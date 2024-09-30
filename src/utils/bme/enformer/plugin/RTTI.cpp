
// ****************************************************************************
// File: RTTI.cpp
// Desc: Run-Time Type Information (RTTI) support
//
// ****************************************************************************
#include "stdafx.h"
#include "Core.h"
#include "RTTI.h"
#include "Vftable.h"
#include <WaitBoxEx.h>
#include "utility.h"

// const Name::`vftable'
static LPCSTR FORMAT_RTTI_VFTABLE = "??_7%s6B@";
static LPCSTR FORMAT_RTTI_VFTABLE_PREFIX = "??_7";
// type 'RTTI Type Descriptor'
static LPCSTR FORMAT_RTTI_TYPE = "??_R0?%s@8";
// 'RTTI Base Class Descriptor at (a,b,c,d)'
static LPCSTR FORMAT_RTTI_BCD = "??_R1%s%s%s%s%s8";
// `RTTI Base Class Array'
static LPCSTR FORMAT_RTTI_BCA = "??_R2%s8";
// 'RTTI Class Hierarchy Descriptor'
static LPCSTR FORMAT_RTTI_CHD = "??_R3%s8";
// 'RTTI Complete Object Locator'
static LPCSTR FORMAT_RTTI_COL = "??_R4%s6B@";
static LPCSTR FORMAT_RTTI_COL_PREFIX = "??_R4";

// Skip type_info tag for class/struct mangled name strings
#define SKIP_TD_TAG(_str) (_str + SIZESTR(".?Ax"))

namespace RTTI
{
    void getBCDInfo(ea_t col, __out bcdList &nameList, __out UINT &numBaseClasses);
	ClassList classList;
	ClassPKeys classPKeys;
	ClassInherit classInherit;
	VFTableList vfTableList;
	UINT maxClassNameLength = 0;
};


typedef stdext::hash_map<ea_t, qstring> stringMap;
static stringMap stringCache;
static eaSet tdSet;
static eaSet chdSet;
static eaSet bcdSet;

void RTTI::freeWorkingData()
{
    stringCache.clear();
    tdSet.clear();
    chdSet.clear();
    bcdSet.clear();
	classList.clear();
	classPKeys.clear();
	vfTableList.clear();
	classInherit.clear();
	vftable::vfGuessedFunc.clear();
}

// Mangle number for labeling
static LPSTR mangleNumber(UINT number, __out_bcount(16) LPSTR buffer)
{
	//
	// 0 = A@
	// X = X-1 (1 <= X <= 10)
	// -X = ? (X - 1)
	// 0x0..0xF = 'A'..'P'

	// Can only get unsigned inputs
	int iNumber = *((PINT) &number);

	if(iNumber == 0)
		return("A@");
	else
	{
		int sign = 0;
		if(iNumber < 0)
		{
			sign = 1;
			iNumber = -iNumber;
		}

		if(iNumber <= 10)
		{
			_snprintf(buffer, 16, "%s%d", (sign ? "?" : ""), (iNumber - 1));
			return(buffer);
		}
		else
		{
			// How many digits max?
			char buffer2[512] = {0};
			int  iCount = sizeof(buffer2);

			while((iNumber > 0) && (iCount > 0))
			{
				buffer2[sizeof(buffer2) - iCount] = ('A' + (iNumber % 16));
				iNumber = (iNumber / 16);
				iCount--;
			};

			if(iCount == 0)
				msg(" *** mangleNumber() Overflow! ***");

			_snprintf(buffer, 16, "%s%s@", (sign ? "?" : ""), buffer2);
			return(buffer);
		}
	}
}


// Return a short label indicating the CHD inheritance type by attributes
// TODO: Consider CHD_AMBIGUOUS?
static LPCSTR attributeLabel(UINT attributes)
{
    if ((attributes & 3) == RTTI::CHD_MULTINH)
		return("[MI]");
	else
    if ((attributes & 3) == RTTI::CHD_VIRTINH)
		return("[VI]");
	else
    if ((attributes & 3) == (RTTI::CHD_MULTINH | RTTI::CHD_VIRTINH))
		return("[MI VI]");
    else
        return("");
}


// Attempt to serialize a managed name until it succeeds
static BOOL serializeName(ea_t ea, __in LPCSTR name)
{
    for (int i = 0; i < 1000000; i++)
    {
        char buffer[MAXSTR]; buffer[SIZESTR(buffer)] = 0;
        _snprintf(buffer, SIZESTR(buffer), "%s_%d", name, i);
        if (set_name(ea, buffer, (SN_NON_AUTO | SN_NOWARN)))
            return(TRUE);
    }
    return(FALSE);
}


// Add RTTI definitions to IDA
// Structure type IDs
static tid_t s_type_info_ID = 1;
static tid_t s_ClassHierarchyDescriptor_ID = 2;
static tid_t s_PMD_ID = 3;
static tid_t s_BaseClassDescriptor_ID = 4;
static tid_t s_CompleteObjectLocator_ID = 5;

// Create structure definition w/comment
static struc_t *AddStruct(__out tid_t &id, __in LPCSTR name, LPCSTR comment)
{
    struc_t *structPtr = NULL;

    // If it exists get current def else create it
	tid_t t = netnode(name);
    id = get_struc_id(name);
    if (BADADDR == id)
		if (BADADDR == t)
			id = add_struc(BADADDR, name);
		else
		{
			msgR("** AddStruct(\"%s\") failed with tid="EAFORMAT"! Name in use for something else!\n", name, t);
			return NULL;
		}
	if (BADADDR != id)
        structPtr = get_struc(id);

    if (structPtr)
    {
        // Clear the old one out if it exists and set the comment
        int dd = del_struc_members(structPtr, 0, MAXADDR);
        dd = dd;
        bool rr = set_struc_cmt(id, comment, true);
        rr = rr;
    }
    else
        msg("** AddStruct(\"%s\") failed with id="EAFORMAT"!\n", name, id);

    return(structPtr);
}

static struc_t *AddClassStruct(__inout tid_t &id, __in LPCSTR name)
{
	char cmt[MAXSTR] = "";
	::qsnprintf(cmt, MAXSTR - 1, "Class %s as struct (#classinformer)", name);
	return AddStruct(id, name, cmt);
}

void RTTI::addDefinitionsToIda()
{
	// Member type info for 32bit offset types
    opinfo_t mtoff;
    ZeroMemory(&mtoff, sizeof(refinfo_t));
    #ifndef __EA64__
	mtoff.ri.flags  = REF_OFF32;
    #define EAOFFSET (offflag() | dwrdflag())
    #else
    mtoff.ri.flags = REF_OFF64;
    #define EAOFFSET (offflag() | qwrdflag())
    #endif
	mtoff.ri.target = BADADDR;

    // Add structure member
    #define ADD_MEMBER(_flags, _mtoff, TYPE, _member)\
    {\
	    TYPE _type;\
        (void)_type;\
	    if(add_struc_member(structPtr, #_member, (ea_t)offsetof(TYPE, _member), (_flags), _mtoff, (asize_t)sizeof(_type._member)) != 0)\
		    msg(" ** ADD_MEMBER(): %s failed! %d, %d **\n", #_member, offsetof(TYPE, _member), sizeof(_type._member));\
    }

    struc_t *structPtr;
    if (structPtr = AddStruct(s_type_info_ID, "type_info", "RTTI std::type_info class (#classinformer)"))
    {
        ADD_MEMBER(EAOFFSET, &mtoff, RTTI::type_info, vfptr);
        ADD_MEMBER(dwrdflag(), NULL, RTTI::type_info, _M_data);

        // Name string zero size
        opinfo_t mt;
        ZeroMemory(&mt, sizeof(refinfo_t));
        if(addStrucMember(structPtr, "_M_d_name", offsetof(RTTI::type_info, _M_d_name), asciflag(), &mt, 0) != 0)
            msg("** addDefinitionsToIda():  _M_d_name failed! \n");
    }

    // Must come before the following  "_RTTIBaseClassDescriptor"
    if (structPtr = AddStruct(s_PMD_ID, "_PMD", "RTTI Base class descriptor displacement container (#classinformer)"))
	{
		ADD_MEMBER(dwrdflag(), NULL, RTTI::PMD, mdisp);
		ADD_MEMBER(dwrdflag(), NULL, RTTI::PMD, pdisp);
		ADD_MEMBER(dwrdflag(), NULL, RTTI::PMD, vdisp);
	}

    if (structPtr = AddStruct(s_ClassHierarchyDescriptor_ID, "_RTTIClassHierarchyDescriptor", "RTTI Class Hierarchy Descriptor (#classinformer)"))
    {
        ADD_MEMBER(dwrdflag(), NULL, RTTI::_RTTIClassHierarchyDescriptor, signature);
        ADD_MEMBER(dwrdflag(), NULL, RTTI::_RTTIClassHierarchyDescriptor, attributes);
        ADD_MEMBER(dwrdflag(), NULL, RTTI::_RTTIClassHierarchyDescriptor, numBaseClasses);
        #ifndef __EA64__
        ADD_MEMBER(EAOFFSET, &mtoff, RTTI::_RTTIClassHierarchyDescriptor, baseClassArray);
        #else
        ADD_MEMBER(dwrdflag(), NULL, RTTI::_RTTIClassHierarchyDescriptor, baseClassArray);
        #endif
    }

    if (structPtr = AddStruct(s_BaseClassDescriptor_ID, "_RTTIBaseClassDescriptor", "RTTI Base Class Descriptor (#classinformer)"))
	{
        #ifndef __EA64__
        ADD_MEMBER(EAOFFSET, &mtoff, RTTI::_RTTIBaseClassDescriptor, typeDescriptor);
        #else
        ADD_MEMBER(dwrdflag(), NULL, RTTI::_RTTIBaseClassDescriptor, typeDescriptor);
        #endif
		ADD_MEMBER(dwrdflag(), NULL, RTTI::_RTTIBaseClassDescriptor, numContainedBases);
        opinfo_t mt;
        ZeroMemory(&mt, sizeof(refinfo_t));
		mt.tid = s_PMD_ID;
		ADD_MEMBER(struflag(), &mt, RTTI::_RTTIBaseClassDescriptor, pmd);
        ADD_MEMBER(dwrdflag(), NULL, RTTI::_RTTIBaseClassDescriptor, attributes);
	}

	if(structPtr = AddStruct(s_CompleteObjectLocator_ID, "_RTTICompleteObjectLocator", "RTTI Complete Object Locator (#classinformer)"))
	{
		ADD_MEMBER(dwrdflag(), NULL, RTTI::_RTTICompleteObjectLocator, signature);
		ADD_MEMBER(dwrdflag(), NULL, RTTI::_RTTICompleteObjectLocator, offset);
		ADD_MEMBER(dwrdflag(), NULL, RTTI::_RTTICompleteObjectLocator, cdOffset);
        #ifndef __EA64__
        ADD_MEMBER(EAOFFSET, &mtoff, RTTI::_RTTICompleteObjectLocator, typeDescriptor);
        ADD_MEMBER(EAOFFSET, &mtoff, RTTI::_RTTICompleteObjectLocator, classDescriptor);
        #else
        ADD_MEMBER(dwrdflag(), NULL, RTTI::_RTTICompleteObjectLocator, typeDescriptor);
        ADD_MEMBER(dwrdflag(), NULL, RTTI::_RTTICompleteObjectLocator, classDescriptor);
        ADD_MEMBER(dwrdflag(), NULL, RTTI::_RTTICompleteObjectLocator, objectBase);
        #endif
	}

    #undef ADD_MEMBER
}

void RTTI::stripAnonymousNamespace(classInfo *ci)
{
	if (LPCSTR sz = strstr(ci->m_cTypeName, "::"))
	{
		char *className;
		sz += 2;
		if (findClassInList(sz))
			return;
		// getPlainTypeName(ci.m_className, className);
		className = ci->m_className;
		while (className = strstr(className, "`anonymous namespace'::"))
		{
			className += strlen("`anonymous namespace'");
			strcpy_s(ci->m_className, className);
		}
		className = ci->m_cTypeName;
		while (className = strstr(className, "_anonymous_namespace_::"))
		{
			className += strlen("_anonymous_namespace_");
			strcpy_s(ci->m_cTypeName, className);
		}
	}
}

static tid_t lpvftableId = 0;

void RTTI::addClassDefinitionsToIda(classInfo ci, bool force)
{
	//msgR(" ** %s.ADD_CLASS_DEF(): **\n", ci.m_classname);

	if (strlen(ci.m_className) > MAXSTR - 1)
	{
		//msgR(" ** class name too long: (%d) %s\n", strlen(ci.m_className), ci.m_className);
		return;	// too dangerous
	}
	//stripAnonymousNamespace(&ci);

	// Member type info for 32bit offset types
	opinfo_t mtoff;
	ZeroMemory(&mtoff, sizeof(refinfo_t));
#ifndef __EA64__
	mtoff.ri.flags = REF_OFF32;
#define EAOFFSET (offflag() | dwrdflag())
#else
	mtoff.ri.flags = REF_OFF64;
#define EAOFFSET (offflag() | qwrdflag())
#endif
	mtoff.ri.target = BADADDR;

#define LPVTABLE "lpVFTable"
#define DUMMY "dummy"

	struc_t *structPtr;

	tid_t id = get_struc_id(ci.m_cTypeName);
	if ((id == BADADDR) || (force && ci.m_sizeFound && (ci.m_size > get_struc_size(id))))
	{
		//msgR(" ** %s.ADD_STRUCT(): as '%s' **\n", ci.m_className, ci.m_cTypeName);

		if (id == BADADDR)
		{
			id = 10;
			for (uval_t i = 0; i < get_struc_qty(); i++) if (tid_t id2 = get_struc_by_idx(i) > id) id = id2;
		}

		if (structPtr = AddClassStruct(++id, ci.m_cTypeName))
		{
			UINT mIndex = 0;
			ea_t offset = 0;
			for (UINT i = 0; i < ci.m_parents.size(); i++)
			{
				classInfo c = classList[ci.m_parents[i]];
				//msgR(" ** %s.ADD_MEMBER(%d): '%s' **\n", ci.m_className, i, c.m_className);

				if (tid_t pid = get_struc_id(c.m_cTypeName))
				{
					asize_t s = get_struc_size(pid);
					opinfo_t copi;
					copi.tid = pid;
					char baseClassName[MAXSTR] = "baseClass";
					char temp[MAXSTR];
					if (i > 0) strcat_s(baseClassName, _itoa(i, temp, 10));
					if (struc_error_t e = add_struc_member(structPtr, baseClassName, offset, struflag(), &copi, s))
						msgR(" ** %s.ADD_MEMBER(): %s failed! error:%d offset:%d, **\n", ci.m_className, c.m_className, e, offset);
					else
					{
						offset += s;
						mIndex++;
					}
				}
			}
			if ((0 == offset) && (0 == mIndex))	// root class, needs vftable if RTTI
			{
				asize_t s = sizeof(ea_t);
				if (ci.m_vft != BADADDR)
					if (lpvftableId)
					{
						opinfo_t copi;
						copi.tid = lpvftableId;
						if (struc_error_t e = add_struc_member(structPtr, LPVTABLE, offset, struflag(), &copi, s))
							msgR(" ** %s.ADD_MEMBER(): %s failed! error:%d offset:%d, **\n", ci.m_className, LPVTABLE, e, offset);
						else
							offset += s;
					}
					else
					if (struc_error_t e = add_struc_member(structPtr, LPVTABLE, offset, EAOFFSET, &mtoff, s))
						msgR(" ** %s.ADD_MEMBER()_: %s failed! error:%d offset:%d, **\n", ci.m_className, LPVTABLE, e, offset);
					else
					{
						offset += s;
						mIndex++;
					}
				else
				{
					if (struc_error_t e = add_struc_member(structPtr, DUMMY, offset, EAOFFSET, &mtoff, s))
						msgR(" ** %s.ADD_MEMBER()_: %s failed! error:%d offset:%d, **\n", ci.m_className, DUMMY, e, offset);
					else
					{
						offset += s;
						mIndex++;
					}
				}
			}

			UINT k = 0;
			size_t s = get_struc_size(id);
			if (ci.m_sizeFound)
				for (UINT j = s; j < ci.m_size;)
				{
					k++;
					ea_t o = j;
#ifndef __EA64__
					flags_t flag = dwrdflag();
#else
					flags_t flag = qwrdflag();
#endif
					struc_error_t e;
					char szTemp[MAXSTR];
					if (j + sizeof(ea_t) <= ci.m_size)
					{
						::qsnprintf(szTemp, MAXSTR - 1, "unk%04X", j);
						e = add_struc_member(structPtr, szTemp, j, flag, NULL, sizeof(ea_t));
						j += sizeof(ea_t);
					}
					else
					if (j + 4 <= ci.m_size)
					{
						::qsnprintf(szTemp, MAXSTR - 1, "dwd%04X", j);
						e = add_struc_member(structPtr, szTemp, j, dwrdflag(), NULL, 4);
						j += 4;
					}
					else
					if (j + 2 <= ci.m_size)
					{
						::qsnprintf(szTemp, MAXSTR - 1, "wrd%04X", j);
						e = add_struc_member(structPtr, szTemp, j, wordflag(), NULL, 4);
						j += 2;
					}
					else
					{
						::qsnprintf(szTemp, MAXSTR - 1, "byt%04X", j);
						e = add_struc_member(structPtr, szTemp, j, byteflag(), NULL, 4);
						j += 1;
					}
					if (e)
						msgR(" ** %s.ADD_MEMBER(): %s failed! error:%d offset:%d, **\n", ci.m_className, szTemp, e, o);
					if (0 == k % 1000)
						msgR(" ** %s.ADD_MEMBER(#%d): %s at offset:%d, **\n", ci.m_className, k, szTemp, o);
				}
		}
	}
	//else
	//	msgR(" ** %s.ADD_STRUCT(): already exists **\n", ci.m_className);
}

// Version 1.05, manually set fields and then try "doStruct()"
// If it fails at least the fields should be set
static void doStructRTTI(ea_t ea, tid_t tid, __in_opt LPSTR typeName = NULL, BOOL bHasChd = FALSE)
{
	#define putDword(ea) doDwrd(ea, sizeof(DWORD))
    #ifndef __EA64__
    #define putEa(ea) doDwrd(ea, sizeof(ea_t))
    #else
    #define putEa(ea) doQwrd(ea, sizeof(ea_t))
    #endif

	if(tid == s_type_info_ID)
	{
        _ASSERT(typeName != NULL);
		UINT nameLen    = (strlen(typeName) + 1);
        UINT structSize = (offsetof(RTTI::type_info, _M_d_name) + nameLen);

		// Place struct
        setUnknown(ea, structSize);
        BOOL result = FALSE;
        if (optionPlaceStructs)
            result = doStruct(ea, structSize, s_type_info_ID);
        if (!result)
        {
            putEa(ea + offsetof(RTTI::type_info, vfptr));
            putEa(ea + offsetof(RTTI::type_info, _M_data));
            doASCI((ea + offsetof(RTTI::type_info, _M_d_name)), nameLen);
        }

        // sh!ft: End should be aligned
        ea_t end = (ea + offsetof(RTTI::type_info, _M_d_name) + nameLen);
        if (end % 4)
            doAlign(end, (4 - (end % 4)), 0);
	}
	else
    if (tid == s_ClassHierarchyDescriptor_ID)
    {
        setUnknown(ea, sizeof(RTTI::_RTTIClassHierarchyDescriptor));
        BOOL result = FALSE;
        if (optionPlaceStructs)
            result = doStruct(ea, sizeof(RTTI::_RTTIClassHierarchyDescriptor), s_ClassHierarchyDescriptor_ID);
        if (!result)
        {
            putDword(ea + offsetof(RTTI::_RTTIClassHierarchyDescriptor, signature));
            putDword(ea + offsetof(RTTI::_RTTIClassHierarchyDescriptor, attributes));
            putDword(ea + offsetof(RTTI::_RTTIClassHierarchyDescriptor, numBaseClasses));
            #ifndef __EA64__
            putEa(ea + offsetof(RTTI::_RTTIClassHierarchyDescriptor, baseClassArray));
            #else
            putDword(ea + offsetof(RTTI::_RTTIClassHierarchyDescriptor, baseClassArray));
            #endif
        }
    }
    else
    if (tid == s_BaseClassDescriptor_ID)
    {
        setUnknown(ea, sizeof(RTTI::_RTTIBaseClassDescriptor));
        doStructRTTI(ea + offsetof(RTTI::_RTTIBaseClassDescriptor, pmd), s_PMD_ID);
        BOOL result = FALSE;
        if (optionPlaceStructs)
            result = doStruct(ea, sizeof(RTTI::_RTTIBaseClassDescriptor), s_BaseClassDescriptor_ID);
        if (!result)
        {
            #ifndef __EA64__
            putEa(ea + offsetof(RTTI::_RTTIBaseClassDescriptor, typeDescriptor));
            #else
            putDword(ea + offsetof(RTTI::_RTTIBaseClassDescriptor, typeDescriptor));
            #endif

            putDword(ea + offsetof(RTTI::_RTTIBaseClassDescriptor, numContainedBases));
            putDword(ea + offsetof(RTTI::_RTTIBaseClassDescriptor, attributes));
            if (bHasChd)
            {
                //_RTTIClassHierarchyDescriptor *classDescriptor; *X64 int32 offset
                #ifndef __EA64__
                putEa(ea + (offsetof(RTTI::_RTTIBaseClassDescriptor, attributes) + sizeof(UINT)));
                #else
                putDword(ea + (offsetof(RTTI::_RTTIBaseClassDescriptor, attributes) + sizeof(UINT)));
                #endif
            }
        }
    }
    else
	if(tid == s_PMD_ID)
	{
		setUnknown(ea, sizeof(RTTI::PMD));
        BOOL result = FALSE;
        if (optionPlaceStructs)
            result = doStruct(ea, sizeof(RTTI::PMD), s_PMD_ID);
        if (!result)
        {
            putDword(ea + offsetof(RTTI::PMD, mdisp));
            putDword(ea + offsetof(RTTI::PMD, pdisp));
            putDword(ea + offsetof(RTTI::PMD, vdisp));
        }
	}
    else
	if(tid == s_CompleteObjectLocator_ID)
	{
		setUnknown(ea, sizeof(RTTI::_RTTICompleteObjectLocator));
        BOOL result = FALSE;
        if (optionPlaceStructs)
            result = doStruct(ea, sizeof(RTTI::_RTTICompleteObjectLocator), s_CompleteObjectLocator_ID);
        if (!result)
        {
            putDword(ea + offsetof(RTTI::_RTTICompleteObjectLocator, signature));
            putDword(ea + offsetof(RTTI::_RTTICompleteObjectLocator, offset));
            putDword(ea + offsetof(RTTI::_RTTICompleteObjectLocator, cdOffset));

            #ifndef __EA64__
            putEa(ea + offsetof(RTTI::_RTTICompleteObjectLocator, typeDescriptor));
            putEa(ea + offsetof(RTTI::_RTTICompleteObjectLocator, classDescriptor));
            #else
            putDword(ea + offsetof(RTTI::_RTTICompleteObjectLocator, typeDescriptor));
            putDword(ea + offsetof(RTTI::_RTTICompleteObjectLocator, classDescriptor));
            putDword(ea + offsetof(RTTI::_RTTICompleteObjectLocator, objectBase));
            #endif
        }
	}
	else
	{
		_ASSERT(FALSE);
	}
}


// Read a string from IDB at address
static int readIdaString(ea_t ea, __out LPSTR buffer, UINT bufferSize)
{
    // Return cached name if it exists
    stringMap::iterator it = stringCache.find(ea);
    if (it != stringCache.end())
    {
        LPCSTR str = it->second.c_str();
        UINT len = strlen(str);

		if (len > RTTI::maxClassNameLength) RTTI::maxClassNameLength = len;

		if (len > bufferSize) len = bufferSize;
        strncpy(buffer, str, len); buffer[len] = 0;
        return(len);
    }
    else
    {
        // Read string at ea if it exists
        UINT len = get_max_ascii_length(ea, ASCSTR_C, ALOPT_IGNHEADS);
        if (len > 0)
        {
            if (len > bufferSize) len = bufferSize;
            if (get_ascii_contents2(ea, len, ASCSTR_C, buffer, bufferSize))
            {
                // Cache it
                buffer[len - 1] = 0;
                stringCache[ea] = buffer;
            }
            else
                len = 0;
        }
        return(len);
    }
}


// --------------------------- Type descriptor ---------------------------

// Get type name into a buffer
// type_info assumed to be valid
int RTTI::type_info::getName(ea_t typeInfo, __out LPSTR buffer, int bufferSize)
{
    return(readIdaString(typeInfo + offsetof(type_info, _M_d_name), buffer, bufferSize));
}

// A valid type_info/TypeDescriptor at pointer?
BOOL RTTI::type_info::isValid(ea_t typeInfo)
{
    // TRUE if we've already seen it
    if (tdSet.find(typeInfo) != tdSet.end())
        return(TRUE);

    if (isLoaded(typeInfo))
	{
		// Verify what should be a vftable
        ea_t ea = getEa(typeInfo + offsetof(type_info, vfptr));
        if (isLoaded(ea))
		{
            // _M_data should be NULL statically
            ea_t _M_data = BADADDR;
            if (getVerifyEa((typeInfo + offsetof(type_info, _M_data)), _M_data))
            {
                if (_M_data == 0)
                    return(isTypeName(typeInfo + offsetof(type_info, _M_d_name)));
            }
		}
	}

	return(FALSE);
}

// Returns TRUE if known typename at address
BOOL RTTI::type_info::isTypeName(ea_t name)
{
    // Should start with a period
    if (get_byte(name) == '.')
    {
        // Read the rest of the possible name string
        char buffer[MAXSTR]; buffer[0] = buffer[SIZESTR(buffer)] = 0;
        if (readIdaString(name, buffer, SIZESTR(buffer)))
        {
            // Should be valid if it properly demangles
            if (LPSTR s = __unDName(NULL, buffer+1 /*skip the '.'*/, 0, malloc, free, (UNDNAME_32_BIT_DECODE | UNDNAME_TYPE_ONLY)))
            {
                free(s);
                return(TRUE);
            }
        }
    }
    return(FALSE);
}

// Returns non empty if name can be demangled
void RTTI::getTypeName(qstring& name)
{
	// Should start with a period
	if (name[0] == '?')
	{
		// Read the rest of the possible name string
		char buffer[MAXSTR] = ""; strcpy_s(buffer, SIZESTR(buffer), name.c_str()); buffer[SIZESTR(buffer)] = 0;
		// Should be valid if it properly demangles
		if (LPSTR s = __unDName(NULL, buffer, 0, malloc, free, 0))
		{
			name = s;
			free(s);
			return;
		}
	}
	name = "";
}

// Put struct and place name at address
void RTTI::type_info::doStruct(ea_t typeInfo)
{
    // Only place once per address
    if (tdSet.find(typeInfo) != tdSet.end())
        return;
    else
        tdSet.insert(typeInfo);

	// Get type name
	char name[MAXSTR]; name[0] = name[SIZESTR(name)] = 0;
    int nameLen = getName(typeInfo, name, SIZESTR(name));

	doStructRTTI(typeInfo, s_type_info_ID, name);
    if (nameLen > 0)
    {
        if (!hasUniqueName(typeInfo))
        {
            // Set decorated name/label
            char name2[MAXSTR]; name2[SIZESTR(name2)] = 0;
            _snprintf(name2, SIZESTR(name2), FORMAT_RTTI_TYPE, name + 2);
            set_name(typeInfo, name2, (SN_NON_AUTO | SN_NOWARN | SN_NOCHECK));
        }
    }
    #ifdef _DEVMODE
    else
        _ASSERT(FALSE);
    #endif
}


// --------------------------- Complete Object Locator ---------------------------

// Return TRUE if address is a valid RTTI structure
BOOL RTTI::_RTTICompleteObjectLocator::isValid(ea_t col)
{
    if (isLoaded(col))
    {
        // Check signature
        UINT signature = -1;
        if (getVerify32_t((col + offsetof(_RTTICompleteObjectLocator, signature)), signature))
        {
            #ifndef __EA64__
            if (signature == 0)
            {
                // Check valid type_info
                ea_t typeInfo = getEa(col + offsetof(_RTTICompleteObjectLocator, typeDescriptor));
                if (RTTI::type_info::isValid(typeInfo))
                {
                    ea_t classDescriptor = getEa(col + offsetof(_RTTICompleteObjectLocator, classDescriptor));
                    if (RTTI::_RTTIClassHierarchyDescriptor::isValid(classDescriptor))
                    {
                        //msg(EAFORMAT" " EAFORMAT " " EAFORMAT " \n", col, typeInfo, classDescriptor);
                        return(TRUE);
                    }
                }
            }
            #else
            if (signature == 1)
			{
                // TODO: Can any of these be zero and still be valid?
                UINT objectLocator = get_32bit(col + offsetof(RTTI::_RTTICompleteObjectLocator, objectBase));
                if (objectLocator != 0)
                {
                    UINT tdOffset = get_32bit(col + offsetof(_RTTICompleteObjectLocator, typeDescriptor));
                    if (tdOffset != 0)
                    {
                        UINT cdOffset = get_32bit(col + offsetof(RTTI::_RTTICompleteObjectLocator, classDescriptor));
                        if (cdOffset != 0)
                        {
                            ea_t colBase = (col - (UINT64)objectLocator);

                            ea_t typeInfo = (colBase + (UINT64)tdOffset);
                            if (RTTI::type_info::isValid(typeInfo))
                            {
                                ea_t classDescriptor = (colBase + (UINT64) cdOffset);
                                if (RTTI::_RTTIClassHierarchyDescriptor::isValid(classDescriptor, colBase))
                                {
                                    //msg(EAFORMAT" " EAFORMAT " " EAFORMAT " \n", col, typeInfo, classDescriptor);
                                    return(TRUE);
                                }
                            }
                        }
                    }
                }
			}
            #endif
		}
	}

	return(FALSE);
}

// Same as above but from an already validated type_info perspective
#ifndef __EA64__
BOOL RTTI::_RTTICompleteObjectLocator::isValid2(ea_t col)
{
    // 'signature' should be zero
    UINT signature = -1;
    if (getVerify32_t((col + offsetof(_RTTICompleteObjectLocator, signature)), signature))
    {
        if (signature == 0)
        {
            // Verify CHD
            ea_t classDescriptor = getEa(col + offsetof(_RTTICompleteObjectLocator, classDescriptor));
            if (classDescriptor && (classDescriptor != BADADDR))
                return(RTTI::_RTTIClassHierarchyDescriptor::isValid(classDescriptor));
        }
    }

    return(FALSE);
}
#endif

// Place full COL hierarchy structures
void RTTI::_RTTICompleteObjectLocator::doStruct(ea_t col)
{
    doStructRTTI(col, s_CompleteObjectLocator_ID);

    #ifndef __EA64__
    // Put type_def
    ea_t typeInfo = getEa(col + offsetof(_RTTICompleteObjectLocator, typeDescriptor));
    type_info::doStruct(typeInfo);

    // Place CHD hierarchy
    ea_t classDescriptor = getEa(col + offsetof(_RTTICompleteObjectLocator, classDescriptor));
    _RTTIClassHierarchyDescriptor::doStruct(classDescriptor);
    #else
    UINT tdOffset = get_32bit(col + offsetof(_RTTICompleteObjectLocator, typeDescriptor));
    UINT cdOffset = get_32bit(col + offsetof(RTTI::_RTTICompleteObjectLocator, classDescriptor));
    UINT objectLocator = get_32bit(col + offsetof(RTTI::_RTTICompleteObjectLocator, objectBase));
    ea_t colBase = (col - (UINT64)objectLocator);

    ea_t typeInfo = (colBase + (UINT64)tdOffset);
    type_info::doStruct(typeInfo);

    ea_t classDescriptor = (colBase + (UINT64)cdOffset);
    _RTTIClassHierarchyDescriptor::doStruct(classDescriptor, colBase);

    // Set absolute address comments
    char buffer[64];
    sprintf(buffer, "0x" EAFORMAT, typeInfo);
    set_cmt((col + offsetof(RTTI::_RTTICompleteObjectLocator, typeDescriptor)), buffer, TRUE);
    sprintf(buffer, "0x" EAFORMAT, classDescriptor);
    set_cmt((col + offsetof(RTTI::_RTTICompleteObjectLocator, classDescriptor)), buffer, TRUE);
    #endif
}


// --------------------------- Base Class Descriptor ---------------------------

// Return TRUE if address is a valid BCD
BOOL RTTI::_RTTIBaseClassDescriptor::isValid(ea_t bcd, ea_t colBase64)
{
    // TRUE if we've already seen it
    if (bcdSet.find(bcd) != bcdSet.end())
        return(TRUE);

    if (isLoaded(bcd))
    {
        // Check attributes flags first
        UINT attributes = -1;
        if (getVerify32_t((bcd + offsetof(_RTTIBaseClassDescriptor, attributes)), attributes))
        {
            // Valid flags are the lower byte only
            if ((attributes & 0xFFFFFF00) == 0)
            {
                // Check for valid type_info
                #ifndef __EA64__
                return(RTTI::type_info::isValid(getEa(bcd + offsetof(_RTTIBaseClassDescriptor, typeDescriptor))));
                #else
                UINT tdOffset = get_32bit(bcd + offsetof(_RTTIBaseClassDescriptor, typeDescriptor));
                ea_t typeInfo = (colBase64 + (UINT64) tdOffset);
                return(RTTI::type_info::isValid(typeInfo));
                #endif
            }
        }
    }

    return(FALSE);
}

// Put BCD structure at address
void RTTI::_RTTIBaseClassDescriptor::doStruct(ea_t bcd, __out_bcount(MAXSTR) LPSTR baseClassName, ea_t colBase64)
{
    // Only place it once
    if (bcdSet.find(bcd) != bcdSet.end())
    {
        // Seen already, just return type name
        #ifndef __EA64__
        ea_t typeInfo = getEa(bcd + offsetof(_RTTIBaseClassDescriptor, typeDescriptor));
        #else
        UINT tdOffset = get_32bit(bcd + offsetof(_RTTIBaseClassDescriptor, typeDescriptor));
        ea_t typeInfo = (colBase64 + (UINT64) tdOffset);
        #endif

        char buffer[MAXSTR]; buffer[0] = buffer[SIZESTR(buffer)] = 0;
        type_info::getName(typeInfo, buffer, SIZESTR(buffer));
        strcpy(baseClassName, SKIP_TD_TAG(buffer));
        return;
    }
    else
        bcdSet.insert(bcd);

    if (isLoaded(bcd))
    {
        UINT attributes = get_32bit(bcd + offsetof(_RTTIBaseClassDescriptor, attributes));
        doStructRTTI(bcd, s_BaseClassDescriptor_ID, NULL, ((attributes & BCD_HASPCHD) > 0));

        // Has appended CHD?
        if (attributes & BCD_HASPCHD)
        {
            // yes, process it
            ea_t chdOffset = (bcd + (offsetof(_RTTIBaseClassDescriptor, attributes) + sizeof(UINT)));

            #ifndef __EA64__
            fixEa(chdOffset);
            ea_t chd = getEa(chdOffset);
            #else
            fixDword(chdOffset);
            UINT chdOffset32 = get_32bit(chdOffset);
            ea_t chd = (colBase64 + (UINT64) chdOffset32);

            char buffer[64];
            sprintf(buffer, "0x" EAFORMAT, chd);
            set_cmt(chdOffset, buffer, TRUE);
            #endif

            if (isLoaded(chd))
                _RTTIClassHierarchyDescriptor::doStruct(chd, colBase64);
            else
                _ASSERT(FALSE);
        }

        // Place type_info struct
        #ifndef __EA64__
        ea_t typeInfo = getEa(bcd + offsetof(_RTTIBaseClassDescriptor, typeDescriptor));
        #else
        UINT tdOffset = get_32bit(bcd + offsetof(_RTTIBaseClassDescriptor, typeDescriptor));
        ea_t typeInfo = (colBase64 + (UINT64)tdOffset);
        #endif
        type_info::doStruct(typeInfo);

        // Get raw type/class name
        char buffer[MAXSTR]; buffer[0] = buffer[SIZESTR(buffer)] = 0;
        type_info::getName(typeInfo, buffer, SIZESTR(buffer));
        strcpy(baseClassName, SKIP_TD_TAG(buffer));

        if (!optionPlaceStructs && attributes)
        {
            // Place attributes comment
            if (!has_cmt(getFlags(bcd + offsetof(_RTTIBaseClassDescriptor, attributes))))
            {
                qstring s("");
                BOOL b = 0;
                #define ATRIBFLAG(_flag) { if (attributes & _flag) { if (b) s += " | ";  s += #_flag; b = 1; } }
                ATRIBFLAG(BCD_NOTVISIBLE);
                ATRIBFLAG(BCD_AMBIGUOUS);
                ATRIBFLAG(BCD_PRIVORPROTINCOMPOBJ);
                ATRIBFLAG(BCD_PRIVORPROTBASE);
                ATRIBFLAG(BCD_VBOFCONTOBJ);
                ATRIBFLAG(BCD_NONPOLYMORPHIC);
                ATRIBFLAG(BCD_HASPCHD);
                #undef ATRIBFLAG
                set_cmt((bcd + offsetof(_RTTIBaseClassDescriptor, attributes)), s.c_str(), TRUE);
            }
        }

        // Give it a label
        if (!hasUniqueName(bcd))
        {
            // Name::`RTTI Base Class Descriptor at (0, -1, 0, 0)'
            ZeroMemory(buffer, sizeof(buffer));
            char buffer1[32] = { 0 }, buffer2[32] = { 0 }, buffer3[32] = { 0 }, buffer4[32] = { 0 };
            _snprintf(buffer, SIZESTR(buffer), FORMAT_RTTI_BCD,
                mangleNumber(get_32bit(bcd + (offsetof(_RTTIBaseClassDescriptor, pmd) + offsetof(PMD, mdisp))), buffer1),
                mangleNumber(get_32bit(bcd + (offsetof(_RTTIBaseClassDescriptor, pmd) + offsetof(PMD, pdisp))), buffer2),
                mangleNumber(get_32bit(bcd + (offsetof(_RTTIBaseClassDescriptor, pmd) + offsetof(PMD, vdisp))), buffer3),
                mangleNumber(attributes, buffer4),
                baseClassName);

            if (!set_name(bcd, buffer, (SN_NON_AUTO | SN_NOWARN)))
                serializeName(bcd, buffer);
        }
    }
    else
        _ASSERT(FALSE);
}


// --------------------------- Class Hierarchy Descriptor ---------------------------

// Return true if address is a valid CHD structure
BOOL RTTI::_RTTIClassHierarchyDescriptor::isValid(ea_t chd, ea_t colBase64)
{
    // TRUE if we've already seen it
    if (chdSet.find(chd) != chdSet.end())
        return(TRUE);

    if (isLoaded(chd))
    {
        // signature should be zero statically
        UINT signature = -1;
        if (getVerify32_t((chd + offsetof(_RTTIClassHierarchyDescriptor, signature)), signature))
        {
            if (signature == 0)
            {
                // Check attributes flags
                UINT attributes = -1;
                if (getVerify32_t((chd + offsetof(_RTTIClassHierarchyDescriptor, attributes)), attributes))
                {
                    // Valid flags are the lower nibble only
                    if ((attributes & 0xFFFFFFF0) == 0)
                    {
                        // Should have at least one base class
                        UINT numBaseClasses = 0;
                        if (getVerify32_t((chd + offsetof(_RTTIClassHierarchyDescriptor, numBaseClasses)), numBaseClasses))
                        {
                            if (numBaseClasses >= 1)
                            {
                                // Check the first BCD entry
                                #ifndef __EA64__
                                ea_t baseClassArray = getEa(chd + offsetof(_RTTIClassHierarchyDescriptor, baseClassArray));
                                #else
                                UINT baseClassArrayOffset = get_32bit(chd + offsetof(_RTTIClassHierarchyDescriptor, baseClassArray));
                                ea_t baseClassArray = (colBase64 + (UINT64) baseClassArrayOffset);
                                #endif

                                if (isLoaded(baseClassArray))
                                {
                                    #ifndef __EA64__
                                    ea_t baseClassDescriptor = getEa(baseClassArray);
                                    return(RTTI::_RTTIBaseClassDescriptor::isValid(baseClassDescriptor));
                                    #else
                                    ea_t baseClassDescriptor = (colBase64 + (UINT64) get_32bit(baseClassArray));
                                    return(RTTI::_RTTIBaseClassDescriptor::isValid(baseClassDescriptor, colBase64));
                                    #endif
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    return(FALSE);
}


// Put CHD structure at address
void RTTI::_RTTIClassHierarchyDescriptor::doStruct(ea_t chd, ea_t colBase64)
{
    // Only place it once per address
    if (chdSet.find(chd) != chdSet.end())
        return;
    else
        chdSet.insert(chd);

    if (isLoaded(chd))
    {
        // Place CHD
        doStructRTTI(chd, s_ClassHierarchyDescriptor_ID);

        // Place attributes comment
        UINT attributes = get_32bit(chd + offsetof(_RTTIClassHierarchyDescriptor, attributes));
        if (!optionPlaceStructs && attributes)
        {
            if (!has_cmt(getFlags(chd + offsetof(_RTTIClassHierarchyDescriptor, attributes))))
            {
                qstring s("");
                BOOL b = 0;
                #define ATRIBFLAG(_flag) { if (attributes & _flag) { if (b) s += " | ";  s += #_flag; b = 1; } }
                ATRIBFLAG(CHD_MULTINH);
                ATRIBFLAG(CHD_VIRTINH);
                ATRIBFLAG(CHD_AMBIGUOUS);
                #undef ATRIBFLAG
                set_cmt((chd + offsetof(_RTTIClassHierarchyDescriptor, attributes)), s.c_str(), TRUE);
            }
        }

        // ---- Place BCD's ----
        UINT numBaseClasses = 0;
        if (getVerify32_t((chd + offsetof(_RTTIClassHierarchyDescriptor, numBaseClasses)), numBaseClasses))
        {
            // Get pointer
            #ifndef __EA64__
            ea_t baseClassArray = getEa(chd + offsetof(_RTTIClassHierarchyDescriptor, baseClassArray));
            #else
            UINT baseClassArrayOffset = get_32bit(chd + offsetof(_RTTIClassHierarchyDescriptor, baseClassArray));
            ea_t baseClassArray = (colBase64 + (UINT64) baseClassArrayOffset);

            char buffer[MAXSTR];
            sprintf(buffer, "0x" EAFORMAT, baseClassArray);
            set_cmt((chd + offsetof(RTTI::_RTTIClassHierarchyDescriptor, baseClassArray)), buffer, TRUE);
            #endif

            if (baseClassArray && (baseClassArray != BADADDR))
            {
                // Create offset string based on input digits
                #ifndef __EA64__
                char format[32];
                if(numBaseClasses > 1)
                {
                    int iDigits = strlen(_itoa(numBaseClasses, format, 10));
                    if (iDigits > 1)
                        _snprintf(format, SIZESTR(format), "  BaseClass[%%0%dd]", iDigits);
                    else
                        strncpy(format, "  BaseClass[%d]", SIZESTR(format));
                }
                #else
                char format[128];
                if (numBaseClasses > 1)
                {
                    int iDigits = strlen(_itoa(numBaseClasses, format, 10));
                    if (iDigits > 1)
                        _snprintf(format, SIZESTR(format), "  BaseClass[%%0%dd] 0x%016I64X", iDigits);
                    else
                        strncpy(format, "  BaseClass[%d] 0x%016I64X", SIZESTR(format));
                }
                #endif

                for (UINT i = 0; i < numBaseClasses; i++, baseClassArray += sizeof(UINT)) // sizeof(ea_t)
                {
                    #ifndef __EA64__
                    fixEa(baseClassArray);

                    // Add index comment to to it
                    if (!has_cmt(get_flags_novalue(baseClassArray)))
                    {
                        if (numBaseClasses == 1)
                            set_cmt(baseClassArray, "  BaseClass", FALSE);
                        else
                        {
                            char ptrComent[MAXSTR]; ptrComent[SIZESTR(ptrComent)] = 0;
                            _snprintf(ptrComent, SIZESTR(ptrComent), format, i);
                            set_cmt(baseClassArray, ptrComent, false);
                        }
                    }

                    // Place BCD struct, and grab the base class name
                    char baseClassName[MAXSTR];
                    _RTTIBaseClassDescriptor::doStruct(getEa(baseClassArray), baseClassName);
                    #else
                    fixDword(baseClassArray);
                    UINT bcOffset = get_32bit(baseClassArray);
                    ea_t bcd = (colBase64 + (UINT64)bcOffset);

                    // Add index comment to to it
                    if (!has_cmt(get_flags_novalue(baseClassArray)))
                    {
                        if (numBaseClasses == 1)
                        {
                            sprintf(buffer, "  BaseClass 0x" EAFORMAT, bcd);
                            set_cmt(baseClassArray, buffer, FALSE);
                        }
                        else
                        {
                            _snprintf(buffer, SIZESTR(buffer), format, i, bcd);
                            set_cmt(baseClassArray, buffer, false);
                        }
                    }

                    // Place BCD struct, and grab the base class name
                    char baseClassName[MAXSTR];
                    _RTTIBaseClassDescriptor::doStruct(bcd, baseClassName, colBase64);
                    #endif

                    // Now we have the base class name, name and label some things
                    if (i == 0)
                    {
                        // Set array name
                        if (!hasUniqueName(baseClassArray))
                        {
                            // ??_R2A@@8 = A::`RTTI Base Class Array'
                            char mangledName[MAXSTR]; mangledName[SIZESTR(mangledName)] = 0;
                            _snprintf(mangledName, SIZESTR(mangledName), FORMAT_RTTI_BCA, baseClassName);
                            if (!set_name(baseClassArray, mangledName, (SN_NON_AUTO | SN_NOWARN)))
                                serializeName(baseClassArray, mangledName);
                        }

                        // Add a spacing comment line above us
                        if (optionOverwriteComments)
                        {
                            killAnteriorComments(baseClassArray);
                            add_long_cmt(baseClassArray, true, "");
                        }
                        else
                        if (!hasAnteriorComment(baseClassArray))
                            add_long_cmt(baseClassArray, true, "");

                        // Set CHD name
                        if (!hasUniqueName(chd))
                        {
                            // A::`RTTI Class Hierarchy Descriptor'
                            char mangledName[MAXSTR]; mangledName[SIZESTR(mangledName)] = 0;
                            _snprintf(mangledName, (MAXSTR - 1), FORMAT_RTTI_CHD, baseClassName);
                            if (!set_name(chd, mangledName, (SN_NON_AUTO | SN_NOWARN)))
                                serializeName(chd, mangledName);
                        }
                    }
                }

                // Make following DWORD if it's bytes are zeros
                if (numBaseClasses > 0)
                {
                    if (isLoaded(baseClassArray))
                    {
                        if (get_32bit(baseClassArray) == 0)
                            fixDword(baseClassArray);
                    }
                }
            }
            else
                _ASSERT(FALSE);
        }
        else
            _ASSERT(FALSE);
    }
    else
        _ASSERT(FALSE);
}


// --------------------------- Vftable ---------------------------


// Get list of base class descriptor info
static void RTTI::getBCDInfo(ea_t col, __out bcdList &list, __out UINT &numBaseClasses)
{
	numBaseClasses = 0;

    #ifndef __EA64__
    ea_t chd = getEa(col + offsetof(_RTTICompleteObjectLocator, classDescriptor));
    #else
    UINT cdOffset = get_32bit(col + offsetof(RTTI::_RTTICompleteObjectLocator, classDescriptor));
    UINT objectLocator = get_32bit(col + offsetof(RTTI::_RTTICompleteObjectLocator, objectBase));
    ea_t colBase = (col - (UINT64) objectLocator);
    ea_t chd = (colBase + (UINT64) cdOffset);
    #endif

	if(chd)
	{
        if (numBaseClasses = get_32bit(chd + offsetof(_RTTIClassHierarchyDescriptor, numBaseClasses)))
		{
            list.resize(numBaseClasses);

			// Get pointer
            #ifndef __EA64__
            ea_t baseClassArray = getEa(chd + offsetof(_RTTIClassHierarchyDescriptor, baseClassArray));
            #else
            UINT bcaOffset = get_32bit(chd + offsetof(_RTTIClassHierarchyDescriptor, baseClassArray));
            ea_t baseClassArray = (colBase + (UINT64) bcaOffset);
            #endif

			if(baseClassArray && (baseClassArray != BADADDR))
			{
				for(UINT i = 0; i < numBaseClasses; i++, baseClassArray += sizeof(UINT)) // sizeof(ea_t)
				{
                    #ifndef __EA64__
                    // Get next BCD
                    ea_t bcd = getEa(baseClassArray);

                    // Get type name
                    ea_t typeInfo = getEa(bcd + offsetof(_RTTIBaseClassDescriptor, typeDescriptor));
                    #else
                    UINT bcdOffset = get_32bit(baseClassArray);
                    ea_t bcd = (colBase + (UINT64) bcdOffset);

                    UINT tdOffset = get_32bit(bcd + offsetof(_RTTIBaseClassDescriptor, typeDescriptor));
                    ea_t typeInfo = (colBase + (UINT64) tdOffset);
                    #endif
                    bcdInfo *bi = &list[i];
                    type_info::getName(typeInfo, bi->m_name, SIZESTR(bi->m_name));

					// Add info to list
                    UINT mdisp = get_32bit(bcd + (offsetof(_RTTIBaseClassDescriptor, pmd) + offsetof(PMD, mdisp)));
                    UINT pdisp = get_32bit(bcd + (offsetof(_RTTIBaseClassDescriptor, pmd) + offsetof(PMD, pdisp)));
                    UINT vdisp = get_32bit(bcd + (offsetof(_RTTIBaseClassDescriptor, pmd) + offsetof(PMD, vdisp)));
                    // As signed int
                    bi->m_pmd.mdisp = *((PINT) &mdisp);
                    bi->m_pmd.pdisp = *((PINT) &pdisp);
                    bi->m_pmd.vdisp = *((PINT) &vdisp);
                    bi->m_attribute = get_32bit(bcd + offsetof(_RTTIBaseClassDescriptor, attributes));

					//msg("   BN: [%d] \"%s\", ATB: %04X\n", i, bi->m_name, get_32bit((ea_t) bi->m_attribute));
					//msg("       mdisp: %d, pdisp: %d, vdisp: %d\n", *((PINT) &mdisp), *((PINT) &pdisp), *((PINT) &vdisp));
				}
			}
		}
	}
}


BOOL RTTI::stripClassName(__in LPCSTR name, __out_bcount(MAXSTR) LPSTR outStr)
{
	outStr[0] = outStr[MAXSTR - 1] = 0;

	UINT i = 0;
	UINT j = 0;
	while (i < strlen(name))
	{
		if (name[i] != '@') {
			outStr[j] = name[i];
			j++;
}
		i++;
		outStr[j] = 0;
	}
	return(TRUE);
}

static UINT lastTooLong = 0;

void RTTI::ReplaceForCTypeName(LPSTR cTypeName, LPCSTR currName)
{
	char workingName[MAXSTR];
	lastTooLong++;
	QT::qsnprintf(cTypeName, MAXSTR - 2, "__ICI__TooLong%0.5d__", lastTooLong);
	if (strlen(currName) < (MAXSTR - 25)) {
		strcpy_s(workingName, MAXSTR - 2, currName);
		while (LPSTR sz = strchr(workingName, '\'')) *sz = '_';
		while (LPSTR sz = strchr(workingName, '`')) *sz = '_';
		while (LPSTR sz = strchr(workingName, '<')) *sz = '_';
		while (LPSTR sz = strchr(workingName, '>')) *sz = '_';
		while (LPSTR sz = strchr(workingName, ',')) *sz = '_';
		while (LPSTR sz = strchr(workingName, ' ')) *sz = '_';
		while (LPSTR sz = strchr(workingName, '*')) *sz = '_';
		while (LPSTR sz = strchr(workingName, '&')) *sz = '_';
		while (LPSTR sz = strchr(workingName, '?')) *sz = '_';
		while (LPSTR sz = strchr(workingName, '-')) *sz = '_';
		while (LPSTR sz = strchr(workingName, '(')) *sz = '_';
		while (LPSTR sz = strchr(workingName, ')')) *sz = '_';
		while (LPSTR sz = strchr(workingName, '[')) *sz = '_';
		while (LPSTR sz = strchr(workingName, ']')) *sz = '_';
		while (LPSTR sz = strchr(workingName, '{')) *sz = '_';
		while (LPSTR sz = strchr(workingName, '}')) *sz = '_';
		while (LPSTR sz = strchr(workingName, '~')) *sz = '_';
		if (strlen(workingName) < (MAXSTR - 25))
		{
			strcpy_s(cTypeName, MAXSTR - 1, workingName);
			lastTooLong--;
		}
	}
	//msgR("  ** PrefixName:'%s' as '%s'\n", prefixName, cTypeName);
}

void RTTI::CalcCTypeName(LPSTR cTypeName, LPCSTR prefixName)
{
	char workingName[MAXSTR];
	stripClassName(prefixName, workingName);
	ReplaceForCTypeName(cTypeName, workingName);
	//msgR("  ** PrefixName:'%s' as '%s'\n", prefixName, cTypeName);
}

bool RTTI::AddNonRTTIclass(LPCSTR prefixName)
{
	//msg(" =" EAFORMAT " " EAFORMAT " ColName:'%s' DemangledName:'%s' PrefixName:'%s'\n", vft, col, colName, demangledColName, prefixName);
	classInfo ci;
	bcdList list;
	char tempName[MAXSTR];
	char newName[MAXSTR];
	if (strlen(prefixName) > MAXSTR - 25)
	{
		::qsnprintf(tempName, (MAXSTR - 1), "__ICI__classTooLongRenamed_%d__", lastTooLong++);
		msgR("\t\t\tToo long: '%s'\t\t\t\treplaced by '%s'\n", prefixName, tempName);
		strcpy_s(newName, MAXSTR, tempName);
	}
	else
		strcpy_s(newName, MAXSTR, prefixName);
	stripClassName(newName, tempName);
	strcpy_s(ci.m_className, (MAXSTR - 1), tempName);
	size_t i = 0;
	while (findClassInList(ci.m_className))
	{
		::qsnprintf(ci.m_className, (size_t)(MAXSTR - 1), "%s_%d", tempName, i);
		msgR("\t\t\tTrying className:'%s'\n", ci.m_className);
		i++;
	}
	CalcCTypeName(ci.m_cTypeName, ci.m_className);
	strcpy_s(ci.m_colName, "");
	strcpy_s(ci.m_templateInfo.m_templatename, "");
	ci.m_bcdlist = list;
	ci.m_vft = BADADDR;
	ci.m_col = BADADDR;
	ci.m_start = BADADDR;
	ci.m_end = BADADDR;
	ci.m_numBaseClasses = 1;
	ci.m_baseClassIndex = 0;
	ci.m_templateInfo.m_template = strchr(ci.m_className, '<');
	ci.m_templateInfo.m_templateTypeCount = 0;
	ci.m_sizeFound = false;
	ci.m_size = 0;
	if (ci.m_templateInfo.m_template)
	{
		decodeTemplate(&(ci.m_templateInfo), ci.m_className);
	}
	addClassDefinitionsToIda(ci, false);

	int s = classList.size();
	classList.resize(s + 1);
	classList[s] = ci;

	classKeyInfo aPK;
	ClassListPK(aPK.pk, ci);
	aPK.index = s;
	//msg("  ** Sorting class '%s' from %d\n", aPK.pk, s);
	refreshUI();
	bool found = false;
	for (ClassPKeys::iterator i = classPKeys.begin(); i != classPKeys.end(); i++)
	{
		int s = stricmp(aPK.pk, i->pk);
		if (0 >= s)
		{
			found = true;
			if (0 != s)
			{
				//msg("  ** Insert before " EAFORMAT " '%s' at %d\n", i, i->pk, i->index);
				classPKeys.insert(i, aPK);
			}
			else
			{
				msg("  ** This class %d already exists! '%s' at index %d. [as '%s' or '%s'] 1\n", aPK.index, aPK.pk, i->index, ci.m_className, ci.m_cTypeName);
				refreshUI();
				return false;
			}
			break;
		}
	}
	if (!found)
		classPKeys.push_back(aPK);

	classInheritInfo cii;
	ClassListInherit(&cii.classes, ci);
	cii.index = s;
	found = false;
	for (ClassInherit::iterator i = classInherit.begin(); i != classInherit.end(); i++)
	{
		int s = stricmp(cii.classes.c_str(), i->classes.c_str());
		if (0 >= s)
		{
			found = true;
			if (0 != s)
			{
				classInherit.insert(i, cii);
			}
			else
			{
				msg("  ** This class %d already exists! '%s' at index %d. 2\n", cii.index, ci.m_className, i->index);
				refreshUI();
				return false;
			}
			break;
		}
	}
	if (!found)
		classInherit.push_back(cii);
	return true;
}

// Process RTTI vftable info part 1: Find class name and initial hierarchy. Store result in classList
void RTTI::processVftablePart1(ea_t vft, ea_t col)
{
    #ifdef __EA64__
    UINT tdOffset = get_32bit(col + offsetof(_RTTICompleteObjectLocator, typeDescriptor));
    UINT objectLocator = get_32bit(col + offsetof(RTTI::_RTTICompleteObjectLocator, objectBase));
    ea_t colBase  = (col - (UINT64) objectLocator);
    ea_t typeInfo = (colBase + (UINT64) tdOffset);
    #endif

    // Get vftable info
    vftable::vtinfo vi;
    if (vftable::getTableInfo(vft, vi, 0))
    {
        //msg(EAFORMAT" - " EAFORMAT " c: %d\n", vi.start, vi.end, vi.methodCount);

	    // Get COL type name
        #ifndef __EA64__
        ea_t typeInfo = getEa(col + offsetof(_RTTICompleteObjectLocator, typeDescriptor));
        ea_t chd = get_32bit(col + offsetof(_RTTICompleteObjectLocator, classDescriptor));
        #else
        UINT cdOffset = get_32bit(col + offsetof(RTTI::_RTTICompleteObjectLocator, classDescriptor));
        ea_t chd = (colBase + (UINT64) cdOffset);
        #endif

        char colName[MAXSTR]; colName[0] = colName[SIZESTR(colName)] = 0;
        type_info::getName(typeInfo, colName, SIZESTR(colName));
		if (strlen(colName) > maxClassNameLength)
			maxClassNameLength = strlen(colName);
        char demangledColName[MAXSTR];
        if (!getPlainTypeName(colName, demangledColName))
			strcpy_s(demangledColName, colName);
		char prefixName[MAXSTR];
		strcpy_s(prefixName, demangledColName);
		//msg("  " EAFORMAT " " EAFORMAT " ColName:'%s' DemangledName:'%s' PrefixName:'%s'\n", vft, col, colName, demangledColName, prefixName);

		UINT chdAttributes = get_32bit(chd + offsetof(_RTTIClassHierarchyDescriptor, attributes));
        UINT offset = get_32bit(col + offsetof(_RTTICompleteObjectLocator, offset));

	    // Parse BCD info
	    bcdList list;
        UINT numBaseClasses;
	    getBCDInfo(col, list, numBaseClasses);
		int baseClassIndex = 0;
		UINT realNumBaseClasses = numBaseClasses;

        BOOL success = FALSE, isTopLevel = FALSE;
        qstring cmt;

	    // ======= Simple or no inheritance
        if ((offset == 0) && ((chdAttributes & (CHD_MULTINH | CHD_VIRTINH)) == 0))
	    {
		    // Set the vftable name
            if (!hasUniqueName(vft))
		    {
                // Decorate raw name as a vftable. I.E. const Name::`vftable'
                char decorated[MAXSTR]; decorated[SIZESTR(decorated)] = 0;
                _snprintf(decorated, SIZESTR(decorated), FORMAT_RTTI_VFTABLE, SKIP_TD_TAG(colName));
                if (!set_name(vft, decorated, (SN_NON_AUTO | SN_NOWARN)))
                    serializeName(vft, decorated);
		    }

			// Set COL name. I.E. const Name::`RTTI Complete Object Locator'
            if (!hasUniqueName(col))
            {
                char decorated[MAXSTR]; decorated[SIZESTR(decorated)] = 0;
                _snprintf(decorated, SIZESTR(decorated), FORMAT_RTTI_COL, SKIP_TD_TAG(colName));
                if (!set_name(col, decorated, (SN_NON_AUTO | SN_NOWARN)))
                    serializeName(col, decorated);
            }

            success = TRUE;
	    }
	    // ======= Multiple inheritance, and, or, virtual inheritance hierarchies
        else
        {
            bcdInfo *bi = NULL;
            int index = 0;

            // Must be the top level object for the type
            if (offset == 0)
            {
                _ASSERT(strcmp(colName, list[0].m_name) == 0);
                bi = &list[0];
                isTopLevel = TRUE;
            }
            else
            {
				char plainName[MAXSTR];

				// Get our object BCD level by matching COL offset to displacement
                for (UINT i = 0; i < numBaseClasses; i++)
                {
                    if (list[i].m_pmd.mdisp == offset)
                    {
                        bi = &list[i];
                        index = i;
						baseClassIndex = index;
						getPlainTypeName(bi->m_name, plainName);
						break;
                    }
                }

                // If not found in list, use the first base object instead
                if (!bi)
                {
                    //msg("** " EAFORMAT " MI COL class offset: %X(%d) not in BCD.\n", vft, offset, offset);
                    for (UINT i = 0; i < numBaseClasses; i++)
                    {
                        if (list[i].m_pmd.pdisp != -1)
                        {
                            bi = &list[i];
                            index = i;
							baseClassIndex = index;
							getPlainTypeName(bi->m_name, plainName);
							break;
                        }
                    }
                }
			}

            if (bi)
            {
                // Top object level layout
                int placed = 0;
                if (isTopLevel)
                {
                    // Set the vft name
                    if (!hasUniqueName(vft))
                    {
                        char decorated[MAXSTR]; decorated[SIZESTR(decorated)] = 0;
                        _snprintf(decorated, SIZESTR(decorated), FORMAT_RTTI_VFTABLE, SKIP_TD_TAG(colName));
                        if (!set_name(vft, decorated, (SN_NON_AUTO | SN_NOWARN)))
                            serializeName(vft, decorated);
                    }

                    // COL name
                    if (!hasUniqueName(col))
                    {
                        char decorated[MAXSTR]; decorated[SIZESTR(decorated)] = 0;
                        _snprintf(decorated, SIZESTR(decorated), FORMAT_RTTI_COL, SKIP_TD_TAG(colName));
                        if (!set_name(col, decorated, (SN_NON_AUTO | SN_NOWARN)))
                            serializeName(col, decorated);
                    }
                }
                else
                {
                    // Combine COL and CHD name
                    char combinedName[MAXSTR]; combinedName[SIZESTR(combinedName)] = 0;
					_snprintf(combinedName, SIZESTR(combinedName), "%s6B%s@", SKIP_TD_TAG(colName), SKIP_TD_TAG(bi->m_name));
					_snprintf(prefixName, SIZESTR(prefixName), "%s::%s", SKIP_TD_TAG(colName), SKIP_TD_TAG(bi->m_name));

                    // Set vftable name
                    if (!hasUniqueName(vft))
                    {
                        char decorated[MAXSTR];
                        strncat(strcpy(decorated, FORMAT_RTTI_VFTABLE_PREFIX), combinedName, (MAXSTR - (1 + SIZESTR(FORMAT_RTTI_VFTABLE_PREFIX))));
                        if (!set_name(vft, decorated, (SN_NON_AUTO | SN_NOWARN)))
                            serializeName(vft, decorated);
                    }

                    // COL name
                    if (!hasUniqueName((ea_t) col))
                    {
                        char decorated[MAXSTR];
                        strncat(strcpy(decorated, FORMAT_RTTI_COL_PREFIX), combinedName, (MAXSTR - (1 + SIZESTR(FORMAT_RTTI_COL_PREFIX))));
                        if (!set_name((ea_t) col, decorated, (SN_NON_AUTO | SN_NOWARN)))
                            serializeName((ea_t)col, decorated);
                    }
                }
                if (placed > 1)
                    cmt += ';';
                success = TRUE;
            }
            else
                msg(EAFORMAT" ** Couldn't find a BCD for MI/VI hierarchy!\n", vft);
        }

        if (success)
        {
			//msg(" =" EAFORMAT " " EAFORMAT " ColName:'%s' DemangledName:'%s' PrefixName:'%s'\n", vft, col, colName, demangledColName, prefixName);
			classInfo ci;
			char tempName[MAXSTR];
			if (strlen(prefixName) > MAXSTR - 25)
			{
				::qsnprintf(tempName, (MAXSTR - 1), "__ICI__classTooLongRenamed_%d__", lastTooLong++);
				msgR("\t\t\tToo long: '%s'\t\t\t\treplaced by '%s'\n", prefixName, tempName);
				strcpy_s(prefixName, MAXSTR, tempName);
			}
			stripClassName(prefixName, tempName);
			strcpy_s(ci.m_className, (MAXSTR - 1), tempName);
			size_t i = 0;
			while (findClassInList(ci.m_className))
			{
				::qsnprintf(ci.m_className, (size_t)(MAXSTR - 1), "%s_%d", tempName, i);
				msgR("\t\t\tTrying className:'%s' for vft:"EAFORMAT"\n", ci.m_className, vft);
				i++;
			}
			CalcCTypeName(ci.m_cTypeName, ci.m_className);
			//msg(" =" EAFORMAT " " EAFORMAT " \tclassName:'%s' cTypeName:'%s'\n", vft, col, ci.m_className.c_str(), ci.m_cTypeName);
			strcpy_s(ci.m_colName, colName);
			strcpy_s(ci.m_templateInfo.m_templatename, "");
			ci.m_bcdlist = list;
			ci.m_vft = vft;
			ci.m_col = col;
			ci.m_start = vi.start;
			ci.m_end = vi.end;
			ci.m_numBaseClasses = realNumBaseClasses;
			ci.m_baseClassIndex = baseClassIndex;
			ci.m_templateInfo.m_template = strchr(ci.m_className, '<');
			ci.m_templateInfo.m_templateTypeCount = 0;
			ci.m_sizeFound = false;
			ci.m_size = 0;
			if (ci.m_templateInfo.m_template)
			{
				decodeTemplate(&(ci.m_templateInfo), ci.m_className);
			}
			//stripAnonymousNamespace(&ci);

			int s = classList.size();
			classList.resize(s + 1);
			classList[s] = ci;

			classKeyInfo aPK;
			ClassListPK(aPK.pk, ci);
			aPK.index = s;
			//msg("  ** Sorting class '%s' from %d\n", aPK.pk, s);
			refreshUI();
			bool found = false;
			for (ClassPKeys::iterator i = classPKeys.begin(); i != classPKeys.end(); i++)
			{
				int s = strcmp(aPK.pk, i->pk);
				if (0 >= s)
				{
					found = true;
					if (0 != s)
					{
						//msg("  ** Insert before " EAFORMAT " '%s' at %d\n", i, i->pk, i->index);
						classPKeys.insert(i, aPK);
					}
					else
					{
						msg("  ** This class %d already exists! '%s' at index %d. [as '%s' or '%s'] 3\n", aPK.index, aPK.pk, i->index, ci.m_className, ci.m_cTypeName);
						refreshUI();
					}
					break;
				}
			}
			if (!found)
				classPKeys.push_back(aPK);

			classInheritInfo cii;
			ClassListInherit(&cii.classes, ci);
			//msg("  ** Sorting class '%s' from %d\n", cii.classes.c_str(), s);
			cii.index = s;
			found = false;
			for (ClassInherit::iterator i = classInherit.begin(); i != classInherit.end(); i++)
			{
				int s = strcmp(cii.classes.c_str(), i->classes.c_str());
				if (0 >= s)
				{
					found = true;
					if (0 != s)
					{
						//msg("  ** Insert before '%s' at %d\n", i->classes.c_str(), i->index);
						classInherit.insert(i, cii);
					}
					else
					{
						// msg("  ** This class %d already exists! '%s' at index %d. 4\n", cii.index, ci.m_className, i->index);
						refreshUI();
					}
					break;
				}
			}
			if (!found)
				classInherit.push_back(cii);
		}
    }
    else
    {
        msg(EAFORMAT"\t\t\t ** No vftable attached to this COL, error?\n", vft);

        // Set COL name
        if (!hasUniqueName(col))
        {
            #ifndef __EA64__
            ea_t typeInfo = getEa(col + offsetof(_RTTICompleteObjectLocator, typeDescriptor));
            #endif
            char colName[MAXSTR]; colName[0] = colName[SIZESTR(colName)] = 0;
            type_info::getName(typeInfo, colName, SIZESTR(colName));

            char decorated[MAXSTR]; decorated[SIZESTR(decorated)] = 0;
            _snprintf(decorated, SIZESTR(decorated), FORMAT_RTTI_COL, SKIP_TD_TAG(colName));
            if (!set_name(col, decorated, (SN_NON_AUTO | SN_NOWARN)))
                serializeName(col, decorated);
        }
    }
}

RTTI::classInfo* RTTI::findClassInList(LPCSTR className)
{
	for (UINT i = 0; i < classList.size(); i++)
		if (0 == stricmp(classList[i].m_className, className))
			return &RTTI::classList[i];
	if (strchr(className, '_'))
		for (UINT i = 0; i < classList.size(); i++)
			if (0 == stricmp(classList[i].m_cTypeName, className))
				return &RTTI::classList[i];
	return NULL;
}

int RTTI::findIndexInList(LPCSTR className)
{
	for (UINT i = 0; i < classList.size(); i++)
		if (0 == stricmp(classList[i].m_className, className))
		{
			return i;
		}
	return -1;
}

RTTI::classInfo* RTTI::findColInList(ea_t col)
{
	for (UINT i = 0; i < classList.size(); i++)
		if (RTTI::classList[i].m_col == col)
			return &RTTI::classList[i];
	return NULL;
}

LPSTR RTTI::ClassListPK(LPSTR pk, RTTI::classInfo ci)
{
	if (pk)
		_snprintf(pk, MAXSTR - 1, "%01d%06d%s", ci.m_templateInfo.m_template ? 0 : 1, ci.m_numBaseClasses, ci.m_className);
	return pk;
}

int RTTI::findclassPKinList(LPCSTR pk)
{
	if (pk)
		for (UINT i = 0; i < classList.size(); i++)
		{
			char aPK[MAXSTR];
			ClassListPK(aPK, classList[i]);
			if (0 == stristr(pk, aPK))
				return i;
		}
	return -1;
}

void ClassListInheritParent(RTTI::LPClassesList classes, RTTI::classInfo ci)
{
	for (UINT i = 0; i < ci.m_parents.size() ; i++)
	{
		ClassListInheritParent(classes, RTTI::classList[ci.m_parents[i]]);
		classes->append("-");
	}
	classes->append(ci.m_className);
}

RTTI::LPClassesList RTTI::ClassListInherit(LPClassesList classes, RTTI::classInfo ci)
{
	char sz[MAXSTR];
	if (classes)
	{
		::qsnprintf(sz, MAXSTR - 2, "%04d", ci.m_bcdlist.size());
		classes->clear();
		classes->append(sz);
		ClassListInheritParent(classes, ci);
	}
	return classes;
}

int RTTI::findclassInheritInList(LPClassesList classes)
{
	if (classes)
		for (UINT i = 0; i < classList.size(); i++)
		{
			ClassesList cl;
			ClassListInherit(&cl, classList[i]);
			if (0 == stricmp(cl.c_str(), classes->c_str()))
				return i;
		}
	return -1;
}

#ifdef __EA64__
#define ntf_flags NTF_TYPE | NTF_64BIT
#define bitsPerInt 8
#else
#define ntf_flags NTF_TYPE
#define bitsPerInt 4
#endif

bool get_vftable_member(udt_member_t * um)
{
	if (!um) return false;

	const type_t *ptr;
	*um = udt_member_t();
	bool found = get_numbered_type(idati, sizeof(int), &ptr);
	if (found)
	{
		tinfo_t	tInt = tinfo_t(*ptr);
		um->size = sizeof(int) << bitsPerInt;
		um->name = "vftable";
		um->cmt = "pointer to virtual function table";
		um->type = tInt;
		msg("  ** \tcreating type for vftable ** \n");
	}
	return found;
}

bool get_parent_member(udt_member_t * um, uint64 offset, LPCSTR parentName)
{
	if (!um) return false;

	return false;

	const type_t *ptr;
	*um = udt_member_t();
	bool found = get_named_type(idati, parentName, ntf_flags, &ptr);
	if (found)
	{
		tinfo_t	tInt = tinfo_t(*ptr);
		um->offset = offset;
		um->size = tInt.get_size() << bitsPerInt;
		um->name = "vftable";
		um->cmt = "parent class";
		um->type = tInt;
		msg("  ** \tcreating type for parent class ** \n");
	}
	return found;
}

char outputBias[MAXSTR] = "";

UINT RTTI::getClassOffset(ea_t vft, ea_t col)
{
	return get_32bit(col + offsetof(_RTTICompleteObjectLocator, offset));
}

// Process RTTI vftable info part 2: Full hierarchy. All possible classes should be in classList.
void RTTI::processVftablePart2(ea_t vft, ea_t col)
{
	classInfo* ci = findColInList(col);
	if (!ci || ci->m_done) return;

#ifdef __EA64__
	UINT tdOffset = get_32bit(col + offsetof(_RTTICompleteObjectLocator, typeDescriptor));
	UINT objectLocator = get_32bit(col + offsetof(RTTI::_RTTICompleteObjectLocator, objectBase));
	ea_t colBase = (col - (UINT64)objectLocator);
	ea_t typeInfo = (colBase + (UINT64)tdOffset);
#endif

	strcat_s(outputBias, "  ");

	// Get vftable info
	vftable::vtinfo vi;
	if (vftable::getTableInfo(vft, vi, 0))
	{
		//msg(EAFORMAT" - " EAFORMAT " c: %d\n", vi.start, vi.end, vi.methodCount);

		// Get COL type name
#ifndef __EA64__
		ea_t typeInfo = getEa(col + offsetof(_RTTICompleteObjectLocator, typeDescriptor));
		ea_t chd = get_32bit(col + offsetof(_RTTICompleteObjectLocator, classDescriptor));
#else
		UINT cdOffset = get_32bit(col + offsetof(RTTI::_RTTICompleteObjectLocator, classDescriptor));
		ea_t chd = (colBase + (UINT64)cdOffset);
#endif

		char colName[MAXSTR]; colName[0] = colName[SIZESTR(colName)] = 0;
		type_info::getName(typeInfo, colName, SIZESTR(colName));
		char demangledColName[MAXSTR];
		getPlainTypeName(colName, demangledColName);
		char prefixName[MAXSTR];
		strcpy_s(prefixName, demangledColName);

		UINT chdAttributes = get_32bit(chd + offsetof(_RTTIClassHierarchyDescriptor, attributes));
		UINT offset = get_32bit(col + offsetof(_RTTICompleteObjectLocator, offset));

		// Parse BCD info
		bcdList list;
		UINT numBaseClasses;
		ci->m_done = true;
		//msgR("***** Done %s\n", ci->m_cTypeName);
		list = ci->m_bcdlist;
		numBaseClasses = ci->m_numBaseClasses;
		//UINT i = findIndexInList(ci->m_className);
		//ci->m_parents.push_back(i);
		//msgR(EAFORMAT" - " EAFORMAT " c: %5d %s %3d Entering class '%s'\n", vi.start, vi.end, vi.methodCount, outputBias, ci->m_numBaseClasses, ci->m_classname);

		int baseClassIndex = 0;
		UINT realNumBaseClasses = numBaseClasses;

		BOOL success = FALSE, isTopLevel = FALSE;
		qstring cmt;

		// ======= Simple or no inheritance
		if ((offset == 0) && ((chdAttributes & (CHD_MULTINH | CHD_VIRTINH)) == 0))
		{

			// Build object hierarchy string
			int placed = 0;
			if (numBaseClasses > 1)
			{
				// Parent
				char plainName[MAXSTR];
				getPlainTypeName(list[0].m_name, plainName);
				cmt.sprnt("%s%s: ", ((list[0].m_name[3] == 'V') ? "" : "struct "), plainName);
				placed++;
				isTopLevel = ((strcmp(list[0].m_name, colName) == 0) ? TRUE : FALSE);

				// Child object hierarchy
				for (UINT i = 1; i < numBaseClasses; i++)
				{
					// Append name
					getPlainTypeName(list[i].m_name, plainName);
					cmt.cat_sprnt("%s%s, ", ((list[i].m_name[3] == 'V') ? "" : "struct "), plainName);
					placed++;

					bool found = false;
					size_t parentSize = 0;
					for (UINT j = 0; j < classList.size(); j++)
						if (0 == stricmp(classList[j].m_className, plainName))
						{
							if (!RTTI::classList[j].m_done)
								processVftablePart2(RTTI::classList[j].m_vft, RTTI::classList[j].m_col);
							found = true;
							parentSize = ((RTTI::classList[j].m_end - RTTI::classList[j].m_start) / sizeof(ea_t));
							break;
						}
					if (!found)
					{
						//msgR(EAFORMAT" - " EAFORMAT " c: %5d %s Class '%s' not found for '%s' **\n", vi.start, vi.end, vi.methodCount, outputBias, plainName, ci->m_classname);
						AddNonRTTIclass(plainName);
					}
					//else
					//	msgR(EAFORMAT" - " EAFORMAT " c: %5d %s Class '%s'     found for '%s'\n", vi.start, vi.end, vi.methodCount, outputBias, plainName, ci->m_classname);
					
					// Make sure our vfTable is at least as big as our parent's
					vftable::getTableInfo(vft, vi, parentSize);

					if (i == 1)	// the direct parent is the only parent
					{
						int index = findIndexInList(plainName);
						if (index > -1 && ci->m_parents.size() == 0)
						{
							//msg("  ** Found NM class '%s' in list at index %d (%d) **\n", plainName, index, ci->m_parents.size());
							ci->m_parents.push_back(index);
							RTTI::classInfo * pci = &RTTI::classList[index];
							index = findIndexInList(ci->m_className);
							pci->m_childs.push_back(index);
						}
						//else
						//	msg("  ** Cannot find NM class '%s' in list **\n", plainName);
					}
				}

				// Nix the ending ',' for the last one
				if (placed > 1)
					cmt.remove((cmt.length() - 2), 2);
			}
			else
			{
				// Plain, no inheritance object(s)
				cmt.sprnt("%s%s: ", ((colName[3] == 'V') ? "" : "struct "), demangledColName);
				isTopLevel = TRUE;
				//msgR(EAFORMAT" - " EAFORMAT " c: %5d %s Class '%s' is base\n", vi.start, vi.end, vi.methodCount, outputBias, ci->m_classname);
			}
			if (placed > 1)
				cmt += ';';
			success = TRUE;
		}
		// ======= Multiple inheritance, and, or, virtual inheritance hierarchies
		else
		{
			bcdInfo *bi = NULL;
			int index = 0;

			// Must be the top level object for the type
			if (offset == 0)
			{
				_ASSERT(strcmp(colName, list[0].m_name) == 0);
				bi = &list[0];
				isTopLevel = TRUE;
				for (UINT k = 1; k < numBaseClasses; k++)
				{
					char plainName[MAXSTR];
					bool found = false;
					size_t parentSize = 0;
					getPlainTypeName(list[k].m_name, plainName);
					for (UINT i = 0; i < classList.size(); i++)
						if (0 == stricmp(classList[i].m_className, plainName))
						{
							if (!RTTI::classList[i].m_done)
								processVftablePart2(RTTI::classList[i].m_vft, RTTI::classList[i].m_col);
							realNumBaseClasses = index + classList[i].m_numBaseClasses;
							found = true;
							parentSize = ((RTTI::classList[i].m_end - RTTI::classList[i].m_start) / sizeof(ea_t));
							break;
						}
					if (!found)
					{
						//msgR(EAFORMAT" - " EAFORMAT " c: %5d %s Class '%s' not found for '%s'!!!\n", vi.start, vi.end, vi.methodCount, outputBias, plainName, ci->m_classname);
						AddNonRTTIclass(plainName);
					}
					//else
					//	msgR(EAFORMAT" - " EAFORMAT " c: %5d %s Class '%s'     found for '%s'\n", vi.start, vi.end, vi.methodCount, outputBias, plainName, ci->m_classname);

					// Make sure our vfTable is at least as big as our parent's
					vftable::getTableInfo(vft, vi, parentSize);
				}
			}
			else
			{
				char plainName[MAXSTR];

				// Get our object BCD level by matching COL offset to displacement
				for (UINT i = 0; i < numBaseClasses; i++)
				{
					if (list[i].m_pmd.mdisp == offset)
					{
						bi = &list[i];
						index = i;
						baseClassIndex = index;
						getPlainTypeName(bi->m_name, plainName);
						break;
					}
				}

				// If not found in list, use the first base object instead
				if (!bi)
				{
					//msg("** " EAFORMAT " MI COL class offset: %X(%d) not in BCD.\n", vft, offset, offset);
					for (UINT i = 0; i < numBaseClasses; i++)
					{
						if (list[i].m_pmd.pdisp != -1)
						{
							bi = &list[i];
							index = i;
							baseClassIndex = index;
							getPlainTypeName(bi->m_name, plainName);
							break;
						}
					}
				}
				bool found = false;
				size_t parentSize = 0;
				if (bi)
					for (UINT i = 0; i < classList.size(); i++)
						if (0 == stricmp(classList[i].m_className, plainName))
						{
							if (!RTTI::classList[i].m_done)
								processVftablePart2(RTTI::classList[i].m_vft, RTTI::classList[i].m_col);
							realNumBaseClasses = index + classList[i].m_numBaseClasses;
							found = true;
							parentSize = ((RTTI::classList[i].m_end - RTTI::classList[i].m_start) / sizeof(ea_t));
							break;
						}
				if (!found)
				{
					//msgR(EAFORMAT" - " EAFORMAT " c: %5d %s Class '%s' not found for '%s'!!!\n", vi.start, vi.end, vi.methodCount, outputBias, plainName, ci->m_classname);
					AddNonRTTIclass(plainName);
				}
				//else
				//	msgR(EAFORMAT" - " EAFORMAT " c: %5d %s Class '%s'     found for '%s'\n", vi.start, vi.end, vi.methodCount, outputBias, plainName, ci->m_classname);

				// Make sure our vfTable is at least as big as our parent's
				vftable::getTableInfo(vft, vi, parentSize);
			}
			//msg(" ** continuing Class '%s' bi:%08X {%1d} %d / %d \n", ci->m_classname, bi, isTopLevel, numBaseClasses, realNumBaseClasses);

			if (bi)
			{
				bool needParents = ci->m_parents.size() == 0;
				// Top object level layout
				int placed = 0;
				if (isTopLevel)
				{
					// Build hierarchy string starting with parent
					char plainName[MAXSTR];
					getPlainTypeName(list[0].m_name, plainName);
					cmt.sprnt("%s%s: ", ((list[0].m_name[3] == 'V') ? "" : "struct "), plainName);
					placed++;

					UINT next = 1;
					// Concatenate forward child hierarchy
					for (UINT i = 1; i < numBaseClasses; i++)
					{
						getPlainTypeName(list[i].m_name, plainName);
						cmt.cat_sprnt("%s%s, ", ((list[i].m_name[3] == 'V') ? "" : "struct "), plainName);
						placed++;
						if (needParents && i == next)
						{
							int index = findIndexInList(plainName);
							if (index > -1)
							{
								//msg("  ** Found TL class '%s' in list at index %d (%d) **\n", plainName, index, ci->m_parents.size());
								ci->m_parents.push_back(index);
								next = i + classList[index].m_numBaseClasses;
							}
							//else
							//	msg("  ** Cannot find TL class '%s' in list **\n", plainName);
						}
					}
					if (placed > 1)
						cmt.remove((cmt.length() - 2), 2);
				}
				else
				{
					// Combine COL and CHD name
					char combinedName[MAXSTR]; combinedName[SIZESTR(combinedName)] = 0;
					_snprintf(combinedName, SIZESTR(combinedName), "%s6B%s@", SKIP_TD_TAG(colName), SKIP_TD_TAG(bi->m_name));
					_snprintf(prefixName, SIZESTR(prefixName), "%s::%s", SKIP_TD_TAG(colName), SKIP_TD_TAG(bi->m_name));

					// Build hierarchy string starting with parent
					char plainName[MAXSTR];
					getPlainTypeName(bi->m_name, plainName);
					cmt.sprnt("%s%s: ", ((bi->m_name[3] == 'V') ? "" : "struct "), plainName);
					placed++;

					// Concatenate forward child hierarchy
					if (++index < (int)realNumBaseClasses)
					{
						for (; index < (int)realNumBaseClasses; index++)
						{
							getPlainTypeName(list[index].m_name, plainName);
							cmt.cat_sprnt("%s%s, ", ((list[index].m_name[3] == 'V') ? "" : "struct "), plainName);
							placed++;
						}
						if (placed > 1)
							cmt.remove((cmt.length() - 2), 2);
					}

					/*
					Experiment, maybe better this way to show before and after to show it's location in the hierarchy
						// Concatenate reverse child hierarchy
						if (--index >= 0)
						{
						for (; index >= 0; index--)
						{
						getPlainTypeName(list[index].m_name, plainName);
						cmt.cat_sprnt("%s%s, ", ((list[index].m_name[3] == 'V') ? "" : "struct "), plainName);
						placed++;
						}
						if (placed > 1)
						cmt.remove((cmt.length() - 2), 2);
						}
					*/
				}
				if (placed > 1)
					cmt += ';';
				success = TRUE;
			}
			else
				msg(EAFORMAT" ** Couldn't find a BCD for MI/VI hierarchy!\n", vft);
		}

		if (success)
		{
			// Store entry
			addTableEntry(((chdAttributes & 0xF) | ((isTopLevel == TRUE) ? RTTI::IS_TOP_LEVEL : 0)), vft, vi.methodCount, "%s@%s", demangledColName, cmt.c_str());

			//cmt.cat_sprnt("  %s O: %d, A: %d  (#classinformer)", attributeLabel(chdAttributes, numBaseClasses), offset, chdAttributes);
			cmt.cat_sprnt("  %s (#classinformer)", attributeLabel(chdAttributes));

			// Add a separating comment above RTTI COL
			ea_t cmtPtr = (vft - sizeof(ea_t));
			if (optionOverwriteComments)
			{
				killAnteriorComments(cmtPtr);
				describe(cmtPtr, true, "\n; %s %s", ((colName[3] == 'V') ? "class" : "struct"), cmt.c_str());
			}
			else
				if (!hasAnteriorComment(cmtPtr))
					describe(cmtPtr, true, "\n; %s %s", ((colName[3] == 'V') ? "class" : "struct"), cmt.c_str()); // add_long_cmt

			const type_t *ptr;
			int found = get_named_type(idati, "__ICI__VFUNC__", ntf_flags, &ptr);
			if (!found)
			{
				char cLine[MAXSTR];
				strcpy_s(cLine, MAXSTR - 1, "typedef /*virtual*/ int __thiscall (*__ICI__VFUNC__)(void*);");
				int c = h2ti(idati, NULL, cLine);
			}
			found = get_named_type(idati, "__ICI__VTABLE__", ntf_flags, &ptr);
			if (!found)
			{
				char cLine[MAXSTR];
				strcpy_s(cLine, MAXSTR - 1, "typedef __ICI__VFUNC__ __ICI__VTABLE__[1];");
				int c = h2ti(idati, NULL, cLine);
			}
			found = get_named_type(idati, "__ICI__LPVTABLE__", ntf_flags, &ptr);
			if (!found)
			{
				char cLine[MAXSTR];
				strcpy_s(cLine, MAXSTR - 1, "typedef __ICI__VTABLE__ *__ICI__LPVTABLE__;");
				int c = h2ti(idati, NULL, cLine);
			}
			addClassDefinitionsToIda(*ci);

			/*
			found = get_named_type(idati, ci->m_classname, ntf_flags, &ptr);
			if (!found)
			{
#define HUGESTR 32768
				char cLine[HUGESTR];
				//::qsnprintf(cLine, HUGESTR - 1, "struct %s { __ICI__LPVTABLE__ vftable; };", ci->m_classname, ci->m_classname, ci->m_classname);
				::qsnprintf(cLine, HUGESTR - 1, "struct %s%c{%cint vftable;%c};", ci->m_classname, 10, 10, 10, 10);
				int c = h2ti(idati, NULL, cLine , HTI_CPP | HTI_PAK1 | HTI_HIGH, NULL, NULL, &msg, NULL, abs_no);
				msg("  ** [%6d] Created type Name:'%s' ** \n", c, cLine);
				::qsnprintf(cLine, HUGESTR - 1, "struct { int vftable; };");
				c = h2ti(idati, NULL, cLine, HTI_CPP | HTI_PAK1 | HTI_HIGH, NULL, NULL, &msg, NULL, abs_no);
				msg("  ** [%6d] Created type Name:'%s' ** \n", c, cLine);
			}
*/
/*
				classInfo aCi = *ci;
				size_t	fullSize = 0;
				qvector<tinfo_t> typeList;
				udt_type_data_t ud = udt_type_data_t();
				ud.effalign = 1;

				for (UINT i = 0; i < aCi.m_parents.size(); i++)
				{
					classInfo c = classList[aCi.m_parents[i]];
					int found = get_named_type(idati, c.m_classname, ntf_flags, &ptr);
					if (found)
					{
						tinfo_t	t = tinfo_t(*ptr);
						if (size_t s = t.get_size())
						{
							fullSize = ud.total_size;
							udt_member_t um = udt_member_t();
							if (get_parent_member(&um, fullSize, c.m_classname))
							{
								ud.push_back(um);
								align_size(fullSize, um.size, ud.sda);
								ud.total_size = fullSize;
							}
						}
					}
					msg("  ** Creating type Name:'%s' ** \n", aCi.m_classname);
					tinfo_t	t = tinfo_t();
					msg("  ** \tCreated type Name:'%s' ** \n", aCi.m_classname);

					fullSize = (ud.total_size);
					if (!fullSize)
					{	// first member, is the vftable
						udt_member_t um = udt_member_t();
						if (get_vftable_member(&um))
						{
							ud.push_back(um);
							align_size(fullSize, sizeof(int) << bitsPerInt, ud.effalign);
							ud.total_size = fullSize;
						}
					}

					bool created = t.create_udt(ud, BTF_STRUCT);
					msg("  ** \tPopulated type Name:'%s' ** \n", aCi.m_classname);
					if (created && t.is_struct())
					{
							
						msg("  ** \tCreated struct Name:'%s' ** \n", aCi.m_classname);
						size_t s = t.get_size();
						if (s < 0xFFFFFFFF)
						{
							msg("  ** \tCreated struct Name:'%s' for %X bytes ** \n", aCi.m_classname, s);
							tinfo_code_t tic = t.set_named_type(idati, aCi.m_classname, 0);
							if (tic == 0)
							{
								int found = get_named_type(idati, aCi.m_classname, ntf_flags, &ptr);
								if (found)
									msg("  ** \tCreated struct named Name:'%s' ** \n", aCi.m_classname);
								udt_type_data_t ud;
								if (t.get_udt_details(&ud))
								{
									msg("  ** \tName:'%s' %d ** \n", "", ud.size());
									for (UINT i = 0; i < ud.size(); i++)
									{
										udt_member_t um = ud[i];
										msg("  ** \t\t%6d: %08X Name:'%s' %08X ** \n", i, um.offset, um.name, um.type);
									}
								}
							}
							else
								msg("  ** \tCreated non named struct Name:'%s' [%04d] ** \n", aCi.m_classname, tic);
						}
					}
					else
						msg("  ** \tCreated non struct Name:'%s' ** \n", aCi.m_classname);
				}
*/
			//msgR(EAFORMAT" - " EAFORMAT " c: %5d %s Leaving  class '%s'\n", vi.start, vi.end, vi.methodCount, outputBias, ci->m_classname);
		}
		//if (ci)
		//	for (UINT i = 0; i < ci->m_parents.size(); i++)
		//		msg("  " EAFORMAT " col:" EAFORMAT " ** '%s' %d: %d \"%s\" **\n", vft, col, ci->m_classname, i, ci->m_parents[i], classList[ci->m_parents[i]].m_classname);
		//refreshUI();
	}
	outputBias[strlen(outputBias)-2] = 0;
}

THREAD_SAFE AS_PRINTF(1, 2) inline int msgR(const char *format, ...)
{
	va_list va;
	va_start(va, format);
	int nbytes = vmsg(format, va);
	va_end(va);
	refreshUI();
	return nbytes;
}

UINT RTTI::countTemplateType(LPCSTR templateName)
{
	//msgR(" ** countTemplateType: '%s'\n", templateName);
	UINT count = 1;
	UINT level = 0;
	UINT chars = 0;
	char szT[MAXSTR] = "";
	LPCSTR sz = templateName;

	while (sz && *sz)
	{
		//msgR(" ** countTemplateType: '%s' %d\\%d\n", sz, count, level);
		switch(*sz)
		{
			case '<': level++; break;
			case '>': if ( level) { level--; break; }
			case ',': if (!level) { count++; break; }
		}
		sz++;
		chars++;
		if (chars > 250) return 25;
	}
	return count;
}

void RTTI::readTemplateType(templateTypeList tt, LPCSTR templateName)
{
	//msgR(" ** readTemplateType: '%s' %d\n", templateName, list.size());
	UINT count = 1;
	UINT level = 0;
	UINT chars = 0;
	LPCSTR sz = templateName;
	LPCSTR szType = sz;

	while (sz && *sz)
	{
		//msgR(" ** readTemplateType: '%s' of '%s' %d at %d\n", sz, szType, count, level);
		switch (*sz)
		{
			case '<': level++; break;
			case '>': if (level) { level--; break; }
			case ',': if (!level) {
				//msgR(" ** %d: readTemplateType: '%s' of '%s' %d Len: %d \n", count, sz, szType, level, sz - szType);
				strncpy_s(tt[count - 1].m_name, MAXSTR - 1, szType, sz - szType);
				sz++;
				szType = sz++;
				count++; 
				break;
			}
		}
		sz++;
		chars++;
		if (chars > 1020) break;
	}
	//msgR(" ** %d: readTemplateType: '%s' of '%s' %d Len: %d \n", count, sz, szType, level, sz - szType);
	strcpy_s(tt[count - 1].m_name, MAXSTR - 1, szType);
}

LPSTR RTTI::defTemplate(LPSTR templateDef, UINT count)
{
	//msgR(" ** defTemplate: '%s' for %d\n", templateDef, count);
	char sz[MAXSTR] = "";
	strcpy_s(templateDef, (MAXSTR - 1), "template<");
	//msgR(" ** defTemplate: '%s' for %d\n", templateDef, count);
	for (UINT i = 0; i < count; i++)
	{
		//msgR(" ** defTemplate: '%s' for %d of %d\n", templateDef, i, count);
		_itoa_s(i, sz, 10);
		//msgR(" ** defTemplate: '%s' for %s of %d\n", templateDef, sz, count);
		strcat_s(templateDef, (MAXSTR - 1), " typename _T");
		strcat_s(templateDef, (MAXSTR - 1), sz);
		strcat_s(templateDef, (MAXSTR - 1), ",");
	}
	//msgR(" ** defTemplate: '%s' for %d\n", templateDef, count);
	if (templateDef)
		templateDef[strlen(templateDef)-1] = '>';
	//msgR(" ** defTemplate: '%s' for %d\n", templateDef, count);
	return templateDef;
}

bool RTTI::decodeTemplate(LPSTR decodedTemplate, LPSTR templateName, LPCSTR baseTemplate)
{
	//msgR(" ** decodeTemplate: '%s' into '%s' (and '%s') \n", baseTemplate, decodedTemplate, templateName);
	bool result = false;
	char encodedTemplate[MAXSTR] = "";
	strcpy_s(encodedTemplate, baseTemplate);
	strcpy_s(decodedTemplate, MAXSTR, " ");
	if (LPSTR szStartTemplateTypes = strchr(encodedTemplate, '<'))
	{
		//msgR(" ** decodeTemplate: '%s' start '%s'\n", encodedTemplate, szStartTemplateTypes);
		*szStartTemplateTypes = 0;
		szStartTemplateTypes++;
		if (LPSTR szEndTemplateTypes = strrchr(szStartTemplateTypes, '>'))
		{
			//msgR(" ** decodeTemplate: '%s' end '%s'\n", encodedTemplate, szEndTemplateTypes);
			*szEndTemplateTypes = 0;
			UINT iTemplateTypesCount = countTemplateType(szStartTemplateTypes);
			//msgR(" ** decodeTemplate: '%s' count %d\n", encodedTemplate, iTemplateTypesCount);
			defTemplate(decodedTemplate, iTemplateTypesCount);
			//msgR(" ** decodeTemplate: '%s' is '%s'\n", encodedTemplate, decodedTemplate);
		}
		result = true;
	}
	else
		strcpy_s(decodedTemplate, MAXSTR - 1, baseTemplate);
	if (templateName)
		strcpy_s(templateName, MAXSTR - 1, encodedTemplate);
	//msgR(" ** decodeTemplate: [%d] '%s' into '%s' (and '%s') \n", result, baseTemplate, decodedTemplate, templateName);
	return result;
}

bool RTTI::decodeTemplate(RTTI::templateInfo* ti, LPCSTR baseTemplate)
{
	//msgR(" ** decodeTemplate: '%s' into '%s' (and '%s') \n", baseTemplate, decodedTemplate, templateName);
	bool result = false;
	char encodedTemplate[MAXSTR] = "";
	strcpy_s(encodedTemplate, baseTemplate);
	if (LPSTR szStartTemplateTypes = strchr(encodedTemplate, '<'))
	{
		//msgR(" ** decodeTemplate: '%s' start '%s'\n", encodedTemplate, szStartTemplateTypes);
		*szStartTemplateTypes = 0;
		szStartTemplateTypes++;
		if (LPSTR szEndTemplateTypes = strrchr(szStartTemplateTypes, '>'))
		{
			//msgR(" ** decodeTemplate: '%s' end '%s'\n", encodedTemplate, szEndTemplateTypes);
			*szEndTemplateTypes = 0;
			UINT iTemplateTypesCount = countTemplateType(szStartTemplateTypes);
			//for (UINT i = iTemplateTypesCount; i > 0; i--)
			//{
			//	templateType tt;
			//	tt.m_index = i-1;
			//	tt.m_instance = 0;
			//	strcpy_s(tt.m_name, "");
			//	ti->m_templateList.push_back(tt);
			//}
			////msgR(" ** decodeTemplate: '%s' count %d\n", encodedTemplate, iTemplateTypesCount);
			//readTemplateType(ti->m_templateList, szStartTemplateTypes);
			////msgR(" ** decodeTemplate: '%s' is '%s'\n", encodedTemplate, decodedTemplate);
			////for (UINT i = 0; i < iTemplateTypesCount; i++)
			////{
			////	msgR("  ** %d: '%s'\n", i, ti->m_templateList[i]);
			////}
		}
		strcpy_s(ti->m_templatename, MAXSTR - 1, encodedTemplate);
		result = true;
	}
	//else
	//	strcpy_s(decodedTemplate, MAXSTR - 1, baseTemplate);
	//msgR(" ** decodeTemplate: [%d] '%s' into '%s' \n", result, baseTemplate, ti->m_templatename);
	return result;
}

void RTTI::replaceTypeName(LPSTR plainName, RTTI::templateInfo ti, UINT k)
{
	// nothing, TBD
}

bool RTTI::checkForAllocationPattern(ea_t eaCall, size_t *amount)
{

#define patternCount 9
	BYTE pattern0[] = {
		0x6A, 0,
		0xE8, 0, 0, 0, 0,
		0x83, 0xC4, 0x04,
		0x89, 0, 0, 0, 0, 0,
		0xC6, 0x45, 0, 0,
		0x83, 0xBD, 0, 0, 0, 0, 0,
		0x74, 0,
		0x8B, 0x8D, 0, 0, 0, 0,
	};
	BYTE pattern1[] = {
		0x68, 0, 0, 0, 0,
		0xE8, 0, 0, 0, 0,
		0x83, 0xC4, 0x04,
		0x89, 0, 0, 0, 0, 0,
		0xC6, 0x45, 0, 0,
		0x83, 0xBD, 0, 0, 0, 0, 0,
		0x74, 0,
		0x8B, 0x8D, 0, 0, 0, 0,
	};
	BYTE pattern2[] = {
		0xB9, 0, 0, 0, 0,
		0xE8, 0, 0, 0, 0,
		0x48, 0x89, 0, 0, 0, 0, 0, 0,
		0x48, 0x83, 0xBC, 0, 0, 0, 0, 0, 0,
		0x74, 0,
		0x48, 0x8B, 0x8C, 0, 0, 0, 0, 0,
	};
	BYTE pattern3[] = {
		0x6A, 0,
		0xE8, 0, 0, 0, 0,
		0x83, 0xC4, 0x04,
		0x89, 0, 0,
		0xC7, 0x45, 0, 0, 0, 0, 0,
		0x83, 0x7D, 0, 0,
		0x74, 0,
		0x8B, 0x4D, 0,
	};
	BYTE pattern4[] = {
		0xBA, 0, 0, 0, 0,
		0xE8, 0, 0, 0, 0,
		0x48, 0x85, 0xC0,
		0x74, 0,
		0x48, 0x8B, 0xC8,
		0x48, 0x83, 0xC4, 0,
	};
	BYTE pattern5[] = {
		0x41, 0x8D, 0x51, 0,
		0xE8, 0, 0, 0, 0,
		0x48, 0x85, 0xC0,
		0x74, 0,
		0x48, 0x8B, 0xC8,
	};
	BYTE pattern6[] = {
		0xBA, 0, 0, 0, 0,
		0x41, 0xB8, 0, 0, 0, 0,
		0xE8, 0, 0, 0, 0,
		0x33, 0,
		0x48, 0x85, 0xC0,
		0x74, 0,
		0x48, 0x8B, 0xC8,
	};
	BYTE pattern7[] = {
		0xB9, 0, 0, 0, 0,
		0x48, 0, 0, 0,
		0x75, 0x0,
		0xE8, 0, 0, 0, 0,
		0x48, 0x85, 0xC0,
		0x0F, 0x84, 0, 0, 0, 0,
		0x48, 0x8B, 0xC8,
	};
	BYTE pattern8[] = {
		0xB9, 0, 0, 0, 0,
		0x48, 0, 0, 0,
		0x75, 0x0,
		0xE8, 0, 0, 0, 0,
		0x48, 0x85, 0xC0,
		0x74, 0,
		0xB2, 0,
		0x48, 0x8B, 0xC8,
	};

	size_t patternSizes[] = { sizeof(pattern0), sizeof(pattern1), sizeof(pattern2), sizeof(pattern3), sizeof(pattern4), sizeof(pattern5), sizeof(pattern6), 
		sizeof(pattern7), sizeof(pattern8), };

	bool result = true;
	UINT indexPattern = (UINT)-1;
	ea_t basePattern;
	for (UINT j = 0; j < patternCount; j++)
	{
		result = true;
		size_t patternSize = patternSizes[j];
		basePattern = eaCall - patternSize;
		indexPattern = j;
		for (UINT i = 0; i < patternSize; i++)
		{
			BYTE c;
			switch (indexPattern)
			{
			case 0: c = pattern0[i]; break;
			case 1: c = pattern1[i]; break;
			case 2: c = pattern2[i]; break;
			case 3: c = pattern3[i]; break;
			case 4: c = pattern4[i]; break;
			case 5: c = pattern5[i]; break;
			case 6: c = pattern6[i]; break;
			case 7: c = pattern7[i]; break;
			case 8: c = pattern8[i]; break;
			default:
				msgR("  **  " EAFORMAT " j=%d is greater than max=%d\n", basePattern, j, patternCount, i, patternSize);
			}
			//msgR("  **  " EAFORMAT " " EAFORMAT " j=%d of %d, i=%d of %d : compare %X to %X\n", eaCall, basePattern, j, patternCount, i, patternSize, c, get_byte(basePattern + i));
			if (c && (c != get_byte(basePattern + i)))
			{
				result = false;
				break;
			}
		}
		if (result)
			break;
	}
	if (result)
		switch (indexPattern)
	{
		case 0:
		case 3:
			*amount = get_byte(basePattern + 1);
			break;
		case 5:
			*amount = get_byte(basePattern + 3);
			break;
		case 1:
		case 2:
		case 4:
		case 6:
		case 7:
		case 8:
			*amount = get_long(basePattern + 1);
			break;
	}
	//msgR("\n");

	return result;
#undef patternCount
}

bool RTTI::checkForInlineAllocationPattern(ea_t eaCall, size_t *amount)
{

#define patternCount 2
	BYTE pattern0[] = {
		0x6A, 0,
		0xFF, 0xD7,
		0x83, 0xC4, 0x04,
		0x3B, 0xC3,
		0x74, 0,
	};
	BYTE pattern1[] = {
		0x68, 0, 0, 0, 0,
		0xFF, 0xD7,
		0x83, 0xC4, 0x04,
		0x3B, 0xC3,
		0x74, 0,
	};
	// inline x64 detection seems improbable :(

	size_t patternSizes[] = { sizeof(pattern0), sizeof(pattern1), };

	bool result = true;
	UINT indexPattern = (UINT)-1;
	ea_t basePattern;
	for (UINT j = 0; j < patternCount; j++)
	{
		result = true;
		size_t patternSize = patternSizes[j];
		basePattern = eaCall - patternSize;
		indexPattern = j;
		for (UINT i = 0; i < patternSize; i++)
		{
			BYTE c;
			switch (indexPattern)
			{
			case 0: c = pattern0[i]; break;
			case 1: c = pattern1[i]; break;
			default:
				msgR("  **  " EAFORMAT " j=%d is greater than max=%d\n", basePattern, j, patternCount, i, patternSize);
			}
			//msgR("  **  " EAFORMAT " " EAFORMAT " j=%d of %d, i=%d of %d : compare %X to %X\n", eaCall, basePattern, j, patternCount, i, patternSize, c, get_byte(basePattern + i));
			if (c && (c != get_byte(basePattern + i)))
			{
				result = false;
				break;
			}
		}
		if (result)
			break;
	}
	if (result)
		switch (indexPattern)
	{
		case 0:
			*amount = get_byte(basePattern + 1);
			break;
		case 1:
			*amount = get_long(basePattern + 1);
			break;
	}
	//msgR("\n");

	return result;
#undef patternCount
}

void RTTI::recordSize(classInfo aCI, size_t amount, int classIndex)
{
	aCI.m_sizeFound = true;
	aCI.m_size = amount;
	RTTI::classList[classIndex] = aCI;
}

void RTTI::makeConstructor(func_t* funcFrom, LPCSTR className, classInfo aCI, size_t amount, int classIndex)
{
	flags_t funcFlags = getFlags(funcFrom->startEA);
	if (0 == funcFrom->argsize)	// "void" constructor
	{
		if (!has_name(funcFlags) || has_dummy_name(funcFlags))
		{
			char constructorName[MAXSTR] = "";
			::qsnprintf(constructorName, MAXSTR - 1, "%s::%s", className, className);
			char constructorFunc[MAXSTR] = "";
			::qsnprintf(constructorFunc, MAXSTR - 1, "void __thiscall %s__%s(%s *this);", className, className, className);
			//msgR("  ** '%s'\n", constructorName);
			if (!set_name(funcFrom->startEA, constructorName, (SN_NON_AUTO | SN_NOWARN)))
				serializeName(funcFrom->startEA, constructorName);
			//msgR("  ** as '%s'\n", constructorFunc);
			apply_cdecl2(idati, funcFrom->startEA, constructorFunc);
		}
	}
	// others? to be done
}

void RTTI::recordConstructor(ea_t eaAddress, LPCSTR className, classInfo aCI, size_t amount, int classIndex)
{
	flags_t inlFlags = getFlags(eaAddress);
	if (!has_cmt(inlFlags))
	{
		char constructorFunc[MAXSTR] = "";
		::qsnprintf(constructorFunc, MAXSTR - 1, "void __thiscall %s__%s(%s *this);", className, className, className);
		set_cmt(eaAddress, constructorFunc, false);
		//msgR("  " EAFORMAT "  ** inline constructor as '%s'\n", eaAddress, constructorFunc);
	}
}


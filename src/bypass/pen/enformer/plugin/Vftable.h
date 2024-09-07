
// ****************************************************************************
// File: Vftable.h
// Desc: Virtual function table parsing support
//
// ****************************************************************************
#pragma once

namespace vftable
{
	// vftable info container
	struct vtinfo
	{
		ea_t start, end;
		int  methodCount;
		//char name[MAXSTR];
	};

	BOOL getTableInfo(ea_t ea, vtinfo &info, size_t parentSize);

	// Returns TRUE if mangled name indicates a vftable
	inline BOOL isValid(LPCSTR name){ return(*((PDWORD) name) == 0x375F3F3F /*"??_7"*/); }

	typedef stdext::hash_map<ea_t, bool> VFGuessedFunc;
	extern VFGuessedFunc vfGuessedFunc;

	extern const char *defaultMemberFormat;			// = "Func%04X";					//	default: index
	extern const char *defaultNameFormat;			// = "%s::%s";						//	default: className defaultName
	extern const char *defaultTypeNameFormat32;		// = "%s%s __thiscall %s(%s%s%s)";	//	default: int , " ", fullName, paramName
	extern const char *defaultTypeNameFormat64;		// = "%s%s __fastcall %s(%s%s%s)";	//	default: int , " ", fullName, paramName
	extern const char *defaultCommentNameFormat;	// = " (#Func %04X) %s::%s";		//	default: index, className, memberName

	struct EntryInfo;
	typedef qvector<EntryInfo> VFMemberList;
	struct EntryInfo
	{
		#ifdef __EA64__
		#define defaultTypeNameFormat defaultTypeNameFormat64
		#else
		#define defaultTypeNameFormat defaultTypeNameFormat32
		#endif
	public:
		ea_t	vft;			// owner vfTable
		ea_t	parentVft;		// parent class vfTable (or BADADDR)
		ea_t	entry;			// vft + index * sizeof(ea_t)
		ea_t	member;			// actual function offset (after all jumps)
		ea_t	jump;			// first jump or BADADDR
		UINT	index;			// index in vfTable
		flags_t	memberFlags;	// flags associated with member
		flags_t	entryFlags;		// flags associated with entry
		flags_t	jumpFlags;		// flags associated with jump
		qstring	className;		// class name
		qstring defaultName;	// default member name
		qstring	memberName;		// portion of the name following the last :: (Func%04X by default)
		qstring	fullName;		// current name of member
		qstring	comment;		// current comment of entry (should be duplicated as comment of jump and comment of member)
		qstring	jumpComment;	// current comment of jump (if differs from comment)
		qstring	returnName;		// return type declaration (int by default)
		qstring	paramName;		// string of parameters (ClassName* this by default)
		qstring	typeName;		// c like function declaration of member
		qstring	jumpTypeName;	// c like function declaration of jump (if differs from member)
		bool	isDefault;
		bool	isInherited;
		bool	isIdentical;
		bool	isMember;
		bool	isOutOfHierarchy;
		VFMemberList* parentList;
		EntryInfo() : vft(BADADDR), parentVft(BADADDR), entry(BADADDR), member(BADADDR), jump(BADADDR), index(UINT(-1)),
			memberFlags(0), entryFlags(0), jumpFlags(0),
			className(), memberName(), returnName(), paramName(), fullName(), comment(), jumpComment(), typeName(), jumpTypeName(),
			isDefault(false), isInherited(false), isIdentical(false), isMember(false), isOutOfHierarchy(false), parentList(NULL) {};
		EntryInfo(UINT iIndex, ea_t eaVft, ea_t eaParentVft, LPCSTR szClassName, VFMemberList* aParentList);
		EntryInfo(const EntryInfo& parentInfo) : 
			vft(parentInfo.vft), parentVft(parentInfo.parentVft), entry(parentInfo.entry), member(parentInfo.member), jump(parentInfo.jump),
			index(parentInfo.index), memberFlags(parentInfo.memberFlags), entryFlags(parentInfo.entryFlags), jumpFlags(parentInfo.jumpFlags),
			className(parentInfo.className), defaultName(parentInfo.defaultName), memberName(parentInfo.memberName), returnName(parentInfo.returnName),
			paramName(parentInfo.paramName), fullName(parentInfo.fullName), comment(parentInfo.comment), jumpComment(parentInfo.jumpComment),
			typeName(parentInfo.typeName), jumpTypeName(parentInfo.jumpTypeName),
			isDefault(parentInfo.isDefault), isInherited(parentInfo.isInherited), isIdentical(parentInfo.isIdentical), isMember(parentInfo.isMember),
			isOutOfHierarchy(parentInfo.isOutOfHierarchy), parentList(NULL) {};
		EntryInfo(const EntryInfo& parentInfo, qstring ClassName, ea_t VFT) : EntryInfo(parentInfo)
		{
			className = ClassName;
			parentVft = vft;
			vft = VFT;
			entry = vft + index * sizeof(ea_t);
		};
		void	process(UINT iIndex, LPCSTR szClassName, bool propagate = false);
		bool	IsDefault()			{ return isDefault; };
		bool	IsInherited()		{ return isInherited; };
		bool	IsIdentical()		{ return isIdentical; };
		bool	IsMember()			{ return isMember; };
		bool	IsOutOfHierarchy()	{ return isOutOfHierarchy; };
		bool	IsJump()			{ return (BADADDR != jump); };
		void	MakeDefaultName(qstring& aDefaultName)
		{
			aDefaultName.sprnt(defaultMemberFormat, index);
		}
		void	MakeFullName(qstring& aFullName)
		{
			aFullName.sprnt(defaultNameFormat, className.c_str(), memberName.c_str());
		}
		void	MakeNewFullName(qstring& aFullName, qstring& newMemberName)
		{
			aFullName.sprnt(defaultNameFormat, className.c_str(), newMemberName.c_str());
		}
		void	MakeDefaultFullName(qstring& aFullName)
		{
			aFullName.sprnt(defaultNameFormat, className.c_str(), defaultName.c_str());
		}
		void	MakeTypeName(qstring& aTypeName)
		{
			aTypeName.sprnt(defaultTypeNameFormat, returnName.length() ? returnName.c_str() : "", returnName.length() ? " " : "",
				fullName.c_str(), paramName.length() ? paramName.c_str() : "void");
		}
		void	MakeDefaultComment(qstring& aComment)
		{
			aComment.sprnt(defaultCommentNameFormat, index, className.c_str(), defaultName.c_str());
		}
		void	MakeComment(qstring& aComment)
		{
			aComment.sprnt(defaultCommentNameFormat, index, className.c_str(), memberName.c_str());
		}
	};

	// Identify and name common member functions
	void processMembers(LPCTSTR name, ea_t eaStart, ea_t* eaEnd, LPCSTR prefixName, ea_t parentvft, UINT parentCount, VFMemberList* vfMemberList);
	void correctFunctions(LPCTSTR name);
	bool IsClass(LPCSTR szClassName, LPSTR szCurrName, bool translate);
	ea_t getMemberName(LPSTR name, ea_t eaAddress);
	ea_t getMemberShortName(LPSTR name, ea_t eaAddress);

//	typedef std::string String;

}

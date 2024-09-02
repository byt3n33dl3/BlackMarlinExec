
// ****************************************************************************
// File: Utility.h
// Desc: Utility stuff
//
// ****************************************************************************
#pragma once

#include "undname.h"
#include <string>
#include <hash_set>
#include <hash_map>

// Size of string with out terminator
#define SIZESTR(x) (sizeof(x) - 1)

#define ALIGN(_x_) __declspec(align(_x_))

// Stack alignment trick, based on Douglas Walker's post
// http://www.gamasutra.com/view/feature/3975/data_alignment_part_2_objects_on_.php
#define STACKALIGN(name, type) \
	BYTE space_##name[sizeof(type) + (16-1)]; \
	type &name = *reinterpret_cast<type *>((UINT_PTR) (space_##name + (16-1)) & ~(16-1))

template <class T> inline void swap_t(T &var1, T &var2)
{
    T var = var1;
    var1 = var2;
    var2 = var;
}

// Time
typedef double TIMESTAMP;  // In fractional seconds
#define SECOND 1
#define MINUTE (60 * SECOND)
#define HOUR   (60 * MINUTE)
#define DAY    (HOUR * 24)

void trace(const char *format, ...);
TIMESTAMP getTimeStamp();
LPCSTR timeString(TIMESTAMP time);
LPCSTR byteSizeString(UINT64 bytes);
LPSTR  prettyNumberString(UINT64 n, __bcount(32) LPSTR buffer);
void getDisasmText(ea_t ea, qstring &s);
void idaFlags2String(flags_t f, __out qstring &s, BOOL withValue = FALSE);
void dumpFlags(ea_t ea, BOOL withValue = FALSE);

// Returns TRUE if there is a name at address that is unique (I.E. user, or from PDB, etc., and not IDA auto-generated)
inline BOOL hasUniqueName(ea_t ea) { return(has_name(get_flags_novalue(ea))); }

// Tick IDA's Qt message pump so it will show msg() output
#define refreshUI() WaitBox::processIdaEvents()

#define CATCH() catch (...) { msg("** Exception in %s()! ***\n", __FUNCTION__); }
#define CATCHTRUE() catch (...) { msg("** Exception in %s()! ***\n", __FUNCTION__); return(TRUE); }

typedef qlist<ea_t> eaList;
typedef stdext::hash_set<ea_t> eaSet;
typedef stdext::hash_map<ea_t, UINT> eaRefMap;
struct earef
{
    ea_t ea;
    UINT refs;
};
typedef qlist<earef> eaRefList;


// ea_t zero padded hex number format
#ifndef __EA64__
#define EAFORMAT "%08X"
#else
#define EAFORMAT "%016I64X"
#endif

#define __STR2__(x) #x
#define __STR1__(x) __STR2__(x)
#define __LOC__ __FILE__ "("__STR1__(__LINE__)") : Warning MSG: "
#define __LOC2__ __FILE__ "("__STR1__(__LINE__)") : "
// Now you can use the #pragma message to add the location of the message:
//
// #pragma message(__LOC__ "important part to be changed")
// #pragma message(__LOC2__ "error C9901: wish that error would exist")

// Get IDA 32 bit value with verification
template <class T> BOOL getVerify32_t(ea_t eaPtr, T &rValue)
{
	// Location valid?
    if (isLoaded(eaPtr))
	{
		// Get 32bit value
		rValue = (T) get_32bit(eaPtr);
		return(TRUE);
	}

	return(FALSE);
}

// Get IDA 64 bit value with verification
template <class T> BOOL getVerify64_t(ea_t eaPtr, T &rValue)
{
	// Location valid?
	if (isLoaded(eaPtr))
	{
		// Get 64bit value
		rValue = (T)get_64bit(eaPtr);
		return(TRUE);
}

	return(FALSE);
}

#ifdef __EA64__
#define getVerify_t getVerify64_t
#else
#define getVerify_t getVerify32_t
#endif

// Get address/pointer value
inline ea_t getEa(ea_t ea)
{
    #ifndef __EA64__
    return((ea_t) get_32bit(ea));
    #else
    return((ea_t) get_64bit(ea));
    #endif
}


// Returns TRUE if ea_t sized value flags
inline BOOL isEa(flags_t f)
{
    #ifndef __EA64__
    return(isDwrd(f));
    #else
    return(isQwrd(f));
    #endif
}
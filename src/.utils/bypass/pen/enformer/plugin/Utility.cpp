
// ****************************************************************************
// File: Utility.cpp
// Desc: Utility stuff
//
// ****************************************************************************
#include "stdafx.h"


// Integer to to double seconds
#define I2TIME(_int) ((double) (_int) * (double) ((double) 1.0 / (double) 1000.0))

// ==== Data ====
static ALIGN(16) double s_fTimeStampHolder = 0;
static DWORD s_dwLastTimeRead = 0;

// ****************************************************************************
// Func: GetTimeSamp()
// Desc: Get high precision elapsed seconds
//
// ****************************************************************************
TIMESTAMP getTimeStamp()
{
	LARGE_INTEGER large;
	QueryPerformanceCounter(&large);

    static ALIGN(16) TIMESTAMP s_ClockFreq = 0;
	if(s_ClockFreq == 0.0)
	{
		LARGE_INTEGER tLarge;
		QueryPerformanceFrequency(&tLarge);
		s_ClockFreq = (TIMESTAMP) tLarge.QuadPart;
	}

	return((TIMESTAMP) large.QuadPart / s_ClockFreq);
}

// Output formated text to debugger channel
void trace(const char *format, ...)
{
    if (format)
    {
        va_list vl;
        char str[4096]; str[SIZESTR(str)] = 0;
        va_start(vl, format);
        _vsntprintf(str, (sizeof(str) - 1), format, vl);
        va_end(vl);
        OutputDebugString(str);
    }
}

// Get a pretty delta time string for output
LPCSTR timeString(TIMESTAMP time)
{
	static char szBuff[64];

	if(time >= HOUR)
		_snprintf(szBuff, SIZESTR(szBuff), "%.2f hours", (time / (TIMESTAMP) HOUR));
	else
	if(time >= MINUTE)
		_snprintf(szBuff, SIZESTR(szBuff), "%.2f minutes", (time / (TIMESTAMP) MINUTE));
	else
	if(time < (TIMESTAMP) 0.01)
		_snprintf(szBuff, SIZESTR(szBuff), "%.2f milliseconds", (time * (TIMESTAMP) 1000.0));
	else
		_snprintf(szBuff, SIZESTR(szBuff), "%.2f seconds", time);

	return(szBuff);
}

// Returns a pretty factional byte size string for given input size
LPCSTR byteSizeString(UINT64 bytes)
{
    static const UINT64 KILLOBYTE = 1024;
    static const UINT64 MEGABYTE = (KILLOBYTE * 1024); // 1048576
    static const UINT64 GIGABYTE = (MEGABYTE * 1024); // 1073741824
    static const UINT64 TERABYTE = (GIGABYTE * 1024); // 1099511627776

    #define BYTESTR(_Size, _Suffix) \
    { \
	    double fSize = ((double) bytes / (double) _Size); \
	    double fIntegral; double fFractional = modf(fSize, &fIntegral); \
	    if(fFractional > 0.05) \
		    _snprintf(buffer, SIZESTR(buffer), ("%.1f " ## _Suffix), fSize); \
                else \
		    _snprintf(buffer, SIZESTR(buffer), ("%.0f " ## _Suffix), fIntegral); \
    }

    static char buffer[32];
    ZeroMemory(buffer, sizeof(buffer));
    if (bytes >= TERABYTE)
        BYTESTR(TERABYTE, "TB")
    else
    if (bytes >= GIGABYTE)
        BYTESTR(GIGABYTE, "GB")
    else
    if (bytes >= MEGABYTE)
        BYTESTR(MEGABYTE, "MB")
    else
    if (bytes >= KILLOBYTE)
        BYTESTR(KILLOBYTE, "KB")
    else
        _snprintf(buffer, SIZESTR(buffer), "%u byte%c", bytes, (bytes == 1) ? 0 : 's');

    return(buffer);
}


// Return a comma formatted string for a given number
LPSTR prettyNumberString(UINT64 n, __bcount(32) LPSTR buffer)
{
    std::string s;
    int c = 0;
    do
    {
        s.insert(0, 1, char('0' + (n % 10)));
        n /= 10;
        if ((c += (3 && n)) >= 3)
        {
            s.insert(0, 1, ',');
            c = 0;
        }
    } while (n);
    strncpy(buffer, s.c_str(), 31);
    return(buffer);
}

// Get a nice line of disassembled code text sans color tags
void getDisasmText(ea_t ea, qstring &s)
{
    s.clear();
    char buffer[MAXSTR]; buffer[0] = buffer[SIZESTR(buffer)] = 0;
    if (generate_disasm_line(ea, buffer, SIZESTR(buffer)))
        tag_remove(buffer, buffer, SIZESTR(buffer));
    s = buffer;
}


// ================================================================================================
// From IDA SDK "bytes.hpp"
// As it says were not supposed to be using these internal defs. Should be using accessors like
// isByte(), byteflag(), etc., but then these have never changed since at least 5.8'ish (yet)
// But it's a lot easier this way..
#define DT_TYPE     0xF0000000L         // Mask for DATA typing
#define FF_BYTE     0x00000000L         // byte
#define FF_WORD     0x10000000L         // word
#define FF_DWRD     0x20000000L         // double word
#define FF_QWRD     0x30000000L         // quadro word
#define FF_TBYT     0x40000000L         // tbyte
#define FF_ASCI     0x50000000L         // ASCII ?
#define FF_STRU     0x60000000L         // Struct ?
#define FF_OWRD     0x70000000L         // octaword (16 bytes)
#define FF_FLOAT    0x80000000L         // float
#define FF_DOUBLE   0x90000000L         // double
#define FF_PACKREAL 0xA0000000L         // packed decimal real
#define FF_ALIGN    0xB0000000L         // alignment directive
#define FF_3BYTE    0xC0000000L         // 3-byte data (only with support from the processor module)
#define FF_CUSTOM   0xD0000000L         // custom data type
#define FF_YWRD     0xE0000000L         // ymm word (32 bytes/256 bits)

#undef FF_JUMP
#define MS_CODE		0xF0000000L
#define FF_FUNC		0x10000000L			// function start?
//					0x20000000L         // not used
#define FF_IMMD		0x40000000L         // Has Immediate value ?
#define FF_JUMP		0x80000000L         // Has jump table or switch_info?

#define MS_0TYPE	0x00F00000L         // Mask for 1st arg typing
#define FF_0VOID	0x00000000L         // Void (unknown)?
#define FF_0NUMH	0x00100000L         // Hexadecimal number?
#define FF_0NUMD	0x00200000L         // Decimal number?
#define FF_0CHAR	0x00300000L         // Char ('x')?
#define FF_0SEG		0x00400000L         // Segment?
#define FF_0OFF		0x00500000L         // Offset?
#define FF_0NUMB	0x00600000L         // Binary number?
#define FF_0NUMO	0x00700000L         // Octal number?
#define FF_0ENUM	0x00800000L         // Enumeration?
#define FF_0FOP		0x00900000L         // Forced operand?
#define FF_0STRO	0x00A00000L         // Struct offset?
#define FF_0STK		0x00B00000L         // Stack variable?
#define FF_0FLT		0x00C00000L         // Floating point number?
#define FF_0CUST	0x00D00000L         // Custom format type?

#define MS_1TYPE	0x0F000000L			// Mask for 2nd arg typing
#define FF_1VOID	0x00000000L         // Void (unknown)?
#define FF_1NUMH	0x01000000L         // Hexadecimal number?
#define FF_1NUMD	0x02000000L         // Decimal number?
#define FF_1CHAR	0x03000000L         // Char ('x')?
#define FF_1SEG		0x04000000L         // Segment?
#define FF_1OFF		0x05000000L         // Offset?
#define FF_1NUMB	0x06000000L         // Binary number?
#define FF_1NUMO	0x07000000L         // Octal number?
#define FF_1ENUM	0x08000000L         // Enumeration?
#define FF_1FOP		0x09000000L         // Forced operand?
#define FF_1STRO	0x0A000000L         // Struct offset?
#define FF_1STK		0x0B000000L         // Stack variable?
#define FF_1FLT		0x0C000000L         // Floating point number?
#define FF_1CUST	0x0D000000L         // Custom format type?

#define FF_FLOW		0x00010000L         // Exec flow from prev instruction
#define FF_SIGN		0x00020000L         // Inverted sign of operands
#define FF_BNOT		0x00040000L         // Bitwise negation of operands
#define FF_VAR		0x00080000L         // is variable byte?

#define FF_REF		0x00001000L         // has references
#define FF_LINE		0x00002000L         // Has next or prev lines ?
#define FF_NAME		0x00004000L         // Has name ?
#define FF_LABL		0x00008000L         // Has dummy name?

#define FF_COMM		0x00000800L         // Has comment ?
#define FF_CODE		0x00000600L         // Code ?
#define FF_DATA		0x00000400L         // Data ?
#define FF_TAIL		0x00000200L         // Tail ?
#define FF_IVL		0x00000100L         // Byte has value ?
#define FF_UNK		0x00000000L         // Unknown ?


// Decode IDA address flags value into a readable string
void idaFlags2String(flags_t f, __out qstring &s, BOOL withValue)
{
	s.clear();
    #define FTEST(_f) if(f & _f){ if(!first) s += ", "; s += #_f; first = FALSE; }

	// F0000000
	BOOL first = TRUE;
	if(isData(f))
	{
		switch(f & DT_TYPE)
		{
			case FF_BYTE    : s += "FF_BYTE";     break;
			case FF_WORD    : s += "FF_WORD";     break;
			case FF_DWRD    : s += "FF_DWRD";     break;
			case FF_QWRD    : s += "FF_QWRD";     break;
			case FF_TBYT    : s += "FF_TBYT";     break;
			case FF_ASCI    : s += "FF_ASCI";     break;
			case FF_STRU    : s += "FF_STRU";     break;
			case FF_OWRD    : s += "FF_OWRD";     break;
			case FF_FLOAT   : s += "FF_FLOAT";	   break;
			case FF_DOUBLE  : s += "FF_DOUBLE";   break;
			case FF_PACKREAL: s += "FF_PACKREAL"; break;
			case FF_ALIGN   : s += "FF_ALIGN";    break;
			case FF_3BYTE   : s += "FF_3BYTE";    break;
			case FF_CUSTOM  : s += "FF_CUSTOM";   break;
		};
		first = FALSE;
	}
	else
	if(isCode(f))
	{
		if(f & MS_CODE)
		{
			FTEST(FF_FUNC);
			FTEST(FF_IMMD);
			FTEST(FF_JUMP);
		}
	}

	// 0F000000
	if(f & MS_1TYPE)
	{
		if(!first) s += ", ";
		switch(f & MS_1TYPE)
		{
			//default: s += ",FF_1VOID"; break;
			case FF_1NUMH: s += "FF_1NUMH"; break;
			case FF_1NUMD: s += "FF_1NUMD"; break;
			case FF_1CHAR: s += "FF_1CHAR"; break;
			case FF_1SEG:  s += "FF_1SEG";  break;
			case FF_1OFF:  s += "FF_1OFF";  break;
			case FF_1NUMB: s += "FF_1NUMB"; break;
			case FF_1NUMO: s += "FF_1NUMO"; break;
			case FF_1ENUM: s += "FF_1ENUM"; break;
			case FF_1FOP:  s += "FF_1FOP";  break;
			case FF_1STRO: s += "FF_1STRO"; break;
			case FF_1STK:  s += "FF_1STK";  break;
			case FF_1FLT:  s += "FF_1FLT";  break;
			case FF_1CUST: s += "FF_1CUST"; break;
		};
		first = FALSE;
	}

	// 00F00000
	if(f & MS_0TYPE)
	{
		if(!first) s += ", ";
		switch(f & MS_0TYPE)
		{
			//default: s += ",FF_0VOID"; break;
			case FF_0NUMH: s += "FF_0NUMH"; break;
			case FF_0NUMD: s += "FF_0NUMD"; break;
			case FF_0CHAR: s += "FF_0CHAR"; break;
			case FF_0SEG : s += "FF_0SEG";  break;
			case FF_0OFF : s += "FF_0OFF";  break;
			case FF_0NUMB: s += "FF_0NUMB"; break;
			case FF_0NUMO: s += "FF_0NUMO"; break;
			case FF_0ENUM: s += "FF_0ENUM"; break;
			case FF_0FOP : s += "FF_0FOP";  break;
			case FF_0STRO: s += "FF_0STRO"; break;
			case FF_0STK : s += "FF_0STK";  break;
			case FF_0FLT : s += "FF_0FLT";  break;
			case FF_0CUST: s += "FF_0CUST"; break;
		};
		first = FALSE;
	}

	// 000F0000
	if(f & 0xF0000)
	{
		FTEST(FF_FLOW);
		FTEST(FF_SIGN);
		FTEST(FF_BNOT);
		FTEST(FF_VAR);
	}

	// 0000F000
	if(f & 0xF000)
	{
		FTEST(FF_REF);
		FTEST(FF_LINE);
		FTEST(FF_NAME);
		FTEST(FF_LABL);
	}

	// 00000F00
	if(!first) s += ", ";
	switch(f & (FF_CODE | FF_DATA | FF_TAIL))
	{
		case FF_CODE: s += "FF_CODE"; break;
		case FF_DATA: s += "FF_DATA"; break;
		case FF_TAIL: s += "FF_TAIL"; break;
		default: s += "FF_UNK";	   break;
	};
	first = FALSE;
	if(f & FF_COMM) s += ", FF_COMM";
	if(f & FF_IVL)  s += ", FF_IVL";

	// 000000FF optional value
    if (withValue && (f & FF_IVL))
	{
        char buffer[16]; buffer[SIZESTR(buffer)] = 0;
        _snprintf(buffer, SIZESTR(buffer), ", value: %02X", (f & 0xFF));
		s += buffer;
	}

	#undef FTEST
}

// Dump flags at address w/optional byte value dump
void dumpFlags(ea_t ea, BOOL withValue)
{
    qstring s;
    idaFlags2String(getFlags(ea), s, withValue);
    msg(EAFORMAT" Flags: %s\n", ea, s.c_str());
}
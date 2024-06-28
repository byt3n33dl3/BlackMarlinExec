; =========================================================================================
;  A commented disssembly of the Operating System of the Lambda 8300 later ROM version.
; =========================================================================================

; Incompatible ROMS
; =================
; An earlier version of the Lambda ROM existed, with no color support (no INK, PAPER or BORDER).
; Also, two more ROMS existed for the CAC-3 and NF300 clones supporting READ/DATA/RESTORE

; Last updated: 23-JUL-2015,  Stefano B
; Work in progress, any contribution is welcome.
; 
; The Lambda 8300 was a ZX81 clone made in Hong Kong, featuring
; interesting improvements such as sound and colour option.
; The ROM programmer was able to rework the original ZX81 code
; and squeeze out few bytes from the core routines !
;
; The Lambda 8300 was also rebranded with the following names:
; DEF 3000, PC 2000, Marathon 32K, IQ 8300, PC 8300, Power 3000
; Unisonic 8300, Futura 8300, Basic 2000 and Basic 3000.
; 
; The documentation is incomplete and if you can find a copy
; of "The Complete Spectrum ROM Disassembly" then many routines
; such as POINTERS and most of the mathematical routines are
; similar and often identical.
;
; I've kept the labels (and recycled most of the comments) from
; the ZX81 ROM assembly listings, so it should be easy to compare
; portions of the two ROMs if necessary.
;
; The TOKENS table sections are still messy, please don't blame me!


00000000: D3 FD		OUTA (FDh)		; turn off the NMI generator.
00000002: 3E BF		LD A,BFh
00000004: DB FE		INA (FEh)		; BFFEh :    ENTER  L    K    J    H
00000006: 18 25		JR +25h			; jp to 0F28h via 002dh


;; NEXT-CHAR ?
;; CH-ADD+1

00000008: 00		NOP
00000009: 2A 16 40	LD HL,(4016h)		; fetch character address from CH_ADD.
;; TEMP-PTR1 + GET-CHAR
0000000C: 23		INC HL				; address next immediate location.
;; TEMP-PTR2 + GET-CHAR
0000000D: 22 16 40	LD (4016h),HL		; update system variable CH_ADD.

;----------------------------------
; THE 'COLLECT A CHARACTER' RESTART
;----------------------------------
; The character addressed by the system variable CH_ADD is fetched and if it
; is a non-space, non-cursor character it is returned else CH_ADD is 
; incremented and the new addressed character tested until it is not a space.
00000010: 2A 16 40	LD HL,(4016h)		; fetch character address from CH_ADD.
00000013: 7E		LD A,(HL)			; fetch the character.
00000014: B7		OR A				; compare to cursor character ($7F on the ZX81).
00000015: C0		RET NZ				; return if not the cursor.
00000016: 18 F4		JR -0Ch				; back for next character to TEMP-PTR1.

;--------------------------------
; THE 'PRINT A CHARACTER' RESTART
;--------------------------------
; This restart prints the character in the accumulator using the alternate
; register set so there is no requirement to save the main registers.
; There is sufficient room available to separate a space (zero) from other
; characters as leading spaces need not be considered with a space.

00000018: C3 B4 04	JP 04B4h


;------------------------
; Absolute magnitude
;------------------------
; This calculator literal finds the absolute value of the last value,
; floating point, on calculator stack.

;; abs
0000001B: 23		INC HL
0000001C: CB BE		RES 7,(HL)
0000001E: 2B		DEC HL
0000001F: C9		RET


;---------------------------
; THE 'STK-FETCH' SUBROUTINE
;---------------------------
; This routine fetches a five-byte value from the calculator stack
; reducing the pointer to the end of the stack by five.
; For a floating-point number the exponent is in A and the mantissa
; is the thirty-two bits EDCB.
; For strings, the start of the string is in DE and the length in BC.
; A is unused.

;; STK-FETCH
00000020: 2A 1C 40	LD HL,(401Ch)				; STKEND
00000023: 2B		DEC HL
00000024: 46		LD B,(HL)

00000025: C3 25 14	JP 1425h

; routine SYNTAX-Z
00000028: FD CB 1E 7E	BIT 7,(IY+1Eh)			; BREG/FLAGS
0000002C: C9		RET

;; BOOT / RESET   pivot
0000002D: C3 28 0F	JP 0F28h

;; FP-CALC  / CALCULATE
00000030: CD ED 18	CALL 18EDh		; STK-PNTRS

;; GEN-ENT-2
00000033: D9		EXX				; switch sets
00000034: E3		EX HL,(SP) 		; and store the address of next instruction, the return address, in H'L'.
									; If this is a recursive call then the H'L' of the previous invocation goes on stack.
									; c.f. end-calc.
00000035: C3 7F 09	JP 097Fh


;------------------------
; THE 'INTERRUPT' RESTART
;------------------------
;
00000038: 05		DEC B
00000039: 20 0A		JR NZ,+0Ah		; JUMP forward if not zero to SCAN-LINE
0000003B: E1		POP HL
0000003C: 0D		DEC C
0000003D: C8		RET Z
0000003E: C8		RET Z
0000003F: 06 08		LD B,08h

;; WAIT-INT
00000041: ED 4F		LD R,A
00000043: FB		EI
00000044: E9		JP      (HL)

00000045: D1		POP DE
00000046: 00		NOP
00000047: 18 F8		JR -08h		; WAIT-INT

; conversion table for no-l-eql, etc
00000049:   06 05 03 01 02 04


;------------------------------
; Handle string AND number 
;------------------------------
; e.g. "YOU WIN" AND SCORE>99 will return the string if condition is true
; or the null string if false.

;; str-&-no
0000004F: 1A		LD A,(DE)		; fetch exponent of second number.
00000050: B7		OR A			; test it.
00000051: C0		RET NZ			; return if number was not zero - the string is the result.

; if the number was zero (false) then the null string must be returned by
; altering the length of the string on the calculator stack to zero.

00000052: 1B		DEC DE			; point to the 5th byte of string descriptor.
00000053: 12		LD (DE),A		; place zero in high byte of length
00000054: 1B		DEC DE			; address low byte of length
00000055: 12		LD (DE),A		; place zero there - now the null string
00000056: 13		INC DE			; restore pointer
00000057: 13		INC DE
00000058: C9		RET

;; NMI-CONT
00000059: 08		EX AF,AF'
0000005A: F5		PUSH AF
0000005B: E5		PUSH HL
0000005C: D5		PUSH DE
0000005D: C5		PUSH BC
0000005E: 21 7D C0	LD HL,C07Dh		; point to upper 32K 'display file' ghosted copy
00000061: 76		HALT			; Wait for Interrupt
00000062: D3 FD		OUTA (FDh)		; turn off the NMI generator.
00000064: DD E9		JP IX			; forward to 1323h or 1334h

; NMI
00000066: 08		EX AF,AF'
00000067: 3C		INC A
00000068: CA 59 00	JP Z,0059h
0000006B: 00		NOP
;; NMI-RET
0000006C: 08		EX AF,AF'
0000006D: C9		RET



;----------------------
; THE 'ARCSIN' FUNCTION
;----------------------
; (Offset $??: 'asn')
; the inverse sine function with result in radians.
; derived from arctan function above.
; Error A unless the argument is between -1 and +1 inclusive.
; uses an adaptation of the formula asn(x) = atn(x/sqr(1-x*x))
;
;
;           /|
;        1 / |
;         /  |x
;        /a  |
;       /----|    
;         y
;
; e.g. we know the opposite side (x) and hypotenuse (1) 
; and we wish to find angle a in radians.
; we can derive length y by Pythagorus and then use ATN instead. 
; since y*y + x*x = 1*1 (Pythagorus Theorum) then
; y=sqr(1-x*x)                         - no need to multiply 1 by itself.
; so, asn(a) = atn(x/y)
; or more fully,
; asn(a) = atn(x/sqr(1-x*x))

; Close but no cigar.

; While PRINT ATN (x/SQR (1-x*x)) gives the same results as PRINT ASN x,
; it leads to division by zero when x is 1 or -1.
; To overcome this, 1 is added to y giving half the required angle and the 
; result is then doubled. 
; That is PRINT ATN (x/(SQR (1-x*x) +1)) *2
; A value higher than 1 gives the required error as attempting to find  the
; square root of a negative number generates an error in Sinclair BASIC.

;; asn
0000006E: F7		RST 30h				; FP-CALC
0000006F: 01		;;duplicate
00000070: 01		;;duplicate
00000071: 1F		;;multiply
00000072: 79		;;stk-one
00000073: 1E		;;subtract
00000074: 09		;;negate
00000075: 16		;;sqr
00000076: 79		;;stk-one
00000077: 2A		;;addition
00000078: 20		;;division
00000079: 12		;;atn
0000007A: 01		;;duplicate
0000007B: AA		;;addition & end-calc
0000007C: C9		RET

;; NEXT-LINE
0000007D: 22 0A 40	LD (400Ah),HL			; NXTLIN (<> ZX81)
00000080: ED 53 16 40	LD (4016h),DE		; CH_ADD
00000084: FD CB 1E FE	SET 7,(IY+1Eh)		; BREG/FLAGS

;; LINE-RUN
00000088: FD 36 07 FF	LD (IY+07h),FFh		; PPC low
0000008C: CD 1A 14	CALL 141Ah				; SET-MIN
0000008F: 3A 2D 40	LD A,(402Dh)			; FLAGX
00000092: CB 6F		BIT 5,A
00000094: 20 4F		JR NZ,+4Fh
;; LINE-NULL
00000096: D7		RST 10h					; GET-CHAR
00000097: FE 76		CP 76h					; compare to NEWLINE.
00000099: C8		RET Z					; return if so.

0000009A: 11 F1 00	LD DE,00F1h				; offset to offset table.
0000009D: FE 46		CP 46h
0000009F: 38 0C		JR C,+0Ch
000000A1: FE DC		CP DCh
000000A3: 30 06		JR NC,+06h
000000A5: FE 49		CP 49h
000000A7: 30 04		JR NC,+04h
000000A9: C6 93		ADD 93h					; adjust token to offset

000000AB: 5F		LD E,A					; transfer character to E.

000000AC: CF		RST 08h					; NEXT-CHAR

000000AD: 21 02 1A	LD HL,1A02h				; offset table.
000000B0: 19		ADD HL,DE				; index into offset table.
000000B1: 5E		LD E,(HL)				; fetch offset
000000B2: 19		ADD HL,DE				; index into parameter table.

;; GET-PARAM
000000B3: 7E		LD A,(HL)
000000B4: 23		INC HL

000000B5: 22 30 40	LD (4030h),HL			; T_ADDR
000000B8: 5F		LD E,A
000000B9: FE 0D		CP 0Dh
000000BB: 38 0B		JR C,+0Bh
000000BD: D7		RST 10h					; GET-CHAR
000000BE: BB		CP E
000000BF: C2 42 0A	JP NZ,0A42h				; to REPORT-C

000000C2: CF		RST 08h					; NEXT-CHAR

;; SCAN-LOOP
000000C3: 2A 30 40	LD HL,(4030h)			; T_ADDR
000000C6: 18 EB		JR -15h					; to GET-PARAM

000000C8: 16 00		LD D,00h
000000CA: 21 D1 09	LD HL,09D1h
000000CD: 19		ADD HL,DE
000000CE: 5E		LD E,(HL)
000000CF: 19		ADD HL,DE
000000D0: 11 C3 00	LD DE,00C3h				; Address: SCAN-LOOP
000000D3: D5		PUSH DE					; is pushed on machine stack.
000000D4: E5		PUSH HL
000000D5: D7		RST 10h					; GET-CHAR
000000D6: C9		RET

000000D7: EF		RST 28h					; routine SYNTAX-Z
000000D8: 28 05		JR Z,+05h

000000DA: F7		RST 30h					; FP-CALC
000000DB: B5 		;;delete & end-calc

000000DC: 1A		LD A,(DE)
000000DD: B7		OR A
000000DE: C8		RET Z
000000DF: D7		RST 10h					; GET-CHAR
000000E0: 18 B8		JR -48h
000000E2: 3A 1E 40	LD A,(401Eh)			; BREG/FLAGS
000000E5: F5		PUSH AF
000000E6: CD 06 08	CALL 0806h				; SCANNING
000000E9: F1		POP AF
000000EA: FD AE 1E	XOR (IY+1Eh)			; BREG/FLAGS
000000ED: CB 77		BIT 6,A
000000EF: 20 CE		JR NZ,-32h


; offset fable
000000F1: CD 3B 0A	CALL 0A3Bh				; routine CHECK-END
000000F4: FD CB 2D AE	RES 5,(IY+2Dh)      ; FLAGX

;---------------------
; THE 'LET' SUBROUTINE
;---------------------
;
;

;; LET
000000F8: 2A 12 40	LD HL,(4012h)			; DEST
000000FB: FD CB 2D 4E	BIT 1,(IY+2Dh)      ; FLAGX
000000FF: 20 26		JR NZ,+26h

;; L-EXISTS
00000101: CD 7A 09	CALL 097Ah				; routine SYNTAX-Z
00000104: 20 50		JR NZ,+50h
00000106: ED 4B 2E 40	LD BC,(402Eh)		; STRLEN
0000010A: 3A 2D 40	LD A,(402Dh)			; FLAGX
0000010D: 1F		RRA
0000010E: 38 51		JR C,+51h
00000110: C5		PUSH BC
00000111: E5		PUSH HL
00000112: E7		RST 20h					; STK-FETCH
00000113: E1		POP HL
00000114: D9		EXX
00000115: C1		POP BC
00000116: 79		LD A,C
00000117: B0		OR B
00000118: 0B		DEC BC
00000119: D9		EXX
0000011A: C8		RET Z
0000011B: 78		LD A,B
0000011C: B1		OR C
0000011D: 28 03		JR Z,+03h
0000011F: 0B		DEC BC
00000120: 1A		LD A,(DE)
00000121: 13		INC DE
00000122: 77		LD (HL),A
00000123: 23		INC HL
00000124: D9		EXX
00000125: 18 EF		JR -11h

;; LET (continued)
00000127: 01 05 00	LD BC,0005h
0000012A: CD 36 05	CALL 0536h
0000012D: 30 FB		JR NC,-05h
0000012F: EE 0D		XOR 0Dh				; is it '$' ?
00000131: 28 5F		JR Z,+5Fh			; forward if so to L-NEW$

00000133: CD DD 0B	CALL 0BDDh			; BC-SPACES
00000136: 79		LD A,C
00000137: D6 06		SUB 06h
00000139: 4F		LD C,A
0000013A: 3E 80		LD A,80h
0000013C: 20 01		JR NZ,+01h
0000013E: 0F		RRCA
0000013F: 2A 12 40	LD HL,(4012h)		; DEST
00000142: AE		XOR (HL)
00000143: D5		PUSH DE
00000144: F2 4E 01	JP P,014Eh
00000147: 23		INC HL
00000148: ED B0		LDIR
0000014A: 1B		DEC DE
0000014B: EB		EX DE,HL
0000014C: CB FE		SET 7,(HL)
0000014E: E1		POP HL
0000014F: CD AF 01	CALL 01AFh
00000152: 01 FA FF	LD BC,FFFAh
00000155: 09		ADD HL,BC

; part of S-DECIMAL
00000156: 23		INC HL
00000157: E5		PUSH HL

00000158: F7		RST 30h				; FP-CALC
00000159: B5 		;;delete & end-calc

0000015A: EB		EX DE,HL
0000015B: D1		POP DE
0000015C: 01 05 00	LD BC,0005h			; five bytes to move.
0000015F: 18 2C		JR +2Ch

;; L-ADD$
00000161: 2B		DEC HL
00000162: 2B		DEC HL
00000163: 2B		DEC HL
00000164: E5		PUSH HL
00000165: 7E		LD A,(HL)
00000166: CD 96 01	CALL 0196h			; L-STRING
00000169: E1		POP HL
0000016A: CD 13 1A	CALL 1A13h			; routine NEXT-ONE
0000016D: 18 08		JR +08h

;; RECLAIM-1
0000016F: CD 37 1A	CALL 1A37h			; routine DIFFER
00000172: 18 03		JR +03h

;---------------------------
; THE 'CLEAR-ONE' SUBROUTINE
;---------------------------
;
;

;; CLEAR-ONE
00000174: 01 01 00	LD BC,0001h
;; RECLAIM-2
00000177: C5		PUSH BC
00000178: AF		XOR A
00000179: 91		SUB C
0000017A: 4F		LD C,A
0000017B: 3E 00		LD A,00h
0000017D: 98		SBC B
0000017E: 47		LD B,A
0000017F: CD 3F 1A	CALL 1A3Fh		; routine POINTERS
00000182: EB		EX DE,HL
00000183: 2A 1C 40	LD HL,(401Ch)		; STKEND low
00000186: A7		AND A
00000187: ED 52		SBC HL,DE
00000189: 44		LD B,H
0000018A: 4D		LD C,L
0000018B: E1		POP HL
0000018C: 19		ADD HL,DE

; part of S-DECIMAL
0000018D: D5		PUSH DE
0000018E: ED B0		LDIR
00000190: E1		POP HL
00000191: C9		RET

;; L-NEW$
00000192: 2B		DEC HL
00000193: 3E 60		LD A,60h				; prepare mask %01100000
00000195: AE		XOR (HL)

; -------------------------
; THE 'L-STRING' SUBROUTINE
; -------------------------
;

;; L-STRING
00000196: F5		PUSH AF
00000197: E7		RST 20h					; routine STK-FETCH
00000198: EB		EX DE,HL
00000199: 09		ADD HL,BC
0000019A: 03		INC BC
0000019B: 03		INC BC
0000019C: E5		PUSH HL
0000019D: 03		INC BC
0000019E: CD DD 0B	CALL 0BDDh				; BC-SPACES
000001A1: 0B		DEC BC
000001A2: D1		POP DE
000001A3: 0B		DEC BC
000001A4: EB		EX DE,HL
000001A5: C5		PUSH BC
000001A6: ED B8		LDDR					; Copy Bytes
000001A8: C1		POP BC
000001A9: EB		EX DE,HL
000001AA: 0B		DEC BC
000001AB: 70		LD (HL),B
000001AC: 2B		DEC HL
000001AD: 71		LD (HL),C
000001AE: FE F5		CP F5h

000001B0: ED 5B 14 40	LD DE,(4014h)		; E_LINE
000001B4: CD 6F 01	CALL 016Fh				; RECLAIM-1
000001B7: 2B		DEC HL
000001B8: F1		POP AF

;; L-FIRST
000001B9: 77		LD (HL),A
000001BA: 2A 1A 40	LD HL,(401Ah)			; STKBOT
000001BD: 22 14 40	LD (4014h),HL			; E_LINE
000001C0: 2B		DEC HL
000001C1: 36 80		LD (HL),80h
000001C3: C9		RET

0;---------------------------
; THE 'POKE' COMMAND ROUTINE
;---------------------------
;
;

;; POKE
00001C4: CD FF 14	CALL 14FFh				; STK-TO-A
000001C7: F5		PUSH AF
000001C8: CD 09 15	CALL 1509h				; FIND-INT
000001CB: F1		POP AF
000001CC: 02		LD (BC),A
000001CD: C9		RET

; ----------------------------------
; THE 'FETCH TWO NUMBERS' SUBROUTINE
; ----------------------------------
; This routine is used by addition, multiplication and division to fetch
; the two five-byte numbers addressed by HL and DE from the calculator stack
; into the Z80 registers.
; The HL register may no longer point to the first of the two numbers.
; Since the 32-bit addition operation is accomplished using two Z80 16-bit
; instructions, it is important that the lower two bytes of each mantissa are
; in one set of registers and the other bytes all in the alternate set.
;
; In: HL = highest number, DE= lowest number
;
;         : alt':   :
; Out:    :H,B-C:C,B: num1
;         :L,D-E:D-E: num2

;; FETCH-TWO
000001CE: 4E		LD C,(HL)
000001CF: 23		INC HL
000001D0: 46		LD B,(HL)
000001D1: 77		LD (HL),A		; insert sign when used from multiplication.
000001D2: 79		LD A,C			; m1
000001D3: 23		INC HL
000001D4: 4E		LD C,(HL)
000001D5: 23		INC HL
000001D6: C5		PUSH BC			; PUSH m2 m3
000001D7: 46		LD B,(HL)
000001D8: 23		INC HL
000001D9: 4E		LD C,(HL)		; m4
000001DA: EB		EX DE,HL		; make HL point to start of second number.
000001DB: 56		LD D,(HL)
000001DC: 23		INC HL
000001DD: 5F		LD E,A
000001DE: D5		PUSH DE
000001DF: 56		LD D,(HL)
000001E0: 23		INC HL
000001E1: 5E		LD E,(HL)
000001E2: 23		INC HL
000001E3: D5		PUSH DE
000001E4: 56		LD D,(HL)
000001E5: 23		INC HL
000001E6: 5E		LD E,(HL)
000001E7: D9		EXX
000001E8: D1		POP DE
000001E9: E1		POP HL
000001EA: C1		POP BC
000001EB: D9		EXX
000001EC: C9		RET

;; DISPLAY-3
000001ED: FD 46 28	LD B,(IY+28h)		; load B with MARGIN
000001F0: DD E1		POP IX				; return address to IX register (see above)
										; It will be either 1323h or 1334h
000001F2: FD CB 3B 7E	BIT 7,(IY+3Bh)		; test CDFLAG
000001F6: 28 0C		JR Z,+0Ch			; forward to DISPLAY-4

000001F8: 78		LD A,B
000001F9: 3D		DEC A
000001FA: ED 44		NEG
000001FC: 08		EX AF,AF'
000001FD: D3 FE		OUTA (FEh)			; enable the NMI generator.

000001FF: C1		POP BC
00000200: D1		POP DE
00000201: E1		POP HL
00000202: F1		POP AF
00000203: C9		RET


;; DISPLAY-4
00000204: 0E 01		LD C,01h
00000206: 3E FC		LD A,FCh
00000208: CD 66 16	CALL 1666h
0000020B: E3		EX HL,(SP)
0000020C: E3		EX HL,(SP)
0000020D: 2B		DEC HL
0000020E: DD E9		JP IX

;-----------------------------
; THE 'STACK-TO-BC' SUBROUTINE
;-----------------------------
;
;

;; STK-TO-BC
00000210: CD FF 14	CALL 14FFh			; STK-TO-A
00000213: F5		PUSH AF
00000214: CD FF 14	CALL 14FFh			; STK-TO-A
00000217: F1		POP AF
00000218: 47		LD B,A
00000219: C9		RET

;-------------------
; Series generator
;-------------------
; The ZX81 uses Chebyshev polynomials to generate approximations for
; SIN, ATN, LN and EXP.  (...)

;; series-xx
0000021A: 32 09 40	LD (4009h),A        ; VERSN acts as a counter and is loaded with  parameter $00 - $1F
										; on the ZX81 the counter was stored in register B

0000021D: F7		RST 30h				; FP-CALC

; The initialization phase.

0000021E: 01		;;duplicate					x,x
0000021F: 2A		;;addition					x+x
00000220: 50		;;st-mem-0					x+x
00000221: 35		;;delete					.
00000222: 7A		;;stk-zero					0
00000223: DA		;;st-mem-2 & end-calc		0

; a loop is now entered to perform the algebraic calculation for each of
; the numbers in the series

;; G-LOOP
00000224: F7		RST 30h				; FP-CALC
00000225: 01		;;duplicate					v,v.
00000226: 40		;;get-mem-0					v,v,x+2
00000227: 1F		;;multiply					v,v*x+2
00000228: 4A		;;get-mem-2					v,v*x+2,v
00000229: 55		;;st-mem-1
0000022A: 9E		;;subtract & end.calc

; the previous pointer is fetched from the machine stack to H'L' where it
; addresses one of the numbers of the series following the series literal.

0000022B: CD 31 0D	CALL 0D31h			; routine STK-DATA is called directly to push a value and advance H'L'.
0000022E: CD 33 00	CALL 0033h			; routine GEN-ENT-2 recursively re-enters the calculator without disturbing system variable BREG 
										; H'L' value goes on the machine stack and is then loaded as usual with the next address.
										
00000231: 2A		;;addition
00000232: 33		;;exchange
00000233: 5A		;;st-mem-2
00000234: B5		;;delete & end-calc

00000235: FD 35 09	DEC (IY+09h)        ; VERSN
00000238: 20 EA		JR NZ,-16h			; loop to G-LOOP

0000023A: F7		RST 30h				; FP-CALC
0000023B: 45		LD B,L
0000023C: 9E		;;subtract & end-calc
0000023D: C9		RET

;; 
0000023E: CD 54 14	CALL 1454h			; routine LINE-ENDS
00000241: CD C2 06	CALL 06C2h			; routine LEFT-EDGE
00000244: CD 74 01	CALL 0174h			; routine CLEAR-ONE
00000247: 2A 14 40	LD HL,(4014h)		; E_LINE
0000024A: 54		LD D,H
0000024B: 5D		LD E,L
0000024C: 2B		DEC HL
0000024D: 22 16 40	LD (4016h),HL		; CH_ADD
00000250: CF		RST 08h				; NEXT-CHAR
00000251: 12		LD (DE),A
00000252: 13		INC DE
00000253: FE 76		CP 76h
00000255: 28 45		JR Z,+45h
00000257: FE 0B		CP 0Bh
00000259: 28 08		JR Z,+08h
0000025B: D5		PUSH DE
0000025C: 11 82 05	LD DE,0582h			; 'TOKENS' TABLE
0000025F: 0E 00		LD C,00h
00000261: 18 1C		JR +1Ch

00000263: 23		INC HL
00000264: 7E		LD A,(HL)
00000265: 12		LD (DE),A
00000266: 13		INC DE
00000267: FE 76		CP 76h
00000269: 28 31		JR Z,+31h
0000026B: FE 0B		CP 0Bh
0000026D: 20 F4		JR NZ,-0Ch
0000026F: 18 DC		JR -24h
00000271: 1A		LD A,(DE)
00000272: 13		INC DE
00000273: 17		RLA
00000274: 30 FB		JR NC,-05h
00000276: 0C		INC C
00000277: 3E 48		LD A,48h
00000279: B9		CP C
0000027A: 30 03		JR NC,+03h
0000027C: D1		POP DE
0000027D: 18 D1		JR -2Fh

0000027F: 2A 16 40	LD HL,(4016h)		; CH_ADD
00000282: 1A		LD A,(DE)
00000283: 47		LD B,A
00000284: E6 3F		AND 3Fh
00000286: BE		CP (HL)
00000287: 20 E8		JR NZ,-18h
00000289: 23		INC HL
0000028A: 13		INC DE
0000028B: CB 78		BIT 7,B
0000028D: 28 F3		JR Z,-0Dh
0000028F: D1		POP DE
00000290: 1B		DEC DE
00000291: 79		LD A,C
00000292: CB 77		BIT 6,A
00000294: 20 02		JR NZ,+02h
00000296: F6 C0		OR C0h
00000298: 12		LD (DE),A
00000299: 13		INC DE
0000029A: 18 B0		JR -50h
0000029C: EB		EX DE,HL
0000029D: CD E1 13	CALL 13E1h					; SET-STK-B
000002A0: 21 FC 0F	LD HL,0FFCh
000002A3: E5		PUSH HL
000002A4: AF		XOR A
000002A5: 32 1E 40	LD (401Eh),A				; BREG/FLAGS
000002A8: CD 80 13	CALL 1380h					; E-LINE-NO
000002AB: CD 88 00	CALL 0088h					; LINE-RUN
000002AE: D1		POP DE
000002AF: CD 80 13	CALL 1380h					; E-LINE-NO
000002B2: 28 0D		JR Z,+0Dh
000002B4: ED 4B 30 40	LD BC,(4030h)			; T_ADDR
000002B8: CD 93 14	CALL 1493h					; call LOC-ADDR
000002BB: ED 5B 0A 40	LD DE,(400Ah)			; NXTLIN (<> ZX81)
000002BF: 18 49		JR +49h
000002C1: B0		OR B
000002C2: 28 3A		JR Z,+3Ah
000002C4: 21 30 03	LD HL,0330h
000002C7: E5		PUSH HL
000002C8: ED 43 29 40	LD (4029h),BC			; E_PPC (<> ZX81)

000002CC: 2A 1A 40	LD HL,(401Ah)				; STKBOT
000002CF: ED 5B 16 40	LD DE,(4016h)			; CH_ADD
000002D3: ED 52		SBC HL,DE
000002D5: E5		PUSH HL
000002D6: CD 38 0B	CALL 0B38h					; routine LINE-ADDR (BC)
000002D9: CC 6A 01	CALL Z,016Ah
000002DC: C1		POP BC
000002DD: 79		LD A,C
000002DE: 3D		DEC A
000002DF: B0		OR B
000002E0: 28 18		JR Z,+18h

000002E2: C5		PUSH BC

000002E3: CD B1 1C	CALL 1CB1h					; MAKE-ROOM plus 4
000002E6: 23		INC HL
000002E7: ED 5B 29 40	LD DE,(4029h)			; E_PPC (<> ZX81)
000002EB: 72		LD (HL),D
000002EC: 23		INC HL
000002ED: 73		LD (HL),E
000002EE: 23		INC HL
000002EF: C1		POP BC
000002F0: 71		LD (HL),C
000002F1: 23		INC HL
000002F2: 70		LD (HL),B
000002F3: 23		INC HL
000002F4: EB		EX DE,HL
000002F5: 2A 16 40	LD HL,(4016h)			; CH_ADD
000002F8: ED B0		LDIR
000002FA: E1		POP HL

;; jumps to N/L-ONLY
000002FB: C3 63 18	JP 1863h				; to N/L-ONLY

;; TEST-NULL
000002FE: D7		RST 10h					; GET-CHAR
000002FF: FE 76		CP 76h
;; N/L-NULL
00000301: 28 F8		JR Z,-08h				; to N/L-ONLY

00000303: 3C		INC A
00000304: C4 7A 1C	CALL NZ,1C7Ah			; CLEAR-PRB and CLS
00000307: 11 7D 40	LD DE,407Dh				; D-FILE
0000030A: D7		RST 10h					; GET-CHAR
0000030B: EB		EX DE,HL
0000030C: FD 36 22 02	LD (IY+22h),02h		; DF_SZ
00000310: CD 7D 00	CALL 007Dh				; NEXT-LINE
00000313: CD 45 14	CALL 1445h				; X-TEMP
00000316: FD CB 1E 8E	RES 1,(IY+1Eh)		; BREG/FLAGS
0000031A: 3A 07 40	LD A,(4007h)			; PPC low / ERR NR
0000031D: E6 C0		AND C0h
0000031F: 28 0F		JR Z,+0Fh

00000321: 2A 0A 40	LD HL,(400Ah)			; NXTLIN (<> ZX81)
00000324: A6		AND (HL)
00000325: 20 09		JR NZ,+09h				; to STOP-LINE

00000327: CD 1A 1C	CALL 1C1Ah
0000032A: 38 E4		JR C,-1Ch
0000032C: FD 36 07 01	LD (IY+07h),01h		; PPC low

;; STOP-LINE
00000330: CD CA 1C	CALL 1CCAh				; run COPY-BUFF if printer is enabled
00000333: 06 01		LD B,01h
00000335: CD 91 14	CALL 1491h				; LOC-ADDR for current row
00000338: ED 5B 36 40	LD DE,(4036h)		; LAMBDA-VAR
0000033C: FD 36 37 F0	LD (IY+37h),F0h		; LAMBDA-VAR +1
00000340: 3A 07 40	LD A,(4007h)			; PPC low / ERR NR
00000343: 3C		INC A
00000344: 28 0A		JR Z,+0Ah				; to REPORT

00000346: 62		LD H,D
00000347: 6B		LD L,E
00000348: FE 01		CP 01h
0000034A: 20 01		JR NZ,+01h				; to CONTINUE
0000034C: 23		INC HL

;; CONTINUE
0000034D: 22 2B 40	LD (402Bh),HL			; OLDPPC

;; REPORT
00000350: FE 04		CP 04h
00000352: F5		PUSH AF
00000353: 87		ADD A
00000354: 4F		LD C,A
00000355: AF		XOR A
00000356: 47		LD B,A
00000357: 32 2D 40	LD (402Dh),A			; FLAGX
0000035A: 32 19 40	LD (4019h),A			; X_PTR_high
0000035D: 32 22 40	LD (4022h),A			; DF_SZ

00000360: 21 E5 07	LD HL,07E5h				; ERR-MSG table
00000363: 09		ADD HL,BC
00000364: 7E		LD A,(HL)
00000365: DF		RST 18h					; PRINT-A
00000366: 23		INC HL
00000367: 7E		LD A,(HL)
00000368: DF		RST 18h					; PRINT-A
00000369: CB 7A		BIT 7,D
0000036B: 20 0D		JR NZ,+0Dh
0000036D: AF		XOR A
0000036E: DF		RST 18h					; PRINT-A
0000036F: 3E 2E		LD A,2Eh
00000371: DF		RST 18h					; PRINT-A
00000372: 3E 33		LD A,33h
00000374: DF		RST 18h					; PRINT-A
00000375: AF		XOR A
00000376: DF		RST 18h					; PRINT-A
00000377: CD 87 04	CALL 0487h
0000037A: F1		POP AF
0000037B: D4 B0 0B	CALL NC,0BB0h			; ALERT BEEP
0000037E: CD 2D 1C	CALL 1C2Dh				; DEBOUNCE
00000381: C3 21 12	JP 1221h

00000384: FD CB 2D 6E	BIT 5,(IY+2Dh)      ; FLAGX
00000388: CA 63 18	JP Z,1863h				; to N/L-ONLY
0000038B: CD 54 14	CALL 1454h				; routine LINE-ENDS
0000038E: 18 9C		JR -64h

;-------------------------
; THE 'ARCCOS' FUNCTION
;-------------------------
; (Offset $??: 'acs')
; the inverse cosine function with the result in radians.
; Error A unless the argument is between -1 and +1.
; Result in range 0 to pi.
; Derived from asn above which is in turn derived from the preceding atn.
; It could have been derived directly from atn using acs(x) = atn(sqr(1-x*x)/x).
; However, as sine and cosine are horizontal translations of each other,
; uses acs(x) = pi/2 - asn(x)

; e.g. the arccosine of a known x value will give the required angle b in 
; radians.
; We know, from above, how to calculate the angle a using asn(x). 
; Since the three angles of any triangle add up to 180 degrees, or pi radians,
; and the largest angle in this case is a right-angle (pi/2 radians), then
; we can calculate angle b as pi/2 (both angles) minus asn(x) (angle a).
; 
;
;           /|
;        1 /b|
;         /  |x
;        /a  |
;       /----|    
;         y

;; acs
00000390: F7		RST 30h					; FP-CALC
00000391: 10		;;asn
00000393: 70		;;stk-pi/2
00000393: 1E		;;subtract
00000394: 89		;;negate & end-calc
00000395: C9		RET



00000396: 4F		LD C,A
00000397: CD C2 06	CALL 06C2h			; routine LEFT-EDGE
0000039A: 79		LD A,C
0000039B: 01 01 00	LD BC,0001h
0000039E: CD B5 1C	CALL 1CB5h			; MAKE-ROOM
000003A1: 12		LD (DE),A
000003A2: C9		RET


;-------------------------------
; Get from memory area ($E0 etc. ???)
;-------------------------------
; Literals $E0 to $FF ???
; A holds $00-$1F offset.
; The calculator stack increases by 5 bytes.

;; get-mem-xx
000003A3: D5		PUSH DE
000003A4: CD 95 1B	CALL 1B95h				; LOC-MEM
000003A7: CD 6F 07	CALL 076Fh				; MOVE-FP
000003AA: E1		POP HL
000003AB: C9		RET

;-------------------------
; THE 'EDITING KEYS' TABLE
;-------------------------
;
;

;; ED-KEYS
000003AC:
		DEFW    1808h           ; Address: UP-KEY
        DEFW    1800h           ; Address: 
        DEFW    1639h           ; Address: 
        DEFW    1654h           ; Address: 
        DEFW    1282h           ; Address: 
        DEFW    0FC7h           ; Address: N/L-KEY
        DEFW    02E3h           ; Address: 
        DEFW    1639h           ; Address: 
        DEFW    127Ch           ; Address: 
        DEFW    0384h           ; Address: 
        DEFW    1073h           ; Address: 

		
;---------------------------------
; THE 'REDUCE ARGUMENT' SUBROUTINE
;---------------------------------
; (offset ??: 'get-argt')
;
; This routine performs two functions on the angle, in radians, that forms
; the argument to the sine and cosine functions.
; First it ensures that the angle 'wraps round'. That if a ship turns through 
; an angle of, say, 3*PI radians (540 degrees) then the net effect is to turn 
; through an angle of PI radians (180 degrees).
; Secondly it converts the angle in radians to a fraction of a right angle,
; depending within which quadrant the angle lies, with the periodicity 
; resembling that of the desired sine value.
; The result lies in the range -1 to +1.              
;
;                     90 deg.
; 
;                     (pi/2)
;              II       +1        I
;                       |
;        sin+      |\   |   /|    sin+
;        cos-      | \  |  / |    cos+
;        tan-      |  \ | /  |    tan+
;                  |   \|/)  |           
; 180 deg. (pi) 0 -|----+----|-- 0  (0)   0 degrees
;                  |   /|\   |
;        sin-      |  / | \  |    sin-
;        cos-      | /  |  \ |    cos+
;        tan+      |/   |   \|    tan-
;                       |
;              III      -1       IV
;                     (3pi/2)
;
;                     270 deg.


;; get-argt
000003C2: F7		RST 30h				; FP-CALC 
000003C3: 05		;;stk-data
000003C4: EE		;;Exponent: $7E, Bytes: 4
000003C5: 22 F9 83 6E						; X, 1/(2*PI)
000003C9: 1F		;;multiply
000003CA: 01		;;duplicate
000003CB: 75		;;stk-half
000003CC: 2A		;;addition
000003CD: 15		;;int
000003CE: 1E		;;subtract				now range -.5 to .5
000003CF: 01		;;duplicate
000003D0: 2A		;;addition				now range -1 to 1.
000003D1: 01		;;duplicate
000003D2: 2A		;;addition				now range -2 to 2.

; quadrant I (0 to +1) and quadrant IV (-1 to 0) are now correct.
; quadrant II ranges +1 to +2.
; quadrant III ranges -2 to -1.

000003D3: 01		;;duplicate				Y, Y.
000003D4: 18		;;abs					Y, abs(Y).    range 1 to 2
000003D5: 79		;;stk-one				Y, abs(Y), 1.
000003D6: 1E		;;subtract				Y, abs(Y)-1.  range 0 to 1
000003D6: 01		;;duplicate				Y, Z, Z.
000003D8: 02		;;greater-0				Y, Z, (1/0).
000003D9: 50		;;st-mem-0				store as possible sign for cosine function.
000003DA: 34		;;jump-true
000003DB: 03		;;to  ZPLUS  with quadrants II and III

; else the angle lies in quadrant I or IV and value Y is already correct.

000003DC: B5		;;delete & end-calc		delete test value.
000003DD: C9		RET

;; ZPLUS
000003DE: 79		;;stk-one				Y, Z, 1
000003DF: 1E		;;subtract				Y, Z-1.       Q3 = 0 to -1
000003E0: 33		;;exchange				Z-1, Y.
000003E1: 03		;;less-0				Z-1, (1/0).
000003E2: 34		;;jump-true				Z-1.
000003E3: 02		;;to YNEG				if angle in quadrant III

; else angle is within quadrant II (-1 to 0)

000003E4: 09		;;negate
;; YNEG
000003E5: 00		;;end-calc
000003E6: C9		RET

; ****************
; ** KEY TABLES **
; ****************

; -------------------------------
; THE 'UNSHIFTED' CHARACTER CODES
; -------------------------------

;; K-UNSHIFT

000003E7:
		; (SHIFT KEY is kept into consideratin by pointing to the key table 1 byte backwords)
        DEFB    $3F             ; Z
        DEFB    $3D             ; X
        DEFB    $28             ; C
        DEFB    $3B             ; V
		
        DEFB    $26             ; A
        DEFB    $38             ; S
        DEFB    $29             ; D
        DEFB    $2B             ; F
        DEFB    $2C             ; G

        DEFB    $36             ; Q
        DEFB    $3C             ; W
        DEFB    $2A             ; E
        DEFB    $37             ; R
        DEFB    $39             ; T

        DEFB    $1D             ; 1
        DEFB    $1E             ; 2
        DEFB    $1F             ; 3
        DEFB    $20             ; 4
        DEFB    $21             ; 5

        DEFB    $1C             ; 0
        DEFB    $25             ; 9
        DEFB    $24             ; 8
        DEFB    $23             ; 7
        DEFB    $22             ; 6

        DEFB    $35             ; P
        DEFB    $34             ; O
        DEFB    $2E             ; I
        DEFB    $3A             ; U
        DEFB    $3E             ; Y

        DEFB    $76             ; NEWLINE
        DEFB    $31             ; L
        DEFB    $30             ; K
        DEFB    $2F             ; J
        DEFB    $2D             ; H

        DEFB    $00             ; SPACE
        DEFB    $1B             ; .
        DEFB    $32             ; M
        DEFB    $33             ; N
        DEFB    $27             ; B


; -----------------------------
; THE 'SHIFTED' CHARACTER CODES
; -----------------------------


;; K-SHIFT
0000040E:
		; (SHIFT KEY is kept into consideratin by pointing to the key table 1 byte backwords)
		DEFB     $F5	; PRINT
		DEFB     $7A	; "LINE NO"
		DEFB     $70	; cursor-up
		DEFB     $71	; cursor-down

		DEFB     $C6	; ASN
		DEFB     $C7	; ACS
		DEFB     $C8	; ATN
		DEFB     $CA	; EXP
		DEFB     $CE	; ABS

		DEFB     $C3	; SIN
		DEFB     $C4	; COS
		DEFB     $C5	; TAN
		DEFB     $C9	; LOG (LN)
		DEFB     $CD	; SGN

		DEFB     $0F	; "ghost"
		DEFB     $0C	; "spider"
		DEFB     $0E	; "butterfly"
		DEFB     $0D	; $
		DEFB     $0B	; "

		DEFB     $14	; =
		DEFB     $11	; )
		DEFB     $10	; (
		DEFB     $1A	; ,
		DEFB     $19	; ;

		DEFB     $12	; >
		DEFB     $13	; <
		DEFB     $45	; PI
		DEFB     $43	; RND
		DEFB     $CC	; SQR

		DEFB     $74	; GL  (enter / exit graphics mode)
		DEFB     $15	; +
		DEFB     $16	; -
		DEFB     $17	; *
		DEFB     $18	; /

		DEFB     $79	; BREAK
		DEFB     $77	; DELETE (rubout)
		DEFB     $75	; EDIT
		DEFB     $73	; cursor-right
		DEFB     $72	; cursor-left



; -------------------------------
; THE 'PREPARE TO ADD' SUBROUTINE
; -------------------------------
; This routine is called twice to prepare each floating point number for
; addition, in situ, on the calculator stack.
; The exponent is picked up from the first byte which is then cleared to act
; as a sign byte and accept any overflow.
; If the exponent is zero then the number is zero and an early return is made.
; The now redundant sign bit of the mantissa is set and if the number is 
; negative then all five bytes of the number are twos-complemented to prepare 
; the number for addition.
; On the second invocation the exponent of the first number is in B.


;; PREP-ADD
00000435: 7E		LD A,(HL)
00000436: B7		OR A
00000437: C8		RET Z
00000438: 36 00		LD (HL),00h		; make this byte zero to take any overflow and default to positive.
0000043A: 23		INC HL			; point to first byte of mantissa.
0000043B: CB 7E		BIT 7,(HL)		; test the sign bit.
0000043D: CB FE		SET 7,(HL)		; set it to its implied state.
0000043F: 2B		DEC HL			; set pointer to first byte again.
00000440: C8		RET Z			; return if bit indicated number is positive.>>

; if negative then all five bytes are twos complemented starting at LSB.

0000441: C5		PUSH BC
00000442: 01 05 00	LD BC,0005h
00000445: 09		ADD HL,BC		; point to location after 5th byte.
00000446: 41		LD B,C			; set the B counter to five.
00000447: 4F		LD C,A			; store original exponent in C.

; now enter a loop to twos-complement the number.
; The first of the five bytes becomes $FF to denote a negative number.

;; NEG-BYTE

00000448: 2B		DEC HL
00000449: 3E 00		LD A,00h
0000044B: 9E		SBC (HL)
0000044C: 77		LD (HL),A
0000044D: 10 F9		DJNZ -07h
0000044F: 79		LD A,C
00000450: C1		POP BC
00000451: C9		RET


;-------------------------------
; THE 'EXPAND TOKENS' SUBROUTINE
;-------------------------------
;
;

;; TOKENS
00000452: CB 77		BIT 6,A
00000454: 28 5E		JR Z,+5Eh
00000456: E5		PUSH HL
00000457: B7		OR A
00000458: F2 5D 04	JP P,045Dh

0000045B: E6 3F		AND 3Fh
0000045D: 21 81 05	LD HL,0581h				; Address of TOKENS
00000460: FE 49		CP 49h
00000462: 30 09		JR NC,+09h
00000464: 3C		INC A					; skip first token ('.', used for all non-existing keywords)
00000465: 47		LD B,A					; get token code
;; WORDS
00000466: 7E		LD A,(HL)
00000467: 23		INC HL
00000468: 17		RLA						; 
00000469: 30 FB		JR NC,-05h				; loop to WORDS until word-end marker is found 

0000046B: 10 F9		DJNZ -07h				; to WORDS


0000046D: CB 76		BIT 6,(HL)
0000046F: 20 08		JR NZ,+08h				; to COMP-FLAG

00000471: FD CB 1E 46	BIT 0,(IY+1Eh)		; BREG/FLAGS
00000475: 28 02		JR Z,+02h

00000477: AF		XOR A					; leading SPACE
00000478: DF		RST 18h					; PRINT-A
00000479: 7E		LD A,(HL)				; pick character from TOKEN table
0000047A: E6 3F		AND 3Fh					; mask leftmost bit (word termination)
0000047C: DF		RST 18h					; PRINT-A
0000047D: 7E		LD A,(HL)				; pick character again
0000047E: 23		INC HL					; increment ptr to TOKEN table
0000047F: 87		ADD A					; shift left
00000480: 30 F7		JR NC,-09h				; loop until word-end marker is found

00000482: E1		POP HL
00000483: F8		RET M
00000484: AF		XOR A
00000485: 18 2D		JR +2Dh
00000487: 0E FF		LD C,FFh
00000489: E5		PUSH HL
0000048A: EB		EX DE,HL
0000048B: 11 18 FC	LD DE,FC18h
0000048E: CD A2 04	CALL 04A2h
00000491: 11 9C FF	LD DE,FF9Ch
00000494: CD A2 04	CALL 04A2h
00000497: 1E F6		LD E,F6h
00000499: CD A2 04	CALL 04A2h
0000049C: 7D		LD A,L
0000049D: CD B1 04	CALL 04B1h
000004A0: E1		POP HL
000004A1: C9		RET
000004A2: AF		XOR A
000004A3: 19		ADD HL,DE
000004A4: 3C		INC A
000004A5: 38 FC		JR C,-04h
000004A7: ED 52		SBC HL,DE
000004A9: 3D		DEC A
000004AA: 20 05		JR NZ,+05h
000004AC: 79		LD A,C
000004AD: B7		OR A
000004AE: F8		RET M
000004AF: 18 0E		JR +0Eh

000004B1: 0E 1C		LD C,1Ch
000004B3: 81		ADD C


;; PRINT-A

000004B4: FD CB 1E C6	SET 0,(IY+1Eh)				; BREG/FLAGS
000004B8: B7		OR A
000004B9: 20 04		JR NZ,+04h
;; PRINT-CH
000004BB: FD CB 1E 86	RES 0,(IY+1Eh)				; BREG/FLAGS

;; PRINT-SP
000004BF: D9		EXX
000004C0: E5		PUSH HL
000004C1: FD CB 1E 4E	BIT 1,(IY+1Eh)	; test 	BREG/FLAGS - is printer in use ?
000004C5: 20 06		JR NZ,+06h			; to LPRINT-A
000004C7: CD 64 14	CALL 1464h
000004CA: E1		POP HL
000004CB: D9		EXX
000004CC: C9		RET

;; LPRINT-A
000004CD: CD D2 1C	CALL 1CD2h			; routine LPRINT-CH
000004D0: 18 F8		JR -08h

000004D2: 7E		LD A,(HL)
000004D3: 23		INC HL
000004D4: E6 7F		AND 7Fh
000004D6: 18 D9		JR -27h

000004D8: ED 5B 18 40	LD DE,(4018h)		; X_PTR
;; MORE-LINE
000004DC: B7		OR A
000004DD: ED 52		SBC HL,DE
000004DF: 19		ADD HL,DE
000004E0: 28 13		JR Z,+13h

000004E2: CD F6 18	CALL 18F6h			; routine NUMBER
000004E5: 23		INC HL				; 
000004E6: 28 F4		JR Z,-0Ch			; to MORE-LINE

000004E8: FE 76		CP 76h
000004EA: 28 C8		JR Z,-38h			; to PRINT-A (OUT-CH)

000004EC: FE 7F		CP 7Fh				; compare to cursor character.
000004EE: 28 1D		JR Z,+1Dh			; to OUT-CURS

000004F0: CD 52 04	CALL 0452h			; routine TOKENS
000004F3: 18 E7		JR -19h				; to MORE-LINE
;
000004F5: 3E 2A		LD A,2Ah
000004F7: CD 1B 05	CALL 051Bh			; CURSOR BACKSPACE
000004FA: 3E 7F		LD A,7Fh
000004FC: BE		CP (HL)				; compare to cursor character.
000004FD: 28 E6		JR Z,-1Ah

;; EXPAND-1
000004FF: 01 01 00	LD BC,0001h
00000502: CD B8 1C	CALL 1CB8h			; MAKE-ROOM + 3  (don't check for free space)
00000505: EB		EX DE,HL

;; WRITE-CH
00000506: 77		LD (HL),A
00000507: 23		INC HL
00000508: CD B0 0B	CALL 0BB0h				; ALERT BEEP
0000050B: 18 CB		JR -35h

;; OUT-CURS
0000050D: AF		XOR A
0000050E: FD CB 3B 66	BIT 4,(IY+3Bh)		; CDFLAG
00000512: 28 02		JR Z,+02h
00000514: 3E 2C		LD A,2Ch
00000516: CD 1B 05	CALL 051Bh				; CURSOR BACKSPACE
00000519: 18 C1		JR -3Fh

;; CURSOR BACKSPACE
0000051B: CD BF 04	CALL 04BFh				; PRINT-SP
0000051E: ED 4B 0E 40	LD BC,(400Eh)		; DF_CC
00000522: 0B		DEC BC
00000523: ED 43 7B 40	LD (407Bh),BC		; BLINK
00000527: C9		RET

;------------
; Signum ()
;------------
; This routine replaces the last value on the calculator stack,
; which is in floating point form, with one if positive and with -minus one
; if negative. If it is zero then it is left as such.

;; sgn
00000528: 7E		LD A,(HL)				; pick up the byte with the sign bit.
00000529: B7		OR A					
0000052A: 23		INC HL					; point to first byte of 4-byte mantissa.
0000052B: 7E		LD A,(HL)
0000052C: 2B		DEC HL
0000052D: C4 82 0C	CALL NZ,0C82h			; routine FP-0/1  replaces last value with one
00000530: 17		RLA						; rotate original sign bit to carry.
00000531: 23		INC HL					; point to first byte of 4-byte mantissa.
00000532: CB 1E		RR (HL)					; rotate the carry into sign.
00000534: 2B		DEC HL					; point to last value.
00000535: C9		RET

00000536: 03		INC BC
00000537: 23		INC HL
00000538: 7E		LD A,(HL)
; -------------------------
; THE 'ALPHANUM' SUBROUTINE
; -------------------------

;; ALPHANUM
00000539: FE 1C		CP 1Ch
0000053B: D8		RET C
0000053C: FE 40		CP 40h
0000053E: 3F		CCF
0000053F: C9		RET

;----------------
; USR number ()
;----------------
; The USR function followed by a number 0-65535 is the method by which
; the ZX81 invokes machine code programs. This function returns the
; contents of the BC register pair.
; Note. on LAMBDA that STACK-BC does NOT re-initializes the IY register to $4000 

;; usr-no
00000540: CD 09 15	CALL 1509h				; FIND-INT
00000543: 11 7E 07	LD DE,077Eh				; STACK-BC
00000546: D5		PUSH DE
00000547: C5		PUSH BC
00000548: C9		RET

;-------------------------------------
; THE 'FLOATING-POINT TO A' SUBROUTINE
;-------------------------------------
;
;

;; FP-TO-A
00000549: CD 55 05	CALL 0555h			; routine FP-TO-BC
0000054C: D8		RET C
0000054D: F5		PUSH AF
0000054E: 78		LD A,B
0000054F: B7		OR A
00000550: 28 2C		JR Z,+2Ch			; jp forward if in range
00000552: F1		POP AF				; fetch result
00000553: 37		SCF					; set carry flag signaling overflow
00000554: C9		RET


;--------------------------------------
; THE 'FLOATING-POINT TO BC' SUBROUTINE
;--------------------------------------
; The floating-point form on the calculator stack is compressed directly into
; the BC register rounding up if necessary.
; Valid range is 0 to 65535.4999

;; FP-TO-BC
0000555: E7		RST 20h					; routine STK-FETCH - exponent to A mantissa to EDCB.
00000556: B7		OR A				; test for value zero.
00000557: FA 5C 05	JP M,055Ch

0000055A: 3E 7F		LD A,7Fh
0000055C: FE 91		CP 91h
0000055E: 3F		CCF
0000055F: D8		RET C
00000560: CB 7B		BIT 7,E				; Bit 7 of E is the 17th bit which will be significant for rounding ..
00000562: F5		PUSH AF				; 
00000563: CB FB		SET 7,E				; ..if the number is already normalized.
00000565: 2F		CPL					; 
00000566: C6 91		ADD 91h				; 
00000568: A7		AND A				; reset CY
00000569: 47		LD B,A
0000056A: 28 06		JR Z,+06h
0000056C: CB 3B		SRL E
0000056E: CB 1A		RR D
00000570: 10 FA		DJNZ -06h
00000572: 43		LD B,E
00000573: 4A		LD C,D
00000574: 30 05		JR NC,+05h
00000576: 03		INC BC
00000577: 79		LD A,C
00000578: B0		OR B
00000579: 28 D7		JR Z,-29h
0000057B: CD ED 18	CALL 18EDh		; STK-PNTRS
0000057E: F1		POP AF
0000057F: 79		LD A,C
00000580: C9		RET

; ------------------
; THE 'TOKEN' TABLES
; ------------------

;; TOKENS
00000581:        DEFB    $1B+$40+$80                         ; .  (printed for all non-existing keywords)
00000582:        DEFB    $28+$40,$34,$29,$2A+$80             ; CODE  (192)
00000586:        DEFB    $3B+$40,$26,$31+$80                 ; VAL
00000589:        DEFB    $31+$40,$2A,$33+$80                 ; LEN
0000058C:        DEFB    $38+$40,$2E,$33+$80                 ; SIN		
0000058F:        DEFB    $28+$40,$34,$38+$80                 ; COS		
00000592:        DEFB    $39+$40,$26,$33+$80                 ; TAN		
00000595:        DEFB    $26+$40,$38,$33+$80                 ; ASN
00000598:        DEFB    $26+$40,$28,$38+$80                 ; ACS   (199)
0000059B:        DEFB    $26+$40,$39,$33+$80                 ; ATN
0000059E:        DEFB    $31+$40,$34,$2C+$80                 ; LOG  (was LN on ZX81)
000005A1:        DEFB    $2A+$40,$3D,$35+$80                 ; EXP
000005A4:        DEFB    $2E+$40,$33,$39+$80                 ; INT
000005A7:        DEFB    $38+$40,$36,$37+$80                 ; SQR
000005AA:        DEFB    $38+$40,$2C,$33+$80                 ; SGN
000005AD:        DEFB    $26+$40,$27,$38+$80                 ; ABS
000005B0:        DEFB    $35+$40,$2A,$2A,$30+$80             ; PEEK
000005B4:        DEFB    $3A+$40,$38,$37+$80                 ; USR
000005B7:        DEFB    $38+$40,$39,$37,$0D+$80             ; STR$
000005BB:        DEFB    $28+$40,$2D,$37,$0D+$80             ; CHR$
000005BF:        DEFB    $33+$40,$34,$39+$80                 ; NOT  (211)

000005C2:        DEFB    $26,$39+$80                         ; AT   -- first char is not bit-tagged
000005C4:        DEFB    $39+$40,$26,$27+$80                 ; TAB

000005C7:        DEFB    $17+$40,$17+$40+$80                 ; **   ! mind the odd bit-tags !
000005C9:        DEFB    $34,$37+$80                         ; OR   -- first char is not bit-tagged
000005CB:        DEFB    $26,$33,$29+$80                     ; AND  -- first char is not bit-tagged
000005CE:        DEFB    $13+$40,$14+$40+$80                 ; <=	! mind the odd bit-tags !
000005D0:        DEFB    $12+$40,$14+$40+$80                 ; >=	! mind the odd bit-tags !
000005D2:        DEFB    $13+$40,$12+$40+$80                 ; <>	! mind the odd bit-tags !  (219)

;; in the next token group the first char is not bit-tagged
;;----------------------------------------------------------------------------

000005D4:        DEFB    $39,$2A,$32,$35,$34+$80             ; TEMPO
000005D9:        DEFB    $32,$3A,$38,$2E,$28+$80             ; MUSIC
000005DE:        DEFB    $3A,$34,$3A,$33,$29+$80             ; SOUND
000005E3:        DEFB    $27,$2A,$2A,$35+$80                 ; BEEP
000005E7:        DEFB    $33,$34,$27,$2A,$2A,$35+$80         ; NOBEEP

000005ED:        DEFB    $31,$35,$37,$2E,$33,$39+$80     ; LPRINT
000005F3:        DEFB    $31,$31,$2E,$38,$39+$80         ; LLIST
000005F8:        DEFB    $38,$39,$34,$35+$80             ; STOP
000005FC:        DEFB    $38,$31,$34,$3C+$80             ; SLOW
00000600:        DEFB    $2B,$26,$38,$39+$80             ; FAST
00000604:        DEFB    $33,$2A,$3C+$80                 ; NEW
00000607:        DEFB    $38,$28,$37,$34,$31,$31+$80     ; SCROLL
0000060D:        DEFB    $28,$34,$33,$39+$80             ; CONT
00000611:        DEFB    $29,$2E,$32+$80                 ; DIM
00000614:        DEFB    $37,$2A,$32+$80                 ; REM
00000617:        DEFB    $2B,$34,$37+$80                 ; FOR
0000061A:        DEFB    $2C,$34,$39,$34+$80             ; GOTO
0000061E:        DEFB    $2C,$34,$38,$3A,$27+$80         ; GOSUB
00000623:        DEFB    $2E,$33,$35,$3A,$39+$80         ; INPUT
00000628:        DEFB    $31,$34,$26,$29+$80             ; LOAD
0000062C:        DEFB    $31,$2E,$38,$39+$80             ; LIST
00000630:        DEFB    $31,$2A,$39+$80                 ; LET
00000633:        DEFB    $35,$26,$3A,$38,$2A+$80         ; PAUSE
00000638:        DEFB    $33,$2A,$3D,$39+$80             ; NEXT
0000063C:        DEFB    $35,$34,$30,$2A+$80             ; POKE
00000640:        DEFB    $35,$37,$2E,$33,$39+$80         ; PRINT
00000645:        DEFB    $35,$31,$34,$39+$80             ; PLOT
00000649:        DEFB    $37,$3A,$33+$80                 ; RUN
0000064C:        DEFB    $38,$26,$3B,$2A+$80             ; SAVE
00000650:        DEFB    $37,$26,$33,$29+$80             ; RAND
00000654:        DEFB    $2E,$2B+$80                     ; IF
00000656:        DEFB    $28,$31,$38+$80                 ; CLS
00000659:        DEFB    $3A,$33,$35,$31,$34,$39+$80     ; UNPLOT
0000065F:        DEFB    $28,$31,$2A,$26,$37+$80         ; CLEAR
00000664:        DEFB    $37,$2A,$39,$3A,$37,$33+$80     ; RETURN
0000066A:        DEFB    $28,$34,$35,$3E+$80             ; COPY     (255)

0000066E:        DEFB    $39,$2D,$2A,$33+$80             ; THEN		(64)
00000671:        DEFB    $39,$34+$80                     ; TO		(65)
00000674:        DEFB    $38,$39,$2A,$35+$80             ; STEP

;;----------------------------------------------------------------------------

00000678:        DEFB    $37+$40,$33,$29+$80                     ; RND      ! mind the odd bit-tags !
0000067B:        DEFB    $2E+$40,$33,$30,$2A,$3E,$0D+$40+$80     ; INKEY$   ! mind the odd bit-tags !
00000681:        DEFB    $35+$40,$2E+$40+$80                     ; PI


000005A4:        DEFB    $2E,$33,$30+$80                         ; INK
00000686:        DEFB    $35,$26,$35,$2A,$37+$80                 ; PAPER
0000068A:        DEFB    $27,$34,$37,$29,$2A,$37+$80             ; BORDER   (72)


00000691: CD A2 06	CALL 06A2h				; SET-FIELD
00000694: C6 10		ADD 10h
00000696: E6		AND 10h
00000697: 4F		LD C,A

00000699: AF		XOR A					; SPACE
0000069A: DF		RST 18h					; PRINT-A

0000069B: CD A2 06	CALL 06A2h				; SET-FIELD
0000069E: B9		CP C
0000069F: 20 F8		JR NZ,-08h
000006A1: C9		RET

;; SET-FIELD
000006A2: FD CB 1E 4E	BIT 1,(IY+1Eh)		; BREG/FLAGS  - Is printer in use
000006A6: 20 09		JR NZ,+09h				; to NO_CENTRE

000006A8: 3A 39 40	LD A,(4039h)	; S_POSN_x
000006AB: 2F		CPL
000006AC: C6 22		ADD 22h

; ; ;
000006AE: E6 1F		AND 1Fh
000006B0: C9		RET

;; NO_CENTRE
000006B1: 3A 38 40	LD A,(4038h)		; PR_CC
000006B4: D6 3C		SUB 3Ch
000006B6: 18 F6		JR -0Ah	

000006B8: 21 CC 02	LD HL,02CCh
000006BB: 87		ADD A
000006BC: 5F		LD E,A
000006BD: 19		ADD HL,DE
000006BE: 4E		LD C,(HL)
000006BF: 23		INC HL
000006C0: 46		LD B,(HL)
000006C1: C5		PUSH BC


;; LEFT-EDGE
000006C2: 2A 14 40	LD HL,(4014h)		; E_LINE
000006C5: 3E 7F		LD A,7Fh
000006C7: BE		CP (HL)
000006C8: C8		RET Z
000006C9: 23		INC HL
000006CA: 18 FB		JR -05h

;; INK
000006CC: CD FF 14	CALL 14FFh			; STK-TO-A
000006CF: 0E 0F		LD C,0Fh			; INK mask
;; ATTR-SET
000006D1: 21 08 40	LD HL,4008h			; ATTR-P
;; UPD-COLOR
000006D4: AE		XOR (HL)
000006D5: A1		AND C
000006D6: AE		XOR (HL)
000006D7: 77		LD (HL),A
000006D8: C9		RET

;; PAPER
000006D9: CD FF 14	CALL 14FFh			; STK-TO-A
000006DC: 17		RLA
000006DD: 17		RLA
000006DE: 17		RLA
000006DF: 17		RLA
000006E0: 0E F0		LD C,F0h			; PAPER mask
000006E2: 18 ED		JR -13h				; to ATTR-SET

;; BORDER
000006E4: CD FF 14	CALL 14FFh			; STK-TO-A
000006E7: 17		RLA
000006E8: 17		RLA
000006E9: 17		RLA
000006EA: 17		RLA
; entry used while booting
000006EB: 21 7D 20	LD HL,207Dh
000006EE: 77		LD (HL),A
000006EF: 23		INC HL
000006F0: 11 21 00	LD DE,0021h			; 33 bytes (=1 display row)
000006F3: 06 19		LD B,19h			; loop 25 times
000006F5: 77		LD (HL),A
000006F6: 19		ADD HL,DE
000006F7: 10 FC		DJNZ -04h
000006F9: C9		RET


;---------------------------
; THE 'SQUARE ROOT' FUNCTION
;---------------------------
; (Offset ??: 'sqr')
; Error A if argument is negative.
; This routine is remarkable only in its brevity - 6 bytes (1 more byte saved porting from the ZX81 version!!)


;; sqr
000006FA: F7		RST 30h				; FP-CALC
000006FB: 01		;;duplicate
000006FC: 1D		;;not
000006FD: 34		;;jump-true
000006FE: 16		;;to LAST
; else continue to calculate as x ** .5
000006FE: F5		;;stk-half & end-calc


;-------------------------------
; THE 'EXPONENTIATION' OPERATION
;-------------------------------
; (Offset $??: 'to-power')
; This raises the first number X to the power of the second number Y.
; As with the ZX80,
; 0 ** 0 = 1
; 0 ** +n = 0
; 0 ** -n = arithmetic overflow.

;; to-power
00000700: F7		RST 30h				; FP-CALC
00000701: 33		;;exchange
00000702: 01		;;duplicate
00000703: 34		;;jump-true
00000704: 12		

; these routines form the three simple results when the number is zero.
; begin by deleting the known zero to leave Y the power factor.

; continue here if X is zero.

;; XISO
00000705: 35		;;delete
00000706: 01		;;duplicate
00000707: 1D		;;not
00000706: 34		;;jump-true		
00000709: 09		
0000070A: 7A		;;stk-zero		
0000070B: 33		;;exchange
0000070C: 02		;;greater-0
0000070D: 34		;;jump-true
0000070E: 06		;;to L1DFD, LAST        if Y was any positive number

; else force division by zero thereby raising an Arithmetic overflow error.

0000070F: 79		;;stk-one			0, 1.
00000710: 33		;;exchange			1, 0.
00000711: 20		;;division			1/0    >> error 

; ---

;; ONE
00000712: 35		;;delete
00000713: 79		;;stk-one

;; LAST
00000714: 00		;;end-calc
00000715: C9		RET

; else X is non-zero. function 'ln' will catch a negative value of X.

00000716: 13		;;ln
00000717: 9F		;;multiply & end-calc


;-----------------
; Exponential
;-----------------
;

;; exp
00000718: F7		RST 30h				; FP-CALC
00000719: 05		;;stk-data
0000071A: F1		;;Exponent: $81, Bytes: 4
0000071B: 38 AA	3B 29
0000071F: 1F		;;multiply
00000720: 01		;;duplicate
00000721: 15		;;int
00000722: 5F		;;st-mem-3
00000723: 1E		;;subtract
00000724: 01		;;duplicate
00000725: 2A		;;addition
00000726: 79		;;stk-one
00000727: 1E		;;subtract
00000728: 68		;;series-08
00000729: 13		;;Exponent: $63, Bytes: 1
0000072A: 36		;;(+00,+00,+00)
0000072B: 58		;;Exponent: $68, Bytes: 2
0000072C: 65 66		;;(+00,+00)
0000072E: 9D		;;Exponent: $6D, Bytes: 3
0000072F: 78 65 40	;;(+00)
00000732: A2		;;Exponent: $72, Bytes: 3
00000733: 60 32 C9	;;(+00)
00000736: E7		;;Exponent: $77, Bytes: 4
00000737: 21 F7 AF 24	;;
0000073B: EB		;;Exponent: $7B, Bytes: 4
0000073C: 2F B0 B0 14	;;
00000740: EE		;;Exponent: $7E, Bytes: 4
00000741: 7E BB 94 58	;;
00000745: F1		;;Exponent: $81, Bytes: 4
00000746: 3A 7E F8 CF	;;
0000074A: CF		;;get-mem-3 & end-calc

0000074B: CD 49 05	CALL 0549h			; FP-TO-A
0000074E: 28 0D		JR Z,+0Dh

;; N-NEGTV
00000750: 30 04		JR NC,+04h

;; RSLT-ZERO
00000752: F7		RST 30h				; FP-CALC
00000753: 35		;;delete
00000754: FA		;;stk-zero & end-calc
00000755: C9		RET

00000756: 96		SUB (HL)
00000757: 30 F9		JR NC,-07h			; to RSLT-ZERO
00000759: ED 44		NEG					; Negate

;; RESULT-OK
0000075B: 77		LD (HL),A
0000075C: C9		RET

0000075D: 38 03		JR C,+03h			; to REPORT-6b

0000075F: 86		ADD (HL)
00000760: 30 F9		JR NC,-07h			; to RESULT-OK

;; REPORT-6b - number too big
00000762: C3 23 17	JP 1723h

00000765: FD CB 3B AE	RES 5,(IY+3Bh)		; CDFLAG
00000769: C9		RET

0000076A: FD CB 3B EE	SET 5,(IY+3Bh)		; CDFLAG
0000076E: C9		RET

;----------------------------------
; Move a floating point number (2D)
;----------------------------------
; This simple routine is a 5-byte LDIR instruction
; that incorporates a memory check.
; When used as a calculator literal it duplicates the last value on the
; calculator stack.
; Unary so on entry HL points to last value, DE to stkend

;; duplicate
;; MOVE-FP
0000076F: CD F2 13	CALL 13F2h				; routine TEST-5-SP
00000772: ED B0		LDIR
00000774: C9		RET

;; STK-DIGIT
00000775: CD 54 1C	CALL 1C54h				; routine ALPHA
00000778: D8		RET C

; ------------------------
; THE 'STACK-A' SUBROUTINE
; ------------------------
;

;; STACK-A
00000779: 06 00		LD B,00h
0000077B: 4F		LD C,A
0000077C: FE E7		CP E7h

;---------------------
; THE 'LEN' SUBROUTINE
;---------------------
; (offset $1b: 'len')
; Returns the length of a string.
; In Sinclair BASIC strings can be more than twenty thousand characters long
; so a sixteen-bit register is required to store the length

;; len
;; THIS IS THE SAME BYTE ALREADY USED BY THE CODE ABOVE !!
0000077D: E7		RST 20h				; routine STK-FETCH to fetch and delete the string parameters
										; from the calculator stack.  Register BC now holds the length of string.

; continue to STACK-BC to save result on the calculator stack (with memory check).
										
; -------------------------
; THE 'STACK-BC' SUBROUTINE
; -------------------------
; The ZX81 does not have an integer number format so the BC register contents
; must be converted to their full floating-point form.

;; STACK-BC
0000077E: C5		PUSH BC
0000077F: F7		RST 30h				; FP-CALC
00000780: FA		;;stk-zero & end-calc

00000781: C1		POP BC			; restore integer value.

00000782: 79		LD A,C
00000783: B0		OR B
00000784: C8		RET Z			; return if BC was zero - done.

00000785: 36 90		LD (HL),90h		; place $90 in exponent (was 91h on ZX81)
00000787: CB 78		BIT 7,B
00000789: 20 07		JR NZ,+07h
0000078B: 35		DEC (HL)
0000078C: CB 21		SLA C
0000078E: CB 10		RL B
00000790: 18 F5		JR -0Bh
00000792: 23		INC HL
00000793: CB B8		RES 7,B
00000795: 70		LD (HL),B
00000796: 23		INC HL
00000797: 71		LD (HL),C
00000798: C9		RET


;--------------------------
; Handle PEEK function
;--------------------------
; This function returns the contents of a memory address.
; The entire address space can be peeked including the ROM.

;; peek
00000799: CD 09 15	CALL 1509h				; FIND-INT
0000079C: 0A		LD A,(BC)
0000079D: 18 DA		JR -26h					; exit via STACK-A to put value on the  calculator stack

;--------------------
; THE 'CODE' FUNCTION
;--------------------
; Returns the code of a character or first character of a string
; e.g. CODE "AARDVARK" = 38  (not 65 as the ZX81 does not have an ASCII character set).

;; code
0000079F: E7		RST 20h				; routine STK-FETCH to fetch and delete the string parameters
000007A0: 79		LD A,C				; test length
000007A1: B0		OR B				; of the string
000007A2: 28 DA		JR Z,-26h			; skip to STK-CODE with zero if the null string.

000007A4: 1A		LD A,(DE)			; else fetch the first character.
000007A5: 18 D2		JR -2Eh				; jump to STACK-A (with memory check)

;; E-FORMAT
000007A7: FE 42		CP 42h				; is character 'E' ?
000007A9: 28 07		JR Z,+07h			

;; F-USE-ONE
000007AB: CD 3B 0A	CALL 0A3Bh			; routine CHECK-END
000007AE: F7		RST 30h				; FP-CALC
000007AF: F9		;;stk-one & end-calc

000007B0: 18 06		JR +06h				; to F-REORDER

000007B2: CD 10 0A	CALL 0A10h
000007B5: CD 3B 0A	CALL 0A3Bh			; routine CHECK-END

;; F-REORDER
000007B8: F7		RST 30h				; FP-CALC
000007B9: 50		;;st-mem-0
000007BA: 35		;;delete
000007BB: 33		;;exchange
000007BC: 40		;;get-mem-0
000007BD: B3		;;exchange & end-calc

000007BE: CD F8 00	CALL 00F8h			; routine LET
000007C1: 01 06 00	LD BC,0006h
000007C4: 2B		DEC HL				; point to letter.
000007C5: CB 7E		BIT 7,(HL)
000007C7: CB FE		SET 7,(HL)
000007C9: 09		ADD HL,BC
000007CA: 20 06		JR NZ,+06h			; F-LMT-STP

000007CC: 0E 0C		LD C,0Ch
000007CE: CD B5 1C	CALL 1CB5h			; routine MAKE-ROOM
000007D1: 23		INC HL

;; F-LMT-STP
000007D2: E5		PUSH HL

000007D3: F7		RST 30h				; FP-CALC
000007D4: 35		;;delete
000007D5: B5		;;delete & end-calc

000007D6: EB		EX DE,HL
000007D7: 0E 0A		LD C,0Ah			; ten bytes to be moved.
000007D9: D1		POP DE
000007DA: ED B0		LDIR				; copy bytes
000007DC: 2A 36 40	LD HL,(4036h)		; LAMBDA-VAR
000007DF: 23		INC HL
000007E0: EB		EX DE,HL
000007E1: 73		LD (HL),E
000007E2: 23		INC HL
000007E3: 72		LD (HL),D
000007E4: C9		RET

; ERR-MSG table
000007E5: 34 30		; "OK"
000007E7: 38 39		; 0,"ST" - STOP statement executed
000007E9: 27 30		; 1,"BK" - BREAK Key pressed
000007EB: 38 2B		; 2,"SF" - Screen Full
000007ED: 34 32		; 3,"OM" - Out of memory
000007EF: 33 2B		; 4,"NF" - NEXT without FOR
000007F1: 34 3B		; 5,"OV" - Number overflow
000007F3: 37 2C		; 6,"RG" - RETURN without GOSUB
000007F5: 2E 2E		; 7,"II" - Illegal Input
000007F7: 3A 3B		; 8,"UV" - Undefined Variable
000007F9: 26 2C		; 9,"AG" - Invalid Argument
000007FB: 2E 37		; A,"IR" - Integer out of Range
000007FD: 2E 2A		; B,"IE" - Invalid Expression
000007FF: 27 38		; C,"BS" - Bad Subscript
00000801: 33 26		; D,"NA" - Invalid program name
00000803: 32 2B		; E,"MF" - Incorrect music string format

00000805: CF		RST 08h		; NEXT-CHAR



;--------------------------
; THE 'SCANNING' SUBROUTINE
;--------------------------
; This recursive routine is where the ZX81 gets its power. Provided there is
; enough memory it can evaluate an expression of unlimited complexity.
; Note. there is no unary plus so, as on the ZX80, PRINT +1 gives a syntax error.
; PRINT +1 works on the Spectrum but so too does PRINT + "STRING".

;; SCANNING
00000806: 06 00		LD B,00h
00000808: D7		RST 10h					; GET-CHAR

00000809: FE CF		CP CFh					; 'PEEK'
0000080B: C5		PUSH BC					; stack zero as a priority end-marker.
0000080C: 01 C9 09	LD BC,09C9h
0000080F: FE 16		CP 16h					; is character '-' ?
00000811: 28 F7		JR Z,-09h

00000813: 01 DD 04	LD BC,04DDh				; prepare priority $04, operation 'not'
00000816: FE D3		CP D3h					; 'NOT'
00000818: 28 F0		JR Z,-10h				; 

0000081A: 30 25		JR NC,+25h				; jp with anything higher to S-RPT-C  (report C)

; else is a function '??' thru '??'

0000081C: FE C0		CP C0h					;
0000081E: 38 13		JR C,+13h

00000820: C6 0A		ADD 0Ah	
00000822: 06 10		LD B,10h				; priority sixteen binds all functions to arguments removing the need for brackets
00000824: FE CD		CP CDh					;
00000826: 30 02		JR NC,+02h

00000828: E6 BF		AND BFh
0000082A: FE DB		CP DBh					;
0000082C: 38 02		JR C,+02h

0000082E: E6 7F		AND 7Fh
00000830: 4F		LD C,A
00000831: 18 D7		JR -29h
00000833: FE 0B		CP 0Bh
00000835: 20 15		JR NZ,+15h

;; S-Q-AGAIN
00000837: E5		PUSH HL
00000838: CF		RST 08h					; NEXT-CHAR
00000839: FE 0B		CP 0Bh
0000083B: 28 07		JR Z,+07h
0000083D: FE 76		CP 76h					; compare to NEWLINE

0000083F: 20 F7		JR NZ,-09h				; loop back if not to S-Q-AGAIN

;; S-RPT-C
00000841: C3 42 0A	JP 0A42h				; to REPORT-C

00000844: D1		POP DE					; * retrieve start of string
00000845: 13		INC DE					;
00000846: ED 52		SBC HL,DE				; subtract start from current position
00000848: 4D		LD C,L					; transfer this length
00000849: 44		LD B,H					; to the BC register pair
0000084A: 18 13		JR +13h					; to S-STRING

; ---

;; S-TST-INK
0000084C: FE 44		CP 44h					; compare to character 'INKEY$'
0000084E: 20 19		JR NZ,+19h				; forward, if not, to S-ALPHANUM

; -----------------------
; THE 'INKEY$' EVALUATION
; -----------------------

00000850: CD 74 0D	CALL 0D74h				; routine KEYBOARD
00000853: 55		LD D,L
00000854: 14		INC D
00000855: 4D		LD C,L
00000856: 44		LD B,H
00000857: C4 77 18	CALL NZ,1877h			; routine DECODE
0000085A: EB		EX DE,HL
0000085B: 44		LD B,H
0000085C: 4C		LD C,H
0000085D: CB 11		RL C

;; S-STRING
0000085F: EF		RST 28h					; routine SYNTAX-Z
00000860: C4 BC 13	CALL NZ,13BCh			; in run-time routine STK-STO-$ stacks the string descriptor
00000863: FD CB 1E B6	RES 6,(IY+1Eh)		; BREG/FLAGS - signal string result
00000867: 18 0B		JR +0Bh

;; S-ALPHANUM
00000869: FE 10		CP 10h			; '('
0000086B: 20 0A		JR NZ,+0Ah
0000086D: CD 05 08	CALL 0805h

00000870: FE 11		CP 11h			; ')'
00000872: 20 CD		JR NZ,-33h		; jp if not to S-RPT-C (report C)

00000874: C3 FB 08	JP 08FBh		; jp to  NEXT-CHAR, S-JP-CONT3 and then S-CONT3



00000877: CD 39 05	CALL 0539h		; routine ALPHANUM
0000087A: 38 18		JR C,+18h

;; S-LTR-DGT
0000087C: FE 26		CP 26h			; compare to 'A'.
0000087E: 38 18		JR C,+18h		; forward if less to S-DECIMAL

00000880: CD AE 0A	CALL 0AAEh		; LOOK-VARS-B
00000883: DA 0C 0A	JP C,0A0Ch		; to REPORT-2
00000886: CC F0 0D	CALL Z,0DF0h	; routine STK-VAR stacks string parameters or
									; returns cell location if numeric.

00000889: 3E BF		LD A,BFh
0000088B: FD BE 1E	CP (IY+1Eh)		; BREG/FLAGS
0000088E: DC C7 09	CALL C,09C7h	; update STKEND and MOVE-FP
00000891: D7		RST 10h					; GET-CHAR
00000892: 18 68		JR +68h

00000894: FE 1B		CP 1Bh					; is character a '.' ?
00000896: 20 26		JR NZ,+26h				; jump forward if not

; ---

; The Scanning Decimal routine is invoked when a decimal point or digit is
; found in the expression.
; When checking syntax, then the 'hidden floating point' form is placed
; after the number in the BASIC line.
; In run-time, the digits are skipped and the floating point number is picked
; up.

;; S-DECIMAL
00000898: EF		RST 28h					; routine SYNTAX-Z
00000899: 28 0B		JR Z,+0Bh

; ---

; In run-time the branch is here when a digit or point is encountered.

;; S-STK-DEC
0000089B: CF		RST 08h					; NEXT-CHAR
0000089C: FE 7E		CP 7Eh					; compare to 'number marker'
0000089E: 20 FB		JR NZ,-05h				; loop back until found to S-STK-DEC
											; skipping all the digits.
000008A0: CD C7 09	CALL 09C7h				; update STKEND and MOVE-FP to stack the number
000008A3: 2B		DEC HL
000008A4: 18 13		JR +13h

000008A6: CD C1 11	CALL 11C1h				; routine DEC-TO-FP
000008A9: 01 06 00	LD BC,0006h				; six locations are required.
000008AC: D7		RST 10h					; GET-CHAR
000008AD: CD B5 1C	CALL 1CB5h				; routine MAKE-ROOM
000008B0: 23		INC HL					; point to first new location
000008B1: 36 7E		LD (HL),7Eh				; insert the number marker 126 decimal.
000008B3: CD 56 01	CALL 0156h				
000008B6: 0E 04		LD C,04h
000008B8: 09		ADD HL,BC
000008B9: 22 16 40	LD (4016h),HL			; update system variable CH_ADD.
000008BC: 18 39		JR +39h

;; S-TEST-PI
000008BE: FE 45		CP 45h
000008C0: 20 08		JR NZ,+08h

; -------------------
; THE 'PI' EVALUATION
; -------------------

000008C2: EF		RST 28h					; routine SYNTAX-Z
000008C3: 28 32		JR Z,+32h				; forward if checking syntax to S-PI-END
000008C5: F7		RST 30h					; FP-CALC
000008C6: F0		;;stk-pi/2 & end-calc

000008C7: 34		INC (HL)				; double the exponent giving PI on the stack
000008C8: 18 2D		JR +2Dh					; jp to S-PI-END


000008CA: FE 43		CP 43h					; compare to the 'RND' character (was 40h on ZX81)
000008CC: 20 A4		JR NZ,-5Ch				; jp if not

; ------------------
; THE 'RND' FUNCTION
; ------------------

000008CE: EF		RST 28h					; routine SYNTAX-Z
000008CF: 28 26		JR Z,+26h				; forward if checking syntax to ???
000008D1: ED 4B 32 40	LD BC,(4032h)		; SEED
000008D5: CD 7E 07	CALL 077Eh				; routine STACK-BC
000008D8: F7		RST 30h					; FP-CALC
000008D9: 79		;;stk-one
000008DA: 2A 		;;addition
000008DB: 05		;;stk-data
000008DC: 37		;;Exponent: $87, Bytes: 1
000008DD: 16 		;;(+00,+00,+00)
000008DE: 1F		;;multiply
000008DF: 05		;;stk-data
000008E0: 80		;;Bytes: 3
000008E1: 41		;;Exponent $91
000008E2: 00h, 00h ,80h	;;(+00)
000008E5: 06		;;n-mod-m
000008E5: 35		;;delete
000008E7: 79		;;stk-one
000008E8: 1E		;;subtract
000008E9: 81		;;duplicate & end-calc

000008EA: CD 55 05	CALL 0555h				; routine FP-TO-BC
000008ED: ED 43 32 40	LD (4032h),BC		; update the SEED system variable.
000008F1: 7E		LD A,(HL)				; HL addresses the exponent of the last value.
000008F2: D6 10		SUB 10h					; reduce exponent by sixteen (thus dividing by 65536 for last value)
000008F4: 38 01		JR C,+01h
000008F6: 77		LD (HL),A				

;; S-PI-END
;; S-NUMERIC
000008F7: FD CB 1E F6	SET 6,(IY+1Eh)		; BREG/FLAGS - Signal numeric result


000008FB: CF		RST 08h					; NEXT-CHAR advances character pointer.
000008FC: CD 7A 09	CALL 097Ah				; routine SYNTAX-Z
000008FF: 20 09		JR NZ,+09h

;; S-CONT-3
00000901: FE 10		CP 10h					; compare to opening bracket '('
00000903: 20 05		JR NZ,+05h				; forward if not to S-OPERTR

00000905: CD 37 13	CALL 1337h				; routine SLICING
00000908: 18 F1		JR -0Fh


; ---

; the character is now manipulated to form an equivalent in the table of
; calculator literals. This is quite cumbersome and in the ZX Spectrum a
; simple look-up table was introduced at this point.

;; S-OPERTR
0000090A: 01 D5 00	LD BC,00D5h			; prepare operator 'subtract' as default.
0000090D: FE 12		CP 12h				; is character '>' ?
0000090F: 38 1B		JR C,+1Bh			; forward if less to S-LOOP as we have reached end of meaningful expression

00000911: FE 16		CP 16h				; is character '-' ?
00000913: 38 10		JR C,+10h			; forward with - * / and '**' '<>' to SUBMLTDIV

00000915: 0E C8		LD C,C8h
00000917: FE 19		CP 19h				; 'ATN'
00000919: 38 0A		JR C,+0Ah

0000091B: FE D6		CP D6h				; '**'
0000091D: 38 0D		JR C,+0Dh

0000091F: 0E 0B		LD C,0Bh
00000921: FE DC		CP DCh				; 'TEMPO'
00000923: 30 07		JR NC,+07h

; ---

;; SUBMLTDIV

00000925: 81		ADD C
00000926: 4F		LD C,A
00000927: 21 8E 15	LD HL,158Eh				; tbl-pri (166Ch) - DEh: theoretical the base of the priorities table ?
0000092A: 09		ADD HL,BC				; add C ( B is zero)
0000092B: 46		LD B,(HL)				; pick up the priority in B
0000092C: E1		POP HL
0000092D: 7C		LD A,H
0000092E: B8		CP B
0000092F: 30 1B		JR NC,+1Bh
00000931: E5		PUSH HL
00000932: CD 7A 09	CALL 097Ah				; routine SYNTAX-Z
00000935: 20 12		JR NZ,+12h
00000937: 3E C8		LD A,C8h
00000939: 81		ADD C
0000093A: 0E 6B		LD C,6Bh
0000093C: FE AB		CP ABh
0000093E: 28 09		JR Z,+09h
00000940: 38 8A		JR C,-76h
00000942: 0E 32		LD C,32h
00000944: FE B2		CP B2h
00000946: 28 01		JR Z,+01h
00000948: 4F		LD C,A
00000949: C3 0A 08	JP 080Ah
0000094C: B7		OR A
0000094D: 28 2A		JR Z,+2Ah
0000094F: C5		PUSH BC
00000950: 7D		LD A,L
00000951: F5		PUSH AF
00000952: EF		RST 28h					; routine SYNTAX-Z
00000953: 20 16		JR NZ,+16h
00000955: FD AE 1E	XOR (IY+1Eh)			; BREG/FLAGS
00000958: CB 77		BIT 6,A
0000095A: C2 42 0A	JP NZ,0A42h				; to REPORT-C
0000095D: F1		POP AF
0000095E: 21 1E 40	LD HL,401Eh				; BREG/FLAGS

00000961: CB F6		SET 6,(HL)
00000963: 17		RLA
00000964: 38 02		JR C,+02h
00000966: CB B6		RES 6,(HL)
00000968: C1		POP BC
00000969: 18 C1		JR -3Fh
0000096B: E6 3F		AND 3Fh
0000096D: F6 80		OR 80h
0000096F: CD ED 18	CALL 18EDh				; STK-PNTRS
00000972: D9		EXX
00000973: E5		PUSH HL
00000974: 21 5D 09	LD HL,095Dh
00000977: 18 0E		JR +0Eh
00000979: D7		RST 10h					; GET-CHAR

;--------------------------
; THE 'SYNTAX-Z' SUBROUTINE
;--------------------------
; This routine returns with zero flag set if checking syntax.
; Calling this routine uses three instruction bytes compared to four if the
; bit test is implemented inline.

0000097A: FD CB 1E 76	BIT 6,(IY+1Eh)		; BREG/FLAGS
0000097E: C9		RET



;; coming from FP-CALC/CALCULATE/GEN-ENT-2 (continue)

0000097F: D9		EXX						; switch back to main set.

; this is the re-entry looping point when handling a string of literals.
;; RE-ENTRY
00000980: ED 53 1C 40	LD (401Ch),DE		; save end of stack in system variable STKEND
00000984: D9		EXX						; switch to alt
00000985: 7E		LD A,(HL)				; get next literal
00000986: 23		INC HL					; increase pointer'

; single operation jumps back to here (?  to be checked)

00000987: 87		ADD A					;
00000988: 28 36		JR Z,+36h				;  a zeroed opcode means "end-calc"

0000098A: 11 80 09	LD DE,0980h
0000098D: 30 03		JR NC,+03h
0000098F: 11 BF 09	LD DE,09BFh				; GEN-ENT-2 sub
00000992: D5		PUSH DE
00000993: E5		PUSH HL
00000994: FA B0 09	JP M,09B0h
00000997: FE 3C		CP 3Ch
00000999: 38 07		JR C,+07h
0000099B: D9		EXX
0000099C: 5D		LD E,L
0000099D: 54		LD D,H
0000099E: CD F1 18	CALL 18F1h
000009A1: D9		EXX
000009A2: 5F		LD E,A
000009A3: 16 00		LD D,00h
000009A5: 21 F2 0B	LD HL,0BF2h			; tbl-addrs - 2
000009A8: 19		ADD HL,DE
000009A9: 5E		LD E,(HL)
000009AA: 23		INC HL
000009AB: 56		LD D,(HL)
000009AC: E1		POP HL
000009AD: D5		PUSH DE
000009AE: D9		EXX
000009AF: C9		RET

000009B0: 0F		RRCA
000009B1: 57		LD D,A
000009B2: 0F		RRCA
000009B3: 0F		RRCA
000009B4: 0F		RRCA
000009B5: E6 06		AND 06h
000009B7: C6 6C		ADD 6Ch
000009B9: 5F		LD E,A
000009BA: 7A		LD A,D
000009BB: E6 0F		AND 0Fh
000009BD: 18 E4		JR -1Ch

;; GEN-ENT-2 sub
000009BF: D9		EXX

;; end-calc   (slightly different from the ZX81 version which does not embed it)
000009C0: E3		EX HL,(SP)
000009C1: D9		EXX
000009C2: ED 53 1C 40	LD (401Ch),DE		; STKEND

;------------------------
; THE 'DELETE' SUBROUTINE
;------------------------
; offset $??: 'delete'
; A simple return but when used as a calculator literal this
; deletes the last value from the calculator stack.
; On entry, as always with binary operations,
; HL=first number, DE=second number
; On exit, HL=result, DE=stkend.
; So nothing to do

;; delete
000009C6: C9		RET

;; update STKEND and MOVE-FP
000009C7: 23		INC HL
000009C8: ED 5B 1C 40	LD DE,(401Ch)		; STKEND
000009CC: CD 6F 07	CALL 076Fh				; MOVE-FP
000009CF: 18 F1		JR -0Fh

; <table>
000009D1: 08		EX AF,AF'
000009D2: 0C		INC C
000009D3: 3E 43		LD A,43h
000009D5: 49		LD C,C
000009D6: 53		LD D,E
000009D7: 55		LD D,L
000009D8: 55		LD D,L

000009D9: CD A6 0A	CALL 0AA6h				; routine LOOK-VARS
000009DC: 18 0B		JR +0Bh

; ---

;; CLASS-4
000009DE: CD A6 0A	CALL 0AA6h				; routine LOOK-VARS
000009E1: F5		PUSH AF
000009E2: 3E 9F		LD A,9Fh
000009E4: B1		OR C
000009E5: 3C		INC A
000009E6: 20 5A		JR NZ,+5Ah

;; CLASS-4-2
000009E8: F1		POP AF
000009E9: 38 1B		JR C,+1Bh

000009EB: CC F0 0D	CALL Z,0DF0h			; routine STK-VAR
000009EE: FD 36 2D 00	LD (IY+2Dh),00h		; FLAGX
000009F2: EF		RST 28h					; routine SYNTAX-Z
000009F3: C8		RET Z

000009F4: CD 7A 09	CALL 097Ah				; routine SYNTAX-Z
000009F7: 20 05		JR NZ,+05h

000009F9: E7		RST 20h					; STK-FETCH
000009FA: 32 2D 40	LD (402Dh),A			; FLAGX
000009FD: EB		EX DE,HL

;; SET-STRLN
000009FE: 22 12 40	LD (4012h),HL			; DEST
00000A01: ED 43 2E 40	LD (402Eh),BC		; STRLEN
00000A05: C9		RET


00000A06: FD 36 2D 02	LD (IY+2Dh),02h		; FLAGX
00000A0A: 20 F2		JR NZ,-0Eh

;; REPORT-2
00000A0C: CD 4A 14	CALL 144Ah				; ERROR-1
00000A0F: 08		EX AF,AF'
					; "UV" - Undefined Variable

00000A10: CF		RST 08h					; NEXT-CHAR

; ---

;; CLASS-6		(A numeric expression must follow, otherwise error)
00000A11: CD 06 08	CALL 0806h				; SCANNING
00000A14: C0		RET NZ					; return with numeric expression if found
00000A15: 18 2B		JR +2Bh					; to REPORT-C

00000A17: CD 06 08	CALL 0806h				; SCANNING
00000A1A: 28 10		JR Z,+10h
00000A1C: 18 24		JR +24h


;; CLASS-3		(A numeric expression may follow, else default to zero)
00000A1E: FE 76		CP 76h
00000A20: 20 07		JR NZ,+07h

00000A22: EF		RST 28h					; routine SYNTAX-Z
00000A23: 28 07		JR Z,+07h

00000A25: F7		RST 30h					; FP-CALC
00000A26: FA		;;stk-zero & end-calc

00000A27: 18 03		JR +03h
00000A29: CD 11 0A	CALL 0A11h				; routine CLASS-06 if non-zero number

;; CLASS-0		(No further operands)
00000A2C: 37		SCF						; set CY to force CHECK-END

;; CLASS-5		(variable syntax checked entirely by routine)
00000A2D: D1		POP DE
00000A2E: DC 3B 0A	CALL C,0A3Bh			; routine CHECK-END
00000A31: EB		EX DE,HL
00000A32: 2A 30 40	LD HL,(4030h)			; T_ADDR
00000A35: 4E		LD C,(HL)
00000A36: 23		INC HL
00000A37: 46		LD B,(HL)
00000A38: C5		PUSH BC
00000A39: EB		EX DE,HL
00000A3A: C9		RET



;---------------------------
; THE 'CHECK END' SUBROUTINE
;---------------------------
; Check for end of statement and that no spurious characters occur after
; a correctly parsed statement. Since only one statement is allowed on each
; line, the only character that may follow a statement is a NEWLINE.
;

;; CHECK-END
00000A3B: EF		RST 28h					; routine SYNTAX-Z
00000A3C: C0		RET NZ
00000A3D: D1		POP DE

;; CHECK-2
00000A3E: 3E 76		LD A,76h
00000A40: BE		CP (HL)
00000A41: C8		RET Z

;; REPORT-C
00000A42: CD 4A 14	CALL 144Ah				; ERROR-1 (REPORT-C ?)
00000A45: 0B		; "IE" - Invalid Expression

;; FIELD
00000A46: FD CB 1E CE	SET 1,(IY+1Eh)		; BREG/FLAGS  - Suppress leading space
00000A4A: FE 76		CP 76h
00000A4C: 20 0C		JR NZ,+0Ch

00000A4E: EF		RST 28h					; routine SYNTAX-Z
00000A4F: C8		RET Z
00000A50: DF		RST 18h					; PRINT-A
00000A51: C9		RET

00000A52: EF		RST 28h					; routine SYNTAX-Z
00000A53: C4 91 06	CALL NZ,0691h

00000A56: CF		RST 08h					; NEXT-CHAR
00000A57: FE 76		CP 76h
00000A59: C8		RET Z

;; PRINT-1
00000A5A: FE 19		CP 19h					; ','
00000A5C: 28 F8		JR Z,-08h

00000A5E: FE 1A		CP 1Ah					; 'A'
00000A60: 28 F0		JR Z,-10h

00000A62: FE D5		CP D5h					; 'TAB'
00000A64: 28 19		JR Z,+19h

00000A66: FE D4		CP D4h					; 'AT'
00000A68: 28 23		JR Z,+23h

; ---

;; (NOT-TAB on the ZX81)
00000A6A: CD 06 08	CALL 0806h				; SCANNING
00000A6D: EF		RST 28h					; routine SYNTAX-Z
00000A6E: C4 50 15	CALL NZ,1550h			; routine PRINT-STK

;; PRINT-ON
00000A71: D7		RST 10h					; GET-CHAR
00000A72: FE 19		CP 19h
00000A74: 28 E0		JR Z,-20h
00000A76: FE 1A		CP 1Ah
00000A78: 28 D8		JR Z,-28h


00000A7A: CD 3B 0A	CALL 0A3Bh			; routine CHECK-END
00000A7D: 18 D1		JR -2Fh

00000A7F: CD 9E 0A	CALL 0A9Eh			; routine SYNTAX-ON
00000A82: CD FF 14	CALL 14FFh			; STK-TO-A
00000A85: E6 1F		AND 1Fh
00000A87: 4F		LD C,A
00000A88: CD 9B 06	CALL 069Bh
00000A8B: 18 E4		JR -1Ch				; to PRINT-ON

00000A8D: CD 10 0A	CALL 0A10h
00000A90: FE 1A		CP 1Ah
00000A92: 20 AE		JR NZ,-52h
00000A94: CD 9E 0A	CALL 0A9Eh			; routine SYNTAX-ON

00000A97: F7		RST 30h				; FP-CALC
00000A98: B3		; exchange & end-calc

00000A99: CD B5 14	CALL 14B5h			;  STK and PRINT-AT
00000A9C: 18 D3		JR -2Dh

;; SYNTAX-ON
00000A9E: CD 10 0A	CALL 0A10h
00000AA1: EF		RST 28h				; routine SYNTAX-Z
00000AA2: E1		POP HL
00000AA3: 28 CC		JR Z,-34h
00000AA5: E9		JP      (HL)

;---------------------------
; THE 'LOOK-VARS' SUBROUTINE
;---------------------------
;
; 

;; LOOK-VARS
00000AA6: D7		RST 10h				; GET-CHAR
00000AA7: FE 26		CP 26h
00000AA9: CD 3B 05	CALL 053Bh
00000AAC: 38 94		JR C,-6Ch

;; LOOK-VARS-B
00000AAE: E6 1F		AND 1Fh
00000AB0: 47		LD B,A
00000AB1: E5		PUSH HL
00000AB2: CF		RST 08h		; NEXT-CHAR
00000AB3: FD CB 1E F6	SET 6,(IY+1Eh)		; BREG/FLAGS
00000AB7: FE 10		CP 10h
00000AB9: E5		PUSH HL
00000ABA: 28 0B		JR Z,+0Bh
00000ABC: FE 0D		CP 0Dh
00000ABE: CB F0		SET 6,B
00000AC0: 20 1C		JR NZ,+1Ch
00000AC2: FD CB 1E B6	RES 6,(IY+1Eh)		; BREG/FLAGS
00000AC6: CF		RST 08h				; NEXT-CHAR
00000AC7: EF		RST 28h				; routine SYNTAX-Z
00000AC8: 48		LD C,B
00000AC9: 2A 10 40	LD HL,(4010h)		; VARS
00000ACC: 20 23		JR NZ,+23h
;; V-80-BYTE
00000ACE: CB F9		SET 7,C
;; V-SYNTAX
00000AD0: 21 CB F8	LD HL,F8CBh
00000AD3: D7		RST 10h				; GET-CHAR
00000AD4: FE 10		CP 10h
00000AD6: 28 02		JR Z,+02h			; forward to V-PASS-B
00000AD8: CB E8		SET 5,B

;; V-PASS-B
00000ADA: D1		POP DE
00000ADB: E1		POP HL
00000ADC: 18 3B		JR +3Bh 			; V-FOUND-2B

00000ADE: CB E8		SET 5,B
;; V-PASS
00000AE0: CD 39 05	CALL 0539h			; routine ALPHANUM
00000AE3: 38 E2		JR C,-1Eh
00000AE5: CF		RST 08h				; NEXT-CHAR
00000AE6: CB B0		RES 6,B
00000AE8: 18 F6		JR -0Ah				; back to V-PASS

;; V-GET-PTR
00000AEA: EB		EX DE,HL

;; V-NEXT
00000AEB: C5		PUSH BC
00000AEC: CD 13 1A	CALL 1A13h			; routine NEXT-ONE
00000AEF: C1		POP BC
;; V-EACH
00000AF0: EB		EX DE,HL
00000AF1: 3E 7F		LD A,7Fh
00000AF3: A6		AND (HL)
00000AF4: 28 DB		JR Z,-25h			; to V-80-BYTE

00000AF6: B9		CP C
00000AF7: 20 F2		JR NZ,-0Eh			; to V-NEXT

00000AF9: 87		ADD A
00000AFA: 87		ADD A
00000AFB: D1		POP DE
00000AFC: 38 1A		JR C,+1Ah		; to V-FOUND-2

00000AFE: F2 18 0B	JP P,0B18h		; to V-FOUND-2

00000B01: D5		PUSH DE
00000B02: E5		PUSH HL

;; V-MATCHES
00000B03: 23		INC HL

;; V-SPACES
00000B04: 1A		LD A,(DE)
00000B05: B7		OR A
00000B06: 13		INC DE
00000B07: 28 FB		JR Z,-05h

00000B09: AE		XOR (HL)
00000B0A: 28 F7		JR Z,-09h		; back to V-MATCHES

00000B0C: FE 80		CP 80h
00000B0E: 1A		LD A,(DE)
00000B0F: D1		POP DE
00000B10: 20 D8		JR NZ,-28h		; forward to V-GET-PTR

00000B12: CD 39 05	CALL 0539h		; routine ALPHANUM
00000B15: 30 D3		JR NC,-2Dh		; forward to V-GET-PTR

;; V-FOUND-1
00000B17: D1		POP DE
;; V-FOUND-2
00000B18: D1		POP DE
;; V-FOUND-2B
00000B19: CB 10		RL B
00000B1B: CB 70		BIT 6,B
00000B1D: C9		RET


;------------------------------
; THE 'JUMP ON TRUE' SUBROUTINE
;------------------------------
; (Offset $??; 'jump-true')
; This enables the calculator to perform conditional relative jumps
; dependent on whether the last test gave a true result
; On the ZX81, the exponent will be zero for zero or else $81 for one.

;; jump-true
00000B1E: 1A		LD A,(DE)		; collect exponent byte
00000B1F: B7		OR A			; is result 0 or 1 ?
00000B20: 20 04		JR NZ,+04h		; back to JUMP if true (1).
00000B22: D9		EXX				; else switch in the pointer set.
00000B23: 23		INC HL			; step past the jump length.
00000B24: D9		EXX				; switch in the main set
00000B25: C9		RET


;----------------------
; THE 'JUMP' SUBROUTINE
;----------------------
; (Offset $??; 'jump')
; This enables the calculator to perform relative jumps just like
; the Z80 chip's JR instruction.
; This is one of the few routines to be polished for the ZX Spectrum.
; See, without looking at the ZX Spectrum ROM, if you can get rid of the
; relative jump.

;; jump
00000B26: D9		EXX				; switch in pointer set
00000B27: 7E		LD A,(HL)		; the jump byte 0-127 forward, 128-255 back.
00000B28: 17		RLA				; test if negative jump
00000B29: 9F		SBC A			; clear accumulator.
00000B2A: 57		LD D,A			; transfer to high byte.
00000B2B: 5E		LD E,(HL)		; get the jump byte into E
00000B2C: 19		ADD HL,DE		; advance calculator pointer forward or back.
00000B2D: D9		EXX
00000B2E: C9		RET


;-----------------------
; THE 'TANGENT' FUNCTION
;-----------------------
; (offset $??: 'tan')
;
; Evaluates tangent x as    sin(x) / cos(x).
;
;
;           /|
;        h / |
;         /  |o
;        /x  |
;       /----|    
;         a
;
; the tangent of angle x is the ratio of the length of the opposite side 
; divided by the length of the adjacent side. As the opposite length can 
; be calculates using sin(x) and the adjacent length using cos(x) then 
; the tangent can be defined in terms of the previous two functions.

; Error 6 if the argument, in radians, is too close to one like pi/2
; which has an infinite tangent. e.g. PRINT TAN (PI/2)  evaluates as 1/0.
; Similarly PRINT TAN (3*PI/2), TAN (5*PI/2) etc.

;; tan
00000B2F: F7		RST 30h				; FP-CALC
00000B30: 01		;;duplicate
00000B31: 0D		;;sin
00000B32: 33		;;exchange
00000B33: 0E		;;cos
00000B34: A0		;;division & end-calc
00000B35: C9		RET

;------------------------------
; THE 'LINE ADDRESS' SUBROUTINE
;------------------------------
;
;

;; LINE-ADDR (HL)
00000B36: 44		LD B,H
00000B37: 4D		LD C,L
;; LINE-ADDR (BC)
00000B38: 21 96 43	LD HL,4396h				; The first location after System Variables -> default program position (17302)
00000B3B: 5D		LD E,L
00000B3C: 54		LD D,H
; NEXT-TEST
00000B3D: CD 68 18	CALL 1868h				; routine CP-LINES
00000B40: D0		RET NC
00000B41: C5		PUSH BC
00000B42: CD 13 1A	CALL 1A13h				; routine NEXT-ONE
00000B45: C1		POP BC
00000B46: EB		EX DE,HL
00000B47: 18 F4		JR -0Ch					; NEXT-TEST
;; REPORT-1
00000B49: CD 4A 14	CALL 144Ah				; ERROR-1
00000B4C: 04		; "NF" - NEXT without FOR

00000B4D: FD CB 2D 4E	BIT 1,(IY+2Dh)      ; FLAGX
00000B51: C2 0C 0A	JP NZ,0A0Ch				; to REPORT-2
00000B54: 2A 12 40	LD HL,(4012h)			; DEST
00000B57: 7E		LD A,(HL)
00000B58: 17		RLA
00000B59: 30 EE		JR NC,-12h				; to REPORT-1
00000B5B: 23		INC HL
00000B5C: 22 1F 40	LD (401Fh),HL			; MEM
00000B5F: F7		RST 30h					; FP-CALC
00000B60: 40	;;get-mem-0
00000B61: 4a	;;get-mem-2
00000B62: 2a	;;addition
00000B63: 50	;;st-mem-0
00000B64: 45	;;delete
00000B65: 4a	;;end-calc

00000B66: 03		INC BC
00000B67: 34		INC (HL)
00000B68: 02		LD (BC),A
00000B69: 33		;;exchange
00000B6A: 1E 03		LD E,03h
00000B6C: B4		OR H
00000B6D: 20 11		JR NZ,+11h
00000B6F: 0F		RRCA
00000B70: 00		NOP
00000B71: 2A 1F 40	LD HL,(401Fh)		; MEM
00000B74: 19		ADD HL,DE
00000B75: 5E		LD E,(HL)
00000B76: 23		INC HL
00000B77: 56		LD D,(HL)
00000B78: EB		EX DE,HL
00000B79: C3 11 15	JP 1511h

;-----------------------
; THE 'INTEGER' FUNCTION
;-----------------------
; (offset $??: 'int')
; This function returns the integer of x, which is just the same as truncate
; for positive numbers. The truncate literal truncates negative numbers
; upwards so that -3.4 gives -3 whereas the BASIC INT function has to
; truncate negative numbers down so that INT -3.4 is 4.
; It is best to work through using, say, plus or minus 3.4 as examples.

;; int
00000B7C: F7		RST 30h				; FP-CALC
00000B7D: 81		;;duplicate & end-calc					-3.4, -3.4.

00000B7E: CD A0 0C	CALL 0CA0h			; truncate 			-3.4, -3.

00000B81: F7		RST 30h				; FP-CALC
00000B82: 50		;;st-mem-0								-3.4, -3.
00000B83: 1E		;;subtract								-.4
00000B84: 40		;;get-mem-0								-.4, -3.
00000B85: 33		;;exchange								-3, -.4.
00000B86: 03		;;less-0
00000B87: 1D		;;not									-3, (0).
00000B88: 34		;;jump-true								-3.
00000B89: 03		;;to $B8B, EXIT							-3.
00000B8A: 79		;;stk-one               				-3, 1.
00000B8B: 1E		;;subtract								-4.
00000B8C: 00		;;end-calc
00000B8D: C9		RET


; -------------------------
; THE 'ADD-BACK' SUBROUTINE
; -------------------------
; Called from SHIFT-FP above during addition and after normalization from
; multiplication.
; This is really a 32-bit increment routine which sets the zero flag according
; to the 32-bit result.
; During addition, only negative numbers like FF FF FF FF FF,
; the twos-complement verson of xx 80 00 00 01 say 
; will result in a full ripple FF 00 00 00 00.
; FF FF FF FF FF when shifted right is unchanged by SHIFT-FP but sets the 
; carry invoking this routine.

;; ADD-BACK
00000B8E: 1C		INC E
00000B8F: C0		RET NZ

00000B90: 14		INC D
00000B91: C0		RET NZ

00000B92: D9		EXX
00000B93: 1C		INC E
00000B94: 20 01		JR NZ,+01h

00000B96: 14		INC D

;; ALL-ADDED
00000B97: D9		EXX
00000B98: C9		RET

;; SOUND
00000B99: CD 09 15	CALL 1509h				; FIND-INT
00000B9C: C5		PUSH BC
00000B9D: CD FF 14	CALL 14FFh			; STK-TO-A
00000BA0: C1		POP BC
00000BA1: 5F		LD E,A

; SOUND-ENGINE (play value in E, length BC)
; frequency loop
00000BA2: DB F5		INA (F5h)	; toggle sound bit
00000BA4: 53		LD D,E

; sound lenght loop
00000BA5: 0B		DEC BC
00000BA6: 78		LD A,B
00000BA7: B1		OR C
00000BA8: C8		RET Z
00000BA9: 15		DEC D
00000BAA: 28 F6		JR Z,-0Ah	; frequency loop

00000BAC: 00		NOP
00000BAD: 00		NOP
00000BAE: 18 F5		JR -0Bh		; sound lenght loop


; ALERT BEEP
00000BB0: 1E 1C		LD E,1Ch			; preset alert tone
00000BB2: 01 88 13	LD BC,1388h			; 5000
00000BB5: 18 EB		JR -15h				; to SOUND-ENGINE

00000BB7: FE 21		CP 21h
00000BB9: 30 16		JR NC,+16h

; -----------------------------
; THE 'SHIFT ADDEND' SUBROUTINE
; -----------------------------
; The accumulator A contains the difference between the two exponents.
; This is the lowest of the two numbers to be added 

;; SHIFT-FP
00000BBB: B7		OR A
00000BBC: C8		RET Z

00000BBD: D9		EXX
00000BBE: CB 2C		SRA H
00000BC0: CB 1A		RR D
00000BC2: CB 1B		RR E
00000BC4: D9		EXX
00000BC5: CB 1A		RR D
00000BC7: CB 1B		RR E
00000BC9: 3D		DEC A
00000BCA: 20 F1		JR NZ,-0Fh
00000BCC: D0		RET NC
00000BCD: CD 8E 0B	CALL 0B8Eh
00000BD0: C0		RET NZ

00000BD1: AF		XOR A
00000BD2: 57		LD D,A
00000BD3: 5F		LD E,A
00000BD4: D9		EXX
00000BD5: 57		LD D,A
00000BD6: 5F		LD E,A
00000BD7: 67		LD H,A
00000BD8: D9		EXX
00000BD9: C9		RET


00000BDA: 01 01 00	LD BC,0001h
;------------------------------
; THE 'MAKE BC SPACES'  RESTART
;------------------------------
; This restart is used eight times to create, in workspace, the number of
; spaces passed in the BC register.

00000BDD: 2A 14 40	LD HL,(4014h)			; E_LINE
00000BE0: C5		PUSH BC
00000BE1: E5		PUSH HL
00000BE2: 2A 1A 40	LD HL,(401Ah)			; STKBOT
00000BE5: 2B		DEC HL
00000BE6: CD B5 1C	CALL 1CB5h				; MAKE-ROOM
00000BE9: 13		INC DE
00000BEA: EB		EX DE,HL
00000BEB: C1		POP BC
00000BEC: 13		INC DE
00000BED: ED 43 14 40	LD (4014h),BC		; E_LINE
00000BF1: 13		INC DE
00000BF2: C1		POP BC
00000BF3: C9		RET

;-------------------------
; THE 'TABLE OF ADDRESSES'
;-------------------------
;
; The order of binary operation types is different
; compared to the ZX81 ROM
;
; The following opcodes are probably missing on the Lambda 8300:
; dec-jr-nz, truncate, fp-calc-2
;
; Opcode $00 for end-calc is handled internally by the FP calculator.
;

;; tbl-addrs
        DEFW    $076F           ; $01 - duplicate
        DEFW    $0C77           ; $02 - greater-0
        DEFW    $0C7C           ; $03 - less-0
        DEFW    $0B26           ; $04 - jump
        DEFW    $0D31           ; $05 - stk-data
        DEFW    $0C66           ; $06 - n-mod-m
        DEFW    $03C2           ; $07 - get-argt
        DEFW    $11F3           ; $08 - e-to-fp


; true unary operations

        DEFW    $1288           ; $09 - neg

        DEFW    $079F           ; $0A - code
        DEFW    $18BE           ; $0B - val
        DEFW    $077D           ; $0C - len
        DEFW    $1189           ; $0D - sin
        DEFW    $117E           ; $0E - cos
        DEFW    $0B2F           ; $0F - tan
        DEFW    $006E           ; $10 - asn
        DEFW    $0390           ; $11 - acs
        DEFW    $1B9D           ; $12 - atn
        DEFW    $1A63           ; $13 - ln  (log)
        DEFW    $0718           ; $14 - exp
        DEFW    $0B7C           ; $15 - int
        DEFW    $06FA           ; $16 - sqr
        DEFW    $0528           ; $17 - sgn		
        DEFW    $001B           ; $18 - abs
        DEFW    $0799           ; $19 - peek
        DEFW    $0540           ; $1A - usr-no
        DEFW    $0DA3           ; $1B - strs
        DEFW    $0DD2           ; $1C - chrs
        DEFW    $0C8F           ; $1D - not

; true binary operations

        DEFW    $173D           ; $1E - subtract
        DEFW    $16DA           ; $1F - multiply
        DEFW    $1679           ; $20 - division
        DEFW    $0700           ; $21 - to-power
        DEFW    $0C9B           ; $22 - or

        DEFW    $0C96           ; $23 - no-&-no
        DEFW    $10BE           ; $24 - no-l-eql
        DEFW    $10BE           ; $25 - no-gr-eql
        DEFW    $10BE           ; $26 - nos-neql
        DEFW    $10BE           ; $27 - no-grtr
        DEFW    $10BE           ; $28 - no-less
        DEFW    $10BE           ; $29 - nos-eql
        DEFW    $1746           ; $2A - addition

        DEFW    $004F           ; $2B - str-&-no
        DEFW    $10BE           ; $2C - str-l-eql
        DEFW    $10BE           ; $2D - str-gr-eql
        DEFW    $10BE           ; $2E - strs-neql
        DEFW    $10BE           ; $2F - str-grtr
        DEFW    $10BE           ; $30 - str-less
        DEFW    $10BE           ; $31 - strs-eql
        DEFW    $189B           ; $32 - strs-add
		
; special operations   -  opcodes start from $33
		
        DEFW    $1CA5           ; $33 - exchange
		DEFW    $0B1E           ; $34 - jump-true
        DEFW    $09C6           ; $35 - delete

 the following are just the next available slots for the 128 compound literals
; which are in range $80 - $FF.

        DEFW    $03A3           ; $40 - get-mem-xx   $40,$45,$4A,$4F...
        DEFW    $1A07           ; $50 - st-mem-xx    $50,$55,$5A,$5F...
        DEFW    $021A           ; $60 - series-xx    $60 - $6F.
        DEFW    $17DE           ; $3A - stk-const-xx	$7A(stk-zero),
													;	$79(stk-one),
													;	$78(stk-half),
													;	$77(stk-ten),
													;	$70(stk-pi/2)


;-------------------------
; THE 'MODULUS' SUBROUTINE
;-------------------------
; ( Offset $??: 'n-mod-m' )
; ( i1, i2 -- i3, i4 )
; The subroutine calculate N mod M where M is the positive integer, the
; 'last value' on the calculator stack and N is the integer beneath.
; The subroutine returns the integer quotient as the last value and the
; remainder as the value beneath.
; e.g.    17 MOD 3 = 5 remainder 2
; It is invoked during the calculation of a random number and also by
; the PRINT-FP routine.

;; n-mod-m
00000C66: F7		RST 30h				; FP-CALC
00000C67: 50		;;st-mem-0		
00000C68: 35		;;delete
00000C69: 01		;;duplicate
00000C70: 40		;;get-mem-0
00000C71: A0		;;division & end-calc

00000C6C: CD A0 0C	CALL 0CA0h			; truncate

00000C6F: F7		RST 30h				; FP-CALC
00000C70: 40		;;get-mem-0
00000C71: 33		;;exchange
00000C72: 50		;;st-mem-0
00000C73: 1F		;;multiply
00000C74: 1E		;;subtract
00000C75: C0		;;get-mem-0 & end-calc
00000C76: C9		RET

;------------------------
; Greater than zero ($33)
;------------------------
; Test if the last value on the calculator stack is greater than zero.
; This routine is also called directly from the end-tests of the comparison
; routine.

;; greater-0
00000C77: 7E		LD A,(HL)	; fetch exponent.
00000C78: B7		OR A		; test it for zero.
00000C79: C8		RET Z		; return if so.

00000C7A: AF		XOR A		; invert the xor mask to change the sign bit
								
00000C7B: FE 3E		CP 3Eh	;  byte "3E" also as instruction in the next line 


;--------------------
; Less than zero 
;--------------------
; Destructively test if last value on calculator stack is less than zero.
; Bit 7 of second byte will be set if so.

;; less-0
00000C7C: 3E BF		LD A,BFh	; set the XOR mask (this line exists only if entry is 0C7Ch)

00000C7D: BF		CP A		; (this line disappears if entry is not 0C7Ch.. by the way it has no impact when executed)

; transfer sign of mantissa to Carry Flag.

;; SIGN-TO-C
00000C7E: 23		INC HL			; address 2nd byte.
00000C7F: AE		XOR (HL)		; bit 7 of HL will be set if number is negative.
00000C80: 17		RLA				; rotate bit 7 of A to carry.
00000C81: 2B		DEC HL			; address 1st byte again.

;------------
; Zero or one
;------------
; This routine places an integer value zero or one at the addressed location
; of calculator stack or MEM area. The value *ZERO* is written if carry is set on
; entry else zero.

;; FP-0/1
00000C82: E5		PUSH HL			; save pointer to the first byte
00000C83: 06 05		LD B,05h		; five bytes to do.

;; FP-loop
00000C85: 36 00		LD (HL),00h		; insert a zero.
00000C87: 23		INC HL
00000C88: 10 FB		DJNZ -05h		; repeat
00000C8A: E1		POP HL
00000C8B: D8		RET C
00000C8C: 36 81		LD (HL),81h		; make value 1
00000C8E: C9		RET


;-------------------------
; Handle NOT operator ($??)
;-------------------------
; This overwrites the last value with 1 if it was zero else with zero
; if it was any other value.
;
; e.g NOT 0 returns 1, NOT 1 returns 0, NOT -3 returns 0.
;
; The subroutine is also called directly from the end-tests of the comparison
; operator.

;; not
00000C8F: 7E		LD A,(HL)			; get exponent byte.
00000C90: B7		OR A				; check for zero.
00000C91: 28 EF		JR Z,-11h			;

00000C93: 37		SCF					
00000C94: 18 EC		JR -14h				; if not zero, forward to FP-0/1


;------------------------------
; Handle number AND number (?)
;------------------------------
; The Boolean AND operator.
;
; e.g.    -3 AND 2  returns -3.
;         -3 AND 0  returns 0.
;          0 and -2 returns 0.
;          0 and 0  returns 0.
;
; Compare with OR routine above.

;; no-&-no
00000C96: 1A		LD A,(DE)			; fetch exponent of second number.
00000C97: B7		OR A				; test it.
00000C98: 28 F9		JR Z,-07h			; forward to FP-0/1 to overwrite the first operand with zero for return value.
00000C9A: C9		RET					; return if not zero.


;------------------------
; Handle OR operator (??)
;------------------------
; The Boolean OR operator. eg. X OR Y
; The result is zero if both values are zero else a non-zero value.
;
; e.g.    0 OR 0  returns 0.
;        -3 OR 0  returns -3.
;         0 OR -3 returns 1.
;        -3 OR 2  returns 1.
;
; A binary operation.
; On entry HL points to first operand (X) and DE to second operand (Y).

;; or
00000C9B: 1A		LD A,(DE)			; fetch exponent of second number
00000C9C: B7		OR A				; test it.
00000C9D: 20 E3		JR NZ,-1Dh			; if not zero, back to FP-0/1 to overwrite the first operand with the value 1.
00000C9F: C9		RET					; return if zero.

; ------------------------------------------------
; THE 'INTEGER TRUNCATION TOWARDS ZERO' SUBROUTINE
; ------------------------------------------------
;

;; truncate
00000CA0: 7E		LD A,(HL)		; fetch exponent
00000CA1: FE 81		CP 81h			; compare to +1 
00000CA3: 38 DD		JR C,-23h		; forward, if 0 or LESS

;;T-GR-ZERO
00000CA5: 3E A0		LD A,A0h
00000CA7: 96		SUB (HL)		; subtract +32 from exponent
00000CA8: D8		RET C
00000CA9: 47		LD B,A
00000CAA: CB 38		SRL B
00000CAC: CB 38		SRL B
00000CAE: CB 38		SRL B
00000CB0: EB		EX DE,HL
00000CB1: 2B		DEC HL
00000CB2: 28 05		JR Z,+05h
00000CB4: 36 00		LD (HL),00h
00000CB6: 2B		DEC HL
00000CB7: 10 FB		DJNZ -05h
00000CB9: E6 07		AND 07h
00000CBB: C8		RET Z
00000CBC: 47		LD B,A
00000CBD: 3E FF		LD A,FFh
00000CBF: CB 27		SLA A
00000CC1: 10 FC		DJNZ -04h
00000CC3: A6		AND (HL)
00000CC4: 77		LD (HL),A
00000CC5: C9		RET

;----------------------------------------
; THE 'LIST' AND 'LLIST' COMMAND ROUTINES
;----------------------------------------
;
;

;; LLIST
00000CC6: FD CB 1E CE	SET 1,(IY+1Eh)		; BREG/FLAGS

;; LIST
00000CCA: CD 09 15	CALL 1509h				; FIND-INT
00000CCD: 78		LD A,B
00000CCE: E6 3F		AND 3Fh
00000CD0: 47		LD B,A
00000CD1: ED 43 29 40	LD (4029h),BC			; E_PPC (<> ZX81)
00000CD5: CD 38 0B	CALL 0B38h					; routine LINE-ADDR (BC)
00000CD8: ED 4B 29 40	LD BC,(4029h)			; E_PPC (<> ZX81)
00000CDC: CD 68 18	CALL 1868h					; routine CP-LINES
00000CDF: 01 00 97	LD BC,9700h
00000CE2: 28 06		JR Z,+06h
00000CE4: 41		LD B,C
00000CE5: 38 03		JR C,+03h
00000CE7: FD 71 09	LD (IY+09h),C        ; VERSN
00000CEA: 7E		LD A,(HL)
00000CEB: FE 40		CP 40h
00000CED: D0		RET NC
00000CEE: 57		LD D,A
00000CEF: 23		INC HL
00000CF0: 5E		LD E,(HL)
00000CF1: 23		INC HL
00000CF2: CD 89 04	CALL 0489h
00000CF5: 22 16 40	LD (4016h),HL		; CH_ADD
00000CF8: 78		LD A,B
00000CF9: CD BB 04	CALL 04BBh			; PRINT-CH
00000CFC: 23		INC HL
00000CFD: 23		INC HL
00000CFE: CD D8 04	CALL 04D8h
00000D01: 18 D5		JR -2Bh

;; SAVE
00000D03: CD 38 15	CALL 1538h			; NAME
00000D06: 30 04		JR NC,+04h

00000D08: CD 4A 14	CALL 144Ah			; ERROR-1
00000D0B: 0D		; "NA" - Invalid program name

00000D0C: EB		EX DE,HL
00000D0D: 16 40		LD D,40h
00000D0F: CD F4 19	CALL 19F4h			; call PULSES
00000D12: 15		DEC D
00000D13: 20 FA		JR NZ,-06h
00000D15: 3E 0A		LD A,0Ah
00000D17: 3D		DEC A
00000D18: 20 FD		JR NZ,-03h
00000D1A: 10 F9		DJNZ -07h

;; OUT-NAME
00000D1C: CD ED 17	CALL 17EDh			; routine OUT-BYTE
00000D1F: CB 7E		BIT 7,(HL)			; test for inverted bit.
00000D21: 23		INC HL				; address next character of name.
00000D22: 28 F8		JR Z,-08h			; back if not inverted to OUT-NAME

; now start saving the system variables onwards.

00000D24: 21 09 40	LD HL,4009h   		; set start of area to VERSN/BERG thereby preserving RAMTOP etc.
00000D27: 36 FF		LD (HL),FFh

;; OUT-PROG
00000D29: CD ED 17	CALL 17EDh			; routine OUT-BYTE
00000D2C: CD BA 0E	CALL 0EBAh			; routine LOAD/SAVE
00000D2F: 18 F8		JR -08h				; loop back to OUT-PROG


;--------------------
; Stack literals
;--------------------
; When a calculator subroutine needs to put a value on the calculator
; stack that is not a regular constant this routine is called with a
; variable number of following data bytes that convey to the routine
; the floating point form as succinctly as is possible.

;; stk-data
00000D31: CD F2 13	CALL 13F2h		; routine TEST-5-SP tests that room exists
00000D34: D5		PUSH DE
00000D35: D9		EXX
00000D36: E5		PUSH HL			; save the pointer to next literal on stack
00000D37: D9		EXX
00000D38: E1		POP HL			; pointer to HL
00000D39: 7E		LD A,(HL)		; fetch the byte following 'stk-data'
00000D3A: 07		RLCA			; rotate
00000D3B: 07		RLCA			; to bits 1 and 0  
00000D3C: E6 03		AND 03h			; mask the range $00 - $03
00000D3E: 3C		INC A			; increment to give number of bytes to read. $01 - $04
00000D3F: 4F		LD C,A			; copy to C
00000D40: 7E		LD A,(HL)		; reload the first byte
00000D41: 23		INC HL
00000D42: E6 3F		AND 3Fh			; mask off to give possible exponent.
00000D44: 20 02		JR NZ,+02h		; forward to FORM-EXP if it was possible to include the exponent.

; else byte is just a byte count and exponent comes next.

00000D46: 7E		LD A,(HL)		; pick up the exponent ( - $50).
00000D47: 23		INC HL
;; FORM-EXP
00000D48: C6 50		ADD 50h			; now add $50 to form actual exponent
00000D4A: 12		LD (DE),A		; and load into first destination byte.
00000D4B: 13		INC DE
00000D4C: 3E 05		LD A,05h		; load accumulator with $05 and
00000D4E: 91		SUB C			; subtract C to give count of trailing
00000D4F: ED B0		LDIR			; copy C bytes
00000D51: E5		PUSH HL			; put HL on stack as next literal pointer
00000D52: D9		EXX
00000D53: E1		POP HL			; restore next literal pointer from stack to H'L'.
00000D54: D9		EXX
00000D55: E1		POP HL
00000D56: 4F		LD C,A			; zero count to C
00000D57: AF		XOR A			; clear accumulator
;; STK-ZEROS
00000D58: 0D		DEC C			; decrement B counter
00000D59: C8		RET Z			; return if zero.          >> DE points to new STKEND, HL to new number.
00000D5A: 12		LD (DE),A		; else load zero to destination
00000D5B: 13		INC DE			; increase destination
00000D5C: 18 FA		JR -06h			; loop back to STK-ZEROS until done.




;----------------------------
; THE 'PAUSE' COMMAND ROUTINE
;----------------------------
;
;

;; FAST
00000D5E: FD CB 3B B6	RES 6,(IY+3Bh)		; CDFLAG

;; SET-FAST
00000D62: FD CB 3B 7E	BIT 7,(IY+3Bh)		; CDFLAG
00000D66: C8		RET Z
00000D67: 76		HALT
00000D68: D3 FD		OUTA (FDh)				; turn off the NMI generator.
00000D6A: FD CB 3B BE	RES 7,(IY+3Bh)		; CDFLAG
00000D6E: C9		RET

;; GET-INT & SET-FAST
00000D6F: E7		RST 20h					; STK-FETCH
00000D70: 62		LD H,D
00000D71: 6B		LD L,E
00000D72: 18 EE		JR -12h					; to set-fast


;-----------------------------------
; THE 'KEYBOARD SCANNING' SUBROUTINE
;-----------------------------------
;
;

;; KEYBOARD
00000D74: 01 FE FE	LD BC,FEFEh
00000D77: 21 FF FF	LD HL,FFFFh
00000D7A: ED 78		IN A,(C)
00000D7C: F6 01		OR 01h

;; EACH-LINE
00000D7E: F6 E0		OR E0h
00000D80: 5F		LD E,A
00000D81: 2F		CPL
00000D82: FE 01		CP 01h
00000D84: 9F		SBC A
00000D85: B0		OR B
00000D86: A5		AND L
00000D87: 6F		LD L,A
00000D88: 7B		LD A,E
00000D89: A4		AND H
00000D8A: 67		LD H,A
00000D8B: CB 00		RLC B
00000D8D: ED 78		IN A,(C)
00000D8F: 38 ED		JR C,-13h			; to EACH-LINE

00000D91: 0F		RRCA
00000D92: CB 14		RL H
00000D94: 3E FF		LD A,FFh
00000D96: DB 7E		INA (7Eh)			; FF7Eh.R   Lambda - read PAL/NTSC flag (A7=row) (via diode from A7 to KEYB.0)
00000D98: 1F		RRA
00000D99: 3F		CCF
00000D9A: 9F		SBC A
00000D9B: E6 18		AND 18h
00000D9D: C6 1F		ADD 1Fh
00000D9F: 32 28 40	LD (4028h),A		; MARGIN
00000DA2: C9		RET


;-----------------
; Handle STR$
;-----------------
; This function returns a string representation of a numeric argument.
; The method used is to trick the PRINT-FP routine.

;; str$
00000DA3: 2A 0E 40	LD HL,(400Eh)		; fetch value of DF_CC
00000DA6: E5		PUSH HL				; and preserve on stack
00000DA7: 2A 39 40	LD HL,(4039h)		; fetch value of S_POSN column/line
00000DAA: E5		PUSH HL				; and preserve on stack.
00000DAB: 21 FF 18	LD HL,18FFh			; make column value high to create a
00000DAE: 22 39 40	LD (4039h),HL		; contrived buffer and store in system variable S_POSN.
00000DB1: 01 0E 00	LD BC,000Eh			; create the temporary buffer space of 14 bytes
00000DB4: CD DD 0B	CALL 0BDDh			; BC-SPACES
00000DB7: D5		PUSH DE
00000DB8: ED 53 0E 40	LD (400Eh),DE	; now set DF_CC which normally addresses somewhere in the display file
										; to the start	of workspace.
00000DBC: CD 55 15	CALL 1555h			; routine PRINT-FP.
00000DBF: 2A 0E 40	LD HL,(400Eh)		; DF_CC
00000DC2: AF		XOR A
00000DC3: D1		POP DE				; retrieve start of string
00000DC4: ED 52		SBC HL,DE
00000DC6: 4D		LD C,L
00000DC7: 44		LD B,H
00000DC8: E1		POP HL				; restore original
00000DC9: 22 39 40	LD (4039h),HL		; S_POSN x and y values
00000DCC: E1		POP HL				; restore original
00000DCD: 22 0E 40	LD (400Eh),HL		; DF_CC value
00000DD0: 18 09		JR +09h  ; **v


;-----------------
; Handle CHR$
;-----------------
; This function returns a single character string that is a result of
; converting a number in the range 0-255 to a string e.g. CHR$ 38 = "A".
; Note. the ZX81 does not have an ASCII character set.

;; chrs
00000DD2: CD FF 14	CALL 14FFh			; STK-TO-A
00000DD5: F5		PUSH AF
00000DD6: CD DA 0B	CALL 0BDAh			; call BC-SPACES for one space (makes DE point to start)
00000DD9: F1		POP AF				; restore the number.
00000DDA: 12		LD (DE),A			; and store in workspace
							; **^
00000DDB: CD BC 13	CALL 13BCh			; routine STK-STO-$ stores the string descriptor on the calculator stack.
00000DDE: EB		EX DE,HL			; HL = last value, DE = STKEND.
00000DDF: C9		RET

; switch the output from screen to workspace buffer 
00000DE0: 21 FF 18	LD HL,18FFh		; set row value to 24 and make column value
									; high to create a contrived buffer of length 254.
00000DE3: 22 39 40	LD (4039h),HL	; store in system variable S_POSN.
00000DE6: 2A 14 40	LD HL,(4014h)		; fetch E_LINE
00000DE9: 22 0E 40	LD (400Eh),HL		; now set DF_CC which normally addresses somewhere in the display file
										; to the start of workspace.
00000DEC: 2A 29 40	LD HL,(4029h)		; E_PPC (<> ZX81)
00000DEF: C9		RET

;-------------------------
; THE 'STK-VAR' SUBROUTINE
;-------------------------
;

00000DF0: AF		XOR A
00000DF1: EF		RST 28h					; routine SYNTAX-Z
00000DF2: 47		LD B,A
00000DF3: 28 24		JR Z,+24h
00000DF5: CB 7E		BIT 7,(HL)
00000DF7: 28 0B		JR Z,+0Bh

;; SV-ARRAYS
00000DF9: CB 71		BIT 6,C
00000DFB: 23		INC HL
00000DFC: 23		INC HL
00000DFD: 23		INC HL
00000DFE: 46		LD B,(HL)
00000DFF: 28 17		JR Z,+17h
00000E01: 10 0E		DJNZ +0Eh
00000E03: FE 3C		CP 3Ch
00000E05: 23		INC HL
00000E06: 4E		LD C,(HL)
00000E07: 23		INC HL
00000E08: 46		LD B,(HL)
00000E09: EB		EX DE,HL
00000E0A: 13		INC DE
00000E0B: CD BC 13	CALL 13BCh				; routine STK-STO-$
00000E0E: D7		RST 10h					; GET-CHAR
00000E0F: 18 47		JR +47h
00000E11: EB		EX DE,HL
00000E12: D7		RST 10h					; GET-CHAR
00000E13: D6 10		SUB 10h
00000E15: 20 35		JR NZ,+35h
00000E17: FE EB		CP EBh
00000E19: CF		RST 08h					; NEXT-CHAR
00000E1A: 21 00 00	LD HL,0000h
00000E1D: 18 48		JR +48h


00000E1F: D5		PUSH DE
00000E20: E5		PUSH HL
00000E21: CD 11 0A	CALL 0A11h				; routine CLASS-06
00000E24: EF		RST 28h					; routine SYNTAX-Z
00000E25: 28 0C		JR Z,+0Ch
00000E27: CD 09 15	CALL 1509h				; FIND-INT
00000E2A: E1		POP HL
00000E2B: E5		PUSH HL
00000E2C: B0		OR B
00000E2D: 28 1D		JR Z,+1Dh
00000E2F: ED 42		SBC HL,BC
00000E31: 38 19		JR C,+19h
00000E33: E1		POP HL
00000E34: D1		POP DE
00000E35: C9		RET

00000E36: EE 11		XOR 11h
00000E38: 20 12		JR NZ,+12h
00000E3A: CF		RST 08h					; NEXT-CHAR
00000E3B: C9		RET

00000E3C: EF		RST 28h					; routine SYNTAX-Z
00000E3D: 20 0D		JR NZ,+0Dh
00000E3F: CB 71		BIT 6,C
00000E41: D1		POP DE
00000E42: 28 F2		JR Z,-0Eh

00000E44: FE 41		CP 41h
00000E46: 28 08		JR Z,+08h

00000E48: EE 11		XOR 11h
00000E4A: 28 0B		JR Z,+0Bh

00000E4C: CD 4A 14	CALL 144Ah				; ERROR-1
00000E4F: 0C		; "BS" - Bad Subscript

00000E50: 2B		DEC HL
00000E51: 22 16 40	LD (4016h),HL			; CH_ADD
00000E54: CD 37 13	CALL 1337h				; routine SLICING
00000E57: CF		RST 08h					; NEXT-CHAR
00000E58: D6 10		SUB 10h
00000E5A: 28 F8		JR Z,-08h
00000E5C: FD CB 1E B6	RES 6,(IY+1Eh)		; BREG/FLAGS
00000E60: C9		RET

00000E61: FE 1A		CP 1Ah
00000E63: 20 D7		JR NZ,-29h
00000E65: CF		RST 08h		; NEXT-CHAR
00000E66: E1		POP HL
00000E67: 3E E0		LD A,E0h
00000E69: A1		AND C
00000E6A: EE C0		XOR C0h
00000E6C: 20 09		JR NZ,+09h
00000E6E: D7		RST 10h					; GET-CHAR
00000E6F: FE 41		CP 41h
00000E71: 28 DD		JR Z,-23h
00000E73: EE 11		XOR 11h
00000E75: 28 E0		JR Z,-20h

;; SV-MULT
00000E77: C5		PUSH BC
00000E78: E5		PUSH HL
00000E79: CD 95 18	CALL 1895h				; routine DE,(DE+1)
00000E7C: E3		EX HL,(SP)
00000E7D: EB		EX DE,HL
00000E7E: CD 1F 0E	CALL 0E1Fh				; routine INT-EXP1
00000E81: CD A3 13	CALL 13A3h				; routine GET-HL*DE
00000E84: D1		POP DE
00000E85: 09		ADD HL,BC
00000E86: 2B		DEC HL
00000E87: C1		POP BC
00000E88: E5		PUSH HL
00000E89: D7		RST 10h					; GET-CHAR
00000E8A: 10 D5		DJNZ -2Bh
00000E8C: EF		RST 28h					; routine SYNTAX-Z
00000E8D: 28 BD		JR Z,-43h
00000E8F: CB 71		BIT 6,C
00000E91: 28 17		JR Z,+17h

;; SV-ELEM$
00000E93: CD 95 18	CALL 1895h				; routine DE,(DE+1)
00000E96: E3		EX HL,(SP)
00000E97: CD A5 13	CALL 13A5h				; routine GET-HL*DE
00000E9A: C1		POP BC
00000E9B: 03		INC BC
00000E9C: 09		ADD HL,BC
00000E9D: 42		LD B,D
00000E9E: 4B		LD C,E
00000E9F: EB		EX DE,HL
00000EA0: CD 7D 13	CALL 137Dh				; routine STK-ST-0
00000EA3: D7		RST 10h					; GET-CHAR
00000EA4: FE 1A		CP 1Ah
00000EA6: 28 AC		JR Z,-54h
00000EA8: 18 9E		JR -62h
00000EAA: FE 11		CP 11h
00000EAC: 20 9E		JR NZ,-62h
00000EAE: 4B		LD C,E
00000EAF: 42		LD B,D
00000EB0: D1		POP DE
00000EB1: CF		RST 08h		; NEXT-CHAR
00000EB2: 21 05 00	LD HL,0005h
00000EB5: CD A5 13	CALL 13A5h
00000EB8: 09		ADD HL,BC
00000EB9: C9		RET

;-------------------------------
; THE 'LOAD-SAVE UPDATE' ROUTINE
;-------------------------------
;
;

;; LOAD/SAVE
00000EBA: EB		EX DE,HL
00000EBB: 2A 14 40	LD HL,(4014h)		; system variable edit line E_LINE.
00000EBE: 37		SCF
00000EBF: 13		INC DE
00000EC0: ED 52		SBC HL,DE
00000EC2: EB		EX DE,HL
00000EC3: D0		RET NC				; return if more bytes to load/save.

00000EC4: D1		POP DE				; else drop return address

;-----------------------
; THE 'DISPLAY' ROUTINES
;-----------------------


00000EC5: FD 34 09	INC (IY+09h)   		; VERSN / BERG
00000EC8: CA A9 12	JP Z,12A9h			; routine SLOW/FAST



00000ECB: 2A 0C 40	LD HL,(400Ch)		; PROGRAM
00000ECE: CD 36 14	CALL 1436h			; Init PROGRAM and VARS and CLEAR
00000ED1: 21 7D 40	LD HL,407Dh			; D-FILE
00000ED4: 01 19 03	LD BC,0319h
00000ED7: CD B5 1C	CALL 1CB5h			; MAKE-ROOM
00000EDA: EB		EX DE,HL
00000EDB: 23		INC HL
00000EDC: 3E C0		LD A,C0h
00000EDE: A6		AND (HL)
00000EDF: 23		INC HL
00000EE0: 23		INC HL
00000EE1: 23		INC HL
00000EE2: 28 04		JR Z,+04h
00000EE4: 18 7D		JR +7Dh
00000EE6: 80		ADD B

;;
00000EE7: 77		LD (HL),A
;; MORE-LINE-B
00000EE8: 23		INC HL
00000EE9: CD F6 18	CALL 18F6h			; routine NUMBER
00000EEC: 28 FA		JR Z,-06h			; to MORE-LINE-B

00000EEE: FE 76		CP 76h				;
00000EF0: 28 E9		JR Z,-17h			;

00000EF2: FE E1		CP E1h
00000EF4: 30 F2		JR NC,-0Eh

00000EF6: FE 40		CP 40h
00000EF8: 38 EE		JR C,-12h

00000EFA: 06 03		LD B,03h
00000EFC: FE 43		CP 43h
00000EFE: 38 E6		JR C,-1Ah

00000F00: 06 62		LD B,62h
00000F02: FE DE		CP DEh
00000F04: 30 E0		JR NC,-20h

00000F06: 06 FE		LD B,FEh
00000F08: FE D8		CP D8h
00000F0A: 30 DA		JR NC,-26h

00000F0C: 06 FC		LD B,FCh
00000F0E: FE C4		CP C4h
00000F10: 30 D4		JR NC,-2Ch

00000F12: 06 13		LD B,13h
00000F14: FE C1		CP C1h
00000F16: 30 CE		JR NC,-32h

00000F18: FE C0		CP C0h
00000F1A: 20 CC		JR NZ,-34h

00000F1C: 3E 17		LD A,17h
00000F1E: 18 C7		JR -39h


;--------------------------
; THE 'NEW' COMMAND ROUTINE
;--------------------------
;
;

;; NEW
00000F20: CD 62 0D	CALL 0D62h			; routine SET-FAST
00000F23: 2A 04 40	LD HL,(4004h)		; fetch value of system variable RAMTOP
00000F26: 18 11		JR +11h				; jump forcefully to COLD BOOT

; ENTRY for BOOT/RESET  (address '0')
00000F28: 1F		RRA					; load ENTER key bit to CARRY to choose between COLD/WARM boot mode
00000F29: 2F		CPL
00000F2A: 32 09 40	LD (4009h),A   		; VERSN / BERG
00000F2D: 30 07		JR NC,+07h			

00000F2F: 3A 7D 40	LD A,(407Dh)		; D-FILE

00000F32: FE 76		CP 76h				; Check for NEWLINE
00000F34: 28 2D		JR Z,+2Dh			; jump if LAMBDA video mem looks correctly initialized (warm boot ?)

00000F36: 21 00 C0	LD HL,C000h			; set HL to the max possible RAM address

;; COLD BOOT
00000F39: 31 67 40	LD SP,4067h
00000F3C: CD B0 0B	CALL 0BB0h			; ALERT BEEP


;------------------------
; THE 'RAM CHECK' ROUTINE
;------------------------

00000F3F: 2B		DEC HL
00000F40: 3E 3F		LD A,3Fh
00000F42: 5D		LD E,L
00000F43: 54		LD D,H
;; RAM-FILL
00000F44: 36 FF		LD (HL),FFh
00000F46: 2B		DEC HL
00000F47: BC		CP H
00000F48: 38 FA		JR C,-06h			; to RAM-FILL

;; RAM-READ
00000F4A: AF		XOR A
00000F4B: ED 52		SBC HL,DE
00000F4D: 19		ADD HL,DE
00000F4E: 23		INC HL
00000F4F: 30 06		JR NC,+06h			; to SET-TOP

00000F51: 34		INC (HL)
00000F52: 20 03		JR NZ,+03h			; to SET-TOP
00000F54: BE		CP (HL)
00000F55: 28 F3		JR Z,-0Dh			; to RAM-READ

;; SET-TOP
00000F57: 22 04 40	LD (4004h),HL		; set system variable RAMTOP to first byte above the BASIC system area.

;-----------------------------
; THE 'INITIALIZATION' ROUTINE
;-----------------------------
;
;

;; INITIAL
00000F5A: 21 96 43	LD HL,4396h				; The first location after System Variables -> default program position (17302)
00000F5D: 22 0C 40	LD (400Ch),HL			; PROGRAM
00000F60: CD 36 14	CALL 1436h				; Init PROGRAM and VARS and CLEAR
00000F63: ED 56		IM 1
00000F65: AF		XOR A
00000F66: 32 19 40	LD (4019h),A			; X_PTR_high
00000F69: 32 2D 40	LD (402Dh),A			; FLAGX
00000F6C: 32 01 30	LD (3001h),A			; Enable COLOR module (if present);  writing to 3000h would disable it.
00000F6F: FD 21 00 40	LD IY,4000h			; set IY to the start of RAM so that the system variables can be indexed.
00000F73: FD 36 7D 76	LD (IY+7Dh),76h		; insert NEWLINE (HALT instruction) in the first D-FILE byte
00000F77: FD CB 35 FE	SET 7,(IY+35h)
00000F7B: FD 36 3B 40	LD (IY+3Bh),40h		; set CDFLAG 0100 0000
00000F7F: FD 36 21 19	LD (IY+21h),19h		; set MUNIT (tempo) to 25
00000F83: FD 36 37 F0	LD (IY+37h),F0h		; LAMBDA-VAR +1
00000F87: FD 36 08 07	LD (IY+08h),07h		; PPC high

00000F8B: 2A 04 40	LD HL,(4004h)			; fetch system variable RAMTOP.
00000F8E: 2B		DEC HL					; point to last system byte.
00000F8F: 36 AA		LD (HL),AAh				; make GO SUB end-marker $3E - too high for high order byte of line number.
											; (is 3Fh on ZX80 and 3Eh on ZX81)
00000F91: 2B		DEC HL					; point to unimportant low-order byte.
00000F92: F9		LD SP,HL				; and initialize the stack-pointer to this location.
00000F93: E5		PUSH HL					; HL now holds the current machine stack
00000F94: ED 73 02 40	LD (4002h),SP		; set the error stack pointer ERR_SP to the base of the now empty machine stack.
00000F98: E1		POP HL
00000F99: CD EB 06	CALL 06EBh				; initialize BORDER
00000F9C: CD 7D 1C	CALL 1C7Dh				; routine CLS
00000F9F: CD B0 0B	CALL 0BB0h				; ALERT BEEP
00000FA2: CD A9 12	CALL 12A9h				; routine SLOW/FAST
00000FA5: FD CB 09 46	BIT 0,(IY+09h)		; VERSN / BERG
00000FA9: C2 00 20	JP NZ,2000h

00000FAC: 3A 96 43	LD A,(4396h)			; The first location after System Variables -> default program position (17302)
00000FAF: 3C		INC A
00000FB0: C2 63 18	JP NZ,1863h				; to N/L-ONLY

00000FB3: 3E B7		LD A,B7h				; (inverse) 'R'
00000FB5: DF		RST 18h					; PRINT-A
00000FB6: 3E AA		LD A,AAh				; (inverse) 'E'
00000FB8: DF		RST 18h					; PRINT-A
00000FB9: 3E A6		LD A,A6h				; (inverse) 'A'
00000FBB: DF		RST 18h					; PRINT-A
00000FBC: 3E A9		LD A,A9h				; (inverse) 'D'
00000FBE: DF		RST 18h					; PRINT-A
00000FBF: 3E BE		LD A,BEh				; (inverse) 'Y'
00000FC1: DF		RST 18h					; PRINT-A

00000FC2: CD D4 13	CALL 13D4h				; routine CURSOR-IN inserts the cursor and end-marker
											; in the Edit Line also setting size of lower display to two lines.
00000FC5: 18 3D		JR +3Dh

;--------------------------
; THE 'NEWLINE KEY' ROUTINE
;--------------------------
;
;

;; N/L-KEY
00000FC7: CD 54 14	CALL 1454h				; routine LINE-ENDS
00000FCA: FD CB 2D 6E	BIT 5,(IY+2Dh)      ; FLAGX
00000FCE: 20 F2		JR NZ,-0Eh

00000FD0: CD E0 0D	CALL 0DE0h				; switch the output from screen to workspace buffer 
00000FD3: CD 93 12	CALL 1293h
00000FD6: 23		INC HL
00000FD7: 7B		LD A,E
00000FD8: B2		OR D
00000FD9: 28 E7		JR Z,-19h
00000FDB: CD 87 04	CALL 0487h
00000FDE: 4E		LD C,(HL)
00000FDF: 23		INC HL
00000FE0: 46		LD B,(HL)
00000FE1: 23		INC HL
00000FE2: EB		EX DE,HL
00000FE3: 21 30 03	LD HL,0330h			; location for STOP-LINE
00000FE6: E5		PUSH HL
00000FE7: 2A 0E 40	LD HL,(400Eh)		; DF_CC
00000FEA: 36 7F		LD (HL),7Fh
00000FEC: 23		INC HL
00000FED: 22 1C 40	LD (401Ch),HL		; STKEND low
00000FF0: CD F5 13	CALL 13F5h			; TEST-ROOM
00000FF3: EB		EX DE,HL
00000FF4: ED B0		LDIR
00000FF6: EB		EX DE,HL
00000FF7: CD E1 13	CALL 13E1h			; SET-STK-B
00000FFA: 18 74		JR +74h
00000FFC: 3A 07 40	LD A,(4007h)		; PPC low / ERR NR
00000FFF: FE 03		CP 03h
00001001: CA 30 03	JP Z,0330h			; STOP-LINE

;; LOWER
00001004: 2A 14 40	LD HL,(4014h)		; fetch edit line start from E_LINE.
;; EACH-CHAR
00001007: 7E		LD A,(HL)			; fetch a character from edit line.
00001008: FE 7E		CP 7Eh				; compare to the number marker.
0000100A: 28 23		JR Z,+23h			; SKIP-NUM - skip the 6 invisible bytes
;; END-LINE
0000100C: 23		INC HL
0000100D: FE 76		CP 76h
0000100F: 20 F6		JR NZ,-0Ah			; to EACH-CHAR

00001011: CD 54 14	CALL 1454h				; routine LINE-ENDS
00001014: FD 36 07 FF	LD (IY+07h),FFh		; PPC low
00001018: 2A 14 40	LD HL,(4014h)			; E_LINE
0000101B: CD D8 04	CALL 04D8h
0000101E: FD CB 07 76	BIT 6,(IY+07h)		; PPC low

00001022: C2 24 12	JP NZ,1224h
00001025: 21 22 40	LD HL,4022h				; DF_SZ
00001028: CB 66		BIT 4,(HL)
0000102A: 20 F6		JR NZ,-0Ah

0000102C: 34		INC (HL)
0000102D: 18 E2		JR -1Eh
;; SKIP-NUM
0000102F: 01 06 00	LD BC,0006h				; else six invisible bytes to be removed.
00001032: CD 77 01	CALL 0177h				; routine RECLAIM-2
00001035: 18 D0		JR -30h					; back to EACH-CHAR

00001037: CD 4A 14	CALL 144Ah				; ERROR-1
0000103A: 07		; "II" - Illegal Input

0000103B: 3A 37 40	LD A,(4037h)			; LAMBDA-VAR +1
0000103E: 17		RLA
0000103F: 38 F6		JR C,-0Ah
00001041: 01 02 00	LD BC,0002h
00001044: 3A 1E 40	LD A,(401Eh)			; BREG/FLAGS
00001047: 21 2D 40	LD HL,402Dh				; FLAGX
0000104A: CB B6		RES 6,(HL)
0000104C: CB EE		SET 5,(HL)
0000104E: E6 40		AND 40h
00001050: 20 02		JR NZ,+02h
00001052: CB 21		SLA C
00001054: B6		OR (HL)
00001055: 77		LD (HL),A
00001056: CD 45 14	CALL 1445h				; X-TEMP
00001059: CD DD 0B	CALL 0BDDh				; BC-SPACES
0000105C: CB 51		BIT 2,C
0000105E: 36 76		LD (HL),76h
00001060: 2B		DEC HL
00001061: 28 05		JR Z,+05h
00001063: 3E 0B		LD A,0Bh
00001065: 77		LD (HL),A
00001066: 12		LD (DE),A
00001067: 2B		DEC HL
00001068: 36 7F		LD (HL),7Fh
0000106A: 2A 39 40	LD HL,(4039h)			; S_POSN_x
0000106D: 22 30 40	LD (4030h),HL			; T_ADDR
00001070: D1		POP DE
00001071: 18 91		JR -6Fh
 
00001073: FD CB 2D 6E	BIT 5,(IY+2Dh)      ; FLAGX
00001077: 20 8B		JR NZ,-75h

00001079: CD E0 0D	CALL 0DE0h				; switch the output from screen to workspace buffer 
0000107C: 11 0A 00	LD DE,000Ah				; 10
0000107F: 19		ADD HL,DE
00001080: EB		EX DE,HL
00001081: 21 0F 27	LD HL,270Fh				; 9999
00001084: A7		AND A
00001085: ED 52		SBC HL,DE
00001087: 30 03		JR NC,+03h
00001089: 11 0F 27	LD DE,270Fh				; 9999
0000108C: CD 87 04	CALL 0487h
0000108F: 2A 0E 40	LD HL,(400Eh)			; DF_CC
00001092: CD DB 13	CALL 13DBh
00001095: 18 DA		JR -26h

; -----------------------------
; THE 'GRAPHIC' CHARACTER CODES
; -----------------------------
; (start from position Z,X,C,V..)

;; K-GRAPH
00001097: 
		DEFB 83h
		DEFB 03h
		DEFB 05h
		DEFB 85h
0000109B:
		DEFB 08h
		DEFB 0Ah
		DEFB 09h
		DEFB 8Ah
		DEFB 89h	
000010A0:
		DEFB 01h
		DEFB 02h
		DEFB 04h
		DEFB 87h
		DEFB 81h
000010A5:
		DEFB 8Fh
		DEFB 8Ch
		DEFB 8Eh
		DEFB 8Dh
		DEFB 8Bh
000010AA:
		DEFB 94h
		DEFB 91h
		DEFB 90h
		DEFB 9Ah
		DEFB 99h
000010AF:
		DEFB 92h
		DEFB 93h
		DEFB 07h
		DEFB 84h
		DEFB 82h
000010B4:
		DEFB 78h
		DEFB 95h
		DEFB 96h
		DEFB 97h
		DEFB 98h
000010B9:
		DEFB 78h
		DEFB 77h
		DEFB 78h
		DEFB 86h
		DEFB 06h


;------------------------------------
; Perform comparison 
;------------------------------------
; True binary operations.
;
; A single entry point is used to evaluate six numeric and six string
; comparisons. On entry, the calculator literal is in the B register and
; the two numeric values, or the two string parameters, are on the
; calculator stack.
; The individual bits of the literal are manipulated to group similar
; operations although the SUB 8 instruction does nothing useful and merely
; alters the string test bit.
; Numbers are compared by subtracting one from the other, strings are
; compared by comparing every character until a mismatch, or the end of one
; or both, is reached.
;
; Numeric Comparisons.
; --------------------
; The 'x>y' example is the easiest as it employs straight-thru logic.
; Number y is subtracted from x and the result tested for greater-0 yielding
; a final value 1 (true) or 0 (false).
; For 'x<y' the same logic is used but the two values are first swapped on the
; calculator stack.
; For 'x=y' NOT is applied to the subtraction result yielding true if the
; difference was zero and false with anything else.
; The first three numeric comparisons are just the opposite of the last three
; so the same processing steps are used and then a final NOT is applied.
;
; literal    Test   No  sub 8       ExOrNot  1st RRCA  exch sub  ?   End-Tests
; =========  ====   == ======== === ======== ========  ==== ===  =  === === ===
; no-l-eql   x<=y   09 00000001 dec 00000000 00000000  ---- x-y  ?  --- >0? NOT
; no-gr-eql  x>=y   0A 00000010 dec 00000001 10000000c swap y-x  ?  --- >0? NOT
; nos-neql   x<>y   0B 00000011 dec 00000010 00000001  ---- x-y  ?  NOT --- NOT
; no-grtr    x>y    0C 00000100  -  00000100 00000010  ---- x-y  ?  --- >0? ---
; no-less    x<y    0D 00000101  -  00000101 10000010c swap y-x  ?  --- >0? ---
; nos-eql    x=y    0E 00000110  -  00000110 00000011  ---- x-y  ?  NOT --- ---
;
;                                                           comp -> C/F
;                                                           ====    ===
; str-l-eql  x$<=y$ 11 00001001 dec 00001000 00000100  ---- x$y$ 0  !or >0? NOT
; str-gr-eql x$>=y$ 12 00001010 dec 00001001 10000100c swap y$x$ 0  !or >0? NOT
; strs-neql  x$<>y$ 13 00001011 dec 00001010 00000101  ---- x$y$ 0  !or >0? NOT
; str-grtr   x$>y$  14 00001100  -  00001100 00000110  ---- x$y$ 0  !or >0? ---
; str-less   x$<y$  15 00001101  -  00001101 10000110c swap y$x$ 0  !or >0? ---
; strs-eql   x$=y$  16 00001110  -  00001110 00000111  ---- x$y$ 0  !or >0? ---
;
; String comparisons are a little different in that the eql/neql carry flag
; from the 2nd RRCA is, as before, fed into the first of the end tests but
; along the way it gets modified by the comparison process. The result on the
; stack always starts off as zero and the carry fed in determines if NOT is
; applied to it. So the only time the greater-0 test is applied is if the
; stack holds zero which is not very efficient as the test will always yield
; zero. The most likely explanation is that there were once separate end tests
; for numbers and strings.

;; no-l-eql,etc.
000010BE: 0F		RRCA
000010BF: D6 24		SUB 24h
000010C1: CB 5F		BIT 3,A
000010C3: CB 9F		RES 3,A
000010C5: 4F		LD C,A
000010C6: 06 00		LD B,00h
000010C8: 21 49 00	LD HL,0049h				; conversion table (06 05 03 01 02 04)
000010CB: 09		ADD HL,BC
000010CC: 46		LD B,(HL)
000010CD: C5		PUSH BC
000010CE: 28 31		JR Z,+31h

000010D0: E7		RST 20h					; routine STK-FETCH gets 2nd string params
000010D1: D5		PUSH DE					; save start2 *.
000010D2: C5		PUSH BC					; and the length.
000010D3: E7		RST 20h					; routine STK-FETCH gets 1st string parameters - start in DE, length in BC.
000010D4: E1		POP HL					; restore length of second to HL.
000010D5: E5		PUSH HL
000010D6: ED 42		SBC HL,BC
000010D8: 30 02		JR NC,+02h			; jp to 10DCh!  (E1h = POP HL)

000010DA: C1		POP BC
000010DB: 3E E1		LD A,E1h
000010DD: E1		POP HL
000010DE: 3F		CCF
000010DF: F5		PUSH AF
000010E0: 78		LD A,B

; ---

000010E1: B1		OR C
000010E2: 28 09		JR Z,+09h		

; both strings have at least one character left.

000010E4: 1A		LD A,(DE)
000010E5: BE		CP (HL)
000010E6: 0B		DEC BC
000010E7: 23		INC HL
000010E8: 13		INC DE
000010E9: 28 F5		JR Z,-0Bh
000010EB: E1		POP HL

000010EC: 3E F1		LD A,F1h
000010EE: 3E 04		LD A,04h
000010F0: 28 05		JR Z,+05h
000010F2: 3E 02		LD A,02h
000010F4: 38 01		JR C,+01h
000010F6: 3D		DEC A
000010F7: C1		POP BC
000010F8: A0		AND B
000010F9: 20 03		JR NZ,+03h

; ---

;; ZERO
000010FB: F7		RST 30h				; FP-CALC
000010FC: FA		;;stk-zero & end-calc
000010FD: C9		RET

; ---

;; ONE
000010FE: F7		RST 30h				; FP-CALC
000010FF: F9		;;stk-one & end-calc
00001100: C9		RET


; delete the Boolean value on the calculator stack.

00001101: F7		RST 30h				; FP-CALC
00001102: 1E		;;subtract
00001102: B5		;;delete & end-calc

00001104: EB		EX DE,HL
00001105: 23		INC HL
00001106: CB 16		RL (HL)
00001108: 2B		DEC HL
00001109: 34		INC (HL)
0000110A: 35		DEC (HL)
0000110B: 18 E1		JR -1Fh

0000110D: CB B1		RES 6,C
0000110F: CD F0 0D	CALL 0DF0h			; routine STK-VAR
00001112: C3 3E 0A	JP 0A3Eh			; routine CHECK-2

00001115: CD A6 0A	CALL 0AA6h			; routine LOOK-VARS
00001118: 20 2C		JR NZ,+2Ch
0000111A: EF		RST 28h				; routine SYNTAX-Z
0000111B: 28 F0		JR Z,-10h

0000111D: C5		PUSH BC
0000111E: D4 6A 01	CALL NC,016Ah
00001121: 11 05 00	LD DE,0005h
00001124: C1		POP BC
00001125: 42		LD B,D
00001126: CB F9		SET 7,C
00001128: CB 71		BIT 6,C
0000112A: C5		PUSH BC
0000112B: 28 02		JR Z,+02h
0000112D: 1E 01		LD E,01h
0000112F: CF		RST 08h				; NEXT-CHAR
00001130: 26 80		LD H,80h
00001132: CD 1F 0E	CALL 0E1Fh
00001135: E1		POP HL
00001136: 24		INC H
00001137: C5		PUSH BC
00001138: E5		PUSH HL
00001139: 69		LD L,C
0000113A: 60		LD H,B
0000113B: CD A5 13	CALL 13A5h
0000113E: EB		EX DE,HL
0000113F: D7		RST 10h				; GET-CHAR
00001140: FE 1A		CP 1Ah
00001142: 28 EB		JR Z,-15h

00001144: EE 11		XOR 11h
00001146: C2 42 0A	JP NZ,0A42h			; to REPORT-C

00001149: C1		POP BC
0000114A: D5		PUSH DE
0000114B: C5		PUSH BC
0000114C: 67		LD H,A
0000114D: 68		LD L,B
0000114E: 23		INC HL
0000114F: 23		INC HL
00001150: 29		ADD HL,HL
00001151: 19		ADD HL,DE
00001152: DA 08 14	JP C,1408h
00001155: 79		LD A,C
00001156: 4D		LD C,L
00001157: 44		LD B,H
00001158: 2A 14 40	LD HL,(4014h)		; E_LINE
0000115B: 2B		DEC HL
0000115C: C5		PUSH BC
0000115D: CD B5 1C	CALL 1CB5h			; MAKE-ROOM
00001160: C1		POP BC
00001161: 23		INC HL
00001162: 0B		DEC BC
00001163: 77		LD (HL),A
00001164: 0B		DEC BC
00001165: 23		INC HL
00001166: 0B		DEC BC
00001167: 71		LD (HL),C
00001168: 23		INC HL
00001169: 70		LD (HL),B
0000116A: 23		INC HL
0000116B: F1		POP AF
0000116C: 77		LD (HL),A
0000116D: C1		POP BC
0000116E: 6B		LD L,E
0000116F: 62		LD H,D
00001170: 36 00		LD (HL),00h
00001172: 1B		DEC DE
00001173: ED B8		LDDR
00001175: 47		LD B,A
00001176: D1		POP DE
00001177: 72		LD (HL),D
00001178: 2B		DEC HL
00001179: 73		LD (HL),E
0000117A: 2B		DEC HL
0000117B: 10 F9		DJNZ -07h
0000117D: C9		RET


;----------------------
; THE 'COSINE' FUNCTION
;----------------------
; (offset $$$: 'cos')
; Cosines are calculated as the sine of the opposite angle rectifying the 
; sign depending on the quadrant rules. 
;
;
;           /|
;        h /y|
;         /  |o
;        /x  |
;       /----|    
;         a
;
; The cosine of angle x is the adjacent side (a) divided by the hypotenuse 1.
; However if we examine angle y then a/h is the sine of that angle.
; Since angle x plus angle y equals a right-angle, we can find angle y by 
; subtracting angle x from pi/2.
; However it's just as easy to reduce the argument first and subtract the
; reduced argument from the value 1 (a reduced right-angle).
; It's even easier to subtract 1 from the angle and rectify the sign.
; In fact, after reducing the argument, the absolute value of the argument
; is used and rectified using the test result stored in mem-0 by 'get-argt'
; for that purpose.

;; cos
0000117E: F7		RST 30h				; FP-CALC			angle in radians.
0000117F: 07		;;get-argt
00001180: 18		;;abs
00001180: 79		;;stk-one
00001182: 1E		;;subtract
00001183: 40		;;get-mem-0
00001184: 34		;;jump-true
00001185: 06		;;fwd to C-ENT
00001186: 09		;;negate
00001187: 04		;;jump
00001188: 03		;;fwd to C-ENT


;--------------------
; THE 'SINE' FUNCTION
;--------------------
; (offset $??: 'sin')
; This is a fundamental transcendental function from which others such as cos
; and tan are directly, or indirectly, derived.
; It uses the series generator to produce Chebyshev polynomials.
;
;
;           /|
;        1 / |
;         /  |x
;        /a  |
;       /----|    
;         y
;
; The 'get-argt' function is designed to modify the angle and its sign 
; in line with the desired sine value and afterwards it can launch straight
; into common code.

;; sin
00001189: F7		RST 30h				; 		angle in radians
0000118A: 07		;;get-argt							reduce - sign now correct.
;; C-ENT
0000118B: 01 		;;duplicate
0000118C: 01 		;;duplicate
0000118D: 1F		;;multiply
0000118F: 01 		;;duplicate
0000118F: 2A		;;addition
00001190: 79		;;stk-one
00001191: 1E		;;subtract

00001192: 66		;;series-06
00001193: 14		;;Exponent: $64, Bytes: 1
00001194: E6		;;(+00,+00,+00)
00001195: 5C		;;Exponent: $6C, Bytes: 2
00001196: 1F 0B		;;(+00,+00)
00001198: A3		;;Exponent: $73, Bytes: 3
00001199: 8F 38 EE	;;(+00)
0000119C: E9		;;Exponent: $79, Bytes: 4
0000119D: 15 63 BB 23
000011A1: EE		;;Exponent: $7E, Bytes: 4
000011A2: 92 0D CD ED
000011A6: F1		;;Exponent: $81, Bytes: 4
000011A7: 23 5D 1B EA
000011AB: 9F		;;multiply & end-calc
000011AC: C9		RET


;; PLOT
000011AD: CD D9 14	CALL 14D9h				; PLOT/UNP
000011B0: B2		OR D

000011B1: FE 08		CP 08h
000011B3: 38 02		JR C,+02h

000011B5: EE 8F		XOR 8Fh

;; PLOT-END
000011B7: DF		RST 18h					; PRINT-A
000011B8: C9		RET

;; UNPLOT
000011B9: CD D9 14	CALL 14D9h				; PLOT/UNP
000011BC: 2F		CPL
000011BD: B2		OR D
000011BE: 2F		CPL
000011BF: 18 F0		JR -10h					; to UNPLOT

; ------------------------------------------
; THE 'DECIMAL TO FLOATING POINT' SUBROUTINE
; ------------------------------------------
;

;; DEC-TO-FP
000011C1: CD 44 1C	CALL 1C44h				; routine INT-TO-FP
000011C4: FE 1B		CP 1Bh					; is character a '.' ?
000011C6: 20 13		JR NZ,+13h				; forward if not to E-FORMAT

000011C8: F7		RST 30h					; FP-CALC
000011C9: 79		;;stk-one
000011CA: 50		;;st-mem-0
000011CB: B5		;;delete & end-calc
000011CC: 18 07		JR +07h					; forward to NXT-DGT-1


;----------
; loop back till exhausted from NXT-DGT-1
000011CE: F7		RST 30h					; FP-CALC
000011CF: 40		;;get-mem-0
000011D0: 77		;;stk-ten
000011D1: 20		;;division
000011D2: 50		;;st-mem-0
000011D3: 1F		;;multiply
000011D4: AA		;;addition & end-calc

;; NXT-DGT-1
000011D5: CF		RST 08h				; NEXT-CHAR
000011D6: CD 75 07	CALL 0775h			; routine STK-DIGIT
000011D9: 30 F3		JR NC,-0Dh			; loop back till exhausted
;----------

;; E-FORMAT
000011DB: EE 2A		XOR 2Ah				; is character 'E' ?
000011DD: C0		RET NZ				; return if not

000011DE: 47		LD B,A				; set B to zero

000011DF: CF		RST 08h				; NEXT-CHAR
000011E0: FE 15		CP 15h				; is character a '+' ?
000011E2: 28 05		JR Z,+05h			; if so, jp to ST-E-POSITIVE

000011E4: FE 16		CP 16h				; is it a '-' ?
000011E6: 20 02		JR NZ,+02h			; jp if not to ST-E-POSITIVE

000011E8: 04		INC B				; mark for negative sign

;; ST-E-POSITIVE
000011E9: CF		RST 08h				; NEXT-CHAR

;; ST-E-PART
000011EA: C5		PUSH BC
000011EB: CD 44 1C	CALL 1C44h			; routine INT-TO-FP
000011EE: C1		POP BC
000011EF: 10 02		DJNZ +02h			; jp if not negative

000011F1: F7		RST 30h				; FP-CALC
000011F2: 09		;;negate & end-calc


; -------------------------------------------
; THE 'E-FORMAT TO FLOATING POINT' SUBROUTINE
; -------------------------------------------
; (Offset $??: 'e-to-fp')
; invoked from DEC-TO-FP and PRINT-FP.
; e.g 2.3E4 is 23000.
; This subroutine evaluates xEm where m is a positive or negative integer.
; At a simple level x is multiplied by ten for every unit of m.
; If the decimal exponent m is negative then x is divided by ten for each unit.
;
; On entry in the ZX81, m, the exponent, is the 'last value', and the
; floating-point decimal mantissa is beneath it.


;; e-to-fp
000011F3: F7		RST 30h				; FP-CALC
000011F4: 01		;;duplicate
000011F5: 03		;;less-0
000011F6: 50		;;st-mem-0
000011F7: 35		;;delete
000011F8: 18		;;abs

;; E-LOOP
000011F9: 79		;;stk-one
000011FA: 1E		;;subtract
000011FB: 01		;;duplicate
000011FC: 03		;;less-0
000011FD: 34		;;jump-true
000011FE: 21		;;... to E-END
000011FF: 01		;;duplicate
00001200: 05		;;stk-data
00001201: 33		;;Exponent: $83, Bytes: 1
00001202: 20		;;(+00,+00,+00)   ... $40 on ZX81
00001203: 1E		;;subtract
00001204: 01		;;duplicate
00001205: 03		;;less-0
00001206: 34		;;jump-true
00001207: 0B		;;... to E-LOW

00001208: 33		;;exchange
00001209: 35		;;delete
0000120A: 33		;;exchange
0000120B: 05		;;stk-data
0000120C: 40		;;Exponent $?? Bytes: 3
0000120D: 44 74 24		;;(+00)
00001210: 04		;;jump
00001211: 04		;;... to E-CHUNK

;; E-LOW
00001212: 35		;;delete
00001213: 33		;;exchange
00001214: 77		;;stk-ten

;; E-CHUNK
00001215: 40		;;get-mem-0
00001216: 34		;;jump-true
00001217: 04		;;to E-DIVSN

00001218: 1F		;;multiply
00001219: 04		;;jump
0000121A: 02		;;to E-SWAP

;; E-DIVSN
0000121B: 20		;;division

;; E-SWAP
0000121C: 33		;;exchange		
0000121D: 04		;;jump
0000121E: DB		;;to E-LOOP
0000121F: B5		;;delete & end-calc

00001220: C9		RET


00001221: CD D4 13	CALL 13D4h				; routine CURSOR-IN
00001224: 21 3B 40	LD HL,403Bh				; CDFLAG
00001227: 22 18 40	LD (4018h),HL			; X_PTR
0000122A: CB 7E		BIT 7,(HL)
0000122C: CC B6 12	CALL Z,12B6h
0000122F: CB 46		BIT 0,(HL)
00001231: 28 FC		JR Z,-04h
00001233: CD 70 18	CALL 1870h
00001236: 30 EC		JR NC,-14h
00001238: FD CB 3B 6E	BIT 5,(IY+3Bh)		; CDFLAG
0000123C: 20 1D		JR NZ,+1Dh
0000123E: D5		PUSH DE
0000123F: E5		PUSH HL
00001240: CD 62 0D	CALL 0D62h				; routine SET-FAST
00001243: C6 14		ADD 14h
00001245: 5F		LD E,A
00001246: 01 CE 04	LD BC,04CEh				; 1230
00001249: FD CB 28 6E	BIT 5,(IY+28h)		; MARGIN
0000124D: 20 03		JR NZ,+03h
0000124F: 01 06 04	LD BC,0406h				; 1030
00001252: CD A2 0B	CALL 0BA2h				; SOUND-ENGINE (play value in E, length BC)
00001255: CD A9 12	CALL 12A9h				; routine SLOW/FAST
00001258: E1		POP HL
00001259: D1		POP DE
0000125A: 7B		LD A,E
0000125B: FD CB 3B 66	BIT 4,(IY+3Bh)		; CDFLAG
0000125F: 28 08		JR Z,+08h
00001261: FE 28		CP 28h
00001263: 38 10		JR C,+10h
00001265: 21 6F 10	LD HL,106Fh
00001268: 19		ADD HL,DE
00001269: 7E		LD A,(HL)
0000126A: FE F0		CP F0h
0000126C: EA B8 06	JP PE,06B8h
0000126F: CD 96 03	CALL 0396h
00001272: C3 04 10	JP 1004h				; to LOWER

00001275: 7E		LD A,(HL)
00001276: FE 76		CP 76h
00001278: CB FF		SET 7,A
0000127A: 20 F3		JR NZ,-0Dh

0000127C: FD CB 3B A6	RES 4,(IY+3Bh)		; CDFLAG
00001280: 18 F0		JR -10h

00001282: FD CB 3B E6	SET 4,(IY+3Bh)		; CDFLAG
00001286: 18 EA		JR -16h

;------------------------
; Handle unary minus 
;------------------------
; Unary so on entry HL points to last value, DE to STKEND.

;; negate
00001288: 7E		LD A,(HL)				; fetch exponent of last value on the calculator stack
00001289: B7		OR A					; test it.
0000128A: C8		RET Z					; return if zero.

0000128B: 23		INC HL					; address the byte with the sign bit.
0000128C: 3E 80		LD A,80h				
0000128E: AE		XOR (HL)				; toggle the sign bit.
0000128F: 77		LD (HL),A				; put it back.
00001290: 2B		DEC HL					; point to last value again.
00001291: C9		RET

;; INC HL, LINE-ADDR, AND LINE-NO
00001292: 23		INC HL
00001293: CD 36 0B	CALL 0B36h				; routine LINE-ADDR (HL)
;; LINE-NO
00001296: 3E C0		LD A,C0h
00001298: A6		AND (HL)
00001299: 28 06		JR Z,+06h				; to ZERO-DE
0000129B: 21 A9 13	LD HL,13A9h
0000129E: EB		EX DE,HL
0000129F: 18 F7		JR -09h
;; ZERO-DE
000012A1: 56		LD D,(HL)
000012A2: 23		INC HL
000012A3: 5E		LD E,(HL)
000012A4: C9		RET
;
;; SLOW MODE
000012A5: FD CB 3B F6	SET 6,(IY+3Bh)		; CDFLAG

;; SLOW/FAST  (L0207 on ZX81)
000012A9: 21 3B 40	LD HL,403Bh 	       ; system variable CDFLAG
000012AC: 7E		LD A,(HL)
000012AD: 07		RLCA
000012AE: AE		XOR (HL)
000012AF: F0		RET P
000012B0: CB FE		SET 7,(HL)
000012B2: F5		PUSH AF
000012B3: E5		PUSH HL
000012B4: D5		PUSH DE
000012B5: C5		PUSH BC
000012B6: AF		XOR A
000012B7: 08		EX AF,AF'
000012B8: D3 FE		OUTA (FEh)			; enable the NMI generator.
000012BA: 76		HALT
000012BB: D3 FD		OUTA (FDh)			; turn off the NMI generator.
000012BD: 23		INC HL
000012BE: 23		INC HL
000012BF: 23		INC HL

;; DISPLAY-1
000012C0: 2A 34 40	LD HL,(4034h)		; FRAMES
000012C3: 7C		LD A,H
000012C4: E6 7F		AND 7Fh
000012C6: B5		OR L
000012C7: 7C		LD A,H
000012C8: 20 03		JR NZ,+03h			; to ANOTHER
000012CA: 17		RLA
000012CB: 18 03		JR +03h				; to OVER-NC

; ---

;; ANOTHER
000012CD: 37		SCF
000012CE: 0E 00		LD C,00h

;; OVER-NC
000012D0: 67		LD H,A
000012D1: 2B		DEC HL
000012D2: 22 34 40	LD (4034h),HL		; FRAMES
000012D5: D0		RET NC
000012D6: 7D		LD A,L
000012D7: 2A 7B 40	LD HL,(407Bh)		; BLINK
000012DA: CB 26		SLA (HL)
000012DC: 17		RLA
000012DD: 17		RLA
000012DE: 17		RLA
000012DF: 17		RLA
000012E0: CB 1E		RR (HL)

;; DISPLAY-2
000012E2: CD 74 0D	CALL 0D74h			; routine KEYBOARD
000012E5: ED 4B 25 40	LD BC,(4025h)	; LAST_K
000012E9: 22 25 40	LD (4025h),HL		; LAST_K
000012EC: 50		LD D,B
000012ED: 3E 02		LD A,02h
000012EF: 80		ADD B
000012F0: ED 42		SBC HL,BC
000012F2: 06 09		LD B,09h
000012F4: 3A 27 40	LD A,(4027h)		; DEBOUNCE
000012F7: B5		OR L
000012F8: B4		OR H
000012F9: 21 3B 40	LD HL,403Bh			; CDFLAG
000012FC: CB 86		RES 0,(HL)
000012FE: 20 08		JR NZ,+08h			; to NO-KEY
00001300: CB C6		SET 0,(HL)
00001302: CB 7E		BIT 7,(HL)
00001304: C8		RET Z
00001305: 05		DEC B
00001306: 05		DEC B
00001307: 37		SCF

;; NO-KEY
00001308: CB 10		RL B
0000130A: 10 FE		DJNZ -02h
0000130C: 7A		LD A,D
0000130D: FE FE		CP FEh
0000130F: 9F		SBC A
00001310: 21 27 40	LD HL,4027h			; DEBOUNCE
00001313: B6		OR (HL)
00001314: E6 0F		AND 0Fh
00001316: 1F		RRA
00001317: 77		LD (HL),A
00001318: 29		ADD HL,HL
00001319: 29		ADD HL,HL
0000131A: 23		INC HL
0000131B: D3 FF		OUTA (FFh)			; terminate retrace
0000131D: 21 7D C0	LD HL,C07Dh			; point to upper 32K 'display file' ghosted copy
00001320: CD ED 01	CALL 01EDh			; routine DISPLAY-3
; ---

;; R-IX-1, on ZX81 it is the "famous" 0281h location
00001323: 01 19 01	LD BC,0119h			; on ZX81 C and B are inverted
00001326: 3A 00 00	LD A,(0000h)		; on ZX81.. LD A,R
00001329: 3E F5		LD A,F5h
0000132B: CD 66 16	CALL 1666h			; routine DISPLAY-5
0000132E: 00		NOP
0000132F: 00		NOP
00001330: 2B		DEC HL
00001331: CD ED 01	CALL 01EDh			; routine DISPLAY-3
; ---

;; R-IX-2, on ZX81 it is the "famous" 028Fh location
00001334: C3 C0 12	JP 12C0h			; to DISPLAY-1


;-------------------------
; THE 'SLICING' SUBROUTINE
;-------------------------
;
;

;; SLICING
00001337: EF		RST 28h					; routine SYNTAX-Z
00001338: 28 01		JR Z,+01h
0000133A: E7		RST 20h					; STK-FETCH
0000133B: CF		RST 08h					; NEXT-CHAR
0000133C: FE 11		CP 11h					; is it ')' ?
0000133E: 28 3B		JR Z,+3Bh				; forward if so to SL-STORE

00001340: 60		LD H,B					
00001341: 69		LD L,C
00001342: D5		PUSH DE
00001343: 11 01 00	LD DE,0001h
00001346: E5		PUSH HL
00001347: EE 41		XOR 41h
00001349: 28 0A		JR Z,+0Ah

0000134B: CD 1F 0E	CALL 0E1Fh
0000134E: 59		LD E,C
0000134F: 50		LD D,B
00001350: D7		RST 10h					; GET-CHAR
00001351: FE 41		CP 41h					; is it 'TO' ?
00001353: 20 0B		JR NZ,+0Bh

00001355: CF		RST 08h					; NEXT-CHAR
00001356: EE 11		XOR 11h
00001358: E1		POP HL
00001359: 28 0D		JR Z,+0Dh

0000135B: CD 1F 0E	CALL 0E1Fh
0000135E: D7		RST 10h					; GET-CHAR
0000135F: FE E1		CP E1h					; is it 'LPRINT' ?  (???)
00001361: EE 11		XOR 11h
00001363: C2 42 0A	JP NZ,0A42h				; to REPORT-C

00001366: 69		LD L,C
00001367: 60		LD H,B
00001368: FD CB 1E B6	RES 6,(IY+1Eh)		; BREG/FLAGS
0000136C: AF		XOR A
0000136D: ED 52		SBC HL,DE
0000136F: 4D		LD C,L
00001370: 44		LD B,H
00001371: 03		INC BC
00001372: 30 03		JR NC,+03h
00001374: 01 00 00	LD BC,0000h
00001377: E1		POP HL
00001378: 19		ADD HL,DE
00001379: EB		EX DE,HL
0000137A: 1B		DEC DE
0000137B: EF		RST 28h					; routine SYNTAX-Z
0000137C: C8		RET Z

;; STK-ST-0
0000137D: AF		XOR A
0000137E: 18 3C		JR +3Ch

;-------------------------------
; THE 'E-LINE NUMBER' SUBROUTINE
;-------------------------------
;
;

;; E-LINE-NO
00001380: 2A 14 40	LD HL,(4014h)			; E_LINE
00001383: CD 0D 00	CALL 000Dh				; TEMP-PTR2 + GET-CHAR
00001386: FD CB 2D 6E	BIT 5,(IY+2Dh)      ; FLAGX
0000138A: C0		RET NZ
0000138B: 21 5D 40	LD HL,405Dh				; MEMBOT
0000138E: 22 1C 40	LD (401Ch),HL			; STKEND low
00001391: CD 44 1C	CALL 1C44h				; routine INT-TO-FP
00001394: CD 55 05	CALL 0555h				; routine FP-TO-BC
00001397: 21 F0 D8	LD HL,D8F0h				; value '-10000'
0000139A: DA 42 0A	JP C,0A42h				; to REPORT-C

0000139D: 09		ADD HL,BC
0000139E: 38 FA		JR C,-06h
000013A0: BF		CP A
000013A1: 18 77		JR +77h

; --------------------------
; THE 'GET-HL*DE' SUBROUTINE
; --------------------------
;

;; GET-HL*DE
000013A3: EF		RST 28h		; routine SYNTAX-Z
000013A4: C8		RET Z
000013A5: 7D		LD A,L
000013A6: C5		PUSH BC
000013A7: 4C		LD C,H
; HL-LOOP
L000013A8: 21 00 00	LD HL,0000h
000013AB: 06 10		LD B,10h
000013AD: 29		ADD HL,HL
000013AE: 38 58		JR C,+58h
000013B0: 17		RLA
000013B1: CB 11		RL C
000013B3: 30 03		JR NC,+03h
000013B5: 19		ADD HL,DE
;; HL-END
000013B6: 38 50		JR C,+50h
;; HL-AGAIN
000013B8: 10 F3		DJNZ -0Dh
000013BA: C1		POP BC
000013BB: C9		RET

;---------------------------
; THE 'STK-STORE' SUBROUTINE
;---------------------------

;; STK-STO-$
000013BC: 2A 1C 40	LD HL,(401Ch)			; STKEND
000013BF: C5		PUSH BC
000013C0: CD F2 13	CALL 13F2h				; routine TEST-5-SP
000013C3: FD CB 1E B6	RES 6,(IY+1Eh)		; BREG/FLAGS
000013C7: 77		LD (HL),A
000013C8: 23		INC HL
000013C9: 73		LD (HL),E
000013CA: 23		INC HL
000013CB: 72		LD (HL),D
000013CC: 23		INC HL
000013CD: C1		POP BC
000013CE: 71		LD (HL),C
000013CF: 23		INC HL
000013D0: 70		LD (HL),B
000013D1: 23		INC HL
000013D2: 18 59		JR +59h

;------------------------
; THE 'CURSOR-IN' ROUTINE
;------------------------
; This routine is called to set the edit line to the minimum cursor/newline
; and to set STKEND, the start of free space, at the next position.

;; CURSOR-IN
000013D4: FD 36 22 02	LD (IY+22h),02h		; DF_SZ
000013D8: 2A 14 40	LD HL,(4014h)		; E_LINE
000013DB: 36 7F		LD (HL),7Fh
000013DD: 23		INC HL
000013DE: 36 76		LD (HL),76h
000013E0: 23		INC HL


;-----------------------
; THE 'SET-STK' ROUTINES
;-----------------------
;
;

;; SET-STK-B
000013E1: 22 1A 40	LD (401Ah),HL			; STKBOT
000013E4: 18 47		JR +47h					; to SET-STK-E


;----------------------------
; THE 'GO SUB' COMMAND ROUTINE
;----------------------------
;
;

;; GOSUB
000013E6: CD 2B 15	CALL 152Bh				; GOTO
000013E9: 2A 36 40	LD HL,(4036h)			; LAMBDA-VAR
000013EC: E3		EX HL,(SP)
000013ED: E5		PUSH HL
000013EE: ED 73 02 40	LD (4002h),SP		; ERR-SP

;-------------------------------
; THE 'TEST 5 SPACES' SUBROUTINE
;-------------------------------
; This routine is called from MOVE-FP, STK-CONST and STK-STORE to
; test that there is enough space between the calculator stack and the
; machine stack for another five-byte value. It returns with BC holding
; the value 5 ready for any subsequent LDIR.

;; TEST-5-SP
000013F2: 01 05 00	LD BC,0005h

;; TEST-ROOM
000013F5: E5		PUSH HL
000013F6: 2A 1C 40	LD HL,(401Ch)		; STKEND
000013F9: 09		ADD HL,BC
000013FA: 38 0C		JR C,+0Ch
000013FC: C5		PUSH BC
000013FD: 01 20 00	LD BC,0020h
00001400: 09		ADD HL,BC
00001401: 38 05		JR C,+05h
00001403: C1		POP BC
00001404: ED 72		SBC HL,SP
00001406: E1		POP HL
00001407: D8		RET C

00001408: 3E 03		LD A,03h
0000140A: 01 3E 00	LD BC,003Eh

0000140B: 3E 00		LD A,00h		; reusing the same bytes above: this line disappears if entry is 1408h
0000140D: 01 3E 02	LD BC,023Eh

;---------------------
; THE 'ERROR-2' BRANCH
;---------------------
; This is a continuation of the error restart.
; If the error occured in runtime then the error stack pointer will probably
; lead to an error report being printed unless it occured during input.
; If the error occured when checking syntax then the error stack pointer
; will be an editing routine and the position of the error will be shown
; when the lower screen is reprinted.

;; ERROR-2
00001410: ED 7B 02 40	LD SP,(4002h)		; set the stack pointer from ERR_SP
00001414: 32 07 40	LD (4007h),A			; PPC low / ERR NR
00001417: CD A9 12	CALL 12A9h				; routine SLOW/FAST selects slow mode.
; ..exit continuing via routine SET-MIN.


;-------------------------
; THE 'SET-MIN' SUBROUTINE
;-------------------------
;
;

;; SET-MIN
0000141A: 21 5D 40	LD HL,405Dh			; MEMBOT
0000141D: 22 1F 40	LD (401Fh),HL		; MEM
00001420: 2A 1A 40	LD HL,(401Ah)		; STKBOT
00001423: 18 08		JR +08h


;; STK-FETCH (cont)
00001425: 2B		DEC HL
00001426: 4E		LD C,(HL)
00001427: 2B		DEC HL
00001428: 56		LD D,(HL)
00001429: 2B		DEC HL
0000142A: 5E		LD E,(HL)
0000142B: 2B		DEC HL
0000142C: 7E		LD A,(HL)

;; SET-STK-E
0000142D: 22 1C 40	LD (401Ch),HL		; STKEND
00001430: C9		RET

;--------------------------
; THE 'RUN' COMMAND ROUTINE
;--------------------------
;
;

;; RUN
00001431: CD 2B 15	CALL 152Bh			; GOTO
00001434: 18 06		JR +06h

;; Init PROGRAM and VARS and CLEAR  (called while booting, HL points to PROGRAM)
00001436: 36 FF		LD (HL),FFh
00001438: 23		INC HL
00001439: 22 10 40	LD (4010h),HL		; VARS

;----------------------------
; THE 'CLEAR' COMMAND ROUTINE
;----------------------------
;
;

;; CLEAR
0000143C: 2A 10 40	LD HL,(4010h)		; VARS
0000143F: 36 80		LD (HL),80h
00001441: 23		INC HL
00001442: 22 14 40	LD (4014h),HL		; E_LINE

;------------------------
; THE 'X-TEMP' SUBROUTINE
;------------------------
;
;

;; X-TEMP
00001445: 2A 14 40	LD HL,(4014h)		; E_LINE
00001448: 18 97		JR -69h				; SET-STK-B


;--------------------
; THE 'ERROR' RESTART
;--------------------
; The error restart deals immediately with an error. ZX computers execute the 
; same code in runtime as when checking syntax. If the error occured while 
; running a program then a brief report is produced. If the error occured
; while entering a BASIC line or in input etc., then the error marker indicates
; the exact point at which the error lies.

;; ERROR-1
0000144A: E1		POP HL
0000144B: 7E		LD A,(HL)
0000144C: 2A 16 40	LD HL,(4016h)		; CH_ADD
0000144F: 22 18 40	LD (4018h),HL		; X_PTR
00001452: 18 BC		JR -44h

;---------------------------
; THE 'LINE-ENDS' SUBROUTINE
;---------------------------
;
;

;; LINE-ENDS
00001454: FD 46 22	LD B,(IY+22h)		; DF_SZ
00001457: C5		PUSH BC
00001458: CD 7F 1C	CALL 1C7Fh			; routine B-LINES (partial CLS)
0000145B: C1		POP BC
0000145C: 18 32		JR +32h

0000145E: 05		DEC B
0000145F: 0E 21		LD C,21h
00001461: 23		INC HL
00001462: 18 08		JR +08h

00001464: ED 4B 39 40	LD BC,(4039h)	; S_POSN_x
00001468: 2A 0E 40	LD HL,(400Eh)		; DF_CC
0000146B: 5F		LD E,A
0000146C: 78		LD A,B
0000146D: B7		OR A
0000146E: 28 9E		JR Z,-62h
00001470: FD BE 22	CP (IY+22h)	; DF_SZ
00001473: 28 99		JR Z,-67h
00001475: 7B		LD A,E
00001476: FE 76		CP 76h
00001478: 28 16		JR Z,+16h
0000147A: 0D		DEC C
0000147B: 28 E1		JR Z,-1Fh
0000147D: 77		LD (HL),A
0000147E: 23		INC HL
0000147F: ED 43 39 40	LD (4039h),BC	; S_POSN_x
00001483: 22 0E 40	LD (400Eh),HL		; DF_CC
00001486: F8		RET M
00001487: 7C		LD A,H
00001488: D6 20		SUB 20h
0000148A: 67		LD H,A
0000148B: 3A 08 40	LD A,(4008h)			; ATTR-P
0000148E: 77		LD (HL),A
0000148F: C9		RET

; LOC-ADDR for next row
00001490: 05		DEC B
; LOC-ADDR for current row
00001491: 0E 21		LD C,21h			; 33

;-----------------------------
; THE 'LOCATE ADDRESS' ROUTINE
;-----------------------------
;
;

;; LOC-ADDR
00001493: ED 43 39 40	LD (4039h),BC	; S_POSN_x

;; TEST-LOW
00001497: 3E 21		LD A,21h
00001499: 91		SUB C
0000149A: 4F		LD C,A
0000149B: 3E 18		LD A,18h
0000149D: 90		SUB B
0000149E: 6F		LD L,A
0000149F: 26 00		LD H,00h
000014A1: 06 05		LD B,05h
000014A3: 29		ADD HL,HL
000014A4: 10 FD		DJNZ -03h
000014A6: 09		ADD HL,BC
000014A7: 4F		LD C,A
000014A8: 09		ADD HL,BC
000014A9: 01 7E 40	LD BC,407Eh				; D-FILE + 1
000014AC: 09		ADD HL,BC
000014AD: FD CB 1E 86	RES 0,(IY+1Eh)		; BREG/FLAGS
000014B1: 22 0E 40	LD (400Eh),HL			; DF_CC
000014B4: C9		RET

;--------------------------
; THE 'PRINT AT' SUBROUTINE
;--------------------------
;
;
;; STK and PRINT-AT
000014B5: CD 10 02	CALL 0210h				; routine STK-TO-BC

;; PRINT-AT
000014B8: 3E 17		LD A,17h
000014BA: 90		SUB B
000014BB: 38 48		JR C,+48h
000014BD: FD BE 22	CP (IY+22h)	; DF_SZ
000014C0: 47		LD B,A
000014C1: 04		INC B
000014C2: DA 0E 14	JP C,140Eh
000014C5: 79		LD A,C
000014C6: FE 20		CP 20h
000014C8: 30 3B		JR NC,+3Bh
000014CA: C6 3C		ADD 3Ch
000014CC: FD CB 1E 4E	BIT 1,(IY+1Eh)		; BREG/FLAGS
000014D0: C2 64 1D	JP NZ,1D64h
000014D3: 2F		CPL
000014D4: C6 5E		ADD 5Eh
000014D6: 4F		LD C,A
000014D7: 18 BA		JR -46h			; to TEST-LOW -4


;---------------------------------------
; THE 'PLOT AND UNPLOT' COMMAND ROUTINES
;---------------------------------------
;
;

;; PLOT/UNP
000014D9: CD 10 02	CALL 0210h				; routine STK-TO-BC
000014DC: 3E 2B		LD A,2Bh
000014DE: 90		SUB B
000014DF: 47		LD B,A
000014E0: 38 23		JR C,+23h				; to REPORT-B

000014E2: 16 08		LD D,08h
000014E4: CB 38		SRL B
000014E6: 38 02		JR C,+02h
000014E8: 16 02		LD D,02h
000014EA: CB 39		SRL C
000014EC: 38 02		JR C,+02h
000014EE: CB 3A		SRL D
000014F0: CD B8 14	CALL 14B8h				; PRINT-AT
000014F3: 7E		LD A,(HL)
000014F4: 07		RLCA
000014F5: FE 10		CP 10h
000014F7: 38 01		JR C,+01h
000014F9: AF		XOR A
000014FA: 0F		RRCA
000014FB: D0		RET NC
000014FC: EE 8F		XOR 8Fh
000014FE: C9		RET

;----------------------------
; THE 'STACK-TO-A' SUBROUTINE
;----------------------------
;
;

;; STK-TO-A
000014FF: CD 49 05	CALL 0549h			; FP-TO-A
00001502: 38 01		JR C,+01h
00001504: C8		RET Z

;; REPORT-B (or equivalent error msg)
00001505: CD 4A 14	CALL 144Ah			; ERROR-1
00001508: 0A		; "IE" - Invalid Expression

;; FIND-INT
00001509: CD 55 05	CALL 0555h			; routine FP-TO-BC
0000150C: 18 F4		JR -0Ch

;---------------------------
; THE 'CONT' COMMAND ROUTINE
;---------------------------
; Another abbreviated command. ROM space was really tight.
; CONTINUE at the line number that was set when break was pressed.
; Sometimes the current line, sometimes the next line.

;; CONT
0000150E: 2A 2B 40	LD HL,(402Bh)			; OLDPPC

;; GOTO-2
00001511: 3E 27		LD A,27h				;  <- continued from GOTO
00001513: BC		CP H
00001514: 38 EF		JR C,-11h				; to REPORT-B
00001516: CD 36 0B	CALL 0B36h				; routine LINE-ADDR (HL)
00001519: 22 0A 40	LD (400Ah),HL			; NXTLIN (<> ZX81)
0000151C: C9		RET

;-----------------------------
; THE 'RETURN' COMMAND ROUTINE
;-----------------------------
;

;; RETURN
0000151D: 3E AA		LD A,AAh
0000151F: E1		POP HL
00001520: E3		EX HL,(SP)
00001521: BC		CP H
00001522: 28 0E		JR Z,+0Eh
00001524: ED 73 02 40	LD (4002h),SP		; ERR-SP
00001528: 23		INC HL
00001529: 18 E6		JR -1Ah

;---------------------------
; THE 'GOTO' COMMAND ROUTINE
;---------------------------
;
;

;; GOTO
0000152B: CD 09 15	CALL 1509h				; FIND-INT
0000152E: 69		LD L,C
0000152F: 60		LD H,B
00001530: 18 DF		JR -21h


;; REPORT-7
00001532: E3		EX HL,(SP)
00001533: E5		PUSH HL
00001534: CD 4A 14	CALL 144Ah			; ERROR-1
00001537: 06		; "RG" - RETURN without GOSUB

;; NAME
00001538: CD 6F 0D	CALL 0D6Fh			; GET-INT & SET-FAST
0000153B: 0D		DEC C
0000153C: 37		SCF
0000153D: F8		RET M
0000153E: 09		ADD HL,BC
0000153F: CB FE		SET 7,(HL)
00001541: C9		RET

;; from PRINT-STK
00001542: E7		RST 20h				; STK-FETCH
;; PR-STR-3
;; PR-STR-4
00001543: 79		LD A,C
00001544: B0		OR B
00001545: C8		RET Z
00001546: 1A		LD A,(DE)
00001547: 0B		DEC BC
00001548: 13		INC DE
00001549: C5		PUSH BC
0000154A: CD 52 04	CALL 0452h			; routine TOKENS
0000154D: C1		POP BC
0000154E: 18 F3		JR -0Dh				; loop back to PR-STR-3

;; PRINT-STK
00001550: CD 7A 09	CALL 097Ah			; routine SYNTAX-Z
00001553: 28 ED		JR Z,-13h			; continue above



;-----------------------------------------------
; THE 'PRINT A FLOATING-POINT NUMBER' SUBROUTINE
;-----------------------------------------------
; prints 'last value' x on calculator stack.
; There are a wide variety of formats see Chapter 4.
; e.g. 
; PI            prints as       3.1415927
; .123          prints as       0.123
; .0123         prints as       .0123
; 999999999999  prints as       1000000000000
; 9876543210123 prints as       9876543200000

; Begin by isolating zero and just printing the '0' character
; for that case. For negative numbers print a leading '-' and
; then form the absolute value of x.

;; PRINT-FP
00001555: F7		RST 30h				; FP-CALC
00001556: 00		;;end-calc

00001557: 7E		LD A,(HL)
00001558: B7		OR A				; test for zero
00001559: 20 06		JR NZ,+06h

0000155B: F7		RST 30h				; FP-CALC
0000155C: B5		B5 		;;delete & end-calc

0000155E: 3E 1C		LD A,1Ch			; '0'
0000155F: DF		RST 18h				; PRINT-A
00001560: C9		RET

00001561: 23		INC HL
00001562: CB 7E		BIT 7,(HL)			; check for sign bit
00001564: CB BE		RES 7,(HL)			; and reset it
00001566: 3E 16		LD A,16h			; '-'
00001568: C4 B4 04	CALL NZ,04B4h		; PRINT-A -> print 'minus' symbol if negative
0000156B: 2B		DEC HL
0000156C: 7E		LD A,(HL)
0000156D: CD 79 07	CALL 0779h			; STACK-A

00001570: F7		RST 30h				; FP-CALC
00001571: 05		;;stk-data
00001572: 78		;;Exponent: $88, Bytes: 2
00001573: 80 80		;;(+00,+00)			x, e, -128.5
00001575: 2A		;;addition			x, e -.5
00001576: 05		;;stk-data
00001577: EF		;;Exponent: $7F, Bytes: 4
00001578: 1A 20 9A 85					;.30103 (log10 2)
0000157C: 1F		;;multiply              x,
0000157D: 15		;;int
0000157E: 55		;;st-mem-1              x, n.
0000157F: 05		DEC B
00001580: 34		INC (HL)
00001581: 80		ADD B
00001582: 2A 09 08	LD HL,(0809h)
00001585: 75		LD (HL),L
00001586: 2A 95 21	LD HL,(2195h)
00001589: 71		LD (HL),C
0000158A: 40		LD B,B
0000158B: 36 00		LD (HL),00h
0000158D: 2B		DEC HL

0000158E: 06 0A		LD B,0Ah
00001590: C5		PUSH BC
00001591: E5		PUSH HL
00001592: F7		RST 30h				; FP-CALC
00001593: 77		;;stk-ten
00001594: 06 B3		LD B,B3h
00001596: CD 49 05	CALL 0549h			; FP-TO-A
00001599: E1		POP HL
0000159A: 77		LD (HL),A
0000159B: 2B		DEC HL
0000159C: C1		POP BC
0000159D: 10 F1		DJNZ -0Fh
0000159F: E5		PUSH HL
000015A0: 23		INC HL
000015A1: 7E		LD A,(HL)
000015A2: A7		AND A
000015A3: 28 FB		JR Z,-05h
000015A5: 01 08 00	LD BC,0008h
000015A8: 09		ADD HL,BC
000015A9: 7E		LD A,(HL)
000015AA: FE 05		CP 05h
000015AC: E5		PUSH HL
000015AD: 36 80		LD (HL),80h
000015AF: 2B		DEC HL
000015B0: 7E		LD A,(HL)
000015B1: 38 07		JR C,+07h
000015B3: 3C		INC A
000015B4: FE 0A		CP 0Ah
000015B6: 38 01		JR C,+01h
000015B8: AF		XOR A
000015B9: 77		LD (HL),A
000015BA: 3C		INC A
000015BB: 3D		DEC A
000015BC: 28 EF		JR Z,-11h
000015BE: E1		POP HL
000015BF: 06 06		LD B,06h
000015C1: 36 80		LD (HL),80h
000015C3: 23		INC HL
000015C4: 10 FB		DJNZ -05h
000015C6: F7		RST 30h				; FP-CALC
000015C7: 35		DEC (HL)
000015C8: C5		PUSH BC
000015C9: CD 49 05	CALL 0549h			; FP-TO-A
000015CC: 28 02		JR Z,+02h
000015CE: ED 44		NEG
000015D0: 3C		INC A
000015D1: 3C		INC A
000015D2: E1		POP HL
000015D3: 57		LD D,A
000015D4: 23		INC HL
000015D5: 15		DEC D
000015D6: 7E		LD A,(HL)
000015D7: A7		AND A
000015D8: 28 FA		JR Z,-06h
000015DA: 7A		LD A,D
000015DB: FE FB		CP FBh
000015DD: FA 11 16	JP M,1611h
000015E0: FE 0D		CP 0Dh
000015E2: F2 11 16	JP P,1611h
000015E5: 3C		INC A
000015E6: 28 17		JR Z,+17h
000015E8: FA 04 16	JP M,1604h
000015EB: 47		LD B,A
000015EC: CD D2 04	CALL 04D2h
000015EF: 10 FB		DJNZ -05h
000015F1: CB 7E		BIT 7,(HL)
000015F3: C0		RET NZ
000015F4: 3E 1B		LD A,1Bh
000015F6: DF		RST 18h					; PRINT-A
000015F7: CD D2 04	CALL 04D2h
000015FA: CB 7E		BIT 7,(HL)
000015FC: 28 F9		JR Z,-07h
000015FE: C9		RET
000015FF: 3E 1C		LD A,1Ch
00001601: DF		RST 18h					; PRINT-A
00001602: 18 ED		JR -13h
00001604: ED 44		NEG
00001606: 47		LD B,A
00001607: 3E 1B		LD A,1Bh
00001609: DF		RST 18h					; PRINT-A
0000160A: 3E 1C		LD A,1Ch
0000160C: DF		RST 18h					; PRINT-A
0000160D: 10 FB		DJNZ -05h
0000160F: 18 E6		JR -1Ah
00001611: CD D2 04	CALL 04D2h
00001614: CD F1 15	CALL 15F1h
00001617: 3E 2A		LD A,2Ah
00001619: DF		RST 18h					; PRINT-A
0000161A: CB 7A		BIT 7,D
0000161C: 28 06		JR Z,+06h
0000161E: AF		XOR A
0000161F: 92		SUB D
00001620: 57		LD D,A
00001621: 3E 16		LD A,16h
00001623: 01 3E 15	LD BC,153Eh
00001626: DF		RST 18h					; PRINT-A
00001627: 7A		LD A,D
00001628: 16 FF		LD D,FFh
0000162A: D6 0A		SUB 0Ah
0000162C: 14		INC D
0000162D: 30 FB		JR NC,-05h
0000162F: 5F		LD E,A
00001630: 7A		LD A,D
00001631: C4 B1 04	CALL NZ,04B1h
00001634: 7B		LD A,E
00001635: C6 26		ADD 26h
00001637: DF		RST 18h					; PRINT-A
00001638: C9		RET

00001639: ED 4B 14 40	LD BC,(4014h)		; E_LINE
0000163D: ED 42		SBC HL,BC
0000163F: 09		ADD HL,BC
00001640: 28 08		JR Z,+08h

00001642: 2B		DEC HL
00001643: CB 4B		BIT 1,E
00001645: 28 06		JR Z,+06h

00001647: CD 74 01	CALL 0174h				; routine CLEAR-ONE
0000164A: C3 04 10	JP 1004h				; to LOWER



0000164D: 7E		LD A,(HL)
0000164E: 36 7F		LD (HL),7Fh
00001650: 23		INC HL
00001651: 77		LD (HL),A
00001652: 18 F6		JR -0Ah

00001654: 23		INC HL
00001655: 7E		LD A,(HL)
00001656: FE 76		CP 76h
00001658: 28 F0		JR Z,-10h
0000165A: 36 7F		LD (HL),7Fh
0000165C: 2B		DEC HL
0000165D: 18 F2		JR -0Eh

;; TEMPO
0000165F: CD FF 14	CALL 14FFh			; STK-TO-A
00001662: 32 21 40	LD (4021h),A		; MUNIT (tempo)
00001665: C9		RET

;; DISPLAY-5
00001666: ED 4F		LD R,A
00001668: 3E DD		LD A,DDh
0000166A: FB		EI
0000166B: E9		JP      (HL)

;--------------------------
; THE 'TABLE OF PRIORITIES'
;--------------------------
;
;

;; tbl-pri
0000166C: 06             ;       '-'
0000166D: 08             ;       '*'
0000166E: 08             ;       '/'
0000166F: 0A             ;       '**'
00001670: 02             ;       'OR'
00001671: 03             ;       'AND'
00001672: 05             ;       '<='
00001673: 05             ;       '>='
00001674: 05             ;       '<>'
00001675: 05             ;       '>'
00001676: 05             ;       '<'
00001677: 05             ;       '='
00001678: 06             ;       '+'

0000167A: CD 8A 1B	CALL 1B8Ah				; XOR A & routine PREP-M/D
0000167D: DA 23 17	JP C,1723h


; ------------------------
; THE 'DIVISION' OPERATION
; ------------------------

; First check for division by zero.

;; division
00001679: 17		RLA					; THIS IS THE SAME BYTE ALREADY USED BY THE CODE ABOVE !!
										; (it should have the effect of setting 'A' to zero)
00001680: EB		EX DE,HL
00001681: CD 8B 1B	CALL 1B8Bh				; routine PREP-M/D
00001684: D8		RET C					; return if zero, 0/anything is zero.

00001685: D9		EXX						; - - -
00001686: E5		PUSH HL					; save pointer to the next calculator literal.
00001687: D9		EXX						; - - -

00001688: D5		PUSH DE					; save pointer to divisor - will be STKEND.
00001689: E5		PUSH HL
0000168A: CD CE 01	CALL 01CEh				; routine FETCH-TWO
0000168D: D9		EXX
0000168E: E5		PUSH HL
0000168F: 69		LD L,C
00001690: 60		LD H,B
00001691: D9		EXX
00001692: A7		AND A					; clear carry bit and accumulator.
00001693: 60		LD H,B
00001694: 69		LD L,C
00001695: 0E DF		LD C,DFh				; count upwards from -33 decimal
00001697: 18 19		JR +19h					 ; forward to mid-loop entry point DIV-START

; ---

;; DIV-LOOP
00001699: 17		RLA
0000169A: CB 10		RL B
0000169C: D9		EXX
0000169D: CB 11		RL C
0000169F: CB 10		RL B
000016A1: D9		EXX

;; div-34th
000016A2: 29		ADD HL,HL
000016A3: D9		EXX
000016A4: ED 6A		ADC HL,HL
000016A6: D9		EXX
000016A7: 30 09		JR NC,+09h
000016A9: B7		OR A
000016AA: ED 52		SBC HL,DE
000016AC: D9		EXX
000016AD: ED 52		SBC HL,DE
000016AF: D9		EXX
000016B0: 18 0E		JR +0Eh

;; DIV-START
000016B2: ED 52		SBC HL,DE
000016B4: D9		EXX
000016B5: ED 52		SBC HL,DE
000016B7: D9		EXX
000016B8: 30 05		JR NC,+05h
000016BA: 19		ADD HL,DE
000016BB: D9		EXX
000016BC: ED 5A		ADC HL,DE
000016BE: D9		EXX
000016BF: 3F		CCF

;; COUNT-ONE
000016C0: 0C		INC C
000016C1: FA 99 16	JP M,1699h		; back while still minus to DIV-LOOP

000016C4: F5		PUSH AF
000016C5: 28 DB		JR Z,-25h		; back to DIV-START

000016C7: 5F		LD E,A
000016C8: D9		EXX
000016C9: 50		LD D,B
000016CA: F1		POP AF
000016CB: CB 18		RR B
000016CD: F1		POP AF
000016CE: CB 18		RR B
000016D0: 59		LD E,C

000016D1: D9		EXX
000016D2: 50		LD D,B
000016D3: C1		POP BC
000016D4: 78		LD A,B
000016D5: 3D		DEC A
000016D6: ED 44		NEG
000016D8: 18 42		JR +42h



; ------------------------------
; THE 'MULTIPLICATION' OPERATION
; ------------------------------
;
;

;; multiply

000016DA: CD 8A 1B	CALL 1B8Ah				; XOR A & routine PREP-M/D
000016DD: D8		RET C
000016DE: D9		EXX						; - - -
000016DF: E5		PUSH HL					; save pointer to 'next literal'
000016E0: D9		EXX						; - - -
000016E1: EB		EX DE,HL
000016E2: E5		PUSH HL
000016E3: CD 8B 1B	CALL 1B8Bh				; routine PREP-M/D
000016E6: EB		EX DE,HL
000016E7: 38 40		JR C,+40h				; forward with carry to ZERO-RSLT (anything * zero = zero)
000016E9: E5		PUSH HL
000016EA: CD CE 01	CALL 01CEh				; routine FETCH-TWO
000016ED: AF		XOR A
000016EE: D9		EXX
000016EF: E5		PUSH HL
000016F0: 67		LD H,A
000016F1: 6F		LD L,A
000016F2: D9		EXX
000016F3: 67		LD H,A
000016F4: 6F		LD L,A
000016F5: 78		LD A,B
000016F6: 06 21		LD B,21h
000016F8: 18 11		JR +11h
000016FA: 30 05		JR NC,+05h
000016FC: 19		ADD HL,DE
000016FD: D9		EXX
000016FE: ED 5A		ADC HL,DE
00001700: D9		EXX
00001701: D9		EXX
00001702: CB 1C		RR H
00001704: CB 1D		RR L
00001706: D9		EXX
00001707: CB 1C		RR H
00001709: CB 1D		RR L
0000170B: D9		EXX
0000170C: CB 18		RR B
0000170E: CB 19		RR C
00001710: D9		EXX
00001711: 1F		RRA
00001712: CB 19		RR C
00001714: 10 E4		DJNZ -1Ch
00001716: C1		POP BC
00001717: EB		EX DE,HL
00001718: D9		EXX
00001719: EB		EX DE,HL
0000171A: D9		EXX
0000171B: 78		LD A,B

0000171C: E1		POP HL
0000171D: 81		ADD C
0000171E: F2 27 17	JP P,1727h
00001721: 30 10		JR NC,+10h

00001723: CD 4A 14	CALL 144Ah			; ERROR-1
00001726: 05		; "OV" - Number overflow

00001727: 38 0A		JR C,+0Ah

;; ZERO-RSLT
00001729: CD D1 0B	CALL 0BD1h
0000172C: 77		LD (HL),A
0000172D: 23		INC HL
0000172E: 77		LD (HL),A
0000172F: 2B		DEC HL
00001730: C3 C6 17	JP 17C6h			; forward to OFLOW-CLR


00001733: C6 80		ADD 80h
00001735: 28 F2		JR Z,-0Eh
00001737: 77		LD (HL),A
00001738: D9		EXX
00001739: 78		LD A,B
0000173A: D9		EXX
0000173B: 18 62		JR +62h

; ---------------------------
; THE 'SUBTRACTION' OPERATION
; ---------------------------
; just switch the sign of subtrahend and do an add.

;; subtract
0000173D: 1A		LD A,(DE)					; fetch exponent byte of second number the subtrahend. 
0000173E: B7		OR A						; test for zero
0000173F: C8		RET Z						; return if zero - first number is result.
00001740: 13		INC DE						; address the first mantissa byte.
00001741: 1A		LD A,(DE)					; fetch to accumulator.
00001742: EE 80		XOR 80h						; toggle the sign bit.
00001744: 12		LD (DE),A					; place back on calculator stack.
00001745: 1B		DEC DE						; point to exponent byte.  (continue into addition routine)

; ------------------------
; THE 'ADDITION' OPERATION
; ------------------------
; The addition operation pulls out all the stops and uses most of the Z80's
; registers to add two floating-point numbers.
; This is a binary operation and on entry, HL points to the first number
; and DE to the second.

;; addition
00001746: D9		EXX							; - - -
00001747: E5		PUSH HL						; save the pointer to the next literal.
00001748: D9		EXX							; - - -
00001749: D5		PUSH DE						; save pointer to second number
0000174A: E5		PUSH HL						; save pointer to first number - will be the result pointer on calculator stack.
0000174B: CD 35 04	CALL 0435h					; PREP-ADD
0000174E: EB		EX DE,HL					; switch number pointers.
0000174F: 4F		LD C,A						; save first exponent byte in C.
00001750: CD 35 04	CALL 0435h					; PREP-ADD
00001753: B9		CP C						; compare the exponent bytes.
00001754: 30 04		JR NC,+04h					; forward if second higher to SHIFT-LEN
00001756: EB		EX DE,HL					; else switch the number pointers
00001757: 47		LD B,A						; and the exponent bytes.
00001758: 79		LD A,C						;
00001759: 48		LD C,B

;; SHIFT-LEN
0000175A: F5		PUSH AF						; save higher exponent
0000175B: 91		SUB C						; subtract lower exponent
0000175C: F5		PUSH AF
0000175D: CD CE 01	CALL 01CEh					; routine FETCH-TWO
00001760: F1		POP AF
00001761: CD B7 0B	CALL 0BB7h					; routine SHIFT-FP
00001764: F1		POP AF						; restore higher exponent.
00001765: E1		POP HL						; restore result pointer.
00001766: 77		LD (HL),A					; insert exponent byte.

00001767: EB		EX DE,HL
00001768: 09		ADD HL,BC
00001769: EB		EX DE,HL
0000176A: D9		EXX
0000176B: EB		EX DE,HL
0000176C: ED 4A		ADC HL,BC
0000176E: 7A		LD A,D
0000176F: 8B		ADC E
00001770: EB		EX DE,HL
00001771: 67		LD H,A
00001772: 0F		RRCA
00001773: AC		XOR H
00001774: 0F		RRCA						; has overflow occurred ?
00001775: D9		EXX
00001776: 30 08		JR NC,+08h					; skip forward if not to TEST-NEG

; if the addition of two positive mantissas produced overflow or if the
; addition of two negative mantissas did not then the result exponent has to
; be incremented and the mantissa shifted one place to the right.

00001778: 3E 01		LD A,01h					; one shift required.
0000177A: CD BD 0B	CALL 0BBDh					; routine SHIFT-FP(+2) performs a single shift rounding any lost bit
0000177D: 34		INC (HL)					; increment the exponent.
0000177E: 28 A3		JR Z,-5Dh					; forward to ADD-REP-6 if the exponent wraps round from FF to zero
												; as number is too big for the system.
;; TEST-NEG
00001780: 23		INC HL						; point to first byte of mantissa
00001781: D9		EXX							; switch in the alternate set.
00001782: 3E 80		LD A,80h					; isolate bit 7 from sign byte setting zero flag
00001784: A4		AND H						; ..if positive.
00001785: D9		EXX							; back to main set.
00001786: 77		LD (HL),A					; insert $00 positive or $80 negative at position on calculator stack.
00001787: 2B		DEC HL						; point to exponent again.
00001788: 28 15		JR Z,+15h					; forward if positive to GO-NC-MLT

; a negative number has to be twos-complemented before being placed on stack.

0000178A: AF		XOR A
0000178B: 93		SUB E			; negate the lowest (rightmost) mantissa byte (CY value matters)
0000178C: 5F		LD E,A			; place back in register

0000178D: 3E 00		LD A,00h		; ditto
0000178F: 9A		SBC D
00001790: 57		LD D,A

00001791: D9		EXX				; switch to higher (lefmost) 16 bits.

00001792: 3E 00		LD A,00h		; ditto
00001794: 9B		SBC E
00001795: 5F		LD E,A

00001796: 3E 00		LD A,00h		; ditto
00001798: 9A		SBC D
00001799: 57		LD D,A

0000179A: D9		EXX
0000179B: 3E 00		LD A,00h
0000179D: 30 24		JR NC,+24h

; ---

; this branch is common to addition and multiplication with the mantissa
; result still in registers D'E'D E .

;; NORMALIZE

0000179F: 06 20		LD B,20h		; a maximum of thirty-two left shifts will be needed
000017A1: A7		AND A			

;; SHIFT-ONE
000017A2: D9		EXX				; address higher 16 bits.
000017A3: CB 7A		BIT 7,D			; test the leftmost bit
000017A5: D9		EXX				; address lower 16 bits.
000017A6: 20 13		JR NZ,+13h		; forward if leftmost bit was set to NORML-NOW
000017A8: 17		RLA				; this holds zero from addition, 33rd bit from multiplication.
000017A9: CB 13		RL E			; C < 76543210 < C
000017AB: CB 12		RL D			; C < 76543210 < C
000017AD: D9		EXX				; address higher 16 bits.
000017AE: CB 13		RL E			; C < 76543210 < C
000017B0: CB 12		RL D			; C < 76543210 < C
000017B2: D9		EXX				; switch to main set.
000017B3: 35		DEC (HL)		; decrement the exponent byte on the calculator stack
000017B4: 28 02		JR Z,+02h		; back if exponent becomes zero to NEAR-ZERO
									; it's just possible that the last rotation set bit 7 of D. We shall see.
000017B6: 10 EA		DJNZ -16h		; loop back to SHIFT-ONE

; if thirty-two left shifts were performed without setting the most significant 
; bit then the result is zero.

000017B8: C3 29 17	JP 1729h		; back to ZERO-RSLT


000017BB: 07		RLCA

000017BC: 30 08		JR NC,+08h		; forward to OFLOW-CLR

000017BE: CD 8E 0B	CALL 0B8Eh		; forward to ADD-BACK
000017C1: 20 03		JR NZ,+03h
000017C3: 34		INC (HL)
000017C4: 28 B8		JR Z,-48h


; now transfer the mantissa from the register sets to the calculator stack
; incorporating the sign bit already there.

;; OFLOW-CLR

000017C6: E5		PUSH HL				; save pointer to exponent on stack.
000017C7: D9		EXX
000017C8: D5		PUSH DE				; push the most significant two bytes.
000017C9: D9		EXX
000017CA: C1		POP BC				; pop - true mantissa is now BCDE
000017CB: 23		INC HL

; now pick up the sign bit.
000017CC: 78		LD A,B				; first mantissa byte to A 
000017CD: 07		RLCA				; rotate out bit 7 which is set
000017CE: CB 26		SLA (HL)			; rotate sign bit on stack into carry
000017D0: 1F		RRA					; rotate sign bit into bit 7 of mantissa

; and transfer mantissa from main registers to calculator stack.

000017D1: 77		LD (HL),A			;
000017D2: 23		INC HL
000017D3: 71		LD (HL),C
000017D4: 23		INC HL
000017D5: 72		LD (HL),D
000017D6: 23		INC HL
000017D7: 73		LD (HL),E

000017D8: E1		POP HL				; restore pointer to num1 now result.
000017D9: D1		POP DE				; restore pointer to num2 now STKEND 

000017DA: D9		EXX					; 
000017DB: E1		POP HL				; restore pointer to next calculator literal.
000017DC: D9		EXX
000017DD: C9		RET


;---------------------------
; Stack a constant 
;---------------------------
; This routine allows a one-byte instruction to stack up to 32 constants
; held in short form in a table of constants. In fact only 5 constants are
; required. On entry the A register holds the literal ANDed with $1F.
; It isn't very efficient and it would have been better to hold the
; numbers in full, five byte form and stack them in a similar manner
; to that which would be used later for semi-tone table values.

;; stk-const-xx
000017DE: D9		EXX
000017DF: E5		PUSH HL
000017E0: 21 37 1C	LD HL,1C37h  ; start of table of constants
000017E3: 5F		LD E,A
000017E4: 16 00		LD D,00h
000017E6: 19		ADD HL,DE
000017E7: D9		EXX
000017E8: CD 31 0D	CALL 0D31h	; stk-data
000017EB: 18 ED		JR -13h		; recycle the code to restore the pointer to next literal

; -------------------------
; THE 'OUT-BYTE' SUBROUTINE
; -------------------------
; This subroutine outputs a byte a bit at a time to a domestic tape recorder.

;; OUT-BYTE
000017ED: 37		SCF						; set carry flag - as a marker.
000017EE: 56		LD D,(HL)				; fetch byte to be saved.
;; EACH-BIT
000017EF: CB 12		RL D					;  C < 76543210 < C
000017F1: C8		RET Z					; return when the marker bit has passed right through

000017F2: 9F		SBC A					; $FF if set bit or $00 with no carry.
000017F3: E6 05		AND 05h					; $05               $00
000017F5: C6 04		ADD 04h					; $09               $04
000017F7: 5F		LD E,A					; transfer timer to E. a set bit has a longer pulse than a reset bit.

000017F8: CD F4 19	CALL 19F4h				; call PULSES

000017FB: AF		XOR A
000017FC: 10 FD		DJNZ -03h
000017FE: 18 EF		JR -11h					; loop back to EACH-BIT


;; 
00001800: 2A 29 40	LD HL,(4029h)			; E_PPC (<> ZX81)
00001803: CD 92 12	CALL 1292h				; INC HL, LINE-ADDR (HL), AND LINE-NO
00001806: 18 0A		JR +0Ah					; to KEY-INPUT

;------------------------
; THE 'CURSOR UP' ROUTINE
;------------------------
;
;

;; UP-KEY
00001808: 2A 29 40	LD HL,(4029h)			; E_PPC (<> ZX81)
0000180B: CD 36 0B	CALL 0B36h				; routine LINE-ADDR (HL)
0000180E: EB		EX DE,HL
0000180F: CD 96 12	CALL 1296h				; routine LINE-NO


00001812: FD CB 2D 6E	BIT 5,(IY+2Dh)      ; FLAGX
00001816: C2 04 10	JP NZ,1004h				; to LOWER

;----------------------------
; THE 'BASIC LISTING' SECTION
;----------------------------
;
;

00001819: ED 53 29 40	LD (4029h),DE		; E_PPC (<> ZX81)
;; UPPER
0000181D: CD 7D 1C	CALL 1C7Dh				; routine CLS
00001820: ED 5B 23 40	LD DE,(4023h)		; S_TOP
00001824: B7		OR A
00001825: 2A 29 40	LD HL,(4029h)			; E_PPC (<> ZX81)
00001828: ED 52		SBC HL,DE
0000182A: EB		EX DE,HL
0000182B: 30 04		JR NC,+04h				; to ADDR-TOP
0000182D: 19		ADD HL,DE
0000182E: 22 23 40	LD (4023h),HL			;S_TOP
;; ADDR-TOP
00001831: CD 36 0B	CALL 0B36h				; routine LINE-ADDR (HL)
00001834: 28 01		JR Z,+01h
00001836: EB		EX DE,HL
;; LIST-TOP
00001837: FD 36 09 FF	LD (IY+09h),FFh		; VERSN / BERG
0000183B: CD D8 0C	CALL 0CD8h				; routine LIST-PROG
0000183E: FD 34 09	INC (IY+09h)			; VERSN / BERG
00001841: C2 04 10	JP NZ,1004h				; to LOWER

00001844: 2A 29 40	LD HL,(4029h)			; E_PPC (<> ZX81)
00001847: CD 36 0B	CALL 0B36h				; routine LINE-ADDR (HL)
0000184A: 2A 16 40	LD HL,(4016h)			; CH_ADD
0000184D: ED 52		SBC HL,DE
0000184F: 38 0C		JR C,+0Ch				; DONT-INC-LINE

;; INC-LINE
00001851: 2A 23 40	LD HL,(4023h)			; S_TOP
00001854: CD 92 12	CALL 1292h				; INC HL, LINE-ADDR (HL), AND LINE-NO
00001857: ED 53 23 40	LD (4023h),DE		; S_TOP
0000185B: 18 C0		JR -40h					; to UPPER

;; DONT-INC-LINE
0000185D: EB		EX DE,HL
0000185E: 56		LD D,(HL)
0000185F: 23		INC HL
00001860: 5E		LD E,(HL)
00001861: 18 F4		JR -0Ch					; to INC-LINE

;; N/L-ONLY
00001863: CD D4 13	CALL 13D4h		; routine CURSOR-IN inserts the cursor and end-marker in the Edit Line 
00001866: 18 B5		JR -4Bh			; also setting size of lower display to two lines.

;; CP-LINES
00001868: 7E		LD A,(HL)
00001869: B8		CP B
0000186A: C0		RET NZ
0000186B: 23		INC HL
0000186C: 7E		LD A,(HL)
0000186D: B9		CP C
0000186E: 2B		DEC HL
0000186F: C9		RET

00001870: ED 4B 25 40	LD BC,(4025h)		; LAST_K
00001874: CD 2D 1C	CALL 1C2Dh				; DEBOUNCE


;---------------------------------
; THE 'KEYBOARD DECODE' SUBROUTINE
;---------------------------------
;
;

;; DECODE
00001877: CB 28		SRA B
00001879: 9F		SBC A
0000187A: F6 26		OR 26h

0000187C: 11 01 00	LD DE,0001h

; to KEY-LINE
0000187F: 83		ADD E
00001880: 37		SCF
00001881: CB 18		RR B
00001883: 38 FA		JR C,-06h		; to KEY-LINE
00001885: 04		INC B
00001886: C0		RET NZ
00001887: 1D		DEC E
00001888: 1E 05		LD E,05h
0000188A: 41		LD B,C
0000188B: 28 F2		JR Z,-0Eh		; to KEY-LINE

0000188D: 93		SUB E
0000188E: 5F		LD E,A
0000188F: 21 E6 03	LD HL,03E6h		; "KEY TABLES" -1
00001892: 19		ADD HL,DE
00001893: 37		SCF
00001894: C9		RET

; --------------------------
; THE 'DE,(DE+1)' SUBROUTINE
; --------------------------
; INDEX and LOAD Z80 subroutine. 
; This emulates the 6800 processor instruction LDX 1,X which loads a two-byte
; value from memory into the register indexing it. Often these are hardly worth
; the bother of writing as subroutines and this one doesn't save any time or 
; memory. The timing and space overheads have to be offset against the ease of
; writing and the greater program readability from using such toolkit routines.

;; DE,(DE+1)

00001895: 13		INC DE
00001896: EB		EX DE,HL
00001897: 5E		LD E,(HL)
00001898: 23		INC HL
00001899: 56		LD D,(HL)
0000189A: C9		RET

;--------------------------
; String concatenation ()
;--------------------------
; This literal combines two strings into one e.g. LET A$ = B$ + C$
; The two parameters of the two strings to be combined are on the stack.

;; strs-add
0000189B: E7		RST 20h		; routine STK-FETCH fetches string parameters and deletes calculator stack entry
0000189C: D5		PUSH DE		; save start address.
0000189D: C5		PUSH BC		; and length
0000189E: E7		RST 20h		; routine STK-FETCH for first string
0000189F: E1		POP HL		; re-fetch first length
000018A0: E5		PUSH HL		; and save again
000018A1: 09		ADD HL,BC	; add the two lengths.
000018A2: C5		PUSH BC		; save length
000018A3: 4D		LD C,L		; transfer to BC 
000018A4: 44		LD B,H
000018A5: D5		PUSH DE		; save start of second string
000018A6: CD DD 0B	CALL 0BDDh	; create BC-SPACES in workspace
000018A9: CD BC 13	CALL 13BCh	; routine STK-STO-$ stores parameters of new string updating STKEND.
000018AC: E1		POP HL		; length of first
000018AD: C1		POP BC		; address of start
000018AE: 79		LD A,C		; test for
000018AF: B0		OR B		; zero length.
000018B0: 28 02		JR Z,+02h	; to OTHER-STR if null string
000018B2: ED B0		LDIR		; copy string to workspace.

;; OTHER-STR
000018B4: C1		POP BC		; now second length
000018B5: E1		POP HL		; and start of string
000018B6: 79		LD A,C		; test this one
000018B7: B0		OR B		; for zero length
000018B8: 28 33		JR Z,+33h	; skip forward to STK-PNTRS if so as complete.
000018BA: ED B0		LDIR		; else copy the bytes 
000018BC: 18 2F		JR +2Fh		; and sets the calculator stack pointers

;-----------------------------
; Handle VAL ()
;-----------------------------
; VAL treats the characters in a string as a numeric expression.
;     e.g. VAL "2.3" = 2.3, VAL "2+4" = 6, VAL ("2" + "4") = 24.

;; val
000018BE: E7		RST 20h		; routine STK-FETCH fetches the string operand from calculator stack.

000018BF: 2A 16 40	LD HL,(4016h)		; fetch value of system variable CH_ADD
000018C2: E5		PUSH HL				; and save on the machine stack.
000018C3: 03		INC BC
000018C4: D5		PUSH DE
000018C5: CD DD 0B	CALL 0BDDh			; BC-SPACES creates the space in workspace.
000018C8: ED 53 16 40	LD (4016h),DE	; load CH_ADD with start DE in workspace.
000018CC: E1		POP HL				; restore start of string to HL.
000018CD: D5		PUSH DE				; save the start in workspace
000018CE: 0B		DEC BC
000018CF: ED B0		LDIR				; copy string from program or variables or workspace to the workspace area.
000018D1: 3E 76		LD A,76h			; insert a carriage return at end.
000018D3: 12		LD (DE),A
000018D4: FD CB 1E BE	RES 7,(IY+1Eh)	; update BREG/FLAGS  - signal checking syntax.
000018D8: CD 11 0A	CALL 0A11h			; routine CLASS-06 - SCANNING evaluates string expression and checks for integer result.

000018DB: CD 3E 0A	CALL 0A3Eh			; routine CHECK-2 checks for carriage return.
000018DE: FD CB 1E FE	SET 7,(IY+1Eh)	; update BREG/FLAGS  - signal running program.
000018E2: E1		POP HL
000018E3: 22 16 40	LD (4016h),HL		; set CH_ADD to the start of the string again.
000018E6: CD 06 08	CALL 0806h			; routine SCANNING evaluates the string in full, leaving result on calculator stack.
										
000018E9: E1		POP HL				; restore saved character address in program.
000018EA: 22 16 40	LD (4016h),HL


;; STK-PNTRS
000018ED: ED 5B 1C 40	LD DE,(401Ch)		; STKEND
000018F1: 21 FB FF	LD HL,FFFBh
000018F4: 19		ADD HL,DE
000018F5: C9		RET

;------------------------
; THE 'NUMBER' SUBROUTINE
;------------------------
;
;

;; NUMBER
000018F6: 7E		LD A,(HL)
000018F7: FE 7E		CP 7Eh
000018F9: C0		RET NZ
000018FA: 23		INC HL
000018FB: 23		INC HL
000018FC: 23		INC HL
000018FD: 23		INC HL
000018FE: 23		INC HL
000018FF: C9		RET
00001900: 94		SUB H
00001901: 8B		ADC E
00001902: 84		ADD H
00001903: 7C		LD A,H
00001904: F8		RET M
00001905: EB		EX DE,HL
00001906: DD D1		POP DE
00001908: C5		PUSH BC
00001909: BA		CP D
0000190A: BA		CP D
0000190B: B0		OR B
0000190C: A6		AND (HL)
0000190D: 9D		SBC L

;; skip word
0000190E: 78		LD A,B
0000190F: B1		OR C
00001910: C8		RET Z
00001911: 7E		LD A,(HL)
00001912: 0B		DEC BC
00001913: 23		INC HL
00001914: A7		AND A
00001915: C0		RET NZ
00001916: 18 F6		JR -0Ah

;; PAUSE ?
00001918: CD 6F 0D	CALL 0D6Fh				; GET-INT & SET-FAST
0000191B: CD 0E 19	CALL 190Eh				; skip word
0000191E: CA A9 12	JP Z,12A9h				; routine SLOW/FAST

00001921: FE 1B		CP 1Bh
00001923: 1E 01		LD E,01h
00001925: 28 24		JR Z,+24h
00001927: 07		RLCA
00001928: FE 5A		CP 5Ah
0000192A: 30 5C		JR NC,+5Ch
0000192C: D6 4C		SUB 4Ch
0000192E: 38 58		JR C,+58h
00001930: E5		PUSH HL
00001931: 16 00		LD D,00h
00001933: 5F		LD E,A
00001934: 21 00 19	LD HL,1900h
00001937: 19		ADD HL,DE
00001938: 5E		LD E,(HL)
00001939: E1		POP HL
0000193A: CD 0E 19	CALL 190Eh				; skip word
0000193D: 28 49		JR Z,+49h

0000193F: FE 13		CP 13h
00001941: 28 08		JR Z,+08h

00001943: CB 3B		SRL E
00001945: FE 12		CP 12h
00001947: 20 07		JR NZ,+07h

00001949: CB 3B		SRL E
0000194B: CD 0E 19	CALL 190Eh				; skip word
0000194E: 28 38		JR Z,+38h

00001950: CD 54 1C	CALL 1C54h				; routine ALPHA
00001953: 38 33		JR C,+33h

00001955: 57		LD D,A
00001956: CD 0E 19	CALL 190Eh				; skip word
00001959: 28 12		JR Z,+12h

0000195B: CD 54 1C	CALL 1C54h				; routine ALPHA
0000195E: 30 04		JR NC,+04h

00001960: 2B		DEC HL
00001961: 03		INC BC
00001962: 18 09		JR +09h
00001964: CB 22		SLA D
00001966: 82		ADD D
00001967: CB 22		SLA D
00001969: CB 22		SLA D
0000196B: 82		ADD D
0000196C: 57		LD D,A
0000196D: E5		PUSH HL
0000196E: C5		PUSH BC
0000196F: 62		LD H,D
00001970: FD 6E 21	LD L,(IY+21h)			; MUNIT  (tempo)
00001973: 0E 00		LD C,00h
00001975: 53		LD D,E
00001976: 45		LD B,L					; load tempo
00001977: CD A5 0B	CALL 0BA5h
0000197A: 25		DEC H
0000197B: 20 F9		JR NZ,-07h
0000197D: CD 28 1C	CALL 1C28h				; routine BREAK-1 test for BREAK key.
00001980: 30 62		JR NC,+62h
00001982: 10 F9		DJNZ -07h				; timing loop
00001984: C1		POP BC
00001985: E1		POP HL
00001986: 18 93		JR -6Dh

00001988: CD 4A 14	CALL 144Ah			; ERROR-1
0000198B: 0E		; "MF" - Incorrect music string format

; ------------------------
; THE 'IN-BYTE' SUBROUTINE
; ------------------------

;; IN-BYTE
0000198C: 0E 01		LD C,01h			; prepare an eight counter 00000001.
0000198E: 18 1B		JR +1Bh				; Forward to next-bit

00001990: E5		PUSH HL				; save the 
00001991: 2E 96		LD L,96h			; timing value.
00001993: 06 1B		LD B,1Bh			; counter to twenty seven.
00001995: DB FE		INA (FEh)			; read the
00001997: 07		RLCA
00001998: 2D		DEC L				; decrement the measuring timer.
00001999: 7D		LD A,L
0000199A: CB 7F		BIT 7,A				; bit 6: Display Refresh Rate (0=60Hz, 1=50Hz)
0000199C: 38 F5		JR C,-0Bh
0000199E: 10 F5		DJNZ -0Bh
000019A0: E1		POP HL
000019A1: 20 04		JR NZ,+04h			; to BIT-DONE
000019A3: FE 5A		CP 5Ah
000019A5: 30 04		JR NC,+04h			; to NEXT-BIT
;; BIT-DONE
000019A7: 3F		CCF
000019A8: CB 11		RL C
000019AA: D8		RET C				; return when byte is complete

;; NEXT-BIT
000019AB: 06 00		LD B,00h			; set counter to 256
;; BREAK-3
000019AD: 3E 7F		LD A,7Fh
000019AF: DB FE		INA (FEh)			; Read leyboard and CAS input bit, but not PAL/NTSC
000019B1: D3 FF		OUTA (FFh)			; Terminate retrace / CAS output
000019B3: 07		RLCA				; test for SPACE pressed.
000019B4: 38 DA		JR C,-26h
000019B6: 0F		RRCA
000019B7: 0F		RRCA
000019B8: 30 25		JR NC,+25h			; forward if set to GET-BIT
000019BA: 10 F1		DJNZ -0Fh

000019BC: E1		POP HL
000019BD: 15		DEC D
000019BE: 14		INC D				; test for zero.
000019BF: 28 20		JR Z,+20h

000019C1: 6B		LD L,E
000019C2: 62		LD H,D
000019C3: CD 8C 19	CALL 198Ch			; IN-BYTE
000019C6: 79		LD A,C
000019C7: CB 7A		BIT 7,D
000019C9: 20 03		JR NZ,+03h
000019CB: BE		CP (HL)
000019CC: 20 21		JR NZ,+21h
000019CE: 23		INC HL
000019CF: 07		RLCA
000019D0: 30 F1		JR NC,-0Fh
000019D2: 21 09 40	LD HL,4009h   		; VERSN / BERG
000019D5: CD 8C 19	CALL 198Ch			; IN-BYTE
000019D8: 71		LD (HL),C
000019D9: CD BA 0E	CALL 0EBAh			; routine LOAD/SAVE
000019DC: 50		LD D,B
000019DD: 18 F6		JR -0Ah

;; GET-BIT
000019DF: 15		DEC D
000019E0: 14		INC D				; test for zero.

;; RESTART
000019E1: CA 5A 0F	JP Z,0F5Ah			; jump forward to INITIAL if D is zero to reset the system
										; if the tape signal has timed out (for example if the tape is stopped)
										; Not just a simple report as some system variables will have been overwritten.

000019E4: CD 4A 14	CALL 144Ah			; ERROR-1
000019E7: 01		"BK" - BREAK Key pressed


;---------------------------
; THE 'LOAD COMMAND' ROUTINE
;---------------------------
;
;

;; LOAD
000019E8: CD 38	15	CALL 1538h			; NAME
000019EB: 7A		LD A,D
000019EC: 17		RLA					; pick up carry 
000019ED: 0F		RRCA				; carry now in bit 7.
000019EE: 57		LD D,A
;; NEXT-PROG
000019EF: CD 8C 19	CALL 198Ch			; IN-BYTE
000019F2: 18 FB		JR -05h				; loop to NEXT-PROG


;; PULSES  (used by SAVE)
000019F4: D3 FF		OUTA (FFh)			; pulse to cassette.
000019F6: 06 23		LD B,23h			; set timing constant
;; DELAY-2
000019F8: 10 FE		DJNZ -02h			; self-loop to DELAY-2

000019FA: CD 28 1C	CALL 1C28h			; routine BREAK-1 test for BREAK key.
000019FD: 06 1E		LD B,1Eh			; set timing value.
000019FF: 30 E3		JR NC,-1Dh			; forward with break to REPORT-D
;; DELAY-3
00001A01: 10 FE		DJNZ -02h			; self-loop to DELAY-3

00001A03: 1D		DEC E				; decrement counter
00001A04: 20 EE		JR NZ,-12h			; loop back to PULSES
00001A06: C9		RET


;---------------------------------
; Store in a memory area ($C0 etc???)
;---------------------------------
; Offsets $C0 to $DF  (???)
; Although 32 memory storage locations can be addressed, only six
; $C0 to $C5 are required by the ROM and only the thirty bytes (6*5)
; required for these are allocated. ZX81 programmers who wish to
; use the floating point routines from assembly language may wish to
; alter the system variable MEM to point to 160 bytes of RAM to have
; use the full range available.
; A holds derived offset $00-$1F.
; Unary so on entry HL points to last value, DE to STKEND.

;; st-mem-xx
00001A07: EB		EX DE,HL
00001A08: D5		PUSH DE
00001A09: CD 95 1B	CALL 1B95h				; LOC-MEM
00001A0C: EB		EX DE,HL
00001A0D: CD 6F 07	CALL 076Fh				; MOVE-FP
00001A10: D1		POP DE
00001A11: EB		EX DE,HL
00001A12: C9		RET


;---------------------------------------
; THE 'NEXT LINE OR VARIABLE' SUBROUTINE
;---------------------------------------
;
;

;; NEXT-ONE
00001A13: 7E		LD A,(HL)
00001A14: E5		PUSH HL
00001A15: FE 40		CP 40h
00001A17: 38 16		JR C,+16h
00001A19: CB 6F		BIT 5,A
00001A1B: 28 13		JR Z,+13h
;; NEXT+FIVE
00001A1D: 11 05 00	LD DE,0005h
00001A20: 87		ADD A
00001A21: 30 05		JR NC,+05h		; to NEXT-LETT
00001A23: F2 28 1A	JP P,1A28h
00001A26: 1E 11		LD E,11h
;; NEXT-LETT
00001A28: 87		ADD A
00001A29: 23		INC HL
00001A2A: 7E		LD A,(HL)
00001A2B: 30 FB		JR NC,-05h		; to NEXT-LETT
00001A2D: 18 06		JR +06h			; to NEXT-ADD
;; LINES
00001A2F: 23		INC HL
;; NEXT-O-4
00001A30: 23		INC HL
00001A31: 5E		LD E,(HL)
00001A32: 23		INC HL
00001A33: 56		LD D,(HL)
00001A34: 23		INC HL
;; NEXT-ADD
00001A35: 19		ADD HL,DE
00001A36: D1		POP DE
;----------------------------
; THE 'DIFFERENCE' SUBROUTINE
;----------------------------
;
;

;; DIFFER
00001A37: B7		OR A
00001A38: ED 52		SBC HL,DE
00001A3A: 4D		LD C,L
00001A3B: 44		LD B,H
00001A3C: 19		ADD HL,DE
00001A3D: EB		EX DE,HL
00001A3E: C9		RET

;--------------------------
; THE 'POINTERS' SUBROUTINE
;--------------------------
;
;

;; POINTERS
00001A3F: F5		PUSH AF
00001A40: E5		PUSH HL
00001A41: 3E 07		LD A,07h
00001A43: 21 0F 40	LD HL,400Fh
;; NEXT-PTR
00001A46: 23		INC HL
00001A47: 5E		LD E,(HL)
00001A48: 23		INC HL
00001A49: 56		LD D,(HL)
00001A4A: E3		EX HL,(SP)
00001A4B: B7		OR A
00001A4C: ED 52		SBC HL,DE
00001A4E: 19		ADD HL,DE
00001A4F: E3		EX HL,(SP)
00001A50: 30 09		JR NC,+09h		; to PTR-DONE

00001A52: EB		EX DE,HL
00001A53: E5		PUSH HL
00001A54: 09		ADD HL,BC
00001A55: EB		EX DE,HL
00001A56: 72		LD (HL),D
00001A57: 2B		DEC HL
00001A58: 73		LD (HL),E
00001A59: D1		POP DE
;; PTR-DONE
00001A5A: 23		INC HL
00001A5B: 3D		DEC A
00001A5C: 20 E8		JR NZ,-18h
00001A5E: E1		POP HL
00001A5F: EB		EX DE,HL
00001A60: F1		POP AF
00001A61: 18 D4		JR -2Ch


;-----------------------
; THE 'NATURAL LOGARITHM' FUNCTION
;-----------------------
; (offset $??: 'ln')  <--  'log' on the Lambda
; The two most common logarithms are called common logarithms and natural 
; logarithms.
; Common logarithms have a base of 10 and natural logarithms have a base of 'e'.

;; ln
00001A63: F7		RST 30h				; FP-CALC
00001A64: 01		;;duplicate
00001A65: 02		;;greater-0
00001A66: B4		;;jump-true & end-calc !!
00001A67: 05		;; ..to VALID

; Error Report: Invalid argument
00001A68: CD 4A 14	CALL 144Ah			; ERROR-1
00001A6B: 09		; "AG" - Invalid Argument

;; VALID
00001A6C: 7E		LD A,(HL)
00001A6D: 36 80		LD (HL),80h
00001A6F: CD 79 07	CALL 0779h			; STACK-A

00001A72: F7		RST 30h				; FP-CALC
00001A73: 05		DEC B
00001A74: 38 00		JR C,+00h
00001A76: 1E		;;subtract
00001A77: 33		;;exchange
00001A78: 01 05 F0	LD BC,F005h
00001A7B: 4C		LD C,H
00001A7C: CC CC CD	CALL Z,CDCCh
00001A7F: 1E 02		LD E,02h
00001A81: 34		INC (HL)
00001A82: 07		RLCA
00001A83: 33		;;exchange
00001A84: 79		LD A,C
00001A85: 1E B3		LD E,B3h
00001A87: 34		INC (HL)

00001A88: F7		RST 30h				; FP-CALC
00001A89: 33		;;exchange
00001A8A: 05		DEC B
00001A8B: F0		RET P
00001A8C: 31 72 17	LD SP,1772h
00001A8F: F8		RET M
00001A90: 1F		;;multiply
00001A91: 33		INC SP
00001A92: 79		LD A,C
00001A93: 1E 01		LD E,01h
00001A95: 05		DEC B
00001A96: 32 20 1F	LD (1F20h),A
00001A99: 75		LD (HL),L
00001A9A: 1E 6C		LD E,6Ch
00001A9C: 11 AC 14	LD DE,14ACh
00001A9F: 09		ADD HL,BC
00001AA0: 56		LD D,(HL)
00001AA1: DA A5 59	JP C,59A5h
00001AA4: 30 C5		JR NC,-3Bh
00001AA6: 5C		LD E,H
00001AA7: 90		SUB B
00001AA8: AA		XOR D
00001AA9: 9E		SBC (HL)
00001AAA: 70		LD (HL),B
00001AAB: 6F		LD L,A
00001AAC: 61		LD H,C
00001AAD: A1		AND C
00001AAE: CB DA		SET 3,D
00001AB0: 96		SUB (HL)
00001AB1: A4		AND H
00001AB2: 31 9F B4	LD SP,B49Fh
00001AB5: E7		RST 20h				; STK-FETCH
00001AB6: A0		AND B
00001AB7: FE 5C		CP 5Ch
00001AB9: FC EA 1B	CALL M,1BEAh		; PAUSE
00001ABC: 43		LD B,E
00001ABD: CA 36 ED	JP Z,ED36h
00001AC0: A7		AND A
00001AC1: 9C		SBC H
00001AC2: 7E		LD A,(HL)
00001AC3: 5E		LD E,(HL)
00001AC4: F0		RET P
00001AC5: 6E		LD L,(HL)
00001AC6: 23		INC HL
00001AC7: 80		ADD B
00001AC8: 93		SUB E
00001AC9: 1F		RRA
00001ACA: AA		XOR D
00001ACB: C9		RET

;---------------------------
; THE 'RAND' COMMAND ROUTINE
;---------------------------
; The keyword was 'RANDOMISE' on the ZX80, is 'RAND' on the ZX81 and becomes 'RANDOMIZE' on the ZX Spectrum.
; In all invocations the procedure is the same - to set the SEED system variable
; with a supplied integer value or to use a time-based value if no number, or
; zero, is supplied.

;; RAND
00001ACC: CD 09 15	CALL 1509h				; FIND-INT
00001ACF: B0		OR B					; test value for zero
00001AD0: 20 04		JR NZ,+04h				; forward if not zero to SET-SEED
00001AD2: ED 4B 34 40	LD BC,(4034h)		; fetch value of FRAMES system variable.
00001AD6: ED 43 32 40	LD (4032h),BC		; SEED
00001ADA: C9		RET


00001ADB: 76		HALT
00001ADC: 78		LD A,B
00001ADD: 7A		LD A,D
00001ADE: 67		LD H,A
00001ADF: 51		LD D,C
00001AE0: 3C		INC A
00001AE1: 7C		LD A,H
00001AE2: 7E		LD A,(HL)
00001AE3: 9B		SBC E
00001AE4: 5B		LD E,E
00001AE5: 96		SUB (HL)
00001AE6: 86		ADD (HL)
00001AE7: 82		ADD D
00001AE8: 7B		LD A,E
00001AE9: 89		ADC C
00001AEA: 85		ADD L
00001AEB: 9C		SBC H
00001AEC: 98		SBC B
00001AED: 1E 60		LD E,60h
00001AEF: 5C		LD E,H
00001AF0: 17		RLA
00001AF1: 45		LD B,L
00001AF2: 50		LD D,B

00001AF3: 0F		RRCA
00001AF4: 54		LD D,H
00001AF5: 1E 2B		LD E,2Bh
00001AF7: 8A		ADC D
00001AF8: 2E 40		LD L,40h
00001AFA: 39		ADD HL,SP
00001AFB: 41		LD B,C
00001AFC: 1B		DEC DE
00001AFD: 69		LD L,C
00001AFE: 2D		DEC L
00001AFF: 76		HALT
00001B00: 78		LD A,B
00001B01: 59		LD E,C
00001B02: 00		NOP
00001B03: 14		INC D
00001B04: 07		RLCA
00001B05: E2 00 00	JP PO,0000h
00001B08: 06 3B		LD B,3Bh
00001B0A: 10 01		DJNZ +01h
00001B0C: 14		INC D
00001B0D: 02		LD (BC),A
00001B0E: 41		LD B,C
00001B0F: 02		LD (BC),A
00001B10: 07		RLCA
00001B11: A7		AND A
00001B12: 07		RLCA
00001B13: 01 06 4D	LD BC,4D06h
00001B16: 0B		DEC BC
00001B17: 02		LD (BC),A
00001B18: 40		LD B,B





00001B19: 07		DEFB 07h		; 
00001B1A: D7 00		DEFW 00D7h		;

;---
00001B1C: 02 1A		DEFW 1A02h		; offset table.
;---

;; P-SOUND
00001B1E: 05		DEFB 05h		; Class-06 - A numeric expression must follow.
00001B1F: 99 0B		DEFW 0B99h		; SOUND

;---
00001B21: 02 1A		DEFW 1A02h		; offset table.
;---

00001B23: 05		DEFB 05h		; Class-06 - A numeric expression must follow.
00001B24: C4 01 	DEFW 01C4h		;

;---
00001B27: 02 1A		DEFW 1A02h		; offset table.
;---

;; P-PLOT
00001B28: 05		DEFB 05h		; Class-06 - A numeric expression must follow.
00001B29: AD 11		DEFW 11ADh		; PLOT

;---
00001B2B: 02 1A		DEFW 1A02h		; offset table.
;---

;; P-UNPLOT
00001B2D: 05		DEFB 05h		; Class-06 - A numeric expression must follow.
00001B2E: B9 11		DEFW 11B9h		; UNPLOT

00001B30: 03		DEFB 03h		; Class-05 - Variable syntax checked entirely by routine.
00001B31: 18 19		DEFW 1918h		; PAUSE ?

;; P-SAVE
00001B33: 03		DEFB 03h		; Class-05 - Variable syntax checked entirely by routine.
00001B34: 03 0D		DEFW 0D03h		; SAVE

;; P-LOAD
00001B36: 03		DEFB 03h		; Class-05 - Variable syntax checked entirely by routine. 
00001B37: E8 19		DEFW 19E8h		; LOAD

;; P-RUN
00001B39: 04		DEFB 04h		; Class-03 - A numeric expression may follow, else default to zero
00001B3A: 31 14		DEFW 1431h		; RUN

;; P-RAND
00001B3C: 04		DEFB 04h		; Class-03 - A numeric expression may follow, else default to zero
00001B3D: CC 1A 	DEFW 1ACCh		; RAND

;; P-LLIST
00001B3F: 04		DEFB 04h		; Class-03 - A numeric expression may follow, else default to zero
00001B40: C6 0C		DEFW 0CC6h		; LLIST

;; P-LIST
00001B42: 04		DEFB 04h		; Class-03 - A numeric expression may follow, else default to zero
00001B43: CA 0C		DEFW 0CCAh		; LIST

;; P-TEMPO
00001B45: 05		DEFB 05h		; Class-06 - A numeric expression must follow.
00001B46: 5F 16		DEFW 165Fh		; TEMPO

;; P-PAUSE
00001B48: 05		DEFB 05h		; Class-06 - A numeric expression must follow.
00001B49: EA 1B		DEFW 1BEAh		; PAUSE

;; P-GOSUB
00001B4B: 05		DEFB 05h		; Class-06 - A numeric expression must follow.
00001B4C: E6 13		DEFW 13E6h		; GOSUB

;; P-GOTO
00001B4E: 05		DEFB 05h		; Class-06 - A numeric expression must follow.
00001B4F: 2B 15		DEFW 152Bh		; GOTO

;; P-INK
00001B51: 05		DEFB 05h		; Class-06 - A numeric expression must follow.
00001B52: CC 06		DEFW 06CCh		; INK

;; P-PAPER
00001B54: 05		DEFB 05h		; Class-06 - A numeric expression must follow.
00001B55: D9 06		DEFW 06D9h		; PAPER

;; P-BORDER
00001B57: 05		DEFB 05h		; Class-06 - A numeric expression must follow.
00001B58: E4 06		DEFW 06E4h		; BORDER

;; P-COPY
00001B5A: 06		DEFB 06h		; Class-00 - No further operands.
00001B5B: C3 1C		DEFW 1CC3h		; COPY


00001B5D: 06		DEFB 06h		; Class-00 - No further operands.
00001B5E: 65 07		DEFW 0765h		; { res 5,(CDFLAG) }  -> BEEP/NOBEEP ?

00001B60: 06		DEFB 06h		; Class-00 - No further operands.
00001B61: 6A 07		DEFW 076Ah		; { set 5,(CDFLAG) }  -> BEEP/NOBEEP ?


;; P-NEW
00001B63: 06		DEFB 06h		; Class-00 - No further operands.
00001B64: 20 0F		DEFW 0F20h		; NEW

;; P-CLS
00001B66: 06		DEFB 06h		; Class-00 - No further operands.
00001B67: 7D 1C		DEFW 1C7Dh		; CLS

;; P-PAUSE
00001B69: 06		DEFB 06h		; Class-00 - No further operands.
00001B6A: 5E 0D		DEFW 0D5Eh		; PAUSE

;; P-SLOW
00001B6C: 06		DEFB 06h		; Class-00 - No further operands.
00001B6D: A5 12		DEFW 12A5h		; SLOW

;; P-CONT
00001B6F: 06		DEFB 06h		; Class-00 - No further operands.
00001B70: 0E 15		DEFW 150Eh		; CONT

;; P-SCROLL
00001B72: 06		DEFB 06h		; Class-00 - No further operands.
00001B73: 5E 1C		DEFW 1C5Eh		; SCROLL

00001B75: 06		DEFB 06h		; Class-00 - No further operands.
00001B76: 3C 14		DEFW 143Ch		; CLEAR

00001B78: 06		DEFB 06h		; Class-00 - No further operands.
00001B79: 1D 15		DEFW 151Dh		; RETURN

00001B7B: 06		DEFB 06h		; Class-00 - No further operands.
00001B7C: 0B 14		DEFW 140Bh		; 

00001B7E: 07		DEFB 07h		; 
00001B7F: 46 0A		DEFW 0A46h		; 

00001B81: 07		DEFB 07h		; 
00001B82: 4A 0A		DEFW 0A4Ah		; 

00001B84: 07		DEFB 07h		; 
00001B85: D6 00		DEFW 00D6h		; "ret" ?

00001B87: 07		DEFB 07h		; 
00001B88: 15 11		DEFW 1115h		; dim?



; ----------------------------------------------
; THE 'PREPARE TO MULTIPLY OR DIVIDE' SUBROUTINE
; ----------------------------------------------
; this routine is called twice from multiplication and twice from division
; to prepare each of the two numbers for the operation.
; Initially the accumulator holds zero and after the second invocation bit 7
; of the accumulator will be the sign bit of the result.

00001B8A: AF		XOR A

;; PREP-M/D
00001B8B: 34		INC (HL)			; test exponent
00001B8C: 35		DEC (HL)			; for zero
00001B8D: 37		SCF					; set carry flag to signal number is zero.
00001B8E: C8		RET Z				; return if zero with carry flag set.

00001B8F: 23		INC HL				; address first mantissa byte.
00001B90: AE		XOR (HL)			; exclusive or the running sign bit.
00001B91: CB FE		SET 7,(HL)			; set the implied bit.
00001B93: 2B		DEC HL				; point to exponent byte.
00001B94: C9		RET					; return.

;; LOC-MEM
00001B95: 2A 1F 40	LD HL,(401Fh)		; MEM
00001B98: 4F		LD C,A
00001B99: 06 00		LD B,00h
00001B9B: 09		ADD HL,BC
00001B9C: C9		RET



;----------------------
; THE 'ARCTAN' FUNCTION
;----------------------
; (Offset $??: 'atn')
; the inverse tangent function with the result in radians.
; This is a fundamental transcendental function from which others such as asn
; and acs are directly, or indirectly, derived.
; It uses the series generator to produce Chebyshev polynomials.

;; atn
00001B9D: 7E		LD A,(HL)
00001B9E: FE 81		CP 81h
00001BA0: 38 0E		JR C,+0Eh

00001BA2: F7		RST 30h				; FP-CALC
00001BA3: 79		;;stk-one
00001BA4: 33		;;exchange
00001BA5: 20		;;division
00001BA6: 09		;;negate
00001BA7: 01		;;duplicate
00001BA8: 70		;;stk-pi/2
00001BA9: 33		;;exchange
00001BAA: 03		;;not
00001BAB: 34		;;jump-true
00001BAC: 06		; to 1BB2h, CASES

00001BAd: 09		;;negate
00001BAE: 04		;;jump
00001BAF: 03		;; to 1BB2h, CASES


; ---

;; SMALL

00001BB0: F7		RST 30h				; FP-CALC
00001BB1: 7A		;;stk-zero

;; CASES
00001BB2: 33		;;exchange
00001BB3: 01		;;duplicate
00001BB4: 01		;;duplicate
00001BB5: 1F		;;multiply
00001BB6: 01		;;duplicate
00001BB7: 2A		;;addition
00001BB7: 79		;;stk-one
00001BB9: 1E		;;subtract
00001BB9: 6C		;;series-0C
00001BBB: 10		;;Exponent: $60, Bytes: 1
00001BBB: B2		;;(+00,+00,+00)
00001BBD: 13		;;Exponent: $63, Bytes: 1
00001BBE: 0E		;;(+00,+00,+00)
00001BBF: 55		;;Exponent: $65, Bytes: 2
00001BC0: E4 8D		;;(+00,+00)
00001BC2: 58		;;Exponent: $68, Bytes: 2
00001BC3: 39 BC		;;(+00,+00)
00001BC5: 5B		;;Exponent: $6B, Bytes: 2
00001BC6: 98 FD		;;(+00,+00)
00001BC8: 9E		;;Exponent: $6E, Bytes: 3
00001BC9: 00 36 75	;;(+00)
00001BCC: A0		;;Exponent: $70, Bytes: 3
00001BCD: DB E8	B4	;;(+00)
00001BD0: 63		;;Exponent: $73, Bytes: 2
00001BD1: 42 C4		;;(+00,+00)
00001BD3: E6		;;Exponent: $76, Bytes: 4
00001BD4: B5 09 36 BE
00001BD8: E9		;;Exponent: $79, Bytes: 4
00001BD9: 36 73	1B 5D
00001BDD: EC		;;Exponent: $7C, Bytes: 4
00001BDE: D8 DE 63 BE
00001BE2: F0		;;Exponent: $80, Bytes: 4
00001BE3: 61 A1	B3 0C
00001BE7: 1F		;;multiply
00001BE8: AA		;;addition & end-calc
00001BE9: C9		RET

; ---------------------------
; THE 'PAUSE' COMMAND ROUTINE
; ---------------------------

;; PAUSE
00001BEA: CD 09 15	CALL 1509h				; FIND-INT
00001BED: 21 3B 40	LD HL,403Bh				; CDFLAG
00001BF0: CB 7E		BIT 7,(HL)
00001BF2: 20 0D		JR NZ,+0Dh				; indirectly to DEBOUNCE

00001BF4: ED 43 34 40	LD (4034h),BC		; FRAMES
00001BF8: CD B6 12	CALL 12B6h
00001BFB: FD CB 35 FE	SET 7,(IY+35h)

00001BFF: 18 2C		JR +2Ch					; indirectly to DEBOUNCE
00001C01: 78		LD A,B
00001C02: E6 80		AND 80h
00001C04: 57		LD D,A
00001C05: CB F8		SET 7,B
00001C07: ED 43 34 40	LD (4034h),BC		; FRAMES
00001C0B: 78		LD A,B
00001C0C: 17		RLA
00001C0D: B1		OR C
00001C0E: B2		OR D
00001C0F: C8		RET Z
00001C10: ED 4B 34 40	LD BC,(4034h)		; FRAMES
00001C14: CB 46		BIT 0,(HL)
00001C16: 28 F3		JR Z,-0Dh
00001C18: 18 13		JR +13h

00001C1A: 46		LD B,(HL)
00001C1B: 23		INC HL
00001C1C: 4E		LD C,(HL)
00001C1D: 23		INC HL
00001C1E: ED 43 36 40	LD (4036h),BC		; LAMBDA-VAR
00001C22: 5E		LD E,(HL)
00001C23: 23		INC HL
00001C24: 56		LD D,(HL)
00001C25: 23		INC HL
00001C26: EB		EX DE,HL
00001C27: 19		ADD HL,DE


;-----------------------
; THE 'BREAK' SUBROUTINE
;-----------------------
;
;

;; BREAK-1
00001C28: 3E 7F		LD A,7Fh			; read port $7FFE - keys B,N,M,.,SPACE.
00001C2A: DB FE		INA (FEh)
00001C2C: 0F		RRCA				; carry will be set if space not pressed.


;--------------------------
; THE 'DEBOUNCE' SUBROUTINE
;--------------------------
;
;

;; DEBOUNCE
00001C2D: 3E 0F		LD A,0Fh
00001C2F: 32 27 40	LD (4027h),A			; DEBOUNCE
00001C32: FD CB 3B 86	RES 0,(IY+3Bh)		; CDFLAG
00001C36: C9		RET


;-------------------------
; THE 'TABLE OF CONSTANTS'
;-------------------------
; The ZX81 (and Lambda ?) have only floating-point number representation.
; Both the ZX80 and the ZX Spectrum have integer numbers in some form.

;; stk-pi/2                                                 81 49 0F DA A2
00001C37:
        DEFB    $F1             ;;Exponent: $81, Bytes: 4
        DEFB    $49,$0F,$DA,$A2 ;;

;; stk-half                                                 80 00 00 00 00
00001C3C:
        DEFB    $30             ;;Exponent: $80, Bytes: 1
        DEFB    $00             ;;(+00,+00,+00)

;; stk-ten                                                  84 20 00 00 00
00001C3E:
        DEFB    $34             ;;Exponent: $84, Bytes: 1
        DEFB    $20             ;;(+00,+00,+00)

;; stk-one                                                  81 00 00 00 00
00001C40:
		DEFB    $31             ;;Exponent $81, Bytes: 1
        ;; (the following byte matters: DEFB  $00)             ;;(+00,+00,+00)

;; stk-zero                                                 00 00 00 00 00
00001C41:
        DEFB    $00             ;;Bytes: 1
        DEFB    $B0             ;;Exponent $00
        DEFB    $00             ;;(+00,+00,+00)

;; INT-TO-FP
00001C44: F5		PUSH AF
00001C45: F7		RST 30h				; FP-CALC
00001C46: FA F1 CD	JP M,CDF1h
00001C49: 75		LD (HL),L
00001C4A: 07		RLCA
00001C4B: D8		RET C
00001C4C: F7		RST 30h				; FP-CALC
00001C4D: 33		INC SP
00001C4E: 77		;;stk-ten
00001C4F: 1F		;;multiply
00001C50: AA		XOR D
00001C51: CF		RST 08h		; NEXT-CHAR
00001C52: 18 F4		JR -0Ch

; ----------------------
; THE 'ALPHA' SUBROUTINE
; ----------------------

;; ALPHA
00001C54: FE 26		CP 26h

;; ALPHA-2
00001C56: 3F		CCF
00001C57: D8		RET C
00001C58: FE 1C		CP 1Ch
00001C5A: D8		RET C
00001C5B: D6 1C		SUB 1Ch
00001C5D: C9		RET

;; SCROLL
00001C5E: 21 9F 40	LD HL,409Fh		; D-FILE + 1 + 33
00001C61: 11 7E 40	LD DE,407Eh		; D-FILE + 1
00001C64: 01 F6 02	LD BC,02F6h
00001C67: ED B0		LDIR
00001C69: 21 A0 20	LD HL,20A0h		; ATTR + 1 + 33
00001C6C: 11 7F 20	LD DE,207Fh		; ATTR + 1
00001C6F: 01 F6 02	LD BC,02F6h
00001C72: ED B0		LDIR
00001C74: FD 46 22	LD B,(IY+22h)	; DF_SZ
00001C77: 04		INC B
00001C78: 18 05		JR +05h



00001C7A: CD 57 1D	CALL 1D57h		; routine CLEAR-PRB

;--------------------------
; THE 'CLS' COMMAND ROUTINE
;--------------------------
;
;

;; CLS
00001C7D: 06 18		LD B,18h

;; B-LINES
00001C7F: C5		PUSH BC
00001C80: CD 91 14	CALL 1491h					; LOC-ADDR for current row
00001C83: C1		POP BC
00001C84: AF		XOR A
00001C85: 32 7C 40	LD (407Ch),A
00001C88: 32 1E 40	LD (401Eh),A				; BREG/FLAGS
00001C8B: 5D		LD E,L
00001C8C: 7C		LD A,H
00001C8D: D6 20		SUB 20h
00001C8F: 57		LD D,A
00001C90: 13		INC DE
00001C91: 3A 08 40	LD A,(4008h)				; ATTR-P
00001C94: 0E 20		LD C,20h
00001C96: 36 00		LD (HL),00h
00001C98: 12		LD (DE),A
00001C99: 23		INC HL
00001C9A: 13		INC DE
00001C9B: 0D		DEC C
00001C9C: 20 F8		JR NZ,-08h
00001C9E: 36 76		LD (HL),76h
00001CA0: 23		INC HL
00001CA1: 13		INC DE
00001CA2: 10 F0		DJNZ -10h
00001CA4: C9		RET

;-------------------------------------
; Swap first number with second number
;-------------------------------------
; This routine exchanges the last two values on the calculator stack
; On entry, as always with binary operations,
; HL=first number, DE=second number
; On exit, HL=result, DE=stkend.

;; exchange
00001CA5: 06 05		LD B,05h
00001CA7: 4E		LD C,(HL)
00001CA8: 1A		LD A,(DE)
00001CA9: 77		LD (HL),A
00001CAA: 79		LD A,C
00001CAB: 12		LD (DE),A
00001CAC: 13		INC DE
00001CAD: 23		INC HL
00001CAE: 10 F7		DJNZ -09h
00001CB0: C9		RET

;---------------------------
; THE 'MAKE ROOM' SUBROUTINE
;---------------------------
;
;

;; MAKE-ROOM plus 4
00001CB1: 03		INC BC
00001CB2: 03		INC BC
00001CB3: 03		INC BC
00001CB4: 03		INC BC

;; MAKE-ROOM
00001CB5: CD F5 13	CALL 13F5h		; routine TEST-ROOM
00001CB8: CD 3F 1A	CALL 1A3Fh		; routine POINTERS
00001CBB: 03		INC BC
00001CBC: 2A 1C 40	LD HL,(401Ch)	; STKEND
00001CBF: EB		EX DE,HL
00001CC0: ED B8		LDDR
00001CC2: C9		RET

; THE 'COPY' COMMAND ROUTINE
;---------------------------
; The full character-mapped screen is copied to the Printer.

;; COPY
00001CC3: 21 7E 40	LD HL,407Eh			; D-FILE + 1
00001CC6: 06 16		LD B,16h			; prepare to copy twenty four text lines.
00001CC8: 18 2C		JR +2Ch

00001CCA: 3A 38 40	LD A,(4038h)		; PR_CC
00001CCD: FE 3C		CP 3Ch
00001CCF: C8		RET Z

00001CD0: 3E 76		LD A,76h
;; LPRINT-CH
00001CD2: 4F		LD C,A
00001CD3: DB FB		INA (FBh)
00001CD5: 17		RLA
00001CD6: FD A6 06	AND (IY+06h)		; editor MODE
00001CD9: 79		LD A,C
00001CDA: FA F7 1D	JP M,1DF7h

00001CDD: FE 76		CP 76h
00001CDF: 28 10		JR Z,+10h			; to COPY-BUFF

00001CE1: FD 6E 38	LD L,(IY+38h)		; PR_CC
00001CE4: 26 40		LD H,40h
00001CE6: 3E 5B		LD A,5Bh
00001CE8: BD		CP L
00001CE9: DC F1 1C	CALL C,1CF1h		; routine COPY-BUFF
00001CEC: 71		LD (HL),C
00001CED: FD 34 38	INC (IY+38h)		; PR_CC
00001CF0: C9		RET

;; COPY-BUFF
00001CF1: 21 3C 40	LD HL,403Ch			; set HL to start of printer buffer PRBUFF.

00001CF4: 06 01		LD B,01h
00001CF6: DB FB		INA (FBh)
00001CF8: CB 77		BIT 6,A
00001CFA: 20 71		JR NZ,+71h
00001CFC: CD 62 0D	CALL 0D62h			; routine SET-FAST
00001CFF: AF		XOR A
00001D00: 57		LD D,A
00001D01: E5		PUSH HL
00001D02: D3 FB		OUTA (FBh)
00001D04: E1		POP HL
00001D05: CD 28 1C	CALL 1C28h			; routine BREAK-1 test for BREAK key.
00001D08: 30 5E		JR NC,+5Eh

; ---

;; COPY-CONT
00001D0A: DB FB		INA (FBh)		; read from printer port.
00001D0C: 17		RLA				; test bit 7
00001D0D: 30 F6		JR NC,-0Ah

00001D0F: 78		LD A,B			; text line count to A?
00001D10: D6 02		SUB 02h			; check if last line.
00001D12: 9F		SBC A			; now $FF if last line else zero.

00001D13: E5		PUSH HL			; preserve the character ptr


; now cleverly prepare a printer control mask setting bit 2 (later moved to 1)
; of E to slow printer for the last two pixel lines ( D = 6 and 7)

00001D14: A2		AND D			; and with pixel line offset 0-7
00001D15: 07		RLCA			; shift to left.
00001D16: A2		AND D			; and again.
00001D17: 5F		LD E,A			; store control mask in E.

00001D18: C5		PUSH BC
00001D19: 06 08		LD B,08h

;; COPY-NEXT
00001D1B: 7E		LD A,(HL)		; load character from screen or buffer.
00001D1C: 23		INC HL
00001D1D: FE 76		CP 76h			; is character a NEWLINE ?
00001D1F: 28 1D		JR Z,+1Dh		; forward, if so, to COPY-N/L

00001D21: D3 F6		OUTA (F6h)		; select charset char number (00..3F)
00001D23: 17		RLA
00001D24: 7A		LD A,D
00001D25: D3 F5		OUTA (F5h)		; select charset line number (00..07)
00001D27: DB F6		INA (F6h)		; read selected charset data (8 pixels)
00001D29: 4F		LD C,A
00001D2A: 9F		SBC A
00001D2B: A9		XOR C
00001D2C: 4F		LD C,A

;; COPY-BITS
00001D2D: CB 11		RL C
00001D2F: 7B		LD A,E
00001D30: 1F		RRA
00001D31: 08		EX AF,AF'

;; COPY-WAIT
00001D32: DB FB		INA (FBh)			; read the printer port
00001D34: 0F		RRCA				; test for alignment signal from encoder.
00001D35: 30 FB		JR NC,-05h			; loop if not present to COPY-WAIT

00001D37: 08		EX AF,AF'
00001D38: D3 FB		OUTA (FBh)
00001D3A: 10 F1		DJNZ -0Fh			; loop for all eight bits to COPY-BITS

00001D3C: 18 DB		JR -25h				; back for adjacent character line to COPY-NEXT
00001D3E: C1		POP BC


; ---

; A NEWLINE has been encountered either following a text line or as the 
; first character of the screen or printer line.

00001D3F: DB FB		INA (FBh)
00001D41: 0F		RRCA
00001D42: 30 FB		JR NC,-05h
00001D44: 7B		LD A,E
00001D45: 0F		RRCA
00001D46: D3 FB		OUTA (FBh)
00001D48: 14		INC D
00001D49: CB 5A		BIT 3,D
00001D4B: 28 B7		JR Z,-49h

; eight pixel lines, a text line have been completed.

00001D4D: D1		POP DE
00001D4E: 10 AF		DJNZ -51h		; decrease text line count and  back if not zero to COPY-LOOP
00001D50: 3E 0F		LD A,0Fh
00001D52: D3 FB		OUTA (FBh)

;; COPY-END
00001D54: CD A9 12	CALL 12A9h				; routine SLOW/FAST


;--------------------------------------
; THE 'CLEAR PRINTER BUFFER' SUBROUTINE
;--------------------------------------
; This subroutine sets 32 bytes of the printer buffer to zero (space) and
; the 33rd character is set to a NEWLINE.
; This occurs after the printer buffer is sent to the printer but in addition
; after the 24 lines of the screen are sent to the printer. 
; Note. This is a logic error as the last operation does not involve the 
; buffer at all. Logically one should be able to use 
; 10 LPRINT "HELLO ";
; 20 COPY
; 30 LPRINT ; "WORLD"
; and expect to see the entire greeting emerge from the printer.
; Surprisingly this logic error was never discovered and although one can argue
; if the above is a bug, the repetition of this error on the Spectrum was most
; definitely a bug.
; Since the printer buffer is fixed at the end of the system variables, and
; the print position is in the range $3C - $5C, then bit 7 of the system
; variable is set to show the buffer is empty and automatically reset when
; the variable is updated with any print position - neat.

;; CLEAR-PRB
00001D57: 06 20		LD B,20h				
00001D59: 21 5C 40	LD HL,405Ch				; address fixed end of PRBUFF
00001D5C: 36 76		LD (HL),76h				; place a newline at last position.

;; PRB-BYTES
00001D5E: 2B		DEC HL					; decrement address
00001D5F: 36 00		LD (HL),00h				; place a zero byte
00001D61: 10 FB		DJNZ -05h				; loop for all thirty-two to PRB-BYTES
00001D63: 7D		LD A,L
00001D64: 32 38 40	LD (4038h),A			; update one-byte system variable PR_CC
00001D67: C9		RET


00001D68: D3 FB		OUTA (FBh)				; stop ZX printer motor, de-activate sylus.
00001D6A: C3 E4 19	JP 19E4h				; REPORT-D  (BREAK error msg)

00001D6D: FD CB 06 7E	BIT 7,(IY+06h)		; editor MODE
00001D71: 20 49		JR NZ,+49h
00001D73: C5		PUSH BC
00001D74: E5		PUSH HL
00001D75: 21 64 1E	LD HL,1E64h
00001D78: 06 07		LD B,07h
00001D7A: CD 59 1E	CALL 1E59h
00001D7D: E1		POP HL
00001D7E: 5E		LD E,(HL)
00001D7F: 23		INC HL
00001D80: E5		PUSH HL
00001D81: CB 73		BIT 6,E
00001D83: 20 29		JR NZ,+29h
00001D85: 26 08		LD H,08h
00001D87: 0E 07		LD C,07h
00001D89: 7B		LD A,E
00001D8A: FD CB 3B 7E	BIT 7,(IY+3Bh)		; CDFLAG
00001D8E: 28 01		JR Z,+01h
00001D90: 76		HALT
00001D91: D3 F6		OUTA (F6h)				; select charset char number (00..3F)
00001D93: 79		LD A,C
00001D94: D3 F5		OUTA (F5h)				; select charset line number (00..07)
00001D96: DB F6		INA (F6h)				; read selected charset data (8 pixels)
00001D98: 44		LD B,H
00001D99: 1F		RRA
00001D9A: 10 FD		DJNZ -03h
00001D9C: CB 1D		RR L
00001D9E: 0D		DEC C
00001D9F: F2 89 1D	JP P,1D89h
00001DA2: 7B		LD A,E
00001DA3: 17		RLA
00001DA4: 9F		SBC A
00001DA5: AD		XOR L
00001DA6: CD E4 1D	CALL 1DE4h
00001DA9: 25		DEC H
00001DAA: 20 DB		JR NZ,-25h
00001DAC: 18 CF		JR -31h
00001DAE: 21 61 1E	LD HL,1E61h
00001DB1: 06 03		LD B,03h
00001DB3: CD 59 1E	CALL 1E59h
00001DB6: E1		POP HL
00001DB7: C1		POP BC
00001DB8: 10 B9		DJNZ -47h
00001DBA: 18 9B		JR -65h
00001DBC: FD CB 06 B6	RES 6,(IY+06h)		; editor MODE
00001DC0: 7E		LD A,(HL)
00001DC1: E5		PUSH HL
00001DC2: 4F		LD C,A
00001DC3: CD E1 1D	CALL 1DE1h
00001DC6: E1		POP HL
00001DC7: 7E		LD A,(HL)
00001DC8: 23		INC HL
00001DC9: FE 76		CP 76h
00001DCB: 20 F3		JR NZ,-0Dh
00001DCD: 10 F1		DJNZ -0Fh
00001DCF: 18 86		JR -7Ah
00001DD1: CB 76		BIT 6,(HL)
00001DD3: CB B6		RES 6,(HL)
00001DD5: 28 0A		JR Z,+0Ah
00001DD7: FE 20		CP 20h
00001DD9: 38 09		JR C,+09h
00001DDB: 3E 27		LD A,27h
00001DDD: CD E4 1D	CALL 1DE4h
00001DE0: 79		LD A,C
00001DE1: CD 04 1E	CALL 1E04h

00001DE4: F5		PUSH AF
00001DE5: CD 28 1C	CALL 1C28h			; routine BREAK-1 test for BREAK key.
00001DE8: 30 80		JR NC,-80h
00001DEA: DB FB		INA (FBh)
00001DEC: CB 6F		BIT 5,A
00001DEE: 20 03		JR NZ,+03h
00001DF0: 17		RLA
00001DF1: 38 F2		JR C,-0Eh
00001DF3: F1		POP AF
00001DF4: D3 FB		OUTA (FBh)
00001DF6: C9		RET

00001DF7: FD 34 38	INC (IY+38h)	; PR_CC
00001DFA: 21 06 40	LD HL,4006h		; editor MODE
00001DFD: FE 88		CP 88h
00001DFF: 20 D0		JR NZ,-30h
00001E01: CB F6		SET 6,(HL)
00001E03: C9		RET

00001E04: FE 76		CP 76h
00001E06: 20 0C		JR NZ,+0Ch
00001E08: 3E 0D		LD A,0Dh
00001E0A: CD E4 1D	CALL 1DE4h
00001E0D: FD 36 38 3C	LD (IY+38h),3Ch		; PR_CC <- activate printer
00001E11: 3E 0A		LD A,0Ah
00001E13: C9		RET

00001E14: E6 3F		AND 3Fh
00001E16: FE 26		CP 26h
00001E18: 38 08		JR C,+08h
00001E1A: C6 1B		ADD 1Bh
00001E1C: CB 79		BIT 7,C
00001E1E: C8		RET Z
00001E1F: C6 20		ADD 20h
00001E21: C9		RET

00001E22: FE 1C		CP 1Ch
00001E24: 38 03		JR C,+03h

00001E26: C6 14		ADD 14h			; 20
00001E28: C9		RET

00001E29: 5F		LD E,A
00001E2A: 16 00		LD D,00h
00001E2C: 21 3D 1E	LD HL,1E3Dh
00001E2F: 19		ADD HL,DE
00001E30: 79		LD A,C
00001E31: FE 81		CP 81h
00001E33: 38 03		JR C,+03h
00001E35: FE 86		CP 86h
00001E37: 3F		CCF
00001E38: 7E		LD A,(HL)
00001E39: D8		RET C
00001E3A: C6 20		ADD 20h
00001E3C: C9		RET

00001E3D: 20 5B		JR NZ,+5Bh
00001E3F: 5C		LD E,H
00001E40: 5D		LD E,L
00001E41: 5E		LD E,(HL)
00001E42: 40		LD B,B
00001E43: 5F		LD E,A
00001E44: 26 27		LD H,27h
00001E46: 23		INC HL
00001E47: 21 22 25	LD HL,2522h
00001E4A: 24		INC H
00001E4B: 3A 3F 28	LD A,(283Fh)
00001E4E: 29		ADD HL,HL
00001E4F: 3E 3C		LD A,3Ch
00001E51: 3D		DEC A
00001E52: 2B		DEC HL
00001E53: 2D		DEC L
00001E54: 2A 2F 3B	LD HL,(3B2Fh)
00001E57: 2C		INC L
00001E58: 2E 7E		LD L,7Eh
00001E5A: CD E4 1D	CALL 1DE4h
00001E5D: 23		INC HL
00001E5E: 10 F9		DJNZ -07h
00001E60: C9		RET

00001E61: db 0A, 1B, 32
00001E64: db 1B, 41, 08, 1B, 4B, 00, 01


00001E6B: db FF...
(...)
00001FFF: db ..FF


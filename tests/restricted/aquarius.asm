; 
; MATTEL AQUARIUS ROM DISASSEMBLY
; By Kenny Millar 26 April 2000
; Last update:	15th August 2000
; email: beetleuk@aol.com
;
; Improved with some of the results by basck.c
;
; The original Aquarius rom was marked as 
; (C) Microsoft 1982, However I am pretty sure
; that after the demise of the Aqurius production
; this software passed into the public domain.
;
; However this document is my property, although you can
; copy and distribute it freely, but please credit
; me as the original author, and include my email address.
;
; Changes and additions are welcome. Your input will be
; credited accordingly.
;

#define CLS	defb $0b 	; The 'clear screen' character code.
#define CR	defb $0d 	; Carriage return
#define	LF	defb $0a	; Line Feed
#define CRLF	defb $0d,$0a	; Carriage return+linefeed.

;SYSTEM VARIABLES.
;    NAME       LOCATION	DESCRIPTION
;-------------------------------------------------------------------
; 1. COLRAM		#3400		Start of screen colour ram
; 2. CURCOL		#3800 	Current cursor column 
; 3. CURRAM		#3801 	Position in CHARACTER RAM of cursor
; 4. USRJMP		#3803		Location of JMP instruction for USR.
; 5. ROWCOUNT	#3808		Counter for number of screen lines printed.
; 6. LASTFF		#3809		The value last sent out to ($FF)
; 7. LSTASCI	#380a		the ASCII value of last key pressed.
; 8. KWADDR		#380b		Address of the keyword in the keyword table.
; 9. CURHOLD	#380d		Holder for the character behind the cursor.
;10. LASTKEY	#380E		The SCAN CODE of the last key pressed.
;11. SCANCNT	#380f		The number of SCANS the key has been down for.
;12. PRNCOL     	#3846		The current printer column.
;13. CHANNEL	#3847		Channel: 0=screen, 1=printer.
;14. CURLIN		#384D		The current BASIC line number.
;15. BASTART	#384F		Address in ram of first line of basic.
;16. LINBUF		#3860		Address of start of the line input buffer.
;17. RAMTOP		#38AD 	Address of top of physically working ram.
;18. TMPSTAT	#38ce		Temporary holder of next statement address
;19. CONTPOS	#38d4		Position in memory to CONTinue from.
;20. CONTLIN	#38d2		Line number to CONTinue from.
;21. BASEND		#38d6		Address in ram of the last byte of the BASIC program.
;22. RESTORE	#38DC		Address in ram of line last RESTORE'd 

; 		     IO Ports
;    NAME       Address	Bit	DESCRIPTION
;-------------------------------------------------------------------
; 1. SPEAKER	FC	0	Loud speaker
; 2. PRINTER	FE	0	Printer
; 3. KEYBOARD	FF	0-6	Keyboard (See NOTE: Keyboard)


; NOTE: Keyboard.
;
; The Aquarius keyboard is layed out as 8 columns of 6 keys, giving
; a maximum of 48 keys.
; The reset key is wired directly to the RESET- pin of the CPU.
; The Aquarius keyboard routines make use of the 'feature' of the Z80
; where by the byte in B register is output on the high byte of the address
; bus during an IN A,(C) instruction.
;
; Any BIT which is SET in B during the IN instruction enables a single column
; of the keybaord. Then any key which is down during the read will create a 0
; in the appropriate bit of A, this is inverted so a down key will create a 1
; in the appropraite bit of A.



;****************************
;*  MAIN EXECUTIVE ROUTINES *
;****************************
;  ENTRY
;  On power up the Z80 always starts processing from 0x0000
; 
ENTRY:  jp      $1fe1,START	; immediately jump to START
l0003:	defb    82,06,22	; hex representation of "22/06/82" - The date!
l0006:	defb    $0B		; Undefined, possibly the revision number.
        defb	$00		;

;*************************
;*** RESTART FUNCTIONS ***
;*************************

; RST08: (CHKNXT)
; This routine compares the current character
; in the statement with the DEFB which follows
; the RST $08 instruction. 
; If they are the same, then the routine returns with Z flag set.
; otherwise it branches to report a syntax error.
;
RST08:  ld      a,(hl)			; Retrieve (HL)
        ex      (sp),hl			; Retrieve (SP)
        cp      (hl)			; Compare (HL) with (SP)
        inc     hl			; Adjust SP to account for the DEFB Byte
        ex      (sp),hl			; on the stack.
        jp      nz,ERROR_SN,$03c4	; If (HL) and (SP) are not equal, 
					; report a SyNtax error.
					; Else return.
;
; Get the next character,
; return with CARRY SET if it is between 0 and 9 incl.
GETNEXT:
RST10:  inc     hl		; increment pointer	
        ld      a,(hl)		; retrieve character
        cp      $3a		; compare with ':'
        ret     nc		; return if it is above "9".
        jp      $0670		; else jump to $0670 to check if 
				; it is between '0' and '9'
				; this function will return with carry set if it is.

PRNCHAR:
RST18:  jp      PRNTCHR		; Print the character in A.
        nop     
        nop     
        nop     
        nop     
        nop     
;
; Compare HL with DE to find greater.
; If DE is greater, CARRY will be set
;CMPHLDE:
CMPHLDE:
RST20:  ld      a,h	; Compare MSB first.
        sub     d		; subtract D from H
        ret     nz	; Return with carry set if DE>HL
				; otherwise check LSB...
        ld      a,l		; if (H-D)=0 then do (L-E)
        sub     e		; subtract E from L
        ret     		; and return.

        nop     
        nop     

RST28:
l0028:  ld      a,($38e7)	; Get byte at ($38e7)
        or      a		; Set flags
        jp      nz,$14eb	; Jump if not zero
        ret     		; Return if zero.

;
; The user can write his own RST30 routine by putting the start address
; into $3806,$3807.
; The default one does nothing but chew up the DEFB after the RST 30h
; Nothing in the BASIC rom changes this from default.

CALLUDF:
RST30:  ld      ix,($3806)	;initially this contains $003b
        jp      (ix)		; unless changed by the user this will
        nop     		; jump to 003b which just chews up the DEFB and returns.
        nop     

;
; location USRJMP contains a JMP command followed by 2 bytes
; initially these bytes point to ERROR_FC,$0697 (The UF error report)
; but are modified by the user when they prepare for a USR 
; command in basic to jump to his own routine.
;
CALLUSR:
RST38:  jp      USRJMP	; initially this holds 0697
			; which just reports a NF error.
;
; This is the system default UDF which does nothing but chew up the DEFB
; in the code after the RST $30 command.
; The user can write his own UDF by placing the code in ram and then
; putting a 16 pit pointer to his code at $3806, LSB first.
;
SYSUDF:
l003b:  exx     		;swap register sets
        pop     hl		;
        inc     hl		;Increment the SP to account for the defb after each RST $30
        push    hl		;
        exx     
        ret     

START2:
l0041:  ld      sp,$38a0	; initialise stack pointer
        ld      a,$0b		; CHR$($0b) = clear the screen.
        call    PRNCHR	

        ld      hl,(CURRAM)	; location in ram of cursor
        ld      (hl),$20	; blank out the cursor with a space.

        ld      a,$07		; CHR$($07) = BEEP
        call    PRNCHR	

        xor     a		; make a=00
        out     ($ff),a		; 
        ld      hl,$2fff	; end of rom space?
        ld      ($385d),hl	; 

;
; Check for presence of Xtended-ROM cartrige?
; If found jump into it 
;
XROMCHK:
        ld      de,$e011	; 
        ld      hl,$0081	; 

l0062:  dec     de		; A simple for of encryption is used, so we don't know
        dec     de		; what the rom is checking for.
        inc     hl		; Basically it jumps backwards from $e011 two bytes 
        ld      a,(de)		; at a time , does some simple maths on the contents
        rrca    		; and compares then with the bytes starting at $0081.
        rrca    		;
        add     a,e		;
        cp      (hl)		; 
        jr      z,$0062       	; Perfect match, so check next byte...
        ld      a,(hl)		;
        or      a		; Did we get as far as the $00 end marker byte?
        jr      nz,$0089      	; if not continue at START3 into BASIC
        ex      de,hl		; else cary on here.
        ld      b,$0c

l0073:  add     a,(hl)
        inc     hl
        add     a,b
        dec     b
        jr      nz,$0073        ;  (-6)
        xor     (hl)
        out     ($ff),a
        ld      (LASTFF),a
        jp      $e010		; jump to ROM cartridge????

l0082:  defb	'+7$$3,'	
	defb	$00


START3:
l0089:  ld      de,$31a1 	; Offset into character ram
        ld      hl,$00b0 	; 'BASIC'
        ld      bc,$0005 	;  5 letters long
        ldir			;  copy to character ram matrix
        ld      de,$3210	;  offset into chr ram
        ld      hl,$00b5 	; 'Press RETURN KEY TO START'
        ld      bc,$0019	;  0x19 charcters long.
        ldir    		;  copy into screen ram.

CLRCYCLE:
l009f:  ld      b,$03		; BLACK on YELLOW
        call    SPLASH,$00cf	; set colours, delay, check for RTN key
        ld      b,$02		; BALCK on BLUE
        call    SPLASH,$00cf	; set colours, delay, check for RTN key
        ld      b,$06		; BLACK on GREEN
        call    SPLASH,$00cf	; set colours, delay, check for RTN key
        jr      CLRCYCLE        ; do it all again....

l00b0:  defb	'BASIC'
l00b5:  defb	"Press RETURN key to start."
        nop     
;
; Set background colour to b, 
; delay 1 second, 
; check for RTN key etc
;
SPLASH:
l00cf:  ld      hl,COLRAM 		; start of screen colour ram

l00d2:  ld      (hl),b			; The colour to be used.
        inc     hl			; fill screen ram with colour code.
        ld      a,h			; stop when we get to $3800
        cp      $38
        jr      nz,$00d2            	; Loop.

        ld      hl,$4000		; Now we have filled the colour ram,
					; we are going to loop $4000 times
					; checking for RTN or CTRL+C each time.

l00dc:  call    KEYCHK,$1e80		; Get ASCII of last key pressed.
        cp      $0d			; was RTN pressed?
        jr      z,COLDSTART,$00fd       ; If so, start with NEW

        cp      $03			; was CTRL-C pressed?
        jr      z,WARMSTART,$00ed      	; if so start without NEW
					; all other key codes ignored.
        dec     hl			; decrement the loop counter
        ld      a,h			; and compare..
        or      l			; ..with 00
        jr      nz,$00dc            	; total loop $4000 times
        ret     			; then return for next background colour.
					; keep doing this until the user presses RTN 
					; or CTRL+C

;
; If the users presses CTRL+C on the start screen
; we start without doing a 'NEW'.
; this allows the user to recover from a crash or infinite loop
; without loosing the programme. This is an undocumented feature.
;
WARMSTART:
l00ed:  ld      a,$0b			; Preload A with the clear-screen character
        call    PRNCHR1,$1d72		; Print the character in A
        ld      a,(LASTFF)		; 
        out     ($ff),a			; 
        call    CLRWKSP,$0be5		; Clear workspace and prepare for IM-MODE
        call    KEYBREAK,$1a40		; Start as though the program 
					; had just got a "Break" during execution.
;
;START with NEW
;
COLDSTART:
l00fd:  ld      hl,$0187		; copy $51 bytes from $0187 to
	ld      bc,$0051		; $3803, thereby initialising most
        ld      de,USRJMP		; system varibles.
        ldir    			; 
        xor     a			; Clear A
        ld      ($38a9),a		; And initialise some 
        ld      ($3900),a		; more system variables.
;
; RAM test
;

        ld      hl,$3964		; start of USER RAM
RAMTEST:
l0112:  inc     hl
        ld      c,(hl)			; Save current contents of RAM location
        ld      a,h			;
        or      l			; Are we done? (ie HL wrapped back to 0000)
        jr      z,SVRAMTOP,$0123	; If so, jump to next section.
        xor     c			; XOR C into Accumulator
        ld      (hl),a			; store into current memory address
        ld      b,(hl)			; then retrieve
        cpl     			; invert
        ld      (hl),a			; store
        ld      a,(hl)			; retrieve
        cpl     			; invert
        ld      (hl),c			; (restore ORIGINAL contents)
        cp      b			; is location working?
        jr      z,RAMTEST     		; If so, jump to top of loop and test next location.

					; If the previously tested memory address 
SVRAMTOP:				; didn't work we fall through to here.
					; and HL points to the last address tested.
l0123:  dec     hl			; Derement to point to last WORKING address.
        ld      de,$3a2c		; Start of program ram 14892 (decimal)
        rst     $20			; COMPARE HL,DE		

        jp      c,OM_ERROR,$0bb7	; if start of program ram is > working ram
					; then we have  a problem!
					; so we report the error, and drop out to
					; immediate mode.

        ld      de,$ffce		; this value is -50
l012e:  ld      (RAMTOP),hl		;
        add     hl,de			; subtract 50 from RAMTOP
        ld      ($384b),hl		; and save the result here.
        call    $0bbe			;
        call    $1ff2 			; 'Print copyright message.

l013b:  ld      sp,$3865	;
        call    CLRWKSP,$0be5	; Clear workspace and prepare to enter Immediate mode.
        ld      hl,$2005	;
        ld      de,$0082	;

l0147:  ld      a,(de)		;
        or      a			; if (DE)= $00 jump to 1fe8 and start
					; running code from cartridge.
        jp      z,JMPCART,$1fe8		;
        cp      (hl)			; otherwise compare (DE) with (HL)
        jr      nz,$0153                ; if not the same jump forward and start BASIC
        dec     hl
        inc     de
        jr      $0147                   ; Loop 

l0153:  ld      a,r			; obtain a random value from Refresh register.
        rla     			; rotate it left, just for the hell.
        add     a,c			; and add C - that should be pretty random now!
        out     ($ff),a			; throw it out to ($FF)
        ld      (LASTFF),a		; and save to LASTFF
        jp      OKMAIN,$0402		; print 'Ok' and enter immediate mode.

l015f:  defb	CLS+"Copyright . 1982 by Microsoft Inc. S2" +CR
	defb	00

;The bytes from $0187 to $01d7 are copied to $3803 onwards as default data.

l0187:  jp      ERROR_FC,$0697		; $3803
	defb	$3b,$00			; ($3806,$3807) = $003b Address of RST30
	defb	$00			; $3808
        defb	$a3			; $3809 = LASTFF - the last value
					; sent OUT to $ff
	defb	$00			; $380a = LASTASCI
	defb	$00,$00			; $380b,$390c = Address of keyword in table.
        defb	$20			; $380d - Holder for the character behind 
					; the cursor.
	defb	$00			; $380e The scan code of the last key pressed.
	defb	$00			; $380f - Scan count. The number of scan loops
					; the key has been held down for.
	
l0194:	sub	$00			; the code from here on is copied to
	ld	l,a			; $3810 onwards. This is so that it can
	ld	a,h			; be replaced by the USER or CARTRIDGE.
	sbc	a,00			; 
	ld	h,a
	ld	a,b
	sbc	a,00
	ld      b,a
        ld      a,$00
        ret     

l01a2:  nop     
        nop     
        nop     
        dec     (hl)
        ld      c,d
        jp      z,$3999
        inc     e
        halt    
        sbc     a,b

l01ad:  ld      ($b395),hl
        sbc     a,b
        ld      a,(bc)
        ld      b,a
        sbc     a,b
        ld      d,e
        pop     de
        sbc     a,c
        sbc     a,c
        ld      a,(bc)
        ld      a,(de)
        sbc     a,a
        sbc     a,b
        ld      h,l
        cp      h
        call    $d698

l01c2:  ld      (hl),a
        ld      a,$98
        ld      d,d

l01c6:  rst     $0
        ld      c,a

l01c8:  add     a,b
        nop     
        nop     
        nop     
        jr      z,$01dc                 ;  (14)
        nop     
        ld      h,h
        add     hl,sp
        cp      $ff
        ld      bc,$2139
;
; JUMP table
; This table is used by the interpreter to JUMP to the correct 
; instructions based on the command byte found in the BASIC line.
; On entry to each routine, the Z flag is set if there are no 
; more parameters following the command or statement.
; 
; NOTE, although the jump table includes entries for ATN and FN
; there is no implementation for these commands in the ROM
; so they cannot be used. 
;
l01d5	defb	$0c21	; END
l01d7	defb	$05bc	; FOR
l01d9	defb	$0d13	; NEXT
l01db	defb	$071c	; DATA
l01dd	defb	$0893	; INPUT
l01df	defb	$10cc	; DIM
l01e1	defb	$08be	; READ
l01e3	defb	$0731	; LET
l01e5	defb	$06dc	; GOTO
l01e7	defb	$06be	; RUN
l01e9	defb	$079c	; IF
l01eb	defb	$0c05	; RESTORE
l01ed	defb	$06cb	; GOSUB
l01ef	defb	$06f8	; RETURN
l01f1	defb	$071e	; REM
l01f3	defb	$0c1f	; STOP
l01f5	defb	$0780	; ON
l01f7	defb	$07b5	; LPRINT
l01f9	defb	$1b15	; COPY
l01fb	defb	$0b3b	; DEF
l01fd	defb	$0b6d	; POKE
l01ff	defb	$07bc	; PRINT
l0201	defb	$0c4b	; CONT
l0203	defb	$056c	; LIST
l0205	defb	$0567	; LLIST
l0207	defb	$0ccd	; CLEAR
l0209	defb	$1c2c	; CLOAD
l020b	defb	$1c08	; CSAVE
l020d	defb	$1a4f	; PSET
l020f	defb	$1a4c	; PRESET
l0211	defb	$1ad6	; SOUND
l0213	defb	$0bbd	; NEW
l0215	defb	$14f5	; SGN
l0217	defb	$15b1	; INT
l0219	defb	$1509	; ABS
l021b	defb	$3803	; USR
l021d	defb	$10a8	; FRE
l021f	defb	$0b2e	; LPOS
l0221	defb	$0b33	; POS
l0223	defb	$1775	; SQR
l0225	defb	$1866	; RND
l0227	defb	$1385	; LOG
l0229	defb	$17cd	; EXP
l022b	defb	$18d7	; COS
l022d	defb	$18dd	; SIN
l022f	defb	$1970	; TAN
l0231	defb	$1985	; ATN
l0233	defb	$0b63	; PEEK
l0235	defb	$0ff3	; LEN
l0237	defb	$0e29	; STR$
l0239	defb	$1084	; VAL
l023b	defb	$1002	; ASC
l023d	defb	$1013	; CHR$
l023f	defb	$1021	; LEFT$
l0241	defb	$1050	; RIGHT$
l0243	defb	$1059	; MID$


;Keyword table. NOTE! The first letter of each keyword is + $80
l0245:	defb 	'END'	defb	'FOR'		defb	'NEXT'	defb	'DATA'
	defb	'INPUT'	defb	'DIM'		defb	'READ'	defb	'LET'
	defb	'GOTO'	defb	'RUN'		defb	'IF'	defb	'RESTORE'
	defb	'GOSUB'	defb	'RETURN'	defb	'REM'	defb	'STOP'
	defb	'ON'	defb	'LPRINT'	defb	'COPY'	defb	'DEF'
	defb	'POKE'	defb	'PRINT'		defb	'CONT'	defb	'LIST'
	defb	'LLIST'	defb	'CLEAR'		defb	'CLOAD'	defb	'CSAVE'
	defb	'PSET'	defb	'PRESET'	defb	'SOUND'	defb	'NEW'

	defb	'TAB('	defb	'TO'		defb	'FN'	defb	'SPC('
	defb	'INKEY$'			defb	'THEN'	defb	'NOT'
	defb	'STEP'
L02E7:	defb	$AB,$AD,$AA,$AF,$DE ; - The operators: + - * / and ^

L02EC:	defb	'AND'	defb	'OR'	defb	$BE,$BD,$BC

	defb	'SGN'	defb	'INT'	defb	'ABS'	defb	'USR'
	defb	'FRE'	defb	'LPOS'	defb	'POS'	defb	'SQR'
	defb	'RND'	defb	'LOG'	defb	'EXP'	defb	'COS'
	defb	'SIN'	defb	'TAN'	defb	'ATN'	defb	'PEEK'
	defb	'LEN'	defb	'STR$'	defb	'VAL'	defb	'ASC'
	defb	'CHR$'	defb	'LEFT$'	defb	'RIGHT$'	defb	'MID$'
	defb	'POINT'

L034B 	defb	$80	defb	$79	defb	$5c	defb	$16	defb	$79
	defb	$5c	defb	$12	defb	$7c	defb	$c9	defb	$13
	defb	$7c	defb	$2d	defb	$14	defb	$7f	defb	$7e
	defb	$17	defb	$50	defb	$a9	defb	$0a	defb	$46
	defb	$a8

L0360:	defb	$0a
	defb	" Error" +beep 
	defb	$00
l0369:	defb	" in "
	defb 	$00
l036e:	defb	"Ok" +CR+LF
	defb	$00
l0373:	defb	"Break"
	defb	$00
;
; ERROR Abbreviations:
l0379:	defb	"NF"	; No UDF's defined.
	defb	"SN"	; Syntax error
	defb	"RG"	; Return without gosub
	defb	"OD"	; out of data
	defb	"FC"	; Function control error
	defb	"OV"	; Overflow
	defb	"OM"	; Out of memory
	defb	"UL"	; Undefined line
	defb	"BS"	; Bad subscript
	defb	"DD"	;
	defb	"/0"	; divide by zero
	defb	"ID"	; Illegal immediate mode
	defb	"TM"	; Type mismatch error
	defb	"OS"	; Over size error.
	defb	"LS"	; 
	defb	"ST"	; 
	defb	"CN"	; Can't continue
	defb	"UF"	; Undefined function error
	defb	"MO"	; Missing operand
     
l039f:  ld      hl,$0004
        add     hl,sp

l03a3:  ld      a,(hl)
        inc     hl
        cp      $81	;
        ret     nz

l03a8:  ld      c,(hl)
        inc     hl
        ld      b,(hl)
        inc     hl
        push    hl
        ld      h,b
        ld      l,c
        ld      a,d
        or      e
        ex      de,hl
        jr      z,$03b6                 ;  (2)
        ex      de,hl
        rst     $20			; COMPARE HL,DE

l03b6:  ld      bc,$000d
        pop     hl
        ret     z

        add     hl,bc
        jr      $03a3                   ;  (-27)

l03be:  ld      hl,($38c9)
        ld      (CURLIN),hl		; update current line number

;
; RST08_2:
; RST08 Jumps here if (sp) and (HL) are not the same.
;
ERROR_SN:
l03c4:  ld      e,$02			; offset from start of ERROR codes to SN
        ld      bc,$141e		; These instructions don't make any sense.
        ld      bc,$001e		; I assume they are here as fallout from
l03cb:  ld      bc,$121e		; previous code.
        ld      bc,$221e		;
        ld      bc,$0a1e		;
        ld      bc,$241e		;
        ld      bc,$181e		;

;
; ERROR: On entry E holds an offset to the 2 digit error abbreviation.
; 
ERROR:
l03db:  call    CLRWKSP,$0be5	; Clear workspace and prepare to enter
				; immediate mode.
        rst     $30,CALLUDF	; call the UDF if set.
	defb 	$00

        call    RSTCOL,$19de    ; reset cursor to start of next line,
				; if not already at start of line.

        ld      hl,$0379	; 'NF' the start of the error code table.
        rst     $30,CALLUDF
	defb    $01

	ld	d,a
	add     hl,de
        ld      a,$3f		;'?'
        rst     $18		;PRINTCHR

        ld      a,(hl)		; HL points to the start of a 2 digit error abbreviation.
        rst     $18		; PRINT CHARACTER in A
        rst     $10,GETNEXT	; Get next character
        rst     $18		; Print character in A
        ld      hl,$0361	; ' Error'+BEEP

l03f4:  call    0e9d,PRINTSTR   ; Print the string pointed to by HL
        ld      hl,(CURLIN)	; get current line number
        ld      a,h		; and check if it is 0000
        and     l		;
        inc     a		;
        call    nz,PERRIN,$166d	; If we were executing a BASIC line 
				; then Print ' in ' &CURLIN as part of 
				; the error report.


        ld      a,$c1		; ** This instruction overlaps with PUSH BC
				; ($c1) in the next instruction.
				; but this won't cause a problem.
OKMAIN2:
l0401:	pop	bc		;	

; OKMAIN
; Print OK and enter immediate mode.
;
OKMAIN:
l0402:  rst     $30,CALLUDF
        defb    2

        call    PRNHOME,$19be		; if we were printing to printer, LPRINT a CR and LF
        xor     a
        ld      (ROWCOUNT),a		; Set ROWCOUNT to 0.
        call    RSTCOL,$19de          	; reset cursor to start of next line,
					; if not already at start of line.
        ld      hl,$036e		; 'Ok' +CR+LF
        call    0e9d,PRINTSTR		; PRINTSTR

;
; IMMODE:
; Immediate mode starts here.
;
l0414:  ld      hl,$ffff
        ld      (CURLIN),hl
        call    GETLINE,$0d85		; Input a line from keyboard
					; check for CTRL+C, RTN, TAB, BELL, BS
					; CTRL+U (Abandon line), and CTRL+X (DELINE)
					; on return HL points to the location 
					; 1 before LINBUF, the line buffer
					; which now contains the line which was input.
					; If ther user pressed CTRL+C the 
					; carry flag is set.

        jr      c,IMMODE,$0414          ; If the CARRY FLAG is set then the user pressed CTRL+C
					; which has been handled, so we jump back to the start
					; of IMMODE.

					; fall through to here if CTRL+C was not pressed
					; during line entry.

        rst     $10,GETNEXT		; Get next character, which is actually 1st character
					; of the line buffer.
        inc     a
        dec     a			; set flags
        jr      z,IMMODE,$0414          ; If nothing to do, jump back to start of immediate mode
					; and start inputting a new line.
        push    af			; save character for later.
        call    STR2VAL,$069c		; attempt to convert the first part 
					; of the line to a number
					; on return DE = the number and 
					; HL will point to the 1st character
					; after the line number.
        push    de			; save results for later.

        call    $04bc			; 
        ld      b,a
        pop     de
        pop     af
        rst     $30,CALLUDF
        defb	$03

        jp      nc,$064b
        push    de
        push    bc
        xor     a
        ld      ($38cc),a
        rst     $10,GETNEXT		; get next character
        or      a			; set flags
        push    af			; save for later.
        call    FINDLIN,$049f		; Find address in ram of the start
					; of the line number held in DE
        jr      c,$0448                 ; 
        pop     af
        push    af
        jp      z,UL_ERROR,$06f3	; 
        or      a

l0448:  push    bc
        jr      nc,$045b                ;  (16)
        ex      de,hl
        ld      hl,(BASEND)

; DELLINE: Deletes the BASIC line pointed to by BC
DELLINE:
l044f:  ld      a,(de)			;
        ld      (bc),a			; copy (DE) to (BC)
        inc     bc
        inc     de
        rst     $20			; Until DE point to BASEND.
        jr      nz,$044f                ; 

        ld      h,b			; and update BASEND
        ld      l,c
        ld      (BASEND),hl

l045b:  pop     de
        pop     af
        jr      z,$0480                 ; 
        ld      hl,(BASEND)
        ex      (sp),hl
        pop     bc
        add     hl,bc
        push    hl
        call    $0b92
        pop     hl
        ld      (BASEND),hl
        ex      de,hl
        ld      (hl),h
        pop     de
        inc     hl
        inc     hl
        ld      (hl),e
        inc     hl
        ld      (hl),d
        inc     hl
        ld      de,LINEBUF

l0479:  ld      a,(de)
        ld      (hl),a
        inc     hl
        inc     de
        or      a
        jr      nz,$0479                ;  (-7)

l0480:  rst     $30,CALLUDF
	defb	$04
        call    $0bcb
        rst     $30,CALLUDF
	defb	$05
        inc     hl
        ex      de,hl

l0489:  ld      h,d
        ld      l,e
        ld      a,(hl)
        inc     hl
        or      (hl)
        jp      z,IMMODE,$0414		; top of immediate mode
        inc     hl
        inc     hl
        inc     hl
        xor     a

l0495:  cp      (hl)
        inc     hl
        jr      nz,$0495                ;  (-4)
        ex      de,hl
        ld      (hl),e
        inc     hl
        ld      (hl),d
        jr      $0489                   ;  (-22)


;
; On entry DE contains the line number to find.
; Entering here starts from very start of BASIC program.
FINDLIN:
l049f:  ld      hl,(BASTART)	; Retrieve address of first line of BASIC.

;
; On entry DE contains the line number to find.
; Entering here starts from current line.
;
FINDLIN2:
l04a2:  ld      b,h			; save HL into BC for later.
        ld      c,l
        ld      a,(hl)			; load a with (HL)
        inc     hl			; and then compare it 
        or      (hl)			; with (HL+1)
        dec     hl			; restore HL to original value.
        ret     z			; return if (HL) and (HL+1) =00

        inc     hl			; move to next 16 bit address
        inc     hl			;
        ld      a,(hl)			; move 16 bit value at (HL) into HL
        inc     hl
        ld      h,(hl)
        ld      l,a
        rst     $20			; COMPARE HL,DE

        ld      h,b			; Restore original HL
        ld      l,c
        ld      a,(hl)			; get 16 bit value at (HL)
        inc     hl			; into HL
        ld      h,(hl)			;
        ld      l,a
        ccf     			; compliment CF
        ret     z			; return if DE=HL
        ccf     			; compliment CF
        ret     nc			; return if HL>DE
        jr      FINDLIN2,$04A2          ; loop back again.

;
; I think this changes TEXT to a keyword value.
; on entry HL points to first character of text.
;
l04bc:  xor     a			; clear A
        ld      ($38ac),a		; 
        ld      c,$05
        ld      de,LINEBUF

l04c5:  ld      a,(hl)			; check current character.
        cp      $20			; If it is SPACE
        jp      z,$053c			; jump forward to $053c
        ld      b,a			; save A to B
        cp      $22			; if it is the " character
        jp      z,$0558			; then jump forward to $0558
        or      a
        jp      z,$055e			; is it $00, if so jump to $055e
        ld      a,($38ac)		
        or      a
        ld      a,(hl)
        jp      nz,$053c
        cp      $3f			; is it '?'
        ld      a,$95			; load a with keyword token for 'print'
        jp      z,$053c			; jump forward

        ld      a,(hl)
        cp      $30			; '0'
        jr      c,$04ee                 ;  (5)
        cp      $3c			; '<'
        jp      c,$053c

l04ee:  push    de
        ld      de,$0244
        push    bc
        ld      bc,$0536
        push    bc
        ld      b,$7f
        ld      a,(hl)
        cp      $61			; check if A is less than 'a'
        jr      c,$0505                 ; jump to $0505 if it is.
        cp      $7b			; check if it is >= 'z'
        jr      nc,$0505                ; jump to $0505 if it is.
				
        and     $5f			; A must be between 'a' and 'z'
					; so convert it to uppercase
        ld      (hl),a			; and replace it in the line buffer.

l0505:  ld      c,(hl)			; move character to C
        ex      de,hl			; swap DE,HL

l0507:  inc     hl			; HL now points to start of keyword table.
        or      (hl)			; 
        jp      p,$0507
        inc     b
        ld      a,(hl)
        and     $7f
        ret     z

        cp      c
        jr      nz,$0507                ;  (-13)
        ex      de,hl
        push    hl

l0516:  inc     de
        ld      a,(de)
        or      a
        jp      m,$0532
        ld      c,a
        ld      a,b
        cp      $88
        jr      nz,$0524                ;  (2)
        rst     $10,GETNEXT
        dec     hl

l0524:  inc     hl
        ld      a,(hl)			; retrieve cahracter into A
        cp      $61			; compare with 'a' 
        jr      c,$052c                 ; if below 'a' then jump
        and     $5f			; otherwise and it with $5F to make 
					; it upper case by stripping out bit 5

l052c:  cp      c			;
        jr      z,$0516                 ;  (-25)
        pop     hl
        jr      $0505                   ;  (-45)

l0532:  ld      c,b
        pop     af
        ex      de,hl
        ret     

        rst     $30,CALLUDF
        defb	$0a;

        ex      de,hl
        ld      a,c
        pop     bc
        pop     de

l053c:  inc     hl			; skip past current handled character.
        ld      (de),a			; copy current character to program ram.
        inc     de			; increment program ram counter.
        inc     c			; inc C
        sub     $3a			; check if current character is ':'
        jr      z,$0548                 ; if it is jump to $0548
        cp      $49			; 
        jr      nz,$054b                ;  (3)

l0548:  ld      ($38ac),a

l054b:  sub     $54
        jp      nz,$04c5
        ld      b,a

l0551:  ld      a,(hl)
        or      a
        jr      z,$055e                 ;  (9)
        cp      b
        jr      z,$053c                 ;  (-28)

l0558:  inc     hl
        ld      (de),a
        inc     c
        inc     de
        jr      $0551                   ;  (-13)

l055e:  ld      hl,$385f
        ld      (de),a
        inc     de
        ld      (de),a
        inc     de
        ld      (de),a
        ret     

; Entry point for LLIST command.
ST_LLIST:
l0567:  ld      a,$01			; set channel to PRINTER
        ld      (CHANNEL),a		; the fall through LIST command.

;Entry point for LIST command.
ST_LIST:
l056c:	ld      a,$17			; $17 is the number of lines to print
					; before pausing for a keypress.
        ld      (ROWCOUNT),a		; set ROWCOUNT to $17
        call    STR2VAL,$069c		; convert parameter following LIST 
					; to a 16 value in DE
        ret     nz			;

        pop     bc
        call    FINDLIN,$049f		; Find address of required line in RAM
        push    bc

l057a:  pop     hl			; Restore address.
        ld      c,(hl)			; Get next two bytes
        inc     hl			; into BC
        ld      b,(hl)			;
        inc     hl			;
        ld      a,b			; check B and C for $00
        or      c			;
        jp      z,OKMAIN,$0402		; if BC is $0000 jump to OKMAIN,$0402
					; which prints OK and enters immediate mode,
					; otherwise carry on.
        call    CHKKEYP,$1a25		; read key buffer check for CTRL+C or CTRL+S
					; and handle as appropraite.
        push    bc			; Save line number
        call    PRNCRLF,$19ea		; Print CRLF
        ld      e,(hl)			; get LINE NUMBER into DE
        inc     hl
        ld      d,(hl)
        inc     hl
        push    hl			; HL now points to the first character after the line number.
        ex      de,hl			; DE now is address of statement after line number and
						; HL now is the line number.
        call    $1675			; Print LINE NUMBER
        ld      a,$20
        pop     hl

l0597:  rst     $18			; print character in A

;
; Print the character at (HL) or 
; expand and print if it is a keyword.
;
PEXPAND:
l0598:  ld      a,(hl)		; retrieve character to be printed
        inc     hl		; and point to next location.
        or      a		; set flags.
        jr      z,$057a         ; if it is $00 jump back to $057a
        jp      p,$0597		; Check if byte is 'positive' ie less than $7f
				; to test to see if it is a keyword pointer.
				; if if it is not a keyword, print
				; the character and loop to handle the
				; next character.
        rst     $30,CALLUDF	; call userdefined function if set.
	defb	$16
				
				; if it IS a keyword pointer, fall through to here.	
l05a2:	sub	$7F		; Remove marker bit from keyword token.
        ld      c,a		; and save to C to use as a counter.
        ld      de,$0245 	; Point to start of keyword table

l05a8:  ld      a,(de)		; Enter the loop to scan for 1st byte of keyword
        inc     de		; preload address of next character.
        or      a		; set flags
        jp      p,$05a8		; if bit 7 not set, loop back. When we encounter
				; a byte with bit 7 set, we know we are at the next
				; keyword in the table, or then end marker.
        dec     c		; Decrement Key Word counter.
        jr      nz,$05a8        ; Keep looping till we get the correct keyword.

				; when we get this far we know we are pointing at the
				; first character of the required keyword.
l05b1:  and     $7f		; remove marker bit from character,
        rst     $18 		; print current character of keyword.
        ld      a,(de)		; get next byte of keyword
        inc     de		; preload address of next character.
        or      a		; Set flags
        jp      p,$05b1		; loop to print next charater, or
				; if byte is NEG then we are done.

        jr      $0598           ; Done expanding the keyword, continue printing data.

; Entry point for FOR command.
ST_FOR:
l05bc:	ld      a,$64
        ld      ($38cb),a
        call    $0731
        pop     bc
        push    hl
        call    $071c
        ld      ($38c7),hl
        ld      hl,$0002
        add     hl,sp

l05d0:  call    $03a3
        jr      nz,$05e9                ;  (20)
        add     hl,bc
        push    de
        dec     hl
        ld      d,(hl)
        dec     hl
        ld      e,(hl)
        inc     hl
        inc     hl
        push    hl
        ld      hl,($38c7)
        rst     $20		; COMPARE HL,DE
        pop     hl
        pop     de
        jr      nz,$05d0                ;  (-22)
        pop     de
        ld      sp,hl
        inc     c

l05e9:  pop     de
        ex      de,hl
        ld      c,$08
        call    $0ba0,CHK_STKSPC        ;check stack space
        push    hl
        ld      hl,($38c7)
        ex      (sp),hl
        push    hl
        ld      hl,(CURLIN)
        ex      (sp),hl
        call    $0975
        rst     $8,CHKNEXT
        defb $a1

        call    $0972
        push    hl
        call    $152e					; BCDEFP
        pop     hl
        push    bc
        push    de
        ld      bc,$8100
        ld      d,c
        ld      e,d
        ld      a,(hl)
        cp      $a7
        ld      a,$01
        jr      nz,$061f                ;  (10)
        rst     $10,GETNEXT
        call    $0972
        push    hl
        call    $152e					; BCDEFP
        rst     $28				; TSTSGN
        pop     hl

l061f:  push    bc
        push    de
        push    af
        inc     sp
        push    hl
        ld      hl,(TMPSTAT)		; preload address of next statment as
        ex      (sp),hl			; return address on stack.

l0628:  ld      b,$81
        push    bc
        inc     sp

l062c:  ld      (TMPSTAT),hl		; save address of next statment
        call    $1fc2
        ld      a,(hl)
        cp      $3a			; Check for the ":" character.
        jr      z,$064b                 ; If found jump to $064b.
        or      a			; otherwise, set flags
        jp      nz,ERROR_SN,$03c4	; and report a syntax error if we 
					; are not at the end of the line.

        inc     hl			; Retrieve next two characters.
        ld      a,(hl)			; 
        inc     hl			; 
        or      (hl)			; And check if they are both $00
        jp      z,$0c29			; if so jump to $0c29 
        inc     hl
        ld      e,(hl)
        inc     hl
        ld      d,(hl)
        ex      de,hl
        ld      (CURLIN),hl
        ex      de,hl
;
; Execute each statement in turn by jumping here.
; This routine will look up the address of the statment
; by multiplying converting the command byte into
; an offset into the jump table.
; The it pushes the address held in that location in the
; jump table to the stack as a return address.
; It then checks the next character before calling the function.
; If there are more parameters the CF will be set.
NEXTSTMT:
l064b:  rst     $10,GETNEXT		; get next character.
        ld      de,$062c		; push return address to stack 
        push    de			;

l0650:  ret     z			; Return if nothing to do.

l0651:  sub     $80			; subtract $80 from command byte
					; to form a command index into the jump table.
        jp      c,$0731			; if command byte < $80 then jump to $0731
        cp      $20			; is it a space?
        rst     $30,CALLUDF		; Call UDF
        defb	%17    			;

        jp      nc,ERROR_SN,$03c4	; If the command byte is not valid after 
					; all the above checks we exit via a SN error.

        rlca    			; multiply index by 2 as each entry in the jump
					; table is 16 bits.
        ld      c,a			; and add the resultant offset to the
        ld      b,$00			; address of the start of the jump table.
        ex      de,hl			; save HL for later.
        ld      hl,$01d5		; Preload JUMP TABLE start address,
        add     hl,bc			; add the offset.
        ld      c,(hl)			; and move low byte to C
        inc     hl			;       
        ld      b,(hl)			; and high byte to B	
        push    bc			; and push it to the stack as the return address.
        ex      de,hl			; restore character pointer to HL
;
; Get next character from the string
;
NEXTCHR:
l066b:  inc     hl
        ld      a,(hl)
        cp      $3a			; Is it (':') ?
        ret     nc			; If it is ":" then there is no more data
					; so RET effectively calling the routine
					; whose address was pushed to the stack.
					; if not ":" then remove skip whitespace
					; and then call the routine with CF set
					; to signal that there is data following the 
					; command.
;
; On entry to this routine, A holds an ASCII code.
; Also called from RST10 GETNEXT, to fetch the next character in the string.
;
l0670:  cp      $20			; is it a SPACE
        jr      z,$066b                 ; if so, jump to 066b, NEXTCHR:,
					; to skip whitespace.

        cp      $30			; is it between '0' and '9'
        ccf     			; compliment carry flag
        inc     a			; 
        dec     a			; set other flags.
        ret     			; 

l067a:  rst     $10,GETNEXT 		

l067b:  call    $0972			;

l067e:  rst     $28				; TSTSGN
        jp      m,ERROR_FC,$0697	; Jump if negative

l0682:  ld      a,($38e7)		;
        cp      $90			; 
        jp      c,$1586			; if it's less than $90 jump ~~~ 		; FPINT
        ld      bc,$9080		; 
        ld      de,$0000		;
        push    hl			; 
        call    $155b			; CMPNUM
        pop     hl			;
        ld      d,c			;
        ret     z			;

ERROR_FC:
l0697:  ld      e,$08		 	; 08 is the offset of FC in the error table.
        jp      ERROR,$03db		; report an FC error.
;
; STR2VAL converts the string pointed to by HL
; into a decimal equivalent stored in DE 
; for example, if the string pointed to by HL is
; "2345" then DE would become 2345(dec) = $0929
; interestingly the maximum number that can be held is
; 65529(dec).
;
; This routine works by first multiplying DE by 10
; then adding VAL(A) and looping again until all the
; characters have been read.
;
STR2VAL:
l069c:  dec     hl

l069d:  ld      de,$0000		; we start with 00

l06a0:  rst     $10,GETNEXT		; get next character
        ret     nc			; return if it is not between '0' and '9'
					; fall through if it is.
        push    hl
        push    af
        ld      hl,$1998		; compare with 6552 before starting.
        rst     $20			; COMPARE HL,DE
        jr      c,$06bb                 ; if DE is greater,
					; jump to 06bb to restore registers
					; and flags and return.

        ld      h,d			; These 6 lines multiply DE by ten and
        ld      l,e			; store the result in HL.
        add     hl,de			; HL now equals 2 x DE
        add     hl,hl			; HL now equal2 4 x DE
        add     hl,de			; HL now equals 5 x DE
        add     hl,hl			; HL now equals 10 x DE

        pop     af			; retsore AF
        sub     $30			; convert ASCII to byte. ie '1' = $01
        ld      e,a			; move to DE
        ld      d,$00			; DE now equals VAL(A) where '0' <= a <= '9'
        add     hl,de			; hl = (10 x DE)+VAL(A)
        ex      de,hl			; put HL back into DE
        pop     hl			; restore HL
        jr      $06a0                   ; and do it again!

l06bb:  pop     af
        pop     hl
        ret     

;
; Entry point for RUN command.
;
ST_RUN:
l06be:  rst     $30,CALLUDF
 	defb	$18
	jp	z,$0bcb
        call    $0bcf
        ld      bc,$062c
        jr      $06db                   ; 

; Entry point for GOSUB routine.
ST_GOSUB:
l06cb:  ld      c,$03
        call    $0ba0,CHK_STKSPC        ;check stack space
        pop     bc
        push    hl
        push    hl
        ld      hl,(CURLIN)
        ex      (sp),hl			; save CURLIN to stack for the return address.
        ld      a,$8c			; command byte for GOSUB
        push    af			; push onto stack.
        inc     sp			; 
	
l06db:  push    bc			; restore previous stack top
					; and fall through to GOTO
;
; Entry point for GOTO command.
;
ST_GOTO:
l06dc:  call    STR2VAL,$069c		; convert the line number, held as text
					; to a 16 bit value in DE.
        call    FIND_BC,$071e		; Find BC in memory (swaps B and C first
					; to allow for LSB first order of the Z80)
        inc     hl			; move HL to point to next statment.
        push    hl			; and save address for later.
        ld      hl,(CURLIN)		; retrieve CURRENT line number temporarily
        rst     $20,CMPHLDE		; Compare current line number 
					; with the line number after GOTO statement.

        pop     hl			; retrieve next statment address.
				
					; If GOTO line number is > current line number
					; we will search FORWARD through ram to
        call    c,FINDLIN2,$04A2	; locate the line number held in DE 
					; and make HL point to it.
        call    nc,FINDLIN,$049f	; otherwise we will search from start of program ram
				; to find the correct line number.
				; On return BC points to the line number in ram.
        ld      h,b		; Move new LINE NUMBER address to HL
        ld      l,c		; 
        dec     hl		; allow for auto INC
        ret     c		; return to jump to that line.

UL_ERROR:			; Otherwise fall through to report a UL Error.
l06f3:  ld      e,$0e		; Offset for 'UL' error. (Undefined line)
        jp      ERROR,$03db

;Entry point for RETURN
ST_RETURN:
l06f8:	ret     nz		; if nothing follow the RETURN statement then
				; a simple return will cause the interpreter to 
				; report a SN error.

        ld      d,$ff		;
        call    $039f
        ld      sp,hl
        cp      $8c	
        ld      e,$04			; report a 'Return with Gosub' error
        jp      nz,ERROR,$03db		; if A <> $8C
        pop     hl
        ld      (CURLIN),hl
        inc     hl
        ld      a,h
        or      l
        jr      nz,$0716                ;  (7)
        ld      a,($38cc)
        or      a
        jp      nz,OKMAIN2,$0401	; Print OK and return to immediate mode.

l0716:  ld      hl,$062c
        ex      (sp),hl
        ld      a,$e1

*************************
*** OVERLAPPING CODE HERE               
*** Either the disassembly corupted the byte at 071c
*** or there is a genuine bug in the ROM
*************************
*** Existing code was:

l071c:	ld	bc,0e3a			; NOTE: This is a hang-over from old code
	nop				; as BC get overwritten in the next instructions
					; what happens is that a DATA statement
					; is treated exactly like a REM statement.

; FIND BC
; (Also used as entry point for REM command.)
; Will search through memory until it has found a byte the same as C
; and a byte the same a B somewhere after it.
FIND_BC:
ST_REM:
l071e:	ld	c,$00			; initialise B and C to $0000
l0720:  ld      b,$00

SWAP_BC:
l0722:  ld      a,c			; Swap B and C
        ld      c,b			; so, for example if BC was $0405
        ld      b,a			; it would now be $0504

l0725:  ld      a,(hl)			; overwrite A with (HL)
        or      a			; set flag
        ret     z			; return if A=00

        cp      b			; compare A with B
        ret     z			; return if both the same.
        inc     hl			; increment HL
        cp      $22			; If we found B we now llok for C
        jr      z,$0722                 ; so jump to SWAP_BC to swap BC round.
        jr      $0725                   ; then continue.
;
; entry point for LET statement.
;
ST_LET:
l0731:  call    $10d1
        rst	$8
        defb	$b0			; ensure an = sign follws variable name.

        push    de
        ld      a,($38ab)
        push    af
        call    $0985
        pop     af
        ex      (sp),hl
        ld      (TMPSTAT),hl		; save address of next statment
        rra     
        call    $0977
        jp      z,$0779

l074a:  push    hl
        ld      hl,($38e4)
        push    hl
        inc     hl
        inc     hl
        ld      e,(hl)
        inc     hl
        ld      d,(hl)
        ld      hl,(BASTART)	; retrieve address of first line of BASIC
        rst     $20		; COMPARE HL,DE
        jr      nc,$0768                ;  (14)
        ld      hl,($38da)
        rst     $20		; COMPARE HL,DE
        pop     de
        jr      nc,$0770                ;  (15)
        ld      hl,$38bd
        rst     $20		; COMPARE HL,DE
        jr      nc,$0770                ;  (9)
        ld      a,$d1
        call    $0fe4
        ex      de,hl
        call    $0e39

l0770:  call    $0fe4
        pop     hl
        call    $153d
        pop     hl
        ret     

l0779:  push    hl
        call    $153a
        pop     de
        pop     hl
        ret     

; Entry point for ON command
ST_ON:
L0780:	rst     $30,CALLUDF
	defb	$19

        call    $0b54
        ld      a,(hl)
        ld      b,a
        cp      $8c
        jr      z,$078e                 ;  (3)
        rst     $8,CHKNEXT			; compare (HL) with $88
        defb	$88

        dec     hl
l078e:  ld      c,e

l078f:  dec     c
        ld      a,b
        jp      z,$0651
        call    $069d
        cp      $2c
        ret     nz
        jr      $078f                   ;  (-13)

;Entry point for IF statement.
ST_IF:
l079c:  call    $0985
        ld      a,(hl)			;
        cp      $88			; is next command 'Goto' 
        jr      z,$07a7                 ; then jump forward.
        rst     $8,CHKNEXT		; compare (HL) with $A5 (The defb)
	defb	$a5			; make sure next command is 'THEN'?

        dec     hl

l07a7:  call    $0975
        rst     $28				; TSTSGN
        jp      z,FIND_BC,$071e		; find BC in memory.
        rst     $10,GETNEXT
        jp      c,$06dc
        jp      $0650

;Entry point for LPRINT command.
ST_LPRINT:
l07b5:	ld      a,$01			; set channel to 01-Printer
        ld      (CHANNEL),a

l07ba:  dec     hl
        rst     $10,GETNEXT 			;GETNEXT

;Entry point for PRINT command.
ST_PRINT:
l07bc:	rst     $30,CALLUDF			; call the UDF
	defb	%06

	call	z,PRNCRLF,$19ea			; If there are no parameters
						; following the Print statement 
PRT_CONT:					; then print CRLF
l07c1:	jp	z,PRINT_END,$0866		; and we done printing.

						; The character immediately following
						; the print statement is in A 
						; at this point.
	cp	$a0				; is it 160?
	jp	z,$083a				; if so jump to $083a

	cp	$a3				; is it 163 (# Keyword)
	jp	z,$083a				; if so jump to $083a

	push	hl
	cp	$2c				; is it ','
        jr      z,$0817                 	; if so jump to $0817, PRTCOMMA

        cp      $3b				; Is it ';'
        jp      z,$0861				; if so jump to $0861

        pop     bc				; restore character pointer to BC
        call    $0985
        push    hl
        ld      a,($38ab)
        or      a
        jp      nz,$0811
        call    $1680
        call    $0e5f
        ld      (hl),$20
        ld      hl,($38e4)
        ld      a,(CHANNEL)
        or      a
        jr      z,$07fd                 ;  (8)
        ld      a,(PRNCOL,$3846)	; get current printer column.
        add     a,(hl)			; add (HL)
        cp      $84			; is it 132?
        jr      $080a                   ; 

l07fd:  ld      a,($3848)
        ld      b,a
        inc     a
        jr      z,$080d                 ;  (9)
        ld      a,(CURCOL)		; see note about cursor position.
        add     a,(hl)
        dec     a
        cp      b

l080a:  call    nc,PRNCRLF,$19ea	; Reset print head to start of next line.

l080d:  call    $0ea0
        xor     a

l0811:  call    nz,$0ea0
        pop     hl
        jr      $07ba                   ;  (-93)

; Print a , operator to current stream.
PRTCOMMA:
l0817:  ld      a,(CHANNEL)
        or      a
        jr      z,$0825                 ; 
        ld      a,(PRNCOL,$3846)	; get current printer column
        cp      $70			; compare with 112 to set CF?
        jp      $082d			; jump forward to 082d

l0825:  ld      a,($3849)
        ld      b,a
        ld      a,(CURCOL)
        cp      b

l082d:  call    nc,PRNCRLF,$19ea
        jp      nc,$0861

l0833:  sub     $0e
        jr      nc,$0833                ;  (-4)
        cpl     
        jr      $085a                   ;  (32)

l083a:  push    af
        call    $0b53
        rst     $8,CHKNEXT
	defb	$29			; check for a ')' and stop via syntax error
					; if it is missing.
        dec     hl
        pop     af
        sub     $a3
        push    hl
        jr      z,$0856                 ;  (15)
        ld      a,(CHANNEL)
        or      a
        jp      z,$0853			; 
        ld      a,(PRNCOL,$3846)	; get current printhead column.
        jr      $0856                   ; 

l0853:  ld      a,(CURCOL)

l0856:  cpl     
        add     a,e
        jr      nc,$0861                ;  (7)

l085a:  inc     a
        ld      b,a
        ld      a,$20			; load A with SPACE

l085e:  rst     $18			; print B spaces.
        djnz    $085e                   ; loop till B = 00

l0861:  pop     hl			; restore character pointer.
        rst     $10,GETNEXT		; retrieve next character
        jp      PRT_CONT,$07c1		; and continue printing.

PRINT_END:
l0866:	rst     $30,CALLUDF
	defb	$07

        xor     a
        ld      (CHANNEL),a
        ret     

L086D:  defb	'?Redo from start',0d,0a,00

l0880:  rst     $30,CALLUDF
	defb	$08

        ld      a,($38cd)
        or      a
        jp      nz,$03be
        pop     bc
        ld      hl,$086d     	; '?Redo from start' +CR + LF
        call    0e9d,PRINTSTR
        jp      $0c01

;
; ST_INPUT: entry point for INPUT statement
;
ST_INPUT:
l0893:  rst     $30,CALLUDF
	defb	$1a

        call    $0b45
        ld      a,(hl)
        cp      $22
        ld      a,$00
        jp      nz,$08aa
        call    $0e60
        rst     $8,CHKNEXT
        dec     sp
        push    hl
        call    $0ea0
        ld      a,$e5
        call    $0d5b
        pop     bc
        jp      c,$0c26
        inc     hl
        ld      a,(hl)
        or      a
        dec     hl
        push    bc
        jp      z,$071b
        ld      (hl),$2c
        jr      $08c3                   ;  (5)

;Entry point for READ command.
ST_READ:
l08be:  push    hl
        ld      hl,(RESTORE)		; Address of line last RESTORE'd or
					; first line of BASIC if no data ever READ
					; or RESTORE'd
        or      $af
        ld      ($38cd),a
        ex      (sp),hl
        ld      bc,$2ccf
        call    $10d1
        ex      (sp),hl
        push    de
        ld      a,(hl)
        cp      $2c
        jr      z,$08f0                 ;  (27)
        ld      a,($38cd)
        or      a
        jp      nz,$0953
        ld      a,$3f
        rst     $18			; print character in A
        call    $0d5b
        pop     de
        pop     bc
        jp      c,$0c26
        inc     hl
        ld      a,(hl)
        dec     hl
        or      a
        push    bc

l08ec:  jp      z,$071b
        push    de

l08f0:  rst     $30,CALLUDF
	defb	$1c

        ld      a,($38ab)
        or      a
        jr      z,$0917                 ;  (31)
        rst     $10,GETNEXT
        ld      d,a
        ld      b,a
        cp      $22
        jr      z,$090b                 ;  (12)
        ld      a,($38cd)
        or      a
        ld      d,a
        jr      z,$0908                 ;  (2)
        ld      d,$3a			; ':'

l0908:  ld      b,$2c			; ','
        dec     hl

l090b:  call    $0e63
        ex      de,hl
        ld      hl,$0920
        ex      (sp),hl
        push    de
        jp      $074a

l0917:  rst     $10,GETNEXT
        call    $15e5				; ASCTFP
        ex      (sp),hl
        call    $153a
        pop     hl
        dec     hl
        rst     $10,GETNEXT
        jr      z,$0929                 ;  (5)
        cp      $2c
        jp      nz,$0880

l0929:  ex      (sp),hl
        dec     hl
        rst     $10,GETNEXT
        jp      nz,$08c9
        pop     de
        ld      a,($38cd)
        or      a
        ex      de,hl
        jp      nz,$0c1a
        push    de
        or      (hl)
        ld      hl,$0942		; '?Extra ignored' +CR+LF
        call    nz,PRINTSTR
        pop     hl
        ret     

l0942:	defb 	'?Extra Ignored',0d,0a,00
        
l0953:  call    $071c			; 
        or      a
        jr      nz,$096a                ;  (17)
        inc     hl
        ld      a,(hl)
        inc     hl
        or      (hl)
        ld      e,$06			; Offset for 'Out of data' error
        jp      z,ERROR,$03db		; report 'OD Error'
        inc     hl
        ld      e,(hl)
        inc     hl
        ld      d,(hl)
        ld      ($38c9),de

l096a:  rst     $10,GETNEXT
        cp      $83
        jr      nz,$0953                ;  (-28)
        jp      $08f0

l0972:  call    $0985

l0975:  or      $37		; or A with $37

l0977:  ld      a,($38ab)
        adc     a,a
        or      a
        ret     pe
        jp      $03d9
        rst     $8,CHKNEXT
        or      b
        ld      bc,$28cf

l0985:  dec     hl			; HL now points to the character immediately
					; after 'PRINT'
        ld      d,$00

l0988:  push    de
        ld      c,$01
        call    $0ba0,CHK_STKSPC        ;check stack space
        call    $09fd
        ld      ($38d0),hl

l0994:  ld      hl,($38d0)
        pop     bc
        ld      a,b
        cp      $78			;
        call    nc,$0975		;
        ld      a,(hl)
        ld      ($38c3),hl
        cp      $a8			;
        ret     c

        cp      $b2			;
        ret     nc			;

        cp      $af
        jp      nc,$09e2

        sub     $a8
        ld      e,a
        jr      nz,$09ba                ;  (8)
        ld      a,($38ab)
        dec     a
        ld      a,e
        jp      z,$0f7c

l09ba:  rlca    
        add     a,e
        ld      e,a
        ld      hl,$034c
        ld      d,$00
        add     hl,de
        ld      a,b
        ld      d,(hl)
        cp      d
        ret     nc
        inc     hl
        call    $0975

l09cb:  push    bc
        ld      bc,$0994
        push    bc
        ld      b,e
        ld      c,d
        call    $1513		; STAKFP
        ld      e,b
        ld      d,c
        ld      c,(hl)
        inc     hl
        ld      b,(hl)
        inc     hl
        push    bc
        ld      hl,($38c3)
        jp      $0988

l09e2:  ld      d,$00

l09e4:  sub     $af
        jp      c,$0ad0
        cp      $03
        jp      nc,$0ad0
        cp      $01
        rla     
        xor     d
        cp      d
        ld      d,a
        jp      c,ERROR_SN,$03c4
        ld      ($38c3),hl
        rst     $10,GETNEXT
        jr      $09e4                   ;  (-25)

l09fd:  rst     $30,CALLUDF
	defb	$09

        xor     a
        ld      ($38ab),a
        rst     $10,GETNEXT	; get next character (at HL+1)
        jp      z,$03d6		; if character is 00, jump back
        jp      c,$15e5		; if character is 0-9jump forward to ASCTFP
        call    IsAtoZ,$0cc6
        jp      nc,$0a4e
        cp      $a8
        jr      z,$09fd                 ;  (-23)
        cp      $2e
        jp      z,$15e5					; ASCTFP
        cp      $a9
        jp      z,$0a3d
        cp      $22
        jp      z,$0e60
        cp      $a6
        jp      z,$0b05
        cp      $a4
        jp      z,$19fb
        cp      $a2
        jp      z,$0b40
        sub     $b2
        jp      nc,$0a5f

l0a37:  call    $0983
        rst     $8,CHKNEXT
        add     hl,hl
        ret     

l0a3d:  ld      d,$7d
        call    $0988
        ld      hl,($38d0)
        push    hl
        call    $150b
        call    $0975
        pop     hl
        ret     

l0a4e:  call    $10d1
        push    hl
        ex      de,hl
        ld      ($38e4),hl
        ld      a,($38ab)
        or      a
        call    z,$1520		; PHLTFP
        pop     hl
        ret     

l0a5f:  rst     $30,CALLUDF
	defb	$1b
        cp      $18			; CTRL+X or 24
        jp      z,$1a68
        ld      b,$00
        rlca    
        ld      c,a
        push    bc
        rst     $10,GETNEXT
        ld      a,c
        cp      $29
        jr      c,$0a87                 ;  (22)
        call    $0983
        rst     $8,CHKNEXT
        inc     l
        call    $0976
        ex      de,hl
        ld      hl,($38e4)
        ex      (sp),hl
        push    hl
        ex      de,hl
        call    $0b54
        ex      de,hl
        ex      (sp),hl
        jr      $0a8f                   ;  (8)

l0a87:  call    $0a37
        ex      (sp),hl
        ld      de,$0a49
        push    de

l0a8f:  ld      bc,$0215
        add     hl,bc
        ld      c,(hl)
        inc     hl
        ld      h,(hl)
        ld      l,c
        jp      (hl)

l0a98:  dec     d
        cp      $a9
        ret     z
        cp      $2d
        ret     z
        inc     d
        cp      $2b
        ret     z
        cp      $a8
        ret     z
        dec     hl
        ret     
        or      $af
        push    af
        call    $0975
        call    $0682
        pop     af
        ex      de,hl
        pop     bc
        ex      (sp),hl
        ex      de,hl
        call    $1523		; FPBCDE
        push    af
        call    $0682
        pop     af
        pop     bc
        ld      a,c
        ld      hl,$0b21
        jp      nz,$0acb
        and     e
        ld      c,a
        ld      a,b
        and     d
        jp      (hl)

l0acb:  or      e
        ld      c,a
        ld      a,b
        or      d
        jp      (hl)

l0ad0:  ld      hl,$0ae2
        ld      a,($38ab)
        rra     
        ld      a,d
        rla     
        ld      e,a
        ld      d,$64
        ld      a,b
        cp      d
        ret     nc
        jp      $09cb
        call    po,$790a
        or      a
        rra     
        pop     bc
        pop     de
        push    af
        call    $0977
        ld      hl,$0afb
        push    hl
        jp      z,$155b			; CMPNUM
        xor     a
        ld      ($38ab),a
        jp      $0dfc
        inc     a
        adc     a,a
        pop     bc
        and     b
        add     a,$ff
        sbc     a,a
        jp      $14f6			; FLGREL

l0b05:  ld      d,$5a
        call    $0988
        call    $0975
        call    $0682
        ld      a,e
        cpl     
        ld      c,a
        ld      a,d
        cpl     
        call    $0b21
        pop     bc
        jp      $0994

l0b1c:  ld      a,l
        sub     e
        ld      c,a
        ld      a,h
        sbc     a,d

l0b21:  ld      b,c

l0b22:  ld      d,b			; move B to D

l0b23:  ld      e,$00			; make E = $00
        ld      hl,$38ab
        ld      (hl),e
        ld      b,$90
        jp      $14fb

; Entry point for LPOS function
ST_LPOS:
l0b2e:  ld      a,(PRNCOL,$3846)	; Retrieve current PRINT HEAD column
        jr      $0b36

; Entry point for POS function
ST_POS:
l0B33:	ld      a,(CURCOL)		; retrieve current SCREEN CURSOR column.

l0b36:  ld      b,a			; save position to B
        xor     a			; clear out A
        jp      $0b22			; jump to $0b22

;ST_DEF entry point for DEF statement.
ST_DEF:
l0b3b:  rst     $30,CALLUDF
	defb	$0f

        jp      ERROR_SN,$03c4

l0b40:  rst     $30,CALLUDF
	defb	$10
	jp	ERROR_SN,$03c4

	push	hl
        ld      hl,(CURLIN)
        inc     hl
        ld      a,h
        or      l
        pop     hl
        ret     nz
        ld      e,$16
        jp      ERROR,$03db

l0b53:  rst     $10,GETNEXT

l0b54:  call    $0972

l0b57:  call    $067e
        ld      a,d
        or      a				; set flags.
        jp      nz,ERROR_FC,$0697		; report an FC error if D <> 0
        dec     hl
        rst     $10,GETNEXT
        ld      a,e
        ret     

; Entry point for PEEK function
ST_PEEK	call    $0682				; get value into DE
        call    CKSYSAD,$0b88			; check that DE is above system rom/ram
						; otherwise report an FC error.
        ld      a,(de)				; the actual PEEK happening.
        jp      $0b36

;ST_POKE entry point for POKE command.
ST_POKE:
l0b6d:  call    $0972
        call    $0682
        call    CKSYSAD,$0b88			; check that DE is above system rom/ram
						; otherwise report an FC error.
        push    de
        rst     $8,CHKNEXT
	defb	$2c				; ensure a "," follows, otherwise report
						; a SN Error.

        call    $0b54
        pop     de
        ld      (de),a				; the actual POKE happening.
        ret     

l0b7f:  call    $0985
        push    hl
        call    $0682
        pop     hl
        ret     
;
; Check DE is above system ROM/RAM
; The user is not allowed to PEEK/POKE into system ram/rom.
; CKSYSAD
CKSYSAD:
l0b88:  push    hl			; save HL
        ld      hl,$2fff		; HL=start of user ram. (incl screen ram)
        rst     $20			; COMPARE HL,DE		; COMPARE HL,DE
        pop     hl			; restore HL
        jp      nc,ERROR_FC,$0697	; DE is less than 2fff we report an FC error.
	ret     			; otherwise we return.

l0b92:  call    $0ba9

l0b95:  push    bc
        ex      (sp),hl
        pop     bc

l0b98:  rst     $20		; COMPARE HL,DE
        ld      a,(hl)
        ld      (bc),a
        ret     z
        dec     bc
        dec     hl
        jr      $0b98                   ;  (-8)

CHK_STKSPC
l0ba0,CHK_STKSPC        ;check stack space:  push    hl			; save HL for later.
        ld      hl,($38da)		;
        ld      b,$00			;
        add     hl,bc
        add     hl,bc
        ld      a,$e5
        ld      a,$d0
        sub     l
        ld      l,a
        ld      a,$ff
        sbc     a,h
        ld      h,a
        jr      c,OM_ERROR,$0bb7         ;  (3)
        add     hl,sp
        pop     hl
        ret     c
;
; OM_ERROR: Reports an OUT of memory error and falls out to Immediate mode.
;
OM_ERROR:
l0bb7:  ld      de,$000c		; Load E with the code for an OM error
	jp      ERROR,$03db		; and report OUT OF MEMORY!

; Entry point for NEW command.
ST_NEW:
l0bbd:	ret     nz			; if there are parameters after NEW we return
					; and this will cause a SYNTAX error
					; when the interpreter reaches the addittional
					; parameters.

ST_NEW2:
l0bbe:  rst     $30,CALLUDF		; call the UDF, if installed, with parameter $0b
	defb	$0b     

        ld      hl,(BASTART)		; retrieve address of first line of BASIC
        xor     a			; clear A
        ld      (hl),a			; save $0000 to (BASTART)
        inc     hl			;
        ld      (hl),a			; 
        inc     hl			;
        ld      (BASEND),hl		; save $0000 to (BASEND)

l0bcb:  ld      hl,(BASTART)
        dec     hl

l0bcf:  ld      (TMPSTAT),hl		; Set address of next statment
        ld      hl,(RAMTOP)
        ld      ($38c1),hl
        xor     a
        call    ST_RESTORE,$0c05	; issue a RESTORE statement to clear
					; the RESTORE pointer.
        ld      hl,(BASEND)
        ld      ($38d8),hl
        ld      ($38da),hl

CLRWKSP:
l0be5:  pop     bc			; Retrieve current return address.
        ld      hl,($384b)		; Retrieve alternative return address.
        ld      sp,hl			; preload the previous return address. In effect
					; this ensures that this routine will return to where
					; it was called from, but the previous routine
					; will return to ($384b). 

        call    $1fd8			; Store address of the instruction which 
					; caused the error and preload HL with $38b1

        ld      ($38af),hl		; move $38b1 to ($38af)
        call    PRNHOME,$19be		; if we were printing to printer, LPRINT a CR and LF

        xor     a			; Reset some system variables.
        ld      l,a			;
        ld      h,a			;
        ld      (CONTPOS),hl		; The CONTinue position is set to $0000
        ld      ($38cb),a		;
        ld      ($38de),hl		;
        push    hl			;
        push    bc			;

l0c01:  ld      hl,(TMPSTAT)		; and return to carry on at next statement.
        ret     			;

;
; Entry point for RESTORE statement.
;
ST_RESTORE
l0c05:  ex      de,hl			; save HL for later.
        ld      hl,(BASTART)		; retrieve address of first line of basic.
        jr      z,$0c19                 ; if no parameters follow RESTORE jump to $0c19
        ex      de,hl			; swap NEXTCHAR and BASTART
        call    STR2VAL,$069c		; convert figure after RESTORE statement
					; to a value in BC
        push    hl			; save HL for later.
        call    FINDLIN,$049f		; locate required line in ram.
        ld      h,b			; and save its address to HL
        ld      l,c
        pop     de			; restore original NEXTCHAR to HL
        jp      nc,UL_ERROR,$06f3	; report a UL error if line not found.

l0c19:  dec     hl			; 
	
l0c1a:  ld      (RESTORE),hl		; save address of RESTORE'd line to RESTORE
        ex      de,hl
        ret     

;Entry point for STOP statement
ST_STOP:
l0c1f:  ret     nz			; if there is anything after the stop
					; statement we simply return causing
					; a SN error to be reported.

l0c20:  or      $c0			;

;
; Enter at ST_END for an END statement.
;
ST_END:
l0c21:  ld      (TMPSTAT),hl
        ld      hl,$fff6
        pop     bc

l0c29:  ld      hl,(CURLIN)
        push    af			; save AF
        ld      a,l			; restore Current line number to A
        and     h			;
        inc     a			; check if it is $FFFF ie. Immediate mode.
        jr      z,STATEND,$0c3b         ; if so jump to STATEND.
					
        ld      ($38d2),hl		; Otherwise save current line number.
        ld      hl,(TMPSTAT)		; and current statment address.
        ld      (CONTPOS),hl		; Save the address of the command we STOPped at.
;
; A clean end to statement execution.
; Print either "Ok" or 'Break' and OK depending on how
; we got here.
;
STATEND:
l0c3b:  call    PRNHOME,$19be		; if we were printing to printer, 
					; LPRINT a CR and LF.
        call    RSTCOL,$19de          	; reset cursor to start of next line,
					; if not already at start of line.
        pop     af
        ld      hl,$0373		; Point to 'Break'
        jp      nz,$03f4		; if not in IMMODE then report the line 
					; number in the break message.
        jp      OKMAIN,$0402		; Otherwise just print 'Ok' and 
					; enter immediate mode.

; Entry point for CONT statement
ST_CONT:
l0c4b:	ld      hl,(CONTPOS)		; Retrieve position of the command 
					; we STOPed at.
        ld      a,h			; and check if it is valid
        or      l			; If it is 0000 we report a 
					; Cant Continue Error.
        ld      de,$0020		; Offset for 'CN' error code.
        jp      z,ERROR,$03db		; report the 'Cant continue' error.

        ld      de,($38d2)		; 
        ld      (CURLIN),de
        ret     

        jp      ERROR_FC,$0697		; report an FC error.

l0c62:  ld      a,$af

; Entry point for CLOAD* statement.
ST_CLOAD*
l0c63:	xor	a			; clear A
        or      a			; set flags.
        push    af			; save AF.
        rst     $10,GETNEXT		; 
        ld      a,$01			;
        ld      ($38cb),a
        call    $10d1			;
        jp      nz,ERROR_FC,$0697	; report an FC Error
        ld      ($38cb),a
        call    $0975
        pop     af
        push    hl
        push    af
        push    bc
        ld      b,$23			;  
        jr      z,$0c92                 ; 
        call    RECMSG,$1b7f		; display 'Press <RECORD>' etc
					; and wait for the RTN key to be pressed.
        call    SAVESYNC,$1bbc		; Save sync signal to tape.

        ld      a,b			; move byte in B into A
        call    TAPEBYTE2,$1b87		; save byte in A to tape TWICE
        call    TAPEBYTE2,$1b87		; save byte in A to tape TWICE
        call    TAPEBYTE2,$1b87		; save byte in A to tape TWICE
        jr      $0ca3                   ; 

l0c92:  call    TAPELD1,$1b2e	        ; display the 'Press <PLAY>' message 
					; and wait for CR
        call    BYTEREAD,$1bce		; read SYNC signal from tape.

l0c98:  ld      c,$06

l0c9a:  call    BYTEREAD2,$1b4d
        cp      b
        jr      nz,$0c98                ;  (-8)
        dec     c
        jr      nz,$0c9a                ;  (-9)

l0ca3:  pop     hl
        ex      de,hl
        add     hl,de
        ex      de,hl
        ld      c,(hl)
        ld      b,$00
        add     hl,bc
        add     hl,bc
        inc     hl

l0cad:  rst     $20		; COMPARE HL,DE
        jr      z,$0cbd         ;  (13)
        pop     af
        push    af
        ld      a,(hl)
        call    nz,TAPEBYTE,$1b8a
        call    z,BYTEREAD2,$1b4d
        ld      (hl),a
        inc     hl
        jr      $0cad                   ;  (-16)

l0cbd:  pop     af
        jp      nz,$1c1c
        pop     hl
        jp      $1b7e

; Retrieve current character pointed to by HL...
RIsAtoZ
l0cc5:  ld      a,(hl)			; retrieve current character.

; ...and check if it is between A and Z
IsAtoZ:
l0cc6:  cp      $41			; compare current character with 'A'
        ret     c			; Return with CF set if LESS than 'A'
        cp      $5b			; Compare with '[' which is one more than 'Z'
        ccf     			; clear carry flag
        ret     			; and return

; Entry point for CLEAR command.
ST_CLEAR
l0ccd:	rst     $30,CALLUDF
	defb	$0b

        jp      z,$0bcf
        call    $067b
        dec     hl
        rst     $10,GETNEXT

        push    hl
        ld      hl,(RAMTOP)
        jr      z,$0ceb                 ;  (14)
        pop     hl
        rst     $8,CHKNEXT
	defb	$2c			; check for a ',' and stop via
					; syntax error if it is missing.

        push    de
        call    $067b
        dec     hl
        rst     $10,GETNEXT
        jp      nz,ERROR_SN,$03c4
        ex      (sp),hl
        ex      de,hl

l0ceb:  ld      a,l
        sub     e
        ld      e,a
        ld      a,h
        sbc     a,d
        ld      d,a
        jp      c,OM_ERROR,$0bb7
        push    hl
        ld      hl,(BASEND)
        ld      bc,$0028		
        add     hl,bc
        rst     $20			; COMPARE HL,DE
        jp      nc,OM_ERROR,$0bb7	; report OUT OF MEMORY if
        ex      de,hl
        ld      ($384b),hl
        pop     hl
        ld      (RAMTOP),hl
        pop     hl
        jp      $0bcf
        ld      a,l
        sub     e
        ld      e,a
        ld      a,h
        sbc     a,d
        ld      d,a
        ret     

; Entry point for the 'NEXT' statement.
ST_NEXT
l0d13:	ld      de,$0000

l0d16:  call    nz,$10d1
        ld      (TMPSTAT),hl
        call    $039f
        jp      nz,$03ca
        ld      sp,hl
        push    de
        ld      a,(hl)
        push    af
        inc     hl
        push    de
        call    $1520		; PHLTFP
        ex      (sp),hl
        push    hl
        call    $1253
        pop     hl
        call    $153a
        pop     hl
        call    $1531		; LOADFP
        push    hl
        call    $155b			; CMPNUM
        pop     hl
        pop     bc
        sub     b
        call    $1531		; LOADFP
        jr      z,$0d4d                 ;  (9)
        ex      de,hl
        ld      (CURLIN),hl
        ld      l,c
        ld      h,b
        jp      $0628


l0d4d:  ld      sp,hl
        ld      hl,(TMPSTAT)
        ld      a,(hl)
        cp      $2c
        jp      nz,$062c
        rst     $10,GETNEXT
        call    $0d16

l0d5b:  ld      a,$3f			; The '?' character
        rst     $18			; print character in A
        ld      a,$20			; The SPACE character
        rst     $18			; print character in A
        jp      GETLINE,$0d85

; Jump here if a keyword was pressed during immediate mode
;
l0d64:  ld      a,($384a)
        or      a
        ld      a,$5c			; 
        ld      ($384a),a		;
        jr      nz,$0d74                ;  (5)
        dec     b
        jr      z,GETLINE,$0d85         ; Reset line buffer and start collecting a new line.
        rst     $18			; Print character in A
        inc     b

l0d74:  dec     b
        dec     hl
        jr      z,$0d81                 ;  (9)
        ld      a,(hl)
        rst     $18			; print character in A
        jr      $0d8e                   ;  (18)

l0d7c:  dec     b
        dec     hl
        rst     $18			; print character in A
        jr      nz,$0d8e                ;  (13)

l0d81:  rst     $18			; print character in A

l0d82:  call    PRNCRLF,$19ea

;
; GETLINE
; Reset the INPUT LINE BUFFER and start collecting a line.
;
GETLINE:
l0d85:  ld      hl,LINEBUF		; Start of LINE INPUT BUFFER
        ld      b,$01			; initialise line length counter to 1
        xor     a			; clear A
        ld      ($384a),a		; set ($384a) to $00

l0d8e:  call    CLRKEYWT,$19da		; clear keyboard buffer and wait for a keypress.
					; on return A = key pressed.
        ld      c,a			; save key for later
        cp      $7f			; was key pressed $7F?
        jr      z,$0d64                 ; if so, jump to $0d64
					; otherwise carry on.
        ld      a,($384a)		; 
        or      a
        jr      z,$0da3                 ; is A $00? Then jump to 0da3.
        ld      a,$5c			; Otherwise load A with '\' character
        rst     $18			; print character in A
        xor     a
        ld      ($384a),a

l0da3:  ld      a,c			; restore character to A
        cp      $07			; Is it a BEEP chr?
        jr      z,$0de9                 ; if so jump to $0de9
        cp      $03			; is it CTRL+C
        call    z,PRNCRLF,$19ea		; if so reset cursor to start of next line,
        scf     			; set the carry flag
        ret     z			; and return.
					; Otherwise, we carry on through.
        cp      $0d			; is it CR
        jp      z,LIENDONE,$19e5			; if so jump to LIENDONE,$19e5
        cp      $15			; is it CTRL+U key? (Abandon line)
        jp      z,$0d82			; if so, handle it.
        nop     			; Some other key press used to be trapped
        nop     			; here, but was deleted before manufacture.
        nop     			;
        nop     			;
        nop     			;
        cp      $08			; is it BACKSPACE
        jp      z,$0d7c			; if so, handle it.
        cp      $18			; is it CTRL+X?
					; which is DELINE, which aborts the entering of the
					; line an prints a # character instead.
        jr      nz,$0dcc                ; if NOT CTRL+X, jump to 0dcc
        ld      a,$23			; otherwise print '#'
        jp      $0d81			; and carry on reading from keyboard.

l0dcc:  cp      $12			; is it $12
        jr      nz,$0de4                ;  (20)
        push    bc
        push    de
        push    hl
        ld      (hl),$00
        call    PRNCRLF,$19ea
        ld      hl,LINEBUF
        call    0e9d,PRINTSTR		; print the string pointed to by HL
        pop     hl
        pop     de
        pop     bc
        jp      $0d8e			;

l0de4:  cp      $20			; is it less than SPACE
        jp      c,$0d8e			; if so carry on reading characters.

l0de9:  ld      a,b			; move line length into A
        cp      $49			; have we already goy 73 characters?
        ld      a,$07			; if so jump forward to sound a beep and ignore 
        jp      nc,$0df8		; the keypress.
        ld      a,c			; otherwise, restore keypress to A
        ld      (hl),c			; store it at HL
        ld      ($38cc),a		; and at $38cc
        inc     hl			; increment HL
        inc     b			; increment line length counter

l0df8:  rst     $18			; print character in A
        jp      $0d8e			; and get next character.

l0dfc:  push    de
        call    $0fc9
        ld      a,(hl)
        inc     hl
        inc     hl
        ld      c,(hl)
        inc     hl
        ld      b,(hl)
        pop     de
        push    bc
        push    af
        call    $0fcd
        call    $1531		; LOADFP
        pop     af
        ld      d,a
        pop     hl

l0e12:  ld      a,e
        or      d
        ret     z
        ld      a,d
        sub     $01
        ret     c
        xor     a
        cp      e
        inc     a
        ret     nc
        dec     d
        dec     e
        ld      a,(bc)
        inc     bc
        cp      (hl)
        inc     hl
        jr      z,$0e12                 ;  (-19)
        ccf     
        jp      $14f1

;Entry point for STR$ function
ST_STR$:
l0e29:  call    $0975			; TSTNUM          ; Make sure it's a number
        call    $1680			; NUMASC          ; Turn number into text
        call    $0e5f			; CRTST           ; Create string entry for it
        call    $0fc9			; GSTRCU          ; Current string to pool
        ld      bc,$101d		; preload return address
        push    bc

l0e39:  ld      a,(hl)
l0e3a:	inc     hl
        inc     hl
        push    hl
        call    $0eb3
        pop     hl
        ld      c,(hl)
        inc     hl
        ld      b,(hl)
        call    $0e53
        push    hl
        ld      l,a
        call    $0fbd
        pop     de
        ret     

l0e4e:  ld      a,$01

l0e50:  call    $0eb3

l0e53:  ld      hl,$38bd
        push    hl
        ld      (hl),a
        inc     hl
        inc     hl
        ld      (hl),e
        inc     hl
        ld      (hl),d
        pop     hl
        ret     

l0e5f:  dec     hl			; HL points to start of a string expression.
					; but we decrement it before entering the loop
					; because the first instruction in the loop
					; is an INC HL

l0e60:  ld      b,$22			; the " character.
        ld      d,b			; move it to D

l0e63:  push    hl			; Save HL for later
        ld      c,$ff			; This is -1 as the value is INC'd during the loop.

l0e66:  inc     hl			; HL points to start of string constant again.
        ld      a,(hl)			; Lets get current character.
        inc     c			; 
        or      a			; 
        jr      z,$0e72             	; Jump if the character being checked and C are 00
        cp      d			; 
        jr      z,$0e72             	; Jump if the character being checked = d
        cp      b			; 
        jr      nz,$0e66            	; If the character being checked <> b the loop

l0e72:  cp      $22			; Did we get because of the " symbol?
        call    z,$066b			; if so call $06bb
        ex      (sp),hl			;
        inc     hl			;
        ex      de,hl			;
        ld      a,c			;
        call    $0e53			;

l0e7e:  ld      de,$38bd
        ld      hl,($38af)
        ld      ($38e4),hl
        ld      a,$01
        ld      ($38ab),a
        call    $153d
        rst     $20		; COMPARE HL,DE
        ld      ($38af),hl
        pop     hl
        ld      a,(hl)
        ret     nz
        ld      de,$001e
        jp      ERROR,$03db
        inc     hl
;
; PRINTSTR:
; Prints the zero terminated string expression pointed to by HL.
l0e9d:  call    $0e5f

l0ea0:  call    $0fc9
        call    $1531		; LOADFP
        inc     e

l0ea7:  dec     e
        ret     z
        ld      a,(bc)
        rst     $18			; print character in A
        cp      $0d
        call    z,$19f0
        inc     bc
        jr      $0ea7                   ;  (-12)

l0eb3:  or      a
        ld      c,$f1
        push    af
        ld      hl,($384b)
        ex      de,hl
        ld      hl,($38c1)
        cpl     
        ld      c,a
        ld      b,$ff
        add     hl,bc
        inc     hl
        rst     $20		; COMPARE HL,DE
        jr      c,$0ece                 ;  (7)
        ld      ($38c1),hl
        inc     hl
        ex      de,hl
        pop     af
        ret     

l0ece:  pop     af
        ld      de,$001a		; Offset for 'OS' (Over size) error code.
        jp      z,ERROR,$03db		; report an 'OS Error'
        cp      a
        push    af
        ld      bc,$0eb5
        push    bc

l0edb:  ld      hl,(RAMTOP)

l0ede:  ld      ($38c1),hl
        ld      hl,$0000
        push    hl
        ld      hl,($38da)
        push    hl
        ld      hl,$38b1
        ld      de,($38af)
        rst     $20		; COMPARE HL,DE
        ld      bc,$0eec
        jp      nz,$0f32
        ld      hl,(BASEND)

l0efa:  ld      de,($38d8)
        rst     $20		; COMPARE HL,DE
        jr      z,$0f0b                 ;  (10)
        inc     hl
        ld      a,(hl)
        inc     hl
        or      a
        call    $0f35
        jr      $0efa                   ;  (-16)

l0f0a:  pop     bc

l0f0b:  ld      de,($38da)
        rst     $20		; COMPARE HL,DE
        jp      z,$0f57
        call    $1531		; LOADFP
        ld      a,d
        push    hl
        add     hl,bc
        or      a
        jp      p,$0f0a
        ld      ($38c5),hl
        pop     hl
        ld      c,(hl)
        ld      b,$00
        add     hl,bc
        add     hl,bc
        inc     hl
        ex      de,hl
        ld      hl,($38c5)
        ex      de,hl
        rst     $20		; COMPARE HL,DE
        jr      z,$0f0b                 ;  (-36)
        ld      bc,$0f27

l0f32:  push    bc
        or      $80

l0f35:  ld      a,(hl)
        inc     hl
        inc     hl
        ld      e,(hl)
        inc     hl
        ld      d,(hl)
        inc     hl
        ret     p
        or      a
        ret     z
        ld      b,h
        ld      c,l
        ld      hl,($38c1)
        rst     $20		; COMPARE HL,DE
        ld      h,b
        ld      l,c
        ret     c
        pop     hl
        ex      (sp),hl
        rst     $20		; COMPARE HL,DE
        ex      (sp),hl
        push    hl
        ld      h,b
        ld      l,c
        ret     nc
        pop     bc
        pop     af
        pop     af
        push    hl
        push    de
        push    bc
        ret     

l0f57:  pop     de
        pop     hl
        ld      a,h
        or      l
        ret     z
        dec     hl
        ld      b,(hl)
        dec     hl
        ld      c,(hl)
        push    hl
        dec     hl
        dec     hl
        ld      l,(hl)
        ld      h,$00
        add     hl,bc
        ld      d,b
        ld      e,c
        dec     hl
        ld      b,h
        ld      c,l
        ld      hl,($38c1)
        call    $0b95
        pop     hl
        ld      (hl),c
        inc     hl
        ld      (hl),b
        ld      h,b
        ld      l,c
        dec     hl
        jp      $0ede

l0f7c:  push    bc
        push    hl
        ld      hl,($38e4)
        ex      (sp),hl
        call    $09fd
        ex      (sp),hl
        call    $0976
        ld      a,(hl)
        push    hl
        ld      hl,($38e4)
        push    hl
        add     a,(hl)
        ld      de,$001c		; offset for the LS error code.
        jp      c,ERROR,$03db		; if C set, report the LS error.
        call    $0e50
        pop     de
        call    $0fcd
        ex      (sp),hl
        call    $0fcc
        push    hl
        ld      hl,($38bf)
        ex      de,hl
        call    $0fb4
        call    $0fb4
        ld      hl,$0991
        ex      (sp),hl
        push    hl
        jp      $0e7e

l0fb4:  pop     hl
        ex      (sp),hl
        ld      a,(hl)
        inc     hl
        inc     hl
        ld      c,(hl)
        inc     hl
        ld      b,(hl)
        ld      l,a

l0fbd:  inc     l

l0fbe:  dec     l
        ret     z
        ld      a,(bc)
        ld      (de),a
        inc     bc
        inc     de
        jr      $0fbe                   ;  (-8)

GETSTR:
l0fc6:  call    $0976
GSTRCU:
l0fc9:  ld      hl,($38e4)
GSTRHL:
l0fcc:  ex      de,hl
GSTRDE:
l0fcd:  call    $0fe4
        ex      de,hl
        ret     nz
        push    de
        ld      d,b
        ld      e,c
        dec     de
        ld      c,(hl)
        ld      hl,($38c1)
        rst     $20		; COMPARE HL,DE
        jr      nz,$0fe2                ;  (5)
        ld      b,a
        add     hl,bc
        ld      ($38c1),hl

l0fe2:  pop     hl
        ret     

l0fe4:  ld      hl,($38af)
        dec     hl
        ld      b,(hl)
        dec     hl
        ld      c,(hl)
        dec     hl
        dec     hl
        rst     $20		; COMPARE HL,DE
        ret     nz
        ld      ($38af),hl
        ret     

; Entry point for LEN function.
ST_LEN:
l0ff3:  ld      bc,$0b36	; preload return address.
        push    bc

l0ff7:  call    $0fc6
        xor     a
        ld      d,a
        ld      ($38ab),a
        ld      a,(hl)
        or      a
        ret     

; Entry point for ASC function.
ST_ASC
l1002:	ld      bc,$0b36	; preload return address on stack.
        push    bc

l1006:  call    $0ff7
        jp      z,ERROR_FC,$0697
        inc     hl
        inc     hl
        ld      e,(hl)
        inc     hl
        ld      d,(hl)
        ld      a,(de)
        ret     

; Entry point for CHR$ function
ST_CHR$:
l1013:  call    $0e4e
        call    $0b57

l1019:  ld      hl,($38bf)
        ld      (hl),e
        pop     bc
        jp      $0e7e

;Entry point for LEFT$ function
ST_LEFT$:
	call    $10a0
        xor     a

l1025:  ex      (sp),hl
        ld      c,a
        push    hl
        ld      a,(hl)
        cp      b
        jr      c,$102e                 ;  (2)
        ld      a,b
        ld      de,$000e
        push    bc
        call    $0eb3
        pop     bc
        pop     hl
        push    hl
        inc     hl
        inc     hl
        ld      b,(hl)
        inc     hl
        ld      h,(hl)
        ld      l,b
        ld      b,$00
        add     hl,bc
        ld      b,h
        ld      c,l
        call    $0e53
        ld      l,a
        call    $0fbd
        pop     de
        call    $0fcd
        jp      $0e7e

; Entry point for RIGHT$ function
ST_RIGHT$:
l1050:	call    $10a0
        pop     de
        push    de
        ld      a,(de)
        sub     b
        jr      $1025                   ;  (-52)

;Entry point for MID$ function
ST_MID$:
l1059:	ex      de,hl
        ld      a,(hl)
        call    $10a3
        inc     b
        dec     b
        jp      z,ERROR_FC,$0697	; report an FC error if B=0
        push    bc
        ld      e,$ff
        cp      $29			; is A="," ?
        jr      z,$106f                 ; if so continue at $106F
        rst     $8,CHKNEXT
	defb	$2c			; ensure a "," follows, else report
					; a syntax error.

        call    $0b54

l106f:  rst     $8,CHKNEXT		; ensure a ")" follows, else report 
	defb	$29			; a syntax error.

        pop     af
        ex      (sp),hl
        ld      bc,$1027
        push    bc
        dec     a
        cp      (hl)
        ld      b,$00
        ret     nc
        ld      c,a
        ld      a,(hl)
        sub     c
        cp      e
        ld      b,a
        ret     c
        ld      b,e
        ret     

; Entry point for VAL function.
ST_VAL
l1084:	call    $0ff7
        jp      z,$12c3
        ld      e,a
        inc     hl
        inc     hl
        ld      a,(hl)
        inc     hl
        ld      h,(hl)
        ld      l,a
        push    hl
        add     hl,de
        ld      b,(hl)
        ld      (hl),d
        ex      (sp),hl
        push    bc
        dec     hl
        rst     $10,GETNEXT
        call    $15e5				; ASCTFP
        pop     bc
        pop     hl
        ld      (hl),b
        ret     

l10a0:  ex      de,hl
        rst     $8,CHKNEXT
        add     hl,hl

l10a3:  pop     bc
        pop     de
        push    bc
        ld      b,e
        ret     


; Entry point for FRE function.

l10a8:	ld      hl,($38da)
        ex      de,hl
        ld      hl,$0000
        add     hl,sp
        ld      a,($38ab)
        or      a
        jp      z,$0b1c
        call    $0fc9
        call    $0edb
        ld      de,($384b)
        ld      hl,($38c1)
        jp      $0b1c

        dec     hl
        rst     $10,GETNEXT 	; get next character in BASIC line.
        ret     z		; return if nothing more to do.

        rst     $8,CHKNEXT
        defb	$2c		; check that a COMMA follows, otherwise
				; stop via SYNTAX ERROR.

;Entry point for DIM statement
st_dim:
l10cc:	ld      bc,$10c7
        push	bc
	defb	f6			; ****** OVERLAPPING CODE *******

l10d1:  xor 	a			; set A to 00
        ld      ($38aa),a		; save 00 to $38aa
        ld      c,(hl)			; retrieve current character into C

        call    RIsAtoZ,$0cc5		; check if character at (HL) is A to Z
        jp      c,ERROR_SN,$03c4	; if carry flag is set it is less than A
					; so we report a SN Error.

        xor     a			; Clear A
        ld      b,a			; clear B
        ld      ($38ab),a		; set $38ab to $00
        rst     $10,GETNEXT		; get next character.
        jr      c,$10e9                 ; if if it "A" to "Z" jump to 10e9
        call    IsAtoZ,$0cc6		; check if it is less than "A"
        jr      c,$10f2                 ; CF set so it IS less than "A"
					; so jump to $10f2
					;
					; fall through if character is > "9"
l10e9:  ld      b,a			; save character to A

l10ea:  rst     $10,GETNEXT		; get next character
        jr      c,$10ea                 ; loop while it is "A" to "Z"
        call    IsAtoZ,$0cc6		; then check following character
        jr      nc,$10ea                ; Loop back if it is < "Z"

l10f2:  sub     $24			; Now check if it is $
        jr      nz,$10fe                ; If not jump forward to $10fe
        inc     a			; 
        ld      ($38ab),a
        rrca    
        add     a,b
        ld      b,a
        rst     $10,GETNEXT

l10fe:  ld      a,($38cb)
        dec     a
        jp      z,$11a0
        jp      p,$110e
        ld      a,(hl)
        sub     $28			; is it '('
        jp      z,$117a			; if so jump forward to 117a

l110e:  xor     a
        ld      ($38cb),a
        push    hl
        ld      d,b
        ld      e,c
        ld      hl,($38de)
        rst     $20		; COMPARE HL,DE
        ld      de,$38e0
        jp      z,$141a
        ld      hl,($38d8)
        ex      de,hl
        ld      hl,(BASEND)

l1126:  rst     $20		; COMPARE HL,DE
        jp      z,$113d
        ld      a,c
        sub     (hl)
        inc     hl
        jp      nz,$1132
        ld      a,b
        sub     (hl)

l1132:  inc     hl
        jp      z,$116c
        inc     hl
        inc     hl
        inc     hl
        inc     hl
        jp      $1126

l113d:  pop     hl
        ex      (sp),hl
        push    de
        ld      de,$0a51
        rst     $20		; COMPARE HL,DE
        pop     de
        jp      z,$116f
        ex      (sp),hl
        push    hl
        push    bc
        ld      bc,$0006
        ld      hl,($38da)
        push    hl
        add     hl,bc
        pop     bc
        push    hl
        call    $0b92
        pop     hl
        ld      ($38da),hl
        ld      h,b
        ld      l,c
        ld      ($38d8),hl

l1161:  dec     hl
        ld      (hl),$00
        rst     $20		; COMPARE HL,DE
        jr      nz,$1161                ;  (-6)
        pop     de
        ld      (hl),e
        inc     hl
        ld      (hl),d
        inc     hl

l116c:  ex      de,hl
        pop     hl
        ret     

l116f:  ld      ($38e7),a
        ld      hl,$036d
        ld      ($38e4),hl
        pop     hl
        ret     

l117a:  push    hl
        ld      hl,($38aa)
        ex      (sp),hl
        ld      d,a

l1180:  push    de
        push    bc
        call    $067a
        pop     bc
        pop     af
        ex      de,hl
        ex      (sp),hl
        push    hl
        ex      de,hl
        inc     a
        ld      d,a
        ld      a,(hl)
        cp      $2c
        jp      z,$1180
        rst     $8,CHKNEXT
        defb	$29			; ')'

        ld      ($38d0),hl
        pop     hl
        ld      ($38aa),hl
        ld      e,$00
        push    de
        ld      de,$f5e5
        ld      hl,($38d8)
        ld      a,$19
        ld      de,($38da)
        rst     $20		; COMPARE HL,DE
        jr      z,$11d3                 ;  (37)
        ld      a,(hl)
        inc     hl
        cp      c
        jr      nz,$11b5                ;  (2)
        ld      a,(hl)
        cp      b

l11b5:  inc     hl
        ld      e,(hl)
        inc     hl
        ld      d,(hl)
        inc     hl
        jr      nz,$11a6                ;  (-22)
        ld      a,($38aa)
        or      a
        jp      nz,$03cd
        pop     af
        ld      b,h
        ld      c,l
        jp      z,$141a
        sub     (hl)
        jp      z,$122b

;
; Report a BS error
;
ERROR_BS:
l11cd:  ld      de,$0010		; offset for BS
        jp      ERROR,$03db		; report a BS error.

l11d3:  ld      de,$0004
        pop     af
        jp      z,ERROR_FC,$0697	; report a FC error
        ld      (hl),c
        inc     hl
        ld      (hl),b
        inc     hl
        ld      c,a
        call    $0ba0,CHK_STKSPC        ;check stack space
        inc     hl
        inc     hl
        ld      ($38c3),hl
        ld      (hl),c
        inc     hl
        ld      a,($38aa)
        rla     
        ld      a,c

l11ee:  ld      bc,$000b
        jr      nc,$11f5                ;  (2)
        pop     bc
        inc     bc

l11f5:  ld      (hl),c
        push    af
        inc     hl
        ld      (hl),b
        inc     hl
        push    hl
        call    $15ca			; MLDEBC (Mult DE by BC)
        ex      de,hl
        pop     hl
        pop     af
        dec     a
        jr      nz,$11ee                ;  (-22)
        push    af
        ld      b,d
        ld      c,e
        ex      de,hl
        add     hl,de
        jp      c,OM_ERROR,$0bb7
        call    $0ba9
        ld      ($38da),hl

l1212:  dec     hl
        ld      (hl),$00
        rst     $20		; COMPARE HL,DE
        jr      nz,$1212                ;  (-6)
        inc     bc
        ld      d,a
        ld      hl,($38c3)
        ld      e,(hl)
        ex      de,hl
        add     hl,hl
        add     hl,bc
        ex      de,hl
        dec     hl
        dec     hl
        ld      (hl),e
        inc     hl
        ld      (hl),d
        inc     hl
        pop     af
        jr      c,$124c                 ;  (33)

l122b:  ld      b,a
        ld      c,a
        ld      a,(hl)
        inc     hl
        ld      d,$e1
        ld      e,(hl)
        inc     hl
        ld      d,(hl)
        inc     hl
        ex      (sp),hl
        push    af
        rst     $20		; COMPARE HL,DE
        jp      nc,ERROR_BS,$11cd
        push    hl
        call    $15ca			; MLDEBC (Mult DE by BC)
        pop     de
        add     hl,de
        pop     af
        dec     a
        ld      b,h
        ld      c,l
        jr      nz,$1230                ;  (-23)
        add     hl,hl
        add     hl,hl
        pop     bc
        add     hl,bc
        ex      de,hl

l124c:  ld      hl,($38d0)
        ret     

l1250:  ld      hl,$1757

l1253:  call    $1531		; LOADFP
        jr      $1261                   ;  (9)
        call    $1531		; LOADFP
        ld      hl,$d1c1

l125e:  call    $150b		; INVSGN

l1261:  ld      a,b
        or      a
        ret     z
        ld      a,($38e7)	; FPEXP
        or      a
        jp      z,$1523		; FPBCDE
        sub     b
        jr      nc,$127a                ; NOSWAP  (12)
        cpl     
        inc     a
        ex      de,hl
        call    $1513		; STAKFP
        ex      de,hl
        call    $1523		; FPBCDE
        pop     bc
        pop     de

l127a:  cp      $19
        ret     nc
        push    af
        call    $1546			; SIGNS
        ld      h,a
        pop     af
        call    $1330
        ld      a,h
        or      a
        ld      hl,$38e4
        jp      p,$129f
        call    $1310
        jr      nc,$12f1                ;  (94)
        inc     hl
        inc     (hl)
        jp      z,$03d3
        ld      l,$01
        call    $1352
        jr      $12f1                   ;  (82)

l129f:  xor     a
        sub     b
        ld      b,a
        ld      a,(hl)
        sbc     a,e
        ld      e,a
        inc     hl
        ld      a,(hl)
        sbc     a,d
        ld      d,a
        inc     hl
        ld      a,(hl)
        sbc     a,c
        ld      c,a

l12ad:  call    c,$131c

l12b0:  ld      l,b
        ld      h,e
        xor     a

l12b3:  ld      b,a
        ld      a,c
        or      a
        jr      nz,$12df                ;  (39)
        ld      c,d
        ld      d,h
        ld      h,l
        ld      l,a
        ld      a,b
        sub     $08
        cp      $e0
        jr      nz,$12b3                ;  (-16)

l12c3:  xor     a

l12c4:  ld      ($38e7),a
        ret     

l12c8:  ld      a,h
        or      l
        or      d
        jr      nz,$12d7                ;  (10)
        ld      a,c

l12ce:  dec     b
        rla     
        jr      nc,$12ce                ;  (-4)
        inc     b
        rra     
        ld      c,a
        jr      $12e2                   ;  (11)

l12d7:  dec     b
        add     hl,hl
        ld      a,d
        rla     
        ld      d,a
        ld      a,c
        adc     a,a
        ld      c,a

l12df:  jp      p,$12c8

l12e2:  ld      a,b
        ld      e,h
        ld      b,l
        or      a
        jr      z,$12f1                 ;  (9)
        ld      hl,$38e7
        add     a,(hl)
        ld      (hl),a
        jr      nc,$12c3                ;  (-44)
        jr      z,$12c3                 ;  (-46)

l12f1:  ld      a,b

l12f2:  ld      hl,$38e7
        or      a
        call    m,$1303
        ld      b,(hl)
        inc     hl
        ld      a,(hl)
        and     $80
        xor     c
        ld      c,a
        jp      $1523		; FPBCDE

l1303:  inc     e
        ret     nz
        inc     d
        ret     nz
        inc     c
        ret     nz
        ld      c,$80
        inc     (hl)
        ret     nz
        jp      $03d3

l1310:  ld      a,(hl)
        add     a,e
        ld      e,a
        inc     hl
        ld      a,(hl)
        adc     a,d
        ld      d,a
        inc     hl
        ld      a,(hl)
        adc     a,c
        ld      c,a
        ret     

l131c:  ld      hl,$38e8
        ld      a,(hl)
        cpl     
        ld      (hl),a
        xor     a
        ld      l,a
        sub     b
        ld      b,a
        ld      a,l
        sbc     a,e
        ld      e,a
        ld      a,l
        sbc     a,d
        ld      d,a
        ld      a,l
        sbc     a,c
        ld      c,a
        ret     

l1330:  ld      b,$00

l1332:  sub     $08
        jr      c,$133d                 ;  (7)
        ld      b,e
        ld      e,d
        ld      d,c
        ld      c,$00
        jr      $1332                   ;  (-11)

l133d:  add     a,$09
        ld      l,a
        ld      a,d
        or      e
        or      b
        jr      nz,$134e                ;  (9)
        ld      a,c

l1346:  dec     l
        ret     z
        rra     
        ld      c,a
        jr      nc,$1346                ;  (-6)
        jr      $1354                   ;  (6)

l134e:  xor     a
        dec     l
        ret     z
        ld      a,c

l1352:  rra     
        ld      c,a

l1354:  ld      a,d
        rra     
        ld      d,a
        ld      a,e
        rra     
        ld      e,a
        ld      a,b
        rra     
        ld      b,a
        jr      $134e                   ;  (-17)
        nop     
        nop     
        nop     
        add     a,c
        inc     b
        sbc     a,d
        rst     $30,CALLUDF
	defb	$19

        add     a,e
        inc     h
        ld      h,e
        ld      b,e
        add     a,e
        ld      (hl),l
        call    $848d
        xor     c
        ld      a,a
        add     a,e
        add     a,d
        inc     b
        nop     
        nop     
        nop     
        add     a,c
        jp      po,$4db0
        add     a,e
        ld      a,(bc)
        ld      (hl),d
        ld      de,$f483
        inc     b
        dec     (hl)
        ld      a,a

; Entry point for LOG function
ST_LOG:
l1385:  rst     $28				; TSTSGN
        or      a
        jp      pe,ERROR_FC,$0697		; report a FC Error.
        call    $1395
        ld      bc,$8031
        ld      de,$7218
        jr      $13cb                   ;  (54)

l1395:  call    $152e					; BCDEFP
        ld      a,$80
        ld      ($38e7),a
        xor     b
        push    af
        call    $1513		; STAKFP
        ld      hl,$1363
        call    $1846
        pop     bc
        pop     hl
        call    $1513		; STAKFP
        ex      de,hl
        call    $1523		; FPBCDE
        ld      hl,$1374
        call    $1846
        pop     bc
        pop     de
        call    $142f		; DVBCDE
        pop     af
        call    $1513		; STAKFP
        call    $14f6			; FLGREL
        pop     bc
        pop     de
        jp      $1261
        ld      hl,$d1c1

l13cb:  rst     $28				; TSTSGN
        ret     z
        ld      l,$00
        call    $14ac
        ld      a,c
        ld      ($38f6),a
        ex      de,hl
        ld      ($38f7),hl
        ld      bc,$0000
        ld      d,b
        ld      e,b
        ld      hl,$12b0
        push    hl
        ld      hl,$13eb
        push    hl
        push    hl
        ld      hl,$38e4
        ld      a,(hl)
        inc     hl
        or      a
        jr      z,$141c                 ;  (44)
        push    hl
        ld      l,$08

l13f3:  rra     
        ld      h,a
        ld      a,c
        jr      nc,$1403                ;  (11)
        push    hl
        ld      hl,($38f7)
        add     hl,de
        ex      de,hl
        pop     hl
        ld      a,($38f6)
        adc     a,c

l1403:  rra     
        ld      c,a
        ld      a,d
        rra     
        ld      d,a
        ld      a,e
        rra     
        ld      e,a
        ld      a,b
        rra     
        ld      b,a
        and     $10
        jr      z,$1416                 ;  (4)
        ld      a,b
        or      $20
        ld      b,a

l1416:  dec     l
        ld      a,h
        jr      nz,$13f3                ;  (-39)

l141a:  pop     hl
        ret     

l141c:  ld      b,e
        ld      e,d
        ld      d,c
        ld      c,a
        ret     

DIV10:
l1421:  call    $1513		; STAKFP
        ld      bc,$8420
        ld      de,$0000
        call    $1523		; FPBCDE

DIV:
l142d:  pop     bc
        pop     de

DVBCDE:
l142f:  rst     $28				; TSTSGN
        jp      z,$03c7
        ld      l,$ff
        call    $14ac
        inc     (hl)
        jp      z,$03d3
        inc     (hl)
        jp      z,$03d3
        dec     hl
        ld      a,(hl)
        ld      ($3819),a
        dec     hl
        ld      a,(hl)
        ld      ($3815),a
        dec     hl
        ld      a,(hl)
        ld      ($3811),a
        ld      b,c
        ex      de,hl
        xor     a
        ld      c,a
        ld      d,a
        ld      e,a
        ld      ($381c),a

l1458:  push    hl
        push    bc
        ld      a,l
        call    $3810
        sbc     a,$00
        ccf     
        jr      nc,$146a                ;  (7)
        ld      ($381c),a
        pop     af
        pop     af
        scf     
        jp      nc,$e1c1
        ld      a,c
        inc     a
        dec     a
        rra     
        jp      p,$1487
        rla     
        ld      a,($381c)
        rra     
        and     $c0
        push    af
        ld      a,b
        or      h
        or      l
        jr      z,$1482                 ;  (2)
        ld      a,$20

l1482:  pop     hl
        or      h
        jp      $12f2

l1487:  rla     
        ld      a,e
        rla     
        ld      e,a
        ld      a,d
        rla     
        ld      d,a
        ld      a,c
        rla     
        ld      c,a
        add     hl,hl
        ld      a,b
        rla     
        ld      b,a
        ld      a,($381c)
        rla     
        ld      ($381c),a
        ld      a,c
        or      d
        or      e
        jr      nz,$1458                ;  (-73)
        push    hl
        ld      hl,$38e7
        dec     (hl)
        pop     hl
        jr      nz,$1458                ;  (-81)
        jp      $12c3

l14ac:  ld      a,b
        or      a
        jr      z,$14cd                 ;  (29)
        ld      a,l
        ld      hl,$38e7
        xor     (hl)
        add     a,b
        ld      b,a
        rra     
        xor     b
        ld      a,b
        jp      p,$14cc
        add     a,$80
        ld      (hl),a
        jp      z,$141a
        call    $1546			; SIGNS
        ld      (hl),a
        dec     hl
        ret     
        rst     $28				; TSTSGN
        cpl     
        pop     hl

l14cc:  or      a

l14cd:  pop     hl
        jp      p,$12c3
        jp      $03d3

l14d4:  call    $152e					; BCDEFP
        ld      a,b
        or      a
        ret     z
        add     a,$02
        jp      c,$03d3
        ld      b,a
        call    $1261
        ld      hl,$38e7
        inc     (hl)
        ret     nz
        jp      $03d3

;
; RST28 Jumps here if ($38e7) <> $00
;
RST28_2:
l14eb:  ld      a,($38e6)		; Set a to be ($38e6) 		; FPREG+2
        cp      $2f			; compare with $2F
        rla     			; multiply A by 2.

l14f1:  sbc     a,a			; 
        ret     nz			; 
        inc     a			; 
        ret     			; 

; Entry point for SGN function.
ST_SGN:
l14f5:	rst     $28				; TSTSGN

FLGREL:
l14f6:  ld      b,$88
        ld      de,$0000

l14fb:  ld      hl,$38e7		; 
        ld      c,a			;
        ld      (hl),b			;
        ld      b,$00			;
        inc     hl			;
        ld      (hl),$80		;
        rla     			;
        jp      $12ad			;

ST_ABS:
l1509:	rst     $28			; Check the operand  (TSTSGN)
        ret     p			; if it's already POSITIVE simply return.

;
;Toggle bit 7 of ($38e6)		;		; FPREG+2
;
INVSGN:
l150b:  ld      hl,$38e6		; otherwise we INVERT the SIGN bit.		; FPREG+2
        ld      a,(hl)			; dead simple.
        xor     $80			; just XOR the byte with $80 to invert
        ld      (hl),a			; the sign bit.
        ret     			; and return!

STAKFP:
l1513:  ex      de,hl		; STAKFP
        ld      hl,($38e4)
        ex      (sp),hl
        push    hl
        ld      hl,($38e6)		; FPREG+2
        ex      (sp),hl
        push    hl
        ex      de,hl
        ret     

PHLTFP:
l1520:  call    $1531		; LOADFP

FPBCDE:
l1523:  ex      de,hl
        ld      ($38e4),hl
        ld      h,b
        ld      l,c
        ld      ($38e6),hl		; FPREG+2
        ex      de,hl
        ret     

BCDEFP:
l152e:  ld      hl,$38e4

LOADFP:
l1531:  ld      e,(hl)
        inc     hl
        ld      d,(hl)
        inc     hl
        ld      c,(hl)
        inc     hl
        ld      b,(hl)
INCHL:
l1538:  inc     hl
        ret     

FPTHL:
l153a:  ld      de,$38e4

l153d:  ld      b,$04

l153f:  ld      a,(de)
        ld      (hl),a
        inc     de
        inc     hl
        djnz    $153f                   ;  (-6)
        ret     

SIGNS:
l1546:  ld      hl,$38e6		; FPREG+2
        ld      a,(hl)
        rlca    
        scf     
        rra     
        ld      (hl),a
        ccf     
        rra     
        inc     hl
        inc     hl
        ld      (hl),a
        ld      a,c
        rlca    
        scf     
        rra     
        ld      c,a
        rra     
        xor     (hl)
        ret     

CMPNUM:
l155b:  ld      a,b		
        or      a		; check if B=0
        jp      z,$0028		; if B=0 jump to RST028
        ld      hl,$14ef	;
        push    hl		;
        rst     $28				; TSTSGN
        ld      a,c
        ret     z
        ld      hl,$38e6		; FPREG+2
        xor     (hl)
        ld      a,c
        ret     m

        call    $1573			; CMPFP
        rra     
        xor     c
        ret     

CMPFP:
l1573:  inc     hl
        ld      a,b
        cp      (hl)
        ret     nz
        dec     hl
        ld      a,c
        cp      (hl)
        ret     nz

        dec     hl
        ld      a,d
        cp      (hl)
        ret     nz

        dec     hl
        ld      a,e
        sub     (hl)
        ret     nz

        pop     hl
        pop     hl
        ret     

FPINT:
l1586:  ld      b,a
        ld      c,a
        ld      d,a
        ld      e,a
        or      a
        ret     z

        push    hl
        call    $152e					; BCDEFP
        call    $1546			; SIGNS
        xor     (hl)
        ld      h,a
        call    m,$15aa
        ld      a,$98
        sub     b
        call    $1330
        ld      a,h
        rla     
        call    c,$1303
        ld      b,$00
        call    c,$131c
        pop     hl
        ret     

DCBCDE:
l15aa:  dec     de
        ld      a,d
        and     e
        inc     a
        ret     nz
        dec     bc
        ret     

; Entry point for INT function.
INT:
ST_INT
l15b1:  ld      hl,$38e7
        ld      a,(hl)
        cp      $98			;
        ld      a,($38e4)
        ret     nc
        ld      a,(hl)
        call    $1586		; FPINT
        ld      (hl),$98
        ld      a,e
        push    af
        ld      a,c
        rla     
        call    $12ad
        pop     af
        ret     

MLDEBC:
l15ca:  ld      hl,$0000
        ld      a,b
        or      c
        ret     z
        ld      a,$10

l15d2:  add     hl,hl
        jp      c,ERROR_BS,$11cd
        ex      de,hl
        add     hl,hl
        ex      de,hl
        jp      nc,$15e0
        add     hl,bc
        jp      c,ERROR_BS,$11cd

l15e0:  dec     a
        jp      nz,$15d2
        ret     

ASCTFP:
l15e5:  cp      $2d 			; check for the '-' sign
        push    af
        jr      z,$15ef                 ;  if - sign is presnt jump forward, to avoid
					; printing a <space>
        cp      $2b			; same for + sign
        jr      z,$15ef                 ; 
        dec     hl			; HL now points to <SPACE> before constant.

l15ef:  call    $12c3			; clear out the calculator stack?
        ld      b,a			; preload mantissa and exponent with 
					; default values for 0.
        ld      d,a
        ld      e,a
        cpl     
        ld      c,a

l15f7:  rst     $10,GETNEXT
        jp      c,$163f
        cp      $2e			; check for DECIMAL POINT
        jp      z,$161a			; jump to $161a if it is a decimal now.
        cp      $65
        jp      z,$160a
        cp      $45
        jp      nz,$161e

l160a:  rst     $10,GETNEXT
        call    $0a98

l160e:  rst     $10,GETNEXT
        jp      c,$1661
        inc     d
        jp      nz,$161e
        xor     a
        sub     e
        ld      e,a
        inc     c

l161a:  inc     c
        jp      z,$15f7

l161e:  push    hl
        ld      a,e
        sub     b

l1621:  call    p,$1637
        jp      p,$162d
        push    af
        call    $1421
        pop     af
        inc     a

l162d:  jp      nz,$1621
        pop     de
        pop     af
        call    z,$150b
        ex      de,hl
        ret     

l1637:  ret     z

l1638:  push    af
        call    $14d4
        pop     af
        dec     a
        ret     

l163f:  push    de
        ld      d,a
        ld      a,b
        adc     a,c
        ld      b,a
        push    bc
        push    hl
        push    de
        call    $14d4
        pop     af
        sub     $30		; convert ascii to decimal.
        call    $1656
        pop     hl
        pop     bc
        pop     de
        jp      $15f7

l1656:  call    $1513		; STAKFP
        call    $14f6
        pop     bc
        pop     de
        jp      $1261

l1661:  ld      a,e
        rlca    
        rlca    
        add     a,e
        rlca    
        add     a,(hl)
        sub     $30
        ld      e,a
        jp      $160e

;
; PERRIN:
; Prints the word ' in ' as part of an error report.
;
PERRIN:
l166d:  push    hl			; save current BASIC line number
        ld      hl,$0369     		; Point to ' in '
        call    0e9d,PRINTSTR		; print it.
        pop     hl			; retrieve line number

l1675:  ld      de,$0e9c		; Return address.
        push    de
        ex      de,hl
        xor     a
        ld      b,$98			; 
        call    $14fb

l1680:  ld      hl,$38e9
        push    hl
        rst     $28				; TSTSGN
        ld      (hl),$20
        jp      p,$168c
        ld      (hl),$2d

l168c:  inc     hl
        ld      (hl),$30
        jp      z,$1742
        push    hl
        call    m,$150b
        xor     a
        push    af
        call    $1748

l169b:  ld      bc,$9143
        ld      de,$4ff8
        call    $155b			; CMPNUM
        or      a
        jp      po,$16b9
        pop     af
        call    $1638
        push    af
        jp      $169b

l16b0:  call    $1421
        pop     af
        inc     a
        push    af
        call    $1748

l16b9:  call    $1250
        inc     a
        call    $1586		; FPINT
        call    $1523		; FPBCDE
        ld      bc,$0306
        pop     af
        add     a,c
        inc     a
        jp      m,$16d5
        cp      $08
        jp      nc,$16d5
        inc     a
        ld      b,a
        ld      a,$02

l16d5:  dec     a
        dec     a
        pop     hl
        push    af
        ld      de,$175e
        dec     b
        jp      nz,$16e6
        ld      (hl),$2e
        inc     hl
        ld      (hl),$30
        inc     hl

l16e6:  dec     b
        ld      (hl),$2e
        call    z,$1538				; INCHL
        push    bc
        push    hl
        push    de
        call    $152e					; BCDEFP
        pop     hl
        ld      b,$2f

l16f5:  inc     b
        ld      a,e
        sub     (hl)
        ld      e,a
        inc     hl
        ld      a,d
        sbc     a,(hl)
        ld      d,a
        inc     hl
        ld      a,c
        sbc     a,(hl)
        ld      c,a
        dec     hl
        dec     hl
        jp      nc,$16f5
        call    $1310
        inc     hl
        call    $1523		; FPBCDE
        ex      de,hl
        pop     hl
        ld      (hl),b
        inc     hl
        pop     bc
        dec     c
        jp      nz,$16e6
        dec     b
        jp      z,$1726

l171a:  dec     hl
        ld      a,(hl)
        cp      $30
        jp      z,$171a
        cp      $2e
        call    nz,$1538			; INCHL

l1726:  pop     af
        jp      z,$1745
        ld      (hl),$45
        inc     hl
        ld      (hl),$2b
        jp      p,$1736
        ld      (hl),$2d
        cpl     
        inc     a

l1736:  ld      b,$2f

l1738:  inc     b
        sub     $0a
        jp      nc,$1738
        add     a,$3a
        inc     hl
        ld      (hl),b

l1742:  inc     hl
        ld      (hl),a
        inc     hl

l1745:  ld      (hl),c
        pop     hl
        ret     

l1748:  ld      bc,$9474
        ld      de,$23f7
        call    $155b			; CMPNUM
        or      a
        pop     hl
        jp      po,$16b0
        jp      (hl)
        nop     
        nop     
        nop     
        add     a,b
        ld      b,b
        ld      b,d
        rrca    
        and     b
        add     a,(hl)
        ld      bc,$2710
        nop     
        ret     pe
        inc     bc
        nop     
        ld      h,h
        nop     
        nop     
        ld      a,(bc)
        nop     
        nop     
        ld      bc,$0000

l1770:  ld      hl,$150b
        ex      (sp),hl
        jp      (hl)

; Entry point for SQR function
ST_SQR
l1775:	call    $1513		; STAKFP
        ld      hl,$1757
        call    $1520		; PHLTFP
        pop     bc
        pop     de
        rst     $28				; TSTSGN
        ld      a,b
        jp      z,$17cd
        jp      p,$178c
        or      a
        jp      z,$03c7

l178c:  or      a
        jp      z,$12c4
        push    de
        push    bc
        ld      a,c
        or      $7f
        call    $152e					; BCDEFP
        jp      p,$17b5
        push    af
        ld      a,($38e7)
        cp      $99
        jr      c,$17a6                 ;  (3)
        pop     af
        jr      $17b5                   ;  (15)

l17a6:  pop     af
        push    de
        push    bc
        call    $15b1			; INT
        pop     bc
        pop     de
        push    af
        call    $155b			; CMPNUM
        pop     hl
        ld      a,h
        rra     

l17b5:  pop     hl
        ld      ($38e6),hl		; FPREG+2
        pop     hl
        ld      ($38e4),hl
        call    c,$1770
        call    z,$150b
        push    de
        push    bc
        call    $1385			; LOG
        pop     bc
        pop     de
        call    $13cb				; FPMULT

; Entry point for EXP function.
ST_EXP:
l17cd:  ld      bc,$8138
        ld      de,$aa3b
        call    $13cb				; FPMULT
        ld      a,($38e7)
        cp      $88
        jr      nc,$17ff                ;  (34)
        cp      $68
        jr      c,$1811                 ;  (48)
        call    $1513		; STAKFP
        call    $15b1			; INT
        add     a,$81
        pop     bc
        pop     de
        jr      z,$1802                 ;  (21)
        push    af
        call    $125e
        ld      hl,$181a
        call    $1846
        pop     bc
        ld      de,$0000
        ld      c,d
        jp      $13cb

l17ff:  call    $1513		; STAKFP

l1802:  ld      a,($38e6)		; FPREG+2
        or      a
        jp      p,$180e
        pop     af
        pop     af
        jp      $12c3

l180e:  jp      $03d3

l1811:  ld      bc,$8100
        ld      de,$0000
        jp      $1523		; FPBCDE
        rlca    
        ld      a,h
        adc     a,b
        ld      e,c
        ld      (hl),h
        ret     po
        sub     a
        ld      h,$77
        call    nz,$1e1d
        ld      a,d
        ld      e,(hl)
        ld      d,b
        ld      h,e
        ld      a,h
        ld      a,(de)
        cp      $75
        ld      a,(hl)
        jr      $18a3                   ;  (114)
        ld      sp,$0080
        nop     
        nop     
        add     a,c

l1837:  call    $1513		; STAKFP
        ld      de,$13c9
        push    de
        push    hl
        call    $152e					; BCDEFP
        call    $13cb
        pop     hl

l1846:  call    $1513		; STAKFP
        ld      a,(hl)
        inc     hl
        call    $1520		; PHLTFP
        ld      b,$f1
        pop     bc
        pop     de
        dec     a
        ret     z
        push    de
        push    bc
        push    af
        push    hl
        call    $13cb
        pop     hl
        call    $1531		; LOADFP
        push    hl
        call    $1261
        pop     hl
        jr      $184f                   ;  (-23)

; Entry point for RND function
ST_RND
l1866:	rst     $28				; TSTSGN
        ld      hl,$3820       ; SEED+2, Random number seed
        jp      m,$18c4		; RESEED (if negative)
        ld      hl,$3841	; LSTRND - Last random number
        call    $1520		; PHLTFP - Move last RND to FPREG
        ld      hl,$3820	; SEED+2, Random number seed
        ret     z
        add     a,(hl)
        and     $07
        ld      b,$00
        ld      (hl),a
        inc     hl
        add     a,a
        add     a,a
        ld      c,a
        add     hl,bc
        call    $1531		; LOADFP
        call    $13cb
        ld      a,($381f)
        inc     a
        and     $03
        ld      b,$00
        cp      $01
        adc     a,b
        ld      ($381f),a
        ld      hl,$18c7
        add     a,a
        add     a,a
        ld      c,a
        add     hl,bc
        call    $1253

l18a0:  call    $152e					; BCDEFP

l18a3:  ld      a,e
        ld      e,c
        xor     $4f
        ld      c,a
        ld      (hl),$80
        dec     hl
        ld      b,(hl)
        ld      (hl),$80
        ld      hl,$381e
        inc     (hl)
        ld      a,(hl)
        sub     $ab
        jr      nz,$18bb                ;  (4)
        ld      (hl),a
        inc     c
        dec     d
        inc     e

l18bb:  call    $12b0
        ld      hl,$3841
        jp      $153a

l18c4:  ld      (hl),a
        dec     hl
        ld      (hl),a
        dec     hl
        ld      (hl),a
        jr      $18a0                   ;  (-43)
        ld      l,b
        or      c
        ld      b,(hl)
        ld      l,b
        sbc     a,c
        jp      (hl)
        sub     d
        ld      l,c
        djnz    $18a6                   ;  (-47)
        ld      (hl),l
        ld      l,b

; Entry point for COS function.
ST_COS:
l18d7:  ld      hl,$1953
        call    $1253

;Entry point for SIN function
ST_SIN
l18dd:  ld      a,($38e7)
        cp      $77
        ret     c
        ld      a,($38e6)		; FPREG+2
        or      a
        jp      p,$18f3
        and     $7f
        ld      ($38e6),a		; FPREG+2
        ld      de,$150b
        push    de

l18f3:  ld      bc,$7e22
        ld      de,$f983
        call    $13cb
        call    $1513		; STAKFP
        call    $15b1			; INT
        pop     bc
        pop     de
        call    $125e
        ld      bc,$7f00
        ld      de,$0000
        call    $155b			; CMPNUM
        jp      m,$1935
        ld      bc,$7f80
        ld      de,$0000
        call    $1261
        ld      bc,$8080
        ld      de,$0000
        call    $1261
        rst     $28				; TSTSGN
        call    p,$150b
        ld      bc,$7f00
        ld      de,$0000
        call    $1261
        call    $150b

l1935:  ld      a,($38e6)		; FPREG+2
        or      a
        push    af
        jp      p,$1942
        xor     $80
        ld      ($38e6),a		; FPREG+2

l1942:  ld      hl,$195b
        call    $1837
        pop     af
        ret     p

l194a:  ld      a,($38e6)		; FPREG+2
        xor     $80
        ld      ($38e6),a		; FPREG+2
        ret     

l1953:  in      a,($0f)
        ld      c,c
        add     a,c
        nop     
        nop     
        nop     
        ld      a,a
        dec     b
        ei      
        rst     $10,GETNEXT
        ld      e,$86
        ld      h,l
        ld      h,$99
        add     a,a
        ld      e,b
        inc     (hl)
        inc     hl
        add     a,a
        pop     hl
        ld      e,l
        and     l
        add     a,(hl)
        in      a,($0f)
        ld      c,c
        add     a,e

; Entry point for TAN function
ST_TAN
l1970:  call    $1513		; STAKFP
        call    $18dd
        pop     bc
        pop     hl
        call    $1513		; STAKFP
        ex      de,hl
        call    $1523		; FPBCDE
        call    $18d7
        jp      $142d		; DIV

; Entry point for ATN function
ST_ATN:
l1985:  rst     $30,CALLUDF		; This is interesting!
	defb    $0e			; If you use ATN at all you get
	jmp	ERROR_SN,$03c4		; a Syntax Error. The developers
					; obviously had to sacrifise this command
					; for space or time reasons.

PRNTCHR:
l198a:	rst	$30			; call UDF
        defb    0d

        push    af			; save character to be printed
        ld      a,(CHANNEL)		;
        or      a				; 
        jp      z,$19d6			; If channel is SCREEN jump forward 

        pop     af
        push    af
        cp      $09			; Is it a TAB chr?
        jr      nz,PRTCHR2              ; jump if it is not.

l199a:  ld      a,$20			; it's a TAB chr so we print spaces 
					; till we are in correct column
        rst     $18			; print character in A

        ld      a,(PRNCOL,$3846)
        and     $07				; correct column yet?
        jr      nz,$199a                	; loop if not.
        pop     af				; all done
        ret     

PRTCHR2:
l19a6:  pop     af			; restore character being printed to A
        push    af			; and save again for later.
        sub     $0d			; compare with $0d
        jr      z,$19b7                 ; Are we printing CR? If so jump
					; forward to $19b7 to reset PRNCOL to 0 and
					; print the character.
        jr      c,$19ba                 ; or is it a character < $0d then go print it.
        ld      a,(PRNCOL,$3846)	; else, check current print head column
        inc     a			; if its = 132 we rest the printhead to column 0
					; before printing.
        cp      $84			; 132 is maximum columns.
        call    z,PRNRESET,$19c7	; reset print head to start
					; of next line.
					; then fall through to print the character.

l19b7:  ld      (PRNCOL,$3846),a

l19ba:  pop     af

l19bb:  jp      $1ae8,LPRINTA		; send character in A to printer.

;
; Return print head home and feed a line.
;
PRNHOME:
l19be:  xor     a
        ld      (CHANNEL),a
        ld      a,(PRNCOL,$3846)	; get current print head column.
        or      a			; Set flags
        ret     z			; return if already home.
;
; PRNRESET
; Reset the printer to home position.
;
PRNRESET:
l19c7:  ld      a,$0d
        call    $19bb			; lprint CR
        ld      a,$0a
        call    $19bb			; lprint LF
        xor     a
        ld      (PRNCOL,$3846),a
        ret     

l19d6:  pop     af
        jp      PRNCHR1,$1d72

;
; CLRKEYWT
; Clear the keyboard buffer and wait for anykey.
; return with the key pressed in A
;
CLRKEYWT:
l19da:  call    CLRKEYWT22,$1a2f
        ret     
;
; RSTCOL
; Reset the cursor to start of next line, if not already there.
;
RSTCOL:
l19de:  ld      a,(CURCOL)		; check current cursor column
        or      a			; if it is 0
        ret     z			; simply return.
        jr      PRNCRLF,$19ea          	; else print CRLF

;
; jump here when RTN is pressed during immediate mode.
LINEDONE:
l19e5:  ld      (hl),$00		; put end of line marker in place
        ld      hl,$385f		; And point to one less than LINBUF, the line buffer.
					; then fall through

;
; Print a CRLF
;
PRNCRLF:
l19ea:  ld      a,$0d	          	; print CR
        rst     $18			; print character in A
        ld      a,$0a		        ; print LF
        rst     $18			; print character in A

l19f0:  ld      a,(CHANNEL)		;
        or      a		        ;
        jr      z,$19fa                 ;
        xor     a		        ;
        ld      (PRNCOL,$3846),a	;

l19fa:  ret     

l19fb:  rst     $10,GETNEXT
        push    hl
        call    $1a18
        jr      z,$1a0b                 ;  (9)
        push    af
        call    $0e4e
        pop     af
        ld      e,a
        call    $1019

l1a0b:  ld      hl,$036d
        ld      ($38e4),hl
        ld      a,$01
        ld      ($38ab),a
        pop     hl
        ret     

l1a18:  push    hl
        ld      hl,LSTASCI,$380a
        ld      a,(hl)
        ld      (hl),$00
        or      a
        call    z,$1a39
        pop     hl
        ret     
;
; Check key with pause.
; If no key has been pressed, return.
; If CTRL+C was pressed, handle it.
; If CTRL+S was pressed pause until another key is pressed.
CHKKEYP:
l1a25:  call    $1a39
        ret     z
        ld      (LSTASCI,$380a),a
        cp      $13			; check for CTRL+S
					; if CTRL+S was pressed, 
					; pause until another key is pressed.
        ret     nz
;
; Clear the last key value and wait for user to press a key.
;
CLRKEYWT2:
l1a2f:  xor     a			; put 00 into (LSTASCI,$380a)
        ld      (LSTASCI,$380a),a		;

;
; Wait for a KEYPRESS and return with it in A
;
KEYWAIT:	
l1a33:  call    $1a39			; Keep calling $1a39 until A <> 0
        jr      z,KEYWAIT,$1a33                 ; 
        ret     

l1a39:  call    UKEYCHK,$1e7e		; Get last key pressed.
        cp      $03			; Was it CTRL+C
        jr      nz,ENDKEYWT,$1a4a       ; if NOT return with key in A.

;
; Jump here if a CTRL+C was pressed while waiting for input.
; KEYBREAK:
l1a40:  ld      a,($385e)		; 
        or      a			;
        call    z,$0bbe			;
        jp      $1fce

ENDKEYWT:
l1a4a:  or      a			; clear flags
        ret     			; return

;Entry point for PRESET command.
ST_PRESET:
l1a4c:	xor     a		; signal that we are doing a PRESET
        jr      $1a51                   ;  (2)

; Entry point for PSET command.
ST_PSET:
l1a4f:  ld      a,$01		; Signal that we are doing a PSET

l1a51:  ex      af,af'
        call    $1a7f		; get two values stored in BASIC as (x,y) into
				; BC and DE
        call    $1a8e		; check X and Y co-ords are within range.
				; otherwise crash with FC error.
        jr      z,$1a5c         ;  (2)
        ld      (hl),$a0

l1a5c:  ex      af,af'
        or      a
        ld      a,(de)
        jr      nz,$1a64                ;  (3)
        cpl     
        and     (hl)
        ld      b,$b6
        ld      (hl),a
        pop     hl
        ret     

l1a68:  rst     $10,GETNEXT
        call    $1a7f		; get two values stored in BASIC as (x,y) into 
				; BC and DE
        call    $1a8e		; check X and Y coords are in range, otherwise
				; bomb out with FC error.
        jr      nz,$1a77                ;  (6)
        ld      a,(de)
        and     (hl)
        ld      d,$01
        jr      nz,$1a79                ;  (2)

l1a77:  ld      d,$00

l1a79:  xor     a
        call    $0b23
        pop     hl
        ret     
;
; This routine at $1a7f will check that the syntax is like (x,y) then 
; store X to BC and Y to DE.
; As in the statment SOUND (500,1000) or PSET (50,60)
GET2VALS:
l1a7f:  rst     $8,CHKNEXT
	defb	$28			; check that the next byte is '('
					; stop via SN ERROR if it is not.
	call	$1ad0			; get value into DE
	push	de			; and save on stack.
	rst	$8,CHKNEXT		;
	defb	$2c			; check next byte is ','
	call	$1ad0			; get value into DE
	rst	$8,CHKNEXT		;
	defb	$29			; check next byte is ')'
	pop	bc			; restore first value into BC
        ret     

CHK_XY:
l1a8e:  ex      (sp),hl			;
        push    hl
        push    bc
        push    de
        ld      hl,$0047		; maximum value of Y coordinate.
        rst     $20			; COMPARE HL,DE

l1a96:  jp      c,ERROR_FC,$0697	; if y-coord is out of range report 
					; an FC error.
        ld      hl,$004f		; now check X coordinate.
        push    bc
        pop     de
        rst     $20			; if X coord is out of range report
					; an FC error.
        jr      c,$1a96                 ; 

        pop     de			; retsore coordinates from stack.
        pop     bc

        ld      hl,$3028 CHR_HOME	;
        ld      a,e
        ld      de,$0028

l1aaa:  cp      $03
        jr      c,$1ab4                 ;  (6)
        add     hl,de
        dec     a
        dec     a
        dec     a
        jr      $1aaa                   ;  (-10)

l1ab4:  rlca    
        sra     c
        jr      nc,$1aba                ;  (1)
        inc     a

l1aba:  add     hl,bc
        ld      de,$1aca

l1abe:  or      a
        jr      z,$1ac5                 ;  (4)
        inc     de
        dec     a
        jr      $1abe                   ;  (-7)

l1ac5:  ld      a,(hl)
        or      $a0			;
        xor     (hl)
        ret     
        ld      bc,$0402		; 
        ex      af,af'
        djnz    $1b10                   ;  (64)

l1ad0:  call    $0985
        jp      $0682

; Entry point for SOUND command
ST_SOUND
l1ad6:	push    de			; save DE for later.
        call    $1a7f			; get duration into BC and pitch into DE
        push    hl			; save character pointer
        call    PLAYSOUND		; play the sound
        pop     hl			; restore HL and DE and
        pop     de			; done.
        ret     			;
;
; LPCRLF :- Send a CR and LF to the printer port.
;
LPCRLF:
l1ae1:  ld      a,$0d				; preload A with CR
        call    $1ae8,LPRINTA			; output it to printer
        ld      a,$0a				; preload A with LF
						; and fall through to print routine.
;
; Send the character in A to the printer port.
;
LPRINTA:
l1ae8:  rst     $30,CALLUDF		; Call the UDF for character handling.
					; if installed.
	defb	$11			; 

        push	af			; save AF twice since it gets POPed twice
        push	af			; during the routines.
        exx     

; PRINTER HANDLING ROUTINES.
; 
; In the following printer handling routines the time constant
; $b1 is used to make a baud rate of 1200 bps.
; some NOPs are used to get precise time constants.
;
; Also of note is the fact that there is no TIMEOUT value,
; so if the printer is not ready or not connected, and the
; user tries to print the only way to get control back is to
; restart the computer or attach the printer!

LPRINT2:
l1aed:  in      a,($fe)			; Read from printer IO port.
        and     $01			; Wait for PRINTER READY signal.
        jr      z,LRPINT2,$1aed         ; loop until we get it!
        call    $1b08			; output $00 to the port and 
					; wait $b1 loops (time contant 1200 baud)
        ld      e,$08			; prepare to output 8 Bits.
        pop     af			; restore AF

l1af9:  call    $1b0a			; Output bit 0 of a and wait the time constant.
        rrca    			; rotate right to shift the appropriate bit 
					; into BIT 0
        dec     e			; decrement bit counter
        jr      nz,$1af9                ; loop for 8 bits.

        ld      a,$01			; output 1 STOP bit.
        call    $1b0a			;
        exx     			; restore registers
        pop     af			; restore data
        ret     			; return.

l1b08:  ld      a,$00			; preload A with $00

l1b0a:  out     ($fe),a			; output A to the port
        ld      h,$b1			; $b1 is a time constant

l1b0e:  dec     h			; dec H
        jr      nz,$1b0e                ; loop until H = 0
        nop     			; add T-States for precision timing.
        nop     			;
        nop     			;
        ret     			; and return
;
; ST_COPY entry point for COPY command.
; This routine copies the contents of the screen to the printer.
;
ST_COPY:
l1b15:  push    hl			; save HL and DE for later.
        push    de
	call    $1ae1			; Send CRLF to printer.
        ld      hl,$3028,CHR_HOME	; HL points to start of character ram
        ld      de,$33e8,CHR_END	; DE points to end of character ram.
;
; Entering here will copy ram from HL to DE to the printer.
ST_COPY2:
l1b20:  ld      a,(hl)			; retriev character at (HL)
        call    $1ae8,LPRINTA		; print it to the printer.
        inc     hl			; move to next character,
        rst     $20			; COMPARE HL,DE to see if we are at the end.
        jr      c,$1b20                 ; loop to ST_COPY2
        call    $1ae1			; Send CRLF to printer at the end.
        pop     de			; Restore DE,
        pop     hl			; restore DL,
        ret     			; and retrun.

;
; Display tape load message and wait for RTN key.
;	
TAPELD1:
l1b2e:  push    hl
        push    de
        push    bc
        ld      hl,$1be8     		; 'Press <PLAY>'+CR+LF+$00

TAPEMSG:
l1b34:  push    af
        call    0e9d,PRINTSTR		; Display the message
        ld      hl,$00b5		; 'Press RETURN key to start'+$00
        call    0e9d,PRINTSTR	        ; Display the message

l1b3e:  call    UKEYCHK,$1e7e		; Loop until the user presses
        cp      $0d		    	; the RTN key.
        jr      nz,$1b3e                ;
        call    PRNCRLF,$19ea		; Print a CRLF
        pop     af
        pop     bc
        pop     de
        pop     hl
        ret     

;
; BYTEREAD2: Read part of the SYNC signal from tape.
; 
BYTEREAD2:
l1b4d:  exx     			; swap 16 bit register sets
        ld      c,$fc			; FC is the cassette port IO value

RSTARTBIT:				; Wait for a start bit, and
l1b50:  call    $1b62			; calculate in A the time for a 1-0-1 transition.
					; this figure gets ComPared with $49 during the routine.
        jr      c,$1b50                 ; If it was less than $49 loop again.
					
        ld      h,$08			; Get ready to read 8 bits, (each bit =0101 on tape.)

READBYTE:
l1b57:  call    $1b62			; wait for another 0-1-0-1 transition
        rl      l			; multiply L by 2 each time round this loop
        dec     h
        jr      nz,$1b57                ; loop 8 times to read 8 Bits.
        ld      a,l			; save L to A
        exx     			; restore registers
        ret     			; and return.

CALCLAG:
TAPE0WT:
l1b62:  in      a,(c)			; keep reading in from $FC until we get a 0 at bit 1
        rra     
        jr      c,TAPE0WT,$1b62         

TAPE1WT:
l1b67:  in      a,(c)			; keep reading from tape port until we get a 1 at bit 1
        rra     
        jr      nc,TAPE1WT,$1b67        
        xor     a			; clear contents of A

TAPE0WT2:
l1b6d:  inc     a			; A is now a counter
        in      b,(c)			; Keep reading tape port till we get a 0
        rr      b			; incrementing A each time round the loop.
        jr      c,TAPE0WT2,$1b6d        ;

TAPE1WT2:
l1b74:  inc     a			; 
        in      b,(c)			; keep reading from tape port till we get a 1
        rr      b			; incrementing A each time.
        jr      nc,TAPE1WT2,$1b74       ;
        cp      $49			; compare total time with $49, set flags accordingly.
        ret     			;

l1b7e:  ret     

;
; Display tape save message and wait for RTN
;
RECMSG:
l1b7f:  push    hl
        push    de
        push    bc
        ld      hl,$1bf7		; point to 'Press <RECORD>'+CR+LF+$00
        jr      TAPEMSG,$1b34           ; display message and wait for RTN key.

;
; TAPEBYTE2, save the byte in A to tape TWICE.
;
TAPEBYTE2:
l1b87:  call    TAPEBYTE,$1b8a		; save byte in A to tape

; CASSETTE SAVE BYTE ROUTINE.
; Output one start bit, one byte, and two stop bits to tape.
; A 0 bit is saved as a LOW freuency tone (high time lag between bits)
; A 1 bit is saved as a HIGH frequency tone, (Low time lag between bits)
;
TAPEBYTE:
l1b8a:  push    af			; save AF
        exx     			; swap HL,DE and BC register sets
        ld      c,$fc  			; preload C with the tape IO port address.
        push    af			; save AF

					; output one START BIT (Start bit = 0)
        xor     a		        ; make A 00
        ld      e,$01			; E is the bit counter. ie No. of BITS to output.
					; the loop at $lba5 will out put 
					; the E most significant bits of A
        call    $1ba5			; Output the bits to tape.

        pop     af			; Restore AF
        ld      e,$08			; Prepare to output 8 bits.
        call    $1ba5			; Output the data to tape.
        ld      a,$ff			; Prepare to out put 2 stop bits. (Stop bit = 1)
        ld      e,$02			; 2 stop bits.
        call    $1ba5			; output the data
        exx     			; restore registers
        pop     af			; restore AF
        ret     			; return

l1ba5:  rla     			; Rotate bit 7 of A into CARRY,
					; if it is a 1 we get a High freq sound (low time lag)
					; if it is a 0 we get a Low Freq sound (high time lag)
        ld      l,$40			; preload L with $40=HIGH FREQ SOUND
        jr      c,$1bac                 ; if carry is 1 we jump forward,
        ld      l,$80			; otherwise overwrite L with $80 = LOW FREQ SOUND

l1bac:  ld      b,$04			; counting down from 4 to 1 gives 0,1,0,1 on BIT 0
	
l1bae:  out     (c),b			; c =$FC
        ld      h,l			; move L to H

l1bb1:  dec     h
        jr      nz,$1bb1                ; loop for a time delay of H reps.
        dec     b			; decrement B
        jr      nz,$1bae                ; if B is not 0, out put the new value to $FC
        dec     e			; if B is now 0 dec E
        jr      nz,$1ba5                ; loop the whole thing E times.
        ret     
        ret     

;
; SAVESYNC, saves a sync tone of 12 x $FF,$00 bytes to tape.
;
SAVESYNC:
l1bbc:  push    af
        push    bc
        ld      b,$0c			; 12 times we will out put FF followed by 00

l1bc0:  ld      a,$ff			;
        call    TAPEBYTE,$1b8a		; save byte in A to tape
        djnz    $1bc0                   ; Loop BC times.

        xor     a			; make A = 00
        call    TAPEBYTE,$1b8a		; save byte in A to tape
        pop     bc
        pop     af
        ret     

;
; Read the SYNC signal from the tape.
;
BYTEREAD:
l1bce:  push    af			; save AF
        push    bc			; save BC

l1bd0:  ld      b,$06			; preload B with 6, for 6 loops

l1bd2:  call    BYTEREAD2,$1b4d		; read data from tape.
        inc     a			; 
        jr      nz,$1bd0                ;  (-8)
        djnz    $1bd2                   ;  (-8)

l1bda:  call    BYTEREAD2,$1b4d		; read a byte from tape
        or      a
        jr      z,$1be5                 ;  (5)
        inc     a
        jr      z,$1bda                 ;  (-9)
        jr      $1bd0                   ;  (-21)

l1be5:  pop     bc
        pop     af
        ret     

l1be8	defb	'Press <PLAY>'+CR+LF+$00
l1bf7	defb	'Press <RECORD>'+CR+LF+$00

; Entry point for CSAVE command.
ST_CSAVE
l1c08	rst     $30,CALLUDF
	defb	$15

        cp      $aa			; Is the next byte the "*" operator?
					; if so we are saving DATA not BASIC program.
        jp      z,$0c62			; so jump to $0c62.
        call    $1cb8
        push    hl
        call    $1d25
        ld      hl,(BASTART)
        call    $1d38

l1c1c:  ld      b,$0f			; save 16 bytes of $00 to tape.
        xor     a

l1c1f:  call    TAPEBYTE,$1b8a		; Save byte in A to tape.
        djnz    $1c1f                   ; Decerement B and loop accordingly.
        ld      bc,$1f40		; Then pause for $1f40 loops (Approx 1 second)
        call    SLEEPBC,$1d4b		; sleep for BC loops.
        pop     hl

l1c2b:  ret     

; Entry point for CLOAD command.
ST_CLOAD:
        rst     $30,CALLUDF		; call the UDF if present.
	defb	$14			; 'CLOAD'
        cp      $aa			; is next byte the "*" operartor?
        jp      z,$0c63			; if so we are loading DATA not program.
					; so jump to $0c63
        sub     $95
        jr      z,$1c39                 ; 
        xor     a
        ld      bc,$232f
        cp      $01
        push    af
        ld      a,$ff
        ld      ($385e),a
        call    $1cb1

l1c46:  xor     a
        ld      ($385d),a
        push    de
        call    TAPELD1,$1b2e       	; Display the TAPE LOAD message
					; and wait for CR
        call    $1cd9
        ld      hl,$3857
        call    $1ced
        pop     de
        jr      z,$1c6c                 ;  (18)
        ld      hl,$1d06		; point to "Skip: "
        call    $1d0d			; print "Skip: " and the name of the program
					; being skipped on tape.

l1c60:  ld      b,$0a

l1c62:  call    BYTEREAD2,$1b4d
        or      a
        jr      nz,$1c60                ;  (-8)
        djnz    $1c62                   ;  (-8)
        jr      $1c46                   ;  (-38)

l1c6c:  ld      hl,$1cfe		; point to "Found: " message
        call    $1d0d			; print it and the name of the program
					; which was found.
        pop     af
        ld      ($38e4),a
        call    c,$0bbe
        ld      a,($38e4)
        cp      $01
        ld      ($385e),a
        ld      hl,(BASTART)
        call    $1d51
        jr      nz,$1c9a                ;  (17)
        ld      (BASEND),hl		; send 'END OF BASIC' marker.

LOAD_OK:
l1c8c:  ld      hl,$036e		; 'Ok'
        call    0e9d,PRINTSTR		; Print 'Ok'
        ld      a,$ff
        ld      ($385e),a
        jp      $0480			; 

l1c9a:  inc     hl
        ex      de,hl
        ld      hl,(BASEND)		; retrieve 'End of basic' pointer.
        rst     $20			; COMPARE it with DE
        jr      c,LOAD_OK,$1c8c        	; If DE > (BASEND) then jump to LOAD_OK

        ld      hl,$1cab		; Otherwise display 'Bad'+crlf+$00
        call    0e9d,PRINTSTR		; print "Bad"
        jp      OKMAIN2,$0401		; print OK and return to IMMEDIATE mode.
					

l1cab:	defb	'Bad',CRLF,$00

l1cb1:  xor     a
        ld      ($3851),a
        dec     hl
        rst     $10,GETNEXT
        ret     z

l1cb8:  call    $0985
        push    hl
        call    $1006
        dec     hl
        dec     hl
        dec     hl
        ld      b,(hl)
        ld      c,$06
        ld      hl,$3851

l1cc8:  ld      a,(de)
        ld      (hl),a
        inc     hl
        inc     de
        dec     c
        jr      z,$1cd7                 ;  (8)
        djnz    $1cc8                   ;  (-9)
        ld      b,c

l1cd2:  ld      (hl),$00
        inc     hl
        djnz    $1cd2                   ;  (-5)

l1cd7:  pop     hl
        ret     

l1cd9:  call    BYTEREAD,$1bce
        xor     a
        ld      ($385d),a
        ld      hl,$3857
        ld      b,$06			; prepare to read 6 bytes.

l1ce5:  call    BYTEREAD2,$1b4d		; read 1 byte from tape.
        ld      (hl),a			; store at (HL)
        inc     hl			; increment HL
        djnz    $1ce5                   ; and loop till we have read B bytes.
        ret     			; then return.

l1ced:  ld      bc,$3851
        ld      e,$06
        ld      a,(bc)
        or      a
        ret     z

l1cf5:  ld      a,(bc)
        cp      (hl)
        inc     hl
        inc     bc
        ret     nz
        dec     e
        jr      nz,$1cf5                ;  (-8)
        ret     

l1cfe:	defb	"Found: ",$00
l1d06:	defb	"Skip: ",$00

;
; Print either "Skip: " or "Found: " plus the name of the
; program found on tape.
;
PSKIPFND:
l1d0d:  push    de
        push    af
        call    0e9d,PRINTSTR
        ld      hl,$3857
        ld      b,$06			; maximum 6 characters in program name.

l1d17:  ld      a,(hl)
        inc     hl
        or      a
        jr      z,$1d1d                 ;  (1)
        rst     $18			; print character in A

l1d1d:  djnz    $1d17                  ; 
        call    PRNCRLF,$19ea
        pop     af
        pop     de
        ret     

l1d25:  call    RECMSG,$1b7f
        call    SAVESYNC,$1bbc
        ld      b,$06
        ld      hl,$3851

l1d30:  ld      a,(hl)
        inc     hl
        call    TAPEBYTE,$1b8a		; save byte in A to tape
        djnz    $1d30                   ;  (-7)
        ret     

l1d38:  call    SAVESYNC,$1bbc
        ex      de,hl
        ld      hl,(BASEND)		; HL points to the end of our BASIC program.

; Saves the block of data from DE to HL to tape.
SAVEBLOCK:
l1d3f:  ld      a,(de)
        inc     de
        call    TAPEBYTE,$1b8a		; save byte in A to tape
        rst     $20			; COMPARE HL,DE
        jr      nz,$1d3f                ; Keep saving bytes till we reach the 
					; end of our basic program.
        ret     			; return when done.

; SLEEPFFFF will enter a loop going round $FFFF times.
SLEEPFFFF:
l1d48:  ld      bc,$0000

SLEEP_BC:
l1d4b:  dec     bc			; decrement the loop counter.
        ld      a,b			; check if B and C are both 00
        or      c			
        jr      nz,SLEEPBC,$1d4b        ; Loop till BC = 00.
        ret     			; Then return.

l1d51:  call    BYTEREAD,$1bce
        ld      a,$ff
        ld      ($385d),a
        sbc     a,a
        cpl     
        ld      d,a

l1d5c:  ld      b,$0a

l1d5e:  call    BYTEREAD2,$1b4d
        ld      e,a
        sub     (hl)
        and     d
        ret     nz
        ld      (hl),e
        call    $0ba9
        ld      a,(hl)
        or      a
        inc     hl
        jr      nz,$1d5c                ;  (-18)
        djnz    $1d5e                   ;  (-18)
        xor     a
        ret     
PRNCHR1
l1d72:  rst     $30,CALLUDF			; UDF 
	defb	$13      

        push    af			; save AF
        cp      $0a			; A contains a character code.
        jr      z,RPRNCHR,$1d93         ; If it is LF, call RPRNCHR to handle it.
					; else carry on.
        ld      a,(CURCOL)		; check current cursor column
        or      a			; is it 0?
        jr      nz,RPRNCHR,$1d93        ; if not then just jump forward 
					; to print the character.

        ld      a,(ROWCOUNT)		; if CURCOL is 0 then we must have started
					; a new line so check (ROWCOUNT)
        or      a			; is that $00?
					; if ROWCOUNT is 00 we are NOT counting rows
					; so we just leave it and carry on.
					; otherwise we decrement the row count
					; and pause for a keypress every 24 lines.
        jr      z,RPRNCHR,$1d93         ; Not counting lines so jump forward to print.
        dec     a			; Otherwise, decrement line counter,
        ld      (ROWCOUNT),a		; and if not $00 then
        jr      nz,RPRNCHR,$1d93	; jump to print the character
        ld      a,$17			; else, reset (ROWCOUNT) to $17
        ld      (ROWCOUNT),a		; then Wait for any key.
        call    CLRKEYWT2,$1a2f		; Clear key buffer and wait for a keypress.

;
; RPRINCHR is entered here if the character to be printed
; is on the stack.
RPRNCHR:
l1d93:  pop     af			; retrive character from stack.

;
; PRNCHR
; Prints out the character in A and updates the
; screen system variables.
;
; Also handles special characters like
; BS,BELL,CLS,TAB etc
;


PRNCHR:
l1d94:  push    af
        exx     
        cp      $07			; is it a beep?
        jp      z,$1e14			; If so jump to BEEP

        cp      $0b			;  is it a CLS?
        jp      z,CLRSCRN		;  If so jump to CLS
        ld      e,a
        ld      hl,(CURRAM)		; location of cursor in ram
        ld      a,(CURHOLD)
        ld      (hl),a
        ld      a,e
        cp      $08			; is it a TAB
        jr      z,$1ddd                 ;  (48)

        cp      $0d			; is it a CR?
        jr      z,$1dbe                 ;  (13)

        cp      $0a			;  is it a LF
        jr      z,$1dc8                 ;  (19)

        ld      hl,(CURRAM)
        ld      (hl),a
        call    $1e1f
        jr      $1dea                   ;  (44)

l1dbe:  ld      de,(CURCOL)
        xor     a
        ld      d,a
        sbc     hl,de
        jr      $1de7                   ;  (31)

l1dc8:  ld      de,$33c0		; address of last line of screen character ram.
        rst     $20			; COMPARE HL,DE
        jp      nc,$1dd8
        ld      de,$0028
        add     hl,de
        ld      (CURRAM),hl
        jr      $1dea                   ;  (18)

l1dd8:  call    SCROLLUP		; scroll screen up one line
        jr      $1dea                   ;  (13)

l1ddd:  ld      a,(CURCOL)
        or      a
        jr      z,$1de5                 ;  (2)
        dec     hl
        dec     a

l1de5:  ld      (hl),$20

l1de7:  call    SVCURCOL,$1e3e		; save cursor address and column number.

l1dea:  ld      hl,(CURRAM)		; retrieve cursor position in character
					; ram matrix.
        ld      a,(hl)			; retrieve character at cursor.
        ld      (CURHOLD),a		; save to CURHOLD
        ld      (hl),$7f		; fill cursor position with cursor.

PRINTRET:
l1df3:  exx     
        pop     af
        ret     

        ld      hl,(CURRAM)
        ld      a,(CURHOLD)
        ld      (hl),a
        ret     

SCROLLUP:			; Scroll the screen UP one row.
l1dfe:  ld      bc,$0398 ; SIZE-OF-SCREEN (23rows * 40 cols)
        ld      de,$3028 ; CHR_HOME
        ld      hl,$3050
        ldir    

BLNKLINE:			; Blank the bottom line
        ld      b,$28		; 40 bytes, one line width
        ld      hl,$33c1	; address of last line

l1e0e:  ld      (hl),$20	; fill with SPACEs
        inc     hl
        djnz    $1e0e           ; Loop
        ret     

BEEP:
l1e14:  ld      bc,$00c8		; Duration
        ld      de,$0032		; Pitch
        call    PLAYSOUND

l1e1d:  jr      PRINTRET		; finished.

l1e1f:  ld      hl,(CURRAM)
        ld      a,(CURCOL)
        inc     hl			; increment ram address of cursor
        inc     a			; increment COLUMN counter
        cp      $26			; and compare with 38.
					; remember that when entering/listing BASIC 
					; programs that the aquarius only uses columns
					; 1 to 38 from the possible 0 to 39.

        jr      c,SVCURCOL,$1e3e        ; If less than 38 jump forward to
					; save CURCOL and CURRAM and return to caller.
        inc     hl			; HL now points to first editor column of next line.
        inc     hl
        ld      de,$33e8,CHAR_END	; the end of the character ram matrix.
        rst     $20			; COMPARE HL,DE
        ld      a,$00			; reset column counter.
        jr      c,SVCURCOL,$1e3e        ; Jump forward and save if not at screen end.
        ld      hl,$33c1		; otherwise point HL to start of bottom screen
					; line.
        call    SVCURCOL,$1e3e		; save data and
        jp      SCROLLUP		; scroll the screen up one line.

l1e3e:  ld      (CURRAM),hl		; ram location of cursor
        ld      (CURCOL),a		; column of cursor
        ret     

CLRSCRN:
l1e45:  ld      b,$20			; ASCII code for <space>
        ld      hl,$3000		; start of screen character ram location
        call    FILLSCRN		; fill screen character ram with spaces.

        ld      b,$06			; Black on BLUE colour attrib
        call    FILLSCRN		; set colour attribs.

        ld      hl,$3029		; first byte of CHAR RAM
        xor     a
        jp      $1de7

FILLSCRN:
l1e59:  ld      de,$03ff		; there are 1024 bytes in the COLOUR 
					; ram matrix
l1e5c:  ld      (hl),b			; fill each location with the colour code in B
        inc     hl			; next location
        dec     de			; Decrement the byte counter
        ld      a,d			; Check for DE=00
        or      e			; 
        jr      nz,$1e5c            	; Loop until de=0
        ret     			; then return

PLAYSOUND:
l1e64:  ld      a,b			; on entry BC=duration
        or      c			; DE=pitch
        ret     z			; RET if no duration left.
        xor     a			; start with speaker OFF
        out     ($fc),a			; 
        call    DELAY,$1e76		; Delay for DE loops
        inc     a			; speaker ON
        out     ($fc),a			; 
        call    DELAY,$1e76
        dec     bc			; dec DURATION
        jr      PLAYSOUND           	; loop to top of PLAYSOUND

DELAY:					; delay for DE loops
l1e76:  push    de
        pop     hl			; move DE to HL

l1e78:  ld      a,h
        or      l
        ret     z			; return when done.
        dec     hl
        jr      $1e78       		; loop if not done.

;
; Call the user defined keyboard handler.
; If no UDF Keyboard handler, the default is used.
UKEYCHK:
l1e7e:  rst     $30,CALLUDF			; Call the UDF 
        defb    $12

;
; KEYCHK: See if a key has been pressed and return ASCII value.
;
KEYCHK:
l1e80:  exx     			; Swap register sets.
l1e81:  ld      hl,(KWADDR)		; Is HL pointing to a KEYWORD?
        ld      a,h
        or      a
        jr      z,KEYCHK2,$1ea2         ; if NOT then continue scanning keyboard
        ex      de,hl			; else save HL into DE
        ld      hl,SCANCNT		; Retrieve the number of scans this key has
					; been hold down for.
        inc     (hl)			; Increment it.
        ld      a,(hl)			; 
        cp      $0f			; And test
        jr      c,KEYDONE,$1ece         ; Restore registers and return
        ld      (hl),$05
        ex      de,hl
        inc     hl
        ld      a,(hl)
        ld      (KWADDR),hl
        or      a
        jp      p,KEYRET,$1f36
        xor     a
        ld      ($380c),a

;
; The keyboard matrix is 8 lines in by 6 lines out.
; The keyboard is scanned by reading the value IN at port $FF
; Register B should hold a Bit pattern corresponding to the
; column of keys being scanned.
; For example to scan column 0 B would hold 11111110 (Binary)
;             to scan column 1 B would hold 11111101 
;             and so on.
;
; If a key is pressed it causes a bit in the IN value to be 0
; The invalue is then inverted (complimented) to make a key down
; cause a bit 1.
; 
; Initially this routine checks to see if ANY keys are down at all
; without trying to figure out which one, by scanning all the columns
; at once.
; A key is not decoded until it has been held down for 4 successive scans.
; this is as a 'debounce' to prevent spurious readings.
;
; Once the key has been scanned 71 times the routine stops counting.
; the number of scans is stored at address SCANCNT.
; The scan code is stored at $380E

KEYCHK2:
l1ea2:  ld      bc,$00ff		; Scan all columns at once.
        in      a,(c)			; Read the results.
        cpl     				; invert - (a key down now gives 1)
        and     $3f			; check all rows.
        ld      hl,LASTKEY		; Get the scan code of the last key pressed.
        jr      z,$1ec5             ; If NO keys pressed jump to $1ec5
						; else continue scanning, one column at a time.
SCNCOL8:
        ld      b,$7f			; 01111111 - scanning column 8
        in      a,(c)
        cpl     				; invert bits
        and     $0f			; check lower 4 bits
        jr      nz,$1ed7      	; there is a KEYDOWN

SCNCOLS:
        ld      b,$bf			; 10111111 - start with column 7
l1eba:  in      a,(c)
        cpl     			; invert bits
        and     $3f			; is there any key down?
        jr      nz,$1ed7      		; YES: goto KEYDOWN, 
        rrc     b			; NO: try next column
        jr      c,$1eba       		; when the 0 bit gets to CARRY FLAG we know
					; we have scanned all the columns
					; and not found anything, so we fall through to
					; NOKEYS

NOKEYS:					; no keys are down.
l1ec5:  inc     hl			; HL now equals SCANCNT, the SCAN counter.
        ld      a,$46			; this counts how many times the same code has 
        cp      (hl)			;  been scanned in a row. It stops counting at $46
        jr      c,KEYDONE,$1ece        	; Already scanned more than $46 times, so just return.
        jr      z,$1ed1             	; increment scan counter,  then return.
        inc     (hl)			; increment scan counter
;
; KEYDONE
;
l1ece:  xor     a			; clear accumulator
        exx     			; restore registers
        ret     			; return

l1ed1:  inc     (hl)			; increment the SCAN counter
        dec     hl			; point back to LASTKEY
        ld      (hl),$00		; clear it's contents
        jr      KEYDONE,$1ece    	; and exit.

;
; KEYDOWN
; Jump here if a key is found to be pressed.
; the B register still holds the bit pattern of the column being scanned.
; so one bit of B will be 0 the rest 1
;
KEYDOWN:
l1ed7:  ld      de,$0000		; DE is used as a column counter.

;
; KROWCNT, converts the BIT number of the row and column into 
; actual numbers. So if bit 7 was set, a would hold 7.
; the column is multiplied by 6 so it can be added to the row number
; to give a unique scan code for each key.
; There are 8 columns of 6 keys giving a total of 48 keys.
;
KROWCNT:
l1eda:  inc     e
        rra     
        jr      nc,KROWCNT                ; Count how many rotations to get the bit into the carry.
        ld      a,e			; A now holds the bit number which was SET
					; eg if bit 4 of A was set, A would now be $04
KCOLCNT:
l1edf:  rr      b			; 
        jr      nc,$1ee7                ; once the 0 bit gets to CARRY we jump to 
					;
        add     a,$06			; add 6 for each rotate, to give the column number.
        jr      $1edf,KCOLCNT                   ; 

;
; At this point A = (column*6)+row
;
;
l1ee7:  ld      e,a
        cp      (hl)			; Check to see if it is the 
        ld      (hl),a			; same keycode as last time.
        inc     hl			; if not, set scancount to 0
        jr      nz,$1efc            	; and return.
					
					; Same key, so has it been
        ld      a,$04			; down for 04 scans? (De-bounce)
        cp      (hl)			;
        jr      c,$1ef7             	; if more than 4, then we already handling it.
					; so keep counter at 06 and return.
        jr      z,KDECODE,$1f00         ; if is has been down for exactly 4 scans,
					; jump to KDECODE.
        inc     (hl)			; otherwise increment scan count...
        jr      $1ef9               	; ...and return.

l1ef7:  ld      (hl),$06

l1ef9:  xor     a
        exx     
        ret     
;
; If the keycode is different from last time, reset scan count
; and return.
;
SCANNEW:
l1efc:  ld      (hl),$00
        jr      $1ef9                   ;  (-7)

;
; The same key has now been down for $04 scans.
; so it's time to find out what it is.
KDECODE:
l1f00:  inc     (hl)			; increment the scan count
        ld      b,$7f			; read column 8 ($7f = 01111111)
        in      a,(c)			;
        bit     5,a			; CTRL key down?
        ld      ix,$1f93		; point to start of CTRL key lookup table
        jr      z,$1f19                 ; JUMP to KLOOKUP
        bit     4,a			; SHIFT key down?
        ld      ix,$1f65		; point to start of SHIFT key lookup table
        jr      z,$1f19                 ; JUMP to KLOOKUP
        ld      ix,$1f37		; else point to start of natural key lookup table.
;
; KLOOKUP
; This routine translates scancodes into actual ASCII values, or control
; key values. On entry IX points to the appropraite tabel and DE holds the offset
; into that table. The minimum offset is 1
;
KLOOKUP:
l1f19:  add     ix,de			; offset into table.
        ld      a,(ix+$00)		; retrieve code
        or      a			; update flags
        jp      p,KEYRET,$1f36		; if positive then it's not a KEY word.
					; so we return with the vlaue in A
					; else, it's an offset into the keyword table.
        sub     $7f			; So we strip the high bit.
					; this leaves us with an index in A representing the 
					; position on the keyword in the table.
					; ie if A = 3 then we want the THIRD keyword.
        ld      c,a			; move this number to C
        ld      hl,$0244		; Point to the byte prior to the 
					; start of the KEYWORD table.
;
; KYWSCAN, on entry C holds an index into the keyword table.
; we step throught the tabel to find that word.
; the first byte of each word has the BIT 7 set.
KYWSCAN:
l1f28:  inc     hl			;
        ld      a,(hl)			; read caharcter at (HL)
        or      a			; set flags
        jp      p,KYWSCAN,$1f28		; LOOP if positive.ie Bit 7=0, so it's
					; not the first letter of a keyword.
        dec     c			; DEC C at the start of each keyword.
        jr      nz,$1f28                ; if C is not yet 0 continue scanning
        ld      (KWADDR),hl		; save the position of the first byte of our
        and     $7f			; keyword. And strip it's high bit from A
					; A now holds the first CHARACTER of our keyword.
KEYRET:
l1f36:  exx     			; restore registers
        ret     			; and return.



; THE KEY TABLES
; The tables actually start 1 byte higher than IX since the minimum
; offset is 1 not 0.

;Vanilla key table - no shift or control keys pressed:
l1f38:	defb	'='
	defb	$08
	defb	':'
	defb	CR
	defb	";.-/0pl,9okmnj8i7uhb6ygvcf5t"
	defb	"4rdx3esz a2w1q"

; SHIFT key table
l1f66:	defb	"+\*",CR
	defb	"@>_^?PL<)OKMNJ(I'UHB&YGVCF%T$"
	defv	"RDX#ESZ A"
	defb	$22 				;the " charcter
	defb	"W!Q"

; CTRL key table
l1f94	defb	$82,$1c,$c1,$0d,$94,$c4,$81,$1e,$30,$10
	defb	$ca,$c3,$92,$0f,$9d,$0d,$c8,$9c,$8d,$09
	defb	$8c,$15,$08,$c9,$90,$19,$07,$c7,$03,$83
	defb	$88,$84,$a5,$12,$86,$18,$8a,$85,$13,$9a
	defb	$c6,$9b,$97,$8e,$89,$11



l1fc1:	ld      de,$21e5
        inc     b
        nop     
        add     hl,sp
        ld      ($38f9),hl
        pop     hl
        jp      CHKKEYP,$1a25		; read key buffer check for CTRL+C or CTRL+S

l1fce:  ld      hl,($38f9)

l1fd1:  ld      sp,hl
        ld      hl,(TMPSTAT)
        call    $0c20

l1fd8:  dec     hl			; DEC HL to point to the 
        dec     hl			; instruction that caused the
					; syntax error.
        ld      ($38f9),hl		; save HL
        ld      hl,$38b1		; preload HL
        ret     			; return

START:				; This routine is JUMPed to 
				; immediately upon power-on.
l1fe1:  ld      a,$ff		;
        out     ($fe),a 	;
        jp      $0041		; Jump to START2

;JMPCART:
l1fe8:  ld      a,$aa		; 10101010
        out     ($ff),a
        ld      (LASTFF),a
        jp      $2010		; Jump to ROM extension

l1ff2:  ld      hl,$015f  	; Start of Copyright message.
        jp      PRINTSTR	;


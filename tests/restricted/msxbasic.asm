
; How to build (use the z80asm variant in z88dk):
;
; z80asm -b msxbasic
;


; Variant with HOOKs disabled:
;
; z80asm -DNOHOOK -b msxbasic
;
; No HOOKs but same ROM addresses:
; z80asm -DNOHOOK -DPRESERVE_LOCATIONS -b msxbasic
;

; MOD demonstration (ZX Spectrum skin variant):
;
; z80asm -DSPECTRUM_SKIN -DNOHOOK -b msxbasic
; 


defc BEL    =  $07		; Control "G", BEEP via the console output
defc TAB    =  $09		; TAB
defc LF     =  $0A		; Line feed
defc CR     =  $0D		; Carriage return
defc FF     =  $0C		; Form Feed / CLS
defc ESC    =  $1B		; Escape


; --- Sizes --- 

defc NUMLEV   = 60  ; On CP/M it is 29: ; 0*20+19+2*5

; --- Prefixes, Tokens.. --- 

defc ONEFUN = TK_LEFT_S		; Function offset

defc CLMWID   = 14  ; MAKE COMMA COLUMNS FOURTEEN CHARACTERS



defc OCTCON   = 11  ; $0B - EMBEDED OCTAL CONSTANT
defc HEXCON   = 12  ; $0C - EMBEDED HEX CONSTANT

defc PTRCON   = 13  ; $0D - A LINE REFERENCE CONSTANT
defc LINCON   = 14  ; $0E - A LINE NUMBER UNCONVERTED TO POINTER

defc IN2CON   = 15  ;SINGLE BYTE (TWO BYTE WITH TOKEN) INTEGER
defc CONCN2   = 16  ;TOKEN RETURNED SECOND TYPE CONSTANT IS SCANNED.

defc ONECON   = 17  ;FIRST OF 10 (0-9) INTEGER SPECIAL TOKENS
defc INTCON   = 28  ;REGULAR 16 BIT TWO'S COMPLEMENT INT

defc CONCON   = 30  ;TOKEN RETURNED BY CHRGET AFTER CONSTANT SCANNED
defc DBLCON   = 31  ;DOUBLE PREC (8 BYTE) CONSTANT


; --- ------ --- 


;defc STACK_INIT = $F376
defc STACK_INIT = MAXRAM-10

  INCLUDE "msxbasic.def"
  INCLUDE "msxhook.def"
  INCLUDE "msxtoken.def"
  
  INCLUDE "msx.def"


ORG $0000

  
; Routine at 0
;
; Check RAM and sets slot for command area.
STARTUP:


  DI
  JP _STARTUP

; Used to initialize CHFONT
FONT:
  IF SPECTRUM_SKIN
  DEFW _FONT-256
  ELSE
  DEFW _FONT
  ENDIF

_VDP_RD:
  DEFB VDP_DATAIN
_VDP_WR:
  DEFB VDP_DATA

; A byte follows to be compared
;
; Checks if then current character pointed by
SYNCHR:
  JP _SYNCHR
  NOP

; Routine at 12
;
; Reads the value of an address in another slot
RDSLT:
  JP _RDSLT
  NOP

; Routine at 16
;
; Gets next character (or token) from BASIC text.
CHRGTB:
  JP _CHRGTB
  NOP

; Routine at 20
;
; Writes a value to an address in another slot.
WRTSLT:
  JP _WRTSLT
  NOP

; Routine at 24
;
; Output to the current device (formerly OUTC).
OUTDO:
  JP _OUTDO
  NOP

; Routine at 28
;
; Performs inter-slot call to specified address.
CALSLT:
  JP _CALSLT
  NOP

; Routine at 32
;
; Compare HL with DE.
DCOMPR:
  JP CPDEHL
  NOP

; Routine at 36
;
; Switches indicated slot at indicated page on perpetual
ENASLT:
  JP _ENASLT
  NOP

; Routine at 40
;
; Return the number type (FAC)
GETYPR:
  JP _GETYPR

; Routine at 43  
;  002B  1        Basic ROM Character set / Date format / Default interrupt freq
;               7 6 5 4 3 2 1 0
;               | | | | +-+-+-+-- Character set
;               | | | |           0 = Japanese, 1 = Other
;               | +-+-+---------- Date format
;               |                 0 = Y-M-D, 1 = M-D-Y, 2 = D-M-Y
;               +---------------- Default interrupt frequency (VSYNC)
;                                 0 = 60Hz, 1 = 50Hz
L002B:
  DEFB $91

L002C:
  DEFB $11
  
; 002D  1        MSX Version Number
;               0 = MSX 1
;               1 = MSX 2
;               2 = MSX 2+
;               3 = MSX Turbo RL002D:
  DEFB $00

L002E:
  DEFB $00		; IF BIT 0 = 1 then internal MIDI is present ( Turbo R Only !!! )

  NOP

; Routine at 48
;  Call FAR
CALLF:
  JP  _CALLF

L0033:
  NOP
  NOP
  NOP
  NOP
  NOP


; Routine at 56
;
; Performs hardware interrupt procedures.
KEYINT:
  JP _KEYINT

; Routine at 59
;
; Dev. initialization.
INITIO:
  JP _INITIO

; Routine at 62
;
; Initializes function key strings.
INIFNK:
  JP _INIFNK

; Routine at 65
;
; Disables screen display.
DISSCR:
  JP _DISSCR

; Routine at 68
;
; Enables screen display.
ENASCR:
  JP _ENASCR

; Routine at 71
;
; Writes to the VDP register.
WRTVDP:
  JP _WRTVDP

; Routine at 74
;
; Reads the VRAM address by [HL].
RDVRM:
  JP _RDVRM

; Routine at 77
;
; Write to the VRAM address by [HL].
WRTVRM:
  JP _WRTVRM

; Routine at 80
;
; Sets up the VDP for read.
SETRD:
  JP _SETRD

; Routine at 83
;
; Sets up the VDP for write.
SETWRT:
  JP _SETWRT

; Routine at 86
;
; Fill the vram with specified data
FILVRM:
  JP _FILVRM

; Routine at 89
;
; Block transfer to memory from VRAM
LDIRMV:
  JP _LDIRMV

; Routine at 92
;
; Block transfer to VRAM from memory
LDIRVM:
  JP _LDIRVM

; Routine at 95
;
; Sets the VDP mode according to SCRMOD.
CHGMOD:
  JP _CHGMOD

; Routine at 98
;
; Changes the color of the screen.
CHGCLR:
  JP _CHGCLR

  NOP

; Routine at 102
;
; Performs non-maskable interrupt procedures.
NMI:
  JP _NMI

; Routine at 105
;
; Initializes all sprites.
CLRSPR:
  JP _CLRSPR

; Routine at 108
;
; Initializes screen for text mode (40*24) and sets the VDP.
INITXT:
  JP _INITXT

; Routine at 111
;
; Initializes screen for text mode (32*24) and sets the VDP.
INIT32:
  JP _INIT32

; Routine at 114
;
; Initializes screen for high-resolution mode and sets the VDP.
INIGRP:
  JP _INIGRP

; Routine at 117
;
; Initializes screen for multi-color mode and sets the VDP.
INIMLT:
  JP _INIMLT

; Routine at 120
;
; Sets the VDP for text (40*24) mode.
SETTXT:
  JP _SETTXT

; Routine at 123
;
; Sets the VDP for text (32*24) mode.
SETT32:
  JP _SETT32

; Routine at 126
;
; Sets the VDP for high-resolution mode.
SETGRP:
  JP _SETGRP

; Routine at 129
;
; Sets the VDP for multicolor mode.
SETMLT:
  JP _SETMLT

; Routine at 132
;
; Returns address of sprite pattern table.
CALPAT:
  JP _CALPAT

; Routine at 135
;
; Returns address of sprite atribute table.
CALATR:
  JP _CALATR

; Routine at 138
;
; Returns the current sprite size.
GSPSIZ:
  JP _GSPSIZ

; Routine at 141
;
; Prints a character on the graphic screen.
GRPPRT:
  JP _GRPPRT

; Routine at 144
;
; Initializes PSG,and static data for PLAY
GICINI:
  JP _GICINI

; Routine at 147
;
; Writes data to the PSG register.
WRTPSG:
  JP _WRTPSG

; Routine at 150
;
; Reads data from PSG register.
RDPSG:
  JP _RDPSG

; Routine at 153
;
; Checks/starts background tasks for PLAY.
STRTMS:
  JP _STRTMS

; Routine at 156
;
; Check the status of keyboard buffer.
CHSNS:
  JP _CHSNS

; Routine at 159
;
; Waits for character being input and returns the character codes.
CHGET:
  JP _CHGET

; Routine at 162
;
; Outputs a character to the console.
CHPUT:
  JP _CHPUT

; Routine at 165
;
; Output a character to the line printer.
LPTOUT:
  JP _LPTOUT

; Routine at 168
;
; Check the line priter status.
LPTSTT:
  JP _LPTSTT

; Routine at 171
;
; Check graphic header byte and converts codes.
SNVCHR:
  JP _SNVCHR

; Routine at 174
;
; Accepts a line from console until a CR or STOP
PINLIN:
  JP _PINLIN

; Routine at 177
;
; Same as PINLIN,exept if AUTFLO if set.
INLIN:
  JP _INLIN

; Routine at 180
;
; Output a '?' mark and a space then falls into the INLIN routine.
QINLIN:
  JP _QINLIN

; Routine at 183
;
; Check the status of the Control-STOP key.
BREAKX:
  JP _BREAKX

; Routine at 186
;
; Check the status of the SHIFT-STOP key.
ISCNTC:
  JP _ISCNTC

; Routine at 189
;
; Same as ISCNTC,used by BASIC
CKCNTC:
  JP _CKCNTC

; Routine at 192
;
; Sounds the buffer
BEEP:
  JP _BEEP

; Routine at 195
;
; Clear the screen.
__CLS:
  JP _CLS

; Routine at 198
;
; Locate cursor at the specified position.
POSIT:
  JP _POSIT 		; Locate cursor at the specified position

; Routine at 201
;
; Check if function key display is active, and display the FN list if so...
FNKSB:
  JP _FNKSB

; Routine at 204
;
; Hide the function key diplay.
ERAFNK:
  JP _ERAFNK

; Routine at 207
;
; Show the function key display.
DSPFNK:
  JP _DSPFNK

; Routine at 210
;
; Forcidly places the screen in text mode.
TOTEXT:
  JP _TOTEXT

; Routine at 213
;
; Return the current joystick status.
GTSTCK:
  JP _GTSTCK

; Routine at 216
;
; Return the current trigger button status.
GTTRIG:
  JP _GTTRIG

; Routine at 219
;
; Check the current touch PAD status.
GTPAD:
  JP _GTPAD

; Routine at 222
;
; Return the value of the paddle.
GTPDL:
  JP _GTPDL

; Routine at 225
;
; Reads the header block after turning the cassette motor on
TAPION:
  JP _TAPION

; Routine at 228
;
; Read data from the tape
TAPIN:
  JP _TAPIN

; Routine at 231
;
; Stops reading from the tape
TAPIOF:
  JP _TAPIOF

; Routine at 234
;
; Turns on the cassette motor and writes the header
TAPOON:
  JP _TAPOON

; Routine at 237
;
; Writes data on the tape
TAPOUT:
  JP _TAPOUT

; Routine at 240
;
; Stops writing on the tape
TAPOOF:
  JP _TAPOOF

; Routine at 243
;
; Sets the cassette motor action
STMOTR:
  JP _STMOTR

; Routine at 246
;
; Gives number of bytes in queue
LFTQ:
  JP _LFTQ

; Routine at 249
;
; Put byte in queue
PUTQ:
  JP _PUTQ

; Routine at 252
;
; Shifts screenpixel to the right
RIGHTC:
  JP _RIGHTC

; Routine at 255
;
; Shifts screenpixel to the left
LEFTC:
  JP _LEFTC

; Routine at 258
;
; Shifts screenpixel up
UPC:
  JP _UPC

; Routine at 261
;
; Tests whether UPC is possible, if possible, execute UPC
TUPC:
  JP _TUPC

; Routine at 264
;
; Shifts screenpixel down
DOWNC:
  JP _DOWNC

; Routine at 267
;
; Tests whether DOWNC is possible, if possible, execute DOWNC
TDOWNC:
  JP _TDOWNC

; Routine at 270
;
; Scales X and Y coordinates
SCALXY:
  JP _SCALXY

; Routine at 273
; a.k.a. MAPXYC
;
; Places cursor at current cursor address
MAPXY:
  JP _MAPXY

; Routine at 276
;
; Gets current "graphics cursor" position and mask pattern
FETCHC:
  JP _FETCHC

; Routine at 279
;
; Record current "graphics cursor" position and mask pattern
STOREC:
  JP _STOREC

; Routine at 282
;
; Set attribute byte
SETATR:
  JP _SETATR

; Routine at 285
;
; Reads attribute byte of current screenpixel
READC:
  JP _READC

; Routine at 288
;
; Update current screenpixel of specified attribute byte
SETC:
  JP _SETC

; Routine at 291
;
; Set horizontal screenpixels: draws an horizontal line, used for filled polygons
NSETCX:
  JP _NSETCX

; Routine at 294
;
; Gets screen relations
GTASPC:
  JP _GTASPC
  
; Routine at 297
;
; This entry point is used by the routine at __PAINT.
PNTINI:
  JP _PNTINI
  
; Routine at 300
;
SCANR:
  JP _SCANR
  
; Routine at 303
;
SCANL:
  JP _SCANL		; $197A

; Routine at 306
;
; Alternates the CAP lamp status
CHGCAP:
  JP _CHGCAP

; Routine at 309
;
; Alternates the 1-bit sound port status
CHGSND:
  JP _CHGSND

; Routine at 312
;
; Reads the primary slot register
RSLREG:
  JP _RSLREG

; Routine at 315
;
; Writes value to the primary slot register
WSLREG:
  JP _WSLREG

; Routine at 318
;
; Reads VDP status register
RDVDP:
  JP _RDVDP

; Routine at 321
;
; Returns the value of the specified line from the keyboard matrix
SNSMAT:
  JP _SNSMAT

; Routine at 324
;
; Executes I/O for mass-storage media like diskettes
PHYDIO:
  JP _PHYDIO

; Routine at 327
;
; Initialises mass-storage media like formatting of diskettes
FORMAT:
  JP _FORMAT

; Routine at 330
;
; Tests if I/O to device is taking place
ISFLIO:
  JP _ISFLIO

; Routine at 333
;
; Printer output
OUTDLP:
  JP OUTC_TABEXP

; Routine at 336
;
; Returns pointer to play queue
GETVCP:
  JP _GETVCP

; Routine at 339
;
; Returns pointer to variable in queue number VOICEN (byte op $FB38)
GETVC2:
  JP _GETVC2

; Routine at 342
;
; Clear keyboard buffer
KILBUF:
  JP _KILBUF

; Routine at 345
;
; Executes inter-slot call to the routine in BASIC interpreter
CALBAS:
  JP _CALBAS

; -- RESERVED FOR EXPANSION --
L015C:
  DEFS $5A

; Routine at 438
;
; Used by the routines at RDSLT, _RDSLT_0, COPY_FONT and L0752.
; Reads the value in an address in another slot
_RDSLT:
  CALL SELPRM		; Calculate bit pattern and mask code, slot# in A
  JP M,_RDSLT_0
  IN A,(PPI_A)
  LD D,A
  AND C
  OR B
  CALL RDPRIM
  LD A,E
  RET

; Routine at 454
;
; Used by the routine at _RDSLT.
_RDSLT_0:
  PUSH HL
  CALL SELEXP		; Select secondary slot
  EX (SP),HL
  PUSH BC
  CALL _RDSLT
  JR _RW_SLT_SUB

; Routine at 465
;
; Used by the routines at WRTSLT and _WRTSLT_0.
; Writes a value to an address in another slot.
_WRTSLT:
  PUSH DE
  CALL SELPRM		; Calculate bit pattern and mask code, slot# in A
  JP M,_WRTSLT_0
  POP DE
  IN A,(PPI_A)
  LD D,A
  AND C
  OR B
  JP WRPRIM

; Routine at 481
;
; Used by the routine at _WRTSLT.
_WRTSLT_0:
  EX (SP),HL
  PUSH HL
  CALL SELEXP		; Select secondary slot
  POP DE
  EX (SP),HL
  PUSH BC
  CALL _WRTSLT
; This entry point is used also by the routine at _RDSLT_0.
_RW_SLT_SUB:
  POP BC
  EX (SP),HL
  PUSH AF
  LD A,B
  AND $3F
  OR C
  OUT (PPI_AOUT),A
  LD A,L
  LD ($FFFF),A		; Secondary slot select register 
  LD A,B
  OUT (PPI_AOUT),A
  POP AF
  POP HL
  RET

; Routine at 511
;
; Used by the routines at CALBAS, L0D12, _OUTDO and L1BA2.
_CALBAS:
IF NOCALBAS
  JP (IX)
  IF PRESERVE_LOCATIONS
    DEFS 4
  ENDIF
ELSE
  LD IY,(EXP0-1)			; Load expansion slot #0 address on IYl
  JR _CALSLT
ENDIF

; Routine at 517
;
; Used by the routine at L002B.
;  Call FAR
_CALLF:
  EX (SP),HL
  PUSH AF
  PUSH DE
  LD A,(HL)
  PUSH AF
  POP IY
  INC HL
  LD E,(HL)
  INC HL
  LD D,(HL)
  INC HL
  PUSH DE
  POP IX
  POP DE
  POP AF
  EX (SP),HL
; This entry point is used by the routines at CALSLT, _CALBAS and _CALSLT_0.
; Performs inter-slot call to specified address.
_CALSLT:
  EXX
  EX AF,AF'
  PUSH IY			; slot address is on IYl
  POP AF
  PUSH IX
  POP HL
  CALL SELPRM		; Calculate bit pattern and mask code, slot# in A
  JP M,_CALSLT_0
  IN A,(PPI_A)
  PUSH AF
  AND C
  OR B
  EXX
  JP CLPRIM

; Routine at 558
;
; Used by the routine at _CALLF.
_CALSLT_0:
  CALL SELEXP		; Select secondary slot
  PUSH AF
  POP IY
  PUSH HL
  PUSH BC
  LD C,A
  LD B,$00
  LD A,L
  AND H
  OR D
  LD HL,SLT0
  ADD HL,BC
  LD (HL),A
  PUSH HL
  EX AF,AF'
  EXX
  CALL _CALSLT
  EXX
  EX AF,AF'
  POP HL
  POP BC
  POP DE
  LD A,B
  AND $3F
  OR C
  DI
  OUT (PPI_AOUT),A
  LD A,E
  LD ($FFFF),A			;  Secondary slot select register 
  LD A,B
  OUT (PPI_AOUT),A
  LD (HL),E
  EX AF,AF'
  EXX
  RET

; Routine at 606
;
; Used by the routines at ENASLT, _ENASLT_0 and L043F.
_ENASLT:
  CALL SELPRM		; Calculate bit pattern and mask code, slot# in A
  JP M,_ENASLT_0
  IN A,(PPI_A)
  AND C
  OR B
  OUT (PPI_AOUT),A
  RET

; Routine at 619
;
; Used by the routine at _ENASLT.
_ENASLT_0:
  PUSH HL
  CALL SELEXP		; Select secondary slot
  LD C,A
  LD B,$00
  LD A,L
  AND H
  OR D
  LD HL,SLT0
  ADD HL,BC
  LD (HL),A
  POP HL
  LD A,C
  JR _ENASLT

; Routine at 638
;
; Used by the routines at _RDSLT, _WRTSLT, _CALLF and _ENASLT.
; Calculate bit pattern and mask code
SELPRM:
  DI
  PUSH AF
  LD A,H
  RLCA
  RLCA
  AND $03
  LD E,A
  LD A,$C0
SELPRM_0:
  RLCA
  RLCA
  DEC E
  JP P,SELPRM_0
  LD E,A
  CPL
  LD C,A
  POP AF
  PUSH AF
  AND $03
  INC A
  LD B,A
  LD A,$AB			; @10101011
SELPRM_1:
  ADD A,$55			; @01010101
  DJNZ SELPRM_1
  LD D,A
  AND E
  LD B,A
  POP AF
  AND A
  RET

; Routine at 675
;
; Used by the routines at _RDSLT_0, _WRTSLT_0, _CALSLT_0 and _ENASLT_0.
; Select secondary slot REG
SELEXP:
  PUSH AF
  LD A,D
  AND $C0
  LD C,A
  POP AF
  PUSH AF
  LD D,A
  IN A,(PPI_A)
  LD B,A
  AND $3F
  OR C
  OUT (PPI_AOUT),A
  LD A,D
  RRCA
  RRCA
  AND $03
  LD D,A
  LD A,$AB			; @10101011
SELEXP_0:
  ADD A,$55			; @01010101
  DEC D
  JP P,SELEXP_0
  AND E
  LD D,A
  LD A,E
  CPL
  LD H,A
  LD A,($FFFF)			 ; Secondary slot select register 
  CPL					; Reading returns INVERTED! previous written value
  LD L,A
  AND H
  OR D
  LD ($FFFF),A				; Secondary slot select register 
  LD A,B
  OUT (PPI_AOUT),A
  POP AF
  AND $03
  RET


; This entry point is used by the routine at STARTUP.
; $02D7
_STARTUP:
  LD A,$82
  OUT (PPI_MOUT),A
  XOR A
  OUT (PPI_AOUT),A
  LD A,$50
  OUT (PPI_COUT),A
  LD DE,$FFFF
  XOR A
  LD C,A
_STARTUP_0:
  OUT (PPI_AOUT),A
  SLA C
  LD B,$00
  LD HL,$FFFF				; Secondary slot select register 
  LD (HL),$F0
  LD A,(HL)					; Reading returns INVERTED! previous written value
  SUB $0F
  JR NZ,_STARTUP_2
  LD (HL),A
  LD A,(HL)
  INC A
  JR NZ,_STARTUP_2
  INC B
  SET 0,C
_STARTUP_1:
  LD ($FFFF),A				; Secondary slot select register 
_STARTUP_2:
  LD HL,$BF00
_STARTUP_3:
  LD A,(HL)
  CPL
  LD (HL),A
  CP (HL)
  CPL
  LD (HL),A
  JR NZ,_STARTUP_4
  NOP
  NOP
  NOP
  DEC H
  JP M,_STARTUP_3
_STARTUP_4:
  LD L,$00
  INC H
  LD A,L
  SUB E
  LD A,H
  SBC A,D
  JR NC,_STARTUP_5
  EX DE,HL
  LD A,($FFFF)					; Secondary slot select register 
  CPL							; Reading returns INVERTED! previous written value
  LD L,A
  IN A,(PPI_A)
  LD H,A
  LD SP,HL
_STARTUP_5:
  LD A,B
  AND A
  JR Z,_STARTUP_6
  LD A,($FFFF)				; Secondary slot select register
  CPL						; Reading returns INVERTED! previous written value
  ADD A,$10
  CP $40
  JR C,_STARTUP_1
_STARTUP_6:
  IN A,(PPI_A)
  ADD A,$50
  JR NC,_STARTUP_0
  LD HL,0
  ADD HL,SP
  LD A,H
  OUT (PPI_AOUT),A
  LD A,L
  LD ($FFFF),A						; Secondary slot select register
  LD A,C
  RLCA
  RLCA
  RLCA
  RLCA
  LD C,A
  LD DE,$FFFF
  IN A,(PPI_A)
  AND $3F
_STARTUP_7:
  OUT (PPI_AOUT),A
  LD B,$00
  RLC C
  JR NC,_STARTUP_9
  INC B
  LD A,($FFFF)					; Secondary slot select register
  CPL							; Reading returns INVERTED! previous written value
  AND $3F
_STARTUP_8:
  LD ($FFFF),A					; Secondary slot select register
_STARTUP_9:
  LD HL,$FE00
_STARTUP_10:
  LD A,(HL)
  CPL
  LD (HL),A
  CP (HL)
  CPL
  LD (HL),A
  JR NZ,_STARTUP_11
  NOP
  NOP
  NOP
  DEC H
  LD A,H
  CP $C0
  JR NC,_STARTUP_10
_STARTUP_11:
  LD L,$00
  INC H
  LD A,L
  SUB E
  LD A,H
  SBC A,D
  JR NC,_STARTUP_12
  EX DE,HL
  LD A,($FFFF)					; Secondary slot select register
  CPL							; Reading returns INVERTED! previous written value
  LD L,A
  IN A,(PPI_A)
  LD H,A
  LD SP,HL
_STARTUP_12:
  LD A,B
  AND A
  JR Z,_STARTUP_13
  LD A,($FFFF)					; Secondary slot select register
  CPL							; Reading returns INVERTED! previous written value
  ADD A,$40
  JR NC,_STARTUP_8
; $0398
_STARTUP_13:
  IN A,(PPI_A)
  ADD A,$40
  JR NC,_STARTUP_7
  LD HL,0
  ADD HL,SP
  LD A,H
  OUT (PPI_AOUT),A
  LD A,L
  LD ($FFFF),A					; Secondary slot select register

; $03A9
  LD A,C
  LD BC,$0C49			;  Clear System Variable Region (3145 bytes)
  LD DE,RDPRIM+1		;  System variables region
  LD HL,RDPRIM			;     "      "        "
  LD (HL),$00
  LDIR
  LD C,A
  LD B,$04
  LD HL,EXP3			; Expansion slot #3

_STARTUP_14:
; $03DB
  RR C
  SBC A,A
  AND $80
  LD (HL),A
  DEC HL
  DJNZ _STARTUP_14
  
  IN A,(PPI_A)
  LD C,A
  XOR A
  OUT (PPI_AOUT),A
  LD A,($FFFF)					; Secondary slot select register
  CPL							; Reading returns INVERTED! previous written value
  LD L,A
  LD A,$40
  OUT (PPI_AOUT),A
  LD A,($FFFF)					; Secondary slot select register
  CPL							; Reading returns INVERTED! previous written value
  LD H,A
  LD A,$80
  OUT (PPI_AOUT),A
  LD A,($FFFF)					; Secondary slot select register
  CPL							; Reading returns INVERTED! previous written value
  LD E,A
  LD A,$C0
  OUT (PPI_AOUT),A
  LD A,($FFFF)					; Secondary slot select register
  CPL							; Reading returns INVERTED! previous written value
  LD D,A
  LD A,C
  OUT (PPI_AOUT),A
  LD (SLT0),HL
  EX DE,HL
  LD (SLT2),HL
  

; $03F6
  IM 1
  JP CSTART
  

; Routine at 1019
;
; Used by the routines at ISCNTC and _CKCNTC.
_ISCNTC:
  LD A,(BASROM)		
  AND A
  RET NZ
  PUSH HL
  LD HL,INTFLG
  DI
  LD A,(HL)
  LD (HL),$00
  POP HL
  EI
  AND A
  RET Z
  CP $03
  JR Z,_ISCNTC_1
  PUSH HL
  PUSH DE
  PUSH BC
  CALL L09DA
  LD HL,INTFLG
_ISCNTC_0:
  DI
  LD A,(HL)
  LD (HL),$00
  EI
  AND A
  JR Z,_ISCNTC_0
  PUSH AF
  CALL L0A27
  POP AF
  POP BC
  POP DE
  POP HL
  CP $03
  RET NZ
_ISCNTC_1:
  PUSH HL
  CALL _KILBUF
  CALL CKSTTP				; Check for STOP trap
  JR NC,L043F
  LD HL,IFLG_STOP			; STOP button - Interrupt flags
  DI
  CALL TST_IFLG_EVENT
  EI
  POP HL
  RET

; Routine at 1087
;
; Used by the routine at _ISCNTC.
L043F:
  CALL _TOTEXT
  LD A,(EXP0)			; Expansion slot #0
  LD H,$40
  CALL _ENASLT
  POP HL
  XOR A
  LD SP,(SAVSTK)
  PUSH BC
  JP __STOP_0

; Routine at 1108
;
; Used by the routines at _ISCNTC and L24C4.
; Check for STOP trap
CKSTTP:
  LD A,(IFLG_STOP)			; STOP button - Interrupt flags
  RRCA
  RET NC
  LD HL,(IENTRY_STOP)		; STOP button - Interrupt related code
  LD A,H
  OR L
  RET Z
  LD HL,(CURLIN)		; Line number the Basic interpreter is working on, in direct mode it will be filled with #FFFF
  INC HL
  LD A,H
  OR L
  RET Z					; RET if we are in 'DIRECT' (immediate) mode
  SCF
  RET

; Routine at 1128
;
; Used by the routines at KILBUF and _ISCNTC.
_KILBUF:
  LD HL,(PUTPNT)
  LD (GETPNT),HL
  RET

; Routine at 1135
;
; Used by the routines at BREAKX, _LPTOUT, _TAPOON, _TAPOUT, _TAPIN, TAPIN_PERIOD and TAPIN_BIT.
; Return CY if STOP is pressed
_BREAKX:
  IN A,(PPI_C)
  AND $F0

  OR $07
  OUT (PPI_COUT),A
  
  IN A,(PPI_B)
  AND $10
  RET NZ
  IN A,(PPI_C)
  DEC A
  OUT (PPI_COUT),A
  IN A,(PPI_B)
  AND $02
  RET NZ
  PUSH HL
  LD HL,(PUTPNT)
  LD (GETPNT),HL
  POP HL
  LD A,(OLDKEY+7)
  AND $EF		; TK_EQUAL ?
  LD (OLDKEY+7),A
  LD A,$0D
  LD (REPCNT),A
  SCF
  RET


; Routine at 1181
;
; Used by the routine at INITIO.
_INITIO:
  LD A,$07
  LD E,$80
  CALL _WRTPSG
  LD A,$0F
  LD E,$CF
  CALL _WRTPSG
  LD A,$0B
  LD E,A
  CALL _WRTPSG
  CALL L110C
  AND $40
  LD (KANAMD),A
  LD A,$FF
  OUT (PRN_STB),A  
  
; This entry point is used by the routines at GICINI, _BEEP and L24C4.
_GICINI:
  PUSH HL
  PUSH DE
  PUSH BC
  PUSH AF
  LD HL,MUSICF
  LD B,$71
  XOR A
GICINI_1:
  LD (HL),A
  INC HL
  DJNZ GICINI_1
  LD DE,VOICAQ
  LD B,$7F
  LD HL,$0080
GICINI_2:
  PUSH HL
  PUSH DE
  PUSH BC
  PUSH AF
  CALL L14DA
  POP AF
  ADD A,$08
  LD E,$00
  CALL _WRTPSG
  SUB $08
  PUSH AF
  LD L,$0F
  CALL _GETVC2_0
  EX DE,HL
  LD HL,L0508
  LD BC,$0006
  LDIR
  POP AF
  POP BC
  POP HL
  POP DE
  ADD HL,DE
  EX DE,HL
  INC A
  CP $03
  JR C,GICINI_2
  LD A,$07
  LD E,$B8
  CALL _WRTPSG
  JP _POPALL

; Sound/Envelope table? at 1288, 6 bytes
L0508:
	DEFB $04,$04,$78,$88,$ff,$00
  

  

; This entry point is used by the routines at INITXT and _CHGMOD.
_INITXT:
  CALL _DISSCR
  XOR A
  LD (SCRMOD),A
  LD (OLDSCR),A
  LD A,(LINL40)
  LD (LINLEN),A
  LD HL,(TXTNAM)
  LD (NAMBAS),HL
  LD HL,(TXTCGP)
  LD (CGPBAS),HL
  CALL _CHGCLR
  CALL CLS_FORMFEED
  CALL COPY_FONT
  CALL _SETTXT
  JR _ENASCR

; Routine at 1336
;
; Used by the routines at INIT32 and _CHGMOD.
_INIT32:
  CALL _DISSCR
  LD A,$01
  LD (SCRMOD),A
  LD (OLDSCR),A
  LD A,(LINL32)
  LD (LINLEN),A
  LD HL,(T32NAM)		; SCREEN 1 name table
  LD (NAMBAS),HL
  LD HL,(T32CGP)		; SCREEN 1 character pattern table
  LD (CGPBAS),HL
  LD HL,(T32PAT)		; SCREEN 1 sprite pattern table
  LD (PATBAS),HL
  LD HL,(T32ATR)
  LD (ATRBAS),HL
  CALL _CHGCLR
  CALL CLS_FORMFEED
  CALL COPY_FONT
  CALL _CLRSPR_0
  CALL _SETT32
  
; This entry point is used by the routines at ENASCR, _INITXT, _INIGRP and _INIMLT.
_ENASCR:
  LD A,(RG1SAV)
  OR $40
  JR _DISSCR_0

; Routine at 1399
;
; Used by the routines at DISSCR, _INITXT, _INIT32, _INIGRP and _INIMLT.
_DISSCR:
  LD A,(RG1SAV)
  AND $BF
; This entry point is used by the routine at _INIT32.
_DISSCR_0:
  LD B,A
  LD C,$01
  
; This entry point is used by the routines at WRTVDP, _SETTXT, _SETT32, _SETGRP,
; _SETMLT, _CLRSPR and RESTORE_BORDER.
_WRTVDP:
  LD A,B
  DI
  OUT (VDP_CMD),A
  LD A,C
  OR $80
  OUT (VDP_CMD),A
  EI
  PUSH HL
  LD A,B
  LD B,$00
  LD HL,RG0SAV
  ADD HL,BC
  LD (HL),A
  POP HL
  RET

; Routine at 1428
;
; Used by the routines at SETTXT and _INITXT.
_SETTXT:
  LD A,(RG0SAV)
  AND $01
  LD B,A
  LD C,$00
  CALL _WRTVDP
  LD A,(RG1SAV)
  AND $E7
  OR $10
  LD B,A
  INC C
  CALL _WRTVDP
  LD HL,TXTNAM
  LD DE,$0000
  JP _SETMLT_0

; Routine at 1460
;
; Used by the routines at SETT32 and _INIT32.
_SETT32:
  LD A,(RG0SAV)
  AND $01
  LD B,A
  LD C,$00
  CALL _WRTVDP
  LD A,(RG1SAV)
  AND $E7
  LD B,A
  INC C
  CALL _WRTVDP
  LD HL,T32NAM		; SCREEN 1 name table
  LD DE,$0000
  JP _SETMLT_0

; Routine at 1490
;
; Used by the routines at INIGRP and _CHGMOD.
_INIGRP:
  CALL _DISSCR
  LD A,$02
  LD (SCRMOD),A
  LD HL,(GRPPAT)		; SCREEN 2 sprite pattern table
  LD (PATBAS),HL
  LD HL,(GRPATR)		; SCREEN 2 sprite attribute table
  LD (ATRBAS),HL
  LD HL,(GRPNAM)		; SCREEN 2 name table
  CALL _SETWRT
  XOR A
  LD B,$03
_INIGRP_0:
  OUT (VDP_DATA),A
  INC A
  JR NZ,_INIGRP_0
  DJNZ _INIGRP_0
  CALL CLS_TXT
  CALL _CLRSPR_0
  CALL _SETGRP
  JP _ENASCR

; Routine at 1538
;
; Used by the routines at SETGRP and _INIGRP.

_SETGRP:
  LD A,(RG0SAV)
  OR $02
  LD B,A
  LD C,$00
  CALL _WRTVDP
  LD A,(RG1SAV)
  AND $E7
  LD B,A
  INC C
  CALL _WRTVDP
  LD HL,GRPNAM
  LD DE,$7F03
  JR _SETMLT_0

; Routine at 1567
;
; Used by the routines at INIMLT and _CHGMOD.
_INIMLT:
  CALL _DISSCR
  LD A,$03
  LD (SCRMOD),A
  LD HL,(MLTPAT)		; SCREEN 3 sprite pattern table
  LD (PATBAS),HL
  LD HL,(MLTATR)		; SCREEN 3 sprite attribute table
  LD (ATRBAS),HL
  LD HL,(MLTNAM)		; SCREEN 3 name table
  CALL _SETWRT
  LD DE,$0006
_INIMLT_0:
  LD C,$04
_INIMLT_1:
  LD A,D
  LD B,$20
_INIMLT_2:
  OUT (VDP_DATA),A
  INC A
  DJNZ _INIMLT_2
  DEC C
  JR NZ,_INIMLT_1
  LD D,A
  DEC E
  JR NZ,_INIMLT_0
  CALL CLS_MLT
  CALL _CLRSPR_0
  CALL _SETMLT
  JP _ENASCR

; Routine at 1625
;
; Used by the routines at SETMLT and _INIMLT.
_SETMLT:
  LD A,(RG0SAV)
  AND $01
  LD B,A
  LD C,$00
  CALL _WRTVDP
  LD A,(RG1SAV)
  AND $E7
  OR $08
  LD B,A
  LD C,$01
  CALL _WRTVDP
  LD HL,MLTNAM		; SCREEN 3 name table
  LD DE,$0000
; This entry point is used by the routines at _SETTXT, _SETT32 and _SETGRP.
_SETMLT_0:
  LD BC,$0602
  CALL _SETMLT_1
  LD B,$0A
  LD A,D
  CALL _SETMLT_2
  LD B,$05
  LD A,E
  CALL _SETMLT_2
  LD B,$09
  CALL _SETMLT_1
  LD B,$05
_SETMLT_1:
  XOR A
_SETMLT_2:
  PUSH HL
  PUSH AF
  LD A,(HL)
  INC HL
  LD H,(HL)
  LD L,A
  XOR A
_SETMLT_3:
  ADD HL,HL
  ADC A,A
  DJNZ _SETMLT_3
  LD L,A
  POP AF
  OR L
  LD B,A
  CALL _WRTVDP
  POP HL
  INC HL
  INC HL
  INC C
  RET

; Routine at 1704
;
; Used by the routine at CLRSPR.
_CLRSPR:
  LD A,(RG1SAV)
  LD B,A
  LD C,$01
  CALL _WRTVDP
  LD HL,(PATBAS)
  LD BC,$0800		; 2048
  XOR A
  CALL _FILVRM
  
; This entry point is used by the routines at _INIT32, _INIGRP and _INIMLT.
_CLRSPR_0:
  LD A,(FORCLR)
  LD E,A
  LD HL,(ATRBAS)
  LD BC,$2000
_CLRSPR_1:
  LD A,$D1
  CALL _WRTVRM
  INC HL
  INC HL
  LD A,C
  CALL _WRTVRM
  INC HL
  INC C
  LD A,(RG1SAV)
  RRCA
  RRCA
  JR NC,_CLRSPR_2
  INC C
  INC C
  INC C
_CLRSPR_2:
  LD A,E
  CALL _WRTVRM
  INC HL
  DJNZ _CLRSPR_1
  RET

; Routine at 1764
;
; Used by the routine at CALPAT.
_CALPAT:
  LD L,A
  LD H,$00
  ADD HL,HL
  ADD HL,HL
  ADD HL,HL
  CALL _GSPSIZ
  CP $08
  JR Z,_CALPAT_0
  ADD HL,HL
  ADD HL,HL
_CALPAT_0:
  EX DE,HL
  LD HL,(PATBAS)
  ADD HL,DE
  RET

; Routine at 1785
;
; Used by the routine at CALATR.
_CALATR:
  LD L,A
  LD H,$00
  ADD HL,HL
  ADD HL,HL
  EX DE,HL
  LD HL,(ATRBAS)
  ADD HL,DE
  RET

; Routine at 1796
;
; Used by the routines at GSPSIZ and _CALPAT.
_GSPSIZ:
  LD A,(RG1SAV)
  RRCA
  RRCA
  LD A,$08
  RET NC
  LD A,$20
  RET

; Routine at 1807
;
; Used by the routines at LDIRMV and ESC_L_2.
_LDIRMV:
  CALL _SETRD
  EX (SP),HL
  EX (SP),HL
_LDIRMV_0:
  IN A,(VDP_DATAIN)
  LD (DE),A
  INC DE
  DEC BC
  LD A,C
  OR B
  JR NZ,_LDIRMV_0
  RET

; Routine at 1822
;
; Used by the routines at _INITXT and _INIT32.
COPY_FONT:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HINIP			;  Hook to Copy character set to VDP
ENDIF
  LD HL,(CGPBAS)
  CALL _SETWRT
  LD A,(SLOTID)
  LD HL,(CHFONT)
  LD BC,$0800			; FONT LENGTH: 2048 bytes 
  PUSH AF
COPY_FONT_0:
  POP AF
  PUSH AF
  PUSH BC
  DI
  CALL _RDSLT
  EI
  POP BC
  OUT (VDP_DATA),A
  INC HL
  DEC BC
  LD A,C
  OR B
  JR NZ,COPY_FONT_0
  POP AF
  RET

; Routine at 1860
;
; Used by the routines at LDIRVM and RESET_CONSOLE.
_LDIRVM:
  EX DE,HL
  CALL _SETWRT
_LDIRVM_0:
  LD A,(DE)
  OUT (VDP_DATA),A
  INC DE
  DEC BC
  LD A,C
  OR B
  JR NZ,_LDIRVM_0
  RET

; Routine at 1874
;
; Used by the routine at _GRPPRT.
L0752:
  LD H,$00
  LD L,A
  ADD HL,HL
  ADD HL,HL
  ADD HL,HL
  EX DE,HL
  LD HL,(CHFONT)
  ADD HL,DE
  LD DE,PATWRK
  LD B,$08
  LD A,(SLOTID)
L0752_0:
  PUSH AF
  PUSH HL
  PUSH DE
  PUSH BC
  CALL _RDSLT
  EI
  POP BC
  POP DE
  POP HL
  LD (DE),A
  INC DE
  INC HL
  POP AF
  DJNZ L0752_0
  RET

; Routine at 1911
;
; Used by the routine at _CLS.
CLS:
  CALL IS_TXT
  JR Z,CLS_TXT
  JR NC,CLS_MLT
; This entry point is used by the routines at _INITXT and _INIT32.
CLS_FORMFEED:
  LD A,(SCRMOD)
  AND A
  LD HL,(NAMBAS)
  LD BC,$03C0		; 960  (40*24)
  JR Z,CLS_1
  LD BC,$0300		; 768	(32x24)
CLS_1:
  LD A,' '
  CALL _FILVRM
  CALL CURS_HOME
  LD HL,LINTTB
  LD B,$18
CLS_2:
  LD (HL),B
  INC HL
  DJNZ CLS_2
  JP _FNKSB			; Check if function key display is active, and display the FN list if so...

; Routine at 1953
;
; Used by the routines at _INIGRP and CLS.
CLS_TXT:
  CALL RESTORE_BORDER
  LD BC,$1800
  PUSH BC
  LD HL,(GRPCOL)		; SCREEN 2 color table
  LD A,(BAKCLR)
  CALL _FILVRM
  LD HL,(GRPCGP)		; SCREEN 2 character pattern table
  POP BC
  XOR A
  ; --- START PROC L07B6 ---
__FILVRM:
  JP _FILVRM

; Data block at 1977
  ; --- START PROC CLS_MLT ---
CLS_MLT:
  CALL RESTORE_BORDER
  LD HL,BAKCLR
  LD A,(HL)
  ADD A,A
  ADD A,A
  ADD A,A
  ADD A,A
  OR (HL)
  LD HL,(MLTCGP)		; SCREEN 3 character pattern table
  LD BC,$0600		; 64*24
  JR __FILVRM

; Routine at 1997
;
; Used by the routines at WRTVRM, _CLRSPR, _NSETCX and SETC_GFX_4.
_WRTVRM:
  PUSH AF
  CALL _SETWRT
  EX (SP),HL
  EX (SP),HL
  POP AF
  OUT (VDP_DATA),A
  RET

; Routine at 2007
;
; Used by the routines at RDVRM and L166C.
; $07D7
_RDVRM:
  CALL _SETRD
  EX (SP),HL
  EX (SP),HL
  IN A,(VDP_DATAIN)
  RET

; Routine at 2015
;
; Used by the routines at SETWRT, _INIGRP, _INIMLT, COPY_FONT, _LDIRVM, _WRTVRM, ESC_CLINE and
; OUT_CHAR.
_SETWRT:
  LD A,L
  DI
  OUT (VDP_CMD),A
  LD A,H
  AND $3F
  OR $40
  OUT (VDP_CMD),A
  EI
  RET

; Routine at 2028
;
; Used by the routines at SETRD, _LDIRMV, _RDVRM and GETCOD.
_SETRD:
  LD A,L
  DI
  OUT (VDP_CMD),A
  LD A,H
  AND $3F
  OUT (VDP_CMD),A
  EI
  RET

  ; --- START PROC L07F7 ---
_CHGCLR:
  LD A,(SCRMOD)
  DEC A
  JP M,_CHGCLR_0
  PUSH AF
  CALL RESTORE_BORDER
  POP AF
  RET NZ
  LD A,(FORCLR)		; Foreground color 
  ADD A,A
  ADD A,A
  ADD A,A
  ADD A,A
  LD HL,BAKCLR
  OR (HL)
  LD HL,(T32COL)		; SCREEN 1 color table
  LD BC,32

_FILVRM:
  PUSH AF
  CALL _SETWRT
_FILVRM_0:
  POP AF
  OUT (VDP_DATA),A
  PUSH AF
  DEC BC
  LD A,C
  OR B
  JR NZ,_FILVRM_0
  POP AF
  RET
  
_CHGCLR_0:
  LD A,(FORCLR)		; Foreground color 
  ADD A,A
  ADD A,A
  ADD A,A
  ADD A,A
  LD HL,BAKCLR
  OR (HL)
  LD B,A
  JR SETBORDER

  
; Routine at 2098
;
; Used by the routine at CLS_TXT.
RESTORE_BORDER:
  LD A,(BDRCLR)
SETBORDER:
  LD B,A
  LD C,$07
  JP _WRTVDP

; Routine at 2107
;
; Used by the routines at TOTEXT and L043F.
_TOTEXT:
  CALL IS_TXT
  RET C
  LD A,(OLDSCR)
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HTOTE		; Hook for the TOTEXT std routine
ENDIF
  JP _CHGMOD		; Sets the VDP mode according to SCRMOD.

; Routine at 2120
;
; Used by the routine at __CLS.
_CLS:
  RET NZ
  PUSH HL
  CALL CLS
  POP HL
  RET

; Routine at 2127
;
; Used by the routines at CHGMOD and _TOTEXT.
; Sets the VDP mode according to SCRMOD.
_CHGMOD:
  DEC A
  JP M,_INITXT
  JP Z,_INIT32
  DEC A
  JP Z,_INIGRP
  JP _INIMLT

; Routine at 2141
;
; Used by the routines at LPTOUT and L1BA2.
_LPTOUT:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HLPTO		; Hook for "LPTOUT"
ENDIF
  PUSH AF
_LPTOUT_0:
  CALL _BREAKX		; Set CY if STOP is pressed
  JR C,LPTOUT_BRK
  CALL _LPTSTT
  JR Z,_LPTOUT_0
  POP AF
; This entry point is used by the routine at LPTOUT_BRK.
_LPTOUT_1:
  PUSH AF
  OUT (PRN_DATA),A
  XOR A
  OUT (PRN_STB),A
  DEC A
  OUT (PRN_STB),A
  POP AF
  AND A
  RET

  
; Routine at 2168
;
; Used by the routine at _LPTOUT.
LPTOUT_BRK:
  XOR A
  LD (LPTPOS),A
  LD A,CR
  CALL _LPTOUT_1
  POP AF
  SCF
  RET

; Routine at 2180
;
; Used by the routines at LPTSTT and _LPTOUT.
_LPTSTT:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HLPTS		;  Hook for LPTSTT
ENDIF
  IN A,(PRN_STATUS)
  RRCA
  RRCA
  CCF
  SBC A,A
  RET

; Routine at 2190
;
; Used by the routines at POSIT and TTY_CR.
_POSIT: 		; Locate cursor at the specified position
  LD A,ESC
  RST OUTDO  		; Output char to the current device
  LD A,'Y'			; ESC_Y, set cursor coordinates
  RST OUTDO  		; Output char to the current device
  LD A,L
  ADD A,$1F			; L+31
  RST OUTDO  		; Output char to the current device
  LD A,H
  ADD A,$1F			; H+31
  RST OUTDO  		; Output char to the current device
  RET

; Routine at 2205
;
; Used by the routines at SNVCHR, CHPUT_CONT, _FNKSB and OUTC_TABEXP.
; A.K.A. CNVCHR (Convert Character)
_SNVCHR:
  PUSH HL
  PUSH AF
  LD HL,GRPHED
  XOR A
  CP (HL)
  LD (HL),A
  JR Z,_SNVCHR_SUB
  POP AF
  SUB $40	; 'A'-1 ?
  CP $20
  JR C,_SNVCHR_1
  ADD A,$40
; This entry point is used by the routine at _SNVCHR_SUB.
_SNVCHR_0:
  CP A
  SCF
_SNVCHR_1:
  POP HL
  RET

; Routine at 2228
;
; Used by the routine at _SNVCHR.
_SNVCHR_SUB:
  POP AF
  CP $01
  JR NZ,_SNVCHR_0
  LD (HL),A
  POP HL
  RET

; Routine at 2236
;
; Used by the routines at CHPUT and _OUTCON.
_CHPUT:
  PUSH HL
  PUSH DE
  PUSH BC
  PUSH AF
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HCHPU			; Hook for CHPUT event (A-character; SAVE ALL)
ENDIF
  CALL IS_TXT
  JR NC,_POPALL
  CALL ERASE_CURSOR
  POP AF
  PUSH AF
  CALL CHPUT_CONT
  CALL DISP_CURSOR
  LD A,(CSRX)
  DEC A
  LD (TTYPOS),A
; This entry point is used by the routines at _INITIO and _GRPPRT_4.
_POPALL:
  POP AF
; This entry point is used by the routines at L0D89, _CHGET and L11E2.
_CHPUT_1:
  POP BC
  POP DE
  POP HL
  RET

; Routine at 2271
;
; Used by the routines at _CHPUT and CURS_TAB.
CHPUT_CONT:
  CALL _SNVCHR        ; Convert character
  RET NC
  LD C,A
  JR NZ,L08F3
  LD HL,ESCCNT
  LD A,(HL)
  AND A               ; Are we in ESCAPE or in some special 'control code' mode ?
  JP NZ,IN_ESC
  LD A,C
  CP ' '              ;IS THIS A MEANINGFUL CHARACTER?
  JR C,TRYOUT         ;IF IT'S A NON-PRINTING CHARACTER
L08F3:
  LD HL,(CSRY)
IF SPECTRUM_SKIN
  ; Unbind CHR$(127) and make it printable
ELSE
  CP $7F		; 'DEL' key code
  JP Z,DELCHR
ENDIF
  CALL OUT_CHAR
  CALL ESC_C
  RET NZ
  XOR A
  CALL SETTRM
  LD H,$01
CURS_LF:
  CALL CURS_DOWN
  RET NZ
  CALL SV_CURS_POS
  LD L,$01
  JP ESC_M_0	; ESC,"M", delete line

; Routine at 2324
;
; Used by the routine at CHPUT_CONT.
; $0914:  Character control code processor
TRYOUT:
  LD HL,TTY_CTLCODES-2
  LD C,12
; This entry point is used by the routines at IN_ESC and _QINLIN.
; Parse the jump table in HL for C entries
TTY_JP:
  INC HL
  INC HL
  AND A
  DEC C
  RET M
  CP (HL)
  INC HL
  JR NZ,TTY_JP
  LD C,(HL)
  INC HL
  LD B,(HL)
  LD HL,(CSRY)
  CALL JP_BC
  XOR A
  RET

; Routine at 2349
;
; Used by the routine at TRYOUT.
JP_BC:
  PUSH BC
  RET

; First TTY JP table (12 entries)
TTY_CTLCODES:

  DEFB BEL		; BELL, go beep
  DEFW _BEEP
  
  DEFB $08		; BS, cursor left
  DEFW CURS_LEFT
  
  DEFB $09		; TAB, cursor to next tab position
  DEFW CURS_TAB
  
  DEFB LF		; LF, cursor down a row
  DEFW CURS_LF
  
  DEFB $0b		; HOME, cursor to home
  DEFW CURS_HOME
  
  DEFB FF		; FORMFEED, clear screen and home
  DEFW CLS_FORMFEED
  
  DEFB $0d		; CR, cursor to leftmost column
  DEFW CURS_CR
  
  DEFB $1b		; ESC, enter escape sequence
  DEFW ENTER_ESC
  
  DEFB $1c		; RIGHT, cursor right
  DEFW CURS_RIGHT
  
  DEFB $1d		; LEFT, cursor left
  DEFW CURS_LEFT
  
  DEFB $1e		; UP, cursor up
  DEFW CURS_UP
  
  DEFB $1f		; DOWN, cursor down.
  DEFW CURS_DOWN

  
; Second TTY JP table (15 entries)
TTY_ESC:
  DEFB 'j'		; ESC,"j", clear screen and home
  DEFW CLS_FORMFEED		
  
  DEFB 'E'		; ESC,"E", clear screen and home
  DEFW CLS_FORMFEED
  
  DEFB 'K'		; ESC,"K", clear to end of line
  DEFW ESC_K
  
  DEFB 'J'		; ESC,"J", clear to end of screen
  DEFW ESC_J
  
  DEFB 'l'		; ESC,"l", clear line
  DEFW ESC_CLINE
  
  DEFB 'L'		; ESC,"L", insert line
  DEFW ESC_L
  
  DEFB 'M'		; ESC,"M", delete line
  DEFW ESC_M
  
  DEFB 'Y'		; ESC,"Y", set cursor coordinates
  DEFW ESC_Y
  
  DEFB 'A'		; ESC,"A", cursor up
  DEFW CURS_UP
  
  DEFB 'B'		; ESC,"B", cursor down
  DEFW CURS_DOWN

  DEFB 'C'		; ESC,"C", cursor right
  DEFW ESC_C
  
  DEFB 'D'		; ESC,"D", cursor left
  DEFW ESC_D+1
  
  DEFB 'H'		; ESC,"H", cursor home
  DEFW CURS_HOME
  
  DEFB 'x'		; ESC,"x", change cursor
  DEFW ESC_CURSOR_X
  
  DEFB 'y'		; ESC,"y", change cursor
  DEFW ESC_CURSOR_Y
  
  
ESC_CURSOR_X:
; ESC,"x", change cursor, see ESC_CURS
  LD A,$01
  
  DEFB $01	; "LD BC,nn" to jump over the next word without executing it
ESC_CURSOR_Y:
; ESC,"y", change cursor, see ESC_CURS
  LD A,$02

  DEFB $01	; "LD BC,nn" to jump over the next word without executing it
; ESC,"Y", set cursor coordinates, see ESC_CURS
ESC_Y:
  LD A,$04

  DEFB $01	; "LD BC,nn" to jump over the next word without executing it
; 'ESCAPE' sequence handling
ENTER_ESC:
  LD A,$FF
  
L098B:
  LD (ESCCNT),A
  RET

; Routine at 2447
;
; Used by the routine at CHPUT_CONT.
; "ESC sequence processor"
IN_ESC:
  JP P,ESC_CURS
; In-Escape
  LD (HL),$00
  LD A,C
  LD HL,TTY_ESC-2
  LD C,15
  JP TTY_JP

; Routine at 2461
;
; Used by the routine at IN_ESC.
; different "Escape-Like" status flags
ESC_CURS:
  DEC A
  JR Z,CHG_CURSOR_X		; ESC,"x", change cursor
  DEC A
  JR Z,CHG_CURSOR_Y		; ESC,"y", change cursor
  DEC A
; ESC,"Y", set cursor coordinates (row,column)
  LD (HL),A
  LD A,(LINLEN)
  LD DE,CSRX
  JR Z,ESC_CURS_0
  LD (HL),$03
  CALL TEXT_LINES
  DEC DE
ESC_CURS_0:
  LD B,A
  LD A,C
  SUB $20	;Top left of screen is n=m=20h.
  CP B
  INC A
  LD (DE),A
  RET C
  LD A,B
  LD (DE),A
  RET

; Routine at 2494
;
; Used by the routine at ESC_CURS.
CHG_CURSOR_X:
  LD (HL),A
  LD A,C
  SUB '4'
  JR Z,SET_CSTYLE	; Set block cursor style
  DEC A			; Cursor off
  JR Z,SET_CRSW
  RET

; Routine at 2504
;
; Used by the routine at ESC_CURS.
CHG_CURSOR_Y:
  LD (HL),A
  LD A,C
  SUB '4'
  JR NZ,CURSOR_ON

  INC A		; Set underscore cursor style
; This entry point is used by the routine at CHG_CURSOR_X.
SET_CSTYLE:
  LD (CSTYLE),A
  RET

; Routine at 2515
;
; Used by the routine at CHG_CURSOR_Y.
CURSOR_ON:
  DEC A
  RET NZ
  INC A
; This entry point is used by the routine at CHG_CURSOR_X.
SET_CRSW:
  LD (CSRSW),A
  RET

; Routine at 2522
;
; Used by the routines at _ISCNTC and _CHGET.
L09DA:
  LD A,(CSRSW)
  AND A
  RET NZ
  JR DISP_CURSOR_0

; Routine at 2529
;
; Used by the routines at _CHPUT, L2428, TTY_CR, L24F2, L2535, L2550 and L25CD.
DISP_CURSOR:
  LD A,(CSRSW)
  AND A
  RET Z
; This entry point is used by the routine at L09DA.
DISP_CURSOR_0:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HDSPC			; Hook for "Display Cursor" event
ENDIF
  CALL IS_TXT
  RET NC
  LD HL,(CSRY)
  PUSH HL
  CALL GETCOD
  LD (CODSAV),A
  LD L,A
  LD H,$00
  ADD HL,HL
  ADD HL,HL
  ADD HL,HL
  EX DE,HL
  LD HL,(CGPBAS)
; L0A01:
  PUSH HL
  ADD HL,DE
  CALL RD_CURSOR_PIC
  LD HL,LINWRK + 7			; $FC1F
  LD B,$08		; block cursor style
  LD A,(CSTYLE)
  AND A
  JR Z,DISP_CURSOR_1
  LD B,$03		; "underscore" cursor style
DISP_CURSOR_1:
  LD A,(HL)
  CPL			; Toggle cursor block
  LD (HL),A
  DEC HL
  DJNZ DISP_CURSOR_1
  POP HL
  LD BC,$07F8		; 2040
  ADD HL,BC
  CALL WR_CURSOR_PIC
  POP HL
  LD C,$FF
  JP OUT_CHAR

; Routine at 2599
;
; Used by the routines at _ISCNTC and _CHGET.
L0A27:
  LD A,(CSRSW)
  AND A
  RET NZ
  JR ERASE_CURSOR_0

; Routine at 2606
;
; Used by the routines at _CHPUT, L2428, TTY_CR, L24F2, L2550, L25AE, L25B9,
; L25D7, L25F8 and L260E.
ERASE_CURSOR:
  LD A,(CSRSW)
  AND A
  RET Z
; This entry point is used by the routine at L0A27.
ERASE_CURSOR_0:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HERAC			;  Hook for "Erase cursor" event
ENDIF
  CALL IS_TXT
  RET NC
  LD HL,(CSRY)
  LD A,(CODSAV)
  LD C,A
  JP OUT_CHAR

; Routine at 2628
;
; Used by the routines at CHPUT_CONT and CURS_RIGHT.
; ESC,"C", cursor right
ESC_C:
  LD A,(LINLEN)
  CP H
  RET Z
  INC H
  JR SV_CURS_POS

; Routine at 2636
;
; Used by the routines at DELCHR and L2634.
CURS_LEFT:
  CALL ESC_D+1		; ESC,"D", cursor left
  RET NZ
  LD A,(LINLEN)
  LD H,A
ESC_D:
	; ESC_D+1:	DEC H / LD A,n  (Toggle DEC H / DEC L)
  LD DE,$3E25
CURS_UP:
  DEC L
  RET Z
  JR SV_CURS_POS

; Routine at 2651
;
; Used by the routines at L25D7, L260E and L2624.
CURS_RIGHT:
  CALL ESC_C		; ESC,"C", cursor right
  RET NZ
  LD H,$01
; This entry point is used by the routine at CHPUT_CONT.
CURS_DOWN:
  CALL TEXT_LINES
  CP L
  RET Z
  JR C,L0A6D
  INC L
; This entry point is used by the routines at CHPUT_CONT, ESC_C, CURS_LEFT, L0A6D and CURS_HOME.
SV_CURS_POS:
  LD (CSRY),HL
  RET

; Routine at 2669
;
; Used by the routine at CURS_RIGHT.
L0A6D:
  DEC L
  XOR A
  JR SV_CURS_POS

; Routine at 2673
CURS_TAB:
  LD A,' '
  CALL CHPUT_CONT
  LD A,(CSRX)
  DEC A
  AND $07
  JR NZ,CURS_TAB
  RET

; Routine at 2687
;
; Used by the routine at CLS.
CURS_HOME:
  LD L,$01
; This entry point is used by the routines at ESC_M and ESC_L.
CURS_CR:
  LD H,$01
  JR SV_CURS_POS

; Routine at 2693
; ESC,"M", delete line
ESC_M:
  CALL CURS_CR
; This entry point is used by the routines at CHPUT_CONT and L2535.
ESC_M_0:
  CALL TEXT_LINES
  SUB L
  RET C
  JP Z,ESC_CLINE		; ESC,"l", clear line
  PUSH HL
  PUSH AF
  LD C,A
  LD B,$00
  CALL GETTRM
  LD L,E
  LD H,D
  INC HL
  LDIR
  LD HL,FSTPOS
  DEC (HL)
  POP AF
  POP HL
ESC_M_1:
  PUSH AF
  INC L
  CALL ESC_L_2
  DEC L
  CALL RESET_CONSOLE
  INC L
  POP AF
  DEC A
  JR NZ,ESC_M_1
  JP ESC_CLINE		; ESC,"l", clear line

; Routine at 2740
; ESC,"L", insert line
ESC_L:
  CALL CURS_CR
; This entry point is used by the routine at L2524.
ESC_L_0:
  CALL TEXT_LINES
  LD H,A
  SUB L
  RET C
  JP Z,ESC_CLINE		; ESC,"l", clear line
  LD L,H
  PUSH HL
  PUSH AF
  LD C,A
  LD B,$00
  CALL GETTRM
  LD L,E
  LD H,D
  PUSH HL
  DEC HL
  LDDR
  POP HL
  LD (HL),H
  POP AF
  POP HL
ESC_L_1:
  PUSH AF
  DEC L
  CALL ESC_L_2
  INC L
  CALL RESET_CONSOLE
  DEC L
  POP AF
  DEC A
  JR NZ,ESC_L_1
  JR ESC_CLINE		; ESC,"l", clear line

; Routine at 2787
;
; Used by the routine at CHPUT_CONT.
; Outputting the code for 'DELETE'
DELCHR:
  CALL CURS_LEFT
  RET Z
  LD C,' '
  JP OUT_CHAR

; Routine at 2796
;
; Used by the routines at ESC_M, ESC_L and _ERAFNK.
; ESC,"l", clear line
ESC_CLINE:
  LD H,$01
; This entry point is used by the routines at ESC_J and L25B9.
; ESC,"K", clear to end of line
ESC_K:
  CALL TERMIN
  PUSH HL
  CALL TXT_LOC
  CALL _SETWRT
  POP HL
ESC_CLINE_1:
  LD A,' '
  OUT (VDP_DATA),A
  INC H
  LD A,(LINLEN)
  CP H
  JR NC,ESC_CLINE_1
  RET

; Routine at 2821
; ESC,"J", clear to end of screen
ESC_J:
  PUSH HL
  CALL ESC_K	; ESC,"K", clear to end of line
  POP HL
  CALL TEXT_LINES
  CP L
  RET C
  RET Z
  LD H,$01
  INC L
  JR ESC_J

; Routine at 2837
;
; Used by the routine at ERAFNK.
_ERAFNK:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HERAF			; Hook for ERAFNK std routine(no param.)
ENDIF
  XOR A
  CALL UPD_CNSDFG
  RET NC
  PUSH HL
  LD HL,(CRTCNT)
  CALL ESC_CLINE		; ESC,"l", clear line
  POP HL
  RET

; Routine at 2854
;
; Used by the routines at FNKSB and CLS.
; Check if function key display is active, and display the FN list if so...
_FNKSB:
  LD A,(CNSDFG)		; FN key status
  AND A
  RET Z

; This entry point is used by the routines at DSPFNK and _CHSNS.
; Show the function key display.
_DSPFNK:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HDSPF		; Hook for DSPFNK std routine(no param.)
ENDIF
  LD A,$FF
  CALL UPD_CNSDFG
  RET NC
  PUSH HL
  LD A,(CSRY)
  LD HL,CRTCNT
  CP (HL)
  LD A,LF
  JR NZ,_FNKSB_1
  RST OUTDO  		; Output char to the current device
_FNKSB_1:
  LD A,($FBEB)		; KBD ROW #6
  RRCA
  LD HL,FNKSTR
  LD A,$01
  JR C,_FNKSB_2
  LD HL,FNKSTR+80
  XOR A
_FNKSB_2:
  LD (FNKSWI),A
  LD DE,LINWRK
  PUSH DE
  LD B,40
  LD A,' '
_FNKSB_3:
  LD (DE),A
  INC DE
  DJNZ _FNKSB_3
  POP DE
  LD C,$05
  LD A,(LINLEN)
  SUB $04
  JR C,_FNKSB_8
  LD B,$FF
_FNKSB_4:
  INC B
  SUB $05
  JR NC,_FNKSB_4
  LD A,B
  AND A
  JR Z,_FNKSB_8

  DEFB $3E  ; "LD A,n" to Mask the next byte
L0B75:
  INC DE
  PUSH BC
  LD C,$00
_FNKSB_5:
  LD A,(HL)
  INC HL
  INC C
  CALL _SNVCHR
  JR NC,_FNKSB_5
  JR NZ,_FNKSB_6
  CP ' '
  JR C,_FNKSB_7
_FNKSB_6:
  LD (DE),A
_FNKSB_7:
  INC DE
  DJNZ _FNKSB_5
  LD A,$10
  SUB C
  LD C,A
  ADD HL,BC
  POP BC
  DEC C
  JR NZ,L0B75
_FNKSB_8:
  LD HL,(CRTCNT)
  CALL RESET_CONSOLE
  POP HL
  RET

; Routine at 2972
;
; Used by the routines at _ERAFNK and _FNKSB.
UPD_CNSDFG:
  LD (CNSDFG),A		; FN key status
; This entry point is used by the routines at CLS, _TOTEXT, _CHPUT, DISP_CURSOR, ERASE_CURSOR and _CHSNS.
IS_TXT:
  LD A,(SCRMOD)
  CP $02
  RET

; Routine at 2981
;
; Used by the routine at DISP_CURSOR.
RD_CURSOR_PIC:
  PUSH HL
  LD C,$08		; 8 bytes for cursor "shape"
  JR ESC_L_2_0

; Routine at 2986
;
; Used by the routines at ESC_M and ESC_L.
ESC_L_2:
  PUSH HL
  LD H,$01
  CALL TXT_LOC
  LD A,(LINLEN)
  LD C,A
; This entry point is used by the routine at RD_CURSOR_PIC.
ESC_L_2_0:
  LD B,$00		; byte counter in C only
  LD DE,LINWRK
  CALL _LDIRMV	; VRAM to DE
  POP HL
  RET

; Routine at 3006
;
; Used by the routine at DISP_CURSOR.
WR_CURSOR_PIC:
  PUSH HL
  LD C,$08			; 8 bytes for cursor "shape"
  JR RESET_CONSOLE_0

; Routine at 3011
;
; Used by the routines at ESC_M, ESC_L and _FNKSB.
RESET_CONSOLE:
  PUSH HL
  LD H,$01
  CALL TXT_LOC
  LD A,(LINLEN)
  LD C,A
; This entry point is used by the routine at WR_CURSOR_PIC.
RESET_CONSOLE_0:
  LD B,$00
  EX DE,HL
  LD HL,LINWRK
  CALL _LDIRVM
  POP HL
  RET

; Routine at 3032
;
; Used by the routines at DISP_CURSOR, TTY_CR, L24F2, L2550, L25D7 and L2634.
GETCOD:
  PUSH HL
  CALL TXT_LOC
  CALL _SETRD
  EX (SP),HL
  EX (SP),HL
  IN A,(VDP_DATAIN)
  LD C,A
  POP HL
  RET

; Routine at 3046
;
; Used by the routines at CHPUT_CONT, DISP_CURSOR, ERASE_CURSOR, DELCHR, L24F2 and L2550.
;
OUT_CHAR:
  PUSH HL
  CALL TXT_LOC
  CALL _SETWRT
  LD A,C
  OUT (VDP_DATA),A
  POP HL
  RET

; Routine at 3058
;
; Used by the routines at ESC_CLINE, ESC_L_2, RESET_CONSOLE, GETCOD and OUT_CHAR.
TXT_LOC:
  PUSH BC
  LD E,H
  LD H,$00
  LD D,H
  DEC L
  ADD HL,HL
  ADD HL,HL
  ADD HL,HL		; *8
  LD C,L
  LD B,H
  ADD HL,HL
  ADD HL,HL		; *32
  ADD HL,DE		; -> *40
  LD A,(SCRMOD)
  AND A
  LD A,(LINLEN)
  JR Z,TXTLOC_SUB
  SUB $22
  JR TXTLOC_SUB_0

; Routine at 3085
;
; Used by the routine at TXT_LOC.
TXTLOC_SUB:
  ADD HL,BC
  SUB $2A		; '*'? TK_CVD ?
; This entry point is used by the routine at TXT_LOC.
TXTLOC_SUB_0:
  CPL
  AND A
  RRA
  LD E,A
  ADD HL,DE
  EX DE,HL
  LD HL,(NAMBAS)
  ADD HL,DE
  DEC HL
  POP BC
  RET

; Routine at 3101
;
; Used by the routines at ESC_M, ESC_L, TERMIN, TTY_CR, L24C4, L24F2, L2550,
; L25B9, L25D7 and L266C.
; LD A,(DE+L)	..
GETTRM:
  PUSH HL
  LD DE,BASROM
  LD H,$00
  ADD HL,DE
  LD A,(HL)
  EX DE,HL
  POP HL
  AND A
  RET

; Routine at 3113
;
; Used by the routines at ESC_CLINE, _QINLIN and TTY_CR.
TERMIN:
	;TERMIN+1: XOR A
  LD A,$AF
; This entry point is used by the routine at CHPUT_CONT.
SETTRM:
  PUSH AF
  CALL GETTRM
  POP AF
  LD (DE),A
  RET

; Routine at 3122
;
; Used by the routines at ESC_CURS, CURS_RIGHT, ESC_M, ESC_L, ESC_J, L2524 and L2624.
TEXT_LINES:
  LD A,(CNSDFG)		; FN key status
  PUSH HL
  LD HL,CRTCNT
  ADD A,(HL)		; Number of lines on screen 
  POP HL
  RET

; This entry point is used by the routine at KEYINT.
_KEYINT:
  PUSH HL
  PUSH DE
  PUSH BC
  PUSH AF
  EXX
  EX AF,AF'
  PUSH HL
  PUSH DE
  PUSH BC
  PUSH AF
  PUSH IY
  PUSH IX
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HKEYI 		; First interrupt handler hook
ENDIF
  IN A,(VDP_STATUS)
  AND A
  JP P,_KEYINT_2
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HTIMI			; Hook 2 for Interrupt handler
	ENDIF
  EI
  LD (STATFL),A
  AND $20
  LD HL,IFLG_COLLSN		; Sprite collision - Interrupt flags
  CALL NZ,TST_IFLG_EVENT
  LD HL,(INTCNT)
  DEC HL
  LD A,H
  OR L
  JR NZ,_KEYINT_0
  LD HL,IFLG_TIMER			; TIMER - Interrupt flags
  CALL TST_IFLG_EVENT
  LD HL,(INTVAL)
_KEYINT_0:
  LD (INTCNT),HL
  LD HL,(JIFFY)
  INC HL
  LD (JIFFY),HL
  LD A,(MUSICF)
  LD C,A
  XOR A
_KEYINT_1:
  RR C
  PUSH AF
  PUSH BC
  CALL C,L113B
  POP BC
  POP AF
  INC A
  CP $03
  JR C,_KEYINT_1
  LD HL,SCNCNT		; a.k.a. KYREPT, Wait count for repeat
  DEC (HL)
  JR NZ,_KEYINT_2
  LD (HL),$01
  XOR A
  CALL _GTSTCK_2
  AND $30
  PUSH AF
  LD A,$01
  CALL _GTSTCK_2
  AND $30
  RLCA
  RLCA
  POP BC
  OR B
  PUSH AF
  CALL _GTSTCK_5
  AND $01
  POP BC
  OR B
  LD C,A
  LD HL,TRGFLG
  XOR (HL)
  AND (HL)
  LD (HL),C
  LD C,A
  RRCA
  LD HL,IFLG_STRIG0			; SPACE key trigger - Interrupt flags
  CALL C,TST_IFLG_EVENT
  RL C
  LD HL,IFLG_STRIG4			; Joystick 2, Fire 2 - Interrupt flags
  CALL C,TST_IFLG_EVENT
  RL C
  LD HL,IFLG_STRIG2			; Joystick 2, Fire 1 - Interrupt flags
  CALL C,TST_IFLG_EVENT
  RL C
  LD HL,IFLG_STRIG3			; Joystick 1, Fire 2 - Interrupt flags
  CALL C,TST_IFLG_EVENT
  RL C
  LD HL,IFLG_STRIG1			; Joystick 1, Fire 1 - Interrupt flags
  CALL C,TST_IFLG_EVENT
  XOR A
  LD (CLIKFL),A
  CALL L0D12
  JR NZ,_KEYINT_2
  LD HL,REPCNT
  DEC (HL)
  JR NZ,_KEYINT_2
  LD (HL),$01
  LD HL,OLDKEY
  LD DE,OLDKEY+1
  LD BC,$000A
  LD (HL),$FF
  LDIR
  CALL L0D49_0
_KEYINT_2:
  POP IX
  POP IY
  POP AF
  POP BC
  POP DE
  POP HL
  EX AF,AF'
  EXX
  POP AF
  POP BC
  POP DE
  POP HL
  EI
  RET

; Routine at 3346
;
; Used by the routine at _KEYINT.
L0D12:
  IN A,(PPI_C)			; $9A on SVI
  AND $F0
  LD C,A
  LD B,$0B
  LD HL,NEWKEY
L0D12_0:
  LD A,C
  OUT (PPI_COUT),A			; $96 on SVI
  IN A,(PPI_B)			; $99 on SVI
  LD (HL),A
  INC C
  INC HL
  DJNZ L0D12_0
  LD A,(ENSTOP)
  AND A
  JR Z,L0D3A
  
L0D2C:
  LD A,($FBEB)				; KBD ROW #6
  CP $E8					; CTRL-STOP  ?
  JR NZ,L0D3A
  LD IX,READYR
  JP _CALBAS

; Routine at 3386
;
; Used by the routine at L0D12.
L0D3A:
  LD DE,NEWKEY
  LD B,$0B
L0D3A_0:
  DEC DE
  DEC HL
  LD A,(DE)
  CP (HL)
  JR NZ,L0D49
  DJNZ L0D3A_0
  JR L0D49_0

; Routine at 3401
;
; Used by the routine at L0D3A.
L0D49:
  LD A,$0D
  LD (REPCNT),A
; This entry point is used by the routines at _KEYINT and L0D3A.
L0D49_0:
  LD B,$0B
  LD HL,OLDKEY
  LD DE,NEWKEY
L0D49_1:
  LD A,(DE)
  LD C,A
  XOR (HL)
  AND (HL)
  LD (HL),C
  CALL NZ,L0D89
  INC DE
  INC HL
  DJNZ L0D49_1
; This entry point is used by the routine at _CHSNS.
L0D49_2:
  LD HL,(GETPNT)
  LD A,(PUTPNT)
  SUB L
  RET

; Routine at 3434
;
; Used by the routines at CHSNS and _CHGET.
_CHSNS:
  EI
  PUSH HL
  PUSH DE
  PUSH BC
  CALL IS_TXT
  JR NC,_CHSNS_0
  LD A,(FNKSWI)
  LD HL,$FBEB				; KBD ROW #6
  XOR (HL)
  LD HL,CNSDFG		; FN key status
  AND (HL)
  RRCA
  CALL C,_DSPFNK		; Show the function key display.
_CHSNS_0:
  CALL L0D49_2
  POP BC
  POP DE
  POP HL
  RET

; Routine at 3465
;
; Used by the routine at L0D49.
L0D89:
  PUSH HL
  PUSH DE
  PUSH BC
  PUSH AF
  LD A,$0B
  SUB B
  ADD A,A
  ADD A,A
  ADD A,A
  LD C,A
  LD B,$08
  POP AF
L0D97:
  RRA
  PUSH BC
  PUSH AF
  CALL C,SCAN_KEYBOARD
  POP AF
  POP BC
  INC C
  DJNZ L0D97
  JP _CHPUT_1

; Message at 3493
KEYMAP:
  DEFM "0123456789-="
  DEFB '\\'
  DEFM "[];'`,./"
  DEFB $FF

; Message at 3515
L0DBB:
  DEFM "abcdefghijklmnopqrstuvwxyz"
  DEFM ")!@#$%^&*(_+|{}:"
  DEFB '"'
  DEFM "~<>?"
  DEFB $FF

; Message at 3563
L0DEB:
  DEFM "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  DEFB  $09


L0E06:
  DEFB  $ac,$ab,$ba,$ef,$bd,$f4,$fb,$ec,$07,$17,$f1,$1e,$01,$0d,$06,$05
  DEFB  $bb,$f3,$f2,$1d
  DEFB $FF

  DEFB  $c4,$11,$bc,$c7

L0E1F:
  CALL L1514
  INC DE
  CALL C,$DDC6
  RET Z
  DEC BC
  DEC DE
  JP NZ,$CCDB
  JR L0E1F-$1F		;$0E00 (??)

; Data block at 3630
L0E2E:
  DEFB $12,$C0,$1A,$CF,$1C,$19,$0F,$0A
  DEFB $00,$FD,$FC,$00
  
L0E3A:  ; Later we have a reference to $0E3A, but perhaps they are not bound
  DEFB $00,$F5,$00,$00
  DEFB $08
  DEFB $1F,$F0,$16,$02
  DEFB $0E,$04,$03
  DEFB $F7,$AE,$AF,$F6,$FF,$FE,$00,$FA
  DEFB $C1
  
  DEFB $CE,$D4
  DEFB $10,$D6
  DEFB $DF,$CA
  DEFB $DE,$C9
  DEFB $0C,$D3
  
  DEFB $C3,$D7
  DEFB $CB,$A9
  DEFB $D1
  
  DEFB $00,$C5,$D5,$D0,$F9,$AA,$F8,$EB
  DEFB $9F,$D9,$BF,$9B,$98,$E0,$E1,$E7
  DEFB $87,$EE,$E9,$00,$ED,$DA,$B7,$B9
  DEFB $E5,$86,$A6,$A7,$FF,$84,$97,$8D
  DEFB $8B,$8C,$94,$81,$B1,$A1,$91,$B3
  DEFB $B5,$E6,$A4,$A2,$A3,$83,$93,$89
  DEFB $96,$82,$95,$88,$8A,$A0,$85,$D8
  DEFB $AD,$9E,$BE,$9C,$9D,$00,$00,$E2
  DEFB $80,$00,$00,$00
  DEFB $E8,$EA,$B6,$B8,$E4,$8F,$00
  DEFB $A8,$FF,$8E
  DEFB $00,$00,$00,$00
  DEFB $99,$9A,$B0,$00
  DEFB $92,$B2,$B4,$00
  DEFB $A5,$00,$E3,$00
  DEFB $00,$00,$00,$90,$00,$00,$00,$00,$00

L0EC5:
  LD E,C
  LD D,$00
  LD HL,$FB99		; $FB99: Unknown System Variable, or -1127, -$0467
  ADD HL,DE
  LD A,(HL)
  AND A
  JR NZ,L0EE3
L0ED0:
  EX DE,HL
  ADD HL,HL
  ADD HL,HL
  ADD HL,HL
  ADD HL,HL
  LD DE,$F52F		; $F52F: Unknown System Variable or -2769, -$0AD1
  ADD HL,DE
  EX DE,HL
L0EDA:
  LD A,(DE)
  AND A
  RET Z
  CALL K_L0F46_1
  INC DE
  JR L0EDA

; Routine at 3811
L0EE3:
  LD HL,(CURLIN)		 ; Line number the Basic interpreter is working on, in direct mode it will be filled with #FFFF
  INC HL
  LD A,H
  OR L
  JR Z,L0ED0		; JP if in 'DIRECT' (immediate) mode
  LD HL,$FBAD		; OLDKEY base address ?  ($FD43 on SVI)
  ADD HL,DE
  ADD HL,DE
  ADD HL,DE
  
; This entry point is used by the routines at _ISCNTC and _KEYINT.
TST_IFLG_EVENT:
  LD A,(HL)
  AND $01
  RET Z
  LD A,(HL)
  OR $04
  CP (HL)
  RET Z
  LD (HL),A
  XOR $05
  RET NZ
  LD A,(ONGSBF)
  INC A
  LD (ONGSBF),A
  RET

IF NOHOOK
 IF PRESERVE_LOCATIONS
 ELSE
  TRIM_0F00:
    DEFS $0F00-TRIM_0F00
 ENDIF
ENDIF

; Routine at 3846
K_L0F06:
  LD A,($FBEB)				; KBD ROW #6
  RRCA
  LD A,$0C
  SBC A,$00
  JR K_L0F46_1


  ; --- --- CODE CAN BE RELOCATED STARTING FROM HERE --- ---

; Routine at 3856
K_L0F10:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HKYEA			; Hook 1 for Keyboard decoder
ENDIF
  LD E,A
  LD D,$00
  ;LD HL,$1003
  LD HL,L1033-$30
  ADD HL,DE
  LD A,(HL)
  AND A
  RET Z
  JR K_L0F46_1

; Routine at 3871
L0F1F:
  LD A,($FBEB)				; KBD ROW #6
  LD E,A
  OR $FE
  BIT 4,E
  JR NZ,L0F1F_0
  AND $FD
L0F1F_0:
  CPL
  INC A
  LD (KANAST),A
  JR K_L0F46_2
  
  NOP
  NOP
  NOP

; Routine at 3893
L0F35:
  RET

; Routine at 3894
K_CAPS:
  LD HL,CAPST			;  "capital status" flag, ( 00# = Off / FF# = On )
  LD A,(HL)
  CPL
  LD (HL),A
  CPL
; This entry point is used by the routine at CHGCAP.
_CHGCAP:
  AND A
  LD A,$0C
  JR Z,K_CAPS_1
  INC A
K_CAPS_1:
  OUT (PPI_MOUT),A
  RET

; Routine at 3910
K_L0F46:
  LD A,($FBEB)				; KBD ROW #6
  RRCA
  RRCA
  LD A,$03
  JR NC,K_L0F46_0
  INC A
K_L0F46_0:
  LD (INTFLG),A
  JR C,K_L0F46_2
; This entry point is used by the routines at K_L0F06, K_L0F10 and L0FD0.
K_L0F46_1:
  LD HL,(PUTPNT)
  LD (HL),A
  CALL L105A+1
  LD A,(GETPNT)
  CP L
  RET Z
  LD (PUTPNT),HL
; This entry point is used by the routine at L0F1F.
K_L0F46_2:
  LD A,(CLIKSW)
  AND A
  RET Z
  LD A,(CLIKFL)
  AND A
  RET NZ
  LD A,$0F				; KBD click ?
  LD (CLIKFL),A
  OUT (PPI_MOUT),A
  LD A,$0A				; KBD click ?
K_L0F46_3:
  DEC A
  JR NZ,K_L0F46_3
; This entry point is used by the routine at CHGSND.
_CHGSND:
  AND A
  LD A,$0E
  JR Z,_CHGSND_0
  INC A
_CHGSND_0:
  OUT (PPI_MOUT),A
  RET


K_L0F83:
  LD A,($FBEB)			; KBD ROW #6
  LD E,A
  RRA
  RRA
  PUSH AF
  LD A,E
  CPL
  JR NC,K_L0F83_0
  RRA
  RRA
  RLCA
  AND $03
  BIT 1,A
  JR NZ,GET_KSYM
  BIT 4,E
  JR NZ,GET_KSYM
  OR $04
  DEFB 17	; "LD DE,nn" to jump over the next word without executing it
K_L0F83_0:
  AND  $01

GET_KSYM:
  LD E,A
  ADD A,A
  ADD A,E
  ADD A,A
  ADD A,A
  ADD A,A
  ADD A,A
  LD E,A
  LD D,$00
  LD HL,KEYMAP		; Keyboard map ?
  ADD HL,DE
  LD B,D
  ADD HL,BC
  POP AF
  LD A,(HL)
  INC A
  JP Z,L0F1F
  DEC A
  RET Z
  JR C,L0FD0
  AND $DF		; TK_SPC ?
  SUB $40		; '@'
  CP ' '
  RET NC
L0FC1:
  JR  K_L0F46_1


  
; Routine at 4035
K_L0FC3:
  LD A,($FBEB)				; KBD ROW #6
  RRCA
  JR C,K_L0FC3_0
  LD A,C
  ADD A,$05
  LD C,A
K_L0FC3_0:
  JP L0EC5

; Routine at 4048
L0FD0:
  CP ' '
  JR NC,L0FDF
  PUSH AF
  LD A,$01
  CALL K_L0F46_1
  POP AF
  ADD A,'A'-1
  JR L0FC1

; Routine at 4063
;
; Used by the routine at L0FD0.
L0FDF:
  LD HL,CAPST         ; "capital status" flag
  INC (HL)
  DEC (HL)
  JR Z,L0FDF_0
  CP 'a'              ; Less than "a" ?
  JR C,SEARCH         ; Yes - search for words
  CP 'z'+1            ; Greater than "z" ?
  JR NC,SEARCH        ; Yes - search for words
  AND $DF		; TK_SPC ?
L0FDF_0:
  LD DE,(KANAST)
  INC E
  DEC E
  JR Z,L0FC1
  LD D,A
  OR $20
  LD HL,L1066
  LD C,$06
  CPDR
L1003:
  LD A,D
  JR NZ,L0FC1
  INC HL
  LD C,$06
L1008:
  ADD HL,BC
  DEC E
  JR NZ,L1008
  LD A,(HL)
  BIT 5,D
  JR NZ,L0FC1
SEARCH:
  LD C,$1F	; 31
  LD HL,L109D
  CPDR
  JR NZ,L0FC1
  LD C,$1F
  INC HL
  ADD HL,BC
  LD A,(HL)
  JR L0FC1

; Routine at 4129
;
; Used by the routine at L0D89.
SCAN_KEYBOARD:
  LD A,C
  LD HL,L1B96
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HKEYC			; Hook 2 for Keyboard decoder
ENDIF
  LD D,$0F
SCAN_KEYBOARD_0:
  CP (HL)
  INC HL
  LD E,(HL)
  INC HL
  PUSH DE
  RET C
  POP DE
  JR SCAN_KEYBOARD_0

  
;- Example of European Keyboard Layout
;FBE5 0  => 7    6   5   4   3   2   1   0
;FBE6 1  => ;    ]   [   \   =   -   9   8
;FBE7 2  => B    A   ACCENT /   .   ,   `   '
;FBE8 3  => J    I   H   G   F   E   D   C
;FBE9 4  => R    Q   P   O   N   M   L   K
;FBEA 5  => Z    Y   X   W   V   U   T   S
;FBEB 6  => F3   F2  F1  CODE   CAPS   GRPH   CTRL   SHIFT
;FBEC 7  => RET  SEL    BS  STOP   TAB    ESC    F5  F4
;FBED 8  => RIGHT   DOWN   UP  LEFT   DEL    INS    HOME   SPACE
;FBEE 9  => 4    3   2   1   0    /   +   *
;FBEF 10 => .   ,   -   9   8   7   6   5
  
  
; Keyboard map
L1033:
  DEFB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00

; Routine at 4157
L103D:
  DEFB $1b,$09,$00,$08
  
L1041:
  DEFB $18,$0d

; Data block at 4163
L1043:
  DEFB $20,$0C,$12,$7F,$1D,$1E,$1F,$1C
  DEFB $00,$00,$00

; Message at 4174
L104E:
  DEFM "0123456789"

; Routine at 4184
L1058:
  DEC L
  INC L
  
L105A:
	;L105A+1:  XOR A
  LD L,$AF
  LD (KANAST),A
  JR CK_CTLX

; Message at 4193

L1061:
  DEFM "aeiou"

L1066:  
  DEFB $79,$85,$8A,$8D,$95,$97
  DEFB $79,$A0,$82,$A1,$A2,$A3
  DEFB $79,$83,$88,$8C,$93,$96
  DEFB $79,$84,$89,$8B,$94,$81
  DEFB $98,$83,$88,$8C,$93,$96
  DEFB $84,$89,$8B,$94,$81,$98
  DEFB $A0,$82,$A1,$A2,$A3,$85
  DEFB $8A,$8D,$95,$97,$B1,$B3
  DEFB $B5,$B7,$A4,$86,$87,$91
  DEFB $B9
  
  

; Message at 4253
L109D:
  DEFB $79
  DEFM "AEIOU"
  DEFB $8E
  DEFM "EI"
  DEFB $99
  DEFB $9A
  DEFM "YA"
  DEFB $90
  DEFM "IOUAEIOU"
  DEFB $B0,$B2,$B4,$B6,$A5,$8F,$80,$92
  DEFB $B8,$59,$00,$00,$00,$00,$00
  
  ; --- START PROC CK_CTLX ---
CK_CTLX:
  INC HL
  LD A,L
  CP $18		; CTL-X ?
  RET NZ
  LD HL,KEYBUF
  RET

		
; Routine at 4299
;
; Used by the routines at CHGET and _QINLIN.
_CHGET:
  PUSH HL
  PUSH DE
  PUSH BC
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HCHGE			; Hook for CHGET  std routine
ENDIF
  CALL _CHSNS
  JR NZ,_CHGET_1
  CALL L09DA
_CHGET_0:
  CALL _CHSNS
  JR Z,_CHGET_0
  CALL L0A27
_CHGET_1:
  LD HL,INTFLG
  LD A,(HL)
  CP $04
  JR NZ,_CHGET_2
  LD (HL),$00
_CHGET_2:
  LD HL,(GETPNT)
  LD C,(HL)
  CALL CK_CTLX
  LD (GETPNT),HL
  LD A,C
  JP _CHPUT_1

; Routine at 4345
;
; Used by the routine at CKCNTC.
_CKCNTC:
  PUSH HL
  LD HL,$0000
  CALL _ISCNTC
  POP HL
  RET

; Routine at 4354
;
; Used by the routines at WRTPSG, _INITIO, _BEEP, L113B, L1181 and L11B0.
_WRTPSG:
  DI
  OUT (PSG_ADDR),A
  PUSH AF
  LD A,E
  OUT (PSG_DATA),A
  EI
  POP AF
  RET

; Routine at 4364
;
; Used by the routines at _INITIO, _GTSTCK_3, _GTPAD, GTPAD_SUB3 and GTPAD_SUB4.
L110C:
  LD A,$0E
; This entry point is used by the routines at RDPSG, _GTSTCK_2, _GTPDL and _GTPAD.
_RDPSG:
  OUT (PSG_ADDR),A
  IN A,(PSG_DATAIN)
  RET

; Routine at 4371
;
; Used by the routine at BEEP.
_BEEP:
  XOR A
  LD E,$55
  CALL _WRTPSG
  LD E,A
  INC A
  CALL _WRTPSG
  LD E,$BE
  LD A,$07
  CALL _WRTPSG
  LD E,A
  INC A
  CALL _WRTPSG
  LD BC,2000
  CALL BEEP_DELAY
  JP _GICINI

; Routine at 4403
;
; Used by the routine at _BEEP.
BEEP_DELAY:
  DEC BC
  EX (SP),HL
  EX (SP),HL
  LD A,B
  OR C
  JR NZ,BEEP_DELAY
  RET

; Routine at 4411
L113B:
  LD B,A
  CALL _GETVCP	; Returns pointer to play queue
  DEC HL
  LD D,(HL)
  DEC HL
  LD E,(HL)
  DEC DE
  LD (HL),E
  INC HL
  LD (HL),D
  LD A,D
  OR E
  RET NZ
  LD A,B
  LD (QUEUEN),A
  CALL L11E2
  CP $FF
  JR Z,L11B0
  LD D,A
  AND $E0
  RLCA
  RLCA
  RLCA
  LD C,A
  LD A,D
  AND $1F
  LD (HL),A
  CALL L11E2
  DEC HL
  LD (HL),A
  INC C
; This entry point is used by the routine at L1181.
L113B_0:
  DEC C
  RET Z
  CALL L11E2
  LD D,A
  AND $C0
  JR NZ,L1181
  CALL L11E2
  LD E,A
  LD A,B
  RLCA
  CALL _WRTPSG
  INC A
  LD E,D
  CALL _WRTPSG
  DEC C
  JR L113B_0

; Routine at 4481
;
; Used by the routine at L113B.
L1181:
  LD H,A
  AND $80
  JR Z,L1181_0
  LD E,D
  LD A,B
  ADD A,$08
  CALL _WRTPSG
  LD A,E
  AND $10
  LD A,$0D
  CALL NZ,_WRTPSG
L1181_0:
  LD A,H
  AND $40
  JR Z,L113B_0
  CALL L11E2
  LD D,A
  CALL L11E2
  LD E,A
  LD A,$0B
  CALL _WRTPSG
  INC A
  LD E,D
  CALL _WRTPSG
  DEC C
  DEC C
  JR L113B_0

; Routine at 4528
;
; Used by the routine at L113B.
L11B0:
  LD A,B
  ADD A,$08
  LD E,$00
  CALL _WRTPSG
  INC B
  LD HL,MUSICF
  XOR A
  SCF
L11B0_0:
  RLA
  DJNZ L11B0_0
  AND (HL)
  XOR (HL)
  LD (HL),A
; This entry point is used by the routine at STRTMS.
_STRTMS:
  LD A,(MUSICF)
  OR A
  RET NZ
  LD HL,PLYCNT
  LD A,(HL)
  OR A
  RET Z
  DEC (HL)
  LD HL,$0001
  LD (VCBA),HL
  LD (VCBB),HL
  LD (VCBC),HL
  LD A,$07
  LD (MUSICF),A
  RET

; Routine at 4578
;
; Used by the routines at L113B and L1181.
L11E2:
  LD A,(QUEUEN)
  PUSH HL
  PUSH DE
  PUSH BC
  CALL L14AD
  JP _CHPUT_1

; Routine at 4590
;
; Used by the routine at GTSTCK.
_GTSTCK:
  DEC A
  JP M,_GTSTCK_1
  CALL _GTSTCK_2
  LD HL,STICK0_MAP
_GTSTCK_0:
  AND $0F
  LD E,A
  LD D,$00
  ADD HL,DE
  LD A,(HL)
  RET

_GTSTCK_1:
  CALL _GTSTCK_5
  RRCA
  RRCA
  RRCA
  RRCA
  LD HL,STICK1_MAP
  JR _GTSTCK_0


; Routine at 4620
;
; Used by the routines at _KEYINT, _GTSTCK and _GTTRIG.
_GTSTCK_2:
  LD B,A
  LD A,$0F
  DI
  CALL _RDPSG
  DJNZ _GTSTCK_3
  AND $DF
  OR $4C
  JR _GTSTCK_4

; Routine at 4635
;
; Used by the routine at _GTSTCK_2.
_GTSTCK_3:
  AND $AF
  OR $03
; This entry point is used by the routine at _GTSTCK_2.
_GTSTCK_4:
  OUT (PSG_DATA),A
  CALL L110C
  EI
  RET

; Routine at 4646
;
; Used by the routines at _KEYINT and _GTTRIG_3.
_GTSTCK_5:
  DI
  IN A,(PPI_C)
  AND $F0
  ADD A,$08
  OUT (PPI_COUT),A
  IN A,(PPI_B)
  EI
  RET
  
STICK0_MAP:
  DEFB $00,$05,$01,$00,$03,$04,$02,$03
  DEFB $07,$06,$08,$07,$00,$05,$01,$00

STICK1_MAP:
  DEFB $00,$03,$05,$04,$01,$02,$00,$03
  DEFB $07,$00,$06,$05,$08,$01,$07,$00


; This entry point is used by the routine at GTTRIG.
  ; --- START PROC L1253 ---
_GTTRIG:
  DEC A
  JP M,_GTTRIG_3
  PUSH AF
  AND $01
  CALL _GTSTCK_2
  POP BC
  DEC B
  DEC B
  LD B,$10
  JP M,_GTTRIG_1
  LD B,$20
_GTTRIG_1:
  AND B
; This entry point is used by the routine at _GTTRIG_3.
_GTTRIG_2:
  SUB $01
  SBC A,A
  RET

; Routine at 4716
;
; Used by the routine at _GTTRIG.
_GTTRIG_3:
  CALL _GTSTCK_5
  AND $01
  JR _GTTRIG_2

; Routine at 4723
;
; Used by the routine at GTPDL.
_GTPDL:
  INC A
  AND A
  RRA
  PUSH AF
  LD B,A
  XOR A
  SCF
_GTPDL_0:
  RLA
  DJNZ _GTPDL_0
  LD B,A
  POP AF
  LD C,$10
  LD DE,$03AF	; MSK=$AF,  OR=$03
  JR NC,_GTPDL_1
  LD C,$20
  LD DE,$4C9F	; MSK=$9F,  OR=$4C
_GTPDL_1:
  LD A,$0F
  DI
  CALL _RDPSG
  AND E
  OR D
  OR C
  OUT (PSG_DATA),A
  XOR C
  OUT (PSG_DATA),A
  LD A,$0E
  OUT (PSG_ADDR),A
  LD C,$00
_GTPDL_2:
  IN A,(PSG_DATAIN)
  AND B
  JR Z,_GTPDL_3
  INC C
  JP NZ,_GTPDL_2
  DEC C
_GTPDL_3:
  EI
  LD A,C
  RET

; Routine at 4780
;
; Used by the routine at GTPAD.
; Check the current touch PAD status.
_GTPAD:
  CP $04
  LD DE,$0CEC
  JR C,_GTPAD_0
  LD DE,$03D3
  SUB $04
_GTPAD_0:
  DEC A
  JP M,_GTPAD_1
  DEC A
  LD A,(PADX)
  RET M
  LD A,(PADY)
  RET Z
_GTPAD_1:
  PUSH AF
  EX DE,HL
  LD (FILNAM),HL
  SBC A,A
  CPL
  AND $40
  LD C,A
  LD A,$0F
  DI
  CALL _RDPSG
  AND $BF
  OR C
  OUT (PSG_DATA),A
  POP AF
  JP M,GTPAD_SUB
  CALL L110C
  EI
  AND $08
  SUB $01
  SBC A,A
  RET

; Routine at 4840
;
; Used by the routine at _GTPAD.
GTPAD_SUB:
  LD C,$00
  CALL GTPAD_SUB3
  CALL GTPAD_SUB3
  JR C,GTPAD_SUB_2
  CALL GTPAD_SUB2
  JR C,GTPAD_SUB_2
  PUSH DE
  CALL GTPAD_SUB2
  POP BC
  JR C,GTPAD_SUB_2
  LD A,B
  SUB D
  JR NC,GTPAD_SUB_0
  CPL
  INC A
GTPAD_SUB_0:
  CP $05
  JR NC,GTPAD_SUB
  LD A,C
  SUB E
  JR NC,GTPAD_SUB_1
  CPL
  INC A
GTPAD_SUB_1:
  CP $05
  JR NC,GTPAD_SUB
  LD A,D
  LD (PADX),A
  LD A,E
  LD (PADY),A
GTPAD_SUB_2:
  EI
  LD A,H
  SUB $01
  SBC A,A
  RET

; Routine at 4896
;
; Used by the routine at GTPAD_SUB.
GTPAD_SUB2:
  LD C,$0A
  CALL GTPAD_SUB3
  RET C
  LD D,L
  PUSH DE
  LD C,$00
  CALL GTPAD_SUB3
  POP DE
  LD E,L
  XOR A
  LD H,A
  RET

; Routine at 4914
;
; Used by the routines at GTPAD_SUB and GTPAD_SUB2.
GTPAD_SUB3:
  CALL GTPAD_SUB4
  LD B,$08
  LD D,C
GTPAD_SUB3_0:
  RES 0,D
  RES 2,D
  CALL GTPAD_SUB4_1
  CALL L110C
  LD H,A
  RRA
  RRA
  RRA
  RL L
  SET 0,D
  SET 2,D
  CALL GTPAD_SUB4_1
  DJNZ GTPAD_SUB3_0
  SET 4,D
  SET 5,D
  CALL GTPAD_SUB4_1
  LD A,H
  RRA
  RET

; Routine at 4955
;
; Used by the routine at GTPAD_SUB3.
GTPAD_SUB4:
  LD A,$35
  OR C
  LD D,A
  CALL GTPAD_SUB4_1
GTPAD_SUB4_0:
  CALL L110C
  AND $02
  JR Z,GTPAD_SUB4_0
  RES 4,D
  RES 5,D
; This entry point is used by the routine at GTPAD_SUB3.
GTPAD_SUB4_1:
  PUSH HL
  PUSH DE
  LD HL,(FILNAM)
  LD A,L
  CPL
  AND D
  LD D,A
  LD A,$0F
  OUT (PSG_ADDR),A
  IN A,(PSG_DATAIN)
  AND L
  OR D
  OR H
  OUT (PSG_DATA),A
  POP DE
  POP HL
  RET


; Routine at 4996
;
; Used by the routine at STMOTR.
_STMOTR:
  AND A
  JP M,_STMOTR_2

_STMOTR_0:
  JR NZ,_STMOTR_1+1
  LD A,9		; MOTOR OFF
  
_STMOTR_1:
	; L183C+1: LD A,8
  defb $C2	; JP NZ,NN (always false), masks the next 2 bytes
  LD A,8		; MOTOR ON
  OUT (PPI_MOUT),A
  RET

; Routine at 5010
; Used by the routine at _STMOTR.
_STMOTR_2:
  IN A,(PPI_C)
  AND $10
  JR _STMOTR_0


; Routine at 5016
;
; Used by the routine at NMI.
_NMI:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HNMI		; Hook for NMI std routine
ENDIF
  RETN


; a.k.a. RSTFNK  
; This entry point is used by the routine at INIFNK.
_INIFNK:
  LD BC,$00A0		; 160
  LD DE,FNKSTR
  LD HL,FNKTAB
  LDIR
  RET


; Message at 5033
FNKTAB:
  DEFM "color "

; Data block at 5039
L13AF:
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00

; Message at 5049
L13B9:
  DEFM "auto "

; Data block at 5054
L13BE:
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00

; Message at 5065
L13C9:
  DEFM "goto "

; Data block at 5070
L13CE:
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00

; Message at 5081
L13D9:
  DEFM "list "

; Data block at 5086
L13DE:
  DEFB $00,$00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00

; Message at 5097
L13E9:
  DEFM "run"
  DEFB CR

  DEFB $00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00,$00

; Message at 5113
L13F9:
  DEFM "color 15,4,4"
  DEFB CR

  DEFB $00
  DEFB $00
  DEFB $00
  DEFM "cload"
  DEFB '"'
  DEFB $00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00

; Message at 5145
L1419:
  DEFM "cont"
  DEFB CR

; Data block at 5149
L141E:
  DEFB $00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00

; Message at 5161
L1429:
  DEFM "list."
  DEFB CR

; Data block at 5166
L142F:
  DEFB $1E,$1E,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$0C

; Message at 5178
L143A:
  DEFM "run"
  DEFB CR

L143E:
  DEFB $00,$00,$00,$00,$00,$00,$00
  DEFB $00,$00,$00,$00


_RDVDP:
  IN A,(VDP_STATUS)
  RET

; Routine at 5196
;
; Used by the routine at RSLREG.
_RSLREG:
  IN A,(PPI_A)
  RET

; Routine at 5199
;
; Used by the routine at WSLREG.
_WSLREG:
  OUT (PPI_AOUT),A
  RET

; Routine at 5202
;
; Used by the routine at SNSMAT.
_SNSMAT:
  LD C,A
  DI
  IN A,(PPI_C)
  AND $F0
  ADD A,C
  OUT (PPI_COUT),A
  IN A,(PPI_B)
  EI
  RET

; Routine at 5215
;
; Used by the routines at ISFLIO and _OUTDO.
_ISFLIO:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HISFL			; Hook for ISFLIO std routine
ENDIF
  PUSH HL               ;Save text pointer
  LD HL,(PTRFIL)        ;See if 'disk file'
  LD A,L
  OR H
  POP HL
  RET

; Routine at 5226
;
; Used by the routine at DCOMPR.
CPDEHL:
  LD A,H
  SUB D
  RET NZ
  LD A,L
  SUB E
  RET

; Routine at 5232
;
; Used by the routines at GETVCP and L113B.
; Returns pointer to play queue
_GETVCP:
  LD L,$02
  JR _GETVC2_0

; Routine at 5236
;
; Used by the routine at GETVC2.
_GETVC2:
  LD A,(VOICEN)
; This entry point is used by the routines at _INITIO and _GETVCP.
_GETVC2_0:
  PUSH DE
  LD DE,VCBA
  LD H,$00
  ADD HL,DE
  OR A
  JR Z,_GETVC2_2
  LD DE,$0025
_GETVC2_1:
  ADD HL,DE
  DEC A
  JR NZ,_GETVC2_1
_GETVC2_2:
  POP DE
  RET

; Routine at 5258
;
; Used by the routine at PHYDIO.
_PHYDIO:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HPHYD		; Hook for PHYDIO std routine
ENDIF
  RET

; Routine at 5262
;
; Used by the routine at FORMAT.
_FORMAT:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HFORM		; Hook for FORMAT std routine
ENDIF
  RET


;PUTQ - append data to back of queue
;
; Routine at 5266
; Used by the routine at PUTQ.
; Put byte in queue
_PUTQ:
  CALL QUE_BCA		; IN: A= QUEUE#, OUT: BCA = first three bytes of the given QUEUE
  LD A,B
  INC A
  INC HL
  AND (HL)
  CP C
  RET Z
  PUSH HL
  DEC HL
  DEC HL
  DEC HL
  EX (SP),HL
  INC HL
  LD C,A
  LD A,(HL)
  INC HL
  LD H,(HL)
  LD L,A
  LD B,$00
  ADD HL,BC
  LD (HL),E
  POP HL
  LD (HL),C
  RET

; Routine at 5293
;
; Used by the routine at L11E2.
L14AD:
  CALL QUE_BCA		; IN: A= QUEUE#, OUT: BCA = first three bytes of the given QUEUE
  LD (HL),$00
  JR NZ,L14D1	; QUEBAK+A
  LD A,C
  CP B
  RET Z
  INC HL
  INC A
  AND (HL)
  DEC HL
  DEC HL
  PUSH HL
  INC HL
  INC HL
  INC HL
  LD C,A
  LD A,(HL)
  INC HL
  LD H,(HL)
  LD L,A
  LD B,$00
  ADD HL,BC
  LD A,(HL)
  POP HL
  LD (HL),C
  OR A
  RET NZ
  INC A
  LD A,$00
  RET

; Routine at 5329
;
; Used by the routine at L14AD.
L14D1:
  LD C,A
  LD B,$00
  LD HL,QUEBAK-1
  ADD HL,BC
  LD A,(HL)
  RET

; Routine at 5338
;
; Used by the routine at _INITIO.
L14DA:
  PUSH BC
  CALL QUEADDR		; HL = address for queue in A
  LD (HL),B
  INC HL
  LD (HL),B
  INC HL
  LD (HL),B
  INC HL
  POP AF
  LD (HL),A
  INC HL
  LD (HL),E
  INC HL
  LD (HL),D
  RET

; Routine at 5355
;
; Used by the routine at LFTQ.
; Gives number of bytes left in queue
_LFTQ:
  CALL QUE_BCA		; IN: A= QUEUE#, OUT: BCA = first three bytes of the given QUEUE
  LD A,B
  INC A
  INC HL
  AND (HL)
  LD B,A
  LD A,C
  SUB B
  AND (HL)
  LD L,A
  LD H,$00
  RET

; Routine at 5370
;
; Used by the routines at _PUTQ, L14AD and _LFTQ.
; IN: A= QUEUE#, OUT: BCA = first three bytes of the given QUEUE
QUE_BCA:
  CALL QUEADDR		; HL = address for queue in A
  LD B,(HL)
  INC HL
  LD C,(HL)
  INC HL
  LD A,(HL)
  OR A
  RET

; Routine at 5380
;
; Used by the routines at L14DA and QUE_BCA.
; HL = address for queue in A
QUEADDR:
  RLCA
  LD B,A
  RLCA
  ADD A,B
  LD C,A
  LD B,$00
  LD HL,(QUEUES)
  ADD HL,BC
  RET

; Data block at 5392
; $1510
_GRPPRT:
  PUSH HL
  PUSH DE
  PUSH BC
  PUSH AF
  ; --- START PROC L1514 ---
L1514:
  CALL _SNVCHR
  JR NC,L157B
  JR NZ,_GRPPRT_00
  CP CR
  JR Z,L157E
  CP ' '
  JR C,L157B 

; Routine at 5411
_GRPPRT_00:
  CALL L0752
  LD A,(FORCLR)
  LD (ATRBYT),A
  LD HL,(GRPACY)
  EX DE,HL
  LD BC,(GRPACX)
  CALL _SCALXY
  JR NC,L157B
  CALL _MAPXY
  LD DE,PATWRK
  LD C,$08
_GRPPRT_0:
  LD B,$08
  CALL _FETCHC		; Save cursor
  PUSH HL
  PUSH AF
  LD A,(DE)
_GRPPRT_1:
  ADD A,A
  PUSH AF
  CALL C,_SETC		; Update current screenpixel of specified attribute byte
  CALL L16AC
  POP HL
  JR C,_GRPPRT_2
  PUSH HL
  POP AF
  DJNZ _GRPPRT_1
_GRPPRT_2:
  POP AF
  POP HL
  CALL _STOREC		; Restore cursor
  CALL _TDOWNC
  JR C,_GRPPRT_3
  INC DE
  DEC C
  JR NZ,_GRPPRT_0
_GRPPRT_3:
  CALL IN_GRP_MODE       ; Z if GRP (high resolution screen with 256×192 pixels)
  LD A,(GRPACX)
  JR Z,_GRPPRT_4
  ADD A,$20
  JR C,L157E
  JR _GRPPRT_5

; Routine at 5492
;
; Used by the routine at _GRPPRT.
_GRPPRT_4:
  ADD A,$08
  JR C,L157E
; This entry point is used by the routine at _GRPPRT.
_GRPPRT_5:
  LD (GRPACX),A
; This entry point is used by the routines at _GRPPRT and L157E.
L157B:
  JP _POPALL

; Routine at 5502
;
; Used by the routines at _GRPPRT and _GRPPRT_4.
L157E:
  XOR A
  LD (GRPACX),A
  CALL IN_GRP_MODE       ; Z if GRP (high resolution screen with 256×192 pixels)
  LD A,(GRPACY)
  JR Z,L158D
  ADD A,$20
  DEFB $01	; "LD BC,nn" to jump over the next word without executing it
L158D:
  ADD A,8
  
  CP $C0
  JR C,L157E_0
  XOR A
L157E_0:
  LD (GRPACY),A
  JR L157B

; Routine at 5529
;
; Used by the routines at SCALXY and _GRPPRT.
_SCALXY:
  PUSH HL
  PUSH BC
  LD B,$01
  EX DE,HL
  LD A,H
  ADD A,A
  JR NC,_SCALXY_1
  LD HL,$0000
  JR _SCALXY_2

_SCALXY_1:
  LD DE,192
  RST DCOMPR		; Compare HL with DE.
  JR C,_SCALXY_3
  EX DE,HL
  DEC HL

_SCALXY_2:
  LD B,$00
_SCALXY_3:
  EX (SP),HL
  LD A,H
  ADD A,A
  JR NC,_SCALXY_4
  LD HL,$0000
  JR _SCALXY_5

_SCALXY_4:
  LD DE,256
  RST DCOMPR		; Compare HL with DE.
  JR C,_SCALXY_6
  EX DE,HL
  DEC HL

_SCALXY_5:
  LD B,$00
_SCALXY_6:
  POP DE
  CALL IN_GRP_MODE       ; Z if GRP (high resolution screen with 256×192 pixels)
  JR Z,_SCALXY_7
  SRL L
  SRL L
  SRL E
  SRL E
_SCALXY_7:
  LD A,B
  RRCA
  LD B,H
  LD C,L
  POP HL
  RET

; Routine at 5593
;
; Used by the routines at _GRPPRT, L157E, _SCALXY_4, _MAPXY, _SETC, L16AC, _RIGHTC,
; L16D8, _LEFTC, _TDOWNC, _DOWNC, _TUPC, _UPC, _NSETCX, _PNTINI and _SCANL.
; Z if GRP (high resolution screen with 256×192 pixels)
IN_GRP_MODE:
  LD A,(SCRMOD)
  SUB $02
  RET

; Routine at 5599
;
; Used by the routines at MAPXY and _GRPPRT.
_MAPXY:
  PUSH BC
  CALL IN_GRP_MODE       ; Z if GRP (high resolution screen with 256×192 pixels)
  JR NZ,_MAPXY_1
  LD D,C
  LD A,C
  AND $07
  LD C,A
  LD HL,_MAPXY_0
  ADD HL,BC
  LD A,(HL)
  LD (CMASK),A
  LD A,E
  RRCA
  RRCA
  RRCA
  AND $1F
  LD B,A
  LD A,D
  AND $F8
  LD C,A
  LD A,E
  AND $07
  OR C
  LD C,A
  LD HL,(GRPCGP)
  ADD HL,BC
  LD (CLOC),HL
  POP BC
  RET

_MAPXY_0:
  ADD A,B
  LD B,B
  JR NZ,_MAPXY_3
  EX AF,AF'
  INC B
  LD (BC),A

  DEFB $01	; "LD BC,nn" to jump over the next word without executing it

_MAPXY_1:
  LD A,C
  RRCA

  LD A,$F0			; Mask and keep the left nibble
  JR NC,EVEN_BYTE		
  LD A,$0F			; Mask and keep the righe nibble
EVEN_BYTE:
  LD (CMASK),A

  LD A,C
_MAPXY_3:
  ADD A,A
  ADD A,A
  AND $F8
  LD C,A
  LD A,E
  AND $07
  OR C
  LD C,A
  LD A,E
  RRCA
  RRCA
  RRCA
  AND $07
  LD B,A
  LD HL,(MLTCGP)		; SCREEN 3 character pattern table
  ADD HL,BC
  LD (CLOC),HL
  POP BC
  RET

; Routine at 5689
;
; Used by the routines at FETCHC, _STOREC, _GRPPRT, _SETC, L16AC, _RIGHTC, L16D8, _LEFTC,
; L1779, RIGHTC_MLT, L179C, LEFTC_MLT, _NSETCX, L190C, L192D and L1963.
;
; Gets current "graphics cursor" position and mask pattern
_FETCHC:
  LD A,(CMASK)
  LD HL,(CLOC)
  RET

; Routine at 5696
;
; Used by the routines at STOREC, _GRPPRT and L192D.
; Record current "graphics cursor" position and mask pattern
;
_STOREC:
  LD (CMASK),A
  LD (CLOC),HL
  RET

; Data block at 5703
  ; --- START PROC L1647 ---
_READC:
  PUSH BC
  PUSH HL
  CALL _FETCHC			; Gets current cursor position and mask pattern
  LD B,A
  CALL IN_GRP_MODE       ; Z if GRP (high resolution screen with 256×192 pixels)
  JR NZ,L166C
  CALL _RDVRM
  AND B
  PUSH AF
  LD BC,$2000
  ADD HL,BC
  CALL _RDVRM
  LD B,A
  POP AF
  LD A,B
  JR Z,L1667
L1663:
  RRCA
  RRCA
  RRCA
  RRCA
L1667:
  AND $0F
  POP HL
  POP BC
  RET


; Routine at 5740
L166C:
  CALL _RDVRM
  INC B
  DEC B
  JP P,L1667
  JR L1663

; Routine at 5750
;
; Used by the routine at SETATR.
; Set attribute byte
_SETATR:
  CP $10
  CCF
  RET C
  LD (ATRBYT),A
  RET

; Routine at 5758
;
; Used by the routines at SETC, _GRPPRT, L18BB and L19C7.
_SETC:
  PUSH HL
  PUSH BC
  CALL IN_GRP_MODE       ; Z if GRP (high resolution screen with 256×192 pixels)
  CALL _FETCHC			; Get cursor statur
  JR NZ,_SETC_0
  PUSH DE
  CALL SETC_GFX
  POP DE
  POP BC
  POP HL
  RET

; Data block at 5776
_SETC_0:
  LD B,A
  CALL _RDVRM
  LD C,A
  LD A,B
  CPL
  AND C
  LD C,A
  LD A,(ATRBYT)
  INC B
  DEC B
  JP P,_SETC_1
  ADD A,A
  ADD A,A
  ADD A,A
  ADD A,A
_SETC_1:
  OR C
  CALL _WRTVRM
  POP BC
  POP HL
  RET


; Routine at 5804
;
; Used by the routines at _GRPPRT, L18F0, L190C, L1951 and L1963.
L16AC:
  PUSH HL
  CALL IN_GRP_MODE       ; Z if GRP (high resolution screen with 256×192 pixels)
  JP NZ,L1779
  CALL _FETCHC			; Gets current cursor position and mask pattern
  RRCA
  JR NC,LR_2
  LD A,L
  AND $F8
  CP $F8
  LD A,$80
  JR NZ,_RIGHTC_0
  JP _TUPC_1

; Routine at 5829
;
; Used by the routines at RIGHTC, L18BB, L199C and L19BA.
; Shifts screenpixel to the right

_RIGHTC:
  PUSH HL
  CALL IN_GRP_MODE       ; Z if GRP (high resolution screen with 256×192 pixels)
  JP NZ,RIGHTC_MLT
  CALL _FETCHC			; Gets current cursor position and mask pattern
  RRCA
  JR NC,LR_2
; This entry point is used by the routine at L16AC.
_RIGHTC_0:
  PUSH DE
  LD DE,$0008
  JR LR_1

; Routine at 5848
;
; Used by the routines at _SCANL and L19BA.
L16D8:
  PUSH HL
  CALL IN_GRP_MODE       ; Z if GRP (high resolution screen with 256×192 pixels)
  JP NZ,L179C
  CALL _FETCHC			; Gets current cursor position and mask pattern
  RLCA
  JR NC,LR_2
  LD A,L
  AND $F8
  LD A,$01
  JR NZ,LR_0
  JR _TUPC_1

; Routine at 5870
;
; Used by the routine at LEFTC.
_LEFTC:
  PUSH HL
  CALL IN_GRP_MODE       ; Z if GRP (high resolution screen with 256×192 pixels)
  JP NZ,LEFTC_MLT
  CALL _FETCHC			; Gets current cursor position and mask pattern
  RLCA
  JR NC,LR_2
  
; This entry point is used by the routine at L16D8.
LR_0:
  PUSH DE
  LD DE,$FFF8		; -8
; This entry point is used by the routine at _RIGHTC.
LR_1:
  ADD HL,DE
  LD (CLOC),HL
  POP DE
; This entry point is used by the routines at L16AC, _RIGHTC and L16D8.
LR_2:
  LD (CMASK),A
  AND A
  POP HL
  RET

; Routine at 5898
;
; Used by the routines at TDOWNC and _GRPPRT.
_TDOWNC:
  PUSH HL
  PUSH DE
  LD HL,(CLOC)
  CALL IN_GRP_MODE       ; Z if GRP (high resolution screen with 256×192 pixels)
  JP NZ,TDOWNC_MLT
  PUSH HL
  LD HL,(GRPCGP)		; SCREEN 2 character pattern table
  LD DE,$1700
  ADD HL,DE
  EX DE,HL
  POP HL
  RST DCOMPR		; Compare HL with DE.
  JR C,_DOWNC_0
  LD A,L
  INC A
  AND $07
  JR NZ,_DOWNC_0
  JR _TUPC_0

; Routine at 5930
;
; Used by the routine at DOWNC.
_DOWNC:
  PUSH HL
  PUSH DE
  LD HL,(CLOC)
  CALL IN_GRP_MODE       ; Z if GRP (high resolution screen with 256×192 pixels)
  JP NZ,DOWNC_MLT
; This entry point is used by the routine at _TDOWNC.
_DOWNC_0:
  INC HL
  LD A,L
  LD DE,$00F8
  JR _UPC_1

; Routine at 5948
;
; Used by the routine at TUPC.
_TUPC:
  PUSH HL
  PUSH DE
  LD HL,(CLOC)
  CALL IN_GRP_MODE       ; Z if GRP (high resolution screen with 256×192 pixels)
  JP NZ,TUPC_MLT
  PUSH HL
  LD HL,(GRPCGP)         ; SCREEN 2 character pattern table
  LD DE,256
  ADD HL,DE
  EX DE,HL
  POP HL
  RST DCOMPR             ; Compare HL with DE.
  JR NC,_UPC_0
  LD A,L
  AND $07
  JR NZ,_UPC_0
; This entry point is used by the routine at _TDOWNC.
_TUPC_0:
  POP DE
; This entry point is used by the routines at L16AC, L16D8, L1779 and L179C.
_TUPC_1:
  SCF
  POP HL
  RET

; Routine at 5981
;
; Used by the routine at UPC.
_UPC:
  PUSH HL
  PUSH DE
  LD HL,(CLOC)
  CALL IN_GRP_MODE       ; Z if GRP (high resolution screen with 256×192 pixels)
  JP NZ,UPC_MLT
; This entry point is used by the routine at _TUPC.
_UPC_0:
  LD A,L
  DEC HL
  LD DE,$FF08		; -248
; This entry point is used by the routine at _DOWNC.
_UPC_1:
  AND $07
  JR NZ,_UPC_2
  ADD HL,DE
_UPC_2:
  LD (CLOC),HL
  AND A
  POP DE
  POP HL
  RET

; Routine at 6009
;
; Used by the routine at L16AC.
L1779:
  CALL _FETCHC			; Gets current cursor position and mask pattern
  AND A
  LD A,$0F				; Mask and keep the right nibble
  JP M,APPLY_MASK
  LD A,L
  AND $F8
  CP $F8
  JR NZ,RIGHTC_MLT_0
  JR _TUPC_1

; Routine at 6027
;
; Used by the routine at _RIGHTC.
RIGHTC_MLT:
  CALL _FETCHC			; Gets current cursor position and mask pattern
  AND A
  LD A,$0F				; Mask and keep the right nibble
  JP M,APPLY_MASK
; This entry point is used by the routine at L1779.
RIGHTC_MLT_0:
  PUSH DE
  LD DE,$0008
  LD A,$F0				; Mask and keep the lsft nibble
  JR LEFTC_MLT_1

; Routine at 6044
;
; Used by the routine at L16D8.
L179C:
  CALL _FETCHC			; Gets current cursor position and mask pattern
  AND A
  LD A,$F0				; Mask and keep the left nibble
  JP P,APPLY_MASK
  LD A,L
  AND $F8
  JR NZ,LEFTC_MLT_0
  JR _TUPC_1

; Routine at 6060
;
; Used by the routine at _LEFTC.
LEFTC_MLT:
  CALL _FETCHC			; Gets current cursor position and mask pattern
  AND A
  LD A,$F0				; Mask and keep the left nibble
  JP P,APPLY_MASK
; This entry point is used by the routine at L179C.
LEFTC_MLT_0:
  PUSH DE
  LD DE,$FFF8		; -8
  LD A,$0F				; Mask and keep the right nibble
; This entry point is used by the routine at RIGHTC_MLT.
LEFTC_MLT_1:
  ADD HL,DE
  LD (CLOC),HL
  POP DE
; This entry point is used by the routines at L1779, RIGHTC_MLT and L179C.
APPLY_MASK:
  LD (CMASK),A
  AND A
  POP HL
  RET

; Routine at 6086
;
; Used by the routine at _TDOWNC.
TDOWNC_MLT:
  PUSH HL
  LD HL,(MLTCGP)		; SCREEN 3 character pattern table
  LD DE,$0500			; 1280
  ADD HL,DE
  POP HL
  RST DCOMPR		; Compare HL with DE.
  JR C,DOWNC_MLT
  LD A,L
  INC A
  AND $07
  JR NZ,DOWNC_MLT
  SCF
  POP DE
  POP HL
  RET

; Routine at 6108
;
; Used by the routines at _DOWNC and TDOWNC_MLT.
DOWNC_MLT:
  INC HL
  LD A,L
  LD DE,$00F8
  JR UPC_MLT_0

; Routine at 6115
;
; Used by the routine at _TUPC.
TUPC_MLT:
  PUSH HL
  LD HL,(MLTCGP)		; SCREEN 3 character pattern table
  LD DE,256
  ADD HL,DE
  POP HL
  RST DCOMPR		; Compare HL with DE.
  JR NC,UPC_MLT
  LD A,L
  AND $07
  JR NZ,UPC_MLT
  SCF
  POP DE
  POP HL
  RET

; Routine at 6136
;
; Used by the routines at _UPC and TUPC_MLT.
UPC_MLT:
  LD A,L
  DEC HL
  LD DE,$FF08		; -248
; This entry point is used by the routine at DOWNC_MLT.
UPC_MLT_0:
  AND $07
  JR NZ,UPC_MLT_1
  ADD HL,DE
UPC_MLT_1:
  LD (CLOC),HL
  AND A
  POP DE
  POP HL
  RET

; Routine at 6153
;
; Used by the routines at NSETCX, L192D and L199C.
; Set horizontal screenpixels
;
_NSETCX:
  CALL IN_GRP_MODE       ; Z if GRP (high resolution screen with 256×192 pixels)
  JP NZ,_NSETCX_NOGRP
  PUSH HL
  CALL _FETCHC			; Gets current cursor position and mask pattern
  EX (SP),HL
  ADD A,A
  JR C,_NSETCX_1
  PUSH AF
  LD BC,-1
  RRCA
_NSETCX_0:
  ADD HL,BC
  JR NC,_NSETCX_4
  RRCA
  JR NC,_NSETCX_0
  POP AF
  DEC A
  EX (SP),HL
  PUSH HL
  CALL SETC_GFX
  POP HL
  LD DE,$0008
  ADD HL,DE
  EX (SP),HL
_NSETCX_1:
  LD A,L
  AND $07
  LD C,A
  LD A,H
  RRCA
  LD A,L
  RRA
  RRCA
  RRCA
  AND $3F
  POP HL
  LD B,A
  JR Z,_NSETCX_3
_NSETCX_2:
  XOR A
  CALL _WRTVRM
  LD DE,$2000
  ADD HL,DE
  LD A,(ATRBYT)
  CALL _WRTVRM
  LD DE,$2008
  ADD HL,DE
  DJNZ _NSETCX_2
_NSETCX_3:
  DEC C
  RET M
  PUSH HL
  LD HL,NSETCX_OFFSMAP
  ADD HL,BC
  LD A,(HL)
  JR _NSETCX_5

NSETCX_OFFSMAP:
  DEFB 10000000b
  DEFB 11000000b
  DEFB 11100000b
  DEFB 11110000b
  DEFB 11111000b
  DEFB 11111100b
  DEFB 11111110b

_NSETCX_4:
  ADD A,A
  DEC A
  CPL
  LD B,A
  POP AF
  DEC A
  AND B

  ; --- START PROC _NSETCX_5 ---
_NSETCX_5:
  POP HL


  ; --- START PROC SETC_GFX ---
SETC_GFX:
  LD B,A
  CALL _RDVRM
  LD C,A
  LD DE,$2000
  ADD HL,DE
  CALL _RDVRM
  PUSH AF
  AND $0F
  LD E,A
  POP AF
  SUB E
  LD D,A
  LD A,(ATRBYT)		; Attribute byte (for graphical routines it’s used to read the color) 
  CP E
  JR Z,SETC_GFX_1
  ADD A,A
  ADD A,A
  ADD A,A
  ADD A,A
  CP D
  JR Z,SETC_GFX_2
  PUSH AF
  LD A,B
  OR C
  CP $FF
  JR Z,SETC_GFX_4
  PUSH HL
  PUSH DE
  CALL SETC_GFX_2
  POP DE
  POP HL
  POP AF
  OR E
  JR SETC_GFX_5


; Routine at 6302
SETC_GFX_1:
  LD A,B
  CPL
  AND C

  DEFB $11              ; "LD DE,nn" to skip the next 2 instructions

SETC_GFX_2:
  LD A,B
  OR C

; This entry point is used by the routine at SETC_GFX_4.
SETC_GFX_3:
  LD DE,$2000
  ADD HL,DE
  JR SETC_GFX_5

; Routine at 6314
SETC_GFX_4:
  POP AF
  LD A,B
  CPL
  PUSH HL
  PUSH DE
  CALL SETC_GFX_3
  POP DE
  POP HL
  LD A,(ATRBYT)
  OR D
; This entry point is used by the routine at SETC_GFX_1.
SETC_GFX_5:
  JP _WRTVRM

; Routine at 6331
;
; Used by the routine at _NSETCX.
_NSETCX_NOGRP:
  PUSH HL
  CALL _SETC
  CALL _RIGHTC
  POP HL
  DEC L
  JR NZ,_NSETCX_NOGRP
  RET

; Routine at 6343
;
; Used by the routine at GTASPC.
_GTASPC:
  LD HL,(ASPCT1)
  EX DE,HL
  LD HL,(ASPCT2)
  RET

; Routine at 6351
;
; Used by the routine at GTASPC.
_PNTINI:
  PUSH AF
  CALL IN_GRP_MODE       ; Z if GRP (high resolution screen with 256×192 pixels)
  JR Z,L18DB
  POP AF
  CP $10
  CCF
  JR L18DB_0

; Routine at 6363
;
; Used by the routine at _PNTINI.
L18DB:
  POP AF
  LD A,(ATRBYT)
  AND A
; This entry point is used by the routine at _PNTINI.
L18DB_0:
  LD (BRDATR),A
  RET

  ; --- START PROC L18E4 ---
; Scans screenpixels to the right
_SCANR:
  LD HL,$0000
  LD C,L
  CALL IN_GRP_MODE       ; Z if GRP (high resolution screen with 256×192 pixels)
  JR NZ,L1951
  LD A,B
  LD (RUNFLG),A
  XOR A
  LD (FILNAM+3),A
  LD A,(BRDATR)
  LD B,A
_SCANR_0:
  CALL _READC
  CP B
  JR NZ,L190C
  DEC DE
  LD A,D
  OR E
  RET Z
  CALL L16AC
  JR NC,_SCANR_0
  LD DE,$0000
  RET

; Routine at 6412
;
; Used by the routine at _SCANR.
L190C:
  CALL L19AE
  PUSH DE
  CALL _FETCHC			; Gets current cursor position and mask pattern
  LD (CSAVEA),HL
  LD (CSAVEM),A
  LD DE,$0000
L190C_0:
  INC DE
  CALL L16AC
  JR C,L192D
  CALL _READC
  CP B
  JR Z,L192D
  CALL L19AE
  JR L190C_0

; Routine at 6445
;
; Used by the routine at L190C.
L192D:
  PUSH DE
  CALL _FETCHC		; Save cursor
  PUSH HL
  PUSH AF
  LD HL,(CSAVEA)
  LD A,(CSAVEM)
  CALL _STOREC		; Restore cursor
  EX DE,HL
  LD (FILNAM+1),HL
  LD A,(FILNAM)
  AND A
  CALL NZ,_NSETCX
  POP AF
  POP HL
  CALL _STOREC		; Restore cursor
  POP HL
  POP DE
  JP L199C_1

; Routine at 6481
L1951:
  CALL L19C7
  JR NC,L1963
  DEC DE
  LD A,D
  OR E
  RET Z
  CALL L16AC
  JR NC,L1951
  LD DE,$0000
  RET

; Routine at 6499
;
; Used by the routine at L1951.
L1963:
  CALL _FETCHC			; Gets current cursor position and mask pattern
  LD (CSAVEA),HL
  LD (CSAVEM),A
  LD HL,$0000
L1963_0:
  INC HL
  CALL L16AC
  RET C
  CALL L19C7
  JR NC,L1963_0
  RET

; Routine at 6522
;
; Used by the routine at GTASPC.
_SCANL:
  LD HL,$0000
  LD C,L
  CALL IN_GRP_MODE       ; Z if GRP (high resolution screen with 256×192 pixels)
  JR NZ,L19BA
  XOR A
  LD (FILNAM+3),A
  LD A,(BRDATR)
  LD B,A
_SCANL_0:
  CALL L16D8
  JR C,L199C_0
  CALL _READC
  CP B
  JR Z,L199C
  CALL L19AE
  INC HL
  JR _SCANL_0

; Routine at 6556
;
; Used by the routine at _SCANL.
L199C:
  CALL _RIGHTC
; This entry point is used by the routine at _SCANL.
L199C_0:
  PUSH HL
  LD DE,(FILNAM+1)
  ADD HL,DE
  CALL _NSETCX
  POP HL
; This entry point is used by the routine at L192D.
L199C_1:
  LD A,(FILNAM+3)
  LD C,A
  RET

; Routine at 6574
;
; Used by the routines at L190C and _SCANL.
L19AE:
  PUSH HL
  LD HL,ATRBYT
  CP (HL)
  POP HL
  RET Z
  INC A
  LD (FILNAM+3),A
  RET

; Routine at 6586
;
; Used by the routine at _SCANL.
L19BA:
  CALL L16D8
  RET C
  CALL L19C7
  JP C,_RIGHTC
  INC HL
  JR L19BA

; Routine at 6599
;
; Used by the routines at L1951, L1963 and L19BA.
L19C7:
  CALL _READC
  LD B,A
  LD A,(BRDATR)
  SUB B
  SCF
  RET Z
  LD A,(ATRBYT)
  CP B
  RET Z
  CALL _SETC
  LD C,$01
  AND A
  RET

; Routine at 6621
; a.k.a. CTWOFF
; Used by the routine at TAPOOF.
_TAPOOF:
  PUSH BC
  PUSH AF
  LD BC,$0000
_TAPOOF_0:
  DEC BC
  LD A,B
  OR C
  JR NZ,_TAPOOF_0
  POP AF
  POP BC

; a.k.a. CTOFF
; This entry point is used by the routine at TAPIOF.
_TAPIOF:
  PUSH AF
  LD A,$09
  OUT (PPI_MOUT),A
  POP AF
  EI
  RET

; Routine at 6641
;
; Used by the routine at TAPOON.
_TAPOON:
  OR A
  PUSH AF
  LD A,$08
  OUT (PPI_MOUT),A
  LD HL,$0000
_TAPOON_0:
  DEC HL
  LD A,H
  OR L
  JR NZ,_TAPOON_0
  POP AF
  LD A,(HEADER)
  JR Z,_TAPOON_1
  ADD A,A
  ADD A,A
_TAPOON_1:
  LD B,A
  LD C,$00
  DI
_TAPOON_2:
  CALL TAPSEND_HIGH
  CALL TAPSEND_RET
  DEC BC
  LD A,B
  OR C
  JR NZ,_TAPOON_2
  JP _BREAKX		; Set CY if STOP is pressed

; Routine at 6681
;
; Used by the routine at TAPOUT.
_TAPOUT:
  LD HL,(LOW)
  PUSH AF
  LD A,L
  SUB $0E
  LD L,A
  ; start bit (HL=LOW)
  CALL TAPSEND_0
  POP AF
  LD B,$08		; 8 bits
_TAPOUT_0:
  RRCA
  CALL C,TAPSEND_HIGH_X2    ; '1'
  CALL NC,TAPSEND_LOW       ; '0'
  DJNZ _TAPOUT_0
  ; stop bits
  CALL TAPSEND_HIGH_X2
  CALL TAPSEND_HIGH_X2
  JP _BREAKX		; Set CY if STOP is pressed

; Routine at 6713
;
; Used by the routine at _TAPOUT.
TAPSEND_LOW:
  LD HL,(LOW)
  CALL TAPSEND_0
; This entry point is used by the routine at _TAPOON.
TAPSEND_RET:
  RET

  ; --- START PROC TAPSEND_HIGH_X2 ---
TAPSEND_HIGH_X2:
  CALL TAPSEND_HIGH
  EX   (SP),HL		; Delay ?
  EX   (SP),HL
  NOP
  NOP
  NOP
  NOP
  CALL TAPSEND_HIGH
  RET



; Routine at 6733
;
; Used by the routine at _TAPOON.
TAPSEND_HIGH:
  LD HL,(HIGH)
; This entry point is used by the routines at _TAPOUT and TAPSEND_LOW.
TAPSEND_0:
  PUSH AF
TAPSEND_1:
  DEC L
  JP NZ,TAPSEND_1
  LD A,$0B
  OUT (PPI_MOUT),A
TAPSEND_2:
  DEC H
  JP NZ,TAPSEND_2
  LD A,$0A
  OUT (PPI_MOUT),A
  POP AF
  RET

; Routine at 6755
;
; Used by the routine at TAPION.
_TAPION:
  LD A,$08
  OUT (PPI_MOUT),A
  DI
  LD A,$0E
  OUT (PSG_ADDR),A
_TAPION_0:
  LD HL,$0457		; 1111
_TAPION_1:
  LD D,C
  CALL TAPIN_BIT
  RET C               ; Exit if BREAK was pressed
  LD A,C              ; get measured tape sync speed
  CP $DE              ; Timeout ?
  JR NC,_TAPION_0     ; Try again
  CP $05              ; Too short ?
  JR C,_TAPION_0      ; Try again
  SUB D
  JR NC,_TAPION_2
  CPL
  INC A
_TAPION_2:
  CP $04
  JR NC,_TAPION_0     ; Try again
  DEC HL
  LD A,H
  OR L
  JR NZ,_TAPION_1     ; Correct leading tone.  It must stay like this 1111 times.
  LD HL,$0000
  LD B,L
  LD D,L
_TAPION_3:
  CALL TAPIN_BIT
  RET C               ; Exit if BREAK was pressed
  ADD HL,BC
  DEC D
  JP NZ,_TAPION_3
  LD BC,$06AE		; 1710
  ADD HL,BC
  LD A,H
  RRA
  AND $7F
  LD D,A
  ADD HL,HL
  LD A,H
  SUB D
  LD D,A
  SUB $06
  LD (LOWLIM),A			; Keep the minimal length of startbit
  LD A,D
  ADD A,A
  LD B,$00
_TAPION_4:
  SUB $03
  INC B
  JR NC,_TAPION_4
  LD A,B
  SUB $03
  LD (WINWID),A			;  Store the difference between a low-and high-cycle
  OR A
  RET

; Routine at 6844
;
; Used by the routine at TAPIN.
_TAPIN:
  LD A,(LOWLIM)			; Minimal length of startbit
  LD D,A
_TAPIN_0:
  CALL _BREAKX			; Set CY if STOP is pressed
  RET C
  IN A,(PSG_DATAIN)
  RLCA
  JR NC,_TAPIN_0
_TAPIN_1:
  CALL _BREAKX			; Set CY if STOP is pressed
  RET C
  IN A,(PSG_DATAIN)
  RLCA
  JR C,_TAPIN_1
  LD E,$00
  CALL TAPIN_PERIOD
_TAPIN_2:
  LD B,C
  CALL TAPIN_PERIOD
  RET C
  LD A,B
  ADD A,C
  JP C,_TAPIN_2
  CP D
  JR C,_TAPIN_2
  LD L,$08
_TAPIN_BYTE:
  CALL _TAPIN_STARTBIT
  CP $04
  CCF
  RET C
  CP $02
  CCF
  RR D
  LD A,C
  RRCA
  CALL NC,TAPIN_PERIOD_0
  CALL TAPIN_PERIOD
  DEC L
  JP NZ,_TAPIN_BYTE
  CALL _BREAKX		; Set CY if STOP is pressed
  LD A,D
  RET

; Routine at 6915
;
; Used by the routine at _TAPIN.
_TAPIN_STARTBIT:
  LD A,(WINWID)		;  Get the difference between a low-and high-cycle
  LD B,A
  LD C,$00

_TAPIN_STARTBIT_0:
  IN A,(PSG_DATAIN)
  XOR E
  JP P,_TAPIN_STARTBIT_1
  LD A,E
  CPL
  LD E,A
  INC C
  DJNZ _TAPIN_STARTBIT_0
  LD A,C
  RET

; Unused
_TAPIN_STARTBIT_1:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 4
 ENDIF
ELSE
  DEFS 4
ENDIF

  DJNZ _TAPIN_STARTBIT_0
  LD A,C
  RET

; Routine at 6943
;
; Used by the routine at _TAPIN.
TAPIN_PERIOD:
  CALL _BREAKX		; Set CY if STOP is pressed
  RET C
; This entry point is used by the routines at _TAPIN and TAPIN_BIT.
TAPIN_PERIOD_0:
  LD C,$00
; This entry point is used by the routine at TAPIN_BIT.
TAPIN_PERIOD_1:
  INC C
  JR Z,TAPIN_PERIOD_OVERFLOW
  IN A,(PSG_DATAIN)
  XOR E
  JP P,TAPIN_PERIOD_1
  LD A,E
  CPL
  LD E,A
  RET

; Routine at 6962
;
; Used by the routine at TAPIN_PERIOD.
TAPIN_PERIOD_OVERFLOW:
  DEC C
  RET

; Routine at 6964
;
; Used by the routine at _TAPION.
TAPIN_BIT:
  CALL _BREAKX		; Set CY if STOP is pressed
  RET C
  IN A,(PSG_DATAIN)
  RLCA
  JR C,TAPIN_BIT
  LD E,$00
  CALL TAPIN_PERIOD_0
  JP TAPIN_PERIOD_1

; Routine at 6981
;
;	OUTDO (either CALL or RST) prints char in [A] no registers affected
;		to either terminal or disk file or printer depending
;		flags:
;			PRTFLG if non-zero print to printer
;			PTRFIL if non-zero print to disk file pointed to by PTRFIL
;
; Used by the routine at OUTDO.
_OUTDO:
  PUSH AF
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HOUTD		; Hook for OUTDO std routine
ENDIF
  CALL _ISFLIO
  JR Z,OUTDO_NOFILE
  
  POP AF
  LD IX,FILO		; Sequential file output
  JP _CALBAS

; Routine at 6998
;
; Used by the routine at _OUTDO.
OUTDO_NOFILE:
  LD A,(PRTFLG)          ;SEE IF WE WANT TO TALK TO LPT
  OR A                   ;TEST BITS
  JR Z,_OUTCON           ;IF ZERO THEN NOT
  LD A,(RAWPRT)
  AND A
  JR NZ,_OUTPRT
  POP AF                 ;GET BACK CHAR

; This entry point is used by the routine at OUTDLP.
OUTC_TABEXP:
  PUSH AF
  CP TAB                 ;TAB
  JR NZ,NO_TAB           ;NO
TABEXP_LOOP:
  LD A,' '
  CALL OUTC_TABEXP
  LD A,(LPTPOS)
  AND $07                ;AT TAB STOP?
  JR NZ,TABEXP_LOOP      ;GO BACK IF MORE TO PRINT
  POP AF                 ;POP OFF CHAR
  RET                    ;RETURN

; Routine at 7030
;
; Used by the routine at OUTDO_NOFILE.
NO_TAB:
  SUB CR
  JR Z,NO_TAB_0
  JR C,NO_TAB_1
  CP ' '-CR
  JR C,NO_TAB_1
  LD A,(LPTPOS)
  INC A
NO_TAB_0:
  LD (LPTPOS),A
NO_TAB_1:
  LD A,(NTMSXP)
  AND A
  JR Z,_OUTPRT
  POP AF
  CALL _SNVCHR
  RET NC
  JR NZ,OUTPRT_SPC
  JR OUTPRT_CHR

; Keyboard jp table
L1B96:
  DEFB $30,K_L0F83-$0F00
  DEFB $33,K_L0F10-$0F00
  DEFB $34,K_CAPS-$0F00
  DEFB $35,K_L0F10-$0F00
  DEFB $3a,K_L0FC3-$0F00
  DEFB $3c,K_L0F10-$0F00
  DEFB $3d,K_L0F46-$0F00
  DEFB $41,K_L0F10-$0F00
  DEFB $42,K_L0F06-$0F00
  DEFB $ff,K_L0F10-$0F00
  DEFB $00

  
; This entry point is used by the routines at OUTDO_NOFILE and NO_TAB.
_OUTPRT:
  POP AF
; This entry point is used by the routines at NO_TAB and OUTPRT_SPC.
OUTPRT_CHR:
  CALL _LPTOUT
  RET NC
  LD IX,IO_ERR
  JP _CALBAS

; Routine at 7095
;
; Used by the routine at NO_TAB.
OUTPRT_SPC:
  LD A,' '
  JR OUTPRT_CHR

; Routine at 7099
;
; Used by the routine at OUTDO_NOFILE.
_OUTCON:
  POP AF
  JP _CHPUT

; Data block at 7103  ($1bbf)
; Data block size: $800 (2048 bytes)
_FONT:
IF SPECTRUM_SKIN
	BINARY  "ZXFONT.BIN"
ELSE
	BINARY  "msxfont.bin"
ENDIF

  ; --- START PROC L23BF ---
; Accepts a line from console until a CR or STOP
; is typed,and stores the line in a buffer.
_PINLIN:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HPINL		; Hook for PINLIN std routine
ENDIF
  LD A,(AUTFLG)		; AUTO mode ?
  AND A
  JR NZ,_INLIN      ;NO, REUGLAR MODE
  LD L,$00
  JR _INLIN_0


; Routine at 9164
;
; Used by the routine at QINLIN.
; Same as PINLIN, except if AUTFLO if set.
; L23CC
_QINLIN:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HQINL		; Hook for QINLIN std routine
ENDIF
  LD A,'?'
  RST OUTDO  		; Output char to the current device
  LD A,' '
  RST OUTDO  		; Output char to the current device
  
; This entry point is used by the routine at INLIN.
_INLIN:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HINLI			; Hook for INLIN std routine
ENDIF
  LD HL,(CSRY)
  DEC L
  CALL NZ,TERMIN
  INC L
_INLIN_0:
  LD (FSTPOS),HL
  XOR A
  LD (INTFLG),A
_INLIN_1:
  CALL _CHGET
  LD HL,INLIN_TBL-2
IF SPECTRUM_SKIN
  ; Unbind CHR$(127) and make it printable
  LD C,10
ELSE
  LD C,11
ENDIF
  CALL TTY_JP
  PUSH AF
  CALL NZ,CTL_CHARS
  POP AF
  JR NC,_INLIN_1
  LD HL,BUFMIN
  RET Z
  CCF
L23FE:
  RET

; Routine at 9215
;
; Used by the routine at _QINLIN.
CTL_CHARS:
  PUSH AF
  CP $09		; TAB ?
  JR NZ,NOTAB
  POP AF
TAB_LOOP:
  LD A,$20
  CALL CTL_CHARS
  LD A,(CSRX)
  DEC A
  AND $07
  JR NZ,TAB_LOOP
  RET

; Routine at 9235
;
; Used by the routine at CTL_CHARS.
NOTAB:
  POP AF
  LD HL,INSFLG
  CP $01	;  ?
  JR Z,NOTAB_0
  CP ' '
  JR C,L2428
  PUSH AF
  LD A,(HL)
  AND A
  CALL NZ,L24F2
  POP AF
NOTAB_0:
  RST OUTDO  		; Output char to the current device
  RET

; Routine at 9256
;
; Used by the routine at NOTAB.
L2428:
  LD (HL),$00
  RST OUTDO  		; Output char to the current device
L242B:
  DEFB $3E  ; "LD A,n" to Mask the next byte
L242C:
  DEFB $3E  ; "LD A,n"   .. Toggle between   "LD A,$AF" and "XOR A"

; This entry point is used by the routines at L24C4, L24E5 and L25CD.
L242D:
  XOR A
  PUSH AF
  CALL ERASE_CURSOR
  POP AF
  LD (CSTYLE),A
  JP DISP_CURSOR


  
; Third TTY JP table (11 entries)
INLIN_TBL:
  DEFB $08		; BS, backspace
  DEFW L2561
  
  DEFB $12		; INS, toggle insert mode
  DEFW L24E5
  
  DEFB $1b		; ESC: No action, (just point to 'RET')
  DEFW L23FE
  
  DEFB $02		; CTRL-B, previous word
  DEFW L260E
  
  DEFB $06		; CTRL-F, next word
  DEFW L25F8
  
  DEFB $0E		; CTRL-N, end of logical line
  DEFW L25D7
  
  DEFB $05		; CTRL-E, clear to end of line
  DEFW L25B9
  
  DEFB $03		; CTRL-STOP, terminate (CTRL-C)
  DEFW L24C5
  
  DEFB $0d		; CR, terminate
  DEFW L245A
  
  DEFB $15		; CTRL-U, clear line
  DEFW L25AE
  
IF SPECTRUM_SKIN
  ; Unbind CHR$(127) and make it printable
ELSE
  DEFB $7f		; DEL, delete character
  DEFW L2550
ENDIF


; CR, terminate
L245A:
  CALL L266C
  LD A,(AUTFLG)		; AUTO mode ?
  AND A
  JR Z,TTY_CR_0     ;YES
  LD H,$01
TTY_CR_0:
  PUSH HL
  CALL ERASE_CURSOR
  POP HL
  LD DE,BUF
  LD B,$FE
  DEC L
TTY_CR_1:
  INC L
TTY_CR_2:
  PUSH DE
  PUSH BC
  CALL GETCOD
  POP BC
  POP DE
  AND A
  JR Z,TTY_CR_4
  CP $20	; ' ' ?
  JR NC,TTY_CR_3
  DEC B
  JR Z,TTY_CR_5
  LD C,A
  LD A,$01
  LD (DE),A
  INC DE
  LD A,C
  ADD A,$40
TTY_CR_3:
  LD (DE),A
  INC DE
  DEC B
  JR Z,TTY_CR_5
TTY_CR_4:
  INC H
  LD A,(LINLEN)
  CP H
  JR NC,TTY_CR_2
  PUSH DE
  CALL GETTRM
  POP DE
  LD H,$01
  JR Z,TTY_CR_1
TTY_CR_5:
  DEC DE
  LD A,(DE)
  CP ' '
  JR Z,TTY_CR_5
  PUSH HL
  PUSH DE
  CALL DISP_CURSOR
  POP DE
  POP HL
  INC DE
  XOR A
  LD (DE),A
; This entry point is used by the routine at L24C4.
TTY_CR_6:
  LD A,CR
  AND A
; This entry point is used by the routine at L24C4.
TTY_CR_7:
  PUSH AF
  CALL TERMIN
  CALL _POSIT 		; Locate cursor at the specified position
  LD A,LF
  RST OUTDO  		; Output char to the current device
  XOR A
  LD (INSFLG),A
  POP AF
  SCF
  POP HL
  RET

; Routine at 9412
L24C4:
  INC L
; CTRL-STOP, terminate (CTRL-C)
L24C5:
  CALL GETTRM
  JR Z,L24C4
  CALL L242D
  XOR A
  LD (BUF),A
  LD H,$01
  PUSH HL
  CALL _GICINI
  CALL CKSTTP				; Check for STOP trap
  POP HL
  JR C,TTY_CR_6
  LD A,(BASROM)
  AND A
  JR NZ,TTY_CR_6
  JR TTY_CR_7

; Routine at 9445
; INS, toggle insert mode
L24E5:
  LD HL,INSFLG
  LD A,(HL)
  XOR $FF
  LD (HL),A
  JP Z,L242D
  JP L242C

; Routine at 9458
;
; Used by the routine at NOTAB.
L24F2:
  CALL ERASE_CURSOR
  LD HL,(CSRY)
  LD C,$20
; This entry point is used by the routine at L2535.
L24F2_0:
  PUSH HL
L24F2_1:
  PUSH BC
  CALL GETCOD
  POP DE
  PUSH BC
  LD C,E
  CALL OUT_CHAR
  POP BC
  LD A,(LINLEN)
  INC H
  CP H
  LD A,D
  JR NC,L24F2_1
  POP HL
  CALL GETTRM
  JR Z,L2535_2
  LD A,C
  CP $20
  PUSH AF
  JR NZ,L2524
  LD A,(LINLEN)
  CP H
  JR Z,L2524
  POP AF
  JP DISP_CURSOR

; Routine at 9508
;
; Used by the routine at L24F2.
L2524:
  CALL TERMIN+1
  INC L
  PUSH BC
  PUSH HL
  CALL TEXT_LINES
  CP L
  JR C,L2535
  CALL ESC_L_0		; ESC,"L", insert line
  JR L2535_1

; Routine at 9525
;
; Used by the routine at L2524.
L2535:
  LD HL,CSRY
  DEC (HL)
  JR NZ,L2535_0
  INC (HL)
L2535_0:
  LD L,$01
  CALL ESC_M_0		; ESC,"M", delete line
  POP HL
  DEC L
  PUSH HL
; This entry point is used by the routine at L2524.
L2535_1:
  POP HL
  POP BC
  POP AF
  JP Z,DISP_CURSOR
  DEC L
; This entry point is used by the routine at L24F2.
L2535_2:
  INC L
  LD H,$01
  JR L24F2_0

IF SPECTRUM_SKIN
  ; Unbind CHR$(127) and make it printable
ELSE
; Routine at 9552
; DEL, delete character
L2550:
  LD A,(LINLEN)
  CP H
  JR NZ,L2550_0
  CALL GETTRM
  JR NZ,L2550_5
L2550_0:
  LD A,$1C			; RIGHT, cursor right
  RST OUTDO  		; Output char to the current device
  LD HL,(CSRY)
ENDIF
  
; BS, backspace
L2561:
  PUSH HL
  CALL ERASE_CURSOR
  POP HL
  DEC H
  JP NZ,L2550_2
  INC H
  PUSH HL
  DEC L
  JR Z,L2550_1
  LD A,(LINLEN)
  LD H,A
  CALL GETTRM
  JR NZ,L2550_1
  EX (SP),HL
L2550_1:
  POP HL
L2550_2:
  LD (CSRY),HL
L2550_3:
  LD A,(LINLEN)
  CP H
  JR Z,L2550_5
  INC H
L2550_4:
  CALL GETCOD
  DEC H
  CALL OUT_CHAR
  INC H
  INC H
  LD A,(LINLEN)
  INC A
  CP H
  JR NZ,L2550_4
  DEC H
L2550_5:
  LD C,' '
  CALL OUT_CHAR
  CALL GETTRM
  JP NZ,DISP_CURSOR
  PUSH HL
  INC L
  LD H,$01
  CALL GETCOD
  EX (SP),HL
  CALL OUT_CHAR
  POP HL
  JR L2550_3

; Routine at 9646
; CTRL-U, clear line
L25AE:
  CALL ERASE_CURSOR
  CALL L266C
  LD (CSRY),HL
  JR L25B9_0

; Routine at 9657
; CTRL-E, clear to end of line
L25B9:
  PUSH HL
  CALL ERASE_CURSOR
  POP HL
; This entry point is used by the routine at L25AE.
L25B9_0:
  CALL GETTRM
  PUSH AF
  CALL ESC_K	; ESC,"K", clear to end of line
  POP AF
  JR NZ,L25CD
  LD H,$01
  INC L
  JR L25B9_0

; Routine at 9677
;
; Used by the routines at L25B9, L25D7, L25F8 and L260E.
L25CD:
  CALL DISP_CURSOR
  XOR A
  LD (INSFLG),A
  JP L242D

; Routine at 9687
; CTRL-N, end of logical line
L25D7:
  CALL ERASE_CURSOR
  LD HL,(CSRY)
  DEC L
L25D7_0:
  INC L
  CALL GETTRM
  JR Z,L25D7_0
  LD A,(LINLEN)
  LD H,A
  INC H
L25D7_1:
  DEC H
  JR Z,L25D7_2
  CALL GETCOD
  CP $20
  JR Z,L25D7_1
L25D7_2:
  CALL CURS_RIGHT
  JR L25CD

; Routine at 9720
; CTRL-F, next word
L25F8:
  CALL ERASE_CURSOR
  CALL L2634
L25F8_0:
  CALL L2624
  JR Z,L25CD
  JR C,L25F8_0
L25F8_1:
  CALL L2624
  JR Z,L25CD
  JR NC,L25F8_1
  JR L25CD

; Routine at 9742
; CTRL-B, previous word
L260E:
  CALL ERASE_CURSOR
L260E_0:
  CALL L2634
  JR Z,L25CD
  JR NC,L260E_0
L260E_1:
  CALL L2634
  JR Z,L25CD
  JR C,L260E_1
  CALL CURS_RIGHT
  JR L25CD

; Routine at 9764
;
; Used by the routine at L25F8.
L2624:
  LD HL,(CSRY)
  CALL CURS_RIGHT
  CALL TEXT_LINES
  LD E,A
  LD A,(LINLEN)
  LD D,A
  JR L2641

; Routine at 9780
;
; Used by the routines at L25F8 and L260E.
L2634:
  LD HL,(CSRY)
  CALL CURS_LEFT
  LD DE,$0101		; TOP-LEFT ?
  
; This entry point is used by the routine at L2624.
L2641:
  LD HL,(CSRY)
  RST DCOMPR		; Compare HL with DE.
  RET Z				; ret if so
  LD DE,L2668
  PUSH DE
  CALL GETCOD
  CP '0'
  CCF
  RET NC
  CP '9'+1
  RET C
  CP 'A'
  CCF
  RET NC
  CP 'Z'+1
  RET C
  CP 'a'
  CCF
  RET NC
  CP 'z'+1
  RET C
  CP $86
  CCF
  RET NC
  CP $A0
  RET C
  CP $A6
  CCF
L2668:
  LD A,$00
  INC A
  RET

; Routine at 9836
;
; Used by the routines at TTY_CR and L25AE.

L266C:
  DEC L
  JR Z,L266C_0
  CALL GETTRM
  JR Z,L266C
L266C_0:
  INC L
  LD A,(FSTPOS)
  CP L
  LD H,$01
  RET NZ
  LD HL,(FSTPOS)
  RET

; Routine at 9856
CSTART:
  JP _CSTART

; Routine at 9859
;
; Used by the routine at SYNCHR.
; Check syntax: a byte follows to be compared 
_SYNCHR:
  JP __SYNCHR

; Routine at 9862
;
; Used by the routine at CHRGTB.
; Gets next character (or token) from BASIC text.
_CHRGTB:
  JP __CHRGTB

; Routine at 9865
;
; Used by the routine at GETYPR.
; Return the number type (FAC)
_GETYPR:
  JP __GETYPR





;  DOUBLE PRECISION ARITHMETIC ROUTINES

;DOUBLE PRECISION NUMBERS ARE 8 BYTE QUANTITIES
;THE LAST 4 BYTES IN MEMORY ARE IN THE SAME FORMAT AS SINGLE PRECISION NUMBERS
;THE FIRST 4 BYTES ARE 32 MORE LOW ORDER BITS OF PRECISION
;THE LOWEST ORDER BYTE COMES FIRST IN MEMORY
;
;CALLING CONVENTIONS:
;FOR ONE ARGUMENT FUNCTIONS:
;	THE ARGUMENT IS IN THE FAC, THE RESULT IS LEFT IN THE FAC
;FOR TWO ARGUMENT OPERATIONS:
;	THE FIRST ARGUMENT IS IN THE FAC
;	THE SECOND ARGUMENT IS IN ARG-7,6,5,4,3,2,1,0  (NOTE: ARGLO=ARG-7)
;	THE RESULT IS LEFT IN THE FAC
;NOTE:	THIS ORDER IS REVERSED FROM INT AND SNG
;VALTYP(DOUBLE PRECISION)=10 OCTAL



; FACCU <- FACCU-ARG
;
	;DOUBLE PRECISION SUBTRACTION	FAC:=FAC-ARG
	;ALTERS ALL REGISTERS
;
; aka DSUB, Double precision SUB (formerly SUBCDE)
; Routine at 9868
; Used by the routines at __SIN, __ATN, __EXP and FSUBS.
DSUB:
  LD HL,ARG            ;NEGATE THE SECOND ARGUMENT
  LD A,(HL)            ;GET THE HO AND SIGN
  OR A                 ; Is number zero?
  RET Z                ; Yes - Nothing to subtract
  XOR $80              ;COMPLEMNT THE SIGN
  LD (HL),A            ;PUT IT BACK
  JR DADD_0          ;FALL INTO DADD


  ; --- START PROC L2697 ---
; Entry used by 'NEXT'
NEXT_DADD:
  CALL HL_ARG          

  ; --- START PROC DADD ---
; FACCU <- FACCU+ARG
DADD:
  LD HL,ARG             ;GET  POINTER TO EXPONENT OF FIRST ARGUMENT
  LD A,(HL)             ;CHECK IF IT IS ZERO                          ; Get FP exponent
  OR A                                                                ; Is number zero?
  RET  Z                ;IT IS, RESULT IS ALREADY IN FAC              ; Yes - Nothing to add

DADD_0:
  AND $7F
  LD B,A                ;SAVE EXPONENT FOR UNPACKING
  LD DE,FACCU           ;GET POINTER TO EXPONENT OF SECOND ARGUMENT
  LD A,(DE)             ;GET EXPONENT                                 ; Get FPREG exponent
  OR A                  ;SEE IF IT IS ZERO                            ; Is this number zero?
  JP Z,VMOVFA           ;IT IS, MOVE ARG TO FAC AND WE ARE DONE       ; Yes - Move FP to FPREG      ; FP number larger?
  AND $7F               
  SUB B                 ;SUBTRACT EXPONENTS TO GET SHIFT COUNT        ; FP number larger?
  JR NC,NOSWAP_DEC      ;PUT THE SMALLER NUMBER IN FAC                ; No - Don't swap them
  CPL                   ;NEGATE SHIFT COUNT                           ; Two's complement
  INC A
  PUSH AF               ;SAVE SHIFT COUNT
  PUSH HL               ;SAVE POINTER TO ARG                          ; Put FP on stack
  LD B,$08              ;SWITCH FAC AND ARG, SET UP A COUNT
DADD_SWAP:
  LD A,(DE)             ;GET A BYTE OF THE FAC
  LD C,(HL)             ;GET A BYTE OF ARG
  LD (HL),A             ;PUT THE FAC BYTE IN ARG
  LD A,C                ;PUT THE ARG BYTE IN A
  LD (DE),A             ;PUT THE ARG BYTE IN FAC
  INC DE                ;POINT TO THE NEXT LO BYTE OF FAC
  INC HL                ;POINT TO THE NEXT LO BYTE OF ARG
  DJNZ DADD_SWAP      ;ARE WE DONE?  NO, DO THE NEXT LO BYTE
  POP HL                ; Pointer to ARG
  POP AF                ;GET THE SHIFT COUNT BACK
NOSWAP_DEC:
  
	;WE NOW HAVE THE SUSPECTED LARGER NO IN THE FAC, WE NEED
	;TO KNOW IF WE ARE TO SUBTRACT (SIGNS ARE DIFFERENT) AND
	;WE NEED TO RESTORE THE HIDDEN MANTISSA BIT
	;FURTHER, IF THERE IS TO BE MORE THAN 56 BITS SHIFTED
	;TO ALIGN THE BINARY POINTS THEN THE LESSOR NO. IS
	;INSIGNIFICANT IN COMPARISON TO THE LARGER NO. SO WE
	;CAN JUST RETURN AND CALL THE LARGER NO. THE ANSWER.
				
  CP 16                 ;ARE WE WITHIN 15 BITS?             ; Second number insignificant?    ; (GWBASIC) THIS MUST SET CF TO CONTINUE
  RET NC                ;NO, ALL DONE                       ; Yes - First number is result
  PUSH AF               ;SAVE SHIFT COUNT                   ; Save number of bits to scale
  XOR A                 ;
  LD (FACCU+8),A        ;CLEAR TEMPORARY LEAST SIG BYTE
  LD (ARG+8),A          ;CLEAR EXTRA BYTE
  LD HL,ARG+1           ;POINT TO THE HO OF ARG             ; Point to FPREG
  POP AF                ;GET SHIFT COUNT                    ; Restore scaling factor
  CALL DSHFTR           ;SHIFT ARG RIGHT THE RIGHT NUMBER OF TIMES    ; Scale to same exponent
  LD HL,ARG
  LD A,(FACCU)
  XOR (HL)                     ; Result to be positive?
  JP M,DADD3                                                ; No - Subtract FPREG from CDE
  LD A,(ARG+8)          ;GET SUBTRACTION FLAG
  LD (FACCU+8),A        ;SUBTRACT NUMBERS IF THEIR SIGNS ARE DIFFERENT
  CALL BCDADD                  ; Add FPREG to CDE
  JP NC,DECROU                 ; No overflow - Round it up
  EX DE,HL                     ; Point to exponent
  LD A,(HL)
  INC (HL)                     ; Increment it
  XOR (HL)
  JP M,OV_ERR                  ; Number overflowed - Error

;**************************************************************
; WE ARE NOW SET TO SHIFT THE FAC RIGHT 1 BIT. RECALL WE GOT HERE WITH CF=1. 
; THE INSTRUCTIONS SINCE WE GOT HERE HAVEN'T AFFECTED
; CF SO WHEN WE SHIFT RIGHT WE WILL SHIFT CF INTO THE HIGH MANTISSA BIT.
;*************************************************************

  CALL DSHFRB           ;SHIFT NUMBER RIGHT ONE, SHIFT IN CARRY    ; Shift result right
  SET 4,(HL)
  JR DECROU             ; Round it up        ; (GWBASIC: 'ROUND': GO ROUND THE RESULT)

;**************************************************************
;TO GET HERE THE SIGNS OF THE FAC AND ARG WERE DIFFERENT THUS
;IMPLYING A DESIRED SUBTRACT.
;**************************************************************

; Routine at 9975
; Used by the routine at DADD.
DADD3:
  CALL BCDSUB           ;SUBTRACT FROM FAC
; This entry point is used by the routines at BNORM and __RND.
DECNRM:
; Normalize FACCU
  LD HL,FACCU+1
  LD BC,$0800        ; B=8, C=256
DECNRM_0:
  LD A,(HL)          ; Get MSB                         ;DO WE HAVE 1 BYTE OF ZEROS
  OR A               ; Is it zero?
  JR NZ,DNORML       ; No - Do it bit at a time        ;NO, SHIFT ONE PLACE AT A TIME
  
  ;THIS LOOP SPEEDS THINGS UP BY SHIFTING 8 PLACES AT ONE TIME
  INC HL
  DEC C
  DEC C
  DJNZ DECNRM_0
  JP ZERO


; a.k.a. PNORM  (or NORMD on GW-BASIC)
	;NORMALIZE FAC
	;ALTERS A,B,C,D,H,L
; Routine at 9996
; Used by the routine at DADD3.
DNORML:
  AND $F0           ;Check SHIFT COUNT
  JR NZ,DNORM1
  PUSH HL
  CALL DNORML_RLD	; shift 4 bits left the whole accumulator (multiply by 16)
  POP HL
  DEC C

;***************************************************************
;NOW DO AT 1 BYTE MOVE LEFT
;***************************************************************

DNORM1:
  LD A,$08
  SUB B             ;SUBTRACT 8
  JR Z,DNORM5       ;UNDERFLOW
  PUSH AF
  PUSH BC
  LD C,B
  LD DE,FACCU+1
  LD B,$00
  LDIR
  POP BC
  POP AF
  LD B,A
  XOR A
DNORM3:
  LD (DE),A
  INC DE
  DJNZ DNORM3
DNORM5:
  LD A,C            ;GET THE SHIFT COUNT
  OR A              ;SEE IF NO SHIFTING WAS DONE
  JR Z,DECROU       ;NONE WAS, PROCEED TO ROUND THE NUMBER
  LD HL,FACCU
  LD B,(HL)         ;GET POINTER TO EXPONENT
  ADD A,(HL)        ;UPDATE IT
  LD (HL),A         ;SAVE UPDATED EXPONENT
  XOR B
  JP M,OV_ERR		; Err $06 -  "Overflow"
  RET Z


	;ROUND FAC
	;ALTERS A,B,H,L
; a.k.a. DROUND
; This entry point is used by the routines at DADD and L3301.
DECROU:
  LD HL,FACCU+8
  LD B,$07
; This entry point is used by the routine at FINDIV.
BNORM_8:
  LD A,(HL)
  CP $50
  RET C
  DEC HL
  XOR A
  SCF
DNORML_5:
  ADC A,(HL)
  DAA
  LD (HL),A
  RET NC
  DEC HL
  DJNZ DNORML_5
  LD A,(HL)
  INC (HL)
  XOR (HL)
  JP M,OV_ERR		; Err $06 -  "Overflow"
  INC HL
  LD (HL),$10
  RET

; Routine at 10073
;
; Used by the routine at DADD.
; Add the BCD number in (HL) to (DE).  Result in (DE)
BCDADD:
  LD HL,ARG+7
  LD DE,FACCU+7
  LD B,$07
; This entry point is used by the routine at DMUL.
DAA_PASS2:
  XOR A
  
; Add the BCD number in (HL) to (DE).  Result in (DE)
BCDADD_1:
  LD A,(DE)
  ADC A,(HL)
  DAA
  LD (DE),A
  DEC DE
  DEC HL
  DJNZ BCDADD_1
  RET


; Routine at 10091
;
; Used by the routine at DADD3.
; Subtract the BCD number in (HL) from (DE).
BCDSUB:
  LD HL,ARG+8
  LD A,(HL)
  CP $50
  JR NZ,BCDSUB_0
  INC (HL)
BCDSUB_0:
  LD DE,FACCU+8
  LD B,$08
  XOR A
BCDSUB_1:
  LD A,(DE)
  SBC A,(HL)
  DAA
  LD (DE),A
  DEC DE
  DEC HL
  DJNZ BCDSUB_1
  RET NC
  EX DE,HL
  LD A,(HL)
  XOR $80
  LD (HL),A
  LD HL,FACCU+8
  LD B,$08
  XOR A
BCDSUB_2:
  LD A,$00
  SBC A,(HL)
  DAA
  LD (HL),A
  DEC HL
  DJNZ BCDSUB_2
  RET

; Routine at 10135
;
; Used by the routine at DNORML.
DNORML_RLD:
  LD HL,FACCU+8
DNORML_RLD_0:
  PUSH BC
  XOR A
RLDLOOP:
  RLD
  DEC HL              ;DECREMENT POINTER TO NEXT HIGHER ORDER
  DJNZ RLDLOOP        ;ARE WE DONE?  NO, DO THE NEXT BYTE
  POP BC
  RET


	;SUBROUTINE FOR ROUND: ADD ONE TO FAC
; Routine at 10147
; Used by the routine at DADD.
DSHFTR:
  OR A
  RRA
  PUSH AF
  OR A
  JP Z,DSHFRB_0
  PUSH AF
  CPL
  INC A
  LD C,A
  LD B,$FF
  LD DE,$0007
  ADD HL,DE
  LD D,H
  LD E,L
  ADD HL,BC

  LD A,$08             ;SET UP A COUNT
  ADD A,C

  LD C,A               ; Move [A] bytes
  PUSH BC
  LD B,$00
  LDDR
  POP BC

  POP AF
  INC HL
  INC DE
  PUSH DE
  LD B,A
  XOR A
DSHFTR_0:
  LD (HL),A
  INC HL
  DJNZ DSHFTR_0
  POP HL
  POP AF
  RET NC
  LD A,C
; This entry point is used by the routine at DSHFRB.
DSHFTR_1:
  PUSH HL
  PUSH BC
  LD B,A
  XOR A
DSHFTR_2:
  RRD
  INC HL
  DJNZ DSHFTR_2
  POP BC
  POP HL
  RET

; Routine at 10203
;
; Used by the routines at DADD and FINDIV.
DSHFRB:
  LD HL,FACCU+1
; This entry point is used by the routine at DSHFRB_0.
DSHFRB_LP:
  LD A,$08                ;SET UP A COUNT, ROTATE FAC ONE LEFT
  JR DSHFTR_1

; Used by the routine at DSHFTR.
DSHFRB_0:
  POP AF
  RET NC                  ;Exit if we're done
  JR DSHFRB_LP


;**********************************************************
;       $FMULS  FMULS MULTIPLIES THE SINGLE PRECISION
;               FLOATING POINT QUANTITIES  AND (FAC)
;               AND RETURNS THE PRODUCT IN THE (FAC).
;***********************************************************

	
; a.k.a. DMULT
;
	;DOUBLE PRECISION MULTIPLICATION	FAC:=FAC*ARG
	;ALTERS ALL REGISTERS
;
; Routine at 10214
; Used by the routines at __LOG, MULPHL, SUMSER, FMULT and DEXP.
DMUL:
  CALL SIGN         ;ZF=1 WILL BE SET IF (FAC)=0    ; Test sign of FP accumulator
  RET Z             ;JUST RETURN IF (FAC)=0         ; Return zero if zero
  LD A,(ARG)        ;MUST SEE IF ARG IS ZERO
  OR A              
  JP Z,ZERO         ;RETURN ZERO

  LD B,A
  LD HL,FACCU
  XOR (HL)
  AND $80
  LD C,A
  RES 7,B
  LD A,(HL)
  AND $7F			; ABS
  ADD A,B
  LD B,A
  LD (HL),$00
  AND $C0
  RET Z
  CP $C0            ;MUST NOW CHECK FOR OVERFLOW
  JR NZ,DMUL_0
  JP OV_ERR			; Err $06 -  "Overflow"

DMUL_0:
  LD A,B
  ADD A,$40
  AND $7F			; ABS
  RET Z
  OR C
  DEC HL
  LD (HL),A
  LD DE,HOLD+7
  LD BC,$0008
  LD HL,FACCU+7
  PUSH DE
  LDDR
  INC HL
  XOR A

  LD B,$08

; Init FP accumulator to zero
DMUL_1:
  LD (HL),A
  INC HL
  DJNZ DMUL_1
  POP DE
  LD BC,BNORM		; NORMALIZE
  PUSH BC
; This entry point is used by the routine at __RND.
DMUL_2:
  CALL DAA_PASS1	; ADC/DAA loop
  PUSH HL
  LD BC,$0008
  EX DE,HL
  LDDR
  EX DE,HL
  LD HL,HOLD2+7
  LD B,$08
  CALL DAA_PASS2	; ADC/DAA loop
  POP DE
  CALL DAA_PASS1	; ADC/DAA loop
  LD C,$07
  LD DE,ARG+7
DMUL_3:
  LD A,(DE)
  OR A
  JR NZ,DMUL_4

  DEC DE
  DEC C
  JR DMUL_3

DMUL_4:
  LD A,(DE)
  DEC DE
  PUSH DE
  LD HL,HOLD8+7  ; HOLD8+7				; Double precision operations work area
DMUL_5:
  ADD A,A
  JR C,DMUL_7
  JR Z,DMUL_8

DMUL_6:
  LD DE,$0008
  ADD HL,DE
  JR DMUL_5

DMUL_7:
  PUSH AF
  LD B,$08
  LD DE,FACCU+7
  PUSH HL
  CALL DAA_PASS2
  POP HL
  POP AF
  JR DMUL_6
 
DMUL_8:
  LD B,$0F
  LD DE,FACCU+14	; some declaration is missing here but the distances between
  LD HL,FACCU+15	; the labels in this work area is the same on all the target computers
  CALL LDDR_DEHL
  LD (HL),$00
  POP DE
  DEC C
  JR NZ,DMUL_4
  RET

; Routine at 10371
BNORM:
  DEC HL
  LD A,(HL)
  INC HL
  LD (HL),A
  JP DECNRM		; Single precision normalization

; Routine at 10378
;
; Used by the routine at DMUL.
; IN: HL=last byte of value
DAA_PASS1:
  LD HL,$FFF8		; -8
  ADD HL,DE			; Move on first byte of value
  LD C,$03
DAA_PASS1_0:
  LD B,$08
  OR A
DAA_PASS1_1:
  LD A,(DE)
  ADC A,A
  DAA
  LD (HL),A
  DEC HL
  DEC DE
  DJNZ DAA_PASS1_1
  DEC C
  JR NZ,DAA_PASS1_0
  RET


; Double precision DIVIDE
;
	;DOUBLE PRECISION DIVISION	FAC:=FAC/ARG
	;ALTERS ALL REGISTERS
;
; Data block at 10399
  ; --- START PROC L289F ---
DDIV:
  LD A,(ARG)
  OR A               ;CHECK FOR DIVISION BY ZERO
  JP Z,O_ERR		 ;GET THE EXPONENT OF ARG
  LD B,A
  LD HL,FACCU        ;IF FAC=0 THEN ANS IS ZERO
  LD A,(HL)
  OR A
  JP Z,ZERO
  XOR B              ;Compute sign
  AND $80
  LD C,A
  RES 7,B            ;
  LD A,(HL)
  AND $7F            ;
  SUB B
  LD B,A
  RRA
  XOR B
  AND $40
  LD (HL),$00		; zero exponent
  JR Z,DDIV_1
  LD A,B
  AND $80
  RET NZ
DDIV_0:
  JP OV_ERR			; Err $06 -  "Overflow"


DDIV_1:
  LD A,B
  ADD A,$41
  AND $7F			; ABS
  LD (HL),A
  JR Z,DDIV_0
  OR C
  LD (HL),$00
  DEC HL
  LD (HL),A
  LD DE,FACCU+7
  LD HL,ARG+7			; Unknown system variable ?
  LD B,$07
  XOR A
DDIV_2:
  CP (HL)
  JR NZ,DDIV_3
  DEC DE
  DEC HL
  DJNZ DDIV_2
DDIV_3:
  LD (DECTM2),HL		; Used at division routine execution
  EX DE,HL
  LD (DECTMP),HL
  LD A,B
  LD (DECCNT),A
  LD HL,HOLD
DDIV_4:
  LD B,$0F
DDIV_5:
  PUSH HL
  PUSH BC
  LD HL,(DECTM2)
  EX DE,HL
  LD HL,(DECTMP)
  LD A,(DECCNT)
  LD C,$FF
DDIV_6:
  INC C
  LD B,A
  PUSH HL
  PUSH DE
  XOR A
  EX DE,HL
DDIV_7:
  LD A,(DE)
  SBC A,(HL)
  DAA
  LD (DE),A
  DEC HL
  DEC DE
  DJNZ DDIV_7
  LD A,(DE)
  SBC A,B
  LD (DE),A
  POP DE
  POP HL
  LD A,(DECCNT)
  JR NC,DDIV_6
  LD B,A
  EX DE,HL
  CALL DAA_PASS2
  JR NC,DDIV_8
  EX DE,HL
  INC (HL)
DDIV_8:
  LD A,C
  POP BC
  LD C,A
  PUSH BC
  SRL B
  INC B
  LD E,B
  LD D,$00
  LD HL,FACCU-1
  ADD HL,DE
  CALL DNORML_RLD_0
  POP BC
  POP HL
  LD A,B
  INC C
  DEC C
  JR NZ,DDIV_13
  CP $0F
  JR Z,DDIV_12
  RRCA
  RLCA
  JR NC,DDIV_13
  PUSH BC
  PUSH HL
  LD HL,FACCU
  LD B,$08
  XOR A
DDIV_9:
  CP (HL)
  JR NZ,DDIV_11
  INC HL
  DJNZ DDIV_9
  POP HL
  POP BC
  SRL B
  INC B
  XOR A
DDIV_10:
  LD (HL),A
  INC HL
  DJNZ DDIV_10
  JR DDIV_16

DDIV_11:
  POP HL
  POP BC
  LD A,B
  JR DDIV_13

DDIV_12:
  LD A,(FACCU-1)
  LD E,A
  DEC A
  LD (FACCU-1),A
  XOR E
  JP P,DDIV_4
  JP ZERO                  ;UNDERFLOW

DDIV_13:
  RRA
  LD A,C
  JR C,DDIV_14
  OR (HL)
  LD (HL),A
  INC HL
  JR DDIV_15

DDIV_14:
  ADD A,A
  ADD A,A
  ADD A,A
  ADD A,A
  LD (HL),A
DDIV_15:
  DEC B
  JP NZ,DDIV_5
DDIV_16:
  LD HL,FACCU+8
  LD DE,HOLD+7
  LD B,$08
  CALL LDDR_DEHL
  JP BNORM			; NORMALIZE

  ; --- START PROC L2993 ---

; Routine at 10643
;
; Used by the routine at __TAN.
;
;  "Sine/Cosine" Taylor polynomial algorithm
__COS:                    ;WILL CALCULATE X=FAC/(2*PI)
  LD HL,FP_EPSILON        ;FP_EPSILON: 1/(2*PI) =~ 0.159155
  CALL MULPHL
  LD A,(FACCU)
  AND $7F			; ABS
  LD (FACCU),A
  LD HL,FP_QUARTER
  CALL FSUBS
  CALL NEG
  JR __SIN_0


; 'SIN' BASIC function
;
	;SINE FUNCTION
	;IDEA: USE IDENTITIES TO GET FAC IN QUADRANTS I OR IV
	;THE FAC IS DIVIDED BY 2*PI AND THE INTEGER PART IS IGNORED BECAUSE SIN(X+2*PI)=SIN(X).
	;THEN THE ARGUMENT CAN BE COMPARED WITH PI/2 BY COMPARING THE RESULT OF THE DIVISION WITH PI/2/(2*PI)=1/4.
	;IDENTITIES ARE THEN USED TO GET THE RESULT IN QUADRANTS I OR IV.
	;AN APPROXIMATION POLYNOMIAL IS THEN USED TO COMPUTE SIN(X).
;
; Routine at 10668
; Used by the routine at __TAN.
__SIN:
;; Trick to inspect single precision constants, "PRINT  SIN(X)" to display the value
;  LD BC,$xxxx
;  LD DE,$yyyy
;  CALL FPBCDE
;  CALL __CDBL
;  JP VALDBL
;;
;; (to preserve the code size, comment out the some of next instructions)
;;
                          ;WILL CALCULATE X=FAC/(2*PI)
  LD HL,FP_EPSILON        ;FP_EPSILON: 1/(2*PI) =~ 0.159155
  CALL MULPHL
; This entry point is used by the routine at __COS.
__SIN_0:
  LD A,(FACCU)
  OR A
  CALL M,NEGAFT
  CALL STAKFP              ;SAVE X
  CALL __INT               ;FAC=INT(X)
  CALL FACCU2ARG
  CALL USTAKFP             ;FETCH X TO REGISTERS
  CALL DSUB                ;FAC=X-INT(X)
  LD A,(FACCU)
  CP $40
  JP C,__SIN_2
  LD A,(FACCU+1)
  CP $25
  JP C,__SIN_2
  CP $75
  JP NC,__SIN_1
  CALL FACCU2ARG
  LD HL,FP_HALF
  CALL HL2FACCU
  CALL DSUB
  JP __SIN_2
__SIN_1:
  LD HL,FP_UNITY
  CALL HL2ARG
  CALL DSUB
__SIN_2:
  LD HL,FP_SINTAB				; 8 values series
  JP SUMSER



; 'TAN' BASIC function
;
	;TANGENT FUNCTION
	;TAN(X)=SIN(X)/COS(X)
;
; Routine at 10747
__TAN:
  CALL STAKFP       ; Put angle on stack
  CALL __COS        ; Get COS of angle
  CALL XSTKFP       ; Exchange stack and FP value
  CALL __SIN        ; Get SIN of angle
  CALL USTAKARG     ; Recall result of COS
  LD A,(ARG)        
  OR A              ; COS(x) is not zero..
  JP NZ,DDIV        ; Go for division
  JP OV_ERR			; If it is zero, Err $06 -  "Overflow"



; 'ATN' BASIC function
	;IDEA: USE IDENTITIES TO GET ARG BETWEEN 0 AND 1 AND THEN USE AN
	;APPROXIMATION POLYNOMIAL TO COMPUTE ARCTAN(X)
; Routine at 10772
__ATN:
  LD A,(FACCU)
  OR A
  RET Z
  CALL M,NEGAFT      ; Negate result after if -ve       ;IF ARG IS NEGATIVE, USE:  ARCTAN(X)=-ARCTAN(-X)
  CP $41             ; Number less than 1?
  JP C,__ATN_0       ; Yes - Get arc tangnt
  CALL FACCU2ARG
  LD HL,FP_UNITY     ; BCDE = 1                         ;GET THE CONSTANT 1
  CALL HL2FACCU                                        ;COMPUTE RECIPROCAL TO USE THE IDENTITY:
  CALL DDIV          ; Get reciprocal of number         ;  ARCTAN(X)=PI/2-ARCTAN(1/X)
  CALL __ATN_0
  CALL FACCU2ARG
  LD HL,FP_HALFPI    ; PI/2 - angle in case > 1         ;GET POINTER TO PI/2 IN CASE WE HAVE TO
  CALL HL2FACCU
  JP DSUB            ; Number > 1 - Sub from PI/2       ; SUBTRACT THE RESULT FROM PI/2
  
__ATN_0:
  LD HL,FP_TAN15
  CALL CMPPHL
  JP M,ATN_SUMSER    ; Evaluate sum of series
  CALL STAKFP
  LD HL,FP_SQR3
  CALL ADDPHL
  CALL XSTKFP
  LD HL,FP_SQR3
  CALL MULPHL
  LD HL,FP_UNITY
  CALL FSUBS
  CALL USTAKARG
  CALL DDIV
  CALL ATN_SUMSER    ; Evaluate sum of series
  LD HL,FP_SIXTHPI
  JP ADDPHL
  
ATN_SUMSER:
  LD HL,FP_ATNTAB    ; Coefficient table                ;EVALUATE APPROXIMATION POLYNOMIAL
  JP SUMSER          ; Evaluate sum of series           


;**********************************************************
;FOR LOG CALCULATIONS HART ALGORITHM 2524 WILL BE USED
;IN THIS ALGORITHM WE WILL CALCULATE BASE 2 LOG AS FOLLOWS
;LOG(X)=P(X)/Q(X)
;***************************************************************

; Routine at 10866
;
; Used by the routine at DEXP.
__LOG:
  CALL SIGN             ; test FP number sign
  JP M,FC_ERR			; Err $05 - "Illegal function call"     ;ERROR IF ($FAC).LE..0
  JP Z,FC_ERR			; Err $05 - "Illegal function call"
  LD HL,FACCU
  LD A,(HL)             ;FETCH EXPONENT
  PUSH AF
  LD (HL),$41           ;ZERO THE EXPONENT
  LD HL,FP_10EXHALF
  CALL CMPPHL
  JP M,__LOG_0
  POP AF
  INC A
  PUSH AF
  LD HL,FACCU
  DEC (HL)
__LOG_0:
  POP AF
  LD (TEMP3),A          ;SAVE EXPONENT
  CALL STAKFP
  LD HL,FP_UNITY
  CALL ADDPHL
  CALL XSTKFP
  LD HL,FP_UNITY
  CALL FSUBS
  CALL USTAKARG
  CALL DDIV
  CALL STAKFP
  CALL SQUAREFP
  CALL STAKFP
  CALL STAKFP
  LD HL,FP_LOGTAB_Q
  CALL POLY             ;CALCULATE Q(X)
  CALL XSTKFP           ;SAVE Q(X)
  LD HL,FP_LOGTAB_P
  CALL POLY             ;NOW TO USE HART APPROX FOR P(X)
  CALL USTAKARG         ;RECALL Q(X)
  CALL DDIV           ;CALCULATE P(X)/Q(X)
  CALL USTAKARG
  CALL DMUL
  LD HL,FP_TWODLN10     ;FETCH 2/LN(10)
  CALL ADDPHL
  CALL USTAKARG
  CALL DMUL           ;MULTIPLY TO COMPLETE
  CALL STAKFP
  LD A,(TEMP3)          ;FETCH EXPONENT
  SUB $41
  LD L,A
  ADD A,A
  SBC A,A
  LD H,A
  CALL HL_CSNG
  CALL CONDS
  CALL USTAKARG
  CALL DADD
  LD HL,FP_LN10
  JP MULPHL


; 'SQR' BASIC function
;
	;SQUARE ROOT FUNCTION
	;WE USE SQR(X)=X^.5
;
; Routine at 11007
__SQR:
  CALL SIGN				; test FP number sign
  RET Z
  JP  M,FC_ERR			; Err $05 - "Illegal function call"
  CALL FACCU2ARG
  LD A,(FACCU)
  OR A
  RRA
  ADC A,$20
  LD (ARG),A
  LD A,(FACCU+1)
  OR A
  RRCA
  OR A
  RRCA
  AND $33
  ADD A,$10
  LD (ARG+1),A
  LD A,$07
__SQR_0:
  LD (TEMP3),A
  CALL STAKFP
  CALL STAKARG
  CALL DDIV
  CALL USTAKARG
  CALL DADD
  LD HL,FP_HALF           ; Set power to 1/2            ;GET 1/2
  CALL MULPHL
  CALL FACCU2ARG
  CALL USTAKFP
  LD A,(TEMP3)
  DEC A
  JR NZ,__SQR_0
  JP ARG2FACCU



;*************************************************************
;
;THE FUNCTION EXP(X) CALCULATES e^X WHERE e=2.718282
;       THE TECHNIQUE USED IS TO EMPLOY A COUPLE
;       OF FUNDAMENTAL IDENTITIES THAT ALLOWS US TO
;       USE THE BASE 2 THROUGH THE DIFFICULT PORTIONS OF
;       THE CALCULATION:
;
;               (1)e^X=2^y  WHERE y=X*LOG(e)
;               (2) 2^y=2^[ INT(y)+(y-INT(y)]
;               (3) IF Ny=INT(y) THEN
;                   2^(Ny+y-Ny)=[2^Ny]*[2^(y-Ny)]
;
;       NOW, SINCE 2^Ny IS EASY TO COMPUTE (AN EXPONENT
;       CALCULATION WITH MANTISSA BITS OF ZERO) THE DIFFICULT
;       PORTION IS TO COMPUTE 2^(Y-Ny) WHERE 0.LE.(Y-Ny).LT.1
;       THIS IS ACCOMPLISHED WITH A POLYNOMIAL APPROXIMATION
;       TO 2^Z WHERE 0.LE.Z.LT.1  . ONCE THIS IS COMPUTED WE
;       HAVE TO EFFECT THE MULTIPLY BY 2^Ny .
;
;**************************************************************
; Routine at 11082
;
; Used by the routine at DEXP.
__EXP:
  LD HL,FP_LOG10E
  CALL MULPHL       ;y=FAC*LOG(e)
  CALL STAKFP
  CALL __CINT
  LD A,L
  RLA
  SBC A,A
  CP H
  JR Z,__EXP_1
  LD A,H
  OR A              ; Test if new exponent zero             ;Is it positively too big?
  JP P,RESZER       ; Result zero                           ;Yes, overflow.
  CALL VALDBL                                               ;No, underflow for negative.
  CALL USTAKFP
  LD HL,FP_ZERO
  JP HL2FACCU
RESZER:
  JP OV_ERR			; Err $06 -  "Overflow"
  
__EXP_1:
  LD (TEMP3),HL
  CALL __CDBL
  CALL FACCU2ARG
  CALL USTAKFP
  CALL DSUB
  LD HL,FP_HALF
  CALL CMPPHL
  PUSH AF
  JR Z,__EXP_2
  JR C,__EXP_2
  LD HL,FP_HALF
  CALL FSUBS
__EXP_2:
  CALL STAKFP
  LD HL,FP_EXPTAB2	; 3 values series
  CALL SUMSER
  CALL XSTKFP
  LD HL,FP_EXPTAB	; 4 values series
  CALL SMSER1
  CALL USTAKARG
  CALL STAKARG
  CALL STAKFP
  CALL DSUB
  LD HL,HOLD
  CALL DBL_FACCU2HL
  CALL USTAKARG
  CALL USTAKFP
  CALL DADD
  LD HL,HOLD
  CALL HL2ARG
  CALL DDIV
  POP AF
  JR C,__EXP_3
  JR Z,__EXP_3
  LD HL,FP_10EXHALF
  CALL MULPHL
__EXP_3:
  LD A,(TEMP3)
  LD HL,FACCU
  LD C,(HL)
  ADD A,(HL)
  LD (HL),A
  XOR C
  RET P
  JP OV_ERR			; Err $06 -  "Overflow"


; Routine at 11231
__RND:
  CALL SIGN			; test FP number sign
  LD HL,RNDX
  JR Z,__RND_0
  CALL M,DBL_FACCU2HL
  LD HL,HOLD
  LD DE,RNDX
  CALL DBL2HL
  LD HL,RNDTAB_1
  CALL HL2ARG
  LD HL,RNDTAB_2
  CALL HL2FACCU
  LD DE,HOLD+7
  CALL DMUL_2
  LD DE,FACCU+8
  LD HL,RNDX+1
  LD B,$07
  CALL MOVE1   		; Copy B bytes from DE to HL
  LD HL,RNDX
  LD (HL),$00
__RND_0:
  CALL HL2FACCU
  LD HL,FACCU
  LD (HL),$40
  XOR A
  LD (FACCU+8),A
  JP DECNRM		; Single precision normalization

; Routine at 11300
;
; Used by the routine at L628E.
INIT_RND:
  LD DE,RNDX_INIT
  LD HL,RNDX
  JR DBL2HL

; Routine at 11308
;
; Used by the routines at __ATN and __LOG.
ADDPHL:
  CALL HL2ARG
  JP DADD


;SUBTRACTION	FAC:=ARG-FAC
;ENTRY IF POINTER TO ARG IS IN (HL)

; Routine at 11314
; Used by the routines at __COS, __ATN, __LOG and __EXP.
FSUBS:
  CALL HL2ARG                ;ENTRY IF POINTER TO ARG IS IN (HL)
  JP DSUB                  ; FPREG = -FPREG + number at HL

; Routine at 11320
;
; Used by the routines at __LOG and SMSER1.
SQUAREFP:
  LD HL,FACCU

; ADD number at HL to BCDE
;
; Used by the routines at __COS, __SIN, __ATN, __LOG, __SQR, __EXP, SMSER1 and
; L3878.
MULPHL:
  CALL HL2ARG
  JP DMUL

; Routine at 11329
DIVPHL:
  CALL HL2ARG
  JP DDIV

; Routine at 11335
;
; Used by the routines at __ATN, __LOG and __EXP.
CMPPHL:
  CALL HL2ARG
  JP XDCOMP

; Routine at 11341
;
; Used by the routines at __SIN, __ATN, __SQR, __EXP and L3878.
FACCU2ARG:
  LD HL,FACCU
; This entry point is used by the routines at __SIN, __EXP, __RND, ADDPHL,
; FSUBS, MULPHL, DIVPHL, CMPPHL and SMSER1.

HL2ARG:
  LD DE,ARG
; This entry point is used by the routine at ARG2FACCU.
FP2DE:
  EX DE,HL
  CALL DBL2HL
  EX DE,HL
  RET

; Routine at 11353
;
; Used by the routines at __SQR, XSTKFP, DEXP, L3878 and L391A.
ARG2FACCU:
  LD HL,ARG
; This entry point is used by the routines at __SIN, __ATN, __EXP, __RND,
; SMSER1, FOUINI, DEXP and L3878.
HL2FACCU:
  LD DE,FACCU
  JR FP2DE

; Routine at 11361 ($2C61)
; ..how is this called ?
GET_RNDX:
  CALL HL_CSNG
  LD HL,RNDX
  
; This entry point is used by the routines at __EXP, __RND, SMSER1, DEXP and
; L3878.
DBL_FACCU2HL:
  LD DE,FACCU
; This entry point is used by the routines at __RND, INIT_RND and FACCU2ARG.
DBL2HL:
  LD B,$08
  JP MOVE1   		; Copy B bytes from DE to HL

; Routine at 11375
;
; Used by the routines at __TAN, __ATN, __LOG, __EXP and DEXP.
; Exchange stack and FP value (ARG is used and left = FACCU)
XSTKFP:
  POP HL
  LD (FBUFFR),HL		; Buffer for fout, save ret addr.
  CALL USTAKARG
  CALL STAKFP
  CALL ARG2FACCU
  LD HL,(FBUFFR)		; Buffer for fout, restore ret addr.
  JP (HL)


; EXPONENTIATION AND THE SQUARE ROOT FUNCTION

; Negate number, a.k.a. PSHNEG
;
; Used by the routines at __SIN and __ATN.
NEGAFT:
  CALL NEG              
  LD HL,NEG             ;GET THE ADDRESS OF NEG
  EX (SP),HL            ;SWITCH RET ADDR AND ADDR OF NEG
  JP (HL)               ;RETURN, THE ADDRESS OF NEG IS ON THE STACK

; This entry point is used by the routines at __SIN, __ATN and __EXP.
SUMSER:
  LD (FBUFFR),HL		; Buffer for fout
  CALL STAKFP
  LD HL,(FBUFFR)		; Buffer for fout
  CALL SMSER1
  CALL USTAKARG         ; Move FPREG to BCDE               ;SQUARE X
  JP DMUL               ; Square the value

; Routine at 11418
;
; Used by the routines at __EXP and SUMSER.
SMSER1:
  LD (FBUFFR),HL		; Buffer for fout
  CALL SQUAREFP
  LD HL,(FBUFFR)		; Buffer for fout
; This entry point is used by the routine at __LOG.
POLY:
  LD A,(HL)			; Get number of coefficients       ;GET DEGREE
  PUSH AF           ; Save count                       ;SAVE DEGREE
  INC HL			; Point to start of table          ;INCREMENT POINTER TO FIRST CONSTANT
  PUSH HL
  LD HL,FBUFFR		; Buffer for fout
  CALL DBL_FACCU2HL
  POP HL            ; Point to start of table
  CALL HL2FACCU     ; Move coefficient to FPREG        ;MOVE FIRST CONSTANT TO FAC
SUMLP:
  POP AF            ; Restore count                    ;GET DEGREE
  DEC A             ; Cont coefficients                ;ARE WE DONE?
  RET Z             ; All done                         ;YES, RETURN
  PUSH AF           ; Save count                       ;SAVE DEGREE
  PUSH HL           ; Save address in table            ;SAVE CONSTANT POINTER
  LD HL,FBUFFR		; Buffer for fout
  CALL MULPHL       ; Multiply FPREG by BCDE           ;EVALUATE THE POLY, MULTIPLY BY X
  POP HL            ; Restore address in table         ;GET LOCATION OF CONSTANTS
  CALL HL2ARG       ; Number at HL to BCDE             ;GET CONSTANT
  PUSH HL           ; Save address in table            ;STORE LOCATION OF CONSTANTS SO FADD AND FMULT
  CALL DADD         ; Add coefficient to FPREG         ; WILL NOT SCREW THEM UP, ADD IN CONSTANT
  POP HL            ; Restore address in table         ;MOVE CONSTANT POINTER TO NEXT CONSTANT
  JR SUMLP          ; More coefficients                ;SEE IF DONE

; Routine at 11463
;
; Used by the routines at __SQR, __EXP and L391A.
STAKARG:
  LD HL,ARG+7
  JR STAKFP_0

; Routine at 11468
;
; Used by the routines at __SIN, __TAN, __ATN, __LOG, __SQR, __EXP, XSTKFP,
; SUMSER, DEXP and L3878.
STAKFP:
  LD HL,FACCU+7
; This entry point is used by the routine at STAKARG.
STAKFP_0:
  LD A,$04
  POP DE
STAKFP_1:
  LD B,(HL)
  DEC HL
  LD C,(HL)
  DEC HL
  PUSH BC
  DEC A
  JR NZ,STAKFP_1
  EX DE,HL
  JP (HL)


; This entry point is used by the routines at __TAN, __ATN, __LOG, __SQR,
; __EXP, XSTKFP, SUMSER, DEXP and L391A.
USTAKARG:
  LD HL,ARG
  JR USTAK_SUB

  ; --- START PROC USTAKFP ---
USTAKFP:
  LD HL,FACCU

  ; --- START PROC USTAK_SUB ---
USTAK_SUB:
  LD A,$04
  POP DE
USTAK_SUB_0:
  POP BC
  LD (HL),C
  INC HL
  LD (HL),B
  INC HL
  DEC A
  JR NZ,USTAK_SUB_0
  EX DE,HL
  JP (HL)


; FP "operands" for RND

RNDTAB_2:
  DEFB $00,$14,$38,$98,$20,$42,$08,$21

RNDTAB_1:
  DEFB $00,$21,$13,$24,$86,$54,$05,$19 

; Constant to initialize the "last random number" variable
RNDX_INIT:
  DEFB $00,$40,$64,$96,$51,$37,$23,$58


; FP Numeric constants

FP_LOG10E:
  DEFB $40,$43,$42,$94,$48,$19,$03,$24		; LOG(E)	 =~  0.43429448190324

FP_HALF:
  DEFB $40,$50								; 0.5
FP_ZERO:
  DEFB $00,$00,$00,$00,$00,$00,$00,$00		; 0

; Why did they optimize space for FP_HALF and
; preferred not to reuse the last value of FP_ATNTAB for FP UNITY ?
FP_UNITY:
  DEFB $41,$10,$00,$00,$00,$00,$00,$00		;  1

FP_QUARTER:
  DEFB $40,$25,$00,$00,$00,$00,$00,$00		; 1/4		=  0.25

FP_10EXHALF:
  DEFB $41,$31,$62,$27,$76,$60,$16,$84		; 10^(1/2)  =~ 3.1622776601684

FP_TWODLN10:
  DEFB $40,$86,$85,$88,$96,$38,$06,$50		; 2/LN(10)	=~ 0.8685889638065

FP_LN10:
  DEFB $41,$23,$02,$58,$50,$92,$99,$40		; LN(10)	=~ 2.302585092994

FP_HALFPI:
  DEFB $41,$15,$70,$79,$63,$26,$79,$49		; PI/2		=~ 1.5707963267949 

FP_TAN15:
  DEFB $40,$26,$79,$49,$19,$24,$31,$12		; TAN(15)	=~ 0.26794919243112

FP_SQR3:
  DEFB $41,$17,$32,$05,$08,$07,$56,$89		; SQR(3)	=~ 1.7320508075689

FP_SIXTHPI:
  DEFB $40,$52,$35,$98,$77,$55,$98,$30		; PI/6		=~ 0.5235987755983

FP_EPSILON:
  DEFB $40,$15,$91,$54,$94,$30,$91,$90		; 1/(2*PI)	=~  0.1591549430919

FP_EXPTAB:
  DEFB $04	; 4 values series
  DEFB $41,$10,$00,$00,$00,$00,$00,$00		; 1
  DEFB $43,$15,$93,$74,$15,$23,$60,$31		; 159.37415236031
  DEFB $44,$27,$09,$31,$69,$40,$85,$16		; 2709.3169408516
  DEFB $44,$44,$97,$63,$35,$57,$40,$58		; 4497.6335574058

FP_EXPTAB2:
  DEFB $03	; 3 values
  DEFB $42,$18,$31,$23,$60,$15,$92,$75		; 18.31236015975
  DEFB $43,$83,$14,$06,$72,$12,$93,$71		; 831.4067219371
  DEFB $44,$51,$78,$09,$19,$91,$51,$62		; 5178.0919915162
  
FP_LOGTAB_P:
  DEFB $04	; 4 values
  DEFB $c0,$71,$43,$33,$82,$15,$32,$26		; -0.71433382153226
  DEFB $41,$62,$50,$36,$51,$12,$79,$08		; 6.2503651127908
  DEFB $C2,$13,$68,$23,$70,$24,$15,$03		; -13.682370241503
  DEFB $41,$85,$16,$73,$19,$87,$23,$89		; 8.5167319872389

FP_LOGTAB_Q:
  DEFB $05	; 5 values
  DEFB $41,$10,$00,$00,$00,$00,$00,$00		; 1
  DEFB $C2,$13,$21,$04,$78,$35,$01,$56		; -13.210478350156
  DEFB $42,$47,$92,$52,$56,$04,$38,$73		; 47.925256043873
  DEFB $C2,$64,$90,$66,$82,$74,$09,$43		; -64.906682740943
  DEFB $42,$29,$41,$57,$50,$17,$23,$23		; 29.415750172323

; Compared to the earlier BASIC versions this one is much more accurate
; the first three values of the list were simply missing
FP_SINTAB:
  DEFB $08	; 8 values
  DEFB $C0,$69,$21,$56,$92,$29,$18,$09		; -0.69215692291809
  DEFB $41,$38,$17,$28,$86,$38,$57,$71 		; 3.8172886385771
  DEFB $C2,$15,$09,$44,$99,$47,$48,$01		; -15.094499474801
  DEFB $42,$42,$05,$86,$89,$66,$73,$55		; 42.048689667355
  DEFB $c2,$76,$70,$58,$59,$68,$32,$91		; -76.605859683291
  DEFB $42,$81,$60,$52,$49,$27,$55,$13		; 81.605249275513        ->  .7968968E-1
  DEFB $c2,$41,$34,$17,$02,$24,$03,$98		; -41.341702240398       -> -.6459637
  DEFB $41,$62,$83,$18,$53,$07,$17,$96		; 6.2831853071796        -> 1.570796

FP_ATNTAB:
  DEFB $08	; 8 values                      ; Approx. conversion of list
  DEFB $BF,$52,$08,$69,$39,$04,$00,$00		; -1/19   =~ -0.05208693904    (slightly smaller)
  DEFB $3F,$75,$30,$71,$49,$13,$48,$00		;  1/13   =~  0.0753071491348  (slightly smaller)
  DEFB $bf,$90,$81,$34,$32,$24,$70,$50		; -1/11   =~ -0.09081343224705
  DEFB $40,$11,$11,$07,$94,$18,$40,$29		;  1/9    =~  0.11110794184029
  DEFB $C0,$14,$28,$57,$08,$55,$48,$84		; -1/7    =~ -0.14285708554884
  DEFB $40,$19,$99,$99,$99,$94,$89,$67		;  1/5    =~  0.19999999948967
  DEFB $C0,$33,$33,$33,$33,$33,$31,$60		; -1/3    =~ -0,3333333333316
  DEFB $41,$10,$00,$00,$00,$00,$00,$00		;  1/1    =  1



; Test sign of FPREG

	;PUT SIGN OF FAC IN A
	;ALTERS A ONLY
	;LEAVES FAC ALONE
	;NOTE: TO TAKE ADVANTAGE OF THE RST INSTRUCTIONS TO SAVE BYTES, FSIGN IS USUALLY DEFINED TO BE AN RST.
	;"FSIGN" IS EQUIVALENT TO "CALL SIGN"
	;THE FIRST FEW INSTRUCTIONS OF SIGN (THE ONES BEFORE SIGNC) ARE DONE IN THE 8 BYTES AT THE RST LOCATION.

SIGN:
  LD A,(FACCU)         ; Get sign of FPREG
  OR A                                                             ;CHECK IF THE NUMBER IS ZERO
  RET Z                ; RETurn if number is zero                  ;IT IS, A IS ZERO
  DEFB $FE             ; CP 2Fh ..hides the "CPL" instruction      ;"CPI" AROUND NEXT BYTE

FCOMPS:
  CPL                  ; Invert sign         ;ENTRY FROM FCOMP, COMPLEMENT SIGN

  ; --- START PROC L2E78 ---
ICOMPS:
  RLA                  ; Sign bit to carry   ;ENTRY FROM ICOMP, PUT SIGN BIT IN CARRY

  ; --- START PROC L2E79 ---
SIGNS:
  SBC A,A              ; Carry to all bits of A      ;A=0 IF CARRY WAS 0, A=377 IF CARRY WAS 1
  RET NZ               ; Return -1 if negative       ;RETURN IF NUMBER WAS NEGATIVE
  INC A                ; Bump to +1                  ;PUT ONE IN A IF NUMBER WAS POSITIVE
  RET                  ; Positive - Return +1        ;ALL DONE


;ZERO FAC
;ALTERS A ONLY
;EXITS WITH A=0
;BY OUR FLOATING POINT FORMAT, THE NUMBER IS ZERO IF THE EXPONENT IS ZERO

; Routine at 11901
;
; Used by the routines at DADD3, DMUL and __FIX.
ZERO:
  XOR A                 ; Result is zero           ;ZERO A
  LD (FACCU),A          ; Save result as zero      ;ZERO THE FAC'S EXPONENT, ENTRY IF A=0
  RET                                              ;ALL DONE


;
;	;GET THE VALTYP AND SET CONDITION CODES AS FOLLOWS:
;;CONDITION CODE		TRUE SET	FALSE SET
;;SIGN			INT=2		STR,SNG,DBL
;;ZERO			STR=3		INT,SNG,DBL
;;ODD PARITY		SNG=4		INT,STR,DBL
;;NO CARRY		DBL=10		INT,STR,SNG
;GETYPE:	LDA	VALTYP		;GET THE VALTYP
;	CPI	10		;SET CARRY CORRECTLY
;	DCR	A		;SET THE OTHER CONDITION CODES CORRECTLY
;	DCR	A		; WITHOUT AFFECTING CARRY
;	DCR	A
;	RET	*			;ALL DONE


; 'ABS' BASIC function

	;ABSOLUTE VALUE OF FAC
	;ALTERS A,B,C,D,E,H,L

;
; Routine at 11906
__ABS:
  CALL VSIGN         ;GET THE SIGN OF THE FAC IN A
  RET P              ;IF IT IS POSITIVE, WE ARE DONE


; Invert number sign

	;NEGATE ANY TYPE VALUE IN THE FAC
	;ALTERS A,B,C,D,E,H,L

;
; Used by the routines at __FIX, L3301 and OPRND.
INVSGN:
  RST GETYPR         ;SEE WHAT KIND OF NUMBER WE HAVE
  JP M,INEG          ;WE HAVE AN INTEGER, NEGATE IT THAT WAY
  JP Z,TM_ERR        ;BLOW UP ON STRINGS,   If string type, Err $0D - "Type mismatch"
                     ;FALL INTO NEG TO NEGATE A SNG OR DBL


; Invert number sign

	;NEGATE NUMBER IN THE FAC
	;ALTERS A,H,L
	;NOTE: THE NUMBER MUST BE PACKED

;
; This entry point is used by the routines at __COS, NEGAFT, __FIX, IMULT and FSUB.
NEG:
  LD HL,FACCU         ;GET POINTER TO SIGN

INVSGN_1:
  LD A,(HL)           ;GET SIGN
  OR A
  RET Z
  XOR $80             ;COMPLEMENT SIGN BIT
  LD (HL),A           ;SAVE IT
  RET                 ;ALL DONE


; 'SGN' BASIC function

	;SGN FUNCTION
	;ALTERS A,H,L
;
; Routine at 11927
__SGN:
  CALL VSIGN          ;GET THE SIGN OF THE FAC IN A    ; Test sign of FPREG

;ENTRY TO CONVERT A SIGNED NUMBER IN A TO AN INTEGER
; Signed char to signed int conversion, then return
; Get back from function, result in A (signed)
;
; This entry point is used by the routines at DOCMP, CAS_EOF, FN_PLAY and __STRIG.
CONIA:                ;ENTRY TO CONVERT A SIGNED NUMBER IN A TO AN INTEGER
  LD L,A              ;PUT IT IN THE LO POSITION
  RLA                 ;EXTEND THE SIGN TO THE HO     ; Sign bit to carry
  SBC A,A                                            ; Carry to all bits of A
  LD H,A              
  JP MAKINT           ;RETURN THE RESULT AND SET VALTYP


; Test sign in number

	;GET THE SIGN OF THE VALUE IN THE FAC IN A
	;ALTERS A,H,L
;
; Routine at 11937
;
; Used by the routines at __ABS, __SGN and __IF.
VSIGN:
  RST GETYPR          ;SEE WHAT KIND OF A NUMBER WE HAVE
  JP Z,TM_ERR         ;BLOW UP ON STRINGS
  JP P,SIGN           ;SINGLE AND DOUBLE PREC. WORK THE SAME
  LD HL,(FACLOW)      ;GET THE INTEGER ARGUMENT


	;ENTRY TO FIND THE SIGN OF (HL)
	;ALTERS A ONLY
ISIGN:
  LD A,H              ;GET ITS SIGN
  OR L                ;CHECK IF THE NUMBER IS ZERO
  RET Z               ;IT IS, WE ARE DONE
  LD A,H              ;IT ISN'T, SIGN IS THE SIGN OF H
  JR ICOMPS           ;GO SET A CORRECTLY


; Put FP value on stack

	;FLOATING POINT MOVEMENT ROUTINES
	;PUT FAC ON STACK
	;ALTERS D,E
;
; Routine at 11953
; Used by the routines at IADD, IMULT, IDIV and CGTCNT.
PUSHF:
  EX DE,HL            ; Save code string address        ;SAVE (HL)
  LD HL,(FACLOW)      ; LSB,NLSB of FPREG               ;GET LO'S
  EX (SP),HL          ; Stack them,get return           ;SWITCH LO'S AND RET ADDR
  PUSH HL             ; Re-save return                  ;PUT RET ADDR BACK ON STACK
  LD HL,(FACCU)       ; MSB and exponent of FPREG       ;GET HO'S
  EX (SP),HL          ; Stack them,get return           ;SWITCH HO'S AND RET ADDR
  PUSH HL             ; Re-save return                  ;PUT RET ADDR BACK ON STACK
  EX DE,HL            ; Restore code string address     ;GET OLD (HL) BACK
  RET                                                   ;ALL DONE

; Routine at 11966
;
; Used by the routine at DOSND.
MOVFM:
  CALL LOADFP         ; Number at HL to BCDE       ;GET NUMBER IN REGISTERS
                                                   ;FALL INTO MOVFR AND PUT IT IN FAC

; Move BCDE to FPREG
; a.k.a. MOVFR
;
	;MOVE REGISTERS (B,C,D,E) TO FAC
	;ALTERS D,E
;
FPBCDE:
  EX DE,HL            ; Save code string address          ;GET LO'S IN (HL)
  LD (FACLOW),HL      ; Save LSB,NLSB of number           ;PUT THEM WHERE THEY BELONG
  LD H,B              ; Exponent of number                ;GET HO'S IN (HL)
  LD L,C              ; MSB of number
  LD (FACCU),HL       ; Save MSB and exponent             ;PUT HO'S WHERE THEY BELONG
  EX DE,HL            ; Restore code string address       ;GET OLD (HL) BACK
  RET                                                     ;ALL DONE


; Load FP reg to BCDE
; a.k.a. MOVRF
;
	;MOVE FAC TO REGISTERS (B,C,D,E)
	;ALTERS B,C,D,E,H,L
;
; Routine at 11980
BCDEFP:
  LD HL,(FACLOW)      ; Point to FPREG                    ;GET POINTER TO FAC

; Load FP value pointed by HL to BCDE,
; a.k.a. MOVRM
;
;GET NUMBER IN REGISTERS (B,C,D,E) FROM MEMORY [(HL)]
;ALTERS B,C,D,E,H,L
;AT EXIT (HL):=(HL)+4
;
  EX DE,HL            
  LD HL,(FACCU)       
  LD C,L              
  LD B,H              
  RET                 
                      

; Load single precision FP value from (HL) into BCDE in reverse byte order
; a.k.a. LOADFP_CBED
;
; Routine at 11990
; Used by the routine at __NEXT.
HLBCDE:
  LD C,(HL)
  INC HL
  LD B,(HL)
  INC HL
  LD E,(HL)
  INC HL
  LD D,(HL)
  INC HL
  RET


; Load FP value pointed by HL to BCDE,
; a.k.a. MOVRM
;
;GET NUMBER IN REGISTERS (B,C,D,E) FROM MEMORY [(HL)]
;ALTERS B,C,D,E,H,L
;AT EXIT (HL):=(HL)+4
;
; Routine at 11999
; Used by the routines at MOVFM, L324B, __NEXT and GNXARY.
LOADFP:
  LD E,(HL)         ; Get LSB of number                 ;GET LO
  INC HL                                                ;POINT TO MO
; This entry point is used by the routine at PRS1.
LOADFP_0:
  LD D,(HL)         ; Get NMSB of number                ;GET MO, ENTRY FOR BILL
  INC HL                                                ;POINT TO HO
  LD C,(HL)         ; Get MSB of number                 ;GET HO
  INC HL                                                ;POINT TO EXPONENT
  LD B,(HL)         ; Get exponent of number            ;GET EXPONENT

INCHL:
  INC HL            ; Used for conditional "INC HL"     ;INC POINTER TO BEGINNING OF NEXT NUMBER
  RET                                                   ;ALL DONE


	;MOVE NUMBER FROM FAC TO MEMORY [(HL)]
	;ALTERS A,B,D,E,H,L
	;a.k.a. MOVMF
; Routine at 12008
; Used by the routine at __NEXT.
; copy number value from FPREG (FP accumulator) to HL
FPTHL:
  LD DE,FACCU       ; Point to FPREG                    ;GET POINTER TO FAC
                                                        ;FALL INTO MOVE
	;MOVE NUMBER FROM (DE) TO (HL)
	;ALTERS A,B,D,E,H,L
	;EXITS WITH (DE):=(DE)+4, (HL):=(HL)+4
  LD B,$04          ; 4 bytes to move    ;SET COUNTER
  JR MOVE1   		                     ;CONTINUE WITH THE MOVE

; Routine at 12015
;
; Used by the routine at __NEXT.
HL_ARG:
  LD DE,ARG         ;ENTRY TO SWITCH (DE) AND (HL)

; Copy number value from HL to DE
	;MOVE ANY TYPE VALUE (AS INDICATED BY VALTYP) FROM (DE) TO (HL)
	;ALTERS A,B,D,E,H,L
MOVVFM:
  EX DE,HL
  
; This entry point is used by the routines at __LET, __SWAP, TSTOPL and LHSMID.
; Copy number value from DE to HL
  ; --- START PROC L2EF3 ---
VMOVE:
  LD A,(VALTYP)    ;GET THE LENGTH OF THE NUMBER                           
  LD B,A           ;SAVE IT AWAY  (number of bytes to move)      
  
; This entry point is used by the routines at __RND, GET_RNDX, FPTHL and MAKTKN.
; Copy B bytes from DE to HL
                                 
  ; --- START PROC L2EF7 ---
MOVE1:
  LD A,(DE)         ; Get source            ;GET WORD, ENTRY FROM VMOVMF
  LD (HL),A         ; Save destination      ;PUT IT WHERE IT BELONGS
  INC DE            ; Next source           ;INCREMENT POINTERS TO NEXT WORD
  INC HL            ; Next destination
  DJNZ MOVE1        ; Copy B bytes from DE to HL
  RET

; Routine at 12030
;
; Used by the routine at DMUL.
; Similar to LDDR but moving from DE to HL, B times.
LDDR_DEHL:
  LD A,(DE)
  LD (HL),A
  DEC DE
  DEC HL
  DJNZ LDDR_DEHL
  RET


	;MOVE ANY TYPE VALUE FROM MEMORY [(HL)] TO FAC
	;ALTERS A,B,D,E,H,L
; Routine at 12037
VMOVFA:
  LD HL,ARG         ;ENTRY FROM DADD, MOVE ARG TO FAC

; This entry point is used by the routines at NUMCON, OPRND and __NEXT.
VMOVFM:
  LD DE,MOVVFM 		;GET ADDRESS OF LOCATION THAT DOES  ; Copy number value from HL to DE
  JR VMVVFM         ; AN "XCHG" AND FALLS INTO MOVE1


	;MOVE ANY TYPE VALUE FROM FAC TO MEMORY [(HL)]
	;ALTERS A,B,D,E,H,L
; Routine at 12045
; Used by the routines at DOSND.
VMOVAF:
  LD HL,ARG         ;ENTRY FROM FIN, DMUL10, DDIV10


	;MOVE FAC TO ARG
; This entry point is used by the routines at DOFN and __NEXT.
  ; --- START PROC L2F10 ---
VMOVMF:
  LD DE,VMOVE   		;GET ADDRESS OF MOVE SUBROUTINE  (Copy number value from DE to HL)
  
; This entry point is used by the routine at VMOVFA.
VMVVFM:
  PUSH DE               ;SHOVE IT ON THE STACK
;VDFACS:
  LD DE,FACCU           ;GET FIRST ADDRESS FOR INT, STR, SNG
  LD A,(VALTYP)         ;GET THE VALUE TYPE
  CP $04
  RET NC                ;GO MOVE IT IF WE DO NOT HAVE A DBL
  LD DE,FACLOW          ;WE DO, GET LO ADDR OF THE DBL NUMBER
  RET                   ;GO DO THE MOVE


;	COMPARE TWO NUMBERS

	;COMPARE TWO SINGLE PRECISION NUMBERS
	;A=1 IF ARG .LT. FAC
	;A=0 IF ARG=FAC
	;A=-1 IF ARG .GT. FAC
	;DOREL DEPENDS UPON THE FACT THAT FCOMP RETURNS WITH CARRY ON
	; IFF A HAS 377
	;ALTERS A,H,L

; aka CMPNUM, Compare FP reg to BCDE
; Routine at 12065
;
; Used by the routines at CONIS2, GETWORD_HL, CMPONE and __NEXT.
FCOMP:
  LD A,C            ; Get exponent of number
  OR A              ;CHECK IF ARG IS ZERO
  JP Z,SIGN         ; Zero - Test sign of FPREG
  LD HL,FCOMPS      ; Return relation routine           ;WE JUMP TO FCOMPS WHEN WE ARE DONE
  PUSH HL           ; Save for return                   ;PUT THE ADDRESS ON THE STACK
  CALL SIGN			; Test sign of FPREG                ;CHECK IF FAC IS ZERO
  LD A,C            ; Get MSB of number                 ;IF IT IS, RESULT IS MINUS THE SIGN OF ARG
  RET Z             ; FPREG zero - Number's MSB         ;IT IS
  LD HL,FACCU       ; MSB of FPREG                      ;POINT TO SIGN OF FAC
  XOR (HL)          ; Combine signs                     ;SEE IF THE SIGNS ARE THE SAME
  LD A,C            ; Get MSB of number                 ;IF THEY ARE DIFFERENT, RESULT IS SIGN OF ARG
  RET M             ; Exit if signs different           ;THEY ARE DIFFERENT
  CALL CMPFP        ; Compare FP numbers                ;CHECK THE REST OF THE NUMBER
; This entry point is used by the routine at XDCOMP.
;FCOMPD:
  RRA               ; Get carry to sign                 ;NUMBERS ARE DIFFERENT, CHANGE SIGN IF
  XOR C             ; Combine with MSB of number        ; BOTH NUMBERS ARE NEGATIVE
  RET                                                   ;GO SET UP A

; Routine at 12091
;
; Used by the routine at FCOMP.
; 
CMPFP:
  LD A,C            ; Point to exponent                 ;POINT TO EXPONENT
  CP (HL)           ; Get exponent                      ;GET EXPONENT OF ARG
  RET NZ            ; Compare exponents                 ;COMPARE THE TWO
  INC HL            ; Different                         ;NUMBERS ARE DIFFERENT
  LD A,B            ; Point to MBS                      ;POINT TO HO
  CP (HL)           ; Get MSB                           ;GET HO OF ARG
  RET NZ            ; Compare MSBs                      ;COMPARE WITH HO OF FAC
  INC HL            ; Different                         ;THEY ARE DIFFERENT
  LD A,E            ; Point to NMSB                     ;POINT TO MO OF FAC
  CP (HL)           ; Get NMSB                          ;GET MO OF ARG
  RET NZ            ; Compare NMSBs                     ;COMPARE WITH MO OF FAC
  INC HL            ; Different                         ;THE NUMBERS ARE DIFFERENT
  LD A,D            ; Point to LSB                      ;POINT TO LO OF FAC
  SUB (HL)          ; Get LSB                           ;GET LO OF ARG
  RET NZ            ; Compare LSBs                      ;SUBTRACT LO OF FAC
  POP HL            ; Different                         ;NUMBERS ARE DIFFERENT
  POP HL            ; Drop RETurn                       ;NUMBERS ARE THE SAME, DON'T SCREW UP STACK
  RET               ; Drop another RETurn               
                                                        ;ALL DONE

; Integer COMPARE
; Compare the signed integer in DE to the signed integer in HL
;
	;COMPARE TWO INTEGERS
	;A=1 IF (DE) .LT. (HL)
	;A=0 IF (DE)=(HL)
	;A=-1 IF (DE) .GT. (HL)
	;ALTERS A ONLY
;
; Routine at 12109
; Used by the routine at __NEXT.
ICOMP:
  LD A,D            ;ARE THE SIGNS THE SAME?
  XOR H             
  LD A,H            ;IF NOT, ANSWER IS THE SIGN OF (HL)
  JP M,ICOMPS       ;THEY ARE DIFFERENT
  CP D              ;THEY ARE THE SAME, COMPARE THE HO'S
  JR NZ,ICOMP_0     ;GO SET UP A
  LD A,L            ;COMPARE THE LO'S
  SUB E             
  RET Z             ;ALL DONE, THEY ARE THE SAME
ICOMP_0:            
  JP SIGNS          ;GO SET UP A


	;COMPARE TWO DOUBLE PRECISION NUMBERS
	;A=1 IF ARG .LT. FAC
	;A=0 IF ARG=FAC
	;A=-1 IF ARG .GT. FAC
	;ALTERS A,B,C,D,E,H,L

; a.k.a. DCOMPD
; Routine at 12124
;
; Used by the routines at CMPPHL, DCOMP, L391A and __NEXT.
XDCOMP:
  LD DE,ARG         ;GET POINTER TO ARG
  LD A,(DE)         ;SEE IF ARG=0
  OR A
  JP Z,SIGN         ;ARG=0, GO SET UP A
  LD HL,FCOMPS      ;PUSH FCOMPS ON STACK SO WE WILL RETURN TO
  PUSH HL           ; TO IT AND SET UP A
  CALL SIGN         ;SEE IF FAC=0
  LD A,(DE)         ;GET SIGN OF ARG
  LD C,A            ;SAVE IT FOR LATER
  RET Z             ;FAC=0, SIGN OF RESULT IS SIGN OF ARG
  LD HL,FACCU       ;POINT TO SIGN OF FAC
  XOR (HL)          ;SEE IF THE SIGNS ARE THE SAME
  LD A,C            ;IF THEY ARE, GET THE SIGN OF THE NUMBERS
  RET M             ;THE SIGNS ARE DIFFERENT, GO SET A
  LD B,$08          ;SET UP A COUNT
XDCOMP_0:           
  LD A,(DE)         ;GET A BYTE FROM ARG
  SUB (HL)          ;COMPARE IT WITH THE FAC
  JR NZ,FCOMPD      ;THEY ARE DIFFERENT, GO SET UP A
  INC DE            ;THEY ARE THE SAME, EXAMINE THE NEXT LOWER
  INC HL            ; ORDER BYTES
  DJNZ XDCOMP_0     ;ARE WE DONE? NO, COMPARE THE NEXT BYTES
  POP BC            ;THEY ARE THE SAME, GET FCOMPS OFF STACK
  RET               ;ALL DONE

FCOMPD:
  RRA               ; Get carry to sign                 ;NUMBERS ARE DIFFERENT, CHANGE SIGN IF
  XOR C             ; Combine with MSB of number        ; BOTH NUMBERS ARE NEGATIVE
  RET                                                    ;GO SET UP A


; Compare the double precision numbers in FAC1 and ARG
	;COMPARE TWO DOUBLE PRECISION NUMBERS
	;A=1 IF ARG .GT. FAC
	;A=0 IF ARG=FAC
	;A=-1 IF ARG .LT. FAC
	;NOTE:	THIS IS THE REVERSE OF ICOMP, FCOMP AND XDCOMP
	;ALTERS A,B,C,D,E,H,L
; Double precision COMPARE
; Routine at 12163
DCOMP:
  CALL XDCOMP       ;COMPARE THE TWO NUMBERS
  JP NZ,FCOMPS      ;NEGATE THE ANSWER, MAKE SURE THE CARRY COMES
  RET               ; OUT CORRECT FOR DOCMP



;  CONVERSION ROUTINES BETWEEN INTEGER, SINGLE AND DOUBLE PRECISION
	

; 'CINT' BASIC function
; a.k.a. FRCINT
	;FORCE THE FAC TO BE AN INTEGER
	;ALTERS A,B,C,D,E,H,L
;
; Routine at 12170
; Used by the routines at __EXP, EVAL, NOT, DANDOR, DEPINT, VARGET, __CIRCLE,
; CGTCNT, DOSND and PARMADDR.
  ; --- START PROC L2F8A ---
__CINT:
  RST GETYPR        ;SEE WHAT WE HAVE
  LD HL,(FACLOW)    ;GET FACLO+0,1 IN CASE WE HAVE AN INTEGER
  RET M             ;WE HAVE AN INTEGER, ALL DONE
  JP Z,TM_ERR       ;WE HAVE A STRING, THAT IS A "NO-NO"
  CALL CINT         
  JP C,OV_ERR
  EX DE,HL


; Get back from function, result in HL
;
	;PUT (HL) IN FACLO, SET VALTYP TO INT
	;ALTERS A ONLY
;
; This entry point is used by the routines at __SGN, CONIS2, __FIX, IMULT,
; IMULDV, IN_PRT, OPRND, OCTCNS, __POS, FN_POINT, __CIRCLE and CGTCNT.
MAKINT:
  LD (FACLOW),HL    ;STORE THE NUMBER IN FACLO
; This entry point is used by the routine at IMOD.
VALINT:
  LD A,$02          ;SET VALTYP TO "INTEGER"
; This entry point is used by the routine at VALSNG.
SETTYPE:
  LD (VALTYP),A     ;ENTRY FROM CONDS
  RET               ;ALL DONE

; Routine at 12194
;
; Used by the routine at L3301.
CONIS2:
  LD BC,$32C5       ; BCDE = -32768  (float)
  LD DE,$8076       
  CALL FCOMP        ;CHECK IF NUMBER IS -32768, ENTRY FROM FIN
  RET NZ            ;ERROR:  IT CAN'T BE CONVERTED TO AN INTEGER
  LD HL,$8000       ;IT IS -32768, PUT IT IN (HL)

; This entry point is used by the routine at IADD.
CONIS1:
  POP DE
  JR MAKINT         ;STORE IT IN THE FAC AND SET VALTYP

  
; 'CSNG' BASIC function
;
	;FORCE THE FAC TO BE A SINGLE PRECISION NUMBER
	;ALTERS A,B,C,D,E,H,L
;
;  Convert number to single precision
__CSNG:
  RST GETYPR        ;SEE WHAT KIND OF NUMBER WE HAVE
  RET PO            ;WE ALREADY HAVE A SNG, ALL DONE
  JP M,CONSI        ;WE HAVE AN INTEGER, CONVERT IT
  JP Z,TM_ERR       ;STRINGS!! -- ERROR!!
                    ;DBL PREC -- FALL INTO CONSD
;CONSD:
  CALL VALSNG       ;IF NOT INTEGER FORCE DOUBLE TO S.P.
  CALL FTCH_SNG     ;Fetch in single precision
  INC HL
  LD A,B
  OR A
  RRA               ;WANT ROUND-UP IF HIGH BIT SET
  LD B,A
  JP BNORM_8        ;GO ROUND THE NUMBER



; Convert the signed integer in FAC1 to single precision.
	;CONVERT AN INTEGER TO A SINGLE PRECISION NUMBER
	;ALTERS A,B,C,D,E,H,L
  ; --- START PROC CONSI ---
CONSI:
  LD HL,(FACLOW)    ;GET THE INTEGER
  ; --- START PROC HL_CSNG ---
HL_CSNG:
  LD A,H            ;SET UP REGISTERS FOR FLOATR
  ; --- START PROC HL_CSNG_A ---
HL_CSNG_A:
  OR A
  PUSH AF
  CALL M,INEGHL
  CALL VALSNG              ;SET VALTYP TO "SINGLE PRECISION"
  EX DE,HL
  LD HL,$0000
  LD (FACCU),HL
  LD (FACLOW),HL           ; DECIMAL ACCUMULATOR + 2
  LD A,D
  OR E
  JP Z,POPAF
  LD BC,$0500		; 1280
  LD HL,FACCU+1
  PUSH HL
  LD HL,HL_CSNG_CONST
HL_CSNG_1:
  LD A,$FF
  PUSH DE
  LD E,(HL)
  INC HL
  LD D,(HL)
  INC HL
  EX (SP),HL
  PUSH BC
HL_CSNG_2:
  LD B,H
  LD C,L
  ADD HL,DE
  INC A
  JR C,HL_CSNG_2
  LD H,B
  LD L,C
  POP BC
  POP DE
  EX DE,HL
  INC C
  DEC C
  JR NZ,HL_CSNG_3
  OR A
  JR Z,HL_CSNG_6
  PUSH AF
  LD A,40h  		; '@'
  ADD A,B
  LD (FACCU),A
  POP AF
HL_CSNG_3:
  INC C
  EX (SP),HL
  PUSH AF
  LD A,C
  RRA
  JR NC,HL_CSNG_4
  POP AF
  ADD A,A			; *16
  ADD A,A
  ADD A,A
  ADD A,A
  LD (HL),A
  JR HL_CSNG_5


HL_CSNG_4:
  POP AF
  OR (HL)
  LD (HL),A
  INC HL
HL_CSNG_5:
  EX (SP),HL
HL_CSNG_6:
  LD A,D
  OR E
  JR Z,HL_CSNG_7
  DJNZ HL_CSNG_1
HL_CSNG_7:
  POP HL
  POP AF
  RET P
  JP NEG


HL_CSNG_CONST:
  DEFB $F0,$D8,$18,$FC,$9C
  DEFB $FF,$F6,$FF,$FF,$FF
  


; 'CDBL' BASIC function
	;FORCE THE FAC TO BE A DOUBLE PRECISION NUMBER
	;ALTERS A,B,C,D,E,H,L
;
; This entry point is used by the routines at __EXP, FINFRC, FOUINI, L3878, and ISFUN.
; Position: $303A
__CDBL:
  RST GETYPR           ;SEE WHAT KIND OF NUMBER WE HAVE
  RET NC               ;WE ALREADY HAVE A DBL, WE ARE DONE
  JP Z,TM_ERR          ;GIVE AN ERROR IF WE HAVE A STRING
  CALL M,CONSI         ;CONVERT TO SNG IF WE HAVE AN INT
                       ;FALL INTO CONDS AND CONVERT TO DBL

	;CONVERT A SINGLE PRECISION NUMBER TO A DOUBLE PRECISION ONE
	;ALTERS A,H,L
; This entry point is used by the routines at __LOG, L324B, FMULT, DIVIDE and L3878.
CONDS:
  LD HL,$0000          ;ZERO H,L
  LD (FACCU+4),HL      ;CLEAR THE FOUR LOWER BYTES IN THE DOUBLE
  LD (FACCU+6),HL      ; PRECISION NUMBER
  LD A,H
  LD (FACCU+8),A

; Set type to "double precision"
;
; This entry point is used by the routines at __EXP and DEXP.
VALDBL:
  LD A,$08
  JR VALSNG_0

; Set type to "single precision"
;
; Routine at 12371
VALSNG:
  LD A,$04             ;SET VALTYP TO "SINGLE PRECISION"
; This entry point is used by the routine at L3034.
VALSNG_0:
  JP SETTYPE


; Test for string type, 'Type Error' if it is not
; a.k.a. CHKSTR, FRCSTR
;
	;FORCE THE FAC TO BE A STRING
	;ALTERS A ONLY
;
; Routine at 12376
; Used by the routines at __LINE, ISFUN, USING, L61C4, CONCAT, GETSTR, FN_INSTR and LHSMID.
TSTSTR:
  RST GETYPR          ;SEE WHAT KIND OF VALUE WE HAVE
  RET Z               ;WE HAVE A STRING, EVERYTHING IS OK
  JP TM_ERR           ;WE DON'T HAVE A STRING, FALL INTO TMERR

; Data block at 12381
  ; --- START PROC CINT ---
CINT:
  LD HL,CINT_RET2
  PUSH HL
  LD HL,FACCU
  LD A,(HL)            ;GET SIGN BYTE
  AND $7F              ;CLEAR SIGN
  CP $46               ;SEE IF TOO LARGE
  RET NC               ; RET with CY set
  SUB $41
  JR NC,CINT_SUB
  OR A                 ; reset CY
  POP DE
  LD DE,$0000
  RET

CINT_SUB:
  INC A
  LD B,A
  LD DE,$0000
  LD C,D
  INC HL
CINT_SUB_0:
  LD A,C
  INC C
  RRA
  LD A,(HL)
  JR C,CINT_SUB_1
  RRA
  RRA
  RRA
  RRA
  JR CINT_SUB_2

CINT_SUB_1:
  INC HL
CINT_SUB_2:
  AND $0F
  LD (DECTMP),HL
  LD H,D
  LD L,E
  ADD HL,HL
  RET C
  ADD HL,HL
  RET C
  ADD HL,DE
  RET C
  ADD HL,HL
  RET C
  LD E,A
  LD D,$00
  ADD HL,DE
  RET C
  EX DE,HL
  LD HL,(DECTMP)
  DJNZ CINT_SUB_0
  LD HL,$8000		; 32768
  RST DCOMPR		; Compare HL with DE.
  LD A,(FACCU)
  RET C
  JR Z,CINT_RET1
  POP HL
  OR A
  RET P
  EX DE,HL
  CALL INEGHL
  EX DE,HL
  OR A
  RET

CINT_RET1:
  OR A
  RET P
  POP HL
  RET


; Routine at 12474
CINT_RET2:
  SCF
  RET

; Routine at 12476
DCXBRT:
  DEC BC            ;THIS IS FOR BILL.  C WILL NEVER BE ZERO
  RET               ; (THE MSB WILL ALWAYS BE ONE) SO "DCX	B"
                    ; AND "DCR	C" ARE FUNCTIONALLY EQUIVALENT


; 'FIX' BASIC function
	; THIS IS THE FIX (X) FUNCTION. IT RETURNS
	; FIX(X)=SGN(X)*INT(ABS(X))
; Double Precision to Integer conversion
; a.k.a. FIXER
; Routine at 12478
__FIX:
  RST GETYPR        ;GET VALTYPE OF ARG
  RET M             ;INT, DONE
  CALL SIGN         ;GET SIGN
  JP P,__INT        ;IF POSITIVE, JUST CALL REGULAR INT CODE
  CALL NEG          ;NEGATE IT
  CALL __INT        ;GET THE INTEGER OF IT
  JP INVSGN         ;NOW RE-NEGATE IT


; 'INT' BASIC function
;
	;GREATEST INTEGER FUNCTION
	;ALTERS A,B,C,D,E,H,L
;
; a.k.a. VINT
; This entry point is used by the routines at __SIN and L391A.
__INT:
  RST GETYPR        ;SEE WHAT TYPE OF A NUMBER WE HAVE
  RET M             ;IT IS AN INTEGER, ALL DONE
  LD HL,FACCU+8     ;GET EXPONENT
  LD C,$0E
  JR NC,__INT_0
  JP Z,TM_ERR				; If string type, Err $0D - "Type mismatch"
  LD HL,FACCU+4
  LD C,$06			; TK_ABS ?
__INT_0:
  LD A,(FACCU)
  OR A
  JP M,__FIX_2
  AND $7F			; ABS
  SUB $41
  JP C,ZERO
  INC A
  SUB C
  RET NC
  CPL
  INC A
  LD B,A
__INT_1:
  DEC HL
  LD A,(HL)
  AND $F0
  LD (HL),A
  DEC B
  RET Z
  XOR A
  LD (HL),A
  DJNZ __INT_1
  RET
  
__FIX_2:
  AND $7F			; ABS
  SUB $41
  JR NC,__FIX_3
  LD HL,$FFFF
  JP MAKINT
  
__FIX_3:
  INC A
  SUB C
  RET NC
  CPL
  INC A
  LD B,A
  LD E,$00
__FIX_4:
  DEC HL
  LD A,(HL)
  LD D,A
  AND $F0
  LD (HL),A
  CP D
  JR Z,__FIX_5
  INC E
__FIX_5:
  DEC B
  JR Z,__FIX_7
  XOR A
  LD (HL),A
  CP D
  JR Z,__FIX_6
  INC E
__FIX_6:
  DJNZ __FIX_4
__FIX_7:
  INC E
  DEC E
  RET Z
  LD A,C
  CP $06			; TK_ABS ?
  LD BC,$10C1		; BCDE = 1 (float) 
  LD DE,$0000
  JP Z,FADD
  EX DE,HL
  LD (ARG+6),HL
  LD (ARG+4),HL
  LD (ARG+2),HL
  LD H,B
  LD L,C
  LD (ARG),HL
  JP DADD


; Multiply DE by BC
; a.k.a. UMULT
	;INTEGER MULTIPLY FOR MULTIPLY DIMENSIONED ARRAYS
	; (DE):=(BC)*(DE)
	;OVERFLOW CAUSES A BS ERROR
	;ALTERS A,B,C,D,E
;
; Routine at 12618
; Used by the routine at DOSND.
MLDEBC:
  PUSH HL                                                   ;SAVE [H,L]
  LD HL,$0000			; Clear partial product             ;ZERO PRODUCT REGISTERS
  LD A,B				; Test multiplier                   ;CHECK IF (BC) IS ZERO
  OR C                                                      ;IF SO, JUST RETURN, (HL) IS ALREADY ZERO
  JR Z,MLDEBC_2			; Return zero if zero               ;THIS IS DONE FOR SPEED
  LD A,16				; 16 bits                           ;SET UP A COUNT
MLDBLP:                 
  ADD HL,HL				; Shift P.P left                    ;ROTATE (HL) LEFT ONE
  JP C,BS_ERR           ; "Subscript error" if overflow     ;CHECK FOR OVERFLOW, IF SO,
  EX DE,HL                                                  ; BAD SUBSCRIPT (BS) ERROR
  ADD HL,HL				; Shift multiplier left             ;ROTATE (DE) LEFT ONE
  EX DE,HL                                                  
  JR NC,NOMLAD			; Bit was zero - No add             ;ADD IN (BC) IF HO WAS 1
  ADD HL,BC				; Add multiplicand                  
  JP C,BS_ERR           ; "Subscript error" if overflow     ;CHECK FOR OVERFLOW
NOMLAD:                 
  DEC A					; Count bits                        ;SEE IF DONE
  JR NZ,MLDBLP          
MLDEBC_2:               
  EX DE,HL                                                  ;RETURN THE RESULT IN [D,E]
  POP HL                                                    ;GET BACK THE SAVED [H,L]
  RET



;
;	INTEGER ARITHMETIC CONVENTIONS
;
;INTEGER VARIABLES ARE 2 BYTE, SIGNED NUMBERS
;	THE LO BYTE COMES FIRST IN MEMORY
;
;CALLING CONVENTIONS:
;FOR ONE ARGUMENT FUNCTIONS:
;	THE ARGUMENT IS IN (HL), THE RESULT IS LEFT IN (HL)
;FOR TWO ARGUMENT OPERATIONS:
;	THE FIRST ARGUMENT IS IN (DE)
;	THE SECOND ARGUMENT IS IN (HL)
;	THE RESULT IS LEFT IN THE FAC AND IF NO OVERFLOW, (HL)
;IF OVERFLOW OCCURS, THE ARGUMENTS ARE CONVERTED TO SINGLE PRECISION
;WHEN INTEGERS ARE STORED IN THE FAC, THEY ARE STORED AT FACLO+0,1
;VALTYP(INTEGER)=2


; Integer SUB
	;INTEGER SUBTRTACTION	(HL):=(DE)-(HL)
	;ALTERS A,B,C,D,E,H,L
; Routine at 12647
ISUB:
  LD A,H               ;EXTEND THE SIGN OF (HL) TO B
  RLA                  ;GET SIGN IN CARRY
  SBC A,A
  LD B,A
  CALL INEGHL          ;NEGATE (HL)
  LD A,C               ;GET A ZERO
  SBC A,B              ;NEGATE SIGN
  JR IADD_0            ;GO ADD THE NUMBERS

; Routine at 12658
;
; Used by the routine at __NEXT.
IADD:
  LD A,H               ;EXTEND THE SIGN OF (HL) TO B
  RLA                  ;GET SIGN IN CARRY
  SBC A,A

; This entry point is used by the routine at ISUB.
IADD_0:
  LD B,A               ;SAVE THE SIGN
  PUSH HL              ;SAVE THE SECOND ARGUMENT IN CASE OF OVERFLOW
  LD A,D               ;EXTEND THE SIGN OF (DE) TO A
  RLA                  ;GET SIGN IN CARRY
  SBC A,A              
  ADD HL,DE            ;ADD THE TWO LO'S
  ADC A,B              ;ADD THE EXTRA HO
  RRCA                 ;IF THE LSB OF A IS DIFFERENT FROM THE MSB OF
  XOR H                ; H, THEN OVERFLOW OCCURED
  JP P,CONIS1          ;NO OVERFLOW, GET OLD (HL) OFF STACK AND WE ARE DONE, SAVE (HL) IN THE FAC ALSO
  PUSH BC              ;OVERFLOW -- SAVE EXTENDED SIGN OF (HL)
  EX DE,HL             ;GET (DE) IN (HL)
  CALL HL_CSNG         ;FLOAT IT
  POP AF               ;GET SIGN OF (HL) IN A
  POP HL               ;GET OLD (HL) BACK
  CALL PUSHF           ;PUT FIRST ARGUMENT ON STACK
  CALL HL_CSNG         ;FLOAT IT
  POP BC               ;GET PREVIOUS NUMBER OFF STACK
  POP DE
  JP FADD              ;ADD THE TWO NUMBERS


; Integer MULTIPLY
	;INTEGER MULTIPLICATION		(HL):=(DE)*(HL)
	;ALTERS A,B,C,D,E,H,L
; Routine at 12691
; Used by the routine at L390D.
IMULT:
  LD A,H               ;CHECK (HL) IF IS ZERO, IF SO
  OR L                 ; JUST RETURN.  THIS IS FOR SPEED.
  JP Z,MAKINT          ;UPDATE FACLO TO BE ZERO AND RETURN
  PUSH HL              ;SAVE SECOND ARGUMENT IN CASE OF OVERFLOW
  PUSH DE              ;SAVE FIRST ARGUMENT
  CALL IMULDV          ;FIX UP THE SIGNS
  PUSH BC              ;SAVE THE SIGN OF THE RESULT
  LD B,H               ;COPY SECOND ARGUMENT INTO (BC)
  LD C,L
  LD HL,$0000          ;ZERO (HL), THAT IS WHERE THE PRODUCT GOES
  LD A,16              ;SET UP A COUNT
IMULT_0:
  ADD HL,HL            ;ROTATE PRODUCT LEFT ONE
  JR C,IMULT5          ;CHECK FOR OVERLFOW
  EX DE,HL             ;ROTATE FIRST ARGUMENT LEFT ONE TO SEE IF
  ADD HL,HL            ; WE ADD IN (BC) OR NOT
  EX DE,HL
  JR NC,IMULT_1        ;DON'T ADD IN ANYTHING
  ADD HL,BC            ;ADD IN (BC)
  JR C,IMULT5          ;CHECK FOR OVERLFOW
IMULT_1:
  DEC A                ;ARE WE DONE?
  JR NZ,IMULT_0        ;NO, DO IT AGAIN
  POP BC               ;WE ARE DONE, GET SIGN OF RESULT
  POP DE               ;GET ORIGINAL FIRST ARGUMENT
; This entry point is used by the routine at DIVLP.
IMLDIV:
  LD A,H               ;ENTRY FROM IDIV, IS RESULT .GE. 32768?
  OR A
  JP M,IMULT_3         ;IT IS, CHECK FOR SPECIAL CASE OF -32768
  POP DE               ;RESULT IS OK, GET SECOND ARGUMENT OFF STACK
  LD A,B               ;GET THE SIGN OF RESULT IN A
  JP INEGA             ;NEGATE THE RESULT IF NECESSARY

IMULT_3:
  XOR $80              ;IS RESULT 32768?
  OR L                 ;NOTE: IF WE GET HERE FROM IDIV, THE RESULT
  JR Z,IMULT4          ; MUST BE 32768, IT CANNOT BE GREATER
  EX DE,HL             ;IT IS .GT. 32768, WE HAVE OVERFLOW
  JR IMULT5_0

IMULT5:
  POP BC               ;GET SIGN OF RESULT OFF STACK
  POP HL               ;GET THE ORIGINAL FIRST ARGUMENT
                       
IMULT5_0:
  CALL HL_CSNG         ;FLOAT IT
  POP HL               ;GET THE ORIGINAL SECOND ARGUMENT
  CALL PUSHF           ;SAVE FLOATED FIRST ARUMENT
  CALL HL_CSNG         ;FLOAT SECOND ARGUMENT
;FMULTT:
  POP BC
  POP DE               ;GET FIRST ARGUMENT OFF STACK, ENTRY FROM POLYX
  JP FMULT             ;MULTIPLY THE ARGUMENTS USING SINGLE PRECISION

IMULT4:
  LD A,B               ;IS RESULT +32768 OR -32768?
  OR A                 ;GET ITS SIGN
  POP BC               ;DISCARD ORIGINAL SECOND ARGUMENT
  JP M,MAKINT          ;THE RESULT SHOULD BE NEGATIVE, IT IS OK
  PUSH DE              ;IT IS POSITIVE, SAVE REMAINDER FOR MOD
  CALL HL_CSNG         ;FLOAT -32768
  POP DE               ;GET MOD'S REMAINDER BACK
  JP NEG               ;NEGATE -32768 TO GET 32768, WE ARE DONE

 
; Divide the signed integer in DE by the signed integer in HL.
;
	;INTEGER DIVISION	(HL):=(DE)/(HL)
	;REMAINDER IS IN (DE), QUOTIENT IN (HL)
	;ALTERS A,B,C,D,E,H,L
;
; Data block at 12774
INT_DIV:
  LD A,H
INT_DIV_0:
  OR L              ;CHECK FOR DIVISION BY ZERO
  JP Z,O_ERR   		;WE HAVE DIVISION BY ZERO!!  (Err $0B - "Division by zero")
  CALL IMULDV       ;FIX UP THE SIGNS
  PUSH BC           ;SAVE THE SIGN OF THE RESULT
  EX DE,HL          ;GET DENOMINATOR IN (HL)
  CALL INEGHL       ;NEGATE IT
  LD B,H            ;SAVE NEGATED DENOMINATOR IN (BC)
  LD C,L

; Routine at 12789
IDIV0:
  LD HL,$0000       ;ZERO WHERE WE DO THE SUBTRACTION
  LD A,17           ;SET UP A COUNT
  OR A              ;CLEAR CARRY 
  JR IDIV3          ;GO DIVIDE

DIVLP:
  PUSH HL           ;SAVE (HL) I.E. CURRENT NUMERATOR
  ADD HL,BC         ;SUBTRACT DENOMINATOR
  JR NC,IDIV2       ;WE SUBTRACTED TOO MUCH, GET OLD (HL) BACK
  INC SP            ;THE SUBTRACTION WAS GOOD, DISCARD OLD (HL)
  INC SP
  SCF				;NEXT BIT IN QUOTIENT IS A ONE
  DEFB $30          ; "JR NC,n" AROUND NEXT BYTE

IDIV2:
  POP HL            ;IGNORE THE SUBTRACTION, WE COULDN'T DO IT

IDIV3:
  RL E				;SHIFT IN THE NEXT QUOTIENT BIT
  RL D				
  ADC HL,HL			
  DEC A             ;ARE WE DONE?
  JR NZ,DIVLP       ;NO, DIVIDE AGAIN
  EX DE,HL          ;GET QUOTIENT IN (HL), REMAINDER IN (DE)
  POP BC            ;GET SIGN OF RESULT
  PUSH DE           ;SAVE REMAINDER SO STACK WILL BE ALRIGHT
  JP IMLDIV         ;CHECK FOR SPECIAL CASE OF 32768


	;GET READY TO MULTIPLY OR DIVIDE
	;ALTERS A,B,C,D,E,H,L
;
; Routine at 12821
; Used by the routine at IMULT.
IMULDV:
  LD A,H            ;GET SIGN OF RESULT
  XOR D
  LD B,A            ;SAVE IT IN B
  CALL INEGH        ;NEGATE SECOND ARGUMENT IF NECESARY
  EX DE,HL          ;PUT (DE) IN (HL), FALL IN AND NEGATE FIRST ARGUMENT IF NECESSARY


	;NEGATE H,L
	;ALTERS A,C,H,L
INEGH:
  LD A,H            ;GET SIGN OF (HL)
; This entry point is used by the routines at IMULT and IMOD.
INEGA:
  OR A              ;SET CONDITION CODES
  JP P,MAKINT       ;WE DON'T HAVE TO NEGATE, IT IS POSITIVE
                    ;SAVE THE RESULT IN THE FAC FOR WHEN
                    ; OPERATORS RETURN THROUGH HERE

; This entry point is used by the routines at ISUB and INEG.
INEGHL:
  XOR A             ;CLEAR A
  LD C,A            ;STORE A ZERO (WE USE THIS METHOD FOR ISUB)
  SUB L             ;NEGATE LO
  LD L,A            ;SAVE IT
  LD A,C            ;GET A ZERO BACK
  SBC A,H           ;NEGATE HO
  LD H,A            ;SAVE IT
  JP MAKINT         ;ALL DONE, SAVE THE RESULT IN THE FAC
                    ; FOR WHEN OPERATORS RETURN THROUGH HERE

  
	;INTEGER NEGATION
	;ALTERS A,B,C,D,E,H,L
;
; Routine at 12843
; Used by the routine at INVSGN.
INEG:
  LD HL,(FACLOW)    ;GET THE INTEGER
  CALL INEGHL       ;NEGATE IT
  LD A,H            ;GET THE HIGH ORDER
  XOR $80           ;CHECK FOR SPECIAL CASE OF 32768
  OR L
  RET NZ            ;IT DID NOT OCCUR, EVERYTHING IS FINE

; This entry point is used by the routines at NUMCON, OPRND, GIVDBL, FN_TIME and
; L7BA3.
INEG2:
  XOR A             ;WE HAVE IT, FLOAT 32768
  JP HL_CSNG_A


	;MOD OPERATOR
	;(HL):=(DE)-(DE)/(HL)*(HL),  (DE)=QUOTIENT
	;ALTERS A,B,C,D,E,H,L
;
; Routine at 12858
; Used by the routine at DANDOR.
IMOD:
  PUSH DE           ;SAVE (DE) FOR ITS SIGN
  CALL INT_DIV      ;DIVIDE AND GET THE REMAINDER
  XOR A             ;TURNOFF THE CARRY AND TRANFER
  ADD A,D           ;THE REMAINDER*2 WHICH IS IN [D,E]
  RRA               ;TO [H,L] DIVIDING BY TWO
  LD H,A
  LD A,E
  RRA
  LD L,A            ; ***WHG01*** FIX TO MOD OPERATOR
  CALL VALINT       ;SET VALTYP TO "INTEGER" IN CASE RESULT OF
  POP AF
  JR INEGA



; FLOATING POINT ADDITION AND SUBTRACTION
; ENTRY TO FADD WITH POINTER TO ARG IN (HL)


; LOADFP/FADD
; Load FP at (HL) to BCDE
;
; Routine at 12875,  this entry is not used by the core ROM
FADDS:
  CALL LOADFP            ;GET ARGUMENT INTO THE REGISTERS
                         ;DO THE ADDITION

; This entry point is used by the routines at __FIX, IADD, FSUB, GETWORD_HL and
; __NEXT.
FADD:
  CALL DEC_HL2ARG
  CALL CONDS
  JP DADD


;SUBTRACTION	FAC:=ARG-FAC

; Subtract the single precision numbers in FAC1 and BCDE
; aka, SUBCDE Subtract BCDE from FP reg
;
; Routine at 12887
FSUB:
  CALL NEG              ;NEGATE SECOND ARGUMENT
  JR FADD               ;FALL INTO FADD

; Routine at 12892
;
; Used by the routines at IMULT, __CIRCLE and CGTCNT.
FMULT:
  CALL DEC_HL2ARG
  CALL CONDS
  JP DMUL

; Routine at 12901
;
; Used by the routine at IDIV.
DIVIDE:
  POP BC
  POP DE
; This entry point is used by the routine at __CIRCLE.
FDIV:
  LD HL,(FACLOW)
  EX DE,HL
  LD (FACLOW),HL
  PUSH BC
  LD HL,(FACCU)
  EX (SP),HL
  LD (FACCU),HL
  POP BC
  CALL DEC_HL2ARG
  CALL CONDS
  JP DDIV

; Routine at 12928
;
; Used by the routines at FADDS, FMULT and DIVIDE.
DEC_HL2ARG:
  EX DE,HL
  LD (ARG+2),HL
  LD H,B
  LD L,C
  LD (ARG),HL
  LD HL,$0000
  LD (ARG+4),HL
  LD (ARG+6),HL
  RET

; Routine at 12947
;
DCRART:
  DEC A
  RET

; Routine at 12949
;
DCXHRT:
  DEC HL
  RET

; Routine at 12951
; 
POPHLRT:
  POP HL
  RET


; ASCII to Double precision FP number
;	FLOATING POINT INPUT ROUTINE
;
	;ALTERS ALL REGISTERS
	;THE NUMBER IS LEFT IN FAC
	;AT ENTRY, (HL) POINTS TO THE FIRST CHARACTER IN A TEXT BUFFER.
	;THE FIRST CHARACTER IS ALSO IN A.  WE PACK THE DIGITS INTO THE FAC
	;AS AN INTEGER AND KEEP TRACK OF WHERE THE DECIMAL POINT IS.
	;C IS $FF IF WE HAVE NOT SEEN A DECIMAL POINT, 0 IF WE HAVE.
	;B IS THE NUMBER OF DIGITS AFTER THE DECIMAL POINT.
	;AT THE END, B AND THE EXPONENT (IN E) ARE USED TO DETERMINE HOW MANY
	;TIMES WE MULTIPLY OR DIVIDE BY TEN TO GET THE CORRECT NUMBER.
	;
; Data block at 12953
  ; --- START PROC L3299 ---
; Also known as "FIN", convert text to number
FIN_DBL:
  EX DE,HL               ;SAVE THE TEXT POINTER IN (DE)
  LD BC,$00FF            ;CLEAR FLAGS:  B=DECIMAL PLACE COUNT,  C="." FLAG
  LD H,B                 ;ZERO (HL)
  LD L,B                 
  CALL MAKINT            ;ZERO FAC, SET VALTYP TO "INTEGER"
  EX DE,HL               ;GET THE TEXT POINTER BACK IN (HL) AND ZEROS IN (DE)
  LD A,(HL)              ;RESTORE CHAR FROM MEMORY

; ASCII to FP number (also '&' prefixes)
H_ASCTFP:
  CP '&'
  JP Z,OCTCNS

; ASCII to FP number
_ASCTFP:                                                   ;IF WE ARE CALLED BY VAL OR INPUT OR READ, THE SIGNS MAY NOT BE CRUNCHED
  CP '-'                 ; '-': Negative?                  ;SEE IF NUMBER IS NEGATIVE
  PUSH AF                ; Save it and flags               ;SAVE SIGN
  JR Z,_ASCTFP_0         ; Yes - Convert number            ;IGNORE MINUS SIGN
  CP '+'                 ; Positive?                       ;IGNORE A LEADING SIGN
  JR Z,_ASCTFP_0         ; Yes - Convert number
  DEC HL                 ; DEC 'cos GETCHR INCs            ;SET CHARACTER POINTER BACK ONE

; This entry point is used by the routine at DPOINT.
_ASCTFP_0:                                                 ;HERE TO CHECK FOR A DIGIT, A DECIMAL POINT, "E" OR "D"
  RST CHRGTB             ; Set result to zero              ;GET THE NEXT CHARACTER OF THE NUMBER
  JP C,_ASCTFP_DIGITS    ; Digit - Add to number           ;WE HAVE A DIGIT
  CP '.'                                                   ;CHECK FOR A DECIMAL POINT
  JP Z,DPOINT            ; "." - Flag point                ;WE HAVE ONE, I GUESS
  CP 'e'                                                   ;LOWER CASE "E"
  JR Z,EXPONENTIAL       
  CP 'E'                 ;CHECK FOR A SINGLE PRECISION EXPONENT
EXPONENTIAL:             
  JR NZ,NOTE             ;NO
  PUSH HL                ;SAVE TEXT PTR
  RST CHRGTB             ;GET NEXT CHAR
  CP 'l'                 ;SEE IF LOWER CASE "L"
  JR Z,_ASCTFP_2         ;IF SO POSSIBLE ELSE
  CP 'L'                 ;IS THIS REALLY AN "ELSE"?
  JR Z,_ASCTFP_2         ;WAS ELSE
  CP 'q'                 ;SEE IF LOWER CASE "Q"
  JR Z,_ASCTFP_2         ;IF SO POSSIBLE "EQV"
  CP 'Q'                 ;POSSIBLE "EQV"
_ASCTFP_2:               
  POP HL                 ;RESTORE [H,L]
  JR Z,_ASCTFP_3         ;IT WAS JUMP!
  RST GETYPR             ;IF DOUBLE DON'T DOWNGRADE TO SINGLE
  JR NC,FINEX1
  XOR A                  ;MAKE A=0 SO NUMBER IS A SINGLE
  JR FINEX
_ASCTFP_3:
  LD A,(HL)              ;RESTORE ORIGINAL CHAR
NOTE:
  CP '%'                 ;TRAILING % (RSTS-11 COMPATIBILITY)    ; Integer variable ?
  JP Z,FININT            ;MUST BE INTEGER.
  CP '#'                 ;FORCE DOUBLE PRECISION?               ; Double precision variable ?
  JP Z,FINDBF            ;YES, FORCE IT & FINISH UP.
  CP '!'                 ;FORCE SINGLE PREC.                    ; Single precision variable ?
  JP Z,FINSNF
  CP 'd'                 ;LOWER CASE "D"
  JR Z,FINEX1
  CP 'D'                 ;CHECK FOR A DOUBLE PRECISION EXPONENT
  JR NZ,FINE             ;WE DON'T HAVE ONE, THE NUMBER IS FINISHED
FINEX1:
  OR A                   ;DOUBLE PRECISION NUMBER -- TURN OFF ZERO FLAG
FINEX:                   
  CALL FINFRC            ;FORCE THE FAC TO BE SNG OR DBL
  RST CHRGTB             ;GET THE FIRST CHARACTER OF THE EXPONENT
  PUSH DE                
  LD D,$00
  CALL SGNEXP            ;EAT SIGN OF EXPONENT  ( test '+', '-'..)
  LD C,D
  POP DE

	;HERE TO GET THE NEXT DIGIT OF THE EXPONENT
FINEC:
  RST CHRGTB
  JR NC,FINE_NODG
  ;PACK THE NEXT DIGIT INTO THE EXPONENT
  LD A,E                 ;EXPONENT DIGIT -- MULTIPLY EXPONENT BY 10
  CP 12                  ;CHECK THAT THE EXPONENT DOES NOT OVERFLOW
                         ;IF IT DID, E COULD GET GARBAGE IN IT.
  JR NC,FINEDO           ;WE ALREADY HAVE TWO DIGITS
  RLCA                   ;FIRST BY 4
  RLCA
  ADD A,E                ;ADD 1 TO MAKE 5
  RLCA                   ;NOW DOUBLE TO GET 10
  ADD A,(HL)             ;ADD IT IN
  SUB '0'                ;SUBTRACT OFF ASCII CODE, THE RESULT IS
                         ; POSITIVE ON LENGTH=2 BECAUSE OF THE ABOVE CHECK
  LD E,A                 ;STORE EXPONENT
  JR FINEC               ;CONTINUE

FINEDO:
  LD E,$80               ;AN EXPONENT LIKE THIS WILL SAFELY CAUSE  OVERFLOW OR UNDERFLOW
  JR FINEC               ;CONTINUE

FINE_NODG:
  INC C
  JR NZ,FINE
  XOR A                  ;THE EXPONENT IS NEGATIVE
  SUB E                  ;NEGATE IT
  LD E,A                 ;SAVE IT AGAIN

	;HERE TO FINISH UP THE NUMBER
; This entry point is used by the routines at _ASCTFP, DPOINT, FININT and FINDBF.
FINE:
  RST GETYPR
  JP M,FINE_0
  LD A,(FACCU)
  OR A                   ;CHECK IF THE NUMBER IS ZERO
  JR Z,FINE_0
  LD A,D
  SUB B
  ADD A,E
  ADD A,$40
  LD (FACCU),A
  OR A
  CALL M,FINE_OV

FINE_0:
  POP AF                ;GET THE SIGN
  PUSH HL               ;GET THE TEXT POINTER
  CALL Z,INVSGN         ;NEGATE IF NECESSARY
  RST GETYPR            ;WE WANT -32768 TO BE AN INT, BUT UNTIL NOW IT WOULD BE A SNG
;FINE2C:
  JR NC,FINE_DBL
  POP HL                ;GET THE TEXT POINTER IN (HL)
  RET PE                ;IT IS NOT SNG, SO IT IS NOT -32768
  PUSH HL               ;WE HAVE A SNG, SAVE TEXT POINTER
  LD HL,POPHLRT         ;GET ADDRESS THAT POP'S H OFF STACK BECAUSE
  PUSH HL               ; CONIS2 DOES FUNNY THINGS WITH THE STACK
  CALL CONIS2           ;CHECK IF WE HAVE -32768
  RET                   ;WE DON'T, POPHRT IS STILL ON THE STACK SO WE CAN JUST RETURN

FINE_DBL:
  CALL DECROU
  POP HL
  RET

; Routine at 13132
;
; Used by the routine at L3301.
FINE_OV:
  JP OV_ERR			; Err $06 -  "Overflow"


	;HERE TO CHECK IF WE HAVE SEEN 2 DECIMAL POINTS AND SET THE DECIMAL POINT FLAG
; a.k.a. FINDP
; Routine at 13135
; Used by the routine at _ASCTFP.
DPOINT:
  RST GETYPR            ;SET CARRY IF WE DON'T HAVE A DOUBLE
  INC C                 ;SET THE FLAG
  JR NZ,FINE            ;WE HAD 2 DECIMAL POINTS, NOW WE ARE DONE
  JR NC,DPOINT_0        
  CALL FINFRC           ;THIS IS THE FIRST ONE, CONVERT FAC TO SNG IF WE DON'T ALREADY HAVE A DOUBLE
  LD A,(FACCU)          ;CONTINUE LOOKING FOR DIGITS
  OR A
  JR NZ,DPOINT_0
  LD D,A
DPOINT_0:
  JP _ASCTFP_0

; Routine at 13154
;
; Used by the routine at _ASCTFP.
FININT:
  RST CHRGTB            ; Gets next character (or token) from BASIC text.
  POP AF                ;GET SIGN OFF THE STACK
  PUSH HL               ;SAVE TEXT POINTER
  LD HL,POPHLRT         ;ADDRESS POP (HL) AND RETURN
  PUSH HL
  LD HL,__CINT          ;WILL WANT TO FORCE ONCE D.P. DONE
  PUSH HL
  PUSH AF               ;PUT SIGN BACK ON THE STACK
  JR FINE               ;ALL DONE


; Routine at 13168
; Used by the routine at _ASCTFP.
FINDBF:
  OR A                  ;SET NON-ZERO TO FORCE DOUBLE PREC
; This entry point is used by the routine at _ASCTFP.
FINSNF:
  CALL FINFRC           ;FORCE THE TYPE
  RST CHRGTB            ;READ AFTER TERMINATOR
  JR FINE               ;ALL DONE

; Routine at 13175
;
; Used by the routines at _ASCTFP, DPOINT and FINDBF.
FINFRC:
  PUSH HL               ;SAVE TEXT POINTER
  PUSH DE               ;SAVE EXPONENT INFORMATION
  PUSH BC               ;SAVE DECIMAL POINT INFORMATION
  PUSH AF               ;SAVE WHAT WE WANT THE FAC TO BE
  CALL Z,__CSNG         ;CONVERT TO SNG IF WE HAVE TO
  POP AF                ;GET TYPE FLAG BACK
  CALL NZ,__CDBL        ;CONVERT TO DBL IF WE HAVE TO
  POP BC                ;GET DECIMAL POINT INFORMATION BACK
  POP DE                ;GET EXPONENT INFORMATION BACK
  POP HL                ;GET TEXT POINTER BACK
  RET                   ;ALL DONE

; Data block at 13190
_ASCTFP_DIGITS:
  SUB '0'           ; convert from ASCII
  JP NZ,L3393
  OR C
  JP Z,L3393
  AND D
  JP Z,_ASCTFP_0
L3393:
  INC D
  LD A,D
  CP $07
  JR NZ,ADDIG
  OR A
  CALL FINFRC


; a.k.a. FINDIG
	;HERE TO PACK THE NEXT DIGIT OF THE NUMBER INTO THE FAC
	;WE MULTIPLY THE FAC BY TEN AND ADD IN THE NEXT DIGIT
ADDIG:
  PUSH DE            ;SAVE EXPONENT INFORMATION                  ; Save sign of exponent/digit
  LD A,B             ;INCREMENT DECIMAL PLACE COUNT IF WE ARE    ; Get digits after point
  ADD A,C            ; PAST THE DECIMAL POINT                    ; Add one if after point
  INC A                                                          
  LD B,A                                                         ; Re-save counter
  PUSH BC            ;SAVE DECIMAL POINT INFORMATION             ; Save point flags
  PUSH HL            ;SAVE TEXT POINTER                          ; Save code string address
  LD A,(HL)          ;GET THE DIGIT
  SUB '0'            ;CONVERT IT TO ASCII                        ; convert from ASCII
  PUSH AF            ;SAVE THE DIGIT
  RST GETYPR         ;SEE WHAT KIND OF A NUMBER WE HAVE          ; Get the number type (FAC)
  JP P,FINDGV        ;WE DO NOT HAVE AN INTEGER 

	;HERE TO PACK THE NEXT DIGIT OF AN INTEGER
  LD HL,(FACLOW)     ;WE HAVE AN INTEGER, GET IT IN (HL)
  LD DE,3277         ;SEE IF WE WILL OVERFLOW                    ; Const: $0CCD
  RST DCOMPR         ;COMPAR RETURNS WITH CARRY ON IF            ; Compare HL with DE.
  JR NC,FINDG2       ; (HL) .LT. (DE), SO THE NUMBER IS TOO BIG
  LD D,H             ;COPY (HL) INTO (DE)
  LD E,L             
  ADD HL,HL          ;MULTIPLY (HL) BY 2                         ; * 10
  ADD HL,HL          ;MULTIPLY (HL) BY 2, (HL) NOW IS 4*(DE)
  ADD HL,DE          ;ADD IN OLD (HL) TO GET 5*(DE)
  ADD HL,HL          ;MULTIPLY BY 2 TO GET TEN TIMES THE OLD (HL)
  POP AF             ;GET THE DIGIT
  LD C,A             ;SAVE IT SO WE CAN USE DAD, B IS ALREADY ZERO
  ADD HL,BC          ;ADD IN THE NEXT DIGIT
  LD A,H             ;CHECK FOR OVERFLOW
  OR A               ;OVERFLOW OCCURED IF THE MSB IS ON
  JP M,FINDG1        ;WE HAVE OVERFLOW!!
  LD (FACLOW),HL     ;EVERYTHING IS FINE, STORE THE NEW NUMBER
FINDGE:
  POP HL             ;ALL DONE, GET TEXT POINTER BACK
  POP BC             ;GET DECIMAL POINT INFORMATION BACK
  POP DE             ;GET EXPONENT INFORMATION BACK
  JP _ASCTFP_0       ;GET THE NEXT CHARACTER


	;HERE TO HANDLE 32768, 32769
FINDG1:
  LD A,C             ;GET THE DIGIT
  PUSH AF            ;PUT IT BACK ON THE STACK


	;HERE TO CONVERT THE INTEGER DIGITS TO SINGLE PRECISION DIGITS
FINDG2:
  CALL CONSI         ;CONVERT THE INTEGER TO SINGLE PRECISION

	;HERE TO DECIDE IF WE HAVE A SINGLE OR DOUBLE PRECISION NUMBER
FINDGV:
  POP AF
  POP HL
  POP BC
  POP DE
  JR NZ,FINDG3
  LD A,(FACCU)
  OR A
  LD A,$00
  JR NZ,FINDG3
  LD D,A
  JP _ASCTFP_0

	;HERE TO CONVERT A 7 DIGIT SINGLE PRECISION NUMBER TO DOUBLE PRECISION
FINDG3:
  PUSH DE
  PUSH BC
  PUSH HL
  PUSH AF
  LD HL,FACCU
  LD (HL),$01
  LD A,D
  CP $10
  JR C,FINDG_BCD
  POP AF
  JR FINDGE          ;GET FLAGS OFF STACK AND WE ARE DONE


FINDG_BCD:
  INC A
  OR A
  RRA
  LD B,$00
  LD C,A
  ADD HL,BC
  POP AF
  LD C,A
  LD A,D
  RRA
  LD A,C
  JR NC,FINDGE1      ; HI or LOW BCD digit ?
  ADD A,A
  ADD A,A
  ADD A,A
  ADD A,A
FINDGE1:
  OR (HL)
  LD (HL),A
  JR FINDGE





; 'in' <line number> message
;
; Routine at 13322
; Used by the routine at LINE2PTR.
; $340A:
IN_PRT:
  PUSH HL             ;SAVE LINE NUMBER
  LD HL,IN_MSG		  ;PRINT MESSAGE    (.." in "..)
  CALL PRS            
  POP HL              ;FALL INTO LINPRT

; Print HL in ASCII form at the current cursor position
; a.k.a. NUMPRT
		;PRINT THE 2 BYTE NUMBER IN H,L
		;ALTERS ALL REGISTERS
; This entry point is used by the routines at __LLIST, LINE2PTR and L7D29.
LINPRT:
  LD BC,PRNUMS
  PUSH BC
  CALL MAKINT         ;PUT THE LINE NUMBER IN THE FAC AS AN INTEGER
  XOR A               ;SET FORMAT TO FREE FORMAT
  LD (TEMP3),A
  LD HL,FBUFFR+1
  LD (HL),' '         ;SET UP THE SIGN
  OR (HL)             ;TURN OFF THE ZERO FLAG
  JR SPCFST           ;CONVERT THE NUMBER INTO DIGITS

  

;
;	OUTPUT THE VALUE IN THE FAC ACCORDING TO THE FORMAT SPECIFICATIONS
;	IN A,B,C
;	ALL REGISTERS ARE ALTERED
;	THE ORIGINAL CONTENTS OF THE FAC IS LOST
;
;	THE FORMAT IS SPECIFIED IN A, B AND C AS FOLLOWS:
;	THE BITS OF A MEAN THE FOLLOWING:
;BIT 7	0 MEANS FREE FORMAT OUTPUT, I.E. THE OTHER BITS OF A MUST BE ZERO,
;	TRAILING ZEROS ARE SUPPRESSED, A NUMBER IS PRINTED IN FIXED OR FLOATING
;	POINT NOTATION ACCORDING TO ITS MAGNITUDE, THE NUMBER IS LEFT
;	JUSTIFIED IN ITS FIELD, B AND C ARE IGNORED.
;	1 MEANS FIXED FORMAT OUTPUT, I.E. THE OTHER BITS OF A ARE CHECKED FOR
;	FORMATTING INFORMATION, THE NUMBER IS RIGHT JUSTIFIED IN ITS FIELD,
;	TRAILING ZEROS ARE NOT SUPPRESSED.  THIS IS USED FOR PRINT USING.
;BIT 6	1 MEANS GROUP THE DIGITS IN THE INTEGER PART OF THE NUMBER INTO GROUPS
;	OF THREE AND SEPARATE THE GROUPS BY COMMAS
;	0 MEANS DON'T PRINT THE NUMBER WITH COMMAS
;BIT 5	1 MEANS FILL THE LEADING SPACES IN THE FIELD WITH ASTERISKS ("*")
;BIT 4	1 MEANS OUTPUT THE NUMBER WITH A FLOATING DOLLAR SIGN ("$")
;BIT 3	1 MEANS PRINT THE SIGN OF A POSITIVE NUMBER AS A PLUS SIGN ("+")
;	INSTEAD OF A SPACE
;BIT 2	1 MEANS PRINT THE SIGN OF THE NUMBER AFTER THE NUMBER
;BIT 1	UNUSED
;BIT 0	1 MEANS PRINT THE NUMBER IN FLOATING POINT NOTATION I.E. "E NOTATION"
;	IF THIS BIT IS ON, THE COMMA SPECIFICATION (BIT 6) IS IGNORED.
;	0 MEANS PRINT THE NUMBER IN FIXED POINT NOTATION.  NUMBERS .GE. 1E16
;	CANNOT BE PRINTED IN FIXED POINT NOTATION.
;
;	B AND C TELL HOW BIG THE FIELD IS:
;B   =	THE NUMBER OF PLACES IN THE FIELD TO THE LEFT OF THE DECIMAL POINT
;	(B DOES NOT INCLUDE THE DECIMAL POINT)
;C   =	THE NUMBER OF PLACES IN THE FIELD TO THE RIGHT OF THE DECIMAL POINT
;	(C INCLUDES THE DECIMAL POINT)
;	B AND C DO NOT INCLUDE THE 4 POSITIONS FOR THE EXPONENT IF BIT 0 IS ON
;	FOUT ASSUMES B+C .LE. 24 (DECIMAL)
;	IF THE NUMBER IS TOO BIG TO FIT IN THE FIELD, A PERCENT SIGN ("%") IS
;	PRINTED AND THE FIELD IS EXTENDED TO HOLD THE NUMBER.


; Convert number/expression to string (format not specified)
;
	;FLOATING OUTPUT OF FAC
	;ALTERS ALL REGISTERS
	;THE ORIGINAL CONTENTS OF THE FAC IS LOST
;
; a.k.a. NUMASC
; --- START PROC L3425 ---
; Convert number/expression to string (format not specified)
FOUT:                 ;ENTRY TO PRINT THE FAC IN FREE FORMAT
  XOR A               ;SET FORMAT FLAGS TO FREE FORMATTED OUTPUT

; --- START PROC L3426 ---
; Convert number/expression to string ("PRINT USING" format specified in 'A' register)
PUFOUT:               ;ENTRY TO PRINT THE FAC USING THE FORMAT SPECIFICATIONS IN A, B AND C
  CALL FOUINI         ;SAVE THE FORMAT SPECIFICATION IN A AND PUT A SPACE FOR POSITIVE NUMBERS IN THE BUFFER
  AND $08             ;CHECK IF POSITIVE NUMBERS GET A PLUS SIGN      ; bit 3 - Sign (+ or -) preceeds number
  JR Z,PUFOUT_0       ;THEY DON'T
  LD (HL),'+'         ;THEY DO, PUT IN A PLUS SIGN
PUFOUT_0:             
  EX DE,HL            ;SAVE BUFFER POINTER
  CALL VSIGN          ;GET THE SIGN OF THE FAC                        ; Test sign of FPREG
  EX DE,HL            ;PUT THE BUFFER POINTER BACK IN (HL)
  JP P,SPCFST         ;IF WE HAVE A NEGATIVE NUMBER, NEGATE IT        ; Positive - Space to start
  LD (HL),'-'         ; AND PUT A MINUS SIGN IN THE BUFFER            ; "-" sign at start
  PUSH BC             ;SAVE THE FIELD LENGTH SPECIFICATION
  PUSH HL             ;SAVE THE BUFFER POINTER
  CALL INVSGN         ;NEGATE THE NUMBER
  POP HL              ;GET THE BUFFER POINTER BACK
  POP BC              ;GET THE FIELD LENGTH SPECIFICATIONS BACK
  OR H                ;TURN OFF THE ZERO FLAG, THIS DEPENDS ON THE FACT THAT FBUFFR IS NEVER ON PAGE 0.

; --- START PROC SPCFST ---
SPCFST:
  INC HL              ;POINT TO WHERE THE NEXT CHARACTER GOES  ; First byte of number
  LD (HL),'0'         ;PUT A ZERO IN THE BUFFER IN CASE THE NUMBER IS ZERO (IN FREE FORMAT)
                      ;OR TO RESERVE SPACE FOR A FLOATING DOLLAR SIGN (FIXED FORMAT)
  LD A,(TEMP3)        ;GET THE FORMAT SPECIFICATION
  LD D,A              ;SAVE IT FOR LATER
  RLA                 ;PUT THE FREE FORMAT OR NOT BIT IN THE CARRY
  LD A,(VALTYP)       ;GET THE VALTYP, VNEG COULD HAVE CHANGED THIS SINCE -32768 IS INT AND 32768 IS SNG.
  JP C,FOUTFX         ;THE MAN WANTS FIXED FORMATED OUTPUT
  
	;HERE TO PRINT NUMBERS IN FREE FORMAT
  JP Z,FOUTZR         ;IF THE NUMBER IS ZERO, FINISH IT UP
  CP $04              ;DECIDE WHAT KIND OF A VALUE WE HAVE
  JP NC,FOUFRV        ;WE HAVE A SNG OR DBL

	;HERE TO PRINT AN INTEGER IN FREE FORMAT
  LD BC,$0000         ;SET THE DECIMAL POINT COUNT AND COMMA COUNT TO ZERO
  CALL FOUTCI         ;CONVERT THE INTEGER TO DECIMAL
                      ;FALL INTO FOUTZS AND ZERO SUPPRESS THE THING

	;ZERO SUPPRESS THE DIGITS IN FBUFFR
	;ASTERISK FILL AND ZERO SUPPRESS IF NECESSARY
	;SET UP B AND CONDITION CODES IF WE HAVE A TRAILING SIGN
FOUTZS:
  LD HL,FBUFFR+1      ;GET POINTER TO THE SIGN
  LD B,(HL)           ;SAVE THE SIGN IN B
  LD C,' '            ;DEFAULT FILL CHARACTER TO A SPACE
  LD A,(TEMP3)        ;GET FORMAT SPECS TO SEE IF WE HAVE TO
  LD E,A              ; ASTERISK FILL.  SAVE IT                       ; bit 5 - Asterisks fill  
  AND $20             
  JR Z,FOUTZS_0       ;WE DON'T
  LD A,B              ;WE DO, SEE IF THE SIGN WAS A SPACE
  CP C                ;ZERO FLAG IS SET IF IT WAS
  LD C,'*'            ;SET FILL CHARACTER TO AN ASTERISK
  JR NZ,FOUTZS_0      ;SET THE SIGN TO AN ASTERISK IF IT WAS A SPACE
  LD A,E              ;GET FORMAT SPECS AGAIN
  AND $04             ;SEE IF SIGN IS TRAILING                        ; bit 2 - Sign (+ or -) follows ASCII number  
  JR NZ,FOUTZS_0      ;IF SO DON'T ASTERISK FILL
  LD B,C              ;B HAS THE SIGN, C THE FILL CHARACTER

FOUTZS_0:
  LD (HL),C           ;FILL IN THE ZERO OR THE SIGN
  RST CHRGTB          ;GET THE NEXT CHARACTER IN THE BUFFER SINCE THERE ARE NO SPACES, "CHRGET" IS EQUIVALENT TO "INX	H"/"MOV	A,M"
  JR Z,FOUTZS_1       ;IF WE SEE A REAL ZERO, IT IS THE END OF THE NUMBER, AND WE MUST BACK UP AND PUT IN A ZERO.
                      ;CHRGET SETS THE ZERO FLAG ON REAL ZEROS OR COLONS, BUT WE WON'T SEE ANY COLONS IN THIS BUFFER.

  CP 'E'              ;BACK UP AND PUT IN A ZERO IF WE SEE
  JR Z,FOUTZS_1       ;AN "E" OR A "D" SO WE CAN PRINT 0 IN
  CP 'D'              ;FLOATING POINT NOTATION WITH THE C FORMAT ZERO
  JR Z,FOUTZS_1
  CP '0'              ;DO WE HAVE A ZERO?
  JR Z,FOUTZS_0       ;YES, SUPPRESS IT
  CP ','              ;DO WE HAVE A COMMA?
  JR Z,FOUTZS_0       ;YES, SUPPRESS IT
  CP '.'              ;ARE WE AT THE DECIMAL POINT?
  JR NZ,FOUTZS_2      ;NO, I GUESS NOT
FOUTZS_1:
  DEC HL              ;YES, BACK UP AND PUT A ZERO BEFORE IT
  LD (HL),'0'
FOUTZS_2:
  LD A,E              ;GET THE FORMAT SPECS TO CHECK FOR A FLOATING
  AND $10             ; DOLLAR SIGN                                   ; bit 4 - Print leading '$'  
  JR Z,FOUTZS_3       ;WE DON'T HAVE ONE
  DEC HL              ;WE HAVE ONE, BACK UP AND PUT IN THE DOLLAR
  LD (HL),'$'         ; SIGN
FOUTZS_3:
  LD A,E              ;DO WE HAVE A TRAILING SIGN?
  AND $04		                                                      ; bit 2 - Sign (+ or -) follows ASCII number  
  RET NZ              ;YES, RETURN; NOTE THE NON-ZERO FLAG IS SET
  DEC HL              ;NO, BACK UP ONE AND PUT THE SIGN BACK IN
  LD (HL),B           ;PUT IN THE SIGN
  RET                 ;ALL DONE


	;HERE TO PRINT A SNG OR DBL IN FREE FORMAT
FOUFRV:
  PUSH HL             ;SAVE THE BUFFER POINTER
  CALL FTCH_SNG
  LD D,B              ;THIS CALCULATES HOW MANY DIGITS
  INC D               ;WE WILL PRINT
  LD BC,$0300         ;B = DECIMAL POINT COUNT
                      ;C = COMMA COUNT
                      ;SET COMMA COUNT TO ZERO AND DECIMAL POINT COUNT FOR E NOTATION
  LD A,(FACCU)        ;NORMAL ROUTE
  SUB $3f             ;SEE IF NUMBER SHOULD BE PRINTED IN E NOTATION
  JR C,FOFRS1         ;IT SHOULD, IT IS .LT. .01
  INC D               ;CHECK IF IT IS TOO BIG
  CP D
  JR NC,FOFRS1        ;IT IS TOO BIG, IT IS .GT. 10^D-1
  INC A               ;IT IS OK FOR FIXED POINT NOTATION
  LD B,A              ;SET DECIMAL POINT COUNT
  LD A,$02            ;SET FIXED POINT FLAG, THE EXPONENT IS ZERO
                      ; IF WE ARE USING FIXED POINT NOTATION
FOFRS1:
  SUB $02             ;E NOTATION: ADD D-2 TO ORIGINAL EXPONENT
                      ;RESTORE EXP IF NOT D.P.
  POP HL              ;GET THE BUFFER POINTER BACK
  PUSH AF             ;SAVE THE EXPONENT FOR LATER
  CALL FOUTAN         ;.01 .LE. NUMBER .LT. .1?
  LD (HL),'0'         ;YES, PUT ".0" IN BUFFER
  CALL Z,INCHL
  CALL FOUTCV         ;CONVERT THE NUMBER TO DECIMAL DIGITS

	;HERE TO SUPPRESS THE TRAILING ZEROS
SUPTLZ:
  DEC HL              ; Move back through buffer         ;MOVE BACK TO THE LAST CHARACTER
  LD A,(HL)           ; Get character                    ;GET IT AND SEE IF IT WAS ZERO
  CP '0'              ; "0" character?
  JR Z,SUPTLZ         ; Yes - Look back for more         ;IT WAS, CONTINUE SUPPRESSING
  CP '.'              ; A decimal point?                 ;HAVE WE SUPPRESSED ALL THE FRACTIONAL DIGITS?
  CALL NZ,INCHL       ; Move back over digit             ;YES, IGNORE THE DECIMAL POINT ALSO
  POP AF              ; Get "E" flag                     ;GET THE EXPONENT BACK
  JR Z,NOENED         ; No "E" needed - End buffer       ;WE ARE DONE IF WE ARE IN FIXED POINT NOTATION
                                                         ;FALL IN AND PUT THE EXPONENT IN THE BUFFER

; a.k.a. FOFLDN
;
	;HERE TO PUT THE EXPONENT AND "E" OR "D" IN THE BUFFER
	;THE EXPONENT IS IN A, THE CONDITION CODES ARE ASSUMED TO BE SET
	;CORRECTLY.
;
DOEBIT:
  LD (HL),'E'         ; Put "E" in buffer                ;SAVE IT IN THE BUFFER
  INC HL              ; And move on                      ;INCREMENT THE BUFFER POINTER

	;PUT IN THE SIGN OF THE EXPONENT
  LD (HL),'+'         ; Put '+' in buffer                ;A PLUS IF POSITIVE
  JP P,OUTEXP         ; Positive - Output exponent
  LD (HL),'-'         ; Put "-" in buffer                ;A MINUS IF NEGATIVE
  CPL                 ; Negate exponent                  ;NEGATE EXPONENT
  INC A

	;CALCULATE THE TWO DIGIT EXPONENT
OUTEXP:
  LD B,'0'-1          ; ASCII "0" - 1                    ;INITIALIZE TEN'S DIGIT COUNT
EXPTEN:               
  INC B               ; Count subtractions               ;INCREMENT DIGIT
  SUB 10              ; Tens digit                       ;SUBTRACT TEN
  JR NC,EXPTEN        ; More to do                       ;DO IT AGAIN IF RESULT WAS POSITIVE
  ADD A,'0'+10        ; Restore and make ASCII           ;ADD BACK IN TEN AND CONVERT TO ASCII
                      
	;PUT THE EXPONENT IN THE BUFFER
  INC HL              ; Move on                          
  LD (HL),B           ; Save MSB of exponent             ;PUT TEN'S DIGIT OF EXPONENT IN BUFFER
  INC HL                                                 ;WHEN WE JUMP TO HERE, A IS ZERO
  LD (HL),A           ; Save LSB of exponent             ;PUT ONE'S DIGIT IN BUFFER

FOUTZR:
  INC HL              ;INCREMENT POINTER, HERE TO FINISH UP

	; PRINTING A FREE FORMAT ZERO
NOENED:
  LD (HL),$00         ;PUT A ZERO AT THE END OF THE NUMBER
  EX DE,HL            ;SAVE THE POINTER TO THE END OF THE NUMBER IN (DE) FOR FFXFLV
  LD HL,FBUFFR+1      ;GET A POINTER TO THE BEGINNING    ; Buffer for fout + 1
  RET                 ;ALL DONE


	;HERE TO PRINT A NUMBER IN FIXED FORMAT
FOUTFX:
  INC HL              ;MOVE PAST THE ZERO FOR THE DOLLAR SIGN
  PUSH BC             ;SAVE THE FIELD LENGTH SPECIFICATIONS
  CP $04              ;CHECK WHAT KIND OF VALUE WE HAVE
  LD A,D              ;GET THE FORMAT SPECS
  JP NC,FOUFXV        ;WE HAVE A SNG OR A DBL
  
	;HERE TO PRINT AN INTEGER IN FIXED FORMAT
  RRA                 ;CHECK IF WE HAVE TO PRINT IT IN FLOATING
  JP C,FFXIFL         ; POINT NOTATION

	;HERE TO PRINT AN INTEGER IN FIXED FORMAT-FIXED POINT NOTATION
  LD BC,$0603         ;SET DECIMAL POINT COUNT TO 6 AND COMMA COUNT TO 3
  CALL FOUICC         ;CHECK IF WE DON'T HAVE TO USE THE COMMAS
  POP DE              ;GET THE FIELD LENGTHS
  LD A,D              ;SEE IF WE HAVE TO PRINT EXTRA SPACES BECAUSE
  SUB $05             ; THE FIELD IS TOO BIG
  CALL P,FOTZER       ;WE DO, PUT IN ZEROS, THEY WILL LATER BE CONVERTED TO SPACES OR ASTERISKS BY FOUTZS
  CALL FOUTCI         ;CONVERT THE NUMBER TO DECIMAL DIGITS

FOUTTD:
  LD A,E              ;DO WE NEED A DECIMAL POINT?
  OR A                
  CALL Z,DCXHRT       ;WE DON'T, BACKSPACE OVER IT.
  DEC A               ;GET HOW MANY TRAILING ZEROS TO PRINT
  CALL P,FOTZER       ;PRINT THEM
                      ;IF WE DO HAVE DECIMAL PLACES, FILL THEM UP WITH ZEROS
                      ;FALL IN AND FINISH UP THE NUMBER


	;HERE TO FINISH UP A FIXED FORMAT NUMBER
; This entry point is used by the routines at L35EC.
FOUTTS:
  PUSH HL             ;SAVE BUFFER POINTER
  CALL FOUTZS         ;ZERO SUPPRESS THE NUMBER
  POP HL              ;GET THE BUFFER POINTER BACK
  JR Z,FFXIX1         ;CHECK IF WE HAVE A TRAILING SIGN
  LD (HL),B           ;WE DO, PUT THE SIGN IN THE BUFFER
  INC HL              ;INCREMENT THE BUFFER POINTER
FFXIX1:
  LD (HL),$00         ;PUT A ZERO AT THE END OF THE NUMBER


	;HERE TO CHECK IF A FIXED FORMAT-FIXED POINT NUMBER OVERFLOWED ITS
	;FIELD LENGTH
	;D = THE B IN THE FORMAT SPECIFICATION
	;THIS ASSUMES THE LOCATION OF THE DECIMAL POINT IS IN TEMP2
  LD HL,FBUFFR        ;GET A POINTER TO THE BEGINNING
FOUBE1:
  INC HL              ;INCREMENT POINTER TO THE NEXT CHARACTER
; This entry point is used by the routine at FOUBE3.
FOUBE5:
  LD A,(NXTOPR)       ;GET THE LOCATION OF THE DECIMAL POINT

	;SINCE FBUFFR IS ONLY 35 (DECIMAL) LONG, WE
	; ONLY HAVE TO LOOK AT THE LOW ORDER TO SEE
	; IF THE FIELD IS BIG ENOUGH
  SUB L               ;FIGURE OUT HOW MUCH SPACE WE ARE TAKING
  SUB D               ;IS THIS THE RIGHT AMOUNT OF SPACE TO TAKE?
  RET Z               ;YES, WE ARE DONE, RETURN FROM FOUT
  LD A,(HL)           ;NO, WE MUST HAVE TOO MUCH SINCE WE STARTED

	; CHECKING FROM THE BEGINNING OF THE BUFFER
	; AND THE FIELD MUST BE SMALL ENOUGH TO FIT IN THE BUFFER.
	; GET THE NEXT CHARACTER IN THE BUFFER.
  CP ' '              ;IF IT IS A SPACE OR AN ASTERISK, WE CAN
  JR Z,FOUBE1         ; IGNORE IT AND MAKE THE FIELD SHORTER WITH
  CP '*'              ; NO ILL EFFECTS
  JR Z,FOUBE1
  DEC HL              ;MOVE THE POINTER BACK ONE TO READ THE CHARACTER WITH CHRGET
  PUSH HL             ;SAVE THE POINTER


	;HERE WE SEE IF WE CAN IGNORE THE LEADING ZERO BEFORE A DECIMAL POINT.
	;THIS OCCURS IF WE SEE THE FOLLOWING: (IN ORDER)
	;	+,-	A SIGN (EITHER "-" OR "+")	[OPTIONAL]
	;	$	A DOLLAR SIGN			[OPTIONAL]
	;	0	A ZERO				[MANDATORY]
	;	.	A DECIMAL POINT			[MANDATORY]
	;	0-9	ANOTHER DIGIT			[MANDATORY]
	;IF YOU SEE A LEADING ZERO, IT MUST BE THE ONE BEFORE A DECIMAL POINT
	;OR ELSE FOUTZS WOULD HAVE SUPPRESSED IT, SO WE CAN JUST "INX	H"
	;OVER THE CHARACTER FOLLOWING THE ZERO, AND NOT CHECK FOR THE
	;DECIMAL POINT EXPLICITLY.
FOUBE2:
  PUSH AF              ;PUT THE LAST CHARACTER ON THE STACK.
                       ;THE ZERO FLAG IS SET.
                       ;THE FIRST TIME THE ZERO ZERO FLAG IS NOT SET.
  LD BC,FOUBE2         ;GET ADDRESS WE GO TO IF WE SEE A CHARACTER
  PUSH BC              ; WE ARE LOOKING FOR
  RST CHRGTB           ;GET THE NEXT CHARACTER
  CP '-'               ;SAVE IT AND GET THE NEXT CHARACTER IF IT IS
  RET Z                ; A MINUS SIGN, A PLUS SIGN OR A DOLLAR SIGN
  CP '+'
  RET Z 
  CP '$'
  RET Z 
  POP BC               ;IT ISN'T, GET THE ADDRESS OFF THE STACK
  CP '0'               ;IS IT A ZERO?
  JR NZ,FOUBE4         ;NO, WE CAN NOT GET RID OF ANOTHER CHARACTER
  INC HL               ;SKIP OVER THE DECIMAL POINT
  RST CHRGTB           ;GET THE NEXT CHARACTER
  JR NC,FOUBE4         ;IT IS NOT A DIGIT, WE CAN'T SHORTEN THE FIELD
  DEC HL               ;WE CAN!!!  POINT TO THE DECIMAL POINT
  JR FOUBE3_0

; Routine at 13655
FOUBE3:
  DEC HL               ;POINT BACK ONE CHARACTER
  LD (HL),A            ;PUT THE CHARACTER BACK


	;IF WE CAN GET RID OF THE ZERO, WE PUT THE CHARACTERS ON THE STACK
	;BACK INTO THE BUFFER ONE POSITION IN FRONT OF WHERE THEY ORIGINALLY
	;WERE.  NOTE THAT THE MAXIMUM NUMBER OF STACK LEVELS THIS USES IS
	;THREE -- ONE FOR THE LAST ENTRY FLAG, ONE FOR A POSSIBLE SIGN,
	;AND ONE FOR A POSSIBLE DOLLAR SIGN.  WE DON'T HAVE TO WORRY ABOUT
	;THE FIRST CHARACTER BEING IN THE BUFFER TWICE BECAUSE THE POINTER
	;WHEN FOUT EXITS WILL BE POINTING TO THE SECOND OCCURANCE.
FOUBE3_0:
  POP AF               ;GET THE CHARACTER OFF THE STACK
  JR Z,FOUBE3          ;PUT IT BACK IN THE BUFFER IF IT IS NOT THE LAST ONE
  POP BC               ;GET THE BUFFER POINTER OFF THE STACK
  JR FOUBE5            ;SEE IF THE FIELD IS NOW SMALL ENOUGH

	;HERE IF THE NUMBER IS TOO BIG FOR THE FIELD
; Routine at 13663
;
FOUBE4:
  POP AF               ;GET THE CHARACTERS OFF THE STACK
  JR Z,FOUBE4          ;LEAVE THE NUMBER IN THE BUFFER ALONE
  POP HL               ;GET THE POINTER TO THE BEGINNING OF THE NUMBER MINUS 1
  LD (HL),'%'          ;PUT IN A PERCENT SIGN TO INDICATE THE NUMBER WAS TOO LARGE FOR THE FIELD
  RET                  ;ALL DONE -- RETURN FROM FOUT


	;HERE TO PRINT A SNG OR DBL IN FIXED FORMAT
FOUFXV:
  PUSH HL              ;SAVE THE BUFFER POINTER
  RRA                  ;GET FIXED OR FLOATING NOTATION FLAG IN CARRY
  JP C,FFXFLV          ;PRINT THE NUMBER IN E-NOTATION
  CALL FTCH_SNG
  LD D,B               ;SET D = NUMBER OF DIGITS TO PRINT FOR A DBL
  LD A,(FACCU)
  SUB $4F              ;  (WE CAN'T PRINT A NUMBER .GE. 10^16 IN FIXED POINT NOTATION)
  JR C,FFXSDC          ;IF THE FAC WAS SMALL ENOUGH, GO PRINT IT

	;HERE TO PRINT IN FREE FORMAT WITH A PERCENT SIGN A NUMBER .GE. 10^16
;FFXSDO:
  POP HL               ;GET THE BUFFER POINTER OFF THE STACK
  POP BC               ;GET THE FIELD SPECIFICATION OFF THE STACK
  CALL FOUT            ;PRINT THE NUMBER IN FREE FORMAT
  LD HL,FBUFFR         ;POINT TO IN FRONT OF THE NUMBER
  LD (HL),'%'          ;PUT IN THE PERCENT SIGN
  RET                  ;ALL DONE--RETURN FROM FOUT

	;HERE TO PRINT A SNG IN FIXED FORMAT--FIXED POINT NOTATION
FFXSDC:
  CALL SIGN			; test FP number sign
  CALL NZ,FOUTNV
  POP HL
  POP BC
  JP M,FFXXVS

	;HERE TO PRINT A NUMBER WITH NO FRACTIONAL DIGITS
  PUSH BC              ;SAVE THE FIELD LENGTH SPECS AGAIN
  LD E,A               ;SAVE THE EXPONENT IN E
  LD A,B               ;WE HAVE TO PRINT LEADING ZEROS IF THE FIELD
  SUB D                ; HAS MORE CHARACTERS THAN THERE ARE DIGITS
  SUB E                ; IN THE NUMBER.

	; IF WE ARE USING COMMAS, A MAY BE TOO BIG.
	; THIS DOESN'T MATTER BECAUSE FOUTTS WILL FIND THE CORRECT BEGINNING.
	; THERE IS ROOM IN FBUFFR BECAUSE THE MAXIMUM VALUE B CAN BE IS
	; 24 (DECIMAL) SO D+C .LE. 16 (DECIMAL)  SINCE FAC .LT. 10^16.
	; SO WE NEED 8 MORE BYTES FOR ZEROS.
	; 4 COME SINCE WE WILL NOT NEED TO PRINT AN EXPONENT.
	; FBUFFR ALSO CONTAINS AN EXTRA 4 BYTES FOR THIS CASE.
	;(IT WOULD TAKE MORE THAN 4 BYTES TO CHECK FOR THIS.)

  CALL P,FOTZER        ;FOUTZS WILL LATER SUPPRESS THEM
  CALL FOUTCD          ;SETUP DECIMAL POINT AND COMMA COUNT
  CALL FOUTCV          ;CONVERT THE NUMBER TO DECIMAL DIGITS
  OR E                 ;PUT IN DIGITS AFTER THE NUMBER IF IT IS BIG ENOUGH, HERE A=0
  CALL NZ,FOTZEC       ;THERE CAN BE COMMAS IN THESE ZEROS
  OR E                 ;MAKE SURE WE GET A DECIMAL POINT FOR FOUTTS
  CALL NZ,FOUTED
  POP DE               ;GET THE FIELD LENGTH SPECS
  JP FOUTTD            ;GO CHECK THE SIZE, ZERO SUPPRESS, ETC. AND FINISH THE NUMBER

	;HERE TO PRINT A SNG OR DBL THAT HAS FRACTIONAL DIGITS
FFXXVS:
  LD E,A               ;SAVE THE EXPONENT
  LD A,C               ;DIVIDE BY TEN THE RIGHT NUMBER OF TIMES SO
  OR A                 ; THE RESULT WILL BE ROUNDED CORRECTLY AND
  CALL NZ,DCRART       ; HAVE THE CORRECT NUMBER OF SIGNIFICANT
  ADD A,E              ; DIGITS
  JP M,FFXXV8          ;FOR LATER CALCULATIONS, WE WANT A ZERO IF THE
  XOR A                ; RESULT WAS NOT NEGATIVE
FFXXV8:
  PUSH BC              ;SAVE THE FIELD SPECS
  PUSH AF              ;SAVE THIS NUMBER FOR LATER
  CALL M,FINDIV
  POP BC               ;GET THE NUMBER WE SAVED BACK IN B
  LD A,E               ;WE HAVE TWO CASES DEPENDING ON WHETHER THE
  SUB B                ; THE NUMBER HAS INTEGER DIGITS OR NOT
  POP BC               ;GET THE FILED SPECS BACK
  LD E,A               ;SAVE HOW MANY DECIMAL PLACES BEFORE THE
  ADD A,D              ; THE NUMBER ENDS
  LD A,B               ;GET THE "B" FIELD SPEC
  JP M,FFXXV3

	;HERE TO PRINT NUMBERS WITH INTEGER DIGITS
  SUB D                ;PRINT SOME LEADING ZEROS IF THE FIELD IS
  SUB E                ; BIGGER THAN THE NUMBER OF DIGITS WE WILL
  CALL P,FOTZER        ; PRINT
  PUSH BC              ;SAVE FIELD SPEC
  CALL FOUTCD          ;SET UP DECIMAL POINT AND COMMA COUNT
  JR FFXXV6            ;CONVERT THE DIGITS AND DO THE TRIMMING UP

	;HERE TO PRINT A NUMBER WITHOUT INTEGER DIGITS
FFXXV3:
  CALL FOTZER          ;PUT ALL ZEROS BEFORE THE DECIMAL POINT
  LD A,C               ;SAVE C
  CALL FOUTDP          ;PUT IN A DECIMAL POINT
  LD C,A               ;RESTORE C
  XOR A                ;DECIDE HOW MANY ZEROS TO PRINT BETWEEN THE
  SUB D                ; DECIMAL POINT AND THE FIRST DIGIT WE WILL
  SUB E                ; PRINT.
  CALL FOTZER          ;PRINT THE ZEROS
  PUSH BC              ;SAVE EXPONENT AND THE "C" IN THE FIELD SPEC
  LD B,A               ;ZERO THE DECIMAL PLACE COUNT
  LD C,A               ;ZERO THE COMMA COUNT
FFXXV6:
  CALL FOUTCV          ;CONVERT THE NUMBER TO DECIMAL DIGITS
  POP BC               ;GET THE FIELD SPECS BACK
  OR C                 ;CHECK IF WE HAVE TO PRINT ANY ZEROS AFTER THE LAST DIGIT
  JR NZ,FFXXV7         ;CHECK IF THERE WERE ANY DECIMAL PLACES AT ALL
                       ;E CAN NEVER BE 200, (IT IS NEGATIVE) SO IF
                       ; A=0 HERE, THERE IS NO WAY WE WILL CALL FOTZER 
  LD HL,(NXTOPR)       ;THE END OF THE NUMBER IS WHERE THE DP IS
FFXXV7:
  ADD A,E              ;PRINT SOME MORE TRAILING ZEROS
  DEC A
  CALL P,FOTZER
  LD D,B               ;GET THE "B" FIELD SPEC IN D FOR FOUTTS
  JP FOUTTS            ;FINISH UP THE NUMBER

	;HERE TO PRINT AN INTEGER IN FIXED FORMAT--FLOATING POINT NOTATION
FFXIFL:
  PUSH HL              ;SAVE THE BUFFER POINTER
  PUSH DE              ;SAVE THE FORMAT SPECS
  CALL CONSI           ;CONVERT THE INTEGER TO A SNG
  POP DE               ;GET THE FORMAT SPECS BACK
;;;  XOR A                 ;SET FLAGS TO PRINT THE NUMBER AS A SNG
                       ;FALL INTO FFXFLV
FFXFLV:
  CALL FTCH_SNG
  LD E,B               ; () GET HOW MANY DIGITS WE PRINT
  
; Routine at 13817
  CALL SIGN            ;SEE IF WE HAVE ZERO
  PUSH AF
  CALL NZ,FOUTNV       ;IF NOT, NORMALIZE THE NUMBER SO ALL DIGITS TO BE PRINTED ARE IN THE INTEGER PART
  POP AF
  POP HL               ;GET THE BUFFER POINTER BACK
  POP BC               ;GET THE FIELD LENGTH SPECS
  PUSH AF              ;SAVE THE EXPONENT
  LD A,C               ;CALCULATE HOW MANY SIGNIFICANT DIGITS WE MUST
  OR A                 ; PRINT
  PUSH AF              ;SAVE THE "C" FIELD SPEC FOR LATER
  CALL NZ,DCRART       ; (DEC A, RET)
  ADD A,B
  LD C,A
  LD A,D               ;GET THE "A" FIELD SPEC
  AND $04              ;SEE IF THE SIGN IS A TRAILING SIGN
  CP $01               ;SET CARRY IF A IS ZERO
  SBC A,A              ;SET D=0 IF WE HAVE A TRAILING SIGN,
  LD D,A               ; D=377 IF WE DO NOT
  ADD A,C
  LD C,A               ;SET C=NUMBER OF SIGNIFICANT DIGITS TO PRINT
  SUB E                ;IF WE HAVE LESS THAN E, THEN WE MUST GET RID
  PUSH AF              ;SAVE COMPARISON # OF SIG DIGITS AND THE # OF DIGITS WE WILL PRINT
  JP P,FFXLV3_0
  CALL FINDIV          ; OF SOME BY DIVIDING BY TEN AND ROUNDING
  JR NZ,FFXLV3_0
  PUSH HL
  CALL DSHFRB          ;SHIFT NUMBER RIGHT ONE, SHIFT IN CARRY
  LD HL,FACCU
  INC (HL)
  POP HL
FFXLV3_0:
  POP AF               ;GET # OF TRAILING ZEROS TO PRINT
  PUSH BC              ;SAVE THE "B" FIELD SPEC AND # OF SIG DIGITS
  PUSH AF              ;SAVE # OF TRAILING ZEROS TO PRINT
  JP M,FFXLV3          ;TAKE INTO ACCOUNT DIGITS THAT WERE
  XOR A                ;DIVIDED OFF AT FFXLV1
FFXLV3:
  CPL
  INC A
  ADD A,B              ;SET THE DECIMAL PLACE COUNT
  INC A                
  ADD A,D              ;TAKE INTO ACCOUNT IF THE SIGN IS TRAILING
  LD B,A               ; OR NOT
  LD C,$00             ;SET COMMA COUNT TO ZERO, THE COMMA SPEC IS IGNORED.
  CALL Z,FOUTAN        ;CONVERT THE NUMBER TO DECIMAL DIGITS
  CALL FOUTCV          ;GET NUMBER TRAILING ZEROS TO PRINT
  POP AF

	;IF THE FIELD LENGTH IS LONGER THAN THE # OF DIGITS
	;WE CAN PRINT
  CALL P,FOTZNC        ;THE DECIMAL POINT COULD COME OUT IN HERE
  CALL FOUTED          ;IN CASE D.P. IS LAST ON LIST
  POP BC               ;GET # OF SIG DIGITS AND "B" FIELD SPAC BACK
  POP AF               ;GET THE "C" FIELD SPEC BACK
  JR NZ,FFXLV4         ;IF NON-ZERO PROCEED
  CALL DCXHRT          ;SEE IF D.P. THERE
  LD A,(HL)            ;FETCH TO MAKE SURE D.P.
  CP '.'               ;IF NOT MUST BE ZERO
  CALL NZ,INCHL        ;IF NOT MUST LEAVE AS IS
  LD (NXTOPR),HL       ;NEED D.P. LOCATION IN TEMP2
FFXLV4:                ; SO IGNORE IT.
  POP AF               ;GET THE EXPONENT BACK
  LD A,(FACCU)
  JR Z,FFXLV2          ;EXPONENT=0 IF THE NUMBER IS ZERO
  ADD A,E              ;SCALE IT CORRECTLY
  SUB B
  SUB D
FFXLV2:
  PUSH BC              ;SAVE THE "B" FIELD SPEC
  CALL DOEBIT          ;PUT THE EXPONENT IN THE BUFFER
  EX DE,HL             ;GET THE POINTER TO THE END IN (HL) IN CASE WE HAVE A TRAILING SIGN
  POP DE               ;GET THE "B" FIELD SPEC IN D, PUT ON A
  JP FOUTTS            ; POSSIBLE TRAILING SIGN AND WE ARE DONE


	;HERE TO PUT SOME ZEROS IN THE BUFFER
	;THE COUNT IS IN A, IT CAN BE ZERO, BUT THE ZERO FLAG MUST BE SET
	;ONLY (HL) AND A ARE ALTERED
	;WE EXIT WITH A=0
; Routine at 13926
FOTZER:
  OR A                 ;THIS IS BECAUSE FFXXV3 CALL US WITH THE CONDITION CODES NOT SET UP
FOTZR1:
  RET Z                ;RETURN IF WE ARE DONE
  DEC A                ;WE ARE NOT DONE, SO DECREMENT THE COUNT
  LD (HL),'0'          ;PUT A ZERO IN THE BUFFER
  INC HL               ;UPDATE THE BUFFER POINTER
  JR FOTZR1            ;GO SEE IF WE ARE NOW DONE


	;HERE TO PUT ZEROS IN THE BUFFER WITH COMMAS OR A DECIMAL POINT IN THE MIDDLE.  
	;THE COUNT IS IN A, IT CAN BE ZERO, BUT THE ZERO FLAG MUST BE SET.
	;B THE DECIMAL POINT COUNT AND C THE COMMA COUNT ARE UPDATED
	;A,B,C,H,L ARE ALTERED
; Data block at 13934
FOTZNC:
  JR NZ,FOTZEC         ;ENTRY AFTER A "CALL FOUTCV"
FOTZRC:
  RET Z                ;RETURN IF WE ARE DONE
  CALL FOUTED          ;SEE IF WE HAVE TO PUT A COMMA OR A DECIMAL POINT BEFORE THIS ZERO
FOTZEC:                
  LD (HL),'0'          ;PUT A ZERO IN THE BUFFER
  INC HL               ;UPDATE THE BUFFER POINTER
  DEC A                ;DECREMENT THE ZERO COUNT
  JR FOTZRC            ;GO BACK AND SEE IF WE ARE DONE


; Routine at 13946
FOUTCD:
  LD A,E               ;SETUP DECIMAL POINT COUNT
  ADD A,D
  INC A
  LD B,A
  INC A                ;SETUP COMMA COUNT
FOUTCD_0:
  SUB $03              ;REDUCE [A] MOD 3
  JR NC,FOUTCD_0
  ADD A,$05            ;ADD 3 BACK IN AND ADD 2 MORE FOR SCALING
  LD C,A               ;SAVE A POSSIBLE COMMA COUNT

FOUICC:
  LD A,(TEMP3)         ;GET THE FORMAT SPECS
  AND $40              ;LOOK AT THE COMMA BIT
  RET NZ               ;WE ARE USING COMMAS, JUST RETURN
  LD C,A               ;WE AREN'T, ZERO THE COMMA COUNT
  RET                  ;ALL DONE


;*****************************************************************
;
;       $FOUTAN  THIS ROUTINE IS CALLED BY THE FREE FORMAT OUTPUT
;               CODE TO OUTPUT DECIMAL POINT AND LEADING ZEROS.
;       $FOUTED  THIS ROUTINE IS CALLED BY BOTH THE FREE FORMAT
;               OUTPUT ROUTINE AND THE PRINT USING CODE TO OUTPUT
;               THE DECIMAL POINT WHEN NECESSARY AND TO PUT IN
;               COMMAS "," AFTER EACH THREE DIGITS IF THIS OPTION
;               IS INVOKED.
;       CALLING SEQUENCE:       CALL    $FOUTAN
;                               CALL    $FOUTED
;               WITH $FMTCX CONTAINING NUMBER PLACES PRIOR TO
;               DECIMAL POINT(NEGATIVELY) IN UPPER BYTE AND
;               NO PLACES BEFORE NEXT COMMA IN LOW BYTE
;
;*******************************************************************


	;HERE TO PUT DECIMAL POINTS AND COMMAS IN THEIR CORRECT PLACES
	;THIS SUBROUTINE SHOULD BE CALLED BEFORE THE NEXT DIGIT IS PUT IN THE
	;BUFFER.  B=THE DECIMAL POINT COUNT, C=THE COMMA COUNT
	;THE COUNTS TELL HOW MANY MORE DIGITS HAVE TO GO IN BEFORE THE COMMA
	;OR DECIMAL POINT GO IN.  THE COMMA OR DECIMAL POINT THEN GOES BEFORE 
	;THE LAST DIGIT IN THE COUNT.  FOR EXAMPLE, IF THE DECIMAL POINT SHOULD
	;COME AFTER THE FIRST DIGIT, THE DECIMAL POINT COUNT SHOULD BE 2.
; Routine at 13966
;
FOUTAN:
  DEC B             ;IF NEGATIVE THEN LEADING ZEROS
  JP P,FTD05                                            ;PROCESS AS NORMAL
  LD (NXTOPR),HL    ;SAVE DECIMAL POINT COUNT           ;SAVE LOCATION OF DECIMAL POINT
  LD (HL),'.'       ;MOVE IN DECIMAL POINT
FTN10:              
  INC HL            ;POINT TO NEXT OUTPUT POSITION
  LD (HL),'0'       ;PUT IN LEADING ZERO
  INC B             ;WILL INCREMENT B UNTIL ZERO
  LD C,B            
  JR NZ,FTN10       ;PUT IN LEADING ZEROS UNTIL B ZERO
  INC HL            ;POINT TO NEXT AVAILABLE BUFFER LOCATION
  RET

; Routine at 13984
; Used by the routines at FOUTCI.
FOUTED:
  DEC B             ;TIME FOR D.P.?
FTD05:              
  JR NZ,FOUED1      ;IF NOT D.P. TIME, SEE IF COMMA TIME

	;ENTRY TO PUT A DECIMAL POINT IN THE BUFFER
FOUTDP:            
  LD (HL),'.'       ;YES, PUT THE DECIMAL POINT IN
  LD (NXTOPR),HL    ;SAVE THE LOCATION OF THE DECIMAL POINT
  INC HL            ;INCREMENT THE BUFFER POINTER PAST D.P. 
  LD C,B            ;PUT ZERO IN C SO WE WON"T PRINT ANY COMMAS AFTER THE DECIMAL POINT.
  RET               ;ALL DONE

;HERE TO SEE IF IT IS TIME TO PRINT A COMMA
FOUED1:
  DEC C             ;IF ZERO TIME FOR COMMA
  RET NZ            ;NOPE, WE CAN RETURN
  LD (HL),','       ;YES, PUT A COMMA IN THE BUFFER
  INC HL            ;POINT TO NEXT BUFFER POSITION
  LD C,$03          ;RESET THE COMMA COUNT SO WE WILL PRINT A COMMA AFTER THREE MORE DIGITS.
  RET               ;ALL DONE


	;HERE TO CONVERT A SNG OR DBL NUMBER THAT HAS BEEN NORMALIZED TO DECIMAL DIGITS.
	;THE DECIMAL POINT COUNT AND COMMA COUNT ARE IN B AND C RESPECTIVELY.
	;(HL) POINTS TO WHERE THE FIRST DIGIT WILL GO.
	;THIS EXITS WITH A=0.  (DE) IS LEFT UNALTERED.
; Data block at 14003
  ; --- START PROC FOUTCV ---
FOUTCV:
  PUSH DE
	;HERE TO CONVERT A DOUBLE PRECISION NUMBER TO DECIMAL DIGITS
  PUSH HL
  PUSH BC
  CALL FTCH_SNG
  LD A,B
  POP BC
  POP HL
  LD DE,FACCU+1
  SCF
FOUCD1:
  PUSH AF
  CALL FOUTED
  LD A,(DE)
  JR NC,L36CD
  RRA
  RRA
  RRA
  RRA
  JR L36CE

L36CD:
  INC DE
L36CE:
  AND $0F
  ADD A,'0'
  LD (HL),A
  INC HL
  POP AF
  DEC A
  CCF
  JR NZ,FOUCD1
  JR FOUCI3


;*************************************************************
;
;       $FOUTCI  CONVERT THE INTEGER IN (FACLO)-TWO BYTES TO
;               ASCII DIGITS.
;       CALLING SEQUENCE:       CALL    $FOUTCI
;               WITH DECIMAL POINT AND COMMA COUNTS IN (CX)
;       $FOUTO  CONVERT INTEGER IN $FACLO:FACLO+1 TO OCTAL
;       $FOUTH  CONVERT INTEGER IN $FACLO:FACLO+1 TO HEXIDECIMAL
;       CALLING SEQUENCE:       CALL    $FOUTO/$FOUTH
;               WITH $FACLO:FACLO+1 CONTAINING INTEGER TO BE
;               PRINTED. RETURNS WITH (BX) POINTING TO $FBUFF
;
;**************************************************************

	;HERE TO CONVERT AN INTEGER INTO DECIMAL DIGITS
	;THIS EXITS WITH A=0.  (DE) IS LEFT UNALTERED.
; Routine at 14043
FOUTCI:
  PUSH DE
  LD DE,POWERS_TAB        ;INTEGER POWER OF TEN TABLE (a.k.a. FOITB)
  LD A,$05                ;MAX DIGITS TO CONVERT

	;HERE TO CALCULATE EACH DIGIT
FOUCI1:                   ;ENTRY FOR FOTCV SO WE WILL ONLY CONVERT 4 DIGITS
  CALL FOUTED             ;SEE IF A COMMA OR DP GOES BEFORE THE DIGIT
  PUSH BC                 ;SAVE COMMA AND DECIMAL POINT INFORMATION
  PUSH AF                 ;SAVE DIGIT COUNT
  PUSH HL                 ;SAVE BUFFER POINTER
  EX DE,HL                ;GET THE POWER OF TEN POINTER IN (HL)
  LD C,(HL)               ;PUT THE POWER OF TEN ON THE STACK
  INC HL
  LD B,(HL)
  PUSH BC
  INC HL                  ;INCREMENT THE PWR OF TEN PTR TO NEXT POWER
  EX (SP),HL              ;GET THE POWER OF TEN IN (HL) AND PUT THE POINTER ON THE STACK
  EX DE,HL                ;PUT THE POWER OF TEN IN (DE)
  LD HL,(FACLOW)          ;GET THE INTEGER IN (HL)
  LD B,'0'-1              ;SET UP THE DIGIT COUNT, B=DIGIT TO BE PRINTED


FOUCI2:
  INC B                   ;INCREMENT THE DIGIT COUNT
	; HL=HL-DE: SUBTRACT OUT POWER OF TEN
  LD A,L                  ;SUBTRACT (DE) FROM (HL)
  SUB E                   ;SUBTRACT THE LOW ORDERS
  LD L,A                  ;SAVE THE NEW RESULT
  LD A,H                  ;SUBTRACT THE HIGH ORDERS
  SBC A,D
  LD H,A                  ;SAVE THE NEW HIGH ORDER
  JR NC,FOUCI2            ;IF (HL) WAS .GE. (DE) THEN SUBTRACT AGAIN
  ADD HL,DE               ;WE ARE DONE, BUT WE SUBTRACTED (DE) ONCE TOO OFTEN, SO ADD IT BACK IN
  LD (FACLOW),HL          ;SAVE IN THE FAC WHAT IS LEFT
  POP DE                  ;GET THE POWER OF TEN POINTER BACK
  POP HL                  ;GET THE BUFFER POINTER BACK
  LD (HL),B               ;PUT THE NEW DIGIT IN THE BUFFER
  INC HL                  ;INCREMENT THE BUFFER POINTER TO NEXT DIGIT
  POP AF                  ;GET THE DIGIT COUNT BACK
  POP BC                  ;GET THE COMMA AND DP INFORMATION BACK
  DEC A                   ;WAS THAT THE LAST DIGIT?
  JR NZ,FOUCI1            ;NO, GO DO THE NEXT ONE
FOUCI3:
  CALL FOUTED             ;YES, SEE IF A DP GOES AFTER THE LAST DIGIT
  LD (HL),A               ;PUT A ZERO AT THE END OF THE NUMBER, BUT DON'T INCREMENT (HL)
                          ;SINCE AN EXPONENT OR A TRAILING SIGN MAY BE COMMING
  POP DE                  ;GET (DE) BACK
  RET                     ;ALL DONE, RETURN WITH A=0


	;CONSTANTS USED BY FOUT

; Routine at 14096
POWERS_TAB:
	DEFW 10000
	DEFW 1000
	DEFW 100
	DEFW 10
	DEFW 1

  
; This entry point is used by __BIN$.
BIN_STR:
  DEFB $06	; "LD B,1"   	; BASE: 2^1 -> 2
L371B:
  DEFB $01	; "LD BC,nn" to jump over the next word without executing it
L371C:
  DEFB $18	; "JR 06 -> FOUT_SUB
L371D:
  DEFB $06	; "LD B,6" /INC BC 	; BASE: 2^6 -> 64 (this is incidental !!)

; This entry point is used by the routines at NUMLIN and __OCT$.
FOUTO:
  LD B,$03	; BASE: 2^3 -> 8
  JR FOUT_SUB

; Routine at 14114
;
; Used by the routines at NUMLIN and __HEX$.
FOUTH:
  LD B,$04	; BASE: 2^4 -> 16


FOUT_SUB:
  PUSH BC
  CALL GETWORD_HL      ;GET DOUBLE BYTE INT IN [H,L]
  LD DE,FBUFFR+17      ;POINTER TO OUTPUT BUFFER IN [D,E]
  XOR A	               ;GET SET TO HAVE FIRST DIGIT FOR OCTAL
  LD (DE),A            ;CLEAR DIGIT SEEN FLAG
  POP BC
  LD C,A
FOUT_SUB_0:
  PUSH BC
  DEC DE               ;BUMP POINTER
FOUT_SUB_1:
  AND A
  LD A,H
  RRA
  LD H,A
  LD A,L
  RRA
  LD L,A
  LD A,C
  RRA
  LD C,A
  DJNZ FOUT_SUB_1
  POP BC
  PUSH BC
MAKDIG:
  RLCA
  DJNZ MAKDIG
  ADD A,'0'            ;MAKE NUMERIC DIGIT
  CP '9'+1             ;IS IT A BIG HEX DIGIT? (A-F)
  JR C,NOTHAL          ;NO, DONT ADD OFFSET
  ADD A,'A'-'9'-1      ;(A..F) ADD OFFSET
NOTHAL:
  LD (DE),A            ;SAVE DIGIT IN FBUFFR
  POP BC
  LD A,L
  OR H
  JR NZ,FOUT_SUB_0
  EX DE,HL
  RET

; Routine at 14162
;
; Used by the routines at FINDIV, FOUTNV and L37B4.
FTCH_SNG:
  RST GETYPR 		; Get the number type (FAC)
  LD HL,FACCU+7
  LD B,$0E
  RET NC
  LD HL,FACLOW+1
  LD B,$06
  RET


	;HERE TO INITIALLY SET UP THE FORMAT SPECS AND PUT IN A SPACE FOR THE
	;SIGN OF A POSITIVE NUMBER
; Routine at 14175
FOUINI:
  LD (TEMP3),A          ;SAVE THE FORMAT SPECIFICATION
  PUSH AF
  PUSH BC
  PUSH DE
  CALL __CDBL
  LD HL,FP_ZERO
  LD A,(FACCU)
  AND A
  CALL Z,HL2FACCU
  POP DE
  POP BC
  POP AF
  LD HL,FBUFFR+1		;WE START AT FBUFFR+1 IN CASE THE NUMBER WILL OVERFLOW ITS FIELD, 
                        ; THEN THERE IS ROOM IN FBUFFR FOR THE PERCENT SIGN.
  LD (HL),' '           ;PUT IN A SPACE
  RET                   ;ALL DONE

; Routine at 14203
;
FINDIV:
  PUSH HL
  PUSH DE
  PUSH BC
  PUSH AF
  CPL
  INC A
  LD E,A
  LD A,$01
  JP Z,FINDIV_1
  CALL FTCH_SNG
  PUSH HL
FINDIV_0:
  CALL DSHFRB
  DEC E
  JR NZ,FINDIV_0
  POP HL
  INC HL
  LD A,B
  RRCA
  LD B,A
  CALL BNORM_8
  CALL L37B4
FINDIV_1:
  POP BC
  ADD A,B
  POP BC
  POP DE
  POP HL
  RET

; Routine at 14242
;
FOUTNV:
  PUSH BC
  PUSH HL
  CALL FTCH_SNG
  LD A,(FACCU)
  SUB $40
  SUB B
  LD (FACCU),A
  POP HL
  POP BC
  OR A
  RET

; Routine at 14260
;
; Used by the routine at FINDIV.
L37B4:
  PUSH BC
  CALL FTCH_SNG
L37B4_0:
  LD A,(HL)
  AND $0F
  JR NZ,L37B4_1
  DEC B
  LD A,(HL)
  OR A
  JR NZ,L37B4_1
  DEC HL
  DJNZ L37B4_0
L37B4_1:
  LD A,B
  POP BC
  RET

; Single precision exponential function
FEXP:
  CALL DEC_HL2ARG
  CALL CONDS
  CALL STAKARG
  CALL XSTKFP
  CALL USTAKARG


; Double precision exponential function
DEXP:
  LD A,(ARG)
  OR A
  JP Z,INTEXP_0		; SIGN - test FP number sign
  LD H,A
  LD A,(FACCU)
  OR A
  JP Z,INTEXP_2
  CALL STAKFP
  CALL L391A
  JR C,DEXP_1
  EX DE,HL
  LD (TEMP8),HL
  CALL VALDBL
  CALL USTAKARG
  CALL L391A
  CALL VALDBL
  LD HL,(TEMP8)
  JP NC,L385A
  LD A,(ARG)
  PUSH AF
  PUSH HL
  CALL ARG2FACCU
  LD HL,FBUFFR		; Buffer for fout
  CALL DBL_FACCU2HL
  LD HL,FP_UNITY                                              ; Load '1' to FP accumulator
  CALL HL2FACCU               ;SAVE y                         ; Put value on stack
  POP HL
  LD A,H
  OR A
  PUSH AF
  JP P,DEXP_0
  XOR A
  LD C,A
  SUB L
  LD L,A
  LD A,C
  SBC A,H
  LD H,A
DEXP_0:
  PUSH HL
  JP L3878_0

DEXP_1:
  CALL VALDBL
  CALL ARG2FACCU
  CALL XSTKFP
  CALL __LOG
  CALL USTAKARG
  CALL DMUL
  JP __EXP

  
; Integer exponential function
; FACCU=DE^HL
INTEXP:
  LD A,H
  OR L
  JR NZ,INTEXP_1
		
INTEXP_0:
  LD HL,$0001
  JP INT_RESULT_ONE

INTEXP_1:
  LD A,D
  OR E
  JR NZ,L385A
INTEXP_2:
  LD A,H
  RLA
  JR NC,INT_RESULT_ZERO
  JP O_ERR			; Err $0B - "Division by zero"

INT_RESULT_ZERO:
  LD HL,$0000
INT_RESULT_ONE:
  JP MAKINT

L385A:
  LD (TEMP8),HL
  PUSH DE
  LD A,H
  OR A
  PUSH AF
  CALL M,INEGHL
  LD B,H
  LD C,L
  LD HL,$0001
L3869:
  OR A
  LD A,B
  RRA
  LD B,A
  LD A,C
  RRA
  LD C,A
  JR NC,L3877
  CALL L390D
  JR NZ,L38C3
L3877:
  LD A,B
L3878:
  OR C
  JR Z,L3878_2
  PUSH HL
  LD H,D
  LD L,E
  CALL L390D
  EX DE,HL
  POP HL
  JR Z,L3869
  PUSH BC
  PUSH HL
  LD HL,FBUFFR		; Buffer for fout
  CALL DBL_FACCU2HL
  POP HL
  CALL HL_CSNG
  CALL CONDS
; This entry point is used by the routine at DEXP.
L3878_0:
  POP BC
  LD A,B
  OR A
  RRA
  LD B,A
  LD A,C
  RRA
  LD C,A
  JR NC,L3878_1
  PUSH BC
  LD HL,FBUFFR		; Buffer for fout
  CALL MULPHL
  POP BC
L3878_1:
  LD A,B
  OR C
  JR Z,L3878_2
  PUSH BC
  CALL STAKFP
  LD HL,FBUFFR		; Buffer for fout
  PUSH HL
  CALL HL2FACCU
  POP HL
  PUSH HL
  CALL MULPHL
  POP HL
  CALL DBL_FACCU2HL
  CALL USTAKFP
  JR L3878_0
  
L38C3:
  PUSH BC
  PUSH DE
  CALL __CDBL
  CALL FACCU2ARG
  POP HL
  CALL HL_CSNG
  CALL CONDS
  LD HL,FBUFFR		; Buffer for fout
  CALL DBL_FACCU2HL
  CALL ARG2FACCU
  POP BC
  JR L3878_1
  
L3878_2:
  POP AF
  POP BC
  RET P
  LD A,(VALTYP)
  CP $02		; Integer ?
  JR NZ,L3878_3
  PUSH BC
  CALL HL_CSNG
  CALL CONDS
  POP BC
L3878_3:
  LD A,(FACCU)
  OR A
  JR NZ,L3878_4
  LD HL,(TEMP8)
  OR H
  RET P
  LD A,L
  RRCA
  AND B
  JP OV_ERR			; Err $06 -  "Overflow"
  
L3878_4:
  CALL FACCU2ARG
  LD HL,FP_UNITY
  CALL HL2FACCU
  JP DDIV

  
; Routine at 14605
;
; Used by the routine at L3878.
L390D:
  PUSH BC
  PUSH DE
  CALL IMULT
  LD A,(VALTYP)
  CP $02		; Integer ?
  POP DE
  POP BC
  RET

; Routine at 14618
;
; Used by the routine at DEXP.
L391A:
  CALL ARG2FACCU
  CALL STAKARG
  CALL __INT
  CALL USTAKARG
  CALL XDCOMP
  SCF
  RET NZ
  JP CINT

; Jump table for statements and functions
; $392E
FNCTAB:
  DEFW __END
  DEFW __FOR
  DEFW __NEXT
  DEFW __DATA
  DEFW __INPUT
  DEFW __DIM
  DEFW __READ
  DEFW __LET
  DEFW __GOTO
  DEFW __RUN
  DEFW __IF
  DEFW __RESTORE
  DEFW __GOSUB
  DEFW __RETURN
  DEFW __REM
  DEFW __STOP
  DEFW __PRINT
  DEFW __CLEAR
  DEFW __LIST
  DEFW __NEW
  DEFW __ON
  DEFW __WAIT
  DEFW __DEF
  DEFW __POKE
  DEFW __CONT
  DEFW __CSAVE
  DEFW __CLOAD
  DEFW __OUT
  DEFW __LPRINT
  DEFW __LLIST
  DEFW __CLS
  DEFW __WIDTH
  DEFW __REM		; ELSE
  DEFW __TRON
  DEFW __TROFF
  DEFW __SWAP
  DEFW __ERASE
  DEFW __ERROR
  DEFW __RESUME
  DEFW __DELETE
  DEFW __AUTO
  DEFW __RENUM
  DEFW __DEFSTR
  DEFW __DEFINT
  DEFW __DEFSNG
  DEFW __DEFDBL
  DEFW __LINE
  DEFW __OPEN
  DEFW __FIELD
  DEFW __GET
  DEFW __PUT
  DEFW __CLOSE
  DEFW __LOAD
  DEFW __MERGE
  DEFW __FILES
  DEFW __LSET
  DEFW __RSET
  DEFW __SAVE
  DEFW __LFILES
  DEFW __CIRCLE
  DEFW __COLOR
  DEFW __DRAW
  DEFW __PAINT
  DEFW BEEP
  DEFW __PLAY
  DEFW __PSET
  DEFW __PRESET
  DEFW __SOUND
  DEFW __SCREEN
  DEFW __VPOKE
  DEFW __SPRITE
  DEFW __VDP
  DEFW __BASE
  DEFW __CALL
  DEFW __TIME
  DEFW __KEY
  DEFW __MAX
  DEFW __MOTOR
  DEFW __BLOAD
  DEFW __BSAVE
  DEFW __DSKO_S
  DEFW __SET
  DEFW __NAME
  DEFW __KILL
  DEFW __IPL
  DEFW __COPY
  DEFW __CMD
  DEFW __LOCATE
  
FNCTAB_FN:
  DEFW __LEFT_S
  DEFW __RIGHT_S
  DEFW __MID_S
  DEFW __SGN
  DEFW __INT
  DEFW __ABS
  DEFW __SQR
  DEFW __RND
  DEFW __SIN
  DEFW __LOG
  DEFW __EXP
  DEFW __COS
  DEFW __TAN
  DEFW __ATN
  DEFW __FRE
  DEFW __INP
  DEFW __POS
  DEFW __LEN
  DEFW __STR_S
  DEFW __VAL
  DEFW __ASC
  DEFW __CHR_S
  DEFW __PEEK
  DEFW __VPEEK
  DEFW __SPACE_S
  DEFW __OCT_S
  DEFW __HEX_S
  DEFW __LPOS
  DEFW __BIN_S
  DEFW __CINT
  DEFW __CSNG
  DEFW __CDBL
  DEFW __FIX
  DEFW __STICK
  DEFW __STRIG
  DEFW __PDL
  DEFW __PAD
  DEFW __DSKF
  DEFW __FPOS
  DEFW __CVI
  DEFW __CVS
  DEFW __CVD
  DEFW __EOF
  DEFW __LOC
  DEFW __LOF
  DEFW __MKI_S
  DEFW __MKS_S
  DEFW __MKD_S

FNCTAB_END:

; Table position: $3A3E
WORD_PTR:
  DEFW WORDS_A
  DEFW WORDS_B
  DEFW WORDS_C
  DEFW WORDS_D
  DEFW WORDS_E
  DEFW WORDS_F
  DEFW WORDS_G
  DEFW WORDS_H
  DEFW WORDS_I
  DEFW WORDS_J
  DEFW WORDS_K
  DEFW WORDS_L
  DEFW WORDS_M
  DEFW WORDS_N
  DEFW WORDS_O
  DEFW WORDS_P
  DEFW WORDS_Q
  DEFW WORDS_R
  DEFW WORDS_S
  DEFW WORDS_T
  DEFW WORDS_U
  DEFW WORDS_V
  DEFW WORDS_W
  DEFW WORDS_X
  DEFW WORDS_Y
  DEFW WORDS_Z
  

; BASIC keyword and TOKEN codes list
WORDS:

WORDS_A:
  DEFM "UT"
  DEFB 'O'+$80
  DEFB TK_AUTO

  DEFM "N"
  DEFB 'D'+$80
  DEFB TK_AND

  DEFM "B"
  DEFB 'S'+$80
  DEFB TK_ABS

  DEFM "T"
  DEFB 'N'+$80
  DEFB TK_ATN

  DEFM "S"
  DEFB 'C'+$80
  DEFB TK_ASC

  DEFM "TTR"
  DEFB '$'+$80
  DEFB TK_ATTR

  DEFB $00


WORDS_B:

  DEFM "AS"
  DEFB 'E'+$80
  DEFB TK_BASE

  DEFM "SAV"
  DEFB 'E'+$80
  DEFB TK_BSAVE

  DEFM "LOA"
  DEFB 'D'+$80
  DEFB TK_BLOAD

  DEFM "EE"
  DEFB 'P'+$80
  DEFB TK_BEEP

  DEFM "IN"
  DEFB '$'+$80
  DEFB TK_BIN

  DEFB $00


WORDS_C:

  DEFM "AL"
  DEFB 'L'+$80
  DEFB TK_CALL

  DEFM "LOS"
  DEFB 'E'+$80
  DEFB TK_CLOSE

  DEFM "OP"
  DEFB 'Y'+$80
  DEFB TK_COPY

  DEFM "ON"
  DEFB 'T'+$80
  DEFB TK_CONT

  DEFM "LEA"
  DEFB 'R'+$80
  DEFB TK_CLEAR

  DEFM "LOA"
  DEFB 'D'+$80
  DEFB TK_CLOAD

  DEFM "SAV"
  DEFB 'E'+$80
  DEFB TK_CSAVE

  DEFM "SRLI"
  DEFB 'N'+$80
  DEFB TK_CSRLIN

  DEFM "IN"
  DEFB 'T'+$80
  DEFB TK_CINT

  DEFM "SN"
  DEFB 'G'+$80
  DEFB TK_CSGN

  DEFM "DB"
  DEFB 'L'+$80
  DEFB TK_CDBL

  DEFM "V"
  DEFB 'I'+$80
  DEFB TK_CVI

  DEFM "V"
  DEFB 'S'+$80
  DEFB TK_CVS

  DEFM "V"
  DEFB 'D'+$80
  DEFB TK_CVD

  DEFM "O"
  DEFB 'S'+$80
  DEFB TK_COS

  DEFM "HR"
  DEFB '$'+$80
  DEFB TK_CHR_S

  DEFM "IRCL"
  DEFB 'E'+$80
  DEFB TK_CIRCLE

  DEFM "OLO"
  DEFB 'R'+$80
  DEFB TK_COLOR

  DEFM "L"
  DEFB 'S'+$80
  DEFB TK_CLS

  DEFM "M"
  DEFB 'D'+$80
  DEFB TK_CMD

  DEFB $00


WORDS_D:

  DEFM "ELET"
  DEFB 'E'+$80
  DEFB TK_DELETE

  DEFM "AT"
  DEFB 'A'+$80
  DEFB $84

  DEFM "I"
  DEFB 'M'+$80
  DEFB TK_DIM

  DEFM "EFST"
  DEFB 'R'+$80
  DEFB TK_DEFSTR

  DEFM "EFIN"
  DEFB 'T'+$80
  DEFB TK_DEFINT

  DEFM "EFSN"
  DEFB 'G'+$80
  DEFB TK_DEFSGN

  DEFM "EFDB"
  DEFB 'L'+$80
  DEFB TK_DEFDBL

  DEFM "SKO"
  DEFB '$'+$80
  DEFB TK_DSKO_S

  DEFM "E"
  DEFB 'F'+$80
  DEFB TK_DEF

  DEFM "SKI"
  DEFB '$'+$80
  DEFB TK_DSKI

  DEFM "SK"
  DEFB 'F'+$80
  DEFB TK_DSKF

  DEFM "RA"
  DEFB 'W'+$80
  DEFB TK_DRAW

  DEFB $00


WORDS_E:

  DEFM "LS"
  DEFB 'E'+$80
  DEFB TK_ELSE

  DEFM "N"
  DEFB 'D'+$80
  DEFB $81

  DEFM "RAS"
  DEFB 'E'+$80
  DEFB TK_ERASE

  DEFM "RRO"
  DEFB 'R'+$80
  DEFB TK_ERROR

  DEFM "R"
  DEFB 'L'+$80
  DEFB TK_ERL

  DEFM "R"
  DEFB 'R'+$80
  DEFB TK_ERR

  DEFM "X"
  DEFB 'P'+$80
  DEFB TK_EXP

  DEFM "O"
  DEFB 'F'+$80
  DEFB TK_EOF

  DEFM "Q"
  DEFB 'V'+$80
  DEFB TK_EQV

  DEFB $00


WORDS_F:

  DEFM "O"
  DEFB 'R'+$80
  DEFB TK_FOR

  DEFM "IEL"
  DEFB 'D'+$80
  DEFB TK_FIELD

  DEFM "ILE"
  DEFB 'S'+$80
  DEFB TK_FILES

  DEFB 'N'+$80
  DEFB TK_FN

  DEFM "R"
  DEFB 'E'+$80
  DEFB TK_FRE

  DEFM "I"
  DEFB 'X'+$80
  DEFB TK_FIX

  DEFM "PO"
  DEFB 'S'+$80
  DEFB TK_FPOS

  DEFB $00


WORDS_G:

  DEFM "OT"
  DEFB 'O'+$80
  DEFB TK_GOTO

  DEFM "O T"
  DEFB 'O'+$80
  DEFB TK_GOTO

  DEFM "OSU"
  DEFB 'B'+$80
  DEFB TK_GOSUB

  DEFM "E"
  DEFB 'T'+$80
  DEFB TK_GET

  DEFB $00


WORDS_H:

  DEFM "EX"
  DEFB '$'+$80
  DEFB TK_HEX_S

  DEFB $00


WORDS_I:

  DEFM "NPU"
  DEFB 'T'+$80
  DEFB TK_INPUT

  DEFB 'F'+$80
  DEFB TK_IF

  DEFM "NST"
  DEFB 'R'+$80
  DEFB TK_INSTR

  DEFM "N"
  DEFB 'T'+$80
  DEFB TK_INT

  DEFM "N"
  DEFB 'P'+$80
  DEFB TK_INP

  DEFM "M"
  DEFB 'P'+$80
  DEFB TK_IMP

  DEFM "NKEY"
  DEFB '$'+$80
  DEFB TK_INKEY_S

  DEFM "P"
  DEFB 'L'+$80
  DEFB TK_IPL

  DEFB $00


WORDS_J:

  DEFB $00


WORDS_K:

  DEFM "IL"
  DEFB 'L'+$80
  DEFB TK_KILL

  DEFM "E"
  DEFB 'Y'+$80
  DEFB TK_KEY

  DEFB $00


WORDS_L:

  DEFM "PRIN"
  DEFB 'T'+$80
  DEFB TK_LPRINT

  DEFM "LIS"
  DEFB 'T'+$80
  DEFB TK_LLIST

  DEFM "PO"
  DEFB 'S'+$80
  DEFB TK_LPOS

  DEFM "E"
  DEFB 'T'+$80
  DEFB TK_LET

  DEFM "OCAT"
  DEFB 'E'+$80
  DEFB TK_LOCATE

  DEFM "IN"
  DEFB 'E'+$80
  DEFB TK_LINE

  DEFM "OA"
  DEFB 'D'+$80
  DEFB TK_LOAD

  DEFM "SE"
  DEFB 'T'+$80
  DEFB TK_LSET

  DEFM "IS"
  DEFB 'T'+$80
  DEFB TK_LIST

  DEFM "FILE"
  DEFB 'S'+$80
  DEFB TK_LFILES

  DEFM "O"
  DEFB 'G'+$80
  DEFB TK_LOG

  DEFM "O"
  DEFB 'C'+$80
  DEFB TK_LOC

  DEFM "E"
  DEFB 'N'+$80
  DEFB TK_LEN

  DEFM "EFT"
  DEFB '$'+$80
  DEFB TK_LEFT_S

  DEFM "O"
  DEFB 'F'+$80
  DEFB TK_LOF

  DEFB $00


WORDS_M:

  DEFM "OTO"
  DEFB 'R'+$80
  DEFB TK_MOTOR

  DEFM "ERG"
  DEFB 'E'+$80
  DEFB TK_MERGE

  DEFM "O"
  DEFB 'D'+$80
  DEFB TK_MOD

  DEFM "KI"
  DEFB '$'+$80
  DEFB TK_MKI_S

  DEFM "KS"
  DEFB '$'+$80
  DEFB TK_MKS_S

  DEFM "KD"
  DEFB '$'+$80
  DEFB TK_MKD_S

  DEFM "ID"
  DEFB '$'+$80
  DEFB TK_MID_S

  DEFM "A"
  DEFB 'X'+$80
  DEFB TK_MAX

  DEFB $00


WORDS_N:

  DEFM "EX"
  DEFB 'T'+$80
  DEFB TK_NEXT

  DEFM "AM"
  DEFB 'E'+$80
  DEFB TK_NAME

  DEFM "E"
  DEFB 'W'+$80
  DEFB TK_NEW

  DEFM "O"
  DEFB 'T'+$80
  DEFB TK_NOT

  DEFB $00


WORDS_O:

  DEFM "PE"
  DEFB 'N'+$80
  DEFB TK_OPEN

  DEFM "U"
  DEFB 'T'+$80
  DEFB TK_OUT

  DEFB 'N'+$80
  DEFB $95

  DEFB 'R'+$80
  DEFB TK_OR

  DEFM "CT"
  DEFB '$'+$80
  DEFB TK_OCT_S

  DEFM "F"
  DEFB 'F'+$80
  DEFB TK_OFF

  DEFB $00


WORDS_P:

  DEFM "RIN"
  DEFB 'T'+$80
  DEFB TK_PRINT

  DEFM "U"
  DEFB 'T'+$80
  DEFB TK_PUT

  DEFM "OK"
  DEFB 'E'+$80
  DEFB TK_POKE

  DEFM "O"
  DEFB 'S'+$80
  DEFB TK_POS

  DEFM "EE"
  DEFB 'K'+$80
  DEFB TK_PEEK

  DEFM "SE"
  DEFB 'T'+$80
  DEFB TK_PSET

  DEFM "RESE"
  DEFB 'T'+$80
  DEFB TK_PRESET

  DEFM "OIN"
  DEFB 'T'+$80
  DEFB TK_POINT

  DEFM "AIN"
  DEFB 'T'+$80
  DEFB TK_PAINT

  DEFM "D"
  DEFB 'L'+$80
  DEFB TK_PDL

  DEFM "A"
  DEFB 'D'+$80
  DEFB TK_PAD

  DEFM "LA"
  DEFB 'Y'+$80
  DEFB TK_PLAY

  DEFB $00


WORDS_Q:

  DEFB $00


WORDS_R:

  DEFM "ETUR"
  DEFB 'N'+$80
  DEFB TK_RETURN

  DEFM "EA"
  DEFB 'D'+$80
  DEFB TK_READ

  DEFM "U"
  DEFB 'N'+$80
  DEFB TK_RUN

  DEFM "ESTOR"
  DEFB 'E'+$80
  DEFB TK_RESTORE

  DEFM "E"
  DEFB 'M'+$80
  DEFB TK_REM

  DEFM "ESUM"
  DEFB 'E'+$80
  DEFB TK_RESUME

  DEFM "SE"
  DEFB 'T'+$80
  DEFB TK_RSET

  DEFM "IGHT"
  DEFB '$'+$80
  DEFB TK_RIGHT_S

  DEFM "N"
  DEFB 'D'+$80
  DEFB TK_RND

  DEFM "ENU"
  DEFB 'M'+$80
  DEFB TK_RENUM

  DEFB $00


WORDS_S:

  DEFM "CREE"
  DEFB 'N'+$80
  DEFB TK_SCREEN

  DEFM "PRIT"
  DEFB 'E'+$80
  DEFB TK_SPRITE

  DEFM "TO"
  DEFB 'P'+$80
  DEFB TK_STOP

  DEFM "WA"
  DEFB 'P'+$80
  DEFB TK_SWAP

  DEFM "E"
  DEFB 'T'+$80
  DEFB TK_SET

  DEFM "AV"
  DEFB 'E'+$80
  DEFB TK_SAVE

  DEFM "PC"
  DEFB '('+$80
  DEFB TK_SPC

  DEFM "TE"
  DEFB 'P'+$80
  DEFB TK_STEP

  DEFM "G"
  DEFB 'N'+$80
  DEFB TK_SGN

  DEFM "Q"
  DEFB 'R'+$80
  DEFB TK_SQR

  DEFM "I"
  DEFB 'N'+$80
  DEFB TK_SIN

  DEFM "TR"
  DEFB '$'+$80
  DEFB TK_STR_S

  DEFM "TRING"
  DEFB '$'+$80
  DEFB TK_STRING

  DEFM "PACE"
  DEFB '$'+$80
  DEFB TK_SPACE_S

  DEFM "OUN"
  DEFB 'D'+$80
  DEFB TK_SOUND

  DEFM "TIC"
  DEFB 'K'+$80
  DEFB TK_STICK

  DEFM "TRI"
  DEFB 'G'+$80
  DEFB TK_TRIG

  DEFB $00


WORDS_T:

  DEFM "HE"
  DEFB 'N'+$80
  DEFB TK_THEN

  DEFM "RO"
  DEFB 'N'+$80
  DEFB TK_TRON

  DEFM "ROF"
  DEFB 'F'+$80
  DEFB TK_TROFF

  DEFM "AB"
  DEFB '('+$80
  DEFB TK_TAB

  DEFB 'O'+$80
  DEFB TK_TO

  DEFM "IM"
  DEFB 'E'+$80
  DEFB TK_TIME

  DEFM "A"
  DEFB 'N'+$80
  DEFB TK_TAN

  DEFB $00


WORDS_U:

  DEFM "SIN"
  DEFB 'G'+$80
  DEFB TK_USING

  DEFM "S"
  DEFB 'R'+$80
  DEFB TK_USR

  DEFB $00


WORDS_V:

  DEFM "A"
  DEFB 'L'+$80
  DEFB TK_VAL

  DEFM "ARPT"
  DEFB 'R'+$80
  DEFB TK_VARPTR

  DEFM "D"
  DEFB 'P'+$80
  DEFB TK_VDP

  DEFM "POK"
  DEFB 'E'+$80
  DEFB TK_VPOKE

  DEFM "PEE"
  DEFB 'K'+$80
  DEFB TK_VPEEK

  DEFB $00


WORDS_W:

  DEFM "IDT"
  DEFB 'H'+$80
  DEFB TK_WIDTH

  DEFM "AI"
  DEFB 'T'+$80
  DEFB TK_WAIT

  DEFB $00


WORDS_X:

  DEFM "O"
  DEFB 'R'+$80
  DEFB TK_XOR

  DEFB $00


WORDS_Y:

  DEFB $00


WORDS_Z:

  DEFB $00
  
  

OPR_TOKENS:
  DEFB $AB
  DEFB TK_PLUS		; Token for '+'
  DEFB $AD
  DEFB TK_MINUS		; Token for '-'
  DEFB $AA
  DEFB TK_STAR		; Token for '*'
  DEFB $AF
  DEFB TK_SLASH		; Token for '/'
  DEFB $DE
  DEFB TK_EXPONENT	; Token for '^'
  DEFB $DC
  DEFB TK_BKSLASH	; Token for '\'
  DEFB $A7
  DEFB TK_APOSTROPHE	; Token for '''
  DEFB $BE
  DEFB TK_GREATER	; Token for '>'
  DEFB $BD
  DEFB TK_EQUAL		; Token for '='
  DEFB $BC
  DEFB TK_MINOR		; Token for '<'
  DEFB $00

  

; ARITHMETIC PRECEDENCE TABLE
PRITAB:
  DEFB $79  ; +   (Token code $F1)
  DEFB $79  ; -
  DEFB $7c  ; *
  DEFB $7c  ; /
  DEFB $7f  ; ^
  DEFB $50  ; AND 
  DEFB $46  ; OR
  DEFB $3c  ; XOR
  DEFB $32  ; EQU
  DEFB $28  ; IMP
  DEFB $7a  ; MOD
  DEFB $7b  ; \   (Token code $FC)


; USED BY ASSIGNMENT CODE TO FORCE THE RIGHT HAND VALUE TO CORRESPOND
; TO THE VALUE TYPE OF THE VARIABLE BEING ASSIGNED TO.

; NUMBER TYPES
TYPE_OPR:
  DEFW __CDBL
  DEFW 0
  DEFW __CINT
  DEFW TSTSTR
  DEFW __CSNG

  
;
; THESE TABLES ARE USED AFTER THE DECISION HAS BEEN MADE
; TO APPLY AN OPERATOR AND ALL THE NECESSARY CONVERSION HAS
; BEEN DONE TO MATCH THE TWO ARGUMENT TYPES (APPLOP)
;

; ARITHMETIC OPERATIONS TABLE  
DEC_OPR:
  DEFW DADD
  DEFW DSUB
  DEFW DMUL
  DEFW DDIV
  DEFW DEXP
  DEFW DCOMP

defc OPCNT = ((FLT_OPR-DEC_OPR)/2)-1

; Message at 15709
FLT_OPR:
  DEFW FADD
  DEFW FSUB
  DEFW FMULT
  DEFW FDIV
  DEFW FEXP
  DEFW FCOMP
  
INT_OPR:
  DEFW IADD
  DEFW ISUB
  DEFW IMULT
  DEFW IDIV
  DEFW INTEXP
  DEFW ICOMP

; Message at 15734
ERROR_MESSAGES:
  DEFB $00
  ; Err $01
  DEFM "NEXT without FOR"
  DEFB $00
  ; Err $02
  DEFM "Syntax error"
  DEFB $00
  ; Err $03
  DEFM "RETURN without GOSUB"
  DEFB $00
  ; Err $04
  DEFM "Out of DATA"
  DEFB $00
  ; Err $05
  DEFM "Illegal function call"
  DEFB $00
  ; Err $06
  DEFM "Overflow"
  DEFB $00
  ; Err $07
  DEFM "Out of memory"
  DEFB $00
  ; Err $08
  DEFM "Undefined line number"
  DEFB $00
  ; Err $09
  DEFM "Subscript out of range"
  DEFB $00
  ; Err $0A
  DEFM "Redimensioned array"
  DEFB $00
  ; Err $0B
  DEFM "Division by zero"
  DEFB $00
  ; Err $0C
  DEFM "Illegal direct"
  DEFB $00
  ; Err $0D
  DEFM "Type mismatch"
  DEFB $00
  ; Err $0E
  DEFM "Out of string space"
  DEFB $00
  ; Err $0F
  DEFM "String too long"
  DEFB $00
  ; Err $10
  DEFM "String formula too complex"
  DEFB $00
  ; Err $11
  DEFM "Can't CONTINUE"
  DEFB $00
  ; Err $12
  DEFM "Undefined user function"
  DEFB $00
  ; Err $13
  DEFM "Device I/O error"
  DEFB $00
  ; Err $14
  DEFM "Verify error"
  DEFB $00
  ; Err $15
  DEFM "No RESUME"
  DEFB $00
  ; Err $16
  DEFM "RESUME without error"
  DEFB $00  
  ; Err $17 (but also $00)
  DEFM "Unprintable error"
  DEFB $00
  ; Err $18
  DEFM "Missing operand"
  DEFB $00
  ; Err $19
  DEFM "Line buffer overflow"
  DEFB $00

  ; Err $32
  DEFM "FIELD overflow"
  DEFB $00
  ; Err $33
  DEFM "Internal error"
  DEFB $00
  ; Err $34
  DEFM "Bad file number"
  DEFB $00
  ; Err $35
  DEFM "File not found"
  DEFB $00
  ; Err $36
  DEFM "File already open"
  DEFB $00
  ; Err $37
  DEFM "Input past end"
  DEFB $00
  ; Err $38
  DEFM "Bad file name"
  DEFB $00
  ; Err $39
  DEFM "Direct statement in file"
  DEFB $00
  ; Err $3A
  DEFM "Sequential I/O only"
  DEFB $00
  ; Err $3B
  DEFM "File not OPEN"
  DEFB $00
  
IN_MSG:
  DEFM " in "

NULL_STRING:
  DEFB $00

OK_MSG:
  DEFM "Ok"
  DEFB CR
  DEFB LF
  DEFB $00

BREAK_MSG:
  DEFM "Break"
  DEFB $00

; Data block at 16353
  ; --- START PROC BAKSTK ---
; Search FOR or GOSUB block on stack (skip 2 words)
; Used by 'RETURN' and 'NEXT'
BAKSTK:
  LD HL,$0004       ; IGNORING EVERYONES "NEWSTT" AND THE RETURN..
  ADD HL,SP         ; ..ADDRESS OF THIS SUBROUTINE

; Look for "FOR" block with same index as specified in D
; a.k.a. FNDFOR
;
LOKFOR:
  LD A,(HL)         ; Get block ID
  INC HL            ; Point to index address
  CP TK_FOR         ; Is it a "FOR" token                     ;IS THIS STACK ENTRY A "FOR"?
  RET NZ            ; No - exit                               ;NO SO OK
  LD C,(HL)         ; BC = Address of "FOR" index
  INC HL                                                      ;DO EQUIVALENT OF PUSHM / XTHL
  LD B,(HL)
  INC HL            ; Point to sign of STEP
  PUSH HL           ; Save pointer to sign                    ;PUT H  ON
  LD H,B            ; HL = address of "FOR" index             ;PUSH B / XTHL IS SLOWER
  LD L,C           
  LD A,D            ; See if an index was specified           ;FOR THE "NEXT" STATMENT WITHOUT AN ARGUMENT
  OR E              ; DE = 0 if no index specified            ;WE MATCH ON ANYTHING
  EX DE,HL          ; Specified index into HL                 ;MAKE SURE WE RETURN [D,E]
  JR Z,INDFND       ; Skip if no index given                  ;POINTING TO THE VARIABLE
  EX DE,HL          ; Index back into DE
  RST DCOMPR		; Compare index with one given
  
INDFND:
  LD BC,22          ; Offset to next block               ;TO WIPE OUT A "FOR" ENTRY
  POP HL            ; Restore pointer to sign
  RET Z             ; Return if block found, WITH [H,L] POINTING THE BOTTOM OF THE ENTRY
  ADD HL,BC         ; Point to next block
  JR LOKFOR         ; Keep on looking

;
; THE FOLLOWING FUNCTIONS ALLOW THE 
; USER FULL ACCESS TO THE ALTAIR I/O PORTS
; INP(CHANNEL#) RETURNS AN INTEGER WHICH IS THE STATUS
; OF THE CHANNEL. OUT CHANNEL#,VALUE PUTS OUT THE INTEGER
; VALUE ON CHANNEL #. IT IS A STATEMENT, NOT A FUNCTION.
;
__INP:
  CALL GETWORD_HL    ;GET INTEGER CHANNEL #
  LD B,H
  LD C,L
__INP_0:
  IN A,(C)
  JP PASSA

; Routine at 16395
;
; Used by the routines at __OUT and __WAIT.
; Get "WORD,BYTE" parameters
SETIO:
  CALL GETWORD      ; GET INTEGER CHANNEL NUMBER
  PUSH DE           ; Save channel # on stack
  RST SYNCHR
  DEFB ','          ;MAKE SURE THERE IS A COMMA
  CALL GETINT       ; Get integer 0-255
  POP BC            ; BC = channel #
  RET

; Routine at 16406
__OUT:
  CALL SETIO		; Get "WORD,BYTE" parameters
  OUT (C),A
  RET

; Routine at 16412
__WAIT:
  CALL SETIO		; Get "WORD,BYTE" parameters
  PUSH BC
  PUSH AF           ;SAVE THE MASK
  LD E,$00          ;DEFAULT MASK2 TO ZERO
  DEC HL
  RST CHRGTB		;SEE IF THE STATEMENT ENDED
  JR Z,__WAIT_0     ;IF NO THIRD ARGUMENT SKIP THIS
  RST SYNCHR
  DEFB ','          ;MAKE SURE THERE IS A ","
  CALL GETINT              ; Get integer 0-255
__WAIT_0:
  POP AF            ;REGET THE "AND" MASK
  LD D,A
  POP BC
__WAIT_1:
  CALL CKCNTC
  IN A,(C)
  XOR E             ;XOR WITH MASK2
  AND D             ;AND WITH MASK
  JR Z,__WAIT_1     ;LOOP UNTIL RESULT IS NON-ZERO
  RET

; Routine at 16441
PRG_END:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HPRGE			; Hook for Program End event
ENDIF
  LD HL,(CURLIN)		;GET CURRENT LINE #
  LD A,H                ;SEE IF in 'DIRECT' (immediate) mode
  AND L                 ;AND TOGETHER
  INC A                 ;SET CC'S
  JR Z,PRG_END_0		;IF DIRECT DONE, ALLOW FOR DEBUGGING PURPOSES
  LD A,(ONEFLG)         ;SEE IF IN ON ERROR
  OR A                  ;SET CC
  LD E,$15              ;"NO RESUME" ERROR (Err $15)
  JR NZ,ERROR			;YES, FORGOT RESUME
PRG_END_0:
  JP ENDCON             ;NO, LET IT END

; Routine at 16463
;
; Used by the routine at L4B4A.
DATSNR:
  LD HL,(DATLIN)
  LD (CURLIN),HL

; entry for '?SN ERROR'
;
; Used by the routines at LNUM_RANGE, RUNLIN, __AUTO, EVAL, OCTCNS, NOT_KEYWORD, __RENUM_0,
; __SYNCHR, __CALL, GETVAR, __CLEAR, __OPEN, __PLAY_2, L77FE and __MAX.
SN_ERR:
  LD E,$02	; DERSN - "Syntax error"
  
  DEFB $01	; "LD BC,nn" to jump over the next word without executing it
; a.k.a. OERR, DZERR
O_ERR:
  LD E,$0B	; DERDV0 - "Division by zero"
  
  DEFB $01	; "LD BC,nn" to jump over the next word without executing it
NF_ERR:
  LD E,$01	; DERNF - "NEXT without FOR"

  DEFB $01	; "LD BC,nn" to jump over the next word without executing it
DD_ERR:
  LD E,$0A	; "Redimensioned array"

  DEFB $01	; "LD BC,nn" to jump over the next word without executing it
UFN_ERR:
  LD E,$12  ; DERUF - "Undefined user function"

  DEFB $01	; "LD BC,nn" to jump over the next word without executing it
RW_ERR:
  LD E,$16	; DERRE - "RESUME without error"

  DEFB $01	; "LD BC,nn" to jump over the next word without executing it
OV_ERR:
  LD E,$06  ; DEROV - "Overflow"
  
  DEFB $01	; "LD BC,nn" to jump over the next word without executing it
MO_ERR:
  LD E,$18	; DERMO - "Missing operand"
  
  DEFB $01	; "LD BC,nn" to jump over the next word without executing it
TM_ERR:
  LD E,$0D	; DERTM - "Type mismatch"

; This entry point is used by the routines at PRG_END, TOKENIZE_COLON, FC_ERR, UL_ERR,
; __ERROR, FDTLP, IDTEST, CHKSTK, __CONT, TSTOPL, TESTR, CONCAT, NM_ERR, __CLOAD and IO_ERR.
ERROR:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HERRO			; Hook for Error handler
ENDIF
  XOR A
  LD (NLONLY),A
  LD HL,(VLZADR)
  LD A,H
  OR L
  JR Z,ERROR_1
  LD A,(VLZDAT)
  LD (HL),A
  LD HL,$0000
  LD (VLZADR),HL
ERROR_1:
  EI
  LD HL,(CURLIN)		 ; Line number the Basic interpreter is working on, in direct mode it will be filled with #FFFF
  LD (ERRLIN),HL
  LD A,H
  AND L
  INC A
  JR Z,ERRESM			; JR if in 'DIRECT' (immediate) mode
  LD (DOT),HL
  
; This entry point is also used by the routine at ON_ERROR.
ERRESM:		;(4096h)
  LD BC,ERRMOR
  JR ERESET


; Routine at 16539  ($409B)
;
; address of "warm boot" BASIC interpreter

; THIS ROUTINE IS CALLED TO RESET THE STACK IF BASIC IS
; EXTERNALLY STOPPED AND THEN RESTARTED.

READYR:
  LD BC,RESTART		; 01 1E 41

; Routine at $409D
; This entry point is used by ERROR and BASIC_MAIN routines.
ERESET:
  LD HL,(SAVSTK)	;GET A GOOD STACK BACK
  JP STKERR			;JUMP INTO STKINI

; Routine at 16404
ERRMOR:
  POP BC                ;POP OFF FNDFOR STOPPER
  LD A,E                ;[A]=ERROR NUMBER
  LD C,E                ;ALSO SAVE IT FOR LATER RESTORE
  LD (ERRFLG),A         ;SAVE IT SO WE KNOW WHETHER TO CALL "EDIT"
  LD HL,(SAVTXT)        ;GET SAVED TEXT POINTER
  LD (ERRTXT),HL        ;SAVE FOR RESUME.
  EX DE,HL              ;SAVE SAVTXT PTR
  LD HL,(ERRLIN)        ;GET ERROR LINE #
  LD A,H                ;TEST IF DIRECT LINE
  AND L                 ;SET CC'S
  INC A                 ;SETS ZERO IF DIRECT LINE (65535)
  JR Z,NTMDCN           ;IF DIRECT, DONT MODIFY OLDTXT & OLDLIN
  LD (OLDLIN),HL        ;SET OLDLIN=ERRLIN.
  EX DE,HL              ;GET BACK SAVTXT
  LD (OLDTXT),HL        ;SAVE IN OLDTXT.
NTMDCN:
  LD HL,(ONELIN)
  LD A,H
  OR L
  EX DE,HL
  LD HL,ONEFLG		; =1 if executing an error trap routine
  JR Z,ERROR_REPORT
  AND(HL)
  JR NZ,ERROR_REPORT
  ; We get here if the standard error handling is temporairly disabled (error trap).
  DEC(HL)
  EX DE,HL
  JP GONE4

; Interactive error handling (print error message and break)
; a.k.a. NOTRAP
ERROR_REPORT:
  XOR A
  LD (HL),A
  LD E,C
  CALL CONSOLE_CRLF
  LD HL,ERROR_MESSAGES
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HERRP			; Hook 1 for Error Handler
ENDIF
  LD A,E
  CP $3C
  JR NC,UE_ERR	 	; JP if error code is bigger than $3B
  CP $32
  JR NC,NTDER2 		; JP if error code is between $32 and $3B
  CP $1A
  JR C,LEPSKP   	; JP if error code is < $1A

; a.k.a. UPERR
UE_ERR:
  LD A,$2F		; if error code is bigger than $3B then force it to $2f-$18=$17 ("Unprintable error")

; JP here if error code is between $32 and $3B, sub $18
NTDER2:
  SUB $18		     ; (DSKERR-NONDSK): FIX OFFSET INTO TABLE OF MESSAGES
  LD E,A             ;SAVE BACK ERROR CODE
LEPSKP:
  CALL __REM		; 'Move to next line' (used by ELSE, REM..)
  INC HL
  DEC E
  JR NZ,LEPSKP
  PUSH HL
  LD HL,(ERRLIN)
  EX (SP),HL
  ; --- START PROC _ERROR_REPORT ---
_ERROR_REPORT:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HERRF			; Hook 2 for Error Handler
ENDIF
  PUSH HL
  CALL TOTEXT
  POP HL
  LD A,(HL)            ;GET 1ST CHAR OF ERROR
  CP $3F               ;PADDED ERROR?
  JR NZ,_LEPSKP        ;NO,PRINT
  POP HL               ;GET LINE # OFF STACK
  LD HL,ERROR_MESSAGES
  JR UE_ERR

_LEPSKP:
  LD A,BEL
  RST OUTDO  		; Output char to the current device
  CALL PRS             ;PRINT MESSAGE
  POP HL               ;RESTORE LINE NUMBER
  LD A,H               ;SEE IF IN DIRECT MODE
  AND L
  INC A                ;ZERO SAYS DIRECT MODE
  CALL NZ,IN_PRT       ;PRINT LINE NUMBER IN [H,L]
  DEFB $3E  ; "LD A,n" to Mask the next byte

RESTART:
  POP BC

  ; --- START PROC READY ---
READY:
  CALL TOTEXT               ; Go back in text mode if in graphics mode (e.g. if BREAK was pressed)
  CALL FINLPT
  CALL CLOSE_STREAM
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HREAD				; Hook 1 for Mainloop ("OK")
ENDIF
  CALL CONSOLE_CRLF
  LD HL,OK_MSG				; "Ok" Message
  CALL PRS
  ; --- START PROC L4134 ---
PROMPT:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HMAIN				; Hook 2 for Mainloop
ENDIF
  LD HL,$FFFF
  LD (CURLIN),HL			; Set interpreter in 'DIRECT' (immediate) mode
  LD HL,ENDPRG
  LD (SAVTXT),HL
  LD A,(AUTFLG)		; AUTO mode ?
  OR A
  JR Z,PROMPT_1      ;YES
  LD HL,(AUTLIN)
  PUSH HL
  CALL LINPRT
  POP DE
  PUSH DE
  CALL SRCHLN		; Get first line number
  LD A,'*'          ;CHAR TO PRINT IF LINE ALREADY EXISTS
  JR C,PROMPT_0
  LD A,' '
PROMPT_0:
  RST OUTDO  		; Output char to the current device
  LD (AUTFLG),A		; AUTO mode
PROMPT_1:
  CALL ISFLIO		; Tests if I/O to device is taking place
  JR NZ,INI_STREAM
  CALL PINLIN
  JR NC,INI_LIN
  XOR A
  LD (AUTFLG),A		; Enable AUTO mode
  JP PROMPT

; Accepts a line from a stream
INI_STREAM:
  CALL PINSTREAM
  ; --- START PROC INI_LIN ---
INI_LIN:
  RST CHRGTB		 ; Get first character                  GET THE FIRST
  INC A              ; Test if end of line                  SEE IF 0 SAVING THE CARRY FLAG
  DEC A              ; Without affecting Carry
  JR Z,PROMPT        ; Nothing entered - Get another        IF SO, A BLANK LINE WAS INPUT
  PUSH AF            ; Save Carry status                    SAVE STATUS INDICATOR FOR 1ST CHARACTER
  CALL ATOH		     ; Get line number into DE              READ IN A LINE # specified line number
  JR NC,BAKSP_0      ; BACK UP THE POINTER
  CALL ISFLIO		; Tests if I/O to device is taking place
  JP Z,SN_ERR		; ?SN Err


BAKSP_0:
  CALL BAKSP
  LD A,(AUTFLG)		; AUTO mode ?
  OR A
  JR Z,L4195		; YES
  CP '*'
  JR NZ,L4195
  CP (HL)
  JR NZ,L4195
  INC HL
L4195:
  LD A,D
  OR E
  JR Z,EDENT
  LD A,(HL)
  CP ' '
  JR NZ,EDENT
  INC HL
EDENT:
  PUSH DE                  ;SAVE LINE #
  CALL TOKENIZE            ;CRUNCH THE LINE DOWN ; (CRUNCH)
  POP DE                   ;RESTORE LINE #
  POP AF                   ;WAS THERE A LINE #?
  LD (SAVTXT),HL           ;FOR RESUMING A DIRECT STMT 
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HDIRD				; Hook 3 for Mainloop (direct statement)
ENDIF
  JR C,L41B4
  XOR A
  LD (AUTFLG),A		; Enable AUTO mode
  JP EXEC_FILE

L41B4:
  PUSH DE
  PUSH BC                  ;SAVE LINE # AND CHARACTER COUNT
  RST CHRGTB               ;REMEMBER IF THIS LINE IS
  OR A                     ;SET THE ZERO FLAG ON ZERO      LINES THAT START WITH ":" SHOULD NOT BE IGNORED
  PUSH AF
  LD A,(AUTFLG)            ;IN AN AUTO COMMAND?
  AND A                    ;SET CC'S
  JR Z,AUTGOD              ;Yes
  POP AF
  SCF
  PUSH AF
  
AUTGOD:
  LD (DOT),DE		       ;SAVE THIS LINE # IN DOT (Current line for edit & list)
  LD HL,(AUTINC)	       ;GET INCREMENT
  ADD HL,DE                ;ADD INCREMENT TO THIS LINE
  JR C,AUTRES              ;CHECK FOR PATHETIC CASE
  PUSH DE                  ;SAVE LINE NUMBER #
  LD DE,$FFFA              ;CHECK FOR LINE # TOO BIG
  RST DCOMPR
  POP DE                   ;GET BACK LINE #
  ; --- START PROC L41D2 ---
L41D2:
  LD (AUTLIN),HL           ;SAVE IN NEXT LINE
  JR C,AUTSTR              ;JP if not too big


AUTRES:
  XOR A
  LD (AUTFLG),A			;Enable 'AUTO' mode

AUTSTR:                 ;And enter line
  CALL SRCHLN			; Search for line number in DE: GET A POINTER TO THE LINE
  JR C,LINFND           ; Jump if line found: LINE EXISTS, DELETE IT
  POP AF                ;GET FLAG SAYS WHETHER LINE BLANK
  PUSH AF               ;SAVE BACK
  JR NZ,L41EA
  JP NC,UL_ERR			; TRYING TO DELETE NON-EXISTANT LINE,   Err $08 - "Undefined line number"
  ; --- START PROC L41E7 ---
L41E7:
  PUSH BC
  JR FINI

  ; --- START PROC L41EA ---
L41EA:
  OR A                    ;CLEAR FLAG THAT SAYS LINE EXISTS
  JR LINFND_1

  ; --- START PROC LINFND ---
LINFND:
  POP AF
  PUSH AF
  JR NZ,LINFND_0
  JR C,L41E7
LINFND_0:
  SCF                     ;SET FLAG THAT SAYS LINE EXISTS
  ; --- START PROC LINFND_1 ---
LINFND_1:
  PUSH BC                 ; Save address of line in prog
  PUSH AF                 ;SAVE REGISTERS
  PUSH HL                 ;SAVE [H,L]
  CALL DEPTR              ;GET RID OF PTRS IN PGM
  POP HL                  ;GET BACK POINTER TO NEXT LINE
  POP AF                  ;GET BACK PSW
  POP BC                  ;RESTORE POINTER TO THIS LINE
  PUSH BC                 ;SAVE BACK AGAIN
  CALL C,__DELETE_0       ;DELETE THE LINE
  POP DE                  ;POP POINTER AT PLACE TO INSERT
  POP AF                  ;SEE IF THIS LINE HAD ANYTHING ON IT
  PUSH DE                 ;SAVE PLACE TO START FIXING LINKS
  JR Z,FINI               ;IF NOT DON'T INSERT
  POP DE                  ;GET RID OF START OF LINK FIX
  LD HL,$0000
  LD (ONELIN),HL          ; LINE to go when error
  LD HL,(VARTAB)          ; Get end of program           CURRENT END
  EX (SP),HL              ; Get length of input line     [H,L]=CHARACTER COUNT. VARTAB ONTO THE STACK
  POP BC                  ; End of program to BC         [B,C]=OLD VARTAB
  PUSH HL                 ;SAVE COUNT OF CHARS TO MOVE
  ADD HL,BC               ; Find new end
  PUSH HL                 ; Save new end                 SAVE NEW VARTAB
  CALL MOVUP              ; Make space for line
  POP HL                  ; Restore new end              POP OFF VARTAB
  LD (VARTAB),HL          ; Update end of program pointer
  EX DE,HL                ; Get line to move up in HL
  LD (HL),H               ; Save MSB                     FOOL CHEAD WITH NON-ZERO LINK
  POP BC                  ;                              RESTORE COUNT OF CHARS TO MOVE
  POP DE                  ; Get new line number          GET LINE # OFF STACK
  PUSH HL                 ;           SAVE START OF PLACE TO FIX LINKS SO IT DOESN'T THINK
  INC HL                  ;                 THIS LINK IS THE END OF THE PROGRAM
  INC HL
  LD (HL),E               ; Save LSB of line number      PUT DOWN LINE #
  INC HL                  
  LD (HL),D               ; Save MSB of line number
  INC HL                  ; To first byte in line
  LD DE,KBUF              ; Copy buffer to program       ;MOVE LINE FRM KBUF TO PROGRAM AREA
  DEC BC                                                 ;FIX UP COUNT OF CHARS TO MOVE
  DEC BC                                                 ;(DONT INCLUDE LINE # & LINK)
  DEC BC
  DEC BC

; NOW TRANSFERING LINE IN FROM BUF
MOVBUF:
  LD A,(DE)               ; Get source
  LD (HL),A               ; Save destinations
  INC HL                  ; Next source
  INC DE                  ; Next destination
  DEC BC
  LD A,C
  OR B                    ; Done?
  JR NZ,MOVBUF             ; No - Repeat

  ; --- START PROC FINI ---
FINI:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HFINI			;  Hook 1 for Mainloop finished
ENDIF
  POP DE                ;GET START OF LINK FIXING AREA
  CALL CHEAD            ;FIX LINKS
  LD HL,(PTRFIL)		; Points to file data of currently accessing file
  LD (NXTOPR),HL		; Save I/O pointer before a possible file redirection (RUN "program")
  CALL RUN_FST          ;DO CLEAR & SET UP STACK 
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HFINE			;  Hook 2 for Mainloop finished
ENDIF
  LD HL,(NXTOPR)		; Restore I/O pointer
  LD (PTRFIL),HL
  JP PROMPT

  ; --- START PROC LINKER ---

; Routine at 16979
;
; Used by the routine at CHKSTK.
LINKER:
  LD HL,(TXTTAB)
  EX DE,HL
;
; CHEAD GOES THROUGH PROGRAM STORAGE AND FIXES
; UP ALL THE LINKS. THE END OF EACH
; LINE IS FOUND BY SEARCHING FOR THE ZERO AT THE END.
; THE DOUBLE ZERO LINK IS USED TO DETECT THE END OF THE PROGRAM
;
CHEAD:
  LD H,D                ;[H,L]=[D,E]
  LD L,E                
  LD A,(HL)             ;SEE IF END OF CHAIN
  INC HL                ;BUMP POINTER
  OR (HL)               ;2ND BYTE
  RET Z                 
  INC HL                ;FIX H TO START OF TEXT
  INC HL
CZLOOP:
  INC HL                ;BUMP POINTER
  LD A,(HL)             ;GET BYTE
CZLOO2:
  OR A                  ;SET CC'S
  JR Z,CZLIN            ;END OF LINE, DONE.
  CP ' '                ;EMBEDDED CONSTANT?
  JR NC,CZLOOP          ;NO, GET NEXT
  CP $0A+1              ;IS IT LINEFEED OR BELOW?
  JR C,CZLOOP           ;THEN SKIP PAST
  CALL __CHRCKB		    ;GET CONSTANT
  RST CHRGTB		    ;GET OVER IT
  JR CZLOO2             ;GO BACK FOR MORE
  
CZLIN:
  INC HL                ;MAKE [H,L] POINT AFTER TEXT
  EX DE,HL              ;SWITCH TEMP
  LD (HL),E             ;DO FIRST BYTE OF FIXUP
  INC HL                ;ADVANCE POINTER
  LD (HL),D             ;2ND BYTE OF FIXUP
  JR CHEAD              ;KEEP CHAINING TIL DONE

; Line number range
;
; SCNLIN SCANS A LINE RANGE OF
; THE FORM  #-# OR # OR #- OR -# OR BLANK
; AND THEN FINDS THE FIRST LINE IN THE RANGE
;
; Routine at 17017
; Used by the routines at __LLIST and __DELETE.
LNUM_RANGE:
  LD DE,$0000           ;ASSUME START LIST AT ZERO
  PUSH DE               ;SAVE INITIAL ASSUMPTION
  JR Z,ALL_LIST         ;IF FINISHED, LIST IT ALL
  POP DE                ;WE ARE GOING TO GRAB A #
  CALL LNUM_PARM        ;GET A LINE #. IF NONE, RETURNS ZERO
  PUSH DE               ;SAVE FIRST
  JR Z,SNGLIN           ;IF ONLY # THEN DONE.
  RST SYNCHR 			;   Check syntax: next byte holds the byte to be found
  DEFB TK_MINUS			;MUST BE A DASH.
ALL_LIST:
  LD DE,65530           ;ASSUME MAX END OF RANGE
  CALL NZ,LNUM_PARM     ;GET THE END OF RANGE
  JP NZ,SN_ERR          ;MUST BE TERMINATOR
SNGLIN:
  EX DE,HL              ;[H,L] = FINAL
  POP DE                ;GET INITIAL IN [D,E]

FNDLN1:
  EX (SP),HL            ;PUT MAX ON STACK, RETURN ADDR TO [H,L]
  PUSH HL               ;SAVE RETURN ADDRESS BACK


;
; FNDLIN SEARCHES THE PROGRAM TEXT FOR THE LINE
; WHOSE LINE # IS PASSED IN [D,E]. [D,E] IS PRESERVED.
; THERE ARE THREE POSSIBLE RETURNS:
;
;	1) ZERO FLAG SET. CARRY NOT SET.  LINE NOT FOUND.
;	   NO LINE IN PROGRAM GREATER THAN ONE SOUGHT.
;	   [B,C] POINTS TO TWO ZERO BYTES AT END OF PROGRAM.
;	   [H,L]=[B,C]
;
;	2) ZERO, CARRY SET. 
;	   [B,C] POINTS TO THE LINK FIELD IN THE LINE
;	   WHICH IS THE LINE SEARCHED FOR.
;	   [H,L] POINTS TO THE LINK FIELD IN THE NEXT LINE.
;
;	3) NON-ZERO, CARRY NOT SET.
;	   LINE NOT FOUND, [B,C]  POINTS TO LINE IN PROGRAM
;	   GREATER THAN ONE SEARCHED FOR.
;	   [H,L] POINTS TO THE LINK FIELD IN THE NEXT LINE.
;
;
; (Find line # in DE, BC=line addr, HL=next line addr)
;
; This entry point is used by the routines at GOTO, __DELETE, __RENUM_0, LINE2PTR and
; __RESTORE.
; Get first line number
SRCHLN:
  LD HL,(TXTTAB)	; Start of program text

; This entry point is used by the routine at RUNLIN.
SRCHLP:
  LD B,H            ; BC = Address to look at     IF EXITING BECAUSE OF END OF PROGRAM,
  LD C,L            ;                             SET [B,C] TO POINT TO DOUBLE ZEROES.
  LD A,(HL)         ; Get address of next line
  INC HL            
  OR (HL)           ; End of program found?
  DEC HL            ;GO BACK
  RET Z				; Yes - Line not found
  INC HL            ;SKIP PAST AND GET THE LINE #
  INC HL
  LD A,(HL)			; Get LSB of line number      INTO [H,L] FOR COMPARISON WITH
  INC HL            ;                             THE LINE # BEING SEARCHED FOR
  LD H,(HL)         ; Get MSB of line number      WHICH IS IN [D,E]
  LD L,A
  RST DCOMPR		; Compare with line in DE         SEE IF IT MATCHES OR IF WE'VE GONE TOO FAR
  LD H,B            ; HL = Start of this line         MAKE [H,L] POINT TO THE START OF THE
  LD L,C            ;                                 LINE BEYOND THIS ONE, BY PICKING
  LD A,(HL)         ; Get LSB of next line address    UP THE LINK THAT [B,C] POINTS AT
  INC HL            
  LD H,(HL)         ; Get MSB of next line address
  LD L,A            ; Next line to HL
  CCF
  RET Z             ; Lines found - Exit
  CCF               
  RET NC            ; Line not found,at line after    NO MATCH RETURN (GREATER)
  JR SRCHLP         ; Keep looking


; TOKENIZE (CRUNCH)
; ALL "RESERVED" WORDS ARE TRANSLATED INTO SINGLE ONE OR TWO
; (IF TWO, FIRST IS ALWAYS $FF, 377 OCTAL) BYTES WITH THE MSB ON.
; THIS SAVES SPACE AND TIME BY ALLOWING FOR TABLE DISPATCH DURING EXECUTION.
; THEREFORE ALL STATEMENTS APPEAR TOGETHER IN THE RESERVED WORD LIST 
; IN THE SAME ORDER THEY APPEAR IN IN STMDSP.
;
; NUMERIC CONSTANTS ARE ALSO CONVERTED TO THEIR INTERNAL 
; BINARY REPRESENTATION TO IMPROVE EXECUTION SPEED
; LINE NUMBERS ARE ALSO PRECEEDED BY A SPECIAL TOKEN SO THAT
; LINE NUMBERS CAN BE CONVERTED TO POINTERS AT EXECUTION TIME.
;
; Routine at 17074
TOKENIZE:
  XOR A                    ; SAY EXPECTING FLOATING NUMBERS
  LD (DONUM),A             ; SET FLAG ACORDINGLY
  LD (DORES),A             ; ALLOW CRUNCHING
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HCRUN			; Hook 1 for Tokenise
ENDIF
  LD BC,BUF-BUFFER-5	; BUF-BUFFER-5 = 315 bytes
  LD DE,KBUF            ; SETUP DESTINATION POINTER

; This entry point is used by the routine at TSTNUM.
NXTCHR:                 ; (=KLOOP)
  LD A,(HL)             ; Get byte
  OR A                  ; End of line ?
  JR NZ,CRNCLP          ; No, continue

					
; This entry point is used by the routine at TOKEN_BUILT.
CRDONE:                 ; Yes - Terminate buffer
  LD HL,BUF-BUFFER      ; GET OFFSET: BUF-BUFFER = KBFLEN+2 = 320 bytes
  LD A,L                ;GET COUNT TO SUBTRACT FROM
  SUB C                 ;SUBTRACT
  LD C,A
  LD A,H
  SBC A,B
  LD B,A
  LD HL,BUFFER     ; Point to start of buffer
  ; Mark end of buffer
  XOR A            ;GET A ZERO
  LD (DE),A        ;NEED THREE 0'S ON THE END
  INC DE           ;ONE FOR END-OF-LINE
  LD (DE),A        ;AND 2 FOR A ZERO LINK
  INC DE           ;SINCE IF THIS IS A DIRECT STATEMENT
  LD (DE),A        ;ITS END MUST LOOK LIKE THE END OF A PROGRAM
  RET              ;END OF CRUNCHING

CRNCLP:
  CP '"'            ; Is it a quote?                   QUOTE SIGN? 
  JP Z,CPYLIT       ; Yes - Copy literal string        YES, GO TO SPECIAL STRING HANDLING
  CP ' '            ; Is it a space?                   SPACE?
  JR Z,STUFFH       ; Yes - Copy direct                JUST STUFF AWAY
  LD A,(DORES)		; a.k.a. OPRTYP, indicates whether stored word can be crunched, etc..
  OR A              ; crunched, etc..                  END OF LINE?
  LD A,(HL)
  JR Z,CRNCLP_2     ;                                  YES, DONE CRUNCHING

; This entry point is used by the routines at TSTNUM and NTSNGT.
STUFFH:
  INC HL                ; ENTRY TO BUMP [H,L]
  PUSH AF               ; SAVE CHAR AS KRNSAV CLOBBERS
  CP $01
  JR NZ,TOKENIZE_4
  LD A,(HL)
  AND A
  LD A,$01              ;SET LINE NUMBER ALLOWED FLAG - KLUDGE AS HAS TO BE NON-ZERO.
TOKENIZE_4:
  CALL NZ,KRNSAV        ; Insert during tokenization           SAVE CHAR IN KRUNCH BUFFER
  POP AF                ; RESTORE CHAR
  SUB ':'			    ; ":", End of statement?
  JR Z,SETLIT           ; IF SO ALLOW CRUNCHING AGAIN
  CP TK_DATA-':'        ; SEE IF IT IS A DATA TOKEN
  JR NZ,TSTREM          ; No - see if REM
  LD A,$01              ;SET LINE NUMBER ALLOWED FLAG - KLUDGE AS HAS TO BE NON-ZERO.
SETLIT:
  LD (DORES),A		    ;SETUP FLAG
  LD (DONUM),A          ;SET NUMBER ALLOWED FLAG
TSTREM:
  SUB TK_REM-':'
  JR NZ,NXTCHR          ;KEEP LOOPING
  PUSH AF               ;SAVE TERMINATOR ON STACK
STR1_LP:
  LD A,(HL)             ;GET A CHAR
  OR A                  ;SET CONDITION CODES
  EX (SP),HL            ;GET SAVED TERMINATOR OFF STACK, SAVE [H,L]
  LD A,H                ;GET TERMINATOR INTO [A] WITHOUT AFFECTING PSW
  POP HL                ;RESTORE [H,L]
  JR Z,CRDONE           ;IF END OF LINE THEN DONE
  CP (HL)               ;COMPARE CHAR WITH THIS TERMINATOR
  JR Z,STUFFH           ;IF YES, DONE WITH STRING

CPYLIT:
  PUSH AF               ;SAVE TERMINATOR
  LD A,(HL)             ;GET BACK LINE CHAR
; This entry point is used by the routine at TOKEN_BUILT.
TOKENIZE_9:
  INC HL                ;INCREMENT TEXT POINTER
  CP $01
  JR NZ,TOKENIZE_10
  LD A,(HL)             ;GET BACK LINE CHAR
  AND A
  LD A,$01
TOKENIZE_10:
  CALL NZ,KRNSAV        ;SAVE CHAR IN KRUNCH BUFFER
  JR STR1_LP            ;KEEP LOOPING

CRNCLP_2:
  INC HL
  OR A
  JP M,NXTCHR
  CP $01
  JR NZ,TOKENIZE_12
  LD A,(HL)             ;GET A CHAR
  AND A                 ;SET CONDITION CODES
  JR Z,CRDONE           ;IF END OF LINE THEN DONE
  INC HL                ;INCREMENT TEXT POINTER
  JR NXTCHR

TOKENIZE_12:
  DEC HL
  CP '?'                ; Is it "?" short for PRINT
  LD A,TK_PRINT         ; TK_PRINT: "PRINT" token
  PUSH DE               ;SAVE STORE POINTER
  PUSH BC               ;SAVE CHAR COUNT
  JP Z,MOVDIR           ;THEN USE A "PRINT" TOKEN
  LD A,(HL)
  CP '_'		; $5F
  JP Z,MOVDIR           ; ... leave '_' unchanged ?
					;***5.11 DONT ALLOW FOLLOWING LINE #***
  LD DE,OPR_TOKENS      ;ASSUME WE'LL SEARCH SPECIAL CHAR TABLE
  CALL MAKUPL           ;MAKE UPPER CASE (?)
  CALL ISLETTER_A       ;IS IT A LETTER?
  JP C,TSTNUM           ;NOT A LETTER, TEST FOR NUMBER
  PUSH HL               ;SAVE TEXT POINTER
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HCRUS			; Hook 2 for Tokenise
ENDIF

  LD HL,WORD_PTR      ;GET POINTER TO ALPHA DISPATCH TABLE

; On Spectravideo SVI this entry is tracked in the initial JP table (LBCA:) to facilitate the HOOK insertion

  SUB 'A'             ;SUBTRACT ALPHA OFFSET
  ADD A,A             ;MULTIPLY BY TWO
  LD C,A              ;SAVE OFFSET IN [C] FOR DAD.
  LD B,$00            ;MAKE HIGH PART OF OFFSET ZERO
  ADD HL,BC           ;ADD TO TABLE ADDRESS
  LD E,(HL)           ;SET UP POINTER IN [D,E]
  INC HL
  LD D,(HL)           ;GET HIGH PART OF ADDRESS
  POP HL              ;GET BACK SOURCE POINTER
  INC HL              ;POINT TO CHAR AFTER FIRST ALPHA  (Get next reserved word)

TRYAGA:
  PUSH HL             ;SAVE TXTPTR TO START OF SEARCH AREA
LOPPSI:
  CALL MAKUPL         ;TRANSLATE THIS CHAR TO UPPER CASE
  LD C,A              ;SAVE CHAR IN [C]
  LD A,(DE)           ;GET BYTE FROM RESERVED WORD LIST   (Get byte from table)
  AND $7F             ;GET RID OF HIGH BIT
  JP Z,NOTRES         ;IF=0 THEN END OF THIS CHARS RESLT  (JP if end of list)
  INC HL              ;BUMP SOURCE POINTER
  CP C                ;COMPARE TO CHAR FROM SOURCE LINE     (Same character as in buffer?)
  JR NZ,LOPSKP        ;IF NO MATCH, SEARCH FOR NEXT RESWRD  (No - get next word)
  LD A,(DE)           ;GET RESWRD BYTE AGAIN
  INC DE              ;BUMP RESLST POINTER
  OR A                ;SET CC'S
  JP P,LOPPSI         ;SEE IF REST OF CHARS MATCH
  POP AF              ;GET RID OF SAVED [H,L]
  LD A,(DE)           ;GET RESWRD VALUE
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HISRE				; Hook 3 for Tokenise
ENDIF
  OR A
  JP M,TOKENIZE_17
  POP BC
  POP DE
  OR $80             ;MAKE HIGH ORDER BIT ONE
  PUSH AF            ;SAVE FN CHAR
  LD A,$FF           ;GET BYTE WHICH PRECEEDS FNS
  CALL KRNSAV        ;SAVE IN KRUNCH BUFFER
  XOR A              ;MAKE A ZERO
  LD (DONUM),A       ;TO RESET DONUM (FLOATINGS ALLOWED)
  POP AF             ;GET FUNCTION TOKEN
  CALL KRNSAV        ;STORE IT
  JP NXTCHR          ;KEEP KRUNCHING

LOPSKP:
  POP HL             ;RESTORE UNDEFILED TEXT POINTER
LOPSK2:
  LD A,(DE)          ;GET A BYTE FROM RESWRD LIST
  INC DE             ;BUMP RESLST POINTER
  OR A               ;SET CC'S
  JP P,LOPSK2        ;NOT END OF RESWRD, KEEP SKIPPING
  INC DE             ;POINT AFTER TOKEN
  JR TRYAGA          ;TRY ANOTHER RESWRD

TOKENIZE_17:
  DEC HL
MOVDIR:
  PUSH AF
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HNTFN			; Hook 4 for Tokenise
ENDIF
  LD DE,LNUM_TOKENS		; List of commands (tokens) requiring program line numbers
  LD C,A
MOVDIR_0:
  LD A,(DE)
  OR A
  JR Z,TOKEN_BUILT
  INC DE
  CP C
  JR NZ,MOVDIR_0
  JR TOKENIZE_LNUM

; Routine at 17333
; List of commands (tokens) requiring program line numbers
LNUM_TOKENS:
  DEFB TK_RESTORE
  DEFB TK_AUTO
  DEFB TK_RENUM
  DEFB TK_DELETE
  DEFB TK_RESUME
  DEFB TK_ERL
  DEFB TK_ELSE
  DEFB TK_RUN
  DEFB TK_LIST
  DEFB TK_LLIST
  DEFB TK_GOTO
  DEFB TK_RETURN		; !
  DEFB TK_THEN
  DEFB TK_GOSUB
  DEFB $00

; This entry point is used by the routine at TOKENIZE.
TOKEN_BUILT:
  XOR A
  defb $C2	; JP NZ,NN (always false), masks the next 2 bytes
TOKENIZE_LNUM:
  LD A,1

TOKEN_BUILT_1:
  LD (DONUM),A
  POP AF

RETNAD:
  POP BC                   ;GET BACK CHAR COUNT
  POP DE                   ;GET BACK DEPOSIT POINTER
  CP TK_ELSE               ;HAVE TO PUT A HIDDEN COLON IN FRONT OF "ELSE"S
  PUSH AF                  ;SAVE CURRENT CHAR ($ELSE)
  CALL Z,TOKENIZE_COLON    ;SAVE ":" IN CRUNCH BUFFER
  POP AF
  CP TK_CALL	; $CA
  JR Z,TOKEN_BUILT_3
  CP '_'		; $5F
  JR NZ,TOKEN_BUILT_7
TOKEN_BUILT_3:
  CALL NC,KRNSAV		; Insert during tokenization
TOKEN_BUILT_4:
  INC HL
  CALL MAKUPL		; Load A with char in 'HL' and make it uppercase
  AND A
TOKEN_BUILT_5:
  JP Z,CRDONE
  JP M,TOKEN_BUILT_4
  CP $01
  JR NZ,TOKEN_BUILT_6
  INC HL
  LD A,(HL)
  AND A
  JR Z,TOKEN_BUILT_5
  JR TOKEN_BUILT_4

TOKEN_BUILT_6:
  CP ' '
  JR Z,TOKEN_BUILT_3
  CP ':'
  JR Z,TSTNUM_1
  CP '('
  JR Z,TSTNUM_1
  CP '0'
  JR TOKEN_BUILT_3

TOKEN_BUILT_7:
  CP TK_APOSTROPHE        ;SINGLE QUOTE TOKEN?   "'" = comment (=REM)
  JP NZ,NTSNGT
  PUSH AF
  CALL TOKENIZE_COLON     ;SAVE ":" IN CRUNCH BUFFER
  LD A,TK_REM             ;STORE ":$REM" IN FRONT FOR EXECUTION
  CALL KRNSAV             ;SAVE IT
  POP AF                  ;GET SNGQTK (TK_APOSTROPHE) BACK
  PUSH HL                 ;SAVE BACK AS TERMINATOR FOR STRNG
  LD HL,$0000             ;STUFF THE REST OF THE LINE WITHOUT CRUNCHING
  EX (SP),HL
  JP TOKENIZE_9

; Routine at 17437
;
; Used by the routine at TOKENIZE.
TSTNUM:
  LD A,(HL)               ;GET CHAR
  CP '.'                  ;TEST FOR START OF FLOATING #
  JR Z,NUMTRY             ;TRY INPUTTING IT AS CONSTANT
  CP '9'+1                ;IS IT A DIGIT?
  JP NC,SRCSPC            ;NO, TRY OTHER THINGS
  CP '0'                  ;TRY LOWER END
  JP C,SRCSPC             ;NO TRY OTHER POSSIBILITIES
NUMTRY:
  LD A,(DONUM)            ;TEST FOR NUMBERS ALLOWED
  OR A                    ;SET CC'S
  LD A,(HL)               ;GET CHAR IF GOING TO STUFFH
  POP BC                  ;RESTORE CHAR COUNT
  POP DE                  ;RESTORE DEP. POINTER
  JP M,STUFFH             ;NO, JUST STUFF IT (!)
  JR Z,FLTGET             ;IF DONUM=0 THEN FLOATING #'S ALLOWED
  CP '.'                  ;IS IT DOT?

; This entry point is used by the routine at TOKEN_BUILT.
TSTNUM_1:
  JP Z,STUFFH             ;YES, STUFF IT FOR HEAVENS SAKE! (EDIT .)
  LD A,LINCON             ;GET LINE # TOKEN
  CALL KRNSAV             ;SAVE IT
  PUSH DE                 ;SAVE DEPOSIT POINTER
  CALL ATOH               ;GET THE LINE #.
  CALL BAKSP              ;BACK UP POINTER TO AFTER LAST DIGIT

SAVINT:
  EX (SP),HL              ;EXCHANGE CURRENT [H,L] WITH SAVED [D,E]
  EX DE,HL                ;GET SAVED [D,E] IN [D,E]
TSTNUM_3:                 
  LD A,L                  ;GET LOW BYTE OF VALUE RETURNED BY LINGET
  CALL KRNSAV             ;SAVE THE LOW BYTE OF LINE #
  LD A,H                  ;GET HIGH BYTE
POPSTF:
  POP HL                  ;RESTORE [H,L]
  CALL KRNSAV             ;SAVE IT TOO
  JP NXTCHR               ;EAT SOME MORE

FLTGET:
  PUSH DE                 ;SAVE DEPOSIT POINTER
  PUSH BC                 ;SAVE CHAR COUNT
  LD A,(HL)               ;FIN ASSUMES CHAR IN [A]
  CALL FIN_DBL            ;READ THE #
  CALL BAKSP              ;BACK UP POINTER TO AFTER LAST DIGIT
  POP BC                  ;RESTORE CHAR COUNT
  POP DE                  ;RESTORE DEPOSIT POINTER
  PUSH HL                 ;SAVE TEXT POINTER
  LD A,(VALTYP)           ;GET VALUE TYPE
  CP $02                  ;INTEGER?
  JR NZ,NTINTG            ;NO
  LD HL,(FACLOW)          ;GET IT
  LD A,H                  ;GET HIGH PART
  OR A                    ;IS IT ZERO?
  LD A,$02                ;RESTORE INT VALTYP
  JR NZ,NTINTG            ;THEN ISNT SINGLE BYTE INT
  LD A,L                  ;GET LOW BYTE
  LD H,L                  ;GET LOW BYTE IN HIGH BYTE TO STORE
  LD L,$0F                ;GET CONSTANT FOR 1 BYTE INTS
  CP $0A                  ;IS IT TOO BIG FOR A SINGLE BYTE CONSTANT?
  JR NC,TSTNUM_3          ;TOO BIG, USE SINGLE BYTE INT
  ADD A,ONECON            ;MAKE SINGLE BYTE CONSTANT
  JR POPSTF               ;POP H & STUFF AWAY CHAR

NTINTG:
  PUSH AF                 ;SAVE FOR LATER
  RRCA                    ;DIVIDE BY TWO
  ADD A,$1B               ;ADD OFFSET TO GET TOKEN
  CALL KRNSAV             ;SAVE THE TOKEN
  LD HL,FACCU             ;GET START POINTER
  LD A,(VALTYP)
  CP $02
  JR NZ,TSTNUM_7
  LD HL,FACLOW
TSTNUM_7:
  POP AF                  ;RESTORE COUNT OF BYTES TO MOVE
TSTNUM_8:
  PUSH AF                 ;SAVE BYTE MOVE COUNT
  LD A,(HL)               ;GET A BYTE
  CALL KRNSAV             ;SAVE IT IN KRUNCH BUFFER
  POP AF                  ;GET BACK COUNT
  INC HL                  ;BUMP POINTER INTO FAC
  DEC A                   ;MOVE IT DOWN
  JR NZ,TSTNUM_8          ;KEEP MOVING IT
  POP HL                  ;GET BACK SAVED TEXT POINTER
  JP NXTCHR               ;KEEP LOOPING

SRCSPC:
  LD DE,OPR_TOKENS-1     ; GET POINTER TO SPECIAL CHARACTER TABLE
SRCSP2:                  
  INC DE                 ; MOVE POINTER AHEAD
  LD A,(DE)              ; GET BYTE FROM TABLE
  AND $7F                ; MASK OFF HIGH BIT
  JP Z,L44FA             ; IF END OF TABLE, STUFF AWAY, DONT CHANGE DONUM
  INC DE                 ; BUMP POINTER
  CP (HL)                ; IS THIS SPECIAL CHAR SAME AS CURRENT TEXT CHAR?
  LD A,(DE)              ; GET NEXT RESWRD
  JR NZ,SRCSP2           ; IF NO MATCH, KEEP LOOKING
  JP NOTRS1              ; FOUND, SAVE AWAY AND SET DONUM=1.

; Routine at 17588
;
; Used by the routine at TOKEN_BUILT.
NTSNGT:
  CP '&'		    ; OCTAL CONSTANT?
  JP NZ,STUFFH     ; JUST STUFF IT AWAY
  PUSH HL           ; SAVE TEXT POINTER
  RST CHRGTB		; GET NEXT CHAR
  POP HL            ; RESTORE TEXT POINTER
  CALL UCASE        ; MAKE CHAR UPPER CASE
  CP 'H'		    ; '&H' HEX CONSTANT?
  JR Z,NTSNGT_1
  CP 'O'		    ; &O ..octal prefix
  JR Z,NTSNGT_0
  LD A,'&'          ; $26
  JP STUFFH

NTSNGT_0:
  LD A,$0B          ; Octal Number prefix
  JR WUZOCT

NTSNGT_1:
  LD A,$0C          ; Hex Number prefix
WUZOCT:
  CALL KRNSAV		; Insert during tokenization
  PUSH DE
  PUSH BC
  CALL OCTCNS
  POP BC
  JP SAVINT

; Routine at 17630
;
; Used by the routine at TOKEN_BUILT.
TOKENIZE_COLON:
  LD A,':'             ; GET COLON IN KRUNCH BUFFER
; This entry point is used by the routines at TOKENIZE, TOKEN_BUILT, TSTNUM and NTSNGT.

; Insert during tokenization
KRNSAV:
  LD (DE),A            ; SAVE BYTE IN KRUNCH BUFFER
  INC DE               ; BUMP POINTER
  DEC BC               ; DECREMENT COUNT OF BYTES LEFT IN BUFFER
  LD A,C               ; TEST IF IT WENT TO ZERO
  OR B                 ; BY SEEING IF DOUBLE BYTE ZERO.
  RET NZ               ; ALL DONE IF STILL SPACE LEFT
  
  LD E,$19             ; Err $19 - "Line buffer overflow"
  JP ERROR

; Routine at 17643
;
; Used by the routine at TOKENIZE.
NOTRES:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HNOTR			; Hook 5 for Tokenise
ENDIF
  POP HL                ;GET BACK POINTER TO ORIGINAL CHAR
  DEC HL                ;NOW POINT TO FIRST ALPHA CHAR
  DEC A                 ;SET A TO MINUS ONE
  LD (DONUM),A          ;FLAG WERE IN VARIABLE NAME
  CALL MAKUPL           ;GET CHAR FROM LINE, MAKE UPPER CASE
  JP RETNAD           ;..continue

; Routine at 17658
;
; Used by the routine at TSTNUM.
L44FA:
  LD A,(HL)
  CP ' '
  JR NC,NOTRS1
  CP $09	; TAB
  JR Z,NOTRS1
  CP LF
  JR Z,NOTRS1
  LD A,' '
; This entry point is used by the routine at TSTNUM.
NOTRS1:
  PUSH AF
  LD A,(DONUM)
  INC A
  JR Z,L44FA_1
  DEC A
L44FA_1:
  JP TOKEN_BUILT_1


; ROUTINE TO BACK UP POINTER AFTER # EATEN
; Routine at 17684
;
; Used by the routine at TSTNUM.
BAKSP:
  DEC HL                ;POINT TO PREVIOUS CHAR
  LD A,(HL)             ;GET THE CHAR
  CP ' '                ;A SPACE?
  JR Z,BAKSP            ;YES, KEEP BACKING UP
  CP $09                ;TAB?
  JR Z,BAKSP            ;YES, BACK UP
  CP LF                 ;LF?
  JR Z,BAKSP
  INC HL                ;POINT TO CHAR AFTER LAST NON-SPACE
  RET                   ;ALL DONE.


; 'FOR' BASIC command
;
; A "FOR" ENTRY ON THE STACK HAS THE FOLLOWING FORMAT:
;
; LOW ADDRESS
;	TOKEN ($FOR IN HIGH BYTE)  1 BYTE
;	A POINTER TO THE LOOP VARIABLE  2 BYTES
;	A BYTE REFLECTING THE SIGN OF THE INCREMENT 1 BYTE
;	THE STEP 4 BYTES
;	THE UPPER VALUE 4 BYTES
;	THE LINE # OF THE "FOR" STATEMENT 2 BYTES
;	A TEXT POINTER INTO THE "FOR" STATEMENT 2 BYTES
;
; Data block at 17700
__FOR:
  LD A,$64				; Flag "FOR" assignment
  LD (SUBFLG),A			; Save "FOR" flag                    DONT RECOGNIZE SUBSCRIPTED VARIABLES
  CALL __LET            ; Set up initial index               GET POINTER TO LOOP VARIABLE
  POP BC                ; Drop RETurn address                GET RID OF THE NEWSTT RETURN
  PUSH HL               ; Save code string address           SAVE THE TEXT POINTER
  CALL __DATA           ; Get next statement address         SET [H,L]=END OF STATEMENT
  LD (ENDFOR),HL		; Next address of FOR st.	         SAVE FOR COMPARISON
  LD HL,2               ; Offset for "FOR" block             SET UP POINTER INTO STACK
  ADD HL,SP             ; Point to it
FORSLP:
  CALL LOKFOR           ; Look for existing "FOR" block      MUST HAVE VARIABLE POINTER IN [D,E]
  JR NZ,FORFND          ; IF NO MATCHING ENTRY, DON'T ELIMINATE ANYTHING
  ADD HL,BC             ; IN THE CASE OF "FOR" WE ELIMINATE THE MATCHING ENTRY AS WELL AS EVERYTHING AFTER IT
  PUSH DE               ; SAVE THE TEXT POINTER
  DEC HL                ; SEE IF END TEXT POINTER OF MATCHING ENTRY
  LD D,(HL)             ; MATCHES THE FOR WE ARE HANDLING
  DEC HL                ; PICK UP THE END OF THE "FOR" TEXT POINTER
  LD E,(HL)             ; FOR THE ENTRY ON THE STACK
  INC HL                ; WITHOUT CHANGING [H,L]
  INC HL
  PUSH HL               ; Save block address                 SAVE THE STACK POINTER FOR THE COMPARISON
  LD HL,(ENDFOR)		; Get address of loop statement      GET ENDING TEXT POINTER FOR THIS "FOR"
  RST DCOMPR			; Compare the FOR loops              SEE IF THEY MATCH
  POP HL                ; Restore block address              GET BACK THE STACK POINTER
  POP DE                ;                                    GET BACK THE TEXT POINTER
  JR NZ,FORSLP          ; Different FORs - Find another      KEEP SEARCHING IF NO MATCH
  POP DE                ; Restore code string address        GET BACK THE TEXT POINTER
  LD SP,HL              ; Remove all nested loops            DO THE ELIMINATION
  LD (SAVSTK),HL        ; UPDATE SAVED STACK SINCE A MATCHING ENTRY WAS FOUND
  
  DEFB $0E              ; LD C,N to mask the next byte

FORFND:
  POP DE                ; Code string address to DE
  EX DE,HL              ; [H,L]=TEXT POINTER
  LD C,12               ; MAKE SURE 24 BYTES ARE AVAILABLE OFF OF THE STACK
  CALL CHKSTK           ; Check for 12 levels of stack
  PUSH HL               ; REALLY SAVE THE TEXT POINTER
  LD HL,(ENDFOR)        ; Get first statement of loop        PICK UP POINTER AT END OF "FOR" 
                        ;                                    JUST BEYOND THE TERMINATOR
  EX (SP),HL            ; Save and restore code string       PUT [H,L] POINTER TO TERMINATOR ON THE STACK
                        ;                                    AND RESTORE [H,L] AS TEXT POINTER AT VARIABLE NAME
  PUSH HL               ; Re-save code string address        PUSH THE TEXT POINTER ONTO THE STACK
  LD HL,(CURLIN)		; Get current line number            [H,L] GET THE CURRENT LINE #
  EX (SP),HL            ; Save and restore code string       NOW THE CURRENT LINE # IS ON THE STACK, HL IS THE TEXT POINTER
  RST SYNCHR 			; Make sure "TO" is next
  DEFB TK_TO			; TK_TO: "TO" token                  "TO" IS NECESSARY
  RST GETYPR 			; Get the number type (FAC)          SEE WHAT TYPE THIS VALUE HAS
  JP Z,TM_ERR			; If string type, "Type mismatch"    GIVE STRINGS A "TYPE MISMATCH"
  PUSH AF               ; save type                          SAVE THE INTEGER/FLOATING FLAG
  CALL EVAL             ;                                    EVALUATE THE TARGET VALUE FORMULA
  POP AF                ; Restore type                       POP OFF THE FLAG
  PUSH HL               ; SAVE THE TEXT POINTER
  JR NC,FORFND_DBL      ; Deal with DOUBLE-PRECISION
  JP P,FORFND_SNG       ; POSITIVE MEANS SINGLE PRECISION "FOR"-LOOP
  CALL __CINT           ; COERCE THE FINAL VALUE
  EX (SP),HL            ; SAVE IT ON THE STACK AND REGET THE TEXT POINTER

  LD DE,$0001			; Default value for STEP               DEFAULT THE STEP TO BE 1
  LD A,(HL)             ; Get next byte in code string         SEE WHAT CHARACTER IS NEXT
  CP TK_STEP			; See if "STEP" is stated              IS THERE A "STEP" CLAUSE?
  CALL Z,FPSINT         ; If so, get updated value for 'STEP'  IF SO, READ THE STEP INTO [D,E]
  PUSH DE               ;                                      PUT THE STEP ONTO THE STACK
  PUSH HL               ;                                      SAVE THE TEXT POINTER
  EX DE,HL              ;                                      STEP INTO [H,L]
  CALL ISIGN            ; Test sign for 'STEP'                 THE SIGN OF THE STEP INTO [A]
  JR FORFND_1           ;                                      FINISH UP THE ENTRY BY PUTTING THE SIGN OF
                        ;                                      THE STEP AND THE DUMMY ENTRIES ON THE STACK
  
FORFND_DBL:
  CALL __CDBL	        ; Get value for 'TO'
  POP DE	
  LD HL,$FFF8			; -8
  ADD HL,SP	
  LD SP,HL	
  PUSH DE	
  CALL VMOVMF	
  POP HL	
  LD A,(HL)	
  CP TK_STEP			; 'STEP'
  LD DE,FP_UNITY	    ; 1
  LD A,1				; Default STEP value
  JR NZ,SAVSTP			; No STEP given - Default to 1
  RST CHRGTB			; Jump over "STEP" token and point to step value
  CALL EVAL	
  PUSH HL	
  CALL __CDBL
  CALL SIGN			; test FP number sign
  LD DE,FACCU
  POP HL
  
SAVSTP:
  LD B,H
  LD C,L
  LD HL,$FFF8		; -8
  ADD HL,SP
  LD SP,HL
  PUSH AF
  PUSH BC
  CALL VMOVE
  POP HL
  POP AF
  JR FORFND_3

FORFND_SNG:
  CALL __CSNG       ; Get value for 'TO'
  CALL BCDEFP       ; Move "TO" value to BCDE
  POP HL            ; Restore code string address
  PUSH BC           ; Save "TO" value in block
  PUSH DE           ; SAVE THE SIGN OF THE INCREMENT
  LD BC,$1041		; BCDE = 1.0 float (default value for STEP)
  LD DE,$0000

IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HSNGF			; Hook for 'FOR'
ENDIF

  LD A,(HL)             ; Get next byte in code string          GET TERMINATING CHARACTER
  CP TK_STEP			; See if "STEP" is stated
  LD A,$01              ; Sign of step = 1
  JR NZ,SAVSTP_2		; No STEP given - Default to 1
  CALL EVAL_0           ; Jump over "STEP" token and point to step value
  PUSH HL               ; Save code string address
  CALL __CSNG           ; Get value for 'STEP'
  CALL BCDEFP           ; Move STEP to BCDE
  CALL SIGN             ; Test sign for 'STEP' in FPREG

FORFND_1:
  POP HL                ; Restore code string address

SAVSTP_2:
  PUSH DE               ; Save the STEP value in block
  PUSH BC
  PUSH BC
  PUSH BC
  PUSH BC
  PUSH BC

FORFND_3:
  OR A
  JR NZ,FORFND_4
  LD A,$02
FORFND_4:
  LD C,A                ;[C]=SIGN OF STEP
  RST GETYPR            ;MUST PUT ON INTEGER/SINGLE-PRECISION FLAG - MINUS IS SET FOR INTEGER CASE
  LD B,A                ;HIGH BYTE = INTEGER/SINGLE PRECISION FLAG
  PUSH BC               ;SAVE FLAG AND SIGN OF STEP BOTH
  PUSH HL               ; Save code string address
  LD HL,(TEMP)          ; Get address of index variable       ;GET THE POINTER TO THE VARIABLE BACK
  EX (SP),HL            ; Save and restore code string        ;PUT THE PTR ON SP AND RESTORE THE TEXT POINTER
; --- Put "FOR" block marker ---
PUTFID:
  LD B,TK_FOR           ; "FOR" block marker                  ;FINISH UP "FOR"
  PUSH BC               ; Save it
  INC SP                ; Don't save C                        ;THE "TOKEN" ONLY TAKES ONE BYTE OF STACK SPACE
;	JMP	NEWSTT		;ALL DONE

;
; BASIC program execution driver (a.k.a. RUNCNT).  HL points to code.
;
; BACK HERE FOR NEW STATEMENT. CHARACTER POINTED TO BY [H,L]
; ":" OR END-OF-LINE. THE ADDRESS OF THIS LOCATION IS
; LEFT ON THE STACK WHEN A STATEMENT IS EXECUTED SO
; IT CAN MERELY DO A RETURN WHEN IT IS DONE.
;
NEWSTT: 
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HNEWS				; Hook for runloop new statement event
ENDIF
  LD (SAVSTK),SP
  CALL ISCNTC			; Check STOP key status
  LD A,(ONGSBF)
  OR A                  ;
  CALL NZ,EXEC_ONGOSUB
NEWSTT_0:
  EI
  LD (SAVTXT),HL		; Save code address for break TO REMEMBER HOW TO RESTART THIS STATEMENT
  LD A,(HL)             ; GET CURRENT CHARACTER WHICH TERMINATED THE LAST STATEMENT
  CP ':'                ; Multi statement line?
  JR Z,EXEC             ; Yes - Execute it
  OR A                  ; End of line?
  JP NZ,SN_ERR          ; No - Syntax error               ;MUST BE A ZERO
  INC HL                ; Point to address of next line

;$4620
GONE4:                  ;CHECK POINTER TO SEE IF IT IS ZERO, IF SO WE ARE AT THE END OF THE PROGRAM
  LD A,(HL)				; Get LSB of line pointer
  INC HL
  OR (HL)               ; Is it zero (End of prog)?
  JP Z,PRG_END          ; Yes - Terminate execution        ;FIX SYNTAX ERROR IN UNENDED ERROR ROUTINE
  INC HL                ; Point to line number
  LD E,(HL)             ; Get LSB of line number
  INC HL
  LD D,(HL)             ; Get MSB of line number           ;GET LINE # IN [D,E]
  EX DE,HL              ; Line number to HL                ;[H,L]=LINE #
  LD (CURLIN),HL        ; Save as current line number      ;SETUP CURLIN WITH THE CURRENT LINE #
  LD A,(TRCFLG)			; SEE IF TRACE IS ON (0 MEANS NO TRACE)
  OR A                  ; NON-ZERO MEANS YES
  JR Z,NEWSTT_2         ; SKIP THIS PRINTING

  ; If "TRACE" is ON, then print current line number between brackets
  ; [0000] <<<-- print line number being executed
  PUSH DE               ;SAVE THE TEXT POINTER
  LD A,'['              ;FORMAT THE LINE NUMBER
  RST OUTDO             ;OUTPUT IT
  CALL LINPRT           ;PRINT THE LINE # IN [H,L]
  LD A,']'              ;SOME MORE FORMATING
  RST OUTDO             
  POP DE                ;[D,E]=TEXT POINTER

;$463F
NEWSTT_2:
  EX DE,HL				;RESTORE THE TEXT POINTER, Line number back to DE
  
;$4640
EXEC:
  RST CHRGTB		; Get key word                         ;GET THE STATEMENT TYPE
  LD DE,NEWSTT      ; Where to RETurn to                   ;PUSH ON A RETURN ADDRESS OF NEWSTT
  PUSH DE           ; Save for RETurn                      ;STATEMENT
  RET Z             ; Go to NEWSTT if end of STMT          ;IF A TERMINATOR TRY AGAIN


;"IF" COMES HERE, "ON ... GOTO" AND "ON ... GOSUB" COME HERE
; This entry point is used by the routines at __ON and __IF.
ONJMP:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HGONE			; Hook 1 in runloop execute event
ENDIF
  CP '_'			; $5F
  JP Z,CALL_SHCUT
  SUB TK_END                 ; $81 = TK_END .. is it a token?
  JP C,__LET                 ; No - try to assign it, MUST BE A LET
  CP TK_LOCATE+1-TK_END      ; END to LOCATE ?
  JP NC,NOT_KEYWORD          ; Not a key word - ?SN Error

  ; We're in the token range between TK_END and TK_LOCATE
  RLCA
  LD C,A
  LD B,$00
  EX DE,HL          ; Save code string address
  LD HL,FNCTAB	 	; Function routine addresses     ;a.k.a. STMDSP: STATEMENT DISPATCH TABLE
  ADD HL,BC         ; Point to right address         ;ADD ON OFFSET 
  LD C,(HL)         ; Get LSB of address             ;PUSH THE ADDRESS TO GO TO ONTO
  INC HL                                             ;THE STACK
  LD B,(HL)         ; Get MSB of address             ;PUSHM SAVES BYTES BUT NOT SPEED
  PUSH BC                                            
  EX DE,HL                                           ;RESTORE THE TEXT POINTER

  ; --- START PROC L4666 ---
;
; NEWSTT FALLS INTO CHRGET. THIS FETCHES THE FIRST CHAR AFTER
; THE STATEMENT TOKEN AND THE CHRGET'S "RET" DISPATCHES TO STATEMENT
;
__CHRGTB:               ; DUPLICATION OF CHRGET RST FOR SPEED
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HCNRG		; Hook for CHRGTR std routine
ENDIF
  INC HL                ; Point to next character         ;LOOK AT NEXT CHAR
  ; --- START PROC __CHRCKB ---
  ; Gets current character (or token) from BASIC text.
__CHRCKB:
  LD A,(HL)             ; Get next code string byte       ;SEE CHRGET RST FOR EXPLANATION
  CP ':'                ; Z if ":"                        ;IS IT END OF STATMENT OR BIGGER
  RET NC                ; NC if > "9"

;
; CHRCON IS THE CONTINUATION OF THE CHRGET RST
;
; IN EXTENDED, CHECK FOR INLINE CONSTANT AND IF ONE
; MOVE IT INTO THE FAC & SET VALTYP APPROPRIATELY
;
  CP ' '                ;                               MUST SKIP SPACES
  JR Z,__CHRGTB         ; Skip over spaces              GET ANOTHER CHARACTER
  JR NC,NOTLFT          ; NC if < "0"                   NOT SPECIAL TRY OTHER POSSIB.
  OR A                  ; Test for zero - Leave carry
  RET Z
  CP OCTCON             ;IS IT INLINE CONSTANT ?
  JR C,NOTCON           ;NO, SHOULD BE TAB OR LF
  CP CONCON             ;ARE WE TRYING TO RE-SCAN A CONSTANT?
  JR NZ,NTRSCC          ;NO.
  LD A,(CONSAV)         ;GET THE SAVED CONSTANT TOKEN
  OR A                  ;SET NON-ZERO, NON CARRY CC'S
  RET                   ;ALL DONE

NTRSCC:
  CP CONCN2	            ;(CONCN2) GOING TO SCAN PAST EMBEDDED CONSTANT?
  JR Z,NTRSC2           ;NO, TRY OTHER CASES
  PUSH AF               ;SAVE TOKEN TO RETURN
  INC HL                ;POINT TO NUMBER
  LD (CONSAV),A         ;SAVE CURRENT TOKEN
  SUB INTCON            ;IS IT LESS THAN INTEGER CONSTANT?
  JR NC,MAKTKN          ;NO, NOT LINE NUMBER CONSTANT
  SUB ONECON-INTCON     ;LESS THAN EMBEDDED 1 BYTER
  JR NC,ONEI            ;WAS ONE BYTER
  CP IN2CON-ONECON      ;IS IT TWO BYTER?
  JR NZ,FRCINC          ;NOPE, NORMAL INT
  LD A,(HL)             ;GET EMBEDED INT
  INC HL                ;POINT AFTER CONSTANT
ONEI:                   
  LD (CONTXT),HL        ;SAVE TEXT POINTER
  LD H,$00              ;GET UPPER BYTE OF ZERO
ONEI2:                  
  LD L,A                ;GET VALUE
  LD (CONLO),HL         ;SAVE CONSTANT VALUE
  LD A,$02              ;GET VALTYPE
  LD (CONTYP),A         ;SET IT UP IN SAVE PLACE
  LD HL,NUMCON          ;POINT TO NUMBER RE-SCANNER ("FAKE TEXT")
  POP AF                ;GET BACK TOKEN
  OR A                  ;MAKE SURE NUMBER FLAG RE-SET
  RET                   ;RETURN TO CALLER

FRCINC:
  LD A,(HL)             ;GET LOW BYTE OF CONSTANT
  INC HL                ;POINT PAST IT
  INC HL                ;TO NEXT THING
  LD (CONTXT),HL        ;SAVE POINTER PAST
  DEC HL                ;BACK TO HIGH BYTE
  LD H,(HL)             ;GET HIGH BYTE
  JR ONEI2              ;FINISH SCANNING

; Routine at 18104
;RESCAN THE TOKEN & RESTORE OLD TEXT PTR
;
; Used by the routine at OPRND.
_CONFAC:
  CALL CONFAC
NTRSC2:
  LD HL,(CONTXT)
  JR __CHRCKB		; Gets current character (or token) from BASIC text.

; Routine at 18112
MAKTKN:
  INC A                 ;CALCULATE VALTYPE
  RLCA                  ;*2 TO GET VALTYPE 0=2, 1=4, 3=8
  LD (CONTYP),A         ;CONTYPE NOW SETUP
  PUSH DE               ;SAVE SOME RGS
  PUSH BC
  LD DE,CONLO           ;PLACE TO STORE SAVED CONSTANT
  EX DE,HL              ;GET TEXT POINTER IN [D,E]
  LD B,A                ;SETUP COUNTER IN [B]
  CALL MOVE1           ;MOVE DATA IN
  EX DE,HL              ;GET TEXT POINTER BACK
  POP BC                ;RESTORE [B,C]
  POP DE
  LD (CONTXT),HL        ;SAVE THE GOOD TEXT POINTER
  POP AF                ;RESTORE TOKEN
  LD HL,NUMCON          ;GET POINTER TO FAKE TEXT
  OR A                  ;CLEAR CARRY SO OTHERS DONT THINK ITS A NUMBER AND SET NON-ZERO SO NOT TERMINATOR
  RET                   ;ALL DONE

; Routine at 18139
NOTCON:
  CP $09                ;LINE FEED OR TAB?
  JP NC,__CHRGTB        ;YES, EAT.
NOTLFT:
  CP '0'                ;ALL CHARACTERS GREATER THAN "9" HAVE RETURNED, SO SEE IF NUMERIC
  CCF                   ;MAKE NUMERICS HAVE CARRY ON
  INC A                 ;SET ZERO IF [A]=0
  DEC A
  RET


; Data at 18150

;THESE FAKE TOKENS FORCE CHRGET TO EFFECTIVELY RE-SCAN THE EMBEDED CONSTANT
NUMCON:
  DEFB CONCON     ;TOKEN RETURNED BY CHRGET AFTER CONSTANT SCANNED
  DEFB CONCN2     ;TOKEN RETURNED SECOND TYPE CONSTANT IS SCANNED.



; This entry point is used by the routines at _CONFAC and NUMLIN.
CONFAC:
  LD A,(CONSAV)         ;GET CONSTANT TOKEN
  CP LINCON+1           ;LINE# CONSTANT? (ERL=#)
  JR NC,NTLINE          ;NO
  CP PTRCON             ;LINE POINTER CONSTANT?
  JR C,NTLINE			;NO
  LD HL,(CONLO)			;GET VALUE
  JR NZ,FLTLIN          ;MUST BE LINE NUMBER, NOT POINTER
  INC HL                ;POINT TO LINE #
  INC HL
  INC HL
  LD E,(HL)             ;GET LINE # IN [D,E]
  INC HL
  LD D,(HL)             ;GET HIGH PART
  EX DE,HL              ;VALUE TO [H,L]
FLTLIN:
  JP INEG2              ;FLOAT IT

NTLINE:
  LD A,(CONTYP)			;GET SAVED CONSTANT VALTYP
  LD (VALTYP),A         ;SAVE IN REAL VALTYP
  CP $02                ; Integer ?
  JR NZ,NTLINE_FLT      ; No, JP
  LD HL,(CONLO)			;GET LOW TWO BYTES OF FAC
  LD (FACLOW),HL        ;SAVE THEM
NTLINE_FLT:
  LD HL,CONLO			; Value of stored constant
  JP VMOVFM


; $4718
__DEFSTR:
  LD E,$03	; DEFAULT SOME LETTERS TO String type

  DEFB $01	; "LD BC,nn" to jump over the next word without executing it
; $471B
__DEFINT:
  LD E,$02	; DEFAULT SOME LETTERS TO Integer type

  DEFB $01	; "LD BC,nn" to jump over the next word without executing it
; $471E
__DEFSNG:
  LD E,$04	; DEFAULT SOME LETTERS TO Single precision type
  
  DEFB $01	; "LD BC,nn" to jump over the next word without executing it
; $4721
__DEFDBL:
  LD E,$08	; DEFAULT SOME LETTERS TO Double Precision type

; $4723
DEFCON:
  CALL IS_LETTER  		;MAKE SURE THE ARGUMENT IS A LETTER
  LD BC,SN_ERR          ;PREPARE "SYNTAX ERROR" RETURN
  PUSH BC
  RET C                 ;RETURN IF THERES NO LETTER
  SUB 'A'               ;MAKE AN OFFSET INTO DEFTBL
  LD C,A                ;SAVE THE INITIAL OFFSET
  LD B,A                ;ASSUME IT WILL BE THE FINAL OFFSET
  RST CHRGTB            ;GET THE POSSIBLE DASH
  CP TK_MINUS           ;(token code for '-'): A RANGE ARGUMENT? ; 
  JR NZ,NOTRNG          ;IF NOT, JUST ONE LETTER
  RST CHRGTB            ;GET THE FINAL POSITION
  CALL IS_LETTER         ;CHECK FOR A LETTER
  RET C                 ;GIVE A SYNTAX ERROR IF IMPROPER
  SUB  'A'              ;MAKE IT AN OFFSET
  LD B,A                ;PUT THE FINAL IN [B]
  RST CHRGTB            ;GET THE TERMINATOR
NOTRNG:
  LD A,B                ;GET THE FINAL CHARACTER
  SUB C                 ;SUBTRACT THE START
  RET C                 ;IF IT'S LESS THATS NONSENSE
  INC A                 ;SETUP THE COUNT RIGHT
  EX (SP),HL            ;SAVE THE TEXT POINTER AND GET RID OF THE "SYNTAX ERROR" RETURN
  LD HL,DEFTBL          ;POINT TO THE TABLE OF DEFAULTS
  LD B,$00              ;SETUP A TWO-BYTE STARTING OFFSET
  ADD HL,BC             ;MAKE [H,L] POINT TO THE FIRST ENTRY TO BE MODIFIED
LPDCHG:
  LD (HL),E             ;MODIFY THE DEFAULT TABLE
  INC HL                
  DEC A                 ;COUNT DOUNT THE NUMBER OF CHANGES TO MAKE
  JR NZ,LPDCHG          
  POP HL                ;GET BACK THE TEXT POINTER
  LD A,(HL)             ;GET LAST CHARACTER
  CP ','                ;IS IT A COMMA?
  RET NZ                ;IF NOT STATEMENT SHOULD HAVE ENDED
  RST CHRGTB            ;OTHERWISE SET UP TO SCAN NEW RANGE
  JR DEFCON

; Routine at 18261
; Get subscript
;
; INTIDX READS A FORMULA FROM THE CURRENT POSITION AND
; TURNS IT INTO A POSITIVE INTEGER
; LEAVING THE RESULT IN [D,E].  NEGATIVE ARGUMENTS
; ARE NOT ALLOWED. [H,L] POINTS TO THE TERMINATING
; CHARACTER OF THE FORMULA ON RETURN.
;
INTIDX:
  RST CHRGTB		; Gets next character (or token) from BASIC text.
; This entry point is used by the routine at __CLEAR.
INTIDX_0:
  CALL FPSINT_0          ;READ A FORMULA AND GET THE RESULT AS AN INTEGER IN [D,E]
                         ;ALSO SET THE CONDITION CODES BASED ON THE HIGH ORDER OF THE RESULT
  RET P                  ;DON'T ALLOW NEGATIVE NUMBERS

; entry for '?FC ERROR'
;
; Used by the routines at __LOG, __ERROR, __AUTO, OPRND, __WIDTH, FNDNUM,
; __DELETE, __RENUM_0, __RENUM_NXT, SCNVAR, ATRSCN, IN_GFX_MODE, __PAINT, __CIRCLE, CGTCNT,
; __DRAW, DMOVE, DSCALE, DCOLR, CHKRNG, REUSST, __SWAP, __CLEAR, __ASC, __MID_S,
; FN_INSTR, LHSMID, __LFILES, FN_INPUT, __SOUND, MCLPLAY, SNDFCE, L77D4, ON_OPTIONS, __STRIG,
; __SCREEN, SET_BAUDRATE, __SPRITE, PUT_SPRITE, __BASE, __CVD and __MAX.
;  $475A
FC_ERR:
  LD E,$05				; Err $05 - "Illegal function call"
  JP ERROR              ;TOO BIG. FUNCTION CALL ERROR

; Evaluate line number text pointed to by HL.
;
;
; LINSPC IS THE SAME AS LINGET EXCEPT IN ALLOWS THE
; CURRENT LINE (.) SPECIFIER
;
; Routine at 18271
;
; Used by the routines at LNUM_RANGE, __AUTO and __RENUM_0.
LNUM_PARM:
  LD A,(HL)             ;GET CHAR FROM MEMORY
  CP '.'                ;IS IT CURRENT LINE SPECIFIER
  LD DE,(DOT)           ;GET CURRENT LINE #
  JP Z,__CHRGTB         ;ALL DONE.


; Get specified line number
; ASCII to Integer, result in DE
;
; LINGET READS A LINE # FROM THE CURRENT TEXT POSITION
;
; LINE NUMBERS RANGE FROM 0 TO 65529
;
; THE ANSWER IS RETURNED IN [D,E].
; [H,L] IS UPDATED TO POINT TO THE TERMINATING CHARACTER
; AND [A] CONTAINS THE TERMINATING CHARACTER WITH CONDITION
; CODES SET UP TO REFLECT ITS VALUE.
;
; This entry point is used by the routines at TSTNUM, __GOSUB, RUNLIN, __AUTO,
; CNSGET, __RENUM_0 and __RESTORE.
ATOH:
  DEC HL                ;BACKSPACE PTR

; As above, but conversion starts at HL+1
;
; Used by the routine at ON_ERROR.
ATOH2:
  RST CHRGTB		    ;FETCH CHAR (GOBBLE LINE CONSTANTS)
  CP LINCON             ;$0E: EMBEDDED LINE CONSTANT?
  JR Z,LINGT3           ;YES, RETURN DOUBLE BYTE VALUE
  CP PTRCON             ;$0D: ALSO CHECK FOR POINTER

; This entry point is used by the routines at LINE2PTR and SCNPT2.
LINGT3:
  LD DE,(CONLO)			;GET EMBEDDED LINE #
  JP Z,__CHRGTB			;EAT FOLLOWING CHAR
  XOR A
  LD (CONSAV),A
  LD DE,$0000           ;ZERO ACCUMULATED LINE #
  DEC HL                ;BACK UP POINTER
GTLNLP:
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  RET NC                ;WAS IT A DIGIT
  PUSH HL
  PUSH AF
  LD HL,65529/10     ; Largest number 65529      ;SEE IF THE LINE # IS TOO BIG
  RST DCOMPR		 ; Compare HL with DE.
  JR C,POPHSR        ; YES, DON'T SCAN ANY MORE DIGITS IF SO.  FORCE CALLER TO SEE DIGIT AND GIVE SYNTAX ERROR
                     ; CAN'T JUST GO TO SYNTAX ERROR BECAUSE OF NON-FAST RENUM WHICH CAN'T TERMINATE
  LD H,D             ;SAVE [D,E]
  LD L,E
  ADD HL,DE		; *2
  ADD HL,HL		; ..*4
  ADD HL,DE     ; ..*5
  ADD HL,HL     ; ..*10  ;PUTTING [D,E]*10 INTO [H,L]
  POP AF        ; Restore digit
  SUB '0'       ; Make it 0 to 9
  LD E,A        ; DE = Value of digit
  LD D,0
  ADD HL,DE     ; Add to number                   ;ADD THE NEW DIGIT
  EX DE,HL      ; Number to DE
  POP HL        ; Restore code string address     ;GET BACK TEXT POINTER
  JR GTLNLP     ; Go to next character

POPHSR:
  POP AF        ;GET OFF TERMINATING DIGIT
  POP HL        ;GET BACK OLD TEXT POINTER
  RET

; Routine at 18334
__RUN:
  JP Z,RUN_FST        ; RUN from start if just RUN   ;NO LINE # ARGUMENT
  CP LINCON           ;LINE NUMBER CONSTANT?
  JR Z,__RUN_0        ;YES
  CP PTRCON           ;LINE POINTER (RATHER UNLIKELY)
  JP NZ,_RUN_FILE

__RUN_0:              ; Initialise variables    ;CLEAN UP -- RESET THE STACK, DATPTR,VARIABLES ...
                                                ;[H,L] IS THE ONLY THING PRESERVED
  CALL _CLVAR
  LD BC,NEWSTT
  JR RUNLIN                                     ;PUT "NEWSTT" ON AND FALL INTO "GOTO"

; 'GOSUB' BASIC command
; Routine at 18354
;
; A "GOSUB" ENTRY ON THE STACK HAS THE FOLLOWING FORMAT
;
; LOW ADDRESS
;
;	A TOKEN EQUAL TO $GOSUB 1 BYTE
;	THE LINE # OF THE THE "GOSUB" STATEMENT 2 BYTES
;	A POINTER INTO THE TEXT OF THE "GOSUB" 2 BYTES
;
; HIGH ADDRESS
;
; TOTAL 5 BYTES
;
__GOSUB:
  LD C,$03             ; 3 Levels of stack needed        ;"GOSUB" ENTRIES ARE 5 BYTES LONG
  CALL CHKSTK          ; Check for 3 levels of stack     ;MAKE SURE THERE IS ROOM
  CALL ATOH                                              ;MUST SCAN LINE NUMBER NOW
  POP BC               ; Get return address              ;POP OFF RETURN ADDRESS OF "NEWSTT"
  PUSH HL              ; Save code string for RETURN     ;REALLY PUSH THE TEXT POINTER
  PUSH HL              ; And for GOSUB routine           ;SAVE TEXT POINTER
  LD HL,(CURLIN)       ; Get current line                ;GET THE CURRENT LINE #
  EX (SP),HL           ; Into stack - Code string out    ;PUT CURLIN ON THE STACK AND [H,L]=TEXT PTR
  LD BC,$0000          
  PUSH BC              
  LD BC,NEWSTT      
  LD A,TK_GOSUB        ; "GOSUB" token
  PUSH AF              ; Save token                      ;PUT GOSUB TOKEN ON THE STACK
  INC SP               ; Don't save flags                ;THE GOSUB TOKEN TAKES ONLY ONE BYTE
  PUSH BC                                                ;SAVE NEWSTT ON STACK
  JR __GOTO_0                                            ;HAVE NOW GRAB LINE # PROPERLY

; Routine at 18383
;
; Used by the routine at EXEC_ONGOSUB.
DO_GOSUB:
  PUSH HL                ; Save code string for RETURN
  PUSH HL                ; And for GOSUB routine
  LD HL,(CURLIN)		 ; Get current line
  EX (SP),HL             ; Into stack - Code string out
  PUSH BC
  LD A,TK_GOSUB          ; "GOSUB" token
  PUSH AF                ; Save token
  INC SP                 ; Don't save flags
  EX DE,HL
  DEC HL
  LD (SAVTXT),HL
  INC HL
  LD (SAVSTK),SP
  JP GONE4

; Routine at 18407
;
; This entry point is used by the routine at __RUN.
RUNLIN:                                          ; CONTINUE WITH SUBROUTINE
  PUSH BC               ; Save return address    ; RESTORE RETURN ADDRESS OF "NEWSTT"
                                                 ; AND SEARCH. IN THE 8K WE START WHERE WE
                                                 ; ARE IF WE ARE GOING TO A FORWARD LOCATION.

; This entry point is used by the routine at __IF.
__GOTO:
  CALL ATOH             ; ASCII number to DE binary    ;PICK UP THE LINE # AND PUT IT IN [D,E]
; This entry point is used by the routine at __GOSUB.
__GOTO_0:
  LD A,(CONSAV)         ;GET TOKEN FOR LINE # BACK
  CP PTRCON             ;WAS IT A POINTER
  EX DE,HL              ;ASSUME SO
  RET Z                 ;IF IT WAS, GO BACK TO NEWSTT WITH [H,L] AS TEXT PTR
  CP LINCON				; Line number prefix
  JP NZ,SN_ERR
  EX DE,HL              ;FLIP BACK IF NOT
  PUSH HL               ;SAVE CURRENT TEXT PTR ON STACK
  LD HL,(CONTXT)        ;GET POINTER TO RIGHT AFTER CONSTANT
  EX (SP),HL            ;SAVE ON STACK, RESTORE CURRENT TEXT PTR
  CALL __REM			; Get end of line                     ;SKIP TO THE END OF THIS LINE
  INC HL                ; Start of next line                  ;POINT AT THE LINK BEYOND IT
  PUSH HL               ; Save Start of next line             ;SAVE THE POINTER
  LD HL,(CURLIN)		; Get current line                    ;GET THE CURRENT LINE #
  RST DCOMPR            ; Line after current?   ;[D,E] CONTAINS WHERE WE ARE GOING, [H,L] CONTAINS THE CURRENT LINE #
                                                  ;SO COMPARING THEM TELLS US WHETHER TO START SEARCHING FROM WHERE 
                                                  ;WE ARE OR TO START SEARCHING FROM THE BEGINNING OF TXTTAB
  POP HL                ; Restore Start of next line          ; [H,L]=CURRENT POINTER
  CALL C,SRCHLP         ; Line is after current line          ; SEARCH FROM THIS POINT
  CALL NC,SRCHLN        ; Line is before current line         ; SEARCH FROM THE BEGINNING
                                                              ; -- ACTUALLY SEARCH AGAIN IF ABOVE SEARCH FAILED
  JR NC,UL_ERR			; Err $08 - "Undefined line number"   ;LINE NOT FOUND, DEATH
  DEC BC                ; Incremented after
  LD A,PTRCON           ;POINTER CONSTANT
  LD (PTRFLG),A         ;SET PTRFLG
  POP HL                ;GET SAVED POINTER TO RIGHT AFTER CONSTANT
  CALL CONCH2           ;CHANGE LINE # TO PTR
  LD H,B                ; Set up code string address: [H,L]= POINTER TO THE START OF THE MATCHED LINE
  LD L,C                ; NOW POINTING AT THE FIRST BYTE OF THE POINTER TO THE START OF THE NEXT LINE
  RET                   ; Line found: GO TO NEWSTT

; entry for '?UL ERROR'
;
; Used by the routines at RUNLIN, L492A and __RESTORE.
  ; --- START PROC L481C ---
UL_ERR:
  LD E,$08				; Err $08 - "Undefined line number"
  JP ERROR              ;C=MATCH, SO IF NO MATCH WE GIVE A "US" ERROR


;
; SEE "GOSUB" FOR THE FORMAT OF THE STACK ENTRY
; "RETURN" RESTORES THE LINE NUMBER AND TEXT POINTER ON THE STACK
; AFTER ELIMINATING ALL THE "FOR" ENTRIES IN FRONT OF THE "GOSUB" ENTRY
;
; Data block at 18465
__RETURN:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HRETU			; Hook for 'RETURN'
ENDIF
  LD (TEMP),HL
  LD D,$FF				; Flag "GOSUB" search
  CALL BAKSTK			; Look "GOSUB" block
  CP TK_GOSUB			; TK_GOSUB, Token for 'GOSUB'
  JR Z,__RETURN_0
  DEC HL                
__RETURN_0:
  LD SP,HL              ; Kill all FORs in subroutine
  LD (SAVSTK),HL
  LD E,$03				; Err $03 - "RETURN without GOSUB" (ERRRG)
  JP NZ,ERROR           ; Error if no "GOSUB" found          

  POP HL                ;GET LINE # "GOSUB" WAS FROM
  LD A,H
  OR L                  ; Return to line
  JR Z,__RETURN_1       ; No - Return to line
  LD A,(HL)
  AND $01
  CALL NZ,RETURN_TRAP
__RETURN_1:
  POP BC           		; Get RETURN line number         ;GET LINE # "GOSUB" WAS FROM
  LD HL,NEWSTT          ; Execution driver loop          ;PUT IT INTO CURLIN
  EX (SP),HL            ; Into stack - Code string out   ;PUT RETURN ADDRESS OF "NEWSTT" BACK ONTO THE STACK.
                                                         ;GET TEXT POINTER FROM "GOSUB" SKIP OVER SOME CHARACTERS
                                                         ;SINCE WHEN "GOSUB" STUCK THE TEXT POINTER ONTO THE STACK
                                                         ;THE LINE # ARGUMENT HADN'T BEEN READ IN YET.
  EX DE,HL
  LD HL,(TEMP)
  DEC HL
  RST CHRGTB			; Gets next character (or token) from BASIC text.
  JP NZ,__GOTO
  LD H,B            	; Put RETURN line number in HL
  LD L,C
  LD (CURLIN),HL    	; Save as current                ;PUT IT INTO CURLIN
  EX DE,HL

  DEFB $3E  ; "LD A,n" to Mask the next byte

NXTDTA:
  POP HL                ;GET TEXT POINTER OFF STACK

  ; --- START PROC L485B ---
; DATA statement: find next DATA program line..
;
; Used by the routines at __IF, FDTLP and __DEF.
__DATA:
  DEFB $01          ; "LD BC," TO PICK UP ":" INTO C AND SKIP
  DEFB ':'          ;"DATA" TERMINATES ON ":" AND 0.   ":" ONLY APPLIES IF QUOTES HAVE MATCHED UP

; 'Go to next line'
; Used by 'REM', 'ELSE' (EXECUTED "ELSE"S ARE SKIPPED) and error handling code.
;
; NOTE: REM MUST PRESERVE [D,E] BECAUSE OF "GO TO" AND ERROR
;
__REM:
  DEFB $0E          ;"LD C,"   THE ONLY TERMINATOR IS ZERO
  DEFB 0            ;0 = End of statement

  LD B,$00          ;INSIDE QUOTES THE ONLY TERMINATOR IS ZERO
NXTSTL:
  LD A,C			; Statement and byte   ;WHEN A QUOTE IS SEEN THE SECOND
  LD C,B                                   ;TERMINATOR IS TRADED, SO IN "DATA"
  LD B,A			; Statement end byte   ;COLONS INSIDE QUOTATIONS WILL HAVE NO EFFECT
NXTSTT:
  DEC HL            ;NOP THE INX H IN CHRGET
NXTSTT_0:
  RST CHRGTB		; Get byte                       ;GET A CHAR
  OR A              ; End of line?                   ;ZERO IS ALWAYS A TERMINATOR
  RET Z             ; Yes - Exit
  CP B              ; End of statement?              ;TEST FOR THE OTHER TERMINATOR
  RET Z             ; Yes - Exit
  INC HL            ; Next byte
  CP '"'            ; Literal string?                ;IS IT A QUOTE?
  JR Z,NXTSTL       ; Yes - Look for another '"'     ;IF SO TIME TO TRADE
;
; WHEN AN "IF" TAKES A FALSE BRANCH IT MUST FIND THE APPROPRIATE "ELSE" TO START EXECUTION AT.
; "DATA" COUNTS THE NUMBER OF "IF"S, IT SEES SO THAT THE "ELSE" CODE CAN MATCH "ELSE"S WITH "IF"S.
; THE COUNT IS KEPT IN [D] BECAUSE THEN S HAVE NO COLON
; MULTIPLE IFS CAN BE FOUND IN A SINGLE STATEMENT SCAN
; THIS CAUSES A PROBLEM FOR 8-BIT DATA IN UNQUOTED STRING DATA BECAUSE $IF MIGHT BE MATCHED.
; FIX IS TO HAVE FALSIF IGNORE CHANGES IN [D] IF ITS A DATA STATEMENT
;
  INC A             ;FUNCTION TOKEN?
  JR Z,NXTSTT_0     ;THEN IGNORE FOLLOWING FN NUMBER
  SUB TK_IF+1       ;IS IT AN "IF"
  JR NZ,NXTSTT      ;IF NOT, CONTINUE ON
  CP B              ;SINCE "REM" CAN'T SMASH [D,E] WE HAVE TO BE CAREFUL
                    ;SO ONLY IF B DOESN'T EQUAL ZERO WE INCREMENT D. (THE "IF" COUNT)
  ADC A,D           ;CARRY ON IF [B] NOT ZERO
  LD D,A            ;UPDATE [D]
  JR NXTSTT			; Keep looking

; Routine at 18555
; LETCON IS LET ENTRY POINT WITH VALTYP-3 IN [A]
; BECAUSE GETYPR HAS BEEN CALLED
LETCON:
  POP AF            ;GET VALTYPE OFF STACK
  ADD A,$03         ;MAKE VALTYPE CORRECT
  JR __LET_0        ;CONTINUE

; Routine at 18560
__LET:
  CALL GETVAR       ;GET THE POINTER TO THE VARIABLE NAMED IN TEXT AND PUT IT INTO [D,E]
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB TK_EQUAL		;CHECK FOR "="
  LD (TEMP),DE      ;MUST SET UP TEMP FOR "FOR" UP HERE SO WHEN
                    ;USER-FUNCTIONS CALL REDINP, TEMP DOESN'T GET CHANGED
  PUSH DE
  LD A,(VALTYP)     ; Get data type
  PUSH AF           ; save type         ;CALL REDINP, TEMP DOESN'T GET CHANGED
  CALL EVAL                             ;GET THE VALUE OF THE FORMULA
  POP AF            ; Restore type      ;GET THE VALTYP OF THE VARIABLE INTO [A] INTO FAC

; This entry point is used by the routines at LETCON and __LINE.
__LET_0:
  EX (SP),HL        ;[H,L]=POINTER TO VARIABLE TEXT POINTER TO ON TOP OF STACK
; This entry point is used by the routine at __READ.
__LET_1:
  LD B,A            ;SAVE VALTYP
  LD A,(VALTYP)     ;GET PRESENT VALTYPE
  CP B              ;COMPARE THE TWO
  LD A,B            ;GET BACK CURRENT
  JR Z,__LET_2      ;VALTYPE ALREADY SET UP, GO!

  CALL CHKTYP       ;FORCE VALTPES TO BE [A]'S
LETCN4:
  LD A,(VALTYP)     ;GET PRESENT VALTYPE
__LET_2:
  LD DE,FACCU       ;ASSUME THIS IS WHERE TO START MOVEING
  CP $02            ;IS IT?   ; (Integer ?)
  JR NZ,__LET_3     ;YES
  LD DE,FACLOW      ;NO, USE D.P. FAC
__LET_3:
  PUSH HL           ;SAVE THE POINTER AT THE VALUE POSITION
  CP $03            ; String ?
  JR NZ,LETNUM      ;NUMERIC, SO FORCE IT AND COPY

  LD HL,(FACLOW)	; Pointer to string entry         ;GET POINTER TO THE DESCRIPTOR OF THE RESULT
  PUSH HL			; Save it on stack                ;SAVE THE POINTER AT THE DESCRIPTOR
  INC HL			; Skip over length
  LD E,(HL)			; LSB of string address
  INC HL
  LD D,(HL)			; MSB of string address
  LD HL,BUFFER      ;IF THE DATA IS IN BUF, OR IN DISK RANDOM BUFFER, COPY.
  RST DCOMPR		; Compare HL with DE.. is string before program?
  JR C,__LET_5      ;SINCE BUF CHANGES ALL THE TIME GO COPY, IF DATA REALLY IS IN BUF
  LD HL,(STREND)    ;SEE IF IT POINTS INTO STRING SPACE
  RST DCOMPR		;Is string literal in program?    IF NOT DON'T COPY
  POP DE            ;GET BACK THE POINTER AT THE DESCRIPTOR
  JR NC,DNTCPY		;DON'T COPY LITERALS
  LD HL,DSCTMP-1	;NOW, SEE IF ITS A VARIABLE
  RST DCOMPR		;BY SEEING IF THE DESCRIPTOR IS IN THE TEMPORARY STORAGE AREA (BELOW DSCTMP)
  JR C,__LET_4
  LD HL,TEMPST-1
  RST DCOMPR		; Compare HL with DE.
  JR C,DNTCPY       ;DON'T COPY IF ITS NOT A VARIABLE

__LET_4:
  DEFB $3E                ; "LD A,n" to Mask the next byte
  
__LET_5:
  POP DE            ;GET THE POINTER TO THE DESCRIPTOR IN [D,E]

  CALL FRETMS       ;FREE UP A TEMORARY POINTING INTO BUF    (Back to last tmp-str entry)
  EX DE,HL          ;STRCPY COPIES [H,L]
  CALL STRCPY       ;COPY VARIABLES IN STRING SPACE OR STRINGS WITH DATA IN BUF

; a.k.a MVSTPT
DNTCPY:
  CALL FRETMS		;FREE UP THE TEMPORARY WITHOUT FREEING UP ANY STRING SPACE (Back to last tmp-str entry)
  EX (SP),HL        ;[H,L]=PLACE TO STORE THE DESCRIPTOR
                    ;LEAVE A NONSENSE ENTRY ON THE STACK, SINCE THE "POP DE" DOESN'T EVER MATTER IN THIS CASE
LETNUM:
  CALL VMOVE   		;COPY A DESCRIPTOR OR A VALUE
  POP DE            ;FOR "FOR" POP OFF A POINTER AT THE LOOP VARIABLE INTO [D,E]
  POP HL            ;GET THE TEXT POINTER BACK
  RET

; 'ON' BASIC instruction
; ON..GOTO, ON ERROR GOTO CODE
;
; Data block at 18660
__ON:
  CP TK_ERROR        ;"ON...ERROR"?
  JR NZ,ON_OTHER     ;NO.
  RST CHRGTB         ;GET NEXT THING
  RST SYNCHR         
  DEFB TK_GOTO       ;MUST HAVE ...GOTO
  CALL ATOH	         ;GET FOLLOWING LINE #
  LD A,D             ;IS LINE NUMBER ZERO?
  OR E               ;SEE
  JR Z,__ON_0        ;IF ON ERROR GOTO 0, RESET TRAP
  CALL FNDLN1        ;SEE IF LINE EXISTS (SAVE [H,L] ON STACK)	..Sink HL in stack and get first line number
  LD D,B             ;GET POINTER TO LINE IN [D,E]
  LD E,C             ;(LINK FIELD OF LINE)
  POP HL             ;RESTORE [H,L]
  JP NC,UL_ERR		 ;ERROR IF LINE NOT FOUND.. Err $08 - "Undefined line number"
__ON_0:
  LD (ONELIN),DE     ;SAVE POINTER TO LINE OR ZERO IF 0.
  RET C              ;YOU WOULDN'T BELIEVE IT IF I TOLD YOU
  LD A,(ONEFLG)      ;ARE WE IN AN "ON...ERROR" ROUTINE?
  OR A               ;SET CONDITION CODES
  LD A,E             ;WANT AN EVEN STACK PTR. FOR 8086
  RET Z              ;IF NOT, HAVE ALREADY DISABLED TRAPPING.
  LD A,(ERRFLG)      ;GET ERROR CODE
  LD E,A             ;INTO E.
  JP ERRESM          ;FORCE THE ERROR TO HAPPEN

  ; ON KEY, STOP, SPRITE...
ON_OTHER:
  CALL ON_OPTIONS	; ON_KEY, ON_STOP, ON_SPRITE, ON_TRIG, ON_INTERVAL...
  JR C,NTOERR       ; AN "ON ... GOSUB" PERHAPS?

  PUSH BC
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB TK_GOSUB     ; ..must be GOSUB.  Otherwise error
  XOR A

L4917:
  POP BC
  PUSH BC
  CP C
  JP NC,SN_ERR		; ?SN Err
  PUSH AF
  CALL ATOH		; Get specified line number
  LD A,D
  OR E
  JR Z,L492E
  CALL FNDLN1		; Sink HL in stack and get first line number
  LD D,B
  LD E,C		; DE=BC

; Routine at 18730
L492A:
  POP HL
  JP NC,UL_ERR			; Err $08 - "Undefined line number"

L492E:
  POP AF
  POP BC
  PUSH AF
  ADD A,B
  PUSH BC
  CALL L785C		; (ON key.. ?)
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  POP BC
  POP DE
  RET Z
  PUSH BC
  PUSH DE
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
  POP AF
  INC A
  JR L4917

; Not 'ON ERROR'
NTOERR:
  CALL GETINT           ; Get integer 0-255                     ;GET VALUE INTO [E]
  LD A,(HL)             ; Get "GOTO" or "GOSUB" token           ;GET THE TERMINATOR BACK
  LD B,A                ; Save in B                             ;SAVE THIS CHARACTER FOR LATER
  CP TK_GOSUB           ; "GOSUB" token?                        ;AN "ON ... GOSUB" PERHAPS?
  JR Z,ONGO             ; Yes - Find line number                ;YES, SOME FEATURE USE
  RST SYNCHR 		    ; Make sure it's "GOTO"                 
  DEFB TK_GOTO          ; TK_GOTO: "GOTO" token                 ;OTHERWISE MUST BE "GOTO"
  DEC HL                ; Cancel increment                      ;BACK UP CHARACTER POINTER

ONGO:                   
  LD C,E                ; Integer of branch value
ONGOLP:                 
  DEC C                 ; Count branches
  LD A,B                ; Get "GOTO" or "GOSUB" token
  JP Z,ONJMP            ; Go to that line if right one
  CALL ATOH2            ; Get line number to DE
  CP ','                ; Another line number?          ;A COMMA
  RET NZ                ; No - Drop through, IF A COMMA DOESN'T DELIMIT THE END OF THE
                        ; CURRENT LINE #, WE MUST BE THE END OF THE LINE
  JR ONGOLP             ; Yes - loop                    ;CONTINUE GOBBLING LINE #S

; Data block at 18781
__RESUME:
  LD A,(ONEFLG)         ;GET FLAG
  OR A                  ;TRAP ROUTINE.
  JR NZ,__RESUME_0      ;No error, continue
  LD (ONELIN),A
  LD (ONELIN+1),A
  JP RW_ERR             ; Err 16 - "RESUME without error"

__RESUME_0:
  INC A                 ;MAKE A=0
  LD (ERRFLG),A         ;CLEAR ERROR FLAG SO ^C DOESN'T GIVE ERROR
  LD A,(HL)             ;GET CURRENT CHAR BACK
  CP TK_NEXT            ;RESUME NEXT?
  JR Z,RESNXT           ;YUP.
  CALL ATOH             ;GET FOLLOWING LINE #
  RET NZ                ;SHOULD TERMINATE
  LD A,D                ;IS LINE NUMBER ZERO?
  OR E                  ;TEST
  JR Z,RES_NOLINE         
  CALL __GOTO_0         ;DO A GOTO THAT LINE.
  XOR A
  LD (ONEFLG),A         ; Clear 'on error' flag
  RET

RESNXT:
  RST CHRGTB            ;MUST TERMINATE
  RET NZ                ;BLOW HIM UP
  JR RESTXT

RES_NOLINE:
  XOR A
  LD (ONEFLG),A			; Clear 'on error' flag
  INC A                 ;SET NON ZERO CONDITION CODES
RESTXT:
  LD HL,(ERRTXT)		;GET POINTER INTO LINE.
  EX DE,HL              ;SAVE ERRTXT IN [D,E]
  LD HL,(ERRLIN)		;GET LINE #
  LD (CURLIN),HL        ;SAVE IN CURRENT LINE #
  EX DE,HL
  RET NZ                ;GO TO NEWSTT IF JUST "RESUME"
  LD A,(HL)             ;GET ":" OR LINE HEADER
  OR A                  ;SET CC
  JR NZ,NOTBGL          ;#0 MEANS MUST BE ":"
  INC HL                ;SKIP HEADER
  INC HL
  INC HL
  INC HL
NOTBGL:
  INC HL                ;POINT TO START OF THIS STATEMENT
  XOR A
  LD (ONEFLG),A			; Clear 'on error' flag
  JP __DATA             ;GET NEXT STMT


; 'ERROR' BASIC command
;
; THIS IS THE ERROR <CODE> STATEMENT WHICH FORCES
; AN ERROR OF TYPE <CODE> TO OCCUR
; <CODE> MUST BE .GE. 0 AND .LE. 255
;
; Routine at 18858
__ERROR:
  CALL GETINT           ;GET THE PARAM
  RET NZ                ;SHOULD HAVE TERMINATED
  OR A                  ;ERROR CODE 0?
  JP Z,FC_ERR			;YES, ERROR IN ITSELF, Err $05 - "Illegal function call"
  JP ERROR              ;FORCE AN ERROR


; AUTO [<line number>[,<increment>]]
;
; THE AUTO [BEGGINNING LINE[,[INCREMENT]]]
; COMMAND IS USED TO AUTOMATICALLY GENERATE LINE NUMBERS FOR LINES TO BE INSERTED.
; BEGINNING LINE IS USED TO SPECIFY THE INITAL LINE (10 IS ASSUMED IF OMMITED)
; AND THE INCREMENT IS USED TO SPECIFY THE INCREMENT USED TO GENERATE THE NEXT LINE #.
; IF ONLY A COMMA IS USED AFTER THE BEGGINING LINE, THE OLD INCREMENT IS USED.
;
; Routine at 18869
__AUTO:
  LD DE,10              ;ASSUME INITIAL LINE # OF 10
  PUSH DE               ;SAVE IT
  JR Z,__AUTO_0         ;IF END OF COMMAND USE 10,10
  CALL LNUM_PARM        ;GET LINE #, ALLOW USE OF . FOR CURRENT LINE
  EX DE,HL              ;GET TXT PTR IN [D,E]
  EX (SP),HL            ;PUT INIT ON STACK, GET 10 IN [H,L]
  JR Z,__AUTO_1         ;IF TERMINATOR, USE INC OF 10
  EX DE,HL              ;GET TEXT PTR BACK IN [H,L]
  RST SYNCHR
  DEFB ','              ;COMMA MUST FOLLOW
  LD DE,(AUTINC)        ;GET PREVIOUS INC
  JR Z,__AUTO_0         ;USE PREVIOUS INC IF TERMINATOR
  CALL ATOH             ;GET INC
  JP NZ,SN_ERR          ;SHOULD HAVE FINISHED.
__AUTO_0:               
  EX DE,HL              ;GET INC IN [H,L]
__AUTO_1:               
  LD A,H                ;SEE IF ZERO
  OR L                  
  JP Z,FC_ERR			;ZERO INC GIVES FCERR ( Err $05 - "Illegal function call" )
  LD (AUTINC),HL        ;SAVE INCREMENT
  LD (AUTFLG),A			;SET FLAG TO USE AUTO IN MAIN CODE.; AUTO mode ?
  POP HL                ;GET INITIAL LINE #
  LD (AUTLIN),HL        ;SAVE IN INTIAL LINE
  POP BC                ;GET RID OF NEWSTT ADDR
  JP PROMPT             ;JUMP INTO MAIN CODE (FOR REST SEE AFTER MAIN:)


; 'IF'..'THEN' BASIC code
; Routine at 18917
__IF:
  CALL EVAL             ; Evaluate expression (FORMULA)
  LD A,(HL)             ; Get token
  CP ','                ; "," GET TERMINATING CHARACTER OF FORMULA
  CALL Z,__CHRGTB       ; IF SO SKIP IT
  CP TK_GOTO			; "GOTO" token?
  JR Z,IFGO             ; Yes - Get line
  RST SYNCHR 		    ; Make sure it's "THEN"
  DEFB TK_THEN			; "THEN" token
  DEC HL                ; Cancel increment
IFGO:                   
  PUSH HL               ; SAVE THE TEXT POINTER
  CALL VSIGN            ; Test state of expression        
  POP HL                ; GET BACK THE TEXT POINTER
  JR Z,FALSE_IF         ; False - Drop through, HANDLE POSSIBLE "ELSE"
DOCOND:
  RST CHRGTB			; PICK UP THE FIRST LINE # CHARACTER
  RET Z                 ; Go to NEWSTT (RUNCNT) if end of STMT (RETURN FOR "THEN :" OR "ELSE :")
  CP LINCON				; Line number prefix ?
  JP Z,__GOTO			; Yes - GOTO that line
  CP PTRCON             ; POINTER CONSTANT
  JP NZ,ONJMP			; Otherwise do statement (EXECUTE STATEMENT, NOT GOTO)
  LD HL,(CONLO)			; GET TEXT POINTER
  RET                   ; FETCH NEW STATMENT

;
; "ELSE" HANDLER. HERE ON FALSE "IF" CONDITION
;
FALSE_IF:
  LD D,$01              ;NUMBER OF "ELSE"S THAT MUST BE SEEN.
                        ;"DATA" INCREMENTS THIS COUNT EVERY TIME AN "IF" IS SEEN
SKPMRF:
  CALL __DATA           ;SKIP A STATEMENT
  ;":" IS STUCK IN FRONT OF "ELSE"S SO THAT "DATA" WILL STOP BEFORE "ELSE" CLAUSES
  OR A                  ;END OF LINE?
  RET Z                 ;IF SO, NO "ELSE" CLAUSE
  RST CHRGTB			;SEE IF WE HIT AN "ELSE"
  CP TK_ELSE			
  JR NZ,SKPMRF          ;NO, STILL IN THE "THEN" CLAUSE
  DEC D                 ;DECREMENT THE NUMBER OF "ELSE"S THAT MUST BE SEEN
  JR NZ,SKPMRF          ;SKIP MORE IF HAVEN'T SEEN ENOUGH
  JR DOCOND             ;FOUND THE RIGHT "ELSE" -- GO EXECUTE

; Routine at 18973
__LPRINT:
  LD A,$01              ;SAY NON ZERO
  LD (PRTFLG),A         ;SAVE AWAY
  JR MRPRNT             ; a.k.a. NEWCHR

; Data block at 18980
__PRINT:
  LD C,$02              ;SETUP OUTPUT FILE
  CALL FILGET           ; Get stream number (C=default #channel)
MRPRNT:
  DEC HL                ; DEC 'cos GETCHR INCs
  RST CHRGTB            ; GET ANOTHER CHARACTER
  CALL Z,OUTDO_CRLF     ; CRLF if just PRINT    (IF END WITHOUT PUNCTUATION)
PRNTLP:
  JP Z,FINPRT		    ; End of list - Exit (FINISH BY RESETTING FLAGS)
                        ; IN WHICH CASE A TERMINATOR DOES NOT MEAN WE SHOULD TYPE A CRLF BUT JUST RETURN
  CP TK_USING		      ; USING                             ;IS IT "PRINT USING" ?
  JP Z,USING                                                  ;IF SO, USE A SPECIAL HANDLER
  CP TK_TAB			      ; "TAB(" token?                     
  JP Z,__TAB		      ; Yes - Do TAB routine              ;THE TAB FUNCTION?
  CP TK_SPC			      ; "SPC(" token?                     
  JP Z,__TAB		      ; Yes - Do SPC routine              ;THE SPC FUNCTION?
  PUSH HL                 ; Save code string address          ;SAVE THE TEXT POINTER
  CP ','                  ; Comma?                            ;IS IT A COMMA?
  JR Z,DOCOM              ; Yes - Move to next zone
  CP ';'                  ; Semi-colon?                       ;IS IT A ";"
  JP Z,NEXITM		      ; Do semi-colon routine
  POP BC                  ; Code string address to BC         ;GET RID OF OLD TEXT POINTER
  CALL EVAL               ; Evaluate expression               ;EVALUATE THE FORMULA
  PUSH HL                 ; Save code string address          ;SAVE TEXT POINTER
  RST GETYPR 		      ; Get the number type (FAC)         ;SEE IF WE HAVE A STRING
  JR Z,PRNTST		      ; JP If string type                 ;IF SO, PRINT SPECIALY
  CALL FOUT               ; Convert number to text            ;MAKE A NUMBER INTO A STRING
  CALL CRTST              ; Create temporary string           ;MAKE IT  A STRING
  LD (HL),' '             ; Followed by a space               ;PUT A SPACE AT THE END
  LD HL,(FACLOW)          ; Get length of output              ;AND INCREASE SIZE BY 1
  INC (HL)                ; Plus 1 for the space              ;SIZE BYTE IS FIRST IN DESCRIPTOR

; Output string contents (a.k.a. STRDON)
; USE FOLDING FOR STRINGS AND #S
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HPRTF			; Hook 1 for "PRINT"
ENDIF
  CALL ISFLIO           ;DISK OUTPUT?  IF SO, DON'T EVER FORCE A CRLF
  JR NZ,PRNTNB
  LD HL,(FACLOW)        ;GET THE POINTER
  LD A,(PRTFLG)         
  OR A                  
  JR Z,ISTTY            ;LPT OR TTY?
  LD A,(LPTPOS)         ;GET WIDTH OF PRINTER
  ADD A,(HL)
  CP $FF                ;IS IT INFINITE? (255="infinite")
  JR LINCH2             ;THEN JUST PRINT

ISTTY:
  LD A,(LINLEN)           ; Get width of line
  LD B,A                  ; To B
  LD A,(TTYPOS)           ; Get cursor position
  ADD A,(HL)              ; Add length of string
  DEC A                   ; Adjust it
  CP B                    ; Will output fit on this line?
LINCH2:                  
  JR C,PRNTNB             ; START ON A NEW LINE
  CALL Z,CRFIN            ; No - CRLF first
  CALL NZ,OUTDO_CRLF
PRNTNB:
  CALL PRS1               ; Output string at (HL)
  OR A                    ; Skip CALL by resetting "Z" flag

; Output string contents (a.k.a. STRDON)
; USE FOLDING FOR STRINGS AND #S
;
; Used by the routine at __PRINT.
PRNTST:
  CALL Z,PRS1             ; Output string at (HL)
  POP HL                  ; Restore code string address
  JP MRPRNT               ; See if more to PRINT

; "," found in PRINT list
DOCOM:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HCOMP			; Hook 2 for "PRINT" (comma found in PRINT command)
ENDIF
  LD BC,$0008         ;(NMLO.C) if file output, SPECIAL PRINT POSITION SHOULD BE FETCHED FROM FILE DATA
  LD HL,(PTRFIL)
  ADD HL,BC           ;[H,L] POINT AT POSITION..
  CALL ISFLIO         ;OUTPUTING INTO A FILE?
  LD A,(HL)           ;IF FILE IS ACTIVE
  JR NZ,ZONELP
  LD A,(PRTFLG)       ;OUTPUT TO THE LINE PRINTER?
  OR A                ;NON-ZERO MEANS YES
  JR Z,ISCTTY         ;NO, DO TELETYPE COMMA
  LD A,(LPTPOS)       ;OUTPUT TO THE LINE PRINTER?
  CP $EE              ;CHECK IF MAX COMMA FIELDS
  JR CHKCOM           ;USE TELETYPE CHECK
  
ISCTTY:
  LD A,(CLMLST)			;Column space, POSITION BEYOND WHICH THERE ARE NO MORE COMMA FIELDS
  LD B,A
  LD A,(TTYPOS)         ;GET TELETYPE POSITION
  CP B
CHKCOM:
  CALL NC,OUTDO_CRLF    ;TYPE CRLF
  JP NC,NEXITM          ;AND QUIT IF BEYOND THE LAST COMMA FIELD

; a.k.a MORCOM
ZONELP:
  SUB CLMWID        ; Next zone of 14 characters
  JR NC,ZONELP      ; Repeat if more zones
  CPL               ; Number of spaces to output
                    ; WE WANT TO  FILL THE PRINT POSITION OUT TO AN EVEN CLMWID,
                    ; SO WE PRINT CLMWID-[A] MOD CLMWID SPACES
  JR ASPCS          ; Output them                 ;GO PRINT [A]+1 SPACES

  
; __TAB(   &   __SPC(
__TAB:
  PUSH AF           ; Save token                  ;REMEMBER IF [A]=SPCTK OR TABTK
  CALL FNDNUM		; Numeric argument (0..255)   ;EVALUATE THE ARGUMENT
  RST SYNCHR 		; Make sure ")" follows
  DEFB ')'
  DEC HL			; Back space on to ")"
  POP AF			; Restore token               ;SEE IF ITS SPC OR TAB
  SUB TK_SPC		; Was it "SPC(" ?             ;IF SPACE LEAVE ALONE
  PUSH HL			; Save code string address
  JR Z,DOSPC		; Yes - Do "E" spaces

; TAB(
  LD BC,$0008       ;(NMLO.C) if file output, SPECIAL PRINT POSITION SHOULD BE FETCHED FROM FILE DATA
  LD HL,(PTRFIL)
  ADD HL,BC         ;[H,L] POINT AT POSITION
  CALL ISFLIO       ;OUTPUTING INTO A FILE?  (IF SO, [PTRFIL] .NE. 0)
  LD A,(HL)         ;IF FILE IS ACTIVE
  JR NZ,DOSPC       ;DO TAB CALCULATION NOW
  LD A,(PRTFLG)     ;LINE PRINTER OR TTY?
  OR A              ;NON-ZERO MEANS LPT
  JP Z,TTYIST
  LD A,(LPTPOS)     ; Get current printer position     ;GET LINE PRINTER POSITION
  JR DOSPC          ;GET THE LINE LENGTH

TTYIST:
  LD A,(TTYPOS)    ; Get current position        ;GET TELETYPE PRINT POSITION

; SPC(
DOSPC:
  CPL              ; Number of spaces to print to    ;PRINT [E]-[A] SPACES
  ADD A,E          ; Total number to print
  JR NC,NEXITM     ; TAB < Current POS(X)
ASPCS:
  INC A            ; Output A spaces
  LD B,A           ; Save number to print            ;[B]=NUMBER OF SPACES TO PRINT
  LD A,' '         ; Space                           ;[A]=SPACE
SPCLP:           
  RST OUTDO  		; Output character in A          ;PRINT [A]
  DJNZ SPCLP        ; Repeat if more                 ;DECREMENT THE COUNT
                    
; Move to next item in the PRINT list
NEXITM:            
  POP HL           ; Restore code string address       ;PICK UP TEXT POINTER
  RST CHRGTB		; Get next character               ;AND THE NEXT CHARACTER
  ;AND SINCE WE JUST PRINTED SPACES, DON'T CALL CRDO IF IT'S THE END OF THE LINE
  JP PRNTLP        ; More to print

; This entry point is used by the routines at LTSTND, L61C4 and L628E.
;
;FINISH 'PRINT' BY RESETTING FLAGS
;(IN WHICH CASE A TERMINATOR DOES NOT MEAN WE SHOULD TYPE A CRLF BUT JUST RETURN)
FINPRT:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HFINP			; Hook 3 for "PRINT"
ENDIF
  XOR A
  LD (PRTFLG),A
  PUSH HL               ;SAVE THE TEXT POINTER
  LD H,A                ;[H,L]=0
  LD L,A
  LD (PTRFIL),HL		;ZERO OUT PTRFIL  (disabling eventual output redirection)
  POP HL                ;GET BACK THE TEXT POINTER
  RET

; Routine at 19214
__LINE:
  CP TK_INPUT		; ? Token for INPUT to support the "LINE INPUT" statement ?
  JP NZ,LINE		; No, this is a real graphics command !
  
  ; LINE INPUT
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB TK_INPUT
  CP '#'                ;SEE IF THERE IS A FILE NUMBER
  JP Z,LINE_INPUT       ;DO DISK INPUT LINE
  CALL __INPUT_0        ;PRINT QUOTED STRING IF ONE
  CALL GETVAR           ;READ STRING TO STORE INTO
  CALL TSTSTR           ;MAKE SURE ITS A STRING
  PUSH DE               ;SAVE POINTER AT VARIABLE
  PUSH HL               ;SAVE TEXT POINTER
  CALL INLIN            ;READ A LINE OF INPUT
  POP DE                ;GET TEXT POINTER
  POP BC                ;GET POINTER AT VARIABLE
  JP C,INPBRK           ;IF CONTROL-C, STOP
  PUSH BC               ;SAVE BACK VARIABLE POINTER
  PUSH DE               ;SAVE TEXT POINTER
  LD B,$00              ;SETUP ZERO AS ONLY TERMINATOR
  CALL QTSTR_0          ;LITERALIZE THE INPUT
  POP HL                ;RESTORE [H,L]=TEXT POINTER
  LD A,$03              ;SET THREE FOR STRING
  JP __LET_0            ;DO THE ASSIGNMENT

; Message at 19259
REDO_MSG:
  DEFM "?Redo from start"
  DEFB CR, LF, $00

;
; a.k.a. BADINP
; HERE WHEN PASSING OVER STRING LITERAL IN SUBSCRIPT OF VARIABLE IN INPUT LIST
; ON THE FIRST PASS OF INPUT CHECKING FOR TYPE MATCH AND NUMBER
;
; This entry point is used by the routine at LTSTND.
SCNSTR:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HTRMN			; Hook for "READ/INPUT" error
ENDIF
  LD A,(FLGINP)         ;WAS IT READ OR INPUT?
  OR A                  ;ZERO=INPUT
  JP NZ,DATSNR          ;GIVE ERROR AT DATA LINE
  POP BC                 ;GET RID OF THE POINTER INTO THE VARIABLE LIST
  LD HL,REDO_MSG
  CALL PRS              ;PRINT "?REDO FROM START" TO NEWSTT POINTING AT THE START OF
  LD HL,(SAVTXT)        ;START ALL OVER: GET SAVED TEXT POINTER
  RET                   ;GO BACK TO NEWSTT

; Routine at 19298
; INPUT #, set stream number (input channel)
; "set input channel"
;
; Used by the routine at __INPUT.
FILSTI:		; deal with '#' argument
  CALL FILINP		; Get stream number (default #channel=1)
  PUSH HL               ;PUT THE TEXT POINTER ON THE STACK
  LD HL,BUFMIN          ;POINT AT A COMMA
  JP INPUT_CHANNEL		; 'INPUT' from a stream

; Routine at 19308
__INPUT:
  CP '#'
  JR Z,FILSTI		; "set input channel"
  PUSH HL
  PUSH AF
  CALL TOTEXT
  POP AF
  POP HL
  LD BC,NOTQTI      ;WHERE TO GO
  PUSH BC           ;WHEN DONE WITH QUOTED STRING

; This entry point is used by the routine at __LINE.
__INPUT_0:
  CP '"'        	; Is there a prompt string?    ;IS IT A QUOTE?
  LD A,$00      	; Clear A and leave flags      ;BE TALKATIVE
  RET NZ            ; not a quote.. JUST RETURN
  CALL QTSTR		; MAKE THE MESSAGE A STRING
  RST SYNCHR 		; Check for ";" after prompt
  DEFB ';'          ; MUST END WITH SEMI-COLON
  PUSH HL           ; Save code string address     ;REMEMBER WHERE IT ENDED
  CALL PRS1         ; Output prompt string
  POP HL            ; Restore code string address  ;GET BACK SAVED TEXT PTR
  RET               ;ALL DONE

; Routine at 19339
NOTQTI:
  PUSH HL
  CALL QINLIN       ; User interaction with question mark, HL = resulting text 
  POP BC            ; Restore code string address      ;TAKE OFF SINCE MAYBE LEAVING
  JP C,INPBRK                                          ;IF EMPTY LEAVE
  INC HL
  LD A,(HL)
  OR A
  DEC HL
  PUSH BC           ; Re-save code string address      ;PUT BACK SINCE DIDN'T LEAVE
;
; THIS IS THE FIRST PASS DICTATED BY ANSI REQUIRMENT THAN NO VALUES BE ASSIGNED 
; BEFORE CHECKING TYPE AND NUMBER. THE VARIABLE LIST IS SCANNED WITHOUT EVALUATING
; SUBSCRIPTS AND THE INPUT IS SCANNED TO GET ITS TYPE. NO ASSIGNMENT IS DONE
;
  JP Z,NXTDTA		; just before '__DATA"


; This entry point is used by the routine at FILSTI.
; 'INPUT' from a stream
INPUT_CHANNEL:
  LD (HL),','         ;SETUP COMMA AT BUFMIN
  JR INPCON

; Routine at 19359
__READ:
  PUSH HL               ; Save code string address       ;SAVE THE TEXT POINTER
  LD HL,(DATPTR)        ; Next DATA statement            ;GET LAST DATA LOCATION
                                                      
  DEFB $F6				; OR AFh ..Flag "READ"           ;"ORI" TO SET [A] NON-ZERO

INPCON:
  XOR A					; Flag "INPUT"                   ;SET FLAG THAT THIS IS AN INPUT
  LD (FLGINP),A			; Save "READ"/"INPUT" flag       ;STORE THE FLAG
;
; IN THE PROCESSING OF DATA AND READ STATEMENTS:
; ONE POINTER POINTS TO THE DATA (IE THE NUMBERS BEING FETCHED)
; AND ANOTHER POINTS TO THE LIST OF VARIABLES
;
; THE POINTER INTO THE DATA ALWAYS STARTS POINTING TO A
; TERMINATOR -- A , : OR END-OF-LINE
;
  EX (SP),HL			; Get code str' , Save pointer   ;[H,L]=VARIABLE LIST POINTER <> DATA POINTER GOES ON THE STACK
  
  DEFB $01	; "LD BC,nn" to jump over the next word without executing it

LOPDT2:
  RST SYNCHR			; Check for comma between items
  DEFB ','              ; MAKE SURE THERE IS A ","

; a.k.a. LOPDAT
;GTVLUS:  <-  the 'DEFB' trick above makes this jump unnecessary
  CALL GETVAR           ;READ THE VARIABLE LIST AND GET THE POINTER TO A VARIABLE INTO [D,E]
                        ;PUT THE VARIABLE LIST POINTER ONTO THE STACK AND TAKE THE DATA LIST POINTER OFF
  EX (SP),HL
;
; NOTE AT THIS POINT WE HAVE A VARIABLE WHICH WANTS DATA
; AND SO WE MUST GET DATA OR COMPLAIN
;
  PUSH DE               ; SAVE THE POINTER TO THE VARIABLE WE ARE ABOUT TO SET UP WITH A VALUE
  ;SINCE THE DATA LIST POINTER ALWAYS POINTS AT A TERMINATOR LETS READ THE TERMINATOR INTO [A] AND SEE WHAT IT IS
  LD A,(HL)
  CP ','				; Comma?
  JR Z,SCNVAL			; Yes - Get another value       ;A COMMA SO A VALUE MUST FOLLOW
  LD A,(FLGINP)         ; Is it READ?                   ;SEE WHAT TYPE OF STATEMENT THIS WAS
  OR A                  
  JP NZ,FDTLP           ; Yes - Find next DATA stmt     ;SEARCH FOR ANOTHER DATA STATEMENT

  LD A,'?'              ; More INPUT needed
  RST OUTDO				; Output character
  CALL QINLIN			; Get INPUT with prompt, HL = resulting text 
  POP DE
  POP BC
  JP C,INPBRK
  INC HL
  LD A,(HL)
  DEC HL
  OR A
  PUSH BC
  JP Z,NXTDTA		; just before '__DATA"
  PUSH DE

; This entry point is used by the routine at FDTLP.
SCNVAL:
  CALL ISFLIO       ; SEE IF A FILE READ
  JP NZ,FILIND      ; IF SO, SPECIAL HANDLING
  RST GETYPR 		; IS IT A STRING?
  PUSH AF           ; SAVE THE TYPE INFORMATION
;
; IF NUMERIC, USE FIN TO GET IT
; ONLY THE VARAIBLE TYPE IS CHECKED SO AN UNQUOTED STRING CAN BE ALL DIGITS
;
  JR NZ,INPBIN	    ; If numeric, convert to binary
  RST CHRGTB		; Gets next character
  LD D,A            ; Save input character               ;ASSUME QUOTED STRING
  LD B,A            ; Again                              ;SETUP TERMINATORS
  CP '"'            ; Start of literal sting?            ;QUOTE ?
  JR Z,STRENT       ; Yes - Create string entry          ;TERMINATORS OK
  LD A,(FLGINP)     ; "READ" or "INPUT" ?                ;INPUT SHOULDN'T TERMINATE ON ":"
  OR A                                                   ;SEE IF READ OR INPUT
  LD D,A            ; Save 00 if "INPUT"                 ;SET D TO ZERO FOR INPUT
  JR Z,ITMSEP       ; "INPUT" - End with 00
  LD D,':'          ; "DATA" - End with 00 or ":"        ;UNQUOTED STRING TERMINATORS
ITMSEP:
  LD B,','          ; Item separator
                    ; NOTE: ANSI USES [B]=44 AS A FLAG TO TRIGGER TRAILING SPACE SUPPRESSION

  DEC HL            ; Back space for DTSTR
                    ; BACKUP SINCE START CHARACTER MUST BE INCLUDED
                    ; IN THE QUOTED STRING CASE WE DON'T WANT TO
                    ; INCLUDE THE STARTING OR ENDING QUOTE

; a.k.a. NOWGET
STRENT:
  ;MAKE A STRING DESCRIPTOR FOR THE VALUE AND COPY IF NECESSARY
  CALL DTSTR           ; Get string terminated by D

DOASIG:
  POP AF               ;POP OFF THE TYPE INFORMATION
  ADD A,$03            ;MAKE VALTYPE CORRECT
  EX DE,HL             ;[D,E]=TEXT POINTER
  LD HL,LTSTND         ;RETURN LOC
  EX (SP),HL           ;[H,L]=PLACE TO STORE VARIABLE VALUE
  PUSH DE              ;TEXT POINTER GOES ON
  JP __LET_1           ;DO ASSIGNMENT

; a.k.a. NUMINS
INPBIN:
  RST CHRGTB           ; Gets next character (or token) from BASIC text.
  LD BC,DOASIG         ; ASSIGNMENT IS COMPLICATED EVEN FOR NUMERICS SO USE THE "LET" CODE
  PUSH BC              ; SAVE ON STACK
  JP FIN_DBL           ; ELSE CALL SPECIAL ROUTINE WHICH EXPECTS DOUBLES

; Routine at 19461
LTSTND:
  DEC HL               ; DEC 'cos GETCHR INCs
  RST CHRGTB		   ; Get next character
  JR Z,MORDT           ; End of line - More needed?
  CP ','               ; Another value?
  JP NZ,SCNSTR         ; No - Bad input           ;ENDED PROPERLY?
MORDT:              
  EX (SP),HL           ; Get code string address
  DEC HL               ; DEC 'cos GETCHR INCs     ;LOOK AT TERMINATOR
  RST CHRGTB           ; Get next character       ;AND SET UP CONDITION CODES
  JP NZ,LOPDT2         ; More needed - Get it     ;NOT ENDING, CHECK FOR COMMA AND GET
                                                  ;ANOTHER VARIABLE TO FILL WITH DATA
  POP DE               ; Restore DATA pointer     ;POP OFF THE POINTER INTO DATA
  LD A,(FLGINP)        ; "READ" or "INPUT" ?      ;FETCH THE STATEMENT TYPE FLAG
  OR A
				;INPUT STATEMENT
  EX DE,HL             ; DATA pointer to HL
  JP NZ,UPDATA         ; Update DATA pointer if "READ"        ;UPDATE DATPTR
  PUSH DE              ; Save code string address             ;SAVE THE TEXT POINTER
  CALL ISFLIO          ; Tests if I/O to device is taking place
  JR NZ,LTSTND_1
  LD A,(HL)
  OR A
  LD HL,EXTRA_MSG		; "?Extra ignored"
  CALL NZ,PRS
LTSTND_1:
  POP HL               ; Restore code string address          ;GET BACK THE TEXT POINTER
  JP FINPRT

; Data block at 19503
EXTRA_MSG:
  DEFM "?Extra ignored"
  DEFB CR, LF, $00

  
; Find next DATA statement
;
; THE SEARCH FOR DATA STATMENTS IS MADE BY USING THE EXECUTION CODE
; FOR DATA TO SKIP OVER STATEMENTS. THE START WORD OF EACH STATEMENT
; IS COMPARED WITH $DATA. EACH NEW LINE NUMBER
; IS STORED IN DATLIN SO THAT IF AN ERROR OCCURS WHILE READING
; DATA THE ERROR MESSAGE WILL GIVE THE LINE NUMBER OF THE 
; ILL-FORMATTED DATA
;
; a.k.a. DATLOP
; Used by the routine at __READ.
FDTLP:
  CALL __DATA      ; Get next statement
  OR A             ; End of line?
  JR NZ,FANDT      ; No - See if DATA statement
  INC HL
  LD A,(HL)        ; End of program?
  INC HL
  OR (HL)          ; 00 00 Ends program
  LD E,$04         ; Err $04 - "Out of DATA" (?OD Error)    ;NO DATA IS ERROR ERROD
  JP Z,ERROR       ; Yes - Out of DATA                      ;IF SO COMPLAIN
  INC HL                                                    ;SKIP PAST LINE #
  LD E,(HL)        ; LSB of line number                     ;GET DATA LINE #
  INC HL
  LD D,(HL)        ; MSB of line number
  LD (DATLIN),DE   ; Set line of current DATA item
FANDT:
  RST CHRGTB       ; Get next character                     ;GET THE STATEMENT TYPE
  CP TK_DATA       ; TK_DATA, "DATA" token                  ;IS IS "DATA"?
  JR NZ,FDTLP      ; No "DATA" - Keep looking               ;NOT DATA SO LOOK SOME MORE
  JP SCNVAL        ; Found - Convert input                  ;CONTINUE READING


  ; --- START PROC L4C5F ---
;
;	FORMULA EVALUATION CODE
;
; THE FORMULA EVALUATOR STARTS WITH [H,L] POINTING TO THE FIRST CHARACTER OF THE FORMULA.
; AT THE END [H,L] POINTS TO THE TERMINATOR.
; THE RESULT IS LEFT IN THE FAC.
; ON RETURN [A] DOES NOT REFLECT THE TERMINATING CHARACTER
;
; THE FORMULA EVALUATOR USES THE OPERATOR TABLE (OPTAB) TO DETERMINE
; PRECEDENCE AND DISPATCH ADDRESSES FOR EACH OPERATOR.
;
; A TEMPORARY RESULT ON THE STACK HAS THE FOLLOWING FORMAT:
; - THE ADDRESS OF 'RETAOP' -- THE PLACE TO RETURN ON COMPLETION OF OPERATOR APPLICATION
; - THE FLOATING POINT TEMPORARY RESULT
; - THE ADDRESS OF THE OPERATOR ROUNTINE
; - THE PRECEDENCE OF THE OPERATOR
;
; TOTAL 10 BYTES
;
FRMEQL:
  RST SYNCHR       ;   Check syntax: next byte holds the byte to be found
  DEFB TK_EQUAL    ; Token for '='          ;CHECK FOR EQUAL SIGN
                                            ;EVALUATE FORMULA AND RETURN
  DEFB 1           ; "LD BC,n" to mask the next 2 lines

; Chk Syntax, make sure '(' follows
OPNPAR:
  RST SYNCHR       ; Make sure "(" follows
  DEFB '('         ;GET PAREN BEFORE FORMULA

  ; --- START PROC L4C64 ---
; Evaluate expression
;
; Used by the routines at __LET, __IF, DOFN, INTIDX, FNDNUM, GETWORD, __CIRCLE,
; CGTCNT, L61C4, FN_STRING, FN_INSTR, NAMSCN, BSAVE_PARM, __BASE and __VPOKE.
; a.k.a. GETNUM, evaluate expression
EVAL:
  DEC HL           ; Evaluate expression & save      ;BACK UP CHARACTER POINTER
  
; This entry point is used by the routine at USING.
; a.k.a. LPOPER
EVAL_0:
  LD D,$00              ; Precedence value           ;INITIAL DUMMY PRECEDENCE IS 0

; Save precedence and eval until precedence break
;
; Used by the routines at EVAL, OPRND and NOT.
EVAL_1:
  PUSH DE               ; Save precedence                     ;SAVE PRECEDENCE
  LD C,$01              ; Check for 1 level of stack          ;EXTRA SPACE NEEDED FOR RETURN ADDRESS
  CALL CHKSTK                                                 ;MAKE SURE THERE IS ROOM FOR RECURSIVE CALLS
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HFRME			; Hook 1 for Expression evaluator
ENDIF
  CALL OPRND            ; Get next expression value           ;EVALUATE SOMETHING

; Evaluate expression until precedence break
;
EVAL2:
  LD (NXTOPR),HL			; Save address of next operator

;
; Used by the routine at NOT.
EVAL3:
  LD HL,(NXTOPR)			; Restore address of next opr
  POP BC                    ; Precedence value and operator           ;POP OFF THE PRECEDENCE OF OLDOP
  LD A,(HL)                 ; Get next operator / function            ;GET NEXT CHARACTER
  LD (TEMP3),HL                                                       ;SAVE UPDATED CHARACTER POINTER
  CP TK_GREATER				; Token code for '>' (lower opr code)     ;IS IT AN OPERATOR?
  RET C               ; NO, ALL DONE (THIS CAN RESULT IN OPERATOR APPLICATION OR ACTUAL RETURN)                     
  CP TK_MINOR+1             ; '<' +1  (higher opr code)               ;SOME KIND OF RELATIONAL?
  JR C,DORELS                                                         ;YES, DO IT
  SUB TK_PLUS				; TK_PLUS, token code for '+'             ;SUBTRAXDCT OFFSET FOR FIRST ARITHMETIC
  LD E,A					; Coded operator                          ;MUST MULTIPLY BY 3 SINCE OPTAB ENTRIES ARE 3 LONG
  JR NZ,FOPRND                                                        ;NOT ADDITION OP

  LD A,(VALTYP)				; Get data type                           ;SEE IF LEFT PART IS STRING
  CP $03					; String ?                                ;SEE IF ITS A STRING
  LD A,E					; Coded operator                          ;REFETCH OP-VALUE
  JP Z,CONCAT				; If so, string concatenation (use '+' to join strings)
FOPRND:
  CP LSTOPK                 ; HIGHER THAN THE LAST OP?                ;HIGHER THAN THE LAST OP?
  RET NC                                                              ;YES, MUST BE TERMINATOR
  LD HL,PRITAB              ; ARITHMETIC PRECEDENCE TABLE             ;CREATE INDEX INTO OPTAB
  LD D,$00                                                            ;MAKE HIGH BYTE OF OFFSET=0
  ADD HL,DE                 ; To the operator concerned               ;ADD IN CALCULATED OFFSET
  LD A,B                    ; Last operator precedence                ;[A] GETS OLD PRECEDENCE
  LD D,(HL)                 ; Get evaluation precedence               ;REMEMBER NEW PRECEDENCE
  CP D                      ; Compare with eval precedence            ;OLD-NEW
  RET NC                    ; Exit if higher precedence               ;MUST APPLY OLD OP
		;IF HAS GREATER OR = PRECEDENCE, NEW OPERATOR
  PUSH BC                   ; Save last precedence & token            ;SAVE THE OLD PRECEDENCE
  LD BC,EVAL3               ; Where to go on prec' break              ;PUT ON THE ADDRESS OF THE
  PUSH BC                   ; Save on stack for return                ;PLACE TO RETURN TO AFTER OPERATOR APPLICATION
  LD A,D                                                              ;SEE IF THE OPERATOR IS EXPONENTIATION
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HNTPL			; Hook 2 for Expression Evaluator
ENDIF
  CP $51				; one less than AND as mapped in PRITAB     ;SEE IF THE OPERATOR IS "AND" OR "OR"
  JR C,EVAL_BOOL	                                                ;AND IF SO "FRCINT" AND MAKE A SPECIAL STACK ENTRY
  AND $FE	                                                        ;MAKE 123 AND 122 BOTH MAP TO 122
  CP $7A				; MOD as mapped in PRITAB                   ;MAKE A SPECIAL CHECK FOR "MOD" AND "IDIV"
  JR Z,EVAL_BOOL	                                                ;IF SO, COERCE ARGUMENTS TO INTEGER

; THIS CODE PUSHES THE CURRENT VALUE IN THE FAC
; ONTO THE STACK, EXCEPT IN THE CASE OF STRINGS IN WHICH IT CALLS
; TYPE MISMATCH ERROR. [D] AND [E] ARE PRESERVED.
;
EVAL_NUMERIC:
  LD HL,FACLOW          ;SAVE THE VALUE OF THE FAC
  LD A,(VALTYP)         ;FIND OUT WHAT TYPE OF VALUE WE ARE SAVING
  SUB $03				; String ?   SET ZERO FOR STRINGS
  JP Z,TM_ERR			; Err $0D - "Type mismatch"
  OR A                  ;SET PARITY -- CARRY UNAFFECTED SINCE OFF
  
  LD HL,(FACLOW)
  PUSH HL               ;PUSH FACLO+0,1 ON THE STACK
  JP M,EVAL_NEXT        ;ALL DONE IF THE DATA WAS AN INTEGER  (Stack this one and get next)
  
  LD HL,(FACCU)
  PUSH HL               ;PUSH FAC-1,0 ON THE STACK
  JP PO,EVAL_NEXT       ;ALL DONE IF WE HAD A SNG  (Stack this one and get next)
  
  LD HL,(FACCU+6)       ;WE HAVE A DOUBLE PRECISON NUMBER
  PUSH HL               ;PUSH ITS 4 LO BYTES ON THE STACK
  LD HL,(FACCU+4)
  PUSH HL

;a.k.a. VPUSHD
EVAL_NEXT:
  ADD A,$03             ; FIX [A] TO BE THE VALTYP OF THE NUMBER JUST PUSHED ON THE STACK
  LD C,E                ; [C]=OPERATOR NUMBER
  LD B,A                ; [B]=TYPE OF VALUE ON THE STACK
  PUSH BC               ; SAVE THESE THINGS FOR APPLOP
  LD BC,APPLOP          ; GENERAL OPERATOR APPLICATION ROUTINE -- DOES TYPE CONVERSIONS
  
;a.k.a. FINTMP
EVAL_MORE:
  PUSH BC               ; Save routine address              ;SAVE PLACE TO GO
  LD HL,(TEMP3)         ; Address of current operator       ;REGET THE TEXT POINTER
  JP EVAL_1              ; Loop until prec' break            ;PUSH ON THE PRECEDENCE AND READ MORE FORMULA


; This entry point is used by the routine at EVAL3.
DORELS:
  LD D,$00       ;ASSUME NO RELATION OPS, ALSO SETUP THE HIGH ORDER OF THE INDEX INTO OPTAB
LOPREL:
  SUB TK_GREATER                ;IS THIS ONE RELATION?
  JR C,FINREL                   ;RELATIONS ALL THROUGH
  CP TK_MINOR-TK_GREATER+1      ;IS IT REALLY RELATIONAL?
  JR NC,FINREL                  ;NO JUST BIG
  CP 1                          ;SET UP BITS BY MAPPING
  RLA                           ;0 TO 1 1 TO 2 AND 2 TO 4
  XOR D                         ;BRING IN THE OLD BITS
  CP D                          ;MAKE SURE RESULT IS BIGGER
  LD D,A                        ;SAVE THE MASK
  JP C,SN_ERR                   ;DON'T ALLOW TWO OF THE SAME
  LD (TEMP3),HL                 ;SAVE CHARACTER POINTER
  RST CHRGTB                    ;GET THE NEXT CANDIDATE
  JR LOPREL

;
; FOR "AND" AND "OR" AND "\" AND "MOD" WE WANT TO FORCE THE CURRENT VALUE
; IN THE FAC TO BE AN INTEGER, AND AT APPLICATION TIME FORCE THE RIGHT
; HAND OPERAND TO BE AN INTEGER
;
EVAL_BOOL:
  PUSH DE                       ;SAVE THE PRECEDENCE
  CALL __CINT                   
  POP DE                        ;[D]=PRECEDENCE
  PUSH HL                       ;PUSH THE LEFT HAND OPERAND
  LD BC,DANDOR                  ;"AND" AND "OR" DOER
  JR EVAL_MORE                  ;PUSH ON THIS ADDRESS,PRECEDENCE AND CONTINUE EVALUATION

;
; HERE TO BUILD AN ENTRY FOR A RELATIONAL OPERATOR
; STRINGS ARE TREATED SPECIALLY. NUMERIC COMPARES ARE DIFFERENT
; FROM MOST OPERATOR ENTRIES ONLY IN THE FACT THAT AT THE
; BOTTOM INSTEAD OF HAVING RETAOP, DOCMP AND THE RELATIONAL
; BITS ARE STORED. STRINGS HAVE STRCMP,THE POINTER AT THE STRING DESCRIPTOR,
; DOCMP AND THE RELATIONAL BITS.
;
FINREL:
  LD A,B                    ;[A]=OLD PRECEDENCE
  CP 100                    ;RELATIONALS HAVE PRECEDENCE 100
  RET NC                    ;APPLY EARLIER OPERATOR IF IT HAS HIGHER PRECEDENCE
  PUSH BC                   ;SAVE THE OLD PRECEDENCE
  PUSH DE                   ;SAVE [D]=RELATIONAL BITS
  LD DE,100*256+OPCNT       ;[D]=PRECEDENCE=100
                            ;[E]=DISPATCH OFFSET FOR COMPARES IN APPLOP=4
                            ;IN CASE THIS IS A NUMERIC COMPARE
  LD HL,DOCMP               ;ROUTINE TO TAKE COMPARE ROUTINE RESULT
                            ;AND RELATIONAL BITS AND RETURN THE ANSWER
  PUSH HL                   ;DOES A JMP TO RETAOP WHEN DONE
  RST GETYPR                ;SEE IF WE HAVE A NUMERIC COMPARE
  JP NZ,EVAL_NUMERIC        ;YES, BUILD AN APPLOP ENTRY
  LD HL,(FACLOW)            ;GET THE POINTER AT THE STRING DESCRIPTOR
  PUSH HL                   ;SAVE IT FOR STRCMP
  LD BC,STRCMP              ;STRING COMPARE ROUTINE
  JR EVAL_MORE              ;PUSH THE ADDRESS, REGET THE TEXT POINTER
                            ;SAVE THE PRECEDENCE AND SCAN
                            ;MORE OF THE FORMULA

; Code at 19746
;
; APPLOP IS RETURNED TO WHEN IT IS TIME TO APPLY AN ARITHMETIC
; OR NUMERIC COMPARISON OPERATION.
; THE STACK HAS A DOUBLE BYTE ENTRY WITH THE OPERATOR
; NUMBER AND THE VALTYP OF THE VALUE ON THE STACK.
; APPLOP DECIDES WHAT VALUE LEVEL THE OPERATION
; WILL OCCUR AT, AND CONVERTS THE ARGUMENTS. APPLOP
; USES DIFFERENT CALLING CONVENTIONS FOR EACH VALUE TYPE.
; INTEGERS: LEFT IN [D,E] RIGHT IN [H,L]
; SINGLES:  LEFT IN [B,C,D,E] RIGHT IN THE FAC
; DOUBLES:  LEFT IN FAC   RIGHT IN ARG
;
APPLOP:
  POP BC                    ;[B]=STACK OPERAND VALUE TYPE  [C]=OPERATOR OFFSET
  LD A,C                    ;SAVE IN MEMORY SINCE THE STACK WILL BE BUSY
  LD (OPRTYP),A             ;A RAM LOCATION
  LD A,(VALTYP)             ;GET VALTYP OF FAC
  CP B                      ;ARE VALTYPES THE SAME?
  JR NZ,VALNSM              ;NO
  CP $02                    ;INTEGER?
  JR Z,INTDPC               ;YES, DISPATCH!!
  CP $04                    ;SINGLE?
  JP Z,SNGDPC               ;YES, DISPATCH!!
  JR NC,DBLDPC              ;MUST BE DOUBLE, DISPATCH!!
VALNSM:
  LD D,A                    ;SAVE IN [D]
  LD A,B                    ;CHECK FOR DOUBLE
  CP $08                    ;PRECISION ENTRY ON THE STACK
  JR Z,STKDBL               ;FORCE FAC TO DOUBLE
  LD A,D                    ;GET VALTYPE OF FAC
  CP $08                    ;AND IF SO, CONVERT THE STACK OPERAND
  JR Z,FACDBL               ;TO DOUBLE PRECISION
  LD A,B                    ;SEE IF THE STACK ENTRY IS SINGLE
  CP $04                    ;PRECISION AND IF SO, CONVERT
  JR Z,STKSNG               ;THE FAC TO SINGLE PRECISION
  LD A,D                    ;SEE IF THE FAC IS SINGLE PRECISION
  CP $03                    ;BLOW UP ON RIGHT HAND STRING OPERAND
  JP Z,TM_ERR               ; Err $0D - "Type mismatch"
  JR NC,EVAL_FP             ;AND IF SO CONVERT THE STACK TO SINGLE PRECISION

;NOTE: THE STACK MUST BE INTEGER AT THIS POINT

; Integer VALTYP
INTDPC:
  LD HL,INT_OPR             ;INTEGER INTEGER CASE
  LD B,$00                  ;SPECIAL DISPATCH FOR SPEED
  ADD HL,BC                 ;[H,L] POINTS TO THE ADDRESS TO GO TO 
  ADD HL,BC
  LD C,(HL)                 ;[B,C]=ROUTINE ADDRESS
  INC HL
  LD B,(HL)
  POP DE                    ;[D,E]=LEFT HAND OPERAND
  LD HL,(FACLOW)            ;[H,L]=RIGHT HAND OPERAND
  PUSH BC                   ;DISPATCH
  RET

;
; THE STACK OPERAND IS DOUBLE PRECISION, SO
; THE FAC MUST BE FORCED TO DOUBLE PRECISION, MOVED INTO ARG
; AND THE STACK VALUE POPED INTO THE FAC
;
STKDBL:
  CALL __CDBL               ;MAKE THE FAC DOUBLE PRECISION
DBLDPC:
  CALL VMOVAF               ;POP OFF THE STACK OPERAND INTO THE FAC
  POP HL
  LD (FACCU+4),HL
  POP HL
  LD (FACCU+6),HL           ;STORE LOW BYTES AWAY
SNGDBL:
  POP BC
  POP DE                    ;POP OFF A FOUR BYTE VALUE
  CALL FPBCDE               ;INTO THE FAC
SETDBL:
  CALL __CDBL               ;MAKE SURE THE LEFT OPERAND IS DOUBLE PRECISION
  LD HL,DEC_OPR             ;DISPATCH TO A DOUBLE PRECISION ROUTINE
DODSP:
  LD A,(DORES)              ;RECALL WHICH OPERAND IT WAS
  RLCA                      ;CREATE A DISPATCH OFFSET, SINCE
  ADD A,L                   ;TABLE ADDRESSES ARE TWO BYTES
  LD L,A                    ;ADD LOW BYTE OF ADDRESS
  ADC A,H                   ;SAVE BACK
  SUB L                     ;ADD HIGH BYTE
  LD H,A                    ;SUBTRACT LOW
  LD A,(HL)                 ;RESULT BACK
  INC HL                    ;GET THE ADDRESS
  LD H,(HL)
  LD L,A
  JP (HL)     ;AND PERFORM THE OPERATION, RETURNING TO RETAOP, EXCEPT FOR COMPARES WHICH RETURN TO DOCMP
  
;
; THE FAC IS DOUBLE PRECISION AND THE STACK IS EITHER
; INTEGER OR SINGLE PRECISION AND MUST BE CONVERTED
; 
FACDBL:
  LD A,B
  PUSH AF                   ;SAVE THE STACK VALUE TYPE
  CALL VMOVAF               ;MOVE THE FAC INTO ARG
  POP AF                    ;POP THE STACK VALUE TYPE INTO [A]
  LD (VALTYP),A             ;PUT IT IN VALTYP FOR THE FORCE ROUTINE
  CP $04                    ;SEE IF ITS SINGLE, SO WE KNOW HOW TO POP THE VALUE OFF
  JR Z,SNGDBL               ;IT'S SINGLE PRECISION SO DO A POPR / CALL MOVFR
  POP HL                    ;POP OFF THE INTEGER VALUE
  LD (FACLOW),HL            ;SAVE IT FOR CONVERSION
  JR SETDBL                 ;SET IT UP

;
; THIS IS THE CASE WHERE THE STACK IS SINGLE PRECISION
; AND THE FAC IS EITHER SINGLE PRECISION OR INTEGER
;
STKSNG:
  CALL __CSNG               ;CONVERT THE FAC IF NECESSARY
; Single Precision VALTYP
SNGDPC:
  POP BC                    ;PUT THE LEFT HAND OPERAND IN THE REGISTERS
  POP DE
SNGDO:
  LD HL,FLT_OPR             ;SETUP THE DISPATCH ADDRESS FOR THE SINGLE PRECISION OPERATOR ROUTINES
  JR DODSP                  ;DISPATCH

;
; THIS IS THE CASE WHERE THE FAC IS SINGLE PRECISION AND THE STACK
; IS AN INTEGER. 
;
EVAL_FP:
  POP HL                    ;POP OFF THE INTEGER ON THE STACK
  CALL PUSHF                ;SAVE THE FAC ON THE STACK
  CALL HL_CSNG              ;CONVERT [H,L] TO A SINGLE PRECISION NUMBER IN THE FAC
  CALL BCDEFP               ;PUT THE LEFT HAND OPERAND IN THE REGISTERS
  POP HL                    ;RESTORE THE FAC
  LD (FACCU),HL             ;FROM THE STACK
  POP HL
  LD (FACLOW),HL
  JR SNGDO                  ;PERFORM THE OPERATION

;
; HERE TO DO INTEGER DIVISION. SINCE WE WANT 1/3 TO BE
; .333333 AND NOT ZERO WE HAVE TO FORCE BOTH ARGUMENTS
; TO BE SINGLE-PRECISION FLOATING POINT NUMBERS
; AND USE FDIV
;
; Routine at 19896
IDIV:
  PUSH HL                   ;SAVE THE RIGHT HAND ARGUMENT
  EX DE,HL                  ;[H,L]=LEFT HAND ARGUMENT
  CALL HL_CSNG              ;CONVERT [H,L] TO A SINGLE-PRECISION NUMBER IN THE FAC
  POP HL                    ;GET BACK THE RIGHT HAND ARGUMENT
  CALL PUSHF                ;PUSH THE CONVERTED LEFT HAND ARGUMENT ONTO THE STACK
  CALL HL_CSNG              ;CONVERT THE RIGHT HAND ARGUMENT TO A SINGLE PRECISION NUMBER IN THE FAC
  JP DIVIDE                 ;DO THE DIVISION AFTER POPING INTO THE REGISTERS THE LEFT HAND ARGUMENT


; Routine at 19911
; Get next expression value (a.k.a. "EVAL" !)
; Used by the routines at EVAL_1 and CONCAT.
OPRND:
  RST CHRGTB			; Gets next character (or token) from BASIC text.
  JP Z,MO_ERR			;TEST FOR MISSING OPERAND - IF NONE, Err $18 - "Missing Operand" Error
  JP C,FIN_DBL          ;IF NUMERIC, INTERPRET CONSTANT              If numeric type, create FP number
  CALL ISLETTER_A		;VARIABLE NAME?                              See if a letter
  JP NC,EVAL_VARIABLE   ;AN ALPHABETIC CHARACTER MEANS YES           Letter - Find variable
  CP DBLCON+1           ;IS IT AN EMBEDED CONSTANT
  JP C,_CONFAC          ;RESCAN THE TOKEN & RESTORE OLD TEXT PTR
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HEVAL            ; Hook 1 for Factor Evaluator
ENDIF
  INC A                 ;IS IT A FUNCTION CALL (PRECEDED BY $FF, 377 OCTAL)
  JP Z,ISFUN            ;YES, DO IT
  DEC A                 ;FIX A BACK
  CP TK_PLUS            ;IGNORE "+"
  JR Z,OPRND            ; ..skip it, we will look the digits
  CP TK_MINUS           ;NEGATION?
  JP Z,MINUS            ; Yes - deal with minus sign
  CP '"'                ;STRING CONSTANT?
  JP Z,QTSTR            ;IF SO BUILD A DESCRIPTOR IN A TEMPORARY DESCRIPTOR LOCATION
                        ;AND PUT A POINTER TO THE DESCRIPTOR IN FACLO.
  CP TK_NOT             ;CHECK FOR "NOT" OPERATOR
  JP Z,NOT
  CP '&'                ;OCTAL CONSTANT?
  JP Z,OCTCNS           
  CP TK_ERR             ;'ERR' token ?
  JR NZ,NTERC           ;NO, TRY OTHER POSSIBILITIES

__ERR:
  RST CHRGTB            ;GRAB FOLLOWING CHAR IS IT A DISK ERROR CALL?
  LD A,(ERRFLG)         ;GET THE ERROR CODE. "CPI OVER NEXT BYTE
  PUSH HL               ;SAVE TEXT POINTER
  CALL PASSA            ;RETURN THE VALUE
  POP HL                ;RESTORE TEXT POINTER
  RET                   ;ALL DONE.


NTERC:
  CP TK_ERL             ;ERROR LINE NUMBER VARIABLE
  JR NZ,NTERL           ;NO, TRY MORE THINGS.
  
 __ERL:
  RST CHRGTB            ;GET FOLLOWING CHARACTER
  PUSH HL               ;SAVE TEXT POINTER
  LD HL,(ERRLIN)        ;GET THE OFFENDING LINE #
  CALL INEG2            ;FLOAT 2 BYTE UNSINGED INT
  POP HL                ;RESTORE TEXT POINTER
  RET                   ;RETURN
  
NTERL:
  CP TK_POINT 
  JP Z,FN_POINT
  CP TK_TIME
  JP Z,FN_TIME
  CP TK_SPRITE
  JP Z,FN_SPRITE
  CP TK_VDP
  JP Z,FN_VDP
  CP TK_BASE
  JP Z,FN_BASE
  CP TK_PLAY
  JP Z,FN_PLAY
  CP TK_DSKI
  JP Z,FN_DSKI
  CP TK_ATTR
  JP Z,FN_ATTR

  CP TK_VARPTR          ;VARPTR CALL?
  JR NZ,NTVARP          ;NO
                          	
; 'VARPTR'
  RST CHRGTB            ;EAT CHAR AFTER
  RST SYNCHR            ;EAT LEFT PAREN
  DEFB '('              
  CP '#'                ;WANT POINTER TO FILE?
  JR NZ,NVRFIL          ;NO, MUST BE VARIABLE

; VARPTR(#buffer) Function
;VARPTR_BUF:
  CALL FNDNUM           ;READ FILE #
  PUSH HL               ;SAVE TEXT PTR
  CALL FILIDX           ;GET PTR TO FILE
  EX DE,HL
  POP HL                ;RESTORE TEXT PTR
  JR VARPTR_0
  
NVRFIL:
  CALL PTRGET           ;GET ADDRESS OF VARIABLE

VARPTR_0:
  RST SYNCHR
  DEFB ')'              ;EAT RIGHT PAREN
  PUSH HL               ;SAVE TEXT POINTER
  EX DE,HL              ;GET VALUE TO RETURN IN [H,L]
  LD A,H                ;MAKE SURE NOT UNDEFINED VAR
  OR L                  ;SET CC'S. ZERO IF UNDEF
  JP Z,FC_ERR           ;ALL OVER IF UNDEF (DONT WANT USER POKING INTO ZERO IF HE'S TOO LAZY TO CHECK)
  CALL MAKINT           ;MAKE IT AN INT
  POP HL                ;RESTORE TEXT POINTER
  RET

  
NTVARP:
  CP TK_USR             ;USER ASSEMBLY LANGUAGE ROUTINE??
  JP Z,FN_USR           ;GO HANDLE IT
  CP TK_INSTR           ;IS IT THE INSTR FUNCTION??
  JP Z,FN_INSTR         ;DISPATCH
  CP TK_INKEY_S         ;INKEY$ FUNCTION?
  JP Z,FN_INKEY         ;GO DO IT
  CP TK_STRING          ;STRING FUNCTION?
  JP Z,FN_STRING        ;YES, GO DO IT
  CP TK_INPUT           ;FIXED LENGTH INPUT?
  JP Z,FN_INPUT         ;YES
  CP TK_CSRLIN
  JP Z,FN_CSRLIN
  CP TK_FN              ;USER-DEFINED FUNCTION?
  JP Z,DOFN
					;NUMBERED CHARACTERS ALLOWED
					;SO THERE IS NO NEED TO CHECK
					;THE UPPER BOUND

; End of expression.  Look for ')'.
; ONLY POSSIBILITY LEFT IS A FORMULA IN PARENTHESES
;
; This entry point is used by the routines at ISFUN and FN_USR.
EVLPAR:
  CALL OPNPAR       ; Evaluate expression in "()", RECURSIVELY EVALUATE THE FORMULA
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ')'
  RET
  
; '-', deal with minus sign 
MINUS:		; (a.k.a. "MINUS")
  LD D,$7D				; "-" precedence                   ;A PRECEDENCE BELOW ^
  CALL EVAL_1			; Evaluate until prec' break       ;BUT ABOVE ALL ELSE
  LD HL,(NXTOPR)		; Get next operator address        ;SO ^ GREATER THAN UNARY MINUS
  PUSH HL				; Save next operator address       ;GET TEXT POINTER
  CALL INVSGN			; Negate value


; FUNCTIONS THAT DON'T RETURN STRING VALUES COME BACK HERE (POP HL / RET)
RETNUM:
  POP HL				; Restore next operator address
  RET


; This entry point is used by the routine at SCNVAR.
; EVAL_VARIABLE (a.k.a. CONVAR)
EVAL_VARIABLE:
  CALL GETVAR           ;GET A POINTER TO THE VARIABLE IN [D,E]
COMPTR:
  PUSH HL               ;SAVE THE TEXT POINTER
  EX DE,HL              ;PUT THE POINTER TO THE VARIABLE VALUE INTO [H,L]. IN THE CASE OF A STRING
                        ;THIS IS A POINTER TO A DESCRIPTOR AND NOT AN ACTUAL VALUE
  LD (FACLOW),HL        ;IN CASE IT'S STRING STORE THE POINTER TO THE DESCRIPTOR IN FACLO.
  RST GETYPR 		    ;Get the number type (FAC).   FOR STRINGS WE JUST LEAVE
  CALL NZ,VMOVFM	    ;A POINTER IN THE FAC THE FAC USING [H,L] AS THE POINTER.   (CALL if not string type)
  POP HL                ;RESTORE THE TEXT POINTER
  RET

; Routine at 20137
;
; Used by the routines at TOKENIZE, TOKEN_BUILT, NOTRES, L55F8 and GET_DEVNAME.
MAKUPL:
  LD A,(HL)             ;GET CHAR FROM MEMORY

; Make char in 'A' upper case
;
; Used by the routines at NTSNGT and OCTCNS.
UCASE:
  CP 'a'                ;IS IT LOWER CASE RANGE
  RET C                 ;LESS
  CP 'z'+1              ;GREATER
  RET NC                ;TEST
  AND $5F               ;MAKE UPPER CASE
  RET                   ;DONE

; Routine at 20147
CNSGET:
  CP '&'		 ; $26
  JP NZ,ATOH

; OCTAL, HEX or other specified base (ASCII) to FP number
;
; Used by the routines at H_ASCTFP, NTSNGT and OPRND.
OCTCNS:
  LD DE,$0000       ;INITIALIZE TO ZERO AND IGNORE OVERFLOW
  RST CHRGTB		;GET FIRST CHAR
  CALL UCASE        ;MAKE UPPER IF NESC.
  LD BC,$0102		; B=1, C=2  ..Binary
  CP 'B'            ;"&b": BINARY?
  JR Z,LOPOCT       ;IF SO, DO IT
  LD BC,$0308		; B=3, C=8  ..Octal
  CP 'O'            ;"&o": OCTAL?
  JR Z,LOPOCT       ;IF SO, DO IT
  LD BC,$0410		; B=4, C=16  ..Hex
  CP 'H'            ;"&h": HEX?
  JP NZ,SN_ERR      ; If not, "syntax error"
LOPOCT:
  INC HL            ;BUMP POINTER
  LD A,(HL)         ;GET CHAR
  EX DE,HL
  CALL UCASE        ;MAKE UPPER CASE
  CP '9'+1          ;IS IT BIGGER THAN LARGEST DIGIT?
  JR C,ALPTST       ;NO
  CP 'A'
  JR C,OCTFIN
  SUB 'A'-10-'0'
ALPTST:
  SUB '0'			;CONVERT DIGIT, MAKE BINARY
  CP C              ;IS IT BIGGER THAN LARGEST DIGIT?
  JR NC,OCTFIN      ;YES, BE FORGIVING & RETURN
  PUSH BC
LOPHEX:
  ADD HL,HL         ;SHIFT RIGHT B BITS
  JP C,OV_ERR		; Err $06 -  "Overflow"
  DJNZ LOPHEX
  POP BC
  OR L              ;OR ON NEW DIGIT
  LD L,A            ;SAVE BACK
  EX DE,HL          ;GET TEXT POINTER BACK IN [H,L]
  JR LOPOCT         ;KEEP EATING

OCTFIN:
  CALL MAKINT
  EX DE,HL
  RET

; Routine at 20220
;
; Used by the routine at OPRND.
ISFUN:
  INC HL                   ; BUMP SOURCE TEXT POINTER
  LD A,(HL)                ; GET THE ACTUAL TOKEN FOR FN
  SUB $80+ONEFUN           ; MAKE INTO OFFSET  (Is it a function?  -$80-1)
  LD B,$00                 ; Get address of function
  RLCA                     ; Double function offset             ;MULTIPLY BY 2
  LD C,A                   ; BC = Offset in function table
  PUSH BC                  ; Save adjusted token value          ;SAVE THE FUNCTION # ON THE STACK
  RST CHRGTB		       ; Get next character
  LD A,C                   ; Get adjusted token value           ;LOOK AT FUNCTION #
  CP 2*TK_MID_S-2*ONEFUN+1 ; Adj' LEFT$,RIGHT$ or MID$ ?
  JR NC,OKNORM             ; No - Do function

;
; MOST FUNCTIONS TAKE A SINGLE ARGUMENT.
; THE RETURN ADDRESS OF THESE FUNCTIONS IS A SMALL ROUTINE
; THAT CHECKS TO MAKE SURE VALTYP IS 0 (NUMERIC) AND POPS OFF
; THE TEXT POINTER. SO NORMAL FUNCTIONS THAT RETURN STRING RESULTS (I.E. CHR$)
; MUST POP OFF THE RETURN ADDRESS OF LABBCK, AND POP OFF THE
; TEXT POINTER AND THEN RETURN TO FRMEVL.
;
; THE SO CALLED "FUNNY" FUNCTIONS CAN TAKE MORE THAN ONE ARGUMENT.
; THE FIRST OF WHICH MUST BE STRING AND THE SECOND OF WHICH
; MUST BE A NUMBER BETWEEN 0 AND 256. THE TEXT POINTER IS
; PASSED TO THESE FUNCTIONS SO ADDITIONAL ARGUMENTS
; CAN BE READ. THE TEXT POINTER IS PASSED IN [D,E].
; THE CLOSE PARENTHESIS MUST BE CHECKED AND RETURN IS DIRECTLY
; TO FRMEVL WITH [H,L] SETUP AS THE TEXT POINTER POINTING BEYOND THE ")".
; THE POINTER TO THE DESCRIPTOR OF THE STRING ARGUMENT
; IS STORED ON THE STACK UNDERNEATH THE VALUE OF THE INTEGER ARGUMENT (2 BYTES)
;
; FIRST ARGUMENT ALWAYS STRING -- SECOND INTEGER
;
  CALL OPNPAR		       ; Evaluate expression  (X,...        ;EAT OPEN PAREN AND FIRST ARG
  RST SYNCHR 		       ; Make sure "," follows
  DEFB ','                                                      ;TWO ARGS SO COMMA MUST DELIMIT
  CALL TSTSTR              ; Make sure it's a string            ;MAKE SURE THE FIRST ONE WAS STRING
  EX DE,HL                 ; Save code string address           ;[D,E]=TXTPTR
  LD HL,(FACLOW)           ; Get address of string              ;GET PTR AT STRING DESCRIPTOR
  EX (SP),HL               ; Save address of string             ;GET FUNCTION # <> SAVE THE STRING PTR
  PUSH HL                  ; Save adjusted token value          ;PUT THE FUNCTION # ON
  EX DE,HL                 ; Restore code string address        ;[H,L]=TXTPTR
  CALL GETINT              ; Get integer 0-255                  ;[E]=VALUE OF FORMULA
  EX DE,HL                 ; Save code string address           ;TEXT POINTER INTO [D,E] <> [H,L]=INT VALUE OF SECOND ARGUMENT
  EX (SP),HL               ; Save integer,HL = adj' token       ;SAVE INT VALUE OF SECOND ARG <> [H,L]=FUNCTION NUMBER
  JR GOFUNC                ; Jump to string function            ;DISPATCH TO FUNCTION

; a.k.a. FNVAL
OKNORM:
  CALL EVLPAR              ; Evaluate expression                ;CHECK OUT THE ARGUMENT AND MAKE SURE ITS FOLLOWED BY ")"
  EX (SP),HL               ; HL = Adjusted token value          ;[H,L]=FUNCTION # AND SAVE TEXT POINTER
;
; CHECK IF SPECIAL COERCION MUST BE DONE FOR ONE OF THE TRANSCENDENTAL
; FUNCTIONS (RND, SQR, COS, SIN, TAN, ATN, LOG, AND EXP)
; THESE FUNCTIONS DO NOT LOOK AT VALTYP, BUT RATHER ASSUME THE
; ARGUMENT PASSED IN THE FAC IS SINGLE PRECISION, SO FRCSNG
; MUST BE CALLED BEFORE DISPATCHING TO THEM.
;
  LD A,L                 ;[A]=FUNCTION NUMBER
  CP 2*(TK_SQR-ONEFUN)   ;LESS THAN SQUARE ROOT?        ; Adj' SGN, INT or ABS ?
  JR C,NOTFRF            ;DON'T FORCE THE ARGUMENT
  CP 2*(TK_ATN-ONEFUN)+1 ;BIGGER THAN ARC-TANGENT?      ; Adj' ABS, SQR, RND, SIN, LOG, EXP, COS, TAN or ATN ?
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HOKNO				; Hook 2 for Factor Evaluator
ENDIF
  JR NC,NOTFRF           ;DON'T FORCE THE ARGUMENT
  RST GETYPR 		; Get the number type (FAC)
  
  PUSH HL
  CALL C,__CDBL
  POP HL
  
NOTFRF:
  LD DE,RETNUM          ; Return number from function     ;RETURN ADDRESS
  PUSH DE               ; Save on stack                   ;MAKE THEM REALLY COME BACK


GOFUNC:
  LD BC,FNCTAB_FN		; Function routine addresses      ;FUNCTION DISPATCH TABLE
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HFING		; Hook 3 for Factor Evaluator
ENDIF
DISPAT:
  ADD HL,BC             ; Point to right address          ;ADD ON THE OFFSET
  LD C,(HL)             ; Get LSB of address              ;FASTER THAN PUSHM
  INC HL                ;
  LD H,(HL)             ; Get MSB of address
  LD L,C                ; Address to HL
  JP (HL)               ; Jump to function                ;GO PERFORM THE FUNCTION

; THE FOLLOWING ROUTINE IS CALLED FROM FIN IN F4
; TO SCAN LEADING SIGNS FOR NUMBERS. IT WAS MOVED
; TO F3 TO ELIMINATE BYTE EXTERNALS
;
; This entry point is used by the routine at _ASCTFP.
; test '+', '-'..
SGNEXP:
  DEC D                 ; Dee to flag negative exponent       ;SET SIGN OF EXPONENT FLAG
  CP TK_MINUS			; "-" token ?                         ;NEGATIVE EXPONENT?
  RET Z                 ; Yes - Return
  CP '-'                ; "-" ASCII ?
  RET Z                 ; Yes - Return
  INC D                 ; Inc to flag positive exponent       ;NO, RESET FLAG
  CP '+'                ; "+" ASCII ?
  RET Z                 ; Yes - Return
  CP TK_PLUS			; "+" token ?                         ;IGNORE "+"
  RET Z                 ; Yes - Return
  DEC HL                ; DEC 'cos GETCHR INCs                ;CHECK IF LAST CHARACTER WAS A DIGIT
  RET                   ; Return "NZ"                         ;RETURN WITH NON-ZERO SET

; Routine at 20311
DOCMP:
  INC A                   ;SETUP BITS
  ADC A,A                 ;4=LESS 2=EQUAL 1=GREATER
  POP BC                  ;WHAT DID HE WANT?
  AND B                   ;ANY BITS MATCH?
  ADD A,$FF               ;MAP 0 TO 0
  SBC A,A                 ;AND ALL OTHERS TO 377
  CALL CONIA              ;CONVERT [A] TO AN INTEGER SIGNED
  JR NOT_0                ;RETURN FROM OPERATOR APPLICATION PLACE SO THE TEXT POINTER
                          ;WILL GET SET UP TO WHAT IT WAS WHEN LPOPER RETURNED.

; Routine at 20323
;
; Used by the routine at OPRND.
; Evaluate 'NOT'
NOT:
  LD D,$5A             ; Precedence value for "NOT"         ;"NOT" HAS PRECEDENCE 90, SO FORMULA EVALUATION
  CALL EVAL_1          ; Eval until precedence break        ;IS ENTERED WITH A DUMMY ENTRY OF 90 ON THE STACK
  CALL __CINT          ; Get integer -32768 - 32767         ;COERCE THE ARGUMENT TO INTEGER
  LD A,L               ; Get LSB                            ;COMPLEMENT [H,L]
  CPL                  ; Invert LSB
  LD L,A               ; Save "NOT" of LSB
  LD A,H               ; Get MSB
  CPL                  ; Invert MSB
  LD H,A               ; Set "NOT" of MSB
  LD (FACLOW),HL       ; Save AC as current                 ;UPDATE THE FAC
  POP BC               ; Clean up stack                     ;FRMEVL, AFTER SEEING THE PRECEDENCE OF 90 THINKS IT IS 
                                                            ;APPLYING AN OPERATOR SO IT HAS THE TEXT POINTER IN TEMP2 SO
; This entry point is used by the routine at DOCMP.
NOT_0:
  JP EVAL3             ; Continue evaluation                ;RETURN TO REFETCH IT


;
; DANDOR APPLIES THE "AND" AND "OR" OPERATORS
; AND SHOULD BE USED TO IMPLEMENT ALL LOGICAL OPERATORS.
; WHENEVER AN OPERATOR IS APPLIED, ITS PRECEDENCE IS IN [B].
; THIS FACT IS USED TO DISTINGUISH BETWEEN "AND" AND "OR".
; THE RIGHT HAND ARGUMENT IS COERCED TO INTEGER, JUST AS
; THE LEFT HAND ONE WAS WHEN IT WAS PUSHED ON THE STACK.
;
; Routine at 20344
DANDOR:
  LD A,B              ;SAVE THE PRECEDENCE "OR"=70
  PUSH AF             
  CALL __CINT         ;COERCE RIGHT HAND ARGUMENT TO INTEGER
  POP AF              ;GET BACK THE PRECEDENCE TO DISTINGUISH "AND" AND "OR"
  POP DE              ;POP OFF THE LEFT HAND ARGUMENT
  CP $7A              ;IS THE OPERATOR "MOD"?    (as in PRITAB)
  JP Z,IMOD           ;IF SO, USE MONTE'S SPECIAL ROUTINE
  CP $7B              ;IS THE OPERATOR "IDIV"?   (as in PRITAB)
  JP Z,INT_DIV        ;LET MONTE HANDLE IT
  LD BC,GIVINT        ;PLACE TO RETURN WHEN DONE
  PUSH BC             ;SAVE ON STACK
  CP $46              ;SET ZERO FOR "OR"
  JR NZ,NOTOR
OR:
  LD A,E              ;SETUP LOW IN [A]
  OR L
  LD L,A
  LD A,H
  OR D
  RET                 ;RETURN THE INTEGER [A,L]

NOTOR:
  CP $50              ;AND?
  JR NZ,NOTAND
  
AND:
  LD A,E
  AND L
  LD L,A
  LD A,H
  AND D
  RET                 ;RETURN THE INTEGER [A,L]
  
NOTAND:
  CP $3C              ;XOR?
  JR NZ,NOTXOR        ;NO

XOR:
  LD A,E
  XOR L
  LD L,A
  LD A,H
  XOR D
  RET
  
NOTXOR:
  CP $32              ;EQV?
  JR NZ,IMP           ;NO

EQV:
  LD A,E              ;LOW PART
  XOR L
  CPL
  LD L,A
  LD A,H
  XOR D
  CPL
  RET

; 'IMP' expression
;
;FOR "IMP" USE A IMP B = NOT(A AND NOT(B))
IMP:
  LD A,L              ;MUST BE "IMP"
  CPL
  AND E
  CPL
  LD L,A
  LD A,H
  CPL
  AND D
  CPL
  RET

; Routine at 20417 ($4FC1)
;
; THIS ROUTINE SUBTRACTS [D,E] FROM [H,L]
; AND FLOATS THE RESULT LEAVING IT IN FAC.
;
; Used by the routine at __FRE.
GIVDBL:
  OR A
  SBC HL,DE           ;[H,L]=[H,L]-[D,E]
  JP INEG2            ;FLOAT 2 BYTE UNSIGNED INT

; Routine at 20423
__LPOS:
  LD A,(LPTPOS)
  JR PASSA            ;SEE WHERE WE ARE

; Routine at 20428
__POS:
  LD A,(TTYPOS)       ;GET TELETYPE POSITION, SEE WHERE WE ARE


; Exit from function, result in A
; a.k.a. SNGFLT
;
; This entry point is used by the routines at __INP_0, OPRND, __LPOS, __PEEK,
; __VAL, __PDL, FN_VDP and __VPEEK.
PASSA:
  LD L,A            ;MAKE [A] AN UNSIGNED INTEGER
  XOR A

GIVINT:
  LD H,A
  JP MAKINT

; Routine at 20437
;
; USER DEFINED (USR) ASSEMBLY LANGUAGE FUNCTION CODE
;
; Used by the routine at OPRND.
FN_USR:
  CALL SCNUSR           ;SCAN THE USR#
  PUSH DE               ;SAVE POINTER
  CALL EVLPAR           ;EAT LEFT PAREN AND FORMULA
  EX (SP),HL            ;SAVE TEXT POINTER & GET INDEX INTO USRTAB
  LD E,(HL)             ;GET DISPATCH ADRESS
  INC HL                ;BUMP POINTER
  LD D,(HL)             ;PICK UP 2ND BYTE OF ADDRESS
  LD HL,POPHLRT         ;GET ADDRESS OF POP H RET
  PUSH HL               ;PUSH IT ON
  PUSH DE               ;SAVE ADDRESS OF USR ROUTINE
  LD A,(VALTYP)         ;GET ARGUMENT TYPE IN [A]
  PUSH AF               ;SAVE VALTYP
  CP $03                ;STRING??
  CALL Z,GSTRCU         ;FREE IT UP
  POP AF                ;GET BACK VALTYP
  EX DE,HL              ;MOVE POSSIBLE DESC. POINTER TO [D,E]
  LD HL,FACCU           ;POINTER TO FAC IN [H,L]
  RET                   ;CALL USR ROUTINE

; Routine at 20468
;
; Used by the routines at FN_USR and DEF_USR.
SCNUSR:
  RST CHRGTB            ;GET A CHAR
  LD BC,$0000           ;ASSUME USR0
  CP ONECON+10          ;SINGLE BYTE INT EXPECTED
  JR NC,NOARGU          ;NO, MUST BE DEFAULTING TO USR0
  CP ONECON             ;IS IT SMALLER THAN ONECON
  JR C,NOARGU           ;YES, ASSUME TRYING TO DEFAULT TO USR0
  RST CHRGTB            ;SCAN PAST NEXT CHAR
  LD A,(CONLO)          ;GET VALUE OF 1 BYTER
  OR A                  ;MAKE SURE CARRY IS OFF
  RLA                   ;MULTIPLY BY 2
  LD C,A                ;SAVE OFFSET IN [C]
NOARGU:
  EX DE,HL              ;SAVE TEXT POINTER IN [D,E]
  LD HL,USR0            ;GET START OF TABLE
  ADD HL,BC             ;ADD ON OFFSET
  EX DE,HL              ;RESTORE TEXT POINTER, ADDRESS TO [D,E]
  RET                   ;RETURN FROM SCAN ROUTINE

; Routine at 20494
;
; Used by the routine at __DEF.
DEF_USR:
  CALL SCNUSR           ;SCAN THE USR NAME
  PUSH DE               ;SAVE POINTER TO USRTAB ENTRY
  RST SYNCHR
  DEFB TK_EQUAL         ;MUST HAVE EQUAL SIGN
  CALL GETWORD          ;GET THE ADDRESS
  EX (SP),HL            ;TEXT POINTER TO STACK, GET ADDRESS
  LD (HL),E             ;SAVE USR CALL ADDRESS
  INC HL                ;BUMP POINTER
  LD (HL),D             ;SAVE HIGH BYTE OF ADDRESS
  POP HL                ;RESTORE TEXT POINTER
  RET                   ;RETURN TO NEWSTT

;
;SIMPLE-USER-DEFINED-FUNCTION CODE
;
; IN THE 8K VERSION (SEE LATER COMMENT FOR EXTENDED)
; NOTE ONLY SINGLE ARGUMENTS ARE ALLOWED TO FUNCTIONS
; AND FUNCTIONS MUST BE OF THE SINGLE LINE FORM:
; DEF FNA(X)=X^2+X-2
; NO STRINGS CAN BE INVOLVED WITH THESE FUNCTIONS
;
; IDEA: CREATE A FUNNY SIMPLE VARIABLE ENTRY
; WHOSE FIRST CHARACTER (SECOND WORD IN MEMORY)
; HAS THE 200 BIT SET.
; THE VALUE WILL BE:
;
; 	A TXTPTR TO THE FORMULA
;	THE NAME OF THE PARAMETER VARIABLE
;
; FUNCTION NAMES CAN BE LIKE "FNA4"
;

; 'DEF' BASIC instruction
; Routine at 20509
__DEF:
  CP TK_USR            ;DEFINING THE CALL ADDRESS OF USR ROUTINE?
  JR Z,DEF_USR         ;YES, DO IT
  
; DEF FN<name>[«parameter list>}]=<function definition>
;
  CALL GETFNM             ; Get "FN" and name              ;GET A POINTER TO THE FUNCTION NAME
  CALL IDTEST             ; Error if in 'DIRECT' (immediate) mode
  EX DE,HL                ;[D,E] = THE TEXT POINTER AFTER THE FUNCTION NAME 
                          ;AND [H,L] = POINTER AT PLACE TO STORE VALUE OF THE FUNCTION VARIABLE
  LD (HL),E               ;SAVE THE TEXT POINTER AS THE VALUE
  INC HL                  
  LD (HL),D               
  EX DE,HL                ;RESTORE THE TEXT POINTER TO [H,L]
  LD A,(HL)               ;GET NEXT CHAR
  CP '('                  ;DOES THIS FUNCTION HAVE ARGS?
  JP NZ,__DATA            ;NO, go to get next statement
  RST CHRGTB
SCNLIS:
  CALL GETVAR             ;GET POINTER TO DUMMY VAR(CREATE VAR)
  LD A,(HL)               ;GET TERMINATOR
  CP ')'                  ;END OF ARG LIST?
  JP Z,__DATA             ;YES
  RST SYNCHR
  DEFB ','                ;"," MUST FOLLOW THEN
  JR SCNLIS

; Routine at 20544
;
; Used by the routine at OPRND.
DOFN:
  CALL GETFNM           ; Make sure "FN" follows and get FN name
  LD A,(VALTYP)         ;FIND OUT WHAT KIND OF FUNCTION IT IS
  OR A                  ;PUSH THIS [A] ON WITH A PSW WITH CARRY OFF SO THAT WHEN VALUES ARE
                        ;BEING POPPED OFF AND RESTORED TO PARAMETERS WE WILL KNOW WHEN TO STOP
                        ;WHEN A VALTYP IS POPPED OFF WITH CARRY OFF

  PUSH AF               ;SAVE SO THAT THE FINAL RESULT WILL BE COERCED TO THE FUNCTION TYPE
  LD (NXTOPR),HL		;SAVE THE TEXT POINTER THAT POINTS PAST THE FUNCTION NAME IN THE CALL
  EX DE,HL              ;[H,L]=A POINTER TO THE VALUE OF FUNCTION
  LD A,(HL)             ;[H,L]=VALUE OF THE FUNCTION
  INC HL                ;WHICH IS A TEXT POINTER AT THE FORMAL
  LD H,(HL)             ;PARAMETER LIST IN THE DEFINITION
  LD L,A                
  LD A,H                ; Is function DEFined?
  OR L                  ;A ZERO TEXT POINTER MEANS THE FUNCTION WAS NEVER DEFINED
  JP Z,UFN_ERR          ; Err $12 - "Undefined user function"
  LD A,(HL)             ;SEE IF THERE ARE ANY PARAMETERS
  CP '('                ;PARAMETER LIST STARTS WITH "(""
  JP NZ,FINVLS          ;SKIP OVER PARAMETER SETUP
  RST CHRGTB            ;GO PAST THE "("
  LD (TEMP3),HL         ;SAVE THE TEXT POINTER TO THE START OF THE
  EX DE,HL              ;PARAMETER LIST.
  LD HL,(NXTOPR)		;NOW GET THE TEXT-POINTER FROM THE CALL WHICH IS POINTING
                        ;JUST PAST THE FUNCTION NAME AT THE ARGUMENT LIST
  RST SYNCHR
  DEFB '('              ;MAKE SURE THE ARGUMENT LIST IS THERE
  XOR A                 ;INDICATE END OF VALUES TO ASSIGN
  PUSH AF               
  PUSH HL               ;SAVE THE CALLERS TEXT POINTER
  EX DE,HL              ;GET THE POINTER TO THE BEGINNING OF THE PARAMETER LIST
ASGMOR:
  LD A,$80              ;OUTLAW ARRAYS WHEN SCANNING
  LD (SUBFLG),A         ;PARAMETERS
  CALL GETVAR           ;READ A PARAMETER
  EX DE,HL              ;[D,E]=PARAMETER LIST TEXT,[H,L]=VARIABLE POINTER
  EX (SP),HL            ;SAVE THE VARIABLES POSITION AND GET THE POINTER AT THE ARG LIST
  LD A,(VALTYP)         ;AND ITS TYPE (FOR COERCION)
  PUSH AF               
  PUSH DE               ;SAVE THE TEXT POINTER INTO THE PARAMETER
  CALL EVAL             ;EVALUATE THE ARGUMENT
  LD (NXTOPR),HL		;SAVE THE ARGUMENT LIST POINTER
  POP HL                ;AND THE PARAMETER LIST POINTER
  LD (TEMP3),HL
  POP AF                ;GET THE VALUE TYPE
  CALL CHKTYP           ;COERCE THE ARGUMENT
  LD C,$04              ;MAKE SURE THERE IS ROOM FOR THE VALUE
  CALL CHKSTK           ; Check for C levels on stack
  LD HL,-8              ;SAVE EIGHT PLACES
  ADD HL,SP
  LD SP,HL
  CALL VMOVMF           ;PUT VALUE INTO RESERVED PLACE IN STACK
  LD A,(VALTYP)         ;SAVE TYPE FOR ASSIGNMENT
  PUSH AF
  LD HL,(NXTOPR)		;REGET THE ARGUMENT LIST POINTER
  LD A,(HL)             ;SEE WHAT COMES AFTER THE ARGUMENT FORMULA
  CP ')'                ;IS THE ARGUMENT LIST ENDING?
  JR Z,POPASG           ;MAKE SURE THE ARGUMENT LIST ALSO ENDED
  RST SYNCHR            
  DEFB ','              ;SKIP OVER ARGUMENT COMMA
  PUSH HL               ;SAVE THE ARGUMENT LIST TEXT POINTER
  LD HL,(TEMP3)         ;GET THE TEXT POINTER INTO THE DEFINTION'S PARAMETER LIST
  RST SYNCHR            
  DEFB ','              ;SKIP OVER THE PARAMETER LIST COMMA
  JR ASGMOR             ;AND BIND THE REST OF THE PARAMETERS
  

POPAS2:
  POP AF                ;IF ASSIGNMENT IS SUCESSFUL UPDATE PRMLN2
  LD (PRMLN2),A         ;INDICATE NEW VARIABLE IS IN PLACE
POPASG:
  POP AF                ;GET THE VALUE TYPE
  OR A
  JR Z,FINASG           ;ZERO MEANS NO MORE LEFT TO POP AND ASSIGN
  LD (VALTYP),A
  LD HL,$0000           ;POINT INTO STACK
  ADD HL,SP             ;TO GET SAVED VALUE
  CALL VMOVFM           ;PUT VALUE INTO FAC
  LD HL,$0008           ;FREE UP STACK AREA
  ADD HL,SP
  LD SP,HL
  POP DE                ;GET PLACE TO STORE TO
  LD L,$03              ;CALCULATE THE SIZE OF THE LOOKS (NAME)

;LPSIZL:
;  INC L                   ;INCREMENT SIZE
;  DEC DE                  ;POINT AT PREVIOUS CHARACTER
;  LD A,(DE)               ;SEE IF IT IS THE LENGTH OR ANOTHER CHARACTER
;  OR A
;  JP M,LPSIZL             ;HIGH BIT INDICATES STILL PART OF NAME

  DEC DE                ;BACK UP OVER LOOKS
  DEC DE
  DEC DE
  LD A,(VALTYP)         ;GET SIZE OF VALUE
  ADD A,L               ;ADD ON SIZE OF NAME
  LD B,A                ;SAVE TOTAL LENGTH IN [B]
  LD A,(PRMLN2)         ;GET CURRENT SIZE OF BLOCK
  LD C,A                ;SAVE IN [C]
  ADD A,B               ;GET POTENTIAL NEW SIZE
  CP $64                ;CAN'T EXCEED ALLOCATED STORAGE
  JP NC,FC_ERR          ; Err $05 - "Illegal function call"
  PUSH AF               ;SAVE NEW SIZE
  LD A,L                ;[A]=SIZE OF NAME
  LD B,$00              ;[B,C]=SIZE OF PARM2
  LD HL,PARM2           ;BASE OF PLACE TO STORE INTO
  ADD HL,BC             ;[H,L]=PLACE TO START THE NEW VARIABLE
  LD C,A                ;[B,C]=LENGTH OF NAME OF VARIABLE
  CALL BCTRAN           ;PUT IN THE NEW NAME
  LD BC,POPAS2          ;PLACE TO RETURN AFTER ASSIGNMENT
  PUSH BC               
  PUSH BC               ;SAVE EXTRA ENTRY ON STACK
  JP LETCN4             ;PERFORM ASSIGNMENT ON [H,L] (EXTRA POP D)

FINASG:
  LD HL,(NXTOPR)        ;GET ARGUMENT LIST POINTER
  RST CHRGTB            ;SKIP OVER THE CLOSING PARENTHESIS
  PUSH HL               ;SAVE THE ARGUMENT TEXT POINTER
  LD HL,(TEMP3)         ;GET THE PARAMETER LIST TEXT POINTER
  RST SYNCHR
  DEFB ')'              ;MAKE SURE THE PARAMETER LIST ENDED AT THE SAME TIME

  DEFB $3E              ; SKIP THE NEXT BYTE WITH "LD A,n"

FINVLS:
  PUSH DE               ;HERE WHEN THERE WERE NO ARGUMENTS OR PARAMETERS SAVE THE TEXT POINTER OF THE CALLER
  LD (TEMP3),HL         ;SAVE THE TEXT POINTER OF THE FUNCTION
  LD A,(PRMLEN)         ;PUSH PARM1 STUFF ONTO THE STACK
  ADD A,$04             ;WITH PRMLEN AND PRMSTK (4 BYTES EXTRA)
  PUSH AF               ;SAVE THE NUMBER OF BYTES
  RRCA                  ;NUMBER OF TWO BYTE ENTRIES IN [A]
  LD C,A
  CALL CHKSTK           ;IS THERE ROOM ON THE STACK?
  POP AF                ;[A]=AMOUNT TO PUT ONTO STACK
  LD C,A
  CPL                   ;COMPLEMENT [A]
  INC A
  LD L,A
  LD H,$FF
  ADD HL,SP             ;SET UP NEW STACK
  LD SP,HL              ;SAVE THE NEW VALUE FOR PRMSTK
  PUSH HL               ;FETCH DATA FROM HERE
  LD DE,PRMSTK
  CALL BCTRAN
  POP HL                ;LINK PARAMETER BLOCK FOR GARBAGE COLLECTION
  LD (PRMSTK),HL        ;NOW PUT PARM2 INTO PARM1
  LD HL,(PRMLN2)        ;SET UP LENGTH
  LD (PRMLEN),HL
  LD B,H
  LD C,L                ;[B,C]=TRANSFER COUNT
  LD HL,PARM1
  LD DE,PARM2
  CALL BCTRAN
  LD H,A                ;CLEAR OUT PARM2
  LD L,A
  LD (PRMLN2),HL
  LD HL,(FUNACT)		;INCREMENT FUNCTION COUNT
  INC HL
  LD (FUNACT),HL		; Count of active functions
  LD A,H
  OR L                  ;SET UP ACTIVE FLAG NON-ZERO
  LD (NOFUNS),A         ; 0 if no function active
  LD HL,(TEMP3)         ;GET BACK THE FUNCTION DEFINITION TEXT POINTER

;	DCX	H			;DETECT A MULTI-LINE FUNCTION
;	CHRGET			;IF THE DEFINITION ENDS NOW
;	JZ	MULFUN		;IF ENDS, ITS A MULTI-LINE FUNCTION

  CALL FRMEQL           ;SKIP OVER THE "=" IN THE DEFINITION AND EVALUATE THE DEFINITION FORMULA
                        ;CAN HAVE RECURSION AT THIS POINT
  DEC HL
  RST CHRGTB            ;SEE IF THE STATEMENT ENDED RIGHT
  JP NZ,SN_ERR          ;THIS IS A CHEAT, SINCE THE LINE NUMBER OF THE ERROR WILL BE
                        ;THE CALLER'S LINE # INSTEAD OF THE DEFINITIONS LINE #
  RST GETYPR            ;SEE IF THE RESULT IS A STRING
  JR NZ,NOCPRS          ;WHOSE DESCRIPTOR IS ABOUT TO BE WIPED OUT BECAUSE IT IS SITTING IN PARM1
                        ;(THIS HAPPENS IT THE FUNCTION IS A PROJECTION FUNCTION ON A STRING ARGUMENT)
  LD DE,DSCTMP
  LD HL,(FACLOW)
  RST DCOMPR
  JR C,NOCPRS           ;RESULT IS A TEMP - NO COPY NESC
  CALL STRCPY           ;MAKE A COPY IN DSCTMP
  CALL PUTTMP           ;PUT RESULT IN A TEMP AND MAKE FACLO POINT AT IT
NOCPRS:
  LD HL,(PRMSTK)		;GET PLACE TO RESTORE PARM1 FROM STACK
  LD D,H
  LD E,L
  INC HL                ;POINT AT LENGTH
  INC HL
  LD C,(HL)             ;[B,C]=LENGTH
  INC HL
  LD B,(HL)
  INC BC                ;INCLUDE EXTRA BYTES
  INC BC
  INC BC
  INC BC
  LD HL,PRMSTK          ;PLACE TO STORE INTO
  CALL BCTRAN
  EX DE,HL              ;[D,E]=PLACE TO RESTORE STACK TO
  LD SP,HL
  LD HL,(FUNACT)		;DECREASE ACTIVE FUNCTION COUNT
  DEC HL
  LD (FUNACT),HL
  LD A,H
  OR L                  ;SET UP FUNCTION FLAG
  LD (NOFUNS),A         ; (0 if no function active)
  POP HL                ;GET BACK THE CALLERS TEXT POINTER
  POP AF                ;GET BACK THE TYPE OF THE FUNCTION

  ; --- START PROC CHKTYP ---
; a.k.a. DOCNVF (=force type conversion)
CHKTYP:
  PUSH HL               ;SAVE THE TEXT POINTER
  AND $07               ;SETUP DISPATCH TO FORCE FORMULA TYPE 
                        ;TO CONFORM TO THE VARIABLE ITS BEING ASSIGNED TO
  LD HL,TYPE_OPR        ;TABLE OF FORCE ROUTINES
  LD C,A                ;[B,C]=TWO BYTE OFFSET
  LD B,$00
  ADD HL,BC
  CALL DISPAT           ;DISPATCH
  POP HL                ;GET BACK THE TEXT POINTER
  RET

;
; BLOCK TRANSFER ROUTINE WITH SOURCE IN [D,E] DESTINATION IN [H,L]
; AND COUNT IN [B,C]. TRANSFER IS FORWARD.
;
; Routine at 20873
BCTRAL:
  LD A,(DE)
  LD (HL),A
  INC HL
  INC DE
  DEC BC
BCTRAN:
  LD A,B
  OR C
  JR NZ,BCTRAL
  RET

; Routine at 20883
;
; SUBROUTINE TO SEE IF WE ARE IN DIRECT MODE AND COMPLAIN IF SO
;
; Check for a running program (Z if so).  If a program is not running, generate
; an Illegal Direct (ID) error.
;
; Used by the routine at __DEF.
IDTEST:
  PUSH HL               ; Save code string address                        ;SAVE THEIR [H,L]
  LD HL,(CURLIN)		; Get current line number                         ;SEE WHAT THE CURRENT LINE IS
  INC HL                ; -1 means direct statement                       ;DIRECT IS 65,535 SO NOW 0
  LD A,H
  OR L                                                                    ;IS IT ZERO NOW?
  POP HL                ; Restore code string address
  RET NZ                ; Return if in program                            ;RETURN IF NOT
  LD E,$0C				; Err $0C - "Illegal direct" (ID_ERROR)           ;"ILLEGAL DIRECT" ERROR
  JP ERROR

; Routine at 20897
;
; SUBROUTINE TO GET A POINTER TO A FUNCTION NAME
; Make sure "FN" follows and get FN name
;
; Used by the routines at __DEF and DOFN.
GETFNM:
  RST SYNCHR            ; Make sure FN follows
  DEFB TK_FN            ;MUST START WITH "FN"
  LD A,$80              ;DONT ALLOW AN ARRAY,
  LD (SUBFLG),A         ;DON'T RECOGNIZE THE "(" AS THE START OF AN ARRAY REFEREENCE
  OR (HL)               ; FN name has bit 7 set     ;PUT FUNCTION BIT ON
  LD C,A                ; in first byte of name     ;GET FIRST CHARACTER INTO [C]
  JP GTFNAM             ; Get FN name

; Routine at 20909
NOT_KEYWORD:
  CP $7E		; = $FF-$81 .. Token codes smaller than $80 ?
  JR NZ,NOT_KEYWORD_ERR
  INC HL
  LD A,(HL)
  INC HL
  CP TK_MID_S+$80	; $83
  JP Z,LHSMID
  CP TK_TRIG+$80	; $A3
  JP Z,_TRIG
  CP TK_INT+$80	; $85
  JP Z,_INTERVAL
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HISMI			; Hook 2 for Runloop execute event
ENDIF
NOT_KEYWORD_ERR:
  JP SN_ERR

; Routine at 20937
__WIDTH:
  CALL GETINT       ; GET WIDTH
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HWIDT			; Hook for "WIDTH"
ENDIF
  AND A
  JR Z,__WIDTH_1
  LD A,(OLDSCR)
  AND A
  LD A,E
  JR Z,__WIDTH_0
  CP 32+1
  JR NC,__WIDTH_1
__WIDTH_0:
  CP 40+1
__WIDTH_1:
  JP NC,FC_ERR			; Err $05 - "Illegal function call"
  LD A,(LINLEN)
  CP E
  RET Z
  LD A,FF			; FORMFEED
  RST OUTDO  		; Output char to the current device
  LD A,E
  LD (LINLEN),A     ;SETUP THE LINE LENGTH
  LD A,(OLDSCR)
  DEC A
  LD A,E
  JR NZ,__WIDTH_2
  LD (LINL32),A
  JR __WIDTH_3

__WIDTH_2:
  LD (LINL40),A
__WIDTH_3:
  LD A,FF			; FORMFEED
  RST OUTDO  		; Output char to the current device
  LD A,E

; This entry point is used by the routine at __SCREEN.
__WIDTH_4:
  SUB CLMWID
  JR NC,__WIDTH_4
  ADD A,CLMWID*2
  CPL
  INC A
  ADD A,E
  LD (CLMLST),A			; Column space
  RET                   ;BACK TO NEWSTT

; Routine at 21006
; $520E
FPSINT:
  RST CHRGTB		; Gets next character (or token) from BASIC text.
;
; This entry point is used by the routines at INTIDX, SCAN1 and __CIRCLE.
; $520F
FPSINT_0:
  CALL EVAL           ;EVALUATE A FORMULA
;
; Get integer variable to DE, error if negative
; Used by the routine at FNDNUM.
; $5212
;CONVERT THE FAC TO AN INTEGER IN [D,E]
;AND SET THE CONDITION CODES BASED ON THE HIGH ORDER
DEPINT:
  PUSH HL             ;SAVE THE TEXT POINTER
  CALL __CINT         ;CONVERT THE FORMULA TO AN INTEGER IN [H,L]
  EX DE,HL            ;PUT THE INTEGER INTO [D,E]
  POP HL              ;RETSORE THE TEXT POINTER
  LD A,D              ;SET THE CONDITION CODES ON THE HIGH ORDER
  OR A
  RET

; Routine at 21019
;
; Used by the routines at L4A5A, OPRND and FILINP.
FNDNUM:
  RST CHRGTB		; Gets next character (or token) from BASIC text.
; This entry point is used by the routines at SETIO, __WAIT, L492A, __ERROR,
; ISFUN, __WIDTH, __POKE, ATRSCN, __PAINT, LHSMID, MID_ARGSEP, FILSCN, __OPEN, RETRTS,
; FN_INPUT, __SOUND, __LOCATE, L77D4, __COLOR, __SCREEN, SET_BAUDRATE, PUT_SPRITE, __VDP,
; __VPOKE and __MAX.

; a.k.a. GETBYT, get integer in 0-255 range
GETINT:
  CALL EVAL           ;EVALUATE A FORMULA
; This entry point is used by the routines at __CHR_S, FN_STRING, FN_INSTR, FILFRM,
; __STICK, __STRIG, __PDL and __PAD.
CONINT:
  CALL DEPINT         ;CONVERT THE FAC TO AN INTEGER IN [D,E]
  JP NZ,FC_ERR        ;WASN'T ERROR (Err $05 - "Illegal function call")
  DEC HL              ;ACTUALLY FUNCTIONS CAN GET HERE
                      ;WITH BAD [H,L] BUT NOT SERIOUS
                      ;SET CONDITION CODES ON TERMINATOR
  RST CHRGTB
  LD A,E              ;RETURN THE RESULT IN [A] AND [E]
  RET


; 'LLIST' BASIC command
;
; Routine at 21033
__LLIST:               ;PRTFLG=1 FOR REGULAR LIST
  LD A,$01             ;GET NON ZERO VALUE
  LD (PRTFLG),A        ;SAVE IN I/O FLAG (END OF LPT)

; 'LIST' BASIC command
;
; This entry point is used by the routine at __SAVE.
__LIST:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HLIST			; Hook for "LIST"
ENDIF
  POP BC               ;GET RID OF NEWSTT RETURN ADDR
  CALL LNUM_RANGE      ;SCAN LINE RANGE
  PUSH BC              ;SAVE POINTER TO 1ST LINE
__LIST_0:
  LD HL,65535          ;DONT ALLOW ^C TO CHANGE
  LD (CURLIN),HL       ;CONTINUE PARAMETERS:  Set interpreter in 'DIRECT' (immediate) mode
  POP HL               ;GET POINTER TO LINE
  POP DE               ;GET MAX LINE # OFF STACK
  LD C,(HL)            ;[B,C]=THE LINK POINTING TO THE NEXT LINE
  INC HL               
  LD B,(HL)
  INC HL
  LD A,B               ;SEE IF END OF CHAIN
  OR C                 
  JP Z,READY           ;LAST LINE, STOP.  
  CALL ISFLIO          ;DON'T ALLOW ^C ON FILE OUTPUT
  CALL Z,ISCNTC        ;CHECK FOR CONTROL-C
  PUSH BC              ;SAVE LINK
  LD C,(HL)            ;PUSH THE LINE #
  INC HL
  LD B,(HL)
  INC HL
  PUSH BC
  EX (SP),HL           ;GET LINE # INTO [H,L]
  EX DE,HL             ;GET MAX LINE IN [H,L]
  RST DCOMPR           ;PAST LAST LINE IN RANGE?
  POP BC               ;TEXT POINTER TO [B,C]
  JP C,RESTART         ;IF PAST, THEN DONE LISTING.
  EX (SP),HL           ;SAVE MAX ON BOTTOM OF STACK
  PUSH HL              ;SAVE LINK ON TOP
  PUSH BC              ;SAVE TEXT POINTER BACK
  EX DE,HL             ;GET LINE # IN [H,L]
  LD (DOT),HL          ;SAVE FOR LATER EDIT OR LIST <> AND WE WANT [H,L] ON THE STACK
  CALL LINPRT          ;PRINT AS INT WITHOUT LEADING SPACE
  POP HL
  LD A,(HL)            ;GET BYTE FROM LINE
  CP $09               ;IS IT A TAB?
  JR Z,__LIST_1        ;THEN DONT PRINT SPACE
  LD A,' '
  RST OUTDO            ;PRINT A SPACE AFTER THE LINE #
__LIST_1:
  CALL DETOKEN_LIST    ;UNPACK THE LINE INTO BUF
  LD HL,BUF            ;POINT AT THE START OF THE UNPACKED CHARACTERS
  CALL LISPRT          ;PRINT THE LINE
  CALL OUTDO_CRLF      ;PRINT CRLF
  JR __LIST_0          ;GO BACK FOR NEXT LINE

; Routine at 21115
;
; Used by the routine at __LLIST.
LISPRT:
  LD A,(HL)
  OR A                 ;SET CC
  RET Z                ;IF =0 THEN END OF LINE
  CALL OUTCH1          ;OUTPUT CHAR AND CHECK FOR LF
  INC HL               ;INCR POINTER
  JR LISPRT            ;PRINT NEXT CHAR

; Routine at 21124
;
; Used by the routine at __LLIST.
DETOKEN_LIST:
  LD BC,BUF            ;GET START OF TEXT BUFFER
  LD D,$FF             ;GET ITS LENGTH INTO [D]
  XOR A                ;SET ON SPECIAL CHAR FOR SPACE INSERTION
  LD (DORES),A         ; a.k.a. OPRTYP, indicates whether stored word can be crunched, etc..
  JR PLOOP2            ;START HERE

;  block at 21135
  ; --- START PROC DETOKEN_NEXT ---
DETOKEN_NEXT:
  INC BC                 ;INCREMENT DEPOSIT PTR.
  INC HL                 ;ADVANCE TEXT PTR
  DEC D                  ;BUMP DOWN COUNT
  RET Z                  ;IF BUFFER FULL, RETURN
  ; --- START PROC PLOOP2 ---
PLOOP2:
  LD A,(HL)              ;GET CHAR FROM BUF
  OR A                   ;SET CC'S
  LD (BC),A              ;SAVE THIS CHAR
  RET Z                  ;IF END OF SOURCE BUFFER, ALL DONE.
  CP OCTCON              ;IS IT SMALLER THAN SMALLEST EMBEDDED CONSTANT?   (Not a number constant prefix ?)
  JR C,NTEMBL            ;YES, DONT TREAT AS ONE
  CP DBLCON+1            ;IS IT EMBEDED CONSTANT?
  JP C,NUMLIN            ; JP if control code     	;PRINT LEADING SPACE IF NESC.
  CP '"'
  JR NZ,DETOKEN_NEXT_2
  LD A,(OPRTYP)		; Temp operator number operations
  XOR $01
  LD (OPRTYP),A		; Temp operator number operations
  LD A,'"'
DETOKEN_NEXT_2:
  CP ':'
  JR NZ,NTEMBL
  LD A,(OPRTYP)		; Temp operator number operations
  RRA
  JR C,DETOKEN_NEXT_3
  RLA
  AND $FD
  LD (OPRTYP),A		; Temp operator number operations
DETOKEN_NEXT_3:
  LD A,':'
NTEMBL:
  OR A
  JP P,DETOKEN_NEXT
  LD A,(OPRTYP)		; Temp operator number operations
  RRA
  JR C,_DETOKEN_NEXT
  RRA
  RRA
  JR NC,DETOKEN
  LD A,(HL)
  CP TK_APOSTROPHE	     ;SINGLE QUOTE TOKEN?
  PUSH HL
  PUSH BC
  LD HL,__DETOKEN_NEXT
  PUSH HL
  RET NZ
  
  ; ..or with the ':REM' sequence..
  DEC BC
  LD A,(BC)
  CP 'M'
  RET NZ
  DEC BC
  LD A,(BC)
  CP 'E'
  RET NZ
  DEC BC
  LD A,(BC)
  CP 'R'
  RET NZ
  DEC BC
  LD A,(BC)
  CP ':'
  RET NZ
  
  POP AF
  POP AF
  POP HL
  INC D		; add 4 to line byte counter D
  INC D
  INC D
  INC D                ;FIX UP CHAR COUNT
  JR PLOOPR

; Routine at 21237
__DETOKEN_NEXT:
  POP BC
  POP HL
  LD A,(HL)
; This entry point is used by the routine at DETOKEN.
_DETOKEN_NEXT:
  JP DETOKEN_NEXT

; Routine at 21243
;
; Used by the routine at DETOKEN.
SET_DATA_FLAG:
  LD A,(DORES)	; a.k.a. OPRTYP, indicates whether stored word can be crunched, etc..
  OR $02
; This entry point is used by the routine at SET_REM_FLAG.
UPD_OPRTYP:
  LD (DORES),A	; a.k.a. OPRTYP, indicates whether stored word can be crunched, etc..
  XOR A
  RET

; Routine at 21253
;
; Used by the routine at DETOKEN.
SET_REM_FLAG:
  LD A,(DORES)	; a.k.a. OPRTYP, indicates whether stored word can be crunched, etc..
  OR $04
  JR UPD_OPRTYP

; Routine at 21260
DETOKEN:
  RLA
  JR C,_DETOKEN_NEXT
  LD A,(HL)
  CP TK_DATA
  CALL Z,SET_DATA_FLAG
  CP TK_REM
  CALL Z,SET_REM_FLAG

PLOOPR:
  LD A,(HL)
  INC A	                   ;SET ZERO IF FN TOKEN
  LD A,(HL)                ;GET CHAR BACK
  JR NZ,NTFNTK             ;NOT FUNCTION JUST TREAT NORMALLY
  INC HL                   ;BUMP POINTER
  LD A,(HL)                ;GET CHAR
  AND $7F                  ;TURN OFF HIGH BIT
NTFNTK:
  INC HL
  CP TK_ELSE
  JR NZ,DETOKEN_1
  DEC BC
  INC D
DETOKEN_1:
  PUSH HL                  ;SAVE TEXT PTR.
  PUSH BC                  ;SAVE DEPOSIT PTR.
  PUSH DE                  ;SAVE CHAR COUNT.
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HBUFL			; Hook for Detokenise event
ENDIF

  LD HL,WORDS-1           ;GET PTR TO START OF RESERVED WORD LIST
  LD B,A                  ;SAVE THIS CHAR IN [B]
  LD C,'A'-1              ;INIT LEADING CHAR VALUE
RESSR3:
  INC C                   ;BUMP LEADING CHAR VALUE.
RESSR1:
  INC HL                  ;BUMP POINTER INTO RESLST
  LD D,H                  ;SAVE PTR TO START OF THIS RESWRD
  LD E,L
RESSRC:
  LD A,(HL)               ;GET CHAR FROM RESLST
  OR A                    ;SET CC'S
  JR Z,RESSR3             ;IF END OF THIS CHARS TABLE, GO BACK & BUMP C
  INC HL                  ;BUMP SOURCE PTR
  JP P,RESSRC             ;IF NOT END OF THIS RESWRD, THEN KEEP LOOKING
  LD A,(HL)               ;GET PTR TO RESERVED WORD VALUE
  CP B                    ;SAME AS THE ONE WE SEARCH FOR?
  JR NZ,RESSR1            ;NO, KEEP LOOKING.
  EX DE,HL
  LD A,C                  ;GET LEADING CHAR
  POP DE
  POP BC
  CP 'Z'+1                ;WAS IT A SPECIAL CHAR?
  JR NZ,NTSPCH            ;NON-SPECIAL CHAR
MORPUR:
  LD A,(HL)               ;GET BYTE FROM RESWRD
  INC HL                  ;BUMP POINTER
NTSPCH:
  LD E,A                  ;SAVE CHAR
  AND $7F                 ;AND OFF HIGH ORDER BIT FOR DISK & EDIT
  LD (BC),A               ;STORE THIS CHAR
  INC BC
  DEC D                   ;ANY SPACE LEFT IN BUFFER
  JP Z,POPAF              ;NO, RETURN
  OR E                    ;SET CC'S
  JP P,MORPUR             ;END OF RESWRD?
  POP HL                  ;RESTORE SOURCE PTR.
  JP PLOOP2               ;GET NEXT CHAR FROM LINE

; Routine at 21345
NUMLIN:
  DEC HL                  ;MOVE POINTER BACK AS CHRGET INX'S
  RST CHRGTB              ;SCAN THE CONSTANT
  PUSH DE                 ;SAVE CHAR COUNT
  PUSH BC                 ;SAVE DEPOSIT PTR
  PUSH AF                 ;SAVE CONSTANT TYPE.
  CALL CONFAC             ;MOVE CONSTANT INTO FAC
  POP AF                  ;RESTORE CONSTANT TYPE
  LD BC,CONLIN            ;PUT RETURN ADDR ON STACK
  PUSH BC                 ;SAVE IT
  CP OCTCON               ;OCTAL CONSTANT?
  JP Z,FOUTO              ;PRINT IT
  CP HEXCON               ;HEX CONSTANT?
  JP Z,FOUTH              ;PRINT IN HEX
  LD HL,(CONLO)           ;GET LINE # VALUE IF ONE.
  JP FOUT                 ;PRINT REMAINING POSSIBILITIES.

; Routine at 21374
CONLIN:
  POP BC                   ;RESTORE DEPOSIT PTR.
  POP DE                   ;RESTORE CHAR COUNT
  LD A,(CONSAV)            ;GET SAVED CONSTANT TOKEN
  LD E,'O'                 ;ASSUME OCTAL CONSTANT
  CP OCTCON                ;OCTAL CONSTANT?
  JR Z,SAVBAS              ;YES, PRINT IT
  CP HEXCON                ;HEX CONSTANT?
  LD E,'H'                 ;ASSUME SO.
  JR NZ,NUMSLN             ;NOT BASE CONSTANT
SAVBAS:
  LD A,'&'                 ;PRINT LEADING BASE INDICATOR
  LD (BC),A                ;SAVE IT
  INC BC                   ;BUMP PTR
  DEC D                    ;BUMP DOWN CHAR COUNT
  RET Z                    ;RETURN IF END OF BUFFER
  LD A,E                   ;GET BASE CHAR
  LD (BC),A                ;SAVE IT
  INC BC                   ;BUMP PTR
  DEC D                    ;BUMP DOWN BASE COUNT
  RET Z                    ;END OF BUFFER, DONE
NUMSLN:
  LD A,(CONTYP)            ;GET TYPE OF CONSTANT WE ARE
  CP $04		           ;IS IT SINGLE OR DOUBLE PREC?
  LD E,$00                 ;NO, NEVER PRINT TRAILING TYPE INDICATOR
  JR C,TYPSET
  LD E,'!'                 ;ASSUME SINGLE PREC.
  JR Z,TYPSET              ;IS CONTYP=4, WAS SINGLE
  LD E,'#'                 ;DOUBLE PREC INDICATOR
TYPSET:
  LD A,(HL)                ;GET LEADING CHAR
  CP ' '                   ;LEADING SPACE
  JR NZ,NUMSL2             ;GO BY IT
  INC HL
NUMSL2:
  LD A,(HL)                ;GET CHAR FROM NUMBER BUFFER
  INC HL                   ;BUMP POINTER
  OR A                     ;SET CC'S
  JR Z,NUMDN               ;IF ZERO, ALL DONE.
  LD (BC),A                ;SAVE CHAR IN BUF.
  INC BC                   ;BUMP PTR
  DEC D                    ;SEE IF END OF BUFFER
  RET Z                    ;IF END OF BUFFER, RETURN
  LD A,(CONTYP)            ;GET TYPE OF CONSTANT TO BE PRINTED
  CP $04                   ;TEST FOR SINGLE OR DOUBLE PRECISION
  JR C,NUMSL2              ;NO, WAS INTEGER
  DEC BC                   ;PICK UP SAVED CHAR
  LD A,(BC)                ;EASIER THAN PUSHING ON STACK
  INC BC                   ;RESTORE TO POINT WHERE IT SHOULD
  JR NZ,DBLSCN             ;IF DOUBLE, DONT TEST FOR EMBEDED "."
  CP '.'                   ;TEST FOR FRACTION  ; $2E
  JR Z,ZERE                ;IF SINGLE & EMBEDED ., THEN DONT PRINT !   
DBLSCN:
; Double Precision specifier (exponential syntax, e.g. -1.09432D-06)                   
  CP 'D'                   ;DOUBLE PREC. EXPONENT?
  JR Z,ZERE                ;YES, MARK NO VALUE TYPE INDICATOR NESC.
; Exponential format specifier (e.g. -1.09E-06)
  CP 'E'                   ;SINGLE PREC. EXPONENT?
  JR NZ,NUMSL2             ;NO, PROCEED
ZERE:
  LD E,$00                 ;MARK NO PRINTING OF TYPE INDICATOR
  JR NUMSL2                ;KEEP MOVING NUMBER CHARS INTO BUF
  
NUMDN:
  LD A,E                   ;GET FLAG TO INDICATE WHETHER TO INSERT
  OR A                     ;A "D" AFTER DOUBLE PREC. #
  JR Z,NOD                 ;NO, DONT INSERT IT
  LD (BC),A                ;SAVE IN BUFFER
  INC BC                   ;BUMP POINTER
  DEC D                    ;DECRMENT COUNT OF CHARS LEFT IN BUFFER
  RET Z                    ;=0, MUST TRUNCATE LIST OF THIS LINE.
NOD:
  LD HL,(CONTXT)           ;GET BACK TEXT POINTER AFTER CONSTANT
  JP PLOOP2                ;GET NEXT CHAR

;
; THE FOLLOWING CODE IS FOR THE DELETE RANGE
; COMMAND. BEFORE THE LINES ARE DELETED, 'OK'
; IS TYPED.
;
; Routine at 21474
__DELETE:
  CALL LNUM_RANGE          ;SCAN LINE RANGE
  PUSH BC
  CALL DEPTR               ;CHANGE POINTERS BACK TO NUMBERS
  POP BC
  POP DE                   ;POP MAX LINE OFF STACK
  PUSH BC                  ;SAVE POINTER TO START OF DELETION FOR USE BY CHEAD AFTER FINI
  PUSH BC                  ;SAVE POINTER TO START OF 1ST LINE
  CALL SRCHLN              ;FIND THE LAST LINE
  JR NC,FCERRG             ;MUST HAVE A MATCH ON THE UPPER BOUND
  LD D,H                   ;[D,E] =  POINTER AT THE START OF THE LINE
  LD E,L                   ;BEYOND THE LAST LINE IN THE RANGE
  EX (SP),HL               ;SAVE THE POINTER TO THE NEXT LINE
  PUSH HL                  ;SAVE THE POINTER TO THE START OF THE FIRST LINE IN THE RANGE
  RST DCOMPR               ;MAKE SURE THE START COMES BEFORE THE END
FCERRG:
  JP NC,FC_ERR             ;IF NOT, Err $05 - "Illegal function call"
  LD HL,OK_MSG             ;PRINT "OK" PREMATURELY
  CALL PRS
  POP BC                   ;GET POINTER TO FIRST IN [B,C]
  LD HL,FINI               ;GO BACK TO FINI WHEN DONE
  EX (SP),HL               ;[H,L]=POINTER TO THE NEXT LINE


; --- START PROC __DELETE_0 ---
;
; ERASE A LINE FROM MEMORY
; [B,C]=START OF LINE BEING DELETED
; [D,E]=START OF NEXT LINE
;
__DELETE_0:
  EX DE,HL                 ;[D,E] NOW HAVE THE POINTER TO THE LINE BEYOND THIS ONE
  LD HL,(VARTAB)           ;COMPACTIFYING TO VARTAB
MLOOP:
  LD A,(DE)
  LD (BC),A                ;SHOVING DOWN TO ELIMINATE A LINE
  INC BC
  INC DE
  RST DCOMPR               ; Compare HL with DE.
  JR NZ,MLOOP              ;DONE COMPACTIFYING?
  LD H,B
  LD L,C
  LD (VARTAB),HL
  LD (ARYTAB),HL
  LD (STREND),HL
  RET

;
; NOTE: IN THE 8K PEEK ONLY ACCEPTS POSITIVE NUMBERS UP TO 32767
; POKE WILL ONLY TAKE AN ADDRESS UP TO 32767 , NO
; FUDGING ALLOWED. THE VALUE IS UNSIGNED.
; IN THE EXTENDED VERSION NEGATIVE NUMBERS CAN BE
; USED TO REFER TO LOCATIONS HIGHER THAN 32767.
; THE CORRESPONDENCE IS GIVEN BY SUBTRACTING 65536 FROM LOCATIONS
; HIGHER THAN 32767 OR BY SPECIFYING A POSITIVE NUMBER UP TO 65535.
;

; Routine at 21532
__PEEK:
  CALL GETWORD_HL          ;GET AN INTEGER IN [H,L]
  LD A,(HL)                ;GET THE VALUE TO RETURN
  JP PASSA                 ;AND FLOAT IT

; Routine at 21539
__POKE:
  CALL GETWORD             ;READ A FORMULA
  PUSH DE
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
  CALL GETINT              ; Get integer 0-255
  POP DE
  LD (DE),A
  RET

; Routine at 21551
; Get a number to DE (0..65535)
; a.k.a. FRMQNT
; Used by the routines at SETIO, DEF_USR, __POKE, __CLEAR, ONGO and __TIME.
GETWORD:
  CALL EVAL
  PUSH HL
  CALL GETWORD_HL
  EX DE,HL
  POP HL
  RET

; Routine at 21561
;
; Used by the routines at FOUTH(BIN, OCT...), __PEEK, GETWORD and BSAVE_PARM.
GETWORD_HL:
  LD BC,__CINT             ;RETURN HERE
  PUSH BC                  ;SAVE ADDR
  RST GETYPR               ;SET THE CC'S ON VALTYPE
  RET M                    ;RETURN IF ALREADY INTEGER.
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HFRQI		; Hook for "convert to integer"
ENDIF
  CALL SIGN			; test FP number sign
  RET M
  CALL __CSNG
  LD BC,$3245		; BCDE = 32768 (float)
  LD DE,$8076
  CALL FCOMP
  RET C
  LD BC,$6545		; BCDE = 65536 (float)
  LD DE,$6053
  CALL FCOMP
  JP NC,OV_ERR			; Err $06 -  "Overflow"
  LD BC,$65C5		; BCDE = -65536 (float)
  LD DE,$6053
  JP FADD

; Data block at 21608
__RENUM:
  LD  BC,10                ;ASSUME INC=10
  PUSH BC                  ;SAVE ON STACK
  LD  D,B                  ;RESEQ ALL LINES BY SETTING [D,E]=0
  LD  E,B                  
  JR  Z,__RENUM_2          ;IF JUST 'RESEQ' RESEQ 10 BY 10
  CP  ','                  ;COMMA
  JR  Z,__RENUM_1          ;DONT USE STARTING # OF ZERO
  PUSH DE                  ;SAVE [D,E]
  CALL LNUM_PARM           ;GET NEW NN
  LD  B,D                  ;GET IN IN [B,C] WHERE IT BELONGS
  LD  C,E                  

; Routine at 21626
__RENUM_0:
  POP DE                   ;GET BACK [D,E]
  JR Z,__RENUM_2           ;IF EOS, DONE
__RENUM_1:
  RST SYNCHR
  DEFB ','                 ;EXPECT COMMA
  CALL LNUM_PARM           ;GET NEW MM
  JR Z,__RENUM_2           ;IF EOS, DONE
  POP AF                   ;GET RID OF OLD INC
  RST SYNCHR
  DEFB ','                 ;EXPECT COMMA
  PUSH DE                  ;SAVE MM
  CALL ATOH                ;GET NEW INC
  JP NZ,SN_ERR             ;SHOULD HAVE TERMINATED.
  LD A,D                   ;SEE IF INC=0 (ILLEGAL)
  OR E
  JP Z,FC_ERR              ;YES, BLOW HIM UP NOW (Err $05 - "Illegal function call")
  EX DE,HL                 ;FLIP NEW INC & [H,L]
  EX (SP),HL               ;NEW INC ONTO STACK
  EX DE,HL                 ;GET [H,L] BACK, ORIG [D,E] BACK
__RENUM_2:
  PUSH BC                  ;SAVE NN ON STACK
  CALL SRCHLN              ;FIND MM LINE
  POP DE                   ;GET NN OFF STACK
  PUSH DE                  ;SAVE NN BACK
  PUSH BC                  ;SAVE POINTER TO MM LINE
  CALL SRCHLN              ;FIND FIRST LINE TO RESEQ.
  LD H,B                   ;GET PTR TO THIS LINE IN [H,L]
  LD L,C                   
  POP DE                   ;GET LINE PTD TO BY MM
  RST DCOMPR               ;COMPARE TO FIRST LINE RESEQED
  EX DE,HL                 ;GET PTR TO MM LINE IN [H,L]
  JP C,FC_ERR              ;CANT ALLOW PROGRAM TO BE RESEQUED ON TOP OF ITSELF (Err $05 - "Illegal function call")
  POP DE                   ;GET NN BACK
  POP BC                   ;GET INC IN [B,C]
  POP AF                   ;GET RID OF NEWSTT
  PUSH HL                  ;SAVE PTR TO FIRST LINE TO RESEQ.
  PUSH DE                  ;SAVE NN ON STACK
  JR __RENUM_4

; Routine at 21679
__RENUM_NXT:
  ADD HL,BC                ;ADD INCREMENT INTO
  JP C,FC_ERR              ;UH OH, HIS INC WAS TOO LARGE. (Err $05 - "Illegal function call")
  EX DE,HL                 ;FLIP LINK FIELD, ACCUM.
  PUSH HL                  ;SAVE LINK FIELD
  LD HL,65529              ;TEST FOR TOO LARGE LINE
  RST DCOMPR               ;COMPARE TO CURRENT #
  POP HL                   ;RESTORE LINK FIELD
  JP C,FC_ERR              ;UH OH, HIS INC WAS TOO LARGE. (Err $05 - "Illegal function call")
__RENUM_4:
  PUSH DE                  ;SAVE CURRENT LINE ACCUM
  LD E,(HL)                ;GET LINK FIELD INTO [D,E]
  INC HL                   ;GET LOW PART INTO K[A] FOR ZERO TEST
  LD D,(HL)                
  LD A,D                   ;GET HIGH PART OF LINK
  OR E                     ;SET CC'S ON LINK FIELD
  EX DE,HL                 ;SEE IF NEXT LINK ZERO
  POP DE                   ;GET BACK ACCUM LINE #
  JR Z,__RENUM_FIN         ;ZERO, DONE
  LD A,(HL)                ;GET FIRST BYTE OF LINK
  INC HL                   ;INC POINTER
  OR (HL)                  ;SET CC'S
  DEC HL                   ;MOVE POINTER BACK
  EX DE,HL                 ;BACK IN [D,E]
  JR NZ,__RENUM_NXT        ;INC COUNT

__RENUM_FIN:
  PUSH BC                  ;SAVE INC
  CALL SCCLIN              ;SCAN PROGRAM CONVERTING LINES TO PTRS.
  POP BC                   ;GET BACK INC
  POP DE                   ;GET NN
  POP HL                   ;GET PTR TO FIRST LINE TO RESEQ
__RENUM_LP:
  PUSH DE                  ;SAVE CURRENT LINE
  LD E,(HL)                ;GET LINK FIELD
  INC HL                   ;PREPARE FOR ZERO LINK FIELD TEST
  LD D,(HL)
  LD A,D
  OR E
  JR Z,LINE2PTR            ;STOP RESEQING WHEN SEE END OF PGM
  EX DE,HL                 ;FLIP LINE PTR, LINK FIELD
  EX (SP),HL               ;PUT LINK ON STACK, GET NEW LINE # OFF
  EX DE,HL                 ;PUT NEW LINE # IN [D,E], THIS LINE PTR IN [H,L]
  INC HL                   ;POINT TO LINE # FIELD.
  LD (HL),E                ;CHANGE TO NEW LINE #
  INC HL
  LD (HL),D
  EX DE,HL                 ;GET THIS LINE # IN [H,L]
  ADD HL,BC                ;ADD INC
  EX DE,HL                 ;GET NEW LINE # BACK IN [D,E]
  POP HL                   ;GET PTR TO NEXT LINE
  JR __RENUM_LP            ;KEEP RESEQING

; Routine at 21738
;
; Used by the routines at __DELETE, __CLOAD and __CSAVE_1.
DEPTR:
  LD A,(PTRFLG)
  OR A
  RET Z
  JR SCCPTR

  ; --- START PROC LINE2PTR ---
LINE2PTR:
  LD BC,RESTART           ;WHERE TO GO WHEN DONE
  PUSH BC                 ;SAVE ON STACK

  DEFB $FE                  ; 'CP $F6'  masking the next byte/instr.

; THE SUBROUTINES SCCLIN AND SCCPTR CONVERT ALL
; LINE #'S TO POINTERS AND VICE-VERSA.
; THE ONLY SPECIAL CASE IS "ON ERROR GOTO 0" WHERE THE "0"
; IS LEFT AS A LINE NUMBER TOKEN SO IT WONT BE CHANGED BY RESEQUENCE.

SCCLIN:
  DEFB $F6                ; 'OR $AF'  masking the next instruction
 
SCCPTR:
  XOR A             ;SET A=0

  LD (PTRFLG),A     ;SET TO SAY WHETER LINES OR PTRS EXTANT
  LD HL,(TXTTAB)    ; Start of program text                     GET PTR TO START OF PGM
  DEC HL            ;                                           NOP NEXT INX.

SCNPLN:
  INC HL            ;                                           POINT TO BYTE AFTER ZERO AT END OF LINE
  LD A,(HL)         ; Get address of next line                  GET LINK FIELD INTO [D,E]
  INC HL            ;                                           BUMP PTR
  OR (HL)           ; End of program found?                     SET CC'S
  RET Z             ; Yes - Line not found                      RETURN IF ALL DONE.
  INC HL            ;                                           POINT PAST LINE #
  LD E,(HL)         ; Get LSB of line number                    GET LOW BYTE OF LINE #
  INC HL            
  LD D,(HL)         ; Get MSB of line number                    GET HIGH BYTE OF LINE #
SCNEXT:
  RST CHRGTB		;GET NEXT CHAR FROM LINE

; Line number to pointer
_LINE2PTR:
  OR A                    ;END OF LINE
  JR Z,SCNPLN             ;SCAN NEXT LINE
  LD C,A                  ;SAVE [A]
  LD A,(PTRFLG)           ;CHANGE LINE TOKENS WHICH WAY?
  OR A                    ;SET CC'S
  LD A,C                  ;GET BACK CURRENT CHAR
  JR Z,SCNPT2             ;CHANGING POINTERS TO #'S
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HSCNE		; Hook for 'Line number to pointer' event
ENDIF
  CP TK_ERROR             ;IS IT ERROR TOKEN?
  JR NZ,NTERRG            ;NO.
  RST CHRGTB              ;SCAN NEXT CHAR
  CP TK_GOTO              ;ERROR GOTO?
  JR NZ,_LINE2PTR         ;GET NEXT ONE
  RST CHRGTB              ;GET NEXT CHAR
  CP LINCON               ; Line number prefix (LINCON):  LINE # CONSTANT?
  JR NZ,_LINE2PTR         ;NO, IGNORE.
  PUSH DE                 ;SAVE [D,E]
  CALL LINGT3             ;GET IT
  LD A,D                  ;IS IT LINE # ZERO?
  OR E                    ;SET CC'S
  JR NZ,CHGPTR            ;CHANGE IT TO A POINTER
  JR SCNEX3               ;YES, DONT CHANGE IT

NTERRG:
  CP LINCON               ; Line number prefix (LINCON): LINE # CONSTANT?
  JR NZ,SCNEXT            ;NOT, KEEP SCANNING
  PUSH DE                 ;SAVE CURRENT LINE # FOR POSSIBLE ERROR MSG
  CALL LINGT3             ;GET LINE # OF LINE CONSTANT INTO [D,E]
CHGPTR:                   
  PUSH HL                 ;SAVE TEXT POINTER JUST AT END OF LINCON 3 BYTES
  CALL SRCHLN             ;TRY TO FIND LINE IN PGM.
  DEC BC                  ;POINT TO ZERO AT END OF PREVIOUS LINE
  LD A,PTRCON             ;CHANGE LINE # TO PTR
  JR C,MAKPTR             ;IF LINE FOUND CHANE # TO PTR
  CALL CONSOLE_CRLF       ;PRINT CRLF IF REQUIRED
  LD HL,LINE_ERR_MSG      ;PRINT "Undefined line" MESSAGE
  PUSH DE                 ;SAVE LINE #
  CALL PRS                ;PRINT IT
  POP HL                  ;GET LINE # IN [H,L]
  CALL LINPRT             ;PRINT IT
  POP BC                  ;GET TEXT PTR OFF STACK
  POP HL                  ;GET CURRENT LINE #
  PUSH HL                 ;SAVE BACK
  PUSH BC                 ;SAVE BACK TEXT PTR
  CALL IN_PRT             ;PRINT IT
SCNPOP:
  POP HL                  ;POP OFF CURRENT TEXT POINTER
SCNEX3:
  POP DE                  ;GET BACK CURRENT LINE #
  DEC HL                  ;BACKUP POINTER

_SCNEXT:
  JR SCNEXT               ;KEEP SCANNING

; Message at 21850
LINE_ERR_MSG:
  DEFM "Undefined line "
  DEFB $00

; Routine at 21866
SCNPT2:
  CP PTRCON               ; POINTER?
  JR NZ,_SCNEXT
  PUSH DE
  CALL LINGT3
  PUSH HL
  EX DE,HL
  INC HL
  INC HL
  INC HL
  LD C,(HL)
  INC HL
  LD B,(HL)
  LD A,LINCON			; Line number prefix
; This entry point is used by the routine at LINE2PTR.
MAKPTR:
  LD HL,SCNPOP
  PUSH HL
  LD HL,(CONTXT)

; This entry point is used by the routine at RUNLIN.
CONCH2:
  PUSH HL
  DEC HL
  LD (HL),B
  DEC HL
  LD (HL),C
  DEC HL
  LD (HL),A
  POP HL
  RET


; SYNCHR - REPLACEMENTS FOR COMPAR & SYNCHK IN RSTLES VERSION
; Routine at 21900
;
; Used by the routine at _SYNCHR.
__SYNCHR:
  LD A,(HL)
  EX (SP),HL
  CP (HL)           ;CMPC-IS CHAR THE RIGHT ONE?
  INC HL
  EX (SP),HL
  JP NZ,SN_ERR      ;GIVE ERROR IF CHARS DONT MATCH
  JP __CHRGTB

; Routine at 21911
;
; Used by the routine at _GETYPR.
; Return the number type (FAC)
; 
__GETYPR:
  LD A,(VALTYP)
  CP $08		; set M,PO.. flags
;
; CONTINUATION OF GETYPE RST
;
  JR NC,NCASE       ;SPLIT OFF NO CARRY CASE
  SUB $03           ;SET A CORRECTLY
  OR A              ;NOW SET LOGICAL'S OK
  SCF               ;CARRY MUST BE SET
  RET               ;ALL DONE
NCASE:
  SUB $03           ;SUBTRACT CORRECTLY
  OR A              ;SET CC'S PROPERLY
  RET               ;RETURN


; '_' works like a shortcut for 'CALL'
; Routine at 21927
CALL_SHCUT:
  RST CHRGTB		; Gets next character (or token) from BASIC text.


__CALL:
  LD DE,PROCNM
  LD B,$0F
__CALL_0:
  LD A,(HL)
  AND A
  JR Z,__CALL_1
  CP ':'
  JR Z,__CALL_1
  CP '('               ;Eat left paren
  JR Z,__CALL_1
  LD (DE),A
  INC DE
  INC HL
  DJNZ __CALL_0
__CALL_1:
  LD A,B
  CP $0F		; Did we find 0, ':', or '(' at first position ?
  JR Z,__CALL_5
__CALL_2:		; No, skip spaces
  XOR A
  LD (DE),A
  DEC DE
  LD A,(DE)
  CP ' '
  JR Z,__CALL_2
  LD B,$40
  LD DE,SLTATR
__CALL_3:
  LD A,(DE)
  AND $20
  JR NZ,__CALL_6
__CALL_4:
  INC DE
  DJNZ __CALL_3
__CALL_5:
  JP SN_ERR
  
__CALL_6:
  PUSH BC
  PUSH DE
  PUSH HL
  CALL L7E2A
  PUSH AF
  LD C,A
  LD L,$04
  CALL RDSLT_WORD
  PUSH DE
  POP IX
  POP IY
  POP HL
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  CALL CALSLT
  POP DE
  POP BC
  JR C,__CALL_4
  RET

; Routine at 22008
;
; Used by the routine at GET_DEVNAME.
; deal with exceptions/expansions
L55F8:
  POP HL
  LD A,B
  CP $10			; TK_INP ?
  JR C,L55F8_0
  LD B,$0F
L55F8_0:
  CALL L7FB7			; "RESUME NEXT"+1, copy in ROM  ??
L55F8_1:
  CALL MAKUPL		; Load A with char in 'HL' and make it uppercase
  LD (DE),A
  INC HL
  INC DE
  DJNZ L55F8_1
  XOR A
  LD (DE),A
  LD B,$40
  LD DE,SLTATR
L55F8_2:
  LD A,(DE)
  AND $40
  JR NZ,L55F8_5
L55F8_3:
  INC DE
  DJNZ L55F8_2
L55F8_4:
  JP NM_ERR					; Err $38 -  'Bad file name'
  
L55F8_5:
  PUSH BC
  PUSH DE
  CALL L7E2A
  PUSH AF
  LD C,A
  LD L,$06
  CALL RDSLT_WORD
  PUSH DE
  POP IX
  POP IY
  LD A,$FF
  CALL CALSLT
  POP DE
  POP BC
  JR C,L55F8_3
  LD C,A
  LD A,$40
  SUB B
  ADD A,A
  ADD A,A
  OR C
  CP $09
  JR C,L55F8_4
  CP $FC		; TK_BKSLASH ?
  JR NC,L55F8_4
  POP HL
  POP DE
  AND A
  RET

; Routine at 22090
;
; Used by the routine at L6F85.
L564A:
  PUSH BC
  PUSH AF
  RRA
  RRA
  AND $3F
  CALL L7E2A_0
  PUSH AF
  LD C,A
  LD L,$06
  CALL RDSLT_WORD
  PUSH DE
  POP IX
  POP IY
  POP AF
  AND $03
  LD (DEVICE),A
  POP BC
  POP AF
  POP DE
  POP HL
  JP CALSLT



; ________________________________________________________

;
;       MACLNG - MACRO LANGUAGE DRIVER
;
; MICROSOFT GRAPHICS AND SOUND MACRO LANGUAGES
;


; Data block at 22124
MACLNG:
  LD   (MCLTAB),DE  ;SAVE POINTER TO COMMAND TABLE
  CALL EVAL         ;EVALUATE STRING ARGUMENT
  PUSH HL           ;SAVE TXTPTR TILL DONE
  LD   DE,$0000     ;PUSH DUMMY ENTRY TO MARK END OF STK
  PUSH DE           ;DUMMY ADDR
  PUSH AF           ;DUMMY LENGTH
MCLNEW:
  CALL GETSTR
  CALL LOADFP       ;GET LENGTH & POINTER
  LD   B,C
  LD   C,D
  LD   D,E
  LD   A,B
  OR C
  JR Z,MCLOOP       ;Don't Push if addr is 0
  LD A,D
  OR A
  JR Z,MCLOOP       ; or if Len is 0...
  PUSH BC           ;PUSH ADDR OF STRING
  PUSH DE           ;PUT IN [AL]
MCLOOP:
  POP AF            ;GET LENGTH OFF STACK
  LD (MCLLEN),A
  POP HL            ;GET ADDR
  LD A,H            ;SEE IF LAST ENTRY
  OR L
  JR NZ,MACLNG_0
  LD A,(MCLFLG)		;Are we using PLAY macros ?
  OR A
  JP Z,MC_POPTRT    ;ALL FINISHED IF ZERO
  JP MCLPLAY_0      ;Yes, go for the extras


MACLNG_0:
  LD (MCLPTR),HL    ;SET UP POINTER

; This entry point is used by the routines at __PLAY_2 and DOSND.
MCLSCN:
  CALL FETCHR       ;GET A CHAR FROM STRING
  JR Z,MCLOOP       ;END OF STRING - SEE IF MORE ON STK
  ADD A,A           ;PUT CHAR * 2 INTO [C]
  LD C,A
  LD HL,(MCLTAB)    ;POINT TO COMMAND TABLE
MSCNLP:
  LD A,(HL)         ;GET CHAR FROM COMMAND TABLE
  ADD A,A           ;CHAR = CHAR * 2 (CLR HI BIT FOR CMP)
GOFCER:
  CALL Z,FC_ERR     ;END OF TABLE.    ( Err $05 - "Illegal function call" )
  CP C              ;HAVE WE GOT IT?
  JR Z,MISCMD       ;YES.
  INC HL            ;MOVE TO NEXT ENTRY
  INC HL
  INC HL
  JR MSCNLP

MISCMD:
  LD BC,MCLSCN      ;RETURN TO TOP OF LOOP WHEN DONE
  PUSH BC
  LD A,(HL)         ;SEE IF A VALUE NEEDED
  LD C,A            ;PASS GOTTEN CHAR IN [C]
  ADD A,A
  JR NC,MNOARG      ;COMMAND DOESN'T REQUIRE ARGUMENT
  OR A              ;CLEAR CARRY
  RRA               ;MAKE IT A CHAR AGAIN
  LD C,A            ;PUT IN [C]
  PUSH BC
  PUSH HL           ;SAVE PTR INTO CMD TABLE
  CALL FETCHR       ;GET A CHAR
  LD DE,$0001       ;DEFAULT ARG=1
  JP Z,VSNARG_0     ;NO ARG IF END OF STRING
  CALL ISLETTER_A   ;SEE IF POSSIBLE LETTER
  JP NC,VSNARG
  CALL VALSC3       ;GET THE VALUE
  SCF               ;SET CARRY TO FLAG USING NON-DEFAULT
  JR ISCMD3

VSNARG:
  CALL DECFET       ;PUT CHAR BACK INTO STRING
VSNARG_0:
  OR A              ;CLEAR CARRY
ISCMD3:
  POP HL
  POP BC            ;GET BACK COMMAND CHAR
MNOARG:
  INC HL            ;POINT TO DISPATCH ADDR
  LD A,(HL)         ;GET ADDRESS INTO HL
  INC HL
  LD H,(HL)
  LD L,A
  JP (HL)           ;DISPATCH



; This entry point is used by the routines at VALSCN, SCNVAR and DMOVE.
FETCHZ:
  CALL FETCHR       ;GET A CHAR FROM STRING
  JR Z,GOFCER       ;GIVE ERROR IF END OF LINE
  RET

; Routine at 22254
;
; Used by the routines at L5683, VALSCN, PLAY_NOTE and DOSND.
FETCHR:
  PUSH HL
FETCH2:
  LD HL,MCLLEN      ;POINT TO STRING LENGTH
  LD A,(HL)
  OR A
  JR Z,MC_POPTRT    ;RETURN Z=0 IF END OF STRING
  DEC (HL)          ;UPDATE COUNT FOR NEXT TIME
  LD HL,(MCLPTR)    ;GET PTR TO STRING
  LD A,(HL)         ;GET CHARACTER FROM STRING
  INC HL            ;UPDATE PTR FOR NEXT TIME
  LD (MCLPTR),HL
  CP ' '            ;SKIP SPACES
  JR Z,FETCH2
  CP 'a'-1          ;CONVERT LOWER CASE TO UPPER
  JR C,MC_POPTRT
  SUB $20           ;DO CONVERSION
; This entry point is used by the routine at L5683.
MC_POPTRT:
  POP HL
  RET

; Routine at 22283
;
; Used by the routines at L5683, VALSCN, DMOVE, PLAY_NOTE and DOSND.
DECFET:
  PUSH HL
  LD HL,MCLLEN      ;INCREMENT LENGTH
  INC (HL)
  LD HL,(MCLPTR)    ;BACK UP POINTER
  DEC HL
  LD (MCLPTR),HL
  POP HL
  RET

; Routine at 22297
;
; Used by the routine at DMOVE.
VALSCN:
  CALL FETCHZ       ;GET FIRST CHAR OF ARGUMENT
; This entry point is used by the routine at L5683.
VALSC3:
  CP '='            ;NUMERIC?
  JP Z,VARGET
  CP '+'            ;PLUS SIGN?
  JR Z,VALSCN       ;THEN SKIP IT
  CP '-'            ;NEGATIVE VALUE?
  JR NZ,VALSC2
  LD DE,NEGD        ;IF SO, NEGATE BEFORE RETURNING
  PUSH DE
  JR VALSCN         ;EAT THE "-"
  
; This entry point is used by the routine at DOSND.
VALSC2:
  LD DE,$0000       ;INITIAL VALUE OF ZERO
NUMLOP:
  CP ','            ;COMMA
  JR Z,DECFET       ;YES, BACK UP AND RETURN
  CP ';'            ;SEMICOLON?
  RET Z             ;YES, JUST RETURN
  CP '9'+1          ;NOW SEE IF ITS A DIGIT
  JR NC,DECFET      ;IF NOT, BACK UP AND RETURN
  CP '0'
  JR C,DECFET

  LD HL,$0000       ;[HL] is accumulator
  LD B,$0A          ;[HL]=[DE]*10
MUL10:
  ADD HL,DE
  JR C, SCNFC       ;overflow - JMP Function Call Error
  DJNZ MUL10
  
  SUB '0'           ;ADD IN THE DIGIT
  LD E,A
  LD D,$00
  ADD HL,DE
  JR C, SCNFC       ;overflow - JMP Function Call Error
  EX DE,HL          ;VALUE SHOULD BE IN [DE]
  CALL FETCHR       ;GET NEXT CHAR
  JR NZ,NUMLOP      ;branch if not end of string
  RET


; (GW-BASIC has extra code here to "Allow VARPTR$(variable) for BASCOM compatibility")
;
; Routine at 22362
; Used by the routines at VARGET and MCLXEQ.
SCNVAR:
  CALL FETCHZ       ;MAKE SURE FIRST CHAR IS LETTER
  LD DE,BUF         ;PLACE TO COPY NAME FOR PTRGET
  PUSH DE           ;SAVE ADDR OF BUF FOR "ISVAR"
  LD B,40           ;COPY MAX OF 40 CHARACTERS
  CALL ISLETTER_A   ;MAKE SURE IT'S A LETTER
  JR C,SCNFC        ;FC ERROR IF NOT LETTER
SCNVLP:
  LD (DE),A         ;STORE CHAR IN BUF
  INC DE
  CP ';'            ;A SEMICOLON?
  JR Z,SCNV2        ;YES - END OF VARIABLE NAME
  CALL FETCHZ       ;GET NEXT CHAR
  DJNZ SCNVLP

; This entry point is used by the routine at VALSCN.
 SCNFC:
  CALL FC_ERR       ;ERROR - VARIABLE TOO LONG
SCNV2:
  POP HL            ;GET PTR TO BUF
  JP EVAL_VARIABLE  ;GO GET ITS VALUE

; Routine at 22394
;
; Used by the routine at VALSCN.
VARGET:
  CALL SCNVAR       ;SCAN & EVALUATE VARIABLE
  CALL __CINT       ;MAKE IT AN INTEGER
  EX DE,HL          ;IN [DE]
  RET

; Routine at 22402
;
; Used by the DRAW and PLAY routines.
;  Plays MML stored in string variable A$ *3 / Executes a drawing substring
MCLXEQ:
  CALL SCNVAR       ;SCAN VARIABLE NAME
  LD A,(MCLLEN)     ;SAVE CURRENT STRING POS & LENGTH
  LD HL,(MCLPTR)
  EX (SP),HL        ;POP OFF RET ADDR, PUSH MCLPTR
  PUSH AF
  LD C,$02          ;MAKE SURE OF ROOM ON STACK
  CALL CHKSTK
  JP MCLNEW

; Routine at 22421
NEGD:
  XOR A
  SUB E
  LD E,A
  SBC A,D
  SUB E
  LD D,A
  RET

; ________________________________________________________
;  End of MACRO LANGUAGE block 



;
; ALLOW A COORDINATE OF THE FORM (X,Y) OR STEP(X,Y)
; THE LATTER IS RELATIVE TO THE GRAPHICS AC.
; THE GRAPHICS AC IS UPDATED WITH THE NEW VALUE
; RESULT IS RETURNED WITH [B,C]=X AND [D,E]=Y
; CALL SCAN1 TO GET FIRST IN A SET OF TWO PAIRS SINCE IT ALLOWS
; A NULL ARGUMENT TO IMPLY THE CURRENT AC VALUE AND
; IT WILL SKIP A "@" IF ONE IS PRESENT
;

; Routine at 22428
;
; Used by the routines at LINE, __PAINT, __CIRCLE and PUT_SPRITE.
SCAN1:
  LD A,(HL)         ;GET THE CURRENT CHARACTER
  CP '@'            ;ALLOW MEANINGLESS "@"
  CALL Z,__CHRGTB   ;BY SKIPPING OVER IT
  LD BC,$0000       ;ASSUME NO COODINATES AT ALL (-SECOND)
  LD D,B
  LD E,C
  CP TK_MINUS		; "-", SEE IF ITS SAME AS PREVIOUS
  JR Z,SCANN        ;USE GRAPHICS ACCUMULATOR

;
; THE STANDARD ENTRY POINT
;

; This entry point is used by the routines at __PSET and FN_POINT.
SCAND:
  LD A,(HL)         ;GET THE CURRENT CHARACTER
  ;CP TK_MINUS       ; '-'
  CP TK_STEP        ;IS IT RELATIVE?    ; If STEP is used, coordinates are interpreted relative to the current cursor position.
                                        ; In this case the values can also be negative.
  PUSH AF           ;REMEMBER
  CALL Z,__CHRGTB   ;SKIP OVER $STEP TOKEN
  RST SYNCHR        
  DEFB '('          ;SKIP OVER OPEN PAREN
  CALL FPSINT_0     ;SCAN X INTO [D,E]
  PUSH DE           ;SAVE WHILE SCANNING Y
  RST SYNCHR        
  DEFB ','          ;SCAN COMMA
  CALL FPSINT_0     ;GET Y INTO [D,E]
  RST SYNCHR        
  DEFB ')'          
  POP BC            ;GET BACK X INTO [B,C]
  POP AF            ;RECALL IF RELATIVE OR NOT

SCANN:
  PUSH HL           ;SAVE TEXT POINTER
  LD HL,(GRPACX)    ;GET OLD POSITION
  JR Z,SCXREL       ;IF ZERO,RELATIVE SO USE OLD BASE           ; JP if 'STEP' is specified
  LD HL,$0000       ;IN ABSOLUTE CASE, JUST Y USE ARGEUMENT
SCXREL:             
  ADD HL,BC         ;ADD NEW VALUE
  LD (GRPACX),HL    ;UPDATE GRAPHICS ACCUMLATOR
  LD (GXPOS),HL     ;STORE SECOND COORDINTE FOR CALLER
  LD B,H            ;RETURN X IN BC
  LD C,L            
  LD HL,(GRPACY)    ;GET OLDY POSITION
  JR Z,SCYRE        ;IF ZERO, RELATIVE SO USE OLD BASE          ; JP if 'STEP' is specified
  LD HL,$0000       ;ABSOLUTE SO OFFSET BY 0
SCYRE:              
  ADD HL,DE         
  LD (GRPACY),HL    ;UPDATE Y PART OF ACCUMULATOR
  LD (GYPOS),HL     ;STORE Y FOR CALLER
  EX DE,HL          ;RETURN Y IN [D,E]
  POP HL            ;GET BACK THE TEXT POINTER                  ; code string address
  RET



;
; PSET (X,Y)[,ATTRIBUTE] DEFAULT ATTRIBUTE TO FORCLR
; PRESET (X,Y)[,ATTRIBUTE] DEFAULT ATTIBUTE TO BAKCLR
;

; Routine at 22501
__PRESET:
  LD A,(BAKCLR)
  JR __PSET_0


; Routine at 22506
__PSET:
  LD A,(FORCLR)                ; Get default color (PSET=foreground)
; This entry point is used by the routine at __PRESET.
__PSET_0:
  PUSH AF                      ; Save default color               ;SAVE DEFAULT ATTRIBUTE
  CALL SCAND                   ; Get coordinates in BC, DE        ;SCAN A SINGLE COORDINATE
  POP AF                       ; Restore default color            ;GET BACK DEFAULT ATTRIBUTE
  CALL ATRENT                  ; Get color, if specified          ;SCAN POSSIBLE ATTRIBUTE
  PUSH HL                      ; Save code string address         ;SAVE TEXT POINTER
  CALL SCALXY                                                     ;SCALE INTO BOUNDS
  JR NC,PSTNOT                                                    ;NO PSET IF NOT IN BOUNDS
  CALL MAPXY                   ;MAP INTO A "C"           ; Find position in VRAM. CLOC=memory address, CMASK=color pixelmask
  CALL SETC                    ;ACTUALLY DO THE SET
PSTNOT:
  POP HL                       ; Restore code string address
  RET


; Routine at 22531
;
; Used by the routine at OPRND.
FN_POINT:
  RST CHRGTB		; Gets next character (or token) from BASIC text.       ;POINT IS RECOGNIZED IN EVAL SO NEED TO SKIP ONE MORE CHAR
  PUSH HL			; Save code string address                              ; Save the text pointer.
  CALL FETCHC		; Save cursor                                           ;Preserve the graphics cursor, GXPOS,
  POP DE			; Move code string address to DE                        ;and GYPOS across the POINT function
  PUSH HL			; Save cursor position                                  ;so cases like
  PUSH AF			; Save cursor mask                                      ;LINE (x1,y1)-(x2,y2),POINT(x3,y3) will
  LD HL,(GYPOS)		; Make a copy of GX, GY                                 ;work correctly.
  PUSH HL
  LD HL,(GXPOS)		; etc..
  PUSH HL
  LD HL,(GRPACY)
  PUSH HL
  LD HL,(GRPACX)
  PUSH HL
  EX DE,HL			; Move code string address to HL                        ;Put the text pointer back in HL.
  CALL SCAND        ; Get coordinates in BC, DE                             ;READ THE SPECIFICATION OF THE POINT
  PUSH HL			; Save code string address                              ;SAVE THE TEXT POINTER
  CALL SCALXY                                                               ;SCALE THE POINT
  LD HL,-1                                                                  ;ASSUME ILLEGAL POINT
  JR NC,PNTNOT                                                              ;NOT LEGAL - RETURN -1
  CALL MAPXY		; Set addresses for dot position
  CALL READC                                                                ;READ OUT THE ATTRIBUTE
  LD L,A
  LD H,$00
PNTNOT:
  CALL MAKINT                                                               ;Restore text pointer
  POP DE			; Code string address
  POP HL
  LD (GRPACX),HL	; Restore GX, GY..
  POP HL                                                                    ;Restore GXPOS, GYPOS, and the graphics
  LD (GRPACY),HL	; ..etc..                                               ;cursor.
  POP HL
  LD (GXPOS),HL		; ..to the original ..
  POP HL
  LD (GYPOS),HL		; ...values
  POP AF			; Restore cursor mask
  POP HL			; Restore cursor position
  PUSH DE			; Save code string address
  CALL STOREC		; Restore cursor
  POP HL			; Restore code string address                           ;Retrieve the text pointer and return.
  RET


;
; ATTRIBUTE SCAN
; LOOK AT THE CURRENT POSITION AND IF THERE IS AN ARGUMENT READ IT AS
; THE 8-BIT ATTRIBUTE VALUE TO SEND TO SETATR. IF STATEMENT HAS ENDED
; OR THERE IS A NULL ARGUMENT, SEND FORCLR  TO SETATR
;
; Routine at 22605
; Used by the routines at LINE, __PAINT and __CIRCLE.
ATRSCN:
  LD A,(FORCLR)
; This entry point is used by the routine at __PSET.
ATRENT:
  PUSH BC
  PUSH DE
  LD E,A
  CALL IN_GFX_MODE       ; "Illegal function call" if not in graphics mode
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JR Z,ATRFIN            ;USE DEFAULT
  RST SYNCHR
  DEFB ','               ;INSIST ON COMMA
  CP ','                 ;ANOTHER COMMA FOLLOWS?
  JR Z,ATRFIN            ;IF SO, NULL ARGUMENT SO USE DEFAULT
  CALL GETINT            ;GET THE BYTE  ; Get integer 0-255
ATRFIN:
  LD A,E                 ;GET ATTRIBUTE INTO [A]
  PUSH HL                ;SAVE THE TEXT POINTER
  CALL SETATR            ; Set attribute byte
  JP C,FC_ERR            ;Graphics not available          ; Err $05 - "Illegal function call"
  POP HL
  POP DE                 ;GET BACK CURRENT POINT
  POP BC
  JP __CHRCKB		; Gets current character (or token) from BASIC text.



;
; XDELT SETS [H,L]=ABS(GXPOS-[B,C]) AND SETS CARRY IF [B,C].GT.GXPOS
; ALL REGISTERS EXCEPT [H,L] AND [A,PSW] ARE PRESERVED
; NOTE: [H,L] WILL BE A DELTA BETWEEN GXPOS AND [B,C] - ADD 1 FOR AN X "COUNT"
;

; Routine at 22641
; Used by the routines at LINE and DOGRPH.
XDELT:
  LD HL,(GXPOS)          ;GET ACCUMULATOR POSITION
  LD A,L
  SUB C
  LD L,A                 ;DO SUBTRACT INTO [H,L]
  LD A,H
  SBC A,B
  LD H,A
; This entry point is used by the routine at YDELT.
XDELT_0:
  RET NC                 ;IF NO CARRY, NO NEED TO NEGATE COUNT
  
; This entry point is used by the routines at DOGRPH, STPAIN, NEGDE, CPLOT8 and
; DMOVE.
NEGHL:
  XOR A                   ;STANDARD [H,L] NEGATE
  SUB L                   ; Negate exponent
  LD L,A                  ; Re-save exponent
  SBC A,H
  SUB L
  LD H,A
  SCF
  RET


;
; YDELT SETS [H,L]=ABS(GYPOS-[D,E]) AND SETS CARRY IF [D,E].GT.GYPOS
; ALL REGISTERS EXCEPT [H,L] AND [A,PSW] ARE PRESERVED
;

; Routine at 22659
; Used by the routines at LINE and DOGRPH.
YDELT:
  LD HL,(GYPOS)
  ; HL=HL-DE
  LD A,L
  SUB E
  LD L,A
  LD A,H
  SBC A,D
  LD H,A
  ;
  JR XDELT_0



;
; XCHGX EXCHANGES [B,C] WITH GXPOS
; XCHGY EXCHANGES [D,E] WITH GYPOS
; XCHGAC PERFORMS BOTH OF THE ABOVE
; NONE OF THE OTHER REGISTERS IS AFFECTED
;

; Routine at 22670
;
; Used by the routines at XCHGAC and LINE.
XCHGY:
  PUSH HL
  LD HL,(GYPOS)
  EX DE,HL
  LD (GYPOS),HL
  POP HL
  RET

; Routine at 22680
; Used by the routines at LINE and DOGRPH.
XCHGAC:
  CALL XCHGY

; This entry point is used by the routine at LINE.
XCHGX:
  PUSH HL
  PUSH BC
  LD HL,(GXPOS)
  EX (SP),HL
  LD (GXPOS),HL
  POP BC
  POP HL
  RET



;
; LINE [(X1,Y1)]-(X2,Y2) [,ATTRIBUTE[,B[F]]]
; DRAW A LINE FROM (X1,Y1) TO (X2,Y2) EITHER
; 1. STANDARD FORM -- JUST A LINE CONNECTING THE 2 POINTS
; 2. ,B=BOXLINE -- RECTANGLE TREATING (X1,Y1) AND (X2,Y2) AS OPPOSITE CORNERS
; 3. ,BF= BOXFILL --  FILLED RECTANGLE WITH (X1,Y1) AND (X2,Y2) AS OPPOSITE CORNERS
;

; Routine at 22695
; Used by the routine at __LINE.
LINE:
  CALL SCAN1         ;SCAN THE FIRST COORDINATE
  PUSH BC            ;SAVE THE POINT
  PUSH DE
  RST SYNCHR
  DEFB TK_MINUS      ;MAKE SURE ITS PROPERLY SEPERATED
  CALL SCAND         ;SCAN THE SECOND SET            ; Get coordinates in BC, DE
  CALL ATRSCN        ;SCAN THE ATTRIBUTE
  POP DE             ;GET BACK THE FIRST POINT
  POP BC
  JR Z,DOLINE        ;IF STATEMENT ENDED ITS A NORMAL LINE
  RST SYNCHR
  DEFB ','           ;OTHERWISE MUST HAVE A COMMA
  RST SYNCHR
  DEFB 'B'           ;AND A "B"
  JP Z,BOXLIN        ;IF JUST "B" THE NON-FILLED BOX

  RST SYNCHR
  DEFB 'F'           ;MUST BE FILLED BOX
DOBOXF:
  PUSH HL            ;SAVE THE TEXT POINTER
  CALL SCALXY        ;SCALE FIRST POINT
  CALL XCHGAC        ;SWITCH POINTS
  CALL SCALXY        ;SCALE SECOND POINT
  CALL YDELT         ;SEE HOW MANY LINES AND SET CARRY
  CALL C,XCHGY       ;MAKE [D,E] THE SMALLEST Y
  INC HL             ;MAKE [H,L] INTO A COUNT
  PUSH HL            ;SAVE COUNT OF LINES
  CALL XDELT         ;GET WIDTH AND SMALLEST X
  CALL C,XCHGX       ;MAKE [B,C] THE SMALLEST X
  INC HL             ;MAKE [H,L] INTO A WIDTH COUNT
  PUSH HL            ;SAVE WIDTH COUNT
  CALL MAPXY         ;MAP INTO A "C"         (Set addresses for initial dot position)
  POP DE             ;GET WIDTH COUNT
  POP BC             ;GET LINE COUNT

BOXLOP:
  PUSH DE            ;SAVE WIDTH
  PUSH BC            ;SAVE NUMBER OF LINES
  CALL FETCHC        ;LOOK AT CURRENT C                  ; Save cursor
  PUSH AF            ;SAVE BIT MASK OF CURRENT "C"
  PUSH HL            ;SAVE ADDRESS
  EX DE,HL           ;SET UP FOR NSETCX WITH COUNT
  CALL NSETCX        ;IN [H,L] OF POINTS TO SETC
  POP HL             ;GET BACK STARTING C
  POP AF             ;ADDRESS AND BIT MASK
  CALL STOREC        ;SET UP AS CURRENT "C"              ; Restore cursor
  CALL DOWNC         ;MOVE TO NEXT LINE DOWN IN Y
  POP BC             ;GET BACK NUMBER OF LINES
  POP DE             ;GET BACK WIDTH
  DEC BC             ;COUNT DOWN LINES
  LD A,B             ;SEE IF ANY LEFT
  OR C
  JR NZ,BOXLOP       ;KEEP DRAWING MORE LINES
  POP HL             ;RESTORE TEXT POINTER
  RET
  
DOLINE:
  PUSH BC            ;SAVE COORDINATES
  PUSH DE
  PUSH HL            ;SAVE TEXT POINTER
  CALL DOGRPH
  LD HL,(GRPACX)     ;RESTORE ORIGINAL SECOND COORDINATE
  LD (GXPOS),HL
  LD HL,(GRPACY)     ;FOR BOXLIN CODE
  LD (GYPOS),HL
  POP HL             ;RESTORE TEXT POINTER
  POP DE
  POP BC
  RET
  
BOXLIN:
  PUSH HL            ;SAVE TEXT POINTER
  LD HL,(GYPOS)
  PUSH HL            ;SAVE Y2
  PUSH DE            ;SAVE Y1
  EX DE,HL           ;MOVE Y2 TO Y1
  CALL DOLINE        ;DO TOP LINE
  POP HL             ;MOVE Y1 TO Y2
  LD (GYPOS),HL
  EX DE,HL
  CALL DOLINE
  POP HL             ;GET BACK Y2
  LD (GYPOS),HL      ;AND RESTORE
  LD HL,(GXPOS)      ;GET X2
  PUSH BC            ;SAVE X1
  LD B,H             ;SET X1=X2
  LD C,L
  CALL DOLINE
  POP HL
  LD (GXPOS),HL      ;SET X2=X1
  LD B,H             ;RESTORE X1 TO [B,C]
  LD C,L
  CALL DOLINE
  POP HL             ;RESTORE THE TEXT POINTER
  RET


;
; DOGRPH DRAWS A LINE FROM ([B,C],[D,E]) TO (GXPOS,GYPOS)
;

; Routine at 22844
;
; Used by the routines at LINE and CLINE2.
DOGRPH:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HDOGR			; Hook for line drawing event
ENDIF
  CALL SCALXY           ;CHEATY SCALING - JUST TRUNCATE FOR NOW
  CALL XCHGAC
  CALL SCALXY
  CALL YDELT            ;GET COUNT DIFFERENCE IN [H,L]
  CALL C,XCHGAC         ;IF CURRENT Y IS SMALLER NO EXCHANGE
  PUSH DE               ;SAVE Y1 COORDINATE
  PUSH HL               ;SAVE DELTA Y
  CALL XDELT
  EX DE,HL              ;PUT DELTA X INTO [D,E]
  LD HL,RIGHTC          ;ASSUME X WILL GO RIGHT
  JR NC,LINCN2
  LD HL,LEFTC

LINCN2:
  EX (SP),HL            ;PUT ROUTINE ADDRESS ON STACK AND GET DELTA Y
  RST DCOMPR            ;SEE WHICH DELTA IS BIGGER
  JR NC,YDLTBG          ;YDELTA IS BIGGER OR EQUAL
  LD (MINDEL),HL        ;SAVE MINOR AXIS DELTA (Y)
  POP HL                ;GET X ACTION ROUTINE
  LD (MAXUPD+1),HL      ;SAVE IN MAJOR ACTION ADDRESS    ; MAXUPD = JP nn for RIGHTC, LEFTC and DOWNC 
  LD HL,DOWNC           ;ALWAYS INCREMENT Y
  LD (MINUPD+1),HL      ;WHICH IS THE MINOR AXIS         ; MINUPD = JP nn for RIGHTC, LEFTC and DOWNC 
  EX DE,HL              ;[H,L]=DELTA X=MAJOR DELTA
  JR LINCN3             ;MERGE WITH YDLTBG CASE AND DO DRAW

YDLTBG:
  EX (SP),HL            ;ACTION ROUTINE FOR X INTO [H,L],  SAVE DELTA Y ON THE STACK
  LD (MINUPD+1),HL      ;SAVE ADDRESS OF MINOR AXIS UPDATE      ; MINUPD = JP nn for RIGHTC, LEFTC and DOWNC 
  LD HL,DOWNC           ;Y IS ALWAYS INCREMENT MODE
  LD (MAXUPD+1),HL      ;SAVE AS MAJOR AXIS UPDATE              ; MAXUPD = JP nn for RIGHTC, LEFTC and DOWNC 
  EX DE,HL              ;[H,L]=DELTA X
  LD (MINDEL),HL        ;SAVE MINOR DELTA
  POP HL                ;[H,L]=DELTA Y=MAJOR DELTA




; MAJOR AXIS IS ONE WITH THE LARGEST DELTA
; MINOR IS THE OTHER
; READY TO DRAW NOW
; MINUPD+1=ADDRESS TO GO TO UPDATE MINOR AXIS COORDINATE
; MAXUPD+1=ADDRESS TO GO TO UPDATE MAJOR AXIS COORDINATE
; [H,L]=MAJOR AXIS DELTA=# OF POINTS-1
; MINDEL=DELTA ON MINOR AXIS
;
; IDEA IS
;  SET SUM=MAJOR DELTA/2
;  [B,C]=# OF POINTS
;  MAXDEL=-MAJOR DELTA (CONVENIENT FOR ADDING)
; LINE LOOP (LINLP3):
;       DRAW AT CURRENT POSITION
;       UPDATE MAJOR AXIS
;       SUM=SUM+MINOR DELTA
;       IF SUM.GT.MAJOR DELTA THEN UPDATE MINOR AND SUM=SUM-MAJOR DELTA
;       DECREMENT [B,C] AND TEST FOR 0 -- LOOP IF NOT
; END LOOP
;
LINCN3:
  POP DE                ;GET BACK Y1
  PUSH HL
  CALL NEGHL
  LD (MAXDEL),HL        ;SAVE MAJOR DELTA FOR SUMMING
  CALL MAPXY            ;GET POSITION INTO BITMSK AND [H,L]             ; Set addresses for initial dot position
  POP DE
  PUSH DE               ;START SUM AT MAXDEL/2
  CALL DE_DIV2          ; "RR DE"
  POP BC                ;GET COUNT IN [B,C]
  INC BC                ;NUMBER OF POINTS IS DELTA PLUS ONE
  JR LINLP3

; Routine at 22931
LINLOP:
  POP HL
  LD A,B               ;CONTINUE UNTIL COUNT EXHAUSTED
  OR C
  RET Z
LINLOP_0:
  CALL MAXUPD          ;UPDATE MAJOR AXIS


	
; Inner loop of line code.
;
; This entry point is used by the routine at DOGRPH.
LINLP3:
  CALL SETC               ;SET CURRENT POINT
  DEC BC
  PUSH HL
  LD HL,(MINDEL)          ;ADD SMALL DELTA TO SUM
  ADD HL,DE
  EX DE,HL
  LD HL,(MAXDEL)
  ADD HL,DE
  JR NC,LINLOP          ;TIME TO UPDATE MINOR?
  EX DE,HL
  POP HL
  LD A,B                ;CONTINUE UNTIL COUNT EXHAUSTED
  OR C
  RET Z
  CALL MINUPD           ;UPDATE MAJOR AXIS		; MINUPD = JP nn for RIGHTC, LEFTC and DOWNC 
  JR LINLOP_0


; a.k.a. HLFDE
; Routine at 22964
; "RR DE" - Used by the routines at DOGRPH, __CIRCLE and DSCLDE.
DE_DIV2:
  LD A,D
  OR A          ;CLEAR CARRY
  RRA           ;SCALE MEANS SHIFTING RIGHT ONE
  LD D,A
  LD A,E
  RRA
  LD E,A
  RET


; Routine at 22972
;
; Used by the routine at ATRSCN.
IN_GFX_MODE:
  LD A,(SCRMOD)
  CP $02
  RET P
  JP FC_ERR			; Err $05 - "Illegal function call"


; PAINT - Fill an area with color
;
; Routine at 22981
__PAINT:
  CALL SCAN1            ;GET (X,Y) OF START
  PUSH BC               ;SAVE COORDS OF START
  PUSH DE
  CALL ATRSCN           ;SET FILL ATTRIBUTE AS CURRENT
  LD A,(ATRBYT)         ;DEFAULT BORDER COLOR IS SAME AS FILL
  LD E,A                ;DEFAULT ATTRIBUTE TO [E] LIKE GETBYT
  DEC HL
  RST CHRGTB
  JR Z,GOTBRD           ;NOTHING THERE - USE DEFAULT
  RST SYNCHR
  DEFB ','              ;MAKE SURE OF COMMA
  CALL GETINT           ;GET BORDER COLOR ARGUMENT
GOTBRD:
  LD A,E                ;BORDER ATTRIBUTE TO A
  CALL PNTINI           ;INIT PAINT STUFF & CHECK BORDER ATTRIB
  JP C,FC_ERR			; Err $05 - "Illegal function call"
  POP DE                ;GET BACK START COORDS
  POP BC
  PUSH HL               ;SAVE TXTPTR UNTIL DONE
  CALL CHKRNG           ;MAKE SURE POINT IS ON SCREEN
  CALL MAPXY                          ; Set addresses for initial dot position
  LD DE,$0001           ;ENTRY COUNT IS ONE (SKIP NO BORDER)
  LD B,$00
  CALL SCANR1           ;SCAN RIGHT FROM INITIAL POSITION
  JR Z,POPTRT           ;STARTED ON BORDER - GET TXTPTR & QUIT
  PUSH HL               ;SAVE NO. OF POINTED PAINTED TO RIGHT
  CALL SCANL1           ;NOW SCAN LEFT FROM INITIAL POS.
  POP DE                ;GET RIGHT SCAN COUNT.
  ADD HL,DE             ;ADD TO LEFT SCAN COUNT
  EX DE,HL              ;COUNT TO [DE]
  XOR A
  CALL ENTST1
  LD A,$40              ;MAKE ENTRY FOR GOING DOWN
  CALL ENTST1
  LD B,$C0              ;CAUSE PAINTING UP
  JR STPAIN             ;START PAINTING UPWARD

; This entry point is used by the routines at STPAIN and __CIRCLE.
POPTRT:
  POP HL                ;GET BACK TEXTPTR
  RET


;
; MAIN PAINT LOOP
;

; Data block at 23050
PNTLOP:
  CALL CKCNTC           ;CHECK FOR CTRL-C ABORT
  LD   A,(LOHDIR)
  OR   A
  JR   Z,PNTLP1
  LD   HL,(LOHADR)
  PUSH HL
  LD   HL,(LOHMSK)
  PUSH HL
  LD   HL,(LOHCNT)
  PUSH HL
PNTLP1:
  POP  DE
  POP  BC
  POP  HL
  LD   A,C
  CALL STOREC           ; Restore cursor

STPAIN:
  LD  A,B               ;GET DIRECTION
  LD  (PDIREC),A        ; Direction of the paint
  ADD A,A               ;SEE WHETHER TO GO UP, DOWN, OR QUIT
  JR Z,POPTRT           ;IF ZERO, ALL DONE.
  PUSH DE               ;SAVE SKPCNT IN CASE TUP&TDOWN DON'T
  JR NC,PDOWN           ;IF POSITIVE, GO DOWN FIRST
  CALL TUPC             ;MOVE UP BEFORE SCANNING
  JR PDOWN2

PDOWN:
  CALL TDOWNC           ;SEE IF AT BOTTOM & MOVE DOWN IF NOT
PDOWN2:
  POP DE                ;GET SKPCNT BACK
  JR C,PNTLP1           ;OFF SCREEN - GET NEXT ENTRY
  LD B,$00
  CALL SCANR1           ;SCAN RIGHT & SKIP UP TO SKPCNT BORDER
  JP Z,PNTLP1           ;IF NO POINTS PAINTED, GET NEXT ENTRY

  XOR A
  LD (LOHDIR),A
  CALL SCANL1           ;NOW SCAN LEFT FROM START POINT
  LD E,L                ;[DE] = LEFT MOVCNT
  LD D,H
  OR A                  ;SEE IF LINE WAS ALREADY PAINTED
  JR Z,PNTLP3           ;IT WAS - DON'T MAKE OVERHANG ENTRY
  DEC HL                ;IF LMVCNT.GT.1, NEED TO MAKE ENTRY
  DEC HL                ;IN OPPOSITE DIRECTION FOR OVERHANG.
  LD A,H
  ADD A,A               ;SEE IF [HL] WAS .GT. 1
  JR C,PNTLP3
  LD (LOHCNT),DE
  CALL FETCHC			;GET CURRENT POINT ADDRESS
  LD (LOHADR),HL
  LD (LOHMSK),A         ;CMASK
  LD A,(PDIREC)         ;GET BACK DIRECTION AND INDEX
  CPL
  LD (LOHDIR),A
PNTLP3:
  LD HL,(MOVCNT)        ;GET COUNT PAINTED DURING RIGHT SCAN
  ADD HL,DE             ;ADD TO LEFT MOVCNT
  EX DE,HL              ;ENTRY COUNT TO [DE]
  CALL ENTSLR           ;GO MAKE ENTRY.

  LD HL,(CSAVEA)        ;SET CURRENT LOCATION BACK TO END
  LD A,(CSAVEM)         ;OF RIGHT SCAN.
  CALL STOREC

PNTLP4:
  LD HL,(SKPCNT)        ;CALC SKPCNT - MOVCNT TO SEE IF
  LD DE,(MOVCNT)        ;ANY MORE BORDER TO SKIP
  OR A
  SBC HL,DE
  JR Z,GOPLOP           ;NO MORE - END OF THIS SCAN
  JR C,PNTLP6           ;RIGHT OVERHANG - SEE IF ENTRY NEEDED
  EX DE,HL              ;SKIP COUNT TO [DE] FOR SCANR
  LD B,$01
  CALL SCANR1           ;HERE IF NEED TO CONTINUE RIGHT SCAN
  JR Z,GOPLOP           ;NO MORE POINTS.
  OR A                  ;SEE IF LINE ALREADY PAINTED
  JR Z,PNTLP4           ;YES, DON'T ENTER ANYTHING
  EX DE,HL              ;ENTRY COUNT TO [DE]
  LD HL,(CSAVEA)        ;MAKE ENTRY AT LOCATION SAVED BY SCANR
  LD A,(CSAVEM)         ;SO WE CAN ENTER A POSITIVE SKPCNT
  LD C,A
  LD A,(PDIREC)
  LD B,A
  CALL ENTSTK           ;MAKE ENTRY
  JR PNTLP4             ;CONTINUE UNTIL SKPCNT .LE. 0
  
PNTLP6:
  CALL NEGHL            ;MAKE NEW SKPCNT POSITIVE
  DEC HL                ;IF SKPCNT-MOVCNT .LT. -1
  DEC HL                ;THEN RIGHT OVERHANG ENTRY IS NEEDED.
  LD A,H                ;SEE IF POSITIVE.
  ADD A,A
  JR C,GOPLOP           ;OVERHANG TOO SMALL FOR NEW ENTRY

  INC HL                ;NOW MOVE LEFT TO BEGINNING OF SCAN
  PUSH HL               ;SO WE CAN ENTER A POSITIVE SKPCNT
RTOVH1:
  CALL LEFTC            ;START IS -(SKPCNT-MOVCNT)-1 TO LEFT
  DEC HL
  LD A,H
  OR L
  JR NZ,RTOVH1
;RTOVH2:
  POP DE                ;GET BACK ENTRY SKPCNT INTO [DE]
  LD A,(PDIREC)         ;MAKE ENTRY IN OPPOSITE DIRECTION
  CPL
  CALL ENTST1           ;MAKE ENTRY
GOPLOP:
  JP PNTLOP             ;GO PROCESS NEXT ENTRY



; Routine at 23234
;
; Used by the routine at STPAIN.
ENTSLR:
  LD A,(LFPROG)         ;DON'T STACK IF SCANNED LINE
  LD C,A                ;WAS ALREADY PAINTED
  LD A,(RTPROG)
  OR C
  RET Z                 ;Z IF SCAN LINE ALREADY PAINTED

  LD A,(PDIREC)
; This entry point is used by the routines at __PAINT and STPAIN.
ENTST1:
  LD B,A                ;DIRECTION IN [B]
  CALL FETCHC			;LOAD REGS WITH CURRENT "C"
  LD C,A                ;BIT MASK IN [C]

; This entry point is used by the routine at STPAIN.
ENTSTK:
  EX (SP),HL
  PUSH BC
  PUSH DE
  PUSH HL
  LD C,$02
  JP CHKSTK             ;IS ENOUGH SPACE LEFT OUT

; Data block at 23260
SCANR1:
  CALL SCANR            ;PERFORM LOW LEVEL RIGHT SCAN
  LD   (SKPCNT),DE      ;SAVE UPDATED SKPCNT
  LD   (MOVCNT),HL      ;SAVE MOVCNT
  LD   A,H              ;SET CC'S ON MOVCNT
  OR   L
  LD   A,C              ;GET ALREADY-PAINTED FLAG FROM [C]
  LD   (RTPROG),A
  RET


; Data block at 23277
SCANL1:
  CALL FETCHC           ;GET CURRENT LOCATION
  PUSH HL               ;AND SWAP WITH CSV
  PUSH AF
  LD   HL,(CSAVEA)
  LD   A,(CSAVEM)
  CALL STOREC           ;REPOS AT BEGINNING OF SCAN
  POP  AF               ;REGET PLACE WHERE RT SCN STOPPED
  POP  HL
  LD   (CSAVEA),HL      ;AND SAVE IT IN TEMP LOCATION
  LD   (CSAVEM),A
  CALL SCANL            ;NOW DO LOW LEVEL LEFT SCAN
  LD   A,C              ;GET ALREADY-PAINTED FLAG FROM [C]
  LD   (LFPROG),A       ;WHETHER IT WAS ALREADY PAINTED
  RET
		


; Routine at 23307
;
; Used by the routines at CPLOT8, DRUP, DRLEFT, DRWHHH, DRWEEE, DRWGGG and DMOVE.
NEGDE:
  EX DE,HL
  CALL NEGHL
  EX DE,HL
  RET



;
;       CIRCLE - DRAW A CIRCLE
;
; SYNTAX: CIRCLE @(X,Y),RADIUS[,ATRB[,+/-STARTANG[,+/-ENDANG[,ASPECT]]]]
;

; Routine at 23313
__CIRCLE:
  CALL SCAN1            ;GET (X,Y) OF CENTER INTO GRPACX,Y
  RST SYNCHR
  DEFB ','              ;EAT COMMA
  CALL FPSINT_0         ;GET THE RADIUS
  PUSH HL               ;SAVE TXTPTR
  EX DE,HL
  LD (GXPOS),HL         ;SAVE HERE TILL START OF MAIN LOOP
  CALL MAKINT           ;PUT INTEGER INTO FAC
  CALL __CSNG           ;CONVERT TO SINGLE PRECISION
  LD BC,$7040           ;LOAD REGS WITH SQR(2)/2   (BCDE = 0.707107)
  LD DE,$0771
  CALL FMULT            ;DO FLOATING PT MULTIPLY
  CALL __CINT           ;CONVERT TO INTEGER & GET INTO [HL]
  LD (CNPNTS),HL        ;CNPNTS=RADIUS*SQR(2)/2=# PTS TO PLOT
  XOR A                 ;ZERO OUT CLINEF - NO LINES TO CENTER
  LD (CLINEF),A
  LD (CSCLXY),A         ;INITIALLY SCALING Y
  POP HL                ;REGET TXTPTR
  CALL ATRSCN           ;SCAN POSSIBLE ATTRIBUTE
  LD C,$01              ;SET LO BIT IN CLINEF FOR LINE TO CNTR
  LD DE,$0000           ;DEFAULT START COUNT = 0
  CALL CGTCNT           ;PARSE THE BEGIN ANGLE
  PUSH DE               ;SAVE COUNT FOR LATER COMPARISON
  LD C,$80              ;SET HI BIT IN CLINEF FOR LINE TO CNTR
  LD DE,$FFFF           ;DEFAULT END COUNT = INFINITY
  CALL CGTCNT           ;PARSE THE END ANGLE
  EX (SP),HL            ;GET START COUNT, PUSH TXTPTR TILL DONE
  XOR A
  EX DE,HL              ;REVERSE REGS TO TEST FOR .LT.
  RST DCOMPR            ;SEE IF END .GE. START
  LD A,$00
  JR NC,CSTPLT          ;YES, PLOT POINTS BETWEEN STRT & END
  DEC A                 ;PLOT POINTS ABOVE & BELOW
  EX DE,HL              ;SWAP START AND END SO START .LT. END
  PUSH AF               ;Swap sense of center line flags
  LD A,(CLINEF)
  LD C,A
  RLCA
  RLCA
  OR C
  RRCA
  LD (CLINEF),A         ;Store swapped flags
  POP AF
CSTPLT:
  LD (CPLOTF),A         ;SET UP PLOT POLARITY FLAG
  LD (CSTCNT),DE        ;STORE START COUNT
  LD (CENCNT),HL        ;AND END COUNT
  POP HL                ;GET TXTPTR
  DEC HL                ;NOW SEE IF LAST CHAR WAS A COMMA
  RST CHRGTB
  JR NZ,CIRC1           ;SOMETHING THERE
  PUSH HL               ;SAVE TXTPTR
  CALL GTASPC           ;GET DEFAULT ASPECT RATIO INTO [HL]
  LD A,H
  OR A                  ;IS ASPECT RATIO GREATER THAN ONE?
  JR Z,CIRC2            ;BRIF GOOD ASPECT RATIO
  LD A,$01
  LD (CSCLXY),A
  EX DE,HL              ;ASPECT RATIO IS GREATER THAN ONE, USE INVERSE
  JR CIRC2              ;NOW GO CONVERT TO FRACTION OF 256

CIRC1:
  RST SYNCHR
  DEFB ','              ;EAT COMMA
  CALL EVAL
  PUSH HL               ;SAVE TXTPTR
  CALL __CSNG           ;MAKE IT FLOATING POINT
  CALL SIGN                ; test FP number sign
  JP Z,FC_ERR              ; Err $05 - "Illegal function call"
  JP M,FC_ERR              ; Err $05 - "Illegal function call"
  CALL CMPONE           ;SEE IF GREATER THAN ONE
  JR NZ,__CIRCLE_2      ;LESS THAN ONE - SCALING Y
  INC A                 ;MAKE [A] NZ
  LD (CSCLXY),A         ;FLAG SCALING X
  CALL FDIV             ;RATIO = 1/RATIO
__CIRCLE_2:
  LD BC,$2543			;MAKE NUMBER FRACTION OF 256   (BCDE = 256 (float))
  LD DE,$0060
  CALL FMULT            ;BY MULTIPLYING BY 2^8 (256)
  CALL __CINT           ;MAKE IT AN INTEGER IN [HL]
CIRC2:
  LD (ASPECT),HL        ;STORE ASPECT RATIO

;
;       CIRCLE ALGORITHM
;
;       [HL]=X=RADIUS * 2 (ONE BIT FRACTION FOR ROUNDING)
;       [DE]=Y=0
;       SUM =0
; LOOP: IF Y IS EVEN THEN
;             REFLECT((X+1)/2,(Y+1)/2) (I.E., PLOT POINTS)
;             IF X.LT.Y THEN EXIT
;       SUM=SUM+2*Y+1
;       Y=Y+1
;       IF SUM.GGWGRP.RNO
;             SUM=SUM-2*X+1
;             X=X-1
;       ENDIF
;       GOTO LOOP
;

  LD DE,$0000           ;INIT Y = 0
  LD (CRCSUM),DE        ;SUM = 0
  LD HL,(GXPOS)         ;X = RADIUS*2
  ADD HL,HL

CIRCLP:
  CALL CKCNTC
  LD A,E                ;TEST EVENNESS OF Y
  RRA                   ;TO SEE IF WE NEED TO PLOT
  JR C,CRCLP2           ;Y IS ODD - DON'T TEST OR PLOT
  PUSH DE               ;SAVE Y AND X
  PUSH HL
  INC HL                ;ACTUAL COORDS ARE (X+1)/2,(Y+1)/2
  EX DE,HL              ;(PLUS ONE BEFORE DIVIDE TO ROUND UP)
  CALL DE_DIV2		; "RR DE"
  EX DE,HL
  INC DE
  CALL DE_DIV2		; "RR DE"
  CALL CPLOT8
  POP DE                ;RESTORE X AND Y
  POP HL                ;INTO [DE] AND [HL] (BACKWARDS FOR CMP)
  RST DCOMPR            ;QUIT IF Y .GE. X
  JP NC,POPTRT          ;GO POP TXTPTR AND QUIT
  EX DE,HL
CRCLP2:
  LD B,H                ;GET OFFSETS INTO PROPER REGISTERS
  LD C,L                ;[BC]=X
  LD HL,(CRCSUM)
  INC HL                ;SUM = SUM+2*Y+1
  ADD HL,DE
  ADD HL,DE
  LD A,H                ;NOW CHECK SIGN OF RESULT
  ADD A,A
  JR C,CNODEX           ;DON'T ADJUST X IF WAS NEGATIVE
  PUSH DE               ;SAVE Y
  EX DE,HL              ;[DE]=SUM
  LD H,B                ;[HL]=X
  LD L,C
  ADD HL,HL             ;[HL]=2*X-1
  DEC HL
  EX DE,HL              ;PREPARE TO SUBTRACT
  OR A
  SBC HL,DE             ;CALC SUM-2*X+1
  DEC BC                ;X=X-1
  POP DE                ;GET Y BACK
CNODEX:
  LD (CRCSUM),HL        ;UPDATE CIRCLE SUM
  LD H,B                ;GET X BACK TO [HL]
  LD L,C
  INC DE                ;Y=Y+1
  JR CIRCLP

; Routine at 23546
;
; Used by the routine at CPLOT8.
CPLSCX:
  PUSH DE
  CALL SCALEY
  POP HL                ;GET UNSCALED INTO [HL]
  LD A,(CSCLXY)         ;SEE WHETHER ASPECT WAS .GT. 1
  OR A 
  RET Z
  EX DE,HL
  RET                   ;DON'T SWAP IF ZERO


;
; REFLECT THE POINTS AROUND CENTER
; [HL]=X OFFSET FROM CENTER, [DE]=Y OFFSET FROM CENTER
;

; Routine at 23558
;
; Used by the routine at __CIRCLE.
CPLOT8:
  LD (CPCNT),DE         ;POINT COUNT IS ALWAYS = Y
  PUSH HL               ;SAVE X
  LD HL,$0000           ;START CPCNT8 OUT AT 0
  LD (CPCNT8),HL
  CALL CPLSCX           ;SCALE Y AS APPROPRIATE
  LD (CXOFF),HL         ;SAVE CXOFF
  POP HL                ;GET BACK X
  EX DE,HL
  PUSH HL               ;SAVE INITIAL [DE]
  CALL CPLSCX           ;SCALE X AS APPROPRIATE
  LD (CYOFF),DE
  POP DE                ;GET BACK INITIAL [DE]
  CALL NEGDE            ;START: [DE]=-Y,[HL]=X,CXOFF=Y,CY=X

  CALL CPLOT4           ;PLOT +X,-SY -Y,-SX -X,+SY +Y,-SX

  PUSH HL
  PUSH DE
  LD HL,(CNPNTS)        ;GET # PNTS PER OCTANT
  LD (CPCNT8),HL        ;AND SET FOR DOING ODD OCTANTS
  LD DE,(CPCNT)         ;GET POINT COUNT
  OR A
  SBC HL,DE             ;ODD OCTANTS ARE BACKWARDS SO
  LD (CPCNT),HL         ;PNTCNT = PNTS/OCT - PNTCNT
  LD HL,(CXOFF)         ;NEED TO NEGATE CXOFF TO START OUT RIGHT
  CALL NEGHL
  LD (CXOFF),HL
  POP DE
  POP HL
  CALL NEGDE            ;ALSO NEED TO MAKE [DE]=-SX=-[DE]
                        ;PLOT +Y,-SX -X,-SY -Y,+SX +X,+SY
                        ;(FALL THRU TO CPLOT4)
CPLOT4:
  LD A,$04              ;LOOP FOUR TIMES
CPLOT:
  PUSH AF               ;SAVE LOOP COUNT
  PUSH HL               ;SAVE BOTH X & Y OFFSETS
  PUSH DE
  PUSH HL               ;SAVE TWICE
  PUSH DE
  LD DE,(CPCNT8)        ;GET NP*OCTANT*8
  LD HL,(CNPNTS)        ;ADD SQR(2)*RADIUS FOR NEXT OCTANT
  ADD HL,HL
  ADD HL,DE
  LD (CPCNT8),HL        ;UPDATE FOR NEXT TIME
  LD HL,(CPCNT)         ;CALC THIS POINT'S POINT COUNT
  ADD HL,DE             ;ADD IN PNTCNT*OCTANT*NP
  EX DE,HL              ;SAVE THIS POINT'S COUNT IN [DE]
  LD HL,(CSTCNT)        ;GET START COUNT
  RST DCOMPR
  JR Z,CLINSC           ;SEE IF LINE TO CENTER REQUIRED
  JR NC,CNBTWN          ;IF SC .GT. PC, THEN NOT BETWEEN
  LD HL,(CENCNT)        ;GET END COUNT
  RST DCOMPR
  JR Z,CLINEC           ;GO SEE IF LINE FROM CENTER NEEDED
  JR NC,CBTWEN          ;IF EC .GT. PC, THEN BETWEEN

CNBTWN:
  LD A,(CPLOTF)         ;SEE WHETHER TO PLOT OR NOT
  OR A                  ;IF NZ, PLOT POINTS NOT IN BETWEEN
  JR NZ,CPLTIT          ;NEED TO PLOT NOT-BETWEEN POINTS
  JR GCPLFN             ;DON'T PLOT - FIX UP STACK & RETURN

CLINEC:
  LD A,(CLINEF)         ;GET CENTER LINE FLAG BYTE
  ADD A,A               ;BIT 7=1 MEANS DRAW LINE FROM CENTER
  JR NC,CPLTIT          ;NO LINE REQUIRED - JUST PLOT POINT
  JR CLINE              ;LINE REQUIRED.

CLINSC:
  LD A,(CLINEF)         ;GET CENTER LINE FLAG BYTE
  RRA                   ;BIT 0=1 MEANS LINE FROM CENTER NEEDED.
  JR NC,CPLTIT          ;NO LINE REQUIRED - JUST PLOT POINT

CLINE:
  POP DE                ;GET X & Y OFFSETS
  POP HL
  CALL GTABSC           ;GO CALC TRUE COORDINATE OF POINT
  CALL CLINE2           ;DRAW LINE FROM [BC],[DE] TO CENTER
  JR CPLFIN
  
CBTWEN:
  LD A,(CPLOTF)         ;SEE WHETHER PLOTTING BETWEENS OR NOT
  OR A
  JR Z,CPLTIT           ;IF Z, THEN DOING BETWEENS
GCPLFN:
  POP DE                ;CLEAN UP STACK
  POP HL
  JR CPLFIN

CPLTIT:
  POP DE                ;GET X & Y OFFSETS
  POP HL
  CALL GTABSC           ;CALC TRUE COORDINATE OF POINT
  CALL SCALXY           ;SEE IF POINT OFF SCREEN
  JR NC,CPLFIN          ;NC IF POINT OFF SCREEN - NO PLOT
  CALL MAPXY
  CALL SETC             ;PLOT THE POINT
CPLFIN:
  POP DE                ;GET BACK OFFSETS
  POP HL
  POP AF                ;GET BACK LOOP COUNT
  DEC A
  RET Z                 ;QUIT IF DONE.
  PUSH AF               ; PUSH PSW
  PUSH DE               ;SAVE X OFFSET
  LD DE,(CXOFF)         ;SWAP [HL] AND CXOFF
  CALL NEGDE            ;NEGATE NEW [HL]
  LD (CXOFF),HL         ;SWAP [DE] AND CYOFF
  EX DE,HL              ;NEGATE NEW [DE]
  POP DE
  PUSH HL
  LD HL,(CYOFF)
  EX DE,HL
  LD (CYOFF),HL
  CALL NEGDE
  POP HL
  POP AF                ; POP PSW
  JP CPLOT              ;PLOT NEXT POINT

; Routine at 23757
;
; Used by the routines at CPLOT8 and DMOVE.
CLINE2:
  LD HL,(GRPACX)        ;DRAW LINE FROM [BC],[DE]
  LD (GXPOS),HL         ;TO GRPACX,Y
  LD HL,(GRPACY)
  LD (GYPOS),HL
  JP DOGRPH             ;GO DRAW THE LINE

;
; GTABSC - GET ABSOLUTE COORDS
; ([BC],[DE])=(GRPACX+[HL],GRPACY+[DE])
;
; Routine at 23772
; Used by the routines at CPLOT8 and DMOVE.
GTABSC:
  PUSH DE               ;SAVE Y OFFSET FROM CENTER
  LD DE,(GRPACX)        ;GET CENTER POS
  ADD HL,DE             ;ADD TO DX
  LD B,H                ;[BC]=X CENTER + [HL]
  LD C,L
  POP DE
  LD HL,(GRPACY)        ;GET CENTER Y
  ADD HL,DE
  EX DE,HL              ;[DE]=Y CENTER + [DE]
  RET


; Routine at 23787
; Used by the routine at CPLSCX.
SCALEY:
  LD HL,(ASPECT)        ;SCALE [DE] BY ASPECT RATIO
  LD A,L                ;CHECK FOR *0 AND *1 CASES
  OR A                  ;ENTRY TO DO [A]*[DE] ([A] NON-Z)
  JR NZ,SCAL2           ;NON-ZERO
  OR H                  ;TEST HI BYTE
  RET NZ                ;IF NZ, THEN WAS *1 CASE
  EX DE,HL              ;WAS *0 CASE - PUT 0 IN [DE]
  RET

	
SCAL2:
  LD C,D
  LD D,$00
  PUSH AF
  CALL SCL_MULTIPLY
  LD E,$80              ; ROUND UP
  ADD HL,DE
  LD E,C
  LD C,H
  POP AF
  CALL SCL_MULTIPLY
  LD E,C
  ADD HL,DE
  EX DE,HL
  RET

; Routine at 23818
;
; Used by the routine at SCALEY.
SCL_MULTIPLY:
  LD B,$08
  LD HL,$0000
SCL_MULTIPLY_0:
  ADD HL,HL
  ADD A,A
  JR NC,SCL_MULTIPLY_1
  ADD HL,DE
SCL_MULTIPLY_1:
  DJNZ SCL_MULTIPLY_0
  RET


;
; PARSE THE BEGIN AND END ANGLES
;  SETTING APPROPRIATE BITS IN CLINEF IF NEG.
;

; Routine at 23831
; Used by the routine at __CIRCLE.
CGTCNT:
  DEC HL
  RST CHRGTB            ;GET CURRENT CHAR
  RET Z                 ;IF NOTHING, RETURN DFLT IN [DE]
  RST SYNCHR
  DEFB ','              ;EAT THE COMMA
  CP ','                ;USE DEFAULT IF NO ARGUMENT.
  RET Z
  PUSH BC               ;SAVE FLAG BYTE IN [C]
  CALL EVAL             ;EVALUATE THE THING
  EX (SP),HL            ;POP FLAG BYTE, PUSH TXTPTR
  PUSH HL               ;RESAVE FLAG BYTE
  CALL __CSNG           ;MAKE IT A SINGLE PRECISION VALUE
  POP BC                ;GET BACK FLAG BYTE
  LD HL,FACCU           ;NOW SEE WHETHER POSITIVE OR NOT
  LD A,(HL)             ;GET EXPONENT BYTE
  OR A
  JP P,CGTCNT_0
  AND $7F               ;MAKE IT POSITIVE
  LD (HL),A
  LD HL,CLINEF          ;SET BIT IN [C] IN CLINEF
  LD A,(HL)
  OR C
  LD (HL),A

CGTCNT_0:
  LD BC,$1540			;LOAD REGS WITH 1/2*PI  (BCDE = 0.159155)
  LD DE,$5591
  CALL FMULT            ;MULTIPLY BY 1/(2*PI) TO GET FRACTION
  CALL CMPONE           ;SEE IF RESULT IS GREATER THAN ONE
  JP Z,FC_ERR			;FC ERROR IF SO   (Err $05 - "Illegal function call")
  CALL PUSHF            ;SAVE FAC ON STAC
  LD HL,(CNPNTS)        ;GET NO. OF POINTS PER OCTANT
  ADD HL,HL             ;TIMES 8 FOR TRUE CIRCUMFERENCE
  ADD HL,HL
  ADD HL,HL
  CALL MAKINT           ;STICK IT IN FAC
  CALL __CSNG           ;AND MAKE IT SINGLE PRECISION
  POP BC                ;GET BACK ANG/2*PI IN REGS
  POP DE
  CALL FMULT            ;DO THE MULTIPLY
  CALL __CINT           ;CONVERT TO INTEGER IN [HL]
  POP DE                ;GET BACK TXTPTR
  EX DE,HL
  RET

; Routine at 23907
;
; Used by the routines at __CIRCLE and CGTCNT.
CMPONE:
  LD BC,$1041           ;MAKE SURE FAC IS LESS THAN ONE  ..BCDE = 1 (float)
  LD DE,$0000
  CALL FCOMP
  DEC A
  RET

; Routine at 23918
__DRAW:
  LD A,(SCRMOD)
  CP $02
  JP C,FC_ERR           ;DRAW not allowed in text mode   (Err $05 - "Illegal function call")
  LD DE,DRAW_TAB        ;DISPATCH TABLE FOR GML
  XOR A
  LD (DRWFLG),A
  LD (MCLFLG),A
  JP MACLNG



; Data at 23939   ($5D83)
; JP table for the Graphics Macro Language (GML)

DRAW_TAB:

  DEFB 'U'+$80  ;UP
  DEFW DRUP     ; Draw a line of <DE> pixels in a straight upward direction

  DEFB 'D'+$80  ;DOWN
  DEFW DRDOWN	; Draw a line of <DE> pixels in a straight downward direction

  DEFB 'L'+$80  ;LEFT
  DEFW DRLEFT	; Draw a line of <DE> pixels to the left

  DEFB 'R'+$80  ;RIGHT
  DEFW DRIGHT	; Draw a line of <DE> pixels to the right

  DEFB 'M'		;MOVE
  DEFW DMOVE	; Draw a line to a specific location (x,y) or a location relative to the current position (M+20,-20)

  DEFB 'E'+$80	; -,-
  DEFW DRWEEE	; Draw a diagonal line of <DE> pixels (line goes upward and to the right)

  DEFB 'F'+$80	; +,-
  DEFW DRWFFF	; Draw a diagonal line of <DE> pixels (line goes downward and to the right)

  DEFB 'G'+$80	; +,+
  DEFW DRWGGG	; Draw a diagonal line of <DE> pixels (line goes downward and to the left)

  DEFB 'H'+$80	; -,+
  DEFW DRWHHH	; Draw a diagonal line of <DE> pixels (line goes upward and to the left)

  DEFB 'A'+$80  ;ANGLE COMMAND
  DEFW DANGLE	; Change the orientation of the drawing to 0 (normal), 1 (90 degrees clockwise), 2 (180 degrees clockwise) or 3 (270 degrees clockwise)

  DEFB 'B'      ;MOVE WITHOUT PLOTTING
  DEFW DNOPLT	; Move to the location specified by the command, but don't draw a line 

  DEFB 'N'      ;DON'T CHANGE CURRENT COORDS
  DEFW DNOMOV	; Return to the starting position after performing the command 

  DEFB 'X'      ;EXECUTE STRING
  DEFW MCLXEQ	; X<string> Execute a sub-string of instructions 

  DEFB 'C'+$80      ;COLOR
  DEFW DCOLR	; Change the foreground (drawing) color to <color>
  
  DEFB 'S'+$80   ;SCALE
  DEFW DSCALE	; S<scale> Scale every length specified after this command by <scale/4> pixels.
  
  DEFB $00		;END OF TABLE   (Table termination)

  
  
  
  
;MOVE +0,-Y
; Draw a line of <DE> pixels in a straight upward direction
DRUP:
  CALL NEGDE

;MOVE +0,+Y
; Draw a line of <DE> pixels in a straight downward direction
DRDOWN:
  LD BC,$0000     ;DX=0
  JR DOMOVR       ;TREAT AS RELATIVE MOVE


;MOVE -X,+0
; Routine at 23993
; Used by the routine at L5D83.
; Draw a line of <DE> pixels to the left
DRLEFT:
  CALL NEGDE

;MOVE +X,+0
; Draw a line of <DE> pixels to the right
DRIGHT:
  LD B,D          ;[BC]=VALUE
  LD C,E
  LD DE,$0000     ;DY=0
  JR DOMOVR       ;TREAT AS RELATIVE MOVE

;MOVE -X,-Y
; Routine at 24003
; Draw a diagonal line of <DE> pixels (line goes upward and to the left)
DRWHHH:
  CALL NEGDE

;MOVE +X,+Y
; Draw a diagonal line of <DE> pixels (line goes downward and to the right)
DRWFFF:
  LD B,D
  LD C,E
  JR DOMOVR

;MOVE +X,-Y
; Routine at 24010
; Draw a diagonal line of <DE> pixels (line goes upward and to the right)
DRWEEE:
  LD B,D
  LD C,E
; This entry point is used by the routine at DRWGGG.
DRWHHC:
  CALL NEGDE
  JR DOMOVR

;MOVE -X,+Y
; Routine at 24017
; Draw a diagonal line of <DE> pixels (line goes downward and to the left)
DRWGGG:
  CALL NEGDE
  LD B,D
  LD C,E
  JR DRWHHC       ;MAKE DY POSITIVE & GO



; Routine at 24024
; Draw a line to a specific location (x,y) or a location relative to the current position (M+20,-20)
DMOVE:
  CALL FETCHZ     ;GET NEXT CHAR AFTER COMMA
  LD B,$00        ;ASSUME RELATIVE
  CP '+'          ;IF "+" OR "-" THEN RELATIVE
  JR Z,MOVREL
  CP '-'
  JR Z,MOVREL
  INC B           ;NON-Z TO FLAG ABSOLUTE
  
MOVREL:
  LD A,B
  PUSH AF         ;SAVE ABS/REL FLAG ON STACK
  CALL DECFET     ;BACK UP SO VALSCN WILL SEE "-"
  CALL VALSCN     ;GET X VALUE
  PUSH DE         ;SAVE IT
  CALL FETCHZ     ;NOW CHECK FOR COMMA
  CP ','          ;COMMA?
  JP NZ,FC_ERR    ; If not, Err $05 - "Illegal function call"
  CALL VALSCN     ;GET Y VALUE IN D
  POP BC          ;GET BACK X VALUE
  POP AF          ;GET ABS/REL FLAG
  OR A
  JR NZ,DRWABS    ;NZ - ABSOLUTE
  

; This entry point is used by the DRAW routines at DRUP, DRLEFT, DRWHHH and DRWEEE.
DOMOVR:
  CALL DSCLDE     ;ADJUST Y OFFSET BY SCALE
  PUSH DE         ;SAVE Y OFFSET
  LD D,B          ;GET X INTO [DE]
  LD E,C          ;GO SCALE IT.
  CALL DSCLDE     ;GET ADJUSTED X INTO [HL]
  EX DE,HL        ;GET ADJUSTED Y INTO [DE]
  POP DE
  LD A,(DRWANG)   ;GET ANGLE BYTE
  RRA             ;LOW BIT TO CARRY
  JR NC,ANGEVN    ;ANGLE IS EVEN - DON'T SWAP X AND Y
  PUSH AF         ;SAVE THIS BYTE
  CALL NEGHL      ;ALWAYS NEGATE NEW DY
  EX DE,HL
  POP AF          ;GET BACK SHIFTED ANGLE
ANGEVN:
  RRA             ;TEST SECOND BIT
  JR NC,ANGPOS    ;DON'T NEGATE COORDS IF NOT SET
  CALL NEGHL
  CALL NEGDE      ;NEGATE BOTH DELTAS
ANGPOS:
  CALL GTABSC     ;GO CALC TRUE COORDINATES
DRWABS:
  LD A,(DRWFLG)   ;SEE WHETHER WE PLOT OR NOT
  ADD A,A         ;CHECK HI BIT
  JR C,DSTPOS     ;JUST SET POSITION.
  PUSH AF         ;SAVE THIS FLAG
  PUSH BC         ;SAVE X,Y COORDS
  PUSH DE         ;BEFORE SCALE SO REFLECT DISTANCE OFF
  CALL CLINE2     ;SCALE IN CASE COORDS OFF SCREEN
  POP DE
  POP BC          ;GET THEM BACK
  POP AF          ;GET BACK FLAG
DSTPOS:
  ADD A,A         ;SEE WHETHER TO STORE COORDS
  JR C,DNSTOR     ;DON'T UPDATE IF B6=1
  LD (GRPACY),DE  ;UPDATE GRAPHICS AC
  LD H,B
  LD L,C
  LD (GRPACX),HL
DNSTOR:
  XOR A           ;CLEAR SPECIAL FUNCTION FLAGS   (Reset draw mode when finished drawing)
  LD (DRWFLG),A
  RET

; Routine at 24130
; Set flags to return to the starting position after performing the command 
DNOMOV:
  LD A,$40        ;SET BIT SIX IN FLAG BYTE
  JR DSTFLG

; Routine at 24134
; Set flags to move to the location specified by the command, but don't draw a line 
DNOPLT:
  LD A,$80        ;SET BIT 7

; This entry point is used by the routine at DNOMOV.
DSTFLG:
  LD HL,DRWFLG
  OR (HL)
  LD (HL),A       ;STORE UPDATED BYTE
  RET

; Data block at 24142
; Change the orientation of the drawing to 0 (normal), 1 (90 degrees clockwise), 2 (180 degrees clockwise) or 3 (270 degrees clockwise)
DANGLE:
  JR NC,DSCALE    ;ERROR IF NO ARG
  LD A,E          ;MAKE SURE LESS THAN 4
  CP $04
  JR NC,DSCALE    ;ERROR IF NOT
  LD (DRWANG),A	  ; DrawAngle (0..3): 1=90 degrees rotation .. 3=270 degrees, etc..
  RET

; S<scale> Scale every length specified after this command by <scale/4> pixels.
DSCALE:
  JP NC,FC_ERR			; Err $05 - "Illegal function call"
  LD A,D          ;MAKE SURE LESS THAN 256
  OR A
  JP NZ,FC_ERR			; Err $05 - "Illegal function call"
  LD A,E
  LD (DRWSCL),A   ;STORE SCALE FACTOR
  RET

; Routine at 24166
;
; Used by the routine at DMOVE.
DSCLDE:
  LD A,(DRWSCL)   ;GET SCALE FACTOR
  OR A            ;ZERO MEANS NO SCALING
  RET Z
  LD HL,$0000
DSCLP:
  ADD HL,DE       ;ADD IN [DE] SCALE TIMES
  DEC A
  JR NZ,DSCLP
  EX DE,HL        ;PUT IT BACK IN [DE]
  LD A,D          ;SEE IF VALUE IS NEGATIVE
  ADD A,A
  PUSH AF         ;SAVE RESULTS OF TEST
  JR NC,DSCPOS
  DEC DE          ;MAKE IT TRUNCATE DOWN
DSCPOS:
  CALL DE_DIV2    ;DIVIDE BY FOUR
  CALL DE_DIV2
  POP AF          ;SEE IF WAS NEGATIVE
  RET NC          ;ALL DONE IF WAS POSITIVE
  LD A,D          ;OR IN HIGH 2 BITS TO MAKE NEGATIVE
  OR $C0
  LD D,A
  INC DE          ;ADJUST SO TRUNCATING TO LOWER VALUE
  RET



DCOLR:
  JR NC,DSCALE    ; "NCFER": FC ERROR IF NO ARG
  LD A,E          ;GO SET ATTRIBUTE
  CALL SETATR     ; Set attribute byte
  JP C,FC_ERR     ;ERROR IF ILLEGAL ATTRIBUTE   ( Err $05 - "Illegal function call" )
  RET

; Routine at 24209
;
; Used by the routine at __PAINT.
CHKRNG:
  PUSH HL         ;SAVE TXTPTR
  CALL SCALXY
  JP NC,FC_ERR    ;OUT OF BOUNDS - ERROR   ( Err $05 - "Illegal function call" )
  POP HL          ;REGET TXTPTR
  RET

  
; Return from 'DIM' command
; a.k.a. DIMCON
DIMRET:
  DEC HL            ; DEC 'cos GETCHR INCs        ;SEE IF COMMA ENDED THIS VARIABLE
  RST CHRGTB		; Get next character
  RET Z             ; End of DIM statement        ;IF TERMINATOR, GOOD BYE
  RST SYNCHR 		; Make sure "," follows       
  DEFB ','                                        ;MUST BE COMMA
  
  
; 'DIM' BASIC command
;
; THE "DIM" CODE SETS DIMFLG AND THEN FALLS INTO THE VARIABLE
; SEARCH ROUTINE. THE VARIABLE SEARCH ROUTINE LOOKS AT
; DIMFLG AT THREE DIFFERENT POINTS:
;
;	1) IF AN ENTRY IS FOUND, DIMFLG BEING ON INDICATES
;		A "DOUBLY DIMENSIONED" VARIABLE
;	2) WHEN A NEW ENTRY IS BEING BUILT DIMFLG'S BEING ON
;		INDICATES THE INDICES SHOULD BE USED FOR
;		THE SIZE OF EACH INDICE. OTHERWISE THE DEFAULT
;		OF TEN IS USED.
;	3) WHEN THE BUILD ENTRY CODE FINISHES, ONLY IF DIMFLG IS
;		OFF WILL INDEXING BE DONE
;
__DIM:
  LD BC,DIMRET      ; Return to "DIMRET"    ;PLACE TO COME BACK TO
  PUSH BC           ; Save on stack

  DEFB $F6			; "OR n" to Mask 'XOR A' (Flag "Create" variable):   NON ZERO THING MUST TURN THE MSB ON

; Get variable address to DE (AKA PTRGET)
;
; ROUTINE TO READ THE VARIABLE NAME AT THE CURRENT TEXT POSITION
; AND PUT A POINTER TO ITS VALUE IN [D,E]. [H,L] IS UPDATED
; TO POINT TO THE CHARACTER AFTER THE VARIABLE NAME.
; VALTYP IS SETUP. NOTE THAT EVALUATING SUBSCRIPTS IN
; A VARIABLE NAME CAN CAUSE RECURSIVE CALLS TO PTRGET SO AT
; THAT POINT ALL VALUES MUST BE STORED ON THE STACK.
; ON RETURN, [A] DOES NOT REFLECT THE VALUE OF THE TERMINATING CHARACTER
;
; Used by the routines at __LET, __LINE, __READ, OPRND, __DEF, DOFN, PTRGET,
; __SWAP and __NEXT.
GETVAR:
  XOR A				; Find variable address,to DE           ;MAKE [A]=0
  LD (DIMFLG),A		; Set locate / create flag              ;FLAG IT AS SUCH
  LD C,(HL)			; Get First byte of name                ;GET FIRST CHARACTER IN [C]
  
; This entry point is used by the routine at GETFNM.
GTFNAM:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HPTRG		;  Hook for Variable search event
ENDIF
  CALL IS_LETTER  	; See if a letter                       ;CHECK FOR LETTER
  JP C,SN_ERR       ; ?SN Error if not a letter             ;MUST HAVE A LETTER
  XOR A
  LD B,A            ; Clear second byte of name
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JR C,ISSEC        ; JP if it WAS NUMERIC
  CALL ISLETTER_A	; See if a letter
  JR C,NOSEC        ; ALLOW ALPHABETICS
ISSEC:
  LD B,A
ENDNAM:
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JR C,ENDNAM
  CALL ISLETTER_A	; Check it is in the 'A'..'Z' range
  JR NC,ENDNAM
NOSEC:
  CP '%'+1          ;NOT A TYPE INDICATOR
  JR NC,TABTYP      ;THEN DONT CHECK THEM
  LD DE,HAVTYP      ;SAVE JUMPS BY USING RETURN ADDRESS
  PUSH DE           
  LD D,$02          ;CHECK FOR INTEGER
  CP '%'            
  RET Z             
  INC D             ;CHECK FOR STRING
  CP '$'            
  RET Z             
  INC D             ;CHECK FOR SINGLE PRECISION
  CP '!'            
  RET Z             
  LD D,$08          ;ASSUME ITS DOUBLE PRECISION
  CP '#'            ;CHECK THE CHARACTER
  RET Z             ;WHEN WE MATCH, SETUP VALTYP
  POP AF            ;POP OFF NON-USED HAVTYP ADDRESS
TABTYP:
  LD A,C            ;GET THE STARTING CHARACTER
  AND $7F           ;GET RID OF THE USER-DEFINED FUNCTION BIT IN [C]
  LD E,A            ;BUILD A TWO BYTE OFFSET
  LD D,$00          
  PUSH HL           ;SAVE THE TEXT POINTER
  LD HL,DEFTBL-'A'  ;SEE WHAT THE DEFAULT IS
  ADD HL,DE         
  LD D,(HL)         ;GET THE TYPE OUT OF THE TABLE
  POP HL            ;GET BACK THE TEXT POINTER
  DEC HL            ;NO MARKING CHARACTER
  
HAVTYP:
  LD A,D                                               ;SETUP VALTYP
  LD (VALTYP),A     ; Set variable type
  RST CHRGTB                                           ;READ PAST TYPE MARKER
  LD A,(SUBFLG)     ; Array name needed ?              ;GET FLAG WHETHER TO ALLOW ARRAYS
  DEC A                                                ;IF SUBFLG=1, "ERASE" HAS CALLED
  JP Z,ARLDSV       ; Yes - Get array name             ;PTRGET, AND SPECIAL HANDLING MUST BE DONE
  JP P,NSCFOR       ; No array with "FOR" or "FN"      ;NO ARRAYS ALLOWED
  LD A,(HL)         ; Get byte again                   ;GET CHAR BACK
  SUB '('           ; ..Subscripted variable?          ;ARRAY PERHAPS (IF SUBFLG SET NEVER WILL MATCH)
  JP Z,SBSCPT       ; Yes - Sort out subscript         ;IT IS!
  SUB '['-')'+1     ; ..Subscripted variable?          ;SEE IF LEFT BRACKET
  JP Z,SBSCPT       ; Yes - Sort out subscript         ;IF SO, OK SUBSCRIPT
  
; a.k.a. NOARYS
NSCFOR:
  XOR A                ;ALLOW PARENS AGAIN         ; Simple variable
  LD (SUBFLG),A        ;SAVE IN FLAG LOCATION      ; Clear "FOR" flag
  PUSH HL              ;SAVE THE TEXT POINTER      ; Save code string address
  LD A,(NOFUNS)        ;ARE FUNCTIONS ACTIVE?
  OR A                 
  LD (PRMFLG),A        ;INDICATE IF PARM1 NEEDS SEARCHING
  JR Z,SNFUNS          ;NO FUNCTIONS SO NO SPECIAL SEARCH
  LD HL,(PRMLEN)       ;GET THE SIZE TO SEARCH
  LD DE,PARM1          ;GET THE BASE OF THE SEARCH
  ADD HL,DE            ;[H,L]= PLACE TO STOP SEARCHING
  LD (ARYTA2),HL       ;SET UP STOPPING POINT
  EX DE,HL             ;[H,L]=START [D,E]=END
  JR LOPFND            ;START LOOPING

; Routine at 24355
LOPTOP:
  LD A,(DE)            ;GET THE VALTYP OF THIS SIMPLE VARIABLE
  LD L,A               ;SAVE SO WE KNOW HOW MUCH TO SKIP
  INC DE
  LD A,(DE)            ;[A]=FIRST CHARACTER OF THIS VARIABLE
  INC DE               ;POINT TO 2ND CHAR OF VAR NAME
  CP C                 ;SEE IF OUR VARIABLE MATCHES
  JR NZ,NOTIT1
  LD A,(VALTYP)        ;GET TYPE WERE LOOKING FOR
  CP L                 ;COMPARE WITH OUR VALTYP
  JR NZ,NOTIT1         ;NOT RIGHT KIND -- SKIP IT
  LD A,(DE)            ;SEE IF SECOND CHACRACTER MATCHES
  CP B
  JP Z,FINPTR          ;THAT WAS IT, ALL DONE

NOTIT1:
  INC DE

  LD H,$00             ;[H,L]=NUMBER OF BYTES TO SKIP
  ADD HL,DE            ;ADD ON THE POINTER
  
LOPFND:
  EX DE,HL             ;[D,E]=POINTER INTO SIMPLE VARIABLES
  LD A,(ARYTA2)        ;ARE LOW BYTES DIFFERENT
  CP E                 ;TEST
  JP NZ,LOPTOP         ;YES
  LD A,(ARYTA2+1)      ;ARE HIGH BYTES DIFFERENT
  CP D                 ;THE SAME?
  JR NZ,LOPTOP         ;NO, MUST BE MORE VARS TO EXAMINE
;NOTFNS:
  LD A,(PRMFLG)        ;HAS PARM1 BEEN SEARCHED
  OR A
  JR Z,SMKVAR          ;IF SO, CREATE VARIABLE
  XOR A                ;FLAG PARM1 AS SEARCHED
  LD (PRMFLG),A

SNFUNS:
  LD HL,(ARYTAB)       ;STOPPING POINT IS [ARYTA2]
  LD (ARYTA2),HL       
  LD HL,(VARTAB)       ;SET UP STARTING POINT
  JR LOPFND

; Routine at 24413
;
; Used by the routine at VARPTR.
PTRGET:
  CALL GETVAR
VARRET:
  RET


; THIS IS EXIT FOR VARPTR AND OTHERS
; Routine at 24417
VARNOT:
  LD D,A               ;ZERO [D,E]
  LD E,A
  POP BC               ;GET RID OF PUSHED [D,E]
  EX (SP),HL           ;PUT RETURN ADDRESS BACK ON STACK
  RET                  ;RETURN FROM PTRGET

; Routine at 24422
;
; a.k.a. CFEVAL
; Used by the routine at LOPTOP.
SMKVAR:
  POP HL               ;[H,L]= TEXT POINTER
  EX (SP),HL           ;[H,L]= RETURN ADDRESS
  PUSH DE              ;SAVE CURRENT VARIABLE TABLE POSITION
  LD DE,VARRET         ;ARE WE RETURNING TO VARPTR?
  RST DCOMPR           ;COMPARE
  JR Z,VARNOT          ;YES.
  LD DE,COMPTR         ;RETURN HERE IF NOT FOUND
  RST DCOMPR
  POP DE               ;RESTORE THE POSITION
  JR Z,FINZER          ;MAKE FAC ZERO (ALL TYPES) AND SKIP RETURN
  EX (SP),HL           ;PUT RETURN ADDRESS BACK
  PUSH HL              ;PUT THE TEXT POINTER BACK
  PUSH BC              ;SAVE THE LOOKS
  LD A,(VALTYP)        ;GET LENGTH OF SYMBOL TABLE ENTRY
  LD C,A               ;[C]=VALTYP
  PUSH BC              ;SAVE THE VALTYP ON THE STACK
  LD B,$00             ;[B]=0
  INC BC               ;MAKE THE LENGTH INCLUDE
  INC BC               ;THE LOOKS TOO
  INC BC
  LD HL,(STREND)       ;EVERYTHING UP BY THE CURRENT END OF STORAGE
  PUSH HL              ;SAVE THIS #
  ADD HL,BC            ;ADD ON THE AMOUNT OF SPACE EXTRA NOW BEING USED
  POP BC               ;POP OFF HIGH ADDRESS TO MOVE
  PUSH HL              ;SAVE NEW CANDIDATE FOR STREND
  CALL MOVUP           ;BLOCK TRANSFER AND MAKE SURE WE ARE NOT OVERFLOWING THE STACK SPACE
  POP HL               ;[H,L]=NEW STREND
  LD (STREND),HL       ;STORE SINCE WAS OK
                       ;THERE WAS ROOM, AND BLOCK TRANSFER WAS DONE, SO UPDATE POINTERS
  LD H,B               ;GET BACK [H,L] POINTING AT THE END
  LD L,C               ;OF THE NEW VARIABLE
  LD (ARYTAB),HL       ;UPDATE THE ARRAY TABLE POINTE
ZEROER:
  DEC HL               ;[H,L] IS RETURNED POINTING TO THE
  LD (HL),$00          ;END OF THE VARIABLE SO WE
  RST DCOMPR           ;ZERO BACKWARDS TO [D,E] WHICH
  JR NZ,ZEROER         ;POINTS TO THE START OF THE VARIABLE
  POP DE
  LD (HL),E            ;PUT DESCRIPTION
  INC HL
  POP DE               ;OF THIS VARIABLE INTO MEMORY
  LD (HL),E
  INC HL
  LD (HL),D
  EX DE,HL             ;POINTER AT VARIABLE INTO [D,E]

; This entry point is used by the routine at LOPTOP.
FINPTR:
  INC DE               ;POINT TO VALUE OF VAR
  POP HL               ;RESTORE TEXT POINTER
  RET                  ;ALL DONE WITH THIS VAR

;
; MAKE ALL TYPES ZERO AND SKIP RETURN
;
FINZER:
  LD (FACCU),A         ;MAKE SINGLES AND DOUBLES ZERO
  LD H,A               ;MAKE INTEGERS ZERO
  LD L,A
  LD (FACLOW),HL
  RST GETYPR           ;SEE IF ITS A STRING
  JR NZ,POPHR2         ;IF NOT, DONE
  LD HL,NULL_STRING    ;MAKE IT A NULL STRING BY
  LD (FACLOW),HL       ;POINTING AT A ZERO
POPHR2:
  POP HL               ;GET THE TEXT POINTER
  RET                  ;RETURN FROM EVAL


; MULTIPLE DIMENSION CODE
;

; FORMAT OF ARRAYS IN CORE
;
; DESCRIPTOR 
;	LOW BYTE = SECOND CHARCTER (200 BIT IS STRING FLAG)
;	HIGH BYTE = FIRST CHARACTER
;	LENGTH OF ARRAY IN CORE IN BYTES (DOES NOT INCLUDE DESCRIPTOR)
;	NUMBER OF DIMENSIONS 1 BYTE FOR EACH DIMENSION 
;		STARTING WITH THE FIRST A LIST (2 BYTES EACH) OF THE MAX INDICE+1
;	THE VALUES
;
; SBSCPT (a.k.a. ISARY): Sort out subscript
; Data block at 24506
; Used by the routine at GETVAR.
SBSCPT:
  PUSH HL			; Save code string address
  LD HL,(DIMFLG)
  EX (SP),HL		; Save and get code string
  LD D,A			; Zero number of dimensions
SCPTLP:
  PUSH DE			; Save number of dimensions
  PUSH BC			; Save array name
  CALL INTIDX		; Get subscript                 ;EVALUATE INDICE INTO [D,E]
  POP BC            ;POP OFF THE LOOKS
  POP AF			;[A] = NUMBER OF DIMENSIONS SO FAR
  EX DE,HL          ;[D,E]=TEXT POINTER <> [H,L]=INDICE
  EX (SP),HL		;PUT THE INDICE ON THE STACK <> [H,L]=VALTYP & DIMFLG   ; Save subscript value
  PUSH HL			;RESAVE VALTYP AND DIMFLG                               ; Save NAMTMP and TYPE
  EX DE,HL          ;[H,L]=TEXT POINTER
  INC A				;INCREMENT # OF DIMENSIONS                              ; Count dimensions
  LD D,A			;[D]=NUMBER OF DIMENSIONS                               ; Save in D
  LD A,(HL)			;GET TERMINATING CHARACTER                              ; Get next byte in code string
  CP ','            ;A COMMA SO MORE INDICES FOLLOW?                        ; Comma (more to come)?
  JP Z,SCPTLP       ;IF SO, READ MORE                                       ; Yes - More subscripts
  CP ')'            ;EXPECTED TERMINATOR?                                   ; Make sure ")" follows
  JR Z,DOCHRT       ;DO CHRGET FOR NEXT ONE
  CP ']'            ;BRACKET?
  JP NZ,SN_ERR      ;NO, GIVE ERROR

DOCHRT:
  RST CHRGTB		; Gets next character (or token) from BASIC text.

;SUBSOK:
  LD (NXTOPR),HL    ;SAVE THE TEXT POINTER
  POP HL            ;[H,L]= VALTYP & DIMFLG
  LD (DIMFLG),HL    ;SAVE VALTYP AND DIMFLG
  LD E,$00          ;WHEN [D,E] IS POPED INTO PSW, WE DON'T WANT THE ZERO FLAG TO BE SET,
                    ;SO "ERASE" WILL HAVE A UNIQUE CONDITION
  PUSH DE           ;SAVE NUMBER OF DIMENSIONS
  
  defb $11          ; "LD DE,nn", OVER THE NEXT TWO BYTES

; a.k.a. ERSFIN
; Used by the routine at HAVTYP.
ARLDSV:
  PUSH HL            ; Save code string address         ;SAVE THE TEXT POINTER
  PUSH AF            ; A = 00 , Flags set = Z,N         ;SAVE A DUMMY NUMBER OF DIMENSIONS WITH THE ZERO FLAG SET
;
; AT THIS POINT [B,C]=LOOKS. THE TEXT POINTER IS IN TEMP2.
; THE INDICES ARE ALL ON THE STACK, FOLLOWED BY THE NUMBER OF DIMENSIONS.
;
  LD HL,(ARYTAB)     ; Start of arrays                  ;[H,L]=PLACE TO START THE SEARCH

  DEFB $3E           ; "LD A,n" AROUND THE NEXT BYTE

FNDARY:
  ADD HL,DE          ; Move to next array start
  LD DE,(STREND)     ; End of arrays
  RST DCOMPR		 ; Compare HL with DE.
  JR Z,CREARY        ; Yes - Create array
  LD E,(HL)          ; Get type
  INC HL             ; Move on
  LD A,(HL)          ; Get second byte of name
  INC HL             ; Move on
  CP C               ; Compare with name given (second byte)
  JR NZ,NXTARY       ; Different - Find next array
  LD A,(VALTYP)
  CP E               ; Compare type
  JR NZ,NXTARY       ; Different - Find next array
  LD A,(HL)          ; Get first byte of name
  CP B               ; Compare with name given (first byte)
NXTARY:
  INC HL             ; POINT TO SIZE ENTRY
  LD E,(HL)          ; GET VAR NAME LENGTH IN [E]
  INC HL             ; ADD ONE TO GET CORRECT LENGTH
  LD D,(HL)          ; HIGH BYTE OF ZERO
  INC HL             ; ADD OFFSET
  JR NZ,FNDARY       ; Not found - Keep looking                    ;IF NO MATCH, SKIP THIS ONE AND TRY AGAIN
  LD A,(DIMFLG)      ; Found Locate or Create it?                  ;SEE IF CALLED BY "DIM"
  OR A                                                             ;ZERO MEANS NO
  JP NZ,DD_ERR		 ; Create - Err $0A - "Redimensioned array"    ;PRESERVE [D,E], AND DISPATCH TO
                                                                   ;"REDIMENSIONED VARIABLE" ERROR
                                                                   ;IF ITS "DIM" CALLING PTRGET
;
; TEMP2=THE TEXT POINTER
; WE HAVE LOCATED THE VARIABLE WE WERE LOOKING FOR
; AT THIS POINT [H,L] POINTS BEYOND THE SIZE TO THE NUMBER OF DIMENSIONS
; THE INDICES ARE ON THE STACK FOLLOWED BY THE NUMBER OF DIMENSIONS
;
  POP AF             ; Locate - Get number of dim'ns               ;[A]=NUMBER OF DIMENSIONS
  LD B,H             ; BC Points to array dim'ns                   ;SET [B,C] TO POINT AT NUMBER OF DIMENSIONS
  LD C,L
  JP Z,POPHLRT		 ; Jump if array load/save                     ;"ERASE" IS DONE AT THIS POINT, SO RETURN TO DO THE ACTUAL ERASURE
  SUB (HL)           ; Same number of dimensions?                  ;MAKE SURE THE NUMBER GIVEN NOW
                                                                   ;AND WHEN THE ARRAY WAS SET UP ARE THE SAME
  JP Z,FINDEL        ; Yes - Find element                          ;JUMP OFF AND READ THE INDICES....

  ; --- START PROC BS_ERR ---
BS_ERR:
  LD DE,$0009		; ERR $09 - "Subscript out of range"
  JP ERROR

;
; HERE WHEN VARIABLE IS NOT FOUND IN THE ARRAY TABLE
;
; BUILDING AN ENTRY:
; 
;	PUT DOWN THE DESCRIPTOR	
;	SETUP NUMER OF DIMENSIONS
;	MAKE SURE THERE IS ROOM FOR THE NEW ENTRY
;	REMEMBER VARPTR
;	TALLY=4 (VALTYP FOR THE EXTENDED)
;	SKIP 2 LOCS FOR LATER FILL IN -- THE SIZE
; LOOP:	GET AN INDICE
;	PUT NUMBER +1 DOWN AT VARPTR AND INCREMENT VARPTR
;	TALLY= TALLY * NUMBER+1
;	DECREMENT NUMBER-DIMS
;	JNZ	LOOP
;	CALL REASON WITH [H,L] REFLECTING LAST LOC OF VARIABLE
;	UPDATE STREND
;	ZERO BACKWARDS
;	MAKE TALLY INCLUDE MAXDIMS
;	PUT DOWN TALLY
;	IF CALLED BY DIMENSION, RETURN
;	OTHERWISE INDEX INTO THE VARIABLE AS IF IT WERE FOUND ON THE INITIAL SEARCH
;
CREARY:
  LD A,(VALTYP)         ;GET VALTYP OF NEW VAR
  LD (HL),A             ;PUT DOWN THE VARIABLE TYPE
  INC HL
  LD E,A
  LD D,$00              ;[D,E]=SIZE OF ONE VALUE (VALTYP)
  POP AF                ; Array to save or 0 dim'ns?
  JP Z,FC_ERR			; Err $05 - "Illegal function call"
  LD (HL),C             ;PUT DOWN THE DESCRIPTOR                  ; Save second byte of name
  INC HL
  LD (HL),B                                                       ; Save first byte of name
  INC HL
  LD C,A                ; Number of dimensions to C  (=NUMBER OF TWO BYTE ENTRIES NEEDED TO STORE THE SIZE OF EACH DIMENSION)
  CALL CHKSTK           ; Check if enough memory                  ;GET SPACE FOR DIMENSION ENTRIES
  INC HL                ; Point to number of dimensions           ;SKIP OVER THE SIZE LOCATIONS
  INC HL                
  LD (TEMP3),HL         ; Save address of pointer     ;SAVE THE LOCATION TO PUT THE SIZE IN -- POINTS AT THE NUMBER OF DIMENSIONS
  LD (HL),C             ; Set number of dimensions    ;STORE THE NUMBER OF DIMENSIONS
  INC HL
  LD A,(DIMFLG)         ; Locate of Create?           ;CALLED BY DIMENSION?
  RLA                   ; Carry set = Create          ;SET CARRY IF SO
  LD A,C                ; Get number of dimensions    ;[A]=NUMBER OF DIMENSIONS
CRARLP:
  LD BC,10+1            ; Default dimension size 10
  JR NC,DEFSIZ          ; Locate - Set default size        ;DEFAULT DIMENSIONS TO TEN
  POP BC                ; Get specified dimension size     ;POP OFF AN INDICE INTO [B,C]
  INC BC                ; Include zero element             ;ADD ONE TO IT FOR THE ZERO ENTRY
DEFSIZ:
  LD  (HL),C            ; Save LSB of dimension size       ;PUT THE MAXIMUM DOWN
  PUSH AF               ; Save num' of dim'ns an status    ;SAVE THE NUMBER OF DIMENSIONS AND DIMFLG (CARRY)
  INC HL                
  LD  (HL),B            ; Save MSB of dimension size
  INC HL
  CALL MLDEBC           ; Multiply DE by BC to find amount of mem needed   ;MULTIPLY [B,C]=NEWMAX BY CURTOL=[D,E]
  POP AF                ; Restore number of dimensions      ;GET THE NUMBER OF DIMENSIONS AND DIMFLG (CARRY) BACK
  DEC A                 ; Count them                        ;DECREMENT THE NUMBER OF DIMENSIONS LEFT
  JR  NZ,CRARLP         ; Do next dimension if more         ;HANDLE THE OTHER INDICES
  PUSH AF               ; Save locate/create flag           ;SAVE DIMFLG (CARRY)
  LD  B,D               ; MSB of memory needed              ;[B,C]=SIZE
  LD  C,E               ; LSB of memory needed
  EX  DE,HL                                                 ;[D,E]=START OF VALUES
  ADD HL,DE             ; Add bytes to array start          ;[H,L]=END OF VALUES
  JP  C,OM_ERR          ; Too big - Error                   ;OUT OF MEMORY POINTER BEING GENERATED?
  CALL ENFMEM           ; See if enough memory              ;SEE IF THERE IS ROOM FOR THE VALUES
  LD  (STREND),HL       ; Save new end of array             ;UPDATE THE END OF STORAGE

ZERARY:
  DEC HL                ; Back through array data           ;ZERO THE NEW ARRAY
  LD  (HL),$00          ; Set array element to zero
  RST DCOMPR		    ; All elements zeroed?              ;BACK AT THE BEGINNING?
  JR  NZ,ZERARY         ; No - Keep on going                ;NO, ZERO MORE
  INC BC                ; Number of bytes + 1               ;ADD ONE TO THE SIZE TO INCLUDE THE BYTE FOR THE NUMBER OF DIMENSIONS
  LD  D,A               ; A=0                               ;[D]=ZERO
  LD  HL,(TEMP3)        ; Get address of array              ;GET A POINTER AT THE NUMBER OF DIMENSIONS
  LD  E,(HL)            ; Number of dimensions              ;[E]=NUMBER OF DIMENSIONS
  EX  DE,HL             ; To HL                             ;[H,L]=NUMBER OF DIMENSIONS
  ADD HL,HL             ; Two bytes per dimension size      ;[H,L]=NUMBER OF DIMENSIONS TIMES TWO
  ADD HL,BC             ; Add number of bytes               ;ADD ON THE SIZE TO GET THE TOTAL NUMBER OF BYTES USED
  EX  DE,HL             ; Bytes needed to DE                ;[D,E]=TOTAL SIZE
  DEC HL                                                    ;BACK UP TO POINT TO LOCATION TO PUT
  DEC HL                                                    ;THE SIZE OF THE ARRAY IN BYTES IN.
  LD  (HL),E            ; Save LSB of bytes needed          ;PUT DOWN THE SIZE
  INC HL                
  LD  (HL),D            ; Save MSB of bytes needed
  INC HL                
  POP AF                ; Locate / Create?                  ;GET BACK DIMFLG (CARRY) AND SET [A]=0
  JR  C,ENDDIM          ; A is 0 , End if create

;
; AT THIS POINT [H,L] POINTS BEYOND THE SIZE TO THE NUMBER OF DIMENSIONS
; STRATEGY:
;	NUMDIM=NUMBER OF DIMENSIONS
;	CURTOL=0
; INLPNM:GET A NEW INDICE
;	POP NEW MAX INTO CURMAX
;	MAKE SURE INDICE IS NOT TOO BIG
;	MUTLIPLY CURTOL BY CURMAX
;	ADD INDICE TO CURTOL
;	NUMDIM=NUMDIM-1
;	JNZ	INLPNM
;	USE CURTOL*4 (VALTYP FOR EXTENDED) AS OFFSET
;
; a.k.a. GETDEF
FINDEL:
  LD  B,A               ; Find array element               ;[B,C]=CURTOL=ZERO
  LD  C,A
  LD  A,(HL)            ; Number of dimensions             ;[A]=NUMBER OF DIMENSIONS
  INC HL                                                   ;POINT PAST THE NUMBER OF DIMENSIONS
  DEFB $16                ; "LD D,n" to skip "POP HL"      ;"MVI D," AROUND THE NEXT BYTE
  
INLPNM:
  POP HL                ; Address of next dim' size        ;[H,L]= POINTER INTO VARIABLE ENTRY
  LD  E,(HL)            ; Get LSB of dim'n size            ;[D,E]=MAXIMUM FOR THE CURRENT INDICE
  INC HL                
  LD  D,(HL)            ; Get MSB of dim'n size
  INC HL
  EX  (SP),HL           ; Save address - Get index         ;[H,L]=CURRENT INDICE, POINTER INTO THE VARIABLE GOES ON THE STACK
  PUSH AF               ; Save number of dim'ns            ;SAVE THE NUMBER OF DIMENSIONS
  RST DCOMPR		    ; Dimension too large?             ;SEE IF THE CURRENT INDICE IS TOO BIG
  JP  NC,BS_ERR         ; Yes - ?BS Error                  ;IF SO "BAD SUBSCRIPT" ERROR
  CALL MLDEBC           ; Multiply previous by size        ;CURTOL=CURTOL*CURRENT MAXIMUM
  ADD HL,DE             ; Add index to pointer             ;ADD THE INDICE TO CURTOL
  POP AF                ; Number of dimensions             ;GET THE NUMBER OF DIMENSIONS IN [A]
  DEC A                 ; Count them                       ;SEE IF ALL THE INDICES HAVE BEEN PROCESSED
  LD  B,H               ; MSB of pointer                   ;[B,C]=CURTOL IN CASE WE LOOP BACK
  LD  C,L               ; LSB of pointer
  JR  NZ,INLPNM         ; More - Keep going                ;PROCESS THE REST OF THE INDICES
  LD A,(VALTYP)         ; SEE HOW BIG THE VALUES ARE AND MULTIPLY BY THAT SIZE
  LD B,H                ; SAVE THE ORIGINAL VALUE FOR MULTIPLYING
  LD C,L                ; BY THREE
  ADD HL,HL             ; MULTIPLY BY TWO AT LEAST
  SUB $04               ; FOR INTEGERS AND STRINGS NO MORE MULTIPLYING BY TWO
  JR C,SMLVAL          
  ADD HL,HL             ;NOW MULTIPLIED BY FOUR
  JR Z,DONMUL           ;IF SINGLE ALL DONE
  ADD HL,HL             ;BY EIGHT FOR DOUBLES
SMLVAL:
  OR A                  ;FIX CC'S FOR Z-80
  JP PO,DONMUL          ;FOR STRINGS
  ADD HL,BC             ;ADD IN THE ORIGINAL
DONMUL:                
  POP BC                ; Start of array                   ;POP OFF THE ADDRESS OF WHERE THE VALUES BEGIN
  ADD HL,BC             ; Point to element                 ;ADD IT ONTO CURTOL TO GET THE PLACE THE VALUE IS STORED
  EX DE,HL              ; Address of element to DE         ;RETURN THE POINTER IN [D,E]

; a.k.a. FINNOW
ENDDIM:                 
  LD HL,(NXTOPR)		; Got code string address          ;REGET THE TEXT POINTER
  RET                   


; PRINT USING
;
; PRINT#<filenumber>,[USING<string exp>;]<list of exps>
; To write data to a sequential disk file.
;
; COME HERE AFTER THE "USING" CLAUSE IN A PRINT STATEMENT IS RECOGNIZED.
; THE IDEA IS TO SCAN THE USING STRING UNTIL THE VALUE LIST IS EXHAUSTED,
; FINDING STRING AND NUMERIC FIELDS TO PRINT VALUES OUT OF THE LIST IN,
; AND JUST OUTPUTING ANY CHARACTERS THAT AREN'T PART OF A PRINT FIELD.
;
; Routine at 24753
USING:
  CALL EVAL_0           ;EVALUATE THE "USING" STRING
  CALL TSTSTR           ;MAKE SURE IT IS A STRING
  RST SYNCHR
  DEFB ';'              ;MUST BE DELIMITED BY A SEMI-COLON
  EX DE,HL              ;[D,E]=TEXT POINTER
  LD HL,(FACLOW)        ;GET POINTER TO "USING" STRING DESCRIPTOR
  JR USING_1            ;DONT POP OFF OR LOOK AT USFLG

; Routine at 24767
;
; Used by the routine at L61C4.
REUSST:
  LD A,(FLGINP)         ;DID WE PRINT OUT A VALUE LAST SCAN?
  OR A                  ;SET CC'S
  JR Z,FCERR3           ;NO, GIVE ERROR
  POP DE                ;[D,E]=POINTER TO "USING" STRING DESCRIPTOR
  EX DE,HL              ;[D,E]=TEXT POINTER
USING_1:                
  PUSH HL               ;SAVE THE POINTER TO "USING" STRING DESCRIPTOR
  XOR A                 ;INITIALLY INDICATE THERE ARE MORE VALUES IN THE VALUE LIST
  LD (FLGINP),A         ;RESET THE FLAG THAT SAYS VALUES PRINTED
  INC A                 ;TURN THE ZERO FLAG OFF TO INDICATE THE VALUE LIST HASN'T ENDED
  PUSH AF               ;SAVE FLAG INDICATING WHETHER THE VALUE LIST HAS ENDED
  PUSH DE               ;SAVE THE TEXT POINTER INTO THE VALUE LIST
  LD B,(HL)             ;[B]=LENGTH OF THE "USING" STRING
  INC B                 ;SEE IF ITS ZERO
  DEC B
FCERR3:
  JP Z,FC_ERR			;IF SO, Err $05 - "Illegal function call"
  INC HL                ;[H,L]=POINTER AT THE "USING" STRING'S
  LD A,(HL)             ;DATA
  INC HL
  LD H,(HL)             
  LD L,A
  JR PRCCHR             ;GO INTO THE LOOP TO SCAN THE "USING" STRING

; Data block at 24796
BGSTRF:
  LD E,B                ;SAVE THE "USING" STRING CHARACTER COUNT
  PUSH HL               ;SAVE THE POINTER INTO THE "USING" STRING
  LD C,$02              ;THE \\ STRING FIELD HAS 2 PLUS NUMBER OF ENCLOSED SPACES WIDTH
LPSTRF:                 
  LD A,(HL)             ;GET THE NEXT CHARACTER
  INC HL                ;ADVANCE THE POINTER AT THE "USING" STRINGDATA
  CP '\\'               ;THE FIELD TERMINATOR?
  JP Z,ISSTRF           ;GO EVALUATE A STRING AND PRINT
  CP ' '                ;A FIELD EXTENDER?
  JR NZ,NOSTRF          ;IF NOT, ITS NOT A STRING FIELD
  INC C                 ;INCREMENT THE FIELD WIDTH
  DJNZ LPSTRF           ;KEEP SCANNING FOR THE FIELD TERMINATOR
;
; SINCE  STRING FIELD WASN'T FOUND, THE "USING" STRING 
; CHARACTER COUNT AND THE POINTER INTO IT'S DATA MUST
; BE RESTORED AND THE "\" PRINTED
;
NOSTRF:
  POP HL                ;RESTORE THE POINTER INTO "USING" STRING'S DATA
  LD B,E                ;RESTORE THE "USING" STRING CHARACTER COUNT
  LD A,'\\'             ;RESTORE THE CHARACTER

;
; HERE TO PRINT THE CHARACTER IN [A] SINCE IT WASN'T PART OF ANY FIELD
;
NEWUCH:
  CALL PLS_PRNT         ;IF A "+" CAME BEFORE THIS CHARACTER MAKE SURE IT GETS PRINTED
  RST OUTDO             ;PRINT THE CHARACTER THAT WASN'T PART OF A FIELD
PRCCHR:
  XOR A                 ;SET [D,E]=0 SO IF WE DISPATCH
  LD E,A                ;SOME FLAGS ARE ALREADY ZEROED
  LD D,A                ;DON'T PRINT "+" TWICE
PLSFIN:
  CALL PLS_PRNT         ;ALLOW FOR MULTIPLE PLUSES IN A ROW
  LD D,A                ;SET "+" FLAG
  LD A,(HL)             ;GET A NEW CHARACTER
  INC HL                
  CP '!'                ;CHECK FOR A SINGLE CHARACTER
  JP Z,SMSTRF           ;STRING FIELD
  CP '#'                ;CHECK FOR THE START OF A NUMERIC FIELD 
  JR Z,NUMNUM           ;GO SCAN IT
  CP '&'                ;SEE IF ITS A VARIABLE LENGTH STRING FIELD
  JP Z,VARSTR           ;GO PRINT ENTIRE STRING
  DEC B                 ;ALL THE OTHER POSSIBILITIES REQUIRE AT LEAST 2 CHARACTERS
  JP Z,REUSIN           ;IF THE VALUE LIST IS NOT EXHAUSTED GO REUSE "USING" STRING
  CP '+'                ;A LEADING "+" ?
  LD A,$08              ;SETUP [D] WITH THE PLUS-FLAG ON IN
  JR Z,PLSFIN           ;CASE A NUMERIC FIELD STARTS
  DEC HL                ;POINTER HAS ALREADY BEEN INCREMENTED
  LD A,(HL)             ;GET BACK THE CURRENT CHARACTER
  INC HL                ;REINCREMENT THE POINTER
  CP '.'                ;NUMERIC FIELD WITH TRAILING DIGITS
  JR Z,DOTNUM           ;IF SO GO SCAN WITH [E]=NUMBER OF DIGITS BEFORE THE "."=0
  CP '\\'               ;CHECK FOR A BIG STRING FIELD STARTER
  JR Z,BGSTRF           ;GO SEE IF IT REALLY IS A STRING FIELD
  CP (HL)               ;SEE IF THE NEXT CHARACTER MATCHES THE CURRENT ONE
  JR NZ,NEWUCH          ;IF NOT, CAN'T HAVE $$ OR ** SO ALL THE POSSIBILITIES ARE EXHAUSTED
  CP '$'                ;IS IT $$ ?
  JR Z,DOLRNM           ;GO SET UP THE FLAG BIT
  CP '*'                ;IS IT ** ?
  JR NZ,NEWUCH          ;IF NOT, ITS NOT PART OF A FIELD SINCE ALL THE POSSIBILITIES HAVE BEEN TRIED
  INC HL                ;SEE IF THE "USING" STRING IS LONG
  LD A,B                ;CHECK FOR $
  CP $02                ;ENOUGH FOR THE SPECIAL CASE OF
  JR C,_NOTSPC          ; **$
  LD A,(HL)
  CP '$'                ;IS THE NEXT CHARACTER $ ?
_NOTSPC:
  LD A,32               ;SET THE ASTERISK BIT
  JR NZ,SPCNUM          ;IF IT NOT THE SPECIAL CASE, DON'T SET THE DOLLAR SIGN FLAG
  DEC B                 ;DECREMENT THE "USING" STRING CHARACTER COUNT TO TAKE THE $ INTO CONSIDERATION
  INC E                 ;INCREMENT THE FIELD WIDTH FOR THE FLOATING DOLLAR SIGN

  DEFB $FE		; CP AFh ..hides the "XOR A" instruction (MVI SI,  IN 8086)

DOLRNM:
  XOR A                 ;CLEAR [A]
  ADD A,$10             ;SET BIT FOR FLOATING DOLLAR SIGN FLAG
  INC HL                ;POINT BEYOND THE SPECIAL CHARACTERS
SPCNUM:
  INC E                 ;SINCE TWO CHARACTERS SPECIFY THE FIELD SIZE, INITIALIZE [E]=1
  ADD A,D               ;PUT NEW FLAG BITS IN [A]
  LD D,A                ;INTO [D]. THE PLUS FLAG MAY HAVE ALREADY BEEN SET
NUMNUM:
  INC E                 ;INCREMENT THE NUMBER OF DIGITS BEFORE THE DECIMAL POINT
  LD C,$00              ;SET THE NUMBER OF DIGITS AFTER THE DECIMAL POINT = 0
  DEC B                 ;SEE IF THERE ARE MORE CHARACTERS
  JR Z,ENDNUS           ;IF NOT, WE ARE DONE SCANNING THIS NUMERIC FIELD
  LD A,(HL)             ;GET THE NEW CHARACTER
  INC HL                ;ADVANCE THE POINTER AT THE "USING" STRING DATA
  CP '.'                ;DO WE HAVE TRAILING DIGITS?
  JR Z,AFTDOT           ;IF SO, USE SPECIAL SCAN LOOP
  CP '#'                ;MORE LEADING DIGITS ?
  JR Z,NUMNUM           ;INCREMENT THE COUNT AND KEEP SCANNING
  CP ','
  JR NZ,FINNUM
  LD A,D                ;TURN ON THE COMMA BIT
  OR 64
  LD D,A
  JR NUMNUM             ;GO SCAN SOME MORE

;
; HERE WHEN A "." IS SEEN IN THE "USING" STRING
; IT STARTS A NUMERIC FIELD IF AND ONLY IF
; IT IS FOLLOWED BY A "#"
;
DOTNUM:
  LD A,(HL)             ;GET THE CHARACTER THAT FOLLOWS
  CP '#'                ;IS THIS A NUMERIC FIELD?
  LD A,'.'              ;IF NOT, GO BACK AND PRINT "."
  JP NZ,NEWUCH
  LD C,$01              ;INITIALIZE THE NUMBER OF DIGITS AFTER THE DECIMAL POINT
  INC HL
AFTDOT:
  INC C                 ;INCREMENT THE NUMBER OF DIGITS AFTER THE DECIMAL POINT
  DEC B                 ;SEE IF THE "USING" STRING HAS MORE
  JR Z,ENDNUS           ;CHARACTERS, AND IF NOT, STOP SCANNING
  LD A,(HL)             ;GET THE NEXT CHARACTER
  INC HL
  CP '#'                ;MORE DIGITS AFTER THE DECIMAL POINT?
  JR Z,AFTDOT           ;IF SO, INCREMENT THE COUNT AND KEEP SCANNING
;
; CHECK FOR THE "^^^^" THAT INDICATES SCIENTIFIC NOTATION
;
FINNUM:
  PUSH DE               ;SAVE [D]=FLAGS AND [E]=LEADING DIGITS
  LD DE,NOTSCI          ;PLACE TO GO IF ITS NOT SCIENTIFIC
  PUSH DE               ;NOTATION
  LD D,H                ;REMEMBER [H,L] IN CASE
  LD E,L                ;ITS NOT SCIENTIFIC NOTATION
  CP '^'                ;IS THE FIRST CHARACTER "^" ?
  RET NZ
  CP (HL)               ;IS THE SECOND CHARACTER "^" ?
  RET NZ
  INC HL
  CP (HL)               ;IS THE THIRD CHARACTER "^" ?
  RET NZ
  INC HL
  CP (HL)               ;IS THE FOURTH CHARACTER "^" ?
  RET NZ
  INC HL
  LD A,B                ;WERE THERE ENOUGH CHARACTERS FOR "^^^^"
  SUB $04               ;IT TAKES FOUR
  RET C
  POP DE                ;POP OFF THE NOTSCI RETURN ADDRESS
  POP DE                ;GET BACK [D]=FLAGS [E]=LEADING DIGITS
  LD B,A                ;MAKE [B]=NEW CHARACTER COUNT
  INC D                 ;TURN ON THE SCIENTIFIC NOTATION FLAG
  INC HL

  DEFB $CA              ; JP Z,nn  to mask the next 2 bytes    ;SKIP THE NEXT TWO BYTES WITH "JZ"

NOTSCI:  
  EX DE,HL              ;RESTORE THE OLD [H,L]
  POP DE                ;GET BACK [D]=FLAGS [E]=LEADING DIGITS
  
ENDNUS:
  LD A,D                ;IF THE LEADING PLUS FLAG IS ON
  DEC HL
  INC E                 ;INCLUDE LEADING "+" IN NUMBER OF DIGITS
  AND $08               ;DON'T CHECK FOR A TRAILING SIGN
  JR NZ,ENDNUM          ;ALL DONE WITH THE FIELD IF SO IF THERE IS A LEADING PLUS
  DEC E                 ;NO LEADING PLUS SO DON'T INCREMENT THE NUMBER OF DIGITS BEFORE THE DECIMAL POINT
  LD A,B
  OR A                  ;SEE IF THERE ARE MORE CHARACTERS
  JR Z,ENDNUM           ;IF NOT, STOP SCANNING
  LD A,(HL)             ;GET THE CURRENT CHARACTER
  SUB '-'               ;TRAIL MINUS?
  JR Z,SGNTRL           ;SET THE TRAILING SIGN FLAG
  CP '+'-'-'            ;A TRAILING PLUS?
  JR NZ,ENDNUM          ;IF NOT, WE ARE DONE SCANNING
  LD A,$08              ;TURN ON THE POSITIVE="+" FLAG
SGNTRL:
  ADD A,$04             ;TURN ON THE TRAILING SIGN FLAG
  ADD A,D               ;INCLUDE WITH OLD FLAGS
  LD D,A
  DEC B                 ;DECREMENT THE "USING" STRING CHARACTER COUNT TO ACCOUNT FOR THE TRAILING SIGN
ENDNUM:
  POP HL                ;[H,L]=THE OLD TEXT POINTER
  POP AF                ;POP OFF FLAG THAT SAYS WHETHER THERE ARE MORE VALUES IN THE VALUE LIST
  JR Z,FLDFIN           ;IF NOT, WE ARE DONE WITH THE "PRINT"
  PUSH BC               ;SAVE [B]=# OF CHARACTERS REMAINING IN "USING" STRING AND [C]=TRAILING DIGITS
  PUSH DE               ;SAVE [D]=FLAGS AND [E]=LEADING DIGITS
  CALL EVAL             ;READ A VALUE FROM THE VALUE LIST
  POP DE                ;[D]=FLAGS & [E]=# OF LEADING DIGITS
  POP BC                ;[B]=# CHARACTER LEFT IN "USING" STRING
                        ;[C]=NUMBER OF TRAILING DIGITS
  PUSH BC               ;SAVE [B] FOR ENTERING SCAN AGAIN
  PUSH HL               ;SAVE THE TEXT POINTER
  LD B,E                ;[B]=# OF LEADING DIGITS
  LD A,B                ;MAKE SURE THE TOTAL NUMBER OF DIGITS
  ADD A,C               ;DOES NOT EXCEED TWENTY-FOUR
  CP 25
  JP NC,FC_ERR          ;IF SO, Err $05 - "Illegal function call"

  LD A,D                ;[A]=FLAG BITS
  OR $80                ;TURN ON THE "USING" BIT
  CALL PUFOUT           ;PRINT THE VALUE
  CALL PRS              ;ACTUALLY PRINT IT

FNSTRF:
  POP HL                ;GET BACK THE TEXT POINTER
  DEC HL                ;SEE WHAT THE TERMINATOR WAS
  RST CHRGTB            
  SCF                   ;SET FLAG THAT CRLF IS DESIRED
  JR Z,CRDNUS           ;IF IT WAS A END-OF-STATEMENT, FLAG THAT THE VALUE LIST ENDED AND THAT CRLF SHOULD BE PRINTED
  LD (FLGINP),A         ;FLAG THAT VALUE HAS BEEN PRINTED.
                        ;DOESNT MATTER IF ZERO SET, [A] MUST BE NON-ZERO OTHERWISE
  CP ';'                ;A SEMI-COLON?
  JR Z,SEMUSN           ;A LEGAL DELIMITER
  RST SYNCHR            ;A COMMA ?
  DEFB ','              ;THE DELIMETER WAS ILLEGAL

  DEFB $06    ; "LD B,n" to Mask the next byte

SEMUSN:
  RST CHRGTB            ;IS THERE ANOTHER VALUE?
CRDNUS:                 
  POP BC                ;[B]=CHARACTERS REMAINING IN "USING" STRING
  EX DE,HL              ;[D,E]=TEXT POINTER
  POP HL                ;[H,L]=POINT AT THE "USING" STRING
  PUSH HL               ;DESCRIPTOR. RESAVE IT.
  PUSH AF               ;SAVE THE FLAG THAT INDICATES WHETHER OR NOT THE VALUE LIST TERMINATED
  PUSH DE               ;SAVE THE TEXT POINTER

;
; SINCE FRMEVL MAY HAVE FORCED GARBAGE COLLECTION
; WE HAVE TO USE THE NUMBER OF CHARACTERS ALREADY SCANNED
; AS AN OFFSET TO THE POINTER TO THE "USING" STRING'S DATA
; TO GET A NEW POINTER TO THE REST OF THE CHARACTERS TO BE SCANNED
;
  LD A,(HL)            ;GET THE "USING" STRING'S LENGTH
  SUB B                ;SUBTRACT THE NUMBER OF CHARACTERS ALREADY SCANNED
  INC HL               ;[H,L]=POINTER AT
  LD D,$00             ;THE "USING" STRING'S
  LD E,A               ;STRING DATA
  LD A,(HL)            
  INC HL               
  LD H,(HL)            ;SETUP [D,E] AS A DOUBLE BYTE OFFSET
  LD L,A
  ADD HL,DE            ;ADD ON THE OFFSET TO GET THE NEW POINTER
;CHKUSI:
  LD A,B               ;[A]=THE NUMBER OF CHARACTERS LEFT TO SCAN
  OR A                 ;SEE IF THERE ARE ANY LEFT
  JP NZ,PRCCHR         ;IF SO, KEEP SCANNING
  JR FINUSI            ;SEE IF THERE ARE MORE VALUES

REUSIN:
  CALL PLS_PRNT        ;PRINT A "+" IF NECESSARY
  RST OUTDO            ;PRINT THE FINAL CHARACTER
FINUSI:
  POP HL               ;POP OFF THE TEXT POINTER
  POP AF               ;POP OFF THE INDICATOR OF WHETHER OR NOT THE VALUE LIST HAS ENDED
  JP NZ,REUSST         ;IF NOT, REUSE THE "USING" STRING

FLDFIN:
  CALL C,OUTDO_CRLF    ;IF NOT COMMA OR SEMI-COLON ENDED THE VALUE LIST, PRINT A CRLF
  EX (SP),HL           ;SAVE THE TEXT POINTER <> [H,L]=POINT AT THE "USING" STRING'S DESCRIPTOR
  CALL GSTRHL          ;FINALLY FREE IT UP
  POP HL               ;GET BACK THE TEXT POINTER
  JP FINPRT            ;ZERO [PTRFIL]

;
; HERE TO HANDLE VARIABLE LENGTH STRING FIELD SPECIFIED WITH "&"
;
VARSTR:
  LD C,$00             ;SET LENGTH TO MAXIMUM POSSIBLE
  JR ISSTRF_0

;
; HERE WHEN THE "!" INDICATING A SINGLE CHARACTER STRING FIELD HAS BEEN SCANNED
;
SMSTRF:
  LD C,$01             ;SET THE FIELD WIDTH TO 1
  DEFB $3E             ; "LD A,n" to Mask the next byte      ;SKIP NEXT BYTE WITH A "MVI A,"
  
ISSTRF:
  POP AF               ;GET RID OF THE [H,L] THAT WAS BEING SAVED IN CASE THIS WASN'T A STRING FIELD
ISSTRF_0:
  DEC B                ;DECREMENT THE "USING" STRING CHARACTER COUNT
  CALL PLS_PRNT        ;PRINT A "+" IF ONE CAME BEFORE THE FIELD
  POP HL               ;TAKE OFF THE TEXT POINTER
  POP AF               ;TAKE OFF THE FLAG WHICH SAYS WHETHER THERE ARE MORE VALUES IN THE VALUE LIST
  JR Z,FLDFIN          ;IF THERE ARE NO MORE VALUES THEN WE ARE DONE
  PUSH BC              ;SAVE [B]=NUMBER OF CHARACTERS YET TO BE SCANNED IN "USING" STRING
  CALL EVAL            ;READ A VALUE
  CALL TSTSTR          ;MAKE SURE ITS A STRING
  POP BC               ;[C]=FIELD WIDTH
  PUSH BC              ;RESAVE [B]
  PUSH HL              ;SAVE THE TEXT POINTER
  LD HL,(FACLOW)       ;GET A POINTER TO THE DESCRIPTOR
  LD B,C               ;[B]=FIELD WIDTH
  LD C,$00             ;SET UP FOR "LEFT$"
  LD A,B
  PUSH AF
  OR A
  CALL NZ,__LEFT_S_1   ; into LEFT$, TRUNCATE THE STRING TO [B] CHARACTERS
  CALL PRS1            ;PRINT THE STRING
  LD HL,(FACLOW)       ;SEE IF IT NEEDS TO BE PADDED
  POP AF               ;[A]=FIELD WIDTH
  OR A                 ;
  JP Z,FNSTRF          ;DONT PRINT ANY TRAILING SPACES
  SUB (HL)             ;[A]=AMOUNT OF PADDING NEEDED
  LD B,A
  LD A,' '             ;SETUP THE PRINT CHARACTER
  INC B                ;DUMMY INCREMENT OF NUMBER OF SPACES
UPRTSP:
  DEC B                ;SEE IF MORE SPACES
  JP Z,FNSTRF          ;NO, GO SEE IF THE VALUE LIST ENDED AND RESUME SCANNING
  RST OUTDO            ;PRINT A SPACE
  JR UPRTSP            ;AND LOOP PRINTING THEM

;
; WHEN A "+" IS DETECTED IN THE "USING" STRING IF A NUMERIC FIELD FOLLOWS A BIT IN [D]
; SHOULD BE SET, OTHERWISE "+" SHOULD BE PRINTED.
; SINCE DECIDING WHETHER A NUMERIC FIELD FOLLOWS IS VERY DIFFICULT, THE BIT IS ALWAYS SET IN [D].
; AT THE POINT IT IS DECIDED A CHARACTER IS NOT PART OF A NUMERIC FIELD, THIS ROUTINE IS CALLED
; TO SEE IF THE BIT IN [D] IS SET, WHICH MEANS A PLUS PRECEDED THE CHARACTER AND SHOULD BE PRINTED.
;
; Routine at 25158
PLS_PRNT:
  PUSH AF              ;SAVE THE CURRENT CHARACTER
  LD A,D               ;CHECK THE PLUS BIT
  OR A                 ;SINCE IT IS THE ONLY THING THAT COULD BE TURNED ON
  LD A,'+'             ;SETUP TO PRINT THE PLUS
  CALL NZ,OUTDO        ;PRINT IT IF THE BIT WAS SET
  POP AF               ;GET BACK THE CURRENT CHARACTER
  RET

; Routine at 25168
;
; Used by the routine at SMKVAR.
MOVUP:
  CALL ENFMEM   ; $6267 = ENFMEM (reference not aligned to instruction)
; This entry point is used by the routines at GNXARY, __PLAY_2 and MCLPLAY.
MOVUP_0:
  PUSH BC
  EX (SP),HL
  POP BC
MOVUP_1:
  RST DCOMPR		; Compare HL with DE.
  LD A,(HL)
  LD (BC),A
  RET Z
  DEC BC
  DEC HL
  JR MOVUP_1

; Routine at 25182
;
; Used by the routines at __GOSUB, EVAL_1, DOFN, MCLXEQ, ENTSLR and EXEC_ONGOSUB.
; $625E
CHKSTK:
  PUSH HL
  LD HL,(STREND)
  LD B,$00
  ADD HL,BC
  ADD HL,BC

  DEFB $3E  ; "LD A,n" to Mask the next byte

; See if enough memory
ENFMEM:
  PUSH HL                 ; Save code string address
  LD A,256-(2*NUMLEV)     ; -(2*NUMLEV) Bytes minimum RAM
  ;LD A,-120	; 120 Bytes minimum RAM
  SUB L
  LD L,A
  LD A,-1	; 120 Bytes (MSB) minimum RAM
  SBC A,H
  LD H,A
  JR C,OM_ERR
  ADD HL,SP
  POP HL
  RET C

; This entry point is used by the routines at __CLEAR and MAXFILES.
OM_ERR:
  CALL LINKER
  LD HL,(STKTOP)
  DEC HL
  DEC HL
  LD (SAVSTK),HL
  LD DE,$0007			; Err $07 - "Out of memory"
  JP ERROR


; Data block at 25222
__NEW:
  RET NZ
  ; --- START PROC L6287 ---
CLRPTR:
  LD  HL,(TXTTAB)
  CALL __TRON+1			; TROFF
  LD (AUTFLG),A			; AUTO mode flag
  LD (PTRFLG),A			; =0 if no line number converted to pointers
  LD (HL),A
  INC HL
  LD (HL),A
  INC HL
  LD (VARTAB),HL		; Pointer to start of variable space
  
  ; --- START PROC RUN_FST ---
; a.k.a. RUNC
RUN_FST:
  ; Clear all variables
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HRUNC			; Hook 1 for RUN-Clear
ENDIF
  LD HL,(TXTTAB)		; Starting address of BASIC text area
  DEC HL
  ; --- START PROC _CLVAR ---
;; INTVAR:
_CLVAR:
  ; Initialise RUN variables
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HCLEA			; Hook 2 for RUN-Clear
ENDIF
  LD (TEMP),HL			; Location for temporary reservation for st.code
  
  ; --- START PROC L62A7 ---
; Clear registers
_CLREG:
  CALL CLR_ALLINT
  LD B,1Ah
  LD HL,DEFTBL
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HLOPD			; Hook 3 for RUN-Clear
ENDIF

_CLREG_0:
  LD (HL),$08
  INC HL
  DJNZ _CLREG_0
  
  CALL INIT_RND
  XOR A
  LD (ONEFLG),A			; Clear 'on error' flag
  LD L,A
  LD H,A
  LD (ONELIN),HL
  LD (OLDTXT),HL
  LD HL,(MEMSIZ)
  LD (FRETOP),HL
  CALL __RESTORE
  LD HL,(VARTAB)
  LD (ARYTAB),HL
  LD (STREND),HL
  CALL CLSALL		; Close all files
  LD A,(NLONLY)
  AND $01
  JR NZ,CLREG  		; Clear registers and warm boot
  LD (NLONLY),A
; This entry point is used by the routine at _CSTART.
; Clear registers and warm boot:
CLREG:
  POP BC
  LD HL,(STKTOP)
  DEC HL
  DEC HL
  LD (SAVSTK),HL
  INC HL
  INC HL

; This entry point is used by the routine at READYR.
STKERR:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HSTKE		; Hook for "Reset stack" event
ENDIF
  LD SP,HL
  LD HL,TEMPST
  LD (TEMPPT),HL
  CALL FINLPT
  CALL FINPRT
  XOR A
  LD H,A
  LD L,A
  LD (PRMLEN),HL
  LD (NOFUNS),A			; 0 if no function active
  LD (PRMLN2),HL
  LD (FUNACT),HL
  LD (PRMSTK),HL		; Previous definition block on stack
  LD (SUBFLG),A
  PUSH HL
  PUSH BC
GTMPRT:
  LD HL,(TEMP)
  RET

; Routine at 25371
;
; Used by the routine at L77FE.
TIME_S_ON:
  DI
  LD A,(HL)
  AND $04
  OR $01
  CP (HL)
  LD (HL),A
  JR Z,TIME_S_ON_0
  AND $04
  JR NZ,RESET_ONGSBF
TIME_S_ON_0:
  EI
  RET

; Routine at 25387
;
; Used by the routine at L77FE.
TIME_S_OFF:
  DI
  LD A,(HL)
  LD (HL),$00
  JR STOP_TRAPEVT_FLG

; Routine at 25393
;
; Used by the routines at EXEC_ONGOSUB and L77FE.
TIME_S_STOP:
  DI
  LD A,(HL)
  PUSH AF
  OR $02		; Interrupt STOP
  LD (HL),A
  POP AF
; This entry point is used by the routine at TIME_S_OFF.
STOP_TRAPEVT_FLG:
  XOR $05  	; bit 0 and 2 (Interrupt occurred / Interrupt OFF)
  JR Z,SET_ONGSBF
  EI
  RET

; Routine at 25406
RETURN_TRAP:
  DI
  LD A,(HL)
  AND $05	;  bit 0 and 2 (Interrupt occurred / Interrupt OFF)
  CP (HL)
  LD (HL),A
  JR NZ,RESET_TRAPEVT_FLG
  EI
  RET

; Toggle bit 0 and 2 (Interrupt occurred / Interrupt OFF)
RESET_TRAPEVT_FLG:
  XOR $05	;  bit 0 and 2 (Interrupt occurred / Interrupt OFF)
  JR Z,RESET_ONGSBF
  EI
  RET

; Routine at 25422
L634E:
  DI
; This entry point is used by the routines at TIME_S_ON and RETURN_TRAP.
RESET_ONGSBF:
  LD A,(ONGSBF)
  INC A
  LD (ONGSBF),A
  EI
  RET

; Routine at 25432
;
; Used by the routine at EXEC_ONGOSUB.
TIME_S_EVENT:
  DI
  LD A,(HL)
  AND $03		; are bit 0 or 1 (Interrupt OFF / Interrupt STOP) set ?
  CP (HL)
  LD (HL),A
  JR NZ,SET_ONGSBF
TIME_S_STOP_7:
  EI
  RET
  
; This entry point is used by the routine at TIME_S_STOP.
SET_ONGSBF:
  LD A,(ONGSBF)
  SUB $01
  JR C,TIME_S_STOP_7
  LD (ONGSBF),A
  EI
  RET

; Routine at 25454
;
; Used by the routine at L628E.
; Clear all the interrupt trap tables definitions
CLR_ALLINT:
  LD HL,TRPTBL
  LD B,$1A
  XOR A
CLR_ALLINT_0:
  LD (HL),A
  INC HL
  LD (HL),A
  INC HL
  LD (HL),A
  INC HL
  DJNZ CLR_ALLINT_0
  LD HL,FNKFLG
  LD B,$0A
CLR_ALLINT_1:
  LD (HL),A
  INC HL
  DJNZ CLR_ALLINT_1
  LD (ONGSBF),A
  RET

; Routine at 25481
EXEC_ONGOSUB:
  LD A,(ONEFLG)
  OR A
  RET NZ
  PUSH HL
  LD HL,(CURLIN)		 ; Line number the Basic interpreter is working on, in direct mode it will be filled with #FFFF
  LD A,H
  AND L
  INC A
  JR Z,EXEC_ONGOSUB_2
  LD HL,TRPTBL
  LD B,$1A
EXEC_ONGOSUB_0:
  LD A,(HL)
  CP $05
  JR Z,EXEC_ONGOSUB_3
RUN_FST4:
  INC HL
  INC HL
  INC HL
  DJNZ EXEC_ONGOSUB_0
EXEC_ONGOSUB_2:
  POP HL
  RET

EXEC_ONGOSUB_3:
  PUSH BC
  INC HL
  LD E,(HL)
  INC HL
  LD D,(HL)
  DEC HL
  DEC HL
  LD A,D
  OR E
  POP BC
  JR Z,RUN_FST4
  PUSH DE
  PUSH HL
  CALL TIME_S_EVENT
  CALL TIME_S_STOP
  LD C,$03
  CALL CHKSTK
  POP BC
  POP DE
  POP HL
  EX (SP),HL
  POP HL
  JP DO_GOSUB

; Routine at 25545
;
; Used by the routine at L628E.
__RESTORE:
  EX DE,HL
  LD HL,(TXTTAB)
  JR Z,__RESTORE_0
  EX DE,HL
  CALL ATOH		; Get specified line number
  PUSH HL
  CALL SRCHLN		; Get first line number
  LD H,B
  LD L,C
  POP DE
  JP NC,UL_ERR			; Err $08 - "Undefined line number"
__RESTORE_0:
  DEC HL
; This entry point is used by the routine at LTSTND.
; a.k.a. RESFIN
UPDATA:
  LD (DATPTR),HL
  EX DE,HL
  RET

; Routine at 25571
; $63E3
__STOP:
  JP NZ,L77A5
; This entry point is used by the routine at L043F.
__STOP_0:
  RET NZ                    ;RETURN IF NOT CONTROL-C AND MAKE
  INC A                     ;SURE "STOP" STATEMENTS HAVE A TERMINATOR
  JR __END_00

; Routine at 25578
__END:
  RET NZ                    ;MAKE SURE "END" STATEMENTS HAVE A TERMINATOR
  XOR A
  LD (ONEFLG),A				; Clear 'on error' flag
  PUSH AF                   ;PRESERVE CONDITION CODES OVER CALL TO CLSALL
  CALL Z,CLSALL             ; Close all files
  POP AF                    ;RESTORE CONDITION CODES
; This entry point is used by the routine at __STOP.
__END_00:
  LD (SAVTXT),HL
  LD HL,TEMPST
  LD (TEMPPT),HL
  DEFB $21	 ; "LD HL,nn" to jump over the next word without executing it

; Used by the routines at __RESUME, __LINE, __INPUT and __READ.
INPBRK:
  OR $FF                 ; 11111111b, Flag "Break" wanted
  POP BC                 ; Return not needed and more
; This entry point is used by the routine at PRG_END.
; $6401
ENDCON:
  LD HL,(CURLIN)		 ; Get current line number
  PUSH HL                
  PUSH AF                ; Save STOP / END statusct break?
  LD A,L                 ; Is it direct break?
  AND H
  INC A                  ; Line is -1 if direct break
  JR Z,NOLIN             ; Yes - No line number
  LD (OLDLIN),HL         ; Save line of break
  LD HL,(SAVTXT)         ; Get point of break
  LD (OLDTXT),HL         ; Save point to CONTinue
NOLIN:
  CALL FINLPT          ; Disable printer echo if enabled
  CALL CONSOLE_CRLF
  POP AF
  LD HL,BREAK_MSG		; "Break" message
  JP NZ,_ERROR_REPORT
  JP RESTART

; Routine at 25636
__CONT:
  LD HL,(OLDTXT)        ; Get CONTinue address
  LD A,H                ; Is it zero?
  OR L
  LD DE,$0011			; Err $11 - "Can't CONTINUE"
  JP Z,ERROR
  LD DE,(OLDLIN)        ; Get line of last break
  LD (CURLIN),DE        ; Set up current line number
  RET

; Routine at 25656
__TRON:
  DEFB $3E  ; "LD A,n" to Mask the next byte

__TROFF:
  XOR A
  LD (TRCFLG),A			; 0 MEANS NO TRACE
  RET

; Routine at 25662
__SWAP:
  CALL GETVAR
  PUSH DE
  PUSH HL
  LD HL,SWPTMP
  CALL VMOVE   		; Copy number value from DE to HL
  LD HL,(ARYTAB)
  EX (SP),HL
  RST GETYPR 		; Get the number type (FAC)
  PUSH AF
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
  CALL GETVAR
  POP AF
  LD B,A
  RST GETYPR 		; Get the number type (FAC)
  CP B
  JP NZ,TM_ERR	; If types are different, Err $0D - "Type mismatch"
  EX (SP),HL
  EX DE,HL
  PUSH HL
  LD HL,(ARYTAB)
  RST DCOMPR		; Compare HL with DE.
  JR NZ,_FC_ERR_A
  POP DE
  POP HL
  EX (SP),HL
  PUSH DE
  CALL VMOVE   		; Copy number value from DE to HL
  POP HL
  LD DE,SWPTMP
  CALL VMOVE   		; Copy number value from DE to HL
  POP HL
  RET
_FC_ERR_A:
  JP FC_ERR			; Err $05 - "Illegal function call"

; Data block at 25719
__ERASE:
L6477:
  LD A,$01
  LD (SUBFLG),A
  CALL GETVAR
  PUSH HL
  LD (SUBFLG),A
  LD H,B
  LD L,C
  DEC BC
  DEC BC
  DEC BC
  DEC BC
  DEC BC
  ADD HL,DE
  EX DE,HL
  LD HL,(STREND)

L648F:
  RST DCOMPR		; Compare HL with DE.

L6490:
  LD  A,(DE)
  LD  (BC),A
  INC DE
  INC BC
  JR  NZ,L648F
  DEC BC
  LD  H,B
  LD  L,C
  LD  (STREND),HL
  POP HL
  LD  A,(HL)
  CP  ','
  RET NZ
  RST CHRGTB		; Gets next character (or token) from BASIC text.
L64A2:
  JR  __ERASE

; Routine at 25764
L64A4:
  POP AF
  POP HL
  RET

; Routine at 25767

; a.k.a. CHKLTR
; Used by the routines at DEFCON and GETVAR.
; Load A with char in (HL) and check it is a letter:
IS_LETTER:
  LD A,(HL)         ; Get byte

; This entry point is used by the routines at TOKENIZE, OPRND, L5683, SCNVAR and GETVAR.
; Check char in 'A' being in the 'A'..'Z' range
ISLETTER_A:
  CP 'A'             ; < "A" ?
  RET C              ; Carry set if not letter
  CP 'Z'+1           ; > "Z" ?
  CCF                
  RET                ; Carry set if not letter

; Routine at 25775
__CLEAR:
  JP Z,_CLVAR       ; Just "CLEAR" Keep parameters
  CALL INTIDX_0     ; Get integer
  DEC HL            ; Cancel increment
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  PUSH HL           ; Save code string address
  LD HL,(HIMEM)
  LD B,H
  LD C,L
  LD HL,(MEMSIZ)    ; Get end of RAM
  JR Z,STORED       ; No value given - Use stored
  POP HL
  RST SYNCHR 		; Check for comma
  DEFB ','
  PUSH DE           ; Save number
  CALL GETWORD      ; Get integer 0 to 32767 to DE
  DEC HL            ; Cancel increment
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JP NZ,SN_ERR
  EX (SP),HL        ; Save code string address
  EX DE,HL          ; Number to DE
  LD A,H            ; Get MSB of new RAM top
  AND A             ; too low ?
  JP P,FC_ERR		; Err $05 - "Illegal function call"
  PUSH DE
  LD DE,MAXRAM+1	; Limit of CLEAR position
  RST DCOMPR		; Compare HL with DE.
  JP NC,FC_ERR		; Err $05 - "Illegal function call"
  POP DE
  PUSH HL           ; Save code string address (again)
  LD BC,$FEF5		; -267 (same offset on Tandy model 100)
  LD A,(MAXFIL)
__CLEAR_0:
  ADD HL,BC
  DEC A
  JP P,__CLEAR_0
  POP BC            ; Restore code string address (1st copy)
  DEC HL
STORED:
  ;; CALL SUBDE     ; The Philips VG-5000 uses this call
  LD A,L            ; Get LSB of new RAM top
  SUB E             ; Subtract LSB of string space
  LD E,A            ; Save LSB
  LD A,H            ; Get MSB of new RAM top
  SBC A,D           ; Subtract MSB of string space
  LD D,A            ; Save MSB
  JP C,OM_ERR       ; ?OM Error if not enough mem
  PUSH HL           ; Save RAM top
  LD HL,(VARTAB)    ; Get program end
  PUSH BC
  LD BC,$00A0		; 160 Bytes minimum working RAM (same offset on Tandy model 100)
  ADD HL,BC         ; Get lowest address
  POP BC
  RST DCOMPR		; Enough memory?
  JP NC,OM_ERR     ; No - ?OM Error
  EX DE,HL          ; RAM top to HL
  LD (STKTOP),HL    ; Set new top of RAM
  LD H,B
  LD L,C
  LD (HIMEM),HL
  POP HL
  LD (MEMSIZ),HL    ; Set new string space
  POP HL
  CALL _CLVAR       ; Initialise variables
  LD A,(MAXFIL)
  CALL MAXFILES
  LD HL,(TEMP)
  JP NEWSTT

; Routine at 25888
; SUBDE was probably replaced by inline code and never removed on MSX and SVI
;
; SUBTRACT [H,L]-[D,E] INTO [D,E]
;
SUBDE:
  LD A,L                  ; Get LSB of new RAM top
  SUB E                   ; Subtract LSB of string space
  LD E,A                  ; Save LSB
  LD A,H                  ; Get MSB of new RAM top
  SBC A,D                 ; Subtract MSB of string space
  LD D,A                  ; Save MSB
  RET

; Routine at 25895
__NEXT:
  LD DE,$0000               ; In case no index given
__NEXT_0:
  CALL NZ,GETVAR			; not end of statement, locate variable (Get index address)
  LD (TEMP),HL				; save BASIC pointer
  CALL BAKSTK				; search FOR block on stack (skip 2 words)
  JP NZ,NF_ERR				; Err $01 - "NEXT without FOR"
  LD SP,HL					; Clear nested loops
  PUSH DE					; Save index address
  LD A,(HL)					; Get sign of STEP
  PUSH AF                   ; Save sign of STEP
  INC HL
  PUSH DE                   ; Save index address
  LD A,(HL)
  INC HL
  OR A
  JP M,__NEXT_2
  DEC A
  JR NZ,__NEXT_1
  LD BC,$0008
  ADD HL,BC
__NEXT_1:
  ADD A,$04
  LD (VALTYP),A
  CALL VMOVFM				; Move index value to FPREG
  EX DE,HL
  EX (SP),HL				; Save address of TO value
  PUSH HL
  RST GETYPR 				; Get the number type (FAC)
  JR NC,__NEXT_4	
  CALL HLBCDE			; Load single precision FP value from (HL) in reverse byte order
  CALL FADD
  POP HL
  CALL FPTHL
  POP HL
  CALL LOADFP
  PUSH HL
  CALL FCOMP
  JR __NEXT_3

__NEXT_2:
  LD BC,RDSLT
  ADD HL,BC
  LD C,(HL)
  INC HL
  LD B,(HL)
  INC HL
  EX (SP),HL
  LD E,(HL)
  INC HL
  LD D,(HL)
  PUSH HL
  LD L,C
  LD H,B
  CALL IADD            ; ADD THE STEP TO THE LOOP VARIABLE
  LD A,(VALTYP)        ; SEE IF THERE WAS OVERFLOW
  CP $02               ; TURNED TO SINGLE-PRECISION?
  JP NZ,OV_ERR         ; INDICE GOT TOO LARGE  ( Err $06 -  "Overflow" )
  EX DE,HL             ; [D,E]=NEW LOOP VARIABLE VALUE
  POP HL               ; GET THE POINTER AT THE LOOP VARIABLE
  LD (HL),D            ; STORE THE NEW VALUE
  DEC HL
  LD (HL),E
  POP HL               ; GET BACK THE POINTER INTO THE "FOR" ENTRY
  PUSH DE              ; SAVE THE VALUE OF THE LOOP VARIABLE
  LD E,(HL)            ; [D,E]=FINAL VALUE
  INC HL
  LD D,(HL)
  INC HL
  EX (SP),HL           ; SAVE THE ENTRY POINTER AGAIN, GET THE VALUE OF THE LOOP VARIABLE INTO [H,L]
  CALL ICOMP           ; DO THE COMPARE
__NEXT_3:
  POP HL               ; POP OFF THE "FOR" ENTRY POINTER WHICH IS NOW POINTING PAST THE FINAL VALUE
  POP BC               ; GET THE SIGN OF THE INCREMENT
  SUB B                ; SUBTRACT THE INCREMENTS SIGN FROM THAT OF (CURRENT VALUE-FINAL VALUE)
  CALL LOADFP          ; GET LINE # OF "FOR" INTO [D,E]
  JR Z,KILFOR          ; IF SIGN(FINAL-CURRENT)+SIGN(STEP)=0, then loop finished - Terminate it
  EX DE,HL             ; Loop statement line number
  LD (CURLIN),HL       ; Set loop line number
  LD L,C               ; Set code string to loop
  LD H,B
  JP PUTFID

__NEXT_4:
  CALL NEXT_DADD
  POP HL
  CALL VMOVMF
  POP HL
  CALL HL_ARG
  PUSH DE
  CALL XDCOMP
  JR __NEXT_3
  
; Remove "FOR" block
KILFOR:
  LD SP,HL           ; SINCE [H,L] MOVED ALL THE WAY DOWN THE ENTRY
  LD (SAVSTK),HL     ; Code string after "NEXT"
  EX DE,HL           ; RESTORE THE TEXT POINTER
  LD HL,(TEMP)       
  LD A,(HL)          ; Get next byte in code string
  CP ','             ; More NEXTs ?
  JP NZ,NEWSTT       ; No - Do next statement
  RST CHRGTB         ; Position to index name
  CALL __NEXT_0      ; Re-enter NEXT routine
; < will not RETurn to here , Exit to NEWSTT (RUNCNT) or Loop >


;
; THE FOLLOWING ROUTINE COMPARES TWO STRINGS
; ONE WITH DESC IN [D,E] OTHER WITH DESC. IN [FACLO, FACLO+1]
; A=0 IF STRINGS EQUAL
; A=377 IF B,C,D,E .GT. FACLO
; A=1 IF B,C,D,E .LT. FACLO
;
STRCMP:
  CALL GETSTR              ; Get current string              ;FREE UP THE FAC STRING, AND GET THE POINTER TO THE FAC DESCRIPTOR IN [H,L]
  LD A,(HL)                ; Get length of string            ;SAVE THE LENGTH OF THE FAC STRING IN [A]
  INC HL
  LD C,(HL)                ; Get LSB of address              ;SAVE THE POINTER AT THE FAC STRING DATA IN [B,C]
  INC HL
  LD B,(HL)
  POP DE                   ; Restore string name             ;GET THE STACK STRING POINTER
  PUSH BC                  ; Save address of string          ;SAVE THE POINTER AT THE FAC STRING DATA
  PUSH AF                  ; Save length of string           ;SAVE THE FAC STRING LENGTH
  CALL GSTRDE              ; Get second string               ;FREE UP THE STACK STRING AND RETURN
                                                             ;THE POINTER TO THE STACK STRING DESCRIPTOR IN [H,L]
  POP AF                   ; Restore length of string 1
  LD D,A                   ; Length to D                     ;[D]=LENGTH OF FAC STRING
  LD E,(HL)                                                  ;[E]=LENGTH OF STACK STRING
  INC HL
  LD C,(HL)                                                  ;[B,C]=POINTER AT STACK STRING
  INC HL
  LD B,(HL)
  POP HL                   ; Restore address of string 1     ;GET BACK 2ND CHARACTER POINTER

; a.k.a. CMPSTR
CSLOOP:
  LD A,E                   ; Bytes of string 2 to do         ;BOTH STRINGS ENDED
  OR D                     ; Bytes of string 1 to do         ;TEST BY OR'ING THE LENGTHS TOGETHER
  RET Z                    ; Exit if all bytes compared      ;IF SO, RETURN WITH A ZERO
  LD A,D                   ; Get bytes of string 1 to do     ;GET FACLO STRING LENGTH
  SUB 1                                                      ;SET CARRY AND MAKE [A]=255 IF [D]=0
  RET C                    ; Exit if end of string 1         ;RETURN IF THAT STRING ENDED
  XOR A                                                      ;MUST NOT HAVE BEEN ZERO, TEST CASE
  CP E                     ; Bytes of string 2 to do         ;OF B,C,D,E STRING HAVING ENDED FIRST
  INC A                                                      ;RETURN WITH A=1
  RET NC                   ; Exit if end of string 2         ;TEST THE CONDITION

; a.k.a. CMPRES
;HERE WHEN NEITHER STRING ENDED
  DEC D                    ; Count bytes in string 1         ;DECREMENT BOTH CHARACTER COUNTS
  DEC E                    ; Count bytes in string 2
  LD A,(BC)                ; Byte in string 2                ;GET CHARACTER FROM B,C,D,E STRING
  INC BC                   ; Move up string 2
  CP (HL)                  ; Compare to byte in string 1     ;COMPARE WITH FACLO STRING
  INC HL                   ; Move up string 1                ;BUMP POINTERS (INX DOESNT CLOBBER CC'S)
  JR Z,CSLOOP              ; Same - Try next bytes           ;IF BOTH THE SAME, MUST BE MORE TO STRINGS
  CCF                      ; Flag difference (">" or "<")    ;HERE WHEN STRINGS DIFFER
  JP SIGNS                 ; "<" gives -1 , ">" gives +1     ;SET [A] ACCORDING TO CARRY


; 'OCT$' BASIC function
;
; THE STRO$ FUNCTION TAKES A NUMBER AND GIVES
; A STRING WITH THE CHARACTERS THE NUMBER WOULD GIVE IF OUTPUT IN OCTAL
;
; Routine at 26101
__OCT_S:
  CALL FOUTO             ;PUT OCTAL NUMBER IN FBUFFR
  JR __STR_S_0             ;JUMP INTO STR$ CODE

; 'HEX$' BASIC function
; STRH$ SAME AS STRO$ EXCEPT USES HEX INSTEAD OF OCTAL
; Routine at 26106
__HEX_S:
  CALL FOUTH             ;PUT HEX NUMBER IN FBUFFR
  JR __STR_S_0             ;JUMP INTO STR$ CODE

; Routine at 26111
__BIN_S:
  CALL BIN_STR
  JR __STR_S_0

; Routine at 26116
__STR_S:                                                ;IS A NUMERIC
  CALL FOUT           ; Turn number into text           ;DO ITS OUTPUT

; This entry point is used by the routines at __OCT_S, __HEX_S and __BIN_S.
__STR_S_0:
  CALL CRTST          ; Create string entry            ;SCAN IT AND TURN IT INTO A STRING
  CALL GSTRCU         ; Current string to pool         ;FREE UP THE TEMP

; Save string in string area
SAVSTR:
  LD BC,TOPOOL        ; Save in string pool
  PUSH BC             ; Save address on stack        ;SET UP ANSWER IN NEW TEMP

;
; STRCPY CREATES A COPY OF THE STRING WHOSE DESCRIPTOR IS POINTED TO BY [H,L].
; ON RETURN [D,E] POINTS TO DSCTMP WHICH HAS THE STRING INFO (LENGTH, WHERE COPIED TO)
;
; This entry point is used by the routines at __LET and LHSMID.
; $6611
STRCPY:
  LD A,(HL)           ; Get string length                      ;GET LENGTH
  INC HL                                                       ;MOVE UP TO THE POINTER
  PUSH HL             ; Save pointer to string                 ;GET POINTER TO POINTER OF ARG
  CALL TESTR          ; See if enough string space             ;GET THE SPACE
  POP HL              ; Restore pointer to string              ;FIND OUT WHERE STRING TO COPY
  LD C,(HL)           ; Get LSB of address
  INC HL
  LD B,(HL)           ; Get MSB of address
  CALL CRTMST         ; Create string entry                    ;SETUP DSCTMP
  PUSH HL             ; Save pointer to MSB of addr            ;SAVE POINTER TO DSCTMP
  LD L,A              ; Length of string                       ;GET CHARACTER COUNT INTO [L]
  CALL TOSTRA         ; Move to string area                    ;MOVE THE CHARS IN
  POP DE              ; Restore pointer to MSB                 ;RESTORE POINTER TO DSCTMP
  RET                                                          ;RETURN

; Routine at 26149
;
; Used by the routines at __CHR_S and FN_INKEY.
STRIN1:
  LD A,$01            ;MAKE ONE CHAR STRING (CHR$, INKEY$)

; This entry point is used by the routines at CONCAT, FN_STRING, FN_INPUT and FN_SPRITE.
; Make temporary string
;GET SOME STRING SPACE ([A] CHARS)
MKTMST:
  CALL TESTR			; See if enough string space

; This entry point is used by the routines at SAVSTR, DTSTR and __LEFT_S.
; Create string entry
CRTMST:
  LD HL,DSCTMP           ; Temporary string                ;GET DESC. TEMP
  PUSH HL                ; Save it                         ;SAVE DESC. POINTER
  LD (HL),A              ; Save length of string           ;SAVE CHARACTER COUNT
;PUTDEI:
  INC HL                                                   ;STORE [D,E]=POINTER TO FREE SPACE
  LD (HL),E              ; Save LSB of address
  INC HL          
  LD (HL),D              ; Save MSB of address
  POP HL                 ; Restore pointer                 ;AND RESTORE [H,L] AS THE DESCRIPTOR POINTER
  RET

; Routine at 26165
;
; Used by the routines at __STR_S and PRS.
CRTST:
  DEC HL                 ; DEC - INCed after


;
; STRLT2 TAKES THE STRING LITERAL WHOSE FIRST CHARACTER IS POINTED BY [H,L]+1 AND BUILDS A DESCRIPTOR FOR IT.
; THE DESCRIPTOR IS INITIALLY BUILT IN DSCTMP, BUT PUTNEW TRANSFERS IT INTO A TEMPORARY AND LEAVES A POINTER
; AT THE TEMPORARY IN FACLO. THE CHARACTERS OTHER THAN ZERO THAT TERMINATE THE STRING SHOULD BE SET UP IN [B]
; AND [D]. IT THE TERMINATOR IS A QUOTE, THE QUOTE IS SKIPPED OVER.
; LEADING QUOTES SHOULD BE SKIPPED BEFORE CALL. ON RETURN THE CHARACTER AFTER THE STRING LITERAL IS POINTED TO
; BY [H,L] AND IS IN [A], BUT THE CONDITION CODES ARE NOT SET UP.
;
; Create quote terminated String
;
; Used by the routines at __INPUT and OPRND.
QTSTR:
  LD B,'"'			; Terminating quote          ;ASSUME STR ENDS ON QUOTE
; This entry point is used by the routines at __LINE and L6E35.
QTSTR_0:
  LD D,B			; Quote to D

; Create String, termination char in D
;
; Used by the routine at __READ.
DTSTR:
  PUSH HL           ; Save start                      	;SAVE POINTER TO START OF LITERAL
  LD C,-1           ; Set counter to -1                 ;INITIALIZE CHARACTER COUNT
STRGET:
  INC HL            ; Move on
  LD A,(HL)         ; Get byte                          ;GET CHAR
  INC C             ; Count bytes                       ;BUMP CHARACTER COUNT
  OR A              ; End of line?                      ;IF 0, (END OF LINE) DONE
  JR Z,STRFIN       ; Yes - Create string entry         ;TEST
  CP D              ; Terminator D found?
  JR Z,STRFIN       ; Yes - Create string entry
  CP B              ; Terminator B found?               ;CLOSING QUOTE
  JR NZ,STRGET      ; No - Keep looking                 ;NO, GO BACK FOR MORE
STRFIN:
  CP '"'            ; End with '"'?                     ;IF QUOTE TERMINATES THE STRING
  CALL Z,__CHRGTB   ; Yes - Get next character          ;SKIP OVER THE QUOTE
;------
;  PUSH HL                 ;SAVE POINTER AT END OF STRING
;  LD A,B                  ;WERE WE SCANNING AN UNQUOTED STRING?
;  CP ','
;  JP NZ,NTTRLS            ;IF NOT, DON'T SUPPRESS TRAILING SPACES
;  INC C                   ;FIX [C] WHICH IS THE CHARACTER COUNT
;LPTRLS:
;  DEC C                   ;DECREMENT UNTIL WE FIND A NON-SPACE CHARACTER
;  JP Z,NTTRLS             ;DON'T GO PAST START (ALL SPACES)
;  DEC HL                  ;LOOK AT PREVIOUS CHARACTER
;  LD A,(HL)
;  CP ' '
;  JP Z,LPTRLS             ;IF SO CONTINUE LOOKING
;NTTRLS:
;  POP HL
;-------
  EX (SP),HL        ; Starting quote
  INC HL            ; First byte of string
  EX DE,HL          ; To DE                             ;GET POINTER TO TEMP
  LD A,C            ; Get length                        ;GET CHARACTER COUNT IN A
  CALL CRTMST		; Create string entry               ;SAVE STR INFO

;
; SOME STRING FUNCTION IS RETURNING A RESULT IN DSCTMP
; WE WANT TO SETUP A TEMP DESCRIPTOR WITH DCSTMP IN IT
; PUT A POINTER TO THE DESCRIPTOR IN FACLO AND FLAG THE 
; RESULT AS TYPE STRING
;

; Temporary string to pool
; a.k.a. PUTNEW
;
; Used by the routines at CONCAT, TOPOOL, __LEFT_S, FN_INPUT and FN_SPRITE.
TSTOPL:
  LD DE,DSCTMP      ; Temporary string                     ;[D,E] POINT AT RESULT DESCRIPTOR
  DEFB $3E          ; "LD A,n" to Mask the next byte       ;SKIP THE NEXT BYTE ("MVI AL,")

PUTTMP:
  PUSH DE                                                  ;SAVE A POINTER TO THE START OF THE STRING
  LD HL,(TEMPPT)	; Temporary string pool pointer        ;[H,L]=POINTER TO FIRST FREE TEMP
  LD (FACLOW),HL	; Save address of string ptr           ;POINTER AT WHERE RESULT DESCRIPTOR WILL BE
  LD A,$03          
  LD (VALTYP),A     ; Set type to string                   ;FLAG THIS AS A STRING
  CALL VMOVE   		; Move string to pool                  ;AND MOVE THE VALUE INTO A TEMPORARY
  LD DE,DSCTMP+3                                           ;IF THE CALL IS TO PUTTMP, [D,E] WILL NOT EQUAL DSCTMP +3
  RST DCOMPR		; Out of string pool?                  ;DSCTMP IS JUST BEYOND THE TEMPS
                                                           ;AND IF TEMPPT POINTS AT IT THERE ARE NO FREE TEMPS
  LD (TEMPPT),HL	; Save new pointer                     ;SAVE NEW TEMPORARY POINTER
  POP HL			; Restore code string address          ;GET THE TEXT POINTER
  LD A,(HL)			; Get next code byte                   ;GET CURRENT CHARACTER INTO [A]
  RET NZ			; Return if pool OK
  LD DE,$0010		; Err $10 - "String formula too complex"  ; "STRING TEMPORARY" ERROR
  JP ERROR                                                 ;GO TELL HIM

;
; PRINT THE STRING POINTED TO BY [H,L] WHICH ENDS WITH A ZERO
; IF THE STRING IS BELOW DSCTMP IT WILL BE COPIED INTO STRING SPACE
;
; Routine at 26231
PRNUMS:
  INC HL            ;POINT AT NEXT CHARACTER

; Create string entry and print it
;
; a.k.a. STROUT
; Used by the routines at IN_PRT, L4B4A, LTSTND, __DELETE, LINE2PTR, L61C4, __CLOAD,
; L710B, _CSTART and L7D29.
PRS:
  CALL CRTST        ;GET A STRING LITERAL

; Print string at HL
;
; Used by the routines at L4A5A, __INPUT and L61C4.
PRS1:
  CALL GSTRCU       ;RETURN TEMP POINTER BY FACLO
  CALL LOADFP_0     ;[D]=LENGTH [B,C]=POINTER AT DATA
  INC D             ;INCREMENT AND DECREMENT EARLY TO CHECK FOR NULL STRING
PRS1_0:
  DEC D             ;DECREMENT THE LENGTH
  RET Z             ;ALL DONE
  LD A,(BC)         ;GET CHARACTER TO PRINT
  RST OUTDO
  CP CR
  CALL Z,CRFIN
  INC BC            ;POINT TO THE NEXT CHARACTER
  JR PRS1_0         ;AND PRINT IT...


; Test if enough room for string
;
; a.k.a. GETSPA - GET SPACE FOR CHARACTER STRING
; MAY FORCE GARBAGE COLLECTION.
;
; # OF CHARS (BYTES) IN [A]
; RETURNS WITH POINTER IN [D,E] OTHERWISE IF CANT GET SPACE
; BLOWS OFF TO "OUT OF STRING SPACE" TYPE ERROR.
;
; Routine at 26254
; Used by the routines at SAVSTR, STRIN1 and __LEFT_S.
TESTR:
  OR A              ; MUST BE NON ZERO. SIGNAL NO GARBAG YET
  DEFB $0E          ; "LD C,n" to Mask the next byte

; GRBDON: Garbage Collection Done
GRBDON:
  POP AF                                                ;IN CASE COLLECTED WHAT WAS LENGTH?
  PUSH AF           ; Save status                       ;SAVE IT BACK
  LD HL,(STKTOP)    ; Bottom of string space in use
  EX DE,HL          ; To DE                             ;IN [D,E]
  LD HL,(FRETOP)    ; Bottom of string area             ;GET TOP OF FREE SPACE IN [H,L]
  CPL               ; Negate length (Top down)          ;-# OF CHARS
  LD C,A            ; -Length to BC                     ;IN [B,C]
  LD B,$FF          ; BC = -ve length of string
  ADD HL,BC         ; Add to bottom of space in use     ;SUBTRACT FROM TOP OF FREE
  INC HL            ; Plus one for 2's complement
  RST DCOMPR        ; Below string RAM area?            ;COMPARE THE TWO
  JR C,TESTOS       ; Tidy up if not done else err      ;NOT ENOUGH ROOM FOR STRING, OFFAL TIME
  LD (FRETOP),HL    ; Save new bottom of area           ;SAVE NEW BOTTOM OF MEMORY
  INC HL            ; Point to first byte of string     ;MOVE BACK TO POINT TO STRING
  EX DE,HL          ; Address to DE                     ;RETURN WITH POINTER IN [D,E]

; This entry point is used by the routine at DETOKEN.
POPAF:
  POP AF            ; Throw away status push            ;GET CHARACTER COUNT
  RET                                                   ;RETURN FROM GETSPA
  
; Garbage Collection: Tidy up if not done else err
; a.k.a. GARBAG
; Used by the routine at GRBDON.
TESTOS:
  POP AF            ; Garbage collect been done?           ;HAVE WE COLLECTED BEFORE?
  LD DE,$000E       ; Err $0E - "Out of string space"      ;GET READY FOR OUT OF STRING SPACE ERROR
  JP Z,ERROR        ; Yes - Not enough string apace        ;GO TELL USER HE LOST
  CP A              ; Flag garbage collect done            ;SET ZERO FLAG TO SAY WEVE GARBAGED
  PUSH AF           ; Save status                          ;SAVE FLAG BACK ON STACK
  LD BC,GRBDON      ; Garbage collection done              ;PLACE FOR GARBAG TO RETURN TO.
  PUSH BC           ; Save for RETurn                      ;SAVE ON STACK

; This entry point is used by the routine at __FRE.
GARBGE:
  LD HL,(MEMSIZ)    ; Get end of RAM pointer               ;START FROM TOP DOWN
; This entry point is used by the routine at GNXARY.
GARBLP:
  LD (FRETOP),HL    ; Reset string pointer                 ;LIKE SO
  LD HL,$0000                                              ;GET DOUBLE ZERO
  PUSH HL           ; Flag no string found                 ;SAY DIDNT SEE VARS THIS PASS
  LD HL,(STREND)    ; Get bottom of string space           ;FORCE DVARS TO IGNORE STRINGS IN THE PROGRAM TEXT (LITERALS, DATA)
  PUSH HL           ; Save bottom of string space          ;FORCE FIND HIGH ADDRESS
  LD HL,TEMPST      ; Temporary string pool                ;GET START OF STRING TEMPS

TVAR:
  LD DE,(TEMPPT)
  RST DCOMPR		; Compare HL with DE.

  ;CANNOT RUN IN RAM SINCE IT STORES TO MESS UP BASIC
  LD BC,TVAR        ;FORCE JUMP TO TVAR                       ; Loop until string pool done
  JP NZ,STPOOL      ;DO TEMP VAR GARBAGE COLLECT              ; No - See if in string area
  LD HL,PRMPRV      ;SETUP ITERATION FOR PARAMETER BLOCKS     ; Start of simple variables
  LD (TEMP9),HL     
  LD HL,(ARYTAB)    ;GET STOPPING POINT IN [H,L]
  LD (ARYTA2),HL    ;STORE IN STOP LOCATION
  LD HL,(VARTAB)    ;GET STARTING POINT IN [H,L]
SMPVAR:
  LD DE,(ARYTA2)    ;GET STOPPING LOCATION                    ; End of simple variables
  RST DCOMPR        ;SEE IF AT END OF SIMPS                   ; All simple strings done?
  JR Z,ARYVAR                                                 ; Yes - Do string arrays
  LD A,(HL)         ;GET VALTYP                               ; Get type of variable
  INC HL            ;BUMP POINTER TWICE
  INC HL            ;
  INC HL            ;POINT AT THE VALUE
  CP $03            ;SEE IF ITS A STRING
  JR NZ,SKPVAR      ;IF NOT, JUST SKIP AROUND IT
  CALL STRADD       ;COLLECT IT                               ; Add if string in string area
  XOR A             ;AND DON'T SKIP ANYTHING MORE
SKPVAR:
  LD E,A
  LD D,$00          ;[D,E]=AMOUNT TO SKIP
  ADD HL,DE
  JR SMPVAR         ;GET NEXT ONE                             ; Loop until simple ones done

ARYVAR:
  LD HL,(TEMP9)     ;GET LINK IN PARAMETER BLOCK CHAIN
  LD E,(HL)         ;GO BACK ONE LEVEL
  INC HL
  LD D,(HL)
  LD A,D
  OR E              ;WAS THAT THE END?
  LD HL,(ARYTAB)
  JR Z,ARRLP        ;OTHERWISE GARBAGE COLLECT ARRAYS
  EX DE,HL
  LD (TEMP9),HL     ;SETUP NEXT LINK IN CHAIN FOR ITERATION
  INC HL            ;SKIP CHAIN POINTER
  INC HL
  LD E,(HL)         ;PICK UP THE LENGTH
  INC HL
  LD D,(HL)
  INC HL
  EX DE,HL          ;SET [D,E]= ACTUAL END ADDRESS BY
  ADD HL,DE         ;ADDING BASE TO LENGTH
  LD (ARYTA2),HL    ;SET UP STOP LOCATION
  EX DE,HL
  JR SMPVAR

; Move to next array
;
; Used by the routine at ARRLP.
; Routine at 26393
GNXARY:
  POP BC            ; Scrap address of this array         ;GET RID OF STACK GARBAGE

; Used by the routines at TVAR and GRBARY.
ARRLP:
  LD DE,(STREND)    ; End of string arrays                ;GET END OF ARRAYS
  RST DCOMPR        ; All string arrays done?             ;SEE IF DONE WITH ARRAYS
  JP Z,SCNEND       ; Yes - Move string if found          ;YES, SEE IF DONE COLLECTING
  LD A,(HL)         ; Get type of array                   ;GET THE VALUE TYPE INTO [A]
  INC HL
  CALL LOADFP       ; Get next                            ;SKIP THE EXTRA CHARACTERS
  PUSH HL           ; Save address of num of dim'ns       ;SAVE POINTER TO DIMS
  ADD HL,BC         ; Start of next array                 ;ADD TO CURRENT POINTER PO
  CP $03            ; Test type of array                  ;SEE IF ITS A STRING
  JR NZ,GNXARY      ; Numeric array - Ignore it           ;IF NOT JUST SKIP IT
  LD (TEMP8),HL     ; Save address of next array          ;SAVE END OF ARRAY
  POP HL            ; Get address of num of dim'ns        ;GET BACK CURRENT POSITION
  LD C,(HL)         ; BC = Number of dimensions           ;PICK UP NUMBER OF DIMS
  LD B,$00                                                ;MAKE DOUBLE WITH HIGH ZERO
  ADD HL,BC         ; Two bytes per dimension size        ;GO PAST DIMS
  ADD HL,BC                                               ;BY ADDING ON TWICE #DIMS (2 BYTE GUYS)
  INC HL            ; Plus one for number of dim'ns       ;ONE MORE TO ACCOUNT FOR #DIMS.

ARYSTR:
  EX DE,HL          ;SAVE CURRENT POSIT IN [D,E]          ; Get address of next array
  LD HL,(TEMP8)     ;GET END OF ARRAY
  EX DE,HL          ;FIX [H,L] BACK TO CURRENT            ; Is this array finished?
  RST DCOMPR        ;SEE IF AT END OF ARRAY               ; Yes - Get next one
  JR Z,ARRLP        ;END OF ARRAY, TRY NEXT ARRAY         ; Loop until array all done
  LD BC,ARYSTR      ;ADDR OF WHERE TO RETURN TO

; This entry point is used by the routine at TESTR.
STPOOL:
  PUSH BC           ;GOES ON STACK                        ; Save return address

; This entry point is used by the routine at TESTR.
STRADD:
  XOR A
  OR (HL)           ; Get string length                  ;SEE IF ITS THE NULL STRING
  INC HL
  LD E,(HL)         ; Get LSB of string address
  INC HL
  LD D,(HL)         ; Get MSB of string address
  INC HL                                                 ;[D,E]=POINTER AT THE VALUE
  RET Z                                                  ;NULL STRING, RETURN
  LD B,H                                                 ;MOVE [H,L] TO [B,C]
  LD C,L
  LD HL,(FRETOP)    ; Bottom of new area                 ;GET POINTER TO TOP OF STRING FREE SPACE
  RST DCOMPR        ; String been done?                  ;IS THIS STRINGS POINTER .LT. FRETOP
  LD H,B            ; Restore variable pointer           ;MOVE [B,C] BACK TO [H,L]
  LD L,C
  RET C             ; String done - Ignore               ;IF NOT, NO NEED TO MESS WITH IT FURTHUR
  POP HL            ; Return address                     ;GET RETURN ADDRESS OFF STACK
  EX (SP),HL        ; Lowest available string area       ;GET MAX SEEN SO FAR & SAVE RETURN ADDRESS
  RST DCOMPR        ; String within string area?         ;LETS SEE
  EX (SP),HL        ; Lowest available string area       ;SAVE MAX SEEN & GET RETURN ADDRESS OFF STACK
  PUSH HL           ; Re-save return address             ;SAVE RETURN ADDRESS BACK
  LD H,B            ; Restore variable pointer           ;MOVE [B,C] BACK TO [H,L]
  LD L,C
  RET NC            ; Outside string area - Ignore       ;IF NOT, LETS LOOK AT NEXT VAR
  POP BC            ; Get return , Throw 2 away          ;GET RETURN ADDR OFF STACK
  POP AF                                                 ;POP OFF MAX SEEN
  POP AF                                                 ;AND VARIABLE POINTER
  PUSH HL           ; Save variable pointer              ;SAVE NEW VARIABLE POINTER
  PUSH DE           ; Save address of current            ;AND NEW MAX POINTER
  PUSH BC           ; Put back return address            ;SAVE RETURN ADDRESS BACK
  RET               ; Go to it                           ;AND RETURN
  
;
; HERE WHEN MADE ONE COMPLETE PASS THRU STRING VARS
;
; All string arrays done, now move string
;
; Used by the routine at ARYVAR.
SCNEND:
  POP DE            ; Addresses of strings               ;POP OFF MAX POINTER
  POP HL                                                 ;AND GET VARIABLE POINTER
  LD A,H            ; HL = 0 if no more to do            ;GET LOW IN
  OR L                                                   ;SEE IF ZERO POINTER
  RET Z             ; No more to do - Return             ;IF END OF COLLECTION, THEN MAYBE RETURN TO GETSPA
  DEC HL                                                 ;CURRENTLY JUST PAST THE DESCRIPTOR
  LD B,(HL)         ; MSB of address of string           ;[B]=HIGH BYTE OF DATA POINTER
  DEC HL
  LD C,(HL)         ; LSB of address of string           ;[B,C]=POINTER AT STRING DATA
  PUSH HL           ; Save variable address              ;SAVE THIS LOCATION SO THE POINTER CAN BE UPDATED AFTER THE STRING IS MOVED
  DEC HL
  LD L,(HL)         ; HL = Length of string              ;[L]=STRING LENGTH
  LD H,$00                                               ;[H,L] GET CHARACTER COUNT
  ADD HL,BC         ; Address of end of string+1         ;[H,L]=POINTER BEYOND STRING
  LD D,B            ; String address to DE
  LD E,C                                                 ;[D,E]=ORIGINAL POINTER
  DEC HL            ; Last byte in string                ;DON'T MOVE ONE BEYOND STRING
  LD B,H            ; Address to BC                      ;GET TOP OF STRING IN [B,C]
  LD C,L
  LD HL,(FRETOP)    ; Current bottom of string area      ;GET TOP OF FREE SPACE
  CALL MOVUP_0      ; Move string to new address         ;MOVE STRING
  POP HL            ; Restore variable address           ;GET BACK POINTER TO DESC.
  LD (HL),C         ; Save new LSB of address            ;SAVE FIXED ADDR
  INC HL                                                 ;MOVE POINTER
  LD (HL),B         ; Save new MSB of address            ;HIGH PART
  LD H,B            ; Next string area+1 to HL
  LD L,C                                                 ;[H,L]=NEW POINTER
  DEC HL            ; Next string area address           ;FIX UP FRETOP
  JP GARBLP         ; Look for more strings              ;AND TRY TO FIND HIGH AGAIN

; String concatenation
;
; THE FOLLOWING ROUTINE CONCATENATES TWO STRINGS
; THE FACLO CONTAINS THE FIRST ONE AT THIS POINT,
; [H,L] POINTS BEYOND THE + SIGN AFTER IT
;
; Routine at 26503
; Used by the routine at EVAL3.
CONCAT:
  PUSH BC           ; Save prec' opr & code string       ;PUT OLD PRECEDENCE BACK ON
  PUSH HL                                                ;SAVE TEXT POINTER
  LD HL,(FACLOW)    ; Get first string                   ;GET POINTER TO STRING DESC.
  EX (SP),HL        ; Save first string                  ;SAVE ON STACK & GET TEXT POINTER BACK
  CALL OPRND        ; Get second string                  ;EVALUATE REST OF FORMULA
  EX (SP),HL        ; Restore first string               ;SAVE TEXT POINTER, GET BACK DESC.
  CALL TSTSTR       ; Make sure it's a string
  LD A,(HL)         ; Get length of second string
  PUSH HL           ; Save first string                  ;SAVE DESC. POINTER.
  LD HL,(FACLOW)    ; Get second string                  ;GET POINTER TO 2ND DESC.
  PUSH HL           ; Save second string                 ;SAVE IT
  ADD A,(HL)        ; Add length of second string        ;ADD TWO LENGTHS TOGETHER
  LD DE,$000F       ; Err $0F - "String too long"        ;SEE IF RESULT .LT. 256
  JP C,ERROR        ; String too long - Error            ;ERROR "LONG STRING"
  CALL MKTMST       ; Make temporary string              ;GET INITIAL STRING
  POP DE            ; Get second string to DE            ;GET 2ND DESC.
  CALL GSTRDE       ; Move to string pool if needed
  EX (SP),HL        ; Get first string                   ;SAVE POINTER TO IT
  CALL GSTRHL       ; Move to string pool if needed      ;FREE UP 1ST TEMP
  PUSH HL           ; Save first string                  ;SAVE DESC. POINTER (FIRST)
  LD HL,(TMPSTR)    ; Temporary string address           ;GET POINTER TO FIRST
  EX DE,HL          ; To DE                              ;IN [D,E]
  CALL SSTSA        ; First string to string area        ;MOVE IN THE FIRST STRING
  CALL SSTSA        ; Second string to string area       ;AND THE SECOND
  LD HL,EVAL2       ; Return to evaluation loop          ;CAT REENTERS FORMULA EVALUATION AT EVAL2
  EX (SP),HL        ; Save return,get code string
  PUSH HL           ; Save code string address           ;TEXT POINTER OFF FIRST
  JP TSTOPL         ; To temporary string to pool        ;THEN RETURN ADDRESS OF TSTOP

; Routine at 26559
;
; Used by the routine at CONCAT.
SSTSA:
  POP HL            ; Return address                     ;GET RETURN ADDR
  EX (SP),HL        ; Get string block,save return       ;PUT BACK, BUT GET DESC.
  LD A,(HL)         ; Get length of string               ;[A]=STRING LENGTH
  INC HL
  LD C,(HL)         ; Get LSB of string address          ;[B,C]=POINTER AT STRING DATA
  INC HL
  LD B,(HL)         ; Get MSB of string address
  LD L,A            ; Length to L                        ;[L]=STRING LENGTH
  
; Move string in BC, (len in L) to string area
; a.k.a. MOVSTR
; This entry point is used by the routines at SAVSTR and __LEFT_S.
TOSTRA:
  INC L                 ; INC - DECed after
  
TSALP:
  DEC L             ; Count bytes moved                  ;SET CC'S
  RET Z             ; End of string - Return             ;0, NO BYTE TO MOVE
;MV_MEM:
; Move the memory pointed by BC to the memory pointed by DE, L times.
  LD A,(BC)         ; Get source                         ;GET CHAR
  LD (DE),A         ; Save destination                   ;SAVE IT
  INC BC            ; Next source                        ;MOVE POINTERS
  INC DE            ; Next destination
  JR TSALP          ; Loop until string moved            ;KEEP DOING IT


; Get string pointed by FPREG 'Type Error' if it is not
;
; a.k.a. FRESTR
; FRETMP IS PASSED A POINTER TO A STRING DESCRIPTOR IN [D,E]
; THIS VALUE IS RETURNED IN [H,L]. ALL THE OTHER REGISTERS ARE MODIFIED.
; A CHECK TO IS MADE TO SEE IF THE STRING DESCRIPTOR [D,E] POINTS TO
; IS THE LAST TEMPORARY DESCRIPTOR ALLOCATED BY PUTNEW.
; IF SO, THE TEMPORARY IS FREED UP BY THE UPDATING OF TEMPPT.
; IF A TEMPORARY IS FREED UP, A FURTHER CHECK IS MADE TO SEE IF THE STRING DATA
; THAT THAT STRING TEMPORARY POINTED TO IS THE THE LOWEST PART OF STRING SPACE IN USE.
; IF SO, FRETMP IS UPDATED TO REFLECT THE FACT THAT THAT SPACE IS NO LONGER IN USE.
;
; Routine at 26576
;
; Used by the routines at __NEXT, __LEN, FN_INSTR, LHSMID, NAMSCN and __SPRITE.
; $67D0
GETSTR:
  CALL TSTSTR           ; Make sure it's a string

; Get string pointed by FPREG
;
; Used by the routines at FN_USR, __STR_S, PRS1 and __FRE.
; a.k.a. FREFAC
GSTRCU:
  LD HL,(FACLOW)        ; Get current string

; Get string pointed by HL
;
; Used by the routines at L61C4, CONCAT and FN_INSTR.
GSTRHL:
  EX DE,HL              ; Save DE                            ;FREE UP THE TEMP IN THE FACLO

; Get string pointed by DE
;
; Used by the routines at __NEXT, CONCAT and __LEFT_S.
GSTRDE:
  CALL FRETMS		    ; Was it last tmp-str?               ;FREE UP THE TEMPORARY 
  EX DE,HL              ; Restore DE                         ;PUT THE STRING POINTER INTO [H,L]
  RET NZ                ; No - Return
  PUSH DE               ; Save string                        ;SAVE [D,E] TO RETURN IN [H,L]
  LD D,B                ; String block address to DE         ;[D,E]=POINTER AT STRING
  LD E,C
  DEC DE                ; Point to length                    ;SUBTRACT ONE
  LD C,(HL)             ; Get string length                  ;[C]=LENGTH OF THE STRING FREED UP
  LD HL,(FRETOP)        ; Current bottom of string area      ;SEE IF ITS THE FIRST ONE IN STRING SPACE
  RST DCOMPR		    ; Last one in string area?
  JR NZ,POPHL           ; No - Return                        ;NO SO DON'T ADD
  LD B,A                ; Clear B (A=0)                      ;MAKE [B]=0
  ADD HL,BC             ; Remove string from str' area       ;ADD
  LD (FRETOP),HL        ; Save new bottom of str' area       ;AND UPDATE FRETOP
POPHL:
  POP HL                ; Restore string                     ;GET POINTER AT CURRENT DESCRIPTOR
  RET

; Routine at 26606
;
; Used by the routines at __LET and GSTRDE.
; Back to last tmp-str entry
; a.k.a BAKTMP
FRETMS:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HFRET		; Hook for 'Free descriptor' event
ENDIF
  LD HL,(TEMPPT)    ; Back                               ;GET TEMP POINTER
  DEC HL            ; Get MSB of address                 ;LOOK AT WHAT IS IN THE LAST TEM
  LD B,(HL)         ; Back                               ;[B,C]=POINTER AT STRING
  DEC HL            ; Get LSB of address                 ;DECREMENT TEMPPT BY STRSIZ
  LD C,(HL)         ; Back
  DEC HL            ; Back
  RST DCOMPR		; String last in string pool?        ;SEE IF [D,E] POINT AT THE LAST 
  RET NZ            ; Yes - Leave it                     ;RETURN NOW IF NOW FREEING DONE
  LD (TEMPPT),HL    ; Save new string pool top           ;UPDATE THE TEMP POINTER SINCE ITS BEEN DECREMENTED BY 4
  RET
  

; 'LEN' BASIC function
;
; THE FUNCTION LEN($) RETURNS THE LENGTH OF THE
; STRING PASSED AS AN ARGUMENT
;
; Routine at 26623
__LEN:
  LD BC,PASSA        ; To return integer A                ;CALL SNGFLT WHEN DONE
  PUSH BC            ; Save address                       ;LIKE SO

; This entry point is used by the routines at __ASC and __VAL.
GETLEN:
  CALL GETSTR        ; Get string and its length          ;FREE UP TEMP POINTED TO BY FACLO
  XOR A                                                   ;FORCE NUMERIC FLAG
  LD D,A             ; Clear D                            ;SET HIGH OF [D,E] TO ZERO FOR VAL
  LD A,(HL)          ; Get length of string
  OR A               ; Set status flags                   ;SET CONDITION CODES ON LENGTH
  RET                                                     ;RETURN


; 'ASC' BASIC function
;
; THE FOLLOWING IS THE ASC($) FUNCTION. IT RETURNS AN INTEGER
; WHICH IS THE DECIMAL ASCII EQUIVALENT
;
; Routine at 26635
__ASC:
  LD BC,PASSA        ; To return integer A                ;WHERE TO GO WHEN DONE
  PUSH BC            ; Save address                       ;SAVE RETURN ADDR ON STACK

; This entry point is used by the routine at FN_STRING.
__ASC_0:
  CALL GETLEN        ; Get length of string               ;SET UP ORIGINAL STR
  JP Z,FC_ERR		 ; Null string - Error                ;NULL STR, BAD ARG.
  INC HL                                                  ;BUMP POINTER
  LD E,(HL)          ; Get LSB of address                 ;[D,E]=POINTER AT STRING DATA
  INC HL
  LD D,(HL)          ; Get MSB of address
  LD A,(DE)          ; Get first byte of string           ;[A]=FIRST CHARACTER
  RET


; 'CHR$' BASIC function
;
; CHR$(#) CREATES A STRING WHICH CONTAINS AS ITS ONLY
; CHARACTER THE ASCII EQUIVALENT OF THE INTEGER ARG (#)
; WHICH MUST BE .LE. 255.
;
; Routine at 26651
__CHR_S:
  CALL STRIN1        ; Make One character temporary string   ;GET STRING IN DSCTMP
  CALL CONINT        ; Make it integer A                     ;GET INTEGER IN RANGE

; This entry point is used by the routine at FN_INKEY.
SETSTR:
  LD HL,(TMPSTR)     ; Get address of string              ;GET ADDR OF STR
  LD (HL),E          ; Save character                     ;SAVE ASCII BYTE

; Save in string pool
;
; Used by the routine at FN_STRING.
TOPOOL:
  POP BC            ; Clean up stack                      ;RETURN TO HIGHER LEVEL & SKIP THE CHKNUM CALL.
  JP TSTOPL         ; Temporary string to pool            ;GO CALL PUTNEW

; Routine at 26665
;
; Used by the routine at OPRND.
FN_STRING:
  RST CHRGTB        ;GET NEXT CHAR FOLLOWING "STRING$"
  RST SYNCHR        
  DEFB '('          ;MAKE SURE LEFT PAREN
  CALL GETINT       ;EVALUATE FIRST ARG (LENGTH)
  PUSH DE           ;SAVE IT
  RST SYNCHR        
  DEFB ','          ;COMMA
  CALL EVAL         ;GET FORMULA ARG 2
  RST SYNCHR        
  DEFB ')'          ;EXPECT RIGHT PAREN
  EX (SP),HL        ;SAVE TEXT POINTER ON STACK, GET REP FACTOR
  PUSH HL           ;SAVE BACK REP FACTOR
  RST GETYPR        ;GET TYPE OF ARG
  JR Z,STRSTR       ;WAS A STRING
  CALL CONINT       ;GET ASCII VALUE OF CHAR
  JR CALSPA         ;NOW CALL SPACE CODE
  
STRSTR:
  CALL __ASC_0      ;GET VALUE OF CHAR IN [A]
CALSPA:
  POP DE            ;GET REP FACTOR IN [E]
  CALL __SPACE_S_0  ;INTO SPACE CODE, PUT DUMMY ENTRY ON STACK POPPED OFF BY FINBCK
  
__SPACE_S:
  CALL CONINT       ;GET NUMBER OF CHARS IN [E]
  LD A,' '          ;GET SPACE CHAR

__SPACE_S_0:
  PUSH AF           ;SAVE CHAR
  LD A,E            ;GET NUMBER OF CHARS IN [A]
  CALL MKTMST		;GET A STRING THAT LONG
  LD B,A            ;COUNT OF CHARS BACK IN [B]
  POP AF            ;GET BACK CHAR TO PUT IN STRING
  INC B             ;TEST FOR NULL STRING
  DEC B             
  JR Z,TOPOOL       ;YES, ALL DONE
  LD HL,(TMPSTR)    ;GET DESC. POINTER
SPLP:
  LD (HL),A         ;SAVE CHAR
  INC HL            ;BUMP PTR
  DJNZ SPLP         ;DECR COUNT, KEEP STORING CHAR
  JR TOPOOL         ;PUT TEMP DESC WHEN DONE


; 'LEFT$' BASIC function
;
; THE FOLLOWING IS THE LEFT$($,#) FUNCTION.
; IT TAKES THE LEFTMOST # CHARS OF THE STR.
; IF # IS .GT. THAN THE LEN OF THE STR, IT RETURNS THE WHOLE STR.
;
; Routine at 26721
__LEFT_S:
  CALL LFRGNM			; Get number and ending ")"            ;TEST THE PARAMETERS
  XOR A                 ; Start at first byte in string        ;LEFT NEVER CHANGES STRING POINTER

; This entry point is used by the routine at __RIGHT_S.
RIGHT1:
  EX (SP),HL            ; Save code string,Get string          ;SAVE TEXT POINTER
  LD C,A                ; Starting position in string          ;OFFSET NOW IN [C]
  
  DEFB $3E              ; "LD A,n" to Mask the next byte       ;SKIP THE NEXT BYTE WITH "MVI A,"

;
; THIS IS PRINT USINGS ENTRY POINT INTO LEFT$
;
__LEFT_S_1:
  PUSH HL               ; Save string block address (twice)    ;THIS IS A DUMMY PUSH TO OFFSET THE EXTRA POP IN PUTNEW

; Continuation of MID$ routine
MID1:
  PUSH HL               ; Save string block address            ;SAVE DESC. FOR  FRETMP
  LD A,(HL)             ; Get length of string                 ;GET STRING LENGTH
  CP B                  ; Compare with number given            ;ENTIRE STRING WANTED?
  JR C,ALLFOL           ; All following bytes required         ;IF #CHARS ASKED FOR.GE.LENGTH,YES
  LD A,B                ; Get new length                       ;GET TRUNCATED LENGTH OF STRING
  DEFB $11              ; "LD DE,nn" to skip "LD C,0"          ;SKIP OVER MVI USING "LXI D,"

ALLFOL:
  LD C,0                ; First byte of string                 ;MAKE OFFSET ZERO
  PUSH BC               ; Save position in string              ;SAVE OFFSET ON STACK
  CALL TESTR            ; See if enough string space           ;GET SPACE FOR NEW STRING
  POP BC                ; Get position in string               ;GET BACK OFFSET
  POP HL                ; Restore string block address         ;GET BACK DESC POINTER.
  PUSH HL               ; And re-save it                       ;BUT KEEP ON STACK
  INC HL                                                       ;MOVE TO STRING POINTER FIELD
  LD B,(HL)             ; Get LSB of address                   ;GET POINTER LOW
  INC HL                                                       ;
  LD H,(HL)             ; Get MSB of address                   ;POINTER HIGH
  LD L,B                ; HL = address of string               ;GET LOW IN  L
  LD B,$00              ; BC = starting address                ;GET READY TO ADD OFFSET TO POINTER
  ADD HL,BC             ; Point to that byte                   ;ADD  IT
  LD B,H                ; BC = source string                   ;GET OFFSET POINTER IN [B,C]
  LD C,L
  CALL CRTMST	        ; Create a string entry                ;SAVE INFO IN DSCTMP
  LD L,A                ; Length of new string                 ;GET#  OF CHARS TO  MOVE IN L
  CALL TOSTRA           ; Move string to string area           ;MOVE THEM IN
  POP DE                ; Clear stack                          ;GET BACK DESC. POINTER
  CALL GSTRDE           ; Move to string pool if needed        ;FREE IT UP.
  JP TSTOPL             ; Temporary string to pool             ;PUT TEMP IN TEMP LIST


; 'RIGHT$' BASIC function
; Routine at 26769
__RIGHT_S:
  CALL LFRGNM			; Get number and ending ")"            ;CHECK ARG
  POP DE                ; Get string length                    ;GET DESC. POINTER
  PUSH DE               ; And re-save                          ;SAVE BACK FOR LEFT
  LD A,(DE)             ; Get length                           ;GET PRESENT LEN OF STR
  SUB B                 ; Move back N bytes                    ;SUBTRACT 2ND PARM
  JR RIGHT1             ; Go and get sub-string                ;CONTINUE WITH LEFT CODE


; 'MID$' BASIC function
;
; MID ($,#) RETURNS STR WITH CHARS FROM # POSITION
; ONWARD. IF # IS GT LEN($) THEN RETURN NULL STRING.
; MID ($,#,#) RETURNS STR WITH CHARS FROM # POSITION
; FOR #2 CHARS. IF #2 GOES PAST END OF STRING, RETURN
; AS MUCH AS POSSIBLE.
;
; Routine at 26778
__MID_S:
  EX DE,HL              ; Get code string address              ;PUT THE TEXT POINTER IN [H,L]
  LD A,(HL)             ; Get next byte "," or ")"             ;GET THE FIRST CHARACTER
  CALL MIDNUM           ; Get number supplied                  ;GET OFFSET OFF STACK AND MAKE
  INC B                 ; Is it character zero?
  DEC B                                                        ;SEE IF EQUAL TO ZERO
  JP Z,FC_ERR           ; Yes - Error                          ;IT MUST NOT BE 0 SURE DOES NOT = 0.
  PUSH BC               ; Save starting position               ;PUT OFFSET ON TO THE STACK
  CALL MID_ARGSEP       ; test ',' & ')'                       ;DUPLICATE OF CODE CONDITIONED OUT BELOW
  POP AF                ; Restore starting position            ;GET OFFSET BACK IN A
  EX (SP),HL            ; Get string,save code string          ;SAVE TEXT POINTER, GET DESC.
  LD BC,MID1            ; Continuation of MID$ routine         ;WHERE TO RETURN TO.
  PUSH BC               ; Save for return                      ;GOES ON STACK
  DEC A                 ; Starting position-1                  ;SUB ONE FROM OFFSET
  CP (HL)               ; Compare with length                  ;POINTER PAST END OF STR?
  LD B,$00              ; Zero bytes length                    ;ASSUME NULL LENGTH STR
  RET NC                ; Null string if start past end        ;YES, JUST USE NULL STR
  LD C,A                ; Save starting position-1             ;SAVE OFFSET OF CHARACTER POINTER
  LD A,(HL)             ; Get length of string                 ;GET PRESENT LEN OF STR
  SUB C                 ; Subtract start                       ;SUBTRACT INDEX (2ND ARG)
  CP E                  ; Enough string for it?                ;IS IT TRUNCATION
  LD B,A                ; Save maximum length available        ;GET CALCED LENGTH IN B
  RET C                 ; Truncate string if needed            ;IF NOT USE PARTIAL STR
  LD B,E                ; Set specified length                 ;USE TRUNCATED LENGTH
  RET                   ; Go and create string                 ;RETURN TO LEFT2


; 'VAL' BASIC function
;
; THE VAL FUNCTION TAKES A STRING AND TURN IT INTO
; A NUMBER BY INTERPRETING THE ASCII DIGITS. ETC..
; EXCEPT FOR THE PROBLEM THAT A TERMINATOR MUST BE SUPPLIED
; BY REPLACING THE CHARACTER BEYOND THE STRING, VAL
; IS MERELY A CALL TO FLOATING INPUT (FIN).
;
; Routine at 26811
__VAL:
  CALL GETLEN               ; Get length of string                 ;DO SETUP, SET RESULT=REAL
  JP Z,PASSA                ; Result zero                          ;MAKE SURE TYPE SET UP OK IN EXTENDED
  LD E,A                    ; Save length                          ;GET LENGTH OF STR
  INC HL                                                           ;TO HANDLE THE FACT THE IF
  LD A,(HL)                 ; Get LSB of address
  INC HL
  LD H,(HL)                 ; Get MSB of address                   ;TWO STRINGS "1" AND "2"
  LD L,A                    ; HL = String address                  ;ARE STORED NEXT TO EACH OTHER
  PUSH HL                   ; Save string address                  ;AND FIN IS CALLED POINTING TO
  ADD HL,DE                                                        ;THE FIRST TWELVE WILL BE RETURNED
  LD B,(HL)                 ; Get end of string+1 byte
  LD (VLZADR),HL                                                   
  LD A,B                                                           
  LD (VLZDAT),A
  LD (HL),D                 ; Zero it to terminate                 ;THE IDEA IS TO STORE 0 IN THE
                                                                   ;STRING BEYOND THE ONE VAL
                                                                   ;IS BEING CALLED ON
  EX (SP),HL                ; Save string end,get start
  PUSH BC                   ; Save end+1 byte                      ;THE FIRST CHARACTER OF THE NEXT STRING
  DEC HL                                                           ;***CALL CHRGET TO MAKE SURE
  RST CHRGTB                                                       ;VAL(" -3")=-3
  CALL FIN_DBL              ; Convert ASCII string to FP           ;IN EXTENDED, GET ALL THE PRECISION WE CAN
  LD HL,$0000
  LD (VLZADR),HL
  POP BC                    ; Restore end+1 byte                   ;GET THE MODIFIED CHARACTER OF THE NEXT STRING INTO [B]
  POP HL                    ; Restore end+1 address                ;GET THE POINTER TO THE MODIFIED CHARACTER
  LD (HL),B                 ; Put back original byte               ;RESTORE THE CHARACTER

					;IF STRING IS HIGHEST IN STRING SPACE
					;WE ARE MODIFYING [MEMSIZ] AND
					;THIS IS WHY [MEMSIZ] CAN'T BE USED TO STORE
					;STRING DATA BECAUSE WHAT IF THE
					;USER TOOK VAL OFF THAT HIGH STRING
  RET


; Routine at 26851
;
; Get number, check for ending ')'
; Used by the routines at __LEFT_S and __RIGHT_S.
; USED BY RIGHT$ AND LEFT$ FOR PARAMETER CHECKING AND SETUP
LFRGNM:
  EX DE,HL          ; Code string address to HL            ;PUT THE TEXT POINTER IN [H,L]
  RST SYNCHR 		; Make sure ")" follows                ;PARAM LIST SHOULD END
  DEFB ')'

; Get numeric argument for MID$
; USED BY MID$ FOR PARAMETER CHECKING AND SETUP
MIDNUM:
  POP BC            ; Get return address                   ;GET RETURN ADDR OFF STACK
  POP DE            ; Get number supplied                  ;GET LENGTH OF ARG OFF STACK
  PUSH BC           ; Re-save return address               ;SAVE RETURN ADDR BACK ON
  LD B,E            ; Number to B                          ;SAVE INIT LENGTH
  RET


; INSTR
;
; THIS IS THE INSTR FUCNTION. IT TAKES ONE OF TWO
; FORMS: INSTR(I%,S1$,S2$) OR INSTR(S1$,S2$)
; IN THE FIRST FORM THE STRING S1$ IS SEARCHED FOR THE
; CHARACTER S2$ STARTING AT CHARACTER POSITION I%.
; THE SECOND FORM IS IDENTICAL, EXCEPT THAT THE SEARCH
; STARTS AT POSITION 1. INSTR RETURNS THE CHARACTER
; POSITION OF THE FIRST OCCURANCE OF S2$ IN S1$.
; IF S1$ IS NULL, 0 IS RETURNED. IF S2$ IS NULL, THEN
; I% IS RETURNED, UNLESS I% .GT. LEN(S1$) IN WHICH
; CASE 0 IS RETURNED.
;
; Routine at 26859
;
; Used by the routine at OPRND.
FN_INSTR:
  RST CHRGTB           ;EAT FIRST CHAR
  CALL OPNPAR          ;EVALUATE FIRST ARG
  RST GETYPR           ;SET ZERO IF ARG A STRING.
  LD A,$01             ;IF SO, ASSUME, SEARCH STARTS AT FIRST CHAR
  PUSH AF              ;SAVE OFFSET IN CASE STRING
  JR Z,FN_INSTR_0      ;WAS A STRING
  POP AF               ;GET RID OF SAVED OFFSET
  CALL CONINT          ;FORCE ARG1 (I%) TO BE INTEGER
  OR A                 ;DONT ALLOW ZERO OFFSET
  JP Z,FC_ERR          ;KILL HIM.
  PUSH AF              ;SAVE FOR LATER
  RST SYNCHR           
  DEFB ','             ;EAT THE COMMA
  CALL EVAL            ;EAT FIRST STRING ARG
  CALL TSTSTR          ;BLOW UP IF NOT STRING
FN_INSTR_0:            
  RST SYNCHR           
  DEFB ','             ;EAT COMMA AFTER ARG
  PUSH HL              ;SAVE THE TEXT POINTER
  LD HL,(FACLOW)       ;GET DESCRIPTOR POINTER
  EX (SP),HL           ;PUT ON STACK & GET BACK TEXT PNT.
  CALL EVAL            ;GET LAST ARG
  RST SYNCHR           
  DEFB ')'             ;EAT RIGHT PAREN
  PUSH HL              ;SAVE TEXT POINTER
  CALL GETSTR          ;FREE UP TEMP & CHECK STRING
  EX DE,HL             ;SAVE 2ND DESC. POINTER IN [D,E]
  POP BC               ;GET TEXT POINTER IN B
  POP HL               ;DESC. POINTER FOR S1$
  POP AF               ;OFFSET
  PUSH BC              ;PUT TEXT POINTER ON BOTTOM
  LD BC,POPHLRT        ;PUT ADDRESS OF POP H, RET ON
  PUSH BC              ;PUSH IT
  LD BC,PASSA          ;NOW ADDRESS OF [A] RETURNER
  PUSH BC              ;ONTO STACK
  PUSH AF              ;SAVE OFFSET BACK
  PUSH DE              ;SAVE DESC. OF S2
  CALL GSTRHL          ;FREE UP S1 DESC.
  POP DE               ;RESTORE DESC. S2
  POP AF               ;GET BACK OFFSET
  LD B,A               ;SAVE UNMODIFIED OFFSET
  DEC A                ;MAKE OFFSET OK
  LD C,A               ;SAVE IN C
  CP (HL)              ;IS IT BEYOND LENGTH OF S1?
  LD A,$00             ;IF SO, RETURN ZERO. (ERROR)
  RET NC               
  LD A,(DE)            ;GET LENGTH OF S2$
  OR A                 ;NULL??
  LD A,B               ;GET OFFSET BACK
  RET Z                ;ALL IF S2 NULL, RETURN OFFSET
  LD A,(HL)            ;GET LENGTH OF S1$
  INC HL               ;BUMP POINTER
  LD B,(HL)            ;GET 1ST BYTE OF ADDRESS
  INC HL               ;BUMP POINTER
  LD H,(HL)            ;GET 2ND BYTE
  LD L,B               ;GET 1ST BYTE SET UP
  LD B,$00             ;GET READY FOR DAD
  ADD HL,BC            ;NOW INDEXING INTO STRING
  SUB C                ;MAKE LENGTH OF STRING S1$ RIGHT
  LD B,A               ;SAVE LENGTH OF 1ST STRING IN [B]
  PUSH BC              ;SAVE COUNTER, OFFSET
  PUSH DE              ;PUT 2ND DESC (S2$) ON STACK
  EX (SP),HL           ;GET 2ND DESC. POINTER
  LD C,(HL)            ;SET UP LENGTH
  INC HL               ;BUMP POINTER
  LD E,(HL)            ;GET FIRST BYTE OF ADDRESS
  INC HL               ;BUMP POINTER AGAIN
  LD D,(HL)            ;GET 2ND BYTE
  POP HL               ;RESTORE POINTER FOR 1ST STRING
CHK1:
  PUSH HL              ;SAVE POSITION IN SEARCH STRING
  PUSH DE              ;SAVE START OF SUBSTRING
  PUSH BC              ;SAVE WHERE WE STARTED SEARCH
CHK:
  LD A,(DE)            ;GET CHAR FROM SUBSTRING
  CP (HL)              ; = CHAR POINTER TO BY [H,L]
  JR NZ,OHWELL         ;NO
  INC DE               ;BUMP COMPARE POINTER
  DEC C                ;END OF SEARCH STRING?
  JR Z,GOTSTR          ;WE FOUND IT!
  INC HL               ;BUMP POINTER INTO STRING BEING SEARCHED
  DJNZ CHK             ;DECREMENT LENGTH OF SEARCH STRING
  POP DE               ;END OF STRING, YOU LOSE
  POP DE               ;GET RID OF POINTERS
  POP BC               ;GET RID OF GARB
RETZER:
  POP DE               ;LIKE SO
  XOR A                ;GO TO SNGFLT.
  RET                  ;RETURN
  
GOTSTR:
  POP HL
  POP DE               ;GET RID OF GARB
  POP DE               ;GET RID OF EXCESS STACK
  POP BC               ;GET COUNTER, OFFSET
  LD A,B               ;GET ORIGINAL SOURCE COUNTER
  SUB H                ;SUBTRACT FINAL COUNTER
  ADD A,C              ;ADD ORIGINAL OFFSET (N1%)
  INC A                ;MAKE OFFSET OF ZERO = POSIT 1
  RET                  ;DONE
                       
OHWELL:                
  POP BC               
  POP DE               ;POINT TO START OF SUBSTRING
  POP HL               ;GET BACK WHERE WE STARTED TO COMPARE
  INC HL               ;AND POINT TO NEXT CHAR
  DJNZ CHK1            ;DECR. # CHAR LEFT IN SOURCE STRING, TRY SEARCHING SOME MORE
  JR RETZER            ;END OF STRING, RETURN 0


; STRING FUNCTIONS - LEFT HAND SIDE MID$
; Routine at 26990
;
; Used by the routine at NOT_KEYWORD.
LHSMID:
  RST SYNCHR
  DEFB '('             ;MUST HAVE (
  CALL GETVAR          ;GET A STRING VAR
  CALL TSTSTR          ;MAKE SURE IT WAS A STRING
  PUSH HL              ;SAVE TEXT POINTER
  PUSH DE              ;SAVE DESC. POINTER
  EX DE,HL             ;PUT DESC. POINTER IN [H,L]
  INC HL               ;MOVE TO ADDRESS FIELD
  LD E,(HL)            ;GET ADDRESS OF LHS IN [D,E]
  INC HL               ;BUMP DESC. POINTER
  LD D,(HL)            ;PICK UP HIGH BYTE OF ADDRESS
  LD HL,(STREND)       ;SEE IF LHS STRING IS IN STRING SPACE
  RST DCOMPR           ;BY COMPARING IT WITH STKTOP
  JR C,NCPMID          ;IF ALREADY IN STRING SPACE DONT COPY.

               ;9/23/79 Allow MID$ on field strings
  LD HL,(TXTTAB)
  RST DCOMPR           ;Is this a fielded string?
  JR NC,NCPMID         ;Yes, Don't copy!!
  POP HL               ;GET BACK DESC. POINTER
  PUSH HL              ;SAVE BACK ON STACK
  CALL STRCPY          ;COPY THE STRING LITERAL INTO STRING SPACE
  POP HL               ;GET BACK DESC. POINTER
  PUSH HL              ;BACK ON STACK AGAIN
  CALL VMOVE           ;MOVE NEW DESC. INTO OLD SLOT.
NCPMID:
  POP HL               ;GET DESC. POINTER
  EX (SP),HL           ;GET TEXT POINTER TO [H,L] DESC. TO STACK
  RST SYNCHR
  DEFB ','             ;MUST HAVE COMMA
  CALL GETINT          ;GET ARG#2 (OFFSET INTO STRING)
  OR A                 ;MAKE SURE NOT ZERO
  JP Z,FC_ERR          ;BLOW HIM UP IF ZERO
  PUSH AF              ;SAVE ARG#2 ON STACK
  LD A,(HL)            ;RESTORE CURRENT CHAR
  CALL MID_ARGSEP	   ;USE MID$ CODE TO EVALUATE POSIBLE THIRD ARG.
  PUSH DE              ;SAVE THIRD ARG ([E]) ON STACK
  CALL FRMEQL          ;MUST HAVE = SIGN, EVALUATE RHS OF THING.
  PUSH HL              ;SAVE TEXT POINTER.
  CALL GETSTR          ;FREE UP TEMP RHS IF ANY.
  EX DE,HL             ;PUT RHS DESC. POINTER IN [D,E]
  POP HL               ;TEXT POINTER TO [H,L]
  POP BC               ;ARG #3 TO C.
  POP AF               ;ARG #2 TO A.
  LD B,A               ;AND [B]
  EX (SP),HL           ;GET LHS DESC. POINTER TO [H,L] <> TEXT POINTER TO STACK
  PUSH HL              ;SAVE TEXT POINTER
  LD HL,POPHLRT        ;GET ADDR TO RETURN TO
  EX (SP),HL           ;SAVE ON STACK & GET BACK TXT PTR.
  LD A,C               ;GET ARG #3
  OR A                 ;SET CC'S
  RET Z                ;IF ZERO, DO NOTHING
  LD A,(HL)            ;GET LENGTH OF LHS
  SUB B                ;SEE HOW MANY CHARS IN EMAINDER OF STRING
  JP C,FC_ERR          ;CANT ASSIGN PAST LEN(LHS)!
  INC A                ;MAKE PROPER COUNT
  CP C                 ;SEE IF # OF CHARS IS .GT. THIRD ARG
  JR C,BIGLEN          ;IF SO, DONT TRUNCATE
  LD A,C               ;TRUNCATE BY USING 3RD ARG.
BIGLEN:                
  LD C,B               ;GET OFFSET OF STRING IN [C]
  DEC C                ;MAKE PROPER OFFSET
  LD B,$00             ;SET UP [B,C] FOR LATER DAD B.
  PUSH DE              ;SAVE [D,E]
  INC HL               ;POINTER TO ADDRESS FIELD.
  LD E,(HL)            ;GET LOW BYTE IN [E]
  INC HL               ;BUMP POINTER
  LD H,(HL)            ;GET HIGH BYTE IN [H]
  LD L,E               ;NOW COPY LOW BYTE BACK TO [L]
  ADD HL,BC            ;ADD OFFSET
  LD B,A               ;SET COUNT OF LHS IN [B]
  POP DE               ;RESTORE [D,E]
  EX DE,HL             ;MOVE RHS. DESC. POINTER TO [H,L]
  LD C,(HL)            ;GET LEN(RHS) IN [C]
  INC HL               ;MOVE POINTER
  LD A,(HL)            ;GET LOW BYTE OF ADDRESS IN [A]
  INC HL               ;BUMP POINTER.
  LD H,(HL)            ;GET HIGH BYTE OF ADDRESS IN [H]
  LD L,A               ;COPY LOW BYTE TO [L]
  EX DE,HL             ;ADDRESS OF RHS NOW IN [D,E]
  LD A,C               ;IS RHS NULL?
  OR A                 ;TEST
  RET Z                ;THEN ALL DONE.

; NOW ALL SET UP FOR ASSIGNMENT.
; [H,L] = LHS POINTER
; [D,E] = RHS POINTER
; C = LEN(RHS)
; B = LEN(LHS)

MID_LP:
  LD A,(DE)            ;GET BYTE FROM RHS.
  LD (HL),A            ;STORE IN LHS
  INC DE               ;BUMP RHS POINTER
  INC HL               ;BUMP LHS POINTER.
  DEC C                ;BUMP DOWN COUNT OF RHS.
  RET Z                ;IF ZERO, ALL DONE.
  DJNZ MID_LP          ;IF LHS ENDED, ALSO DONE.   IF NOT DONE, MORE COPYING.
  RET                  ;BACK TO NEWSTT


; Routine at 27108
;
; Used by the routines at __MID_S and LHSMID.
; test ',' & ')'
MID_ARGSEP:
  LD E,255             ;IF TWO ARG GUY, TRUNCATE.
  CP ')'               
  JR Z,MID_ARGSEP_0    ;[E] SAYS USE ALL CHARS
                       ;IF ONE ARGUMENT THIS IS CORRECT
  RST SYNCHR           
  DEFB ','             ;COMMA? MUST DELINEATE 3RD ARG.
  CALL GETINT          ;GET ARGUMENT  IN  [E]
MID_ARGSEP_0:          
  RST SYNCHR           
  DEFB ')'             ;MUST BE FOLLOWED BY )
  RET                  ;ALL DONE.

; Routine at 27122
__FRE:
  LD HL,(STREND)
  EX DE,HL
  LD HL,$0000
  ADD HL,SP
  RST GETYPR
  JP NZ,GIVDBL
  CALL GSTRCU          ;FREE UP ARGUMENT AND SETUP TO GIVE FREE STRING SPACE
  CALL GARBGE          ;DO GARBAGE COLLECTION
  LD DE,(STKTOP)
  LD HL,(FRETOP)       ;TOP OF FREE AREA
  JP GIVDBL            ;RETURN [H,L]-[D,E]

; Routine at 27150
;
; Used by the routines at __OPEN, _RUN_FILE, __SAVE and __BSAVE.
; AKA  NAMSCN (name scan) - evaluate filespecification
NAMSCN:
  CALL EVAL
;NAMSC1:
  PUSH HL
  CALL GETSTR
  LD A,(HL)
  OR A					; stringsize zero ?
  JR Z,NAMSCN_2			; yep, bad filename error
  INC HL
  LD E,(HL)
  INC HL
  LD H,(HL)
  LD L,E				; pointer to string
  LD E,A				; size of string
  
  CALL PAR_DNAME		; Parse Device Name
  PUSH AF
  LD BC,FILNAM
  LD D,11
  INC E
; This entry point is used by the routine at FNAME_6.
NAMSCN_0:
  DEC E						; end of filespecification string ?
  JR Z,L6A61				; yep, fill remaining FILNAME with spaces
  LD A,(HL)
  CP ' '					; control characters ?
  JR C,NAMSCN_2				; yep, bad filename error
  CP '.'					; filename/extension seperator ?
  JR Z,FNAME_7				; yep, handle extension
  LD (BC),A
  INC BC
  INC HL
  DEC D						; FILNAM full ?
  JR NZ,NAMSCN_0			; nope, next
; This entry point is used by the routine at L6A61.
NAMSCN_1:
  POP AF
  PUSH AF
  LD D,A					; devicecode
  LD A,(FILNAM)
  INC A						; first character FILNAME charactercode 255 ?
  JR Z,NAMSCN_2				; yep, bad filename error (because this is internally used as runflag)
  POP AF
  POP HL
  RET

; This entry point is used by the routine at FNAME_7.
NAMSCN_2:
  JP NM_ERR					; Err $38 -  'Bad file name'

; Routine at 27210
;
; Used by the routine at FNAME_7.
FNAME_6:
  INC HL
  JR NAMSCN_0

; Routine at 27213
;
; Used by the routine at NAMSCN.
FNAME_7:
  LD A,D
  CP 11
  JP Z,NAMSCN_2
  CP 3
  JP C,NAMSCN_2
  JR Z,FNAME_6
  LD A,' '
  LD (BC),A
  INC BC
  DEC D
  JR FNAME_7

; Routine at 27233
;
; Used by the routine at NAMSCN.
L6A61:
  LD A,' '
  LD (BC),A
  INC BC
  DEC D
  JR NZ,L6A61
  JR NAMSCN_1

;
; CONVERT ARGUMENT TO FILE NUMBER AND SET [B,C] TO POINT TO FILE DATA BLOCK
;
; AT THIS ENTRY POINT THE FAC HAS THE FILE NUMBER IN IT ALREADY
;
; a.k.a. GETFLP
; Routine at 27242
;
; Used by the routines at __LOC, __LOF, __EOF and __FPOS.
FILFRM:
  CALL CONINT            ;GET THE FILE NUMBER INTO [A]
;
; AT THIS POINT IT IS ASSUMED THE FILE NUMBER IS IN [A]
; [D] IS SET TO ZERO. [B,C] IS SAVED.
; [H,L] IS SET TO POINT AT THE FILE DATA BLOCK FOR FILE [E]
; [A] GIVE THE MODE OF THE FILE AND ZERO IS SET, IF THE FILE IS MODE ZERO (NOT OPEN).
;
; This entry point is used by the routines at OPRND, FILSCN and __OPEN.
; a.k.a. VARPTR_A, GETPTR
FILIDX:
  LD L,A                  ;GET FILE NUMBER INTO [L]
  LD A,(MAXFIL)           ;IS THIS FILE # LEGAL?
  CP L
  JP C,BN_ERR             ;IF NOT, "BAD FILE NUMBER"  (Err $34 -  'Bad file number')
  LD H,$00                ;SETUP OFFSET TO GET POINTER TO FILE DATA BLOCK
  ADD HL,HL
  EX DE,HL
  LD HL,(FILTAB)          ;POINT AT POINTER TABLE
  ADD HL,DE               ;ADD ON OFFSET
  LD A,(HL)               ;PICK UP POINTER IN [H,L]
  INC HL
  LD H,(HL)
  LD L,A

  LD A,(NLONLY)           ; Are we loading a program ?
  INC A
  RET Z

  LD A,(HL)               ;GET MODE OF FILE INTO [A]
  OR A                    ;SET ZERO IF FILE NOT OPEN
  RET Z

  PUSH HL
  LD DE,$0004             ;(DATOFC) POINT TO DATA BLOCK
  ADD HL,DE
  LD A,(HL)               ; A = FILE MODE
  CP $09
  JR NC,FILIDX_1
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HGETP				; Hook 1 for Locate FCB
ENDIF
  JP IE_ERR				; Err $33 - "Internal Error"

FILIDX_1:
  POP HL
  LD A,(HL)
  OR A
  SCF
  RET

;
; AT THIS ENTRY POINT [H,L] IS ASSUMED TO BE THE TEXT POINTER AND
; A FILE NUMBER IS SCANNED
;
; Routine at 27294
;
; Used by the routines at GET and FN_INPUT.
FILSCN:
  DEC HL
  RST CHRGTB
  CP '#'                ;MAKE NUMBER SIGN OPTIONAL
  CALL Z,__CHRGTB       ;BY SKIPPING IT IF THERE
  CALL GETINT           ;READ THE FILE NUMBER INTO THE FAC
  EX (SP),HL
  PUSH HL

; a.k.a. SELECT. This entry point is used by the routines at _RUN_FILE and FILINP.
SETFIL:
  CALL FILIDX
  JP Z,CF_ERR			; Err $3B - "File not OPEN"
  LD (PTRFIL),HL		; Redirect I/O
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HSETF			; Hook 2 for Locate FCB
ENDIF
  RET

; Routine at 27319
__OPEN:
  LD BC,FINPRT
  PUSH BC
  CALL NAMSCN
  LD A,(HL)
  CP TK_FOR			; 'FOR'
  LD E,$04
  JR NZ,__OPEN_2
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  CP TK_INPUT		; 'INPUT'
  LD E,$01
  JR Z,__OPEN_INPUT
  
  CP TK_OUT			; 'OUT..PUT'
  JR Z,__OPEN_OUTPUT
  
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB 'A'
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB 'P'
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB 'P'
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB TK_END
  LD E,$08			; 'APPEND'
  JR __OPEN_2
  
__OPEN_OUTPUT:
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB TK_PUT		; "OUTPUT"  :S
  LD E,$02
  JR __OPEN_2
__OPEN_INPUT:
  RST CHRGTB		; Gets next character (or token) from BASIC text.
__OPEN_2:
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB 'A'
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB 'S'			; 'AS'
  PUSH DE
  LD A,(HL)
  CP '#'
  CALL Z,__CHRGTB  ; Gets next character (or token) from BASIC text.
  CALL GETINT              ; Get integer 0-255
  OR A
  JP Z,BN_ERR			; Err $34 -  'Bad file number'
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HNOFO		; Hook for "OPEN": not found event
ENDIF

  DEFB $1E      ;LD E,N
NULOPN:
  PUSH DE		    ; open a "NULL" file
  DEC HL
  LD E,A            ;SAVE FILE NUMBER IN [E]
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JP NZ,SN_ERR
  EX (SP),HL
  LD A,E            ;GET FILE NUMBER
  PUSH AF
  PUSH HL
  CALL FILIDX
  JP NZ,AO_ERR		; Err $36 - "File already open"
  POP DE
  LD A,D
  CP $09
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HNULO		; Hook for "OPEN"
ENDIF
  JP C,IE_ERR				; Err $33 - "Internal Error"
  PUSH HL
  LD BC,$0004
  ADD HL,BC
  LD (HL),D
  LD A,$00
  POP HL
  CALL GET_DEVICE
  POP AF
  POP HL
  RET

; Data block at 27428
  ; --- START PROC CLSFIL ---
CLSFIL:
  PUSH HL
  OR   A
  JR   NZ,NTFL0
  LD   A,(NLONLY)		; <>0 when loading program
  AND  $01
  JP   NZ,POPHLRT2      ;   POP HL / RET
  
; NTFL0 - "NoT FiLe number 0"
NTFL0:
  CALL FILIDX
  JR   Z,NOCLSB_0 		; CLOSE_1
  LD   (PTRFIL),HL
  PUSH HL
  JR   C,NOCLSB		; CLOSE_0
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HNTFL			; Hook for Close I/O buffer 0 event
ENDIF
  JP   IE_ERR			; Err $33 - "Internal Error"

 ; CLOSE_0
NOCLSB:
  LD   A,$02
  CALL GET_DEVICE
  CALL CLRBUF
  POP  HL
 ; CLOSE_1
NOCLSB_0:
  PUSH HL
  LD   DE,$0007
  ADD  HL,DE
  LD   (HL),A
  LD   H,A
  LD   L,A
  LD (PTRFIL),HL		; Redirect I/O
  POP HL
  ADD A,(HL)
  LD (HL),$00
  POP HL
  RET

; Routine at 27483
;
; load and RUN a file when text is addedd to "RUN"
;
; Used by the routine at __RUN.
_RUN_FILE:
  SCF
  defb $11	; LD DE,NN

; Routine at 19824
__LOAD:
  defb $f6		; OR $AF

; Routine at 19825
__MERGE:
  XOR A             ;FLAG ZERO FOR "LOAD"
  PUSH AF           ;SAVE "RUN"/"LOAD" FLAG
  CALL NAMSCN
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HMERG		; Hook for "MERGE/LOAD"
ENDIF
  POP AF
  PUSH AF           ;SEE IF NO RUN OPTION
  JR Z,_LOAD_0      ;NO, JUST LOAD
  LD A,(HL)
  SUB ','           ;GOTTA HAVE A COMMA
  OR A
  JR NZ,_LOAD_0     ;NO, JUST LOAD
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB 'R'          ;ONLY OPTION IS RUN
  POP AF            ;GET RID OF "RUN"/"LOAD" FLAG
  SCF				; Set the 'RUN' flag 
  PUSH AF
_LOAD_0:
  PUSH AF
  XOR A
  LD E,$01
  CALL NULOPN		; OPEN a "NULL file"
  LD HL,(PTRFIL)
  LD BC,$0007
  ADD HL,BC
  POP AF
  SBC A,A
  AND $80
  OR $01
  LD (NLONLY),A
  POP AF
  PUSH AF
  SBC A,A
  LD (FILNAM),A
  LD A,(HL)
  OR A
  JP M,L6BD4			; handle "bad file name" for MERGE/LOAD
  
  POP AF
  CALL NZ,CLRPTR
  XOR A
  CALL SETFIL
  JP PROMPT

; Routine at 27555
__SAVE:
  CALL NAMSCN
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HSAVE		; Hook 1 for "SAVE"
ENDIF
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  LD E,$80
  SCF
  JR Z,__SAVE_0
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB 'A'			;   Save in ASCII mode ?
  OR A
  LD E,$02
__SAVE_0:
  PUSH AF
  LD A,D
  CP $09
  JR C,__SAVE_1
  LD E,$02
  POP AF
  XOR A
  PUSH AF
__SAVE_1:
  XOR A
  CALL NULOPN		; OPEN a "NULL file"
  POP AF
  JR C,__SAVE_2
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JP __LIST
  
__SAVE_2:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HBINS		; Hook 2 for "SAVE"
ENDIF
  JP NM_ERR					; Err $38 -  'Bad file name'

; Routine at 27604
;
; Used by the routine at _LOAD.
; handle "bad file name" for MERGE/LOAD
L6BD4:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HBINL		; Hook for "MERGE/LOAD"
ENDIF
  JP NM_ERR					; Err $38 -  'Bad file name'

; Routine at 27610
; This function is never called by other rountines in the same ROM bank
; It is most probably used by MSXDOS.  On the Spectravideo SVI it is located at $6463.
GETDEV:
  PUSH HL
  PUSH DE
  LD HL,(PTRFIL)
  LD DE,$0004
  ADD HL,DE
  LD A,(HL)
  POP DE
  POP HL
  RET

; Routine at 27623
;
; Used by the routines at RETRTS and CLSALL.
_CLOSE:
  JR NZ,RETRTS_0           ;NOT END OF STATEMENT, SO SCAN ARGUMENTS
  PUSH HL                  ;SAVE THE TEXT POINTER
; This entry point is used by the routine at RETALL.
__CLOSE_0:
  PUSH BC                  ;SAVE ROUTINE ADDRESS
  PUSH AF                  ;SAVE CURRENT VALUE
  LD DE,RETALL             ;RETURN ADDRESS
  PUSH DE                  ;SAVE IT TO COME BACK WITH
  PUSH BC                  ;DISPATCH TO SERVICE ROUTINE
  OR A
  RET

; Routine at 27635
RETALL:
  POP AF                   ;GET BACK OLD ARGUMENT
  POP BC                   ;GET BACK SERVICE ROUTINE ADDRESS
  DEC A                    ;DECREMENT ARGUMENT
  JP P,__CLOSE_0           ;LOOP ON MORE VALUES
  POP HL                   ;GET BACK THE TEXT POINTER
  RET

; Routine at 27643
RETRTS:
  POP BC                   ;GET BACK SERVICE ROUTINE ADDRESS
  POP HL                   ;GET BACK THE TEXT POINTER
  LD A,(HL)                ;SEE IF MORE ARGUMENTS
  CP ','                   ;DELIMITED BY COMMA
  RET NZ
  RST CHRGTB               ;READ FIRST CHARACTER OF FORMULA
; This entry point is used by the routine at _CLOSE.
RETRTS_0:
  PUSH BC                  ;SAVE THE SERVICE ROUTINE ADDRESS
  LD A,(HL)                ;GET POSSBLE "#"
  CP '#'                   ;IS IT
  CALL Z,__CHRGTB          ;SKIP IT, ITS OPTIONAL
  CALL GETINT              ;READ THE ARGUMENT
  EX (SP),HL               ;SAVE THE TEXT POINTER ON THE STACK <> AND SET [H,L]=SERVICE ADDRESS
  PUSH HL                  ;SAVE THE SERVICE ADDRESS
  LD DE,RETRTS             ;PUT A RETURN ADDRESS ON THE STACK
  PUSH DE
  SCF
  JP (HL)                  ;DISPATCH TO DO THE FUNCTION

__CLOSE:
  LD BC,CLSFIL             ;SERVICE ROUTINE ADDRESS
  LD A,(MAXFIL)            ;HIGHEST POSSIBLE ARGUMENT, WHICH MEANS DO ALL POSSIBLE
  JR _CLOSE

; Routine at 27676
;
; Used by the routines at L628E, __END and __MAX.
; Close all files
CLSALL:
  LD A,(NLONLY)
  OR A
  RET M
  LD BC,CLSFIL
  XOR A
  LD A,(MAXFIL)
  JR _CLOSE

; Routine at 27690
__LFILES:
  LD A,$01
  LD (PRTFLG),A
__FILES:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HFILE				; Hook for "FILES"
ENDIF
  JP FC_ERR

; Routine at 27701
;
; Used by the routine at L7756.
GET:
  PUSH AF
  CALL FILSCN
  JR C,GET_0
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HDGET				; Hook for "GET/PUT"
ENDIF
  JP NM_ERR					; Err $38 -  'Bad file name'

GET_0:
  POP DE
  POP BC
  LD A,$04
  JP GET_DEVICE

; Data block at 27720
FILO:
  PUSH HL
  PUSH DE
  PUSH BC
  PUSH AF
  CALL INDSKB               ; GET A CHARACTER FROM A SEQUENTIAL FILE IN [PTRFIL]
  JR NC,L6C57
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HFILO			; Hook for "Sequential Output" event
ENDIF
  JP NM_ERR					; Err $38 -  'Bad file name'
		
L6C57:
  POP  AF
  PUSH AF
  LD C,A
  LD A,$06
  CALL GET_DEVICE
  JP POPALL

;
; GET A CHARACTER FROM A SEQUENTIAL FILE IN [PTRFIL]
; ALL REGISTERS EXCEPT [D,E] SMASHED
; Used also to Check stream buffer status before I/O operations
;
;	'C' set if EOF read
;
INDSKB:
  PUSH DE
  LD HL,(PTRFIL)
  EX DE,HL
  LD HL,$0004
  ADD HL,DE
  LD A,(HL)
  EX DE,HL
  POP DE
  CP $09
  RET


; Routine at 27761
; a.k.a. INDSKC
  ; --- START PROC RDBYT ---
  ; Read byte, C flag is set if EOF
RDBYT:
  PUSH HL
  PUSH DE
  PUSH BC
  CALL INDSKB               ; GET A CHARACTER FROM A SEQUENTIAL FILE IN [PTRFIL]
  JR   NC,RDBYT_0           ; JP IF NOT EOF
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HINDS				; Hook for "Sequential Input" exception
ENDIF
  JP   IE_ERR				; Err $33 - "Internal Error"


RDBYT_0:
  LD A,$08
  CALL GET_DEVICE
  JP POPALL_0

; Routine at 27783
;
; Used by the routine at OPRND.
FN_INPUT:
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB '$'          ;STRING FUNCTION
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB '('
  PUSH HL
  LD HL,(PTRFIL)
  PUSH HL
  LD HL,$0000
  LD (PTRFIL),HL
  POP HL
  EX (SP),HL
  CALL GETINT       ;Get # of bytes to read
  PUSH DE           ;Save # of bytes to read
  LD A,(HL)          
  CP ','            ;Read from disk file?
  JR NZ,REDTTY      ;No, from user's terminal
  RST CHRGTB
  CALL FILSCN       ; Check we have the '#' channel specifier and put the associated file buffer in BC
  CP $01
  JP Z,FN_INPUT_0
  CP $04
  JP NZ,EF_ERR		; Err $37 - "Input past END" (EOF)
FN_INPUT_0:
  POP HL            ;SET UP PTRFIL
  XOR A             ;SET ZERO FOR FLAG
  LD A,(HL)
REDTTY:
  PUSH AF           ;NON ZERO SET IF TERMINAL I/O
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found\n
  DEFB ')'          ;Must have paren
  POP AF            ;Get flag off stack
  EX (SP),HL        ;Save text ptr, [L]=# to read
  PUSH AF           ;Save flag
  LD A,L
  OR A              ;Read no characters?
  JP Z,FC_ERR       ;Yes, error
  PUSH HL           ;Save #
  CALL MKTMST		;Get space for string
  EX DE,HL
  POP BC            ;[C] = # to read
FIXLOP:
  POP AF
  PUSH AF           ;NON-ZERO set if should read from TTY
  JR Z,DSKCHR       ;Read from disk file
  CALL CHGET        ;GET CHAR IF ONE
  PUSH AF           ;WAS ONE
  CALL CKCNTC       ;Check if Control-C
  POP AF
PUTCHR:
  LD (HL),A         ;Put char into string
  INC HL            
  DEC C             ;Read enough yet?
  JR NZ,FIXLOP      ;No, read more
  POP AF            ;Get flag off stack
  POP BC
  POP HL
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HRSLF				; Hook for "INPUT$"
ENDIF
  LD (PTRFIL),HL
  PUSH BC
  JP TSTOPL         ;STOP PROGRAM

DSKCHR:
  CALL RDBYT
  JP C,EF_ERR		; Err $37 - "Input past END" (EOF)
  JR PUTCHR

; Routine at 27882
CLRBUF:
  CALL GETBUF
  PUSH HL
  LD B,$00
  CALL DOCLR
POPHLRT2:
  POP HL
  RET

; Routine at 27893
;
; Used by the routine at CLRBUF.
DOCLR:
  XOR A
DOCLR_0:
  LD (HL),A
  INC HL
  DJNZ DOCLR_0
  RET

; Routine at 27899
;
; Used by the routine at CLRBUF.
GETBUF:
  LD HL,(PTRFIL)
  LD DE,$0009
  ADD HL,DE
  RET

; Routine at 27907
__LOC:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HSAVD			; Init Hook for LOC, LOF, EOF, FPOS
ENDIF
  CALL FILFRM
  JR Z,DERFNO
  LD A,$0A
  JR C,__EOF_1
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HLOC				; Hook for LOC
ENDIF
  JR DERIER				;  Internal error

; Routine at 27924
__LOF:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HSAVD			; Init Hook for LOC, LOF, EOF, FPOS
ENDIF
  CALL FILFRM
  JR Z,DERFNO
  LD A,$0C
  JR C,__EOF_1
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HLOF				; Hook for LOF
ENDIF
  JR DERIER				;  Internal error

; Routine at 27941
__EOF:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HSAVD			; Init Hook for LOC, LOF, EOF, FPOS
ENDIF
  CALL FILFRM

; This entry point is used by the routines at __LOC and __LOF.
; Possible "File Not Open" or "Bad file mode" condition
; On the Spectravideo SVI it was called "DERFND"
DERFNO:
  JP Z,CF_ERR			; Err $3B - "File not OPEN"
  LD A,$0E		; ? LINCON ??
; This entry point is used by the routines at __LOC, __LOF and __FPOS.
__EOF_1:
  JP C,GET_DEVICE
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HEOF				; Hook for EOF
ENDIF
; This entry point is used by the routines at __LOC, __LOF and __FPOS.
DERIER:
  JP IE_ERR				; Err $33 - "Internal Error"

; Routine at 27961
__FPOS:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HSAVD			; Init Hook for LOC, LOF, EOF, FPOS
ENDIF
  CALL FILFRM
  LD A,$10
  JR C,__EOF_1
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HFPOS			; Hook for FPOS
ENDIF
  JR DERIER				;  Internal error

; Routine at 27976
EXEC_FILE:
  CALL ISFLIO
  JP Z,EXEC
  XOR A
  CALL CLSFIL
  JP DS_ERR		; Err $39 - Direct statement in a file

; FILINP AND FILGET -- SCAN A FILE NUMBER AND SETUP PTRFIL

; REVISION HISTORY
; 4/23/78   PGA - ALLOW # ON CLOSE
; 8/6/79    PGA - IF ^C ON MBASIC FOO, DONT RETURN TO SYSTEM. SEE 'NOTINI'
; 6/27/80   PGA - FIX INPUT#1,D# SO IT USES FINDBL INSTEAD OF FIN AND THUS AVOIDS LOSING SIGNIFICANCE.

; Routine at 27989
;
; Get stream number (default #channel=1)
; Used by the routine at FILSTI.
FILINP:
  LD C,$01          ; (MD.SQI) MUST BE SEQUENTIAL INPUT

; Get stream number (C=default #channel)
; Look for '#' channel specifier and put the associated file buffer in BC
FILGET:
  CP '#'            ;NUMBER SIGN THERE?
  RET NZ            ;NO, NOT DISK READER

  PUSH BC           ;SAVE EXPECTED MODE
  CALL FNDNUM		; Numeric argument (0..255)
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','          ;GO PAST THE COMMA
  LD A,E
  PUSH HL
  CALL SETFIL       ;SETUP PTRFIL = HL
  LD A,(HL)
  POP HL
  POP BC            ;[C]=FILE MODE
  CP C              ;IS IT RIGHT?
  JR Z,GDFILM       ;GOOD FILE MODE
  CP $04
  JR Z,GDFILM       ;GOOD FILE MODE
  CP $08
  JR NZ,BDFILM      ;BAD FILE MODE
  LD A,C
  CP $02
BDFILM:
  JP NZ,BN_ERR			; Err $34 -  'Bad file number'

GDFILM:
  LD A,(HL)
  RET

; Routine at 28027
;
; Used by the routine at L7380.
CLOSE_STREAM:
  LD BC,GTMPRT
  PUSH BC
  XOR A
  JP CLSFIL

; Routine at 28035
;
; Used by the routine at __READ.
FILIND:
  RST GETYPR             ;SEE IF INPUT IS STRING OR NUMBER
  LD BC,DOASIG           ;RETURN ADDRESS TO SETUP [FAC]
  LD DE,$2C20            ; D=','  E=' '   ..SETUP TERMINATORS SPACE AND COMMA
  JR NZ,INPDOR           ;IF NUMERIC, GO READ THE FILE
  LD E,D                 ;MAKE BOTH TERMINATORS COMMA
  JR INPDOR              ;GO READ THE FILE

; LINE INPUT & READ CODE FOR ITEM FETCHING FROM SEQUENTIAL INPUT FILES
; Data block at 28047
LINE_INPUT:
  LD BC,FINPRT           ;RESET TO CONSOLE WHEN DONE READING
  PUSH BC                ;SAVE ON STACK
  CALL FILINP            ;GET FILE NUMBER SET UP
  CALL GETVAR            ;READ STRING TO STORE INTO
  CALL TSTSTR            ;MAKE SURE IT WAS A STRING
  PUSH DE
  LD BC,LETCON           ;GOOD RETURN ADDRESS FOR ASSIGNMENT
  XOR A                  ;SET A=0 FOR STRING VALUE TYPE
  LD D,A                 ;ZERO OUT BOTH TERMINATORS
  LD E,A
INPDOR:
  PUSH AF                ;SAVE VALUE TYPE
  PUSH BC                ;SAVE RETURN ADDRESS
  PUSH HL                ;SAVE POINTER AT DATA COMING IN A DUMMY POINTER AT BUFMIN
NOTNWT:
  CALL RDBYT             ;READ A CHARACTER
  JP C,EF_ERR            ;READ PAST END ERROR IF EOF  - Err $37 - "Input past END" (EOF)
  CP ' '                 ;SKIP LEADING SPACES
  JR NZ,NOTSPC           ;EXCEPT FOR LINE INPUT
  INC D                  ;CHECK FOR LINEINPUT
  DEC D
  JR NZ,NOTNWT           ;SKIP ANY NUMBER
NOTSPC:
  CP '"'                 ;QUOTED STRING COMING IN?
  JR NZ,NOTQTE     
  LD A,E                 ;SAVE THE QUOTE
  CP ','                 ;MUST BE INPUT OF A STRING
  LD A,'"'               ;WHICH HAS [E]=44
  JR NZ,NOTQTE           ;QUOTE BACK INTO [A]
  LD D,A                 
  LD E,A                 ;TERMINATORS ARE QUOTES ONLY
  CALL RDBYT             
  JR C,QUITSI            ;READ PAST QUOTATION
NOTQTE:                  ;IF EOF, ALL DONE
  LD HL,BUF              ;BUFFER FOR DATA
  LD B,$FF               ;MAXIMUM NUMBER OF CHARACTERS (255)
LOPCRS:
  LD C,A                 ;SAVE CHARACTER IN [C]
  LD A,D                 ;CHECK FOR QUOTED STRING
  CP '"'                 
  LD A,C                 ;RESTORE CHARACTER
  JR Z,NOTQTL            ;DON'T IGNORE CR OR STOP ON LF
  CP CR                  ;CR?
  PUSH HL                ;SAVE DEST PTR. ON STACK
  JR Z,ICASLF            ;EAT LINE FEED IF ONE
  POP HL                 ;RESTORE DEST. PTR.
  CP LF                  ;LF?
  JR NZ,NOTQTL           ;NO, TEST OTHER TERMINATORS
LPISLF:
  LD C,A                 ;SAVE CURRENT CHAR
  LD A,E                 ;GET TERMINATOR 2
  CP ','                 ;CHECK FOR COMMA (UNQUOTED STRING)
  LD A,C                 ;RESTORE ORIG CHAR
  CALL NZ,STRCHR         ;IF NOT, STORE LF (?)
  CALL RDBYT             ;GET NEXT CHAR
  JR C,QUITSI            ;IF EOF, ALL DONE.

  ;** 5/14/82 BUG FIX (MULTIPLE LF FOR UNQUOTED STRING)
  ; This extra check exists on GW-BASIC, Tandy M100, Olivetti M10 and MSX
  CP LF                  ;IS IT LF?
  JR Z,LPISLF

  CP CR                  ;IS IT A CR?
  JR NZ,NOTQTL           ;IF NOT SEE IF STORE NORMALLY
  LD A,E                 ;GET TERMINATOR
  CP ' '                 ;IS IT NUMERIC INPUT?
  JR Z,LPCRGT            ;IF SO, IGNORE CR, DONT PUT IN BUFFER
  CP ','                 ;IS IT NON-QUOTED STRING (TERM=,)
  LD A,CR                ;GET BACK CR.
  JR Z,LPCRGT            ;IF SO, IGNORE CR.
NOTQTL:
  OR A                   ;IS CHAR ZERO
  JR Z,LPCRGT            ;ALWAYS IGNORE, AS IT IS TERMINATOR FOR STRLIT (SEE QUIT2B)
  CP D                   ;TERMINATOR ONE?
  JR Z,QUITSI            ;STOP THEN
  CP E                   ;TERMINATOR TWO?
  JR Z,QUITSI            
  CALL STRCHR            ;SAVE THE CHAR
LPCRGT:
  CALL RDBYT
  JR NC,LOPCRS
QUITSI:
  PUSH HL                ;SAVE PLACE TO STUFF ZERO
  CP '"'                 ;STOPPED ON QUOTE?
  JR Z,MORSPC            ;DON'T SKIP SPACES THEN, BUT DO SKIP FOLLOWING COMMA OR CRLF THOUGH
  CP ' '                 ;STOPPED ON SPACE?
  JR NZ,NOSKCR           ;NO, DON'T SKIP SPACES OR ANY FOLLOWING COMMAS OR CRLFS EITHER
MORSPC:
  CALL RDBYT             ;READ SPACES
  JR C,NOSKCR            ;EOF, ALL DONE.
  CP ' '
  JR Z,MORSPC
  CP ','                 ;COMMA?
  JR Z,NOSKCR            ;OK, SKIP IT
  CP CR                  ;CARRIAGE RETURN?
  JR NZ,BAKUPT           ;BACK UP PAST THIS CHARACTER
ICASLF:
  CALL RDBYT             ;READ ANOTHER
  JR C,NOSKCR            ;EOF, ALL DONE.
  CP LF                  ;LINE FEED?
  JR Z,NOSKCR            ;OK, SKIP IT TOO
BAKUPT:
  LD C,A
  CALL INDSKB
  JR NC,L6E3C
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HBAKU			; Hook for "LINE INPUT#"
ENDIF
  JP IE_ERR			; Err $33 - "Internal Error"

L6E3C:
  LD A,$12		; INS ?  .. TK_LEN ?
  CALL GET_DEVICE

NOSKCR:
  POP HL            ;GET BACK PLACE TO STORE TERMINATOR

; This entry point is used by the routine at STRCHR.
QUIT2B:
  LD (HL),$00       ;STORE THE TERMINATOR
  LD HL,BUFMIN      ;(buf-1) ITEM IS NOW STORED AT THIS POINT +1
  LD A,E            ;WAS IT A NUMERIC INPUT?
  SUB $20           ;IF SO, [E]=" "
  JR Z,NUMIMK       ;USE FIN TO SCAN IT
  LD B,$00
  CALL QTSTR_0		; Eval '0' quoted string
  POP HL            ;GET BACK [H,L]
  RET               ;DO ASSIGNMENT
  
NUMIMK:
  RST GETYPR 		;;GET TYPE OF NUMERIC VARIABLE BEING READ
  PUSH AF            ;SAVE IT
  RST CHRGTB		;;READ FIRST CHARACTER
  POP AF             ;RESTORE TYPE OF VARIABLE
  PUSH AF            ;SAVE BACK
  CALL C,FIN_DBL     ;SINGLE PRECISION INPUT
  POP AF             ;GET BACK TYPE OF VAR
  CALL NC,FIN_DBL    ;DOUBLE PRECISION INPUT
  POP HL             ;GET [H,L]
  RET                ;DO THE ASSIGNMENT

; Routine at 28257
STRCHR:
  OR A              ;TRYING TO STORE NULL BYTE
  RET Z             ;RETURN, DONT STORE IT
  LD (HL),A         ;STORE THE CHARACTER
  INC HL
  DEC B             ;128 YET?
  RET NZ            ;MORE SPACE IN BUFFER, RETURN
  POP AF            ;GET RID OF SUPERFLUOUS STACK ENTRY
  JP QUIT2B         ;SPECIAL QUIT

; Routine at 28267
;
; Used by the routines at L55F8, NAMSCN, __SAVE, L6BD4, GET, __BSAVE, BLOAD_1,
; L71AB, L71D9 and GET_DEVNO.
NM_ERR:
  LD E,$38 ; DERNMF - Bad file name

  DEFB $01	; "LD BC,nn" to jump over the next word without executing it
AO_ERR:
  LD E,$36 ; DERFAO - File already open, on Spectravideo it was called DERFAD
  
  DEFB $01	; "LD BC,nn" to jump over the next word without executing it
DS_ERR:
  LD E,$39 ; DERFDR - Direct statement in a file

  DEFB $01	; "LD BC,nn" to jump over the next word without executing it
FF_ERR:
  LD E,$35 ; DERFNF - File not found

  DEFB $01	; "LD BC,nn" to jump over the next word without executing it
CF_ERR:
  LD E,$3B ; DERFNO - File not OPEN

  DEFB $01	; "LD BC,nn" to jump over the next word without executing it
FO_ERR:
  LD E,$32 ; DERFOV - FIELD overflow

  DEFB $01	; "LD BC,nn" to jump over the next word without executing it
BN_ERR:
  LD E,$34 ; DERBFN - Bad file number

  DEFB $01	; "LD BC,nn" to jump over the next word without executing it
IE_ERR:
  LD E,$33 ; DERIER - Internal error

  DEFB $01	; "LD BC,nn" to jump over the next word without executing it
EF_ERR:
  LD E,$37 ; DERRPE - Input past end

  DEFB $01	; "LD BC,nn" to jump over the next word without executing it
DERSAP:
  LD E,$3A ; - Sequential I/O Only

  XOR A
  LD (NLONLY),A
  LD (FLBMEM),A
  JP ERROR			; Error $00


; Routine at 28306
__BSAVE:
  CALL NAMSCN
  PUSH DE
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
  CALL BSAVE_PARM
  EX DE,HL
  LD (SAVENT),HL
  EX DE,HL
  PUSH DE
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
  CALL BSAVE_PARM
  EX DE,HL
  LD (SAVEND),HL
  EX DE,HL
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JR Z,__BSAVE_0
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
  CALL BSAVE_PARM
  EX DE,HL
  LD (SAVENT),HL
  EX DE,HL
__BSAVE_0:
  POP BC
  POP DE
  PUSH HL
  PUSH BC
  LD A,D
  CP $FF
  JP Z,DO_BSAVE
  JP NM_ERR					; Err $38 -  'Bad file name'

; Data block at 28358
; $6EC6
__BLOAD:
  CALL NAMSCN
  PUSH DE
  XOR A
  LD  (RUNBNF),A	; Reset "Run Binary File After loading" flag (see below)
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  LD  BC,$0000
  JR  Z,BLOAD_1
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
  CP  'R'
  JR  NZ,BLOAD_0
  LD  (RUNBNF),A	; Run Binary File After loading ( Bload"File.Bin",R ) 0 = Don't Run / 1 = Run
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JR  Z,BLOAD_1
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
BLOAD_0:
  CALL BSAVE_PARM
  LD  B,D
  LD  C,E
BLOAD_1:
  POP DE
  PUSH HL
  PUSH BC
  LD A,D
  CP $FF
  JP Z,TAPE_LOAD		; load data from tape (incl. header)
  JP NM_ERR					; Err $38 -  'Bad file name'

; Routine at 28404
;
; Used by the routine at TAPE_LOAD.
TAPE_LOAD_END:
  LD A,(RUNBNF)			; Run Binary File After loading ( Bload"File.Bin",R ) 0 = Don't Run / 1 = Run
  OR A
  JR Z,SPSVEX
  XOR A
  CALL CLSFIL
  LD HL,POPHLRT2      ;   POP HL / RET
  PUSH HL
  LD HL,(SAVENT)
  JP (HL)

; Named SPSVEX only to suggest a retro compatibility with the SVI318
SPSVEX:
  POP HL
  XOR A
  JP CLSFIL

; Routine at 28427
;
; Used by the routine at __BSAVE.
BSAVE_PARM:
  CALL EVAL
  PUSH HL
  CALL GETWORD_HL
  POP DE
  EX DE,HL
  RET

; Data block at 28437
; --- START PROC PAR_DNAME ---
;
; Parse Device Name
PAR_DNAME:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HPARD		; Hook 1 for "Parse device name" event
ENDIF
  LD A,(HL)
  CP ':'
  JR C,POSDSK
  PUSH HL
  LD D,E
  LD A,(HL)
  INC  HL
  DEC  E
  JR Z,L6F2E
L6F24:
  CP ':'
  JR Z,GET_DEVNAME
  LD A,(HL)
  INC  HL
  DEC  E
  JP P,L6F24
L6F2E:
  LD E,D
  POP  HL
  XOR  A
  LD A,$FF
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HNODE		; Hook 2 for "Parse device name" event
ENDIF
  RET

 
POSDSK:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HPOSD		; Hook 3 for "Parse device name" event
ENDIF
  JP NM_ERR					; Err $38 -  'Bad file name'

GET_DEVNAME:
  LD A,D
  SUB E
  DEC A
  POP BC
  PUSH DE
  PUSH BC
  LD C,A		; dev name length
  LD B,A
  LD DE,DEVICE_TBL
  EX (SP),HL
  PUSH HL
DEVN_LOOP:
  CALL MAKUPL		; Load A with char in 'HL' and make it uppercase
  PUSH BC
  LD B,A
  LD A,(DE)
  INC HL
  INC DE
  CP B
  POP BC
  JR NZ,GET_DEVNAME_2
  DEC C
  JR NZ,DEVN_LOOP
GET_DEVNAME_1:
  LD A,(DE)
  OR A
  JP P,GET_DEVNAME_2
  POP HL
  POP HL
  POP DE
  OR A
  RET
  
GET_DEVNAME_2:
  OR A
  JP M,GET_DEVNAME_1
GET_DEVNAME_3:
  LD A,(DE)
  ADD A,A
  INC DE
  JR NC,GET_DEVNAME_3
  LD C,B
  POP HL
  PUSH HL
  LD A,(DE)
  OR A
  JR NZ,DEVN_LOOP
  JP L55F8			; deal with exceptions/expansions

; Message at 28534
DEVICE_TBL:
  DEFM "CAS"
  DEFB $FF
  DEFM "LPT"
  DEFB $FE
  DEFM "CRT"
  DEFB $FD
  DEFM "GRP"
  DEFB $FC
  DEFB $00

; Table to define Token groups ?
DEVICE_VECT:
  DEFW CAS_CTL
  DEFW LPT_CTL
  DEFW CRT_CTL
  DEFW GRP_CTL

; This entry point is used by the routines at __OPEN, GET, L6C50, L6C78,
; __EOF and L6E35.

; Routine location: $6F8F
GET_DEVICE:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HGEND			; Hook for I/O function dispatcher
ENDIF
  PUSH HL
  PUSH DE
  PUSH AF
  LD DE,$0004
  ADD HL,DE
  LD A,(HL)
  CP $FC		; TK_BKSLASH ?
  JP C,L564A
  LD A,$FF
  SUB (HL)
  ADD A,A
  LD E,A
  LD HL,DEVICE_VECT
  ADD HL,DE
  LD E,(HL)
  INC HL
  LD D,(HL)
  POP AF
  LD L,A
  LD H,$00
  ADD HL,DE
  LD E,(HL)
  INC HL
  LD D,(HL)
  EX DE,HL
  POP DE
  EX (SP),HL
  RET

; Routine at 28599
__CSAVE:
  CALL FNAME_ARG
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JR Z,__CSAVE_0
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
  CALL SET_BAUDRATE
__CSAVE_0:
  PUSH HL
  LD A,$D3			; BASIC PROGRAM header mode (TK_NAME)
  CALL CSAVE_HEADER
  LD HL,(VARTAB)
  LD (SAVEND),HL
  LD HL,(TXTTAB)
  CALL __CSAVE_1
  POP HL
  RET

; Routine at 28631
;
; Used by the routine at __BSAVE.
DO_BSAVE:
  LD A,$D0          ; MACHINE CODE header mode   (TK_BSAVE)
  CALL CSAVE_HEADER
  XOR A
  CALL CWRTON		; start tape for writing
  POP HL
  PUSH HL
  CALL BSAVE_HL			; send word to tape
  LD HL,(SAVEND)
  PUSH HL
  CALL BSAVE_HL			; send word to tape
  LD HL,(SAVENT)
  CALL BSAVE_HL			; send word to tape
  POP DE
  POP HL
DO_BSAVE_0:
  LD A,(HL)
  CALL CASOUT		; send byte to tape
  RST DCOMPR		; Compare HL with DE.
  JR NC,DO_BSAVE_1
  INC HL
  JR DO_BSAVE_0

DO_BSAVE_1:
  CALL TAPOOF
  POP HL
  RET

; Routine at 28675
;
; Used by the routine at DO_BSAVE.
; send word to tape
BSAVE_HL:
  LD A,L
  CALL CASOUT		; send byte to tape
  LD A,H
  JP CASOUT		; send byte to tape

; Routine at 28683
;
; Used by the routine at TAPE_LOAD.
; get word from tape
BLOAD_HL:
  CALL _CASIN                   ; get byte from tape
  LD L,A
  CALL _CASIN                   ; get byte from tape
  LD H,A
  RET

; Routine at 28692
;
; Used by the routine at BLOAD_1.
; load data from tape (incl. header)
TAPE_LOAD:
  LD C,$D0                        ; MACHINE CODE header mode   (TK_BSAVE)
  CALL CLOAD_HEADER
  CALL _CSROON                    ; start tape for reading
  POP BC
  CALL BLOAD_HL                   ; get word from tape
  ADD HL,BC
  EX DE,HL
  CALL BLOAD_HL                   ; get word from tape
  ADD HL,BC
  PUSH HL
  CALL BLOAD_HL                   ; get word from tape
  LD (SAVENT),HL
  EX DE,HL
  POP DE
TAPE_LOAD_0:
  CALL _CASIN                   ; get byte from tape
  LD (HL),A
  RST DCOMPR		; Compare HL with DE.
  JR Z,TAPE_LOAD_1
  INC HL
  JR TAPE_LOAD_0

TAPE_LOAD_1:
  CALL TAPIOF
  JP TAPE_LOAD_END

; Routine at 28735
__CLOAD:
  SUB $91		 ; TK_PRINT  (Check if a "CLOAD?" command was issued, to just VERIFY the file )
  JR Z,_VERIFY
  XOR A
  DEFB $01	; "LD BC,nn" to jump over the next word without executing it
_VERIFY:
  CPL
  INC HL
  
  CP $01
  PUSH AF
  CALL CLOAD_FNAME_ARG
  LD C,$D3					; BASIC PROGRAM header mode (TK_NAME)
  CALL CLOAD_HEADER
  
  POP AF
  LD (FACLOW),A
  CALL C,CLRPTR
  LD A,(FACLOW)
  CP $01
  LD (FRCNEW),A
  PUSH AF
  CALL DEPTR
  POP AF
  LD HL,(TXTTAB)
  CALL CLOAD_SUB
  JR NZ,__CLOAD_1
  LD (VARTAB),HL
__CLOAD_OK:
  LD HL,OK_MSG				; "Ok" Message
  CALL PRS
  LD HL,(TXTTAB)
  PUSH HL
  JP FINI

__CLOAD_1:
  INC HL
  EX DE,HL
  LD HL,(VARTAB)
  RST DCOMPR		; Compare HL with DE.
  JP C,__CLOAD_OK
  LD E,$14				; Err $14 - "Verify error"
  JP ERROR

; Data block at 28812
  ; --- START PROC CLOAD_FNAME_ARG ---
CLOAD_FNAME_ARG:
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JR  NZ,FNAME_ARG
  PUSH HL
  LD  HL,FILNAM
  LD  B,$06
  JR  FNAME_ARG_1

  ; --- START PROC FNAME_ARG ---
FNAME_ARG:
  CALL EVAL
  PUSH HL
  CALL __ASC_0
  DEC HL
  DEC HL
  LD  B,(HL)
  LD  C,$06
  LD  HL,FILNAM
FNAME_ARG_0:
  LD  A,(DE)
  LD  (HL),A
  INC HL
  INC DE
  DEC C
  JR  Z,FNAME_ARG_2
  DJNZ FNAME_ARG_0
  LD  B,C
FNAME_ARG_1:
  LD (HL),' '
  INC HL
  DJNZ FNAME_ARG_1
FNAME_ARG_2:
  POP HL
  RET

; Routine at 28856
;
; Used by the routines at TAPE_LOAD, __CLOAD and L71D9.
CLOAD_HEADER:
  CALL _CSROON                   ; start tape for reading
  LD B,10			; we check the leading header marker 10 times

CLOAD_HEADER_0:
  CALL _CASIN         ; get byte from tape
  CP C                ; check type
  JR NZ,CLOAD_HEADER
  DJNZ CLOAD_HEADER_0
  
  LD HL,FILNM2
  PUSH HL
  LD B,$06           ; 6 bytes
CLOAD_HEADER_1:
  CALL _CASIN         ; get byte from tape
  LD (HL),A
  INC HL
  DJNZ CLOAD_HEADER_1
  POP HL

  LD DE,FILNAM
  LD B,$06           ; 6 bytes
CLOAD_HEADER_2:
  LD A,(DE)
  INC DE
  CP ' '
  JR NZ,CMP_FNAME
  DJNZ CLOAD_HEADER_2
  JR FILE_FOUND
  
CMP_FNAME:
  LD DE,FILNAM
  LD B,$06           ; 6 bytes
CMP_FNAME_LOOP:
  LD A,(DE)
  CP (HL)
  JR NZ,SKIP_CAS_FILE
  INC HL
  INC DE
  DJNZ CMP_FNAME_LOOP
  
FILE_FOUND:
  LD HL,FOUND_MSG
  JP PRINT_FNAME_MSG
  
SKIP_CAS_FILE:
  PUSH BC
  LD HL,SKIP_MSG
  CALL PRINT_FNAME_MSG
  POP BC
  JR CLOAD_HEADER

; Message at 28927
FOUND_MSG:
  DEFM "Found:"
  DEFB $00
  
SKIP_MSG:
  DEFM "Skip :"
  DEFB $00

PRINT_FNAME_MSG:
  LD DE,(CURLIN)		 ; Line number the Basic interpreter is working on, in direct mode it will be filled with #FFFF
  INC DE
  LD A,D
  OR E
  RET NZ				; Avoid printing messages if CLOAD was issued from within a running program
  CALL PRS
  LD HL,FILNM2
  LD B,$06
PRNAME_LOOP:
  LD A,(HL)
  INC HL
  RST OUTDO  		; Output char to the current device
  DJNZ PRNAME_LOOP
  JP OUTDO_CRLF

; Routine at 28965
;
; Used by the routines at __CSAVE, DO_BSAVE and L71D9.
CSAVE_HEADER:
  CALL CWRTON		; start tape for writing
  LD B,10			; we write the leading header marker 10 times
CSAVE_HEADER_0:
  CALL CASOUT		; send byte to tape
  DJNZ CSAVE_HEADER_0
  LD B,$06
  LD HL,FILNAM
CSAVE_HEADER_1:
  LD A,(HL)
  INC HL
  CALL CASOUT		; send byte to tape
  DJNZ CSAVE_HEADER_1
  JP TAPOOF

; Routine at 28990
;
; Used by the routine at __CSAVE.
__CSAVE_1:
  PUSH HL
  CALL DEPTR
  XOR A
  CALL CWRTON		; start tape for writing
  POP DE
  LD HL,(SAVEND)
__CSAVE_1_0:
  LD A,(DE)
  INC DE
  CALL CASOUT		; send byte to tape
  RST DCOMPR		; Compare HL with DE.
  JR NZ,__CSAVE_1_0
  LD L,$07
__CSAVE_1_1:
  CALL CASOUT		; send byte to tape
  DEC L
  JR NZ,__CSAVE_1_1
  JP TAPOOF

; Routine at 29021
;
; Used by the routine at __CLOAD.
CLOAD_SUB:
  CALL _CSROON                   ; start tape for reading
  SBC A,A
  CPL
  LD D,A
CLOAD_SUB_0:
  LD B,$0A       ; 10 bytes
CLOAD_SUB_1:
  CALL _CASIN     ; get byte from tape
  LD E,A
  CALL ENFMEM   ; $6267 = ENFMEM (reference not aligned to instruction)
  LD A,E
  SUB (HL)
  AND D
  JP NZ,TAPIOF
  LD (HL),E
  LD A,(HL)
  OR A
  INC HL
  JR NZ,CLOAD_SUB_0
  DJNZ CLOAD_SUB_1
  
  LD BC,$FFFA		; -6
  ADD HL,BC
  XOR A
  JP TAPIOF


; Data block at 29058
; GRP: Device Control Table/Driver
; $7182
GRP_CTL:
  DEFW DEVICE_OPEN
  DEFW DO_NOTHING		; CLOSE operation
  DEFW DERSAP			; "Sequential I/O access only" error
  DEFW GRP_OUTPUT

  DEFW FC_ERR		; INPUT operation
  DEFW FC_ERR
  DEFW FC_ERR
  DEFW FC_ERR		; EOF operation
  DEFW FC_ERR
  DEFW FC_ERR		; UNGETC operation

GRP_OUTPUT:
  LD A,(SCRMOD)
  CP $02
  JP C,FC_ERR
  LD A,C
; Routine at 29087
L719F:
  JP GRPPRT

  
  
; Routine at 29090
; CRT: Device Control Table/Driver
; $71A2
CRT_CTL:
  DEFW DEVICE_OPEN
  DEFW DO_NOTHING		; CLOSE operation
  DEFW DERSAP           ; "Sequential I/O access only" error
  DEFW CRT_OUTPUT
  
  DEFW FC_ERR		; INPUT operation
  DEFW FC_ERR
  DEFW FC_ERR
  DEFW FC_ERR		; EOF operation
  DEFW FC_ERR
  DEFW FC_ERR		; UNGETC operation
  
DEVICE_OPEN:
  CALL GET_DEVNO	; Get device number
  CP $01
  JP Z,NM_ERR					; Err $38 -  'Bad file name'
; This entry point is used by the routine at L71D9.
REDIRECT_IO:
  LD (PTRFIL),HL
  LD (HL),E
DO_NOTHING:
  RET

; Routine at 29123
CRT_OUTPUT:
  LD A,C
  JP CHPUT

; Data block at 29127
; CAS: Device Control Table/Driver
;$71C7
CAS_CTL:
  DEFW CAS_OPEN
  DEFW CAS_CLOSE
  DEFW DERSAP            ; "Sequential I/O access only" error
  DEFW CAS_OUTPUT
  
  DEFW CAS_INPUT
  DEFW FC_ERR
  DEFW FC_ERR
  DEFW CAS_EOF
  DEFW FC_ERR
  DEFW CAS_UNGETC


CAS_OPEN:
  PUSH HL
  PUSH DE
  LD BC,$0006
  ADD HL,BC					; char count
  XOR A
  LD (HL),A
  LD (CASPRV),A				; clear char for UNGETC
  CALL GET_DEVNO
  CP $04
  JP Z,NM_ERR				; Err $38 -  'Bad file name'

  CP $01
  JR Z,CAS_OPEN_RD

  LD A,$EA					; ASCII FILE header mode (TK_DSKI$)
  CALL CSAVE_HEADER

CAS_OPEN_END:
  POP DE
  POP HL
  JR REDIRECT_IO

CAS_OPEN_RD:
  LD C,$EA					; ASCII FILE header mode (TK_DSKI$)
  CALL CLOAD_HEADER
  CALL TAPIOF
  JR CAS_OPEN_END

  
; Routine at 29189
CAS_CLOSE:
  LD A,(HL)
  CP $01
  JR Z,CAS_CLOSE_1
  LD A,$1A		; EOF
  PUSH HL
  CALL INIT_DEV_OUTPUT
  CALL Z,CAS_OUTPUT_0
  POP HL
  CALL CLOSE_DEVICE
  JR Z,CAS_CLOSE_1
  PUSH HL
  ADD HL,BC
CAS_CLOSE_0:
  LD (HL),$1A		; EOF
  INC HL
  INC C
  JR NZ,CAS_CLOSE_0
  POP HL
  CALL CAS_OUTPUT_0
CAS_CLOSE_1:
  XOR A
  LD (CASPRV),A
  RET

; Routine at 29226
CAS_OUTPUT:
  LD A,C
  CALL INIT_DEV_OUTPUT
  RET NZ
; This entry point is used by the routine at CAS_CLOSE.
CAS_OUTPUT_0:
  XOR A
  CALL CWRTON		; start tape for writing
  LD B,$00
CAS_OUTPUT_1:
  LD A,(HL)
  CALL CASOUT		; send byte to tape
  INC HL
  DJNZ CAS_OUTPUT_1
  JP TAPOOF

; Routine at 29247
;
; Used by the routine at CAS_EOF.
CAS_INPUT:
  EX DE,HL
  LD HL,CASPRV
  CALL GET_BYTE
  EX DE,HL
  CALL INIT_INPUT
  JR NZ,CAS_INPUT_1
  PUSH HL
  CALL _CSROON                   ; start tape for reading
  POP HL
  LD B,$00
CAS_INPUT_0:
  CALL _CASIN                   ; get byte from tape
  LD (HL),A
  INC HL
  DJNZ CAS_INPUT_0
  CALL TAPIOF
  DEC H
  XOR A
  LD B,A
CAS_INPUT_1:
  LD C,A
  ADD HL,BC
  LD A,(HL)
  CP $1A		; EOF
  SCF
  CCF
  RET NZ
  LD (CASPRV),A
  SCF
  RET

; Routine at 29293
CAS_EOF:
  CALL CAS_INPUT
  LD HL,CASPRV
  LD (HL),A
  SUB $1A		; EOF
  SUB $01
  SBC A,A
  JP CONIA      ;CONVERT [A] TO AN INTEGER SIGNED

; Routine at 29308
CAS_UNGETC:
  LD HL,CASPRV
  LD (HL),C
  RET

; Routine at 29313
;
; Used by the routine at CAS_CLOSE.
CLOSE_DEVICE:
  LD BC,$0006
  ADD HL,BC					; char count
  LD A,(HL)
  LD C,A
  LD (HL),$00
  JR DEVICE_RET

; Routine at 29323
;
; Used by the routines at CAS_CLOSE and CAS_OUTPUT.
INIT_DEV_OUTPUT:
  LD E,A
  LD BC,$0006
  ADD HL,BC					; char count
  LD A,(HL)
  INC (HL)
  INC HL
  INC HL
  INC HL
  PUSH HL
  LD C,A
  ADD HL,BC
  LD (HL),E
  POP HL
  RET

; Routine at 29339
;
; Used by the routine at CAS_INPUT.
INIT_INPUT:
  LD BC,$0006
  ADD HL,BC					; char count
  LD A,(HL)
  INC (HL)
; This entry point is used by the routine at CLOSE_DEVICE.
DEVICE_RET:
  INC HL
  INC HL
  INC HL
  AND A
  RET

; Data block at 29350
; LPT: Device Control Table/Driver
; $72A6
LPT_CTL:
  DEFW DEVICE_OPEN
  DEFW DO_NOTHING		; CLOSE operation
  DEFW DERSAP           ; "Sequential I/O access only" error
  DEFW LPT_OUTPUT
 
  DEFW FC_ERR		; INPUT operation
  DEFW FC_ERR
  DEFW FC_ERR
  DEFW FC_ERR		; EOF operation
  DEFW FC_ERR
  DEFW FC_ERR		; UNGETC operation

LPT_OUTPUT:
  LD A,C
  JP OUTDLP


; Routine at 29374
;
; Used by the routine at CAS_INPUT.
GET_BYTE:
  LD A,(HL)
  LD (HL),$00
  AND A
  RET Z
  INC SP
  INC SP
  CP $1A		; EOF
  SCF
  CCF
  RET NZ
  LD (HL),A
  SCF
  RET

; Routine at 29389
;
; Used by the routines at L71AB and L71D9.
; Copy the current device/stream/channel number to A
GET_DEVNO:
  LD A,E
  CP $08
  JP Z,NM_ERR		; Err $38 -  'Bad file name'
  RET

; Routine at 29396
;
; Used by the routines at BLOAD_HL, TAPE_LOAD, CLOAD_HEADER, CLOAD_SUB and CAS_INPUT.
; get byte from tape
_CASIN:
  PUSH HL
  PUSH DE
  PUSH BC
  CALL TAPIN	; Get byte from cassette
  JR NC,POPALL_0
  JR DIOERR

; Routine at 29406
;
; Used by the routines at DO_BSAVE, BSAVE_HL, CSAVE_HEADER, __CSAVE_1 and CAS_OUTPUT.
; send byte to tape
CASOUT:
  PUSH HL
  PUSH DE
  PUSH BC
  PUSH AF
  CALL TAPOUT
  JR NC,POPALL
  JR DIOERR

; Routine at 29417
;
; Used by the routines at TAPE_LOAD, CLOAD_HEADER, CLOAD_SUB and CAS_INPUT.
; start tape for reading  (Cassette motor on and wait for Sync and Header)
_CSROON:
  PUSH HL
  PUSH DE
  PUSH BC
  PUSH AF
  CALL TAPION
  JR NC,POPALL
; This entry point is used by the routines at _CASIN and CASOUT.
DIOERR:
  CALL TAPIOF
  JP IO_ERR

; Routine at 29432
;
; Used by the routines at DO_BSAVE, CSAVE_HEADER, __CSAVE_1 and CAS_OUTPUT.
; start tape for writing
CWRTON:
  PUSH HL
  PUSH DE
  PUSH BC
  PUSH AF
  CALL TAPOON
; This entry point is used by the routines at L6C50, CASOUT and _CSROON.
POPALL:
  POP AF
; This entry point is used by the routines at L6C78 and _CASIN.
POPALL_0:
  POP BC
  POP DE
  POP HL
  RET

; Routine at 29444
;
; Used by the routines at L628E and __END.
FINLPT:
  XOR A                   ;RESET PRINT FLAG SO
  LD (PRTFLG),A           ;OUTPUT GOES TO TERMINAL
  LD A,(LPTPOS)           ;GET CURRENT LPT POSIT
  OR A                    ;ON LEFT HAND MARGIN ALREADY?
  RET Z                   ;YES, RETURN

  LD A,CR                 ;PUT OUT CRLF
  CALL LPTCHR
  LD A,LF
  CALL LPTCHR
  XOR A
  LD (LPTPOS),A           ;ZERO LPTPOS
  RET                     ;DONE

; Routine at 29468
;
; Used by the routine at FINLPT.
LPTCHR:
  CALL LPTOUT
  RET NC
  JP IO_ERR

; Routine at 29475
;
; Used by the routines at LINE2PTR and __END.
CONSOLE_CRLF:
  LD A,(TTYPOS)      ;GET CURRENT TTYPOS
  OR A               ;SET CC'S
  RET Z              ;IF ALREADY ZERO, RETURN
  
; This entry point is used by the routines at L4A5A, __LLIST, L61C4, L710B and __KEY.
; a.k.a. CRDO
OUTDO_CRLF:

IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HCRDO		; Hook for "CRLF to OUTDO" events
ENDIF

  LD A,CR           ; CR
  RST OUTDO  		; Output char to the current device
  LD A,LF           ; LF
  RST OUTDO  		; Output char to the current device

; This entry point is used by the routines at L4A5A, PRS1 and OUTCH1.
;DON'T PUT CR/LF OUT TO LOAD FILE
CRFIN:
  CALL ISFLIO		;SEE IF OUTPUTTING TO DISK
  JR Z,CRCONT       ;NOT DISK FILE, CONTINUE
  XOR A             ;CRFIN MUST ALWAYS RETURN WITH A=0
  RET               ;AND CARRY=0.

CRCONT:
  LD A,(PRTFLG)		;GOING TO PRINTER?
  OR A              ;TEST
  JR Z,NTPRTR       ;NO
  XOR A             ;DONE, RETURN
  LD (LPTPOS),A		;ZERO POSITON
  RET

NTPRTR:
  LD (TTYPOS),A		; Set to position 0       ;SET TTYPOS=0
  RET               ; Store it

; Routine at 29511
;
; Used by the routine at OPRND.
FN_INKEY:
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  PUSH HL               ;SAVE THE TEXT POINTER
  CALL CHSNS            ;SET NON-ZERO IF CHAR THERE
  JR Z,NULRT            ;NO, RETURN NULL STRING
  CALL CHGET
  PUSH AF
  CALL STRIN1           ;MAKE ONE CHAR STRING
  POP AF
  LD E,A                ;CHAR TO [D]
  CALL SETSTR           ;STUFF IN DESCRIPTOR AND GOTO PUTNEW

NULRT:
  LD HL,NULL_STRING
  LD (FACLOW),HL
  LD A,$03			; String
  LD (VALTYP),A
  POP HL
  RET

; Routine at 29543
;
; Used by the routine at LISPRT.
OUTCH1:
  RST OUTDO            ;OUTPUT THE CHAR
  CP LF                ;WAS IT A LF?
  RET NZ               ;NO, RETURN
  LD A,CR              ;DO CR
  RST OUTDO
  CALL CRFIN
  LD A,LF              ;RESTORE CHAR (LF)
  RET


; A.K.A. TTYLIN
; Accepts a line from a file or device
;
PINSTREAM:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HDSKC  		; ($FEEE) Hook for  Mainloop line input
ENDIF
  LD B,$FF
  LD HL,BUF
L737C:
  CALL RDBYT
  JR C,EOF_REACHED
  LD (HL),A
  CP CR
  JR Z,NEXT_LINE
  CP $09		; TAB
  JR Z,L7380_0
  CP LF
  JR Z,L737C
L7380_0:
  INC HL
  DJNZ L737C
NEXT_LINE:
  XOR A
  LD (HL),A
  LD HL,BUFMIN
  RET
  
EOF_REACHED:
  INC B
  JR NZ,NEXT_LINE
  LD A,(NLONLY)
  AND $80
  LD (NLONLY),A
  CALL CLOSE_STREAM
  LD A,(FILNAM)
  AND A
  JP Z,RESTART
  CALL RUN_FST
  JP NEWSTT

; Routine at 29618
;
; Used by the routines at _CSROON and LPTCHR.
IO_ERR:
  LD E,$13				; Err $13 - "Device I/O error"
  JP ERROR

; Routine at 29623
__MOTOR:
  LD E,$FF
  JR Z,__MOTOR_0
  SUB TK_OFF
  LD E,A
  JR Z,L73C4+1
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB TK_ON
  LD E,$01
L73C4:
	; L73C4+1:   RST CHRGTB		; Gets next character (or token) from BASIC text.
  LD A,$D7
__MOTOR_0:
  LD A,E
  JP STMOTR

; Routine at 29642
__SOUND:
  CALL GETINT          ;Get frequency.      ; Get integer 0-255
  CP 14                ; PSG Channel range
  JP NC,FC_ERR         ;Frequency too low
  PUSH AF              ;Save frequency
  RST SYNCHR
  DEFB ','
  CALL GETINT          ;Get duration.
;:::::::::::::::::::::
L73D8:
  POP AF
;:::::::: CODE RELOCATION IS SAFE STARTING FROM HERE ::::::::
  CP $07
  JR NZ,__SOUND_0
  RES 6,E
  SET 7,E
__SOUND_0:
  JP WRTPSG




; Data block at 29668
L73E4:
  DEFB ' '


;
; PLAY - MUSIC MACRO LANGUAGE
;

; Takumi Miyamoto, former employee at ASCII Corporation, tells about a bug in the play statement:
; "Few people seemed to notice it, but there was a bug in BASIC play statements in MSX1-2+.
; It caused an extra space for one count when a play command ended.
; In other words, there was a short pause at the moment of the transition from one play sentence to the next.
; The tempo shifts for a moment, but many of you may not have noticed it."

__PLAY:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HPLAY  		; Hook for 'PLAY'
ENDIF

  PUSH HL
  LD HL,PLAY_TAB
  LD (MCLTAB),HL
  LD A,$00
  LD (PRSCNT),A		; Used by PLAY command in BASIC	
  LD HL,$FFF6		; -10
  ADD HL,SP
  LD (SAVSP),HL		; Used by PLAY command in BASIC
  POP HL
  PUSH AF
__PLAY_0:
  CALL EVAL
  EX (SP),HL
  PUSH HL
  CALL GETSTR
  CALL LOADFP
  LD A,E
  OR A
  JR NZ,__PLAY_1
  
  LD E,$01
  LD BC,L73E4		; points to ' '.. empty play queue
  LD D,C
  LD C,B

; Routine at 29715
__PLAY_1:
  POP AF
  PUSH AF
  CALL GETVCP	; Returns pointer to play queue
  LD (HL),E		; = 1
  INC HL
  LD (HL),D
  INC HL
  LD (HL),C
  INC HL
  LD D,H
  LD E,L
  LD BC,$001C		; 28
  ADD HL,BC
  EX DE,HL
  LD (HL),E
  INC HL
  LD (HL),D
  POP BC
  POP HL
  INC B
  LD A,B
  CP $03			; TK_MID_S ?
  JR NC,__PLAY_3
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JR Z,__PLAY_2
  PUSH BC
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
  JR __PLAY_0

; Routine at 29753
__PLAY_2:
  LD  A,B
  LD  (VOICEN),A
  CALL DOSND_SUB
  INC B
  LD A,B
  CP $03
  JR C,__PLAY_2
; This entry point is used by the routine at __PLAY_1.
__PLAY_3:
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JP NZ,SN_ERR
  PUSH HL
; This entry point is used by the routine at MCLPLAY.
__PLAY_4:
  XOR A
; This entry point is used by the routine at MCLPLAY.
__PLAY_5:
  PUSH AF
  LD (VOICEN),A
  LD B,A
  CALL L7521
  JP C,MCLPLAY_3
  LD A,B
  CALL GETVCP	; Returns pointer to play queue
  LD A,(HL)
  OR A
  JP Z,MCLPLAY_3
  LD (MCLLEN),A
  INC HL
  LD E,(HL)
  INC HL
  LD D,(HL)
  INC HL
  LD (MCLPTR),DE
  LD E,(HL)
  INC HL
  LD D,(HL)
  INC HL
  PUSH HL
  LD L,$24
  CALL GETVC2
  PUSH HL
  LD HL,(SAVSP)
  DEC HL
  POP BC
  DI
  CALL MOVUP_0
  POP DE
  LD H,B
  LD L,C
  LD SP,HL
  EI
  LD A,$FF
  LD (MCLFLG),A
  JP MCLSCN

; Routine at 29838
;
; Used by the routine at DOSND.
MCLPLAY:
  LD A,(MCLLEN)     ;POINT TO STRING LENGTH
  OR A
  JR NZ,MCLPLAY_1
; This entry point is used by the routine at L5683.
MCLPLAY_0:
  CALL DOSND_SUB
MCLPLAY_1:
  LD A,(VOICEN)
  CALL GETVCP
  LD A,(MCLLEN)     ;Get str len
  LD (HL),A
  INC HL
  LD DE,(MCLPTR)
  LD (HL),E
  INC HL
  LD (HL),D
  LD HL,$0000
  ADD HL,SP
  EX DE,HL
  LD HL,(SAVSP)
  DI
  LD SP,HL
  POP BC
  POP BC
  POP BC
  PUSH HL
  OR A
  SBC HL,DE
  JR Z,MCLPLAY_2
  LD A,$F0
  AND L
  OR H
  JP NZ,FC_ERR
  LD L,$24
  CALL GETVC2
  POP BC
  DEC BC
  CALL MOVUP_0
  POP HL
  DEC HL
  LD (HL),B
  DEC HL
  LD (HL),C
  JR MCLPLAY_3
MCLPLAY_2:
  POP BC
  POP BC
; This entry point is used by the routine at __PLAY_2.
MCLPLAY_3:
  EI
  POP AF
  INC A
  CP $03
  JP C,__PLAY_5
  DI
  LD A,(INTFLG)
  CP $03
  JR Z,MCLPLAY_6
  LD A,(PRSCNT)
  RLCA
  JR C,MCLPLAY_4
  LD HL,PLYCNT
  INC (HL)
  CALL STRTMS
MCLPLAY_4:
  EI
  LD HL,PRSCNT
  LD A,(HL)
  OR $80
  LD (HL),A
  CP $83		; TK_NEXT ?
  JP NZ,__PLAY_4
MCLPLAY_5:
  POP HL
  RET

MCLPLAY_6:
  CALL GICINI
  JR MCLPLAY_5

; Routine at 29959
;
; Used by the routines at __PLAY_2 and MCLPLAY.
DOSND_SUB:
  LD A,(PRSCNT)
  INC A
  LD (PRSCNT),A
  LD E,$FF
; This entry point is used by the routine at DOSND.
DOSND_SUB_0:
  PUSH HL
  PUSH BC
DOSND_SUB_1:
  PUSH DE
  LD A,(VOICEN)
  DI
  CALL PUTQ
  EI
  POP DE
  JR Z,DOSND_SUB_1
  POP BC
  POP HL
  RET


; Routine at 29985
;
; Used by the routines at __PLAY_2 and DOSND.
L7521:
  LD A,(VOICEN)
  PUSH BC
  DI
  CALL LFTQ			; Gives number of bytes left in queue
  EI
  POP BC
  CP $08
  RET


; Data table at 29998
;$5D83
PLAY_TAB:
  DEFB 'A'           ;THE NOTES A-G
  DEFW PLAY_NOTE
  
  DEFB 'B' 
  DEFW PLAY_NOTE
  
  DEFB 'C' 
  DEFW PLAY_NOTE
  
  DEFB 'D' 
  DEFW PLAY_NOTE
  
  DEFB 'E' 
  DEFW PLAY_NOTE
  
  DEFB 'F' 
  DEFW PLAY_NOTE
  
  DEFB 'G' 
  DEFW PLAY_NOTE

  DEFB 'M'+$80          ;Music Meta Command
  DEFW PLYMET           ; Envelope cycle setting *2 (1..65535)

  DEFB 'V'+$80
  DEFW VOLUME			; Volume (0..15)
  
  DEFB 'S'+$80
  DEFW ENVELOPE_SHAPE	; Envelope shape *2 (0..15)
  
  DEFB 'N'+$80          ;PLAY NUMERIC NOTE
  DEFW PLYNUM		    ; Plays Note raised to n (0..96)

  DEFB 'O'+$80          ;OCTAVE
  DEFW POCTAV			; Octave (1..8)
  
  DEFB 'R'+$80          ; GW-BASIC has 'P' for 'Pause'
  DEFW REST				; Rest setting (1..64)

  DEFB 'T'+$80          ;TEMPO
  DEFW TEMPO			; Tempo setting (32..255)

  DEFB 'L'+$80          ;LENGTH
  DEFW LENGTH			; Length (1..64)

  DEFB 'X'              ;EXECUTE STRING
  DEFW MCLXEQ           ; .. Plays MML string stored in variable A$
  
  DEFB $00              ;END OF TABLE



; TABLE OF INDEXES INTO NOTE_TAB FOR EACH NOTE
; VALUE OF 0 MEANS NOTE NOT ALLOWED.

NOTE_XLT:
  DEFB 8*2       ;A- (G#)
  DEFB 9*2       ;A
  DEFB 10*2      ;A#
  DEFB 11*2      ;B

  DEFB $00       ;NO C- OR B#
  DEFB $00

  DEFB 1*2       ;C
  DEFB 2*2       ;C#
  DEFB 3*2       ;D
  DEFB 4*2       ;D#
  DEFB 5*2       ;E

  DEFB 5*2       ;NO E# OR F-
  
  DEFB 6*2       ;F
  DEFB 7*2       ;F#
  DEFB 8*2       ;G
 
 
; TABLE OF NOTE FREQUENCIES
; IN GW-BASIC THESE WERE THE FREQUENCIES IN HERTZ OF THE TOP OCTAVE (6)
; DIVIDED DOWN BY POWERS OF TWO TO GET ALL OTHER OCTAVES
;

	
NOTE_TAB:
  DEFW  $0D5D    ;C
  DEFW  $0C9C    ;C#
  DEFW  $0BE7    ;D
  DEFW  $0B3C    ;D#
  DEFW  $0A9B    ;E
  DEFW  $0A02    ;F
  DEFW  $0973    ;F#
  DEFW  $08EB    ;G
  DEFW  $086B    ;G#
  DEFW  $07F2    ;A
  DEFW  $0780    ;A#
  DEFW  $0714    ;B

  
  
; Volume (0..15)
VOLUME:
  JR C,SET_VOLUME
  LD E,8		; Default volume: 8
SET_VOLUME:
  LD A,15		; Max volume: 15
  CP E
  JR C,PLGO_FC

SET_ENVELOPE:
  XOR A
  OR D
  JR NZ,PLGO_FC
  LD L,$12
  CALL GETVC2
  LD A,$40
  AND (HL)
  OR E
  LD (HL),A
  RET



; PLYMET - Process Music Meta Commands.
; ..on AY it sets the envelope cycle *2 (1..65535)


; Routine at 30110
; Used by the routine at L752E.
PLYMET:
  LD A,E
  JR C,SET_ENV_CYCLE
  CPL
  INC A
  LD E,A
SET_ENV_CYCLE:
  OR D
  JR Z,PLGO_FC
  LD L,$13
  CALL GETVC2
  PUSH HL
  LD A,(HL)
  INC HL
  LD H,(HL)
  LD L,A
  RST DCOMPR		; Compare HL with DE.
  POP HL
  RET Z
  LD (HL),E
  INC HL
  LD (HL),D
  DEC HL
  DEC HL
  LD A,$40
  OR (HL)
  LD (HL),A
  RET

; Routine at 30142
; Envelope shape *2 (0..15)
ENVELOPE_SHAPE:
  LD A,E
  CP 15+1		; Max envelope shape: 15
  JR NC,PLGO_FC
  OR $10
  LD E,A
  JR SET_ENVELOPE


; Data block at 30152
  ; --- START PROC LENGTH ---
; Length (1..64)
LENGTH:
  JR C,SET_LENGHT      ;JP IF ARGUMENT AVAILABLE
  LD E,4               ; Default Length: 4
SET_LENGHT:
  LD A,E
  CP 64+1              ;ALLOW ONLY UP TO 64
  JR NC,PLGO_FC        ;FC ERROR IF TOO BIG
  LD L,$10             ;STORE NOTE LENGTH

  ; --- START PROC L75D3 ---
SETVC2:
  CALL GETVC2
  XOR  A
  OR D
  JR NZ,PLGO_FC
  OR E
  JR Z,PLGO_FC
  LD (HL),A
  RET

  ; --- START PROC PLGO_FC ---
PLGO_FC:
  CALL FC_ERR
  
  ; --- START PROC TEMPO ---
; Tempo setting (32..255)
TEMPO:
  JR C,SET_TEMPO    ;JP IF ARGUMENT AVAILABLE
  LD E,120          ; Default tempo: 120
SET_TEMPO:
  LD A,E
  CP 32             ;ALLOW ONLY 32 - 255
  JR C,PLGO_FC      ;FC ERROR IF TOO SMALL
  LD L,$11          ;Store Beats per minute
  JR SETVC2

; Routine at 30191
; Octave (1..8)
POCTAV:
  JR C,SET_OCTAVE   ;JP IF ARGUMENT AVAILABLE
  LD E,4            ; Default octave: 4
SET_OCTAVE:
  LD A,E
  CP 8+1            ; Max octave: 8
  JR NC,PLGO_FC     ;FC ERROR IF TO BIG
  LD L,$0F          ;Store octave value
  JR SETVC2
  
; Routine at 30204
;
; Used by the routine at L752E.
; Rest setting (1..64)
REST:
  JR C,SET_REST
  LD E,4		; Default REST value: 4
SET_REST:
  XOR A
  OR D
  JR NZ,PLGO_FC
  OR E
  JR Z,PLGO_FC
  CP 65             ;If was .gt. 64
  JR NC,PLGO_FC     ; then error

; This entry point is used by the routine at PLYNUM.
PLYNO3:
  LD HL,$0000
  PUSH HL
  LD L,$10
  CALL GETVC2
  PUSH HL
  INC HL
  INC HL
  LD A,(HL)
  LD (SAVVOL),A
  LD (HL),$80
  DEC HL
  DEC HL
  JR DOSND_0

; Routine at 30241
PLYNUM:
  JR NC,PLGO_FC     ;ERROR IF NO ARG
  XOR A             ;GET NOTE NUMBER INTO [AL]
  OR D
  JR NZ,PLGO_FC
  OR E              ;SEE IF ZERO (PAUSE)
  JR Z,PLYNO3       ;DO THE PAUSE
  CP 96+1			;ALLOW ONLY 0..96    (Max RAISE value: 96)
  JR NC,PLGO_FC     ;FC ERROR IF TOO BIG
  LD A,E
  LD B,$00
  LD E,B
PLYNUM_0:
  SUB 12            ;DIVIDE BY 12
  INC E             ;OCTAVE counter
  JR NC,PLYNUM_0
  ADD A,12
  ADD A,A           ;NOTE*2..
  LD C,A            ;.. in BC
  JP PLYNU3         ;PLAY NOTE

; Routine at 30270
PLAY_NOTE:
  LD B,C
  LD A,C
  SUB 'A'-1         ;MAP TO 1..7
  ADD A,A           ;MAP TO 2..14 (THIS ASSUMES SHARP)
  LD C,A
  CALL FETCHR       ;GET NEXT CHARACTER
  JR Z,PLYNO2       ;END OF STRING - NO SHARP OR FLAT
  CP '#'            ;CHECK FOR POSSIBLE SHARP
  JR Z,PLYSHARP     ;SHARP IT THEN
  CP '+'            ;"+" ALSO MEANS SHARP
  JR Z,PLYSHARP
  CP '-'            ;"-" MEANS FLAT
  JR Z,PLYFLAT
  CALL DECFET       ;PUT CHAR BACK IN STRING.
  JR PLYNO2         ;TREAT AS UNMODIFIED NOTE.

; Flat (Lower half tone)
PLYFLAT:
  DEC C             ;DECREMENT TWICE TO FLAT IT
  LD A,B            ;INTO [AL] FOR XLAT
  CP 'C'
  JR Z,PLAY_NOTE_1  ; 'C flat' does not exist, compensate..
  CP 'F'
  JR NZ,PLYNO2      ; 'F flat' does not exist, compensate..
PLAY_NOTE_1:
  DEC C
PLYNO2:
  DEC C             ;MAP BACK TO UNSHARPED
; Sharp (raise half tone) 
PLYSHARP:
  LD L,$0F
  CALL GETVC2
  LD E,(HL)
  LD B,$00
  LD HL,NOTE_XLT    ;POINT TO TRANSLATE TABLE
  ADD HL,BC
  LD C,(HL)


; Play note.  BC = ptr to the freq. table,  E=octave
; This entry point is used by the routine at PLYNUM.
PLYNU3:
  LD HL,NOTE_TAB
  ADD HL,BC
  LD A,E             ; A = OCTAVE
  LD E,(HL)
  INC HL
  LD D,(HL)
PLYNU3_0:
  DEC A              ; OCTAVE properly set ?
  JR Z,DOSND         ; ok, go for sound
  SRL D
  RR E
  JR PLYNU3_0        ; OCTAVE shifting

; Routine at 30340
SNDFCE:
  CALL FC_ERR        ; Complain
  
; This entry point is used by the routine at PLAY_NOTE.
DOSND:
  ADC A,E
  LD E,A
  ADC A,D
  SUB E
  LD D,A
  PUSH DE
  LD L,$10
  CALL GETVC2
  LD C,(HL)
  PUSH HL
  CALL FETCHR
  JR Z,PLYNU4        ;Brif end of string
  CALL VALSC2        ;See if possible number

; This entry point is used by the routine at REST.
DOSND_0:
  LD A,64            ;If was .gt. 64
  CP E
  JR C,SNDFCE        ; then error
  XOR A
  OR D
  JR NZ,SNDFCE
  OR E               ;Any Length?
  JR Z,PLYNU4        ;Brif not, just do note
  LD C,E
PLYNU4:
  POP HL
  LD D,$00
  LD B,D
  INC HL
  LD E,(HL)
  PUSH HL
  CALL MLDEBC
  EX DE,HL
  CALL HL_CSNG
  CALL VMOVAF
  LD HL,FP_SNDCONST		; Single precision float const: 12000, (calibrate to 1 second units)
  CALL MOVFM
  CALL DDIV
  CALL __CINT
  LD D,H
  LD E,L
PLYDOT:
  CALL FETCHR
  JR Z,PLYDOX          ;Brif EOS
  CP '.'               ;Note duration extender?
  JR NZ,PLYDO2         ;Brif not
  SRL D                ;Duration = Duration * 1.5
  RR E                 ;Ovf/2
  ADC HL,DE
  LD A,$E0
  AND H                ;Still too big?
  JR Z,PLYDOT          ;Itterate if not
  XOR H
  LD H,A
  JR PLYDOX
PLYDO2:
  CALL DECFET          ;Put char back	
PLYDOX:
  LD DE,$0005
  RST DCOMPR		; Compare HL with DE.
  JR C,DOSND_1
  EX DE,HL
DOSND_1:
  LD BC,$FFF7		; -9
  POP HL
  PUSH HL
  ADD HL,BC
  LD (HL),D
  INC HL
  LD (HL),E
  INC HL
  LD C,$02
  EX (SP),HL
  INC HL
  LD E,(HL)
  LD A,E
  AND $BF
  LD (HL),A
  EX (SP),HL
  LD A,$80
  OR E
  LD (HL),A
  INC HL
  INC C
  EX (SP),HL
  LD A,E
  AND $40
  JR Z,DOSND_2
  INC HL
  LD E,(HL)
  INC HL
  LD D,(HL)
  POP HL
  LD (HL),D
  INC HL
  LD (HL),E
  INC HL
  INC C
  INC C

  DEFB $FE                  ; 'CP $E1'  masking 'POP HL'
  
DOSND_2:
  POP HL
  POP DE
  LD A,D
  OR E
  JR Z,DOSND_3
  LD (HL),D
  INC HL
  LD (HL),E
  INC C
  INC C
DOSND_3:
  LD L,$07
  CALL GETVC2
  LD (HL),C
  LD A,C
  SUB $02
  RRCA
  RRCA
  RRCA
  INC HL
  OR (HL)
  LD (HL),A
  DEC HL
  LD A,D
  OR E
  JR NZ,DOSND_4
  PUSH HL
  LD A,(SAVVOL)
  OR $80
  LD BC,$000B
  ADD HL,BC
  LD (HL),A
  POP HL
DOSND_4:
  POP DE
  LD B,(HL)
  INC HL
DOSND_5:
  LD E,(HL)
  INC HL
  CALL DOSND_SUB_0
  DJNZ DOSND_5
  CALL L7521
  JP C,MCLPLAY
  JP MCLSCN

; Pointed by routine at DOSND
; numeric float const
FP_SNDCONST:
  DEFB $00
  DEFB $00
  DEFB $45
  DEFB $12


__PUT:
  LD B,$80
  DEFB 17	; "LD DE,nn" to jump over the next word without executing it

__GET:
  LD B,$00
  CP TK_SPRITE
  JP Z,PUT_SPRITE
  LD A,B
  JP GET

; Routine at 30566
__LOCATE:
  LD DE,(CSRY)
  PUSH DE
  CP ','
  JR Z,__LOCATE_0
  CALL GETINT              ; Get integer 0-255
  INC A
  POP DE
  LD D,A
  PUSH DE
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JR Z,__LOCATE_3
__LOCATE_0:
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
  CP ','
  JR Z,__LOCATE_1
  CALL GETINT              ; Get integer 0-255
  INC A
  POP DE
  LD E,A
  PUSH DE
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JR Z,__LOCATE_3
__LOCATE_1:
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
  CALL GETINT              ; Get integer 0-255
  AND A					; Hide..
  LD A,'y'
  JR NZ,__LOCATE_2
  DEC A					; ..un-hide cursor
__LOCATE_2:
  PUSH AF
  LD A,ESC
  RST OUTDO  		; Output char to the current device
  POP AF			; ESC_y (show/hide cursor)
  RST OUTDO  		; Output char to the current device
  LD A,$35			; '5'
  RST OUTDO  		; Output char to the current device
__LOCATE_3:
  EX (SP),HL
  CALL POSIT
  POP HL
  RET

; Routine at 30629
;
; Used by the routine at __STOP.
L77A5:
  PUSH HL
  LD HL,$FC6A		; Unkown system variable
  JR _TRIG_0

; Routine at 30635
;
; Used by the routine at __SPRITE.
L77AB:
  PUSH HL
  LD HL,IFLG_COLLSN		; Sprite collision - Interrupt flags
  JR _TRIG_0

; Routine at 30641
;
; Used by the routine at NOT_KEYWORD.
_INTERVAL:
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB 'E'			; "INTE..."
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB 'R'			; "INTER..."
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB $FF
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB TK_VAL+$80	; "INTERVAL"
  PUSH HL
  LD HL,IFLG_TIMER		; TIMER - Interrupt flags
  JR _TRIG_0

; Routine at 30655
;
; Used by the routine at NOT_KEYWORD.
; STICK(n) function
_TRIG:
  LD A,$04
  CALL BYTPPARM		; Get (byte parameter), use A to check its MAX value
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  PUSH HL
  LD D,$00
  LD HL,IFLG_STRIG0		; SPACE key trigger - Interrupt flags
  ADD HL,DE
  ADD HL,DE
  ADD HL,DE
; This entry point is used by the routines at L77A5, L77AB and _INTERVAL.
_TRIG_0:
  CALL L77FE
  JR __MDM_2

; Routine at 30676
; This entry point is used by the routine at _TRIG and KEY_CONFIG.
L77D4:
  CALL GETINT              ; Get integer 0-255
  DEC A
  CP $0A
  JP NC,FC_ERR
  LD A,(HL)
  PUSH HL
  CALL L77E8

__MDM_2:
  POP HL
  POP AF
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JP NEWSTT_0

; Routine at 30696
;
; Used by the routine at L77D4.
L77E8:
  LD D,$00
  LD HL,FNKSWI
  ADD HL,DE
  PUSH HL
  LD HL,TRPTBL-3		; BOTTOM+1
  ADD HL,DE
  ADD HL,DE
  ADD HL,DE
  CALL L77FE
  LD A,(HL)
  AND $01
  POP HL
  LD (HL),A
  RET

; Routine at 30718
;
; Used by the routines at _TRIG and L77E8.
L77FE:
  CP TK_ON
  JP Z,TIME_S_ON
  CP TK_OFF
  JP Z,TIME_S_OFF
  CP TK_STOP
  JP Z,TIME_S_STOP
  JP SN_ERR

; Routine at 30736
ON_OPTIONS:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HONGO		; Hook for "ON DEVICE GOSUB"
ENDIF
  LD BC,$000A		; 1, 10
  CP TK_KEY
  RET Z
  LD BC,$0A01		; 10, 1
  CP TK_STOP
  RET Z
  INC B				; 10, 2
  CP TK_SPRITE
  RET Z
  CP $FF			; Lower TOKEN codes prefix ?
  RET C
  PUSH HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  CP TK_TRIG+$80	; $A3
  JR Z,ON_OPTIONS_1
  
  CP TK_INT+$80		; INTERVAL ?
  JR Z,ON_INTERVAL
  
ON_OPTIONS_0:
  POP HL
  SCF
  RET

ON_OPTIONS_1:
  POP BC
  LD BC,$0C05		; 12, 5
  RET

ON_INTERVAL:
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  CP 'E'			; "INTE.."
  JR NZ,ON_OPTIONS_0
  POP BC
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB 'R'			; "INTER.."
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB $FF
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB TK_VAL+$80	; "INTERVAL"
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB TK_EQUAL		; Token for '='
  CALL GETWORD
  LD A,D
  OR E
  JP Z,FC_ERR
  EX DE,HL
  LD (INTVAL),HL
  LD (INTCNT),HL
  EX DE,HL
  LD BC,$1101		; 17, 1
  DEC HL
  RET

  
; Routine at 30812
;
; Used by the routine at L492A.
L785C:
  PUSH HL
  LD B,A	; compute (B*3)+IENTRY_F1
  ADD A,A
  ADD A,B
  LD L,A
  LD H,$00
  LD BC,TRPTBL+1		; First entry in the table for interrupt services
  ADD HL,BC
  LD (HL),E
  INC HL
  LD (HL),D
  POP HL
  RET

; Routine at 30828
__KEY:
  CP TK_LIST		; "KEY LIST" command ?
  JR NZ,KEY_CONFIG
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  PUSH HL
  LD HL,FNKSTR
  LD C,$0A
__KEY_0:
  LD B,$10
__KEY_1:
  LD A,(HL)
  INC HL
  CALL SNVCHR
  JR C,__KEY_2
  DEC B
  JR Z,__KEY_5
  LD A,(HL)
  INC HL
  LD E,A
  CALL SNVCHR
  JR Z,__KEY_2
  LD A,$01
  RST OUTDO  		; Output char to the current device
  LD A,E
  JR __KEY_4

__KEY_2:
  CP $7F			; 'DEL' key code
  JR Z,__KEY_3
  CP ' '
  JR NC,__KEY_4
__KEY_3:
  LD A,' '
__KEY_4:
  RST OUTDO  		; Output char to the current device
  DJNZ __KEY_1
__KEY_5:
  CALL OUTDO_CRLF
  DEC C
  JR NZ,__KEY_0
  POP HL
  RET

; Routine at 30886
KEY_ON:
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JP DSPFNK		; Show the function key display.

; Routine at 30890
KEY_OFF:
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JP ERAFNK

; Data block at 30894
KEY_CONFIG:
  CP '('
  JP Z,L77D4
  CP TK_ON		; "KEY ON"
  JR Z,KEY_ON
  
  CP TK_OFF		; "KEY OFF"
  JR Z,KEY_OFF
  
  CALL GETINT              ; Get integer 0-255
  DEC A
  CP LF
  JP NC,FC_ERR
  EX DE,HL
  LD L,A
  LD H,$00
  ADD HL,HL
  ADD HL,HL
  ADD HL,HL
  ADD HL,HL
  LD BC,FNKSTR		; FUNCTION KEY AREA
  ADD HL,BC
  PUSH HL
  EX DE,HL
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
  CALL EVAL
  PUSH HL
  CALL GETSTR
  LD B,(HL)
  INC HL
  LD E,(HL)
  INC HL
  LD D,(HL)
  POP HL
  EX (SP),HL
  LD C,$0F
  LD A,B
  AND A
  JR Z,KEY_CONFIG_1
KEY_CONFIG_0:
  LD A,(DE)
  AND A
  JP Z,FC_ERR
  LD (HL),A
  INC DE
  INC HL
  DEC C
  JR Z,KEY_CONFIG_2
  DJNZ KEY_CONFIG_0
KEY_CONFIG_1:
  LD (HL),B
  INC HL
  DEC C
  JR NZ,KEY_CONFIG_1
KEY_CONFIG_2:
  LD (HL),C
  CALL FNKSB
  POP HL
  RET

; Routine at 30976
;
; Used by the routine at OPRND.
FN_TIME:
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  PUSH HL
  LD HL,(JIFFY)
  CALL INEG2
  POP HL
  RET

; Routine at 30986
;
; Used by the routine at OPRND.
FN_CSRLIN:
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  PUSH HL
  LD A,(CSRY)
  JR FN_PLAY_1

; Routine at 30993
__TIME:
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB TK_EQUAL			; Token for '='
  CALL GETWORD
  LD (JIFFY),DE
  RET

; Routine at 31003
;
; Used by the routine at OPRND.
FN_PLAY:
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  LD A,$03			; 3 possible sound channels
  CALL BYTPPARM		; Get (byte parameter), use A to check its MAX value
  PUSH HL
  LD A,(MUSICF)
  DEC E
  JP M,FN_PLAY_3
FN_PLAY_0:
  RRCA
  DEC E
  JP P,FN_PLAY_0
  LD A,$00
  JR NC,FN_PLAY_2
; This entry point is used by the routine at FN_CSRLIN.
FN_PLAY_1:
  DEC A
FN_PLAY_2:
  CALL CONIA        ;CONVERT [A] TO AN INTEGER SIGNED
  POP HL
  RET
  
FN_PLAY_3:
  AND $07
  JR Z,FN_PLAY_2
  LD A,$FF
  JR FN_PLAY_2

; Routine at 31040
__STICK:
  CALL CONINT
  CP $03
  JR NC,__STRIG_0
  CALL GTSTCK
  JR __PDL_0

; Routine at 31052
__STRIG:
  CALL CONINT
  CP $05
; This entry point is used by the routines at __STICK, __PDL and __PAD.
__STRIG_0:
  JP NC,FC_ERR
  CALL GTTRIG
; This entry point is used by the routine at __PAD.
__STRIG_1:
  JP CONIA           ;CONVERT [A] TO AN INTEGER SIGNED

; Routine at 31066
__PDL:
  CALL CONINT
  DEC A
  CP $0C
  JR NC,__STRIG_0
  INC A
  CALL GTPDL
; This entry point is used by the routines at __STICK and __PAD.
__PDL_0:
  JP PASSA

; Routine at 31081
__PAD:
  CALL CONINT
  CP $08
  JR NC,__STRIG_0
  PUSH AF
  CALL GTPAD
  LD B,A
  POP AF
  AND $03
  DEC A
  CP $02
  LD A,B
  JR C,__PDL_0
  JR __STRIG_1

; Routine at 31104
__COLOR:
  LD BC,FC_ERR			; Default addr to exit to if out of range
  PUSH BC
  LD DE,(FORCLR)
  PUSH DE
  CP ','
  JR Z,__COLOR_0
  CALL GETINT              ; Get integer 0-255
  POP DE
  CP $10		; 16 colors
  RET NC
  LD E,A
  PUSH DE
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JR Z,__COLOR_2
__COLOR_0:
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
  JR Z,__COLOR_2
  CP ','
  JR Z,__COLOR_1
  CALL GETINT              ; Get integer 0-255
  POP DE
  CP $10		; 16 colors
  RET NC
  LD D,A
  PUSH DE
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JR Z,__COLOR_2
__COLOR_1:
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
  CALL GETINT              ; Get integer 0-255
  POP DE
  CP $10		; 16 colors
  RET NC
  LD (BDRCLR),A
  PUSH DE
__COLOR_2:
  POP DE
  POP AF			; Remove "FC_ERR" on exit
  PUSH HL
  EX DE,HL
  LD (FORCLR),HL
  LD A,L
  LD (ATRBYT),A
  CALL CHGCLR
  POP HL
  RET

; Routine at 31180
; SCREEN <DisplayMode>,<SpriteSize>,<Keyclick>,<BaudRate>,<PrinterType>
__SCREEN:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HSCRE		; Hook for "SCREEN"
ENDIF
  CP ','
  JR Z,__SCREEN_0
  CALL GETINT              ; Get integer 0-255
  CP $04
  JP NC,FC_ERR
  PUSH HL
  CALL CHGMOD		; Sets the VDP mode according to SCRMOD.
  LD A,(LINLEN)
  LD E,A
  CALL __WIDTH_4
  POP HL
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  RET Z
__SCREEN_0:
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
  CP ','
  JR Z,__SCREEN_1
  CALL GETINT              ; Get integer 0-255
  CP $04
  JP NC,FC_ERR
  LD A,(RG1SAV)
  AND $FC
  OR E
  LD (RG1SAV),A
  PUSH HL
  CALL CLRSPR
  POP HL
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  RET Z
__SCREEN_1:
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
  CP ','
  JR Z,__SCREEN_2
  CALL GETINT              ; Get integer 0-255
  LD (CLIKSW),A
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  RET Z
__SCREEN_2:
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
  CP ','
  JR Z,SET_PRINTERTYPE
  CALL SET_BAUDRATE
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  RET Z
  
SET_PRINTERTYPE:
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
  CALL GETINT              ; Get integer 0-255
  LD (NTMSXP),A
  RET

; Routine at 31277
;
; Used by the routines at __CSAVE and __SCREEN.
SET_BAUDRATE:
  CALL GETINT              ; Get integer 0-255
  DEC A
  CP $02
  JP NC,FC_ERR
  PUSH HL
  LD BC,$0005
  AND A
  LD HL,CS120			; 1200 bps
  JR Z,SET_BAUDRATE_0
  ADD HL,BC				; HL=CS240:  2400 BPS

SET_BAUDRATE_0:
  LD DE,LOW
  LDIR			; Copy to 'LOW', 'HIGH' and 'HEADER' delay counters
  POP HL
  RET

; Routine at 31304
__SPRITE:
  CP $24
  JP NZ,L77AB
  LD A,(SCRMOD)
  AND A
  JP Z,FC_ERR
  CALL GET_HEXBYTE
  PUSH DE
  CALL FRMEQL
  EX (SP),HL
  PUSH HL
  CALL GETSTR
  INC HL
  LD E,(HL)
  INC HL
  LD D,(HL)
  CALL GSPSIZ
  LD C,A
  LD B,$00
  DEC HL
  DEC HL
  DEC A
  CP (HL)
  LD A,(HL)
  JR C,__SPRITE_0
  POP HL
  PUSH HL
  PUSH AF
  XOR A
  CALL FILVRM
  POP AF
  AND A
  LD C,A
  LD B,$00
__SPRITE_0:
  EX DE,HL
  POP DE
  CALL NZ,LDIRVM
  POP HL
  RET

; Routine at 31364
;
; Used by the routine at OPRND.
FN_SPRITE:
  CALL GETNEXT_HEXBYTE
  PUSH HL
  PUSH DE
  CALL GSPSIZ
  LD C,A
  LD B,$00
  PUSH BC
  CALL MKTMST			; Make temporary string
  LD HL,(TMPSTR)
  EX DE,HL
  POP BC
  POP HL
  CALL LDIRMV
  JP TSTOPL

; Routine at 31391
;
; Used by the routine at FN_SPRITE.
GETNEXT_HEXBYTE:
  RST CHRGTB		; Gets next character (or token) from BASIC text.

; This entry point is used by the routine at __SPRITE.
GET_HEXBYTE:
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB '$'
  LD A,$FF			; A whole byte range
  CALL BYTPPARM		; Get (byte parameter), use A to check its MAX value
  PUSH HL
  LD A,E
  CALL CALPAT
  EX DE,HL
  POP HL
  RET

; Routine at 31407
;
; Used by the routine at L7756.
PUT_SPRITE:
  DEC B
  JP M,FC_ERR
  LD A,(SCRMOD)
  AND A
  JP Z,FC_ERR
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  CALL GETINT              ; Get integer 0-255
  CP 32
  JP NC,FC_ERR
  PUSH HL
  CALL CALATR
  EX (SP),HL
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
  CP ','
  JR Z,PUT_SPRITE_1
  CALL SCAN1
  EX (SP),HL
  LD A,E
  CALL WRTVRM
  LD A,B
  ADD A,A
  LD A,C
  LD B,$00
  JR NC,PUT_SPRITE_0
  ADD A,$20
  LD B,$80
PUT_SPRITE_0:
  INC HL
  CALL WRTVRM
  INC HL
  INC HL
  CALL RDVRM
  AND $0F
  OR B
  CALL WRTVRM
  DEC HL
  DEC HL
  DEC HL
  EX (SP),HL
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  POP BC
  RET Z
  PUSH BC
PUT_SPRITE_1:
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
  CP ','
  JR Z,PUT_SPRITE_2
  CALL GETINT              ; Get integer 0-255
  CP $10
  JP NC,FC_ERR
  EX (SP),HL
  INC HL
  INC HL
  INC HL
  CALL RDVRM
  AND $80
  OR E
  CALL WRTVRM
  DEC HL
  DEC HL
  DEC HL
  EX (SP),HL
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  POP BC
  RET Z
  PUSH BC
PUT_SPRITE_2:
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
  CALL GETINT              ; Get integer 0-255
  CALL GSPSIZ
  LD A,E
  JR NC,PUT_SPRITE_3
  CP $40
  JP NC,FC_ERR
  ADD A,A
  ADD A,A
PUT_SPRITE_3:
  EX (SP),HL
  INC HL
  INC HL
  CALL WRTVRM
  POP HL
  RET

; Routine at 31543
__VDP:
  LD A,$07
  CALL BYTPPARM		; Get (byte parameter), use A to check its MAX value
  PUSH DE
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB TK_EQUAL			; Token for '='
  CALL GETINT              ; Get integer 0-255
  POP BC
  LD B,A
  JP WRTVDP

; Routine at 31559
;
; Used by the routine at OPRND.
FN_VDP:
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  LD A,$08
  CALL BYTPPARM		; Get (byte parameter), use A to check its MAX value
  PUSH HL
  LD D,$00
  LD HL,RG0SAV
  ADD HL,DE
  LD A,(HL)
  CALL PASSA
  POP HL
  RET

; Routine at 31578
__BASE:
  LD A,$13
  CALL BYTPPARM		; Get (byte parameter), use A to check its MAX value
  LD D,$00
  PUSH DE
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB TK_EQUAL			; Token for '='
  CALL EVAL
  EX (SP),HL
  PUSH HL
  CALL PARMADDR		; get address parameter
  LD C,L
  LD B,H
  POP HL
  LD A,L
  PUSH AF
  ADD HL,HL
  EX DE,HL
  LD HL,L7BA3
  ADD HL,DE
  LD A,C
  AND (HL)
  JR NZ,__BASE_0
  INC HL
  LD A,B
  AND (HL)
__BASE_0:
  JP NZ,FC_ERR
  LD HL,TXTNAM
  ADD HL,DE
  LD (HL),C
  INC HL
  LD (HL),B
  POP AF
  LD E,$FF
__BASE_1:
  INC E
  SUB $05
  JR NC,__BASE_1
  LD A,(SCRMOD)
  CP E
  CALL Z,L7B99
  POP HL
  RET

; Routine at 31641
;
; Used by the routine at __BASE.
L7B99:
  DEC A
  JP M,SETTXT
  JP Z,SETGRP
  JP SETMLT

; Routine at 31651
L7BA3:
  DEFB $ff,$03, $3f,$00, $ff,$07, $7f,$00, $ff,$07
  DEFB $ff,$03, $3f,$00, $ff,$07, $7f,$00, $ff,$07
  DEFB $ff,$03, $ff,$1f, $ff,$1f, $7f,$00, $ff,$07
  DEFB $ff,$03, $3f,$00, $ff,$07, $7f,$00, $ff,$07

; This entry point is used by the routine at OPRND.
FN_BASE:
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  LD A,$13
  CALL BYTPPARM		; Get (byte parameter), use A to check its MAX value
  PUSH HL
  LD D,$00
  LD HL,TXTNAM
  ADD HL,DE
  ADD HL,DE
; This entry point is used by the routine at BYTPPARM.
FN_BASE_1:
  LD A,(HL)
  INC HL
  LD H,(HL)
  LD L,A
  CALL INEG2
  POP HL
  RET

; Routine at 31714
__VPOKE:
  CALL EVAL
  PUSH HL
  CALL PARMADDR		; get address parameter
  EX (SP),HL
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
  CALL GETINT              ; Get integer 0-255
  EX (SP),HL
  CALL WRTVRM
  POP HL
  RET

; Routine at 31733
__VPEEK:
  CALL PARMADDR		; get address parameter
  CALL RDVRM
  JP PASSA

; Routine at 31742
;
; Used by the routines at __BASE, __VPOKE and __VPEEK.
PARMADDR:
  CALL __CINT
  LD DE,$4000
  RST DCOMPR		; Compare HL with DE.
  RET C
  JR _FC_ERR_B

; Routine at 31752
;
; Used by the routines at _TRIG, FN_PLAY, GETNEXT_HEXBYTE, __VDP, FN_VDP, __BASE and L7BA3.
; Get (byte parameter), use A to check its MAX value
BYTPPARM:
  PUSH AF
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB '('
  CALL GETINT              ; Get integer 0-255
  POP AF
  CP E
  JR C,_FC_ERR_B
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ')'
  LD A,E
  RET

; Routine at 31766
__DSKO_S:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HDSKO			; Hook for "DSKO$"
ENDIF
  JR _FC_ERR_B

; Routine at 31771
__SET:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HSETS			; Hook for SET
ENDIF
  JR _FC_ERR_B

; Routine at 31776
__NAME:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HNAME			; Hook for NAME
ENDIF
  JR _FC_ERR_B

; Routine at 31781
__KILL:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HKILL			; Hook for KILL
ENDIF
  JR _FC_ERR_B

; Routine at 31786
__IPL:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HIPL				; Hook for IPL
ENDIF
  JR _FC_ERR_B

; Routine at 31791
__COPY:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HCOPY			; Hook for COPY
ENDIF
  JR _FC_ERR_B

; Routine at 31796
__CMD:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HCMD				; Hook for CMD
ENDIF
  JR _FC_ERR_B

; Routine at 31801
__DSKF:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HDSKF			; Hook for DSKF
ENDIF
  JR _FC_ERR_B

; Routine at 31806
;
; Used by the routine at OPRND.
FN_DSKI:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HDSKI			; Hook for DSKI$
ENDIF
  JR _FC_ERR_B

; Routine at 31811
;
; Used by the routine at OPRND.
FN_ATTR:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HATTR			; Hook for ATTR$
ENDIF
  JR _FC_ERR_B



;LSET/RSET stringvar = stringexp
;
; If stringvar points to an I/O buffer, use the string size to
; justify string. If stringvar is a literal, make new var with length
; of literal. If stringvar points to string space, use it. If the
; length of the variable is zero, return the null string. If a copy
; must be created, and stringexp is a temporary, use this space over
; unless length stringvar greater than stringexp.


; Routine at 31816
__LSET:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HLSET			; Hook for LSET
ENDIF
  JR _FC_ERR_B

; Routine at 31821
__RSET:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HRSET			; Hook for RSET
ENDIF
  JR _FC_ERR_B

; Routine at 31826
__FIELD:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HFIEL			; Hook for FIELD
ENDIF
  JR _FC_ERR_B

; Routine at 31831
__MKI_S:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HMKI_S			; Hook for MKI$
ENDIF
  JR _FC_ERR_B

; Routine at 31836
__MKS_S:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HMKS_S			; Hook for MKS$
ENDIF
  JR _FC_ERR_B

; Routine at 31841
__MKD_S:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HMKD_S			; Hook for MKD$
ENDIF
  JR _FC_ERR_B

; Routine at 31846
__CVI:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HCVI				; Hook for CVI
ENDIF
  JR _FC_ERR_B

; Routine at 31851
__CVS:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HCVS				; Hook for CVS
ENDIF
  JR _FC_ERR_B

; Routine at 31856
__CVD:
IF NOHOOK
 IF PRESERVE_LOCATIONS
   DEFS 3
 ENDIF
ELSE
  CALL HCVD				; Hook for CVD
ENDIF
; This entry point is used by the routines at PARMADDR, BYTPPARM, __DSKO_S, __SET,
; __NAME, __KILL, __IPL, __COPY, __CMD, __DSKF, FN_DSKI, FN_ATTR, __LSET, __RSET,
; __FIELD, __MKI_S, __MKS_S, __MKD_S, __CVI and __CVS.
_FC_ERR_B:
  JP FC_ERR

; Routine at 31862
;
; Used by the routine at CSTART.
_CSTART:
  LD SP,STACK_INIT
IF NOHOOK
  IF PRESERVE_LOCATIONS
  DEFS 13
  ENDIF
ELSE
  LD BC,$022F		; HOOK table size
  LD DE,HKEYI+1
  LD HL,HKEYI		; First Entry in the Hook Table
  LD (HL),$C9		; 'RET'
  LDIR
ENDIF
  LD HL,RDPRIM		;  First location in the System variables region
  LD (HIMEM),HL
  CALL BASE_RAM
  LD (BOTTOM),HL
  
  LD BC,$0090		; > $0076 crashes the SVI
  LD DE,RDPRIM		; Prepare System variables region, first location is $F380 (RDPRIM)
  LD HL,__RDPRIM	; 
  LDIR

  ;CALL INIT32
  ;HALT
  
  CALL INIFNK		; Init FN KEY region, starts at $F87F
  XOR A
  LD (ENDBUF),A
  LD (NLONLY),A
  LD A,','
  LD (BUFMIN),A			; a comma just before BUF.. used, e.g. in "FILSTI"
  LD A,':'
  LD (BUFFER),A         ; a colon for restarting input
  LD HL,(FONT)			; Point to CHFONT in ROM
  LD (CHFONT),HL
  LD HL,PRMSTK		; Previous definition block on stack
  LD (PRMPRV),HL
  LD (STKTOP),HL
  LD BC,$00C8		; 200
  ADD HL,BC
  LD (MEMSIZ),HL
  LD A,$01
  LD (VARTAB+1),A
  CALL MAXFILES
  CALL CLREG  		; Clear registers and warm boot
  LD HL,(BOTTOM)
  XOR A
  LD (HL),A
  INC HL
  LD (TXTTAB),HL
  CALL CLRPTR
  CALL INITIO
  CALL INIT32
  CALL CLRSPR
  LD HL,$0A0B		; Cursor Position: 
  LD (CSRY),HL		
  LD HL,MSX_MSG		; "MSX System"
  CALL PRS
  LD HL,$0A0C		; Cursor Position: 
  LD (CSRY),HL
  LD HL,VER_MSG
  CALL PRS
IF SPECTRUM_SKIN
  LD HL,$060E		; Cursor Position: 
ELSE
  LD HL,$020E		; Cursor Position: 
ENDIF
  LD (CSRY),HL
  LD HL,COPYRIGHT_MSG
  CALL PRS
  LD B,$06
_CSTART_0:
  DEC HL
  LD A,L
  OR H
  JR NZ,_CSTART_0
  LD B,$00
  CALL L7D75
  LD HL,(BOTTOM)
  XOR A
  LD (HL),A
  INC HL
  LD (TXTTAB),HL
  CALL CLRPTR
  CALL BANNER
  JP READY

; Routine at 32041
;
; Used by the routine at _CSTART.
; Initial "copyright" message on top of the screen
; The "DISK BASIC" extension calls it directly skipping the 
; above call (adds the "DISK BASIC" message), so this can't be easily relocated
; (probably HOOKS need to be disabled in this case)
BANNER:
  LD A,$FF
  LD (CNSDFG),A		; FN key status
IF SPECTRUM_SKIN
  CALL INIT32
ELSE
  CALL INITXT
ENDIF
  LD HL,BASIC_MSG
  CALL PRS
  LD HL,VER_MSG
  CALL PRS
  LD HL,COPYRIGHT_MSG
  CALL PRS
  LD HL,(VARTAB)
  EX DE,HL
  LD HL,(STKTOP)
  ; HL=HL-DE
  LD A,L
  SUB E
  LD L,A
  LD A,H
  SBC A,D
  LD H,A
  ;
  LD BC,$FFF2		; -14
  ADD HL,BC
  CALL LINPRT
  LD HL,BYTES_MSG
  JP PRS

; Routine at 32093
;
; Used by the routine at _CSTART.
;  Programs mostly start on 0x8000 (if not otherwise descripted by TXTTAB)
BASE_RAM:
  LD HL,$8000		; 32768
; This entry point is used by the routine at L7D61.
JUST_RET:
  RET

; Routine at 32097
L7D61:
  CPL
  LD (HL),A
  CP (HL)
  CPL
  LD (HL),A
  JR NZ,L7D61_0
  INC L
  JR NZ,JUST_RET
  LD A,H
  DEC A
  RET P
  LD H,A
  JR JUST_RET
L7D61_0:
  LD L,$00
  INC H
  RET

; Routine at 32117
;
; Used by the routine at _CSTART.
L7D75:
  DI
  LD C,$00
  LD DE,EXP0		; Expansion slot #0
  LD HL,SLTATR
L7D75_0:
  LD A,(DE)
  OR C
  LD C,A
  PUSH DE
L7D75_1:
  INC HL
  PUSH HL
  LD HL,$4000
L7D75_2:
  CALL RDSLT_WORD
  PUSH HL
  LD HL,$4241
  RST DCOMPR		; Compare HL with DE.
  POP HL
  LD B,$00
  JR NZ,L7D75_3
  CALL RDSLT_WORD
  PUSH HL
  PUSH BC
  PUSH DE
  POP IX
  LD A,C
  PUSH AF
  POP IY
  CALL NZ,CALSLT
  POP BC
  POP HL
  CALL RDSLT_WORD
  ADD A,$FF
  RR B
  CALL RDSLT_WORD
  ADD A,$FF
  RR B
  CALL RDSLT_WORD
  ADD A,$FF
  RR B
  LD DE,$FFF8		; -8
  ADD HL,DE
L7D75_3:
  EX (SP),HL
  LD (HL),B
  INC HL
  EX (SP),HL
  LD DE,$3FFE
  ADD HL,DE
  LD A,H
  CP $C0
  JR C,L7D75_2
  POP HL
  INC HL
  LD A,C
  AND A
  LD DE,RDSLT
  JP P,L7DDF+1
  ADD A,$04
  LD C,A
  CP $90
  JR C,L7D75_1
  AND $03
  LD C,A
L7DDF:
	; L7DDF+1:  ADD HL,DE
  LD A,$19
  POP DE
  INC DE
  INC C
  LD A,C
  CP $04
  JR C,L7D75_0
  LD HL,SLTATR
  LD B,$40
L7DEE:
  LD A,(HL)
  ADD A,A
  JR C,L7D75_5
  INC HL
  DJNZ L7DEE
  RET

L7D75_5:
  CALL L7E2A
  CALL ENASLT
  LD HL,(VARTAB)
  LD DE,$C000
  RST DCOMPR		; Compare HL with DE.
  JR NC,L7D75_6
  EX DE,HL
  LD (VARTAB),HL
L7D75_6:
  LD HL,($8008)		;  Programs mostly start on 0x8000 (if not otherwise descripted by TXTTAB)
  INC HL
  LD (TXTTAB),HL
  LD A,H
  LD (BASROM),A
  CALL RUN_FST
  JP NEWSTT

; Routine at 32282
;
; Used by the routines at __CALL, L55F8, L564A and L7D75.
RDSLT_WORD:
  CALL RDSLT_WORD_0
  LD E,D
RDSLT_WORD_0:
  LD A,C
  PUSH BC
  PUSH DE
  CALL RDSLT
  POP DE
  POP BC
  LD D,A
  OR E
  INC HL
  RET

; Routine at 32298
;
; Used by the routines at __CALL, L55F8 and L7D75.
L7E2A:
  LD A,$40
  SUB B
; This entry point is used by the routine at L564A.
L7E2A_0:
  LD B,A
  LD H,$00
  RRA
  RR H
  RRA
  RR H
  RRA
  RRA
  AND $03
  LD C,A
  LD A,B
  LD B,$00
  PUSH HL
  LD HL,EXP0		; Expansion slot #0
  ADD HL,BC
  AND $0C
  OR C
  LD C,A
  LD A,(HL)
  POP HL
  OR C
  RET

; Routine at 32331
__MAX:
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB TK_FILES
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB TK_EQUAL			; Token for '='
  CALL GETINT              ; Get integer 0-255
  JP NZ,SN_ERR
  CP $10
  JP NC,FC_ERR
  LD (TEMP),HL
  PUSH AF
  CALL CLSALL		; Close all files
  POP AF
  CALL MAXFILES
  CALL _CLREG
  JP NEWSTT

; Routine at 32363
;
; Used by the routines at __CLEAR, _CSTART and __MAX.
; clear files ?
MAXFILES:
  PUSH AF
  LD HL,(HIMEM)
  LD DE,$FEF5		; -267 (same offset on Tandy model 100)
MAXFILES_0:
  ADD HL,DE
  DEC A
  JP P,MAXFILES_0
  EX DE,HL
  LD HL,(STKTOP)
  LD B,H
  LD C,L
  LD HL,(MEMSIZ)
  LD A,L
  SUB C
  LD L,A
  LD A,H
  SBC A,B
  LD H,A
  POP AF
  PUSH HL
  PUSH AF
  LD BC,$008C		; 140
  ADD HL,BC
  LD B,H
  LD C,L
  LD HL,(VARTAB)
  ADD HL,BC
  RST DCOMPR		; Compare HL with DE.
  JP NC,OM_ERR
  POP AF
  LD (MAXFIL),A
  LD L,E
  LD H,D
  LD (FILTAB),HL
  DEC HL
  DEC HL
  LD (MEMSIZ),HL
  POP BC
  LD A,L
  SUB C
  LD L,A
  LD A,H
  SBC A,B
  LD H,A
  LD (STKTOP),HL
  DEC HL
  DEC HL
  POP BC
  LD SP,HL
  PUSH BC
  LD A,(MAXFIL)
  LD L,A
  INC L
  LD H,$00
  ADD HL,HL
  ADD HL,DE
  EX DE,HL
  PUSH DE
  LD BC,$0109		; 265
MAXFILES_1:
  LD (HL),E
  INC HL
  LD (HL),D
  INC HL
  EX DE,HL
  LD (HL),$00
  ADD HL,BC
  EX DE,HL
  DEC A
  JP P,MAXFILES_1
  POP HL
  LD BC,$0009
  ADD HL,BC
  LD (NULBUF),HL
  RET

; Message at 32472
MSX_MSG:
  DEFM "MSX  system"
  DEFB $00
VER_MSG:
  DEFM "version 1.0"
  DEFB CR
  DEFB LF
  DEFB $00
BASIC_MSG:
  DEFM "MSX BASIC "
  DEFB $00
COPYRIGHT_MSG:
IF SPECTRUM_SKIN
  DEFB 127
  DEFM " 1983 by Microsoft"
ELSE
  DEFM "Copyright 1983 by Microsoft"
ENDIF
  DEFB CR
  DEFB LF
  DEFB $00
BYTES_MSG:
  DEFM " Bytes free"
  DEFB $00

  
;----------------------------------------------------
;-- THE NEXT $ 90 BYTES WILL BE RELOCATED AT $F380 --
;----------------------------------------------------

; Routine at 32551 ($7F27 -> $F380)
__RDPRIM:
  OUT (PPI_AOUT),A
  LD E,(HL)
  JR __WRPRIM_0

DEFC SYSV_DELTA = RDPRIM-__RDPRIM
  
; Routine at 32556 ($7F2C -> $F385)
__WRPRIM:
  OUT (PPI_AOUT),A
  LD (HL),E

__WRPRIM_0:
  LD A,D
  OUT (PPI_AOUT),A
  RET

; Routine at 32563 ($F733 -> $F38C)
__CLPRIM:
  OUT (PPI_AOUT),A
  EX AF,AF'
  CALL CALLIX + SYSV_DELTA		; CALL (IX)
  EX AF,AF'
  POP AF
  OUT (PPI_AOUT),A
  EX AF,AF'
  RET

CALLIX:  JP  (IX)   ; ($7F3F -> $F398)
; CALLIX+1:  JP (HL)	; ($7F40 -> $F399)

; USR0 ($7F3F -> $F39A)
USR_JPTAB:
  DEFW FC_ERR		; USR0
  DEFW FC_ERR		; USR1
  DEFW FC_ERR		; USR2
  DEFW FC_ERR		; USR3
  DEFW FC_ERR		; USR4
  DEFW FC_ERR		; USR5
  DEFW FC_ERR		; USR6
  DEFW FC_ERR		; USR7
  DEFW FC_ERR		; USR8
  DEFW FC_ERR		; USR9

  DEFB 37		; LINL40: Width for SCREEN 0
  DEFB 29		; LINL32: Width for SCREEN 1
  DEFB 29		; LINLEN: Width for the current text mode 
  DEFB 24		; CRTCNT: Columns
  DEFB 14		; CLMLST: Column space.
  
  DEFW 0		; TXTNAM: SCREEN 0 name table
  DEFW 0		; TXTCOL: SCREEN 0 color table
  DEFW $0800	; TXTCGP: SCREEN 0 character pattern table
  DEFW 0		; TXTATR: SCREEN 0 Sprite Attribute Table
  DEFW 0		; TXTPAT: SCREEN 0 Sprite Pattern Table

  DEFW $1800	; T32NAM: SCREEN 1 name table
  DEFW $2000	; T32COL: SCREEN 1 color table
  DEFW 0		; T32CGP: SCREEN 1 character pattern table
  DEFW $1B00	; T32ATR: SCREEN 1 Sprite Attribute Table
  DEFW $3800	; T32PAT: SCREEN 1 Sprite Pattern Table

  DEFW $1800	; GRPNAM: SCREEN 2 name table
  DEFW $2000	; GRPCOL: SCREEN 2 color table
  DEFW 0		; GRPCGP: SCREEN 2 character pattern table
  DEFW $1B00	; GRPATR: SCREEN 2 Sprite Attribute Table
  DEFW $3800	; GRPPAT: SCREEN 2 Sprite Pattern Table

  DEFW $0800	; MLTNAM: SCREEN 3 name table
  DEFW 0		; MLTCOL: SCREEN 3 color table
  DEFW 0		; MLTCGP: SCREEN 3 character pattern table
  DEFW $1B00	; MLTATR: SCREEN 3 Sprite Attribute Table
  DEFW $3800	; MLTPAT: SCREEN 3 Sprite Pattern Table

  DEFB 1		; CLIKSW: keyboard click status
  DEFB 1		; CSRY  : Current row position of the cursor
  DEFB 1		; CSRX  : Current column position of the cursor
  DEFB 0		; CNSDFG: function keys status
  
  DEFB $00		; RG0SAV: Copy of VDP Register #0
  DEFB $E0		; RG1SAV: Copy of VDP Register #1
  DEFB $00		; RG2SAV: Copy of VDP Register #2
  DEFB $00		; RG3SAV: Copy of VDP Register #3
  DEFB $00		; RG4SAV: Copy of VDP Register #4
  DEFB $00		; RG5SAV: Copy of VDP Register #5
  DEFB $00		; RG6SAV: Copy of VDP Register #6
  DEFB $00		; RG7SAV: Copy of VDP Register #7

  DEFB $00		; STATFL: Content of VDP(8) status register
  DEFB $FF		; TRGFLG: trigger buttons and space bar status
IF SPECTRUM_SKIN
  DEFB 1		; FORCLR: Foreground color
  DEFB 14		; BAKCLR: Background color
  DEFB 14		; BDRCLR: Border color
ELSE
  DEFB 15		; FORCLR: Foreground color
  DEFB 4		; BAKCLR: Background color
  DEFB 4		; BDRCLR: Border color
ENDIF
  
  JP 0			; ($7F94 -> $F3EC) Jump instruction used by Basic LINE command. (RIGHTC, LEFTC, UPC and DOWNC)
  JP 0			; ($7F96 -> $F3EF) Jump instruction used by Basic LINE command. (RIGHTC, LEFTC, UPC and DOWNC
  
  DEFB $0F		; ATRBYT: Attribute byte (for graphical routines it’s used to read the color) 
  
  DEFW $F959	; QUEUES: Address of the queue table for 'PLAY'
  DEFB $FF		; FRCNEW: CLOAD flag
  
  DEFB 1		; SCNCNT: Key scan timing
  DEFB 50		; REPCNT: Key repeat delay counter

L7FFF:
  DEFW KEYBUF	; PUTPNT: Keyboard buffer write position
  DEFW KEYBUF	; GETPNT: Keyboard buffer read position

; CS120 Cassette I/O parameters to use for 1200 baud 
 DEFW $5C53		; LOW - Signal delay when writing a 0 to tape 
 DEFW $2D26		; HIGH - Signal delay when writing a 1 to tape ($4D52 on SVI)
 DEFB $0F		; HEADER - Delay of tape header (sync.) block 

; CS240 - Cassette I/O parameters to use for 2400 baud 
 DEFW $2D25		; LOW - Signal delay when writing a 0 to tape 
 DEFW $160E		; HIGH - Signal delay when writing a 1 to tape ($4D52 on SVI)
 DEFB $1F		; HEADER - Delay of tape header (sync.) block 

; Default  Cassette I/O parameters (1200 baud)
 DEFW $5C53		; LOW - Signal delay when writing a 0 to tape 
 DEFW $2D26		; HIGH - Signal delay when writing a 1 to tape ($4D52 on SVI)
 DEFB $0F		; HEADER - Delay of tape header (sync.) block 

 DEFW $0100		; ASPCT1 Horizontal / Vertical aspect for CIRCLE command 
 DEFW $0100		; ASPCT2 Horizontal / Vertical aspect for CIRCLE command  

; "RESUME NEXT"   ($7FB6 -> $F40F)
; ENDCON:
; 
  DEFB ':'	; SAVTXT often points to this value (copied to "ENDCON" in RAM)
L7FB7:
  LD DE,PROCNM		; $FD89
  AND A
  RET NZ
  INC B
  RET
  
  
  
  
L0END:
  defs $8000-L0END


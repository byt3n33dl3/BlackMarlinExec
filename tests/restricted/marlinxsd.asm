  ORG $0000

; NEC PC8201

L0000:
  JP BOOT
NOFILE_MRK:
  DEFM "-.-"
  NOP
  NOP

; Check syntax, 1 byte follows to be compared
;
; Used by the routines at SNERR, __FOR, __DATA, FDTLP, OPNPAR, OPRND, UCASE,
; DEPINT, MAKINT, GETWORD, TOPOOL, LFRGNM, MIDNUM, CHKSTK, ISFLIO, SCPTLP and
; GET_DEVICE.
SYNCHR:
  LD A,(HL)
  EX (SP),HL
  CP (HL)
  JP NZ,SNERR
  INC HL
  EX (SP),HL
; This entry point is used by the routines at SNERR, __FOR, ULERR, __DATA,
; FDTLP, EVAL_04, OPRND, UCASE, FPSINT, FNDNUM, MAKINT, GETWORD, TOPOOL, MIDNUM,
; _DBL_ASCTFP, __RND, __POS, CHKSTK, ISFLIO, GETVAR, SCPTLP and GET_DEVICE.
CHRGTB:
  JP _CHRGTB
  
; This entry point is used by the routine at GET_DEVICE.
SYNCHR_1:
  EX DE,HL
  LD HL,($F507)
  EX DE,HL

; compare DE and HL (aka CPDEHL)
;
; Used by the routines at SNERR, __FOR, __DATA, MAKINT, GETWORD, TSTOPL, TESTR,
; GSTRDE, _DBL_ASCTFP, __POS, CHKSTK, GETVAR, SCPTLP and GET_DEVICE.
CPDEHL:
  LD A,H
  SUB D
  RET NZ
  LD A,L
  SUB E
  RET
; This entry point is used by the routine at ISFLIO.
CPDEHL_0:
  LD A,' '

; Output char in 'A' to console
;
; Used by the routines at SNERR, __DATA, MAKINT, GETWORD, PRS1, ISFLIO, SCPTLP
; and GET_DEVICE.
OUTC:
  JP _OUTC
  NOP
  JP TEL_TERM_000
  NOP

; Test number FAC type (Precision mode, etc..)
;
; Used by the routines at TOKEN_BUILT, __FOR, __DATA, EVAL_04, OPRND, GETWORD,
; TOPOOL, MIDNUM, __ABS, _TSTSGN, LOADFP, FCOMP, HLPASS, TSTSTR, FIX, __INT,
; _DBL_ASCTFP, GETVAR and SCPTLP.
GETYPR:
  JP __GETYPR
  
  NOP
  DI
  JP GET_DEVICE_697
  
; This entry point is used by the routines at __FOR, GETWORD, SCALE, __LOG,
; FMULT_BCDE, DIV, FCOMP, FIX, DECADD, _DBL_ASCTFP, POWER, __RND and __POS.
__TSTSGN:
  JP TSTSGN

  NOP
  DI
  JP _UART

; This entry point is used by the routines at SNERR, GETWORD, _DBL_ASCTFP, CHKSTK,
; ISFLIO, SCPTLP and GET_DEVICE.
GETYPR_1:
  JP _RST38H
  
  NOP
  DI
  JP GETWORD_128

; Jump table for statements and functions
FNCTAB:
  DEFW __END
  DEFW __FOR
  DEFW __NEXT
  DEFW __DATA
  DEFW __TANUT
  DEFW __DIM
  DEFW __READ
  DEFW __LET
  DEFW __GO TO
  DEFW __RUN
  DEFW __IF
  DEFW __RESTORE
  DEFW __GOSUB
  DEFW __RETURN
  DEFW __DATA+2		;  REM
  DEFW __STOP
  DEFW __PRINT
  DEFW __CLEAR
  DEFW __LIST
  DEFW __NEW
  DEFW __ON
  DEFW ULERR
  DEFW ULERR
  DEFW __POKE
  DEFW __CONT
  DEFW __CSAVE
  DEFW __CLOAD
  DEFW __OUT
  DEFW __LPRINT
  DEFW __LLIST
  DEFW ULERR
  DEFW __WIDTH
  DEFW __DATA+2		; ELSE
  DEFW ULERR
  DEFW ULERR
  DEFW ULERR
  DEFW ULERR
  DEFW __ERROR
  DEFW __RESUME
  DEFW __MENU
  DEFW ULERR
  DEFW __RENUM
  DEFW __DEFSTR
  DEFW __DEFINT
  DEFW __DEFSNG
  DEFW __DEFDBL
  DEFW __LINE
  DEFW __PRESET
  DEFW __PSET
  DEFW __BEEP
  DEFW __FORMAT
  DEFW __KEY
  DEFW __COLOR
  DEFW __COM
  DEFW __MAX
  DEFW __CMD
  DEFW __MOTOR
  DEFW __SOUND
  DEFW __EDIT
  DEFW __EXEC
  DEFW __SCREEN
  DEFW __CLS
  DEFW __POWER
  DEFW __BLOAD
  DEFW __BSAVE
  DEFW __DSKO_S
  DEFW ULERR
  DEFW ULERR
  DEFW __OPEN
  DEFW ULERR
  DEFW ULERR
  DEFW ULERR
  DEFW ULERR
  DEFW __CLOSE
  DEFW _LOAD+2	; __LOAD
  DEFW _LOAD+3	; __MERGE
  DEFW __FILES
  DEFW __NAME
  DEFW __KILL
  DEFW ULERR
  DEFW ULERR
  DEFW __SAVE
  DEFW __LFILES
  DEFW ULERR
FNCTAB_0:
  DEFW __LOCATE
  
  DEFW ULERR
  DEFW ULERR
  DEFW ULERR
  
;FNCTAB_FN:
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
  DEFW __SPACE_S	; $18
  DEFW ULERR
  DEFW ULERR
  DEFW __LPOS
  DEFW ULERR
  DEFW ULERR
  DEFW ULERR
  DEFW __CINT
  DEFW __CSNG
  DEFW __CDBL		; $21
  DEFW FIX
  DEFW ULERR
  DEFW ULERR
  DEFW ULERR
  DEFW __DSKF		; $26 
  DEFW __EOF		; $27
FNCTAB_1:
  DEFW __LOC		; $28
  DEFW __LOF		; $29
  DEFW L520D		; $2A
  DEFW ULERR
  DEFW ULERR
  DEFW ULERR
  
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
  DEFW WORDS_X		; $0396
  DEFW WORDS_Y		; $039A
  DEFW WORDS_Z		; $039B

; BASIC keyword list
WORDS:
WORDS_A:
  DEFM "N"
  DEFB $C4
  DEFB $F8	; TK_AND
  DEFM "B"
  DEFB $D3
  DEFB $06	; TK_ABS
  DEFM "T"
  DEFB $CE
  DEFB $0E	; TK_ATN
  DEFM "S"
  DEFB $C3
  DEFB $15	; TK_ASC
  DEFB $00

WORDS_B:
  DEFM "SAV"
  DEFB $C5
  DEFB $C1	; TK_BSAVE
  DEFM "LOA"
  DEFB $C4
  DEFB $C0	; TK_BLOAD
  DEFM "EE"
  DEFB $D0
  DEFB $B2	; TK_BEEP
  DEFB $00

WORDS_C:
  DEFM "OLO"
  DEFB $D2
  DEFB $B5	; TK_COLOR
  DEFM "LOS"
  DEFB $C5
  DEFB $CA	; TK_CLOSE
  DEFM "ON"
  DEFB $D4
  DEFB $99	; TK_CONT
  DEFM "LEA"
  DEFB $D2
  DEFB $92	; TK_CLEAR
  DEFM "LOA"
  DEFB $C4
  DEFB $9B	; TK_CLOAD
  DEFM "SAV"
  DEFB $C5
  DEFB $9A	; TK_CSAVE
  DEFM "SRLI"
  DEFB $CE
  DEFB $E6	; TK_CSRLIN
  DEFM "IN"
  DEFB $D4
  DEFB $1F	; TK_CINT
  DEFM "SN"
  DEFB $C7
  DEFB $20	; TK_CSNG
  DEFM "DB"
  DEFB $CC
  DEFB $21	; TK_CDBL
  DEFM "O"
  DEFB $D3
  DEFB $0C	; TK_COS
  DEFM "HR"
  DEFB $A4
  DEFB $16	; TK_CHR$
  DEFM "O"
  DEFB $CD
  DEFB $B6	; TK_COM
  DEFM "L"
  DEFB $D3
  DEFB $BE	; TK_CLS
  DEFM "M"
  DEFB $C4
  DEFB $B8	; TK_CMD
  DEFB $00

WORDS_D:
  DEFM "AT"
  DEFB $C1
  DEFB $84	; TK_DATE
  DEFM "I"
  DEFB $CD
  DEFB $86	; TK_DIM
  DEFM "EFST"
  DEFB $D2
  DEFB $AB	; TK_DEFSTR
  DEFM "EFIN"
  DEFB $D4
  DEFB $AC	; TK_DEFINT
  DEFM "EFSN"
  DEFB $C7
  DEFB $AD	; TK_DEFSNG
  DEFM "EFDB"
  DEFB $CC
  DEFB $AE	; TK_DEFDBL
  DEFM "SKO"
  DEFB $A4
  DEFB $C2	; TK_DSKO$
  DEFM "SKI"
  DEFB $A4
  DEFB $E8	; TK_DSKI$
  DEFM "SK"
  DEFB $C6
  DEFB $26	; TK_DSKF
  DEFM "ATE"
  DEFB $A4
  DEFB $EB	; TK_DATE$
  DEFB $00

WORDS_E:
  DEFM "LS"
  DEFB $C5
  DEFB $A1	; TK_ELSE
  DEFM "N"
  DEFB $C4
  DEFB $81	; TK_END
  DEFM "DI"
  DEFB $D4
  DEFB $BB	; TK_EDIT
  DEFM "RRO"
  DEFB $D2
  DEFB $A6	; TK_ERROR
  DEFM "R"
  DEFB $CC
  DEFB $DF	; TK_ERL
  DEFM "R"
  DEFB $D2
  DEFB $E0	; TK_ERR
  DEFM "XE"
  DEFB $C3
  DEFB $BC	; TK_EXEC
  DEFM "X"
  DEFB $D0
  DEFB $0B	; TK_EXP
  DEFM "O"
  DEFB $C6
  DEFB $27	; TK_EOF
  DEFM "Q"
  DEFB $D6
  DEFB $FB	; TK_EQV
  DEFB $00

WORDS_F:
  DEFM "ORMA"
  DEFB $D4
  DEFB $B3	; TK_FORMAT
  DEFM "O"
  DEFB $D2
  DEFB $82	; TK_FOR
  DEFM "ILE"
  DEFB $D3
  DEFB $CD	; TK_FILES
  DEFM "R"
  DEFB $C5
  DEFB $0F	; TK_FRE
  DEFM "I"
  DEFB $D8
  DEFB $22	; TK_FIX
  DEFB $00

WORDS_G:
  DEFM "OT"
  DEFB $CF
  DEFB $89	; TK_GOTO
  DEFM "O T"
  DEFB $CF
  DEFB $89	; TK_GOTO
  DEFM "OSU"
  DEFB $C2
  DEFB $8D	; TK_GOSUB
  DEFB $00

WORDS_H:
  DEFB $00

WORDS_I:
  DEFM "NPU"
  DEFB $D4
  DEFB $85	; TK_INPUT
  DEFB $C6
  DEFB $8B	; TK_IF
  DEFM "NST"
  DEFB $D2
  DEFB $E3	; TK_INSTR
  DEFM "N"
  DEFB $D4
  DEFB $05	; TK_INT
  DEFM "N"
  DEFB $D0
  DEFB $10	; TK_INP
  DEFM "M"
  DEFB $D0
  DEFB $FC	; TK_IMP
  DEFM "NKEY"
  DEFB $A4
  DEFB $E9	; TK_INKEY
  DEFB $00

WORDS_J:
  DEFB $00

WORDS_K:
  DEFM "IL"
  DEFB $CC
  DEFB $CF	; TK_KILL
  DEFM "E"
  DEFB $D9
  DEFB $B4	; TK_KEY
  DEFB $00

WORDS_L:
  DEFM "OCAT"
  DEFB $C5
  DEFB $D5	; TK_LOCATE
  DEFM "PRIN"
  DEFB $D4
  DEFB $9D	; TK_LPRINT
  DEFM "LIS"
  DEFB $D4
  DEFB $9E	; TK_LLIST
  DEFM "PO"
  DEFB $D3
  DEFB $1B	; TK_LPOS
  DEFM "E"
  DEFB $D4
  DEFB $88	; TK_LET
  DEFM "IN"
  DEFB $C5
  DEFB $AF	; TK_LINE
  DEFM "OA"
  DEFB $C4
  DEFB $CB	; TK_LOAD
  DEFM "IS"
  DEFB $D4
  DEFB $93	; TK_LIST
  DEFM "FILE"
  DEFB $D3
  DEFB $D3	; TK_LFILES
  DEFM "O"
  DEFB $C7
  DEFB $0A	; TK_LOG
  DEFM "O"
  DEFB $C3
  DEFB $28	; TK_LOC
  DEFM "E"
  DEFB $CE
  DEFB $12	; TK_LEN
  DEFM "EFT"
  DEFB $A4
  DEFB $01	; TK_LEFT$
  DEFM "O"
  DEFB $C6
  DEFB $29	; TK_LOF
  DEFB $00

WORDS_M:
  DEFM "OTO"
  DEFB $D2
  DEFB $B9	; TK_MOTOR
  DEFM "ERG"
  DEFB $C5
  DEFB $CC	; TK_MERGE
  DEFM "O"
  DEFB $C4
  DEFB $FD	; TK_MOD
  DEFM "ID"
  DEFB $A4
  DEFB $03	; TK_MID$
  DEFM "A"
  DEFB $D8
  DEFB $B7	; TK_MAX
  DEFM "EN"
  DEFB $D5
  DEFB $A8	; TK_MENU
  DEFB $00
  
WORDS_N:
  DEFM "EX"
  DEFB $D4
  DEFB $83	; TK_NEXT
  DEFM "AM"
  DEFB $C5
  DEFB $CE	; TK_NAME
  DEFM "E"
  DEFB $D7
  DEFB $94	; TK_NEW
  DEFM "O"
  DEFB $D4
  DEFB $DE	; TK_NOT
  DEFB $00

WORDS_O:
  DEFM "PE"
  DEFB $CE
  DEFB $C5	; TK_OPEN
  DEFM "U"
  DEFB $D4
  DEFB $9C	; TK_OUT
  DEFB $CE
  DEFB $95	; TK_ON
  DEFB $D2
  DEFB $F9	; TK_OR
  DEFM "F"
  DEFB $C6
  DEFB $E7	; TK_OFF
  DEFB $00

WORDS_P:
  DEFM "RIN"
  DEFB $D4
  DEFB $91	; TK_PRINT
  DEFM "OK"
  DEFB $C5
  DEFB $98	; TK_POKE
  DEFM "O"
  DEFB $D3
  DEFB $11	; TK_POS
  DEFM "EE"
  DEFB $CB
  DEFB $17	; TK_PEEK
  DEFM "SE"
  DEFB $D4
  DEFB $B1	; TK_PSET
  DEFM "RESE"
  DEFB $D4
  DEFB $B0	; TK_PRESET
  DEFM "OWE"
  DEFB $D2
  DEFB $BF	; TK_POWER
  DEFB $00

WORDS_Q:
  DEFB $00

WORDS_R:
  DEFM "ETUR"
  DEFB $CE
  DEFB $8E	; TK_RETURN
  DEFM "EA"
  DEFB $C4
  DEFB $87	; TK_READ
  DEFM "U"
  DEFB $CE
  DEFB $8A	; TK_RUN
  DEFM "ESTOR"
  DEFB $C5
  DEFB $8C	; TK_RESTORE
  DEFM "E"
  DEFB $CD
  DEFB $8F	; TK_REM
  DEFM "ESUM"
  DEFB $C5
  DEFB $A7	; TK_RESUME
  DEFM "IGHT"
  DEFB $A4
  DEFB $02	; TK_RIGHT$
  DEFM "N"
  DEFB $C4
  DEFB $08	; TK_RND
  DEFM "ENU"
  DEFB $CD
  DEFB $AA	; TK_RENUM
  DEFB $00

WORDS_S:
  DEFM "CREE"
  DEFB $CE
  DEFB $BD	; TK_SCREEN
  DEFM "TO"
  DEFB $D0
  DEFB $90	; TK_STOP
  DEFM "TATU"
  DEFB $D3
  DEFB $EE	; TK_STATUS
  DEFM "AV"
  DEFB $C5
  DEFB $D2	; TK_SAVE
  DEFM "TE"
  DEFB $D0
  DEFB $DA	; TK_STEP
  DEFM "G"
  DEFB $CE
  DEFB $04	; TK_SGN
  DEFM "Q"
  DEFB $D2
  DEFB $07	; TK_SQR
  DEFM "I"
  DEFB $CE
  DEFB $09	; TK_SIN
  DEFM "TR"
  DEFB $A4
  DEFB $13	; TK_STR$
  DEFM "TRING"
  DEFB $A4
  DEFB $E1	; TK_STRING$
  DEFM "PACE"
  DEFB $A4
  DEFB $18	; TK_SPACE$
  DEFM "OUN"
  DEFB $C4
  DEFB $BA	; TK_SOUND
  DEFB $00
  
WORDS_T:
  DEFM "HE"
  DEFB $CE
  DEFB $D8		; TK_THEN
  DEFM "AB"
  DEFB $A8
  DEFB $D9		; TK_TAB(
  DEFB $CF
  DEFB $D7		; TK_TO
  DEFM "IME"
  DEFB $A4
  DEFB $EA		; TK_TIME$
  DEFM "A"
  DEFB $CE
  DEFB $0D		; TK_TAN
  DEFB $00
  
WORDS_U:
  DEFM "SIN"
  DEFB $C7
  DEFB $E2		; TK_USING
  DEFB $00

WORDS_V:
  DEFM "A"
  DEFB $CC
  DEFB $14		; TK_VAL
  DEFB $00
  
WORDS_W:
  DEFM "IDT"
  DEFB $C8
  DEFB $A0		; TK_WIDTH
  DEFB $00
  
WORDS_X:

  DEFM "O"
  DEFB 'R'+$80
  DEFB $FA		;TK_XOR
  DEFB $00

WORDS_Y:

  DEFB $00

WORDS_Z:

  DEFB $00

  
OPR_TOKENS:
  DEFB $AB
  DEFB $F3		; TK_PLUS		; Token for '+'
  DEFB $AD
  DEFB $F4		; TK_MINUS		; Token for '-'
  DEFB $AA
  DEFB $F5		; TK_STAR		; Token for '*'
  DEFB $AF
  DEFB $F6		; TK_SLASH		; Token for '/'
  DEFB $DE
  DEFB $F7		; TK_EXPONENT	; Token for '^'
  DEFB $DC
  DEFB $FE		; TK_BKSLASH	; Token for '\'
  DEFB $A7
  DEFB $E4		; TK_APOSTROPHE	; Token for '''
  DEFB $BE
  DEFB $F0		; TK_GREATER	; Token for '>'
  DEFB $BD
  DEFB $F1		; TK_EQUAL		; Token for '='
  DEFB $BC
  DEFB $F2		; TK_MINOR		; Token for '<'
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

; NUMBER TYPES
TYPE_OPR:
  DEFW __CDBL
  DEFW 0
  DEFW __CINT
  DEFW TSTSTR
  DEFW __CSNG

DEC_OPR:
  DEFW DECADD
  DEFW DECSUB
  DEFW DECMUL
  DEFW DECDIV
  DEFW DECCOMP

FLT_OPR:
  DEFW FADD
  DEFW FSUB
  DEFW FMULT_BCDE
  DEFW FDIV
  DEFW FCOMP

;$03DB
INT_OPR:
  DEFW IADD
  DEFW ISUB
  DEFW IMULT
  DEFW IDIV
  DEFW ICOMP


ERRMSG:
  DEFM "NFSNRGODFCOVOMULBSDD"
  DEFM "/0IDTMOSLSSTCNUFNRRW"
  DEFM "UEMOBOIODUIEBNFFAOEF"
  DEFM "NMDSFLCFPC"

; Data block at 1067
SYSVARS_ROM:
  DEFW $8A4D
  DEFW $0000
  DEFW $F380
  DEFW $00C9
  DEFW $FB00
  DEFW $00C9
  DEFW $00C9
  DEFW $C900
  DEFW $0000
  DEFW $95C3
  DEFW $DB18
  DEFW $E6A0
  DEFW $C00C
  DEFW FNCTAB_1
  DEFW $A1D3
  DEFW $4021
  DEFW $1100
  DEFW $F991
  DEFW $127E
  DEFW UCASE_6
  DEFW $D67D
  DEFW $C248
  DEFW $F3A4
  DEFW $A1D3
  DEFW $912A
  DEFW $11F9
  DEFW $4241
  DEFW $18C3
  DEFW $F300
  DEFW FNCTAB_1
  DEFW $A1D3
  DEFW $00C7
  DEFW $5321
  DEFW $5459
  DEFW FNCTAB
  DEFW $00F0
  DEFW $00C9
  DEFW $C900
  DEFW $0000
  DEFW $00C9
  DEFW $C900
  DEFW $0000
  DEFW $00C9
  DEFW $C900
  DEFW $0000
  DEFW $0000
  DEFW $C9C0
  DEFW $0000
  DEFW $0000
  DEFW $FFFF
  DEFW $0100
  DEFW $0801
  DEFW GETYPR
  DEFW $0000
  DEFW $0101
  DEFW $0101
  DEFW $2819
  DEFW $0000
  DEFW L4FC4_4
  DEFW $3038
  DEFW $0000
  DEFW $0000
  DEFW $0000
  DEFW $0000
  DEFW $0000
  DEFW $FF64
  DEFW $0000
  DEFW $4938
  DEFW $3137
  DEFW GET_DEVICE_5
  DEFW $00C3
  DEFW $0000
  DEFW $00C9
  DEFW $D3C9
  DEFW $C900
  DEFW $00D6
  DEFW $7C6F
  DEFW $00DE
  DEFW $7867
  DEFW $00DE
  DEFW $3E47
  DEFW $C900
  DEFW $0000
  DEFW $3500
  DEFW $CA4A
  DEFW $3999
  DEFW $761C
  DEFW $2298
  DEFW $B395
  DEFW $0A98
  DEFW $47DD
  DEFW $5398
  DEFW $99D1
  DEFW $0A99
  DEFW $9F1A
  DEFW $6598
  DEFW $CDBC
  DEFW $D698
  DEFW $3E77
  DEFW $5298
  DEFW $4FC7
  DEFW $DB80
  DEFW $C900
  DEFW $003A
  DEFW $0000
  DEFW $0000
  DEFW $0000
  DEFW __IF
  DEFW $FA00
  DEFW $FEFB
  DEFW $97FF
  DEFW $00FB
  DEFB 0



; Message at 1292
ERR_MSG:
  DEFM " Error"
  DEFB $00
;$0513
IN_MSG:
  DEFM " in "

; Data block at 1303
NULL_STRING:
  DEFB $00

; Message at 1304
OK_MSG:
  DEFM "Ok"
  DEFB $0D
  DEFB $0A
  DEFB $00
  
BREAK_MSG:
  DEFM "Break"
  DEFB $00

; Routine at 1315
;
; Used by the routines at ULERR and CHKSTK.
L0523:
  LD HL,$0004
  ADD HL,SP
; This entry point is used by the routine at __FOR.
NEXT_UNSTACK_0:
  LD A,(HL)
  INC HL
  CP $82
  RET NZ
  LD C,(HL)
  INC HL
  LD B,(HL)
  INC HL
  PUSH HL
  LD H,B
  LD L,C
  LD A,D
  OR E
  EX DE,HL
  JP Z,L0523_1
  EX DE,HL
  RST $18
L0523_1:
  LD BC,$000E
  POP HL
  RET Z
  ADD HL,BC
  JP NEXT_UNSTACK_0
  
; This entry point is used by the routine at __MERGE.
L0523_2:
  LD BC,RESTART
; This entry point is used by the routine at ISFLIO.
L0523_3:
  JP JPBC
  
; This entry point is used by the routine at __FOR.
L0523_4:
  LD HL,(CURLIN)
  LD A,H
  AND L
  INC A
  JP Z,BASIC_MAIN_1
  LD A,($FADA)
  OR A
  LD E,$13
  JP NZ,ERROR
BASIC_MAIN_1:
  JP __END_1
  JP ERROR


; 'SN err' entry for Input STMT
;
; Used by the routine at __DATA.
DATSNR:
  LD HL,(DATLIN)
  LD (CURLIN),HL

; entry for '?SN ERROR'
;
; Used by the routines at SYNCHR, __FOR, __DATA, EVAL_04, GETWORD, CHKSTK,
; GETVAR, SCPTLP and GET_DEVICE.
SNERR:
  LD E,$02
  LD BC,$3B1E
  LD BC,$191E
  LD BC,$0B1E
  LD BC,$011E
  LD BC,$0A1E
  LD BC,$141E
  LD BC,$061E
  LD BC,$161E
  LD BC,$0D1E
  
; This entry point is used by the routines at TOKEN_BUILT, __FOR, ULERR,
; __DATA, FDTLP, GETWORD, TSTOPL, TESTR, CONCAT, CHKSTK, SCPTLP and GET_DEVICE.
ERROR:
  XOR A
  LD (NLONLY),A
  LD HL,(VLZADR)
  LD A,H
  OR L
  JP Z,SNERR_1
  LD A,(VLZDAT)
  LD (HL),A
  LD HL,$0000
  LD (VLZADR),HL
SNERR_1:
  EI
  LD HL,(ERRTRP)
  PUSH HL
  LD A,H
  OR L
  RET NZ
  LD HL,(CURLIN)
  LD (ERRLIN),HL
  LD A,H
  AND L
  INC A
  JP Z,ERROR_2
  LD (DOT),HL
; This entry point is used by the routine at __DATA.
ERROR_2:
  LD BC,L05BB
  LD HL,(SAVSTK)
  JP WARM_ENTRY
  
L05BB:
  POP BC
  LD A,E
  LD C,E
  LD (ERR_CODE),A
  LD HL,(SAVTXT)
  LD (ERRTXT),HL
  EX DE,HL
  LD HL,(ERRLIN)
  LD A,H
  AND L
  INC A
  JP Z,SNERR_3
  LD (OLDLIN),HL
  EX DE,HL
  LD (OLDTXT),HL
SNERR_3:
  LD HL,(ONELIN)
  LD A,H
  OR L
  EX DE,HL
  LD HL,ONEFLG		; =1 if executing an error trap routine
  JP Z,ERROR_REPORT
  AND (HL)
  JP NZ,ERROR_REPORT
  ; We get here if the standard error handling is temporairly disabled (error trap).
  DEC (HL)
  EX DE,HL
  JP EXEC_EVAL_0_1
  
ERROR_REPORT:
  XOR A
  LD (HL),A
  LD E,C
  CALL CONSOLE_CRLF
  CALL HERRP			; Hook 1 for Error Handler
  LD A,E
  CP $3C
  JP NC,UNKNOWN_ERR 	; JP if error code is bigger than $3B
  CP $32
  JP NC,SUB_18_ERR 		; JP if error code is between $33 and $3B
  CP $1A
  JP C,SNERR_7		; JP if error code is < $1A
  
UNKNOWN_ERR:
  LD A,$2D		; if error code is bigger than $3B then force it to ("Unprintable error")
SUB_18_ERR:
  SUB $18		; JP if error code is between $33 and $3B, sub $18
  LD E,A
SNERR_7:
  LD D,$00
  LD HL,ERRMSG-2
  ADD HL,DE
  ADD HL,DE
  LD A,$3F 		; '?'
  RST OUTC
  LD A,(HL)
  RST OUTC
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  RST OUTC
  LD HL,ERR_MSG
  PUSH HL
  LD HL,(ERRLIN)
  EX (SP),HL
; This entry point is used by the routine at CHKSTK.
SNERR_8:
  CALL PRS
  POP HL
  LD A,H
  AND L
  INC A
  CALL NZ,LNUM_MSG
  LD A,$C1

; Routine at 1580
;
; Used by the routines at GETWORD, CHKSTK and ISFLIO.
RESTART:
  POP BC
; This entry point is used by the routines at MAKINT, GETWORD and GET_DEVICE.
READY:
  CALL INIT_OUTPUT
  CALL SCPTLP_104
  CALL CONSOLE_CRLF
  LD HL,OK_MSG
  CALL PRS
  
; This entry point is used by the routine at SCPTLP.
PROMPT:
  LD HL,$FFFF
  LD (CURLIN),HL
  LD HL,ENDPRG
  LD (SAVTXT),HL
  CALL ERAEOL1
  JP C,PROMPT
; Perform operation in (HL) buffer and return to BASIC ready.
EXEC_HL:
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  INC A
  DEC A
  JP Z,PROMPT
  PUSH AF
  CALL LNUM_PARM_0
  JP NC,EXEC_HL_0
  CALL ISFLIO
  JP Z,SNERR
EXEC_HL_0:
  CALL EXEC_HL_SUB
  LD A,(HL)
  CP ' '
  CALL Z,INCHL
  PUSH DE
  CALL TOKENIZE
  POP DE
  POP AF
  LD (SAVTXT),HL
  JP NC,INIT_PRINT_h_2
  PUSH DE
  PUSH BC
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  OR A
  PUSH AF
  EX DE,HL
  LD (DOT),HL
  EX DE,HL
  CALL FIRST_LNUM		; Get first line number
  JP C,EXEC_HL_1
  POP AF
  PUSH AF
  JP Z,ULERR			; Error: "Undefined line number"
  OR A
EXEC_HL_1:
  PUSH BC
  PUSH AF
  PUSH HL
  CALL EXEC_HL_FLIO
  POP HL
  POP AF
  POP BC
  PUSH BC
  JP NC,EXEC_HL_2
  CALL DETOKEN_NEXT5
  LD A,C
  SUB E
  LD C,A
  LD A,B
  SBC A,D
  LD B,A
  CALL GETWORD_256
  LD HL,(CO_FILES)
  ADD HL,BC
  LD (CO_FILES),HL
  LD HL,(RAM_FILES)
  ADD HL,BC
  LD (RAM_FILES),HL
EXEC_HL_2:
  POP DE
  POP AF
  PUSH DE
  JP Z,SNERR_15
  POP DE
  LD HL,$0000
  LD (ONELIN),HL
  LD HL,(PROGND)
  EX (SP),HL
  POP BC
  PUSH HL
  ADD HL,BC
  PUSH HL
  CALL __POS_1
  POP HL
  LD (PROGND),HL
  EX DE,HL
  LD (HL),H
  POP BC
  POP DE
  PUSH HL
  INC HL
  INC HL
  LD (HL),E
  INC HL
  LD (HL),D
  INC HL
  LD DE,KBUF
  PUSH HL
  CALL GETWORD_256
  LD HL,(CO_FILES)
  ADD HL,BC
  LD (CO_FILES),HL
  LD HL,(RAM_FILES)
  ADD HL,BC
  LD (RAM_FILES),HL
  POP HL
  DEC BC
  DEC BC
  DEC BC
  DEC BC
SNERR_14:
  LD A,(DE)
  LD (HL),A
  INC HL
  INC DE
  DEC BC
  LD A,C
  OR B
  JP NZ,SNERR_14
SNERR_15:
  POP DE
  CALL UPD_PTRS_0
  LD HL,(PTRFIL)
  LD (TEMP2),HL
  CALL RUN_FST
  LD HL,(TEMP2)
  LD (PTRFIL),HL			; Redirect I/O
  JP PROMPT
; This entry point is used by the routines at GETWORD, CHKSTK and GET_DEVICE.
UPD_PTRS:
  LD HL,(BASTXT)
  EX DE,HL
; This entry point is used by the routine at GETWORD.
UPD_PTRS_0:
  LD H,D
  LD L,E
  LD A,(HL)
  INC HL
  OR (HL)
  RET Z
  INC HL
  INC HL
SNERR_18:
  INC HL
  LD A,(HL)
SNERR_19:
  OR A
  JP Z,ERROR_20
  CP ' '
  JP NC,SNERR_18
  CP $0B
  JP C,SNERR_18
  CALL __FOR_12
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JP SNERR_19
ERROR_20:
  INC HL
  EX DE,HL
  LD (HL),E
  INC HL
  LD (HL),D
  JP UPD_PTRS_0
  
; This entry point is used by the routine at MAKINT.
LNUM_RANGE:
  LD DE,$0000
  PUSH DE
  JP Z,$0750
  POP DE
  CALL __FOR_33
  PUSH DE
  JP Z,ERROR_22
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  CALL P,TEL_TERM_015
  RST $38
  CALL NZ,__FOR_33
  JP NZ,SNERR

ERROR_22:
  EX DE,HL
  POP DE
; This entry point is used by the routine at __DATA.
PHL_FIND_LINE:
  EX (SP),HL
  PUSH HL
; This entry point is used by the routines at __FOR, GETWORD and CHKSTK.
FIRST_LNUM:
  LD HL,(BASTXT)
; This entry point is used by the routine at __FOR.
FIND_LINE_FHL:
  LD B,H
  LD C,L
  LD A,(HL)
  INC HL
  OR (HL)
  DEC HL
  RET Z
  INC HL
  INC HL
  LD A,(HL)
  INC HL
  LD H,(HL)
  LD L,A
  RST CPDEHL
  LD H,B
  LD L,C
  LD A,(HL)
  INC HL
  LD H,(HL)
  LD L,A
  CCF
  RET Z
  CCF
  RET NC
  JP FIND_LINE_FHL

TOKENIZE:
  XOR A
  LD (DONUM),A
  LD (OPRTYP),A
  LD BC,$013B		; $01, $3b
  LD DE,KBUF

; This entry point is used by the routine at TOKEN_BUILT.
TOKENIZE_NEXT:
  LD A,(HL)
  OR A
  JP NZ,TOKENIZE_2
  
TOKENIZE_END:
  LD HL,$0140		; $01, $40
  LD A,L
  SUB C
  LD C,A
  LD A,H
  SBC A,B
  LD B,A
  LD HL,BUFFER
  XOR A
  LD (DE),A
  INC DE
  LD (DE),A
  INC DE
  LD (DE),A
  RET

TOKENIZE_2:
  CP '"'
  JP Z,TOKENIZE_8
  CP ' '
  JP Z,TOKENIZE_3
  LD A,(OPRTYP)
  OR A
  LD A,(HL)
  JP Z,TOKENIZE_11
; This entry point is used by the routine at TOKEN_BUILT.
TOKENIZE_3:
  INC HL
  PUSH AF
  CALL TOKENIZE_ADD
  POP AF
  SUB $3A	; ':'
  JP Z,HAVE_TOKEN
  CP $4A	; $4A + $3A = $84 -> TK_DATA
  JP NZ,TOKENIZE_6
  LD A,$01
HAVE_TOKEN:
  LD (OPRTYP),A		; Indicates whether stored word can be crunched
  LD (DONUM),A
TOKENIZE_6:
  SUB $55	; $55 + $3A = $8F  -> TK_REM
  JP NZ,TOKENIZE_NEXT
  PUSH AF
TOKENIZE_7:
  LD A,(HL)
  OR A
  EX (SP),HL
  LD A,H
  POP HL
  JP Z,TOKENIZE_END
  CP (HL)
  JP Z,TOKENIZE_3

TOKENIZE_8:
  PUSH AF
  LD A,(HL)
; This entry point is used by the routine at TOKEN_BUILT.
TOKENIZE_10:
  INC HL
  CALL TOKENIZE_ADD
  JP TOKENIZE_7

TOKENIZE_11:
  INC HL
  OR A
  JP M,TOKENIZE_NEXT
  DEC HL
  CP '?'
  LD A,$91		; TK_PRINT
  PUSH DE
  PUSH BC
  JP Z,TOKEN_FOUND
  LD DE,OPR_TOKENS
  CALL UCASE_HL
  CALL IS_ALPHA_A
  JP C,TOKEN_BUILT_2
  PUSH HL
  LD HL,WORD_PTR
  SUB $41
  ADD A,A
  LD C,A
  LD B,$00
  ADD HL,BC
  LD E,(HL)
  INC HL
  LD D,(HL)
  POP HL
  INC HL
TOKENIZE_13:
  PUSH HL
TOKENIZE_14:
  CALL UCASE_HL
  LD C,A
  LD A,(DE)
  AND $7F
  JP Z,TOKEN_BUILT_14
  INC HL
  CP C
  JP NZ,TOKENIZE_15
  LD A,(DE)
  INC DE
  OR A
  JP P,TOKENIZE_14
  POP AF
  LD A,(DE)
  OR A
  JP M,TOKENIZE_17
  POP BC
  POP DE
  OR $80
  PUSH AF
  LD A,$FF
  CALL TOKENIZE_ADD
  XOR A
  LD (DONUM),A
  POP AF
  CALL TOKENIZE_ADD
  JP TOKENIZE_NEXT

TOKENIZE_15:
  POP HL
TOKENIZE_16:
  LD A,(DE)
  INC DE
  OR A
  JP P,TOKENIZE_16
  INC DE
  JP TOKENIZE_13

TOKENIZE_17:
  DEC HL
TOKEN_FOUND:
  PUSH AF
  LD DE,LNUM_TOKENS
  LD C,A
TOKENIZE_19:
  LD A,(DE)
  OR A
  JP Z,TOKEN_BUILT
  INC DE
  CP C
  JP NZ,TOKENIZE_19
  JP TOKENIZE_LNUM
  
; Message at 2143
LNUM_TOKENS:
  DEFB $8C	; TK_RESTORE
  DEFB $AA	; TK_RENUM
  DEFB $BB	; TK_EDIT
  DEFB $A7	; TK_RESUME
  DEFB $DF	; TK_ERL
  DEFB $A1	; TK_ELSE
  DEFB $8A	; TK_RUN
  DEFB $93	; TK_LIST
  DEFB $9E	; TK_LLIST
  DEFB $89	; TK_GOTO
  DEFB $8E	; TK_RETURN
  DEFB $D8	; TK_THEN
  DEFB $8D	; TK_GOSUB
  DEFB $00

; This entry point is used by the routine at TOKENIZE.
TOKEN_BUILT:
  XOR A
  defb $C2	; JP NZ,NN (always false), masks the next 2 bytes
TOKENIZE_LNUM:
  LD A,1
  
TOKEN_BUILT_0:
  LD (DONUM),A
  POP AF
TOKEN_BUILT_1:
  POP BC
  POP DE
  CP $A1		; TK_ELSE
  PUSH AF
  CALL Z,TOKENIZE_COLON
  POP AF
  CP $E4		; (TK_APOSTROPHE) COMMENT, check if line ends with the apostrophe..
  JP NZ,TOKENIZE_3
  PUSH AF
  CALL TOKENIZE_COLON
  LD A,$8F
  CALL TOKENIZE_ADD
  POP AF
  PUSH HL
  LD HL,$0000
  EX (SP),HL
  JP TOKENIZE_10
  
; This entry point is used by the routine at SNERR.
TOKEN_BUILT_2:
  LD A,(HL)
  CP '.'
  JP Z,TOKEN_BUILT_3
  CP '9'+1
  JP NC,TOKEN_BUILT_10
  CP '0'
  JP C,TOKEN_BUILT_10
TOKEN_BUILT_3:
  LD A,(DONUM)
  OR A
  LD A,(HL)
  POP BC
  POP DE
  JP M,TOKENIZE_3
  JP Z,TOKEN_BUILT_6
  CP '.'
  JP Z,TOKENIZE_3
  LD A,$0E				; Line number prefix
  CALL TOKENIZE_ADD
  PUSH DE
  CALL LNUM_PARM_0		; Get specified line number
  CALL EXEC_HL_SUB
  EX (SP),HL
  EX DE,HL
TOKEN_BUILT_4:
  LD A,L
  CALL TOKENIZE_ADD
  LD A,H
TOKEN_BUILT_5:
  POP HL
  CALL TOKENIZE_ADD
  JP TOKENIZE_NEXT

TOKEN_BUILT_6:
  PUSH DE
  PUSH BC
  LD A,(HL)
  CALL DBL_ASCTFP
  CALL EXEC_HL_SUB
  POP BC
  POP DE
  PUSH HL
  LD A,(VALTYP)
  CP $02
  JP NZ,TOKEN_BUILT_7
  LD HL,(DBL_FPREG)
  LD A,H
  OR A
  LD A,$02
  JP NZ,TOKEN_BUILT_7
  LD A,L
  LD H,L
  LD L,$0F
  CP $0A
  JP NC,TOKEN_BUILT_4
  ADD A,$11
  JP TOKEN_BUILT_5
TOKEN_BUILT_7:
  PUSH AF
  RRCA
  ADD A,$1B
  CALL TOKENIZE_ADD
  LD HL,DBL_FPREG
  RST GETYPR 		; Get the number type (FAC)
  JP C,TOKEN_BUILT_8
  LD HL,$FB24
TOKEN_BUILT_8:
  POP AF
TOKEN_BUILT_9:
  PUSH AF
  LD A,(HL)
  CALL TOKENIZE_ADD
  POP AF
  INC HL
  DEC A
  JP NZ,TOKEN_BUILT_9
  POP HL
  JP TOKENIZE_NEXT

TOKEN_BUILT_10:
  LD DE,OPR_TOKENS-1
TOKEN_BUILT_11:
  INC DE
  LD A,(DE)
  AND $7F
  JP Z,TOKEN_BUILT_15
  INC DE
  CP (HL)
  LD A,(DE)
  JP NZ,TOKEN_BUILT_11
  JP TOKEN_BUILT_16

TOKENIZE_COLON:
  LD A,':'
; This entry point is used by the routine at SNERR.
TOKENIZE_ADD:
  LD (DE),A
  INC DE
  DEC BC
  LD A,C
  OR B
  RET NZ
  LD E,$17
  JP ERROR

; This entry point is used by the routine at SNERR.
TOKEN_BUILT_14:
  POP HL
  DEC HL
  DEC A
  LD (DONUM),A
  CALL UCASE_HL
  JP TOKEN_BUILT_1
TOKEN_BUILT_15:
  LD A,(HL)
  CP ' '
  JP NC,TOKEN_BUILT_16
  CP $09
  JP Z,TOKEN_BUILT_16
  CP $0A
  JP Z,TOKEN_BUILT_16
  LD A,' '
TOKEN_BUILT_16:
  PUSH AF
  LD A,(DONUM)
  INC A
  JP Z,TOKEN_BUILT_17
  DEC A
TOKEN_BUILT_17:
  JP TOKEN_BUILT_0
  
; This entry point is used by the routine at SNERR.
EXEC_HL_SUB:
  DEC HL
  LD A,(HL)
  CP ' '
  JP Z,EXEC_HL_SUB
  CP $09
  JP Z,EXEC_HL_SUB
  CP $0A
  JP Z,EXEC_HL_SUB
  INC HL
  RET

; 'FOR' BASIC instruction
__FOR:
  LD A,$64
  LD (SUBFLG),A
  CALL __LET
  POP BC
  PUSH HL
  CALL __DATA
  LD ($FAC5),HL
  LD HL,$0002
  ADD HL,SP
__FOR_0:
  CALL $0527
  JP NZ,$09AD
  ADD HL,BC
  PUSH DE
  DEC HL
  LD D,(HL)
  DEC HL
  LD E,(HL)
  INC HL
  INC HL
  PUSH HL
  LD HL,($FAC5)
  RST CPDEHL
  POP HL
  POP DE
  JP NZ,__FOR_0
  POP DE
  LD SP,HL
  LD (SAVSTK),HL
  LD C,$D1
  EX DE,HL
  LD C,$08
  CALL CHKSTK
  PUSH HL
  LD HL,($FAC5)
  EX (SP),HL
  PUSH HL
  LD HL,(CURLIN)
  EX (SP),HL
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  RST GETYPR 		; Get the number type (FAC)
  JP Z,TMERR
  JP NC,TMERR
  PUSH AF
  CALL EVAL
  POP AF
  PUSH HL
  JP P,__FOR_1
  CALL __CINT
  EX (SP),HL
  LD DE,$0001
  LD A,(HL)
  CP $DA			; TK_STEP
  CALL Z,FPSINT
  PUSH DE
  PUSH HL
  EX DE,HL
  CALL _SGN_RESULT
  JP __FOR_2
__FOR_1:
  CALL __CSNG
  CALL BCDEFP
  POP HL
  PUSH BC
  PUSH DE
  LD BC,$8100
  LD D,C
  LD E,D
  LD A,(HL)
  CP $DA			; TK_STEP
  LD A,$01
  JP NZ,__FOR_3
  CALL EVAL_0
  PUSH HL
  CALL __CSNG
  CALL BCDEFP
  RST TSTSGN
__FOR_2:
  POP HL
__FOR_3:
  PUSH BC
  PUSH DE
  OR A
  JP NZ,__FOR_4
  LD A,$02
__FOR_4:
  LD C,A
  RST GETYPR 		; Get the number type (FAC)
  LD B,A
  PUSH BC
  PUSH HL
  LD HL,(TEMP)
  EX (SP),HL
; This entry point is used by the routine at CHKSTK.
__FOR_5:
  LD B,$82
  PUSH BC
  INC SP
  
; This entry point is used by the routines at GETWORD, CHKSTK, ISFLIO and
; GET_DEVICE.
EXEC_EVAL_0:
  CALL TEL_TERM_008
  CALL RCVX
  CALL NZ,RUN_FST3
; This entry point is used by the routine at GETWORD.
EXEC_EVAL_00:
  CALL CHSNS_0
  LD (SAVTXT),HL
  EX DE,HL
  LD HL,$0000
  ADD HL,SP
  LD (SAVSTK),HL
  EX DE,HL
  LD A,(HL)
  CP $3A
  JP Z,EXEC
  OR A
  JP NZ,SNERR
  INC HL
; This entry point is used by the routine at SNERR.
EXEC_EVAL_0_1:
  LD A,(HL)
  INC HL
  OR (HL)
  JP Z,WORDS_3
  INC HL
  LD E,(HL)
  INC HL
  LD D,(HL)
  EX DE,HL
  LD (CURLIN),HL
  EX DE,HL
  
; This entry point is used by the routine at SCPTLP.
EXEC:
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  LD DE,EXEC_EVAL_0
  PUSH DE
  RET Z
; This entry point is used by the routine at __DATA.
__FOR_10:
  CP $EA			; TK_TIME
  JP Z,TIME
  CP $EB			; TK_DATE
  JP Z,DATE
  SUB $81			; Normal Alphanum sequence ?
  JP C,__LET		; Ok, assume an implicit "LET" statement
  CP $55			;TK_TO-$81
  JP NC,SNERR
  RLCA
  LD C,A
  LD B,$00
  EX DE,HL
  LD HL,($F3C4)		; FNCTAB JP table
  ADD HL,BC
  LD C,(HL)
  INC HL
  LD B,(HL)
  PUSH BC
  EX DE,HL

; This entry point is used by the routines at SYNCHR, __DATA, DTSTR and SCPTLP.
_CHRGTB:
  INC HL
; This entry point is used by the routine at SNERR.
__FOR_12:
  LD A,(HL)
  CP $3A
  RET NC
  CP ' '
  JP Z,_CHRGTB
  JP NC,__FOR_22
  OR A
  RET Z
  CP $0B
  JP C,__FOR_21
  CP $0D
  JP NC,__FOR_13
  LD A,$1C
__FOR_13:
  CP $1E
  JP NZ,__FOR_14
  LD A,(CONSAV)
  OR A
  RET
__FOR_14:
  CP $10
  JP Z,__FOR_19
  PUSH AF
  INC HL
  LD (CONSAV),A
  SUB $1C
  JP NC,__FOR_20
  SUB $F5
  JP NC,__FOR_15
  CP $FE
  JP NZ,__FOR_17
  LD A,(HL)
  INC HL
__FOR_15:
  LD (CONTXT),HL
  LD H,$00
__FOR_16:
  LD L,A
  LD (CONLO),HL
  LD A,$02
  LD (CONTYP),A
  LD HL,$0B05
  POP AF
  OR A
  RET
__FOR_17:
  LD A,(HL)
  INC HL
  INC HL
  LD (CONTXT),HL
  DEC HL
  LD H,(HL)
  JP __FOR_16
; This entry point is used by the routine at OPRND.
__FOR_18:
  CALL __FOR_23
__FOR_19:
  LD HL,(CONTXT)
  JP __FOR_12
__FOR_20:
  INC A
  RLCA
  LD (CONTYP),A
  PUSH DE
  PUSH BC
  LD DE,CONLO
  EX DE,HL
  LD B,A
  CALL REV_LDIR_B
  EX DE,HL
  POP BC
  POP DE
  LD (CONTXT),HL
  POP AF
  LD HL,$0B05
  OR A
  RET
__FOR_21:
  CP $09
  JP NC,_CHRGTB
__FOR_22:
  CP '0'
  CCF
  INC A
  DEC A
  RET

  LD E,$10
; This entry point is used by the routine at MAKINT.
__FOR_23:
  LD A,(CONSAV)
  CP $0F			; Prefix for Integer 10 to 255 ?
  JP NC,__FOR_25
  CP $0C+1
  JP C,__FOR_25			; JP if Prefix for Hex or Octal number
  LD HL,(CONLO)			; Value of stored constant
  JP NZ,__FOR_24
  INC HL
  INC HL
  INC HL
  LD E,(HL)
  INC HL
  LD D,(HL)
  EX DE,HL
__FOR_24:
  JP DBL_ABS_0
  
__FOR_25:
  LD A,(CONTYP)			; Type of stored constant
  LD (VALTYP),A
  CP $08
  JP Z,__FOR_26
  LD HL,(CONLO)			; Value of stored constant
  LD (DBL_FPREG),HL
  LD HL,(CONLO+2)
  LD (LAST_FPREG),HL
  RET

__FOR_26:
  LD HL,CONLO
  JP LOADFP_7
  

__DEFSTR:
  LD E,$03

  DEFB $01	; "LD BC,nn" to jump over the next word without executing it

__DEFINT:
  LD E,$02	; Integer type
  
  DEFB $01	; "LD BC,nn" to jump over the next word without executing it

__DEFSNG:
  LD E,$04	; Single precision type

  DEFB $01	; "LD BC,nn" to jump over the next word without executing it

__DEFDBL:
  LD E,$08	; Double Precision type

DEFVAL:
  CALL IS_ALPHA  		; Load A with char in (HL) and check it is a letter
  LD BC,SNERR
  PUSH BC
  RET C
  SUB $41
  LD C,A
  LD B,A
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  CP $F4		; TK_MINUS, '-'
  JP NZ,__FOR_28
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  CALL IS_ALPHA  		; Load A with char in (HL) and check it is a letter
  RET C
  SUB $41
  LD B,A
  RST CHRGTB		; Gets next character (or token) from BASIC text.
__FOR_28:
  LD A,B
  SUB C
  RET C
  INC A
  EX (SP),HL
  LD HL,$FAED
  LD B,$00
  ADD HL,BC
DEFVAL_1:
  LD (HL),E
  INC HL
  DEC A
  JP NZ,DEFVAL_1
  POP HL
  LD A,(HL)
  CP ','
  RET NZ
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JP DEFVAL

; This entry point is used by the routine at SCPTLP.
GET_POSINT:
  RST CHRGTB		; Gets next character (or token) from BASIC text.
; This entry point is used by the routine at CHKSTK.
__FOR_31:
  CALL FPSINT_0
  RET P
; This entry point is used by the routines at __DATA, MAKINT, GETWORD, GSTRDE,
; TOPOOL, MIDNUM, __LOG, CHKSTK, SCPTLP and GET_DEVICE.
FCERR:
  LD E,$05
  JP ERROR
; This entry point is used by the routines at SNERR and GETWORD.
__FOR_33:
  LD A,(HL)
  CP '.'
  EX DE,HL
  LD HL,(DOT)
  EX DE,HL
  JP Z,_CHRGTB

; This entry point is used by the routines at SNERR, TOKEN_BUILT, __DATA,
; GETWORD and CHKSTK.
; Get specified line number
; ASCII to Integer, result in DE
LNUM_PARM_0:
  DEC HL
; This entry point is used by the routine at __DATA.
LNUM_PARM_1::
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  CP $0E			; Line number prefix
  JP Z,__FOR_36
  CP $0D
; This entry point is used by the routine at GETWORD.
__FOR_36:
  EX DE,HL
  LD HL,(CONLO)
  EX DE,HL
  JP Z,_CHRGTB
  XOR A
  LD (CONSAV),A
  LD DE,$0000
  DEC HL
__FOR_37:
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  RET NC
  PUSH HL
  PUSH AF
  LD HL,$1998
  RST CPDEHL
  JP C,__FOR_38
  LD H,D
  LD L,E
  ADD HL,DE
  ADD HL,HL
  ADD HL,DE
  ADD HL,HL
  POP AF
  SUB $30
  LD E,A
  LD D,$00
  ADD HL,DE
  EX DE,HL
  POP HL
  JP __FOR_37
__FOR_38:
  POP AF
  POP HL
  RET
  
__RUN:
  JP Z,RUN_FST
  CP $0E			; Line number prefix
  JP Z,__RUN_0
  CP $0D		; CR
  JP NZ,_LOAD
__RUN_0:
  CALL _CLVAR
  LD BC,EXEC_EVAL_0
  JP GO_TO

__GOSUB:
  LD C,$03
  CALL CHKSTK
  CALL LNUM_PARM_0
  POP BC
  PUSH HL
  PUSH HL
  LD HL,(CURLIN)
  EX (SP),HL
  LD BC,$0000
  PUSH BC
  LD BC,EXEC_EVAL_0
  LD A,$8D
  PUSH AF
  INC SP
  PUSH BC
  JP __GO_TO_0
; This entry point is used by the routine at CHKSTK.
__FOR_40:
  PUSH HL
  PUSH HL
  LD HL,(CURLIN)
  EX (SP),HL
  PUSH BC
  LD A,$8D
  PUSH AF
  INC SP
  EX DE,HL
  DEC HL
  LD (SAVTXT),HL
  INC HL
  JP EXEC_EVAL_0_1
  
GO_TO:
  PUSH BC
; This entry point is used by the routines at ULERR and __DATA.
__GO TO:
  CALL LNUM_PARM_0
; This entry point is used by the routine at __DATA.
__GO_TO_0:
  LD A,(CONSAV)
  CP $0D
  EX DE,HL
  RET Z
  CP $0E			; Line number prefix
  JP NZ,SNERR
  EX DE,HL
  PUSH HL
  LD HL,(CONTXT)
  EX (SP),HL
  CALL __DATA+2		; 'Move to next line' (used by ELSE, REM..)
  INC HL
  PUSH HL
  LD HL,(CURLIN)
  RST CPDEHL
  POP HL
  CALL C,FIND_LINE_FHL
  CALL NC,FIRST_LNUM	; Get first line number
  JP NC,ULERR			; Error: "Undefined line number"
  DEC BC
  LD A,$0D
  LD (PTRFLG),A
  POP HL
  CALL GETWORD_18
  LD H,B
  LD L,C
  RET

; entry for '?UL ERROR'
;
; Used by the routines at SNERR, __FOR, __DATA and CHKSTK.
ULERR:
  LD E,$08
  JP ERROR
  
__RETURN:
  LD (TEMP),HL
  LD D,$FF
  CALL NEXT_UNSTACK			; search FOR block on stack (skip 2 words)
  CP $8D
  JP Z,ULERR			; Error: "Undefined line number"_0
  DEC HL
ULERR_0:
  LD SP,HL
  LD (SAVSTK),HL
  LD E,$03				; Err $03 - RETURN without GOSUB
  JP NZ,ERROR
  
  POP HL
  LD A,H
  OR L
  JP Z,ULERR			; Error: "Undefined line number"_1
  LD A,(HL)
  AND $01
  CALL NZ,TIME_S_STOP_1
ULERR_1:
  POP BC
  LD HL,EXEC_EVAL_0
  EX (SP),HL
  EX DE,HL
  LD HL,(TEMP)
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JP NZ,__GO TO
  
  LD H,B
  LD L,C
  LD (CURLIN),HL
  EX DE,HL

  DEFB $3E  ; "LD A,n" to Mask the next byte

  POP HL

; DATA statement: find next DATA program line..
;
; Used by the routines at __FOR and FDTLP.
__DATA:
  LD BC,$0E3A		; Put ':' in C, $0E in B

; Used by 'REM', 'ELSE' and error handling code.
; __DATA+2:
; LD C,0		; Put $00 in C

  NOP
  LD B,$00
__DATA_0:
  LD A,C
  LD C,B
  LD B,A
__DATA_1:
  DEC HL
__DATA_2:
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  OR A
  RET Z
  CP B
  RET Z
  INC HL
  CP '"'
  JP Z,__DATA_0
  INC A
  JP Z,__DATA_2
  SUB $8C
  JP NZ,__DATA_1
  CP B
  ADC A,D
  LD D,A
  JP __DATA_1
  POP AF
  ADD A,$03
  JP __DATA_3

; This entry point is used by the routine at __FOR.
__LET:
  CALL GETVAR
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  POP AF
  EX DE,HL
  LD (TEMP),HL
  EX DE,HL
  PUSH DE
  LD A,(VALTYP)
  PUSH AF
  CALL EVAL
  POP AF
__DATA_3:
  EX (SP),HL
__DATA_4:
  LD B,A
  LD A,(VALTYP)
  CP B
  LD A,B
  JP Z,__DATA_5
  CALL OPRND_3_05
  LD A,(VALTYP)
__DATA_5:
  LD DE,DBL_FPREG
  CP $05
  JP C,__DATA_6
  LD DE,$FB24
__DATA_6:
  PUSH HL
  CP $03				; String ?
  JP NZ,LETNUM
  LD HL,(DBL_FPREG)		; Pointer to string entry
  PUSH HL				; Save it on stack
  INC HL				; Skip over length
  LD E,(HL)				; LSB of string address
  INC HL
  LD D,(HL)				; MSB of string address
  LD HL,BUFFER
  RST CPDEHL			; Compare HL with DE.. is string before program?
  JP C,$0D10
  LD HL,(ARREND)
  RST CPDEHL			; Compare HL with DE.. is string literal in program?
  POP DE
  JP NC,MVSTPT			; Yes - Set up pointer
  LD HL,VARIABLES+15	; .. on MSX it is = VARIABLES+14
  RST CPDEHL
  JP C,__DATA_7
  LD HL,VARIABLES-15	; .. on MSX it is = VARIABLES-16
  RST CPDEHL
  JP C,MVSTPT
  
__DATA_7:
  ;LD A,$D1
  DEFB $3E  ; "LD A,n" to Mask the next byte
  POP DE
  CALL BAKTMP
  EX DE,HL
  CALL SAVSTR_0
MVSTPT:
  CALL BAKTMP
  EX (SP),HL
LETNUM:
  CALL FP2HL
  POP DE
  POP HL
  RET
  

__ON:
  CP $A6		; TK_ERROR
  JP NZ,ON_OTHER

ON_ERROR:
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  ADC A,C			; DEFB TK_GOTO
  
  CALL LNUM_PARM_0
  LD A,D
  OR E
  JP Z,__ON_0
  CALL PHL_FIND_LINE		; Sink HL in stack and get first line number
  LD D,B
  LD E,C
  POP HL
  JP NC,ULERR			; Error: "Undefined line number"
__ON_0:
  EX DE,HL
  LD (ONELIN),HL
  EX DE,HL
  RET C
  LD A,(ONEFLG)		  ; =1 if executing an error trap routine
  OR A
  LD A,E
  RET Z
  LD A,(ERR_CODE)
  LD E,A
  JP ERROR_2
  
ON_OTHER:
  CALL ONGO
  JP C,__DATA_14
  PUSH BC
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  ADC A,L
  XOR A
__DATA_12:
  POP BC
  PUSH BC
  CP C
  JP NC,SNERR
  PUSH AF
  CALL LNUM_PARM_0
  LD A,D
  OR E
  JP Z,__DATA_13
  CALL PHL_FIND_LINE
  LD D,B
  LD E,C
  POP HL
  JP NC,ULERR			; Error: "Undefined line number"

__DATA_13:
  POP AF
  POP BC
  PUSH AF
  ADD A,B
  PUSH BC
  CALL GETWORD_127
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
  JP __DATA_12
  
__DATA_14:
  CALL GETINT
  LD A,(HL)
  LD B,A
  CP $8D			; TK_GOSUB
  JP Z,__DATA_15
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  ADC A,C			; DEFB TK_GOTO
  DEC HL
  
__DATA_15:
  LD C,E
__DATA_16:
  DEC C
  LD A,B
  JP Z,__FOR_10
  CALL LNUM_PARM_1:
  CP ','
  RET NZ
  JP __DATA_16
  
__RESUME:
  LD A,(ONEFLG)
  OR A
  JP NZ,__DATA_17
  LD (ONELIN),A
  LD ($FAD9),A
  JP $057A
__DATA_17:
  INC A
  LD (ERR_CODE),A
  LD A,(HL)
  CP $83
  JP Z,__DATA_18
  CALL LNUM_PARM_0
  RET NZ
  LD A,D
  OR E
  JP Z,__DATA_19
  CALL __GO_TO_0
  XOR A
  LD (ONEFLG),A
  RET
  
__DATA_18:
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  RET NZ
  JP __DATA_20
  
__DATA_19:
  XOR A
  LD (ONEFLG),A
  INC A
__DATA_20:
  LD HL,(ERRTXT)
  EX DE,HL
  LD HL,(ERRLIN)
  LD (CURLIN),HL
  EX DE,HL
  RET NZ
  LD A,(HL)
  OR A
  JP NZ,__DATA_21
  INC HL
  INC HL
  INC HL
  INC HL
__DATA_21:
  INC HL
  XOR A
  LD (ONEFLG),A
  JP __DATA
__ERROR:
  CALL GETINT
  RET NZ
  OR A
  JP Z,FCERR
  JP ERROR
  
__IF:
  CALL EVAL
  LD A,(HL)
  CP ','
  CALL Z,_CHRGTB
  CP $89			; TK_GOTO
  JP Z,__DATA_22
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  RET C				; TK_THEN
  DEC HL
__DATA_22:
  PUSH HL
  CALL _TSTSGN
  POP HL
  JP Z,__DATA_24
__DATA_23:
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  RET Z
  CP $0E			; Line number prefix
  JP Z,__GO TO
  CP $0D	;
  JP NZ,__FOR_10
  LD HL,(CONLO)
  RET
  
__DATA_24:
  LD D,$01
__DATA_25:
  CALL __DATA
  OR A
  RET Z
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  CP $A1		; TK_ELSE
  JP NZ,__DATA_25
  DEC D
  JP NZ,__DATA_25
  JP __DATA_23
  
__LPRINT:
  LD A,$01
  LD (PRTFLG),A
  JP __DATA_26

__PRINT:
  LD C,$02
  CALL SCPTLP_102
__DATA_26:
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  CALL Z,OUTDO_CRLF
__DATA_27:
  JP Z,FINPRT
  CP $E2			; TK_USING
  JP Z,USING
  CP $D9			; TK_TAB(
  JP Z,__DATA_36
  PUSH HL
  CP ','		; TAB(
  JP Z,__DATA_32
  CP ';'
  JP Z,__DATA_41
  POP BC
  CALL EVAL
  PUSH HL
  RST GETYPR 		; Get the number type (FAC)
  JP Z,__DATA_31
  CALL FOUT
  CALL CRTST
  LD (HL),' '
  LD HL,(DBL_FPREG)
  INC (HL)
  CALL ISFLIO
  JP NZ,__DATA_30
  LD HL,(DBL_FPREG)
  LD A,(PRTFLG)
  OR A
  JP Z,__DATA_28
  LD A,(LPT_POS)
  ADD A,(HL)
  CP $FF
  JP __DATA_29
__DATA_28:
  LD A,(ACTV_Y)
  LD B,A
  INC A
  JP Z,__DATA_30
  LD A,(TTYPOS)
  ADD A,(HL)
  DEC A
  CP B
__DATA_29:
  JP C,__DATA_30
  CALL Z,SCPTLP_46
  CALL NZ,OUTDO_CRLF
__DATA_30:
  CALL PRS1
  OR A
__DATA_31:
  CALL Z,PRS1
  POP HL
  JP __DATA_26
  
; TAB(
__DATA_32:
  LD BC,$0008
  LD HL,(PTRFIL)
  ADD HL,BC
  CALL ISFLIO
  LD A,(HL)
  JP NZ,__DATA_35
  LD A,(PRTFLG)
  OR A
  JP Z,__DATA_33
  LD A,(LPT_POS)
  CP $EE
  JP __DATA_34
  
__DATA_33:
  LD A,(CLMLST)
  LD B,A
  LD A,(TTYPOS)
  CP B
__DATA_34:
  CALL NC,OUTDO_CRLF
  JP NC,__DATA_41
__DATA_35:
  SUB $0E
  JP NC,__DATA_35
  CPL
  JP __DATA_39

__DATA_36:
  CALL FNDNUM
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  ADD HL,HL
  DEC HL
  PUSH HL
  JP Z,__DATA_38
  LD BC,SYNCHR
  LD HL,(PTRFIL)
  ADD HL,BC
  CALL ISFLIO
  LD A,(HL)
  JP NZ,__DATA_38
  LD A,(PRTFLG)
  OR A
  JP Z,__DATA_37
  LD A,(LPT_POS)
  JP __DATA_38
  
__DATA_37:
  LD A,(TTYPOS)
__DATA_38:
  CPL
  ADD A,E
  JP NC,__DATA_41
__DATA_39:
  INC A
  LD B,A
  LD A,' '
__DATA_40:
  RST OUTC
  DEC B
  JP NZ,__DATA_40
  
__DATA_41:
  POP HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JP __DATA_27

; This entry point is used by the routines at CHKSTK and SCPTLP.
FINPRT:
  XOR A
  LD (PRTFLG),A
  PUSH HL
  LD H,A
  LD L,A
  LD (PTRFIL),HL			; Redirect I/O
  POP HL
  RET

__LINE:
  CP $85
  JP NZ,GETWORD_140
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  CP '#'
  JP Z,SCPTLP_106
  CALL __DATA_45
  CALL GETVAR
  CALL TSTSTR
  PUSH DE
  PUSH HL
  CALL _INLIN
  POP DE
  POP BC
  JP C,$4103
  PUSH BC
  PUSH DE
  LD B,$00
  CALL QTSTR_0
  POP HL
  LD A,$03
  JP __DATA_3
  CCF
  LD D,D
  LD H,L
  LD H,H
  LD L,A
  JR NZ,$0FCA
  LD (HL),D
  LD L,A
  LD L,L
  JR NZ,$0FDC
  LD (HL),H
  LD H,C
  LD (HL),D
  LD (HL),H
  DEC C
  LD A,(BC)
  NOP

__DATA_43:
  LD A,(FLGINP)
  OR A
  JP NZ,DATSNR
  POP BC
  LD HL,$0F5D
  CALL PRS
  LD HL,(SAVTXT)
  RET

__DATA_44:
  CALL SCPTLP_101
  PUSH HL
  LD HL,BUFMIN
  JP __DATA_46

__TANUT:
  CP '#'
  JP Z,__DATA_44
  LD BC,$0FA5
  PUSH BC
__DATA_45:
  CP '"'
  LD A,$00
  RET NZ
  CALL QTSTR
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEC SP
  PUSH HL
  CALL PRS1
  POP HL
  RET

  PUSH HL
  CALL QINLIN			; User interaction with question mark, HL = resulting text 
  POP BC
  JP C,$4103
  INC HL
  LD A,(HL)
  OR A
  DEC HL
  PUSH BC
  JP Z,$0C8B
__DATA_46:
  LD (HL),$2C
  JP L0FBF
  
__READ:
  PUSH HL
  LD HL,(DATPTR)
  
  defb $f6		; OR $AF

; Routine at 3294
;
; Used by the routine at L0CC4.
L0FBF:
  XOR A
  LD (FLGINP),A
  EX (SP),HL
  JP __DATA_48
  
__DATA_47:
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
__DATA_48:
  CALL GETVAR
  EX (SP),HL
  PUSH DE
  LD A,(HL)
  CP ','
  JP Z,__DATA_49
  LD A,(FLGINP)
  OR A
  JP NZ,FDTLP
  LD A,$3F
  RST OUTC
  CALL QINLIN			; User interaction with question mark, HL = resulting text 
  POP DE
  POP BC
  JP C,$4103
  INC HL
  LD A,(HL)
  DEC HL
  OR A
  PUSH BC
  JP Z,$0C8B
  PUSH DE
; This entry point is used by the routine at FDTLP.
__DATA_49:
  CALL ISFLIO
  JP NZ,SCPTLP_105
  RST GETYPR 		; Get the number type (FAC)
  PUSH AF
  JP NZ,__DATA_52
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  LD D,A
  LD B,A
  CP '"'
  JP Z,__DATA_51
  LD A,(FLGINP)
  OR A
  LD D,A
  JP Z,__DATA_50
  LD D,$3A
__DATA_50:
  LD B,$2C
  DEC HL
__DATA_51:
  CALL DTSTR
  POP AF
  ADD A,$03
  EX DE,HL
  LD HL,$102B
  EX (SP),HL
  PUSH DE
  JP __DATA_4
__DATA_52:
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  POP AF
  PUSH AF
  LD BC,$1012
  PUSH BC
  JP C,DBL_ASCTFP
  JP DBL_DBL_ASCTFP
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JP Z,__DATA_53
  CP ','
  JP NZ,__DATA_43
__DATA_53:
  EX (SP),HL
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JP NZ,__DATA_47
  POP DE
  LD A,(FLGINP)
  OR A
  EX DE,HL
  JP NZ,RUN_FST7
  PUSH DE
  CALL ISFLIO
  JP NZ,__DATA_54
  LD A,(HL)
  OR A
  LD HL,$1057
  CALL NZ,PRS
__DATA_54:
  POP HL
  JP FINPRT
  CCF
  LD B,L
  LD A,B
  LD (HL),H
  LD (HL),D
  LD H,C
  JR NZ,EVAL_04_1
  LD H,A
  LD L,(HL)
  LD L,A
  LD (HL),D
  LD H,L
  LD H,H
  DEC C
  LD A,(BC)
  NOP

; Find next DATA statement
;
; Used by the routine at __DATA.
FDTLP:
  CALL __DATA
  OR A
  JP NZ,FDTLP_0
  INC HL
  LD A,(HL)
  INC HL
  OR (HL)
  LD E,$04
  JP Z,ERROR
  INC HL
  LD E,(HL)
  INC HL
  LD D,(HL)
  EX DE,HL
  LD (DATLIN),HL
  EX DE,HL
FDTLP_0:
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  CP $84
  JP NZ,FDTLP
  JP __DATA_49
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  POP AF
  JP EVAL

; Chk Syntax, make sure '(' follows
;
; Used by the routines at OPRND, UCASE and MIDNUM.
OPNPAR:
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  JR Z,$10BD

EVAL:
  DEC HL

; (a.k.a. GETNUM, EVAL_0uate expression (GETNUM)
;
; Used by the routines at __FOR and SCPTLP.
EVAL_0:
  LD D,$00
; This entry point is used by the routines at EVAL_04, OPRND and UCASE.
EVAL1:
  PUSH DE

; Save precedence and EVAL_0 until precedence break
EVAL2:
  LD C,$01
  CALL CHKSTK
  CALL OPRND
  LD (TEMP2),HL
; This entry point is used by the routine at UCASE.
EVAL_03:
  LD HL,(TEMP2)

; EVAL_0uate expression until precedence break
EVAL_04:
  POP BC
  LD A,(HL)
  LD (TEMP3),HL
  CP $F0		; TK_GREATER	; Token for '>'
  RET C
  CP $F3		; TK_PLUS, '+'
  JP C,EVAL_04_5
  SUB $F3
  LD E,A
  JP NZ,EVAL_04_0
  LD A,(VALTYP)
  CP $03
  LD A,E
  JP Z,CONCAT
EVAL_04_0:
  CP $0C
  RET NC
  LD HL,PRITAB
  LD D,$00
  ADD HL,DE
; This entry point is used by the routine at __DATA.
EVAL_04_1:
  LD A,B
  LD D,(HL)
  CP D
  RET NC
  PUSH BC
  LD BC,EVAL_03
  PUSH BC
  LD A,D
  CP $7F			; BS
  JP Z,EVAL_04_7
  CP $51
  JP C,EVAL_04_8
  AND $FE
  CP $7A
  JP Z,EVAL_04_8
EVAL_04_2:
  LD HL,DBL_FPREG
  LD A,(VALTYP)
  SUB $03
  JP Z,TMERR
  OR A
  LD C,(HL)
  INC HL
  LD B,(HL)
  PUSH BC
  JP M,EVAL_04_3
  INC HL
  LD C,(HL)
  INC HL
  LD B,(HL)
  PUSH BC
  JP PO,EVAL_04_3
  LD HL,$FB24
  LD C,(HL)
  INC HL
  LD B,(HL)
  INC HL
  PUSH BC
  LD C,(HL)
  INC HL
  LD B,(HL)
  PUSH BC
EVAL_04_3:
  ADD A,$03
  LD C,E
  LD B,A
  PUSH BC
  LD BC,$116A
EVAL_04_4:
  PUSH BC
  LD HL,(TEMP3)
  JP EVAL1
  
EVAL_04_5:
  LD D,$00
EVAL_04_6:
  SUB $F0
  JP C,NO_COMPARE_TK
  CP $03
  JP NC,NO_COMPARE_TK
  CP $01
  RLA
  XOR D
  CP D
  LD D,A
  JP C,SNERR
  LD (TEMP3),HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JP EVAL_04_6
  
EVAL_04_7:
  CALL __CSNG
  CALL STAKI
  LD BC,POWER
  LD D,$7F
  JP EVAL_04_4
  
EVAL_04_8:
  PUSH DE
  CALL __CINT
  POP DE
  PUSH HL
  LD BC,L1341
  JP EVAL_04_4
  
NO_COMPARE_TK:
  LD A,B
  CP $64
  RET NC
  PUSH BC
  PUSH DE
  LD DE,$6405		; const value
  LD HL,L1316
  PUSH HL
  RST GETYPR 		; Get the number type (FAC)
  JP NZ,EVAL_04_2		; JP if not string type
  LD HL,(DBL_FPREG)
  PUSH HL
  LD BC,EVAL_STR
  JP EVAL_04_4
  
  POP BC
  LD A,C
  LD (OPRTYP),A
  LD A,(VALTYP)
  CP B				; is type specified in 'B' different ?
  JP NZ,EVAL_04_10
  CP $02
  JP Z,EVAL_04_11
  CP $04
  JP Z,EVAL_04_19
  JP NC,EVAL_04_13
EVAL_04_10:
  LD D,A
  LD A,B
  CP $08			; Double precision ?
  JP Z,EVAL_04_12
  LD A,D
  CP $08			; Double precision ?
  JP Z,EVAL_04_17
  LD A,B
  CP $04			; Single precision ?
  JP Z,EVAL_04_18
  LD A,D
  CP $03			; String ?
  JP Z,TMERR		; "Type mismatch"
  JP NC,EVAL_04_21
EVAL_04_11:
  LD HL,INT_OPR
  LD B,$00
  ADD HL,BC
  ADD HL,BC
  LD C,(HL)
  INC HL
  LD B,(HL)
  POP DE
  LD HL,(DBL_FPREG)
  PUSH BC
  RET
  
EVAL_04_12:
  CALL __CDBL
EVAL_04_13:
  CALL FP_ARG2HL
  POP HL
  LD ($FB26),HL
  POP HL
  LD ($FB24),HL
EVAL_04_14:
  POP BC
  POP DE
  CALL FPBCDE
EVAL_04_15:
  CALL __CDBL
  LD HL,DEC_OPR
EVAL_04_16:
  LD A,(OPRTYP)
  RLCA
  ADD A,L
  LD L,A
  ADC A,H
  SUB L
  LD H,A
  LD A,(HL)
  INC HL
  LD H,(HL)
  LD L,A
  JP (HL)
EVAL_04_17:
  LD A,B
  PUSH AF
  CALL FP_ARG2HL
  POP AF
  LD (VALTYP),A
  CP $04
  JP Z,EVAL_04_14
  POP HL
  LD (DBL_FPREG),HL
  JP EVAL_04_15

EVAL_04_18:
  CALL __CSNG
EVAL_04_19:
  POP BC
  POP DE
EVAL_04_20:
  LD HL,FLT_OPR
  JP EVAL_04_16
EVAL_04_21:
  POP HL
  CALL STAKI
  CALL HL_CSNG
  CALL BCDEFP
  POP HL
  LD (LAST_FPREG),HL
  POP HL
  LD (DBL_FPREG),HL
  JP EVAL_04_20

; Routine at 4619
IDIV:
  PUSH HL
  EX DE,HL
  CALL HL_CSNG
  POP HL
  CALL STAKI
  CALL HL_CSNG
  JP DIV

; Get next expression value
;
; Used by the routines at EVAL1 and CONCAT.
OPRND:
  CALL TEL_TERM_003
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JP Z,$0580		; OPERAND_ERR (OPRND)
  JP C,DBL_ASCTFP
  CALL IS_ALPHA_A
  JP NC,VAR_EVAL_0
  CP ' '
  JP C,__FOR_18
  INC A
  JP Z,OPRND_SUB
  DEC A
  CP $F3		; TK_PLUS, '+'
  JP Z,OPRND
  CP $F4		; TK_MINUS, '-'
  JP Z,OPRND_SUB
  CP '"'
  JP Z,QTSTR
  CP $DE
  JP Z,NOT
  CP $E0		; Token for ERR (TK_ERR ?)
  JP NZ,OPRND_0
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  LD A,(ERR_CODE)
  PUSH HL
  CALL UNSIGNED_RESULT_A
  POP HL
  RET

OPRND_0:
  CP $DF		; TK_ERL
  JP NZ,OPRND_1

__ERL:
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  PUSH HL
  LD HL,(ERRLIN)
  CALL DBL_ABS_0
  POP HL
  RET
  
OPRND_1:
  CP $EA			; TK_TIME
  JP Z,FN_TIME
  CP $EB			; TK_DATE
  JP Z,FN_DATE
  CP $EE			; TK_STATUS
  JP Z,FN_STATUS
  CP $E3			; TK_INSTR
  JP Z,FN_INSTR
  CP $E9			; TK_INKEY_S
  JP Z,FN_INKEY
  CP $E1
  JP Z,TOPOOL_0
  CP $85
  JP Z,SCPTLP_88
  CP $E6
  JP Z,GETWORD_147
  CP $E8
  JP Z,USING5

; This entry point is used by the routine at UCASE.
OPRND_2:
  CALL OPNPAR
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  ADD HL,HL
  RET

OPRND_SUB:
  LD D,$7D
  CALL EVAL1
  LD HL,(TEMP2)		; NXTOPR,  Next operator in EVAL_0
  PUSH HL
  CALL INVSGN

; Routine at 4773
_POPHLRT:
  POP HL
  RET
  
VAR_EVAL_0:
  CALL GETVAR
  PUSH HL
  EX DE,HL
  LD (DBL_FPREG),HL
  RST GETYPR 		; Get the number type (FAC)
  CALL NZ,FP_HL2DE	; CALL if not string type
  POP HL
  RET

; Get char from (HL) and make upper case
;
; Used by the routines at SNERR, TOKEN_BUILT, GETWORD, SCPTLP and GET_DEVICE.
UCASE_HL:
  LD A,(HL)

; Make char in 'A' upper case
;
; Used by the routine at GET_DEVICE.
UCASE:
  CP $61
  RET C
  CP $7B
  RET NC
  AND $5F
  RET
; This entry point is used by the routine at OPRND.
OPRND_SUB:
  INC HL
  LD A,(HL)
  SUB $81
  LD B,$00
  RLCA
  LD C,A
  PUSH BC
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  LD A,C
  CP $05
  JP NC,OPRND_3_0
  CALL OPNPAR
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
  CALL TSTSTR
  EX DE,HL
  LD HL,(DBL_FPREG)
  EX (SP),HL
  PUSH HL
  EX DE,HL
  CALL GETINT
  EX DE,HL
  EX (SP),HL
  JP UCASE_3
  
OPRND_3_0:
  CALL OPRND_2
  EX (SP),HL
  LD A,L
  CP $0C
  JP C,OPRND_3_1
  CP $1B
  PUSH HL
  CALL C,__CSNG
  POP HL
OPRND_3_1:
  LD DE,_POPHLRT		; (POP HL / RET)
  PUSH DE
UCASE_3:
  LD B,H
  LD C,L
  LD HL,(FNCTAB_FN)			; FNCTAB_FN
UCASE_4:
  ADD HL,BC
  LD C,(HL)
  INC HL
  LD H,(HL)
  LD L,C
  JP (HL)
  
; This entry point is used by the routine at _DBL_ASCTFP.
UCASE_5:
  DEC D
  CP $F4		; TK_MINUS, '-'
  RET Z
  CP '-'
  RET Z
  INC D
  CP '+'
  RET Z
  CP $F3		; TK_PLUS, '+'
  RET Z

DCXH:
  DEC HL
  RET

L1316:
  INC A
  ADC A,A
  POP BC
  AND B
  ADD A,$FF
  SBC A,A
  CALL INT_RESULT_A
  JP NOT_0
  
; This entry point is used by the routine at OPRND.
NOT:
  LD D,$5A
  CALL EVAL1
  CALL __CINT
  LD A,L
  CPL
  LD L,A
  LD A,H
  CPL
  LD H,A
  LD (DBL_FPREG),HL
  POP BC
NOT_0:
  JP EVAL_03
  
; This entry point is used by the routine at GETYPR.
__GETYPR:
  LD A,(VALTYP)
  CP $08
  DEC A
  DEC A
  DEC A
  RET

L1341:
  LD A,B
  PUSH AF
  CALL __CINT
  POP AF
  POP DE
  
  CP $7A		; MOD as mapped in PRITAB
  JP Z,IMOD
  
  CP $7B		; '\' as mapped in PRITAB
  JP Z,INT_DIV
  
  LD BC,BOOL_RESULT
  PUSH BC
  CP $46		; OR as mapped in PRITAB
  JP NZ,SKIP_OR
  
OR:
  LD A,E
  OR L
  LD L,A
  LD A,H
  OR D
  RET
  
SKIP_OR:
  CP $50		; AND as mapped in PRITAB
  JP NZ,SKIP_AND
  
AND:
  LD A,E
  AND L
  LD L,A
  LD A,H
  AND D
  RET
  
SKIP_AND:
  CP $3C		; XOR as mapped in PRITAB
  JP NZ,SKIP_XOR
  
XOR:
  LD A,E
  XOR L
  LD L,A
  LD A,H
  XOR D
  RET

SKIP_XOR:
  CP $32		; EQU (=) as mapped in PRITAB
  JP NZ,IMP

EQV:
  LD A,E
  XOR L
  CPL
  LD L,A
  LD A,H
  XOR D
  CPL
  RET
  
IMP:
  LD A,L
  CPL
  AND E
  CPL
  LD L,A
  LD A,H
  CPL
  AND D
  CPL
  RET
  
; This entry point is used by the routine at MIDNUM.
IMP:
  LD A,L
  SUB E
  LD L,A
  LD A,H
  SBC A,D
  LD H,A
  JP DBL_ABS_0
  
__LPOS:
  LD A,(LPT_POS)
  JP UNSIGNED_RESULT_A
  
__POS:
  LD A,(TTYPOS)
; This entry point is used by the routines at OPRND, MAKINT and TOPOOL.
UNSIGNED_RESULT_A:
  LD L,A
  XOR A

BOOL_RESULT:
  LD H,A
  JP INT_RESULT_HL
  
; This entry point is used by the routine at __DATA.
OPRND_3_05:
  PUSH HL
  AND $07
  LD HL,TYPE_OPR
  LD C,A
  LD B,$00
  ADD HL,BC
  CALL UCASE_4
  POP HL
  RET
  
__INP:
  CALL MAKINT
  LD (INPORT),A
  CALL TEL_TERM_013
  JP UNSIGNED_RESULT_A
  
__OUT:
  CALL GTIO_PARMS		; Get "WORD,BYTE" paramenters
  JP TEL_TERM_011

; Get subscript
;
; Used by the routine at __FOR.
FPSINT:
  RST CHRGTB		; Gets next character (or token) from BASIC text.
; This entry point is used by the routine at __FOR.
FPSINT_0:
  CALL EVAL

; Get integer variable to DE, error if negative
;
; Used by the routine at MAKINT.
DEPINT:
  PUSH HL
  CALL __CINT
  EX DE,HL
  POP HL
  LD A,D
  OR A
  RET
  
; This entry point is used by the routine at UCASE.
GTIO_PARMS:
  CALL GETINT
  LD (INPORT),A
  LD (OTPORT),A
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
  JP GETINT

; Load 'A' with the next number in BASIC program
;
; Used by the routines at __DATA and SCPTLP.
FNDNUM:
  RST CHRGTB		; Gets next character (or token) from BASIC text.

; Get a number to 'A'
;
; Used by the routines at __DATA, UCASE, DEPINT, MAKINT, GETWORD, TOPOOL,
; SCPTLP and GET_DEVICE.
GETINT:
  CALL EVAL

; Convert tmp string to int in A register
;
; Used by the routines at UCASE, GSTRDE, TOPOOL, MIDNUM and SCPTLP.
MAKINT:
  CALL DEPINT
  JP NZ,FCERR
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  LD A,E
  RET

__LLIST:
  LD A,$01
  LD (PRTFLG),A

; This entry point is used by the routines at SCPTLP and GET_DEVICE.
__LIST:
  POP BC
  CALL LNUM_RANGE
  PUSH BC
  LD H,B
  LD L,C
  LD (LBLIST),HL
MAKINT_0:
  LD HL,$FFFF
  LD (CURLIN),HL
  POP HL
  LD (LBEDIT),HL
  POP DE
  LD C,(HL)
  INC HL
  LD B,(HL)
  INC HL
  LD A,B
  OR C
  JP Z,MAKINT_3
  LD A,(MENU_FLG)
  AND A
  CALL Z,ISFLIO
  CALL Z,CHSNS_0
  PUSH BC
  LD C,(HL)
  INC HL
  LD B,(HL)
  INC HL
  PUSH BC
  EX (SP),HL
  EX DE,HL
  RST CPDEHL
  POP BC
  JP C,MAKINT_2
  EX (SP),HL
  PUSH HL
  PUSH BC
  EX DE,HL
  LD (DOT),HL
  CALL NUMPRT
  POP HL
  LD A,(HL)
  CP $09
  JP Z,MAKINT_1
  LD A,' '
  RST OUTC
MAKINT_1:
  CALL DETOKEN_LIST
  LD HL,INPBFR			; M100 uses KBUF directly
  CALL MAKINT_4
  CALL OUTDO_CRLF
  JP MAKINT_0

MAKINT_2:
  POP BC
MAKINT_3:
  LD A,(ERRTRP-1)
  AND A
  JP NZ,__EDIT_1
  LD A,$1A
  RST OUTC
  LD A,(MENU_FLG)
  AND A
  JP NZ,GET_DEVICE_100
  JP READY

MAKINT_4:
  LD A,(HL)
  OR A
  RET Z
  RST OUTC
  INC HL
  JP MAKINT_4

DETOKEN_LIST:
  LD BC,INPBFR
  LD D,$FF		; init line byte counter in D
  XOR A
  LD (OPRTYP),A		; a.k.a. DORES, indicates whether stored word can be crunched, etc..
  JP DETOKEN_NEXT_1

DETOKEN_NEXT:
  INC BC
  INC HL
  DEC D
  RET Z
DETOKEN_NEXT_1:
  LD A,(HL)
  OR A
  LD (BC),A
  RET Z
  CP $0B
  JP C,DETOKEN_NEXT_4
  CP ' '
  JP C,MAKINT_25
  CP '"'
  JP NZ,DETOKEN_NEXT_2
  LD A,(OPRTYP)
  XOR $01
  LD (OPRTYP),A
  LD A,'"'
DETOKEN_NEXT_2:
  CP ':'
  JP NZ,DETOKEN_NEXT_4
  LD A,(OPRTYP)
  RRA
  JP C,DETOKEN_NEXT_3
  RLA
  AND $FD
  LD (OPRTYP),A
DETOKEN_NEXT_3:
  LD A,':'
DETOKEN_NEXT_4:
  OR A
  JP P,DETOKEN_NEXT
  LD A,(OPRTYP)
  RRA
  JP C,_DETOKEN_NEXT
  RRA
  RRA
  JP NC,DETOKEN
  LD A,(HL)
  CP $E4			; TK_APOSTROPHE: COMMENT, check if line ends with the apostrophe..
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
  INC D
  JP MAKINT_16

__DETOKEN_NEXT:
  POP BC
  POP HL
  LD A,(HL)
_DETOKEN_NEXT:
  JP DETOKEN_NEXT

SET_DATA_FLAG:
  LD A,(OPRTYP)	; Indicates whether stored word can be crunched
  OR $02
UPD_OPRTYP:
  LD (OPRTYP),A
  XOR A
  RET

SET_REM_FLAG:
  LD A,(OPRTYP)
  OR $04
  JP UPD_OPRTYP
  
DETOKEN:
  RLA
  JP C,_DETOKEN_NEXT
  LD A,(HL)
  CP $84		; TK_DATA
  CALL Z,SET_DATA_FLAG
  CP $8F		; TK_REM
  CALL Z,SET_REM_FLAG
MAKINT_16:
  LD A,(HL)
  INC A
  LD A,(HL)
  JP NZ,MAKINT_17
  INC HL
  LD A,(HL)
  AND $7F
MAKINT_17:
  INC HL
  CP $A1		; TK_ELSE
  JP NZ,MAKINT_18
  DEC BC
  INC D
MAKINT_18:
  PUSH HL
  PUSH BC
  PUSH DE
  LD HL,WORDS-1
  LD B,A
  LD C,$40
DETOKEN_2:
  INC C
  LD A,C
  CP $5C  	;'\'
  JP NC,DETOKEN_7
DETOKEN_3:
  INC HL
  LD D,H
  LD E,L
DETOKEN_4:
  LD A,(HL)
  OR A
  JP Z,DETOKEN_2
  INC HL
  JP P,DETOKEN_4
  LD A,(HL)
  CP B
  JP NZ,DETOKEN_3
  EX DE,HL
  LD A,C
  POP DE
  POP BC
  CP $5B
  JP NZ,DETOKEN_6
DETOKEN_5:
  LD A,(HL)
  INC HL
DETOKEN_6:
  LD E,A
  AND $7F
  LD (BC),A
  INC BC
  DEC D
  JP Z,TESTR_0
  OR E
  JP P,DETOKEN_5
  POP HL
  JP DETOKEN_NEXT_1
  
DETOKEN_7:
  POP DE
  POP BC
  LD HL,$1561
  JP DETOKEN_5
  
  
  LD HL,($4350)
  XOR D
MAKINT_25:
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  PUSH DE
  PUSH BC
  PUSH AF
  CALL __FOR_23
  POP AF
  LD HL,(CONLO)
  CALL FOUT
  POP BC
  POP DE
  LD A,(CONTYP)
  CP $04
  LD E,$00
  JP C,MAKINT_26
  LD E,$21
  JP Z,MAKINT_26
  LD E,$23
MAKINT_26:
  LD A,(HL)
  CP ' '
  CALL Z,INCHL
MAKINT_27:
  LD A,(HL)
  INC HL
  OR A
  JP Z,MAKINT_30
  LD (BC),A
  INC BC
  DEC D
  RET Z
  LD A,(CONTYP)
  CP $04
  JP C,MAKINT_27
  DEC BC
  LD A,(BC)
  INC BC
  JP NZ,MAKINT_28
  CP '.'
  JP Z,MAKINT_29
MAKINT_28:
  CP 'D'			; 'D'
  JP Z,MAKINT_29
  CP 'E'			; 'E'
  JP NZ,MAKINT_27
MAKINT_29:
  LD E,$00
  JP MAKINT_27
  
MAKINT_30:
  LD A,E
  OR A
  JP Z,MAKINT_31
  LD (BC),A
  INC BC
  DEC D
  RET Z
MAKINT_31:
  LD HL,(CONTXT)
  JP DETOKEN_NEXT_1
  
; This entry point is used by the routine at SNERR.
DETOKEN_NEXT5:
  EX DE,HL
  LD HL,(PROGND)
MAKINT_33:
  LD A,(DE)
  LD (BC),A
  INC BC
  INC DE
  RST CPDEHL
  JP NZ,MAKINT_33
  LD H,B
  LD L,C
  LD (PROGND),HL
  LD (VAREND),HL
  LD (ARREND),HL
  RET

__PEEK:
  CALL GETWORD_HL
  LD A,(HL)
  JP UNSIGNED_RESULT_A

__POKE:
  CALL GETWORD
  PUSH DE
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
  CALL GETINT
  POP DE
  LD (DE),A
  RET

; Get a number to DE (0..65535)
;
; Used by the routines at MAKINT and CHKSTK.
GETWORD:
  CALL EVAL
  PUSH HL
  CALL GETWORD_HL
  EX DE,HL
  POP HL
  RET

; This entry point is used by the routine at MAKINT.
GETWORD_HL:
  LD BC,__CINT
  PUSH BC
  RST GETYPR 		; Get the number type (FAC)
  RET M
  LD A,(FACCU)
  CP $90
  RET NZ
  RST TSTSGN
  RET M
  CALL __CSNG
  LD BC,$9180
  LD DE,$0000
  JP FADD
  
__RENUM:
  LD BC,$000A
  PUSH BC
  LD D,B
  LD E,B
  JP Z,GETWORD_2
  CP ','
  JP Z,GETWORD_1
  PUSH DE
  CALL __FOR_33
  LD B,D
  LD C,E
  POP DE
  JP Z,GETWORD_2

GETWORD_1:
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
  CALL __FOR_33
  JP Z,GETWORD_2
  POP AF
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
  PUSH DE
  CALL LNUM_PARM_0
  JP NZ,SNERR
  LD A,D
  OR E
  JP Z,FCERR
  EX DE,HL
  EX (SP),HL
  EX DE,HL
GETWORD_2:
  PUSH BC
  CALL FIRST_LNUM
  POP DE
  PUSH DE
  PUSH BC
  CALL FIRST_LNUM
  LD H,B
  LD L,C
  POP DE
  RST CPDEHL
  EX DE,HL
  JP C,FCERR
  POP DE
  POP BC
  POP AF
  PUSH HL
  PUSH DE
  JP GETWORD_4
GETWORD_3:
  ADD HL,BC
  JP C,FCERR
  EX DE,HL
  PUSH HL
  LD HL,$FFF9
  RST CPDEHL
  POP HL
  JP C,FCERR
GETWORD_4:
  PUSH DE
  LD E,(HL)
  INC HL
  LD D,(HL)
  LD A,D
  OR E
  EX DE,HL
  POP DE
  JP Z,GETWORD_5
  LD A,(HL)
  INC HL
  OR (HL)
  DEC HL
  EX DE,HL
  JP NZ,GETWORD_3
GETWORD_5:
  PUSH BC
  CALL $16A7
  POP BC
  POP DE
  POP HL
GETWORD_6:
  PUSH DE
  LD E,(HL)
  INC HL
  LD D,(HL)
  LD A,D
  OR E
  JP Z,GETWORD_7
  EX DE,HL
  EX (SP),HL
  EX DE,HL
  INC HL
  LD (HL),E
  INC HL
  LD (HL),D
  EX DE,HL
  ADD HL,BC
  EX DE,HL
  POP HL
  JP GETWORD_6

GETWORD_7:
  LD BC,RESTART
  PUSH BC
  CP $F6
; This entry point is used by the routine at GET_DEVICE.
GETPARM_VRFY:
  XOR A
  LD (PTRFLG),A
  LD HL,(BASTXT)
  DEC HL
GETWORD_9:
  INC HL
  LD A,(HL)
  INC HL
  OR (HL)
  RET Z
  INC HL
  LD E,(HL)
  INC HL
  LD D,(HL)
GETWORD_10:
  RST CHRGTB		; Gets next character (or token) from BASIC text.

LINE2PTR:
  OR A
  JP Z,GETWORD_9
  LD C,A
  LD A,(PTRFLG)
  OR A
  LD A,C
  JP Z,GETWORD_16
  CP $A6			; TK_ERROR
  JP NZ,GETWORD_12
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  CP $89			; TK_GOTO
  
  JP NZ,LINE2PTR
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  CP $0E			; Line number prefix
  
  JP NZ,LINE2PTR
  PUSH DE
  CALL __FOR_36
  LD A,D
  OR E
  JP NZ,GETWORD_13
  JP GETWORD_14
  
GETWORD_12:
  CP $0E			; Line number prefix
  JP NZ,GETWORD_10
  PUSH DE
  CALL __FOR_36
GETWORD_13:
  PUSH HL
  CALL FIRST_LNUM
  DEC BC
  LD A,$0D
  JP C,GETWORD_17
  CALL CONSOLE_CRLF
  LD HL,$1712
  PUSH DE
  CALL PRS
  POP HL
  CALL NUMPRT
  POP BC
  POP HL
  PUSH HL
  PUSH BC
  CALL LNUM_MSG
  POP HL
GETWORD_14:
  POP DE
  DEC HL
GETWORD_15:
  JP GETWORD_10
  LD D,L
  LD L,(HL)
  LD H,H
  LD H,L
  LD H,(HL)
  LD L,C
  LD L,(HL)
  LD H,L
  LD H,H
  JR NZ,$1789
  LD L,C
  LD L,(HL)
  LD H,L
  JR NZ,GETWORD_16
GETWORD_16:
  CP $0D
  JP NZ,GETWORD_15
  PUSH DE
  CALL __FOR_36
  PUSH HL
  EX DE,HL
  INC HL
  INC HL
  INC HL
  LD C,(HL)
  INC HL
  LD B,(HL)
  LD A,$0E
GETWORD_17:
  LD HL,$170C
  PUSH HL
  LD HL,(CONTXT)
; This entry point is used by the routine at __FOR.
GETWORD_18:
  PUSH HL
  DEC HL
  LD (HL),B
  DEC HL
  LD (HL),C
  DEC HL
  LD (HL),A
  POP HL
  RET
  
; This entry point is used by the routine at SNERR.
EXEC_HL_FLIO:
  LD A,(PTRFLG)
  OR A
  RET Z
  JP GETPARM_VRFY
  
; This entry point is used by the routines at ISFLIO, SCPTLP and GET_DEVICE.
CHGET:
  PUSH HL
  PUSH DE
  PUSH BC
  CALL GETWORD_21
  JP POPALL_0
GETWORD_21:
  RST $38
  INC B
  LD HL,(FNKPNT)
  INC H
  DEC H
  JP Z,GETWORD_24
  LD B,(HL)
  INC HL
  LD A,(HL)
  OR A
  JP NZ,GETWORD_22
  LD H,A
GETWORD_22:
  LD (FNKPNT),HL
  LD A,B
  RET

GETWORD_23:
  LD A,(FNK_FLAG)
  ADD A,A
  RET C
  LD HL,$0000
  LD (PASPNT),HL
  LD A,$0D
  LD ($F98E),A
GETWORD_24:
  LD HL,(PASPNT)
  LD A,L
  AND H
  INC A
  JP Z,GETWORD_26
  PUSH HL
  LD A,($F98E)
  CP $0D
  CALL Z,RESFPT_0
  LD HL,(HAYASHI)		; Paste buffer file
  POP DE
  ADD HL,DE
  LD A,(HL)
  LD ($F98E),A
  LD B,A
  CP $1A		; EOF
  LD A,$00
  JP Z,GETWORD_25
  CALL KEYX
  JP C,GETWORD_25
  INC HL
  LD A,(HL)
  EX DE,HL
  INC HL
  LD (PASPNT),HL
  CP $1A		; EOF
  LD A,B
  SCF
  CCF
  RET NZ
GETWORD_25:
  LD HL,$FFFF
  LD (PASPNT),HL
  RET

GETWORD_26:
  CALL CHSNS
  JP NZ,GETWORD_28
  CALL BLINK_CURS_SHOW
  LD A,$FF
  LD (POWR_FLAG),A
GETWORD_27:
  CALL CHSNS
  JP Z,GETWORD_27
  XOR A
  LD (POWR_FLAG),A
  CALL BLINK_CURS_HIDE
GETWORD_28:
  LD HL,TMOFLG
  LD A,(HL)
  AND A
  JP NZ,POWER_DOWN
  CALL GETWORD_131
  CALL __MENU_45
  RET NC
  SUB $0A
  JP Z,GETWORD_23
  JP NC,INVALID_CH
  LD E,A
  LD A,(FNK_FLAG)
  AND $60
  SCF
  LD A,E
  RET NZ
  LD D,$FF
  EX DE,HL
  ADD HL,HL
  ADD HL,HL
  ADD HL,HL
  ADD HL,HL
  LD DE,$F745
  ADD HL,DE
  LD A,(FNK_FLAG)
  AND A
  JP P,GETWORD_29
  INC HL
  INC HL
  INC HL
  INC HL
GETWORD_29:
  LD (FNKPNT),HL
  JP GETWORD_21

FNBAR_IF_NZ:
  JP Z,ERAFNK
  JP DSPFNK
  
; This entry point is used by the routine at CHGET.
POWER_DOWN:
  DI
  LD (HL),$00
  LD A,(PWRINT)
  DEC HL
  LD (HL),A
  CALL TURN_OFF

INVALID_CH:
  XOR A
  RET

BLINK_CURS_SHOW:
  LD A,(CSR_STATUS)
  LD (BLINK),A
  AND A
  RET NZ
  CALL CURSON
  JP _ESC_X		; Refresh cursor

BLINK_CURS_HIDE:
  LD A,(BLINK)
  AND A
  RET NZ
  CALL CURSOFF
  JP _ESC_X		; Refresh cursor

; This entry point is used by the routines at SCPTLP and GET_DEVICE.
CHSNS:
  LD A,(FNKPNT+1)	; 
  AND A
  RET NZ
  LD A,(TMOFLG)
  AND A

; This entry point is used by the routine at GET_DEVICE.
_CHSNS:
  RET NZ
  PUSH HL
  LD HL,(PASPNT)
  LD A,L
  AND H
  INC A
  POP HL
  RET NZ
  RST $38
  DEFB $06	; HCHSNS, Offset: 06
  
  JP KEYX


; This entry point is used by the routines at __FOR and MAKINT.
ISCNTC
  CALL BRKCHK
  RET Z
  CP $03
  JP Z,CTL_C
  CP $13
  RET NZ
  CALL BLINK_CURS_SHOW
ISCNTC_0:
  CALL BRKCHK
  CP $11
  JP Z,BLINK_CURS_HIDE
  CP $03
  JP NZ,ISCNTC_0
  CALL BLINK_CURS_HIDE
  
CTL_C:
  XOR A
  LD (KYBCNT),A
  JP __STOP

; POWER statement
__POWER:
  SUB $99
  JP Z,POWER_CONT
  CP $4E	; $99+$4E=$E7: TOKEN for "OFF"
  JP NZ,POWER_ON
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JP Z,TURN_OFF_0
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  AND A		; TK_RESUME
  JP NZ,SNERR
  JP TURN_OFF

LOW_PWR_EXIT:
  POP AF
  RET

; Normal TRAP (low power) interrupt routine
LOW_PWR:
  PUSH AF
  IN A,($D8)
  AND A
  JP M,LOW_PWR_EXIT
  LD A,(POWR_FLAG)
  AND A
  LD A,$01
  LD (POWR_FLAG),A
  JP NZ,TURN_OFF_0
  POP AF

; Turn off computer
;
; Used by the routines at FNBAR_TOGGLE and __POWER.
TURN_OFF:
  DI
  PUSH HL
  PUSH DE
  PUSH BC
  PUSH AF
  LD HL,$0000
  ADD HL,SP
  LD ($F9AE),HL
  LD HL,$9C0B	; POWER ON data marker
  LD (ATIDSV),HL
TURN_OFF_0:
  DI
  CALL GETWORD_131
  IN A,($BA)
  OR $10
  OUT ($BA),A
  HALT
POWER_CONT:
  CALL GETWORD_45
  LD (TMOFLG),A
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  RET

POWER_ON:
  CALL GETINT
  CP $0A
  JP C,FCERR
GETWORD_45:
  LD (PWRINT),A
  LD (TIMINT),A
  RET
  
; This entry point is used by the routine at SCPTLP.
LPT_OUT:
  RST $38
  INC C
  CALL PRS_ABORTMSG7
  PUSH AF
  CALL GETWORD_131
  POP AF
  RET NC
  XOR A
  LD (LPT_POS),A
  JP GETWORD_49
  
; Start tape and load tape header.  If an error or Shift Break pressed,
; generate I/O error
;
; Used by the routine at CAS_OPNI_CO.
HEADER:
  CALL TEL_TERM_007
  CALL CTON
  CALL SYNCR
  RET NC
HEADER_0:
  CALL CTOFF
GETWORD_49:
  LD E,$18
  JP ERROR
  
IOOPRND_0:
  CALL TEL_TERM_006
  CALL CTON
  LD BC,$0000
GETWORD_51:
  DEC BC
  LD A,B
  OR C
  JP NZ,GETWORD_51
  JP __MENU_06
  
CTON:
  DI
  defb $11		; LD DE,NN to skip the next 2 bytes
; Cassette motor OFF
;
; Used by the routines at HEADER, CAS_INPUT, __CLOAD, LOAD_RECORD, CLOADM,
; LDIR_B, CAS_OPNO_CO and CAS_OPNI_CO.
CTOFF:
  EI
  LD E,$00
  JP DATAR_1
  
CASIN:
  CALL TEL_TERM_004
  PUSH DE
  PUSH HL
  PUSH BC
  CALL DATAR
  JP C,HEADER_0
  LD D,A
  POP BC
  ADD A,C
  LD C,A
  LD A,D
  POP HL
  POP DE
  RET

CSOUT:
  CALL TEL_TERM_005
  PUSH HL
  PUSH DE
  LD D,A
  ADD A,C
  LD C,A
  PUSH BC
  LD A,D
  CALL DATAW
  JP C,HEADER_0
  JP POPALL_0


; LCD Device control block
LCD_CTL:
  DEFW LCDLPT_OPN
  DEFW _CLOSE
  DEFW LCD_OUTPUT
  
;  LD C,B
;  ADD HL,DE
;  DEC B
;  LD C,A
;  LD D,L
;  ADD HL,DE


; LCD and LPT file open routine
LCDLPT_OPN:
  LD A,$02
  CP E
  JP NZ,NMERR			; NM error: bad file name
  
REDIRECT_IO:
  LD (PTRFIL),HL			; Redirect I/O
  LD (HL),E
  POP AF
  POP HL
  RET

; LCD file output routine
LCD_OUTPUT:
  POP AF
  PUSH AF
  CALL OUTC_SUB_0
LCD_OUTPUT_0:
  CALL GETWORD_131
  
; This entry point is used by the routines at ISFLIO and GET_DEVICE.
POPALL:
  POP AF
POPALL_0:
  POP BC
  POP DE
  POP HL
  RET



  
; CRT device control block?
; Data block at 6498
CRT_CTL:
  DEFW CRT_OPN
  DEFW _CLOSE
  DEFW CRT_OUTPUT
  DEFW L1970
  DEFW L1972

CRT_OPN:
  RST $38
  DEFB $62
  
CRT_OUTPUT:
  RST $38
  DEFB $66

L1970:
  RST $38
  DEFB $68

L1972:
  RST $38
  DEFB $6a


; Data block at 6516
RAM_CTL:
  DEFW RAM_OPN
  DEFW RAM_CLS
  DEFW RAM_OUTPUT
  DEFW RAM_INPUT
  DEFW RAM_IO
  


; RAM Device control block
RAM_CTL:
  DEFW RAM_OPN
  DEFW RAM_CLS
  DEFW RAM_OUTPUT
  DEFW RAM_INPUT
  DEFW RAM_IO


; Data block at 6516
RAM_CTL:
  DEFW L197E
  DEFW $1A05
  DEFW $1A24
  DEFW $1A3C
  DEFW $1A93
  
; RAM file open routine
RAM_OPN:
  PUSH HL
  PUSH DE
  INC HL
  INC HL
  PUSH HL
  LD A,E
  CP $01
  JP Z,GETWORD_62
  CP $08
  JP Z,GETWORD_63
RAM_OPN_0:
  CALL MAKTXT
  JP C,GETWORD_65
  PUSH DE
  CALL __EOF_3
  POP DE
GETWORD_60:
  LD BC,$0000
GETWORD_61:
  POP HL
  LD A,(DE)
  AND $02
  JP NZ,AOERR
  LD A,(DE)
  OR $02
  LD (DE),A
  INC DE
  LD (HL),E
  INC HL
  LD (HL),D
  INC HL
  INC HL
  INC HL
  LD (HL),$00
  INC HL
  LD (HL),C
  INC HL
  LD (HL),B
  POP DE
  POP HL
  JP REDIRECT_IO
  
GETWORD_62:
  LD A,(ERRTRP-1)
  AND A
  LD HL,SUZUKI+21
  CALL Z,FINDCO_0
  JP Z,FFERR
  EX DE,HL
  CALL GET_RAM_PTR
  XOR A
  LD (HL),A
  LD L,A
  LD H,A
  LD (RAM_FILES),HL
  JP GETWORD_60

GETWORD_63:
  POP HL
  POP DE
  LD E,$02
  PUSH DE
  PUSH HL
  CALL RESFPT_0
  CALL FINDCO_0
  JP Z,RAM_OPN_0
  LD E,L
  LD D,H
  INC HL
  LD A,(HL)
  INC HL
  LD H,(HL)
  LD L,A
  LD BC,$FFFF
GETWORD_64:
  LD A,(HL)
  INC HL
  INC BC
  CP $1A		; EOF
  JP NZ,GETWORD_64
  JP GETWORD_61
GETWORD_65:
  LD A,(DE)
  AND $02
  JP NZ,AOERR
  EX DE,HL
  CALL KILLASC+1 
  JP RAM_OPN_0

; Routine at 6661
RAM_CLS:
  PUSH HL
  CALL RAM_CLS_0
  POP HL
  CALL CLOSE_DEVICE
  CALL NZ,RAM_INPUT_2
  CALL GET_RAM_PTR
  LD (HL),$00
  JP _CLOSE
  
RAM_CLS_0:
  INC HL
  INC HL
  LD A,(HL)
  INC HL
  LD H,(HL)
  LD L,A
  DEC HL
  LD A,(HL)
  AND $FD
  LD (HL),A
  RET

; Routine at 6692
RAM_OUTPUT:
  POP AF
  PUSH AF
  LD BC,LCD_OUTPUT_0
  PUSH BC
  AND A
  RET Z
  CP $1A		; EOF
  RET Z
  CP $7F		; BS
  RET Z
  CALL INIT_DEV_OUTPUT
  RET NZ
  LD BC,$0100
  JP RAM_INPUT_2


; RAM file input routine
; Routine at 6716
RAM_INPUT:
  EX DE,HL
  CALL GET_RAM_PTR
  CALL GET_BYTE
  EX DE,HL
  CALL GETPARM_VRFY3
  JP NZ,RAM_INPUT_1
  EX DE,HL
  LD HL,(FILTAB+4)
  RST CPDEHL
  PUSH AF
  PUSH DE
  CALL NZ,RESFPT_0
  POP HL
  POP AF
  LD BC,$FFF9
  ADD HL,BC
  LD E,(HL)
  INC HL
  LD D,(HL)
  EX DE,HL
  LD A,(HL)
  INC HL
  LD H,(HL)
  LD L,A
  JP NZ,RAM_INPUT_0
  PUSH DE
  EX DE,HL
  LD HL,(RAM_FILES)
  EX DE,HL
  ADD HL,DE
  POP DE
RAM_INPUT_0:
  EX DE,HL
  INC HL
  INC HL
  INC HL
  INC HL
  LD C,(HL)
  INC HL
  LD B,(HL)
  INC (HL)
  INC HL
  EX DE,HL
  ADD HL,BC
  LD B,$00
  CALL LDIR_B
  EX DE,HL
  DEC H
  XOR A
RAM_INPUT_1:
  LD C,A
  ADD HL,BC
  LD A,(HL)
  CP $1A		; EOF
  SCF
  CCF
  JP NZ,RDBYT_0
  CALL GET_RAM_PTR
  LD (HL),A
  SCF
  JP RDBYT_0

; Routine at 6803
RAM_IO:
  CALL GET_RAM_PTR
  JP DEV_IO_SUB

; This entry point is used by the routines at RAM_CLS and RAM_OUTPUT.
RAM_INPUT_2:
  PUSH HL
  PUSH BC
  PUSH HL
  EX DE,HL
  LD HL,(FILTAB+4)
  RST CPDEHL
  CALL NZ,RESFPT_0
  POP HL
  DEC HL
  LD D,(HL)
  DEC HL
  LD E,(HL)
  EX DE,HL
  POP BC
  PUSH BC
  PUSH HL
  ADD HL,BC
  EX DE,HL
  LD (HL),E
  INC HL
  LD (HL),D
  LD BC,$FFFA			; -6
  ADD HL,BC
  LD E,(HL)
  INC HL
  LD D,(HL)
  LD A,(DE)
  LD L,A
  INC DE
  LD A,(DE)
  LD H,A
  POP BC
  ADD HL,BC
  POP BC
  PUSH HL
  PUSH BC
  CALL MAKHOL
  CALL NC,__EOF_4
  POP BC
  POP DE
  POP HL
  JP C,RAM_INPUT_4
  PUSH HL
RAM_INPUT_3:
  LD A,(HL)
  LD (DE),A
  INC DE
  INC HL
  DEC C
  JP NZ,RAM_INPUT_3
  POP DE
  LD HL,(FILTAB+4)
  RST CPDEHL
  RET Z
  JP RESFPT_0

RAM_INPUT_4:
  LD BC,$FFF7				; -9
  ADD HL,BC
  LD (HL),$00
  CALL RAM_CLS_0
  JP OMERR

GET_RAM_PTR:
  PUSH DE
  LD HL,(RAMFILE)
  LD DE,RAMPRV
  ADD HL,DE
  POP DE
  RET


; CAS Device control block
CAS_CTL:
  DEFW CAS_OPN
  DEFW CAS_CLS
  DEFW CAS_OUTPUT
  DEFW CAS_INPUT
  DEFW CAS_IO


; CAS file open routine
CAS_OPN:
  PUSH HL
  PUSH DE
  LD BC,$0006
  ADD HL,BC
  XOR A
  LD (HL),A
  LD (CASPRV),A
  LD A,E
  CP $08
  JP Z,NMERR			; NM error: bad file name
  CP $01
  JP Z,CAS_OPN_1
  CALL CAS_OPNO_DO
CAS_OPN_0:
  POP DE
  POP HL
  JP REDIRECT_IO

CAS_OPN_1:
  CALL $2A0F		; CAS_OPNI_DO
  JP CAS_OPN_0

; CAS file close routine
CAS_CLS:
  CALL CLOSE_DEVICE
  JP Z,CAS_CLS_1
  PUSH HL
  ADD HL,BC
CAS_CLS_0:
  LD (HL),$1A		; EOF
  INC HL
  INC C
  JP NZ,CAS_CLS_0
  POP HL
  CALL CAS_OUTPUT_0
CAS_CLS_1:
  XOR A
  LD (CASPRV),A
  JP _CLOSE
  

; CAS file output routine
CAS_OUTPUT:
  POP AF
  PUSH AF
  CALL INIT_DEV_OUTPUT
  CALL Z,CAS_OUTPUT_0
  JP LCD_OUTPUT_0

; CAS file input routine
CAS_INPUT:
  EX DE,HL
  LD HL,CASPRV
  CALL GET_BYTE
  EX DE,HL
  CALL GETPARM_VRFY3
  JP NZ,GETWORD_78
  PUSH HL
  CALL CAS_OPNI_CO_10
  POP HL
  LD BC,$0000
GETWORD_77:
  CALL CASIN
  LD (HL),A
  INC HL
  DEC B
  JP NZ,GETWORD_77
  CALL CASIN
  LD A,C
  AND A
  JP NZ,HEADER_0
  CALL CTOFF
  DEC H
  XOR A
  LD B,A
GETWORD_78:
  LD C,A
  ADD HL,BC
  LD A,(HL)
  CP $1A		; EOF
  SCF
  CCF
  JP NZ,RDBYT_0
  LD (CASPRV),A
  SCF
  JP RDBYT_0
  LD HL,CASPRV
  JP DEV_IO_SUB
CAS_OUTPUT_0:
  PUSH HL
  CALL CAS_OPNO_CO_3
  POP HL
  LD BC,$0000
GETPARM_VRFY0:
  LD A,(HL)
  CALL CSOUT
  INC HL
  DEC B
  JP NZ,GETPARM_VRFY0
  JP CAS_OPNO_CO_1
CLOSE_DEVICE:
  LD A,(HL)
  CP $01
  RET Z
  LD BC,$0006
  ADD HL,BC
  LD A,(HL)
  LD C,A
  LD (HL),$00
  JP GETPARM_VRFY4
INIT_DEV_OUTPUT:
  LD E,A
  LD BC,$0006
  ADD HL,BC
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
GETPARM_VRFY3:
  LD BC,$0006
  ADD HL,BC
  LD A,(HL)
  INC (HL)
GETPARM_VRFY4:
  INC HL
  INC HL
  INC HL
  AND A
  RET
  LD C,B
  ADD HL,DE
  DEC B
  LD C,A
  JP NC,GET_DEVICE_694
  PUSH AF
  CALL OUTC_TABEXP
  JP LCD_OUTPUT_0
  CALL PO,$011B
  INC E
  DEC E
  INC E
  JR Z,GETPARM_VRFY6
  LD B,A
  INC E
  RST $38
  LD C,(HL)
  PUSH HL
  PUSH DE
  LD HL,FILNAM
  CALL GETWORD_91
  POP DE
  LD A,E
  CP $08
  JP Z,NMERR			; NM error: bad file name
  SUB $01
  JP NZ,GETPARM_VRFY5
  LD (COMPRV),A
GETPARM_VRFY5:
  POP HL
GETPARM_VRFY6:
  JP REDIRECT_IO
  
GETPARM_VRFY7:
  RST $38
  LD D,B
  IN A,($D8)
  AND $10
  JP Z,GETPARM_VRFY7
  LD BC,__CLOSE_3
GETPARM_VRFY8:
  DEC BC
  LD A,B
  OR C
  JP NZ,GETPARM_VRFY8
  CALL __MENU_02
  XOR A
  LD (COMPRV),A
  JP _CLOSE

  POP AF
  PUSH AF
  CALL SD232C
  JP NC,LCD_OUTPUT_0
  JP GETWORD_49
  LD HL,COMPRV
  CALL GET_BYTE
  CALL RV232C
  JP C,GETWORD_49
  JP Z,GETPARM_VRFY9
  LD A,$82
GETPARM_VRFY9:
  CP $1A		; EOF
  SCF
  CCF
  JP NZ,RDBYT_0
  LD (COMPRV),A
  SCF
  JP RDBYT_0
  LD HL,COMPRV
DEV_IO_SUB:
  LD (HL),C
  JP SCPTLP_119
  
; This entry point is used by the routine at GET_DEVICE.
GETWORD_91:
  LD E,L
  LD D,H
  LD B,$06
GETWORD_92:
  LD A,(DE)
  CP ' '
  JP NZ,GETWORD_93
  INC DE
  DEC B
  JP NZ,GETWORD_92
  LD HL,$F406
GETWORD_93:
  LD BC,NMERR			; NM error: bad file name
  PUSH BC
  LD A,(HL)
  SUB $31
  CP $09
  RET NC
  INC A
  LD D,A
  INC HL
  CALL UCASE_HL
  LD B,A
  CP $49
  JP Z,GETWORD_94
  CP 'E'
  LD E,$02
  JP Z,GETWORD_95
  SUB $4E
GETWORD_94:
  LD E,$04
  JP Z,GETWORD_95
  DEC A
  RET NZ
  LD E,A
GETWORD_95:
  INC HL
  LD A,(HL)
  SUB $36
  CP $03
  RET NC
  INC A
  ADD A,A
  ADD A,A
  ADD A,A
  OR E
  LD E,A
  LD A,B
  CP $49
  JP NZ,$1CAC
  LD A,E
  AND $18
  CP $18
  RET Z
  LD A,E
  ADD A,$08
  LD E,A
  AND $08
  ADD A,A
  ADD A,A
  ADD A,A
  OR $3F
  JP Z,PTRFIL_2
  LD C,A
  INC HL
  LD A,(HL)
  SUB $31
  CP $02
  RET NC
  OR E
  LD E,A
  INC HL
  CALL UCASE_HL
  CP $4E
  JP Z,GETWORD_96
  CP $58
  RET NZ
  CALL _XONXOFF_FLG
  SCF
GETWORD_96:
  CALL NC,$6F8E
  INC HL
  CALL UCASE_HL
  CP $53
  JP Z,GETWORD_97
  CP $4E
  RET NZ
GETWORD_97:
  POP AF
  PUSH DE
  LD DE,$F40B
  LD B,$06
GETWORD_98:
  CALL UCASE_HL
  LD (DE),A
  DEC HL
  DEC DE
  DEC B
  JP NZ,GETWORD_98
  POP HL
  JP $6F58
  OR $1C
  RET M
  INC E
  ADD A,A
  DEC BC
  JP M,PTRFIL_0
  INC E

  RST $38
  LD L,H

  RST $38
  LD L,(HL)

  RST $38
  LD (HL),B

  RST $38
  LD (HL),D

__EOF:
  RST $38
  JR Z,$1CCE
  DEC L
  LD C,(HL)
  JP Z,CFERR
  CP $01
  JP NZ,NMERR			; NM error: bad file name
  PUSH HL
  CALL __EOF_1
  LD C,A
  SBC A,A
  CALL INT_RESULT_A
  POP HL
  INC HL
  INC HL
  INC HL
  INC HL
  LD A,(HL)
  LD HL,COMPRV
  CP $FC		; 'COM' device
  JP Z,__EOF_0
  CALL GET_RAM_PTR
  CP $F9		; 'RAM' device ?
  JP Z,__EOF_0
  LD HL,CASPRV
__EOF_0:
  LD (HL),C
  RET

__EOF_1:
  PUSH BC
  PUSH HL
  PUSH DE
  LD A,$06
  JP GET_DEVICE

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
  JP NZ,RDBYT_0
  LD (HL),A
; This entry point is used by the routine at GET_DEVICE.
GETWORD_102:
  SCF
  JP RDBYT_0

__EOF_3:
  LD BC,$0001
__EOF_4:
  LD HL,(SAVSTK)
__EOF_5:
  LD A,(HL)
  AND A
  RET Z
  EX DE,HL
  LD HL,(STKTOP)
  EX DE,HL
  RST CPDEHL
  RET NC
  LD A,(HL)
  CP $82
  LD DE,$0007
  JP NZ,GETWORD_106
  INC HL
  LD E,(HL)
  INC HL
  LD D,(HL)
  EX DE,HL
  ADD HL,BC
  EX DE,HL
  LD (HL),D
  DEC HL
  LD (HL),E
  LD DE,CHRGTB
GETWORD_106:
  ADD HL,DE
  JP __EOF_5
  
; This entry point is used by the routine at OPRND.
FN_TIME:
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  PUSH HL
  CALL GET_DAY_0
  CALL READ_TIME
  JP TSTOPL
  
; This entry point is used by the routine at GET_DEVICE.
READ_TIME:
  CALL READ_CLOCK
  LD DE,$F837
  CALL LINE2PTR4
  LD (HL),':'
  INC HL
  CALL LINE2PTR4
  LD (HL),':'
GETWORD_109:
  INC HL
  JP LINE2PTR4
  
; This entry point is used by the routine at OPRND.
FN_DATE:
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  PUSH HL
  CALL GET_DAY_0
  CALL GET_DATE
  JP TSTOPL
  
; This entry point is used by the routine at GET_DEVICE.
GET_DATE:
  CALL READ_CLOCK
  PUSH HL
  LD HL,$F83D
  LD B,$00
  DI
  CALL $7EEC
  EI
  LD A,D
  EX (SP),HL
  CALL LINE2PTR6
  EX (SP),HL
  DEC HL
  DI
  CALL $7EEC
  EI
  LD A,D
  POP HL
  CALL LINE2PTR6
  LD DE,$F83B
  LD (HL),$2F
  INC HL
  LD A,(DE)
  CP $0A
  LD B,$30
  JP C,LINE2PTR2
  LD B,$31
  SUB $0A
LINE2PTR2:
  LD (HL),B
  INC HL
  CALL LINE2PTR6
  DEC DE
  LD (HL),$2F
  JP GETWORD_109
  
GET_DAY_0:
  LD A,$08
  CALL MKTMST
  LD HL,(TMPSTR)
  RET
  
LINE2PTR4:
  CALL LINE2PTR5
LINE2PTR5:
  LD A,(DE)
LINE2PTR6:
  OR $30
  LD (HL),A
  DEC DE
  INC HL
  RET
  
READ_CLOCK:
  PUSH HL
  LD HL,SECS
  DI
  CALL READ_CLOCK_HL
  EI
  POP HL
  RET

; This entry point is used by the routine at __FOR.
TIME:
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  CALL GETWORD_123
LINE2PTR9:
  LD HL,SECS
  DI
  CALL $735A
  EI
  POP HL
  RET

; This entry point is used by the routine at __FOR.
DATE:
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  CALL GETWORD_122
  JP NZ,SNERR
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  PUSH HL
  LD HL,$F83D
  DI
  CALL __MENU_189
  EI
  EX (SP),HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  EX (SP),HL
  DEC HL
; This entry point is used by the routine at EXP.
GETWORD_121:
  DI
  CALL __MENU_189
  EI
  POP HL
  INC HL
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  CPL
  CALL GETINT
  DEC A
  CP $0C
  JP NC,SNERR
  INC A
  LD DE,$F83B
  LD (DE),A
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  CPL
  DEC DE
  CALL GETWORD_124
  CP $04
  JP NC,SNERR
  CALL GETWORD_124
  JP LINE2PTR9

GETWORD_122:
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  POP AF
  CALL EVAL
  EX (SP),HL
  PUSH HL
  CALL READ_CLOCK
  CALL GETSTR
  LD A,(HL)
  INC HL
  LD E,(HL)
  INC HL
  LD H,(HL)
  LD L,E
  CP $08
  RET
GETWORD_123:
  CALL GETWORD_122
  JP NZ,SNERR
  EX DE,HL
  POP HL
  EX (SP),HL
  PUSH HL
  EX DE,HL
  LD DE,$F838
  CALL GETWORD_124
  CP $03
  JP NC,SNERR
  CALL GETWORD_124
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  LD A,($7BCD)
  LD E,$CF
  LD A,($83CD)
  LD E,$FE
  LD B,$D2
  LD L,B
  DEC B
GETWORD_124:
  DEC DE
  LD A,(HL)
  INC HL
  SUB $30
  CP $0A
  JP NC,SNERR
  AND $0F
  LD (DE),A
  RET
  
; COM and MDM Statements
__COM:
  PUSH HL
  LD HL,ON_COM_FLG
  CALL GETWORD_125
;__MDM_2:
  POP HL
  POP AF
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JP EXEC_EVAL_00
  
GETWORD_125:
  CP $95
  JP Z,TIME_S_ON
  CP $E7
  JP Z,TIME_S_OFF
  CP $90
  JP Z,TIME_S_STOP
  JP SNERR
  
; This entry point is used by the routine at __DATA.
ONGO:
  CP $B6
  LD BC,$0001
  RET Z
  SCF
  RET
  
; This entry point is used by the routine at __DATA.
GETWORD_127:
  EX DE,HL
  LD ($F84D),HL		; IENTRY_F1
  EX DE,HL
  RET
  
; This entry point is used by the routine at GETYPR.
GETWORD_128:
  CALL GET_DEVICE_699
  PUSH HL
  PUSH DE
  PUSH BC
GETWORD_129:
  PUSH AF
  LD A,$0D
  JR NC,GETWORD_129
  LD HL,CSRITP
  DEC (HL)
  JP NZ,GETWORD_130
  LD (HL),$7D
  INC HL
  DEC (HL)
  JP NZ,GETWORD_130
  LD (HL),$0C
  INC HL
  PUSH HL
  LD HL,(CURLIN)
  INC HL
  LD A,H
  OR L
  POP HL
  CALL NZ,GETWORD_131
  LD A,(HL)
  AND A
  JP Z,GETWORD_130
  DEC (HL)
  JP NZ,GETWORD_130
  INC HL
  LD (HL),$FF
GETWORD_130:
  JP _RST75_7
; This entry point is used by the routine at GET_DEVICE.
GETWORD_131:
  LD A,(PWRINT)
  LD (TIMINT),A
  RET

; This entry point is used by the routine at ISFLIO.
GETWORD_132:
  LD A,(HL)
  CP $7F		; BS
  JP Z,GETWORD_133
  CP ' '
  JP NC,GETWORD_134
GETWORD_133:
  LD A,' '
GETWORD_134:
  RST OUTC
  INC HL
  DEC B
  JP NZ,GETWORD_132
  LD A,' '
  RET

__KEY:
  CALL GETINT
  DEC A
  CP $0A
  JP NC,FCERR
  EX DE,HL
  LD L,A
  LD H,$00
  ADD HL,HL
  ADD HL,HL
  ADD HL,HL
  ADD HL,HL
  LD BC,FNKSTR
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
  JP Z,GETWORD_137
GETWORD_135:
  LD A,(DE)
  AND A
  JP Z,FCERR
  LD (HL),A
  INC DE
GETWORD_136:
  INC HL
  DEC C
  JP Z,GETWORD_138
  DEC B
  JP NZ,GETWORD_135
GETWORD_137:
  LD (HL),B
  INC HL
  DEC C
  JP NZ,GETWORD_137
GETWORD_138:
  LD (HL),C
  CALL FNKSB
  CALL DWNLDR_47
  POP HL
  RET
__PSET:
  CALL GETWORD_141
GETWORD_139:
  RRCA
  PUSH HL
  PUSH AF
  CALL C,PLOT
  POP AF
  CALL NC,$74D1
  POP HL
  RET

__PRESET:
  CALL GETWORD_141
  CPL
  JP GETWORD_139

; This entry point is used by the routine at __DATA.
GETWORD_140:
  RST $38
  ADD A,(HL)
GETWORD_141:
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  JR Z,GETWORD_136
  EX (SP),HL
  INC DE
  CP $F0		; TK_GREATER	; Token for '>'
  JP C,GETWORD_142
  LD A,$EF
GETWORD_142:
  PUSH AF
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
  CALL GETINT
  CP $40
  JP C,GETWORD_143
  LD E,$3F
GETWORD_143:
  POP AF
  LD D,A
  EX DE,HL
  LD ($F3FA),HL
  EX DE,HL
  LD A,(HL)
  CP ')'
  JP NZ,GETWORD_144
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  LD A,$01
  RET
GETWORD_144:
  PUSH DE
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
  CALL GETINT
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  ADD HL,HL
  LD A,E
  POP DE
  RET
  
__LOCATE:
  CALL GETINT
  PUSH AF
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
  CALL GETINT
  POP AF
  LD D,A
  LD A,(ACTV_Y)
  INC D
  CP D
  JP NC,GETWORD_145
  LD D,A
GETWORD_145:
  LD A,(ACTV_X)
  INC E
  CP E
  JP NC,GETWORD_146
  LD E,A
GETWORD_146:
  PUSH HL
  EX DE,HL
  CALL POSIT
  LD A,H
  DEC A
  LD (TTYPOS),A
  POP HL
  RET
; This entry point is used by the routine at OPRND.
GETWORD_147:
  PUSH HL
  LD A,(CSRX)
  DEC A
  CALL INT_RESULT_A
  POP HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  RET
  
__WIDTH:
  RST $38
  LD E,(HL)
__CMD:
  RST $38
  ADC A,D
__COLOR:
  RST $38
  ADC A,B
; This entry point is used by the routine at OPRND.
FN_STATUS:
  RST $38
  ADC A,H
__SOUND:
  CALL GETWORD
  LD A,D
  AND $C0
  JP NZ,FCERR
  PUSH DE
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
  CALL GETINT
GETWORD_149:
  AND A
  LD B,A
  POP DE
  JP NZ,MUSIC
  RET
__MOTOR:
  CALL GETINT
  JP DATAR_1
__EXEC:
  CALL GETWORD
  PUSH HL
  LD A,($F9A7)
  LD HL,($F9A8)
  CALL GETWORD_150
  LD ($F9A7),A
  LD ($F9A8),HL
  POP HL
  RET
GETWORD_150:
  PUSH DE
  RET

__SCREEN:
  CP ','
  LD A,($F3E4)
  CALL NZ,GETINT
  CALL __SCREEN_SUB
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  RET Z
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
  CALL GETINT
  PUSH HL
  AND A
  CALL FNBAR_IF_NZ
  POP HL
  RET

; This entry point is used by the routine at GET_DEVICE.
__SCREEN_SUB:
  PUSH HL
  LD ($F3E4),A
  AND A
  LD DE,$2808
  LD HL,(CSR_ROW)
  LD A,$0E
  RST $38
  LD (HL),$CA
  LD C,H
  JR NZ,GETWORD_149
  LD ($F3E4),A
  RST $38
  LD H,B
  LD (CSRX),HL
  EX DE,HL
  LD (ACTV_X),HL
  LD (CLMLST),A
  POP HL
  RET
  
; This entry point is used by the routine at SCPTLP.
MERGE_SUB:
  PUSH HL
  CALL CHGET8
  CALL RESFPT
  LD HL,(FILNAM+6)
  LD DE,$2020
  RST CPDEHL
  PUSH AF
  JP Z,_MERGE_SUB_3
  LD DE,'B'+'A'*$100			; "BA" (as in filename string)
  RST CPDEHL
  JP NZ,_MERGE_SUB_5
_MERGE_SUB_3:
  CALL FINDBA
  JP Z,_MERGE_SUB_5
  POP AF
  POP BC
  POP AF
  JP Z,FCERR
  LD A,$00
  PUSH AF
  PUSH BC
  LD (DIRPNT),HL
  EX DE,HL
  LD (BASTXT),HL
  CALL UPD_PTRS
  POP HL
  LD A,(HL)
  CP ','
  JP NZ,_MERGE_SUB_4
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB 'R'
  POP AF
  LD A,$80
  SCF
  PUSH AF
_MERGE_SUB_4:
  POP AF
  LD (NLONLY),A
  JP C,RUN_FST
  CALL RUN_FST
  JP READY
  
_MERGE_SUB_5:
  POP AF
  POP HL
  LD D,$F9		; 'RAM' device
  JP NZ,__MERGE_0
  PUSH HL
  LD HL,$2020
  LD (FILNAM+6),HL			; clear file name ext
  POP HL
  JP __MERGE_0

; This entry point is used by the routine at SCPTLP.
__LCOPY_6:
  PUSH HL
  CALL CHGET8
  LD HL,(FILNAM+6)			; point to file name ext
  LD DE,'D'+'O'*$100		; "DO" (as in filename string)
  RST CPDEHL
  LD B,$00
  JP Z,__LCOPY_7
  LD DE,'B'+'A'*$100		; "BA" (as in filename string)
  RST CPDEHL
  LD B,$01
  JP Z,__LCOPY_7
  LD DE,$2020			; "  "
  RST CPDEHL
  LD B,$02
  JP NZ,NMERR			; NM error: bad file name

__LCOPY_7:
  POP HL
  PUSH BC
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JP Z,__LCOPY_9
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB 'A'
  POP BC
  DEC B
  JP Z,NMERR			; NM error: bad file name
__LCOPY_8:
  XOR A
  LD DE,$F902		; D = 'RAM' device, E = $02
  PUSH AF
  JP __SAVE_1

__LCOPY_9:
  POP BC
  DEC B
  JP M,__LCOPY_8
  CALL __NAME_2
  JP NZ,FCERR

;SAVEBA:
  CALL FINDBA
  CALL NZ,KILLASC_6
  CALL RESFPT_0
  CALL NXTDIR_0
  LD (DIRPNT),HL
  LD A,$80
  EX DE,HL
  LD HL,(BASTXT)
  EX DE,HL
  CALL MAKTXT_0
  CALL RESFPT_9
  JP READY
  
__FILES:
  RST $38
  INC (HL)
  PUSH HL
  CALL CATALOG
  POP HL
  JP CONSOLE_CRLF


; Display Catalog
;
; Used by the routine at __FILES.
CATALOG:
  LD HL,$F844
CATALOG_0:
  LD C,$03
  LD A,(ACTV_Y)
  CP 40
  JP Z,CATALOG_1
  LD C,$06		; 6 characters
CATALOG_1:
  CALL NXTDIR
  RET Z
  AND $18	; 24
  JP NZ,CATALOG_1
  PUSH HL
  INC HL
  LD E,(HL)
  INC HL
  LD D,(HL)
  INC HL
  PUSH DE
  
  LD B,$06		; 6 characters
CATALOG_2:
  LD A,(HL)
  RST OUTC
  INC HL
  DEC B
  JP NZ,CATALOG_2
  LD A,'.'
  RST OUTC
  LD A,(HL)
  RST OUTC
  INC HL
  LD A,(HL)
  RST OUTC
  POP DE
  LD HL,(BASTXT)
  RST CPDEHL
  LD A,'*'
  LD B,' '
  JP Z,CATALOG_3
  LD A,B
CATALOG_3:
  RST OUTC
  LD A,B
  RST OUTC
  RST OUTC
  POP HL
  DEC C
  JP NZ,CATALOG_1
  CALL OUTDO_CRLF
  PUSH HL
  LD HL,$0000
  CALL CHSNS_0
  POP HL
  JP CATALOG_0

__KILL:
  CALL __NAME_1
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JP NZ,SNERR
  LD A,D
  CP $F9		; 'RAM' device ?
  JP Z,__KILL_0
  RST $38
  DEFB $7E		; HKILL, Offset: 126
  ;LD A,(HL)
__KILL_0:
  PUSH HL
  CALL RESFPT_0
  CALL FINDFL
  JP Z,FFERR
  LD B,A
  AND $20
  JP NZ,KILLBIN_0
  LD A,B
  AND $40
  JP Z,KILLASC_5
  LD A,B
  AND $02
  JP NZ,AOERR

; Kill a text (.DO) file, DE=TOP addr, HL=adrress of dir entry.
KILLASC:
  LD A,$E5
  ; PUSH	HL  	; (KILLASC+1)
  LD BC,$0000
  LD (HL),C
  LD L,E
  LD H,D
KILLASC_0:
  LD A,(DE)
  INC DE
  INC BC
  CP $1A		; EOF
  JP NZ,KILLASC_0
  CALL MASDEL
KILLASC_1:
  CALL __EOF_4
  CALL RESFPT_0
  POP HL
  RET
  
; This entry point is used by the routine at GET_DEVICE.
KILLBIN:
  PUSH HL
KILLBIN_0:
  LD (HL),$00
  LD HL,(CO_FILES)
  PUSH HL
  EX DE,HL
  PUSH HL
  INC HL
  INC HL
  LD C,(HL)
  INC HL
  LD B,(HL)
  LD HL,$0006
  ADD HL,BC
  LD B,H
  LD C,L
  POP HL
  CALL MASDEL
  POP HL
  LD (CO_FILES),HL
  JP KILLASC_1

; This entry point is used by the routine at GET_DEVICE.
KILLASC_4:
  CALL RESFPT_0
  LD HL,($F887)
  EX DE,HL
  LD HL,SUZUKI+21
  JP KILLASC+1

KILLASC_5:
  PUSH HL
  LD HL,(BASTXT)
  RST CPDEHL
  POP HL
  JP Z,FCERR
  CALL KILLASC_6
  CALL _CLVAR
  JP READY

; This entry point is used by the routine at GET_DEVICE.
KILLASC_6:
  LD (HL),$00
  LD HL,(BASTXT)
  RST CPDEHL
  PUSH AF
  PUSH DE
  CALL UPD_PTRS_0
  POP DE
  INC HL
  CALL GETWORD_188
  PUSH BC
  CALL RESFPT_0
  POP BC
  POP AF
  RET Z
  RET C
  LD HL,(BASTXT)
  ADD HL,BC
  LD (BASTXT),HL
  RET

__NAME:
  CALL __NAME_1
  PUSH DE
  CALL SWAPNM
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB 'A'
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB 'S'
  CALL __NAME_1
  LD A,D
  POP DE
  CP D
  JP NZ,FCERR
  CP $F9		; D = 'RAM' device ?
  JP Z,__NAME_0
  
  RST $38
  ADD A,B	; HNAME, Offset:

__NAME_0:
  PUSH HL
  CALL FINDFL
  JP NZ,FCERR
  CALL SWAPNM
  CALL FINDFL
  JP Z,FFERR
  PUSH HL
  LD HL,(FILNAM+6)
  EX DE,HL
  LD HL,(FILNM2+6)
  RST CPDEHL			; compare file name extensions
  JP NZ,FCERR
  POP HL
  CALL SWAPNM
  INC HL
  INC HL
  INC HL
  CALL COPY_NAME
  POP HL
  RET

__NAME_1:
  CALL FILE_PARMS
  RET NZ
  LD D,$F9		; 'RAM' device
  RET

__NAME_2:
  LD HL,(DIRPNT)
  LD DE,SUZUKI-1
  RST CPDEHL
  RET


; Routine at 8329
;
; Used by the routines at CSAVEM and CLOADM.
FINDCO:
  LD BC,'C'*$100+'O'
  JP FIND_FILEXT

; This entry point is used by the routine at GET_DEVICE.
FINDCO_0:
  CALL CHGET8
  LD HL,(FILNAM+6)
  LD DE,$2020		; "  "
  RST CPDEHL
  JP Z,FINDDO
  LD DE,'D'+'O'*$100	; "DO" (as in filename string)
  RST CPDEHL
  JP NZ,NMERR			; NM error: bad file name

FINDDO:
  LD BC,'D'*$100+'O'
  JP FIND_FILEXT
  
FINDBA:
  LD BC,'B'*$100+'A'

FIND_FILEXT:
  LD HL,FILNAM+6
  LD (HL),B
  INC HL
  LD (HL),C

FINDFL:
  CALL CHGET8
  LD HL,$F844
  ;LD A,$E1
  DEFB $3E  ; "LD A,n" to Mask the next byte

; Routine at 8371
L22A2:
  POP HL
  CALL NXTDIR
  RET Z
  PUSH HL
  INC HL
  INC HL
  LD DE,$FB77
  LD B,$08
FINDFL_0:
  INC DE
  INC HL
  LD A,(DE)
  CP (HL)
  JP NZ,L22A2
  DEC B
  JP NZ,FINDFL_0
  POP HL
  LD A,(HL)
  INC HL
  LD E,(HL)
  INC HL
  LD D,(HL)
  DEC HL
  DEC HL
  AND A
  RET

NXTDIR:
  PUSH BC
  LD BC,$000B
  ADD HL,BC
  POP BC
  LD A,(HL)
  CP $FF
  RET Z
  AND A
  JP P,NXTDIR
  RET

NXTDIR_0:
  LD A,(ERRTRP-1)
  AND A
  LD HL,SUZUKI+21
  RET NZ
  LD HL,SUZUKI+21
  LD BC,$000B
NXTDIR_1:
  ADD HL,BC
  LD A,(HL)
  CP $FF
  JP Z,FLERR
  ADD A,A
  JP C,NXTDIR_1
  RET

__NEW:
  RET NZ
; This entry point is used by the routines at SCPTLP and GET_DEVICE.
CLRPTR:
  CALL __NAME_2
  CALL NZ,RESFPT
  CALL CLSALL		; Close all files
  LD HL,SUZUKI-1
  LD (DIRPNT),HL
  LD HL,(SUZUKI)
  LD (BASTXT),HL
  XOR A
  LD (PTRFLG),A
  LD (HL),A
  INC HL
  LD (HL),A
  INC HL
  EX DE,HL
  LD HL,(DO_FILES)
  CALL GETWORD_188
  LD HL,$0000
  LD (RAM_FILES),HL
  CALL RESFPT_0
  JP RUN_FST
  
; This entry point is used by the routine at GET_DEVICE.
__NEW_2:
  LD HL,(LBLIST)
  EX DE,HL
  LD HL,(LBEDIT)
GETWORD_188:
  LD A,L
  SUB E
  LD C,A
  LD A,H
  SBC A,D
  LD B,A
  EX DE,HL
  CALL MASDEL
  LD HL,(DO_FILES)
  ADD HL,BC
  LD (DO_FILES),HL
  RET
  
; This entry point is used by the routine at GET_DEVICE.
RESFPT:
  CALL GETPARM_VRFY
; This entry point is used by the routine at GET_DEVICE.
RESFPT_0:
  CALL RESFPT_3
  XOR A
  LD ($F745),A
  LD HL,(RAM)
  INC HL
RESFPT_0:
  PUSH HL
  LD HL,$F865
  LD DE,$FFFF
RESFPT_1:
  CALL NXTDIR
  JP Z,RESFPT_2
  CP $F0
  JP Z,RESFPT_1
  RRCA
  JP C,RESFPT_1
  PUSH HL
  INC HL
  LD A,(HL)
  INC HL
  LD H,(HL)
  LD L,A
  RST CPDEHL
  POP HL
  JP NC,RESFPT_1
  LD B,H
  LD C,L
  INC HL
  LD E,(HL)
  INC HL
  LD D,(HL)
  DEC HL
  DEC HL
  JP RESFPT_1
  
RESFPT_2:
  LD A,E
  AND D
  INC A
  POP DE
  JP Z,RESFPT_3
  LD H,B
  LD L,C
  LD A,(HL)
  OR $01
  LD (HL),A
  INC HL
  LD (HL),E
  INC HL
  LD (HL),D
  EX DE,HL
  CALL RESFPT_5
  JP RESFPT_0
  
RESFPT_3:
  LD HL,$F844
RESFPT_4:
  CALL NXTDIR
  RET Z
  AND $FE
  LD (HL),A
  JP RESFPT_4
  
RESFPT_5:
  LD A,($F745)
  DEC A
  JP M,RESFPT_8
  JP Z,RESFPT_6
  INC HL
  INC HL
  LD E,(HL)
  INC HL
  LD D,(HL)
  INC HL
  INC HL
  INC HL
  ADD HL,DE
  RET
  
RESFPT_6:
  LD A,$1A		; EOF
RESFPT_7:
  CP (HL)
  INC HL
  JP NZ,RESFPT_7
  EX DE,HL
  LD HL,(CO_FILES)
  EX DE,HL
  RST CPDEHL
  RET NZ
  LD A,$02
  LD ($F745),A
  RET

RESFPT_8:
  EX DE,HL
  CALL UPD_PTRS_0
  INC HL
  EX DE,HL
  LD HL,(DO_FILES)
  EX DE,HL
  RST CPDEHL
  RET NZ
  LD A,$01
  LD ($F745),A
  RET
  
RESFPT_9:
  LD HL,(PROGND)
  LD (VAREND),HL
  LD (ARREND),HL
  LD HL,(DO_FILES)
  DEC HL
  LD (SUZUKI),HL
  INC HL
  LD BC,$0002
  EX DE,HL
  CALL MAKHOL_0
  XOR A
  LD (HL),A
  INC HL
  LD (HL),A
  LD HL,(DO_FILES)
  ADD HL,BC
  LD (DO_FILES),HL
  JP RESFPT_0


; Count the number of characters in (HL), null terminated
;
; Used by the routines at OPENDO, TEL_UPLD and TXT_CTL_G.
COUNT_CHARS:
  PUSH HL
  LD E,$FF
COUNT_CHARS_0:
  INC E
  LD A,(HL)
  INC HL
  AND A
  JP NZ,COUNT_CHARS_0
  POP HL
  RET

; This entry point is used by the routine at GET_DEVICE.
OPENDO:
  CALL COUNT_CHARS
  CALL FNAME
  JP NZ,SNERR
  
MAKTXT:
  CALL RESFPT_0
  CALL FINDCO_0
  EX DE,HL
  SCF
  RET NZ
  CALL NXTDIR_0
  PUSH HL
  LD HL,(DO_FILES)
  PUSH HL
  LD A,$1A		; EOF
  CALL INSCHR
  JP C,OMERR
  POP DE
  POP HL
  PUSH HL
  PUSH DE
  LD A,$C0
  DEC DE
  CALL MAKTXT_0
  CALL RESFPT_0
  POP HL
  POP DE
  AND A
  RET

; This entry point is used by the routines at SAVEBA and CSAVEM.
MAKTXT_0:
  PUSH DE
  LD (HL),A
  INC HL
  LD (HL),E
  INC HL
  LD (HL),D
  INC HL

  DEFB $3E  ; "LD A,n" to Mask the next byte
;  LD A,$D5

; Used by the routine at __NAME.
COPY_NAME:
  PUSH DE
  LD DE,FILNAM
  LD B,$08
  CALL REV_LDIR_B
  POP DE
  RET

SWAPNM:
  PUSH HL
  LD B,$09
  LD DE,FILNAM
  LD HL,FILNM2
SWAPNM_0:
  LD C,(HL)
  LD A,(DE)
  LD (HL),A
  LD A,C
  LD (DE),A
  INC DE
  INC HL
  DEC B
  JP NZ,SWAPNM_0
  POP HL
  RET
 
CHGET8:
  PUSH HL
  LD HL,FILNAM+6
  LD B,$03
CHGET9:
  CALL UCASE_HL
  LD (HL),A
  INC HL
  DEC B
  JP NZ,CHGET9
  POP HL
  RET

; This entry point is used by the routines at CHKSTK and GET_DEVICE.
SWAPNM_1:
  CALL RESFPT_0
  LD HL,$FFFF
  LD (PASPNT),HL
  LD B,H
  LD C,L
  LD HL,(HAYASHI)		; Paste buffer file
  PUSH HL
  LD A,$1A		; EOF
SWAPNM_2:
  CP (HL)
  INC BC
  INC HL
  JP NZ,SWAPNM_2
  POP HL
  CALL MASDEL
  JP RESFPT_0

; This entry point is used by the routine at GET_DEVICE.
GETWORD_212:
  PUSH AF
  CALL CONSOLE_CRLF
  CALL ERAEOL
  POP AF
  ADD A,A
  ADD A,A
  JP C,GETWORD_218
  JP M,GETWORD_225
  RST $38
  INC A
  LD HL,(SUZUKI)
  LD (BASTXT),HL
  CALL CHGDSP_15
  LD A,B
  OR C
  JP Z,CLOAD_STOP
  LD (DATPTR),HL
  PUSH HL
  CALL GETWORD_256
  LD HL,GETWORD_217
  LD (ERRTRP),HL
  CALL GETWORD_294
  DI
  POP DE
  PUSH DE
  LD HL,(BASTXT)
GETWORD_213:
  LD B,$0A
GETWORD_214:
  CALL CASIN
  LD (HL),A
  LD C,A
  INC HL
  RST CPDEHL
  JP NC,GETWORD_217
  LD A,C
  AND A
  JP NZ,GETWORD_213
  DEC B
  JP NZ,GETWORD_214
  CALL CTOFF
  CALL UPD_PTRS
  INC HL
  POP DE
  CALL GETWORD_255
  CALL GETWORD_224
  CALL NXTDIR_0
  LD A,$80
  EX DE,HL
  LD HL,(SUZUKI)
  EX DE,HL
GETWORD_215:
  DEC DE
GETWORD_216:
  CALL MAKTXT_0
  JP __MENU
  
GETWORD_217:
  CALL CTOFF
  LD HL,(BASTXT)
  EX DE,HL
  LD HL,(DATPTR)
  EX DE,HL
  CALL GETWORD_255
  JP CLOAD_STOP
GETWORD_218:
  LD HL,BLANK_BYTE
  XOR A
  LD (FNAME_END),A
  LD E,$01
  CALL _OPEN
  LD HL,GETWORD_222
  LD (ERRTRP),HL
  CALL CHGDSP_14
  LD A,B
  OR C
  JP Z,GETWORD_223
  LD H,B
  LD L,C
  LD (DATPTR),HL
  LD HL,(DO_FILES)
  LD (TEMP),HL
GETWORD_219:
  CALL RDBYT
  JP C,GETWORD_220
  CALL DWNLDR_6
  JP Z,GETWORD_219
  CALL C,GETWORD_221
  CALL GETWORD_221
  JP GETWORD_219
GETWORD_220:
  LD (HL),$1A
  CALL SCPTLP_104
  CALL GETWORD_224
  CALL NXTDIR_0
  LD A,$C0
  EX DE,HL
  LD HL,(DO_FILES)
  EX DE,HL
  JP GETWORD_215
GETWORD_221:
  LD (HL),A
  INC HL
  LD A,(HL)
  AND A
  LD A,$0A
  RET Z
  
GETWORD_222:
  LD HL,(DATPTR)
  LD B,H
  LD C,L
  LD HL,(TEMP)
  CALL MASDEL
GETWORD_223:
  CALL SCPTLP_104
  JP CLOAD_STOP

GETWORD_224:
  LD B,$09
  LD DE,FILNAM
  LD HL,$F99B
  JP LDIR_B

GETWORD_225:
  RST $38
  LD A,$CD
  LD (DE),A
  LD HL,($E32A)
  JP M,EVAL_STR_1
  JP NZ,GET_DEVICE_693
  LD BC,$0006
  ADD HL,BC
  LD (DATPTR),HL
  LD B,H
  LD C,L
  LD HL,(PROGND)
  LD (TEMP),HL
  CALL MAKHOL
  JP C,CLOAD_STOP
  EX DE,HL
  LD HL,TOP
  CALL CLOADM_8
  PUSH DE
  LD HL,GETWORD_226
  LD (ERRTRP),HL
  CALL CAS_OPNI_CO_10
  POP HL
  POP DE
  CALL LOAD_RECORD
  JP NZ,GETWORD_226
  CALL CTOFF
  POP HL
  LD (CO_FILES),HL
  CALL GETWORD_224
  CALL NXTDIR_0
  LD A,$A0
  EX DE,HL
  LD HL,(PROGND)
  EX DE,HL
  JP GETWORD_216

GETWORD_226:
  CALL CTOFF
  JP GETWORD_222

__CSAVE:
  CALL GETWORD_277
; This entry point is used by the routine at SCPTLP.
GETWORD_227:
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JP Z,GETWORD_228
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB 'A'
  LD E,$02
  AND A
  PUSH AF
  JP __SAVE_1
GETWORD_228:
  LD HL,$FB7D
  LD B,$06
GETWORD_229:
  LD A,(HL)
  SUB $20
  JP NZ,GETWORD_230
  LD (HL),A
  DEC HL
  DEC B
  JP NZ,GETWORD_229
GETWORD_230:
  CALL GETPARM_VRFY
  INC HL
  PUSH HL
  CALL IOOPRND_0
  LD B,$0A
GETWORD_231:
  LD A,$D3
  CALL CSOUT
  DEC B
  JP NZ,GETWORD_231
  LD B,$06
  LD HL,FILNAM
GETWORD_232:
  LD A,(HL)
  CALL CSOUT
  INC HL
  DEC B
  JP NZ,GETWORD_232
  LD BC,$4E20
GETWORD_233:
  DEC BC
  LD A,B
  OR C
  JP NZ,GETWORD_233
  POP DE
  LD HL,(BASTXT)
GETWORD_234:
  LD A,(HL)
  CALL CSOUT
  INC HL
  RST CPDEHL
  JP NZ,GETWORD_234
  LD B,$09
GETWORD_235:
  XOR A
  CALL CSOUT
  DEC B
  JP NZ,GETWORD_235
  LD BC,$1F40
GETWORD_236:
  DEC BC
  LD A,B
  OR C
  JP NZ,GETWORD_236
  CALL CTOFF
GETWORD_237:
  LD A,(MENU_FLG)
  AND A
  JP NZ,GET_DEVICE_100
  JP RESTART
  
__BSAVE:
  CALL __NAME_1
  LD A,D
  CP $FD
  JP Z,GETWORD_238
  CP $F9
  JP Z,GETWORD_240
  RST $38
  ADD A,D
GETWORD_238:
  CALL CSAVEM_2
  CALL $2989
  CALL CAS_OPNO_CO_3
  LD HL,(PRLEN)
  EX DE,HL
  LD HL,(TOP)
  LD C,$00
GETWORD_239:
  LD A,(HL)
  CALL CSOUT
  INC HL
  DEC DE
  LD A,D
  OR E
  JP NZ,GETWORD_239
  CALL CAS_OPNO_CO_1
  JP GETWORD_237
  
GETWORD_240:
  CALL CSAVEM_2
  CALL RESFPT_0
  CALL FINDCO
  CALL NZ,KILLBIN
  CALL NXTDIR_0
  PUSH HL
  LD HL,(CO_FILES)
  PUSH HL
  LD HL,(PRLEN)
  LD A,H
  OR L
  JP Z,OMERR
  PUSH HL
  LD BC,$0006		; 6 characters
  ADD HL,BC
  LD B,H
  LD C,L
  LD HL,(PROGND)
  LD (TEMP),HL
  CALL NC,MAKHOL
  JP C,OMERR
  EX DE,HL
  LD HL,TOP
  CALL CLOADM_8
  LD HL,(TOP)
  POP BC
  CALL _LDIR
  POP HL
  LD (CO_FILES),HL
  POP HL
  LD A,$A0
  EX DE,HL
  LD HL,(TEMP)
  EX DE,HL
  CALL MAKTXT_0
  CALL RESFPT_0
  JP RESTART
  
CSAVEM_2:
  CALL GETWORD_242
  PUSH DE
  CALL GETWORD_242
  LD A,D
  OR E
  JP Z,FCERR
  PUSH DE
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  LD DE,$0000
  CALL NZ,GETWORD_242
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JP NZ,SNERR
  EX DE,HL
  LD (EXE),HL
  POP DE
  POP HL
  LD (TOP),HL
  ADD HL,DE
  JP C,FCERR
  EX DE,HL
  LD (PRLEN),HL
  RET
  
GETWORD_242:
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
  JP GETWORD
  
__CLOAD:
  CP $91		; TK_PRINT  (=CLOAD?)
  JP Z,CVERIFY
  CALL GETWORD_274
  OR $FF
  PUSH AF
; This entry point is used by the routine at SCPTLP.
__CLOAD_0:
  POP AF
  PUSH AF
  JP NZ,__CLOAD_1
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JP NZ,FCERR
__CLOAD_1:
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  LD A,$00
  SCF
  CCF
  JP Z,__CLOAD_2
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB 'R'
  JP NZ,SNERR
  POP AF
  SCF
  PUSH AF
  LD A,$80
__CLOAD_2:
  PUSH AF
  LD (NLONLY),A
  POP BC
  POP AF
  PUSH AF
  PUSH BC
  JP Z,__CLOAD_3
  CALL GETPARM_VRFY
  CALL RESFPT_0
  LD HL,(SUZUKI)
  LD (BASTXT),HL
  LD HL,SUZUKI-1
  LD (DIRPNT),HL
  LD HL,(PROGND)
  LD (VAREND),HL
  LD (ARREND),HL
  CALL CHGDSP_14
  CALL GETWORD_256
  LD HL,$27E4
  LD (ERRTRP),HL
__CLOAD_3:
  CALL GETWORD_298
  JP Z,__CLOAD_5
  CP $9C		; DO file type
  JP Z,LOAD_RECORD_2
__CLOAD_4:
  CALL FNBAR_IF_NZ4
  CALL CONSOLE_CRLF
  JP __CLOAD_3

__CLOAD_5:
  CALL GETWORD_285
  JP NZ,__CLOAD_3
  CALL GETWORD_287
  JP NZ,__CLOAD_4
  POP BC
  POP AF
  PUSH AF
  PUSH BC
  JP Z,__CLOAD_4
  POP AF
  POP AF
  SBC A,A
  LD (FILFLG),A
  CALL CAS_OPNI_CO_12
  DI
  LD HL,(DO_FILES)
  EX DE,HL
  LD HL,(BASTXT)
__CLOAD_6:
  LD B,$0A
__CLOAD_7:
  CALL CASIN
  LD (HL),A
  LD C,A
  INC HL
  RST CPDEHL
  JP NC,GETWORD_253
  LD A,C
  AND A
  JP NZ,__CLOAD_6
  DEC B
  JP NZ,__CLOAD_7
  CALL UPD_PTRS
  INC HL
  EX DE,HL
  LD HL,(DO_FILES)
  EX DE,HL
  CALL GETWORD_255
  XOR A
  LD L,A
  LD H,A
  LD (ERRTRP),HL
  CALL CTOFF
  CALL CONSOLE_CRLF
  CALL RUN_FST
  LD A,(FILFLG)
  AND A
  JP NZ,EXEC_EVAL_0
  JP READY
  
LOAD_RECORD:
  LD C,$00
GETWORD_252:
  CALL CASIN
  LD (HL),A
  INC HL
  DEC DE
  LD A,D
  OR E
  JP NZ,GETWORD_252
  CALL CASIN
  LD A,C
  AND A
  RET
  
  CALL GETWORD_254
  LD HL,$0000
  LD (ERRTRP),HL
  JP HEADER_0
  
GETWORD_253:
  CALL GETWORD_254
  LD HL,$0000
  LD (ERRTRP),HL
  CALL CTOFF
  JP OMERR
  
GETWORD_254:
  LD HL,(DO_FILES)
  EX DE,HL
  LD HL,(BASTXT)
  XOR A
  LD (HL),A
  INC HL
  LD (HL),A
  INC HL
GETWORD_255:
  LD A,E
  SUB L
  LD C,A
  LD A,D
  SBC A,H
  LD B,A
  CALL MASDEL
; This entry point is used by the routine at SNERR.
GETWORD_256:
  LD HL,(DO_FILES)
  ADD HL,BC
  LD (DO_FILES),HL
  RET
  
LOAD_RECORD_2:
  CALL CAS_OPNI_CO_12
  CALL CONSOLE_CRLF
  POP BC
  POP AF
  PUSH AF
  PUSH BC
  CALL NZ,GETWORD_254
  LD HL,$0000
  LD (ERRTRP),HL
  LD HL,(FILTAB)
  LD A,(HL)
  INC HL
  LD H,(HL)
  LD L,A
  LD (PTRFIL),HL			; Redirect I/O
  LD (HL),$01
  INC HL
  INC HL
  INC HL
  INC HL
  LD (HL),$FD		; 'CAS' device ?
  INC HL
  INC HL
  XOR A
  LD (HL),A
  INC HL
  LD (HL),A
  LD (CASPRV),A
  JP __MERGE_3
  
CVERIFY:
  PUSH HL
  CALL GETPARM_VRFY
  INC HL
  EX (SP),HL
  CALL CAS_OPNI_BA
  PUSH HL
  CALL GETWORD_294
  DI
  POP HL
  POP DE
  PUSH HL
  LD HL,(BASTXT)
GETWORD_259:
  CALL CASIN
  CP (HL)
  JP NZ,VERIFY_ERROR
  INC HL
  RST CPDEHL
  JP C,GETWORD_259
GETWORD_260:
  CALL CTOFF
  POP HL
  RET

VERIFY_ERROR:
  LD HL,$287B
  CALL PRINT_LINE
  JP GETWORD_260
  LD B,D
  LD H,C
  LD H,H
  DEC C
  LD A,(BC)
  NOP

__BLOAD:
  CP $91		; TK_PRINT
  JP Z,CVERIFYM
  CALL __NAME_1
  LD A,D
  CP $FD
  JP Z,GETWORD_262
  CP $F9
  JP Z,CLOADM_RAM
  RST $38
  ADD A,H
GETWORD_262:
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JP NZ,SNERR
  PUSH HL
  CALL $2A12
  CALL _CLOAD_PARMS
  JP C,OMERR
  CALL CAS_OPNI_CO_10
  LD HL,(PRLEN)
  EX DE,HL
  LD HL,(TOP)
  CALL LOAD_RECORD
  JP NZ,HEADER_0
  CALL CTOFF
  JP GETWORD_264
  
CLOADM_RAM:
  PUSH HL
  CALL RESFPT_0
  CALL FINDCO
  JP Z,FFERR
  EX DE,HL
  CALL CLOADM_7
  PUSH HL
  CALL _CLOAD_PARMS
  JP C,OMERR
  LD HL,(PRLEN)
  LD B,H
  LD C,L
  LD HL,(TOP)
  EX DE,HL
  POP HL
  CALL _LDIR
GETWORD_264:
  POP HL
  RET

_CLOAD_PARMS:
  LD HL,(HIMEM)
  EX DE,HL
  LD HL,(TOP)
  RST CPDEHL
  RET C
  EX DE,HL
  LD HL,(PRLEN)
  ADD HL,DE
  EX DE,HL
  LD HL,MAXRAM
  RST $38
  LD B,H
  RST CPDEHL
  LD HL,(TOP)
  RET

; This entry point is used by the routine at GET_DEVICE.
CLOADM_7:
  LD DE,TOP
CLOADM_8:
  LD B,$06

; Move memory pointed to by HL to the memory pointed to by DE for B number of
; bytes.
;
; Used by the routines at RAM_INPUT, GET_DAY, CHGDSP, TXT_CTL_L, LOAD_BA_LBL,
; SET_CLOCK_HL and BOOT.
LDIR_B:
  LD A,(HL)
  LD (DE),A
  INC HL
  INC DE
  DEC B
  JP NZ,LDIR_B
  RET

; This entry point is used by the routine at GET_DEVICE.
LDIR_B_0:
  CALL CLOADM_7
  PUSH HL
  CALL _CLOAD_PARMS
  JP C,CLOAD_STOP
  EX DE,HL
  LD HL,(PRLEN)
  LD B,H
  LD C,L
  POP HL
  CALL _LDIR
  LD HL,(EXE)
  LD A,H
  OR L
  LD (LASTCALL),HL
  CALL NZ,PIVOTCALL
  JP __MENU
  
CLOAD_STOP:
  CALL __BEEP
  JP __MENU
  
CVERIFYM:
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  CALL __NAME_1
  CALL GETWORD_279
  PUSH HL
  CALL $2A12
  CALL CAS_OPNI_CO_10
  LD HL,(PRLEN)
  EX DE,HL
  LD HL,(TOP)
  CALL GETWORD_272
  JP NZ,VERIFY_ERROR
  CALL CTOFF
  POP HL
  RET

; This entry point is used by the routine at LOAD_RECORD.
GETWORD_272:
  LD C,$00
GETWORD_273:
  CALL CASIN
  CP (HL)
  RET NZ
  INC HL
  DEC DE
  LD A,D
  OR E
  JP NZ,GETWORD_273
  CALL CASIN
  LD A,C
  AND A
  RET
GETWORD_274:
  DEC HL
CAS_OPNI_BA:
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JP NZ,GETWORD_277
  LD B,$06
  LD DE,FILNAM
  LD A,' '
GETWORD_276:
  LD (DE),A
  INC DE
  DEC B
  JP NZ,GETWORD_276
  JP GETWORD_278

GETWORD_277:
  CALL FILE_PARMS
  JP NZ,GETWORD_279

GETWORD_278:
  LD D,$FD
GETWORD_279:
  LD A,D
  CP $FD
  JP NZ,FCERR
  RET

CAS_OPNO_DO:
  LD A,$9C		; DO type

  defb $01	; LD BC,NN

; CAS open for output for Command files
;
; Used by the routine at CSAVEM.
;  LD BC,$D03E

CAS_OPNO_CO:
  LD A,$D0		; CO type
  PUSH AF
  CALL IOOPRND_0
  POP AF
  CALL CSOUT
  LD C,$00
  LD HL,FILNAM
  LD DE,$0602		; D=6, E=2
CAS_OPNO_CO_0:
  LD A,(HL)
  CALL CSOUT
  INC HL
  DEC D
  JP NZ,CAS_OPNO_CO_0
  LD HL,TOP
  LD D,$0A			; 10
  DEC E
  JP NZ,CAS_OPNO_CO_0
CAS_OPNO_CO_1:
  LD A,C
  CPL
  INC A
  CALL CSOUT
  LD B,$14			; 20
CAS_OPNO_CO_2:
  XOR A
  CALL CSOUT
  DEC B
  JP NZ,CAS_OPNO_CO_2
  JP CTOFF

CAS_OPNO_CO_3:
  CALL IOOPRND_0
  LD A,$8D
  JP CSOUT

GETWORD_285:
  LD B,$09
GETWORD_286:
  CALL CASIN
  CP $D3
  RET NZ
  DEC B
  JP NZ,GETWORD_286
  RET
GETWORD_287:
  LD B,$06
  LD HL,FILNM2
GETWORD_288:
  CALL CASIN
  LD (HL),A
  INC HL
  DEC B
  JP NZ,GETWORD_288
GETWORD_289:
  LD HL,FILNAM
  LD B,$06
  LD A,' '
GETWORD_290:
  CP (HL)
  JP NZ,GETWORD_291
  INC HL
  DEC B
  JP NZ,GETWORD_290
  RET
GETWORD_291:
  LD HL,FILNAM
  LD DE,FILNM2
  LD B,$06
GETWORD_292:
  LD A,(DE)
  AND A
  JP NZ,GETWORD_293
  LD A,' '
GETWORD_293:
  CP (HL)
  RET NZ
  INC DE
  INC HL
  DEC B
  JP NZ,GETWORD_292
  RET
GETWORD_294:
  LD B,$D3
  LD DE,$9C06
  LD DE,$D006
  PUSH BC
GETWORD_295:
  CALL GETWORD_298
  JP NZ,GETWORD_296
  CALL GETWORD_285
  JP NZ,GETWORD_295
  CALL GETWORD_287
  JP NZ,GETWORD_297
  LD A,$D3
GETWORD_296:
  POP BC
  CP B
  JP Z,CAS_OPNI_CO_12
  PUSH BC
GETWORD_297:
  CALL FNBAR_IF_NZ4
  CALL CONSOLE_CRLF
  JP GETWORD_295
GETWORD_298:
  CALL HEADER
  CALL CASIN
  CP $D3
  RET Z
  CP $9C
  JP Z,GETWORD_299
  CP $D0
  JP NZ,GETWORD_298
GETWORD_299:
  PUSH AF
  LD HL,FILNM2
  LD DE,$0602
  LD C,$00
FNBAR_IF_NZ0:
  CALL CASIN
  LD (HL),A
  INC HL
  DEC D
  JP NZ,FNBAR_IF_NZ0
  LD HL,TOP
  LD D,$0A
  DEC E
  JP NZ,FNBAR_IF_NZ0
  CALL CASIN
  LD A,C
  AND A
  JP NZ,FNBAR_IF_NZ2
  CALL CTOFF
  CALL GETWORD_289
  JP NZ,FNBAR_IF_NZ1
  POP AF
  AND A
  RET

FNBAR_IF_NZ1:
  CALL FNBAR_IF_NZ4
  CALL CONSOLE_CRLF
FNBAR_IF_NZ2:
  POP AF
  JP GETWORD_298
CAS_OPNI_CO_10:
  CALL HEADER
  CALL CASIN
  CP $8D
  JP NZ,HEADER_0
  RET

FNBAR_IF_NZ4:
  LD DE,$2AC6
  JP FNBAR_IF_NZ6
CAS_OPNI_CO_12:
  LD DE,$2ABF
FNBAR_IF_NZ6:
  LD HL,(CURLIN)
  INC HL
  LD A,H
  OR L
  RET NZ
  EX DE,HL
  CALL PRINT_LINE
  XOR A
  LD (FILNM2+6),A
  LD HL,FILNM2
  CALL PRS
  LD A,$0D
  LD HL,CSRY
  SUB (HL)
  RET C
  RET Z
  LD B,A
  LD A,' '
FNBAR_IF_NZ7:
  RST OUTC
  DEC B
  JP NZ,FNBAR_IF_NZ7
  RET

  
FOUND_MSG:
  DEFM "Found:"
  DEFB $00
  
SKIP_MSG:
  DEFM "Skip :"
  DEFB $00


EVAL_STR:
  CALL GETSTR
  LD A,(HL)
  INC HL
  LD C,(HL)
  INC HL
  LD B,(HL)
  POP DE
  PUSH BC
  PUSH AF
  CALL GSTRDE
  POP AF
  LD D,A
  LD E,(HL)
  INC HL
  LD C,(HL)
  INC HL
  LD B,(HL)
  POP HL
EVAL_STR_0:
  LD A,E
  OR D
EVAL_STR_1:
  RET Z
  LD A,D
  SUB $01
  RET C
  XOR A
  CP E
  INC A
  RET NC
  DEC D
  DEC E
  LD A,(BC)
  INC BC
  CP (HL)
  INC HL
  JP Z,EVAL_STR_0
  CCF
  JP EVAL_RESULT

; STR BASIC function entry
__STR_S:
  CALL FOUT
  CALL CRTST
  CALL GSTRCU

; Save string in string area
SAVSTR:
  LD BC,TOPOOL
  PUSH BC
; This entry point is used by the routine at __DATA.
SAVSTR_0:
  LD A,(HL)
  INC HL
  PUSH HL
  CALL TESTR
  POP HL
  LD C,(HL)
  INC HL
  LD B,(HL)
  CALL CRTMST			; Make temporary string
  PUSH HL
  LD L,A
  CALL TOSTRA
  POP DE
  RET
  
; This entry point is used by the routines at GSTRDE and SCPTLP.
MK_1BYTE_TMST:
  LD A,$01

; Make temporary string
;
; Used by the routines at GETWORD, CONCAT, TOPOOL and SCPTLP.
MKTMST:
  CALL TESTR

; Create temporary string entry
;
; Used by the routines at SAVSTR, DTSTR and TOPOOL.
CRTMST:
  LD HL,TMPSTR
  PUSH HL
  LD (HL),A
  INC HL
  LD (HL),E
  INC HL
  LD (HL),D
  POP HL
  RET

; Create String
;
; Used by the routines at __DATA, __STR_S and PRS.
CRTST:
  DEC HL

; Create quote terminated String
;
; Used by the routines at __DATA and OPRND.
QTSTR:
  LD B,$22
; This entry point is used by the routines at __DATA and SCPTLP.
QTSTR_0:
  LD D,B

; Create String, termination char in D
;
; Used by the routine at __DATA.
DTSTR:
  PUSH HL
  LD C,$FF
DTSTR_0:
  INC HL
  LD A,(HL)
  INC C
  OR A
  JP Z,DTSTR_1
  CP D
  JP Z,DTSTR_1
  CP B
  JP NZ,DTSTR_0
DTSTR_1:
  CP '"'
  CALL Z,_CHRGTB
  EX (SP),HL
  INC HL
  EX DE,HL
  LD A,C
  CALL CRTMST			; Make temporary string

; Temporary string to pool
;
; Used by the routines at GETWORD, CONCAT, TOPOOL and SCPTLP.
TSTOPL:
  LD DE,TMPSTR
  LD A,$D5
  LD HL,(TEMPPT)
  LD (DBL_FPREG),HL
  LD A,$03
  LD (VALTYP),A
  CALL FP2HL
  LD DE,FRETOP
  RST CPDEHL
  LD (TEMPPT),HL
  POP HL
  LD A,(HL)
  RET NZ
  LD DE,CHRGTB
  JP ERROR

; Print number string
PRNUMS:
  INC HL

; Create string entry and print it
;
; Used by the routines at SNERR, __DATA, GETWORD, _DBL_ASCTFP, ISFLIO, SCPTLP and
; GET_DEVICE.
PRS:
  CALL CRTST

; Print string at HL
;
; Used by the routine at __DATA.
PRS1:
  CALL GSTRCU
  CALL LOADFP_0
  INC D
PRS1_0:
  DEC D
  RET Z
  LD A,(BC)
  RST OUTC
  CP $0D
  CALL Z,SCPTLP_46
  INC BC
  JP PRS1_0

; Test if enough room for string
;
; Used by the routines at SAVSTR, MKTMST and TOPOOL.
TESTR:
  OR A
  LD C,$F1
  PUSH AF
  LD HL,(STKTOP)
  EX DE,HL
  LD HL,(FRETOP)
  CPL
  LD C,A
  LD B,$FF
  ADD HL,BC
  INC HL
  RST CPDEHL
  JP C,TESTR_1
  LD (FRETOP),HL
  INC HL
  EX DE,HL
; This entry point is used by the routine at MAKINT.
TESTR_0:
  POP AF
  RET
TESTR_1:
  POP AF
  LD DE,$000E
  JP Z,ERROR
  CP A
  PUSH AF
  LD BC,$2B8B
  PUSH BC
; This entry point is used by the routine at MIDNUM.
TESTR_2:
  LD HL,(MEMSIZ)
TESTR_3:
  LD (FRETOP),HL
  LD HL,$0000
  PUSH HL
  LD HL,(ARREND)
  PUSH HL
  LD HL,TEMPST
  EX DE,HL
  LD HL,(TEMPPT)
  EX DE,HL
  RST CPDEHL
  LD BC,$2BC3
  JP NZ,TESTR_9
  LD HL,PRMPRV
  LD ($FB15),HL
  LD HL,(VAREND)
  LD ($FB12),HL
  LD HL,(PROGND)
TESTR_4:
  EX DE,HL
  LD HL,($FB12)
  EX DE,HL
  RST CPDEHL
  JP Z,TESTR_6
  LD A,(HL)
  INC HL
  INC HL
  INC HL
  CP $03
  JP NZ,TESTR_5
  CALL TESTR_10
  XOR A
TESTR_5:
  LD E,A
  LD D,$00
  ADD HL,DE
  JP TESTR_4
TESTR_6:
  LD HL,($FB15)
  LD E,(HL)
  INC HL
  LD D,(HL)
  LD A,D
  OR E
  LD HL,(VAREND)
  JP Z,TESTR_8
  EX DE,HL
  LD ($FB15),HL
  INC HL
  INC HL
  LD E,(HL)
  INC HL
  LD D,(HL)
  INC HL
  EX DE,HL
  ADD HL,DE
  LD ($FB12),HL
  EX DE,HL
  JP TESTR_4
TESTR_7:
  POP BC
TESTR_8:
  EX DE,HL
  LD HL,(ARREND)
  EX DE,HL
  RST CPDEHL
  JP Z,TESTR_11
  LD A,(HL)
  INC HL
  CALL LOADFP
  PUSH HL
  ADD HL,BC
  CP $03
  JP NZ,TESTR_7
  LD (TEMP8),HL
  POP HL
  LD C,(HL)
  LD B,$00
  ADD HL,BC
  ADD HL,BC
  INC HL
  EX DE,HL
  LD HL,(TEMP8)
  EX DE,HL
  RST CPDEHL
  JP Z,TESTR_8
  LD BC,$2C3C
TESTR_9:
  PUSH BC
TESTR_10:
  XOR A
  OR (HL)
  INC HL
  LD E,(HL)
  INC HL
  LD D,(HL)
  INC HL
  RET Z
  LD B,H
  LD C,L
  LD HL,(FRETOP)
  RST CPDEHL
  LD H,B
  LD L,C
  RET C
  POP HL
  EX (SP),HL
  RST CPDEHL
  EX (SP),HL
  PUSH HL
  LD H,B
  LD L,C
  RET NC
  POP BC
  POP AF
  POP AF
  PUSH HL
  PUSH DE
  PUSH BC
  RET
TESTR_11:
  POP DE
  POP HL
  LD A,H
  OR L
  RET Z
  DEC HL
  LD B,(HL)
  DEC HL
  LD C,(HL)
  PUSH HL
  DEC HL
  LD L,(HL)
  LD H,$00
  ADD HL,BC
  LD D,B
  LD E,C
  DEC HL
  LD B,H
  LD C,L
  LD HL,(FRETOP)
  CALL __POS_2
  POP HL
  LD (HL),C
  INC HL
  LD (HL),B
  LD H,B
  LD L,C
  DEC HL
  JP TESTR_3

; String concatenation
;
; Used by the routine at EVAL_04.
CONCAT:
  PUSH BC
  PUSH HL
  LD HL,(DBL_FPREG)
  EX (SP),HL
  CALL OPRND
  EX (SP),HL
  CALL TSTSTR
  LD A,(HL)
  PUSH HL
  LD HL,(DBL_FPREG)
  PUSH HL
  ADD A,(HL)
  LD DE,$000F			; Err $0F - "String too long"
  JP C,ERROR
  CALL MKTMST
  POP DE
  CALL GSTRDE
  EX (SP),HL
  CALL GSTRHL
  PUSH HL
  LD HL,(TMPSTR)
  EX DE,HL
  CALL SSTSA
  CALL SSTSA
  LD HL,EVAL2
  EX (SP),HL
  PUSH HL
  JP TSTOPL

; Move string on stack to string area
;
; Used by the routine at CONCAT.
SSTSA:
  POP HL
  EX (SP),HL
  LD A,(HL)
  INC HL
  LD C,(HL)
  INC HL
  LD B,(HL)
  LD L,A

; Move string in BC, (len in L) to string area
;
; Used by the routines at SAVSTR and TOPOOL.
TOSTRA:
  INC L

; TOSTRA loop
TSALP:
  DEC L
  RET Z
  LD A,(BC)
  LD (DE),A
  INC BC
  INC DE
  JP TSALP

; Get string pointed by FPREG 'Type Error' if it is not
;
; Used by the routines at GETWORD, GSTRDE, MIDNUM and SCPTLP.
GETSTR:
  CALL TSTSTR

; Get string pointed by FPREG
;
; Used by the routines at __STR_S, PRS1 and MIDNUM.
GSTRCU:
  LD HL,(DBL_FPREG)

; Get string pointed by HL
;
; Used by the routines at CONCAT, MIDNUM and SCPTLP.
GSTRHL:
  EX DE,HL

; Get string pointed by DE
;
; Used by the routines at GETWORD, CONCAT and TOPOOL.
GSTRDE:
  CALL BAKTMP
  EX DE,HL
  RET NZ
  PUSH DE
  LD D,B
  LD E,C
  DEC DE
  LD C,(HL)
  LD HL,(FRETOP)
  RST CPDEHL
  JP NZ,GSTRDE_0
  LD B,A
  ADD HL,BC
  LD (FRETOP),HL
GSTRDE_0:
  POP HL
  RET
; This entry point is used by the routine at __DATA.
BAKTMP:
  LD HL,(TEMPPT)
  DEC HL
  LD B,(HL)
  DEC HL
  LD C,(HL)
  DEC HL
  RST CPDEHL
; This entry point is used by the routine at TOPOOL.
GSTRDE_2:
  RET NZ
  LD (TEMPPT),HL
  RET
  
__LEN:
  LD BC,UNSIGNED_RESULT_A
  PUSH BC
; This entry point is used by the routines at __ASC and __VAL.
__LEN_0:
  CALL GETSTR
  XOR A
  LD D,A
  LD A,(HL)
  OR A
  RET
  
__ASC:
  LD BC,UNSIGNED_RESULT_A
  PUSH BC
; This entry point is used by the routine at FN_STRING.
__ASC_0:
  CALL __LEN_0
  JP Z,FCERR
  INC HL
  LD E,(HL)
  INC HL
  LD D,(HL)
  LD A,(DE)
  RET

__CHR_S:
  CALL MK_1BYTE_TMST
  CALL MAKINT
; This entry point is used by the routine at SCPTLP.
__CHR_S_0:
  LD HL,(TMPSTR)
  LD (HL),E

; Save in string pool
TOPOOL:
  POP BC
  JP TSTOPL
; This entry point is used by the routine at OPRND.
TOPOOL_0:
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  JR Z,GSTRDE_2
  EX (SP),HL
  INC DE
  PUSH DE
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
  CALL EVAL
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  ADD HL,HL
  EX (SP),HL
  PUSH HL
  RST GETYPR 		; Get the number type (FAC)
  JP Z,TOPOOL_1
  CALL MAKINT
  JP TOPOOL_2
TOPOOL_1:
  CALL __ASC_0
TOPOOL_2:
  POP DE
  CALL TOPOOL_3
  
__SPACE_S
  CALL MAKINT
  LD A,' '
TOPOOL_3:
  PUSH AF
  LD A,E
  CALL MKTMST
  LD B,A
  POP AF
  INC B
  DEC B
  JP Z,TOPOOL
  LD HL,(TMPSTR)
__SPACE_S_1:
  LD (HL),A
  INC HL
  DEC B
  JP NZ,__SPACE_S_1
  JP TOPOOL

__LEFT_S:
  CALL LFRGNM
  XOR A
__LEFT_S_0:
  EX (SP),HL
  LD C,A
  
__LEFT_S_1:
  LD A,$E5
	;; __LEFT_S_1+1:  PUSH HL

  PUSH HL
  LD A,(HL)
  CP B
  JP C,$2D7C
  LD A,B
  LD DE,$000E
  PUSH BC
  CALL TESTR
  POP BC
  POP HL
  PUSH HL
  INC HL
  LD B,(HL)
  INC HL
  LD H,(HL)
  LD L,B
  LD B,$00
  ADD HL,BC
  LD B,H
  LD C,L
  CALL CRTMST			; Make temporary string
  LD L,A
  CALL TOSTRA
  POP DE
  CALL GSTRDE
  JP TSTOPL

__RIGHT_S:
  CALL LFRGNM
  POP DE
  PUSH DE
  LD A,(DE)
  SUB B
  JP __LEFT_S_0
__MID_S:
  EX DE,HL
  LD A,(HL)
  CALL MIDNUM
  INC B
  DEC B
  JP Z,FCERR
  PUSH BC
  LD E,$FF
  CP ')'
  JP Z,__MID_S_1
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
  CALL GETINT
__MID_S_1:
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  ADD HL,HL
  POP AF
  EX (SP),HL
  LD BC,$2D74
  PUSH BC
  DEC A
  CP (HL)
  LD B,$00
  RET NC
  LD C,A
  LD A,(HL)
  SUB C
  CP E
  LD B,A
  RET C
  LD B,E
  RET
  
__VAL:
  CALL __LEN_0
  JP Z,UNSIGNED_RESULT_A
  LD E,A
  INC HL
  LD A,(HL)
  INC HL
  LD H,(HL)
  LD L,A
  PUSH HL
  ADD HL,DE
  LD B,(HL)
  LD (VLZADR),HL
  LD A,B
  LD (VLZDAT),A
  LD (HL),D
  EX (SP),HL
  PUSH BC
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  CALL DBL_DBL_ASCTFP
  LD HL,$0000
  LD (VLZADR),HL
  POP BC
  POP HL
  LD (HL),B
  RET

; number in program listing and check for ending ')'
;
; Used by the routine at TOPOOL.
LFRGNM:
  EX DE,HL
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  ADD HL,HL

; Get number in program listing
;
; Used by the routine at TOPOOL.
MIDNUM:
  POP BC
  POP DE
  PUSH BC
  LD B,E
  RET
  
; This entry point is used by the routine at OPRND.
FN_INSTR:
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  CALL OPNPAR
  RST GETYPR 		; Get the number type (FAC)
  LD A,$01
  PUSH AF
  JP Z,FN_INSTR_0	; JP if string type
  POP AF
  CALL MAKINT
  OR A
  JP Z,FCERR
  PUSH AF
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
  CALL EVAL
  CALL TSTSTR
FN_INSTR_0:
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
  PUSH HL
  LD HL,(DBL_FPREG)
  EX (SP),HL
  CALL EVAL
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  ADD HL,HL
  PUSH HL
  CALL GETSTR
  EX DE,HL
  POP BC
  POP HL
  POP AF
  PUSH BC
  LD BC,POPHLRT		; (POP HL / RET)
  PUSH BC
  LD BC,UNSIGNED_RESULT_A
  PUSH BC
  PUSH AF
  PUSH DE
  CALL GSTRHL
  POP DE
  POP AF
  LD B,A
  DEC A
  LD C,A
  CP (HL)
  LD A,$00
  RET NC
  LD A,(DE)
  OR A
  LD A,B
  RET Z
  LD A,(HL)
  INC HL
  LD B,(HL)
  INC HL
  LD H,(HL)
  LD L,B
  LD B,$00
  ADD HL,BC
  SUB C
  LD B,A
  PUSH BC
  PUSH DE
  EX (SP),HL
  LD C,(HL)
  INC HL
  LD E,(HL)
  INC HL
  LD D,(HL)
  POP HL
FN_INSTR_2:
  PUSH HL
  PUSH DE
  PUSH BC
FN_INSTR_3:
  LD A,(DE)
  CP (HL)
  JP NZ,FN_INSTR_6
  INC DE
  DEC C
  JP Z,FN_INSTR_5
  INC HL
  DEC B
  JP NZ,FN_INSTR_3
  POP DE
  POP DE
  POP BC
FN_INSTR_4:
  POP DE
  XOR A
  RET

FN_INSTR_5:
  POP HL
  POP DE
  POP DE
  POP BC
  LD A,B
  SUB H
  ADD A,C
  INC A
  RET

FN_INSTR_6:
  POP BC
  POP DE
  POP HL
  INC HL
  DEC B
  JP NZ,FN_INSTR_2
  JP FN_INSTR_4

__FRE:
  LD HL,(ARREND)
  EX DE,HL
  LD HL,$0000
  ADD HL,SP
  RST GETYPR 		; Get the number type (FAC)
  JP NZ,IMP
  CALL GSTRCU
  CALL TESTR_2
  EX DE,HL
  LD HL,(STKTOP)
  EX DE,HL
  LD HL,(FRETOP)
  JP IMP
; This entry point is used by the routine at _DBL_ASCTFP.
MIDNUM_7:
  CALL FP_ARG2HL
  LD HL,$3CE2
  CALL LOADFP_7
  CALL DECADD
  RET
; This entry point is used by the routine at _DBL_ASCTFP.
MIDNUM_8:
  LD HL,HALF
; This entry point is used by the routines at __RND and CHKSTK.
MIDNUM_9:
  CALL LOADFP
  JP FADD
  CALL LOADFP

; Subtract BCDE from FP reg
;
; Used by the routines at EXP and __RND.
FSUB:
  CALL INVSGN

; Add BCDE to FP reg
;
; Used by the routines at GETWORD, MIDNUM, __LOG, MLSP10, _DBL_ASCTFP, EXP and
; __RND.
FADD:
  LD A,B
  OR A
  RET Z
  LD A,(FACCU)
  OR A
  JP Z,FPBCDE
  SUB B
  JP NC,FADD_0
  CPL
  INC A
  EX DE,HL
  CALL STAKI
  EX DE,HL
  CALL FPBCDE
  POP BC
  POP DE
FADD_0:
  CP $19
  RET NC
  PUSH AF
  CALL LOADFP_5
  LD H,A
  POP AF
  CALL COMPL_0
  LD A,H
  OR A
  LD HL,DBL_FPREG
  JP P,FADD_1
  CALL PLUCDE
  JP NC,BNORM_8
  INC HL
  INC (HL)
  JP Z,$057D
  LD L,$01
  CALL SCALE_2
  JP BNORM_8

FADD_1:
  XOR A
  SUB B
  LD B,A
  LD A,(HL)
  SBC A,E
  LD E,A
  INC HL
  LD A,(HL)
  SBC A,D
  LD D,A
  INC HL
  LD A,(HL)
  SBC A,C
  LD C,A
; This entry point is used by the routines at FLGREL and INT.
FADD_2:
  CALL C,COMPL

; Normalise number
;
; Used by the routine at __RND.
BNORM:
  LD L,B
  LD H,E
  XOR A
BNORM_0:
  LD B,A
  LD A,C
  OR A
  JP NZ,BNORM_6
  LD C,D
  LD D,H
  LD H,L
  LD L,A
  LD A,B
  SUB $08
  CP $E0
  JP NZ,BNORM_0

; This entry point is used by the routines at DIV, DECADD, DBL_DBL_ASCTFP and EXP.
CLEAR_EXPONENT:
  XOR A
; This entry point is used by the routine at POWER.
SET_EXPONENT:
  LD (FACCU),A
  RET

BNORM_3:
  LD A,H
  OR L
  OR D
  JP NZ,BNORM_5
  LD A,C
BNORM_4:
  DEC B
  RLA
  JP NC,BNORM_4
  INC B
  RRA
  LD C,A
  JP DECROU

BNORM_5:
  DEC B
  ADD HL,HL
  LD A,D
  RLA
  LD D,A
  LD A,C
  ADC A,A
  LD C,A
BNORM_6:
  JP P,BNORM_3


; Single precision rounding
DECROU:
  LD A,B
  LD E,H
  LD B,L
  OR A
  JP Z,BNORM_8
  LD HL,FACCU
  ADD A,(HL)
  LD (HL),A
  JP NC,CLEAR_EXPONENT
  JP Z,CLEAR_EXPONENT
  
; This entry point is used by the routines at FADD and FCOMP.
BNORM_8:
  LD A,B
; This entry point is used by the routines at DIV and GET_DEVICE.
BNORM_9:
  LD HL,FACCU
  OR A
  CALL M,CLEAR_EXPONENT0
  LD B,(HL)
  INC HL
  LD A,(HL)
  AND $80
  XOR C
  LD C,A
  JP FPBCDE

; This entry point is used by the routine at FPINT.
CLEAR_EXPONENT0:
  INC E
  RET NZ
  INC D
  RET NZ
  INC C
  RET NZ
  LD C,$80
  INC (HL)
  RET NZ
  JP $057D

; Add number pointed by HL to CDE
;
; Used by the routines at FADD and _DBL_ASCTFP.
PLUCDE:
  LD A,(HL)
  ADD A,E
  LD E,A
  INC HL
  LD A,(HL)
  ADC A,D
  LD D,A
  INC HL
  LD A,(HL)
  ADC A,C
  LD C,A
  RET

; Convert a negative number to positive
;
; Used by the routines at FADD and FPINT.
COMPL:
  LD HL,SGNRES
  LD A,(HL)
  CPL
  LD (HL),A
  XOR A
  LD L,A
  SUB B
  LD B,A
  LD A,L
  SBC A,E
  LD E,A
  LD A,L
  SBC A,D
  LD D,A
  LD A,L
  SBC A,C
  LD C,A
  RET
; This entry point is used by the routines at FADD and FPINT.
COMPL_0:
  LD B,$00
COMPL_1:
  SUB $08
  JP C,SHRITE
  LD B,E
  LD E,D
  LD D,C
  LD C,$00
  JP COMPL_1

; Shift right number in BCDE
;
; Used by the routine at COMPL.
SHRITE:
  ADD A,$09

; Scale number in BCDE for A exponent (bits)
SCALE:
  ADD HL,BC
  LD L,A
  LD A,D
  OR E
  OR B
  JP NZ,SCALE_1
  LD A,C
SCALE_0:
  DEC L
  RET Z
  RRA
  LD C,A
  JP NC,SCALE_0
  JP SCALE_3
SCALE_1:
  XOR A
  DEC L
  RET Z
  LD A,C
; This entry point is used by the routine at FADD.
SCALE_2:
  RRA
  LD C,A
SCALE_3:
  LD A,D
  RRA
  LD D,A
  LD A,E
  RRA
  LD E,A
  LD A,B
  RRA
  LD B,A
  JP SCALE_1
  NOP
  NOP
  NOP
  ADD A,C
  INC B
  SBC A,D
  RST TSTSGN
  ADD HL,DE
  ADD A,E
  INC H
  LD H,E
  LD B,E
  ADD A,E
  LD (HL),L
  CALL CALLHL5
  XOR C
  LD A,A
  ADD A,E
  ADD A,D
  INC B
  NOP
  NOP
  NOP
  ADD A,C
  JP PO,$4DB0
  ADD A,E
  LD A,(BC)
  LD (HL),D
  LD DE,$F483
  INC B
  DEC (HL)
  LD A,A

; LOG
;
; Used by the routine at POWER.
__LOG:
  RST TSTSGN
  OR A
  JP PE,FCERR
  CALL __LOG_0
  LD BC,$8031
  LD DE,$7218
  JP FMULT_BCDE
__LOG_0:
  CALL BCDEFP
  LD A,$80
  LD (FACCU),A
  XOR B
  PUSH AF
  CALL STAKI
  LD HL,$2FDA
  CALL EXP_5
  POP BC
  POP HL
  CALL STAKI
  EX DE,HL
  CALL FPBCDE
  LD HL,$2FEB
  CALL EXP_5
  POP BC
  POP DE
  CALL FDIV
  POP AF
  CALL STAKI
  CALL FLGREL
  POP BC
  POP DE
  JP FADD

; Multiply BCDE to FP reg
;
; Used by the routines at __LOG, IMULT, EXP and __RND.
FMULT_BCDE:
  RST TSTSGN
  RET Z
  LD L,$00
  CALL DIV_5
  LD A,C
  LD ($FB5E),A
  EX DE,HL
  LD ($FB5F),HL
  LD BC,$0000
  LD D,B
  LD E,B
  LD HL,BNORM
  PUSH HL
  LD HL,$3060
  PUSH HL
  PUSH HL
  LD HL,DBL_FPREG
  LD A,(HL)
  INC HL
  OR A
  JP Z,FMULT_BCDE_4
  PUSH HL
  LD L,$08
FMULT_BCDE_0:
  RRA
  LD H,A
  LD A,C
  JP NC,FMULT_BCDE_1
  PUSH HL
  LD HL,($FB5F)
  ADD HL,DE
  EX DE,HL
  POP HL
  LD A,($FB5E)
  ADC A,C
FMULT_BCDE_1:
  RRA
  LD C,A
  LD A,D
  RRA
  LD D,A
  LD A,E
  RRA
  LD E,A
  LD A,B
  RRA
  LD B,A
  AND $10
  JP Z,FMULT_BCDE_2
  LD A,B
  OR $20
  LD B,A
FMULT_BCDE_2:
  DEC L
  LD A,H
  JP NZ,FMULT_BCDE_0

; This entry point is used by the routines at DIV and SCPTLP.
POPHLRT:
  POP HL
  RET

FMULT_BCDE_4:
  LD B,E
  LD E,D
  LD D,C
  LD C,A
  RET

; Divide FP by 10
;
; Used by the routine at _DBL_ASCTFP.
DIV10:
  CALL STAKI
  LD HL,$3681
  CALL PHLTFP

; Divide FP by number on stack
;
; Used by the routines at EVAL_04 and __TAN.
DIV:
  POP BC
  POP DE
; This entry point is used by the routines at __LOG and __POS.
FDIV:
  RST TSTSGN
  JP Z,OERR
  LD L,$FF
  CALL DIV_5
  INC (HL)
  JP Z,$057D
  INC (HL)
  JP Z,$057D
  DEC HL
  LD A,(HL)
  LD ($F41F),A
  DEC HL
  LD A,(HL)
  LD ($F41B),A
  DEC HL
  LD A,(HL)
  LD ($F417),A
  LD B,C
  EX DE,HL
  XOR A
  LD C,A
  LD D,A
  LD E,A
  LD ($F422),A
DIV_1:
  PUSH HL
  PUSH BC
  LD A,L
  CALL TEL_TERM_012
  SBC A,$00
  CCF
  JP NC,$30E1
  LD ($F422),A
  POP AF
  POP AF
  SCF
  JP NC,GET_DEVICE_692
  LD A,C
  INC A
  DEC A
  RRA
  JP P,DIV_3
  RLA
  LD A,($F422)
  RRA
  AND $C0
  PUSH AF
  LD A,B
  OR H
  OR L
  JP Z,DIV_2
  LD A,' '
DIV_2:
  POP HL
  OR H
  JP BNORM_9

DIV_3:
  RLA
  LD A,E
  RLA
  LD E,A
  LD A,D
  RLA
  LD D,A
  LD A,C
  RLA
  LD C,A
  ADD HL,HL
  LD A,B
  RLA
  LD B,A
  LD A,($F422)
  RLA
  LD ($F422),A
  LD A,C
  OR D
  OR E
  JP NZ,DIV_1
  PUSH HL
  LD HL,FACCU
  DEC (HL)
  POP HL
  JP NZ,DIV_1
  JP CLEAR_EXPONENT

; This entry point is used by the routine at DECADD.
DIV_4:
  LD A,$FF
  ;LD L,$AF
	defb $2E		; LD L,nn  (mask the next "XOR" instruction)
	
; Routine at 12585
;
; Used by the routine at DBL_ADD.
L3129:
  XOR A
  LD HL,DBL_LAST_FPREG
  LD C,(HL)
  INC HL
  XOR (HL)
  LD B,A
  LD L,$00
; This entry point is used by the routine at FMULT_BCDE.
DIV_5:
  LD A,B
  OR A
  JP Z,DIV_8
  LD A,L
  LD HL,FACCU
  XOR (HL)
  ADD A,B
  LD B,A
  RRA
  XOR B
  LD A,B
  JP P,DIV_7
  ADD A,$80
  LD (HL),A
  JP Z,POPHLRT
  CALL LOADFP_5
  LD (HL),A
; This entry point is used by the routine at _DBL_ASCTFP.
DCXH_2:
  DEC HL
  RET

  RST TSTSGN
  CPL
  POP HL
DIV_7:
  OR A
DIV_8:
  POP HL
  JP P,CLEAR_EXPONENT
  JP $057D

; Multiply number in FPREG by 10
;
; Used by the routine at _DBL_ASCTFP.
MLSP10:
  CALL BCDEFP
  LD A,B
  OR A
  RET Z
  ADD A,$02
  JP C,$057D
  LD B,A
  CALL FADD
  LD HL,FACCU
  INC (HL)
  RET NZ
  JP $057D

; Test sign of FPREG
;
; Used by the routines at GETYPR, _TSTSGN and FCOMP.
TSTSGN:
  LD A,(FACCU)
  OR A
  RET Z
  LD A,(LAST_FPREG)
	DEFB $FE		;  CP 2Fh ..hides the "CPL" instruction
SGN_RESULT_CPL:
  CPL  
  ; --- START PROC L2E78 ---
SGN_RESULT:
  RLA

; This entry point is used by the routines at GETWORD and FCOMP.
EVAL_RESULT:
  SBC A,A
  RET NZ
  INC A
  RET

; CY and A to FP, & normalise
;
; Used by the routines at __LOG and _DBL_ASCTFP.
; CY and A to FP, & normalise
FLGREL:
  LD B,$88
  LD DE,$0000
; This entry point is used by the routines at HLPASS and DBL_ABS.
FLGREL_0:
  LD HL,FACCU
  LD C,A
  LD (HL),B
  LD B,$00
  INC HL
  LD (HL),$80
  RLA
  JP FADD_2

; ABS
__ABS:
  CALL _TSTSGN
  RET P
; This entry point is used by the routines at OPRND, FIX and _DBL_ASCTFP.
INVSGN:
  RST GETYPR 		; Get the number type (FAC)
  JP M,DBL_ABS
  JP Z,TMERR

; Invert number sign
;
; Used by the routines at FSUB, FIX, IMULT, POWER, __RND and __POS.
INVSGN:
  LD HL,LAST_FPREG
  LD A,(HL)
  XOR $80
  LD (HL),A
  RET
__SGN:
  CALL _TSTSGN

; Get back from function, result in A (signed)
;
; Used by the routines at UCASE and GETWORD.
INT_RESULT_A:
  LD L,A
  RLA
  SBC A,A
  LD H,A
  JP INT_RESULT_HL

; Test sign in number
;
; Used by the routines at __DATA, __ABS, INVSGN and _DBL_ASCTFP.
_TSTSGN:
  RST GETYPR 		; Get the number type (FAC)
  JP Z,TMERR
  JP P,TSTSGN
  LD HL,(DBL_FPREG)
; This entry point is used by the routine at __FOR.
_SGN_RESULT:
  LD A,H
  OR L
  RET Z
  LD A,H
  JP SGN_RESULT

; Put FP value on stack
;
; Used by the routines at EVAL_04, FADD, __LOG, DIV10, MLDEBC, IMULT, _DBL_ASCTFP,
; __SQR, EXP, __RND and __TAN.
STAKI:
  EX DE,HL
  LD HL,(DBL_FPREG)
  EX (SP),HL
  PUSH HL
  LD HL,(LAST_FPREG)
  EX (SP),HL
  PUSH HL
  EX DE,HL
  RET

; Number at HL to BCDE
;
; Used by the routines at DIV10, _DBL_ASCTFP, __SQR, EXP, __RND and CHKSTK.
PHLTFP:
  CALL LOADFP

; Move BCDE to FPREG
;
; Used by the routines at EVAL_04, FADD, BNORM, __LOG, _DBL_ASCTFP, EXP and __TAN.
FPBCDE:
  EX DE,HL
  LD (DBL_FPREG),HL
  LD H,B
  LD L,C
  LD (LAST_FPREG),HL
  EX DE,HL
  RET

; Load FP reg to BCDE
;
; Used by the routines at __FOR, EVAL_04, __LOG, MLSP10, FCOMP, FPINT, INT,
; _DBL_ASCTFP, POWER, EXP and __RND.
BCDEFP:
  LD HL,DBL_FPREG

; Load FP value pointed by HL to BCDE
;
; Used by the routines at TESTR, MIDNUM, PHLTFP, EXP, __RND and CHKSTK.
LOADFP:
  LD E,(HL)
  INC HL
; This entry point is used by the routine at PRS1.
LOADFP_0:
  LD D,(HL)
  INC HL
  LD C,(HL)
  INC HL
  LD B,(HL)
; This entry point is used by the routines at SNERR, MAKINT and _DBL_ASCTFP.
INCHL:
  INC HL
  RET

; This entry point is used by the routines at __RND and CHKSTK.
LOADFP_2:
  LD DE,DBL_FPREG
  LD B,$04
  JP REV_LDIR_B
  
; Copy number value from HL to DE
VAL2DE:
  EX DE,HL
  
; This entry point is used by the routines at STEP, __LET, TSTOPL and INSTR.
; Copy number value from DE to HL
FP2HL:
  LD A,(VALTYP)
  LD B,A

; Move the memory from (DE) to (HL) for B bytes
;
; Used by the routines at __IPL, ON_TIME_S, MAKTXT, __RND, L31CA, FAC1_HL and
; BOOT.REV_LDIR_B:
  LD A,(DE)
  LD (HL),A
  INC DE
  INC HL
  DEC B
  JP NZ,REV_LDIR_B
  RET
  
; This entry point is used by the routines at FADD, DIV, FCOMP, FPINT, INT
; and DECADD.
LOADFP_5:
  LD HL,LAST_FPREG
  LD A,(HL)
  RLCA
  SCF
  RRA
  LD (HL),A
  CCF
  RRA
  INC HL
  INC HL
  LD (HL),A
  LD A,C
  RLCA
  SCF
  RRA
  LD C,A
  RRA
  XOR (HL)
  RET
  
; This entry point is used by the routine at DECADD.
LOADFP_6:
  LD HL,$FB2E
; This entry point is used by the routines at __FOR, OPRND, MIDNUM and _DBL_ASCTFP.
LOADFP_7:
  LD DE,$31F2
  JP INCHL0
  
; This entry point is used by the routines at EVAL_04, MIDNUM, DECADD and
; _DBL_ASCTFP.
FP_ARG2HL:
  LD HL,$FB2E
; This entry point is used by the routine at _DBL_ASCTFP.
LOADFP_9:
  LD DE,FP2HL
INCHL0:
  PUSH DE
  LD DE,DBL_FPREG
  RST GETYPR 		; Get the number type (FAC)
  RET C
  LD DE,$FB24
  RET

; Compare FP reg to BCDE
;
; Used by the routines at _DBL_ASCTFP, POWER, __RND and CHKSTK.
FCOMP:
  LD A,B
  OR A
  JP Z,TSTSGN
  LD HL,SGN_RESULT_CPL
  PUSH HL
  RST TSTSGN
  LD A,C
  RET Z
  LD HL,LAST_FPREG
  XOR (HL)
  LD A,C
  RET M
  CALL FCOMP_1
  
XDCOMP_1:
  RRA
  XOR C
  RET

FCOMP_1:
  INC HL
  LD A,B
  CP (HL)
  RET NZ
  DEC HL
  LD A,C
  CP (HL)
  RET NZ
  DEC HL
  LD A,D
  CP (HL)
  RET NZ
  DEC HL
  LD A,E
  SUB (HL)
  RET NZ
  POP HL
  POP HL
  RET

; This entry point is used by the routine at CHKSTK.
ICOMP:
  LD A,D
  XOR H
  LD A,H
  JP M,SGN_RESULT
  CP D
  JP NZ,FCOMP_3
  LD A,L
  SUB E
  RET Z
FCOMP_3:
  JP EVAL_RESULT

; This entry point is used by the routine at _DBL_ASCTFP.
FCOMP_4:
  LD HL,$FB2E
  CALL FP2HL
XDCOMP:
  LD DE,ARG
  LD A,(DE)
  OR A
  JP Z,TSTSGN
  LD HL,SGN_RESULT_CPL		; SGN_RESULT_CPL
  PUSH HL
  RST TSTSGN
  DEC DE
  LD A,(DE)
  LD C,A
  RET Z
  LD HL,LAST_FPREG
  XOR (HL)
  LD A,C
  RET M
  INC DE
  INC HL
  LD B,$08
XDCOMP_2:
  LD A,(DE)
  SUB (HL)
  JP NZ,XDCOMP_1
  DEC DE
  DEC HL
  DEC B
  JP NZ,XDCOMP_2
  POP BC
  RET

; Routine at 12951
DECCOMP:
  CALL XDCOMP
  JP NZ,SGN_RESULT_CPL
  RET

; This entry point is used by the routines at __FOR, EVAL_04, UCASE and DEPINT.
__CINT:
  RST GETYPR 		; Get the number type (FAC)
  LD HL,(DBL_FPREG)
  RET M
  JP Z,TMERR		; If string type, "Type mismatch"
  CALL NC,FCOMP_14
  LD HL,$057D
  PUSH HL
; This entry point is used by the routine at __INT.
FCOMP_7:
  LD A,(FACCU)
  CP $90
  JP NC,INT_RESULT_HL_2
  CALL FPINT
  EX DE,HL
  
;INT_RESULT_HL-1:
  POP DE
  
; This entry point is used by the routines at UCASE, INT_RESULT_A, INT,
; IMULT, DBL_ASCTFP and _DBL_ASCTFP.
INT_RESULT_HL:
  LD (DBL_FPREG),HL
  
; This entry point is used by the routine at DBL_ABS.
SETTYPE_INT:
  LD A,$02		; Integer type
  
; This entry point is used by the routine at HLPASS.
SETTYPE:
  LD (VALTYP),A
  RET
  
; This entry point is used by the routine at _DBL_ASCTFP.
INT_RESULT_HL_2:
  LD BC,$9080				; BCDE = -32768 (float)
  LD DE,$0000
  CALL FCOMP
  RET NZ
  LD H,C					; BCDE = 32768 (float)
  LD L,D
  JP INT_RESULT_HL-1
  
; This entry point is used by the routines at __FOR, EVAL_04, UCASE, GETWORD,
; _DBL_ASCTFP and POWER.
__CSNG:
  RST GETYPR 		; Get the number type (FAC)
  RET PO
  JP M,INT_CSNG
  JP Z,TMERR
FCOMP_14:
  CALL BCDEFP
  CALL $3310
  LD A,B
  OR A
  RET Z
  CALL LOADFP_5
  LD HL,$FB27
  LD B,(HL)
  JP BNORM_8

; This entry point is used by the routines at HLPASS and _DBL_ASCTFP.
INT_CSNG:
  LD HL,(DBL_FPREG)
; This entry point is used by the routines at EVAL_04, MLDEBC and IMULT.
HL_CSNG:
  CALL $3310

; Get back from function passing an INT value HL
HLPASS:
  LD A,H
  LD D,L
  LD E,$00
  LD B,$90
  JP FLGREL_0

; This entry point is used by the routines at EVAL_04, INT and _DBL_ASCTFP.
__CDBL:
  RST GETYPR 		; Get the number type (FAC)
  RET NC
  JP Z,TMERR
  CALL M,INT_CSNG
; This entry point is used by the routine at _DBL_ASCTFP.
ZERO_FACCU:
  LD HL,$0000
  LD ($FB24),HL
  LD ($FB26),HL
; This entry point is used by the routine at DBL_DBL_ASCTFP.
SETTYPE_DBL:
  LD A,$08
  LD BC,$043E
  JP SETTYPE

; Test a string, 'Type Error' if it is not
;
; Used by the routines at __DATA, UCASE, CONCAT, GETSTR, MIDNUM and SCPTLP.
TSTSTR:
  RST GETYPR 		; Get the number type (FAC)
  RET Z
  JP TMERR

; Floating Point to Integer
;
; Used by the routines at FCOMP, INT and _DBL_ASCTFP.
FPINT:
  LD B,A
  LD C,A
  LD D,A
  LD E,A
  OR A
  RET Z
  PUSH HL
  CALL BCDEFP
  CALL LOADFP_5
  XOR (HL)
  LD H,A
  CALL M,DCBCDE
  LD A,$98
  SUB B
  CALL COMPL_0
  LD A,H
  RLA
  CALL C,CLEAR_EXPONENT0
  LD B,$00
  CALL C,COMPL
  POP HL
  RET

; Decrement FP value in BCDE
;
; Used by the routine at FPINT.
DCBCDE:
  DEC DE
  LD A,D
  AND E
  INC A
  RET NZ
  DEC BC
  RET

; Double Precision to Integer conversion
FIX:
  RST GETYPR 		; Get the number type (FAC)
  RET M
  RST TSTSGN
  JP P,__INT
  CALL INVSGN
  CALL __INT
  JP INVSGN

; INT (double precision BASIC variant)
;
; Used by the routine at FIX.
__INT:
  RST GETYPR 		; Get the number type (FAC)
  RET M
  JP NC,INT_0
  JP Z,TMERR
  CALL FCOMP_7

; INT
;
; Used by the routines at POWER, EXP and __RND.
INT:
  LD HL,FACCU
  LD A,(HL)
  CP $98
  LD A,(DBL_FPREG)
  RET NC
  LD A,(HL)
  CALL FPINT
  LD (HL),$98
  LD A,E
  PUSH AF
  LD A,C
  RLA
  CALL FADD_2
  POP AF
  RET

; This entry point is used by the routine at __INT.
INT_0:
  LD HL,FACCU
  LD A,(HL)
  CP $90
  JP NZ,INT_3
  LD C,A
  DEC HL
  LD A,(HL)
  XOR $80
  LD B,$06
INT_1:
  DEC HL
  OR (HL)
  DEC B
  JP NZ,INT_1
  OR A
  LD HL,$8000
  JP NZ,INT_2
  CALL INT_RESULT_HL
  JP __CDBL

INT_2:
  LD A,C
INT_3:
  OR A
  RET Z
  CP $B8
  RET NC
; This entry point is used by the routine at _DBL_ASCTFP.
INT_4:
  PUSH AF
  CALL BCDEFP
  CALL LOADFP_5
  XOR (HL)
  DEC HL
  LD (HL),$B8
  PUSH AF
  DEC HL
  LD (HL),C
  CALL M,INT_5
  LD A,(LAST_FPREG)
  LD C,A
  LD HL,LAST_FPREG
  LD A,$B8
  SUB B
  CALL DECADD_22
  POP AF
  CALL M,DECADD_10
  XOR A
  LD ($FB23),A
  POP AF
  RET NC
  JP DECADD_3
INT_5:
  LD HL,$FB24
INT_6:
  LD A,(HL)
  DEC (HL)
  OR A
  INC HL
  JP Z,INT_6
  RET

; Multiply DE by BC
;
; Used by the routine at SCPTLP.
MLDEBC:
  PUSH HL
  LD HL,$0000
  LD A,B
  OR C
  JP Z,MLDEBC_2
  LD A,$10
MLDEBC_0:
  ADD HL,HL
  JP C,SBSCT_ERR
  EX DE,HL
  ADD HL,HL
  EX DE,HL
  JP NC,MLDEBC_1
  ADD HL,BC
  JP C,SBSCT_ERR
MLDEBC_1:
  DEC A
  JP NZ,MLDEBC_0
MLDEBC_2:
  EX DE,HL
  POP HL
  RET


; Routine at 13303
ISUB:
  LD A,H
  RLA
  SBC A,A
  LD B,A
  CALL INT_DIV_6
  LD A,C
  SBC A,B
  JP IADD_0
  
; This entry point is used by the routine at CHKSTK.
IADD:
  LD A,H
  RLA
  SBC A,A
IADD_0:
  LD B,A
  PUSH HL
  LD A,D
  RLA
  SBC A,A
  ADD HL,DE
  ADC A,B
  RRCA
  XOR H
  JP P,INT_RESULT_HL-1
  PUSH BC
  EX DE,HL
  CALL HL_CSNG
  POP AF
  POP HL
  CALL STAKI
  EX DE,HL
  CALL DBL_ABS_1
  JP _DBL_ASCTFP_26

; Integer MULTIPLY
IMULT:
  LD A,H
  OR L
  JP Z,INT_RESULT_HL
  PUSH HL
  PUSH DE
  CALL INT_DIV_3
  PUSH BC
  LD B,H
  LD C,L
  LD HL,$0000
  LD A,$10
IMULT_0:
  ADD HL,HL
  JP C,L345B
  EX DE,HL
  ADD HL,HL
  EX DE,HL
  JP NC,IMULT_1
  ADD HL,BC
  JP C,L345B
IMULT_1:
  DEC A
  JP NZ,IMULT_0
  POP BC
  POP DE
IMULT_2:
  LD A,H
  OR A
  JP M,IMULT_3
  POP DE
  LD A,B
  JP INT_DIV_5

IMULT_3:
  XOR $80
  OR L
  JP Z,IMULT_4
  EX DE,HL
  LD BC,GET_DEVICE_692

; Routine at 13403
;
; Used by the routine at INT_MUL.
L345B:
  CALL HL_CSNG
  POP HL
  CALL STAKI
  CALL HL_CSNG
  POP BC
  POP DE
  JP FMULT_BCDE

IMULT_4:
  LD A,B
  OR A
  POP BC
  JP M,INT_RESULT_HL
  PUSH DE
  CALL HL_CSNG
  POP DE
  JP INVSGN
  
; This entry point is used by the routines at UCASE and DBL_ABS.
INT_DIV:
  LD A,H
  OR L
  JP Z,OERR   		; "Division by zero"
  CALL INT_DIV_3
  PUSH BC
  EX DE,HL
  CALL INT_DIV_6
  LD B,H
  LD C,L
  LD HL,$0000
  LD A,$11		; const
  PUSH AF
  OR A
  JP INT_DIV_2

INT_DIV_0:
  PUSH AF
  PUSH HL
  ADD HL,BC
  JP NC,INT_DIV_1
  POP AF
  SCF
  ;LD A,$E1
  DEFB $3E  ; "LD A,n" to Mask the next byte
  
INT_DIV_1:
  POP HL
INT_DIV_2:
  LD A,E
  RLA
  LD E,A
  LD A,D
  RLA
  LD D,A
  LD A,L
  RLA
  LD L,A
  LD A,H
  RLA
  LD H,A
  POP AF
  DEC A
  JP NZ,INT_DIV_0
  EX DE,HL
  POP BC
  PUSH DE
  JP IMULT_2

INT_DIV_3:
  LD A,H
  XOR D
  LD B,A
  CALL INT_DIV_4
  EX DE,HL
INT_DIV_4:
  LD A,H
; This entry point is used by the routine at DBL_ABS.
INT_DIV_5:
  OR A
  JP P,INT_RESULT_HL
; This entry point is used by the routines at MLDEBC and DBL_ABS.
INT_DIV_6:
  XOR A
  LD C,A
  SUB L
  LD L,A
  LD A,C
  SBC A,H
  LD H,A
  JP INT_RESULT_HL

; ABS (double precision BASIC variant)
;
; Used by the routine at __ABS.
DBL_ABS:
  LD HL,(DBL_FPREG)
  CALL INT_DIV_6
  LD A,H
  XOR $80
  OR L
  RET NZ
; This entry point is used by the routines at __FOR, OPRND and UCASE.
DBL_ABS_0:
  EX DE,HL
  CALL $3310
  XOR A
; This entry point is used by the routine at MLDEBC.
DBL_ABS_1:
  LD B,$98
  JP FLGREL_0

; This entry point is used by the routine at UCASE.
IMOD:
  PUSH DE
  CALL INT_DIV
  XOR A
  ADD A,D
  RRA
  LD H,A
  LD A,E
  RRA
  LD L,A
  CALL SETTYPE_INT
  POP AF
  JP INT_DIV_5

; aka DECSUB, Double precision SUB (formerly FSUB)
DECSUB:
  LD HL,DBL_LAST_FPREG
  LD A,(HL)
  XOR $80
  LD (HL),A

; aka DECADD, Double precision ADD (formerly FADD)
;
; Used by the routines at MIDNUM and _DBL_ASCTFP.
DECADD:
  LD HL,ARG
  LD A,(HL)
  OR A
  RET Z
  LD B,A
  DEC HL
  LD C,(HL)
  LD DE,FACCU
  LD A,(DE)
  OR A
  JP Z,LOADFP_6
  SUB B
  JP NC,DECADD_1
  CPL
  INC A
  PUSH AF
  LD C,$08		; DBL number, 8 bytes
  INC HL
  PUSH HL
DECADD_0:
  LD A,(DE)
  LD B,(HL)
  LD (HL),A
  LD A,B
  LD (DE),A
  DEC DE
  DEC HL
  DEC C
  JP NZ,DECADD_0
  POP HL
  LD B,(HL)
  DEC HL
  LD C,(HL)
  POP AF
DECADD_1:
  CP $39
  RET NC
  PUSH AF
  CALL LOADFP_5
  LD HL,$FB2D
  LD B,A
  LD A,$00
  LD (HL),A
  LD ($FB23),A
  POP AF
  LD HL,DBL_LAST_FPREG
  CALL DECADD_22
  LD A,B
  OR A
  JP P,DECADD_2
  LD A,($FB2D)
  LD ($FB23),A
  CALL DECADD_12
  JP NC,DECADD_8
  EX DE,HL
  INC (HL)
  JP Z,$057D
  CALL DECADD_31
  JP DECADD_8
DECADD_2:
  CALL DECADD_16
  LD HL,SGNRES
  CALL C,DECADD_20
; This entry point is used by the routine at INT.
DECADD_3:
  XOR A
DECADD_4:
  LD B,A
  LD A,(LAST_FPREG)
  OR A
  JP NZ,DECADD_7
  LD HL,$FB23
  LD C,$08
DECADD_5:
  LD D,(HL)
  LD (HL),A
  LD A,D
  INC HL
  DEC C
  JP NZ,DECADD_5
  LD A,B
  SUB $08
  CP $C0
  JP NZ,DECADD_4
  JP CLEAR_EXPONENT
  
DECADD_6:
  DEC B
  LD HL,$FB23
  CALL DECADD_32
  OR A
DECADD_7:
  JP P,DECADD_6
  LD A,B
  OR A
  JP Z,DECADD_8
  LD HL,FACCU
  ADD A,(HL)
  LD (HL),A
  JP NC,CLEAR_EXPONENT
  RET Z
DECADD_8:
  LD A,($FB23)
DECADD_9:
  OR A
  CALL M,DECADD_10
  LD HL,SGNRES
  LD A,(HL)
  AND $80
  DEC HL
  DEC HL
  XOR (HL)
  LD (HL),A
  RET

; This entry point is used by the routine at INT.
DECADD_10:
  LD HL,$FB24
  LD B,$07
DECADD_11:
  INC (HL)
  RET NZ
  INC HL
  DEC B
  JP NZ,DECADD_11
  INC (HL)
  JP Z,$057D
  DEC HL
  LD (HL),$80
  RET
DECADD_12:
  LD HL,$FB2E
; This entry point is used by the routine at _DBL_ASCTFP.
DECADD_13:
  LD DE,$FB24
DECADD_14:
  LD C,$07
  XOR A
DECADD_15:
  LD A,(DE)
  ADC A,(HL)
  LD (DE),A
  INC DE
  INC HL
  DEC C
  JP NZ,DECADD_15
  RET
DECADD_16:
  LD HL,$FB2E
; This entry point is used by the routine at _DBL_ASCTFP.
DECADD_17:
  LD DE,$FB24
DECADD_18:
  LD C,$07
  XOR A
DECADD_19:
  LD A,(DE)
  SBC A,(HL)
  LD (DE),A
  INC DE
  INC HL
  DEC C
  JP NZ,DECADD_19
  RET
DECADD_20:
  LD A,(HL)
  CPL
  LD (HL),A
  LD HL,$FB23
  LD B,$08
  XOR A
  LD C,A
DECADD_21:
  LD A,C
  SBC A,(HL)
  LD (HL),A
  INC HL
  DEC B
  JP NZ,DECADD_21
  RET
; This entry point is used by the routine at INT.
DECADD_22:
  LD (HL),C
  PUSH HL
DECADD_23:
  SUB $08
  JP C,DECADD_27
  POP HL
DECADD_24:
  PUSH HL
  LD DE,$0800
DECADD_25:
  LD C,(HL)
  LD (HL),E
  LD E,C
DECADD_26:
  DEC HL
  DEC D
  JP NZ,DECADD_25
  JP DECADD_23
DECADD_27:
  ADD A,$09
  LD D,A
DECADD_28:
  XOR A
  POP HL
  DEC D
  RET Z
DECADD_29:
  PUSH HL
  LD E,$08
DECADD_30:
  LD A,(HL)
  RRA
  LD (HL),A
  DEC HL
  DEC E
  JP NZ,DECADD_30
  JP DECADD_28
DECADD_31:
  LD HL,LAST_FPREG
  LD D,$01
  JP DECADD_29
DECADD_32:
  LD C,$08
DECADD_33:
  LD A,(HL)
  RLA
  LD (HL),A
  INC HL
  DEC C
  JP NZ,DECADD_33
  RET
  
; This entry point is used by the routine at _DBL_ASCTFP.
DECMUL:
  RST TSTSGN
  RET Z
  LD A,(ARG)
  OR A
  JP Z,CLEAR_EXPONENT
  CALL L3129
  CALL DECADD_41
  LD (HL),C
  INC DE
  LD B,$07
DECADD_35:
  LD A,(DE)
  INC DE
  OR A
  PUSH DE
  JP Z,DECADD_38
  LD C,$08
DECADD_36:
  PUSH BC
  RRA
  LD B,A
  CALL C,DECADD_12
  CALL DECADD_31
  LD A,B
  POP BC
  DEC C
  JP NZ,DECADD_36
DECADD_37:
  POP DE
  DEC B
  JP NZ,DECADD_35
  JP DECADD_3
DECADD_38:
  LD HL,LAST_FPREG
  CALL DECADD_24
  JP DECADD_37
  CALL CALLHL9
  CALL Z,CALLHL9
  LD C,H
  LD A,L
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  JR NZ,DECADD_26
; This entry point is used by the routine at _DBL_ASCTFP.





DECADD_39:
  LD DE,$3675
  LD HL,$FB2E
  CALL FP2HL
  JP DECMUL

; Routine at 13969
DECDIV:
  LD A,(ARG)
  OR A
  JP Z,OERR
  LD A,(FACCU)
  OR A
  JP Z,CLEAR_EXPONENT
  CALL DIV_4
  INC (HL)
  INC (HL)
  JP Z,$057D
  CALL DECADD_41
  LD HL,$FB58
  LD (HL),C
  LD B,C
DECADD_40:
  LD DE,$FB51
  LD HL,$FB2E
  CALL DECADD_18
  LD A,(DE)
  SBC A,C
  CCF
  JP C,$36C9
  LD DE,$FB51
  LD HL,$FB2E
  CALL DECADD_14
  XOR A
  JP C,$0412
  LD A,(LAST_FPREG)
  INC A
  DEC A
  RRA
  JP M,DECADD_9
  RLA
  LD HL,$FB24
  LD C,$07
  CALL DECADD_33
  LD HL,$FB51
  CALL DECADD_32
  LD A,B
  OR A
  JP NZ,DECADD_40
  LD HL,FACCU
  DEC (HL)
  JP NZ,DECADD_40
  JP CLEAR_EXPONENT
  
DECADD_41:
  LD A,C
  LD (DBL_LAST_FPREG),A
  DEC HL
  LD DE,$FB57
  LD BC,$0700
DECADD_42:
  LD A,(HL)
  LD (DE),A
  LD (HL),C
  DEC DE
  DEC HL
  DEC B
  JP NZ,DECADD_42
  RET

; This entry point is used by the routine at _DBL_ASCTFP.
DECADD_43:
  CALL FP_ARG2HL
  EX DE,HL
  DEC HL
  LD A,(HL)
  OR A
  RET Z
  ADD A,$02
  JP C,$057D
  LD (HL),A
  PUSH HL
  CALL DECADD
  POP HL
  INC (HL)
  RET NZ
  JP $057D

; ASCII to Double precision FP number
;
; Used by the routines at __DATA, TOPOOL and SCPTLP.
DBL_DBL_ASCTFP:
  CALL CLEAR_EXPONENT
  CALL SETTYPE_DBL

  defb $f6		; OR $AF

; ASCII to FP number (New version)
;
; Used by the routines at TOKEN_BUILT, __DATA, OPRND and SCPTLP.
DBL_ASCTFP:
  XOR A
  EX DE,HL
  LD BC,$00FF
  LD H,B
  LD L,B
  CALL Z,INT_RESULT_HL
  EX DE,HL
  LD A,(HL)

; ASCII to FP number
_DBL_ASCTFP:
  CP '-'
  PUSH AF
  JP Z,_DBL_ASCTFP_0
  CP '+'
  JP Z,_DBL_ASCTFP_0
  DEC HL
_DBL_ASCTFP_0:
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JP C,_DBL_ASCTFP_18
  CP '.'
  JP Z,_DBL_ASCTFP_9
  CP $65
  JP Z,_DBL_ASCTFP_1
  CP 'E'
_DBL_ASCTFP_1:
  JP NZ,_DBL_ASCTFP_4
  PUSH HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  CP $6C
  JP Z,_DBL_ASCTFP_2
  CP $4C
  JP Z,_DBL_ASCTFP_2
  CP $71
  JP Z,_DBL_ASCTFP_2
  CP $51
_DBL_ASCTFP_2:
  POP HL
  JP Z,_DBL_ASCTFP_3
  LD A,(VALTYP)
  CP $08
  JP Z,_DBL_ASCTFP_5
  LD A,$00
  JP _DBL_ASCTFP_5
_DBL_ASCTFP_3:
  LD A,(HL)
_DBL_ASCTFP_4:
  CP '%'
  JP Z,_DBL_ASCTFP_10
  CP '#'
  JP Z,_DBL_ASCTFP_11
  CP '!'
  JP Z,_DBL_ASCTFP_12
  CP $64
  JP Z,_DBL_ASCTFP_5
  CP 'D'
  JP NZ,_DBL_ASCTFP_7
_DBL_ASCTFP_5:
  OR A
  CALL _DBL_ASCTFP_13
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  CALL UCASE_5
_DBL_ASCTFP_6:
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JP C,_DBL_ASCTFP_27
  INC D
  JP NZ,_DBL_ASCTFP_7
  XOR A
  SUB E
  LD E,A
_DBL_ASCTFP_7:
  PUSH HL
  LD A,E
  SUB B
  LD E,A
_DBL_ASCTFP_8:
  CALL P,_DBL_ASCTFP_14
  CALL M,_DBL_ASCTFP_17
  JP NZ,_DBL_ASCTFP_8
  POP HL
  POP AF
  PUSH HL
  CALL Z,INVSGN
  POP HL
  RST GETYPR 		; Get the number type (FAC)
  RET PE
  PUSH HL
  LD HL,POPHLRT
  PUSH HL
  CALL INT_RESULT_HL_2
  RET
_DBL_ASCTFP_9:
  RST GETYPR 		; Get the number type (FAC)
  INC C
  JP NZ,_DBL_ASCTFP_7
  CALL C,_DBL_ASCTFP_13
  JP _DBL_ASCTFP_0
_DBL_ASCTFP_10:
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  POP AF
  PUSH HL
  LD HL,POPHLRT
  PUSH HL
  PUSH AF
  JP _DBL_ASCTFP_7
_DBL_ASCTFP_11:
  OR A
_DBL_ASCTFP_12:
  CALL _DBL_ASCTFP_13
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JP _DBL_ASCTFP_7
_DBL_ASCTFP_13:
  PUSH HL
  PUSH DE
  PUSH BC
  PUSH AF
  CALL Z,__CSNG
  POP AF
  CALL NZ,__CDBL
  POP BC
  POP DE
  POP HL
  RET

_DBL_ASCTFP_14:
  RET Z
_DBL_ASCTFP_15:
  PUSH AF
  RST GETYPR 		; Get the number type (FAC)
  PUSH AF
  CALL PO,MLSP10
  POP AF
  CALL PE,DECADD_43
  POP AF
DCR_A:
  DEC A
  RET
  
_DBL_ASCTFP_17:
  PUSH DE
  PUSH HL
  PUSH AF
  RST GETYPR 		; Get the number type (FAC)
  PUSH AF
  CALL PO,DIV10
  POP AF
  CALL PE,DECADD_39
  POP AF
  POP HL
  POP DE
  INC A
  RET
  
_DBL_ASCTFP_18:
  PUSH DE
  LD A,B
  ADC A,C
  LD B,A
  PUSH BC
  PUSH HL
  LD A,(HL)
  SUB $30	; '0'
  PUSH AF
  RST GETYPR 		; Get the number type (FAC)
  JP P,_DBL_ASCTFP_22
  LD HL,(DBL_FPREG)
  LD DE,$0CCD		; const
  RST CPDEHL
  JP NC,_DBL_ASCTFP_21
  LD D,H
  LD E,L
  ADD HL,HL
  ADD HL,HL
  ADD HL,DE
  ADD HL,HL
  POP AF
  LD C,A
  ADD HL,BC
  LD A,H
  OR A
  JP M,_DBL_ASCTFP_20
  LD (DBL_FPREG),HL

_DBL_ASCTFP_19:
  POP HL
  POP BC
  POP DE
  JP _DBL_ASCTFP_0

_DBL_ASCTFP_20:
  LD A,C
  PUSH AF
_DBL_ASCTFP_21:
  CALL INT_CSNG
  SCF
_DBL_ASCTFP_22:
  JP NC,_DBL_ASCTFP_24
  LD BC,$9474
  LD DE,$2400
  CALL FCOMP
  JP P,_DBL_ASCTFP_23
  CALL MLSP10
  POP AF
  CALL _DBL_ASCTFP_25
  JP _DBL_ASCTFP_19

_DBL_ASCTFP_23:
  CALL ZERO_FACCU
_DBL_ASCTFP_24:
  CALL DECADD_43
  CALL FP_ARG2HL
  POP AF
  CALL FLGREL
  CALL ZERO_FACCU
  CALL DECADD
  JP _DBL_ASCTFP_19

_DBL_ASCTFP_25:
  CALL STAKI
  CALL FLGREL
; This entry point is used by the routine at MLDEBC.
_DBL_ASCTFP_26:
  POP BC
  POP DE
  JP FADD
_DBL_ASCTFP_27:
  LD A,E
  CP $0A
  JP NC,$388B
  RLCA
  RLCA
  ADD A,E
  RLCA
  ADD A,(HL)
  SUB $30
  LD E,A
  JP M,$7F1E
  JP _DBL_ASCTFP_6
  
; This entry point is used by the routines at SNERR and GETWORD.
LNUM_MSG:
  PUSH HL
  LD HL,IN_MSG
  CALL PRS
  POP HL

; Print HL in ASCII form at the current cursor position
;
; Used by the routines at __LIST, PRPARM and FREEMEM.
NUMPRT:
  LD BC,PRNUMS
  PUSH BC
  CALL INT_RESULT_HL
  XOR A
  CALL NUMPRT_SUB
  OR (HL)
  JP PUFOUT_1
  
; This entry point is used by the routines at __DATA, MAKINT and __INP.
FOUT:
  XOR A
  
; This entry point is used by the routine at SCPTLP.
; Convert number/expression to string ("PRINT USING" format specified in 'A' register)
FOUT_0:
  CALL NUMPRT_SUB

; Convert the binary number in FAC1 to ASCII.  A - Bit configuration for PRINT
; USING options
PUFOUT:
  AND $08
  JP Z,PUFOUT_0
  LD (HL),'+'
PUFOUT_0:
  EX DE,HL
  CALL _TSTSGN
  EX DE,HL
  JP P,PUFOUT_1
  LD (HL),'-'
  PUSH BC
  PUSH HL
  CALL INVSGN
  POP HL
  POP BC
  OR H
PUFOUT_1:
  INC HL
  LD (HL),'0'
  LD A,(TEMP3)
  LD D,A
  RLA
  LD A,(VALTYP)
  JP C,_DBL_ASCTFP_48
  JP Z,_DBL_ASCTFP_46
  CP $04
  JP NC,_DBL_ASCTFP_40
  LD BC,$0000
  CALL _DBL_ASCTFP_105
  
_DBL_ASCTFP_34:
  LD HL,FBUFFR+1
  LD B,(HL)
  LD C,$20
  LD A,(TEMP3)
  LD E,A
  AND $20			; bit 5 - Asterisks fill  
  JP Z,_DBL_ASCTFP_35
  LD A,B
  CP C
  LD C,'*'
  JP NZ,_DBL_ASCTFP_35
  LD A,E
  AND $04
  JP NZ,_DBL_ASCTFP_35
  LD B,C
_DBL_ASCTFP_35:
  LD (HL),C
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JP Z,_DBL_ASCTFP_36
  CP 'E'
  JP Z,_DBL_ASCTFP_36
  CP 'D'
  JP Z,_DBL_ASCTFP_36
  CP '0'
  JP Z,_DBL_ASCTFP_35
  CP ','
  JP Z,_DBL_ASCTFP_35
  CP '.'
  JP NZ,_DBL_ASCTFP_37
_DBL_ASCTFP_36:
  DEC HL
  LD (HL),'0'
_DBL_ASCTFP_37:
  LD A,E
  AND $10
  JP Z,_DBL_ASCTFP_38
  DEC HL
  LD (HL),$5C
_DBL_ASCTFP_38:
  LD A,E
  AND $04
  RET NZ
  DEC HL
  LD (HL),B
  RET
  
NUMPRT_SUB:
  LD (TEMP3),A
  LD HL,FBUFFR+1
  LD (HL),' '
  RET

_DBL_ASCTFP_40:
  CP $05
  PUSH HL
  SBC A,$00
  RLA
  LD D,A
  INC D
  CALL _DBL_ASCTFP_76
  LD BC,$0300
  ADD A,D
  JP M,_DBL_ASCTFP_41
  INC D
  CP D
  JP NC,_DBL_ASCTFP_41
  INC A
  LD B,A
  LD A,$02
_DBL_ASCTFP_41:
  SUB $02
  POP HL
  PUSH AF
  CALL _DBL_ASCTFP_95
  LD (HL),'0'
  CALL Z,INCHL
  CALL _DBL_ASCTFP_98
SUPTLZ:
  DEC HL
  LD A,(HL)
  CP '0'
  JP Z,SUPTLZ
  CP '.'
  CALL NZ,INCHL
  POP AF
  JP Z,NOENED

_DBL_ASCTFP_43:
  PUSH AF
  RST GETYPR 		; Get the number type (FAC)
  LD A,$22
  ADC A,A
  LD (HL),A
  INC HL
  POP AF
  LD (HL),'+'
  JP P,OUTEXP
  LD (HL),'-'
  CPL
  INC A
OUTEXP:
  LD B,'0'-1  ; $2F, '/'
EXPTEN:
  INC B
  SUB 10
  JP NC,EXPTEN
  ADD A,'0'+10
  INC HL
  LD (HL),B
  INC HL
  LD (HL),A
_DBL_ASCTFP_46:
  INC HL
NOENED:
  LD (HL),$00
  EX DE,HL
  LD HL,FBUFFR+1
  RET

_DBL_ASCTFP_48:
  INC HL
  PUSH BC
  CP $04
  LD A,D
  JP NC,_DBL_ASCTFP_55
  RRA
  JP C,_DBL_ASCTFP_65
  LD BC,$0603		; const
  CALL _DBL_ASCTFP_94
  POP DE
  LD A,D
  SUB $05
  CALL P,_DBL_ASCTFP_87
  CALL _DBL_ASCTFP_105
_DBL_ASCTFP_49:
  LD A,E
  OR A
  CALL Z,DCXH_2
  DEC A
  CALL P,_DBL_ASCTFP_87
_DBL_ASCTFP_50:
  PUSH HL
  CALL _DBL_ASCTFP_34
  POP HL
  JP Z,_DBL_ASCTFP_51
  LD (HL),B
  INC HL
_DBL_ASCTFP_51:
  LD (HL),$00
  LD HL,FBUFFR
_DBL_ASCTFP_52:
  INC HL
_DBL_ASCTFP_53:
  LD A,(TEMP2)
  SUB L
  SUB D
  RET Z
  LD A,(HL)
  CP ' '
  JP Z,_DBL_ASCTFP_52
  CP '*'
  JP Z,_DBL_ASCTFP_52
  DEC HL
  PUSH HL
  PUSH AF
  LD BC,$39E0
  PUSH BC
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  CP '-'
  RET Z
  CP '+'
  RET Z
  CP $5C  	;'\'
  RET Z
  POP BC
  CP '0'
  JP NZ,_DBL_ASCTFP_54
  INC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JP NC,_DBL_ASCTFP_54
  DEC HL
  LD BC,$772B
  POP AF
  JP Z,$39FC
  POP BC
  JP _DBL_ASCTFP_53
_DBL_ASCTFP_54:
  POP AF
  JP Z,_DBL_ASCTFP_54
  POP HL
  LD (HL),$25
  RET
_DBL_ASCTFP_55:
  PUSH HL
  RRA
  JP C,_DBL_ASCTFP_66
  JP Z,_DBL_ASCTFP_57
  LD DE,$3CEA
  CALL FCOMP_4
  LD D,$10
  JP M,_DBL_ASCTFP_58
_DBL_ASCTFP_56:
  POP HL
  POP BC
  CALL FOUT
  DEC HL
  LD (HL),$25
  RET
_DBL_ASCTFP_57:
  LD BC,$B60E
  LD DE,$1BCA
  CALL FCOMP
  JP P,_DBL_ASCTFP_56
  LD D,$06
_DBL_ASCTFP_58:
  RST TSTSGN
  CALL NZ,_DBL_ASCTFP_76
  POP HL
  POP BC
  JP M,_DBL_ASCTFP_59
  PUSH BC
  LD E,A
  LD A,B
  SUB D
  SUB E
  CALL P,_DBL_ASCTFP_87
  CALL _DBL_ASCTFP_92
  CALL _DBL_ASCTFP_98
  OR E
  CALL NZ,_DBL_ASCTFP_91
  OR E
  CALL NZ,_DBL_ASCTFP_95
  POP DE
  JP _DBL_ASCTFP_49

_DBL_ASCTFP_59:
  LD E,A
  LD A,C
  OR A
  CALL NZ,DCR_A		; DEC A, RET
  ADD A,E
  JP M,_DBL_ASCTFP_60
  XOR A
_DBL_ASCTFP_60:
  PUSH BC
  PUSH AF
_DBL_ASCTFP_61:
  CALL M,_DBL_ASCTFP_17
  JP M,_DBL_ASCTFP_61
  POP BC
  LD A,E
  SUB B
  POP BC
  LD E,A
  ADD A,D
  LD A,B
  JP M,_DBL_ASCTFP_62
  SUB D
  SUB E
  CALL P,_DBL_ASCTFP_87
  PUSH BC
  CALL _DBL_ASCTFP_92
  JP _DBL_ASCTFP_63
_DBL_ASCTFP_62:
  CALL _DBL_ASCTFP_87
  LD A,C
  CALL _DBL_ASCTFP_96
  LD C,A
  XOR A
  SUB D
  SUB E
  CALL _DBL_ASCTFP_87
  PUSH BC
  LD B,A
  LD C,A
_DBL_ASCTFP_63:
  CALL _DBL_ASCTFP_98
  POP BC
  OR C
  JP NZ,_DBL_ASCTFP_64
  LD HL,(TEMP2)				; NXTOPR on MSX
_DBL_ASCTFP_64:
  ADD A,E
  DEC A
  CALL P,_DBL_ASCTFP_87
  LD D,B
  JP _DBL_ASCTFP_50
  
_DBL_ASCTFP_65:
  PUSH HL
  PUSH DE
  CALL INT_CSNG
  POP DE
  XOR A
_DBL_ASCTFP_66:
  JP Z,L3AB6
  LD E,$10
  defb $01	; LD BC,NN
  ;LD BC,$061E

; Routine at 15030
;
; Used by the routine at _ASCTFP.
L3AB6:
  LD E,$06
  RST TSTSGN
  SCF
  CALL NZ,_DBL_ASCTFP_76
  POP HL
  POP BC
  PUSH AF
  LD A,C
  OR A
  PUSH AF
  CALL NZ,DCR_A		; DEC A, RET
  ADD A,B
  LD C,A
  XOR A
  OR B
  JP Z,_DBL_ASCTFP_67
  LD A,D
  AND $04
  CP $01
  SBC A,A
_DBL_ASCTFP_67:
  LD D,A
  ADD A,C
  LD C,A
  SUB E
  PUSH AF
  PUSH BC
  PUSH DE
  PUSH HL
  PUSH AF
_DBL_ASCTFP_68:
  CALL M,_DBL_ASCTFP_17
  JP M,_DBL_ASCTFP_68
  XOR A
  LD ($FB1A),A
  LD HL,$FB1B
  CALL LOADFP_9
  RST GETYPR 		; Get the number type (FAC)
  JP PE,_DBL_ASCTFP_69
  CALL MIDNUM_8
  LD A,$FA
  JP _DBL_ASCTFP_70
_DBL_ASCTFP_69:
  CALL MIDNUM_7
  LD A,$F0
_DBL_ASCTFP_70:
  POP DE
  SUB D
_DBL_ASCTFP_71:
  CALL M,_DBL_ASCTFP_17
  JP M,_DBL_ASCTFP_71
  LD A,(FACCU)
  SUB $81
  PUSH AF
  LD HL,$FB1B
  CALL LOADFP_7
  POP AF
  JP M,_DBL_ASCTFP_72
  LD A,$01
  LD ($FB1A),A
  CALL _DBL_ASCTFP_17
_DBL_ASCTFP_72:
  POP HL
  POP DE
  POP BC
  POP AF
  PUSH BC
  PUSH AF
  JP M,_DBL_ASCTFP_73
  XOR A
_DBL_ASCTFP_73:
  CPL
  INC A
  ADD A,B
  INC A
  ADD A,D
  LD B,A
  LD C,$00
  CALL _DBL_ASCTFP_98
  POP AF
  CALL P,_DBL_ASCTFP_89
  CALL _DBL_ASCTFP_95
  POP BC
  POP AF
  JP NZ,_DBL_ASCTFP_74
  CALL DCXH_2
  LD A,(HL)
  CP '.'
  CALL NZ,INCHL
  LD (TEMP2),HL
_DBL_ASCTFP_74:
  POP AF
  JP C,_DBL_ASCTFP_75
  ADD A,E
  SUB B
  SUB D
_DBL_ASCTFP_75:
  PUSH BC
  LD B,A
  LD A,($FB1A)
  ADD A,B
  CALL _DBL_ASCTFP_43
  EX DE,HL
  POP DE
  JP _DBL_ASCTFP_50
  
_DBL_ASCTFP_76:
  PUSH DE
  XOR A
  PUSH AF
  RST GETYPR 		; Get the number type (FAC)
  JP PO,_DBL_ASCTFP_78
_DBL_ASCTFP_77:
  LD A,(FACCU)
  CP $91		; TK_PRINT
  JP NC,_DBL_ASCTFP_78
  LD DE,$3CCA
  LD HL,$FB2E
  CALL FP2HL
  CALL DECMUL
  POP AF
  SUB $0A
  PUSH AF
  JP _DBL_ASCTFP_77
_DBL_ASCTFP_78:
  CALL _DBL_ASCTFP_84
_DBL_ASCTFP_79:
  RST GETYPR 		; Get the number type (FAC)
  JP PE,_DBL_ASCTFP_80
  LD BC,$9143
  LD DE,$4FF9
  CALL FCOMP
  JP _DBL_ASCTFP_81
_DBL_ASCTFP_80:
  LD DE,$3CD2
  CALL FCOMP_4
_DBL_ASCTFP_81:
  JP P,_DBL_ASCTFP_83
  POP AF
  CALL _DBL_ASCTFP_15
  PUSH AF
  JP _DBL_ASCTFP_79
_DBL_ASCTFP_82:
  POP AF
  CALL _DBL_ASCTFP_17
  PUSH AF
  CALL _DBL_ASCTFP_84
_DBL_ASCTFP_83:
  POP AF
  OR A
  POP DE
  RET

_DBL_ASCTFP_84:
  RST GETYPR 		; Get the number type (FAC)
  JP PE,_DBL_ASCTFP_85
  LD BC,$9474
  LD DE,$23F8
  CALL FCOMP
  JP _DBL_ASCTFP_86

_DBL_ASCTFP_85:
  LD DE,$3CDA
  CALL FCOMP_4
_DBL_ASCTFP_86:
  POP HL
  JP P,_DBL_ASCTFP_82
  JP (HL)

_DBL_ASCTFP_87:
  OR A
_DBL_ASCTFP_88:
  RET Z
  DEC A
  LD (HL),'0'
  INC HL
  JP _DBL_ASCTFP_88
_DBL_ASCTFP_89:
  JP NZ,_DBL_ASCTFP_91
_DBL_ASCTFP_90:
  RET Z
  CALL _DBL_ASCTFP_95
_DBL_ASCTFP_91:
  LD (HL),'0'
  INC HL
  DEC A
  JP _DBL_ASCTFP_90
_DBL_ASCTFP_92:
  LD A,E
  ADD A,D
  INC A
  LD B,A
  INC A
_DBL_ASCTFP_93:
  SUB $03
  JP NC,_DBL_ASCTFP_93
  ADD A,$05
  LD C,A
_DBL_ASCTFP_94:
  LD A,(TEMP3)
  AND $40
  RET NZ
  LD C,A
  RET
_DBL_ASCTFP_95:
  DEC B
  JP NZ,_DBL_ASCTFP_97
_DBL_ASCTFP_96:
  LD (HL),$2E
  LD (TEMP2),HL
  INC HL
  LD C,B
  RET
_DBL_ASCTFP_97:
  DEC C
  RET NZ
  LD (HL),$2C
  INC HL
  LD C,$03
  RET
_DBL_ASCTFP_98:
  PUSH DE
  PUSH BC
  PUSH HL
  RST GETYPR 		; Get the number type (FAC)
  JP PO,_DBL_ASCTFP_101
  CALL MIDNUM_7
  XOR A
  CALL INT_4
  POP HL
  POP BC
  LD DE,$3CF2
  LD A,$0A
_DBL_ASCTFP_99:
  CALL _DBL_ASCTFP_95
  PUSH BC
  PUSH AF
  PUSH HL
  PUSH DE
  LD B,$2F
_DBL_ASCTFP_100:
  INC B
  POP HL
  PUSH HL
  CALL DECADD_17
  JP NC,_DBL_ASCTFP_100
  POP HL
  CALL DECADD_13
  EX DE,HL
  POP HL
  LD (HL),B
  INC HL
  POP AF
  POP BC
  DEC A
  JP NZ,_DBL_ASCTFP_99
  PUSH BC
  PUSH HL
  LD HL,$FB24
  CALL PHLTFP
  JP _DBL_ASCTFP_102
_DBL_ASCTFP_101:
  CALL MIDNUM_8
  LD A,$01
  CALL FPINT
  CALL FPBCDE
_DBL_ASCTFP_102:
  POP HL
  POP BC
  XOR A
  LD DE,$3D38
_DBL_ASCTFP_103:
  CCF
  CALL _DBL_ASCTFP_95
  PUSH BC
  PUSH AF
  PUSH HL
  PUSH DE
  CALL BCDEFP
  POP HL
  LD B,$2F
_DBL_ASCTFP_104:
  INC B
  LD A,E
  SUB (HL)
  LD E,A
  INC HL
  LD A,D
  SBC A,(HL)
  LD D,A
  INC HL
  LD A,C
  SBC A,(HL)
  LD C,A
  DEC HL
  DEC HL
  JP NC,_DBL_ASCTFP_104
  CALL PLUCDE
  INC HL
  CALL FPBCDE
  EX DE,HL
  POP HL
  LD (HL),B
  INC HL
  POP AF
  POP BC
  JP C,_DBL_ASCTFP_103
  INC DE
  INC DE
  LD A,$04
  JP _DBL_ASCTFP_106

_DBL_ASCTFP_105:
  PUSH DE
  LD DE,$3D3E
  LD A,$05
_DBL_ASCTFP_106:
  CALL _DBL_ASCTFP_95
  PUSH BC
  PUSH AF
  PUSH HL
  EX DE,HL
  LD C,(HL)
  INC HL
  LD B,(HL)
  PUSH BC
  INC HL
  EX (SP),HL
  EX DE,HL
  LD HL,(DBL_FPREG)
  LD B,'0'-1  ; $2F, '/'
_DBL_ASCTFP_107:
  INC B
  LD A,L
  SUB E
_DBL_ASCTFP_108:
  LD L,A
  LD A,H
  SBC A,D
  LD H,A
  JP NC,_DBL_ASCTFP_107
  ADD HL,DE
  LD (DBL_FPREG),HL
  POP DE
  POP HL
  LD (HL),B
  INC HL
  POP AF
  POP BC
  DEC A
  JP NZ,_DBL_ASCTFP_106
  CALL _DBL_ASCTFP_95
  LD (HL),A
  POP DE
  RET


  NOP
  NOP
  NOP
  NOP
  LD SP,HL
  LD (BC),A

  DEC D
  AND D
  POP HL
  RST $38
  SBC A,A
  LD SP,$5FA9
  LD H,E
  OR D
  CP $FF
  INC BC
  CP A
  RET
  DEC DE
  LD C,$B6
  NOP
  NOP
  NOP
  NOP

HALF:
  NOP
  NOP
  NOP
  ADD A,B
  NOP
  NOP
  INC B
  CP A
  RET
  DEC DE
  LD C,$B6
  NOP
  ADD A,B
  ADD A,$A4
  LD A,(HL)
  ADC A,L
  INC BC
  NOP
  LD B,B
  LD A,D
  DJNZ $3CF1
  LD E,D
  NOP
  NOP
  AND B
  LD (HL),D
  LD C,(HL)
  JR _DBL_ASCTFP_109
  NOP
  NOP
  DJNZ _DBL_ASCTFP_108
  CALL NC,FNCTAB_0
  NOP
  NOP
_DBL_ASCTFP_109:
  RET PE
  HALT
  LD C,B
  RLA
  NOP
  NOP
  NOP
  CALL PO,GET_DEVICE_15
  LD (BC),A
  NOP
  NOP
  NOP
  JP Z,_DBL_ASCTFP_81
  NOP
  NOP
  NOP
  NOP
  POP HL
  PUSH AF
  DEC B
  NOP
  NOP
  NOP
  ADD A,B
  SUB (HL)
  SBC A,B
  NOP
  NOP
  NOP
  NOP
  LD B,B
  LD B,D
  RRCA
  NOP
  NOP
  NOP
  NOP
  AND B
  ADD A,(HL)
  LD BC,$2710
  NOP
  DJNZ POWER_1
  RET PE
  INC BC
  LD H,H
  NOP
  LD A,(BC)
  NOP
  LD BC,$2100

; Negate number
;
; Used by the routines at POWER and __POS.
NEGAFT:
  LD HL,INVSGN
  EX (SP),HL
  JP (HL)

; SQR
__SQR:
  CALL STAKI
  LD HL,HALF
  CALL PHLTFP
  JP POWER_0

; POWER
POWER:
  CALL __CSNG
; This entry point is used by the routine at __SQR.
POWER_0:
  POP BC
  POP DE
  RST TSTSGN
  LD A,B
  JP Z,__EXP
  JP P,POWER_2
  OR A
; This entry point is used by the routine at _DBL_ASCTFP.
POWER_1:
  JP Z,OERR
POWER_2:
  OR A
  JP Z,SET_EXPONENT
  PUSH DE
  PUSH BC
  LD A,C
  OR $7F
  CALL BCDEFP
  JP P,POWER_4
  PUSH AF
  LD A,(FACCU)
  CP $99
  JP C,POWER_3
  POP AF
  JP POWER_4
POWER_3:
  POP AF
  PUSH DE
  PUSH BC
  CALL INT
  POP BC
  POP DE
  PUSH AF
  CALL FCOMP
  POP HL
  LD A,H
  RRA
POWER_4:
  POP HL
  LD (LAST_FPREG),HL
  POP HL
  LD (DBL_FPREG),HL
  CALL C,NEGAFT
  CALL Z,INVSGN
  PUSH DE
  PUSH BC
  CALL __LOG
  POP BC
  POP DE

; EXP
EXP:
  CALL FMULT_BCDE
; This entry point is used by the routine at POWER.
__EXP:
  LD BC,$8138
  LD DE,$AA3B
  CALL FMULT_BCDE
  LD A,(FACCU)
  CP $88
  JP NC,EXP_0
  CP $68
  JP C,EXP_3
  CALL STAKI
  CALL INT
  ADD A,$81
  JP Z,EXP_1
  POP BC
  POP DE
  PUSH AF
  CALL FSUB
  LD HL,$3DFD
  CALL EXP_5
  POP BC
  LD DE,$0000
  LD C,D
  JP FMULT_BCDE

EXP_0:
  CALL STAKI
EXP_1:
  LD A,(LAST_FPREG)
  OR A
  JP P,EXP_2
  POP AF
  POP AF
  JP CLEAR_EXPONENT
  
EXP_2:
  JP $057D
EXP_3:
  LD BC,$8100
  LD DE,$0000
  JP FPBCDE
  RLCA
  LD A,H
  ADC A,B
  LD E,C
  LD (HL),H
  RET PO
  SUB A
  LD H,$77
  CALL NZ,GETWORD_121
  LD A,D
  LD E,(HL)
  LD D,B
  LD H,E
  LD A,H
  LD A,(DE)
  CP $75
  LD A,(HL)
  JR $3E86
  LD SP,$0080
  NOP
  NOP
  ADD A,C
; This entry point is used by the routines at __RND and __POS.
EXP_4:
  CALL STAKI
  LD DE,$3467
  PUSH DE
  PUSH HL
  CALL BCDEFP
  CALL FMULT_BCDE
  POP HL

; This entry point is used by the routine at __LOG.
EXP_5:
  CALL STAKI
  LD A,(HL)
  INC HL
  CALL PHLTFP
; Routine at 15922
L3E32:
  LD B,$F1		; POP	AF
  POP BC
  POP DE
  DEC A
  RET Z
  PUSH DE
  PUSH BC
  PUSH AF
  PUSH HL
  CALL FMULT_BCDE
  POP HL
  CALL LOADFP
  PUSH HL
  CALL FADD
  POP HL
  JP L3E32

; RND
__RND:
  RST TSTSGN
  LD HL,RNDX
  JP M,__RND_3
  LD HL,HOLD
  CALL PHLTFP
  LD HL,RNDX
  RET Z
  ADD A,(HL)
  AND $07
  LD B,$00
  LD (HL),A
  INC HL
  ADD A,A
  ADD A,A
  LD C,A
  ADD HL,BC
  CALL LOADFP
  CALL FMULT_BCDE
  LD A,(RNDX-1)
  INC A
  AND $03
  LD B,$00
  CP $01
  ADC A,B
  LD (RNDX-1),A
  LD HL,L3EAD
  ADD A,A
  ADD A,A
  LD C,A
  ADD HL,BC
  CALL MIDNUM_9
__RND_0:
  CALL BCDEFP
  LD A,E
  LD E,C
  XOR $4F
  LD C,A
__RND_1:
  LD (HL),$80
  DEC HL
  LD B,(HL)
  LD (HL),$80
  LD HL,RNDX-2
  INC (HL)
  LD A,(HL)
  SUB $AB
  JP NZ,__RND_2
  LD (HL),A
  INC C
  DEC D
  INC E
__RND_2:
  CALL BNORM
  LD HL,HOLD
  JP LOADFP_2
__RND_3:
  LD (HL),A
  DEC HL
  LD (HL),A
  DEC HL
; Routine at 16045
L3EAD:
  LD (HL),A
  JP __RND_0

  LD L,B
  OR C
  LD B,(HL)
  LD L,B
  SBC A,C
  JP (HL)

  SUB D
  LD L,C
  DJNZ __RND_1
  LD (HL),L
  LD L,B

; This entry point is used by the routine at __TAN.
__COS:
  LD HL,$3F41
  CALL MIDNUM_9
; This entry point is used by the routine at __TAN.
__SIN:
  LD A,(FACCU)
  CP $77
  RET C
  LD A,(LAST_FPREG)
  OR A
  JP P,__RND_4
  AND $7F
  LD (LAST_FPREG),A
  LD DE,INVSGN
  PUSH DE
__RND_4:
  LD BC,$7E22
  LD DE,$F983
  CALL FMULT_BCDE
  CALL STAKI
  CALL INT
  POP BC
  POP DE
  CALL FSUB
  LD BC,$7F00
  LD DE,$0000
  CALL FCOMP
  JP M,__RND_5
  LD BC,$7F80
  LD DE,$0000
  CALL FADD
  LD BC,$8080
  LD DE,$0000
  CALL FADD
  RST TSTSGN
  CALL P,INVSGN
  LD BC,$7F00
  LD DE,$0000
  CALL FADD
  CALL INVSGN
__RND_5:
  LD A,(LAST_FPREG)
  OR A
  PUSH AF
  JP P,__RND_6
  XOR $80
  LD (LAST_FPREG),A
__RND_6:
  LD HL,$3F49
  CALL EXP_4
  POP AF
  RET P
  LD A,(LAST_FPREG)
  XOR $80
  LD (LAST_FPREG),A
  RET
  NOP
  NOP
  NOP
  NOP
  ADD A,E
  LD SP,HL
  LD ($DB7E),HL
  RRCA
  LD C,C
  ADD A,C
  NOP
  NOP
  NOP
  LD A,A
  DEC B
  EI
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  LD E,$86
  LD H,L
  LD H,$99
  ADD A,A
  LD E,B
  INC (HL)
  INC HL
  ADD A,A
  POP HL
  LD E,L
  AND L
  ADD A,(HL)
  IN A,($0F)
  LD C,C
  ADD A,E

; TAN
__TAN:
  CALL STAKI
  CALL __SIN
  POP BC
  POP HL
  CALL STAKI
  EX DE,HL
  CALL FPBCDE
  CALL __COS
  JP DIV

; ATN
__POS:
  RST TSTSGN
  CALL M,NEGAFT
  CALL M,INVSGN
  LD A,(FACCU)
  CP $81
  JP C,__POS_0
  LD BC,$8100
  LD D,C
  LD E,C
  CALL FDIV
  LD HL,$2EC1
  PUSH HL
__POS_0:
  LD HL,$3F98
  CALL EXP_4
  LD HL,$3F41
  RET
  ADD HL,BC
  LD C,D
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  DEC SP
  LD A,B
  LD (BC),A
  LD L,(HL)
  ADD A,H
  LD A,E
  CP $C1
  CPL
  LD A,H
  LD (HL),H
  LD SP,$7D9A
  ADD A,H
  DEC A
  LD E,D
  LD A,L
  RET Z
  LD A,A
  SUB C
  LD A,(HL)
  CALL PO,$4CBB
  LD A,(HL)
  LD L,H
  XOR D
  XOR D
  LD A,A
  NOP
  NOP
  NOP
  ADD A,C
; This entry point is used by the routines at SNERR and GETVAR.
__POS_1:
  CALL $3FD5
; This entry point is used by the routine at TESTR.
__POS_2:
  PUSH BC
  EX (SP),HL
  POP BC
__POS_3:
  RST CPDEHL
  LD A,(HL)
  LD (BC),A
  RET Z
  DEC BC
  DEC HL
  JP __POS_3

; Check for C levels of stack
;
; Used by the routines at __FOR, EVAL1 and SCPTLP.
CHKSTK:
  PUSH HL
  LD HL,(ARREND)
  LD B,$00
  ADD HL,BC
  ADD HL,BC
  LD A,$E5
  LD A,$88
  SUB L
  LD L,A
  LD A,$FF
  SBC A,H
  LD H,A
  JP C,OMERR
  ADD HL,SP
  POP HL
  RET C
; This entry point is used by the routines at GETWORD, SCPTLP and GET_DEVICE.
OMERR:
  CALL UPD_PTRS
  LD HL,(STKTOP)
  DEC HL
  DEC HL
  LD (SAVSTK),HL
  LD DE,$0007
  JP ERROR
; This entry point is used by the routines at SNERR, __FOR, GETWORD, ISFLIO and
; GET_DEVICE.
RUN_FST:
  LD HL,(BASTXT)
  DEC HL
; This entry point is used by the routines at __FOR, GETWORD and GET_DEVICE.
_CLVAR:
  LD (TEMP),HL
; This entry point is used by the routine at GET_DEVICE.
_CLREG:
  CALL RUN_FST2
  LD B,$1A
  LD HL,$FAED
CHKSTK_4:
  LD (HL),$04
  INC HL
  DEC B
  JP NZ,CHKSTK_4
  XOR A
  LD (ONEFLG),A
  LD L,A
  LD H,A
  LD (ONELIN),HL
  LD (OLDTXT),HL
  LD HL,(MEMSIZ)
  LD (FRETOP),HL
  CALL __RESTORE
  LD HL,(PROGND)
  LD (VAREND),HL
  LD (ARREND),HL
  CALL CLSALL		; Close all files
  LD A,(NLONLY)
  AND $01
  JP NZ,_CLREG_1
  LD (NLONLY),A
; This entry point is used by the routine at GET_DEVICE.
_CLREG_1:
  POP BC
  LD HL,(STKTOP)
  DEC HL
  DEC HL
  LD (SAVSTK),HL
  INC HL
  INC HL
  
; This entry point is used by the routine at SNERR.
WARM_ENTRY:
  LD SP,HL
  LD HL,TEMPST
  LD (TEMPPT),HL
  CALL INIT_OUTPUT
  CALL FINPRT
  XOR A
  LD H,A
  LD L,A
  LD (PRMLEN),HL
  LD (NOFUNS),A
  LD (PRMLN2),HL
  LD (FUNACT),HL
  LD (PRMSTK),HL
  LD (SUBFLG),A
  PUSH HL
  PUSH BC
  LD HL,(TEMP)
  RET
  
; This entry point is used by the routine at GETWORD.
TIME_S_ON:
  DI
  LD A,(HL)
  AND $04
  OR $01
  LD (HL),A
  EI
  RET
  
; This entry point is used by the routine at GETWORD.
TIME_S_OFF:
  DI
  LD (HL),$00
  EI
  RET
  
; This entry point is used by the routine at GETWORD.
TIME_S_STOP:
  DI
  LD A,(HL)
  OR $02
  LD (HL),A
  EI
  RET
  
; This entry point is used by the routine at ULERR.
TIME_S_STOP_1:
  DI
  LD A,(HL)
  AND $05
  LD (HL),A
  EI
  RET
  
RUN_FST1:
  DI
  LD A,(HL)
  AND $03
  LD (HL),A
  EI
  RET
  
RUN_FST2:
  XOR A
  LD L,A
  LD H,A
  LD (ON_COM_FLG),A
  LD ($F84D),HL
  RET
  
; This entry point is used by the routine at __FOR.
RUN_FST3:
  LD A,(ONEFLG)
  OR A
  RET NZ
  PUSH HL
  LD HL,(CURLIN)
  LD A,H
  AND L
  INC A
  JP Z,RUN_FST4
  LD HL,ON_COM_FLG
  LD A,(HL)
  DEC A
  JP Z,TIME_S_STOP_7
RUN_FST4:
  POP HL
  RET

TIME_S_STOP_7:
  INC HL
  LD E,(HL)
  INC HL
  LD D,(HL)
  DEC HL
  DEC HL
  LD A,D
  OR E
  JP Z,RUN_FST4
  PUSH DE
  PUSH HL
  CALL RUN_FST1
  CALL TIME_S_STOP
  LD C,$03
  CALL CHKSTK
  POP BC
  POP DE
  POP HL
  POP AF
  JP __FOR_40
  
__RESTORE:
  EX DE,HL
  LD HL,(BASTXT)
  JP Z,RUN_FST6
  EX DE,HL
  CALL LNUM_PARM_0
  PUSH HL
  CALL FIRST_LNUM
  LD H,B
  LD L,C
  POP DE
  JP NC,ULERR			; Error: "Undefined line number"
RUN_FST6:
  DEC HL
; This entry point is used by the routine at __DATA.
RUN_FST7:
  LD (DATPTR),HL
  EX DE,HL
  RET
  
; This entry point is used by the routine at GETWORD.
__STOP:
  RET NZ
  INC A
  JP RUN_FST8
  
__END:
  RET NZ
  XOR A
  LD (ONEFLG),A
  PUSH AF
  CALL Z,CLSALL		; Close all files
  POP AF
RUN_FST8:
  LD (SAVTXT),HL
  LD HL,TEMPST
  LD (TEMPPT),HL
  LD HL,$FFF6
  POP BC
  LD HL,(CURLIN)
  PUSH HL
  PUSH AF
  LD A,L
  AND H
  INC A
  JP Z,RUN_FST9
  LD (OLDLIN),HL
  LD HL,(SAVTXT)
  LD (OLDTXT),HL
RUN_FST9:
  CALL INIT_OUTPUT
  CALL CONSOLE_CRLF
  POP AF
  LD HL,BREAK_MSG
  JP NZ,SNERR_8
  JP RESTART
  
__CONT:
  LD HL,(OLDTXT)
  LD A,H
  OR L
  LD DE,$0011
  JP Z,ERROR
  EX DE,HL
  LD HL,(OLDLIN)
  LD (CURLIN),HL
  EX DE,HL
  RET
  JP FCERR

; This entry point is used by the routines at __FOR and GETVAR.
IS_ALPHA:
  LD A,(HL)
; This entry point is used by the routines at SNERR, OPRND and GETVAR.
IS_ALPHA_A:
  CP $41
  RET C
  CP $5B
  CCF
  RET

__CLEAR:
  PUSH HL
  CALL GET_DEVICE_206
  CALL SWAPNM_1
  CALL GET_DEVICE_207
  POP HL
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JP Z,_CLVAR
  CALL __FOR_31
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  PUSH HL
  LD HL,(HIMEM)
  LD B,H
  LD C,L
  LD HL,(MEMSIZ)
  JP Z,_CLVAR3
  POP HL
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
  PUSH DE
  CALL GETWORD
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JP NZ,SNERR
  EX (SP),HL
  EX DE,HL
  LD A,H
  AND A
  JP P,FCERR		; "Illegal function call"
  PUSH DE
  LD DE,MAXRAM+1	; Limit of CLEAR position
  RST $38
  DEFB $00			; RST38_VECT, offset: 00, Hook for CLEAR
  
  RST CPDEHL
  JP NC,FCERR		; "Illegal function call"
  POP DE
  PUSH HL
  LD BC,$FEF5		; -267 (same offset on M100)
  LD A,(MAXFIL)
_CLVAR2:
  ADD HL,BC
  DEC A
  JP P,_CLVAR2
  POP BC
  DEC HL
_CLVAR3:
  LD A,L
  SUB E
  LD E,A
  LD A,H
  SBC A,D
  LD D,A
  JP C,OMERR
  PUSH HL
  LD HL,(PROGND)
  PUSH BC
  LD BC,$00A0
  ADD HL,BC
  POP BC
  RST CPDEHL
  JP NC,OMERR
  EX DE,HL
  LD (STKTOP),HL
  LD H,B
  LD L,C
  LD (HIMEM),HL
  POP HL
  LD (MEMSIZ),HL
  POP HL
  CALL _CLVAR
  LD A,(MAXFIL)
  CALL __MAX_0
  LD HL,(TEMP)
  JP EXEC_EVAL_0

__NEXT:
  LD DE,$0000
_CLVAR4:
  CALL NZ,GETVAR
  LD (TEMP),HL
  CALL NEXT_UNSTACK			; search FOR block on stack (skip 2 words)
  JP NZ,$0574
  LD SP,HL
  PUSH DE
  LD A,(HL)
  PUSH AF
  INC HL
  PUSH DE
  LD A,(HL)
  INC HL
  OR A
  JP M,_CLVAR5
  CALL PHLTFP
  EX (SP),HL
  PUSH HL
  CALL MIDNUM_9
  POP HL
  CALL LOADFP_2
  POP HL
  CALL LOADFP
  PUSH HL
  CALL FCOMP
  JP _CLVAR6
_CLVAR5:
  INC HL
  INC HL
  INC HL
  INC HL
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
  CALL IADD
  LD A,(VALTYP)
  CP $04
  JP Z,$057D
  EX DE,HL
  POP HL
  LD (HL),D
  DEC HL
  LD (HL),E
  POP HL
  PUSH DE
  LD E,(HL)
  INC HL
  LD D,(HL)
  INC HL
  EX (SP),HL
  CALL ICOMP
_CLVAR6:
  POP HL
  POP BC
  SUB B
  CALL LOADFP
  JP Z,_CLVAR7
  EX DE,HL
  LD (CURLIN),HL
  LD L,C
  LD H,B
  JP __FOR_5
_CLVAR7:
  LD SP,HL
  LD (SAVSTK),HL
  EX DE,HL
  LD HL,(TEMP)
  LD A,(HL)
  CP ','
  JP NZ,EXEC_EVAL_0
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  CALL _CLVAR4

; Tests if an I/O redirection to device is in place
;
; Used by the routines at SNERR, __DATA, MAKINT and SCPTLP.
ISFLIO:
  PUSH HL
  LD HL,(PTRFIL)
  LD A,H
  OR L
  POP HL
  RET

; Send CRLF to screen or printer
;
; Used by the routines at __KEY, CATALOG, INLIN_BRK, INLIN_ENTER, TEL_FIND,
; TXT_ESC, TXT_CTL_Y and TXT_CTL_V.
OUTDO_CRLF:
  LD A,$0D
  RST OUTC
  LD A,$0A
  RST OUTC
  RET

; Routine at 16937
;
; Used by the routines at LDIR_B, INXD, TELCOM, TEL_TERM, __MENU, SCHEDL_DE,
; TEXT and MOVE_TEXT.
__BEEP:
  LD A,$07			; BEL
  RST OUTC
  RET

; This entry point is used by the routine at GET_DEVICE.
HOME:
  LD A,$0B
  RST OUTC
  RET

; Routine at 16945
;
; Used by the routines at __MENU, _PRINT_TDATE, SCHEDL_DE and __EDIT.
__CLS:
  LD A,$0C			; CLS/FF
  RST OUTC
  RET  

; Protect line 8.  An ESC T is printed.
;
; Used by the routine at DSPFNK.
ISFLIO_2:
  LD A,$54		; 'T'
  JP ESCA

; Unprotect line 8.  An ESC U is printed.
;
; Used by the routines at ERAFNK and DSPFNK.
oint is used by the routine at GET_DEVICE.
RSTSYS:
  LD A,$55		; 'U'
  JP ESCA

; Stop automatic scrolling.  ( ESC V )
;
; Used by the routines at __MENU and WAIT_SPC.
LOCK:
  LD A,$56		; 'V'
  JP ESCA

; Resume automatic scrolling.  (ESC W)
;
; Used by the routines at TELCOM, __MENU and TXT_ESC.
UNLOCK:
  LD A,$57		; 'W'
  JP ESCA

; Turn the cursor on.  An ESC P is printed.
;
; Used by the routines at FNBAR_TOGGLE, TEL_TERM and TEL_PREV.
CURSON:
  LD A,$50		; 'P'
  JP ESCA

; Turn the cursor off.  An ESC Q is printed.
;
; Used by the routines at FNBAR_TOGGLE, TEL_PREV, TEL_BYE, __MENU and WAIT_SPC.
CURSOFF:
  LD A,$51		; 'Q'
  JP ESCA

; Delete current line on screen.  ( ESC M )
;
; Used by the routines at DSPFNK and TXT_CTL_L.
DELLIN:
  LD A,$4D		; 'M'
  JP ESCA

; Insert line at current line. (ESC L)
;
; Used by the routine at TXT_CTL_C.
INSLIN:
  LD A,$4C		; 'L'
  JP ESCA

; Erase from cursor to end of line.  (ESC K)
;
; Used by the routines at CAS_OPNI_CO, ERAFNK, DSPFNK, INXD, MOVE_TEXT and
; TXT_CTL_V.
ERAEOL:
  LD A,$4B		; 'K'
  JP ESCA
  
; This entry point is used by the routines at GETWORD and GET_DEVICE.
_ESC_X:
  LD A,$58
  JP ESCA
; This entry point is used by the routine at GET_DEVICE.
HOME2:
  LD A,$33
  JP ESCA

; This entry point is used by the routine at GET_DEVICE.
HOME3:
  LD A,$34
  JP ESCA

ENTREV_COND:
  OR (HL)
  RET Z

; calls ESC__p, Reverse mode
;
; Used by the routines at DSPFNK, ESC_L and INXD.
ENTREV:
  LD A,$70		; 'p'
  JP ESCA

; calls ESC__q, Exit reverse mode
;
; Used by the routines at DSPFNK, ESC_L, INXD, __MENU, WAIT_SPC and TXT_CTL_V.
EXTREV:
  LD A,$71		; 'q'
  
ESCA:
  PUSH AF
  LD A,$1B
  RST OUTC
  POP AF
  RST OUTC
  RET
  
ESCA_0:
  LD HL,(ACTV_X)
  LD H,$01

; calls ESC_Y, set cursor position (H,L)
;
; Used by the routines at LINE_GFX, ERAFNK, DSPFNK, __MENU, DOTTED_FNAME,
; CURS_HOME, SHOW_TIME, TXT_ESC, TXT_CTL_I, TXT_CTL_E, TXT_CTL_T, TXT_CTL_R,
; TXT_CTL_C, MCLEAR, MOVE_TEXT, TXT_CTL_Y and TXT_CTL_V.
; H=X position, L=Y position
POSIT:
  LD A,$59
  CALL ESCA
  LD A,L
  ADD A,$1F
  RST OUTC
  LD A,H
  ADD A,$1F
  RST OUTC
  RET

; This entry point is used by the routines at GETWORD and GET_DEVICE.
ERAFNK:
  LD A,(LABEL_LN)
  AND A
  RET Z
  CALL RSTSYS
  LD HL,(CSRX)
  PUSH HL
  CALL ESCA_0
  CALL HOME31
  CALL ERAEOL
  POP HL
  CALL POSIT
  CALL _ESC_X
  XOR A
  RET

; Set and display function keys
;
; Used by the routines at TELCOM and SCHEDL_DE.STDSPF:
  CALL STFNK
; This entry point is used by the routines at GETWORD and GET_DEVICE.
DSPFNK:
  XOR A
; This entry point is used by the routine at GET_DEVICE.
DSPFNK_0:
  PUSH AF
  LD (FNKSTS),A
  LD HL,(CSRX)
  LD A,(ACTV_X)
  CP L
  JP NZ,DSPFNK_1
  PUSH HL
  CALL CURSOFF8
  CALL HOME
  CALL DELLIN
  POP HL
  DEC L
DSPFNK_1:
  PUSH HL
  CALL RSTSYS
  CALL ESCA_0
  CALL HOME31
  LD HL,FNKSTR
  LD D,$01
  POP BC
  POP AF
  PUSH BC
  JP Z,DSPFNK_2
  LD HL,FNKSTR+80
  LD D,$06
DSPFNK_2:
  LD E,$05
  LD A,(REVERSE)

  PUSH AF			; Save "reverse" status
  CALL EXTREV		; Exit from reverse mode
ISFLIO_26:
  LD A,(ACTV_Y)
  CP 40
  LD BC,$0709		; pos for 40 columns (7, 9)
  JP Z,ISFLIO_27
  LD BC,$0F01
ISFLIO_27:
  PUSH HL
  LD HL,CAPTUR+1
  LD A,D
  SUB $04
  JP Z,ISFLIO_28
  DEC A
  DEC HL
ISFLIO_28:
  CALL Z,ENTREV_COND
  POP HL
  CALL GETWORD_132
  ADD HL,BC
  CALL EXTREV
  INC D
  DEC E
  CALL NZ,CPDEHL_0
  JP NZ,ISFLIO_26
  CALL ERAEOL
  CALL ISFLIO_2
  POP AF
  AND A
  CALL NZ,HOME5
  POP HL
  CALL POSIT
  CALL _ESC_X
  XOR A
  RET

; This entry point is used by the routine at SCPTLP.
OUTC_SUB:
  PUSH HL
  PUSH DE
  PUSH BC
  PUSH AF
  RST $38
  EX AF,AF'		; HOUTD
  
  CALL OUTC_SUB_0
  JP POPALL

; This entry point is used by the routine at GETWORD.
OUTC_SUB_0:
  LD C,A
  XOR A
  LD (CRTFLG),A
  RST $38
  LD A,(BC)
  CALL OUTC_SUB_1
  LD HL,(CSRX)
  LD (CSR_ROW),HL
  RET
  
OUTC_SUB_1:
  CALL $7426
  CALL OUTC_SUB_3
OUTC_SUB_2:
  LD HL,(CSRX)
  EX DE,HL
  CALL MOVE_CURSOR
  LD A,(CSR_STATUS)
  AND A
  RET Z
  JP __MENU_75
  
OUTC_SUB_3:
  LD HL,ESCCNT
  LD A,(HL)
  AND A
  JP NZ,IN_ESC
  LD A,C
  CP ' '
  JP C,TTY_VECT_JP_1

RSTSYS4:
  LD HL,(CSRX)
  CP $7F		; BS
  JP Z,CURSON2
  LD C,A
  CALL ESC_J_1
  CALL LOCK6
  RET NZ
  CALL RSTSYS5
  LD H,$01
  CALL LOCK9
  RET NZ
  CALL __MENU_199
  AND A
  RET NZ
  CALL UPD_COORDS
  CALL CURSOFF8
  LD L,$01
  JP ESC_M_0
  
RSTSYS5:
  CALL TTY_VECT_JP_0_1
  JP HOME33

TTY_VECT_JP_0:
  SBC A,(HL)
  LD C,C
  
TTY_VECT_JP_1:
  LD HL,ESCTBL-2

TTY_VECT_JP:
  LD C,$0C

; This entry point is used by the routine at GET_DEVICE.
TTY_VECT_JP_2:
  INC HL
  INC HL
  AND A
  DEC C
  RET M
  CP (HL)
  INC HL
  JP NZ,TTY_VECT_JP_2
  LD A,(HL)
  INC HL
  LD H,(HL)
  LD L,A
  PUSH HL
  LD HL,INVALID_CH
  EX (SP),HL
  PUSH HL
  LD HL,(CSRX)
  RET

TTY_CTLCODES:
  DEFB $07                ; Control code + JP location list for TTY controls
  DEFW $76EB              ; Control code + JP location list for TTY controls
  DEFB $08                ; Control code + JP location list for TTY controls
  DEFW LOCK8          ; Control code + JP location list for TTY controls
  DEFB $09                ; Control code + JP location list for TTY controls
  DEFW UNLOCK2          ; Control code + JP location list for TTY controls
  DEFB $0A                ; Control code + JP location list for TTY controls
  DEFW $43B8              ; Control code + JP location list for TTY controls
  DEFB $0B                ; Control code + JP location list for TTY controls
  DEFW ESC_H          ; Control code + JP location list for TTY controls
  DEFB $0C                ; Control code + JP location list for TTY controls
  DEFW $45CC              ; Control code + JP location list for TTY controls
  DEFB $0D                ; Control code + JP location list for TTY controls
  DEFW CURS_CR          ; Control code + JP location list for TTY controls
  DEFB $1B                ; Control code + JP location list for TTY controls
  DEFW ESC_MODE              ; Control code + JP location list for TTY controls
  DEFB $1C                ; Control code + JP location list for TTY controls
  DEFW $44ED              ; Control code + JP location list for TTY controls
  DEFB $1D                ; Control code + JP location list for TTY controls
  DEFW LOCK8          ; Control code + JP location list for TTY controls
  DEFB $1E                ; Control code + JP location list for TTY controls
  DEFW $44E8              ; Control code + JP location list for TTY controls
  DEFB $1F                ; Control code + JP location list for TTY controls
  DEFW LOCK9          ; Control code + JP location list for TTY controls

; This entry point is used by the routine at GET_DEVICE.
TTY_VECT_JP_0_1:
  LD A,(CRTFLG)
  AND A
  RET Z
  POP AF
  RET
  
TEXT_LINES:
  LD A,(LABEL_LN)
  ADD A,$08
  RET


; Set cursor position
ESC_Y:
  LD A,$02
  defb $01	; LD BC,NN

; (27), This routine puts the LCD output routine into ESCape mode
;
; Used by the routine at ESC_W.
ESC_MODE:
	;ESC_MODE+1: XOR A 
  LD A,$AF
  LD (ESCCNT),A
  RET


  
; a.k.a. TTY_ESC
ESCFN:
; a.k.a. TTY_ESC
ESCFN:
  DEFM "j"
  DEFW _CLS

  DEFM "E"
  DEFW _CLS

  DEFM "K"
  DEFW ESC_K

  DEFM "J"
  DEFW ESC_J

  DEFM "l"
  DEFW ESC_CLINE		; ESC,"l", clear line

  DEFM "L"
  DEFW ESC_L

  DEFM "M"
  DEFW ESC_M

  DEFM "Y"
  DEFW ESC_Y

  DEFM "A"
  DEFW ESC_A

  DEFM "B"
  DEFW ESC_B

  DEFM "C"
  DEFW ESC_X_1

  DEFM "D"
  DEFW ESC_D

  DEFM "H"
  DEFW ESC_H		; Home cursor

  DEFM "p"
  DEFW ESC__p

  DEFM "q"
  DEFW ESC__q

  DEFM "P"
  DEFW ESC_P

  DEFM "Q"
  DEFW ESC_Q

  DEFM "T"
  DEFW ESC_T

  DEFM "U"
  DEFW ESC_U

  DEFM "V"
  DEFW ESC_V

  DEFM "W"
  DEFW ESC_W

  DEFM "X"
  DEFW ESC_X
  
  

; ESCape sequence processor.
;
; Used by the routine at OUTC_SUB.
IN_ESC:
  RST $38
  LD B,(HL)
  LD A,C
  CP $1B
  LD A,(HL)
  JP Z,LOCK5
  AND A
  JP P,LOCK3
  CALL ESC_MODE+1
  LD A,C
  LD HL,ESCFN-2
LOCK2:
  LD C,$18
  JP TTY_VECT_JP_2
  
LOCK3:
  DEC A
  LD (ESCCNT),A
  LD A,(ACTV_Y)
  LD DE,CSRY
  JP Z,LOCK4
  LD A,(ACTV_X)
  LD HL,LABEL_LN
  ADD A,(HL)
  DEC DE
LOCK4:
  LD B,A
  LD A,C
  SUB $20
  CP B
  INC A
  LD (DE),A
  RET C
  LD A,B
  LD (DE),A
  RET

; Start inverse video mode
ESC__p:
  defb $f6		; OR $AF

; Cancel inverse video
ESC__q:
  XOR A
  LD (REVERSE),A
  RET

; Unprotect line 8
ESC_U:
  XOR A
  defb $C2	; JP NZ,NN (always false)

; Protect line 8
ESC_T:
  LD A,$FF
  LD (LABEL_LN),A
  RET

; Stop automatic scrolling
ESC_V:
  defb $f6		; OR $AF

; Resume automatic scrolling
ESC_W:
  XOR A
  LD (NO_SCROLL),A
  RET


;ESC_?:
  defb $f6		; OR $AF
;  OR $AF
;ESC_?:
  XOR A
  LD (CSTYLE),A
  RET

LOCK5:
  INC HL
  LD (HL),A
  JP ESC_MODE
  

; ESC X
ESC_X:
  LD HL,ESCSAV
  
; This entry point is used by the routine at DSKI_S.
; (Erase last character ?)
ESC_X_0:
  LD A,(HL)
  LD (HL),$00
  DEC HL
  LD (HL),A
  RET
  

LOCK6:
  LD A,(ACTV_Y)
  CP H
  RET Z
  INC H
  JP UPD_COORDS
LOCK7:
  DEC H
  RET Z
  JP UPD_COORDS
LOCK8:
  CALL LOCK7
  RET NZ
  LD A,(ACTV_Y)
  LD H,A
  DEC L
  RET Z
  JP UPD_COORDS
  CALL LOCK6
  RET NZ
  LD H,$01
LOCK9:
  CALL GET_BT_ROWPOS
  CP L
  RET Z
  JP C,UNIN_ESC
  INC L
UPD_COORDS:
  LD (CSRX),HL
  RET
UNIN_ESC:
  DEC L
  XOR A
  JP UPD_COORDS
UNLOCK2:
  LD A,(CSRY)
  PUSH AF
  LD A,' '
  CALL RSTSYS4
  POP BC
  LD A,(CSRY)
  CP B
  RET Z
  DEC A
  AND $07
  JP NZ,UNLOCK2
  RET
  
; Home cursor (ESC H) and vertical tab (0Bh)
;
; Used by the routine at _CLS.
; Home cursor
ESC_H:
  LD L,$01

; Move cursor to beginning
;
; Used by the routines at ESC_M and ESC_L.
CURS_CR:
  LD H,$01
  JP UPD_COORDS
  
  LD A,$AF
  LD HL,CSR_STATUS
  LD (HL),A
  CALL TTY_VECT_JP_0_1
  LD A,(HL)
  AND A
  JP __MENU_76


; Erase current line
ESC_M:
  CALL CURS_CR
ESC_M_0:
  CALL TTY_VECT_JP_0_1
  CALL TEXT_LINES
  SUB L
  RET C
  JP Z,ESC_CLINE		; ESC,"l", clear line
  PUSH HL
  PUSH AF
  LD B,A
  CALL GETTRM
  LD L,E
ESC_M_0:
  LD H,D
  INC HL
  CALL LDIR_B
  LD HL,FSTPOS
  DEC (HL)
  POP AF
  POP HL
ESC_M_1:
  PUSH AF
  LD H,40
ESC_M_2:
  INC L
  CALL ESC_L_2
  DEC L
  CALL RESET_CONSOLE
  DEC H
  JP NZ,ESC_M_2
  INC L
  POP AF
  DEC A
  JP NZ,ESC_M_1
  JP ESC_CLINE


; Insert line
ESC_L:
  CALL CURS_CR
  CALL TTY_VECT_JP_0_1
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
  DEC HL
  CALL _LDDR
  POP AF
  POP HL
UNLOCK9:
  PUSH AF
  LD H,40
CURSON0:
  DEC L
  CALL ESC_L_2
  INC L
  CALL RESET_CONSOLE
  DEC H
  JP NZ,CURSON0
  DEC L
  POP AF
  DEC A
  JP NZ,UNLOCK9
  JP ESC_CLINE
  
ESC_L_2:
  PUSH HL
  PUSH HL
  CALL ESC_J_4
  LD C,(HL)
  POP HL
  CALL ESC_J_7
  AND (HL)
  POP HL
  RET

CURSON2:
  CALL LOCK8
  CALL TTY_VECT_JP_0_1
CURSON3:
  XOR A
  LD C,$20
  JP RESET_CONSOLE
ESC_CLINE:
  LD H,$01

ESC_K:
  CALL TTY_VECT_JP_0_1
  CALL HOME32
CURSON6:
  CALL CURSON3
  INC H
  LD A,H
  CP ')'
  JP C,CURSON6
  RET

  CALL ESC_H
  CALL CLR_ALTLCD

; Erase from the cursor to the bottom of the screen
; "erase in display"
ESC_J:
  CALL TTY_VECT_JP_0_1
  
CURSON7:
  CALL ESC_K
  CALL TEXT_LINES
  CP L
  RET C
  RET Z
  LD H,$01
  INC L
  JP CURSON7
  
ESC_J_1:
  CALL TTY_VECT_JP_0_1
  LD A,(REVERSE)

; This entry point is used by the routines at ESC_M, ESC_L and ESC_K.
RESET_CONSOLE:
  PUSH HL
  PUSH AF
  PUSH HL
  PUSH HL
  CALL ESC_J_5
  POP HL
  CALL ESC_J_4
  LD (HL),C
  POP DE
  CALL INIT_LCD
  POP AF
  AND A
  POP HL
  RET Z
ESC_J_3:
  DI
  LD A,$0D
  JR NC,ESC_J_3
  CALL PUT_SHAPE
  LD A,$09
  ;JR NC,$45D3
  JR NC,ESC_J+1		; ???

ESC_J_4:
  LD A,L
  ADD A,A
  ADD A,A
  ADD A,L
  ADD A,A
  ADD A,A
  ADD A,A
  LD E,A
  SBC A,A
  CPL
  LD D,A
  LD L,H
  LD H,$00
  ADD HL,DE
  LD DE,$FDD7
  ADD HL,DE
  RET

ESC_J_5:
  LD B,A
  CALL ESC_J_7
  INC B
  DEC B
  JP Z,$4629
  OR (HL)
  JP Z,CALLHL6
  LD (HL),A
  RET
  
ESC_J_7:
  LD A,L
  ADD A,A
  ADD A,A
  ADD A,L
  LD L,A
  LD A,H
  DEC A
  PUSH AF
  RRCA
  RRCA
  RRCA
  AND $1F
  ADD A,L
  LD L,A
  LD H,$00
  LD DE,$FA5B
  ADD HL,DE
  POP AF
  AND $07
  LD D,A
  XOR A
  SCF
CURSOFF4:
  RRA
  DEC D
  JP P,CURSOFF4
  RET
  
; This entry point is used by the routine at GET_DEVICE.
ESC_J_9:
  PUSH HL
  CALL ESC_J_7
  XOR (HL)
  LD (HL),A
  POP HL
  RET
  
; This entry point is used by the routine at GET_DEVICE.
CLR_ALTLCD:
  CALL TTY_VECT_JP_0_1
  LD A,(FNK_FLAG)
  ADD A,A
  RET P
  PUSH HL
  LD HL,ALT_LCD
  LD BC,$0140
CURSOFF7:
  LD (HL),' '
  INC HL
  DEC BC
  LD A,B
  OR C
  JP NZ,CURSOFF7
  POP HL
  RET
  
CURSOFF8:
  CALL TTY_VECT_JP_0_1
  LD A,(FNK_FLAG)
  ADD A,A
  RET P
  LD DE,ALT_LCD
  LD HL,$FBE8
  LD BC,$0140	; 40x8
  JP _LDIR
  
; This entry point is used by the routine at GET_DEVICE.
CURSOFF9:
  CALL $7426
  LD L,$01
DELLIN0:
  LD H,$01
DELLIN1:
  CALL ESC_L_2
  CALL RESET_CONSOLE
  INC H
  LD A,H
  CP ')'
  JP NZ,DELLIN1
  INC L
  LD A,L
  CP $09
  JP NZ,DELLIN0
  JP OUTC_SUB_2
  
; This entry point is used by the routine at GET_DEVICE.
DELLIN2:
  LD HL,ALT_LCD
  LD E,$01
DELLIN3:
  LD D,$01
DELLIN4:
  PUSH HL
  PUSH DE
  LD C,(HL)
  CALL INIT_LCD
  POP DE
  POP HL
  INC HL
  INC D
  LD A,D
  CP ')'
  JP NZ,DELLIN4
  INC E
  LD A,E
  CP $09
  JP NZ,DELLIN3
  RET
  

; _INLIN  backspace, left arrow, control H handler
;
; Used by the routines at _INLIN, _INLIN_CTL_UX and MOVE_TEXT.
_INLIN_BS:
  LD A,B
  DEC A
  SCF
  RET Z
  DEC B
  DEC DE
  CALL DELLIN9
_INLIN_BS_0:
  PUSH AF
  LD A,$7F
  RST OUTC
  LD HL,(CSRX)
  DEC L
  DEC H
  LD A,H
  OR L
  JP Z,_INLIN_BS_1
  LD HL,CSRY
  POP AF
  CP (HL)
  JP NZ,_INLIN_BS_0
  RET
  
_INLIN_BS_1:
  POP AF
  SCF
  RET
  
_INLIN_CTL_UX:
  CALL _INLIN_BS
  JP NC,_INLIN_CTL_UX
  RET
  
DELLIN9:
  PUSH BC
  LD A,(SV_CSRY)
  DEC B
  JP Z,INSLIN3
  LD C,A
  LD HL,INPBFR
INSLIN0:
  INC C
  LD A,(HL)
  CP $09
  JP NZ,INSLIN1
  LD A,C
  DEC A
  AND $07
  JP NZ,INSLIN0
INSLIN1:
  LD A,(ACTV_Y)
  CP C
  JP NC,INSLIN2
  LD C,$01
INSLIN2:
  INC HL
  DEC B
  JP NZ,INSLIN0
  LD A,C
INSLIN3:
  POP BC
  RET
  
_INLIN_FILE:
  LD HL,(PTRFIL)
  PUSH HL
  INC HL
  INC HL
  INC HL
  INC HL
  LD A,(HL)
  SUB $F9
  JP NZ,_INLIN_FILE_0
  LD L,A
  LD H,A
  LD (PTRFIL),HL			; Redirect I/O
  LD HL,SV_TXTPOS
  INC (HL)
  LD A,(HL)
  RRCA
  CALL NC,HOME5
  LD HL,CR_WAIT_MSG
  CALL PRS
  CALL EXTREV
_INLIN_FILE_0:
  POP HL
  LD (PTRFIL),HL			; Redirect I/O
  LD B,$FF
  LD HL,INPBFR		; On M100 KBUF is used directly
_INLIN_FILE_1:
  XOR A
  LD (RAMFILE),A
  LD (RAMFILE+1),A
  CALL RDBYT
  JP C,INSLIN9
  LD (HL),A
  CP $0D         	; CR
  JP Z,_INLIN_FILE_3
  CP $09			; TAB
  JP Z,_INLIN_FILE_2
  CP ' '
  JP C,_INLIN_FILE_1
_INLIN_FILE_2:
  INC HL
  DEC B
  JP NZ,_INLIN_FILE_1
_INLIN_FILE_3:
  XOR A
  LD (HL),A
  LD HL,BUFMIN
  RET
  
INSLIN9:
  INC B
  JP NZ,_INLIN_FILE_3
  LD A,(NLONLY)
  AND $80
  LD (NLONLY),A
  CALL SCPTLP_104
  LD A,$0D		; CR
  RST OUTC
  CALL ERAEOL
  LD A,(FILFLG)
  AND A
  JP Z,ERAEOL0
  CALL RUN_FST
  JP EXEC_EVAL_0
  
ERAEOL0:
  LD A,(ERRTRP-1)
  AND A
  JP NZ,__EDIT_3
  JP RESTART
  
; This entry point is used by the routine at SNERR.
ERAEOL1:
  CALL ISFLIO
  JP NZ,_INLIN_FILE
  RST $38
  LD B,B
  LD L,A
  JP ERAEOL4
; This entry point is used by the routines at __DATA and GET_DEVICE.
QINLIN:
  LD A,$3F
  RST OUTC
  LD A,' '
  RST OUTC
; This entry point is used by the routines at __DATA and GET_DEVICE.
_INLIN:
  RST $38
  LD B,D			; HINLI, Hook for INLIN std routine
  LD HL,(CSRX)
  DEC L
  CALL NZ,HOME32
  INC L
ERAEOL4:
  LD (FSTPOS),HL
  LD A,(CSR_STATUS)
  LD ($F99A),A
  CALL CURSOFF
ERAEOL5:
  CALL CHGET
  JP C,ERAEOL5
  LD HL,$47FA
  LD C,$08
  CALL TTY_VECT_JP_2
  PUSH AF
  CALL NZ,ERAEOL6
  POP AF
  JP NC,ERAEOL5
  PUSH AF
  LD A,($F99A)
  AND A
  CALL NZ,CURSON
  POP AF
  LD HL,BUFMIN
  RET Z
  CCF
  RET
ERAEOL6:
  LD HL,$F3DA
  CP ' '
  JP C,ERAEOL7
  PUSH AF
  LD A,(HL)
  AND A
  CALL NZ,_ESC_X3
  POP AF
  RST OUTC
  RET
ERAEOL7:
  LD (HL),$00
  RST OUTC
  JP HOME2
  EX AF,AF'
  ADD HL,BC
  LD C,C
  LD (DE),A
  LD L,A
  LD C,B
  LD A,(BC)
  CALL PO,WORDS_2
  LD E,B
  LD C,C
  INC BC
  LD E,L
  LD C,B
  DEC C
  INC D
  LD C,B
  DEC D
  LD D,D
  LD C,C
  LD A,A
  INC BC
  LD C,C
  CALL HOME28
  LD DE,INPBFR
  LD B,$FE
  DEC L
ERAEOL8:
  INC L
ERAEOL9:
  PUSH DE
  PUSH BC
  CALL ESC_L_2
  LD A,C
  POP BC
  POP DE
  LD (DE),A
  INC DE
  DEC B
  JP Z,_ESC_X0
  INC H
  LD A,$28
  CP H
  JP NC,ERAEOL9
  PUSH DE
  CALL GETTRM
  POP DE
  LD H,$01
  JP Z,ERAEOL8
_ESC_X0:
  DEC DE
  LD A,(DE)
  CP ' '
  JP Z,_ESC_X0
  INC DE
  XOR A
  LD (DE),A
  LD A,$0D
  AND A
_ESC_X1:
  PUSH AF
  CALL HOME32
  CALL POSIT
  LD A,$0A
  RST OUTC
  XOR A
  LD ($F3DA),A
  POP AF
  SCF
  POP HL
  RET
_ESC_X2:
  INC L
  CALL GETTRM
  JP Z,_ESC_X2
  CALL HOME2
  XOR A
  LD (INPBFR),A
  LD H,$01
  JP _ESC_X1
  LD HL,$F3DA
  LD A,(HL)
  CPL
  LD (HL),A
  AND A
  JP Z,HOME2
  JP HOME3
_ESC_X3:
  LD HL,(CSRX)
  LD C,$20
  LD A,(REVERSE)
_ESC_X4:
  PUSH HL
_ESC_X5:
  PUSH BC
  PUSH AF
  CALL ESC_L_2
  POP DE
  LD B,D
  POP DE
  PUSH BC
  PUSH AF
  LD C,E
  LD A,B
  CALL RESET_CONSOLE
  POP DE
  POP BC
  LD A,$28
  INC A
  INC H
  CP H
  LD A,D
  JP NZ,_ESC_X5
  POP HL
  PUSH DE
  CALL GETTRM
  POP DE
  JP Z,HOME20
  LD A,C
  CP ' '
  PUSH AF
  JP NZ,_ESC_X6
  LD A,$28
  CP H
  JP Z,_ESC_X6
  POP AF
  RET
_ESC_X6:
  PUSH DE
  XOR A
  CALL HOME33
  POP DE
  INC L
  PUSH BC
  PUSH DE
  PUSH HL
  CALL TEXT_LINES
  CP L
  JP C,_ESC_X7
  EX DE,HL
  LD HL,(CSRX)
  EX DE,HL
  PUSH DE
  CALL POSIT
  CALL INSLIN
  POP HL
  CALL POSIT
  JP _ESC_X9
_ESC_X7:
  EX DE,HL
  LD HL,(CSRX)
  EX DE,HL
  PUSH DE
  LD HL,$0101
  CALL POSIT
  CALL DELLIN
  POP HL
  DEC L
  JP NZ,_ESC_X8
  INC L
_ESC_X8:
  CALL POSIT
  POP HL
  DEC L
  PUSH HL
_ESC_X9:
  POP HL
  POP DE
  POP BC
  POP AF
  RET Z
  DEC L
HOME20:
  LD H,$01
  INC L
  LD A,D
  JP _ESC_X4
  LD A,$1C
  RST OUTC
  LD HL,(CSRX)
  DEC H
  JP NZ,HOME22
  INC H
  PUSH HL
  DEC L
  JP Z,HOME21
  LD A,$28
  LD H,A
  CALL GETTRM
  JP NZ,HOME21
  EX (SP),HL
HOME21:
  POP HL
HOME22:
  CALL POSIT
HOME23:
  LD A,$28
  CP H
  JP Z,HOME25
  INC H
HOME24:
  CALL ESC_L_2
  DEC H
  CALL RESET_CONSOLE
  INC H
  INC H
  LD A,$28
  INC A
  CP H
  JP NZ,HOME24
  DEC H
HOME25:
  LD C,$20
  XOR A
  CALL RESET_CONSOLE
  CALL GETTRM
  RET NZ
  PUSH HL
  INC L
  LD H,$01
  CALL ESC_L_2
  EX (SP),HL
  CALL RESET_CONSOLE
  POP HL
  JP HOME23
  CALL HOME28
  CALL POSIT
  CALL HOME2
  XOR A
  LD ($F3DA),A
  PUSH HL
HOME26:
  CALL GETTRM
  PUSH AF
  CALL ERAEOL
  POP AF
  JP NZ,HOME27
  LD H,$01
  INC L
  CALL POSIT
  JP HOME26
HOME27:
  POP HL
  JP POSIT
HOME28:
  DEC L
  JP Z,HOME29
  CALL GETTRM
  JP Z,HOME28
HOME29:
  INC L
  LD A,(FSTPOS)
  CP L
  LD H,$01
  RET NZ
  LD HL,(FSTPOS)
  RET
GETTRM:
  PUSH HL
  LD DE,$F826
  LD H,$00
  ADD HL,DE
  LD A,(HL)
  EX DE,HL
  POP HL
  AND A
  RET
; This entry point is used by the routine at GET_DEVICE.
HOME31:
  CALL TTY_VECT_JP_0_1
HOME32:
  LD A,L
HOME33:
  PUSH AF
  CALL GETTRM
  POP AF
  LD (DE),A
  RET
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  RET Z
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','

; DIM command
__DIM:
  LD BC,$49A5
  PUSH BC
  
  defb $f6		; OR $AF

; Get variable address to DE
;
; Used by the routines at __DATA, OPRND, CHKSTK and SCPTLP.
GETVAR:
  XOR A
  LD (DIMFLG),A
  LD C,(HL)
  CALL IS_ALPHA
  JP C,SNERR
  XOR A
  LD B,A
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JP C,GETVAR_0
  CALL IS_ALPHA_A
  JP C,GETVAR_2
GETVAR_0:
  LD B,A
GETVAR_1:
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JP C,GETVAR_1
  CALL IS_ALPHA_A
  JP NC,GETVAR_1
GETVAR_2:
  CP '&'
  JP NC,GETVAR_3
  LD DE,GVAR
  PUSH DE
  LD D,$02
  CP '%'
  RET Z
  INC D
  CP '$'
  RET Z
  INC D
  CP '!'
  RET Z
  LD D,$08
  CP '#'
  RET Z
  POP AF
GETVAR_3:
  LD A,C
  AND $7F
  LD E,A
  LD D,$00
  PUSH HL
  LD HL,VARIABLES
  ADD HL,DE
  LD D,(HL)
  POP HL
  DEC HL
  
GVAR:
  LD A,D
  LD (VALTYP),A
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  LD A,(SUBFLG)
  DEC A
  JP Z,SBSCPT_1
  JP P,GETVAR_4
  LD A,(HL)
  SUB $28	; '('
  JP Z,SBSCPT
  SUB $33
  JP Z,SBSCPT
GETVAR_4:
  XOR A
  LD (SUBFLG),A
  PUSH HL
  LD HL,(PROGND)
  JP GETVAR_7
GETVAR_5:
  LD A,(DE)
  LD L,A
  INC DE
  LD A,(DE)
  INC DE
  CP C
  JP NZ,GETVAR_6
  LD A,(VALTYP)
  CP L
  JP NZ,GETVAR_6
  LD A,(DE)
  CP B
  JP Z,GETVAR_10
GETVAR_6:
  INC DE
  LD H,$00
  ADD HL,DE
GETVAR_7:
  EX DE,HL
  LD A,(VAREND)
  CP E
  JP NZ,GETVAR_5
  LD A,($FAE8)
  CP D
  JP NZ,GETVAR_5
  JP GETVAR_8
GETVAR_8:
  POP HL
  EX (SP),HL
  PUSH DE
  LD DE,$12AA
  RST CPDEHL
  POP DE
  JP Z,GETVAR_11
  EX (SP),HL
  PUSH HL
  PUSH BC
  LD A,(VALTYP)
  LD C,A
  PUSH BC
  LD B,$00
  INC BC
  INC BC
  INC BC
  LD HL,(ARREND)
  PUSH HL
  ADD HL,BC
  POP BC
  PUSH HL
  CALL __POS_1
  POP HL
  LD (ARREND),HL
  LD H,B
  LD L,C
  LD (VAREND),HL
GETVAR_9:
  DEC HL
  LD (HL),$00
  RST CPDEHL
  JP NZ,GETVAR_9
  POP DE
  LD (HL),E
  INC HL
  POP DE
  LD (HL),E
  INC HL
  LD (HL),D
  EX DE,HL
GETVAR_10:
  INC DE
  POP HL
  RET
  
GETVAR_11:
  LD (FACCU),A
  LD H,A
  LD L,A
  LD (DBL_FPREG),HL
  RST GETYPR 		; Get the number type (FAC)
  JP NZ,GETVAR_12		; JP if not string type, 
  LD HL,NULL_STRING
  LD (DBL_FPREG),HL
GETVAR_12:
  POP HL
  RET

; Sort out subscript
;
; Used by the routine at GETVAR.
SBSCPT:
  PUSH HL			; Save code string address
  LD HL,(DIMFLG)
  EX (SP),HL		; Save and get code string
  LD D,A			; Zero number of dimensions

; SBSCPT loop
SCPTLP:
  PUSH DE			; Save number of dimensions
  PUSH BC			; Save array name
  CALL GET_POSINT		; Get subscript
  POP BC
  POP AF			; Get number of dimensions
  EX DE,HL
  EX (SP),HL		; Save subscript value
  PUSH HL			; Save LCRFLG and TYPE (DIMFLAG)
  EX DE,HL
  INC A				; Count dimensions
  LD D,A			; Save in D
  LD A,(HL)			; Get next byte in code string
  CP ','
  JP Z,SCPTLP
  CP ')'
  JP Z,SCPTLP_0
  CP ']'
  JP NZ,SNERR
SCPTLP_0:
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  LD (TEMP2),HL
  POP HL
  LD (DIMFLG),HL
  LD E,$00
  PUSH DE
  
  defb $11	
;  LD DE,$F5E5

SBSCPT_1:
  PUSH HL
  PUSH AF
  LD HL,(VAREND)

  ;LD A,$19
  DEFB $3E  ; "LD A,n" to Mask the next byte

SBSCPT_2:
  ADD HL,DE
  EX DE,HL
  LD HL,(ARREND)
  EX DE,HL
  RST CPDEHL

  JP Z,BSOPRND_0
  LD E,(HL)
  INC HL
  LD A,(HL)
  INC HL
  CP C
  JP NZ,SCPTLP_1
  LD A,(VALTYP)
  CP E
  JP NZ,SCPTLP_1
  LD A,(HL)
  CP B
SCPTLP_1:
  INC HL
  LD E,(HL)
  INC HL
  LD D,(HL)
  INC HL
  JP NZ,SBSCPT_2
  LD A,(DIMFLG)
  OR A
  JP NZ,$0577
  POP AF
  LD B,H
  LD C,L
  JP Z,POPHLRT
  SUB (HL)
  JP Z,SCPTLP_8

; This entry point is used by the routine at MLDEBC.
; "Subscript error" / "Subscript out of range"
SBSCT_ERR:
  LD DE,$0009
  JP ERROR
  
BSOPRND_0:
  LD A,(VALTYP)
  LD (HL),A
  INC HL
  LD E,A
  LD D,$00
  POP AF
  JP Z,FCERR
  LD (HL),C
  INC HL
  LD (HL),B
  INC HL
  LD C,A
  CALL CHKSTK
  INC HL
  INC HL
  LD (TEMP3),HL
  LD (HL),C
  INC HL
  LD A,(DIMFLG)
  RLA
  LD A,C
SCPTLP_4:
  LD BC,$000B
  JP NC,SCPTLP_5
  POP BC
  INC BC
SCPTLP_5:
  LD (HL),C
  PUSH AF
  INC HL
  LD (HL),B
  INC HL
  CALL MLDEBC
  POP AF
  DEC A
  JP NZ,SCPTLP_4
  PUSH AF
  LD B,D
  LD C,E
  EX DE,HL
  ADD HL,DE
; This entry point is used by the routine at ISFLIO.
SCPTLP_6:
  JP C,OMERR
  CALL $3FD5
  LD (ARREND),HL
SCPTLP_7:
  DEC HL
  LD (HL),$00
  RST CPDEHL
  JP NZ,SCPTLP_7
  INC BC
  LD D,A
  LD HL,(TEMP3)
  LD E,(HL)
  EX DE,HL
  ADD HL,HL
  ADD HL,BC
  EX DE,HL
  DEC HL
  DEC HL
  LD (HL),E
  INC HL
  LD (HL),D
  INC HL
  POP AF
  JP C,SCPTLP_11
SCPTLP_8:
  LD B,A
  LD C,A
  LD A,(HL)
  INC HL
  LD D,$E1
  LD E,(HL)
  INC HL
  LD D,(HL)
  INC HL
  EX (SP),HL
  PUSH AF
  RST CPDEHL
  JP NC,SBSCT_ERR		; "Subscript error" / "Subscript out of range"
  CALL MLDEBC
  ADD HL,DE
  POP AF
  DEC A
  LD B,H
  LD C,L
  JP NZ,$4B6E
  LD A,(VALTYP)
  LD B,H
  LD C,L
  ADD HL,HL
  SUB $04
  JP C,SCPTLP_9
  ADD HL,HL
  JP Z,SCPTLP_10
  ADD HL,HL
SCPTLP_9:
  OR A
  JP PO,SCPTLP_10
  ADD HL,BC
SCPTLP_10:
  POP BC
  ADD HL,BC
  EX DE,HL
SCPTLP_11:
  LD HL,(TEMP2)
  RET
  
; This entry point is used by the routine at __DATA.
USING:
  CALL EVAL_0
  CALL TSTSTR
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEC SP
  EX DE,HL
  LD HL,(DBL_FPREG)
  JP USING_1
USING_0:
  LD A,(FLGINP)
  OR A
  JP Z,USING_2
  POP DE
  EX DE,HL
USING_1:
  PUSH HL
  XOR A
  LD (FLGINP),A
  INC A
  PUSH AF
  PUSH DE
  LD B,(HL)
  INC B
  DEC B
USING_2:
  JP Z,FCERR
  INC HL
  LD A,(HL)
  INC HL
  LD H,(HL)
  LD L,A
  JP USING_7

SCPTLP_16:
  CALL BSOPRND_03
  RST OUTC
USING_7:
  XOR A
  LD E,A
  LD D,A
SCPTLP_18:
  CALL BSOPRND_03
  LD D,A
  LD A,(HL)
  INC HL
  CP '#'
  JP Z,SBSCT_ERR1
  DEC B
  JP Z,BSOPRND_00
  CP '+'
  LD A,$08
  JP Z,SCPTLP_18
  DEC HL
  LD A,(HL)
  INC HL
  CP '.'
  JP Z,SBSCT_ERR2
  CP (HL)
  JP NZ,SCPTLP_16
  CP $5C  	;'\'
  JP Z,L4C12+1
  CP '*'
  JP NZ,SCPTLP_16
  INC HL
  LD A,B
  CP $02
  JP C,SCPTLP_19
  LD A,(HL)
  CP $5C  	;'\'
SCPTLP_19:
  LD A,' '
  JP NZ,SBSCT_ERR0
  DEC B
  INC E
  
L4C12:
  CP $AF
  ; L4C12+1:  XOR A

  ADD A,$10
  INC HL
SBSCT_ERR0:
  INC E
  ADD A,D
  LD D,A
  
SBSCT_ERR1:
  INC E
  LD C,$00
  DEC B
  JP Z,SBSCT_ERR5
  LD A,(HL)
  INC HL
  CP '.'
  JP Z,SBSCT_ERR3
  CP '#'
  JP Z,SBSCT_ERR1
  CP ','
  JP NZ,SBSCT_ERR4
  LD A,D
  OR $40
  LD D,A
  JP SBSCT_ERR1
  
SBSCT_ERR2:
  LD A,(HL)
  CP '#'
  LD A,'.'
  JP NZ,SCPTLP_16
  LD C,$01
  INC HL
SBSCT_ERR3:
  INC C
  DEC B
  JP Z,SBSCT_ERR5
  LD A,(HL)
  INC HL
  CP '#'
  JP Z,SBSCT_ERR3
SBSCT_ERR4:
  PUSH DE
  LD DE,SBSCT_ERR5-2
  PUSH DE
  LD D,H
  LD E,L
  CP $5E
  RET NZ
  CP (HL)
  RET NZ
  INC HL
  CP (HL)
  RET NZ
  INC HL
  CP (HL)
  RET NZ
  INC HL
  LD A,B
  SUB $04
  RET C
  POP DE
  POP DE
  LD B,A
  INC D
  INC HL
;  JP Z,GET_DEVICE_691
  JP Z,$D1EB		; ??  probably 'Z' never happens (same trick on MSX)
;  EX DE,HL / POP DE

SBSCT_ERR5:
  LD A,D
  DEC HL
  INC E
  AND $08
  JP NZ,SBSCT_ERR7
  DEC E
  LD A,B
  OR A
  JP Z,SBSCT_ERR7
  LD A,(HL)
  SUB $2D		; '-'
  JP Z,SBSCT_ERR6
  CP $FE
  JP NZ,SBSCT_ERR7
  LD A,$08
SBSCT_ERR6:
  ADD A,$04
  ADD A,D
  LD D,A
  DEC B
SBSCT_ERR7:
  POP HL
  POP AF
  JP Z,BSOPRND_02
  PUSH BC
  PUSH DE
  CALL EVAL
  POP DE
  POP BC
  PUSH BC
  PUSH HL
  LD B,E
  LD A,B
  ADD A,C
  CP $19
  JP NC,FCERR			; "Illegal function call" error
  
  LD A,D
  OR $80
  CALL FOUT_0		; Convert number/expression to string (format specified in 'A' register)
  CALL PRS
  
  POP HL
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  SCF
  JP Z,SBSCT_ERR9
  LD (FLGINP),A
  CP ';'
  JP Z,SBSCT_ERR8
  CP ','
  JP NZ,SNERR
SBSCT_ERR8:
  RST CHRGTB		; Gets next character (or token) from BASIC text.
SBSCT_ERR9:
  POP BC
  EX DE,HL
  POP HL
  PUSH HL
  PUSH AF
  PUSH DE
  LD A,(HL)
  SUB B
  INC HL
  LD D,$00
  LD E,A
  LD A,(HL)
  INC HL
  LD H,(HL)
  LD L,A
  ADD HL,DE
  LD A,B
  OR A
  JP NZ,USING_7
  JP BSOPRND_01
BSOPRND_00:
  CALL BSOPRND_03
  RST OUTC
BSOPRND_01:
  POP HL
  POP AF
  JP NZ,USING_0
BSOPRND_02:
  CALL C,OUTDO_CRLF
  EX (SP),HL
  CALL GSTRHL
  POP HL
  JP FINPRT

BSOPRND_03:
  PUSH AF
  LD A,D
  OR A
  LD A,'+'
  CALL NZ,_OUTC
  POP AF
  RET

; This entry point is used by the routines at OUTC and GET_DEVICE.
_OUTC:
  PUSH AF
  PUSH HL
  CALL ISFLIO
  JP NZ,OUTC_FOUT
  POP HL
  LD A,(PRTFLG)
  OR A
  JP Z,SCPTLP_43
  POP AF

; Print the character in the A register on the printer.  Expand tabs into
; spaces if nescessary
;
; Used by the routines at LPT_OUTPUT and TEL_TERM.
OUTC_TABEXP:
  PUSH AF
  CP $09
  JP NZ,OUTC_1
OUTC_TABEXP_0:
  LD A,' '
  CALL OUTC_TABEXP
  LD A,(LPT_POS)
  AND $07
  JP NZ,OUTC_TABEXP_0
  POP AF
  RET
  
OUTC_1:
  SUB $0D
  JP Z,OUTC_2
  JP C,OUTC_3
  CP $13
  JP C,OUTC_3
  LD A,(LPT_POS)
  INC A
OUTC_2:
  LD (LPT_POS),A
OUTC_3:
  POP AF
OUTC_4:
  CP $1A		; EOF
  RET Z
  JP LPT_OUT

; This entry point is used by the routines at SNERR and CHKSTK.
INIT_OUTPUT:
  XOR A
  LD (PRTFLG),A
  LD A,(LPT_POS)
  OR A
  RET Z

; This entry point is used by the routine at GET_DEVICE.
INIT_OUTPUT_0:
  LD A,$0D
  CALL OUTC_4
  LD A,$0A
  CALL OUTC_4
  XOR A
  LD (LPT_POS),A
  RET

SCPTLP_43:
  POP AF
  PUSH AF
  CALL OUTC_SUB
  LD A,(CSRY)
  DEC A
  LD (TTYPOS),A
  POP AF
  RET
  
; This entry point is used by the routines at SNERR, GETWORD, CHKSTK and GET_DEVICE.
; $4BB8
CONSOLE_CRLF:
  LD A,(CSRY)
  DEC A
  RET Z
  JP OUTDO_CRLF
  
  LD (HL),$00
  CALL ISFLIO
  LD HL,BUFMIN
  JP NZ,SCPTLP_46
; This entry point is used by the routines at __DATA and MAKINT.
OUTDO_CRLF:
  LD A,$0D
  RST OUTC
  LD A,$0A
  RST OUTC
; This entry point is used by the routines at __DATA and PRS1.
SCPTLP_46:
  CALL ISFLIO
  JP Z,SCPTLP_47
  XOR A
  RET
SCPTLP_47:
  LD A,(PRTFLG)
  OR A
  JP Z,SCPTLP_48
  XOR A
  LD (LPT_POS),A
  RET
SCPTLP_48:
  XOR A
  LD (TTYPOS),A
  RET
; This entry point is used by the routine at OPRND.
FN_INKEY:
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  PUSH HL
  CALL CHSNS
  JP Z,INKEY_S_0
  CALL CHGET
  CP $03
  JP Z,SCPTLP_92
  PUSH AF
  CALL MK_1BYTE_TMST
  POP AF
  LD E,A
  CALL __CHR_S_0
INKEY_S_0:
  LD HL,NULL_STRING
  LD (DBL_FPREG),HL
  LD A,$03
  LD (VALTYP),A
  POP HL
  RET

; This entry point is used by the routines at GETWORD and GET_DEVICE.
FNAME:
  PUSH HL
  JP SCPTLP_53
; This entry point is used by the routine at GETWORD.
FILE_PARMS:
  CALL EVAL
  PUSH HL
  CALL GETSTR
  LD A,(HL)
  OR A
  JP Z,FILE_PARMS_2
  INC HL
  LD E,(HL)
  INC HL
  LD H,(HL)
  LD L,E
  LD E,A
SCPTLP_53:
  CALL USING6
  PUSH AF
  LD BC,FILNAM
  LD D,$09
  INC E
SCPTLP_54:
  DEC E
  JP Z,SCPTLP_60
  LD A,(HL)
  CP ' '
  JP C,FILE_PARMS_2
  CP $7F		; BS
  JP Z,FILE_PARMS_2
  CP '.'
  JP Z,SCPTLP_58
  LD (BC),A
  INC BC
  INC HL
  DEC D
  JP NZ,SCPTLP_54
SCPTLP_55:
  POP AF
  PUSH AF
  LD D,A
  LD A,(FILNAM)
  INC A
  JP Z,FILE_PARMS_2
  POP AF
  POP HL
  RET
FILE_PARMS_2:
  JP NMERR
SCPTLP_57:
  INC HL
  JP SCPTLP_54
SCPTLP_58:
  LD A,D
  CP $09
  JP Z,FILE_PARMS_2
  CP $03
  JP C,FILE_PARMS_2
  JP Z,SCPTLP_57
  LD A,' '
  LD (BC),A
  INC BC
  DEC D
SCPTLP_59:
  JP SCPTLP_58


SCPTLP_60:
  LD A,' '
  LD (BC),A
  INC BC
  DEC D
  JP NZ,SCPTLP_60
  JP SCPTLP_55
  
SCPTLP_61:
  LD A,(HL)
  INC HL
  DEC E
  RET


GETFLP:
  CALL MAKINT

; a.k.a. GETPTR
VARPTR_A:
  LD L,A
  LD A,(MAXFIL)
  CP L
  JP C,BNERR
  LD H,$00
  LD (RAMFILE),HL
  ADD HL,HL
  EX DE,HL
  LD HL,(FILTAB)
  ADD HL,DE
  LD A,(HL)
  INC HL
  LD H,(HL)
  LD L,A
  LD A,(HL)
  OR A
  RET Z
  PUSH HL
  LD DE,$0004
  ADD HL,DE
  LD A,(HL)
  CP $09
  JP NC,SCPTLP_63
  RST $38
  JR NZ,SCPTLP_59
  OR $51
SCPTLP_63:
  POP HL
  LD A,(HL)
  OR A
  SCF
  RET
SCPTLP_64:
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  CP '#'
  CALL Z,_CHRGTB
  CALL GETINT
  EX (SP),HL
  PUSH HL

; a.k.a. SELECT. This entry point is used by the routines at _LOAD, __MERGE and GT_CHANNEL.
SETFIL:
  CALL VARPTR_A
  JP Z,CFERR
  LD (PTRFIL),HL			; Redirect I/O
  RST $38
  DEFB $0E		; HSETF, Offset: 14
  RET
  
__OPEN:
  LD BC,FINPRT
  PUSH BC
  CALL FILE_PARMS
  JP NZ,__OPEN_0
  LD D,$F9		; D = 'RAM' device ?
  
__OPEN_0:
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  ADD A,D			; TK_FOR
  CP $85				; TK_INPUT, 'INPUT' TOKEN code
  LD E,$01
  JP Z,__OPEN_INPUT
  
  CP $9C
  JP Z,__OPEN_OUTPUT
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB 'A'
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB 'P'
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB 'P'
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  ADD A,C
  LD E,$08
  JP __OPEN_2
  
__OPEN_OUTPUT:
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB 'P'
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB 'U'
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB 'T'		; "OUTPUT"  :S
  LD E,$02
  
  DEFB $3E  ; "LD A,n" to Mask the next byte


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
  CALL Z,_CHRGTB
  CALL GETINT
  OR A
  JP Z,BNERR
  RST $38
  DEFB $1A		; HNOFO, Offset: 26
  
;  LD E,$D5
  
  DEFB $1E      ;LD E,N

; Routine at 19730
;
; Used by the routines at __MERGE, __SAVE, __EDIT, TXT_CTL_G and TXT_CTL_V.
_OPEN:
  PUSH DE
  DEC HL
  LD E,A
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JP NZ,SNERR
  EX (SP),HL
  LD A,E
  PUSH AF
  PUSH HL
  CALL VARPTR_A
  JP NZ,AOERR
  POP DE
  LD A,D
  CP $09
  RST $38
  DEFB $1E		; HNULO, Offset: 30
  ;LD E,$DA
  JP C,IEERR
  PUSH HL
  LD BC,$0004
  ADD HL,BC
  LD (HL),D
  LD A,$00
  POP HL
  JP GET_DEVICE

;
; Used by the routines at __CLOSE, INIT_PRINT_h and L4F2E.
CLOSE1:
  PUSH HL
  OR A
  JP NZ,NTFL0
  LD A,(NLONLY)
  AND $01
  JP NZ,SCPTLP_95

; NTFL0 - "NoT FiLe number 0"
NTFL0:
  CALL VARPTR_A
  JP Z,_CLOSE_0
  
  LD (PTRFIL),HL			; Redirect I/O
  PUSH HL
  LD A,$02
  JP C,GET_DEVICE
  
  RST $38
  DEFB $16			; HNTFL, Offset: 22
  ;LD D,$C3
  JP IEERR

; LCD, CRT, and LPT file close routine
;
; Used by the routines at GETWORD, RAM_CLS, CAS_CLS and COM_CLS.
_CLOSE:
  CALL SCPTLP_94
  POP HL
_CLOSE_0:
  PUSH HL
  LD DE,$0007
  ADD HL,DE
  LD (HL),A
  LD H,A
  LD L,A
  LD (PTRFIL),HL			; Redirect I/O
  POP HL
  ADD A,(HL)
  LD (HL),$00
  POP HL
  RET
  
; This entry point is used by the routine at __FOR.
_LOAD:
  SCF			; Carry flag set for autorun
  ;LD DE,CALLHL7
  LD DE,$AFF6
  ;; _LOAD+2:  OR $AF	-> __LOAD
  ;; _LOAD+3:  XOR A	-> __MERGE
  PUSH AF
  CALL FILE_PARMS
  JP Z,MERGE_SUB
  LD A,D
  CP $F9
  JP Z,MERGE_SUB
  CP $FD
  JP Z,__CLOAD_0
  RST $38
  DEFB $1C		; HMERG, Offset: 28
  
; This entry point is used by the routine at GETWORD.
__MERGE_0:
  POP AF
  PUSH AF
  JP Z,_LOAD_0
  LD A,(HL)
  SUB ','
  OR A
  JP NZ,_LOAD_0
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB 'R'
  POP AF
  SCF
; This entry point is used by the routine at GET_DEVICE.
__MERGE_1:
  PUSH AF
_LOAD_0:
  PUSH AF
  XOR A
  LD E,$01
  CALL _OPEN
  
; This entry point is used by the routine at GETWORD.
__MERGE_3:
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
  LD (FILFLG),A
  LD A,(HL)
  OR A
  JP M,__SAVE_3
  
  POP AF
  CALL NZ,CLRPTR
  CALL CLSALL		; Close all files
  XOR A
  CALL SETFIL
  JP PROMPT
  
__SAVE:
  CALL FILE_PARMS
  JP Z,__LCOPY_6
  LD A,D
  CP $F9
  JP Z,__LCOPY_6
  CP $FD
  JP Z,GETWORD_227
  RST $38
  JR $4FB3
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  LD E,$80
  SCF
  JP Z,SCPTLP_78
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB 'A'
  OR A
  LD E,$02
SCPTLP_78:
  PUSH AF
  LD A,D
  CP $09
  JP C,__SAVE_1
  LD A,E
  AND $80
  JP Z,__SAVE_1
  LD E,$02
  POP AF
  XOR A
  PUSH AF
; This entry point is used by the routine at GETWORD.
__SAVE_1:
  XOR A
  CALL _OPEN
  POP AF
  JP C,__SAVE_2
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JP __LIST
__SAVE_2:
  RST $38
  INC H
  JP NMERR
  
__SAVE_3:
  RST $38
  DEFB $26		; Offset: 38
  JP NMERR


; This entry point is used by the routines at __KILL, _CLREG, __END, __MERGE
; and __MAX.
; Close all files
CLSALL:
  LD A,(NLONLY)
  OR A
  RET M

; Routine at 20007
CLOSE_FN:
  XOR A
  
__CLOSE:
  LD A,(MAXFIL)
  JP NZ,__CLOSE_1
  PUSH HL
SCPTLP_82:
  PUSH AF
  CALL CLOSE1
  POP AF
  DEC A
  JP P,SCPTLP_82
  POP HL
  RET
  
__CLOSE_1:
  LD A,(HL)
  CP '#'
  CALL Z,_CHRGTB
  CALL GETINT
  PUSH HL
  CALL CLOSE1
  POP HL
  LD A,(HL)
SCPTLP_84:
  CP ','
  RET NZ
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  JP __CLOSE_1
  
OUTC_FOUT:
  POP HL
  POP AF
  PUSH HL
  PUSH DE
  PUSH BC
  PUSH AF
  LD HL,(PTRFIL)
  LD A,$04
  CALL __CLOSE_3
  RST $38
  LD ($E4C3),HL
  LD D,C
  
__CLOSE_3:
  PUSH AF
  PUSH DE
  EX DE,HL
  LD HL,$0004
  ADD HL,DE
  LD A,(HL)
  EX DE,HL
  POP DE
  CP $09
  JP C,INIT_PRINT_h_1
  POP AF
  EX (SP),HL
  POP HL
  JP GET_DEVICE

; This entry point is used by the routines at GETWORD and ISFLIO.
RDBYT:
  PUSH BC
  PUSH HL
  PUSH DE
  LD HL,(PTRFIL)
  LD A,$06
  CALL __CLOSE_3
  RST $38
  DEFB $0A		; Offset: 10
  JP NMERR

; Routine at 20517
;
; Used by the routines at L1A3C and RAM_IO.
RDBYT_0:
  POP DE
  POP HL
  POP BC
  RET
  
; This entry point is used by the routine at OPRND.
SCPTLP_88:
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  INC H
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  JR Z,$5014
  LD HL,(PTRFIL)
  PUSH HL
  LD HL,$0000
  LD (PTRFIL),HL			; Redirect I/O
  POP HL
  EX (SP),HL
  CALL GETINT
  PUSH DE
  LD A,(HL)
  CP ','
  JP NZ,SCPTLP_89
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  CALL SCPTLP_64
  CP $01
  JP NZ,$51F9
  POP HL
  XOR A
  LD A,(HL)
SCPTLP_89:
  PUSH AF
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  ADD HL,HL
  POP AF
  EX (SP),HL
  PUSH AF
  LD A,L
  OR A
  JP Z,FCERR
  PUSH HL
  CALL MKTMST
  EX DE,HL
  POP BC
SCPTLP_90:
  POP AF
  PUSH AF
  JP Z,SCPTLP_93
  CALL CHGET
  CP $03
  JP Z,SCPTLP_92
SCPTLP_91:
  LD (HL),A
  INC HL
  DEC C
  JP NZ,SCPTLP_90
  POP AF
  POP BC
  POP HL
  RST $38
  LD (DE),A
  LD (PTRFIL),HL			; Redirect I/O
  PUSH BC
  JP TSTOPL
SCPTLP_92:
  POP AF
  LD HL,(CURLIN)
  LD (ERRLIN),HL
  POP HL
  JP WORDS_1
SCPTLP_93:
  CALL RDBYT
  JP C,$51F9
  JP SCPTLP_91
SCPTLP_94:
  CALL SCPTLP_98
  PUSH HL
  LD B,$00
  CALL ZERO_MEM
SCPTLP_95:
  POP HL
  RET
; This entry point is used by the routine at GET_DEVICE.
ZERO_MEM:
  XOR A
SCPTLP_97:
  LD (HL),A
  INC HL
  DEC B
  JP NZ,SCPTLP_97
  RET
SCPTLP_98:
  LD HL,(PTRFIL)
  LD DE,$0009
  ADD HL,DE
  RET
INIT_PRINT_h_1:
  POP AF
  RET
; This entry point is used by the routine at SNERR.
INIT_PRINT_h_2:
  CALL ISFLIO
  JP Z,EXEC
  XOR A
  CALL CLOSE1
  JP $51EA
; This entry point is used by the routine at __DATA.
SCPTLP_101:
  LD C,$01
; This entry point is used by the routine at __DATA.
SCPTLP_102:
  CP '#'
  RET NZ
  PUSH BC
  CALL FNDNUM
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  DEFB ','
  LD A,E
  PUSH HL
  CALL SETFIL
  LD A,(HL)
  POP HL
  POP BC
  CP C
  JP Z,SCPTLP_103
  JP BNERR

SCPTLP_103:
  LD A,(HL)
  RET

; This entry point is used by the routines at SNERR, GETWORD, ISFLIO and
; GET_DEVICE.
SCPTLP_104:
  LD BC,$4066
  PUSH BC
  XOR A
  JP CLOSE1

; This entry point is used by the routine at __DATA.
SCPTLP_105:
  RST GETYPR 		; Get the number type (FAC)
  LD BC,$1012
  LD DE,$2C20
  JP NZ,SCPTLP_107
  LD E,D
  JP SCPTLP_107

; This entry point is used by the routine at __DATA.
SCPTLP_106:
  LD BC,FINPRT
  PUSH BC
  CALL SCPTLP_101
  CALL GETVAR
  CALL TSTSTR
  PUSH DE
  LD BC,$0CB0
  XOR A
  LD D,A
  LD E,A
SCPTLP_107:
  PUSH AF
  PUSH BC
  PUSH HL
SCPTLP_108:
  CALL RDBYT
  JP C,$51F9
  CP ' '
  JP NZ,SCPTLP_109
  INC D
  DEC D
  JP NZ,SCPTLP_108
SCPTLP_109:
  CP '"'
  JP NZ,SCPTLP_110
  LD A,E
  CP ','
  LD A,$22
  JP NZ,SCPTLP_110
  LD D,A
  LD E,A
  CALL RDBYT
  JP C,SCPTLP_115
SCPTLP_110:
  LD HL,INPBFR
  LD B,$FF
SCPTLP_111:
  LD C,A
  LD A,D
  CP '"'
  LD A,C
  JP Z,SCPTLP_113
  CP $0D
  PUSH HL
  JP Z,SCPTLP_117
  POP HL
  CP $0A
  JP NZ,SCPTLP_113
SCPTLP_112:
  LD C,A
  LD A,E
  CP ','
  LD A,C
  CALL NZ,USING2
  CALL RDBYT
  JP C,SCPTLP_115
  CP $0A
  JP Z,SCPTLP_112
  CP $0D
  JP NZ,SCPTLP_113
  LD A,E
  CP ' '
  JP Z,SCPTLP_114
  CP ','
  LD A,$0D
  JP Z,SCPTLP_114
SCPTLP_113:
  OR A
  JP Z,SCPTLP_114
  CP D
  JP Z,SCPTLP_115
  CP E
  JP Z,SCPTLP_115
  CALL USING2
SCPTLP_114:
  CALL RDBYT
  JP NC,SCPTLP_111
SCPTLP_115:
  PUSH HL
  CP '"'
  JP Z,SCPTLP_116
  CP ' '
  JP NZ,SCPTLP_119
SCPTLP_116:
  CALL RDBYT
  JP C,SCPTLP_119
  CP ' '
  JP Z,SCPTLP_116
  CP ','
  JP Z,SCPTLP_119
  CP $0D
  JP NZ,SCPTLP_118
SCPTLP_117:
  CALL RDBYT
  JP C,SCPTLP_119
  CP $0A
  JP Z,SCPTLP_119
SCPTLP_118:
  LD HL,(PTRFIL)
  LD C,A
  LD A,$08
  CALL __CLOSE_3
  RST $38
  INC D
  JP NMERR
; This entry point is used by the routine at GETWORD.
SCPTLP_119:
  POP HL
USING0:
  LD (HL),$00
  LD HL,BUFMIN
  LD A,E
  SUB $20
  JP Z,USING1
  LD B,$00
  CALL QTSTR_0
  POP HL
  RET
USING1:
  RST GETYPR 		; Get the number type (FAC)
  PUSH AF
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  POP AF
  PUSH AF
  CALL C,DBL_ASCTFP
  POP AF
  CALL NC,DBL_DBL_ASCTFP
  POP HL
  RET
USING2:
  OR A
  RET Z
  LD (HL),A
  INC HL
  DEC B
  RET NZ
  POP AF
  JP USING0
; This entry point is used by the routine at GETWORD.
NMERR:
  LD E,$37
  LD BC,$351E
  LD BC,$381E
  LD BC,$341E
  LD BC,$3A1E
  LD BC,$331E
  LD BC,FP_ARG2HL
USING4:
  LD BC,$361E
  LD BC,_DBL_ASCTFP_37
  JP ERROR
  
; Routine at 20993
__LOF:
  RST $38
  LD (HL),H

; Routine at 20995
__LOC:
  RST $38
  HALT

__LFILES:
  RST $38
  LD A,B

__DSKO_S:
  RST $38
  LD A,H

; This entry point is used by the routine at OPRND.
USING5:
  RST $38
  LD A,D

__DSKF:
  RST $38
  ADC A,(HL)


; Routine at 21005
L520D:
  RST $38
  SUB B

__FORMAT:
  RST $38
  SUB D
USING6:
  RST $38
  LD HL,($FE7E)
  LD A,(FCOMP_14)
  LD D,D
  PUSH HL
  LD D,E
  CALL SCPTLP_61
  JP Z,USING8
USING7:
  CP $3A
  JP Z,$5237
  CALL SCPTLP_61
  JP P,USING7
USING8:
  LD E,D
  POP HL
  XOR A
  RST $38
  INC L
  RET
  RST $38
  JR NC,USING4
  CALL PO,GET_DEVICE_608
  SUB E
  DEC A
  CP $02
  JP NC,$5244
  RST $38
  LD L,$C3
  CALL PO,PTRFIL_1
  DEC B
  JP NC,NMERR			; NM error: bad file name
  POP BC
  PUSH DE
  PUSH BC
  LD C,A
  LD B,A
  LD DE,$528D
  EX (SP),HL
  PUSH HL
USING9:
  CALL UCASE_HL
  PUSH BC
  LD B,A
  LD A,(DE)
  INC HL
  INC DE
  CP B
  POP BC
  JP NZ,USING_02
  DEC C
  JP NZ,USING9
USING_00:
  LD A,(DE)
  OR A
  JP M,USING_01
  CP $31
  JP NZ,USING_02
  INC DE
  LD A,(DE)
  JP USING_02
USING_01:
  POP HL
  POP HL
  POP DE
  OR A
  RET
USING_02:
  OR A
  JP M,USING_00
USING_03:
  LD A,(DE)
  OR A
  INC DE
  JP P,USING_03
  LD C,B
  POP HL
  PUSH HL
  LD A,(DE)
  OR A
  JP NZ,USING9
  JP NMERR
  LD C,H
  LD B,E
  LD B,H
  RST $38
  LD B,E
  LD D,D
  LD D,H
  CP $43
  LD B,C
  LD D,E
  DEFB $FD
  LD B,E
  LD C,A
  LD C,L
  CALL M,$4157
  LD C,(HL)
  LD B,H
  EI
  LD C,H
  LD D,B
  LD D,H
  JP M,$4152
  LD C,L
  LD SP,HL
  NOP

; Data block at 21163
;
; Device vector
DEVICE_VECT:
  DEFW L1942
  DEFW CRT_CTL
  DEFW L1AF7
  DEFW L1BDA
  DEFW L1CEC
  DEFW L1BCC
  DEFW RAM_CTL

; Get the device table associated to dev# in A
;
; Used by the routines at GETWORD and SCPTLP.
GET_DEVICE:
  RST $38
  LD ($D5E5),A
  PUSH AF
  LD DE,$0004
  ADD HL,DE
  LD A,$FF
  SUB (HL)
  ADD A,A
  LD E,A
  LD D,$00
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

GET_DEVICE_0:
  RST $38
  LD C,B
  CALL UNLOCK
  LD HL,$5334
  CALL STDSPF
  JP GET_DEVICE_4
GET_DEVICE_1:
  RST $38
  LD D,(HL)
  CALL __BEEP
  LD HL,$5334
  CALL STFNK
GET_DEVICE_2:
  CALL STKINI
  LD HL,GET_DEVICE_1
  LD (ERRTRP),HL
  LD HL,$5318
  CALL PRINT_LINE
  CALL _INLIN
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  AND A
  JP Z,GET_DEVICE_2
  EX DE,HL
  LD HL,($F3C0)
  EX DE,HL
  CALL PARSE_COMMAND
  JP Z,GET_DEVICE_1
  RET

  LD D,H
  LD H,L
  LD L,H
  LD H,E
  LD L,A
  LD L,L
  LD A,(OUTC)
  LD D,E
  LD D,H
  LD B,C
  LD D,H
  LD C,L
  LD D,E
  LD D,H
  LD B,L
  LD D,D
  LD C,L
  ADC A,B
  LD D,E
  LD C,L
  LD B,L
  LD C,(HL)
  LD D,L
  LD B,L
  LD D,(HL)
  RST $38
  NOP
  NOP
  NOP
  LD D,E
  LD (HL),H
  LD H,C
  LD (HL),H
  JR NZ,GET_DEVICE_3
GET_DEVICE_3:
  LD D,H
  LD H,L
  LD (HL),D
  LD L,L
  DEC C
  NOP
  NOP
  NOP
  NOP
  NOP
  LD C,L
  LD H,L
  LD L,(HL)
  LD (HL),L
  DEC C
  NOP
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  AND A
  JP NZ,GET_DEVICE_6
GET_DEVICE_4:
  LD HL,$F406
  LD B,$06
GET_DEVICE_5:
  LD A,(HL)
  RST OUTC
  INC HL
  DEC B
  JP NZ,GET_DEVICE_5
  JP GET_DEVICE_2
GET_DEVICE_6:
  CALL GETWORD_91
  CALL __MENU_02
  JP GET_DEVICE_2
  
  JR NZ,GET_DEVICE_9
  LD (HL),D
  LD H,L
  HALT
  NOP
  NOP
  NOP
  JR NZ,TEL_TERM_0
  LD D,L
  LD (HL),B
  NOP
  JR NZ,$53BE
  LD L,A
  LD (HL),A
  LD L,(HL)
  NOP
  NOP
  NOP
  NOP
  NOP
  JR NZ,$53A4
  LD B,D
  LD A,C
  LD H,L
  NOP
  
  RST $38
  LD C,D

  LD HL,$F406
  CALL GETWORD_91
  LD A,$40
  LD (FNK_FLAG),A
  
TEL_TERM_0:
  LD ($F45C),A
  XOR A
  LD (CAPTUR),A
  LD (CAPTUR+1),A
  CALL CLR_ALTLCD
  LD HL,TERM_BAR		;$536B
  CALL STFNK
  CALL DUPDSP		; Display terminal 'DUPLEX' status
  CALL ECHDSP
  CALL DSPFNK
  CALL CURSON
TEL_TERM_LOOP:
  CALL RESTAK
  LD HL,TEL_TERM_TRAP		;$5427
  LD (ERRTRP),HL
GET_DEVICE_9:
  CALL CHSNS
  JP Z,GET_DEVICE_10
  CALL CHGET
  LD B,A
  JP C,GET_DEVICE_18
  AND A
  CALL NZ,SD232C
  JP C,GET_DEVICE_16
  LD A,(DUPLEX)
  AND A
  LD A,B
  JP Z,GET_DEVICE_11
GET_DEVICE_10:
  CALL RCVX
  JP Z,TEL_TERM_LOOP
  CALL RV232C
GET_DEVICE_11:
  LD B,A
  JP C,TEL_TERM_LOOP
  JP Z,GET_DEVICE_12
  LD A,$82
GET_DEVICE_12:
  CP $7F		; BS
  JP NZ,GET_DEVICE_13
  LD A,(CSRY)
  DEC A
  LD A,B
GET_DEVICE_13:
  CALL NZ,_OUTC
  CALL TEL_TERM_INTRPT
  CALL GET_DEVICE_37
  JP TEL_TERM_LOOP
  
TEL_TERM_INTRPT:
  LD B,A
  LD A,(ECHO)
  AND A
  LD A,B
  RET Z
  LD HL,OUTC_TABEXP
; This entry point is used by the routine at _DBL_ASCTFP.
GET_DEVICE_15:
  PUSH HL
  CP ' '
  RET NC
  CP $1B
  RET Z
  POP HL
  CP $08
  RET C
  CP $0E			; Line number prefix
  RET NC
  JP (HL)
  
GET_DEVICE_16:
  XOR A
  LD (ENDLCD),A
GET_DEVICE_17:
  CALL BREAK
  JP C,GET_DEVICE_17
  JP TEL_TERM_LOOP
  CALL __BEEP
  XOR A
  LD (ECHO),A
  CALL ECHDSP
  JP TEL_TERM_LOOP
GET_DEVICE_18:
  LD E,A
  LD D,$FF
  LD HL,($F3C2)
  ADD HL,DE
  ADD HL,DE
  LD A,(HL)
  INC HL
  LD H,(HL)
  LD L,A
  LD DE,TEL_TERM_LOOP
  PUSH DE
  JP (HL)
  LD E,C
  LD D,H
  LD (HL),H
  LD D,H
  ADD A,(HL)
  LD D,H
  PUSH BC
  LD D,H
  LD D,B
  LD D,L
  OR H
  LD D,E
  OR H
GET_DEVICE_19:
  LD D,E
  OR H
  LD D,E
  OR H
  LD D,E
  RET P
  LD D,L
  CALL TTY_VECT_JP_0_1
  CALL CURSOFF
GET_DEVICE_20:
  CALL DELLIN2
GET_DEVICE_21:
  CALL CHSNS
  JP Z,GET_DEVICE_21
  CALL CHGET
  CALL CURSOFF9
  CALL CURSON
  JP _ESC_X
  LD HL,DUPLEX
  LD A,(HL)
  CPL
  LD (HL),A

; Routine at 21828
;
; Used by the routine at TEL_TERM.
; Display terminal 'DUPLEX' status
DUPDSP:
  LD A,(DUPLEX)
  LD DE,$F6B5
  LD HL,FULLHALF_MSG	;$54AD
  JP CHGDSP


; TELCOM ECHO function routine
TEL_ECHO:
  LD HL,ECHO
  LD A,(HL)
  CPL
  LD (HL),A
;
; Used by the routine at TEL_TERM.
; Display terminal 'ECHO' status
ECHDSP:
  LD A,(ECHO)
  LD DE,$F6C5
  LD HL,$54B5

CHGDSP:
  AND A
  LD BC,$0004
  JP NZ,CHGDSP_0
  ADD HL,BC
  
CHGDSP_0:
  LD B,C
  CALL LDIR_B
  LD B,$0C
  XOR A
CHGDSP_1:
  LD (DE),A
  INC DE
  DEC B
  JP NZ,CHGDSP_1
  JP FNKSB

; Message at 21677 
FULLHALF_MSG:
  DEFM "FullHalf"

ECHO_MSG:
  DEFM "Echo    "
 
CR_WAIT_MSG:
  DEFB $0D
  DEFM " "

WAIT_MSG:
  DEFM "Wait "
  DEFB $00

; TELCOM UP function routine
TEL_UPLD:
  LD HL,UPLOAD_ABORT		;$55C1
  LD (ERRTRP),HL
  PUSH HL
  LD A,(CAPTUR)
  AND A
  RET NZ
  CALL RESFPT_0
  LD HL,UPLMSG_0		;$560A
  CALL PRINT_LINE
  CALL QINLIN			; User interaction with question mark, HL = resulting text 
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  AND A
  RET Z
  LD (FNAME_END),A
  CALL COUNT_CHARS
  CALL FNAME
  RET NZ
  CALL FINDCO_0
  LD HL,FNTFND		; "No file" (file not found)  ..$5635
  JP Z,PRINT_LINE
  EX DE,HL
  EX (SP),HL
  LD A,$01
  LD (CAPTUR+1),A
  CALL FNKSB
  POP HL
  
TEL_UPLD_1:
  LD A,(HL)
  CP $1A		; EOF
  RST $38
  LD E,D		; HC_UPLD
  
  JP Z,TEL_UPLD_STOP
  CP $0A
  JP NZ,TEL_UPLD_4
  LD A,(RS232LF)
  AND A
  JP NZ,TEL_UPLD_4
  LD A,(FNAME_END)
  CP $0D
TEL_UPLD_4:
  LD A,(HL)
  LD (FNAME_END),A
  JP Z,TEL_UPLD_5
  CALL SD232C
  CALL TEL_UPLD_7
TEL_UPLD_5:
  INC HL
  CALL CHSNS
  JP Z,TEL_UPLD_1
  CALL CHGET
  CP $03		; CTL_C ?
  JP Z,TEL_UPLD_STOP
  CP $13		; PAUSE ?
  CALL Z,CHGET
  CP $03		; CTL_C ?
  JP NZ,TEL_UPLD_1
TEL_UPLD_STOP:
  XOR A
  LD (CAPTUR+1),A
  JP FNKSB
  
TEL_UPLD_7:
  CALL RCVX
  RET Z
  CALL RV232C
  RET C
  RST OUTC
  JP TEL_UPLD_7

; TELCOM DOWN function routine
TEL_DOWNLD:
  CALL RESFPT_0
  LD A,(CAPTUR)
  XOR $FF
  LD (CAPTUR),A
  JP Z,DWNLDR_2
  LD HL,DOWNLOAD_ABORT

DWNLDR:
  LD (ERRTRP),HL
  PUSH HL
  LD HL,DWNFMSG		; "File to Download"   ..$5619
  CALL PRINT_LINE
  CALL QINLIN			; User interaction with question mark, HL = resulting text 
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  AND A
  RET Z
  LD (FNAME_END),A
  POP AF
DWNLDR_0:
  PUSH HL
  CALL OPENDO
  JP C,DWNLDR_1
  LD (SV_TXTPOS),HL
  CALL GETEND
  POP AF
  CALL TXT_CTL_C_15
  JP FNKSB
  
DWNLDR_1:
  EX DE,HL
  CALL KILLASC+1
  POP HL
  JP DWNLDR_0
  
DWNLDR_2:
  CALL FNKSB
  JP TXT_WIPE_END
  
GET_DEVICE_37:
  LD C,A
  LD A,(CAPTUR)
  AND A
  LD A,C
  RET Z
  CALL DWNLDR_6
  RET Z
  JP NC,DWNLDR_4
  CALL DWNLDR_4
  LD A,$0A		; 10
DWNLDR_4:
  LD HL,(SV_TXTPOS)
  CALL TXT_SPLIT_ROW
  LD (SV_TXTPOS),HL
  RET NC		; RET if at the end of text

DOWNLOAD_ABORT:
  XOR A
  LD (CAPTUR),A
  CALL FNKSB
  LD HL,DWNMSG		;$5621
  JP PRS_ABORTMSG
  
UPLOAD_ABORT:
  LD HL,UPLMSG		;$5612

PRS_ABORTMSG:
  CALL PRINT_LINE
  LD HL,ABTMSG		;$562A
  CALL PRS
  JP TEL_TERM_LOOP
  
; This entry point is used by the routine at GETWORD.
DWNLDR_6:
  LD C,A
  AND A
  RET Z
  CP $1A		; EOF
  RET Z
  CP $7F		; BS
  RET Z
  CP $0A
  JP NZ,GET_DEVICE_41
  LD A,(FNAME_END)
  CP $0D
GET_DEVICE_41:
  LD A,C
  LD (FNAME_END),A
  RET Z
  CP $0D
  SCF
  CCF
  RET NZ
  AND A
  SCF
  RET
  CALL CONSOLE_CRLF
  RST $38
  LD C,H
  XOR A
  LD (FNK_FLAG),A
  LD L,A
  LD H,A
  LD (CAPTUR),HL
  CALL __MENU_02
  CALL CURSOFF
  CALL MCLEAR_0
  JP GET_DEVICE_0

; Message at 22026
UPLMSG_0:
  DEFM "File to "
UPLMSG:
  DEFM "Upload"
  DEFB $00
  
DWNFMSG:
  DEFM "File to "
DWNMSG:
  DEFM "Download"
  DEFB $00

ABTMSG:
  DEFM " aborted"
  DEFB $0D
  DEFB $0A
  DEFB $00

FNTFND:
  DEFM "No file"
  DEFB $0D
  DEFB $0A
  DEFB $00
  


; This entry point is used by the routine at GETWORD.
PRINT_LINE:
  CALL CONSOLE_CRLF
  JP PRS

; This entry point is used by the routine at GETWORD.
__MENU:
  SUB A
  LD (PRTFLG),A
  CALL _CLVAR
  CALL __MENU_02
  CALL MCLEAR_0
  CALL RESFPT
  CALL TEL_UPLD_18
  LD A,' '
  LD (FNK_FLAG),A
  LD A,$FF
  LD (MENU_FLG),A
  LD A,($F3E4)
  LD ($F59C),A
  SUB A
  LD (ESCCNT),A
  LD ($F590),A
  CALL __SCREEN_SUB
  CALL EXTREV
  CALL CURSOFF
  CALL LOCK
__MENU_0:
  CALL STKINI
  SUB A
  LD ($F9BB),A
  CALL ERAFNK
  LD HL,__MENU_0
  LD (ERRTRP),HL
  CALL _PRINT_TDATE
  LD HL,IOOPRND_0
  CALL POSIT
  LD HL,COPYRIGHT_MSG	;$7FAF
  CALL PRINT_TEXT
  LD A,$23
  RST OUTC
  IN A,($A0)
__MENU_1:
  AND $0C
  RRCA
  RRCA
  CP $01
  ADC A,$30
  RST OUTC
  LD HL,$F543
  LD ($F579),HL
  LD B,$36
  
__MENU_2:
  LD (HL),$FF
  INC HL
  DEC B
  JP NZ,__MENU_2
  LD L,B
  LD DE,$5E61
  LD A,$B0
__MENU_3:
  LD C,A
  PUSH DE
  CALL __MENU_21
  POP DE
  LD A,(DE)
  INC DE
  OR A
  JP NZ,__MENU_3
  LD A,L
  LD ($F591),A
__MENU_4:
  CP $18	; TEXT down arrow
  JP Z,__MENU_5
  CALL GET_DEVICE_135
  PUSH HL
  LD HL,NOFILE_MRK
  CALL PRINT_TEXT
  POP HL
  INC L
  LD A,L
  JP __MENU_4

__MENU_5:
  LD A,($F590)
  LD L,A
  CALL __MENU_10
  CALL CLRFLK
  LD HL,$2208	; cursor coordinates
  CALL POSIT
  CALL FREEMEM
  LD HL,FBUFFR+1
  LD DE,$F6E5
  LD B,$01
  CALL STFNK_0
__MENU_6:
  SUB A
  LD ($F9BB),A
  CALL SCPTLP_104
  CALL PRINT_TDATE
  CALL DSPFNK
  LD HL,FSTFLG
  SUB A
  CP (HL)
  JP Z,__MENU_8
  LD (HL),A
  LD HL,DIRECTORY
  LD B,$1B
__MENU_7:
  LD A,(HL)
  INC A
  JP Z,__MENU_8
  DEC A
  CP $C4
  JP Z,GET_DEVICE_59
  CALL GET_DEVICE_189
  JP NZ,__MENU_7
__MENU_8:
  OR $97
  CALL Z,__BEEP
  CALL STKINI
  LD HL,$572D
  LD (ERRTRP),HL
  CALL TEXT
  JP C,GET_DEVICE_69
  CP $0D
  JP Z,__MENU_18
  LD BC,$573A
  PUSH BC
  CP ' '
  JP C,__MENU_9
  RET NZ
  LD A,$1C
__MENU_9:
  LD HL,($F590)
  LD E,L
  SUB $1C
  RET M
  LD BC,$576E
  PUSH BC
  JP Z,GET_DEVICE_58
  DEC A
  JP Z,GET_DEVICE_57
  DEC A
  POP BC
  JP Z,GET_DEVICE_56
  LD A,E
  ADD A,$04
  LD D,A
  CP H
  RET P
  LD ($F590),A
  LD L,E
  PUSH DE
  CALL __MENU_10
  POP DE
  LD L,D

__MENU_10:
  CALL $7426
  CALL GET_DEVICE_135
  LD B,$0A
  PUSH HL
  LD HL,CSRY
  DEC (HL)
__MENU_11:
  PUSH BC
  PUSH DE
  LD HL,(CSRX)
  CALL ESC_J_9
  EX DE,HL
  CALL MOVE_CURSOR
  DI
  CALL PUT_SHAPE
  EI
  POP DE
  LD HL,CSRY
  INC (HL)
  POP BC
  DEC B
  JP NZ,__MENU_11
  CALL $7426
  POP HL
  RET

GET_DEVICE_56:
  LD A,E
  SUB $04
  LD D,A
  RET M
  PUSH BC
  RET
  
GET_DEVICE_57:
  LD A,E
  DEC A
  LD D,A
  RET P
  LD D,H
  DEC D
  LD A,D
  RET
  
GET_DEVICE_58:
  LD A,E
  INC A
  LD D,A
  CP H
  RET M
  SUB A
  LD D,A
  RET
  
GET_DEVICE_59:
  CALL GET_DEVICE_160
  EX DE,HL
  LD HL,IPLBBUF
  PUSH HL
  LD B,$40
  CALL GET_DEVICE_65
  LD (HL),$00
  INC HL
  LD (HL),$00
  POP DE
  LD HL,$F57B
  LD BC,$0A00
GET_DEVICE_60:
  LD A,(DE)
  CP '.'
  JP NZ,GET_DEVICE_61
  LD C,$7F
GET_DEVICE_61:
  INC C
  CALL M,UCASE
  OR A
  JP Z,GET_DEVICE_63
  CP $0D
  JP Z,GET_DEVICE_62
  LD (HL),A
  INC DE
  INC HL
  DEC B
  JP NZ,GET_DEVICE_60
  JP $572D

GET_DEVICE_62:
  INC DE
GET_DEVICE_63:
  LD (HL),$00
  PUSH DE
  CALL CHKF_0
  JP Z,$572D
  PUSH HL
  CALL CHSNS
  JP Z,GET_DEVICE_64
  CALL CHGET
  CP $03
  JP Z,$572D
GET_DEVICE_64:
  POP DE
  POP HL
  LD (FNKPNT),HL
  EX DE,HL
  JP __MENU_19

GET_DEVICE_65:
  LD A,(DE)
  CP $1A		; EOF
  RET Z
  LD (HL),A
  INC HL
  INC DE
  DEC B
  RET Z
  JP GET_DEVICE_65

__MENU_18:
  CALL GET_DEVICE_158
__MENU_19:
  PUSH HL
  CALL ERAFNK
  CALL __CLS
  CALL UNLOCK
  LD A,($F59C)
  CALL __SCREEN_SUB
  CALL RSTSYS
  LD A,$0C
  RST OUTC
  CALL UNLOCK
  CALL EXTREV
  CALL HOME2
  SUB A
  LD (MENU_FLG),A
  LD (FNK_FLAG),A
  LD L,A
  LD H,A
  LD (ERRTRP),HL
  POP HL
  LD A,(HL)
  AND $F0
  CALL GET_DEVICE_160
  CP $A0
  JP Z,LDIR_B_0
  CP $B0
  JP Z,CALLHL
  CP $F0
  JP Z,TEL_TERM_002
  CP $C0
  JP Z,EDIT_TEXT
  CP $80
  JP NZ,__MENU_0
  LD (BASTXT),HL
  DEC DE
  DEC DE
  EX DE,HL
  LD (DIRPNT),HL
  CALL UPD_PTRS
  CALL LOAD_BA_LBL
  CALL DSPFNK
  CALL RUN_FST
  JP EXEC_EVAL_0

CALLHL:
  JP (HL)

GET_DEVICE_69:
  LD HL,TEL_TERM_00
  LD (ERRTRP),HL
  PUSH AF
  LD A,$FF
  LD ($F9BB),A
  CALL ERAFNK
  POP AF
  SUB $F7
  JP C,TEL_TERM_LOOP0
  CP $08
  JP Z,$7EAB
  CP $05
  JP Z,GET_DEVICE_93
  OR A
  PUSH AF
  CALL GET_DEVICE_158
  PUSH HL
  CALL GET_DEVICE_160
  EX DE,HL
  POP HL
  LD A,(HL)
  LD C,A
  POP AF
  PUSH AF
  CP $01
  LD A,C
  JP Z,GET_DEVICE_107
  AND $10
  JP NZ,TEL_TERM_00
  LD A,(HL)
  AND $60
  RLCA
  RLCA
  RLCA
  LD C,A
  POP AF
  PUSH HL
  PUSH DE
  PUSH BC
  PUSH HL
  JP Z,TEL_TERM_01
  DEC A
  DEC A
  JP Z,TXT_ASK_WIDTH
  DEC A
  DEC A
  JP Z,GET_DEVICE_93
  CP $03
  JP Z,GET_DEVICE_105
TEL_TERM_00:
  CALL SCPTLP_104
  CALL __BEEP
  CALL RESTAK
  JP __MENU_6

TEL_TERM_01:
  CALL GET_DEVICE_92
  POP HL
  PUSH HL
  CALL GET_DEVICE_122
  LD HL,$5EDB
  CALL PRINT_TEXT
  LD A,$0D
  CALL GET_DEVICE_111
  POP DE
  LD A,($F58F)
  OR A
  JP Z,TEL_TERM_02
  DEC HL
  LD A,(HL)
  INC HL
  CP $3A
  JP NZ,TEL_TERM_03
  DEC HL
  DEC HL
  LD A,(HL)
  INC HL
  INC HL
  CALL UCASE
  CP $4D
  JP Z,TEL_TERM_03
TEL_TERM_02:
  INC DE
  INC DE
  INC DE
  CALL MOVE_6_BYTES
TEL_TERM_03:
  LD (HL),$00
  POP BC
  DEC C
  JP M,TEL_TERM_05
  JP NZ,$593A
  CALL GET_DEVICE_124
  POP HL
  PUSH DE
  CALL CLOADM_7
  POP DE
  RST $38
  LD A,($60C3)
  LD H,$CD
  PUSH HL
  LD E,H
  POP HL
TEL_TERM_04:
  LD A,(HL)
  RST OUTC
  INC HL
  CP $1A		; EOF
  JP NZ,TEL_TERM_04
  JP __MENU_6
  
TEL_TERM_05:
  CALL TEL_TERM_LOOP9
  LD A,D
  CP $FC
  JP Z,TEL_TERM_06
  LD HL,$5EB2
  CALL GET_DEVICE_121
  CALL SHOW_TIME
  CALL CHGET_UCASE
  CP $0D
  JP Z,TEL_TERM_09
  CP $42
  JP Z,TEL_TERM_08
  CP $41
  JP NZ,__MENU_6
  RST OUTC
TEL_TERM_06:
  CALL GET_DEVICE_126
TEL_TERM_07:
  POP HL
  LD (BASTXT),HL
  SUB A
  JP __LIST
TEL_TERM_08:
  RST OUTC
TEL_TERM_09:
  CALL GET_DEVICE_124
  POP HL
  LD (BASTXT),HL
  RST $38
  JR C,$5947
  PUSH HL
  DEC H
TEL_TERM_LOOP0:
  LD HL,__MENU
  LD (ERRTRP),HL
  LD HL,$5E79
  CALL GET_DEVICE_121
  LD HL,$5ED2
  CALL PRINT_TEXT
  LD HL,$F57B
  LD DE,GET_DEVICE_164
  PUSH DE
  PUSH DE
  CALL TEL_TERM_INTRPT3
  LD (HL),$00
  POP DE
  LD HL,FILNAM
  CALL TEL_TERM_INTRPT2
  LD HL,$F99B
  POP DE
  CALL TEL_TERM_INTRPT2
  LD A,$0D
  CALL GET_DEVICE_111
  LD A,($F58F)
  LD D,$FD
  OR A
  JP Z,TEL_TERM_LOOP5
  LD B,$0D
  LD DE,$F57B
TEL_TERM_LOOP1:
  LD A,(DE)
  INC DE
  CP $3A
  JP Z,TEL_TERM_LOOP2
  DEC B
  JP NZ,TEL_TERM_LOOP1
  LD DE,$F57B
  JP TEL_TERM_LOOP3
TEL_TERM_LOOP2:
  LD A,(DE)
  OR A
  JP Z,TEL_TERM_LOOP4
TEL_TERM_LOOP3:
  LD HL,FILNAM
  CALL TEL_TERM_INTRPT4
TEL_TERM_LOOP4:
  CALL TEL_TERM_LOOP9
TEL_TERM_LOOP5:
  PUSH DE
  CALL GET_DEVICE_92
  LD HL,$5EDC
  CALL PRINT_TEXT
  LD A,$09
  CALL GET_DEVICE_111
  LD A,($F58F)
  CP $03
  JP C,TEL_TERM_00
  DEC HL
  CALL UCASE_HL
  LD (HL),A
  LD ($F9A2),A
  DEC HL
  CALL UCASE_HL
  LD (HL),A
  LD ($F9A1),A
  DEC HL
  LD DE,$5E66
  LD A,(HL)
  CP '.'
  JP NZ,TEL_TERM_00
  CALL PARSE_COMMAND
  JP Z,TEL_TERM_00
  POP AF
  POP DE
  PUSH AF
  CP $C0
  JP Z,TEL_TERM_LOOP6
  CALL GET_DEVICE_90
  JP Z,TEL_TERM_00
TEL_TERM_LOOP6:
  CALL GET_DEVICE_91
  JP Z,TEL_TERM_00
  PUSH DE
  CALL CHKF_0
  JP Z,TEL_TERM_LOOP7
  PUSH HL
  CALL GET_DEVICE_160
  PUSH HL
  CALL __BEEP
  CALL GET_DEVICE_127
  JP NZ,__MENU_6
  POP DE
  POP HL
  POP BC
  POP AF
  PUSH AF
  PUSH BC
  CP $A0
  CALL GET_DEVICE_106
  JP TEL_TERM_LOOP8
TEL_TERM_LOOP7:
  LD A,($F591)
  CP $18
  JP Z,TEL_TERM_00
  CALL GET_DEVICE_125
TEL_TERM_LOOP8:
  LD HL,$F99B
  LD DE,$F57B
  CALL TEL_TERM_INTRPT4
  SUB A
  LD ($F590),A
  POP DE
  POP AF
  JP GETWORD_212
TEL_TERM_LOOP9:
  LD HL,$F57B
  CALL COUNT_CHARS
  CALL FNAME
  RET NZ
  LD D,$FD
  RET
GET_DEVICE_90:
  LD A,D
  CP $FC
  RET Z
GET_DEVICE_91:
  LD A,D
  CP $F9
  RET Z
  CP $FE
  RET Z
  CP $FF
  RET Z
  CP $FA
  RET Z
  LD HL,$5EA5
  LD A,(HL)
  RET

GET_DEVICE_92:
  LD HL,GET_DEVICE_161
  JP GET_DEVICE_121
GET_DEVICE_93:
  OR A
  PUSH AF
  LD HL,DIRECTORY
  LD B,$1B
GET_DEVICE_94:
  LD A,(HL)
  INC A
  JP Z,GET_DEVICE_95
  DEC A
  AND $FB
  LD (HL),A
  CALL GET_DEVICE_189
  JP NZ,GET_DEVICE_94
GET_DEVICE_95:
  POP AF
  JP NZ,__MENU_0
  DEC C
  DEC C
  JP NZ,TEL_TERM_00
  POP HL
  LD A,(HL)
  OR $04
  LD (HL),A
  JP __MENU_0
  
TXT_ASK_WIDTH:
  POP HL
  POP BC
  DEC C
  JP Z,TEL_TERM_00
  INC C
  PUSH HL
  JP Z,GET_DEVICE_101
  CALL GET_DEVICE_102
  LD HL,WIDTH_MSG         ; $5ef9,  "Width("
  CALL PRINT_TEXT
  LD HL,$F3F6
  CALL PRINT_TEXT
  LD HL,WIDTH_TAIL_MSG    ; "):_"
  CALL PRINT_TEXT
  LD A,$03
  PUSH AF
  CALL $5C13
  LD HL,$F57B
  POP BC
  PUSH HL
GET_DEVICE_97:
  LD A,(HL)
  CP '0'
  JP C,GET_DEVICE_98
  CP '9'+1
  JP NC,GET_DEVICE_98
  INC HL
  DEC B
  JP NZ,GET_DEVICE_97
  
GET_DEVICE_98:
  LD (HL),$00
  POP HL
  LD A,(HL)
  OR A
  CALL Z,GET_DEVICE_104
  
  CALL GETINT
  CP $0A		; 10
  JP C,TEL_TERM_00
  CP $85		; 133
  JP NC,TEL_TERM_00
  
  ; A is in the range of 10..132
  PUSH AF
  LD DE,$F3F6
  LD HL,$F57B
  CALL MOVE_TEXT
  CALL GET_DEVICE_102
  POP AF
  POP HL
  PUSH HL
  PUSH AF
  CALL GET_DEVICE_103
  POP AF
  LD (TXT_WIDTH),A
  LD (TRM_WIDTH),A
  LD (PRTFLG),A
  LD A,$01
  LD (TXT_EDITING),A
  LD ($F4F7),A
  CALL OUTDO_CRLF
  POP HL
  CALL GET_DEVICE_122
  CALL OUTDO_CRLF
  POP DE
  POP HL
GET_DEVICE_99:
  CALL DWNLDR_05
  LD A,D
  AND A
  INC A
  JP NZ,GET_DEVICE_99
; This entry point is used by the routines at MAKINT and GETWORD.
GET_DEVICE_100:
  SUB A
  LD (TXT_EDITING),A
  LD (PRTFLG),A
  LD A,(ACTV_Y)
  LD (TRM_WIDTH),A
  JP __MENU_6
  
GET_DEVICE_101:
  CALL GET_DEVICE_102
  POP HL
  PUSH HL
  CALL GET_DEVICE_103
  CALL INIT_OUTPUT_0
  POP HL
  LD A,$FF
  LD (PRTFLG),A
  CALL GET_DEVICE_122
  CALL INIT_OUTPUT_0
  JP TEL_TERM_07
GET_DEVICE_102:
  LD HL,GET_DEVICE_163
  JP GET_DEVICE_121
GET_DEVICE_103:
  CALL GET_DEVICE_122
  CALL GET_DEVICE_125
  LD HL,GET_DEVICE_100
  LD (ERRTRP),HL
  RET
  
GET_DEVICE_104:
  LD HL,$F3F6
  LD DE,$F57B
  JP MOVE_TEXT
GET_DEVICE_105:
  LD HL,$5EA7
  CALL GET_DEVICE_121
  POP HL
  CALL GET_DEVICE_122
  CALL GET_DEVICE_127
  JP NZ,__MENU_6
  POP BC
  POP DE
  POP HL
  DEC C
  CALL GET_DEVICE_106
  SUB A
  LD ($F590),A
  JP __MENU_0

GET_DEVICE_106:
  JP Z,KILLBIN
  JP M,KILLASC_6
  JP KILLASC+1

GET_DEVICE_107:
  PUSH HL
  PUSH AF
  PUSH HL
  PUSH HL
  LD HL,GET_DEVICE_162
  CALL GET_DEVICE_121
  POP HL
  CALL GET_DEVICE_122
  LD HL,$5EDB
  CALL PRINT_TEXT
  POP HL
  LD DE,$0009
  ADD HL,DE
  PUSH HL
  LD A,$06
  CALL $5C13
  POP DE
  POP AF
  CALL GET_DEVICE_153
  JP NZ,TEL_TERM_00
  LD HL,$F57B
GET_DEVICE_108:
  LD A,(HL)
  OR A
  JP Z,GET_DEVICE_109
  CP $3A
  INC HL
  JP Z,TEL_TERM_00
  JP GET_DEVICE_108
GET_DEVICE_109:
  POP HL
  INC HL
  INC HL
  INC HL
  LD DE,GET_DEVICE_164
  PUSH HL
  CALL MOVE_6_BYTES
  POP HL
  LD DE,$F57B
GET_DEVICE_110:
  LD A,(DE)
  OR A
  JP Z,__MENU_0
  CP '.'
  JP Z,__MENU_0
  LD (HL),A
  INC DE
  INC HL
  JP GET_DEVICE_110
GET_DEVICE_111:
  PUSH AF
  LD A,$FF
  LD DE,$97F5
  LD ($F5A3),A
  POP AF
  LD ($F5A2),A
  SUB A
  LD ($F58F),A
  LD HL,$F57B
GET_DEVICE_112:
  CALL TEXT
  JP C,GET_DEVICE_112
  CP $08
  JP Z,GET_DEVICE_120
  CP $7F		; BS
  JP Z,GET_DEVICE_120
  CP $1D
  JP Z,GET_DEVICE_120
  CP $03
  JP Z,TEL_TERM_00
  CP $0D
  JP Z,GET_DEVICE_114
  CP '.'
  CALL Z,GET_DEVICE_118
  CP ' '
  JP C,GET_DEVICE_112
  LD C,A
  LD A,($F5A2)
  LD E,A
  LD A,($F58F)
  CALL Z,$5C99
  CP E
  JP Z,GET_DEVICE_119
  
; This entry point is used by the routine at __MENU.
SHOW_TIME_0:
  INC A
  LD ($F58F),A
  LD (HL),C
  INC HL
  PUSH HL
  LD A,C
  RST OUTC
  LD HL,UNDERSCORE_PROMPT	;$5EDF
GET_DEVICE_113:
  CALL PRINT_TEXT
  POP HL
  JP GET_DEVICE_112

GET_DEVICE_114:
  PUSH HL
  LD HL,$F57B
  LD A,($F58F)
  OR A
  JP Z,GET_DEVICE_117
  LD E,A
  LD D,$01
GET_DEVICE_115:
  LD A,(HL)
  CP $3A
  JP NZ,GET_DEVICE_116
  DEC D
GET_DEVICE_116:
  DEC E
  INC HL
  JP NZ,GET_DEVICE_115
  LD A,D
  OR A
  JP M,TEL_TERM_00
GET_DEVICE_117:
  POP HL
  LD (HL),$00
  RET
GET_DEVICE_118:
  LD A,($F5A3)
  OR A
  LD A,'.'
  RET NZ
  LD DE,$C0B7
  POP AF
GET_DEVICE_119:
  CALL __BEEP
  JP GET_DEVICE_112
GET_DEVICE_120:
  LD A,($F58F)
  OR A
  JP Z,GET_DEVICE_119
  DEC A
  LD ($F58F),A
  DEC HL
  PUSH HL
  LD HL,$5ECC
  JP GET_DEVICE_113
GET_DEVICE_121:
  PUSH HL
  LD HL,$0108
  CALL POSIT
  JP GET_DEVICE_123
GET_DEVICE_122:
  EX DE,HL
  LD HL,$F57B
  PUSH HL
  CALL DOTTED_FNAME
GET_DEVICE_123:
  POP HL
  JP PRINT_TEXT
GET_DEVICE_124:
  CALL TEL_TERM_LOOP9
  CALL GET_DEVICE_90
  JP Z,TEL_TERM_00
GET_DEVICE_125:
  PUSH DE
  PUSH HL
  LD HL,$5EE4
  CALL GET_DEVICE_128
  POP HL
  POP DE
  RET Z
  CP $0D
  JP NZ,__MENU_6
  RET

GET_DEVICE_126:
  CALL TEL_TERM_LOOP9
  CALL GET_DEVICE_91
  JP Z,TEL_TERM_00
  CALL GET_DEVICE_125
  SUB A
  LD E,$02
  JP _OPEN
  
GET_DEVICE_127:
  LD HL,$5EEF
GET_DEVICE_128:
  CALL PRINT_TEXT
  CALL SHOW_TIME
  CALL CHGET_UCASE
  CP $59
  RET NZ
  RST OUTC
  RET

__MENU_21:
  LD B,$1B
  LD DE,DIRECTORY
__MENU_22:
  LD A,(DE)
  INC A
  RET Z
  DEC A
  AND $FB
  CP C
  JP NZ,__MENU_23
  PUSH BC
  PUSH DE
  PUSH HL
  LD HL,($F579)
  LD (HL),E
  INC HL
  LD (HL),D
  INC HL
  LD ($F579),HL
  POP HL
  CALL GET_DEVICE_135
  PUSH HL
  LD HL,$F57B
  PUSH HL
  CALL DOTTED_FNAME
  POP HL
  CALL PRINT_TEXT
  POP HL
  INC L
  POP DE
  POP BC
__MENU_23:
  CALL GET_DEVICE_190
  JP NZ,__MENU_22
  RET

DOTTED_FNAME:
  LD A,(DE)
  LD B,$2E
  CP $C4
  JP NZ,_DOTTED_FNAME_0
  LD B,$2A
_DOTTED_FNAME_0:
  INC DE
  INC DE
  INC DE
  CALL MOVE_6_BYTES
  LD A,' '
DOTTED_FNAME_0:
  DEC HL
  CP (HL)
  JP Z,DOTTED_FNAME_0
  INC HL
  LD (HL),$00
  LD A,(DE)
  CP ' '
  RET Z
  LD (HL),B
  INC HL
  LD A,$02
  CALL MOVE_MEM
  LD (HL),$00
  RET
  
GET_DEVICE_135:
  PUSH DE
  PUSH HL
  LD A,L
  RRA
  RRA
  AND $3F
  LD E,A
  INC E
  INC E
  LD A,L
  AND $03
  ADD A,A
  LD D,A
  ADD A,A
  ADD A,A
  ADD A,D
  LD D,A
  INC D
  INC D
  EX DE,HL
  CALL POSIT
  POP HL
GET_DEVICE_136:
  POP DE
  RET

; Print time, day, and date on the first line of the screen
;
; Used by the routine at __MENU.
_PRINT_TDATE:
  CALL __CLS

; Same as _PRINT_TDATE but screen is not cleared.
;
; Used by the routine at SHOW_TIME.
PRINT_TDATE:
  LD HL,$0101
  CALL POSIT
  LD HL,$F52A
  PUSH HL
  LD (HL),$31		; '1'
  INC HL
  LD (HL),$39		; '9'	; CENTURY PREFIX (not Y2K compliant!)
  INC HL
  CALL GET_DATE
  LD (HL),' '
  INC HL
  CALL READ_TIME
  LD (HL),$00
  POP HL

; Print the buffer pointed to by HL, null terminated.
;
; Used by the routines at TEL_SET_STAT, TEL_CALL, __MENU, SCHEDL_DE and
; SHOW_TIME.
PRINT_TEXT:
  LD A,(HL)
  OR A
  RET Z
  RST OUTC
  INC HL
  JP PRINT_TEXT

MOVE_6_BYTES:
  LD A,$06

MOVE_MEM:
  PUSH AF
  LD A,(DE)
  LD (HL),A
  INC DE
  INC HL
  POP AF
  DEC A
  JP NZ,MOVE_MEM
  RET

TEL_TERM_INTRPT2:
  CALL TEL_TERM_INTRPT4
  LD (HL),$00
  RET
  
TEL_TERM_INTRPT3:
  CALL TEL_TERM_INTRPT4
  INC DE
TEL_TERM_INTRPT4:
  LD A,(DE)
  OR A
  RET Z
  CP '.'
  RET Z
  LD (HL),A
  INC HL
  INC DE
  JP TEL_TERM_INTRPT4

; Compare the buffer pointed to by DE to the buffer pointed to by HL for C
; bytes or until a null is found
;
; Used by the routine at CHKF.
COMP_MEM:
  LD A,(DE)
  CP (HL)
  RET NZ
  OR A
  RET Z
  INC HL
  INC DE
  DEC C
  JP NZ,COMP_MEM
  RET

; Clear (wipe) function key definition table
;
; Used by the routine at __MENU.
CLRFLK:
  LD HL,EMPTY_FNTAB		;$5E79

; Set new function key table, HL=address of fn table. Up to 16 chars for each
; of the 8 FN keys.
;
; Used by the routines at STDSPF, TELCOM, TEL_TERM, SCHEDL_DE, IS_CRLF, TEXT,
; WAIT_SPC and BOOT.
STFNK:
  LD DE,FNKSTR
  LD B,$0A
STFNK_0:
  LD C,$0F
STFNK_1:
  LD A,(HL)
  INC HL
  OR A
  JP Z,STFNK_2
  LD (DE),A
  INC DE
  DEC C
  JP NZ,STFNK_1
  SUB A
STFNK_2:
  INC C
STFNK_3:
  LD (DE),A
  INC DE
  DEC C
  JP NZ,STFNK_3
  DEC B
  JP NZ,STFNK_0

; This entry point is used by the routine at GETWORD.
FNKSB:
  LD A,(LABEL_LN)
  OR A
  CALL NZ,DSPFNK
  RET

GET_DEVICE_153:
  PUSH AF
  LD (HL),$00
  LD A,($F58F)
  OR A
  JP Z,TEL_TERM_00
  POP AF
  AND $10
  JP NZ,CHKF_0
  LD (HL),$2E
  INC HL
  LD A,(DE)
  LD (HL),A
  INC HL
  INC DE
  LD A,(DE)
  LD (HL),A
  INC HL
  LD (HL),$00
CHKF_0:
  LD B,$1B
  LD DE,DIRECTORY
CHKF_1:
  LD HL,$F592
  LD A,(DE)
  INC A
  RET Z
  AND $80
  JP Z,GET_DEVICE_157
  PUSH DE
  PUSH HL
  CALL DOTTED_FNAME
  POP HL
  LD C,$09
  LD DE,$F57B
  CALL COMP_MEM
  JP NZ,GET_DEVICE_156
  POP HL
  INC C
  RET
GET_DEVICE_156:
  POP DE
GET_DEVICE_157:
  CALL GET_DEVICE_190
  JP NZ,CHKF_1
  RET

GET_DEVICE_158:
  LD A,($F590)
  LD HL,$F541
  LD DE,$0002
  INC A
GET_DEVICE_159:
  ADD HL,DE
  DEC A
  JP NZ,GET_DEVICE_159
  DEC HL
  
GET_DEVICE_160:
  INC HL
  LD E,(HL)
  INC HL
  LD D,(HL)
  EX DE,HL
  RET

  DEFB $F0
  DEFB $C0
  DEFB $80
  DEFB $A0
  DEFB $00
  DEFM ".BA"
  DEFB $00
  DEFB $00
  DEFB $80
  DEFM ".CO"
  DEFB $00
  DEFB $00
  DEFB $A0
  DEFM ".DO"
  DEFB $00
  DEFB $00
  DEFB $C0
  DEFB $FF
  DEFM "Load "
  DEFB $00
  DEFM "Save "
  DEFB $00
  DEFM "Name "
  DEFB $00
  DEFM "List "
  DEFB $00
  DEFM "      "
  DEFB $00
  DEFM "SetIPL"
  DEFB $00
  DEFM "ClrIPL"
  DEFB $00
  DEFB $00
  DEFM "Kill "
  DEFB $00
  DEFM "Bank"
  DEFB $00
  DEFM "B(inary) or A(scii)? _"
  DEFB $1B
  DEFM "K"
  DEFB $08
  DEFB $00
  DEFM " "
  DEFB $08
  DEFB $08
  DEFM "_"
  DEFB $08
  DEFB $00
  DEFM " from _"
  DEFB $08
  DEFB $00
  DEFM " as _"
  DEFB $1B
  DEFM "K"
  DEFB $08
  DEFB $00
  DEFM " Ready? _"
  DEFB $08
  DEFB $00
  DEFM " Sure? _"
  DEFB $08
  DEFB $00

; Message at 24313
WIDTH_MSG:
  DEFM "Width("
  DEFB $00
  
WIDTH_TAIL_MSG:
  DEFM "): _"
  DEFB $08
  DEFB $00
  
  
; Message at 24326 ($5F06)
FNKTAB:
  DEFM "Load \""
  DEFB $00
  DEFM "Save \""
  DEFB $00
  DEFM "Files"
  DEFB $0D
  DEFB $00
  DEFM "List "
  DEFB $00
  DEFM "Run"
  DEFB $0D
  DEFB $00
  DEFM "Edit "
FNKTAB_0:
  DEFB $00
  DEFM "Cont"
  DEFB $0D
  DEFB $00
  DEFM "Print "
FNKTAB_1:
  DEFB $00
  DEFM "List."
FNKTAB_2:
  DEFB $0D
FNKTAB_3:
  DEFB $1E
  DEFB $1E
  DEFB $00
  DEFM "Menu"
  DEFB $0D
  DEFB $00


  
FIND_TEXT:
  PUSH DE
GET_DEVICE_183:
  PUSH HL
  PUSH DE
GET_DEVICE_184:
  LD A,(DE)
GET_DEVICE_185:
  CALL UCASE
  LD C,A
  CALL UCASE_HL
  CP C
  JP NZ,GET_DEVICE_186
  INC DE
  INC HL
  JP GET_DEVICE_184
GET_DEVICE_186:
  CP $00
  LD A,C
  POP BC
  POP HL
  JP Z,GET_DEVICE_187
  CP $1A		; EOF
  JP Z,GET_DEVICE_136
  CALL GET_DEVICE_188
  JP NZ,GET_DEVICE_183
  POP AF
  JP FIND_TEXT

GET_DEVICE_187:
  POP DE
  SCF
  RET

GET_DEVICE_188:
  LD A,(DE)
  CP $0D
  INC DE
  RET NZ
  LD A,(DE)
  CP $0A
  RET NZ
  INC DE
  RET

GET_DEVICE_189:
  LD DE,$000B
  ADD HL,DE
  DEC B
  RET

GET_DEVICE_190:
  PUSH HL
  EX DE,HL
  CALL GET_DEVICE_189
  EX DE,HL
  POP HL
  RET

STKINI:
  LD HL,$FFFF
  LD (CURLIN),HL
  INC HL
  LD (CAPTUR),HL

RESTAK:
  POP BC
  LD HL,(SAVSTK)
  LD SP,HL
  PUSH BC
  RET

CHGET_UCASE:
  CALL CHGET
  JP UCASE

SHOW_TIME:
  PUSH HL
  LD HL,(CSRX)
  PUSH HL
  CALL CHSNS
  PUSH AF
  CALL Z,PRINT_TDATE
  POP AF
  POP HL
  PUSH AF
  CALL POSIT
  POP AF
  POP HL
  JP Z,SHOW_TIME
  RET
  
  CALL SHOW_TIME
  JP CHGET
  
TEXT:
  LD HL,L5FD1
  LD (ERRTRP),HL
  LD HL,TEXT_EMPTYBAR
  CALL STFNK

L5FD1:
  XOR A
  CALL NZ,__BEEP
  CALL STKINI
  LD HL,EDFILE_MSG
  CALL PRS
  CALL QINLIN			; User interaction with question mark, HL = resulting text 
  RST CHRGTB		; Gets next character (or token) from BASIC text.
  AND A
  JP Z,__MENU
  CALL OPENDO
  JP EDIT_TEXT



; Message at 24555
EDFILE_MSG:
  DEFM "File to edit"

; Message at 24567
TEXT_EMPTYBAR:
  DEFB $00
  DEFB $00
  DEFB $00
  DEFB $00
  DEFB $00
  DEFB $00
  DEFB $00
  DEFB $00
  DEFB $00
  DEFB $03
  DEFB $00

; Message at 24578
TEXT_FNBAR:
  DEFM "Find"
  DEFB $0E
  DEFB $00
  DEFM "Next"
  DEFB $0B
  DEFB $00
  DEFM "Sel "
  DEFB $0C
  DEFB $00
  DEFM "Cut "
  DEFB $15
  DEFB $00
  DEFM "Copy"
  DEFB $0F
  DEFB $00
  DEFM "Keys"
  DEFB $10
  DEFB $00
  DEFB $00
  DEFB $00
  DEFB $00
  DEFM "Menu"
  DEFB $1B
  DEFB $1B
  DEFB $00
  
__EDIT:
  PUSH HL
  PUSH AF
  CALL GET_DEVICE_206
  CALL GETPARM_VRFY
  POP AF
  PUSH AF
  LD A,$01
  JP Z,GET_DEVICE_199
  LD A,$FF
GET_DEVICE_199:
  LD (ERRTRP-1),A
  XOR A
  LD ($FB7A),A
  LD HL,$2020		; "  "
  LD (FILNAM+6),HL
  LD HL,EDIT_OPN_TRP		;$60C4
  LD (ERRTRP),HL
  LD DE,$F902		; D = 'RAM' device, E = $02
  LD HL,BLANK_BYTE		; $6115
  CALL _OPEN
  LD HL,EDIT_TRP
  LD (ERRTRP),HL
  CALL GET_DEVICE_207
  POP AF
  POP HL
  PUSH HL
  JP __LIST

; This entry point is used by the routine at MAKINT.
__EDIT_1:
  CALL SCPTLP_104
  CALL __NEW_2
  LD A,(LABEL_LN)
  LD (SV_LABEL_LN),A
  LD HL,$0000
  LD (SAVE_CSRX),HL
  LD ($F503),HL
__EDIT_2:
  CALL RESFPT
  LD HL,($F887)
  LD A,(HL)
  CP $1A		; EOF
  JP Z,__EDIT_4
  PUSH HL
  XOR A
  LD HL,L6095
  JP WAIT_SPC_2

L6095:
  XOR A
  LD HL,$60D5
  LD (ERRTRP),HL
  LD HL,BLANK_BYTE
  LD D,$F9		; 'RAM' device  ($F8 on m100)
  JP __MERGE_1

; This entry point is used by the routine at ISFLIO.
__EDIT_3:
  CALL __CLS
__EDIT_4:
  XOR A
  LD (ERRTRP-1),A
  LD L,A
  LD H,A
  LD (ERRTRP),HL
  CALL KILLASC_4
  CALL _CLREG_1
  LD A,(SV_LABEL_LN)
  LD (LABEL_LN),A		; Label line/8th line protect status (0=off)
  JP BASIC_0

; Trap exit address for errors during EDITing
EDIT_TRP:
  PUSH DE
  CALL KILLASC_4
  POP DE
  
EDIT_OPN_TRP:
  PUSH DE
  XOR A
  LD (ERRTRP-1),A
  LD L,A
  LD H,A
  LD (ERRTRP),HL
  CALL SCPTLP_104
  POP DE
  JP ERROR

  LD A,E
  PUSH AF
  LD HL,(FILTAB+4)
  DEC HL
  LD B,(HL)
  DEC B
  DEC HL
  LD C,(HL)
  DEC HL
  LD L,(HL)
  XOR A
  LD H,A
  ADD HL,BC
  LD BC,$FFFF
  ADD HL,BC
  JP C,__EDIT_5
  LD L,A
  LD H,A
  
__EDIT_5:
  LD (SAVE_CSRX),HL
  CALL SCPTLP_104
  POP AF
  CP $07
  LD HL,ERR_MEMORY		;$627F
  JP Z,GET_DEVICE_205
  LD HL,ILLTXT_MSG		;$6105
GET_DEVICE_205:
  LD ($F503),HL
  JP __EDIT_2

ILLTXT_MSG:
  DEFM "Text ill-formed"
  DEFB $07
  
; This entry point is used by the routine at CHKSTK.
GET_DEVICE_206:
  LD HL,CONTXT
  LD DE,$F99B
  JP GET_DEVICE_208
; This entry point is used by the routine at CHKSTK.
GET_DEVICE_207:
  LD HL,$F99B
  LD DE,CONTXT
GET_DEVICE_208:
  LD B,$0C
  JP LDIR_B

EDIT_TEXT:
  PUSH HL
  LD HL,$0000
  LD (SAVE_CSRX),HL
  LD ($F503),HL
  LD A,$01
  LD HL,__MENU
WAIT_SPC_2:
  LD ($F4F7),A
  LD (TXT_ESCADDR),HL
  CALL EXTREV		; Exit from reverse mode
  CALL ERAFNK
  CALL LOCK
  CALL CURSOFF
  CALL TEL_UPLD_18
  LD HL,TEXT_FNBAR
  CALL STFNK
  LD A,(ERRTRP-1)
  AND A
  JP Z,WAIT_SPC_3
  LD HL,$7845		; H=120, L=69   (same const on PC8201 etc..)
  ;LD ($F735),HL
  LD (FNKSTR+$90),HL
  LD HL,$7469		; H=116, L=105
  ;LD ($F737),HL
  LD (FNKSTR+$92),HL
WAIT_SPC_3:
  LD A,(ACTV_Y)
  LD (TRM_WIDTH),A
  LD A,$80
  LD (FNK_FLAG),A
  XOR A
  LD L,A
GET_DEVICE_212:
  LD H,A
  LD ($F4F9),A
  LD (TXT_EDITING),A
  LD (TXT_ERRFLG),A
  LD (STRG_ASKBUF),A
  LD (TXT_SEL_BEG),HL
  POP HL
  LD (CUR_TXTFILE),HL
  PUSH HL
  CALL GETEND_CURTXT
  CALL TXT_CTL_C_15
  POP DE
  LD HL,(SAVE_CSRX)
  ADD HL,DE
  CALL GET_BT_ROWPOS
  PUSH HL
  CALL TEL_UPLD_75
  POP HL
  CALL TXT_CTL_C_9
  LD HL,($F503)
  LD A,H
  OR L
  JP Z,GET_DEVICE_213
  PUSH HL
  CALL TXT_CTL_N_2
  EX (SP),HL
  CALL TXT_ERROR
  POP HL
  CALL POSIT
GET_DEVICE_213:
  CALL HOME3
GET_DEVICE_214:
  CALL STKINI
  LD HL,GET_DEVICE_214
  LD (ERRTRP),HL
  PUSH HL
  LD A,($F4F9)
  LD ($F4FA),A
  CALL TEL_UPLD6
  LD ($F4F9),A
  PUSH AF
  CALL TEL_UPLD_41
  POP AF
  JP C,TXT_CTL_U_11
  CP $7F			; BS
  JP Z,TXT_CTL_H_0
  CP ' '
  JP NC,GET_DEVICE_215
  LD C,A
  LD B,$00
  LD HL,$61EF
  ADD HL,BC
  ADD HL,BC
  LD C,(HL)
  INC HL
  LD H,(HL)
  LD L,C
  PUSH HL
  LD HL,(CSRX)
  RET
  XOR $61
  LD E,D
  LD H,E
  AND L
  LD H,E
  LD E,L
  LD H,H
  XOR H
  LD H,D
  INC HL
  LD H,E
  LD C,B
  LD H,E
  XOR $61
  EXX
  LD H,D
  LD E,B
  LD H,D
  XOR $61
  LD H,$67
  DJNZ GET_DEVICE_217
  ADC A,H
  LD H,D
  LD (HL),$67
  LD B,$66
  XOR $61
  EXX
  LD H,E
  BIT 4,E
  RRA
  LD H,E
  SUB B
  LD H,E
  LD A,(DE)
  LD H,(HL)
  XOR $61
  SBC A,$63
  OR B
  LD H,D
  XOR $61
  JP PE,BNORM_9
  LD H,D
  XOR H
  LD H,D
  RRA
  LD H,E
  INC HL
  LD H,E
  OR B
  LD H,D
  LD A,($F4FA)
  SUB $1B
  RET NZ
  LD L,A
  LD H,A
  LD (ERRTRP),HL
  RST $38
  LD E,H
  CALL TEL_UPLD_18
  CALL UNLOCK
  CALL HOME2
  CALL ERAFNK
  CALL GO_BOTTOMROW
  CALL POSIT
  CALL OUTDO_CRLF
  CALL TXT_WIPE_END
  LD HL,(TXT_ESCADDR)
  JP (HL)
  
GET_DEVICE_215:
  PUSH AF
  CALL TXT_CTL_C
  CALL DWNLDR_19
  CALL TXT_GET_CURPOS
  POP AF
GET_DEVICE_216:
  CALL TXT_SPLIT_ROW
  JP C,TXT_CTL_I_1
  PUSH HL
  CALL CHGDSP3
GET_DEVICE_217:
  POP HL
  JP DUPDSP5
TXT_CTL_I_1:
  CALL TXT_CTL_N_2
  PUSH HL
  LD HL,ERR_MEMORY
  CALL TXT_ERROR
GET_DEVICE_219:
  POP HL
  JP POSIT

; Message at 25215
ERR_MEMORY:
  DEFM "Memory full"
  DEFB $07
  DEFB $00


; TEXT control M routine
; (CR/LF, ENTER key code)
  CALL TXT_CTL_C
  CALL DWNLDR_19
  LD HL,(TEXT_END)
  INC HL
  LD A,(HL)
  INC HL
  OR (HL)
  JP NZ,TXT_CTL_I_1
  CALL CHGDSP3
  CALL TXT_GET_CURPOS
  LD A,$0D
  CALL TXT_SPLIT_ROW
  LD A,$0A
  JP GET_DEVICE_216

; TEXT right arrow and control D routine
; (move cursor right)
TXT_CTL_D:
  CALL TXT_CTL_X_0
  SCF

; TEXT down arrow and control X routine
TXT_CTL_X:
  CALL NC,TXT_CTL_X_1
  JP TXT_CTL_C_0

TXT_CTL_X_0:
  LD HL,(CSRX)
  LD A,(ACTV_Y)
  INC H
  CP H
  JP NC,DUPDSP8
  LD H,$01
  
TXT_CTL_X_1:
  INC L
  LD A,L
  PUSH HL
  CALL DWNLDR_13
  LD A,E
  AND D
  INC A
  POP HL
  SCF
  RET Z
  CALL GET_BT_ROWPOS
  CP L
  CALL C,TXT_CTL_C_10
  JP DUPDSP8

; TEXT control H routine
; Delete previous character (BS)
TXT_CTL_H:
  CALL TXT_CTL_C
  CALL TXT_GET_CURPOS
  CALL TXT_CTL_C_9
  CALL DUPDSP6
  RET C
  
TXT_CTL_H_0:
  CALL TXT_CTL_C
  CALL TXT_GET_CURPOS
  PUSH HL
DUPDSP3:
  CALL TXT_CTL_C_9
  POP HL
  LD A,(HL)
  CP $1A		; EOF
  RET Z
  PUSH AF
  PUSH HL
  PUSH HL
  CALL DWNLDR_19
  POP HL
DUPDSP4:
  CALL MCLEAR_5
  CALL $6424
  POP HL
  POP AF
  CP $0D
  JP NZ,DUPDSP5
  LD A,(HL)
  CP $0A
  JP NZ,DUPDSP5
  PUSH AF
  PUSH HL
  JP DUPDSP4
DUPDSP5:
  PUSH HL
  LD A,(CSRX)
  CALL TEL_UPLD_77
  POP HL
  JP TXT_CTL_C_7
  CALL DUPDSP6
  SCF
  CALL NC,DUPDSP7
  JP TXT_CTL_C_0
DUPDSP6:
  LD HL,(CSRX)
  DEC H
  JP NZ,DUPDSP8
  LD A,(ACTV_Y)
  LD H,A
DUPDSP7:
  PUSH HL
  CALL DWNLDR_12
  LD HL,(CUR_TXTFILE)
  RST CPDEHL
  POP HL
  CCF
  RET C
  DEC L
  CALL Z,TXT_CTL_C_12
DUPDSP8:
  CALL POSIT
  AND A
  RET
  CALL TXT_GET_CURPOS
DUPDSP9:
  CALL ECHDSP4
  JP NZ,DUPDSP9
ECHDSP0:
  CALL ECHDSP4
  JP Z,ECHDSP0
  JP ECHDSP3
  CALL TXT_GET_CURPOS
ECHDSP1:
  CALL ECHDSP5
  JP Z,ECHDSP1
ECHDSP2:
  CALL ECHDSP5
  JP NZ,ECHDSP2
  CALL ECHDSP4
ECHDSP3:
  CALL TXT_CTL_C_7
  JP TXT_CTL_C_0
ECHDSP4:
  LD A,(HL)
  CP $1A		; EOF
  POP BC
  JP Z,ECHDSP3
  INC HL
  JP ECHDSP6
ECHDSP5:
  EX DE,HL
  LD HL,(CUR_TXTFILE)
  EX DE,HL
  RST CPDEHL
  POP BC
  JP Z,ECHDSP3
  DEC HL
ECHDSP6:
  PUSH BC
  PUSH HL
  LD A,(HL)
  CALL TEL_UPLD_73
  POP HL
  RET
  DEC L
  LD L,$01
  JP NZ,ECHDSP7
  PUSH HL
  CALL DWNLDR_12
  EX DE,HL
  CALL CHGDSP0
  POP HL
ECHDSP7:
  CALL POSIT
  JP TXT_CTL_C_0
  PUSH HL
  INC L
  CALL GET_BT_ROWPOS
  INC A
  CP L
  JP NZ,ECHDSP8
  PUSH AF
  CALL DWNLDR_12
  EX DE,HL
  LD A,$01
  CALL CHGDSP1
  POP AF
ECHDSP8:
  DEC A
  CALL DWNLDR_13
  LD B,A
  INC DE
  LD A,D
  OR E
  LD A,B
  JP Z,ECHDSP8
  POP HL
  LD L,A
  JP ECHDSP7
  
  LD A,(ACTV_Y)
  LD H,A
  CALL POSIT
  CALL TXT_GET_CURPOS
  CALL TXT_CTL_V_55
  LD BC,$0126
  JP ECHDSP7
  LD HL,(CUR_TXTFILE)
  CALL CHGDSP2
  CALL HOME
  JP TXT_CTL_C_0
  
  LD HL,(TEXT_END)
  PUSH HL
  CALL TXT_CTL_V_46
  POP HL
  RST CPDEHL
  PUSH HL
  CALL NC,CHGDSP0
ECHDSP9:
  POP HL
  CALL TXT_CTL_C_9
  JP TXT_CTL_C_0

CHGDSP0:
  CALL GET_BT_ROWPOS
CHGDSP1:
  CALL GET_DEVICE_372
CHGDSP2:
  CALL SYNCHR_1
  RET Z
  LD ($F507),HL
  LD A,$01
  JP TEL_UPLD_79

  CALL TXT_CTL_C
  CALL TXT_GET_CURPOS
  LD (TXT_SEL_BEG),HL
  LD (TXT_SEL_END),HL
  LD E,L
  LD D,H
  JP CHGDSP_01

CHGDSP3:
  LD C,$00
  LD HL,$800E
  CALL GET_BT_ROWPOS
  LD HL,CSRX
  SUB (HL)
  LD B,A
  CALL DWNLDR_12
  INC HL
TXT_CTL_L_1:
  INC HL
  LD E,(HL)
  INC HL
  LD D,(HL)
  INC DE
  LD A,D
  OR E
  RET Z
  DEC C
  JP M,TXT_CTL_L_2
  DEC DE
  DEC DE
TXT_CTL_L_2:
  DEC HL
  LD (HL),E
  INC HL
  LD (HL),D
  DEC B
  JP P,TXT_CTL_L_1
  RET

TXT_CTL_L_3:
  CALL HOME
  CALL DELLIN
  CALL GET_BT_ROWPOS

TXT_CTL_L_4:
  ADD A,A
  LD B,A
  LD DE,$F507
  LD HL,$F509
  JP LDIR_B

; TEXT control C routine
;
; Used by the routines at TXT_CTL_I, TXT_CTL_M, TXT_CTL_H, TXT_CTL_L,
; TXT_CTL_O, TXT_CTL_U and TXT_CTL_N.
; Interrupt any type of function (Cancel SETFIL, SAVE, LOAD, FIND or PRINT)
TXT_CTL_C:
  CALL TXT_IS_SETFILING
  PUSH HL
  LD HL,$0000
  LD (TXT_SEL_BEG),HL
  CALL TXT_GET_CURPOS
  POP DE
  JP TXT_CTL_C_1
  
; This entry point is used by the routines at TXT_CTL_X, TXT_CTL_E, TXT_CTL_A,
; TXT_CTL_T, TXT_CTL_W and TXT_CTL_Z.
TXT_CTL_C_0:
  CALL TXT_IS_SETFILING
  CALL TXT_GET_CURPOS
  EX DE,HL
  LD HL,(TXT_SEL_END)
  RST CPDEHL
  RET Z
  EX DE,HL
  LD (TXT_SEL_END),HL
TXT_CTL_C_1:
  CALL TXT_CTL_U_5
CHGDSP_01:
  PUSH HL
  PUSH DE
  CALL TXT_CTL_V_46
  POP HL
  RST CPDEHL
  JP C,CHGDSP_02
  CALL GO_BOTTOMROW
CHGDSP_02:
  CALL C,TXT_CTL_V_55
  LD H,L
  EX (SP),HL
  CALL SYNCHR_1
  JP NC,CHGDSP_03
  LD L,$01
CHGDSP_03:
  CALL NC,TXT_CTL_V_55
  POP AF
  SUB L
  LD C,A
  EX DE,HL
  LD HL,(CSRX)
  EX DE,HL
  PUSH DE
  LD H,$01
  CALL POSIT
  CALL DWNLDR_12
  LD A,C
TXT_CTL_C_5:
  PUSH AF
  CALL DWNLDR_05
  POP AF
  DEC A
  JP P,TXT_CTL_C_5
  JP GET_DEVICE_219

TXT_IS_SETFILING:
  LD HL,(TXT_SEL_BEG)
  LD A,H
  OR L
  RET NZ
  POP HL
  RET

TXT_CTL_C_7:
  CALL SYNCHR_1
  CALL C,TXT_CTL_C_13
  JP C,TXT_CTL_C_7
CHGDSP_07:
  PUSH HL
  CALL TXT_CTL_V_46
  POP HL
  RST CPDEHL
  CALL NC,TXT_CTL_C_11
  JP NC,CHGDSP_07
  
; This entry point is used by the routines at WAIT_SPC, TXT_CTL_H, TXT_CTL_Z,
; TXT_CTL_U and TXT_CTL_V.
TXT_CTL_C_9:
  CALL TXT_CTL_V_55
  JP POSIT

TXT_CTL_C_10:
  DEC L
TXT_CTL_C_11:
  PUSH AF
  PUSH HL
  CALL TXT_CTL_L_3
  CALL GET_BT_ROWPOS
  JP TXT_CTL_C_14

TXT_CTL_C_12:
  INC L
TXT_CTL_C_13:
  PUSH AF
  PUSH HL
  CALL CLR_BOTTOMROW
  CALL HOME
  CALL INSLIN
  CALL DWNLDR_14
  PUSH DE
  CALL TXT_CTL_V_46
  INC HL
  LD E,L
  LD D,H
  DEC HL
  DEC HL
  DEC A
  ADD A,A
  LD C,A
  LD B,$00
  CALL _LDDR
  EX DE,HL
  POP DE
  LD (HL),D
  DEC HL
  LD (HL),E
  LD A,$01
TXT_CTL_C_14:
  CALL TEL_UPLD_79
  POP HL
  POP AF
  RET
; This entry point is used by the routine at GETWORD.
CHGDSP_14:
  LD HL,(DO_FILES)
; This entry point is used by the routine at GETWORD.
CHGDSP_15:
  DEC HL
  LD (TEXT_END),HL
  
TXT_CTL_C_15:
  LD HL,(ARREND)
  LD BC,$00C8
  ADD HL,BC
  LD BC,$0000
  XOR A
  SUB L
  LD L,A
  SBC A,A
  SUB H
  LD H,A
  ADD HL,SP
  RET NC
  LD A,H
  OR L
  RET Z
  LD B,H
  LD C,L
  LD HL,(TEXT_END)
  EX DE,HL
  INC DE
  CALL MAKHOL_0
  PUSH BC
MCLEAR:
  LD (HL),$00
  INC HL
  DEC BC
  LD A,B
  OR C
  JP NZ,MCLEAR
  POP BC
  RET

MCLEAR_0:
  LD HL,(DO_FILES)
MCLEAR_1:
  CALL GETEND
  INC HL
  EX DE,HL
  LD HL,(CO_FILES)
  EX DE,HL
  RST CPDEHL
  RET NC
  LD A,(HL)
  AND A
  JP NZ,MCLEAR_1

; This entry point is used by the routines at DWNLDR, TXT_ESC, TXT_CTL_O and
; TXT_CTL_U.
TXT_WIPE_END:
  LD HL,(TEXT_END)
  PUSH HL
  LD BC,$FFFF
  XOR A
TXT_WIPE_END_0:
  INC HL
  INC BC
  CP (HL)
  JP Z,TXT_WIPE_END_0
  POP HL
  INC HL
  JP MASDEL

; This entry point is used by the routines at DWNLDR, TXT_CTL_I, TXT_CTL_M and
; TXT_CTL_V.
TXT_SPLIT_ROW:
  EX DE,HL
  LD HL,(TEXT_END)
  INC HL
  INC (HL)
  DEC (HL)
  SCF
  RET NZ
  PUSH AF
  LD (TEXT_END),HL
  EX DE,HL
  LD A,E
  SUB L
  LD C,A
  LD A,D
  SBC A,H
  LD B,A
  LD L,E
  LD H,D
  DEC HL
  CALL _LDDR
  INC HL
  POP AF
  LD (HL),A
  INC HL
  AND A
  RET

; This entry point is used by the routine at TXT_CTL_H.
MCLEAR_5:
  EX DE,HL
  LD HL,(TEXT_END)
  LD A,L
  SUB E
  LD C,A
  LD A,H
  SBC A,D
  LD B,A
  DEC HL
  LD (TEXT_END),HL
  LD L,E
  LD H,D
  INC HL
  CALL _LDIR
  XOR A
  LD (DE),A
  RET

; This entry point is used by the routine at ISFLIO.
GET_BT_ROWPOS:
  PUSH HL
  PUSH AF
  LD HL,LABEL_LN
  LD A,(ACTV_X)
  ADD A,(HL)
  LD L,A
  POP AF
  LD A,L
  POP HL
  RET

GO_BOTTOMROW:
  PUSH AF
  LD HL,(ACTV_X)
  CALL GET_BT_ROWPOS
  LD L,A
  POP AF
  RET

TEL_UPLD6:
  CALL CHGET
  RET C
  PUSH AF
  CP $10
  JP Z,MCLEAR_9
  POP AF
  RET
  
MCLEAR_9:
  LD HL,(CSRX)
  PUSH HL
  LD A,(LABEL_LN)
  AND A
  JP NZ,MCLEAR_10
  INC A
  CALL DSPFNK_0
  LD A,(CSRX)
  POP HL
  CP L
  LD A,(ACTV_X)
  CALL NZ,TXT_CTL_L_4
  POP AF
  RET
  
MCLEAR_10:
  CALL ERAFNK
  LD A,(ACTV_X)
  DEC A
  CALL DWNLDR_13
  INC HL
  LD (HL),$FE
  INC HL
  INC HL
  LD (HL),$FE
  DEC A
  CALL TEL_UPLD_79
  XOR A
  LD (TXT_ERRFLG),A
  POP HL
  CALL POSIT
  POP AF
  RET

; TEXT control O routine
; 'COPY' the SETFILed text
TXT_CTL_O:
  CALL TXT_IS_SETFILING
  CALL TXT_WIPE_END
  CALL TXT_CTL_U_6
  PUSH AF
  CALL TXT_CTL_C_15
  POP AF
  JP NC,TXT_CTL_C
  JP TXT_CTL_I_1

; TEXT control U routine
; same as CUT function
TXT_CTL_U:
  CALL TXT_IS_SETFILING
  CALL TXT_WIPE_END
  CALL TXT_CTL_U_6
  PUSH AF
  CALL NC,MASDEL
  POP AF
  JP NC,TXT_CTL_U_2
  LD A,B
  AND A
  JP Z,TXT_CTL_U_1
TXT_CTL_U_0:
  CALL GETWORD_131
  PUSH BC
  LD BC,$0100
  CALL TXT_CTL_U_3
  POP BC
  DEC B
  JP NZ,TXT_CTL_U_0
TXT_CTL_U_1:
  LD A,C
  AND A
  CALL NZ,TXT_CTL_U_3
TXT_CTL_U_2:
  LD DE,$0000
  EX DE,HL
  LD (TXT_SEL_BEG),HL
  EX DE,HL
  PUSH HL
  LD A,(CSRX)
  CALL TEL_UPLD_75
  POP HL
  CALL TXT_CTL_C_9
  CALL GETEND_CURTXT
  JP TXT_CTL_C_15
  

TXT_CTL_U_3:
  PUSH HL
  PUSH BC
  EX DE,HL
  LD HL,(FILTAB+4)
  EX DE,HL
  CALL _LDIR
  POP BC
  POP HL
  PUSH HL
  PUSH BC
  CALL MASDEL
  LD HL,(HAYASHI)		; Paste buffer file
  ADD HL,BC
  EX DE,HL
  POP BC
  CALL MAKHOL_0
  EX DE,HL
  LD HL,(FILTAB+4)
  CALL _LDIR
  POP HL
  RET

TXT_CTL_U_4:
  LD HL,(TXT_SEL_BEG)
  EX DE,HL
  LD HL,(TXT_SEL_END)

; This entry point is used by the routine at TXT_CTL_C.
TXT_CTL_U_5:
  RST CPDEHL
  RET C
  EX DE,HL
  RET

TXT_CTL_U_6:
  CALL SWAPNM_1
  LD HL,(HAYASHI)		; Paste buffer file
  LD (KBUF),HL
  XOR A
  LD (TXT_BUFLAG),A
  CALL TXT_CTL_U_4
  DEC DE

TXT_CTL_U_7:
  LD A,E
  SUB L
  LD C,A
  LD A,D
  SBC A,H
  LD B,A
  JP C,TXT_CTL_U_8
  LD A,(DE)
  CP $1A		; EOF
  JP Z,TXT_CTL_U_9
  CP $0D
  JP NZ,TXT_CTL_U_8
  INC DE
  LD A,(DE)
  CP $0A         ; LF
  JP NZ,TXT_CTL_U_8
  INC BC
TXT_CTL_U_8:
  INC BC
TXT_CTL_U_9:
  LD A,B
  OR C
  RET Z
  PUSH HL
  LD HL,(KBUF)
  CALL MAKHOL
  EX DE,HL
  POP HL
  RET C
  LD A,(TXT_BUFLAG)
  AND A
  JP Z,TXT_CTL_U_10
  ADD HL,BC
TXT_CTL_U_10:
  PUSH HL
  PUSH BC
  CALL _LDIR
  POP BC
  POP HL
  RET
  
; This entry point is used by the routines at WAIT_SPC and TXT_CTL_P.
TXT_CTL_U_11:
  CALL TXT_CTL_C
  CALL TXT_WIPE_END
  CALL RESFPT
  CALL TXT_GET_CURPOS
  LD (KBUF),HL
  LD A,H
  LD (TXT_BUFLAG),A
  LD HL,(HAYASHI)		; Paste buffer file
  LD A,(HL)
  CP $1A		; EOF
  JP Z,TXT_CTL_C_15
  LD E,L
  LD D,H
  DEC DE
TXT_CTL_U_12:
  INC DE
  LD A,(DE)
  CP $1A		; EOF
  JP NZ,TXT_CTL_U_12
  CALL TXT_CTL_U_7
  PUSH AF
  PUSH DE
  CALL GETEND_CURTXT
  CALL TXT_CTL_C_15
  POP DE
  POP AF
  JP C,TXT_CTL_I_1
  PUSH DE
  LD HL,(KBUF)
  LD A,(CSRX)
  CALL TEL_UPLD_75
  CALL TXT_CTL_V_46
  POP HL
  RST CPDEHL
  CALL GET_BT_ROWPOS
  PUSH HL
  CALL NC,TEL_UPLD_75
  POP HL
  JP TXT_CTL_C_9

; "FIND more" ?
  CALL TXT_CTL_N_2
  CALL TXT_GET_CURPOS
  EX DE,HL
  LD HL,STRG_ASKBUF
  LD A,(HL)
  AND A
  RET Z
  JP TEL_UPLD_12


; TEXT control N routine
; FIND in text
TXT_CTL_N:
  CALL TXT_CTL_N_2
  CALL TXT_GET_CURPOS
  PUSH HL
  LD HL,STRG_MSG		;$67BC
  LD DE,STRG_ASKBUF
  PUSH DE
  CALL ASK_TEXT
  POP DE
  INC HL
  LD A,(HL)
  AND A
  SCF
  JP Z,TXT_CTL_N_0
  CALL MOVE_TEXT
  POP DE
TEL_UPLD_12:
  PUSH DE
  LD A,(DE)
  CP $1A		; EOF
  JP Z,TXT_CTL_N_1
  INC DE
  CALL FIND_TEXT
  JP NC,TXT_CTL_N_1
  POP DE
  PUSH BC
  PUSH BC
  CALL TXT_CTL_V_46
  POP HL
  RST CPDEHL
  JP C,TXT_CTL_N_0
  CALL $6A1E
  AND A
TXT_CTL_N_0:
  CALL C,TEL_UPLD_42
  SCF
TXT_CTL_N_1:
  LD HL,NOMATCH_MSG		;$67B3
  CALL NC,TXT_ERROR
  JP ECHDSP9
  CALL TXT_CTL_C

; This entry point is used by the routines at TXT_CTL_Y and TXT_CTL_G.
TXT_CTL_N_2:
  LD HL,(CSRX)
  CALL GET_BT_ROWPOS
  CP L
  RET NZ
  DEC L
  PUSH HL
  CALL TXT_CTL_L_3
  JP GET_DEVICE_219

; This entry point is used by the routines at TXT_CTL_Y and TXT_CTL_V.
TXT_ABT_ERROR:
  LD HL,ABTMSG		;$562A
TXT_ERROR:
  LD A,$01
  LD (TXT_ERRFLG),A
TEL_UPLD_17:
  CALL CLR_BOTTOMROW
  CALL PRS	; prints error message in HL

TEL_UPLD_18:
  CALL CHSNS
  RET Z
  CALL CHGET
  JP TEL_UPLD_18

MOVE_TEXT:
  PUSH HL
MOVE_TEXT_0:
  LD A,(HL)
  LD (DE),A
  INC HL
  INC DE
  AND A
  JP NZ,MOVE_TEXT_0
  POP HL
  RET

; Routine at 26062
NOMATCH_MSG:
  DEFM "No match"
  DEFB $00

STRG_MSG:
  DEFM "String:"
  DEFB $00

;
; Used by the routines at TXT_CTL_C and TXT_CTL_N.
CLR_BOTTOMROW:
  PUSH HL
  CALL GO_BOTTOMROW
  LD H,$01
  CALL POSIT
  POP HL
  JP ERAEOL

TEL_UPLD_41:
  LD HL,TXT_ERRFLG
  XOR A
  CP (HL)
  RET Z
  LD (HL),A
TEL_UPLD_42:
  LD HL,(CSRX)
  PUSH HL
  CALL GET_BT_ROWPOS
  CALL TEL_UPLD_79
  JP GET_DEVICE_219
  LD DE,BLANK_BYTE
  
ASK_TEXT:
  PUSH DE
  CALL TEL_UPLD_17
  LD A,(CSRY)
  LD (SV_CSRY),A
  POP HL
  PUSH HL
  CALL PRS
  CALL HOME2
TEL_UPLD_44:
  CALL CHGET
  JP C,TEL_UPLD_44
  AND A
  JP Z,TEL_UPLD_44
  POP HL
  CP $0D
  JP Z,TEL_UPLD_46
  PUSH AF
  CALL GO_BOTTOMROW
  LD A,(SV_CSRY)
  LD H,A
  CALL POSIT
  CALL ERAEOL
  POP AF
  LD DE,INPBFR
  LD B,$01
  AND A
  JP TEL_UPLD_45

  CALL CHGET
TEL_UPLD_45:
  LD HL,$6822
  PUSH HL
  RET C
  CP $7F			; BS
  JP Z,_INLIN_BS
  CP ' '
  JP NC,TEL_UPLD_48
  LD HL,$6843
  LD C,$07
  JP TTY_VECT_JP_2
TEL_UPLD_46:
  LD DE,INPBFR
  CALL MOVE_TEXT
  JP TEL_UPLD_47
  INC BC
  LD E,D
  LD L,B
  EX AF,AF'
  POP BC
  LD B,(HL)
  ADD HL,BC
  LD H,A
  LD L,B
  DEC C
  LD E,L
  LD L,B
  DEC D
  CALL PO,_CHSNS
  CALL PO,GETWORD_102
  POP BC
  LD B,(HL)
  LD DE,INPBFR
  POP HL
  POP HL
  XOR A
  LD (DE),A
TEL_UPLD_47:
  LD HL,BUFMIN
  JP HOME3

  LD A,$09
TEL_UPLD_48:
  LD C,A
  LD A,(ACTV_Y)
  SUB $09
  LD HL,CSRY
  CP (HL)
  JP C,__BEEP
  LD A,C
  INC B
  RST OUTC
  LD (DE),A
  INC DE
  RET

TEL_UPLD_49:
  XOR A
  LD (TXT_COUNT),A
  LD (TXT_BUFLAG),A
  LD HL,TXT_BUF
  LD (TXT_PTR),HL
  
L67DF_LOOP:
  PUSH DE
  CALL TXT_CTL_V_21
  POP DE
  LD A,(DE)
  INC DE
  CP $1A		; EOF
  JP Z,TXT_CTLZ_EOF
  CP $0D
  JP Z,TXTCURS_CR
  CP $09
  JP Z,TXT_TAB
  CP ' '
  JP C,TXT_SPC
  
TXT_TAB:
  CALL TXT_ADD_GRAPH
  JP NC,L67DF_LOOP
  LD A,(DE)
  CALL TXT_CTL_V_26
  JP NZ,TXT_CTL_V_6
  CALL TXT_CTL_V_8
  LD A,(DE)
  CP ' '
  RET NZ
  LD A,(TXT_EDITING)
  AND A
  RET Z
  INC DE
  LD A,(DE)
  CP ' '
  RET NZ
  DEC DE
  RET

TXT_CTL_V_6:
  EX DE,HL
  LD (KBUF),HL
  EX DE,HL
  LD HL,(TXT_PTR)
  LD (TXT_SAVPTR),HL
  DEC DE
  LD A,(DE)
  INC DE
  CALL TXT_CTL_V_26
  JP Z,TXT_CTL_V_8
TEL_UPLD_53:
  DEC DE
  LD A,(DE)
  INC DE
  CALL TXT_CTL_V_26
  JP Z,TEL_UPLD_STOP5
  DEC DE
  CALL TEL_UPLD_STOP3
  JP NZ,TEL_UPLD_53
  LD HL,(TXT_SAVPTR)
  LD (TXT_PTR),HL
  LD HL,(KBUF)		; =PASTE_BUF
  EX DE,HL
TXT_CTL_V_8:
  LD A,(TXT_EDITING)
  DEC A
  JP Z,TXT_CRLF
  RET
  
TXT_SPC:
  PUSH AF
  LD A,$5E
  CALL TXT_ADD_GRAPH
  JP C,TEL_UPLD_56
  POP AF
  OR $40
  CALL TXT_ADD_GRAPH
  JP NC,L67DF_LOOP
  LD A,(TXT_EDITING)
  AND A
  JP NZ,TXT_CRLF
  RET
  
TEL_UPLD_56:
  POP AF
  DEC DE
  LD HL,(TXT_PTR)
  DEC HL
  LD (TXT_PTR),HL
  LD HL,TXT_COUNT
  DEC (HL)
  JP TEL_UPLD_STOP5
  
TXT_CTLZ_EOF:
  LD A,(TXT_EDITING)
  AND A
  LD A,$80
  CALL Z,TXT_ADD_GRAPH
  CALL TEL_UPLD_STOP5
  LD DE,$FFFF
  RET

TXTCURS_CR:
  LD A,(DE)
  CP $0A
  LD A,$0D
  JP NZ,TXT_SPC
  PUSH DE
  CALL TXT_CTL_V_21
  POP DE
  LD A,(TXT_EDITING)
  AND A
  LD A,$81
  CALL Z,TXT_ADD_GRAPH
  CALL TEL_UPLD_STOP5
  INC DE
  RET
TXT_ADD_GRAPH:
  PUSH HL
  CALL ADD_CHAR
  LD HL,TXT_COUNT
  CP $09		; TAB
  JP Z,ADD_TAB
  INC (HL)
  JP TEL_UPLD_STOP1

ADD_TAB:
  INC (HL)
  LD A,(HL)
  AND $07
  JP NZ,ADD_TAB
TEL_UPLD_STOP1:
  LD A,(TRM_WIDTH)
  DEC A
  CP (HL)
  POP HL
  RET

ADD_CHAR:
  LD HL,(TXT_PTR)
  LD (HL),A
  INC HL
  LD (TXT_PTR),HL
  RET
TEL_UPLD_STOP3:
  LD HL,(TXT_PTR)
  DEC HL
  DEC HL
  DEC HL
  LD A,(HL)
  CP $1B
  JP Z,TEL_UPLD_STOP4
  INC HL
  INC HL
TEL_UPLD_STOP4:
  LD (TXT_PTR),HL
  LD HL,TXT_COUNT
  DEC (HL)
  RET
  
TEL_UPLD_STOP5:
  LD A,(TXT_COUNT)
  LD HL,TRM_WIDTH
  CP (HL)
  RET NC
  LD A,(TXT_EDITING)
  AND A
  JP NZ,TXT_CRLF
  LD A,$1B		; ESC ..
  CALL ADD_CHAR
  LD A,$4B		; ..'K', "erase in line"
  CALL ADD_CHAR
TXT_CRLF:
  LD A,$0D
  CALL ADD_CHAR
  LD A,$0A
  JP ADD_CHAR

TXT_CTL_V_21:
  CALL TXT_IS_SETFILING
  LD A,(TXT_EDITING)
  AND A
  RET NZ
  LD BC,TXT_BUFLAG
  PUSH DE
  EX DE,HL
  LD HL,(TXT_SEL_END)
  EX DE,HL
  RST CPDEHL
  POP DE
  JP NC,TEL_UPLD_STOP9
  EX DE,HL
  RST CPDEHL
  JP C,TEXT_NOREV
  EX DE,HL
  LD HL,(TXT_SEL_END)
  EX DE,HL
  RST CPDEHL
  JP NC,TEXT_NOREV
TEXT_REV:
  LD A,(BC)
  AND A
  RET NZ
  INC A
  LD H,'p'			; ESC p (enter in inverse video mode)
  JP ADD_ESC_SEQ
  
TEL_UPLD_STOP9:
  EX DE,HL
  RST CPDEHL
  JP NC,TEXT_NOREV
  EX DE,HL
  LD HL,(TXT_SEL_END)
  EX DE,HL
  RST CPDEHL
  JP NC,TEXT_REV
  
TEXT_NOREV:
  LD A,(BC)
  AND A
  RET Z
  XOR A
  LD H,'q'			; ESC q (exit from inverse video mode)
  
ADD_ESC_SEQ:
  PUSH HL
  LD (BC),A
  LD A,$1B
  CALL ADD_CHAR
  POP AF
  JP ADD_CHAR
  
TXT_CTL_V_26:
  LD B,A
  LD A,($F4F7)
  AND A
  LD A,B
  RET Z
  
TEL_UPLD_73:
  LD HL,SYMBS_TXT
  LD B,$01
SYMB_LOOP:
  CP (HL)
  RET Z
  INC HL
  DEC B
  JP NZ,SYMB_LOOP
  CP '!'
  INC B
  RET NC
  DEC B
  RET

SYMBS_TXT:
  DEFM "()<>[]+-*/"
  

  CALL GET_BT_ROWPOS
  AND A
  RRA
TEL_UPLD_75:
  CALL GET_DEVICE_372
  LD ($F507),HL
  CALL GET_BT_ROWPOS
  ADD A,A
  LD HL,$F509
TEL_UPLD_76:
  LD (HL),$FE
  INC HL
  DEC A
  JP NZ,TEL_UPLD_76
  INC A
  JP TEL_UPLD_79
TEL_UPLD_77:
  PUSH AF
  LD HL,($F505)
  LD A,H
  OR L
  JP Z,TEL_UPLD_78
  EX DE,HL
  CALL TEL_UPLD_49
  POP AF
  LD B,A
  CALL DWNLDR_08
  LD A,B
  PUSH AF
  JP Z,TEL_UPLD_78
  DEC A
  JP Z,TEL_UPLD_78
  LD L,A
  LD H,$01
  CALL POSIT
  CALL DWNLDR_06
  LD A,D
  AND E
  INC A
  POP BC
  JP Z,ERAEOL
  PUSH BC
TEL_UPLD_78:
  POP AF
TEL_UPLD_79:
  LD L,A
  LD H,$01
  CALL POSIT
  CALL DWNLDR_12
  LD A,E
  AND D
  INC A
  JP Z,DWNLDR_04
  CALL DWNLDR_12
DWNLDR_00:
  CALL GO_BOTTOMROW
  CP L
  JP Z,DWNLDR_01
  CALL DWNLDR_05
  LD A,D
  AND E
  INC A
  JP Z,DWNLDR_03
  CALL DWNLDR_09
  JP NZ,DWNLDR_00
  RET
DWNLDR_01:
  CALL DWNLDR_05
DWNLDR_02:
  CALL GET_BT_ROWPOS
  INC A
  JP DWNLDR_08
DWNLDR_03:
  CALL DWNLDR_09
  JP Z,DWNLDR_02
DWNLDR_04:
  CALL ERAEOL
  CALL OUTDO_CRLF
  JP DWNLDR_03
DWNLDR_05:
  CALL TEL_UPLD_49
DWNLDR_06:
  PUSH DE
  LD HL,(TXT_PTR)
  LD DE,TXT_BUF
DWNLDR_07:
  LD A,(DE)
  RST OUTC
  INC DE
  RST CPDEHL
  JP NZ,DWNLDR_07
  LD A,(TXT_EDITING)
  AND A
  CALL Z,EXTREV
  POP DE
  RET
DWNLDR_08:
  PUSH DE
  CALL DWNLDR_13
  JP DWNLDR_10
DWNLDR_09:
  PUSH DE
  CALL DWNLDR_12
DWNLDR_10:
  LD C,A
  EX (SP),HL
  RST CPDEHL
  LD A,C
  EX DE,HL
  POP HL
  RET Z
  LD (HL),E
  INC HL
  LD (HL),D
  LD A,C
  RET
  
TXT_CTL_V_46:
  CALL GET_BT_ROWPOS
  INC A
  JP DWNLDR_13
DWNLDR_12:
  LD A,(CSRX)
DWNLDR_13:
  LD E,A
  LD D,$00
  LD HL,$F505
  ADD HL,DE
  ADD HL,DE
  LD E,(HL)
  INC HL
  LD D,(HL)
  DEC HL
  RET
DWNLDR_14:
  CALL DWNLDR_12
  DEC A
  JP Z,DWNLDR_15
  DEC HL
  LD D,(HL)
  DEC HL
  LD E,(HL)
  RET
DWNLDR_15:
  LD HL,(CUR_TXTFILE)
  RST CPDEHL
  JP C,DWNLDR_16
  LD DE,$0000
  RET
DWNLDR_16:
  PUSH DE
  DEC DE
  RST CPDEHL
  JP NC,DWNLDR_18
DWNLDR_17:
  DEC DE
  RST CPDEHL
  JP NC,DWNLDR_18
  LD A,(DE)
  CP $0A
  JP NZ,DWNLDR_17
  DEC DE
  RST CPDEHL
  JP NC,DWNLDR_18
  LD A,(DE)
  INC DE
  CP $0D
  JP NZ,DWNLDR_17
  INC DE
DWNLDR_18:
  PUSH DE
  CALL TEL_UPLD_49
  POP BC
  EX DE,HL
  POP DE
  PUSH DE
  RST CPDEHL
  EX DE,HL
  JP C,DWNLDR_18
  POP DE
  LD E,C
  LD D,B
  RET
  
DWNLDR_19:
  CALL DWNLDR_14
  EX DE,HL
  LD ($F505),HL
  RET
  
  
TXT_CTL_V_55:
  LD (SAVE_CSRX),HL
  PUSH HL
  LD HL,$F507
  CALL GET_BT_ROWPOS
  LD B,A
DWNLDR_21:
  LD E,(HL)
  INC HL
  LD D,(HL)
  INC HL
  PUSH HL
  LD HL,(SAVE_CSRX)
  RST CPDEHL
  JP C,DWNLDR_22
  POP HL
  EX DE,HL
  EX (SP),HL
  EX DE,HL
  DEC B
  JP P,DWNLDR_21
  DI
  HALT
  
DWNLDR_22:
  EX DE,HL
  POP HL
  POP HL
DWNLDR_23:
  PUSH HL
  LD HL,TXT_BUF
  LD (TXT_PTR),HL
  XOR A
  LD (TXT_COUNT),A
  POP HL
  DEC HL
DWNLDR_24:
  INC HL
  RST CPDEHL
  JP NC,DWNLDR_25
  LD A,(HL)
  CALL TXT_ADD_GRAPH
  LD A,(HL)
  CP ' '
  JP NC,DWNLDR_24
  CP $09
  JP Z,DWNLDR_24
  CALL TXT_ADD_GRAPH
  JP DWNLDR_24
  
DWNLDR_25:
  LD A,(TXT_COUNT)
  INC A
  LD H,A
  CALL GET_BT_ROWPOS
  SUB B
  LD L,A
  RET
  
; This entry point is used by the routines at TXT_CTL_I, TXT_CTL_M, TXT_CTL_H,
; TXT_CTL_F, TXT_CTL_A, TXT_CTL_R, TXT_CTL_L, TXT_CTL_C, TXT_CTL_U and
; TXT_CTL_N.
TXT_GET_CURPOS:
  CALL DWNLDR_12
  PUSH DE
  INC A
  CALL DWNLDR_13
  LD A,D
  AND E
  INC A
  JP NZ,DWNLDR_27
  LD HL,(TEXT_END)
  EX DE,HL
  INC DE
DWNLDR_27:
  DEC DE
  LD A,(DE)
  CP $0A
  JP NZ,DWNLDR_28
  DEC DE
  LD A,(DE)
  CP $0D
  JP Z,DWNLDR_28
  INC DE
DWNLDR_28:
  POP HL
  PUSH HL
  CALL DWNLDR_23
  LD A,(CSRY)
  CP H
  JP C,DWNLDR_27
  POP HL
  EX DE,HL
  RET
  
GETEND_CURTXT:
  LD HL,(CUR_TXTFILE)
GETEND:
  LD A,$1A
GET_DEVICE_371:
  CP (HL)
  INC HL
  JP NZ,GET_DEVICE_371
  DEC HL
  LD (TEXT_END),HL
  RET
GET_DEVICE_372:
  PUSH AF
  EX DE,HL
  LD HL,(CUR_TXTFILE)
  EX DE,HL
GET_DEVICE_373:
  PUSH HL
  PUSH DE
  CALL TEL_UPLD_49
  POP BC
  POP HL
  RST CPDEHL
  JP NC,GET_DEVICE_373
  LD H,B
  LD L,C
  POP BC
  DEC B
  RET Z
  EX DE,HL
GET_DEVICE_374:
  PUSH BC
  CALL DWNLDR_15
  POP BC
  LD A,D
  OR E
  LD HL,(CUR_TXTFILE)
  RET Z
  DEC B
  JP NZ,GET_DEVICE_374
  EX DE,HL
  RET
; This entry point is used by the routine at GETWORD.
INSCHR:
  LD BC,$0001
  PUSH AF
  CALL MAKHOL
  POP BC
  RET C
  LD (HL),B
  INC HL
  RET
; This entry point is used by the routine at GETWORD.
MAKHOL:
  EX DE,HL
  LD HL,(ARREND)
  ADD HL,BC
  RET C
  LD A,$88
  SUB L
  LD L,A
  LD A,$FF
  SBC A,H
  LD H,A
  RET C
  ADD HL,SP
  CCF
  RET C
; This entry point is used by the routine at GETWORD.
MAKHOL_0:
  PUSH BC
  CALL GET_DEVICE_379
  LD HL,(ARREND)
  LD A,L
  SUB E
  LD E,A
  LD A,H
  SBC A,D
  LD D,A
  PUSH DE
  LD E,L
  LD D,H
  ADD HL,BC
  LD (ARREND),HL
  EX DE,HL
  DEC DE
  DEC HL
  POP BC
  LD A,B
  OR C
  CALL NZ,_LDDR
  INC HL
  POP BC
  RET
; This entry point is used by the routine at GETWORD.
MASDEL:
  LD A,B
  OR C
  RET Z
  PUSH HL
  PUSH BC
  PUSH HL
  ADD HL,BC
  EX DE,HL
  LD HL,(ARREND)
  EX DE,HL
  LD A,E
  SUB L
  LD C,A
  LD A,D
  SBC A,H
  LD B,A
  POP DE
  LD A,B
  OR C
  CALL NZ,_LDIR
  EX DE,HL
  LD (ARREND),HL
  POP BC
  XOR A
  SUB C
  LD C,A
  SBC A,A
  SUB B
  LD B,A
  POP HL
GET_DEVICE_379:
  PUSH HL
  LD HL,(CO_FILES)
  ADD HL,BC
  LD (CO_FILES),HL
  LD HL,(PROGND)
  ADD HL,BC
  LD (PROGND),HL
  LD HL,(VAREND)
  ADD HL,BC
  LD (VAREND),HL
  POP HL
  RET
  
; This entry point is used by the routines at GETWORD and ISFLIO.
_LDIR:
  LD A,(HL)
  LD (DE),A
  INC HL
  INC DE
  DEC BC
  LD A,B
  OR C
  JP NZ,_LDIR
  RET
  
; This entry point is used by the routine at ISFLIO.
_LDDR:
  LD A,(HL)
  LD (DE),A
  DEC HL
  DEC DE
  DEC BC
  LD A,B
  OR C
  JP NZ,_LDDR
  RET
  
  OR B
  RET NC
  LD L,H
  LD B,D
  LD B,C
  LD D,E
  LD C,C
  LD B,E
  JR NZ,DWNLDR_44
  NOP
  OR B
  CALL NZ,GET_DEVICE_20
  LD B,L
  LD E,B
  LD D,H
  JR NZ,DWNLDR_45
  JR NZ,DWNLDR_42
DWNLDR_42:
  OR B
  CALL C,GET_DEVICE_19
  LD B,L
  LD C,H
  LD B,E
  LD C,A
  LD C,L
  JR NZ,DWNLDR_43
DWNLDR_43:
  ADC A,B
  NOP
  NOP
  NOP
  LD D,E
  LD (HL),L
  LD A,D
  LD (HL),L
  LD L,E
DWNLDR_44:
  LD L,C
  JR NZ,_LDDR
  NOP
  NOP
  NOP
  LD C,B
  LD H,C
  LD A,C
  LD H,C
DWNLDR_45:
  LD (HL),E
  LD L,B
  LD L,C
  LD C,B
  NOP
  NOP
  NOP
  LD D,D
  LD L,C
  LD H,E
  LD L,E
  LD E,C
  JR NZ,$6CF0
  
  
  CALL PRINT_COPYRIGHT
  LD HL,SUZUKI-1
  LD (DIRPNT),HL
  LD HL,(SUZUKI)
  LD (BASTXT),HL
  LD A,$FF
  LD (LABEL_LN),A
BASIC_0:
  CALL LOAD_BA_LBL
  CALL FNKSB
  XOR A
  LD (FNK_FLAG),A
  CALL UPD_PTRS
  CALL RUN_FST
  JP READY

; This entry point is used by the routines at OUTS_B_CHARS and BOOT.
SAVE_BA_LBL:
  LD HL,FNKSTR
  LD DE,$F746
  JP LOAD_BA_LBL_0

; LOAD BA LABEL
;
; Used by the routines at __MENU and BASIC.
LOAD_BA_LBL:
  LD HL,$F746
  LD DE,FNKSTR

LOAD_BA_LBL_0:
  LD B,$A0
  JP LDIR_B
  
; This entry point is used by the routines at TELCOM_RDY and SCHEDL_DE.
PARSE_COMMAND:
  DEC HL
  RST CHRGTB		; Gets next character (or token) from BASIC text.
PARSE_COMMAND_0:
  LD A,(DE)
  INC A
  RET Z
  PUSH HL
  LD B,$04
PARSE_COMMAND_1:
  LD A,(DE)
  LD C,A
  CALL UCASE_HL
  CP C
  INC DE
  INC HL
  JP NZ,PARSE_COMMAND_3
  DEC B
  JP NZ,PARSE_COMMAND_1
  POP AF
  PUSH HL
  EX DE,HL
PARSE_COMMAND_2:
  LD E,(HL)
  INC HL
  LD D,(HL)
  EX DE,HL
  POP DE
  EX (SP),HL
  PUSH HL
  EX DE,HL
  INC H
  DEC H
  RET

PARSE_COMMAND_3:
  INC DE
  DEC B
  JP NZ,PARSE_COMMAND_3
  INC DE
  POP HL
  JP PARSE_COMMAND_0

INITIO:
  DI
  LD HL,ENDLCD
  LD B,132
  CALL ZERO_MEM
  INC A
IOINIT:
  PUSH AF
  DI
  LD A,$19
  JR NC,PARSE_COMMAND_2
  RET Z
  LD A,$43
  OUT ($B8),A
  LD A,$05
  CALL SET_CLOCK_HL_4
  LD A,$ED
  OUT ($BA),A
  LD A,($FE43)
  CALL __MENU_04
  CALL GET_DEVICE_566
  CALL INIT_LCD_ADDR
  XOR A
  OUT ($FE),A
  CALL INIT_LCD_ADDR
  LD A,$3B
  OUT ($FE),A
  CALL LCD_INIT_3E
  CALL INIT_LCD_ADDR
  LD A,$39
  OUT ($FE),A
  EI
  POP AF
  RET Z
  CALL __MENU_03
  LD A,($FEC1)
  CP $02
  RET NC
  CALL GET_DEVICE_582
  CALL GET_DEVICE_581
  LD A,($FEC1)
  DEC A
  CALL NZ,GET_DEVICE_589
  RET

; This entry point is used by the routine at GETWORD.
PRS_ABORTMSG7:
  PUSH BC
  LD C,A
PRS_ABORTMSG8:
  CALL BREAK
  JP C,$6DBF
  IN A,($BB)
  AND $06
  XOR $02
  JP NZ,PRS_ABORTMSG8
  CALL SETINT_1D
  LD A,C
  OUT ($B9),A		; I/O port select
  LD A,(ROMSEL)
  LD B,A
  OR $20
  NOP
  OUT ($90),A
  LD A,B
  OUT ($90),A
  PUSH BC
  LD C,$06
  CALL CALLHL1
PRS_ABORTMSG9:
  POP BC
  LD A,$09
  JR NC,$6E39
  POP BC
  RET

; Check RS232 queue for characters, Z if no data, A = number of chars in queue
;
; Used by the routines at EXEC_EVAL_0, TEL_TERM, TEL_UPLD and RV232C.
RCVX:
  LD A,(XONXOFF_FLG)
  OR A
  JP Z,RCVX_0
  LD A,(XONXOFF)
  INC A
  RET Z
RCVX_0:
  LD A,(RS232_COUNT)
  OR A
  RET

; Get from RS232, A = char, Z if OK, CY if BREAK
;
; Used by the routines at COM_INPUT, TEL_LOGON, TEL_TERM and TEL_UPLD.
RV232C:
  PUSH HL
  PUSH DE
  PUSH BC
  LD HL,POPALL_INT+1
  PUSH HL
  LD HL,RS232_COUNT
RV232C_0:
  CALL GET_DEVICE_580
  CALL RCVX
  JP Z,RV232C_0
  CP $03
  CALL C,SENDCQ
  DI
  DEC (HL)
  CALL _UART_2
  LD A,(HL)
  EX DE,HL
  INC HL
  INC HL
  INC (HL)
  DEC (HL)
  RET Z
  DEC (HL)
  JP Z,RV232C_1
  CP A
  RET
RV232C_1:
  OR $FF
  RET

; RST 6.5 (RS232 Interrupt on received character) routine
;
; Used by the routine at RST65.
_UART:
  CALL UART
  PUSH HL
  PUSH DE
  PUSH BC
  PUSH AF
  LD HL,POPALL_INT
  PUSH HL
  IN A,($C8)
  LD HL,COMMSK
  AND (HL)
  LD C,A
  IN A,($D8)
  AND $0E
  LD B,A
  JP NZ,_UART_0
  LD A,C
  CP $11	; XON
  JP Z,$6E26
  CP $13	; XOFF
  JP NZ,_UART_0
  LD A,$AF
  LD (ENDLCD),A
  LD A,(XONXOFF_FLG)
  OR A
  RET NZ

_UART_0:
  LD A,($FE43)
  CP $03
  JP NZ,DWNLDR_68
  LD A,($F40B)
  CP $53
  JP NZ,DWNLDR_68
  LD HL,$F9B8
  LD A,C
  SUB $0F
  JP NZ,DWNLDR_67
  LD (HL),A
  RET

DWNLDR_67:
  INC A
  JP NZ,DWNLDR_68
  LD (HL),$80
  RET

DWNLDR_68:
  LD HL,RS232_COUNT
  LD A,(HL)
  CP $FF
  RET Z
  CP $E7
  CALL NC,SENDCS
  PUSH BC
  INC (HL)
  INC HL
  CALL _UART_2
  POP BC
  LD A,($F40B)
  CP $53
  JP NZ,DWNLDR_69
  LD A,C
  CP ' '
  JP C,GET_DEVICE_410
DWNLDR_69:
  LD A,($F9B8)
  OR C
GET_DEVICE_410:
  LD (HL),A
  LD A,B
  OR A
  RET Z
  EX DE,HL
  INC HL
  DEC (HL)
  INC (HL)
  RET NZ
  LD A,(RS232_COUNT)
  LD (HL),A
  RET
  
_UART_2:
  INC HL
  LD C,(HL)
  LD A,C
  INC A
  CP $FF
  JP C,GET_DEVICE_412
  XOR A
GET_DEVICE_412:
  LD (HL),A
  EX DE,HL
  LD HL,RS232_BUF
  LD B,$00
  ADD HL,BC
  RET

; Send CTRL-Q character (X-ON)
;
; Used by the routine at RV232C.
SENDCQ:
  LD A,(XONXOFF_FLG)
  AND A
  RET Z
  LD A,(CTRL_S_FLG)
  DEC A
  RET NZ
  LD (CTRL_S_FLG),A
  PUSH BC
  LD C,$11
  JP _SD232C_DELAYED

; Send CTRL-S character (X-OFF)
;
; Used by the routine at _UART.
SENDCS:
  LD A,(XONXOFF_FLG)
  AND A
  RET Z
  LD A,(CTRL_S_FLG)
  OR A
  RET NZ
  INC A
  LD (CTRL_S_FLG),A
  PUSH BC
  LD C,$13		; XOFF
  JP _SD232C

; This entry point is used by the routine at GETWORD.
SD232C:
  RST $38
  LD D,D
  PUSH BC
  LD C,A
  LD A,($F40B)
  CP $53
  JP NZ,GET_DEVICE_416
  LD A,($F9B7)
  XOR C
  LD A,C
  LD ($F9B7),A
  JP P,GET_DEVICE_416
  ADD A,A
  SBC A,A
  ADD A,$0F
  CALL SD232C
GET_DEVICE_416:
  LD A,C
  POP BC
  
  

; Send to RS232, A = char
;
; Used by the routines at COM_OUTPUT, TEL_LOGON, TEL_TERM and TEL_UPLD.
SD232C:
  PUSH BC
  LD C,A
  CALL _SD232C_1
  JP C,_SD232C_0


_SD232C_DELAYED:
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  
_SD232C:
  IN A,($D8)
  AND $10
  JP Z,_SD232C
  LD A,C
  OUT ($C8),A
  
_SD232C_0:
  LD A,C
  POP BC
  RET

_SD232C_1:
  LD A,(XONXOFF_FLG)
  OR A
  RET Z
  LD A,C
  CP $11
  JP NZ,_SD232C_2
  XOR A
  LD (CTRL_S_FLG),A
  JP _SD232C_3
  
_SD232C_2:
  SUB $13
  JP NZ,_SD232C_4
  DEC A
_SD232C_3:
  LD (XONXOFF),A
  RET
  
_SD232C_4:
  CALL BREAK
  RET C
  LD A,(ENDLCD)
  OR A
  JP NZ,_SD232C_4
  RET


; Set baud rate, H = 0..9
;
; Used by the routine at INZCOM.
BAUDST:
  PUSH HL
  LD A,H
  RLCA
  LD HL,BAUD_TBL-2
  LD D,$00
  LD E,A
  ADD HL,DE
  LD (RS232_BAUD),HL
  POP HL
; This entry point is used by the routine at MUSIC.
BAUDST_0:
  PUSH HL
  LD HL,(RS232_BAUD)
  LD A,(HL)
  OUT ($BC),A
  INC HL
  LD A,(HL)
  OUT ($BD),A
  LD A,$C3
  OUT ($B8),A
  POP HL
  RET

; Start of 18 byte RS232 baud rate timer values (words).
BAUD_TBL:
  DEFW $4800
  DEFW $456B
  DEFW $4200
  DEFW $4100
  DEFW $4080
  DEFW $4040
  DEFW $4020
  DEFW $4010
  DEFW $4008



; Routine at 28498
;
; Used by the routine at L76E6.
L6F52:
  LD A,$01
  LD BC,$023E
  LD BC,$033E
  PUSH HL
  PUSH DE
  PUSH BC
  PUSH AF
  CP $03
  JP Z,INZCOM_0
  CALL $6F8E
  LD BC,$C0FF
  LD HL,$091C
INZCOM_0:
  DI
  LD A,C
  LD (COMMSK),A
  POP AF
  PUSH AF
  CALL __MENU_04
  
  CALL BAUDST
  IN A,($BA)
  AND $3F
  OR B
  OUT ($BA),A
  IN A,($D8)
  LD A,L
  AND $1F
  OUT ($D8),A
  CALL RES_RS232_FLAGS
  JP POPALL_INT

; This entry point is used by the routine at GETWORD.
_XONXOFF_FLG:
  LD A,$AF
  DI
_XONXOFF_SETFLG:
  LD (XONXOFF_FLG),A
  EI
  RET
  
RES_RS232_FLAGS:
  XOR A
  LD L,A
  LD H,A
  LD (ENDLCD),HL
  LD (RS232_COUNT),HL
  LD ($FE47),HL
  LD ($F9B7),HL
  LD (CTRL_S_FLG),A
  RET

; This entry point is used by the routine at GETWORD.
__MENU_02:
  IN A,($BA)
  OR $C0
  OUT ($BA),A
__MENU_03:
  XOR A
  LD ($FEC2),A
  
__MENU_04:
  RST $38
  LD D,H
  PUSH BC
  LD C,A
  OR A
  JP Z,__MENU_05
  LD A,($FE43)
  OR A
  JP Z,__MENU_05
  CP C
  JP NZ,$056E
  
__MENU_05:
  LD A,C
  LD ($FE43),A
  RRCA
  RRCA
  LD C,A
  LD A,(ROMSEL)
  AND $3F
  OR C
  LD (ROMSEL),A
  OUT ($90),A
  POP BC
  RET

; This entry point is used by the routine at GETWORD.
DATAR_1:
  LD A,(ROMSEL)
  AND $F7
  INC E
  DEC E
  JP Z,DATAR_2
  OR $08
DATAR_2:
  OUT ($90),A
  LD (ROMSEL),A
  RET

; This entry point is used by the routine at GETWORD.
DATAW:
  LD C,A
  LD DE,$00A5
  CALL __MENU_04
  IN A,($B9)
  ADD A,$00
  LD B,$08
__MENU_09:
  NOP
  NOP
  LD HL,($0000)
  INC DE
  LD A,C
  RRA
  LD C,A
  JP C,__MENU_02
  ADD A,$00
  LD DE,$00A5
  CALL __MENU_04
  IN A,($B9)
__MENU_00:
  DEC B
  JP NZ,__MENU_09
  LD A,$03
__MENU_01:
  DEC A
  JP NZ,__MENU_01
  LD A,($0000)
  LD DE,$00A8
  CALL __MENU_03
  NOP
  NOP
  LD DE,$00A8
  CALL __MENU_03
  JP BREAK
__MENU_02:
  NOP
  LD DE,$00A5
  CALL __MENU_03
  JP __MENU_00
__MENU_03:
  LD A,$D0
  JP __MENU_05
__MENU_04:
  IN A,($B9)
  LD A,$50
__MENU_05:
  JR NC,$705C
  LD A,D
  OR E
  JP NZ,$7040
  RET
  
; This entry point is used by the routine at GETWORD.
__MENU_06:
  CALL __MENU_04
  LD BC,5240
  CALL DELAY_BC
  CALL __MENU_03
  LD BC,1000
  JP DELAY_BC

; Read cassette header and sync byte only
;
; Used by the routine at HEADER.SYNCR:
SYNCR:
  LD D,$00
SYNCR_0:
  CALL __MENU_17
  RET C
  LD A,H
  RLA
  JP C,SYNCR
  INC D
  JP NZ,SYNCR_0
__MENU_09:
  LD D,$00
__MENU_10:
  CALL __MENU_17
  RET C
  LD A,H
  AND A
  JP P,__MENU_09
  INC D
  JP P,__MENU_10
  RET

__MENU_11:
  LD E,$00
__MENU_12:
  CALL BREAK
  RET C
  JR NZ,__MENU_14
  JP NC,__MENU_12
__MENU_13:
  INC E
  JP Z,__MENU_11
__MENU_14:
  JR NZ,$7090
  JP C,__MENU_13
  XOR A
  RET

; This entry point is used by the routine at GETWORD.
DATAR:
  CALL __MENU_11
  RET C
  LD A,$14
  CP E
  JP NC,DATAR
  CALL __MENU_11
  RET C
  LD A,$14
  CP E
  JP NC,DATAR
  LD L,$08
__MENU_16:
  CALL __MENU_17
  RET C
  DEC L
  JP NZ,__MENU_16
  LD A,H
  CP H
  RET
  
__MENU_17:
  CALL __MENU_11
  RET C
  LD B,E
  CALL __MENU_11
  RET C
  LD A,B
  ADD A,E
  CP $28
  JP NC,__MENU_18
  CALL __MENU_11
  RET C
  CALL __MENU_11
  RET C
  SCF
__MENU_18:
  LD A,H
  RRA
  LD H,A
  XOR A
  RET
  
L70CD:
  LD HL,_RST75_END
  PUSH HL
  LD HL,KBSITP
  DEC (HL)
  RET NZ
  LD (HL),$03
  LD HL,KYDATA+8
  LD DE,KB_SHIFT
  ; BRK_SCAN
  LD A,$FF
  OUT ($B9),A		; I/O port select
  IN A,($BA)
  AND $FE
  OUT ($BA),A
  IN A,($E8)
  PUSH AF
  IN A,($BA)
  INC A
  OUT ($BA),A
  POP AF
  CPL
  CP (HL)
  LD (HL),A
  JP NZ,__MENU_19
  LD A,(DE)
  LD B,A
  LD A,(HL)
  LD (DE),A
__MENU_19:
  XOR A
  OUT ($B9),A		; I/O port select
  IN A,($E8)
  INC A
  LD A,$FF
  OUT ($B9),A		; I/O port select
  JP Z,__MENU_44
  LD A,$7F
  LD C,$07
__MENU_20:
  LD B,A
  OUT ($B9),A		; I/O port select
  IN A,($E8)
  CPL
  DEC HL
  DEC DE
  CP (HL)
  LD (HL),A
  LD A,$FF
  OUT ($B9),A		; I/O port select
  JP NZ,__MENU_21
  LD A,(DE)
  CP (HL)
  CALL NZ,__MENU_22
__MENU_21:
  LD A,B
  RRCA
  DEC C
  JP P,__MENU_20
  DEC HL
  LD (HL),$02
  LD HL,KYWHAT
  DEC (HL)
  JP Z,__MENU_28
  INC (HL)
  RET M
  LD A,(KYWHAT+2)
  LD HL,(KYWHAT+3)
  AND (HL)
  RET Z
  LD A,(KYBCNT)
  CP $02
  RET NC
  LD HL,KYREPT
  DEC (HL)
  RET NZ
  LD (HL),$06
  LD A,$01
  LD (CSRCNT),A
  JP __MENU_29
  
__MENU_22:
  PUSH BC
  PUSH HL
  PUSH DE
  LD B,A
  LD A,$80
  LD E,$07
__MENU_23:
  LD D,A
  AND (HL)
  JP Z,__MENU_24
  AND B
  JP Z,__MENU_26
__MENU_24:
  LD A,D
  RRCA
  DEC E
  JP P,__MENU_23
  POP DE
__MENU_25:
  POP HL
  LD A,(HL)
  LD (DE),A
  POP BC
  RET
  
__MENU_26:
  LD HL,KYWHAT
  INC A
  CP (HL)
  JP NZ,__MENU_27
  POP DE
  POP HL
  POP BC
  RET
  
__MENU_27:
  LD (HL),A
  LD A,C
  RLCA
  RLCA
  RLCA
  OR E
  INC HL
  LD (HL),A
  INC HL
  LD (HL),D
  POP DE
  EX DE,HL
  LD (KYWHAT+3),HL
  EX DE,HL
  JP __MENU_25
  
__MENU_28:
  DEC HL
  LD (HL),$54
  DEC HL
  LD A,(KB_SHIFT)
  LD (HL),A
__MENU_29:
  LD HL,$7224
  PUSH HL
  LD HL,KYWHAT+1
  LD A,(HL)
  LD C,A
  LD DE,$002E
  LD B,D
  CP $35
  LD A,B
  SBC A,B
  INC HL
  AND (HL)
  LD (HL),A
  LD A,(KYHOW)
  RRCA
  PUSH AF
  LD A,C
  CP E
  JP C,__MENU_32
  POP AF
  LD E,A
  RRCA
  JP NC,__MENU_30
  LD A,C
  CP $31
  JP C,__MENU_30
  CP $35
  LD HL,$71EA
  JP C,__MENU_31
__MENU_30:
  LD HL,$7BFD
  LD A,E
  RLCA
  JP NC,__MENU_31
  LD HL,$7C0F
__MENU_31:
  ADD HL,BC
  LD A,(HL)
  RET
__MENU_32:
  POP AF
  LD E,B
  JP NC,__MENU_33
  LD E,$15
__MENU_33:
  PUSH AF
  LD HL,$7BE9
  AND $20
  JP Z,__MENU_34
  LD HL,GET_DEVICE_646
__MENU_34:
  ADD HL,BC
  POP AF
  RRCA
  JP C,__MENU_37
  RRCA
  JP C,GET_DEVICE_621
  DEC E
  JP P,__MENU_36
  AND $02
__MENU_35:
  LD A,(HL)
  RET Z
  JP GET_DEVICE_629
__MENU_36:
  LD A,C
  CP $1A		; EOF
  JP C,__MENU_35
  ADD HL,DE
  LD A,(HL)
  RET
__MENU_37:
  AND $10
  LD A,C
  LD C,$1B
  CALL NZ,__MENU_38
  CP C
  LD A,(HL)
  JP C,$721F
  XOR A
  RET
__MENU_38:
  DEC C
  CP '"'
  RET NZ
  XOR A
  RET
  RLA
  LD A,(DE)
  LD DE,$7E12
  AND $1F
  POP HL
  JP C,CALLHL8
  LD C,A
  SUB $F0
  JP C,__MENU_39
  LD C,A
  JP __MENU_41
__MENU_39:
  LD A,C
  CP $11
  JP Z,__MENU_40
  AND $EF
  CP $03
  JP NZ,__MENU_42
__MENU_40:
  LD A,(FNK_FLAG)
  AND $C0
  JP NZ,__MENU_42
  LD A,C
  LD (BRKCHR),A
  CP $03
  RET NZ
  LD HL,KYBCNT
  LD (HL),$00
  INC B
__MENU_41:
  DEC B
__MENU_42:
  LD HL,KYBCNT
  LD A,(HL)
  CP ' '
  RET NC
  INC (HL)
  RLCA
  INC HL
  LD E,A
  ADD HL,DE
  LD (HL),C
  INC HL
  LD (HL),B
  POP AF
  
_RST75_END:
  LD A,$09
  
  ; THIS IS A COMPLEX OPTIMIZATION,
  ; THE RELATIVE JP OFFSET IS EQUIVALENT TO "POP AF" !
  ;
  ; Moving the code in this ROM is not definitely a beginner's task..
  ;
  ;JR NC,$7258
  defb $30		; JR NC,N

; POP AF, BC, DE, and HL off stack, enable interrupts and return.
;
; Used by the routines at INZCOM and MUSIC.
POPALL_INT:
  POP AF
;
  POP BC
  POP DE
  POP HL
  EI
  RET

__MENU_44:
  LD HL,REPCNT
  DEC (HL)
  RET NZ
  LD HL,KYDATA
  LD B,$11
  JP ZERO_MEM

; This entry point is used by the routine at GETWORD.
__MENU_45:
  CALL SETINT_1D
  LD A,(KYBCNT)
  OR A
  JP Z,EI_NORM
  LD HL,KYRDBF+1
  LD A,(HL)
  ADD A,$02
  DEC HL
  LD A,(HL)
  PUSH AF
  DEC HL
  DEC (HL)
  LD A,(HL)
  RLCA
  LD C,A
  LD DE,KYRDBF+2
  INC HL
KYREAD_0:
  DEC C

  defb $FA  ; JP M,KYREAD_1

KYREAD_1:
  LD L,C
  LD (HL),D
  LD A,(DE)
  LD (HL),A
  INC HL
  INC DE
  JP KYREAD_0
  
EI_NORM:
  PUSH AF
EI_NORM_0:
  LD A,$09
  JR NC,KYREAD_1
  RET
  
; This entry point is used by the routine at GETWORD.
KEYX:
  CALL BRKCHK
  JP Z,KEYX_0
  CP $03
  JP NZ,KEYX_0
  OR A
  SCF
  RET
  
KEYX_0:
  LD A,(KYBCNT)
  OR A
  RET

; This entry point is used by the routine at GETWORD.
BRKCHK:
  PUSH HL
  LD A,(LABEL_LN)
  OR A
  JP Z,BRKCHK_0
  LD A,(KB_SHIFT)
  LD L,A
  LD A,(FNKSTS)
  XOR L
  AND $01
  JP Z,BRKCHK_0
  AND L
  PUSH DE
  PUSH BC
  CALL DSPFNK_0
  POP BC
  POP DE
BRKCHK_0:
  LD HL,BRKCHR
  LD A,(HL)
  LD (HL),$00
  POP HL
  OR A
  RET

BREAK:
  PUSH BC
  IN A,($BA)
  LD B,A
  OR $01
  OUT ($BA),A
  IN A,($B9)		; I/O port select
  LD C,A
  LD A,$7F
  OUT ($B9),A		; I/O port select
  IN A,($E8)
  PUSH AF
  LD A,$FF
  OUT ($B9),A		; I/O port select
  LD A,B
  AND $FE
  OUT ($BA),A
  IN A,($E8)
  RRCA
  LD A,C
  OUT ($B9),A		; I/O port select
  LD A,B
  OUT ($BA),A
  POP BC
  LD A,B
  RRA
  AND $C0
  POP BC
  RET NZ
  INC A
  SCF
  RET
  
; This entry point is used by the routine at GETWORD.
MUSIC:
  DI
  LD A,E
  OUT ($BC),A
  LD A,D
  OR $40
  OUT ($BD),A
  LD A,$C3
  OUT ($B8),A
  IN A,($BA)
  AND $F8
  OR $20
  OUT ($BA),A
MUSIC_0:
  CALL BREAK
  JP NC,MUSIC_1
  LD A,$03
  LD (BRKCHR),A
  JP MUSIC_3

MUSIC_1:
  PUSH BC
  LD BC,$012F
  CALL DELAY_BC
  POP BC
  DEC B
  JP NZ,MUSIC_0
MUSIC_3:
  IN A,($BA)
  OR $04
  OUT ($BA),A
  CALL BAUDST_0
  EI
  RET
  
DELAY_BC:
  LD A,C
DELAY_BC_1:
  PUSH BC
  LD C,$48
DELAY_BC_2:
  DEC C
  JP NZ,DELAY_BC_2
  POP BC
  DEC A
  JP NZ,DELAY_BC_1
  DEC B
  JP NZ,DELAY_BC
  RET


; Load the contents of the clock chip registers into the address pointed to by
; HL.
;
; Used by the routines at READ_CLOCK and _RST75.
READ_CLOCK_HL:
  defb $f6		; OR $AF


; Update the clock chip internal registers with the time in the buffer pointed
; to by HL
;
; Used by the routines at SET_CLOCK and BOOT.
SET_CLOCK_HL:
  XOR A
  PUSH AF
  CALL SETINT_1D
  LD A,$03
  CALL NZ,SET_CLOCK_HL_4
  LD A,$01
  CALL SET_CLOCK_HL_4
  LD C,$07
  CALL DELAY_C
  LD B,$0A
__MENU_63:
  LD C,$04
  LD D,(HL)
__MENU_64:
  POP AF
  PUSH AF
  JP Z,__MENU_65
  IN A,($BB)
  RRA
  LD A,D
  RRA
  LD D,A
  XOR A
  JP __MENU_66

__MENU_65:
  LD A,D
  RRCA
  LD D,A
  LD A,$10
  RRA
  RRA
  RRA
  RRA
  OUT ($B9),A		; I/O port select
__MENU_66:
  OR $09
  OUT ($B9),A		; I/O port select
  AND $F7
  OUT ($B9),A		; I/O port select
  DEC C
  JP NZ,__MENU_64
  LD A,D
  RRCA
  RRCA
  RRCA
  RRCA
  AND $0F
  LD (HL),A
  INC HL
  DEC B
  JP NZ,__MENU_63
  POP AF
  LD A,$02
  CALL Z,SET_CLOCK_HL_4
  XOR A
  CALL SET_CLOCK_HL_4
  JP SET_CLOCK_HL_16
  
; This entry point is used by the routine at IOINIT.
SET_CLOCK_HL_4:
  OUT ($B9),A		; I/O port select
  LD A,(ROMSEL)
  OR $10
  OUT ($90),A
  AND $EF
  OUT ($90),A
  RET

; This entry point is used by the routine at GETWORD.
_RST75_7:
  CALL SETINT_1D
  LD HL,L70CD
  PUSH HL
  LD HL,CSRCNT
  DEC (HL)
  RET NZ
  LD (HL),$7D
  DEC HL
  LD A,(HL)
  OR A
  JP P,_RST75_8
  RET PO
_RST75_8:
  XOR $01
  LD (HL),A
  
; -- extra code, missing on other platforms
  LD A,(CSTYLE)
  OR A
  JP Z,PUT_SHAPE
  PUSH HL
  CALL __MENU_91
  LD A,(CSRSTS)
  RRCA
  JP NC,PUT_SHAPE_2
  PUSH DE
  LD A,(RVSCUR)
  LD E,A
  LD A,$06
  LD HL,SHAPE2
  LD BC,SHAPE
  PUSH BC
__MENU_70:
  PUSH AF
  LD A,(HL)
  OR E
  LD (BC),A
  INC BC
  INC HL
  POP AF
  DEC A
  JP NZ,__MENU_70
  POP HL
  POP DE
  JP PUT_SHAPE_1
; -- extra code, missing on other platforms
  
; This entry point is used by the routines at ESC_J and DOTTED_FNAME.
PUT_SHAPE:
  PUSH HL
  LD HL,SHAPE
  LD D,$00
  CALL LOAD_SHAPE
  LD B,$06
  DEC HL
PUT_SHAPE_0:
  LD A,(HL)
  CPL
  LD (HL),A
  DEC HL
  DEC B
  JP NZ,PUT_SHAPE_0
  INC HL
PUT_SHAPE_1:
  LD D,$01
  CALL LOAD_SHAPE
PUT_SHAPE_2:
  POP HL
  RET

; This entry point is used by the routine at ISFLIO.
__MENU_75:
  OR $AF
; This entry point is used by the routine at ISFLIO.
__MENU_76:
  PUSH HL
  PUSH DE
  PUSH BC
  PUSH AF
  CALL SETINT_1D
  LD HL,CSRSTS
  LD A,(HL)
  RRCA
  LD (HL),$80
  CALL C,__MENU_91
  POP AF
  PUSH AF
  JP Z,_RST75_END
  LD D,$00
  CALL LOAD_SHAPE2
  XOR A
  LD (CSRSTS),A
  INC A
  LD (CSRCNT),A
  JP _RST75_END
  
; This entry point is used by the routine at ISFLIO.
INIT_LCD:
  CALL SETINT_1D
  LD HL,$0000
  ADD HL,SP
  LD (SAVSP),HL
  DEC D
  DEC E
  EX DE,HL
  LD (LCD_ADDR),HL
  LD A,C
  ;LD DE,$78B7
  LD DE,FONT-1
  SUB $20
  JP Z,__MENU_82

  CP $60
  ;defb $fe	; CP NN  
  ;LD H,B
  
  JP NC,__MENU_79
  LD HL,$7AFF
  LD B,$09
__MENU_78:
  CP (HL)
  JP Z,GET_DEVICE_624
  INC HL
  DEC B
  JP NZ,__MENU_78
  SCF
  JP __MENU_82
__MENU_79:
  SUB $63
  JP NC,__MENU_80
  ADD A,$53
  OR A
  JP __MENU_82

__MENU_80:
  LD B,A
  DEC DE
  LD HL,(GCPNTR)
SET_CLOCK_HL_12:
  LD A,L
  OR H
  JP Z,__MENU_82
  EX DE,HL
  LD A,B
__MENU_82:
  PUSH AF
  LD L,A
  LD H,$00
  LD B,H
  LD C,L
  ADD HL,HL
  ADD HL,HL
  ADD HL,BC		; *5
  POP AF
  PUSH AF
  JP C,ASCII_SYMBOL
  ADD HL,BC		; *6
ASCII_SYMBOL:
  ADD HL,DE
  POP AF
  JP NC,GFX_SYMBOL
  LD DE,SHAPE
  PUSH DE
  LD B,$05
  CALL LDIR_B
  XOR A
  LD (DE),A
  POP HL
GFX_SYMBOL:
  LD D,$01
  CALL LOAD_SHAPE
SET_CLOCK_HL_15:
  XOR A
  LD (GFX_TEMP+3),A
  CALL LCD_INIT_3E
SET_CLOCK_HL_16:
  LD A,$09
  JR NC,SET_CLOCK_HL_12
  
; Move cursor to specified position
;
; Used by the routines at OUTC_SUB and DOTTED_FNAME.
MOVE_CURSOR:
  CALL SETINT_1D
  DEC D
  DEC E
  EX DE,HL
  LD (LCD_ADDR),HL
  JP SET_CLOCK_HL_16

; Plot point on screen  (D,E)
;
; Used by the routine at __PSET.
;
; D = X position (0..239), E = Y position (0..63)
PLOT:
  defb $f6		; OR $AF

; Reset point on screen  (D,E)
;
; Used by the routine at __PSET.
UNPLOT:
  XOR A
  PUSH AF		; Save flags to choose between PLOT and UNPLOT
  CALL SETINT_1D
  PUSH DE
  LD C,$FE
  LD A,D
__MENU_89:
  INC C
  INC C
  LD D,A
  SUB $32
  JP NC,__MENU_89
  LD B,$00
  LD HL,PLOT_TBL
  LD A,E
  RLA
  RLA
  RLA
  JP NC,__MENU_90
  
  LD HL,PLOT_TBL2
  
__MENU_90:
  ADD HL,BC
  LD B,A
  CALL SET_LCD_ADDR
  LD A,B
  AND $C0
  OR D
  LD B,A
  LD E,$01
  LD HL,SHAPE
  CALL SET_LCD
  POP DE
  LD D,B
  LD A,E
  AND $07
  ADD A,A
  LD C,A
  LD B,$00
  LD HL,PLOT_TBL
  ADD HL,BC
  POP AF
  LD A,(HL)
  LD HL,SHAPE
  JP NZ,$751B
  CPL
  AND (HL)

  DEFB $06	; LD B,N
L7497:

  LD B,$B6
  LD (HL),A
  LD B,D
  LD E,$01
  CALL GET_LCD
  JP SET_CLOCK_HL_16

__MENU_91:
  LD D,$01
LOAD_SHAPE2:
  LD HL,SHAPE2
  
;
; Used by the routines at SET_CLOCK_HL and L7409, D=??.
LOAD_SHAPE:
  PUSH HL
  LD E,$06
  LD A,(LCD_ADDR+1)
  CP $08
  JP Z,LOAD_SHAPE_0
  CP $10
  JP Z,LOAD_SHAPE_1
  CP $21
  JP NZ,LOAD_SHAPE_2
LOAD_SHAPE_0:
  DEC E
  DEC E
LOAD_SHAPE_1:
  DEC E
  DEC E
LOAD_SHAPE_2:
  LD C,A
  ADD A,C
  ADD A,C
  LD C,A
  LD B,$00
  LD A,(LCD_ADDR)
  RRA
  RRA
  RRA
  LD HL,GFX_VECT2
  JP C,LOAD_SHAPE_3
  LD HL,GFX_VECT

LOAD_SHAPE_3:
  ADD HL,BC
  LD B,A
  CALL SET_LCD_ADDR
  LD (GFX_TEMP),HL
  LD A,B
  OR (HL)
  LD B,A
  POP HL
  DEC D
  CALL SEND_LCD
  INC D
  LD A,$06
  SUB E
  RET Z
  LD E,A
  PUSH HL
  LD HL,(GFX_TEMP)
  INC HL
  CALL SET_LCD_ADDR
  POP HL
  LD A,B
  AND $C0
  LD B,A
  DEC D

  defb $da		; JP C,NN

SET_LCD:
	DEFB $F6	;OR $AF (masks XOR A)

; This entry point is used by the routine at UNPLOT.

; Rebuild graphics character code to finalize PLOT/UNPLOT
GET_LCD:
  XOR A
  
; This entry point is used by the routine at L7497.
SEND_LCD:
  PUSH DE
  PUSH AF
  LD A,B
  CALL WAIT_LCD
  OUT ($FE),A
  JP Z,UNPLOT_8
  CALL WAIT_LCD
  IN A,($FF)
UNPLOT_8:
  POP AF
  JP NZ,DO_GET_LCD

DO_SEND_LCD:
  IN A,($FE)
  RLA
  JP C,DO_SEND_LCD
  LD A,(HL)
  OUT ($FF),A
  INC HL
  DEC E
  JP NZ,DO_SEND_LCD
  POP DE
  RET

DO_GET_LCD:
  IN A,($FE)
  RLA
  JP C,DO_GET_LCD
  IN A,($FF)
  LD (HL),A
  INC HL
  DEC E
  JP NZ,DO_GET_LCD
  POP DE
  RET

LCD_INIT_3E:
  CALL INIT_LCD_ADDR
  LD A,$3E
  OUT ($FE),A
  RET

INIT_LCD_ADDR:
  LD C,$03
  CALL DELAY_C
  LD HL,$76CA		; OUT ($B9),$FF, OR $03

SET_LCD_ADDR:
  LD A,(HL)
  OUT ($B9),A		; I/O port select
  INC HL
  IN A,($BA)
  AND $FC
  OR (HL)
  OUT ($BA),A
  INC HL
  RET

WAIT_LCD:
  PUSH AF
__MENU_106:
  IN A,($FE)
  RLA
  JP C,__MENU_106
  POP AF
  RET


; Data block at 30170
GFX_VECT:
  DEFB $01, $00, $00
  DEFB $01, $00, $06
  DEFB $01, $00, $0C
  DEFB $01, $00, $12
  DEFB $01, $00, $18
  DEFB $01, $00, $1E
  DEFB $01, $00, $24
  DEFB $01, $00, $2A
  DEFB $01, $00, $30
  DEFB $02, $00, $04
  DEFB $02, $00, $0A
  DEFB $02, $00, $10
  DEFB $02, $00, $16
  DEFB $02, $00, $1C
  DEFB $02, $00, $22
  DEFB $02, $00, $28
  DEFB $02, $00, $2E
  DEFB $04, $00, $02
  DEFB $04, $00, $08
  DEFB $04, $00, $0E
  DEFB $04, $00, $14
  DEFB $04, $00, $1A
  DEFB $04, $00, $20
  DEFB $04, $00, $26
  DEFB $04, $00, $2C
  DEFB $08, $00, $00
  DEFB $08, $00, $06
  DEFB $08, $00, $0C
  DEFB $08, $00, $12
  DEFB $08, $00, $18
  DEFB $08, $00, $1E
  DEFB $08, $00, $24
  DEFB $08, $00, $2A
  DEFB $08, $00, $30
  DEFB $10, $00, $04
  DEFB $10, $00, $0A
  DEFB $10, $00, $10
  DEFB $10, $00, $16
  DEFB $10, $00, $1C
  DEFB $10, $00, $22
  
; Data block at 30290
GFX_VECT2:
  DEFB $20, $00, $00
  DEFB $20, $00, $06
  DEFB $20, $00, $0C
  DEFB $20, $00, $12
  DEFB $20, $00, $18
  DEFB $20, $00, $1E
  DEFB $20, $00, $24
  DEFB $20, $00, $2A
  DEFB $20, $00, $30
  DEFB $40, $00, $04
  DEFB $40, $00, $0A
  DEFB $40, $00, $10
  DEFB $40, $00, $16
  DEFB $40, $00, $1C
  DEFB $40, $00, $22
  DEFB $40, $00, $28
  DEFB $40, $00, $2E
  DEFB $80, $00, $02
  DEFB $80, $00, $08
  DEFB $80, $00, $0E
  DEFB $80, $00, $14
  DEFB $80, $00, $1A
  DEFB $80, $00, $20
  DEFB $80, $00, $26
  DEFB $80, $00, $2C
  DEFB $00, $01, $00
  DEFB $00, $01, $06
  DEFB $00, $01, $0C
  DEFB $00, $01, $12
  DEFB $00, $01, $18
  DEFB $00, $01, $1E
  DEFB $00, $01, $24
  DEFB $00, $01, $2A
  DEFB $00, $01, $30
  DEFB $00, $02, $04
  DEFB $00, $02, $0A
  DEFB $00, $02, $10
  DEFB $00, $02, $16
  DEFB $00, $02, $1C
  DEFB $00, $02, $22
  


; Data block at 30412
PLOT_TBL:
  DEFB $01, $00
  DEFB $02, $00
  DEFB $04, $00
  DEFB $08, $00
  DEFB $10, $00
  
; Data block at 30422 ($76D6)
PLOT_TBL2:
  DEFB $20, $00
  DEFB $40, $00
  DEFB $80, $00
  DEFB $00, $01
  DEFB $00, $02
  

DELAY_C:
  DEC C
  JP NZ,DELAY_C
  RET

; Set interrupt to 1DH
;
; Used by the routines at PRINTR, KYREAD, SET_CLOCK_HL, MOVE_CURSOR, PLOT, UNPLOT and
; _BEEP.
SETINT_1D:
  DI
  LD A,$1D
  JR NC,SETINT_1D
  RET

;_BEEP:
  CALL SETINT_1D
  LD B,$00
_BEEP_0:
  CALL _CLICK
  LD C,$50
  CALL DELAY_C
  DEC B
  JP NZ,_BEEP_0
  JP SET_CLOCK_HL_16

_CLICK:
  IN A,($BA)
  XOR $20
  OUT ($BA),A
  RET

GET_DEVICE_565:
  CALL GET_DEVICE_570
  RET Z
GET_DEVICE_566:
  LD A,$91
  OUT ($73),A
  CALL GET_DEVICE_570
  RET NZ
  LD C,$00
  LD A,$0F
  OUT ($73),A
GET_DEVICE_567:
  CALL GET_DEVICE_580
  IN A,($72)
  AND $02
  JP Z,GET_DEVICE_567
  LD A,$0E
  OUT ($73),A
  LD A,C
  OUT ($71),A
  LD A,$09
  OUT ($73),A
GET_DEVICE_568:
  CALL GET_DEVICE_580
  IN A,($72)
  AND $04
  JP Z,GET_DEVICE_568
  LD A,$08
  OUT ($73),A
GET_DEVICE_569:
  CALL GET_DEVICE_580
  IN A,($72)
  AND $04
  JP NZ,GET_DEVICE_569
  RET
  
GET_DEVICE_570:
  PUSH BC
  LD A,$55
  LD B,A
  OUT ($71),A
  IN A,($71)
  CP B
  POP BC
  RET
  
GET_DEVICE_571:
  LD A,$0B
  OUT ($73),A
GET_DEVICE_572:
  CALL GET_DEVICE_580
  IN A,($72)
  AND $01
  JP Z,GET_DEVICE_572
  LD A,$0A
  OUT ($73),A
  IN A,($70)
  LD C,A
  LD A,$0D
  OUT ($73),A
GET_DEVICE_573:
  CALL GET_DEVICE_580
  IN A,($72)
  AND $01
  JP NZ,GET_DEVICE_573
  LD A,$0C
  OUT ($73),A
  RET
  
GET_DEVICE_574:
  IN A,($BA)
  AND $7F
  OUT ($BA),A
  LD D,$00
  CALL GET_DEVICE_575
  PUSH AF
  IN A,($BA)
  OR $80
  OUT ($BA),A
  POP AF
  RET C
  LD D,$10
GET_DEVICE_575:
  LD A,($FEC2)
  LD E,A
GET_DEVICE_576:
  LD BC,$01F4
GET_DEVICE_577:
  CALL GET_DEVICE_580
  IN A,($BB)
  AND $10
  XOR D
  RET Z
  DEC BC
  LD A,C
  OR B
  JP NZ,GET_DEVICE_577
  DEC E
  JP NZ,GET_DEVICE_576
  SCF
  RET
  
GET_DEVICE_578:
  PUSH BC
  CALL GET_DEVICE_574
  POP BC
  RET C
GET_DEVICE_579:
  CALL GET_DEVICE_580
  IN A,($D8)
  AND $10
  JP Z,GET_DEVICE_579
  LD A,C
  OUT ($C8),A
  RET

GET_DEVICE_580:
  CALL BREAK
  RET NC
  EX (SP),HL
  POP HL
  RET

GET_DEVICE_581:
  CALL PRINT_LINE7
  JP GET_DEVICE_583
GET_DEVICE_582:
  CALL $6F55
GET_DEVICE_583:
  LD HL,__MENU_03
  PUSH HL
  LD A,$01
  LD ($FEC2),A
  LD C,$04
  CALL GET_DEVICE_578
  RET C
  XOR A
  LD ($FEC2),A
  CALL GET_DEVICE_587
  AND $3F
  RET NZ
  CALL GET_DEVICE_588
  LD DE,$0006
  RST CPDEHL
  RET NZ
  CALL GET_DEVICE_588
  RET C
  EX DE,HL
  CALL GET_DEVICE_588
  RET C
  CALL GET_DEVICE_592
  RET C
  CALL GET_DEVICE_588
  RET C
  EX DE,HL
  POP BC
  LD A,$FF
  LD ($FEC3),A
  LD SP,HL
  PUSH DE
  LD DE,$0000
  PUSH DE
  PUSH BC
GET_DEVICE_584:
  LD C,$47
  CALL GET_DEVICE_578
  RET C
  LD C,$04
  CALL GET_DEVICE_579
  RET C
  CALL GET_DEVICE_587
  RET C
  AND $3F
  JP Z,GET_DEVICE_585
  CP $0E			; Line number prefix
  RET NZ
  POP HL
  POP HL
  RET

GET_DEVICE_585:
  EX DE,HL
  CALL GET_DEVICE_588
  RET C
  EX DE,HL
GET_DEVICE_586:
  CALL GET_DEVICE_587
  LD (HL),A
  INC HL
  DEC DE
  LD A,D
  OR E
  JP NZ,GET_DEVICE_586
  JP GET_DEVICE_584

GET_DEVICE_587:
  CALL RV232C
  RET Z
  POP AF
  SCF
  RET

GET_DEVICE_588:
  CALL GET_DEVICE_587
  LD H,A
  CALL GET_DEVICE_587
  LD L,A
  RET

GET_DEVICE_589:
  CALL GET_DEVICE_565
  RET NZ
  LD HL,$7712
  PUSH HL
  LD C,$1B
  CALL GET_DEVICE_567
  RET C
  LD C,'*'
  CALL GET_DEVICE_567
  RET C
  CALL GET_DEVICE_591
  RET C
  EX DE,HL
  CALL GET_DEVICE_591
  RET C
  CALL GET_DEVICE_592
  RET C
  LD B,H
  LD C,L
  CALL GET_DEVICE_591
  RET C
  LD A,$FF
  LD ($FEC3),A
  EX DE,HL
  LD SP,HL
  PUSH DE
  LD DE,$0000
  PUSH DE
  LD D,B
  LD E,C
GET_DEVICE_590:
  CALL GET_DEVICE_571
  RET C
  LD (HL),C
  INC HL
  DEC DE
  LD A,D
  OR E
  JP NZ,GET_DEVICE_590
  POP AF
  RET

GET_DEVICE_591:
  PUSH BC
  CALL GET_DEVICE_571
  LD H,C
  POP BC
  RET C
  PUSH BC
  CALL GET_DEVICE_571
  LD L,C
  POP BC
  RET

GET_DEVICE_592:
  PUSH HL
  LD HL,(PROGND)
  LD BC,FNCTAB
  ADD HL,BC
  RST CPDEHL
  POP HL
  CCF
  RET C
  PUSH HL
  PUSH DE
  ADD HL,DE
  EX DE,HL
  LD HL,(HIMEM)
  RST CPDEHL
  POP DE
  POP HL
  RET

  NOP

;$78B7
FONT:
	BINARY  "FONT_L.BIN"


;$7A96

;00000000
;00001000
;00011100
;00111110
;01111111
  DEFB $00,$08,$1C,$3E,$7F,$00

;00100000
;01110000
;11111000
;00100000
;00111110
  DEFB $20,$70,$F8,$20,$3E,$00

;01010101
;10101010
;01010101
;10101010
;01010101
;10101010
 DEFB $55,$AA,$55,$AA,$55,$AA

  


; Routine at 31401
L7AA9:
  NOP
  NOP
  LD B,H
  LD A,A
  LD B,L
GET_DEVICE_619:
  LD B,L
  JR NZ,GET_DEVICE_620
  AND A
  AND L
  PUSH HL
  JR GET_DEVICE_632
  INC H
  LD ($7924),HL
  DEC A
  LD B,D
  LD B,D
  LD B,D
  DEC A
  DEC A
  LD B,B
  LD B,B
  LD B,B
  DEC A
  JR NZ,GET_DEVICE_630
  LD D,H
  LD D,L
  LD A,B
GET_DEVICE_620:
  JR C,GET_DEVICE_628
  LD B,H
  LD B,L
  JR C,GET_DEVICE_626
  LD B,C
  LD B,B
  LD A,L
  LD B,B
  LD A,(HL)
  DEC H
  DEC H
  DEC H
  LD A,(DE)
GET_DEVICE_621:
  DEC E
  JP M,GET_DEVICE_622
  LD B,$20
GET_DEVICE_622:
  LD A,C
  CP ' '
  JP NC,GET_DEVICE_623
  ADD A,$80
  ADD A,B
  RET
GET_DEVICE_623:
  XOR A
  RET
GET_DEVICE_624:
  LD A,(KYHOW)
  RLCA
  JP NC,GET_DEVICE_625
  LD BC,$0009
  ADD HL,BC
  RLCA
  JP NC,GET_DEVICE_625
  ADD HL,BC
GET_DEVICE_625:
  LD A,(HL)
  SCF
  JP __MENU_82
  INC BC
  JR NZ,GET_DEVICE_633
  INC A
  DEC A
  LD E,E
  LD E,H
  LD E,L
  LD E,(HL)
  LD H,H
  JR NZ,GET_DEVICE_634
GET_DEVICE_626:
  INC A
  DEC A
  LD E,E
  LD E,H
GET_DEVICE_627:
  LD E,L
GET_DEVICE_628:
  LD E,(HL)
  INC BC
  LD H,L
  LD H,(HL)
  LD H,A
  LD L,B
  LD L,C
  LD L,D
  LD L,E
  LD L,H
GET_DEVICE_629:
  LD C,A
GET_DEVICE_630:
  CP $61
  RET C
  LD A,(KYHOW)
  AND $40
  LD A,C
  JP NZ,GET_DEVICE_631
  CP $7B
  RET NC
  AND $5F
  RET
GET_DEVICE_631:
  CP $7E
GET_DEVICE_632:
  RET NC
  AND $5F
  RET
  LD B,H
  JR NZ,GET_DEVICE_634
  RRCA
  EX AF,AF'
  RLCA
  LD B,L
  DEC H
  RRA
  LD A,(BC)
GET_DEVICE_633:
  LD C,D
  LD A,$09
  EX AF,AF'
  RLCA
  NOP
  LD B,A
  JR NZ,GET_DEVICE_636
GET_DEVICE_634:
  INC B
  LD B,L
  DEC A
  DEC B
  INC B
  NOP
  LD A,A
  INC B
  EX AF,AF'
  DJNZ GET_DEVICE_635
  LD B,D
  CCF
GET_DEVICE_635:
  LD (BC),A
  LD (BC),A
  LD B,B
  LD B,D
  LD B,D
  LD B,D
  LD B,B
  LD C,D
  LD HL,($2A12)
  LD B,(HL)
  LD (DE),A
  LD (DE),A
  LD A,E
  LD A,(BC)
  LD D,$40
GET_DEVICE_636:
  JR NZ,$7B77
  EX AF,AF'
  RLCA
  LD B,B
  INC A
  LD BC,$7C02
  CCF
  LD B,H
  LD B,H
  LD B,H
  LD B,H
  LD BC,$2141
  LD DE,$040F
  LD (BC),A
  LD BC,$3C02
  LD ($7F02),A
  LD (BC),A
  LD ($1202),A
  LD ($0E52),HL
  LD HL,$2525
  LD HL,$7840
  LD B,H
  LD B,D
  LD D,C
  LD H,B
  LD B,B
  JR Z,GET_DEVICE_638
  JR Z,GET_DEVICE_637
  INC B
  DEC B
  CCF
  LD B,L
  LD B,L
  LD (BC),A
  LD A,A
GET_DEVICE_637:
  LD (BC),A
  LD (DE),A
  LD C,$40
  LD B,D
  LD B,D
  LD A,(HL)
GET_DEVICE_638:
  LD B,B
  LD C,D
  LD C,D
  LD C,D
  LD C,D
  LD A,(HL)
  INC B
  DEC B
  LD B,L
  DEC H
  INC E
  NOP
  RRA
  LD B,B
  JR NZ,GET_DEVICE_640
  LD B,B
  LD A,$00
  LD A,A
  JR NZ,GET_DEVICE_639
GET_DEVICE_639:
  LD A,A
  LD B,B
  JR NZ,GET_DEVICE_641
  LD A,(HL)
  LD B,D
  LD B,D
  LD B,D
  LD A,(HL)
  RLCA
  LD BC,$2141
  RRA
  LD B,D
  LD B,D
  LD B,B
  JR NZ,GET_DEVICE_642
  LD BC,$0002
  LD BC,$0202
GET_DEVICE_640:
  DEC B
  DEC B
  LD (BC),A
GET_DEVICE_641:
  NOP
  NOP
  EX AF,AF'
  INC E
  LD A,$7F
  NOP
  JR NZ,GET_DEVICE_646
  RET M
  JR NZ,GET_DEVICE_643
  NOP
  LD D,L
  XOR D
GET_DEVICE_642:
  LD D,L
  XOR D
  LD D,L
  XOR D
  LD A,D
  LD A,B
  LD H,E
  HALT
  LD H,D
  LD L,(HL)
  LD L,L
  LD L,H
  LD H,C
  LD (HL),E
  LD H,H
  LD H,(HL)
  LD H,A
  LD L,B
  LD L,D
  LD L,E
  LD (HL),C
  LD (HL),A
  LD H,L
  LD (HL),D
  LD (HL),H
  LD A,C
  LD (HL),L
  LD L,C
  LD L,A
  LD (HL),B
  LD B,B
  LD E,H
  INC L
  LD L,$2F
  LD E,L
  LD SP,$3332
  INC (HL)
  DEC (HL)
  LD (HL),$37
  JR C,GET_DEVICE_645
  JR NC,GET_DEVICE_646
  LD A,($5B2D)
  LD E,(HL)
  LD A,H
  INC A
  LD A,$3F
  LD A,L
  LD HL,$2322
GET_DEVICE_643:
  INC H
  DEC H
  LD H,$27
  JR Z,GET_DEVICE_646
  LD E,A
  DEC HL
  LD HL,(GET_DEVICE_633)
  JR NZ,GET_DEVICE_644
  EX AF,AF'
  LD E,$1F
  DEC E
  INC E
  ADD HL,BC
  DEC DE
  DEC C
  RET P
  POP AF
  JP P,TEL_TERM_014
  NOP
  NOP
  INC BC
  JR NZ,$7C39
GET_DEVICE_644:
  LD A,A
  INC D
  LD (BC),A
  LD BC,$0906
  DEC DE
  DEC C
  PUSH AF
  OR $F7
  RET M
GET_DEVICE_645:
  LD SP,HL
  NOP
  NOP
  INC BC
GET_DEVICE_646:
  LD A,C
  LD A,B
  LD H,E
  HALT
  LD H,D
  LD L,(HL)
  LD L,L
  LD L,H
  LD H,C
  LD (HL),E
  LD H,H
  LD H,(HL)
  LD H,A
  LD L,B
  LD L,D
  LD L,E
  LD (HL),C
  LD (HL),A
  LD H,L
  LD (HL),D
  LD (HL),H
  LD A,D
  LD (HL),L
  LD L,C
  LD L,A
  LD (HL),B
  LD A,L
  INC HL
  INC L
  LD L,$2D
  DEC HL
  LD SP,$3332
  INC (HL)
  DEC (HL)
  LD (HL),$37
  JR C,GET_DEVICE_648
  JR NC,$7CF6
  LD A,E
  LD A,(HL)
  INC A
  LD E,L
  LD E,(HL)
  DEC SP
  LD A,($2A27)
  LD HL,$4022
  INC H
  DEC H
  LD H,$2F
  JR Z,GET_DEVICE_649
  DEC A
  LD E,H
  LD E,E
  CCF
  LD A,$00
  NOP
  NOP
  
  
; Boot routine
;
; Used by the routine at $0000.
BOOT:
  DI
  LD SP,ALT_LCD
  LD HL,30000	; delay
BOOT_DELAY:
  DEC HL
  LD A,H
  OR L
  JP NZ,BOOT_DELAY
  IN A,($D8)
  AND A
  JP P,BOOT_DELAY
  LD A,$43
  OUT ($B8),A
  LD A,$EC
  OUT ($BA),A
  LD A,$FF
GET_DEVICE_648:
  OUT ($B9),A		; I/O port select
  IN A,($E8)
GET_DEVICE_649:
  AND $03
  LD A,$ED
  OUT ($BA),A
  JP Z,BOOT_4
  LD HL,(MAXRAM)
  LD DE,$8A4D
  RST CPDEHL
  JP NZ,BOOT_4
  IN A,($A0)
  AND $0C
  JP NZ,GET_DEVICE_650
  LD A,($F3DB)
  AND A
  JP Z,GET_DEVICE_650
  LD DE,$7CDC
  JP __MENU_186
  JP Z,GET_DEVICE_650
  XOR A
  OUT ($A1),A		; LCD address
  LD ($F3DB),A
  
GET_DEVICE_650:
  LD A,($F9B1)
  LD D,A
  CALL TEST_FREEMEM
  CP D
  JP NZ,BOOT_4
  CALL EXTROM_TST
  LD A,$00
  JP NZ,BOOT_1
  DEC A
BOOT_1:
  LD HL,OPTROM
  CP (HL)
  JP NZ,BOOT_4
  LD HL,(ATIDSV)
  EX DE,HL
  LD HL,$0000
  LD (ATIDSV),HL
  LD HL,$9C0B	; POWER ON data marker
  RST CPDEHL
  JP NZ,BOOT_2
  LD HL,($F9AE)
  LD SP,HL
  CALL BOOT_VECT
  CALL L7D6F
  LD HL,(SAVSP)
  PUSH HL
  LD HL,(MENU_FLG)
  LD A,L
  AND A
  JP Z,GET_DEVICE_652
  LD A,H
  AND A
  JP Z,GET_DEVICE_654
GET_DEVICE_652:
  LD HL,$FEC3
  XOR A
  CP (HL)
  LD (HL),A
  JP NZ,GET_DEVICE_654
  LD A,($F3E4)
  AND A
  JP NZ,GET_DEVICE_655
  CALL CURSOFF9
  POP HL
  LD A,H
  AND A
  JP Z,POPALL
  LD SP,HL
  JP SET_CLOCK_HL_15

BOOT_2:
  LD A,(ERRTRP-1)
  AND A
  JP Z,GET_DEVICE_654
  CALL L7D6F
  CALL STKINI
  CALL CURSOFF9
  JP GET_DEVICE_214

GET_DEVICE_654:
  INC A
  LD (FSTFLG),A			; Set to 1 to indicate this is a power-up condition. 
GET_DEVICE_655:
  LD HL,(STKTOP)
  LD SP,HL
  CALL BOOT_VECT
  CALL _CLREG_1
  LD HL,__MENU
  PUSH HL

	DEFB $F6	; OR $AF
	
L7D6F:
  XOR A
  CALL IOINIT
; Routine at 32111
;
; Used by the routine at L7426.
  XOR A
  LD (POWR_FLAG),A
  LD A,($FE43)
  CP $03
  RET NZ
  LD HL,$F406
  JP GETWORD_91
  
BOOT_4:
  LD SP,STACK_INIT
  CALL TEST_FREEMEM
  LD B,$E1
  LD DE,MAXRAM
  LD HL,SYSVARS_ROM
  CALL LDIR_B
  CALL INIT_HOOKS
  LD A,$0C
  LD (TIMCN2),A
  LD A,$64
  LD (TIMINT),A
  LD HL,FNKTAB
  CALL STFNK
  CALL DWNLDR_47
  LD B,$42
  LD DE,$6C8E
  LD HL,DIRECTORY
  CALL REV_LDIR_B
  LD B,$E7
  CALL ZERO_MEM
  LD (HL),$FF
  CALL EXTROM_TST
  JP NZ,BOOT_6
  DEC A
  LD (OPTROM),A
  LD HL,USRDIR
  LD (HL),$F0
  INC HL
  INC HL
  INC HL
  LD DE,$F993
  LD B,$06
  CALL REV_LDIR_B
  LD (HL),' '
  INC HL
  LD (HL),B
BOOT_6:
  XOR A
  LD (ENDBUF),A
  LD (NLONLY),A
  LD (TMOFLG),A
  LD A,':'
  LD (BUFFER),A
  LD HL,PRMSTK
  LD (PRMPRV),HL
  LD (STKTOP),HL
  LD BC,$0100
  ADD HL,BC
  LD (MEMSIZ),HL
  LD A,$01
  LD (PROGND+1),A
  CALL __MAX_0
  CALL _CLREG_1
  LD HL,(RAM)
  XOR A
  LD (HL),A
  INC HL
  LD (BASTXT),HL
  LD (SUZUKI),HL
  LD (HL),A
  INC HL
  LD (HL),A
  INC HL
  LD (DO_FILES),HL
  LD (HAYASHI),HL		; Paste buffer file
  LD (HL),$1A		; EOF
  INC HL
  LD (CO_FILES),HL
  LD (PROGND),HL
  LD HL,SUZUKI-1
  LD (DIRPNT),HL
  CALL CLRPTR
  CALL INITIO
  LD HL,$3833
  LD ($F83C),HL
  LD HL,$7EA1
  CALL $735A
  JP __MENU
  
PRINT_COPYRIGHT:
  LD HL,PROMPT_MSG
  CALL PRS
  CALL CONSOLE_CRLF
  RST $38
  LD E,B
  CALL FREEMEM
  LD HL,BYTES_MSG
  JP PRS

FREEMEM:
  LD HL,(PROGND)
  EX DE,HL
  LD HL,(STKTOP)
  LD A,L
  SUB E
  LD L,A
  LD A,H
  SBC A,D
  LD H,A
  LD BC,$FFF2
  ADD HL,BC
  JP NUMPRT
  
INIT_HOOKS:
  LD HL,RST38_VECT
  LD BC,$2F02	; B=47, C=2
  LD DE,NULSUB
__MENU_181:
  LD (HL),E
  INC HL
  LD (HL),D
  INC HL
  DEC B
  JP NZ,__MENU_181
  LD B,$1B
  LD DE,FCERR
  DEC C
  JP NZ,__MENU_181
  RET
TEST_FREEMEM:
  LD HL,$C000
__MENU_183:
  LD A,(HL)
  CPL
  LD (HL),A
  CP (HL)
  CPL
  LD (HL),A
  LD A,H
  JP NZ,__MENU_184
  INC L
  JP NZ,__MENU_183
  SUB $20
  LD H,A
  JP M,__MENU_183
__MENU_184:
  LD L,$00
  ADD A,$20
  LD H,A
  LD (RAM),HL
  RET
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  LD BC,$0000
  LD BC,$DBF3
  AND B
__MENU_185:
  ADD A,$04
  AND $0C
  CP $04
  JP Z,__MENU_185
  LD DE,$7EBD
  JP __MENU_186
  JP NZ,$7EAB
  IN A,($A0)
  LD C,A
  XOR A
  OUT ($A1),A		; LCD address
  LD A,C
  LD ($F3DB),A
  OUT ($A1),A		; LCD address
  JP $0000
__MENU_186:
  OUT ($A1),A		; LCD address
  LD HL,$E000
__MENU_187:
  LD A,(HL)
  CPL
  LD (HL),A
  CP (HL)
  CPL
  LD (HL),A
  JP NZ,__MENU_188
  INC L
  JP NZ,__MENU_187
__MENU_188:
  EX DE,HL
  JP (HL)
; This entry point is used by the routine at GETWORD.
__MENU_189:
  JP NC,SNERR
  LD B,$00
  AND $0F
  LD D,A
  OR $37
  IN A,($A0)
  LD C,A
  LD A,B
  OUT ($A1),A		; LCD address
  JP C,__MENU_190
  LD (HL),D
__MENU_190:
  LD D,(HL)
  LD A,C
  OUT ($A1),A		; LCD address
  RET

__MAX:
  RST SYNCHR 		;   Check syntax: next byte holds the byte to be found
  CALL GET_DEVICE_695
  CALL GETINT
  JP NZ,SNERR
  CP $10
  JP NC,FCERR
  LD (TEMP),HL
  PUSH AF
  CALL CLSALL		; Close all files
  POP AF
  CALL __MAX_0
  CALL _CLREG
  JP EXEC_EVAL_0
  
; This entry point is used by the routine at CHKSTK.
__MAX_0:
  PUSH AF
  LD HL,(HIMEM)
  LD DE,$FEF5
__MAX_1:
  ADD HL,DE
  DEC A
  JP P,__MAX_1
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
  LD BC,$008C
  ADD HL,BC
  LD B,H
  LD C,L
  LD HL,(PROGND)
  ADD HL,BC
  RST CPDEHL
  JP NC,OMERR
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
__MAX_2:
  LD (HL),E
  INC HL
  LD (HL),D
  INC HL
  EX DE,HL
  LD (HL),$00
  ADD HL,BC
  EX DE,HL
  DEC A
  JP P,__MAX_2
  POP HL
  LD BC,$0009
  ADD HL,BC
  LD (FILTAB+4),HL
  RET
  

; Message at 32649
BYTES_MSG:
  DEFM " Bytes free"
  DEFB $00

; Message at 32661
PROMPT_MSG:
  DEFM "NEC PC-8201 BASIC Ver 1.0 (C) Microsoft "
  DEFB $00
  
; This entry point is used by the routine at GETYPR.
_RST38H:
  EX (SP),HL
  PUSH AF
  LD A,(HL)
  LD (RST38_OFFS),A
  POP AF
  INC HL
  EX (SP),HL
  PUSH HL
  PUSH BC
  PUSH AF
  LD HL,RST38_VECT
  LD A,(RST38_OFFS)
  LD C,A
  LD B,$00
  ADD HL,BC
  LD A,(HL)
  INC HL
  LD H,(HL)
  LD L,A
  POP AF
  POP BC
  EX (SP),HL
; Routine at 32731
NULSUB:
  RET

; This entry point is used by the routine at ISFLIO.
__MENU_199:
  LD A,(NO_SCROLL)
  AND A
  RET Z
  JP HOME31

_CLREG_1:
  XOR A
  LD (LPT_POS),A
  JP _CLREG_1

CALLHL1:
  LD B,$00
CALLHL2:
  IN A,($BB)
  AND $04
  RET Z
  DEC B
  JP NZ,CALLHL2
  DEC C
CALLHL3:
  JP NZ,CALLHL1
  RET

  EX DE,HL
  LD A,A
  JP PRS_ABORTMSG9


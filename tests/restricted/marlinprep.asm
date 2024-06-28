
;
;    MZ 811  Basic  Source  Listing
;    ------------------------------
;

; Default mode build (also MZ-1500):
; z88dk-z80asm -b -m mz-5z009.asm

; "It is a common misunderstanding that MZ-800 and MZ-1500 are almost identical. 
; MZ-1500 is not just a Japanese version of MZ-800.  They are both based on MZ-700 architecture but differently extended.
; MZ-1500 does not have 640x200/320x200 bitmap screen but has 8-color PCG screen (1024 PCGs consist 320x200 screen).
; MZ-1500 has two SN76489 while MZ-800 has one. Etc. "
; PLE mode build (6 channels sound):
; z88dk-z80asm -b -m -DSYS mz-5z009.asm


; V1.0B+ MODIFIED versions
; 64 KB
; z88dk-z80asm -b -m -DRAMDISK mz-5z009.asm
;
; PILSOFT MOD, 20.02.89:  64 KB, IO EC~EF
; z88dk-z80asm -b -m -DRAMDISK -DALTFN -DMOD_B mz-5z009.asm

; RS232 mode:
; (default):   MZ-700, MZ-1500
; -DRSYS   :   MZ-800



; Section                 address
; -------------------------------------
; MON1                    0000
; MON2                    0FF0
; MON3                    142B
; MON-IOCS                1800
; XWORK                   2000
; H-QD                    2FD0
; H-CMT                   375A
; H-FD                    3B9E
; MON4                    3C00
; MON-RS                  3C64
; MON-EMM                 3EC6
; MON-PSG                 404A
; MON-GRPH                453A
; XSYS                    5800
; MONEQU                  5800
; BASIC                   5800
; STMNT                   650D
; IOCS                    6C81
; GRPH                    7590
; CONV                    797A
; EDIT                    8216
; EXPR                    853D
; FLOAT                   909E
; MUSIC                   9BAC
; WORKQ                   9E4B
; PLT                     9FCE
; -------------------------------------
;




;defc IOOUT   =  0104H
;defc DEASC   =  029EH
;defc PATCH   =  0531H
;defc INKEY0  =  0BA1H
;defc IOERR   =  00EBH
;defc TEST1   =  0164H
;defc ERRX    =  0340H
;defc COLS    =  049CH
;defc HCLSW   =  061DH
;defc PONT    =  0963H
;defc INKEY1  =  0B21H
;defc _KB     =  0DF6H
;defc _HL     =  00A7H
;defc PUSHR   =  00C7H
;defc SETDFL  =  0314H
;defc BINPUT  =  0A67H
;defc PUSHRA  =  00BAH
;defc CKHEX   =  02E9H
;defc DCOLOR  =  048AH
;defc PONTB   =  097AH
;defc ERRORJ  =  00EDH
;defc CLRHL   =  0137H
;defc SETDE   =  013EH
;defc INDRCT  =  0151H
;defc INCHLF  =  015DH
;defc IOCALL  =  0247H
;defc DWIDTH  =  04EFH
;defc ACCDI   =  05ADH
;defc LBOUND  =  05F9H
;defc PONTC   =  0960H
;defc INKEY_  =  0B1AH
;defc BRKCHK  =  001EH
;defc DEVASC  =  010DH
;defc DWIND   =  04AEH
;defc PONTCB  =  0977H
;defc INKEYF  =  0B8BH
;defc SYSSTA  =  004DH
;defc PUSHW   =  0671H
;defc HCUROF  =  093BH
;defc TESTX   =  016EH
;defc PALOFF  =  0441H
;defc DPALST  =  0476H
;defc PRNTT   =  0A58H
;defc EQTBL   =  0DDDH
;defc _TEMPO  =  0041H
;defc __RET   =  00B2H
;defc CLRDE   =  013DH
;defc HLFTCH  =  015EH
;defc HALT    =  02F8H
;defc ADDP0   =  031CH
;defc DGCOL   =  0493H
;defc TBCALC  =  0615H
;defc ERRORP  =  004FH
;defc LDDEMD  =  0132H
;defc ADDP1   =  0323H
;defc HCLS    =  0652H
;defc NOTXT   =  00A6H
;defc ASCHL   =  025EH
;defc ADDP2   =  032AH
;defc SETDNM  =  0397H
;defc PLTOTX  =  0EB3H
;defc DSMODE  =  03BEH
;defc CURMOV  =  094DH
;defc GETL    =  0A84H
;defc BREAKX  =  00E6H
;defc CHKACC  =  011BH
;defc LDDEHL  =  0143H
;defc LDHLDE  =  014AH
;defc BITMAP  =  05CEH
;defc BRKEY   =  0D22H
;defc _CRT    =  0DDDH
;defc CRT1C   =  0E61H
;defc ADDHLA  =  0158H
;defc DEHEX   =  02CEH
;defc DPALBK  =  044FH
;defc FLASH   =  0945H
;defc _USR    =  0F7FH
;defc BREAKZ  =  00E8H
;defc LDDEMI  =  012DH
;defc SETHL   =  0138H
;defc HCURON  =  092BH

;defc _IOSVC  =  0003H
;defc _MONOP  =  0000H
;defc _CR1    =  0001H
;defc _CR2    =  0002H
;defc _CRT1C  =  0003H
;defc _CRT1X  =  0004H
;defc _CRTMS  =  0005H
;defc _LPTOT  =  0006H
;defc _LPT1C  =  0007H
;defc _CR     =  0008H
;defc _1C     =  0009H
;defc _1CX    =  000AH
;defc _MSG    =  000BH
;defc _GETL   =  000CH
;defc _INKEY  =  000DH
;defc _BREAK  =  000EH
;defc _HALT   =  000FH
;defc _DI     =  0010H
;defc _EI     =  0011H
;defc _CURMV  =  0012H
;defc _DEASC  =  0013H
;defc _DEHEX  =  0014H
;defc _CKHEX  =  0015H
;defc _ASCHL  =  0016H
;defc _COUNT  =  0017H
;defc _ADDP0  =  0018H
;defc _ADDP1  =  0019H
;defc _ADDP2  =  001AH
;defc _ERRX   =  001BH
;defc _DACN   =  001CH
;defc _ADCN   =  001DH
;defc _STICK  =  001EH
;defc _STRIG  =  001FH
;defc _BELL   =  0020H
;defc _PLAY   =  0021H
;defc _SOUND  =  0022H
;defc _MCTRL  =  0023H
;defc _IOOUT  =  0024H
;defc _TIMRD  =  0025H
;defc _TIMST  =  0026H
;defc _INP1C  =  0027H
;defc _CLRIO  =  0028H
;defc _SEGAD  =  0029H
;defc _OPSEG  =  002AH
;defc _DLSEG  =  002BH
;defc _DEVNM  =  002CH
;defc _DEVFN  =  002DH
;defc _LUCHK  =  002EH
;defc _LOPEN  =  002FH
;defc _LOADF  =  0030H
;defc _SAVEF  =  0031H
;defc _VRFYF  =  0032H
;defc _RWOPN  =  0033H
;defc _INSTT  =  0034H
;defc _INMSG  =  0035H
;defc _INDAT  =  0036H
;defc _PRSTR  =  0037H
;defc _CLKL   =  0038H
;defc _DIR    =  0039H
;defc _SETDF  =  003AH
;defc _LSALL  =  003BH
;defc _FINIT  =  003CH
;defc _DELET  =  003DH
;defc _RENAM  =  003EH
;defc _LOCK   =  003FH
;defc _RECST  =  0040H
;defc _INREC  =  0041H
;defc _PRREC  =  0042H
;defc _ERCVR  =  0043H
;defc _SWAP   =  0044H
;defc _CLS    =  0045H
;defc _POSCK  =  0046H
;defc _POSSV  =  0047H
;defc _PSET   =  0048H
;defc _LINE   =  0049H
;defc _PATTR  =  004AH
;defc _BOX    =  004BH
;defc _PAINT  =  004CH
;defc _CIRCL  =  004DH
;defc _POINT  =  004EH
;defc _HCPY   =  004FH
;defc _DSMOD  =  0050H
;defc _DPLBK  =  0051H
;defc _DPLST  =  0052H
;defc _DWIND  =  0053H
;defc _DCOL   =  0054H
;defc _DGCOL  =  0055H
;defc _ICRT   =  0056H
;defc _SYMBL  =  0057H
;defc ZWRK2   =  1049H
;defc ZWO     =  1057H
;defc ZWDIR   =  1063H
;defc VARST   =  1074H
;defc STRST   =  1076H
;defc INPFLG  =  108FH
;defc LPOSB   =  1095H
;defc INBUFL  =  1353H
;defc YW      =  1371H
;defc ZKL     =  105BH
;defc ZINP    =  105DH
;defc ELMD    =  1000H
;defc ZOUT    =  105FH
;defc __LPT   =  106EH
;defc VARED   =  1078H
;defc CURX    =  1082H
;defc POINTX  =  1088H
;defc KEYDAT  =  1365H
;defc SELCOL  =  137BH
;defc PALAD   =  137FH
;defc ELMD1   =  1001H
;defc ZBLK    =  105BH
;defc ZDELT   =  1061H
;defc DDEV    =  106AH
;defc POOLED  =  1074H
;defc CURY    =  1083H
;defc POINTY  =  108AH
;defc CURFLG  =  108CH
;defc CURMAK  =  108DH
;defc FILOUT  =  1091H
;defc PNMODE  =  1097H
;defc CPLANE  =  109CH
;defc KEY262  =  12AAH
;defc CWIDTH  =  136BH
;defc PAL2T   =  1385H
;defc CURDT1  =  1391H
;defc PBCN    =  13CEH
;defc ELMD20  =  1014H
;defc ZEQT    =  1044H
;defc ZEOF    =  1047H
;defc ZNXT    =  104AH
;defc ZDEVNM  =  104CH
;defc PSEL    =  1092H
;defc INBUF   =  1354H
;defc CURDT2  =  1399H
;defc ELMD30  =  101EH
;defc ZCH     =  1046H
;defc ZFLAG1  =  1050H
;defc INTFAC  =  107CH
;defc MEMMAX  =  1080H
;defc DMD     =  1098H
;defc KEY264  =  12ACH
;defc LINLIM  =  1364H
;defc PAL4T   =  1389H
;defc CURDT3  =  13A1H
;defc ELMD22  =  1016H
;defc ZFLAG2  =  1051H
;defc BITADR  =  1086H
;defc TMCNT   =  1195H
;defc KEYBUF  =  11A4H
;defc FUNBUF  =  12B2H
;defc ELMD32  =  1020H
;defc ZSTRT   =  1059H
;defc PCRLF   =  1093H
;defc KEY266  =  12AEH
;defc INBUFC  =  1352H
;defc SSA     =  1375H
;defc HERRF   =  13D9H
;defc ELMD24  =  1018H
;defc TMPEND  =  107AH
;defc DISPX   =  1090H
;defc CMODE   =  109BH
;defc SOF     =  1372H
;defc PAL16T  =  138DH
;defc EMPTR   =  13C4H
;defc ZCL     =  1059H
;defc POSADR  =  1084H
;defc KEYBM1  =  11A3H
;defc SEA     =  1376H
;defc EMWP0   =  13C6H
;defc ELMD26  =  101AH
;defc ZMAPB   =  1057H
;defc POOL    =  1072H
;defc SW      =  1374H
;defc PAIWED  =  137CH
;defc PALBK   =  137EH
;defc SCRNT0  =  13A9H
;defc EMWP1   =  13C8H
;defc ELMD18  =  1012H
;defc ZRWX    =  1043H
;defc ZRO     =  1055H
;defc ZMAPS   =  1055H
;defc __CRT   =  106CH
;defc CURXY   =  1082H
;defc CMTMSG  =  108EH
;defc IBUFE   =  10F0H
;defc CSMDT   =  1199H
;defc AMPM    =  1366H
;defc XS      =  1369H
;defc CRTMD1  =  1379H
;defc EMFLG   =  13C3H
;defc CTABLE  =  13DAH
;defc ZLOG    =  1042H
;defc ZDIRS   =  1059H
;defc ZPOS    =  1061H
;defc ZFREE   =  1065H
;defc TEXTST  =  1070H
;defc MEMLMT  =  107EH
;defc PWMODE  =  109AH
;defc PMASK   =  109EH
;defc GMODE   =  109FH
;defc YS      =  136FH
;defc CRTMD2  =  137AH
;defc ZTOP    =  1040H
;defc PSMAL   =  1096H
;defc SUMDT   =  1197H
;defc TEMPW   =  119EH
;defc XE      =  136AH
;defc SSW     =  1377H
;defc ZDIRMX  =  1052H
;defc ZINIT   =  1053H
;defc DCHAN   =  1069H
;;;defc TEXTED  =  1072H
;defc MEMOP   =  1099H
;defc CSIZE   =  136DH
;defc YE      =  1370H
;defc ZWRK1   =  1048H
;defc LPT_TM  =  1094H
;defc MAXCF   =  109DH
;defc SECD    =  1367H
;defc PALTBL  =  1381H


;defc TEXTBF  =  2000H
;defc BITBUF  =  8000H
;defc FONTBF  =  1000H
;defc ERRTXT  =  0FDA0H
;defc ZBYTES  =  001DH



; ---------------------------
; MZ-800     crt port define
; FI:CRTEQU  ver 1.0  7.26.84
; ---------------------------
;
;
; custom  lsi ports
;
;
;
defc LSPAL  =   0F0H            ;palette
defc LSFC   =   0FCH
defc LSE0   =   0E0H
defc LSE1   =   0E1H
defc LSE2   =   0E2H
defc LSE3   =   0E3H
defc LSE4   =   0E4H
defc LSE5   =   0E5H
defc LSE6   =   0E6H
defc LSD0   =   0D0H
defc LSD1   =   0D1H
defc LSD2   =   0D2H
defc LSD3   =   0D3H
;
defc LSWF   =  0CCH
defc LSRF   =  0CDH
defc LSDMD  =  0CEH
defc LSSCR  =  0CFH
;
;
;
;  work area
;
;defc TEXTBF   =   2000H
defc BITBUF  =  8000H
defc FONTBF  =  1000H
defc ERRTXT  = 0FDA0H

; ----------------------------
; MZ-800      Monitor part-1
; FI:PL1      ver 1.0  7.30.84
; ----------------------------
;
;
;
;        ORG    0

;   RAM - Monitor - jump table
;
        JP      STARTP          ; Monitor / Basic  -  Home entry
;
        JP      GETL            ; Get line from keyboard to memory (DE).
;
        JP      CR1             ; Output newline to screen
;
        JP      CR2             ; Line feed when cursor is not at beginning of line
;
        JP      CRT1S           ; print a space on the screen
;
        JP      PRNTT           ; Move cursor to next tab position
;
        JP      CRT1C           ; Display accu on screen (execution of control characters)
;
        JP      CRTMSG          ; Output text (DE) on screen (execution of control characters)
;
_DOCMD:
        JP      IOSVC           ; Software - execute command (RST _DOCMD: RST3 supervisor call entry)
;
        JP      INKEY0          ; Query whether key is pressed
;
BRKCHK: JP      BRKEY           ; Query whether (Shift) - BREAK is pressed
;
        JP      SAVE1           ; File - write identifier on tape (cassette)
;
        JP      SAVE2           ; File - write data to tape (cassette)
;
        JP      LOAD1           ; Read file identifier from tape (cassette)
;
        JP      LOAD2           ; File - read data from tape (cassette)
;
        JP      LOAD_2          ; File - compare data on tape with storage data
;
        JP      __RET           ; RET (formerly Music - Play Text (DE)), RST6
;
        JP      TIMST           ; set time
;
        DEFS    2               ; dummy
;
        JP      __RET           ; RET (formerly interrupt for clock)
;
        JP      TIMRD           ; read time
;
_BEEP:  JP      CTRLG           ; Treat reference tone according to code in Accu
;
_TEMPO: JP      _TEMP           ; set pace
;
        JP      MLDSP           ; turn off the sound
;
        JP      MLDSP           ; turn off the sound
;
        JP      GETL            ; Get line from keyboard to memory (DE).
;

SYSSTA:
        DEFW   _START
ERRORP:
        DEFS   2
;
        JP     CRTMSG          ;org 51H
;
        DEFS   4
;
        JP     INKEY           ;org 58H
;---------------------------------
;
;   crt driver contrl code tabel
;
;---------------------------------
CONTTB: DEFW   __RET           ;@ 00
        DEFW   __RET           ;A 01
        DEFW   __RET           ;B 02
        DEFW   CTR_M           ;C 03
        DEFW   __RET           ;D 04
        DEFW   CTR_E           ;E 05 sft lock
        DEFW   CTR_F           ;F 06 sft normal
        DEFW   __RET           ;G 07 beep
        DEFW   __RET           ;H 08
        DEFW   C_TAB           ;I 09
        DEFW   __RET           ;J 0A
        DEFW   __RET           ;K 0B
        DEFW   __RET           ;L 0C
        DEFW   CTR_M           ;M 0D cr
        DEFW   SPLSW           ;N 0E spool exec/stop
        DEFW   __RET           ;O 0F
        DEFW   DEL             ;P 10 del
        DEFW   CDOWN           ;Q 11 cursor down
        DEFW   CUP             ;R 12 cursor up
        DEFW   CRIGHT          ;S 13 cursor right
        DEFW   CLEFT           ;T 14 cursor left
        DEFW   HOME            ;U 15 home
        DEFW   HCLSW           ;V 16 clr
        DEFW   CTR_W           ;W 17 graph
        DEFW   INST            ;X 18 inst
        DEFW   CTR_F           ;Y 19 alpha
        DEFW   __RET           ;Z 1A
        DEFW   CTR_M           ;[ 1B esc
        DEFW   __RET           ;\ 1C
        DEFW   __RET           ;] 1D
        DEFW   __RET           ;^ 1E
        DEFW   __RET           ;_ 1F


;
CTRLJB: ADD    A,A
        LD     HL,CONTTB
        CALL   ADDHLA
        CALL   INDRCT
        JP     (HL)
;
;
NOTXT:                         ; Default for text without characters
        NOP
;
_HL:
        JP     (HL)
;
;
SVC_DI:
        EI
        PUSH   AF
        CALL   MWAIT
        CALL   SPLOFF
        POP    AF
        DI
__RET:
        RET
;
;
SVC_EI:
        PUSH   AF
        CALL   SPLON
        POP    AF
        EI
        RET

;----------------------------------
;
;   register all push program
;
; PUSHRA : PUSH IX,HL,BC,DE,AF
; PUSHR  : PUSH IX,HL,BC,DE
;  Destroy IX
;
;----------------------------------
PUSHRA:
        EX     (SP),IX
        PUSH   HL
        PUSH   BC
        PUSH   DE
        PUSH   AF
        PUSH   HL
        LD     HL,POPRA
        EX     (SP),HL
        JP     (IX)
PUSHR:
        EX     (SP),IX
        PUSH   HL
        PUSH   BC
        PUSH   DE
        PUSH   HL
        LD     HL,POPR
        EX     (SP),HL
        JP     (IX)
POPRA:  POP    AF
POPR:   POP    DE
        POP    BC
        POP    HL
        POP    IX
        RET
;
;
;
;---------------------------------
;
;      cold startup routine
;
;---------------------------------
;ORG DAH
;
COLDST: DI
        LD     SP,0000H
        IM     2
        OUT    (LSE1),A
        LD     HL,(SYSSTA)
        JP     (HL)            ;system entry jump
;
;
;
;---------------------------------
;
;    BREAK,can't cont
;---------------------------------
BREAKX:
        XOR    A
        DEFB   21H
;---------------------------------
;    BREAK,can cont
;---------------------------------
BREAKZ:
        LD     A,80H
        DEFB   21H
;---------------------------------
;    I/O error
;---------------------------------
IOERR:
        OR     80H
;---------------------------------
;    Error occur
;---------------------------------
ERRORJ:
        PUSH   AF
        CALL   MLDSP
        POP    AF
        LD     HL,(ERRORP)
        JP     (HL)            ;error jump
;


;
;---------------------------------
;
;  B = String bytes (till 00H)
;
;---------------------------------
COUNT:  PUSH   DE
        LD     B,0
COUNT2: LD     A,(DE)
        OR     A
        JR     Z,COUNT9
        INC    DE
        INC    B
        JR     NZ,COUNT2
        DEC    B
COUNT9: POP    DE
        RET
;---------------------------------
;
;    IOOUT
;
;    Ent. HL=I/O data tabel
;         B =counter
;
;---------------------------------
IOOUT:
        LD     A,(HL)
        INC    HL
        LD     C,(HL)
        INC    HL
        OUT    (C),A
        DJNZ   IOOUT
        RET
;
;
;
;
;
DEVASC:
        RST    3
        DEFB   _DEASC
        LD     A,D
        OR     A
        JP     NZ,ER03
        LD     A,E
        CP     B
        RET    C
        JP     ER03

;
        NOP

;
;
;        ORG    011BH
;---------------------------------
;
;
;  CHECK ACC
;     CALL CHKACC
;     DEFB N
;     DEFB X1
;     DEFB X2
;      :   :
;     DEFB XN
;---------------------------------
CHKACC:
        EX     (SP),HL
        PUSH   BC
        LD     B,(HL)
        INC    HL
        CP     (HL)
        JR     Z,CHACC1
        DJNZ   $-4
        INC    HL
        JR     CHACC9
CHACC1: INC    HL
        DJNZ   $-1
CHACC9: POP    BC
        EX     (SP),HL
        RET
;---------------------------------
;  LD DE,(HL+)
;---------------------------------
LDDEMI:
        LD     E,(HL)
        INC    HL
        LD     D,(HL)
        INC    HL
        RET
;---------------------------------
;  LD DE,(HL)
;---------------------------------
LDDEMD:
        LD     E,(HL)
        INC    HL
        LD     D,(HL)
        DEC    HL
        RET
;---------------------------------
; Clear (HL) B bytes
;---------------------------------
CLRHL:
        XOR    A
;---------------------------------
; Set  (HL) B bytes
;---------------------------------
SETHL:
        LD     (HL),A
        INC    HL
        DJNZ   $-2
        RET


;---------------------------------
; Clear (DE) B bytes
;---------------------------------
CLRDE:
        XOR    A
;---------------------------------
;  Set (DE) B bytes
;---------------------------------
SETDE:
        LD     (DE),A
        INC    DE
        DJNZ   $-2
        RET
;---------------------------------
;  LD (DE),(HL)  B bytes
;---------------------------------
LDDEHL:
        LD     A,(HL)
        LD     (DE),A
        INC    HL
        INC    DE
        DJNZ   $-4
        RET
;---------------------------------
;  LD (HL),(DE)  B bytes
;---------------------------------
LDHLDE:
        LD     A,(DE)
        LD     (HL),A
        INC    HL
        INC    DE
        DJNZ   $-4
        RET
;---------------------------------
;  LD HL,(HL)
;---------------------------------
INDRCT:
        PUSH   AF
        LD     A,(HL)
        INC    HL
        LD     H,(HL)
        LD     L,A
        POP    AF
        RET
;---------------------------------
;  ADD HL,A
;---------------------------------
ADDHLA:
        ADD    A,L
        LD     L,A
        RET    NC
        INC    H
        RET


;---------------------------------
; Fetch subroutines
;---------------------------------
INCHLF:
        INC    HL
HLFTCH:
        LD     A,(HL)
        CP     ' '
        JR     Z,INCHLF
        RET
;---------------------------------
; TEST1 "x" ;test 1 char
;---------------------------------
TEST1:
        CALL   HLFTCH
        EX     (SP),HL
        CP     (HL)
        INC    HL
        EX     (SP),HL
        RET    NZ
        INC    HL
        RET
;---------------------------------
;  TESTX "x"  ;check 1 char
;---------------------------------
TESTX:
        CALL   HLFTCH
        EX     (SP),HL
        CP     (HL)
        INC    HL
        EX     (SP),HL
        INC    HL
        RET    Z               ;OK
        LD     A,1
        JP     ERRORJ          ;Syntax error
;
;
;
;


;---------------------------------
; SVC(RST3) table
;---------------------------------
;
;

IOSVCT:
defc _MONOP  =    00H
        DEFW   MONOP
defc _CR1    =    01H
        DEFW   CR1
defc _CR2    =    02H
        DEFW   CR2
defc _CRT1C  =    03H
        DEFW   CRT1C
defc _CRT1X  =    04H
        DEFW   CRT1CX
defc _CRTMS  =    05H
        DEFW   CRTSIMU
defc _LPTOT  =    06H
        DEFW   LPTOUT
defc _LPT1C  =    07H
        DEFW   LPT1C
defc _CR     =    08H
        DEFW   PR_CR
defc _1C     =    09H
        DEFW   PR_1C
defc _1CX    =    0AH
        DEFW   PR_1CX
defc _MSG    =    0BH
        DEFW   PR_MSG
defc _GETL   =    0CH
        DEFW   GETL
defc _INKEY  =    0DH
        DEFW   INKEY
defc _BREAK  =    0EH
        DEFW   BRKEY
defc _HALT   =    0FH
        DEFW   HALT
defc _DI     =    10H
        DEFW   SVC_DI
defc _EI     =    11H
        DEFW   SVC_EI
defc _CURMV  =    12H
        DEFW   CURMOV
defc _DEASC  =    13H
        DEFW   DEASC
defc _DEHEX  =    14H
        DEFW   DEHEX
defc _CKHEX  =    15H
        DEFW   CKHEX
defc _ASCHL  =    16H
        DEFW   ASCHL
defc _COUNT  =    17H
        DEFW   COUNT
defc _ADDP0  =    18H
        DEFW   ADDP0
defc _ADDP1  =    19H
        DEFW   ADDP1
defc _ADDP2  =    1AH
        DEFW   ADDP2
defc _ERRX   =    1BH
        DEFW   ERRX
defc _DACN   =    1CH
        DEFW   DACN
defc _ADCN   =    1DH
        DEFW   ADCN
defc _STICK  =    1EH
        DEFW   STICK
defc _STRIG  =    1FH
        DEFW   STRIG
defc _BELL   =    20H
        DEFW   CTRLG
defc _PLAY   =    21H
        DEFW   PLAY
defc _SOUND  =    22H
        DEFW   MSOUND
defc _MCTRL  =    23H
        DEFW   MCTRL
defc _IOOUT  =    24H
        DEFW   IOOUT
defc _TIMRD  =    25H
        DEFW   TIMRD
defc _TIMST  =    26H
        DEFW   TIMST
defc _INP1C  =    27H
        DEFW   INP1C0


;
defc _CLRIO  =    28H
        DEFW   CLRIO
defc _SEGAD  =    29H
        DEFW   SEGADR
defc _OPSEG  =    2AH
        DEFW   OPSEG
defc _DLSEG  =    2BH
        DEFW   DELSEG
defc _DEVNM  =    2CH
        DEFW   DEV
defc _DEVFN  =    2DH
        DEFW   DEV_FN
defc _LUCHK  =    2EH
        DEFW   LUCHK
defc _LOPEN  =    2FH
        DEFW   LOPEN
defc _LOADF  =    30H
        DEFW   LOADFL
defc _SAVEF  =    31H
        DEFW   SAVEFL
defc _VRFYF  =    32H
        DEFW   VRFYFL
defc _RWOPN  =    33H
        DEFW   RWOPEN
defc _INSTT  =    34H
        DEFW   INPSTRT
defc _INMSG  =    35H
        DEFW   INPMSG
defc _INDAT  =    36H
        DEFW   INPDT
defc _PRSTR  =    37H
        DEFW   PRTSTR
defc _CLKL   =    38H
        DEFW   CLKL
defc _DIR    =    39H
        DEFW   FDIR
defc _SETDF  =    3AH
        DEFW   SETDFL
defc _LSALL  =    3BH
        DEFW   LSALL
defc _FINIT  =    3CH
        DEFW   FINIT
defc _DELET  =    3DH
        DEFW   FDELET
defc _RENAM  =    3EH
        DEFW   FRENAM
defc _LOCK   =    3FH
        DEFW   FLOCK
defc _RECST  =    40H
        DEFW   RECST
defc _INREC  =    41H
        DEFW   INREC
defc _PRREC  =    42H
        DEFW   PRREC
defc _ERCVR  =    43H
        DEFW   ERRCVR
defc _SWAP   =    44H
        DEFW   FSWAP
defc _CLS    =    45H
        DEFW   HCLS
defc _POSCK  =    46H
        DEFW   POSCK
defc _POSSV  =    47H
        DEFW   POSSV
defc _PSET   =    48H
        DEFW   PSET
defc _LINE   =    49H
        DEFW   WLINE
defc _PATTR  =    4AH
        DEFW   CHARW
defc _BOX    =    4BH
        DEFW   WBOX
defc _PAINT  =    4CH
        DEFW   WPAINT
defc _CIRCL  =    4DH
        DEFW   WCIRCL
defc _POINT  =    4EH
        DEFW   WPOINT
defc _HCPY   =    4FH
        DEFW   HCPY
defc _DSMOD  =    50H
        DEFW   DSMODE
defc _DPLBK  =    51H
        DEFW   DPALBK
defc _DPLST  =    52H
        DEFW   DPALST
defc _DWIND  =    53H
        DEFW   DWIND
defc _DCOL   =    54H
        DEFW   DCOLOR
defc _DGCOL  =    55H
        DEFW   DGCOL
defc _ICRT   =    56H
        DEFW   ICRT
defc _SYMBL  =    57H
        DEFW   SYMBOL


;---------------------------------
;
; SVC handlar (RST3)
;
;---------------------------------
IOSVC:  EX     (SP),HL
        PUSH   AF
        LD     A,(HL)
        INC    HL
        PUSH   HL
        LD     HL,IOSVCT
        ADD    A,A
        ADD    A,L
        JR     NC,$+3
        INC    H
        LD     L,A
        LD     A,(HL)
        INC    HL
        LD     H,(HL)
        LD     L,A
        LD     (IOSVCX+1),HL
        POP    HL
        POP    AF
        EX     (SP),HL
IOSVCX: JP     0               ;xxx
;
;  I/O device call (RST5)
;
IOCALL:
        PUSH   HL
        PUSH   DE
        LD     (IOCALX+1),IX
        LD     IX,IOERR
        OR     A
IOCALX: CALL   0               ;xxx
        POP    DE
        POP    HL
        RET    NC
        OR     A
        SCF
        RET    Z
        JP     IOERR
;
;
;
;  Convert BINARY(HL) to ASCII(DE)
;
ASCHL:
        PUSH   HL
        PUSH   BC
        PUSH   DE
        LD     DE,10000
        CALL   ASCHL2
        LD     DE,1000
        CALL   ASCHL2
        LD     DE,100
        CALL   ASCHL2
        LD     DE,10
        CALL   ASCHL2
        LD     A,L
        POP    DE
        OR     '0'
        LD     (DE),A
        INC    DE
        XOR    A
        LD     (DE),A
        POP    BC
        POP    HL
        RET
;
ASCHL2: LD     A,0FFH
ASCHL4: INC    A
        OR     A
        SBC    HL,DE
        JR     NC,ASCHL4
        ADD    HL,DE
        OR     A
        JR     NZ,ASCHL6
        OR     B
        RET    Z               ;Zero sup.
        XOR    A
ASCHL6: LD     B,1
        OR     '0'
        POP    DE
        EX     (SP),HL
        LD     (HL),A
        INC    HL
        EX     (SP),HL
        PUSH   DE
        RET


;
;  Convert ASCII(HL) to BINARY(DE)
;
DEASC:
        CALL   TEST1
        DEFM   "$"
        JR     Z,DEHEX
        LD     DE,0
DEASC2: CALL   HLFTCH
        SUB    '0'
        CP     10
        RET    NC
        INC    HL
        PUSH   HL
        LD     HL,DE
        ADD    HL,HL           ;2
        JR     C,ER02_
        ADD    HL,HL           ;4
        JR     C,ER02_
        ADD    HL,DE           ;5
        JR     C,ER02_
        ADD    HL,HL           ;10
        JR     C,ER02_
        LD     E,A
        LD     D,0
        ADD    HL,DE
        JR     C,ER02_
        EX     DE,HL
        POP    HL
        JR     DEASC2
;
ER02_:  LD     A,2
        JP     ERRORJ


;
; Convert HEX(HL) to BINARY(DE)
;
DEHEX:
        LD     DE,0
DEHEX2: LD     A,(HL)
        CALL   CKHEX
        RET    C
        INC    HL
        EX     DE,HL
        ADD    HL,HL           ;2
        JR     C,ER02_
        ADD    HL,HL           ;4
        JR     C,ER02_
        ADD    HL,HL           ;8
        JR     C,ER02_
        ADD    HL,HL           ;16
        JR     C,ER02_
        ADD    A,L
        LD     L,A
        EX     DE,HL
        JR     DEHEX2
;
; Chck hex
;
CKHEX:
        SUB    '0'
        CP     10
        CCF
        RET    NC
        SUB    'A'-'0'
        CP     6
        CCF
        RET    C
        ADD    A,10
        RET
;
; SVC .HALT   ;Halt if SPACE,
;             ;and break check
;
HALT:
        CALL   HALTSB
        CP     ' '
        RET    NZ
        CALL   HALTSB
        OR     A
        JR     Z,$-4
        RET
HALTSB:
        RST    3
        DEFB   _BREAK
        JR     Z,HALTBR
        LD     A,0FFH
        RST    3
        DEFB   _INKEY
        CP     1BH
        RET    NZ
HALTBR: JP     BREAKZ
        RET


;
; SVC .SETDF  ;set default
;   ent DE:equipment table
;       A: channel
;
SETDFL:
        LD     (DDEV),DE           ;default device
        LD     (DCHAN),A           ;default channel
        RET
;
; Pointer update
;
ADDP0:
        LD     HL,(POOL)
        ADD    HL,DE
        LD     (POOL),HL
ADDP1:
        LD     HL,(VARST)          ;Variable start <> POOL END
        ADD    HL,DE
        LD     (VARST),HL
ADDP2:
        LD     HL,(STRST)
        ADD    HL,DE
        LD     (STRST),HL
        LD     HL,(VARED)
        ADD    HL,DE
        LD     (VARED),HL
        LD     HL,(TMPEND)
        ADD    HL,DE
        LD     (TMPEND),HL
        RET
;


;
; SVC .ERRX  ;Print error message
;
ERRX:
        LD     C,A
        RST    3
        DEFB   _BELL
        RST    3
        DEFB   _CR2
        BIT    7,C
        JR     Z,ERRX1
        LD     HL,KEYBUF
        PUSH   HL
        CALL   SETDNM
        POP    DE
        RST    3
        DEFB   _CRTMS          ;Device name
ERRX1:  LD     A,C
        AND    7FH
        LD     C,A
        RST    3
        DEFB   _DI
        OUT    (LSE3),A        ;bank change
        JR     ERRX0
;
ERRXU:  LD     C,69
ERRX0:  LD     DE,ERRTXT
ERRX2:  DEC    C
        JR     Z,ERRX4
        LD     A,(DE)
        INC    DE
        OR     A
        JP     P,$-3
        JR     Z,ERRXU
        JR     ERRX2
;
ERRX4:  LD     A,(DE)
        CP     80H
        JR     Z,ERRXU
        EX     DE,HL
        LD     DE,KEYBUF
ERRX6:  LD     A,(HL)
        OR     A
        JP     M,ERRX8
        LDI
        JR     ERRX6
ERRX8:  AND    7FH
        LD     (DE),A
        OUT    (LSE1),A        ;bank change
        RST    3
        DEFB   _EI
        INC    DE
        LD     HL,MESER
        LD     B,8
        CALL   LDDEHL
        LD     DE,KEYBUF
        RST    3
        DEFB   _CRTMS
        RET
;


;
SETDNM:
        LD     DE,(ZEQT)
        INC    DE
        INC    DE
        RST    3
        DEFB   _COUNT
        CALL   LDHLDE
        LD     A,(ZCH)
        ADD    A,'1'
        LD     (HL),A             ;ch#
        LD     A,(ZFLAG2)
        AND    0FH             ;max ch#
        JR     Z,$+3
        INC    HL
        LD     (HL),':'
        INC    HL
        LD     (HL),0
        RET
;
MESER:  DEFM   " ERROR"

        DEFB   0
;
;
;-----------------------------------
;
;
;    display mode
;
;
;   ent. acc   mode    colors  dmd
;         1  320*200     4      0
;         2  320*200    16      2
;         3  640*200     2      4
;         4  640*200     4      6
;
;
;-----------------------------------
;
DSMODE:
        CALL   PUSHR
        LD     B,A
;
        LD     A,(MEMOP)       ;option vram exist ?
        OR     A
        LD     A,B
        JR     NZ,DSM0
        CP     2
        JR     Z,CERR
        CP     4
        JR     Z,CERR
;
;
;
DSM0:   PUSH   AF
        DEC    A
        LD     D,0FFH
        LD     HL,PAL4T
        LD     BC,0403H
        JR     Z,DSM00         ;skip if 320*200  4 colors
        DEC    A
        LD     HL,PAL16T
        LD     BC,100FH
        JR     Z,DSM00         ;skip if 320*200 16 colors
        DEC    A
        LD     HL,PAL2T
        LD     BC,0201H
        JR     Z,DSM00         ;skip if 640*200  2 colors
        LD     HL,PAL4T        ; 640 *200  4 colors
        LD     BC,0805H
        LD     D,0FDH
;
DSM00:  LD     (CPLANE),BC     ;c cplane
        LD     A,D
        LD     (PMASK),A       ;plane mask
        LD     (PALAD),HL
        CALL   PALOFF
        POP    AF
        DEC    A
        RLCA
        LD     (DMD),A
        OUT    (LSDMD),A
        AND    4               ;bit 2 only
        CALL   DWIDTH          ;acc=0 -->40 chr
        CALL   _CONSOI          ;(YS,YE)=0,24 palint
        OR     A
        RET
;
;
CERR:
        SCF
        RET


;-----------------------------------
;
;
;  console & palette & color init
;
;-----------------------------------
_CONSOI: LD     HL,1800H        ;(ys,ye)=(0,24)
        CALL   DWIND
;
;JR PALINT
;
PALINT: LD     A,(CPLANE)
        LD     (CMODE),A
        XOR    A
        CALL   DPALBK          ;init palette block reg.
        LD     HL,PALAD
        LD     E,(HL)
        INC    HL
        LD     D,(HL)
        EX     DE,HL
        LD     DE,PALTBL       ;init palette reg.
        PUSH   DE
        LD     BC,4
        LDIR
        POP    HL
PALOUT: LD     B,4
        LD     C,LSPAL
        OTIR
        RET
;--------------------------------
;
;   Palette all clr
;
;
;--------------------------------
PALOFF:
        PUSH   BC
        XOR    A
        LD     B,5
        LD     C,LSPAL
PALOF1: OUT    (C),A
        ADD    A,10H
        DJNZ   PALOF1
        POP    BC
        RET
;
;


;----------------------------------
;
;
;   pallet  block regster set
;
;      ent  acc=pal block number
;
;----------------------------------
DPALBK:
        CALL   PUSHR
        LD     (PALBK),A
        LD     E,A
        LD     A,(DMD)
        CP     2
        JR     NZ,PALBK1       ;skip if not 320*200 16 col
;
        LD     A,E
        RLCA                   ;*2
        RLCA                   ;*4
        LD     HL,PALTBL
        LD     B,4
        PUSH   HL
PALBK0: LD     (HL),A
        ADD    A,11H
        INC    HL
        DJNZ   PALBK0
        POP    HL
        CALL   PALOUT
PALBK1: LD     A,E
        OR     40H
        OUT    (LSPAL),A
        RET
;


;----------------------------------
;
;   pallet  regster set
;
;      ent  acc=pal register number
;           b  =pal color code
;
;----------------------------------
;
DPALST:
        CALL   PUSHR
        LD     HL,PALTBL
        LD     D,0
        LD     E,A             ;pallet register number
        ADD    HL,DE
        OR     A
        RLCA
        RLCA
        RLCA
        RLCA
        OR     B               ;pallet color code
        LD     (HL),A
        OUT    (LSPAL),A
        RET
;


;
;----------------------------------
;
;
;   display color set
;
;           Acc=col code
;----------------------------------
;
DCOLOR:
        PUSH   AF
        CALL   COLS
        LD     (CMODE),A
        POP    AF
        RET
;
;
DGCOL:
        PUSH   AF
        CALL   COLS
        LD     (GMODE),A
        POP    AF
        RET
;
COLS:
        PUSH   BC
        LD     B,A
        LD     A,(DMD)
        CP     6
        LD     A,B
        JR     NZ,COLS1        ;skip if not 640*200 4
        CP     2
        JR     C,COLS1
        ADD    A,2             ;2 or 3 only
COLS1:  POP    BC
        RET
;


;----------------------------------
;
;
;  display window set
;
;
;
;----------------------------------
DWIND:
        CALL   PUSHR
        LD     (YS),HL         ;save YS,YE
        LD     A,H
        SUB    L
        INC    A
        LD     (YW),A          ;YW=YE-YS+1 :lines
        LD     B,A
        ADD    A,A
        ADD    A,A
        ADD    A,B
        LD     (SW),A          ;SW=YW*5
        EX     DE,HL
        LD     H,0
        LD     L,A
        ADD    HL,HL           ;*2
        ADD    HL,HL           ;*4
        ADD    HL,HL           ;*8
        LD     (SSW),HL
        EX     DE,HL
        INC    H
        LD     A,H
        ADD    A,A
        ADD    A,A
        ADD    A,H
        LD     (SEA),A         ;SEA=(YE+1)*5
        LD     A,L
        ADD    A,A
        ADD    A,A
        ADD    A,L
        LD     (SSA),A         ;SSA=YS*5
        LD     HL,0
        LD     (SOF),HL        ;SOF=0
        LD     HL,SEA
        LD     BC,6CFH         ;B counter C scrool reg
        OTDR
        CALL   HCLS
        JP     HOME


;----------------------------------
;
;
;  display chracter size change
;
;     if acc=1 then 640 chr
;     if acc=0 then 320 chr
;----------------------------------
;
DWIDTH:
        CALL   PUSHR
        OR     A
        LD     A,40
        LD     DE,2300H
        JR     Z,DWID1
        ADD    A,A             ;80 chr
        LD     DE,0023H
DWID1:  LD     (CWIDTH),A
        LD     H,0
        LD     L,A
        ADD    HL,HL           ;*2
        ADD    HL,HL           ;*4
        ADD    HL,HL           ;*8
        LD     (CSIZE),HL
        DEC    A
        LD     (XE),A
;
        LD     A,D
        LD     (PTW0),A
        LD     (PTW0+1),A
        LD     (PTB0),A
        LD     A,E
        LD     (PTW1),A
        LD     (PTW1+1),A
        LD     (PTB1),A
        LD     BC,0B07H        ;patch counter
        LD     HL,CHTBL        ;patch table addr
        CALL   PATCH
        CALL   CHGRPH          ;mon-grph
        JP     HCLS
;
;
PATCH:
;
;  word patch
;
PATCHW: LD     E,(HL)          ;addr read
        INC    HL
        LD     D,(HL)
        INC    HL
PTW0:   INC    HL              ;nop
        INC    HL              ;nop
        LD     A,(HL)          ;data read
        INC    HL
        LD     (DE),A
        INC    DE
        LD     A,(HL)
        INC    HL
        LD     (DE),A
PTW1:   NOP                    ;inc hl
        NOP                    ;inc hl
        DJNZ   PATCHW
;
;    byte patch
;
        LD     B,C
PATCHB: LD     E,(HL)          ;addr read
        INC    HL
        LD     D,(HL)
        INC    HL
PTB0:   INC    HL              ;nop
        LD     A,(HL)
        INC    HL
        LD     (DE),A
PTB1:   NOP                    ;inc hl
        DJNZ   PATCHB
        RET
;


;--------------------------------
;
;
;    PL-EX crt driver patch tabel
;
;
;--------------------------------
;
CHTBL:
;
;  word patch
;
        DEFW   XPD1+1          ;ld de,xxxxh
        DEFW   80
        DEFW   40

        DEFW   XPC1            ;sla c
        DEFW   21CBH           ;(SLA C)
        DEFW   0               ;(NOP NOP)

        DEFW   XPC2+1          ;ld bc,xxxxh
        DEFW   400             ; Value for 80 characters per line
        DEFW   200             ; Value for 40 characters per line

        DEFW   XPC3+1          ;ld hl,xxxxh
        DEFW   BITBUF+16000
        DEFW   BITBUF+8000

        DEFW   XPDE3+1         ;ld de,xxxxh
        DEFW   80
        DEFW   40

        DEFW   XPDE4+1         ;ld bc,xxxxh
        DEFW    7 * 80         ; Value for 80 characters per line
        DEFW    7 * 40         ; Value for 40 characters per line

        DEFW   XPIN2+1         ;ld de,xxxxh
        DEFW   80
        DEFW   40

        DEFW   XPIN3+1         ;ld de,xxxxh
        DEFW    -80            ; Value for 80 characters per line
        DEFW    -40            ; Value for 40 characters per line

        DEFW   XPIN4+1         ;ld bc,xxxxh
        DEFW    - (7 * 80)     ; Value for 80 characters per line
        DEFW    - (7 * 40)     ; Value for 40 characters per line

        DEFW   XPLI2+1         ;ld de,xxxxh
        DEFW   80
        DEFW   40

        DEFW   XPSC2+1         ;ld bc,xxxxh
        DEFW   8 * 80 - 1      ; Value for 80 characters per line
        DEFW   8 * 40 - 1      ; Value for 40 characters per line
;
;
;
;byte patch
;
;
        DEFW   XPDE1+1         ;ld l,xxh
        DEFB   79
        DEFB   39

        DEFW   XPDE2+1         ;ld c,xxh
        DEFB   79
        DEFB   39

        DEFW   XPIN1+1         ;ld c,xxh
        DEFB   79
        DEFB   39

        DEFW   XPLI1+1         ;ld a,xxh
        DEFB   79
        DEFB   39

        DEFW   XPSC1+1         ;ld c,xxh
        DEFB   80
        DEFB   40

        DEFW   XPCU1
        DEFB   29H             ;add hl,hl
        DEFB   0               ;nop

        DEFW   XPCU2
        DEFB   29H             ;add hl,hl
        DEFB   0               ;nop
;
;
;
;---------------------------------
;
;
;    crt 1 character display
;
;       acc=ascii code
;
;
;---------------------------------
;
ACCDI:
        CALL   PUSHRA
        LD     HL,(POSADR)
        LD     C,A
        CP     20H             ;convert space
        JR     NZ,ACCDI0
        XOR    A
ACCDI0: LD     (HL),A
        LD     HL,(BITADR)
        LD     A,C
        CALL   BITMAP
        XOR    A               ;patch cursor
        LD     (CDOWN2+2),A
        CALL   CRIGHT
        LD     A,7
        LD     (CDOWN2+2),A
        RET
;


;----------------------------------
;
;    bitmap extention
;
;    ent Acc:ascii  code
;        HL :bitadr
;
;----------------------------------
;
BITMAP:
;
        RST    3
        DEFB   _ADCN          ;ascii->display
        DI
        EXX
        PUSH   HL
        LD     H,0
        LD     L,A             ;display code
        LD     A,(CMODE)
        OR     80H             ;replace mode
        OUT    (LSWF),A
;
        ADD    HL,HL           ;*2
        ADD    HL,HL           ;*4
        ADD    HL,HL           ;*8
        SET    4,H             ;offset fontbuf $1000
        EXX
        LD     B,8
XPD1:   LD     DE,40           ;cwidth 80<--80 chr
        IN     A,(LSE0)        ;bank change !!
BITM1:  EXX
        LD     A,(HL)          ;font pattern read
        INC    HL              ;next pointer
        EXX
        LD     (HL),A          ;font pattern write
        ADD    HL,DE           ;next laster
        DJNZ   BITM1
        IN     A,(LSE1)        ;   bank reset !!
        EI
        EXX
        POP    HL
        EXX
        RET


;----------------------------------
;
;
;     manegement   utility
;
;
;----------------------------------

;     exit D=begin line
;          E=end line+1
;
LBOUND:
        CALL   TBCALC
LBOUN1: LD     A,(HL)
        OR     A
        JR     Z,LBOUN2
        DEC    HL
        DEC    E
        LD     A,(YS)
        CP     E
        JR     C,LBOUN1
LBOUN2: LD     D,E
LBOUN3: INC    E
        INC    HL
        LD     A,(HL)
        OR     A
        RET    Z
        LD     A,(YE)
        CP     E
        JR     NC,LBOUN3
        RET
;
;
TBCALC:
        LD     E,H
        LD     D,0
        LD     HL,SCRNT0
        ADD    HL,DE
        RET
;
;-----------------------------------
;
;     clear  window
;
;
;
;-----------------------------------
HCLSW:
        CALL   PUSHR
        LD     A,(YS)
        LD     H,A
        CALL   TBCALC
        LD     A,(YW)          ;YW=YE-YS+1
        LD     B,A             ;lines
        LD     E,A             ;store YW
;
        CALL   CLRHL          ;mangement buf clr
;
CLSWT:  LD     C,E             ;restore YW
        LD     A,(YE)
;JR CLSLT
;
;
;-----------------------------------
;
;
;    clear   line
;
;    C=lines Acc=line no.
;
;-----------------------------------
;
CLSLT:
        INC    A
        LD     L,0
        LD     H,A
        PUSH   HL              ;start pos x,y
        CALL   PONT
        LD     B,0
XPC1:   NOP                    ;SMC  (40: NOP,  80: SLA C)
        NOP
        PUSH   BC
        CALL   PUSHW
        POP    HL              ;pop counter
        ADD    HL,HL           ;*2
        ADD    HL,HL           ;*4
        ADD    HL,HL           ;*8
        LD     C,L
        LD     B,H
        POP    HL              ;start pos x,y
        CALL   PONTB
        CALL   PUSHW
        JR     CLRSCR
;
;-----------------------------------
;
;    clear   screen
;
;
;
;
;-----------------------------------
HCLS:
        CALL   PUSHRA
CLST:   LD     HL,TEXTBF+2000
        LD     BC,50
        CALL   PUSHW
        LD     B,25
        LD     HL,SCRNT0
        CALL   CLRHL          ;manegement buf clr
CLSB:
;
;  color mode
;
XPC2:   LD     BC,200          ;or 400
XPC3:   LD     HL,BITBUF+8000  ;or +16000
        CALL   PUSHW
        JR     CLRSCR
;-----------------------------------
;
;   PUSH Write
;
;
;  Ent:HL=cls point addr
;      BC=counts *40
;
;-----------------------------------
;
PUSHW:
        LD     (PUSHW1+1),SP
        LD     (PUSHW2+1),HL
        LD     HL,0
        LD     A,(CPLANE)      ;display active plane
        OR     80H             ;replace mode
        OUT    (LSWF),A
;
PUSHW0: DI
PUSHW2: LD     SP,0            ;xx
        IN     A,(LSE0)        ;bank
;
        PUSH   HL
        PUSH   HL
        PUSH   HL
        PUSH   HL
        PUSH   HL              ;10
        PUSH   HL
        PUSH   HL
        PUSH   HL
        PUSH   HL
        PUSH   HL              ;20
        PUSH   HL
        PUSH   HL
        PUSH   HL
        PUSH   HL
        PUSH   HL              ;30
        PUSH   HL
        PUSH   HL
        PUSH   HL
        PUSH   HL
        PUSH   HL              ;40
        IN     A,(LSE1)        ;bank
        LD     (PUSHW2+1),SP
PUSHW1: LD     SP,0            ;xxx
        EI
;
        DEC    BC
        LD     A,C
        OR     B
        JR     NZ,PUSHW0
        RET
;----------------------------------
;
;    scrool parameter initial
;
;
;----------------------------------
;
CLRSCR:
        LD     HL,0
        LD     (SOF),HL
        LD     B,2
        LD     C,LSSCR         ;lsi scrool register
        OUT    (C),H
        DEC    B
        OUT    (C),L
        JP     HOME
;
;
;----------------------------------
;
;
;
;     delete chacter
;
;
;----------------------------------
;
;
DEL:
        EXX
        PUSH   HL
        PUSH   DE
        PUSH   BC
        EXX
        CALL   DEL0
        EXX
        POP    BC
        POP    DE
        POP    HL
        EXX
        RET
;
DEL0:
        LD     HL,(CURXY)
        DEC    L
        JP     P,DEL1
;
        CALL   TBCALC
        LD     A,(HL)
        LD     H,E
        LD     L,0
        OR     A
        JR     Z,DEL1
        LD     A,(YS)
        CP     H
        JR     Z,DEL1
        DEC    H
XPDE1:  LD     L,39            ;XE 39 or 79
DEL1:
        LD     (CURXY),HL
        CALL   LINCAL
;BC lines HL' counts HL last curxy
        CALL   PONTC
        PUSH   BC              ;lines store
        LD     D,H
        LD     E,L
        INC    HL
        EXX
        PUSH   HL              ;HL' counts
        EXX
        POP    BC
        LDIR
        XOR    A
        LD     (DE),A          ;last addr space
        POP    BC              ;lines pop
        LD     HL,(CURXY)
        INC    HL
        CALL   PONTB           ;bitmap addr
DELB11: EXX
        LD     D,9             ;laster set
        LD     HL,(MAXCF)
        DEC    D
        EXX
        JR     DELB2           ;line first time only


;----------------------------------
;  DELB
;
;  ent.
;  BC  lines
;  HL  start address
;----------------------------------
DELB:
;
XPDE2:  LD     C,39            ;79 xe
        DEC    B               ;last line ?
        JR     Z,DELB0         ;skip if end of func.
        INC    DE              ;next addr calc
        INC    DE
        LD     H,D
        LD     L,E
        JR     DELB11
;
DELB1:  LD     HL,(MAXCF)      ;
        DEC    D               ;last laster ?
        EXX
        JR     Z,DELB          ;skip if next line
XPDE3:  LD     DE,40           ;cwidth  80
        ADD    HL,DE
;
DELB2:  EXX                    ;next plane ?
        RRC    L
        JR     C,DELB1
        LD     A,L
        AND    H               ;pmask
        EXX
        JR     Z,DELB2         ;skip if warp
        DI
        PUSH   HL
        PUSH   BC
        OUT    (LSRF),A        ;read plane
        OUT    (LSWF),A        ;write plane
        IN     A,(LSE0)        ;bank change
        OUT    (LSE0),A        ;cg off
        LD     D,H
        LD     E,L
        DEC    DE
        LD     A,C
        OR     A
        JR     Z,XPDE4
        LD     A,B             ;line counter
        LD     B,0
        LDIR
        DEC    A
        JR     Z,DELB3         ;skip if last counter
XPDE4:  LD     BC,280          ; 560
        ADD    HL,BC
        LD     A,(HL)
        LD     (DE),A
DELB3:  IN     A,(LSE1)        ;bank off
        EI
        POP    BC
        POP    HL
        JP     DELB2
;
;
DELB0:
        EX     DE,HL
        INC    C
        LD     E,C
        LD     D,B
        LD     B,8
        DI
        IN     A,(LSE0)        ;bank change
        OUT    (LSE0),A        ;cg off
        LD     A,(CPLANE)
        OR     80H             ;replace mode
        OUT    (LSWF),A
DELB01: XOR    A
        LD     (HL),A          ;space fill
        SBC    HL,DE
        DJNZ   DELB01
        IN     A,(LSE1)        ;bank off
        EI
        LD     HL,(CURXY)
        JP     CURMOV
;


;----------------------------------

;
;
;     insert chacter
;
;
;----------------------------------
;
;
INST:
;
        EXX
        PUSH   HL
        PUSH   DE
        PUSH   BC
        EXX
        CALL   INST0
        EXX
        POP    BC
        POP    DE
        POP    HL
        EXX
        RET
;
;
INST0:
        LD     HL,(CURXY)
        CALL   LINCAL
;BC lines HL' counts HL last curxy
        PUSH   HL              ;store last-next pos x,y
        CALL   PONT
        DEC    HL              ;last addr
        LD     A,(HL)
        OR     A
        JR     NZ,INSTE        ;no insert space
        PUSH   BC              ;lines store
        LD     D,H
        LD     E,L
        DEC    HL
        EXX
        PUSH   HL              ;HL' counts
        EXX
        POP    BC
IF RAMDISK
        CALL   INST_0
ELSE
        LDDR
        XOR    A
ENDIF
        LD     (DE),A          ;last addr space
        POP    BC              ;lines pop
        POP    HL
        CALL   PONTB           ;bitmap addr
        DEC    HL
        LD     A,C
        LD     (LASTC+1),A
        DEC    B
        JR     Z,INSEF         ;first time ended
        JR     INSB1
;
INSTE:  POP    HL
        RET
;
;
;----------------------------------
;
;
;       insert operation
;
;            <<bitmap>>
;
;       ent. B =line counter
;
;----------------------------------
;
INSB:
        DEC    B               ;last line ?
        JR     Z,INSEND        ;skip if end of func.
INSB1:
XPIN1:  LD     C,39            ;79 xe
        CALL   INSLIN
        JR     INSB
;
;---------------------------------
;
;
;       insert operation
;
;             <<bitmap end >>
;
;---------------------------------
INSEND:
LASTC:  LD     C,0             ;patch
INSEF:  CALL   INSLIN
        CALL   PONTCB
XPIN2:  LD     DE,40           ;cwidth 80
        LD     B,8
        DI
        LD     A,(CPLANE)
        OR     80H             ;replace mode
        OUT    (LSWF),A
        IN     A,(LSE0)        ;bank change
        OUT    (LSE0),A        ;cg off
INSB01: XOR    A
        LD     (HL),A          ;space fill
        ADD    HL,DE
        DJNZ   INSB01
        IN     A,(LSE1)        ;bank off
        EI
        RET
;


;----------------------------------
;
;       insert operation
;
;              1 line only
;
;   ent.
;         HL=first destination addr
;         C =bytes
;
;----------------------------------
INSLIN:
        EXX
        LD     D,9             ;laster counter set
INSL1:  LD     HL,(MAXCF)      ;
        DEC    D               ;last laster ?
        EXX
        RET    Z
        CALL   INSLAS
XPIN3:  LD     DE,0FFD8H        ;FFB0h <--80
        ADD    HL,DE
        EXX
        JR     INSL1
;
;
;
;
;---------------------------------
;
;       insert operation
;
;              1 laster only
;
;
;   ent.  E'=plane data(maxcf)
;         HL=first destination addr
;         C=bytes
;
;---------------------------------
INSLAS: EXX                    ;next plane ?
        RRC    L
        LD     A,L
        EXX
        RET    C               ;next laster
        EXX
        AND    H               ;pmask
        EXX
        JR     Z,INSLAS        ;skip if warp
        PUSH   HL
        PUSH   BC
        DI
        OUT    (LSRF),A        ;read plane
        OUT    (LSWF),A        ;write plane
        IN     A,(LSE0)        ;bank change
        OUT    (LSE0),A        ;cg off
        LD     D,H
        LD     E,L
        DEC    HL
        LD     A,C
        OR     A
        JR     Z,XPIN4
        LD     A,B             ;line counter
        LD     B,0
        LDDR
        OR     A
        JR     Z,INSLA1        ;skip if last line
XPIN4:  LD     BC,0FEE8H        ;FDD0H <--80
        ADD    HL,BC
        LD     A,(HL)
        LD     (DE),A
INSLA1: IN     A,(LSE1)        ;bank off
        EI
        POP    BC
        POP    HL
        JP     INSLAS
;
;-------------------------------
;
;
;   line cal
;
;
;-------------------------------
;
LINCAL:
        LD     B,1
XPLI1:  LD     A,39            ;xe 39 or 79
        SUB    L
        LD     C,A
        EXX
XPLI2:  LD     DE,40           ;cwidth 80
        LD     H,0
        LD     L,A
        EXX
LINC1:  INC    H               ;next line check
        LD     A,(YE)
        CP     H
        JR     C,LINC2         ;scrool end check
        CALL   TBCALC
        LD     A,(HL)
        OR     A
        LD     H,E
        JR     Z,LINC2         ;manage ment check
        INC    B
        EXX
        ADD    HL,DE
        EXX
        JR     LINC1
;
;
LINC2:  LD     L,0
        RET
;
;
;
;----------------------------------
;
;    scrool main logic
;
;
;
;
;----------------------------------
SCROOL: CALL   PUSHRA
;---------------------------------
;
;  text buf scrool & clr
;
;---------------------------------
SCRTX:  LD     A,(YS)
        LD     H,A
        LD     L,0
        CALL   PONT            ;start addr  cal
        LD     D,H
        LD     E,L             ;DE destination addr
        LD     B,0
XPSC1:  LD     C,40            ;cwidth 80
        ADD    HL,BC           ;HL source addr
;
        LD     A,(YW)          ;scrool lines
        DEC    A
        JR     Z,SCR0          ;skip if 1 line mode
        PUSH   BC
        PUSH   HL
        LD     HL,0
SCR1:   ADD    HL,BC
        DEC    A
        JR     NZ,SCR1
        LD     B,H             ;scrool bytes
        LD     C,L
        POP    HL              ;pop source addr
        LDIR
        POP    BC
SCR0:   LD     B,C
        CALL   CLRDE          ;last line clr
;-----------------------------------
;
;   maneger buf scrool & clr
;
;-----------------------------------
        LD     A,(YS)
        LD     H,A
        CALL   TBCALC          ;exit HL maneger addr
        LD     A,(YW)          ;scrool lines
        DEC    A               ;1 line mode check
        LD     B,A
        LD     (HL),0
        INC    HL
        LD     D,H
        LD     E,L
        INC    DE
        CALL   NZ,LDHLDE       ;(hl)<--(de)
        LD     (HL),0          ;last line manegement
;
;----------------------------------
;
;    calculation xferad
;
;----------------------------------
SCRCAL: LD     A,(YE)
        LD     H,A
        LD     L,0             ;HL=(0,YE)
        CALL   PONTB
        LD     (XFERAD+1),HL   ;xferad data
;----------------------------------
;
;    scrool offset calc
;
;----------------------------------
SCXFER:
        LD     DE,40
        LD     HL,(SOF)        ;lsi scrool offset
        ADD    HL,DE
        PUSH   HL
        LD     DE,(SSW)        ;lsi scrool width
        OR     A
        SBC    HL,DE
        POP    HL
        JR     NZ,SCXF1        ;sof<ssw
        LD     HL,0
SCXF1:  LD     (SOF),HL
;----------------------------------
;
;   scrool  offset out
;
;----------------------------------
;
SCXF2:  IN     A,(LSDMD)       ;lsi status
        AND    40H             ;vblank check
        JR     NZ,SCXF2
        DI
        LD     C,LSSCR         ;lsi scrool port
        LD     B,2
        OUT    (C),H
        DEC    B
        OUT    (C),L
        LD     A,(CMODE)       ;crt mode st
        OUT    (LSRF),A        ;single mode
        OR     80H             ;replace mode
        OUT    (LSWF),A
;----------------------------------
;
;  xfer   buffer -->> graphic ram
;
;----------------------------------
        IN     A,(LSE0)        ; bank change
        OUT    (LSE0),A        ; cg off
XFERAD: LD     HL,0            ;LD HL,xxxxh
        LD     (HL),0
        LD     D,H
        LD     E,L
        INC    DE
XPSC2:  LD     BC,319          ;xfer bytes
        LDIR
        IN     A,(LSE1)        ;  bank reset
        EI
;----------------------------------
;
;
;      scrool operation ended
;
;        cursor window end pos
;
;----------------------------------
BOS:
        LD     A,(YE)
        LD     H,A
        LD     L,0
        JP     CURMOV
;
;-------------------------------
;
;     cursor  routines
;
;
;
;
;
;-------------------------------
;
CURSOR:
        CALL   PUSHRA
;
;cursor data pattern
        EXX
        PUSH   HL              ;push hl'
        LD     HL,CURDT1
        LD     A,(CURMAK)
        OR     A
        JR     Z,CURS0
        LD     HL,CURDT2
        DEC    A
        JR     Z,CURS0
        LD     HL,CURDT3
CURS0:  EXX
;
        DI
        LD     A,(CURFLG)
        XOR    1
        LD     (CURFLG),A
        LD     HL,(BITADR)
        LD     D,0
        LD     A,(CWIDTH)
        LD     E,A
        LD     B,8             ;counter
        LD     A,(CMODE)
        OR     20H             ;xor mode
        OUT    (LSWF),A        ;wf
        IN     A,(LSE0)        ;bank change
        OUT    (LSE0),A        ;cg off
;
CURS1:  EXX
        LD     A,(HL)
        INC    HL
        EXX
        LD     (HL),A
        ADD    HL,DE
        DJNZ   CURS1
        IN     A,(LSE1)        ;bank reset
        EXX
        POP    HL              ;pop hl'
        EXX
        EI
        RET
;
;
;
HCURON:
        CALL   PUSHRA
        XOR    A
        OUT    (LSD0),A        ;reset 556
        CPL
        OUT    (LSD0),A
        LD     A,(CURFLG)
        OR     A
        RET    NZ
        JR     CURSOR
;
;
HCUROF:
        CALL   PUSHRA
        LD     A,(CURFLG)
        OR     A
        RET    Z
        JR     CURSOR
;
;
FLASH:
        IN     A,(LSD2)        ;bit 6
        RLCA
        RLCA
        JR     NC,HCURON
        JR     HCUROF
;
;--------------------------------
;
;   cursor   move
;
;                ent HL x,y
;
;--------------------------------
;
CURMOV:
        CALL   PUSHR
        LD     (CURXY),HL
        CALL   PONT            ;cursor addr cal
        LD     (POSADR),HL
        CALL   PONTCB          ;bitmap cursor pos cal
        LD     (BITADR),HL
        RET


;-------------------------------
;
;   poniter calc
;
;          ent hl=curxy
;              hl=text addr
;-------------------------------
PONTC:
        LD     HL,(CURXY)
PONT:
        PUSH   DE
        PUSH   AF
        LD     D,20H           ;offset textbuf
        LD     E,L
        LD     A,H
        ADD    A,A             ;2
        ADD    A,A             ;4
        ADD    A,H             ;5
        LD     L,A
        LD     H,0
        ADD    HL,HL           ;10
        ADD    HL,HL           ;20
        ADD    HL,HL           ;40
XPCU1:  NOP                    ;ADD HL,HL *80
        ADD    HL,DE
        POP    AF
        POP    DE
        RET


;----------------------------------
;
;     pointer cal
;
;         ent hl=curxy
;             hl=bitmap addr
;
;----------------------------------
PONTCB:
        LD     HL,(CURXY)
PONTB:
        PUSH   DE
        PUSH   AF
        LD     D,H
        LD     E,0             ;de=h*256
        LD     A,L
        LD     L,H             ;l=curx
        LD     H,E             ;h=0
        ADD    HL,HL           ;*2
        ADD    HL,HL           ;*4
        ADD    HL,HL           ;*8
        ADD    HL,HL           ;*16
        ADD    HL,HL           ;*32
        ADD    HL,HL           ;*64
        ADD    HL,DE           ;*320
XPCU2:  NOP                    ;ADD HL,HL *640
        CALL   ADDHLA
        SET    7,H             ;offset bitmap addr
        POP    AF
        POP    DE
        RET
;
;------------------------------
;
;
;
;    cursor left,right,down,up
;
;
;------------------------------
;
HOME:   LD     L,0
        LD     A,(YS)
        LD     H,A
        JP     CSET
;
;
CR2:    CALL   PUSHR
        LD     HL,(CURXY)
        LD     A,L
        OR     A
        JR     NZ,CR1
        CALL   TBCALC
        LD     A,(HL)
        OR     A
        RET    Z
CR1:    LD     A,0DH
        JP     CRT1C
;
;
CTR_M:  XOR    A
        LD     (CRTSFG+1),A    ;sft mode reset
        LD     HL,(CURXY)
        PUSH   HL
        INC    H
        CALL   TBCALC
        LD     A,(YE)
        LD     D,A
CTR_ML: LD     A,(HL)
        OR     A
        JR     Z,CTR_M4
        INC    HL
        INC    E
        LD     A,D
        CP     E
        JR     NC,CTR_ML
CTR_M4: DEC    E
        POP    HL
        LD     H,E
        JR     CTR_M2
;
CDOWN:  LD     HL,(CURXY)
        JR     CDOWN2
;
CRIGHT: LD     HL,(CURXY)
        INC    L
        LD     A,(XE)
        CP     L
        JR     NC,CSET
CTR_M2:
        LD     L,0
CDOWN2: INC    H
        JR     CDOWN3          ;patch
        PUSH   HL
        CALL   TBCALC
        LD     (HL),1
        POP    HL
CDOWN3:
        LD     A,(YE)
        CP     H
        JR     NC,CSET
        LD     H,A
        PUSH   HL
        CALL   SCROOL
        POP    HL
CSET:   JP     CURMOV
;
;
CUP:    LD     HL,(CURXY)
        JR     CUP2
;
CLEFT:  LD     HL,(CURXY)
        LD     A,L
        OR     A
        JR     NZ,CSET2
        LD     A,(XE)
        LD     L,A
CUP2:   LD     A,(YS)
        CP     H
        JR     C,CSET3
        LD     A,(YS)
        LD     H,A
        DEFB   3EH
CSET2:  DEC    L
        DEFB   3EH
CSET3:  DEC    H
        JR     CSET
;
;
CTR_F:
;CTR_Y:
        XOR    A               ;ALPHA
        DEFB   21H
CTR_E:  LD     A,1             ;Shift lock
        DEFB   21H
CTR_W:  LD     A,2             ;GRAPH
        LD     (CURMAK),A
        RET
;
;----------------------------------
;
;
;
;     tab function
;
;
;----------------------------------
;
C_TAB:  LD     B,0             ;tab
        LD     HL,(CURXY)
        INC    L
        LD     A,L
CTAB1:  INC    B
        SUB    10
        JR     NC,CTAB1
        XOR    A
CTAB2:  ADD    A,10
        DJNZ   CTAB2
        LD     L,A
;
        LD     A,(XE)          ;boader check
        CP     L
        RET    C
;
        PUSH   HL
        LD     A,(INPFLG)
        OR     A
        JR     Z,CTAB4
        LD     A,(CURX)
;
        LD     H,A
        LD     A,L
        SUB    H
        JR     Z,CTAB4
        LD     B,A
CTAB3:  PUSH   BC
        LD     A,20H           ;space
        CALL   PLTOUT
        POP    BC
        DJNZ   CTAB3
CTAB4:  POP    HL
        JP     CURMOV
;------------------------------
;
; tab print function
;
;
;------------------------------
PRNTT:
        CALL   CRT1S
        LD     A,(CURX)
        SUB    10
        JR     NC,$-2
        ADD    A,10
        RET    Z
        JR     PRNTT
;
;
;------------------------------
;
;   GET LINE     V0.1A
;
;                  '84.7.11
;
;------------------------------
;
BINPUT:
        PUSH   HL
        LD     HL,(CURXY)
        PUSH   HL
        PUSH   DE
        CALL   TBCALC
        POP    DE
        LD     (HL),0
        POP    HL
        CALL   GETL
        JR     C,BINERT
        LD     A,L
        OR     A
        JR     Z,BINERT
        LD     H,0
        ADD    HL,DE
        EX     DE,HL
        OR     A
BINERT: POP    HL
        RET
;
;
GETL:
        PUSH   BC
        PUSH   HL
        PUSH   DE
LINP02: CALL   INKEY1
        CP     0DH             ;CR?
        JP     Z,GCRT
        CP     1BH             ;Break?
        JR     Z,LINP_B
        PUSH   AF
        LD     A,(CURMAK)
        CP     2               ;Graph mode?
        JR     NZ,LINP10
        POP    AF
        CP     17H
        JR     NC,LINP11
        CP     11H
        JR     C,LINP11
;
        LD     HL,(CTRSFT)
        BIT    6,L             ;Ctrl?
        JR     Z,LINP11
;
LINP32:
        RST    3
        DEFB   _CRT1X
        JR     LINP02
;
LINP10: POP    AF
LINP11:
        RST    3
        DEFB   _CRT1C
        JR     LINP02
;
LINP_B: SCF                    ;break key on
LINP80:
        RST    3
        DEFB   _CR1
        POP    DE
        POP    HL
        POP    BC
        RET
;
GCRT:   LD     HL,(CURXY)
        CALL   LBOUND          ;begin end search
        LD     A,E
        SUB    D
        LD     E,A             ;E:Y.length
        LD     H,D             ;H:line count
        LD     L,0
        CALL   PONT            ;calc start address
        LD     A,(CWIDTH)      ;X size
        LD     D,A
        POP    BC              ;store address set
        PUSH   BC
        EXX
        PUSH   HL
        LD     HL,(LINLIM)     ;L:line inp limit
        EXX
;
GCRT10:
        LD     A,(HL)          ;A<--ascii code
GCRT36: INC    HL
        LD     (BC),A          ;(BC)<--ascii code
        INC    BC
        EXX
        DEC    L
        JR     Z,GCRT40        ;line limit?
        EXX
        DEC    D
        JR     NZ,GCRT10       ;X right end ?
        LD     A,(CWIDTH)
        LD     D,A
        DEC    E
        JR     NZ,GCRT10       ;line count=0 ?
        EXX
GCRT40: POP    HL
        EXX
        XOR    A
        LD     (BC),A          ;end address=0
        LD     L,C
        LD     H,B
        POP    DE
        PUSH   DE
        PUSH   HL
        OR     A
        SBC    HL,DE
        LD     B,L
        POP    HL
        LD     A,20H           ;clschr?
        LD     D,A
        JP     Z,LINP80
        DEC    HL
GCRT50: LD     A,(HL)
        OR     A
        JR     Z,GCRT52
        CP     D
        JR     NZ,GCRT54
        LD     (HL),0
GCRT52: DEC    HL
        DJNZ   GCRT50
        JR     GCRT56
GCRT54: LD     A,(HL)
        OR     A
        JR     NZ,$+4
        LD     (HL),' '
        DEC    HL
        DJNZ   GCRT54
GCRT56: OR     A
        JP     LINP80
;
;-------------------------------
;
;     KEY      V0.1A
;
;                   '84.7.11
;
;-------------------------------
;
; INKEY$[(ACC)]
;   A=FF : INKEY$   =GET
;   A=0  : INKEY$(0)=KEY DATA
;   A>0  : INKEY$(1)=FLASH GET
;
INKEY:
        INC    A
        JR     Z,INKEYFF
        DEC    A
        JP     Z,INKEY0
;
;
INKEY1:
        CALL   KBFCHR
        CALL   PUSHR
        CALL   HCURON
        EX     AF,AF
        PUSH   AF
        CALL   KEYSNS
        LD     A,(REPTF)
_KEY10: EX     AF,AF
_KEY12: LD     B,16            ;chattering
_KEY14: CALL   FLASH
        CALL   KEYSNS
        BIT    1,A
        JR     NZ,_KEY12       ;same key ?
        DJNZ   _KEY14
        BIT    0,A
        JR     Z,_KEY20        ;key on ?
        BIT    2,A
        JR     NZ,_KEY24       ;new key ?
        EX     AF,AF
        DEC    A
        JR     NZ,_KEY10
        LD     A,6             ;Repeat step time
        JR     _KEY26
_KEY20: PUSH   HL
        PUSH   DE
        PUSH   BC
        LD     HL,KYDTB2
        LD     DE,KYDTB1
        LD     BC,10
        LDIR                   ;(KYDTB1)<--(KYDTB2)
        POP    BC
        POP    DE
        POP    HL
_KEY24: LD     A,40H           ;Repeat init time
_KEY26: LD     (REPTF),A
_KEY28: CALL   FLASH
        CALL   KEYGET
        OR     A
        JR     Z,_KEY29
        LD     (KEYDAT),A
        LD     C,A
        CALL   HCUROF
        POP    AF
        EX     AF,AF
        LD     A,C
        RET
;
_KEY29:
        PUSH   HL
        PUSH   BC
        LD     B,10
        LD     HL,KYDTB1
_KEY30: LD     (HL),0FFH
        INC    HL
        DJNZ   _KEY30
        POP    BC
        POP    HL
        JR     _KEY28
;
INKEYFF:
        CALL   KBFCHR
        PUSH   HL
        CALL   KEYGET
        LD     HL,KEYDAT
        OR     A
        JR     Z,INKEY9
        CP     (HL)
        JR     NZ,INKEY9
        POP    HL
        XOR    A
        RET
INKEY9: LD     (HL),A
        POP    HL
        RET
;
INKEY0:
        CALL   KBFCHR
        CALL   KEYGET
        LD     (KEYDAT),A
        RET
;
KBFCHR: PUSH   HL              ;function key buffer
        LD     HL,(INBUFC)
        LD     A,L             ;INBUFC
        CP     H               ;INBUFL
        POP    HL
        RET    Z
        EX     (SP),HL
        INC    A
        LD     (INBUFC),A
        LD     HL,INBUFL       ;INBUF-1
        CALL   ADDHLA
        LD     A,(HL)
        POP    HL
        RET
;
;
;
KEYSNS: CALL   PUSHR
        LD     DE,KYDTB2
        LD     HL,KYDTB1
        LD     BC,0A00H
        DI
KEYSN0: LD     A,B
        ADD    A,0EFH
        OUT    (0D0H),A
        CP     0F8H             ;special strobe
        IN     A,(0D1H)
        JR     NZ,$+4
        OR     7FH
        CP     0FFH
        JR     Z,$+4
        SET    0,C             ;bit 0=key on
        EX     DE,HL
        CP     (HL)
        LD     (HL),A
        EX     DE,HL
        JR     Z,$+4
        SET    1,C             ;bit 1=not same key
        CPL
        AND    (HL)
        JR     Z,$+4
        SET    2,C             ;bit 2=new key
        INC    HL
        INC    DE
        DJNZ   KEYSN0
        LD     A,C
KEYSNE: EI
        RET
;
KEYGET: CALL   PUSHR
        LD     HL,KYDTB1
        LD     DE,KYDTB2
        PUSH   HL
        PUSH   DE
        LD     BC,10
        LDIR                   ;(KYDTB2)<--(KYDTB1)
        POP    HL
        POP    DE
        LD     BC,0AF9H
        DI
        LD     A,C
        OUT    (0D0H),A
        NOP
        IN     A,(0D1H)
        LD     (DE),A
KEYGL1: LD     A,C
        OUT    (0D0H),A
        CP     0F8H             ;special strobe
        IN     A,(0D1H)
        LD     (DE),A
        JR     Z,KEYG13
        CPL
        AND    (HL)               ;same--->Acc=0
KEYGL3: LD     (HL),A
        INC    DE
        INC    HL
        DEC    C
        DJNZ   KEYGL1
        EI
       LD     BC,0A00H
KYSTCK: DEC    HL
        LD     A,(HL)
        OR     A
        JR     NZ,KEYGIN       ;not same-->KEYGIN
        INC    C
        DJNZ   KYSTCK
        LD     B,10
KEYGL2: DEC    DE
        LD     A,(DE)
        CP     0FFH
        JR     NZ,REPKIN
REPKI3: DJNZ   KEYGL2
KEYNUL: XOR    A
        JR     KEYSNE
;
KEYG13: XOR    A
        JR     KEYGL3
;
REPKIN: LD     A,B
        CP     2
        JR     NZ,REPKI2
        LD     A,(DE)
        AND    81H
        JR     NZ,REPKI3
        LD     A,1BH           ;break key
        JR     KEYSNE
REPKI2: CP     1
        JR     Z,KEYNUL
        LD     A,(REPCD1)
        CP     B
        JR     NZ,REPKI3
        LD     A,(DE)
        PUSH   DE
        LD     D,A
        LD     A,(REPCD2)
        AND    D
        POP    DE
        JR     NZ,REPKI3
        LD     A,(KEYDAT)
        JR     KEYSNE
;
KEYGIN: PUSH   AF
        LD     A,B
        LD     (REPCD1),A
        LD     A,(HL)
        LD     (REPCD2),A
        POP    AF
        DEC    B
        JR     NZ,KEYGI6
        CALL   ABITB           ;function key
        LD     A,(CTRSFT)
        BIT    6,A
        JR     Z,KEYNUL
        BIT    0,A
        LD     A,B
        JR     NZ,$+4
        ADD    A,5
        CP     10
        JR     NC,KEYNUL
        LD     L,A
        LD     H,0
        ADD    HL,HL
        ADD    HL,HL
        ADD    HL,HL
        ADD    HL,HL
        LD     BC,FUNBUF
        ADD    HL,BC
        LD     A,(HL)
        OR     A
        JR     Z,KEYNUL
        LD     DE,INBUFC
        LD     A,1
        LD     (DE),A
        INC    DE
        LD     BC,16
        LDIR
        LD     A,(INBUF)
        JP     KEYSNE
KEYGI6: CALL   ABITB
        LD     A,C
        ADD    A,A
        ADD    A,A
        ADD    A,A
        ADD    A,B
        LD     L,A
        LD     H,0
        LD     A,(CTRSFT)
        BIT    6,A             ;ctrl key
        LD     BC,NOMALB
        JR     Z,CTRLIN
        PUSH   AF
        LD     A,(CURMAK)
        CP     1               ;shift+lock
        JR     NZ,SFTLKL
        POP    AF
        XOR    1
        PUSH   AF
SFTLKL: POP    AF
        BIT    0,A             ;shift key
        JR     NZ,$+5
        LD     BC,SHIFTB
        LD     A,(CURMAK)
        CP     2               ;graph
        JR     NZ,CHRSET
        LD     BC,GRPHB
        LD     A,(CTRSFT)
        BIT    0,A
        JR     Z,CHRSET
        LD     BC,GRPHS
CHRSET: CALL   _KYTBL
        LD     A,C
        JP     KEYSNE
CTRLIN: CALL   _KYTBL
        LD     A,C
        CP     20H
        JP     C,KEYSNE
        LD     HL,CTKYTB
        LD     B,5
        CP     (HL)
        JR     Z,CTRLC1
        INC    HL
        DJNZ   $-4
        CP     40H
        JP     C,KEYNUL
        CP     5BH
        JP     NC,KEYNUL
        SUB    40H
        JP     KEYSNE
CTRLC1: LD     A,32
        SUB    B
        JP     KEYSNE
;
ABITB:  LD     B,8
        RRCA
        JR     C,ABITB2
        DJNZ   $-3
        RET
ABITB2: DEC    B
        RET
;
;
BRKEY:
        LD     A,0E8H
        OUT    (0D0H),A
        NOP
        IN     A,(0D1H)
        AND    81H
        RET    Z
        RLCA
        RET    C
        JR     BRKEY
;
KYDTB1: DEFS   1
CTRSFT: DEFS   9
KYDTB2: DEFS   10
REPTF:  DEFB   0
REPCD1: DEFB   0
REPCD2: DEFB   1
;
;
NOMALB: DEFW   0BEAH
        DEFB   0x90,0x17,0xFC,0x19,0x09,0x3B,0x3A,0x0D
        DEFB   0x18,0x10,0x12,0x11,0x13,0x14,0x3F,0x2F
;
SHIFTB: DEFW   0C2AH
        DEFB   0x90,0x17,0xFB,0x05,0x09,0x2B,0x2A,0x0D
        DEFB   0x16,0x15,0x12,0x11,0x13,0x14,0xC6,0x5F
;
GRPHB:  DEFW   0CE9H
        DEFB   0x90,0x17,0x68,0x05,0x09,0x84,0xE9,0x0D
        DEFB   0x16,0x15,0x12,0x11,0x13,0x14,0x8F,0x8B
;
GRPHS:  DEFW   0C6AH
        DEFB   0x90,0x17,0x6C,0x19,0x09,0xFE,0x89,0x0D
        DEFB   0x16,0x15,0x12,0x11,0x13,0x14,0x8A,0x7B
;
CTKYTB: DEFB   5BH             ;  [
        DEFB   5CH             ;  \
        DEFB   5DH             ;  ]
        DEFB   5EH             ;  ^
        DEFB   2FH             ;  /


;-----------------------------------
;
;
;  CRT message out
;
;   05H,06H simulated
;
;      ent. DE=msg top addr
;           eof is NULL
;           mode code 05h,06h
;          CR is reset mode
;-----------------------------------
;
CRTSIMU:CALL   PUSHR
CRTSI2: LD     A,(DE)          ;get msg data
        INC    DE              ;next pointer
        OR     A
        RET    Z               ;eof code is NULL
        LD     C,A
        CP     05H             ;sft lock in
        JR     Z,CRTSIE        ;CTR_E
        CP     06H             ;normal mode
        JR     Z,CRTSIF        ;CTR_F
        SUB    'A'
        CP     26
        JR     NC,CRTSI4       ;skip not if code A-Z
CRTSFG: LD     A,0             ;xxx
        OR     A
        JR     Z,CRTSI4
        LD     HL,SMLTBL-'A'   ;sftlock code trans.
        LD     B,0
        ADD    HL,BC
        LD     C,(HL)
;
CRTSI4: LD     A,C
        RST    3
        DEFB   _CRT1C
        CP     0DH
        JR     NZ,CRTSI2
CRTSIF: XOR    A
CRTSIE: LD     (CRTSFG+1),A
        JR     CRTSI2
;
SMLTBL:
        DEFB   0A1H            ;a
        DEFB   09AH            ;b
        DEFB   09FH            ;c
        DEFB   09CH            ;d
        DEFB   092H            ;e
        DEFB   0AAH            ;f
        DEFB   097H            ;g
        DEFB   098H            ;h
        DEFB   0A6H            ;i
        DEFB   0AFH            ;j
        DEFB   0A9H            ;k
        DEFB   0B8H            ;l
        DEFB   0B3H            ;m
        DEFB   0B0H            ;n
        DEFB   0B7H            ;o
        DEFB   09EH            ;p
        DEFB   0A0H            ;q
        DEFB   09DH            ;r
        DEFB   0A4H            ;s
        DEFB   096H            ;t
        DEFB   0A5H            ;u
        DEFB   0ABH            ;v
        DEFB   0A3H            ;w
        DEFB   09BH            ;x
        DEFB   0BDH            ;y
        DEFB   0A2H            ;z


EQTBL:
;---------------------------------
;
;
;
; CRT/KB driver
;
;
;---------------------------------
_CRT:
        DEFW   _KB
        DEFM   "CRT"
        DEFB   0
        DEFB   8AH             ;Streem, O1C, W
        DEFW   0
IF RAMDISK
        DEFW   CRTINI_0
ELSE
        DEFW   CRTINI
ENDIF
        DEFW   __RET           ;ROPEN
        DEFW   __RET           ;WOPEN
        DEFW   __RET           ;CLOSE
        DEFW   __RET           ;KILL
        DEFW   CRTIN
        DEFW   CRTOUT
        DEFW   CRTPOS
_KB:
        DEFW   _LPT
        DEFM   "KB"
        DEFW   0
        DEFB   81H             ;Streem, R
        DEFW   0
        DEFW   __RET           ;INIT
        DEFW   __RET           ;ROPEN
        DEFW   __RET           ;WOPEN
        DEFW   __RET           ;CLOSE
        DEFW   __RET           ;KILL
        DEFW   CRTIN
        DEFW   __RET
        DEFW   __RET
;
CRTIN:
        RST    3
        DEFB   _GETL
        LD     A,80H           ;BREAKZ
        RET    C
        RST    3
        DEFB   _COUNT
        RET

CRTOUT: EX     AF,AF
        LD     HL,CRT1C
        LD     A,(DISPX)       ;0=msg/1=msgx
        OR     A
        JR     Z,$+5
        LD     HL,CRT1CX
        EX     AF,AF
        JP     (HL)

CRTPOS: LD     A,(CURX)
        RET


;
;----------------------------------
;
;
; CRT(LPT) routine
;
;     CRT1C  PR_1C
;     CRT1CX PR_1CX
;     CRTMSG PR_MSG
;            PR_CR
;
;---------------------------------
;
PR_CR:    LD     A,0DH
;
PR_1C:    PUSH   AF
        LD     A,(FILOUT)      ;0=crt/1=lpt
        OR     A
        JR     NZ,_1CL
        POP    AF
        JR     CRT1C
_1CL:   POP    AF
        JP     LPT1C
;
PR_1CX:   PUSH   AF
        LD     A,(FILOUT)      ;0=crt/1=lpt
        OR     A
        JR     NZ,_1CXL
        POP    AF
        JR     CRT1CX
_1CXL:  POP    AF
        JP     LPT1CX
;
PR_MSG:   CALL   PUSHR
        LD     HL,PR_1C
        JR     CRTMS2
;
CRTMSG: CALL   PUSHR
        LD     HL,CRT1C
CRTMS2: LD     A,(DE)
        OR     A
        RET    Z
        CALL   _HL
        INC    DE
        JR     CRTMS2


;
CRT1S:  LD     A,' '
CRT1C:
        CALL   PUSHRA
CRT1C0:
        LD     C,A
        LD     A,(INPFLG)      ;plot on/off
        OR     A
        JR     Z,CRT1C9        ;skip if plot off
        LD     A,C
        CP     20H
        JR     NC,CRT1C4       ;skip if normal ascii
        LD     DE,(CURXY)      ;control code only
        LD     HL,(XS)
        CP     14H
        JR     Z,CRT1C1        ;skip if left code
        CP     12H
        JR     NZ,CRT1C2       ;
        LD     HL,(YS)         ;skip if up code
        LD     E,D
CRT1C1: LD     A,L
        CP     E
        JP     NC,_BEEP        ;error range
CRT1C2:
        LD     HL,PLTCOD       ;plotter code  trans.
        LD     B,0
        ADD    HL,BC
        LD     A,(HL)
        INC    A
        JR     Z,CRT1C9        ; no operation when ffh
        DEC    A
        JP     Z,_BEEP         ;beep when null code
CRT1C4: CALL   PLTOUT
CRT1C9: LD     A,C
        CP     20H
        JP     C,CTRLJB        ;control code trans.
        JP     ACCDI           ;1 byte disply ent.=acc
;
CRT1CX: CALL   PUSHRA
        LD     C,A
        CP     0DH
        JR     Z,CRT1C0
        CALL   ACCDI
        LD     A,(INPFLG)      ;plot on/off
        OR     A
        RET    Z
        LD     A,C
;       JR     PLTOTX


;
PLTOTX:
        CP     11H
        JR     C,PLT2E
        CP     17H
        JR     C,PLTOK
        CP     20H
        JR     C,PLT2E
PLTOUT: CP     60H
        JR     C,PLTOK
        CP     70H
        JR     C,PLT2E
        CP     0C1H
        JR     C,PLTOK
        CALL   CHKACC
        DEFB   3
        DEFW   0CFD7H
        DEFB   0FFH
        JR     Z,PLTOK
PLT2E:  LD     A,2EH
PLTOK:  JP     LPTOUT
;
PLTCOD: DEFB   0               ;00
        DEFB   0               ;01
        DEFB   0               ;02
        DEFB   0               ;03
        DEFB   0FFH            ;04 CTR_D
        DEFB   0FFH            ;05 CTR_E
        DEFB   0FFH            ;06 CTR_F
        DEFB   1DH             ;07
        DEFB   0               ;08
        DEFB   0FFH            ;09 C_TAB
        DEFB   0               ;0A
        DEFB   0               ;0B
        DEFB   0               ;0C
        DEFB   0DH             ;0D
        DEFB   0               ;0E
        DEFB   0               ;0F
        DEFB   0               ;10 DEL
        DEFB   0AH             ;11 DOWN
        DEFB   03H             ;12 UP
        DEFB   20H             ;13 RIGHT
        DEFB   0EH             ;14 LEFT
        DEFB   0               ;15 HOME
        DEFB   0               ;16 CLR
        DEFB   0FFH            ;17 GRAPH
        DEFB   0               ;18 INST
        DEFB   0FFH            ;19 ALPHA
        DEFB   0FFH            ;1A KANA
        DEFB   0DH             ;1B
        DEFB   0FFH            ;1C hirakana
        DEFB   0               ;1D
        DEFB   0               ;1E
        DEFB   0               ;1F


;
;--------------------------------
;
;  Monitor hot start
;
;
;--------------------------------
STARTP:
        DI
        XOR    A
        OUT    (LSDMD),A       ;mz-800 320*200 4col
        LD     (INPFLG),A      ;plot on/off
        LD     (FILOUT),A      ;0=crt/1=lpt
        LD     SP,0000H        ;stack pointer set
        IM     2               ;interruptt mode 2
        LD     A,4
        OUT    (LSD3),A        ;8253 int disable
        OUT    (LSE0),A        ;bank dram
        OUT    (LSE1),A        ;bank dram
        CALL   PALOFF          ;palette all off
        LD     A,0FH           ;interrupt vector
        LD     I,A
        LD     A,0FEH           ;interrupt addrs
        OUT    (0FDH),A         ;PIO int vector set
        LD     A,0FH
        OUT    (0FDH),A         ;PIO mode 0
        PUSH   BC
        CALL   CRTPWR          ;CRT power on init
        CALL   PSGPWR          ;PSG power on init
        CALL   EMMPWR          ;EMM power on init
        POP    BC
STRTP2: DEFB   21H             ;dummy byte
        JR     STRTP9

        XOR    A
        LD     (STRTP2),A
        LD     D,A
        LD     E,A
        RST    3
        DEFB   _TIMST
        LD     DE,_CMT
        LD     A,B
        OR     A
        JR     Z,STRTP4
        DEC    A
        JR     Z,STRTP4
        LD     DE,_FD
        DEC    A
        JR     Z,STRTP4
        LD     DE,_QD
STRTP4: LD     A,C
        RST    3
        DEFB   _SETDF
STRTP9: JP     COLDST
;
;
;
;
CRTPWR:
;  check vram option ?
;
        DI
        XOR    A
        OUT    (LSDMD),A       ;320*200 4 color
        LD     A,14H
        OUT    (LSRF),A
        LD     A,94H
        OUT    (LSWF),A
        IN     A,(LSE0)
        OUT    (LSE0),A        ;cg off
        LD     HL,9FFFH
        LD     A,(HL)          ;read
        LD     C,A
        CPL
        LD     (HL),A          ;write
        CP     (HL)            ;verify
        LD     (HL),C          ;pop mem
        LD     A,0
        JR     NZ,CRTPW0
        INC    A
CRTPW0: LD     (MEMOP),A
        IN     A,(LSE1)
        EI
;
        LD     A,1             ;window (0,24)
        CALL   DSMODE          ;320*200 4 color
;
; data free area init
;
;
        XOR    A
        LD     (CURFLG),A      ;cursor off
        LD     (CURMAK),A      ;nomal char
        RET
;
;
; -----------------------------
; MZ-2Z009    User I/O driver
; FI:MON-USR  ver 1.0A 03.17.84
; -----------------------------
;
;
;
_USR:
        DEFW   0
        DEFM   "USR"
        DEFB   0
        DEFB   9FH             ;STRM, FNM, W1C, R1C, W, R
        DEFW   0
        DEFW   __RET           ;INIT
        DEFW   USRRO           ;ROPEN
        DEFW   USRWO           ;WOPEN
        DEFW   __RET           ;CLOSE
        DEFW   __RET           ;KILL
        DEFW   USRIN           ;INP
        DEFW   USROUT          ;OUT
        DEFW   __RET           ;POS
;
USRRO:
USRWO:  LD     HL,ELMD1
        RST    3
        DEFB   _DEASC
        LD     A,D
        OR     E
        JP     Z,ER60

IF RAMDISK
        ;-------------------------
        LD     (USROUT+1),DE
		RET
USRIN:
USROUT: LD     HL,ZWRK1			; "ZWRK1" is probably patched by the code above before a jp happens
        ;-------------------------
ELSE

        LD     (ZWRK1),DE
        RET
USRIN:
USROUT: LD     HL,(ZWRK1)

ENDIF
;
        JP     (HL)

;       END  (0FABH)


IO_END:
DEFS $FF0-IO_END

; -------------------------
; MZ-800 monitor Work area
; FI:MON2  ver 1.0A 9.05.84
; -------------------------
;

;
;
;  Interrupt vector
;
;
;        ORG    0FF0H
        DEFS   12              ;interrupt reserve
;
;        ORG    0FFCH
        DEFW   PSGINT          ;PSG(timer) interrupt
        DEFW   LPTINT          ;Printer intrrupt
;
; Directry entry
;
;        ORG    1000H
ELMD:                    ;file mode
        DEFS   1
ELMD1:                    ;file name
        DEFS   17
ELMD18:                    ;protection, type
        DEFS   2
ELMD20:                    ;size
        DEFS   2
ELMD22:                    ;adrs
        DEFS   2
ELMD24:                    ;exec
        DEFS   2
ELMD26:
        DEFS   4
ELMD30:
        DEFS   2
ELMD32:
        DEFS   32
;
;  LU table entry
;
ZTOP:                    ;LU block top
        DEFW   2
ZLOG:                    ;LU#
        DEFB   0
ZRWX:                    ;1:R, 2:W, 3:X
        DEFB   0
ZEQT:                    ;Address of EQTBL
        DEFW   0
ZCH:                    ;CH#
        DEFB   0
ZEOF:                    ;EOF?
        DEFB   0
ZWRK1:                    ;Work 1
        DEFB   0
ZWRK2:                    ;Work 2
        DEFB   0
;


;
; EQT table entry
;
ZNXT:                     ;STRM  SQR    RND
        DEFW   0
ZDEVNM:                   ;-- device name --
        DEFS   4
ZFLAG1:                   ;----- flag 1 ----
        DEFB   1
ZFLAG2:                   ;----- flag 2 ----
        DEFB   0
ZDIRMX:                   ;---- max dir ----
        DEFB   0
ZINIT:                    ;--- initialize --
        DEFW   0
ZRO:                      ;ROPEN RDINF
ZMAPS:                    ;            Map.start
        DEFW   0
ZWO:                      ;WOPEN WRFIL
ZMAPB:                    ;            Map.bytes
        DEFW   0
ZCL:                      ;CLOSE
ZSTRT:                    ;      START
ZDIRS:                    ;            Dir.start
        DEFW   0
ZKL:                      ;KILL
ZBLK:                     ;      - Block/byte -
        DEFW   0
ZINP:                     ;INP   RDDAT BREAD
        DEFW   0
ZOUT:                     ;OUT   WRDAT BWRIT
        DEFW   0
ZPOS:                     ;Position
ZDELT:                    ;      DELETE
        DEFW   0
ZWDIR:                    ;      WR DIR
        DEFW   0
ZFREE:                    ;      - free bytes -
        DEFW   0
;
defc  ZBYTES =  ZFREE+2-ZNXT    ;Z-area bytes
;
        DEFS   2
;
DCHAN:                    ;default channel
        DEFS   1
DDEV:                     ;default device
        DEFS   2
;
;
__CRT:
        DEFW   _CRT
__LPT:
        DEFW   _LPT
;


;
;
;   Work area pointers
;
TEXTST: DEFS    2               ; Basic - beginning of program ("Text start")
;
POOL:   DEFS    2               ; File work areas (I/O work area)
;
VARST:  DEFS    2               ; Start of Basic variables area
;
STRST:  DEFS    2               ; Start of string text area
;
VARED:  DEFS    2               ; Var & string end
;
TMPEND: DEFS    2               ; End of string work area
;
INTFAC: DEFS    2               ; Start of arithmetic memory (FAC)
;
MEMLMT: DEFS    2               ; LIMIT - address
;
MEMMAX: DEFW    0FF00H          ; Maximum allowed RAM address  (last available memory)

;
;
;    cursor / position work
;
;
;
CURXY:                    ;cursor position
CURX:
        DEFB   0
CURY:
        DEFB   0
POSADR:                    ;text buf addr
        DEFW   TEXTBF
BITADR:                    ;bitmap mem addr
        DEFW   8000H
;
POINTX:                    ;Graphic x-coordinate
        DEFS   2
POINTY:                    ;Graphic y-coordinate
        DEFS   2
;
CURFLG:                    ;0:off 1:on
        DEFB   0
CURMAK:                    ;cursor mark 0=normal
        DEFB   0               ;            1=sftlock,   2=graph


;
; CRT/LPT work
;
CMTMSG:                    ;if =0 disp cmt-msg
        DEFS   1
INPFLG:                    ;0=plot off 1=plot on
        DEFB   0
DISPX:                     ;0=MSG 1=MSGX
        DEFS   1
FILOUT:                    ;0=CRT 1=LPT
        DEFB   0
PSEL:                      ;Printer select
        DEFB   1
PCRLF:                     ;LPT CRLF CODE
        DEFB   0DH
LPT_TM:                    ;LPT wait time
        DEFB   14
LPOSB:                     ;LPT position
        DEFB   0
PSMAL:                     ;LPT small/capital
        DEFB   0
PNMODE:                    ;LPT mode
        DEFB   1               ; 1..text, 2..graph
;
;
;  crt dispmode work
;
;
DMD:                    ;disp mode  0 320 4  col
        DEFB   0               ;            2 320 16 col
;                  4 640 2  col
;                  6 640 4  col
MEMOP:                    ;option mem exit
        DEFB   0               ;0= off 1= on
PWMODE:                   ;graphic operation mode
        DEFB   0
CMODE:                    ;color mode
        DEFB   3
CPLANE:                   ;curent active plane
        DEFB   3
MAXCF:                    ;maximum plane data
        DEFB   4
PMASK:                    ;mask plane data
        DEFB   0FFH
GMODE:                    ;graphic color mode
        DEFB   3
;
        DEFS   50H             ;10A0 -- 10EF monitor stack
;
;
;
IBUFE:                    ;CMT workspace
IFDEF RAMDISK
        DEFB   0x2e, 0x2e, 0x2e, 0x2e, 0x2e, 0x2e, 0x2e, 0x2e, 0x2e, 0x2e, 0x2e, 0x2e
        DEFB   0x2e, 0x2e, 0x2e, 0x2e, 0x2e, 0x2e, 0x2e, 0x2e, 0x2e, 0x2e, 0x2e, 0x2e
        DEFB   0xe0, 0xe0, 0xe0, 0xe0, 0xe0, 0xe0, 0xe0, 0xe0
		DEFM   "MZ-5Z009"
        DEFB   0xd7, 0xd7, 0xd7, 0xd7, 0xd7, 0xd7, 0xd7, 0xd7
        DEFB   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
		DEFM   "*********V.1.02*********"
        DEFB   0x2e, 0x2e, 0x2e, 0x2e, 0x2e, 0x2e, 0x2e, 0x2e, 0x2e, 0x2e, 0x2e, 0x2e
        DEFB   0x2e, 0x2e, 0x2e, 0x2e, 0x2e, 0x2e, 0x2e, 0x2e, 0x2e, 0x2e, 0x2e, 0x2e
        DEFS   24
ELSE
        DEFS   128
ENDIF
;
        DEFS   34
;FLSDT:
        DEFB   0EFH            ;FLSDT
        DEFS   2               ;STRFG, DPRNT
TMCNT:
        DEFS   2
SUMDT:
        DEFS   2               ;SUMDT
CSMDT:
        DEFS   2               ;CSMDT
        DEFS   2               ;AMPM, TIMFG
        DEFB   1               ;SWRK
TEMPW:
        DEFB   4               ;TEMPW
        DEFB   5               ;ONTYO
        DEFS   3               ;OCTV, RATIO
;
KEYBM1:
        DEFS   1

; 270 bytes for Keyboard buffer
KEYBUF:
        DEFS   262
KEY262:
        DEFS   2
KEY264:
        DEFS   2
KEY266:
        DEFS   4

; FN key definition table
FUNBUF:
        DEFB   7
        DEFM   "RUN   "
        DEFB   0DH
        DEFS   15-7

IF ALTFN
        DEFB   6
        DEFM   "LIST  "
        DEFS   15-6

        DEFB   6
        DEFM   "LOAD  "
        DEFS   15-6

        DEFB   6
        DEFM   "SAVE  "
        DEFS   15-6

        DEFB   7
        DEFM   "VERIFY"
        DEFB   0DH
        DEFS   15-7

        DEFB   14
        DEFM   "INIT\"CRT:M2\""
		DEFB   0x14,0x14
        DEFS   15-14

        DEFB   15
        DEFM   "INIT\"LPT:M0,S2,"

        DEFB   11
        DEFM   "OUT@ $E9,0"
		DEFB   0x14
        DEFS   15-11

        DEFB   8
        DEFM   "DEF.CMT"
        DEFB   0DH
        DEFS   15-8

        DEFB   8
        DEFM   "DIRRAM "
        DEFB   0DH
        DEFS   15-8

ELSE
        DEFB   5
        DEFM   "LIST "
        DEFS   15-5

        DEFB   5
        DEFM   "AUTO "
        DEFS   15-5

        DEFB   6
        DEFM   "RENUM "
        DEFS   15-6

        DEFB   6
        DEFM   "COLOR "
        DEFS   15-6

        DEFB   5
        DEFM   "CHR$("
        DEFS   15-5

        DEFB   8
        DEFM   "DEF KEY("
        DEFS   15-8

        DEFB   4
        DEFM   "CONT"
        DEFS   15-4

        DEFB   6
        DEFM   "SAVE  "
        DEFS   15-6

        DEFB   6
        DEFM   "LOAD  "
        DEFS   15-6
ENDIF

;
INBUFC:                    ;INBUF counter
        DEFB   0
INBUFL:                    ;INBUF length
        DEFB   0
INBUF:                    ;pending key 16
        DEFS   16
;
LINLIM:                    ;getline buffer limit
        DEFB   255             ;const
KEYDAT:
        DEFB   0
;
;    timer work
;
AMPM:
        DEFB   0
SECD:
        DEFW   0
;
;    scrool work
;
XS:                    ;console X start const=0
        DEFB   0
XE:                    ;console X end
        DEFB   39
CWIDTH:                    ;console width
        DEFW   40              ;cwidth=xe+1
CSIZE:                    ;csize=cwidth*8
        DEFW   320
YS:                    ;console Y start
        DEFB   0
YE:                    ;console Y end
        DEFB   24
YW:                    ;console Y width
        DEFB   25              ;yw=ye-ys+1
;
;    scrool custom data
;
SOF:                    ;scrool offset
        DEFW   0
SW:                    ;scrool width
        DEFB   7DH             ;sw  = yw*5
SSA:                    ;scrool start
        DEFB   0               ;ssa = ys*5
SEA:                    ;scrool end
        DEFB   7DH             ;sea =(ye+1)*5
SSW:                    ;scrool offset limit
        DEFW   3E8H            ;ssw = sw *8
;
;     crt work (basic used)
;
CRTMD1:                    ;crt bit data
        DEFB   1
CRTMD2:                    ;crt mode no. data
        DEFB   1
SELCOL:                    ;default color
        DEFB   3
PAIWED:
        DEFW   0               ;paint stack end
;
;
;
;     palette work
;
PALBK:                    ;palette block number
        DEFB   0
PALAD:                    ;palette init addr
        DEFW   PAL4T
PALTBL:                    ;palette data table
        DEFS   4
;
;
;     palette init data table
;
PAL2T:                    ;palette
        DEFB   00H             ;PAL 0 black
        DEFB   1FH             ;PAL 1 white
        DEFB   2FH             ;PAL 2 white
        DEFB   3FH             ;PAL 3 white
;
PAL4T:                    ;palette
        DEFB   00H             ;PAL 0 black
        DEFB   11H             ;PAL 1 blue
        DEFB   22H             ;PAL 2 red
        DEFB   3FH             ;PAL 3 white
;
PAL16T:                    ;palette
        DEFB   00H             ;PAL 0 black
        DEFB   11H             ;PAL 1 blue
        DEFB   22H             ;PAL 2 red
        DEFB   33H             ;PAL 3 purple
;
;
;     cursor  init data table
;
CURDT1:                    ;cursor normal
        DEFB   0FFH             ;0
        DEFB   0FFH             ;1
        DEFB   0FFH             ;2
        DEFB   0FFH             ;3
        DEFB   0FFH             ;4
        DEFB   0FFH             ;5
        DEFB   0FFH             ;6
        DEFB   0FFH             ;7
;
CURDT2:                    ;cursor sftlock
        DEFB   7EH             ;0
        DEFB   0FFH             ;1
        DEFB   0FFH             ;2
        DEFB   0FFH             ;3
        DEFB   0FFH             ;4
        DEFB   0FFH             ;5
        DEFB   0FFH             ;6
        DEFB   7EH             ;7
;
CURDT3:                    ;cursor graph
        DEFB   00H             ;0
        DEFB   00H             ;1
        DEFB   00H             ;2
        DEFB   00H             ;3
        DEFB   00H             ;4
        DEFB   00H             ;5
        DEFB   00H             ;6
        DEFB   0FFH             ;7
;
;   screen management buffer
;
SCRNT0:
        DEFS   25
SCRNTE: DEFB   0
;
;
;     emm  work
;
;
EMFLG:
        DEFS   1
EMPTR:
        DEFS   2
EMWP0:
        DEFS   2
EMWP1:
        DEFS   2


; ------------------------------
;
;  lpt work
;
; ------------------------------
;
WPULSE: DEFB   0
WSTROB: DEFB   0
PBCMAW: DEFW   3FF0H
PBCN:
        DEFW   0               ;
PBCIP:  DEFW   0C000H           ;FIFO inp pointer
PBCOP:  DEFW   0C000H           ;FIFO out pointer
PBCTOP: DEFW   0C000H           ;buffer top
SPLFLG: DEFB   0               ;spool on/stop/off
OUTIMF: DEFB   0               ;output image flag
HPCOUN: DEFB   4               ;printer counter
HERRF:
        DEFB   0               ;ROM error flag
;
;
;---------------------------------
;
;
;    code translation table
;
;---------------------------------
;
CTABLE:
        DEFW   CTABL1          ;change table address
;
;
CTABL1: DEFB   39              ;change number
;
;
        DEFB   023H            ;#
        DEFB   023H
;
        DEFB   040H            ;@
        DEFB   040H
;
        DEFB   05BH            ;[
        DEFB   05BH
;
        DEFB   05CH            ;\
        DEFB   05CH
;
        DEFB   05DH            ;]
        DEFB   05DH
;
        DEFB   08BH            ;^
        DEFB   05EH
;
        DEFB   090H            ;under_
        DEFB   05FH
;
        DEFB   093H            ;'
        DEFB   060H
;
        DEFB   0A1H            ;a
        DEFB   061H
;
        DEFB   09AH            ;b
        DEFB   062H
;
        DEFB   09FH            ;c
        DEFB   063H
;
        DEFB   09CH            ;d
        DEFB   064H
;
        DEFB   092H            ;e
        DEFB   065H
;
        DEFB   0AAH            ;f
        DEFB   066H
;
        DEFB   097H            ;g
        DEFB   067H
;
        DEFB   098H            ;h
        DEFB   068H
;
        DEFB   0A6H            ;i
        DEFB   069H
;
        DEFB   0AFH            ;j
        DEFB   06AH
;
        DEFB   0A9H            ;k
        DEFB   06BH
;
        DEFB   0B8H            ;l
        DEFB   6CH
;
        DEFB   0B3H            ;m
        DEFB   6DH
;
        DEFB   0B0H            ;n
        DEFB   6EH
;
        DEFB   0B7H            ;o
        DEFB   6FH
;
        DEFB   09EH            ;p
        DEFB   70H
;
        DEFB   0A0H            ;q
        DEFB   71H
;
        DEFB   09DH            ;r
        DEFB   72H
;
        DEFB   0A4H            ;s
        DEFB   73H
;
        DEFB   096H            ;t
        DEFB   74H
;
        DEFB   0A5H            ;u
        DEFB   75H
;
        DEFB   0ABH            ;v
        DEFB   76H
;
        DEFB   0A3H            ;w
        DEFB   77H
;
        DEFB   09BH            ;x
        DEFB   78H
;
        DEFB   0BDH            ;y
        DEFB   79H
;
        DEFB   0A2H            ;z
        DEFB   7AH
;
        DEFB   0BEH            ;{
        DEFB   7BH
;
        DEFB   0C0H            ;Ý
        DEFB   7CH
;
        DEFB   080H            ;}
        DEFB   7DH
;
        DEFB   094H            ;~
        DEFB   7EH
;
        DEFB   07FH            ;
        DEFB   7FH
;
;
;       END (142BH)


;        ORG    142BH

;
;---------------------------------
;   XMON-ROM   8.30.84
;
;  JISX   MZ-800 --> ASC
;    ent A     :data
;        IX    :output sub
;        (HL)  :tab counter
;        E     :DISPX
;
;---------------------------------
;
;
JISX:
        CP     0DH
        JR     Z,JISXCR
        CP     0AH
        JR     Z,JISXCR
        CALL   AJISX           ;code change
        CP     20H
        JR     NC,_IX
        BIT    0,E             ;print/p ?
        JR     Z,_IX           ;no
        LD     A,' '
_IX:    JP     (IX)
;
JISXCR: CALL   _IX
        LD     (HL),0
        RET
;
AJISX:  PUSH   BC
        LD     C,0
        CALL   AJISX1
        POP    BC
        RET
;
;
AJISX1: CALL   PUSHR
        LD     HL,(CTABLE)
        LD     B,(HL)          ;code counter set
        INC    HL              ;HL=MZ-800
        LD     D,H             ;DE=JIS
        LD     E,L
        INC    DE
        BIT    0,C             ;MZ-800 --> JIS ?
        JR     Z,AJISX2        ;yes
        EX     DE,HL
AJISX2: CP     (HL)
        JR     Z,AJISX3        ;code match
        INC    HL
        INC    HL
        INC    DE
        INC    DE
        DJNZ   AJISX2
        RET
;
AJISX3: LD     A,(DE)
        RET
;
;
;---------------------------------
;
;
;  JISR   ASC    --> MZ-800
;    ent (A)   :data
;        IX    :input  sub
;
;---------------------------------
;
;
JISR:
        CALL   _IX             ;input sub :A set
        RET    C
;
        PUSH   BC
        LD     C,1
        CALL   AJISX1
        POP    BC
        OR     A
        RET
;---------------------------------
;
_LPT:
        DEFW   _CMT
        DEFM   "LPT"
        DEFB   0
        DEFB   8AH             ;Streem, O1C, W
        DEFW   0
        DEFW   LPTINI
        DEFW   ER59            ;ROPEN
        DEFW   __RET           ;WOPEN
        DEFW   __RET           ;CLOSE
        DEFW   __RET           ;KILL
        DEFW   0               ;INP
        DEFW   LPT1C_
        DEFW   LPTPOS
;
;
PIO_AC  =  0FCH             ;Port-A control
PIO_AD  =  0FEH             ;Port-A data
PIO_BC  =  0FDH             ;Port-B control
PIO_BD  =  0FFH             ;Port-B data
;
P_PLT   =   0               ;1P01, 1P09
P_KP5   =   1               ;KP5
P_JIS   =   2               ;JIS code
P_THRU  =   3               ;thrue
;
;
LPTPOS: LD     A,(INPFLG)
        OR     A
        LD     A,(LPOSB)
        RET    Z
        LD     A,(CURX)
        RET
;
;
;
;----------------------------------
;
;        PL ROM CALL
;
;----------------------------------
defc ROMST  =  03H             ;F403H
defc ROMST1 =  0F400H
;
;
TIMST:
        CALL   ROMJP2
        DEFB   ROMST
;
TIMRD:
        CALL   ROMJP2
        DEFB   ROMST+3
;
STICK:
        CALL   ROMJP2
        DEFB   ROMST+6
;
STRIG:
        CALL   ROMJP2
        DEFB   ROMST+9
;
HCPY:
        CALL   ROMJP
        DEFB   ROMST+12
;
LPT1C_:
        LD     HL,DISPX
        BIT    0,(HL)
        JR     NZ,LPT1CX
;
LPT1C:
        PUSH   IY
        EX     AF,AF
        LD     A,3+15          ;F003+15
        LD     (APL1CD),A
        LD     A,_CRT1C
APL1CF: LD     (APL1CE),A
        EX     AF,AF
        CALL   APL1C
        POP    IY
        PUSH   BC
        LD     B,A
        LD     A,(INPFLG)
        OR     A
        LD     A,B
        POP    BC
        RET    Z
        RST    3
APL1CE: DEFB   _CRT1C
        RET
APL1C:  LD     IY,JISX
        CALL   ROMJP
APL1CD: DEFB   ROMST+15
;
LPT1CX:
        PUSH   IY
        EX     AF,AF
        ;LD     A,3+18          ;F003+18
		LD     A,ROMST+18
        LD     (APL1CD),A
		LD     A,_CRT1C
        JR     APL1CF
;
LPTINI:
        CALL   ROMJP
        DEFB   ROMST+21
;
LPTOUT:
        CALL   ROMJP
        DEFB   ROMST+24
;
PBCCLR:
        CALL   ROMJP
        DEFB   ROMST+27
;
SPLOFF:
        CALL   ROMJP
        DEFB   ROMST+30
;
SPLON:
        CALL   ROMJP
        DEFB   ROMST+33
;
SPLSW:
        CALL   ROMJP
        DEFB   ROMST+36
;
LPTM02:
        CALL   ROMJP
        DEFB   ROMST+39
;
;---------------------------
;
;
;
ROMJP:  EX     AF,AF
        LD     A,(PSEL)
        BIT    P_KP5,A
        JR     Z,ROMJP1
;
        PUSH   BC
        LD     B,3
        RST    3
        DEFB   _MCTRL
        POP    BC
;
ROMJP1: EX     AF,AF
ROMJP2: EX     AF,AF
        XOR    A
        LD     (KEY266),HL
        LD     (HERRF),A
        EX     AF,AF
        DI
        LD     (KEY264),SP
        EX     (SP),HL         ;HL=call stored address
        LD     SP,HL           ;
        POP    HL              ;HL=call address
        OUT    (LSE3),A
        LD     SP,KEY262       ; Temporary stack (262 bytes)
        CALL   HLJP
        OUT    (LSE1),A
        LD     SP,(KEY264)
        EX     (SP),HL
        INC    SP
        INC    SP
        EI
        EX     AF,AF
        LD     A,(HERRF)
        OR     A
        JR     NZ,ROMERR
        EX     AF,AF
        RET
HLJP:   LD     H,0F4H          ;HL=F4??H
        JP     (HL)
;
;
ROMERR:
        LD     B,A              ;B=0
        EX     AF,AF
        DEC    B               ;B=1
        JP     Z,BREAKZ
        DEC    B               ;B=2
        JP     NZ,ERRORJ
ROMER1: LD     HL,(PBCN)       ;INIT M2
        LD     A,H
        OR     L
        JR     Z,LPTM02
        CALL   SPLON
        RST    3
        DEFB   _BREAK
        JP     Z,BREAKZ
        JR     ROMER1
;
;
LPTINT:
        DI
        PUSH   AF
        PUSH   HL
        PUSH   BC
        LD     (WKLINT),SP
        LD     SP,WKLINT
        OUT    (LSE3),A
        CALL   ROMST1
        OUT    (LSE1),A
        LD     SP,(WKLINT)
        POP    BC
        POP    HL
        POP    AF
        EI
        RETI
        DEFS   8
WKLINT: DEFW   0
;
; ---------------------------
; MZ-800     Monitor command
; FI:MONOP   ver 1.0A 8.04.84
; ---------------------------
;
MONOP:
        PUSH   HL
        LD     DE,(ERRORP)
        PUSH   DE
        LD     DE,MONERR
        LD     (ERRORP),DE     ;error ret adr set
        LD     A,(LINLIM)
        PUSH   AF
        LD     A,100           ;getline max set
        LD     (LINLIM),A
        LD     (MONSP+1),SP    ;stack pointer push
        XOR    A
        LD     (FILOUT),A      ;crt mode
MONCLD: LD     SP,0000H        ;stack initize
MONHOT: LD     BC,MONHOT
        PUSH   BC              ;last return addrs set
        RST    3
        DEFB   _CR2            ;linefeed & cr
        LD     A,'*'           ;prompt disp
        RST    3
        DEFB   _CRT1C
        CALL   MONEDT          ;memory corretion ?
        JR     NC,$-3
        LD     A,(DE)
        CP     '*'
        RET    NZ              ;prompt check
        INC    DE
        LD     A,(DE)          ;acc=next interpret data
        INC    DE              ;next interpret data addr
;
;
; moniter tabel command jump
;
        EXX                    ;parameter push
        LD     HL,MNCMTB
        LD     B,10            ;commands counter
MNCMCP: CP     (HL)
        INC    HL
        JR     Z,MNCMOK        ;skip if just command
        INC    HL              ;next search
        INC    HL
        DJNZ   MNCMCP
        EXX
        RET
;
MONERR: LD     C,A
        AND    7FH
        JR     Z,MONCLD        ;Break
        LD     A,C             ;acc=errcode
        RST    3
        DEFB   _ERRX           ;display error messege
        RST    3
        DEFB   _ERCVR          ;error recover fd/qd
        JR     MONCLD
;
;
MNCMOK: LD     E,(HL)
        INC    HL
        LD     D,(HL)
        PUSH   DE              ;commnd addr set
        EXX                    ;parameter pop
        RET
;
MNCMTB: DEFM   'D'
        DEFW   MONDMP
        DEFM   'M'
        DEFW   MONSET
        DEFM   'P'
        DEFW   MONPRT
        DEFM   'G'
        DEFW   MONGOT
        DEFM   'F'
        DEFW   MONSCH
        DEFM   'R'
        DEFW   MONSP
        DEFM   'S'
        DEFW   MONSAV
        DEFM   'L'
        DEFW   MONLOD
        DEFM   'V'
        DEFW   MONVRY
        DEFM   'T'
        DEFW   MONTRN
;
MONPRT: LD     A,(FILOUT)      ;lpt/crt
        XOR    1
        LD     (FILOUT),A
        RET
;---------------------------------
;
;     moniter  save commnd
;
;---------------------------------
MONSAV: CALL   SAVTRN          ;set addrs
        RET    C
        EXX
        CALL   FNMST           ;file name set
        EXX
        LD     (ELMD20),BC     ;bytes
        LD     (ELMD22),DE     ;data adrs
        LD     (ELMD24),HL     ;exec adrs
        RST    3
        DEFB   _SAVEF          ;save file
        RET
;---------------------------------
;
;    moniter load command
;
;---------------------------------
MONLOD: CALL   HLSET           ;load addr set
        PUSH   HL              ;hl=load addrs
        PUSH   AF
        CALL   LOAVRY          ;filename set & open
        POP    AF
        POP    HL
        JR     NC,$+5           ;user load addr set ??
        LD     HL,(ELMD22)
        RST    3
        DEFB   _LOADF          ;load file
        RET
;---------------------------------
;
;    filename set & open
;
;---------------------------------
LOAVRY: CALL   FNMST           ;file name set
        RST    3
        DEFB   _LOPEN          ;ropen
        CP     1
        RET    Z
        JP     ER61            ;File mode error
;---------------------------------
;
;    moniter verify command
;
;---------------------------------
MONVRY: CALL   LOAVRY          ;filename set
        LD     HL,(ELMD22)
        RST    3
        DEFB   _VRFYF          ;file verify
        RET
;---------------------------------
;
;    moniter rerturn command
;
;            to BASIC
;---------------------------------
MONSP:  LD     SP,0000H
        POP    AF
        LD     (LINLIM),A
        POP    HL
        LD     (ERRORP),HL
        POP    HL
        RET
;---------------------------------
;
;     moniter operation
;
;---------------------------------
MONEDT: LD     DE,0FF00H        ;moniter work
        RST    3
        DEFB   _GETL
        JR     C,MONEDE
;
;    check ':xxxx='
;
        LD     A,(DE)
        CP     ':'             ;mem correct ??
        SCF
        RET    NZ
;
        INC    DE
        CALL   HLSET           ;addrs input ?
        RET    C
        LD     A,(DE)
        INC    DE
        XOR    3DH             ;"=" input ?
        RET    NZ
;
;
NEXTAC: CALL   ACSET           ;data read
        CCF
        RET    NC
        LD     (HL),A             ;mem correction !
        INC    HL              ;next pointer
        JR     NEXTAC
;
;
MONEDE: LD     (DE),A          ;error
        RET
;----------------------------------
;
;    4 ascii to binary (word)
;
;        ent. de=ascii data pointer
;        ext  hl=xxxxH
;
;----------------------------------
HLSET:  PUSH   HL
        CALL   SPCTAC          ;separater search
        PUSH   DE
        CALL   ACSETH          ;2 ascii to binary
        JR     C,HLSETE
        LD     H,A
        CALL   ACSETH          ;2 ascii to binary
        JR     C,HLSETE
        LD     L,A
        POP    AF
        POP    AF
        XOR    A
        RET
;
HLSETE: POP    DE
        POP    HL
        SCF
        RET
;----------------------------------
;
;    separater  search
;
;----------------------------------
SPCTA2: INC    DE
SPCTAC: LD     A,(DE)
        CP     20H
        JR     Z,SPCTA2
        RET
;---------------------------------
;
;    1 ascii to binary (nibble)
;
;        ent. de=ascii data pointer
;        ext  acc= 0xH
;
;---------------------------------
ACSETS: LD     A,(DE)
        RST    3
        DEFB   _CKHEX          ;0-9 a-f check
        INC    DE              ;next pointer
        RET
;---------------------------------
;
;    2 ascii to  binary (byte)
;
;        ent. de=ascii data pointer
;        ext  acc= xxH
;
;---------------------------------
ACSET:  CALL   SPCTAC          ;separeter search
        CP     ';'
        JR     Z,SEMIOK        ;skip if ascii input
ACSETH:
        PUSH   BC
        PUSH   DE
        CALL   ACSETS          ;1 ascii to binary(nible)
        JR     C,ACSTER
        LD     C,A             ;high nible
        CALL   ACSETS          ;1 ascii to binary(nible)
        JR     C,ACSTER
        LD     B,A             ;low nible
        LD     A,C
        RLCA
        RLCA
        RLCA
        RLCA
        ADD    A,B
        LD     C,A
        LD     A,C
        POP    BC
        POP    BC
        OR     A
        RET
;
ACSTER: POP    DE
        POP    BC
        SCF
        RET
;----------------------------------
;
;    ascii  code input mode
;
;----------------------------------
SEMIOK: INC    DE
        LD     A,(DE)
        INC    DE
        OR     A               ;¯¯JR ACSETO
        RET                    ;¯¯
;----------------------------------
;
;    moniter jump commnd
;
;----------------------------------
MONGOT: CALL   HLSET           ;addrs set
        RET    C
        JP     (HL)
;----------------------------------
;
;   moniter dump commnd
;
;----------------------------------
MONDMP: CALL   HLSET           ;top addrs set
        JR     C,MONDP1        ;skip if 'd' only
        PUSH   HL
        CALL   HLSET           ;end addrs set
        JR     C,MONDP2        ;skip if top addrs only
        POP    DE
        EX     DE,HL
        JR     MONDP3
;
;
;
MONDP2: POP    HL              ;
MONDP1: EX     DE,HL
        LD     HL,80H
        ADD    HL,DE           ;last addrs calc
        EX     DE,HL
MONDP3: LD     C,8             ;counter set
        CALL   MONDPS          ;dump list disp
        RET    C
        PUSH   HL
        SBC    HL,DE           ;dump end calc
        POP    HL
        RET    NC
        JR     MONDP3
;
MONDPS: CALL   HLHXPR          ;addrs disp
        LD     B,C
        PUSH   HL
MONDP4: LD     A,(HL)             ;data read
        CALL   ACHXPR          ;1 byte disp
        INC    HL
        LD     A,20H           ;space disp
        RST    3
        DEFB   _1C
        DJNZ   MONDP4
        POP    HL
;
        LD     A,'/'           ;separater disp
        RST    3
        DEFB   _1C
        LD     B,C
MONDP5: LD     A,(HL)             ;data read
        CP     20H             ;contol code
        JR     NC,$+4
        LD     A,'.'           ;yes, control code
        RST    3
        DEFB   _1C
        INC    HL              ;next pointer
        DJNZ   MONDP5
;
        RST    3
        DEFB   _CR
        RST    3
        DEFB   _HALT           ;break & stop
        OR     A
        RET
;--------------------------------
;
;    disp addrs
;
;         ent. hl=addrs
;              ':xxxx='
;
;--------------------------------
HLHXPR: LD     A,':'
        RST    3
        DEFB   _1C
        LD     A,H
        CALL   ACHXPR          ;acc disp
        LD     A,L
        CALL   ACHXPR          ;acc disp
        LD     A,'='
        RST    3
        DEFB   _1C
        RET
;--------------------------------
;
;    acc  disp
;
;         ent. acc = disp data
;
;--------------------------------
ACHXPR: PUSH   AF
        RLCA
        RLCA
        RLCA
        RLCA
        CALL   AC1HXP          ;nible disp
        POP    AF
AC1HXP: AND    0FH             ;ascii trans
        ADD    A,30H
        CP     ':'
        JR     C,$+4
        ADD    A,7
        RST    3
        DEFB   _1C            ;disp acc(nibble)
        RET
;---------------------------------
;
;   moniter mem correction comd
;
;---------------------------------
MONSET: CALL   HLSET           ;
        LD     A,(FILOUT)      ;lpt/crt switch
        PUSH   AF
        XOR    A
        LD     (FILOUT),A      ;crt mode
MONSTL:
        RST    3
        DEFB   _CR2
        CALL   HLHXPR          ;addrs disp
        LD     A,(HL)             ;data read
        CALL   ACHXPR          ;data disp
        LD     A,20            ;back space
        RST    3
        DEFB   _CRT1C
        RST    3
        DEFB   _CRT1C
        CALL   MONEDT          ;moniter operation
        JR     NC,MONSTL
        POP    AF
        LD     (FILOUT),A
        RET
;--------------------------------
;
;    moniter search command
;
;--------------------------------
MONSCH: CALL   HLSET           ;start addrs
        RET    C
        PUSH   HL
        CALL   HLSET           ;end addrs
        POP    BC
        RET    C
        PUSH   HL              ;hl end addr
        PUSH   BC              ;bc start addr
        LD     HL,0FF00H        ;check data read
        CALL   NEXTAC          ;(hl)<--data
        LD     DE,0FF00H
        OR     A
        SBC    HL,DE           ;check data bytes
        LD     C,L
        POP    HL
        PUSH   HL
        EXX
        POP    HL              ;hl start addr
        POP    DE              ;de end addr
        EXX
        RET    Z
MNSHLP: CALL   HLDECK          ;de=0FF00H
        JR     NZ,SKPSCH       ;de check databuf
        CALL   MONDPS          ;data disp
        RET    C
SKPSCH:
        RST    3
        DEFB   _BREAK
        RET    Z
        EXX
        INC    HL              ;next check pointer
        PUSH   HL
        SCF
        SBC    HL,DE           ;end check ?
        POP    HL
        RET    NC
        PUSH   HL
        EXX
        POP    HL              ;next check pointer
        JR     MNSHLP
;----------------------------------
;
;    3 pointer data interpret
;
;        ent de=ascii data top addr
;
;        ext de=first data
;            bc=(second-first) data
;            hl=last data
;
;        used save,xfer commnd
;
;     command : save :  xfer
;
;        de   : start:  source
;        bc   : bytes:  bytes
;        hl   : end  :  destination
;----------------------------------
SAVTRN: CALL   HLSET           ;first
        PUSH   HL
        CALL   NC,HLSET        ;second
        POP    BC              ;first
        RET    C
        SBC    HL,BC           ;calc bytes
        INC    HL
        PUSH   HL              ;bytes
        PUSH   BC              ;first
        CALL   HLSET           ;last
        PUSH   HL              ;last
        EXX
        POP    HL              ;last
        POP    DE              ;first
        POP    BC              ;bytes
        RET
;-------------------------------
;
;    moniter xfer command
;
;-------------------------------
MONTRN: CALL   SAVTRN          ;
        RET    C
        EX     DE,HL
        PUSH   HL
        SBC    HL,DE           ;direction check
        POP    HL
        JR     C,LDDRTR
        LDIR
        RET
LDDRTR: ADD    HL,BC           ;last addrs calc
        DEC    HL
        EX     DE,HL
        ADD    HL,BC
        DEC    HL
        EX     DE,HL
        LDDR
        RET
;----------------------------------
;
;     filename set
;
;----------------------------------
FNMST:  LD     A,(DE)
        OR     A
        JR     Z,FNMST2
        INC    DE
        CP     ':'             ;demiliter seach
        JR     NZ,FNMST
FNMST2:
        RST    3
        DEFB   _COUNT          ;count string length
        RST    3
        DEFB   _DEVFN          ;interpret dev. file name
        LD     A,1
        LD     (ELMD),A        ;.OBJ atribut
        RET
;---------------------------------
;
;     check (de) (hl) ?
;
;           hl,de check data point
;             c   counter
;
;---------------------------------
HLDECK: LD     A,(DE)
        CP     (HL)
        RET    NZ
        PUSH   BC
        PUSH   DE
        PUSH   HL
        LD     B,C
HLDEC1: LD     A,(DE)
        CP     (HL)
        JR     NZ,HLDEC2
        INC    DE
        INC    HL
        DJNZ   HLDEC1
        XOR    A
HLDEC2: POP    HL
        POP    DE
        POP    BC
        RET
;
;       END  (17EAH)


;=========================
IF RAMDISK
INST_0:
        LD     A,B
		OR     C
		RET    Z
		LDDR
		XOR    A
		RET

CRTINI_0:
        LD     A,$C0
		LD     (_SET+2),A
		LD     (BOXC0+1),A
		JP     CRTINI

ENDIF
;=========================


XMON_END:
DEFS $1800-XMON_END



; -----------------------------
; Lx-monitor  IOCS-part
; FI:MON-IOCS  ver 1.01 5.24.84
; -----------------------------
;

;        ORG    1800H
;
_IOCS:
        JP     _START
;
; FALG1 bit position
;
defc __REN    =    0               ;ROPEN enable
defc __WEN    =    1               ;WOPEN enable
defc __RCHR   =    2               ;Read at 1 char
defc __WCHR   =    3               ;Write at 1 char
defc __FNM    =    4               ;File name exist
defc __RND    =    5               ;FD
defc __SEQ    =    6               ;CMT, QD, XM
defc __STRM   =    7               ;CRT, LPT, RS, USR

;
; FLAG2 bit position
;
defc __CMT    =    7               ;Disp filename
defc __1OPN   =    6               ;1 file only open
defc __1WOP   =    5               ;1 file only wopen
defc __EOFE   =    4               ;select EOF process


; ZRWX bit position
;
defc __ROPN   =    0               ;R.opened
defc __WOPN   =    1               ;W.opened
defc __XOPN   =    2               ;X.opened
defc __LOPN   =    3               ;L.opened
defc __EOF    =    7               ;End of file



;   bit 0,1,2 ..... max channel
;
;
; DIR offset
;
defc _SIZE    =    20
defc _PTR     =    64              ;BSD block pointer
defc _BLKNO   =    64+16-2         ;BSD block number

;  Logical Units
;
defc CMTLU   =    80H
defc LDALU   =    81H
defc CRTLU   =    88H
defc LPTLU   =    89H
defc DATLU   =    8AH
;
;
CRTLU__: LD     A,(ZLOG)
        CP     CRTLU
        RET
;
ZMODE:  DEFW   0               ;File mode
ZBUFF:
        DEFW   0               ;Buffer adrs
ZBUFE:
        DEFW   0               ;Buffer end


;
; SVC .PRSTR  ;print string into file
;    ent DE:adrs
;        B: length
;
PRTSTR:
        CALL   IO_RDY
        CALL   PRTST0

IO_OK:
        XOR    A
        LD     (QSEG),A
        RET
;
IO_RDY:
        LD     A,(ZLOG)
        LD     (QSEG),A
        RET
;
PRTST0: CALL   PUSHR
        LD     A,(ZFLAG1)
        BIT    __STRM,A
        LD     HL,PRT1C
        JR     Z,PRTST2
        BIT    __WCHR,A        ;Output at
        LD     HL,_ZOUT
        JR     NZ,PRTST2       ;  1 char
_ZOUT:
        LD     IX,(ZOUT)       ;  1 line
        CALL   IOCALL
        RET
;
PRTST2: LD     A,B             ;SEQ/RND
        OR     A
        RET    Z
        LD     A,(DE)
PRTST4: CALL   _HL             ;PRT1C or _ZOUT
        INC    DE
        DEC    B
        JR     PRTST2
;
PRT1C:  CALL   PUSHR
        LD     E,(IY+_PTR)
        LD     D,(IY+_PTR+1)
        LD     HL,(ZBUFF)
        ADD    HL,DE
        LD     (HL),A
        INC    DE
        LD     HL,(ZBLK)
        OR     A
        SBC    HL,DE
        CALL   Z,PRT1B         ;Buffer full
        LD     (IY+_PTR),E
        LD     (IY+_PTR+1),D
        INC    (IY+_SIZE)
        RET    NZ
        INC    (IY+_SIZE+1)
        RET    NZ
        JP     ER55            ;too long file


;
PRT1B:  PUSH   BC              ;Output 1 block
        LD     B,02H           ;F# not update, blocked
PRT1B0: CALL   _RND
        LD     IX,_ZOUT
        JR     Z,$+6
        LD     IX,PRX1B
        LD     A,B
        CALL   SEQSET
        CALL   _IX1
PRT1B9: INC    (IY+_BLKNO)
        LD     DE,0
        POP    BC
        RET
;
_IX1:   JP     (IX)
;
PRT1BX: LD     A,1AH           ;Output last block
        LD     E,(IY+_PTR)
        LD     D,(IY+_PTR+1)
PRT1X2: LD     HL,(ZBUFF)
        ADD    HL,DE
        LD     (HL),A
        INC    DE
        LD     HL,(ZBLK)
        XOR    A
        SBC    HL,DE
        JR     NZ,PRT1X2
        PUSH   BC
        LD     HL,(ZBUFF)
        DEC    HL
        LD     (HL),0FFH           ;EOF mark
        DEC    HL
        LD     (HL),0FFH
        LD     B,06H           ;F# update, blocked
        JR     PRT1B0
;
;
SEQSET: LD     BC,(ZBLK)
        INC    BC
        INC    BC
        LD     HL,(ZBUFF)
        DEC    HL
        DEC    HL
        LD     DE,(ZMODE)
        RET
;
;
_ZEND:  DEFB   0F6H
_ZSTRT: XOR    A
        LD     IX,(ZSTRT)
        CALL   IOCALL
        RET


;
; SVC .INSTT  ;INPUT command start
;
INPSTRT:
        CALL   CRTLU__          ;input start
        RET    NZ
        PUSH   DE
        LD     DE,KEYBUF
        CALL   BINPUT
        LD     (INPKB+1),DE
        POP    DE
        RET    NC
        JP     BREAKZ
;
; SVC .INMSG  ;input from file
;   ent DE:adrs
;   ext B: length
;
INPMSG:
        PUSH   HL
        PUSH   DE
        CALL   IO_RDY
        LD     HL,(ZTOP)
        INC    HL
        BIT    __EOF,(HL)
        PUSH   HL
        LD     B,0
        SCF
        CALL   Z,INPMS0
        POP    HL
        CALL   C,INEOF
        POP    DE
        PUSH   AF
        CALL   IO_OK
        LD     L,B
        LD     H,0
        ADD    HL,DE
        LD     (HL),0
        POP    AF
        POP    HL
        RET
;
INEOF:  SET    __EOF,(HL)
        LD     HL,ZFLAG2
        BIT    __EOFE,(HL)
        RET    Z               ;nomally
        JP     ER63            ;old method
;
INPMS0: CALL   CRTLU__          ;input 1 record
        JR     Z,INPKB
        LD     A,(ZFLAG1)
        BIT    __STRM,A
        LD     HL,INP1C
        JR     Z,INPMC
        BIT    __RCHR,A
        LD     HL,_ZINP
        JR     NZ,INPMC
_ZINP:
        LD     IX,(ZINP)
        CALL   IOCALL
        RET
;
INPKB0: LD     A,'?'
        RST    3
        DEFB   _CRT1C
        LD     A,' '
        RST    3
        DEFB   _CRT1C
        RST    3
        DEFB   _INSTT
INPKB:  LD     HL,0            ;xxx
        CALL   HLFTCH
        OR     A
        JR     Z,INPKB0
        LD     C,0
        RST    3
        DEFB   _INDAT
        LD     (INPKB+1),HL
        RET
;
; SVC .INDAT ;read 1 item from buffer
;   ent HL:data pointer
;       DE:input buffer
;       C: separater(nomaly 00H or ":")
;   ext B: length
;       HL:data pointert
;
INPDT:
        LD     B,0
        CALL   TEST1
        DEFB   '"'
        JR     NZ,INPDT6
INPDT2: LD     A,(HL)
        OR     A
        RET    Z
        INC    HL
        CP     '"'
        JR     Z,INPDT4
        LD     (DE),A
        INC    DE
        INC    B
        JR     INPDT2
INPDT4:
        CALL   TEST1
        DEFM   ","
        OR     A               ;Reset CF
        RET
;
INPDT6: LD     A,(HL)
        OR     A
        RET    Z
        CP     C
        RET    Z
        INC    HL
        CP     ','
        RET    Z
        LD     (DE),A
        INC    DE
        INC    B
        JR     INPDT6
;
INPMC:  LD     (INPMC2+1),HL   ;input by chr
        LD     B,0
INPMC2: CALL   0               ;INP1C or (ZINP)
        RET    C
        CP     0DH
        RET    Z
        LD     (DE),A
        INC    DE
        INC    B
        JR     NZ,INPMC2
        JP     ER41            ;I/O error


;
INP1C0:
        LD     A,(ZFLAG1)
        BIT    __STRM,A
        JP     NZ,ER59         ;STRM ommit
INP1C:  CALL   PUSHR
        LD     E,(IY+_PTR)
        LD     D,(IY+_PTR+1)
        LD     HL,(ZBLK)
        OR     A
        SBC    HL,DE
        CALL   Z,INP1B
        RET    C
        LD     L,(IY+_BLKNO)
        LD     H,(IY+_BLKNO+1)
        XOR    A
        SBC    HL,DE
        SCF
        RET    Z               ;EOF
        LD     HL,(ZBUFF)
        ADD    HL,DE
        LD     A,(HL)
        INC    DE
        LD     (IY+_PTR),E
        LD     (IY+_PTR+1),D
        RET
;
INP1B:  CALL   _RND
        JP     NZ,INX1B
        DEFB   0F6H             ;not first block
INP1B0: XOR    A               ;first block
        CALL   SEQSET
        CALL   _ZINP
        RET    C
        LD     A,(HL)
        INC    HL
        AND    (HL)
        LD     (HL),0FFH
        INC    A
        LD     DE,0
        RET    NZ              ;Nomal block
        PUSH   HL              ;EOF block
        LD     HL,(ZBUFE)
        LD     BC,(ZBLK)
INP1B2: DEC    HL
        DEC    BC
        LD     A,(HL)
        OR     A
        JR     Z,INP1B2
        POP    HL
        LD     (HL),B             ;_BLKNO := Block length
        DEC    HL
        LD     (HL),C
        RET


;
; SVC .LUCHK  ;check lu & set Z-area
;   ent A: lu
;   ext A: 1:R, 2:W
;       if CF then not-found
;
LUCHK:
        CALL   PUSHR
        LD     HL,CRTTBL
        CP     CRTLU
        JR     Z,LUCHK4
        LD     HL,LPTTBL
        CP     LPTLU
        JR     Z,LUCHK4
        RST    3
        DEFB   _SEGAD
        RET    C               ;LU# not found
LUCHK4: LD     (ZTOP),HL
        LD     DE,ZLOG
        LD     BC,8
        LDIR
        LD     (ZMODE),HL
        LD     IY,HL
        LD     DE,ELMD
        CALL   LDIR64
        PUSH   HL
        LD     HL,(ZEQT)
        LD     DE,ZNXT
        LD     BC,ZBYTES
        LDIR
        POP    HL
        LD     BC,16
        ADD    HL,BC
        LD     (ZBUFF),HL
        LD     BC,(ZBLK)
        ADD    HL,BC
        LD     (ZBUFE),HL
        LD     A,(ZRWX)
        AND    0FH
        RET
;
;
CRTTBL: DEFB   CRTLU
        DEFB   3               ;W R
        DEFW   _CRT
        DEFW   0
        DEFW   0
;
LPTTBL: DEFB   LPTLU
        DEFB   2               ;W
        DEFW   _LPT
        DEFW   0
        DEFW   0
;


;
; SVC .DEVNM  ;Interp. dev name
;  ent DE:device name pointer
;  ext DE:equipment table
;      HL:file name pointer
;      A: channel
;
DEV:
        LD     HL,KEYBUF
        PUSH   HL
        LD     A,B
        OR     A
        CALL   NZ,LDHLDE
        LD     (HL),0
        LD     HL,EQTBL
        JR     $+5
DEV1:   LD     HL,0            ;xxx
        LD     A,L
        OR     H
        JR     Z,DEV8          ;Not found
        LD     (DEV7+1),HL
        CALL   LDDEMI
        LD     (DEV1+1),DE
        LD     DE,KEYBUF
        EX     DE,HL
DEV2:   LD     A,(DE)
        OR     A
        JR     Z,DEV4
        CP     (HL)
        JR     NZ,DEV1         ;Mismatch
        INC    HL
        INC    DE
        JR     DEV2
DEV4:   LD     A,(HL)
        INC    HL
        CP     ':'
        LD     C,0
        JR     Z,DEV5          ;Match
        SUB    '1'
        CP     9
        JR     NC,DEV1         ;Mismatch
        LD     C,A
        LD     A,(HL)
        INC    HL
        CP     ':'
        JR     NZ,DEV1         ;Mismatch
DEV5:   EX     (SP),HL         ;Found
DEV7:   LD     HL,0            ;xxx
        LD     A,C
        JR     DEV9
DEV8:   POP    HL              ;Not found
        PUSH   HL
DEV82:  LD     A,(HL)
        INC    HL
        CP     ':'
        JP     Z,ER58          ;Dev name err
        OR     A
        JR     NZ,DEV82
        LD     HL,(DDEV)       ;default device
        LD     A,(DCHAN)       ;default channel
DEV9:   LD     (ZEQT),HL
        PUSH   HL
        LD     (ZCH),A
        LD     DE,ZNXT
        LD     BC,ZBYTES
        LDIR
        LD     B,A
        LD     A,(ZFLAG2)
        AND    07H             ;bit 0,1,2
        CP     B
        JP     C,ER58          ;Dev name err (CH#)
        LD     A,B
        POP    DE
        POP    HL
        RET
;
; SVC .DEVFN  ;Interp. dev&file name
;   ent DE:pointer
;       B: length
;
DEV_FN:
        CALL   PUSHR
        RST    3
        DEFB   _DEVNM
        EX     DE,HL
        LD     HL,ELMD1
        LD     B,31
        CALL   CLRHL
        LD     HL,ELMD
        RST    3
        DEFB   _COUNT
        CALL   SETFNAM
        LD     HL,ZFLAG1
        BIT    __FNM,(HL)
        RET    Z
        INC    HL
        BIT    __CMT,(HL)
        RET    NZ
        LD     A,(ELMD1)       ;except CMT,
        CP     0DH             ; no filename is
        JP     Z,ER60          ; error 60.
        RET


;
; SVC .RWOPEN   ;ROPEN/WOPEN/XOPEN
;
RWOPEN:
        CALL   PUSHR
        CALL   OPEN00
        LD     B,0
        CALL   TYPECK
        JP     DUST
;
OPEN00: LD     A,(ZLOG)
        RST    3
        DEFB   _SEGAD
        JP     NC,ER43         ;LU already opened
        CALL   _OPEND          ;Check already opened
        LD     HL,8+64+16+5    ;LU, DIR and work
        LD     A,(ZFLAG1)
        LD     DE,(ZBLK)
        INC    DE
        INC    DE
        BIT    __STRM,A
        JR     NZ,$+3
        ADD    HL,DE           ;SEQ,RND
        LD     A,(ZRWX)
        BIT    2,A
        JR     Z,$+3
        ADD    HL,DE           ;XO
        EX     DE,HL
        LD     A,(ZLOG)
        RST    3
        DEFB   _OPSEG          ;open segment
        LD     (QSEG),A
        LD     (ZTOP),HL
        EX     DE,HL
        LD     HL,ZLOG
        LD     BC,8

        LDIR                   ;xfer ZLOG to seg
        LD     (ZMODE),DE

		defb   $d5, $fd, $e1    ;LD IY,DE  (Z80ASM uses 4 bytes, LD HY,D / LD LY,E)
		; ** the z80asm output would currently be:
		;defb   $fd $62         ; LD HY,D
		;defb   $fd $6b         ; LD LY,E

        LD     HL,ELMD
        CALL   LDIR64          ;xfer ELMD to seg
        LD     HL,16
        ADD    HL,DE
        LD     (ZBUFF),HL
        LD     DE,(ZBLK)
        ADD    HL,DE
        LD     (ZBUFE),HL
        CALL   _RND
        JP     NZ,OPX          ;RND
        LD     A,(ZRWX)        ;SEQ/STRM
        BIT    __XOPN,A
        JP     NZ,ER59
        BIT    __WOPN,A
        LD     IX,(ZWO)
        JR     NZ,OPEN20
        LD     A,(ZFLAG1)
        BIT    __STRM,A
        JR     Z,OPEN30
        LD     IX,(ZRO)        ;STRM RO
OPEN20: LD     HL,ELMD         ;SEQ/STRM WO
        JP     IOCALL
OPEN30: LD     B,(IY+0)        ;SEQ RO
        CALL   SERFLR
        LD     A,(ELMD)
        CP     B
        JP     NZ,ER61
        JP     INP1B0          ;First call
;
; SVC .LOPEN  ;Search for LOAD
;
LOPEN:
        CALL   PUSHR
        LD     IY,0100H        ;(ZLOG)=0
        LD     (ZLOG),IY       ;(ZRWX)=1 ;R
        LD     IY,ELMD
        CALL   _RND
        LD     HL,LOPX
        JR     NZ,$+5
        LD     HL,SERFLR
        CALL   _HL
        LD     B,80H
        CALL   TYPECK
        LD     A,(ELMD)
        RET
;
;  type check (chained or contiguas)
;
TYPECK: LD     A,(ELMD)
        CP     5
        RET    C
        LD     A,(ELMD18)
        AND    80H
        CP     B
        RET    Z
        JP     ER61


;
; SVC .CLKL   ;CLOSE/KILL
;   ent A: lu, if A=0 then all-files
;       B: B=0:KILL, B<>0:CLOSE
;
CLKL:                    ;CLOSE/KILL file
        CALL   PUSHR
        OR     A
        JR     Z,CLKLA
        CALL   CL1F
        JP     DUST
;
CL1F:
        RST    3
        DEFB   _LUCHK
        RET    C               ;LU# not found
        CALL   IO_RDY
        PUSH   AF
        CALL   _RND
        JR     NZ,CL1FR
        BIT    __STRM,A
        LD     A,B
        JR     Z,CL1FB
        OR     A               ;Streem I/O
        LD     IX,(ZKL)
        JR     Z,$+6
        LD     IX,(ZCL)
        CALL   IOCALL
        JR     CL1F8
CL1FB:  OR     A               ;SEQ I/O
        JR     Z,CL1F8
        LD     A,(ZRWX)
        BIT    __WOPN,A
        CALL   NZ,PRT1BX
        JR     CL1F8
CL1FR:  CALL   CLX             ;RND I/O
CL1F8:  POP    AF
        RST    3
        DEFB   _DLSEG
        RET
;
;  SVC .CLRIO ;clear all i/o
;
CLRIO:
        CALL   PUSHR
        LD     B,0
CLKLA:  LD     C,8EH           ;all files
CLKLA2: LD     A,C
        PUSH   BC
        RST    3
        DEFB   _SEGAD
        CALL   NC,CL1F
        POP    BC
        DEC    C
        JR     NZ,CLKLA2
        JP     ERRCVR


;
;  search file (SEQ device)
;
SERFIL:
        CALL   PUSHR           ;Search file
        LD     A,(ZFLAG1)
        BIT    __SEQ,A
        JP     Z,ER59          ;SEQ only ok
        CALL   _ZSTRT
        LD     A,(ZDIRMX)
        LD     B,A
SERFL2: LD     HL,KEYBUF
        PUSH   BC
        LD     IX,(ZRO)        ;RDINF
        CALL   IOCALL
        POP    BC
        SET    0,A             ;A<>0
        RET    C               ;Not found

		defb   $fd, $e5, $d1    ;LD DE,IY  (Z80ASM uses 4 bytes)
		; ** the z80asm output would currently be:
		;defb   $fd $54         ; LD D,HY
		;defb   $fd $5d         ; LD E,LY

        CALL   FNMTCH
        LD     A,(HL)
        RET    Z
        DJNZ   SERFL2
        XOR    A               ;end of dir
        SCF
        RET
;
; search file for WOPEN, SAVE
;  (SEQ device)
;
SERFLW:
        CALL   _OPEND
        CALL   SERFIL
        JP     NC,ER42         ;already exist
        OR     A
        JP     Z,ER51          ;too many files
        RET
;
; search file for ROPEN
;  (SEQ device)
;
SERFLR: CALL   _OPEND
        CALL   SERFIL
        JP     C,ER40          ;not found
        CALL   PUSHR
        LD     HL,KEYBUF

		defb   $fd, $e5, $d1    ;LD DE,IY  (Z80ASM uses 4 bytes)
		; ** the z80asm output would currently be:
		;defb   $fd $54         ; LD D,HY
		;defb   $fd $5d         ; LD E,LY

        PUSH   HL
        CALL   LDIR64
        POP    HL
        LD     DE,ELMD
        LD     A,(HL)
LDIR64: LD     BC,64
        LDIR
        OR     A
        RET


;
; CALL _OPEND ; Check already opened
;
_OPEND:
        LD     IX,_OPCKX
_OPEN0:
        LD     (_OPEN6+1),IX
        CALL   PUSHR
        LD     A,(ZLOG)
        LD     C,A
        LD     HL,(POOL)
        PUSH   HL
_OPEN2: POP    HL
        LD     A,(HL)
        OR     A
        RET    Z
        LD     B,A
        INC    HL
        CALL   LDDEMI
        PUSH   HL
        ADD    HL,DE
        EX     (SP),HL
        CP     8FH
        JR     NC,_OPEN2       ;non i/o seg.
        CP     C
        JR     Z,_OPEN2        ;same lu
        INC    HL              ;ZRWX
        LD     A,(HL)
        EX     AF,AF
        INC    HL
        LD     DE,ZEQT
        PUSH   BC
        LD     BC,300H
_OPEN4: LD     A,(DE)
        SUB    M
        OR     C
        LD     C,A
        INC    DE
        INC    HL
        DJNZ   _OPEN4
        POP    BC
        JR     NZ,_OPEN2       ;Diff. device
        LD     A,B
_OPEN6: CALL   0               ;xxx
        JR     _OPEN2
;
_OPCKX: LD     A,(ZFLAG2)      ;Same device
        BIT    __1OPN,A        ;1 file only ?
        JP     NZ,ER43         ;  Yes, already open
        BIT    __1WOP,A        ;1 file only W ?
        RET    Z               ;  No, ok
        EX     AF,AF
        LD     B,A
        LD     A,(ZRWX)
        AND    B
        BIT    __WOPN,A
        RET    Z
        JP     ER43


;
; SVC .LOADFL
;   ent HL:loaging adrs
;   call after .DEVFN and .LOPEN
;
LOADFL:
        CALL   _RND
        JP     NZ,LDX
        LD     BC,(ELMD20)
        PUSH   BC
        XOR    A               ;first block
        LD     IX,(ZINP)
        CALL   IOCALL
        POP    BC
        RET
;
; SVC .VRFYF  ;verify file
;   ent HL:adrs
;   call after .DEVFN, .LOPEN
;
VRFYFL:
        LD     A,(ZFLAG2)
        BIT    __CMT,A
        JP     Z,ER59
        LD     BC,(ELMD20)
        JP     CMTVRF
;
;  SVC .SAVEF  ;save file
;   ent DE:adrs
;   call after .DEVFN
;
SAVEFL:
        LD     A,(ELMD)
        CP     5
        JR     C,SAVEF2
        LD     A,80H
        LD     (ELMD18),A      ;contiguas flag
SAVEF2: CALL   _RND
        JP     NZ,SVX
        BIT    __STRM,A
        JP     NZ,ER59
        PUSH   DE
        LD     HL,0200H
        LD     (ZLOG),HL
        CALL   _OPEND
        LD     HL,ELMD
        LD     IY,HL
        LD     IX,(ZWO)
        CALL   IOCALL
        LD     BC,(ELMD20)
        POP    HL
        LD     A,04H           ;F# update,unblocked
        LD     IX,(ZOUT)
        CALL   IOCALL
        RET
;
;
_RND:
        LD     A,(ZFLAG1)
        BIT    __RND,A
        RET


;
; SVC .DIR
;   ent A=0 ... read dir
;       A>0 ... output dir
;
FDIR:
        CALL   PUSHR
        OR     A
        JR     NZ,FDIR3
        LD     HL,100H
        LD     (ZLOG),HL
        CALL   _OPEND
        LD     HL,ZFLAG1
        BIT    __STRM,(HL)
        JP     NZ,ER59         ;Streem i/o omit
        BIT    __RND,(HL)
        JP     NZ,LD_DIR       ;RND
        INC    HL              ;SEQ
        BIT    __CMT,(HL)
        JP     NZ,ER59         ;CMT ommit
        CALL   MWAIT           ;MUSIC WAIT
        LD     HL,DIRARE
        LD     BC,8            ;clear 0800H bytes
        CALL   CLRHL
        DEC    C
        JR     NZ,$-4
        CALL   _ZSTRT
        LD     A,(ZDIRMX)
        LD     B,A
        LD     HL,DIRARE
FDIR2:  PUSH   BC
        LD     IX,(ZRO)        ;read infomation
        CALL   IOCALL
        PUSH   AF
        LD     BC,32
        ADD    HL,BC
        LD     (HL),0
        POP    AF
        POP    BC
        JR     C,$+4
        DJNZ   FDIR2
        JP     _ZEND
;
FDIR3:  LD     (FDIROT+1),A
        XOR    A
        LD     (DISPX),A
        LD     HL,KEYBUF
        PUSH   HL
        LD     DE,DIRM1
        LD     B,DIRM2-DIRM1
        CALL   LDHLDE
        CALL   SETDNM          ;set device name
        LD     (HL),' '
        INC    HL
        LD     (HL),' '
        INC    HL
        EX     DE,HL
        CALL   _RND
        LD     IX,(ZFREE)      ;SEQ
        JR     Z,$+6
        LD     IX,FREEX        ;RND
        CALL   IOCALL
        JR     C,FDIR4
        LD     HL,BC
        LD     B,0
        RST    3
        DEFB   _ASCHL
        LD     HL,DIRM2
        LD     B,DIRM3-DIRM2
        CALL   LDDEHL
FDIR4:  EX     DE,HL
        LD     (HL),0DH
        INC    HL
        LD     (HL),0
        POP    DE
        CALL   FDIROT          ;DIR OF dd: xxx KB FREE
;
        LD     B,64            ;max dir
        LD     HL,DIRARE
FDIR6:  CALL   FDIRS           ;mod  "name"
        LD     DE,32
        ADD    HL,DE
        DJNZ   FDIR6
        JP     DUST
;
FDIRS:  CALL   PUSHR
        LD     A,(HL)
        OR     A
        RET    Z
        RET    M
        LD     DE,KEYBUF
        PUSH   DE
        LD     A,' '
        LD     B,38
        CALL   SETDE
        LD     A,(HL)
        CP     MAXMOD+1
        JR     C,$+4
        LD     A,MAXMOD+1
        LD     IY,HL
        POP    DE
        PUSH   DE
        INC    DE
        LD     HL,DIRM3-3
        LD     BC,3
        ADD    HL,BC
        DEC    A
        JR     NZ,$-2
        LDIR
        EX     DE,HL
        BIT    0,(IY+18)
        JR     Z,$+4
        LD     (HL),'*'
        INC    HL
        INC    HL
        LD     (HL),'"'
        INC    HL
FDIRS2: LD     A,(IY+1)
        CP     0DH
        JR     Z,FDIRS4
        LD     (HL),A
        INC    IY
        INC    HL
        JR     FDIRS2
FDIRS4: LD     (HL),'"'
        INC    HL
        LD     (HL),0DH
        INC    HL
        LD     (HL),0
        POP    DE
FDIROT: LD     A,0             ;xxx output lu
        RST    3
        DEFB   _LUCHK
        RST    3
        DEFB   _COUNT
        RST    3
        DEFB   _PRSTR
        RST    3
        DEFB   _HALT
        RET
;
DIRM1:  DEFB   0DH
        DEFM   "DIRECTORY OF "



DIRM2:  DEFM   " KB FREE."


DIRM3:  DEFM   "OBJ"           ;1
        DEFM   "BTX"           ;2
        DEFM   "BSD"           ;3
        DEFM   "BRD"           ;4
        DEFM   "RB "           ;5
        DEFM   " ? "           ;6
        DEFM   "LIB"           ;7
        DEFM   " ? "           ;8
        DEFM   " ? "           ;9
        DEFM   "SYS"           ;10
        DEFM   "GR "           ;11
        DEFM   " ? "           ;12

defc MAXMOD  =    11


;
;  INIT "dev:command"
;
FINIT:
        PUSH   HL
FINIT2: XOR    A
        LD     (ZLOG),A
        LD     IX,_OPCKY
        LD     (_OPCKY+1),SP
        CALL   _OPEN0
        POP    HL
        LD     IX,(ZINIT)
        CALL   IOCALL
        RET
;
_OPCKY: LD     SP,0
        LD     B,0
        RST    3
        DEFB   _CLKL           ;KILL
        JR     FINIT2
;
; Ask Y or N
;
OKYN:
        CALL   TEST1
        DEFM   "Y"
        RET    Z
        LD     DE,OK_MSG
        RST    3
        DEFB   _CRTMS
        LD     A,1
        RST    3
        DEFB   _INKEY
        CP     'Y'
        RET    Z
        JP     BREAKZ
OK_MSG: DEFM   "OK ? [Y/N]"


        DEFB   19H             ;alpha
        DEFB   0


;
; Filename check
;
CKFIL:
        LD     DE,ELMD
FNMTCH:
        CALL   PUSHR
        INC    HL
        INC    DE
        LD     A,(DE)
        CP     0DH
        RET    Z
        LD     B,17
FNMTLP: LD     A,(DE)
        CP     (HL)
        RET    NZ
        CP     0DH
        RET    Z
        INC    HL
        INC    DE
        DJNZ   FNMTLP
        OR     A
        RET
;
;
SETFNAM:
        INC    HL
        LD     C,16
SETFN2: LD     A,B
        OR     A
        JR     Z,SETFN4
        LD     A,(DE)
        INC    DE
        DEC    B
        OR     A
        JR     Z,SETFN4
        CP     '"'
        JR     Z,SETFN2
        CP     ':'
        JP     Z,ER60          ;file name err
        LD     (HL),A
        INC    HL
        DEC    C
        JR     NZ,SETFN2
SETFN4: LD     (HL),0DH
        INC    HL
SETFN6: LD     A,C
        OR     A
        RET    Z
        LD     (HL),' '
        INC    HL
        DEC    C
        JR     SETFN6


;
; SVC .SEGAD  ;get segment adrs
;   ent A .... Seg No.
;   ext HL ... Buffer adrs
;
SEGADR:
        LD     HL,(POOL)
SEGAD2: INC    (HL)
        DEC    (HL)
        SCF
        RET    Z               ;not found
        CP     (HL)
        INC    HL
        JR     Z,SEGAD9
        PUSH   DE
        CALL   LDDEMI
        ADD    HL,DE
        POP    DE
        JR     SEGAD2
SEGAD9: INC    HL
        INC    HL
        RET
;
; SVC .DLSEG ;delete segment
;   ent A .... Seg No.
;
DELSEG:
        CALL   PUSHR
        RST    3
        DEFB   _SEGAD
        RET    C               ;Not exist
        DEC    HL
        LD     B,(HL)
        DEC    HL
        LD     C,(HL)             ;BC = length
        DEC    HL              ;HL = del start
        LD     DE,HL           ;DE = del start
        INC    BC
        INC    BC
        INC    BC              ;BC = del size
        PUSH   BC
        ADD    HL,BC           ;HL = del end
        PUSH   HL
        LD     BC,HL
        LD     HL,(TMPEND)
        OR     A
        SBC    HL,BC
        LD     BC,HL           ;BC = Move bytes
        POP    HL              ;HL = del end
        LDIR
        POP    DE              ;DE = del size
        LD     HL,0
        OR     A
        SBC    HL,DE
        EX     DE,HL           ;DE= - delete size
        RST    3
        DEFB   _ADDP1
        OR     A
        RET
;


;
; SVC .OPSEG ;open segment
;   ent A .... Seg No.
;       DE ... Buffer length
;   ext HL ... Buffer adrs
;
OPSEG:
        PUSH   AF
        PUSH   BC
        PUSH   DE
        PUSH   DE
        INC    DE
        INC    DE
        INC    DE
        LD     HL,(TMPEND)
        EX     DE,HL           ;
        ADD    HL,DE           ; ADD DE,HL
        EX     DE,HL           ; DE = new TMPEND
        JP     C,ER06
        PUSH   HL
        LD     HL,-512
        ADD    HL,SP
        SBC    HL,DE
        JR     C,ER06
        LD     HL,(MEMLMT)
        DEC    H
        DEC    H
        SBC    HL,DE
        JR     C,ER06
        POP    HL
        PUSH   HL              ;old TMPEND
        LD     BC,(VARST)      ;POOL END
        OR     A
        SBC    HL,BC
        LD     BC,HL           ;BC = move bytes
        POP    HL              ;HL = old TMPEND
        INC    BC
        LDDR
        POP    DE              ;Buffer length
        LD     (HL),A             ;Seg No.
        INC    HL
        LD     (HL),E             ;Size
        INC    HL
        LD     (HL),D
        INC    HL
        PUSH   HL
        INC    DE              ;LEN+1
        PUSH   DE
OPSEG2: LD     (HL),0
        INC    HL
        DEC    DE
        LD     A,D
        OR     E
        JR     NZ,OPSEG2
        POP    DE              ;LEN+1
        INC    DE
        INC    DE              ;LEN+3
        RST    3
        DEFB   _ADDP1
        POP    HL
        POP    DE
        POP    BC
        POP    AF
        RET


;
;        MACRO  ERENT
;ER@1:
;        IFD    @2
;        LD     A,@1+80H
;        ENDIF
;        IFU    @2
;        LD     A,@1
;        ENDIF
;        DEFB   21H
;        ENDM
;

ER03:
        LD     A,03
        DEFB   21H

ER06:
        LD     A,06
        DEFB   21H

ER28:
        LD     A,28+80H
        DEFB   21H

ER40:
        LD     A,40+80H
        DEFB   21H

ER41:
        LD     A,41+80H
        DEFB   21H

ER42:
        LD     A,42+80H
        DEFB   21H

ER43:
        LD     A,43+80H
        DEFB   21H

ER46:
        LD     A,46+80H
        DEFB   21H

ER50:
        LD     A,50+80H
        DEFB   21H

ER51:
        LD     A,51+80H
        DEFB   21H

ER52:
        LD     A,52+80H
        DEFB   21H

ER53:
        LD     A,53+80H
        DEFB   21H

ER54:
        LD     A,54+80H
        DEFB   21H

ER55:
        LD     A,55+80H
        DEFB   21H

ER58:
        LD     A,58
        DEFB   21H

ER59:
        LD     A,59+80H
        DEFB   21H

ER60:
        LD     A,60+80H
        DEFB   21H

ER61:
        LD     A,61+80H
        DEFB   21H

ER63:
        LD     A,63+80H
        DEFB   21H

ER64:
        LD     A,64
        DEFB   21H

ER68:
        LD     A,68+80H
        JP     ERRORJ

;
;
;  Error recover routine
;

ERRCVR:
        LD     A,(QSEG)
        OR     A
        LD     B,0
        CALL   NZ,CLKL         ;KILL
        CALL   FLOFF           ;FD motor off
        CALL   QDOFF           ;QD motor off
        XOR    A
        LD     (QSEG),A
        JP     DUST            ;I/O open check
;JP MLDSP


IF MOD_B
EMSV1_00:
		PUSH   AF
		LD     A,(ZCH)

ELSE

        DEFS   3
QSEG:
        DEFB   0

ENDIF
;
;       END  (1FDA)

;=========================
IF RAMDISK

IF MOD_B
;..EMSV1_00 continues here
        ADD     A,0ECH     ; EM_P0   (0EFH: EM_P1)
		LD      C,A
		POP     AF
		LD      B,L
		RET

ELSE
        DEFS    6
ENDIF

SEEK_0:
        CALL    LDEND
        PUSH    BC
        LD      HL,(ELMD24)     ;exec addr
        LD      BC,DSAVE_0+2
        XOR     A
        SBC     HL,BC
        POP     BC
        POP     HL
        RET     NZ
        LD      HL,(TEXTST)
        INC     HL
        INC     HL
        INC     HL
SEEK_LOOP:
        INC     HL
        LD      A,(HL)
		OR      A
		JR      NZ,SEEK_LOOP
		JP      (HL)



ENDIF
;=========================
IF MOD_B
defs 3
QSEG:
ENDIF

XWORK_END:
DEFS $2000-XWORK_END


;        ORG    2000H
;
;
;
; Memory to simulate screen - text - memory
;
; Since the original image memory only contains point patterns, the
; following memory area provides an image of the text screen.
; The 'screen editing' is possible only in this way.
;
; A hardcopy of the displayed text can be easily done PEEKing here
; and sending the output of the read characters to the printer.
; 
;
TEXTBF: DEFS    2000            ; Pseudo - video text memory



;
; work area
; (defc DIRARE  =    27D0H)
;
DIRARE:                    ;DIR area
        DEFS   800H


;        END   (2fd0)


DIRARE_END:
DEFS $2FD0-DIRARE_END



;        ORG    2FD0H

; ----------------------------
; MZ-800 Monitor  QD driver
; FI:M-QD  ver 0.2A  9.5.84
; ----------------------------
;

;
;
;
_QD:
        DEFW   _USR
        DEFM   "QD"
        DEFW   0
        DEFB   5FH             ;Seq, W, R
        DEFB   40H             ;1OPN
        DEFB   32              ;Max dir
        DEFW   Q_INI
        DEFW   Q_RINF
        DEFW   Q_WINF
        DEFW   Q_ON
        DEFW   1024
        DEFW   Q_RDAT
        DEFW   Q_WDAT
        DEFW   0               ;DELETE
        DEFW   0               ;WRDIR
        DEFW   Q_FREE
;
;
Q_FREE: XOR    A
        SCF
        RET
;
;
Q_INI:  RET    C
        CALL   TEST1
        DEFM   "Y"
        JR     Z,Q_INI2
        OR     A
        JP     NZ,ER03
        CALL   OKYN
Q_INI2: CALL   Q_RDY
        RET    C
        RST    3
        DEFB   _DI
        LD     C,2
        JR     QDIOX

;
;  Dir search start
;
Q_ON:   OR     A
        JR     NZ,QDOFF
        RST    3
        DEFB   _DI
        XOR    A
        LD     (FNUPS),A       ;KILL #
        LD     C,5
        CALL   QDIOR
        LD     BC,1
;
QDIOR:  LD     (QDPC),HL
        LD     (QDPE),DE
        LD     HL,QDPB
        LD     (HL),B
        DEC    HL
        LD     (HL),C
        JR     QDIO
;
QDOFF:
        CALL   PUSHR
        LD     C,6
        JR     QDIOX
;
;  Read inf
;   ent HL:adrs
;
Q_RINF: LD     BC,3
        LD     DE,64
        CALL   QDIOR
        RET    NC
        CP     40              ;not found
        SCF
        RET    NZ
        LD     A,0
        RET
;
; Read data
;  ent HL:buffer adars
;      BC:byte size
;
Q_RDAT:
        RST    3
        DEFB   _DI
        LD     DE,BC
        LD     BC,0103H
;
QDIOX:  CALL   QDIOR
        RST    3
        DEFB   _EI
        RET

;
; Write inf
;
Q_WINF: LD     A,37H           ;SCF
        LD     (Q_WD1),A
Q_RDY:  LD     BC,0101H
        JR     QDIOR
;
; Write data
;
Q_WDAT: PUSH   AF
        RST    3
        DEFB   _DI
Q_WD1:  XOR    A               ;XOR A / SCF
        JR     NC,Q_WD2
        LD     A,0AFH           ;XOR A
        LD     (Q_WD1),A
        CALL   SERFLW          ;First time only
        LD     (QDPG),HL
        LD     HL,ELMD
        LD     DE,64
        POP    AF
        JR     Q_WD3
;
Q_WD2:  LD     (QDPG),HL
        POP    AF
        SET    0,A
Q_WD3:  LD     (QDPI),BC
        LD     B,A
        LD     C,4
        JR     QDIOX
;
;
;QD WORK
;
;
QDTBL:
QDPA:
        DEFB   0
QDPB:
        DEFB   0
QDPC:
        DEFW   0
QDPE:
        DEFW   0
QDPG:
        DEFW   0
QDPI:
        DEFW   0
;
HDPT:
        DEFB   0
HDPT0:
        DEFB   0
;
FNUPS:  DEFB   0
FNUPS1: DEFB   0
FNUPF:  DEFB   0
;
FNA:
        DEFB   0
FNB:
        DEFB   0
;
MTF:
        DEFB   0
RTYF:
        DEFB   0
SYNCF:
        DEFB   0
;
RETSP:
        DEFW   0
;
defc FMS   =   0EFFFH
;

;
;------------------------------
;
; QDIO
;
;------------------------------
;
;
QDIO:
        LD     A,5             ;Retry 5
        LD     (RTYF),A
;
RTY:    DI
        CALL   QMEIN
        EI
        RET    NC
        PUSH   AF
        CP     40
        JR     Z,RTY4
        CALL   MTOF
        LD     A,(QDPA)
        CP     4               ;Write ?
        JR     NZ,RTY3
        LD     A,(FNUPF)
        OR     A
        JR     Z,RTY5
        XOR    A               ;FNUPF CLR
        LD     (FNUPF),A
        LD     A,(FNA)
        PUSH   HL              ;RETSP <= SP-2
        LD     (RETSP),SP
        POP    HL
;
        DI
        CALL   QDSVFN
        EI
        JR     C,RTY2
        CALL   MTOF
;
RTY3:   CP     3               ;Read ?
        JR     NZ,RTY5
        LD     HL,HDPT
        DEC    (HL)
;
RTY5:   POP    AF
        PUSH   AF
        CP     41
        JR     NZ,RTY2
;
        LD     HL,RTYF
        DEC    (HL)
        JR     Z,RTY2
        POP    AF
        LD     A,(FNUPS1)
        LD     (FNUPS),A
        JR     RTY
;
RTY2:   CALL   WRCAN
        CALL   QDHPC
RTY4:   POP    AF
        RET
;

;
QMEIN:  LD     (RETSP),SP
        LD     A,(QDPA)
        DEC    A
        JR     Z,QDRC          ;Ready Check
        DEC    A
        JR     Z,QDFM          ;Format
        DEC    A
        JR     Z,QDRD          ;Read
        DEC    A
        JP     Z,QDWR          ;Write
        DEC    A
        JR     Z,QDHPC         ;Head Point Clear
        JR     MTOFX           ;Motor Off
;
;-------------------------
;
; Head Point Clear
;
;-------------------------
;
QDHPC:
        PUSH   AF
        XOR    A
        LD     (HDPT),A
        POP    AF
        RET
;
;-------------------------
;
; Ready Check
;
;-------------------------
;
QDRC:
        LD     A,(QDPB)
        JP     QREDY
;

;
;-------------------------
;
; Format
;
;-------------------------
;
QDFM:
        XOR    A
        CALL   QDSVFN
        CALL   SYNCS2
        LD     BC,FMS
        LD     A,0AAH
;
QDFM1:  CPL
        LD     D,A
        CALL   TRANS
        DEC    BC
        LD     A,B
        OR     C
        JR     Z,QDFM2
        LD     A,D
        JR     QDFM1
;
QDFM2:  CALL   EOM
        CALL   MTOF
        CALL   MTON
        LD     A,(FNB)
        DEC    A
        JR     NZ,FMERR
        CALL   SYNCL2
        LD     BC,FMS
        LD     E,55H
QDFM3:  CP     E
        JR     NZ,FMERR
        DEC    BC
        LD     A,B
        OR     C
        JR     Z,QDFM4
        LD     A,E
        CPL
        LD     E,A
        CALL   RDATA
        JR     QDFM3
;
QDFM4:  CALL   RDCRC
MTOFX:  JP     MTOF
;
FMERR:  LD     A,41            ;Hard Err
        SCF
        RET
;

;
;-------------------------
;
; Read
;
;-------------------------
;
QDRD:
        LD     A,(MTF)
        OR     A
        CALL   Z,MTON
        CALL   HPS
        RET    C
        CALL   BRKC
;
        CALL   RDATA
        LD     C,A
        CALL   RDATA
        LD     B,A
        OR     C               ;Byte size zero check
        JP     Z,QDWE1
        LD     HL,(QDPE)       ;Byte size check
        SBC    HL,BC
        JP     C,QDWE1
        LD     HL,(QDPC)
;
;Block Data Read
;
BDR:    CALL   RDATA
        LD     (HL),A
        INC    HL
        DEC    BC
        LD     A,B
        OR     C
        JR     NZ,BDR
        CALL   RDCRC
        LD     A,(QDPB)
        BIT    0,A
        JR     NZ,MTOFX
        RET
;

;
;Head Point Search
;
HPS:
        LD     HL,FNB
        DEC    (HL)
        JR     Z,HPNFE         ;Not Found
        CALL   SYNCL2
        LD     C,A             ;BLKFLG => C reg
        LD     A,(HDPT)
        LD     HL,HDPT0
        CP     (HL)            ;Search ok ?
        JR     NZ,HPS1
        INC    A               ;HDPT count up
        LD     (HDPT),A
        LD     (HL),A          ;HDPT0 count up
        LD     A,(QDPB)
        XOR    C
        RRA
        RET    NC              ;=
;
;Dummy read
;
DMR:    CALL   RDATA
        LD     C,A
        CALL   RDATA
        LD     B,A
;
DMR1:   CALL   RDATA
        DEC    BC
        LD     A,B
        OR     C
        JR     NZ,DMR1
        CALL   RDCRC
        JR     HPS             ;next
;
HPS1:   INC    (HL)
        JR     DMR
;
HPNFE:  LD     A,40            ;Not Found
        SCF
        RET
;

;
;-------------------------
;
; Write
;
;-------------------------
;
QDWR:
        LD     A,(FNUPS)
        LD     (FNUPS1),A
        LD     A,(MTF)
        OR     A
        JR     NZ,QDWR1
        CALL   MTON
        LD     A,(FNUPS)
        LD     HL,FNB
        ADD    A,(HL)
        LD     (FNB),A
        INC    A
        LD     (HDPT),A
        CALL   HPS
        JP     NC,QDWE1        ;Hard err
QDWR1:  LD     A,(QDPB)
        LD     B,A
        AND    1
        JR     NZ,QDWR2
        LD     DE,QDPC
        LD     A,B
        RES    2,A
        CALL   BDW
        CALL   BRKC
;
QDWR2:  LD     DE,QDPG
        LD     A,(QDPB)
        SET    0,A
        CALL   BDW
        CALL   MTOF
        CALL   BRKC
;
        LD     A,(QDPB)
        AND    4
        JR     Z,NFNUP
        LD     A,(FNA)
        LD     HL,FNUPS
        ADD    A,(HL)
        CALL   QDSVFN
        LD     A,1
        LD     (FNUPF),A
QDWR4:  LD     A,(FNA)
        LD     HL,FNUPS1
        ADD    A,(HL)
        INC    A
        LD     (FNB),A
        INC    A
        LD     (HDPT),A
        CALL   HPS
        JR     NC,QDWE1
        LD     A,(QDPB)
        AND    1
        JR     NZ,QDWR3
        LD     DE,QDPC
        CALL   BDV
        RET    C
QDWR3:  LD     DE,QDPG
        CALL   BDV
        RET    C
        LD     A,(FNUPF)
        OR     A
        JR     Z,QDWR5
WRCAN:  XOR    A
        LD     (FNUPS),A
        LD     (FNUPF),A
;
QDWR5:  JP     MTOF
;
QDWE1:  LD     A,41
        SCF
        RET
;
NFNUP:  CALL   MTON
        JR     QDWR4
;
;Block Data Write
;
BDW:    PUSH   AF
        LD     HL,FNUPS
        INC    (HL)
        CALL   SYNCS2
        POP    AF
        CALL   TRANS
        CALL   RSET
        LD     A,C
        CALL   TRANS
        LD     A,B
        CALL   TRANS
;
BDW1:   LD     A,(HL)
        CALL   TRANS
        INC    HL
        DEC    BC
        LD     A,B
        OR     C
        JR     NZ,BDW1
        JP     EOM
;
;HL,BC SET
;
RSET:   EX     DE,HL
        LD     E,(HL)
        INC    HL
        LD     D,(HL)
        INC    HL
        LD     C,(HL)
        INC    HL
        LD     B,(HL)
        EX     DE,HL
        RET
;
;Block Data Verify
;
BDV:    CALL   SYNCL2
        CALL   RSET
        CALL   RDATA
        CP     C
        JR     NZ,QDWE1
        CALL   RDATA
        CP     B
        JR     NZ,QDWE1
;
BDV1:   CALL   RDATA
        CP     (HL)
        JR     NZ,QDWE1
        INC    HL
        DEC    BC
        LD     A,B
        OR     C
        JR     NZ,BDV1
        JP     RDCRC

;
;
; i/o port adrs
;
defc SIOAD   =    0F4H             ; sio A data
defc SIOBD   =    0F5H             ; sio B data
defc SIOAC   =    0F6H             ; sio A control
defc SIOBC   =    0F7H             ; sio B control

;
;
;
; Ready & Write protect
;    Acc = '0' : Ready check
;    Acc = '1' : & Write Protect
;
QREDY:
        LD     B,A
        LD     A,02H           ;SIO hard check
        OUT    (SIOBC),A
        LD     A,81H
        OUT    (SIOBC),A
        LD     A,02H
        OUT    (SIOBC),A
        IN     A,(SIOBC)
        AND    81H
        CP     81H
        JP     NZ,IOE50        ;Not ready
        LD     A,10H
        OUT    (SIOAC),A
        IN     A,(SIOAC)
        LD     C,A
        AND    08H
        JP     Z,IOE50         ;Not ready
        LD     A,B
        OR     A
        RET    Z               ;No err
        LD     A,C
        AND    20H
        RET    NZ              ;No err
        JP     IOE46           ;Write protect
;

;
;
; Write FN
;
QDSVFN:
        PUSH   AF
        LD     HL,SIOSD
        LD     B,09H
        CALL   LSINT           ;save init
;
SREDY:  LD     A,10H
        OUT    (SIOAC),A
        IN     A,(SIOAC)
        AND    8
        JP     Z,IOE50         ;Not ready
        LD     A,10H
        OUT    (SIOBC),A
        IN     A,(SIOBC)
        AND    8
        JR     Z,SREDY
        LD     BC,00E9H        ;Wait 160ms
        CALL   TIMW
        CALL   SBRK            ;Send Break
        CALL   SYNCS1          ;FN Only SYNC
        POP    AF
        CALL   TRANS           ;FN=A
        CALL   EOM             ;CRC FLAG(7EH)
        JR     FNEND
;
;
;
; MTON -- QD MOTOR ON
;         READ FILE NUMBER
;         READ &CHECK CRC,FLAG
;
MTON:
        LD     HL,SIOLD
        LD     B,0BH
        CALL   LSINT           ;load init
;
LREDY:  LD     A,10H
        OUT    (SIOAC),A
        IN     A,(SIOAC)
        AND    8
        JP     Z,IOE50         ;Not ready
        CALL   BRKC
        LD     A,10H
        OUT    (SIOBC),A
        IN     A,(SIOBC)
        AND    8
        JR     Z,LREDY
        LD     BC,00E9H        ;Wait 160ms
        CALL   TIMW
        CALL   SYNCL1          ;LOAD SYNC
        LD     (FNA),A
        INC    A
        LD     (FNB),A
        CALL   RDCRC
FNEND:  LD     HL,SYNCF
        SET    3,(HL)
        XOR    A
        LD     (HDPT0),A
        RET
;

;
;    sio initial
;
;
LSINT:  LD     C,SIOAC
        OTIR
        LD     A,05H
        LD     (MTF),A
        OUT    (SIOBC),A
        LD     A,80H
        OUT    (SIOBC),A
        RET
;
; Motor off
;
MTOF:
        PUSH   AF
        LD     A,05H
        OUT    (SIOAC),A
        LD     A,60H
        OUT    (SIOAC),A       ;WRGT OFF,TRANS DISABLE
        LD     A,05H
        OUT    (SIOBC),A
        XOR    A
        LD     (MTF),A
        OUT    (SIOBC),A
        POP    AF
        RET
;
;

;
; SYNCL1 -- LOAD F.N SYNC ONLY
;                (SEND BREAK 110ms)
; SYNCL2 -- LOAD FIRST FILE SYNC
;                (SEND BREAK 110ms)
; SYNCL3 -- LOAD FILES SYNC
;                (SEND BREAK 002ms)
;
SYNCL2:
        LD     A,58H
        LD     B,0BH
        LD     HL,SIOLD
        CALL   SYNCA
        LD     HL,SYNCF
        BIT    3,(HL)
        LD     BC,3            ;WAIT 2ms
        JR     Z,TMLPL
        RES    3,(HL)
SYNCL1: LD     BC,00A0H        ;WAIT 110ms
;
TMLPL:  CALL   TIMW
        LD     A,05H
        OUT    (SIOBC),A
        LD     A,82H
        OUT    (SIOBC),A
        LD     A,03H
        OUT    (SIOAC),A
        LD     A,0D3H
        OUT    (SIOAC),A
        LD     BC,2CC0H        ;loop 220ms
;
SYNCW0: LD     A,10H
        OUT    (SIOAC),A
        IN     A,(SIOAC)
        AND    10H
        JR     Z,SYNCW1
        DEC    BC
        LD     A,B
        OR     C
        JR     NZ,SYNCW0
        JP     IOE54           ;Un format
;
SYNCW1: LD     A,03H
        OUT    (SIOAC),A
        LD     A,0C3H
        OUT    (SIOAC),A
        LD     B,9FH           ;loop 3ms
;
SYNCW2: LD     A,10H
        OUT    (SIOAC),A
        IN     A,(SIOAC)
        AND    01H
        JR     NZ,SYNCW3
        DEC    B
        JR     NZ,SYNCW2
        JP     IOE54           ;Un format
;
SYNCW3: LD     A,03H
        OUT    (SIOAC),A
        LD     A,0C9H
        OUT    (SIOAC),A
        CALL   RDATA
        JP     RDATA
;
;
;
; SYNCS1 -- SAVE F.N SYNC
;                (SEND BREAK 220ms)
; SYNCS2 -- SAVE FIRST FILE SYNC
;                (SEND BREAK 220ms)
; SYNCS3 -- SAVE FILES SYNC
;                (SEND BREAK 020ms)
;
SYNCS2:
        LD     A,98H
        LD     B,09H
        LD     HL,SIOSD
        CALL   SYNCA
        CALL   SBRK
;
        LD     HL,SYNCF
        BIT    3,(HL)
        LD     BC,001DH        ;WAIT 20ms
        JR     Z,TMLPS
        RES    3,(HL)
SYNCS1: LD     BC,0140H        ;WAIT 220ms
;
TMLPS:  CALL   TIMW
        LD     A,05H
        OUT    (SIOAC),A
        LD     A,0EFH
        OUT    (SIOAC),A
        LD     BC,1            ;WAIT 0.7ms
        CALL   TIMW
IF RAMDISK
        LD     A,0A5H
        CALL   TRANS
		JP     TRANS_0
ELSE
        LD     A,0C0H
        OUT    (SIOAC),A
        LD     A,0A5H
        JR     TRANS
ENDIF
;
;
;
; SBRK -- SEND BREAK (00H)
;
SBRK:
        LD     A,05H
        OUT    (SIOAC),A
        LD     A,0FFH
        OUT    (SIOAC),A
        RET
;
;
;
SYNCA:  LD     C,SIOAC
        OUT    (C),A
        LD     A,5
        OUT    (SIOBC),A
        LD     A,80H
        OUT    (SIOBC),A
        OTIR
        RET
;

;
;
;
; EOM -- End off message
;         Save CRC#1,#2,FLAG
;         File space check
;
;
EOM:
        LD     BC,1            ;WAIT 0.7ms
        CALL   TIMW
        LD     A,10H
        OUT    (SIOBC),A
        IN     A,(SIOBC)
        AND    8
        RET    NZ
        JP     IOE53           ;NO file space
;
; RDCRC -- READ CRC & CHECK
;
RDCRC:
        LD     B,3
RDCR1:  CALL   RDATA
        DJNZ   RDCR1
RDCR2:  IN     A,(SIOAC)
        RRCA
        JR     NC,RDCR2        ; Rx Available
        LD     A,01H
        OUT    (SIOAC),A
        IN     A,(SIOAC)
        AND    40H
        JR     NZ,IOE41        ;Hard err
        OR     A
        RET
;

;
; Save 1 chr by Acc
;     & ready check
;
TRANS:
        PUSH   AF
TRA1:   IN     A,(SIOAC)
        AND    4               ;TRANS buf null
        JR     Z,TRA1
        POP    AF
        OUT    (SIOAD),A
NRCK:   LD     A,10H
        OUT    (SIOAC),A
        IN     A,(SIOAC)
        AND    08H
        JP     Z,IOE50         ;Not ready
        RET
;
; Read data (1 chr)
;
RDATA:
        CALL   NRCK
        IN     A,(SIOAC)       ;RR0
        RLCA
        JR     C,IOE41         ;Hard err
        RRCA
        RRCA
        JR     NC,RDATA
        IN     A,(SIOAD)
        OR     A
        RET
;

;
; i/o err
;
IOE41:  LD     A,41            ;Hard err
        DEFB   21H
IOE46:  LD     A,46            ;Write protect
        DEFB   21H
IOE50:  LD     A,50            ;Not ready
        DEFB   21H
IOE53:  LD     A,53            ;No file space
        DEFB   21H
IOE54:  LD     A,54            ;Un format
        LD     SP,(RETSP)
        SCF
        RET
;
;
;---------------------------------
;
;   wait  timer  clock 3.54368MHz
;
; BC=001H=  0.7ms(  0.698ms)
;    003H=  2.0ms(  2.072ms)
;    01DH= 20.0ms( 19.929ms)
;    0A0H=110.0ms(109.899ms)
;    0E9H=160.0ms(160.036ms)
;    140H=220.0ms(219.787ms)
;
;---------------------------------
;
TIMW:   PUSH   AF
TIMW1:  LD     A,150           ;MZ-1500=152
TIMW2:  DEC    A
        JR     NZ,TIMW2
        DEC    BC
        LD     A,B
        OR     C
        JR     NZ,TIMW1
        POP    AF
        RET
;

;
;--------------------------------
;
; SIO CH A COMMAND CHAIN
;
; SIOLD -- LOAD INIT. DATA
; SIOSD -- SAVE INIT. DATA
;
;--------------------------------
;
SIOLD:  DEFB   58H             ;CHANNEL RESET
        DEFB   04H             ;POINT WR4
        DEFB   10H             ;X1 CLOCK
        DEFB   05H             ;POINT WR1
        DEFB   04H             ;CRC-16
        DEFB   03H             ;POINT WR3
        DEFB   0D0H             ;ENTER HUNT PHASE
;Rx 8bits
        DEFB   06H             ;POINT WR6
        DEFB   16H             ;SYNC CHR(1)
        DEFB   07H             ;POINT WR7
        DEFB   16H             ;SYNC CHR(2)
;
SIOSD:  DEFB   98H             ;CHANNEL RESET
;Tx CRC Generator reset
        DEFB   04H             ;POINT WR4
        DEFB   10H             ;X1 CLOCK
        DEFB   06H             ;POINT WR6
        DEFB   16H             ;SYNC CHR(1)
        DEFB   07H             ;POINT WR7
        DEFB   16H             ;SYNC CHR(2)
        DEFB   05H             ;POINT WR5
        DEFB   6DH             ;Tx CRC ENABLE
;
;
; BREAK CHECK
;
BRKC:   LD     A,0E8H
        OUT    (LSD0),A
        NOP
        IN     A,(LSD1)
        AND    81H
        RET    NZ
        CALL   WRCAN
        JP     BREAKX          ;Can't CONT
;
;
; -----------------------------
; MZ-800  monitor
;         LDALL
;         SVALL
;         ver 0.1A 08.08.84
; -----------------------------
;
;   RAM i/o port
;
defc RCADR   =   0EBH             ;RAM file ctrl port
defc RDADR   =   0EAH             ;RAM file data port
;
;   RAM equ table
;
defc RMLIM   =   0000H            ;RAM file limit
defc RMADR   =   0002H            ;RAM file usage
defc RMTOP   =   0010H            ;RAM file top adrs
;
;   LDAL,SVAL WORK
;
RMFRE:  DEFW   0
FAS:    DEFW   0
NFT:    DEFW   0               ;1 File top
NBT:    DEFW   0               ;1 Block top
;
FLAGF:  DEFB   0
FNUPB:  DEFB   0
;
BLKF:   DEFB   0
BLKSL:  DEFB   0
BLKSH:  DEFB   0
;
;  SVC .LSALL
;    ent A=0 ... LOAD ALL
;        A=1 ... SAVE ALL
;
LSALL:
        CALL   PUSHR
        LD     HL,LDALM
        OR     A
        JR     Z,$+5
        LD     HL,SVALM
        LD     (LSAL1+1),HL
        RST    3
        DEFB   _CLRIO
        CALL   QDHPC
        PUSH   HL
        LD     (RETSP),SP
        POP    HL
        XOR    A
        CALL   QREDY
        JR     C,LSAL2
        LD     A,5             ;max retry
        LD     (RTYF),A
LSAL3:
        RST    3
        DEFB   _DI
LSAL1:  CALL   0               ;xxx LDALM or SVALM
        CALL   MTOF
        RST    3
        DEFB   _EI
        RET    NC
        CP     41
        JR     NZ,LSAL2
        LD     HL,RTYF
        DEC    (HL)
        JR     NZ,LSAL3
        LD     A,41
LSAL2:  JP     ERRORJ

;
;  LDALL main roution
;
;
LDALM:  LD     (RETSP),SP
        LD     HL,RMLIM
        CALL   EMLD2
        DEC    DE              ;RMFRE-end point buffer
        DEC    DE              ;end point buffer(2byte)
        LD     (RMFRE),DE      ;RAM buffer MAX adrs
        LD     HL,RMADR
        CALL   EMLD2
        LD     HL,RMTOP
        OR     A
        SBC    HL,DE
        JP     NZ,RMER         ;RAM Not init
        LD     (NFT),DE        ;first NFT set(0010H)
        INC    DE
        INC    DE
        LD     (NBT),DE        ;first NBT set(0012H)
        LD     HL,FAS
        LD     (HL),0             ;1 file byte size clear
        INC    HL
        LD     (HL),0
        CALL   MTON
;
LDALN:  LD     HL,FNB
        DEC    (HL)
        JP     Z,_LDEND
        CALL   SYNCL2
        LD     (BLKF),A
        CALL   RDATA
        LD     (BLKSL),A
        CALL   RDATA
        LD     (BLKSH),A
;
        LD     HL,(BLKSL)
        LD     DE,(NBT)
        ADD    HL,DE           ;NBT+Block size
        JR     C,LDALEE        ;over
        LD     BC,2
        ADD    HL,BC           ;HL+BLKF+BLKS(H,L)
LDALEE: JP     C,LDALE         ;64K over
        LD     BC,(RMFRE)
        SBC    HL,BC           ;usedadrs-maxused
        JR     Z,FBUF0         ;free just
        JP     NC,LDALE        ;NTB+lodingsize+3>free
FBUF0:  LD     HL,BLKF
        LD     BC,3
        CALL   EMSVD
        EX     DE,HL
        LD     DE,(BLKSL)
        LD     A,D             ;size zero check
        OR     E
        JP     Z,IOE41         ;size zero error
;
;
LEQM:   IN     A,(SIOAC)
        RLCA
        JR     C,LEQME
        RRCA
        RRCA
        JR     NC,LEQM
        IN     A,(SIOAD)
        LD     C,RCADR
        LD     B,H
        OUT    (C),L
        DEC    C
        OUT    (C),A
        INC    HL
        DEC    DE
        LD     A,D
        OR     E
        JR     NZ,LEQM
        CALL   RDCRC
        LD     (NBT),HL
        LD     HL,(FAS)        ;1 file all size
        LD     DE,(BLKSL)
        ADD    HL,DE
        INC    HL
        INC    HL
        INC    HL
        LD     (FAS),HL
        LD     A,(BLKF)
        BIT    2,A
        JR     NZ,LDALO        ;end block ?
;
LDALP:  CALL   BRKCHK
        JP     NZ,LDALN
        JP     BREAKZ
;
LDALO:  LD     DE,(NFT)
        ADD    HL,DE
        INC    HL
        INC    HL
        LD     (NFT),HL        ;next NFT
        PUSH   HL
        EX     DE,HL
        LD     DE,(FAS)
        CALL   EMSV2
        LD     HL,0
        LD     (FAS),HL
        POP    HL
        INC    HL
        INC    HL
        LD     (NBT),HL
        JR     LDALP
;
_LDEND:  LD     HL,(NFT)
        LD     DE,RMADR
        EX     DE,HL
        CALL   EMSV2
        EX     DE,HL
        NOP
        LD     DE,0
        CALL   EMSV2
        RET
;
LDALE:  CALL   _LDEND
        LD     A,53
LEQME:  SCF
        RET
;

;
;  SVALL main roution
;
SVALM:  LD     (RETSP),SP
        XOR    A
        LD     (FNUPB),A
        LD     (FLAGF),A
        LD     (FNUPS),A
SVALM0:
        LD     HL,RMTOP
        CALL   EMLD2
        LD     A,D
        OR     E
        RET    Z               ;RAM Not file
;
        CALL   MTON
        LD     A,(FNB)
        DEC    A
        JP     NZ,QDER         ;QD Not init
        LD     HL,RMTOP
;
SVALN:  CALL   EMLD2
        LD     (FAS),DE
        LD     A,D
        OR     E
        JR     Z,SVALQ
        INC    HL
        INC    HL
;
;
SVALO:  PUSH   HL
        CALL   SYNCS2
        POP    HL
        CALL   EMLD1
        CALL   TRANS
        INC    HL
        CALL   EMLD2
        LD     (BLKSL),DE
        LD     A,E
        CALL   TRANS
        LD     A,D
        CALL   TRANS
        INC    HL
        INC    HL
SEQM:   LD     C,RCADR
        LD     B,H
        OUT    (C),L
        DEC    C
        IN     B,(C)
;
SEQM1:  IN     A,(SIOAC)
        AND    4
        JR     Z,SEQM1
        LD     A,B
        OUT    (SIOAD),A
        INC    HL
        DEC    DE
        LD     A,D
        OR     E
        JR     NZ,SEQM
;
;   check EOM
;
        LD     BC,1
        CALL   TIMW
        LD     A,10H
        OUT    (SIOBC),A
        IN     A,(SIOBC)
        AND    8
        JR     NZ,SEQM2
        LD     A,53
        LD     (FLAGF),A
        JP     SVALQ
;
SEQM2:  PUSH   HL
        LD     HL,FNUPS
        INC    (HL)
        CALL   BRKCHK
        JP     Z,BREAKZ
        LD     HL,(FAS)
        LD     DE,(BLKSL)
        LD     BC,3
        XOR    A
        SBC    HL,DE
        SBC    HL,BC
        JR     Z,SVALP
        LD     (FAS),HL
        POP    HL
        JR     SVALO
;
SVALP:  POP    HL
        LD     A,(FNUPS)
        LD     (FNUPB),A
        JP     SVALN
;

;
SVALQ:  LD     A,(FNUPB)
        LD     (FNUPS),A
        CALL   MTOF
        CALL   MTON
        LD     HL,RMTOP
;
SVALT:  CALL   EMLD2
        LD     (FAS),DE
        INC    HL
        INC    HL
;
SVALR:  LD     A,(FNUPB)
        DEC    A
        JP     Z,SVALU
        LD     (FNUPB),A
;
        PUSH   HL
        CALL   SYNCL2
        POP    HL
        LD     D,A
        CALL   EMLD1
        CP     D
        JR     NZ,QDHER
        INC    HL
        CALL   EMLD2
        LD     (BLKSL),DE
        CALL   RDATA
        CP     E
        JR     NZ,QDHER
        CALL   RDATA
        CP     D
        JR     NZ,QDHER
        INC    HL
        INC    HL
;
;
VEQM:   IN     A,(SIOAC)
        RLCA
        JR     C,QDHER
        RRCA
        RRCA
        JR     NC,VEQM
        IN     A,(SIOAD)
;
        LD     C,RCADR
        LD     B,H
        OUT    (C),L
        DEC    C
        IN     B,(C)
        CP     B
        JR     NZ,QDHER
        INC    HL
        DEC    DE
        LD     A,D
        OR     E
        JR     NZ,VEQM
        CALL   RDCRC
        PUSH   HL
        CALL   BRKCHK
        JP     Z,BREAKZ
        LD     HL,(FAS)
        LD     DE,(BLKSL)
        LD     BC,3
        XOR    A
        SBC    HL,DE
        SBC    HL,BC
        JR     Z,SVALS
        LD     (FAS),HL
        POP    HL
        JR     SVALR
;
SVALS:  POP    HL
        JR     SVALT
;
SVALU:  CALL   MTOF
        LD     A,(FNUPS)
        CALL   QDSVFN
        XOR    A
        LD     (FNUPS),A
        LD     A,(FLAGF)
        OR     A
        RET    Z
        SCF
        RET
;
;
QDER:
RMER:   LD     A,54
        SCF
        RET
;
QDHER:
        LD     A,41
        SCF
        RET
;
;
;       END  (375AH)


;        ORG    375AH
; -----------------------------
; PLE-monitor   CMT-driver
; FI:M-CMT   ver 0.1  6.05.84
; -----------------------------
;

;
_CMT:
        DEFW   _RS             ;###diff Lx
        DEFM   "CMT"
        DEFB   0
        DEFB   5FH             ;Seq, W, R
_CMTF2: DEFB   0C0H             ;CMT, 1OPN
        DEFB   0
        DEFW   CTINI           ;INIT
        DEFW   CTRINF          ;RO
        DEFW   CTWINF          ;WO
        DEFW   __RET           ;START
        DEFW   256             ;Block/byte
        DEFW   CTRDAT          ;INP
        DEFW   CTWDAT          ;OUT
        DEFW   0               ;DELETE
        DEFW   0               ;WDIR
        DEFW   ER59            ;FREE
;
CTINI:
        CALL   TEST1
        DEFM   "T"             ; Change EOF process
        LD     HL,_CMTF2
        SET    __EOFE,(HL)        ; Tape BASIC mode
        RET    Z
        RES    __EOFE,(HL)        ; Disk BASIC mode
        OR     A
        RET
;
CTWINF: CALL   PUSHR
        LD     DE,IBUFE
        LD     A,(HL)
        LD     C,5
        CP     2               ; BTX 2 ==> 5
        JR     Z,CTWF2
        LD     C,4
        CP     3               ; BSD 3 ==> 4
        JR     Z,CTWF2
        LD     C,A
;
CTWF2:  LD     A,C
        LD     (DE),A
        INC    HL
        INC    DE
        LD     BC,17
        LDIR
        INC    HL
        INC    HL
        LD     BC,6
        LDIR
        LD     B,128-24
        CALL   CLRDE
        LD     HL,IBUFE
        LD     BC,128
        CALL   SAVE1
        JR     CTWD9
;
CTWDAT: CALL   SAVE2
;
CTWD9:  JP     C,BREAKX        ; break!
        RET                    ; ok!
;-------------------------------
;
; read inf
;   ent HL:adrs
;-------------------------------
CTRINF: LD     A,37H           ; SCF
        LD     (CTRDAT),A
        PUSH   HL
        LD     HL,IBUFE
        LD     BC,128
        CALL   LOAD1
        JR     C,CTERR         ; error or break
        LD     DE,FINMES       ; "Found"
        CALL   FNMPRT          ; ? file name
        POP    DE
        LD     A,(ZLOG)
        OR     A               ; ROPEN or LOAD?
        LD     A,(HL)
        JP     NZ,CTRI1        ; R
        LD     C,2             ; L BTX 5 ==> 2
        CP     5
        JR     Z,CTRI2
CTRI1:  LD     C,3             ;   BSD 4 ==> 3
        CP     4
        JR     Z,CTRI2
        LD     C,A
        SUB    2
        CP     2
        JP     C,ER61          ; file mode error!
;
CTRI2:  LD     A,C
        LD     (DE),A
        INC    HL
        INC    DE
        LD     BC,17
        LDIR
        XOR    A
        LD     B,2
        CALL   CLRDE
        LD     BC,6
        LDIR
        LD     B,32-18-2-6
        JP     CLRDE
;----------------------------------
;
;  read data
;    ent HL:adrs
;        BC:byte size
;----------------------------------
CTRDAT: XOR    A               ; XOR A / SCF
        JR     NC,CTRD2
        LD     A,0AFH           ;XOR A
        LD     (CTRDAT),A
        PUSH   HL              ; first time only
        LD     HL,ELMD
        LD     DE,LDNGMS       ; "Loading"
        CALL   FNMPRT          ; ? file name
        POP    HL
;
CTRD2:  CALL   LOAD2
        RET    NC              ; ok!
;
CTERR:  CP     2
        JP     NZ,BREAKX       ; break!
        LD     A,70+80H
        JP     ERRORJ          ; error!
;-----------------------------------
;
; CMT SAVE
;
;-----------------------------------
SAVE1:                    ; Inf.
        LD     A,0CCH
        JR     SAVE3
;
SAVE2:                    ; Data
        LD     A,53H
;
SAVE3:  LD     (SPSV+1),SP     ;;;
        LD     SP,IBUFE        ;;;
        PUSH   DE
        LD     E,A
        LD     D,0D7H           ; 'W'=Dreg.
        LD     A,B
        OR     C
        JR     Z,RET1
        CALL   CKSUM           ; check sum set
        CALL   MOTOR           ; motor on
        JR     C,WRI3          ; break!
        LD     A,E
        CP     0CCH
        JR     NZ,WRI2         ; write Data
        PUSH   DE
        LD     DE,WRTMES       ; "Writing"
        CALL   FNMPRT          ; ? file name
        POP    DE
;
WRI2:   DI
        CALL   GAP             ; write gap
        CALL   NC,WTAPE        ; write Inf. or Data
;
WRI3:   DI
        CALL   _MSTOP          ; motor off
;
RET1:   POP    DE
;
SPSV:   LD     SP,0            ;xxx
        PUSH   AF
        RST    3
        DEFB   _EI
        POP    AF
        RET
;--------------------------------
;
; CMT LOAD
;
;--------------------------------
LOAD1:                    ; Inf.
        LD     A,0CCH
        JR     LOAD3
;
LOAD2:                    ; Data
        LD     A,53H
LOAD3:  LD     (SPSV+1),SP     ;;;
        LD     SP,IBUFE        ;;;
        PUSH   DE
        LD     D,0D2H           ; 'L'->Dreg
        LD     E,A
        LD     A,B
        OR     C
        JR     Z,RET1
        CALL   MOTOR           ; motor on
        DI
        CALL   NC,TMARK        ; read gap & tape mark
        CALL   NC,RTAPE        ; read Inf. or Data
        JR     WRI3
;-------------------------------------
;
; CMT VERIFY
;
;-------------------------------------
CMTVRF:                    ; Data
        PUSH   HL
        LD     DE,VFNGMS       ; "Verifying"
        LD     HL,ELMD
        CALL   FNMPRT          ; ? file name
        POP    HL
        CALL   LOAD_2
        RET    NC              ; ok!
        CP     2
        JP     NZ,BREAKX       ; break!
        LD     A,3+80H
        JP     ERRORJ          ; error!
;
LOAD_2:
        LD     (SPSV+1),SP     ;;;
        LD     SP,IBUFE        ;;;
        PUSH   DE
        LD     D,0D2H
        LD     E,53H
        LD     A,B
        OR     C
        JR     Z,RET1
        CALL   CKSUM           ; check sum set
        CALL   MOTOR           ; motor on
        DI
;
        CALL   NC,TMARK        ; read gap & tape mark
        CALL   NC,TVRFY        ; verify
        JR     WRI3
;----------------------------------------
; motor on
;    exit CF=0:ok
;         CF=1:break
;----------------------------------------
MOTOR:  CALL   PUSHR
        RST    3
        DEFB   _DI
        LD     A,0F8H
        OUT    (LSD0),A        ; break set
        LD     B,10
;
MOT1:   IN     A,(LSD2)
        AND    10H
        JR     Z,MOT4
;
MOT2:   LD     B,0FFH           ; 2sec delay
;
MOT3:   CALL   DLY7            ; 7ms delay
        DJNZ   MOT3            ; motor entry adjust
        XOR    A               ; CF=0
        RET
;
MOT4:   LD     A,6
        OUT    (LSD3),A
        INC    A
        OUT    (LSD3),A
        DJNZ   MOT1
        LD     A,(CMTMSG)
        OR     A
        JR     NZ,MOT6
        RST    3
        DEFB   _CR2
        LD     A,7FH           ; Play mark
        RST    3
        DEFB   _CRT1X
        LD     A,' '
        RST    3
        DEFB   _CRT1C
        LD     A,D
        CP     0D7H             ; 'W'
        LD     DE,RECMES       ; "RECORD."
        JR     Z,MOT5          ; write
        LD     DE,PLYMES       ; "PLAY"
;
MOT5:
        RST    3
        DEFB   _CRTMS
        RST    3
        DEFB   _CR2
;
MOT6:   IN     A,(LSD2)
        AND    10H
        JR     NZ,MOT2
        IN     A,(LSD1)
        AND    80H
        JR     NZ,MOT6
        SCF                    ; CF=1,break!
        RET
;-----------------------------------
;
; write tape
;
;   in   BC=byte size
;        HL=adr.
;
;   exit CF=0:ok.
;        CF=1:break
;-----------------------------------
WTAPE:  PUSH   DE
        PUSH   BC
        PUSH   HL
        LD     D,2             ; repeat set
        LD     A,0F8H
        OUT    (LSD0),A        ; break set
;
WTAP1:  LD     A,(HL)
        CALL   WBYTE           ; 1 byte write
        IN     A,(LSD1)
        AND    80H             ; break check
        SCF
        JR     Z,RTP5          ; break!
        INC    HL
        DEC    BC
        LD     A,B
        OR     C
        JR     NZ,WTAP1
        LD     HL,(SUMDT)      ; check sum write
        LD     A,H
        CALL   WBYTE           ; high
        LD     A,L
        CALL   WBYTE           ; low
        CALL   LONG
        XOR    A
        DEC    D
        JR     Z,RTP5          ; ok!
        LD     B,A             ; Breg=256
;
WTAP2:  CALL   SHORT           ; write short 256
        DJNZ   WTAP2
        POP    HL
        POP    BC
        PUSH   BC
        PUSH   HL
        JR     WTAP1           ; repeat
;-------------------------------------
;
; read tape
;
;   in   BC=byte size
;        HL=load adr.
;
;   exit CF=0:ok
;        CF=1,Acc=2:error
;        else:break
;-------------------------------------
RTAPE:  PUSH   DE
        PUSH   BC
        PUSH   HL
        LD     D,2             ; repeat set
;
RTP1:   CALL   EDGE            ; edge search:(49c)
        JR     C,RTP5          ; break!:7c
; reading point search
        CALL   DLY3            ; 17c (1232c)
        IN     A,(LSD2)
        AND    20H
        JR     Z,RTP1          ; again
        LD     HL,0
        LD     (SUMDT),HL
        POP    HL
        POP    BC
        PUSH   BC
        PUSH   HL
;
RTP3:   CALL   RBYTE           ; 1 byte read
        JR     C,RTP5          ; error!
        LD     (HL),A             ; data->(mem.)
        INC    HL
        DEC    BC
        LD     A,B
        OR     C
        JR     NZ,RTP3
        LD     HL,(SUMDT)      ; check sum
        CALL   RBYTE           ; high
        JR     C,RTP5          ; error!
        CP     H
        JR     NZ,RTP6         ; error!
        CALL   RBYTE           ; low
        JR     C,RTP5          ; error!
        CP     L
        JR     NZ,RTP6         ; error!
;
RTP4:   XOR    A
;
RTP5:   POP    HL
        POP    BC
        POP    DE
        RET
;
RTP6:   DEC    D
        JR     NZ,RTP1         ; repeat
;
VFERR:  LD     A,2             ; error
        SCF
        JR     RTP5
;-------------------------------------
;
; verify tape
;
;   in   BC=byte size
;        HL=adr.
;
;   exit CF=0:ok
;        CF=1,Acc=2:error
;        else:break
;-------------------------------------
TVRFY:  PUSH   DE
        PUSH   BC
        PUSH   HL
        LD     D,2             ; repeat set
;
TVF1:   CALL   EDGE            ; edge search:(49c)
        JR     C,RTP5          ; break!:7c
; reading point search
        CALL   DLY3            ; 17c (1232c)
        IN     A,(LSD2)
        AND    20H
        JR     Z,TVF1          ; again
        POP    HL
        POP    BC
        PUSH   BC
        PUSH   HL
;
TVF2:   CALL   RBYTE           ; 1 byte read
        JR     C,RTP5          ; error!
        CP     (HL)               ; CP A.(mem.)
        JR     NZ,VFERR        ; verify error!
        INC    HL
        DEC    BC
        LD     A,B
        OR     C
        JR     NZ,TVF2
        LD     HL,(CSMDT)      ; Check sum.
        CALL   RBYTE           ; high
        JR     C,RTP5          ; error!
        CP     H
        JR     NZ,VFERR        ; error!
        CALL   RBYTE           ; low
        JR     C,RTP5          ; error!
        CP     L
        JR     NZ,VFERR        ; error!
        DEC    D
        JR     NZ,TVF1         ; repeat
        JR     RTP4            ; ok!
;
RECMES: DEFM   "RECORD."
PLYMES: DEFM   "PLAY"
        DEFB   0
;--------------------------------------
;
; file name print
;--------------------------------------
FNMPRT: LD     A,(CMTMSG)
        OR     A
        RET    NZ
        RST    3
        DEFB   _CR2
        RST    3
        DEFB   _CRTMS
        PUSH   HL
        INC    HL
        LD     A,'"'
        RST    3
        DEFB   _CRT1C
        LD     D,16
;
FNMLP:  LD     A,(HL)
        CP     0DH
        JR     Z,FNMLE
        RST    3
        DEFB   _CRT1C
        INC    HL
        DEC    D
        JR     NZ,FNMLP
;
FNMLE:  LD     A,'"'
        RST    3
        DEFB   _CRT1C
        RST    3
        DEFB   _CR2
        POP    HL
        RET
;
WRTMES: DEFM   "WRITING   "
        DEFB   0
FINMES: DEFM   "FOUND     "
        DEFB   0
LDNGMS: DEFM   "LOADING   "
        DEFB   0
VFNGMS: DEFM   "VERIFYING "
        DEFB   0
;
;
;-----------------------------------------
;
; tape format
;
;          <LONG>       <SHORT>
;      <460us><496us><240us>  <264us>
;      b      b      b  b     b  b
;      gxxxxxx°      gxx°  gxx°  g
; xxxxxt    b hxxxxxxt  hxxt  hxxt
;      b    b        b    b
;      b    b        b    b
;      / /  /        / /  /
;      ! ! Read point! ! Read point
;      ! 368us       ! 368us
;      Read edge     Read edge
;
;-----------------------------------------
;
; Information format  : Data format
;                     :
; * gap               : * gap
;     short 10 sec    :     short 5 sec
;           (22000)   :           (11000)
; * tape mark         : * tape mark
;     long  40        :     long  20
;     short 40        :     short 20
; * long 1            : * long 1
; * Information       : * Data
;               block :             block
;     (128 bytes)     :     (???? bytes)
; * check sum         : * check sum
;     (2 bytes)       :     (2 bytes)
; * long 1            : * long 1
; * short 256         : * short 256
; * Information       : * Data
;               block :             block
;     (128 bytes)     :     (???? bytes)
; * check sum         : * check sum
;     (2 bytes)       :     (2 bytes)
; * long 1            : * long 1
;
;-----------------------------------------
;
;
;   EDGE   (tape data edge search)
;          (85c+111c)/4= 49 clock
;
;   exit CF=0:ok
;        CF=1:break
;
EDGE:   LD     A,0F8H
        OUT    (LSD0),A        ; break set
        NOP
;
EDG1:   IN     A,(LSD1)
        AND    81H             ; shift & break
        JR     NZ,EDG2
        SCF
        RET
;
EDG2:   IN     A,(LSD2)        ; 11c
        AND    20H             ; 7c
        JR     NZ,EDG1         ; CSTR D5=0: 7c/12c
;
EDG3:   IN     A,(LSD1)        ; 11c
        AND    81H             ; 7c
        JR     NZ,EDG4         ; 7c/12c
        SCF
        RET
;
EDG4:   IN     A,(LSD2)        ; 7c
        AND    20H             ; 7c
        JR     Z,EDG3          ; CSTR D5=1: 7c/12c
        RET                    ; 10c
;--------------------------------------
;
;   1 byte read
;
;     exit  SUMDT=Store
;           CF=1:break
;           CF=0:data=Acc
;--------------------------------------
RBYTE:  PUSH   DE
        PUSH   BC
        PUSH   HL
        LD     HL,0800H        ; 8 repeat set
;
RBY1:   CALL   EDGE            ; edge search:(49c)
        JP     C,TM4           ; break!:7c
; reading point search:17c(1232c)
        CALL   DLY3            ; 17c (1232c)
        IN     A,(LSD2)        ; data read
        AND    20H             ; CF=0
        JP     Z,RBY2          ; again
        PUSH   HL
        LD     HL,(SUMDT)      ; check sum set
        INC    HL
        LD     (SUMDT),HL
        POP    HL
        SCF                    ; CF=1
;
RBY2:   LD     A,L
        RLA                    ; rotate left
        LD     L,A
        DEC    H
        JP     NZ,RBY1         ; repeat
        CALL   EDGE
        LD     A,L
        JR     TM4             ; ok!
;-------------------------------------
;
;  1 byte write
;    in Acc=data
;-------------------------------------
WBYTE:  PUSH   BC
        LD     B,8             ; 8 repeat set
        CALL   LONG            ; write long
;
WBY1:   RLCA                   ; rotate left
        CALL   C,LONG          ; 'H' long
        CALL   NC,SHORT        ; 'L' short
        DEC    B
        JP     NZ,WBY1         ; repeat
        POP    BC
        RET
;-------------------------------------
;
;   tape mark read
;
;     in   E=CCH:Inf.  long40,short40
;           else:Data  long20,short20
;
;     exit CF=0:ok
;          CF=1:break
;
;-------------------------------------
TMARK:  CALL   GAPCK
;
        PUSH   DE
        PUSH   BC
        PUSH   HL
        LD     HL,2828H        ; H=40,L=40
        LD     A,E
        CP     0CCH             ;'L'
        JR     Z,TM0
        LD     HL,1414H        ; H=20,L=20
;
TM0:    LD     (TMCNT),HL
;
TM1:    LD     HL,(TMCNT)
;
TM2:    CALL   EDGE            ; edge search:(49c)
        JR     C,TM4           ; break!:7c
; reading point search:17c(1232c)
        CALL   DLY3            ; 17c (1232c)
        IN     A,(LSD2)
        AND    20H
        JR     Z,TM1           ; again
        DEC    H
        JR     NZ,TM2
;
TM3:    CALL   EDGE            ; edge search:(49c)
        JR     C,TM4           ; break!:7c
; reading point search:17c(1232c)
        CALL   DLY3            ; 17c (1232c)
        IN     A,(LSD2)
        AND    20H
        JR     NZ,TM1          ; again
        DEC    L
        JR     NZ,TM3
        CALL   EDGE
;
TM4:    POP    HL
;
TM5:    POP    BC
        POP    DE
        RET
;------------------------------------
;
;   check sum set
;
;    in   BC=byte size
;         HL=adr.
;
;    exit SUMDT=store
;         CSMDT=store
;------------------------------------
CKSUM:  PUSH   DE
        PUSH   BC
        PUSH   HL
        LD     DE,0
;
CKS1:   LD     A,B
        OR     C
        JR     NZ,CKS2
        EX     DE,HL
        LD     (SUMDT),HL
        LD     (CSMDT),HL
        JR     TM4             ; ret
;
CKS2:   LD     A,(HL)
        PUSH   BC
        LD     B,8             ; 8 bits
;
CKS3:   RLCA                   ; rotate left
        JR     NC,CKS4
        INC    DE
;
CKS4:   DJNZ   CKS3
        POP    BC
        INC    HL
        DEC    BC
        JR     CKS1
;--------------------------------------
;
;   gap + tape mark
;
;     in   E=CCH:short gap (10 sec)
;           else:short GAP ( 5 sec)
;--------------------------------------
GAP:    PUSH   DE
        PUSH   BC
        LD     A,E
        LD     BC,55F0H        ; Inf. 22000(10 sec)
        LD     DE,2828H        ;      short40,long40
        CP     0CCH             ;'L'
        JP     Z,GAP1
        LD     BC,2AF8H        ; Data 11000( 5 sec)
        LD     DE,1414H        ;short20,long20
;
GAP1:   CALL   SHORT           ; write short
        DEC    BC
        LD     A,B
        OR     C
        JR     NZ,GAP1
;
GAP2:   CALL   LONG            ; write long
        DEC    D
        JR     NZ,GAP2
;
GAP3:   CALL   SHORT           ; write short
        DEC    E
        JR     NZ,GAP3
        CALL   LONG
        JR     TM5
;-----------------------------------------
;
;   GAP check
;   (long100 search)
;-----------------------------------------
GAPCK:  PUSH   DE
        PUSH   BC
        PUSH   HL
;
GAPCK1: LD     H,100           ; 100 repeat set
;
GAPCK2: CALL   EDGE            ; edge search:(49c)
        JR     C,TM4           ; error!:7c
        CALL   DLY3            ; reading point search:17c(1232c)
        IN     A,(LSD2)
        AND    20H
        JR     NZ,GAPCK1       ; again
        DEC    H
        JR     NZ,GAPCK2
        JR     TM4
;----------------------------------------
;
;  SHORT AND LONG PULSE FOR 1 BIT WRITE
;----------------------------------------
SHORT:  PUSH   AF              ; 11c
        LD     A,03H           ; 7c
        OUT    (LSD3),A        ; 11c
        CALL   DLY1            ; 17c (408c)
        CALL   DLY1            ; 17c (408c)
        LD     A,02H           ; 7c
        OUT    (LSD3),A        ; 11c
        CALL   DLY1            ; 17c (408c)
        CALL   DLY1            ; 17c (408c)
        POP    AF              ; 10c
        RET                    ; 10c
;
;
LONG:   PUSH   AF              ; 11c
        LD     A,03H           ; 7c
        OUT    (LSD3),A        ; 11c
        CALL   DLY4            ; 17c (1704c)
        LD     A,02H           ; 7c
        OUT    (LSD3),A        ; 11c
        CALL   DLY4            ; 17c (1704c)
        POP    AF              ; 10c
        RET                    ; 10c
;----------------------------------------
;
;  MOTOR STOP
;----------------------------------------
_MSTOP: PUSH   AF
        PUSH   BC
        PUSH   DE
        LD     B,10
;
MST1:   IN     A,(LSD2)        ; motor check
        AND    10H
        JR     Z,MST3          ; ok
        LD     A,06H           ; motor off
        OUT    (LSD3),A
        INC    A
        OUT    (LSD3),A
        DJNZ   MST1
;
MST3:   POP    DE
        POP    BC
        POP    AF
        RET
;-------------------------------------------
;
;   7.046 ms delay ... 24989c
;-------------------------------------------
DLY7:
        PUSH   BC              ; 11c
        LD     B,20            ; 7c
;
DLY_7:  CALL   DLY3            ; 17*19+17 (23332c)
        CALL   DLY0            ; 17*19+17 (  226c)
        DJNZ   DLY_7           ; 13*19+8
        POP    BC              ; 10c
        RET                    ; 10c
;-------------------------------------------
;
;   14 clock delay
;-------------------------------------------
DLY0:   NOP                    ; 4c
        RET                    ; 10c
;-------------------------------------------
;
;   347.4 us delay ... 1232c
;-------------------------------------------
DLY3:   NOP                    ; 4c
        LD     A,76            ; 7c
;
DLYA:   DEC    A               ;  4*XX+4
        JR     NZ,DLYA         ; 12*XX+7
        RET                    ; 10c
;-----------------------------------
;
; Delay for short.
;   115.0 us delay ... 408c
;-----------------------------------
DLY1:
        LD     A,24            ; 7c
        JR     DLYA            ; 12c
;-----------------------------------
;
; Delay for long.
;   480.4 us delay ... 1704c
;-----------------------------------
DLY4:
        LD     A,105           ; 7c
        JR     DLYA            ; 12c
;
;       END  (3B9EH)



CMT_END:
DEFS $3B9E-CMT_END



;        ORG    3B9EH

; ----------------------------
; PL-monitor  FD dummy
; FI:DMY-FD   ver 003  3.28.84
; ----------------------------
;

;
;
_FD:
        DEFW   _QD
        DEFB   0
;
CLX:                    ;dummy routines
DUST:
FLOFF:
FREEX:
INREC:
INX1B:
LD_DIR:
LDX:
LOPX:
OPX:
PRREC:
PRX1B:
RECST:
SVX:
        OR     A
        RET
;
FLOCK:
FSWAP:
        JP     ER59


;
;  SVC .DELET
;
FDELET:
        CALL   PUSHR
        LD     HL,(ZDELT)      ;SEQ
        LD     A,L
        OR     H
        JR     Z,FREN2
        PUSH   HL
        RST    3
        DEFB   _LOPEN
        LD     A,2
        LD     (ZRWX),A
        CALL   _OPEND
        JR     FREN4
;
; SVC .RENAM
;
FRENAM:
        CALL   PUSHR
        LD     HL,(ZWDIR)
        LD     A,L
        OR     H
FREN2:  JP     Z,ER59
        PUSH   HL
        RST    3
        DEFB   _LOPEN
        LD     HL,ELMD
        CALL   SETFNAM
        LD     HL,200H
        LD     (ZLOG),HL
        CALL   SERFLW          ;check already exist
FREN4:  POP    IX
        JP     IOCALL

;       END    (3BDFH)


FD_END:
DEFS $3C00-FD_END


;        ORG    3C00H

defc  __ADCN    =      00BB9H          ; Convert ASCII code to display code
defc  __DACN    =      00BCEH          ; Convert display code to ASCII code


;----------------------------------
;
; ascii display code trans
;
;----------------------------------
ADCN:
        CP     10H             ;EX only
        JR     C,_AD3          ; <10H ==> F0H
        CP     80H
        JR     Z,_AD7          ; 80H ==> 40H
        CP     0C0H
        JR     Z,_AD7          ; C0H ==> 80H
        DI
        OUT    (LSE2),A
        CALL   __ADCN 
        OUT    (LSE0),A
        EI
        RET
_AD3:   LD     A,0F0H
        RET
_AD7:   SUB    40H
        RET
;
DACN:
        CP     0F0H
        JR     NC,_DA3
        CP     73H
        JR     Z,_AD3          ; 73H ==> F0H
        CP     40H             ;EX only
        JR     Z,_DA7          ; 40H ==> 80H
        CP     80H
        JR     Z,_DA7          ; 80H ==> C0H
        DI
        OUT    (LSE2),A
        CALL   __DACN
        OUT    (LSE0),A
        EI
        CP     0F0H
        RET    NZ
_DA3:   LD     A,' '
        RET
_DA7:   ADD    A,40H
        RET
;
;
;
_KYTBL:
        PUSH   AF
        LD     A,L
        SUB    8
        JR     C,_KY0
        SUB    48
        JR     C,_KY1
_KY0:   ADD    A,10
        LD     L,A
        ADD    HL,BC
        LD     C,(HL)
        POP    AF
        RET
_KY1:   LD     A,(BC)
        PUSH   AF
        INC    BC
        LD     A,(BC)
        LD     B,A
        POP    AF
        LD     C,A             ;BC=ROM adrs
        ADD    HL,BC
        DI
        OUT    (LSE2),A
        LD     A,(HL)
        OUT    (LSE0),A
        EI
        CALL   DACN
        LD     C,A
        POP    AF
        RET
;        END    (3C64)


;        ORG    3C64H
; ----------------------------
; MZ-800      RS-232C driver
; FI:MON-RS   ver 001  8.02.84
; ----------------------------
;


IF     RSYS
        defc RMCH =   3
ELSE
        defc RMCH =   1
ENDIF
;
;
_RS:
        DEFW   _RAM
        DEFM   "RS"
        DEFW   0
        DEFB   8FH             ;Streem, O1C, I1C, W, R
        DEFB   RMCH            ;ch.
        DEFB   0
        DEFW   RSINI           ;INIT
        DEFW   RSRO            ;ROPEN
        DEFW   RSWO            ;WOPEN
        DEFW   RSCL            ;CLOSE
        DEFW   RSKL            ;KILL
        DEFW   RSINP           ;INP1C
        DEFW   RSOUT           ;OUT1C
        DEFW   __RET           ;POS
;
RSINI:  RET    C
        PUSH   IY
        CALL   SETIY
        CALL   RSINT0
        CALL   RSPARM
        JR     RETIY
;
RSINT0:
        RST    3
        DEFB   _DEASC
        LD     (IY+_MONIT),E
        CALL   TEST1
        DEFM   ","
        JP     NZ,ER03
        RST    3
        DEFB   _DEASC
        LD     (IY+_INIT),E
        CALL   TEST1
        DEFB   0
        RET    Z
        CALL   TEST1
        DEFM   ","
        JP     NZ,ER03
        RST    3
        DEFB   _DEASC
        LD     (IY+_CRLF),E
        RET


;
RSRO:
RSWO:   PUSH   IY
        CALL   SETIY
        LD     A,(IY+_STAT)
        INC    (IY+_STAT)
        OR     A
        CALL   Z,RSOPEN
        JR     RETIY
;
;
RSCL:
RSKL:   PUSH   IY
        CALL   SETIY
        DEC    (IY+_STAT)
        LD     A,(IY+_STAT)
        OR     A
        CALL   Z,RCLOSE
        JR     RETIY2
;
;
;
RSINP:  PUSH   IY
        CALL   SETIY
        CALL   RSINP0
        JP     C,IOERR
        CP     (IY+_CRLF)
        JR     NZ,$+4
        LD     A,0DH
RETIY2: OR     A
RETIY:  POP    IY
        RET
;
RSINP0: BIT    6,(IY+_INIT)
        JP     Z,GET1C
        LD     IX,GET1C
        LD     HL,IY
        LD     DE,_JISR
        ADD    HL,DE
        JP     JISR
;
RSOUT:  PUSH   IY
        CALL   SETIY
        CP     0DH
        JR     NZ,$+5
        LD     A,(IY+_CRLF)
        CALL   RSOUT0
        JR     RETIY
;
RSOUT0: BIT    6,(IY+_INIT)
        JP     Z,PUT1C
        LD     IX,PUT1C
        LD     HL,IY
        LD     DE,_JISX
        ADD    HL,DE
        LD     DE,(DISPX)
        JP     JISX


;
SETIY:  PUSH   AF
        PUSH   DE
        LD     A,(ZCH)
        INC    A
        LD     IY,__A-TBLN
        LD     DE,TBLN
SETIY2: ADD    IY,DE
        DEC    A
        JR     NZ,SETIY2
        LD     C,(IY+0)
        POP    DE
        POP    AF
        RET
;
;
;***  PORT ADDRESS EQU  ***
;
; Serial interface port (also valid on the MZ80K, e.g. MZ-8BIO3 board)
defc CHADT  =    0B0H	; Data port
defc CHACT  =    0B1H	;
defc CHBDT  =    0B2H
defc CHBCT  =    0B3H
;
;
defc CHCDT  =    0D0H
defc CHCCT  =    0D1H
defc CHDDT  =    0D2H
defc CHDCT  =    0D3H
;
defc _CRLF   =    -8
defc _JISX   =    -7
defc _JISR   =    -5
defc _MONIT  =    -3
defc _INIT   =    -2
defc _STAT   =    -1


;
;
        DEFS   1               ;CR or LF
        DEFS   2               ;for JISX
        DEFS   2               ;for JISR
        DEFS   1               ;monitor
        DEFS   1               ;init code
        DEFS   1               ;status
__A:    DEFB   CHACT           ;0
        DEFB   CHADT           ;1
        DEFS   1               ;2 Mask Pattern
        DEFW   1010H           ;3,4
        DEFW   4004H           ;5,6 WR4
        DEFW   0C003H           ;7,8 WR3
        DEFW   6005H           ;9,10 WR5
        DEFB   30H
        DEFB   3
;
;
        DEFS   8
__B:    DEFB   CHBCT
        DEFB   CHBDT
        DEFS   1
        DEFW   1010H
        DEFW   4004H
        DEFW   0C003H
        DEFW   6005H
        DEFB   30H
        DEFB   3
;
;
        IF     RSYS
        DEFS   8
__C:    DEFB   CHCCT           ;0
        DEFB   CHCDT           ;1
        DEFS   1               ;2 Mask Pattern
        DEFW   1010H           ;3,4
        DEFW   4004H           ;5,6 WR4
        DEFW   0C003H           ;7,8 WR3
        DEFW   6005H           ;9,10 WR5
        DEFB   30H
        DEFB   3
;
;
        DEFS   8
__D:    DEFB   CHDCT
        DEFB   CHDDT
        DEFS   1
        DEFW   1010H
        DEFW   4004H
        DEFW   0C003H
        DEFW   6005H
        DEFB   30H
        DEFB   3
        ENDIF
;
defc TBLN  =  __B-__A
;


;
;
;   Break Check
;
BRK:    CALL   BRKCHK
        RET    NZ
        JP     BREAKZ
;
;     sio  parameter  set
;
;
;
RSPARM:
        LD     A,18H           ;channel reset
        OUT    (C),A
        LD     A,30H           ;err reset
        OUT    (C),A
        LD     A,(IY+_INIT)    ;inital bit
        AND    0CH             ;stop bit
        JR     NZ,RSP0
        SET    2,(IY+_INIT)    ;1 bit/chr
RSP0:   LD     A,(IY+_INIT)    ;initial bit
        LD     B,A             ;B=init code
        AND    0FH             ;mask
        OR     40H             ;clock rate *16
        LD     (IY+6),A        ;wr4
        LD     A,B
        AND    80H             ;rx disable d7 bit/chr
        OR     40H
        LD     (IY+8),A        ;wr3
        RRA
        AND    7FH             ;dtroff
        OR     0AH             ;tx enable rtson dtroff
        LD     (IY+10),A       ;wr5
        LD     A,B
        OR     7FH
        LD     (IY+2),A        ;bit mask
        CALL   RSSUB
RSTBUF:
        IN     A,(C)
        RRCA
        RET    NC
        DEC    C
        IN     A,(C)
        INC    C
        LD     A,1
        OUT    (C),A
        IN     A,(C)
        AND    70H
        JR     Z,RSTBUF
        RET
;
;
;
;
;  SIO close
;
;
RCLOSE: RES    0,(IY+8)        ;rx disable
        RES    7,(IY+10)       ;rdy off
        LD     (IY+_STAT),0
RSSUB:  LD     B,10
        PUSH   IY
        POP    HL
        LD     DE,3
        ADD    HL,DE
        OTIR
        RET
;
;
;  SIO open
;
;
RSOPEN: LD     A,30H
        OUT    (C),A           ;err reset
        RET


;
;
;  in IY=channel data
;      C=channel control port
;
;
;
RSEN:   SET    0,(IY+8)        ;wr3 RX enable
        LD     A,13H
        OUT    (C),A           ;ext/int reset
        LD     A,(IY+8)        ;wr3
        OUT    (C),A           ;wr5
        LD     A,35H           ;err reset
        OUT    (C),A
        LD     A,(IY+10)       ;wr5
        OR     88H             ;dtr,rts on tx enable
        LD     (IY+10),A       ;wr5
        OUT    (C),A
        RET
;
;
RSDIS:  LD     A,3
        OUT    (C),A
        RES    0,(IY+8)        ;wr3 RX disenable
        LD     A,(IY+8)        ;wr3
        OUT    (C),A
;
RDYOF:  RES    7,(IY+10)       ;wr5 dtr reset
        JR     WR5OUT
;
;
RTSON:  SET    1,(IY+10)       ;wr5 rts set
        JR     WR5OUT
;
;
RTSOFF: RES    1,(IY+10)       ;wr5 rts reset
        JR     WR5OUT
;
;
RDYON:  SET    7,(IY+10)       ;wr5 dtr set
WR5OUT: LD     A,5
        OUT    (C),A
        LD     A,(IY+10)       ;wr5
        OUT    (C),A
        OR     A
        RET


;
;
;     Receive 1 char
;
;
GET1C:  CALL   PUSHR
        LD     C,(IY+0)
GET1:   CALL   BRK
        CALL   DRCKR
        JR     C,GET1
        CALL   RSEN
CHIN:   CALL   BRK
        IN     A,(C)
        RRCA
        JR     NC,CHIN         ;skip if no data
        DEC    C
        IN     A,(C)           ;data input
        INC    C
        AND    (IY+2)          ;mask
        PUSH   AF
        LD     A,1
        OUT    (C),A
        IN     A,(C)
        AND    70H
        JR     NZ,RSER         ;skip if err
        CALL   RDYOF
        POP    AF
        RET
;
;
;
RSER:   LD     B,A
        POP    AF
        PUSH   BC
        CALL   RSPARM
        POP    BC
        LD     A,29            ;framing err
        RLC    B
        RLC    B
        RET    C
        INC    A               ;overrun err
        RLC    B
        RET    C
        INC    A               ;parity err
        SCF
        RET


;
;
;     Send 1 char
;
;
PUT1C:  CALL   PUSHR
        LD     C,(IY+0)
        LD     D,A
        CALL   RTSON
PUT1:   CALL   BRK
        CALL   DRCKS
        CALL   NC,CTSCK
        JR     C,PUT1
        IN     A,(C)
        BIT    2,A             ;tx buf empty ?
        JR     Z,PUT1
        BIT    7,(IY+_MONIT)   ;all chr send?
        JR     Z,PUT2
        LD     A,1
        OUT    (C),A
        IN     A,(C)
        RRCA
        JR     NC,PUT1
PUT2:   DEC    C
        OUT    (C),D           ;data out
        INC    C
        BIT    6,(IY+_MONIT)   ;rts on/off?
        JR     Z,PUT3
        CALL   RTSOFF
PUT3:   OR     A
        RET
;
;  DCD check
;
DRCKR:  OR     A
        BIT    0,(IY+_MONIT)   ;moniter dr ?
        JR     DRCK1
;
DRCKS:  OR     A               ;carry clear
        BIT    1,(IY+_MONIT)   ;moniter dr ?
DRCK1:  RET    Z
        LD     A,10H           ;ext/int reset
        OUT    (C),A
        IN     A,(C)
        AND    8
        RET    NZ              ;cy=0
        SCF
        RET
;
; CTS check
;
CTSCK:  OR     A
        BIT    2,(IY+_MONIT)   ;moniter cts ?
        RET    Z
        LD     A,10H
        OUT    (C),A
        IN     A,(C)
        AND    20H
        RET    NZ
        SCF
        RET
;
;       END   (3EC6H)


;        ORG    3EC6H

; ----------------------------
; Lx-monitor  EMM driver
; FI:MON-EMM  ver 005  4.27.84
; ----------------------------
;

;
_RAM:
        DEFW   _FD
        DEFM   "RAM"
        DEFB   0
        DEFB   5FH
IF MOD_B
        DEFB   23H             ;1WOPN
ELSE
        DEFB   20H             ;1WOPN
ENDIF
        DEFB   32              ;Max dir
        DEFW   EMINI           ;INIT
        DEFW   EMRINF
        DEFW   EMWINF
        DEFW   EMON
        DEFW   1024
        DEFW   EMRDAT
        DEFW   EMWDAT
        DEFW   EMDEL
        DEFW   EMWDIR
        DEFW   EMFRKB
;
EMFRKB:
IF RAMDISK
        CALL   EMFRB_DI
ELSE
        CALL   EMFRB
ENDIF
        LD     C,H
        LD     B,0             ;/256
        SRL    C               ;/512
        SRL    C               ;/1024
        OR     A
        RET
;
EMFRB:  PUSH   DE
        LD     HL,0            ;free area(bytes)
        CALL   EMLD2           ;max
        PUSH   DE
        INC    HL
        INC    HL
        CALL   EMLD2           ;use
        POP    HL
        SBC    HL,DE
        JP     C,ER41          ;I/O ERR
        POP    DE
        RET
;
;
EMCLR:  LD     DE,10H
EMSETU: LD     HL,2
        CALL   EMSV2           ;Set used mem
        EX     DE,HL
        LD     DE,0
        JP     EMSV2           ;File end mark

;
EMINI:  RET    C
        LD     A,(EMFLG)
        OR     A
        JP     Z,ER50
        CALL   OKYN
        CALL   TEST1
        DEFM   ","
        PUSH   HL
IF RAMDISK
        CALL   EMCLR_DI
ELSE
        CALL   EMCLR
ENDIF
        POP    HL
        CALL   TEST1
        DEFB   0
        RET    Z               ;INIT "EM:"
        RST    3
        DEFB   _DEASC          ;INIT "EM:$hhhh"
EMINI2: LD     HL,0
        DI
        LD     B,1
        LD     A,D
        AND    0FCH
        CP     0FCH
        LD     HL,0FFFFH
        JR     Z,EMINI3        ;if >=FC00 then FFFF
        LD     B,3
        LD     A,D
        OR     A
        LD     HL,20H
        JR     NZ,$+3           ;if <=00FF then 0020
EMINI3: EX     DE,HL
        LD     A,B
        LD     (EMFLG),A
        LD     HL,0
        CALL   EMSV2           ;Set max mem
        CALL   PBCCLR
        EI
        RET


;
;  EMM power on routine
;
EMMPWR:
        LD     HL,8
        LD     B,L
        LD     C,0
EMPWR2: CALL   EMLD1
        SUB    L
        OR     C
        LD     C,A
        LD     A,L
        CALL   EMSV1
        INC    L
        DJNZ   EMPWR2
        LD     A,C
        OR     A
        JR     NZ,EMPWR4
        LD     HL,0            ;already initialized
        CALL   EMLD2
        LD     A,2
        INC    D
        JR     Z,$+3
        INC    A
        LD     (EMFLG),A
        JP     PBCCLR
EMPWR4:
        CALL   EMCLR
        LD     HL,0            ;check EMM installed?
        LD     A,5AH
        CALL   EMSV1
        CALL   EMLD1
        SUB    5AH
EMPWR_SMC:
IF MOD_B
        LD     DE,0FFFFH        ;64KB MOD
ELSE
        LD     DE,0C000H        ;Initial set 48KB
ENDIF
        JR     Z,EMINI2
        XOR    A
        LD     (EMFLG),A
        RET

;
;  Dir search start
;
EMON:   LD     A,(EMFLG)
        OR     A
        JP     Z,ER50
        LD     HL,10H
        LD     (EMPTR),HL
        RET
;
;  Read inf
;    ent HL:adrs
;
EMRINF: LD     BC,HL
        LD     HL,(EMPTR)
IF RAMDISK
        CALL   EMLD2_DI
ELSE
        CALL   EMLD2
ENDIF
        LD     A,D
        OR     E
        SCF
        RET    Z
        INC    HL
        INC    HL
        PUSH   HL
        ADD    HL,DE
        JP     C,ER41          ;I/O ERR
        LD     (EMPTR),HL
        POP    HL
        INC    HL
        INC    HL
        INC    HL
        LD     DE,BC
        LD     BC,32-2
        CALL   EMLDD
        LD     BC,32+2
        ADD    HL,BC
        EX     DE,HL
        LD     (HL),E             ;Save data area adrs
        INC    HL

IF RAMDISK
        JP     EMRINF_EI
ELSE
        LD     (HL),D
        OR     A
        RET
ENDIF
;
;  Read data
;    ent HL:buffer adrs
;        BC:byte size
;
EMRDAT: EX     DE,HL
        LD     L,(IY+30)
        LD     H,(IY+31)
        INC    HL
        INC    HL
        INC    HL
IF RAMDISK
        CALL   EMLDD_0
ELSE
        CALL   EMLDD
ENDIF
        LD     (IY+30),L
        LD     (IY+31),H
        OR     A
        RET

;
;  Write file
;    HL:inf adrs
;
EMWINF: PUSH   AF
        CALL   SERFLW
        PUSH   HL
        LD     HL,2
IF RAMDISK
        CALL   EMLD2_DI_0
ELSE
        CALL   EMLD2
ENDIF
        LD     (EMWP0),DE
        PUSH   DE
        LD     HL,64+7
        ADD    HL,DE
        CALL   EMFRE_          ;Check file space
        POP    DE
        INC    DE
        INC    DE
        POP    HL              ;inf adrs
        LD     BC,64
        POP    AF
IF RAMDISK
        CALL   EMSVB_EI
ELSE
        CALL   EMSVB
ENDIF
        LD     (EMWP1),DE
        RET


;
;  Write data
;    HL:data adrs
;    BC:data bytes
;    A0:close flag
;
;
EMWDAT: PUSH   AF
        PUSH   HL
        PUSH   BC
        LD     HL,(EMWP1)
        INC    BC
        INC    BC
        INC    BC
        ADD    HL,BC
        CALL   EMFRE_
        POP    BC
        POP    HL
        LD     DE,(EMWP1)
        POP    AF
        PUSH   AF
        OR     01H             ;data block
        CALL   EMSVB
        LD     (EMWP1),DE
        POP    AF
        BIT    2,A             ;close ?
        RET    Z               ;no
        PUSH   DE              ;yes
        CALL   EMSETU
        POP    HL
        LD     DE,(EMWP0)
        DEC    HL
        DEC    HL
        OR     A
        SBC    HL,DE
        EX     DE,HL
        JP     EMSV2
;
;
EMFRE_: JR     C,ER53A
        PUSH   HL
        LD     HL,0
        CALL   EMLD2
        OR     A
        POP    HL
        SBC    HL,DE
        RET    C
ER53A:  JP     ER53            ;No file pace


;
;  delete file
;
EMDEL:  LD     HL,(ELMD30)
        LD     DE,-64-5
        ADD    HL,DE           ;HL:=move destination
        CALL   EMLD2           ;DE:=delete size - 2
        EX     DE,HL           ;DE:=move destination
        ADD    HL,DE
        INC    HL
        INC    HL              ;HL:=move source
        PUSH   DE
        PUSH   HL
        LD     HL,2
        CALL   EMLD2
        EX     DE,HL           ;HL:=last use
        POP    DE              ;DE:=move source
        PUSH   DE
        OR     A
        SBC    HL,DE
        INC    HL
        INC    HL
        LD     BC,HL           ;BC:=move bytes
        POP    HL              ;HL:=move source
        POP    DE              ;DE:=move destination
        CALL   EMLDIR
        DEC    DE
        DEC    DE              ;DE:=new last-use
        LD     HL,2
        JP     EMSV2
;
;  write dir
;
EMWDIR: LD     HL,(ELMD30)
        LD     DE,-64
        ADD    HL,DE
        EX     DE,HL
        LD     HL,ELMD
        LD     BC,32
        JP     EMSVD


;
IF MOD_B
;defc EM_P0   =   0ECH
;defc EM_P1   =   0EFH
ELSE
defc EM_P0   =   0EAH
defc EM_P1   =   0EBH
ENDIF

;
; EMM 1 Byte Write
;   ent A: data
;       HL:EMM adrs
;
EMSV1:
        PUSH   BC
IF MOD_B
        CALL   EMSV1_00
        IN     B,(C)
        LD     B,H
        OUT    (C),A
        POP    BC
ELSE
        LD     C,EM_P1
        LD     B,H
        OUT    (C),L
        OUT    (EM_P0),A
        POP    BC
        OR     A
ENDIF
        RET
;
; EMM 1 Byte Read
;   ent HL:EMM adrs
;   ext A: dat
;
EMLD1:
        PUSH   BC
IF MOD_B
        CALL   EMSV1_00
        IN     B,(C)
        LD     B,H
		IN     A,(C)
        POP    BC
ELSE
        LD     C,EM_P1
        LD     B,H
        OUT    (C),L
        IN     A,(EM_P0)
        POP    BC
        OR     A
ENDIF
        RET
;
; EMM 2 Byte Write
;   ent DE:data
;       HL:EMM adrs
;
EMSV2:
        LD     A,E
        CALL   EMSV1
        INC    HL
        LD     A,D
        CALL   EMSV1
        DEC    HL
        RET
;
; EMM 2 Byte Read
;   ent HL:EMM adrs
;       DE:data
;
EMLD2:
        CALL   EMLD1
        LD     E,A
        INC    HL
        CALL   EMLD1
        LD     D,A
        DEC    HL
        RET


;
; EMM write block
;   ent HL :data Top
;       DE :EMM Adrs
;       BC :byte Size
;       A  :block flag
;
EMSVB:  EX     DE,HL
        CALL   EMSV1
        INC    HL
        LD     A,C
        CALL   EMSV1
        INC    HL
        LD     A,B
        CALL   EMSV1
        INC    HL
        EX     DE,HL
EMSVD:
        EX     DE,HL
EMSVE:  LD     A,(DE)
        CALL   EMSV1
        INC    HL
        INC    DE
        DEC    BC
        LD     A,B
        OR     C
        JR     NZ,EMSVE
        EX     DE,HL
        RET
;
; EMM BC Byte Read
;   ent DE :Store Top
;       HL :EMM Adrs
;       BC :Byte Size
;
EMLDD:
        CALL   EMLD1
        LD     (DE),A
        INC    HL
        INC    DE
        DEC    BC
        LD     A,B
        OR     C
        RET    Z
        JR     EMLDD
;
; EMM BC Byte LDIR
;   ent HL :EMM source top
;       DE :EMM destination top
;       BC :Byte Size
;
EMLDIR:
        CALL   EMLD1           ;EMM (HL) Data => Acc
        EX     DE,HL
        CALL   EMSV1           ;Acc => (DE) EMM
        EX     DE,HL
        INC    HL
        INC    DE
        DEC    BC
        LD     A,B
        OR     C
        RET    Z               ;End
        JR     EMLDIR

;       END    (40FA)



;        ORG    40FAH

; ----------------------------
; MZ800-monitor  PSG handlar
; FI:MON-PSG  ver 001  7.26.84
; ----------------------------
;

;
;
defc NMAX   =    83              ;/ÙÄs max
defc PSGA   =    0F2H
defc PSG3   =    3F2H
defc PSG9   =    9F2H
;
        IF     SYS
defc MUSCH   =    6
defc MAXCH   =    8
defc PSGALL  =    0E9H
defc PSGOFF  =    4E9H
        ELSE
defc MUSCH   =    3
defc MAXCH   =    4
defc PSGALL  =    0F2H
defc PSGOFF  =    4F2H
        ENDIF
;----------------------------------
;
; INTM (music interrupt mode )
;0 no operation
;1 music or noise
;2 sound n.time
;
;----------------------------------
;
INTM:
        DEFB   0
SBUSY:  DEFB   0               ;music or noise only
INTC:   DEFB   0
;----------------------------------
;
;   sound out current tabel
;
;
;----------------------------------
;    tone 1a
;
STBL:   DEFB   80H             ;frequency (l)
        DEFB   00H             ;frequency (h)
        DEFB   9FH             ;attenation
;    tone 2a
        DEFB   0A0H            ;frequency (l)
        DEFB   00H             ;frequency (h)
        DEFB   0BFH            ;attenation
;    tone 3a
        DEFB   0C0H            ;frequency (l)
        DEFB   00H             ;frequency (h)
STN0:   DEFB   0DFH            ;attenation
;
        IF     SYS
;    tone 1b
;
        DEFB   80H             ;frequency (l)
        DEFB   00H             ;frequency (h)
        DEFB   9FH             ;attenation
;    tone 2b
        DEFB   0A0H            ;frequency (l)
        DEFB   00H             ;frequency (h)
        DEFB   0BFH            ;attenation
;    tone 3b
        DEFB   0C0H            ;frequency (l)
        DEFB   00H             ;frequency (h)
STN1:   DEFB   0DFH            ;attenation
        ENDIF


;----------------------------------
;
; play table
;
;----------------------------------
PTBL:   DEFB   00H             ;ch no.
        DEFB   00H             ;atc0
        DEFB   00H             ;atc1
        DEFB   00H             ;emva(l)
        DEFB   00H             ;emva(h)
        DEFB   00H             ;att
        DEFB   00H             ;length0
        DEFB   00H             ;tempo0
        DEFB   00H             ;length1
        DEFB   00H             ;tempo1
        DEFB   00H             ;qbuf(l)
        DEFB   00H             ;qbuf(h)
        DEFB   00H             ;emvp
        DEFB   00H             ;status
        DEFB   00H             ;vol
        DEFB   00H             ;reserve
        DEFB   01H             ;ch no.
        DEFS   15              ;ch1
        DEFB   02H             ;ch no.
        DEFS   15              ;ch2
        DEFB   03H             ;ch no.
        DEFS   15              ;noise1
;
        IF     SYS
        DEFB   04H             ;ch no.
        DEFS   15              ;ch3
        DEFB   05H             ;ch no.
        DEFS   15              ;ch4
        DEFB   06H             ;ch no.
        DEFS   15              ;ch5
        DEFB   07H             ;ch no.
        DEFS   15              ;noise2
        ENDIF
;----------------------------------
;
;
;  ontyo     tabel
;
;----------------------------------
LTBL:   DEFB   1               ;0
        DEFB   2               ;1
        DEFB   3               ;2
        DEFB   4               ;3
        DEFB   6               ;4
        DEFB   8               ;5
        DEFB   12              ;6
        DEFB   16              ;7
        DEFB   24              ;8
        DEFB   32              ;9
;----------------------------------
;
;
; tempo tabel
;
;----------------------------------
        DEFB   23              ;1  64
        DEFB   20              ;2  74
        DEFB   17              ;3  90
        DEFB   13              ;4  114
        DEFB   10              ;5  152
        DEFB   7               ;6  222
        DEFB   3               ;7  450


;----------------------------------
;    emvelop pattern tabel
;
;    ATT ÀÙÛÛÙ    code
;
;           0        3
;          -1        4
;          +1        5
;           r        0
;         max        1
;         min        2
;----------------------------------
ETBL:   DEFB   00H             ;emvp 0
        DEFB   05H
        DEFB   03H
        DEFB   03H             ;dummy
;
        DEFB   0FH             ;emvp 1
        DEFB   04H
        DEFB   01H
        DEFB   03H             ;dummy
;
        DEFB   00H             ;emvp 2
        DEFB   05H
        DEFB   02H
        DEFB   00H
;
        DEFB   0FH             ;emvp 3
        DEFB   04H
        DEFB   01H
        DEFB   00H
;
        DEFB   00H             ;emvp 4
        DEFB   05H
        DEFB   02H
        DEFB   03H
;
        DEFB   0FH             ;emvp 5
        DEFB   04H
        DEFB   03H
        DEFB   03H             ;dummy
;
        DEFB   00H             ;emvp 6
        DEFB   05H
        DEFB   04H
        DEFB   00H
;
        DEFB   0FH             ;emvp 7
        DEFB   04H
        DEFB   05H
        DEFB   00H
;
        DEFB   00H             ;emvp 8
        DEFB   03H
        DEFB   03H
        DEFB   00H


;----------------------------------
;
;  frequency tabel
;
;----------------------------------
NTBL:   DEFW   3F00H           ; A
        DEFW   3B07H           ; A#
        DEFW   3802H           ; B
;
;      octave 1
;
        DEFW   340FH           ; C
        DEFW   3200H           ; C#
        DEFW   2F03H           ; D
        DEFW   2C09H           ; D#
        DEFW   2A01H           ; E
        DEFW   270BH           ; F
        DEFW   2507H           ; F#
        DEFW   2306H           ; G
        DEFW   2106H           ; G#
        DEFW   1F08H           ; A
        DEFW   1D0CH           ; A#
        DEFW   1C01H           ; B
;
;      octave 2
;
        DEFW   1A08H           ; C
        DEFW   1900H           ; C#
        DEFW   1709H           ; D
        DEFW   1604H           ; D#
        DEFW   1500H           ; E
        DEFW   130DH           ; F
        DEFW   120CH           ; F#
        DEFW   110BH           ; G
        DEFW   100BH           ; G#
        DEFW   0F0CH           ; A
        DEFW   0E0EH           ; A#
        DEFW   0E00H           ; B
;
;      octave 3
;
        DEFW   0D04H           ; C
        DEFW   0C08H           ; C#
        DEFW   0B0DH           ; D
        DEFW   0B02H           ; D#
        DEFW   0A08H           ; E
        DEFW   090FH           ; F
        DEFW   0906H           ; F#
        DEFW   080DH           ; G
        DEFW   0805H           ; G#
        DEFW   070EH           ; A
        DEFW   0707H           ; A#
        DEFW   0700H           ; B
;
;      octave 4
;
        DEFW   060AH           ; C
        DEFW   0604H           ; C#
        DEFW   050EH           ; D
        DEFW   0509H           ; D#
        DEFW   0504H           ; E
        DEFW   040FH           ; F
        DEFW   040BH           ; F#
        DEFW   0407H           ; G
        DEFW   0403H           ; G#
        DEFW   030FH           ; A
        DEFW   030BH           ; A#
        DEFW   0308H           ; B
;
;      octave 5
;
        DEFW   0305H           ; C
        DEFW   0302H           ; C#
        DEFW   020FH           ; D
        DEFW   020DH           ; D#
        DEFW   020AH           ; E
        DEFW   0208H           ; F
        DEFW   0205H           ; F#
        DEFW   0203H           ; G
        DEFW   0201H           ; G#
        DEFW   010FH           ; A
        DEFW   010EH           ; A#
        DEFW   010CH           ; B
;
;      octave 6
;
        DEFW   010AH           ; C
        DEFW   0109H           ; C#
        DEFW   0108H           ; D
        DEFW   0106H           ; D#
        DEFW   0105H           ; E
        DEFW   0104H           ; F
        DEFW   0103H           ; F#
        DEFW   0102H           ; G
        DEFW   0101H           ; G#
        DEFW   0100H           ; A
        DEFW   000FH           ; A#
        DEFW   000EH           ; B
;
;
;
MSTBL:  DEFW   0BF9FH
        DEFW   0FFDFH
;
;
;
TSOUT:  DEFB   80H             ;ch 0
        DEFB   00H
        DEFB   90H             ;att
TSOUTC: DEFB   00H             ;counter(l)
        DEFB   00H             ;counter(h)


;----------------------------------
;
;
; Music interrupt routine
;
;
;----------------------------------
PSGINT:
        PUSH   IY
        CALL   INT0
        POP    IY
        EI
        RETI
;
INT0:   CALL   PUSHRA
        CALL   MSTART          ;8253 intialize
;
        LD     A,(INTM)
        OR     A
        JP     Z,MSTOP0
        DEC    A
        JP     NZ,SDINT        ;skip if sound out
;
        LD     BC,PSG9         ;psg data out
        LD     HL,STBL
        OTIR
;
        IF     SYS
        LD     B,9
        INC    C
        OTIR
        ENDIF
;
        LD     B,8
        LD     A,(SBUSY)
        OR     A
        JP     Z,MSTOP0        ;channel all close
        LD     C,A
INT1:   DEC    B
        RET    M
        RLC    C
        JR     NC,INT1
        PUSH   BC
        LD     A,B
        CALL   INTER
        BIT    0,(IY+13)
        CALL   Z,NINT
        CALL   MINT
        POP    BC
        JR     INT1


;----------------------------------
;
;  Emvelop     control
;
;----------------------------------
NINT:   DEC    (HL)            ;HL=chx act0
        RET    NZ
        INC    HL              ;new couter set
        LD     A,(HL)          ;load atc1
        DEC    HL
        LD     (HL),A          ;save atc0
        INC    HL
        INC    HL
        LD     E,(HL)          ;HL=enva
        INC    HL
        LD     D,(HL)          ;HL=enva+1
        EX     DE,HL
NINT1:  LD     A,(HL)          ;env ÀÙÛÛÙ data
        OR     A               ;data check 0
        JR     NZ,NINT2        ;noskip if repeat
        DEC    HL
        DEC    HL
        JR     NINT1
;
;
NINT2:  EX     DE,HL           ;de=curent emva
        INC    HL
        DEC    A
        JR     Z,NINT3         ;skip if max Acc=1
        DEC    A
        JR     Z,NINT5         ;skip if min Acc=2
        DEC    A
        RET    Z               ;ÀÙÛÛÙ 0  Acc=3
;
        DEC    A               ;Acc=4
        LD     A,(HL)          ;att data
        JR     Z,NINT4         ;skip if dec att
        INC    A               ;Acc=5
        CP     15              ;max
        JR     Z,NINT7
        JR     C,NINT7
NINT3:  LD     A,15            ;maximam
        JR     NINT6
NINT4:  DEC    A               ;dec att
        JP     M,NINT5
        LD     C,(IY+14)       ;vol minimum
        CP     C
        JR     NC,NINT7
NINT5:  LD     A,(IY+14)       ;minimum
NINT6:  INC    DE              ;de=next curent emva
NINT7:  LD     (HL),A          ;new att data
        DEC    HL
        LD     (HL),D
        DEC    HL
        LD     (HL),E
;
ATTSET: AND    0FH
        LD     B,A             ;acc=att data
ATTS1:  LD     A,(IX+2)        ;stbl att
        AND    0F0H
        OR     B
        LD     (IX+2),A        ;stbl att
        RET


;----------------------------------
;
;    new data interpret routine
;
;----------------------------------
;
MINT:   DEC    (IY+6)          ;length0
        RET    NZ
        DEC    (IY+7)          ;tempo0
        LD     A,(IY+8)        ;length1
        LD     (IY+6),A        ;length counter preset
        RET    NZ
        LD     A,(IY+9)        ;tempo1
        LD     (IY+7),A        ;tempo counter preset
        LD     E,(IY+10)       ;que addr(l)
        LD     D,(IY+11)       ;que addr(h)
;
;
MINT1:  LD     A,(DE)
        INC    DE
        CP     0FFH
        JR     Z,MINT2
        CP     0A0H
        JR     Z,MINT3
        CP     90H
        JR     NC,MINT4
        CP     80H
        JR     NC,MINT5
        CP     60H
        JR     NC,MINT6
        SUB    9
        LD     (IY+10),E       ;que addr (l)
        LD     (IY+11),D       ;que addr (h)
        SET    0,(IY+13)       ;rflag set
        JR     C,MINT7
        RES    0,(IY+13)       ;rflag reset
        CALL   SETNO           ;Nn
MINT7:  LD     A,(IY+2)        ;att
        LD     (IY+1),A
        LD     A,(IY+8)        ;length
        LD     (IY+6),A
        LD     A,(IY+9)        ;tempo
        LD     (IY+7),A
        BIT    0,(IY+13)
        JR     NZ,MEND
;
;
        LD     A,(IY+12)       ;emv pattern
        LD     BC,ETBL
        ADD    A,A             ;*2
        ADD    A,A             ;*4
        LD     H,0
        LD     L,A
        ADD    HL,BC           ;HL=ETBL+4*A
        LD     A,(HL)
        OR     A
        JR     NZ,MINT71
        LD     A,(IY+14)       ;vol minimum
MINT71: LD     (IY+5),A        ;att
        CALL   ATTSET
        INC    HL
        LD     (IY+3),L        ;emva (l)
        LD     (IY+4),H        ;emva (h)
        RET
;
;
;
MINT3:  LD     A,(DE)          ;Mn
        INC    DE
        LD     (IY+2),A        ;atc1
MINT11: JR     MINT1
;
MINT2:  CALL   BRESET          ;channel reset
MEND:   LD     A,0FH
        JP     ATTSET
;
;
MINT4:  SUB    90H             ;Sn
        LD     (IY+12),A       ;curent emv no.
        JR     MINT11
;
;
MINT5:  SUB    80H             ;Vn
        CPL
        AND    0FH
        LD     (IY+14),A       ;vol minimum
        JR     MINT11
;
;
;  tempo  &  length
;
;
MINT6:  SUB    60H             ;Tn,Ln
        LD     B,0
        LD     C,A
        LD     HL,LTBL
        ADD    HL,BC
        CP     0AH
        LD     A,(HL)
        JR     NC,MINT61
        LD     (IY+8),A        ;length1
        JR     MINT11
MINT61: LD     (IY+9),A        ;tempo1
        JR     MINT11


;--------------------------------
;
;
;    onpu  set
;
;     acc  = onpu map data
;     ix   = set mout tbladdr
;--------------------------------
;
SETNO:  ADD    A,A             ;*2
        LD     HL,NTBL
        LD     B,0
        LD     C,A
        ADD    HL,BC
        LD     B,(HL)
        LD     A,(IX+0)
        AND    0F0H
        OR     B
        LD     (IX+0),A
        INC    HL
        LD     A,(HL)
        LD     (IX+1),A
        RET
;----------------------------------
;
;  SOUND=(reg,data)
;
;    ent A.... reg+80H
;        DE... data
;
;
;  SOUND n,time
;
;    ent A.... n
;        DE... time
;
;----------------------------------
;
MSOUND:
        OR     A
        JP     P,SOUT
        AND    0FH
        LD     C,PSGA          ;psg-a
;
        IF     SYS
;
        CP     8
        JR     C,$+5
        SUB    8
        INC    C               ;C=psg sel, A=reg#.
;
        ENDIF
;
        ADD    A,A
        ADD    A,A
        ADD    A,A
        ADD    A,A
        OR     80H
        LD     B,A             ;B = 1rrr0000
;
        BIT    4,A
        JR     NZ,MSND_A       ;att
        CP     0E0H
        JR     Z,MSND_N        ;noise ctrl
        LD     A,D             ;freq
        CP     04H
        JR     NC,MER3
        LD     A,E
        AND    0FH
        OR     B               ;1rrrffff
        OUT    (C),A
        LD     A,D
        LD     B,4
        RL     E
        RLA
        DJNZ   $-3
        OUT    (C),A           ;0fffffff
        RET
;
MSND_N: BIT    3,E
        JR     NZ,MER3
MSND_A: LD     A,E
        AND    0F0H
        OR     D
        JR     NZ,MER3
        LD     A,E
        OR     B
        OUT    (C),A           ;1rrrcccc
        RET
;
MER3:   JP     ER03
;
;--------------------------------
;
;    sout
;
;--------------------------------
;
SDINT:  LD     HL,(TSOUTC)
        DEC    HL
        LD     (TSOUTC),HL
        LD     A,L
        OR     H
        RET    NZ
        JP     MSTOP0
;
;
; SOUND n,l
;
;
SOUT:
        LD     C,A
        LD     A,D
        OR     E
        RET    Z
        LD     A,C
;
        LD     IX,TSOUT
        CP     NMAX+1
        RET    NC
        SUB    9
        PUSH   AF
        LD     A,90H
        JR     NC,SOUT1
        LD     A,9FH
SOUT1:  LD     (IX+2),A        ;TSOUT att
        CALL   MWAIT0
        POP    AF
        CALL   NC,SETNO        ;skip if not rest
        DI
        LD     A,2
        LD     (INTM),A
        LD     (TSOUTC),DE
        LD     HL,TSOUT
        LD     BC,PSG3         ;psg-a out
        OTIR
        CALL   MSTART
        EI
        RET
;
;--------------------------------
;
;     Interpret  point set
;
;
;   in Acc=channel
;
;   exit ix:stbl
;        iy:ptbl
;        hl:ptbl+1
;
;----------------------------------
INTER:  PUSH   BC
        PUSH   AF
        CP     3
        JR     C,INTER1
        DEC    A
;
        IF     SYS
        CP     6
        JR     NZ,INTER1
        DEC    A
        ENDIF
;
INTER1: LD     HL,STBL
        LD     B,A
        ADD    A,A             ;*2
        ADD    A,B             ;*3
        LD     C,A
        LD     B,0
        ADD    HL,BC
        PUSH   HL
        POP    IX
;
        POP    AF
        ADD    A,A             ;*2
        ADD    A,A             ;*4
        ADD    A,A             ;*8
        ADD    A,A             ;*16
        LD     HL,PTBL
        LD     B,0
        LD     C,A
        ADD    HL,BC
        PUSH   HL
        POP    IY
        INC    HL
        POP    BC
        RET


;--------------------------------
;
;     play,noise
;
;--------------------------------
;
;
PLAY:
        CP     0FFH
        JR     NZ,PLY0
        LD     A,MAXCH-1
PLYALL: PUSH   AF
        PUSH   DE
        CALL   PLY0
        POP    DE
        POP    AF
        DEC    A
        JP     M,PSGON
        JR     PLYALL
;
PLY0:   PUSH   AF
        LD     HL,STN0
        IF     SYS
        CP     4
        JR     C,PLY00
        LD     HL,STN1
        ENDIF
;
PLY00:  CP     3
        JR     Z,PLY1
;
        IF     SYS
        CP     7
        JR     Z,PLY1
        ENDIF
;
        LD     A,0DFH
        JR     PLY2
;
PLY1:   LD     A,0E7H           ;noise channel out
        OUT    (PSGALL),A
        LD     A,0FFH
PLY2:   LD     (HL),A          ;STN0 or STN1
        DI
        LD     A,1
        LD     (INTM),A
        POP    AF
        CALL   INTER
        CALL   BSET
        CALL   MINT1
        EI
        RET
;
;
PSGON:
        DI
        LD     A,(INTM)
        OR     A
        CALL   NZ,MSTART
        EI
        RET
;
BRESET: LD     B,86H
        JR     BSET0
;
BSET:   LD     B,0C6H
BSET0:  LD     HL,SBUSY
        LD     A,(IY+0)
        OR     A
        RLCA
        RLCA
        RLCA                   ;00xxx000
        OR     B               ;10xxx110 or 11xxx110
        LD     (BSET1),A
        DEFB   0CBH             ;SET n,(HL) or reset
BSET1:  DEFB   0
        RET


;----------------------------------
;
; sft+break or error or music stop
;
;----------------------------------
;
MLDSP:
MSTOP:
        CALL   PUSHR
;
MSTOP0: XOR    A
        LD     (INTM),A
        LD     (SBUSY),A
;
        LD     BC,PSGOFF
        LD     HL,MSTBL
        OTIR
        LD     B,MUSCH
        LD     HL,STBL+2
MSTOP1: LD     A,(HL)
        AND    0F0H
        OR     0FH
        LD     (HL),A
        INC    HL
        INC    HL
        INC    HL
        DJNZ   MSTOP1
        LD     A,3
        OUT    (0FCH),A         ;pio disenable
        XOR    A

        IF     SYS
        LD     HL,0E008H        ;mz-700 compatible mode
        JP     LDHLA           ;8253 gate disable
        ELSE
        RET                    ;8253 gate no effect
        ENDIF
;
;
;----------------------------------
;
; music wait
;
;----------------------------------
;
MWAIT:
;
MWAIT0: LD     A,(INTM)
        OR     A
        RET    Z
MWAIT1:
        RST    3
        DEFB   _BREAK
        JR     NZ,MWAIT
        JP     BREAKZ


;----------------------------------
;  SVC .MCTRL ; music control
;    B=0: init
;    B=1: psgon
;    B=2: stop
;    B=3: wait
;----------------------------------
;
MCTRL:
        DEC    B
        JP     Z,PSGON
        DEC    B
        JR     Z,MSTOP         ;1
        DEC    B
        JR     Z,MWAIT0        ;2
;----------------------------------
;
; PSG power on init
;
;
;----------------------------------
PSGPWR:
        CALL   MSTOP
        LD     BC,5FCH
        LD     HL,PIOTBL
        OTIR
        LD     DE,MUINID
        LD     A,0FFH
        JP     PLAY
;
;
        IF     SYS
PIOTBL: DEFB   0FCH             ;Vector
        DEFB   0FFH             ;mode 3 (bit mode)
        DEFB   3FH              ;I/O
        DEFB   37H              ;interrupt control
        DEFB   0EFH             ;interrupt mask
;
;
MSTART: OUT    (0E3H),A
        LD     A,30H
        LD     HL,0E007H
        LD     (HL),A          ;8253 control
        LD     BC,22A5H        ;10ms =22F6H
        LD     L,4             ;HL=E004H
        LD     (HL),C          ;8253 time const
        LD     (HL),B
        DEC    HL              ;HL=E003H
        LD     (HL),4          ;8253 int disable
        LD     (HL),0          ;8253 music disable
        LD     A,01H
        LD     L,8             ;HL=E008H
        LD     (HL),A          ;8253 gate enable
        LD     A,83H
        OUT    (0FCH),A         ;pio int enable
        OUT    (0E1H),A
        RET

        ELSE

MSTART:
        LD     HL,PIOTBL
        LD     BC,5FCH
        OTIR
        LD     HL,CTCTBL
        LD     B,6
        JP     IOOUT
;
;
PIOTBL: DEFB   0FCH             ;Vector
        DEFB   0FFH             ;mode 3 (bit mode)
        DEFB   3FH              ;I/O
        DEFB   17H              ;interrupt control
        DEFB   0EFH             ;interrupt mask
;
CTCTBL: DEFW   0D730H
        DEFW   0D4B0H           ;10 ms =2B4CH
        DEFW   0D42AH
        DEFW   0D304H
        DEFW   0D300H
        DEFW   0FC83H
        ENDIF
;
MUINID: DEFB   65H             ;L5
        DEFB   6DH             ;T4
        DEFB   98H             ;S8
        DEFW   0FFA0H           ;M255
        DEFB   0FFH             ;END
        IF     SYS
;----------------------------------
;
;
; BELL (BEEP)  use 8253
;----------------------------------
CTRLG:
        CALL   PUSHR
        LD     (CTRLG9+1),SP
        RST    3
        DEFB   _DI
        LD     SP,IBUFE
        OUT    (0E4H),A         ;K/C mapping
        CALL   02BEH           ;ROM MLDSP
        LD     A,1
        LD     DE,E003H
        LD     (DE),A          ;8253 music gate on
        LD     HL,03F9H
        CALL   02AEH           ;ROM MLDST+3
        LD     BC,18H
        EX     (SP),HL         ;wait
        DJNZ   $-1
        DEC    C
        JR     NZ,$-4
        CALL   02BEH           ;ROM MLDSP
        XOR    A
        LD     (DE),A          ;8253 music gate off
        OUT    (0E0H),A         ;K/C mapping
        OUT    (0E1H),A
        RST    3
        DEFB   _EI
CTRLG9: LD     SP,0            ;xxx
        RET

;
        ELSE
;

CTRLG:
        CALL   PUSHR
        RST    3
        DEFB   _DI
        LD     HL,BEEP0
        LD     B,4
        CALL   IOOUT
        LD     BC,18H
        EX     (SP),HL
        DJNZ   $-1
        DEC    C
        JR     NZ,$-4
        LD     HL,BEEP1
        LD     B,2
        CALL   IOOUT
        RST    3
        DEFB   _EI
        RET
;
;
BEEP0:
        DEFW   0D736H
        DEFW   0D301H
        DEFW   0D4F9H
        DEFW   0D403H
;
BEEP1:
        DEFW   0D736H
        DEFW   0D300H

;--------------------------------
;
;        tempo set
;                  acc=1-7
;--------------------------------
_TEMP:
        CALL   PUSHRA
        LD     DE,TEMPOW
        AND    0FH
        ADD    A,69H
        LD     (DE),A
        LD     B,3
        RST    3
        DEFB   _MCTRL          ;MWAIT
        LD     A,0FFH           ;Channel all
        RST    3
        DEFB   _PLAY
        LD     B,1
        RST    3
        DEFB   _MCTRL          ;PSGON
        RET
;
TEMPOW: DEFS   1
        DEFB   0FFH
;
        ENDIF

;       END (453A)




;        ORG    453AH


; -------------------------------
; MZ-800 Monitor  Graphic-package
; FI:MON-GRPH  ver 1.0A 9.05.84
;
; -------------------------------
;
;

defc KEYBF  =    11A4H           ;KEYBUF label
;-------------------------------
;
; INIT "CRT:
;
;-------------------------------
CRTINI:
        CALL   TEST1
        DEFB   'M'         ; mandatory prefix, it stands for "MODE"
        JR     Z,CRMD
        OR     A
        JR     Z,ICRT
        CP     'B'
        JP     NZ,ER03
;-------------------------------
;
; CRT palette block
;
;-------------------------------
;
PBLOCK: XOR    A
        LD     (PALBK),A
        LD     A,(CRTMD2)
        CP     2
        JP     NZ,ER68
        INC    HL
        LD     B,4
        CALL   DEVASC
        LD     (PALBK),A
        RST    3
        DEFB   _DPLBK
        JR     CRTLP
;
;---------------------------------
;
; CRT mode
;
; 1.....320x200 4 Color
; 2.....320x200 16 Color
; 3.....640x200 2 Color
; 4.....640x200 4 Color
;
;---------------------------------
;
CRMD:   LD     B,5
        CALL   DEVASC
        OR     A
        JR     Z,ER3JP
        LD     B,A
        RST    3
        DEFB   _DSMOD
        JP     C,ER68
        LD     A,B
        LD     (CRTMD2),A
        XOR    A
        LD     (INPFLG),A
        SCF
        ADC    A,A
        DJNZ   $-1
        LD     (CRTMD1),A
        CALL   ICRT2
;
CRTLP:
        CALL   TEST1
        DEFB   0
        RET    Z
        CP     ','
        INC    HL
        JR     Z,CRTINI
ER3JP:  JP     ER03
;
ICRT:
        LD     A,(CRTMD2)
        RST    3
        DEFB   _DSMOD
ICRT2:  CALL   COLINI
        XOR    A
        LD     (PALBK),A
        RST    3
        DEFB   _DPLBK
        RET
;
COLINI: LD     A,(CRTMD1)
        LD     B,3
        RRA
        JR     C,CI1
        LD     B,15
        RRA
        JR     C,CI1
        LD     B,1
        RRA
        JR     C,CI1
        LD     B,3
CI1:    LD     A,B
        LD     (SELCOL),A
        RST    3
        DEFB   _DCOL
        RET


;------------------------
;
;
; BYTE CONVERT TABLE
;
;-----------------------
TDOTL:
        DEFB   0FFH
        DEFB   0FEH
        DEFB   0FCH
        DEFB   0F8H
        DEFB   0F0H
        DEFB   0E0H
        DEFB   0C0H
        DEFB   80H
;
TDOTR:
        DEFB   01H
        DEFB   03H
        DEFB   07H
        DEFB   0FH
        DEFB   1FH
        DEFB   3FH
        DEFB   7FH
        DEFB   0FFH
;
TDOTN:
        DEFB   01H
        DEFB   02H
        DEFB   04H
        DEFB   08H
        DEFB   10H
        DEFB   20H
        DEFB   40H
        DEFB   80H
;-------------------------------
;
;   //  64 - 32  TRANS   //
;
;-------------------------------
;
CHGRPH:
        LD     BC,703H
        LD     HL,CHGTBL
        JP     PATCH
;
;
CHGTBL:
;    word patch table
;
        DEFW   SYMS42+1
        DEFW   0BE80H
        DEFW   9F40H
;
        DEFW   RNGCK0+1
        DEFW   -640
        DEFW   -320
;
        DEFW   LRBSR
        DEFW   640
        DEFW   320
;
        DEFW   BFL0+1
        DEFW   80
        DEFW   40
;
        DEFW   BFL1+1
        DEFW   80
        DEFW   40
;
        DEFW   BFC0+1
        DEFW   -640
        DEFW   -320
;
        DEFW   BFC1+1
        DEFW   639
        DEFW   319
;
;    byte patch table
;
        DEFW   ADCH            ;adrs
        DEFB   29H             ;640 ADD HL,HL
        DEFB   00H             ;320
;
        DEFW   SYMS21+1
        DEFB   80
        DEFB   40
;
        DEFW   SYMS41+1
        DEFB   80
        DEFB   40
;


;----------------------------------
;
;     address  calc
;
;
;       ent.   de=x (0-13FH,27FH)
;              hl=y (0-C7H)
;
;       ext.   hl=vram addr
;               a=vram bit
;               c=de/8
;----------------------------------
ADCH:   ADD    HL,HL           ;NOP
        LD     A,E
        AND    7
        LD     B,A
;
        LD     A,E
        AND    0F8H
        ADD    A,D
        RRCA
        RRCA
        RRCA
        LD     C,A
        LD     A,B
        LD     B,80H           ;vramh
        LD     D,H
        LD     E,L
        ADD    HL,HL
        ADD    HL,HL
        ADD    HL,DE
        ADD    HL,HL
        ADD    HL,HL
        ADD    HL,HL           ;HL=HL*40
        ADD    HL,BC
        RET
;-----------------------------
;
;   READ  POINT
;
;    Ent:DE=X (0-13FH,27EH)
;        HL=Y (0-C7H)
;
;-----------------------------
WPOINT:
        CALL   RNGCK
        JP     C,OVER
        CALL   ADCH
;
        RLCA
        RLCA
        RLCA
        OR     46H
        LD     (PNT2+1),A
        LD     C,LSRF
        LD     A,(MAXCF)
        LD     B,A
;
        DI
        IN     A,(LSE0)
        XOR    A
PNT1:   RR     B
        JR     C,PNT4
        OUT    (C),B
        OR     A
PNT2:   BIT    0,(HL)          ;bit n,(hl)
        JR     Z,PNT3
        SCF
PNT3:   RLA
        JR     PNT1
;
PNT4:   LD     B,A
        IN     A,(LSE1)
        EI
        LD     A,(CPLANE)
        AND    B
        LD     B,A
        LD     A,(DMD)
        CP     6
        LD     A,B
        RET    NZ
;
        CP     4
        RET    C
;
        SUB    2
        RET


;---------------------------------
;
;
;     MODE SET (PWMODE,GMODE)
;
;       ent.   A= 0  RESET
;              A<>0  SET
;---------------------------------
SETW:   LD     A,0FFH
MODSET: PUSH   BC
        OR     A
        LD     A,(GMODE)
        LD     C,A
        LD     A,(PWMODE)
        JR     Z,_RESET
;
_SET:    OR     A
        LD     A,0C0H           ;w0 pset
        JR     Z,SET1
        LD     A,40H           ;w1 or
;
SET1:   OR     C
        OUT    (LSWF),A        ;Write mode set
        POP    BC
        RET
;
;
_RESET: OR     A
        LD     A,60H           ;w1 reset
        JR     NZ,SET1
;
        LD     A,(CPLANE)
        LD     B,A
        LD     A,C             ;reverse  color
        CPL
        AND    B               ;mask color
        OR     0C0H             ;w0 pset mode
        OUT    (LSWF),A        ;Write mode set
        POP    BC
        RET


;-----------------------------
;
; Point Write/Erase
;
;    Ent:DE=X (0-13FH,27EH)
;       HL=Y (0-C7H)
;
;-----------------------------
PSET:
        CALL   MODSET
PSET0:  CALL   RNGCK
        JP     C,OVER
        CALL   ADCH
        EX     DE,HL
        LD     HL,TDOTN
        LD     B,0
        LD     C,A
        ADD    HL,BC
        DI
        IN     A,(LSE0)
        LDI
        IN     A,(LSE1)
        EI
        XOR    A
        RET
;
;
;--------------------------------
;
; RANGE  CHECK
;
;    Ent:DE=X (0-13FH,27EH)
;        HL=Y (0-C7H)
;
;    ext:if over then  CF=1
;
;--------------------------------
RNGCK:
        PUSH   BC
        PUSH   DE
        PUSH   HL
        LD     A,H
        RLCA
        JR     C,RNGER
;
        LD     BC,-200
        ADD    HL,BC
        JR     C,RNGER
;
        LD     A,D
        RLCA
        JR     C,RNGER
;
        EX     DE,HL
RNGCK0: LD     BC,-640         ;-320
        ADD    HL,BC
RNGER:  POP    HL
        POP    DE
        POP    BC
        RET
;
;


;------------------------------
;
; Draw  line
;
;    ent  DE':X0, DE:X
;         HL':Y0, HL:Y
;         A  := 0 BLINE
;             <>0  LINE
;
;    ext  DE':X
;         HL':Y
;-------------------------------
;
;
defc X0      =    KEYBF           ;2
defc DX      =    X0+2            ;2
defc XDIRE   =    DX+2            ;1
defc Y0      =    XDIRE+1         ;2
defc DY      =    Y0+2            ;2
defc YDIRE   =    DY+2            ;1
;
;
WLINE0: LD     A,0FFH
WLINE:
        CALL   MODSET
        PUSH   DE
        PUSH   HL
        EXX
        LD     (X0),DE
        LD     (Y0),HL
        EXX
        PUSH   HL              ;y
        PUSH   DE              ;x
        EX     DE,HL
        LD     HL,(Y0)
        CALL   PLS
        LD     (YDIRE),A
        LD     (DY),HL
        POP    DE              ;x
        JP     NC,WYLIN        ;skip if y=y0
        PUSH   HL              ;dy
        LD     HL,(X0)
        CALL   PLS
        LD     (XDIRE),A
        LD     (DX),HL
        POP    BC              ;dy
        POP    DE              ;y
        JP     NC,WTLIN        ;skip if x=x0
        XOR    A
        SBC    HL,BC
        JR     NC,WLIN04       ;skip if dx>dy
        LD     HL,X0           ;parameter change
        LD     DE,Y0
        LD     B,5
WLIN02: LD     A,(DE)
        LD     C,(HL)
        LD     (HL),A
        LD     A,C
        LD     (DE),A
        INC    HL
        INC    DE
        DJNZ   WLIN02
;
        LD     A,0EBH          ;ex de,hl
WLIN04: LD     (PLOT0),A
        LD     (PLOT1),A
        LD     A,(YDIRE)
        AND    A
        LD     A,23H           ;inc hl
        JR     Z,DIRE1
        LD     A,2BH           ;dec hl
DIRE1:  LD     (PP2),A
;
        LD     A,(XDIRE)
        AND    A
        LD     A,13H           ;inc de
        JR     Z,DIRE2
        LD     A,1BH           ;dec de
DIRE2:  LD     (PP1),A
;
        EXX
        LD     HL,(DX)         ;initial parm set
        LD     D,H
        LD     E,L
        SRL    H
        RR     L
        LD     BC,(DY)
        EXX
;
        LD     HL,(Y0)         ;first point  set
        LD     DE,(X0)
        LD     BC,(DX)
;
PLOT0:  EX     DE,HL           ;nop
        PUSH   HL
        PUSH   DE
        PUSH   BC
        CALL   PSET0
        POP    BC
        POP    DE
        POP    HL
PLOT1:  EX     DE,HL           ;nop
;
;
        DEC    BC
        LD     A,B
        INC    A
        JR     Z,FINW          ;skip if end of line
;
; pointer calc .
;
PP1:    DEFS   1               ;inc de/dec de
        EXX
        OR     A
        SBC    HL,BC
        EXX
        JP     NC,PLOT0
        EXX
        ADD    HL,DE
        EXX
PP2:    DEFS   1               ;inc hl/dec hl
        JP     PLOT0
;
;
FINW:   EXX
        POP    HL
        POP    DE
        EXX
        RET
;
WYLIN:  POP    HL              ;Y
WYLIN0: CALL   WBOXSB
        CALL   WBOXSB
        CALL   YLINE
        JR     FINW
;
WTLIN:  EX     DE,HL
        LD     DE,(X0)
        JR     WYLIN0
;
;
;
PLS:    LD     A,H
        ADD    A,40H
        LD     H,A
        LD     A,D
        ADD    A,40H
        LD     D,A
;
        OR     A
        SBC    HL,DE
        JR     C,PLS1
        LD     A,H
        OR     L
        RET    Z
OVER:   LD     A,0FFH
        SCF
        RET
;
PLS1:   OR     A
        EX     DE,HL
        LD     HL,0
        SBC    HL,DE
        XOR    A
        SCF
        RET


;-------------------------
;
;
;  Write sector
;
;-------------------------
;
WSECTR: CALL   WSPUT
        LD     HL,(POINTX)
        PUSH   HL
        PUSH   BC              ;POINTY
        EXX
        CALL   WSPUT
        LD     B,2
        JP     WBOX2
;
WSPUT:  POP    IX              ;Ret adrs
        EX     DE,HL
        CP     2
        CALL   Z,WSCTRH
        LD     BC,(POINTX)
        ADD    HL,BC
        PUSH   HL              ;X
        EX     DE,HL
        CP     1
        CALL   Z,WSCTRH
        LD     BC,(POINTY)
        ADD    HL,BC
        PUSH   HL              ;Y
        JP     (IX)
;
WSCTRH: BIT    7,H
        JP     Z,HIRITU
        CALL   WSCTRV
        CALL   HIRITU
WSCTRV:
        EX     AF,AF
        CALL   NEGHL
        EX     AF,AF
        RET


;
;-----------------------------
;
; Circle Write
;  ent DE:End X    DE':Start X
;      HL:End Y    HL':Start Y
;      IX:R        BC':Hiritu
;      A:Angle flag
;      if CF then sector
;
;  uses KEYBUF
;-----------------------------
WCIRCL:
        PUSH   AF
        CALL   SETW            ;set pwmode
        POP    AF
        PUSH   AF
        LD     (CIR3+1),IX     ;R
        LD     (SYUX),DE
        LD     (SYUY),HL
        EXX
        LD     (CIR_HF),BC
        LD     (KAIX),DE
        LD     (KAIY),HL
        LD     A,C             ;CIR_HF
        CALL   C,WSECTR
        LD     HL,(KAIX)
        LD     DE,(KAIY)
;Å BLOCK NO."Ù\Ü/BL \ÄÙ
        CALL   BLCKRU
        LD     (KBL),A
        LD     HL,(SYUX)
        LD     DE,(SYUY)
;Å BLOCK NO."Ù\Ü/SBL \mÄÙ
        CALL   BLCKRU
        LD     (SBL),A
;
        LD     HL,CIR_BK
        LD     B,8
        CALL   CLRHL
        LD     HL,KBL
        POP    AF
        LD     B,A
        AND    0FH
        JR     Z,CIR4          ;KK=SK
        CP     3
        JR     Z,CIR15         ;2PI <= ABS(KK-SK)
        LD     A,(HL)
        INC    HL
        CP     (HL)
        JR     NZ,CIR4
        LD     A,B
        CP     81H
        JR     Z,CIR4
        JR     CIR14
;
CIR15:  LD     A,9
        LD     (HL),A
        INC    HL
        LD     (HL),A
CIR14:  LD     B,8
        LD     HL,CIR_BK
        INC    A
        CALL   SETHL
        LD     A,0B0H           ;OR B
        CALL   CHENGE
        JR     CIR3
;
CIR4:   LD     A,0A0H           ;AND B
        CALL   CHENGE
        LD     D,00H
        LD     HL,(KBL)
        LD     B,H
        LD     A,L
CIR2:   LD     HL,CIR_BK-1
        LD     E,A
        ADD    HL,DE
        LD     (HL),1
        CP     B               ;\s\ÛÛÚjlÄ \mÛÛÚjli Ã\l
        JR     Z,CIR3
        AND    7
        INC    A
        JR     CIR2
CIR3:   LD     HL,0            ;;;R
        LD     (DYY),HL
        LD     (XX),HL
        LD     HL,1
        LD     (CI_D),HL
        LD     (YY),HL
CIR7:   LD     HL,(DYY)
        LD     DE,(CI_D)
        XOR    A
        SBC    HL,DE
        LD     (DYY),HL
;
        LD     HL,(YY)
        DEC    HL
        LD     (CYE),HL
        LD     A,(CIR_HF)
        OR     A
        LD     DE,HL
        CALL   NZ,HIRITU
        CP     1
        JR     Z,$+3
        EX     DE,HL
        LD     (YYY),DE
        LD     (YYHI),HL
;
        LD     HL,(XX)
        OR     A
        LD     DE,HL
        CALL   NZ,HIRITU
        CP     1
        JR     Z,$+3
        EX     DE,HL
        LD     (XXX),DE
        LD     (XXHI),HL
;
        LD     HL,(XXX)
        CALL   NEGHL
        LD     (FUXX),HL       ;FUXX = -XXX
        LD     HL,(YYY)
        CALL   NEGHL
        LD     (FUYE),HL       ;FUYE = -YYY
        LD     HL,(YYHI)
        CALL   NEGHL
        LD     (FUYYHI),HL     ;FUYYHI = -YYHI
        LD     HL,(XXHI)
        CALL   NEGHL
        LD     (FUXXHI),HL     ;FUXXHI = -XXHI
        LD     HL,(CYE)
        CALL   NEGHL
        LD     (FUNOYE),HL     ;FUNOYE = -YE
;
        LD     HL,CIR_BK
        LD     A,(HL)             ;BLOCK NO.1
        OR     A
        INC    HL
        JR     Z,P222
        EXX
        LD     HL,(XXX)
        LD     (PL1+1),HL
        LD     B,0
        LD     DE,(FUNOYE)
        BIT    7,D
        JR     Z,P12
        LD     A,(KBL)
        CP     1
        JR     NZ,P11
        LD     HL,(KAIY)
        XOR    A
        SBC    HL,DE
        JR     Z,P11
        JR     C,P12
P11:    INC    B
P12:    LD     A,(SBL)
        CP     1
        JR     NZ,P13
        LD     HL,(SYUY)
        XOR    A
        SBC    HL,DE
        JR     Z,P13
        JR     NC,P14
P13:    LD     A,1
P14:    AND    B
        JR     Z,P15
        LD     HL,(FUYYHI)
        CALL   PLALL
P15:    EXX
;
P222:   LD     A,(HL)             ;BLOCK NO.2
        OR     A
        INC    HL
        JR     Z,P3
        EXX
        LD     B,0
        LD     HL,(YYY)
        LD     (PL1+1),HL
        LD     DE,(CYE)
        LD     A,(KBL)
        CP     2
        JR     NZ,P21
        LD     HL,(KAIX)
        XOR    A
        SBC    HL,DE
        JR     Z,P21
        JR     C,P22
P21:    INC    B
P22:    LD     A,(SBL)
        CP     2
        JR     NZ,P23
        LD     HL,(SYUX)
        XOR    A
        SBC    HL,DE
        JR     Z,P23
        JR     NC,P24
P23:    LD     A,1
P24:    AND    B
        JR     Z,P25
        LD     HL,(FUXXHI)
        CALL   PLALL
P25:    EXX
;
P3:     LD     A,(HL)             ;BLOCK NO.3
        OR     A
        INC    HL
        JR     Z,P4
        EXX
        LD     B,0
        LD     HL,(FUYE)
        LD     (PL1+1),HL
        LD     DE,(FUNOYE)
        BIT    7,D
        JR     Z,P32
        LD     A,(KBL)
        CP     3
        JR     NZ,P31
        LD     HL,(KAIX)
        XOR    A
        SBC    HL,DE
        JR     Z,P31
        JR     C,P32
P31:    INC    B
P32:    LD     A,(SBL)
        CP     3
        JR     NZ,P33
        LD     HL,(SYUX)
        XOR    A
        SBC    HL,DE
        JR     Z,P33
        JR     NC,P34
P33:    LD     A,1
P34:    AND    B
        JR     Z,P35
        LD     HL,(FUXXHI)
        CALL   PLALL
P35:    EXX
;
P4:     LD     A,(HL)             ;BLOCK NO.4
        OR     A
        INC    HL
        JR     Z,P5
        EXX
        LD     B,0
        LD     HL,(FUXX)
        LD     (PL1+1),HL
        LD     DE,(FUNOYE)
        LD     A,(KBL)
        CP     4
        JR     NZ,P41
        LD     HL,(KAIY)
        XOR    A
        SBC    HL,DE
        JR     Z,P41
        JR     NC,P42
P41:    INC    B
P42:    XOR    A
        BIT    7,D
        JR     Z,P44
        LD     A,(SBL)
        CP     4
        JR     NZ,P43
        LD     HL,(SYUY)
        XOR    A
        SBC    HL,DE
        JR     Z,P43
        JR     C,P44
P43:    LD     A,1
P44:    AND    B
        JR     Z,P45
        LD     HL,(FUYYHI)
        CALL   PLALL
P45:    EXX
;
P5:     LD     A,(HL)             ;BLOCK NO.5
        OR     A
        INC    HL
        JR     Z,P6
        EXX
        LD     B,0
        LD     HL,(FUXX)
        LD     (PL1+1),HL
        LD     DE,(CYE)
        LD     A,(KBL)
        CP     5
        JR     NZ,P51
        LD     HL,(KAIY)
        XOR    A
        SBC    HL,DE
        JR     Z,P51
        JR     NC,P52
P51:    INC    B
P52:    LD     A,(SBL)
        CP     5
        JR     NZ,P53
        LD     HL,(SYUY)
        XOR    A
        SBC    HL,DE
        JR     Z,P53
        JR     C,P54
P53:    LD     A,1
P54:    AND    B
        JR     Z,P55
        LD     HL,(YYHI)
        CALL   PLALL
P55:    EXX
;
P6:     LD     A,(HL)             ;BLOCK NO.6
        OR     A
        INC    HL
        JR     Z,P7
        EXX
        LD     B,0
        LD     HL,(FUYE)
        LD     (PL1+1),HL
        LD     DE,(FUNOYE)
        LD     A,(KBL)
        CP     6
        JR     NZ,P61
        LD     HL,(KAIX)
        XOR    A
        SBC    HL,DE
        JR     Z,P61
        JR     NC,P62
P61:    INC    B
P62:    XOR    A
        BIT    7,D
        JR     Z,P64
        LD     A,(SBL)
        CP     6
        JR     NZ,P63
        LD     HL,(SYUX)
        XOR    A
        SBC    HL,DE
        JR     Z,P63
        JR     C,P64
P63:    LD     A,1
P64:    AND    B
        JR     Z,P65
        LD     HL,(XXHI)
        CALL   PLALL
P65:    EXX
;
P7:     LD     A,(HL)             ;BLOCK NO.7
        OR     A
        INC    HL
        JR     Z,P8
        EXX
        LD     HL,(YYY)
        LD     (PL1+1),HL
        LD     DE,(CYE)
        LD     B,0
        LD     A,(KBL)
        CP     7
        JR     NZ,P71
        LD     HL,(KAIX)
        XOR    A
        SBC    HL,DE
        JR     Z,P71
        JR     NC,P72
P71:    INC    B
P72:    LD     A,(SBL)
        CP     7
        JR     NZ,P73
        LD     HL,(SYUX)
        XOR    A
        SBC    HL,DE
        JR     Z,P73
        JR     C,P74
P73:    LD     A,1
P74:    AND    B
        JR     Z,P75
        LD     HL,(XXHI)
        CALL   PLALL
P75:    EXX
;
P8:     LD     A,(HL)             ;BLOCK NO.8
        OR     A
        INC    HL
        JR     Z,_PE
        EXX
        LD     HL,(XXX)
        LD     (PL1+1),HL
        LD     DE,(CYE)
        LD     B,0
        LD     A,(KBL)
        CP     8
        JR     NZ,P81
        LD     HL,(KAIY)
        XOR    A
        SBC    HL,DE
        JR     Z,P81
        JR     C,P82
P81:    INC    B
P82:    LD     A,(SBL)
        CP     8
        JR     NZ,P83
        LD     HL,(SYUY)
        XOR    A
        SBC    HL,DE
        JR     Z,P83
        JR     NC,P84
P83:    LD     A,1
P84:    AND    B
        JR     Z,P85
        LD     HL,(YYHI)
        CALL   PLALL
P85:    EXX
;
_PE:     LD     HL,(DYY)        ;Zs"Ù\o
        BIT    7,H
        JR     Z,CIR10
        LD     DE,(YY)
        LD     HL,(XX)
        DEC    HL
        LD     (XX),HL
        BIT    7,H
        RET    NZ
        XOR    A
        SBC    HL,DE
        RET    C
        LD     HL,(XX)
        ADD    HL,HL
        LD     DE,(DYY)
        ADD    HL,DE
        LD     (DYY),HL
CIR10:  LD     HL,(YY)
        INC    HL
        LD     (YY),HL
        LD     HL,(CI_D)
        INC    HL
        INC    HL
        LD     (CI_D),HL
        JP     CIR7
;
;CIRCLE "ÛÛÜ-ÞÙ
;
;BLOCK NUMBER ZÙ\Ü "ÛÛÜ-ÞÙ
BLCKRU: PUSH   HL
        PUSH   DE
        CALL   ABSHL
        EX     DE,HL
        CALL   ABSHL
        EX     DE,HL
        OR     A
        SBC    HL,DE
        POP    DE
        POP    HL
        JR     C,BLCK1
        BIT    7,H
        JR     NZ,BLCK2
        BIT    7,D
        LD     A,8
        RET    Z
        LD     A,1
        RET
BLCK2:  BIT    7,D
        LD     A,5
        RET    Z
        LD     A,4
        RET
BLCK1:  BIT    7,H
        JR     NZ,BLCK5
        BIT    7,D
        LD     A,7
        RET    Z
        LD     A,2
        RET
BLCK5:  BIT    7,D
        LD     A,6
        RET    Z
        LD     A,3
        RET
;
ABSHL:  BIT    7,H
        RET    Z
NEGHL:  LD     A,H
        CPL
        LD     H,A
        LD     A,L
        CPL
        LD     L,A
        INC    HL
        RET
;
;PLOT Ü-ÞÙ
PLALL:  LD     DE,(POINTY)
        ADD    HL,DE
        LD     DE,65336
        LD     B,H
        LD     C,L
        ADD    HL,DE
        RET    C
PL1:    LD     HL,0000H        ;LKD HL,XXXXH
        LD     DE,(POINTX)
        ADD    HL,DE
        EX     DE,HL
        LD     HL,64896
        ADD    HL,DE
        RET    C
        LD     H,B
        LD     L,C
        JP     PSET0
;
;
;ÃßÜ Zs"Ù Ü-ÞÙ
HIRITU:
        PUSH   AF
        PUSH   DE
        LD     B,8
        LD     C,L
        LD     E,H
        XOR    A
        LD     D,A
        LD     H,A
        LD     L,A
        EX     AF,AF
        LD     A,(CIR_HD)
HR1:    RRA
        JR     NC,HR2
        ADD    HL,DE
        EX     AF,AF
        ADD    A,C
        JR     NC,HR3
        INC    HL
HR3:    EX     AF,AF
HR2:    SLA    C
        RL     E
        RL     D
        DJNZ   HR1
        EX     AF,AF
        BIT    7,A
        JR     Z,$+3
        INC    HL
        POP    DE
        POP    AF
        RET
;
CHENGE: LD     (P14),A
        LD     (P24),A
        LD     (P34),A
        LD     (P44),A
        LD     (P54),A
        LD     (P64),A
        LD     (P74),A
        LD     (P84),A
        RET
;
; work area
;
defc CI_D   =    KEYBF           ;2
defc DYY    =    CI_D+2          ;2
defc XX     =    DYY+2           ;2
defc YY     =    XX+2            ;2
defc CYE    =    YY+2            ;2
defc KBL    =    CYE+2           ;1 \ÄÙÛ BLOCK NO.
defc SBL    =    KBL+1           ;1 \mÄÙÛ BLOCK NO.
;
;
defc FUYE   =    SBL+1           ;2
defc FUXX   =    FUYE+2          ;2
defc FUYYHI =    FUXX+2          ;2
defc FUXXHI =    FUYYHI+2        ;2
;
defc FUNOYE =   FUXXHI+2        ;2
;
defc CIR_BK =   FUNOYE+2        ;9 Block data
;
;
defc KAIX   =   CIR_BK+9        ;2 \ÄÙ X
defc KAIY   =   KAIX+2          ;2 \ÄÙ Y
defc SYUX   =   KAIY+2          ;2 \mÄÙ X
defc SYUY   =   SYUX+2          ;2 \mÄÙ Y
defc XXHI   =   SYUY+2          ;2 XXÛ ÃßÜ DATA
defc YYHI   =   XXHI+2          ;2 YEÛ ÃßÜ DATA
;
defc XXX    =   YYHI+2          ;2
defc YYY    =   XXX+2           ;2
;
defc CIR_HF =    YYY+2           ;1
defc CIR_HD =    CIR_HF+1        ;1
;


; ----------------------------
;
; Box Write
;    ext DE':xs, DE:xe
;        HL':ys, HL:ye
;
;        if CF then A:fill color
;
; ----------------------------
defc LSTA    =   KEYBF
defc RSTA    =   LSTA+2
defc SPBOX   =   RSTA+2
;
WBOX:
        LD     (SPBOX),SP
        EX     AF,AF
        CALL   WBOXSB
        CALL   WBOXSB
        EXX
        PUSH   DE              ;XS Upper
        PUSH   HL              ;YS
        PUSH   DE              ;XS Lower
        EXX
        PUSH   HL              ;YE
        PUSH   DE              ;XE Lower
        PUSH   HL              ;YE
        PUSH   DE              ;XE Upper
        EXX
        PUSH   HL              ;YS
        PUSH   DE              ;XS Upper Left
        PUSH   HL              ;YS
        EXX
        EX     AF,AF
        CALL   C,BOXF          ;Box fill
        LD     B,4
WBOX2:  EXX
        POP    HL
        POP    DE
        EXX
WBOX4:  POP    HL
        POP    DE
        PUSH   BC
        CALL   WLINE0          ;Box bound
        POP    BC
        DJNZ   WBOX4
        RET
;
WBOXSB: EX     DE,HL
        LD     A,H             ;Compare HL,HL'
        EXX
        EX     DE,HL
        CP     H
        EXX
        JR     Z,WBOXS2
        RET    P
        JR     WBOXS4
WBOXS2: LD     A,L
        EXX
        CP     L
        EXX
        RET    NC
WBOXS4: PUSH   HL
        EXX
        EX     (SP),HL
        EXX
        POP    HL
        RET
;
;--------------------------
;
;  BOX FILL
;
;    ent DE':xs, DE:xe
;        HL':ys, HL:ye
;        A:fill color
;
;--------------------------
BOXF:
        CALL   COLS            ;Fill Color Set
        LD     B,A
        LD     A,(GMODE)
        CP     B
        JR     NZ,BOXC
        LD     SP,(SPBOX)      ;line routions pop
BOXC:   LD     A,(PWMODE)
        OR     A
BOXC0:
        LD     A,0C0H           ;w0 pset
        JR     Z,BOXF0
        LD     A,40H           ;w0 or
BOXF0:  OR     B
        OUT    (LSWF),A        ;Write mode set
;
YLINE:  LD     A,H
        OR     D
        RET    M
        CALL   BFCHK
        LD     A,L             ;ye
;
        EXX                    ;hl=ys,de=xs
        BIT    7,H
        JR     Z,$+5
        LD     HL,0
        BIT    7,D
        JR     Z,$+5
;
        LD     DE,0
        EX     AF,AF
        CALL   BFCHK
        RET    C
        EX     AF,AF          ;ye
;
        INC    A
        SUB    L               ;acc=lines(ye-ys+1)
        RET    C
        RET    Z
        EX     AF,AF          ;acc'=lines
;
        PUSH   HL              ;ye
        CALL   ADCH
        LD     (LSTA),HL
        EXX
        POP    HL              ;ye
        LD     B,A             ;left
        PUSH   BC
        CALL   ADCH
        POP    BC
        LD     (RSTA),HL
        LD     C,A             ;right
        LD     DE,(LSTA)
;
HLINE:  OR     A
        SBC    HL,DE
        JR     Z,BOXI
        DEC    HL
        INC    DE              ;next point
        LD     A,L
        OR     A
        CALL   NZ,BOXL         ;a' reserve
;
BOXH:   LD     HL,TDOTR
        LD     A,B
        LD     B,0
        ADD    HL,BC
        LD     L,(HL)
        LD     C,A
        LD     A,L
        LD     HL,TDOTL
        ADD    HL,BC
        LD     B,(HL)
;
;
        LD     DE,(RSTA)
        PUSH   BC
        CALL   BOXW
        POP    BC
        LD     DE,(LSTA)
        LD     A,B
        JR     BOXW
;
;
;
;
BOXI:   LD     HL,TDOTR
        LD     A,B
        LD     B,0
        ADD    HL,BC
        LD     C,A
        LD     A,0FFH
        AND    (HL)
        LD     HL,TDOTL
        ADD    HL,BC
        AND    (HL)
;
;
BOXW:
        LD     C,A
        EX     AF,AF
        LD     B,A
        EX     AF,AF
        EX     DE,HL
        DI
BFL0:   LD     DE,80           ;40
        IN     A,(LSE0)
BOXW1:  LD     (HL),C
        ADD    HL,DE
        DJNZ   BOXW1
        IN     A,(LSE1)
        EI
        RET
;
;
;
;
BOXL:   PUSH   BC
        EX     DE,HL           ;hl=start
        LD     B,A             ;yoko counter
        EX     AF,AF
        LD     C,A             ;tate counter
        EX     AF,AF
BFL1:   LD     DE,80           ;40
        DI
BOXL1:  PUSH   HL
        PUSH   BC
        IN     A,(LSE0)
        LD     A,0FFH
BOXL0:  LD     (HL),A
        INC    HL
        DJNZ   BOXL0
        IN     A,(LSE1)
        POP    BC
        POP    HL
        ADD    HL,DE
        DEC    C
        JR     NZ,BOXL1
        EI
        POP    BC
        RET
;
;


;-----------------------------
;
;    box fill range check
;
;-----------------------------
;
BFCHK:  LD     A,H
        OR     A
        JR     NZ,BFCHK0
        LD     A,199
        CP     L
        JR     NC,BFCHK1       ;skip if hl>199
BFCHK0: LD     HL,199
        SCF
BFCHK1: RRA                    ;push cf
        PUSH   HL
BFC0:   LD     HL,-640         ;-320
        ADD    HL,DE
        POP    HL
        JR     NC,BFCHK3       ;skip if de>639,319
BFC1:   LD     DE,639          ;319
        RET
;
BFCHK3: RLA                    ;pop cf
        RET
;-----------------------------
;
; Position check
;
;-----------------------------
POSCK:
        EXX
        CALL   RNGCK
        EXX
        RET    NC              ;OK
        LD     A,3
        JP     ERRORJ
;-----------------------------
;
; Position save
;
;-----------------------------
POSSV:
        EXX                    ;Position save
        LD     (POINTX),DE
        LD     (POINTY),HL
        EXX
        RET


;----------------------------
;
;  SYMBOL
;
;    Ent. A:angle
;         B:string length
;         H:Y ratio
;         L:X ratio
;         DE:string address
;
;----------------------------
;
;
SBDTAP: DEFS   8
;

; This structure shares the memory space allocated for KEYBUF

defc SDT0   =    1200H
defc SDT7   =    1207H
;
defc SCNT   =    1208H           ;1
defc HCNT   =    SCNT+1          ;1
defc VCNT   =    HCNT+1          ;1
defc BCNT   =    VCNT+1          ;1
;
defc STRAP  =    BCNT+1          ;2
defc SDTAP  =    STRAP+2         ;2
defc BDTAP  =    SDTAP+2         ;2
;
defc DEFX0  =    BDTAP+2         ;1
defc DEFY0  =    DEFX0+1         ;1
defc DEFX8  =    DEFY0+1         ;2
defc DEFY8  =    DEFX8+2         ;2
;
defc PX     =    DEFY8+2         ;2
defc PY     =    PX+2            ;2
;
defc VADD   =    PY+2            ;2
defc LDOT   =    VADD+2          ;1
;
defc DEFX   =    LDOT+1          ;1
defc DEFY   =    DEFX+1          ;1
defc DEF8   =    DEFY+1          ;2
;
defc NSDT   =    DEF8+2          ;2    ->  $1223


;
;
CLLADD: DEFW   LOD00
        DEFW   LOD90
        DEFW   LOD18
        DEFW   LOD27
;
;
SYMBOL:
        PUSH   BC              ;string length
        PUSH   DE              ;string address
        LD     BC,PX
        LD     D,L
        LD     E,H
        BIT    0,A
        JR     Z,SYMB10        ;skip acc=0,2
;
        EX     DE,HL           ;exchange milti
        INC    BC
        INC    BC              ;bc=py
;
SYMB10: LD     (SYMB18+1),BC
        LD     (DEFX0),HL
        LD     H,0
        ADD    HL,HL
        ADD    HL,HL
        ADD    HL,HL           ;defx8=defx*8
        LD     (DEFX8),HL
;
        LD     L,E
        LD     H,0
        ADD    HL,HL
        ADD    HL,HL
        ADD    HL,HL           ;defy8=defy*8
        LD     (DEFY8),HL
;
;
;   set py ,def8
;
        LD     DE,0
        EX     DE,HL           ;de=defy8
        SBC    HL,DE           ;hl=-defy8
        LD     (DEF8),HL       ;def8=-defy8
        BIT    1,A
        JR     Z,SYMB11        ;skip if acc=0,1
;
        LD     (DEF8),DE       ;def8=defy8
SYMB11: OR     A               ;HL=-defy8
        JP     PO,SYMB12       ;skip if acc=1,2
;
        LD     HL,0
SYMB12: LD     DE,(POINTY)
        ADD    HL,DE           ;pointy or pointy-defy8
        LD     (PY),HL         ;set py
;
;
;     set px def8
;
;
        LD     DE,(DEFX8)
        LD     HL,0
        OR     A               ;de=defx8
        SBC    HL,DE           ;hl=-defx8
        BIT    0,A
        JR     NZ,SYMB13       ;skip if acc=1,3
        BIT    1,A
        LD     (DEF8),DE       ;DE=defx8
        JR     Z,SYMB13        ;skip if acc=0
        LD     (DEF8),HL       ;hl=-defx8
SYMB13: EX     DE,HL           ;de=-defx8
        LD     HL,(POINTX)
        BIT    1,A
        JR     Z,SYMB15        ;skip if acc=0,1
        ADD    HL,DE           ;pointx or pointx-defx8
SYMB15: LD     (PX),HL         ;set px
;
;   calc rotation program addr
;
        ADD    A,A
        LD     HL,CLLADD
        LD     D,0
        LD     E,A
        ADD    HL,DE
        LD     E,(HL)
        INC    HL
        LD     D,(HL)
        LD     (SYMS10+1),DE
;
        CALL   SETW            ;set pwmode
        POP    HL
        POP    BC
;
SYMB17: DEC    B               ;string count down
        RET    M
;
        PUSH   HL
        PUSH   BC
        CALL   SYMS
SYMB18: LD     HL,PX           ;py
        LD     E,(HL)          ;calc px(py)=px(py)+def8
        INC    HL
        LD     D,(HL)
        PUSH   HL
        LD     HL,(DEF8)
        ADD    HL,DE
        EX     DE,HL
        POP    HL
        LD     (HL),D
        DEC    HL
        LD     (HL),E          ;set next disp addr
        POP    BC
        POP    HL
        INC    HL              ;next string pointer
        JR     SYMB17


;
; //  SYMBOL  SUB.   //
;
;
;
SYMS:   LD     IY,SCNT
        LD     A,(HL)          ;mz ascii -> display
        RST    3
        DEFB   _ADCN          ;PSGON
        LD     H,0
        LD     L,A
        ADD    HL,HL
        ADD    HL,HL
        ADD    HL,HL
        LD     A,10H
        ADD    A,H
        LD     H,A             ;hl=hl+1000H
;
        LD     DE,SBDTAP       ;xfer cg data
        LD     BC,8
        DI
        IN     A,(LSE0)
        LDIR
        IN     A,(LSE1)
        EI
;
        LD     B,8             ;rotation pro.
SYMS10: CALL   LOD00           ;LODXX
;
;
        LD     HL,808H
        LD     (HCNT),HL       ;set hcnt,vcnt
        LD     DE,(DEFX0)
        LD     (DEFX),DE
        LD     HL,(PX)
        BIT    7,H
        JR     Z,SYMS20        ;skip if PX>=0
;
        CALL   SSYMB
        RET    C               ;error position
;
;
SYMS11: EXX                    ;data area rotate
        LD     B,8
        LD     HL,SDT0
SYMS12: RLC    (HL)
        INC    HL
        DJNZ   SYMS12
        EXX
        DJNZ   SYMS11
;
        LD     HL,0
SYMS20: LD     (SYMS23+1),HL
        LD     A,0F8H
        AND    L
        OR     H
        RRC    A
        RRC    A
        RRC    A
SYMS21: SUB    80              ;40
        RET    NC              ;buffer full check?
;
        LD     L,A             ;SEND DATA ADD.
        LD     H,11H
        LD     (BDTAP),HL
        LD     HL,(PY)
        XOR    A
        BIT    7,H
        JR     Z,SYMS22
;
        INC    IY
        CALL   SSYMB
        DEC    IY
        RET    C               ;error position
;
;
        LD     HL,0
        LD     A,8
        SUB    B
SYMS22: LD     (SYMS24+1),A
SYMS23: LD     DE,0            ;XXH
        PUSH   HL
        PUSH   DE
        CALL   RNGCK
        POP    DE
        POP    HL
        RET    C               ;error position
;
        CALL   ADCH
       LD     (VADD),HL
        LD     HL,TDOTN
        LD     D,0
        LD     E,A
        ADD    HL,DE
        LD     A,(HL)
        LD     (LDOT),A
SYMS24: LD     HL,SDT0
SYMS25: LD     DE,(BDTAP)
        LD     BC,(LDOT)       ;b defx c ldot
        XOR    A
        EXX
        LD     B,(IY+1)        ;hcnt
;
SYMS30: EXX
        LD     (DE),A
        XOR    A
;
        RRC    (HL)
        JR     NC,SYMS31
;
        LD     A,0B1H           ;OR C
SYMS31: LD     (SYMS32),A
        LD     A,(DE)
;
SYMS32: OR     C               ;nop
        RLC    C
        JR     NC,SYMS33
        LD     (DE),A
        INC    E               ;next data addr
        JR     Z,SYMS34        ;skip if buffer full
        XOR    A
SYMS33: DJNZ   SYMS32
;
SYMS3A: LD     B,(IY+0AH)      ;defx0
        EXX
        DJNZ   SYMS30          ;hcnt
;
        EXX
        LD     (DE),A
        INC    E
;
SYMS34: DEC    E
        INC    L
        LD     (SDTAP),HL
        LD     HL,(BDTAP)
        EX     DE,HL
        XOR    A
        SBC    HL,DE
        INC    HL
        LD     (NSDT),HL
        LD     A,(DEFY)
        LD     B,A             ;loop counter set
;
SYMS40: EXX
        LD     DE,(VADD)
        LD     HL,(BDTAP)
        LD     BC,(NSDT)
        DI
        IN     A,(LSE0)
        OUT    (LSE0),A
        LDIR
        IN     A,(LSE1)
        EI
SYMS41: LD     DE,80           ;40
        LD     HL,(VADD)
        ADD    HL,DE
        LD     (VADD),HL       ;next disp addr
SYMS42: LD     DE,0BE80H        ;9F40H
        OR     A
        SBC    HL,DE
        RET    NC              ;position error check
;
        EXX
        DJNZ   SYMS40
;
SYMS43: LD     A,(DEFY0)       ;
        LD     (DEFY),A        ;set loop counter
        LD     HL,(SDTAP)
        DEC    (IY+2)          ;VCNT
        JP     NZ,SYMS25
        RET


;
;   //  rotation sub .   //
;
LOD00:  LD     HL,SBDTAP
        LD     DE,SDT0
        LD     C,B
        LD     B,0
        LDIR
        RET
;
;
LOD90:  LD     DE,SDT0
LOD901: EXX
        LD     HL,SBDTAP
        LD     B,8
        XOR    A
;
LOD902: RLC    (HL)
        RRA
        INC    HL
        DJNZ   LOD902
;
        EXX
        LD     (DE),A
        INC    DE
        DJNZ   LOD901
;
        RET
;
;
LOD18:  LD     DE,SDT7
        LD     HL,SBDTAP
;
LOD181: LD     A,(HL)
        EXX
        LD     C,A
        LD     B,8
        XOR    A
;
LOD182: RR     C
        RL     A
        DJNZ   LOD182
;
        EXX
        LD     (DE),A
        INC    HL
        DEC    DE
        DJNZ   LOD181
;
        RET
;
;
LOD27:  LD     DE,SDT7
LOD271: EXX
        LD     HL,SBDTAP
        XOR    A
        LD     B,8
;
LOD272: RLC    (HL)
        RLA
        INC    HL
        DJNZ   LOD272
;
        EXX
        LD     (DE),A
        DEC    DE
        DJNZ   LOD271
        RET
;
;   calc position
;
;
SSYMB:  LD     B,8
        LD     E,(IY+0AH)      ;defx0,defy0
        LD     D,0
;
SSYMB1: ADD    HL,DE
        BIT    7,H
        JR     Z,SSYMB2
        DJNZ   SSYMB1
SSYMB4: SCF
        RET
;
SSYMB2: LD     A,H
        OR     L
        JR     NZ,SSYMB3
        LD     L,E
        DEC    B
        JR     Z,SSYMB4
SSYMB3: LD     (IY+17H),L      ;defx,defy
        LD     (IY+1),B        ;HCNT,VCNT
        OR     A
        RET


;
;-------------------------------
;
;
; PATTERN
;  ent A:Heighth
;      B:String length
;      H:Direction
;     DE:String adrs
;
;-------------------------------
defc POINTW  =  KEYBF           ;2
defc STRAD   =  POINTW+2        ;2
defc PATDA1  =  POINTW+250
defc PATDA2  =  POINTW+251
defc PATDA3  =  POINTW+252
defc PATDA4  =  POINTW+263
;
;
CHARW:
        OR     A               ;no mode ?
        RET    Z               ;yes
        LD     (STRAD),DE
        LD     E,A             ;E'=Height
        LD     C,A             ;C'=Height(work)
        LD     A,H
        OR     A
        LD     A,23H           ;INC HL
        JR     NZ,PATT1        ;DOWN
;
        LD     A,2BH           ;DEC HL
PATT1:  LD     (PATTA),A
        LD     (PATTC),A
        LD     A,B
        OR     A               ;no string ?
        RET    Z               ;yes
;
        LD     HL,(POINTX)
        LD     A,07H
        AND    L
        LD     D,A
        EXX                    ;keep c',e',b',d'
        LD     HL,TDOTL
        LD     D,0
        LD     E,A
        ADD    HL,DE
        LD     A,(HL)
;
        LD     (PATTB+1),A     ;MASK DATA
;
PATT3:  LD     HL,(POINTY)
PATT4:  LD     (POINTW),HL     ;save (POINTY)
;
PATTB:  LD     C,0FFH           ;C=mask data
        LD     HL,(STRAD)      ;read DATA
        LD     A,(HL)
;
        EXX                    ;keep c',e',b',d'
        LD     H,A
        LD     A,D
        OR     A               ;X=0 ?
        JR     Z,PATT6         ;yeS
PATT7:  RRC    H
        DEC    A
        JR     NZ,PATT7
PATT6:  LD     A,H
        EXX                    ;A=pattern data
;
        LD     HL,PATDA1
;
        LD     B,8             ;DATA sift
        LD     D,A
PATT80: SRL    D
        RLA
        DJNZ   PATT80
;
        LD     D,A             ;C^D
        AND    C
        LD     (HL),A          ;left set data
;
        LD     A,D
        CPL
        LD     B,A             ;B=CPL(D)=CPL(STRAD)
        AND    C               ;C^CPL(D)
        INC    HL
        LD     (HL),A          ;left reset data
;
        LD     A,C
        CPL
        LD     C,A
        AND    D               ;CPL(C)^D
        INC    HL
        LD     (HL),A          ;right set data
;
        LD     A,C
        AND    B               ;CPL(C)^CPL(D)
        INC    HL
        LD     (HL),A          ;right reset data
;
        LD     DE,(POINTX)
        LD     HL,(POINTW)
;
;
        PUSH   DE
        PUSH   HL
        EX     DE,HL           ;X=X+1
        LD     BC,8
        ADD    HL,BC
        EX     DE,HL
        LD     A,1             ;right mode
        CALL   PATT90
        POP    HL
        POP    DE
;
        XOR    A               ;left mode
        CALL   PATT90
;
;
        LD     HL,(STRAD)      ;next data
        INC    HL
        LD     (STRAD),HL
        EXX
        DJNZ   PATT5           ;B'
;
        DEC    C               ;C' X-->END
        EXX
        JP     Z,PATT70        ;X=X+8 & END
        LD     HL,(POINTW)
PATTC:  INC    HL              ;DEC HL
        LD     (POINTY),HL
;
        XOR    A               ;end
        RET
;
PATT5:  DEC    C               ;C'
        JR     NZ,PATT2        ;next Xposition
        LD     C,E             ;C' E'
        EXX
        CALL   PATT70          ;X=X+8
        JR     PATT3
;
;
PATT2:  EXX
        LD     HL,(POINTW)
PATTA:  INC    HL              ;DEC HL
        JR     PATT4
;
;     pointx+8
;
PATT70: LD     HL,(POINTX)
        LD     BC,8
        ADD    HL,BC
        LD     (POINTX),HL
        RET
;
;---------------------------
;
;     V-RAM write
;         non keep
;
;       A=0 ---->left
;         1 ---->right
;       DE=X positin
;       HL=y position
;---------------------------
PATT90: EX     AF,AF          ;push AF
        CALL   RNGCK
        RET    C               ;address err
;
        CALL   ADCH            ;get V-RAM address
        LD     B,A             ;B=0 -->no right data
;          HL=V-RAM address
;
        LD     DE,PATDA1       ;(DE)=write data
        EX     AF,AF          ;pop AF
        OR     A               ;left data ?
        JR     Z,PATT91        ;yes
;
        LD     A,B             ;non right data
        OR     A
        RET    Z
;
        INC    DE              ;DE,PATDA3
        INC    DE
PATT91: CALL   SETW            ;mode set
        DI
        IN     A,(LSE0)
        OUT    (LSE0),A        ;get V-RAM
        LD     A,(DE)          ;B=right data
        LD     (HL),A
        LD     A,(PWMODE)
        OR     A               ;OR mode ?
        JR     NZ,PATT92       ;YES
;
        LD     A,(CPLANE)      ;read color data
        OR     60H
        OUT    (LSWF),A
        INC    DE
        LD     A,(DE)          ;C=reset data
        LD     (HL),A
PATT92: IN     A,(LSE1)
        EI
        RET
;
;
; --------------------------------
;
;    PAINT   ROUTINE  ( 9.5/84 )
;
;
;            HL: COLOR ADD.
;            B : NUM. of COLOR
;
; -------------------------------
;
defc DIRAR   =    27D0H
defc ENKYB   =    12A0H
defc NDSP    =    KEYBF           ;2
defc DSP     =    NDSP+2          ;2
defc NSSP    =    DSP+2           ;1
defc SSP     =    NSSP+1          ;2
defc PBXL    =    SSP+2           ;2
defc PBXR    =    PBXL+2          ;2
;
defc Y       =    PBXR+2          ;2
defc BXL     =    Y+2             ;2
defc BXR     =    BXL+2           ;2
defc DIRECT  =    BXR+2           ;1
defc JCONT   =    DIRECT+1        ;1
defc JSAVE   =    JCONT+1         ;1
defc JSAVE1  =    JSAVE+1         ;1
defc BUFF    =    JSAVE1+1        ;11 DATA BUFF.
;
defc _PEEK    =    DIRAR           ;PROGRAM AREA
;
defc WORK    =    Y
;
;
;  //  MAIN  ROUTINE   //
;
;
WPAINT:
        LD     A,(GMODE)
        OR     0C0H
        OUT    (LSWF),A        ;Write mode set
        EXX
        LD     DE,_PEEK         ;MAKE PEEK ROUTINE
        LD     HL,DPEEK
        LD     BC,DPEEK1-DPEEK
        LDIR
        EXX
;
PAIN0:  LD     A,(HL)          ;     COLOR SELECT
        CALL   COLS            ;Bound Color Set
        OR     80H             ;SEARCH MODE SET
        LD     (DPEEK1+1),A
        INC    HL
        EXX
        LD     HL,DPEEK1
        LD     BC,DPEEK2-DPEEK1
        LDIR
        EXX
        DJNZ   PAIN0
;
        EXX
        LD     BC,DPEEK3-DPEEK2+1
        LDIR
        LD     HL,(TMPEND)
        LD     (DSP),HL
        LD     (CSAVE+2),HL
        LD     HL,(PAIWED)
        LD     DE,-6
        ADD    HL,DE
        LD     (SVDT0+1),HL
;
;
        LD     HL,(POINTX)
        DEC    HL
        LD     (BXL),HL        ;BXL=POINTX-1
        INC    HL
        INC    HL
        LD     (BXR),HL        ;BXR=POINTX+1
        DEC    HL
        EX     DE,HL
        LD     HL,0
        LD     (NDSP),HL
        LD     HL,(POINTY)
        LD     (Y),HL
        CALL   RNGCK
        CCF
        RET    NC              ;START OUT RANGE
;
        LD     (SOVER1),SP
        LD     SP,DIRAR+700H
;
;
        CALL   ADCH
        LD     DE,TDOTN
        PUSH   HL
        LD     H,0
        LD     L,A
        ADD    HL,DE
        LD     C,(HL)
        POP    HL
        CALL   _PEEK
        AND    C
        JP     NZ,PAINCE       ;ON BOUND
;
        CALL   RBSR
        LD     (BXR),IX        ;SET R.BOUND
        CALL   LBSR
        LD     (BXL),IX        ;SET L.BOUND
        LD     A,0FFH
        LD     (DIRECT),A      ;DOWN
        CALL   SVDT
        LD     HL,ENKYB
        LD     (SSP),HL
        XOR    A
        LD     (DIRECT),A
        LD     (NSSP),A
;
PAIN1:  LD     A,(DIRECT)
        CALL   CHDIR0
        LD     A,199
        CP     L
        JR     C,PAINA         ;OUT RANGE
;
        CALL   NBSRCH
        JR     C,PAINA         ;CLOSE
;
        LD     (JCONT),A
        AND    9
        CALL   NZ,PAIND
;
        CALL   CSAVE
        LD     A,(JSAVE)
        OR     A
        JR     NZ,PAINA
;
PAIN3:  CALL   PSRCH
        JR     Z,PAIN1
;
        LD     HL,(BXR)
        PUSH   HL
        PUSH   DE
        CALL   RBSR0
        LD     (BXR),IX
        CALL   SVDT
        POP    HL
        LD     (BXL),HL
        POP    HL
        LD     (BXR),HL
        JR     PAIN1
;
;
PAINA:  LD     HL,(DSP)
        DEC    HL
        LD     DE,-7
        LD     BC,(NDSP)
PAINA1: LD     A,B
        OR     C
        JR     Z,PAINC
;
        LD     A,0FH
        DEC    BC
        CP     (HL)
        ADD    HL,DE
        JR     Z,PAINA1
;
        INC    HL
        PUSH   HL
        LD     (PAINA2+1),HL
        LD     DE,WORK
        LD     BC,7
        LDIR
        EX     DE,HL
        LD     HL,(DSP)
        XOR    A
        POP    BC
        LD     (DSP),BC
        SBC    HL,DE
        JR     Z,PAINA3
;
        LD     B,H
        LD     C,L
PAINA2: LD     HL,00H          ;XXH
        EX     DE,HL
        LDIR
        LD     (DSP),DE
;
PAINA3: LD     HL,(NDSP)
        DEC    HL
        LD     (NDSP),HL
        JP     PAIN3
;
;
PAINC:  LD     HL,(NDSP)
        LD     A,L
        OR     H
        JR     NZ,PAINC0
;
PAINCE: LD     SP,(SOVER1)     ;END JOB
        RET
;
;
PAINC0: DEC    HL
        LD     (NDSP),HL
        LD     HL,(DSP)
        DEC    HL
        LD     DE,WORK+6
        LD     BC,7
        LDDR
        INC    HL
        LD     (DSP),HL
;
PAINC1: CALL   PSRCH
        JR     Z,PAINC
;
        CALL   RBSR0
        LD     (BXR),IX
        JR     PAINC1
;
;
PAIND:  LD     HL,PBXL         ;DATA SAVE
        LD     DE,BUFF
        CALL   PAIND3
        LD     A,(JCONT)
        BIT    0,A
        JR     Z,PAIND1
;
LTW:    LD     HL,(PBXL)
        LD     (BXR),HL
        CALL   TWR
        JR     C,LTW1          ;CLOSE
;
        BIT    0,A
        JR     NZ,LTW
;
LTW1:   CALL   PAIND2
        LD     A,(JCONT)
        CP     9
        RET    NZ
;
PAIND1: LD     HL,(PBXR)
        LD     (BXL),HL
        CALL   TWR
        JR     C,PAIND2
;
        BIT    3,A
        JR     NZ,PAIND1
;
PAIND2: LD     HL,BUFF
        LD     DE,PBXL
PAIND3: LD     BC,11
        LDIR
        RET
;
;
;
;     CHECK  SAVE  DATA
;
;
CSAVE:  LD     IY,00H          ;XXH
        LD     BC,(NDSP)
        LD     HL,00H
        LD     (JSAVE),HL      ;STATUS CLEAR
;
CSAVE1: CALL   DSAVE
        LD     A,(NSSP)
        OR     A
        RET    Z
;
        DEC    A
        LD     (NSSP),A
        LD     (CSAVE2+1),SP
        LD     SP,(SSP)
        POP    IY
        POP    BC
        POP    HL
        LD     (BXR),HL
        POP    HL
        LD     (BXL),HL
        LD     (SSP),SP
CSAVE2: LD     SP,00H          ;XXH
        JR     CSAVE1
;
;
DSAVE:  LD     A,B
        OR     C
        LD     (DSAVEC+1),BC
        JP     Z,DSAVE3
;
        LD     HL,(Y)
        LD     E,(IY+0)
        LD     D,(IY+1)
        XOR    A
        SBC    HL,DE
        JR     NZ,DSAVE2
;
        CALL   COMP
        CP     5
        JR     Z,DSAVE1
;
        CP     0FH
        JR     NZ,DSAVE4
;
        LD     L,(IY+2)        ;SBXL
        LD     H,(IY+3)
        LD     DE,(BXR)
        XOR    A
        SBC    HL,DE
        JR     NC,DSAVE2
;
        LD     HL,(BXL)
        PUSH   HL
        LD     L,(IY+2)
        LD     H,(IY+3)
        PUSH   HL
DSAVE_0:
        LD     (BXL),HL
        LD     A,3
        CALL   ESAVE
        POP    HL
        LD     (BXR),HL
        POP    HL
        LD     (BXL),HL
        CALL   RBSR
        LD     (BXR),IX
        JR     DSAVE2
;
DSAVE1: LD     E,(IY+4)        ;SBXR
        LD     D,(IY+5)
        LD     HL,(BXL)
        XOR    A
        SBC    HL,DE
        JR     NC,DSAVE2
;
        LD     HL,(BXR)
        PUSH   HL
        LD     L,(IY+4)
        LD     H,(IY+5)
        PUSH   HL
        LD     (BXR),HL
        LD     A,4
        CALL   ESAVE
        POP    HL
        LD     (BXL),HL
        POP    HL
        LD     (BXR),HL
        CALL   LBSR
        LD     (BXL),IX
;
DSAVE2: LD     DE,7
        ADD    IY,DE
DSAVEC: LD     BC,00H          ;XXH
        DEC    BC
        JP     DSAVE
;
DSAVE3: LD     A,(JSAVE1)
        OR     A
        CALL   NZ,SVDT
        RET
;
DSAVE4: EX     AF,AF
        LD     A,0FH
        LD     (JSAVE),A
        EX     AF,AF
        OR     A
        JR     NZ,DSAVE5
;
        LD     A,0FH
        LD     (IY+6),A
        RET
;
DSAVE5: CP     1
        JR     NZ,DSAVE6
;
        LD     L,(IY+4)        ;SBXR
        LD     H,(IY+5)
        LD     (BXL),HL
        CALL   LBSR
        LD     (BXL),IX
        JR     DSAVE8
;
DSAVE6: CP     0CH
        JR     NZ,DSAVE9
;
DSAVE7: LD     L,(IY+2)        ;SBXL
        LD     H,(IY+3)
        LD     (BXR),HL
        CALL   RBSR
        LD     (BXR),IX
DSAVE8: LD     A,0FH
        LD     (IY+6),A
        LD     (JSAVE1),A      ;SAVE DATA AFTER JOB
        JR     DSAVE2
;
;
DSAVE9: CP     0DH
        JP     NZ,ESAVE
;
        LD     A,(NSSP)
        INC    A
        CP     27
        CCF
        JP     C,SOVER         ;STACK OVER
;
        LD     (NSSP),A
        LD     HL,(BXL)
        PUSH   HL              ;SAVE BXL
        LD     L,(IY+4)
        LD     H,(IY+5)
        LD     (BXL),HL
        CALL   LBSR
        LD     (DSAVEB+2),IY
        LD     DE,7
        ADD    IY,DE
        LD     BC,(DSAVEC+1)
        DEC    BC
        LD     (DSAVEA+1),SP
        LD     SP,(SSP)
        PUSH   IX              ;BXL
        LD     DE,(BXR)
        PUSH   DE
        PUSH   BC
        PUSH   IY
        LD     (SSP),SP
DSAVEA: LD     SP,00H          ;XXH
DSAVEB: LD     IY,00H          ;XXH
        POP    HL
        LD     (BXL),HL
        JP     DSAVE7
;
;
ESAVE:  EX     AF,AF
        CALL   SVDT
        DEC    DE
        LD     A,0FH
        LD     (DE),A
        EX     AF,AF
        CP     3
        JR     NZ,ESAVE2
;
ESAVE1: LD     HL,(BXR)
        LD     (BXL),HL
        LD     L,(IY+4)
        LD     H,(IY+5)        ;SBXR
        LD     (BXR),HL
        CALL   LBSR
        PUSH   IX
        POP    HL
        LD     (IY+2),L
        LD     (IY+3),H
        RET
;
ESAVE2: CP     4
        JR     Z,ESAVE3
;
        LD     HL,(DSP)
        PUSH   HL
        LD     (SVDT1+1),IY
        CALL   SVDT
        LD     HL,WORK
        LD     (SVDT1+1),HL
        LD     HL,(BXL)
        PUSH   HL
        CALL   ESAVE1
        POP    HL
        LD     (BXR),HL
        POP    IY
        JR     ESAVE4
;
;
ESAVE3: LD     HL,(BXL)
        LD     (BXR),HL
ESAVE4: LD     L,(IY+2)
        LD     H,(IY+3)
        LD     (BXL),HL
        CALL   RBSR
        PUSH   IX
        POP    HL
        LD     (IY+4),L
        LD     (IY+5),H
        RET
;
;
;     NEXT  BOUNS  SEARCH
;
;
NBSRCH: LD     HL,(BXL)
        LD     (PBXL),HL
        LD     HL,(BXR)
        LD     (PBXR),HL
        CALL   LBSR
        RET    C               ;CLOSE
;
        LD     (BXL),IX
        CALL   RBSR
        LD     (BXR),IX
        CALL   _CONT            ;CF=0
        LD     A,B
        RET
;
;    CHANGE  Y DIRECTON
;           &
;    NEXT  Y CO-ORDINATE
;
CHDIR:  LD     A,(DIRECT)
        CPL
        LD     (DIRECT),A
CHDIR0: LD     HL,(Y)
        INC    L
        OR     A
        JR     NZ,CHDIR1
;
        DEC    L
        DEC    L
CHDIR1: LD     (Y),HL
        RET
;
;
TWR:    CALL   CHDIR
        CALL   NBSRCH
        RET    C
;
        PUSH   AF
        LD     HL,(BXL)
        PUSH   HL
        LD     HL,(BXR)
        PUSH   HL
        CALL   CSAVE
        LD     A,(JSAVE)
        OR     A
        CALL   Z,SVDT
;
        POP    HL
        LD     (BXR),HL
        POP    HL
        LD     (BXL),HL
        POP    AF
        RET
;
;
; ***   BOUND  SEARCH   ****
;
;
;
;  //  LEFT BOUNS SEARCH  //
;
LBSR:   LD     DE,(BXR)
        LD     HL,(BXL)
        PUSH   HL
        LD     (BSRCH4+1),DE
        LD     HL,00H
        LD     (BSRCH6+1),HL
        LD     A,2BH           ;DEC IX
        LD     (BSRCH3+1),A
        LD     A,2FH           ;CPL
        LD     (BSRCH5),A
        XOR    A
        LD     (BSRCH7),A
        LD     HL,BSRCHL
        LD     (BSRCH1+1),HL
        LD     HL,BSRCHR
        LD     (BSRCH2+1),HL
        POP    DE
        INC    DE
        JR     BSRCH
;
;  //  RIGHT BOUNS SEARCH  //
;
RBSR:   LD     DE,(BXR)
RBSR0:  LD     HL,(BXL)
        LD     (BSRCH6+1),HL
        DEFB   21H             ;LD HL,640 or 320
LRBSR:
        DEFW   8002H
        LD     (BSRCH4+1),HL
        LD     A,23H           ;INC IX
        LD     (BSRCH3+1),A
        LD     A,2FH           ;CPL
        LD     (BSRCH7),A
        XOR    A
        LD     (BSRCH5),A
        LD     HL,BSRCHR
        LD     (BSRCH1+1),HL
        LD     HL,BSRCHL
        LD     (BSRCH2+1),HL
        DEC    DE
;
;
;  //  SEARCH ROUTINE  //
;
BSRCH:  LD     HL,(Y)
        PUSH   DE
        POP    IX
        CALL   ADCH
        LD     DE,TDOTN
        PUSH   HL
        LD     H,0
        LD     L,A
        ADD    HL,DE
        LD     C,(HL)
        POP    HL
        CALL   _PEEK
        LD     E,A
        AND    C
BSRCH1: JP     Z,BSRCHL        ;JP BSRCHR
;
BSRCH2: CALL   BSRCHR          ;CALL BSRCHL
BSRCH3: DEC    IX              ;INC IX
        RET
;
;   ++  SEARCH  LEFT  +++
;
BSRCHL: DEC    IX
        RRC    C
        JR     NC,BSRCHC
;
        PUSH   IX
        EXX
        POP    DE
        INC    DE
BSRCH6: LD     HL,00H          ;BX
        INC    HL
        SBC    HL,DE
        EXX
        RET    NC
;
        DEC    HL
        CALL   _PEEK
        LD     E,A
BSRCHC: LD     A,E
BSRCH7: NOP                    ;CPL
        AND    C
        JP     Z,BSRCHL
        RET
;
;  ++  SEARCH  RIGHT   +++
;
BSRCHR: INC    IX
        RLC    C
        JR     NC,BSRCHA
;
        CALL   BSRCHD
        RET    C
;
        INC    HL
        CALL   _PEEK
        LD     E,A
BSRCHA: LD     A,E
BSRCH5: CPL                    ;NOP
        AND    C
        JR     Z,BSRCHR

BSRCHD: PUSH   IX
        EXX
        POP    HL
BSRCH4: LD     DE,BXR
        XOR    A
        SBC    HL,DE
        EXX
        CCF
        RET
;
;
;
;  //  CONT. CHECK  //
;
_CONT:   LD     B,0H
        LD     HL,(PBXR)
        LD     DE,(BXR)
        CALL   CONT1
        LD     HL,(PBXL)
        LD     DE,(BXL)
        INC    HL              ;FOR  HL=FFH
        INC    DE              ;FOR  DE=FFH
;
CONT1:  PUSH   HL
        XOR    A
        INC    HL
        SBC    HL,DE
        POP    HL
        RL     B
        INC    DE
        EX     DE,HL
        SBC    HL,DE
        RL     B
        RET
;
;
;  ***  POINT DATA
;
;          SAVE & LOAD  ****
;
;
;  //  DATA  SAVE  //
;
SVDT:   LD     DE,(DSP)
SVDT0:  LD     HL,0000         ; XX  END ADD
        XOR    A
        SBC    HL,DE
        JR     NC,SVDT1
;
SOVER:
        DEFB   31H             ;STACK POINTER
SOVER1:                    ;LD SP,XXH
        DEFW   00H
        SCF
        RET
;
SVDT1:  LD     HL,WORK
        LD     BC,0007H
        LDIR
        LD     (DSP),DE
        LD     HL,(NDSP)
        INC    HL
        LD     (NDSP),HL
        RET
;
;
;  ***  PAINT & SEARCH  ****
;
;
PSRCH:  LD     HL,(Y)
        LD     DE,(BXR)
        DEC    DE
        CALL   ADCH
        LD     DE,TDOTR
        PUSH   HL
        LD     H,0
        LD     L,A
        ADD    HL,DE
        INC    C
        LD     B,C
        LD     C,(HL)
        POP    HL
;
PSRCH1: CALL   _PEEK
        AND    C
        JR     NZ,PSRCH2       ;BOUND
;
        DI
        IN     A,(LSE0)
        LD     (HL),C
        IN     A,(LSE1)
        EI
        LD     C,0FFH
        DEC    HL
        DJNZ   PSRCH1
;
        LD     DE,-1
        JR     PSRCH5
;
PSRCH2: LD     E,B
        LD     B,7H
        LD     D,00H
PSRCH3: RLC    A
        JR     C,PSRCH4
;
        SCF
        RR     D
        DJNZ   PSRCH3
;
PSRCH4: IN     A,(LSE0)
        LD     A,C
        AND    D
        LD     (HL),A
        IN     A,(LSE1)
;
        LD     A,E
        DEC    A
        RLC    A
        RLC    A
        RLC    A
        LD     C,A
        LD     A,07H
        AND    C
        LD     D,A
        LD     A,0F8H
        AND    C
        OR     B
        LD     E,A
PSRCH5: XOR    A
        LD     HL,(BXL)
        SBC    HL,DE
        RET
;
;
;  //  PEEK  DATA   //
;
DPEEK:  PUSH   HL
        EXX
        POP    HL
        DI
        IN     A,(LSE0)
        LD     C,LSRF
        XOR    A
;
DPEEK1: LD     B,00H           ;RE DATA
        OUT    (C),B
        OR     (HL)
;
DPEEK2: LD     E,A
        IN     A,(LSE1)
        EI
        LD     A,E
        EXX
DPEEK3: RET

;
;
;  //  COMP. BXL,BXR  //
;
COMP:   LD     HL,(BXL)
        LD     E,(IY+2)
        LD     D,(IY+3)
        INC    HL
        INC    DE
        XOR    A
        CALL   COMP1
        LD     HL,(BXR)
        LD     E,(IY+4)
        LD     D,(IY+5)
;
COMP1:  SBC    HL,DE
        RLA
        RLA
        RET    Z
;
        OR     1
        RET
;
;       END  (558BH)


IF RAMDISK
TRANS_0:
        LD     A,0C0H
        OUT    (SIOAC),a
        RET

EMFRB_DI:
        DI
        CALL   EMFRB
        EI
        RET

EMCLR_DI:
        DI
        CALL   EMCLR
        EI
        RET

EMLD2_DI:
        DI
        JP     EMLD2

EMRINF_EI:
        LD     (HL),D
        OR     A
        EI
        RET

EMLDD_0:
        DI
        CALL   EMLDD
        EI
        RET

;  EMLD2_DI_0 is identical to EMLD2_DI !
;  Probably the patches were applied manually in small steps
EMLD2_DI_0:
        DI
        JP     EMLD2

EMSVB_EI:
        CALL   EMSVB
        EI
        RET

LET_0:
        CALL   LET
        LD     A,(PRCSON)
        CP     3
        JP     Z,ER04
        RET

        NOP

BORDER:
        CALL   IBYTE
        LD     BC,6CFH         ;B counter C scrool reg
        OUT    (C),E
        RET

; !!!
SCROLL:
        CALL   IDEEXP
        LD     BC,1CFH         ; scroll register
        OUT    (C),E
        INC    B
        OUT    (C),D
        RET

SYNC:
        IN     A,(LSDMD)       ;check dipsw
        AND    40H
        JR     Z,SYNC
SYNC_0:
        IN     A,(LSDMD)       ;check dipsw
        AND    40H
        JR     NZ,SYNC_0
        RET

EMSV1_0:
        PUSH   HL
        PUSH   AF
        SET    7,H
        LD     A,(CRTMD2)
        DEC    A
        JR     NZ,EMSV1_1
        SCF
        RR     H
        RR     L
        RES    6,H
        LD     A,18H
        RES    5,H
        JR     C,EMSV1_2
EMSV1_1:
        LD     A,14H
EMSV1_2:
        OUT    (LSWF),A        ;write plane
        IN     A,(LSE0)        ;bank change
        POP    AF
        LD     (HL),A
        IN     A,(LSE1)        ;bank off
        OR     A
        POP    HL
        RET

EMLD1_A:
        PUSH   HL
        PUSH   AF
        SET    7,H
        LD     A,(CRTMD2)
        DEC    A
        JR     NZ,EMLD1_A0
        SCF
        RR     H
        RR     L
        RES    6,H
        LD     A,18H
        RES    5,H
        JR     C,EMLD1_A1
EMLD1_A0:
        LD     A,14H
EMLD1_A1:
        OUT    (LSRF),A        ;write plane
        IN     A,(LSE0)        ;bank change
        POP    AF
        LD     L,(HL)
        IN     A,(LSE1)        ;bank off
        LD     A,L
        OR     A
        POP    HL
        RET

VRAM:
        LD     A,0x3C		;   "INC A"
        LD     (CRTPW0-1),A
        PUSH   HL
        CALL   CRTPWR
        CALL   CLSHET
        LD     A,(MEMOP)
        OR     A
        POP    HL
        JP     Z,ER59_
        CALL   ENDCHK
        JR     Z,VRAM0
        CALL   TEST1
        SBC    A,L
        JR     Z,VRAM0
        CALL   TESTX
        AND    C

        PUSH   HL
        LD     HL,EMSV1
        LD     (HL),0C5H       ; "PUSH BC"
        INC    HL
IF MOD_B
        LD     (HL),0CDH       ; "CALL .."
ELSE
        LD     (HL),0EH        ; "LD C,.."
ENDIF
        INC    HL
IF MOD_B
        LD     (HL),0D6H       ;
ELSE
        LD     (HL),0EBH       ; ".. EM_P1"
ENDIF
        LD     HL,EMLD1
        LD     (HL),0C5H       ; "PUSH BC"
        INC    HL
IF MOD_B
        LD     (HL),0CDH       ; "CALL .."
ELSE
        LD     (HL),0EH        ; "LD C,.."
ENDIF
        INC    HL
IF MOD_B
        LD     (HL),0D6H       ;
ELSE
        LD     (HL),0EBH       ; ".. EM_P1"
ENDIF

        XOR    A
        CALL   EMMPWR
        POP    HL
        RET

VRAM0:
        PUSH   HL
        LD     HL,EMSV1
        LD     (HL),0C3H       ; "JP  .."
        INC    HL
        LD     (HL),EMSV1_0%256
        INC    HL
        LD     (HL),EMSV1_0/256
        LD     HL,EMLD1
        LD     (HL),0C3H       ; "JP  .."
        INC    HL
        LD     (HL),EMLD1_A%256
        INC    HL
        LD     (HL),EMLD1_A/256

        LD     HL,$3FFF
        LD     (EMPWR_SMC+1),HL

        XOR    A               ;   "NOP"
        LD     (CRTPW0-1),A    ; prevent "option vram" flag from being enabled
        LD     (MEMOP),A       ; disable "option vram" flag
        PUSH   BC
        CALL   EMMPWR          ;  EMM power on routine
        POP    BC
        POP    HL
        RET


FAST:
        JR     Z,FAST_0
        CALL   TEST1
        SBC    A,L
        JR     Z,FAST_0
        CALL   TESTX
        AND    C
        PUSH   HL
        LD     HL,SLOW_TBL
        JR     FAST_1
FAST_0:
        PUSH   HL
        LD     HL,FAST_TBL
FAST_1:
        LD     A,(HL)
        LD     (DLY3+2),A
        INC    HL
        LD     A,(HL)
        LD     (DLY1+1),A
        INC    HL
        LD     A,(HL)
        LD     (DLY4+1),A
        POP    HL
        RET


SLOW_TBL:
        DEFB   76, 24, 105

FAST_TBL:
        DEFB   35, 11, 49


SCREEN:
        CALL   IBYTE
        OUT    (LSRF),A        ;read plane
		CALL   HCH2CH
        CALL   IBYTE
        PUSH   HL
        PUSH   DE
        PUSH   BC
        LD     B,A
        LD     A,(MEMOP)       ;option vram exist ?
        OR     A
        LD     A,B
        JR     NZ,RD_SUB3_1
        AND    0E3H
RD_SUB3_1:
        OUT    (LSWF),A        ;write plane
        LD     HL,8000H
        PUSH   HL
        POP    DE
        LD     BC,2000H
        LD     A,(DMD)			; display mode
        CP     3
        JR     C,RD_SUB3_2
        LD     BC,4000H
RD_SUB3_2:
        IN     A,(LSE0)        ;bank change !!
        LDIR
        IN     A,(LSE1)        ;  bank reset
        POP    BC
        POP    DE
        POP    HL
        RET


; map 'write mode' values to be sent to LSWF port
;
SPECG:
        PUSH   BC
        CALL   ENDCHK
        LD     B,0C0H	; no value
        JR     Z,SPECG_1
        LD     B,020H
        CP     45H		; 'E'
        JR     Z,SPECG_1
        LD     B,060H
        CP     52H		; 'R'
        JR     Z,SPECG_1
        LD     B,0
        CP     53H		; 'S'
        JP     NZ,ER01
SPECG_1:
        LD     A,B          ; A='Write mode' (to be sent to [LSWF] port)
        LD     (_SET+2),A		;w0 pset
        LD     (BOXC0+1),A		;w0 pset
        POP    BC
        CP     0C0H
        RET    Z
        INC    HL
        RET

		defs  8

; --- $5728 ---
START_0:

ENDIF


MON_END:
DEFS $5800-MON_END


;        ORG    5800H
_START:


;        ORG    5800H

; --------------------------
; MZ-800 BASIC  Main program
; FI:BASIC  ver 1.0A 9.06.84
; Programed by T.Miho
; --------------------------
;
;

defc _BAR    =    0C4H
defc _YEN    =    7DH
defc _POND   =    0FBH

;
_BASIC:
        PUSH   BC
        CALL   CLSHET
        POP    BC
        LD     HL,BASIC_PGM
        LD     (TEXTST),HL
        LD     HL,CLSST
        LD     (SYSSTA),HL
        LD     A,B
        OR     A
COLDRT: JP     Z,_BAS2         ;JP _BAS3  Change
        CP     1
        JR     Z,_BAS2
        LD     HL,ARUN
        LD     DE,INBUFL
        LD     BC,16
        LDIR
_BAS2:  LD     DE,IMDBUF
        RST    3
        DEFB   _CRTMS
        RST    3
        DEFB   _BELL
        LD     A,0C3H
        LD     (COLDRT),A
        LD     HL,_BAS3
        LD     (COLDRT+1),HL
;
_BAS3:  LD     HL,BASIC_PGM
MEMCLI: LD     (HL),0
        INC    HL
        LD     A,H
        CP     0FFH             ;mem max
        JR     C,MEMCLI
        CALL   MEMSET
        CALL   NEWTXT
        CALL   IOINIT
        JR     HOTENT
;
ARUN:   DEFB   15
        DEFM   "RUN \"AUTO RUN\""
        DEFB   0DH
;
;
CLSHET: LD     A,1             ;INIT "CRT:M1"
        RST    3
        DEFB   _DSMOD
        XOR    A
        LD     (PWMODE),A
        INC    A
        LD     (CRTMD2),A
        LD     (CRTMD1),A
        RST    3
        DEFB   _ICRT
        RET
;
CLSST:  CALL   CLSHET
;
HOTENT: LD     HL,ERRORA
        LD     (ERRORP),HL
;
;
OK:
        RST    3
        DEFB   _CR2
        LD     DE,OKMES
        RST    3
        DEFB   _CRTMS
        RST    3
        DEFB   _CR1
INPAGN:
        LD     A,(CONTFG)
        OR     A
        JR     NZ,INPAG2
        LD     SP,(INTFAC)
        LD     HL,0FFFFH
        PUSH   HL
        LD     (STACK),SP
INPAG2: LD     HL,0            ;Set direct-mode
        LD     (LNOBUF),HL
        XOR    A
        LD     (CMTMSG),A
        CALL   AUTODS
        RST    3
        DEFB   _ERCVR          ;FD,QD motor off
        LD     DE,KEYBUF
        RST    3
        DEFB   _GETL
        JR     NC,NORINP
AUTOFF: LD     HL,AUTOFG
        LD     A,(HL)
        OR     A
        LD     (HL),0
        JR     NZ,OK
        JR     INPAGN
;
;
NORINP: CALL   SKPDE
        OR     A
        JR     Z,INPAGN
        CALL   TSTNUM
        JP     NC,EDITOR
        LD     HL,IMDBUF       ;Direct command
        PUSH   HL
        CALL   CVIMTX
        INC    HL
        LD     (NXTLPT),HL
        CALL   LDHL00
        POP    HL
        JR     MAIN
;
; Execute
;
MAIN9:  CALL   ENDZ
;
MAIN:
        LD     (STACK),SP
MAIN0:
        LD     DE,MAIN9
        PUSH   DE
MAIN2:  LD     (TEXTPO),HL
        CALL   BRKCHK
        JP     Z,BREAKZ
MAIN4:  LD     A,(HL)
        INC    HL
        CP     80H
        JR     NC,STATEM
        CP     '\''
        JP     Z,DATA
        CP     ' '
        JR     Z,MAIN4
        CP     ':'
        JR     Z,MAIN2
        OR     A
        JR     Z,ENDLIN        ;END OF LINE
        DEC    HL
        SUB    'A'
        CP     26
        JP     C,LET
        JP     ER01
;
ENDLIN:
        LD     HL,(NXTLPT)
NXLINE:
        LD     E,(HL)
        INC    HL
        LD     D,(HL)
        LD     A,D
        OR     E
        JR     Z,ENDPRG        ;END OF PROGRAM
        LD     (CMTMSG),A
        EX     DE,HL
        ADD    HL,DE
        DEC    HL
        LD     (NXTLPT),HL
        EX     DE,HL
        INC    HL
        CALL   LDDEMI
        LD     (LNOBUF),DE
        CALL   TRDISP
        POP    DE
        JR     MAIN
;
ENDPRG: POP    HL
        CALL   _DIRECT
        JP     Z,OK
        XOR    A
        LD     (CONTFG),A
        LD     A,(ERRORF)
        CP     2
        JP     Z,ER20
        PUSH   HL
        JP     _END             ;end command
;
;
STATEM: CP     0FFH             ;command jp
        JP     Z,PFUNCT
        LD     DE,GJPTBL
        CP     0FEH
        JR     NZ,NROSTM
        LD     A,(HL)
        INC    HL
        JR     MIDFJP
NROSTM: CP     0E0H
        JP     NC,ER01
        LD     DE,SJPTBL
MIDFJP: ADD    A,A
        PUSH   HL
        EX     DE,HL
        LD     E,A
        LD     D,0
        ADD    HL,DE
        LD     A,(HL)
        INC    HL
        LD     H,(HL)
        LD     L,A
        EX     (SP),HL
ENDCHK:
        CALL   HLFTCH
ENDCK0:
        OR     A
        RET    Z
        CP     ':'
        RET
;
_DIRECT:                    ;Direct mode ?
        PUSH   HL
        LD     HL,(LNOBUF)
        LD     A,L
        OR     H
        POP    HL
        RET
;
;
;    TABLE
;
;
CTBL1:
        DEFM   "GOT"        ; 80H
        DEFB   'O'+80H
        DEFM   "GOSU"
        DEFB   'B'+80H

        DEFB   80H

        DEFM   "RU"
        DEFB   'N'+80H
        DEFM   "RETUR"
        DEFB   'N'+80H
        DEFM   "RESTOR"
        DEFB   'E'+80H
        DEFM   "RESUM"
        DEFB   'E'+80H
        DEFM   "LIS"
        DEFB   'T'+80H

        DEFB   80H             ; 88

        DEFM   "DELET"
        DEFB   'E'+80H
        DEFM   "RENU"
        DEFB   'M'+80H
        DEFM   "AUT"
        DEFB   'O'+80H
        DEFM   "EDI"
        DEFB   'T'+80H
        DEFM   "FO"
        DEFB   'R'+80H
        DEFM   "NEX"
        DEFB   'T'+80H
        DEFM   "PRIN"
        DEFB   'T'+80H
;
        DEFB   80H             ; 90

        DEFM   "INPU"
        DEFB   'T'+80H
        DEFB   80H
        DEFM   "I"
        DEFB   'F'+80H
        DEFM   "DAT"
        DEFB   'A'+80H
        DEFM   "REA"
        DEFB   'D'+80H
        DEFM   "DI"
        DEFB   'M'+80H
        DEFM   "RE"
        DEFB   'M'+80H

        DEFM   "EN"            ; 98
        DEFB   'D'+80H
        DEFM   "STO"
        DEFB   'P'+80H
        DEFM   "CON"
        DEFB   'T'+80H
        DEFM   "CL"
        DEFB   'S'+80H
        DEFB   80H
        DEFM   "O"
        DEFB   'N'+80H
        DEFM   "LE"
        DEFB   'T'+80H
        DEFM   "NE"
        DEFB   'W'+80H
;
        DEFM   "POK"
        DEFB   'E'+80H           ; A0
        DEFM   "OF"
        DEFB   'F'+80H
        DEFM   "PMOD"
        DEFB   'E'+80H
        DEFM   "PSKI"
        DEFB   'P'+80H
        DEFM   "PLO"
        DEFB   'T'+80H
        DEFM   "PLIN"
        DEFB   'E'+80H
        DEFM   "RLIN"
        DEFB   'E'+80H
        DEFM   "PMOV"
        DEFB   'E'+80H

        DEFM   "RMOV"
        DEFB   'E'+80H          ; A8
        DEFM   "TRO"
        DEFB   'N'+80H
        DEFM   "TROF"
        DEFB   'F'+80H
        DEFM   "INP"
        DEFB   '@'+80H
        DEFM   "DEFAUL"
        DEFB   'T'+80H
        DEFM   "GE"
        DEFB   'T'+80H
        DEFM   "PCOLO"
        DEFB   'R'+80H
        DEFM   "PHOM"
        DEFB   'E'+80H
;
        DEFM   "HSE"
        DEFB   'T'+80H           ; B0
        DEFM   "GPRIN"
        DEFB   'T'+80H
        DEFM   "KE"
        DEFB   'Y'+80H
        DEFM   "AXI"
        DEFB   'S'+80H
        DEFM   "LOA"
        DEFB   'D'+80H
        DEFM   "SAV"
        DEFB   'E'+80H
        DEFM   "MERG"
        DEFB   'E'+80H
        DEFM   "CHAI"
        DEFB   'N'+80H

        DEFM   "CONSOL"
        DEFB   'E'+80H        ; B8
        DEFM   "SEARC"
        DEFB   'H'+80H
        DEFM   "OUT"
        DEFB   '@'+80H
        DEFM   "PCIRCL"
        DEFB   'E'+80H
        DEFM   "PTES"
        DEFB   'T'+80H
        DEFM   "PAG"
        DEFB   'E'+80H
        DEFM   "WAI"
        DEFB   'T'+80H


IF RAMDISK
        DEFB   80H

        DEFM   "VRA"          ; C0
        DEFB   'M'+80H
ELSE
        DEFM   "SWA"
        DEFB   'P'+80H

        DEFB   80H             ; C0
ENDIF

        DEFM   "ERRO"
        DEFB   'R'+80H
        DEFM   "ELS"
        DEFB   'E'+80H
        DEFM   "US"
        DEFB   'R'+80H
        DEFM   "BY"
        DEFB   'E'+80H

        DEFB   80H
        DEFB   80H

        DEFM   "DE"
        DEFB   'F'+80H

        DEFB   80H             ; C8
        DEFB   80H

        DEFM   "LABE"
        DEFB   'L'+80H

        DEFB   80H
        DEFB   80H
        DEFB   80H

        DEFM   "WOPE"
        DEFB   'N'+80H
        DEFM   "CLOS"
        DEFB   'E'+80H
;
        DEFM   "ROPE"
        DEFB   'N'+80H
;

IF RAMDISK
        DEFB   80H

        DEFM   "SPEC"
        DEFB   'G'+80H

ELSE
        DEFM   "XOPE"
        DEFB   'N'+80H

        DEFB   80H
ENDIF

        DEFB   80H
        DEFB   80H

        DEFM   "DI"
        DEFB   'R'+80H

        DEFB   80H
        DEFB   80H

        DEFM   "RENAM"
        DEFB   'E'+80H
        DEFM   "KIL"
        DEFB   'L'+80H

IF RAMDISK
        DEFB   80H
        DEFB   80H

        DEFM   "INI"
        DEFB   'T'+80H
        DEFM   "FAS"
        DEFB   'T'+80H
        DEFM   "SCREE"
        DEFB   'N'+80H
ELSE
        DEFM   "LOC"
        DEFB   'K'+80H
        DEFM   "UNLOC"
        DEFB   'K'+80H
        DEFM   "INI"
        DEFB   'T'+80H

        DEFB   80H
        DEFB   80H
ENDIF

        DEFB   80H
;
        DEFM   "T"
        DEFB   'O'+80H
        DEFM   "STE"
        DEFB   'P'+80H
        DEFM   "THE"
        DEFB   'N'+80H
        DEFM   "USIN"
        DEFB   'G'+80H

        DEFB   80H             ;PI

        DEFM   "AL"
        DEFB   'L'+80H
        DEFM   "TA"
        DEFB   'B'+80H
        DEFM   "SP"
        DEFB   'C'+80H

        DEFB   80H             ; E8
        DEFB   80H
        DEFM   ".XO"
        DEFB   'R'+80H
        DEFM   ".O"
        DEFB   'R'+80H
        DEFM   ".AN"
        DEFB   'D'+80H
        DEFM   ".NO"
        DEFB   'T'+80H
        DEFM   ">"
        DEFB   '<'+80H
        DEFM   "<"
        DEFB   '>'+80H
;
        DEFM   "="
        DEFB   '<'+80H             ; F0
        DEFM   "<"
        DEFB   '='+80H
        DEFM   "="
        DEFB   '>'+80H
        DEFM   ">"
        DEFB   '='+80H
        DEFB   '='+80H
        DEFB   '>'+80H
        DEFB   '<'+80H
        DEFB   '+'+80H
        DEFB   '-'+80H         ; F8
        DEFB   _YEN+80H
        DEFM   ".MO"
        DEFB   'D'+80H
        DEFB   '/'+80H
        DEFB   '*'+80H
        DEFB   '^'+80H
;
        DEFB   0FFH
;


GTABL:
        DEFB   80H             ; FE 80


IF RAMDISK
        DEFM   "SYN"
        DEFB   'C'+80H
        DEFM   "BORDE"
        DEFB   'R'+80H
        DEFM   "SCROL"
        DEFB   'L'+80H
ELSE
        DEFM   "CSE"
        DEFB   'T'+80H
        DEFM   "CRESE"
        DEFB   'T'+80H
        DEFM   "CCOLO"
        DEFB   'R'+80H
ENDIF
        DEFB   80H
        DEFB   80H
        DEFB   80H
        DEFB   80H

        DEFB   80H             ; FE 88
        DEFB   80H
        DEFM   "SOUN"
        DEFB   'D'+80H
        DEFB   80H
        DEFM   "NOIS"
        DEFB   'E'+80H
        DEFM   "BEE"
        DEFB   'P'+80H
        DEFB   80H             ; MZ-1500 VOICE
        DEFB   80H
;
        DEFM   "COLO"
        DEFB   'R'+80H          ; FE 90
        DEFB   80H             ; MZ-1500 PRTY
        DEFM   "SE"
        DEFB   'T'+80H
        DEFM   "RESE"
        DEFB   'T'+80H
        DEFM   "LIN"
        DEFB   'E'+80H
        DEFM   "BLIN"
        DEFB   'E'+80H
        DEFM   "PA"
        DEFB   'L'+80H
        DEFM   "CIRCL"
        DEFB   'E'+80H

        DEFM   "BO"
        DEFB   'X'+80H            ; FE 98
        DEFM   "PAIN"
        DEFB   'T'+80H
        DEFM   "POSITIO"
        DEFB   'N'+80H
        DEFM   "PATTER"
        DEFB   'N'+80H
        DEFM   "HCOP"
        DEFB   'Y'+80H

        DEFB   80H             ; MZ-1500 KPATTERN
        DEFB   80H             ; MZ-1500 FPRINT
        DEFB   80H

;
        DEFM   "SYMBO"
        DEFB   'L'+80H         ; FE A0
        DEFB   80H
        DEFM   "MUSI"
        DEFB   'C'+80H
        DEFM   "TEMP"
        DEFB   'O'+80H
        DEFM   "CURSO"
        DEFB   'R'+80H
        DEFM   "VERIF"
        DEFB   'Y'+80H
        DEFM   "CL"
        DEFB   'R'+80H
        DEFM   "LIMI"
        DEFB   'T'+80H

        DEFB   80H             ; FE A8
        DEFB   80H
        DEFB   80H
        DEFB   80H
        DEFB   80H
        DEFB   80H
        DEFM   "BOO"
        DEFB   'T'+80H
;
;
        DEFB   0FFH
;
;
;
CTBL2:
        DEFM   "IN"
        DEFB   'T'+80H            ; FF 80
        DEFM   "AB"
        DEFB   'S'+80H
        DEFM   "SI"
        DEFB   'N'+80H
        DEFM   "CO"
        DEFB   'S'+80H
        DEFM   "TA"
        DEFB   'N'+80H
        DEFM   "L"
        DEFB   'N'+80H
        DEFM   "EX"
        DEFB   'P'+80H
        DEFM   "SQ"
        DEFB   'R'+80H

        DEFM   "RN"
        DEFB   'D'+80H            ; FF 88
        DEFM   "PEE"
        DEFB   'K'+80H
        DEFM   "AT"
        DEFB   'N'+80H
        DEFM   "SG"
        DEFB   'N'+80H
        DEFM   "LO"
        DEFB   'G'+80H
        DEFM   "FRA"
        DEFB   'C'+80H
        DEFM   "PA"
        DEFB   'I'+80H
        DEFM   "RA"
        DEFB   'D'+80H
;
        DEFB   80H             ; FF 90
        DEFB   80H
        DEFB   80H
        DEFB   80H
        DEFB   80H
        DEFB   80H
        DEFB   80H
        DEFB   80H
        DEFB   80H             ; FF 98
        DEFB   80H
        DEFB   80H
        DEFB   80H
        DEFM   "STIC"
        DEFB   'K'+80H
        DEFM   "STRI"
        DEFB   'G'+80H
        DEFB   80H             ; MZ-1500 JOY
        DEFB   80H
;
        DEFM   "CHR"
        DEFB   '$'+80H
        DEFM   "STR"
        DEFB   '$'+80H
        DEFM   "HEX"
        DEFB   '$'+80H
        DEFB   80H
        DEFB   80H
        DEFB   80H
        DEFB   80H
        DEFB   80H
        DEFM   "SPACE"
        DEFB   '$'+80H
        DEFB   80H
        DEFB   80H             ; MZ-1500 ASCCHR$
        DEFM   "AS"
        DEFB   'C'+80H
        DEFM   "LE"
        DEFB   'N'+80H
        DEFM   "VA"
        DEFB   'L'+80H
        DEFB   80H
        DEFB   80H
;
        DEFB   80H             ; FF B0
        DEFB   80H
        DEFB   80H             ; MZ-1500 HEXCHR$
        DEFM   "ER"
        DEFB   'N'+80H
        DEFM   "ER"
        DEFB   'L'+80H
        DEFM   "SIZ"
        DEFB   'E'+80H
        DEFM   "CSR"
        DEFB   'H'+80H
        DEFM   "CSR"
        DEFB   'V'+80H
        DEFM   "POS"
        DEFB   'H'+80H
        DEFM   "POS"
        DEFB   'V'+80H
        DEFM   "LEFT"
        DEFB   '$'+80H
        DEFM   "RIGHT"
        DEFB   '$'+80H
        DEFM   "MID"
        DEFB   '$'+80H
        DEFB   80H             ; MZ-1500 FONT$
        DEFB   80H
        DEFB   80H
;
        DEFB   80H             ; FF C0
        DEFB   80H
        DEFB   80H
        DEFB   80H
        DEFM   "TI"
        DEFB   '$'+80H
        DEFM   "POIN"
        DEFB   'T'+80H
        DEFM   "EO"
        DEFB   'F'+80H
        DEFM   "F"
        DEFB   'N'+80H
;
        DEFB   0FFH
;
; JPTABLE
;
SJPTBL:
        DEFW   GOTO            ; 80
        DEFW   GOSUB
        DEFW   ER01
        DEFW   RUN
        DEFW   RETURN
        DEFW   RESTOR
        DEFW   RESUME
        DEFW   LIST
        DEFW   ER01            ; 88
        DEFW   DELETE
        DEFW   RENUM
        DEFW   AUTO
        DEFW   EDIT
        DEFW   FOR
        DEFW   NEXT
        DEFW   PRINT
;
        DEFW   ER01            ; 90
        DEFW   INPUT
        DEFW   ER01
        DEFW   _IF
        DEFW   DATA
        DEFW   READ
        DEFW   DIM
        DEFW   REM
        DEFW   _END             ; 98
        DEFW   STOP
        DEFW   CONT
        DEFW   CLS
        DEFW   ER01
        DEFW   ON
        DEFW   LET
        DEFW   NEW
;
        DEFW   POKE            ; A0
        DEFW   ER01
        DEFW   MODE
        DEFW   SKIP
        DEFW   PLOT
        DEFW   PLINE
        DEFW   RLINE
        DEFW   PMOVE
        DEFW   RMOVE           ; A8
        DEFW   TRON
        DEFW   TROFF
        DEFW   INP_
        DEFW   DEFAULT
        DEFW   GETOP
        DEFW   PCOLOR
        DEFW   PHOME
;
        DEFW   HSET            ; B0
        DEFW   GPRINT
        DEFW   KLIST
        DEFW   AXIS
;IF MOD_B
;        DEFW   LOAD+1	; ???
;ELSE
        DEFW   LOAD
;ENDIF
        DEFW   SAVE
        DEFW   MERGE
        DEFW   CHAIN
        DEFW   CONSOL          ; B8
        DEFW   SEARCH
        DEFW   OUT_
        DEFW   PCIRCLE
        DEFW   TEST
        DEFW   PAGE
        DEFW   PAUSE
        DEFW   SWAP            ; <- with a RAMDISK mod, the 'SWAP' keyword is not defined
;
IF RAMDISK
        DEFW   VRAM            ; C0
ELSE
        DEFW   ER01            ; C0
ENDIF
        DEFW   ERROR
        DEFW   _ELSE
        DEFW   USR
        DEFW   BYE
        DEFW   ER01
        DEFW   ER01
        DEFW   DEFOP
        DEFW   ER01            ; C8
        DEFW   ER01
        DEFW   LABEL
        DEFW   ER01
        DEFW   ER01
        DEFW   ER01
        DEFW   WOPEN
        DEFW   CLOSE
;
        DEFW   ROPEN           ; D0
        DEFW   XOPEN           ; <- with a RAMDISK mod, this keyword is not defined
IF RAMDISK
        DEFW   SPECG
ELSE
        DEFW   ER01
ENDIF
        DEFW   ER01
        DEFW   ER01
        DEFW   DIR
        DEFW   ER01
        DEFW   ER01
        DEFW   RENAME          ; D8
        DEFW   KILL

        DEFW   LOCK            ; <- with a RAMDISK mod, this keyword is not defined
        DEFW   UNLOCK          ; <- with a RAMDISK mod, this keyword is not defined
        DEFW   INIT
IF RAMDISK
		DEFW   FAST
		DEFW   SCREEN
ELSE
        DEFW   ER01
        DEFW   ER01
ENDIF
        DEFW   ER01
;
;
GJPTBL:
        DEFW   ER01            ; FE 80

IF RAMDISK
        DEFW   SYNC
        DEFW   BORDER
        DEFW   SCROLL
ELSE
        DEFW   ER01           ; CSET
        DEFW   ER01           ; CRESET
        DEFW   ER01           ; CCOLOR
ENDIF
        DEFW   ER01
        DEFW   ER01
        DEFW   ER01
        DEFW   ER01
        DEFW   ER01            ; FE 88
        DEFW   ER01
        DEFW   SOUND
        DEFW   ER01
        DEFW   NOISE
        DEFW   BEEP
; MZ-1500 .VOICE:
        DEFW   ER01
        DEFW   ER01
;
        DEFW   COLOR           ; FE 90
        DEFW   ER01
        DEFW   SET
        DEFW   RESET
        DEFW   LINE
        DEFW   BLINE
        DEFW   PALET
        DEFW   CIRCLE
        DEFW   BOX             ; FE 98
        DEFW   PAINT
        DEFW   POSITI        ; POSITION
        DEFW   PATTER        ; PATTERN
        DEFW   HCOPY
        DEFW   ER01
        DEFW   ER01
        DEFW   ER01
;
        DEFW   SMBOL           ; FE A0
        DEFW   ER01
        DEFW   MUSIC
        DEFW   TEMPO
        DEFW   CURSOR_
        DEFW   VERIFY
        DEFW   CLR
        DEFW   LIMIT
        DEFW   ER01            ; FE A8
        DEFW   ER01
        DEFW   ER01
        DEFW   ER01
        DEFW   ER01
        DEFW   ER01
        DEFW   BOOT
;
;
FJPTBL:
        DEFW   INTOPR          ; FF 80
        DEFW   ABS
        DEFW   SIN
        DEFW   COS
        DEFW   TAN
        DEFW   LOG             ;LN
        DEFW   EXP
        DEFW   SQR
        DEFW   RND             ; FF 88
        DEFW   PEEK
        DEFW   ATN
        DEFW   SGN
        DEFW   LOGD            ;LOG
        DEFW   FRACT
        DEFW   PAI
        DEFW   RAD
;
        DEFW   ER01            ; FF 90
        DEFW   ER01
        DEFW   ER01
        DEFW   ER01
        DEFW   ER01
        DEFW   ER01
        DEFW   ER01
        DEFW   ER01
        DEFW   ER01            ; FF 98
        DEFW   ER01
        DEFW   ER01
        DEFW   ER01
        DEFW   STCK
        DEFW   STIG
        DEFW   ER01
        DEFW   ER01
;
        DEFW   ER01            ; FF A0 CHR$
        DEFW   STR_S
        DEFW   HEX_S
        DEFW   ER01
        DEFW   ER01
        DEFW   ER01
        DEFW   ER01
        DEFW   ER01
        DEFW   SPACE_S          ; FF A8
        DEFW   ER01
        DEFW   ER01
        DEFW   ASC
        DEFW   LEN
        DEFW   VAL
        DEFW   ER01
        DEFW   ER01
;
        DEFW   ER01            ; FF B0
        DEFW   ER01
        DEFW   ER01
        DEFW   ERR
        DEFW   ERL
        DEFW   SIZE
        DEFW   CSRH
        DEFW   CSRV
        DEFW   POSH            ; FF B8
        DEFW   POSV
        DEFW   LEFT_S
        DEFW   RIGHT_S
        DEFW   MID_S
        DEFW   ER01
        DEFW   ER01
        DEFW   ER01
;
        DEFW   ER01            ; FF C0
        DEFW   ER01
        DEFW   ER01
        DEFW   ER01
        DEFW   TI_S
        DEFW   POINT
        DEFW   EOF
        DEFW   FNEXP           ;FN
        DEFW   ER01            ; FF C8
        DEFW   ER01
        DEFW   ER01
        DEFW   ER01
        DEFW   ER01
        DEFW   ER01
        DEFW   ER01
        DEFW   ER01
;
; GET LINE ADRS
;
GETLIN:
        CALL   TEST1
        DEFB   0CH
        JR     NZ,GLIN2
        CALL   LDDEMI
        OR     0FFH
        RET
GLIN2:  INC    HL
        CP     0BH
        JR     NZ,GLIN4
        LD     E,(HL)
        INC    HL
        LD     D,(HL)
        INC    HL
        LD     A,E
        OR     D
        RET    Z
        EX     DE,HL
        CALL   LNOSER
        JP     C,ER16
        EX     DE,HL
        DEC    HL
        LD     (HL),D
        DEC    HL
        LD     (HL),E
        DEC    HL
        LD     (HL),0CH
        INC    HL
        INC    HL
        INC    HL
        OR     0FFH
        LD     (REFFLG),A
        RET
GLIN4:  CP     '"'
        JP     NZ,ER01
        LD     (LABA+1),HL
        LD     B,0
GLIN6:  LD     A,(HL)
        OR     A
        JR     Z,GLIN8
        INC    HL
        CP     '"'
        JR     Z,GLIN8
        INC    B
        JR     GLIN6
GLIN8:  LD     A,B
        OR     A
        JP     Z,ER01
        LD     (LABN+1),A
        EX     DE,HL
        CALL   LABSER
        JP     C,ER16
        EX     DE,HL
        OR     0FFH
        RET
;
; LABSER .. Label search
; LNOSER .. Line# search
;
LABSER: PUSH   BC
        LD     BC,LABSUB
        JR     LNOSR0
LNOSER: PUSH   BC
        LD     BC,LNOSUB
LNOSR0: LD     (LNOSR_+1),BC
        PUSH   DE
        EX     DE,HL
        LD     HL,(TEXTST)
LNOSR2: LD     C,(HL)
        INC    HL
        LD     B,(HL)
        LD     A,B
        OR     C
        SCF
        JR     Z,LNOSR9
        DEC    HL
        PUSH   HL
        ADD    HL,BC
        EX     (SP),HL
LNOSR_: CALL   0
        JR     C,LNOSR8
        JR     Z,LNOSR8
        POP    HL
        JR     LNOSR2
LNOSR8: POP    DE              ;DMY
LNOSR9: POP    DE
        POP    BC
        RET
;
LNOSUB: INC    HL
        INC    HL
        INC    HL
        LD     A,D
        CP     (HL)
        RET    NZ
        DEC    HL
        LD     A,E
        CP     (HL)
        DEC    HL
        DEC    HL
        RET
;
LABSUB: PUSH   HL
        INC    HL
        INC    HL
        INC    HL
        INC    HL
        CALL   TEST1
        DEFB   0CAH             ;LABEL
        JR     NZ,LABSR9
        CALL   TEST1
        DEFB   '"'
        JR     NZ,LABSR9
LABN:   LD     B,0             ;Label length
LABA:   LD     DE,0            ;Label adrs
LABSR2: LD     A,(DE)
        CP     (HL)
        JR     NZ,LABSR9
        INC    HL
        INC    DE
       DJNZ   LABSR2
        LD     A,(HL)
        CP     '"'
        JR     Z,LABSR9
        OR     A
LABSR9: SCF
        CCF
        POP    HL
        RET
;
; START.LINE - END.LINE
;
GTSTED:
        LD     DE,0000H
        LD     BC,0FFFFH
        CALL   END2C
        RET    Z
        CP     '-'
        JR     Z,GTNXNM
        CP     '.'
        LD     DE,(EDLINE)
        JR     Z,NX2C2D
        CALL   TESTX
        DEFB   0BH
        LD     E,(HL)
        INC    HL
        LD     D,(HL)
NX2C2D: INC    HL
        CALL   END2C
        JR     Z,ONELLN
        CP     '-'
        JR     Z,GTNXNM
ONELLN: LD     C,E
        LD     B,D
        RET
;
GTNXNM: INC    HL
        CALL   END2C
        RET    Z
        CP     '.'
        JR     NZ,GTEDNO
        LD     BC,(EDLINE)
        INC    HL
        RET
;
GTEDNO:
        CALL   TESTX
        DEFB   0BH
        LD     C,(HL)
        INC    HL
        LD     B,(HL)
        INC    HL
        RET
;
END2C:
        CALL   ENDCHK
        RET    Z
        CP     ','
        RET
;
;  REFADR ... Line ref = Adrs
;  REFLNO ... Line ref = Number
;
REFADR: CALL   PUSHR
        LD     A,0FFH
        LD     (REFFLG),A
        LD     HL,CVASUB
        JR     REFL2
;
REFLNO:
        CALL   PUSHR
        CALL   CLRFLG
REFLNX:
        LD     A,(REFFLG)
        OR     A
        RET    Z
        XOR    A
        LD     (REFFLG),A
        LD     HL,CVLSUB
REFL2:  LD     (CVRTLN+1),HL
        LD     HL,(TEXTST)
        DEC    HL
REFL4:  INC    HL
        LD     A,(HL)
        INC    HL
        OR     (HL)
        RET    Z
        INC    HL
        LD     E,(HL)
        INC    HL
        LD     D,(HL)
        LD     (CVALN+1),DE
REFL6:  CALL   IFSKSB
        OR     A
        JR     Z,REFL4
CVRTLN: JP     0
;
CVLSUB: CP     0CH
        JR     NZ,REFL6
        DEC    HL
        LD     E,(HL)
        INC    HL
        LD     D,(HL)
        PUSH   HL
        EX     DE,HL
        INC    HL
        INC    HL
        LD     E,(HL)
        INC    HL
        LD     D,(HL)
        POP    HL
        LD     (HL),D
        DEC    HL
        LD     (HL),E
        DEC    HL
        LD     (HL),0BH
        INC    HL
        INC    HL
        JR     REFL6
;
CVASUB: CP     0BH
        JR     NZ,REFL6
        DEC    HL
        PUSH   HL
        CALL   INDRCT
        LD     E,L
        LD     D,H
        LD     A,L
        OR     H
        JR     Z,CVAS9
        CALL   LNOSER
        JR     C,CVASE
        EX     DE,HL
        POP    HL
        DEC    HL
        LD     (HL),0CH
        INC    HL
        LD     (HL),E
        INC    HL
        LD     (HL),D
        JR     REFL6
;
CVASE:  PUSH   DE
        LD     A,16            ;UNDEF LINE
        RST    3
        DEFB   _ERRX
        LD     A,' '
        RST    3
        DEFB   _CRT1C
        POP    HL
        CALL   ASCFIV
        RST    3
        DEFB   _CRTMS
CVALN:  LD     HL,0            ;xxx
        CALL   P_ERL
        RST    3
        DEFB   _CR2
CVAS9:  POP    HL
        INC    HL
        JR     REFL6
;
REFFLG: DEFB   0
EDITOR:
        RST    3
        DEFB   _CLRIO
        CALL   REFLNO
        CALL   CVBCAS
        LD     A,B
        OR     C
        JP     Z,INPAGN
        LD     (EDLINE),BC
        LD     A,(DE)
        CP     20H
        JR     NZ,$+3
        INC    DE
        PUSH   AF
        LD     HL,IMDBUF
        CALL   CVIMTX
        PUSH   HL
        LD     HL,(EDLINE)
        LD     E,L
        LD     D,H
        CALL   DELSUB
        POP    HL              ; END POINT
        POP    AF
        OR     A
        JR     Z,EDIT9
        LD     DE,IMDBUF
        OR     A
        SBC    HL,DE
        LD     DE,5
        ADD    HL,DE
        LD     BC,HL
        LD     HL,IMDBUF
        CALL   INSTLIN
EDIT9:  LD     A,(AUTOFG)
        OR     A
        JP     Z,INPAGN
        LD     DE,(EDSTEP)
        LD     HL,(EDLINE)
        ADD    HL,DE
        LD     (EDLINE),HL
        JP     NC,INPAGN
        JP     AUTOFF
;
; INSTLIN  HL .. IMD ADRS
;          BC .. IMD LENGTH
;
INSTLIN:
        LD     (INS_P+1),HL
        PUSH   BC
        LD     BC,(EDLINE)
        LD     HL,(TEXTST)
        JR     INSL4
INSL2:  CALL   LDDEMD
        ADD    HL,DE
INSL4:  CALL   LDDEMD
        LD     A,D
        OR     E
        JR     Z,INSL6
        INC    HL
        INC    HL
        CALL   LDDEMD
        EX     DE,HL
        SBC    HL,BC
        DEC    DE
        DEC    DE
        EX     DE,HL
        JR     C,INSL2
INSL6:  POP    DE              ;DE:=open bytes
        PUSH   HL              ;Push inst-point
        PUSH   DE
        LD     HL,40           ;memory check ofset
        ADD    HL,DE
        LD     BC,(VARED)
        LD     (TMPEND),BC
        ADD    HL,BC
        JP     C,ER06_
        EX     DE,HL
        CALL   MEMECK
        POP    DE              ;DE=open bytes
        RST    3
        DEFB   _ADDP0
        POP    HL              ;HL=inst point
        PUSH   DE              ;DE=open bytes
        PUSH   BC
        EX     (SP),HL         ;HL=old VARED
        POP    BC              ;BC=inst point
        PUSH   HL
        OR     A
        SBC    HL,BC
        LD     BC,HL           ;BC=xfer bytes
        POP    HL              ;HL=old VARED
        LD     DE,(VARED)      ;DE=new VARED
        INC    BC
        LDDR
        INC    HL              ;HL=inst point
        POP    BC              ;BC=open bytes
        LD     (HL),C
        INC    HL
        LD     (HL),B
        INC    HL
        LD     DE,(EDLINE)
        LD     (HL),E
        INC    HL
        LD     (HL),D
        INC    HL
        EX     DE,HL
INS_P:  LD     HL,IMDBUF       ;xxx
        DEC    BC
        DEC    BC
        DEC    BC
        DEC    BC
        LDIR
        RET
;
RUN:    JR     Z,RUN0          ;RUN
        CALL   LINE_2
        JP     Z,GOTO          ;RUN linenumber
        JP     FRUN            ;RUN "filename"
RUN0:   CALL   CLR
RUNX:
        CALL   RUNINT
        LD     DE,(TEXTST)
        LD     SP,(INTFAC)
        LD     HL,0FFFFH
        PUSH   HL
        PUSH   HL
        EX     DE,HL
        JP     NXLINE
;
RUNINT:
        PUSH   HL
        CALL   CLRFLG
        LD     (AUTOFG),A
        LD     HL,10
        LD     (EDLINE),HL
        LD     (EDSTEP),HL
        POP    HL
        RET
;
CLRFLG:
        LD     HL,0
        LD     (ERRLNO),HL
        XOR    A
        LD     (DATFLG),A
        LD     (CONTFG),A
        LD     (ERRORF),A
        LD     (ERRCOD),A
        LD     (LSWAP),A
        RET
;
;
;
_END:    LD     A,(LSWAP)
        OR     A
        JP     NZ,BSWAP
        RST    3
        DEFB   _CLRIO          ;END command
        XOR    A
        LD     (CONTFG),A
        POP    BC
        JP     OK

;
AUTO:   CALL   CKCOM
        LD     DE,10           ;AUTO start,step
        LD     BC,10
        JR     Z,AUTO6
        CP     ','
        JR     NZ,AUTO2
        INC    HL
        CALL   IDEEXP
        LD     B,D
        LD     C,E
        LD     DE,10
        JR     AUTO6
;
AUTO2:  CP     '.'
        LD     DE,(EDLINE)
        JR     Z,AUTO4
        CP     0BH
        JP     NZ,ER01
        INC    HL
        LD     E,(HL)
        INC    HL
        LD     D,(HL)
;
AUTO4:  INC    HL
        CALL   TEST1
        DEFB   ","
        JR     NZ,AUTO6
        PUSH   DE
        CALL   IDEEXP
        LD     C,E
        LD     B,D
        POP    DE
AUTO6:  CALL   ENDZ
        LD     A,C
        OR     B
        JP     Z,ER03__
;
        LD     (EDLINE),DE
        LD     (EDSTEP),BC
        LD     A,1
        LD     (AUTOFG),A
        POP    AF
        JP     INPAGN
;
AUTOFG: DEFS   1
;
AUTODS: LD     A,(AUTOFG)      ;Disp auto line
        OR     A
        RET    Z
        XOR    A
        JR     EDITL
;
EDIT:   CALL   EDITL           ;EDIT linenumber
        JP     INPAGN
;
EDITL:  LD     DE,(EDLINE)
        CALL   NZ,GTSTED
        PUSH   DE
        EX     DE,HL
        CALL   LNOSER
        POP    DE
        INC    HL
        INC    HL
        INC    HL
        INC    HL
        JR     NC,$+5
        LD     HL,NOTXT
        EX     DE,HL
        PUSH   DE
        LD     (EDLINE),HL
        CALL   ASCFIV
        RST    3
        DEFB   _CRTMS
        LD     A,' '
        RST    3
        DEFB   _CRT1C
        POP    HL
        LD     DE,KEYBUF
        PUSH   DE
        CALL   CVTXIM
        POP    DE
        LD     B,0
EDL2:   LD     A,(DE)
        OR     A
        JR     Z,EDL6
        INC    B
        RST    3
        DEFB   _CRT1X
        INC    DE
        JR     EDL2
EDL6:   LD     A,B
        OR     A
        RET    Z
        LD     A,14H           ; CURSOR BACK
        RST    3
        DEFB   _CRT1C
        DJNZ   $-3
        RET
;
MEMSET:
        PUSH   DE
        LD     DE,-16
        ADD    HL,DE
        POP    DE
        LD     (MEMLMT),HL
        DEC    H
        LD     (INTFAC),HL
        XOR    A
        LD     (LSWAP),A
        RET
;
NEWTXT:
        LD     HL,(TEXTST)
        CALL   LDHL00
        LD     (POOL),HL
        CALL   RUNINT
        JR     CLR
;
NEW:
        CALL   TEST1
        DEFB   9DH             ;NEW command
        CALL   Z,NEWON
        CALL   NEWTXT
        JP     HOTENT
;
;
CLR:                    ;CLR command
        PUSH   HL
        CALL   CLPTR2
        POP    HL
        RST    3
        DEFB   _CLRIO
        RET
;
CLPTR:
        LD     HL,(TEXTST)
        CALL   LDHL00
        LD     (POOL),HL
CLPTR2: LD     HL,(POOL)
        LD     (HL),0
        INC    HL
        LD     (VARST),HL          ;Variable start <> POOL END
        LD     (HL),0
        INC    HL
        LD     (STRST),HL
        CALL   LDHL00
        LD     (VARED),HL
        LD     (TMPEND),HL
        RET
;
LDHL00:
        LD     (HL),0
        INC    HL
        LD     (HL),0
        INC    HL
        RET
;
;
TRON:   CALL   ENDCHK
        LD     A,1
        JR     Z,TROFF+1
        CALL   TESTX
        DEFB   0FBH             ;/
        CALL   TESTX
        DEFB   'P'
        LD     A,2
        JR     $+3
TROFF:  XOR    A               ;TROFF
        LD     (TRDISP+1),A
        RET
;
TRDISP: LD     A,0             ;0,1,2
        OR     A
        RET    Z
        DEC    A
        LD     (FILOUT),A
        JR     Z,TRDSP2
        LD     A,(PNMODE)
        CP     2
        JR     Z,TRDSP9        ;MODE GR
TRDSP2: PUSH   HL
        LD     A,'['
        RST    3
        DEFB   _1C
        LD     HL,(LNOBUF)
        CALL   ASCFIV
        RST    3
        DEFB   _MSG
        LD     A,']'
        RST    3
        DEFB   _1C
        POP    HL
TRDSP9: XOR    A
        LD     (FILOUT),A
        RET
;
DELETE: CALL   END2C
        JP     Z,ER01          ;DELETE
        CALL   LINE_2
        JR     Z,DELLIN
        CP     '-'
        JR     Z,DELLIN
        CP     '.'
        JP     NZ,FDEL         ;DELETE "filename"
DELLIN:
        CALL   GTSTED          ;DELETE xxx-yyy
        EX     DE,HL
        LD     E,C
        LD     D,B
        CALL   DELSUB
        JP     OK
;
; Delete (HL)-(DE)
;
DELSUB:
        PUSH   AF
        PUSH   BC
        PUSH   HL
        PUSH   DE
        CALL   REFLNO
        LD     C,L
        LD     B,H
        LD     HL,(TEXTST)
FSTLOP: CALL   LDDEMI
        LD     A,E
        OR     D
        JR     NZ,FDDLST
RTDLTE: POP    DE
        POP    HL
        POP    BC
        POP    AF
        RET
;
POPDLR: POP    DE
        JR     RTDLTE
;
FDDLST: EX     DE,HL
        ADD    HL,DE
        DEC    HL
        DEC    HL
        EX     DE,HL
        PUSH   DE
        LD     E,(HL)
        INC    HL
        LD     D,(HL)
        EX     DE,HL
        LD     (LNOTBF),HL
        SBC    HL,BC
        POP    HL
        JR     C,FSTLOP
        DEC    DE
        DEC    DE
        DEC    DE
        POP    BC              ; DELSUB END LINE NO.
        PUSH   BC
        PUSH   DE              ; DELSUB START ADRS
        PUSH   HL              ; NEXT LINE ADRS
        DEFB   21H
LNOTBF: DEFS   2
        SBC    HL,BC
        POP    HL
        JR     Z,DLSTRT        ; DEL-LINE END FOUND
        JR     NC,POPDLR       ; NOTHING OCCUR
SNDDLP: CALL   LDDEMI
        LD     A,D
        OR     E
        JR     Z,DLEFD_
        EX     DE,HL
        ADD    HL,DE
        EX     DE,HL
        DEC    DE
        DEC    DE
        PUSH   DE
        LD     E,(HL)
        INC    HL
        LD     D,(HL)
        EX     DE,HL
        SBC    HL,BC
        POP    HL
        JR     C,SNDDLP
        JR     Z,DLSTRT
        EX     DE,HL
        DEC    HL
DLEFD_: DEC    HL
        DEC    HL
DLSTRT: POP    DE
        PUSH   DE              ;Delete (DE)-(HL)
        PUSH   HL
        OR     A
        EX     DE,HL
        SBC    HL,DE
        EX     DE,HL           ;DE = - bytes
        LD     BC,(VARED)      ;old VARED
        RST    3
        DEFB   _ADDP0
        POP    DE              ;DE = del end
        LD     HL,BC           ;HL = old VARED
        OR     A
        SBC    HL,DE
        LD     BC,HL           ;BC = move bytes
        EX     DE,HL           ;HL = del end
        POP    DE              ;DE = del start
        LDIR
        JR     RTDLTE
;
IDEEX0: CALL   IDEEXP
        LD     A,D
        OR     E
        RET    NZ
       JP     ER03__
;
RENUM:  CALL   CKCOM
        LD     DE,10           ;RENUM xxx,yyy,zzz
        LD     (NEWNO),DE
        LD     (ADDNO),DE
        LD     E,0
        LD     (STLNO),DE
        JR     Z,RNSTRT
        CP     ','
        JR     Z,SKIRE1
        CALL   IDEEX0
        LD     (NEWNO),DE
        CALL   ENDCHK
        JR     Z,RNSTRT
        CALL   HCH2CH
        DEC    HL
SKIRE1: CALL   INCHLF
        CP     ','
        JR     Z,SKMRNU
        CALL   IDEEX0
        LD     (STLNO),DE
        CALL   ENDCHK
        JR     Z,RNSTRT
        CALL   HCH2CH
        DEC    HL
SKMRNU: INC    HL
        CALL   IDEEX0
        LD     (ADDNO),DE
RNSTRT: PUSH   HL
        LD     HL,(STLNO)
        EX     DE,HL
        LD     HL,(NEWNO)
        OR     A
        SBC    HL,DE
        JP     C,ER03__
        CALL   REFADR
        LD     HL,(TEXTST)
BEGRNS: LD     E,(HL)
        INC    HL
        LD     D,(HL)
        LD     A,D
        OR     E
        JR     Z,RNUMED
        EX     DE,HL
        ADD    HL,DE
        DEC    HL
        EX     DE,HL
        INC    HL
        LD     C,(HL)
        INC    HL
        LD     B,(HL)
        PUSH   HL
        DEFB   21H
STLNO:  DEFS   2
        OR     A
        SBC    HL,BC
        POP    HL
        JR     Z,BEGREN
        JR     C,BEGREN
        EX     DE,HL
        JR     BEGRNS
;
BEGREN: DEC    HL
        DEC    HL
        DEC    HL
        DEFB   01H
NEWNO:  DEFS   2
        OR     A
        PUSH   AF
RENUML: LD     E,(HL)
        INC    HL
        LD     D,(HL)
        LD     A,D
        OR     E
        JR     Z,RNUMED
        EX     DE,HL
        ADD    HL,DE
        DEC    HL
        EX     DE,HL
        POP    AF
        JR     C,RENOVR
        INC    HL
        LD     (HL),C
        INC    HL
        LD     (HL),B
        DEFB   21H
ADDNO:  DEFS   2
        ADD    HL,BC
        PUSH   AF
        LD     C,L
        LD     B,H
        EX     DE,HL
        JR     RENUML
;
RNUMED: POP    AF
        CALL   REFLNX
        POP    HL
        RET
;
RENOVR: LD     HL,10
        LD     (ADDNO),HL
        LD     (NEWNO),HL
        LD     L,0
        LD     (STLNO),HL
        CALL   RNSTRT
        JP     ER03__
;
;
; Error message & exeption
;
defc MAXERR  =    70
;
;
ER01:
        LD     A,01
        DEFB   21H

ER02:
        LD     A,02
        DEFB   21H

ER03__:
        LD     A,03
        DEFB   21H

ER04:
        LD     A,04
        DEFB   21H

ER05:
        LD     A,05
        DEFB   21H

ER06__:
        LD     A,06
        DEFB   21H

ER07:
        LD     A,07
        DEFB   21H

ER08:
        LD     A,08
        DEFB   21H

ER13:
        LD     A,13
        DEFB   21H

ER14:
        LD     A,14
        DEFB   21H

ER15:
        LD     A,15
        DEFB   21H

ER16:
        LD     A,16
        DEFB   21H

ER17:
        LD     A,17
        DEFB   21H

ER18:
        LD     A,18
        DEFB   21H

ER19:
        LD     A,19
        DEFB   21H

ER20:
        LD     A,20
        DEFB   21H

ER21:
        LD     A,21
        DEFB   21H

ER22:
        LD     A,22
        DEFB   21H

ER24:
        LD     A,24
        DEFB   21H

ER25:
        LD     A,25
        DEFB   21H

ER58__:
        LD     A,58
        DEFB   21H

ER64__:
        LD     A,64
        JR     ERRJ2

;
ER06_:                    ;Nesting error
        LD     A,6
NESTER:
        LD     SP,(INTFAC)
        LD     HL,0FFFFH
        PUSH   HL
        LD     (STACK),SP
ERRJ2:  JR     ERRJ1
;
LPTMER:                    ;LPT:mode error
        LD     HL,(__LPT)
        DEFB   0DDH
CRTMER:                    ;CRT:mode error
        LD     HL,(__CRT)
        LD     (ZEQT),HL
        XOR    A
        LD     (ZFLAG2),A
        LD     A,68+80H        ;+80H is I/O err
        DEFB   21H
ER59__:
        LD     A,59+80H
        DEFB   21H
ER59_:
        LD     A,59
        DEFB   21H
ER60_:
        LD     A,60+80H
        DEFB   21H
ER61_:
        LD     A,61+80H
ERRJ1:  JP     ERRORJ
;
;
P_ERL:  LD     A,L             ;Print "IN line#"
        OR     H
        RET    Z
        LD     DE,MESIN
        RST    3
        DEFB   _CRTMS
        CALL   ASCFIV
        RST    3
        DEFB   _CRTMS
        RET
;
;
MESIN:  DEFM   " IN "
        DEFB   0
MESBR:  DEFM   "BREAK"

        DEFB   0
;
OKMES:
        DEFM   "READY"

CONTFG:
        DEFB   0
        DEFB   0
;
ERROR:  CALL   IBYTE           ;"ERROR" command
        DEC    A
        CP     MAXERR
        JR     C,$+4
        LD     A,69-1
        INC    A
;
ERRORA: LD     SP,(STACK)      ;jump from monitor
        PUSH   AF
        RST    3
        DEFB   _ERCVR
        CALL   LDEND
        POP    AF
        OR     A
        JR     Z,_BRKX
        CP     80H
        JR     Z,_BRKZ
        LD     C,A
        LD     HL,0
        LD     (FNVRBF),HL
        CALL   _DIRECT
        LD     A,C
        JR     Z,ERR2
        LD     HL,(LNOBUF)
        LD     (ERRLNO),HL
        LD     (EDLINE),HL
        LD     HL,(NXTLPT)
        LD     (ERRLPT),HL
        LD     HL,(TEXTPO)
        LD     (ERRPNT),HL
        AND    7FH
        LD     (ERRCOD),A
        LD     A,(ERRORF)
        INC    A
        CP     02H
        JR     Z,ERROPR
        XOR    A
        LD     (CONTFG),A
        LD     (LSWAP),A
        LD     A,C
ERR2:
        RST    3
        DEFB   _ERRX
ERR4:   LD     HL,(LNOBUF)
        CALL   P_ERL
        JP     OK
;
;
ERROPR: LD     (ERRORF),A      ;Error trap
        LD     HL,(ERRORV)
        PUSH   HL
        JP     NXLINE
;
_BRKZ:  LD     A,'.'           ;Can CONT
_BRKX:                         ;Can't CONT
       LD     HL,(TEXTPO)
        JR     BREAK2
;
STOP:                          ;"STOP" command
        LD     A,'.'           ;Can CONT
        POP    DE              ;Dummy POP
BREAK2: PUSH   AF
        PUSH   HL
        RST    3
        DEFB   _CR2
        RST    3
        DEFB   _BELL
        LD     DE,MESBR
        RST    3
        DEFB   _CRTMS
        POP    HL
        CALL   _DIRECT
        JR     Z,BREAK4
        LD     (BREAKT+1),HL   ;Text pointer
        LD     HL,(NXTLPT)
        LD     (BREAKN+1),HL   ;Next line
        LD     HL,(LNOBUF)
        LD     (BREAKL+1),HL   ;Line No.
        LD     (EDLINE),HL
        POP    AF
        LD     (CONTFG),A
        JP     ERR4
BREAK4: POP    AF
        JP     OK
;
;
CONT:   POP    DE              ;"CONT" command
        LD     HL,CONTFG
        LD     A,(HL)
        OR     A
        JP     Z,ER17
        LD     (HL),0
BREAKL: LD     HL,0            ;Line No.
        LD     (LNOBUF),HL
BREAKN: LD     HL,0            ;Next line
        LD     (NXTLPT),HL
BREAKT: LD     HL,0            ;Text pointer
        JP     MAIN
;
;
;
RESUME:                        ;"RESUME" command
        LD     A,(ERRORF)
        CP     2
        JP     C,ER21
        DEC    A
        LD     (ERRORF),A
        CALL   ENDCHK
        EX     DE,HL
        LD     HL,(ERRLNO)
        LD     (LNOBUF),HL
        LD     HL,(ERRLPT)
        LD     (NXTLPT),HL
        LD     HL,(ERRPNT)
        JR     NZ,RESUM2
        POP    BC
        JP     MAIN0           ;RESUME
RESUM2: CP     8EH
        JP     Z,DATA          ;RESUME NEXT
        EX     DE,HL
        JP     GOTO            ;RESUME line#
;
ONERRG:
        CALL   TESTX
        DEFB   80H             ;GOTO
        CALL   GETLIN
        JR     Z,OFFER
        LD     (ERRORV),DE
        LD     A,1
ONER9:  LD     (ERRORF),A
        RET
;
;
OFFER:  LD     A,(ERRORF)
        DEC    A
        JR     Z,ONER9
        XOR    A
        LD     (ERRORF),A
        LD     HL,(ERRLNO)
        LD     (LNOBUF),HL
        LD     A,(ERRCOD)
        JP     ERRORA
;
;       END    (650DH)






; ---------------------------------
; MZ-800 BASIC  Statement interprit
; FI:STMNT  ver 1.0A 9.06.84
; Programed by T.Miho
; ---------------------------------

;        ORG    650DH

;
;
;
LET:
        CALL   TEST1
        DEFB   0FFH
        JP     Z,PFUNCT
        CALL   INTGTV
        PUSH   BC
        PUSH   BC
        PUSH   AF
        CALL   TESTX
        DEFB   0F4H             ;=
        CALL   EXPR
        POP    BC
        LD     A,(PRCSON)
        CP     B
        JP     NZ,ER04
        EX     (SP),HL         ; VAR ADRS<>TEXTPOINT
        EX     DE,HL
        CP     05H
        JR     Z,DAIBCK
        PUSH   BC
        CALL   STRDAI
        POP    AF
        POP    HL
        POP    BC
        RET
;
DAIBCK: LD     C,A
        LD     B,0
        LDIR
        POP    HL
        POP    BC
        RET
;
PFUNCT:
        CALL   TESTX
        DEFB   0C4H
        JP     TIMDAI          ;TI$=...
;
STRLET:
        PUSH   DE
        EX     DE,HL
        JR     STRDI2
;
STRDAI:
        PUSH   DE
        CALL   CVTSDC
STRDI2: LD     HL,KEYBM1
        LD     (HL),A
        LD     B,A
        LD     C,A
        INC    HL
        CALL   LDHLDE
        POP    HL
        LD     A,(HL)
        CP     C
        JR     Z,SMLNST
        PUSH   HL
        OR     A
        CALL   NZ,DELSTR
        POP    HL
        LD     A,(KEYBM1)
        OR     A
        JR     Z,STRNL1
        PUSH   HL
        LD     BC,(VARST)
        SBC    HL,BC
        EX     DE,HL
        LD     HL,(VARED)
        DEC    HL
        DEC    HL
        LD     (HL),E
        INC    HL
        LD     (HL),D
        INC    HL
        LD     BC,(STRST)
        OR     A
        POP    DE
        PUSH   HL
        SBC    HL,BC
        EX     DE,HL
        LD     (HL),A
        LD     B,A
        INC    HL
        LD     (HL),E
        INC    HL
        LD     (HL),D
        POP    HL
        LD     DE,KEYBM1
        INC    DE
        CALL   STRENT
        CALL   LDHL00
        LD     (TMPEND),HL
        LD     (VARED),HL
        RET
;
STRNL1: LD     (HL),0
        RET
;
SMLNST: INC    HL
        LD     E,(HL)
        INC    HL
        LD     D,(HL)
        LD     HL,(STRST)
        ADD    HL,DE
        LD     DE,KEYBM1
        LD     B,C
        INC    DE
        JP     STRENT
;
DELSTR: LD     C,(HL)
        LD     B,0
        INC    BC
        INC    BC
        INC    HL
        LD     E,(HL)
        INC    HL
        LD     D,(HL)
        LD     HL,(STRST)
        ADD    HL,DE
        DEC    HL
        DEC    HL
        LD     E,L
        LD     D,H
        ADD    HL,BC
        PUSH   BC
        PUSH   DE
        EX     DE,HL
        LD     HL,(VARED)
        OR     A
        SBC    HL,DE
        LD     C,L
        LD     B,H
        EX     DE,HL
        POP    DE
        PUSH   DE
        JR     Z,$+4
        LDIR
        POP    DE
        POP    BC
        LD     HL,(VARED)
        OR     A
        SBC    HL,BC
        LD     (VARED),HL
        EX     DE,HL
STRDE1: LD     E,(HL)
        INC    HL
        LD     D,(HL)
        LD     A,D
        OR     E
        RET    Z
        LD     HL,(VARST)
        ADD    HL,DE
        LD     A,(HL)
        INC    HL
        LD     E,(HL)
        INC    HL
        LD     D,(HL)
        OR     A
        EX     DE,HL
        SBC    HL,BC
        EX     DE,HL
        LD     (HL),D
        DEC    HL
        LD     (HL),E
        PUSH   BC
        LD     C,A
        LD     B,0
        LD     HL,(STRST)
        ADD    HL,DE
        ADD    HL,BC
        POP    BC
        JR     STRDE1
;
FOR:                    ;FOR TO STEP
        POP    BC
        LD     (FORRTA),BC
IF RAMDISK
        CALL   LET_0
ELSE
        CALL   LET
ENDIF
        LD     IX,0
        ADD    IX,SP
        LD     (FRTXPT),HL
        CALL   VAROFST
        LD     (FORVAD+1),BC
FOR3:   LD     E,(IX+0)
        LD     D,(IX+1)
        LD     HL,0FF12H
        OR     A
        SBC    HL,DE
        JR     NZ,FOR1
        LD     E,(IX+6)
        LD     D,(IX+7)
        EX     DE,HL
        OR     A
        SBC    HL,BC
        JR     Z,FOR2          ;EQL FORVAR
        LD     DE,012H
        ADD    IX,DE
        JR     FOR3
FOR2:   LD     DE,012H
        ADD    IX,DE
        LD     SP,IX
FOR1:   LD     HL,(FRTXPT)
        CALL   TESTX
        DEFB   0E0H             ;TO
        CALL   EXPR
        PUSH   AF
        PUSH   HL
        EX     DE,HL
        LD     DE,TODTBF
        CALL   LDIR5
        POP    HL
        POP    AF
        CP     0E1H             ;STEP
        LD     DE,FLONE
        JR     NZ,SSTEP1
        INC    HL
        CALL   EXPR
SSTEP1: LD     (FRTXPT),HL
        LD     HL,0FFF6H        ;-10
        ADD    HL,SP
        LD     SP,HL
        EX     DE,HL
        CALL   LDIR5
        LD     HL,TODTBF
        CALL   LDIR5
FORVAD: LD     HL,0
        PUSH   HL
        DEFB   21H
FRTXPT: DEFS   2
        PUSH   HL
        LD     HL,(NXTLPT)
        PUSH   HL
        LD     HL,0FF12H        ;FOR MARK
        PUSH   HL
        LD     HL,-512
        ADD    HL,SP
        LD     DE,(TMPEND)
        SBC    HL,DE
        LD     A,11            ;FOR..NEXT ERR
        JP     C,NESTER
        LD     HL,(FRTXPT)
        DEFB   0C3H
FORRTA: DEFS   2
;
;
NEXT:                    ;NEXT
        LD     A,5
        LD     (PRCSON),A
        POP    BC
        LD     (NEXRTA),BC
NEXT6:  PUSH   AF
        POP    BC
        LD     (FRTXPT),HL
        LD     IX,0
        ADD    IX,SP
        LD     (FORSTK),IX
        LD     E,(IX+0)
        LD     D,(IX+1)
        LD     HL,0FF12H
        OR     A
        SBC    HL,DE
        JP     NZ,ER13
        PUSH   BC
        POP    AF
        JR     NZ,NEXT1
;
        LD     E,(IX+4)        ;FOR TEXTPO
        LD     D,(IX+5)
        EX     DE,HL
        LD     (NEXT4+1),HL
;
        LD     E,(IX+6)        ;FORVAD
        LD     D,(IX+7)
        LD     HL,(VARST)
        ADD    HL,DE
;
        LD     BC,8            ;STEP ADR
        ADD    IX,BC
        PUSH   IX
        POP    DE
        CALL   ADD
        INC    DE
        LD     A,(DE)
        LD     IX,(FORSTK)
        LD     DE,0DH
        ADD    IX,DE
        PUSH   IX
        POP    DE
        BIT    7,A
        JR     NZ,$+3
        EX     DE,HL
        CALL   CMP
        JR     C,NEXT3         ;END
        DEFB   31H
FORSTK: DEFS   2
        LD     HL,2
        ADD    HL,SP
        LD     A,(HL)
        INC    HL
        LD     H,(HL)
        LD     L,A
        LD     (NXTLPT),HL
NEXT4:  LD     HL,0            ;TEXTPO
NEXT5:  DEFB   0C3H
NEXRTA: DEFS   2
NEXT3:  LD     DE,012H
        LD     HL,(FORSTK)
        ADD    HL,DE
        LD     SP,HL
        LD     HL,(FRTXPT)
        CALL   TEST1
        DEFM   ","
        JR     NZ,NEXT5
;
        LD     (FRTXPT),HL
NEXT1:  LD     IX,0
        ADD    IX,SP
        LD     (FORSTK),IX
        LD     HL,(FRTXPT)
        CALL   TEST1
        DEFM   ","
        JP     Z,NEXT6
        CALL   INTGTV
        LD     (FRTXPT),HL
        CALL   VAROFST
        LD     IX,(FORSTK)
NEXT12: LD     E,(IX+0)
        LD     D,(IX+1)
        LD     HL,0FF12H
        OR     A
        SBC    HL,DE
        JP     NZ,ER13
        LD     L,(IX+6)
        LD     H,(IX+7)
        OR     A
        SBC    HL,BC
        LD     HL,(FRTXPT)
        JP     Z,NEXT6
        LD     DE,012H
        ADD    IX,DE
        LD     (FORSTK),IX
        LD     SP,(FORSTK)
        JR     NEXT12
;
VAROFST:LD     HL,BC
        LD     BC,(VARST)
        OR     A
        SBC    HL,BC
        LD     BC,HL
        RET
;
TODTBF: DEFS   5
;
FRLNBF: DEFS   2
FRNLPT: DEFS   2
;
FORSKS: CALL   IFSKSB
        OR     A
        RET    NZ
        INC    HL
        PUSH   DE
        LD     E,(HL)
        INC    HL
        LD     D,(HL)
        LD     A,D
        OR     E
        INC    HL
        LD     (FRNLPT+1),DE
        LD     E,(HL)
        INC    HL
        LD     D,(HL)
        LD     (FRLNBF+1),DE
        POP    DE
        SCF
        RET    Z
        JR     FORSKS
;
USR:                    ;USR(adrs,source$,dest$)
        CALL   CH28H
        CALL   IDEEXP          ;adrs
        LD     (USRADR+1),DE
        CALL   TEST1
        DEFM   ","
        JR     NZ,USR2
        CALL   EXPR            ;source$
        CALL   STROK
        LD     (USRSRC+1),DE
        CALL   TEST1
        DEFM   ","
        JR     NZ,USR2
        CALL   INTGTV          ;dest$
        CALL   STROK
        LD     (USRDST+1),BC
        XOR    A
USR2:   PUSH   HL
        PUSH   AF
USRSRC: LD     HL,0            ;xxx
        CALL   CVTSDC
        LD     IX,ERRORJ
        XOR    A
USRADR: CALL   0               ;xxx
        POP    AF
        JR     NZ,USR8
        LD     A,B             ;dest$ exist
        EX     DE,HL
USRDST: LD     DE,0            ;xxx
        CALL   STRLET
USR8:   POP    HL
        JP     HCH29H
;
;
PAUSE:                    ;PAUSE command
        CALL   IDEEXP
PAUSE2: LD     A,D
        OR     E
        RET    Z
        LD     B,0FBH           ;JAPAN 00H
        DJNZ   $+0
        RST    3
        DEFB   _BREAK
        RET    Z
        DEC    DE
        JR     PAUSE2
;
REM:                     ;REM   command
LABEL:                   ;LABEL command
DATA:                    ;DATA  command
GSUB:                    ;GOSUB command
        DEC    HL
DATA0:  CALL   IFSKSB
        OR     A
        SCF
        RET    Z
        CP     ':'
        RET    Z
        JR     DATA0
;
OUT_:                    ;OUT @port,data
        CALL   IBYTE
        SUB    0E0H
        CP     7
        JP     C,ER03__          ;E0H .. E6H
        CALL   HCH2CH
        PUSH   DE
        CALL   IBYTE
        POP    BC
        OUT    (C),A
        RET
;
INP_:                    ;INP @port,vara
        CALL   IBYTE
        CALL   HCH2CH
        PUSH   DE
        CALL   INTGTV
        CP     5
        JP     NZ,ER04
        EX     (SP),HL
        PUSH   BC
        EX     (SP),HL
        POP    BC
        IN     E,(C)
        LD     D,0
        CALL   FLTHEX
        POP    HL
        RET
;
CURSOR_:                    ;CURSOR x,y
        CALL   CSRXY
        EX     DE,HL
        RST    3
        DEFB   _CURMV
        EX     DE,HL
        RET
;
CSRXY:
        LD     B,24
        LD     C,39
        LD     A,(CRTMD2)      ;80 char. mode change
        CP     3
        JR     C,CSRXY3
        LD     C,79
CSRXY3: CALL   CSRXY2
        JP     C,ER03__
        RET
;
CSRXY2: PUSH   BC
        CALL   IBYTE
        PUSH   AF
        CALL   HCH2CH
        CALL   IBYTE
        LD     D,E
        POP    AF
        LD     E,A
        POP    BC
        LD     A,C
        CP     E
        RET    C
        LD     A,B
        CP     D
        RET
;
GETOP:                    ;GET var
        CALL   INTGTV
        LD     (PRCSON),A
        CP     5
        JR     Z,GETSUJ
        PUSH   HL              ;GET STR
        PUSH   BC
        LD     A,0FFH
        RST    3
        DEFB   _INKEY
        OR     A
        JR     Z,NLGTKY
        LD     HL,(TMPEND)
        LD     (HL),A
        LD     A,1
NLGTKY: POP    DE
        CALL   STRLET
        POP    HL
        RET
;
GETSUJ: PUSH   HL
        PUSH   BC
        LD     A,0FFH
        RST    3
        DEFB   _INKEY
        SUB    30H
        CP     0AH
        JR     C,$+3
        XOR    A
        LD     E,A
        LD     D,0
        POP    HL
        CALL   FLTHEX
        POP    HL
        RET
;
POKE:                    ;POKE ad,d1,d2,d3,...
        CALL   IDEEXP
        CALL   CH2CH
POKELP: PUSH   DE
        CALL   IBYTE
        POP    DE
        LD     (DE),A
        INC    DE
        CALL   TEST1
        DEFM   ","
        RET    NZ
        JR     POKELP
;
LIMIT:                    ;LIMIT adrs
        PUSH   HL
        CALL   TEST1
        DEFM   "M"
        JR     NZ,LIMIT1
        CALL   TEST1
        DEFM   "A"
        JR     NZ,LIMIT1
        CALL   TEST1
        DEFM   "X"
        JR     NZ,LIMIT1
        EX     (SP),HL
        LD     HL,(MEMMAX)
        JR     LIMIT2
LIMIT1: POP    HL
        CALL   IDEEXP
        PUSH   HL
        LD     HL,(MEMMAX)
        OR     A
        SBC    HL,DE
        JP     C,ER06_
        LD     HL,(TMPEND)
        INC    H
        INC    H
        INC    H
        INC    H
        OR     A
        SBC    HL,DE
        JP     NC,ER03__
        EX     DE,HL
LIMIT2: CALL   MEMSET
        POP    HL
        POP    DE
        LD     SP,(INTFAC)
        LD     BC,0FFFFH
        PUSH   BC
        PUSH   DE
        RET
;
RETURN:                    ;RETURN linenumber
        POP    IX
RETRN2: POP    BC
        PUSH   BC
        LD     A,B
        INC    A
        JP     NZ,ER14
        LD     A,C
        CP     12H
        JR     Z,RETRN6
        CP     0FEH
        JP     NZ,ER14
        POP    BC
        CALL   ENDCHK
        EX     DE,HL
        POP    HL
        LD     (LNOBUF),HL
        POP    HL
        LD     (NXTLPT),HL
        POP    HL
        PUSH   IX
        RET    Z
        EX     DE,HL
        JP     GOTO
RETRN6: EX     DE,HL
        LD     HL,12H
        ADD    HL,SP
        LD     SP,HL
        EX     DE,HL
        JR     RETRN2
;
GOSUB:                    ;GOSUB linenumber
        PUSH   HL
        CALL   GSUB
        EX     DE,HL
        POP    HL
        POP    BC
        PUSH   DE
        EXX
        LD     HL,(NXTLPT)
        PUSH   HL
        LD     HL,(LNOBUF)
        PUSH   HL
        LD     HL,0FFFEH
        PUSH   HL
        LD     HL,-512
        ADD    HL,SP
        LD     DE,(TMPEND)
        SBC    HL,DE
        LD     A,10
        JP     C,NESTER
        EXX
        PUSH   BC
        JR     GOTO
;
ON:                    ;ON command
        CALL   TEST1
        DEFB   0C1H
        JP     Z,ONERRG        ;ON ERROR
        CALL   IDEEXP
        LD     C,E
        LD     B,D
        CP     87H
        JP     NC,ER01
        CP     82H
        JR     NZ,ON_4
        CALL   INCHLF
        LD     E,81H
        CP     0E4H
        JR     Z,ON_2
        CP     0E0H
        JP     NZ,ER01
        DEC    E
ON_2:   LD     A,E
ON_4:   PUSH   HL
        LD     HL,SJPTBL
        SUB    80H
        ADD    A,A
        LD     E,A
        LD     D,0
        ADD    HL,DE
        CALL   INDRCT
        EX     (SP),HL
        INC    HL
        LD     A,B
        OR     A
        JR     NZ,ON_9
        LD     A,C
        OR     A
        JR     Z,ON_9
        LD     B,A
ON_6:   DEC    B
        RET    Z
        CALL   HLFTCH
        CALL   LINE_
        JP     NZ,ER01
        CALL   DTSKL1
        OR     A
        RET    Z
        INC    HL
        CALL   TEST1
        DEFM   ","
        JR     Z,ON_6
        POP    DE
        JP     ENDZ
ON_9:   POP    DE
        JP     DATA
;
GOTO:                    ;GOTO linenumber
        CALL   GETLIN
        EX     DE,HL
        JR     NZ,$+5
        LD     HL,(TEXTST)     ;GOTO 0
        LD     (NXTLPT),HL
        XOR    A
        LD     (CONTFG),A
        JP     NXLINE
;
_IF:                    ;IF THEN ELSE
        CALL   EXPR
        EX     AF,AF
        LD     A,(DE)
        OR     A
        JR     Z,IFALSE
        EX     AF,AF
        CP     0E2H             ;THEN
        JR     NZ,IF_4
IF_2:   CALL   INCHLF
        CALL   LINE_
        JR     Z,GOTO
IF_4:   POP    AF
        JP     MAIN
;
LINE_:
        CP     '"'
        RET    Z
LINE_2:
        CP     0BH
        RET    Z
        CP     0CH
        RET
;
_ELSE:
        CALL   IFSKIP
        JR     NC,$-3
        RET
;
IFALSE: DEC    HL
        CALL   IFSKIP
        JR     NC,IF_2
        JP     ENDLIN
;
IFSKIP: CALL   IFSKSB
        OR     A
        SCF
        RET    Z
        CP     0C2H             ;ELSE
        RET    Z
        CP     93H             ;IF
        JR     NZ,IFSKIP
        CALL   IFSKIP
        RET    C
        JR     IFSKIP
;
DTSKSB:
        INC    HL
        LD     A,(HL)
        JR     DTSKL1
;
IFSKSB:
        INC    HL
        LD     A,(HL)
        CP     94H             ;DATA
        JR     Z,IFDASK
DTSKL1: OR     A
        RET    Z
        CP     '"'
        JR     Z,IFDQSK
        CP     0FEH             ;FUNC/OPTION
        JR     NC,IFFNRT
        CP     97H             ;REM
        JR     Z,IFDASK
        CP     27H             ;'
        JR     Z,IFDASK
        CP     20H
        RET    NC
        CP     0BH
        RET    C
        CP     15H
        JR     NC,ISKFLT
        INC    HL
IFFNRT: INC    HL
        RET
;
;
IFDASK: LD     A,(HL)
        OR     A
        RET    Z
        CP     3AH
        RET    Z
        CP     '"'
        JR     Z,DADQSK
        INC    HL
        JR     IFDASK
;
DADQSK: CALL   IFDQSK
        OR     A
        RET    Z
        INC    HL
        JR     IFDASK
;
ISKFLT: AND    0FH
        ADD    A,L
        LD     L,A
        LD     A,20H
        RET    NC
        INC    H
        RET
;
IFDQSK: INC    HL
        LD     A,(HL)
        OR     A
        RET    Z
        CP     '"'
        RET    Z
        JR     IFDQSK
;
;
BEEP:                    ;BEEP command
        RST    3
        DEFB   _BELL
        RET
;
BYE:                    ;BYE command
        CALL   ENDZ
        RST    3
        DEFB   _CLRIO
        RST    3
        DEFB   _MONOP
        RET
;
CONSOL:                    ;CONSOLE x,xl,y,yl
        JR     Z,CONSOI
        LD     A,(YS)
;
;CONSCK
        LD     D,0
        LD     E,A
        CALL   TEST1
        DEFM   ","
        JR     Z,CONSOK
        CALL   IBYTE
        CALL   HCH2CH
CONSOK: LD     C,E
        PUSH   BC
        CALL   IBYTE
        POP    BC
        DEC    A
        JP     M,ER03__
        ADD    A,C
        CP     25
        JP     NC,ER03__
        LD     B,A
;
        PUSH   HL
        LD     H,B
        LD     L,C
        RST    3
        DEFB   _DWIND
        POP    HL
        RET
CONSOI:                    ;CONSOLE INIT
        PUSH   HL
        LD     HL,1800H
        RST    3
        DEFB   _DWIND
        POP    HL
        RET
;
BOOT:                    ;BOOT command
        DI
        OUT    (0E4H),A
        JP     0
;
;
SEARCH:                    ;SEARCH#n "xxxx"
        XOR    A
        DEFB   1
LIST:                    ;LIST#n   Start-End
        LD     A,1
        LD     (SELTF),A
        PUSH   AF
        CALL   GETLU
        RST    3
        DEFB   _LUCHK
IF RAMDISK
        JP     C,ER44
ELSE
        JP     C,ER64__
ENDIF
        BIT    1,A             ;W?
IF RAMDISK
        JP     Z,__ER59
ELSE
        JP     Z,ER64__
ENDIF
        CALL   TEST1
        DEFM   ","
        POP    AF
        OR     A
        JR     NZ,LIST10
        CALL   STREXP          ;SEARCH command only
        LD     A,B
        LD     (SECLEN),A
        LD     (SESTR),DE
        CALL   ENDZ
        JR     LIST10
;
LIST0:
        LD     A,2
        LD     (SELTF),A
LIST10: CALL   GTSTED
        LD     (LISTSN),DE
        LD     (LISTEN),BC
        LD     A,0FFH
        LD     (DISPX),A
        CALL   PUSHR
        LD     HL,(TEXTST)
LIST20: CALL   LDDEMI
        LD     A,D
        OR     E
        RET    Z
        EX     DE,HL
        ADD    HL,DE
        DEC    HL
        DEC    HL
        EX     DE,HL
        PUSH   DE
        CALL   LDDEMI
        PUSH   HL
        DEFB   21H
LISTSN: DEFS   2
        OR     A
        SBC    HL,DE
        JR     C,LIST30
        JR     Z,LIST30
        POP    HL
        POP    HL
        JR     LIST20
;
LIST30: DEFB   21H
LISTEN: DEFS   2
        OR     A
        SBC    HL,DE
        JR     NC,LIST40
        POP    HL
        POP    HL
        RET
;
;
LIST40: EX     DE,HL
        CALL   ASCFIV
        RST    3
        DEFB   _COUNT
        LD     HL,KEYBUF
        CALL   LDHLDE
        LD     (HL),' '
        INC    HL
        EX     DE,HL
        POP    HL
        CALL   CVTXIM
        LD     A,(SELTF)
        OR     A
        JR     NZ,LIST50
        CALL   SSEST
        JR     NC,LIST60
LIST50: LD     DE,KEYBUF
        RST    3
        DEFB   _COUNT
        RST    3
        DEFB   _PRSTR
        CALL   PRTCR
LIST60: POP    HL
        LD     A,(SELTF)
        CP     2
        JR     Z,LIST20        ;ASCII SAVE
        RST    3
        DEFB   _HALT
        JR     LIST20
;
;
;
; HL=TEXT START ADDRESS
;
SSEST:  EX     DE,HL
SSESTL: PUSH   HL
        CALL   SSESTS
        POP    HL
        RET    C
        RET    Z
        INC    HL
        JR     SSESTL
;
;;;;;;;;;;;;;;;;;;;;;;
;
;  ent HL:CMP pointer
;
;  ext CY=1  sane string
;      CY=0  Acc=0 not same & text end
;            Acc=FFH not same chr
;
SSESTS: LD     A,(SECLEN)      ;String Length
        LD     B,A
        LD     DE,(SESTR)      ;String address
SSEST0: LD     A,(HL)
        INC    HL
        OR     A
        RET    Z
        CP     5
        JR     Z,SSEST1
        CP     6
        JR     NZ,SSEST2
SSEST1: JR     SSEST0
;
SSEST2: PUSH   HL
        LD     C,A
SSEST4: LD     A,(DE)
        INC    DE
        CP     5
        JR     Z,SSEST3
        CP     6
        JR     NZ,SSEST5
SSEST3: DEC    B
        SCF
        POP    HL
        RET    Z
        PUSH   HL
        JR     SSEST4
SSEST5: SUB    C
        POP    HL
        OR     A
        RET    NZ              ;1 Chr not same
        DEC    B
        SCF
        RET    Z
        JR     SSEST0
;
;
SECLEN: DEFS   1               ;Stling length
;
SESTR:  DEFS   2               ;Stling Addrsess
;
SSESTW: DEFS   2               ;Line No.
;
SELTF:  DEFS   1               ;0:SEARCH , 1:LIST
;
;
KLIST:                    ;KEY LIST
        CALL   TESTX
        DEFB   87H             ;LIST
        CALL   TESTP
        PUSH   HL
        LD     C,0
KLSTLP:
        RST    3
        DEFB   _CR
        LD     A,C
        ADD    A,'1'
        LD     D,A
        LD     E,' '
        CP     3AH
        JR     NZ,$+5
        LD     DE,'0'*256+'1'  ; "01"
        LD     (KEYME2),DE
        LD     DE,KEYME1       ;'DEF KEY('
        RST    3
        DEFB   _MSG
        LD     A,C
        CALL   KEYBCL
        LD     B,(HL)
        INC    HL
        PUSH   BC
        CALL   STKYMS          ;(DE)=MSTRING
        POP    BC
        INC    C
        LD     A,C
        CP     10
        JR     NZ,KLSTLP
        RST    3
        DEFB   _CR
        POP    HL
        RET
;
STKYMS: LD     A,B
        OR     A
        LD     C,0
        JR     NZ,STKYM1
        LD     A,'"'
        RST    3
        DEFB   _1CX
        RST    3
        DEFB   _1CX
        RET
STKYM1: LD     A,(HL)
        CP     20H
        JR     C,CHRME1
        CP     '"'
        JR     Z,CHRME1
        LD     A,C
        CP     1
        JR     Z,CHRM22
        OR     A
        LD     DE,KEYME3
        JR     NZ,$+4
        INC    DE
        INC    DE
        RST    3
        DEFB   _MSG
CHRM22: LD     A,(HL)
        RST    3
        DEFB   _1CX
        INC    HL
        LD     C,1
        DJNZ   STKYM1
STKYE2: LD     A,'"'
___1CX:
        RST    3
        DEFB   _1CX
        RET
;
CHRME1: LD     A,C
        CP     0FFH
        JR     Z,CHRM12
        OR     A
        LD     DE,KEYME4
        JR     NZ,$+4
        INC    DE
        INC    DE
        RST    3
        DEFB   _MSG
CHRM16: PUSH   BC
        PUSH   HL
        LD     L,(HL)
        LD     H,0
        CALL   ASCFIV
        RST    3
        DEFB   _MSG
        POP    HL
        POP    BC
        INC    HL
        LD     C,0FFH
        DJNZ   STKYM1
        LD     A,')'
        JP     ___1CX
;
CHRM12: LD     A,','
        RST    3
        DEFB   _1CX
        JR     CHRM16
;
KEYME1: DEFM   "DEF KEY("

KEYME2: DEFS   2
        DEFM   ")="
        DEFB   0
KEYME3: DEFM   ")+\""
        DEFB   0
KEYME4: DEFM   "\"+CHR$("

        DEFB   0

;
DEFOP:                    ;DEF command
        CALL   TEST1
        DEFM   0B2H
        JR     Z,DEFKEY        ;DEF KEY(n)="..."
        CALL   TESTX
        DEFB   0FFH
        CALL   TESTX
        DEFB   0C7H
        JP     DEFFN           ;DEF FNx(x)=expr
;
DEFKEY:
        CALL   TESTX
        DEFM   "("
        CALL   IBYTE
        CALL   TESTX
        DEFM   ")"
        CALL   TESTX
        DEFB   0F4H             ;=
        LD     A,E
        DEC    A
        CP     10
        JP     NC,ER03__
        PUSH   HL
        CALL   KEYBCL
        EX     (SP),HL
        CALL   STREXP          ;A,DE
        EX     (SP),HL
        LD     A,B
        CP     16
        JR     C,$+4
        LD     A,15
        LD     (HL),A
        OR     A
        JR     Z,ESCKPT
        LD     B,A
        INC    HL
        LD     A,(DE)
        LD     (HL),A
        INC    DE
        INC    HL
        DJNZ   $-4
ESCKPT: POP    HL
        EI
        RET
;
;
KEYBCL: ADD    A,A
        ADD    A,A
        ADD    A,A
        ADD    A,A
        LD     HL,FUNBUF
        JP     ADDHLA
;
;        END   (6C81)

STMNT_END:
DEFS $6C81-STMNT_END

;        ORG    6C81H

; --------------------------
; MZ-800 BASIC  IOCS command
; FI:IOCS  ver 1.0B 9.20.84
; Programed by T.Miho
; --------------------------
;

;
;
;defc RUNRFL  =    11A4H           ;KEYBUF   label
;defc BKEYBF  =    11A5H           ;KEYBUF+1 label
defc RUNRFL  =    KEYBUF
defc BKEYBF  =    KEYBUF+1

;
;
;
;
CRTLU_: LD     A,(ZLOG)
        CP     CRTLU
        RET
;
PRTEXP:
        CALL   EXPR
        LD     A,(PRCSON)
        CP     3
        PUSH   HL
        EX     DE,HL
        JR     Z,PRTEX2
        CALL   CVNMFL
        POP    HL
        RST    3
        DEFB   _COUNT
        RET
PRTEX2: CALL   CVTSDC
        POP    HL
        RET

;
;  PRINT command
;
PRINT:
        XOR    A
        LD     (DISPX),A
        CALL   GETLU
        RST    3
        DEFB   _LUCHK
        JP     C,ER44          ;not open
        BIT    2,A             ;X?
        JP     NZ,PRX
        BIT    1,A             ;W?
        JP     Z,__ER59          ;can't exec
        CALL   LU2CH
        CALL   CRTLU_
        JR     NZ,PRT04
        LD     A,(SELCOL)
        LD     (COL),A
        CALL   TEST1
        DEFM   "["
        JR     NZ,PRT04
        CALL   COLCHK
        LD     (COL),A
        CALL   TESTX
        DEFM   "]"
PRT04:  CALL   ENDCHK
        JP     Z,PRTCR
PRT10:  LD     A,(HL)
        CP     0E3H             ;USING
        JR     Z,PRUSNG
        LD     BC,PRT20
        PUSH   BC              ;Return adrs
        CP     ';'
        RET    Z
        CP     ','
        RET    Z
        CP     0E6H             ;TAB
        JR     Z,PRTAB
        CALL   PRTEXP
        JP     PRTMS2
;
PRT20:  CALL   ENDCHK
        JP     Z,PRTCR
        CP     ','
        JR     NZ,PRT30

        CALL   CRTLU_
        JR     C,PRT25
        LD     IX,(ZPOS)
        CALL   IOCALL          ;TAB10
        LD     B,A
        SUB    10
        JR     NC,$-2
        NEG
        LD     B,A
        CALL   PRTAB2
        JR     PRT30
PRT25:  CALL   PRTCR
PRT30:  LD     A,(HL)
        CP     ','
        JR     Z,$+4
        CP     ';'
        JR     NZ,$+3
        INC    HL
        CALL   ENDCHK
        RET    Z
        JR     PRT10
;
PRTAB:  CALL   CRTLU_
        JP     C,__ER59
        CALL   ICH28H
        CALL   IBYTE
        CALL   HCH29H
        LD     IX,(ZPOS)
        CALL   IOCALL
        SUB    E
        RET    NC
        NEG
        LD     B,A
        CALL   CRTLU_
        LD     A,13H           ;Cursor right
        JR     Z,$+4
PRTAB2: LD     A,' '
        LD     DE,BKEYBF
        PUSH   BC
        PUSH   DE
        CALL   SETDE
        POP    DE
        POP    BC
        JR     PRTMS2
;        SKP    3
;
PRUSNG: INC    HL              ;PRINT USING
        CALL   STREXP
        LD     A,B
        OR     A
        JP     Z,ER03__
        PUSH   HL
        LD     HL,BKEYBF
        PUSH   HL
        PUSH   BC
        CALL   LDHLDE
        POP    BC
        LD     A,0F0H
        LD     E,B
        LD     D,0
        INC    DE
        RST    3
        DEFB   _OPSEG
        LD     (USINGS),HL
        LD     (USINGP),HL
        POP    DE
        CALL   LDHLDE
        LD     (HL),0
        POP    HL
PRUSG2: CALL   ENDCHK
        JR     Z,PRUSG8
        INC    HL
        CP     ','
        JR     Z,PRUSG4
        CP     ';'
        JP     NZ,ER01
PRUSG4: CALL   ENDCHK
        JR     Z,PRUSG9
        CALL   EXPRNX
        PUSH   HL
        LD     BC,(TMPEND)
        PUSH   BC
        CALL   USNGSB
        POP    DE
        CALL   PRTMSG
        POP    HL
        JR     PRUSG2
PRUSG8: CALL   PRTCR
PRUSG9: LD     A,0F0H
        RST    3
        DEFB   _DLSEG
        RET

;
CR_TXT:
		defb $0d, 0
;
PRTCR:
		ld de,CR_TXT           ;FMP

;print message
;
PRTMSG:
        RST    3
        DEFB   _COUNT
PRTMS2: CALL   CRTLU_
        JR     Z,PRTMC
        RST    3
        DEFB   _PRSTR
        RET
;
PRTMC:  PUSH   AF
        LD     A,(COL)
        RST    3
        DEFB   _DCOL
        POP    AF
        RST    3
        DEFB   _PRSTR
        LD     A,(SELCOL)
        RST    3
        DEFB   _DCOL
        RET
;
;
;  READ command
;
READ:
        LD     A,DATLU
        LD     (ZLOG),A
        JR     INP10
;
;  INPUT command
;
INPUT:                    ;INPUT command
        CALL   GETLU
        RST    3
        DEFB   _LUCHK
        JP     C,ER44          ;not open
        BIT    2,A             ;X?
        JP     NZ,INX
        BIT    0,A             ;R?
        JP     Z,__ER59          ;can't exec
        CALL   LU2CH
        CALL   CRTLU_
        JR     NZ,INP10
        CALL   HLFTCH
        CP     '"'
        LD     DE,MEM_IN
        LD     B,2
        JR     NZ,INP05
        CALL   STREXP
        CALL   TESTX
        DEFM   ";"
INP05:  LD     A,B
        OR     A
        JR     Z,INP10
INP07:  LD     A,(DE)
        INC    DE
        RST    3
        DEFB   _CRT1C
        DJNZ   INP07
INP10:  LD     (INPSP+1),SP
        LD     DE,(VARED)
        LD     (TMPEND),DE
INP15:  LD     DE,(TMPEND)
        CALL   MEMECK
        CALL   INTGTV
        PUSH   AF
        PUSH   BC
        CALL   ENDCHK
        JR     Z,INP20
        CALL   CH2CH
        JR     INP15
;
ER44:   LD     A,44            ;not opened
        DEFB   21H
__ER59:   LD     A,59+80H        ;can't exec
        JP     ERRORJ
;
MEM_IN: DEFM   "? "
;
;
INP20:  XOR    A
        PUSH   AF              ;END=00
        PUSH   HL
        RST    3
        DEFB   _INSTT
        LD     HL,(INPSP+1)
        DEC    HL
INP24:  LD     A,(HL)
        OR     A
        JR     Z,INP30
        DEC    HL
        DEC    HL
        LD     B,(HL)
        DEC    HL
        LD     C,(HL)
        DEC    HL
        PUSH   HL
        PUSH   AF              ;Type
        PUSH   BC              ;Adrs
        LD     DE,(TMPEND)
        CALL   INPMX
        LD     H,0
        LD     L,B
        ADD    HL,DE
        LD     (HL),0
        POP    DE              ;Adrs
        POP    AF              ;Type
        CALL   INSUB
        POP    HL
        JR     INP24
INP30:  POP    HL
INPSP:  LD     SP,0            ;xxx
        RET
;
INPMX:  LD     A,(ZLOG)
        CP     DATLU
        JR     Z,DATINP
        RST    3
        DEFB   _INMSG
        RET

;
;
INSUB:  CP     3               ;String ?
        JR     NZ,INSUB4       ; No
        LD     HL,(TMPEND)     ; Yes
        LD     A,B
        JP     STRLET
;
INSUB4: PUSH   DE
        LD     HL,(INTFAC)
        LD     DE,(TMPEND)
        EX     DE,HL
        CALL   HLFTCH
        CP     'E'
        JP     Z,ER03__
        EX     DE,HL
        CALL   CVFLAS
        EX     DE,HL
        CALL   TEST1
        DEFM   0
        JP     NZ,ER03__
        EX     DE,HL
        POP    DE
        JP     LDIR5

;
;  RESTORE command
;
RESTOR:
        XOR    A
        LD     (DATFLG),A
        CALL   ENDCHK
        CALL   NZ,GETLIN
        EX     DE,HL
        CALL   NZ,DTSRCX
        EX     DE,HL
        JP     DATA            ;ON RESTORE
;
DATINP: PUSH   HL
        PUSH   DE
        CALL   DATINX
        POP    DE
        POP    HL
        RET
;
DATIN0: LD     HL,(TEXTST)
        CALL   DTSRCX
DATINX: LD     A,(DATFLG)      ;read flag
        CP     1               ;0 is restore top
        JP     Z,ER24          ;1 is out of data
        JR     C,DATIN0        ;2 is ok
        LD     HL,(DATPTR)     ;read pointer
        LD     C,':'
        RST    3
        DEFB   _INDAT
        LD     (DATPTR),HL     ;read pointer
        CALL   ENDCHK
        SCF
        CCF
        RET    NZ
        DEC    HL
DTSRCH: CALL   DTSKSB          ;DATA search
        OR     A
        JR     NZ,DTSRC4
        INC    HL
DTSRCX: LD     A,(HL)
        INC    HL
        OR     (HL)
        LD     A,1
        JR     Z,DTSRC9
        INC    HL
        INC    HL
        JR     DTSRCH
DTSRC4: CP     94H             ;DATA
        JR     NZ,DTSRCH
        INC    HL
        LD     (DATPTR),HL     ;read pointer
        LD     A,2
DTSRC9: LD     (DATFLG),A      ;read flag
        RET

;
;  GETLU ... interpret #n, /P, /T
;    ent HL: pointer
;    ext HL: pointer
;        A:  LU#
;
GETLU:
        CALL   TEST1
        DEFM   "#"
        JR     NZ,GETLU2
        CALL   HLFTCH
        CP     20H
        JP     NC,ER01
        PUSH   DE
        PUSH   BC
        LD     DE,ZFAC
        PUSH   DE
        CALL   FACNUM
        EX     (SP),HL
        CALL   HLFLT
        LD     A,H
        OR     A
        JP     NZ,ER64__
        OR     L
        JP     Z,ER64__
        JP     M,ER64__
        POP    HL
        POP    BC
        POP    DE
        RET
GETLU2:
        CALL   TEST1
        DEFB   0FBH             ;/
        LD     A,CRTLU
        RET    NZ
        CALL   TEST1
        DEFM   "P"
        LD     A,LPTLU
        RET    Z
        CALL   TESTX
        DEFM   "T"
        LD     A,CMTLU
        RET
;
;
LU2CH:  LD     A,(ZLOG)
        OR     A
        RET    M
        JP     HCH2CH

;
;  DEFAULT "dev:"
;
DEFAULT:
        CALL   DEVNAM
        RST    3
        DEFB   _SETDF
        RET
;
;  INIT "dev:command"
;
INIT:
        CALL   ENDCHK
        LD     B,0
        CALL   NZ,STREXP
;
INIT2:  PUSH   HL
        RST    3
        DEFB   _DEVNM
        RST    3
        DEFB   _FINIT
        POP    HL
        RET
;
;
;  ROPEN, WOPEN, XOPEN
;
ROPEN:
        LD     A,1
        DEFB   1
WOPEN:
        LD     A,2
        DEFB   1
XOPEN:
        LD     A,4
        PUSH   AF
        LD     (ZRWX),A
        CALL   GETLU
        CP     CRTLU
        JR     NZ,$+4
        LD     A,CMTLU
        LD     (ZLOG),A
        CALL   LU2CH
        CALL   ELMT
        POP    AF
        CP     4               ;X
        JR     Z,$+4
OPN_B:  LD     A,3             ;BSD
        LD     (ELMD),A
        PUSH   AF
        RST    3
        DEFB   _RWOPN
        LD     A,(ELMD)
        POP    BC
        CP     B
        JP     NZ,ER61_
        RET

;
;  CLOSE/KILL command
;
CLOSE:
        DEFB   0F6H
KILL:
        XOR    A
        LD     B,A
        CALL   ENDCHK
        JR     Z,CLALL         ;all files
CLKL2:  CALL   GETLU
        CP     CRTLU
        RET    NC
        RST    3
        DEFB   _CLKL
        CALL   TEST1
        DEFM   ","
        JR     CLKL2
;
CLALL:  XOR    A
        RST    3
        DEFB   _CLKL
        RET
;
;
ELMT:
        CALL   END2C
        LD     B,0
        CALL   NZ,STREXP
        PUSH   HL
        RST    3
        DEFB   _DEVFN
        POP    HL
        RET

;
DEVNAM: PUSH   HL
        CALL   HLFTCH
        LD     DE,ELMWRK
        LD     B,1
        CALL   ELMCK
        CALL   NC,ELMCK
        JR     C,DEVNM2
        CALL   ELMCK
        CALL   TSTNUM
        CALL   ELMCK2
        CALL   ENDCHK
        JR     NZ,DEVNM2
        LD     A,':'
        LD     (DE),A
        POP    AF              ;dummy
        LD     DE,ELMWRK
        JR     DEVNM4
DEVNM2: POP    HL
        CALL   ENDCHK
        LD     B,0
        CALL   NZ,STREXP
DEVNM4: PUSH   HL
        RST    3
        DEFB   _DEVNM
        INC    (HL)
        DEC    (HL)
        JP     NZ,ER58__
        POP    HL
        RET
;
ELMCK:  CP     'A'
        RET    C
        CP     'Z'+1
        CCF
ELMCK2: RET    C
        LD     (DE),A
        INC    HL
        INC    DE
        LD     A,(HL)
        INC    B
        RET
;
ELMWRK: DEFS   4

;
; LOAD "dev:filename"
;
IF MOD_B
        DEFB   0CDH              ;   (CALL): This is useless, it is unclear why the "LOAD" function was shifted on MOD B
ENDIF

LOAD:
        CALL   TEST1
        DEFB   0E5H             ;ALL

        JR     NZ,_LOAD_2
        XOR    A
__LSALL:
        RST    3
        DEFB   _LSALL
        RET

_LOAD_2:
        CALL   ELMT
        CALL   TEST1
        DEFM   ","
        JP     Z,LOADA
        PUSH   HL
        CALL   LDRDY
        DEC    A
        JR     Z,LDOBJ
        DEC    A
        JP     NZ,ER61_         ;il file mode
        CALL   CKCOM
        CALL   CLRVAR
        CALL   LDFIL
        JR     LOAD9

LDOBJ:  LD     HL,(ELMD22)     ;load addr
        PUSH   HL
        LD     DE,(MEMLMT)
        CALL   COMPR
        LD     DE,(ELMD20)     ;size
        LD     BC,(MEMMAX)

        CALL   NC,MEMOBJ
        JP     C,ER18
        POP    HL
        RST    3
        DEFB   _LOADF
LOAD9:
IF RAMDISK
        JP     SEEK_0
IF MOD_B
        NOP
ELSE
		NOP
		NOP
ENDIF
ELSE
        CALL   LDEND
        POP    HL
        RET
ENDIF
;


MEMOBJ: ADD    HL,DE
        RET    C
        EX     DE,HL
        LD     HL,BC
COMPR:
        PUSH   HL
        OR     A
        SBC    HL,DE
        POP    HL
        RET

;
; CHAIN "dev:filename"
;
CHAIN:
        CALL   ELMT
        CALL   LDRDY
        CP     2
        JP     NZ,ER61_         ;il file mode
        LD     A,(LSWAP)
        OR     A
        JP     Z,RUN2
        JP     SWAP2

;
; MERGE "dev:filename"
;
MERGE:
        CALL   CKCOM
        CALL   ELMT
        CALL   TEST1
        DEFM   ","
        JR     Z,MERGEA
        RST    3
        DEFB   _LOPEN
        CP     2
        JP     NZ,ER61_
        PUSH   HL
        LD     HL,(VARED)
        LD     (TMPEND),HL
        LD     BC,1000
        ADD    HL,BC
        JP     C,ER06_
        PUSH   HL
        LD     BC,(ELMD20)     ;size
        INC    B
        ADD    HL,BC
        JP     C,ER06_
        SBC    HL,SP
        JP     NC,ER06_
        POP    HL
        PUSH   HL
        RST    3
        DEFB   _LOADF
        POP    HL
        CALL   MERGE0
        POP    HL
        RET
;
MERGE0: CALL   LDDEMI
        LD     A,D
        OR     E
        RET    Z
        PUSH   DE
        CALL   LDDEMI
        PUSH   HL
        LD     HL,DE
        LD     (EDLINE),HL
        CALL   DELSUB
        POP    HL
        POP    BC
        PUSH   BC
        PUSH   HL
        CALL   INSTLIN
        POP    HL
        POP    BC
        ADD    HL,BC
        DEC    HL
        DEC    HL
        DEC    HL
        DEC    HL
        JR     MERGE0

;
;  LOAD/MERGE/RUN  ascii
;
LOADA:  CALL   CKCOM
        LD     A,1
        DEFB   1
MERGEA: LD     A,0
        DEFB   1
RUNA:   LD     A,2
        PUSH   AF
        CALL   TESTX
        DEFM   "A"
        CALL   ENDZ
        LD     A,1
        LD     (ZRWX),A
        LD     A,LDALU
        LD     (ZLOG),A
        CALL   OPN_B
        POP    AF
        PUSH   AF
        PUSH   HL              ;RJOB
        LD     HL,0
        LD     DE,0FFFFH
        OR     A
        CALL   NZ,DELSUB       ;load/run only
        LD     A,LDALU
        RST    3
        DEFB   _LUCHK
        LD     HL,(VARED)
        LD     (TMPEND),HL
        LD     BC,1000
        ADD    HL,BC
        JP     C,ER06__
        PUSH   HL              ;load start adrs
        LD     (LDAPTR),HL
LDA2:   LD     HL,-512
        ADD    HL,SP
        LD     DE,(LDAPTR)
        SBC    HL,DE
        JP     C,ER06__
        LD     DE,(TMPEND)
        RST    3
        DEFB   _INMSG
        LD     A,B
        OR     A
        JR     Z,LDA4
        CALL   CVBCAS
        LD     A,B
        OR     C
        JP     Z,ER03__
        LD     HL,(LDAPTR)
        PUSH   HL              ;load pointer
        INC    HL
        INC    HL
        LD     (HL),C
        INC    HL
        LD     (HL),B
        INC    HL
        PUSH   HL
        LD     HL,DE
        CALL   TEST1
        DEFB   0
        JP     Z,ER03__
        POP    HL
        LD     A,(DE)
        CP     ' '
        JR     NZ,$+3
        INC    DE
        CALL   CVIMTX
        LD     (HL),0
        INC    HL
        LD     (LDAPTR),HL
        POP    DE              ;old load pointer
        OR     A
        SBC    HL,DE
        EX     DE,HL           ;DE := length
        LD     (HL),E
        INC    HL
        LD     (HL),D
        JR     LDA2
LDA4:   LD     HL,(LDAPTR)
        CALL   LDHL00
        CALL   CLR
        POP    HL              ;load start adrs
        CALL   MERGE0
        POP    HL              ;RJOB
        POP    AF
        CP     2               ;RUN ?
        RET    NZ              ;no (load/merge)
        JP     RUNX            ;RUN from text-top
;
LDAPTR: DEFS   2

;
; RUN "dev:filename"
;
FRUN:
        CALL   ELMT
        PUSH   HL
        CALL   TEST1
        DEFM   ","
        JR     NZ,RUN1
        CALL   HLFTCH
        CP     'A'
        JP     Z,RUNA
RUN1:   CALL   LDRDY
        POP    HL
        DEC    A
        JR     Z,RUNOBJ
        DEC    A
        JP     NZ,ER61_         ;il file mode
        CALL   CLRVAR
RUN2:   CALL   LDFIL           ;jump from CHAIN
        CALL   LDEND
        JP     RUNX
;
RUNOBJ: LD     D,0             ; normal
        LD     BC,0FF00H
        CALL   TEST1
        DEFM   ","
        JR     NZ,RUNOB2
        CALL   TESTX
        DEFM   "R"
        LD     D,1             ;,R
        LD     BC,0CFF0H
RUNOB2: LD     A,D
        LD     (RUNRFL),A      ;,R flag
        LD     HL,(ELMD20)     ;size
        LD     DE,(ELMD22)     ;load addr
        PUSH   HL
        CALL   MEMOBJ
        POP    DE              ;size
        LD     HL,_BASIC       ;load file area
        LD     BC,0FF00H
        CALL   NC,MEMOBJ
        JP     C,ER06_
        LD     SP,0
        CALL   CLPTR
        XOR    A
        LD     (LOADFG),A
        LD     A,36H           ;count0 mode3
        OUT    (0D7H),A         ;8253 mode set
        LD     A,1
        OUT    (0D3H),A         ;8253 music enable
        LD     HL,(ELMD22)     ;load addr
        LD     DE,(TMPEND)
        CALL   COMPR
        JR     NC,RUNOB3
;
; destroy BASIC
;
        PUSH   HL
        LD     HL,_BASIC       ;load file area
        LD     (TEXTST),HL
        CALL   CLPTR
        LD     HL,RUNOBE-PRXFER+BKEYBF
        LD     (ERRORP),HL
        POP    HL
;
RUNOB3: LD     DE,(TMPEND)
        CALL   COMPR
        JR     NC,$+3
        EX     DE,HL
        PUSH   AF
        PUSH   HL
        LD     HL,PRXFER
        LD     DE,BKEYBF
        PUSH   DE
        LD     BC,RUNTBE-PRXFER
        LDIR
        RET                    ;JP BKEYBF
;
;
;  ORG BKEYBF
;
PRXFER: POP    HL
        RST    3
        DEFB   _LOADF
        LD     A,0C3H           ;int tbl make
        LD     HL,038DH
        LD     (1038H),A
        LD     (1039H),HL
        LD     A,01H           ;320*200 4 color
        RST    3               ; Software - Execute command
        DEFB   _DSMOD          ; Code 80 screen - set operating mode
        RST    3               ; Software - Execute command
        DEFB   _DI             ; Code 16 disable interrupts
        EX     AF,AF
        LD     A,(RUNRFL)      ;run"  " ,r
        OR     A
        CALL   NZ,INITIO-PRXFER+BKEYBF
        EX     AF,AF
        LD     HL,(ELMD24)     ;exec addr
        LD     A,H
        OR     L
        EXX
        LD     HL,(TMPEND)     ;data store addr
        LD     DE,(ELMD22)     ;load addr
        LD     BC,(ELMD20)     ;size
        OR     D
        OR     E
        JR     Z,PROX0
        LD     A,0E9H           ;jp (hl)
        LD     (PRO70P-PRXFER+BKEYBF),A
PROX0:  EXX
        POP    AF              ;ldir flg
        PUSH   HL              ;store exec addr
        LD     HL,PROFF-PRXFER+BKEYBF		; Copy PROFF  at $FF00
        LD     DE,0FF00H
        LD     BC,PRO80E-PROFF
        LDIR
        EXX
        JP     0FF00H
;
;  ORG 0FF00H
;
PROFF:  JR     NC,RUNOB4
        LDIR
RUNOB4: EX     AF,AF
        RET    Z               ;,R
        IN     A,(LSDMD)       ;check dipsw
        AND    2
        LD     A,0             ;mode 800
        OUT    (LSDMD),A       ; 800 mode
        LD     HL,PRO800-PROFF+0FF00H
        LD     BC,PRO80E-PRO800
        JR     NZ,MODSET_
;
        LD     A,8             ;mode 700
        OUT    (LSDMD),A       ;700 or 800 mode
        IN     A,(LSE0)        ;CG xfer
        LD     HL,1000H
        LD     DE,0C000H
        LD     BC,1000H
        LDIR
        IN     A,(LSE1)
;
        LD     HL,PRO700-PROFF+0FF00H
        LD     BC,PRO70E-PRO700
MODSET_:
        LD     DE,0CFF0H
        LDIR
        POP    HL
        LD     SP,IBUFE
        LD     DE,0D800H        ;vram2 for 700 mode
        JP     0CFF0H
;
RUNOBE:
        RST    3
        DEFB   _ERRX
        RST    3
        DEFB   _ERCVR
        RST    3
        DEFB   _DI
        HALT

;    ORG CFF0H
PRO700:
        OUT    (LSE4),A
PRO701: LD     A,71H           ;blue and white
        LD     (DE),A          ;vram2 clr
        INC    DE
        LD     A,D
        CP     0E0H
        JR     NZ,PRO701
PRO70P: OUT    (LSE0),A        ;jp (hl)
        JP     (HL)
PRO70E:
;
;    ORG CFF0H
PRO800:
        OUT    (LSE0),A        ;700mon rom bank off
        OUT    (LSE3),A        ;800mon rom bank on
        JP     (HL)
PRO80E:
;
;
;
INITIO:
        PUSH   AF
        DI                     ;run "file name",r
        IM     1
        LD     HL,RUNTBL-PRXFER+BKEYBF
        LD     B,17
        RST    3
        DEFB   _IOOUT          ;io dev init
        POP    AF
        RET
;
;
;
RUNTBL:
;   pio channel a
        DEFW   0FC00H           ; int vecter
        DEFW   0FCCFH           ; mode 3 (bit mode)
        DEFW   0FC3FH           ; i/o reg. set
        DEFW   0FC07H           ; int seqence (disenable)
;   pio channel b
        DEFW   0FD00H           ; int vecter
        DEFW   0FDCFH           ; mode 3 (bit mode)
        DEFW   0FD00H           ; i/o reg. set
        DEFW   0FD07H           ; int seqence (disenable)
;
        DEFW   0D774H           ;8253 C1 mode 2
        DEFW   0D7B0H           ;     C2 mode 0
        DEFW   0D6C0H           ;counter2  12h
        DEFW   0D6A8H           ;
        DEFW   0D5FBH           ;counter1   1s
        DEFW   0D53CH           ;
        DEFW   0D305H           ;8253 int ok
        DEFW   0CD01H           ;RF mode 700
        DEFW   0CC01H           ;WF mode 700
RUNTBE:
;

;
LDRDY0: LD     HL,(VARED)
        LD     (TMPEND),HL
        LD     DE,(POOL)
        LD     (OLDPOOL),DE
        OR     A
        SBC    HL,DE
        LD     (VARLN),HL
        LD     HL,-256
        ADD    HL,SP
        LD     (LAST),HL
        LD     DE,(VARED)
        PUSH   HL
        OR     A
        SBC    HL,DE
        JP     C,ER06_
        EX     (SP),HL
        EX     DE,HL
        LD     BC,(VARLN)
        INC    BC
        LDDR
        POP    DE
        RST    3
        DEFB   _ADDP0
        LD     A,1
        LD     (LOADFG),A
        RET
;
LDRDY:  CALL   LDRDY0
        RST    3
        DEFB   _LOPEN
        LD     A,(ELMD)
        RET
;
CLRVAR: LD     HL,(VARED)
        XOR    A
        DEC    HL
        LD     (HL),A
        DEC    HL
        LD     (HL),A
        LD     (STRST),HL
        DEC    HL
        LD     (HL),A
        LD     (VARST),HL
        DEC    HL
        LD     (HL),A
        LD     (POOL),HL
        LD     HL,4
        LD     (VARLN),HL
        RET
;
OLDPOOL:DEFS   2
VARLN:  DEFS   2
LAST:   DEFS   2
LOADFG: DEFB   0
;
CKCOM:
        PUSH   AF
        CALL   _DIRECT
        JP     NZ,ER19
        POP    AF
        RET

;
LDFIL:  LD     BC,(ELMD20)
        PUSH   BC
        LD     HL,(POOL)
        LD     DE,(TEXTST)
        OR     A
        SBC    HL,DE           ;HL := text area size
        LD     L,0
        SBC    HL,BC
        JP     C,ER06_
        LD     HL,0
        LD     (OLDPOOL),HL
        CALL   RUNINT
        LD     HL,0
        LD     (LNOBUF),HL
        LD     HL,(TEXTST)
        RST    3
        DEFB   _LOADF
        POP    BC
        LD     HL,(TEXTST)
        ADD    HL,BC
        LD     (OLDPOOL),HL
        RET
;
LDEND:
        LD     A,LDALU
        LD     B,0
        RST    3
        DEFB   _CLKL
        LD     HL,LOADFG
        LD     A,(HL)
        OR     A
        RET    Z
        LD     (HL),0
        LD     HL,(OLDPOOL)
        LD     A,H
        OR     L
        JR     NZ,LDEND2
        LD     HL,(TEXTST)
        CALL   LDHL00
LDEND2: EX     DE,HL
        LD     HL,(POOL)
        LD     BC,(VARLN)
        LDIR
        EX     DE,HL
        OR     A
        SBC    HL,DE
        EX     DE,HL
        RST    3
        DEFB   _ADDP0
        RET

;
; VERIFY "CMT:filename"
;
VERIFY:
        PUSH   HL
        CALL   REFLNX
        POP    HL
        CALL   ELMT
        PUSH   HL
        RST    3
        DEFB   _LOPEN
        CP     2
        JP     NZ,ER61_
        LD     HL,(TEXTST)
        RST    3
        DEFB   _VRFYF
        POP    HL
        RET
;
;  SAVE "dev:filename"
;
SAVE:
        CALL   TEST1
        DEFB   0E5H             ;ALL
        LD     A,1
        JP     Z,__LSALL
        PUSH   HL
        CALL   REFLNX
        POP    HL
        CALL   ELMT
        CALL   TEST1
        DEFM   ","
        JR     Z,SAVEA
        PUSH   HL
        LD     A,2
        LD     (ELMD),A
        LD     HL,(POOL)		; I/O work area, just after the BASIC program space (=TEXTST)
        LD     DE,(TEXTST)
        OR     A
        SBC    HL,DE
        LD     (ELMD20),HL
        LD     A,(ELMD1)
        CP     0DH
        JP     Z,ER60_
        RST    3
        DEFB   _SAVEF
        POP    HL
        RET
;
SAVEA:
        CALL   TESTX
        DEFM   "A"
        PUSH   HL
        LD     A,2
        LD     (ZRWX),A
        LD     A,LDALU
        LD     (ZLOG),A
        CALL   OPN_B
        POP    HL
        CALL   LIST0
        CALL   PRTCR
        LD     B,1
        LD     A,LDALU
        RST    3
        DEFB   _CLKL
        RET

;
;  LOCK/UNLOCK "dev:filename"
;
UNLOCK:
        XOR    A
        DEFB   1
LOCK:
        LD     A,1
        PUSH   AF
        CALL   STREXP
        RST    3
        DEFB   _DEVFN
        POP    AF
        RST    3
        DEFB   _LOCK
        RET
;
; DIR[#n] "dev:"
; DIR[/P] dev
;
DIR:
        CALL   GETLU
        PUSH   AF              ;lu#
        RST    3
        DEFB   _LUCHK
        JP     C,ER44
        BIT    1,A             ;W?
        JP     Z,__ER59
        CALL   LU2CH
        CALL   DEVNAM
        LD     B,A             ;ch#
        XOR    A
        RST    3
        DEFB   _DIR            ;read directory
        LD     A,B             ;A=ch#
        RST    3
        DEFB   _SETDF          ;set default
        POP    AF              ;A=lu#
        RST    3
        DEFB   _DIR            ;print directory
        RET
;
;  DELETE "dev:filename"
;
FDEL:
        CALL   STREXP
        RST    3
        DEFB   _DEVFN
        RST    3
        DEFB   _DELET
        RET
;
;  RENAME "dev:oldname","newnae"
;
RENAME:
        CALL   STREXP
        RST    3
        DEFB   _DEVFN
        CALL   HCH2CH
        CALL   STREXP
        RST    3
        DEFB   _RENAM
        RET

;
; random file access
;
PRX:    CALL   RAN0
PRX2:   CALL   PRTEXP
        RST    3
        DEFB   _PRREC
        CALL   ENDCHK
        RET    Z
        CALL   CH2CH
        JR     PRX2
;
;
INX:    CALL   RAN0
        LD     DE,(TMPEND)
        CALL   MEMECK
INX2:   CALL   INTGTV
        PUSH   HL
        PUSH   AF
        PUSH   BC
        LD     DE,(TMPEND)
        RST    3
        DEFB   _INREC
        POP    DE
        POP    AF
        CALL   INSUB
        POP    HL
        CALL   ENDCHK
        RET    Z
        CALL   CH2CH
        JR     INX2
;
RAN0:
        CALL   TEST1
        DEFM   "("
        RET    NZ
        CALL   IDEEXP
        LD     A,D
        OR     E
        JP     Z,ER03__
        RST    3
        DEFB   _RECST
        CALL   HCH29H
        CALL   TEST1
        DEFM   ","
        RET
;

;
;  SWAP "dev:filename"
;
SWAP:
        LD     A,(LSWAP)
        OR     A
        JP     NZ,ER25
        PUSH   HL
        LD     B,0
        RST    3
        DEFB   _DEVNM
        LD     (SWAPDV),DE
        LD     (SWAPCH),A
        LD     HL,(POOL)		; I/O work area, just after the BASIC program space (=TEXTST)
        LD     DE,(TEXTST)
        XOR    A
        SBC    HL,DE
        LD     (ELMD20),HL
        RST    3
        DEFB   _SWAP
        POP    HL
        CALL   ELMT
        CALL   ENDZ
        LD     A,(ZFLAG1)
        BIT    __RND,A
        JP     Z,__ER59
        PUSH   HL              ;RJOB
        LD     HL,(SWAPNB)
        ADD    HL,SP
        LD     SP,HL
        EX     DE,HL
        LD     HL,SWAPDS
        LD     BC,(SWAPBY)
        LDIR
        CALL   LDRDY
        CP     2
        JP     NZ,ER61_
        LD     (SWAP2+1),SP
SWAP2:  LD     SP,0            ;jump from CHAIN
        CALL   LDFIL
        CALL   LDEND
        LD     HL,0FFFDH
        PUSH   HL              ;SWAP flag
        PUSH   HL
        LD     A,1
        LD     (LSWAP),A
        LD     HL,(TEXTST)
        JP     NXLINE
;
; Recover SWAP
;
BSWAP:
        XOR    A
        LD     (LSWAP),A
        POP    IX
BSWAP2: POP    BC
        LD     A,B
        CP     0FFH
        JP     NZ,ER25
        LD     A,C
        CP     0FDH
        JR     Z,BSWAP6
        CP     0FEH
        LD     HL,4
        JR     Z,BSWAP4
        CP     12H
        LD     HL,10H
        JP     NZ,ER25
BSWAP4: ADD    HL,SP
        LD     SP,HL
        JR     BSWAP2
;
BSWAP6: LD     DE,(SWAPDV)
        LD     A,(SWAPCH)
        RST    3
        DEFB   _SETDF
        LD     B,0
        RST    3
        DEFB   _DEVNM
        CALL   LDRDY0
        OR     0FFH
        RST    3
        DEFB   _SWAP
        CALL   LDFIL
        CALL   LDEND
        LD     HL,0
        ADD    HL,SP
        LD     DE,SWAPDS
        LD     BC,(SWAPBY)
        LDIR
        LD     SP,HL
        POP    HL              ;RJOB
        RET
;
SWAPDV: DEFS   2
SWAPCH: DEFS   1
;
; I/O initial for cold-start
;
IOINIT:
        POP    HL
        PUSH   HL
        LD     (ERRORP),HL
        LD     A,'1'
        CALL   IOINI2
        LD     A,'2'
        CALL   IOINI2
        LD     DE,INITD3
        LD     B,INITD4-INITD3
        JR     IOINI4
IOINI2: LD     (INITD1+2),A
        LD     DE,INITD1
        LD     B,INITD3-INITD1
IOINI4: JP     INIT2
;
INITD1: DEFM   "RS?:0,$8C,13"


INITD3: DEFM   "CMT:T"

INITD4:
;

;       END  (7590H)



;        ORG    7590H


; -----------------------------
; MZ-800 BASIC  Graphic command
; FI:GRPH  ver 1.0B 9.21.84
; Programed by T.Miho
; -----------------------------
;

;
BITFU2: DEFB   0               ;Default W0/W1
COL:                    ;Color code
        DEFB   03H
;
;;;;;;;;;;;;;;;
;
; SET/RESET [c,w]x,y
;
SET:
        DEFB   0F6H
RESET:
        XOR    A
        PUSH   AF
        CALL   COORD0
        RST    3
        DEFB   _POSSV
        POP    AF              ;SET/RESET
        PUSH   HL
        EXX
        RST    3
        DEFB   _PSET
        POP    HL
        RET
;
;;;;;;;;;;;;;;;;;;
;
; LINE/BLINE [c,w] x0,y0,x1,y1,.....
;
LINE:
        DEFB   0F6H
BLINE:
        XOR    A
        LD     (LINE4+1),A
        CALL   COORD0
        CALL   HCH2CH
LINE2:  EXX
        PUSH   HL              ;YS
        PUSH   DE              ;XS
        EXX
        CALL   COORD
        POP    DE              ;XS
        EX     (SP),HL         ;YS,Text
        EXX
LINE4:  LD     A,0             ;LINE/BLINE
        RST    3
        DEFB   _LINE
        POP    HL
        CALL   TEST1
        DEFM   ","
        JR     Z,LINE2
        RST    3
        DEFB   _POSSV
        RET

;
;;;;;;;;;;;;;;;;;;;;;;;;
;
; PATTERN [C,W] N,X$
;
PATTER:
        CALL   COLCON
        CALL   IDEEXP
        XOR    A
        BIT    7,D
        JR     Z,GRDSP4
        PUSH   HL
        LD     H,A
        LD     L,A
        SBC    HL,DE
        EX     DE,HL
        POP    HL
        LD     A,1
GRDSP4: EX     AF,AF
        LD     A,D
        OR     A
        JR     NZ,ER03A
        LD     A,E
        PUSH   AF
        EX     AF,AF
        PUSH   AF
        CALL   HCH2CH
        CALL   STREXP
        POP    AF
        LD     C,A
        POP    AF
        PUSH   HL
        LD     H,C
        RST    3
        DEFB   _PATTR
        POP    HL
        CALL   ENDCHK
        JR     NZ,PATTER
        RET

;;;;;;;;;;;;;;;;;;;
;
;  POSITION x,y
;
POSITI:
        CALL   COORD
        RST    3
        DEFB   _POSSV
        RET
;
;  Get X-Y coordinate
;
COORD0: CALL   COLCON
COORD:  CALL   COORD1          ;Get x,y coordinate
        PUSH   DE
        CALL   TEST1
        DEFB   ','
        CALL   COORD1
        PUSH   DE
        EXX
        POP    HL
        POP    DE
        EXX
        RET
;
;
COORD1: CALL   IDEEXP
        LD     A,D             ;0000 ... 3FFF
        ADD    A,40H           ;C000 ... FFFF
        RET    P
ER03A:  JP     ER03__

;;;;;;;;;;;;;;;;;;;;;;;
;
; color palette
;
PALET:
        CALL   ENDCHK
        JP     Z,ER01
        CALL   PALRD
        CALL   COLCK2
        AND    03H
        PUSH   AF
        LD     A,(PALBK)
        LD     D,E
        SRL    D
        SRL    D
        CP     D
        JP     NZ,ER22
        CALL   TESTX
        DEFB   ','
        CALL   PALRD
        LD     B,A
        POP    AF
        RST    3
        DEFB   _DPLST
        RET
;
PALRD:  CALL   IBYTE
        CP     16              ;0 .. 15 check
        JR     NC,ER03A
        RET
;

;;;;;;;;;;;;;;;;;;;;
;
;  BOX [c,w] xs,ys,xe,ye
BOX:
        CALL   COORD0
        EXX
        PUSH   HL              ;YS
        PUSH   DE              ;XS
        EXX
        CALL   HCH2CH
        CALL   COORD
        EXX
        PUSH   HL              ;YE
        PUSH   DE              ;XE
        EXX
        CALL   ENDCHK
        JR     Z,BOX9
        CALL   CH2CH
        CALL   ENDCHK
        LD     A,(COL)
        CALL   NZ,COLCHK
        SCF
BOX9:   EXX
        POP    DE
        POP    HL
        EXX
        POP    DE
        EX     (SP),HL
        RST    3
        DEFB   _BOX
        POP    HL
        RET

;
;;;;;;;;;;;;;;;;;;
;
; COLOR c,w
;
COLOR:
        CALL   COLSUB
        LD     A,(COL)
        RST    3
        DEFB   _DCOL
        LD     (SELCOL),A
        LD     A,(PWMODE)
        LD     (BITFU2),A
        CALL   ENDZ
        RET
;
;;;;;;;;;;;;;;;;
;
; COLOR CONTROL EXP
;
COLCON:
        CALL   TEST1
        DEFM   ","
        CALL   TEST1
        DEFM   "["
        JR     NZ,COLCN1
        CALL   COLSUB
        LD     A,(COL)
        RST    3
        DEFB   _DGCOL
        CALL   TESTX
        DEFB   "]"
        CALL   TEST1
        DEFM   ","
        RET
;
COLCN1: LD     A,(SELCOL)
        LD     (COL),A
        RST    3
        DEFB   _DGCOL
COLCN2: LD     A,(BITFU2)
        LD     (PWMODE),A
        RET
;
COLSUB:
        CALL   TEST1
        DEFM   ","
        JR     Z,COLC8
        CALL   COLCHK
        LD     (COL),A
        CALL   TEST1
        DEFB   ','
        JR     NZ,COLCN2
COLC9:  CALL   IBYTE
        CP     2
        JR     NC,ER03B
        LD     (PWMODE),A
        RET
;
COLC8:  LD     A,(SELCOL)
        LD     (COL),A
        JR     COLC9
;
COLCHK:
        PUSH   BC
        CALL   IBYTE
        POP    BC
COLCK2: LD     A,(CRTMD1)
        RRA
        JR     C,CMD1
        RRA
        JR     C,CMD2
        RRA
        JR     C,CMD3
CMD1:   LD     A,E
        CP     4
        JR     NC,ER03B
        RET
CMD2:   LD     A,E
        CP     16
        JR     NC,ER03B
        RET
CMD3:   LD     A,E
        CP     2
        RET    C
ER03B:  JP     ER03__
;

;;;;;;;;;;;;;;;;;;;;
;
;PAINT COMMAND
;
PAINT:
        CALL   COLCON
        CALL   POSITI
        LD     B,0
        LD     DE,PAINTB
        PUSH   DE
        CALL   ENDCHK
        JR     Z,PAINT3
PAINT1: CALL   CH2CH
        PUSH   DE
        CALL   COLCHK
        POP    DE
        LD     (DE),A
        INC    DE
        INC    B
        LD     A,B
        CP     16
        JP     Z,ER01
        CALL   ENDCHK
        JR     NZ,PAINT1
PAINT2: EX     (SP),HL         ;data adrs
        PUSH   HL
        LD     HL,-527
        ADD    HL,SP
        LD     (PAIWED),HL
        POP    HL
        RST    3
        DEFB   _PAINT
        JP     C,ER06__
        POP    HL
        RET
;
PAINT3: LD     A,(COL)
        LD     (DE),A
        INC    B               ; data count
        JR     PAINT2
PAINTB: DEFS   16

;;;;;;;;;;;;;;;;;;;;
;
;CIRCLE COMMAND
;
CIRCLE:
        PUSH   HL
        LD     HL,0
        LD     (CW_H+1),HL
        LD     (CW_XS+1),HL
        LD     (CW_YS+1),HL
        LD     (CW_XE+1),HL
        LD     (CW_YE+1),HL
        LD     HL,KK
        CALL   CLRFAC
        LD     HL,FLT2PI
        LD     DE,SK           ;\mßám\l=2PAI
        CALL   LDIR5
        POP    HL
;\s\ºl yÝ-Ä
        CALL   COORD0
        RST    3
        DEFB   _POSSV
        CALL   HCH2CH
        CALL   IDEEXP
        PUSH   HL
        LD     A,D
        AND    0C0H
        JP     NZ,ER03__
        EX     DE,HL
        LD     (CW_R+2),HL     ;ÞÙZs
        LD     (CW_XS+1),HL
        LD     (CW_XE+1),HL
        LD     HL,(INTFAC)
        LD     DE,CIR_R
        CALL   LDIR5
        POP    HL
        CALL   ENDCHK
        JP     Z,CW
        CALL   CH2CH
        CALL   TEST1
        DEFB   ','
        JR     Z,CIRCL2
        CALL   HIRIT
        CALL   ENDCHK
        JP     Z,CW
        CALL   CH2CH
CIRCL2:
        CALL   TEST1
        DEFB   ','
        JR     Z,CIRCL8
        LD     IX,CW_XS+1
        LD     IY,KK
        CALL   STX
        CALL   ENDCHK
        JP     Z,CW
        CALL   CH2CH
CIRCL8:
        CALL   TEST1
        DEFB   ','
        JR     Z,CIRCL4
        LD     IX,CW_XE+1
        LD     IY,SK
        CALL   STX
        CALL   ENDCHK
        JP     Z,CW
        CALL   CH2CH
CIRCL4:
        CALL   TESTX
        DEFB   'O'
        SCF
        JR     $+3
CW:     XOR    A
        PUSH   HL
        PUSH   AF
        LD     HL,KK
        LD     DE,SK
        CALL   SUB
        CALL   LDIR5
        LD     A,(KK)
        OR     A
        LD     B,0
        JR     Z,CW2           ;KK=SK
        LD     HL,KK+1
        RES    7,(HL)
        DEC    HL              ;HL:= ABS(KK-SK)
        LD     DE,FLTPAI
        CALL   CMP
        LD     B,1
        JR     C,CW2           ;        ABS() < PI
        LD     DE,FLT2PI
        CALL   CMP
        LD     B,2
        JR     C,CW2           ;  PI <= ABS() < 2*PI
        LD     B,3             ;2*PI <= ABS()
CW2:    LD     A,(SK+1)
        AND    80H
        OR     B
        LD     B,A
        POP    AF              ;CF='O'
        LD     A,B
        EXX
CW_XS:  LD     DE,0            ;Start X
CW_YS:  LD     HL,0            ;Start Y
CW_H:   LD     BC,0            ;HIRITU
        EXX
CW_XE:  LD     DE,0            ;End X
CW_YE:  LD     HL,0            ;End Y
CW_R:   LD     IX,0            ;R
        RST    3
        DEFB   _CIRCL
        POP    HL
        OR     A
        RET
;
HIRIT:  CALL   IDEEXP
        CALL   PUSHR
        LD     HL,(INTFAC)
        INC    HL
        BIT    7,(HL)
        JP     NZ,ER03__
        DEC    HL
        LD     DE,FLONE
        CALL   CMP
        RET    Z
        LD     A,1
        JR     C,HI
        LD     HL,FLONE
        LD     DE,CIRW3
        PUSH   DE
        CALL   LDIR5
        POP    HL
        LD     DE,(INTFAC)
        CALL   DIV
        LD     A,2
HI:     LD     (CW_H+1),A
        LD     DE,_256DT
        CALL   MUL
        LD     DE,_0_5DT
        CALL   ADD
        CALL   HLFLT
        LD     A,L
        LD     (CW_H+2),A
        BIT    0,H
        RET    Z
        XOR    A
        LD     (CW_H+1),A
        RET
;
STX:    PUSH   IX
        PUSH   IY
        CALL   IDEEXP
        POP    DE              ;KK/SK
        POP    IX
        PUSH   HL
        PUSH   IX
        LD     HL,(INTFAC)
        CALL   LDIR5
        LD     HL,(INTFAC)
        LD     DE,HL
        INC    DE
        INC    DE
        INC    DE
        INC    DE
        INC    DE
        CALL   LDIR5
        CALL   COS             ;HL=(INTFAC)+5
        LD     DE,CIR_R
        CALL   MUL
        CALL   STXSUB
        LD     HL,(INTFAC)
        CALL   SIN
        LD     DE,CIR_R
        CALL   MUL
        CALL   NEG
        CALL   STXSUB
        POP    IX
        POP    HL
        RET
;
STXSUB: INC    HL
        BIT    7,(HL)
        PUSH   AF
        RES    7,(HL)
        DEC    HL
        LD     DE,_0_5DT
        CALL   ADD
        POP    AF
        INC    HL
        JR     Z,$+4
        SET    7,(HL)
        DEC    HL
        CALL   HLFLT
        EX     DE,HL
        POP    HL              ;RET ADRS
        EX     (SP),HL         ;Save coordinate
        LD     (HL),E
        INC    HL
        LD     (HL),D
        INC    HL
        INC    HL
        EX     (SP),HL
        JP     (HL)
;
;
;CIRCLE WORK AREA PART-2
;
CIR_R:  DEFS   5
;
CIRW3:  DEFS   5
;
_256DT:  DEFB   0x89,0x00,0x00,0x00,0x00
;
_0_5DT:  DEFB   0x80,0x00,0x00,0xA7,0xC6
;
KK:     DEFS   5
SK:     DEFS   5
;
; SYMBOL command
;

;
SMBOL:
        CALL   COORD0          ;position load
        RST    3
        DEFB   _POSSV          ;position input
        CALL   HCH2CH
;string pointer load
        CALL   STREXP
;string zero check
        LD     A,B
        OR     A
        PUSH   BC
        PUSH   HL
        LD     C,B
        LD     B,0
        LD     HL,DIRARE
        EX     DE,HL
        JR     Z,SMBL2
        LDIR                   ;string data xfer
SMBL2:  POP    HL
        CALL   HCH2CH
        CALL   IBYTE           ;yoko bairitsu
        LD     A,D
        OR     E
        JR     Z,ERJP3         ;zero error
        PUSH   DE
        CALL   HCH2CH
        CALL   IBYTE           ;tate bairitsu
        LD     A,D
        OR     E
ERJP3:  JP     Z,ER03__          ;zero error
        LD     A,E
        POP    DE
        LD     D,A
        CALL   ENDCHK          ;end check
        PUSH   DE
        JR     Z,SMBL1
        CALL   HCH2CH
        CALL   IBYTE           ;angle load
        LD     A,3
        CP     E
        JP     C,ER03__
        LD     A,E
        DEFB   06H
SMBL1:  XOR    A
        POP    DE
        POP    BC
        LD     C,A             ;angle push
        LD     A,B             ;string length
        OR     A
        RET    Z               ;zero return
        LD     A,C             ;angle pop
        PUSH   HL
        EX     DE,HL
        LD     DE,DIRARE
        RST    3
        DEFB   _SYMBL
        POP    HL
        RET
;

;
;;;;;;;;;;;;;;
;
;  HCOPY 1/2/3
;  CLS   1/2/3
;
HCOPY:
        CALL   ENDZ
        PUSH   HL
        LD     A,00H           ;ASAHI modify
        RST    3
        DEFB   _HCPY
        POP    HL
        RET
;
CLS:
        CALL   ENDZ
        PUSH   HL
        RST    3
        DEFB   _CLS
        POP    HL
        RET
;
;       END  (797AH)



;        ORG    797AH

; -----------------------------
; MZ-800 BASIC  Data conversion
; FI:CONV  ver 1.0A 7.18.84
; Programed by T.Miho
; -----------------------------
;

;
;
;
ENDZ:
        CALL   ENDCHK
        RET    Z
        JP     ER01
;
TESTP:
        XOR    A
        LD     (FILOUT),A
        CALL   TEST1
        DEFB   0FBH             ;/
        RET    NZ              ;ZF=0
        CALL   TESTX
        DEFM   "P"
        CALL   LPTTMD          ;Check text mode
        LD     A,'P'
        LD     (FILOUT),A
        CP     A               ;ZF=1
        RET
;
ASCFIV:
        LD     DE,DGBF00
        LD     B,0             ;Zero sup.
        PUSH   DE
        RST    3
        DEFB   _ASCHL
        POP    DE
        RET

;
; Fetch subroutines
;
ICH28H:
        INC    HL
HCH28H:
        CALL   HLFTCH
CH28H:
        CP     '('
        JR     CHXX2
;
HCH29H:
        CALL   HLFTCH
CH29H:
        CP     ')'
        JR     CHXX2
;
HCH2CH:
        CALL   HLFTCH
CH2CH:
        CP     ','
;
CHXX2:  INC    HL
        RET    Z
        JP     ER01
;
SKPDI:
        INC    DE
SKPDE:
        LD     A,(DE)
        CP     ' '
        JR     Z,SKPDI
        RET
;
;
;(DE)=1.0
LDIR1:
        LD     HL,FLONE
;(DE)=(HL) 5BYTES SET
LDIR5:
        LD     BC,5
        LDIR
        RET

;
;(HL)=DE
FLTHEX:
        CALL   CLRFAC          ;EXT(FLOAT)
        LD     A,E
        OR     D
        RET    Z
        BIT    7,D
        LD     A,7FH
        JR     Z,NORFLH
        LD     A,D
        CPL
        LD     D,A
        LD     A,E
        CPL
        LD     E,A
        INC    DE
        LD     A,0FFH
;
NORFLH: LD     B,91H
SFL:    DEC    B
        BIT    7,D
        JR     NZ,FLHXRT
        RL     E
        RL     D
        JR     SFL
FLHXRT: LD     (HL),B
        INC    HL
        AND    D
        LD     (HL),A
        INC    HL
        LD     (HL),E
        DEC    HL
        DEC    HL
        RET
;
;0-9 THEN CY=0
TSTNUM:
        CP     '0'
        RET    C
        CP     ':'
        CCF
        RET
;
;VAR THEN CY=0
TSTVAR:
        CP     5FH
        RET    Z
        CP     '0'
        RET    C
        CP     5BH
        CCF
        RET    C
        CP     ':'
        CCF
        RET    NC
        CP     41H
        RET

;
;CONV FLOAT(HL)_ASC(DE)
CVFLAS:
        CALL   CLRFAC          ;EXT
        LD     (DGITCO),A
        LD     (DGITFG),A
        LD     (EXPFLG),A
        LD     (PRODFL+1),A
        LD     A,5
        LD     (PRCSON),A
DEFTCL: CALL   SKPDE
        INC    DE
        CP     '+'
        JR     Z,DEFTCL
        CP     '-'
        JR     NZ,CHKAND
        CALL   DEFTCL
        JP     TOGLE
;
CHKAND: CP     '$'
        JR     NZ,ZRSKIP
        PUSH   HL
        EX     DE,HL
        RST    3
        DEFB   _DEHEX
        EX     (SP),HL
        CALL   FLTHEX
        POP    DE
        LD     A,5
        RET
;
ZRSKIP: CP     '0'
        JR     NZ,MDLAG
        LD     A,(DE)
        INC    DE
        JR     ZRSKIP
;
FTCHL:  LD     A,(DE)
        INC    DE
MDLAG:  CP     ' '
        JR     Z,FTCHL
        CP     '.'
        JR     Z,POINTS
        CALL   TSTNUM
        JR     C,TST23H
        SUB    '0'
        CALL   MULTEN
        CALL   MULDEC
        LD     A,1
        LD     (DGITFG),A
        LD     A,(DGITCO)
        INC    A
        LD     (DGITCO),A
        JR     FTCHL
;
POINTS: LD     A,1
        LD     (PRODFL+1),A
        LD     C,A
POINT_: LD     A,(DE)
        INC    DE
        CP     ' '
        JR     Z,POINT_
        CALL   TSTNUM
        JR     C,PESC
        INC    C
        SUB    '0'
        JR     Z,SDFGRE
        PUSH   AF
        LD     A,1
        LD     (DGITFG),A
        POP    AF
SDFGRE: PUSH   AF
        LD     A,(DGITFG)
        LD     B,A
        LD     A,(DGITCO)
        ADD    A,B
        LD     (DGITCO),A
        POP    AF
        CALL   MULTEN
        CALL   MULDEC
        JR     POINT_
;
PESC:   DEC    C
        JR     Z,TST23H
        CALL   DIVTEN
        JR     PESC
;
;
TST23H: CP     'E'
        JR     Z,EXPON_
;
TSTPRC: DEC    DE
        LD     A,(EXPFLG)
        OR     A
        RET    NZ
PRODFL: LD     A,0             ;xxx
        OR     A
        RET    NZ
        LD     A,5
        RET
;
EXPON_: LD     A,(DE)
        CP     '-'
        JR     Z,EXPON
        CP     '+'
        JR     Z,EXPON
        CALL   TSTNUM
        JR     C,TSTPRC
EXPON:  LD     A,1
        LD     (PRODFL+1),A
        PUSH   HL
        LD     HL,MUL
        LD     (EXJPVC),HL
        LD     HL,0000H
        LD     A,(DE)
        INC    DE
        CP     '+'
        JR     Z,CBEGIN
        CP     '-'
        JR     NZ,CLMIDL
        PUSH   HL
        LD     HL,DIV
        LD     (EXJPVC),HL
        POP    HL
CBEGIN: LD     A,(DE)
        INC    DE
CLMIDL: SUB    '0'
        JR     C,ESCPER
        CP     0AH
        JR     NC,ESCPER
        PUSH   DE
        CALL   ADHLCK
        LD     E,L
        LD     D,H
        CALL   ADHLCK
        CALL   ADHLCK
        CALL   ADDECK
        LD     E,A
        LD     D,0
        CALL   ADDECK
        POP    DE
        JR     CBEGIN
ESCPER: LD     A,H
        OR     A
        JR     NZ,OVERF_
        LD     A,L
        POP    HL
        PUSH   DE
        PUSH   BC
        PUSH   HL
        LD     DE,ZFAC
        PUSH   DE
        CALL   LDIR1
        POP    HL
        LD     B,A
        INC    B
        JR     $+5
        CALL   MULTEN
        DJNZ   $-3
        EX     DE,HL
        POP    HL
        DEFB   0CDH
EXJPVC: DEFS   2
        POP    BC
        POP    DE
        JP     TSTPRC
;
DIVTEN: PUSH   AF
        PUSH   BC
        PUSH   DE
        LD     DE,FLTEN
        CALL   DIV
        POP    DE
        POP    BC
        POP    AF
        RET
;
ADDECK: ADD    HL,DE
        RET    NC
        JR     OVERF_
;
ADHLCK: ADD    HL,HL
        RET    NC
OVERF_: JP     ER02            ;OVERFLOW
;
MULDEC: PUSH   DE
        PUSH   HL
        LD     HL,ZFAC         ;*****
        LD     E,A
        LD     D,0
        CALL   FLTHEX
        EX     DE,HL
        POP    HL
        PUSH   BC
        CALL   ADD
        POP    BC
        POP    DE
        RET
;
;
;CONV ASC(DE)_FLOAT(HL)
CVNMFL:
        LD     A,5
        LD     (PRCSON),A
        LD     A,(HL)
        OR     A
        JR     Z,ONLYZ_
        INC    HL
        LD     A,(HL)
        DEC    HL
        RLCA
ONLYZ_: LD     A,20H
        JR     NC,PLUS
        CALL   TOGLE
        LD     A,'-'
PLUS:   PUSH   AF
        CALL   CVASF1
        CALL   ADJDGT
        POP    AF
        DEC    DE
        LD     (DE),A
        RET
;
;
CMP2:   PUSH   BC
        CALL   CMP
        POP    BC
        RET

;
INT:
        CALL   PUSHR
        LD     A,(HL)
        CP     81H
        JP     C,CLRFAC
        LD     A,(HL)
        CP     0A0H
        RET    NC
        INC    HL
        CALL   RCHLBC
        PUSH   HL
        LD     L,(HL)
        LD     B,0
INTSFL: SRL    E
        RR     D
        RR     C
        RR     L
        INC    A
        INC    B
        CP     0A0H
        JR     NZ,INTSFL
INTSBL: SLA    L
        RL     C
        RL     D
        RL     E
        DJNZ   INTSBL
        LD     A,L
        POP    HL
        LD     (HL),A
        DEC    HL
        LD     (HL),C
        DEC    HL
        LD     (HL),D
        DEC    HL
        LD     (HL),E
        RET
;
RCHLBC: LD     E,(HL)
        INC    HL
        LD     D,(HL)
        INC    HL
        LD     C,(HL)
        INC    HL
        RET

;
FRACT:
        LD     A,(HL)
        CP     81H
        RET    C
        PUSH   DE
        PUSH   HL
        LD     DE,FRACW
        PUSH   DE
        CALL   LDIR5
        POP    HL
        CALL   INT
        EX     DE,HL
        POP    HL
        CALL   SUB
        POP    DE
        RET
;
FRACW:  DEFS   5
;
;
MULTEN: PUSH   AF
        PUSH   BC
        PUSH   DE
        LD     DE,FLTEN
        CALL   MUL
        POP    DE
        POP    BC
        POP    AF
        RET

;
HLFLT:
        INC    HL
        BIT    7,(HL)
        JR     Z,NORHLC
        CALL   NORHLC
        LD     A,H
        CPL
        LD     H,A
        LD     A,L
        CPL
        LD     L,A
        INC    HL
        RET
;
NORHLC: DEC    HL
        LD     A,(HL)
        CP     91H
        JP     NC,ER02         ;OVERFLOW
        CP     81H
        JR     C,HXZRRT
        PUSH   AF
        INC    HL
        LD     A,(HL)
        INC    HL
        LD     L,(HL)
        LD     H,A
        POP    AF
        SET    7,H
HXFLSL: CP     90H
        RET    Z
        INC    A
        SRL    H
        RR     L
        JR     HXFLSL
;
HXZRRT: CCF
        LD     HL,0
        RET
;
;
SNGMXO: DEFB   0x9B,0x3E,0xBC,0x20,0x00

SNGMXP: DEFB   0x98,0x18,0x96,0x80,0x00
        DEFB   0x94,0x74,0x24,0x00,0x00
        DEFB   0x91,0x43,0x50,0x00,0x00
        DEFB   0x8E,0x1C,0x40,0x00,0x00
        DEFB   0x8A,0x7A,0x00,0x00,0x00
        DEFB   0x87,0x48,0x00,0x00,0x00

FLTEN:
        DEFB   0x84,0x20,0x00,0x00,0x00

FLONE:
        DEFB   0x81,0x00,0x00,0x00,0x00

        DEFB   0x7D,0x4C,0xCC,0xCC,0xCD

SLLMT:  DEFB   0x66,0x2B,0xCC,0x77,0x12


;
EXPASC: LD     HL,(HLBUF2)
        LD     B,0
TENCOM: LD     DE,FLTEN
        CALL   CMP2
        JR     C,ONECOM
        CALL   DIVTEN
        INC    B
        JR     TENCOM
ONECOM: LD     DE,FLONE
        CALL   CMP2
        JR     NC,COMOK
        CALL   MULTEN
        DEC    B
        JR     ONECOM
COMOK:  PUSH   BC
        CALL   CVASF1
        CALL   ADJDGT
        POP    BC
        PUSH   DE
        EX     DE,HL
SERNOP: LD     A,(HL)
        OR     A
        JR     Z,SEROK
        INC    HL
        JR     SERNOP
SEROK:  DEC    HL
        LD     A,(HL)
        INC    HL
        CP     '0'
        JR     NZ,USEXPE
        INC    B
        DEC    HL
USEXPE: LD     A,'E'
        LD     (HL),A
        INC    HL
        LD     A,B
        LD     B,'+'
        BIT    7,A
        JR     Z,EXSGPT
        NEG
        LD     B,'-'
EXSGPT: LD     (HL),B
        INC    HL
        LD     (HL),'0'
EXTNPT: SUB    0AH
        JR     C,EXONPT
        INC    (HL)
        JR     EXTNPT
EXONPT: ADD    A,3AH
        INC    HL
        LD     (HL),A
        INC    HL
        LD     (HL),0
        POP    DE
        RET

;
INTPAR: PUSH   HL
        CALL   HLFLT
        LD     DE,DGBF11
        PUSH   DE
        LD     B,1             ;Non zero-sup.
        RST    3
        DEFB   _ASCHL
        POP    HL
        LD     A,'0'
        LD     B,5
        CP     (HL)
        JR     NZ,INTDGO
        INC    HL
        DJNZ   $-4
        JR     INTDGE
INTDGO: LD     A,B
        LD     (DGITCO),A
        LD     A,1
        LD     (DGITFG),A
INTDGE: LD     A,'.'
        LD     (DGBF16),A
        POP    HL
        CALL   FRACT
        JP     FRACDG
;
;
CVASF1: LD     (HLBUF2),HL
        XOR    A
        LD     (DGITCO),A
        LD     (DGITFG),A
        PUSH   HL
        LD     HL,DGBF07
        LD     (HL),0FFH
        LD     B,33
        LD     A,'0'
        INC    HL
        LD     (HL),A
        DJNZ   $-2
        LD     A,'.'
        LD     (DGBF16),A
        POP    HL
        LD     A,(HL)
        OR     A
        RET    Z
        LD     DE,SNGMXO
        CALL   CMP
        CCF
        RET    C
        LD     DE,SLLMT
        CALL   CMP
        RET    C
        LD     DE,ZFAC1
        PUSH   DE
        CALL   LDIR5
        POP    HL
        LD     A,(HL)
        CP     81H
        JR     C,FRACDG        ;
        CP     90H
        JP     C,INTPAR        ;
        LD     IX,DGBF08
        LD     DE,SNGMXP
        CALL   GENDGT
        CALL   GEND_
        RET    NC              ;C=0
FRACDG: LD     IX,DGBF17
FRCAGN: LD     DE,SNGMXO
        PUSH   BC
        PUSH   IX
        CALL   MUL
        POP    IX
        POP    BC
        INC    DE
        INC    DE
        INC    DE
        INC    DE
        INC    DE
        CALL   GENDGT
        CALL   GEND_
        JR     C,FRCAGN
        RET
;
;
CVASFL:
        LD     A,5
        LD     (PRCSON),A
        PUSH   HL
        LD     DE,ZFAC2
        PUSH   DE
        CALL   LDIR5
        POP    HL
        CALL   CVASF1
        CALL   ADJDG2
        POP    HL
        RET
;
ZERADJ: LD     DE,DGBF16
        LD     (DE),A
        DEC    DE
        RET
;
ADJDG2: JP     C,EXPASC
ADJDGT: LD     HL,(HLBUF2)
        LD     A,(HL)
        OR     A
        JR     Z,ZERADJ
        LD     DE,DGBF08
        DEC    DE
        EX     DE,HL
        LD     DE,1
SSNTO1: INC    HL
        LD     A,(HL)
        CP     '.'
        JR     NZ,TST30H
        LD     DE,0
        JR     SSNTO1
TST30H: CP     '0'
        JR     Z,SSNTO1
        ADD    HL,DE
        LD     DE,8
        ADD    HL,DE
        LD     A,(HL)
FRCASL: LD     (HL),'0'
        CP     35H
        JR     C,BCKSER
ADDLOP: DEC    HL
        LD     A,(HL)
        CP     '.'
        JR     Z,ADDLOP
        INC    A
        JR     Z,MAXNO
        LD     (HL),A
        CP     ':'
        JR     Z,FRCASL
        INC    HL
BCKSER: LD     DE,DGBF16
        EX     DE,HL
        OR     A
        SBC    HL,DE
        EX     DE,HL
        JR     C,KUMI
        LD     HL,DGBF16
        JR     INTDI2
KUMI:   DEC    HL
        LD     A,(HL)
        CP     '.'
        DEC    HL
        JR     Z,INTDIS
        INC    HL
        CP     '0'
        JR     Z,BCKSER
        PUSH   HL
        LD     DE,DGBF25
        SBC    HL,DE
        POP    HL
        JP     NC,EXPASC
INTDIS: INC    HL
INTDI2: LD     (HL),0
        LD     DE,DGBF08
TSTFST: LD     A,(DE)
        CP     '0'
        JR     NZ,ZEONLY
        INC    DE
        JR     TSTFST
ZEONLY: OR     A
        RET    NZ
        DEC    DE
        LD     A,'0'
        LD     (DE),A
        RET
;
;
MAXNO:  LD     HL,DGBF00
        LD     DE,M1E08
        PUSH   BC
        LD     BC,6
        LDIR
        POP    BC
        LD     DE,DGBF00
        RET
;
M1E08:  DEFM   "1E+08"

        DEFB   0
;
;
GENDGT: LD     A,(DE)
        CP     7DH
        RET    Z
INTGDL: CALL   CMP
        JR     C,GTESTB
        INC    (IX+0)
        PUSH   IX
        PUSH   BC
        CALL   SUB
        POP    BC
        POP    IX
        LD     A,1
        LD     (DGITFG),A
        JR     INTGDL
;
GTESTB: INC    IX
        INC    DE
        INC    DE
        INC    DE
        INC    DE
        INC    DE
        LD     A,(DGITFG)
        LD     B,A
        LD     A,(DGITCO)
        ADD    A,B
        LD     (DGITCO),A
        CALL   GEND_
        RET    NC
        JR     GENDGT
;
GEND_:  LD     A,(HL)
        OR     A
        RET    Z
        LD     A,(DGITCO)
        CP     9
        RET
;
DGITCO: DEFS   1
DGITFG: DEFS   1
EXPFLG: DEFS   1
HLBUF2: DEFS   2
;

;
; USING CONVERSION
;
USINGS:
        DEFS   2               ;USING START
USINGP:
        DEFS   2               ;USING POINTER
;
USNGSB:
        LD     HL,(USINGP)
        PUSH   DE
USNGS2: LD     A,(HL)
        OR     A
        JP     Z,ER03__
        CALL   USGCD
        JR     Z,USNGS4
        LD     (BC),A
        INC    BC
        INC    HL
        JR     USNGS2
USNGS4: EX     AF,AF
        LD     A,(PRCSON)
        CP     3
        JP     NZ,FLTUSG
        EX     AF,AF
        CP     '!'
        JP     Z,CHOUT1
        CP     '&'
        JP     Z,CHOUT2
        JP     ER04
;
CHOUT1: EX     (SP),HL
        PUSH   BC
        CALL   CVTSDC
        OR     A
        LD     A,' '
        JR     Z,$+3
        LD     A,(DE)
        POP    BC
        LD     (BC),A
        INC    BC
AFTPR_: POP    HL
        INC    HL
AFTPRT: LD     A,(HL)
        OR     A
        JR     Z,BRTUSG
        CALL   USGCD
        JR     Z,RETUSG
        LD     (BC),A
        INC    BC
        INC    HL
        JR     AFTPRT

BRTUSG: LD     HL,(USINGS)
RETUSG: LD     (USINGP),HL
        XOR    A
        LD     (BC),A
        RET
;
CHOUT2: LD     D,2
AG2CH_: INC    HL
        LD     A,(HL)
        CP     '&'
        JR     Z,_26FOUN
        INC    D
        CP     ' '
        JR     Z,AG2CH_
        JP     ER03__
_26FOUN: EX     (SP),HL
        LD     A,(HL)
        CP     D
        JR     C,TRIZ__
        INC    HL
        CALL   INDRCT
        PUSH   BC
        LD     BC,(STRST)
        ADD    HL,BC
        POP    BC
_PRLOP: LD     A,(HL)
        LD     (BC),A
        INC    BC
        INC    HL
        DEC    D
        JR     NZ,_PRLOP
        JP     AFTPR_
;
TRIZ__: LD     E,(HL)
        INC    HL
        CALL   INDRCT
        LD     A,E
        OR     A
        JR     Z,__SPCF
        PUSH   BC
        LD     BC,(STRST)
        ADD    HL,BC
        POP    BC
PR__L1: LD     A,(HL)
        LD     (BC),A
        INC    BC
        INC    HL
        DEC    E
        JR     Z,__SPC_
        DEC    D
        JR     NZ,PR__L1
        JP     AFTPR_
__SPCF: LD     A,' '
        LD     (BC),A
        INC    BC
__SPC_: DEC    D
        JR     NZ,__SPCF
        JP     AFTPR_

;
; Check using code
;
USGCD:  CALL   CHKACC
        DEFB   4
        DEFM   "!&#+"
        RET    Z
        LD     E,A
        CP     '*'
        JR     Z,USGCD2
        CALL   POND
        JR     Z,USGCD2
        CP     '.'
        LD     E,'#'
        JR     Z,USGCD2
        CP     _BAR
        RET    NZ
        INC    HL
        LD     A,(HL)
        OR     A
        JP     Z,ER03__
        RET
USGCD2: INC    HL
        LD     A,(HL)
        CP     E
        DEC    HL
        LD     A,(HL)
        RET
;
;
FLTUSG: XOR    A
        LD     (FPLUSF),A
        LD     (PUASTF),A      ;PUT * FLG
        LD     (PUYENF),A      ;]
        LD     (PUAFMF),A      ;AFTER-FLG
        LD     (PUCOMF),A      ;PUT , FLG
        LD     (INTLEN),A      ;INT LENGTH
        LD     (RPLUSF),A      ;###+
        LD     (PUEXPF),A      ;^^^^
        DEC    A
        LD     (FRCLEN),A      ;FRAC LENGTH
        EX     AF,AF
        LD     D,0
        CP     '#'
        JP     Z,PFLENG
        CP     '*'
        JP     Z,ASTRSK
        CALL   POND
        JP     Z,YENUSG
        CP     '.'
        JP     Z,PULSLS
        CP     '+'
        JP     Z,PLUSUS
        JP     ER04
;
ASTRSK: LD     A,1
        LD     (PUASTF),A
        INC    HL
        INC    D
        INC    HL
        INC    D
        LD     A,(HL)
        CALL   POND
        JR     NZ,PULSLS
        JR     YENUS2
;
YENUSG: INC    HL
        INC    D
YENUS2: INC    HL
        INC    D
        LD     (PUYENF),A
        JR     PULSLS
;
PLUSUS: LD     A,1
        LD     (FPLUSF),A
;
PFLENG: INC    HL
        INC    D
;
PULSLS: EX     DE,HL
        DEC    H
PUGTFC: INC    H
        LD     A,(DE)
        INC    DE
        CP     '#'
        JR     Z,PUGTFC
        CP     ','
        JR     NZ,PUCONP
        LD     A,1
        LD     (PUCOMF),A
        JR     PUGTFC
PUCONP: CP     '.'
        JR     Z,PUPOIT
        CP     '-'
        JR     NZ,PUAFMO
        LD     A,1
        LD     (PUAFMF),A
        INC    DE
        JR     PUAFQO
PUAFMO: CP     '+'
        JR     NZ,PUAFQO
        LD     A,(FPLUSF)
        OR     A
        JR     NZ,PUAFQO
        LD     A,1
        LD     (RPLUSF),A
        INC    DE
PUAFQO: DEC    DE
        LD     A,H
        LD     (INTLEN),A
        JR     BEGUSG
;
PUPOIT: LD     A,H
        LD     (INTLEN),A
        LD     H,0FFH
PUPOFC: INC    H
        LD     A,(DE)
        INC    DE
        CP     '#'
        JR     Z,PUPOFC
        CP     '-'
        JR     NZ,PUCOPQ
        LD     A,1
        LD     (PUAFMF),A
        INC    DE
        JR     PUCOPP
PUCOPQ: CP     '+'
        JR     NZ,PUCOPP
        LD     A,(FPLUSF)
        OR     A
        JR     NZ,PUCOPP
        LD     A,1
        LD     (RPLUSF),A
        INC    DE
PUCOPP: DEC    DE
        LD     A,H
        LD     (FRCLEN),A
        JR     BEGUSG
;
NEXPP_: POP    DE
        JR     NEXPPU
;
BEGUSG: LD     H,4
        PUSH   DE
CHEXPU: LD     A,(DE)
        INC    DE
        CP     '^'
        JR     NZ,NEXPP_
        DEC    H
        JR     NZ,CHEXPU
        POP    AF
        LD     A,1
        LD     (PUEXPF),A
NEXPPU: POP    HL
        PUSH   DE
        INC    HL
        LD     A,(HL)
        RES    7,(HL)
        DEC    HL
        LD     (USGSGN),A
        LD     A,(INTLEN)
        LD     D,A
        DEFB   3EH
FRCLEN: DEFS   1
        LD     E,A
        DEFB   3EH
PUEXPF: DEFS   1
        PUSH   BC
        CALL   USNGCV
        POP    BC
        DEFB   3EH
PUCOMF: DEFS   1
        OR     A
        JR     Z,LADJS1
        PUSH   BC
        PUSH   DE
        LD     A,(INTLEN)
        LD     L,A
        LD     H,0
        ADD    HL,DE
        LD     DE,DGBF00
        LD     C,0
        DEC    HL
COMN3D: LD     B,3
COMSK3: LD     A,(HL)
        CP     ' '
        JR     Z,ESCPUC
        INC    C
        LD     (DE),A
        INC    DE
        DEC    HL
        DJNZ   COMSK3
        LD     A,(HL)
        CP     ' '
        JR     Z,ESCPUC
        LD     A,','
        LD     (DE),A
        INC    DE
        INC    C
        JR     COMN3D
;
ESCPUC: DEFB   3EH
INTLEN: DEFS   1
        CP     C
        JP     C,ER02
        LD     B,C
        LD     L,A
        LD     H,0
        POP    DE
        PUSH   DE
        ADD    HL,DE
        LD     DE,DGBF00
        DEC    HL
        LD     A,(DE)
        LD     (HL),A
        DEC    HL
        INC    DE
        DJNZ   $-4
        POP    DE
        POP    BC
LADJS1: DEFB   3EH
PUAFMF: DEFS   1
        OR     A
        JR     NZ,LADJS2
        DEFB   3EH
RPLUSF: DEFS   1
        OR     A
        JR     NZ,LADJS2
        DEFB   3EH
FPLUSF: DEFS   1
        OR     A
        JR     NZ,PTPLS1
        LD     A,(USGSGN)
        RLCA
        JR     NC,LADJS2
        LD     A,(DE)
        CP     ' '
        LD     H,'-'
        JR     Z,FPUTER
        CP     30H
        JP     NZ,ER02
FPUTER: PUSH   DE
PUPTML: LD     A,(DE)
        INC    DE
        CP     ' '
        JR     Z,PUPTML
        CP     30H
        JR     Z,PUPTML
        OR     A
        JR     NZ,$+3
        DEC    DE
        DEC    DE
        DEC    DE
        LD     A,H
        LD     (DE),A
        POP    DE
        JR     LADJS2
;
PTPLS1: DEFB   3EH
USGSGN: DEFS   1
        RLCA
        LD     H,'+'
        JR     NC,FPUTER
        LD     H,'-'
        JR     FPUTER
;
LADJS2: DEFB   3EH
PUYENF: DEFS   1
        OR     A
        JR     Z,LADJS3
        LD     A,(DE)
        CP     ' '
        JR     NZ,LADJS3
        PUSH   DE
        LD     A,(DE)
        INC    DE
        CP     ' '
        JR     Z,$-4
        DEC    DE
        DEC    DE
        LD     A,(PUYENF)
        LD     (DE),A
        POP    DE
LADJS3: DEFB   3EH
PUASTF: DEFS   1
        OR     A
        JR     Z,LADJS4
        PUSH   DE
ASTFIL: LD     A,(DE)
        CP     ' '
        JR     NZ,LADJ4_
        LD     A,'*'
        LD     (DE),A
        INC    DE
        JR     ASTFIL
LADJ4_: POP    DE
LADJS4: LD     A,(DE)
        OR     A
        JR     Z,USPRL8
        LD     (BC),A
        INC    BC
        INC    DE
        JR     LADJS4
USPRL8: LD     A,(RPLUSF)
        OR     A
        JR     Z,TST2DH        ;-
        LD     A,(USGSGN)
        RLCA
        LD     A,'+'
LSDVZR: JR     NC,PULSTX
        LD     A,'-'
PULSTX: LD     (BC),A
        INC    BC
        JR     RETPU_
;
TST2DH: LD     A,(PUAFMF)      ;-
        OR     A
        JR     Z,RETPU_
        LD     A,(USGSGN)
        RLCA
        LD     A,' '
        JR     LSDVZR
;
RETPU_: POP    HL              ; RETPU$
        JP     AFTPRT
;
;
POND:   CP     _POND           ;EX
        RET    Z
        CP     '$'
        RET

;
USNGCV: OR     A
        JP     Z,USGCV2
        PUSH   DE
        LD     A,(HL)
        OR     A
        JR     Z,USCMOK
        PUSH   HL
        LD     A,D
        LD     DE,ZFAC1
        PUSH   AF
        CALL   LDIR1
        POP    AF
        OR     A
        JR     Z,BMULED
        LD     B,A
        LD     HL,ZFAC1
        JR     $+5
        CALL   MULTEN
        DJNZ   $-3
BMULED: POP    HL
        LD     B,0
USTNCM: LD     DE,ZFAC1
        CALL   CMP2
        JR     C,USTOCM
        CALL   DIVTEN
        INC    B
        JR     USTNCM
USTOCM: PUSH   HL
        LD     HL,ZFAC1
        CALL   DIVTEN
        POP    HL
USONCM: LD     DE,ZFAC1
        CALL   CMP2
        JR     NC,USCMOK
        CALL   MULTEN
        DEC    B
        JR     USONCM

USCMOK: POP    DE
        PUSH   BC
        CALL   USGCV1
        POP    BC
        PUSH   DE
        LD     A,(DE)
        CP     '.'
        JR     NZ,FLADSR
        LD     DE,DGBF16
        DEC    DE
        LD     A,(DE)
        CP     31H
        POP    DE
        PUSH   DE
        JR     NZ,USEX0C
        EX     DE,HL
        INC    HL
        LD     (HL),31H
        DEC    HL
        JR     MIDDCX
;
FLADSR: LD     A,(DE)
        CP     31H
        JR     NZ,USEX0C
        EX     DE,HL
        INC    HL
        LD     A,(HL)
        DEC    HL
        CP     '.'
        LD     A,'0'
        JR     Z,$+4
        LD     A,' '
        LD     (HL),A
        INC    HL
        LD     A,(HL)
        CP     '.'
        JR     Z,$-4
        LD     (HL),31H
MIDDCX: EX     DE,HL
        INC    B
USEX0C: LD     A,(DE)
        INC    DE
        OR     A
        JR     NZ,USEX0C
        DEC    DE
        JP     USEXPE
;
USGCV2: PUSH   DE
        CALL   USGCV1
        POP    AF
        OR     A
        RET    NZ
        PUSH   HL
        LD     HL,DGBF16
        DEC    HL
        LD     A,'0'
        CP     (HL)
FOVVXC: JP     NZ,ER02
        DEC    HL
        LD     A,' '
        CP     (HL)
        JR     NZ,FOVVXC
        POP    HL
        RET
;
USGCV1: PUSH   DE
        CALL   CVASF1
        JP     C,ER02
        POP    HL
        PUSH   HL
        LD     H,0
        INC    L
        JR     Z,$+3
        DEC    L
        LD     DE,DGBF17
        ADD    HL,DE
        LD     A,(HL)
        LD     (HL),0
        DEFB   11H
FRCASU: LD     (HL),'0'
        CP     35H
        JR     C,BCKSEU
        DEC    HL
        LD     A,(HL)
        CP     '.'
        JR     Z,$-4
        INC    A
        JP     Z,ER02
        LD     (HL),A
        CP     ':'
        JR     Z,FRCASU
BCKSEU: LD     HL,KEYBM1       ;¯¯KEYBUF
        LD     DE,2000H
        LD     (HL),D
        INC    HL
        DEC    E
        JR     NZ,$-3
        POP    HL
        PUSH   HL
        LD     E,H
        LD     D,0
        LD     HL,KEYBUF
        ADD    HL,DE
        PUSH   HL
        LD     HL,DGBF07
        LD     (HL),' '
        INC    HL
        LD     D,7
BF00SP: LD     A,(HL)
        CP     '0'
        JR     NZ,BF00ED
        LD     (HL),' '
        INC    HL
        DEC    D
        JR     NZ,BF00SP
BF00ED: POP    HL
        PUSH   HL
        LD     B,E
        LD     A,B
        OR     A
        JR     Z,BFST11
        LD     DE,DGBF16
BFSTL1: DEC    HL
        DEC    DE
        LD     A,(DE)
        LD     (HL),A
        CP     ' '
        JR     Z,BFST11
        DJNZ   BFSTL1
        DEC    DE
        LD     A,(DE)
        CP     ' '
        JR     Z,BFST11
        INC    A
        JP     NZ,ER02
;
BFST11: POP    HL
        POP    DE
        INC    E
        JR     Z,EDSTRT
        LD     B,E
        LD     DE,DGBF17
        LD     (HL),'.'
BFSTL2: INC    HL
        DEC    B
        JR     Z,EDSTRT
        LD     A,(DE)
        INC    DE
        LD     (HL),A
        JR     BFSTL2
EDSTRT: LD     (HL),0
        LD     DE,KEYBUF
        RET
;
;       END    (8216H)


;        ORG    8216H

; ------------------------------------
; MZ-800 BASIC  Interm.code conversion
; FI:EDIT  ver 1.0A 7.18.84
; Programed by T.Miho
; ------------------------------------
;

;
CVIMTX:
        PUSH   DE
        PUSH   BC
        LD     C,0
        DEC    DE
CVIM10: INC    DE
CVIM12: CALL   IMSPACE
        OR     A
        JR     Z,IMEND
        CP     0FFH
        JR     Z,IMPAI
        CP     80H
        JP     NC,ER01
        CP     20H
        JR     C,CVIM10
        LD     IX,CVIM12
        PUSH   IX
        CP     '"'
        JR     Z,IMSTR
        CP     '\''
        JR     Z,IMREM
        CP     '?'
        JR     Z,IMPRT
        CP     '.'
        JP     Z,IMFLT
        CP     '$'
        JP     Z,IMHEX
        CALL   TSTNUM
        JR     C,IMRSV
        JP     IMNUM
;
IMEND:  LD     (HL),A
        POP    BC
        POP    DE
        RET
;
IMPAI:  LD     (HL),0E4H
        CALL   IM3R
        JR     CVIM12
;
IMPRT:  LD     A,8FH
        CALL   IM3RS
        JR     IMRSV6
;
IMREM:  LD     (HL),':'
        CALL   IM3R
        LD     (HL),'\''
        CALL   IM3RH
        JP     IMDATA

;
IMSTR:  LD     (HL),A
        CALL   IM3R
IMSTR2: LD     A,(DE)
        OR     A
        RET    Z
        CP     '"'
        JR     NZ,IMSTR
IM3RS:  LD     (HL),A
IM3R:   INC    DE
IM3RH:  INC    HL
IM3RC:  INC    C
        RET    NZ
        JP     ER08            ;LINE LENGTH
;
IMVAR:  POP    BC
        LD     A,(DE)
        CALL   TSTVAR
        JR     C,IM3RS
IMVAR2: CALL   IM3RS
        LD     A,(DE)
        CP     '$'
        JR     Z,IM3RS
        CALL   TSTNUM
        RET    C
        JR     IMVAR2
;
IMRSV:  PUSH   BC
        LD     BC,CTBL1
        CALL   IMSER
        JR     NC,IMRSV4
        LD     BC,GTABL
        CALL   IMSER
        LD     C,0FEH
        JR     NC,IMRSV2
        LD     BC,CTBL2
        CALL   IMSER
        LD     C,0FFH
        JR     C,IMVAR
IMRSV2: LD     (HL),C
        INC    HL
        LD     (HL),A
        POP    BC
        CALL   IM3RC
        CALL   IM3RH
        CP     0B4H             ; ERL ******
        RET    NZ
        CALL   IMSPACE
        CP     '='
        RET    NZ
        LD     (HL),0F4H           ; = ******
        CALL   IM3R
        JR     IMLNO

;
IMRSV4: POP    BC
        CALL   IM3RH
IMRSV6: CP     97H             ; REM
        JR     Z,IMDATA
        CP     94H             ; DATA
        JR     Z,IMDATA
        CP     0C2H             ; ELSE
        JR     Z,IMELSE
        CP     0E2H             ; THEN
        JR     Z,IMLNO
        CP     0E0H
        RET    NC
        PUSH   AF
        CALL   IMSPACE
        CP     '/'
        JR     NZ,IMRSV7
        LD     (HL),0FBH           ;/
        CALL   IM3R
        CALL   SKPDE
        CALL   IM3RS
        JR     IMRSV8
IMRSV7: CP     '#'
        JR     NZ,IMRSV8
        CALL   IM3RS
        CALL   SKPDE
        CALL   TSTNUM
        CALL   NC,IMNUM
IMRSV8: POP    AF
        CP     8DH             ; FOR
        RET    NC
;
IMLNO:  CALL   IMSPACE
        CP     '"'
        JR     NZ,IMLNO2
        CALL   IMSTR
        JR     IMLNO
IMLNO2: CP     2CH
        RET    C
        CP     2FH
        JR     C,IMLNO4        ;",-."
        CALL   TSTNUM
        RET    C
        CALL   IMINT
        JR     IMLNO
IMLNO4: CALL   IM3RS
        JR     IMLNO
;
IMELSE: DEC    HL
        LD     (HL),':'
        INC    HL
        LD     (HL),A
        CALL   IM3RH
        JR     IMLNO
;
IMDATA: LD     A,(DE)
        CALL   ENDCK0
        RET    Z
        CALL   IM3RS
        CP     '"'
        CALL   Z,IMSTR2
        JR     IMDATA
;
;
IMSER:  PUSH   HL              ;Search in tabale
        PUSH   DE
        LD     HL,BC
        LD     B,7FH
IMSER2: POP    DE
        PUSH   DE
        INC    B
        LD     A,(HL)
        CP     0FFH
        JR     NZ,IMSER3
        POP    DE              ;Table end
        POP    HL
        SCF
        RET
;
IMSER3: CP     '.'
        JR     NZ,IMSER4
        INC    HL              ;AND OR XOR NOT
        DEC    DE
        LD     A,(DE)
        INC    DE
        CALL   TSTVAR
        JR     NC,IMSER6
IMSER4: LD     A,(DE)
        CP     ' '
        JR     NZ,IMSER5
        LD     A,(HL)
        AND    7FH
        SUB    'A'
        CP     26
        JR     C,IMSER6
        CALL   SKPDI
IMSER5: LD     C,(HL)
        INC    HL
        INC    DE
        CP     '.'
        JR     Z,IMSER8
        SUB    C
        JR     Z,IMSER4
        CP     80H
        JR     Z,IMSER9
IMSER6: DEC    HL              ;Not match
        BIT    7,(HL)
        INC    HL
        JR     Z,$-3
        JR     IMSER2
IMSER8: LD     A,B
        CP     0E8H             ;operator
        JR     NC,IMSER6
        CCF
IMSER9: POP    HL              ;Found
        POP    HL
        LD     (HL),B
        LD     A,B
        RET
;
IMSPACE:LD     A,(DE)
        CP     ' '
        RET    NZ
        LD     (HL),A
        CALL   IM3R
        JR     IMSPACE

;
IMNUM:  EX     AF,AF
        PUSH   DE
        CALL   SKPDI
        POP    DE
        CALL   TSTNUM          ;check if one-digit
        JR     NC,IMFLT
        CP     '.'
        JR     Z,IMFLT
        CP     'E'
        JR     Z,IMFLT
        EX     AF,AF
        SUB    '0'-1
        JP     IMFLT           ;ok, JP IM3RS
;
IMFLT:  PUSH   BC
        LD     (HL),15H
        INC    HL
        PUSH   HL
        CALL   CVFLAS
        POP    HL
        LD     BC,5
        ADD    HL,BC
        LD     A,6
        JR     BCKSPS
;
IMINT:  PUSH   BC
        CALL   CVBCAS
        LD     (HL),0BH
        INC    HL
        JR     PPOLNO
;
IMHEX:  LD     (HL),A
        INC    DE
        LD     A,(DE)
        RST    3
        DEFB   _CKHEX
        JP     C,IM3RH
        PUSH   BC
        LD     (HL),11H
        INC    HL
        PUSH   HL
        EX     DE,HL
        RST    3
        DEFB   _DEHEX
        LD     BC,DE
        EX     DE,HL
        POP    HL
PPOLNO: LD     A,3
        LD     (HL),C
        INC    HL
        LD     (HL),B
        INC    HL
BCKSPS: POP    BC
        ADD    A,C
        JP     C,ER08          ;LINE LENGTH
        LD     C,A
BCKSKP: DEC    DE
        LD     A,(DE)
        CP     ' '
        JR     Z,$-4
        INC    DE
        RET

;
CVTXIM:
        PUSH   HL
        PUSH   DE
        PUSH   BC
        EXX
        LD     B,0
        EXX
        LD     C,0
CVTX10: LD     A,(HL)
        OR     A
        JR     Z,TXEND
        LD     BC,CVTX10
        PUSH   BC
        CP     '\''
        JR     Z,TXDAT2
        INC    HL
        LD     BC,CTBL1
        CP     20H
        JR     C,TXNUM
        CP     '"'
        JR     Z,TXSTR
        CP     ':'
        JR     Z,TX3AH
        CP     97H             ;REM
        JR     Z,TXDATA
        CP     94H             ;DATA
        JR     Z,TXDATA
        CP     0E4H             ;PI
        JR     Z,TXPAI
        CP     0FEH
        JR     NC,TXRSV0
        CP     80H
        JP     NC,TXRSV
        JP     STRDE
;
TXEND:  LD     (DE),A
        POP    BC
        POP    DE
        POP    HL
        RET
;
TXPAI:  LD     A,0FFH
        JP     STRDE
;
TXRSV0: LD     BC,CTBL2
        JR     NZ,$+5
        LD     BC,GTABL
        LD     A,(HL)
        INC    HL
        JR     TXRSV
;
TXDATA: CALL   TXRSV
        RET    Z
TXDAT2: LD     A,(HL)
        CALL   ENDCK0
        RET    Z
        CALL   STRDE
        LD     A,(HL)
        INC    HL
        CP     '"'
        CALL   Z,TXSTR2
        JR     TXDAT2
;
TXSTR:  CALL   STRDE
TXSTR2: LD     A,(HL)
        OR     A
        RET    Z
        INC    HL
        CP     '"'
        JR     NZ,TXSTR
        JR     STRDE
;
TX3AH:  LD     (DE),A
        LD     A,(HL)
        CP     0C2H             ; ELSE
        RET    Z
        CP     '\''
        RET    Z
        JR     STRDE_
;
TXNUM:  CP     15H
        JR     Z,TXFLT
        CP     0BH
        JR     NC,TXINT
        DEC    A
        OR     30H
        JR     STRDE
;
TXINT:  PUSH   DE
        LD     E,(HL)
        INC    HL
        LD     D,(HL)
        INC    HL
        PUSH   HL
        CP     12H
        JR     Z,TXINT2
        CP     0CH
        JR     C,TXINT2
        JR     NZ,TXHEX
        EX     DE,HL
        INC    HL
        INC    HL
        LD     E,(HL)
        INC    HL
        LD     D,(HL)
TXINT2: EX     DE,HL
        CALL   ASCFIV
        LD     BC,DE
        POP    HL
        POP    DE
TXINT4: LD     A,(BC)
        OR     A
        RET    Z
        CALL   STRDE
        INC    BC
        JR     TXINT4
;
TXFLT:  PUSH   HL
        PUSH   DE
        CALL   CVASFL
        LD     BC,DE
        POP    DE
        POP    HL
        INC    HL
        INC    HL
        INC    HL
        INC    HL
        INC    HL
        JR     TXINT4
;
TXRSV:  CP     80H
        JR     Z,TXRSV4
        EX     AF,AF
TXRSV2: LD     A,(BC)
        RLCA
        INC    BC
        JR     NC,TXRSV2
        EX     AF,AF
        DEC    A
        JR     TXRSV
TXRSV4: LD     A,(BC)
        BIT    7,A
        JR     NZ,STRDES
        CP     '.'
        CALL   NZ,STRDE
        INC    BC
        JR     TXRSV4
;
STRDES: AND    7FH
STRDE:  LD     (DE),A
        OR     A
        RET    Z
STRDE_: INC    DE
        EXX
        INC    B
        EXX
        RET    NZ
        XOR    A
        LD     (DE),A
        DEC    DE
        EXX
        DEC    B
        EXX
        RET
;
TXHEX:  LD     A,'$'
        EX     AF,AF
        EX     DE,HL
        CALL   HEXHL
        LD     BC,DE
        POP    HL
        POP    DE
        EX     AF,AF
        CALL   STRDE
        JR     TXINT4
;
HEXHL:
        LD     DE,DGBF12
        PUSH   DE
        LD     A,H
        CALL   HEXACC
        LD     A,L
        CALL   HEXACC
        XOR    A
        LD     (DE),A
        POP    DE
        LD     B,3
;
ZRSUP:  LD     A,(DE)
        CP     '0'
        RET    NZ
        INC    DE
        DJNZ   ZRSUP
        RET
;
HEXACC:
        PUSH   AF
        RRCA
        RRCA
        RRCA
        RRCA
        AND    0FH
        CALL   HEXAC2
        POP    AF
        AND    0FH
HEXAC2: ADD    A,30H
        CP     3AH
        JR     C,$+4
        ADD    A,7
        LD     (DE),A
        INC    DE
        RET
;
CVBCAS:
        PUSH   HL
        EX     DE,HL
        RST    3
        DEFB   _DEASC
        LD     BC,DE
        EX     DE,HL
        POP    HL
        JP     BCKSKP
;
;       END    (853DH)


;        ORG    853DH

; -----------------------------
; MZ-800 BASIC  Expression part
; FI:EXPR  ver 1.0A 8.25.84
; Programed by T.Miho
; -----------------------------
;
;

;
IBYTE:                    ;0..255
        CALL   IDEEXP
DCHECK:
        LD     A,D
        OR     A
        JP     NZ,ER03__
        LD     A,E
        RET
;
DEEXP:
        CALL   EXPR8
        DEC    DE
        DEC    DE
        DEC    DE
        DEC    DE
        DEC    DE
        JR     STDEFC
;
IDEEXP:                    ;DE=(HL)
        CALL   EXPR
STDEFC:
        PUSH   AF
        PUSH   HL
        EX     DE,HL
        CALL   STROMT
        CALL   HLFLT
        EX     DE,HL
        POP    HL
        POP    AF
        RET
;
STREXP:
        CALL   EXPR
        PUSH   AF
        CALL   STROK
        PUSH   HL
        EX     DE,HL
        CALL   CVTSDC
        POP    HL
        POP    AF
        RET
;
CVTSDC:
        LD     B,(HL)
        INC    HL
        LD     E,(HL)
        INC    HL
        LD     D,(HL)
        LD     HL,(STRST)
        ADD    HL,DE
        EX     DE,HL
        LD     A,B
        RET

;
EXPR:
        LD     DE,(VARED)
        LD     (TMPEND),DE
EXPRNX:
        LD     DE,(INTFAC)
        PUSH   DE
        CALL   EXPR8
        POP    DE
        RET
;
EXPR8:  PUSH   DE
        LD     DE,(TMPEND)
        CALL   MEMECK
        POP    DE
;
;
EXPR7:  CALL   EXPR6
EXPR7L: CP     0EAH             ;XOR
        RET    NZ
        LD     A,(PRCSON)
        PUSH   AF
        INC    HL
        CALL   EXPR6
        POP    BC
        PUSH   AF
        PUSH   HL
        CALL   ADJUST
        CALL   _XOR_
        POP    HL
        POP    AF
        JR     EXPR7L
;
EXPR6:  CALL   EXPR5
EXPR6L: CP     0EBH             ;OR
        RET    NZ
        LD     A,(PRCSON)
        PUSH   AF
        INC    HL
        CALL   EXPR5
        POP    BC
        PUSH   AF
        PUSH   HL
        CALL   ADJUST
        CALL   _OR_
        POP    HL
        POP    AF
        JR     EXPR6L
;
EXPR5:  CALL   EXPR4
EXPR5L: CP     0ECH             ;AND
        RET    NZ
        LD     A,(PRCSON)
        PUSH   AF
        INC    HL
        CALL   EXPR4
        POP    BC
        PUSH   AF
        PUSH   HL
        CALL   ADJUST
        CALL   _AND_
        POP    HL
        POP    AF
        JR     EXPR5L
;
EXPR4:
        CALL   TEST1
        DEFB   0EDH             ;NOT
        JR     NZ,EXPR3
        CALL   EXPR3
        PUSH   AF
        PUSH   HL
        LD     HL,-5
        ADD    HL,DE
        CALL   _NOT_
        POP    HL
        POP    AF
        RET

EXPR3:  CALL   EXPR2
EXPR3L: CP     0EEH            ;><
        RET    C
        PUSH   AF              ;stk OPC
        LD     A,(PRCSON)
        PUSH   AF              ;stk OPC, PRCSON
        INC    HL
        CALL   EXPR2
        POP    BC              ;stk OPC;      B=PRCSON
        EX     (SP),HL         ;stk RJOB;     HL=OPC
        PUSH   AF              ;stk RJOB,NEXT
        PUSH   HL              ;stk RJOB,NEXT,OPC
        CALL   ADJUST
        CALL   CMP
        EX     AF,AF           ;AF' = result
        POP    AF              ;stk RJOB,NEXT; A=OPC
        CP     0F6H            ;<
        JR     NZ,NXTCP1
        EX     AF,AF
        JR     C,TRUE
FALSE:  LD     BC,0
RLBACK: LD     (HL),C
        INC    HL
        LD     (HL),B
        INC    HL
        XOR    A
        LD     (HL),A
        INC    HL
        LD     (HL),A
        INC    HL
        LD     (HL),A
        LD     A,5
        LD     (PRCSON),A
        POP    AF              ;POP NEXT
        POP    HL              ;POP RJOB
        JR     EXPR3L
;
TRUE:   LD     BC,8081H
        JR     RLBACK
;
NXTCP1: CP     0F5H             ;>
        JR     NZ,NXTCP2
        EX     AF,AF
        JR     Z,FALSE
        JR     C,FALSE
        JR     TRUE
;
NXTCP2: CP     0F4H             ;=
        JR     NZ,NXTCP3
        EX     AF,AF
        JR     Z,TRUE
        JR     FALSE
;
NXTCP3: CP     0F2H             ;=>,>=
        JR     C,NXTCP4
        EX     AF,AF
        JR     NC,TRUE
        JR     FALSE
;
NXTCP4: CP     0F0H             ;=<,<=
        JR     C,NXTCP5
        EX     AF,AF
        JR     Z,TRUE
        JR     C,TRUE
        JR     FALSE
;
NXTCP5: EX     AF,AF            ;<>,><
        JR     Z,FALSE
        JR     TRUE
;
;
EXPR2:  CALL   EXPR1
EXPR2L: CP     0F7H             ;+,-
        RET    C
        LD     A,(PRCSON)
        PUSH   AF
        INC    HL
        JR     Z,EXPR2A         ;+
        CALL   EXPR1
        POP    BC
        PUSH   AF
        PUSH   HL
        CALL   ADJUST
        CALL   SUB
EXPR2X: POP    HL
        POP    AF
        JR     EXPR2L
EXPR2A: CALL   EXPR1
        POP    BC
        PUSH   AF
        PUSH   HL
        CALL   ADJUST
        CALL   ADD
        JR     EXPR2X
;
;
EXPR1:  CALL   EXPR0
EXPR1L: CP     0F9H             ;MOD, YEN
        RET    C
        LD     A,(PRCSON)
        PUSH   AF
        INC    HL
        JR     Z,EXPR1A         ;YEN
        CALL   EXPR0
        POP    BC
        PUSH   AF
        PUSH   HL
        CALL   ADJUST
        CALL   MOD
EXPR1X: POP    HL
        POP    AF
        JR     EXPR1L
EXPR1A: CALL   EXPR0
        POP    BC
        PUSH   AF
        PUSH   HL
        CALL   ADJUST
        CALL   YEN
        JR     EXPR1X
;
;
EXPR0:  CALL   EXPRZ
EXPR0L: CP     0FBH             ;/,*
        RET    C
        LD     A,(PRCSON)
        PUSH   AF
        INC    HL
        JR     Z,EXPR0A         ;/
        CALL   EXPRZ
        POP    BC
        PUSH   AF
        PUSH   HL
        CALL   ADJUST
        CALL   MUL
EXPR0X: POP    HL
        POP    AF
        JR     EXPR0L
EXPR0A: CALL   EXPRZ
        POP    BC
        PUSH   AF
        PUSH   HL
        CALL   ADJUST
        CALL   DIV
        JR     EXPR0X
;
EXPRZ:
        CALL   TEST1
        DEFB   0F7H             ;+
        JR     Z,EXPRZ
        CP     0F8H             ;-
        JR     NZ,EXPRY
        INC    HL
        CALL   EXPRY
        JR     EXPRX2
;
EXPRY:  CALL   FACTOR
EXPRYL: CP     0FDH             ;^
        RET    NZ
        LD     A,(PRCSON)
        PUSH   AF
        INC    HL
        CALL   EXPRX
        POP    BC
        PUSH   AF
        PUSH   HL
        CALL   ADJUST          ;
        CALL   POWERS          ;(HL)^(DE)
        POP    HL
        POP    AF
        JR     EXPRYL
;
EXPRX:
        CALL   TEST1
        DEFB   0F7H             ;+
        JR     Z,EXPRX
        CP     0F8H             ;-
        JR     NZ,FACTOR
        INC    HL
        CALL   FACTOR
EXPRX2: PUSH   AF
        PUSH   HL
        LD     HL,-5
        ADD    HL,DE
        CALL   NEG
        POP    HL
        POP    AF
        RET
;

FACTOR: CALL   ENDCHK
        JP     Z,ER01
        CALL   FAC0
        JP     HLFTCH
;
FAC0:   PUSH   HL
        LD     HL,(MEMLMT)
        SCF
        SBC    HL,DE
        JP     C,ER06__          ;TOO COMPLEX EXPR
        POP    HL
        CP     0E4H             ;PI
        JR     Z,FACPAI
        CP     20H
        JR     NC,VARFNC       ;IM 20 ....
;
FACNUM:                    ;Factor(numeric)
        INC    HL
        CP     15H
        JR     C,FACINT
        CALL   LDIR5           ;IM 15
        JR     FACR5
FACPAI: INC    HL
        PUSH   HL
        LD     HL,FLTPAI
        CALL   LDIR5
        POP    HL
FACR5:  LD     A,5
FACRX:  LD     (PRCSON),A
        RET
;
FACINT: CP     0BH             ;IM 00 .. 14
        JR     NC,FACI4
        DEC    A
        JP     M,ER01          ;IM 00
        LD     B,0
        LD     C,A
        JR     FACI6
;
FACI4:  LD     C,(HL)             ;IM 0B .. 14
        INC    HL
        LD     B,(HL)
        INC    HL
        CP     0CH
        JR     NZ,FACI6
        INC    BC
        INC    BC
        LD     A,(BC)
        INC    BC
        EX     AF,AF
        LD     A,(BC)
        LD     B,A
        EX     AF,AF
        LD     C,A
FACI6:  PUSH   HL
        PUSH   DE
        EX     DE,HL
        LD     E,C
        LD     D,B
        CALL   FLTHEX
        POP    DE
        POP    HL
        LD     A,5
FACRX5:
        INC    DE
        INC    DE
        INC    DE
        INC    DE
        INC    DE
        JR     FACRX
;
VARFNC: CP     '"'
        JR     NZ,VARFN1
        INC    HL
        PUSH   HL
        CALL   STRLCK          ;B=len(HL str.)
        EX     (SP),HL         ;New text point
        PUSH   HL              ;Old text point
        LD     HL,(TMPEND)
        PUSH   BC
        LD     BC,(STRST)
        OR     A
        SBC    HL,BC           ;HL=OFSET+ADR
        POP    BC
        EX     DE,HL
        LD     (HL),B             ;FAC set len.
        INC    HL
        LD     (HL),E             ;FAC set adrs
        INC    HL
        LD     (HL),D
        INC    HL
        INC    HL
        INC    HL
        POP    DE              ;Old text point
        PUSH   HL              ;New expr point
        LD     HL,(TMPEND)
        CALL   STRENT          ;(HL)_(DE),B
        LD     (TMPEND),HL
        POP    DE              ;New expr point
        POP    HL              ;New text point
        LD     A,3
        LD     (PRCSON),A
        RET
;
VARFN1: CP     '('
        JR     NZ,FUNC
        INC    HL              ;( ... )
        CALL   EXPR8
        JP     CH29H
;
;
;
FUNC:   OR     A               ;Function
        JP     P,VARFN2
        CP     0E7H             ;SPC ==>
        INC    HL
        JR     NZ,FUNC1
        LD     B,5             ;param is numeric
        LD     A,0A8H           ;   SPACE$
        PUSH   AF
        JR     FUNC2
FUNC1:  CP     0FFH
        JP     NZ,ER01
        LD     A,(HL)
        INC    HL
        CP     0A0H
        JP     Z,CHR_OP        ;CHR$
        CP     0C8H
        JP     NC,ER01
        CP     0BAH
        JR     NC,GETJPA       ;complex
        CP     9CH             ;JOY STICK
        JR     Z,GETJPA
        CP     9DH             ;JOY STRIG
        JP     Z,GETJPA
        PUSH   AF
        CP     0B3H
        JR     NC,SYSV         ;system var
        LD     B,3
        CP     0ABH
        JR     NC,FUNC2        ;param is string
        LD     B,5             ;param is numeric
        CP     88H             ;RND
        JR     Z,RNDONL
FUNC2:  CALL   HCH28H
FUNC4:  PUSH   BC
        CALL   EXPR8
        CALL   CH29H
        POP    AF
        CALL   STRCK
FUNC6:  POP    AF
        PUSH   DE
        PUSH   HL
        LD     HL,-5
        ADD    HL,DE
        CALL   GETJPA
        POP    HL
        POP    DE
        RET
;
;
RNDONL:
        CALL   TEST1
        DEFM   "("
        JR     Z,FUNC4
SYSV:   LD     A,5
        LD     (PRCSON),A
        PUSH   HL
        LD     HL,FLONE
        CALL   LDIR5
        POP    HL
        JR     FUNC6

;
GETJPA: PUSH   HL
        ADD    A,A
        LD     L,A
        LD     H,0
        LD     BC,FJPTBL
        ADD    HL,BC
        LD     A,(HL)
        INC    HL
        LD     H,(HL)
        LD     L,A
        EX     (SP),HL
        RET
;
SIZE:
        EX     DE,HL
        LD     HL,-527
        ADD    HL,SP
        LD     BC,(TMPEND)
        OR     A
        SBC    HL,BC
        EX     DE,HL
        JR     NC,PUT2B
        XOR    A
        JR     PUT1B
;
CSRH:
        LD     A,(CURX)
        JR     PUT1B
CSRV:
        LD     A,(CURY)
        JR     PUT1B
POSH:
        LD     DE,(POINTX)
        JR     PUT2B
POSV:
        LD     DE,(POINTY)
        JR     PUT2B
ERR:
        LD     A,(ERRCOD)
PUT1B:  LD     E,A
        LD     D,0
PUT2B:  LD     A,5
        LD     (PRCSON),A
        JP     FLTHEX
;
ERL:
        LD     DE,(ERRLNO)
        CALL   FLTHEX
        INC    HL
        BIT    7,(HL)
        DEC    HL
        RET    Z
        LD     DE,FL64K
        JP     ADD
;
FL64K:  DEFB   0x91,0x00,0x00,0x00,0x00  ;65536

;
CHR_OP: CALL   HCH28H
        LD     B,0
CHR_LP: PUSH   BC              ;counter
        PUSH   DE              ;FAC
        CALL   DEEXP
        CALL   DCHECK
        POP    DE              ;FAC
        POP    BC              ;counter
        PUSH   AF              ;data
        INC    B
        CALL   TEST1
        DEFM   ","
        JR     Z,CHR_LP
        CALL   CH29H
        LD     A,B             ;length
        EXX
        LD     B,A
        LD     HL,(TMPEND)     ;string start
        CALL   ADDHLA
        LD     DE,HL           ;string end+1
        CALL   MEMECK
CHR_4:  DEC    HL
        POP    AF              ;data
        LD     (HL),A
        DJNZ   CHR_4
        EXX
        LD     A,B             ;length
        EXX
        LD     B,A
;
;HL=String start
;DE=String end+1
;B =String length
;DE'=FAC
;HL'=TEXT,??
;
STEXR2: LD     (TMPEND),DE
        LD     DE,(STRST)
        OR     A
        SBC    HL,DE
        PUSH   HL
        LD     A,B
        EXX
        EX     DE,HL
        LD     (HL),A
        INC    HL
        POP    BC
        LD     (HL),C
        INC    HL
        LD     (HL),B
        LD     BC,3            ;
        ADD    HL,BC
STRPRS: EX     DE,HL
        LD     A,3
        LD     (PRCSON),A
        RET

;
HEX_S:
        PUSH   HL
        CALL   HLFLT
        CALL   HEXHL
        RST    3
        DEFB   _COUNT
;
; DE:adrs
; B:length
; (SP):Text pointer
;
PUTSTR:
        LD     A,B
        OR     A
        JR     Z,NULSPC
        LD     HL,(TMPEND)
        PUSH   HL
        PUSH   BC
        CALL   STRENT
        POP    BC
        EX     DE,HL
        POP    HL
        EXX
        POP    DE
        EXX
        JR     STEXR2
NULSPC: POP    HL
        CALL   CLRFAC
        JR     STRPRS
;
SPACE_S:
        PUSH   HL
        CALL   HLINCK
        LD     B,A
        LD     C,A
        OR     A
        LD     A,' '
        PUSH   DE
        CALL   NZ,SETDE
        POP    DE
        LD     B,C
        JR     PUTSTR
;
HLINCK: CALL   HLFLT
        LD     DE,KEYBUF
        LD     A,H
        OR     A
        JP     NZ,ER03__
        LD     A,L
        RET

;
;
STR_S:
        PUSH   HL
        CALL   CVNMFL
        LD     A,(DE)
        CP     ' '
        JR     NZ,$+3
        INC    DE
        RST    3
        DEFB   _COUNT
        JR     PUTSTR
;

EOF:
        CALL   HCH28H
        CALL   GETLU
        LD     B,A
        CALL   HCH29H
        LD     A,B
        PUSH   HL
        PUSH   DE
        RST    3
        DEFB   _SEGAD
        LD     DE,-1
        JR     C,EOF2
        INC    HL
        BIT    __EOF,(HL)
        JR     NZ,EOF2
        LD     DE,0
EOF2:   POP    HL
        CALL   FLTHEX
        LD     A,5
        LD     (PRCSON),A
EOF8:
        INC    HL
        INC    HL
        INC    HL
        INC    HL
        INC    HL
        EX     DE,HL
        POP    HL
        RET
;
POINT:
        CALL   HCH28H
        PUSH   DE              ;EXPR pointer
        CALL   DEEXP           ;X
        LD     BC,DE           ;X
        POP    DE              ;EXPR pointer
        PUSH   DE              ;EXPR pointer
        PUSH   BC              ;X
        CALL   CH2CH
        CALL   DEEXP           ;Y
        CALL   CH29H
        EX     (SP),HL         ;HL=X
        EX     DE,HL
        RST    3
        DEFB   _POINT
        INC    A
        JP     Z,ER03__        ;Out of range
        DEC    A
        POP    DE              ;TEXT pointer
        POP    HL              ;EXPR pointer
        PUSH   DE              ;TEXT pointer
        CALL   PUT1B
        JR     EOF8

;
ASC:
        PUSH   HL
        CALL   CVTSDC
        OR     A
        JR     Z,$+3
        LD     A,(DE)
        JR     LEN2
;
LEN:
        PUSH   HL
        CALL   CVTSDC
LEN2:   POP    HL
        JP     PUT1B
;
VAL:
        PUSH   HL
        CALL   CVTSDC
        LD     HL,(TMPEND)
        PUSH   HL
        CALL   STRENT
        LD     (HL),0
        POP    DE
        POP    HL
        JP     CVFLAS

;
LEFT_S:
        CALL   CH28EX
        CALL   CH29H
        CALL   BCHECK
        EX     DE,HL
        LD     A,(HL)
        CP     C
        JR     NC,$+3
        LD     C,A
        LD     (HL),C
        LD     BC,5
FACSTR: LD     A,3
        ADD    HL,BC
        EX     DE,HL
        LD     (PRCSON),A
        JP     HLFTCH
;
RIGHT_S:
        CALL   CH28EX
        CALL   CH29H
        CALL   BCHECK
        EX     DE,HL
        LD     A,(HL)
        SUB    C
        JR     NC,MID_EE
        XOR    A
        LD     C,(HL)
MID_EE: LD     (HL),C
        INC    HL
        ADD    A,(HL)
        LD     (HL),A
        INC    HL
        JR     NC,$+3
        INC    (HL)
        LD     BC,3            ;
        JR     FACSTR

;
MID_S:
        CALL   CH28EX
        CALL   BCHECK
        OR     A
        JP     Z,ER03__
        PUSH   AF
        CALL   TEST1
        DEFM   ")"
        LD     A,0FFH
        JR     Z,MID_2
        CALL   HCH2CH
        PUSH   DE
        EX     DE,HL
        LD     BC,5
        ADD    HL,BC
        EX     DE,HL
        CALL   DEEXP
        CALL   CH29H
        CALL   DCHECK
        POP    DE
MID_2:  POP    BC
        LD     C,A
        EX     DE,HL
        LD     A,(HL)
        SUB    B
        JR     C,MIDNUL
        INC    A
        CP     C
        JR     NC,$+3
        LD     C,A
        LD     A,B
        DEC    A
        JR     MID_EE
;
MIDNUL: XOR    A
        LD     C,A
        JR     MID_EE
;
BCHECK: LD     A,B
        OR     A
        JP     NZ,ER03__
        LD     A,C
        RET
;
CH28EX: CALL   HCH28H
        PUSH   DE
        CALL   EXPR8
        CALL   CH2CH
        CALL   STROK
        CALL   DEEXP
        LD     C,E
        LD     B,D
        POP    DE
        RET

;
TI_S:
        PUSH   HL
        PUSH   DE
        LD     HL,(TMPEND)
        PUSH   HL
        LD     A,'0'
        LD     B,6
        CALL   SETHL
        RST    3
        DEFB   _TIMRD          ;A,DE
        POP    HL
        OR     A
        JR     Z,TI_S2
        INC    (HL)
        INC    HL
        INC    (HL)
        INC    (HL)
        DEC    HL
TI_S2:   EX     DE,HL
        LD     BC,8CA0H        ;10H
        CALL   CLDGIT
        LD     BC,0E10H         ;1H
        CALL   CLDGIT
        CP     3AH
        JR     C,TI_S4
        SUB    10
        DEC    DE
        LD     (DE),A
        DEC    DE
        LD     A,(DE)
        INC    A
        LD     (DE),A
        INC    DE
        INC    DE
TI_S4:   DEC    DE
        DEC    DE
        LD     A,(DE)
        INC    DE
        LD     B,A
        LD     A,(DE)
        INC    DE
        LD     C,A
        LD     A,B
        CP     32H
        JR     NZ,TI_S6
        LD     A,C
        CP     34H
        JR     NZ,TI_S6
        LD     HL,(TMPEND)
        LD     A,'0'
        LD     B,6
        CALL   SETHL
        JR     TI_S8
TI_S6:   LD     BC,258H         ;10M
        CALL   CLDGIT
        LD     BC,3CH          ;1M
        CALL   CLDGIT
        LD     BC,0AH          ;10S
        CALL   CLDGIT
        LD     A,30H
        ADD    A,L
        LD     (DE),A
TI_S8:   LD     HL,(TMPEND)
        LD     DE,6
        EX     DE,HL
        ADD    HL,DE
        LD     (TMPEND),HL
        EX     DE,HL
        LD     DE,(STRST)
        OR     A
        SBC    HL,DE
        EX     DE,HL
        POP    HL
        LD     (HL),6
        INC    HL
        LD     (HL),E
        INC    HL
        LD     (HL),D
        INC    HL
        INC    HL
        INC    HL
        EX     DE,HL
        POP    HL
        LD     A,3
        LD     (PRCSON),A
        JP     HLFTCH
;
CLDGIT: OR     A
        SBC    HL,BC
        JR     C,CLDGRT
        LD     A,(DE)
        INC    A
        LD     (DE),A
        JR     CLDGIT
CLDGRT: ADD    HL,BC
        INC    DE
        RET
;
TIMDAI:
        CALL   TESTX
        DEFB   0F4H             ;TI$=....
        CALL   STREXP
        LD     A,B
        CP     6
        JP     NZ,ER03__
        PUSH   HL
        PUSH   DE
        LD     HL,0
        CALL   TIMASC
        CP     24
        JP     NC,ER03__
        CP     12
        LD     A,0
        JR     C,TIMDA2
        PUSH   DE
        LD     DE,12
        OR     A
        SBC    HL,DE
        POP    DE
        INC    A
TIMDA2: PUSH   AF
        CALL   TIMASC
        CP     60
        JP     NC,ER03__
        CALL   TIMASC
        CP     60
        JP     NC,ER03__
        POP    AF
        EX     DE,HL
        RST    3
        DEFB   _TIMST
        POP    DE
        POP    HL
        RET
;
TIMASC: PUSH   DE
        LD     D,H
        LD     E,L
        ADD    HL,HL
        ADD    HL,HL
        ADD    HL,DE
        LD     D,H
        LD     E,L
        ADD    HL,HL
        ADD    HL,DE
        ADD    HL,HL
        ADD    HL,HL
        POP    DE
        LD     A,(DE)
        INC    DE
        SUB    30H
        JP     C,ER03__
        CP     0AH
        JP     NC,ER03__
        PUSH   BC
        LD     C,A
        ADD    A,A
        ADD    A,A
        ADD    A,C
        ADD    A,A
        LD     C,A
        LD     A,(DE)
        INC    DE
        SUB    30H
        JP     C,ER03__
        CP     0AH
        JP     NC,ER03__
        ADD    A,C
        LD     C,A
        LD     B,0
        ADD    HL,BC
        POP    BC
        RET

;
INTGTV:
        LD     DE,(VARED)
        LD     (TMPEND),DE
        LD     DE,(INTFAC)
GETVAR: PUSH   DE
        CALL   VSRTST
GETFNV: LD     A,(HL)
        CP     '('
        JP     Z,ARRAY
        PUSH   HL
        CALL   CHVRNM
        JR     NC,CRNVAR
        LD     A,C
        LD     C,L
        LD     B,H
        POP    HL
        POP    DE
        RET
;
CRNVAR: LD     A,(DE)
        ADD    A,C             ;VAR.LEN.+TYPE
        ADD    A,2
        PUSH   BC
        EX     DE,HL
        LD     HL,(TMPEND)
        PUSH   HL
        OR     A
        SBC    HL,DE
        INC    HL
        LD     C,L
        LD     B,H
        POP    HL
        PUSH   DE
        EX     DE,HL
        LD     L,A
        LD     H,0
        ADD    HL,DE
        EX     DE,HL
        CALL   MEMECK
        LDDR
        LD     E,A
        LD     D,0
        RST    3
        DEFB   _ADDP2
        POP    HL
        POP    BC
        LD     DE,KEYBUF
        LD     (HL),C             ;TYPE SET
        INC    HL
        SCF
        SBC    A,C             ;B=A-C-1
        LD     B,A
VARSL1: LD     A,(DE)          ;VAR.LEN.&NAME
        LD     (HL),A
        INC    DE
        INC    HL
        DJNZ   VARSL1
        PUSH   HL
        LD     B,C
        CALL   CLRHL          ;VAR.CLR
        LD     (HL),A             ;VAR.END MARK
        LD     A,C
        POP    BC
        POP    HL
        POP    DE
        RET
;
VSRTST: CALL   HLFTCH
        SUB    'A'
        CP     26
        JP     NC,ER01
        LD     DE,KEYBUF
        LD     B,0
VSRTS1: INC    DE
        LD     A,(HL)
        CALL   TSTVAR
        JR     C,TSTTYP
        LD     (DE),A
        INC    B
        LD     A,B
        CP     3
        JR     C,$+3
        DEC    B
        INC    HL
        JR     VSRTS1
TSTTYP: LD     DE,KEYBUF
        EX     DE,HL
        LD     (HL),B
        EX     DE,HL
        LD     C,5
        CP     24H             ;$
        RET    NZ
        LD     C,3
        INC    HL
        RET
;
ADJUST: LD     HL,-5
        EX     DE,HL
        ADD    HL,DE
        EX     DE,HL
        ADD    HL,DE
        LD     A,B
        JP     STRCK
;
;
STRLCK: LD     B,0FFH
STRLL1: INC    B
        LD     A,(HL)
        OR     A
        RET    Z
        INC    HL
        CP     '"'
        RET    Z
        JR     STRLL1
;
STRENT:
        LD     A,B
        OR     A
        RET    Z
        CALL   LDHLDE
        EX     DE,HL
        CALL   MEMECK
        EX     DE,HL
        RET
;
;
MEMECK:                    ;SBC SP,DE
        PUSH   HL
        LD     HL,-512
        ADD    HL,SP
        SBC    HL,DE
        POP    HL
        RET    NC
        JP     ER06_
;
;
;
; PUSH DE
; KEYBUF..LEN. NAME
; HL=(
;
ARRAY0: LD     DE,(INTFAC)
        PUSH   DE
        JR     ARRAY2
;
ARRAY:  XOR    A
        LD     (AUTDIM),A
        INC    HL
        LD     (ARYTXT),HL
ARRAY2: LD     B,0
        EXX
        POP    HL              ;POP FAC
        PUSH   HL              ;PUSH FAC
        PUSH   HL              ;PUSH FAC1
        LD     HL,(TMPEND)
        LD     DE,KEYBUF
        PUSH   HL
        LD     A,(DE)
        LD     (HL),A
        INC    DE
        INC    HL
        LD     B,A
        CALL   STRENT
        POP    DE
        LD     (TMPEND),HL
        LD     HL,(STRST)
        EX     DE,HL
        OR     A
        SBC    HL,DE
        EX     (SP),HL         ;NAME ADR.
        PUSH   HL              ;PUSH FAC1
        EXX
TSALOP: POP    DE              ;POP FAC1
        PUSH   DE              ;PUSH FAC1
        PUSH   BC              ;PUSH B,TYPE(C)
        LD     BC,(ARYTXT)
        LD     A,(AUTDIM)
        PUSH   BC
        PUSH   AF
        LD     BC,(DGBF00)
        PUSH   BC
        CALL   DEEXP           ;¯¯DE=EXP(INT)
        BIT    7,D
        JP     NZ,ER03__
        EX     AF,AF
        POP    BC
        LD     (DGBF00),BC
        POP    AF
        LD     (AUTDIM),A
        POP    BC
        LD     (ARYTXT),BC
        EX     AF,AF
        INC    HL
        CP     ')'
        JR     Z,TSFARY
        CP     ','
        JP     NZ,ER01
        POP    BC              ;POP B,TYPE(C)
        INC    B               ;(.,.,.,.)
        LD     A,B
        CP     4
        JP     NC,ER03__
        EXX
        POP    HL              ;POP FAC1
        POP    DE              ;POP NAME ADR.
        EXX
        PUSH   DE              ;ANS
        EXX
        PUSH   DE              ;PUSH NAME ADR.
        PUSH   HL              ;PUSH FAC1
        EXX
        JR     TSALOP
;
TSFARY: POP    BC              ;POP B,TYPE(C)
        EXX
        POP    HL              ;POP FAC1
        POP    DE              ;POP NAME ADR.
        EXX
        INC    B               ;ARRAY POINT
        PUSH   DE              ;ANS
        PUSH   HL              ;PUSH TEXT POINT
        EXX
        LD     HL,(STRST)
        ADD    HL,DE
        LD     B,(HL)
        INC    B
        LD     DE,KEYBUF
        CALL   LDDEHL
        EXX
        SET    7,C
        CALL   CHVRNM
        RES    7,C
        JR     NC,ARYDIM
        LD     A,B
        CP     (HL)
        JP     NZ,ER07         ;DUPLICATE
;LD A,(AUTDIM)
;OR A
;JP NZ,ER07
        INC    HL
        EX     DE,HL
        POP    HL
        LD     (DGBF00),HL     ;TEXT END
        EXX
        LD     HL,0000H
        EXX
        EX     DE,HL
ADRCL:  LD     E,(HL)
        INC    HL
        LD     D,(HL)
        INC    HL
        EX     (SP),HL
        PUSH   DE
        EXX
        POP    DE
        CALL   DIMMUL
        EXX
        PUSH   HL
        OR     A
        SBC    HL,DE
        JP     NC,ER03__
        EXX
        POP    DE
        CALL   DIMADD
        EXX
        POP    HL
        DJNZ   ADRCL
        PUSH   HL
        EXX
        LD     A,C
        LD     D,B
        BIT    6,A
        JR     NZ,VARDIM
        AND    0FH
        LD     E,A
        PUSH   AF
        CALL   DIMMUL
        PUSH   HL
        EXX
        POP    BC
        POP    AF
        POP    HL
        ADD    HL,BC
        LD     C,L
        LD     B,H
VARDME: LD     HL,(DGBF00)
        POP    DE
        RET
;
VARDIM: LD     E,(HL)
        INC    HL
        LD     D,(HL)
        POP    HL
        LD     C,L
        LD     B,H
        LD     (HL),E
        INC    HL
        LD     (HL),D
        AND    0FH
        JR     VARDME
;
;
ARYDIM: EXX
        LD     A,(AUTDIM)
        OR     A
        JP     Z,ER03__
        POP    HL              ;TEXT POINT
        LD     (DGBF00),HL
        EXX
        LD     DE,(TMPEND)
        LD     L,B
        LD     H,0
        ADD    HL,HL
        ADD    HL,DE
        EX     DE,HL
        INC    DE
        CALL   MEMECK
        LD     (HL),B
        INC    HL
        EXX
        LD     HL,1
        EXX
ADRCL_: POP    DE
        LD     A,(AUTDIM)
        OR     A
        JR     NZ,ADRC__
        PUSH   HL              ;1
        EX     DE,HL
        LD     DE,10
        SCF
        SBC    HL,DE
        JP     NC,ER03__
        POP    HL              ;1
ADRC__: INC    DE
        LD     (HL),E
        INC    HL
        LD     (HL),D
        INC    HL
        PUSH   DE
        EXX
        POP    DE
        CALL   DIMMUL
        EXX
        DJNZ   ADRCL_
        LD     E,C
        LD     D,0
        PUSH   BC
        PUSH   DE
        EXX
        POP    DE
        CALL   DIMMUL
        PUSH   HL
        EXX
        POP    BC
        PUSH   BC              ;2 A*B*C*D
        EX     DE,HL
        LD     HL,(TMPEND)     ;(.,.,.)*2
        LD     L,(HL)
        LD     H,0
        ADD    HL,HL
        LD     A,(KEYBUF)      ;+NAME
        ADD    A,5             ;+TY+LN+NL+(.,.)
        ADD    A,L
        LD     L,A
        LD     A,0
        ADC    A,H
        LD     H,A
        JR     C,DIMOVM
        ADD    HL,BC
        JR     C,DIMOVM
        PUSH   HL              ;3 LEN
        ADD    HL,DE           ;+TEMPEND
DIMOVM: JP     C,ER06_
        EX     DE,HL
        CALL   MEMECK
        PUSH   HL              ;4 TMPEND
        EXX
        POP    HL              ;4 TMPEND
        LD     BC,(STRST)      ;VAR END
        DEC    BC
        OR     A
        SBC    HL,BC
        PUSH   HL              ;4 TRANS LEN
        EXX
        POP    BC              ;4 TRANS LEN
        LDDR
        POP    DE              ;3 LEN
        RST    3
        DEFB   _ADDP2
        POP    BC              ;2 CLR LEN
        PUSH   DE              ;2 LEN
        EXX
        POP    DE              ;2 LEN
        LD     H,B
        LD     L,C
        POP    BC              ;1 TYPE
        LD     A,C
        OR     80H
        LD     (HL),A
        INC    HL
        DEC    DE
        LD     (HL),E
        INC    HL
        LD     (HL),D
        INC    HL
        LD     DE,KEYBUF
        LD     A,(DE)
        INC    A
        LD     B,A
        CALL   LDHLDE
        LD     DE,(TMPEND)
        LD     A,(DE)
        LD     (HL),A
        INC    HL
        INC    DE
        ADD    A,A
        LD     B,A
        CALL   LDHLDE
        PUSH   HL
        EXX
        POP    HL
DIMCLR: XOR    A
        LD     (HL),A
        INC    HL
        DEC    BC
        LD     A,B
        OR     C
        JR     NZ,DIMCLR
        LD     (HL),A
        EXX
        POP    DE
        LD     A,(AUTDIM)
        OR     A
        JR     Z,VARCUL
        LD     HL,(DGBF00)
        RET
;
VARCUL: LD     HL,(ARYTXT)
        PUSH   DE
        JP     ARRAY2

;
DIM:
        LD     A,0FFH
        LD     (AUTDIM),A
NXTDIM: CALL   VSRTST
        LD     A,(HL)
        CALL   CH28H
        CALL   ARRAY0
        CALL   HLFTCH
        CP     ','
        RET    NZ
        INC    HL
        JR     NXTDIM
;
DIMADD: ADD    HL,DE
        RET    NC
        JR     SORDIM
;
DIMMUL: PUSH   BC
        EX     DE,HL
        LD     C,L
        LD     A,H
        LD     HL,0
        CALL   DMMULS
        LD     A,C
        CALL   DMMULS
        POP    BC
        RET
;
DMMULS: OR     A
        JR     Z,SKPMUL
        LD     B,8
DMMULP: ADD    HL,HL
        JR     C,SORDIM
        RLCA
        JR     NC,DMMULE
        ADD    HL,DE
        JR     C,SORDIM
DMMULE: DJNZ   DMMULP
        RET
;
SKPMUL: LD     A,H
        LD     H,L
        LD     L,0
        OR     A
        RET    Z
SORDIM: JP     ER06__
;
;
ARYTXT: DEFS   2
AUTDIM: DEFS   1

;
VARFN2: SUB    'A'
        CP     26
        JP     NC,ER01
        LD     BC,(FNVRBF)
        LD     A,B
        OR     C
        JR     NZ,FNGTVR
        CALL   GETVAR
FNGTV2: PUSH   DE
        PUSH   HL
        LD     L,C
        LD     H,B
        LD     B,A
        LD     C,A
        CALL   LDDEHL
        POP    HL
        LD     A,C
        POP    DE
        JP     FACRX5
;
FNGTVR: PUSH   DE
        CALL   VSRTST
        PUSH   HL
        INC    B
        LD     DE,KEYBUF
        LD     HL,(TMPEND)
        CALL   STRENT
        LD     B,0
        LD     HL,(FNVRBF)
        CALL   HLFTCH
        CP     0F4H
        JR     Z,FNSHNO
        CP     '('
        JR     NZ,SERROL       ;¯¯JP NZ,ER01
FNGTL1: INC    HL
        INC    B
        PUSH   BC
        CALL   VSRTST
        LD     A,C
        POP    DE
        CP     E               ;TYPE
        LD     C,E             ;¯¯
        JR     NZ,FNGTL2
        PUSH   DE
        LD     C,B
        INC    C
        PUSH   HL
        LD     HL,(TMPEND)
        LD     DE,KEYBUF
        CALL   _HLDECK
        POP    HL
        POP    BC
        JR     Z,FNSHOK
FNGTL2: CALL   HLFTCH
        CP     ')'
        JR     Z,FNSHNO
        CP     ','
        JR     Z,FNGTL1        ;¯¯¯
SERROL: JP     ER01            ;¯¯
FNSHNO: LD     HL,(TMPEND)
        LD     DE,KEYBUF
        LD     A,(HL)
        LD     (DE),A
        LD     B,A
        INC    HL
        INC    DE
        LD     A,(HL)
        LD     (DE),A
        DJNZ   $-4
        POP    HL
        POP    DE
        CALL   FNGTV1
        JR     FNGTV2
;
FNSHOK: LD     HL,(FNTXBF)
        CALL   HCH28H
        DEC    B
        JR     Z,FNSH13
        DEC    HL
FNSH11: PUSH   BC
FNSH12: CALL   IFSKSB
        CALL   ENDCHK
        JP     Z,ER01
        CP     ')'
        JP     Z,ER01
        CP     ','
        JR     NZ,FNSH12
        POP    BC
        DJNZ   FNSH11
        INC    HL
FNSH13: EX     DE,HL
        POP    HL
        EX     (SP),HL
        EX     DE,HL
        LD     BC,(FNVRBF)
        PUSH   BC
        LD     BC,0
        LD     (FNVRBF),BC
        CALL   EXPR8
        POP    HL
        LD     (FNVRBF),HL
        POP    HL
        JP     HLFTCH
;
FNGTV1: PUSH   DE
        JP     GETFNV

;
CHVRNM:
        LD     HL,(VARST)
ASLOP:  LD     DE,KEYBUF
        LD     A,(HL)
        OR     A
        RET    Z
        CP     40H
        JR     NC,ARYATA
        CP     C
        JR     NZ,SKIPUS
        INC    HL
        LD     A,(DE)
        CP     (HL)
        JR     NZ,SKIPU2
        LD     B,A
VARCL1: INC    DE
        INC    HL
        LD     A,(DE)          ;ÛÛ
        CP     (HL)               ;ÛÛ
;CALL NZ,SMALCH
        JR     NZ,SKIPU3
        DJNZ   VARCL1
        INC    HL
        SCF
        RET
SKIPU3: INC    HL
        DJNZ   SKIPU3
        LD     A,C
        JR     ARSKFN
SKIPU2: LD     A,C
        DEC    HL
SKIPUS: AND    0FH             ;TYPE
        INC    HL
        ADD    A,(HL)          ;NAME LEN.
        INC    HL
ARSKFN: LD     E,A
        LD     D,0
       ADD    HL,DE
        JR     ASLOP
;
;
ARYATA: CP     C               ;TYPE
        JR     Z,ARMSN1
        INC    HL
MIDNAM: LD     E,(HL)
        INC    HL
        LD     D,(HL)
        DEC    HL
        ADD    HL,DE
        JR     ASLOP
;
NXTVR1: LD     A,C
        SUB    B
        CPL
        LD     C,A
        LD     B,0FFH
        ADD    HL,BC
        POP    BC
NXTVR:  DEC    HL
        DEC    HL
        JR     MIDNAM
;
;
ARMSN1: LD     A,(HL)
        EXX
        LD     C,A
        LD     B,00H
        EXX
        INC    HL
        PUSH   DE
        LD     E,(HL)
        INC    HL
        LD     D,(HL)
        INC    HL
        EX     DE,HL
        ADD    HL,DE
;LD (ARYEDA),HL
        EX     DE,HL
        POP    DE
        LD     A,(DE)
        CP     (HL)               ;NAME LEN.
        JR     NZ,NXTVR
        PUSH   BC
        LD     B,A
        LD     C,A
AYNMCK: INC    HL
        INC    DE
        LD     A,(DE)          ;ÛÛ
        CP     (HL)               ;ÛÛ
        JR     NZ,NXTVR1
        DJNZ   AYNMCK
        INC    HL
        POP    BC
        SCF
        RET

;
DEFFN:
        CALL   VSRTST
        SET    6,C
        PUSH   HL
        CALL   CHVRNM
        JP     C,ER07          ;ARY DEF ERR
        LD     (HL),C
        EX     (SP),HL
        PUSH   HL
        DEC    HL
FNSKP1: CALL   IFSKSB
        OR     A
        JR     Z,FNSKED
        CP     3AH             ;:
        JR     NZ,FNSKP1
FNSKED: POP    DE
        PUSH   HL
        INC    HL
        SBC    HL,DE
        LD     A,(KEYBUF)
        ADD    A,4
        LD     C,A
        LD     B,0
        LD     A,L
        ADD    HL,BC
        LD     B,A
        PUSH   HL
        EXX
        POP    BC
        PUSH   BC
        PUSH   HL
        PUSH   DE
        PUSH   BC
        LD     HL,0
        ADD    HL,SP
        LD     DE,(TMPEND)
        DEC    H
        OR     A
        SBC    HL,DE
        LD     A,12
        JP     C,NESTER
        POP    BC
        POP    DE
        POP    HL
        LD     HL,(TMPEND)
        PUSH   HL
        ADD    HL,BC
        EX     (SP),HL
        PUSH   HL
        LD     DE,(STRST)      ;VAR END
        OR     A
        SBC    HL,DE
        LD     C,L
        LD     B,H
        POP    HL
        POP    DE
        LDDR
        POP    DE
        RST    3
        DEFB   _ADDP2
        DEC    DE
        POP    HL
        EX     (SP),HL
        INC    HL
        LD     (HL),E
        INC    HL
        LD     (HL),D
        INC    HL
        LD     DE,KEYBUF
        LD     A,(DE)
        LD     (HL),A
        LD     B,A
        INC    DE
        INC    HL
        LD     A,(DE)
        LD     (HL),A
        DJNZ   $-4
        INC    HL
        PUSH   HL
        EXX
        POP    HL
        CALL   LDHLDE
        LD     (HL),0
        POP    HL
        RET
;
FNEXP:
        PUSH   DE
        CALL   VSRTST
        POP    IX
        PUSH   BC
        SET    6,C
        LD     DE,(FNTXBF)
        LD     (FNTXBF),HL
        PUSH   DE
        CALL   CHVRNM
        JP     NC,ER15         ;UNDEF FN
        LD     DE,(FNVRBF)
        LD     (FNVRBF),HL
        PUSH   DE
        PUSH   IX
        DEC    HL
FNEQSK: CALL   IFSKSB
        CALL   ENDCHK
        JP     Z,ER01
        CP     0F4H             ;=
        JR     NZ,FNEQSK
        INC    HL
        POP    DE
        PUSH   DE
        CALL   EXPR8
        POP    DE
        LD     HL,(FNTXBF)
        POP    BC
        LD     (FNVRBF),BC
        POP    BC
        LD     (FNTXBF),BC
        EX     DE,HL
        POP    BC
        LD     A,C
        CALL   STRCK
        LD     BC,5
        ADD    HL,BC
        EX     DE,HL
        CALL   HLFTCH
        CP     '('
        RET    NZ
        PUSH   DE
        LD     B,1
SK29LP: PUSH   BC
        CALL   IFSKSB
        POP    BC
        CALL   ENDCK0
        JP     Z,ER01
        CP     '('
        JR     NZ,$+3
        INC    B
        CP     ')'
        JR     NZ,SK29LP
        DJNZ   SK29LP
        INC    HL
        CALL   HLFTCH
        POP    DE
        RET
;
STRCK:  CP     3
        JR     NZ,STROMT
STROK:
        LD     A,(PRCSON)
        CP     3
        RET    Z
        JP     ER04            ;TYPE MISMATCH
STROMT:
        LD     A,(PRCSON)
        CP     3
        RET    NZ
        JP     ER04
;
FNVRBF:
        DEFW   0
FNTXBF: DEFS   2

;
;  THIS _IS_ REDUNDANT !!
;
_HLDECK: LD     A,(DE)
        CP     (HL)
        RET    NZ
        PUSH   BC
        PUSH   DE
        PUSH   HL
        LD     B,C
_HLDEC1: LD     A,(DE)
        CP     (HL)
        JR     NZ,_HLDEC2
        INC    DE
        INC    HL
        DJNZ   _HLDEC1
        XOR    A
_HLDEC2: POP    HL
        POP    DE
        POP    BC
        RET
;
; Joy stick command
;
STCK:
        CALL   HCH28H
        PUSH   DE
        CALL   DEEXP
        CALL   DCHECK
        CP     3
        JP     NC,ER03__
        POP    DE
        PUSH   AF
        CALL   HCH29H
        POP    AF
        RST    3
        DEFB   _STICK
        EX     DE,HL
        PUSH   DE
        CALL   PUT1B
        JP     EOF8
;
STIG:
        CALL   HCH28H
        PUSH   DE
        CALL   DEEXP
        CALL   DCHECK
        CP     5
        JP     NC,ER03__
        POP    DE
        PUSH   AF
        CALL   HCH29H
        POP    AF
        RST    3
        DEFB   _STRIG
        EX     DE,HL
        PUSH   DE
        CALL   PUT1B
        JP     EOF8
;
;       END    (909EH)


;        ORG    909EH

; ----------------------------
; MZ-800 BASIC  Floating point
; FI:FLOAT  ver 1.0A 7.18.84
; Programed by T.Miho
; ----------------------------
;
;
;
CLRFAC:
        PUSH   HL
        LD     B,5
        CALL   CLRHL
        POP    HL
        RET
;
NEG:
        CALL   STROMT
TOGLE:
        LD     A,(HL)
        OR     A
        RET    Z
        INC    HL
        LD     A,(HL)
        XOR    80H
        LD     (HL),A
        DEC    HL
        RET
;
;
;(HL)=(HL)-(DE)
;
SUB:
        CALL   STROMT
        LD     C,A
        LD     A,80H
        JP     ADDSUB
;
;(HL)=(HL)+(DE)
;
ADD:
        LD     A,(PRCSON)
        CP     03H
        JP     Z,STRADD
        LD     C,A
        XOR    A
ADDSUB: LD     (HLBUF),HL
        PUSH   DE
        PUSH   HL
        LD     (SPBUF),SP
        INC    HL
        INC    DE
        LD     B,(HL)             ;
        XOR    (HL)
        EX     DE,HL
        XOR    (HL)
        DEC    HL
        DEC    DE
        EX     DE,HL
        RLCA
        LD     A,B
        LD     (SIGN),A
        JP     C,FSUB          ;HL-DE
;
FADD:   XOR    A               ;HL+DE
        CP     (HL)
        JP     Z,_TRANS         ;(HL)_(DE)
        LD     A,(DE)
        OR     A
        JR     Z,FLEXIT        ;SIGN SET RET
        SUB    M               ;DE-HL
        JP     SFADD
;
;
FLEXIT: LD     SP,(SPBUF)
        POP    HL
        POP    DE
        EI
        LD     A,(HL)
        OR     A
        JP     Z,ABS
        LD     A,(SIGN)
        AND    80H
        INC    HL
        RES    7,(HL)
        OR     (HL)
        LD     (HL),A
        DEC    HL
        RET
;
_TRANS:  LD     B,0
        LD     A,5
        LD     C,A
        EX     DE,HL
        LDIR
        JP     FLEXIT
;
STRADD: LD     B,(HL)
        LD     A,(DE)
        ADD    A,B
        JP     C,ER05          ;STRING TOO LONG
        LD     C,A
        PUSH   DE
        PUSH   HL
        PUSH   DE
        INC    HL
        LD     E,(HL)
        INC    HL
        LD     D,(HL)
        LD     HL,(STRST)
        ADD    HL,DE
        EX     DE,HL
        LD     HL,(TMPEND)
        CALL   STRENT
        EX     (SP),HL
        LD     B,(HL)
        INC    HL
        LD     E,(HL)
        INC    HL
        LD     D,(HL)
        LD     HL,(STRST)
        ADD    HL,DE
        EX     DE,HL
        POP    HL
        CALL   STRENT
        LD     A,C
        LD     DE,(TMPEND)
        LD     BC,(STRST)
        EX     DE,HL
        OR     A
        SBC    HL,BC
        EX     DE,HL
        LD     (TMPEND),HL
        POP    HL
        LD     (HL),A
        INC    HL
        LD     (HL),E
        INC    HL
        LD     (HL),D
        DEC    HL
        DEC    HL
        POP    DE
        RET
;
;
CMP:
        LD     A,(PRCSON)
        CP     3
        JR     NZ,FLTCP2
        PUSH   DE
        PUSH   HL
        LD     A,(DE)
        OR     (HL)
        JR     Z,STCMPE
        LD     A,(DE)
        CP     (HL)
        JR     C,$+3
        LD     A,(HL)
        OR     A
        JR     Z,STCMPF
        INC    HL
        LD     C,(HL)
        INC    HL
        LD     B,(HL)
        EX     DE,HL
        INC    HL
        LD     E,(HL)
        INC    HL
        LD     D,(HL)
        LD     HL,(STRST)
        EX     DE,HL
        ADD    HL,DE
        EX     DE,HL
        ADD    HL,BC
        EX     DE,HL
        LD     B,A
        OR     A
        JR     Z,STCMPE
STCMPL: LD     A,(DE)
        CP     (HL)
        JR     NZ,STCMPE
        INC    DE
        INC    HL
        DJNZ   STCMPL
STCMPF: POP    DE
        POP    HL
        LD     A,(DE)
        CP     (HL)
        EX     DE,HL
        RET
;
STCMPE: POP    HL
        POP    DE
        RET
;
;
;
FLTCP2: INC    DE
        INC    HL
        LD     A,(DE)
        DEC    DE
        XOR    (HL)
        RLCA
        JR     NC,FLTCP3
        LD     A,(HL)
        DEC    HL
        RLCA
        RET
FLTCP3: LD     A,(HL)
        DEC    HL
        RLCA
        JR     NC,FLTCMP
        CALL   FLTCMP
        RET    Z
        CCF
        RET
;
FLTCMP: PUSH   DE
        PUSH   HL
        EX     DE,HL
        LD     A,(DE)
        CP     (HL)
        JR     NZ,SUBNZ
        INC    DE
        INC    HL
        LD     A,(HL)
        OR     80H
        LD     B,A
        LD     A,(DE)
        OR     80H
        CP     B
        JR     NZ,SUBNZ
        LD     A,(PRCSON)
        LD     B,A
        DEC    B
        DEC    B
CMPL:   INC    DE
        INC    HL
        LD     A,(DE)
        CP     (HL)
        JR     NZ,SUBNZ
        DJNZ   CMPL
SUBNZ:  POP    HL
        POP    DE
        RET
;
ZERO:   POP    HL
        PUSH   HL
        CALL   CLRFAC
        JP     FLEXIT
;
FSUB:   CALL   FLTCMP
        JR     Z,ZERO
        JR     NC,SUBOK
        LD     A,(SIGN)
        XOR    80H
        LD     (SIGN),A
        SCF
SUBOK:  EX     AF,AF
        LD     A,(HL)
        OR     A
        JP     Z,_TRANS
        LD     A,(DE)
        OR     A
        JP     Z,FLEXIT
        SUB    M
        JR     C,FSUB11
        CP     32
        JP     NC,_TRANS
        JR     SUBOK2
FSUB11: NEG
        CP     32
        JP     NC,FLEXIT
SUBOK2: EX     AF,AF
        JR     C,SUBOK_
        EX     DE,HL
SUBOK_: EX     AF,AF
        JP     SSUB
;
OVERF:  LD     SP,(SPBUF)
        EI
        POP    HL
        POP    DE
        LD     A,(OFLAG)
        OR     A
        JP     Z,ER02
;SET MAX NUM HERE *****
        RET
;
;
;
;
SFADD:  JR     NC,SNSH
        NEG
        CP     32
        JP     NC,FLEXIT
        EX     DE,HL
        JR     SADD1
SNSH:   CP     32
        JP     NC,_TRANS
SADD1:  CALL   SSHIFT
        LD     A,H
        EXX
        ADC    A,H             ; ADJUST WITH CARRY
        EXX
        LD     H,A             ;
        LD     A,L
        EXX
        ADC    A,L
        EXX
        LD     L,A
        LD     A,D
        EXX
        ADC    A,D
        EXX
        LD     D,A
        LD     A,E
        EXX
        ADC    A,E
        EXX
        JR     NC,SSTORE
        RRA
        RR     D
        RR     L
        RR     H
        INC    C
        JP     Z,OVERF
SSTORE: LD     E,A
        LD     A,C
        EXX
        LD     BC,5
        LD     HL,(HLBUF)
        LD     (HL),A
        ADD    HL,BC
        DI
        LD     SP,HL
        EXX
        PUSH   HL
        PUSH   DE
        JP     FLEXIT
;
SSHIFT: DI
        LD     (SPBF),SP
        EX     AF,AF
        INC    HL
        LD     SP,HL
        EXX
        POP    DE              ;E,D,L,H
        SET    7,E             ;CY=0
        POP    HL
        OR     A
SHFLP2: EX     AF,AF
        CP     8
        JR     C,BITET2
        SUB    8
        EX     AF,AF
        RL     H
        LD     H,L
        LD     L,D
        LD     D,E
        LD     E,0
        JR     SHFLP2
BITET2: OR     A
        JR     Z,BITSE2
BITST2: EX     AF,AF
        OR     A
        RR     E
        RR     D
        RR     L
        RR     H
        EX     AF,AF
        DEC    A
        JR     NZ,BITST2
BITSE2: EXX
        EX     DE,HL
        LD     C,(HL)
        INC    HL
        LD     SP,HL
        POP    DE
        SET    7,E
        POP    HL
        EX     AF,AF
        LD     SP,(SPBF)
        EI
        RET
;
SSUB:   CP     32
        JP     NC,FLEXIT
        CALL   SSHIFT
        LD     A,H
        EXX
        SBC    A,H
        EXX
        LD     H,A
        LD     A,L
        EXX
        SBC    A,L
        EXX
        LD     L,A
        LD     A,D
        EXX
        SBC    A,D
        EXX
        LD     D,A
        LD     A,E
        EXX
        SBC    A,E
        EXX
SSFL2:  OR     A
        JR     Z,BSIFT
SSFL3:  BIT    7,A
        JR     NZ,SSTOR2
        RL     H
        RL     L
        RL     D
        RLA
        DEC    C
        JP     NZ,SSFL3
        JP     ZERO
SSTOR2: LD     E,A
        JP     SSTORE
BSIFT:  LD     A,C
        SUB    8
        LD     C,A
        LD     A,D
        LD     D,L
        LD     L,H
        LD     H,0
        JR     Z,$+4
        JR     NC,SSFL2
        JP     ZERO
;
;---------------------
;
EXPCHK: LD     C,A
        INC    HL
        INC    DE
        LD     A,(DE)
        XOR    (HL)
        LD     (SIGN),A
        DEC    HL
        DEC    DE
        RET
;
MUL:
        CALL   STROMT
        CALL   EXPCHK
        PUSH   DE
        PUSH   HL
        LD     (SPBUF),SP
        LD     A,(HL)
        OR     A
        JP     Z,ZERO
        LD     A,(DE)
        OR     A
        JP     Z,ZERO
        INC    DE
        PUSH   DE
        POP    IX
        ADD    A,(HL)
        LD     E,A
        LD     A,0
        ADC    A,A
        LD     D,A
        LD     (EXPSGN),DE
        INC    HL
        XOR    A
        LD     (CYFLG),A
        LD     D,(HL)
        SET    7,D
        INC    HL
        LD     E,(HL)
        INC    HL
        PUSH   HL
        LD     H,A
        LD     L,A
        EXX
        POP    HL
        LD     D,(HL)
        INC    HL
        LD     E,(HL)
        LD     B,A
        LD     C,A
        LD     H,A
        LD     L,A
        EXX
        LD     A,(IX+0)
        OR     80H
        LD     C,4             ;BYTES COUNTER
SMULL1: LD     B,8             ;BIT COUNTER
        OR     A
        JP     Z,SMULL5
SMULL2: RLCA
        JR     NC,SMULL4
        EX     AF,AF
        EXX
        LD     A,C
        ADD    A,B
        LD     C,A
        ADC    HL,DE
        EXX
        ADC    HL,DE
        JR     NC,SMULL3
        LD     A,1
        LD     (CYFLG),A
SMULL3: EX     AF,AF
SMULL4: SRL    D
        RR     E
        EXX
        RR     D
        RR     E
        RR     B
        EXX
        DJNZ   SMULL2
SMULL6: INC    IX
        LD     A,(IX+0)
        DEC    C
        JR     NZ,SMULL1
        EXX
        LD     A,(CYFLG)
        OR     A
        JR     Z,SMULL7
        LD     DE,(EXPSGN)
        INC    DE
        LD     (EXPSGN),DE
        EXX
        SCF
        RR     H
        RR     L
        EXX
        RR     H
        RR     L
        RR     C
SMULL7: BIT    7,C
        JR     Z,SMULL8
        LD     DE,1
        ADD    HL,DE
        EXX
        LD     DE,0
        ADC    HL,DE
        EXX
        JR     NC,SMULL8
        LD     DE,(EXPSGN)
        INC    DE
        LD     (EXPSGN),DE
        EXX
        LD     H,80H
        EXX
SMULL8: POP    IX
        PUSH   IX
        LD     (IX+4),L
        LD     (IX+3),H
        EXX
        LD     (IX+2),L
        LD     (IX+1),H
        LD     HL,(EXPSGN)
        OR     A
        LD     DE,81H
        SBC    HL,DE
        LD     A,H
        ADD    A,0
        JP     M,UNDRFL
        JP     NZ,OVERF
        LD     (IX+0),L
        JP     FLEXIT
;
SMULL5: LD     A,E
        EXX
        LD     B,E
        LD     E,D
        LD     D,A
        EXX
        LD     E,D
        LD     D,0
        JP     SMULL6
;
;
UNDRFL: LD     SP,(SPBUF)      ;****
        JP     ZERO
;
DIV:
        CALL   STROMT
        CALL   EXPCHK
        PUSH   DE
        PUSH   HL
        LD     (SPBUF),SP
        LD     A,(DE)
        OR     A
        JP     Z,ER02          ;DIVID BY ZERO
        EX     AF,AF
        LD     A,(HL)
        OR     A
        JP     Z,ZERO
        EXX
        ADD    A,81H
        LD     B,A
        LD     A,0
        ADC    A,A
        EX     AF,AF
        LD     C,A
        LD     A,B
        SUB    C
        LD     C,A
        EX     AF,AF
        LD     B,A
        EX     AF,AF
        LD     A,B
        SBC    A,0
        JP     C,UNDRFL
        JP     NZ,OVERF
        LD     A,C
        PUSH   AF              ;PUSH A(EXP)
        EXX
        INC    DE
        INC    HL
        LD     B,(HL)
        SET    7,B
        INC    HL
        LD     C,(HL)
        INC    HL
        PUSH   HL
        EX     DE,HL
        LD     D,(HL)
        SET    7,D
        INC    HL
        LD     E,(HL)
        INC    HL
        PUSH   HL
        LD     H,B
        LD     L,C
        EXX
        POP    HL
        LD     D,(HL)
        INC    HL
        LD     E,(HL)
        POP    HL
        LD     A,(HL)
        INC    HL
        LD     L,(HL)
        LD     H,A
        EXX                    ;HLH'L'/DED'E'
        LD     C,5             ;C=5
SDIVL1: LD     B,8             ;B=8
        XOR    A
SDIVL2: BIT    7,H
        JR     NZ,SDIVL3
        OR     A
SDIVL4: RLA
        EXX
        ADD    HL,HL
        EXX
        ADC    HL,HL
        DJNZ   SDIVL2
        PUSH   AF
        DEC    C
        JR     NZ,SDIVL1
        JP     SDIVED
;
SDIVL3: OR     A
        EXX
        SBC    HL,DE
        EXX
        SBC    HL,DE
        CCF
        JR     C,SDIVL4
        EXX
        ADD    HL,DE
        EXX
        ADC    HL,DE
        OR     A
        RLA
        EXX
        ADD    HL,HL
        EXX
        ADC    HL,HL
        DJNZ   SDIVL5
        PUSH   AF
        LD     B,8
        DEC    C
        JP     Z,SDIVED
SDIVL5: EXX
        OR     A
        SBC    HL,DE
        EXX
        SBC    HL,DE
        SCF
        RLA
        DJNZ   SDIVL6
        PUSH   AF
        LD     B,8
        DEC    C
        JR     Z,SDIVED
SDIVL6: EXX
        ADD    HL,HL
        EXX
        ADC    HL,HL
        JR     C,SDIVL5
        JP     SDIVL2
;
SDIVED: POP    AF
        LD     H,A             ;H'
        EXX
        POP    AF
        LD     E,A             ;E
        POP    AF
        LD     D,A             ;D
        POP    AF
        LD     C,A             ;C
        POP    AF
        LD     B,A             ;B
        POP    AF              ;A(EXP)
SDIVL9: BIT    7,B
        JR     NZ,SDIVE2
        EXX
        SLA    H
        EXX
        RL     E
        RL     D
        RL     C
        RL     B
        DEC    A
        JP     NZ,SDIVL9
        JP     ZERO
SDIVE2: EXX
        RL     H
        EXX
        JR     NC,SDIVL8
        LD     HL,1
        ADD    HL,DE
        EX     DE,HL
        LD     HL,0
        ADC    HL,BC
        LD     B,H
        LD     C,L
        JR     NC,SDIVL8
        LD     B,80H
        INC    A
SDIVL8: POP    HL
        PUSH   HL
        LD     (HL),A
        INC    HL
        LD     (HL),B
        INC    HL
        LD     (HL),C
        INC    HL
        LD     (HL),D
        INC    HL
        LD     (HL),E
        JP     FLEXIT
;
HLBUF:  DEFS   2
SIGN:   DEFS   1
SPBUF:  DEFS   2
SPBF:   DEFS   2
CYFLG:  DEFS   1
EXPSGN: DEFS   2
OFLAG:  DEFS   1
;

;
TSTSGN: INC    HL
        BIT    7,(HL)
        DEC    HL
        RET
;
MULTWO: INC    (HL)
        RET    NZ
        JP     ER02
;
DIVTWO: LD     A,(HL)
        OR     A
        RET    Z
        DEC    (HL)
        RET    NZ
        JP     CLRFAC
;
ADDHL5: PUSH   HL
        INC    HL
        INC    HL
        INC    HL
        INC    HL
        INC    HL
        EX     DE,HL
        LD     HL,(MEMMAX)
        DEC    HL
        SBC    HL,DE
        JP     C,ER06__
        POP    HL
        RET
;
FACSET: PUSH   HL
        LD     (SNFAC0),HL
        CALL   ADDHL5
        EX     DE,HL
        LD     (SNFAC1),HL
        CALL   ADDHL5
        EX     DE,HL
        LD     (SNFAC2),HL
        CALL   ADDHL5
        LD     (SNFAC3),DE
        POP    HL
        RET
;
;
POWERS:                    ;(HL)^(DE)
        CALL   STROMT
        EX     DE,HL
        LD     A,(HL)
        OR     A
        JP     Z,POWR1
        EX     DE,HL
        LD     A,(HL)
        OR     A
        JP     Z,CLRFAC
        CALL   TSTSGN
        JR     Z,POWER1
        CALL   TOGLE
        EX     DE,HL
        PUSH   DE
        PUSH   HL
        LD     DE,ZFAC1
        CALL   LDIR5           ;(ZFAC1)=(DE)
        LD     HL,ZFAC1
        CALL   FRACT
        LD     A,(HL)
        OR     A
        JP     NZ,ER03__
        POP    HL
        PUSH   HL
        CALL   HLFLT
        BIT    0,L
        POP    DE
        POP    HL
        JR     Z,POWER1
        CALL   POWER1
        JP     TOGLE
;
POWER1: EX     DE,HL
        LD     A,(HL)
        OR     A
        JR     Z,POWR1
        CALL   TSTSGN
        JR     Z,POWER2
        CALL   TOGLE
        CALL   POWER2
        PUSH   DE
        PUSH   HL
        LD     DE,ZFAC1
        CALL   LDIR1           ;(ZFAC1)=1
        LD     HL,ZFAC1
        POP    DE
        CALL   DIV             ;(ZFAC1)/(HL)
        PUSH   DE
        CALL   LDIR5           ;(HL)=(ZFAC1)
        POP    HL
        POP    DE
        RET
;
POWR1:  PUSH   DE
        CALL   LDIR1
        POP    HL
        RET
;
POWER2: PUSH   DE
        LD     DE,ZFAC1
        CALL   LDIR5           ;(ZFAC1)=(DE)
        POP    HL
        CALL   LOG             ;LOG(HL)
        LD     DE,ZFAC1
        CALL   MUL             ;(HL)*(DE)
        JP     EXP             ;EXP(HL)

;
_NOT_:
        CALL   STROMT
        PUSH   DE
        PUSH   HL
        CALL   HLFLT
        LD     A,L
        CPL
        LD     E,A
        LD     A,H
        CPL
        LD     D,A
        JR     AND9
;
_AND_:
        LD     A,0A2H           ;AND D
        DEFB   1
_OR_:
        LD     A,0B2H           ;OR D
        DEFB   1
_XOR_:
        LD     A,0AAH           ;XOR D
;
        LD     (AND2),A
        INC    A
        LD     (AND4),A
        CALL   STROMT
        PUSH   DE
        PUSH   HL
        CALL   HLFLT
        EX     DE,HL
        CALL   HLFLT
        LD     A,H
AND2:   AND    D               ;AND, OR, XOR
        LD     D,A
        LD     A,L
AND4:   AND    E               ;AND, OR, XOR
        LD     E,A
AND9:   POP    HL
        CALL   FLTHEX
        POP    DE
        RET

;
ABS:
        INC    HL
        RES    7,(HL)
        DEC    HL
        RET
;
INTOPR:
        CALL   TSTSGN
        JP     Z,INT
        CALL   MVFAC1
        CALL   INT
        LD     DE,ZFAC1
        CALL   CMP
        RET    Z
ONESUB: LD     DE,FLONE
        JP     SUB
;
ONEADD: LD     DE,FLONE
        JP     ADD
;
ONECMP: LD     DE,FLONE
        JP     CMP
;
MVFAC1: PUSH   HL
        PUSH   DE
        LD     DE,ZFAC1
        CALL   LDIR5
        POP    DE
        POP    HL
        RET
;
;
MOD:
        CALL   INT
        EX     DE,HL
        CALL   INT
        EX     DE,HL
        CALL   MVFAC1
        CALL   DIV
        CALL   INT
        CALL   MUL
        PUSH   DE
        LD     DE,ZFAC1
        CALL   SUB
        POP    DE
        JP     TOGLE
;
;
YEN:
        CALL   INT
        EX     DE,HL
        CALL   INT
        EX     DE,HL
        CALL   DIV
        JP     INT
;
;
SQR:
        LD     A,(HL)
        OR     A
        RET    Z
        CALL   TSTSGN
        JP     NZ,ER03__
        CALL   LOG
        CALL   DIVTWO
        JP     EXP
;
RETONE: PUSH   HL
        EX     DE,HL
        CALL   LDIR1
        POP    HL
        POP    BC
        RET
;
ATNLM1: DEFB   7EH
        DEFB   4CH
;
ATNLM2: DEFB   80H
        DEFB   2BH
;
ATN:
        PUSH   BC
        INC    HL
        LD     A,(HL)
        RES    7,(HL)
        DEC    HL
        PUSH   AF
        CALL   ATN_1
        POP    AF
        POP    BC
        RLCA
        RET    NC
        JP     TOGLE
;
ATN_1:  CALL   ONECMP
        JR     C,ATN_2
        CALL   ADDHL5
        PUSH   DE
        PUSH   HL
        CALL   LDIR5
        POP    DE
        PUSH   DE
        CALL   LDIR1
        POP    HL
        POP    DE
        CALL   DIV
        CALL   ATN_2
        LD     DE,FLTHPI       ;PI/2
        CALL   SUB
        JP     ABS
;
ATN_2:  LD     A,0FFH
        LD     (SINSGN),A
        LD     DE,ATNLM1
        CALL   CMP
        JR     C,ATNCUL
        LD     DE,ATNLM2
        CALL   CMP
        PUSH   AF
        CALL   ADDHL5
        POP    AF
        PUSH   HL
        PUSH   DE
        CALL   LDIR5
        POP    HL
        JR     C,ATNMID
        CALL   ONEADD
        EX     (SP),HL
        CALL   SUB
        POP    DE
        CALL   DIV
        CALL   ATNCUL
        LD     DE,FLTQPI       ;PI/4
        JP     ADD
;
ATNMID: LD     DE,SQRTMO
        CALL   MUL
        CALL   ONEADD
        EX     (SP),HL
        LD     DE,SQRTMO
        CALL   SUB
        POP    DE
        CALL   DIV
        CALL   ATNCUL
        CALL   MULTWO
        LD     DE,FLTQPI       ;PI/4
        CALL   ADD
        JP     DIVTWO
;
SQRTMO: DEFB   0x7F,0x54,0x13,0xCC,0xD0

;
ATNCUL: PUSH   BC
        PUSH   HL
        CALL   FACSET
        POP    HL
        PUSH   HL
        PUSH   DE
        CALL   LDIR5
        POP    HL
        LD     E,L
        LD     D,H
        CALL   MUL
        LD     DE,(SNFAC2)
        POP    HL
        PUSH   HL
        CALL   LDIR5
        LD     A,(PRCSON)
        DEC    A
        CP     04H
        LD     B,A
        LD     HL,TANTBL
        JP     Z,SIN6
        LD     B,10
        JP     SIN6
;
COS:
        PUSH   BC
        LD     A,(HL)
        OR     A
        JP     Z,RETONE
        LD     DE,FLTHPI       ;PI/2
        CALL   SUB
        CALL   TOGLE
        POP    BC
;
SIN:
        PUSH   BC
        INC    HL
        LD     A,(HL)
        RES    7,(HL)
        AND    80H
        CPL
        LD     (SINSGN),A
        DEC    HL
        LD     DE,FLT2PI       ;PI*2
        PUSH   HL
        CALL   CMP
        JR     C,SIN1
        CALL   DIV
        CALL   FRACT
        CALL   MUL
SIN1:   LD     DE,FLTPAI
        CALL   CMP
        JR     C,SIN2
        CALL   SUB
        LD     A,(SINSGN)
        XOR    80H
        LD     (SINSGN),A
SIN2:   LD     DE,FLTHPI       ;PI/2
        CALL   CMP
        JR     C,SIN4
        LD     DE,FLTPAI
        CALL   SUB
        CALL   ABS
SIN4:   CALL   FACSET
        POP    HL
        PUSH   DE
        LD     DE,FLTQPI       ;PI/4
        CALL   CMP
        JR     NC,COSCUL
        POP    DE
        PUSH   HL
        PUSH   DE
        CALL   LDIR5
        POP    HL
        LD     E,L
        LD     D,H
        CALL   MUL
        LD     DE,(SNFAC2)
        POP    HL
        PUSH   HL
        CALL   LDIR5
        LD     A,(PRCSON)
        LD     B,A
        LD     HL,SINTBL
SIN6:   PUSH   BC
        PUSH   HL
        LD     HL,(SNFAC2)
        LD     DE,(SNFAC3)
        CALL   MUL
        POP    HL
        PUSH   HL
        LD     DE,(SNFAC1)
        PUSH   DE
        CALL   LDIR5
        POP    HL
        LD     DE,(SNFAC2)
        CALL   MUL
        EX     DE,HL
        LD     HL,(SNFAC0)
        CALL   ADD
        POP    HL
        LD     DE,5
        ADD    HL,DE
        POP    BC
        DJNZ   SIN6
        POP    HL
        POP    BC
        LD     A,(SINSGN)
        INC    HL
        XOR    (HL)
        CPL
        LD     (HL),A
        DEC    HL
        LD     A,(PRCSON)
        CP     08H
        LD     A,(HL)
        JR     Z,SIN9
        CP     5CH             ; ADJUST
SIN8:   RET    NC
        JP     CLRFAC
;
SIN9:   CP     4DH             ; ADJUST
        JR     SIN8
;
COSCUL: LD     DE,FLTHPI       ;PI/2
        CALL   SUB
        CALL   ABS
        POP    DE
        PUSH   HL
        PUSH   DE
        CALL   LDIR5
        POP    HL
        LD     E,L
        LD     D,H
        CALL   MUL
        LD     DE,(SNFAC2)
        CALL   LDIR1
        POP    DE
        PUSH   DE
        CALL   LDIR1
        LD     A,(PRCSON)
        LD     B,A
        LD     HL,COSTBL
        JR     SIN6
;
SINSGN: DEFS   1
;
;
TAN:
        PUSH   BC
        PUSH   HL
        CALL   ADDHL5
        EX     DE,HL
        LD     (SNFAC4),HL
        CALL   ADDHL5
        LD     (SNFAC5),DE
        POP    HL
        PUSH   HL
        CALL   LDIR5
        LD     HL,(SNFAC4)
        EX     DE,HL
        POP    HL
        PUSH   HL
        CALL   LDIR5
        LD     HL,(SNFAC5)
        CALL   SIN
        POP    DE
        PUSH   DE
        CALL   LDIR5
        LD     HL,(SNFAC4)
        CALL   COS
        EX     DE,HL
        POP    HL
        CALL   DIV
        POP    BC
        RET
;
SINTBL: DEFB   0x7E,0xAA,0xAA,0xAA,0xAB
        DEFB   0x7A,0x08,0x88,0x88,0x89
        DEFB   0x74,0xD0,0x0D,0x00,0xD0
        DEFB   0x6E,0x38,0xEF,0x1D,0x2B
        DEFB   0x67,0xD7,0x32,0x2B,0x40
        DEFB   0x60,0x30,0x92,0x30,0x9D
        DEFB   0x58,0xD7,0x3F,0x9F,0x3A
        DEFB   0x50,0x4A,0x96,0x3B,0x82
;
COSTBL: DEFB   0x80,0x80,0x00,0x00,0x00
        DEFB   0x7C,0x2A,0xAA,0xAA,0xAB
        DEFB   0x77,0xB6,0x0B,0x60,0xB6
        DEFB   0x71,0x50,0x0D,0x00,0xD0
        DEFB   0x6B,0x93,0xF2,0x7D,0xBC
        DEFB   0x64,0x0F,0x76,0xC7,0x80
        DEFB   0x5C,0xC9,0xCB,0xA5,0x46
        DEFB   0x54,0x57,0x3F,0x9F,0x3A
;
TANTBL: DEFB   0x7F,0xAA,0xAA,0xAA,0xAB
        DEFB   0x7E,0x4C,0xCC,0xCC,0xCD
        DEFB   0x7E,0x92,0x49,0x24,0x92
        DEFB   0x7D,0x63,0x8E,0x38,0xE4
        DEFB   0x7D,0xBA,0x2E,0x8B,0xA3
        DEFB   0x7D,0x1D,0x89,0xD8,0x9E
        DEFB   0x7D,0x88,0x88,0x88,0x89
        DEFB   0x7C,0x70,0xF0,0xF0,0xF1
        DEFB   0x7C,0xD7,0x94,0x35,0xE5
        DEFB   0x7C,0x43,0x0C,0x30,0xC3
;
;
SGN:
        LD     DE,0
        LD     A,(HL)
        OR     A
        JR     Z,SGNSET
        CALL   TSTSGN
        INC    DE
        JR     Z,SGNSET
        DEC    DE
        DEC    DE
SGNSET: CALL   FLTHEX
        RET
;
;
RAD:
        LD     DE,FLTRAD
        JR     $+5
PAI:
        LD     DE,FLTPAI
        PUSH   BC
        CALL   MUL
        POP    BC
        RET

;
FLT2PI: DEFB   0x83,0x49,0x0F,0xDA,0xA2  ;PI*2

FLTPAI: DEFB   0x82,0x49,0x0F,0xDA,0xA2  ;PI

FLTHPI: DEFB   0x81,0x49,0x0F,0xDA,0xA2  ;PI/2

FLTQPI: DEFB   0x80,0x49,0x0F,0xDA,0xA2  ;PI/4

FLTRAD: DEFB   0x7B,0x0E,0xFA,0x35,0x13

;
;
PEEK:
        PUSH   HL
        CALL   HLFLT
        LD     E,(HL)
        LD     D,0
        POP    HL
        CALL   FLTHEX
        RET
;
;
RND:
        LD     A,(HL)
        OR     A
        JR     Z,RNDMIZ
        CALL   TSTSGN
        JR     Z,NORRND
RNDMIZ: PUSH   HL
        LD     HL,4193H
        LD     (SEED),HL
        POP    HL
        XOR    A
        LD     R,A
NORRND: PUSH   BC
        LD     DE,(SEED)
        LD     A,R
        XOR    D
        RRC    A
        RRC    A
        RRC    A
        LD     D,A
        LD     A,R
        XOR    E
        RLC    A
        RLC    A
        LD     E,D
        LD     D,A
        LD     (SEED),DE
        PUSH   HL
        INC    HL
        RES    7,D
        LD     (HL),D
        INC    HL
        LD     (HL),E
        INC    HL
        LD     A,R
        LD     (HL),A
        POP    HL
        LD     (HL),81H
        CALL   ONESUB
        POP    BC
        RET
SEED:   DEFW   4193H
;
EXP:
        PUSH   BC
        LD     A,(HL)
        OR     A
        JP     Z,RETONE
        INC    HL
        LD     A,(HL)
        LD     (EXPSIN),A
        RES    7,(HL)
        DEC    HL
        LD     DE,LNTWO2
        CALL   MUL
        PUSH   HL
        CALL   ADDHL5
        PUSH   DE
        CALL   LDIR5
        POP    HL
        CALL   INT
        PUSH   HL
        CALL   HLFLT
        XOR    A
        CP     H
        JP     NZ,ER02
        LD     A,L
        LD     (EXPOFF),A
        POP    DE
        POP    HL
        PUSH   HL
        CALL   SUB
        PUSH   DE
        PUSH   HL
        CALL   LDIR1
        POP    DE
        POP    HL
        CALL   DIVTWO
        EX     DE,HL
        XOR    A
        LD     B,8
EXPLP1: PUSH   BC
        PUSH   AF
        CALL   CMP
        JR     C,EXPNL1
        CALL   SUB
        POP    AF
        SET    7,A
        PUSH   AF
EXPNL1: POP    AF
        RLC    A
        EX     DE,HL
        PUSH   AF
        CALL   DIVTWO
        POP    AF
        EX     DE,HL
        POP    BC
        DJNZ   EXPLP1
        LD     (EXPHBT),A
        PUSH   DE
        LD     DE,LNTWO
        LD     A,(PRCSON)
        BIT    3,A
        JR     NZ,$+5
        LD     DE,LNTWOF
        CALL   MUL
        POP    DE
        PUSH   DE
        CALL   LDIR5
        POP    HL
        LD     A,(PRCSON)
        BIT    3,A
        JP     Z,EXPSKP
        CALL   MULTWO
        LD     DE,FLTEN
        CALL   ADD
        CALL   DIVTWO
        POP    DE
        PUSH   DE
        CALL   MUL
        LD     DE,FLTEN
        CALL   DIVTWO
        CALL   ADD
        CALL   MULTWO
        POP    DE
        PUSH   DE
        CALL   MUL
        LD     DE,FLT120
        CALL   MUL
        CALL   MULTWO
        CALL   ONEADD
        CALL   DIVTWO
        POP    DE
        PUSH   DE
        CALL   MUL
        CALL   ONEADD
        POP    DE
        PUSH   DE
        CALL   MUL
EXPSK_: CALL   ONEADD
        EX     (SP),HL
        EX     DE,HL
        PUSH   DE
        CALL   LDIR1
        POP    HL
        LD     DE,EXDTBL
        LD     A,(EXPHBT)
        LD     B,8
EXPCLP: RLC    A
        JR     NC,SKPEXP
        PUSH   AF
        PUSH   BC
        CALL   MUL
        POP    BC
        POP    AF
SKPEXP:
        INC    DE
        INC    DE
        INC    DE
        INC    DE
        INC    DE
        DJNZ   EXPCLP
        LD     A,(EXPOFF)
        ADD    A,(HL)
        JP     C,ER02
        LD     (HL),A
        POP    DE
        CALL   MUL
        POP    BC
        LD     A,(EXPSIN)
        RLC    A
        RET    NC
        PUSH   BC
        PUSH   DE
        PUSH   HL
        CALL   LDIR5
        POP    DE
        PUSH   DE
        CALL   LDIR1
        POP    HL
        POP    DE
        CALL   DIV
        POP    BC
        RET
;
EXPSKP: POP    DE
        PUSH   DE
        CALL   MUL
        LD     A,(HL)
        OR     A
        CALL   NZ,DIVTWO
        CALL   ADD
        JP     EXPSK_
;
EXPOFF: DEFS   1
EXPSIN: DEFS   1
EXPHBT: DEFS   1
;
LOGD:
        PUSH   BC
        CALL   LOG
        LD     DE,LOGE10
        CALL   MUL
        POP    BC
        RET
;
LOG:                    ;LN(HL)
        PUSH   BC
        CALL   TSTSGN
        JP     NZ,ER03__
        LD     A,(HL)
        OR     A
        JP     Z,ER03__
        SUB    81H
        LD     (LOGEXP),A
        LD     (HL),81H
        XOR    A
        LD     B,8
        LD     DE,EXDTBL
LOGCLL: PUSH   BC
        PUSH   AF
        CALL   CMP
        JR     C,LOGNCL
        PUSH   HL
        LD     HL,40
        ADD    HL,DE
        EX     DE,HL
        EX     (SP),HL
        CALL   MUL
        POP    DE
        POP    AF
        SET    7,A
        PUSH   AF
LOGNCL: POP    AF
        RLC    A
        INC    DE
        INC    DE
        INC    DE
        INC    DE
        INC    DE
        POP    BC
        DJNZ   LOGCLL
        LD     (SNFAC0),HL
        CALL   ADDHL5
        EX     DE,HL
        LD     E,A
        LD     D,0
        CALL   FLTHEX
        LD     A,(HL)
        OR     A
        JR     Z,NOTDCR
        SUB    08H
        LD     (HL),A
NOTDCR: LD     A,(LOGEXP)
        CP     80H
        JR     C,$+4
        NEG
        PUSH   HL
        CALL   ADDHL5
        EX     DE,HL
        LD     (SNFAC1),HL
        LD     E,A
        LD     D,0
        CALL   FLTHEX
        LD     A,(LOGEXP)
        AND    80H
        INC    HL
        OR     (HL)
        LD     (HL),A
        DEC    HL
        EX     DE,HL
        POP    HL
        CALL   ADD
        LD     A,(PRCSON)
        LD     DE,LNTWO3
        CP     05H
        JR     Z,$+5
        LD     DE,LNTWO
        CALL   MUL
        PUSH   HL
        LD     DE,(SNFAC1)
        LD     HL,(SNFAC0)
        PUSH   HL
        PUSH   DE
        CALL   LDIR5
        POP    HL
        CALL   ONEADD
        EX     (SP),HL
        CALL   SUB
        POP    DE
        CALL   DIV
        PUSH   DE
        CALL   LDIR5
        POP    HL
        PUSH   DE
        LD     E,L
        LD     D,H
        CALL   MUL
        POP    DE
        PUSH   HL
        PUSH   DE
        CALL   LDIR5
        POP    HL
        LD     DE,LOGDAT
        CALL   ADD
        EX     DE,HL
        POP    HL
        CALL   MUL
        LD     DE,FLTEN
        CALL   MULTWO
        CALL   ADD
        CALL   DIVTWO
        EX     DE,HL
        LD     HL,(SNFAC0)
        CALL   MUL
        LD     DE,FLTHR_
        CALL   MUL
        POP    DE
        CALL   ADD
       POP    BC
        RET
;
LOGEXP: DEFS   1
;
;
LOGE10: DEFB   0x7F,0x5E,0x5B,0xD8,0xA9
;
;
FLTHR_: DEFB   0x7F,0x4C,0xCC,0xCC,0xCD
;
LOGDAT: DEFB   0x81,0x55,0x55,0x55,0x56
;
EXDTBL: DEFB   0x81,0x35,0x04,0xF3,0x34  ;2^(1/2)
        DEFB   0x81,0x18,0x37,0xF0,0x52  ;2^(1/4)
        DEFB   0x81,0x0B,0x95,0xC1,0xE4  ;2^(1/8)
        DEFB   0x81,0x05,0xAA,0xC3,0x68  ;2^(1/16)
        DEFB   0x81,0x02,0xCD,0x86,0x99  ;2^(1/32)
        DEFB   0x81,0x01,0x64,0xD1,0xF4  ;2^(1/64)
        DEFB   0x81,0x00,0xB1,0xED,0x50  ;2^(1/128)
        DEFB   0x81,0x00,0x58,0xD7,0xD3  ;2^(1/256)
        DEFB   0x80,0x35,0x04,0xF3,0x34
        DEFB   0x80,0x57,0x44,0xFC,0xCB
        DEFB   0x80,0x6A,0xC0,0xC6,0xE8
        DEFB   0x80,0x75,0x25,0x7D,0x16
        DEFB   0x80,0x7A,0x83,0xB2,0xDC
        DEFB   0x80,0x7D,0x3E,0x0C,0x0D
        DEFB   0x80,0x7E,0x9E,0x11,0x5D
        DEFB   0x80,0x7F,0x4E,0xCB,0x5A
;
FLT120: DEFB   0x7A,0x08,0x88,0x88,0x89
;
LNTWO:  DEFB   0x80,0x31,0x72,0x17,0xF8
;
LNTWOF: DEFB   0x80,0x31,0x72,0x17,0xF8
;
LNTWO2: DEFB   0x81,0x38,0xAA,0x3B,0x2A  ;1/LN(2)
;
LNTWO3: DEFB   0x80,0x31,0x72,0x17,0xF8  ; *
;
;
SNFAC0: DEFS   2
SNFAC1: DEFS   2
SNFAC2: DEFS   2
SNFAC3: DEFS   2
SNFAC4: DEFS   2
SNFAC5: DEFS   2
;
;       END  (9BACH)


;        ORG    9BACH

; ---------------------------
; MZ-800 BASIC  Music command
; FI:MUSIC  ver 1.0A 7.18.84
; Programed by T.Miho
; ---------------------------
;
;

;
;
;
; SOUND m,l /  SOUND=(r,d)
;
SOUND:
        CALL   TEST1
        DEFB   0F4H            ;=
        JR     NZ,SOUND1
        CALL   HCH28H          ;(
        CALL   IBYTE
        CP     16
        SET    7,A
        JR     SOUND2
;
SOUND1: CALL   IBYTE
        CP     NMAX+1
SOUND2: JP     NC,ER03__
        PUSH   AF
        CALL   HCH2CH          ;,
        CALL   IDEEXP
        POP    AF
        PUSH   AF
        OR     A
        CALL   M,HCH29H        ;)
        POP    AF
        PUSH   HL
        RST    3
        DEFB   _SOUND
        POP    HL
        RET
;
; TEMPO n  (n= 1 to 7 )
;
TEMPO:
        CALL   IBYTE
        DEC    A
        CP     7
        INC    A
        JP     _TEMPO


;
;;;;;;;;;;;;;;;;;;;;;
;
; NOISE  A1$;A2$,B1$;...
; MUSIC  A1$;A2$;...;A6$,B1$;...
;
NOISE:
        LD     A,08H           ;pattern (3)
        DEFB   1
;
MUSIC:
        LD     A,07H           ;pattern (0,1,2)
        LD     (MUNOF),A       ;channel pattern
        CALL   HLFTCH
        LD     B,3
        CP     0BEH             ;WAIT
        JR     Z,__MCTRL
        DEC    B
        CP     99H             ;STOP
        JR     Z,__MCTRL
        CP     0DCH             ;INIT
        JR     NZ,MUSIC1
;
        LD     DE,MUSCHO
        LD     B,4
        LD     A,2
        CALL   SETDE
__MCTRL:  PUSH   HL
        RST    3
        DEFB   _MCTRL
        POP    HL
        INC    HL
        RET
;
MUSIC1: CALL   ENDCHK
        RET    Z
        XOR    A
        LD     (MUDNO),A
        LD     (MUCHNO),A
        LD     B,A
        LD     A,0DH
        LD     DE,DIRARE
        LD     (MMBU1A),DE
        LD     (DE),A
        CALL   SETDE
        LD     A,(MUNOF)
        LD     (MUNOF2),A
MUSI1:  LD     DE,MUNOF2
        LD     A,(DE)
        RRC    A
        LD     (DE),A
        PUSH   AF
        LD     B,0
        JR     NC,MUSI3
        CALL   HLFTCH
        CP     ';'
        JR     Z,MUSI3
        CALL   STREXP
MUSI3:  PUSH   HL
        LD     A,(MUCHNO)
        CP     4
        JP     Z,ER01          ;Ch no over
        INC    A
        LD     (MUCHNO),A
        INC    B
        JP     Z,ER05
        LD     A,(MUDNO)
        ADD    A,B
        JP     C,ER05          ;data no. over
        LD     (MUDNO),A
        LD     HL,(MMBU1A)
        CALL   LDHLDE
        LD     (MMBU1A),HL
        DEC    HL
        LD     (HL),0DH
        POP    HL
        POP    AF
        JR     NC,MUSI1
        CALL   ENDCHK
        JR     Z,MUSI4
        CALL   TEST1
        DEFB   ','
        JR     Z,MUSI4
        CALL   TEST1
        DEFB   ';'
        JR     MUSI1
MUSI4:  PUSH   HL
        LD     HL,DIRARE
        LD     IX,HL
        LD     IY,MUSCHO
        LD     B,4
MUSI5:  PUSH   BC
        PUSH   HL
        LD     HL,IX
        LD     DE,DIRARE
        XOR    A
        SBC    HL,DE
        LD     (IY+4),L
        POP    HL
        LD     (MUSI6+1),SP
        CALL   MML_EN
MUSI6:  LD     SP,0            ;xxx
        POP    BC
        INC    HL
        INC    IY
        DJNZ   MUSI5
        LD     B,3
        RST    3
        DEFB   _MCTRL          ;MWAIT
MUSI8:  LD     BC,100H
        LD     HL,DIRARE
        LD     DE,DIRARE+700H
        LDIR
        LD     B,4
        LD     HL,MMCHDA
MUSDS:  LD     E,(HL)
        LD     D,0
        INC    HL
        PUSH   HL
        LD     HL,DIRARE+700H
        ADD    HL,DE
        LD     A,(HL)
        CP     0FFH
        JR     Z,MUSDS1
        LD     A,4
        SUB    B
        PUSH   BC
        EX     DE,HL
        RST    3
        DEFB   _PLAY
        POP    BC
MUSDS1: POP    HL
        DJNZ   MUSDS
        LD     B,1
        RST    3
        DEFB   _MCTRL          ;PSGON
;
        POP    HL
        JP     MUSIC1
;
MUSCHO: DEFW   0202H           ;Oct data eny ch.
        DEFW   0202H
MMCHDA: DEFS   4               ;Play & Noise Data addr
;
MUDNO:  DEFS   1               ;total data No.
MUCHNO: DEFS   1               ;ch no.
MMBU1A: DEFS   2               ;MML data buffer
MUNOF:  DEFS   1               ;07:MUSIC 08:NOISE
MUNOF2: DEFS   1               ;rotate(MUNOF)
;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; MML(HL) => IOCSM(IX) trans
; END code=00H or 0DH or C8H
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
MML_EN: CALL   MML_WC
MML_E0: CALL   HLFTCH
        CALL   MMAGCH
        JR     C,MMTCAL
        LD     C,0
        CALL   MML_AG          ;String:A-G
        JR     MMTCA9
;
MMTCAL: CALL   MMENCH
        JP     Z,MMLEND
        LD     B,12
        EX     DE,HL
        LD     HL,MMTCAT       ;Call address table
MMTCA0: CP     (HL)               ;cmp chr
        INC    HL
        JR     Z,MMTCAJ
        DEC    B
        JP     Z,ER03__
        INC    HL
        INC    HL
        JR     MMTCA0
MMTCAJ: LD     C,(HL)
        INC    HL
        LD     B,(HL)
        EX     DE,HL
        INC    HL
        CALL   _BC
MMTCA9: JP     C,ER03__
        JR     MML_E0
;
_BC:    PUSH   BC
        RET
;
MMTCAT: DEFB   '#'
        DEFW   MML_SH
        DEFB   '+'
        DEFW   MML_UO
        DEFB   0D7H
        DEFW   MML_UO
        DEFB   '-'
        DEFW   MML_DO
        DEFB   0CFH
        DEFW   MML_DO
        DEFB   'O'
        DEFW   MML_O
        DEFB   'N'
        DEFW   MML_N
        DEFB   'T'
        DEFW   MML_T
        DEFB   'V'
        DEFW   MML_V
        DEFB   'S'
        DEFW   MML_S
        DEFB   'M'
        DEFW   MML_M
        DEFB   'L'
        DEFW   MML_L
;
MML_DO: LD     C,-12           ;-
        DEFB   11H
;
MML_UO: LD     C,12            ;+
        CALL   TEST1
        DEFM   "#"
        JR     NZ,$+3
        INC    C
        DEFB   11H
;
MML_SH: LD     C,1             ;#
        CALL   HLFTCH
        CALL   MMAGCH
        RET    C
MML_AG: LD     B,A
        INC    HL
        CALL   MML_DL
        CCF
        CALL   C,MML_L1
        RET    C
        LD     A,B
        CP     'R'
        JR     Z,MML_R
        PUSH   HL
        LD     HL,ONCTT-41H    ;A-G
        CALL   ADDHLA
        LD     B,(IY+0)
        INC    B
        LD     A,(HL)
        POP    HL
        ADD    A,C
        SUB    12
        ADD    A,12
        DJNZ   $-2
        JR     MML_N0
;
MML_R:  XOR    A
MML_R0: PUSH   AF
        CALL   MML_WO
        POP    AF
MML_W1: LD     (IX+0),A
        INC    IX
        RET
;
MML_O:  CALL   MML_DL          ;O
        JR     NC,$+4
        LD     A,2
        CP     7
        CCF
        RET    C
        LD     (IY+0),A        ;oct No.
        RET
;
MML_N:  CALL   MML_DL          ;N
        RET    C
MML_N0: CP     NMAX+1
        CCF
        RET    C
        JR     MML_R0
;
MML_T:  CALL   MML_DL          ;T
        JR     NC,$+4
        LD     A,4
        DEC    A
        CP     7
        CCF
        RET    C
        ADD    A,6AH
        LD     (MML_W),A
        RET
;
MML_V:  CALL   MML_DL          ;V
        JR     NC,$+4
        LD     A,15
        CP     16
        CCF
        RET    C
        ADD    A,80H
        LD     (MML_W+1),A
        RET
;
MML_L:  CALL   MML_DL          ;L
        JR     NC,$+4
        LD     A,5
MML_L1: CP     10
        CCF
        RET    C
MML_L2: ADD    A,60H
        LD     (MML_W+2),A
        RET
;
MML_S:  CALL   MML_DL          ;S
        RET    C
        CP     9
        CCF
        RET    C
        ADD    A,90H
        LD     (MML_W+3),A
        RET
;
MML_M:  CALL   MML_DL          ;M
        RET    C
        OR     A
        SCF
        RET    Z
        LD     B,A
        LD     C,0A0H
        LD     (MML_W+4),BC
        OR     A
        RET
;
;
MML_DL: CALL   HLFTCH
        CALL   MMENCH
        SCF
        CALL   NZ,TSTNUM
        RET    C               ;RET not number
        RST    3
        DEFB   _DEASC
        JP     DCHECK
;
MMAGCH: CP     'R'             ;A-G & R check
        RET    Z
        CP     'A'
        RET    C
        CP     'H'
        CCF
        RET
;
MMENCH: OR     A
        RET    Z
        CP     0DH
        RET    Z
        CP     0C8H
        RET
;
MMLEND: CALL   MML_WO
        LD     A,0FFH           ;Music Data end
        CALL   MML_W1
        JP     MUSI6
;
MML_WO: LD     DE,MML_W
        LD     B,6
        LD     A,(DE)
        OR     A
        CALL   NZ,MML_W1
        INC    DE
        DJNZ   $-6
;
MML_WC: LD     DE,MML_W
        LD     B,6
        JP     CLRDE
;
;
ONCTT:  DEFB   9               ;A
        DEFB   11              ;B
        DEFB   0               ;C
        DEFB   2               ;D
        DEFB   4               ;E
        DEFB   5               ;F
        DEFB   7               ;G
;
MML_W:  DEFB   0               ;T
        DEFB   0               ;V
        DEFB   0               ;L
        DEFB   0               ;S
        DEFB   0               ;Mn
        DEFB   0
;
;       END  (9E4B)

;        ORG    9E4BH

; --------------------------
; MZ-800 BASIC  Work area
; FI:WORKQ  ver 1.0A 9.25.84
; Programed by T.Miho
; --------------------------
;
SWAPDS:                    ;SWAP save data start
;
NXTLPT:
        DEFS   2
EDLINE:
        DEFS   2
EDSTEP:
        DEFS   2
LNOBUF:
        DEFS   2
;
ERRCOD:
        DEFS   1
ERRORF:
        DEFS   1
ERRLNO:
        DEFS   2
ERRLPT:
        DEFS   2
ERRPNT:
        DEFS   2
ERRORV:
        DEFS   2
;
DATFLG:
        DEFS   1
DATPTR:
        DEFS   2
;
SWAPDE:                        ;SWAP save data end
;
SWAPBY:                    ;SWAP save data bytes
        DEFW   SWAPDE-SWAPDS   ;SWAP save data bytes
SWAPNB:                    ; -(SWAPBY)
        DEFW   SWAPDS-SWAPDE
;
;
STACK:
        DEFS   2
TEXTPO:
        DEFS   2
LSWAP:
        DEFB   0
;
DGBFM1:
        DEFS   1
DGBF00:
        DEFS   7
DGBF07:
        DEFS   1
DGBF08:
        DEFS   3
DGBF11:
        DEFS   1
DGBF12:
        DEFS   4
DGBF16:
        DEFS   1
DGBF17:
        DEFS   8
DGBF25:
        DEFS   25
;
PRCSON:
        DEFB   8
ZFAC:
        DEFS   8
ZFAC1:
        DEFS   8
ZFAC2:
        DEFS   8
;
IMDBUF:
        DEFB   16H             ;CLR
        DEFB   0DH
        DEFM   " "
        DEFB   0D7H,0D7H,0D7H,0D7H,0D7H,0D7H,0D7H,0D7H,0D7H,0D7H,0D7H,0D7H,0D7H,0D7H,0D7H,0D7H,0D7H,0D7H,0D7H
        DEFB   0D7H,0D7H,0D7H,0D7H,0D7H,0D7H,0D7H,0D7H,0D7H,0D7H,0D7H,0D7H,0D7H,0D7H,0D7H,0D7H,0D7H,0D7H,0D7H
        DEFM   " "
        DEFM   "   BASIC "
        DEFB   05H
        DEFM   "INTERPRETER  "
        DEFB   06H
        DEFM   "MZ-5Z009"
TTJPEX:
IF RAMDISK
IF MOD_B
        DEFM   " V1.0B+ "
ELSE
        DEFM   " V1.0B +"
ENDIF
ELSE
        DEFM   " V1.0A  "
ENDIF
        DEFB   0DH
        DEFM   "   C"
        DEFB   05H
		DEFM   "OPYRIGHT "
        DEFB   06H
		DEFM   "(C) 1984 "
        DEFB   05H
		DEFM   "BY "
        DEFB   06H
		DEFM   "SHARP CORP.     "
        DEFB   0CFH,0CFH,0CFH,0CFH,0CFH,0CFH,0CFH,0CFH,0CFH,0CFH,0CFH,0CFH,0CFH,0CFH,0CFH,0CFH,0CFH,0CFH,0CFH
        DEFB   0CFH,0CFH,0CFH,0CFH,0CFH,0CFH,0CFH,0CFH,0CFH,0CFH,0CFH,0CFH,0CFH,0CFH,0CFH,0CFH,0CFH,0CFH,0CFH
        DEFM   " "
        DEFB   0DH
        DEFM   " "
        DEFB   05H
		DEFM   "22340 BYTES FREE"
        DEFW   0D0DH
        DEFB   0

        DEFS   5CH
;
;
;        END  (9FCEH)




;        ORG    9FCEH

; -----------------------------
; MZ-800 BASIC  Plotter package
; FI:PLT  ver 1.0A 8.25.84
; Programed by T.Miho
; -----------------------------
;

;
;P_PLT:  EQU    0
PNCHNM: DEFB   "N"             ;N,S,L
;
NEWON:
        LD     BC,ER59_
        LD     DE,NEWONT       ;NEW ON
NEWON2: LD     A,(DE)          ; omit plotter
        INC    DE
        ADD    A,A
        JR     Z,NEWON4
        LD     HL,SJPTBL
        CALL   ADDHLA
        LD     (HL),C
        INC    HL
        LD     (HL),B
        JR     NEWON2
NEWON4: XOR    A               ; PLOT OFF
        LD     (INPFLG),A
        LD     A,(PNMODE)
        DEC    A
        CALL   NZ,MODETX       ; PMODE TX
        LD     HL,NEWAD2
NEWON9: LD     (TEXTST),HL
        RET


;
NEWONT: DEFB   0A2H             ;PMODE
        DEFB   0A3H             ;PSKIP
        DEFB   0A4H             ;PLOT
        DEFB   0A5H             ;PLINE
        DEFB   0A6H             ;RLINE
        DEFB   0A7H             ;PMOVE
        DEFB   0A8H             ;RMOVE
        DEFB   0AEH             ;PCOLOR
        DEFB   0AFH             ;PHOME
        DEFB   0B0H             ;HSET
        DEFB   0B1H             ;GPRINT
        DEFB   0B3H             ;AXIS
        DEFB   0BBH             ;PCIRCLE
        DEFB   0BCH             ;PTEST
        DEFB   0BDH             ;PAGE
        DEFB   0
;
LPTTMD:
        LD     B,1             ;Check text mode
        JR     $+4
LPTGMD:
        LD     B,2             ;Check graph mode
        LD     A,(PNMODE)
        CP     B
        RET    Z
        JP     LPTMER
;


;
NEWAD2:
;
MODE:
        CALL   MODE0           ;"PMODE" command
        XOR    A
        LD     (LPOSB),A       ;LPT TAB
        RET
;
MODE0:  LD     A,(INPFLG)
        OR     A
        JP     NZ,LPTMER
        CALL   PPCHCK
        CALL   TEST1
        DEFM   "G"
        JP     Z,PGRAPH
        CALL   TESTX
        DEFB   "T"
        CALL   TEST1
        DEFM   "N"
        JR     Z,TEXTN
        CALL   TEST1
        DEFM   "L"
        JR     Z,TEXTN
        CALL   TESTX
        DEFB   "S"
TEXTN:  LD     (PNCHNM),A
        CALL   ENDZ
        CALL   OUTA3H
MODETX: LD     A,1
        LD     (PNMODE),A
        RST    3
        DEFB   _LPTOT
        LD     A,(PNCHNM)
        CP     'N'
        RET    Z
        CP     'L'
        LD     A,0BH
        JR     Z,XLPTOT
T80CH:  LD     A,9
        RST    3
        DEFB   _LPTOT
        RST    3
        DEFB   _LPTOT
XLPTOT:
        RST    3
        DEFB   _LPTOT
        RET
;
OUTA3H: LD     A,0AH
        RST    3
        DEFB   _LPTOT
        LD     A,3
        JR     XLPTOT
;
PGRAPH: INC    HL              ;Graphic mode
        CALL   ENDZ
        LD     A,2
        LD     (PNMODE),A
        JR     XLPTOT


;
SKIP:
        CALL   PPCHCK
        CALL   LPTTMD          ;SKIP n
        CALL   IDEEXP
        LD     A,E
        OR     A
        RET    Z
        CP     -20
        JR     NC,SKIPPS
        CP     21
        JP     NC,ER03__
SKIPPS: CALL   ENDZ
        BIT    7,E
        JR     NZ,SKIPD
SKIPI:  LD     A,0AH
        RST    3
        DEFB   _LPTOT
        DEC    E
        JR     NZ,SKIPI
        RET
;
SKIPD:  LD     A,03H
        RST    3
        DEFB   _LPTOT
        INC    E
        JR     NZ,SKIPD
        RET
;
PNMX99: PUSH   HL
        LD     HL,999
        JR     $+6
PNMX48: PUSH   HL
        LD     HL,480
        PUSH   HL
        ADD    HL,DE
        POP    HL
        JR     C,PNMX2
        SBC    HL,DE
        JP     C,ER03__
PNMX2:  POP    HL
        RET


;
PLINE:                    ; PLINE %n,x,y
        LD     C,'D'
        DEFB   11H
RLINE:                    ; RLINE %n,x,y"
        LD     C,'J'
        DEFB   11H
PMOVE:                    ; PMOVE x,y
        LD     C,'M'
        DEFB   11H
RMOVE:                    ; RMOVE x,y
        LD     C,'R'
        CALL   PPCHCK
        CALL   LPTGMD
        LD     A,C
        LD     (LINEC+1),A
        CP     'M'
        JR     NC,LINE5        ;"M","R"
        CALL   TEST1
        DEFM   "%"
        JR     NZ,LINE5
        CALL   IBYTE
        LD     A,E
        DEC    A
        CP     16
        JP     NC,ER03__
        DEC    DE
        LD     A,'L'
        RST    3
        DEFB   _LPTOT
        CALL   NUMPLT
        CALL   LPTCR
        CALL   ENDCHK
        RET    Z
        CALL   CH2CH
LINE5:  CALL   IDEEXP
        CALL   CH2CH
        CALL   PNMX48
        PUSH   DE
        CALL   IDEEXP
        CP     ','
        JR     Z,LINEXY
        CALL   ENDZ
LINEXY: CALL   PNMX99
        POP    BC
        PUSH   DE
LINEC:  LD     A,0             ;Plotter command
        RST    3
        DEFB   _LPTOT
        LD     E,C
        LD     D,B
        CALL   NUMPLT          ;X
        CALL   LPTCOM
        POP    DE
        CALL   NUMPLT          ;Y
        CALL   LPTCR
        CALL   ENDCHK
        RET    Z
        INC    HL
        JR     LINE5


;
PCOLOR:
        CALL   PPCHCK
        CALL   IBYTE           ;PCOLOR n
        LD     A,E
        CP     4
        JP     NC,ER03__
        CALL   ENDZ
        LD     A,(PNMODE)
        CP     2
        JR     Z,PNMBR2
        CALL   OUTA3H
        LD     A,2
        RST    3
        DEFB   _LPTOT
        CALL   PNMBR2
        JP     PRTTX
;
PNMBR2: LD     A,'C'
        RST    3
        DEFB   _LPTOT
        LD     A,E
        OR     30H
        RST    3
        DEFB   _LPTOT
LPTCR:  LD     A,0DH
        JR     $+4
LPTCOM: LD     A,','
YLPTOT:
        RST    3
        DEFB   _LPTOT
        RET
;
PHOME:
        LD     C,'H'
        DEFB   11H
HSET:
        LD     C,'I'
        CALL   LPTGMD          ;PHOME / HSET
        CALL   ENDZ
        LD     A,C
        JR     YLPTOT
;


;
GPRINT:
        CALL   PPCHCK
        CALL   LPTGMD          ;GPRINT [n,s],x$
        CALL   TEST1
        DEFM   "["
        JR     NZ,SYMBL2
        CALL   IBYTE
        CP     64
        JP     NC,ER03__
        PUSH   DE
        CALL   HCH2CH
        CALL   IBYTE
        CP     4
        JP     NC,ER03__
        PUSH   DE
        CALL   TESTX
        DEFM   "]"
        POP    BC
        POP    DE
        PUSH   BC
        LD     A,'S'
        RST    3
        DEFB   _LPTOT
        CALL   NUMPLT
        CALL   LPTCOM
        POP    DE
        LD     A,'Q'
        RST    3
        DEFB   _LPTOT
        CALL   NUMPLT
        CALL   LPTCR
        CALL   ENDCHK
        RET    Z
        CALL   CH2CH
SYMBL2: CALL   STREXP
        CALL   ENDCHK
        JR     Z,SYMBL5
        CALL   CH2CH
        DEC    HL
SYMBL5: LD     A,B
        OR     A
        JR     Z,SYMBL4
        LD     A,'P'
        RST    3
        DEFB   _LPTOT
SYMBL3: LD     A,(DE)
        RST    3
        DEFB   _LPTOT
        INC    DE
        DJNZ   SYMBL3
        CALL   LPTCR
SYMBL4: CALL   ENDCHK
        RET    Z
        INC    HL
        JR     SYMBL2


;
AXIS:
        CALL   LPTGMD          ;AXIS x,p,r
        CALL   IBYTE
        CP     2
        JP     NC,ER03__
        PUSH   AF
        CALL   HCH2CH
        CALL   IDEEXP
        PUSH   DE
        CALL   CH2CH
        CALL   IBYTE
        OR     A
        JP     Z,ER03__
        CALL   ENDZ
        LD     A,'X'
        RST    3
        DEFB   _LPTOT
        POP    BC
        POP    AF
        PUSH   DE
        PUSH   BC
        OR     30H
        RST    3
        DEFB   _LPTOT
        CALL   LPTCOM
        POP    DE
        CALL   PNMX99
        CALL   NUMPLT
        CALL   LPTCOM
        POP    DE
        CALL   NUMPLT
        JP     LPTCR


;
PCIRCLE:
        CALL   LPTGMD          ;PCIRCLE x,y,r,s,e,d
        PUSH   HL
        LD     DE,0
        LD     HL,CRS
        CALL   FLTHEX
        LD     DE,360
        LD     HL,CRE
        CALL   FLTHEX
        LD     HL,FLTEN
        LD     DE,CRTEN
        CALL   LDIR5
        POP    HL
        CALL   EXPR            ;X
        CALL   CH2CH
        PUSH   HL
        LD     HL,CRX
        EX     DE,HL
        CALL   LDIR5
        POP    HL
        CALL   EXPR            ;Y
        CALL   CH2CH
        PUSH   HL
        LD     HL,CRY
        EX     DE,HL
        CALL   LDIR5
        POP    HL
        CALL   EXPR            ;R
        PUSH   HL
        PUSH   AF
        LD     HL,CRR
        EX     DE,HL
        CALL   LDIR5
        LD     A,(CRR+1)
        RLCA
        JP     C,ER03__
        POP    AF
        CP     ','
        JR     NZ,CIREND
        POP    HL
        INC    HL
        CALL   EXPR            ;S
        PUSH   HL
        PUSH   AF
        LD     HL,CRS
        EX     DE,HL
        CALL   LDIR5
        POP    AF
        CP     ','
        JR     NZ,CIREND
        POP    HL
        INC    HL
        CALL   EXPR            ;E
        PUSH   HL
        PUSH   AF
        LD     HL,CRE
        EX     DE,HL
        CALL   LDIR5
        POP    AF
        CP     ','
        JR     NZ,CIREND
        POP    HL
        INC    HL
        CALL   EXPR            ;D
        PUSH   HL
        LD     HL,CRTEN
        EX     DE,HL
        CALL   LDIR5
        LD     A,(CRTEN+1)
        RLCA
        JP     C,ER03__
CIREND:
        POP    HL
        CALL   ENDZ
        PUSH   HL
;
        LD     HL,CRE
        LD     DE,CRS
        LD     A,(CRTEN)
        OR     A
        CALL   NZ,CMP
        JP     C,ER03__
;
        CALL   CRXYRS          ;CAL X,Y
;
        LD     HL,CRXX         ;MOVE X,Y
        LD     (CRMOVX+1),HL
        LD     HL,CRYY
        LD     (CRMOVY+1),HL
        CALL   CRMOVE
        LD     A,(CRTEN)
        OR     A
        JR     Z,CREDLI
;
CRCLP:  LD     HL,CRS          ;S+D
        LD     DE,CRTEN
        CALL   ADD
        LD     DE,CRE
        CALL   CMP
        JR     NC,_EDLINE
        CALL   CRXYRS
        CALL   CRLINE
;
        RST    3
        DEFB   _BREAK
        JR     NZ,CRCLP
;
        POP    HL
        RET
;
_EDLINE: CALL   CREDST
        CALL   CRLINE
        POP    HL
        RET
;
CREDST: LD     HL,CRE
        LD     DE,CRS
        LD     BC,5
        LDIR
        JR     CRXYRS
;
CREDLI: LD     HL,CRX
        LD     (CRMOVX+1),HL
        LD     HL,CRY
        LD     (CRMOVY+1),HL
        CALL   CRLINE
        CALL   CREDST
        LD     HL,CRXX
        LD     (CRMOVX+1),HL
        LD     HL,CRYY
        LD     (CRMOVY+1),HL
        CALL   CRLINE
        POP    HL
        RET
;
CRLINE: LD     A,'D'
        DEFB   21H
CRMOVE: LD     A,'M'
        PUSH   AF
CRMOVX: LD     HL,CRX
        CALL   HLFLT
        PUSH   HL
        EX     DE,HL
        CALL   PNMX99
CRMOVY: LD     HL,CRY
        CALL   HLFLT
        PUSH   HL
        EX     DE,HL
        CALL   PNMX99
        POP    HL
        POP    DE
        POP    AF
        RST    3
        DEFB   _LPTOT
        PUSH   HL
        CALL   NUMPLT
        CALL   LPTCOM
        POP    DE
        CALL   NUMPLT
        JP     LPTCR
;
CRXYRS: LD     DE,(INTFAC)
        LD     HL,CRS
        CALL   LDIR5
        LD     HL,(INTFAC)
        CALL   RAD
        CALL   COS
        LD     DE,CRR
        CALL   MUL
        LD     DE,CRX
        CALL   ADD
        LD     DE,CRXX
        CALL   LDIR5
        LD     DE,(INTFAC)
        LD     HL,CRS
        CALL   LDIR5
        LD     HL,(INTFAC)
        CALL   RAD
        CALL   SIN
        LD     DE,CRR
        CALL   MUL
        LD     DE,CRY
        CALL   ADD
        LD     DE,CRYY
        JP     LDIR5
;
CRX:    DEFS   5
CRY:    DEFS   5
CRR:    DEFS   5
CRS:    DEFS   5
CRE:    DEFS   5
CRTEN:  DEFS   5
CRXX:   DEFS   5
CRYY:   DEFS   5
        DEFS   5
;
;
;
NUMPLT: PUSH   AF
        PUSH   HL
        LD     HL,(INTFAC)
        CALL   FLTHEX
        CALL   CVNMFL
        RST    3
        DEFB   _COUNT
NUMPL2: LD     A,(DE)
        RST    3
        DEFB   _LPTOT
        INC    DE
        DJNZ   NUMPL2
        POP    HL
        POP    AF
        RET
;


;
TEST:
        CALL   PPCHCK
        CALL   LPTTMD          ;TEST command
        CALL   ENDZ
        LD     A,04H
        RST    3
        DEFB   _LPTOT
        RET
;
PAGE:
        CALL   LPTTMD          ;PAGE n
        CALL   IDEEXP
        LD     A,E
        OR     A
        JP     Z,ER03__
        CP     73
        JP     NC,ER03__
        CALL   ENDZ
        LD     A,9
        RST    3
        DEFB   _LPTOT
        RST    3
        DEFB   _LPTOT
        LD     A,(PSEL)
        BIT    P_PLT,A
        JR     Z,PAGE2
        CALL   NUMPLT          ;Plotter only
        JP     LPTCR
PAGE2:  LD     A,E             ;Except plotter
        LD     DE,KEYBUF
        CALL   HEXACC
        DEC    DE
        DEC    DE
        LD     A,(DE)
        RST    3
        DEFB   _LPTOT
        INC    DE
        LD     A,(DE)
        RST    3
        DEFB   _LPTOT
        RET
;
PLOT:
        LD     A,(HL)
        CP     9DH             ;PLOT ON/OFF
        JR     Z,PLOTO_
        CP     0A1H            ;OFF
        JP     NZ,ER01
        XOR    A
PLOTOK: LD     (INPFLG),A
        INC    HL
        RET
PLOTO_: CALL   LPTTMD
        CALL   PPCHCK
        LD     A,(PNCHNM)
        CP     'L'
        JP     Z,LPTMER
        CALL   PRTTX
PL40C:  LD     A,(INPFLG)
        OR     A
        JR     NZ,PLOTOK
        CALL   CONSOI
        LD     A,16H
        RST    3
        DEFB   _CRT1C
        OR     01H
        JR     PLOTOK
;
PRTTX:  LD     A,1
        RST    3
        DEFB   _LPTOT
        LD     A,(CRTMD2)
        CP     3
        RET    C
        CALL   T80CH
        RET
;
PPCHCK: LD     A,(PSEL)
        BIT    P_PLT,A         ;if not plotter
        JP     Z,LPTMER        ; then err
        RET


;        END  (A471)


BASIC_PGM:

; Block filler present in the MOD_A tape dump
;defb $1a, $1a, $1a, $1a, $1a, $1a, $1a, $1a, $1a, $1a, $1a, $1a, $1a, $1a, $1a


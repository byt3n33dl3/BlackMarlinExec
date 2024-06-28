; written by KarlHeinz.Mau@t-online.de 1996, last modified August 22nd, 1998
;
; This program communicates with Commodore 15xx floppy disk drive running
; on Sharp MZ700-series homecomputers.
;
; The following commands are implemented:
; 
; "L" Load a file from 15xx. The load address is modifiable, the program 
;     displays the address where it was stored. You can use or modify this 
;     address. First you have to specify the name of the file to load.
;
; "S" Save a file to 15xx. You have to know the begin/end address for save
;     and you have to specify the name of the file to save. The name of 
;     the file must not exceed 16 characters in length.
;
; "V" Verifies a stored file.
;
; "C" You can input and send any command decsribed in handbooks for 15xx to 
;     the drive.
;
; "F" Reads and displays the error message channel of the floppy drive.
;
; "D" Loads the directory to main storage at location 6bcfh and displays the 
;     directory.
;     Note, loaded directory overwrites the basic program area, like 
;     the C64 does.
;
; "I" Outputs directory to printer.
;
; "P" Outputs directory to plotter.
;
  

 	  CPU	Z80
          org	0a000h 			; A000h Entrypoint MZ700 
	  jp	start			; jump around definitions

;	MZ7xx-Characterset conversion
	  CHARSET	'a',0a1h
	  CHARSET	'b',09ah
	  CHARSET	'c',09fh
	  CHARSET	'd',09ch
	  CHARSET	'e',092h
	  CHARSET	'f',0aah
	  CHARSET	'g',097h
	  CHARSET	'h',098h
	  CHARSET	'i',0a6h
	  CHARSET	'j',0afh
	  CHARSET	'k',0a9h
	  CHARSET	'l',0b8h
	  CHARSET	'm',0b3h
	  CHARSET	'n',0b0h
	  CHARSET	'o',0b7h
	  CHARSET	'p',09eh
	  CHARSET	'q',0a0h
	  CHARSET	'r',09dh
	  CHARSET	's',0a4h
	  CHARSET	't',096h
	  CHARSET	'u',0a5h
	  CHARSET	'v',0abh
	  CHARSET	'w',0a3h
	  CHARSET	'x',09bh
	  CHARSET	'y',0bdh
	  CHARSET	'z',0a2h
	  CHARSET	'ä',0bbh
	  CHARSET	'ö',0bah
	  CHARSET	'ü',0adh
	  CHARSET	'ß',0aeh
	  CHARSET	'Ä',0b9h
	  CHARSET	'Ö',0a8h
	  CHARSET	'Ü',0b2h

;	Monitor-ROM-entries
GETL:	  equ	0003h			; get input line to (de)
LETNL:	  equ	0006h			; set cursor to next line
PRNT:	  equ	0012h			; print character in accu
MSG:	  equ	0015h			; print character string from (de)
ST1:	  equ	00adh			; entry of Monitor-ROM
LPRNT:	  equ	018fh			; 1 Char. plot 
PRTHL:	  equ	03bah			; ascii print for hl
PRTHX:	  equ	03c3h			; ascii print for accu
HLHEX:	  equ	0410h			; compute 4 ascii to hl
KEY:	  equ	09b3h			; waits for any key (accu=displ.code)
SWEP:	  equ	0a50h			; checks for any key pressed
DACN:	  equ	0bceh			; converts display-code to ascii
dacn10:	  equ	0bd4h			; conversion routine
DSP:	  equ	0db5h			; prints display-code from accu
DSPXY:	  equ	1171h			; 1171 curr. column, 1172 curr. row
BasStrt:  equ	6bcfh			; Start adress Basic-program area
screen:	  equ	0d000h			; start of screen area
le000:	  equ	0e000h			; 8255 Port A
le001:	  equ	0e001h			; 8255 Port B
le008:	  equ	0e008h			; LS367

;	constants

lf:	  equ	0ah			; line feed + autom. cr for printer
cr:	  equ   0dh			; Carriage Return
cls:	  equ	16h			; Clear-Screen-Character
brk2:	  equ	1bh			; MZ-code break
spc:	  equ	20h			; space-/blank-character
brk1:	  equ	0CBh			; Keycode Break
cr2:	  equ	66h			; Keycode carriage return

;	Definitions, variables, switches
Prompt0:  db    "LSVCDIPF : \r"		; \r = 0Dh = Stringend
Prompt1:  db    "Command  : \r"
Prompt2:  db	"Load to  : \r"
Prompt3:  db	"Begin    : \r"
Prompt4:  db	"End      : \r"
Prompt5:  db	"Filename : \r"
DEVNPRES: db	"Device not present\r"
Break:	  db	"Break\r"
veriferr: db	"Verifying error\r"
saveerr:  db	"Save error\r"
loaderr:  db	"Load error\r"
searchfo: db	"Searching for \r"
loading:  db	"Loading \r"
veryfing: db	"Verifying \r"
saving:	  db	"Saving \r"
filenfnd: db	"File not found\r"
namemiss: db	"Missing filename\r"

PrtSw:	  db	0ffh			; 'P'=Plot, not 'P'=print
lc401:	  db	00h			; 00h=go back to monitor,
					; not 00h=goback to caller
stackptr: dw	0000h			; stack on entry to hardcopy routine
stckptr:  dw	0000h			; stack pointer to return from errors

;	IEC-Definitions

ST:	  db	40h			; (90h) means c64-zero-page,
					; Status word
LVFlag:	  db	00h			; (93h) 00=load, 01=verify, 02=save
iecflag:  db	55h			; (94h)  flag at IEC-output
IECBUF:	  db	00h			; (95h) 1 byte IEC-buffer for
					; received byte
sta:	  db	55h			; (a3h), IEC I/O-status
bitcnt:	  db	00h			; (a4h), IEC I/O-bit counter
EndPtr:	  dw	00cdh			; (aeh) current save-/load address
fileLen:  db	0dh			; (b7h) length of file name
SecAdr:	  db	60h			; (b9h) secondary address
GerNr:	  db	08h			; (bah) device number (Floppy 8)
IOStrt:	  dw	0000h			; (c1h) start address
AdrLoad:  dw	00c1h			; load address for file/directory
biostrt:  dw	0200h			; save start address
asave:	  db	00h			; save for accu
hlsave:	  db	0000h			; save for hl
zwispei:  db	0b5h			; save for received bit(s)
svsecadr: db	4eh			; save sec. address
ascwork:  db	"00000"			; workarea ascii-convertion 
   	 
	  NEWPAGE
	
;	Entrypoint

start:	  ld	de,Prompt0		;  (prompt0)
	  call  inptproc
	  jp	z,intbrk
	  call	DACN			; convert display code to ascii
	  cp	cr2			; enter (cr) key pressed?
	  jp    z,start			; yes, once more
	  ld	(stckptr),sp		; save stackpointer for errors
	  cp	'C'			; C to put any command on floppydrive
	  jp	z,cmdin			; yes, jump in
	  cp	'D'			; D to get directory on screen
	  jp	z,start015		; yes, jump in
	  cp	'F'			; F to get 15xx error message 
	  jp	z,GetErSta		; yes, jump in
	  cp	'L'			; L to load a file
	  jp	z,Load			; yes, jump in
	  cp	'S'			; S to save a file
	  jp	z,Save			; yes, jump in
	  cp	'V'			; V to verify a stored file
	  jp	z,Verify		; yes, jump in
	  cp	'P'			; P to plot directory
	  jp	nz,start020		; no, try 'I'
	  ld	a,40h			; set IRT bit
	  out	(0feh),a		; IRT plotter (reset)
	  ld	a,00h			; clr lines
	  out	(0feh),a
	  ld	a,'P'
start015: ld	(PrtSw),a		; store to print marker
	  jp	getdir			; continue 

start020: cp	'I'			; I to print directory?
	  jr	nz,start		; no, error, once more
	  ld	(PrtSw),a		; store to print marker
start030: IN	A,(0FEh)
	  BIT	0,A			; busy?
	  JR	Z,getdir		; not busy
	  OR	40h			; set IRT
	  OUT	(0FEh),A		; reset printer
	  CALL	lC719			; test break key
	  JR	NZ,start030		; no, loop
	  jp	intbrk			; yes, goback

inptproc: call	MSG			; print message (de)
inptp10:  call	KEy			; wait on any key. (display code)
	  cp	brk1			; break key pressed?	
	  ret	z			; yes, jump to break routine
	  cp	0c1h			; don't show keys (c1h-cdh)cc?
	  call	c,DSP			; echo key to screen
	  push	af			; save key code
	  call	LETNL			; skip cursor to next line
	  pop	af			; restore
	  and	a			; no break (note: test space bar?)
	  ret

;	input for a 157xx-command that is to send to drive
cmdin:	  ld	de,prompt1		; address of prompt1 to de
	  call	GetNam05		; get command input line
	  jp	z,intbrk		; jump if break key or cr key pressed
	  ld	a,0fh			; command channel 0fh
	  ld	(SecAdr),a		; store in
	  call	IECOPEN			; open cmd channel and submit cmd
	  call	IECCLOSE		; close cmd channel
	  call	ErrorChk		; check for errors
	  jp	GetErSta		; all done, displ. error msg channel

	  
;	Load and display directory 

GetDir:	  xor	a			; 00=Load directory
	  ld	(LVFlag),a		
	  inc	a			; 00+01
	  ld	(fileLen),a		; "$" is length of 1 
	  ld	a,'$'			; $ is 157xx command to load directory
	  ld	(fileName+11),a		; $ to the command line
	  ld	hl,BasStrt		; area to store the directory info
	  ld	(AdrLoad),hl		; save adress for load routine
	  xor	A		
	  LD	(SecAdr),a		; dir load transfer on channel 0
	  call	IECLOAD			; exec load routine
	  call	ErrorChk		; check for errors
 	  jp	c,intbrk		; stop at brk
	  ld	de,BasStrt		; address of directory info in main
DirPrt05: ld	a,cls			; first clear the screen
	  call	prnt			; do it
DirPrt10: inc	de			; skip around two 01h
	  inc	de
	  ex	de,hl
	  ld	e,(hl)			; load # of blocks to de
	  inc	hl
	  ld	d,(hl)
	  inc	hl
	  ex	de,hl			; now to hl for hltoasc
	  call	HLtoASC			; print # blocks
DirPrt20: ld	a,(de)			; check for line end
	  and	a			
	  jr	z,DirPrt40		; yes, line end reached
	  cp	spc			; check for C64 reverse on 12h and
	  jr	nc,DirPrt30		; other non displayable codes
	  ld	a,spc			; yes, force them to space
DirPrt30: call 	prnt			; Display character
	  inc	de			; next char form dir
	  jr	DirPrt20		; continue at this line

DirPrt40: inc	de
	  ld	A,(de)			; check end of directory
	  and	a			; (2nd 00h means end of dir)
	  jr	nz,dirprt50		; no, continue
	  ld	a,(prtsw)		; yes, process end of dir now
	  cp	'D'			; screen only?
	  jr	nz,dirprt45		; no, output too
dirprt43: call	letnl			; set cursor to next line on screen
	  jp	start			; goback

dirprt45: ld	a,0ffh			; lc692 uses ret command and not jump
	  ld	(lc401),a		; to monitor for returning
	  call	lc692			; print/plot
	  jp	z,intbrk
	  call	lc713			; new line char printer/plotter
	  jp	z,intbrk		; stop at brk condition 
	  jr	dirprt43		; go endprocess

dirprt50: ld	a,(DSPXY+1)		; get row number from systemarea
	  cp	24			; screen full?
	  jr	nz,DirPrt60		; no, do new line on screen 
	  ld	a,(prtsw)
	  cp	'D'			; dir to screen only?
	  jr	z,dirprt55		; yes
	  ld	a,0ffh			; no, force return of lc692 to me
	  ld	(lc401),a		; and not to monitor
	  call	lc692			; hardcopy screen
	  jp	z,intbrk		; brk condition during hardcopy
	  jr	dirprt05		; cls, next screen

dirprt55: call	WaitKey			; yes, wait on any key
	  jp	z,intbrk		; break key stops process
	  jr 	DirPrt05		; do next line after clear screen

DirPrt60: call  LETNL			; set cursor to new line
	  jr	DirPrt10		; and continue process

;	Get and display message from drive

GetErSta: xor	A
	  LD	(ST),a			; clear status byte
	  ld	a,(GerNr)		; set device number
	  call	SentTalk		; force device to init talk
	  ld	a,6fh
	  call	SentSAdr		; init device with parameters
GetSta10: call  IECIN			; get 1 character from device
	  push	af			; save gotten character
	  ld	a,(ST)			; check device status
	  and	a
	  jr	z,GetSta20		; ok, continue
	  call	letnl			; CR/new line
	  ld	a,(st)
	  cp	0c2h			; device not present status
	  jp	z,f707			; stop on error
	  pop	af			; end, restore accu
	  jp 	start			; done

GetSta20: pop	af			; restore gotten character
	  call	PRNT			; no, print the character on screen
	  jr	GetSta10		; and continue

;	Load file

Load:	  call	GetNam			; input file name
	  jp	z,intbrk		; stop if break or cr
	  jp	c,load			; again on any input error
	  xor	a
	  ld	(LVFlag),a		; 00h=Load
	  ld	a,0c9h			; at first get old address to store
	  ld	(MdfCmd02),a		; so read first two bytes only
	  call	IECLOAD			; do incomplete load first
	  call	F528			; untalk and close file
	  call	ErrorChk		; check for error
	  ld	a,3ah			; remodify load routine
	  ld	(MdfCmd02),a		; for complete work again
	  jp	c,GetErSta		; get error msg on error
	  ld	a,(ST)			; same on incorrect device status
	  and	a
	  jp	nz,GetErSta
Load20:	  ld	de,Prompt2		; set de to address of prompt2
	  call	MSG			; and print prompt2
	  ld	hl,(EndPtr)		; get old store address to hl
	  call	PRTHL			; and print old store address
	  ld	de,BUFL			; set address of input buffer
	  call	GETL			; get input line (store address)
	  ld	a,(de)
	  cp	brk2			; break?
	  jp	z,intbrk		; yes, stop
	  ld	de,BUFL+11		; address of input
	  call	HLHEX			; translate ascii-hex to hl 
	  jr	c,Load20		; no hex data, once more
	  ld	(AdrLoad),hl		; ok, save store address
	  xor	a
	  ld	(secadr),a		; means load to (adrload)
	  jr	Verify10		; jump around verify, load 00 to accu

;	verify saved file

Verify:	  ld	a,01h			; 01=verify
	  db	21h			; dummy instruction ld hl,3e00h
verify10: ld	a,00h			; 00=load
	  ld	(LVFlag),a		; store
	  call	IECLOAD			; load file
	  call	ErrorChk		; check for error
	  jp	GetErSta		; print error/ok message

;	Save file

Save:	  call	GetNam			; get data set name 
	  jp	z,intbrk		; stop on brk key
	  jr	c,save			; on error again
Save10:	  ld	de,Prompt3
	  call	MSG			; display prompt3
	  ld	de,BUFL
	  call	GETL			; get input to bufl (start address)
	  ld	a,(de)			; check for brk
	  cp	brk2
	  jp	z,intbrk		; stop
	  ld	de,BUFL+11		; 1st input char
	  ld	a,(de)
	  cp	cr			; if no input again
	  jr	z,Save10
	  call	HLHEX			; ascii to hex in hl
	  jr	c,Save10		; if not hex again
	  ld	(IOStrt),hl		; store in start address
Save20:	  ld	de,Prompt4
	  call	MSG			; display prompt4
	  ld	de,BUFL
	  call	GETL			; get input to bufl (end address)
	  ld	a,(de)
	  cp	brk2			; check for brk key
	  jp	z,intbrk		; stop on brk
	  ld	de,BUFL+11
	  ld	a,(de)			; get 1st input char
	  cp	cr			; check for no input
	  jr	z,Save20		; if cr only again 
	  call	HLHEX			; ascii to hex and put it to hl
	  jr	c,Save20		; on hex-error again
	  ld	(EndPtr),hl		; save end address
	  ld	a,02h
	  ld	(LVFlag),a		; 02 means iecstor has to save data
	  call	IECSTORE		; exec save on disk
	  call	ErrorChk		; test for errors
	  jp	GetErSta		; display floppy status message

;	get file or other input to fileNAME

GetNam:	  ld	de,Prompt5		; Address of prompt5 to de
GetNam05: call	MSG			; put prompt5 on screen
	  ld	de,fileName		; address of input area
	  call	GETL			; get input from keyboard
	  call	LETNL			; set cursor to new line
	  ld	a,(filename)		; get 1st char from input
	  cp	brk2			; break?
	  ret	z			; yes, goback
	  ld	de,filename+11	
	  ld	a,(de)			; get 1st char from input line
	  cp	cr			; test for cr
	  ret	z			; goback if no further input
	  ld	b,01h			; init length of name
GetNam10: cp	cr			; end of name?
	  jr	z,GetNam20		; yes, stop testing and counting
	  cp	spc			; valid name must be in the range of
	  ret	c			; 20h and 5fh
	  cp	5fh			
	  ccf				; carry is set if not
	  ret	c
	  inc	b			; count length
	  inc	de			; next byte address of name
	  ld	a,(de)			; get next byte of input
	  jr	GetNam10		; continue

GetNam20: ld	a,b			; length to accu
	  dec	a			; adjust to correct length in accu
	  ld	(fileLen),a		; save length
	  cp	17			; must not exceed 16 chars in length
	  ccf				; carry means wrong length
	  inc	a
	  dec	a
	  ret				; goback to caller

;	the following code is yet sleeping, 
;	it's for dir cmd if basic is active. The coding is under test.
;	sets pointers of basic like cmd NEW does, but dir is still stored in
;	basic's program area.
;
;	another code is in progress for save and load, if basic is active
;	and the user wants to save or load a basic program.
;
;bas:	  ld	hl,(6abfh)
;	  ld	a,6bh
;	  cp	h
;	  ret	nz
;	  ld	a,0cfh
;	  ret	nz
;	  ld	hl,(endptr)
;	  ld	(6ab3h),hl
;	  call  224eh
;	  ret
;
;startxx: call	bas
;	  jp	getdir


;	if accu=f0h (display code for space) then accu=space

lC674:	  CP	0F0h			; display code f0h? (space)
	  RET	NZ			; no
	  AND	20h			; yes, put space
	  RET				; goback
     
;	test shift-break

lC686:	  LD	A,0F8h			; column brk/ctrl/shift
	  LD	(lE000),A		; Port A 8255 send keyboard f8h
	  NOP				; wait 1 nop
	  LD	A,(lE001)		; Port B 8255 receive keyboard data
	  CP	7Eh			; shift + brk ?
	  RET				; goback

;	hardcopy entry

lc692:	  push	bc			; save caller's regs
	  push	de
	  push	hl
	  ld	(stackptr),sp		; 
	  LD	HL,screen		; address to screen area
	  PUSH	HL			; save for futher use
lC6C4:	  POP	HL			; addr. of current row in screen
	  PUSH	HL			; back for further use
	  LD	B,40			; init loop counter (40 columns/row) 
	  LD	D,00h			
	  LD	E,B			; DE is displacement to next row
	  ADD	HL,DE			; HL is address to next row on screen
	  LD	A,0D4h			; check for last row (starts at
	  CP	H			; address d410h)
	  JR	NZ,lC6D6		; not last
	  LD	A,10h
	  CP	L
	  JR	nZ,lC6d6		; not last
	  and	a			; accu is 10h, 'and a' sets NZ=no brk
	  JR	lC72Cn			; goback

lC6D6:	  POP	DE			; exchange entries on stack
	  PUSH	HL			; contains address of next row
	  PUSH	DE			; contains address of current row
lC6D9:	  DEC	HL			; skip backwards subsequent spaces
	  LD	A,(HL)			; get char
	  OR	A			; space?
	  JR	NZ,lC6E3		; no, start outputting, notice,
;					  b-reg contains # of char to output
	  DJNZ	lC6D9			; yes,skip space
	  POP	HL			; full space line rebuild stack
	  JR	lC6C4			; process next row

lC6E3:	  POP	HL			; curr. column address in curr. row
lc6e7:	  SET	3,H			; address to screen color 
	  LD	A,17h			; color of char blue, backgrd. white
	  LD	(HL),A			; set to invert value
	  RES	3,H			; address back to the char. screen
	  LD	A,(HL)			; get char to output
	  CALL	lC78E			; convert displ. code to ascii
	  OR	A			; 00h?
	  JR	NZ,lC6FC		; no
	  OR	20h			; yes, force space on output
lC6FC:	  CALL	lC75B			; output 1 char
	  jp	z,lc72c			; brk condition occured
	  SET	3,H			; address to screen color 
	  LD	A,71h			; color of char white, backgrd. blue
	  LD	(HL),A			; reset to normal value
	  RES	3,H			; address back to the char. screen
	  INC	HL			; next char
	  DJNZ	lC6E7			; loop if length(contents of row)>0
	  call	lc713			; set pen to next line
	  jp	z,lc72cn		; brk condition occured
	  JR	lC6C4			; loop for next row

;	skip to new line (for both, printer/plotter)

lc713:	  ld	a,(prtsw)		; 
	  cp	'P'			; plotter?
	  ld	a,cr			; cr for plotter
	  jr 	z,lc715			; yes, do cr
	  ld	a,lf			; no, lf for printer
lc715:	  call	lc75b			; output cr or lf
	  ret

;  goes back to monitor, if brk key used and started from monitor
;			 else returns if brk key used and called by program
lC719:	  CALL	lC686			; test brk key
	  RET	NZ			; no, continue
lC71D:	  CALL	lC686			; test again and
	  JR	Z,lC71D			; wait until unpressed
	  xor	a			; zero flag indicates break
	  ret

lc72c:	  SET	3,H			; address to screen color 
	  LD	A,71h			; color of char white, backgrd. blue
	  LD	(HL),A			; reset to normal value, may be inv.
	  xor	a			; set zflag (brk condition)
lC72Cn:	  push	af			; save zero flag (z=brk, nz=no brk)
	  LD	A,(lC401)		; 0 means jumped into program by mon.
	  AND	A			; >0 means called by any program
	  JP	z,intrpt		; goback to monitor
	  XOR	A			; prepare next execution parameters
	  LD	(lC401),A
	  pop	af			; notice zflag to caller
	  ld	sp,(stackptr)
	  pop	hl			; restore caller's reg's
	  POP	DE
	  POP	BC
	  ret				; goback to caller

;	plot 1 character

lC73B:	  PUSH	BC			; save callers reg
	  LD	C,00h			; 00h=ready
	  LD	B,A			; save
	  CALL	lC753			; wait on ready
	  jr	z,lc738bn		; stop on brk
	  LD	A,B			; restore char to plot
	  OUT	(0FFh),A		; data to plotter
	  LD	A,80h			; RDP (strobe) high
	  OUT	(0FEh),A		; to plotter
	  LD	C,01h			; RDA test 
	  CALL	lC753			; wait (ack)
	  jr	z,lc738bn		; stop on brk
	  XOR	A
	  OUT	(0FEh),A		; RDP low
	  cpl
	  and	a			; NZ=no brk
lc738bn:  POP	BC			; restore callers reg
	  RET     			; goback to caller

lC753:	  IN	A,(0FEh)
	  AND	00Dh			; RDA only
	  CP	C			; test busy
	  jr	nZ,lc753n		; not busy
lc753v:	  cpl				; ffh/feh
	  and	a			; indicate no break (NZ)
	  ret

lc753n:	  call	lc719			; test break key
	  JR	nz,lC753		; wait on ready
	  ret				; zflag=brk condition

;	outputs 1 character to plotter if (lc3fc) = "P"
;				       else to printer

lC75B:	  LD	C,A			; save char to output	
	  LD	A,(prtsw)		; get user's input char
	  CP	'P'			; "P"?
	  LD	A,C			; get back char to output
	  JR	Z,lC73B			; yes, go plot 1 char
lC764:	  IN	A,(0FEh)		; get state of printer
	  BIT	0,A			; busy?
	  JR	Z,lC772			; no, continue
	  CALL	lC719			; yes, busy, brk key?
	  JR	NZ,lC764		; no. Wait on ready
	  Ret				; goback with brk condition

;	print 1 char

lC772:	  LD	A,C			; get back char to print
	  OUT	(0FFh),A		; data out
	  IN	A,(0FEh)		; get state of printer
	  AND	7Fh			; set strobe
	  OUT	(0FEh),A		; put strobe
	  IN	A,(0FEh)		; get state again
	  OR	80h			; reset strobe
	  OUT	(0FEh),A		; put out
lC781:	  IN	A,(0FEh)		; get state
	  BIT	0,A			; test busy
	  jr	Z,lc753v			; not busy, goback to caller
	  CALL	lC719			; brk key?
	  JR	NZ,lC781		; no, wait on ready (printed)
	  Ret				; yes, goback, brk

;	display to ascii for printer or plotter

lC78E:	  PUSH	AF			; save char to output
	  LD	A,(prtsw)		; users input char
	  CP	'P'			; "P" (plotter)?
	  JR	NZ,lC79D		; no, printer
	  POP	AF			; char to plot
	  CALL	lC66B			; display to ascii (plotter)
	  JP	lC674

;	display to ascii conversion for plotter
;	returns from monitor to caller

lc66b:	  PUSH	BC			; save own regs
	  PUSH	HL
	  PUSH	DE
	  LD	HL,lC402		; my translation table for plotter
	  JP	dacn10			; use monitor's conversion routine


lC79D:	  POP	AF
	  CALL	lC7A4			; display to ascii conversion
	  JP	lC674			; if 0f0h conv. to spc, then goback

;	diplay to ascii conversion for printer

lC7A4:	  PUSH	BC			; save callers reg
	  PUSH	HL
	  PUSH	DE
	  LD	HL,lC508		; table display to ascii (printer)
	  LD	C,A
	  LD	B,00h			; bc is displacement into table
	  ADD	HL,BC			; address to char
	  LD	A,(HL)			; get translation char
	  CP	0F0h			; display code for space?
	  JR	NZ,lC7B5		; no, continue
	  AND	20h			; yes, translate to 20h
lC7B5:	  POP	DE			; restore callers regs
	  POP	HL
	  POP	BC
	  RET     			; goback to caller

;	compute contents of HL to decimal and print up to 5 
;	chars without preceding nulls 

HLtoASC:  push	de			; save callers reg
	  ld	bc,ascwork		; workarea for me
	  ld	de,10000		; 10 exp 4
	  call	hltoa30			; 5th power of 10
	  ld	de,1000			; 10 exp 3
	  call	hltoa30			; 4th power of 10
	  ld	de,100			; 10 exp 2
	  call	hltoa30			; 3rd power of 10
	  ld	de,10			; 10 exp 1
	  call	hltoa30			; 2nd power of 10
	  ld	a,l			; 
	  or	'0'			; comp to decimal 
	  ld	(bc),a			; 10 exp 0
	  ld	de,ascwork
	  ld	b,04h			; max. 4 preceding nulls to skip of 5
hltoa10:  ld	a,(de)			; get printable dec. number
	  cp	'0'			; check for dec. 0
	  jr	nz,hltoa20		; no, go to print remaining numbers
	  inc	de
	  djnz	hltoa10			; yes, skip preceding 0
hltoa20:  inc	b			; adjust b 
hltoa25:  ld	a,(de)			; get number (0-9)
	  call	prnt			; print/plot number
	  inc	de
	  djnz	hltoa25			; do next number
	  pop	de			; end, restore callers reg
	  ret				; goback to caller

hltoa30:  ld	a,0ffh			; init counter to ffh+1=00
hltoa35:  inc	a			; count up
	  or	a			; clear carry
	  sbc	hl,de			; subtract until negative value
	  jr	nc,hltoa35		; value is positive
	  add	hl,de			; make positive
	  or	'0'			; make ascii
	  ld	(bc),a			; store to workarea
	  inc	bc			; next free address in workarea
	  ret				; goback to caller

;	wait on any key

WaitKey:  push	bc			; save callers reg
waitK010: call	SWEP			; keyboard swep
	  ld	a,b			; any key?
	  and	0bfh			; turn off d6=shift, brk only
	  jr	z,waitk010		; no, wait
	  ld	a,b
	  pop	bc			; yes, ok, restore callers reg
	  cp	88h			; test brk key+shift
	  ret				; done


; ErrorChk:	analyse errors and print dependent error message
;
; program logic:
;	save af (contents of accu and carry flag)
;	call errchk40  (prints err.msg load-/save-/verify-error first if any)
;	restore af (contents of accu and carry on entry)
;	if carry
;	   if a=0  (accu on entry)
;	      print "Break"
;	   endif
;	endif
;
;
ErrorChk: push	af			; save carry flag
	  call	Errchk40		; if carry output msg on error
errchk20: pop	af			; get back contents of accu and carry
	  ret	nc			; goback, done (no break)
	  and	a
	  ret	nz			; goback, if brk (accu=1bh)
	  ld	de,break		; address to msg
errchk30: call	msg			; print msg
	  call  letnl
	  scf				; set carry (brk info)
	  ret				; goback

; ErrChk40:		print load/save/verify error msg
; program logic:
;	if no carry
;	   turn off eof bit6 of st (set at time of eof, not at time of brk)
;	   if accu=0
;	      return
;	   endif
;	endif
;	if lvflag=01h
;	   print "Verifying error"
;	else if lvflag=02h
;	        print "Save error"
;	     else print "Load error" (lvflag=00h)
;	     endif
;	endif
;
;
errchk40: jr	c,errchk50		; no eof
	  ld	a,(ST)
	  and	0bfh			; turn off eof bit
	  ret	z			; if eof bit only goback 
errchk50: ld	a,(LVFlag)		; get flag
	  cp	01h			; verify error?
	  jr	nz,errchk60		; no	
	  ld	de,veriferr		; yes, address to verify error msg
errchk55: call	errchk30		; print error msg
	  ret				; goback to caller

errchk60: cp	02h			; save error?
	  jr	nz,errchk70		; no
	  ld	de,saveerr		; address to save error msg
	  jr	errchk55		; go to print

errchk70: ld	de,loaderr		; address to load error msg
	  jr	errchk55		; go to print


;	send Talk/Listen to floppy

ed09:
Talk:
sentTalk: or	40h			; set talker bit
	  jr	ed11

Listen:	  or	20h			; set listener bit
ed11:	  push	af			; save for further process
	  ld	a,(iecflag)		;
	  bit	7,a			; outputting end? (counter=0?)
	  jr	z,ed20			; yes
	  scf	
	  ld	a,(sta)
	  rra
	  ld	(sta),a
	  call	ed40			; put byte on iec bus
	  ld	a,(iecflag)
	  srl	a			; turns off bit 7
	  ld	(iecflag),a
	  ld	a,(sta)
	  srl	a			; turns off bit 7
	  ld	(sta),a
ed20:	  pop	af			; byte to put on iec bus
	  ld	(iecbuf),a		; put command to iec buffer
	  call	ee97			; set data high
	  ld	a,(le008)		; port LS367
	  bit	3,a			; data low?
	  call	z,ee85			; yes, set clk high
	  ld	a,(le000)		; 8255-port A
	  or	10h
	  ld	(le000),a		; set atn low (8255-port A)
ed36:	  call	ee8e			; set clk low (atn=clk=lo=listen)
	  call	ee97			; set data high
	  call	eeb3			; wait 1ms
ed40:	  call	ee97			; set data high
	  call	eea9			; get state of data line
	  jp	c,edad			; error, data is high (no dev. pres.)
	  call	ee85			; data line low, set clk high
	  ld	a,(sta)
	  bit	7,a			; floppy status
	  jr	z,ed5a
ed50:	  call	eea9			; get state of data
	  jr	nc,ed50			; wait for data high
ed55:	  call	eea9			; get state of data line
	  jr	c,ed55			; wait for data low
ed5a:	  call 	eea9			; get state of data
	  jr	nc,ed5a			; wait for data high
	  call	ee8e			; set clk low
	  ld	a,08h
	  ld	(bitcnt),a		; 8 bits
ed66:	  ld	a,(le008)		; port LS367
	  ld	b,a
	  ld	a,(le008)		; port LS367
	  cp	b
	  jr	nz,ed66			; wait for stable state of iec bus
	  bit	3,a
	  jr	z,edb0			; if data low, error (timeout)
	  ld	a,(iecbuf)
	  rra
	  ld	(iecbuf),a
	  jr	c,dath			; buffer bit is on
	  call	eea0			; buffer bit is off, set data low
	  jr	clkh

dath:	  call	ee97			; set data high
clkh:	  call	ee85			; set clk hi (data bit ready)
	  call	ee8e			; set clk low
	  call	ee97			; set data high
	  nop				; wait 4 nop's
	  nop
	  nop
	  nop
	  ld	hl,bitcnt
	  dec	(hl)			; bit count - 1
	  jr	nz,ed66			; if not 8 bits sent process again
	  ld	d,0fbh			; timer
ed9f:	  call	eea9			; get state of data line
	  bit	3,a
	  ret	z			; if data low, goback
	  dec	d			; timer - 1
	  jr	nz,ed9f
	  jr    edb0			; error, time out, no ack

;	set state to 80h/03h

edad:	  ld	a,80h			; status device not present
	  db	21h			; dummy instruction ld hl,3e03h
edb0:	  ld	a,03h			; status time out
edb2:	  call	fe1c			; set status
	  and	a			; set/reset flags
	  jr	ee03			; jump in unlisten

;	  send sec.address just behind sent of listen

edb9:	  ld	(iecbuf),a		; store sec.address
	  call	ed36			; put it on iec bus
edbe:	  ld	a,(le000)		; 8255-port A
	  and	0efh
	  ld	(le000),a		; set atn high
	  ret				; goback

;	send sec.address just behind sent of talk

edc7:	  
sentsadr: ld	(iecbuf),a		; store sec.address	
	  call	ed36			; put it on iec bus 
	  call	eea0			; set data low
	  call	edbe			; set atn high
	  call	ee85			; set clk high
edd6:	  call	eea9			; get state of clk
	  bit	1,a			; test state of clk
	  jr	z,edd6			; wait on clk high
	  ret				; goback

;	IECOUT put 1 char on iec bus

eddd:	  push	af			; save char to put on iec bus
	  ld	a,(iecflag)		; 
	  bit	7,a
	  jr	nz,ede6
	  scf
;	  ld	a,(iecflag)
	  rra
	  ld	(iecflag),a
	  bit	7,a
	  jr	nz,edeb
ede6:	  pop	af			; get callers reg
	  push	af			; save
	  call	ed40			; put byte out
edeb:	  pop	af			; restore char to output to bus
	  ld	(iecbuf),a		; store in iec buffer
	  and	a			; reset carry
	  ret				; goback

;	send untalk	

edef:	  call	ee8e			; set clk low
	  ld	a,(le000)		; 8255-port A
	  or	10h
	  ld	(le000),a		; set atn low
	  ld	a,5fh			; command untalk
	  db	21h			; dummy instr. ld hl,3e3fh
unlisten: ld	a,3fh			; command unlisten
	  call	ed11			; put it on iec bus
ee03:	  call	edbe			; set atn high
ee06:	  ld	b,0ah
ee09:	  dec	b
	  jr	nz,ee09			; wait 40µs
	  call	ee85			; set clk high
	  jp	ee97			; set data high

;	IECIN get 1 char from iec bus

ee13:	  
iecin:	  xor	a
	  ld	(bitcnt),a		; init bit counter
	  call	ee85			; set clk high
ee1b:	  call	eea9			; get state of clk
	  bit	1,a
	  jr	z,ee1b			; wait on clk high
ee20:  	  call	ee97			; set data high
	  ld	d,0ffh			; init timer
ee37:	  call	EEA9			; get clk bit from carry flag
	  bit	1,a			; test clk bit
	  jr	z,ee56			; wait on clk lo (then valid databit)
	  dec	d			; timer - 1
	  jr	nz,ee37			; loop
	  ld	a,(bitcnt)		; get bit counter
	  and	a			; test for zero
	  jr	z,ee47			; no bits received, force eof (?)
	  ld	a,02h			; timeout
	  jp	edb2			; set status

ee47:	  call	eea0			; set data low
	  call	ee85			; set clk hi
	  ld	a,40h			; set state to eof
	  call	fe1c			; do it
	  ld	hl,bitcnt		; when shall this condition occur???
	  inc	(hl)			; increment bit counter
	  jr	nz,ee20			; wait until bit counter equals zero
;  test for programmed loop or bug (no inc to bitcnt in this address range)
ee56:	  ld	a,08h
	  ld	(bitcnt),a		; set bit count
ee5a:	  call	eea9			; get state of clk
	  bit	1,a
	  jr	z,ee5a			; wait on clk high
	  and	08h			; 1st valid bit arrives, isolate data
	  jr	z,ee65			; data bit is zero, carry=0
	  scf				; data bit is one, carry=1

;   test, no usage?
ee65:	  ld	a,(zwispei)		; 
	  rra
	  ld	(zwispei),a
ee67:	  call	eea9			; get state of clk
	  bit	1,a
	  jr	nz,ee67			; wait on clk low
	  ld	hl,bitcnt
	  dec	(hl)			; bit count - 1
	  jr	nz,ee5a			; loop until 8 bits received
	  call	eea0			; byte complete, set data low
	  ld	a,(st)
	  bit	6,a			; eof?
	  jr	z,ee80			; yes, dont wait and...
	  call	ee06			; wait 40µs then set clk and data hi
ee80:	  ld	a,(zwispei)		; ????
	  and	a			; reset carry
	  ret				; goback

;	set clk line high

ee85:
clkhi:	  ld	a,(le000)		; 8255-port A
	  and	0dfh			; turn off bit 5 (clk high)
	  ld	(le000),a
	  ret				; goback

;	set clk line low

ee8e:
clklo:	  ld	a,(le000)		; 8255-port A
	  or	20h			; set bit 5 (clk low)
	  ld	(le000),a
	  ret				; goback

;	set data high

ee97:
datahi:	  ld	a,(le000)		; 8255-port A
	  and	0bfh			; turn off bit 6 (data high)
	  ld	(le000),a
	  ret				; goback

;	set data low

eea0:
datalo:	  ld	a,(le000)		; 8255-port A
	  or	40h			; set bit 6 (data low)
	  ld	(le000),a
	  ret				; goback

;	get state of all input lines and move bit of data to carry flag

eea9:	  
getbit:	  ld	a,(le008)		; Port LS367
	  ld	b,a
	  ld	a,(le008)
	  cp	b
	  jr	nz,eea9			; wait for stable iec bus
	  bit	3,a			; test bit 3
	  ret	z			; bit3=0, carry=0
	  scf				; bit3=1, carry=1
	  ret				; goback

;	wait for 1ms

eeb3:
wait1ms:  ld	b,0ffh			; init loop counter
eeb6:	  dec	b			; b=b-1
	  jp	nz,eeb6			; loop until b=0
	  ret				; goback


;	IECOPEN

f3d5:
IECOPEN:  ld	a,(secadr)
	  bit	7,a			; secondary address?
	  jr	z,f3d9			; yes, continue open
	  and	a			; no, primary address
	  ret				; goback

f3d9:	  ld	a,(filelen)		; test length of file name
	  and	A
	  RET	Z			; if no filename goback
	  XOR	A
	  LD	(ST),a			; clear state
	  ld	a,(gernr)		; get unit address (mormally 8)
	  call	listen			; send listen to this unit
	  ld	a,(secadr)
	  or	0f0h			; set open bits on
	  call	edb9			; send open cmd with sec. address
	  ld	a,(ST)			; 
	  bit	7,a			; device ok?
	  jr	z,f3f6			; yes
	  jp	f707			; no, error

f3f6:	  ld	a,(filelen)		; test length of file name
	  and	a
	  jp	z,f654			; jump to unlisten
	  ld	c,00h			; init loop count
	  ld	hl,filename+11		; set hl to 1st char of file name
iecope30: ld	a,c
	  ld	(asave),a		; save loop count
	  ld	(hlsave),hl		; save current addr. of file name
	  ld	a,(hl)			; get current char of file name
	  call	eddd			; IECOUT 1 char put on iec bus
	  ld	a,(asave)
	  ld	c,a			; restore c with loop count
	  ld	hl,(hlsave)		; restore current address
	  inc	hl			; next address of char to send
	  inc	c			; inc loop count
	  ld	a,(filelen)
	  cp	c			; test loop count = length?
	  jr	nz,iecope30		; no, continue
	  jp	f654			; yes, send unlisten

;	IECLOAD load/verify a file (secondary address 0)

f4b8:	
IECLOAD:  ld	a,(filelen)
	  and	a
	  jp	z,f710			; error, no file name given
	  ld	a,(secadr)
	  ld	(svsecadr),a		; save sec. addr. for futher use
	  call  f5af			; put msg "searching for..."
	  ld	a,60h			; sec. addr. 0 listen and talk
	  ld	(secadr),a
	  call	iecopen			; open file
	  ld	a,(gernr)
	  call	talk			; force talking of (gernr)
	  ld	a,(secadr)
	  call	edc7			; submit sec. addr.
	  call	ee13			; get low byte (IECIN) of load addr. 
	  ld	(endptr),a		; save
	  ld	a,(st)			; state of floppy drive
	  srl	a			; turn off bit 7 and bit 6 too
	  srl	a			; 
	  jr	c,f530			; if bit 6 was on jump
	  call	ee13			; get high byte of load address
	  ld	(endptr+1),a		; save, address is complete
mdfcmd02: ld	a,(svsecadr)		; get back sec. addr.
	  and	a
	  jr	nz,f4f0			; if zero take user's load address
	  ld	a,(adrload)		; see load routine for futher info
	  ld	(endptr),a		; not used if called by verify
	  ld	a,(adrload+1)
	  ld	(endptr+1),a
f4f0:	  call	f5d2			; msg loading/verifying
f4f3:	  ld	a,(st)
	  and	0fdh			; clear timeout
	  LD	(st),a
	  call	ee13			; get byte from IEC bus
	  ld	c,a			; save byte
	  ld	a,(st)
	  srl	a
	  srl	a
	  jr	c,f4f3
	  ld	a,(lvflag)		; test for load or verify
	  and	a
	  ld	hl,(endptr)		; ptr to current address in storage
	  ld	a,c			; restore byte read
	  jr	z,f51c			; jump if load active
	  ld	a,(hl)			; verify active, get byte of storage
	  cp	c			; verify byte read and storage
	  jr	z,f51e			; junp if okay
	  ld	a,10h			; not ok
	  call	fe1c			; set state to verify error
	  jr	f51e			; continue

f51c:	  ld	(hl),a			; load byte read to starage
f51e:	  inc	hl
	  ld	(endptr),hl		; ptr to next
	  ld	a,(st)
	  bit	6,a			; eof?
	  jr	z,f4f3			; no
f528:	  call	edef			; yes, send untalk
	  call	iecclose		; close
f530:	  jp	c,f704			; error, (file not found?)
	  and	a			; set/reset flags
	  ld	de,(endptr)
	  ret				; goback

;	put msg "searching for..." on screen

f5af:	  ld	de,searchfo		; address this msg
	  call	msg			; output this msg
f5c1:	  ld	a,(filelen)		; get length of filename
	  and	a
	  ret	z			; no filename
	  ld	b,a			; b is counter
	  ld	hl,filename+11		; address of filename
f5c7:	  ld	a,(hl)			; get filename char
	  call	prnt			; output char to screen
	  inc	hl			; point to next
	  dec	b			; length - 1
	  jr	nz,f5c7			; continue if not all
	  call	letnl			; set cursor on next line on screen
	  ret				; goback

;	put msg "Loading..." on screen

f5d2:	  ld	de,loading		; address to msg
	  ld	a,(lvflag)		; get Load/verify flag
	  and	a
	  jr	z,f5da			; 00 means load active
	  ld	de,veryfing		; 01 means verify,address to this msg
f5da:	  call	msg			; put msg on screen
	  call	f5c1			; put filename on screen
	  ret				; goback

;	IECSTORE puts header & file on IEC bus (secondary address 1)

f5fa:
IECSTORE: ld	a,(filelen)		; get length of filename
	  and	a
	  jp	z,f710			; missing filename if zero
	  ld	a,61h			; sec. addr 1 listener and talker
	  ld	(secadr),a
	  call	iecopen			; open new file
	  call	f68f			; msg "Saving.."
	  ld	a,(gernr)
	  call	listen			; force listen for (gernr)
	  ld	a,(secadr)
	  call	edb9			; send sec. addr.
	  ld	de,(iostrt)
	  ld	(biostrt),de		; save 
	  ld	a,(biostrt)		; low byte of begin
	  call	eddd			; put it on bus
	  ld	a,(biostrt+1)		; high byte of begin
	  call	eddd			; put it on bus
f624:	  and	a
	  ld	hl,(endptr)		; ptr to end
	  ld	de,(biostrt)		; current address of storage
	  sbc	hl,de
	  jr	c,f63f			; stop if negative
	  ld	a,(de)			; get next byte
	  call	eddd			; output to iec bus
f63a:	  ld	hl,biostrt		; save max. to ffffh
	  inc	(hl)
	  jr	nz,f624			; continue if low byte not zero
	  inc 	hl
	  inc	(hl)
	  jr	nz,f624			; continue if high byte not zero
f63f:	  call	unlisten		; send unlisten
f642:
iecclose: ld	a,(secadr)
	  bit	7,a			; test on secondary address
	  jr	nz,f657			; no, primary address, done
	  ld	a,(gernr)
	  call	listen			; force listen for (gernr)
	  ld	a,(secadr)
	  and	0efh
	  or	0e0h
	  call	edb9			; close sec. addr. 1
f654:	  call	unlisten		; send unlisten
f657:	  and	a			; set/reset flags
	  ret				; goback

;	put msg "Saving..." on screen

f68f:	  ld	de,saving		; address to msg
	  call	msg			; output msg
	  jp	f5c1			; add filename to msg

;	put msg "File not found" on screen

f704:	  ld	de,filenfnd		; address to msg
	  call	errchk30		; output msg
	  call  ErrorChk
	  ld	sp,(stckptr)		; force stop on error
	  jp	GetErSta

;	put msg "device not present" on screen

f707:	  ld	de,devnpres		; address to msg
	  call	errchk30		; output msg
	  call  ErrorChk
	  ld	sp,(stckptr)		; force stop on error
	  jp	start

;	put msg "Missing filename" on screen

f710:	  ld	de,namemiss		; address to msg
	  call	errchk30		; output msg
	  call  ErrorChk
	  ld	sp,(stckptr)		; force stop on error
	  jp	start			; 

;	set state

fe1c:	  ld	b,a
	  ld	a,(st)
	  or	b
	  ld	(st),a
	  ret

;	end of program, goback to monitor
intbrk:	  call	letnl
	  ld	de,break
	  call	msg
	  call	letnl
intrpt:	  ld	sp,10f0h		; init stackpointer
	  jp	st1			; goback to Monitor-ROM


; input areas
filename: db	80 dup (" ")		; max. 16 Zeichen, Buffer max. 80
BUFL:	  db	80 dup (" ")		; Input-Buffer max. 80 Zeichen

;	Init string for plotter (sets line counter to 999)

initstri: db	09h,09h,39h,39h,39h,0dh

;	plotter translation table

lC402:	  db    19 dup 00h
	  db	0c3h,0c4h
	  db    12 dup 00h
	  db	61h,62h,63h,64h,65h,66h,67h,68h,69h
	  db	6bh,6ah,2fh,2ah,2eh,2dh
	  db	20h,21h,22h,23h,24h,25h,26h,27h,28h,29h
	  db	4fh,2ch,51h,2bh,57h,49h,55h
	  db	01h,02h,03h,04h,05h,06h,07h,08h,09h
	  db	0ah,0bh,0ch,0dh,0eh,0fh
	  db	10h,11h,12h,13h,14h,15h,16h,17h,18h,19h
	  db	1ah,52h,59h,54h,50h,45h
	  db	27 dup 00h
	  db	0dbh
	  db	4 dup 00h
	  db	40h
	  db	10 dup 00h
	  db	0beh
	  db	6 dup 00h
	  db	85h,0a4h,0a5h,00h,94h,87h,88h,00h,82h,98h,84h,92h
	  db	90h,83h,91h,81h,9ah,97h,93h,95h,89h,00h,0afh,8bh
	  db	86h,96h,00h,0abh,0aah,8ah,8eh,00h,0adh,8dh
	  db	3 dup 00h
	  db	8fh,8ch,0aeh,0ach,9bh,00h,99h,0bch
	  db	7 dup 00h
	  db	5ah
	  db	8 dup 00h
	  db	3eh,7 dup 00h,36h,35 dup 00h,1bh,58h
	  db	00h,00h,60h

;	printer translation table 

lc508:	  db	" ABCDEFGHIJKLMNOPQRSTUVWXYZd"
	  db	4 dup 0f0h
	  db	"0123456789-=;/.,"
	  db	16 dup 0f0h
	  db	7dh,06h,0f0h,0f0h,04h,0f0h,05h,0f0h,0f0h,"?"
	  db	5 dup 00h,":",0f0h,"<[",03h,"]@",0f0h,">",0f0h
	  db	5ch,6 dup 0f0h,0e3h,"!",22h,"#$%&'()+*"
	  db	20 dup 0f0h,0b3h
	  db	61h,62h,63h,64h,65h,66h,67h,68h,69h
	  db	6ah,6bh,6ch,6dh,6eh,6fh,70h,71h,72h,73h
	  db	74h,75h,76h,77h,78h,79h,7ah,84h
	  db	8 dup 0f0h,60h,0f7h,4 dup 0f0h,0e1h,81h
	  db	94h,9ah,8eh,99h,12 dup 0f0h,7bh,0f0h,5eh
	  db	5fh,64 dup 0f0h

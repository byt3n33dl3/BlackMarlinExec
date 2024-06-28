; GSX.ASM
; -------
;
; CP/M-80 - GSX-80 Version 1.1
;
; Disassembled by:
;
; ROCHE Emmanuel
; 8 rue HERLUISON
; 10000 TROYES
; FRANCE
; ------
;
;--------------------------------
;
	PAGE	0		; Listing without page breaks
;
;	ORG	0000H		; CP/M-80 SYStem file
;
	ORG	0100H		; Debug only
;
;--------------------------------
; List of ASCII characters used
;
DEFC lf  =  0AH ; Line Feed
DEFC cr  =  0DH ; Carriage Return
;
;--------------------------------
; List of BDOS functions used
;
DEFC conout  =  2 ; Console output
DEFC pstring  =  9 ; Print string
DEFC openf  =  15 ; Open file
DEFC closef  =  16 ; Close file
DEFC readf  =  20 ; Read sequential
DEFC setDMA  =  26 ; Set DMA address
;
;--------------------------------
;
;DEFC DBUF  =  0080H ; ----I
;
;--------------------------------
;
	JP	start1		; Start of code
;
;--------------------------------
; Indirect call to BDOS
;
BDOS:	DEFM	0C3H		; JMP opcode
;
L0104	DEFW	0000H		; Storage for ???

;
;--------------------------------
;
wks_id:	DEFW	0FFFFH	; Current workstation ID

;
;
DDtabl:	DEFS	55		; 55 bytes = 5 times 11 bytes
;
; Table of DD filenames
;
; Format:
; 1 byte  for the drive code
; 2 bytes for ???
; 8 bytes for the DD filename   (total = 11 bytes per driver)
;
;
	DEFM	0FFH		; ? Separator?
	DEFM	0FFH		; ?
;
;--------------------------------
;

f_record:
	DEFM	"---------------------------------------------------", cr, lf
	DEFM	"                                                   ", cr, lf
	DEFM	"            LOADING the GSX-80 drivers             ", cr, lf
	DEFM	"                                                   ", cr, lf
dd_file:
	DEFM	"---------------------------------------------------", cr, lf, '$'
;
; Note:
; The first three lines of the copyright message
; are utilized by the GDOS as a file buffer.
;
; The last line of the copyright message
; is used to store the FCB of the DD used.
;




;
;--------------------------------
;
byt_ct:	DEFS	34		; ???


;
;--------------------------------
;
start1:	LD 	A,C			; Reg-A = BDOS function number
	CP	73H				; = 115 ? (GSX function number)
	JP	NZ,BDOS			; No: jump back to BDOS
	LD	HL,__ctl		; 
	LD 	C,10
	CALL	copyDH		; (DE)->(HL), C times
	LD		HL,(__ctl)	; pointer to the "control" array
	LD 		A,(HL)		; 
	INC		HL			; 
	LD 		H,(HL)		; 
	LD 		L,A			; 
	DEC		HL			; ..is the first word we found in the "control" array (thus the command)..
	LD 		A,H			; .. 'Open Workstation' (1) ...
	OR		L			; ... to initialize a driver ?
	JP		Z,init_driver

	CALL	set_entry_parms		; 
	CALL	Enter_Driver		; 
exit_driver:
	JP		get_exit_parms		; 

;
;--------------------------------
;
init_driver:
	LD	HL,(intin)		; 'intin' queue
	LD 	E,(HL)			;  Get the workstation ID (first value)
	INC	HL				; 
	LD 	D,(HL)			; 
	LD	HL,(wks_id)		; 
	CALL	sub16		; Already loaded ?
	JP	Z,DDready		; 
	LD	HL,DDtabl		; 
DDlookup:
	PUSH	HL			; 
	LD 	A,(HL)			; 
	INC	HL				; 
	LD 	H,(HL)			; 
	LD 	L,A				; HL=next entry in the DDtabl
	AND	H				; 
	INC	A				; Last entry in the device list ?
	POP	BC				; 
	JP	Z,DDready		; 
	PUSH	BC			; 
	CALL	sub16		; 
	POP	HL				; 
	JP	Z,DDload		; We need to load the PRL file driver from file
	LD	BC,11
	ADD	HL,BC			; Move to the next entry in DDtabl
	JP	DDlookup		; 

;
;--------------------------------
;
DDload:
	INC	HL				; 
	INC	HL				; 
	EX	DE,HL			; DE = DD file name,   HL = workstation ID
	LD	(wks_id),HL		; Keep the 'Workstation ID'
	LD	HL,dd_file		; File spec in copyr msg
	LD 	C,9 			; 9 bytes (drive code + DD filename)
	CALL	copyDH		; Copy one file specification
	CALL	DDload_prl	; 

DDready:
	CALL	Enter_Driver
	LD	HL,(intout)		; intout
	LD 	A,(HL)			; 
	INC	HL				; 
	PUSH	HL			; 
	LD 	H,(HL)			; 
	LD 	L,A				; 
	INC	HL				; 
	LD	(_maxx),HL		; 1st value in the "intout" queue (maxx ?)
	POP	HL				; 
	INC	HL				; 
	LD 	A,(HL)			; 
	INC	HL				; 
	LD 	H,(HL)			; 
	LD 	L,A				; 
	INC	HL				; 
	LD	(_maxy),HL		; 1st value in the "intout" queue (maxy ?)
	JP	exit_driver		; 

;
;--------------------------------
;
set_entry_parms:
	LD	HL,(__ctl)		; pointer to the "control" array
	INC	HL				; 
	INC	HL				; 

	LD 	E,(HL)			; n_ptsin
	INC	HL				; 
	LD 	D,(HL)			; 

	LD 	A,E				; 
	OR	D				; 
	RET	Z				; exit if no parms

	LD	HL,-75
	ADD	HL,DE			; 
	JP	NC,entry_parms	; More than 75 coordinate pairs?
	LD 	E,75			; if so, limit to 75 entries (150 bytes)
entry_parms:

	LD	HL,(ptsin)		; ptsin
	PUSH	HL			; 
	LD	HL,f_record		; target temp position for ptsin with rescaled values
	LD	(ptsin),HL		; 
	PUSH	HL			; 
	POP	BC				; new adjusted ptsin list with rescaled values
	POP	HL				; 
entry_ptsloop:
	PUSH	DE			; 
	EX	DE,HL			; 
	LD	HL,(_maxx)		; 
	CALL	downscale
	EX	DE,HL			; 
	LD	HL,(_maxy)		; 
	CALL	downscale
	POP	DE				; 
	DEC	E				; repeat for E arguments
	JP	NZ,entry_ptsloop
	RET					; 

;
; Rescale from VDI window to real coordinates
; (HL) -> (BC)
;---------------------------------------------
;
downscale:
	EX	DE,HL		; 
	LD 	A,(HL)		; 
	INC	HL			; 
	PUSH	HL		; 
	LD 	H,(HL)		; 
	PUSH	BC		; 
	LD 	L,A			; 
	
	LD 	C,15
	PUSH	DE		; 
	EX	DE,HL		; 
	LD	HL,0		; 
downscale_1:
	LD 	A,D			; 
	RRA				; 
	LD 	D,A			; 
	LD 	A,E			; 
	RRA				; 
	LD 	E,A			; 
	JP	NC,downscale_2
	LD 	A,C			; 
	POP	BC			; 
	PUSH	BC		; 
	ADD	HL,BC		; 
	LD 	C,A			; 
downscale_2:
	LD 	A,H			; 
	RRA				; 
	LD 	H,A			; 
	LD 	A,L			; 
	RRA				; 
	LD 	L,A			; 
	DEC	C			; 
	JP	NZ,downscale_1	
	POP	BC			; 
	
	POP	BC			; value position
	LD 	A,L			; store value
	LD	(BC),A		; 
	INC	BC			; 
	LD 	A,H			; 
	LD	(BC),A		; 
	INC	BC			; 
	POP	HL			; 
	INC	HL			; 
	RET				; 

;
;--------------------------------
;
get_exit_parms:
	LD	HL,(__ctl)		; pointer to the "control" array 
	LD	DE,4			; 
	ADD	HL,DE			; n_ptsout
	LD 	C,(HL)			; 
	INC	HL				; 
	LD 	B,(HL)			; 
	LD	HL,(ptsout)		; ptsout
exit_ptsloop:
	LD 	A,C				; 
	OR	B				; 
	RET	Z				; repeat for BC arguments, (exit if no arguments)
	PUSH	BC			; 
	EX	DE,HL			; 
	LD	HL,(_maxx)
	CALL	upscale
	EX	DE,HL			; 
	LD	HL,(_maxy)
	CALL	upscale
	POP	BC				; 
	DEC	BC				; 
	JP	exit_ptsloop	; 
	
;
; Convert from real coordinates to VDI (32768x32768)
;----------------------------------------------------
;
upscale:
	LD 	B,H			; 
	LD 	C,L			; 
	EX	DE,HL		; 
	LD 	E,(HL)		; 
	PUSH	HL		; ptsout ptr
	INC	HL			; 
	LD 	D,(HL)		; 
	EX	DE,HL		; 
	
	LD 	A,16 
	LD	DE,0
upscale_1:
	PUSH	AF		; 
	EX	DE,HL		; 
	ADD	HL,HL		; DE=DE*2
	EX	DE,HL		; 
	ADD	HL,HL		; HL=HL*2
	LD 	A,L			; 
	SUB	C			; 
	LD 	L,A			; 
	LD 	A,H			; 
	SBC	B			; 
	LD 	H,A			; 
	JP	NC,upscale_2
	ADD	HL,BC		; 
	DEC	DE			; 
upscale_2:
	INC	DE			; 
	POP	AF			; 
	DEC	A			; 
	JP	NZ,upscale_1

	AND	A			; DE=DE/2
	LD 	A,D			; 
	RRA				; 
	LD 	D,A			; 
	LD 	A,E			; 
	RRA				; 
	LD 	E,A			; 
	JP	NC,upscale_3
	INC	DE
upscale_3:

	POP	HL			; ptsout ptr
	LD 	(HL),E		; 
	INC	HL			; 
	LD 	(HL),D		; 
	INC	HL			; 
	RET				; 

;
;--------------------------------
; copy a string from DE (source) to HL (destination)
;
; DE = source
; HL = destination
;  C = number of bytes
;
;
copyDH:
	LD	A,(DE)		; 
	LD 	(HL),A		;
	INC	HL			; 
	INC	DE			; 
	DEC	C			; 
	JP	NZ,copyDH	; 
	RET				; 

;
;--------------------------------
; 16 bits subtraction
;
sub16:
	LD 	A,L			; 
	SUB	E			; 
	LD 	L,A			; 
	LD 	A,H			; 
	SBC	D			; 
	LD 	H,A			; 
	OR	L			; 
	RET				; 


;
;--------------------------------
;
__ctl:	DEFW	0		; control array (contains the FN code, the lengthts of intin, ptsin, intout, ptsout, and a trailing special argument)
intin:	DEFW	0		; intin
ptsin:	DEFW	0		; ptsin
intout:	DEFW	0		; intout
ptsout:	DEFW	0		; ptsout

_maxx:	DEFW	0
_maxy:	DEFW	0


;
;--------------------------------
;

DDload_prl:
	CALL	get_prl				; 
	CALL	next_record			; Read first 128 bytes file record
	LD		HL,(L0104)			; 
	LD		DE,Driver_pgm		; GSX.SYS + 500H at exact byte boundary
	CALL	sub16				; 
	EX		DE,HL				; 
	LD		HL,(f_record+1)		;  check binary block size from PRL header
	PUSH	HL					; 
	LD 		A,E					; 
	SUB		L					; 
	LD 		A,D					; 
	SBC		H					; 
	JP		NC,load_prl			; 
	LD		DE,toobig			; 'too big to loaL'
	JP		dsp_fname			; Display d:filename.typ

;
;--------------------------------
;
load_prl:
		CALL	next_record		; Read next 128 bytes file record
		POP		BC				; 
		PUSH	BC				; 
		LD		HL,Driver_pgm	; GSX.SYS + 500H at exact byte boundary
		PUSH	HL				; 
ld_loop:
		CALL	get_byte		; 
		LD 		(HL),A			; 
		INC		HL				; 
		DEC		BC				; 
		LD 		A,C				; 
		OR		B				; 
		JP		NZ,ld_loop		; 
		
		
		POP		HL				; 
		LD 		B,H				; 
		DEC		B				; 
		POP		DE				; 

reloc:
		LD 		C,8 			; group of 8 bytes to be relocated 
		CALL	get_byte		; pick the bitmap for the byte group
reloc8:
		RLCA					; test whether the current byte needs to be relocated
		PUSH	AF				; 
		JP		NC,no_reloc		; 
		LD 		A,B				; 
		ADD		A,(HL)			; 
		LD 		(HL),A			; 
no_reloc:
		INC		HL				; 
		DEC		DE				; 
		LD 		A,D				; 
		OR		E				; 
		JP		Z,close_file
		POP		AF				; 
		DEC		C				; 
		JP		NZ,reloc8		; 
		JP		reloc			; 

;
;--------------------------------
;
close_file:
	POP		AF
	JP		do_close		; 

;
;--------------------------------
;
get_byte:
	PUSH	HL				; 
	PUSH	DE				; 
	LD		HL,(byt_ct)		; 
	INC		L				; 128->256->0 ?
	JP		P,in_sect		; 
	PUSH	BC				; 
	CALL	next_record		; Read next 128 bytes file record
	POP		BC				; 
	LD		HL,0			; update byte counter
in_sect:
	LD		(byt_ct),HL		; 
	LD		DE,f_record		; file record
	ADD		HL,DE			; 
	LD 		A,(HL)			; 
	POP		DE				; 
	POP		HL				; 
	RET						; 
;
;--------------------------------
;
get_prl:
	LD		DE,PRLtyp		; PRL filetype
	LD		HL,dd_file		; 
	LD 		C,6 
	CALL	copyDH			; (DE)->(HL), C times
	LD		HL,128
	LD		(byt_ct),HL		; init byte counter
	LD		DE,dd_file		; File spec in copyr msg
	LD 		C,openf			; Open file
	CALL	BDOS			; 
	LD		HL,dd_file		; Last byte of the FCB of DD used
	LD 		(HL),00H		; 
file_done:
	OR		A			; 
	RET		P			; 
	LD		DE,nfound	; ' not founL'
	JP		dsp_fname	; Display d:filename.typ
;
;--------------------------------
;
do_close:
	LD	DE,dd_file	; File spec in copyr msg
	LD 	C,closef	; Close file
	CALL	BDOS		; 
	JP	file_done		; 
;
;--------------------------------
; Display a char on console
;
pchar:
	PUSH	HL		; 
	LD 	C,conout	; Console output
	CALL	BDOS		; 
	POP	HL		; 
	RET			; 
;
;--------------------------------
; Parse n+1 chars and display them
;
parse:
	DEC	A			; 
	RET	Z			; 
	LD 	E,(HL)		; 
	INC	HL			; 
	PUSH	AF		; 
	CALL	pchar	; 
	POP	AF			; 
	JP	parse		; 

;
;--------------------------------
; Read file record (it is kept in the copyright message)
;
next_record:
	LD	DE,f_record	; copyright message = DMA area...
	LD 	C,setDMA	; Set DMA Address
	CALL	BDOS	; 
	LD	DE,dd_file	; File spec in copyr msg
	LD 	C,readf		; Read sequential
	CALL	BDOS	; 
	OR	A			; Successful read ?
	RET	Z			; 
	LD	DE,whyEOF	; ':  unexpected EOF$'

dsp_fname:
	PUSH	DE		; 
	LD	HL,dd_file	; File spec in copyr msg
	LD 	A,(HL)		; 
	OR	A			; Was a drive specified ?
	JP	Z,nodriv	; 
	ADD	A,40H		; Convert drive code in a number
	LD 	E,A			; 
	CALL	pchar	; Display drive letter
	LD 	E,':'		; Drive separator
	CALL	pchar		; Display it
nodriv:
	INC	HL		; 
	LD 	A,8+1		; Filename
	CALL	parse		; 
	LD 	E,'.'		; Filename separator
	CALL	pchar		; 
	LD 	A,3+1		; Filetype
	CALL	parse		; 
	POP	DE		; 
	LD 	C,pstring	; Print string
	CALL	BDOS		; 
	JP	0000H		; Back to CP/M


;
;--------------------------------
;
toobig:	DEFM	" too big to loaL"
;
whyEOF:	DEFM	":  unexpected EOF$"
;
nfound:	DEFM	" not founL"
;
PRLtyp:	DEFM	"PRL"		; PRL filetype
;
	DEFS	8		; ?



;
;--------------------------------
;
Enter_Driver:	LD	DE,__ctl		; ?
;
; The next byte is the first byte of the loaded driver.
; (relocated portion of GSX.SYS + 500H at exact byte boundary)
;--------------------------------
;
Driver_pgm:

	END			; CP/M-80 SYStem file

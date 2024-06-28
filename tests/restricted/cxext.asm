; 06-2018: Converted to z80 mnemonics with toz80.awk
;
;
	title	'C128 external Disk drive support  28 Apr 86'

;
;	This program contains the stubs for bringing up the C128 CP/M
;	for the first time.
;
;	The method used to stub the system I/O is to send the
;	operation request to the serial port as a command and
;	recieve responce from the serial channel.
;
;	The commands supported are:
;
;	CMD:	'I'	; input keyboard char
;	RSP:	xx	; returns keybord char or 00 if none
;
;	CMD	'O'xx	; send char xx to display 
;	RSP:	xx	; echo character
;
;	CMD:	Rttss	; read sector of data  adr by track (tt) sector (ss) 
;	RSP:	xx..yy	; returns 128 bytes of data plus a check sum
;
;	CMD:	Wttssxx..yy	; write sector of data, sent with a check sum 
;				; to (xx..yy) adr by track (tt) sector (ss)
;	RSP:	xx		; xx=00 if no error
;
	page

	maclib	cpm3

	maclib	z80

	maclib	cxequ



	public	_int65,_in65,_ins65,_out65,_outs65
	extrn	_intbd

; Utility routines in standard BIOS
        extrn   _pmsg           ; print message @<HL> up to 00
                                ; saves <BC> & <DE>
        extrn   _pdec           ; print binary number in <A> from 0 to 99.
	extrn	_pderr		; print BIOS disk error header
	extrn	_conin,_cono	; con in and out
	extrn	_const		; get console status

;
;	drive table
;
	public	@dtbl
	extrn	cmdsk0,cmdsk1,cmdsk2,cmdsk3,cmdsk4,RMdsk

	page
;
;	DRVTBL.ASM		
;
	CSEG		; place code in common memory

@dtbl:
	DEFW	cmdsk0			;* drive A 1541/1571 
	DEFW	cmdsk1			;* drive B 1541/1571
	DEFW	cmdsk2			;* drive C 1541/1571
	DEFW	cmdsk3			;* drive D 1541/1571
	DEFW	cmdsk4			;* drive E shares drive A
	DEFW	0			;* drive F 
	DEFW	0			;* drive G
    if	EXTSYS
	DEFW 	0fdsd0			;* drive H (external RS232)
    else
	DEFW	0			;* drive H
    endif
	DEFW	0			;* drive I
	DEFW	0			;* drive J
	DEFW	0			;* drive K
	DEFW	0			;* drive L
	DEFW	RMdsk			;* drive M  Memory Disk (RAM disk)
	DEFW	0			;* drive N
	DEFW	0			;* drive O
	DEFW	0			;* drive P


    if	EXTSYS
	CSEG
;
; Extended Disk Parameter Headers (XPDHs)
;
	DEFW	fd_write
	DEFW	fd_read
	DEFW	fd_login
	DEFW	fd_init
	DEFM	0		; relative drive zero
	DEFM	0		; format type byte
@fdsd0:	
	dph	sk128sssd,dpb_8_sssd


;
; DPB FOR 8 IBM 3740 format		( 243K )
;
dpb_8_sssd:	dpb	128,26,77,1024,64,2

sk128sssd:
	skew	26,6,1




	page
;
;	send an illegial command, should get a period back, meaning
;	that the the command was bad. at this point extrnal system
;	is ready to receive a valid command.
;
	CSEG
resync:
	LD 	c,0dh
	call	send_c
	call	get
	CP	'.'
	JR	NZ,resync

	LD 	c,'O'
	call	send_c
	LD 	c,07			; beep the bell
	call	send_c
	call	get			; should be a bell code
	CP	07
	RET	Z

	call	get
	jr	resync



;
;	CXDISK.ASM
;

;
;
;
	dseg
fd_read:
	LD 	a,10
	LD	(error_count),A		; set retrys to 10
retry_read:
	LD	HL,retry_read
	PUSH	HL			; save retry address on the stack
	LD 	a,'R'
	call	set_up_dsk		; send command, track and sector
read_loop:
	call	get

   if	banked
	call	put_byte_de_bank	; save byte disk bank
	LD 	a,c
   else
	LD 	(HL),a
   endif

	INC	HL
	call	do_sum
	JR	NZ,read_loop

	call	get
	LD	A,(check_sum)
	CP	c
	JR	NZ,dsk_error

	POP	HL			; remove retry address
	XOR	a			; A=0 (no errors)
;
;
fd_init:
fd_login:
	ret


;
;
;
   if	banked

	cseg
put_byte_de_bank:
	LD	A,(force_map)		; read current MMU configuration
	LD	(DE),A			; force to preconfig reg adr in DE
	LD 	(HL),c			; save C in proper bank
	LD	(force_map),A		; force the old bank back
	ret
   endif

	page
;
;
;
	dseg
dsk_error:
	call	resync
	LD	A,(error_count)
	DEC	a
	LD	(error_count),A
	RET	NZ				; return to retry address

	INC	a			; A=1 if hard error
	POP	HL			; remove retry address on error
	ret

error_count:	DEFM	0

	page
;
;
;
	dseg
fd_write:
	LD 	a,10
	LD	(error_count),A		; set retrys to 10

retry_write:
	LD	HL,retry_write
	PUSH	HL
	LD 	a,'W'
	call	set_up_dsk		; send command, track and sector

write_loop:
   if	banked
	call	get_byte_de_bank
   else
	LD 	c,(HL)
   endif
	call	send_c			; leaves sent char in A
	INC	HL
	call	do_sum
	JR	NZ,write_loop
	LD	A,(check_sum)
	call	send_a
	call	get
	OR	a			; A=0 if no errors
	JR	NZ,dsk_error

	POP	HL			; remove error address
	ret				; A=0 (no errors)


   if	banked

	cseg
get_byte_de_bank:
	LD	A,(force_map)		; read current MMU configuration
	LD	(DE),A			; set current disk bank (in DE)
	LD 	c,(HL)
	LD	(force_map),A		; write current MMU conf back
	ret
   endif

	page
;
;	compute check sum and adjust byte count
;	
	dseg
do_sum:
	LD 	b,a
	LD	A,(check_sum)		; get the current sum
	ADD	A,b			; add in new byte
	LD	(check_sum),A		; save new sum
	LD	A,(count)			; get byte count
	DEC	a			; one less to get
	LD	(count),A			; save for later
	ret				; zero flag set if DONE

check_sum:	DEFM	0
count:		DEFM	0


;
;	send the command, track and sector to the external system
;	set count to 128 bytes, clear the checksum and set HL to
;	the DMA address
;
set_up_dsk:
	call	send_a		; send the comand
	LD	A,(@trk)
	call	send_a		; send the track
	LD	A,(@sect)
	call	send_a		; send the sector
	XOR	a
	LD	(check_sum),A
	LD 	a,80h
	LD	(count),A		; transfer 128 bytes
	LD	HL,(@dma)		; HL = current DMA address

   if	banked
	LD	DE,bank_0	; start by pointing to bank 0
	LD	A,(@dbnk)		; get the current disk I/O bank
	OR	a		; is it set to bank 0
	RET	Z			; yes, return

	INC	DE		; no, point to bank 1
   endif
	ret

	page
;==========================================================
;		CHARACTOR INITILIZATION ROUTINES
;==========================================================
;
;
;
	dseg

;
;	set external system com rate to 19.2 K baud
;
_int65:
init_ext:
	LD	HL,(usart_adr)
	LD 	b,h
	LD 	c,l
	INC	BC
	INC	BC			; point to command reg

	LD 	a,cmd_init
	outp	a
	INC	BC			; point to control reg
	LD 	a,cntr_init_19200	; baud rate equ 19200
	outp	a

	DEC	BC			; (02)
	DEC	BC			; (01)
	inp	a			; read status
	DEC	BC			; (00)
	inp	a			; read hung data
	ret

	page
;==========================================================
;		CHARACTOR INPUT ROUTINES
;==========================================================

;
;
;
	dseg
_in65:                  ; character input
	call	_ins65		; check for character adv.
	JR	Z,_in65		; loop if NOT
	LD	A,(key)		; get the key code
	PUSH	AF		; save on stack
	XOR	a		; clear key
	LD	(key),A
	POP	AF		; recover current key
	ret

	page

;==========================================================
;	CHARACTER DEVICE INPUT STATUS
;==========================================================

;
;
;
	dseg
_ins65:			; character input status
	LD	A,(key)		; is there already a key
	OR	a
	JR	NZ,ret_true	; yes, return true
	LD 	a,'I'		; no, test if any typed
	call	send_a
	call	get		; get key
	OR	a		; =0 if none
	RET	Z			; return character not advaliable

	LD	(key),A		; was one, save in key 
_outs65:
ret_true:
	OR	0ffh
	ret

key:	DEFM	0

	page
;==========================================================
;	CHARACTER DEVICE OUTPUT
;==========================================================

; the charactor to be output is in the C register

;
;
;
	dseg
_out65:				; character output
	LD 	a,c
	PUSH	AF
	LD 	a,'O'
	call	send_a
	POP	AF
	call	send_a
;	jmp	get

; fall thru to GET

;==========================================================
;		EXTERNAL DEVICE LOW LEVEL DRIVERS
;==========================================================

;
;
;
	dseg
get:
	call	in_stat
	JR	Z,get
	DEC	BC		; point to data reg (RxD)
	inp	a
	LD 	c,a
	ret
;
;
;
send_c:
	LD 	a,c
send_a:
	PUSH	AF		; save the character to be output
send_loop:
	call	out_stat
	JR	Z,send_loop
	POP	AF
	DEC	BC		: point to data register (TxD)
	outp	a
	ret
;
;
;
in_stat:
	LD	HL,(usart_adr)
	LD 	b,h
	LD 	c,l
	INC	BC		; point to status register
	inp	a
	AND	rxrdy
	ret
;
;
;
out_stat:
	LD	HL,(usart_adr)
	LD 	b,h
	LD 	c,l
	INC	BC		; point to status register
	inp	a
	AND	txrdy
	ret
    else
;==========================================================
;		CHARACTOR INITILIZATION ROUTINES
;==========================================================
;
;
;
	dseg
;
;	set com rate to value in _int_bd
;	(may need to change rate if not supported)
_int65:
init_ext:
   if	use_6551
;
;	must gate 6551 to user port
;	this is done by init'ing the out data to an input
;	and then setting DTR
;
 	LD	BC,CIA2+data_dir_a
	inp	a
	OR	100b			; make TxD bit (2) an input
	outp	a
  endif

	LD	HL,(usart_adr)
	LD 	b,h
	LD 	c,l
	INC	BC			; point to status reg
	outp	a			; software reset (wr to stat reg)

	INC	BC			; point to Command register
	LD 	a,cmd_init		; set DTR active
	outp	a

	INC	BC			; point to Control register
	LD	A,(_int_bd)			; get 6551 baud rate
	OR	10h			; use baud rate generator
	outp	a			; 1 stop (7=0), 8 bits (65=0)
	ret

	page
;==========================================================
;		CHARACTOR INPUT ROUTINES
;==========================================================

;
;
;
	dseg
_in65:                  ; character input
	call	_ins65
	JR	Z,_in65
	DEC	BC		; point to data reg
	inp	a
	ret

;==========================================================
;	CHARACTER DEVICE INPUT STATUS
;==========================================================
;
;
;
	dseg
_ins65:			; character input status
	LD	HL,(usart_adr)
	LD 	b,h
	LD 	c,l
	INC	BC		; point to status register
	inp	a
	AND	rxrdy
	RET	Z
	OR	-1
	ret


;==========================================================
;	CHARACTER DEVICE OUTPUT
;==========================================================

; the charactor to be output is in the C register

;
;
;
	dseg
_out65:				; character output
	LD 	a,c
	PUSH	AF
	call	_outs65
	JR	Z,_out65
	POP	AF
	DEC	BC		; point to data register
	outp	a
	ret

;==========================================================
;	CHARACTER DEVICE OUTPUT STATUS
;==========================================================
;
;
;
	dseg
_outs65:			; character input status
	LD	HL,(usart_adr)
	LD 	b,h
	LD 	c,l
	INC	BC		; point to status register
	inp	a
	AND	txrdy
	RET	Z
	OR	-1
	ret


    endif


	end

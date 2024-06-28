; 06-2018: Converted to z80 mnemonics with toz80.awk
;
	title	'C128 BIOS, main I/O and sys functions     28 Apr 86'

;
;	This module contains CXIO,CXINIT,CXMOVE and CXTIME.
;
	maclib	cpm3

	maclib	z80

	maclib	cxequ

	maclib	modebaud


	public	_init,_ldccp,_rlccp

	public	_user,_di_int

	extrn	_sysint

DEFC bdos  =  5 

	extrn	@civec,@covec,@aivec,@aovec,@lovec
	extrn 	_bnksl

	public	_cinit,_ci,_co,_cist,_cost
	public	@ctbl
	extrn	_kyscn

; Utility routines in standard BIOS
	extrn	_wboot		; warm boot vector
        extrn   _pmsg           ; print message @<HL> up to 00
                                ; saves <BC> & <DE>
        extrn   _pdec           ; print binary number in <A> from 0 to 99.
	extrn	_pderr		; print BIOS disk error header
	extrn	_conin,_cono	; con in and out
	extrn	_const		; get console status

	extrn	@hour,@min,@sec,@date,_bnksl
	public	_time

	page
;
;	keyboard scanning routine 
;
	extrn	_get_key,_int_cia
	extrn	Fx_V_tbl
;
;	links to 80 column display
;
	extrn	_out80,_int80
	extrn	_out40,_int40

	extrn	_pt_i_1101,_pt_o_1,_pt_o_2
	extrn	_convt
;	extrn	_pt_s_1101

;
;	bios8502 function routines
;
	public	_fun65

;
;
;
	public	_intbd
	extrn	_int65,_in65,_ins65,_out65,_outs65

;	cseg
;trace:
;	xthl			; save hl on stack
;	push	psw
;	call	_pmsg		; DE and BC saved by _pmsg
;	pop	psw
;	xthl
;	ret
;
;	CSEG
;disp_A:
;	push	psw		;;;test
;	ani	0fh		;;;test
;	adi	90h		;;;test
;	daa			;;;test
;	aci	40h		;;;test
;	daa			;;;test
;	sta	low_test	;;;test
;	pop	psw		;;;test
;	rar			;;;test
;	rar			;;;test
;	rar			;;;test
;	rar			;;;test
;	ani	0fh		;;;test
;	adi	90h		;;;test
;	daa			;;;test
;	aci	40h		;;;test
;	daa			;;;test
;	sta	hi_test		;;;test
;	call	trace		;;;test
;hi_test:			;;;test
;	db	31		;;;test
;low_test:			;;;test
;	db	31		;;;test
;	db	' '		;;;test
;	db	0		;;;test
;	ret			;;;test
;
	page

	DSEG
_fun65:
	LD	(vic_cmd),A			; save the command passed in A
	
   if	not use_6551

   ; See https://en.wikipedia.org/wiki/MOS_Technology_6551
   ; "Commodore International omitted the 6551 from the popular VIC-20, C64, and C128 home computers.
   ; Instead, these systems implemented a bit-banging UART via KERNAL routines."

fun_di_wait:
	LD	A,(RS232_status)
	AND	11000010b		; char to Xmit, Xmiting or receiving _
	JR	NZ,fun_di_wait		; yes, wait for int to clean up
   endif
	di
	LD	A,(force_map)		; get current MMU configuration
	PUSH	AF			; save it
	LD	(io_0),A			; make I/O 0 current

	LD	DE,1			; D=0,  E=1
   if	use_fast
	LD	BC,VIC_speed
	inp	a
	LD	(sys_speed),A
	outp	d			; set slow mode (1 2 MHz Z80)
   endif
	LD	BC,page_1_h
	outp	d
	DEC	c
	outp	e			; page 1, 0-1
	DEC	c
	outp	d
	DEC	c
	outp	d			; page 0, 0-0
	
	;  DEFC enable_z80  =  0FFD0h ; 8502 code
	;  DEFC return_z80  =  0FFDCh 
	;  DEFC enable_6502  =  0FFE0h ; Z80 code
	;  DEFC return_6502  =  0FFEEh 

	call	enable_6502+6		; go run the 8502
	LD 	c,low(page_1_h)
	outp	e
	DEC	c
	outp	e			; page 1, 1-1
	DEC	c
	outp	e
	DEC	c
	outp	d			; page 0, 1-0
   if	use_fast
	LD	BC,VIC_speed
	LD	A,(sys_speed)		; get desired system speed
	outp	a			; set speed (2 or 4 MHz Z80)
   endif
	POP	AF			; recover the MMU config.
	LD	(force_map),A		; restore it
	ei				; turn interrupts back on
	LD	A,(vic_data)		; get command results
	OR	a			; set the zero flag if A=0
	ret

_di_int:
   if	not use_6551
	PUSH	AF
di_int_1:
	LD	A,(RS232_status)		; character to Xmit or currently
	AND	11000010b		; ..transmitting or receiving _
	JR	NZ,di_int_1		; yes, wait for int to clean up
	POP	AF
   endif
	di
	ret

	page
;
;	set up the MMU for CP/M Plus
;
	DSEG			; init done from banked memory
_init:
	LD 	a,3eh			; force MMU into I/O space
	LD	(force_map),A		;
	LD	HL,mmu_table+11-1	; table of 11 values
	LD	BC,mmu_start+11-1	; to to MMU registers
	LD 	d,11			; move all 11 bytes to the MMU

init_mmu_loop:
	LD 	a,(HL)
	outp	a
	DEC	HL
	DEC	BC
	DEC	d
	JR	NZ,init_mmu_loop

	LD 	a,1			; enable track and sector status
	LD	(stat_enable),A		; on the status line
;	mvi	a,1			; no parity, 8 bits, 1 stop bit
	LD	(XxD_config),A
;
   if	use_6551
	LD	HL,int_6551
   else
	LD	HL,usart
   endif
	LD	(usart_adr),HL

	LD	HL,_convt
	LD	(prt_conv_1),HL
	LD	(prt_conv_2),HL

	LD	HL,Fx_V_tbl
	LD	(key_FX_function),HL
;
; install I/O assignments
;
	LD	HL,4000h+2000h 		; 80 and 40 column drivers
	LD	(@covec),HL
	LD 	h,80h
	LD	(@civec),HL			; assign console input to keys
	LD 	h,10h
	LD	(@lovec),HL			; assign printer to LPT:
	LD 	h,00h
	LD	(@aivec),HL
	LD	(@aovec),HL			; assign rdr/pun port

	page
;
; print sign on message
;
	call	prt_msg			; print signon message
	DEFM	"Z"-'0'			; initialize screen pointers
	DEFM	esc,esc,esc
	DEFM	purple+50h		; set character color
	DEFM	esc,esc,esc
	DEFM	black+60h		; set background (BG) color
	DEFM	esc,esc,esc
	DEFM	brown+70h		; set border color
	DEFM	"Z"-'0'			; home and clear screen (to BG color)

	DEFM	lf,lf,lf
    if	use_fast
	DEFM	"Fast "
    endif

    if	use_6551
	DEFM	"/w 6551 "
    endif

	DEFM	"CP/M 3.0"
    if	not banked
	DEFM	" Non-Banked"
    endif
	DEFM	" On the Commodore 128 "
	date
	warning
	DEFM	cr,lf
	DEFM	"          ",0

;
;	set CONOUT driver to correct screen
;
	LD	HL,4000h			; 80 column screen vector	
	call	read_d505
	RLA
	JR	NC,set_screen
	LD 	a,'4'
	LD	(screen_num),A
	LD 	h,20h			; 40 column screen vector

set_screen:
	call	prt_msg			; HL saved
screen_num:
	DEFM	"80 column display",cr,lf,lf,lf,lf,0
	LD	(@covec),HL			; assign console output to CRT: (40/80)

	page

;
;
	LD 	a,-1			; set block move to NORMAL mode
	LD	(source_bnk),A
;
;	install mode 2 page vectors
;
	LD 	a,JMP
	LD	(INT_vector),A		; install a JMP at vector location
	LD	HL,_sysint
	LD	(INT_vector+1),HL		; install int_handler adr
;
; A software fix is  required for the lack of hardware to force the
; LSB of the INT vector to 0. If the bus floats INT VECT could be
; read as 0FFh; thus ADRh=I (I=0FCh) ADRl=FF for first read, and
; ADRh=I+1 ADRl=00 for second, to ensure that control is retained
; 0FD00h will also have FDh in it.
;
	LD	HL,int_block		; FC00h
	LD	DE,int_block+1		; FC01h
	LD	BC,256-1+1		; interrupt pointer block
	LD 	(HL),INT_vector/256	; high and low are equal (FD)
	ldir
	LD 	a,INT_block/256
	LD	I,A				; set interrupt page pointer
	im2				; enable mode 2 interrupts

	page
;
;
	LD 	a,vicinit		; null command just to setup BIOS8502
	call	_fun65
;
;
;
	LD	A,(sys_freq)		; 0=60Hz 0FFh=50Hz
	AND	80h			; 0=60Hz 080h=50Hz
	LD 	l,a			; save in L
	LD	BC,cia_1+0eh		; point to CRA
	inp	a			; get old config
	AND	7fh			; clear freq bit
	OR	l			; add in new freq bit
	outp	a			; set new config

	LD 	c,8			; start RTC
	outp	a

	LD	HL,date_hex
	LD	(@date),HL			; set date to system data

;
;	setup the sound variables
;
	LD	HL,(key_tbl)
	LD	DE,58*4
	ADD	HL,DE
	LD 	e,(HL)
	INC	HL
	LD 	d,(HL)
	INC	HL
	EX	DE,HL
	LD	(sound1),HL			; H=SID reg 24, L=SID reg 5
	EX	DE,HL
	LD 	e,(HL)
	INC	HL
	LD 	d,(HL)
	EX	DE,HL
	LD	(sound2),HL			; H=SID reg 6, L=SID reg 1
	LD	HL,9
	ADD	HL,DE
	LD 	e,(HL)
	INC	HL
	LD 	d,(HL)
	EX	DE,HL
	LD	(sound3),HL			; H=SID reg 4 then L=SID reg 4 
;
;	set-up key click sound registers
;
	LD	BC,sid+7
	LD	HL,0040h
	outp	l			; (sid+7)=40h
	INC	c
	outp	l			; (sid+8)=40h
	LD 	c,low(sid+12)
	outp	h			; (sid+12)=0  Attack=2ms, Decay=6ms
	INC	c
	outp	h			; (sid+13)=0  Sustain=0,  Release=6ms
	LD 	a,6
	LD	(tick_vol),A		; set keyclick volumn level
;
;	set up interrupts for key scan (not software usart)
;
   if	use_6551
	LD	DE,2273			; int at 150 BAUD rate
	LD	BC,CIA1+timer_b_low	;
	outp	e			;
	INC	c			; point to timer_b_high
	outp	d			;

	LD 	a,11h			;
	LD 	c,CIA_ctrl_b		; turn on timer B
	outp	a			;

	LD	BC,CIA2+data_b		; setup user port for RS232
	inp	a			; get old data
	OR	6			; set CTS and DTR
	outp	a			; update it
   endif
 	ret


mmu_table:
	mmu_tbl_M

	page
;
;
;
	CSEG
prt_msg:
	EX	(SP),HL
	call	_pmsg
	EX	(SP),HL
	ret


;
;	placed in common memory to keep IO from stepping on this code
;		always called from bank 0
;
	CSEG
read_d505:
	LD	(io_0),A			; enable MMU (not RAM)
	LD	BC,0d505h
	inp	a			; read 40/80 column screen
	LD	(bank_0),A			; re-enable RAM
	ret

	page
;
;
;
	DSEG
   if	not use_6551
init_RS232:
	di

	XOR	a
	LD	(RS232_status),A
	LD	HL,RxD_buf_count		; clear the count
	LD 	(HL),0
	INC	l			; point to RxD_buf_put
	LD 	(HL),low(RxD_buffer)
	INC	l			; point to RxD_buf_get
	LD 	(HL),low(RxD_buffer)

	LD	HL,NTSC_baud_table
	LD	A,(sys_freq)
	OR	a
	JR	Z,use_NTSC
	LD	HL,PAL_baud_table
use_NTSC:
	LD	A,(RS232_baud)
	CP	baud_1200		; baud rate less then 1200 baud
	JR	C,baud_ok			; yes, go set it
	LD 	a,baud_1200		; no, 1200 baud is the max
	LD	(RS232_baud),A		; (change to 1200 baud)

baud_ok:
	LD 	e,a
	LD 	d,0
	ADD	HL,DE			; +1X
	ADD	HL,DE			; +1X
	ADD	HL,DE			; +1X = +3X
	LD 	e,(HL)
	INC	HL
	LD 	d,(HL)
	INC	HL			;
	LD 	a,(HL)			; get rate #
	LD	(int_rate),A		;
	LD	BC,CIA1+timer_b_low	;
	outp	e			;
	INC	c			; point to timer_b_high
	outp	d			;

	LD 	a,11h			;
	LD 	c,CIA_ctrl_b		; turn on timer B
	outp	a			;

	LD	BC,CIA2+data_b		; setup user port for RS232
	inp	a			; get old data
	OR	6			; set CTS and DTR
	outp	a			; update it
	ei
	ret

	page
;
;	NTSC rates (1.02273 MHz)
;
NTSC_baud_table:
	DEFW	6818			; no baud rate	 (6666.47)
	DEFM	1
	DEFW	6818			; 50	6666.7us (6666.47)
	DEFM	1
	DEFW	4545			; 75	4444.4us (4443.99)
	DEFM	1
	DEFW	3099			; 110	3030.3us (3030.13)
	DEFM	1
	DEFW	2544			; 134	2487.6us (2487.46)
	DEFM	1
	DEFW	2273			; 150	2222.2us (2222.48)
	DEFM	2
	DEFW	1136			; 300	1111.1us (1110.75)
	DEFM	3
	DEFW	568			; 600	 555.6us ( 555.38)
	DEFM	6
	DEFW	284			; 1200	 277.8us ( 277.69)
	DEFM	12

;
;	PAL rates (0.98525 MHz)
;
PAL_baud_table:
	DEFW	6568			; no baud rate	  (6666.32)
	DEFM	1
	DEFW	6568			; 50	 6666.7us (6666.32)
	DEFM	1
	DEFW	4379			; 75	 4444.4us (4444.56)
	DEFM	1
	DEFW	2986			; 110	 3030.3us (3030.70)
	DEFM	1
	DEFW	2451			; 134	 2487.6us (2487.69)
	DEFM	1
	DEFW	2189			; 150	 2222.2us (2221.77)
	DEFM	2
	DEFW	1095			; 300	 1111.1us (1111.39)  300*3
	DEFM	3
	DEFW	547			; 600	  555.6us ( 555.19)  600*3
	DEFM	6
	DEFW	274			; 1200    277.8us ( 278.10) 1200*3
	DEFM	12

	page
;
;
;
out_RS232:
	call	out_st_RS232
	JR	Z,out_RS232
	LD 	a,c
	LD	(xmit_data),A		; get character to send in A
	LD	HL,RS232_status
	setb	7,(HL)			; set Xmit request bit
	ret

;
;
;
out_st_RS232:
	LD	A,(RS232_status)
	AND	80h			; bit 8 set if busy
	XOR	80h			; A cleared if busy (=80h if not)
	RET	Z
	OR	0ffh			; A=ff if ready (not busy)
	ret

;
;
;
in_RS232:
	call	in_st_RS232
	JR	Z,in_RS232
	LD	A,(recv_data)
	LD	HL,RS232_status
	res	0,(HL)
	ret

;
;
;
in_st_RS232:
	LD	A,(RS232_status)
	AND	1
	RET	Z
	OR	0ffh			; set data ready (-1)
	ret
   endif
	page
;
;	this routine is used to provide the user with a method
;	of interfacing with low level system functions
;
	CSEG
;
;	input:
;		all registers except HL and A are passed to function
;
;	output:
;		all resisters from function are preserved
;
_user:
	LD	(user_hl_temp),HL
	EX	DE,HL
	LD	(de_temp),HL			; save DE for called function

	LD 	e,a			; place function number in E
	LD 	a,num_user_fun-1	; last legal function number

	call	vector			; function
usr_tb:	DEFW	read_mem_0		; 0
	DEFW	write_mem_0		; 1
	DEFW	_kyscn			; 2
	DEFW	do_rom_fun		; 3  (L=function #) 	
	DEFW	do_6502_fun		; 4  (L=function #)
	DEFW	read_d505		; 5  returns MMU reg in A
	DEFW	code_error		; not 0 to 5 ret version number in HL

DEFC num_user_fun  =  (_-usr_tb)/2 

	page
;
;	address in DE is read and returned in C
;	A=0 if no error
;
	DSEG
read_mem_0:
	LD	A,(DE)			; read location addressed by DE
	LD 	c,a			; value returned in C
	XOR	a			; clear error flag
	ret

;
;	address in DE is written to with value in C
;	A=0 if no errors
;
write_mem_0:
	LD 	a,-1			; get error flag and 0ffh value
	CP	d			; do not allow write from FF00 to FFFF
					;   this is 8502 space, MMU direct reg.
	RET	Z
	LD 	a,d
	CP	10h			; do not allow write from 0000 to 0FFF
					;   this is ROM space
	LD 	a,-1			; get error flag
	RET	C				; return if 00h to 0fh
	LD 	a,c
	LD	(DE),A
	XOR	a			; clear error flag 
	ret

	page
;
;	This is the function code entry point for direct execution
;	of driver functions. If the MSB of the function number is
;	set, the 40 column driver is used; else the 80 column drive 
;	is used.
;
do_rom_fun:
	LD	HL,(user_hl_temp)		; get HL (L=fun #)

	LD 	a,7eh			; only allow even functions
	AND	l
	CP	79h
	JR	C,no_hl_req
	LD	HL,(1dma)			; HL will be passed in @dma by
	PUSH	HL			; ..the user
no_hl_req:
	LD 	l,a
	rst	28h			; call rom functon (RCALL) L=fun #	
	ret

;	mvi	a,7eh			; only allow even functions
;	ana	l
;	sta	no_hl_req+1
;	cpi	79h
;	jrc	no_hl_req
;	lhld	@dma			; HL will be passed in @dma by
;	push	h			; ..the user
;no_hl_req:
;	will be changed to RCALL xx   RET for next release (ROM FN 7A, 7C
;		and 7E will not function with current code, they expect
;		a return address on the stack
;
;	RJMP	5Eh			; unused function, real fun# installed
					; ..above

do_6502_fun:
	LD	HL,(user_hl_temp)
	LD 	a,l
	JP	_fun65
;
;
;
code_error:
	LD	HL,date_hex
	LD 	a,-1
	ret

	page
;
;
;
	CSEG
_rlccp:
	LD	HL,ccp_buffer
	LD	BC,0c80h

load_ccp:
	LD	(bank_0),A
	LD 	a,(HL)
	LD	(bank_1),A
	LD	DE,-ccp_buffer+100h
	ADD	HL,DE
	LD 	(HL),a
	LD	DE,ccp_buffer-100h+1
	ADD	HL,DE
	DEC	BC
	LD 	a,b
	OR	c
	JR	NZ,load_ccp
	ret

	page
;
;
;
	CSEG
_ldccp:
	XOR	a
	LD	(ccp_fcb+15),A	; zero extent
	LD	HL,0
	LD	(fcb_nr),HL		; start at beginning of file
	LD	DE,ccp_fcb
	call	open		; open file containing CCP
	INC	a
	JR	Z,no_CCP		; error if no file...
	LD	DE,0100h
        call    setdma          ; start of TPA
        LD     DE,128
	call	setmulti	; allow up to 16K bytes
	LD	DE,ccp_fcb
	call	read

	LD	HL,0100h
	LD	BC,0c80h
	LD	A,(force_map)
	PUSH	AF

;
;
save_ccp:
	LD	(bank_1),A
	LD 	a,(HL)
	LD	(bank_0),A
	LD	DE,ccp_buffer-100h
	ADD	HL,DE
	LD 	(HL),a
	LD	DE,-ccp_buffer+100h+1
	ADD	HL,DE
	DEC	BC
	LD 	a,b
	OR	c
	JR	NZ,save_ccp

	POP	AF
	LD	(force_map),A
	ret

	page 
;
;	The following code does not work with the NEW MMU
;
;_ldccp:
;	xra	a
;	sta	ccp_fcb+15	; zero extent
;	lxi	h,0
;	shld	fcb_nr		; start at beginning of file
;	lxi	d,ccp_fcb
;	call	open		; open file containing CCP
;	inr	a
;
;;	trace	jz below should be jrz
;	jz	no_CCP		; error if no file...
;
;	lda	fcb_rc		; get the record count
;	sta	ccp_count	; save for later
;	lxi	d,0100h
;       call    setdma          ; start of TPA
;       lxi     d,128
;	call	setmulti	; allow up to 16K bytes
;	lxi	d,ccp_fcb
;	call	read
;
;	lxi	d,1f0h		; point to buffer
;				; bank 1, page F0
;;	lxi	h,101h		; point to CCP (in TPA)
;				; bank 1, page 01
;	mov	h,d
;	mov	l,d
;	jr	save_ccp
;
;
;
;
;_rlccp:
;	lda	ccp_count	;
;	sui	30		; we can only save 30 records
;	jp	_ldccp
;
;	lxi	h,1F0h		; point to buffer
;				; bank 1, page F0
;;	lxi	d,101h		; point to TPA space
;				; bank 1, page 01
;	mov	d,h
;	mov	e,h
;
;save_ccp:
;	mvi	b,15		; number of pages in buffer
;ccp_move_loop:
;	push	h
;	push	d
;	push	b
;	call	do_move_0_to_1
;	pop	b
;	pop	d
;	pop	h
;	inx	h
;	inx	d
;	djnz	ccp_move_loop
;
;	ret
;
;
;do_move_0_to_1:
;	call	set_0_and_1
;	call	move_0_to_1
;	lxi	h,100h		; bank 1 page 0
;;	lxi	d,101h		; bank 1 page 1
;	mov	d,h
;	mov	e,h
;;
;;
;;
;set_0_and_1:
;	lda	force_map	; get current map
;	sta	io		; force to i/o in bank 0
;	lxi	b,page_0_l	; point to 1st page register
;	outp	l		; set page 0 low
;	inr	c
;	outp	h		; set page 0 high
;	inr	c
;	outp	e		; set page 1 low
;	inr	c
;	outp	d		; set page 1 high
;	sta	force_map
;	ret
;
;;
;;
;;
;move_0_to_1: 
;	lda	force_map
;	sta	bank_1		; force bank 1 memory
;	lxi	h,000h		; source
;	lxi	d,100h		; dest.
;;	lxi	b,100h
;	mov	b,d
;	mov	c,e		; count
;	ldir
;	sta	force_map
;	ret
;
	page
;
;
;
no_CCP:				; here if we couldn't find the file
	call	prtmsg		; report this...
	DEFM	cr,lf,"BIOS Err on A: No CCP.COM file",0
	call	_conin		; get a response
	jr	_ldccp		; and try again

;
; CP/M BDOS Function Interfaces
;
	CSEG
open:
	LD 	c,15		; open file control block

	DEFM	21h		; lxi h,(mvi c,26)
setdma:
	LD 	c,26		; set data transfer address

	DEFM	21h		; lxi h,(mvi c,44)	
setmulti:
	LD 	c,44		; set record count

	DEFM	21h		; lxi h,(mvi c,20)
read:
	LD 	c,20		; read records
	JP	bdos

;			   12345678901
ccp_fcb		DEFM	1,"CCP     COM",0,0,0
fcb_rc		DEFM	0
		DEFS	16
fcb_nr		DEFM	0,0,0


	page
;
;	CXIO.ASM and CXEM.ASM
;
;==========================================================
;		ROUITINE TO VECTOR TO HANDLER
;==========================================================
;	CP/M IO routines	b=device : c=output char : a=input char
;
	CSEG
;
;
;
_cinit:				; initialize usarts
	LD 	b,c
	call	vector_io	; jump with table adr on stack
number_drivers:
	DEFW	_int_cia	; keys
	DEFW	_int80		; 80col
	DEFW	_int40		; 40col
	DEFW	_pt_i_1101	; prt1
	DEFW	_pt_i_1101	; prt2
	DEFW	_int65		; 6551
   if	not use_6551
	DEFW	init_RS232	; software RS232
   endif
	DEFW	rret		;
DEFC max_devices  =  ((_-number_drivers)/2)-1 

;
;
;
_ci:                            ; character input
	call	vector_io	; jump with table adr on stack
	DEFW	key_board_in	; keys
	DEFW	rret		; 80col
	DEFW	rret		; 40col
	DEFW	rret		; ptr1
	DEFW	rret		; prt2
	DEFW	_in65		; 6551
   if	not use_6551
	DEFW	in_RS232	; software RS232
   endif
	DEFW	null_input

;
;
;
_cist:				; character input status
	call	vector_io	; jump with table adr on stack
	DEFW	key_board_stat	; keys
	DEFW	rret		; 80col
	DEFW	rret		; 40col
	DEFW	rret		; prt1
	DEFW	rret		; prt2
	DEFW	_ins65		; 6551
   if	not use_6551
	DEFW	in_st_RS232	; software RS232
   endif
	DEFW	rret

;
;
;
_co:				; character output
	call	vector_io	; jump with table adr on stack
	DEFW	rret		; keys
	DEFW	_out80		; 80col
	DEFW	_out40		; 40col
	DEFW	_pt_o_1		; prt1
	DEFW	_pt_o_2		; prt2
	DEFW	_out65		; 6551
   if	not use_6551
	DEFW	out_RS232	; software RS232
   endif
	DEFW	rret

;
;
;
_cost:				; character output status
	call	vector_io	; jump with table adr on stack
	DEFW	ret_true	; keys
	DEFW	ret_true	; 80col
	DEFW	ret_true	; 40col
	DEFW	ret_true	; prt1	_pt_s_1101
	DEFW	ret_true	; prt2
	DEFW	_outs65		; 6551
   if	not use_6551
	DEFW	out_st_RS232	; software RS232
   endif
	DEFW	ret_true

	page
;
;	This entry does not care about values of DE
;
vector_io:
	LD 	a,max_devices	; check for device # to high
	LD 	e,b		; get devive # in E
;
;
;	INPUT:
;		Vector # in E, Max device in A
;		passes value in DE_TEMP in DE
;		HL has routine's address in it on entering routine
;
;	OUTPUT:
;		ALL registers of returning routine are passed
;
vector:
	POP	HL		; get address vector list
	LD 	d,0		; zero out the MSB
	CP	e		; is it too high_
	JR	NC,exist		; no, go get the handler address

	LD 	e,a		; yes, set to max_dev_handler(last one) 
exist:
	ADD	HL,DE		; 
	ADD	HL,DE		; point into table

 	LD 	a,(HL)
	INC	HL
	LD 	h,(HL)
	LD 	l,a		; get routine adr in HL

    if	banked
	LD	(hl_temp),HL		; save exec adr
	LD	HL,0
	ADD	HL,sp
	LD	sp,bios_stack
	PUSH	HL		; save old stack

	LD	HL,(de_temp)
	EX	DE,HL
	LD	HL,(hl_temp)		; recover exec adr

	LD	A,(force_map)	; get current bank
	PUSH	AF		; save on stack
	LD	(bank_0),A		; set bank 0 as current

	call	ipchl

	LD	(a_temp),A		; save value to return
	POP	AF
	LD	(force_map),A	; set old bank back
	LD	A,(a_temp)		; recover value to return

	LD	(hl_temp),HL
	POP	HL		; recover old stack
	LD	SP,HL			; set new stack
	LD	HL,(hl_temp)
	ret

ipchl:
	JP	(HL)			; jmp to handler

	DEFS	30h
bios_stack:

    else
	LD	A,(a_temp)
	EX	DE,HL
	LD	HL,(de_temp)
	EX	DE,HL
	JP	(HL)
    endif

	page
;==========================================================
;		CHARACTER INPUT ROUTINES
;==========================================================

	DSEG
;
;
;
key_board_in:
	call	key_board_stat	; test if key is available
	JR	Z,key_board_in	

	LD	A,(key_buf)
	PUSH	AF		; save on stack
	XOR	a		; clear key 
	LD	(key_buf),A
;
;**	the tracking of the display should be able to be turned off
;**	this could be done with one of the keyboard's Fx codes
;
	LD	A,(stat_enable)
	bit	6,a
	JR	NZ,no_update
	LD	A,(char_col_40)
	LD 	b,a
	LD	A,(@off40)
	CP	b
	JR	NC,do_update
	ADD	A,39-1
	CP	b
	JR	NC,no_update
do_update:
	LD 	a,80h	
	LD	(old_offset),A	; store 80h to demand update
no_update:
	POP	AF		; recover current key
rret:
	ret

;
;
;
null_input:		; return a ctl-Z for no device
	LD 	a,1Ah
	ret


	page

;==========================================================
;	CHARACTER DEVICE INPUT STATUS
;==========================================================

	DSEG
;
;
;
key_board_stat:
	LD	A,(key_buf)
	OR	a
	JR	NZ,ret_true

	call	_get_key
	OR	a		; =0 if none
	RET	Z			; return character not advailable

	LD	(key_buf),A		; was one, save in key buffer

ret_true:
	OR	0ffh		; and return true
	ret

	page

	cseg
@ctbl
	DEFM	"KEYS  "	; device 0, internal keyboard
	DEFM	mb_input
	DEFM	baud_none

	DEFM	"80COL "	; device 1, 80 column display
	DEFM	mb_output
	DEFM	baud_none

	DEFM	"40COL "	; device 2, 40 column display
	DEFM	mb_output
	DEFM	baud_none

	DEFM	"PRT1  "	; device 3, serial bus printer (device 4)
	DEFM	mb_output
	DEFM	baud_none

	DEFM	"PRT2  "	; device 4, serial bus printer (device 5)
	DEFM	mb_output
	DEFM	baud_none

	DEFM	"6551  "	; device 5, EXT CRT
	DEFM	mb_in_out+mb_serial+mb_softbaud+mb_xonxoff
_intbd:
	DEFM	baud_1200
   if	not use_6551
	DEFM	"RS232 "	; device 6, software RS232 device
	DEFM	mb_in_out+mb_serial+mb_xonxoff+mb_softbaud
RS232_baud:
	DEFM	baud_300
   endif
	DEFM	0		; mark end of table

	page
;
;	TIME.ASM
;
	cseg
;
;	HL and DE must be presevered
;
_time:
	INC	c
	LD	BC,cia_hours
	JR	Z,set_time
;
;	update SCB time  (READ THE TIME)
;
	inp	a			; read HR (sets sign flag)
	JP	P,is_am			; jmp if AM (positive)
	AND	7fh
	ADD	A,12h			; noon=24(PM), midnight=12(AM)
	daa
	CP	24h			; check for noon (12+12 PM)
	JR	NZ,set_hr
	LD 	a,12h
	jr	set_hr

is_am:
	CP	12h			; check for midnight (AM)
	JR	NZ,set_hr
	XOR	a			; becomes 00:00
set_hr:
	LD	(@hour),A
	LD 	b,a
	LD	A,(old_hr)
	LD 	c,a
	LD 	a,b
	LD	(old_hr),A
        CP     c                       ; if 0hour<old_hr
	JR	NC,same_day
 
	PUSH	HL
	LD	HL,(@date)
	INC	HL
	LD	(@date),HL
	POP	HL

same_day:
	LD	BC,cia_hours-1
	inp	a			; read MIN
	LD	(@min),A

	DEC	c
	inp	a			; read SEC
	LD	(@sec),A

	DEC	c
	inp	a			; read 1/10 of SEC (a must to free
	ret				; the holding register)

old_hr:
	DEFS	1

	page
;
;
;
set_time
	LD	A,(@hour)
	LD	(old_hr),A
	CP	12h			; test for noon
	JR	Z,set_as_is
	AND	a			; test for 00:xx
	JR	NZ,not_zero_hundred
	LD 	a,80h+12h			; set to midnight
	jr	set_as_is

not_zero_hundred:
 	CP	11h+1			; test for 1 to 11 AM
	JR	C,set_as_is
	SUB	12h
	daa				; decimal adjust
set_msb:
	OR	80h			; set PM

set_as_is:
	outp	a
	DEC	c
	LD	A,(@min)
	outp	a
	DEC	c
	LD	A,(@sec)
	outp	a
	DEC	c
	XOR	a
	outp	a
	ret

	page
;
; CXMOVE.ASM
;
	public _move,_xmove,_bank

;
;	Move a block of data from DE to HL
;	count is in BC (within current bank)
;
;
	cseg			; place code in common
_move:
	EX	DE,HL			;*
	LD	A,(source_bnk)	; =FFh if normal block move 
	INC	a		; 
	JR	NZ,inter_bank_move

	LDIR			;* do block move	
	EX	DE,HL			;*
	ret


;
;
;
_xmove:				; can be in bank 0	
	LD 	a,c
	LD	(source_bnk),A
	LD 	a,b
	LD	(dest_bnk),A
	ret			;*

	page
;
;
;
inter_bank_move:
	LD	(@buffer),HL		; save HL TEMP
	LD	HL,0
	ADD	HL,sp
	LD	sp,bios_stack
	PUSH	HL		; save old stack  ;**1
	LD	HL,(@buffer)

inter_bank_move_1:
	LD 	a,b		; get msb of count
	OR	a
	JR	Z,count_less_than_256
	PUSH	BC		; save the count  ;**2
	PUSH	DE		; save the dest   ;**3
	LD	DE,@buffer	; make buffer the dest
	LD	BC,256		; move 256 bytes
	LD	A,(source_bnk)
	call	_bank
	ldir			; move source to buffer

	POP	DE		; recover dest    ;**2
	PUSH	HL		; save updated source ;**3
	LD	HL,@buffer	; make the buffer the source
	LD	BC,256		; move 256 bytes
	LD	A,(dest_bnk)
	call	_bank
	ldir			; move buffer to dest
 
	POP	HL		; recover updated source ;**2
	POP	BC		; recover count          ;**1
	DEC	b		; subtract 256 from count
	jr	inter_bank_move_1

	page
;
;
;
count_less_than_256:
	OR	c		; BC=0  [A (0) or'ed with C]
 	JR	Z,exit_move

	PUSH	DE		; save count for 2nd half  ;**2
	PUSH	BC		; save dest adr            ;**3
	LD	DE,@buffer
	LD	A,(source_bnk)
	call	_bank
	ldir			; move source to buffer

	POP	BC		; recover count		  ;**2
	POP	DE		; recover dest		  ;**1
	PUSH	HL		; save updated dest	  ;**2
	LD	HL,@buffer
	LD	A,(dest_bnk)
	call	_bank
	ldir			; move buffer to dest
	POP	HL	 				   ;**1
;
;
;
exit_move:
	EX	DE,HL
	LD 	a,-1
	LD	(source_bnk),A	; set MOVE back to normal
	LD	A,(@cbnk)

	LD	(@buffer),HL
	POP	HL		; recover old stack	;**0
	LD	SP,HL
	LD	HL,(@buffer)

; call	_bank		; set current bank
; ret

	page
;
;	switch bank to bank number in A
;
	cseg			; (must be in common)
_bank:				
   if	banked
	OR	a		; bank 0 _
	JR	NZ,not_bank_0	; go check for bank 1

	LD	(bank_0),A		; set bank 0
	ret

;
;
not_bank_0:
	DEC	a		; bank 1 _
	RET	NZ			; if not a valid bank just return
	LD	(bank_1),A		; set bank 1
   endif
	ret

	end

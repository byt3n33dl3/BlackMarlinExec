; 06-2018: Converted to z80 mnemonics with toz80.awk
;Commodore 128 CP/M v3.0
;General macro definitions and equates

_*MACRO

DEFC false  =  0 
DEFC true  =  not 

DEFC use_fast  =  false 
DEFC use_6551  =  false ;true

DEFC use_vt100  =  false 
DEFC use_1581  =  true 
DEFC banked  =  true 
DEFC EXTSYS  =  false ; use external system as disk and char I/O
DEFC pre_release  =  false 

; start at Jan 1,1978	 78  79  80  81  82  83  84  85  86
DEFC dt_hx_yr  =  365+365+366+365+365+365+366+365+365 
;	1985			  1  2  3  4  5  6  7  8  9 10 11 12
DEFC date_hex  =  dt_hx_yr+31+28+31+30+28 

date	macro
	DEFM	"****"
	endm
;
;	this is only for Pre-Released versions (done in RED)
;
warning	macro
	if	pre_release
	 DEFM	cr,lf,lf
	 DEFM	esc,esc,esc,red+20h
	 DEFM	"User Beware:",cr,lf
		;1234567890123456789012345678901234567890
	 DEFM	"       This version of the software is a",cr,lf
	 DEFM	"  PRE-RELEASE  for testing only.  It has",cr,lf
	 DEFM	"  been tested but has not yet passed QA.",cr,lf
	 DEFM	esc,esc,esc,purple+50h
	 endif
	endm


space	macro	_x,for
DEFC _x  =  start 
start	set	start+for
	endm

;
; boot memory map (bank 0 only)
;
DEFC bios02  =  3000h ;
DEFC block_buffer  =  3400h ; uses 2K
DEFC boot_parm  =  3C00h ; uses about 256 bytes
;
; bank 0 low memory map
;
DEFC ROM  =  0000h 
DEFC VIC_color  =  1000h ; I/O page only (IO_0 selected)
DEFC SYS_key_area  =  1000h ; 3 256 byte blocks (allow 4)
DEFC screen_40  =  1400h ; 2 X 80 X 25 = 4000 
DEFC BANK_parm_blk  =  2400h ; allow 0.5K of parameters
DEFC BIOS8502  =  2600h ; 1.5K
DEFC VIC_screen  =  2C00h ; 1K
DEFC ccp_buffer  =  3000h ; 0c80h (allow 4K)
DEFC bank0_free  =  4000h ; start of free area in bank 0
;
; mapped I/O locations
;
DEFC VIC  =  0D000h ; 8564
DEFC SID  =  0D400h ; 6581
DEFC MMU  =  0D500h ; 8722
DEFC DS8563  =  0D600h ; 8563
DEFC INT_6551  =  0D700h ; 6551 (added to enginnerring units)
DEFC VIC_C_H  =  0D800h ; (memory mapped only in IO_0)
DEFC VIC_C_L  =  01000h ; (memory and i/o mapped in IO_0)
DEFC CIA1  =  0DC00h ; 6526
DEFC CIA2  =  0DD00h ; 6526
DEFC USART  =  0DE00h ; 6551 (extrn card)
DEFC RAM_dsk_base  =  0DF00h ; 8726

;
; Common memory allocation
;
DEFC int_block  =  0FC00h ; mode 2 interrupt pointers (to FDFDh) 
DEFC parm_block  =  0FD00h ; system parameters
DEFC @buffer  =  0FE00h ; disk buffer (256 bytes)
;			0FF00h	; to 0FFFFh used by 8502
;
; the following are C128 system equates
;
DEFC enable_z80  =  0FFD0h ; 8502 code
DEFC return_z80  =  0FFDCh 
DEFC enable_6502  =  0FFE0h ; Z80 code
DEFC return_6502  =  0FFEEh 

	page
start	set	parm_block+1	; 1st byte used as Intterrupt pointer
space	vic_cmd,1		;; bios8502 command byte
space	vic_drv,1		;  bios8502 drive (bit 0 set, drv 0)
space	vic_trk,1		;; bios8502 track #
space	vic_sect,1		;; bios8502 sector #
space	vic_count,1		;  bios8502 sector count
space	vic_data,1		;; bios8502 data byte to/from
space	cur_drv,1		;  current disk installed to Vir. drive
space	fast,1			;  bit 0 set, drv 0 is fast. ect. 

space	key_tbl,2		;; pointer to keyboard table
space   fun_tbl,2               ;; pointer to function table
space   color_tbl_ptr,2         ;; pointer to logical color table
space   fun_offset,1            ;; function # to be preformed
space	sound_1,2		;;
space	sound_2,2		;;
space	sound_3,2		;;

space   @trk,2                  ;; current track number
space	@dma,2			;; current DMA address
;
; below here not used by ROM
;
space	@sect,2			; current sector number
space	@cnt,1			; record count for multisector transfer
space	@cbnk,1			; bank for processor operations
space	@dbnk,1			; bank for DMA operations
space	@adrv,1			; currently selected disk drive
space	@rdrv,1			; controller relative disk drive
space	sys_speed,0	; byte value 0=1MHz, 1=2 MHz (no 40 column disp)
space	ccp_count,1		; number of records in the CCP (not used)
space	stat_enable,1		; status line enable
				;  7 kybrd, key codes(1), functions(0)
				;  6 40 column tracking on(0), off(1)
				;  0 disk stat, enable(1), disable(0) 
space	emulation_adr,2		; address of current emulation
space	usart_adr,2		; PTR to 6551 reg (not used before 6 Dec 85)
; CXIO equates
space	int_hl,2+20		; interrupt HL hold location
space	int_stack,0		; currently only 10*2 used
space	user_hl_temp,2		; user function HL hold location
space	hl_temp,2		; misc temp storage (used by VECTOR)
space	de_temp,2		; misc temp storage (used by VECTOR)
space	a_temp,1		; misc temp storage (used by VECTOR)
space	source_bnk,1		; inter bank move source bank #
space	dest_bnk,1		; inter bank move dest bank #
space	MFM_tbl_ptr,2		; pointer to MFM table
; 1st release end (3 June and 1 Aug 85)
space	prt_conv_1,2		; pointer to printer 1 ASCII Conversion
space	prt_conv_2,2		; pointer to printer 2 ASCII Conversion
space	key_FX_function,2
space	XxD_config,1		; bit 7	0 = no parity	1 = parity
				; bit 6	0 = mark/space	1 = odd/even
				; bit 5	0 = space/even	1 = mark/odd
				; bit 1	0 = 1 stop bit	1 = 2 stop bits
				; bit 0	0 = 7 data bits	1 = 8 data bits

space	RS232_status,1		; bit 7, 1=send data, 0=no data
				; bit 6, 1=sending data
				; bit 5, 1=recv que active
				; bit 4, 1=parity error
				; bit 3, 1=framing error
				; bit 2, 1=recv over run (no used)
				; bit 1, 1=receiving data
				; bit 0, 1=Data byte ready

space   xmit_data,1             ; data byte to send
space   recv_data,1             ; received data byte

;
; The following equates are used by the interrupt driven keyboard handler
;
space	int_rate,1
;
;	1st byte is a pointer into table, 2nd to 12th byte represent
;	the keyboards current state (active low), NOTE: only
;	current if key_buffer is not full
;
space	key_scan_tbl,12
;
;	keyboard roll over buffer
;
DEFC key_buf_size  =  8*2 ; must be an even number of bytes
space	key_get_ptr,2
space	key_put_ptr,2
space	key_buffer,key_buf_size
;
;	software UART recv buffer
;
DEFC RxD_buf_size  =  64 
space	RxD_buf_count,1
space	RxD_buf_put,1
space	RxD_buf_get,1
space	RxD_buffer,RxD_buf_size
space	tick_vol,1

DEFC INT_vector  =  0FDFDh ;; contains a JMP int_handler
					; (in common)
	page
;===> 40 column misc parm
start	set	BANK_parm_blk
space	temp_1,2		;;
space	@off40,0		;;
space	cur_offset,2		;;
space	old_offset,1		;;
space	prt_flg,1		;;
space	flash_pos,2		;;
;
;===> 40 column position and color storage
space	paint_size,1		;;
space	char_adr_40,2		;;
space	char_col_40,1		;;
space	char_row_40,1		;;
space	attr_40,1		;;
space	bg_color_40,1		;;
space	bd_color_40,1		;;
space	rev_40,1		;;
;
;===> 80 column position and color storage
space	char_adr,2		;;
space	char_col,1		;;
space   char_row,1              ;;
space   current_atr,1           ;;
space	bg_color_80,1		;;
space	char_color_80,1		;;
;	ROM uses localtions above this point
;
;===> Emulation parameters
space	parm_base,2
space	parm_area_80,3
	;	ds	2	; 80 column exec_adr
	;	ds	1	; 80 column row #
space	parm_area_40,3
	;	ds	2	; 40 column exec_adr
	;	ds	1	; 40 column row #
space	buffer_80_col,40*2
;
;===> CXIO parameters
;	int_count not used by releases past 10 Oct 85
space	int_count,1		; one added every 1/60th sec
space	key_buf,1
;
;===> CXKEYS parameters
space	key_down_tbl,11*2	; not used any more (int code)
;;;;; free space above, new interrupt driven code does not require this space 
; control_keys	equ	key_down_tbl+11*2 ; byte, not used any more (int code)

space	commodore_mode,1
space	msgptr,2
space	offset,1
space	cur_pos,1
space	string_index,1
; 1st release end (3 June 85)
space	sys_freq,1		; -1=50Hz, 0=60Hz
; 2nd release end (1 Aug 85)

	page

;===> temp ROM boot data storage
DEFC blk_ptr_cnt  =  32 
start	set	boot_parm
space	load_count,2		; number of 128 byte blocks to load
space	ld_blk_ptr,2		; current sector dma pointer
space	blk_unld_ptr,2		; read memory block (1k,2K) pointer
space	block_size,1		; block size (1K=32 or 2K=64)
space	block_end,2		; allow 48K cpm.sys to load
space	block_ptrs,blk_ptr_cnt	; end of block load buffer (+1K or +2K)
space	info_buffer,12
					; CPM3.sys load adr's and counts
space	ext_num,1		; CPM3.SYS current ext #
space	retry,1+64
space	boot_stack,0		; allow 64 bytes of stack

;===> special equates used by CXKEY
DEFC special  =  00010111b 
DEFC SF_exit  =  001h ; RETURN KEY
DEFC SF_insert  =  028h ; PLUS KEY
DEFC SF_delete  =  02Bh ; MINUS KEY
DEFC alpha_toggle  =  03Dh ; commodore key
DEFC alt_key  =  050h ; alterant key
DEFC SF_left  =  055h ; left arrow key
DEFC lf_arrow  =  055h ; left arrow key
DEFC SF_right  =  056h ; right arrow key
DEFC rt_arrow  =  056h ; right arrow key


DEFC buff_large  =  25 
DEFC buff_small  =  7 
DEFC buff_pos  =  7 


	page
;===> External RS232 interface controls
; rxd_6551	equ	0		; read
; txd_6551	equ	0		; write
; status_6551	equ	1		; read
; reset_6551	equ	1		; write
; command_6551	equ	2		; read/write
; control_6551	equ	3		; read/write

DEFC txrdy  =  10h 
DEFC rxrdy  =  08h 
DEFC cmd_init  =  0bh ; no parity, enable txd + rxd, interrupts off
DEFC cntr_init_19200  =  1Fh ; 1 stop, 8 bits, 19200 baud 
DEFC cntr_init_9600  =  1Eh ; 1 stop, 8 bits, 9600 baud (internal)
DEFC cntr_init_600  =  17h ; 600 baud

;===> memory management loactions
DEFC mmu_start  =  MMU 
DEFC conf_reg  =  MMU ; 3eh
DEFC conf_reg_1  =  MMU+1 ; 3fh
DEFC conf_reg_2  =  MMU+2 ; 7fh
DEFC conf_reg_3  =  MMU+3 ; 3eh
DEFC conf_reg_4  =  MMU+4 ; 7eh
DEFC mode_reg  =  MMU+5 ; b1h
DEFC ram_reg  =  MMU+6 ; 0bh 16K top Common
DEFC page_0_l  =  MMU+7 ; 00h
DEFC page_0_h  =  MMU+8 ; 01h
DEFC page_1_l  =  MMU+9 ; 01h	
DEFC page_1_h  =  MMU+10 ; 01h
DEFC mmu_version  =  MMU+11 ; __h

DEFC enable_C64  =  11110001b ; FS=0
DEFC z80_off  =  10110001b ; value to be write to enable 8502
DEFC z80_on  =  10110000b 
DEFC fast_rd_en  =  Z80_on+0 ; fast serial read
DEFC fast_wr_en  =  Z80_on+8 ; fast serial write
DEFC common_4K  =  09h ; top  4K common
DEFC common_8K  =  0ah ; top  8K common
DEFC common_16K  =  0bh ; top 16K common

;===> preconfiguration maps
DEFC force_map  =  0ff00h 
DEFC bank_0  =  0ff01h ; 3fh
DEFC bank_1  =  0ff02h ; 7fh
DEFC io  =  0ff03h ; 3eh
DEFC io_0  =  0ff03h ; 3eh
DEFC io_1  =  0ff04h ; 7eh

	page
;===> 80 column display equates
DEFC DS_index_reg  =  DS8563 
DEFC DS_status_reg  =  DS8563 
DEFC DS_data_reg  =  DS8563+1 
;===> register pointers
DEFC DS_cursor_high  =  14 
DEFC DS_cursor_low  =  15 
DEFC DS_rw_ptr_high  =  18 
DEFC DS_rw_ptr_low  =  19 
DEFC DS_rw_data  =  31 
DEFC DS_color  =  26 
;===> status bits
DEFC DS_ready  =  80h 
DEFC DS_lt_pen  =  40h 
;===> display memory layout  (16K) 0-3fffh
DEFC DS_screen  =  0000h 
DEFC DS_attribute  =  0800h 
DEFC DS_char_def  =  2000h 
;
;===> VIC equates  (8564)
;
DEFC VIC_blk  =  VIC+17 ; bit 4 = 1 for screen on
DEFC VIC_blk_msk  =  00010000b ;

DEFC VIC_key_row  =  VIC+47 ; output

DEFC VIC_speed  =  VIC+48 ; bit 0 = 1 for fast
DEFC VIC_speed_msk  =  00000001b ;

; vic colors
DEFC black  =  0 
DEFC white  =  1 
DEFC red  =  2 
DEFC cyan  =  3 
DEFC purple  =  4 
DEFC green  =  5 
DEFC blue  =  6 
DEFC yellow  =  7 
DEFC orange  =  8 
DEFC brown  =  9 
DEFC lt_red  =  10 
DEFC dark_grey  =  11 
DEFC med_gray  =  12 
DEFC lt_green  =  13 
DEFC lt_blue  =  14 
DEFC lt_grey  =  15 

      page
DEFC RM_status  =  RAM_dsk_base ;read only register
;   bit 7	Interrupt pending if 1
;	6	Transfer complete if 1
;	5	Block verify error if 1
;   note:  bits 5-7 are cleared when read
;	4	128K if 0,  512K if 1
;	3-0	Version #
;
DEFC RM_command  =  RAM_dsk_base+1 ;r/w
;   bit	7	execute per current config. if set
;	6	reserved
;	5	enable auto reload if set (restores all register to
;			value before command was done, else point to
;			next byte to read/write.)
;	4	disable FF00 decode if set (do operation after command writen)
;	3,2	reserved
;       1,0     00 = transfer C128 --> Ram Disk
;               01 = Transfer C128 <-- Ram Disk
;               10 = swap     C128 <-> Ram Disk
;		11 = Verify   C128  =  Ram Disk
;
DEFC RM_128_low  =  RAM_dsk_base+2 ;r/w
;	bits 0 to 7 of C128 address
;
DEFC RM_128_mid  =  RAM_dsk_base+3 ;r/w
;	bits 8 to 15 of the C128 address
;
DEFC RM_ext_low  =  RAM_dsk_base+4 ;r/w
;	bits 0 to 7 of Ram Disk address
;
DEFC RM_ext_mid  =  RAM_dsk_base+5 ;r/w
;	bits 8 to 15 of Ram Disk address
;
DEFC RM_ext_hi  =  RAM_dsk_base+6 ;r/w
;	bit  16       of Ram Disk address if 128K version
;	bits 16 to 18 of Ram Disk address if 512K version
;
DEFC RM_count_low  =  RAM_dsk_base+7 ;r/w
;	low byte transfer count (bits 0-7)
;
DEFC RM_count_hi  =  RAM_dsk_base+8 ;r/w
;	hi byte transfer count  (bits 8-15)
;
DEFC RM_intr_mask  =  RAM_dsk_base+9 ;r/w
;   bit	7	1=enable chip interrupts
;	6	1=enable end of block interrupts
;	5	1=enable verify error interrupts
;
DEFC RM_control  =  RAM_dsk_base+10 ;r/w
;   bit	7,6    	00	Increment both addresses  (default)
;		01	Fix expansion address
;		10	Fix C128 address
;               11      Fix both addresses
;

	page
;===> CIA equates

DEFC Data_a  =  00h 
DEFC Data_b  =  01h 
DEFC Data_dir_a  =  02h 
DEFC Data_dir_b  =  03h 
DEFC timer_a_low  =  04h 
DEFC timer_a_high  =  05h 
DEFC timer_b_low  =  06h 
DEFC timer_b_high  =  07h 
DEFC tod_sec_60  =  08h 
DEFC tod_sec  =  09h 
DEFC tod_min  =  0ah 
DEFC tod_hrs  =  0bh 
DEFC sync_data  =  0ch 
DEFC int_ctrl  =  0dh 
DEFC cia_ctrl_a  =  0eh 
DEFC cia_ctrl_b  =  0fh 
DEFC CIA_hours  =  CIA1+tod_hrs 

DEFC key_row  =  CIA1+Data_a ; output
DEFC key_col  =  CIA1+Data_b ; input


DEFC data_hi  =  4 ; RS232 data line HI
DEFC data_low  =  0 ; RS232 data line LOW

DEFC lf_shift_key  =  80h 
DEFC rt_shift_key  =  10h 
DEFC commodore_key  =  20h 
DEFC control_key  =  04h 

DEFC type_lower  =  0 
DEFC type_upper  =  1 
DEFC type_shift  =  2 
DEFC type_cntrl  =  3 
DEFC type_field  =  00000011b 
	
	page

DEFC bnk1  =  1 
DEFC page0  =  0 
DEFC page1  =  1 

MMU_tbl_M	macro
	DEFM	3fh,3fh,7fh,3eh,7eh		; config reg"s
	DEFM	z80_on,common_8K		; mode & mem
	DEFM	page0,bnk1,page1,bnk1		; page reg"s 
	endm

	page
;
;    ROM functions
;
TJMP	macro	x
	rst 10h ! db x
	endm

TCALL	macro	x
	LD  l,x ! rst 4
	endm

RJMP	macro	x
	rst 18h ! db x
	endm

RCALL	macro	x
	LD  l,x ! rst 5
	endm

DEFC FR_40  =  2 ; offset to 40 column ROM functions

DEFC FR_wr_char  =  00h ; D=char auto advance
DEFC FR_cursor_pos  =  04h ; B=row, C=column
DEFC FR_cursor_up  =  08h 
DEFC FR_cursor_down  =  0Ch 
DEFC FR_cursor_left  =  10h 
DEFC FR_cursor_rt  =  14h 
DEFC FR_do_cr  =  18h 
DEFC FR_CEL  =  1Ch 
DEFC FR_CES  =  20h 
DEFC FR_char_ins  =  24h 
DEFC FR_char_del  =  28h 
DEFC FR_line_ins  =  2Ch 
DEFC FR_line_del  =  30h 
DEFC FR_color  =  34h ; B=color
DEFC FR_attr  =  38h ; B=bit to set/clear, C=bit value
DEFC FR_rd_chr_atr  =  3Ch ; in  D=row, E=col
					; out H=row, L=col, B=char, C=attr(real)
DEFC FR_wr_chr_atr  =  40h ; in  D=row, E=col, B=char, C=attr(real)
					; out H=row, L=col
DEFC FR_rd_color  =  44h 
;FR_wr_color		equ	48h
;			equ	4Ch

	page
;
DEFC FR_trk_sect  =  50h 
DEFC FR_check_CBM  =  52h 
DEFC FR_bell  =  54h 
;			equ	56h
;			equ	58h
;			equ	5Ah
;			equ	5Ch
;			equ	5Eh

DEFC FR_trk_40  =  60h 
DEFC FR_set_cur_40  =  62h 
DEFC FR_line_paint  =  64h 
DEFC FR_screen_paint  =  66h 
DEFC FR_prt_msg_both  =  68h 
DEFC FR_prt_de_both  =  6Ah 
DEFC FR_update_it  =  6Ch 
;			equ	6Eh

DEFC FR_ASCII_to_pet  =  70h 
DEFC FR_cur_adr_40  =  72h 
DEFC FR_cur_adr_80  =  74h 
DEFC FR_look_color  =  76h 
;			equ	78h
DEFC FR_blk_fill  =  7Ah ; HL passed on the stack
DEFC FR_blk_move  =  7Ch ; "
DEFC FR_char_inst  =  7Eh ; "

;
;	fixed ROM locations
;
DEFC R_cmp_hl_de  =  100h-6 
DEFC R_write_memory  =  180h+0 
DEFC R_read_memory  =  180h+3 
DEFC R_set_update_adr  =  180h+6 
DEFC R_wait  =  180h+9 

DEFC R_status_color_tbl  =  1000h-246-16 
DEFC R_color_convert_tbl  =  1000h-230-16 

	page
;
;	Disk type byte definition
;
;	bit	7	0=GCR,  1=MFM
;
;	    if bit 7 is 1 (MFM)
;		6	C0=0,	C1=1	(side 2 #, 0 to (n/2)-1 or n/2 to n-1)
;		5,4	00=128, 01=256, 10=512, 11=1024  byte/sector
;		3,2,1	disk type (MFM)
;		0	starting sector # ( 0 or 1)
;
;	    if bit 7 is 0 (GCR)
;		6	unused (set to 0)
;		5,4	01  (256 byte sectors) (for 1541or 1571)
;			10  (512 byte sectors) (for 1581)
;		3,2,1	disk type (GCR)
;			Type0 = none,  set track and sector as passed
;			Type1 = C64 CP/M   type disk (1541-71)
;			Type2 = C128 CP/M  type disk (1541-71) 
;		0	unused (set to 0)

DEFC MFM  =  1*128 
DEFC C0  =  0*64 ; 2nd side start at begining
DEFC C1  =  1*64 ; 2nd side continues from first
DEFC C1_bit  =  6 

DEFC Type0  =  0*2 ; (MFM)	top, bottom then next track
				; 	(TRK# 0 to (34 or 39))
DEFC Type1  =  1*2 ; (MFM)	top (trk 0 even), bottom (trk 1 odd)
				; 	(TRK# 0 to (69 or 79))
DEFC Type2  =  2*2 ; (MFM)	top TRK# 0 to 39, bottom TRK# 40 to 79 
				; 	(TRK# on back start at 39 and go to 0)
DEFC Type7  =  7*2 ; (MFM) pass the byte values supplied in @trk
				;	and @sect

DEFC TypeX  =  7*2 

DEFC S0  =  0*1 ; start at sector 0
DEFC S1  =  1*1 ; start at sector 1

DEFC S128  =  0*16 
DEFC S256  =  1*16 
DEFC S512  =  2*16 
DEFC S1024  =  3*16 

;
DEFC dsk_none  =  Type0+S256 ; access to any sector on the disk
DEFC dsk_c64  =  Type1+S256 
DEFC dsk_c128  =  Type2+S256 
DEFC dsk_1581  =  Type2+S512 

DEFC dir_track  =  18 ; C64   disk dir track
DEFC c1581_dir_trk  =  39 ; C1581 disk dir track

	page
;
;	6510 commands
;
DEFC vic_reset  =  -1 ; reboot C128
DEFC vic_init  =  0 ; initilize the bios8502
DEFC vic_rd  =  1 ; read one sector of data (256 bytes) 
DEFC vic_wr  =  2 ; write one sector of data
DEFC vic_rdF  =  3 ; set-up for fast read (many sectors)
DEFC vic_wrF  =  4 ; set-up for fast write
DEFC vic_test  =  5 ; test current disk in drive
DEFC vic_query  =  6 ; get start sectors and #sector/trk
DEFC vic_prt  =  7 ; print data character
DEFC vic_frmt  =  8 ; format a disk (1541)
DEFC vic_user_fun  =  9 
DEFC vic_RM_rd  =  10 ; RAM disk read
DEFC vic_RM_wr  =  11 ; RAM disk write

;
;	control charactors
;
DEFC eom  =  00h 
DEFC bell  =  07h 
DEFC bs  =  08h 
DEFC lf  =  0ah 
DEFC cr  =  0dh 
DEFC xon  =  11h 
DEFC xoff  =  13h 
DEFC esc  =  1bh 

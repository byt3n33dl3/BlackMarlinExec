; 06-2018: Converted to z80 mnemonics with toz80.awk
;
;	*****************************************
;	*					*
;	*	Commodore Disk	Controller	*
;	*	Module for CP/M 3.0 BIOS	*
;	*					*
;	*****************************************
;
;
;
	title 'CXDISK   Commodore C-128 Disk Controller    15 Apr 86'




; CP/M 3 Disk definition macros

	maclib	cpm3

	maclib	z80

; C-128 system equates

	maclib	cxequ

	page

; Disk drive dispatching tables for linked BIOS

	public	cmdsk0,cmdsk1,cmdsk2,cmdsk3,cmdsk4

; System Control Block variables
	extrn	@ermde		; BDOS error mode

; Utility routines in standard BIOS
	extrn	_wboot		; warm boot vector
        extrn   _pmsg           ; print message @<HL> up to 00
                                ; saves <BC> & <DE>
        extrn   _pdec           ; print binary number in <HL> from 0 to 65535
	extrn	_pderr		; print BIOS disk error header
	extrn	_conin,_cono	; con in and out
	extrn	_const		; get console status
	extrn	_sctrn		; sector translation routine
	extrn	@covec

;	status line calls

	extrn	_save,_recov,_stat

; System function call
	extrn	_kyscn
	extrn	_fun65
	extrn	_bank
	extrn	_di_int

	public	_dskst
	public	_dkmov
	extrn	_stat,@st40

	page
;
; Initialization entry point.
; called for first time initialization.
;
	DSEG
init_154X:
	XOR	a
	LD	(fast),A
	LD	HL,MFM_table
	LD	(MFM_tbl_ptr),HL
	ret


	page
;
; This entry is called when a logical drive is about to
;  be logged into for the purpose of density and type determination.
;  It may adjust the parameters contained in the disk
;  parameter header pointed to by <DE>
;
	DSEG
;
;	if disk type GCR or drive type 1541 or 1581(reports as GCR)
;	   if sector size is 256 bytes
;	      if 1st sector has 'CBM' (1st 3 bytes)
;	         if last byte = -1 (0FFh)
;	            set C128 double sided
;	         else
;	            set C128 single sided
;	         endif
;	      else
;	         set C64 type
;	      endif
;	   else  (512 byte sector size)
;	      set C1581 type
;	   endif
;	else (must be MFM)
;	   TEST MFM
;	endif
;
login_154X:
	call	get_drv_info	; set the drive to check (DPH_pointer set)

	LD 	a,vic_test
				; ***** add code to reset 1581 drive *****
	call	_fun65
	LD 	b,a
	AND	0ch
	CP	0ch		; fast drive _
	JR	Z,commodore_type	; no, must be 1541 type
	LD 	a,b		; yes, is a 1571 or 1581
	RLCA			; MSB=1 if NON-Commodore disk 
	JR	C,MFM_type	; 1571 NON-Commodore disk is MFM type

	page
;
;	Commodore Type disk is a disk that is in GCR format (1571)
;	Or Standard Commodore format for 1581 (Has a Commodore dir track)
;
commodore_type:
	LD	HL,(DPH_pointer)
	DEC	HL
  if	use_1581
	LD 	a,b		; get the status byte
	AND	30h		; save only the sector size info
	CP	20h		; 512 byte sectors_
	JR	NZ,set_15x1_type	; no, set up as 1571 or 1541
				; yes, set 1581 type drive
;
;
;
set_1581_type:
	LD 	(HL),dsk_1581	; yes, set up as 1581 double sided
	LD	DE,dpb_1581 
	jr	set_dpb_only

  endif

set_15x1_type:
	LD 	(HL),dsk_c64
	LD	DE,dpb_c64_cpm	; set DPB to C64
	call	set_dpb_only

	XOR	a
	LD	(vic_sect),A	; set track 1 sector 0 (1st sector
	INC	a		; on the disk)
	LD	(vic_trk),A

	LD	HL,@buffer
	LD	(local_DMA),HL	; move DMA pointer to disk buffer
	call	login_rd
	AND	a		; read error _
	RET	NZ			; yes, just return

	RET	CALL	FR_check_CBM
	RET	NZ			; return if not 'CBM'
				; A=0FFh if double sided
	INC	a
	LD	HL,(DPH_pointer)
	DEC	HL		; does not affect flags
	LD 	(HL),dsk_c128

	LD	DE,dpb_c128_SS
	JR	NZ,set_dpb_only

	LD	DE,dpb_c128_DS

	page
;
;
;
set_dpb_only:
	LD	BC,0		; set sector translation to zero
set_format:
	LD	HL,(DPH_pointer)
	LD 	(HL),c
	INC	HL
	LD 	(HL),b		; install sector translation
	LD	BC,25-1		; ofset to DPB
	ADD	HL,BC		; HL points to DPB now
	LD	BC,17		; dpb size
	EX	DE,HL			; move to DPB location
	ldir
	ret

	page
;
;    TEST MFM()
;	save number bytes/sector
;	   if double sided
;	      mark two sided
;	   endif
;	   find start and end sector numbers
;	   scan table of disk for match (if more then 1 match ask user) 
;
MFM_type:
	LD 	c,01100000b
	AND	c			; A = status(trk1) shifted left 1 
	PUSH	AF			; save in case bad query
	PUSH	BC			; save BC

	call	get_max_num_B		; used to set the pointer only
	LD 	b,(HL)			; get size, and disk lock flag
	INC	HL
	LD 	a,(HL)
	INC	HL
	LD 	h,(HL)			; get last MFM_mactch_ptr
	LD 	l,a
	LD 	a,b			; get lock flag in A
	AND	80h			; lock bit set _
	LD	(lock_flag),A		;   (save old lock status)
	LD	(last_match),HL		; save last match pointer
	JR	Z,not__locked_entry	; yes, then set same disk type
; set_locked_entry
	XOR	a
	LD	(lock_flag),A
	LD 	c,0B0h
	LD	A,(vic_data)		; get sector size info
	AND	c
	LD 	b,a			; save disk sector size info
	EX	DE,HL				; save HL
	LD	HL,(DPH_pointer)
	DEC	HL
	LD 	a,c
	AND	(HL)			; get old disk sector size
	CP	b			; are they the same_
	JR	NZ,not_locked_entry	; no, then unlock disk anyway

	EX	DE,HL				; get last match pointer (in DE)
	POP	AF			; yes, remove two data elements 
	POP	AF			; ..save on stack
	jr	set_this_entry

not_locked_entry:
	LD	HL,MFM_match_tbl		; clear Match table
	LD	(MFM_cur_ptr),HL
	LD	DE,MFM_match_tbl+1
	LD 	(HL),0
	LD	BC,(MFM_tbl_entries*2)-1+1+1	; table, offset and count
	ldir
	LD 	a,4
	LD	(vic_trk),A			; do query on track 4
	LD 	a,vic_query
	call	_fun65
	POP	BC			; recover BC
	AND	0eh			; query error _
	JR	NZ,query_error		; yes, use only bits 5 and 6 
	LD	A,(@buffer)			; get trk 4 status
	LD 	b,a			; save in B
	AND	0eh			; trk 4 status error _
	JR	NZ,query_error		; yes, use only bits 5 and 6
	LD 	a,b			; recover B (trk 4 status)
	ADD	A,a			; shift left
	AND	c			; mask sector size bits
	LD 	b,a
	POP	AF			; get trk 1 sector size bits
	CP	b			; same as trk 4 sector size_
	LD 	c,01111111b
	JR	Z,trk_1_trk_4		; yes, (then test for mult format)
	LD 	a,80h			; set MSB to mean mult format
	ADD	A,b			; ..(track 0 different sector size
					; ..then track 4) 
	LD 	b,a			; save in B
	LD 	c,11111111b
trk_1_trk_4:
	LD	A,(@buffer+1)		; get number of sectors/track
	SUB	4			; remove 4 to extend the range
	ADD	A,a			; shift	left
	ADD	A,b			; combine with rest of mask
	LD 	b,a			; save in B for now

	LD	A,(@buffer+3)		; minimum sector number
	ADD	A,b			; add in start sector #
	PUSH	AF			; save on stack for a moment

query_error:
	POP	AF			; get value to match 
	AND	c			; test only those bits in the mask

	LD	HL,(MFM_tbl_ptr)
	LD 	b,MFM_tbl_entries
check_next:
	PUSH	BC			; save BC for a moment
	LD 	b,a			; move compare value to 
	LD 	a,(HL)			; get type info
	AND	c			; test only the good info
	CP	b			; match the current type byte
	LD 	a,b			;   (recover A)
	POP	BC			;   (recover BC)
	JR	NZ,not_found		; no, do not queue data
					; yes queue table entry address

	EX	DE,HL				; save adr in DE
	LD	HL,(MFM_cur_ptr)
	LD 	(HL),e
	INC	HL
	LD 	(HL),d
	INC	HL
	LD	(MFM_cur_ptr),HL
	LD	HL,MFM_count
	INC	(HL)			; add one to counter
	EX	DE,HL

	page
;
;
not_found:
	LD	DE,32			; table entry size
	ADD	HL,DE
	djnz	check_next

	LD	A,(MFM_count)		; number of matches in table 
	AND	a			; test for zero
	JP	Z,tell_user_no_entry	; none, tell the user 

	DEC	a			; only one _
	JR	NZ,user_select		; no, go check with user (which one)
	LD	HL,(MFM_match_tbl)		; yes, use the only one found

;
;	install data from pointer in HL
;
set_this_entry:
	PUSH	HL		; save table pointer
	INC	HL
	LD 	a,(HL)		; get type info. 
	EX	DE,HL			; save table address in DE
	LD	HL,(DPH_pointer)
	DEC	HL
	LD 	(HL),a		; save type code
	EX	DE,HL			; get table adr to HL
	INC	HL		; HL points to sector translation table 
	LD 	c,(HL)		; ..zero if none
	INC	HL
	LD 	b,(HL)
	INC	HL		; HL points to DPB
	EX	DE,HL			; DE points to DPB (HL trash)
	call	set_format
	LD 	b,(HL)		; get the number of sect/trk from MFM table
	LD	A,(lock_flag)	; get the current lock flag value
	OR	b		; combine with sect/trk
	EX	DE,HL			; HL=to adr,  DE=from adr
	LD 	(HL),a		; install sect/trk and lock flag
	POP	DE		; recover table pointer
	INC	HL
	LD 	(HL),e
	INC	HL
	LD 	(HL),d		; save MFM table pointer at end of DPH
	ret

	page
;
;	let the user select the Disk type (s)he wants
;
user_select:
	INC	a			; number of entries to try to match
	LD 	b,a			; set in B as loop count
	LD	HL,(last_match)		; get value to match with
	LD 	d,h
	LD 	e,l			; last match pointer is in DE

	LD	HL,MFM_match_tbl
	LD	(MFM_cur_ptr),HL
	LD 	c,0			; start offset at zero

try_next_format:
	LD 	a,e
	CP	(HL)
	INC	HL
	JR	NZ,not_last_match
	LD 	a,d
	CP	(HL)
	JR	NZ,not_last_match
;
; match, set pointer
;
	LD 	a,c			; get offset in A
	PUSH	AF
	call	save_dsk_window
	POP	AF
	jr	set_offset

not_last_match:
	INC	HL			; each pointer uses two bytes 
	INC	c			; advance the index
	djnz	try_next_format		; test for more, loop if so

	call	save_dsk_window

	LD	HL,(MFM_cur_ptr)
user_loop:
	LD 	e,(HL)			; HL=(MFM_cur_ptr)
	INC	HL
	LD 	d,(HL)
	LD	HL,22			; offset to NAME field
	ADD	HL,DE			; point to Disk name
	call	dsk_window_old

dsk_user_sel_wait:
	call	_kyscn
	INC	b			; test for key pressed
	JR	Z,dsk_user_sel_wait
	DEC	b			; adjust back
	LD 	a,b			; move matrix position to A
	CP	SF_exit
	JR	NZ,CK_dsk_user_rt

	LD 	a,c
	AND	4			; control key down _
	JR	Z,no_cntr_key		; no, don't lock this selection
	LD 	a,80h			; yes, lock disk type to this drive
no_cntr_key:
	LD	(lock_flag),A		;
	call	dsk_window_remove
	LD	HL,(MFM_cur_ptr)
	LD 	e,(HL)
	INC	HL
	LD 	d,(HL)
	EX	DE,HL
	jr	set_this_entry

	page
;
;
;
CK_dsk_user_rt:
	CP	SF_right		;
	JR	NZ,CK_dsk_user_lf

; move window down
	LD	A,(MFM_count)		; get number of items in list
	LD 	b,a			; save in B
	LD	A,(MFM_offset)		; get current position
	INC	a			; advance position
	CP	b			; at last position _ (n-1+1 =count)
	JR	NZ,set_offset		; no, then use A as new position
	XOR	a			; yes, move back to start
	jr	set_offset
	
CK_dsk_user_lf:
	CP	SF_left			;
	JR	NZ,dsk_user_sel_wait

; move window up
	LD	A,(MFM_offset)
	DEC	a			; back up offset (under flow_)
	JP	P,set_offset		; result positive, jump
	LD	A,(MFM_count)		; get last item number
	DEC	a			; pointer is 0 to n-1 (not 1 to n)
set_offset:
	LD	(MFM_offset),A		; set new list offset
	INC	a			; add one to adjust for DCR below
	LD	HL,MFM_match_tbl		; set to the beginning

adjust_dsk_loop:
	LD	(MFM_cur_ptr),HL		; set pointer here !
	DEC	a			; at offset yet_
	JR	Z,user_loop		; yes, go display name
	INC	HL
	INC	HL
	jr	adjust_dsk_loop

	page
;
;
;
tell_user_no_entry:
	LD	A,(vic_data)		; get disk test status
	AND	0b0h			; save only sector size and MFM flag
	LD	HL,(DPH_pointer)
	DEC	HL
	LD 	(HL),a			; set disk size and Type0 (MFM)

	LD	HL,dsk_window*256+buff_pos
	LD	DE,no_dsk_msg
disp_msg_DE_HL:
	call	dsk_window_new
dsk_no_entry_wait:
	call	_kyscn
	INC	b
	JR	Z,dsk_no_entry_wait
	DEC	b
	LD 	a,b
	CP	SF_exit
	JR	NZ,dsk_no_entry_wait
;	jr	dsk_window_remove

	page
;
;
;
dsk_window_remove:
	LD	HL,(window_info)
	LD 	b,h
	LD 	c,l
	JP	_recov
;
;
;
save_dsk_window:
	LD	HL,dsk_window*256+buff_pos	; H=size l=pos
	LD	(window_info),HL
	LD 	b,h
	LD 	c,l
	JP	_save
;
;
;
dsk_window_new:
	LD	(window_info),HL
	EX	DE,HL
	LD 	b,d
	LD 	c,e
	PUSH	HL
	call	_save
	POP	HL

dsk_window_old:
	LD	A,(window_info)		; get start index
	INC	a
	LD 	c,a			; place in C

dsk_out_next:
	PUSH	HL
	LD	HL,(window_info)
	LD 	a,h
	ADD	A,l			; compute max index (start+size)
	DEC	a			; ..less 1
	POP	HL
	CP	c
	RET	Z	
	LD 	b,(HL)
	call	dsk_B_out
	INC	HL
	jr	dsk_out_next

;
;
;
dsk_B_out:
	LD 	a,01000000b			; set reverse video attr
	PUSH	BC
	PUSH	HL
	call	_stat				; display space
	POP	HL
	POP	BC				; recover count
	INC	c
	ret

	page
;
; disk READ and WRITE entry points.
; These entries are called with the following arguments:
;	relative drive number in @rdrv (8 bits)
;	absolute drive number in @adrv (8 bits)
;	disk transfer address in @dma (16 bits)
;	disk transfer bank	in @dbnk (8 bits)
;	disk track address	in @trk (16 bits)
;	disk sector address	in @sect (16 bits)
;       pointer to XDPH in <DE>
;
;   return with an error code in <A>
; 	A=0	no errors
; 	A=1	non-recoverable error
;	A=2	disk write protected
;	A=FF	media change detected
;
	DSEG
read_154X:
	call	get_drv_info
	JP	M,mfm_rd
	call	set_up_GCR		; compute effective track and sector
login_rd:
	LD	A,(vic_drv)
	LD 	b,a
	LD	A,(fast)			; get fast flags
	AND	b			; isolate fast bit for this drive
	JR	NZ,rd_fast			; go handle fast drive
rd_slow:
	LD 	a,vicrd			; read a sector of data (A=1)
	call	dsk_fun			; a=0 if no errors
	JP	NZ,test_error		; check for disk error or media change
;
;
;
buf_move:
	XOR	a			; set direction to read
	call	_dkmov			; go move buffer to DMA
	LD	A,(sect_cnt)
	AND	a
	RET	Z				; a=0 means not read errors
	call	set_up_next
	jr	rd_slow

	page
;
;	A=drive type info
;
mfm_rd:
	call	set_up_MFM

rd_fast:
	LD 	a,vic_rd_f
	call	dsk_fun			; go read the disk

	AND	0eh			; mask off error bits
	JR	NZ,test_error

	call	get_sector_size
	INC	d
	INC	e			; adjust count for pre-decrement

	call	_di_int
	LD	BC,0DD00h		; D2PRA
	inp	a			; get current clock polarity 
	XOR	10h			; toggle clk_bit
	outp	a			; to have status sent (extra clock
					; supplied by rd_1571_data for multi
					; sector transfers)
	LD	A,(vic_count)
rd_multi_sect:
	PUSH	AF
	PUSH	DE			; save the sector size
	call	rd_1571_data		; read disk data to DMA address
	POP	DE

	LD	A,(vic_data)
	AND	0eh
	JR	NZ,test_error_pop		; A=0 if no errors
	POP	AF
	DEC	a
	JR	NZ,rd_multi_sect
	ei
	LD	A,(sect_cnt)
	AND	a			; any sectors left to read
	JR	Z,done_rd_1571

	call	set_up_next
	jr	rd_fast

done_rd_1571:
	LD	BC,0DD00h		;   D2PRA
	inp	a
	AND	not(10h)		; set clk_bit hi
	outp	a
	XOR	a			; A=0 for no errors
	ret


	page
;
;
;
write_154X:
	call	get_drv_info
	JP	M,mfm_wr
	call	set_up_GCR
	LD	A,(vic_drv)
	LD 	b,a
	LD	A,(fast)			; get fast flags
	AND	b			; isolate fast bit for this drive
	JR	NZ,wr_fast_drive		; go handle fast drive
wr_slow:
	LD 	a,-1			; set direction to write
	call	_dkmov			; go move DMA to buffer

	LD 	a,vicwr			; write a sector of data
	call	dsk_fun			; a=0 if no errors
	AND	0eh
	JR	NZ,test_error
	LD	A,(sect_cnt)
	AND	a
	RET	Z
	call	set_up_next
	jr	wr_slow

test_error_pop:
	POP	AF
test_error:
	ei
	LD	A,(vic_data)
	AND	0fh			; check for disk error or media change
	CP	0bh			; disk change _
	JR	Z,change_error
	CP	08h			; test for write protect error
	JR	Z,write_prot_error

	LD 	a,1			;  get general error flag
	ret

;
;
write_prot_error:
	LD 	a,2
	ret

;
;
change_error:
	LD 	a,-1
	ret

	page
;
;
;
mfm_wr:
	call	set_up_MFM
wr_fast_drive:
	LD 	a,vic_wr_f
	call	dsk_fun			; go send the write command

	call	get_sector_size		; setup DMA adr and transfer count
	LD	A,(vic_count)
wr_multi_sect:
	PUSH	AF
	PUSH	DE			; save sector size
	call	wr_1571_data		; write data to disk from DMA address
	POP	DE
	AND	0eh
	JR	NZ,test_error_pop
	POP	AF
	DEC	a
	JR	NZ,wr_multi_sect

	ei
	LD	A,(sect_cnt)
	AND	a
	RET	Z				; return if no errors (A=0)
	call	set_up_next
	jr	wr_fast_drive

	page
;
;
;
get_drv_info:
	LD	HL,(@dma)
	LD	(local_dma),HL
	EX	DE,HL
	LD	(DPH_pointer),HL

	LD	A,(@adrv)			; get drive number (0 to F)
	AND	a
	CALL	Z,drive_A_E
	CP	'E'-'A'			; test if drive E
	CALL	Z,drive_A_E
	DEC	HL			; point at drive mask
	DEC	HL
	LD 	a,(HL)			; get drive mask
	LD 	b,a			; save in B
	LD	(vic_drv),A			; save vic drive # (values 1,2,4,8)

	INC	HL			; point at disk type
	XOR	a
	LD	(sect_cnt),A		; clear the count
	INC	a
	LD	(vic_count),A
	LD 	a,(HL)			; get disk type
	AND	a
	ret

;
;	drive A and E share the same physical disk drive (unit 8)
;
drive_A_E:
	LD 	b,a
	LD	A,(curdrv)			; get the current drive def
	CP	b			; curdrv = requested drive _
	RET	Z				; yes, return
					; no, tell the user to swap disk
	PUSH	HL
	PUSH	DE
	PUSH	BC
send_messg:
	LD 	a,b			; get requested drive # to A
	LD	(curdrv),A			; make this the current drive
	ADD	A,'A'			; compute drive letter
	LD	(msg_drv),A

	RET	CALL	FR_bell			; ring BELL to alert user
	LD	HL,swap_msg_lng*256+buff_pos
	LD	DE,swap_msg
	call	disp_msg_DE_HL		; disp and wait for CR

	LD 	a,vic_test
	call	_fun65
;	ani	0fh
;	cpi	0ch			; not fast ERROR _
;	jrz	exit_drv_A_E		; yes, return that's not a problem
;	ani	0eh			; other error type _
;	jrnz	send_messg
exit_drv_A_E:
	POP	BC
	POP	DE
	POP	HL
	LD 	a,b
	ret

swap_msg:	DEFM	"Insert Disk "
msg_drv:	DEFM	"X in Drive A"

DEFC swap_msg_lng  =  _-swap_msg+2 ; +2 for leading and trailing spaces

	page
;	
;
;
get_max_num_b:
	LD	HL,(DPH_pointer)
	LD	BC,42			; offset to number of sectors on track
	ADD	HL,BC
	LD 	a,(HL)			; get number sectors/track/side
	AND	1fh
	LD 	b,a
	ret
;
;
;
get_sector_size:
	LD	HL,(DPH_pointer)
	DEC	HL
	LD 	a,(HL)			; disk type in B (bit 5,4 size info)
	RRCA				; ..00 = 080h byte sectors
	RRCA				; ..01 = 100h byte sectors
	RRCA				; ..10 = 200h byte sectors
	RRCA				; ..11 = 400h byte sectors
	AND	3
	JR	Z,set_128
	JP	PO,not_3			; jump if (A=) 01b or 10b
	INC	a			; make A = 4
not_3:
	LD 	e,0			; set E to zero
	LD 	d,a			; set sector size (1,2 or 4)
get_DMA:
	LD	HL,(local_DMA)		; get the current DMA pointer
	ret

set_128:
	LD	DE,128
	jr	get_DMA 

	page
;
;
;
	DSEG
set_up_GCR:
	CP	dsk_c128
	JP	NZ,tst_next

	LD 	a,4
	LD	(sect_cnt),A
	LD	HL,sect_buffer
	LD	(sect_buf_ptr),HL

	LD	HL,(@trk)			; 1 K sector pointer 
	ADD	HL,HL
	ADD	HL,HL			; make 256 byte pointer
;
;	build a list of tracks and sectors
;
next_sect:
	LD	(@trk),HL
	RET	CALL	FR_trk_sect
	LD	HL,(vic_trk)			; get trk(L) and sector(H) to HL
	EX	DE,HL
	LD	HL,(sect_buf_ptr)
	LD 	(HL),e
	INC	HL
	LD 	(HL),d
	INC	HL
	LD	(sect_buf_ptr),HL
	LD	HL,(@trk)
	INC	l			; update saved above at next_sect
	LD 	a,l
	AND	3
	JR	NZ,next_sect
;
;	check list of trk-sectors for number of sectors on this trk
; 
	LD	HL,sect_buffer
	LD	(sect_buf_ptr),HL
	LD	A,(vic_drv)
	LD 	b,a
	LD	A,(fast)
	AND	b			; drive type 1571
	JR	Z,handle_1541		; no, handle as 1541

	LD	A,(sect_cnt)		; number of sectors to rd/wr
	LD 	b,a
	INC	HL
	LD 	a,(HL)			; get 1st sector #
	LD	(vic_sect),A
	DEC	HL
	LD 	a,(HL)			; get 1st track #
	LD	(vic_trk),A

try_next:
	CP	(HL)			; test for same trk #
	JR	NZ,exit_no_match
	INC	HL
	INC	HL			; advance to next trk
	LD	(sect_buf_ptr),HL
	djnz	try_next	

exit_no_match:
	LD	A,(sect_cnt)		; number of sectors to rd/wr
	sub	b			; remove number left
					; (leaving number matched)
	LD	(vic_count),A		; save number to read
	LD 	a,b			; get remaining count
	LD	(sect_cnt),A		; save remaining count
	ret


set_up_next:
	LD	A,(vic_count)		; get number of sectors read
	LD	HL,(local_DMA)		; get current DMA pointer
	ADD	A,h			; advance pointer by number of
	LD 	h,a			; sectors read
	LD	(local_DMA),HL
handle_1541:
	LD	HL,(sect_buf_ptr)
	LD 	a,(HL)
	LD	(vic_trk),A
	INC	HL
	LD 	a,(HL)
	LD	(vic_sect),A
	INC	HL
	LD	(sect_buf_ptr),HL
	LD	A,(vic_drv)
	LD 	b,a
	LD	A,(fast)
	AND	b
	JR	Z,set_up_next_slow
	LD	A,(sect_cnt)
	LD	(vic_count),A
	XOR	a			; two reads max with fast drive
	jr	set_up_next_exit

set_up_next_slow:
	LD	A,(sect_cnt)
	DEC	a
set_up_next_exit:
	LD	(sect_cnt),A
	ret
;
;
;
tst_next:
  if	use_1581
	CP	dsk_1581
	JR	Z,c1581_adj
  endif
tst_c64:
	LD 	b,dir_track	; set the dir track number
	CP	dsk_c64		; C64 type disk_
	LD	A,(@sect)		;   get sector # to set
	JR	Z,set_up_c64	; yes, go set up for C64 CP/M disk format
				; no, set up as no type(direct addressing)
;
;	This format is for direct track and sector addressing 
;
do_type_7:
	LD 	b,255		; no dir sector
;
;	this routine will adjust the track number if necessary.
;	The C64 CP/M disk has the C64 directory in the center
;	of the disk. This routine checks and adds one to the track
;	number if we have reached or passed the directory track. 
;
set_up_c64:
	LD	(VIC_sect),A	;
	LD	A,(@trk)		;
        CP     b               ; carry=1 if A < dir_track
	CCF			; add one if dir_track or more (carry not set)
	ADC	A,0		; add the carry bit in
	LD	(vic_trk),A
	ret

  if	use_1581
;
;******	adjust to read multi-512 byte sectors (system sees 1K sector size)
;
c1581_adj:
	LD 	a,2		; 2 512 byte sectors equ 1 1K sector
	LD	(vic_count),A

	LD	A,(@trk)		;
        CP     C1581_dir_trk*2 ; carry=1 if A < dir_track
	CCF			; add one if dir_track or more (carry not set)
	ADC	A,0		; add the carry bit in
	RRA			; track=0trk/2 ; carry set if odd
	LD	(vic_trk),A		;

	LD	A,(@sect)		; sector # are 0 to 9 (10 sector/trk)
	LD 	b,a		;
	JR	NC,bottom_1581	;
	ADD	A,80h		; set top of 1581
bottom_1581:
	ADD	A,b		; make 0 to 8
	INC	a		; adjust to 1 to 9 (odd numbers only)
	LD	(VIC_sect),A	;
	ret			;

  endif


	page
;
;	A=dsk_info on entry
;
set_up_MFM:
	LD 	d,0		; D=side # (0)
	LD 	e,a		; save dsk_info in E
	AND	TypeX		; look at Type0 to Type7
	JR	Z,do_type_0	;
	CP	Type2
	LD	A,(@trk)		; used by Type1, Type2 and Type3
	JR	Z,do_type_2
	JR	C,do_type_1

;	cpi	Type6
;	jrz	do_type_6
;	jnc	do_type_7	; MSB of sector(byte) set for 2nd side of disk

	CP	Type7
	JP	Z,do_type_7	; MSB of sector(byte) set for 2nd side of disk
;
;	only types 0 to 2 and 7 are currenty defined
;		Type3 to Type6 will do Type2
;do_type_3:
;do_type_6:

do_type_2:
	LD 	b,a		; save a copy in B
	SUB	40
	JR	C,do_type_0	; jump if still on side 0
	LD 	a,79		; on back side count 39,38,37,...,0
	sub	b
set_trk:
	LD 	d,80h		; D=side # (1)
	LD	(@trk),A
	jr	do_type_0

	page
;
;	divide the track number by two and if Head=1
;		add #sect/side to @sect
;
do_type_1:
	CCF			; carry was set clear it
	RRA			; divide track by 2 (carry gets LSB)
	LD	(@trk),A
	JR	NC,do_type_0
	call	get_max_num_b	; HL and C changed
	LD	A,(@sect)
	ADD	A,b
	LD	(@sect),A

do_type_0:
	LD	A,(@trk)
	LD	(vic_trk),A
	call	get_max_num_b	; B=number of sectors per track per side
	LD	A,(@sect)		; ..HL and C changed
	CP	b
	JR	C,is_side_0
	LD 	d,80h		; D=side # (1)
	bit	C1_bit,e	; dsk_info in E
				; sector numbering continues on side 1 _
	JR	NZ,is_side_0	; yes, do not remove side one bias
	sub	b		; no, remove side one bias
is_side_0:
	LD 	c,a		; hold 0sect in C	
	LD 	a,e		; get dsk_info to A
	AND	S1		; A=Starting  sector number (0 or 1)
	ADD	A,c		; add back 0sect
	OR	d		; add in the side bit
	LD	(vic_sect),A
	ret

	page
;
;	input:
;		DE = number bytes to read
;		HL = DMA address
;
	CSEG
rd_1571_data:
	LD	A,(@dbnk)			; get the disk DMA bank
	call	_bank			; set it

	LD	BC,0DC0Dh		; D1ICR
rd_1571_stat_wait:
	inp	a
	AND	8			; data ready bit set_
	JR	Z,rd_1571_stat_wait	; no, loop

	LD 	c,0ch			; D1SDR
	inp	a			; read the status byte
	LD	(vic_data),A		; save it
	AND	0eh			; any errors _
	JR	NZ,rd_1571_exit		; yes, exit

	LD	BC,0DD00h
	inp	a			; get current clock polarity

rd_1571_next:
	LD	BC,0DD00h		; D2PRA
	XOR	10h			; toggle clk_bit
	outp	a			; clock the 1571 for a byte

	DEC	e			; DE=count
	JP	NZ,rd_1571_more		; leave as normal jump to keep
	DEC	d			; the transfer speed at it's max
	JR	Z,rd_1571_exit		; ...

;
rd_1571_more:
	DEC	b
rd_1571_wait:
	LD 	c,0dh			; D1ICR (DC0Dh)
	inp	c
	bit	3,c
	JP	Z,rd_1571_wait
	LD 	c,0ch			; D1SDR
        ini                             ; (hl) <- (bc) ; hl <- hl+1 ; b <- b-1
	JP	rd_1571_next


rd_1571_exit:
	LD	(bank_0),A			; restore current mem config
	ret

	page

DEFC clk_in  =  40h 
;
;	input:
;		DE = number of bytes to write
;		HL = DMA address
;
wr_1571_data:
	call	_di_int
; do spout inline
	LD	BC,mode_reg
	LD 	a,fast_wr_en
	LD	(io_0),A
	outp	a			; set data direction to output
	LD	(bank_0),A

	LD	BC,0dc05h		; low (D1T1h)
	XOR	a
	outp	a
	DEC	c			; low(D1T1l)
	LD 	a,3			; clk = osc/3
	outp	a			;

	LD 	c,0eh			; D1CRA
	inp	a
	AND	80h
	OR	55h
	outp	a
	DEC	c			; D1ICR
	inp	a

	LD	A,(@dbnk)			; get the disk DMA bank
	call	_bank			; set it

	LD 	a,clk_in
	LD	(cur_clk),A

	page
;
;
clk_wait:
	LD	BC,0dd00h		; D2PRA
	inp	a
	inp	c			; debounce
	CP	c
	JR	NZ,clk_wait

	LD	A,(cur_clk)			; get old clk value
	XOR	c			; check if changed 
	AND	clk_in			; (only clock in bit)
	JR	Z,clk_wait		; loop if not

	LD 	a,c			; 
	LD	(cur_clk),A			; make this the current clk value
	LD	BC,0dc0ch		; D1SDR
	LD 	a,(HL)
	outp	a			; send character to drive
	INC	HL			; advance pointer
	DEC	DE			; dec the char count

	INC	c			; D1ICR
send_wait:
	inp	a
	AND	8
	JP	Z,send_wait

	LD 	a,d
	OR	e
	JP	NZ,clk_wait		; go send the next byte

; do spin
	LD	BC,0DC0Eh		; D1CRA
	inp	a
	AND	80h
	OR	8
	outp	a
	LD	BC,mode_reg
	LD 	a,fast_rd_en
	LD	(io_0),A			; enable the MMU
	outp	a			; set data direction to input
	LD	(bank_0),A			; disable MMU
; spin done

	page

	LD	BC,0DC0Dh		; D1ICR
	inp	a			; clear data pending flag

	LD	BC,0DD00h		; D2PRA
	inp	a
	OR	10h			; set clk_bit low (hardware inverted)
	outp	a			; 

	LD	BC,0DC0Dh		; D1ICR
wait_status:
	inp	a
	AND	8
	JR	Z,wait_status

	LD	BC,0DC0Ch		; D1SDR
	inp	d

	LD	BC,0DD00h		; D2PRA
	inp	a
	AND	not(10h)		; set clk_bit hi (hardware inverted)
	outp	a			; 

	LD 	a,d			; recover the status byte
	LD	(vic_data),A

	ei
	ret

	page
;
;	This routine is used to move a sector of data
;	 to/from the sector buffer and the DMA pointer.
;	     A=0 for buffer to DMA  (disk read)
;            A<>0 for DMA to buffer (disk write)
;
	CSEG
_dkmov:
	LD	HL,(local_DMA)	; current DMA adr
	LD	DE,0buffer	; location of disk read/write buffer
	LD	BC,256		; sector size
;
;
dk_cont:
	OR	a
	JR	NZ,dsk_read	; swap pointer for read
	EX	DE,HL
;
;
dsk_read:
	LD	A,(@dbnk)		; get the disk bank
	call	_bank
	ldir			; do the data move
	LD	(bank_0),A		; current bank will ALWAYS be 0
	ret

;
;
;
	DSEG
dsk_fun:
	LD	(vic_cmd),A
	LD	A,(stat_enable)
	AND	1			; display of disk info enabled_
	CALL	NZ,disp_dsk_info		; yes, go display disk info
	JP	_fun65+3		; go do the function

	page
;
;
;
	DSEG
_dskst:
disp_dsk_info:
	LD 	a,72			; r/w in col 72 (col 0-79)
	LD	(offset),A
	LD	A,(vic_cmd)
	LD 	b,'R'
	DEC	a			; _1 normal_rd
	JR	Z,out_cmd_rd
	DEC	a			; _2 normal_wr
	JR	Z,out_cmd_wr
	DEC	a			; _3 fast_rd
	JR	Z,out_cmd_rd
	DEC	a			; _4 fast_wr
	RET	NZ
out_cmd_wr:
	LD 	b,'W'
out_cmd_rd:
	call	disp_B
	call	disp_space
	LD 	b,'A'-1
	LD	A,(vic_drv)
next_drv:
	INC	b
	RRCA
	JR	NC,next_drv

	call	disp_B
	LD	A,(vic_trk)
	call	disp_dec
	LD	A,(vic_sect)
	AND	80h
	CALL	Z,disp_space
	LD 	b,'-'
	CALL	NZ,disp_B
	LD	A,(vic_sect)	
	AND	7fh

	page
;
;
;
disp_dec:
	LD 	b,'0'-1

conv_loop:
	INC	b
	SUB	10
	JR	NC,conv_loop

	ADD	A,'0'+10
	PUSH	AF
	call	disp_B
	POP	AF
disp_A:
	LD 	b,a
disp_B:
	LD	HL,0st40-72+40-8
	LD	A,(offset)
	LD 	e,a
	LD 	d,0
	ADD	HL,DE			; add the offset
	LD 	(HL),b			; save on 40 col display

	LD 	a,e
	LD 	c,a			; col # in C
	INC	a
	LD	(offset),A			; advance cursor position
	XOR	a			; no attribute to write
	call	_stat

	LD	HL,0st40
	LD	DE,vic_screen+40*24	; update 40 column screen
	LD	BC,40
	ldir
	XOR	a
	ret

disp_space:
	LD 	b,' '
	jr	disp_B

	page
;
; Extended Disk Parameter Headers (XDPHs)
;
	CSEG			; place tables in common
;
;	1st disk drive on the system
;
	DEFW	write_154X
	DEFW	read_154X
	DEFW	login_154X
	DEFW	init_154X
	DEFM	1		; bit 0 set (drive 0)
	DEFM	dsk_c128	; format type byte
cmdsk0:	
	dph	0,dpb_0

dpb_0:
	dpb	1024,5,159,2048,128,0
	DEFM	0		; max sector number and lock flag
	DEFW	0		; MFM table pointer

	page
;
;	2nd disk Drive on the system
;
	DEFW	write_154X
	DEFW	read_154X
	DEFW	login_154X
	DEFW	init_154X
	DEFM	2		; bit 1 set (drive 1)
	DEFM	dsk_c128	; format type byte 
cmdsk1:
	dph	0,dpb_1

dpb_1:
	dpb	1024,5,159,2048,128,0
	DEFM	0		; max sector number and lock flag
	DEFW	0		; MFM table pointer

	page
;
;	3rd disk drive on the system
;
	DEFW	write_154X
	DEFW	read_154X
	DEFW	login_154X
	DEFW	init_154X
	DEFM	4		; bit 2 set (drive 2)
	DEFM	dsk_c128	; format type byte
cmdsk2:	
	dph	0,dpb_2

dpb_2:
	dpb	1024,5,159,2048,128,0
	DEFM	0		; max sector number and lock flag
	DEFW	0		; MFM table pointer

	page
;
;	4th disk drive on the system
;
	DEFW	write_154X
	DEFW	read_154X
	DEFW	login_154X
	DEFW	init_154X
	DEFM	8		; bit 3 set (drive 3)
	DEFM	dsk_c128	; format type byte 
cmdsk3:
	dph	0,dpb_3

dpb_3:
	dpb	1024,5,159,2048,128,0
	DEFM	0		; max sector number and lock flag
	DEFW	0		; MFM table pointer

	page
;
;	Drive E: shared with 1st drive (A:)
;
	DEFW	write_154X
	DEFW	read_154X
	DEFW	login_154X
	DEFW	init_154X
	DEFM	1		; bit 0 set (drive 0)
	DEFM	dsk_c128	; format type byte 
cmdsk4:
	dph	0,dpb_4

dpb_4:
	dpb	1024,5,159,2048,128,0
	DEFM	0		; max sector number and lock flag
	DEFW	0		; MFM table pointer

	page
;
;	NOTE: The blocking factor for all of these formats is
;		1K (2K for double sided), thus the fractional
;		parts are unusable by CP/M.  They can be accessed
;		by absolute sector addressing.
;
;	NOTE: 1571 and 1541 disk drives use track numbers
;		of 1 to 35 and sector numbers of 0 to nn

;
;		The method used to access the full disk
;		is to tell the system that there is 1 sector
;		per track and then to use the track # as an
;		absolute sector address and do conversion in BIOS.
;
; 
; DPB FOR C128 CP/M 3.0 disk		( 170K, 34K larger then C64 CP/M)
;	256 byte sectors		( 170.75K )
;	1 sectors/track
;		up to 21 physical sectors (0 to 16,17,18 or 20)
;	680 tracks/disk (usable, 683 real)
;		35 physical tracks (0 to 34)
;	1K allocation blocks
;	64 directory entries
;	track offset of 0
;
	DSEG		; these tables are moved to common when used
dpb_c128_SS:		; (170 allocation units)
	dpb	1024,1,170,1024,64,0

	page
;
; DPB FOR C128 CP/M 3.0 double sided disk	( 340K )
;	1024 byte sectors (phy=256)		( 341.5K )	
;	1 sectors/track
;		up to 21 physical sectors (0 to 16,17,18 or 20)
;	340 tracks/disk (usable, 1366 real)
;		70 physical tracks (0 to 34 side 0, 35 to 69 side 1)
;	2K allocation units
;	128 directory entrys
;	track offset of 0
;
dpb_c128_DS:		; (170 allocation units)
	dpb	1024,1,340,2048,128,0

	page
;
; DPB FOR C64 CP/M 2.2 disk -- 			( 136K )
;	256 byte sectors
;	17 sectors / tracks	(sector numbering 0-16)
;		sector 18 to n on the outer tracks are unused
;	34 tracks / disk
;		tracks track 2 to 16    (track numbering 0-34)
;		track 17 is the C128 directory track (not counted)
;		track 19 to 34
;	1K allocation blocks
;	64 directory entrys
;	track offset of 3 (1st two tracks used for CP/M 2.2 boot) plus
;	one sector to adjust for sector numbering of 1 to 35 (not 0 to 34)
;
dpb_c64_cpm:		; (144 allocation units)
	dpb	256,17,34,1024,64,3
                
	page
;
; DPB FOR C128 CP/M 3.0 C1581 DSDD (3.5")	(    K )
;	512 byte sectors			( 720K )
;	10 sectors/track
;	159 tracks/disk
;		160 physical tracks 80 on top, 79 on bottom, 1 used for
;		BAM and disk directory (1581 DOS) (10 sectors per track)
;	2K allocation units
;	128 directory entrys (2 allocation units)
;
  if	use_1581
dpb_1581:		; (xxx allocation units)
	dpb	1024,5,159,2048,128,0
  endif

	page
;
	DSEG
MFM_table:
	DEFM	S256*2+(16*2-8)+1	; 256 byte sect, 16 sect/trk
	DEFM	MFM+S256+Type0+C0+S1	; 	DSDD
	DEFW	0			; start on track 2 sect 1 (2 alc)
	dpb	256,32,40,2048,128,2	; sect# 1 to 16
	DEFM	16			; (top and bottom numbered the same)
	DEFM	"Epson QX10"		;1 Epson QX10
					; 160 allocation units




	DEFM	80h+S512*2+(10*2-8)+1	; 512 byte sect, 10 sect/trk
;	db	S256*2			; track 0 is 256 bytes/sector
	DEFM	MFM+S512+Type0+C0+S1	;	DSDD
	DEFW	0			; start on track 2 sect 1 (2 alc)
	dpb	512,20,40,2048,128,2	; sect# 1 to 10
	DEFM	10			; (top and bottom numbered the same)
	DEFM	"Epson QX10"		;2
					; 200 allocation units

	page

	DEFM	S512*2+(8*2-8)+1	; 512 byte sect 8 sect/trk
	DEFM	MFM+S512+Type2+C0+S1	; 	SSDD
	DEFW	0			; start on track 1 sector 1 (2 alc)
	dpb	512,8,40,1024,64,1	; sect# 1 to 8
	DEFM	8			;
	DEFM	" IBM-8 SS "		;3
					; 160 allocation units




	DEFM	S512*2+(8*2-8)+1	; 512 byte sect 8 sect/trk
	DEFM	MFM+S512+Type2+C0+S1	; 	DSDD
	DEFW	0			; start on track 1 sector 1 (1 alc)
	dpb	512,8,80,2048,64,1	; sect# 1 to 8
	DEFM	8			; (top and bottom numbered the same)
	DEFM	" IBM-8 DS "		;4
					; 160 allocation units

	page

	DEFM	S512*2+(10*2-8)+0	; 512 byte sector, 10 sect/trk
	DEFM	MFM+S512+Type1+C1+S0	;	DSDD
	DEFW	0			; start on track 0 sector 10 (2 alc)
	dpb	512,10,80,2048,128,1	; sect# 0 to 9 on top (even tracks)
	DEFM	10			; sect# 10 to 19 on bottom (odd tracks)
	DEFM	"KayPro IV "		;5
					; 200 allocation units




	DEFM	S512*2+(10*2-8)+0	; 512 byte sect, 10 sect/trk
	DEFM	MFM+S512+Type0+C1+S0	; 	SSDD
	DEFW	0			; start on track 1 sector 0 (4 alc)
	dpb	512,10,40,1024,64,1	; sect# 0 to 9 
	DEFM	10			;
	DEFM	"KayPro II "		;6
					; 200 allocation units

	page

	DEFM	S1024*2+(5*2-8)+1	; 1024 byte sect, 5 sect/trk
	DEFM	MFM+S1024+Type0+C0+S1	; 	SSDD
	DEFW	0			; start on track 3 sector 1 (2 alc)
	dpb	1024,5,40,1024,64,3	; sect# 1 to 5
	DEFM	5			;
	DEFM	"Osborne DD"		;7
					; 200 allocation units


	DEFM	S512*2+(9*2-8)+1	; 512 byte sect 9 sect/track (uses 8)
	DEFM	MFM+S512+Type1+C0+S1	; 	DSDD
	DEFW	0			; start on trk 0, sect 1, hd 1 (1 alc)
	dpb	512,8,80,2048,64,1	; sect# 1 to 9
	DEFM	8			; (top and bottom numbered the same)
	DEFM	"  Slicer  "		;8
					; 160 allocation units

	page

	DEFM	S256*2+(16*2-8)+1	; 256 byte sect, 16 sect/trk
	DEFM	MFM+S256+Type0+C0+S1	; 	DSDD
	DEFW	0			; start on track 4 sect 1 (2 alc)
	dpb	256,32,40,2048,128,4	; sect# 1 to 16
	DEFM	16			; (top and bottom numbered the same)
	DEFM	"Epson Euro"		;9 Epson European (MFCP/M _)
					; 160 allocation units



	DEFM	-1
	DEFM	MFM			; 
	DEFW	0			; 
	dpb	512,20,40,2048,128,2	; 
	DEFM	8			;
	DEFM	"   None   "		;10

	page

	DEFM	-1
	DEFM	MFM			; 
	DEFW	0			; 
	dpb	512,20,40,2048,128,2	; 
	DEFM	8			;
	DEFM	"   None   "		;11

	DEFM	-1
	DEFM	MFM			; 
	DEFW	0			; 
	dpb	512,20,40,2048,128,2	; 
	DEFM	8			;
	DEFM	"   None   "		;12

	page

	DEFM	-1
	DEFM	MFM			; 
	DEFW	0			; 
	dpb	512,20,40,2048,128,2	; 
	DEFM	8			;
	DEFM	"   None   "		;13

	DEFM	-1
	DEFM	MFM			; 
	DEFW	0			; 
	dpb	512,20,40,2048,128,2	; 
	DEFM	8			;
	DEFM	"   None   "		;14

	page

	DEFM	-1
	DEFM	MFM			; 
	DEFW	0			; 
	dpb	512,20,40,2048,128,2	; 
	DEFM	8			;
	DEFM	"   None   "		;15

	DEFM	-1
	DEFM	MFM			; 
	DEFW	0			; 
	dpb	512,20,40,2048,128,2	; 
	DEFM	8			;
	DEFM	"   None   "		;16


	page
;
;	not functional yet
;

;	db	S1024*2+(5*2-8)+1	; 1024 byte sect 5 sect/track
;	db	MFM+S1024+Type0+C0+S1	; 	SSDD
;	dw	0			; start on trk 2, sect 1 (2 alc)
;	dpb	1024,5,40,2048,128,2	; sect# 1 to 5
;	db	5			;
;	db	'Morrow MD2'		; 





;	db	S1024*2+(5*2-8)+1	; 1024 byte sect  5 sect/trk
;	db	MFM+S1024+Type0+C0+S1	; 	DSDD
;	dw	0			; start on trk 1, sect 1, hd 0 (3 alc)
;	dpb	1024,10,40,2048,192,1	; sect# 1 to 5
;	db	5			;
;	db	'Morrow MD3'		; 


DEFC MFM_tbl_entries  =  (_-MFM_table)/32 

	DEFM	-1			; mark end of table
	DEFM	-1

	page

	cseg
cur_clk:	DEFS	1

	dseg
lock_flag	DEFS	1
last_match	DEFS	2
window_info:	DEFS	2

DEFC dsk_window  =  12 

no_dsk_msg:
		;1234567890
	DEFM	" Missing  " 


MFM_match_tbl:
	DEFS	2*MFM_tbl_entries	; MFM_count MUST follow this parm
MFM_count:
	DEFS	1			; MFM_offset MUST follow this parm
MFM_offset:
	DEFS	1

MFM_cur_ptr:
	DEFS	2

DPH_pointer:
	DEFS	2

sect_cnt:
	DEFS	1
sect_buf_ptr:
	DEFS	2
sect_buffer:
	DEFS	4*2

local_DMA:
	DEFS	2

DEFC status_atr  =  0 
offset:		DEFM	0

	end

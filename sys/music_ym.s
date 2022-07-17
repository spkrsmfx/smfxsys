
;(96)6 blocks in, 42 lines
;(256)-> 10 blocks, 166 end --> 124 lines
;;;;;;; YM SHIT
; Atari ST/e synclock demosystem
; January 6, 2008
;
; ym.s
;
; Playback of YM3 files created by various YM-recorders.
; Uses no interupt and not so much CPU.
; About 42k register data per minute music.


ym14:		incbin	'sys/motus.ym'
	even
ym14ptr:	dc.l	ym14

ym14_play:
	move.l	ym14ptr,a0			; source
	lea.l	$ffff8800.w,a1	
	lea.l	$ffff8802.w,a2	

	clr.b	(a1)					;reg 0										;4
	move.b	(a0)+,(a2)				;											;4
	move.b	#1,(a1)					;reg 1										;4
	move.b	(a0)+,(a2)				;											;6

	;2-6
	moveq.l	#2,d2					;											;1
	REPT 5
	move.b	d2,(a1)																;3
	move.b	(a0)+,(a2)															;6
	addq.b	#1,d2																;1
	ENDR

	;7
	move.b	d2,(a1)					;7											;3
	move.b	(a1),d6					;get old reg								;2
	and.b	#%11000000,d6			;erase soundbits, save i/o					;2
	move.b	(a0)+,d7				;get reg7 from dumpfile						;4
	and.b	#%00111111,d7			;erase i/o									;2
	or.b	d6,d7					;or io to regdata							;1
	move.b	d2,(a1)					;7											;3
	move.b	d7,(a2)					;store										;3

	;8
	moveq.l	#8,d2					;8-12
	REPT 5
	move.b	d2,(a1)
	move.b	(a0)+,(a2)
	addq.b	#1,d2																;1
	ENDR

	;13
	cmp.b	#$ff,(a0)
	beq		.skip
		move.b	d2,(a1)					;
		move.b	(a0)+,(a2)				;
		move.l	a0,ym14ptr
		rts
.skip
	addq.w	#1,a0
	move.l	a0,ym14ptr
	rts
	

parse_ym
	move.b	#0,$ffffc123
	move.l	#ym_regdump+4,ym_reg_file_adr
	move.l	#ym_regdump_end-ym_regdump-4,d0
	divu.w	#14,d0
	move.l	d0,ym_length

	lea		ym_regdump,a0		; source
	lea		target,a1
	move.w	d0,d7
	subq.w	#1,d7
.loop
		moveq	#0,d1
		move.b	(a0),(a1)+
		REPT 13
		add.l	d0,d1
		move.b	(a0,d1.l),(a1)+
		ENDR	
		addq.w	#1,a0
	dbra	d7,.loop

	lea		target,a0
	move.l	#264982,d0
	move.b	#0,$ffffc123

target:	
	ds.b	264982



ym_regdump
	incbin	'sys/motus.ym'
ym_regdump_end
	even

music_ym_init:
		move.l	#ym_regdump+4,ym_reg_file_adr
		move.l	#ym_regdump_end-ym_regdump-4,d0
		divu.w	#14,d0
		move.l	d0,ym_length
		clr.l	ym_counter
;		move.l	#200,ym_counter

		move.l	ym_reg_file_adr,a0
		lea		40(a0),a0
		move.l	a0,ym_reg_file_adr

		move.w	#40,music_wait

		rts		
music_wait	dc.w	40

music_ym_play:
	rts
	subq.w	#1,music_wait
	bge		.no
		move.l	ym_reg_file_adr,a0													;4
		lea.l	14(a0),a0															;2
		
		lea.l	$ffff8800.w,a1														;2
		lea.l	$ffff8802.w,a2														;2

		lea.l	ym_counter,a3														;2

		move.l	(a3),d0																;3
		add.l	#32,d0																;4
		move.l	ym_length,d1														;4
		cmp.l	d0,d1
;		cmp.l	#5770,d0
;		ble.s	.ok																	;2
		bgt.s	.ok
			move.w	#1000,music_wait
			clr.l	(a3)

.ok:	
		add.l	(a3),a0					;correct pos								;4
		addq.l	#1,(a3)					;next pos									;5

		move.l	ym_length,d0				;length of each regdump					;4
		move.l	d0,d1																;1

		clr.b	(a1)					;reg 0										;4
		move.b	(a0),(a2)				;											;4

		move.b	#1,(a1)					;reg 1										;4
		move.b	(a0,d1.l),(a2)				;										;6
		

		moveq.l	#2,d2					;2-6										;1
		moveq.l	#5-1,d7																;1
.loop:		
		add.l	d0,d1																;2
		move.b	d2,(a1)																;3
		move.b	(a0,d1.l),(a2)														;6
		addq.b	#1,d2																;1
		dbra	d7,.loop															;3/4

		move.b	d2,(a1)					;7											;3
		move.b	(a1),d6					;get old reg								;2
		and.b	#%11000000,d6				;erase soundbits, save i/o				;2
		add.l	d0,d1					;next register in dumpfile					;2
		move.b	(a0,d1.l),d7				;get reg7 from dumpfile					;4
		and.b	#%00111111,d7				;erase i/o								;2
		or.b	d6,d7					;or io to regdata							;1
		move.b	d2,(a1)					;7											;3
		move.b	d7,(a2)					;store										;3


		moveq.l	#8,d2					;8-12
		moveq.l	#5-1,d7
.loop2:		
		add.l	d0,d1
		move.b	d2,(a1)
		move.b	(a0,d1.l),(a2)
		addq.b	#1,d2
		dbra	d7,.loop2

		add.l	d0,d1					;reg 13
		cmp.b	#$ff,(a0,d1.l)				;
		beq.s	.no13					;
		move.b	d2,(a1)					;
		move.b	(a0,d1.l),(a2)				;
.no13:

.no:		rts						;


music_ym_exit:	
		lea.l	$ffff8800.w,a0				;exit player
		lea.l	$ffff8802.w,a1
		move.b	#8,(a0)
		clr.b	(a1)
		move.b	#9,(a0)
		clr.b	(a1)
		move.b	#10,(a0)
		clr.b	(a1)
		rts


ym_counter:	dc.l	0
ym_length:	dc.l	0
ym_reg_file_adr:dc.l	0
TIMER_A_PATCH	equ 1
TIMER_D_PATCH	equ 1



	clr.l	-(sp)				;super()
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp

	bclr	#0,$484					;Set keyclick off
	move.b	#$12,$fffffc02.w		;Kill mouse

	move.w	#$2700,sr
	lea		dummy_rte,a1
	move.l	a1,$68.w				;HBL
	move.l	a1,$70.w				;VBL
	move.l	a1,$110.w				;T-D
	move.l	a1,$114.w				;T-C
	move.l	a1,$118.w				;ACIA
	move.l	a1,$120.w				;T-B		
	move.l	a1,$134.w				;T-A
	clr.b	$fffffa07.w				;MFP interrupt Enable A (Timer-A & B)
	clr.b	$fffffa09.w				;MFP interrupt Enable B (Timer D)
	clr.b	$fffffa13.w				;MFP interrupt Mask A (Timer-A & B)
	clr.b	$fffffa15.w				;MFP interrupt Mask B (Timer D)
	clr.b	$fffffa19.w				;Timer-A control (stop) ADDED 20190401
	clr.b	$fffffa1b.w				;Timer-B control (stop) ADDED 20190401
	bclr	#3,$fffffa17.w			;MFP automatic end of interrupt
	bset	#5,$fffffa07.w			;Interrupt enable A (Timer-A)
	bset	#5,$fffffa13.w			;Interrupt mask A	

	move.w	#$2300,sr

;	jsr		parse_ym
;	jsr		sndh

	move.w	#$2700,sr
	move.l	#vbl,$70
	move.w	#$2300,sr


.mainloop



	jmp	.mainloop

DUMP_YM	equ 1

vbl:
	movem.l	d0-a6,-(sp)
	IFEQ	DUMP_YM
	jsr		sndh+8
	tst.w	.first
	bne		.skip
		move.b	#0,$ffffc123
		move.w	#-1,.first
.skip
	ELSE
	jsr		ym14_play
	ENDC


	movem.l	(sp)+,d0-a6
	rte
.first	dc.w	0

music
sndh	incbin	'sys/motus.snd'
musicEnd


;;; ---- DUNMP REPLAY CODE
ym14ptr	dc.l	ym14

ym14	incbin	'msx/motus.ym14'


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
		jmp		.end
.skip
	addq.w	#1,a0
	move.l	a0,ym14ptr
.end

	
	rts



;;;----- DUMPING CODE

ym_regdump	incbin	'msx/motus.ym'
ym_regdump_end

parse_ym
;	move.l	#ym_regdump+4,ym_reg_file_adr
	move.l	#ym_regdump_end-ym_regdump-4,d0
	divu.w	#14,d0
	move.l	d0,ym_length

	lea		ym_regdump,a0		; source
	add.w	#4,a0
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
	move.l	ym_length,d0
	muls	#14,d0
	move.l	#276630-4,d1
	move.b	#0,$ffffc123
	rts
ym_length	dc.l	0
target:	
	ds.b	276630-4


dummy_rte:	rte

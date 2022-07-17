

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

	
	sub.l	#1,.counter
	bgt		.ok
		move.l	#(ym14end-ym14)/14,.counter
		move.l	#ym14,ym14ptr
.ok

	rts
.counter	dc.l	(ym14end-ym14)/14

ym14ptr dc.l	ym14

ym14:	
	incbin	'sys/motus.ym14'
ym14end


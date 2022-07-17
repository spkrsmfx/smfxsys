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
	jmp		musicEnd
music
sndh	incbin	'sys/motus.snd'
musicEnd

	jsr		sndh

	lea		siddump,a0
	lea		$14800,a1
;	move.b	#0,$ffffc123
	move.w	#256/4-1,d7
.l
	move.l	(a0)+,(a1)+
	dbra	d7,.l

	move.w	#$2700,sr
	move.l	#vbl,$70
	move.w	#$2300,sr


.mainloop



	jmp	.mainloop

DUMP_YM	equ 1

vbl:
	movem.l	d0-a6,-(sp)

	jsr		ym14_play
	jsr		timerTest

	movem.l	(sp)+,d0-a6
	rte

siddump	incbin	'msx/siddump.bin'

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

TDV	equ	%1
TDC	equ	%10
TDD	equ	%100
TDE	equ	%1000
TDM	equ	%10000

timerTest
	move.l	timerDumpPtr,a0				; timer data

	move.w	(a0)+,d0					; get TD_WRITES,d0
	bne		.doTimers
.noTimers
		move.w	#0,$ffff8240
		add.w	#10,a0					; SKIP OTHER 10 BYTES
		move.l	a0,timerDumpPtr			; NEXT PTR
		rts
.doTimers								; handle stuff
;VECTOR
	move.w	#$030,$ffff8240
	move.w	d0,d1
	and.w	#TDV,d1
	beq		.noTDV
		move.l	(a0),$110.w				; set vector
.noTDV
	add.w	#4,a0						; next

; CONTROL
	move.w	d0,d1
	and.w	#TDC,d1
	beq		.noTDC
		;	0:		andi.b	#$f0,$fffffa1d.w
		;	1:		move.b	DATA,$fffffa1d.w		+DATA
		;	2:		andi.b	#$f0,$fffffa1d.w
		;			ori.b	$1,$fffffa1d.w	
		tst.b	(a0)					; CHECK OP
		beq		.op0
.op1or2
		cmp.b	#1,(a0)
		beq		.op1
.op2
		andi.b	#$f0,$fffffa1d.w
		ori.b	#$1,$fffffa1d.w	
		jmp		.noTDC
.op1
		move.b	1(a0),$fffffa1d.w
		jmp		.noTDC
.op0
		andi.b	#$f0,$fffffa1d.w
.noTDC
	add.w	#2,a0						; next

; DATA
	move.w	d0,d1
	and.w	#TDD,d1
	beq		.noTDD
		move.b	(a0),$fffffa25.w
.noTDD
	add.w	#1,a0

;ENABLE
	move.w	d0,d1
	and.w	#TDE,d1
	beq		.noTDE
	; td_enable:
	;	0:		bset	#4,$fffffa09.w			; enable
	;	1:		bclr	#$4,$fffffa09.w			; disable
	tst.b	(a0)
	beq		.enable0
.enable1
		bclr	#$4,$fffffa09.w	
		jmp		.noTDE
.enable0
		bset	#4,$fffffa09.w
.noTDE
	add.w	#1,a0

;MASK
	move.w	d0,d1
	and.w	#TDM,d1
	beq		.noTDM
	; td_mask:
	;	0:		bset	#4,$fffffa15.w			; enable
	;	1:		bclr	#4,$fffffa15.w			; disable
		tst.b	(a0)
		beq		.mask0
.mask1
			bclr	#4,$fffffa15.w
			jmp		.noTDM
.mask0
			bset	#4,$fffffa15.w
.noTDM
	add.w	#2,a0					;+1=12
	jmp		.end

.noWrite
	add.w	#12,a0
.end
	move.l	a0,timerDumpPtr
	rts



timerDumpPtr	dc.l	timerDump
timerDump	incbin	'msx/motus.tmr'


dummy_rte:	rte

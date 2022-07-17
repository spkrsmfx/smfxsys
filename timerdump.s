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

;	jsr		setFalconCookie
	jsr		sndh

	jsr		redirectTimerD

;	jsr		sndh

	move.w	#$2700,sr
	move.l	#vbl,$70
	move.w	#$2300,sr


.mainloop



	jmp	.mainloop


vbl:
	movem.l	d0-a6,-(sp)
	jsr		sndh+8
;	jsr		timerTest


MYM_TD_OFF	equ 0
	
	IFEQ	MYM_TD_OFF
	jsr		vectorTest
	ENDC

	movem.l	(sp)+,d0-a6
	rte


dummy_rte:	rte


;TDV	equ	%1
;TDC	equ	%10
;TDD	equ	%100
;TDE	equ	%1000
;TDM	equ	%10000


; so how are we going to dumpt he format:
;	TD_WRITES;		dc.w
;	TD_VECTOR:		dc.l	
;	TD_CONTROL:		dc.b	for OP
;					dc.b	for DATA
;	TD_DATA:		dc.b	for DATA
;	TD_ENABLE		dc.b	for OP
;	TD_MASK			dc.b	for OP
;		PADDING 	dc.b	

; so naively:
;	2+4+6 = 12 bytes per frame

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
	move.w	#0,TD_WRITES
	add.w	#12,a0
.end
	move.l	a0,timerDumpPtr
	rts



timerDumpPtr	dc.l	timerDump
timerDump	incbin	'msx/motus.tmr'

vectorDump	ds.b	240000
vectorDumpPtr	dc.l	vectorDump

vectorTest
	move.l	vectorDumpPtr,a6

	move.w	TD_WRITES,$ffff8240
;	move.w	#0,$ffff8240

	tst.w	TD_WRITES
	beq		.noWrite
;		move.w	
;		move.w	#$7,$ffff8240


		; if we get here , we do have TD
		; so lets see what we got
		move.w	TD_WRITES,d0	; and now we will handle it
		move.w	d0,(a6)+		;+2=2
; VECTOR
		move.w	d0,d1
		and.w	#TDV,d1
		beq		.noTDV
			move.l	TD_VECTOR,$110.w
.noTDV
		move.l	TD_VECTOR,(a6)+	;+4=6
; CONTROL
		move.w	d0,d1
		and.w	#TDC,d1
		beq		.noTDC
		; td_control:
		;	0:		andi.b	#$f0,$fffffa1d.w
		;	1:		move.b	DATA,$fffffa1d.w		+DATA
		;	2:		andi.b	#$f0,$fffffa1d.w
		;			ori.b	$1,$fffffa1d.w	
			tst.b	TD_CONTROL_OP
			beq		.op0
.op1or2
			cmp.b	#1,TD_CONTROL_OP
			beq		.op1
.op2
			andi.b	#$f0,$fffffa1d.w
			ori.b	#$1,$fffffa1d.w	
			jmp		.noTDC
.op1
			move.b	TD_CONTROL_DATA,$fffffa1d.w
			jmp		.noTDC
.op0
			andi.b	#$f0,$fffffa1d.w
			jmp		.noTDC
.noTDC
		move.b	TD_CONTROL_OP,(a6)+		;+1=7
		move.b	TD_CONTROL_DATA,(a6)+	;+1=8
; DATA
		move.w	d0,d1
		and.w	#TDD,d1
		beq		.noTDD
			move.b	TD_DATA_DATA,TD_DATA
.noTDD
		move.b	TD_DATA_DATA,(a6)+		;+1=9

;ENABLE
		move.w	d0,d1
		and.w	#TDE,d1
		beq		.noTDE
		; td_enable:
		;	0:		bset	#4,$fffffa09.w			; enable
		;	1:		bclr	#$4,$fffffa09.w			; disable
			tst.b	TD_ENABLE_OP
			beq		.enable0
.enable1
			bclr	#$4,$fffffa09.w	
			jmp		.noTDE
.enable0
			bset	#4,$fffffa09.w
.noTDE
		move.b	TD_ENABLE_OP,(a6)+		;+1=10

;MASK
		move.w	d0,d1
		and.w	#TDM,d1
		beq		.noTDM
		; td_mask:
		;	0:		bset	#4,$fffffa15.w			; enable
		;	1:		bclr	#4,$fffffa15.w			; disable
			tst.b	TD_MASK_OP
			beq		.mask0
.mask1
			bclr	#4,$fffffa15.w
			jmp		.noTDM
.mask0
			bset	#4,$fffffa15.w
.noTDM
		move.b	TD_MASK_OP,(a6)+		;+1=11
		add.w	#1,a6					;+1=12
	move.w	#0,TD_WRITES
	jmp		.end

.noWrite
	move.w	#0,TD_WRITES
	add.w	#12,a6
.end
	move.l	a6,vectorDumpPtr
	subq.w	#1,.times
	bge		.ll
		lea		vectorDump,a0
		move.l	#240000,d0
		move.b	#0,$ffffc123
.ll		
	rts
.times	dc.w	5000





mymPatch:

;-------------------- START MYM  SPECIFIC PATCH -----------------
;-------------------- START MYM  SPECIFIC PATCH -----------------
;-------------------- START MYM  SPECIFIC PATCH -----------------


TD_WRITES			dc.w	0
TDV	equ	%1
TDC	equ	%10
TDD	equ	%100
TDE	equ	%1000
TDM	equ	%10000

TD_VECTOR_WRITE		dc.w	0
TD_VECTOR			dc.l	0

TD_CONTROL			equ $ffffa1d
TD_CONTROL_OP		dc.b	0
TD_CONTROL_DATA		dc.b	0
; td_control:
;	0:		andi.b	#$f0,$fffffa1d.w

;	1:		move.b	DATA,$fffffa1d.w		+DATA

;	2:		andi.b	#$f0,$fffffa1d.w
;			ori.b	$1,$fffffa1d.w	

TD_DATA				equ	$fffffa25
TD_DATA_DATA		ds.b	0
	even

TD_ENABLE			equ	$fffffa09
TD_ENABLE_OP		dc.b	0
	even
; td_enable:
;	0:		bset	#4,$fffffa09.w			; enable
;	1:		bclr	#$4,$fffffa09.w			; disable

TD_MASK				equ	$fffffa15
TD_MASK_OP			dc.b	0
	even
; td_mask:
;	0:		bset	#4,$fffffa15.w			; enable
;	1:		bclr	#4,$fffffa15.w			; disable


;1st:
	dc.l	0



setupTimer
	add.l	#4,a7
	IFNE	MYM_TD_OFF
	move.l	a1,$110.w				; vector		
	ENDC
	move.l	a1,TD_VECTOR
	or.w	#TDV,TD_WRITES

	IFNE	MYM_TD_OFF
	andi.b	#$f0,TD_CONTROL		; control			stop
	ENDC
	move.b	#0,TD_CONTROL_OP
	or.w	#TDC,TD_WRITES

	IFNE	MYM_TD_OFF
	clr.b	TD_DATA			; data				set 256
	ENDC
	move.b	#0,TD_DATA_DATA
	or.w	#TDD,TD_WRITES

	IFNE	MYM_TD_OFF
	bset	#4,TD_ENABLE		; enable			enable timer d
	ENDC
	move.b	#0,TD_ENABLE_OP
	or.w	#TDE,TD_WRITES

	IFNE	MYM_TD_OFF
	bset	#4,TD_MASK			; mask				enable interrupt
	ENDC
	move.b	#0,TD_MASK_OP
	or.w	#TDM,TD_WRITES
	move	(sp)+,sr
	move.l	(sp)+,a1
	rts

	dc.l	1
setupTimerDepends
	add.l	#4,a7

	IFNE	MYM_TD_OFF
	move.l	(a1),$110.w
	ENDC
	or.w	#TDV,TD_WRITES
	move.l	(a1)+,TD_VECTOR

	move.b	$fffffa1d.w,d0
	andi.b	#$f0,d0
	or.b	(a1)+,d0
	IFNE	MYM_TD_OFF
	move.b	d0,TD_CONTROL
	ENDC
	or.w	#TDC,TD_WRITES
	move.w	#1,TD_CONTROL_OP		; 	move.b	d0,$fffffa1d.w
	move.b	d0,TD_CONTROL_DATA

	IFNE	MYM_TD_OFF
	move.b	(a1),TD_DATA
	ENDC
	or.w	#TDD,TD_WRITES
	move.b	(a1)+,TD_DATA_DATA
	tst.b	(a1)+
	beq		.l
		IFNE	MYM_TD_OFF
		bset	#$4,TD_ENABLE
		ENDC
		or.w	#TDE,TD_WRITES
		move.b	#0,TD_ENABLE_OP
		jmp		.ln
.l
		IFNE	MYM_TD_OFF
		bclr	#$4,TD_ENABLE
		ENDC
		or.w	#TDE,TD_WRITES
		move.b	#1,TD_ENABLE_OP
.ln
	tst.b	(a1)+
	beq		.k
		IFNE	MYM_TD_OFF
		bset	#$4,TD_MASK
		ENDC
		or.w	#TDM,TD_WRITES
		move.b	#0,TD_MASK_OP
		jmp		.kn
.k
		IFNE	MYM_TD_OFF
		bclr	#$4,TD_MASK
		ENDC
		or.w	#TDM,TD_WRITES
		move.b	#1,TD_MASK_OP
.kn
	clr.b	(a1)+
	clr.b	(a1)+
	move	(sp)+,sr
	movem.l	(sp)+,d0/a1
	rts

	dc.l	2


someInlineShitCode1
	move.l	(a7)+,a2			; this is where we come from
	move.l	a3,-(a7)			; save d7
	move.l	a2,a3				; free a2

	; now we need to add some magic
	add.l	#$3624,a3
;	move.l	#$123456,$110.w
	IFNE	MYM_TD_OFF
	move.l	(a3),$110.w
	ENDC
	or.w	#TDV,TD_WRITES
	move.l	(a3),TD_VECTOR


	sub.l	#$3624,a3
	add.l	#$36bc,a3
	move.l	a3,a2
	sub.l	#$36bc,a3

	move.l	a5,(a2)
	move.b	d1,9(a2)
	subq.w	#2,d1
	bge		.tt
		moveq	#0,d1
.tt
	move.b	d1,29(a2)

	add.l	#$f72b,a3
	move.l	a3,a2
;	lea		$1234(pc),a2
	sub.l	#$f72b,a3
	move.b	#$d,(a2)
	IFNE	MYM_TD_OFF
	andi.b	#$f0,TD_CONTROL
	ori.b	#$1,TD_CONTROL
	ENDC
	or.w	#TDC,TD_WRITES
	move.b	#2,TD_CONTROL_OP

	IFNE	MYM_TD_OFF
	move.b	$115(a4),TD_DATA
	ENDC
	or.w	#TDD,TD_WRITES
	move.b	$115(a4),TD_DATA_DATA

	st		$13b(a4)
	IFNE	MYM_TD_OFF
	bset	#$4,TD_MASK
	ENDC
	or.w	#TDM,TD_WRITES
	move.b	#0,TD_MASK_OP

	; restore return address to 
	add.l	#64,d7
	move.l	d7,a2
	move.l	(sp)+,d7
	jmp		(a2)


;$110		TD_VECTOR
;$fffffa09	TD_ENABLE
;$fffffa15	TD_MASK
;$fffffa25	TD_DATA
;$fffffa1d	TD_CONTROL

someInlineShitCode2New
	move.l	(a7)+,haxsmc
	tst.b	$113(a4)			;-->115f4
	beq		.a
		tst.b	$132(a4)
		beq		.b					;-->1160e
.a	
	cmpi.b	#5,(a2)				;115f4
	beq		.c					;-->11604
		move.b	#5,(a2)
		move.l	a0,-(a7)
		move.l	haxsmc,a0
		add.l	#$2fc2+22,a0
		IFNE	MYM_TD_OFF
		move.l	(a0),$110.w
		ENDC
		; state machine
		or.w	#TDV,TD_WRITES
		move.l	(a0),TD_VECTOR

		move.l	(a7)+,a0
.c								;11604
	IFNE	MYM_TD_OFF
	move.b	d0,TD_CONTROL
	move.b	d3,TD_DATA
	ENDC

	; state machine
	or.w	#TDC,TD_WRITES
	move.b	#1,TD_CONTROL_OP
	move.b	d0,TD_CONTROL_DATA
	or.w	#TDD,TD_WRITES
	move.b	d3,TD_DATA_DATA


	bra		.d					;-->11628
.b
	move.b	#5,(a2)				;1160e
	move.l	a0,-(a7)
	move.l	haxsmc,a0
	add.l	#$2fae+22,a0
	IFNE	MYM_TD_OFF
	move.l	(a0),$110.w
	ENDC
	;state machine
	or.w	#TDV,TD_WRITES
	move.l	(a0),TD_VECTOR

	move.l	(a7)+,a0

	IFNE	MYM_TD_OFF
	clr.b	TD_CONTROL
	clr.b	TD_DATA
	move.b	d0,TD_CONTROL
	move.b	d3,TD_DATA
	ENDC

	; state machine
	or.w	#TDC,TD_WRITES
	move.b	#1,TD_CONTROL_OP
	move.b	d0,TD_CONTROL_DATA

	or.w	#TDD,TD_WRITES
	move.b	d3,TD_DATA_DATA

.d
	IFNE	MYM_TD_OFF
	bset	#4,TD_MASK		;11628
	ENDC
	;state machine
	or.w	#TDM,TD_WRITES
	move.b	#0,TD_MASK_OP			; bset 4
	move	d2,sr
smcjmp
	jmp		$11736
haxsmc	dc.l	0



;----
;$110		TD_VECTOR
;$fffffa09	TD_ENABLE
;$fffffa15	TD_MASK
;$fffffa25	TD_DATA
;$fffffa1d	TD_CONTROL
someInlineShitCode3New
	move.b	#0,$ffffc123
	move.l	(a7)+,haxsmc2
	tst.b	$113(a4)			;-->115f4
	beq		.a
		tst.b	$132(a4)
		beq		.b					;-->1160e
.a	
	cmpi.b	#$b,(a2)				;115f4
	beq		.c					;-->11604
		move.b	#5,(a2)
		move.l	a0,-(a7)
		move.l	haxsmc2,a0
		add.l	#$2fc2+22,a0
		IFNE	MYM_TD_OFF
		move.l	(a0),$110.w
		ENDC
		;state machine
		or.w	#TDV,TD_WRITES
		move.l	(a0),TD_VECTOR
		move.l	(a7)+,a0
;		move.l	$145c2,$110.w
.c								;11604
	IFNE	MYM_TD_OFF
	move.b	d1,$fffffa1d.w		;control
	move.b	d3,$fffffa25.w		;data
	ENDC
	;state machine
	or.w	#TDC,TD_WRITES
	move.b	#1,TD_CONTROL_OP
	move.b	d1,TD_CONTROL_DATA
	or.w	#TDD,TD_WRITES
	move.b	d3,TD_DATA_DATA

	bra		.d					;-->11628
.b
	move.b	#$b,(a2)				;1160e
	move.l	a0,-(a7)
	move.l	haxsmc2,a0
	add.l	#$2fae+22,a0
	IFNE	MYM_TD_OFF
	move.l	(a0),$110.w
	ENDC
	;state machine
	or.w	#TDV,TD_WRITES
	move.l	(a0),TD_VECTOR
	move.l	(a7)+,a0

	IFNE	MYM_TD_OFF
	clr.b	$fffffa1d.w
	clr.b	$fffffa25.w
	move.b	d1,$fffffa1d.w
	move.b	d3,$fffffa25.w
	ENDC
	;state machine
	or.w	#TDC,TD_WRITES
	move.b	#1,TD_CONTROL_OP
	move.b	d1,TD_CONTROL_DATA
	or.w	#TDD,TD_WRITES
	move.b	d3,TD_DATA_DATA

.d
	IFNE	MYM_TD_OFF
	bset	#4,TD_MASK		;11628
	ENDC
	;state machine
	or.w	#TDM,TD_WRITES
	move.b	#0,TD_MASK_OP			; bset 4

	move	d2,sr
smcjmp2
	jmp		$11736
haxsmc2	dc.l	0



redirectTimerD
	move.w	#$110,d0				; search
	lea		.list,a2


	lea		music,a0				; start of mym binary
	lea		musicEnd,a1				; end of mym binary
	move.w	#11,d6					; its 8 entries we want to patch
.find		
		cmp.l	a0,a1				; check for end of file
		ble		.end
		move.w	(a0)+,d7			; get next word
		cmp.w	d0,d7				; check if word is the same as the address we're looking for
		bne		.find				; if not, continue
			tst.w	(a2)+
			bne		.next
				lea		-4(a0),a6
				move.l	(a2)+,a4
				jsr		(a4)
.next
			dbra	d6,.find		; find next
.end
	rts
.smc_jmp	jmp	$1234567
.p			pea	0(pc)
.r1
		move.l	.p,(a6)+
		move.w	.smc_jmp,(a6)+
		move.l	(a2)+,(a6)+
		rts	
.r2
		lea		-2(a6),a6
		move.l	.p,(a6)+
		move.w	.smc_jmp,(a6)+
		move.l	(a2)+,(a6)+
		rts	
.r3new
		lea		-24(a6),a6
		move.l	.p,(a6)+
		move.w	.smc_jmp,(a6)+
		move.l	(a2)+,(a6)+
		add.l	#324,a6
		move.l	a6,smcjmp+2
		rts	

.r4new	
		lea		-24(a6),a6
		move.l	.p,(a6)+
		move.w	.smc_jmp,(a6)+
		move.l	(a2)+,(a6)+
		add.l	#66,a6
		move.l	a6,smcjmp2+2
		rts	


.list
	dc.w	1
	dc.w	1

	dc.w	0
		dc.l	.r1
		dc.l	setupTimer

	dc.w	0
		dc.l	.r1
		dc.l	setupTimerDepends

	dc.w	1								; need
	dc.w	1

	dc.w	0
		dc.l	.r3new
		dc.l	someInlineShitCode2New

	dc.w	1

	dc.w	0
		dc.l	.r4new
		dc.l	someInlineShitCode3New		; falcon?
	dc.w	1

	dc.w	1
	dc.w	1
	dc.w	1
	dc.w	1
	dc.w	1
	dc.w	1
	dc.w	1
	dc.w	1
	dc.w	1
	dc.w	1
	dc.w	1
	dc.w	1
	dc.w	1
	dc.w	1
	dc.w	1
	dc.w	1




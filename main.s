ORGADD 			EQU $600
DO_MONO 		EQU 0
USE_YM14		EQU 0
YM14_PACKED		EQU 1

DO_YM14_PARSE 	equ 1
MALLOC			equ 0

	jmp	reloc
code:					; this is the start of the code, for code copy
	ORG ORGADD
start:					; entry point of the code
	jsr		initShit		
;demosys start
	move.w	#$2700,sr
	move.l	#vbl,$70
	move.w	#$2300,sr

	IFEQ	DO_YM14_PARSE
		jsr		parse_ym
	ENDC

;============== Mainloop ===============================
mainloop:	lea	vblcount(pc),a0
.wait:		tst.w	(a0)
		beq.s	.wait
		clr.w	(a0)

		move.l	mainrout(pc),a0
		jsr	(a0)

		jmp		mainloop

;============== 50 Hz VBL ==============================
vbl:		
		movem.l	d0-a6,-(sp)
		addq.w	#1,vblcount
		;Sequencer
		lea	scriptaddr(pc),a4
		move.l	(a4),a0
		subq.l	#1,(a0)
		bne.s	.noswitch
		lea	28(a0),a0
		move.l	a0,(a4)
.noswitch:	lea	tarout(pc),a4
		move.b	7(a0),$fffffa1f.w		;Timer A data
		move.b	11(a0),$fffffa19.w		;Timer A pre-div
		movem.l	12(a0),a0-a3			;A0=TA, A1=VBL1, A2=VBL2, A3=Main
		movem.l	a0-a3,(a4)

		;Run VBL1 routine
		jsr	(a1)

		; play music
		IFEQ	USE_YM14
		jsr		ym14_play
		ELSE
		jsr		sndh_play
		ENDC

		;Run VBL2 routine
		move.l	vblrout2(pc),a0
		jsr	(a0)


.noexit:	movem.l	(sp)+,d0-a6
		rte

dummy		rts
scriptaddr:	dc.l	demoscript			;Don't reorder the demosystem variables
tarout:		dc.l	dummy
vblrout:	dc.l	dummy
vblrout2:	dc.l	dummy
mainrout:	dc.l	dummy
vblcount:	dc.w	0
counter		dc.l	0
		even


;============== Demoscript =============================
demoscript:	;dc.l	VBLs,TA-data,TA-prediv,TimerArout,VBLrout1 (before music),VBLrout2 (after music),Mainrout

		dc.l	5,0,0,dummy,dummy,dummy,music_start
		dc.l	-1,0,0,dummy,dummy,dummy,dummy



		dc.l	-1

;============== Demoscript End =============================
	IFEQ	USE_YM14
		IFEQ	YM14_PACKED
			include	'sys/ym14replay.s'			; ym14 packed replayer	
		ELSE
			include	'sys/ym14.s'
		ENDC
	ELSE
		include	'sys/sndh.s'
		IFEQ	MALLOC
		include	'sys/malloc.s'
		ENDC
	ENDC

	IFEQ	DO_YM14_PARSE
		include	'sys/music_ym.s'
	ENDC
	include	'sys/unzx0.s'				;


music_start
	IFEQ	USE_YM14
		IFEQ	YM14_PACKED
			jsr	ym14_depack
		ENDIF
	ELSE
	jsr		sndh_init
	ENDC
	rts



;============== Fast clear, even 256-byte chunks =======
;in:	a0.l	pointer to memory
;	d0.l	bytes to clear (even by 256 bytes)
fast_clear:
		add.l	d0,a0				;End of buffer
		lsr.l	#8,d0				;Don't loop lower 8bit
		subq.l	#1,d0

		moveq	#0,d1
		move.l	d1,d2
		move.l	d1,d3
		move.l	d1,d4
		move.l	d1,d5
		move.l	d1,d6
		move.l	d1,d7
		move.l	d1,a1
		move.l	d1,a2
		move.l	d1,a3
		move.l	d1,a4
		move.l	d1,a5
		move.l	d1,a6

.loop:		movem.l	d1-d7/a1-a6,-(a0)		;52 bytes
		movem.l	d1-d7/a1-a6,-(a0)		;104 bytes
		movem.l	d1-d7/a1-a6,-(a0)		;156 bytes
		movem.l	d1-d7/a1-a6,-(a0)		;208 bytes
		movem.l	d1-d7/a1-a5,-(a0)		;256 bytes
		dbra	d0,.loop
		rts

;----------- FREE MEMORY BELOW ----------
memBase:				; this is the start of memory free

dummy_rte:				rte


initShit:					; this does base initiatlizeation of the system
	bclr	#0,$484					;Set keyclick off
	move.b	#$12,$fffffc02.w		;Kill mouse

	move.w	#$2700,sr
	lea		dummy_rte,a1
	move.l	a1,$70.w				;VBL
	move.l	a1,$68.w				;HBL
	move.l	a1,$134.w				;T-A
	move.l	a1,$120.w				;T-B		
	move.l	a1,$114.w				;T-C
	move.l	a1,$110.w				;T-D
	move.l	a1,$118.w				;ACIA
	clr.b	$fffffa07.w				;MFP interrupt Enable A (Timer-A & B)
	clr.b	$fffffa13.w				;MFP interrupt Mask A (Timer-A & B)
	clr.b	$fffffa09.w				;MFP interrupt Enable B (Timer D)
	clr.b	$fffffa15.w				;MFP interrupt Mask B (Timer D)
	clr.b	$fffffa19.w				;Timer-A control (stop) ADDED 20190401
	clr.b	$fffffa1b.w				;Timer-B control (stop) ADDED 20190401
	bclr	#3,$fffffa17.w			;MFP automatic end of interrupt
	bset	#5,$fffffa07.w			;Interrupt enable A (Timer-A)
	bset	#5,$fffffa13.w			;Interrupt mask A	

	move.w	#$2300,sr

	rts


end:	




		section text
reloc:
		clr.l	-(sp)				;super()
		move.w	#32,-(sp)
		trap	#1
		addq.l	#6,sp
; then inerrupts
		move.w	#$2700,sr		; shut down interrupts	
; then copy
		lea		code,a0		; start
		lea		ORGADD,a1		; target
		move.l	#(end-start)/4/4/4/4,d7
.l
		REPT 64
			move.l	(a0)+,(a1)+
		ENDR
		dbra	d7,.l
		move.l	#ORGADD,a7			; stack
		jmp		ORGADD
; then jump
		end
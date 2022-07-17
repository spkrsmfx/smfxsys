
		section	text



trucolor_init:
		;a0 = codebuf
		;a1 = screen address
		;a2 = List of pal addresses (can be modified!)
		;d0 = number of lines
		;d1 = colour to leave the background after tb
		;d2 ADDED = address of subroutine to run after code

		move.l	a0,pTCCode
		move.l	a0,tcd+2
		move.l	a1,a6
		move.l	a2,pTCListAdrs
		move.w	d0,d6
		move.w	d0,d7
		move.w	d1,trucolor_bgc+2
		move.l	d2,pTCAfterCode

		; generate code
		move.l	#.tc_draw_line,d0
		move.l	#.r,d1
		jsr	global_copy_code

		move.w	#$4e71,-2(a0)
		lea	trucolor_bgc,a1
		move.l	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		move.w	.r,(a0)+
		move.l	a0,pTCCodeEnd

		; draw stripes in fullscreen
		move.l	a6,a0
		;adda.w	#(160*121),a0
		lea	tcdith,a1

		move.w	d6,d7
		subq	#1,d7
.cpy:		movem.l	(a1)+,d0-d6/a2-a4
		movem.l	d0-d6/a2-a4,(a0)
		movem.l	(a1)+,d0-d6/a2-a4
		movem.l	d0-d6/a2-a4,40(a0)
		movem.l	d0-d6/a2-a4,80(a0)
		movem.l	d0-d6/a2-a4,120(a0)
		movem.l	d0-d6/a2-a4,160(a0)
		movem.l	(a1)+,d0-d1
		movem.l	d0-d1,200(a0)
		
		lea	230(a0),a0

		cmp.l	#pTCListAdrs,a1
		bne.s	.skip
		lea	tcdith,a1

.skip:		dbf	d7,.cpy

		rts

.tc_draw_line:
		move.b	d7,$ffff8260.w			;3 Left border
		move.w	d7,$ffff8260.w			;3

		move.l	(a1)+,a0		;3

		;dcb.w	88-85,$4e71
		move.l	(a6)+,(a2)
		move.l	(a6)+,(a3)
		move.l	(a6)+,(a4)
		move.l	(a6)+,(a5)
		move.l	(a6)+,(a2)
		move.l	(a6)+,(a3)
		move.l	(a6)+,(a4)
		move.l	(a6)+,(a5)
		move.l	(a6)+,(a2)
		move.l	(a6)+,(a3)
		move.l	(a6)+,(a4)
		move.l	(a6)+,(a5)
		move.l	(a6)+,(a2)
		move.l	(a6)+,(a3)
		move.l	(a6)+,(a4)
		move.l	(a6)+,(a5)
		move.l	(a6)+,(a2)

		move.w	d7,$ffff820a.w			;3 Right border
		move.b	d7,$ffff820a.w			;3

		move.w	(a6),(a3)	;3
		move.l	a0,a6
		move.l	(a6)+,d0	;3
		move.l	(a6)+,d1	;3

		dcb.w	11-10,$4e71


		move.b	d7,$ffff8260.w			;3 Stabilizer
		move.w	d7,$ffff8260.w			;3

		move.l	d0,(a3)
		move.l	d1,(a4)
		move.l	(a6)+,(a5)
.r:		rts

trucolor_bgc:	move.w	#0,$ffff8240.w
		

;-------------- TIMER B HBL ----------------------------
trucolor_timerB:
		movem.l	d0-d1/d7/a0-a6,-(a7) ; 2+ 2*10=22

		move.w	#$2700,sr
		clr.b	$fffffa1b.w	; ADDED

		moveq	#0,d0
.sync:		move.b	$ffff8209.w,d0
		cmp.b	$ffff8209.w,d0
		beq.s	.sync
	
		move.b	$ffff8209.w,d0
		not.w	d0
		lsr.w	d0,d0

		moveq	#2,d7

		move.l	pTCListAdrs,a1	;5
		lea	$ffff8242.w,a2	;2
		lea	4(a2),a3	;2
		lea	4(a3),a4	;2
		lea	4(a4),a5	;2
		move.l	(a1)+,a6	;3

;		lea	testpal,a6	;3
;		move.l	a6,a0		;1

		move.l	(a6)+,(a3)	;5
		move.l	(a6)+,(a4)	;5
		move.l	(a6)+,(a5)	;5

		dcb.w	69-31,$4e71

tcd:		jsr	tcd

		tst.l	pTCAfterCode
		beq.s	.end

			move.l	pTCAfterCode,a0
			jsr	(a0)

.end:		addq.w	#1,tccount
		movem.l	(a7)+,d0-d1/d7/a0-a6
		rte




		section	data

tcdith:		incbin	'sys\dithtc.4pl'
pTCListAdrs:	dc.l	0
pTCCode:	dc.l	0
pTCCodeEnd:	dc.l	0
pTCAfterCode:	dc.l	0
tccount:	dc.w	0

		section	text
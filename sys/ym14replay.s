OLDYM	equ 1

ym14_depack:	
	lea		ym14packed,a0
	lea		ym14,a1
	jsr		lz4_frame_depack
	move.w	#$4e75,ym14_depack
	rts

ym14_play:
	cmp.w	#$4e75,ym14_depack
	bne		.exit
	jsr		lz4_depack

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

	
	sub.w	#1,.counter
	bgt		.ok
		move.w	#512,.counter
		move.l	#ym14,ym14ptr
.ok

	sub.l	#14,lz4read
	sub.w	#1,.duration
	bge		.okx
		move.w	#$4e75,ym14_play
		move.l	#$08000000,$ffff8800.w
		move.l	#$09000000,$ffff8800.w
		move.l	#$0a000000,$ffff8800.w

.okx
.exit
	rts
	IFEQ	OLDYM

.counter	dc.w	512-180
.duration	dc.w	18000-100-20
ym14packed:	
	incbin	'sys/motus.ym14.lz4'
ym14:		ds.b	7*1024	;	incbin	'sys/hatari.ym14'
	even
ym14ptr:	dc.l	ym14+180*14
lz4read		dc.l	-180*14


	ELSE
.counter	dc.w	512-180
.duration	dc.w	7300+2100-100-20
ym14packed:	
	incbin	'sys/tune21.ym14.lz4'
ym14:		ds.b	7*1024	;	incbin	'sys/hatari.ym14'
	even
ym14ptr:	dc.l	ym14+180*14
lz4read		dc.l	-180*14
	ENDIF



lz4_frame_depack:
		cmpi.l	#$04224d18,(a0)+	; LZ4 frame MagicNb
;		bne.s	lz4_frame_error

		move.b	(a0),d0
		andi.b	#%11001001,d0		; check version, no depacked size, and no DictID
		cmpi.b	#%01000000,d0
;		bne.s	lz4_frame_error

		; read 32bits block size without movep (little endian)
		move.b	6(a0),d0
		lsl.w	#8,d0
		move.b	5(a0),d0
		swap	d0
		move.b	4(a0),d0
		lsl.w	#8,d0
		move.b	3(a0),d0
		lea		7(a0),a0			; skip LZ4 block header + packed data size
		movem.l	d0-a6,lz4state

lz4_depack:
		cmp.l	#140,lz4read
		blt		.kkk
			rts
.kkk

		movem.l	lz4state,d0-a6
		tst.w	lz4_started
		beq		.first
			tst.w	lz4break
			bgt		.gocheck
			blt		.gocheck2
			move.b	#0,$ffffc123
			nop
.first
		move.w	#-1,lz4_started

			lea		0(a0,d0.l),a4	; packed buffer end
			moveq	#0,d0
			moveq	#0,d2
			moveq	#15,d4

.tokenLoop:	move.b	(a0)+,d0
			move.l	d0,d1
			lsr.b	#4,d1
			beq.s	.lenOffset

			bsr.s	.readLen

.litcopy:	move.b	(a0)+,(a1)+



			addq.l	#1,lz4read
.gocheck:
			cmp.l	#140,lz4read
			blt		.gogo
				move.w	#1,lz4break
				movem.l	d0-a6,lz4state
				rts
.gogo

			subq.l	#1,d1			; block could be > 64KiB
			bne.s	.litcopy

			; end test is always done just after literals
			cmpa.l	a0,a4
			beq.s	.blockEnd
			
.lenOffset:	move.b	(a0)+,d2	; read 16bits offset, little endian, unaligned
			move.b	(a0)+,-(a7)
			move.w	(a7)+,d1
			move.b	d2,d1
			movea.l	a1,a3
			sub.l	d1,a3		; d1 bits 31..16 are always 0 here
			moveq	#$f,d1
			and.w	d0,d1

			bsr.s	.readLen

			addq.l	#4,d1
.copy:		move.b	(a3)+,(a1)+

			addq.l	#1,lz4read
.gocheck2:
			cmp.l	#140,lz4read
			blt		.gogo2
				move.w	#-1,lz4break
				movem.l	d0-a6,lz4state
				rts
.gogo2

			subq.l	#1,d1
			bne.s	.copy
			bra.s	.tokenLoop

.readLen:	
			cmp.b	d1,d4
			bne.s	.readEnd
.readLoop:	move.b	(a0)+,d2
			add.l	d2,d1				; final len could be > 64KiB
.okx
			not.b	d2
			beq.s	.readLoop
.readEnd:	
			rts
.blockEnd
			move.w	#0,lz4_started

		move.b	3(a0),d0
		lsl.w	#8,d0
		move.b	2(a0),d0
		swap	d0
		move.b	1(a0),d0
		lsl.w	#8,d0
		move.b	(a0),d0		
		lea		4(a0),a0
		lea		ym14,a1
		movem.l	d0-a6,lz4state
		jmp		lz4_depack
;			move.l	#ym14,a1

			rts
.hax		dc.w	0

lz4state	ds.b	64
lz4_started	dc.w	0
lz4break	dc.w	0
srback		dc.w	0
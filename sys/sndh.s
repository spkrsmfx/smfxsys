; Synclock demosystem for ST/STe
;
; sndh.s
; 50 Hz songs without timer effects
;
; ae@dhs.nu

;		section	text

;============== Initialise the SNDH player =============
sndh_init:
		tst.b	sndh_doplay
		bne		.end
		IFEQ	MALLOC
			move.l  #malloc_trap_vector,$84.w
		ENDIF

		clr.b	sndh_doplay

		moveq	#1,d0
		move.l	sndh_addr,a0
		move.b	#0,$ffffc123
		jsr		(a0)
		move.b	#0,$ffffc123

		move.l	#$08000000,$ffff8800.w
		move.l	#$09000000,$ffff8800.w
		move.l	#$0a000000,$ffff8800.w
		jsr		sndh_enable_play
.end
		rts

;============== SNDH 50 Hz interrupt player ============
sndh_play:	
			tst.b	sndh_doplay
		beq.s	.noplay
		move.l	sndh_addr,a0
		jsr	8(a0)
.noplay:	rts
.herp	dc.w	0
;============== Deinitalise SNDH player ================
sndh_exit:
		clr.b	sndh_doplay

		move.l	sndh_addr,a0
		jsr	4(a0)

		move.l	#$08000000,$ffff8800.w
		move.l	#$09000000,$ffff8800.w
		move.l	#$0a000000,$ffff8800.w
		rts

;============== Enable interrupt player ================
sndh_enable_play:
		move.b	#1,sndh_doplay
		rts

;============== Disable interrupt player ===============
sndh_disable_play:
		clr.w	sndh_doplay
		move.l	#$08000000,$ffff8800.w
		move.l	#$09000000,$ffff8800.w
		move.l	#$0a000000,$ffff8800.w
		rts


sndh_play_tc:	
		tst.b	sndh_doplay
		beq.s	.noplay
		sub.w	#50,.sndhwait
;		lea		.sndhwait(pc),a0
;		move.w	sndh_freq,d0
;		sub.w	d0,(a0)
		bpl.s	.noplay
		add.w	#200,.sndhwait	;(a0)
		movem.l	d0-a6,-(sp)
		move.l	sndh_addr,a0
		jsr	8(a0)
		movem.l	(sp)+,d0-a6
.noplay:	rts
.sndhwait:	dc.w	10

;		section	data

sndh_freq:		dc.w	50				;1-200 Hz

sndh_addr:	dc.l	sndh_file

sndh_file:	
	incbin	'sys/motus.snd'
;	incbin	'sys/tune21.snd'
		even
sndh_doplay:	dc.b	0				;0 = Don't call player
		even


;		section	text

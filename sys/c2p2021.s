;;;;;;;;;;;;;
;; NEW c2p routs!
;; includes superfast 1:1........
;; 30.8.2021 - added subpixel source image generation
;; by TOM!


		section	text
		opt o-
;;;;;;;;;;;;;
;; conversion routs

; a1 = 4pl data
; a2 = chunky buffer
; d7 = num pix
c2p_to_chunky:				; thnx spkr

		lsr.w	#4,d7
		subq.w	#1,d7
		;move.w	#320*200/16-1,d7

.bl:
		movem.w	(a1)+,d0-d3	; each plane in a word
		moveq	#16-1,d5
.pr:
		moveq	#0,d4
		roxl.w	d3
		roxl.w	d4
		roxl.w	d2
		roxl.w	d4
		roxl.w	d1
		roxl.w	d4
		roxl.w	d0
		roxl.w	d4

		move.b	d4,(a2)+

		dbf	d5,.pr
		dbf	d7,.bl

		rts

; a1 = 4pl data
; a2 = chunky buffer
; d7 = num pix
c2p_to_chunky_lm:			

		lsr.w	#4,d7
		subq.w	#1,d7

.bl:
		movem.w	(a1)+,d0-d3	; each plane in a word
		moveq	#16-1,d5
.pr:
			moveq	#0,d4
			roxl.w	d3
			roxl.w	d4
			roxl.w	d2
			roxl.w	d4
			roxl.w	d1
			roxl.w	d4
			roxl.w	d0
			roxl.w	d4

			addq.b	#1,d4
			add.b	d4,d4
			add.b	d4,d4

			move.b	d4,(a2)+
			dbf	d5,.pr
	
		dbf	d7,.bl
		rts


; a1 = screen data (top left)
; a2 = chunky buffer
; d0.w = x pixels width
; d1.w = y pixels height
c2p_scrn_to_chunky:

		move.l	a1,a3

		lsr.w	#4,d0
		subq.w	#1,d0
		move.w	d0,a4		; xcount

		move.w	d1,d7
		subq.w	#1,d7		; ycount

.yloop:
		move.l	a3,a1
		move.w	a4,d6
.xloop:
			movem.w	(a1)+,d0-d3	; each plane in a word
			moveq	#16-1,d5
.pr:
				moveq	#0,d4
				roxl.w	d3
				roxl.w	d4
				roxl.w	d2
				roxl.w	d4
				roxl.w	d1
				roxl.w	d4
				roxl.w	d0
				roxl.w	d4

				move.b	d4,(a2)+
				dbf	d5,.pr
			dbf	d6,.xloop
		
		lea	160(a3),a3
		dbf	d7,.yloop

		rts


; a1 = screen data (top left)
; a2 = chunky buffer
; d0.w = x pixels width
; d1.w = y pixels height
c2p_scrn_to_chunky_lm:

		move.l	a1,a3

		lsr.w	#4,d0
		subq.w	#1,d0
		move.w	d0,a4		; xcount

		move.w	d1,d7
		subq.w	#1,d7		; ycount

.yloop:
		move.l	a3,a1
		move.w	a4,d6
.xloop:
			movem.w	(a1)+,d0-d3	; each plane in a word
			moveq	#16-1,d5
.pr:
				moveq	#0,d4
				roxl.w	d3
				roxl.w	d4
				roxl.w	d2
				roxl.w	d4
				roxl.w	d1
				roxl.w	d4
				roxl.w	d0
				roxl.w	d4

				addq.b	#1,d4
				add.b	d4,d4
				add.b	d4,d4

				move.b	d4,(a2)+
				dbf	d5,.pr

			dbf	d6,.xloop
		
		lea	160(a3),a3
		dbf	d7,.yloop

		rts


;a1 = c2p buffer
;d7 = total number of chunky pix
c2p_lm_to_superfast:

		move.l	#$00000202,d0
		move.l	#$3c3c3e3e,d1
		lsr.w	#3,d7
		subq.w	#1,d7

.al:			add.l	d0,(a1)+
			add.l	d1,(a1)+
			dbf	d7,.al

		rts


c2p_clear_lmbuf:
		lsr.w	#4,d7
		subq.w	#1,d7

		move.l	#$04040404,d0

.clrloop:		move.l	d0,(a1)+
			move.l	d0,(a1)+
			move.l	d0,(a1)+
			move.l	d0,(a1)+
			dbf	d7,.clrloop

		rts


;a1 = c2p buffer
;d7 = total number of chunky pix
c2p_clear_sfbuf:
		lsr.w	#4,d7
		subq.w	#1,d7

		move.l	#$04040404,d0
		move.l	#$06060606,d1
		move.l	#$40404040,d2
		move.l	#$42424242,d3

.clrloop:		move.l	d0,(a1)+
			move.l	d1,(a1)+
			move.l	d2,(a1)+
			move.l	d3,(a1)+
			dbf	d7,.clrloop

		rts


;a0 = c2p buffer (Ws not Bs!)
;a1 = chunky image buffer
;d7 = number of pixels
c2p_chunk_to_w:
		moveq	#0,d0
		moveq	#4,d1
		subq.w	#1,d7

.convloop:		move.b	(a1)+,d0
			add.b	d0,d0
			add.b	d1,d0
			move.b	d0,(a0)
			lea	2(a0),a0

			dbf	d7,.convloop

		rts

;--------------------------------------------------------------
; 1:1 routines

** generate 1:1 c2p masks
** a0 = output buffer

c2p_gen_1to1_masks:

		lea	c2pmask,a1
		moveq	#64-1,d7

.c2ptl:		move.b	(a1)+,d0
A		SET	0
		REPT	8
		move.b	d0,A(a0)
		lsr.b	#1,d0
A		SET	A+64
		ENDR
		lea	1(a0),a0
		dbf	d7,.c2ptl

		rts



c2p_gen_2to1_masks_w:

		movem.l	c2pmask_w,d0-d3
		moveq	#4-1,d7
.c2pcl:			movem.l	d0-d3,(a0)
			lea	16(a0),a0
			lsr.l	#2,d0
			lsr.l	#2,d1
			lsr.l	#2,d2
			lsr.l	#2,d3
			dbf	d7,.c2pcl

		rts




** generate pairs of pixels for 1:1 c2p
** 15 colours only to fit in lm
** a0 = 1:1 table
** a2 = address of POINTER to first c2p table!
** a1-a4 = output tables

c2p_gen_1to1_table_lm:

		;move.l	pC2PMasks,a0		
		lea	64(a0),a1		; a1= table for 2nd pix
		;lea	c2ptables_sf,a2

		moveq	#4-1,d7			; loop for each table

.tl:		move.w	(a2)+,a3		; a3 = next table
		move.l	a0,a4			; a4 = work p for 1st pix
		moveq	#15-1,d6		; 1st pix loop

.1pl:			move.l	(a4)+,d0		; d0 = get first pix
			move.l	a1,a5			; a5 = work p for 2nd pix
			moveq	#15-1,d5		; 2nd pix loop

.2pl:				move.l	d0,d1			; d1 = copy of first pix		
				or.l	(a5)+,d1		; or in 2nd pix
				move.l	d1,(a3)+		; store in table
				dbf	d5,.2pl			; loop for each 2nd pix

			adda.w	#$400-60,a3		; move to next line of table
			dbf	d6,.1pl			; loop for each 1st pix

		lea	128(a0),a0		; move to next pair of pixels
		lea	128(a1),a1	
		dbf	d7,.tl

		rts


c2p_gen_2to1_table_lm_w:
;a0 = masks table

		moveq	#2-1,d7
		move.w	#$404,a3

.ml:		lea	16(a0),a1		; a1= table for 2nd pix
		move.l	a0,a4			; a4 = work p for 1st pix
		moveq	#8-1,d6		; 1st pix loop

.1pl:		move.w	(a4)+,d0		; d0 = get first pix
		move.l	a1,a5			; a5 = work p for 2nd pix
		moveq	#8-1,d5		; 2nd pix loop

.2pl:			move.w	d0,d1			; d1 = copy of first pix		
			or.w	(a5)+,d1		; or in 2nd pix
			move.w	d1,(a3)+		; store in table
			dbf	d5,.2pl			; loop for each 2nd pix

		adda.w	#$200-16,a3		; move to next line of table
		dbf	d6,.1pl			; loop for each 1st pix	

		lea	32(a0),a0
		move.w	#$6404,a3
		dbf	d7,.ml

		rts


;a0 = codebuffer
;d0.w = width
;d1.w = height
c2p_generate_1to1_drawcode:

		lsr.w	#3,d0
		subq.w	#1,d0
		move.w	d0,a5		; xloop

		move.w	d1,d7
		subq.w	#1,d7

		;load registers
		lea	.code(PC),a1
		move.l	(a1)+,d0
		move.l	d0,d1
		move.w	(a1)+,d1
		move.l	d1,d2
		move.l	d2,d3
		move.l	(a1),d4

		move.w	#0,a6			; a6 = running ycount

.yloop:			move.w	a6,d4
			move.l	#$00070001,d5		; d5 = swap addition
			move.w	a5,d6

.xloop:				movem.l	d0-d4,(a0)
				lea	20(a0),a0

				add.w	d5,d4
				swap	d5
				dbf	d6,.xloop

			adda.w	#160,a6
			dbf	d7,.yloop

		move.w	.r,(a0)+
.r:		rts
		

.code:		move.w	(a1)+,a2		; fetch pixel 0
		move.l	(a2),d5			; d5 = first pixel moved in
		or.l	(a2),d5			; combine with pixel 0
		movep.l	d5,$1234(a0)		; put to screen - 8p done



;------------------
c2p_generate_2to1_subpix_images:

; a0 = chunky image (input)
; a1-a4 = destination tables
; d6 = pixel width of input
; d7 = pixel height of input

		lea	c2pmask,a5
		moveq	#0,d0
		moveq	#0,d4

		subq.w	#2,d6
		subq.w	#1,d7

.yloop:			move.w	d6,d5

			move.b	(a0),d4
			add.b	d4,d4
			add.b	d4,d4

.xloop:
				move.b	(a0)+,d0
				add.b	d0,d0
				add.b	d0,d0

				move.l	(a5,d0.w),d1
				move.l	d1,d2
				lsr.l	#1,d2
				or.l	d1,d2

				move.l	d2,(a1)+
				lsr.l	#2,d2
				move.l	d2,(a2)+
				lsr.l	#2,d2
				move.l	d2,(a3)+
				lsr.l	#2,d2
				move.l	d2,(a4)+

				move.b	(a0),d0
				add.b	d0,d0
				add.b	d0,d0
				move.l	(a5,d0.w),d2
				lsr.l	#1,d2
				or.l	d1,d2

				move.l	d2,(a1)+
				lsr.l	#2,d2
				move.l	d2,(a2)+
				lsr.l	#2,d2
				move.l	d2,(a3)+
				lsr.l	#2,d2
				move.l	d2,(a4)+
				
				dbf	d5,.xloop		

			move.b	(a0)+,d0
			add.b	d0,d0
			add.b	d0,d0

			move.l	(a5,d0.w),d1
			move.l	d1,d2
			lsr.l	#1,d2
			or.l	d1,d2

			move.l	d2,(a1)+
			lsr.l	#2,d2
			move.l	d2,(a2)+
			lsr.l	#2,d2
			move.l	d2,(a3)+
			lsr.l	#2,d2
			move.l	d2,(a4)+

			move.l	(a5,d4.w),d2
			lsr.l	#1,d2
			or.l	d1,d2

			move.l	d2,(a1)+
			lsr.l	#2,d2
			move.l	d2,(a2)+
			lsr.l	#2,d2
			move.l	d2,(a3)+
			lsr.l	#2,d2
			move.l	d2,(a4)+
			
			dbf	d7,.yloop

		rts



; d0 = word aligned buffer
c2p_generate_opt_4to1_2pl:

		lea	.c2pmask1(pc),a0
		clr.w	d0

		moveq	#4-1,d7
.m1loop:		move.w	(a0)+,d1
			lea	.c2pmask2(pc),a1
			moveq	#4-1,d6

.m2loop:			move.w	d1,d2
				or.w	(a1)+,d2

				lea	.c2pmask1(pc),a2
				move.l	d0,a4
				moveq	#4-1,d5

.m3loop:				lea	.c2pmask2(pc),a3
					moveq	#4-1,d4

.m4loop:					move.w	(a2),d3
						or.w	(a3)+,d3

						movep.w	d2,0(a4)
						movep.w	d3,1(a4)
						addq.l	#4,a4
						
						dbf	d4,.m4loop
					addq.l	#2,a2
					dbf	d5,.m3loop

				addi.w	#$400,d0
				dbf	d6,.m2loop
			dbf	d7,.m1loop

		rts


.c2pmask1:	dc.b	%00000000,%00000000
		dc.b	%11110000,%00000000
		dc.b	%00000000,%11110000
		dc.b	%11110000,%11110000
.c2pmask2:	dc.b	%00000000,%00000000
		dc.b	%00001111,%00000000
		dc.b	%00000000,%00001111
		dc.b	%00001111,%00001111

; a0 = input
; a1 = tab1 output
; a2 = tab2 output
; d7 = #pix
c2p_generate_opt_4to1_2pl_img:

		lea	.adrs(pc),a6
		moveq	#0,d0
		subq.w	#1,d7

.loop:			move.b	(a0)+,d0
			add.w	d0,d0
			move.w	(a6,d0.w),(a1)+
			move.w	8(a6,d0.w),(a2)+
			dbf	d7,.loop
			
		rts

.adrs:		dc.w	$0000,$1000,$2000,$3000
		dc.w	$0000,$0400,$0800,$0c00


;--------------------------------------------------------------

		section	data

c2pmask:	dc.b	%00000000,%00000000,%00000000,%00000000 ; 0
		dc.b	%10000000,%00000000,%00000000,%00000000 ; 1
		dc.b	%00000000,%10000000,%00000000,%00000000 ; 2
		dc.b	%10000000,%10000000,%00000000,%00000000 ; 3
		dc.b	%00000000,%00000000,%10000000,%00000000 ; 4
		dc.b	%10000000,%00000000,%10000000,%00000000 ; 5
		dc.b	%00000000,%10000000,%10000000,%00000000 ; 6
		dc.b	%10000000,%10000000,%10000000,%00000000 ; 7
		dc.b	%00000000,%00000000,%00000000,%10000000 ; 8
		dc.b	%10000000,%00000000,%00000000,%10000000 ; 9
		dc.b	%00000000,%10000000,%00000000,%10000000 ; 10
		dc.b	%10000000,%10000000,%00000000,%10000000 ; 11
		dc.b	%00000000,%00000000,%10000000,%10000000 ; 12
		dc.b	%10000000,%00000000,%10000000,%10000000 ; 13
		dc.b	%00000000,%10000000,%10000000,%10000000 ; 14
		dc.b	%10000000,%10000000,%10000000,%10000000 ; 15

c2ptables_sf:	dc.w	$404,$606,$4040,$4242

c2pmask_w:	dc.b	%00000000,%00000000		;0 - BG
		dc.b	%10000000,%00000000		;1
		dc.b	%00000000,%10000000		;2
		dc.b	%10000000,%10000000		;3
		dc.b	%01000000,%00000000		;4
		dc.b	%00000000,%01000000		;5
		dc.b	%01000000,%01000000		;6
		dc.b	%00000000,%00000000		;7 - BG/safety


		section	text
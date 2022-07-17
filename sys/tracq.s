; Hack to patch away MFP and vector writes from Tra.CQ replayer
; 2020-03-20

		section	text

tracq_hack_it:
		lea		sndh_file,a0
;in	a0	address to unpacked Tra.CQ SNDH
		lea	tracq_patchofs,a1
		move.w	#$4e71,d1

.loop:
		move.w	(a1)+,d0
		beq.s	.done

		move.l	a0,a2
		add.w	d0,a2

		move.w	(a1)+,d0
		lsr.w	#1,d0
		subq.w	#1,d0
.copy:
		move.w	d1,(a2)+
		dbra	d0,.copy
		bra.s	.loop

.done:		rts

		section	data

tracq_patchofs:

;0076:	lea	$000015E0(pc),a0	      ; 40772 1568	     A��h
;007A:	move.l	a0,$0134.w		      ; 20710 0134	     !��4
;007E:	lea	$00001628(pc),a0	      ; 40772 15A8	     A���
;0082:	move.l	a0,$0110.w		      ; 20710 0110	     !���
;0086:	lea	$FFFFFA00.w,a0		      ; 40770 FA00	     A���
;008A:	clr.b	$0005(a0)		      ; 41050 0005	     B(��
;008E:	ori.b	#$20,$0007(a0)		      ; 00050 00200007	     �(� ��
;0094:	ori.b	#$10,$0009(a0)		      ; 00050 00100009	     �(����
;009A:	ori.b	#$20,$0013(a0)		      ; 00050 00200013	     �(� ��
;00A0:	ori.b	#$10,$0015(a0)		      ; 00050 00100015	     �(����
;00A6:	andi.b	#$DF,$000B(a0)		      ; 01050 00DF000B	     �(����
;00AC:	andi.b	#$EF,$000D(a0)		      ; 01050 00EF000D	     �(����
;00B2:	andi.b	#$DF,$000F(a0)		      ; 01050 00DF000F	     �(����
;00B8:	andi.b	#$EF,$0011(a0)		      ; 01050 00EF0011	     �(����
;00BE:	move.b	#$40,$0017(a0)		      ; 10574 00400017	     �|�@��
;00C4:	clr.b	$0019(a0)		      ; 41050 0019	     B(��
;00C8:	andi.b	#$F8,$001D(a0)		      ; 01050 00F8001D	     �(����
;00CE:	clr.b	$001F(a0)		      ; 41050 001F	     B(��
;00D2:	clr.b	$0025(a0)		      ; 41050 0025	     B(�%
		dc.w	$76,$5c+2+2

;00E0:	lea	$0000015E(pc),a0	      ; 40772 007C	     A��|
;00E4:	move.l	a0,$0134.w		      ; 20710 0134	     !��4
;00E8:	lea	$0000015E(pc),a0	      ; 40772 0074	     A��t
;00EC:	move.l	a0,$0110.w		      ; 20710 0110	     !���
;00F0:	lea	$FFFFFA00.w,a0		      ; 40770 FA00	     A���
;00F4:	clr.b	$0005(a0)		      ; 41050 0005	     B(��
;00F8:	andi.b	#$1F,$0007(a0)		      ; 01050 001F0007	     �(����
;00FE:	andi.b	#$0F,$0009(a0)		      ; 01050 000F0009	     �(����
;0104:	andi.b	#$1F,$0013(a0)		      ; 01050 001F0013	     �(����
;010A:	andi.b	#$0F,$0015(a0)		      ; 01050 000F0015	     �(����
;0110:	andi.b	#$DF,$000B(a0)		      ; 01050 00DF000B	     �(����
;0116:	andi.b	#$EF,$000D(a0)		      ; 01050 00EF000D	     �(����
;011C:	andi.b	#$DF,$000F(a0)		      ; 01050 00DF000F	     �(����
;0122:	andi.b	#$EF,$0011(a0)		      ; 01050 00EF0011	     �(����
;0128:	clr.b	$0019(a0)		      ; 41050 0019	     B(��
;012C:	andi.b	#$F8,$001D(a0)		      ; 01050 00F8001D	     �(����
;0132:	clr.b	$001F(a0)		      ; 41050 001F	     B(��
;0136:	clr.b	$0025(a0)		      ; 41050 0025	     B(�%
		dc.w	$e0,$56+2+2

;01EA:	andi.b	#$F0,$FFFFFA1D.w	      ; 01070 00F0FA1D	     �8����
;020C:	clr.b	$FFFFFA19.w		      ; 41070 FA19	     B8��
;076C:	andi.b	#$F0,$FFFFFA1D.w	      ; 01070 00F0FA1D	     �8����
;077C:	clr.b	$FFFFFA19.w		      ; 41070 FA19	     B8��
;0792:	andi.b	#$F0,$FFFFFA1D.w	      ; 01070 00F0FA1D	     �8����
;079A:	clr.b	$FFFFFA19.w		      ; 41070 FA19	     B8��
;07C2:	move.l	a5,$0110.w		      ; 20715 0110	     !���
		dc.w	$1ea,6
		dc.w	$20c,4
		dc.w	$76c,6
		dc.w	$77c,4
		dc.w	$792,6
		dc.w	$79a,4
		dc.w	$7c2,4

;07F8:	andi.b	#$F0,$FFFFFA1D.w	      ; 01070 00F0FA1D	     �8����
;07FE:	or.b	d1,$FFFFFA1D.w		      ; 81470 FA1D	     �8��
;0828:	move.l	a5,$0134.w		      ; 20715 0134	     !��4
;084C:	move.b	d3,$FFFFFA1F.w		      ; 10703 FA1F	     ����
;0858:	move.b	d1,$FFFFFA19.w		      ; 10701 FA19	     ����
;0932:	andi.b	#$F0,$FFFFFA1D.w	      ; 01070 00F0FA1D	     �8����
;0942:	clr.b	$FFFFFA19.w		      ; 41070 FA19	     B8��
;0958:	andi.b	#$F0,$FFFFFA1D.w	      ; 01070 00F0FA1D	     �8����
;0960:	clr.b	$FFFFFA19.w		      ; 41070 FA19	     B8��
;0988:	move.l	a5,$0110.w		      ; 20715 0110	     !���
		dc.w	$7f8,6
		dc.w	$7fe,4
		dc.w	$828,4
		dc.w	$84c,4
		dc.w	$858,4
		dc.w	$932,6
		dc.w	$942,4
		dc.w	$958,6
		dc.w	$960,4
		dc.w	$988,4

;09AE:	move.b	d3,$FFFFFA25.w		      ; 10703 FA25	     ���%
;09C0:	andi.b	#$F0,$FFFFFA1D.w	      ; 01070 00F0FA1D	     �8����
;09C6:	or.b	d1,$FFFFFA1D.w		      ; 81470 FA1D	     �8��
;09F0:	move.l	a5,$0134.w		      ; 20715 0134	     !��4
;0A16:	move.b	d3,$FFFFFA1F.w		      ; 10703 FA1F	     ����
;0A22:	move.b	d1,$FFFFFA19.w		      ; 10701 FA19	     ����
		dc.w	$9ae,4
		dc.w	$9c0,6
		dc.w	$9c6,4
		dc.w	$9f0,4
		dc.w	$a16,4
		dc.w	$a22,4

;0AFC:	andi.b	#$F0,$FFFFFA1D.w	      ; 01070 00F0FA1D	     �8����
;0B0C:	clr.b	$FFFFFA19.w		      ; 41070 FA19	     B8��
;0B22:	andi.b	#$F0,$FFFFFA1D.w	      ; 01070 00F0FA1D	     �8����
;0B2A:	clr.b	$FFFFFA19.w		      ; 41070 FA19	     B8��
;0B5A:	move.l	a5,$0110.w		      ; 20715 0110	     !���
;0B86:	move.b	d3,$FFFFFA25.w		      ; 10703 FA25	     ���%
;0B98:	andi.b	#$F0,$FFFFFA1D.w	      ; 01070 00F0FA1D	     �8����
;0B9E:	or.b	d1,$FFFFFA1D.w		      ; 81470 FA1D	     �8��
;0BD0:	move.l	a5,$0134.w		      ; 20715 0134	     !��4
;0BFC:	move.b	d3,$FFFFFA1F.w		      ; 10703 FA1F	     ����
;0C08:	move.b	d1,$FFFFFA19.w		      ; 10701 FA19	     ����
		dc.w	$afc,6
		dc.w	$b0c,4
		dc.w	$b22,6
		dc.w	$b2a,4
		dc.w	$b5a,4
		dc.w	$b86,4
		dc.w	$b98,6
		dc.w	$b9e,4
		dc.w	$bd0,4
		dc.w	$bfc,4
		dc.w	$c08,4

;0CE2:	andi.b	#$F0,$FFFFFA1D.w	      ; 01070 00F0FA1D	     �8����
;0CF2:	clr.b	$FFFFFA19.w		      ; 41070 FA19	     B8��
;0D08:	andi.b	#$F0,$FFFFFA1D.w	      ; 01070 00F0FA1D	     �8����
;0D10:	clr.b	$FFFFFA19.w		      ; 41070 FA19	     B8��
;0D40:	move.l	a5,$0110.w		      ; 20715 0110	     !���
;0D68:	move.b	d3,$FFFFFA25.w		      ; 10703 FA25	     ���%
;0D7A:	andi.b	#$F0,$FFFFFA1D.w	      ; 01070 00F0FA1D	     �8����
;0D80:	or.b	d1,$FFFFFA1D.w		      ; 81470 FA1D	     �8��
;0DB2:	move.l	a5,$0134.w		      ; 20715 0134	     !��4
;0DDA:	move.b	d3,$FFFFFA1F.w		      ; 10703 FA1F	     ����
;0DE6:	move.b	d1,$FFFFFA19.w		      ; 10701 FA19	     ����
		dc.w	$ce2,6
		dc.w	$cf2,4
		dc.w	$d08,6
		dc.w	$d10,4
		dc.w	$d40,4
		dc.w	$d68,4
		dc.w	$d7a,6
		dc.w	$d80,4
		dc.w	$db2,4
		dc.w	$dda,4
		dc.w	$de6,4

;0F5C:	andi.b	#$F0,$FFFFFA1D.w	      ; 01070 00F0FA1D	     �8����
;0F6C:	clr.b	$FFFFFA19.w		      ; 41070 FA19	     B8��
;0F82:	andi.b	#$F0,$FFFFFA1D.w	      ; 01070 00F0FA1D	     �8����
;0F8A:	clr.b	$FFFFFA19.w		      ; 41070 FA19	     B8��
;0FB2:	move.l	a5,$0110.w		      ; 20715 0110	     !���
;0FEA:	move.b	d3,$FFFFFA25.w		      ; 10703 FA25	     ���%
;0FFC:	andi.b	#$F0,$FFFFFA1D.w	      ; 01070 00F0FA1D	     �8����
;1002:	or.b	d1,$FFFFFA1D.w		      ; 81470 FA1D	     �8��
;102E:	move.l	a5,$0134.w		      ; 20715 0134	     !��4
;1066:	move.b	d3,$FFFFFA1F.w		      ; 10703 FA1F	     ����
;1072:	move.b	d1,$FFFFFA19.w		      ; 10701 FA19	     ����
		dc.w	$f5c,6
		dc.w	$f6c,4
		dc.w	$f82,6
		dc.w	$f8a,4
		dc.w	$fb2,4
		dc.w	$fea,4
		dc.w	$ffc,6
		dc.w	$1002,4
		dc.w	$102e,4
		dc.w	$1066,4
		dc.w	$1072,4

;114E:	andi.b	#$F0,$FFFFFA1D.w	      ; 01070 00F0FA1D	     �8����
;115E:	clr.b	$FFFFFA19.w		      ; 41070 FA19	     B8��
;1174:	andi.b	#$F0,$FFFFFA1D.w	      ; 01070 00F0FA1D	     �8����
;117C:	clr.b	$FFFFFA19.w		      ; 41070 FA19	     B8��
;11A4:	move.l	a5,$0110.w		      ; 20715 0110	     !���
;11DC:	move.b	d3,$FFFFFA25.w		      ; 10703 FA25	     ���%
;11EE:	andi.b	#$F0,$FFFFFA1D.w	      ; 01070 00F0FA1D	     �8����
;11F4:	or.b	d1,$FFFFFA1D.w		      ; 81470 FA1D	     �8��
;1220:	move.l	a5,$0134.w		      ; 20715 0134	     !��4
;1258:	move.b	d3,$FFFFFA1F.w		      ; 10703 FA1F	     ����
;1264:	move.b	d1,$FFFFFA19.w		      ; 10701 FA19	     ����
		dc.w	$114e,6
		dc.w	$115e,4
		dc.w	$1174,6
		dc.w	$117c,4
		dc.w	$11a4,4
		dc.w	$11dc,4
		dc.w	$11ee,6
		dc.w	$11f4,4
		dc.w	$1220,4
		dc.w	$1258,4
		dc.w	$1264,4

;sidrouts
;15E8:	addi.l	#$00000012,$0134.w	      ; 03270 000000120134   �������4
;15FA:	addi.l	#$00000012,$0134.w	      ; 03270 000000120134   �������4
;160C:	addi.l	#$00000012,$0134.w	      ; 03270 000000120134   �������4
;161E:	subi.l	#$00000036,$0134.w	      ; 02270 000000360134   �����6�4
;1630:	addi.l	#$00000012,$0110.w	      ; 03270 000000120110   ��������
;1642:	addi.l	#$00000012,$0110.w	      ; 03270 000000120110   ��������
;1654:	addi.l	#$00000012,$0110.w	      ; 03270 000000120110   ��������
;1666:	subi.l	#$00000036,$0110.w	      ; 02270 000000360110   �����6��
;1678:	addi.l	#$00000012,$0134.w	      ; 03270 000000120134   �������4
;1682:	subi.l	#$00000012,$0134.w	      ; 02270 000000120134   �������4
;1694:	addi.l	#$00000012,$0110.w	      ; 03270 000000120110   ��������
;169E:	subi.l	#$00000012,$0110.w	      ; 02270 000000120110   ��������
;16B0:	addi.l	#$00000012,$0134.w	      ; 03270 000000120134   �������4
;16BA:	subi.l	#$00000012,$0134.w	      ; 02270 000000120134   �������4
;16CC:	addi.l	#$00000012,$0110.w	      ; 03270 000000120110   ��������
;16D6:	subi.l	#$00000012,$0110.w	      ; 02270 000000120110   ��������
		dc.w	$15e8,8
		dc.w	$15fa,8
		dc.w	$160c,8
		dc.w	$161e,8
		dc.w	$1630,8
		dc.w	$1642,8
		dc.w	$1654,8
		dc.w	$1666,8
		dc.w	$1678,8
		dc.w	$1682,8
		dc.w	$1694,8
		dc.w	$169e,8
		dc.w	$16b0,8
		dc.w	$16ba,8
		dc.w	$16cc,8
		dc.w	$16d6,8

		dc.w	0

		section	text

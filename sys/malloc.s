
; MEMORY ALLOCATION IMPLEMENTAN VECTOR:
; usage:
;	move.l	#somefreememory,malloc_ptr
;	move.l  #malloc_trap_vector,$84.w
malloc_trap_vector:	
	move.b	#0,$ffffc123
                movea.l SP,A0
                add.l  #6,A0 ;that's either 6 or 8 (68000/68030)
  
do_malloc:      movea.l 2(A0),A0        ;requested memory amount
                move.l  malloc_ptr(PC),D0 ;the pointer to memory we're going to give
                move.l	d0,d1
                and.l	#1,d1
                beq		.ok
                	add.l	#1,d0
.ok
                lea     0(A0,D0.l),A0   ;advance our pointer as many bytes as those reserved
                move.l  A0,malloc_ptr   ;save the pointer for next malloc
                rte                     ;and go back to program
 
no_malloc:      cmpi.w  #$49,(A0)       ;mfree?
                bne.s   no_mfree
                rte                     ;do nothing
 
no_mfree:
old_trap1       
                jmp     $1234567              ;jump to O/S' vector
 
                ds.b	4

malloc_ptr:     DC.L memBase+3*65536
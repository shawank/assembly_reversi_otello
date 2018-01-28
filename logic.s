	.data
board: .space 256
chanceBlack: .word 1
gameOver: .word 0
blackCanMove: .word 1
whiteCanMove: .word 1
1schance: .asciz "1's  chance \n"
2schance: .asciz "2's chance \n"
whitewon: .asciz "white won"
blackwon: .asciz "blackwon"
draw: .asciz "It's a draw"
flag: .word 0

Digits:
.word SEG_A|SEG_B|SEG_C|SEG_D|SEG_E|SEG_G @0
.word SEG_B|SEG_C @1
.word SEG_A|SEG_B|SEG_F|SEG_E|SEG_D @2
.word SEG_A|SEG_B|SEG_F|SEG_C|SEG_D @3
.word SEG_G|SEG_F|SEG_B|SEG_C @4
.word SEG_A|SEG_G|SEG_F|SEG_C|SEG_D @5
.word SEG_A|SEG_G|SEG_F|SEG_E|SEG_D|SEG_C @6
.word SEG_A|SEG_B|SEG_C @7
.word SEG_A|SEG_B|SEG_C|SEG_D|SEG_E|SEG_F|SEG_G @8
.word SEG_A|SEG_B|SEG_F|SEG_G|SEG_C @9
.word 0 @Blank display

	.text
	@ r5 for rowNumber & r6 for columnNumber & r7 for wasValid
	mov r5, #0
	mov r6, #0
	mov r7, #0
	bl initialize
	bl printBoard
	ldr r11, =gameOver
	ldr r11 , [r11]
	cmp  r11, #0
	bne last
	bl canBlackMove
	@r8 for blackCanMove and r9 for whiteCanMove and r10 is for logical temp storage
	mov r8, r0
	bl canWhiteMove
	mov r9, r0
	orr r10, r8, r9
	cmp r10,  #0
	bne part2
	ldr r11, =gameOver
	mov r12, #1
	str r12, [r11]
part2: 
	ldr r11, =chanceBlack
	ldr r11, [r11]
	ldr r12, =blackCanMove
	ldr r12, [r12]
	and r10, r11, r12
	cmp r10, #1
	bne elsepart
	@printf("1's chance \n");
	mov r0, #0
	mov r1, #14
	ldr r2, =1schance
	swi 0x204
	b nextpart1

elsepart:
	@printf("2's chance \n");
	mov r0, #0
	mov r1, #14
	ldr r2, =2schance
	swi 0x204
nextpart1: 
	cmp r10, #1
	bne elsepart2
	@scanf("%d%d",&rowNumber,&columnNumber);


	@assume that rowNumber is in r11 and columnNumber in r12
	mov r0, r11
	mov r1, r12
	bl checkValidity
	mov r7, r0
	cmp r7, #0
	bne prt2
	mov r0, r11
	mov r1, r12
	bl move
prt2: 
	bl printBoard
	ldr r11, =chanceBlack
	ldr r12, [r11]
	eor r12, r12, #1
	str r12, [r11]
last:
	bl printBoard
	bl whoWon


initialize:
	mov r0, #1
	ldr r3, =board
	str r0, [r3, 108]
	str r0, [r3, 148]
	mov r0, #2
	str r0, [r3, 112]
	str r0, [r3, 144]
	mov pc, lr



whoWon:
	STMFD sp!, {r4-r12, lr}
	# mov r7, #4  @placeholder for constant 4
	@r0 contains number of black beads and r1 for white. i -> r2 j -> r3
	@r4 -> board address, r5 -> element of board
	mov r0, #0
	mov r1, #0
	mov r2, #0
	mov r3, #0
	ldr r4, =board
starter:	
	cmp r2, #8
	bne outer
inner:
	cmp r3, #8
	bne starter
	add r6, r3, r2, LSL #2
	ldr r5, [r4, r6]
	cmp r5, #1
	bne nextcomp
	add r0, r0 #1
	b inner
nextcomp:
	cmp r5, #2
	bne inner
	add r1, r1, #1
	b inner
outer:
	cmp r0, r1
	blt lessthan
	//printf("black won")
	b ending
lessthan: 
	//printf("white won")
	b ending
equivalent: 
	//printf("draw")
ending:
	STMFD sp!, {r4-r12, pc}

@@	
canBlackMove:
	STMFD sp!, {r4-r12, lr}
	ldr r0, =chanceBlack
	ldr r6, [r0] @this will act like temp
	mov r1, #1
	str r1, [r0]
	mov r4, #0 @ int i 
	mov r5, #0 @int j
gotostartB:	
	cmp r4, #8
	bge gotoendB
gotoinnerB:
	cmp r5, #8
	bge gotostartB
	mov r0, r4
	mov r1, r5
	bl checkValidity
	cmp r0, #1
	bne gotoinnerB
	ldr r0, =chanceBlack
	str r6, [r0]
	ldr lr, [sp], #4
	ldr r6, [sp], #4
	ldr r5, [sp], #4
	ldr r4, [sp]  @@@ error chances
	mov r0, #1
	mov pc, lr
gotoendB:
	ldr r0, =chanceBlack
	str r6, [r0]
	mov r0, #0
	LDMFD sp!, {r4-r12, pc}




@@
canWhiteMove:
	STMFD sp!, {r4-r12, lr}
	ldr r0, =chanceBlack
	ldr r6, [r0] @this will act like temp
	mov r1, #0
	str r1, [r0]
	mov r4, #0 @ int i 
	mov r5, #0 @int j
gotostart:	
	cmp r4, #8
	bge gotoend
gotoinner:
	cmp r5, #8
	bge gotostart
	mov r0, r4
	mov r1, r5
	bl checkValidity
	cmp r0, #1
	bne gotoinner
	ldr r0, =chanceBlack
	str r6, [r0]
	ldr lr, [sp], #4
	ldr r6, [sp], #4
	ldr r5, [sp], #4
	ldr r4, [sp]  @@@ error chances
	mov r0, #1
	mov pc, lr
gotoend:
	ldr r0, =chanceBlack
	str r6, [r0]
	mov r0, #0
	LDMFD sp!, {r4-r12, pc}


printBoard:
	STMFD sp!, {r4,r5,r6,r7,r8,r9,r10,r11,r12,lr}
	@@ r7 for board address; r8 contains const 4; r3 contains i; r4 for j; r0 for x; r1 for y; 
	ldr r0, =chanceBlack
	ldr r7, =board
	mov r8, #4. @@ask tarun for better method
	cmp chanceBlack, #0
	beq whiteturn
	ldr r2, =1schance
	mov r0, #0
	mov r1, #14
	swi 0x204
	b boardpart
whiteturn:
	ldr r2, =2schance
	mov r0, #0
	mov r1, #14
	swi 0x204
boardpart:
	mov r3, #0
	mov r0, #16
	mov r1, #3
numberforloop:
	cmp r3, #8
	bge verticalnumbering
	mov r2, r3
	swi 0x205
	add r3, r3, #1
	add r0, r0, #2
	b numberforloop

verticalnumbering:
	mov r0, #16
	mov r1, #4
	mov r3, #0
	numberforloopV:
	cmp r3, #8
	bge placepieces
	mov r2, r3
	swi 0x205
	add r3, r3, #1
	add r1, r1, #1
	b numberforloop

placepieces:
	mov r3, #0
	mov r4, #0
	mov r0, #18
	mov r1, #3
piecesforloopO:
	cmp r3, #8
	bge endpart
	add r1, r1, #1
piecesforloopI
	cmp r4, #8
	bge piecesforloopO
	mul r9, r4, r8
	mla r9, r9, r3, LSL #5
	ldr r2, [r7, r9]
	swi 0x205
	@@ add for blank space if zero is not preferred
	add r3, r3, #1
	add r4, r4, #1
	add r0, r0, #2
	b piecesforloopI

	LDMFD sp!, {lr,r12,r11,r10,r9,r8,r7,r6,r5,r4}
	mov pc, lr




move:
	STMFD sp!, {r4,r5,r6,r7,r8,r9,r10,r11,r12,lr}

	mov r2, #1			@ int player=1
	mov r3, #2			@ int opponent=2

	ldr r4, =chanceBlack
	ldr r4, [r4]

	cmp r4, #1			@ if(!chanceBlack)
	movne r2, #2		@ player=2
	movne r3, #1		@ opponent=1

	mov r6, #0			@ r6 <- int i=0
move_loop:	
   cmp r6, #8			@ i < 8
   beq move_loop_done

   mov r12, r6
   bl getValue_a
   mov r4, r12			@ r4 contains a_inc[i]

   mov r12, r6
   bl getValue_b
   mov r5, r12			@ r5 contains b_inc[i]

   mov r6, r0 			@ r6 contains a
   mov r7, r1 			@ r7 contains b

first_while:
	
condition1:
	cmp r6, #0
	bgt condition2
	cmp r4, #-1
   	bne condition2
   	b move_if

condition2:
	cmp r6, #7
	blt condition3
	cmp r4, #1
	bne condition3
	b move_if

condition3:
	cmp r7, #0
	bgt condition4
	cmp r5, #-1
   	bne condition4
   	b move_if

condition4:
	cmp r7, #7
	blt condition5
	cmp r5, #1
	bne condition5
	b move_if

condition5:	
	add r11, r6, r4
	add r12, r7, r5
	bl getLocation
	ldr r12, [r12]
	cmp r12, r3
	bne move_if

	add r6, r6, r4
	add r7, r7, r5

move_if:
	
if_condition1:
	cmp r6, #0
	bgt if_condition2
	cmp r4, #-1
   	bne if_condition2
   	b incr_loop

if_condition2:
	cmp r6, #7
	blt if_condition3
	cmp r4, #1
	bne if_condition3
	b incr_loop

if_condition3:
	cmp r7, #0
	bgt if_condition4
	cmp r5, #-1
   	bne if_condition4
   	b incr_loop

if_condition4:
	cmp r7, #7
	blt if_condition5
	cmp r5, #1
	bne if_condition5
	b incr_loop

if_condition5:	
	add r11, r6, r4
	add r12, r7, r5
	bl getLocation
	ldr r12, [r12]
	cmp r12, r2
	bne incr_loop

if_while:
	cmp r6, r0
	bne do_if_while
	cmp r7, r1
	bne do_if_while
	b incr_loop

do_if_while:
	mov r11, r6
	mov r12, r7
	bl getLocation
	str r2, [r12]
	sub r6, r6, r4
	sub r7, r7, r5
	b if_while

incr_loop:
    add r6, r6, #1
    b move_loop

move_loop_done:

	mov r11, r0
	mov r12, r1
	bl getLocation
	str r2, [r12]

	LDMFD sp!, {lr,r12,r11,r10,r9,r8,r7,r6,r5,r4}
	mov pc, lr



checkValidity:
	STMFD sp!, {r4,r5,r6,r7,r8,r9,r10,r11,r12,lr}

	cmp r0, #7
	bgt move_loop_done_2
	cmp r1, #7
	bgt move_loop_done_2
	cmp r0, #0
	blt move_loop_done_2
	cmp r1, #0
	blt move_loop_done_2


	mov r2, #1			@ int player=1
	mov r3, #2			@ int opponent=2

	ldr r4, =chanceBlack
	ldr r4, [r4]

	cmp r4, #1			@ if(!chanceBlack)
	movne r2, #2		@ player=2
	movne r3, #1		@ opponent=1

	ldr r10, =flag
	mov r11, #0
	ldr r11, [r10]		@bool flag = false

	mov r6, #0			@ r6 <- int i=0
move_loop_1:	
   cmp r6, #8			@ i < 8
   beq move_loop_done_2

   mov r11, #0
   mov r11, [r10]		@flag = false


   mov r12, r6
   bl getValue_a
   mov r4, r12			@ r4 contains a_inc[i]

   mov r12, r6
   bl getValue_b
   mov r5, r12			@ r5 contains b_inc[i]

   mov r6, r0 			@ r6 contains a
   mov r7, r1 			@ r7 contains b

first_while_1:
	
condition1_1:
	cmp r6, #0
	bgt condition2_1
	cmp r4, #-1
   	bne condition2_1
   	b move_if_1

condition2_1:
	cmp r6, #7
	blt condition3_1
	cmp r4, #1
	bne condition3_1
	b move_if_1

condition3_1:
	cmp r7, #0
	bgt condition4_1
	cmp r5, #-1
   	bne condition4_1
   	b move_if_1

condition4_1:
	cmp r7, #7
	blt condition5_1
	cmp r5, #1
	bne condition5_1
	b move_if

condition5_1:	
	add r11, r6, r4
	add r12, r7, r5
	bl getLocation
	ldr r12, [r12]
	cmp r12, r3
	bne move_if_1

	add r6, r6, r4
	add r7, r7, r5
	mov r11, #1
    mov r11, [r10]		@flag = false


move_if_1:
	
if_condition0_1:
	ldr r11, [r10]
	cmp r11, #1
	bne incr_loop_1

if_condition1_1:
	cmp r6, #0
	bgt if_condition2_1
	cmp r4, #-1
   	bne if_condition2_1
   	b incr_loop_1

if_condition2_1:
	cmp r6, #7
	blt if_condition3_1
	cmp r4, #1
	bne if_condition3_1
	b incr_loop_1

if_condition3_1:
	cmp r7, #0
	bgt if_condition4_1
	cmp r5, #-1
   	bne if_condition4_1
   	b incr_loop_1

if_condition4_1:
	cmp r7, #7
	blt if_condition5_1
	cmp r5, #1
	bne if_condition5_1
	b incr_loop_1

if_condition5_1:	
	add r11, r6, r4
	add r12, r7, r5
	bl getLocation
	ldr r12, [r12]
	cmp r12, r2
	bne incr_loop_1

if_while_1:
	mov r0, #1
	b move_loop_done_1

incr_loop_1:
    add r6, r6, #1
    b move_loop_1


move_loop_done_2:
	mov r0, #0
	
move_loop_done_1:
	LDMFD sp!, {lr,r12,r11,r10,r9,r8,r7,r6,r5,r4}
	mov pc, lr	

getLocation:			@ returns board[a][b] location--> r11 contains a, r12 contains b, returns address in r12
	STMFD sp!, {r0,r1,r2,r3,r4,r5}

	mov r2, #8
	mov r3, #4
	mul r0, r11, r3
	mul r1, r0, r2 		@ r1 contains 8*a

	mul r4, r12, r3		@ r4 contains b
	add r5, r1, r4 		@ r5 contains 8*a+b

	ldr r12, =board
	add r12, r12, r5
	LDMFD sp!, {r5,r4,r3,r2,r1,r0}
	mov pc, lr

getValue_a:				@ returns a_inc[i]--> r12 contains i, returns value in r12
	STMFD sp!, {r0,r1}
	mov r12, r12, LSL #2

	ldr r0, =a_inc
	add r0, r0, r12

	ldr r12, [r0]

	LDMFD sp!, {r1,r0}
	mov pc, lr

getValue_b:				@ returns b_inc[i]--> r12 contains i, returns value in r12
	STMFD sp!, {r0,r1}
	mov r12, r12, LSL #2

	ldr r0, =b_inc
	add r0, r0, r12

	ldr r12, [r0]
	
	LDMFD sp!, {r1,r0}
	mov pc, lr	


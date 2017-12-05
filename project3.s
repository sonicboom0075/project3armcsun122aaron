.equ SWI_GetTicks, 0x6d			@get current time
.equ SWI_LightLED, 0x201		@switch on/off LED
.equ SWI_CheckKey, 0x203		@checks blue keypad
.equ SWI_CheckBttn, 0x202		@check black buttons
.equ SWI_DispNum, 0x200			@displays the number/letter thingy
.equ SWI_DispStr, 0x204			@displays string on LCD screen
.equ SWI_ClrLCD, 0x206			@clears LCD display
.equ SWI_Heap, 0x12 			@Reserves a chunk of memory

.equ SEG_A,0x80
.equ SEG_B,0x40
.equ SEG_C,0x20
.equ SEG_D,0x08
.equ SEG_E,0x04
.equ SEG_F,0x02
.equ SEG_G,0x01
.equ SEG_P,0x10

.equ VAR_HeapAddress, 0x00002040

mov r0,#0
bl SetUnlock

@---------------------MENU---------------------------
menu:
	@check blue keypad
	swi SWI_CheckKey
	cmp r0,#0
	blne BothLED

	@check black buttons
	swi SWI_CheckBttn
	cmp r0,#1					@right black button
	bleq SetProgram
	bleq RightLED
	bleq Programming
	cmp r0,#2					@left black button
	bleq SetLock
	bleq LeftLED
	bleq ToggleLock

	b menu

@----------------------------------------------------
@--------------------WAITING-------------------------
Wait:
	stmfd sp!, {r0-r2,lr}
	swi SWI_GetTicks
	mov r1, r0 					@ R1: start time

WaitLoop:
	swi SWI_GetTicks
	subs r0, r0, r1 			@ R0: time since start
	rsblt r0, r0, #0			@ fix unsigned subtract
	cmp r0, r2
	blt WaitLoop

WaitDone:
	ldmfd sp!,{r0-r2,pc}

@----------------------------------------------------
@------------------PROGRAMMING MODE------------------
Programming:
	stmfd sp!, {r0-r1,lr}
	mov r2,#0
	mov r3,#0
	mov r4,#0
	cmp r9,#0
	movne r1,r9
	bleq CreateHeap
ProgrammingLoop:
	swi SWI_CheckBttn
	cmp r0,#1
	beq ConfirmStart
	swi SWI_CheckKey
	cmp r0,#0
	blne BothLED
	cmp r0,#0
	blne AddToMem
	b ProgrammingLoop
ConfirmStart:
	str r3,[r9]
	ldr r0,=VAR_HeapAddress
	ldr r0,[r0]
	ldr r0,[r0]
	tst r0,#0
	bne ForgetStart
	bl SetConfirm
	mov r2,#1
	mov r3,#0
	mov r4,#0
	mov r5,#0
	add r9,r9,#4
ConfirmLoop:
	swi SWI_CheckBttn
	cmp r0,#1
	beq ConfirmCheck

	swi SWI_CheckKey
	cmp r0,#0
	blne BothLED
	cmp r0,#0
	blne CheckFromMem

	b ConfirmLoop
ConfirmCheck:
	cmp r8,r4
	beq EndProgramming
	mov r2,#0
	@@blne ErrorProgramming
EndProgramming:
	cmp r2,#1
	beq ProgramSuccess

ProgramFail:
	ldr r0,=VAR_HeapAddress
	ldr r0,[r0]
	mov r2,#0
	str r2,[r0]
	bl SetError
	ldmfd sp!,{r0-r1,pc}
	bx lr

ProgramSuccess:
	sub r9,r9,#20
	bl SetSuccess
	ldmfd sp!,{r0-r1,pc}
	bx lr
@stores number into memory

AddToMem:
	add r4,r4,#4
	str r0,[r9,r4]
	add r3,r3,#1
	bx lr

@checks numbers
CheckFromMem:
	add r4,r4,#1
	ldr r5,[r9,r3]
	add r3,r3,#4
	cmp r0,r5
	bxeq lr
	mov r2,#0
	bx lr
ErrorProgramming:
	bl SetError
	ldmfd sp!,{r0-r1,pc}
	bx lr
ForgetStart:
	bl SetForget
ForgetLoop:
	cmp r3,#4
	beq ForgetEnd
	swi SWI_CheckKey
	cmp r0,#0
	blne BothLED
	cmp r0,#0
	blne AddToMem
	b ForgetLoop
ForgetEnd:
	ldmfd sp!,{r0-r1,pc}
	bx lr
@----------------------------------------------------
@-------------------LOCK BUTTON----------------------
ToggleLock:
	stmfd sp!, {r0-r1,lr}
	bl LoadDisplay
	mov r2,#1000
	bl Wait
	swi SWI_ClrLCD
	bl SetUnlock
	ldmfd sp!,{r0-r1,pc}
	bx lr
@----------------LCD DISPLAY-------------------------
LoadDisplay:
	mov r0,#0
	mov r1,#0
	ldr r2,=WIP
	swi SWI_DispStr
	bx lr
@----------------------------------------------------
@-----------------EMBEST FUNCTIONS-------------------
BothLED:
	stmfd sp!, {r0-r2,lr}
	mov r0,#3
	swi SWI_LightLED
	mov r2,#100
	bl Wait
	bl LEDOff
	ldmfd sp!,{r0-r2,pc}
	bx lr

LeftLED:
	stmfd sp!, {r0-r1,lr}
	mov r0,#2
	swi SWI_LightLED
	mov r2,#100
	bl Wait
	bl LEDOff
	ldmfd sp!,{r0-r1,pc}
	bx lr

RightLED:
	stmfd sp!, {r0-r1,lr}
	mov r0,#1
	swi SWI_LightLED
	mov r2,#100
	bl Wait
	bl LEDOff
	ldmfd sp!,{r0-r1,pc}
	bx lr

LEDOff:
	mov r0,#0
	swi SWI_LightLED
	bx lr
@----------------------------------------------------
@----------------SET 8 SEGMENT DISPLAY---------------
SetLock:
	ldr r1,=Digits
	ldr r0,[r1,#+4]
	swi SWI_DispNum
	bx lr

SetUnlock:
	ldr r1,=Digits
	ldr r0,[r1]
	swi SWI_DispNum
	bx lr

SetError:
	ldr r1,=Digits
	ldr r0,[r1,#+24]
	swi SWI_DispNum
	bx lr

SetProgram:
	ldr r1,=Digits
	ldr r0,[r1,#+8]
	swi SWI_DispNum
	bx lr

SetConfirm:
	ldr r1,=Digits
	ldr r0,[r1,#+12]
	swi SWI_DispNum
	bx lr

SetForget:
	ldr r1,=Digits
	ldr r0,[r1,#+16]
	swi SWI_DispNum
	bx lr

SetSuccess:
	ldr r1,=Digits
	ldr r0,[r1,#+20]
	swi SWI_DispNum
	bx lr
@----------------------------------------------------
@------------------EXTRA FUNCTIONS-------------------
ClearRegisters:
	mov r0,#0
	mov r1,#0
	mov r2,#0
	mov r3,#0
	mov r4,#0
	mov r5,#0
	mov r6,#0
	mov r7,#0
	mov r8,#0
	mov r9,#0
	bx lr

CreateHeap:
	mov r0,#20
	swi SWI_Heap
	mov r9,r0
	ldr r7,=VAR_HeapAddress
	str r0,[r7]
	bx lr

@----------------STRINGS/VARIABLES/ETC---------------
Digits:
	.word SEG_B|SEG_C|SEG_D|SEG_E|SEG_G|SEG_P				@Unlock
	.word SEG_D|SEG_E|SEG_G|SEG_P 							@Lock
	.word SEG_A|SEG_B|SEG_E|SEG_F|SEG_G|SEG_P				@Program
	.word SEG_A|SEG_D|SEG_E|SEG_G|SEG_P 					@Confirm
	.word SEG_A|SEG_E|SEG_F|SEG_G|SEG_P						@Forget
	.word SEG_A|SEG_B|SEG_C|SEG_E|SEG_F|SEG_G|SEG_P			@A programming request was successful
	.word SEG_A|SEG_D|SEG_E|SEG_F|SEG_G|SEG_P 				@Error
	.word 0 												@Blank display

WIP: .asciz "Work in Progress."

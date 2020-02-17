#Main.s
#Julian Singkham
#CE 2801
#Lab 3
#Description: Busy Wait


.syntax unified
.cpu cortex-m4
.thumb
.section .text
	.equ INSTRUCTIONS_PER_MS, 0x3E80 //16,000 instructions per ms

.global delay_ms

	//r0 = delay time in ms
	//r1 = GPIOB_BASE
	//r11 = instructions per ms
	//r12 = temporary variable
delay_ms:
	push {r0-r1, r11-r12}
	ldr r11, =INSTRUCTIONS_PER_MS //conversion counter

1:
	mov r12, r0	//load time into temp register

2: //time counter
	subs r12, r12, #1
	bne 2b //branch backward to local label '1' (1b) if not equal (NE) to 0

	# ms/instruction counter
	subs r11, r11, #1
	bne 1b

	pop {r0-r1, r11-r12}
	bx lr

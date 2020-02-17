#Main.s
#Julian Singkham
#CE 2801
#Lab 3
#Description: Display to LED

#Light are on PB5-PB15 (PB11 not used)

.syntax unified
.cpu cortex-m4
.thumb
.section .text

.equ GPIOB_BSRR, 0x18 //0x40020418 is the location of the bit set/reset 31:16 reset 15:0 sets
.equ BSRR_RESET, 0xFFFF0000

.global num_to_LED

	//r0 = What to display to LED (lowest 10)
	//r1 = GPIOB_BASE
	//r12 = value to send to LED
num_to_LED:
	push {r0, r11-r12}
	ldr r12, = BSRR_RESET
	str r12, [r1, #GPIOB_BSRR] //turn off LED
	mov r12, #0
	
	bfi r12, r0, #5, #6 //Grab the bottom 6
	lsr r0, r0, #6
	bfi R12, r0, #12, #4 //Grab the top 4

#Send R12 to LED
	str r12, [r1, #GPIOB_BSRR]	//Turn LEDs on

	pop {r0, r11-r12}
	bx lr


#Main.s
#Julian Singkham
#CE 2801
#Lab 2
#Description: Night rider light effect.

#Light are on PB5-PB15 (PB11 not used)

.syntax unified
.cpu cortex-m4
.thumb
.section .text

	.equ RCC_BASE, 0x40023800 //base address for clock: ie gives clock to peripherals
	.equ RCC_AHB1ENR, 0x30 //0x40023830 is the location of the "Turns on GPIO peripherls"
	.equ RCC_GPIOBEN, 1<<1 // Shift the value 1 to the left once

	.equ GPIOB_BASE, 0x40020400//Address for the GPIOB (thing that actually controls GPIOB)
	.equ GPIOB_BSRR, 0x18 //0x40020418 is the location of the bit set/reset 31:16 reset 15:0 sets
	.equ GPIO_MODER, 0x00 //Length of an individual pin's function (offset)
	.equ GPIO_ODR, 0x14  //Output data register for a specifac GPIO.

	.equ BSRR_RESET, 0xFFFF0000

.global main

main:

	#Turn on GPIOB in RCC
	ldr r1, =RCC_BASE
	ldr r2, [r1, #RCC_AHB1ENR]
	orr r2, r2, #RCC_GPIOBEN
	str r2, [r1, #RCC_AHB1ENR]

	#Enable PB5-PB10, PB12-PB15 to be outputs
	ldr r1, =GPIOB_BASE
	ldr r2, [r1, #GPIO_MODER]
	movw r3, #0x5400
	movt r3, #0x5515
	orr r2, r2, r3
	movw r3, #0xA800
	movt r3, #0xAA2A
	bic r2, r2, r3
	str r2, [r1, #GPIO_MODER]

#r4 = delay timer
#r3 = increment
#r2 = state of BSRR
#r1 = Location of GPIOB
	ldr r3, =0x00000020 //initial value for BSRR (turns right most LED on)


right_left:
#Check if the current LED is the left most
	cmp r3, #0x00008000
	beq left_right	//If increment =15
#Turn LED on
	mov r2, r3
	str r2, [r1, #GPIOB_BSRR]	//Turn LED on
	bl delay
#Turn LED off
	ldr r2, =BSRR_RESET
	str r2, [r1, #GPIOB_BSRR]	//Turn off LED
#Increment to the left LED
1:
	LSL r3, r3, #1
	cmp r3, #0x00000800
	beq 1b	//If increment =11, go back to increment

	b right_left


left_right:
#Check if the current LED is the right most
	cmp r3, #0x00000020
	beq right_left	//If increment = 5
#Turn LED on
	mov r2, r3
	str r2, [r1, #GPIOB_BSRR]	//Turn LED on
	bl delay
#Turn LED off
	ldr r2, =BSRR_RESET
	str r2, [r1, #GPIOB_BSRR]	//Turn off LED
#Increment to the right LED
1:
	lsr r3, r3, #1
	cmp r3, #0x00000800
	beq 1b	//If increment =11, go back to increment

	b left_right


delay:
	ldr r4, =0x00100000
1:
	subs r4, r4, #1
	# branch backward to local label '1' (1b) if not equal (NE) to 0
	bne 1b
	bx lr

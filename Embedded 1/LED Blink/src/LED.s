#Main.s
#Julian Singkham
#CE 2801
#Lab 2
#Description: This will implement all on then all off.

#Light are on PB5-PB15 (PB11 not used)

.syntax unified
.cpu cortex-m4
.thumb
.section .text

	.equ RCC_BASE, 0x40023800 //base address for clock: ie gives clock to peripherals
	.equ RCC_AHB1ENR, 0x30 //0x40023830 is the location of the Turns on GPIO peripherls
	.equ RCC_GPIOBEN, 1<<1 // Shift the value 1 to the left once

	.equ GPIOB_BASE, 0x40020400//Address for the GPIOB (thing that actually controls GPIOB)
	.equ GPIO_MODER, 0x00 //Length of an individual pin's function (offset)
	.equ GPIO_ODR, 0x14  //Output data register for a specifac GPIO.

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

	#Turn on all light
turn_on:
	ldr r2, [r1, #GPIO_ODR]
	movw r3, #0xF7E0
	orr r2, r2, r3
	str r2, [r1, #GPIO_ODR]

	#wait
	bl delay

	#Turn off all lights

	ldr r2, [r1, #GPIO_ODR]
	movw r3, #0xF7E0
	bic r2, r2, r3
	str r2, [r1, #GPIO_ODR]

	#wait
	bl delay

	#go back to turn all light
	b turn_on

delay:
	ldr r3, =0x00200000
1:
	subs r3, r3, #1
	# branch backward to local label '1' (1b) if not equal (NE) to 0
	bne 1b
	bx lr

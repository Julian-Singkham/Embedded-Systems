#Main.s
#Julian Singkham
#CE 2801
#Lab 3
#Description: Initialize LED

#Light are on PB5-PB15 (PB11 not used)

.syntax unified
.cpu cortex-m4
.thumb
.section .text

	.equ RCC_BASE, 0x40023800 //base address for clock: ie gives clock to peripherals
	.equ RCC_AHB1ENR, 0x30 //0x40023830 is the location of the "Turns on GPIO peripherls"
	.equ RCC_GPIOBEN, 1<<1 // Shift the value 1 to the left once

	.equ GPIOB_BASE, 0x40020400//Address for the GPIOB (thing that actually controls GPIOB)
	.equ GPIO_MODER, 0x00 //Length of an individual pin's function (offset)
	.equ GPIO_ODR, 0x14  //Output data register for a specifac GPIO.

.global num_to_LED_init

num_to_LED_init:
	push {r2, r3}
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

	pop {r2, r3}
	bx lr

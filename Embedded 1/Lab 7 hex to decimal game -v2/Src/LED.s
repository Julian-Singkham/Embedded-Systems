#LED.s
#Julian Singkham
#CE 2801
#Lab 7
#Description: LED

#Light are on PB5-PB15 (PB11 not used)

.syntax unified
.cpu cortex-m4
.thumb
.section .text

	.equ GPIOB_BASE, 0x40020400	//Address for the GPIOB (thing that actually controls GPIOB)
	.equ GPIO_MODER, 0x00 		//Pin function (2 bits)
	.equ GPIO_ODR, 0x14  		//Output data register for a specifac GPIO.
	.equ GPIOB_BSRR, 0x18 		//0x40020418 is the location of the bit set/reset 31:16 reset 15:0 sets
	.equ BSRR_RESET, 0xFFFF0000

.global led_setup
.global led_turn_on
.global led_turn_off
.global led_num

#r10: internal = Temp 3
#r11: internal = Temp 2
#r12: internal = Temp 1

#Moves enables the led
led_setup:
	push {r10-r12, lr}

	#Enable PB5-PB10, PB12-PB15 to be outputs
	ldr r12, =GPIOB_BASE
	ldr r11, [r12, #GPIO_MODER]

	movw r10, #0x5400
	movt r10, #0x5515
	orr r11, r11, r10

	movw r10, #0xA800
	movt r10, #0xAA2A
	bic r11, r11, r10

	str r11, [r12, #GPIO_MODER]
	
	pop {r10-r12, pc}

#Turns on all the leds
led_turn_on:
	push {r10-r12, lr}
	ldr r12, =GPIOB_BASE
	ldr r11, [r12, #GPIO_ODR]
	movw r10, #0xF7E0
	orr r11, r11, r10
	str r11, [r12, #GPIO_ODR]
	pop {r10-r12, pc}

#Turns off all the leds
led_turn_off:
	push {r10-r12, lr}
	ldr r12, =GPIOB_BASE
	ldr r11, [r12, #GPIO_ODR]
	movw r10, #0xF7E0
	bic r11, r11, r10
	str r11, [r12, #GPIO_ODR]
	pop {r10-r12, pc}

#Turns on the leds based on the given number
#r1: input = number to display
led_num:
	push {r1, r11-r12, lr}
	ldr r12, =GPIOB_BASE
	ldr r11, =BSRR_RESET
	str r11, [r12, #GPIOB_BSRR] //turn off LED
	mov r11, #0
	bfi r11, r1, #5, #6 //Grab the bottom 6
	lsr r1, r1, #6
	bfi r11, r1, #12, #4 //Grab the top 4

	str r11, [r12, #GPIOB_BSRR]	//Turn LEDs on

	pop {r1, r11-r12, pc}
	bx lr
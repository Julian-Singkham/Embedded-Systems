#Buzzer.s
#Julian Singkham
#CE 2801
#Lab 6
#Description: Piezo Buzzer

.syntax unified
.cpu cortex-m4
.thumb
.section .text

	.equ RCC_BASE, 0x40023800 //base address for clock
	.equ RCC_AHB1ENR, 0x30 //location for Turn on GPIOx
	.equ RCC_GPIOBEN, 1<<1 // Shift the value 1 to the left once
	.equ RCC_APB1ENR, 0x40 //location for Turn TIMx

	.equ GPIOB_BASE, 0x40020400//Address for the GPIOB (thing that actually controls GPIOB)
	.equ GPIO_MODER, 0x00 //Length of an individual pin's function (offset)
	.equ GPIO_AFRL, 0x20

	.equ TIMx_ARR, 0x2C
	.equ TIMx_CCR2, 0x38
	.equ TIMx_CCR1, 0x34
	.equ TIMx_CCMR1, 0x18
	.equ TIMx_CCER, 0x20
	.equ TIMx_CR1, 0x00
	.equ TIM3_BASE, 0x40000400

.global piezo_setup
.global piezo_play
.global piezo_off

#Activates TIM3 and sets the Pizeo pins
piezo_setup:
	push {r10-r12, lr}

	# enable clock to TIM3 
	ldr r12, =RCC_BASE 
	ldr r11, [r12, RCC_APB1ENR]
	orr r11, r11, #0b10 // TIM3 is bit 1 
	str r11, [r12, RCC_APB1ENR] 
	#enable clock to GPIOB
	ldr r11, [r12, RCC_AHB1ENR] 
	orr r11, r11, #0b10 // GPIOB is bit 1
	str r11, [r12, RCC_AHB1ENR] 

	# Set AF to 2
	ldr r12, =GPIOB_BASE 
	ldr r11, [r12, GPIO_AFRL] 
	bic r11, r11, #(0b1111<<16)
	orr r11, r11, #(0b0010<<16) // AF 2
	str r11, [r12, GPIO_AFRL] 
	# Set PB4 to Alternate mode
	ldr r11, [r12, GPIO_MODER] 
	bic r11, r11, #(0b11<<8)
	orr r11, r11, #(0b10<<8)
	str r11, [r12, GPIO_MODER]
	
	pop {r10-r12, pc}

#Disables Pizeo
piezo_off:
	push {r11-r12, lr}

	#Disbale counter
	ldr r12, =TIM3_BASE
	ldr r11, [r12, TIMx_CR1]
	mov r11, #0
	str r11, [r12, TIMx_CR1]

	pop {r11-r12, pc}

#Plays a tone with the Piezo
#r1:input = amount of ticks (clock/[r1*2]=hz)
piezo_play:
	push {r11-r12, lr}

	ldr r12, =TIM3_BASE

	#Enable counter
	ldr r11, [r12, TIMx_CR1]
	mov r11, #1
	str r11, [r12, TIMx_CR1]

	#set the reset count: period -1
	add r11, r1, r1
	sub r11, r11, #1
	str r11, [r12,TIMx_ARR]

	#Set position of toggle
	mov r11, #0
	str r11, [r12,TIMx_CCR1]

	#Set output mode to toggle
	mov r11, #0b011<<4 // OC1M = 011 - PWM Mode 1
	str r11, [r12,TIMx_CCMR1]

	# compare output enable 
	movw r11, #1 //CC2E =1
	str r11, [r12,TIMx_CCER]
	
	pop {r11-r12, pc}

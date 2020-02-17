#Temp.s
#Julian Singkham
#CE 2801
#Lab 8
#Description: Temperature Sensor
.syntax unified
.cpu cortex-m4
.thumb
.section .text

	.equ RCC_BASE, 0x40023800    //base address for clock
	.equ RCC_AHB1ENR, 0x30          //Peripheral enable 1 (GPIOx)
	.equ RCC_GPIOBEN, 0x2

	.equ GPIOB_BASE, 0x40020400 //Address for the GPIOB
	.equ GPIO_MODER, 0x00		//Pin function (2 bits)
    .equ GPIO_ODR, 0x14			//Pin output (going out)
    .equ GPIO_IDR, 0x10			//pin input (going in)

.global temp_setup
.global get_temp

#r0: output = return value
#r11: internal = Temp 2
#r12: internal = Temp 1
temp_setup:
	push {r11, r12, lr}

	ldr r12, =RCC_BASE

	#Enable GPIOB
	ldr  r11, [r12, #RCC_AHB1ENR]
	orr  r11, r11, #RCC_GPIOBEN
	str  r11, [r12, #RCC_AHB1ENR]

	#Set GPIOB as analog
	ldr r12, =GPIOB_BASE
	ldr r11, [r12, #GPIO_MODER]
	orr r11, r11, #0b11 //analog
	str r11, [r12, #GPIO_MODER]

	pop  {r11, r12, pc}

#r0: Output : Temperature raw value
get_temp:
	push {r11, r12, lr}

	ldr r12, =GPIOB_BASE
	ldr r11, [r12, #GPIO_IDR]
	ubfx r0, r11, #0, #1

	pop  {r11, r12, pc}

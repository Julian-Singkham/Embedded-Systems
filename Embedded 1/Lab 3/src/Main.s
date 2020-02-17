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

.equ VALUE, 0x4D2
.equ DELAY_TIME, 0x1F4//0x1F4

.global main

//r0 = main value setter (decimal value or time)
//r1 = GPIOB_BASE
//r2= BCD value
//r12 = temporary variable
main:
#Initialize the LED
	bl num_to_LED_init

#Convert to ASCII
	ldr r0, =VALUE
	bl num_to_ASCII
	mov r2, r0

1:
#Send ASCII value to LED
	mov r12, #0
    ubfx r12, r2, #24, #8 //first digit
    mov r0, r12
	bl num_to_LED
	ldr r0, =DELAY_TIME
	bl delay_ms

	mov r12, #0
    ubfx r12, r2, #16, #8 //second digit
    mov r0, r12
	bl num_to_LED
	ldr r0, =DELAY_TIME
	bl delay_ms

	mov r12, #0
    ubfx r12, r2, #8, #8 //third digit
    mov r0, r12
	bl num_to_LED
	ldr r0, =DELAY_TIME
	bl delay_ms

	mov r12, #0
    bfi r12, r2, #0, #8 //fourth digit
    mov r0, r12
	bl num_to_LED
	ldr r0, =DELAY_TIME
	bl delay_ms
	b 1b

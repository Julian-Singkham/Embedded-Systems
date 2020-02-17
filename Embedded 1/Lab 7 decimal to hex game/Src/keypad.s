#keypad.s
#Julian Singkham
#CE 2801
#Lab 5
#Description: Reads data from the keypad
#Assume only one button can be pressed at any given time

.syntax unified
.cpu cortex-m4
.thumb
.section .text
	.equ INSTRUCTIONS_PER_500_MS, 0x9C4000

	.equ RCC_BASE, 0x40023800	//base address for clock
    .equ RCC_AHB1ENR, 0x30 		//Peripheral enable 1 (GPIOx)
    .equ RCC_GPIOCEN, 0x4		

    .equ GPIOC_BASE, 0x40020800	//Address for the GPIOC
    .equ GPIO_MODER, 0x00		//Pin function (2 bits)
    .equ GPIO_ODR, 0x14			//Pin output (going out)
    .equ GPIO_IDR, 0x10			//pin input (going in)
    .equ GPIO_PUPDR, 0x0C		//Sets pin as pullup/pulldown
	.equ GPIOC_PULLUP, 0x5555	//value to set columns as pullup
	
.global key_setup
.global key_getkey_noblock
.global key_getkey
.global key_getchar
.global key_scan_col

#r0: output = return value
#r1: input  = Parameter 1 for subroutine calls
#r2: input  = Parameter 2 for subroutine calls
#r2: input  = Parameter 3 for subroutine calls
#r10: internal = Temp 3
#r11: internal = Temp 2
#r12: internal = Temp 1

#Code to initialize the keypad
key_setup:
	#Set up Ports
	push {r10-r12, lr}
    ldr r12, =RCC_BASE
	ldr r11, [r12, #RCC_AHB1ENR]
    orr r11, r11, #RCC_GPIOCEN
	str r11, [r12, #RCC_AHB1ENR]

	ldr r12, =GPIOC_BASE
	ldr r11, [r12, #GPIO_PUPDR]
	ldr r10, =GPIOC_PULLUP
	orr r11, r11, r10
	str r11, [r12, #GPIO_PUPDR]
	pop {r10-r12, pc}

#Returns the key that was pressed (does not wait until the button is not pressed)
#r0:output = what key was pressed
key_getkey_noblock:
	push {r1-r3, r11-r12, lr}

	#Wait for the button to stabalize and then read
	mov r1, #10 //10 us delay
	bl delay_us
	ldr r12, =GPIOC_BASE
	ldr r11, [r12, #GPIO_IDR]
	ubfx r2, r11, #0, #4
	eor r2, #0xFF
	ubfx r2, r2, #0, #4

	bl key_scan_row
	
	#Wait for the button to stabalize and then read
	mov r1, #10 //10 us delay
	bl delay_us
	ldr r12, =GPIOC_BASE
	ldr r11, [r12, #GPIO_IDR]
	ubfx r3, r11, #4, #4
	eor r3, #0xFF
	ubfx r3, r3, #0, #4

	bfi r2, r3, #4, #4
	bl key_get
	pop {r1-r3, r11-r12, pc}

#Waits until the button is not pressed before returning
#r0:output = what key was pressed
key_getkey:
	push {r1-r3, r10-r12, lr}

	#Wait for the button to stabalize and then read
	mov r1, #1 //10 us delay
	bl delay_us
	ldr r12, =GPIOC_BASE
	ldr r11, [r12, #GPIO_IDR]
	ubfx r2, r11, #0, #4
	eor r2, #0xFF
	ubfx r2, r2, #0, #4

	bl key_scan_row
	
	#Wait for the button to stabalize and then read
	mov r1, #10 //1 us delay
	bl delay_us
	ldr r12, =GPIOC_BASE
	ldr r11, [r12, #GPIO_IDR]
	ubfx r3, r11, #4, #4
	eor r3, #0xFF
	ubfx r3, r3, #0, #4

1: //loop until the button is not pressed
	mov r1, #10 //10 us delay
	bl delay_us
	ldr r11, [r12, #GPIO_IDR]
	ubfx r10, r11, #4, #4
	cmp r10, #15
	bne 1b

	bfi r2, r3, #4, #4
	bl key_get
	pop {r1-r3, r10-r12, pc}

#Same as key_getkey, but converts the key value to ASCII
#r0:input/output = Comes in as a key value, exits as an ASCII value
key_getchar:
	push {r10, r12, lr}
	bl key_getkey_noblock

	ldr r12, =b01 //Load the memory location of the ASCII Map
	cmp r0, #0
	beq 1f
	sub r0, r0, #1
	add r0, r0, r0
	ldrh r10, [r12, r0]
	mov r0, r10
1:
	pop {r10, r12, pc}

#Based on the row/col return the key
#r2:input = 7-4 rows, 3-0 columns
#r0:output = What button was pressed
key_get:
	push {r12, lr}
	mov r0, #0
	mov r12, r2

	#1
	cmp r12, #0x11
	IT eq
	moveq r0, #1
	beq 1f
	
	#2
	cmp r12, #0x12
	IT eq
	moveq r0, #2
	beq 1f

	#3
	cmp r12, #0x14
	IT eq
	moveq r0, #3
	beq 1f

	#10 (A)
	cmp r12, #0x18
	IT eq
	moveq r0, #10
	beq 1f

	#4
	cmp r12, #0x21
	IT eq
	moveq r0, #4
	beq 1f
	
	#5
	cmp r12, #0x22
	IT eq
	moveq r0, #5
	beq 1f

	#6
	cmp r12, #0x24
	IT eq
	moveq r0, #6
	beq 1f

	#11 (B)
	cmp r12, #0x28
	IT eq
	moveq r0, #11
	beq 1f

	#7
	cmp r12, #0x41
	IT eq
	moveq r0, #7
	beq 1f
	
	#8
	cmp r12, #0x42
	IT eq
	moveq r0, #8
	beq 1f

	#9
	cmp r12, #0x44
	IT eq
	moveq r0, #9
	beq 1f

	#12 (C)
	cmp r12, #0x48
	IT eq
	moveq r0, #12
	beq 1f

	#*
	cmp r12, #0x81
	IT eq
	moveq r0, #14
	beq 1f
	
	#0
	cmp r12, #0x82
	beq 1f

	##
	cmp r12, #0x84
	IT eq
	moveq r0, #15
	beq 1f

	#13 (D)
	cmp r12, #0x88
	IT eq
	moveq r0, #13
	beq 1f

	#No button was pressed
	pop {r12, pc}
1:
	add r0, r0, #1
	pop {r12, pc}


#Turn Rows to outputs, Columns to inputs
key_scan_col:
	push {r10-r12, lr}
	ldr r12, =GPIOC_BASE
	ldr r11, [r12, #GPIO_MODER]
	mov r10, #0xAA00
	bfi r11, r10, #0, #16
	str r11, [r12, #GPIO_MODER]
	pop {r10-r12, pc}

#Turn Columns to outputs, Rows to inputs
key_scan_row:
	push {r10-r12, lr}
	ldr r12, =GPIOC_BASE
	ldr r11, [r12, #GPIO_MODER]
	mov r10, #0x0055
	bfi r11, r10, #0, #16
	str r11, [r12, #GPIO_MODER]	
	pop {r10-r12, pc}

#Each memory location is 2 bytes big
.data
	b01: .asciz "0"
	b02: .asciz "1"
	b03: .asciz "2"
	b04: .asciz "3"
	b05: .asciz "4"
	b06: .asciz "5"
	b07: .asciz "6"
	b08: .asciz "7"
	b09: .asciz "8"
	b10: .asciz "9"
	b11: .asciz "A"
	b12: .asciz "B"
	b13: .asciz "C"
	b14: .asciz "D"
	b15: .asciz "E"
	b16: .asciz "F"

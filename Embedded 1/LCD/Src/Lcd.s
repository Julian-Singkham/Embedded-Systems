#LCD.s
#Julian Singkham
#CE 2801
#Lab 4
#Description: LCD Functions 

.syntax unified
.cpu cortex-m4
.thumb
.section .text

	.equ RCC_BASE, 0x40023800 //base address for clock: ie gives clock to peripherals
    .equ RCC_AHB1ENR, 0x30 //0x40023830 is the location of the "Turns on GPIO peripherls"
    .equ RCC_GPIOAEN, 0x1
    .equ RCC_GPIOCEN, 0x4

    .equ GPIOA_BASE, 0x40020000
    .equ GPIOC_BASE, 0x40020800
    .equ GPIO_MODER, 0x00
    .equ GPIO_ODR, 0x14
    .equ GPIO_IDR, 0x10
    .equ GPIO_BSRR, 0x18

	#input only
	.equ RS, 0x100 //PC8 
	.equ RW, 0x200 //PC9 
	.equ E,	 0x400 //PC10

    .equ INITIALIZE_DELAY, 0xFAF00 //40ms delay
    .equ MAX_VALUE, 0x270F

    .global lcd_clear
    .global lcd_init
    .global lcd_home
    .global lcd_print_num
    .global lcd_print_string
    .global lcd_set_position
    .global error

#r0: output = return value
#r1: input  = Parameter 1 for subroutine calls
#r2: input  = Parameter 2 for subroutine calls
#r9:  internal = Temp 4
#r10: internal = Temp 3
#r11: internal = Temp 2
#r12: internal = Temp 1

#Code to initialize the LCD
lcd_init:
	push {r1, r11, r12, lr}
	bl setup_ports

	ldr r12, =INITIALIZE_DELAY
1:  //Wait 40ms
    subs r12, r12, #1
    bne 1b

    #Write Function Set (0x38)
    mov r1, #0x38
    bl write_instruction
    mov r1, #0x38
    bl write_instruction

    #Write Display On/Off(0x0F)
    mov r1, #0x0F
    bl write_instruction
    bl lcd_delay

    #Write Display Clear (0x01)
    bl lcd_clear
    bl write_instruction

    #Write Entry Mode Set (0x06)
    mov r1, #0x06
    bl write_instruction

	pop {r1, r11, r12, pc}

setup_ports:
	 #Set up Ports
    ldr r12, =RCC_BASE
	ldr r11, [r12, #RCC_AHB1ENR]
	orr r11, r11, #RCC_GPIOAEN
    orr r11, r11, #RCC_GPIOCEN
	str r11, [r12, #RCC_AHB1ENR]

	#Turn GPIOA to output
	ldr r12, =GPIOA_BASE
	ldr r11, [r12, #GPIO_MODER]
	ldr r10, =0x00555500
	orr r11, r11, r10
	str r11, [r12, #GPIO_MODER]

	#Turn GPIOC to output
	ldr r12, =GPIOC_BASE
	ldr r11, [r12, #GPIO_MODER]
	ldr r10, =0x00150000
	orr r11, r11, r10
	str r11, [r12, #GPIO_MODER]

	bx lr

#Clear the LCD Display
lcd_clear:
    push {r1, lr}
    ldr r1, =0x1
    bl write_instruction
    bl lcd_delay
    pop {r1, pc}

#Moves the curser back to home (Upper left hand corner)
lcd_home:
    push {r1, lr}
    mov r1, #0x02
    bl write_instruction
    bl lcd_delay
    pop {r1, pc}

#Prints a decimal number to the display
#Can only print number between 0 and 9999
#r1 = binary number to print
lcd_print_num:
    push {r1, r12, lr}
	#check if the values are not within range 0-9999
	cmp r1, #0
    bmi error
    ldr r12, =MAX_VALUE
    cmp r1, r12
    bgt error

	bl num_to_ascii
	ubfx r1, r0, #24, #8
	bl write_data

	ubfx r1, r0, #16, #8
	bl write_data

	ubfx r1, r0, #8, #8
	bl write_data

	ubfx r1, r0, #0, #8
	bl write_data

	pop {r1, r12, pc}

# Prints a null terminated string to the display
# r1: input  = address to the string
# r0: output = number of characters written
lcd_print_string:
    push {r1, r11-r12, lr}

	mov r0, #0 // counter
	mov r12, r1 // base address
	mov r11, #0 // offset

next_byte:
	ldrb r1, [r12, r11]

    #exit if there's no more bytes
	cmp r1, #0
	beq 1f

	bl write_data
	add r11, r11, #1
	add r0, r0, #1
	b next_byte

1:
	pop  {r1, r11-r12, pc}

#Moves Cursor to location
#r1: input = row
#r2: input = col
lcd_set_position:
	push {r1-r2, r12, LR}

	bl lcd_home

    #check if the cursor needs to move up/down
	mov r12, r2
	cmp r1, #0
	beq dont_change_line

	# second line starts at 41st digit.
	add r12, r12, #40

dont_change_line:
	cmp r12, #0
	beq dont_move_cursor

1:
	mov r1, #0x14
 	bl write_instruction

	bl lcd_delay

	subs r12, r12, #1
	bne 1b

dont_move_cursor:
	pop {r1-r2, r12, PC}


#Delays the program until the busy flag is off
#Could not implement the busy flag delay, a busy wait is used instead.
lcd_delay:
	push {r10-r12, lr}
    #bl read_instruction
    #ldr r12, =GPIOA_BASE
    mov r12, #0x7D00
1:
 #   ldr r11, [r12, #GPIO_IDR]
  #  ubfx r10, r11, #11, #1
    #check busy flag
    #cmp r10, #0
    subs r12, r12, #1
    bne 1b
    pop {r10-r12, pc}

#DID NOT IMPLEMENT
#Reads Instructions
#RS=0 RW=1 
read_instruction:
    push {lr}

    pop {pc}

#Writes instruction
#r1 = Instruction to write
write_instruction:
	push {r9-r12, LR}
    ldr r12, =GPIOA_BASE
    ldr r11, =GPIOC_BASE

	#Set RS=0,RW=0,E=1
    mov r10, #0
    bic r10, r10, #RS
	bic r10, r10, #RW
	orr r10, r10, #E
    str r10, [r11, #GPIO_ODR]

	#Send R1 to data pins
    bfi r9, r1, #4, #8
    str r9, [r12, #GPIO_ODR]

	#Set E=0
    bic r10, r10, #E
	str r10, [r11, #GPIO_ODR]
    bl lcd_delay
	pop {r9-r12, PC}

#Writes data (ascii value) to the cursor location
#r1 = ascii byte to print
write_data:
    push {r9-r12, LR}
	ldr r12, =GPIOA_BASE
	ldr r11, =GPIOC_BASE

	# set RW=0, RS=1 E=1
	mov r10, #0
	bic r10, r10, #RW
	orr r10, r10, #RS
	orr r10, r10, #E
	str r10, [r11, #GPIO_ODR]

	# write data
	ubfx r9, r1, #0, #8
	lsl r9, r9, #4
	str r9, [r12, #GPIO_ODR]

	# set E=0
	bic r10, r10, #E
	str r10, [r11, #GPIO_ODR]

	bl lcd_delay

	pop  {r9-r12, pc}

#Error message
error:
    mov r1, 'E'
	bl write_data

	mov r1, 'r'
	bl write_data

	mov r1, 'r'
	bl write_data

	mov r0, #0

	pop {r1, r12, pc}

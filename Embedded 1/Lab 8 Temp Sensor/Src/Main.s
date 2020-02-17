#Main.s
#Julian Singkham
#CE 2801
#Lab 8
#Description: Read values from the temperature sensor, save to ram, and display them onto the LCD
#‘*’ – buffer on/off.  When in buffer mode, all samples are stored to RAM.  Upon turning buffer mode off,
#all currently buffered samples will be displayed and subsequent samples transmitted upon collection.
	#'A' - Display buffered results
#‘#’ – allows user to set the interval in seconds between samples (1 - 9 seconds)
#'B' - allows user to set the buffer size (number of samples maintained [01-99])
#'D' - Toggles between displaying temperature in C or F

#Default Continuous mode (display results with as they are computed)

.syntax unified
.cpu cortex-m4
.thumb
.section .text

	.equ ADC_CR2, 0x08
	.equ ADC_SR, 0x00
	.equ ADC_DR, 0x4C
	.equ AHB1ENR_OFFSET, 0x30
	.equ GPIOB_EN, 1<<1
	.equ APB2ENR_OFFSET, 0x44
	.equ ADC1_EN, 1<<8
	.equ ADC_SQR3, 0x34
	.equ RCC_BASE, 0x40023800
	.equ ADC1_BASE, 0x40012000

.global main
.global convert_to_temp
.global print_reading
.global is_buffer_mode
.global inc_buffer_pos

main:
	bl key_setup
	bl lcd_setup
	bl temp_setup
	bl adc_setup
	bl timer_setup
	bl piezo_setup

loop:
	bl key_getchar

	cmp r0, 'D'
	beq set_temp_unit

	cmp r0, '#'
	beq set_interval

	cmp r0, 'B'
	beq set_buffer_size

	cmp R0, '*'
	beq toggle_buffer_mode

	b loop

#Toggles buffer mode on/off
toggle_buffer_mode:
	bl disable_ADC_interrupt
	bl lcd_clear
	ldr r1, =buffer_mode_on_msg
	bl lcd_print_string

	#move to next line
	mov r1, #1
	mov r2 ,#0
	bl lcd_set_position

	ldr r1, =buffer_mode_clear_msg
	bl lcd_print_string

#Loop until A has been pressed
buffer_loop:

	bl key_getchar
	cmp r0, 'A'
	bne buffer_loop
	beq clear_buffer

#flash the buffer
clear_buffer:
	ldr r12, =buffer_size
	ldrb r11, [r12] //offset
	bl lcd_clear
	bl lcd_home

1:	//print every temp. reading to the LCD
	ldr r1, [r12, r11]
	bl convert_to_temp
	bl lcd_home
	bl print_reading

	mov r1, #1
	bl delay_sec

	subs r11, r11, #1
	bne 1b

	bl lcd_clear
	bl enable_ADC_interrupt

	b loop

#Sets the temperature measurement to C/F
set_temp_unit:
	ldr r12, =temp_mode
	ldrb r11, [r12]

	cmp r11, #0
	beq 1f
	bne 2f

1:  //fahrenheit Mode
	mov r11, #1
	b write

2:  //Celcius Mode
	mov r11, #0

write:  //Save the unit of measure
	strb r11, [r12]
	b loop

#Sets the interval in seconds between samples (1 - 9 seconds)
set_interval:
	bl disable_ADC_interrupt
	bl lcd_clear
	ldr r1, =set_interval_msg1
	bl lcd_print_string

	#move next line
	mov r1, #1
	mov r2, #0
	bl lcd_set_position

	ldr r1, =set_interval_msg2
	bl lcd_print_string

	#get value from keypad and print it
1:
	bl key_getchar
	cmp r0, #0x31
	blt 1b
	cmp r0, #0x39
	bgt 1b

	mov r1, r0
	sub r1, r1, #0x30
	ubfx r1, r1, #0, #4
	bl timer_temperature_set

	bl lcd_clear
	bl enable_ADC_interrupt

	b loop

#Sets the size of the buffer with keypad
set_buffer_size:
	bl disable_ADC_interrupt
	bl lcd_clear
	ldr r1, =set_buffer_size_msg1
	bl lcd_print_string

1:
	bl key_getchar
	cmp r0, #0x31
	blt 1b
	cmp r0, #0x39
	bgt 1b

	mov r1, r0
	sub r1, r1, #0x30
	// update buffer size
	ubfx r1, r1, #0, #4
	ldr r12, =buffer_size
	strb r1, [r12]

	//clear the buffer
	mov r11, #0
	ldr r12, =buffer_pos
	strb r11, [r12]

	bl lcd_clear
	bl enable_ADC_interrupt

	b loop

#r1 : input = binary time
print_reading:
	push {r1, r10-r12, lr}

	bl num_to_bcd

	ubfx r12, r0, #8, #4  // tens
	ubfx r11, r0, #4, #4  // ones
	ubfx r10, r0, #0, #4  // tenths

	// convert to ascii
	add r12, r12, #0x30
	add r11, r11, #0x30
	add r10, r10, #0x30

	mov r1, r12
	bl lcd_write_data

	mov r1, r11
	bl lcd_write_data

	mov r1, '.'
	bl lcd_write_data

	mov r1, r10
	bl lcd_write_data

	mov r1, '~'
	bl lcd_write_data

	bl get_temp_unit
	mov r1, r0
	bl lcd_write_data

	pop  {r1, r10-r12, pc}

#Gets the ASCII character for the temperature
#r0: output = ASCII unit of measure
get_temp_unit:
	push {r12, lr}

	ldr r12, =temp_mode
	ldrb r0, [r12]

	cmp r0, #0
	ite eq
	moveq r0, 'C'
	movne r0, 'F'

	pop  {r12, pc}

#Returns if the buffer is on or not
#r0: output = buffer mode
is_buffer_mode:
	push {r12, lr}

	ldr r12, =buffer_mode
	ldrb r0, [r12]

	pop  {r12, pc}
#increments the buffer position in memory
inc_buffer_pos:
	push {r10-r12, lr}
	#load the location of the buffer position
	ldr r12, =buffer_pos
	ldrb r11, [r12]

	#load the size of the buffer
	ldr r10, =buffer_size
	ldrb r10, [r10]

	#compare the current position of the buffer to the size
	cmp r10, r11
	ite eq
	moveq r11, #0
	#move the buffer position if the buffer isnt filled
	addne r11, r11, #1

	strb r11, [r12]

	pop  {r10-r12, pc}

#check later
.section .data

	.global temp_mode
	.global buffer_mode
	.global buffer_pos
	.global buffer_size
	.global temperature_buffer

	set_interval_msg1:     .asciz "Set interval 1-9"
	set_interval_msg2:     .asciz "Seconds: "

	set_buffer_size_msg1:  .asciz "Set Buffer Size"

	buffer_mode_on_msg:    .asciz "Buffer Mode On"
	buffer_mode_clear_msg: .asciz "Press A to exit"

	buffer_mode:     .byte 0 // 0->no buffer | 1->buffer
	temp_mode:       .byte 0 // 0->Celsius | 1->Fahrenheit
	continuous_mode: .byte 0 // 1->write values to lcd when calculated

	interval:        .byte 1 // [1-9]
	buffer_size:     .byte 10 // [1-9]
	buffer_pos:      .byte 0 // [1-buffer_size]

	.balign 4
	temperature_buffer:
		.space 10

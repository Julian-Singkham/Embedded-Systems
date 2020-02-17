#Main.s
#Julian Singkham
#CE 2801
#Lab 6
#Description: Keypad Lock

.syntax unified
.cpu cortex-m4
.thumb
.section .text

	.equ HAPPY_BUZZ, 0x640
	.equ SAD_BUZZ,   0xFA0
#r11 = row for LCD
#r12 = col for LCD
#r10 = counter for password digits
#r9  = password input
.global main
main:
 	//bl KeyInt
	bl lcd_init
	bl led_setup
	bl piezo_setup
	mov r12, #0 //LCD Col
	mov r11, #0 //LCD Row

start:
	mov r10, #4 //password is 4 digits
	mov r9,  #0
	ldr r1, =password_msg1
	bl lcd_print_string
	bl next_line
	ldr r1, =password_msg2
	bl lcd_print_string
	mov r12, #12

1:
	cmp r10, #0
	beq check_password
	cmp r12, #16 //check to see if the cursor is out of bounds column wise
	beq next_line
	bl KeyGetchar
	cmp r0, #0
	beq 1b

	mov r1, r0
	add r9, r0, r9, lsl#8
	bl lcd_write_data
	add r12, r12, #1
	sub r10, r10, #1
	b 1b

	#KeyScanCOl

move_cursor://Move Cursor
	mov r2, r12
	mov r1, r11
	bl lcd_set_position
	b 1b

next_line: //Move to next line
	push {lr}
	cmp r11, #1
	beq reset_lcd
	mov r11, #1
	mov r12, #0
	mov r2, r12
	mov r1, r11
	bl lcd_set_position
	pop {pc}

#Clear the display when there is no more room on the LCD
reset_lcd:
	bl piezo_off
	bl led_turn_off
	bl lcd_clear
	mov r12, #0
	mov r11, #0
	bl lcd_home
	b start

check_password:
	ldr r10, =code
	ldr r10, [r10]
	cmp r9, r10
	bne fail
	b sucess

sucess:
	bl lcd_clear
	bl lcd_home
	mov r11, #0
	mov r12, #0
	ldr r1, =success_msg
	bl lcd_print_string
	bl next_line
	ldr r1, =replay_msg
	bl lcd_print_string
	ldr r1, =HAPPY_BUZZ
	bl piezo_play
	bl led_turn_on
	b check_restart

fail:
	bl lcd_clear
	bl lcd_home
	mov r11, #0
	mov r12, #0
	ldr r1, =fail_msg
	bl lcd_print_string
	bl next_line
	ldr r1, =replay_msg
	bl lcd_print_string
	ldr r1, =SAD_BUZZ
	bl piezo_play
	b check_restart

check_restart:
	bl KeyGetchar
	cmp r0, '*'
	bne check_restart
	b reset_lcd

.data
	password_msg1: .asciz "Enter password"
	password_msg2: .asciz "4 digit:"
	fail_msg: .asciz "Ya done goofed"
	success_msg: .asciz "You shall pass"
	replay_msg: .asciz "* to restart"
	code: .asciz "7331" //stored in little endian, so the real value is 1337
	input_password: .asciz ""

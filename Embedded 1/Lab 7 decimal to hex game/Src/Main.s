#Main.s
#Julian Singkham
#CE 2801
#Lab 7
#Description: Binary to Hex Game with Interrupts

.syntax unified
.cpu cortex-m4
.thumb
.section .text

	.equ HAPPY_BUZZ, 0x640
	.equ SAD_BUZZ,   0xFA0

	.equ TEST_1,   0b1010
	.equ TEST_2,   0b0110
	.equ TEST_3,   0b0011
	.equ TEST_4,   0b1001
	.equ TEST_5,   0b1101

#r11 = row for LCD
#r12 = col for LCD
#r10 = correct value
#r9  = user input
.global main
main:
	bl timer_setup
	bl piezo_setup
	bl lcd_setup
 	bl key_setup
	bl interupt_setup
	bl led_setup
	mov r12, #0 //LCD Col
	mov r11, #0 //LCD Row
	bl start
	bl trial_1

30:
	b 30b

start:
	push {r1, lr}
	ldr r1, =ready_msg
	bl lcd_print_string
	mov r1, #1 //1 sec delay
	bl delay_sec
	bl delay_sec
	bl lcd_clear

	ldr r1, =set_msg
	bl lcd_print_string
	mov r1, #1 //1 sec delay
	bl delay_sec
	bl lcd_clear

	ldr r1, =go_msg
	bl lcd_print_string
	mov r1, #1 //1 sec delay
	bl delay_sec
	bl lcd_clear
	pop {r1, pc}

trial_1:
	push {r10, lr}
	ldr r10, =TEST_1
	bl key_scan_col
1:
	ldr r9, =key_pressed
	ldrb r9, [r9]
	cmp r9, #0
	beq 1b

	ldr r1, =key_pressed
	bl lcd_print_string
	b 30b

	pop {r10, pc}

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
	bl lcd_clear
	mov r12, #0
	mov r11, #0
	bl lcd_home
	b start

check_password:
	push {lr}

	cmp r10, r9
	bne fail
	b sucess

	pop {pc}

sucess:
	push {lr}

	bl lcd_clear
	bl lcd_home
	mov r11, #0
	mov r12, #0

	ldr r1, =success_msg
	bl lcd_print_string
	bl next_line
	ldr r1, =time_msg
	bl lcd_print_string
	ldr r1, =ms_msg
	bl lcd_print_string

	ldr r1, =HAPPY_BUZZ
	bl piezo_play
	
	mov r1, #3 //3 sec delay
	bl delay_sec

	pop {pc}

fail:
	push {lr}
	bl lcd_clear
	bl lcd_home
	mov r11, #0
	mov r12, #0

	ldr r1, =fail1_msg
	bl lcd_print_string
	bl next_line
	ldr r1, =fail2_msg
	bl lcd_print_string
	ldr r1, [r10]
	bl lcd_print_string

	ldr r1, =SAD_BUZZ
	bl piezo_play

	mov r1, #3 //3 sec delay
	bl delay_sec

	pop {pc}

.data
	ready_msg: .asciz "Ready"
	set_msg: .asciz "Set"
	go_msg: .asciz "Go!"
	initial_msg: .asciz "Convert LED hex "

	fail1_msg: .asciz "Ya done goofed"
	fail2_msg: .asciz "The answer is: "

	success_msg: .asciz "You did it"
	time_msg: .asciz "Time: "
	ms_msg: .asciz "ms"

	score_msg: .asciz "Score: 5/6"
	best_time_msg: .asciz "Best T: "

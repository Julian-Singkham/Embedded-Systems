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

#r12 = number of correct answers
#r11 = memory location

#r10 = correct value
#r9  = user input
#r1  = input for sub routines
#r0	 = Value of key pressed
.global main
main:
	#setup
	bl timer_setup
	bl piezo_setup
	bl lcd_setup
 	bl key_setup
	bl led_setup
	mov r12, #0

	# Trials
	bl start
	bl trial_1
	bl start
	bl trial_2
	bl start
	bl trial_3
	bl start
	bl trial_4
	bl start
	bl trial_5

	#End Game
	bl lcd_clear
	ldr r1, =done_msg
	bl lcd_print_string
	b done

#Start of each trial,
start:
	push {r1, lr}
	bl lcd_clear
	bl piezo_off
	ldr r1, =ready_msg
	bl lcd_print_string
	mov r1, #1 //1 sec delay x2
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
	push {lr}
	ldr r10, =TEST_1
	mov r1, r10
	bl led_num
	mov r0, #0
	bl timer_game_start	//Start Timer
1:	//Checks if the key has been pressed
	bl key_getkey_noblock
	cmp r0, #0
	beq 1b
	b check_password

trial_2:
	push {lr}
	ldr r10, =TEST_2
	mov r1, r10
	bl led_num
	mov r0, #0
	bl timer_game_start	//Start Timer
1:	//Checks if the key has been pressed
	bl key_getkey_noblock
	cmp r0, #0
	beq 1b
	b check_password

trial_3:
	push {lr}
	ldr r10, =TEST_3
	mov r1, r10
	bl led_num
	mov r0, #0
	bl timer_game_start	//Start Timer
1:	//Checks if the key has been pressed
	bl key_getkey_noblock
	cmp r0, #0
	beq 1b
	b check_password

trial_4:
	push {lr}
	ldr r10, =TEST_4
	mov r1, r10
	bl led_num
	mov r0, #0
	bl timer_game_start	//Start Timer
1:	//Checks if the key has been pressed
	bl key_getkey_noblock
	cmp r0, #0
	beq 1b
	b check_password

trial_5:
	push {lr}
	ldr r10, =TEST_5
	mov r1, r10
	bl led_num
	mov r0, #0
	bl timer_game_start	//Start Timer
1:	//Checks if the key has been pressed
	bl key_getkey_noblock
	cmp r0, #0
	beq 1b
	b check_password


next_line: //Move to next line
	push {lr}
	mov r2, #0
	mov r1, #1
	bl lcd_set_position
	pop {pc}

check_password:
	sub r0, r0, #1
	cmp r10, r0
	bne fail
	b sucess

#Passed trial
sucess:
	bl timer_game_stop

	bl lcd_clear
	bl lcd_home

	ldr r1, =success_msg
	bl lcd_print_string
	bl next_line

	ldr r1, =time_msg
	bl lcd_print_string
	ldr r1, =time_player
	ldrh r1, [r1]
	bl lcd_print_num
	ldr r1, =ms_msg
	bl lcd_print_string

	ldr r1, =HAPPY_BUZZ
	bl piezo_play
	
	mov r1, #1 //3 sec delay
	bl delay_sec
	bl delay_sec
	bl delay_sec
	add r12, #1

	pop {pc}

#Failed trial
fail:
	bl timer_game_stop
	bl lcd_clear
	bl lcd_home

	ldr r1, =fail1_msg
	bl lcd_print_string
	bl next_line
	ldr r1, =fail2_msg
	bl lcd_print_string
	mov r1, r10
	cmp r1, #9
	bgt 1f

	//hex values 0-9
	add r1, r1, 0x30
	b 2f
1: //hex values A-D
	add r1, r1, #0x37
2:
	bl lcd_write_data

	ldr r1, =SAD_BUZZ
	bl piezo_play

	mov r1, #3 //3 sec delay
	bl delay_sec
	bl delay_sec
	bl delay_sec

	pop {pc}

#End screen
done:
	bl lcd_clear
	bl lcd_home

	ldr r1, =score_msg1
	bl lcd_print_string
	mov r1, r12
	add r1, r1, #0x30
	bl lcd_write_data

	ldr r1, =score_msg2
	bl lcd_print_string
	bl next_line
	ldr r1, =best_time_msg
	bl lcd_print_string
	ldr r1, = time_best_player
	ldrh r1, [r1]
	bl lcd_print_num
	ldr r1, =ms_msg
	bl lcd_print_string

	bl led_turn_off
	bl piezo_off
	b 1f

1:
	b 1b

.data
	ready_msg: .asciz "Ready"
	set_msg: .asciz "Set"
	go_msg: .asciz "Go!"
	initial_msg: .asciz "Convert LED hex "

	fail1_msg: .asciz "Ya done goofed"
	fail2_msg: .asciz "The answer is:"

	success_msg: .asciz "You did it"
	time_msg: .asciz "Time: "
	ms_msg: .asciz "ms"

	score_msg1: .asciz "Score: "
	score_msg2: .asciz "/5"
	best_time_msg: .asciz "Best T: "

#Main.s
#Julian Singkham
#CE 2801
#Lab 4
#Description: Send commands to the LCD

.syntax unified
.cpu cortex-m4
.thumb
.section .text
	.equ INSTRUCTIONS_PER_500_MS, 0x9C4000

.global main
main:
	bl lcd_init

1:
	#print valid number
	mov r1, #1234
	bl lcd_print_num
	#wait half a second
	bl delay
	bl lcd_clear

	#print an invalid number
	mov r1, #0xFFFF
	bl lcd_print_num
	bl delay
	bl lcd_clear

	#Print msg
	ldr r1, =msg
	bl lcd_print_string
	bl delay

	#Move Cursor to home
	bl lcd_home
	bl delay

	#move the cursor to row 2 col 6
	mov r1, #1
	mov r2, #5
	bl lcd_set_position
	bl delay
	bl lcd_clear

	b 1b

#Add a delay between each command so the user can see it
delay:
	push {r12, lr}
	ldr r12, =INSTRUCTIONS_PER_500_MS
1:
	subs r12, r12, #1
	bne 1b

	pop {r12, pc}

.data
	msg: .asciz "Im a string"



#Main.s
#Julian Singkham
#CE 2801
#Lab 5
#Description: Displays what was pressed on the keypad

.syntax unified
.cpu cortex-m4
.thumb
.section .text
	.equ INSTRUCTIONS_PER_500_MS, 0x9C4000

	.equ GPIO_MODER, 0x00

#r11 = row
#r12 = col
.global main
main:
 	bl KeyInt
	bl lcd_init
	mov r12, #0 //LCD Col
	mov r11, #0 //LCD Row

1:
	bl KeyGetchar
	cmp r0, #0
	beq 1b

	mov r1, r0
	bl lcd_write_data
	add r12, r12, #1
	cmp r12, #16
	beq 3f

2://Move Cursor
	mov r2, r12
	mov r1, r11
	bl lcd_set_position
	b 1b

3: //Move to next line
	cmp r11, #1
	beq 4f
	mov r11, #1
	mov r12, #0
	b 2b

4: //Clear the display when there is no more room on the LCD
	bl lcd_clear
	mov r12, #0
	mov r11, #0
	bl lcd_home
	b 1b



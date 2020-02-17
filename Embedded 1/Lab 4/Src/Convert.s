#Main.s
#Julian Singkham
#CE 2801
#Lab 4
#Description: Convert binary to ASCII

.syntax unified
.cpu cortex-m4
.thumb
.section .text

.equ ASCII_ERR, 0x4552522E
.equ MAX_VALUE, 0x270F

.global num_to_ascii

#r0: output = return value
#r1: input  = Parameter 1 for subroutine calls
#r2: input  = Parameter 2 for subroutine calls
#r11: internal = Temp 2
#r12: internal = Temp 1

#convert a binary number to ascii
#r1: input  = binary number to convert
#r0: output = ascii value
num_to_ascii:
	push {r1, lr}
	bl   num_to_bcd
	mov  r1, r0
	bl   bcd_to_ascii
	pop  {r1, pc}

#Convert number to BCD
#r1: input  = binary number to convert
#r0: output = BCD Value
num_to_bcd:
    push {r1, r11-r12, lr}
#check if the values are not within range 0-9999
	cmp r1, #0
    bmi error
    ldr r12, =MAX_VALUE
    cmp r1, r12
    bgt error

#Double Dabble
    mov r0, #0
    mov r11, #16
    bfc r1, #15, #16 //Remove excess bits
1:
    #Once complete exit
    cmp r11, #0
    beq 2f

    #check if each nibble is greater than 4, if it is add 3
    ubfx r12, r0, #0, #4 //fourth nibble
    cmp r12, #4
    IT gt
    addgt r0, r0, #3
    
    ubfx r12, r0, #4, #4 //third nibble
    cmp r12, #4
    IT gt
    addgt r0, r0, #48

    ubfx r12, r0, #8, #4 //second nibble
    cmp r12, #4
    IT gt
    addgt r0, r0, #768

    ubfx r12, r0, #12, #4 //first nibble
    cmp r12, #4
    IT gt
    addgt r0, r0, #12288

    #shift left and add the next bit
    lsl r0, r0, #1
    mov r12, #0
    ubfx r12, r1, #15, #1
    add r0, r0, r12
    lsl r1, r1, #1
    sub r11, #1
    b 1b
2:
    pop {r1, r11-r12, pc}

#Convert the BCD to ASCII
#r1: input  = BCD value to convert
#r0: output = ascii value
bcd_to_ascii:
	push {r1-r2, lr}

    #verify bcd is 16 bit.
	lsl r12, r1, #16
	lsr r12, r2, #16 
	cmp r12, r1      
	ldr R0, =ASCII_ERR   
	bne 1f 

	mov R0, #0x30303030
    #Convert each nibble to ASCII
	ubfx r12, r1, #12, #4
	bfi  r0, r12, #24, #4

	ubfx r12, r1, #8, #4
	bfi  r0, r12, #16, #4

	ubfx r12, r1, #4, #4
	bfi  r0, r12, #8, #4

	ubfx r12, r1, #0, #4
	bfi  r0, r12, #0, #4

1:
	pop  {r1-r2, PC}

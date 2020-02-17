#Main.s
#Julian Singkham
#CE 2801
#Lab 3
#Description: Convert binary to ASCII

.syntax unified
.cpu cortex-m4
.thumb
.section .text

.equ ASCII_ERR, 0x00457272
.equ MAX_VALUE, 0x270F

.global num_to_ASCII

	//r0 = binary value to convert
	//r1 = GPIOB_BASE
    //r10 = counter
    //r11 = BCD value
    //r12 = temporary variable
num_to_ASCII:
    push {r10-r12}
#check if the values are not within range 0-9999
	cmp r0, #0
    bmi error
    ldr r12, =MAX_VALUE
    cmp r0, r12
    bgt error

#Double Dabble
    mov r11, #0
    mov r10, #16
    bfc r0, #15, #16 //Remove excess bits

1:
#Once complete exit
    cmp r10, #0
    beq exit

#check if each nibble is greater than 4, if it is add 3
    ubfx r12, r11, #0, #4 //fourth nibble
    cmp r12, #4
    IT gt
    addgt r11, r11, #3
    
    ubfx r12, r11, #4, #4 //third nibble
    cmp r12, #4
    IT gt
    addgt r11, r11, #48

    ubfx r12, r11, #8, #4 //second nibble
    cmp r12, #4
    IT gt
    addgt r11, r11, #768

    ubfx r12, r11, #12, #4 //first nibble
    cmp r12, #4
    IT gt
    addgt r11, r11, #12288

 #shift left and add the next bit
    lsl r11, r11, #1
    mov r12, #0
    ubfx r12, r0, #15, #1
    add r11, r11, r12
    lsl r0, r0, #1
    sub r10, #1
    b 1b

error:
	ldr r11, =ASCII_ERR //value out of range

exit:
    //mov r0, r11


    mov r0, 0x30303030
#insert ox3 between each nibble (ASCII for numbers is number + 0x30)
    mov r12, #0
    ubfx r12, r11, #0, #4
    bfi r0, r12, #0, #4

    mov r12, #0
    ubfx r12, r11, #4, #4
    bfi r0, r12, #8, #4

    mov r12, #0
    ubfx r12, r11, #8, #4
    bfi r0, r12, #16, #4

    mov r12, #0
    ubfx r12, r11, #12, #4
    bfi r0, r12, #24, #4



    push {r10-r12}
	bx lr

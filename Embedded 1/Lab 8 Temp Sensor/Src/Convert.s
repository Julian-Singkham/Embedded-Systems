#Convert.s
#Julian Singkham
#CE 2801
#Lab 8
#Description: Converter: num to ascii, temperature sensor to C/F

.syntax unified
.cpu cortex-m4
.thumb
.section .text

.equ ASCII_ERR, 0x4552522E

.global num_to_ascii
.global num_to_bcd
.global convert_to_temp

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
#r1: input  = 28-bit binary number to convert
#r0: output = BCD Value
num_to_bcd:
#Double Dabble
	push {r1, r11, r12, lr}
    mov r0, #0
    lsl r1, #4
    mov r11, #28    //bit counter
1:
    #Once complete exit
    cmp r11, #0
    beq 2f

    #check if each nibble is greater than 4, if it is add 3
    ubfx r12, r0, #0, #4 //seventh nibble
    cmp r12, #4
    IT gt
    addgt r0, r0, #0x3
    
    ubfx r12, r0, #4, #4 //sixth nibble
    cmp r12, #4
    IT gt
    addgt r0, r0, #0x30

    ubfx r12, r0, #8, #4 //fifth nibble
    cmp r12, #4
    IT gt
    addgt r0, r0, #0x300

    ubfx r12, r0, #12, #4 //fourth nibble
    cmp r12, #4
    IT gt
    addgt r0, r0, #0x3000
    
    ubfx r12, r0, #16, #4 //third nibble
    cmp r12, #4
    IT gt
    addgt r0, r0, #0x30000

    ubfx r12, r0, #20, #4 //second nibble
    cmp r12, #4
    IT gt
    addgt r0, r0, #0x300000

    ubfx r12, r0, #24, #4 //first nibble
    cmp r12, #4
    IT gt
    addgt r0, r0, #0x3000000

    #shift left and add the next bit
    lsl r0, r0, #1
    mov r12, #0
    ubfx r12, r1, #31, #1
    add r0, r0, r12
    lsl r1, r1, #1
    sub r11, #1
    b 1b
2:
    pop {r1, r11, r12, pc}

#Convert the BCD to ASCII
#r1: input  = BCD value to convert
#r0: output = ascii value
bcd_to_ascii:
	push {r1, r12, lr}

	mov r0, #0x30303030
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
	pop  {r1, r12, pc}

#converts celsius to fahrenheit
#celcius must be in tenths of a degree
#r1: input  = celsius
#r0: output = fahrenheit
convert_to_f:
	push {r1, r12, lr}

	mov r12, #9
	mul r1, r1, r12
	mov r12, #5
	udiv r1, r1, r12
	add r1, r1, #320
    mov r0, r1

	pop  {r1, r12, pc}

#converts mV to celcius
#r1: input  = mV reading
#r0: output = celcius
convert_to_c:
	push {r1, r11, r12, lr}

	mov r12, #3300
	mov r11, #4095
	mul r12, r12, r1
	udiv r12, r12, r11
	mov r1, #250
	mov r11, #750
	sub r12, r12, r11
	add r12, r12, r1
    mov r0, r12

	pop  {r1, r11, r12, pc}

#converts temperature sensor reading to the desired unit
#r1: input = mV
#r0: output = temperature in C/F
convert_to_temp:
	push {r11, r12, lr}

	ldr r12, =temp_mode
	ldrb r11, [r12]

	bl convert_to_c

	cmp r11, #1
	itt eq
	moveq r1, r0
	bleq convert_to_f

	pop  {r11,r12, pc}

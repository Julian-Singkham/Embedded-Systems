.syntax unified
.cpu cortex-m4
.thumb
.section .text

.global main

main:
    #R0 - a's
    #R1 - non a's

    #clear count iterator
    mov r0, #0
    mov r1, #0

    #load location message
    adr r2, msg
 1:
 	ldrb r3, [r2]

 	cmp r3, #0
 	beq store

    #parse the string until null
    cmp r3, #'a'
    ite eq
    addeq r0, r0, #1
    addne r1, r1, #1

    add r2, r2, #1

    b 1b

store:
    #store count into memory
    ldr r3, =countA

    strb r0, [r3]

    ldr r3, =countNonA
    strb r1, [r3]

done:
    b done

.section .data
countA:
    .byte 0
countNonA:
    .byte 0

.section .rodata
msg:
    .asciz "asadbaeraaree"

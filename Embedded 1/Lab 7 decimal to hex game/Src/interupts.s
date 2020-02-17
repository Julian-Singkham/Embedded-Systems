#interupts.s
#Julian Singkham
#CE 2801
#Lab 7
#Description: Interupt handler

.syntax unified
.cpu cortex-m4
.thumb
.section .text
	.equ RCC_BASE, 0x40023800   //clock address
    .equ RCC_APB2ENR, 0x44      //Peripheral enable 2 (SYSCFG)

    .equ SYSCFG_BASE, 0x40013800 //System config controller
    .equ SYSCFG_EXTICR1, 0x08    //External interrupt reg x

    #Interupts
    .equ EXTI_BASE, 0x40013C00  //External interrupt controller
    .equ EXTI_IMR, 0x00         //masking reg
    .equ EXTI_FTSR, 0x0C        //falling/rising edge reg
    .equ EXTI_PR, 0x14          //interupt flag reg

    .equ NVIC_BASE, 0xE000E000      //vector interupt controller
    .equ NVIC_ISER0, 0x100            //vector map
    .equ NVIC_KEYPAD_COL, 0b1111<<6   //which pins in the ISER are our interupts

.global interupt_setup

#r0: output = return value
#r11: internal = Temp 2
#r12: internal = Temp 1

#Keypad columns trigger interupt
interupt_setup:
    push {r11, r12, lr}

    #Enable SysCfg
    ldr r12, =RCC_BASE
    ldr r11, [r12, #RCC_APB2ENR]
    orr r11, r11, #(1<<14)
    str r11, [r12, #RCC_APB2ENR]
    
    #Connect keypad columns to EXTICR1
    ldr r12, =SYSCFG_BASE
    mov r11, #0x2222
    str r11, [r12, #SYSCFG_EXTICR1]

    #Unmask EXTI0-3 in EXTI
    ldr r12, =EXTI_BASE
    ldr r11, [r12, #EXTI_IMR]
    orr r11, r11, #0b1111
    str r11, [r12, #EXTI_IMR]

    #Set for falling edge
    ldr r11, [r12, #EXTI_FTSR]
    orr r11, r11, #0b1111
    str r11, [r12, #EXTI_FTSR]

    #Enable interrupt in NVIC
    ldr r12, =NVIC_BASE
    ldr r11, [r12, #NVIC_ISER0]
    orr r11, r11, #NVIC_KEYPAD_COL
    str r11, [r12, #NVIC_ISER0]

    pop {r11, r12, pc}

#Exception Handler
.global EXTI0_IRQHandler
.global EXTI1_IRQHandler
.global EXTI2_IRQHandler
.global EXTI3_IRQHandler

#For interupts, r3, r12 are the only internal variables
#This is due to r0-r3, r12 being pushed to the stack
#EXTx corresponds to the keypad's column number
.thumb_func
EXTI0_IRQHandler:
	push {lr}

    #Get the ASCII Key
    bl key_getchar
    ldr r12, =key_pressed
    strb r0, [r12]

	//bl key_scan_col
    #Clear pending interrupt
    ldr r12, =EXTI_BASE
    ldr r3, [r12, #EXTI_PR]
    orr r3, r3, #1
    str r3, [r12, #EXTI_PR]

    pop {lr}
    bx lr

.thumb_func
EXTI1_IRQHandler:
    push {lr}

    #Get the ASCII Key
    bl key_getchar
    ldr r12, =key_pressed
    strb r0, [r12]

	//bl key_scan_col
    #Clear pending interrupt
    ldr r12, =EXTI_BASE
    ldr r3, [r12, #EXTI_PR]
    orr r3, r3, #1
    str r3, [r12, #EXTI_PR]


    pop {lr}
    bx lr

.thumb_func
EXTI2_IRQHandler:
    push {lr}

    #Get the ASCII Key
    bl key_getchar
    ldr r12, =key_pressed
    strb r0, [r12]

	//bl key_scan_col
    #Clear pending interrupt
    ldr r12, =EXTI_BASE
    ldr r3, [r12, #EXTI_PR]
    orr r3, r3, #1
    str r3, [r12, #EXTI_PR]

    pop {lr}
    bx lr

.thumb_func
EXTI3_IRQHandler:
    push {lr}

    #Get the ASCII Key
    bl key_getchar
    ldr r12, =key_pressed
    strb r0, [r12]

	//bl key_scan_col
    #Clear pending interrupt
    ldr r12, =EXTI_BASE
    ldr r3, [r12, #EXTI_PR]
    orr r3, r3, #1
    str r3, [r12, #EXTI_PR]

    pop {lr}
    bx lr

.data
	.global key_pressed
    key_pressed: .asciz ""

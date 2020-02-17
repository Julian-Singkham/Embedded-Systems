#adc.s
#Julian Singkham
#CE 2801
#Lab 8
#Description: Analog Digital Converter
#ADC1 is used to read values from the temperature sensor
.syntax unified
.cpu cortex-m4
.thumb
.section .text

    .equ RCC_BASE, 0x40023800	//base address for clock
    .equ RCC_AHB1ENR, 0x30 		//Peripheral enable 1 (GPIOx)
    .equ RCC_APB2ENR, 0x44      //Peripheral enable 2 (ADCx)

    .equ ADC1_BASE, 0x40012000	//Address for the ADC1
    .equ ADC_SR, 0x00   //status register
    .equ ADC_CR1, 0x04  //control register 1. Set mode and interupt
    .equ ADC_CR2, 0x08  //control register 2. Conversion, external stuff
    .equ ADC_SQR3, 0x34 //regular sequence register 3. 6-1 conversion
    .equ ADC_DR, 0x4C   //data register
    
    .equ GPIOB_EN, 0x2  //bit to enable GPIOB
    .equ ADC1_EN, 1<<8  //bit to enable ADC1

    .equ NVIC_BASE, 0xE000E000  //vector interupt controller
    .equ NVIC_ISER0, 0x100        //vector map

.global adc_setup
.global start_convert
.global disable_ADC_interrupt
.global enable_ADC_interrupt

#r0: ouput = output from subroutines
#r1: input = input for subroutines
#r10: temp = temporary variable 3
#r11: temp = temporary variable 2
#r12: temp = temporary variable 1

#Turns on the ADC
adc_setup:
    push {r10-r12, lr}

    ldr r12, =RCC_BASE
    #enable GPIO B
    ldr r11, [r12, #RCC_AHB1ENR]
    orr r11, r11, #GPIOB_EN
    str r11, [r12, #RCC_AHB1ENR]

    #enable ADC1 & turn on ADC1
    ldr r11, [r12, #RCC_APB2ENR]
    orr r11, r11, #ADC1_EN
    str r11, [r12, #RCC_APB2ENR]
    ldr r12, =ADC1_BASE
    ldr r11, [r12, #ADC_CR2]
    orr r11, r11, #(1<<0)
    str r11, [r12, #ADC_CR2]

    #watch channel 8
    ldr r11, [r12, #ADC_SQR3]
    mov r10, #8
    bfi r11, r10, #0, #5
    str r11, [r12, #ADC_SQR3]

    #enable interrupt
    ldr r12, =NVIC_BASE
    ldr r11, [r12, #NVIC_ISER0]
    orr r11, r11, #(1<<18)
    str r11, [r12, #NVIC_ISER0]

    ldr r12,=ADC1_BASE
    ldr r11, [r12, ADC_CR1]
    orr r11, r11,#(1<<5) //enable EOC interupt.
    str r11, [r12,ADC_CR1]

    pop {r10-r12, pc}

#Start conversion of ADC Channels
start_convert:
    push {r11, r12, lr}

    ldr r12, =ADC1_BASE
    ldr r11, [r12, #ADC_CR2]
    orr r11, r11, #(1<<30) //start bit
    str r11, [r12, #ADC_CR2]

    pop  {r11, r12, pc}


#Disables ADC1 interrupt (EOC)
disable_ADC_interrupt:
	push {r11, r12, lr}

	ldr r12, =ADC1_BASE
	ldr r11, [r12, ADC_CR1]
	bic r11, r11, #(1<<5)
	str r11, [r12, ADC_CR1]

	pop  {r11, r12, pc}

#Enables ADC1 interrupt (EOC)
enable_ADC_interrupt:
	push {r11, r12, lr}

	ldr r12, =ADC1_BASE
	ldr r11, [r12, ADC_CR1]
	orr r11, r11, #(1<<5)
	str r11, [r12, ADC_CR1]

	pop  {r11, r12, pc}

.global ADC_HAND

#Interupt is triggered at the end of the conversion (EOC-bit)
#r0: ouput = output from subroutines
#r1: input = input for subroutines
#r3: temp = temporary variable 2
#r12: temp = temporary variable 1
.thumb_func
ADC_HAND:
	push {lr}

	bl is_buffer_mode
	cmp r0, #0
	ldr r12, =ADC1_BASE
	ldr r1, [r12, #ADC_DR] //load data
	beq buffer_off
	bne buffer_on

buffer_off:  //Just print the value
	bl convert_to_temp
	bl lcd_home
	mov r1, r0
	bl print_reading
	b  exit

buffer_on: //Save to memory
	ldr r12, =buffer_pos
	ldr r12, [r12] //location in buffer
	ldr r3, =temperature_buffer //base address

	str r1, [r3, r12]
	bl inc_buffer_pos

exit:
    #turn off interrupt?
	pop {lr}
	bx lr

#Timer.s
#Julian Singkham
#CE 2801
#Lab 8
#Description: Timer
#TIM3 is used for the buzzer
#TIM2 is used to delay temperature readings
#SYSTICK is used as a general input timer
.syntax unified
.cpu cortex-m4
.thumb
.section .text

	.equ RCC_BASE, 0x40023800 	//base address for clock
	.equ RCC_AHB1ENR, 0x30 		//Peripheral enable 1 (GPIOx)
	.equ RCC_APB1ENR, 0x40 		//Peripheral enable 2 (TIMx)
	.equ RCC_GPIOBEN, 0x2	

	.equ GPIOB_BASE, 0x40020400	//Address for the GPIOB
	.equ GPIO_MODER, 0x00 		//Pin function (2 bits)
	.equ GPIO_AFRL, 0x20 		//alternate function

    .equ TIM3_BASE, 0x40000400
	.equ TIM2_BASE, 0x40000000
	.equ TIMx_ARR, 0x2C     //auto reload register
    .equ TIMx_CNT, 0x24     //counter
    .equ TIMx_CCER, 0x20    //capture/compare enable
    .equ TIMx_CCMR1, 0x18   //capture/compare mode 1
	.equ TIMx_CCR1, 0x34    //capture/compare register 1 XXXXXX
	.equ TIMx_CR1, 0x00     //control register 1
	.equ TIMx_DIER, 0x0C	//DMA/interrupt enable register. Timer (update) interupt 
	.equ TIMx_SR,	0x10	//status register

    .equ SYSTICK_BASE, 0xE000E010	//system clock
	.equ SYSTICK_CTRL, 0x00			//Controller
	.equ SYSTICK_LOAD, 0x04			//value clock will count upto
	.equ SYSTICK_ENABLE, 0b101 		//sets SYSTICK to use CPU clock, enable exception, and counter

	.equ NVIC_BASE, 0xE000E000      //vector interupt controller
    .equ NVIC_ISER0, 0x100            //vector map

.global timer_setup
.global delay_ms
.global delay_us
.global delay_sec
.global piezo_setup
.global piezo_play
.global piezo_off
.global timer_temperature_set
.global timer_temperature_start
.global timer_temperature_stop

#r1: input  = Parameter 1 for subroutine calls
#r11: internal = Temp 2
#r12: internal = Temp 1

#Turns on timers TIM3 & TIM2
timer_setup:
	push {r11, r12, lr}

	#enable clock to TIM3 & TIM2
	ldr r12, =RCC_BASE 
	ldr r11, [r12, RCC_APB1ENR]
	orr r11, r11, #0b11 // TIM3 & TIM2
	str r11, [r12, RCC_APB1ENR] 

	ldr r12, =TIM2_BASE
	#set the value in ARR to 1 ms
	ldr r11, =(16000000-1)
	str r11, [r12, TIMx_ARR]

	bl timer_temperature_start

	ldr r12, =NVIC_BASE
	#Enable the TIM2 interrupt in NVIC
	ldr r11, [r12, NVIC_ISER0]
	orr r11, r11, #(1<<28)
	str r11, [r12, NVIC_ISER0]

	
	pop {r11, r12, pc}

#sets the interval between temperature readings
#r1: input = num of seconds
timer_temperature_set:
	push {r11, r12, lr}

	bl timer_temperature_stop

	ldr r12, =TIM2_BASE
	ldr r11, =16000000 // 1 second
	mul r11, r11, r1
	sub r11, r11, #1	//-1 because it takes 1 instruction to exit
	str r11, [r12, TIMx_ARR]

	bl timer_temperature_start

	pop  {r11, r12, pc}

#Start the temperature timer and enable update interrupt
timer_temperature_start:
	push {r11, r12, lr}

	ldr r12, =TIM2_BASE

	//starts the timer.
	ldr r11, [r12, TIMx_CR1]
	orr r11, r11, #1
	str r11, [r12, TIMx_CR1]

	//enable the interrupt.
	ldr r11, [r12, TIMx_DIER]
	orr r11, r11, #1
	str r11, [r12, TIMx_DIER]

	pop {r11, r12, pc}

#stops temperature timer
timer_temperature_stop:
	push {r11-r12, lr}

	#stop timer
	ldr r12, =TIM2_BASE
	ldr r11, [r12, TIMx_CR1]
	and r11, r11, #0
	str r11, [r12, TIMx_CR1]

	#disable the update interrupt
	ldr r11, [r12, TIMx_DIER]
	and r11, r11, #0
	str r11, [r12, TIMx_DIER]

	#reset timer
	mov r11, #0
	str r11, [r12, TIMx_CNT]

	pop {r11-r12, pc}

#Use Systick to delay x ms
#r1: input = num of ms
delay_ms:
    push {r11, r12, lr}

	bl reset_systick
	# cause a delay by using the systick.
	ldr r12, =SYSTICK_BASE
	ldr r11, = 16000 //cyles per ms
	mul r11, r11, r1
	str r11, [r12, SYSTICK_LOAD]
	#start the clock.
	mov r11, SYSTICK_ENABLE
	str r11, [r12, SYSTICK_CTRL]

1:  //determine when is timeout.
	ldr r11, [r12, SYSTICK_CTRL]
	ands r11, r11, #1<<16
	beq 1b

	pop {r11, r12, pc}

#Use Systick to delay x us
#r1: input = num of us
delay_us:
    push {r11, r12, lr}

	bl reset_systick
	#cause a delay by using the systick.
	ldr r12, =SYSTICK_BASE
	mov r11, #16 //cyles per us
	mul r11, r11, r1
	str r11, [r12, SYSTICK_LOAD]
	#start the clock.
	mov r11, SYSTICK_ENABLE
	str r11, [r12, SYSTICK_CTRL]

1:  //determine when is timeout.
	ldr r11, [r12, SYSTICK_CTRL]
	ands r11, r11, #1<<16
	beq 1b

	pop {r11, r12, pc}

#Use Systick to delay x s
#r1: input = num of s
delay_sec:
	push {r11, r12, lr}

	bl reset_systick
	# cause a delay by using the systick.
	ldr r12, =SYSTICK_BASE
	ldr r11, =16000000 //cycles per second
	mul r11, r11, r1
	str r11, [r12, SYSTICK_LOAD]
	#start the clock.
	mov r11, SYSTICK_ENABLE
	str r11, [r12, SYSTICK_CTRL]
	
1:	//determine when is timeout.
	ldr r11, [r12, SYSTICK_CTRL]
	ands r11, r11, #1<<16
	beq 1b

	pop {r11, r12, pc}

#Reset systick controller and load prior to using systick as a timer
reset_systick:
	push {r11, r12, lr}

	# reset all bits.
	ldr r12, =SYSTICK_BASE
	#Reset Systick controller
	ldr r11, [r12, SYSTICK_CTRL]
	and r11, r11, #0
	str r11, [r12, SYSTICK_CTRL]
	#Reset Systick Load
	ldr r11, [r12, SYSTICK_LOAD]
	and r11, r11, #0
	str r11, [r12, SYSTICK_LOAD]

	pop {r11, r12, pc}

#Sends the TIM3 square wave to the buzzer
piezo_setup:
    push {r11, r12, lr}

    #enable clock to GPIOB
    ldr r12, =RCC_BASE
	ldr r11, [r12, RCC_AHB1ENR] 
	orr r11, r11, #0b10 // GPIOB is bit 1
	str r11, [r12, RCC_AHB1ENR] 

    # Set AF to 2
	ldr r12, =GPIOB_BASE 
	ldr r11, [r12, GPIO_AFRL] 
	bic r11, r11, #(0b1111<<16)
	orr r11, r11, #(0b0010<<16) // AF 2
	str r11, [r12, GPIO_AFRL] 
	# Set PB4 to Alternate mode
	ldr r11, [r12, GPIO_MODER] 
	bic r11, r11, #(0b11<<8)
	orr r11, r11, #(0b10<<8)
	str r11, [r12, GPIO_MODER]

    pop {r11, r12, pc}

#Disables Pizeo
piezo_off:
	push {r11, r12, lr}

	#Disbale counter
	ldr r12, =TIM3_BASE
	ldr r11, [r12, TIMx_CR1]
	mov r11, #0
	str r11, [r12, TIMx_CR1]

	pop {r11, r12, pc}

#Plays a tone with the Piezo
#r1:input = amount of ticks (clock/[r1*2]=hz)
piezo_play:
	push {r11, r12, lr}

	ldr r12, =TIM3_BASE

	#Enable counter
	ldr r11, [r12, TIMx_CR1]
	mov r11, #1
	str r11, [r12, TIMx_CR1]

	#set the reset count: period -1
	add r11, r1, r1
	sub r11, r11, #1
	str r11, [r12,TIMx_ARR]

	#Set position of toggle
	mov r11, #0
	str r11, [r12,TIMx_CCR1]

	#Set output mode to toggle
	mov r11, #0b011<<4 // OC1M = 011 - PWM Mode 1
	str r11, [r12,TIMx_CCMR1]

	# compare output enable 
	movw r11, #1 //CC2E =1
	str r11, [r12,TIMx_CCER]
	
	pop {r11, r12, pc}

.global TIM2_Interrupt_Handler

#Interupt is triggered when TIM2 (interval between temp readings) is 0
#r3: temp = temporary variable 2
#r12: temp = temporary variable 1
.thumb_func
TIM2_Interrupt_Handler:
	push {lr}

	bl start_convert

	#clear the interupt flag.
	ldr r12, =TIM2_BASE
	ldr r3, [R0, TIMx_SR]
	bic r3, r3, #1
	str r3, [r12, TIMx_SR]

	pop {lr}
	bx lr		

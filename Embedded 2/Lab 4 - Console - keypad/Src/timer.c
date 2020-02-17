/*
 * timer.c
* Lab 3: LCD + Keypad
 *
 * Created on: DEC 10 2019
 * Author: Julian Singkham
 */

#include <inttypes.h>
#include <stdio.h>
#include "timer.h"

//------------Pointers----------------------
volatile uint32_t *SYSTICK_CTRL	= (uint32_t*) 0xE000E010; //Controller
uint32_t *SYSTICK_LOAD	= (uint32_t*) 0xE000E014; //value clock will count up to

//------------Values------------------------
int SYSTICK_ENABLE = 0b101; //sets SYSTICK to use CPU clock, enable exception, and counter

//------------Static Prototypes--------------
static void reset_systick(void);

/*
 * ms delay using systick.
 *
 * time: how long to wait in ms
 */
void delay_ms(int time){
	reset_systick();
	*SYSTICK_LOAD = time * 16000; //cycles per ms

	*(SYSTICK_CTRL) |= (SYSTICK_ENABLE);
	while(!(*SYSTICK_CTRL & 1<<16)){
		//Waits until the SYSTICK Count flag = 1
	}
}

/*
 * us delay using systick.
 *
 * time: how long to wait in us
 */
void delay_us(int time){
	reset_systick();
	*SYSTICK_LOAD = time * 16; //cycles per ms

	*(SYSTICK_CTRL) |= (SYSTICK_ENABLE);
	while(!(*SYSTICK_CTRL & 1<<16)){
		//Waits until the SYSTICK Count flag = 1
	}
}

/*
 * Sets the systick control and load registers to zero.
 * Used before every systick delay call.
 */
static void reset_systick(void){
	*SYSTICK_CTRL = 0;
	*SYSTICK_LOAD = 0;
}

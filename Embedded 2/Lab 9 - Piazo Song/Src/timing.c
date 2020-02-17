/**
  ******************************************************************************
  * @file     : timing.c
  * @brief    : Main program body
  *           : Lab 9: Piazo Song
  * @date     : FEB 09 2020
  * @author   : Julian Singkham
  ******************************************************************************
  * @attention
  *
  * API to use the Systick for timing
  *
  ******************************************************************************
**/

#include "timing.h"

//===================================Values=====================================
int SYSTICK_ENABLE = 0b101; //sets SYSTICK to use CPU clock, enable exception, and counter

//=================================Prototypes===================================
static void reset_systick(void);
static void reset_regs();

/**
  * @brief Uses systick to create a x ms delay
  * @param delay: In ms
  */
void delay_ms(uint32_t delay) {
	reset_systick();
	*SYSTICK_LOAD = delay * (F_CPU / 8000);
	while(!(*SYSTICK_CTRL & 1<<16)); //Waits until the SYSTICK Count flag = 1
}

/**
  * @brief Uses systick to create a x us delay
  * @param delay: In us
  */
void delay_us(uint32_t delay) {
	reset_regs();
	*SYSTICK_LOAD = delay * (F_CPU / 8000000);
	while(!(*SYSTICK_CTRL & 1<<16)); //Waits until the SYSTICK Count flag = 1
}

/**
  * @brief Sets the Systick control and load registers to zero
  */
static void reset_systick(void){
	*SYSTICK_CTRL = 0;
	*SYSTICK_LOAD = 0;
}

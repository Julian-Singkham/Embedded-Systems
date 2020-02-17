/**
  ******************************************************************************
  * @file    timing.h
  * @author  John Bretz
  * @version V1.0
  * @brief   Function prototypes for the timing api.
  ******************************************************************************
*/

/**
  ******************************************************************************
  * @file     : timing.h
  * @brief    : Header for timing.c
  *           : Lab 9: Piazo Song
  * @date     : FEB 09 2020
  * @author   : Julian Singkham
  ******************************************************************************
  * @attention
  *
  * Protoypes and definitons for the timing api
  * 
  ******************************************************************************
**/

#include <inttypes.h>

#define timing_H

//================================Registers=====================================
#define SYSTICK_CTRL (volatile uint32_t *) 0xE000E010
#define SYSTICK_LOAD (volatile uint32_t *) 0xE000E014

//============================Function Prototypes===============================
void delay_ms(uint32_t); //A blocking delay that will last x milliseconds

void delay_us(uint32_t); //A blocking delay that will last x microseconds

//==================================Variables===================================
#define F_CPU 16000000UL
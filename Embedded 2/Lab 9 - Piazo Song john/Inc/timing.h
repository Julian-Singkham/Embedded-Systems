/**
  ******************************************************************************
  * @file    timing.h
  * @author  John Bretz
  * @version V1.0
  * @brief   Function prototypes for the timing api.
  ******************************************************************************
*/

#include <inttypes.h>

#ifndef TIMING_H
#define TIMING_H

#define F_CPU 16000000UL
#define SYSTICK (volatile uint32_t *) 0xE000E010

/// A blocking delay that will last N milliseconds
/// @param num the number of milliseconds to delay for
void delay_ms(uint32_t);

/// A blocking delay that will last N microseconds
/// @param num the number of microseconds to delay for
void delay_us(uint32_t);

#endif

/**
  ******************************************************************************
  * @file    timing.c
  * @author  John Bretz
  * @version V2.0
  * @brief   Timing api.
  ******************************************************************************
*/

#include "timing.h"


static void wait_delay();
static void reset_regs();

static volatile uint32_t* systick = SYSTICK;

void delay_ms(uint32_t theDelay) {
	reset_regs(systick);
	systick[1] = theDelay * (F_CPU / 8000);
	wait_delay(systick);
}

void delay_us(uint32_t theDelay) {
	reset_regs(systick);
	systick[1] = theDelay * (F_CPU / 8000000);
	wait_delay(systick);
}

static void reset_regs() {
	systick[2] = 0;
	systick[0] = 0;
}

static void wait_delay() {
	systick[0] = 1; // enable the clock.

	while (!(systick[0] & (1 << 16))) {
		// nothing to do.
	}

	systick[0] = 0;
}

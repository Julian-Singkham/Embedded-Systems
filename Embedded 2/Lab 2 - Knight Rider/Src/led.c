/*
 * led.c
 * Lab 2: Knight Rider
 *
 * Created on: DEC 10 2019
 * Author: Julian Singkham
 */

#include <inttypes.h>
#include <stdio.h>
#include "led.h"

//------------Pointers----------------------
uint32_t *RCC_AHB1ENR	= (uint32_t*) 0x40023830; //location of the "Turns on GPIO peripherals"
volatile uint32_t *GPIOB_BSRR	= (uint32_t*) 0x40020418; //location of the bit set/reset 31:16 reset 15:0 sets
uint32_t *GPIO_MODER 	= (uint32_t*) 0x40020400; //Length of an individual pin's function (offset)
volatile uint32_t *GPIO_ODR 		= (uint32_t*) 0x40020414; //Output data register for a specific GPIO.

//-------------Values-----------------------
#define BSRR_RESET 	0xFFFF0000
#define RCC_GPIOBEN (1<<1) 		// Shift the value 1 to the left once
int led_location = 0x00000020; //initial value for BSRR (turns right most LED on)

/*
 * Sets the pins to enable the led's
 */
void led_setup(void){
	*(RCC_AHB1ENR) |= RCC_GPIOBEN; //Turn on GPIOB in RCC

	//Enable PB5-PB10, PB12-PB15 to be outputs
	*(GPIO_MODER) |= (0x55155400);
}

/*
 * Sweeps the leds from right to left
 */
void right_left(void){
	while(1==1){
		//Check if the current LED is the left most
		if(led_location == 0x00008000){
			return;
		}

		//Turn LED on then off
		*(GPIOB_BSRR) = led_location;
		delay_ms(100);
		*(GPIOB_BSRR) = BSRR_RESET;

		//Increment to the left LED skip PB11
		led_location = led_location << 1;
		if(led_location == 0x00000800){
			led_location = led_location << 1;
		}
	}
}

/*
 * Sweeps the leds from left to right
 */
void left_right(void){
	while(1==1){
		//Check if the current LED is the left most
		if(led_location == 0x00000020){
			return;
		}

		//Turn LED on then off
		*(GPIOB_BSRR) = led_location;
		delay_ms(100);
		*(GPIOB_BSRR) = BSRR_RESET;

		//Increment to the left LED
		led_location = led_location >> 1;
		if(led_location == 0x00000800){
			led_location = led_location >> 1;
		}
	}
}

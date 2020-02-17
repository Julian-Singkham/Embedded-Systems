/*
 * led.c
 * Lab 2: Knight Rider
 *
 * Created on: DEC 10 2019
 * Author: Julian Singkham
 */

#include "led.h"
#include <stdio.h>
#include <stdlib.h>

/*
 * This program sweeps the led lights from right-left-right.
 * The led's stay on for 100 ms
 */
int main(void) {
	led_setup();
	while(1==1){
		right_left();
		left_right();
	}
}

/*
 * Main.c
 * Lab 3: LCD + Keypad
 *
 * Created on: DEC 10 2019
 * Author: Julian Singkham
 */

#include <stdio.h>
#include <stdlib.h>
#include "timer.h"
#include "lcd.h"
#include "keypad.h"

/*
 * This program sweeps the led lights from right-left-right.
 * The led's stay on for 100 ms
 */
int main(void) {
	lcd_setup();
	keypad_setup();
	char stuff[6] = "abcde";
	int col = 0;
	int row = 0;

	//LCD TEST
	lcd_print_string(stuff);
	delay_ms(1000);
	delay_ms(1000);
	lcd_clear();
	lcd_print_num(60500);
	delay_ms(1000);
	delay_ms(1000);
	lcd_clear();

	//Keypad test
	int flag = 1;
	char in;
	while(flag){
		in = keypad_getchar();
		delay_ms(125);
		if(in != '\0'){
			lcd_write_data(in);
			col++;
			if(col == 16){
				if(row == 1){
					lcd_clear();
					col = 0;
					row = 0;
				}
				else{
					lcd_set_position(1,0);
					col = 0;
					row++;
				}
			}
		}
	}
}

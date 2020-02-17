/*
 * lcd.h
 * Lab 3: LCD + Keypad
 *
 * Created on: JAN 06 2020
 * Author: Julian Singkham
 */
#define lcd_H_

#include <inttypes.h>

void lcd_print_num(int num);
void lcd_print_string(char string[]);
void lcd_set_position(int row, int col);
void lcd_write_data(int data);
void error(void);
void lcd_setup(void);
void lcd_clear(void);
void lcd_home(void);

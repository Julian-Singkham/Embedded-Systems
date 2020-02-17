/*
 * lcd.c
* Lab 3: LCD + Keypad
 * API to use the LCD display
 *
 * Created on: DEC 17 2019
 * Author: Julian Singkham
 */
#include <inttypes.h>
#include <stdio.h>
#include <string.h>
#include "registers.h"
#include "timer.h"
#include "lcd.h"

//------------Values------------------------
int const RS = 0x100; //PC8
int const RW = 0x200; //PC9
int const E  = 0x400; //PC10

//------------Static Prototypes--------------
static void lcd_delay(void);
static void lcd_write_instruction(int instruction);

/*
 * Setup for LCD
 */
void lcd_setup(void){
	*RCC_AHB1ENR |= RCC_GPIOAEN | RCC_GPIOCEN; //enable clock to GPIO A&C

	//Turn GPIOA and GPIOC to output
	*GPIOA_MODER |= 0x00555500;
	*GPIOC_MODER |= 0x00150000;

	delay_ms(40); //40ms delay

	//Write Function Set (0x38)
	lcd_write_instruction(0x38);
	lcd_write_instruction(0x38);

	//Write Display On/Off(0x0F)
	lcd_write_instruction(0x0F);

	lcd_clear();

	//Write Entry Mode Set (0x06)
	lcd_write_instruction(0x06);
}

/*
 * clear the lcd display
 */
void lcd_clear(void){
	lcd_write_instruction(0x01);
}

/*
 * Moves the curser back to home (Upper left hand corner)
 */
void lcd_home(void){
	lcd_write_instruction(0x02);
}

/*
 * Prints a decimal number to the display
 * 
 * num = number to print
 */
void lcd_print_num(int num){
	char buffer[15];

	sprintf(buffer, "%d", num);

	lcd_print_string(buffer);

}

/*
 * Prints a null terminated string to the display
 * 
 * string_location: base address to the string
 */
void lcd_print_string(char string[]){
	for(int i=0; i< strlen(string); i++){
		if(string[i] == '\0'){
			return;
		}
		lcd_write_data(string[i]);
	}
}

/*
 * Moves Cursor to location
 * 
 * row = row
 * col = column
 */
void lcd_set_position(int row, int col){
	lcd_home();

	//check if the cursor needs to move up/down
	if(row == 1){
		col += 40; //second line starts at 41st digit
	}

	//shift the cursor right until the desired spot is reached
	while(col != 0){
		lcd_write_instruction(0x14);
		col--;
	}
}

/*
 * Delays the program until the busy flag is off
 */
static void lcd_delay(void){
	*GPIOA_MODER &= ~(0xFFFF<<8);	//Set PA4-11 to input
	int busy = 1;

	//check busy flag, (DB7/PA11) 0=off
	while(busy){
		//Set RS=0,RW=1,E=1
		*GPIOC_ODR &= ~RS;
		*GPIOC_ODR |= RW;
		*GPIOC_ODR |= E;

		//check busy flag
		if(*GPIOA_IDR & 1<<11){
			*GPIOC_ODR &= ~E; //set E=0
		}
		else{
			busy = 0;
		}
	}
	*GPIOC_ODR &= ~E; 			//set E=0
	*GPIOA_MODER |= 0x00555500;	//set GPIOA to output
}

/*
 * Writes instruction to LCD
 * 
 * instruction = command to execute
 */
static void lcd_write_instruction(int instruction){
	//Set RS=0,RW=0,E=1
	*GPIOC_ODR &= ~RS;
	*GPIOC_ODR &= ~RW;
	*GPIOC_ODR |= E;

	*GPIOA_ODR |= (instruction<<4); //Send instructions to data pins
	*GPIOA_ODR &= (instruction<<4); //Send instructions to data pins
	*GPIOC_ODR &= ~E; 				//set E=0
	lcd_delay();
}

/*
 * Writes data to LCD
 * 
 * data = what to display on LCD
 */
void lcd_write_data(int data){
	//Set RS=1,RW=0,E=1
	*GPIOC_ODR |= RS;
	*GPIOC_ODR &= ~RW;
	*GPIOC_ODR |= E;

	*GPIOA_ODR |= data<<4;	//Send data to LCD
	*GPIOA_ODR &= data<<4;	//Send data to LCD
	*GPIOC_ODR &= ~E; 		//set E=0
	lcd_delay();
}

void error(void){
	lcd_write_data('E');
	lcd_write_data('r');
	lcd_write_data('r');
}

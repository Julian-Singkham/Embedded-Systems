/*
 * keypad.c
* Lab 3: LCD + Keypad
 * API to use the Keypad
 *
 * Created on: JAN 13 2020
 * Author: Julian Singkham
 * 
 * Assume only one button can be pressed at any given time
 */
#include <inttypes.h>
#include <stdio.h>
#include "registers.h"
#include "timer.h"
#include "keypad.h"

//------------Values------------------------
int const GPIOC_PULLUP = 0x5555; //value to set columns as pullup

//------------Static Prototypes-------------
static int keypad_get(int button);
static int keypad_scan(void);

/*
 * Setup for LCD
 */
void keypad_setup(void){
    *RCC_AHB1ENR |= RCC_GPIOCEN;
    *GPIOC_PUPDR |= GPIOC_PULLUP;
}

/*
 * Returns the key that was pressed (does not wait until the button is not pressed)
 * 
 * output: The key that was pressed
 */
int keypad_getkey_noblock(void){
    return keypad_get(keypad_scan()); //Get the input from the keypad and convert it to a key
}

/*
 * Returns the key that was pressed after it has been released
 * 
 * output: The key that was pressed
 */
int keypad_getkey(void){
    int button = keypad_scan(); //Get the input from the keypad

    while((*GPIOC_IDR & 0xF0) != 0xF0){
        delay_us(10);
    } 
    return keypad_get(button); //Convert input to a key
}

/*
 * Scans the keypad and returns the button that was pressed
 * 
 * output: the input of the keypad
 */
static int keypad_scan(void){
    int input = 0;
    //Scan Column
    *GPIOC_MODER |= 0xAA00;
    *GPIOC_MODER &= 0xFFFFAA00;
    delay_us(10);
    input = ~*GPIOC_IDR & 0xF;   //bits 0-3 Co

    //Scan Row
    *GPIOC_MODER |= 0x0055;
    *GPIOC_MODER &= 0xFFFF0055;
    delay_us(10);
    input |= (~*GPIOC_IDR & 0xF0);   //bits 4-7 Row

    return input;
}

/*
 * Based on the button (row/col) return the key value
 * button = 0 means nothing was pressed
 * 
 * Button: The button that was pressed
 * output: The key value of the button that was pressed
 */
static int keypad_get(int button){
    int key = -1;

	//1
    if(button == 0x11){
        key = 0;
    }
    //2
    else if(button == 0x12){
        key = 1;
    }
    //3
    else if(button == 0x14){
        key = 2;
    }
    //A
    else if(button == 0x18){
        key = 3;
    }
    //4
    else if(button == 0x21){
        key = 4;
    }
    //5
    else if(button == 0x22){
        key = 5;
    }
    //6
    else if(button == 0x24){
        key = 6;
    }
    //B
    else if(button == 0x28){
        key = 7;
    }
    //7
    else if(button == 0x41){
        key = 8;
    }
    //8
    else if(button == 0x42){
        key = 9;
    }
    //9
    else if(button == 0x44){
        key = 10;
    }
    //C
    else if(button == 0x48){
        key = 11;
    }
    //*
    else if(button == 0x81){
        key = 12;
    }
    //0
    else if(button == 0x82){
        key = 13;
    }
    //#
    else if(button == 0x84){
        key = 14;
    }
    //D
    else if(button == 0x88){
        key = 15;
    }
    return key;
}

/*
 * Retrives the char value of the keypad button
 * 
 * output: The char value of the button that was pressed
 */
char keypad_getchar(void){
    static const char keys[] = {'1','2','3','A',
                                    '4','5','6','B',
                                    '7','8','9','C',
                                    '*','0','#','D' };
    int key = keypad_getkey();
    if(key !=-1){
        return keys[key];
    }
    char null = '\0';
    return null;
}

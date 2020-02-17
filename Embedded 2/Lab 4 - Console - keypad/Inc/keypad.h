/*
 * keypad.h
* Lab 3: LCD + Keypad
 *
 * Created on: JAN 13 2020
 * Author: Julian Singkham
 */
#define keypad_H_

#include <inttypes.h>

void keypad_setup(void);
int keypad_getkey_noblock(void);
int keypad_getkey(void);
char keypad_getchar(void);



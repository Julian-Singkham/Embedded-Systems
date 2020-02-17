/*
 * Main.c
 * Lab 4: Console
 *
 * Created on: JAN 20 2019
 * Author: Julian Singkham
 */



#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "uart_driver.h"
#include "ring_buffer.h"

#define F_CPU 16000000UL

/*
 * Using the terminal the user can retrieve and write to memory
 * Additionally the user can dump the memory to the specified number of bytes.
 */
int main(void){
	init_usart2(19200,F_CPU);
	char mode = '\0';		//Which mode to be in
	int address = 0;		//User specified memory location
	int* pointer = 0;		//Pointer to memory location
	char* pointer_2 = '\0';	//Used for memory dump
	int value = 0;			//Value at given memory location
	int amount = 0;			//# of bytes to dump in memory dump
	while(1){
		printf("Use hexadecimal for addresses\n");
		printf("A: Read Memory (A, Address)\nB: Write Memory (B, Address, New integer value)\nC: Dump Memory (C, Starting Address, # of Bytes)\n");
		scanf("%c", &mode);	//Mode select

		//Read Memory
		if(mode == 'A' || mode == 'a'){
			scanf("%x", &address);		//Address to read
			pointer = (int*) address;	//Sets the pointer to the given address
			printf("At 0x%x: %d\n\n", address, *pointer);
		}

		//Write Memory
		else if(mode == 'B' || mode == 'b'){
			scanf("%x %d", &address, &value);	//Address to read, value to write to the address
			pointer = (int*) address;			//Sets the pointer to the given address
			*pointer = value;					//Sets the value of the pointer
			printf("At 0x%x: %d\n\n", address, *pointer);
		}

		//Dump Memory
		else if(mode == 'C' || mode == 'c'){
			scanf("%x %d", &address, &amount);	//Address to read, # of bytes to dump
			//Default # of bytes to dump is 16
			if(amount == 0){
				amount = 16;
			}
			while(amount !=0){
				pointer_2 = (char*) address;	//Sets the pointer to the given address. Note:Char is used because we are reading bytes
				printf("At 0x%x: %x\n", address, *pointer_2);
				address += 0x1;					//Next Byte
				amount-= 1;
			}
			printf("\n");
		}
	}
}


/*
 * uart_driver.c
 * Lab 7-8: Ring Buffer and ISR USART
 * API to use the console
 *
 * Created on: FEB 02 2020
 * Author: Julian Singkham
 */

#include "uart_driver.h"
#include "ring_buffer.h"
#include <inttypes.h>
#include <stdio.h>

//------------Values------------------------
static RingBuffer inputBuffer = {0,0,0};	//Raw console input
static RingBuffer outputBuffer = {0,0,0}; //Sending to the cpu

//------------Static Prototypes--------------
static char usart2_getch(void);
static void usart2_putch(char);

//These will override _read and _write in syscalls.c, which are
//prototyped as weak
int _read(int file, char *ptr, int len){
	int DataIdx;
	// Modified the for loop in order to get the correct behavior for fgets
	int byteCnt = 0;
	for (DataIdx = 0; DataIdx < len; DataIdx++){
		byteCnt++;
		*ptr = usart2_getch();
		if(*ptr == '\n') break;
		ptr++;
	}
	return byteCnt; // Return byte count
}

int _write(int file, char *ptr, int len){
	int DataIdx;

	for (DataIdx = 0; DataIdx < len; DataIdx++){
		usart2_putch(*ptr++);
	}
	return len;
}

char usart2_getch(){

	return buffer_get(&inputBuffer);
}

void usart2_putch(char c){
	buffer_add(&outputBuffer, c);
	*USART_CR1 |= (1<<TXEIE);
}

void init_usart2(uint32_t baud, uint32_t sysclk){
	// Enable clocks for GPIOA and USART2. Turn on NVIC, enable recieve interrupt
	*(RCC_AHB1ENR) 	|= (1<<GPIOAEN);
	*(RCC_APB1ENR) 	|= (1<<USART2EN);

	// Function 7 of PORTA pins is USART
	*(GPIOA_AFRL) &= (0xFFFF00FF); // Clear the bits associated with PA3 and PA2
	*(GPIOA_AFRL) |= (0b01110111<<8);  // Choose function 7 for both PA3 and PA2
	*(GPIOA_MODER) &= (0xFFFFFF0F);  // Clear mode bits for PA3 and PA2
	*(GPIOA_MODER) |= (0b1010<<4);  // Both PA3 and PA2 in alt function mode

	// Set up USART2
	// USART2_init();  //8n1 no flow control
	// over8 = 0..oversample by 16
	// M = 0..1 start bit, data size is 8, 1 stop bit
	// PCE= 0..Parity check not enabled
	// no interrupts... using polling
	*(USART_CR1) = (1<<UE)|(1<<TE)|(1<<RE); // Enable UART, Tx and Rx
	*(USART_CR2) = 0;  // This is the default, but do it anyway
 	*(USART_CR3) = 0;  // This is the default, but do it anyway
	*(USART_BRR) = sysclk/baud;

	 setvbuf(stdout, NULL, _IONBF, 0);
	 //Turn on interrupt & enable interrupt
	 *NVIC_ISER1 	|= (1<<USART2INTERUPT);
	 *USART_CR1		|= (1<<RXNEIE);
}

void USART2_IRQHandler(void){
    //Check the interrupt for receive
    if(*USART_SR & (1<<RXNE)){
    	char temp = *USART_DR; //DR is only 8-bit
    	buffer_add(&outputBuffer, temp);
        if (temp == '\r') {
        	usart2_putch('\n');
        	temp = '\n';
        }
        buffer_add(&inputBuffer, temp);
    }
    //Check the interrupt for Transmit
    if(*USART_SR & (1<<TXE)){
    	//Turn off transmit interrupt if the transmit buffer is empty
    	if(buffer_hasElement(&outputBuffer)){
    		*USART_DR = buffer_get(&outputBuffer);
    	}
    	else{
    		*USART_CR1	&= ~(1<<TXEIE);
    	}
    }
}


/**
  ******************************************************************************
  * @file     : uart_driver.c
  * @brief    : API to use the console
  *           : Lab 9: Piazo Song
  * @date     : NOV 08 2016
  * @author   : barnekow
  ******************************************************************************
  * @attention
  *
  * 
  * 
  ******************************************************************************
**/

#include "uart_driver.h"
#include <inttypes.h>
#include <stdio.h>

//==================================Methods====================================
/**
  * @brief  Read form the usart.
  * These will override _read in syscalls.c, which is Prototyped as weak
  * 
  * @param file: NOT USED
  * @param *ptr: location of the string read from the console
  * @param len: NOT USED
  * 
  * @retval number of bytes read
  */
int _read(int file, char *ptr, int len)
{
	int DataIdx;
	// Modified the for loop in order to get the correct behavior for fgets
	int byteCnt = 0;
	for (DataIdx = 0; DataIdx < len; DataIdx++)
	{
		byteCnt++;
		*ptr = usart2_getch();
		if(*ptr == '\n') break;
		ptr++;
	}
	return byteCnt; // Return byte count
}


/**
  * @brief  Write to the usart.
  * These will override _write in syscalls.c, which is Prototyped as weak
  * 
  * @param file: NOT USED
  * @param *ptr: location of the string read from the console
  * @param len: Length of the string written to the usart
  * 
  * @retval: number of bytes written
  */
int _write(int file, char *ptr, int len)
{
	int DataIdx;

	for (DataIdx = 0; DataIdx < len; DataIdx++)
	{
		usart2_putch(*ptr++);
	}
	return len;
}

/**
  * @brief  Get char from the console
  * 
  * @retval: The char read
  */
char usart2_getch(){
	char c;
	while((*(USART_SR)&(1<<RXNE)) != (1<<RXNE));
	c = ((char) *USART_DR);  // Read character from usart
	usart2_putch(c);  // Echo back

	if (c == '\r'){  // If character is CR
		usart2_putch('\n');  // send it
		c = '\n';   // Return LF. fgets is terminated by LF
	}

	return c;
}

/**
  * @brief  Write char to the console
  * 
  * @param c: char to write
  */
void usart2_putch(char c){
	while((*(USART_SR)&(1<<TXE)) != (1<<TXE));
	*(USART_DR) = c;
}

/**
  * @brief  Initialize the usart
  * 
  * @param baud: The baud rate
  * @param sysclk: The clockrate the of the processor
  */
void init_usart2(uint32_t baud, uint32_t sysclk){
	// Enable clocks for GPIOA and USART2
	*(RCC_AHB1ENR) |= (1<<GPIOAEN);
	*(RCC_APB1ENR) |= (1<<USART2EN);

	// Function 7 of PORTA pins is USART
	*(GPIOA_AFRL) &= (0xFFFF00FF); // Clear the bits associated with PA3 and PA2
	*(GPIOA_AFRL) |= (0b01110111<<8);  // Choose function 7 for both PA3 and PA2
	*(GPIOA_MODER) &= (0xFFFFFF0F);  // Clear mode bits for PA3 and PA2
	*(GPIOA_MODER) |= (0b1010<<4);  // Both PA3 and PA2 in alt function mode

	// Set up USART2
	//USART2_init();  //8n1 no flow control
	// over8 = 0..oversample by 16
	// M = 0..1 start bit, data size is 8, 1 stop bit
	// PCE= 0..Parity check not enabled
	// no interrupts... using polling
	*(USART_CR1) = (1<<UE)|(1<<TE)|(1<<RE); // Enable UART, Tx and Rx
	*(USART_CR2) = 0;  // This is the default, but do it anyway
	*(USART_CR3) = 0;  // This is the default, but do it anyway
	*(USART_BRR) = sysclk/baud;

	 setvbuf(stdout, NULL, _IONBF, 0);
}


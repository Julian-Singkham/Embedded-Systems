/*/
 * uart_driver.h
 *
 * Created on: Nov 8, 2016
 * Author: barnekow
 */

#ifndef UART_DRIVER_H_
#define UART_DRIVER_H_

#include <inttypes.h>

//=============================RCC===============================
#define RCC_APB1ENR (volatile uint32_t*) 0x40023840 //Peripheral enable 1 (USART, Timers)
#define RCC_AHB1ENR (volatile uint32_t*) 0x40023830 //Peripheral enable 1 (GPIOx)
//---------------------------APB1LPENR---------------------------
#define GPIOAEN     0   // GPIOA Enable is bit 0 in RCC_APB1LPENR
//---------------------------AHB1LPENR---------------------------
#define USART2EN    17  // USART2 enable is bit 17 in RCC_AHB1LPENR

//=========================GPIOA registers========================
#define GPIOA_MODER (volatile uint32_t*) 0x40020000 //Pin functions 2 bits per pin
#define GPIOA_AFRL  (volatile uint32_t*) 0x40020020 //Alternate Function Register

//============================USART================================
#define USART_SR    (volatile uint32_t*) 0x40004400 //Status Register
#define USART_DR    (volatile uint32_t*) 0x40004404 //Data Register
#define USART_BRR   (volatile uint32_t*) 0x40004408 //Bit Set Register
#define USART_CR1   (volatile uint32_t*) 0x4000440c //Control Register 1
#define USART_CR2   (volatile uint32_t*) 0x40004410 //Control Register 2
#define USART_CR3   (volatile uint32_t*) 0x40004414 //Control Register 3
//-----------------------------CR1----------------------------------
#define UE 13 // UART enable
#define TE 3  // Transmitter enable
#define RE 2  // Receiver enable
#define RXNE 5  //Recieve flag
#define TXE 7    //transmit flag
#define RXNEIE 5 //Enables recieve interrupt
#define TXEIE 7 //Enables transmit interrupt
//-----------------------------SR----------------------------------
#define TXE 7  // Transmit register empty
#define RXNE 5  // Receive register is not empty..char received

//============================NVIC===================================
//vector interrupt controller
#define NVIC_ISER0  (volatile uint32_t*)	0xE000E100  //Global vector map 1
#define NVIC_ISER1  (volatile uint32_t*)	0xE000E104  //Global vector map 2
//----------------------------ISER1----------------------------------
#define USART2INTERUPT 6 //Enable USART2

//=======================Function prototypes=========================
extern void init_usart2(uint32_t baud, uint32_t sysclk);

void USART2_IRQHandler(void);
//----------------------syscalls overrides------------------------------
int _read(int file, char *ptr, int len);
int _write(int file, char *ptr, int len);

#endif /* UART_DRIVER_H_ */

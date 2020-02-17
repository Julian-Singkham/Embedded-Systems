/*
 * registers.h
 * Lab 3: LCD + Keypad
 * Definitions for all registers
 *
 * Created on: DEC 17 2019
 * Author: Julian Singkham
 */
#ifndef REGISTERS_H
#define REGISTERS_H

//-------------------RCC Peripheral---------------------
#define RCC_BASE    (volatile uint32_t*)    0x40023800	//base address for clock
#define RCC_AHB1ENR (volatile uint32_t*)    0x40023830	//Peripheral enable 1 (GPIOx)
#define RCC_APB1ENR (volatile uint32_t*)    0x40023830	//Peripheral enable 1 (USART, Timers)
#define RCC_GPIOAEN	0x1
#define RCC_GPIOCEN	0x4

//------------------GPIO peripherals---------------------
#define GPIOA_MODER (volatile uint32_t*)    0x40020000	//Pin functions 2 bits per pin
#define GPIOA_IDR   (volatile uint32_t*)    0x40020010	//Pin input
#define GPIOA_ODR   (volatile uint32_t*)	0x40020014	//Pin output
#define GPIOA_BSRR  (volatile uint32_t*)	0x40020018	//on/off for individual pins
#define GPIOC_MODER (volatile uint32_t*)	0x40020800	//Pin functions
#define GPIOC_IDR   (volatile uint32_t*)	0x40020810	//Pin input
#define GPIOC_ODR   (volatile uint32_t*)	0x40020814	//Pin output
#define GPIOC_BSRR  (volatile uint32_t*)	0x40020818	//on/off for individual pins
#define GPIOC_PUPDR (volatile uint32_t*)	0x4002080C	//Sets pin as pullup/down

//------------GPIO MODER settings and bits--------------
#define INPUT 0
#define OUTPUT 1
#define ALTERNATE 2
#define ANALOG 3


#endif

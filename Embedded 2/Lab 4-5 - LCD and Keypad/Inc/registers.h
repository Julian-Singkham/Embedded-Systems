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

// RCC Peripheral
#define RCC_BASE (volatile uint32_t*)	 0x40023800	//base address for clock
#define RCC_AHB1ENR (volatile uint32_t*) 0x40023830	//Peripheral enable 1 (GPIOx)
#define RCC_GPIOAEN	0x1
#define RCC_GPIOCEN	0x4

// GPIO peripherals
#define GPIOA_MODER (volatile uint32_t*)	0x40020000	//Pin functions 2 bits per pin
#define GPIOA_IDR (volatile uint32_t*)		0x40020010	//Pin input
#define GPIOA_ODR (volatile uint32_t*)		0x40020014	//Pin output
#define GPIOA_BSRR (volatile uint32_t*)		0x40020018	//on/off for individual pins
#define GPIOC_MODER (volatile uint32_t*)	0x40020800	//Pin functions
#define GPIOC_IDR (volatile uint32_t*)		0x40020810	//Pin input
#define GPIOC_ODR (volatile uint32_t*)		0x40020814	//Pin output
#define GPIOC_BSRR (volatile uint32_t*)		0x40020818	//on/off for individual pins
#define GPIOC_PUPDR (volatile uint32_t*)	0x4002080C	//Sets pin as pullup/down

// GPIO Bits
#define DR0 0
#define DR1 1
#define DR2 2
#define DR3 3
#define DR4 4
#define DR5 5
#define DR6 6
#define DR7 7
#define DR8 8
#define DR9 9
#define DR10 10
#define DR11 11
#define DR12 12
#define DR13 13
#define DR14 14
#define DR15 15

// GPIO MODER settings and bits
#define INPUT 0
#define OUTPUT 1
#define ALTERNATE 2
#define ANALOG 3

#define MODER0 0
#define MODER1 2
#define MODER2 4
#define MODER3 6
#define MODER4 8
#define MODER5 10
#define MODER6 12
#define MODER7 14
#define MODER8 16
#define MODER9 18
#define MODER10 20
#define MODER11 22
#define MODER12 24
#define MODER13 26
#define MODER14 28
#define MODER15 30

#endif

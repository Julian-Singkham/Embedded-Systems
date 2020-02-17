/**
  ******************************************************************************
  * @file    register.h
  * @author  John Bretz
  * @version V1.0
  * @brief   Defines for useful constants for registers and gpio busses.
  ******************************************************************************
*/

#ifndef REGISTER_H
#define REGISTERS_H

#define RCC_BASE 0x40023800

#define AHB1ENR 0x0C

#define GPIOA_BASE 0x40020000
#define GPIOB_BASE 0x40020400
#define GPIOC_BASE 0x40020800

#define GPIOAEN 1<<0
#define GPIOBEN 1<<1
#define GPIOCEN 1<<2
#define GPIODEN 1<<3
#define GPIOEEN 1<<4
#define GPIOFEN 1<<5
#define GPIOGEN 1<<6
#define GPIOHEN 1<<7

#define MODER 0
#define PUPDR 3
#define IDR   4
#define ODR   5
#define BSRR  6

#define INPUT     0b00
#define OUTPUT    0b01
#define ALTERNATE 0b10
#define ANALOG    0b11

#define NO_PU_PD  0b00
#define PULL_UP   0b01
#define PULL_DOWN 0b10
#define RESERVED  0b11

#endif

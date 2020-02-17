/**
  ******************************************************************************
  * @file     : main.h
  * @brief    : Header for main.c file.
  *           : Lab 9: Piazo Song
  * @date     : FEB 09 2020
  * @author   : Julian Singkham
  ******************************************************************************
  * @attention
  *           
  * Protoypes and definitons for main.
  *
  ******************************************************************************
  */

#define __MAIN_H

#ifdef __cplusplus
extern "C" {
#endif

#include "stm32f4xx_hal.h"

//============================Function Prototypes===============================
void HAL_TIM_MspPostInit(TIM_HandleTypeDef *htim);
void Error_Handler(void);


#ifdef __cplusplus
}
#endif

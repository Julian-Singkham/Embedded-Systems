/**
  ******************************************************************************
  * @file           : music.c
  * @brief          : Functions to play a song on the piezo speaker
  ******************************************************************************
  */

#include "music.h"
#include "main.h"
#include "timing.h"
#include "stm32f446xx.h"
#include "uart_driver.h"

extern TIM_HandleTypeDef htim3;
extern TIM_HandleTypeDef htim10;

static void change_freq(int freq) {
    htim3.Init.Period = freq;
    HAL_TIM_OC_Init(&htim3);
}

static void change_delay(int len) {
    static int *tim10 = (int *)0x4001442C;
    *tim10 = len;
}

void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim) {
    if (htim == &htim10) {

        // stop the timers
        HAL_TIM_Base_Stop_IT(&htim10);
        HAL_TIM_OC_Stop(&htim3, TIM_CHANNEL_1);

        if (cur_song->len != 0) {
            int freq = cur_song->freq;
            int len = cur_song->len;

            int arr_val = freq != 0 ? 16000000 / (2 * freq) : 0;
            int del = len * 20;

            // change note frequency
            change_freq(arr_val);

            // change note duration
            change_delay(del);

            // startup the timers
            HAL_TIM_OC_Start(&htim3, TIM_CHANNEL_1);
            HAL_TIM_Base_Start_IT(&htim10);

            // inc pointer
            cur_song++;
        }
    }
}

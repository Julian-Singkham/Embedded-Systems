/**
  ******************************************************************************
  * @file     : Music.c
  * @brief    : Plays songs
  *           : Lab 9: Piazo Song
  * @date     : FEB 09 2020
  * @author   : Julian Singkham
  ******************************************************************************
  * @attention
  *
  * This file contains the data for the songs and handles playing them.
  *
  ******************************************************************************
**/

#include "music.h"
#include "main.h"
#include "timing.h"
#include "stm32f446xx.h"
#include "uart_driver.h"

//==================================variables====================================
extern TIM_HandleTypeDef htim3;
extern TIM_HandleTypeDef htim10;
//Creates the song array
Tone guile[] = {
{NOTE_FS5, EIGHTH},  {NOTE_FS5, EIGHTH},  {NOTE_D5,  EIGHTH},  {NOTE_B4,  QUARTER}, 
{NOTE_B4,  QUARTER}, {NOTE_E5,  QUARTER}, {NOTE_E5, QUARTER},  {NOTE_E5, FIFTH},
{NOTE_GS5, EIGHTH},  {NOTE_GS5, EIGHTH},  {NOTE_A5, EIGHTH},   {NOTE_B5, EIGHTH},
{NOTE_A5, EIGHTH},   {NOTE_A5, EIGHTH},   {NOTE_A5, EIGHTH},   {NOTE_E5, QUARTER},
{NOTE_D5, QUARTER},  {NOTE_FS5, QUARTER}, {NOTE_FS5, QUARTER}, {NOTE_FS5, FIFTH},
{NOTE_E5, EIGHTH},   {NOTE_E5, EIGHTH},   {NOTE_FS5, EIGHTH},  {NOTE_E5, EIGHTH},
{NOTE_FS5, EIGHTH},  {NOTE_FS5, EIGHTH},  {NOTE_D5,  EIGHTH},  {NOTE_B4,  QUARTER},
{NOTE_B4,  QUARTER}, {NOTE_E5,  QUARTER}, {NOTE_E5, QUARTER},  {NOTE_E5, FIFTH},
{NOTE_GS5, EIGHTH},  {NOTE_GS5, EIGHTH},  {NOTE_A5, EIGHTH},   {NOTE_B5, EIGHTH},
{NOTE_A5, EIGHTH},   {NOTE_A5, EIGHTH},   {NOTE_A5, EIGHTH},   {NOTE_E5, QUARTER},
{NOTE_D5, QUARTER},  {NOTE_FS5, QUARTER}, {NOTE_FS5, QUARTER}, {NOTE_FS5, FIFTH},
{NOTE_E5, EIGHTH},   {NOTE_E5, EIGHTH},   {NOTE_FS5, EIGHTH},  {NOTE_E5, EIGHTH},
NOTE_END,
};
Tone *current_song = guile; //Current song

//====================================Methods====================================
/**
  * @brief Change frequency of the Piazo Buzzer
  * 
  * @param freq: The note to be played
  */
static void change_freq(int note) {
    htim3.Init.Period = note;
    HAL_TIM_OC_Init(&htim3);
}

/**
  * @brief Change the period of the note
  * 
  * @param duation: How long the note will play
  */
static void change_delay(int duration) {
    static int *tim10 = (int *)0x4001442C;
    *tim10 = duration;
}

/**
  * @brief Interrupt for Timer reaching the limit
  * 
  * @param htim: The location of the interrupt that was called
  */
void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim) {
  //verify that timer 10 caused it
  if (htim == &htim10) {
    //stop the timers
    HAL_TIM_Base_Stop_IT(&htim10);
    HAL_TIM_OC_Stop(&htim3, TIM_CHANNEL_1);
    
    if (current_song->duration != 0) {
      int freq = current_song->note;
      int duration = current_song->duration;

      int arr_val = freq != 0 ? 16000000 / (2 * freq) : 0;
      int del = duration * 20;
      change_freq(arr_val); //change note frequency
      change_delay(del);  //change note duration
      
      //startup the timers
      HAL_TIM_OC_Start(&htim3, TIM_CHANNEL_1);
      HAL_TIM_Base_Start_IT(&htim10);

      //increment pointer
      current_song++;
    }
  }
}

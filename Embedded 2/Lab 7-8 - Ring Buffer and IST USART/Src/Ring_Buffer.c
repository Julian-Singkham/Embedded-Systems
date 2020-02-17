/*
 * Ring_Buffer.c
* Lab 7-8: Ring Buffer and ISR USART
 * API to use a ring buffer
 *
 * Created on: JAN 24 2020
 * Author: Julian Singkham
 */

#include <stdio.h>
#include <string.h>
#include "ring_buffer.h"

/*
 * Adds elements to the buffer
 * Blocks.
 */
void buffer_add(RingBuffer* buffer, char element){
	while(!buffer_hasSpace(buffer));
	buffer->buffer[buffer->put] = element;
	if(buffer->put >= BUF_SIZE){
		buffer->put = 0;
	}
	else{
		buffer->put++;
	}
	buffer->amount++;
}

/*
 * Gets element from the buffer.
 */
char buffer_get(RingBuffer* buffer){
	char temp;
	while(!buffer_hasElement(buffer));
	temp = buffer->buffer[buffer->get];
	if(buffer->get >= BUF_SIZE){
		buffer->get = 0;
	}
	else{
		buffer->get++;
	}
	buffer->amount--;
	return temp;
}

/*
 * Returns true (1) if there is room for one element in buffer
 */
int buffer_hasSpace(RingBuffer* buffer){
	return BUF_SIZE != buffer->amount;
}

/*
 * Returns true (1) if there is at least one element in buffer
 */
int buffer_hasElement(RingBuffer* buffer){
	return buffer->amount > 0;
}

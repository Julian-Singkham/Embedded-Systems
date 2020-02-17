/*
 * ring_buffer.h
 * Lab 6-7: Ring Buffer and ISR UART
 *
 * Created on: JAN 24 2020
 * Author: Julian Singkham
 */
#define ring_buffer_H


#define BUF_SIZE 50

typedef struct{
	int put;
	int get;
	int amount;
	char buffer[BUF_SIZE];// Size of the buffer
} RingBuffer;

void buffer_add(RingBuffer* buffer, char element);
char buffer_get(RingBuffer* buffer);
int buffer_hasSpace(RingBuffer* buffer);
int buffer_hasElement(RingBuffer* buffer);

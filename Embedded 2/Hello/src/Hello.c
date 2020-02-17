/*
 ============================================================================
 Name        : Hello.c
 Author      : 
 Version     :
 Copyright   : Your copyright notice
 Description : Hello World in C, Ansi-style
 ============================================================================
 */

#include <stdio.h>
#include <stdlib.h>

int main(void) {
	setvbuf(stdout, NULL, _IONBF, 0); //only needed for compiler
	setvbuf(stderr, NULL, _IONBF, 0); //only needed for compiler
	int bob = 0b111001;
	int tom = 0b000000;
	if(bob & tom){
		printf("works");
	}
	else{
		printf("fuck");
	}


//
//	char buffer[10];
//	int bob = 34000;
//	sprintf(buffer, "%d", bob);
//
//	printf("%s", buffer[1]);
//	//for(int i =0; i<sizeof(buffer); i++){
//		//printf("number:%s", buffer[i]);
//	//}
//
	return EXIT_SUCCESS;
}

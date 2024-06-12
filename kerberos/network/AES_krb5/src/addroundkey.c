/*
 * addroundkey.c
 *
 *  Created on: Sep 9, 2018
 *      Author: jonas
 */
#include "../include/addroundkey.h"

unsigned char* addRoundKey(unsigned char currentState[16], unsigned char key[16]) {
	static unsigned char newState[16];
	for (int i = 0; i < 16; i++) {
		newState[i] = currentState[i] ^ key[i];
	}
	return newState;
}


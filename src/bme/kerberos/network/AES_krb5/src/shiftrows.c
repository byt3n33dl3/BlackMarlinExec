
/*
 * shiftrows.c
 *
 *  Created on: Sep 8, 2018
 *      Author: jonas
 */

#include "../include/shiftrows.h"

unsigned char* shiftRows(unsigned char currentState[16]) {
	static unsigned char newState[16];
	for (int i = 0; i < 4; i++) {
		for (int j = 0; j < 4; j++) {
			int currentIndex = i * 4 + j;
			newState[currentIndex] = currentState[i * 4 + (j + i) % 4];
		}
	}
	return newState;
}

unsigned char* invShiftRows(unsigned char currentState[16]) {
	// Could be done by 3 x ShiftRows.
	static unsigned char newState[16];
	for (int i = 0; i < 4; i++) {
		for (int j = 0; j < 4; j++) {
			int currentIndex = i * 4 + j;
			newState[currentIndex] = currentState[i * 4 + negModulo(j - i, 4)];
		}
	}
	return newState;
}

int negModulo(int x, int N) {
	// Modulo that also works with negative x
    return (x % N + N) % N;
}

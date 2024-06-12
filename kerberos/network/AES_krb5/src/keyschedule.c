/*
 * keyschedule.c
 *
 *  Created on: Sep 8, 2018
 *      Author: jonas
 */

#include "../include/keyschedule.h"
#include "../include/subbytes.h"

unsigned char roundConst[10] = {0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1B, 0x36};

unsigned char* getFunnyWord(unsigned char subWord[4], unsigned char roundConst) {
	static unsigned char funnyWord[4];
	for (int i = 0; i < 4; i++) {
		if (i == 0) {
			funnyWord[i] = sBox(subWord[(i + 1) % 4]) ^ roundConst;
		} else {
			funnyWord[i] = sBox(subWord[(i + 1) % 4]);
		}
	}
	return funnyWord;
}

unsigned char* keySchedule(unsigned char currentKey[16], int round) {
	static unsigned char newKey[16];
	unsigned char currentSubKeys[4][4];
	unsigned char *funnyWord;

	for (int i = 0; i < 4; i++) {
		for (int j = 0; j < 4; j++) {
			currentSubKeys[i][j] = currentKey[4 * j + i];
		}
	}
	funnyWord = getFunnyWord(currentSubKeys[3], roundConst[round]);

	for (int i = 0; i < 4; i++) {
		for (int j = 0; j < 4; j++) {
			if (i == 0) {
				newKey[4 * j + i] = currentSubKeys[i][j] ^ funnyWord[j];
			} else {
				newKey[4 * j + i] = currentSubKeys[i][j] ^ newKey[4 * j + (i - 1)];
			}
		}
	}
	return newKey;
}

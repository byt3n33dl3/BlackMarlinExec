/*
 * AES128.c
 *
 *  Created on: Sep 9, 2018
 *      Author: jonas
 */

#include <stdio.h>
#include <stdlib.h>
#include "../include/keyschedule.h"
#include "../include/addroundkey.h"
#include "../include/mixcolumns.h"
#include "../include/subbytes.h"
#include "../include/shiftrows.h"
#include "../include/ttable.h"

void printState(unsigned char state[16], char mes[]) {
	printf("%s: \t\t", mes);
	printf("0x");
	    for(int i = 0; i < 16; i++)
	        printf("%02x", state[i]);
	printf("\n");
}

unsigned char* standardEncrypt(unsigned char state[16], unsigned char key[16]) {
	unsigned char *newKey, *newState;

	newState = addRoundKey(state, key);
	newKey = keySchedule(key, 0);

	for (int i = 1; i < 10; i++) {
		newState = subBytes(newState);
//		printState(state, "After SubBytes");
		newState = shiftRows(newState);
//		printState(state, "After ShiftRows");
		newState = mixColumns(newState);
//		printState(newState, "After MixColumns");
//		printState(newKey, "key");
		newState = addRoundKey(newState, newKey);
//		printState(state, "After AddRoundKey");
		newKey = keySchedule(newKey, i);
//		printf("\n");
	}

	newState = subBytes(newState);
//	printState(newState, "After SubBytes");
	newState = shiftRows(newState);
//	printState(newState, "After ShiftRows");
//	printState(newKey, "key");
	newState = addRoundKey(newState, newKey);
//	printState(newState, "Final");

	return newState;
}

unsigned char* tTableEncrypt(unsigned char state[16], unsigned char key[16]) {
	unsigned char *newKey, *newState;

	newState = addRoundKey(state, key);
	newKey = keySchedule(key, 0);

	for (int i = 1; i < 10; i++) {
//		printState(newState, "Before remixTTable");
		newState = subShiftMixTTable(newState);
//		printState(newState, "After remixTTable");
//		printState(newKey, "key");
		newState = addRoundKey(newState, newKey);
//		printState(newState, "After AddRoundKey");
		newKey = keySchedule(newKey, i);
//		printf("\n");
	}

	newState = subBytes(newState);
//	printState(newState, "After SubBytes");
	newState = shiftRows(newState);
//	printState(newState, "After ShiftRows");
//	printState(newKey, "key");
	newState = addRoundKey(newState, newKey);
//	printState(newState, "Final");

	return newState;
}

char* AES128Encrypt(const char plaintext[16], const char keyString[16]) {
	static char res[32];
	int k = 0;
	const char *pos1 = plaintext, *pos2 = keyString;
	unsigned char state[16], key[16], tempState[16], tempKey[16], *newState;

	// Plaintext to state array and key similar
	for (int i = 0; i < sizeof state/sizeof *state; i++) {
		sscanf(pos1, "%2hhx", &tempState[i]);
		sscanf(pos2, "%2hhx", &tempKey[i]);
		pos1 += 2;
		pos2 += 2;
	}
	for (int i = 0; i < 4; i++) {
		for (int j = 0; j < 4; j++) {
			key[4 * i + j] = tempKey[4 * j + i];
			state[4 * i + j] = tempState[4 * j + i];
		}
	}

	newState = tTableEncrypt(state, key);
//	newState = standardEncrypt(state, key);

	for (int i = 0; i < 4; i++) {
		for (int j = 0; j < 4; j++) {
			sprintf(&res[k], "%02x", newState[4 * j + i]);
			k += 2;
		}
	}
	return res;
}

char* AES128Decrypt(const char chipertext[16], const char keyString[16]) {
	static char res[32];
	int k = 0;
	const char *pos1 = chipertext, *pos2 = keyString;
	unsigned char state[16], tempState[16], tempKey[16], keys[11][16], *newState, *newKey;

	// Plaintext to state array and key similar
	for (int i = 0; i < sizeof state/sizeof *state; i++) {
		sscanf(pos1, "%2hhx", &tempState[i]);
		sscanf(pos2, "%2hhx", &tempKey[i]);
		pos1 += 2;
		pos2 += 2;
	}
	for (int i = 0; i < 4; i++) {
		for (int j = 0; j < 4; j++) {
			keys[0][4 * i + j] = tempKey[4 * j + i];
			state[4 * i + j] = tempState[4 * j + i];
		}
	}

	for (int i = 0; i < 10; i++) {
		newKey = keySchedule(keys[i], i);
		for (int j = 0; j < 16; j++) {
			keys[i + 1][j] = newKey[j];
		}
	}

//	printState(keys[10], "key");
	newState = addRoundKey(state, keys[10]);
//	printState(state, "First");
	newState = invShiftRows(newState);
//	printState(newState, "After InvShiftRows");
	newState = invSubBytes(newState);
//	printState(newState, "After InvSubBytes");

	for (int i = 9; i > 0; i--) {
//		printState(keys[i], "key");
		newState = addRoundKey(newState, keys[i]);
//		printState(newState, "After AddRoundKey");
		newState = invMixColumns(newState);
//		printState(newState, "After InvMixColumns");
		newState = invShiftRows(newState);
//		printState(newState, "After InvShiftRows");
		newState = invSubBytes(newState);
//		printState(newState, "After InvSubBytes");
//		printf("\n");
	}

//	printState(newState, "Almost last");
	newState = addRoundKey(newState, keys[0]);
//	printState(newState, "Last");

	for (int i = 0; i < 4; i++) {
		for (int j = 0; j < 4; j++) {
			sprintf(&res[k], "%02x", newState[4 * j + i]);
			k += 2;
		}
	}
	return res;
}

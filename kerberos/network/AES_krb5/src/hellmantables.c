#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include "../include/keyschedule.h"
#include "../include/addroundkey.h"
#include "../include/subbytes.h"
#include "../include/shiftrows.h"
#include "../include/ttable.h"

unsigned char plaintext[16] = {
	0xf3, 0x3c, 0xcd, 0x08,
	0x44, 0xc6, 0x5d, 0xf2,
	0x81, 0x27, 0xc3, 0x73,
	0xec, 0xba, 0xfb, 0xe6 };

char* shortAES(const char keyString[6]) {
	static char res[6];
	unsigned char *newState, *newKey;
	unsigned char key[16] = {
		0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00 };

	for (int i = 0; i < 3; i++) {
		sscanf(&keyString[2 * i], "%2hhx", &key[i*4]);
	}
	newState = addRoundKey(plaintext, key);
	newKey = keySchedule(key, 0);

	for (int i = 1; i < 10; i++) {
		newState = subShiftMixTTable(newState);
		newState = addRoundKey(newState, newKey);
		newKey = keySchedule(newKey, i);
	}

	newState = subBytes(newState);
	newState = shiftRows(newState);
	newState = addRoundKey(newState, newKey);

	for (int i = 0; i < 3; i++) {
		sprintf(&res[2 * i], "%02x", newState[4 * i]);
	}
	return res;
}

void generateHellman() {
	int m = pow(2,11);
	int t = pow(2,5);
	int L = pow(2,8); // Number of tables
	int divisor = pow(2, 24);
	int *registr;
	char key[6 + 1];
	int totalNoUniqueKeys = 0;
	int key_index = 0;

	registr = (int*) malloc(m*L*t * sizeof(int));
	FILE *output;
	FILE *points;
	output = fopen("HellmanTables.txt","w");
	points = fopen("points.txt","w");

	//Tables
	for (int i = 0; i < L; i++) {
		printf("Table no: %d\n", i);

		// Rows
		for (int j = 0; j < m; j++) {

			// Generate random key
			for (int index = 0; index < 6; index++) {
			    sprintf(key + index, "%x", rand() % 16);
			}
			fprintf(output, "%s,", key);	//Chain start point

			// Chains
			for (int k = 1; k < t; k++)	{
				int key_int = (int) strtol(key, NULL, 16);

				// Check if key is registered before
				for (key_index = 0; key_index < totalNoUniqueKeys; key_index++) {
					if (key_int == *(registr + key_index)) {
						break;
					}
				}
				if (key_index == totalNoUniqueKeys) {
					*(registr + totalNoUniqueKeys) = key_int;
					totalNoUniqueKeys++;
				}

				key_int = ((int) strtol(shortAES(key), NULL, 16) + i) % divisor;
				snprintf(key, 7, "%06x", key_int);
			}

			fprintf(output, "%s\n", key);	//Chain end point
		}
		fprintf(points, "%d,", totalNoUniqueKeys);
		printf("Total number of unique keys: %d\n", totalNoUniqueKeys);
	}

	printf("Done!");
	fclose(output);
	fclose(points);
	free(registr);
}


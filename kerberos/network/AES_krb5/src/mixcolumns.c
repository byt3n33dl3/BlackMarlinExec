/*
 * mixcolumns.c
 *
 *  Created on: Sep 8, 2018
 *	  Author: jonas
 */

#include "../include/mixcolumns.h"

unsigned char M[4][4] = {
	{0x02, 0x03, 0x01, 0x01},
	{0x01, 0x02, 0x03, 0x01},
	{0x01, 0x01, 0x02, 0x03},
	{0x03, 0x01, 0x01, 0x02} };

unsigned char invM[4][4] = {
	{0x0e, 0x0b, 0x0d, 0x09},
	{0x09, 0x0e, 0x0b, 0x0d},
	{0x0d, 0x09, 0x0e, 0x0b},
	{0x0b, 0x0d, 0x09, 0x0e} };

//Multiply two numbers in the GF(2^8) finite field defined by the polynomial x^8 + x^4 + x^3 + x + 1 = 0
char gMul(char a, char b) {
	char p = 0;
	for (int i = 0; i < 8; i++) {
		if (b & 1) {
			p ^= a;
		}
		if (a & 0x80) {
			a <<= 1;
			a ^= 0x1b;
		} else {
			a <<= 1;
		}
		b >>= 1;
	}
	return p;
}

char g2Mul(char a, char b) {
	if (a == 0x09) {
		return gMul(0x02, gMul(0x02, gMul(0x02, b))) ^ b;
	}
	if (a == 0x0b) {
		return gMul(0x02, gMul(0x02, gMul(0x02, b)) ^ b) ^ b;
	}
	if (a == 0x0d) {
		return gMul(0x02, gMul(0x02, gMul(0x02, b) ^ b)) ^ b;
	}
	if (a == 0x0e) {
		return gMul(0x02, gMul(0x02, gMul(0x02, b) ^ b) ^ b);
	}
	return gMul(a, b);
}

unsigned char vectorsDotProd(unsigned char *x, const unsigned char *y) {
	unsigned char res = 0x00;
	for (int i = 0; i < 4; i++) {
		res ^= gMul(x[i], y[i]);
	}
	return res;
}

unsigned char* matrixVectorMult(const unsigned char *vec) {
	static unsigned char result[4];
	for (int i = 0; i < 4; i++) {
		result[i] = vectorsDotProd(M[i], vec);
	}
	return result;
}

unsigned char* invMatrixVectorMult(const unsigned char *vec) {
	static unsigned char result[4];
	for (int i = 0; i < 4; i++) {
		result[i] = vectorsDotProd(invM[i], vec);
	}
	return result;
}

unsigned char* mixColumns(unsigned char state[16]) {
	static unsigned char result[16];
	unsigned char *subres;
	for (int i = 0; i < 4; i++) {
		unsigned char vec[4];
		for (int j = 0; j < 4; j++) {
			vec[j] = state[4 * j + i];
		}
		subres = matrixVectorMult(vec);
		for (int j = 0; j < 4; j++) {
			result[4 * j + i] = subres[j];
		}
	}
	return result;
}

unsigned char* invMixColumns(unsigned char state[16]) {
	static unsigned char result[16];
	unsigned char *subres;
	for (int i = 0; i < 4; i++) {
		unsigned char vec[4];
		for (int j = 0; j < 4; j++) {
			vec[j] = state[4 * j + i];
		}
		subres = invMatrixVectorMult(vec);
		for (int j = 0; j < 4; j++) {
			result[4 * j + i] = subres[j];
		}
	}
	return result;
}

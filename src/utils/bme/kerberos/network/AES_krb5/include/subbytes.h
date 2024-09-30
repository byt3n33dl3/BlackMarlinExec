/*
 * subbytes.h
 *
 *  Created on: Sep 8, 2018
 *      Author: jonas
 */

#ifndef subbytes_h_
#define subbytes_h_

unsigned char* subBytes(unsigned char[16]);

unsigned char* invSubBytes(unsigned char[16]);

unsigned char sBox(unsigned char);

unsigned char invSBox(unsigned char);

#endif /* subbytes_h_ */

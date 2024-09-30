#include <time.h>
#include <stdio.h>
#include "../include/timing.h"

clock_t startTime;

void startTimer() {
	startTime = clock();
}

void stopTimer() {
	clock_t timeSpent = clock() - startTime;
	printf("cpu time : %f (sec.)\n", (double)timeSpent / CLOCKS_PER_SEC);
}


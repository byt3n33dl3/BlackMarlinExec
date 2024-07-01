/*
* User inputs integer number.  This number represents the count of random numbers to generate.
* Each of these numbers is counted in an array of 10 integers.
* When the number generation is complete, a chart of the distribution is sent to stdout.
*/

#include <stdio.h>
#include <stdlib.h>

int main()
{
	int count;
	int tally[10] = { '0' };

	printf("Number of Random Integers to Generate: ");
	scanf("%d", &count);
	while(count > 0)
	{
		tally[rand()%10]++;
		--count;
	}

	while(count < 10)
	{
		printf("%d->%d\n", count, tally[count]);
		++count;
	}
	return 0;
}

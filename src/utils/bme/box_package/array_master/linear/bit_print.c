/*

Prints out the bits contained in an integer value.

*/

#include <stdio.h>
#include <limits.h>

void bit_print(int a)
{
	int i;
	int n = sizeof(int) * CHAR_BIT;  /* find size of ints for this macine */
	int mask = 1 << (n - 1); /* set mask to 1000000...000 */

	for(i = 1; i <= n; ++i)
	{
		putchar(((a & mask) == 0) ? '0' : '1');
		a <<= 1; /* shift over by one bit */
		if(i % CHAR_BIT == 0 && i < n)
			putchar(' ');
	}
	putchar('\n');

}

int main()
{
	int number;

	for(number = 0; number <= 16; ++number)
	{
		bit_print(number);
	}

	return 0;
}

/* Find triples of integers that add up to N */

#include <stdio.h>

#define N 7

int main()
{
	int cnt = 0, i, j, k;

	for(i = 0; i <= N; ++i)
		for(j = 0; j <= N; ++j)
			for(k = 0; k <= N; ++k)
				if(i + j + k == N)
				{
					++cnt;
					printf("%3d%3d%3d\n", i, j, k);
				}
	printf("\nCount: %d\n", cnt);
	return 0;
}

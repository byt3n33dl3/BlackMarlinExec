#include <stdio.h>
#include <stdlib.h>

int main(void)
{
	int i, n, col;

	printf("\n%s\n%s",
		"Some randomly distributed integers. ",
		"How many to print? ");
	scanf("%d", &n);
	printf("How many columns? ");
	scanf("%d", &col);

	for(i=0; i < n; ++i)
	{
		if(i % col == 0) { printf("\n"); }
		printf("%d", rand()%10);
	}
	printf("\n");

	return 0;
}

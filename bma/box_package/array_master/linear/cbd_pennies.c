#include <stdio.h>

int main()
{
	int h,	// half dollars
	q,	// quarters
	n,	// nickels
	p,	// pennies
	coins;

	printf("Calculates value of change.\n");
	printf("Half Dollars: ");
	scanf("%d", &h);
	printf("Quarters: ");
	scanf("%d", &q);
	printf("Nickels: ");
	scanf("%d", &n);
	printf("Pennies: ");
	scanf("%d", &p);

	printf("Half Dollars: %d\n", h);
	printf("Quarters: %d\n", q);
	printf("Nickels: %d\n", n);
	printf("Pennies: %d\n", p);

	coins = h+q+n+p;
	p = p + (h*50) + (q*25) + (n*5);

	printf("The value of your %d coins is %d pennies.\n", coins, p);

	return 0;
}

#include <stdio.h>

int main()
{
	int input_value, minutes, seconds;

	printf("Input Number of seconds: ");
	scanf("%d", &input_value);
	minutes = input_value / 60;
	seconds = input_value % 60;
	printf("%d seconds is equivalent to %d minutes and %d seconds.\n", input_value, minutes, seconds);
	return 0;
}

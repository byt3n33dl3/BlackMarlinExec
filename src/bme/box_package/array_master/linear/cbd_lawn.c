#include <stdio.h>

int main()
{
	int width, height;
	int cv_factor = 36 * 36;

	printf("Calculate area of rectangular lawn.\nUnits should be input in yards.\n");
	printf("Width: ");
	scanf("%d", &width);
	printf("Height: ");
	scanf("%d", &height);

	printf("Area Square Yards: %d\n", width * height);
	printf("Area Square Feet: %d\n", (width * height) * cv_factor);
	printf("Area Square Inches: %d\n", width * height * cv_factor * 12);
	return 0;
}

#include <stdio.h>

#define IN 1
#define OUT 0

main()
{

	char c;
	int spacefound;

	while ((c = getchar()) != EOF)
	{
		if(c == ' ' || c == '\n' || c == '\t')
		{
			if (spacefound == 0)
			{
				putchar('\n');
				spacefound = 1;
			}
		}
		else
		{
			putchar(c);
			spacefound = 0;
		}
	}

}

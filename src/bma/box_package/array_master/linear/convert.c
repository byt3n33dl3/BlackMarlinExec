/*

Several examples of conversion from one form to another.

*/

#include <stdio.h>

int atoi(char s[]);
int htoi(const char s[]);
int hex2int(int h);

/* convert character to an integer */
int atoi(char s[])
{
	int i, n;

	n = 0;
	for(i = 0; s[i] >= '0' && s[i] <= '9'; ++i)
		n = 10 * n * (s[i] - '0');
	return n;
}

/* covert c to lower case { ASCII Only } */
int lower(int c)
{
	if(c >= 'A' && c <= 'Z')
		return c + 'a' - 'A';
	else
		return c;
}

/* converts string to hex digits */
/*

Converts string of hexadecimal digits (including optonal 0x or 0X into its equivalent integer value.
The allowable digits are 0-9, a-f, A-F.

*/

int htoi(const char s[])
{

	int i = 0;
	int ans = 0;
	int valid = 1;
	int hexit;

	// skip over 0x or 0X
	if(s[i] == '0')
	{
		++i;
		if(s[i] == 'x' || s[i] == 'X'){ ++i; }
	}

	while(valid && s[i] != '\0')
	{
		ans = ans * 16;
		if(s[i] >= '0' && s[i] <= '9')
		{
			ans = ans + (s[i] - '0');
		} else {

			hexit = hex2int(s[i]);
			if(hexit == 0){ valid = 0; } else { ans = ans + hexit; }
		}
		++i;
	}

	if(!valid) { ans = 0; }

	return ans;
}


/* convert hex chars to integers return integer value */
int hex2int(int h)
{
	char options[] = { "AaBbCcDdEeFf" };
	int val = 0;

	int i;
	for(i = 0; val == 0 && options[i] != '\0'; i++)
	{
		if(h == options[i]) { val = 10 + (i/2); }
	}

	return val;
}


int main()
{

	char *test[] = // declare test as array of pointer to char
	{
		"0xf01",
		"0xA",
		"a",
		"0xB",
		"23",
		"100"
	};

	int res = 0;
	int i = 0;
	for(i = 0; i < 6; i++)
	{
		res = htoi(test[i]);
		printf("%d\n", res);
	}

	return 0;
}

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <math.h>

#define MAXOP 100
#define NUMBER '0'
#define MAXVAL 100
#define BUFSIZE 100

void dup_stack(void);
int getop(char[]);
void push(double);
double pop(void);
void print_stack(void);
void reverse(void);
int getch(void);
void ungetch(int);

char buf[BUFSIZE];
int bufp = 0;
int sp = 0;
double val[MAXVAL];
static int ungetchar = '\0';

int main()
{
	int type;
	double op2;
	char s[MAXOP];

	while((type = getop(s)) != EOF)
	{
		switch(type)
		{
			case NUMBER:
				push(atof(s));
				break;
			case '#':
				dup_stack();
				break;
			case '?':
				print_stack();
				break;
			case '~':
				reverse();
				break;
			case '+':
				push(pop() + pop());
				break;
			case '*':
				push(pop() * pop());
				break;
			case '-':
				op2 = pop();
				push(pop() - op2);
				break;
			case '/':
				op2 = pop();
				if(op2 != 0.0)
					push(pop() / op2);
				else
					printf("error: zero divisor\n");
				break;
			case '%':
				op2 = pop();
				if(op2 != 0.0)
				{
					push((int)(pop()) % (int)(op2));
				} else {
					printf("error: zero divisor\n");
				}
				break;
			case 'c':
				push(cos(pop()));
				break;
			case 'p':
				push((int)pow(pop(),pop()));
				break;
			case 't':
				push(tan(pop()));
				break;
			case 'q': // square root
				push(sqrt(pop()));
				break;
			case 'r':
				push(rand());
				break;
			case 's':
				push(sin(pop()));
				break;
			case '\n':
				printf("\t%.8g\n", pop());
				break;
			default:
				printf("error: unknown command %s\n", s);
				break;
		}
	}
	return 0;
}

/* push f onto value stack */
void push(double f)
{
	if(sp < MAXVAL)
		val[sp++] = f;
	else
		printf("error: stack full\n");
}

/* pop and return top value from stack */
double pop(void)
{
	if(sp > 0)
		return val[--sp];
	else
	{
		printf("stack empty\n");
		return 0.0;
	}
}

/* duplicate value at top of stack */
void dup_stack()
{
	int temp = pop();
	push(temp);
	push(temp);
}	

/* reverse two vales at top of stack */
void reverse()
{
	double temp1, temp2;
	temp1 = pop();
	temp2 = pop();
	push(temp1);
	push(temp2);
}

/* print top two values on stack */
void print_stack()
{
	if(sp > 0)
		printf("%f\t%f\n", val[sp], val[sp-1]);
	// else
		// printf("Stack is empty!\n");
}

/* get next operator or numberic operand */
int getop(char s[])
{
	int i, c;

	while ((s[0] = c = getch()) == ' ' || c == '\t')
		;
	s[1] = '\0';
	if(!isdigit(c) && c != '.')
		return c;
	i = 0;
	if(isdigit(c))
		while(isdigit(s[++i] = c = getch()))
			;
	if(c == '.')
		while(isdigit(s[++i] = c = getch()))
			;
	s[i] = '\0';
	if(c != EOF)
		c = ungetchar;
	return NUMBER;
}

int getch(void)
{
	return (bufp > 0) ? buf[--bufp] : getchar();
}

/* NO LONGER NEEDED
void ungetch(int c)
{
	if(bufp >= BUFSIZE)
		printf("ungetch: too many characters\n");
	else
		buf[bufp++] = c;
}
*/

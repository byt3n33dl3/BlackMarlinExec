#include <stdio.h>

void doubleData( float x, float y);
void doubleDataByAddress( float *x, float *y);

main()
{

  float x = 10.0;
  float y = 5.0;

  printf("First Arg: %f\n", x);
  printf("Second Arg: %f\n", y);


  doubleData(x, y);

  printf("First Arg: %f\n", x);
  printf("Second Arg: %f\n", y);


  doubleDataByAddress(&x, &y);

  printf("First Arg: %f\n", x);
  printf("Second Arg: %f\n", y);

  return 0;

}

void doubleData( float x, float y)
{
  x *= 2.0;
  y *=  2.0;
  printf("First Arg: %f\n", x);
  printf("Second Arg: %f\n", y);
}

void doubleDataByAddress( float *x, float *y)
{
  *x *= 2.0;
  *y *=  2.0;
  printf("First Arg: %f\n", *x);
  printf("Second Arg: %f\n",* y);
}



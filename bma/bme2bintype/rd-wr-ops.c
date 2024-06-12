#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "rdwr.h"
void rd_inps() {
	
	int CR,enc,x0,y0,x1,y1;
	fn = "testfile";
		
	inptr = fopen(fn,"rb");
	printf("0x%x\n",inptr);
	
	if (inptr == 0) 
		printf("could open file for input\n");
	else
		num = fread(&CR,sizeof(CR),1,inptr);
		printf("number read %d \n",num);
		num = fread(&enc,sizeof(enc),1,inptr);
		printf("number read %d \n",num);
		num = fread(&x0,sizeof(x0),1,inptr);
		printf("number read %d \n",num);
		num = fread(&y0,sizeof(y0),1,inptr);
		printf("number read %d \n",num);
		num = fread(&x1,sizeof(x1),1,inptr);
		printf("number read %d \n",num);
		num = fread(&y1,sizeof(y1),1,inptr);
		printf("number read %d \n",num);

	fclose(inptr);
	printf("size of 0x%x %x \n",CR,sizeof(CR));
	printf("size of 0x%x %x \n",enc,sizeof(enc));
	printf("size of 0x%x %x \n",x0,sizeof(x0));
	printf("size of 0x%x %x \n",y0,sizeof(y0));
	printf("size of 0x%x %x \n",x1,sizeof(x1));
	printf("size of 0x%x %x \n",y1,sizeof(y1));
	//printf("%s\n",fn);
	
	
}
void wr_inps() {
	int CR,enc,x0,y0,x1,y1;
	enc = 1; 
	x0 = 0;
	y0 = 0;
	x1 = 2048;
	y1 = 2048;
	CR = 25;
 

	fn = "testfile";
	printf("size of 0x%x %x \n",CR,sizeof(CR));
	printf("size of 0x%x %x \n",enc,sizeof(enc));
	printf("size of 0x%x %x \n",x0,sizeof(x0));
	printf("size of 0x%x %x \n",y0,sizeof(y0));
	printf("size of 0x%x %x \n",x1,sizeof(x1));
	printf("size of 0x%x %x \n",y1,sizeof(y1));

	
	fn = "testfile";
		
	outptr = fopen(fn,"wb");
	printf("0x%x\n",outptr);
	
	if (outptr == 0) 
		printf("could open file for output\n");
	else
		num = fwrite(&CR,sizeof(CR),1,outptr);
		printf("number read %d \n",num);
		num = fwrite(&enc,sizeof(enc),1,outptr);
		printf("number read %d \n",num);
		num = fwrite(&x0,sizeof(x0),1,outptr);
		printf("number read %d \n",num);
		num = fwrite(&y0,sizeof(y0),1,outptr);
		printf("number read %d \n",num);
		num = fwrite(&x1,sizeof(x1),1,outptr);
		printf("number read %d \n",num);
		num = fwrite(&y1,sizeof(y1),1,outptr);
		printf("number read %d \n",num);

	fclose(outptr);


	
	
}

void main() {
	wr_inps();
	rd_inps();

}

/*
RaspBian
devel@mypi3-15:~/Ultibo_Projects/jpeg2000/src $ gcc rd-wr-ops.c -o tst
devel@mypi3-15:~/Ultibo_Projects/jpeg2000/src $ ./tst
size of 0x8 4 
size of 0x9 4 
size of 0xa 4 
size of 0xb 4 
0x6e1558
number read 1 
number read 1 
number read 1 
number read 1 
0x6e1558
number read 1 
number read 1 
number read 1 
number read 1 
size of 0x8 4 
size of 0x9 4 
size of 0xa 4 
size of 0xb 4 

devel@mypi3-15:~/Ultibo_Projects/jpeg2000/src $ hexedit testfile

00000000   08 00 00 00  09 00 00 00  0A 00 00 00  0B 00 00 00  ................
Ultibo
Only the first value appears to be read
xx0 8
var
xx0, yy0, xx1, yy1:LongWord;  
 Filename:='C:\testfile';
 try
  FileStream:=TFileStream.Create(Filename,fmOpenRead);  
  FileStream.Read(xx0,1);
  ConsoleWindowWriteLn(Handle, 'xx0 ' + intToStr(xx0));
  FileStream.Read(yy0,1);
  ConsoleWindowWriteLn(Handle, 'yy0 ' + intToStr(yy0));
  FileStream.Read(xx1,1);
  ConsoleWindowWriteLn(Handle, 'xx1 ' + intToStr(xx1));
  FileStream.Read(yy1,1);
  ConsoleWindowWriteLn(Handle, 'yy1 ' + intToStr(yy1));

  {FileStream.Read(decompstr,1);
  ConsoleWindowWriteLn(Handle, 'decomp file ' + decompstr); }


  FileStream.Free;

 finally
 end;
*/

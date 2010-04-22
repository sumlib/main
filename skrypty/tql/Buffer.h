#ifndef _BUFFER_
#define _BUFFER_


typedef struct{
  int cur, size;
  char *buf;
} _bufor;
typedef _bufor* bufor;

void resizeBuffer(bufor b);

void bufAppendS(bufor b, const char* s);
void bufAppendC(bufor b, const char c);
void bufAppendInt(bufor b, int i);

void bufReset(bufor b);
void bufClean(bufor b);


#endif 
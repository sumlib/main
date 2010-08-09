#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "Buffer.h"


#define BUFFER_INITIAL 200




void resizeBuffer(bufor b)
{
  char* temp = (char*) malloc(b->size * sizeof(char));
  if (!temp)
  {
    fprintf(stderr, "Error: Out of memory while attempting to grow buffer!\n");
    exit(1);
  }
  if (b->buf)
  {
    strncpy(temp, b->buf, b->size); /* peteg: strlcpy is safer, but not POSIX/ISO C. */
    free(b->buf);
  }
  b->buf = temp;
}


void bufAppendS(bufor b, const char* s)
{
  int len = strlen(s);
  int n;
  while (b->cur + len + 1 > b->size)
  {
    b->size *= 2; /* Double the buffer size */
    resizeBuffer(b);
  }
  for(n = 0; n < len; n++)
  {
    b->buf[b->cur + n] = s[n];
  }
  b->cur += len;
  b->buf[b->cur] = 0;
}
void bufAppendC(bufor b, const char c)
{
 if (b->cur == b->size)
  {
    b->size *= 2; /* Double the buffer size */
    resizeBuffer(b);
  }
  b->buf[b->cur] = c;
  b->cur++;
  b->buf[b->cur] = 0;
}

void bufAppendInt(bufor b, int i)
{
  char tmp[16];
  sprintf(tmp, "%d", i);
  bufAppendS(b, tmp);
}

void bufReset(bufor b)
{
  int i;
  b->cur = 0;
  b->size = BUFFER_INITIAL;
  b->buf = NULL;
  resizeBuffer(b);
   memset(b->buf, 0, b->size);
//   for(i=0;i<b->size;i++)
//     b->buf[i] = 0;
}

void bufClean(bufor b){
    b->cur = 0;
    memset(b->buf, 0, b->size);
}

char bufPop(bufor b){
    char c = b->buf[--b->cur];
    b->buf[b->cur] = 0;
    return c;
}
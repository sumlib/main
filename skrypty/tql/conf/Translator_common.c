#include "Translator_config.h"
#include "../Err.h"
#include "../Buffer.h"

#include <stdlib.h>
#include <string.h>

static char *fieldsNames[] = {"provenience", "publication", "period", "year", "genre", "code", "cdli_id", "text", "museum", "collection", NULL};

int fieldsCount(){
  int translator_count =0;
  if(!translator_count){
	for(;fieldsNames[translator_count]!=NULL;translator_count++);
        if(translator_count > MAX_POL)
            fatal("Update const MAX_POL to %d", translator_count);
  }
  return translator_count;
}
char *fieldName(int i){
  return fieldsNames[i];
}

char *concatenate(char *expr1, char *connector, char* expr2, int useBrackets){
  _bufor buffer;
  bufReset(&buffer);
  if(useBrackets)  bufAppendS(&buffer, "   (\n ");
  else bufAppendS(&buffer, "");
  bufAppendS(&buffer, expr1);
  bufAppendS(&buffer, connector);
  bufAppendS(&buffer, expr2);
  if(useBrackets) bufAppendS(&buffer, "   )\n");
  //fprintf(stderr, "bufor: %s\n", buffer);
  return strdup(buffer.buf);
}



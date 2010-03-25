#include "Translator_config.h"
#include <stdlib.h>

static char *fieldsNames[] = {"provenience", "publication", "period", "year", "genre", "code", "cdli_id", "text", "museum", "collection", NULL};

int translator_count =0;
int fieldsCount(){
  if(!translator_count){
	for(;fieldsNames[translator_count]!=NULL;translator_count++);
  }
  return translator_count;
}
char *fieldName(int i){
  return fieldsNames[i];
}




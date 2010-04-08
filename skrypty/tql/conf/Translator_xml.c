#include <stdlib.h>

#include "Translator_config.h"
#include "../Buffer.h"
#include "../Cexplode.h"


#define TEXT "??"
#define VAR "###"

static char *queries[] = {"fn:matches($tablet/provenience,'^###$')",
"fn:matches($tablet/publication,'^###$')", "fn:matches($tablet/period,'^###$')",
"fn:matches($tablet/date_of_origin,'^###$')",
"(fn:matches($tablet/genre,'^###$') or fn:matches($tablet/subgenre,'^###$'))",
"", "fn:matches($tablet/idCDLI,'^###$')", TEXT, "fn:matches($tablet/museum,'^###$')",
"fn:matches($tablet/collection,'^###$')", NULL};


bufor buf_result=NULL, buf_where=NULL;


void save_result(){
    if(buf_result==NULL)
        return;
    if(buf_where->cur>0){
        bufAppendS(buf_result, " where \n");
        bufAppendS(buf_result, buf_where->buf);
    }
    bufAppendS(buf_result, "return $tablet");
}


void translator_initSingleQuery(){
    if(!buf_result){
        buf_result = malloc(sizeof(_bufor));
        buf_where = malloc(sizeof(_bufor));
        bufReset(buf_result);
        bufReset(buf_where);
    }else{
        save_result();
        bufAppendS(buf_result, "\n,\n");
    }
    bufAppendS(buf_result, "for $tablet in //tablet\n");
    bufAppendS(buf_where, "");
}

char *translateTextQuery(char *text){
  _bufor tmp;
  int i;

  CexplodeStrings expString;
  if(0>Cexplode(text," ",&expString))
  {
      printf("CexplodeFailed!\n");
      return "";
  }

  bufReset(&tmp);
  bufAppendS(&tmp,"\n (some $edge0 in $tablet//edge satisfies (fn:matches($edge0,'^");
  bufAppendS(&tmp,expString.strings[0]);
  bufAppendS(&tmp,"$')");
  for (i = 1; i < expString.amnt; i++) {
  	bufAppendS(&tmp," and (some $edge");
	bufAppendInt(&tmp,i);
	bufAppendS(&tmp," in $tablet//edge[@node1=$edge");
	bufAppendInt(&tmp,i-1);
	bufAppendS(&tmp,"/@node2] satisfies (fn:matches($edge");
	bufAppendInt(&tmp,i);
	bufAppendS(&tmp,",'^");
        bufAppendS(&tmp,expString.strings[i]);
        bufAppendS(&tmp,"$')\n");
  }
    for (i = 0; i < expString.amnt; i++) {
        bufAppendS(&tmp, " ))\n");
   }

   return tmp.buf;
}

char *translator_simpleText(int i, char *text){
  static char buffer[4096];
  char *position, *tmp_format;
  const char* format = queries[i];
  int ile;
//   fprintf(stderr, "Format: %s\n", f);
  if(strcmp(format,TEXT) == 0) {
    return translateTextQuery(text);
  }

  tmp_format = strdup(format);
  if(!(position = strstr(tmp_format, VAR)))  // is VAR even in format?
    return tmp_format;
  strcpy(buffer, "( ");

 while(position){
    ile = strlen(buffer);
    strncat(buffer, tmp_format, position-tmp_format); // Copy characters from 'tmp_format' - from beginning to position of VAR
    buffer[ile + position-tmp_format] = '\0';
    sprintf(buffer+(ile+position-tmp_format), "%s", text);
    tmp_format = position+strlen(VAR);
    position = strstr(tmp_format, VAR);
  }
  strcat(buffer, tmp_format);
  strcat(buffer, " )");
  return strdup(buffer);
}

char *translator_or(int id, char *expr1, char *expr2){
    return concatenate(expr1, " or ", expr2, 1);
}

char *translator_and(int id, char *expr1, char *expr2){
    return concatenate(expr1, " and ", expr2, 0);
}

char *translator_not(int id, char *expr1){
    return concatenate("not (", expr1 , ")", 0);
}

char *translator_star(char *frag1, char *frag2){
    if (frag1 == NULL) frag1 = "";
    if (frag2 == NULL) frag2 = "";
    return concatenate(frag1, ".*", frag2, 0);
}

void translator_mergeLines(char *line, int id){

    if(buf_where->cur>0)
      bufAppendS(buf_where, "and\n");
    bufAppendS(buf_where, line);
    bufAppendS(buf_where, "\n");
 
}

char *translator_getResult(){
    save_result();
    if(buf_result!=NULL)
        return buf_result->buf;
    return "";
}

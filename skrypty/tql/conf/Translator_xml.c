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


bufor buf_result=NULL, buf_where=NULL, buf_seq_let=NULL, buf_seq_result=NULL;

int id_seq = 0;
//tego używamy, żeby id_seq było unikalne
#define ID_SEQ id_seq++


void save_result(){
    if(buf_result==NULL)
        return;
    if (buf_seq_let->cur>0)
        bufAppendS(buf_result, buf_seq_let->buf);
    if(buf_where->cur>0){
        bufAppendS(buf_result, "where \n");
        bufAppendS(buf_result, buf_where->buf);
    }
    bufAppendS(buf_result, "return <tablet>\n  {$tablet/idCDLI} \n");
    bufAppendS(buf_result, "  {$tablet/publication}\n  {$tablet/provenience}\n");
    bufAppendS(buf_result, "  {$tablet/period}\n  {$tablet/measurements}\n");
    bufAppendS(buf_result, "  {$tablet/genre}\n  {$tablet/subgenre}\n");
    bufAppendS(buf_result, "  {$tablet/collection}\n  {$tablet/museum}\n");
    bufAppendS(buf_result, "  {$tablet/text/show}\n  <seq>\n");
    if (buf_seq_result->cur>0)
        bufAppendS(buf_result, buf_seq_result->buf);
    bufAppendS(buf_result, "  </seq> \n</tablet>\n");
}


void translator_initSingleQuery(){
    if(!buf_result){
        buf_result = malloc(sizeof(_bufor));
        buf_where = malloc(sizeof(_bufor));
        buf_seq_result = malloc(sizeof(_bufor));
        buf_seq_let = malloc(sizeof(_bufor));
        bufReset(buf_result);
        bufReset(buf_where);
        bufReset(buf_seq_result);
        bufReset(buf_seq_let);

    }else{
        save_result();
        bufAppendS(buf_result, "\n,\n");
    }
    bufAppendS(buf_result, "for $tablet in //tablet\n");
    bufAppendS(buf_where, "");
    bufAppendS(buf_seq_result,"");
    bufAppendS(buf_seq_let,"");
}


char *escape(char *text) {
    //.()*^$
    _bufor *tmp;

    tmp = malloc(sizeof(_bufor));
    bufReset(tmp);


    int i;
    for (i=0;i<strlen(text);i++) {
        char c = text[i];
        if ((c == '.') && (text[i+1] != NULL) && (text[i+1] == '*')) {
            bufAppendS(tmp,".*");
            i++;
        }
        else {
          if (c == '.' || c == '(' || c == ')'
                || c == '*' || c == '^' || c == '$' ) {
            bufAppendS(tmp,"\\");
          }
          bufAppendC(tmp,c);
        }
    }

    return tmp->buf;
}

char *translateTextQuery(char *text){


  _bufor tmp2;
  int i;
  int seq=ID_SEQ;

  CexplodeStrings expString;
  if(0>Cexplode(text," ",&expString))
  {
      printf("CexplodeFailed!\n");
      return "";
  }

  bufAppendS(buf_seq_let,"let $seq");
  bufAppendInt(buf_seq_let,seq);
  bufAppendS(buf_seq_let," := (\n  for $edge_end in $tablet//edge\n");
  bufAppendS(buf_seq_let,"  for $edge_start in $tablet//edge\n  where\n");

  bufAppendS(buf_seq_let,"  (\n    fn:matches($edge_start,'^");
  bufAppendS(buf_seq_let,escape(expString.strings[0]));
  bufAppendS(buf_seq_let,"$')");

  if (expString.amnt > 1) {
    for (i = 1; i < expString.amnt - 1; i++) {
  	bufAppendS(buf_seq_let,"\n    and (some $edge");
	bufAppendInt(buf_seq_let,i);
	bufAppendS(buf_seq_let," in $tablet//edge[@node1=$edge");
        if ((i-1)==0)
            bufAppendS(buf_seq_let,"_start");
        else
            bufAppendInt(buf_seq_let,i-1);
	bufAppendS(buf_seq_let,"/@node2] satisfies (fn:matches($edge");
	bufAppendInt(buf_seq_let,i);
	bufAppendS(buf_seq_let,",'^");
        bufAppendS(buf_seq_let,escape(expString.strings[i]));
        bufAppendS(buf_seq_let,"$')\n");
    }

    bufAppendS(buf_seq_let,"    and (");
    bufAppendS(buf_seq_let,"$edge_end[@node1=$edge");
    if ((expString.amnt-2)==0)
        bufAppendS(buf_seq_let,"_start");
    else
        bufAppendInt(buf_seq_let,expString.amnt-2);
    bufAppendS(buf_seq_let, "/@node2] \n    and ");
    bufAppendS(buf_seq_let,"fn:matches($edge_end,'^");
    bufAppendS(buf_seq_let,escape(expString.strings[expString.amnt-1]));
    bufAppendS(buf_seq_let,"$'");

    for (i = 0; i < expString.amnt - 1; i++) {
        bufAppendS(buf_seq_let, "))");
    }

    bufAppendS(buf_seq_let,"\n  )\n");

  }
  else {
      bufAppendS(buf_seq_let,"\n    and $edge_start = $edge_end\n  )\n");
  }

  bufAppendS(buf_seq_let,"  return <seq");
  bufAppendInt(buf_seq_let,seq);
  bufAppendS(buf_seq_let,"> {$edge_start/@node1} {$edge_end/@node2} </seq");
  bufAppendInt(buf_seq_let,seq);
  bufAppendS(buf_seq_let,">\n)\n");


  bufAppendS(buf_seq_result,"    {$seq");
  bufAppendInt(buf_seq_result,seq);
  bufAppendS(buf_seq_result,"}\n");


  bufReset(&tmp2);

  bufAppendS(&tmp2,"    $seq");
  bufAppendInt(&tmp2,seq);
  bufAppendS(&tmp2,"\n");


  return tmp2.buf;
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
  strcpy(buffer, "(");

 while(position){
    ile = strlen(buffer);
    strncat(buffer, tmp_format, position-tmp_format); // Copy characters from 'tmp_format' - from beginning to position of VAR
    buffer[ile + position-tmp_format] = '\0';
    sprintf(buffer+(ile+position-tmp_format), "%s", escape(text));
    tmp_format = position+strlen(VAR);
    position = strstr(tmp_format, VAR);
  }
  strcat(buffer, tmp_format);
  strcat(buffer, ")");
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
    bufAppendS(buf_where, "  ");
    bufAppendS(buf_where, line);
    bufAppendS(buf_where, "\n");
 
}

char *translator_getResult(){
    save_result();
    if(buf_result!=NULL)
        return buf_result->buf;
    return "";
}

#include "Translator_config.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "../Cexplode.h"
#include "../Buffer.h"

#define TEXT "??"
//id_seq - id seqencji odczytów/klinów po której wyszukujemy
#define PUT_HERE_ID_SEQ "##"
#define VAR "###"


static char *fieldsNames[] = { "provenience", "publication", "period", "year", "genre", "code", "cdli_id", "text", "museum", "collection", NULL};
static char *queries[] = {"p.value LIKE '###'", "t.publication LIKE '###'", "pd.value LIKE '###'", "t.date_of_origin LIKE '###'", "g1.value LIKE '###' OR g2.value LIKE '###'", "", "t.cdli_id LIKE '###'", TEXT, "t.museum LIKE '###'", "c.value LIKE '###'", NULL};
int from_level=0, select_level=0;

/************************************ buffory: *****************************************************/
bufor buf_select=NULL, buf_from=NULL, buf_where=NULL, buf_result=NULL;

int id_seq = 0;
//tego używamy, żeby id_seq było unikalne
#define ID_SEQ id_seq++



void save_result(){
    bufAppendS(buf_result, buf_select->buf);
    bufAppendS(buf_result, "\n");
    bufAppendS(buf_result, buf_from->buf);
    if(buf_where->cur>0){
        bufAppendS(buf_result, " WHERE \n");
        bufAppendS(buf_result, buf_where->buf);
    }
}



/******************************* treść właściwa *********************************************/
void translator_initSingleQuery(){
    if(buf_select && buf_from && buf_where && buf_result){
	save_result();
	bufAppendS(buf_result, "\n  UNION\n");
//	printf("INIT:\n%s\n", buf_wynik->buf);
    }else{
	buf_select = malloc(sizeof(_bufor));
	buf_from = malloc(sizeof(_bufor));
	buf_where = malloc(sizeof(_bufor));
	buf_result = malloc(sizeof(_bufor));
	bufReset(buf_result);
    }
    bufReset(buf_select);
    bufReset(buf_from);
    bufReset(buf_where);
    bufAppendS(buf_select, "SELECT t.id, t.id_cdli, t.publication, t.measurements, t.date_of_origin, p.value as provenience, pd.value as period, g1.value as genre, g2.value as subgenre, c.value as collection, t.museum, t.show_text");
    bufAppendS(buf_from, "FROM tablet t \n LEFT JOIN provenience p ON p.id=t.provenience_id\n LEFT JOIN collection c ON c.id=t.collection_id\n LEFT JOIN genre g1 ON g1.id=t.genre_id\n LEFT JOIN genre g2 ON g2.id = t.subgenre_id\n LEFT JOIN period pd ON pd.id = t.period_id \n");
    bufAppendS(buf_where, "");
}


int count =0;
int fieldsCount(){
  if(!count){
	for(;fieldsNames[count]!=NULL;count++);
  }
  return count;
}
char *fieldName(int i){
  return fieldsNames[i];
}

char *translateTextQuery(int id, char *text){
  _bufor tmp;
  int i;

  CexplodeStrings expString;
  if(0>Cexplode(text," ",&expString))
  {
      printf("CexplodeFailed!\n");
      return "";
  }
  
  bufReset(&tmp);
  bufAppendS(&tmp,"       (\n         SELECT id_tab, CAST(array_accum(nodes) as TEXT) as nodes, COUNT(DISTINCT id_seq) AS seq, ");
  bufAppendInt(&tmp,ID_SEQ);
  bufAppendS(&tmp," AS id_seq \n         FROM (\n            SELECT \n               r1.node1_id % 1000000 AS id_tab, \n               '{' || r1.node1_id || ',' || r");
  bufAppendInt(&tmp,expString.amnt);
  bufAppendS(&tmp,".node2_id || '}'AS nodes, \n               1 AS id_seq\n            FROM \n               reading r1 \n");
  for (i = 1; i < expString.amnt; i++) {
	bufAppendS(&tmp,"               LEFT JOIN reading r");
	bufAppendInt(&tmp,i+1);
	bufAppendS(&tmp," ON (r");
	bufAppendInt(&tmp,i);
	bufAppendS(&tmp,".node2_id = r");
	bufAppendInt(&tmp,i+1);
	bufAppendS(&tmp,".node1_id) \n");
  }
  bufAppendS(&tmp,"            WHERE\n               (\n");
   
  for (i = 0; i < expString.amnt; i++) {
	if (i>0) bufAppendS(&tmp, "               AND\n");
	bufAppendS(&tmp,"               r");
	bufAppendInt(&tmp,i+1);
	bufAppendS(&tmp,".value LIKE '");
	bufAppendS(&tmp, expString.strings[i]);
	bufAppendS(&tmp, "'\n");
   }
   bufAppendS(&tmp, "               )\n         ) AS a GROUP BY id_tab\n       ) \n");
   return tmp.buf;
}

char *translator_simpleText(int i, char *text){
  static char buffer[4096];
  char *position, *tmp_format;
  const char* format = queries[i];
  int ile;
//   fprintf(stderr, "Format: %s\n", f);
  if(strcmp(format,TEXT) == 0) {
    return translateTextQuery(i, text);
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


//wygląda na to, że tego nie używamy, ale może się przydać
char *replace(const char *text, char * co_zamienic, char * na_co){
  static char buffer[4096];
  char *position, *tmp_text;

  int count;
  
  tmp_text = strdup(text);
  if(!(position = strstr(tmp_text, co_zamienic)))  // is VAR even in format?
    return tmp_text;

 while(position){
    count = strlen(buffer);
    strncat(buffer, tmp_text, position-tmp_text); // Copy characters buf_from 'str' start to 'orig' st$
    buffer[count + position-tmp_text] = '\0';
    sprintf(buffer+(count+position-tmp_text), "%s", na_co);
    tmp_text = position+strlen(co_zamienic);
    position = strstr(tmp_text,co_zamienic);
  }
  strcat(buffer, tmp_text);
  return strdup(buffer);
}


char *add_id_seq(const char *text){
  static char buffer[4096];
  char *p, *tmp;
  memset(buffer, 0, 4096);
  int ile;
  
  tmp = strdup(text);
  if(!(p = strstr(tmp, PUT_HERE_ID_SEQ)))  // Is 'orig' even in 'str'?
    return tmp;


 while(p){
    ile = strlen(buffer);
    strncat(buffer, tmp, p-tmp); // Copy characters buf_from 'str' start to 'orig' st$
    buffer[ile + p-tmp] = '\0';
    sprintf(buffer+(ile+p-tmp), "%d", ID_SEQ);
    tmp = p+strlen(PUT_HERE_ID_SEQ);
    p = strstr(tmp,PUT_HERE_ID_SEQ);
  }
  strcat(buffer, tmp);
  return strdup(buffer);
}

char *concat(char *expr1, char *connector, char* expr2, int useBrackets){
  _bufor buffer;
  bufReset(&buffer);
  if(useBrackets)  bufAppendS(&buffer, "   (\n ");
  else bufAppendS(&buffer, "");
  bufAppendS(&buffer, add_id_seq(expr1));
  bufAppendS(&buffer, connector);
  bufAppendS(&buffer, expr2);
  if(useBrackets) bufAppendS(&buffer, "   )\n");
  //fprintf(stderr, "bufor: %s\n", buffer);
  return strdup(buffer.buf);
}
char *translator_or(int id, char *expr1, char *expr2) {
  if (strcmp(queries[id],TEXT) == 0) {
      return concat("\n   (\nSELECT id_tab, CAST(array_accum(nodes) as TEXT) as nodes, COUNT(DISTINCT id_seq) as seq, ## as id_seq\n FROM\n",
		      concat(expr1, "   UNION \n", expr2, 1),
		      "  as c \n GROUP BY id_tab\n   )\n", 0);
  }
  return concat(expr1, " OR ", expr2, 1);
}
  
  
char *translator_and(int id, char *expr1, char *expr2) {
  if (strcmp(queries[id],TEXT) == 0) {
      return concat("\n   (\nSELECT * FROM\n   (\nSELECT id_tab, CAST(array_accum(nodes) as TEXT) as nodes, COUNT(DISTINCT id_seq) as seq, ## as id_seq\n FROM\n",
		      concat(expr1, "   UNION \n", expr2, 1),
		      "  as c \n GROUP BY id_tab\n   ) as b\nWHERE b.seq=2\n   )", 0);
  }
  return concat(expr1, " AND ", expr2, 1);
}

char *translator_not(int id, char *expr1)  {
  if (strcmp(queries[id],TEXT) == 0) {
      return concat("\nSELECT id_tab, '' as nodes, 0 as seq, ## as id_seq\nFROM\n   (\n     (select id as id_tab from tablet)\n   EXCEPT\n     (SELECT id_tab from\n", expr1, " as a\n     )\n   ) as b\n", 1);
  }
  return concat("", "NOT ", expr1, 1);
}

char *translator_star(char *frag1, char *frag2)  {
  if(frag1==NULL) frag1 = "";
  if(frag2==NULL) frag2 = "";
  
 return concat(frag1, "%", frag2, 0);
}

void translator_mergeLines(char *line, int id){
  if(strcmp(queries[id],TEXT) == 0) {
    bufAppendS(buf_from, " INNER JOIN ");
    bufAppendS(buf_from, line);
    bufAppendS(buf_from, " AS sequence ON sequence.id_tab = t.id\n");
    bufAppendS(buf_select, ", sequence.nodes as nodes");
    
  }
  else {
    if(buf_where->cur>0)
      bufAppendS(buf_where, "AND\n");
    bufAppendS(buf_where, line);
    bufAppendS(buf_where, "\n");
  }
}

char *translator_getResult(){
    save_result();
    return buf_result->buf;
}

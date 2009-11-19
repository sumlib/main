#include "Translator_config.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "../Cexplode.h"
#include "../Buffer.h"

#define TEXT "??"
//id_seq - id sekwencji odczytów/klinów po której wyszukujemy
#define PUT_HERE_ID_SEQ "##"
#define VAR "###"


static char *fieldsNames[] = { "provenience", "publication", "period", "year", "genre", "code", "cdli_id", "text", "seal", NULL};
static char *queries[] = {"p.wartosc LIKE '###'", "t.publikacja LIKE '###'", "o.wartosc LIKE '###'", "t.data_powstania LIKE '###'", "typ1.wartosc LIKE '###' OR typ2.wartosc LIKE '###'", "", "t.cdli_id LIKE '###'", TEXT, "", NULL};
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
    bufAppendS(buf_result, buf_where->buf);
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
    bufAppendS(buf_select, "SELECT t.id, t.id_cdli, t.publikacja, t.rozmiary, t.data_powstania, p.wartosc, o.wartosc as okres, typ1.wartosc as typ, typ2.wartosc as podtyp, k.wartosc as kolekcja, t.tekst");
    bufAppendS(buf_from, "FROM tabliczka t \n LEFT JOIN prowiniencja p ON p.id=t.prowiniencja_id\n LEFT JOIN kolekcja k ON k.id=t.kolekcja_id\n LEFT JOIN typ typ1 ON typ1.id=t.typ_id\n LEFT JOIN typ typ2 ON typ2.id = t.podtyp_id\n LEFT JOIN okres o ON o.id = t.okres_id \n");
    bufAppendS(buf_where, "WHERE \n  ");
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
  bufAppendS(&tmp,"       (\n         SELECT id_tab, CAST(array_accum(wezly) as TEXT) as wezly, COUNT(DISTINCT id_sekw) AS sekw, ");
  bufAppendInt(&tmp,ID_SEQ);
  bufAppendS(&tmp," AS id_sekw \n         FROM (\n            SELECT \n               o1.wezel1_id % 1000000 AS id_tab, \n               '{' || o1.wezel1_id || ',' || o");
  bufAppendInt(&tmp,expString.amnt);
  bufAppendS(&tmp,".wezel2_id || '}'AS wezly, \n               1 AS id_sekw\n            FROM \n               odczyty o1 \n");
  for (i = 1; i < expString.amnt; i++) {
	bufAppendS(&tmp,"               LEFT JOIN odczyty o");
	bufAppendInt(&tmp,i+1);
	bufAppendS(&tmp," ON (o");
	bufAppendInt(&tmp,i);
	bufAppendS(&tmp,".wezel2_id = o");
	bufAppendInt(&tmp,i+1);
	bufAppendS(&tmp,".wezel1_id) \n");
  }
  bufAppendS(&tmp,"            WHERE\n               (\n");
   
  for (i = 0; i < expString.amnt; i++) {
	if (i>0) bufAppendS(&tmp, "               AND\n");
	bufAppendS(&tmp,"               o");
	bufAppendInt(&tmp,i+1);
	bufAppendS(&tmp,".wartosc LIKE '");
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


char *add_id_seq(const char *tekst){
  static char buffer[4096];
  char *p, *tmp;
  memset(buffer, 0, 4096);
  int ile;
  
  tmp = strdup(tekst);
  if(!(p = strstr(tmp, PUT_HERE_ID_SEQ)))  // Is 'orig' even in 'str'?
    return tmp;


 while(p){
    ile = strlen(buffer);
    strncat(buffer, tmp, p-tmp); // Copy characters buf_from 'str' start to 'orig' st$
//     fprintf(stderr, "początek: %s\n", buffer);
    buffer[ile + p-tmp] = '\0';
//     strcat(buffer, tekst);
    sprintf(buffer+(ile+p-tmp), "%d", ID_SEQ);
//     fprintf(stderr, "po dodaniu tekstu: %s\n", buffer);
    tmp = p+strlen(PUT_HERE_ID_SEQ);
    p = strstr(tmp,PUT_HERE_ID_SEQ);
  }
  strcat(buffer, tmp);
//   fprintf(stderr, "koniec: %s\n", buffer);
//   bufAppendS(buf_where, buffer);
  return strdup(buffer);
}

char *polacz(char *wyr1, char *lacznik, char* wyr2, int nawiasy){
  _bufor buffer;
  bufReset(&buffer);
  if(nawiasy)  bufAppendS(&buffer, "   (\n ");
  else bufAppendS(&buffer, "");
  bufAppendS(&buffer, add_id_seq(wyr1));
  bufAppendS(&buffer, lacznik);
  bufAppendS(&buffer, wyr2);
  if(nawiasy) bufAppendS(&buffer, "   )\n");
  //fprintf(stderr, "bufor: %s\n", buffer);
  return strdup(buffer.buf);
}
char *translator_or(int id, char *wyr1, char *wyr2) {
  if (strcmp(queries[id],TEXT) == 0) {
      return polacz("\n   (\nSELECT id_tab, CAST(array_accum(wezly) as TEXT) as wezly, COUNT(DISTINCT id_sekw) as sekw, ## as id_sekw\n FROM\n", 
		      polacz(wyr1, "   UNION \n", wyr2, 1), 
		      "  as c \n GROUP BY id_tab\n   )\n", 0);
  }
  return polacz(wyr1, " OR ", wyr2, 1);
}
  
  
char *translator_and(int id, char *wyr1, char *wyr2) {
  if (strcmp(queries[id],TEXT) == 0) {
      return polacz("\n   (\nSELECT * FROM\n   (\nSELECT id_tab, CAST(array_accum(wezly) as TEXT) as wezly, COUNT(DISTINCT id_sekw) as sekw, ## as id_sekw\n FROM\n", 
		      polacz(wyr1, "   UNION \n", wyr2, 1), 
		      "  as c \n GROUP BY id_tab\n   ) as b\nWHERE b.sekw=2\n   )", 0);
  }
  return polacz(wyr1, " AND ", wyr2, 1);
}

char *translator_not(int id, char *wyr1)  {
  if (strcmp(queries[id],TEXT) == 0) {
      return polacz("\nSELECT id_tab, '' as wezly, 0 as sekw, ## as id_sekw\nFROM\n   (\n     (select id as id_tab from tabliczka)\n   EXCEPT\n     (SELECT id_tab from\n", wyr1, " as a\n     )\n   ) as b\n", 1);
  }
  return polacz("", "NOT ", wyr1, 1);
}

char *translator_star(char *frag1, char *frag2)  {
  if(frag1==NULL) frag1 = "";
  if(frag2==NULL) frag2 = "";
  
 return polacz(frag1, "%", frag2, 0);
}

void translator_mergeLines(char *line, int id, int notFirstLine){
  if(strcmp(queries[id],TEXT) == 0) {
    bufAppendS(buf_from, " INNER JOIN ");
    bufAppendS(buf_from, line);
    bufAppendS(buf_from, " AS sekwencja ON sekwencja.id_tab = t.id\n");
    bufAppendS(buf_select, ", sekwencja.wezly as wezly");
    
  }
  else {
    if(notFirstLine)
      bufAppendS(buf_where, "AND\n");
      bufAppendS(buf_where, line);
      bufAppendS(buf_where, "\n");
  }
}

char *translator_getResult(){
    save_result();
    return buf_result->buf;
}

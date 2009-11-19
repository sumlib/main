#ifndef SYMBOLS_HEADER_FILE
#define SYMBOLS_HEADER_FILE
#include "Absyn.h"
/* plik definiujący tablicę symboli */
void symbols_init();
int symbols_getId(char* name);
char* symbols_getName(int id);
Zapytanie symbols_getQuery(int id);
void symbols_setQuery(int id, Zapytanie zapyt);
int symbols_isFieldName(Ident i);
int symbols_toFieldId(Ident id);
#endif
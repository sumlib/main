#ifndef SYMBOLS_HEADER_FILE
#define SYMBOLS_HEADER_FILE
#include "Absyn.h"
/* plik definiujący tablicę symboli */
void symbols_init();
int symbols_get_id(char* name);
char* symbols_get_name(int id);
Zapytanie symbols_get_zapyt(int id);
void symbols_set_zapyt(int id, Zapytanie zapyt);
int symbols_is_NazwaPola(Ident i);
int symbols_to_NazwaPola_id(Ident id);
#endif
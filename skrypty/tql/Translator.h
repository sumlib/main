#ifndef TRANSLATOR_HEADER
#define TRANSLATOR_HEADER

#include "Absyn.h"

/* Certain applications may improve performance by changing the buffer size */
#define BUFFER_INITIAL 2000
/* You may wish to change _L_PAREN or _R_PAREN */
#define _L_PAREN '('
#define _R_PAREN ')'

/* The following are simple heuristics for rendering terminals */
/* You may wish to change them */
void renderCC(Char c);
void renderCS(String s);
void indent(void);
void backup(void);


char* translateZapZloz(ZapZloz p);

void ppZapZloz(ZapZloz p, int i);
void ppZapytanie(Zapytanie p, int i);
char* ppLiniaZapytania(LiniaZapytania p, int i);
char* ppWyraz(Wyraz p, Ident id, int i);
void ppListZapytanie(ListZapytanie p, int i);
void ppListLiniaZapytania(ListLiniaZapytania p, int i);
void ppPrzerwa(Przerwa p, int i);
char* ppTekst(Tekst p);
void ppNazwa(Nazwa p, int i);


#endif


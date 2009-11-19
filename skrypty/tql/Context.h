#ifndef SKELETON_HEADER
#define SKELETON_HEADER
/* You might want to change the above name. */

#include "Absyn.h"


void contextZapZloz(ComplexQuery p);
void contextZapytanie(Query p);
void contextLiniaZapytania(QueryLine p);
void contextWyraz(Expr p);
void contextListZapytanie(QueryList p);
void contextListLiniaZapytania(QueryLineList p);
void contextPrzerwa(Przerwa p);
void contextListPrzerwa(SpaceList p);
void contextTekst(Text p);
void contextNazwa(Name p);

void contextMytoken(MyToken p);
void contextIdent(Ident i);
void contextNazwaPola(Ident i);
void contextInteger(Integer i);
void contextDouble(Double d);
void contextChar(Char c);
void contextString(String s);

#endif


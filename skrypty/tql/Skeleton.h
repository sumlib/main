#ifndef SKELETON_HEADER
#define SKELETON_HEADER
/* You might want to change the above name. */

#include "Absyn.h"


void visitZapZloz(ZapZloz p);
void visitZapytanie(Zapytanie p);
void visitLiniaZapytania(LiniaZapytania p);
void visitWyraz(Wyraz p);
void visitListZapytanie(ListZapytanie p);
void visitListLiniaZapytania(ListLiniaZapytania p);
void visitPrzerwa(Przerwa p);
void visitListPrzerwa(ListPrzerwa p);
void visitTekst(Tekst p);
void visitNazwa(Nazwa p);

void visitMytoken(MyToken p);
void visitIdent(Ident i);
void visitNazwaPola(Ident i);
void visitInteger(Integer i);
void visitDouble(Double d);
void visitChar(Char c);
void visitString(String s);

#endif


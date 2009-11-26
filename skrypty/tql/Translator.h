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


char* translateZapZloz(ComplexQuery p);

void ppZapZloz(ComplexQuery p, int i);
void ppQuery(Query p, int i);
char* ppQueryLine(QueryLine p, int i);
char* ppExpr(Expr p, Ident id, int i);
void ppQueryList(QueryList p, int i);
void ppQueryLineList(QueryLineList p, int i);
void ppPrzerwa(Przerwa p, int i);
char* ppText(Text p);
void ppNazwa(Name p, int i);


#endif


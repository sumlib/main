#ifndef SKELETON_HEADER
#define SKELETON_HEADER
/* You might want to change the above name. */

#include "Absyn.h"


void visitZapZloz(ZapZloz p);
void visitQuery(Query p);
void visitQueryLine(QueryLine p);
void visitExpr(Expr p);
void visitQueryList(QueryList p);
void visitQueryLineList(QueryLineList p);
void visitPrzerwa(Przerwa p);
void visitListPrzerwa(ListPrzerwa p);
void visitText(Text p);
void visitNazwa(Nazwa p);

void visitMytoken(MyToken p);
void visitIdent(Ident i);
void visitFieldName(Ident i);
void visitInteger(Integer i);
void visitDouble(Double d);
void visitChar(Char c);
void visitString(String s);

#endif


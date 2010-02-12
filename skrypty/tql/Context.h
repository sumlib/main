#ifndef SKELETON_HEADER
#define SKELETON_HEADER
/* You might want to change the above name. */

#include "Absyn.h"


void contextComplexQuery(ComplexQuery p);
void contextQuery(Query p);
void contextQueryLine(QueryLine p);
void contextExpr(Expr p);
void contextQueryList(QueryList p);
void contextQueryLineList(QueryLineList p);
//void contextPrzerwa(Przerwa p);
//void contextListPrzerwa(SpaceList p);
void contextText(Text p);
void contextName(Name p);

void contextMytoken(MyToken p);
void contextIdent(Ident i);
void contextFieldName(Ident i);
void contextInteger(Integer i);
void contextDouble(Double d);
void contextChar(Char c);
void contextString(String s);

#endif


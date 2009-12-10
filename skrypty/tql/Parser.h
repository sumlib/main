#ifndef PARSER_HEADER_FILE
#define PARSER_HEADER_FILE

#include "Absyn.h"
#include "Symbols.h"

typedef union
{
  int int_;
  char char_;
  double double_;
  int string_;
  ComplexQuery zapzloz_;
  Query zapytanie_;
  QueryLine liniazapytania_;
  Expr wyraz_;
  QueryList querylist_;
  QueryLineList querylinelist_;
  int przerwa_;
  SpaceList listprzerwa_;
  Text tekst_;
  Name nazwa_;
} YYSTYPE;

#define _ERROR_ 258
#define _SYMB_NEWLINE 259
#define _SYMB_DWUKROPEK 260
#define _SYMB_AND 261
#define _SYMB_OR 262
#define _SYMB_NOT 263
#define _SYMB_ALL 264
#define _SYMB_LEWIAS 265
#define _SYMB_PRAWIAS 266
#define _SYMB_AS 267
#define _SYMB_DEFINE 268
#define _SYMB_DWUKROPEK0 269
#define _SYMB_DWUKROPEK1 270
#define _SYMB_DWUKROPEK2 271
#define _STRING_ 272
#define _IDENT_ 273

extern YYSTYPE yylval;
extern int yyline;
ComplexQuery pZapZloz(FILE *inp);
Query pQuery(FILE *inp);
QueryLine pQueryLine(FILE *inp);
Expr pExpr(FILE *inp);
QueryList pQueryList(FILE *inp);
QueryLineList pQueryLineList(FILE *inp);
int pPrzerwa(FILE *inp);
SpaceList pListPrzerwa(FILE *inp);
Text pText(FILE *inp);
Name pNazwa(FILE *inp);


#endif

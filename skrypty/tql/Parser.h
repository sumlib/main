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
  ComplexQuery complexquery_;
  Query query_;
  QueryLine queryline_;
  Expr expr_;
  QueryList querylist_;
  QueryLineList querylinelist_;
  int space_;
  SpaceList spacelist_;
  Text text_;
  Name name_;
} YYSTYPE;

#define _ERROR_ 258
#define _SYMB_NEWLINE 259
#define _SYMB_COLON 260
#define _SYMB_AND 261
#define _SYMB_OR 262
#define _SYMB_NOT 263
#define _SYMB_STAR 264
#define _SYMB_LBRACKET 265
#define _SYMB_RBRACKET 266
#define _SYMB_AS 267
#define _SYMB_DEFINE 268
#define _SYMB_IN 269
#define _SYMB_SEARCH 270
#define _SYMB_DIGIT_IDENT 271
#define _STRING_ 272
#define _IDENT_ 273

extern YYSTYPE yylval;
extern int yyline;
ComplexQuery pComplexQuery(FILE *inp);
Query pQuery(FILE *inp);
QueryLine pQueryLine(FILE *inp);
Expr pExpr(FILE *inp);
QueryList pQueryList(FILE *inp);
QueryLineList pQueryLineList(FILE *inp);
int pSpace(FILE *inp);
SpaceList pSpaceList(FILE *inp);
Text pText(FILE *inp);
Name pName(FILE *inp);


#endif

/*** BNFC-Generated Visitor Traversal Skeleton. ***/
/* This traverses the abstract syntax tree.
   To use, copy Skeleton.h and Skeleton.c to
   new files. */

#include <stdio.h>
#include <stdlib.h>
#include "Skeleton.h"
#include "symbols.h"

void visitZapZloz(ZapZloz _p_)
{
    visitQueryList(_p_->querylist_);
}

void visitQuery(Query _p_)
{
  switch(_p_->kind)
  {
  case is_SingleQuery:
    /* Code for SingleQuery Goes Here */
    break;
  case is_DefQuery:
    /* Code for DefQuery Goes Here */
    visitQuery(_p_->u.zapdef_.zapytanie_);
    visitNazwa(_p_->u.zapdef_.nazwa_);
    break;
  case is_CallQuery:
    /* Code for CallQuery Goes Here */
    visitQuery(_p_->u.zapwyw_.zapytanie_);
    visitNazwa(_p_->u.zapwyw_.nazwa_);
    break;
  case is_EmptyQuery:
    /* Code for EmptyQuery Goes Here */
    break;

  default:
    fprintf(stderr, "Error: bad kind field when printing Query!\n");
    exit(1);
  }
}

void visitQueryLine(QueryLine _p_)
{

    /* Code for LiniaZap Goes Here */
    visitFieldName(_p_->ident_);
    visitExpr(_p_->wyraz_);

}

void visitExpr(Expr _p_)
{
  switch(_p_->kind)
  {
  case is_AndExpr:
    /* Code for AndExpr Goes Here */
    visitExpr(_p_->u.wyrazand_.wyraz_1);
    visitExpr(_p_->u.wyrazand_.wyraz_2);
    break;
  case is_OrExpr:
    /* Code for OrExpr Goes Here */
    visitExpr(_p_->u.wyrazor_.wyraz_1);
    visitExpr(_p_->u.wyrazor_.wyraz_2);
    break;
  case is_NotExpr:
    /* Code for NotExpr Goes Here */
    visitExpr(_p_->u.wyrazneg_.wyraz_);
    break;
  case is_PartExpr:
    /* Code for PartExpr Goes Here */
    visitText(_p_->u.wyrazfrag_.tekst_1);
    visitText(_p_->u.wyrazfrag_.tekst_2);
    break;
  case is_LPartExpr:
    /* Code for LPartExpr Goes Here */
    visitText(_p_->u.wyrazfragl_.tekst_);
    break;
  case is_RPartExpr:
    /* Code for RPartExpr Goes Here */
    visitText(_p_->u.wyrazfragp_.tekst_);
    break;
  case is_TextExpr:
    /* Code for TextExpr Goes Here */
    visitText(_p_->u.wyraztekst_.tekst_);
    break;

  default:
    fprintf(stderr, "Error: bad kind field when printing Expr!\n");
    exit(1);
  }
}

void visitQueryList(QueryList querylist)
{
  while(querylist != 0)
  {
    /* Code For QueryList Goes Here */
    visitQuery(querylist->zapytanie_);
    querylist = querylist->querylist_;
  }
}

void visitQueryLineList(QueryLineList querylinelist)
{
  while(querylinelist != 0)
  {
    /* Code For QueryLineList Goes Here */
    visitQueryLine(querylinelist->liniazapytania_);
    querylinelist = querylinelist->querylinelist_;
  }
}

void visitText(Text _p_)
{

}

void visitNazwa(Nazwa _p_)
{

}

void visitMytoken(MyToken p)
{
  /* Code for MyToken Goes Here */
}
void visitIdent(Ident i)
{
  /* Code for Ident Goes Here */
}

void visitFieldName(Ident i)
{
  if(symbols_is_FieldName(i)) fprintf(stderr, "Error: %s nie jest nazwą pola\n", symbols_get_name(i));
}

void visitInteger(Integer i)
{
  /* Code for Integer Goes Here */
}
void visitDouble(Double d)
{
  /* Code for Double Goes Here */
}
void visitChar(Char c)
{
  /* Code for Char Goes Here */
}
void visitString(String s)
{
  /* Code for String Goes Here */
}


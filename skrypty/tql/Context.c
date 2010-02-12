/*** BNFC-Generated contextor Traversal Skeleton. ***/
/* This traverses the abstract syntax tree.
   To use, copy Skeleton.h and Skeleton.c to
   new files. */

#include <stdio.h>
#include <stdlib.h>
#include "Context.h"
#include "Symbols.h"
#include "Absyn.h"

void contextComplexQuery(ComplexQuery _p_)
{
  contextQueryList(_p_->querylist_);
}

Query merge_queries(Query z1, Query z2){
    Query z = malloc(sizeof(struct Query_));
    int i;
    Expr w;
    if(z1->kind == is_SingleQuery && z2->kind == is_SingleQuery){
        for(i=0;i<fieldsCount();i++){
	  if(z2->u.simplequery_.tabqueryline_[i]!=NULL){
    		w = z2->u.simplequery_.tabqueryline_[i]->expr_;
		if(z1->u.simplequery_.tabqueryline_[i]==NULL)
		    z->u.simplequery_.tabqueryline_[i] = make_QueryLine(z2->u.simplequery_.tabqueryline_[i]->ident_, w);
		else{
		    z->u.simplequery_.tabqueryline_[i] = make_QueryLine(z2->u.simplequery_.tabqueryline_[i]->ident_, make_AndExpr(w, z1->u.simplequery_.tabqueryline_[i]->expr_));
		}
	  }else
	    z->u.simplequery_.tabqueryline_[i] = z1->u.simplequery_.tabqueryline_[i];
	}
	return z;
    }
    return NULL;
}

void contextQuery(Query _p_)
{
  Query zapyt;
  int i;
  switch(_p_->kind)
  {
  case is_SingleQuery:
    /* Code for SingleQuery Goes Here */
    break;
  case is_DefQuery:
    /* Code for DefQuery Goes Here */
    contextQuery(_p_->u.defquery_.query_);
    contextName(_p_->u.defquery_.name_);
    symbols_setQuery(_p_->u.defquery_.name_, _p_->u.defquery_.query_);
    break;
  case is_CallQuery:
    /* Code for CallQuery Goes Here */
    //TODO: Połączyć linie zapytania z zap_def
    contextQuery(_p_->u.callquery_.query_);
    contextName(_p_->u.callquery_.name_);
    zapyt = symbols_getQuery(_p_->u.callquery_.name_);
    if(zapyt==NULL){
	//TODO: komunikat
	exit(1);
    }
    //TODO: zdefiniować funkcję
    zapyt = merge_queries(_p_->u.callquery_.query_, zapyt);
    if(zapyt)
      _p_->u.callquery_.query_ = zapyt;
    break;
  case is_EmptyQuery:
    /* Code for EmptyQuery Goes Here */
    break;

  default:
    fprintf(stderr, "Error: bad kind field when printing Query!\n");
    exit(1);
  }
}

void contextQueryLine(QueryLine _p_)
{

    /* Code for LiniaZap Goes Here */
    contextFieldName(_p_->ident_);
    contextExpr(_p_->expr_);

}

void contextExpr(Expr _p_)
{
  switch(_p_->kind)
  {
  case is_AndExpr:
    /* Code for AndExpr Goes Here */
    contextExpr(_p_->u.andexpr_.expr_1);
    contextExpr(_p_->u.andexpr_.expr_2);
    break;
  case is_OrExpr:
    /* Code for OrExpr Goes Here */
    contextExpr(_p_->u.orexpr_.expr_1);
    contextExpr(_p_->u.orexpr_.expr_2);
    break;
  case is_NotExpr:
    /* Code for NotExpr Goes Here */
    contextExpr(_p_->u.notexpr_.expr_);
    break;
  case is_PartExpr:
    /* Code for PartExpr Goes Here */
    contextText(_p_->u.partexpr_.text_1);
    contextText(_p_->u.partexpr_.text_2);
    break;
  case is_LPartExpr:
    /* Code for LPartExpr Goes Here */
    contextText(_p_->u.lpartexpr_.text_1);
    break;
  case is_RPartExpr:
    /* Code for RPartExpr Goes Here */
    contextText(_p_->u.rpartexpr_.text_);
    break;
  case is_TextExpr:
    /* Code for TextExpr Goes Here */
    contextText(_p_->u.textexpr_.text_);
    break;

  default:
    fprintf(stderr, "Error: bad kind field when printing Expr!\n");
    exit(1);
  }
}

void contextQueryList(QueryList querylist)
{
  while(querylist != 0)
  {
    /* Code For QueryList Goes Here */
    contextQuery(querylist->query_);
    querylist = querylist->querylist_;
  }
}

void contextQueryLineList(QueryLineList querylinelist)
{
  while(querylinelist != 0)
  {
    /* Code For QueryLineList Goes Here */
    contextQueryLine(querylinelist->queryline_);
    querylinelist = querylinelist->querylinelist_;
  }
}

void contextText(Text _p_)
{

}

void contextName(Name _p_)
{

}

void contextMytoken(MyToken p)
{
  /* Code for MyToken Goes Here */
}
void contextIdent(Ident i)
{
  /* Code for Ident Goes Here */
}

void contextFieldName(Ident i)
{
  if(symbols_isFieldName(i)) fprintf(stderr, "Error: %s nie jest nazwą pola\n", symbols_getName(i));
}

void contextInteger(Integer i)
{
  /* Code for Integer Goes Here */
}
void contextDouble(Double d)
{
  /* Code for Double Goes Here */
}
void contextChar(Char c)
{
  /* Code for Char Goes Here */
}
void contextString(String s)
{
  /* Code for String Goes Here */
}


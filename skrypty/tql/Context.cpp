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
    Query z = (Query) malloc(sizeof(struct Query_));
    int i;
    Expr w;
    if(z1->kind == is_EmptyQuery && z2->kind == is_SingleQuery){
        z1->kind = is_SingleQuery;
    }
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

  case is_SimpleCallQuery:
      contextName(_p_->u.simplecallquery_.name_);
      zapyt = symbols_getQuery(_p_->u.simplecallquery_.name_);
      if(zapyt==NULL){
	//TODO: komunikat
	exit(1);
      }
      _p_->kind = is_SingleQuery;
      for(i=0;i<fieldsCount();i++)
          _p_->u.simplequery_.tabqueryline_[i] = NULL;
      zapyt = merge_queries(_p_, zapyt);
      if(zapyt)
          *_p_ = *zapyt;
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
    contextPart(_p_->u.partexpr_.part);
    break;
   default:
    fprintf(stderr, "Error: bad kind field when printing Expr!\n");
    exit(1);
  }
}

void contextLPart(LPart p){

}


void contextRPart(RPart p){

}


void contextLPartList(LPartList l){

}


void contextRPartList(RPartList l){

}

void contextPart(Part p){
    switch(p->kind){
        case is_MiddleStarPart:
            contextText(p->u.middlestar_.text_);
            contextRPartList(p->u.middlestar_.rpartlist_);
            break;
        case is_RightStarPart:
            contextText(p->u.rightstar_.text_);
            contextLPartList(p->u.rightstar_.lpartlist_);
            break;
        case is_LeftStarPart:
            contextText(p->u.leftstar_.text_);
            contextRPartList(p->u.leftstar_.rpartlist_);
            break;
        case is_BothStarPart:
            contextText(p->u.bothstar_.text_);
            contextLPartList(p->u.bothstar_.lpartlist_);
            break;
        default:
            fprintf(stderr, "Error: bad kind field when printing Part!\n");
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


/*** BNFC-Generated contextor Traversal Skeleton. ***/
/* This traverses the abstract syntax tree.
   To use, copy Skeleton.h and Skeleton.c to
   new files. */

#include <stdio.h>
#include <stdlib.h>
#include "Context.h"
#include "symbols.h"
#include "Absyn.h"

void contextZapZloz(ComplexQuery _p_)
{
  contextListZapytanie(_p_->querylist_);
}

Query polacz_zapytania(Query z1, Query z2){
    Query z = malloc(sizeof(struct Query_));
    int i;
    Expr w;
    if(z1->kind == is_ZapProste && z2->kind == is_ZapProste){
        for(i=0;i<fieldsCount();i++){
	  if(z2->u.zapproste_.tabliniazapytania_[i]!=NULL){
    		w = z2->u.zapproste_.tabliniazapytania_[i]->wyraz_;
		if(z1->u.zapproste_.tabliniazapytania_[i]==NULL)
		    z->u.zapproste_.tabliniazapytania_[i] = make_LiniaZap(z2->u.zapproste_.tabliniazapytania_[i]->ident_, w);
		else{
		    z->u.zapproste_.tabliniazapytania_[i] = make_LiniaZap(z2->u.zapproste_.tabliniazapytania_[i]->ident_, make_WyrazAnd(w, z1->u.zapproste_.tabliniazapytania_[i]->wyraz_));
		}
	  }else
	    z->u.zapproste_.tabliniazapytania_[i] = z1->u.zapproste_.tabliniazapytania_[i];
	}
	return z;
    }
    return NULL;
}

void contextZapytanie(Query _p_)
{
  Query zapyt;
  int i;
  switch(_p_->kind)
  {
  case is_ZapProste:
    /* Code for ZapProste Goes Here */
    break;
  case is_ZapDef:
    /* Code for ZapDef Goes Here */
    contextZapytanie(_p_->u.zapdef_.zapytanie_);
    contextNazwa(_p_->u.zapdef_.nazwa_);
    symbols_setQuery(_p_->u.zapdef_.nazwa_, _p_->u.zapdef_.zapytanie_);
    break;
  case is_ZapWyw:
    /* Code for ZapWyw Goes Here */
    //TODO: Połączyć linie zapytania z zap_def
    contextZapytanie(_p_->u.zapwyw_.zapytanie_);
    contextNazwa(_p_->u.zapwyw_.nazwa_);
    zapyt = symbols_getQuery(_p_->u.zapwyw_.nazwa_);
    if(zapyt==NULL){
	//TODO: komunikat
	exit(1);
    }
    //TODO: zdefiniować funkcję
    zapyt = polacz_zapytania(_p_->u.zapwyw_.zapytanie_, zapyt);
    if(zapyt)
      _p_->u.zapwyw_.zapytanie_ = zapyt;
    break;
  case is_ZapPuste:
    /* Code for ZapPuste Goes Here */
    break;

  default:
    fprintf(stderr, "Error: bad kind field when printing Zapytanie!\n");
    exit(1);
  }
}

void contextLiniaZapytania(QueryLine _p_)
{

    /* Code for LiniaZap Goes Here */
    contextNazwaPola(_p_->ident_);
    contextWyraz(_p_->wyraz_);

}

void contextWyraz(Expr _p_)
{
  switch(_p_->kind)
  {
  case is_WyrazAnd:
    /* Code for WyrazAnd Goes Here */
    contextWyraz(_p_->u.wyrazand_.wyraz_1);
    contextWyraz(_p_->u.wyrazand_.wyraz_2);
    break;
  case is_WyrazOr:
    /* Code for WyrazOr Goes Here */
    contextWyraz(_p_->u.wyrazor_.wyraz_1);
    contextWyraz(_p_->u.wyrazor_.wyraz_2);
    break;
  case is_WyrazNeg:
    /* Code for WyrazNeg Goes Here */
    contextWyraz(_p_->u.wyrazneg_.wyraz_);
    break;
  case is_WyrazFrag:
    /* Code for WyrazFrag Goes Here */
    contextTekst(_p_->u.wyrazfrag_.tekst_1);
    contextTekst(_p_->u.wyrazfrag_.tekst_2);
    break;
  case is_WyrazFragL:
    /* Code for WyrazFragL Goes Here */
    contextTekst(_p_->u.wyrazfragl_.tekst_);
    break;
  case is_WyrazFragP:
    /* Code for WyrazFragP Goes Here */
    contextTekst(_p_->u.wyrazfragp_.tekst_);
    break;
  case is_WyrazTekst:
    /* Code for WyrazTekst Goes Here */
    contextTekst(_p_->u.wyraztekst_.tekst_);
    break;

  default:
    fprintf(stderr, "Error: bad kind field when printing Wyraz!\n");
    exit(1);
  }
}

void contextListZapytanie(QueryList listzapytanie)
{
  while(listzapytanie != 0)
  {
    /* Code For ListZapytanie Goes Here */
    contextZapytanie(listzapytanie->zapytanie_);
    listzapytanie = listzapytanie->listzapytanie_;
  }
}

void contextListLiniaZapytania(QueryLineList listliniazapytania)
{
  while(listliniazapytania != 0)
  {
    /* Code For ListLiniaZapytania Goes Here */
    contextLiniaZapytania(listliniazapytania->liniazapytania_);
    listliniazapytania = listliniazapytania->listliniazapytania_;
  }
}

void contextTekst(Text _p_)
{

}

void contextNazwa(Name _p_)
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

void contextNazwaPola(Ident i)
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


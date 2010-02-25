/*** BNFC-Generated Pretty translateer and Abstract Syntax Viewer ***/

#include "Translator.h"
#include "Symbols.h"
#include "conf/Translator_config.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "Buffer.h"

int _n_;
char* buf_;
int cur_;
int buf_size;

void tmpResizeBuffer(void)
{
  char* temp = (char*) malloc(buf_size);
  if (!temp)
  {
    fprintf(stderr, "Error: Out of memory while attempting to grow buffer!\n");
    exit(1);
  }
  if (buf_)
  {
    strncpy(temp, buf_, buf_size); /* peteg: strlcpy is safer, but not POSIX/ISO C. */
    free(buf_);
  }
  buf_ = temp;
}


void tmpBufAppendS(const char* s)
{
  int len = strlen(s);
  int n;
  while (cur_ + len > buf_size)
  {
    buf_size *= 2; /* Double the buffer size */
    tmpResizeBuffer();
  }
  for(n = 0; n < len; n++)
  {
    buf_[cur_ + n] = s[n];
  }
  cur_ += len;
  buf_[cur_] = 0;
}
void tmpBufAppendC(const char c)
{
  if (cur_ == buf_size)
  {
    buf_size *= 2; /* Double the buffer size */
    tmpResizeBuffer();
  }
  buf_[cur_] = c;
  cur_++;
  buf_[cur_] = 0;
}
void tmpBufReset(void)
{
  cur_ = 0;
  buf_size = BUFFER_INITIAL;
  tmpResizeBuffer();
  memset(buf_, 0, buf_size);
}

char *buf_;
int cur_, buf_size;



/* You may wish to change the renderC functions */
void renderC(Char c)
{
  if (c == '{')
  {
     tmpBufAppendC('\n');
     indent();
     tmpBufAppendC(c);
     _n_ = _n_ + 2;
     tmpBufAppendC('\n');
     indent();
  }
  else if (c == '(' || c == '[')
     tmpBufAppendC(c);
  else if (c == ')' || c == ']')
  {
     backup();
     tmpBufAppendC(c);
     tmpBufAppendC(' ');
  }
  else if (c == '}')
  {
     _n_ = _n_ - 2;
     backup();
     backup();
     tmpBufAppendC(c);
     tmpBufAppendC('\n');
     indent();
  }
  else if (c == ',')
  {
     backup();
     tmpBufAppendC(c);
     tmpBufAppendC(' ');
  }
  else if (c == ';')
  {
     backup();
     tmpBufAppendC(c);
     tmpBufAppendC('\n');
     indent();
  }
  else if (c == 0) return;
  else
  {
     tmpBufAppendC(c);
     tmpBufAppendC(' ');
  }
}

void renderS(Char* str)
{
  if(strlen(str) > 0)
  {
    tmpBufAppendS(str);
    tmpBufAppendC(' ');
  }
}
void indent(void)
{
  int n = _n_;
  while (n > 0)
  {
    tmpBufAppendC(' ');
    n--;
  }
}
void backup(void)
{
  if (buf_[cur_ - 1] == ' ')
  {
    buf_[cur_ - 1] = 0;
    cur_--;
  }
}
char* translateComplexQuery(ComplexQuery p)
{
  _n_ = 0;
  tmpBufReset();
  ppComplexQuery(p, 0);
  //printf("\n\n\n%s\n\n\n",  translator_wynik());
  return translator_getResult();
}
void ppComplexQuery(ComplexQuery _p_, int _i_)
{
    ppQueryList(_p_->querylist_, 0);
}

void ppQuery(Query _p_, int _i_)
{
   int j, b;

  switch(_p_->kind)
  {
  case is_SingleQuery:
    translator_initSingleQuery();
    if (_i_ > 0) renderC(_L_PAREN);
    for(j=0;j<fieldsCount();j++){
	if(_p_->u.simplequery_.tabqueryline_[j]!=NULL){
    		translator_mergeLines(ppQueryLine(_p_->u.simplequery_.tabqueryline_[j], 0), _p_->u.simplequery_.tabqueryline_[j]->ident_);
	}
    }
//    ppListPrzerwa(_p_->u.zapproste_.listprzerwa_, 0);
    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_DefQuery:
    break;

  case is_CallQuery:
    if (_i_ > 0) renderC(_L_PAREN);
    ppQuery(_p_->u.callquery_.query_, 0);

    if (_i_ > 0) renderC(_R_PAREN);
    break;

  case is_EmptyQuery:
    if (_i_ > 0) renderC(_L_PAREN);

    if (_i_ > 0) renderC(_R_PAREN);
    break;


  default:
    fprintf(stderr, "Error: bad kind field when translating Query!\n");
    exit(1);
  }
}

char *ppQueryLine(QueryLine _p_, int _i_)
{

    return ppExpr(_p_->expr_, _p_->ident_, 0);

}


char* ppLPart(LPart p){
    return translator_star(ppText(p->text), NULL);
}


char* ppRPart(RPart p){
    return translator_star(NULL, ppText(p->text));
}


void ppLPartList(bufor buf, LPartList l){
    while(l){
        bufAppendS(buf, ppLPart(l->lpart_));
        l = l->lpartlist_;
    }
}


void ppRPartList(bufor buf, RPartList l){
    while(l){
        bufAppendS(buf, ppLPart(l->rpart_));
        l = l->rpartlist_;
    }
}


char* ppPart(Part p) {
    bufor buf = malloc(sizeof(_bufor));
    bufReset(buf);
    switch(p->kind){
        case is_MiddleStarPart:
            bufAppendS(buf, ppText(p->u.middlestar_.text_));
            ppRPartList(buf, p->u.middlestar_.rpartlist_);
            break;
        case is_RightStarPart:
            bufAppendS(buf, translator_star(ppText(p->u.rightstar_.text_), NULL));
            ppLPartList(buf, p->u.rightstar_.lpartlist_);
            break;
        case is_LeftStarPart:
            bufAppendS(buf, translator_star(NULL, ppText(p->u.leftstar_.text_)));
            ppRPartList(buf, p->u.leftstar_.rpartlist_);
            break;
        case is_BothStarPart:
            bufAppendS(buf, translator_star(NULL, translator_star(ppText(p->u.bothstar_.text_), NULL)));
            ppLPartList(buf, p->u.bothstar_.lpartlist_);
            break;
        default:
            fprintf(stderr, "Error: bad kind field when printing Part!\n");
            exit(1);
    }
    return buf->buf;
}


char *ppExpr(Expr _p_, Ident id, int _i_)
{
  //char *format = zapytanie(id);
  switch(_p_->kind)
  {
  case is_AndExpr:
    return translator_and(id, ppExpr(_p_->u.andexpr_.expr_1, id, 0), ppExpr(_p_->u.andexpr_.expr_2, id, 1));
  case is_OrExpr:
    return translator_or(id, ppExpr(_p_->u.orexpr_.expr_1, id, 0), ppExpr(_p_->u.orexpr_.expr_2, id, 1));
  case is_NotExpr:
    return translator_not(id, ppExpr(_p_->u.notexpr_.expr_, id, 1));

  case is_PartExpr:
    return translator_simpleText(id, ppPart(_p_->u.partexpr_.part));

  default:
    fprintf(stderr, "Error: bad kind field when translating Expr!\n");
    exit(1);
  }
}



void ppQueryList(QueryList querylist, int i)
{
  while(querylist!= 0)
  {
    if (querylist->querylist_ == 0)
    {
      ppQuery(querylist->query_, 0);

      querylist = 0;
    }
    else
    {
      ppQuery(querylist->query_, 0);
      renderS("");
      querylist = querylist->querylist_;
    }
  }
}

void ppQueryLineList(QueryLineList querylinelist, int i)
{
  while(querylinelist!= 0)
  {
    if (querylinelist->querylinelist_ == 0)
    {
      ppQueryLine(querylinelist->queryline_, 0);

      querylinelist = 0;
    }
    else
    {
      ppQueryLine(querylinelist->queryline_, 0);
      renderS("\n");
      querylinelist = querylinelist->querylinelist_;
    }
  }
}

char* ppText(Text _p_)
{

    return symbols_getName(_p_);

}

void ppName(Name _p_, int _i_)
{
}

void ppInteger(Integer n, int i)
{
  char tmp[16];
  sprintf(tmp, "%d", n);
  tmpBufAppendS(tmp);
}
void ppDouble(Double d, int i)
{
  char tmp[16];
  sprintf(tmp, "%g", d);
  tmpBufAppendS(tmp);
}
void ppChar(Char c, int i)
{
  tmpBufAppendC('\'');
  tmpBufAppendC(c);
  tmpBufAppendC('\'');
}
void ppString(String s, int i)
{
  tmpBufAppendC('\"');
  tmpBufAppendS(symbols_getName(i));
  tmpBufAppendC('\"');
}
void ppIdent(String s, int i)
{
  renderS(symbols_getName(s));
}
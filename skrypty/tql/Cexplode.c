/* ******************************************************** */
/*                                                          *
*      Implementation of php's explode written in C        *
*      Written by  Maz (2008)                              *
*      http://maz-programmersdiary.blogspot.com/           *
*                                                          *
*      You're free to use this piece of code.              *
*      You can also modify it freely, but if you           *
*      improve this, you must write the improved code      *
*      in comments at:                                     *
*      http://maz-programmersdiary.blogspot.com/           *
*      or at:                                              *
*      http://c-ohjelmoijanajatuksia.blogspot.com/         *
*      or mail the corrected version to me at              *
*      Mazziesaccount@gmail.com                            *
*                                                          *
*      Revision History:                                   *
*                                                          *
*      -v0.0.1 16.09.2008/Maz                              *
*                                                          */
/* ******************************************************** */


#include "Cexplode.h"


int Cexplode
(
  const char *string,
  const char *delim,
  CexplodeStrings *exp_obj 
)
{
  int stringL = 0;
  int delimL  = 0;
  int index;
  int pieces=0;
  int string_start=0;

  char **tmp=NULL;

  //Sanity Checks:
  if(NULL==string || NULL==delim || NULL == exp_obj)
  {
      printf("Invalid params given to Cexplode!\n");
      return ECexplodeRet_InvalidParams;
  }
  stringL = strlen(string);
  delimL  = strlen(delim);
  if(delimL>=stringL)
  {
      printf("Invalid params given to Cexplode!\n");
      return 0;
  }
  for(index=0;index<stringL-delimL;index++)
  {
      if(string[index]==delim[0])
      {
          //Check if delim was actually found
          if( !memcmp(&(string[index]),delim,delimL) )
          {
              //token found
              //let's check if token was at the beginning:
              if(index==string_start)
              {
                  string_start+=delimL;
                  index+=delimL-1;
                  continue;
              }
              /*
                 if token was not at start, then we 
                 should add it in CexplodeStrings
              */
              pieces++;
              if(NULL==tmp)
                  tmp=malloc(sizeof(char *));
              else
                  tmp=realloc(tmp,sizeof(char *)*pieces);
              if(NULL==tmp)
              {
                  printf("Cexplode: Malloc failed!\n");
                  return ECexplodeRet_InternalFailure;
              }
              //alloc also for \0
              tmp[pieces-1]=malloc
              (
                sizeof(char *)*(index-string_start+1)
              );
              if(NULL==tmp[pieces-1])
              {
                  printf("Cexplode: Malloc failed!\n");
                  return ECexplodeRet_InternalFailure;
              }
              memcpy(
                tmp[pieces-1],
                &(string[string_start]),
                index-string_start
              );

              tmp[pieces-1][index-string_start]='\0';
              string_start=index+delimL;
              index+=(delimL-1);
          }//delim found
      }//first letter in delim found from string
  }//for loop

  if(memcmp(&(string[index]),delim,delimL))
      index+=delimL;
  if(index!=string_start)
  {
      pieces++;
      if(NULL==tmp)
          tmp=malloc(sizeof(char *));
      else
          tmp=realloc(tmp,sizeof(char *)*pieces);
      if(NULL==tmp)
      {
          printf("Cexplode: Malloc failed!\n");
          return ECexplodeRet_InternalFailure;
      }
          tmp[pieces-1]=malloc
         (
            sizeof(char *)*(index-string_start+1)
         );
      if(NULL==tmp[pieces-1])
      {
          printf("Cexplode: Malloc failed!\n");
          return ECexplodeRet_InternalFailure;
      }
      memcpy
      (
        tmp[pieces-1],
        &(string[string_start]),
        index-string_start
      );
      tmp[pieces-1][index-string_start]='\0';
  }
  exp_obj->amnt=pieces;
  exp_obj->strings=tmp;
  return pieces;
}


char *Cexplode_getNth(int index,CexplodeStrings exp_obj)
{
  if(exp_obj.amnt<index)
  {
      return NULL;
  }
  return exp_obj.strings[index-1];
}

char *Cexplode_getfirst(CexplodeStrings exp_obj)
{
  return Cexplode_getNth(1,exp_obj);
}
void Cexplode_free(CexplodeStrings exp_obj)
{
  int i=0;
  for(;i<exp_obj.amnt;i++)
      free(exp_obj.strings[i]);
  free(exp_obj.strings);
}
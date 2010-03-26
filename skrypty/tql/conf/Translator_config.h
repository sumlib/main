#define MAX_POL 10
#ifndef _CONFIG_FILE_
#define _CONFIG_FILE_

  int fieldsCount();
  char *fieldName(int i);
  char *translator_simpleText(int i, char *text);
  char *translator_or(int id, char *expr1, char *expr2);
  char *translator_and(int id, char *expr1, char *expr2);
  char *translator_not(int id, char *expr1);
  char *translator_star(char *frag1, char *frag2);
  void translator_initSingleQuery();
  void translator_mergeLines(char *line, int id);
  char *translator_getResult();
#endif
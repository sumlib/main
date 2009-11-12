#define MAX_POL 9
#ifndef _CONFIG_FILE_
#define _CONFIG_FILE_
#define ZMIENNA "###"


  int ilePol();
  char *nazwaPola(int i);
  char *translator_zapytanie(int i, char *tekst);
  char *translator_polaczOr(int id, char *wyr1, char *wyr2);
  char *translator_polaczAnd(int id, char *wyr1, char *wyr2);
  char *translator_negacja(int id, char *wyr1);
  char *translator_gwiazdka(char *frag1, char *frag2);
  void translator_init();
  void translator_linia_zapytania(char *tekst, int id, int bylo);
  char *translator_wynik();
#endif
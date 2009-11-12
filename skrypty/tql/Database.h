#ifndef _DATABASE_HEADER_
#define _DATABASE_HEADER_

typedef enum{results, number, name, place, date} tag_type;

typedef struct{
    int beginNode;
    int endNode;
    int value;
    tag_type type;
} Tag;

typedef struct{
    Tag *tab;
    int size;
    int count;
} Tags;

typedef struct{    
    char* id;
    char* id_cdli;
    char* publication;
    char* measurements;
    char* year;
    char* provenience;
    char* period;
    char* genre;
    char* subgenre;
    char* collection;
    char* text;
    Tags *tags; //miejsca gdzie w tekscie s± wyniki wyszukiwania
} Tablet;

typedef struct{
    int size;
    Tablet *tabs;
} Tablets;

char* getXmlFromQuery(char*);

#endif

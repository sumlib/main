#ifndef _DATABASE_HEADER_
#define _DATABASE_HEADER_

typedef enum{results, number, name, place, date} tag_type;

typedef struct{
    int beginNode;
    int endNode;
    int id;
    int value;
    tag_type type;
} Tag;

typedef struct{
    Tag *tab;
    int size;
    int count;
} Tags;

typedef struct{    
    const char* id_cdli;
    const char* publication;
    const char* measurements;
    const char* year;
    const char* provenience;
    const char* period;
    const char* genre;
    const char* subgenre;
    const char* collection;
    const char* text;
    Tags *tags; //miejsca gdzie w tekscie sa wyniki wyszukiwania
} Tablet;

typedef struct{
    int size;
    Tablet *tabs;
} Tablets;

char* getXmlFromQuery(char*);

#endif

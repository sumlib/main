#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbols.h"
#include "conf/Translator_config.h"

/* plik definiujący tablicę symboli */

int symbols_size = 0;
int symbols_count = 0;

typedef struct{
  char *name;
  Query zapyt;
} Symbol;

Symbol* symbols;

void symbols_init(){
	int i;
	symbols_size = 128;
	symbols = malloc(symbols_size * sizeof(Symbol));
	for(i=0;i<fieldsCount();i++)
		symbols_getId(fieldName(i));
	
}

int symbols_getId(char* name){
	int i;
	Symbol *tmp;
	if(!symbols_size) symbols_init();
	for(i=0;i<symbols_count;i++)
		if(strcmp(name, symbols[i].name)==0) return i;
	if(symbols_size == symbols_count){
		symbols_size*=2;
		tmp = malloc(symbols_size * sizeof(Symbol*));
		for(i=0;i<symbols_count;i++)
			tmp[i] = symbols[i];
		free(symbols);
		symbols = tmp;
	}
	i = symbols_count++;
	symbols[i].name = strdup(name);
	symbols[i].zapyt = NULL;
	
	return symbols_count-1;
}

char* symbols_getName(int id){
	if(id<0 || id>symbols_count){
		fprintf(stderr, "Error: wrong id in symbol_get_name (%d)\n", id);
		return NULL;
	}
	return symbols[id].name;
}

Query symbols_getQuery(int id){
	if(id<0 || id>symbols_count){
		fprintf(stderr, "Error: wrong id in symbol_get_zapyt (%d)\n", id);
		return NULL;
	}
	return symbols[id].zapyt;
}

void symbols_setQuery(int id, Query zapyt){
  	if(id<0 || id>symbols_count){
		fprintf(stderr, "Error: wrong id in symbol_set_zapyt (%d)\n", id);
		return;
	}
	symbols[id].zapyt = zapyt;
}

int symbols_isFieldName(Ident i){
//	printf("czy %d jest Nazwą pola\n", i);
	return (i>=0 && i<fieldsCount());
}

int symbols_toFieldId(Ident id){
	if(symbols_isFieldName(id))
		return id;
	else
		return -1;
}

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "Symbols.h"

int main(){
	char name[12], *tmp;
	int i, id;

	for(i=0;i<130;i++){
		sprintf (name, "symbol%d", i);
		id = symbol_get_id(name);
		printf("%s ma id=%d\n", name, id);
	}
	id = symbol_get_id(name);
	printf("%s ma id=%d\n", name, id);
	for(i=0;i<131;i++){
		tmp = symbol_get_name(i);
		printf("%d -> %s\n", i, tmp);
	}
}	
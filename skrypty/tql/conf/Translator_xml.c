#include "Translator_config.h"
#include "../Buffer.h"


bufor buf_result=NULL;


void translator_initSingleQuery(){
    if(!buf_result){
        buf_result = malloc(sizeof(_bufor));
        bufReset(buf_result);
    }else{
        bufAppendC(buf_result, "\n\n");
    }
}

char *translator_simpleText(int i, char *text){
    return text;
}

char *translator_or(int id, char *expr1, char *expr2){
    return concat(expr1, " OR ", expr2, 0);
}

char *translator_and(int id, char *expr1, char *expr2){
    return concat(expr1, " AND ", expr2, 0);
}

char *translator_not(int id, char *expr1){
    return concat(NULL, " NOT ", expr1, 0);
}

char *translator_star(char *frag1, char *frag2){
    return concat(frag1, " * ", frag2, 0);
}

void translator_mergeLines(char *line, int id){
    bufAppendS(buf_result, line);
}

char *translator_getResult(){
    return buf_result.buf;
}

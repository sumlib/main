#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#include <postgresql/libpq-fe.h>
#include <iostream>


#include "../Cexplode.h"
#include "Database_config.h"
#include "../Err.h"

#include <zorba/zorba.h>
#include <simplestore/simplestore.h>

using namespace zorba;

#define MAX_LINE_SIZE 64
#define CONFIG_FILE "conf/xml.conf"
#define DOC_URI "DOC_URI"

#define cut_newline(s) if (s[strlen(s)-1]=='\n') s[strlen(s)-1]=0

typedef struct {
    char* uri;
} doc_config;

//#define MAX_NODE_SIZE 11;
//#define nodeReset for(ni=0;ni<11;ni++) node[ni] = 0;


void initTags(Tags* tags) {

    tags->count=0;
    tags->size=10;
    tags->tab = (Tag*) malloc(sizeof(Tag)*tags->size);
}

void resizeTags(Tags* tags) {
    tags->size*=2;
    tags->tab=(Tag*) realloc(tags->tab,tags->size);
}

void addTag(Tags* tags, Tag tag) {
    if (tags->size <= tags->count) {
        resizeTags(tags);
    }
    tags->tab[tags->count++]=tag;
}

doc_config parseConfigFile() {
    FILE* f = fopen(CONFIG_FILE, "r");
    if (f == NULL) {
        syserr(errno, "Problems with openning file %s\n", CONFIG_FILE);
    }
    char* line = (char*) malloc(MAX_LINE_SIZE * sizeof (char));
    CexplodeStrings strings;
    doc_config dbc;
    dbc.uri = "";

    while (!feof(f)) {
        line = fgets(line, MAX_LINE_SIZE, f);
        if (line == NULL) {
            fprintf(stderr, "Error: problem while reading config file\n");
            exit(1);
        }
        if (0 > Cexplode(line, "=", &strings) || strings.amnt != 2) {
            printf("CexplodeFailed!\n");
            return dbc;
        }
        if (strcmp(strings.strings[0], DOC_URI) == 0) {
            dbc.uri = strdup(strings.strings[1]);
            cut_newline(dbc.uri);
        }
    }

    //printf("host: %s\nname: %s\nport: %s\nuser: %s\npass: %s\n", dbc.host, dbc.name, dbc.port, dbc.user, dbc.pass);

    return dbc;

}

#define takeRealNode(node)   node[strlen(node)-7] = 0;
#define charIsDigit(c) ('0' <= c && c <= '9')

Tablets *getTablets(char* query) {
    doc_config doc = parseConfigFile();
    //printf("%s\n\n%s\n\n", query, doc.uri);

    simplestore::SimpleStore* lStore = simplestore::SimpleStoreManager::getStore();
    Zorba *lZorba = Zorba::getInstance(lStore);

    try {
       std::cout << "compiling query" << std::endl;
      //XQuery_t lQuery = lZorba->compileQuery("doc('/home/asia/Dokumenty/zorbatest/tablets.xml')/tablets/tablet", lStaticContext);
       XQuery_t lQuery = lZorba->compileQuery(query);
       DynamicContext* lDynamicContext = lQuery->getDynamicContext();

       lDynamicContext->setContextItemAsDocument("file:///home/asia/Dokumenty/zorbatest/tablets.xml");


      std::cout << "compiled" << std::endl;
	  try {

	    std::cout << lQuery << std::endl;

	  } catch (DynamicException &e) {
	    std::cerr << e << std::endl;
	    return false;
	  }

    } catch (StaticException &se) {
      std::cerr << se << std::endl;
      return NULL;
    }

    lZorba->shutdown();
    simplestore::SimpleStoreManager::shutdownStore(lStore);
    
    return NULL;
}
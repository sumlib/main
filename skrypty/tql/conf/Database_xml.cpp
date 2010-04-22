#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
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


#define T_ID_CDLI "idCDLI"
#define T_PUBLICATION "publication"
#define T_PROVENIENCE "provenience"
#define T_PERIOD "period"
#define T_MEASUREMENTS "measurements"
#define T_GENRE "genre"
#define T_SUBGENRE "subgenre"
#define T_COLLECTION "collection"
#define T_MUSEUM "museum"
#define T_TEXT "show"
#define T_NODES "seq"

#define cut_newline(s) if (s[strlen(s)-1]=='\n') s[strlen(s)-1]=0

#define setFromResult(v, nodeName) if(lNodeName.getStringValue().compare(nodeName) == 0){ \
                                        v = (const char*) strdup(lChild.getStringValue().c_str()); \
                                    } else
#define setNodesFromResult(v, nodeName) if(lNodeName.getStringValue().compare(nodeName) == 0){ \
                                        v = parseNodes(lChild); \
                                    }

//                                        std::cout << "set value for " << nodeName << ": " << v << std::endl; \

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

    return dbc;

}


Tags* parseNodes(Item nodes) {
    Tags* tags = (Tags*) malloc(sizeof(Tags));
    Tag tag;
    int tag_id = 0;

    initTags(tags);

    Iterator_t nodesIter = nodes.getChildren();
    Item tagItem;

    nodesIter->open();

    while (nodesIter->next(tagItem)) {
        Item tagNodeName;
        tagItem.getNodeName(tagNodeName);
        const char * seq_string = tagNodeName.getStringValue().c_str() + 3; //pomijamy "seq"
        int seq_id = atoi(seq_string);

        tag.beginNode=0;
        tag.endNode=0;

        Iterator_t attrIter = tagItem.getAttributes();
        attrIter->open();
        Item attr;
        while (attrIter->next(attr)) {
            Item attr_name_item;
            attr.getNodeName(attr_name_item);
            const char* attrValue = attr.getStringValue().c_str();
            if (attr_name_item.getStringValue().compare("node1") == 0) {
                tag.beginNode=atoi(attrValue);

            }
            else if (attr_name_item.getStringValue().compare("node2") == 0) {
                tag.endNode=atoi(attrValue);
            }

        }
        attrIter->close();

        tag.id=tag_id;
        tag.value=seq_id;
        tag.type=results;;
        addTag(tags,tag);

        tag_id++;
    }
    
    nodesIter->close();

    return tags;
}


Tablet* resizeTablet(Tablet* t, int size){
    return (Tablet*) realloc(t, size);
}


Tablets *getTablets(char* query) {
    doc_config doc = parseConfigFile();
    Tablets* retVal = (Tablets*) malloc(sizeof(Tablets));
    int size = 10;
    int count = 0;
    Tablet* tabs = (Tablet*) malloc(size * sizeof(Tablet));

    simplestore::SimpleStore* lStore = simplestore::SimpleStoreManager::getStore();
    Zorba *lZorba = Zorba::getInstance(lStore);

    try {
        XQuery_t lQuery = lZorba->compileQuery(query);
        DynamicContext* lDynamicContext = lQuery->getDynamicContext();

        //ustawianie dokumentu z bazą danych:
        lDynamicContext->setContextItemAsDocument(doc.uri);

        try {

            Iterator_t lIterator = lQuery->iterator();
            lIterator->open();

            Item lItem;
            while (lIterator->next(lItem)) {
                //nowa tabliczka:
                if(count >= size){
                    size*=2;
                    tabs = resizeTablet(tabs, size);
                }


                Iterator_t lChildIter = lItem.getChildren();

                lChildIter->open();
                Item lChild;
                while (lChildIter->next(lChild)) {
                    //węzeł w tabliczce
                    Item lNodeName;
                    lChild.getNodeName(lNodeName);
//                    std::cout << "node name " << lNodeName.getStringValue() << " = " << lChild.getStringValue() << std::endl;
                    setFromResult(tabs[count].id_cdli, T_ID_CDLI)
                    setFromResult(tabs[count].collection, T_COLLECTION)
                    setFromResult(tabs[count].genre, T_GENRE)
                    setFromResult(tabs[count].subgenre, T_SUBGENRE)
                    setFromResult(tabs[count].measurements, T_MEASUREMENTS)
                    setFromResult(tabs[count].period, T_PERIOD)
                    setFromResult(tabs[count].provenience, T_PROVENIENCE)
                    setFromResult(tabs[count].publication, T_PUBLICATION)
                    setFromResult(tabs[count].text, T_TEXT)
                    setNodesFromResult(tabs[count].tags, T_NODES)
                    //jeśli nie pasuje do żadnego:
                     ;
//                            std::cout << "node name " << lNodeName.getStringValue() << " = " << lChild.getStringValue() << std::endl;
                    }

                lChildIter->close();
                count++;
            }

            lIterator->close();


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

    retVal->size = count;
    retVal->tabs = tabs;
    return retVal;
}
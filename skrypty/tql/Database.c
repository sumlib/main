#include "Database.h"
#include "conf/Database_config.h"
#include "Buffer.h"
#include <stdio.h>
#include <stdlib.h>

#define oneTab(n) tabs->tabs[n]

void addNodes(Tablet tab);

char* getXmlFromQuery(char* query){
    Tablets *tabs = getTablets(query);
    int i;
    _bufor buf;
    if(tabs==NULL) return "No results";
    else {
        bufReset(&buf);
        for (i = 0; i < tabs->size; i++) {
           // printf(" id: %s\n id_cdli: %s\n kolekcja: %s\n prowiniencja: %s\n okres: %s\n typ: %s\n podtyp: %s\n publikacja: %s\n ==================================================================\n\n",
             //       oneTab(i).id, oneTab(i).id_cdli, oneTab(i).collection, oneTab(i).provenience, oneTab(i).period, oneTab(i).genre, oneTab(i).subgenre, oneTab(i).publication);
            bufAppendS(&buf, "<tablet id_cdli=\"");
            bufAppendS(&buf, oneTab(i).id_cdli);
            bufAppendS(&buf, "\" collection=\"");
            bufAppendS(&buf, oneTab(i).collection);
            bufAppendS(&buf, "\" provenience=\"");
            bufAppendS(&buf, oneTab(i).provenience);
            bufAppendS(&buf, "\" period=\"");
            bufAppendS(&buf, oneTab(i).period);
            bufAppendS(&buf, "\" genre=\"");
            bufAppendS(&buf, oneTab(i).genre);
            bufAppendS(&buf, "\" subgenre=\"");
            bufAppendS(&buf, oneTab(i).subgenre);
            bufAppendS(&buf, "\" publication=\"");
            bufAppendS(&buf, oneTab(i).publication);
            bufAppendS(&buf, "\">");
            bufAppendS(&buf, oneTab(i).text);
            addNodes(oneTab(i));
            bufAppendS(&buf, "</tablet>\n");
        }
	return buf.buf;
    }
}

int comparator(Tag *t1, Tag *t2){
    if(t1->beginNode > t2->beginNode)
        return 1;
    if(t2->beginNode > t1->beginNode)
        return -1;
    //beginNode s� r�wne
    if(t1->endNode > t2->endNode)
        return 1;
    if(t2->endNode > t1->endNode)
        return -1;
    return 0;
}

void addNodes(Tablet tab){
    int i;
    if(tab.tags==NULL)
        return;
    qsort(tab.tags->tab, tab.tags->count, sizeof(Tag), comparator);
    for(i=0;i<tab.tags->count;i++){
      //  printf("Tag: from %d to %d, value %d\n", tab.tags->tab[i].beginNode, tab.tags->tab[i].endNode, tab.tags->tab[i].value);
    }
}
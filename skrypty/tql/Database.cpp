#include "Database.h"
#include "conf/Database_config.h"
#include "Buffer.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define oneTab(n) tabs->tabs[n]
#define BEGIN_TAG "<tag "
#define END_TAG "</tag>"

const char* addNodes(Tablet tab);

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
            bufAppendS(&buf, addNodes(oneTab(i)));
            bufAppendS(&buf, "</tablet>\n");
        }
	return buf.buf;
    }
}


typedef struct{
    int id;
    Tag* tag;
} TagNode;

int comparator(const void *v1, const void *v2){
    TagNode *tn1, *tn2;
    tn1 = (TagNode*) v1;
    tn2 = (TagNode*) v2;
    if(tn1->id == tn2->id){
        return 0;
    }
    if(tn1->id > tn2->id){
        return 1;
    }
    return -1;
//    if(t1->beginNode > t2->beginNode)
//        return 1;
//    if(t2->beginNode > t1->beginNode)
//        return -1;
//    //beginNode s� r�wne
//    if(t1->endNode > t2->endNode)
//        return 1;
//    if(t2->endNode > t1->endNode)
//        return -1;
//    return 0;
}

//void printTag(Tag *tag, char* info){
//    printf("%s: tag id: %d, value: %d, from: %d, to: %d\n", info, tag->id, tag->value, tag->beginNode, tag->endNode);
//}

void makeTagNode(TagNode *tagNode, Tag *tag, bool begin){
    tagNode->tag = tag;
    if(begin)
        tagNode->id = tag->beginNode;
    else
        tagNode->id = tag->endNode;
}

const char* addNodes(Tablet tab){
    int i, nodenr=0, closed;
    char *line, *textbuf = strdup(tab.text), *node;
    char *saveptr1, *saveptr2;
    _bufor rettextbuf, tagIdsBuf, tagValsBuf;
    char c;
    
    int openedTagsCount=0;

    if(tab.tags==NULL)
        return tab.text;


    bufReset(&rettextbuf);
    bufReset(&tagIdsBuf);
    bufReset(&tagValsBuf);
    Tag* openedTags[tab.tags->count];
   
    int size = tab.tags->count*2;
    TagNode tagNodes[size];
    for(i=0; i<tab.tags->count; i++){
        makeTagNode(&tagNodes[2*i], &(tab.tags->tab[i]), true);
        makeTagNode(&tagNodes[2*i+1], &(tab.tags->tab[i]), false);
    }
    qsort(tagNodes, size, sizeof(TagNode), comparator);

    i = 0;
    line = strtok_r(textbuf, "\n", &saveptr1);
    while(line){
        node = strtok_r(line, " ", &saveptr2);
        while(node){
           if (nodenr == tagNodes[i].id) {
                if (openedTagsCount > 0){
                    c = bufPop(&rettextbuf);
                    bufAppendS(&rettextbuf, END_TAG);
                    bufAppendC(&rettextbuf, c);
                }
               closed = 0;
                for(int j=0; j<openedTagsCount; j++){
                    if(openedTags[j]->endNode == nodenr){
                        if(j<openedTagsCount-1){
                            openedTags[j] = openedTags[openedTagsCount-1];

                        }
                        closed++;
                    }
                }
               openedTagsCount -= closed;
                do {
                    if (tagNodes[i].id == tagNodes[i].tag->beginNode) {
                        openedTags[openedTagsCount++] = tagNodes[i].tag;
                    }
                    i++;
                } while (nodenr == tagNodes[i].id) ;

                for(int j=0; j<openedTagsCount;j++){
                        bufAppendS(&tagIdsBuf, " ");
                        bufAppendInt(&tagIdsBuf, openedTags[j]->id);
                        bufAppendS(&tagValsBuf, " ");
                        bufAppendInt(&tagValsBuf, openedTags[j]->value);
                }

               if (openedTagsCount > 0) {
                    bufAppendS(&rettextbuf, BEGIN_TAG);
                    bufAppendS(&rettextbuf, "ids=\"");
                    bufAppendS(&rettextbuf, tagIdsBuf.buf);
                    bufAppendS(&rettextbuf, "\" values=\"");
                    bufAppendS(&rettextbuf, tagValsBuf.buf);
                    bufAppendS(&rettextbuf, "\" >");
                    bufClean(&tagIdsBuf);
                    bufClean(&tagValsBuf);
                }
               
            }
            bufAppendS(&rettextbuf, node);
            bufAppendS(&rettextbuf, " ");
            node = strtok_r(NULL, " ", &saveptr2);
            nodenr++;
        }
        bufAppendS(&rettextbuf, "\n");
        line = strtok_r(NULL, "\n", &saveptr1);
    }
    
    return rettextbuf.buf;
}
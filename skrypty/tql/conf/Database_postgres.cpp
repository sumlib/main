#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#include <postgresql/libpq-fe.h>
//#include </usr/local/pgsql/include/libpq-fe.h>

#include "../Cexplode.h"
#include "Database_interface.h"
#include "../Err.h"

#define MAX_LINE_SIZE 64
#define CONFIG_FILE "conf/database.conf"
#define DB_HOST "DB_HOST"
#define DB_PORT "DB_PORT"
#define DB_NAME "DB_NAME"
#define DB_USER "DB_USER"
#define DB_PASS "DB_PASS"

#define T_ID 0
#define T_ID_CDLI 1
#define T_PUBLICATION 2
#define T_MEASUREMENTS 3
#define T_YEAR 4
#define T_PROVENIENCE 5
#define T_PERIOD 6
#define T_GENRE 7
#define T_SUBGENRE 8
#define T_COLLECTION 9
#define T_MUSEUM 10
#define T_TEXT 11
#define T_NODES 12

#define cut_newline(s) if (s[strlen(s)-1]=='\n') s[strlen(s)-1]=0
#define setFromResult(v, rowId, i) v = PQgetisnull(result, rowId, i) ? "" : strdup(PQgetvalue(result, rowId, i))

typedef struct {
    char* name;
    char* host;
    char* port;
    char* user;
    char* pass;
} db_config;

#define MAX_NODE_SIZE 11;
#define nodeReset for(ni=0;ni<11;ni++) node[ni] = 0;

#define newTag tags->tab[tags->count-1]


void printTag2(Tag *tag, char* info){
    printf("%s: tag id: %d, value: %d, from: %d, to: %d\n", info, tag->id, tag->value, tag->beginNode, tag->endNode);
}


void initTags(Tags* tags) {

    tags->count=0;
    tags->size=10;
    tags->tab = (Tag*) malloc(sizeof(Tag)*tags->size);
}

void resizeTags(Tags* tags) {
    tags->size*=2;
    tags->tab= (Tag*) realloc(tags->tab,tags->size*sizeof(Tag));
}

void addTag(Tags* tags) {
    if (tags->size <= tags->count) {
        resizeTags(tags);
    }
    tags->count++;
}



db_config parseConfigFile() {
    FILE* f = fopen(CONFIG_FILE, "r");
    if (f == NULL) {
        syserr(errno, "Problems with openning file %s\n", CONFIG_FILE);
    }
    char* line = (char*) malloc(MAX_LINE_SIZE * sizeof (char));
    CexplodeStrings strings;
    db_config dbc;
    dbc.name = "";
    dbc.host = "";
    dbc.port = "";
    dbc.user = "";
    dbc.pass = "";

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
        if (strcmp(strings.strings[0], DB_NAME) == 0) {
            dbc.name = strdup(strings.strings[1]);
            cut_newline(dbc.name);
        } else if (strcmp(strings.strings[0], DB_HOST) == 0) {
            dbc.host = strdup(strings.strings[1]);
            cut_newline(dbc.host);
        } else if (strcmp(strings.strings[0], DB_PORT) == 0) {
            dbc.port = strdup(strings.strings[1]);
            cut_newline(dbc.port);
        } else if (strcmp(strings.strings[0], DB_USER) == 0) {
            dbc.user = strdup(strings.strings[1]);
            cut_newline(dbc.user);
        } else if (strcmp(strings.strings[0], DB_PASS) == 0) {
            dbc.pass = strdup(strings.strings[1]);
            cut_newline(dbc.pass);
        }
    }

    //printf("host: %s\nname: %s\nport: %s\nuser: %s\npass: %s\n", dbc.host, dbc.name, dbc.port, dbc.user, dbc.pass);

    return dbc;

}

#define takeRealNode(node)   node[strlen(node)-7] = 0;
#define charIsDigit(c) ('0' <= c && c <= '9')

#define zerujNode(size) for(int j=0; j<size;j++) node[j] = 0;

Tags* parseNodes(const char *nodes) {
    Tags* tags = (Tags*) malloc(sizeof(Tags));
    int tag_id = 0;
    int i, ni = 0, level = 0;
    int group = 0;
    char node[12];
    zerujNode(12);

    initTags(tags);
    for (i = 0; i < strlen(nodes); i++) {
        if (nodes[i] == '"' || nodes[i] == '\\' || nodes[i] == ' ')
            continue;
        if (nodes[i] == '{') {
            level++;
            continue;
        }
        if (nodes[i] == '}') {
            if (!charIsDigit(nodes[i - 1])) {
                group++;
            }
            if (ni > 0) {
//                takeRealNode(node);
                
                newTag.endNode = atoi(node)/10;
 //               printf("node: '%s' => '%d'\n", node, tag.endNode);
                zerujNode(ni);
                newTag.value = group;
                newTag.type = results;
                newTag.id = tag_id++;
                ni = 0;
            }
            level--;
            continue;
        }
        if (nodes[i] == ',') {
            if(ni>0){
//                takeRealNode(node);
                addTag(tags);
                newTag.beginNode = atoi(node)/10;
//                printf("node: '%s' => '%d'\n", node, tag.beginNode);
                zerujNode(ni);
                ni = 0;
            }
            continue;
        }
        if (charIsDigit(nodes[i])) {
            node[ni++] = nodes[i];
            continue;
        }
        fprintf(stderr, "Uknown char: %c\n", nodes[i]);

    }
    return tags;
}

void setTabletInfo(PGresult *result, int rowId, Tablet* tab) {
    const char* nodes;
    setFromResult(tab->id_cdli, rowId, T_ID_CDLI);
    setFromResult(tab->collection, rowId, T_COLLECTION);
    setFromResult(tab->genre, rowId, T_GENRE);
    setFromResult(tab->measurements, rowId, T_MEASUREMENTS);
    setFromResult(tab->period, rowId, T_PERIOD);
    setFromResult(tab->provenience, rowId, T_PROVENIENCE);
    setFromResult(tab->publication, rowId, T_PUBLICATION);
    setFromResult(tab->subgenre, rowId, T_SUBGENRE);
    setFromResult(tab->year, rowId, T_YEAR);
    tab->tags = NULL;
    setFromResult(tab->text, rowId, T_TEXT);
    setFromResult(nodes, rowId, T_NODES);
    //printf("%s\n\n", nodes);
    tab->tags = parseNodes(nodes);

//    for(int i = 0; i<tab->tags->count;i++){
//         printTag2(&tab->tags->tab[i], "info");
//    }

    //printf("\n\n %s \n\n", nodes);

}

Tablets *getTablets(char* query) {
    PGconn *psql;
    PGresult *result;
    db_config dbc = parseConfigFile();
    int size, i;
    Tablet* tabs;
    Tablets *retVal = (Tablets*) malloc(sizeof (Tablets));
    char conninfo[128];
    sprintf(conninfo, "host = '%s' port = '%s' dbname = '%s' user = '%s' password = '%s' connect_timeout = '10'",
            dbc.host, dbc.port, dbc.name, dbc.user, dbc.pass);


    psql = PQconnectdb(conninfo);
    /* init connection */
    if (!psql) {
        fprintf(stderr, "libpq error: PQconnectdb returned NULL.\n\n");
        exit(0);
    }
    if (PQstatus(psql) != CONNECTION_OK) {
        fprintf(stderr, "libpq error: PQstatus(psql) != CONNECTION_OK\n%s\n", PQerrorMessage(psql));
        exit(0);
    }



    result = PQexec(psql, query);
    //for (i = 0; i j; i++) { printf("Time: %s\n", PQgetvalue(result, i, 0)); printf("MD5: %s\n", PQgetvalue(result, i, 1)); } PQclear(result); if (argc > 1) { data_safe = pq_escape(argv[1]); result = pq_query("SELECT MD5('%s');", data_safe); if (!result || PQntuples(result)< 1) { fprintf(stderr, "libpq error: no results returned or NULL resultset pointer.\n\n"); PQfinish(psql); exit(0); } printf("data: %s (data safe: %s)\n", argv[0]); printf("MD5: %s\n", PQgetvalue(result, 0, 0));  }
    if (!result) {
        fprintf(stderr, "libpq error: no rows returned or bad result set\n\n");
        PQfinish(psql);
        exit(0);
    }
    if (!(size = PQntuples(result))) {
        PQfinish(psql);
        printf("\n%s\n", query);
        return NULL;
    }
    tabs = (Tablet*) malloc(size * sizeof (Tablet));

    for (i = 0; i < size; i++) {
        setTabletInfo(result, i, &tabs[i]);
    }

    PQclear(result);
    PQfinish(psql);

    retVal->size = size;
    retVal->tabs = tabs;
    return retVal;

}
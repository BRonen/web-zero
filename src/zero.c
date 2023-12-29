#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sqlite3.h>

sqlite3 **create_sqlite_ref(char *path)
{
    sqlite3 *db;
    sqlite3 **ref = malloc(sizeof(db));

    *ref = db;

    sqlite3_open(path, ref);

    return ref;
}

sqlite3 *deref_sqlite(sqlite3 **db)
{
    return *db;
}

void free_sqlite(sqlite3 *db)
{
    sqlite3_close(db);
}

char *concat_strings(char *str1, char *str2)
{
    char *str = malloc(strlen(str1) + strlen(str2));

    sprintf(str, "%s%s", str1, str2);

    return str;
}

typedef struct state_node {
    void **value;
    struct state_node *next;
};

void dump_query_state (struct state_node *resultRef)
{
    if(resultRef == NULL) {
        printf("\n<><><>\n");
        return;
    }

    while (resultRef != NULL) {
        printf("-> %x %x\n\n", resultRef, resultRef->next);
        // printf("->> %s\n\n", iter->value[0]);
        // printf("->>> %s\n\n", concat_strings(iter->value[1], ""));

        resultRef = resultRef->next;
    }
}

int sqlite_callback(struct state_node **tRef, int argc, void **argv, char **azColName)
{
    struct state_node* t = *tRef;
    struct state_node* result = malloc(sizeof(struct state_node));
    result->value = argv;
    result->next = NULL;

    printf("=> %s %s %x %x\n\n", argv[0], argv[1], result, result->next);
    
    if(*tRef == NULL) {
        *tRef = result;
        return 0;
    }

    while (t->next != NULL)
        t = t->next;

    t->next = result;

    return 0;
}

char *exec_query_sqlite(sqlite3 *db, char *query)
{
    char *zErrMsg = 0;

    struct state_node* result = NULL;

    dump_query_state(result);
    
    {
        int rc = sqlite3_exec(db, query, sqlite_callback, &result, &zErrMsg);
        if (rc != SQLITE_OK)
        {
            fprintf(stderr, "SQL error: %s\n", zErrMsg);
        }
    }

    dump_query_state(result);

    return " ";
}
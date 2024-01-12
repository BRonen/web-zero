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

void *deref(void **v)
{
    return *v;
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

typedef struct state_node
{
    void **value;
    struct state_node *next;
};

void dump_query_state(struct state_node *resultRef)
{
    if (resultRef == NULL)
    {
        printf("\n<><null><>\n\n");
        return;
    }

    while (resultRef != NULL)
    {
        char **argv = resultRef->value;

        printf(
            "<->> %p : %p :: %s : %s \n\n",
            argv,
            *argv,
            *argv,
            argv[1]);
        // printf("->> %s\n\n", iter->value[0]);
        // printf("->>> %s\n\n", concat_strings(iter->value[1], ""));

        resultRef = resultRef->next;
    }
}

int sqlite_callback(struct state_node **tRef, int argc, void **argv, char **azColName)
{
    printf("}}}}}} %d\n", argc);

    // creates a result list on the heap
    struct state_node *t = *tRef;
    struct state_node *result = malloc(sizeof(struct state_node));
    result->next = NULL;

    void **value = malloc(sizeof(void *) * argc);

    for (int i = 0; i < argc; i++)
    {
        printf("]]]]]] %s %s\n", (char *)*(argv + i), *(azColName + i));

        // copies the value of the column to heap and puts on the result
        char *u = malloc(sizeof(char) * strlen(argv[i]));
        strcpy(u, argv[i]);
        value[i] = u;
    }

    result->value = value;

    printf("\n===> %s %s %p %p\n\n", (char *)*value, (char *)*(value + 1), result, result->next);

    if (*tRef == NULL)
    {
        *tRef = result;
        return 0;
    }

    while (t->next != NULL)
        t = t->next;

    t->next = result;

    return 0;
}

struct state_node *exec_query_sqlite(sqlite3 *db, char *query)
{
    char *zErrMsg = 0;

    struct state_node *result = NULL;

    dump_query_state(result);

    int rc = sqlite3_exec(db, query, sqlite_callback, &result, &zErrMsg);
    if (rc != SQLITE_OK)
        fprintf(stderr, "SQL error: %s\n", zErrMsg);

    dump_query_state(result);

    return result;
}

char *get_column_string(int i, struct state_node v)
{
    dump_query_state(&v);
    printf("\n%s <> %s <> %d\n", v.value[0], v.value[1], i);

    return v.value[i];
}

struct state_node *get_next_row(struct state_node v)
{
    printf("\n>>> %p <> %s\n", &v, v.value[1]);
    printf("\n>>> %p\n", (&v)->next);
    if(v.next == NULL) return NULL;
    // dump_query_state(v.next);
    // printf("\n>>> %s <> %s <> %d\n", v.next->value[0], v.next->value[1]);

    return NULL;
}

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

char* concat_strings (char* str1, char* str2) {
    char* str = malloc(strlen(str1) + strlen(str2));

    sprintf(str, "%s%s", str1, str2);
    
    return str;
}

typedef struct query_state {
    char* value;
    struct query_state* next;
};

int sqlite_callback(struct query_state *result, int argc, char **argv, char **azColName)
{
    for (int i = 0; i < argc; i++)
        result->value = concat_strings(argv[1], "");

    return 0;
}

char* exec_query_sqlite(sqlite3 *db)
{
    char *zErrMsg = 0;

    struct query_state result = { "", NULL };

    int rc = sqlite3_exec(db, "SELECT * FROM users;", sqlite_callback, &result, &zErrMsg);
    if (rc != SQLITE_OK)
    {
        fprintf(stderr, "SQL error: %s\n", zErrMsg);
    }

    return result.value;
}
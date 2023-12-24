#include <stdlib.h>
#include <stdio.h>
#include <sqlite3.h>

static int callback(void *NotUsed, int argc, char **argv, char **azColName){
    int i;
    for(i=0; i<argc; i++){
      printf("%s = %s\n", azColName[i], argv[i] ? argv[i] : "NULL");
    }
    printf("\n");
    return 0;
}

static int** allocVoidPtr () {
    int* valueRef = malloc( sizeof( int* ) );
    int** memRef = malloc( sizeof( int** ) );
    *memRef = valueRef;
    return memRef;
}

static void* deref (void** ref) {
    return *ref;
}

void aaa () {
    printf("hello world\n");
    return;
}

int main () {
    aaa();

    sqlite3* db;

    sqlite3_open("db.sqlite3", &db);

    sqlite3_close(db);
    return 0;
}

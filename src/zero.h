#include <stdlib.h>
#include <stdio.h>

static int callback(void *NotUsed, int argc, char **argv, char **azColName){
    int i;
    for(i=0; i<argc; i++){
      printf("%s = %s\n", azColName[i], argv[i] ? argv[i] : "NULL");
    }
    printf("\n");
    return 0;
}

int** allocVoidPtr () {
    int* valueRef = malloc( sizeof( int* ) );
    int** memRef = malloc( sizeof( int** ) );
    *memRef = valueRef;
    return memRef;
}

void* deref (void** ref) {
    return *ref;
}
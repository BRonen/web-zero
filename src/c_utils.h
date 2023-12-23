#include <stdlib.h>

void** allocVoidPtr () {
    return &malloc( sizeof( void* ) );
}
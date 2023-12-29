#include <sqlite3.h>
#include "../src/zero.c"

int main() {
    struct state_node result1 = {0, NULL};
    struct state_node result2 = {0, &result1};
    struct state_node result3 = {0, &result2};
    struct state_node result4 = {0, &result3};
    struct state_node result5 = {0, &result4};
    struct state_node result6 = {0, &result5};

    dump_query_state(&result6);

    dump_query_state(NULL);

    struct state_node* result = NULL;
    char* param = "test";

    printf("\n======\n");
    dump_query_state(result);
    sqlite_callback(&result, 0, &param, &param);
    sqlite_callback(&result, 0, &param, &param);
    sqlite_callback(&result, 0, &param, &param);
    sqlite_callback(&result, 0, &param, &param);
    dump_query_state(result);

    char* a = get_column_string(0, *result);

    printf("<<< %s >>>\n", a);

    return 0;
}
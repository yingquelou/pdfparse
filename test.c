#include <stdio.h>
#include <stdlib.h>
int main(int argc, char const *argv[])
{
    char str[] = "1234 3452", *pos;
    printf("%d\n", strtoll(str, NULL, 10));
    return 0;
}

#include <stdlib.h>
#include "pdf.h"
void *print(void *obj, void *arg)
{
    // fprintf(stderr, "%p\n", obj);
    PdWriteObj(arg, obj);
    PdObjDestroy(obj);
    return 0;
}
int main(int argc, char const *argv[])
{
    FILE *f = fopen("log.txt", "w");
    ListD list = pdEngin("E:\\desktop\\test.pdf", "E:\\code\\pythonProjects\\conanTest\\rest.txt");
    listDestroy(list, print, f);
    fclose(f);
    return 0;
}

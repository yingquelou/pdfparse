#include <stdlib.h>
#include "pdf.h"
int print(void *obj, void *arg)
{
    PdObj obj2=(PdObj)obj;
    fprintf((FILE*)arg,"%d\n", obj2->typeInfo);
    PdObjDestroy(obj2);
    return 0;
}
int main(int argc, char const *argv[])
{
    FILE *f = fopen("log.txt", "w");
    ListD list = pdEngin("E:\\desktop\\matlab_ref_zh_CN.pdf", "E:\\code\\pythonProjects\\conanTest\\rest.txt");
    listDestroy(list, print, f);
    fclose(f);
    return 0;
}

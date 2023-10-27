#include <stdlib.h>
#include "pdf.h"

extern int pdfdebug;
void *print(void *obj, void *arg)
{
    PdWriteObj(arg, obj);
    // PdObj obj2 = (PdObj)obj;
    // fprintf(arg, "%d", obj2->typeInfo);
    // if (obj2->typeInfo == pdTypeIndirectObj)
    // {
    //     PdIndirectObj iobj = (PdIndirectObj)(obj2->obj);
    //     fprintf(arg, "\t%d\t%d", iobj->id, iobj->id);
    // }
    fprintf(arg, "\n");
    PdObjDestroy(obj);
    return 0;
}
#include <string.h>
#include <cjson/cJSON.h>
int main(int argc, char const *argv[])
{
    char buffer[4096];
    // pdfdebug = 1;
    freopen("error.txt", "w", stderr);
    setvbuf(stderr, buffer, _IOFBF, 4096);
    // setvbuf(stderr, NULL, _IONBF, 0);
    FILE *f = fopen("log.txt", "wb");
    // setvbuf(f, NULL, _IONBF, 0);
    ListD list = pdEngin("E:\\desktop\\tmp.b", "rest.txt");
    // ListD list = pdEngin("E:\\code\\cPojects\\pdfengine\\test.txt", "rest.txt");
    listDestroy(list, print, f);
    fclose(f);
    cJSON_CreateFalse();
    fclose(stderr);
    fread()
    return 0;
}

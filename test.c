#include <stdio.h>
#define DEBUG
#ifdef DEBUG
#include "Pdf/lex.yy.c"
#else
#include "PdType.h"
#include "PdParse.h"
#endif
void printType(FILE *out, PdTypeInfo info)
{
    switch (info)
    {
    case pdTypeBoolean:
        fputs("PdTypeBoolean\n", out);
        break;
    case pdTypeInteger:
        fputs("pdTypeInteger\n", out);
        break;
    case pdTypeReal:
        fputs("pdTypeReal\n", out);
        break;
    case pdTypeString:
        fputs("pdTypeString\n", out);
        break;
    case pdTypeName:
        fputs("pdTypeName\n", out);
        break;
    case pdTypeArray:
        fputs("pdTypeArray\n", out);
        break;
    case pdTypeDictionary:
        fputs("pdTypeDictionary\n", out);
        break;
    case pdTypeStream:
        fputs("pdTypeStream\n", out);
        break;
    case pdTypeObjsXrefNum:
        fputs("pdTypeObjsXrefNum\n", out);
        break;
    case pdOperateLA:
        fputs("pdOperateLA\n", out);
        break;
    case pdOperateRA:
        fputs("pdOperateRA\n", out);
        break;
    case pdOperateLD:
        fputs("pdOperateLD\n", out);
        break;
    case pdOperateRD:
        fputs("pdOperateRD\n", out);
        break;
    default:
        break;
    }
}
void *print(void *item)
{
    PdObj obj = (PdObj)item;
    printType(stderr, obj->typeInfo);
    free(obj->obj);
    free(item);
}
int main(int argc, char const *argv[])
{
    StackL stack = pdfParse("E:\\code\\pythonProjects\\conanTest\\test.txt");
    StackLForeach(&stack, print);
    StackLDestroy(&stack);
    return 0;
}

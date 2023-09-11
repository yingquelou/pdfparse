#include <stdio.h>
#define DEBUG
#ifdef DEBUG
#include"Pdf/lex.yy.c"
#else
#include "PdType.h"
#include "PdParse.h"
#endif
void* print(void*item){
    PdObj obj=(PdObj)item;
    fprintf(stderr,"%d\n",obj->typeInfo);
}
int main(int argc, char const *argv[])
{
    StackL stack = pdfParse("E:\\code\\pythonProjects\\conanTest\\test.txt");
    StackLForeach(&stack, print);
    StackLDestroy(&stack);
    puts("sfsd");
    return 0;
}

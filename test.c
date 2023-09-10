#include <stdio.h>
#include "PdParse.h"
#include "Stack.h"
#include "PdType.h"
void* print(void*item){
    PdObj obj=(PdObj)item;
    printf("%d\n",obj->typeInfo);
}
int main(int argc, char const *argv[])
{
    puts("sfsd");
    StackL stack = pdfParse("E:\\code\\pythonProjects\\conanTest\\test.txt");
    StackLForeach(&stack, print);
    return 0;
}

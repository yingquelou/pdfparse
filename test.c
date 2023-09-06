#include"lex.yy.c" 
#include"y.tab.c"
#include <stdlib.h>
#include <stdio.h>
extern int yyparse();
  
int main(int argc, char* argv[]){
    extern FILE *yyin;
    if((yyin=fopen("test.txt","r"))==NULL){
       perror("无法打开文件test.txt\n") ;
       exit(1);
    }
    if (yyparse()==1){
        fprintf(stderr,"parser error\n");
        exit(1);
    }
    printf("yyparse() completed successfully!\n");
    return 0;
}

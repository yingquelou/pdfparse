%{
int yyerror(char *s);
#include "PdType.h"
#ifndef DEBUG 
#include "List/listd.c"
#else
#include "listd.h"
#endif
#include "lex.yy.c"
#include<stdio.h>
int print(void *x, void *y)
{
    PdObj obj = (PdObj)x;
    printf("$d\t",obj->typeInfo);
    return 0;
}
%}
%union{
    PdBoolean boolean;
    PdInteger integer;
    PdReal real;
    PdString string;
    PdName name;
    ListD list;
    PdObj obj;
}
%token <boolean> BOOLEAN
%token <integer> INTEGER
%token <real> REAL
%token <string> STRING
%token <name> NAME
%token LD RD PDNULL
%type <list> OBJLIST ARRAY ENTRYSET DICTIONARY
%type <obj> KEY OBJ BASEOBJ

%% 
test:OBJLIST{
 listDForEach($1,print,NULL);
};
OBJLIST: {$$=listDCreate();}
|OBJLIST OBJ {$$=listDPushBack($1,$2);}
;
OBJ:KEY {$$=$1;}
|PDNULL {$$=pdnull;}
;
ARRAY: '[' OBJLIST ']' {$$=$2;}
        ;
DICTIONARY: LD ENTRYSET RD {
    $$=$2;
}
;
ENTRYSET:{$$=listDCreate();}
|ENTRYSET KEY OBJ {
    PdDictionaryEntry entry=malloc(sizeof(pdDictionaryEntry));
    entry->key=$2;
    entry->value=$3;
    $$=listDPushBack($1,entry);
}
;
KEY:BASEOBJ 
|ARRAY{
$$=malloc(sizeof(pdObj));
$$->typeInfo=pdTypeArray;
$$->obj=$1;
}
|DICTIONARY{
$$=malloc(sizeof(pdObj));
$$->typeInfo=pdTypeDictionary;
$$->obj=$1;
}
;
BASEOBJ :BOOLEAN {
$$=malloc(sizeof(pdObj));
$$->typeInfo=pdTypeBoolean;
$$->obj=$1;
}
|INTEGER{
$$=malloc(sizeof(pdObj));
$$->typeInfo=pdTypeInteger;
$$->obj=$1;
}
|REAL{
$$=malloc(sizeof(pdObj));
$$->typeInfo=pdTypeReal;
$$->obj=$1;
}
|STRING{
$$=malloc(sizeof(pdObj));
$$->typeInfo=pdTypeString;
$$->obj=$1;
}
|NAME{
$$=malloc(sizeof(pdObj));
$$->typeInfo=pdTypeName;
$$->obj=$1;
}
;
%%

int yyerror(char *s)
{
    fprintf(stderr,"error:%s\n",s);
    return 0; 
}       
int main(int argc, char const *argv[])
{
    yyin=fopen("E:\\code\\pythonProjects\\conanTest\\rest.txt","rb");
  yyparse();
  return 0;
}

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
extern int yydebug;
int print(void*,void*);
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
%start test
%% 
test: OBJLIST {listDForEach($1,print,NULL);};

OBJLIST: {$$=pdnull;}
|OBJLIST OBJ {$$=listDPushBack($1,$2);}
;

OBJ:PDNULL {$$=pdnull;}
|KEY {$$=$1;}
; 
KEY:BASEOBJ {$$=$1;}
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
ARRAY: '[' OBJLIST ']' {$$=$2;}
        ;

DICTIONARY: LD ENTRYSET RD {
    $$=$2;
}
;
ENTRYSET:{$$=pdnull;}
|ENTRYSET KEY OBJ {
    PdDictionaryEntry entry=malloc(sizeof(pdDictionaryEntry));
    entry->key=$2;
    entry->value=$3;
    $$=listDPushBack($1,entry);
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
    yydebug=1;
    yyin=fopen("E:\\code\\pythonProjects\\conanTest\\test.txt","rb");
    yyout=fopen("E:\\code\\pythonProjects\\conanTest\\rest.txt","w");
    yyparse();
    return 0;
}
int print(void*x,void*y){
    if(x)
 fprintf(yyout,"%d\n",((PdObj)x)->typeInfo);
 else
 fprintf(yyout,"null\n");
 return 0;
}
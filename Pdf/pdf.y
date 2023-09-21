%{
int yyerror(char *s);
#include "..\\Pdocument.h"
#ifndef DEBUG 
#include "..\\List\\listd.c"
#else
#include "listd.h"
#endif
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
    PdIndirectObj indirectObj;
    struct {long long first;long long second;}objnum;
}
%token <boolean> BOOLEAN
%token <integer> INTEGER
%token <real> REAL
%token <string> STRING
%token <name> NAME
%token <objnum> OBJ INDIRECTOBJREF
%token LD RD PDNULL ENDOBJ
%type <list> OBJLIST ARRAY ENTRYSET DICTIONARY
%type <obj> KEY OBJREF BASEOBJ
%type <indirectObj> INDIRECTOBJ
%start test
%% 
test: OBJLIST {listDForEach($1,print,NULL);};

OBJLIST: {$$=pdnull;}
|OBJLIST OBJREF {$$=listDPushBack($1,$2);}
;

OBJREF:PDNULL {$$=pdnull;}
|KEY {$$=$1;}
|INDIRECTOBJ{
$$=malloc(sizeof(pdObj));
$$->typeInfo=pdTypeIndirectObj;
$$->obj=$1;
}
; 
KEY:BASEOBJ {$$=$1;}
|INDIRECTOBJREF{
$$=malloc(sizeof(pdObj));
$$->typeInfo=pdTypeIndirectObjRef;
pdIndirectObjRef*ref=malloc(sizeof(pdIndirectObjRef));
ref->id=$1.first;
ref->generation=$1.second;
$$->obj=ref;
}
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
|ENTRYSET KEY OBJREF {
    PdDictionaryEntry entry=malloc(sizeof(pdDictionaryEntry));
    entry->key=$2;
    entry->value=$3;
    $$=listDPushBack($1,entry);
}
;

INDIRECTOBJ:OBJ[num] OBJLIST[objList] ENDOBJ {
    $$=malloc(sizeof(pdIndirectObj));
    $$->id=$num.first;
    $$->generation=$num.second;
    $$->objList=$objList;
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
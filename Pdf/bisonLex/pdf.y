%{
int yyerror(char *s);
#include "Pdocument.h"
#include "listd.h"
#include <stdio.h>
//extern int yydebug;
extern long long pos;
ListD finalList=NULL;
static FILE*report=NULL;
%}
//%debug

%union{
    PdBoolean boolean;
    PdInteger integer;
    PdReal real;
    PdString string;
    PdXString xstring;
    PdStream stream;
    PdName name;
    ListD list;
    PdObj obj;
    PdXrefSubsection subXref;
    PdIndirectObj indirectObj;
    struct {long long first;long long second;}objnum;
}
%token <boolean> BOOLEAN
%token <integer> INTEGER
%token <real> REAL
%token <string> STRING 
%token <stream> ENDSTREAM
%token <xstring> XSTRING
%token <name> NAME
%token <objnum> OBJ INDIRECTOBJREF NXREFENTRY FXREFENTRY SUBXREFHEAD
%token LD RD PDNULL ENDOBJ STREAM XREF TRAILER STARTXREF
%type <list> OBJLIST ARRAY ENTRYSET DICTIONARY SUBXREFLIST SUBXREFENTRYLIST XREFOBJ
%type <obj> KEY OBJREF BASEOBJ
%type <subXref> SUBXREF
%type <indirectObj> INDIRECTOBJ
%start test
%% 
test: OBJLIST {
report=fopen("E:\\code\\pythonProjects\\conanTest\\report.txt","w");
finalList=$1;
};

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
|XREFOBJ{
$$=malloc(sizeof(pdObj));
$$->typeInfo=pdocXref;
$$->obj=$1;
}
|STREAM ENDSTREAM {
$$=malloc(sizeof(pdObj));
$$->typeInfo=pdTypeStream;
$$->obj=$2;
}
|TRAILER DICTIONARY {
$$=malloc(sizeof(pdObj));
$$->typeInfo=pdocTrailer;
$$->obj=$2;
}
|STARTXREF INTEGER {
$$=malloc(sizeof(pdObj));
$$->typeInfo=pdocStartXref;
$$->obj=$2;
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
|XSTRING{
$$=malloc(sizeof(pdObj));
$$->typeInfo=pdTypeXString;
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
XREFOBJ:XREF SUBXREFLIST{
    $$=$2;
};

SUBXREFLIST:{$$=pdnull;}
|SUBXREFLIST SUBXREF{$$=listDPushBack($1,$2);};

SUBXREF:SUBXREFHEAD SUBXREFENTRYLIST{
    $$=malloc(sizeof(pdXrefSubsection));
    $$->startNum=$1.first;
    $$->length=$1.second;
    $$->Entries=$2;
};
SUBXREFENTRYLIST:{$$=pdnull;}
|SUBXREFENTRYLIST FXREFENTRY{
PdXrefEntry entry= malloc(sizeof(pdXrefEntry));
entry->offset=$2.first;
entry->generation=$2.second;
entry->free='f';
$$=listDPushBack($1,entry);
}
|SUBXREFENTRYLIST NXREFENTRY{
PdXrefEntry entry= malloc(sizeof(pdXrefEntry));
entry->offset=$2.first;
entry->generation=$2.second;
entry->free='n';
$$=listDPushBack($1,entry);
}
;
%%

int yyerror(char *s)
{
    fprintf(stderr,"error:%s->%d\n",s,pos);
    return 0; 
}       

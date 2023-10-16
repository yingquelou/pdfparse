%{
int yyerror(char *s);
#include "Pdocument.h"
#include "listd.h"
#include <stdio.h>
//extern int yydebug;
extern long long pos;
ListD finalList=NULL;
char **initCacheIndex();
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
%type <list> OBJLIST ARRAY LIST ENTRYSET DICTIONARY SUBXREFLIST SUBXREFENTRYLIST XREFOBJ
%type <obj> KEY OBJREF BASEOBJ
%type <subXref> SUBXREF
%type <indirectObj> INDIRECTOBJ
%start main
%% 
main: OBJLIST {
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
ARRAY: '[' LIST ']' {$$=$2;}
        ;

LIST: {$$=pdnull;}
|LIST OBJREF {$$=listDPushBack($1,$2);}
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

INDIRECTOBJ:OBJ[num] LIST[objList] ENDOBJ {
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
    fprintf(stderr,"###error:%s->%lld###\n",s,pos);
    return 0; 
}       
#include <path.h>
static char *prefix = NULL;
static PdTypeInfo infoArr[] = {pdTypeBoolean,
                               pdTypeInteger,
                               pdTypeReal,
                               pdTypeString,
                               pdTypeXString,
                               pdTypeStream,
                               pdTypeName,
                               // 复合类型

                               pdTypeArray,
                               pdTypeDictionary,
                               pdTypeIndirectObjRef,

                               // pdTypeObjsXrefNum,

                               /* pdf文档子结构 */
                               pdTypeIndirectObj,
                               pdocXref,
                               pdocXrefSubsection,
                               pdocXrefEntry,
                               pdocTrailer,
                               pdocStartXref};
static size_t IndexLength = sizeof(infoArr) / sizeof(PdTypeInfo);
static char **pdTyeCount()
{
    return malloc(sizeof(char *) * IndexLength);
}
static void singleIndex(char **arr, PdTypeInfo info)
{
    switch (info)
    {
    case pdTypeBoolean:
        arr[info] = createPath(prefix, "pdTypeBoolean");
        break;
    case pdTypeInteger:
        arr[info] = createPath(prefix, "pdTypeInteger");
        break;
    case pdTypeReal:
        arr[info] = createPath(prefix, "pdTypeReal");
        break;
    case pdTypeString:
        arr[info] = createPath(prefix, "pdTypeString");
        break;
    case pdTypeXString:
        arr[info] = createPath(prefix, "pdTypeXString");
        break;
    case pdTypeStream:
        arr[info] = createPath(prefix, "pdTypeStream");
        break;
    case pdTypeName:
        arr[info] = createPath(prefix, "pdTypeName");
        break;
    case pdTypeArray:
        arr[info] = createPath(prefix, "pdTypeArray");
        break;
    case pdTypeDictionary:
        arr[info] = createPath(prefix, "pdTypeDictionary");
        break;
    case pdocXrefSubsection:
        arr[info] = createPath(prefix, "pdocXrefSubsection");
        break;
    case pdocXrefEntry:
        arr[info] = createPath(prefix, "pdocXrefEntry");
        break;
    case pdTypeIndirectObjRef:
        arr[info] = createPath(prefix, "pdTypeIndirectObjRef");
        break;
    case pdTypeIndirectObj:
        arr[info] = createPath(prefix, "pdTypeIndirectObj");
        break;
    case pdocXref:
        arr[info] = createPath(prefix, "pdocXref");
        break;
    case pdocTrailer:
        arr[info] = createPath(prefix, "pdocTrailer");
        break;
    case pdocStartXref:
        arr[info] = createPath(prefix, "pdocStartXref");
        break;
    default:
        perror("undefined type");
        break;
    }
}
char **initCacheIndex()
{
    char *tmp = getCurrent_path();
    prefix = createPath(tmp, "cache");
    free(tmp);
    char **arr = pdTyeCount();
    for (size_t i = 0; i < IndexLength; ++i)
        singleIndex(arr, infoArr[i]);
    return arr;
}

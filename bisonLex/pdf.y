%{
#include<cjson/cJSON.h>
#include"lex.yy.h"
cJSON *cJSON_ConvertArrayToObject(cJSON *);
cJSON *pdfObjOfJsonCache=NULL;
int n=0;
char name[FILENAME_MAX];
int yyerror(char *);
%}

%union{
    cJSON *obj;
}
// 基本对象
%token <obj> PDNULL BOOLEAN INTEGER REAL STRING XSTRING NAME
// 复合对象
%type <obj> DICTIONARY ARRAY
// 标记符1
%token STREAM ENDOBJ LD RD XREF TRAILER STARTXREF
// 标记符2
%token <obj> ENDSTREAM OBJ
// 文档结构
%type <obj> INDIRECTOBJ XREFTABELS
// 辅助构建1
%token <obj> INDIRECTOBJREF NXREFENTRY FXREFENTRY SUBXREFHEAD
// 辅助构建2
%type <obj> LIST ENTRYSET SUBXREFLIST SUBXREFENTRYLIST KEY OBJREF BASEOBJ SUBXREF

%start main
%% 
main: OBJLIST {
    char *buffer = cJSON_Print(pdfObjOfJsonCache);
    FILE*dest=fopen("path.json","wb");
    fputs(buffer,dest);
    free(buffer);
    fclose(dest);
    cJSON_Delete(pdfObjOfJsonCache);
};

OBJLIST:
|OBJLIST OBJREF {
    char *buffer = cJSON_Print($2);
    if(cJSON_IsObject($2)){
    if (cJSON_HasObjectItem($2,"id"))
    {
      cJSON*id = cJSON_GetObjectItem($2,"id");
      sprintf(name,"%s/%sobj%s.json",cJSON_GetStringValue(cJSON_GetObjectItem(pdfObjOfJsonCache,"obj")),cJSON_GetStringValue(cJSON_GetArrayItem(id,0)),cJSON_GetStringValue(cJSON_GetArrayItem(id,1)));
    }
    else if(cJSON_HasObjectItem($2,"xref")){
      sprintf(name,"%s/%d.json",cJSON_GetStringValue(cJSON_GetObjectItem(pdfObjOfJsonCache,"xref")),n++);
    }
    else if(cJSON_HasObjectItem($2,"startxref")){
      cJSON*startxref = cJSON_GetObjectItem($2,"startxref");
      sprintf(name,"%s/%s.json",cJSON_GetStringValue(cJSON_GetObjectItem(pdfObjOfJsonCache,"startxref")),cJSON_GetStringValue((startxref)));
    }
    else if(cJSON_HasObjectItem($2,"trailer")){
      sprintf(name,"%s/%d.json",cJSON_GetStringValue(cJSON_GetObjectItem(pdfObjOfJsonCache,"trailer")),n++);
    }
    }
    else{
      sprintf(name,"%s/%d.json",cJSON_GetStringValue(cJSON_GetObjectItem(pdfObjOfJsonCache,"others")),n++);
    }
    FILE*dest=fopen(name,"wb");
    fputs(buffer,dest);
    free(buffer);
    fclose(dest);
    cJSON_Delete($2);
    }
;

OBJREF:PDNULL {
    $$=cJSON_CreateNull();
}
|KEY
|INDIRECTOBJ
|XREFTABELS
|STREAM ENDSTREAM {$$=$2;}
|TRAILER DICTIONARY {
  $$=cJSON_CreateObject();
  cJSON_AddItemToObject($$,"trailer",$2);
}
|STARTXREF INTEGER {
  $$=cJSON_CreateObject();
  cJSON_AddItemToObject($$,"startxref",$2);
}
; 
KEY:BASEOBJ
|INDIRECTOBJREF
|ARRAY
|DICTIONARY
;

BASEOBJ :BOOLEAN
|INTEGER
|REAL
|STRING
|XSTRING
|NAME
;
ARRAY: '[' LIST ']' {$$=$2;}
        ;

LIST: {$$=cJSON_CreateArray();}
|LIST OBJREF {cJSON_AddItemToArray($1,$2);$$=$1;}
;

DICTIONARY: LD ENTRYSET RD {
    $$=cJSON_ConvertArrayToObject($2);
    if(cJSON_GetArraySize($2)==0)
      cJSON_Delete($2);
}
;
ENTRYSET:{$$=cJSON_CreateArray();}
|ENTRYSET KEY OBJREF {
cJSON_AddItemToArray($1,$2);
cJSON_AddItemToArray($1,$3);
$$=$1;
}
;

INDIRECTOBJ:OBJ[num] LIST[objList] ENDOBJ {
    $$=cJSON_CreateObject();
    cJSON_AddItemToObject($$,"id",$num);
    cJSON_AddItemToObject($$,"body",$objList);
};

XREFTABELS:XREF SUBXREFLIST{
  $$=cJSON_CreateObject();
  cJSON_AddItemToObject($$,"xref",$2);
};

SUBXREFLIST:{$$=cJSON_CreateArray();}
|SUBXREFLIST SUBXREF{
    cJSON_AddItemToArray($1,$2);
    $$=$1;
};

SUBXREF:SUBXREFHEAD SUBXREFENTRYLIST{
$$=cJSON_CreateObject();
cJSON_AddItemToObject($$,"size",$1);
cJSON_AddItemToObject($$,"body",$2);
};
SUBXREFENTRYLIST:{$$=cJSON_CreateArray();}
|SUBXREFENTRYLIST FXREFENTRY{
cJSON_AddItemToArray($1,$2);
$$=$1;
}
|SUBXREFENTRYLIST NXREFENTRY{
cJSON_AddItemToArray($1,$2);
$$=$1;
}
;
%%

int yyerror(char *s)
{
    perror(s);
    return 0; 
}       
cJSON *cJSON_ConvertArrayToObject(cJSON *item)
{
    if (cJSON_IsArray(item))
    {
        int sz = cJSON_GetArraySize(item);
        if (sz <= 0 || sz % 2)
            return item;
        for (int i = 0; i < sz; i += 2)
        {
            if (cJSON_IsString(cJSON_GetArrayItem(item, i)))
                continue;
            else
                return item;
        }
        cJSON *obj = cJSON_CreateObject();
        cJSON *key, *value;
        while (key = cJSON_DetachItemFromArray(item, 0))
        {
            value = cJSON_DetachItemFromArray(item, 0);
            cJSON_AddItemToObject(obj,cJSON_GetStringValue(key),value);
        }
        return obj;
    }
    else
        return item;
}
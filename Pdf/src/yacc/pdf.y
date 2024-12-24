%{
#include "pdf.config.h"
#include <iostream>
%}
%no-lines
//%debug
/* %parse-param {int isSplit} */
/* %parse-param {const char*savaAsJson} */
/* %glr-parser */
/* %skeleton "lalr1.cc"  */
%language "c++"
%define api.token.constructor
%define api.value.type variant
/* %define parse.assert */
%code top {
}
/* %skeleton "glr.c" */
/* %destructor {json_decref($$);} <obj>  */
%token <bool> FALSE_ TRUE_
%token <std::string> STRING XSTRING NAME 
%token PDNULL ENDSTREAM
%token <PdObjNum> OBJ R
%token <double> REAL
%token <signed long long> INTEGER
/* 关键字 */
%token LD RD ENDOBJ STREAM XREF TRAILER STARTXREF La Ra
%type stream subXref pDocument pdSection  trailer startxref xref  
%type <PdObj> pdObj 
%type <PdArray> array objs
%type <PdDict> dict
%type <Object> obj
%type  subXrefEntry dictEntries
%left F N
%start pdf

%%
pdf: pDocument {
};

pDocument:
|pDocument pdSection {
};

pdSection: pdObj 
|xref
|trailer
|startxref
;

xref:XREF subXref {
};

subXref:
subXref subXrefEntry {
}
|INTEGER INTEGER {
};

subXrefEntry:
INTEGER INTEGER F {}
|INTEGER INTEGER N {}
|INTEGER INTEGER {}
;

startxref: STARTXREF INTEGER {}
;

pdObj: OBJ objs ENDOBJ {
};

trailer:
TRAILER dict {};

obj:PDNULL {
    $$.none=nullptr;
}
|stream {

}
|R {
    $$.ref=$1;
}
|array {
    $$.array=$1;
}
|dict {
    $$.dict=$1;
}
|TRUE_ {
    $$.b=1;
}
|FALSE_ {
    $$.b=0;
}
|INTEGER{
    $$.sll=$1;
}
|REAL {
    $$.d=$1;
}
|STRING {
}
|XSTRING
|NAME{
}
;

stream:STREAM ENDSTREAM{};

array: La objs Ra {};


dict: LD dictEntries RD {}
;

dictEntries: {}
|dictEntries NAME obj {
};

objs:{}
|objs obj {
};
%%
void yy::parser::error(const std::string&msg){

}
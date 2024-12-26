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
%token <Json::Value> FALSE_ TRUE_ NAT
%token <Json::Value> STRING XSTRING NAME 
%token <Json::Value> OBJ R STREAM 
%token <Json::Value> INTEGER PDNULL REAL
/* 关键字 */
%token LD RD ENDOBJ  XREF TRAILER STARTXREF La Ra
%type <Json::Value> subXref xref pdSection xrefs
%type <Json::Value> pDocument trailer startxref 
%type <Json::Value> pdObj array objs dict obj dictEntries subXrefEntry
%left F N
%start pdf

%%
pdf: pDocument {
};

pDocument:
|pDocument pdSection ;

pdSection: pdObj 
|xref{
    std::cout<<$1;
}
|trailer
|startxref
;

xref:XREF xrefs {
    $$=$2;
};
xrefs:
|xrefs subXref{
    $1.append($2);
    $$=std::move($1);
};

subXref:
subXref subXrefEntry {
    $1.append($2);
    $$=std::move($1);
}
|NAT NAT {
  Json::Value v;
  auto &header=  v["header"];
  header.append($1);
  header.append($2);
  $$.append(v);
};

subXrefEntry:
NAT NAT F {
auto &f=  $$["f"];
f.append($1);
f.append($2);
}
|NAT NAT N {
auto &n=  $$["n"];
n.append($1);
n.append($2);
}
|NAT NAT {
  auto &header=  $$["header"];
  header.append($1);
  header.append($2);
}
;

startxref: STARTXREF INTEGER {}
;

pdObj: OBJ objs ENDOBJ {
    $1["body"]=$2;
    $$=std::move($1);
};

trailer:
TRAILER dict {};

obj:PDNULL 
|STREAM
|R 
|array 
|dict
|TRUE_ 
|FALSE_ 
|INTEGER
|REAL 
|STRING 
|XSTRING
|NAME
;

array: La objs Ra {$$=std::move($2);};

dict: LD dictEntries RD {$$=std::move($2);};

dictEntries: 
|dictEntries NAME obj {
    $1[$2.asString()]=$3;
    $$=std::move($1);
};

objs: {}
|objs obj {
    $1.append($2);
    $$=std::move($1);
};
%%
void yy::parser::error(const std::string&msg){
std::cerr<<msg;
}
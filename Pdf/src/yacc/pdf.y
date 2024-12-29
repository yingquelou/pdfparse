%{
#include "pdf.config.h"
#include <iostream>
#include <fstream>
extern std::size_t num,gen;
extern std::size_t f_index;
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
%token <Json::Value> FALSE_ TRUE_
%token <Json::Value> STRING XSTRING NAME 
%token <Json::Value> OBJ R F N HEADER STREAM
%token <Json::Value> INTEGER PDNULL REAL
/* 关键字 */
%token LD RD ENDOBJ  XREF TRAILER STARTXREF La Ra
%type <Json::Value> subXref xref pdSection xrefs 
%type <Json::Value> pDocument trailer startxref subXrefEntries
%type <Json::Value> pdObj array objs dict obj dictEntries subXrefEntry
%start pdf

%%
pdf: pDocument {};

pDocument:
|pDocument pdSection {
    // std::cout<<$2;
};

pdSection: pdObj {
    $$=$1;

    std::stringstream ss;
    ss<<"obj_"<< num<<'_'<<gen<<'_'<<f_index++<<".json";
    std::ofstream ofs(ss.str(),std::ofstream::binary);
    ofs<<$$;
}
|xref {
    $$=$1;

    std::stringstream ss;
    ss<<"xref_"<<f_index++<<".json";
    std::ofstream ofs(ss.str(),std::ofstream::binary);
    ofs<<$$;
}
|trailer {
    $$=$1;

    std::stringstream ss;
    ss<<"trailer_"<<f_index++<<".json";
    std::ofstream ofs(ss.str(),std::ofstream::binary);
    ofs<<$$;
}
|startxref{
    $$=$1;

    std::stringstream ss;
    ss<<"startxref_"<<f_index++<<".json";
    std::ofstream ofs(ss.str(),std::ofstream::binary);
    ofs<<$$;
};

xref:XREF xrefs {
    $$=$2;
};
xrefs:
|xrefs subXref{
    $1.append($2);
    $$=std::move($1);
};

subXref:
HEADER subXrefEntries {
    $$["header"]=$1;
    $$["body"]=$2;
};

subXrefEntries:
|subXrefEntries subXrefEntry {
$1.append($2);
$$=std::move($1);
};

subXrefEntry:F 
|N;

startxref: STARTXREF INTEGER {$$["startxref"]=$2;};

pdObj: OBJ objs ENDOBJ {
    $1["body"]=$2;
    $$=std::move($1);
};

trailer:
TRAILER dict {$$=$2;};

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
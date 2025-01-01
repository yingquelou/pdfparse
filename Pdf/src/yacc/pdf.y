%code requires {
#define NEED_FLEX_HEADER
#define YY_DECL yy::parser::symbol_type yylex()
#include "pdf.config.h"
}
%code {
YY_DECL;
}
%{
#include <iostream>
#include <fstream>
#include <sstream>
#include<boost/json.hpp>
namespace json=boost::json;
extern std::size_t num,gen;
extern std::size_t f_index;
%}
%no-lines
//%debug
/* %parse-param {int isSplit} */
/* %glr-parser */
/* %skeleton "lalr1.cc"  */
%language "c++"
%define api.token.constructor
%define api.value.type variant
/* %define parse.assert */
%code top {
}
/* %skeleton "glr.c" */
%token <bool> FALSE_ TRUE_
%token <boost::json::string> STRING XSTRING NAME 
%token <boost::json::value>  STREAM
%token <boost::json::object> R OBJ
%token <double> REAL
%token <long long> INTEGER 
%token <boost::json::array> HEADER F N
/* 关键字 */
%token LD RD ENDOBJ  XREF TRAILER STARTXREF La Ra PDNULL
%type <boost::json::value> pdSection obj
%type <boost::json::object> trailer pdObj dictEntries dict subXref startxref
%type <boost::json::array>  xref  xrefs 
%type <boost::json::array> pDocument   subXrefEntries
%type <boost::json::array>  array objs subXrefEntry
%start pdf

%%
pdf: pDocument;

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
    $$=$xrefs;
};
xrefs:
|xrefs subXref{
    $1.emplace_back($subXref);
    $$=std::move($1);
};

subXref:
HEADER subXrefEntries {
    $$["header"]=$HEADER;
    $$["body"]=$subXrefEntries;
};

subXrefEntries:
|subXrefEntries subXrefEntry {
    $1.emplace_back($subXrefEntry);
    $$=std::move($1);
};

subXrefEntry:F 
|N;

startxref: STARTXREF INTEGER {
    $$["startxref"]=$2;
};

pdObj: OBJ objs ENDOBJ {
    $1["body"]=$objs;
    $$=std::move($1);
};

trailer:
TRAILER dict {
    $$=$dict;
};

obj:PDNULL {}
|STREAM {$$=std::move($1);}
|R {$$=std::move($1);}
|array {$$=std::move($1);}
|dict {$$=std::move($1);}
|TRUE_ {$$=std::move($1);}
|FALSE_ {$$=std::move($1);}
|INTEGER {$$=std::move($1);}
|REAL {$$=std::move($1);}
|STRING {$$=std::move($1);}
|XSTRING {$$=std::move($1);}
|NAME {$$=std::move($1);}
;

array: La objs Ra {
    $$=std::move($objs);
};

dict: LD dictEntries RD {
    $$=std::move($dictEntries);
};

dictEntries: 
|dictEntries NAME obj {
    $1[$NAME]=$obj;
    $$=std::move($1);
};

objs: 
|objs obj {
    $1.emplace_back($obj);
    $$=std::move($1);
};
%%
void yy::parser::error(const std::string&msg){
std::cerr<<msg;
}
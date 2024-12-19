%{
#define BISON_FLEX
#include "pdf.config.h"
#include <iostream>
void yyerror(const char*str);
%}
/* %no-lines */
//%debug
/* %parse-param {int isSplit} */
/* %parse-param {const char*savaAsJson} */
/* %glr-parser */
%define api.value.type {Object}

/* %destructor {json_decref($$);} <obj>  */
%token <b> FALSE_ TRUE_
%token <str> STRING XSTRING NAME 
%token PDNULL OBJ R ENDSTREAM
%token <d> REAL
/* 关键字 */
%token LD RD ENDOBJ STREAM XREF TRAILER STARTXREF La Ra
%type stream subXref obj pDocument pdSection  trailer startxref xref  
%type <obj> pdObj 
%type <array> array objs
%type <dict> dict
%type  subXrefEntry dictEntries
%nonassoc <sll> INTEGER
%left F N
%start pdf
%%
pdf: pDocument {
};

pDocument:
|pDocument pdSection {
};

pdSection: pdObj {
    
}
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

obj:PDNULL 
|stream
|R
|array
|dict
|TRUE_
|FALSE_
|INTEGER{
  // std::cout<<"INTEGER\t"<<$1<<'\n';
}
|REAL
|STRING {
  std::cout<<"STRING\t"<<$1<<'\n';
}
|XSTRING
|NAME{
  // std::cout<<"NAME\t"<<$1<<'\n';
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
void yyerror(const char*str){

}
int main(int argc, char const *argv[])
{
  for (size_t i = 1; argv[i]; i++)
  {
    FILE *f = fopen(argv[i], "rb");
    if (f)
    {
      yyset_in(f);
      yyparse();
      fclose(f);
    }
  }
  return 0;
}
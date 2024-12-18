%{
#define BISON_FLEX
#include "pdf.config.h"
void yyerror(const char*str);
%}
/* %no-lines */
//%debug
/* %parse-param {int isSplit} */
/* %parse-param {const char*savaAsJson} */
/* %glr-parser */
%union{
}
/* %destructor {json_decref($$);} <obj>  */
%token FALSE_ TRUE_ REAL STRING XSTRING NAME PDNULL OBJ R ENDSTREAM
/* 关键字 */
%token LD RD  ENDOBJ STREAM XREF TRAILER STARTXREF La Ra
%type stream subXref obj array pDocument pdSection pdObj trailer startxref xref dict objs
%type  subXrefEntry dictEntries
%nonassoc  INTEGER
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
|INTEGER
|REAL
|STRING
|XSTRING
|NAME
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
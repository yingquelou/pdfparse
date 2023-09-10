%{
int yyerror(char *s);
#include "PdType.h"

%}
%union{
    PdBoolean boolean;
    PdInteger integer;
    PdReal real;
    PdString string;
    PdName name;
}
%token <boolean> BOOLEAN
%token <integer> INTEGER
%token <real> REAL
%token <string> STRING XSTRING
%token <name> NAME
%type ARRAY
%type DICTIONARY
%type OBJ
%token ' ' '[' ']'
%token LD RD

%% 
ARRAY: '[' OBJ ']' {}
        ;
OBJ :BOOLEAN
|INTEGER
|REAL
|STRING
|XSTRING
|NAME
;
DICTIONARY: LD OBJ RD {}
;
%%

int yyerror(char *s)
{
    fprintf(stderr,"error:%s\n",s);
    return 0; 
}       


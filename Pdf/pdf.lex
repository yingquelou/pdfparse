%{
#include "..\\Pdocument.h"
#ifdef YACCHEADFILE
#include YACCHEADFILE
#else
#include"y.tab.h"
#endif
%}

LA \[
RA \]
LD "<<"
RD ">>"
string \(.*\)
d [0-9]
w [0-9a-zA-Z]
xd [0-9A-Fa-f]
f [+-]?{d}*\.{d}+
OBJ {INT}{space}+{INT}{space}+obj
INDIRECTOBJREF {INT}{space}+{INT}{space}+R
INT {d}+
space " "
EOL \r?\n
keyword stream|trailer|endstream|xref|startxref|f|n
name \/[^ \r\n]+

%%

%.*$ {}
{EOL} {}
{space} {}
true {
	yylval.boolean=malloc(sizeof(pdBoolean));
	*(yylval.boolean)=true;
	return BOOLEAN;
}
false {
	yylval.boolean=malloc(sizeof(pdBoolean));
	*(yylval.boolean)=false;
	return BOOLEAN;
}

{INT}   {
	yylval.integer=malloc(sizeof(pdInteger));
	*(yylval.integer)=atoll(yytext);
	return INTEGER;
}
{f}     {
	yylval.real=malloc(sizeof(pdReal));
	*(yylval.real)=atof(yytext);
	return REAL;
}
{name} {
	yylval.name=malloc(yyleng+1);
	memcpy(yylval.name,yytext,yyleng);
	yylval.name[yyleng]='\0';
	return NAME;
}
{string} {
	yylval.string=malloc(sizeof(pdString));
	yylval.string->isHex=false;
	yylval.string->length=yyleng-2;
	yylval.string->str=malloc(yyleng-1);
	memcpy(yylval.string->str,yytext+1,yyleng-2);
	yylval.string->str[yyleng-3]='\0';
	return STRING;
}
\<{xd}*\> {
	yylval.string=malloc(sizeof(pdString));
	yylval.string->isHex=true;
	yylval.string->length=yyleng-2;
	yylval.string->str=malloc(yyleng-1);
	memcpy(yylval.string->str,yytext+1,yyleng-2);
	yylval.string->str[yyleng-3]='\0';
	return STRING;
}
{OBJ} {
	char*textpos;
	yylval.objnum.first=strtoll(yytext,&textpos,10);
	yylval.objnum.second=strtoll(textpos,NULL,10);
	return OBJ;
}
{INDIRECTOBJREF} {
	char*textpos;
	yylval.objnum.first=strtoll(yytext,&textpos,10);
	yylval.objnum.second=strtoll(textpos,NULL,10);
	return INDIRECTOBJREF;
}
endobj {
	return ENDOBJ;
}

{LD} {
	return LD;
}
{RD} {
	return RD;
}
{LA} {
	return '[';
}
{RA} {
	return ']';
}
null {
	return PDNULL;
}

{keyword} {
}

%%
int yywrap()
{
	return(1);
}
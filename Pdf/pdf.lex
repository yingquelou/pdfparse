%{
#include "PdType.h"
#include"y.tab.h"
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
space " "
EOL (\r\n|\n)
keyword obj|endobj|stream|trailer|R|endstream|xref|startxref|f|n
name \/[^ \r\n]+

%%

%.*$ {}
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
{d}+   {
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
{keyword} {
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
{EOL} {
}

%%
int yywrap()
{
	return(1);
}
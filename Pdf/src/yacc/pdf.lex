%{
#define BISON_YACC
#include "pdf.config.h"
#include <string>
#include <sstream>
#include <iostream>
static std::stringstream buffer;
static int parenthesis;
%}
%x streamState strState xstrState
%option noyywrap 
/* %option noline */
/* nodefault */
La "["
Ra "]"
Ld "<<"
Rd ">>"
D [0-9]
Xd [0-9A-Fa-f]
Real [+-]?{D}*\.{D}+
Int [+-]?{D}+
Tab [ \t]
Cr \r
Lf \n
CrLf {Cr}?{Lf}
Name \/[^ \/\\\t\r\n\[\]\<\(\)\>]+
Eol {Tab}*{CrLf}
Space {Tab}|{CrLf}
%%
%.* {}
{CrLf} {
}
{Tab} {}
{Ld} {
	return LD;
}
{Rd} {
	return RD;
}
{La} {
	return La;
}
{Ra} {
	return Ra;
}
"<" {
}
<xstrState>{Xd} {
}
<xstrState>{Space} {}
<xstrState>">" {
	BEGIN INITIAL;
	return XSTRING;
}

"(" {
	parenthesis=1;
	BEGIN strState;
}
<strState>\\{Eol} {}
<strState>\\(D{1,3}|[()nrtbf\\]) {
	buffer.write(yytext,yyleng);
}
<strState>"(" {
	++parenthesis;
	buffer.write(yytext,yyleng);
}
<strState>")" {
	if(--parenthesis==0)
	{
		BEGIN INITIAL;
		yylval.str.assign(buffer.str());
		buffer.str("");
		return STRING;
	}
	else
		buffer.write(yytext,yyleng);
}
<strState>[^)] {
	buffer.write(yytext,yyleng);
}
{Int}{Space}+{Int}{Space}+R {
	return R;
}
trailer {
	return TRAILER;
}
null {
	return PDNULL;
}
endobj {
	return ENDOBJ;
}
{Int}{Space}+{Int}{Space}+obj {
	return OBJ;
}
true {
	return TRUE_;
}
false {
	return FALSE_;
}
startxref {
return STARTXREF;
}
xref {
	return XREF;
}
f {
	return F;
}
n {
	return N;
}
{Int}   {
	yylval.sll=convertAs<signed long long>({yytext,yyleng});
	return INTEGER;
}
{Real}     {
	return REAL;
}

{Name} {
	yylval.str.assign(yytext+1,yyleng-1);
	// std::cout<<"NAME\t"<<yylval.str<<'\n';G
	return NAME;
}

stream{CrLf}? {
	BEGIN streamState;
	return STREAM;
}
<streamState>{CrLf}?endstream {
	BEGIN INITIAL;
	buffer.str("");
	return ENDSTREAM;
}
<streamState>{Lf}|. {
	buffer.write(yytext,yyleng);
}


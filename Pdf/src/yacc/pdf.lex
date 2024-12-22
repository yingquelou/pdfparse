%{
#define BISON_YACC
#include "pdf.config.h"
typedef yy::parser::semantic_type YYSTYPE;
#include <string>
#include <sstream>
#include <iostream>
static std::stringstream buffer;
static int parenthesis;
%}
%x streamState strState xstrState
%option noyywrap bison-bridge noline
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
	return yy::parser::token::LD;
}
{Rd} {
	return yy::parser::token::RD;
}
{La} {
	return yy::parser::token::La;
}
{Ra} {
	return yy::parser::token::Ra;
}
"<" {
}
<xstrState>{Xd} {
}
<xstrState>{Space} {}
<xstrState>">" {
	BEGIN INITIAL;
	return yy::parser::token::XSTRING;
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
		yylval->str.assign(buffer.str());
		buffer.str("");
		return yy::parser::token::STRING;
	}
	else
		buffer.write(yytext,yyleng);
}
<strState>[^)] {
	buffer.write(yytext,yyleng);
}
{Int}{Space}+{Int}{Space}+R {
	return yy::parser::token::R;
}
trailer {
	return yy::parser::token::TRAILER;
}
null {
	return yy::parser::token::PDNULL;
}
endobj {
	return yy::parser::token::ENDOBJ;
}
{Int}{Space}+{Int}{Space}+obj {
	return yy::parser::token::OBJ;
}
true {
	return yy::parser::token::TRUE_;
}
false {
	return yy::parser::token::FALSE_;
}
startxref {
return yy::parser::token::STARTXREF;
}
xref {
	return yy::parser::token::XREF;
}
f {
	return yy::parser::token::F;
}
n {
	return yy::parser::token::N;
}
{Int}   {
	yylval.sll=convertAs<signed long long>({yytext,yyleng});
	return yy::parser::token::INTEGER;
}
{Real}     {
	return yy::parser::token::REAL;
}

{Name} {
	yylval.str.assign(yytext+1,yyleng-1);
	// std::cout<<"NAME\t"<<yylval.str<<'\n';G
	return yy::parser::token::NAME;
}

stream{CrLf}? {
	BEGIN streamState;
	return yy::parser::token::STREAM;
}
<streamState>{CrLf}?endstream {
	BEGIN INITIAL;
	buffer.str("");
	return yy::parser::token::ENDSTREAM;
}
<streamState>{Lf}|. {
	buffer.write(yytext,yyleng);
}


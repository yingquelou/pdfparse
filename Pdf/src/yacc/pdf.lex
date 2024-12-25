%{
#define BISON_YACC
#include "utils.hpp"
#include "pdf.config.h"
#include <string>
#include <sstream>
#include <iostream>
static std::stringstream buffer;
static int parenthesis;
%}
%x streamState strState xstrState
%option noyywrap noline
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
	BEGIN xstrState;
	buffer.str("");
}
<xstrState>{Xd} {buffer.write(yytext,yyleng);}
<xstrState>{Space} {}
<xstrState>">" {
	BEGIN INITIAL;
	auto&&s=buffer.str();
	return {yy::parser::token::XSTRING,"<"+s+">"};
}

"(" {
	parenthesis=1;
	buffer.str("");
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
		auto&&s=buffer.str();
		return {yy::parser::token::STRING,'('+s+')'};
	}
	else
		buffer.write(yytext,yyleng);
}
<strState>[^)] {
	buffer.write(yytext,yyleng);
}
{Int}{Space}+{Int}{Space}+R {
	std::size_t num,gen;
	unpack(std::string(yytext,yyleng),num,gen);
	Json::Value vn(num),vg(gen);
	Json::Value v;
	v.append(vn);
	v.append(vg);
	return {yy::parser::token::R,v};
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
	std::size_t num,gen;
	unpack(std::string(yytext,yyleng),num,gen);
	Json::Value obj;
	obj["id"][0]=num;
	obj["id"][1]=gen;
	return {yy::parser::token::OBJ,obj};
}
true {
	return {yy::parser::token::TRUE_,true};
}
false {
	return {yy::parser::token::FALSE_,false};
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
	return {yy::parser::token::INTEGER,convertAs<long long>({yytext,yyleng})};
}
{Real}     {
	return {yy::parser::token::REAL,convertAs<double>({yytext,yyleng})};
}

{Name} {
	return {yy::parser::token::NAME,{yytext+1,yytext+yyleng}};
}

stream{CrLf}? {
	BEGIN streamState;
	buffer.str("");
}
<streamState>{CrLf}?endstream {
	BEGIN INITIAL;
	return {yy::parser::token::STREAM,buffer.str()};
}
<streamState>{Lf}|. {
	buffer.write(yytext,yyleng);
}


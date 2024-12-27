%{
#define BISON_YACC
#include "utils.hpp"
#include "pdf.config.h"
#include <string>
#include <sstream>
#include <iostream>
static std::stringstream buffer;
static int parenthesis;
static std::stack<yy_state_type> stateStack;
#define yy_push_state(state)      \
	do                            \
	{                             \
		stateStack.push(YYSTATE); \
		BEGIN state;              \
	} while (false)
#define yy_pop_state()          \
	do                          \
	{                           \
		BEGIN stateStack.top(); \
		stateStack.pop();       \
	} while (false)
%}
%x streamState strState xstrState xrefState 
%option noyywrap noline
/* debug */
/* nodefault */
La "["
Ra "]"
Ld "<<"
Rd ">>"
digit [[:digit:]]
xdigit [[:xdigit:]]
Real [+-]?{digit}*\.{digit}+
Nat {digit}+
Int [+-]?{Nat}
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
	yy_push_state(xstrState);
	buffer.str("");
}
<xstrState>{xdigit} {buffer.write(yytext,yyleng);}
<xstrState,xrefState>{Space} {}
<xstrState>">" {
	yy_pop_state();
	auto&&s=buffer.str();
	return {yy::parser::token::XSTRING,"<"+s+">"};
}

"(" {
	parenthesis=1;
	buffer.str("");
	yy_push_state(strState);
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
		yy_pop_state();
		auto&&s=buffer.str();
		return {yy::parser::token::STRING,'('+s+')'};
	}
	else
		buffer.write(yytext,yyleng);
}
<strState>[^)] {
	buffer.write(yytext,yyleng);
}
{Nat}{Space}+{Nat}{Space}+R {
	std::size_t num,gen;
	unpack({yytext,yyleng},num,gen);
	Json::Value vn(num),vg(gen);
	Json::Value v;
	v["R"].append(vn);
	v["R"].append(vg);
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
	yy_push_state(xrefState);
	return yy::parser::token::XREF;
}

<xrefState>{Nat}{Space}+{Nat} {
	std::size_t start,length;
	unpack({yytext,yyleng},start,length);
	Json::Value v;
	v.append(start);
	v.append(length);
	return {yy::parser::token::HEADER,v};
}

<xrefState>{digit}{10}{Space}+{digit}{5}{Space}+f {
	std::string offset,gen,fn;
	unpack({yytext,yyleng},offset,gen,fn);
	Json::Value v;
	v.append(offset);
	v.append(gen);
	v.append(fn);
	return {yy::parser::token::F,v};
}
<xrefState>{digit}{10}{Space}+{digit}{5}{Space}+n {
	std::string offset,gen,fn;
	unpack({yytext,yyleng},offset,gen,fn);
	Json::Value v;
	v.append(offset);
	v.append(gen);
	v.append(fn);
	return {yy::parser::token::N,v};
}
<xrefState>. {
	yyless(0);
	yy_pop_state();
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
	yy_push_state(streamState);
	buffer.str("");
}
<streamState>{CrLf}?endstream {
	yy_pop_state();
	return {yy::parser::token::STREAM,buffer.str()};
}
<streamState>{Lf}|. {
	buffer.write(yytext,yyleng);
}


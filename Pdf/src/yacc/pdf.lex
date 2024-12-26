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
%x streamState strState xstrState
%x objBodyState trailerState xrefState 
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
<INITIAL,xrefState>{CrLf} {
}
<INITIAL,xrefState>{Tab} {}
<objBodyState,trailerState>{Ld} {
	return yy::parser::token::LD;
}
<objBodyState,trailerState>{Rd} {
	return yy::parser::token::RD;
}
<objBodyState,trailerState>{La} {
	return yy::parser::token::La;
}
<objBodyState,trailerState>{Ra} {
	return yy::parser::token::Ra;
}
<objBodyState,trailerState>"<" {
	yy_push_state(xstrState);
	buffer.str("");
}
<xstrState>{xdigit} {buffer.write(yytext,yyleng);}
<xstrState>{Space} {}
<xstrState>">" {
	yy_pop_state();
	auto&&s=buffer.str();
	return {yy::parser::token::XSTRING,"<"+s+">"};
}

<objBodyState,trailerState>"(" {
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
<objBodyState,trailerState>{Int}{Space}+{Int}{Space}+R {
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
<objBodyState,trailerState>null {
	return yy::parser::token::PDNULL;
}
<objBodyState>endobj {
	yy_pop_state();
	return yy::parser::token::ENDOBJ;
}
<INITIAL,xrefState>{Nat} {
	return {yy::parser::token::NAT,{yytext,yytext+yyleng}};
}
{Int}{Space}+{Int}{Space}+obj {
	yy_push_state(objBodyState);
	std::size_t num,gen;
	unpack(std::string(yytext,yyleng),num,gen);
	Json::Value obj;
	obj["id"][0]=num;
	obj["id"][1]=gen;
	return {yy::parser::token::OBJ,obj};
}
<objBodyState,trailerState>true {
	return {yy::parser::token::TRUE_,true};
}
<objBodyState,trailerState>false {
	return {yy::parser::token::FALSE_,false};
}
startxref {
return yy::parser::token::STARTXREF;
}
xref {
	yy_push_state(xrefState);
	return yy::parser::token::XREF;
}
<xrefState>f {
	return yy::parser::token::F;
}
<xrefState>n {
	return yy::parser::token::N;
}
<objBodyState,trailerState>{Int}   {
	return {yy::parser::token::INTEGER,convertAs<long long>({yytext,yyleng})};
}
<objBodyState,trailerState>{Real}     {
	return {yy::parser::token::REAL,convertAs<double>({yytext,yyleng})};
}

<objBodyState,trailerState>{Name} {
	return {yy::parser::token::NAME,{yytext+1,yytext+yyleng}};
}

<objBodyState>stream{CrLf}? {
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


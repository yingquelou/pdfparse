%{
#include "utils.hpp"
// #define ECHO std::cout << "ign" << yytext <<'\n'
#define BISON_YACC
#include "pdf.config.h"
#include <string>
#include <sstream>
#include <fstream>
static std::stringstream buffer;
static int parenthesis;
std::size_t f_index=0;
std::size_t num,gen;
%}
%option noline noyywrap stack
/* debug */
/* nodefault */
%x streamState strState xstrState xrefState 
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
Space [[:space:]]
%%

%.* {}
<INITIAL,xstrState,xrefState>{Space} {}

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
	utils::unpack({yytext,yyleng},num,gen);
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
	utils::unpack(std::string(yytext,yyleng),num,gen);
	Json::Value obj;
	obj["id"].append(num);
	obj["id"].append(gen);
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
	utils::unpack({yytext,yyleng},start,length);
	Json::Value v;
	v.append(start);
	v.append(length);
	return {yy::parser::token::HEADER,v};
}

<xrefState>{digit}{10}{Space}+{digit}{5}{Space}+f {
	std::string offset,gen,fn;
	utils::unpack({yytext,yyleng},offset,gen,fn);
	Json::Value v;
	v.append(offset);
	v.append(gen);
	v.append(fn);
	return {yy::parser::token::F,v};
}
<xrefState>{digit}{10}{Space}+{digit}{5}{Space}+n {
	std::string offset,gen,fn;
	utils::unpack({yytext,yyleng},offset,gen,fn);
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
	return {yy::parser::token::INTEGER,utils::convertAs<long long>({yytext,yyleng})};
}
{Real}     {
	return {yy::parser::token::REAL,utils::convertAs<double>({yytext,yyleng})};
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
	std::stringstream ss;
	ss<<"obj_" << num<<'_'<<gen<<'_'<<f_index++<<".stream";
	auto &&str=ss.str();
	Json::Value v;
	v["stream"]=str;
	std::ofstream ofs(str,std::ofstream::binary);
	ofs<<buffer.str();
	return {yy::parser::token::STREAM, v};
}
<streamState>{Lf}|. {
	buffer.write(yytext,yyleng);
}


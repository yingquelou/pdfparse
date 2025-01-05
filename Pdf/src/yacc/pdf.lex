%top {
#include <string>
typedef struct shared_data
{
	std::string dir;
} shared_data;

#define YY_EXTRA_TYPE shared_data *
}
%{
#define NEED_YACC_HEADER
#include <boost/json.hpp>
#include <boost/filesystem.hpp>
#include "pdf.config.h"
#include "utils.hpp"
namespace json=boost::json;
// #define ECHO std::cout << "ign" << yytext <<'\n'
#include <string>
#include <sstream>
#include <fstream>
static std::stringstream buffer;
static int parenthesis;
std::size_t f_index=0;
std::size_t num,gen;
%}
%option noline noyywrap stack reentrant
/* bison-bridge bison-locations */
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
%{
	// jpdsf
%}

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
	yy_push_state(xstrState,yyscanner);
	buffer.str("");
}
<xstrState>{xdigit} {buffer.write(yytext,yyleng);}
<xstrState>">" {
	yy_pop_state(yyscanner);
	auto&&s="<"+buffer.str()+">";
	boost::json::string str(s.begin(),s.end());
	return {yy::parser::token::XSTRING,str};
}

"(" {
	parenthesis=1;
	buffer.str("");
	yy_push_state(strState,yyscanner);
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
		yy_pop_state(yyscanner);
		auto&&s='('+buffer.str()+')';
	  	boost::json::string str(s.begin(),s.end());
		return {yy::parser::token::STRING,str};
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
	boost::json::object obj({
		{"R",{num,gen}}
	});
	return {yy::parser::token::R,obj};
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
	boost::json::object obj({
		{"id",{num,gen}}
	});
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
	yy_push_state(xrefState,yyscanner);
	return yy::parser::token::XREF;
}

<xrefState>{Nat}{Space}+{Nat} {
	std::size_t start,length;
	utils::unpack({yytext,yyleng},start,length);
	boost::json::array arr({start,length});
	return {yy::parser::token::HEADER,arr};
}

<xrefState>{digit}{10}{Space}+{digit}{5}{Space}+f {
	std::string offset,gen,fn;
	utils::unpack({yytext,yyleng},offset,gen,fn);
  	boost::json::array arr({
		offset,gen,fn
	});
	return {yy::parser::token::F,arr};
}
<xrefState>{digit}{10}{Space}+{digit}{5}{Space}+n {
	std::string offset,gen,fn;
	utils::unpack({yytext,yyleng},offset,gen,fn);
	boost::json::array arr({
		offset,gen,fn
	});
	return {yy::parser::token::N,arr};
}
<xrefState>. {
	yyless(0);
	yy_pop_state(yyscanner);
}

{Int}   {
	return {yy::parser::token::INTEGER,utils::convertAs<long long>({yytext,yyleng})};
}
{Real}     {
	return {yy::parser::token::REAL,utils::convertAs<double>({yytext,yyleng})};
}

{Name} {
	boost::json::string str(yytext+1,yyleng-1);
	return {yy::parser::token::NAME,str};
}

stream{CrLf}? {
	yy_push_state(streamState,yyscanner);
	buffer.str("");
}
<streamState>{CrLf}?endstream {
	yy_pop_state(yyscanner);
	std::stringstream ss;
	ss<<"obj_" << num<<'_'<<gen<<'_'<<f_index++<<".stream";
	boost::filesystem::path p(yyget_extra(yyscanner)->dir);
	auto &&str=p.append(ss.str()).generic_string();
	boost::json::object obj({
		{"stream",str}
	});
	std::ofstream ofs(str,std::ofstream::binary);
	ofs<<buffer.str();
	return {yy::parser::token::STREAM, obj};
}
<streamState>{Lf}|. {
	buffer.write(yytext,yyleng);
}


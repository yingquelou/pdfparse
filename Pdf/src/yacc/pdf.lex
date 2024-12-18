%{
#define BISON_YACC
#include "pdf.config.h"
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
	BEGIN strState;
}
<strState>\\{Eol} {}
<strState>\\(D{1,3}|[()nrtbf\\]) {
}
<strState>"(" {
}
<strState>")" {
		BEGIN INITIAL;
		return STRING;
}
<strState>[^)] {
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
	return INTEGER;
}
{Real}     {
	return REAL;
}

{Name} {
	return NAME;
}

stream{CrLf}? {
	return STREAM;
}
<streamState>{CrLf}?endstream {
	BEGIN INITIAL;
	return ENDSTREAM;
}
<streamState>{Lf}|. {
}


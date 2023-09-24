%{
#include "..\\Pdocument.h"
#ifdef YACCHEADFILE
#include YACCHEADFILE
#else
#include"y.tab.h"
#endif
long streamStartPos=0;
#define ECHO if(streamStartPos==0) do { if (fwrite( yytext, (size_t) yyleng, 1, yyout )) {} } while (0)
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
keyword trailer|xref|startxref|f|n
name \/[^ \r\n]+

%%

%.*$ {}
{EOL} {}
{space} {}
true {
	if(streamStartPos==0)
	{yylval.boolean=malloc(sizeof(pdBoolean));
	*(yylval.boolean)=true;
	return BOOLEAN;}
}
false {
	if(streamStartPos==0)
	{yylval.boolean=malloc(sizeof(pdBoolean));
	*(yylval.boolean)=false;
	return BOOLEAN;}
}

{INT}   {
	if(streamStartPos==0)
	{yylval.integer=malloc(sizeof(pdInteger));
	*(yylval.integer)=atoll(yytext);
	return INTEGER;}
}
{f}     {
	if(streamStartPos==0)
	{yylval.real=malloc(sizeof(pdReal));
	*(yylval.real)=atof(yytext);
	return REAL;}
}
{name} {
	if(streamStartPos==0)
	{yylval.name=malloc(yyleng+1);
	memcpy(yylval.name,yytext,yyleng);
	yylval.name[yyleng]='\0';
	return NAME;}
}
{string} {
	if(streamStartPos==0)
	{yylval.string=malloc(sizeof(pdString));
	yylval.string->isHex=false;
	yylval.string->length=yyleng-2;
	yylval.string->str=malloc(yyleng-1);
	memcpy(yylval.string->str,yytext+1,yyleng-2);
	yylval.string->str[yyleng-3]='\0';
	return STRING;}
}
\<{xd}*\> {
	if(streamStartPos==0)
	{yylval.string=malloc(sizeof(pdString));
	yylval.string->isHex=true;
	yylval.string->length=yyleng-2;
	yylval.string->str=malloc(yyleng-1);
	memcpy(yylval.string->str,yytext+1,yyleng-2);
	yylval.string->str[yyleng-3]='\0';
	return STRING;}
}
{OBJ} {
	if(streamStartPos==0)
	{char*textpos;
	yylval.objnum.first=strtoll(yytext,&textpos,10);
	yylval.objnum.second=strtoll(textpos,NULL,10);
	return OBJ;}
}
{INDIRECTOBJREF} {
	if(streamStartPos==0)
	{char*textpos;
	yylval.objnum.first=strtoll(yytext,&textpos,10);
	yylval.objnum.second=strtoll(textpos,NULL,10);
	return INDIRECTOBJREF;}
}
endobj {
	if(streamStartPos==0)
	return ENDOBJ;
}

{LD} {
	if(streamStartPos==0)
	return LD;
}
{RD} {
	if(streamStartPos==0)
	return RD;
}
{LA} {
	if(streamStartPos==0)
	return '[';
}
{RA} {
	if(streamStartPos==0)
	return ']';
}
null {
	if(streamStartPos==0)
	return PDNULL;
}
stream {
if(streamStartPos)
	exit(1);
streamStartPos=ftell(yyin);
printf("%s\t%d\n",yytext,streamStartPos);
return STREAM;
}
endstream {
// 暂时有bug
PdString str=malloc(sizeof(pdString));
str->length=ftell(yyin)-streamStartPos-9;
str->str=malloc(str->length+1);
fseek(yyin, 9-str->length, SEEK_CUR);
fread(str->str,1,str->length,yyin);
printf("%d\t%d\n",streamStartPos,str->length);
str->isHex=false;
fseek(yyin, 9, SEEK_CUR);
streamStartPos=0;
yylval.string=str;
return ENDSTREAM;
}
{keyword} {
}

%%
int yywrap()
{
	return(1);
}
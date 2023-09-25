%{
#include "..\\Pdocument.h"
#ifdef YACCHEADFILE
#include YACCHEADFILE
#else
#include"y.tab.h"
#endif
long streamStartPos=0;
unsigned long long pos=0;
#define ECHO do {pos+=yyleng; if(streamStartPos==0) if (fwrite( yytext, (size_t) yyleng, 1, yyout )) {} } while (0)
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
{EOL} {pos+=yyleng;}
{space} {pos+=yyleng;}
true {
	pos+=yyleng;
	if(streamStartPos==0)
	{yylval.boolean=malloc(sizeof(pdBoolean));
	*(yylval.boolean)=true;
	return BOOLEAN;}
}
false {
	pos+=yyleng;
	if(streamStartPos==0)
	{yylval.boolean=malloc(sizeof(pdBoolean));
	*(yylval.boolean)=false;
	return BOOLEAN;}
}

{INT}   {
	pos+=yyleng;
	if(streamStartPos==0)
	{yylval.integer=malloc(sizeof(pdInteger));
	*(yylval.integer)=atoll(yytext);
	return INTEGER;}
}
{f}     {
	pos+=yyleng;
	if(streamStartPos==0)
	{yylval.real=malloc(sizeof(pdReal));
	*(yylval.real)=atof(yytext);
	return REAL;}
}
{name} {
	pos+=yyleng;
	if(streamStartPos==0)
	{yylval.name=malloc(yyleng+1);
	memcpy(yylval.name,yytext,yyleng);
	yylval.name[yyleng]='\0';
	return NAME;}
}
{string} {
	pos+=yyleng;
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
	pos+=yyleng;
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
	pos+=yyleng;
	if(streamStartPos==0)
	{char*textpos;
	yylval.objnum.first=strtoll(yytext,&textpos,10);
	yylval.objnum.second=strtoll(textpos,NULL,10);
	return OBJ;}
}
{INDIRECTOBJREF} {
	pos+=yyleng;
	if(streamStartPos==0)
	{char*textpos;
	yylval.objnum.first=strtoll(yytext,&textpos,10);
	yylval.objnum.second=strtoll(textpos,NULL,10);
	return INDIRECTOBJREF;}
}
endobj {
	pos+=yyleng;
//printf("%s\t%d\n",yytext,ftell(yyin));

	if(streamStartPos==0)
	return ENDOBJ;
}

{LD} {
	pos+=yyleng;
	if(streamStartPos==0)
	return LD;
}
{RD} {
	pos+=yyleng;
	if(streamStartPos==0)
	return RD;
}
{LA} {
	pos+=yyleng;
	if(streamStartPos==0)
	return '[';
}
{RA} {
	pos+=yyleng;
	if(streamStartPos==0)
	return ']';
}
null {
	pos+=yyleng;
	if(streamStartPos==0)
	return PDNULL;
}

{EOL}*endstream {
long tmp=ftell(yyin);
PdString str=malloc(sizeof(pdString));
str->length=pos-streamStartPos;
str->str=malloc(str->length+1);
fseek(yyin, streamStartPos, SEEK_SET);
fread(str->str,1,str->length,yyin);
str->isHex=false;
fseek(yyin, tmp, SEEK_SET);
str->str[str->length]='\0';
fprintf(yyout,"%d\t%s",streamStartPos,str->str);
yylval.string=str;
pos+=yyleng;
streamStartPos=0;
return ENDSTREAM;
}
stream{EOL}* {
pos+=yyleng;
if(streamStartPos)
	exit(1);
streamStartPos=pos;
return STREAM;
}
{keyword} {
pos+=yyleng;
}
%%
int yywrap()
{
	return(1);
}
%{
#include "..\\Pdocument.h"
#ifdef YACCHEADFILE
#include YACCHEADFILE
#else
#include"y.tab.h"
#endif
long streamStartPos=0;
unsigned long long pos=0;
#define ECHO do {pos+=yyleng; if(streamStartPos==0) if (fwrite( yytext, (size_t) yyleng, 1, yyout )) {fprintf(yyout,"->%d\n",pos);} } while (0)
%}

LA \[
RA \]
LD "<<"
RD ">>"
string \(.*\)
xstring \<{xd}*\>
d [0-9]
w [0-9a-zA-Z]
xd [0-9A-Fa-f]
f [+-]?{d}*\.{d}+
OBJ {INT}{space}+{INT}{space}+obj
INT [+-]?{d}+
INDIRECTOBJREF {INT}{space}+{INT}({space}|{EOL})+R
space " "
EOL \r?\n
name \/[^ \/\\\t\r\n\[\]\<\(\)\>]+

%%

{EOL} {pos+=yyleng;
	
}
{space} {pos+=yyleng;
	
}
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
xref {
	
	pos+=yyleng;
	return XREF;
}
^{INT}{space}+{INT}{space}*{EOL} {
	
	pos+=yyleng;
	if(streamStartPos==0)
	{char*textpos;
	yylval.objnum.first=strtoll(yytext,&textpos,10);
	yylval.objnum.second=strtoll(textpos,NULL,10);
	return SUBXREFHEAD;}
}
^{d}{10}{space}+{d}{5}{space}+f{space}*{EOL} {
	
	pos+=yyleng;
	if(streamStartPos==0)
	{char*textpos;
	yylval.objnum.first=strtoll(yytext,&textpos,10);
	yylval.objnum.second=strtoll(textpos,NULL,10);
	return FXREFENTRY;}
}
^{d}{10}{space}+{d}{5}{space}+n{space}*{EOL} {
	
	pos+=yyleng;
	if(streamStartPos==0)
	{char*textpos;
	yylval.objnum.first=strtoll(yytext,&textpos,10);
	yylval.objnum.second=strtoll(textpos,NULL,10);
	return NXREFENTRY;}
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
	yylval.string->bufferSize=yyleng-2;
	yylval.string->buffer=malloc(yyleng-1);
	memcpy(yylval.string->buffer,yytext+1,yyleng-2);
	yylval.string->buffer[yyleng-3]='\0';
	return STRING;}
}
{xstring} {
	
	pos+=yyleng;
	if(streamStartPos==0)
	{yylval.xstring=malloc(sizeof(pdXString));
	yylval.xstring->bufferSize=yyleng-2;
	yylval.xstring->buffer=malloc(yyleng-1);
	memcpy(yylval.xstring->buffer,yytext+1,yyleng-2);
	yylval.xstring->buffer[yyleng-3]='\0';
	return XSTRING;}
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

trailer {
	
	pos+=yyleng;
	return TRAILER;
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
PdStream stream=malloc(sizeof(pdStream));
stream->bufferSize=pos-streamStartPos;
stream->buffer=malloc(stream->bufferSize+1);
fseek(yyin, streamStartPos, SEEK_SET);
fread(stream->buffer,1,stream->bufferSize,yyin);
fseek(yyin, tmp, SEEK_SET);
stream->buffer[stream->bufferSize]='\0';
yylval.stream=stream;
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
startxref {
	
pos+=yyleng;
return STARTXREF;
}
%.*{EOL} {pos+=yyleng;
	
}

%%
int yywrap()
{
	//printf("to:%d\n",ftell(yyin));
	//clearerr(yyin);
	//if(errno==EBADF)
		return(1);
	//return(0);
}
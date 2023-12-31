%{
#include "Pdocument.h"
#ifdef YACCHEADFILE
#include YACCHEADFILE
#endif
static long streamStartPos=0;
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
INDIRECTOBJREF {INT}({space}|{EOL})+{INT}({space}|{EOL})+R
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
	
	{YYLVALREF.boolean=malloc(sizeof(pdBoolean));
	*(YYLVALREF.boolean)=true;
	return BOOLEAN;}
}
false {
	
	pos+=yyleng;
	if(streamStartPos==0)
	{YYLVALREF.boolean=malloc(sizeof(pdBoolean));
	*(YYLVALREF.boolean)=false;
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
	YYLVALREF.objnum.first=strtoll(yytext,&textpos,10);
	YYLVALREF.objnum.second=strtoll(textpos,NULL,10);
	return SUBXREFHEAD;}
}
^{d}{10}{space}+{d}{5}{space}+f{space}*{EOL} {
	
	pos+=yyleng;
	if(streamStartPos==0)
	{char*textpos;
	YYLVALREF.objnum.first=strtoll(yytext,&textpos,10);
	YYLVALREF.objnum.second=strtoll(textpos,NULL,10);
	return FXREFENTRY;}
}
^{d}{10}{space}+{d}{5}{space}+n{space}*{EOL} {
	
	pos+=yyleng;
	if(streamStartPos==0)
	{char*textpos;
	YYLVALREF.objnum.first=strtoll(yytext,&textpos,10);
	YYLVALREF.objnum.second=strtoll(textpos,NULL,10);
	return NXREFENTRY;}
}
{INT}   {
	
	pos+=yyleng;
	if(streamStartPos==0)
	{YYLVALREF.integer=malloc(sizeof(pdInteger));
	*(YYLVALREF.integer)=atoll(yytext);
	return INTEGER;}
}
{f}     {
	
	pos+=yyleng;
	if(streamStartPos==0)
	{YYLVALREF.real=malloc(sizeof(pdReal));
	*(YYLVALREF.real)=atof(yytext);
	return REAL;}
}
{name} {
	
	pos+=yyleng;
	if(streamStartPos==0)
	{YYLVALREF.name=malloc(yyleng);
	memcpy(YYLVALREF.name,yytext+1,yyleng-1);
	YYLVALREF.name[yyleng]='\0';
	return NAME;}
}
{string} {
	
	pos+=yyleng;
	if(streamStartPos==0)
	{YYLVALREF.string=malloc(sizeof(pdString));
	YYLVALREF.string->bufferSize=yyleng-2;
	YYLVALREF.string->buffer=malloc(yyleng-1);
	memcpy(YYLVALREF.string->buffer,yytext+1,yyleng-2);
	YYLVALREF.string->buffer[yyleng-3]='\0';
	return STRING;}
}
{xstring} {
	
	pos+=yyleng;
	if(streamStartPos==0)
	{YYLVALREF.xstring=malloc(sizeof(pdXString));
	YYLVALREF.xstring->bufferSize=yyleng-2;
	YYLVALREF.xstring->buffer=malloc(yyleng-1);
	memcpy(YYLVALREF.xstring->buffer,yytext+1,yyleng-2);
	YYLVALREF.xstring->buffer[yyleng-3]='\0';
	return XSTRING;}
}
{OBJ} {
	
	pos+=yyleng;
	if(streamStartPos==0)
	{char*textpos;
	YYLVALREF.objnum.first=strtoll(yytext,&textpos,10);
	YYLVALREF.objnum.second=strtoll(textpos,NULL,10);
	return OBJ;}
}
{INDIRECTOBJREF} {
	
	pos+=yyleng;
	if(streamStartPos==0)
	{char*textpos;
	YYLVALREF.objnum.first=strtoll(yytext,&textpos,10);
	YYLVALREF.objnum.second=strtoll(textpos,NULL,10);
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
YYLVALREF.stream=stream;
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
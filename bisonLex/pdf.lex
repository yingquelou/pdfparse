%{
#include "Pdocument.h"
#ifdef YACCHEADFILE
#include YACCHEADFILE
#endif
static long streamStartPos=0;
static FILE*streamFile=NULL;
static char*streamFileName=NULL;
unsigned long long pos=0;
char *tmpStreamFile()
{
    return tempnam(getenv("tmp"), "stream");
}
%}
%x ENTERSTREAM ENTERSTRING

LA \[
RA \]
LD "<<"
RD ">>"
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

{EOL} {pos+=yyleng;}
{space} {pos+=yyleng;}
true {
	
	pos+=yyleng;
	YYLVALREF.boolean=malloc(sizeof(pdBoolean));
	*(YYLVALREF.boolean)=true;
	return BOOLEAN;
}
false {
	
	pos+=yyleng;
	YYLVALREF.boolean=malloc(sizeof(pdBoolean));
	*(YYLVALREF.boolean)=false;
	return BOOLEAN;
}
xref {
	pos+=yyleng;
	return XREF;
}
^{INT}{space}+{INT}{space}*{EOL} {
	
	pos+=yyleng;
	char*textpos;
	YYLVALREF.objnum.first=strtoll(yytext,&textpos,10);
	YYLVALREF.objnum.second=strtoll(textpos,NULL,10);
	return SUBXREFHEAD;
}
^{d}{10}{space}+{d}{5}{space}+f{space}*{EOL} {
	
	pos+=yyleng;
	char*textpos;
	YYLVALREF.objnum.first=strtoll(yytext,&textpos,10);
	YYLVALREF.objnum.second=strtoll(textpos,NULL,10);
	return FXREFENTRY;
}
^{d}{10}{space}+{d}{5}{space}+n{space}*{EOL} {
	
	pos+=yyleng;
	
	{char*textpos;
	YYLVALREF.objnum.first=strtoll(yytext,&textpos,10);
	YYLVALREF.objnum.second=strtoll(textpos,NULL,10);
	return NXREFENTRY;}
}
{INT}   {
	
	pos+=yyleng;
	
	{YYLVALREF.integer=malloc(sizeof(pdInteger));
	*(YYLVALREF.integer)=atoll(yytext);
	return INTEGER;}
}
{f}     {
	
	pos+=yyleng;
	
	{YYLVALREF.real=malloc(sizeof(pdReal));
	*(YYLVALREF.real)=atof(yytext);
	return REAL;}
}
{name} {
	
	pos+=yyleng;
	
	{YYLVALREF.name=malloc(yyleng);
	memcpy(YYLVALREF.name,yytext+1,yyleng-1);
	YYLVALREF.name[yyleng-1]='\0';
	return NAME;}
}

{xstring} {
	
	pos+=yyleng;
	
	{YYLVALREF.xstring=malloc(sizeof(pdXString));
	YYLVALREF.xstring->bufferSize=yyleng-2;
	YYLVALREF.xstring->buffer=malloc(yyleng-1);
	memcpy(YYLVALREF.xstring->buffer,yytext+1,yyleng-2);
	YYLVALREF.xstring->buffer[yyleng-2]='\0';
	return XSTRING;}
}
{OBJ} {
	
	pos+=yyleng;
	
	{char*textpos;
	YYLVALREF.objnum.first=strtoll(yytext,&textpos,10);
	YYLVALREF.objnum.second=strtoll(textpos,NULL,10);
	return OBJ;}
}
{INDIRECTOBJREF} {
	
	pos+=yyleng;
	
	{char*textpos;
	YYLVALREF.objnum.first=strtoll(yytext,&textpos,10);
	YYLVALREF.objnum.second=strtoll(textpos,NULL,10);
	return INDIRECTOBJREF;}
}
endobj {
	
	pos+=yyleng;
//printf("%s\t%d\n",yytext,ftell(yyin));

	
	return ENDOBJ;
}

trailer {
	
	pos+=yyleng;
	
	return TRAILER;
}

{LD} {
	
	pos+=yyleng;
	
	return LD;
}
{RD} {
	
	pos+=yyleng;
	
	return RD;
}
{LA} {
	
	pos+=yyleng;
	
	return '[';
}
{RA} {
	
	pos+=yyleng;
	
	return ']';
}
null {
	
	pos+=yyleng;
	
	return PDNULL;
}
stream{space}*{EOL}*{space}* {
	BEGIN(ENTERSTREAM);
	streamFileName=tmpStreamFile();
	streamFile= fopen(streamFileName,"wb+");
pos+=yyleng;
return STREAM;
}
<ENTERSTREAM>{space}*{EOL}*{space}*endstream {
	BEGIN(INITIAL);
PdStream stream=malloc(sizeof(pdStream));
stream->bufferSize=ftell(streamFile);
	rewind(streamFile);
stream->buffer=malloc(stream->bufferSize+1);
fread(stream->buffer,1,stream->bufferSize,streamFile);
stream->buffer[stream->bufferSize]='\0';
	fclose(streamFile);
	remove(streamFileName);
	YYLVALREF.stream=stream;
pos+=yyleng + stream->bufferSize;
return ENDSTREAM;
}

<ENTERSTREAM>.|{EOL} {
	fwrite(yytext,1,yyleng,streamFile);
}
\( {
	BEGIN(ENTERSTRING);
	streamFileName=tmpStreamFile();
	streamFile= fopen(streamFileName,"wb+");
	pos+=yyleng;
}
<ENTERSTRING>\\{EOL} {}
<ENTERSTRING>\\{d}{3} {fwrite(yytext,1,yyleng,streamFile);}
<ENTERSTRING>[^\)\r\n\\]+ {fwrite(yytext,1,yyleng,streamFile);}
<ENTERSTRING>\\. {fwrite(yytext,1,yyleng,streamFile);}
<ENTERSTRING>\) {
	BEGIN(INITIAL);
	PdString str=malloc(sizeof(pdString));
	str->bufferSize=ftell(streamFile);
	str->buffer=malloc(str->bufferSize+1);
	rewind(streamFile);
	fread(str->buffer,1,str->bufferSize,streamFile);
	str->buffer[str->bufferSize]='\0';
	fclose(streamFile);
	YYLVALREF.string=str;
	return STRING;
	}
startxref {
pos+=yyleng;

return STARTXREF;
}
%.*{EOL} {pos+=yyleng;}

%%
int yywrap()
{
	return(1);
}
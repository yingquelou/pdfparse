%{
#include<cjson/cJSON.h>
#include"y.tab.h"
extern cJSON *pdfObjOfJsonCache;
FILE*stream=NULL;
extern int n;
extern char name[FILENAME_MAX];
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

{EOL} {}
{space} {}
true {
	yylval.obj=cJSON_CreateTrue();
	return BOOLEAN;
}
false {
	yylval.obj=cJSON_CreateFalse();
	return BOOLEAN;
}
xref {
	return XREF;
}
^{INT}{space}+{INT}{space}*{EOL} {
	char **arr=malloc(sizeof(char*)*2);
	arr[0]=malloc(yyleng+1);
	arr[1]=malloc(yyleng+1);
	sscanf(yytext,"%s%s",arr[0],arr[1]);
	yylval.obj=cJSON_CreateStringArray((const char *const *)arr,2);
	free(arr[0]);free(arr[1]);
	return SUBXREFHEAD;
}
^{d}{10}{space}+{d}{5}{space}+f{space}*{EOL} {
	char offset[11],gen[6];
	sscanf(yytext,"%s%s",offset,gen);
	yylval.obj=cJSON_CreateArray();
	cJSON_AddItemToArray(yylval.obj,cJSON_CreateString(offset));
	cJSON_AddItemToArray(yylval.obj,cJSON_CreateString(gen));
	cJSON_AddItemToArray(yylval.obj,cJSON_CreateString("f"));
	return FXREFENTRY;
}
^{d}{10}{space}+{d}{5}{space}+n{space}*{EOL} {
	char offset[11],gen[6];
	sscanf(yytext,"%s%s",offset,gen);
	yylval.obj=cJSON_CreateArray();
	cJSON_AddItemToArray(yylval.obj,cJSON_CreateString(offset));
	cJSON_AddItemToArray(yylval.obj,cJSON_CreateString(gen));
	cJSON_AddItemToArray(yylval.obj,cJSON_CreateString("n"));
	return NXREFENTRY;
}
{INT}   {
	yylval.obj=cJSON_CreateString(yytext);
	return INTEGER;
	}
{f}     {
	yylval.obj=cJSON_CreateString(yytext);
	return REAL;
	}
{name} {
	yylval.obj=cJSON_CreateString(yytext+1);
	return NAME;
}

{xstring} {
	yytext[yyleng-1]='\0';
	yylval.obj=cJSON_CreateString(yytext+1);
	return XSTRING;
}
{OBJ} {
	char **arr=malloc(sizeof(char*)*2);
	arr[0]=malloc(yyleng+1);
	arr[1]=malloc(yyleng+1);
	sscanf(yytext,"%s%s",arr[0],arr[1]);
	yylval.obj=cJSON_CreateStringArray((const char *const *)arr,2);
	free(arr[0]);free(arr[1]);
	return OBJ;
}
{INDIRECTOBJREF} {
	char **arr=malloc(sizeof(char*)*2);
	arr[0]=malloc(yyleng+1);
	arr[1]=malloc(yyleng+1);
	sscanf(yytext,"%s%s",arr[0],arr[1]);
	yylval.obj=cJSON_CreateObject();
	cJSON_AddItemToObject(yylval.obj,"R",cJSON_CreateStringArray((const char *const *)arr,2));
	free(arr[0]);free(arr[1]);
	return INDIRECTOBJREF;
}
endobj {return ENDOBJ;}

trailer {return TRAILER;}

{LD} {return LD;}
{RD} {return RD;}
{LA} {return '[';}
{RA} {return ']';}
null {return PDNULL;}
stream{space}*{EOL}*{space}* {
	BEGIN(ENTERSTREAM);
	sprintf(name,"%s/%d",cJSON_GetStringValue(cJSON_GetObjectItem(pdfObjOfJsonCache,"stream")),n++);
	stream=fopen(name,"wb");
	return STREAM;
}
<ENTERSTREAM>{space}*{EOL}*{space}*endstream {
	BEGIN(INITIAL);
	long length=ftell(stream);
	yylval.obj=cJSON_CreateObject();
	if(length!=-1l)
	{
	cJSON_AddItemToObject(yylval.obj,"stream",cJSON_CreateString(name));
	}else{
	cJSON_AddItemToObject(yylval.obj,"stream",cJSON_CreateString("streamPath"));
	}
	fclose(stream);
	stream=NULL;
	return ENDSTREAM;
}

<ENTERSTREAM>.|{EOL} {
	fwrite(yytext,1,yyleng,stream);
}
\( {
	BEGIN(ENTERSTRING);
	stream=tmpfile();
}
<ENTERSTRING>\\{EOL} {}
<ENTERSTRING>\\{d}{3} {fwrite(yytext,1,yyleng,stream);}
<ENTERSTRING>[^\)\r\n\\]+ {fwrite(yytext,1,yyleng,stream);}
<ENTERSTRING>\\. {fwrite(yytext,1,yyleng,stream);}
<ENTERSTRING>\) {
	BEGIN(INITIAL);
	long length = ftell(stream);
	rewind(stream);
	char*buffer=malloc(length+1);
	fread(buffer,1,length,stream);
	fclose(stream);
	stream=NULL;
	yylval.obj=cJSON_CreateString(buffer);
	free(buffer);
	return STRING;
	}
startxref {
	return STARTXREF;
}
%.*{EOL} {}

%%
int yywrap()
{
	return(1);
}
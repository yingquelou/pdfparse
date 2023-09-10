%{
#include "Stack.h"
#include "PdType.h"
static PdObj pdObjCreate(PdTypeInfo);
static void pdfStackPush(PdObj);
static long fileLeng,curPos;
StackL pdfStack;
%}

LB \[
RB \]
LD "<<"
RD ">>"
LA \<
RA \>
string \(.*\)
d [0-9]
w [0-9a-zA-Z]
xd [0-9A-Fa-f]
f {d}*\.{d}+
space " "
EOL (\r\n|\n)
keyword obj|endobj|stream|trailer|R|null|endstream|xref|startxref|f|n
name \/[^ ]+

%%

%.*$ {}
{space} {}
{string} {
    // fprintf(yyout,"string: %s\n",yytext);
    fprintf(yyout,"%s",yytext);
}
{keyword} {
    // fprintf(yyout,"keyword: %s\n",yytext);
    fprintf(yyout,"%s",yytext);
}
{EOL} {
	// fprintf(yyout,"EOL\n");
	fprintf(yyout,"\n");
}
{LB} {
    // fprintf(yyout,"LP: %s\n",yytext);
    fprintf(yyout,"%s",yytext);
}
{RB} {
    // fprintf(yyout,"LP: %s\n",yytext);
    fprintf(yyout,"%s",yytext);
}
{LD} {
    // fprintf(yyout,"LD: %s\n",yytext);
	pdfStackPush(pdObjCreate(pdOperateLD));
}
{RD} {
    // fprintf(yyout,"RD: %s\n",yytext);
	pdfStackPush(pdObjCreate(pdOperateRD));
}
{LA} {
    // fprintf(yyout,"LA: %s\n",yytext);
    fprintf(yyout,"%s",yytext);
}
{RA} {
    // fprintf(yyout,"RA: %s\n",yytext);
    fprintf(yyout,"%s",yytext);
}
{d}+   {
    // fprintf(yyout,"integer: %s\n",yytext);
	pdfStackPush(pdObjCreate(pdTypeInteger));
}
{xd}+ {
 	// fprintf(yyout,"xd: %s\n",yytext);
    fprintf(yyout,"%s",yytext);
}
{f}     {
    // fprintf(yyout,"float: %s\n",yytext);
    fprintf(yyout,"%s ",yytext);
}

{name} {
    // fprintf(yyout,"name: %s\n",yytext);
    fprintf(yyout,"%s ",yytext);
}

. {
    //fprintf(stdout,"%s\n",yytext);
}
%%
int yywrap()
{
	if ((curPos = ftell(yyin)) == EOF)
		return (1);
	else if (curPos < fileLeng)
		return 0;
	else
	{
		fclose(yyin);
		fclose(yyout);
		puts("OK");
		return (1);
	}
}
static void *pdExtra(void *entry, void *obj)
{
	*(PdDictionaryEntry *)entry = obj;
}
#include "List.h"
static void pdForOperateRD()
{
	PdDictionary dict = malloc(sizeof(pdDictionary));
	List *list = listCreate();
	PdDictionaryEntry entry = NULL;
	PdObj obj = NULL;
	size_t size = 0;
	while ((obj = StackLPop(&pdfStack)) && obj->typeInfo != pdOperateLD)
	{
		entry = malloc(sizeof(pdDictionaryEntry));
		entry->value = obj;
		entry->key = StackLPop(&pdfStack);
		listPush(list, entry);
		++size;
	}
	dict->size = size;
	dict->entries = malloc(sizeof(PdDictionaryEntry) * size);
	for (size_t i = 0; i < size; ++i)
	{
		listForeach(list, pdExtra, dict->entries + i);
	}
	listDestroy(list);
	obj = malloc(sizeof(pdObj));
	obj->obj = dict;
	obj->typeInfo = pdTypeDictionary;
	StackLPush(&pdfStack, obj);
}
static void pdfStackPush(PdObj obj)
{
	if (obj && obj->obj)
		switch (obj->typeInfo)
		{
		case pdTypeBoolean:
		case pdTypeInteger:
		case pdTypeReal:
		case pdTypeString:
		case pdTypeName:
		case pdOperateLS:
		case pdOperateLA:
		case pdOperateLD:
			StackLPush(&pdfStack, obj);
			break;
		case pdOperateRD:
			pdForOperateRD();
			free(obj);
			break;
		case pdOperateRA:
			// StackLPop(pdfStack);
			break;
		case pdOperateRS:
		case pdTypeArray:
		default:
			fprintf(stderr, "The Type is undefined!\n");
			break;
		}
}
static PdObj pdObjCreate(PdTypeInfo typeInfo)
{
	static PdObj obj = NULL;
	obj = malloc(sizeof(pdObj));
	switch (typeInfo)
	{
	case pdTypeBoolean:
	{
		PdBoolean b = malloc(sizeof(pdBoolean));
		*b = strstr(yytext, "true") ? true : false;
		obj->obj = b;
		obj->typeInfo = pdTypeBoolean;
	}
		return obj;
	case pdTypeInteger:
	{
		PdInteger i = malloc(sizeof(pdInteger));
		*i = atoll(yytext);
		obj->obj = i;
		obj->typeInfo = pdTypeInteger;
	}
		return obj;
	case pdTypeReal:
	{
		PdReal r = malloc(sizeof(pdReal));
		*r = strtold(yytext, NULL);
		obj->obj = r;
		obj->typeInfo = pdTypeReal;
	}
		return obj;
	case pdOperateLD:
		obj->obj = pdnull;
		obj->typeInfo = pdOperateLD;
		return obj;
	case pdOperateRD:
		obj->obj = pdnull;
		obj->typeInfo = pdOperateRD;
		return obj;
	default:
		fprintf(stderr, "The Type is undefined!\n");
		break;
	}
}
StackL pdfParse(const char *pdfPath)
{
	yyin = fopen(pdfPath, "r");
	fseek(yyin, 0, SEEK_END);
	fileLeng = ftell(yyin);
	curPos = 0;
	rewind(yyin);
	printf("%p\n", yyin);
	yylex();
	return pdfStack;
}
void test()
{
	pdfStackPush(pdObjCreate(pdTypeInteger));
}
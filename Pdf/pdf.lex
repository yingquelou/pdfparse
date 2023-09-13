%{
#ifdef DEBUG
#include "Stack/Stack.c"
#include "List/List.c"
#else
#include "Stack.h"
#include "List.h"
#endif
#include "PdType.h"
static PdObj pdObjCreate(PdTypeInfo);
static void pdfStackPush(PdObj);
static long fileLeng,curPos;
StackL pdfStack;
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
space " "
EOL (\r\n|\n)
keyword obj|endobj|stream|trailer|R|null|endstream|xref|startxref|f|n
name \/[^ \r\n]+

%%

%.*$ {}
{space} {}
true|false {
	pdfStackPush(pdObjCreate(pdTypeBoolean));
}
{d}+   {
	pdfStackPush(pdObjCreate(pdTypeInteger));
}
{f}     {
	pdfStackPush(pdObjCreate(pdTypeReal));
}
{name} {
 	pdfStackPush(pdObjCreate(pdTypeName));
}
{string} {
    pdfStackPush(pdObjCreate(pdTypeString));
}
\<{xd}*\> {
	pdfStackPush(pdObjCreate(pdTypeString));
}
{keyword} {
    fprintf(yyout,"keyword: %s\n",yytext);
}

{LD} {
	pdfStackPush(pdObjCreate(pdOperateLD));
}
{RD} {
	pdfStackPush(pdObjCreate(pdOperateRD));
}
{LA} {
	pdfStackPush(pdObjCreate(pdOperateLA));
}
{RA} {
	pdfStackPush(pdObjCreate(pdOperateRA));
}
{EOL} {
	fprintf(yyout,"EOL\n");
}

. {
    fprintf(yyout,"None: %s\n",yytext);
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
		return (1);
	}
}
static void *pdExtra(void *entry, void *obj)
{
	*(PdDictionaryEntry *)entry = obj;
}
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
		listForeach(list, pdExtra, dict->entries + i);
	listDestroy(list);
	free(list);
	obj = malloc(sizeof(pdObj));
	obj->obj = dict;
	obj->typeInfo = pdTypeDictionary;
	StackLPush(&pdfStack, obj);
}
static void *pdExtraArray(void *none, void *obj)
{
	return free(obj), NULL;
}
static void pdForOperateRA()
{
	PdArray arr = malloc(sizeof(pdArray));
	arr->arr;
	List *list = listCreate();
	PdObj obj = NULL;
	while ((obj = StackLPop(&pdfStack)) && obj->typeInfo != pdOperateLA)
		listPush(list, obj);
	free(obj);
	arr->size = list->length;
	arr->arr = malloc(sizeof(pdObj) * arr->size);
	size_t i = 0;
	for (Node *cur = list->head; cur; cur = cur->Next)
	{
		arr->arr[i++] = *(PdObj)(cur->Date);
	}
	listForeach(list, pdExtraArray, NULL);
	listDestroy(list);
	free(list);
	obj->obj = arr;
	obj->typeInfo = pdTypeArray;
	StackLPush(&pdfStack,obj);
}
static void pdfStackPush(PdObj obj)
{
	if (obj)
		switch (obj->typeInfo)
		{
		case pdTypeBoolean:
		case pdTypeInteger:
		case pdTypeReal:
		case pdTypeString:
		case pdTypeName:
		case pdOperateLA:
		case pdOperateLD:
			StackLPush(&pdfStack, obj);
			break;
		case pdOperateRD:
			pdForOperateRD();
			free(obj);
			break;
		case pdOperateRA:
			pdForOperateRA();
			free(obj);
			break;
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
	case pdTypeString:
	{
		PdString str = malloc(sizeof(pdString));
		str->length = yyleng - 2;
		str->str = malloc(yyleng - 1);
		memcpy(str->str, yytext + 1, yyleng - 2);
		str->str[yyleng - 3] = '\0';
		str->isHex = (yytext[0] == '(' ? false : true);
		obj->obj = str;
		obj->typeInfo = pdTypeString;
	}
		return obj;
	case pdTypeName:
	{
		PdName name = malloc(yyleng);
		memcpy(name, yytext + 1, yyleng - 1);
		name[yyleng - 1] = '\0';
		obj->obj = name;
		obj->typeInfo = typeInfo;
	}
		return obj;
	case pdOperateLA:
	case pdOperateRA:
	case pdOperateLD:
	case pdOperateRD:
		obj->obj = pdnull;
		obj->typeInfo = typeInfo;
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
	yyout=fopen("rest.txt","w");
	rewind(yyin);
	yylex();
	return pdfStack;
}
void test()
{
	pdfStackPush(pdObjCreate(pdTypeInteger));
}

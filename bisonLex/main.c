#include "main.h"
#include "cache.h"
extern cJSON *pdfObjOfJsonCache;
int pdf(const char *fileName, const char *cache)
{
    // yydebug=1;
    if (!fileName || strlen(fileName) == 0)
        return 1;
    if (!cache || strlen(cache) == 0)
        cache = tmpnam(NULL);
    pdfObjOfJsonCache = catheConfig(cache);
    yyin = fopen(fileName, "rb");
    if (yyin)
        return yyparse();
    return 1;
}
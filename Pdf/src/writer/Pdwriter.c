#include "Pdwriter.h"
#include <stdlib.h>
size_t PdWriteBoolean(FILE *file, PdBoolean pValue)
{
    if (!pValue || !file)
        return 0;
    if (*pValue)
        return fwrite("true", 1, 4, file);
    else
        return fwrite("false", 1, 5, file);
}

size_t PdWriteInteger(FILE *file, PdInteger pValue)
{
    if (!pValue || !file)
        return 0;
    int ct = fprintf(file, "%ld", *pValue);
    return ct > 0 ? ct : 0;
}

size_t PdWriteReal(FILE *file, PdReal pValue)
{
    if (!pValue || !file)
        return 0;
    int ct = fprintf(file, "%lf", *pValue);
    return ct > 0 ? ct : 0;
}

size_t PdWriteString(FILE *file, PdString pValue)
{
    if (!pValue || !file)
        return 0;
    return fwrite(pValue->buffer, 1, pValue->bufferSize, file);
}

size_t PdWriteXString(FILE *file, PdXString pValue)
{
    return PdWriteString(file, pValue);
}

size_t PdWriteStream(FILE *file, PdStream pValue)
{
    return PdWriteString(file, pValue);
}

size_t PdWriteName(FILE *file, PdName pValue)
{
    if (!pValue || !file)
        return 0;
    int ct = fprintf(file, "/%s", *pValue);
    return ct > 0 ? ct : 0;
}
static void *pdArrayMaper(void *obj, void *file)
{
    size_t *psz = malloc(sizeof(size_t));
    *psz = PdWriteObj(file, obj);
    return psz;
}
static void *getTotal(void *obj, void *total)
{
    *(size_t *)total += *(size_t *)obj;
    free(obj);
    return NULL;
}
size_t PdWriteArray(FILE *file, PdArray pValue)
{
    size_t num;
    ListD list = listDMap(pValue, pdArrayMaper, file);
    size_t total;
    listDestroy(list, getTotal, &total);
    return total;
}

size_t PdWriteDictionary(FILE *file, PdDictionary pValue){
    
}

size_t PdWriteIndirectObjRef(FILE *file, PdIndirectObjRef ref);

size_t PdWriteIndirectObj(FILE *file, PdIndirectObj obj);

size_t PdWriteXref(FILE *file, PdXref xref);

size_t PdWriteTrailer(FILE *file, PdTrailer trailer);

size_t PdWriteStartXref(FILE *file, PdStartXref obj);

size_t PdWriteObj(FILE *file, PdObj obj)
{
}

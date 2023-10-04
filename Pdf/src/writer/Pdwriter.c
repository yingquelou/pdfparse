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
    int ct = fprintf(file, "stream\n");
    if (ct <= 0)
        return 0;
    size_t ret = ct;
    ret += PdWriteString(file, pValue);
    ct = fprintf(file, "endstream\n");
    if (ct <= 0)
        return 0;
    return ret + ct;
}

size_t PdWriteName(FILE *file, PdName pValue)
{
    if (!pValue || !file)
        return 0;
    int ct = fprintf(file, "/%s", pValue);
    return ct > 0 ? ct : 0;
}
static void *pdListMaper(void *obj, void *file)
{
    size_t *psz = malloc(sizeof(size_t));
    *psz = PdWriteObj(file, obj);
    *psz += fwrite(" ", 1, 1, file);
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
    if (!pValue || !file)
        return 0;

    size_t total = 0;
    int tmp = 0;
    tmp = fprintf(file, "[");
    if (tmp <= 0)
        return 0;
    total += tmp;
    ListD list = listDMap(pValue, pdListMaper, file);
    listDestroy(list, getTotal, &total);
    tmp = fprintf(file, "]");
    if (tmp <= 0)
        return 0;
    return total + tmp;
}
static void *pdDictionaryMaper(void *obj, void *file)
{
    PdDictionaryEntry entry = (PdDictionaryEntry)obj;
    size_t *sz = calloc(1, sizeof(size_t));
    *sz += PdWriteObj(file, entry->key);
    *sz += fwrite(" ", 1, 1, file);
    *sz += PdWriteObj(file, entry->value);
    *sz += fwrite("\n", 1, 1, file);
    return sz;
}
size_t PdWriteDictionary(FILE *file, PdDictionary pValue)
{
    if (!pValue || !file)
        return 0;
    size_t total = 0;
    int tmp = 0;
    tmp = fprintf(file, "<<\n");
    if (tmp <= 0)
        return 0;
    total += tmp;
    ListD list = listDMap(pValue, pdDictionaryMaper, file);
    listDestroy(list, getTotal, &total);
    tmp = fprintf(file, ">>");
    if (tmp <= 0)
        return 0;
    return total + tmp;
}

size_t PdWriteIndirectObjRef(FILE *file, PdIndirectObjRef ref)
{
    if (!ref || !file)
        return 0;
    size_t ret = 0;
    ret = fprintf(file, "%ld %ld R", ref->id, ref->generation);
    return ref > 0 ? ret : 0;
}

size_t PdWriteIndirectObj(FILE *file, PdIndirectObj obj)
{

    if (!obj || !file)
        return 0;
    int tmp = 0;
    tmp = fprintf(file, "%ld %ld obj\n", obj->id, obj->generation);
    if (tmp <= 0)
        return 0;
    ListD list = listDMap(obj->objList, pdListMaper, file);
    size_t total = tmp;
    listDestroy(list, getTotal, &total);
    tmp = fprintf(file, "\nendobj");
    if (tmp <= 0)
        return 0;
    return total + tmp;
}
static void *pdXrefEntryMaper(void *obj, void *file)
{
    PdXrefEntry entry = (PdXrefEntry)obj;
    int sz = fprintf(file, "%010ld %05ld %c\n", entry->offset, entry->generation, entry->free);
    if (sz <= 0)
        return NULL;
    size_t *psz = malloc(sizeof(size_t));
    *psz = sz;
    return psz;
}
static void *pdXrefMaper(void *obj, void *file)
{
    PdXrefSubsection subXref = (PdXrefSubsection)obj;
    int tmp = 0;
    tmp = fprintf(file, "%ld %ld\n", subXref->startNum, subXref->length);
    if (tmp <= 0)
        return NULL;
    ListD list = listDMap(subXref->Entries, pdXrefEntryMaper, file);
    size_t total = tmp, *psz = malloc(sizeof(size_t));
    listDestroy(list, getTotal, &total);
    *psz = total;
    return psz;
}
size_t PdWriteXref(FILE *file, PdXref xref)
{
    if (!xref || !file)
        return 0;
    int tmp = 0;
    tmp = fprintf(file, "xref\n");
    if (tmp <= 0)
        return 0;
    ListD list = listDMap(xref, pdXrefMaper, file);
    size_t total = 0;
    listDestroy(list, getTotal, &total);
    return total;
}

size_t PdWriteTrailer(FILE *file, PdTrailer trailer)
{
    if (!trailer || !file)
        return 0;
    int tmp = fprintf(file, "trailer\n");
    if (tmp <= 0)
        return 0;
    return tmp + PdWriteDictionary(file, trailer);
}

size_t PdWriteStartXref(FILE *file, PdStartXref obj)
{
    if (!obj || !file)
        return 0;
    int tmp = fprintf(file, "trailer\n%ld", *obj);
    if (tmp <= 0)
        return 0;
    return tmp;
}
size_t PdWriteObj(FILE *file, PdObj obj)
{
    if (!obj)
    {
        int tmp = fprintf(file, "null");
        if (tmp <= 0)
            return 0;
        return tmp;
    }
    switch (obj->typeInfo)
    {
    case pdTypeBoolean:
        return PdWriteBoolean(file, obj->obj);
    case pdTypeInteger:
        return PdWriteInteger(file, obj->obj);
    case pdTypeReal:
        return PdWriteReal(file, obj->obj);
    case pdTypeString:
        return PdWriteString(file, obj->obj);
    case pdTypeXString:
        return PdWriteXString(file, obj->obj);
    case pdTypeStream:
        return PdWriteStream(file, obj->obj);
    case pdTypeName:
        return PdWriteName(file, obj->obj);
    case pdTypeArray:
        return PdWriteArray(file, obj->obj);
    case pdTypeDictionary:
        return PdWriteDictionary(file, obj->obj);
    case pdTypeIndirectObjRef:
        return PdWriteIndirectObjRef(file, obj->obj);
    case pdTypeIndirectObj:
        return PdWriteIndirectObj(file, obj->obj);
    case pdocXref:
        return PdWriteXref(file, obj->obj);
    case pdocTrailer:
        return PdWriteTrailer(file, obj->obj);
    case pdocStartXref:
        return PdWriteStartXref(file, obj->obj);
    default:
        perror("undefined");
        return 0;
    }
}

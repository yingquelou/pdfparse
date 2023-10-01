#include "PdfDestroy.h"
#include <stdlib.h>
void PdBooleanDestroy(PdBoolean pValue)
{
    if (pValue)
        free(pValue);
}
void PdIntegerDestroy(PdInteger pValue)
{
    if (pValue)
        free(pValue);
}
void PdRealDestroy(PdReal pValue)
{
    if (pValue)
        free(pValue);
}
void PdStringDestroy(PdString pValue)
{
    if (!pValue)
        return;
    if (pValue->buffer)
    {
        free(pValue->buffer);
        pValue->buffer = NULL;
    }
    free(pValue);
}
void PdXStringDestroy(PdXString pValue)
{
    PdStringDestroy(pValue);
}
void PdStreamDestroy(PdStream pValue)
{
    PdStringDestroy(pValue);
}
void PdNameDestroy(PdName pValue)
{
    if (pValue)
        free(pValue);
}
static int PdObjDestroyRef(void *obj, void *arg)
{
    return PdObjDestroy((PdObj)obj), 0;
}
void PdArrayDestroy(PdArray pValue)
{
    listDestroy(pValue, PdObjDestroyRef, NULL);
}
static int PdDictionaryEntryDestroy(void *entry, void *arg)
{
    if (entry)
    {
        PdDictionaryEntry e = (PdDictionaryEntry)entry;
        PdObjDestroy(e->key);
        PdObjDestroy(e->value);
        free(entry);
    }
}
void PdDictionaryDestroy(PdDictionary pValue)
{
    listDestroy(pValue, PdDictionaryEntryDestroy, NULL);
}
void PdIndirectObjRefDestroy(PdIndirectObjRef ref)
{
    if (ref)
        free(ref);
}
void PdIndirectObjDestroy(PdIndirectObj obj)
{
    if (obj)
    {
        listDestroy(obj->objList, PdObjDestroyRef, NULL);
        free(obj);
    }
}
static int PdXrefEntryDestroy(void *obj, void *arg)
{
    if (obj)
        free(obj);
}
static int PdXrefSubsectionDestroy(void *obj, void *arg)
{
    if (obj)
    {
        PdXrefSubsection subXref = (PdXrefSubsection)obj;
        listDestroy(subXref->Entries, PdXrefEntryDestroy, NULL);
        free(obj);
    }
}
void PdXrefDestroy(PdXref xref)
{
    listDestroy(xref, PdXrefSubsectionDestroy, NULL);
}
void PdTrailerDestroy(PdTrailer trailer)
{
    PdDictionaryDestroy(trailer);
}
void PdStartXrefDestroy(PdStartXref obj)
{
    PdIntegerDestroy(obj);
}
void PdObjDestroy(PdObj obj)
{
    if (obj && obj->obj)
    {
        switch (obj->typeInfo)
        {
        case pdTypeBoolean:
            PdBooleanDestroy(obj->obj);
            break;
        case pdTypeInteger:
            PdIntegerDestroy(obj->obj);
            break;
        case pdTypeReal:
            PdRealDestroy(obj->obj);
            break;
        case pdTypeString:
            PdStringDestroy(obj->obj);
            break;
        case pdTypeXString:
            PdXStringDestroy(obj->obj);
            break;
        case pdTypeName:
            PdNameDestroy(obj->obj);
            break;
        case pdTypeArray:
            PdArrayDestroy(obj->obj);
            break;
        case pdTypeDictionary:
            PdDictionaryDestroy(obj->obj);
            break;
        case pdTypeStream:
            PdStreamDestroy(obj->obj);
            break;
        case pdTypeIndirectObjRef:
            PdIndirectObjRefDestroy(obj->obj);
            break;
        case pdTypeIndirectObj:
            PdIndirectObjDestroy(obj->obj);
            break;
        case pdocXref:
            PdXrefDestroy(obj->obj);
            break;
        case pdocTrailer:
            PdTrailerDestroy(obj->obj);
            break;
        case pdocStartXref:
            PdStartXrefDestroy(obj->obj);
            break;
        default:
            fprintf(stderr, "The Type is undefined!\n");
            break;
        }
        obj->obj = NULL;
        free(obj);
    }
}
#include "pdType.h"
#include <stdlib.h>
#include "PdfDestroy.h"
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
    if (pValue && pValue->str)
    {
        pValue->length = 0;
        free(pValue->str);
        pValue->str = NULL;
    }
}
void PdNameDestroy(PdName pValue)
{
    if (pValue)
        free(pValue);
}
void PdObjDestroy(PdObj);
void PdArrayDestroy(PdArray pValue)
{
    if (pValue && pValue->arr && pValue->size)
        for (size_t i = pValue->size - 1; i; --i)
            PdObjDestroy(pValue->arr + i);
}
void PdDictionaryDestroy(PdDictionary pValue)
{
    if (pValue && pValue->entries && pValue->size)
    {
        PdDictionaryEntry entry = NULL;
        for (size_t i = pValue->size - 1; i; --i)
        {
            entry = pValue->entries[i];
            PdObjDestroy(entry->key);
            PdObjDestroy(entry->value);
        }
        free(pValue->entries);
        pValue->entries = NULL;
        pValue->size = 0;
    }
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
        case pdTypeName:
            PdNameDestroy(obj->obj);
            break;
        case pdTypeArray:
            PdArrayDestroy(obj->obj);
            break;
        case pdTypeDictionary:
            PdDictionaryDestroy(obj->obj);
            break;
        default:
            fprintf(stderr, "The Type is undefined!\n");
            break;
        }
        obj->obj = NULL;
        free(obj);
    }
}
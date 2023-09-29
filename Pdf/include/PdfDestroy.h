#ifndef PDFDESTROY_H
#define PDFDESTROY_H 1

#include "PdType.h"
void PdBooleanDestroy(PdBoolean pValue);

void PdIntegerDestroy(PdInteger pValue);

void PdRealDestroy(PdReal pValue);

void PdStringDestroy(PdString pValue);

void PdNameDestroy(PdName pValue);

void PdArrayDestroy(PdArray pValue);

void PdDictionaryDestroy(PdDictionary pValue);

void PdObjDestroy(PdObj obj);
#endif

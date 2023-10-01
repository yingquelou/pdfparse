#ifndef PDFDESTROY_H
#define PDFDESTROY_H 1
#include "Pdocument.h"
extern void PdBooleanDestroy(PdBoolean pValue);

extern void PdIntegerDestroy(PdInteger pValue);

extern void PdRealDestroy(PdReal pValue);

extern void PdStringDestroy(PdString pValue);

extern void PdXStringDestroy(PdXString pValue);

extern void PdStreamDestroy(PdStream pValue);

extern void PdNameDestroy(PdName pValue);

extern void PdArrayDestroy(PdArray pValue);

extern void PdDictionaryDestroy(PdDictionary pValue);

extern void PdIndirectObjRefDestroy(PdIndirectObjRef ref);

extern void PdIndirectObjDestroy(PdIndirectObj obj);

extern void PdXrefDestroy(PdXref xref);

extern void PdTrailerDestroy(PdTrailer trailer);

extern void PdStartXrefDestroy(PdStartXref obj);

extern void PdObjDestroy(PdObj obj);

#endif
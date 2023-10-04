#ifndef PDWRITER_H
#define PDWRITER_H 1
#include"Pdocument.h"
size_t PdWriteBoolean(FILE *file, PdBoolean pValue);

size_t PdWriteInteger(FILE *file, PdInteger pValue);

size_t PdWriteReal(FILE *file, PdReal pValue);

size_t PdWriteString(FILE *file, PdString pValue);

size_t PdWriteXString(FILE *file, PdXString pValue);

size_t PdWriteStream(FILE *file, PdStream pValue);

size_t PdWriteName(FILE *file, PdName pValue);

size_t PdWriteArray(FILE *file, PdArray pValue);

size_t PdWriteDictionary(FILE *file, PdDictionary pValue);

size_t PdWriteIndirectObjRef(FILE *file, PdIndirectObjRef ref);

size_t PdWriteIndirectObj(FILE *file, PdIndirectObj obj);

size_t PdWriteXref(FILE *file, PdXref xref);

size_t PdWriteTrailer(FILE *file, PdTrailer trailer);

size_t PdWriteStartXref(FILE *file, PdStartXref obj);

size_t PdWriteObj(FILE *file, PdObj obj);

#endif
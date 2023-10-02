#ifndef PDWRITER_H
#define PDWRITER_H 1
#include"Pdocument.h"
size_t PdWriteBoolean(FILE *file, PdBoolean pValue);

size_t PdWriteObj(FILE *file, PdObj obj);

#endif


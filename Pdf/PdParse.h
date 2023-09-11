#ifndef PDPARSE_H
#define PDPARSE_H 1
#ifdef DEBUG
#include"Stack/Stack.h"
#else
#include "Stack.h"
#endif
StackL pdfParse(const char*pdfPath);
#endif
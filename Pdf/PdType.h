#ifndef PDTYPE_H
#define PDTYPE_H 1
#include <stdbool.h>
#ifndef DEBUG 
#include "List/listd.h"
#else
#include "listd.h"
#endif
#include <stdio.h>
#include "PdTypeInfo.h"

// base type - null object
#define pdnull ((void *)0)
// base type - Boolean
typedef bool pdBoolean, *PdBoolean;
// base type - Integer
typedef long long pdInteger, *PdInteger;
// base type - Real numbers
typedef double pdReal, *PdReal;
// base type - strings
typedef struct pdString
{
    // 缓冲区大小
    size_t bufferSize;
    // 缓冲区
    char *buffer;
} pdString,pdXString,pdStream, *PdString,*PdXString,*PdStream;
// base type - Name
// 注意:名字类型要么都是动态分配,要么都不是
typedef char *PdName;
typedef struct pdDictionaryEntry
{
    PdObj key;
    PdObj value;
} pdDictionaryEntry, *PdDictionaryEntry;
// 字典条目类型为PdDictionaryEntry
// 数组元素类型为PdObj
typedef ListDNode pdDictionary, *PdDictionary, pdArray, *PdArray;
#endif
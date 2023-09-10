#ifndef PDTYPE_H
#define PDTYPE_H 1
#include <stdbool.h>
typedef enum pdTypeInfo
{
    /* 操作数 */
    // 简单类型

    pdTypeBoolean,
    pdTypeInteger,
    pdTypeReal,
    pdTypeString,
    pdTypeName,
    // 复合类型

    pdTypeArray,
    pdTypeDictionary,
    pdTypeStream,
    pdTypeObjsXrefNum,

    /* 操作符 */
    pdOperateLS,
    pdOperateRS,
    pdOperateLA,
    pdOperateRA,
    pdOperateLD,
    pdOperateRD,
} PdTypeInfo;
// base type - null object
#define pdnull ((void *)0)
// base type - Boolean
typedef bool pdBoolean, *PdBoolean;
// base type - Integer
typedef long long pdInteger, *PdInteger;
// base type - Real numbers
typedef long double pdReal, *PdReal;
#include <stdio.h>
// base type - strings
typedef struct pdString
{
    // 字符(串)序列大小长度
    size_t length;
    // 表示是否是十六进制字符(串)序列
    bool isHex;
    // 字符(串)序列
    char *str;
} pdString, *PdString;
// base type - Name
// 注意:名字类型要么都是动态分配,要么都不是
typedef char *PdName;
// 任意pdf类型对象的引用
typedef struct pdObj
{
    // 指向任意pdf类型对象
    void *obj;
    // 该对象的类型信息
    PdTypeInfo typeInfo;
} pdObj, *PdObj;
// 与交叉引用表条目相对应
typedef struct pdObjsXrefNum
{
    unsigned long long objectNumber;
    unsigned long long generation;
} pdObjsXrefNum, *PdObjsXrefNum;

// pdf主体的基本单元 - Indirect Objects
// 即表示整个
// n1 n2 obj
// ...
// endobj
// 对象
typedef struct pdObjs
{
    // 当前对象在交叉引用表的编号信息
    pdObjsXrefNum xrefNum;
    // 持有当前对象的所有
    // 内嵌对象
    PdObj objs;
    // 内嵌对象的数量
    size_t num;
} pdObjs, *PdObjs;
typedef struct pdArray
{
    size_t size;
    PdObj arr;
} pdArray, *PdArray;
typedef struct pdDictionaryEntry
{
    PdObj key;
    PdObj value;
} pdDictionaryEntry, *PdDictionaryEntry;

typedef struct pdDictionary
{
    size_t size;
    PdDictionaryEntry *entries;
} pdDictionary, *PdDictionary;
/* 流对象
 * Key|Type|Value
 * -|-|-
 * Length|integer|（必填）从关键字流后面的行首到关键字结束流之前的最后一个字节的字节数。（可能还有一个额外的 EOL 标记，即结束流之前，该标记未包含在计数中，并且在逻辑上不是流数据的一部分。有关进一步讨论，请参见 7.3.8.2 “流范围”。
 * 过滤器|名称或数组|（可选）在处理关键字流和结束流之间找到的流数据或零个、一个或多个名称的数组时应应用的过滤器的名称。应按应用顺序指定多个过滤器。
 * DecodeParms|dictionary or array|（可选）参数字典或此类字典的数组，由 Filter 指定的筛选器使用。如果只有一个过滤器并且该过滤器具有参数，则应将解码参数设置为过滤器的参数字典，除非过滤器的所有参数都有其默认值，在这种情况下，可以省略解码Parms 条目。如果有多个过滤器，并且任何过滤器的参数设置为非默认值，则 DecodeParms 应是一个数组，每个过滤器都有一个条目：该过滤器的参数字典，或者如果该过滤器没有参数（或者如果其所有参数都有其默认值），则为 null 对象。如果所有筛选器都没有参数，或者其所有参数都具有默认值，则可以省略 DecodeParms 条目。
 * F|file specification|（可选;PDF 1.2） 包含流数据的文件。如果存在此条目，则应忽略流和结束流之间的字节。但是，Length 条目仍应指定这些字节的数量（通常，没有字节，长度为 0）。应用于文件数据的过滤器应由 FFilter 指定，过滤器参数应由 FDecodeParms 指定。
 * FFilter|name or array|（可选;PDF 1.2） 用于处理在流的外部文件或零个、一个或多个此类名称的数组中找到的数据时应用的过滤器的名称。规则与筛选器相同。
 * FDecodeParms|dictionary or array|（可选;PDF 1.2） 由 FFilter 指定的过滤器使用的参数字典或此类字典的数组。与DecodeParms相同的规则适用。
 * DL|integer|（可选;PDF 1.5） 一个非负整数，表示解码（去过滤）流中的字节数。例如，它可用于确定是否有足够的磁盘空间将流写入文件。此值应仅被视为提示;对于某些流筛选器，可能无法精确确定此值。
 */
typedef pdObjs pdStream, *PdStream;
/*
 * 对象流
 * 对象流共含两个部分,第一部分是一个字典,用于描述第二部分的结构信息,其要求如下所示:
 * key|type|description
 * -|-|-
 * Type|name|（必填）此字典描述的 PDF 对象的类型;对于对象流，应为“ObjStm”。
 * N|integer|（必填）流中存储的间接对象数。
 * First|integer|（必填）第一个压缩对象的解码流中的字节偏移量。
 * Extends|stream|（可选）对另一个对象流的引用，其中当前对象流应被视为扩展。这两个流都被视为对象流集合的一部分（见下文）。给定集合由一组流组成，这些流的扩展链接形成有向无环图。
 * 第二部分是是一个流(由stream、endstream包裹的)
 * 在这个流内部:
 *  - 开头是成对出现的整数,一共N对(就是上述字典中N的值)
 *  - 之后是一共N个字典
 *
 */
typedef pdObjs pdObjsStream, *PdObjsStream;

#endif
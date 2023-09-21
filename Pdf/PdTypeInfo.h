#ifndef PDTYPEINFO_H
#define PDTYPEINFO_H 1
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
    pdTypeIndirectObj,
    pdTypeIndirectObjRef,

    pdTypeStream,
    pdTypeObjsXrefNum,

    /* 操作符 */
    pdOperateLA,
    pdOperateRA,
    pdOperateLD,
    pdOperateRD,
} PdTypeInfo;
// 非pdf类型,旨在引用pdf类型对象
typedef struct pdObj
{
    // 指向任意pdf类型对象
    void *obj;
    // 该对象的类型信息
    PdTypeInfo typeInfo;
} pdObj, *PdObj;
#endif
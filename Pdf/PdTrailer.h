#ifndef PDTRAILER_H
#define PDTRAILER_H 1
#include "PdType.h"
/* 
 * 对Trailer字典的要求:
 * Key|Type|Value
 * -|-|-
 * `Size`|`integer`|（必填;不得间接参考）文件的交叉引用表中的条目总数，由原始节和所有更新节的组合定义。等效地，此值应比文件中定义的最高对象编号大 1。交叉引用节中编号大于此值的任何对象都应被忽略，并由符合要求的读者定义为缺失。
 * `Prev`|`integer`|（仅当文件有多个交叉引用部分时才存在;应为间接引用）解码流中从文件开头到上一个交叉引用部分开头的字节偏移量。
 * `Root`|`dictionary`|（必填;应为间接参考）文件中包含的 PDF 文档的目录字典（请参见 7.7.2 “文档目录”）。
 * `Encrypt`|`dictionary`|（如果文档已加密，则为必填项;PDF 1.1）文档的加密词典（见7.6，“加密”）。
 * `Info`|`dictionary`|（可选;应为间接参考）文档的信息字典（请参见 14.3.3 “文档信息字典”）。
 * `ID`|`array`|（如果存在加密条目，则为必需;否则可选;PDF 1.1）一个由两个字节字符串组成的数组，构成文件的文件标识符（参见14.4，“文件标识符”）。如果存在加密条目，则此数组和两个字节字符串应为直接对象，并且应未加密。注 1：由于 ID 条目未加密，因此可以检查 ID 密钥以确保在不解密文件的情况下访问正确的文件。字符串是直接对象且未加密的限制确保了这是可能的。注 2：尽管此条目是可选的，但缺少此条目可能会阻止文件在某些依赖于唯一标识文件的工作流中运行。注 3 ID 字符串的值用作加密算法的输入。如果这些字符串是间接的，或者 ID 数组是间接的，则这些字符串在写入时将被加密。这将导致读取器的循环条件：必须解密 ID 字符串才能使用它们解密字符串，包括 ID 字符串本身。上述限制可防止此循环情况。
 * 
 */
typedef pdDictionary pdTrailer, *PdTrailer;

#endif
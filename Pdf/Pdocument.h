#ifndef PDOCUMENT_H
#define PDOCUMENT_H 1
#include "PdType.h"
// pdf主体的基本单元 - Indirect Objects
// 即表示整个
// n1 n2 obj
// ...
// endobj
// 对象
typedef struct pdIndirectObj
{
    // 当前对象在交叉引用表的编号信息
    PdInteger id;
    PdInteger generation;
    // 持有当前对象的所有内嵌对象
    ListD objList;
} pdIndirectObj, *PdIndirectObj;
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
typedef pdIndirectObj pdStream, *PdStream;
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
typedef pdIndirectObj pdObjsStream, *PdObjsStream;

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
#define OFFSETMAX 0x2540BE3FFu
#define GENERATIONMAX 0xFFFFu
/* pdf的交叉引用表 */

// 交叉引用表条目
typedef struct pdXrefEntry
{
    // 若当前条目已使用,
    // 表示当前对象相对于当前pdf文件流开头的偏移量,其值不得大于OFFSETMAX;
    // 若当前条目空闲,其值指向下一个空闲条目,那么所有空闲条目构成一条链表
    // 整个交叉引用表的的第一个条目是这条链表的首元节点,
    // 而且整个交叉引用表的最后一个空闲条目亦指向链表的首元节点,
    // 即此链表是循环的,是一个循环链表
    PdInteger offset;
    // 应表示当前对象已被修改的次数
    // 在pdf文件的一次打开-保存周期内至少修改过一次,则generation增长1
    // 若pdf读写引擎比较宽松,不严格执行generation的增长,亦无伤大雅
    // 即当前对象的版本代号,其值不得大于GENERATIONMAX
    // 新对象,代号为0
    // 对整个交叉引用表的的第一个条目,其值始终为GENERATIONMAX
    PdInteger generation;
    // 表示当前条目是否处于空闲状态,f-空闲,n-非空闲
    char free;
} pdXrefEntry, *PdXrefEntry;
// 交叉引用表的小节(子表)
typedef struct pdXrefSubsection
{
    // 当前小节的起始对象编号
    PdInteger startNum;
    // 当前小节的的长度(条目数)
    PdInteger length;
    ListD Entries;
} pdXrefSubsection, *PdXrefSubsection;

// 交叉引用表
typedef struct pdXref
{
    // 持有交叉引用表的所有小节(子表)
    ListD sections;
    // 小节(子表)的数目
    PdInteger num;
} pdXref, *PdXref;
#endif
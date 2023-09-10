/* pdf的交叉引用表 */
#ifndef PDXREF_H
#define PDXREF_H 1
#define OFFSETMAX 0x2540BE3FFu
#define GENERATIONMAX 0xFFFFu
// 交叉引用表条目
typedef struct pdXrefEntry
{
    // 若当前条目已使用,
    // 表示当前对象相对于当前pdf文件流开头的偏移量,其值不得大于OFFSETMAX;
    // 若当前条目空闲,其值指向下一个空闲条目,那么所有空闲条目构成一条链表
    // 整个交叉引用表的的第一个条目是这条链表的首元节点,
    // 而且整个交叉引用表的最后一个空闲条目亦指向链表的首元节点,
    // 即此链表是循环的,是一个循环链表
    unsigned long long offset;
    // 应表示当前对象已被修改的次数
    // 在pdf文件的一次打开-保存周期内至少修改过一次,则generation增长1
    // 若pdf读写引擎比较宽松,不严格执行generation的增长,亦无伤大雅
    // 即当前对象的版本代号,其值不得大于GENERATIONMAX
    // 新对象,代号为0
    // 对整个交叉引用表的的第一个条目,其值始终为GENERATIONMAX
    unsigned long long generation;
    // 表示当前条目是否处于空闲状态,f-空闲,n-非空闲
    char free;
} pdXrefEntry, *PdXrefEntry;
// 交叉引用表的小节(子表)
typedef struct pdXrefSubsection
{
    // 当前小节的起始对象编号
    unsigned long long startNum;
    // 当前小节的的长度(条目数)
    unsigned long long length;
    PdXrefEntry Entries;
} pdXrefSubsection, *PdXrefSubsection;

// 交叉引用表
typedef struct pdXref
{
    // 持有交叉引用表的所有小节(子表)
    PdXrefSubsection sections;
    // 小节(子表)的数目
    unsigned long long num;
} pdXref, *PdXref;

#endif
#ifndef LISTD_H
#define LISTD_H 1
// 定义双向链表	doubly linked list
typedef struct node
{
	// 数据域类型的指针
	void *data;
	// 指针域
	struct node *prev;
	struct node *next;
	// 以上三个指针都应指向动态分配的对象
} *ListD, ListDNode;
// 以`D`为后缀的是双向链表版本,下同
extern ListD listDCreate(void);
// 链表存在的话返回其首节点，否则返回空指针
ListDNode *listDBegin(ListDNode *);
// 链表存在的话返回其尾结点，否则返回空指针
extern ListDNode *listDEnd(ListDNode *);
//
/**
 * \brief 在某个有效结点之后插入一个新的结点用于放置某个有效数据
 *
 * \return  成功返回该新节点,否则返回NULL
 * \date by yingquelou at 2023-09-14 20:10:19
 */
extern ListDNode *listDInsertAfterNode(ListDNode *, void *);
extern ListDNode *listDInsertBeforeNode(ListDNode *node, void *d);
/**
 * \brief 在链表末尾插入一个新的结点用于放置某个有效数据
 *
 * \return  成功返回该新节点,否则返回NULL
 * \date by yingquelou at 2023-09-14 20:10:19
 */
extern ListDNode *listDPushBack(ListD, void *);
extern ListDNode *listDPushFront(ListD, void *);
typedef int (*listOperator)(void *, void *);
/**
 * \brief 遍历链表,对各结点的数据域调用某个函数做某种操作
 * 本函数的第三个参数会被转发给操作子的第二个参数
 * 操作子的第一个参数用于接收数据
 * 注意:本函数的第一个参数可以不是链表头结点,
 * 但依旧是对整个链表进行操作
 * \date by yingquelou at 2023-09-14 20:17:55
 */
extern void listDForEach(ListDNode *, listOperator, void *);
/**
 * \brief 销毁链表
 * 行为与ListDForEach函数相同,但同时进行链表的销毁
 * 当第二个参数为NULL时,表示只销毁链表本身,此时第三个参数无意义
 * \date by yingquelou at 2023-09-14 20:47:49
 */
extern void listDestroy(ListDNode *, listOperator, void *);
/**
 * \brief 返回第一个满足要求(能令操作子返回0)的节点.
 * 本函数的第三个参数会被转发给操作子的第二个参数
 * 操作子的第一个参数用于接收数据域指针
 * \return 未找到返回NULL
 * \date by yingquelou at 2023-09-15 18:31:24
 */
extern ListDNode *listDSearch(ListDNode *, listOperator, void *);
/**
 * \return 当被删除节点为NULL时返回NULL,表示删除失败;
 * 被删除节点保存的数据将通过第二个参数返回
 * 当被删除节点非NULL时,返回其前向节点;若前向节点为空则返回后向节点
 *
 * \date by yingquelou at 2023-09-14 21:27:00
 */
extern ListDNode *listDeleteNode(ListDNode *, void **);
extern ListDNode *listDPopFront(ListDNode *, void **);
extern ListDNode *listDPopBack(ListDNode *node, void **pData);
#endif
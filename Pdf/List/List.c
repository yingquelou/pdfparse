#include "List.h"
#include <stdlib.h>
List *listCreate()
{
    return calloc(1, sizeof(List));
}
bool listIsEmpty(List *pl)
{
    return pl ? (*pl ? false : true) : true;
}
Node *listLastNode(List *pl)
{
    if (!pl)
        return NULL;
    Node *cur = *pl, *last = NULL;
    while (cur)
    {
        last = cur;
        cur = cur->Next;
    }
    return last;
}
Node *nodeCreate(const void *Data)
{
    Node *node = malloc(sizeof(Node));
    if (node)
    {
        node->Date = (void *)Data;
        node->Next = NULL;
    }
    return node;
}
bool listPush(List *pl, const void *Data)
{
    if (!pl || !Data)
        return false;
    Node *cur = nodeCreate(Data);
    if (!cur)
        return false;
    Node *last = listLastNode(pl);
    if (last)
        last->Next = cur;
    else
        *pl = cur;
    return true;
}
void listForeach(List *pl, Func fun, void *funArgs)
{
    if (!pl || !fun)
        return;
    Node *cur = *pl;
    while (cur)
    {
        fun(funArgs, cur->Date);
        cur = cur->Next;
    }
}
void listDestroy(List *pl)
{
    if (!pl)
        return;
    Node *cur = *pl, *tmp = NULL;
    while (cur)
    {
        tmp = cur;
        cur = cur->Next;
        free(tmp);
    }
    *pl = NULL;
}
size_t listLength(const List *pl)
{
    if (!pl)
        return 0;
    Node *cur = *pl;
    size_t lg = 0;
    while (cur)
    {
        ++lg;
        cur = cur->Next;
    }
    return lg;
}
void listQsort(List *pl, const Comparator cmp)
{
    size_t lg = listLength(pl);
    if (lg < 2 || !cmp)
        return;
    void **arr = malloc(sizeof(void *) * lg);
    size_t i;
    Node *cur;
    for (i = 0, cur = *pl; cur; ++i, cur = cur->Next)
        arr[i] = cur->Date;
    qsort(arr, lg, sizeof(void *), cmp);
    for (i = 0, cur = *pl; cur; ++i, cur = cur->Next)
        cur->Date = arr[i];
    free(arr);
}
static void *dataDestroy(void *data,void*no)
{
    return free(data), NULL;
}
List listCopy(List *pl, Func copy)
{
    if (!copy || listIsEmpty(pl))
        return NULL;
    Node *curs = *pl, *pNode = NULL, **lcp = listCreate(), *curc = NULL;
    void *Data = NULL;
    do
    {
        if ((Data = copy(curs->Date,NULL)) && (pNode = nodeCreate(Data)))
        {
            if (*lcp)
                curc->Next = pNode;
            else
                *lcp = pNode;
            curc = pNode;
            curs = curs->Next;
        }
        else
        {
            listForeach(lcp, dataDestroy, NULL);
            listDestroy(lcp);
            return NULL;
        }
    } while (curs);
    curc = *lcp;
    free(lcp);
    return curc;
}
List listMerge(List *first, List *second, const Comparator cmp)
{
    if (listIsEmpty(first) || listIsEmpty(second) || !cmp)
        return NULL;
    listLastNode(first)->Next = *second;
    listQsort(first, cmp);
    return *first;
}
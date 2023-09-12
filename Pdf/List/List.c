#include "List.h"
#include <stdlib.h>
List *listCreate()
{
    return calloc(1, sizeof(List));
}
bool listIsEmpty(const List *pl)
{
    if (pl && pl->head)
        return false;
    return true;
}
Node *listLastNode(List *pl)
{
    if (listIsEmpty(pl))
        return NULL;
    return pl->last;
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
    if (pl->head)
    {
        pl->last->Next = cur;
        pl->last = cur;
        ++(pl->length);
    }
    else
    {
        pl->head = cur;
        pl->last = cur;
        pl->length = 1;
    }
    return true;
}
void listForeach(List *pl, Func fun, void *funArgs)
{
    if (!pl || !fun)
        return;
    Node *cur = pl->head;
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
    Node *cur = pl->head, *tmp = NULL;
    while (cur)
    {
        tmp = cur;
        cur = cur->Next;
        free(tmp);
    }
    pl->head = NULL;
    pl->last = NULL;
    pl->length = 0;
}
size_t listLength(const List *pl)
{
    if (listIsEmpty(pl))
        return 0;
    return pl->length;
}
void listQsort(List *pl, const Comparator cmp)
{
    size_t lg = listLength(pl);
    if (lg < 2 || !cmp)
        return;
    void **arr = malloc(sizeof(void *) * lg);
    size_t i;
    Node *cur;
    for (i = 0, cur = pl->head; cur; ++i, cur = cur->Next)
        arr[i] = cur->Date;
    qsort(arr, lg, sizeof(void *), cmp);
    for (i = 0, cur = pl->head; cur; ++i, cur = cur->Next)
        cur->Date = arr[i];
    free(arr);
}
List *listMerge(List *first, List *second, const Comparator cmp)
{
    if (listIsEmpty(first) || listIsEmpty(second) || !cmp)
        return NULL;
    listLastNode(first)->Next = second->head;
    listQsort(first, cmp);
    second->head = NULL;
    second->last = NULL;
    second->length = 0;
    return first;
}
void listReverse(List *list)
{
    if (listIsEmpty(list))
        return;
    Node *dest = NULL, *moved = NULL, *source = list->head;
    list->last = source;
    while (source)
    {
        moved = source;
        source = source->Next;
        moved->Next = dest;
        dest = moved;
    }
    list->last->Next = NULL;
}
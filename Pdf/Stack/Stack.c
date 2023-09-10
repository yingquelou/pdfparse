#include "Stack.h"
/* 一、顺序栈  sequence stack  -->StackS */
StackS *StackSCreate(const unsigned stacksize)
{
    StackS *ps = NULL;
    if (ps = malloc(sizeof(StackS)))
    {
        if (ps->base = calloc(stacksize, sizeof(void *)))
        {
            ps->top = ps->base;
            ps->size = stacksize;
        }
        else
        {
            free(ps);
            ps = NULL;
        }
    }
    return ps;
}
bool StackSFull(const StackS *const ps)
{
    if ((ps->top - ps->base) == ps->size)
        return true;
    return false;
}
bool StackSPush(StackS *const ps, const void *const pData)
{
    if (StackSFull(ps))
        return false;
    *ps->top++ = (void *)pData;
    return true;
}
bool StackSEmpty(const StackS *const ps)
{
    return ps->base == ps->top;
}
void *StackSPop(StackS *const ps)
{
    if (StackSEmpty(ps))
        return NULL;
    return *--ps->top;
}
void StackSForeach(const StackS *const ps, const sFunc fun)
{
    if (StackSEmpty(ps))
        return;
    void **cur = ps->top;
    while (cur != ps->base)
        fun(*--cur);
}
void StackSDestroy(StackS *ps)
{
    if (ps)
    {
        if (ps->size)
            free(ps->base);
        free(ps);
    }
}
/* 二、链栈    list stack      -->StackL */
bool StackLEmpty(const StackL *const ps)
{
    return ps ? (*ps ? false : true) : true;
}
StackL *StackLCreate()
{
    return calloc(1, sizeof(StackL));
}
bool StackLPush(StackL *const ps, const void *const pData)
{
    if (!ps)
        return false;
    if (*ps)
    {
        StackNodeL *pNode = malloc(sizeof(StackNodeL));
        if (!pNode)
            return false;
        pNode->Next = *ps;
        pNode->pData = (void *)pData;
        *ps = pNode;
        return true;
    }
    else if (*ps = malloc(sizeof(StackNodeL)))
    {
        (*ps)->Next = NULL;
        (*ps)->pData = (void *)pData;
        return true;
    }
    return false;
}
void *StackLPop(StackL *const ps)
{
    if (StackLEmpty(ps))
        return NULL;
    StackNodeL *tmp = *ps;
    *ps = (*ps)->Next;
    void *pData = tmp->pData;
    free(tmp);
    return pData;
}
void StackLForeach(const StackL *const ps, const sFunc fun)
{
    if (StackLEmpty(ps))
        return;
    StackNodeL *cur = *ps;
    while (cur)
    {
        fun(cur->pData);
        cur = cur->Next;
    }
}
void StackLDestroy(StackL *ps)
{
    if (ps)
    {
        StackNodeL *tmp, *cur = *ps;
        while (cur)
        {
            tmp = cur;
            cur = cur->Next;
            free(tmp);
        }
        *ps = NULL;
    }
}
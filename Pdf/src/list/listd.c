#include "listd.h"
#include <stdio.h>
#include <stdlib.h>
ListDNode *listDBegin(ListDNode *node)
{
	ListDNode *begin = NULL;
	while (node)
	{
		begin = node;
		node = node->prev;
	}
	return begin;
}
ListDNode *listDEnd(ListDNode *node)
{
	ListDNode *end = NULL;
	while (node)
	{
		end = node;
		node = node->next;
	}
	return end;
}
ListDNode *listDInsertAfterNode(ListDNode *node, void *d)
{
	ListDNode *cur = malloc(sizeof(ListDNode));
	cur->data = d;
	if (node)
	{
		cur->next = node->next;
		cur->prev = node;

		node->next = cur;

		if (cur->next)
			cur->next->prev = cur;
	}
	else
	{
		cur->next = NULL;
		cur->prev = NULL;
	}
	return cur;
}
ListDNode *listDInsertBeforeNode(ListDNode *node, void *d)
{
	if (!node)
		return listDInsertAfterNode(NULL, d);
	if (node->prev)
		return listDInsertAfterNode(node->prev, d);
	else
	{
		node->prev = listDInsertAfterNode(NULL, d);
		node->prev->next = node;
		return node->prev;
	}
}
ListDNode *listDPushBack(ListD head, void *d)
{
	return listDInsertAfterNode(listDEnd(head), d);
}
ListDNode *listDPushFront(ListD head, void *d)
{
	return listDInsertBeforeNode(listDBegin(head), d);
}
void listDForEach(ListDNode *node, listOperator func, void *arg)
{
	node = listDBegin(node);
	while (node)
	{
		func(node->data, arg);
		node = node->next;
	}
}
void listDestroy(ListDNode *node, listOperator func, void *arg)
{
	node = listDBegin(node);
	ListDNode *destroy = NULL;
	while (node)
	{
		if (func)
			func(node->data, arg);
		destroy = node;
		node = node->next;
		free(destroy);
	}
}
ListDNode *listDSearch(ListDNode *node, listOperator func, void *arg)
{
	if (!node || !func)
		return NULL;
	node = listDBegin(node);
	while (node)
	{
		if (func(node->data, arg))
			node = node->next;
		else
			break;
	}
	return node;
}
ListDNode *listDeleteNode(ListDNode *node, void **pData)
{
	if (!node)
	{
		*pData = NULL;
		return NULL;
	}
	ListDNode *front = node->prev;
	if (front)
	{
		front->next = node->next;
		if (front->next)
			front->next->prev = front;
	}
	else
		front = node->next;
	*pData = node->data;
	node->next = NULL;
	node->prev = NULL;
	node->data = NULL;
	free(node);
	return front;
}
ListDNode *listDPopFront(ListDNode *node, void **pData)
{
	return listDeleteNode(listDBegin(node), pData);
}
ListDNode *listDPopBack(ListDNode *node, void **pData)
{
	return listDeleteNode(listDEnd(node), pData);
}

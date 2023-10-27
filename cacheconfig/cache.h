#pragma once
#ifndef CACHE_H
#define CACHE_H 1
#include <cjson/cJSON.h>
#ifdef __cplusplus
extern "C" {
#endif
cJSON *catheConfig(const char *cachePath);
#ifdef __cplusplus
}
#endif
#endif

#include <filesystem>
#include <iostream>
#include <map>
#include "cache.h"
cJSON *catheConfig(const char *cachePath)
{
    auto &&dir = std::filesystem::absolute(std::filesystem::path(cachePath));
    std::map<std::string, std::filesystem::path> map;
    map.emplace("obj", dir / "obj");
    map.emplace("xref", dir / "xref");
    map.emplace("trailer", dir / "trailer");
    map.emplace("startxref", dir / "startxref");
    map.emplace("stream", dir / "stream");
    map.emplace("others", dir / "others");
    cJSON *cacheIndex = cJSON_CreateObject();
    for (auto &&i : map)
    {
        cJSON_AddItemToObject(cacheIndex, i.first.c_str(), cJSON_CreateString(i.second.c_str()));
        std::filesystem::create_directories(i.second);
        // std::cout << i.first << '\t' << i.second << '\n';
    }
    return cacheIndex;
}
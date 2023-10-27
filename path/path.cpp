#include <filesystem>
#include <string>
#include "path.h"
static char *string2c_str(std::string &&s)
{
    auto &&sz = s.size();
    char *ps = static_cast<char *>(malloc(sz + 1));
    ps[sz] = '\0';
    memmove(ps, s.c_str(), sz);
    return ps;
}
char *getCurrent_path()
{
    return string2c_str(std::filesystem::current_path().string());
}
char *getParentDir(const char *PathArg)
{
    return string2c_str(std::filesystem::absolute(std::filesystem::path(PathArg)).parent_path().string());
}
char *createPath(const char *parent, const char *child)
{
    return string2c_str(std::filesystem::path(parent).append(child).string());
}
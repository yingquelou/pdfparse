#ifndef PDF_H
#define PDF_H 1
#include <string>
#include <map>
#include <vector>
struct Object;
using PdDict = std::map<std::string, Object>;
using PdArray = std::vector<Object>;
using PdObjNum = std::pair<std::size_t, std::size_t>;
using PdObj = std::pair<PdObjNum, PdArray>;
struct Object
{
    union
    {
        std::nullptr_t none;
        bool b;
        signed char sc;
        signed short ss;
        signed int si;
        signed long sl;
        signed long long sll;
        unsigned char uc;
        unsigned short us;
        unsigned int ui;
        unsigned long ul;
        unsigned long long ull;
        float f;
        double d;
    };
    PdDict dict;
    PdArray array;
    std::string str;
    PdObjNum ref;
    PdObj obj;
};
#endif
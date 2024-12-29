#ifndef YYSTYPE_H
#define YYSTYPE_H 1
#include <string>
#include <iostream>
#include <sstream>
namespace utils
{
#if __cplusplus > 201700L
  template <typename... Args>
  void unpack(std::istream &im, Args &...args)
  {
    ((im >> args), ...);
  }
#else
  template <typename T>
  void unpack(std::istream &im, T &t)
  {
    im >> t;
  }
  template <typename T, typename... Rest>
  void unpack(std::istream &im, T &t, Rest &...rest)
  {
    im >> t;
    unpack(im, rest...);
  }
#endif
  template <typename... Args>
  void unpack(std::string str, Args &...args)
  {
    std::stringstream ss(str);
    unpack(ss, args...);
  }
  template <typename T>
  T convertAs(std::string s)
  {
    T t;
    unpack(s, t);
    return t;
  }
} // namespace utils
#endif

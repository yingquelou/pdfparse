#ifndef YYSTYPE_H
#define YYSTYPE_H 1
#include <string>
#include <iostream>
#include <sstream>
template <typename T>
T convertAs(std::string s)
{
  T t;
  std::stringstream ss(s);
  ss >> t;
  return t;
}
template <typename... Args>
void unpack(std::string str, Args &...args)
{
  std::stringstream ss(str);
  ((ss >> args), ...);
}
#endif
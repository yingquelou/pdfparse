#include "pch.h"
#include <iostream>
int main(int argc, char const *argv[])
{
  boost::json::object obj({
    {"ok",12}
  });
  boost::json::array arr;
  boost::json::value v;
  boost::json::string str;
    obj["id"]=10;
    // arr.emplace_back()
    // std::cout << v;
  for (size_t i = 1; argv[i]; i++)
  {
    FILE *f = fopen(argv[i], "rb");
    std::cout << argv[i];
    if (f)
    {
      std::string log(argv[i]);
      log += ".log";
      // FILE *fe = freopen(log.c_str(), "wb", stderr);
      yyrestart(f);
      yy::parser parser;
      parser.set_debug_level(0);
      parser();
      fclose(f);
      // fclose(fe);
      // std::cout << "\tsuccess\n";
    }
    // else std::cout << "\tfailed\n";
  }
  return 0;
}
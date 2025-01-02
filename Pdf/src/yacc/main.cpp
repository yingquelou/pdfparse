#include "pch.h"
#include <iostream>
#include <boost/filesystem.hpp>
int main(int argc, char const *argv[])
{
  boost::json::object obj({{"ok", 12}});
  boost::json::array arr;
  boost::json::value v;
  boost::json::string str;
  obj["id"] = 10;
  // arr.emplace_back()
  // std::cout << v;
  for (size_t i = 1; argv[i]; i++)
  {
    FILE *f = fopen(argv[i], "rb");
    boost::filesystem::path p(argv[i]);
    auto &&dir = p.replace_extension("").generic_string();
    boost::filesystem::create_directories(dir);
    // std::cout << p.append("OK").string();
    if (f)
    {
      std::string log(argv[i]);
      log += ".log";
      // FILE *fe = freopen(log.c_str(), "wb", stderr);
      yyscan_t scanner;
      yylex_init_extra(dir, &scanner);
      yyset_in(f, scanner);
      yy::parser parser(scanner);
      parser.set_debug_level(0);
      parser();
      yylex_destroy(scanner);
      fclose(f);
      // fclose(fe);
      // std::cout << "\tsuccess\n";
    }
    // else std::cout << "\tfailed\n";
  }
  return 0;
}
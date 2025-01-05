#include "pch.h"
#include <iostream>
#include <boost/filesystem.hpp>
int main(int argc, char const *argv[])
{
  for (size_t i = 1; argv[i]; i++)
  {
    FILE *f = fopen(argv[i], "rb");
    boost::filesystem::path p(argv[i]);
    auto &&dir = p.replace_extension("").generic_string();
    boost::filesystem::create_directories(dir);
    if (f)
    {
      shared_data sd;
      sd.dir = dir;
      std::string log(argv[i]);
      log += ".log";
      yyscan_t scanner;
      yylex_init_extra(&sd, &scanner);
      yyset_in(f, scanner);
      yy::parser parser(scanner);
      parser.set_debug_level(0);
      parser();
      yylex_destroy(scanner);
      fclose(f);
    }
  }
  return 0;
}
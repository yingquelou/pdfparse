#include "pdfObjects.h"
#include "pch.h"
int main(int argc, char const *argv[])
{
  for (size_t i = 1; argv[i]; i++)
  {
    FILE *f = fopen(argv[i], "rb");
    if (f)
    {
      std::string log(argv[i]);
      log += ".log";
      FILE *fe = freopen(log.c_str(), "wb", stderr);
      yyrestart(f);
      yy::parser parser;
      parser.set_debug_level(1);
      parser();
      fclose(f);
      fclose(fe);
    }
  }
  return 0;
}
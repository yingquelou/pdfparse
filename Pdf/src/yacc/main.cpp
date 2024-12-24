#include "pdfObjects.h"
#include "pch.h"
int main(int argc, char const *argv[])
{
  for (size_t i = 1; argv[i]; i++)
  {
    FILE *f = freopen(argv[1], "rb", stdin);
    if (f)
    {
      yy::parser parser;
      // parser.set_debug_level(1);
      parser();
      fclose(f);
    }
  }
  return 0;
}
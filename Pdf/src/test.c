#include "Pdocument.h"
#include "lex.pdf.h"
extern ListD finalList;
extern FILE*YYINREF,*YYOUTREF;
ListD pdEngin(char const *inputPdfPath,const char*logFile)
{
    // yydebug=1;
    YYINREF = fopen(inputPdfPath, "rb");
    YYOUTREF = fopen(logFile, "w");
    if (YYINREF)
    {
        pdfparse();
        fclose(YYINREF);
        fclose(YYOUTREF);
        return finalList;
    }
    else
        fprintf(stderr, "yyin is null");
    return NULL;
}
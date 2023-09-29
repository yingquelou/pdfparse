#include "Pdocument.h"
#include "lex.pdf.h"
extern ListD finalList;
extern FILE*YYINREF,*YYOUTREF;
extern int pdfparse (void);
ListD pdEngin(char const *inputPdfPath,const char*logFile)
{
    // yydebug=1;
    YYINREF = fopen(inputPdfPath, "rb");
    // yyin=fopen("E:\\desktop\\test.pdf","rb");
    // yyin=fopen("E:\\code\\pythonProjects\\conanTest\\test.txt","rb");
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
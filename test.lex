%{
#include <ctype.h>
#include <string.h>
#include <math.h>
#include <stdlib.h>
#define false 0
#define ture 1
#include "y.tab.h"
%}

digit [0-9]

%%
{digit}+   {
    yylval.integer=atoi(yytext);
    printf("number:%d\n",yylval.integer);
    return(number);
}

\+   {
    yylval.chr=yytext[0];
    printf("opterator:%c\n",yylval.chr);
    return('+');
}

\-   {
    yylval.chr=yytext[0];
    printf("oprator:%c\n",yylval.chr);
    return('-');
}

\*   {
    yylval.chr=yytext[0];
    printf("oprator:%c\n",yylval.chr);
    return('*');
}

"("   {
    yylval.chr=yytext[0];
    printf("separator:%c\n",yylval.chr);
    return('(');
}
    
")"   {
    yylval.chr=yytext[0];
    printf("separtor:%c\n",yylval.chr);
    return(')');
}

;   {
   return(';');
}

[ \t]+  {
   printf("lexical analyzer error\n");
   /*忽略空格*/
}

quit  {
   printf("Bye!\n");
   exit(0);
}

%%
int yywrap()
{
    return(1);
}

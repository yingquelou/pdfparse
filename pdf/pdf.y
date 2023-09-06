%{
int yyerror(char *s);
%}

%union{
   char chr;
   int integer;
}

%token <integer> number
%type <integer> exp
%type <chr> term factor
%left '+' '-'
%left '*'

%% 
command : exp { printf("the end of this calculation is %d\n",$1); }
        ;/*允许打印结果*/   
		    
exp     : exp '+' term { $$ = $1 + $3; }
        | exp '-' term { $$ = $1 - $3; }
        | term { $$ = $1; }
        ;

term    : term '*' factor { $$ = $1 * $3; }
        | factor { $$ = $1; }
        ;

factor  : number       { $$ = $1; }
        | '(' exp ')'  { $$ = $2; }
        ;
%%

int yyerror(char *s)
{
    fprintf(stderr,"error:%s\n",s);
    return 0; 
}       


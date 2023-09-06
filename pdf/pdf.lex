%{
fpos_t fileLeng=0,curPos=0;
%}

LB \[
RB \]
LD "<<"
RD ">>"
LA \<
RA \>
string \(.*\)
d [0-9]
w [0-9a-zA-Z]
xd [0-9A-Fa-f]
f {d}*\.{d}+
space " "
EOL (\r\n|\n)
keyword obj|endobj|stream|trailer|R|endstream|xref|startxref|f|n
name \/[^ ]+

%%

%.*$ {}
{space} {}
{string} {
    // fprintf(yyout,"string: %s\n",yytext);
    fprintf(yyout,"%s",yytext);
}
{keyword} {
    // fprintf(yyout,"keyword: %s\n",yytext);
    fprintf(yyout,"%s",yytext);
}
{EOL} {
	// fprintf(yyout,"EOL\n");
	fprintf(yyout,"\n");
}
{LB} {
    // fprintf(yyout,"LP: %s\n",yytext);
    fprintf(yyout,"%s",yytext);
}
{RB} {
    // fprintf(yyout,"LP: %s\n",yytext);
    fprintf(yyout,"%s",yytext);
}
{LD} {
    // fprintf(yyout,"LD: %s\n",yytext);
    fprintf(yyout,"%s",yytext);
}
{RD} {
    // fprintf(yyout,"RD: %s\n",yytext);
    fprintf(yyout,"%s",yytext);
}
{LA} {
    // fprintf(yyout,"LA: %s\n",yytext);
    fprintf(yyout,"%s",yytext);
}
{RA} {
    // fprintf(yyout,"RA: %s\n",yytext);
    fprintf(yyout,"%s",yytext);
}
{d}+   {
    // fprintf(yyout,"integer: %s\n",yytext);
    fprintf(yyout,"%s ",yytext);
}
{xd}+ {
 	// fprintf(yyout,"xd: %s\n",yytext);
    fprintf(yyout,"%s",yytext);
}
{f}     {
    // fprintf(yyout,"float: %s\n",yytext);
    fprintf(yyout,"%s ",yytext);
}

{name} {
    // fprintf(yyout,"name: %s\n",yytext);
    fprintf(yyout,"%s ",yytext);
}

. {
    fprintf(yyout,"%s",yytext);
}
%%
int yywrap()
{
	if (fgetpos(yyin, &curPos))
		return (1);
	else if (curPos < fileLeng)
		return 0;
	else
	{
		fclose(yyin);
		fclose(yyout);
		puts("OK");
		return (1);
	}
}
int test(int argc, char const *argv[])
{
	if (yyin = fopen("E:\\desktop\\pdf.pdf", "r"))
	{
		fseek(yyin,0,SEEK_END);
		printf("%d\n",ftell(yyin));
		fgetpos(yyin, &fileLeng);
		rewind(yyin);
		printf("%d\n",fileLeng/1024/1024);
		if (yyout = fopen("E:\\code\\pythonProjects\\conanTest\\pdf\\aaa.txt", "w"))
		{
			yylex();
			yylex_destroy();
		}
		else
			fclose(yyin);
	}
	return 0;
}
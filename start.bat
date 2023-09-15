if not defined YACC (
    conanbuild.bat
)
pushd pdf
%LEX% --noline -i pdf.lex
%YACC% -l --defines pdf.y
popd


if not defined YACC (
    conanbuild.bat
)else (
pushd pdf
%LEX% --noline -i pdf.lex
%YACC% -l --defines pdf.y
popd
)


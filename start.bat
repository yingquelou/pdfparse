if not defined YACC (
    conanbuild.bat
)
pushd pdf
%LEX% --noline -i pdf.lex
%YACC% -l -v --defines --debug -g pdf.y
popd


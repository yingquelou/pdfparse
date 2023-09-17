if not defined YACC (
    conanbuild.bat
)
pushd pdf
%LEX% --noline -i pdf.lex
%YACC% -l -d -v --debug -g pdf.y
popd


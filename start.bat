if not defined YACC (
    conanbuild.bat
)
pushd pdf
md build
pushd build
setlocal ENABLEDELAYEDEXPANSION


set PREFIX=pdf
set LEXHEADFILE=lex.%PREFIX%.h
set LEXFILE=lex.%PREFIX%.c
set YACCHEADFILE=%PREFIX%.tab.h
%LEX% -L -i --prefix=%PREFIX% -DYACCHEADFILE=\"%YACCHEADFILE%\" --header-file=%LEXHEADFILE% ..\pdf.lex
@REM %LEX% -L -i pdf.lex
%YACC% -l -v --debug --define=api.header.include={\"%LEXFILE%\"} -b %PREFIX% -p %PREFIX% --defines -g ..\pdf.y
@REM %YACC% -l -v --defines -g pdf.y
endlocal
popd
popd


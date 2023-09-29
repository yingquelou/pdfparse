if not defined YACC (
    conanbuild.bat
)
setlocal ENABLEDELAYEDEXPANSION
pushd Pdf
pushd src
pushd read
    

set PREFIX=pdf
set HEADPATH=..\..\include
set SRCDIR=..\..\bisonLex
set LEXSRC=%SRCDIR%\pdf.lex
set YACCSRC=%SRCDIR%\pdf.y
set LEXHEADFILE=lex.%PREFIX%.h
set LEXFILE=lex.%PREFIX%.c
set YACCHEADFILE=%PREFIX%.tab.h
set YYLVALREF=%PREFIX%lval

%LEX% -L -i --prefix=%PREFIX% -DYYINREF=%PREFIX%in -DYYOUTREF=%PREFIX%out -DYYLVALREF=%YYLVALREF% -DYACCHEADFILE=\"%YACCHEADFILE%\" --header-file=%HEADPATH%\%LEXHEADFILE% %LEXSRC%
@REM %LEX% -L -i pdf.lex
%YACC% -l -v --report-file=Grammar.txt --define=api.header.include={\"%LEXHEADFILE%\"} -b %PREFIX% -p %PREFIX% --defines=%HEADPATH%\%YACCHEADFILE% -g %YACCSRC%
@REM %YACC% -l -v --defines -g pdf.y

endlocal


popd
popd
popd

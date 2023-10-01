#!/bin/bash
if [ "$(command -v flex)" ]; then

cd pdf
mkdir -p build
cd build
export PREFIX=pdf
export LEXHEADFILE=lex.${PREFIX}.h
export LEXFILE=lex.${PREFIX}.c
export YACCHEADFILE=${PREFIX}.tab.h

flex -L -i --prefix=${PREFIX} -DYACCHEADFILE=\"${YACCHEADFILE}\" --header-file=${LEXHEADFILE} ../pdf.lex
bison -l -v --feature=caret --report=all --report-file=log.txt --define=api.header.include=\{\"${LEXFILE}\"\} -b ${PREFIX} -p ${PREFIX} --defines -g ../pdf.y

cd ..
cd ..
echo "command \"flex\" exists on system"
fi

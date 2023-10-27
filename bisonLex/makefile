all:
	bison -y --header -g -l pdf.y
	flex -i --header-file=lex.yy.h -L pdf.lex
	mv *.h ../include
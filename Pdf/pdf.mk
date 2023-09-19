LEXPATH=pdf.lex
YACCPATH=pdf.y
PREFIX=pdf
YACCHEADPATH="$(PREFIX).tab.h"
LEXHEADPATH=lex.$(PREFIX).h
all:
	$(LEX) -L -i --prefix=$(PREFIX) -DYACCHEADPATH='$(YACCHEADPATH)' --header-file=$(LEXHEADPATH) $(LEXPATH)
	$(YACC) --define=LEXHEADPATH=$(LEXHEADPATH) --warnings=deprecated --defines -l --name-prefix=$(PREFIX) $(YACCPATH)

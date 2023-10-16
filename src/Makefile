# Define variables
PREFIX = pdf
SRCDIR = ../bisonLex
LEXSRC = $(SRCDIR)/pdf.lex
YACCSRC = $(SRCDIR)/pdf.y
LEXHEADFILE = lex.$(PREFIX).h
LEXFILE = lex.$(PREFIX).c
YACCHEADFILE = $(PREFIX).tab.h
YYLVALREF = $(PREFIX)lval

ifdef debug
	LEXDEBUGFLAGS = -d
	YACCDEBUGFLAGS = -t
endif

# Define commands
LEX = ${USERPROFILE}/.conan2/p/winfle15db8e5f2bb5/p/bin/win_flex
YACC = ${USERPROFILE}/.conan2/p/winfle15db8e5f2bb5/p/bin/win_bison -y # Change this to the appropriate yacc command if needed

# Define targets and rules
all: lex yacc
	move *.h ..\\include

lex: $(LEXFILE)

yacc: $(YACCHEADFILE)

$(LEXFILE): $(LEXSRC)
	$(LEX) ${LEXDEBUGFLAGS} -L -i --prefix=$(PREFIX) -DYYINREF=$(PREFIX)in -DYYOUTREF=$(PREFIX)out -DYYLVALREF=$(YYLVALREF) -DYACCHEADFILE=\"$(YACCHEADFILE)\" --header-file=$(LEXHEADFILE) $^

$(YACCHEADFILE): $(YACCSRC)
	$(YACC) ${YACCDEBUGFLAGS} -l -v --report-file=Grammar.txt --define=api.header.include={\"$(LEXHEADFILE)\"} -b $(PREFIX) -p $(PREFIX) --defines=$(YACCHEADFILE) -g $^

clean:
	del /q $(LEXFILE) $(YACCHEADFILE) Grammar.txt $(LEXHEADFILE) ${PREFIX}.tab.c ${PREFIX}.dot

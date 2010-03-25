CC = gcc
CCFLAGS = -g -W -Wall

FLEX = flex
FLEX_OPTS = -PTQL

BISON = bison
BISON_OPTS = -t -pTQL

LATEX = latex
DVIPS = dvips

OBJS = Absyn.o Lexer.o Parser.o Test.o Symbols.o Translator.o Context.o Cexplode.o Database.o Err.o Buffer.o
POSTGRES_OBJS = conf/Translator_postgres.o conf/Database_postgres.o

all: postgresTQL
#TQL.ps

.PHONY: clean distclean

clean:
	rm -f *.o TQL.dvi TQL.aux TQL.log TQL.ps testTQL

distclean: clean
	rm -f *.o Absyn.c Absyn.h Test.c Parser.c Parser.h Lexer.c Translator.c Translator.h TQL.l TQL.y TQL.tex TQL.dvi TQL.aux TQL.log TQL.ps testTQL Makefile

postgresTQL: ${OBJS} ${POSTGRES_OBJS}
	@echo "Linking testTQL..."
	${CC} ${CCFLAGS} *.o -o postgresTQL -lpq

${POSTGRES_OBJS}: %_postgres.o: %_postgres.c %_config.h Buffer.o
	@echo "compiling " $*
	${CC} ${CCFLAGS} -c $<

%.o : %.c %.h
	${CC} ${CCFLAGS} -c $<

#Symbols_test.o: Symbols_test.c Symbols.h

#Absyn.o: Absyn.c Absyn.h conf/Translator_config.h
#	${CC} ${CCFLAGS} -c Absyn.c

Lexer.c: TQL.l
	${FLEX} ${FLEX_OPTS} -oLexer.c TQL.l

Parser.c: TQL.y
	${BISON} ${BISON_OPTS} TQL.y -o Parser.c

Lexer.o: Lexer.c Parser.h  Symbols.h
	${CC} ${CCFLAGS} -c Lexer.c 

Parser.o: Parser.c Absyn.h Symbols.h
	${CC} ${CCFLAGS} -c Parser.c

Translator.o: Translator.c Absyn.h Symbols.h Translator.h conf/Translator_config.h
	${CC} ${CCFLAGS} -c Translator.c

Context.o: Context.c Absyn.h Symbols.h Context.h conf/Translator_config.h
	${CC} ${CCFLAGS} -c Context.c

Test.o: Test.c Parser.h Absyn.h  Symbols.h conf/Translator_config.h
	${CC} ${CCFLAGS} -c Test.c

TQL.dvi: TQL.tex
	${LATEX} TQL.tex

TQL.ps: TQL.dvi
	${DVIPS} TQL.dvi -o TQL.ps


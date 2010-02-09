CC = gcc
CCFLAGS = -g -W -Wall

FLEX = flex
FLEX_OPTS = -PTQL

BISON = bison
BISON_OPTS = -t -pTQL

LATEX = latex
DVIPS = dvips

all: testTQL TQL.ps

.PHONY: clean distclean

clean:
	rm -f *.o TQL.dvi TQL.aux TQL.log TQL.ps testTQL

distclean: clean
	rm -f *.o Absyn.c Absyn.h Test.c Parser.c Parser.h Lexer.c Translator.c Translator.h TQL.l TQL.y TQL.tex TQL.dvi TQL.aux TQL.log TQL.ps testTQL Makefile

testTQL: Absyn.o Lexer.o Parser.o Test.o Symbols.o Translator.o conf/Translator_config.o Context.o Cexplode.o Database.o Err.o
	@echo "Linking testTQL..."
	${CC} ${CCFLAGS} *.o -o testTQL -lpq

#Symbols_test: Symbols.o Symbols_test.o

Symbols.o: Symbols.c Symbols.h
	${CC} ${CCFLAGS} -c Symbols.c

conf/Translator_config.o: conf/Translator_config.c conf/Translator_config.h Buffer.o
	${CC} ${CCFLAGS} -c conf/Translator_config.c

conf/Database_config.o: conf/Database_config.c conf/Database_config.h Buffer.o
	${CC} ${CCFLAGS} -c conf/Database_config.c
	
Database.o: Database.c  Database.h conf/Database_config.o
	${CC} ${CCFLAGS} -c Database.c	
	
Cexplode.o: Cexplode.c Cexplode.h
	${CC} ${CCFLAGS} -c Cexplode.c
	
Buffer.o: Buffer.c Buffer.h
	${CC} ${CCFLAGS} -c Buffer.c

Err.o: Err.c Err.h
	${CC} ${CCFLAGS} -c Err.c
	
#Symbols_test.o: Symbols_test.c Symbols.h

Absyn.o: Absyn.c Absyn.h conf/Translator_config.h
	${CC} ${CCFLAGS} -c Absyn.c

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


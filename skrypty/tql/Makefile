CC = gcc
CCFLAGS = -g -W -Wall

FLEX = flex
FLEX_OPTS = -PTQL

BISON = bison
BISON_OPTS = -t -pTQL

LATEX = latex
DVIPS = dvips

OBJS = conf/Translator_common.o Absyn.o Lexer.o Parser.o main.o Symbols.o Translator.o Context.o Cexplode.o Database.o Err.o Buffer.o
POSTGRES_OBJS = conf/Translator_postgres.o conf/Database_postgres.o
XML_OBJS = conf/Translator_xml.o conf/Database_xml.o

all: xmlTQL postgresTQL

#test: testPostgresTQL

.PHONY: clean distclean

clean:
	rm -f *.o conf/*.o TQL.dvi TQL.aux TQL.log TQL.ps postgresTQL xmlTQL

#distclean: clean
#	rm -f *.o Absyn.c Absyn.h Test.c Parser.c Parser.h Lexer.c Translator.c Translator.h TQL.l TQL.y TQL.tex TQL.dvi TQL.aux TQL.log TQL.ps testTQL Makefile

testPostgresTQL: postgresTQL
	@echo "Testing postgresTQL..."
	auto_test/auto_test.sh ./postgresTQL

testXmlTQL: xmlTQL
	@echo "Testing xmlTQL..."
	auto_test/auto_test.sh ./xmlTQL

postgresTQL: ${OBJS} ${POSTGRES_OBJS}
	@echo "Linking postgresTQL..."
	${CC} ${CCFLAGS} ${OBJS} ${POSTGRES_OBJS} -o postgresTQL -lpq
	#${CC} ${CCFLAGS} ${OBJS} ${POSTGRES_OBJS} -o postgresTQL -lpq -L/usr/local/pgsql/lib #dont commit!!!


xmlTQL: ${OBJS} ${XML_OBJS}
	@echo "Linking xmlTQL..."
	${CC} ${CCFLAGS} ${OBJS} ${XML_OBJS} -o xmlTQL -lpq
	#${CC} ${CCFLAGS} ${OBJS} ${XML_OBJS} -o xmlTQL -lpq -L/usr/local/pgsql/lib #dont commit!!!



${POSTGRES_OBJS}: %_postgres.o: %_postgres.c %_config.h Buffer.o
	@echo "compiling " $*
	${CC} ${CCFLAGS} -c $< -o $*_postgres.o

${XML_OBJS}: %_xml.o: %_xml.c %_config.h Buffer.o
	@echo "compiling " $*
	${CC} ${CCFLAGS} -c $< -o $*_xml.o

%.o : %.c %.h
	${CC} ${CCFLAGS} -c $< -o $*.o

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

TQL.dvi: TQL.tex
	${LATEX} TQL.tex

TQL.ps: TQL.dvi
	${DVIPS} TQL.dvi -o TQL.ps


IN  ?= input.asm
OUT ?= output.asm

all: term

term: term.tab.c term.tab.h lex.yy.c
	gcc -o term term.tab.c lex.yy.c -ll

term.tab.c term.tab.h: term.y
	yacc -d term.y -o term.tab.c

lex.yy.c: term.l
	lex term.l

run: term
	./term $(IN) $(OUT)

clean:
	rm -f term term.tab.c term.tab.h lex.yy.c
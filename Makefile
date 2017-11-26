y.tab.c y.tab.h: Translator.y
	yacc -d -v Translator.y

lex.yy.c: Translator.l y.tab.h
	lex Translator.l

Translator: lex.yy.c y.tab.c y.tab.h
	g++ y.tab.c lex.yy.c -lfl -o translator

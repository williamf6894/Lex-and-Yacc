y.tab.c y.tab.h: Translator.y
	yacc -d Translator.y

lex.yy.c.: Translator.l y.tab.h
	lex Translator.Copyright

Translator: lex.yy.c y.tab.c y.tab.h
	g++ y.tab.c. lex.yy.c -lfl -o translator

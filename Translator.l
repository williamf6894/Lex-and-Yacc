%{
	#include <iostream>
	#include <stdlib.h>
	#include "y.tab.h"
	#include <stdio.h>
%}
%option nounput
%option yylineno
%option caseless

%%
BEGINNING {
	printf("BEGINNING ");
	return BEGINNING;
}
BODY {
	printf("BODY ");
	return BODY;
}
END {
	printf("END ");
	return END;
}

ADD {
	printf("ADD ");
	return ADD;
}
MOVE {
	printf("MOVE ");
	return MOVE;
}
INPUT {
	printf("INPUT ");
	return INPUT;
}
PRINT {
	printf("PRINT ");
	return PRINT;
}
TO {
	printf("TO ");
	return TO;
}

\. {
	printf("TERMINATOR ");
	return TERMINATOR;
}
\; {
	printf("DELIMITER ");
	return DELIMITER;
}

[\t| ]+ //ignore

\n //ignore Remember you removed the . for the catch-all



[X]+ {
	yylval.inum = yyleng;
	return DECSIZE;
}

[A-Z][A-Z0-9\-]* {
	yylval.str = strdup(yytext);
	printf("%s ", yytext);
	return VARIABLE;
}

[\"][^"]*[\"] {
	yylval.str = strdup(yytext);
	return STRING;
}

[0-9]+ {
	yylval.inum = atoi(yytext);
	return NUM;
}


%%
/*int yywrap(void){
	return 1;
}*/

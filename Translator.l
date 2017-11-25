%{
	#include <stdlib.h>
	#include "yac.tab.h"
	#include "keywords.h"
	#include <stdio.h>
%}
%option nounput
%option yylineno
%option caseless

%%
\. {
	return TERMINATOR;
}
BEGINNING {
	return BEGINNING;
}
BODY {
	return BODY;
}
END {
	return END;
}
ADD {
	return ADD;
}
MOVE {
	return MOVE;
}
INPUT {
	return INPUT;
}
PRINT {
	return PRINT;
}
TO {
	return TO;
}
\; {
	return DELIMITER;
}
[ \t\n] {

}

. {
	  printf("Unexpected Character\n");
}

[Xx]+ {
	yylval.inum = yyleng;
	return DECSIZE;
}

[A-Z][A-Z0-9\-]* {
	yylval.str = strdup(yytext);
	return VARIABLE;
}

\"[a-zA-Z0-9]*\" {
	yylval.str = strdup(yytext);
	return STRING;
}

[0-9]+ {
	yylval.num = atoi(strdup(yytext));
	return DIGIT;
}


%%
/*int yywrap(void){
	return 1;
}*/

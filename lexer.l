%{
#include <stdio.h>

#include "y.tab.h"
#define YYSTYPE char *
%}

%option noyywrap
%option caseless

%%

(?i:BEGINING) return TERM_BEGINING;
(?i:BODY) return TERM_BODY;
(?i:END) return TERM_END;
(?i:MOVE) return TERM_MOVE;
(?i:TO) return TERM_TO;
(?i:ADD) return TERM_ADD;
(?i:INPUT) return TERM_INPUT;
(?i:PRINT) return TERM_PRINT;


[\t| ]+ // ignore whitespaces

\n // Ignore new line

[X]+ yylval.integer = yyleng; return TERM_SIZE;

[\"][^"]*[\"] yylval.string = strdup(yytext); return TERM_STR;

";" return TERM_SEPARATOR;

"." return TERM_FULLSTOP;

[0-9]+ yylval.integer = atoi(yytext); return TERM_INT;

[\_\-0-9][a-zA-Z][a-zA-Z0-9\-\_]* yylval.string = strdup(yytext); return TERM_INVALID_VARIABLE_NAME;

[A-Z][A-Z0-9\-]* yylval.string = strdup(yytext); return TERM_VARIABLE_NAME;

. return TERM_INVALID_TOKEN;

%%

//int main(int argc, char** argv) {
//	if (argc != 2) {
//		yyin = stdin;
//		yylex();
//	} else {
//		FILE* aFile = fopen(argv[1], "r");
//		if (!aFile) {
//			printf("Cannot open file!\n");
//			return -1;
//		} else {
//			yyin = aFile;
//			yylex();
//			fclose(yyin);
//		}
//	}
//}

%{
	#include "keywords.h"
%}
%option nounput yylineno
%%
\.					return DOT;
"BEGINNING"			return BEGINNING;
"BODY"				return BODY;
"END"				return END;
"ADD"				return ADD;
"MOVE"				return MOVE;
"INPUT"				return INPUT;
"PRINT"				return PRINT;
"TO"				return TO;
"DOT" 				return DOT;
[ \t\n]				;
.					printf("Unexpected Character\n");
[X]{0,5} 			return DECLARATION;
[A-Z][A-Z0-9\-]*	return VARIABLE;
\"[a-zA-Z0-9]*\"   	return STRING;
[0-9]+             	return DIGIT;

%%
/*int yywrap(void){
	return 1;
}*/

#include <stdio.h>
#include "keywords.h"
#include <string.h>

extern int yylex();
extern int yylineno();
extern char* yytext;

char *tokens[] = {NULL, "beginning", "body", "end", "add", "move", "input", "print", "to", "dot", "XXXXX", "XXXX", "XXX", "XX", "X", "DECLARATION", "VARIABLE", "STRING", "DIGIT"};

int main(void) {

	int ntoken, vtoken;
	int declaresize = 0;
	printf("Hello\n");
	ntoken = yylex();
	while(ntoken) {
		printf("%d\n", ntoken);
		switch (ntoken) {
			case BEGINNING:
				if(yylex() != DOT ) {
					printf("Syntax error in line %d, Expected a '.' but found %s\n", yylineno, yytext);
					return 1;
				}
				else {
					int pass = beginning();

					if(pass == 1){
						return 1;
					}
				}
				break;
			case BODY:
				if(yylex() != DOT) {
					printf("Syntax error in line %d, Expected a '.' but found %s\n", yylineno, yytext);
					return 1;
				}
				else {
					int pass = body();
					if (pass == 1) {
						return 1;
					}
				}
				break;
			case END:
				if(yylex() != DOT ) {
					printf("Syntax error in line %d, Expected a '.' but found %s\n", yylineno, yytext);
					return 1;
				}
				return 0;
				break;
			default:
				printf("Syntax error in line %d\n", yylineno);
		}
		ntoken = yylex();
	}
	printf("Failed\n" );
	return 0;
}

int beginning(void){

	int sizecount = 0;
	int ntoken, vtoken;
	ntoken = yylex();
	while(ntoken){

		vtoken = yylex();
		switch (vtoken) {
			case XXXXX: sizecount++;
			case XXXX: sizecount++;
			case XXX: sizecount++;
			case XX: sizecount++;
			case X:
			 	sizecount++;
				ntoken = yylex();

				if(ntoken != VARIABLE || yylex() == DOT) {
					printf("Syntax error in line %d, Expected a variable but found %s\n", yylineno, yytext);
					return 1;
				}

				printf("Declaration is of size: %d\nFor variable %s", sizecount, yytext );
				break;

			case BODY:
				body();
				break;

			default:
				return 1;
		}
		ntoken = yylex();
	}
	body();
	return 0;
}

int body(void){

	int ntoken, vtoken;
	ntoken = yylex();
	while(ntoken) {
		vtoken = yylex();
		if (vtoken == DOT) {
			printf("Syntax error in line %d, Expected a . but found %s\n", yylineno, yytext);
		}
		switch (ntoken) {
			case ADD:
				if(vtoken == DIGIT) {
					printf("%s is set to %s\n", tokens[ntoken], yytext);
				}
				else if(vtoken == VARIABLE){
					printf("%s is set to %s\n", tokens[ntoken], yytext);
				}
				printf("Syntax error in line %d, Expected an identifier or variable but found %s\n", yylineno, yytext);
				break;
			case MOVE:
				if (vtoken == DIGIT) {
					printf("%s is set to %s\n", tokens[ntoken], yytext);
				}
				if(vtoken == VARIABLE){
					printf("%s is set to %s\n", tokens[ntoken], yytext);
				}
				printf("Syntax error in line %d, Expected an identifier or variable but found %s\n", yylineno, yytext);
				break;
			case INPUT:

				break;
			case PRINT:

				break;
			case TO:
				if(vtoken != STRING) {
					printf("Syntax error in line %d, Expected an identifier but found %s\n", yylineno, yytext);
				}
				break;

		}
	}




	return 0;
}

int end(){

	return 0;
}

void dot(void){


}

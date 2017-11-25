%{
#include <stdio.h>;
int yylex();
void yyerror();

%}

%union {
	int inum;
	float fnum;
	char* str;
}


%token BEGINNING
%token BODY
%token END
%token TERMINATOR
%token <inum> DECSIZE
%token <str> VARIABLE
%token PRINT
%token INPUT
%token <inum> NUM
%token
%token
%token
%token
%token

%%

program:
	BEGINNING TERMINATOR declarations BODY TERMINATOR instructions END TERMINATOR { printf(" Good \n"); }
;

declarations:
	declaration declaration |
	declaration |
	/* blank */
;

declaration:
	DECSIZE VARIABLE TERMINATOR
;

instructions:
 	instruction |
	instructions instruction |
	/* blank */
;

move_instruct:
	MOVE NUM TO VARIABLE TERMINATOR |
	MOVE VARIABLE TO VARIABLE TERMINATOR
;

add_instruct:
	ADD NUM TO VARIABLE TERMINATOR |
	ADD VARIABLE TO VARIABLE TERMINATOR
;

print_instruct:
	PRINT STRING TERMINATOR |
	PRINT VARIABLE DELIMITER STRING
;
// ------------------------------------ FIX ^^

input_instruct:
	INPUT VARIABLE TERMINATOR 
;

var:
	VARIABLE {printf("%s\n",yylval.str);} |
	var VARIABLE {printf("%s\n",yylval.str);}
;

number:
	NUMBER {printf("%d\n",yylval.num);} |
	number NUMBER {printf("%d\n",yylval.num);}
;


%%

extern FILE *yyin;
extern int yyparse();
extern int yylex();

int main(int argc, char **argv)
{

	readFile = fopen(argv[1], "r");

	// safety check
	if(!readFile){
		cout << "Error reading file: Missing or No Parameter" << endl;
		return 2;
	}

	yyin = readFile;
	do {
		yyinyyparse();
	} while(!feof(yyin));

	return 0;
}

void yyerror(char* message)
{
	cout << "Error:\n" << message << endl;
	// Kill it
	exit(-1);
}

%{
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <vector>
#include <math.h>
int yylex();
int yyerror(const char* s);

using namespace std;

struct Variable {
	char* varName;
	int varSize;
	int varValue;
};

bool checkDeclaration(char* varName);
int getNumberSize(int num);
int getVarIndex(char* varName);
void createNewVar(char* varName, int varSize);
void addVarToVar(char* var1, char* var2);
void addNumToVar(int number, char* var2);
void moveVarToVar(char* var1, char* var2);
void moveNumToVar(int number, char* var2);
void inputValueToVar(char* varName);
void printVarValue(char* varName);


%}

%union {
	int inum;
	char* str;
}

%token BEGINNING BODY END
%token PRINT INPUT ADD MOVE TO
%token TERMINATOR DELIMITER
%token DECSIZE VARIABLE STRING NUM
%type <inum> NUM
%type <inum> DECSIZE
%type <str> TERMINATOR
%type <str> DELIMITER
%type <str> STRING
%type <str> VARIABLE
%start program

%%

program:
	start main ending { printf("\nCompilation Complete!\n"); exit(0); }
;

start:
	BEGINNING TERMINATOR declarations
;

main:
	BODY TERMINATOR instructions
;
ending:
 	END TERMINATOR
;

declarations:
	declarations declaration TERMINATOR |

;

declaration:
	DECSIZE VARIABLE { createNewVar($2, $1); }
;

instructions:
	instructions instruction TERMINATOR |
;

instruction:
	move_instruct |
	add_instruct |
	print_instruct |
	input_instruct
;

move_instruct:
	MOVE NUM TO VARIABLE { moveNumToVar($2, $4); } |
	MOVE VARIABLE TO VARIABLE { moveVarToVar($2, $4); }
;

add_instruct:
	ADD NUM TO VARIABLE { addNumToVar($2, $4); } |
	ADD VARIABLE TO VARIABLE { addVarToVar($2, $4); }
;

print_instruct:
	PRINT { printf("Printed: ");} printable
;

printable :
	VARIABLE print_rest { printVarValue($1); } |
	STRING print_rest { printf("%s\n", $1); } |
	VARIABLE { printVarValue($1); } |
	STRING { printf("%s\n", $1); } |
;

print_rest :
	DELIMITER printable
;

input_instruct:
	INPUT input_rest
;

input_rest:
	VARIABLE { inputValueToVar($1); } |
	input_rest DELIMITER VARIABLE { inputValueToVar($3); }
;



%%

extern FILE *yyin;
extern int yyparse();
extern int yylex();

vector<Variable> variableList;

int main(int argc, char **argv)
{

	FILE *readFile = fopen(argv[1], "r");

	if(!readFile){
		yyerror("Error reading file: Missing or No Parameter");
		return 2;
	}

	yyin = readFile;

	do {
		yyparse();
	} while(!feof(yyin));

	return 0;
}

int yyerror(const char* s) {

	printf("%s\n", s);
	exit(0);
}

int getVarIndex(char* varName) {
	for (int i = 0; i < variableList.size(); i++) {
		if (strcmp(variableList.at(i).varName, varName) == 0) {
			return i;
		}
	}
	return -1;
}

void createNewVar(char* varName, int varSize){
	if(!checkDeclaration(varName)){
		struct Variable newVar;
		newVar.varName = varName;
		newVar.varSize = varSize;
		newVar.varValue = 0; // Initialize to Zero.

		printf("Variable %s of size %d with value %d\n", newVar.varName, newVar.varSize, newVar.varValue);

		variableList.push_back(newVar);
	} else {
		yyerror("Error: Variable already been declared.\n");
	}
}

int numberLength(int num) {
	return num == 0 ? 1 : (int) log10 ((double) num) + 1;
}


void printVarValue(char* varName) {
	if (!checkDeclaration(varName)) {
		printf("Syntax Error: Variable %s was not declared\n", varName);
	}
	int index = getVarIndex(varName);
	int varValue = variableList.at(index).varValue;
	printf("%d\n", varValue);
}

void addVarToVar(char* var1, char* var2){
	if(!checkDeclaration(var1)) {
		printf("Error: variable %s is not declared\n", var1);
		yyerror("Critical!");
	}
	else if(!checkDeclaration(var2)) {
		printf("Error: variable %s is not declared\n", var2);
		yyerror("Critical!");
	}
	else {

		int newValue;

		int varIndex1 = getVarIndex(var1);
		int varSize1 = variableList.at(varIndex1).varSize;
		int varValue1 = variableList.at(varIndex1).varValue;

		int varIndex2 = getVarIndex(var2);
		int varSize2 = variableList.at(varIndex2).varSize;
		int varValue2 = variableList.at(varIndex2).varValue;

		if(varSize1 <= varSize2) {

			newValue = varValue1 + varValue2;

			if(getNumberSize(newValue) <= varSize2) {
				variableList.at(varIndex2).varValue = newValue;
				printf("%d has been added to %s\n", newValue, var2);
			}
			else {
				printf("Warning: \n%s is too small for %d\n\n", var2, newValue);
			}

		}
		else {
			printf("Warning: \n%s is too small for %s\n\n", var2, var1);
		}
	}
}

void addNumToVar(int number, char* varName){

	if(!checkDeclaration(varName)) {
		printf("Error: variable %s is not declared\n", varName);
		yyerror("Critical!");
	}

	int newValue;

	int varIndex = getVarIndex(varName);
	int varValue = variableList.at(varIndex).varValue;
	int varSize = variableList.at(varIndex).varSize;

	newValue = varValue + number;

	if (getNumberSize(newValue) <= varSize) {
		variableList.at(varIndex).varValue = newValue;
		printf("%d has been added to %s\n", number, varName);
	}
	else {
		printf("Warning: \n%d is too small for %s\n\n", number, varName);
	}
}

void moveVarToVar(char* var1, char* var2){
	if(!checkDeclaration(var1)) {
		printf("Error: variable %s is not declared\n", var1);
		yyerror("Critical!");
	}
	else if(!checkDeclaration(var2)) {
		printf("Error: variable %s is not declared\n", var2);
		yyerror("Critical!");
	}
	else {

		int varIndex1 = getVarIndex(var1);
		int varSize1 = variableList.at(varIndex1).varSize;
		int varValue1 = variableList.at(varIndex1).varValue;

		int varIndex2 = getVarIndex(var2);
		int varSize2 = variableList.at(varIndex2).varSize;
		int varValue2 = variableList.at(varIndex2).varValue;

		if(varSize1 <= varSize2) {
			variableList.at(varIndex2).varValue = varValue1;
			printf("%s has been moved to %s\n", var1, var2);
		}
		else {
			printf("Warning: \n%s is too small for %s\n\n", var2, var1);
		}

	}
}

void moveNumToVar(int num, char* varName){
	if(!checkDeclaration(varName)) {
		printf("Error: variable %s is not declared\n", varName);
		yyerror("Critical!");
	}
	else {

		int varIndex = getVarIndex(varName);
		int varValue = variableList.at(varIndex).varValue;
		int varSize = variableList.at(varIndex).varSize;

		if (getNumberSize(num) <= varSize) {
			printf("%d has been moved to %s\n", num, varName );
			variableList.at(varIndex).varValue = num;
		}
		else {
			printf("Warning: \n%d is too small for %s\n\n", num, varName);
		}
	}

}

void inputValueToVar(char* varName){
	if(!checkDeclaration(varName)) {
		printf("Error: variable %s is not declared\n", varName);
		yyerror("Critical!");
	}
	int input;
	scanf("%d", &input);

	int varIndex = getVarIndex(varName);
	if (getNumberSize(input) <= variableList.at(varIndex).varSize) {
		printf("Input %d to %s\n", input, varName );
		variableList.at(varIndex).varValue = input;
	}
	else {
		yyerror("Warning: \nInput number too big.\n");
	}

}

int getNumberSize(int num) {
	int i = 1;
	while (num > 9) {
		num = num / 10;
		i++;
	}
	return i;
}


bool checkDeclaration(char* varName) {

	int counter = 0;
	for(counter = 0; counter < variableList.size(); ++counter) {

		if (strcmp(variableList.at(counter).varName, varName) == 0) {
			//variable is declared
			return true;
		}
	}
	return false;
}

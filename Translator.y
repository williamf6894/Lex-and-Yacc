%{
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <vector>
#include <map>
int yylex();
int yyerror(char* s);

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

%token BEGINNING
%token BODY
%token END
%token PRINT
%token INPUT
%token ADD
%token MOVE
%token TO
%token TERMINATOR
%token DELIMITER
%token DECSIZE
%token VARIABLE
%token STRING
%token NUM
%type <inum> NUM
%type <inum> DECSIZE
%type <str> TERMINATOR
%type <str> DELIMITER
%type <str> STRING
%type <str> VARIABLE
%start program

%%

program:
	start main ending { printf("Well played!\n "); }
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
	PRINT printable
;

printable :
	VARIABLE print_rest { printVarValue($1); } |
	STRING print_rest { printf("%s", $1); } |
	VARIABLE { printVarValue($1); } |
	STRING { printf("%s", $1); } |
;

print_rest :
	DELIMITER printable { printf("");}
;

input_instruct:
	INPUT input_rest
;

input_rest:
	VARIABLE { inputValueToVar($1); } |
	input_rest VARIABLE { inputValueToVar($2); }
;



%%

extern FILE *yyin;
extern int yyparse();
extern int yylex();

vector<Variable> variableList;

int main(int argc, char **argv)
{

	// Set up a Map with all the Vars and the Values
	std::map<std::string, int> varsAndValues;
	FILE *readFile = fopen(argv[1], "r");

	// safety check
	if(!readFile){
		cout << "Error reading file: Missing or No Parameter" << endl;
		return 2;
	}

	yyin = readFile;
	do {
		yyparse();
	} while(!feof(yyin));

	return 0;
}

int yyerror(char *s)
{
	std::cout << "Error: " << s << std::endl;
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
		newVar.varValue  = 0;

		printf("Variable %s of size %d with value %d\n", newVar.varName, newVar.varSize, newVar.varValue);

		variableList.push_back(newVar);
	}
}

void printVarValue(char* varName) {
	if (!checkDeclaration(varName)) {
		printf("Syntax Error: Variable %s was not declared\n", varName);
	}
	int index = getVarIndex(varName);
	int varValue = variableList.at(index).varValue;
	printf("\nPrinting %s's value of %d\n", varName, varValue);
}

void addVarToVar(char* var1, char* var2){
	if(!checkDeclaration(var1)) {
		printf("Error with variable %s", var1);
		exit(-1);
	}
	if(!checkDeclaration(var2)) {
		printf("Error with variable %s", var1);
		exit(-1);
	}

	int newValue;

	int varIndex1 = getVarIndex(var1);
	int varSize1 = variableList[varIndex1].varSize;
	int varValue1 = variableList[varIndex1].varValue;

	int varIndex2 = getVarIndex(var2);
	int varSize2 = variableList[varIndex2].varSize;
	int varValue2 = variableList[varIndex2].varValue;

	if(varSize1 <= varSize2) {
		newValue = varValue1 + varValue2;
		variableList[varIndex2].varValue = newValue;
	}
	else{
		printf("%s is too small for %s\n", var2, var1);
		exit(-1);
	}

}

void addNumToVar(int number, char* varName){

	if(!checkDeclaration(varName)) {
		printf("Error with variable %s", varName);
		exit(-1);
	}

	int newValue;

	int varIndex = getVarIndex(varName);
	int varValue = variableList[varIndex].varValue;

	newValue = varValue + number;
	variableList[varIndex].varValue = newValue;
}

void moveVarToVar(char* var1, char* var2){
	if(!checkDeclaration(var1)) {
		printf("Error with variable %s", var1);
		exit(-1);
	}
	if(!checkDeclaration(var2)) {
		printf("Error with variable %s", var1);
		exit(-1);
	}

	int varIndex1 = getVarIndex(var1);
	int varSize1 = variableList[varIndex1].varSize;
	int varValue1 = variableList[varIndex1].varValue;

	int varIndex2 = getVarIndex(var2);
	int varSize2 = variableList[varIndex2].varSize;
	int varValue2 = variableList[varIndex2].varValue;

	if(varSize1 <= varSize2) {
		variableList[varIndex2].varValue = varValue1;
	}
	else {
		printf("%s is too small for %s\n", var2, var1);
		exit(-1);
	}

}

void moveNumToVar(int number, char* varName){
	printf("Moving %d to %s\n", number, varName);
	if(!checkDeclaration(varName)) {
		printf("Error with variable %s", varName);
		exit(-1);
	}

	int varIndex = getVarIndex(varName);

	variableList[varIndex].varValue = number;

}

void inputValueToVar(char* varName){
	if(!checkDeclaration(varName)) {
		printf("Variable %s is not declared", varName);
		exit(-1);
	}
	int input;
	scanf("%d", &input);

	int varIndex = getVarIndex(varName);
	printf("Input %d to %s\n", input, varName );
	variableList.at(varIndex).varValue = input;

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
	for(counter = 0; counter < variableList.size(); counter++) {

		if (strcmp(variableList.at(counter).varName, varName) == 0) {
			// variable is declared
			return true;
		}
	}
	return false;
}

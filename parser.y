%{
//yylval - externalise variable in which yylex should place semantic value associated with a token
//yyparse - parser function produced by bison, call this to start parsing

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <unistd.h>

extern FILE* yyin;
typedef int bool;

#define true 1
#define false 0

#define YYDEBUG 1

//Cause an immediate syntax error
int yyerror(char *s) {
  fprintf(stderr, "%s\n", s);
  exit(0);
}

//Declare yylex, user supplied lexical analyzer function to get the next token
int yylex(void);

//yywrap text wrap
//When scanner recieves EOF it checks yywrap()
int yywrap(void) {
	return 1;
}

// Structure of variable
struct variable {
	char* varName;
	int varSize;
	int varValue;
};

typedef struct {
	struct variable* array;
	size_t used;
	size_t size;
} Array;

// Method declarations
void writeToWarning(char *aWarning);
void writeToError(char *anError);
void writeToLog(char *alog);
bool checkIfDeclared(char* varName);

void initialiseArray(Array *a, size_t initialSize);
void insertArray(Array *a, struct variable *aVar);
void freeArray(Array *a);

void createVar(int size, char* varName);
void inputValues(char* varName);
int getIndexOfVar(char* varName);
int getNumberSize(int number);

void moveIntToVar(int number, char* varName);
void moveVarToVar(char* varName1, char* varName2);
void addIntToVar(int number, char* varName);
void addVarToVar(char* varName1, char* varName2);

void printVarValue(char* varName);
void printInvalidVarName(char* varName);

void logUndeclaredVar(char* varName);
void logDupVar(char* varName);

void logVarToVarOverflow(char* varName1, char* varName2);


%}

//each token is a terminal
%token TERM_BEGINING TERM_BODY TERM_END TERM_MOVE
		TERM_TO TERM_ADD TERM_INPUT TERM_PRINT
		TERM_SIZE TERM_STR TERM_SEPARATOR TERM_FULLSTOP
		TERM_INT TERM_INVALID_VARIABLE_NAME TERM_VARIABLE_NAME TERM_INVALID_TOKEN

//Everything that something can be
//yyvval array from lexer.l
%union {
	int integer;
	char* string;
}

//Define anything that the lexer can return as a string or integer
%type<integer> TERM_INT
%type<integer> TERM_SIZE
%type<string> TERM_STR
%type<string> TERM_SEPARATOR
%type<string> TERM_FULLSTOP
%type<string> TERM_VARIABLE_NAME
%type<string> TERM_INVALID_VARIABLE_NAME

%%

// Create grammer

program:
	/* empty */ |
	begin middle_declarations body grammar_s end {
		printf("\nParsing complete\n");
		exit(0);
	};

begin:
	TERM_BEGINING TERM_FULLSTOP;

body:
	TERM_BODY TERM_FULLSTOP;

end:
	TERM_END TERM_FULLSTOP;

middle_declarations:
	/* empty */ |
	//Left recursive to allow for many declearations
	middle_declarations declaration TERM_FULLSTOP;

declaration:
	TERM_SIZE TERM_VARIABLE_NAME {
		createVar($1, $2);
	}
	|
	TERM_SIZE TERM_INVALID_VARIABLE_NAME {
		printInvalidVarName($2);
	};

grammar_s:
	/* empty */ |
	grammar_s grammar TERM_FULLSTOP;

grammar:
	add | move | print | input;

add:
	TERM_ADD TERM_INT TERM_TO TERM_VARIABLE_NAME {
		addIntToVar($2, $4);
	}
	|
	TERM_ADD TERM_VARIABLE_NAME TERM_TO TERM_VARIABLE_NAME {
		addVarToVar($2, $4);
	}

	;

move:
	TERM_MOVE TERM_VARIABLE_NAME TERM_TO TERM_VARIABLE_NAME {
		moveVarToVar($2, $4);
	}
	|
	TERM_MOVE TERM_INT TERM_TO TERM_VARIABLE_NAME {
		moveIntToVar($2, $4);
	}

	;

print:
	/* empty */ |
	TERM_PRINT rest_of_print {
		printf("\n");
	};

rest_of_print:
	/* empty */ |
	rest_of_print other_print;

other_print:

	TERM_VARIABLE_NAME {
		printVarValue($1);
	}
	|
	TERM_SEPARATOR {
		// do nothing
	}
	|
	TERM_STR {
		printf("%s", $1);
	}

	;

input:
	// Fullstop declares grammar
	TERM_INPUT other_input;

other_input:

	/* empty */ |
	// Input var1
	TERM_VARIABLE_NAME {
		inputValues($1);
	}
	|
	// Can be input var1; var2;...varN
	other_input TERM_SEPARATOR TERM_VARIABLE_NAME {
		inputValues($3);
	}
	;

%%

static Array a;

void initialiseArray(Array *a, size_t initialSize) {
	a->array = (struct variable*) malloc(initialSize * sizeof(struct variable));
	a->used = 0;
	a->size = initialSize;
}

void insertArray(Array *a, struct variable *aVar) {
	if (a->used == a->size) {
		a->size *= 6;
		a->array = (struct variable*) realloc(a->array, a->size * sizeof(struct variable));
	}
	a->array[a->used++] = *aVar;
}

void freeArray(Array *a) {
	free(a->array);
	a->array = NULL;
	a->used = a->size = 0;
}

void createVar(int size, char* varName) {
	bool alreadyDeclared;
	alreadyDeclared = checkIfDeclared(varName);
	// if variable has not been declared we can create it
	if (!alreadyDeclared) {
		struct variable aVar;
 		aVar.varName = varName;
 		aVar.varSize = size;
 		aVar.varValue = 0;

 		insertArray(&a, &aVar);

 		writeToLog("Created variable succesfully\n");
	} else {
		writeToWarning("Variable has already been declared\n");
	}
}

bool checkIfDeclared(char* varName) {
	for (int i = 0; i < a.used; i++) {
		if (strcmp(a.array[i].varName, varName) == 0) {
			// varibable is declared
			return 1;
		}
	}
	// variable has not been declared
	return 0;
}

void inputValues(char* varName) {
	bool alreadyDeclared;
	alreadyDeclared = checkIfDeclared(varName);
	if (!alreadyDeclared) {
		printf("Variable has not been declared: %s\n", varName);
	} else {
		int number;
		scanf("%d", &number);
		int index = getIndexOfVar(varName);
		if (getNumberSize(number) > a.array[index].varSize) {
			printf("Number %d is too large for Variable %s with size %d%s", number, varName, a.array[index].varSize, "\n");
		} else {
			a.array[index].varValue = number;
			printf("\nCompleted Input for Variable %s with value: %d %s", varName, number,"\n");
		}
	}
}

int getIndexOfVar(char* varName) {
	for (int i = 0; i < a.used; i++) {
		if (strcmp(a.array[i].varName, varName) == 0) {
			return i;
		}
	}
	return -1;
}

int getNumberSize(int number) {
	int l = 1;
	while (number > 9) {
		l++;
		number /= 10;
	}
	return l;
}

void moveIntToVar(int number, char* varName) {
	if (checkIfDeclared(varName) == 0) {
		printf("Syntax Error: Variable %s was not declared\n", varName);
	} else {
		int index = getIndexOfVar(varName);
		int varSize = a.array[index].varSize;
		int varValue = a.array[index].varValue;

		// Check that number is not too big for move
		if (getNumberSize(number) <= varSize) {
			a.array[index].varValue = number;
			printf("\nCompleted Move, %s now has a value of: %d %s\n", varName, a.array[index].varValue, "\n");
		} else {
			printf("Warning : Number size %d, is larger than destination size %d for variable %s\n", getNumberSize(number), varSize, varName);
		}
	}
}

void moveVarToVar(char* varName1, char* varName2) {
	if (checkIfDeclared(varName1) == 0) {
		printf("Syntax Error: Variable %s was not declared\n%s", varName1,"\n");
	} else if (checkIfDeclared(varName2) == 0) {
		printf("Syntax Error: Variable %s was not declared\n%s", varName2,"\n");
	} else {
		int index1 = getIndexOfVar(varName1);
		int varSize1 = a.array[index1].varSize;
		int varValue1 = a.array[index1].varValue;

		int index2 = getIndexOfVar(varName2);
		int varSize2 = a.array[index2].varSize;
		int varValue2 = a.array[index2].varValue;

		if (getNumberSize(varValue1) <= varSize2) {
			a.array[index2].varValue = varValue1;
			printf("Completed Move: %s to %s, %s new value is: %d\n", varName1, varName2, varName2, a.array[index2].varValue);
		} else {
			printf("Warning: Variable %s is too big with value %d\nVariable %s has size %d", varName1, varValue1, varName2, varSize2);
		}
	}
}

void addVarToVar(char* varName1, char* varName2) {
	// ADD Y TO Z
	if (checkIfDeclared(varName1) == 0) {
		printf("Syntax Error: Variable %s was not declared\n%s", varName1,"\n");
	} else if (checkIfDeclared(varName2) == 0) {
		printf("Syntax Error: Variable %s was not declared\n%s", varName2,"\n");
	} else {
		int new_varValue;

		int index1 = getIndexOfVar(varName1);
		int varSize1 = a.array[index1].varSize;
		int varValue1 = a.array[index1].varValue;

		int index2 = getIndexOfVar(varName2);
		int varSize2 = a.array[index2].varSize;
		int varValue2 = a.array[index2].varValue;

		// Check if the new value is not too big for varName2
		if (getNumberSize(varValue1) <= varSize2) {
			new_varValue = varValue1 + varValue2;
			if (getNumberSize(new_varValue) > varSize2) {
				printf("Overflow Error, adding %d to %s will cause an overflow. Value of addition is %d\n\n", varValue1, varName2, new_varValue);
			} else {
				a.array[index2].varValue = new_varValue;
				printf("Completed Addition: %s to %s, %s new value is: %d\n\n", varName1, varName2, varName2, a.array[index2].varValue);
			}
		} else {
			printf("Warning: Variable %s is too big with value %d\nVariable %s has size %d", varName1, varValue1, varName2, varSize2);
		}
	}
}

void addIntToVar(int number, char* varName) {
	if (checkIfDeclared(varName) == 0) {
		printf("Syntax Error: Variable %s was not declared\n", varName);
	} else {
		int new_varValue;

		int index = getIndexOfVar(varName);
		int varSize = a.array[index].varSize;
		int varValue = a.array[index].varValue;

		// Check that variable is not too big
		if (getNumberSize(number) <= varSize) {
			// Check if the resulting value can fit into the variable
			new_varValue = number + varValue;
			if (getNumberSize(new_varValue) > varSize) {
				printf("Overflow Error, adding %d to %s will cause an overflow. Value of addition is %d\n\n", number, varName, new_varValue);
			} else {
				a.array[index].varValue = new_varValue;
				printf("Completed Addition, %s now has a value of %d\n\n", varName, a.array[index].varValue);
			}
		} else {
			printf("Number %d size is too large to add to variable %s\n", number, varName);
		}
	}
}

void printVarValue(char* varName) {
	if (checkIfDeclared(varName) == 0) {
		printf("Syntax Error: Variable %s was not declared\n", varName);
	} else {
		int index = getIndexOfVar(varName);
		int varValue = a.array[index].varValue;
		printf("%d", varValue);
	}
}

void printInvalidVarName(char* varName) {
	printf("This is not a valid variable name: %s\n", varName);
}


int main(int argc, char* argv[]) {

	if (argc != 2) {
		yyin = stdin;
		yylex();
	} else {
		FILE* aFile = fopen(argv[1], "r");
		if (!aFile) {
			printf("Cannot open file!\n");
			return -1;
		} else {
			//yydebug = 1;
			int i;
 			initialiseArray(&a, 5);

			yyin = aFile;
			yyparse();
		}
	}

	fclose(yyin);
	freeArray(&a);

	//printf("printing array\n");
	//for (int i = 0; i < a.used; i++) {
	//	printf("name: %s\n", a.array[i].varName);
	//	printf("size: %d\n", a.array[i].varSize);
	//	printf("value: %d\n", a.array[i].varValue);
	//}



 //	for (int i = 0; i < 10; i++) {
 	//	struct variable aVar;
 	//	aVar.varName = "TEST_VAR";
 	//	aVar.varSize = 0;
 	//	aVar.varValue = 0;

 	//	insertArray(&a, &aVar);
 	//}

 	//for (int j = 0; j < a.used; j++) {
 	//	printf("Name: %s\n", a.array[j].varName);
 	//}
 	//printf("Name: %s\n", a.array[9].varName);
 	//printf("Used: %zu\n", a.used);

 	//yyparse();

 	//if (argc > 0) {
 	//	freeArray(&a);
 	//	fclose(yyin);
 	//}
 	return 0;
}

void logUndeclaredVar(char* varName) {
	printf("%s has not been declared");
}

void logDupVar(char* varName) {
	printf("%s has not been declared");
}

void logVarToVarOverflow(char* varName1, char* varName2) {
	printf("");
}

void writeToWarning(char *aWarning){
  printf("Warning : %s%s", aWarning,"\n");
}

void writeToError(char *anError){
  printf("Error : %s%s", anError,"\n");
}

void writeToLog(char *alog){
  printf("Success : %s%s", alog,"\n");
}

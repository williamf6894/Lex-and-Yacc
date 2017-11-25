#define BEGINNING 257
#define BODY 258
#define END 259
#define TERMINATOR 260
#define DECSIZE 261
#define VARIABLE 262
#define PRINT 263
#define INPUT 264
#define NUM 265
#define instruction 266
#define MOVE 267
#define TO 268
#define IDENTIFIER 269
#define ADD 270
#define STRING 271
#define DELIMITER 272
#define NUMBER 273
#ifdef YYSTYPE
#undef  YYSTYPE_IS_DECLARED
#define YYSTYPE_IS_DECLARED 1
#endif
#ifndef YYSTYPE_IS_DECLARED
#define YYSTYPE_IS_DECLARED 1
typedef union {
	int inum;
	float fnum;
	char* str;
} YYSTYPE;
#endif /* !YYSTYPE_IS_DECLARED */
extern YYSTYPE yylval;

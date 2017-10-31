
%{
#include "keywords.h"
%}
letter      [A-Z]
digit       [0-9]
alpha       [A-Z0-9\-]
wspace      [ \t\n]
%s DECLARE VAR MOVE ADD PRINT STRING DIGIT TO BODY INPUT
%%
[ \t\n]* {}
BEGINNING { BEGIN DECLARE; }

[\.]         {return ".";}
BODY        {return BODY; }
PRINT       {BEGIN STRING; return PRINT; }
INPUT       {BEGIN VAR; return INPUT; };
END         return 0;
MOVE        {BEGIN DIGIT; BEGIN TO; BEGIN VAR; return MOVE; }
MOVE        {BEGIN VAR; BEGIN TO; return MOVE; }
ADD         {BEGIN DIGIT; BEGIN TO; return ADD; }
ADD         {BEGIN VAR; BEGIN TO; return ADD; }
TO          {BEGIN VAR; return TO;}
<DECLARE>[X]{0,5} {BEGIN VAR; return DECLARATION; }
<VAR>[A-Z][A-Z0-9\-]* {BEGIN INITIAL; return VARIABLE; }
<STRING>\"[a-zA-Z0-9]*\"  { return STRING; }
<DIGIT>[0-9]+             { return DIGIT; }
%%
int yywrap(void)
{
    return 1;
}

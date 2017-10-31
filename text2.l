
letter      [A-Z]
digit       [0-9]
alpha       [A-Z0-9\-]
wspace      [ \t\n]
%%
[ \t\n]* {}
BEGINNING printf("Beginning ");
"."       printf(" endline\n");
XXXX      printf("Var with 4 ");
XXX       printf("Var with 3 ");
XX        printf("Var with 2 ");
BODY      printf("Body keyword ");
PRINT     printf("Print keyword ");
INPUT     printf("Input keyword ");
END       printf("End of file ");
MOVE      printf("Move ");
ADD       printf("Adding two numbers ");
%%
int yywrap(void)
{
    return 1;
}

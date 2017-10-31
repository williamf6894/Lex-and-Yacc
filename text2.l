letter      [A-Z]
digit       [0-9]
alpha       [A-Z0-9\-]

%optioncaseless
%%

[ \t\n]* {}
BEGINNING                printf("Beginning ");
"."                      printf("EOL\n");
[xX]+                    printf("Declaration with a size of %d for ", yyleng);
BODY                     printf("Body ");
PRINT                    printf("PrintKeyword ");
INPUT                    printf("InputKeyword ");
END                      printf("End of file ");
MOVE                     printf("Move ");
ADD                      printf("Adding two numbers ");
[\t ]                    printf(" ");
;                        printf("[Separator] ");
[\"][^"]*[\"]            printf("String: %s ", yytext);
[a-zA-Z][a-zA-Z0-9\-]*   printf("Variable: %s ", yytext);
[0-9]+                   printf("Digit "); 

%%

int yywrap(void)
{
    return 1;
}

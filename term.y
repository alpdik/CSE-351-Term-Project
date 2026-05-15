%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
int yylex();
extern FILE *yyin;

int expr_count = 0;
int is_left = 1;
%}

%union {
    char *sval;
}

%token <sval> NUMBER REGNUM LABEL
%token MOV LOAD STORE ADDI ADD AND OR XOR BLT BGT BEQ
%token COMMA R

%type <sval> expression

%%

program
    : expr_list
    ;

expr_list
    : expr_list expr
    | expr
    ;

expr
    : NUMBER DOT left_expr right_expr
    | NUMBER DOT left_expr
    ;

left_expr
    : expression EQUALS NUMBER
        {
            expr_count++;
            is_left = 1;
            printf("Expression %d - Left:  %s equals %s.\n", 
                   expr_count, $1, $3);
            free($1); free($3);
        }
    | expression EQUALS NUMBER FINAL

    ;


right_expr
    : expression EQUALS NUMBER
        {
            printf("Expression %d - Right: %s equals %s.\n",
                   expr_count, $1, $3);
            free($1); free($3);
        }
    | expression EQUALS NUMBER FINAL
        {
            
        }
    ;

expression
    : NUMBER PLUS NUMBER
        {
            char *buf = malloc(256);
            sprintf(buf, "%s plus %s", $1, $3);
            $$ = buf;
            free($1); free($3);
        }

   
   
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <input.asm> [output.asm]\n", argv[0]);
        return 1;
    }
    FILE *fin = fopen(argv[1], "r");
    if (!fin) {
        fprintf(stderr, "Cannot open input file: %s\n", argv[1]);
        return 1;
    }
    yyin = fin;

    if (argc > 2) {
        if (!freopen(argv[2], "w", stdout)) {
            fprintf(stderr, "Cannot open output file: %s\n", argv[2]);
            fclose(fin);
            return 1;
        }
    }

    yyparse();
    fclose(fin);
    return 0;
}

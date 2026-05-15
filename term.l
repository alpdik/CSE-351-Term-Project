%{
#include "term.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
%}

%%


[0-9]+(\.[0-9]+)?   { yylval.sval = strdup(yytext); return NUMBER; }
[0-7]   { yylval.sval = strdup(yytext); return REGNUM; }
[a-z]([a-z]|[0-9])*	{yylval.str = strdup(yytext); return LABEL;}


","        { return COMMA; }
"R"         { return R; }
\t			{ return TAB;}


"mov"         { return MOV; }
"load"         { return LOAD; }
"store"         { return STORE; }
"addi"         { return ADDI; }
"add"         { return ADD; }
"and"         { return AND; }
"or"         { return OR; }
"xor"         { return XOR; }
"blt"         { return BLT; }
"bgt"         { return BGT; }
"beq"         { return BEQ; }



[ \t\n]+    { /* skip whitespace */ }
.           { /* skip unknown characters */ }

%%

int yywrap() {
    return 1;
}

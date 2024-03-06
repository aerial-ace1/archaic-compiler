%{
    #include<stdio.h>
    #include<string.h>
    #include<stdlib.h>
    #include<ctype.h>
    #include "lex.yy.c"
    
    int yyerror(const char *s);
    int yylex(void);
    int yywrap();
    int success = 1;
%}

%token PRINTFF SCANFF IF WHILE ELSE RETURN ELIF DECLARE ADD SUB MULT DIV LOG POW GE LE GT LT EQ NE TRUE FALSE AND OR INT FLOAT STRING BOOL CHAR NUM FLOAT_NUM ID STR CHARACTER
%define parse.error verbose

%%

program: entry '(' ')' '{' body return '}'
;


entry: datatype ID
;

datatype: INT 
| FLOAT 
| CHAR
| BOOL
;

body: block body
| 
;

block: WHILE '(' condition ')' '{' body '}'
| IF '(' condition ')' '{' body '}' else_if_block else
| statement ';' 
| PRINTFF '(' STR ')' ';'
| PRINTFF '(' ID ')' ';'
| SCANFF '(' STR ',' '&' ID ')' ';'
;

else_if_block: ELIF '(' condition ')' '{' body '}' else_if_block
|
;

else: ELSE  '{' body '}'
|
;

condition: condition and_or condition
| value_global relop value_global
| TRUE 
| FALSE
;

statement: DECLARE datatype ID init 
| ID '=' expression 
| ID relop expression 
;

init: '=' expression
| '=' charbool
;


expression : expression addops term 
| term 
;

term : term mulops factor 
| factor 
; 

factor : base exponent base 
| LOG '(' value ',' value ')' 
| base
;

base : value 
| '(' expression ')' 
;


exponent: POW
;

mulops: MULT
| DIV
;

addops: ADD 
| SUB 
;

relop: LT
| GT
| LE
| GE
| EQ
| NE
;

and_or : AND
| OR
;

value: NUM
| FLOAT_NUM
| ID
;

value_global: value
| charbool
;

charbool: CHARACTER
| TRUE
| FALSE
;

return: RETURN value_global ';' 
|
;

%%

int main() {
    extern FILE *yyin, *yyout;
   
    yyparse();
    if(success)
        printf("Parsing Successful\n");
    return 0;
}

int yyerror(const char *msg)
{
    extern int yylineno;
    printf("Parsing Failed\nLine Number: %d %s\n",yylineno,msg);
    success = 0;
    return 0;
}

%{
    #include "y.tab.h"
    int countn=0;
%}
%option yylineno
%option noinput nounput
alphabet [a-zA-Z]
digit [0-9]

%%

"proclaim"		{ strcpy(yylval.nd_obj.name,(yytext)); return PRINT; }
"inquire"		{ strcpy(yylval.nd_obj.name,(yytext)); return SCAN; }

"perhaps"      { strcpy(yylval.nd_obj.name,(yytext)); return IF; }
"otherwise"		{ strcpy(yylval.nd_obj.name,(yytext)); return ELSE; }
"yield" 		   { strcpy(yylval.nd_obj.name,(yytext)); return RETURN; }
"however"      { strcpy(yylval.nd_obj.name,(yytext)); return ELIF; }
"anew"	      { strcpy(yylval.nd_obj.name,(yytext)); return DECLARE; }
"+"		      { strcpy(yylval.nd_obj.name,(yytext)); return ADD; }
"-"		      { strcpy(yylval.nd_obj.name,(yytext)); return SUB; }
"*"		      { strcpy(yylval.nd_obj.name,(yytext)); return MULT; }
"/"		      { strcpy(yylval.nd_obj.name,(yytext)); return DIV; }
"log"		      { strcpy(yylval.nd_obj.name,(yytext)); return LOG; }
"exp"		      { strcpy(yylval.nd_obj.name,(yytext)); return POW; }
"whilst"       { strcpy(yylval.nd_obj.name,(yytext)); return WHILE; }

">="		      { strcpy(yylval.nd_obj.name,(yytext)); return GE; }
"<="		      { strcpy(yylval.nd_obj.name,(yytext)); return LE; }
">"		      { strcpy(yylval.nd_obj.name,(yytext)); return GT; }
"<"		      { strcpy(yylval.nd_obj.name,(yytext)); return LT; }
"=="		      { strcpy(yylval.nd_obj.name,(yytext)); return EQ; }
"=!="		      { strcpy(yylval.nd_obj.name,(yytext)); return NE; }

"indeed"		   { strcpy(yylval.nd_obj.name,(yytext)); return TRUE; }
"nay"		      { strcpy(yylval.nd_obj.name,(yytext)); return FALSE; }
"&&"		      { strcpy(yylval.nd_obj.name,(yytext)); return AND; }
"||"		      { strcpy(yylval.nd_obj.name,(yytext)); return OR; }


"num"		      { strcpy(yylval.nd_obj.name,(yytext)); return INT; }
"dec"		      { strcpy(yylval.nd_obj.name,(yytext)); return FLOAT; }
"str"		      { strcpy(yylval.nd_obj.name,(yytext)); return STR; }
"bool"		   { strcpy(yylval.nd_obj.name,(yytext)); return BOOL; }
"char"         { strcpy(yylval.nd_obj.name,(yytext)); return CHAR; }

\#.*			   { ; }
[ \t]*			{ ; }
[\n]			   { countn++; }


[-]?{digit}+                		{ strcpy(yylval.nd_obj.name,(yytext)); return NUM; }
[-]?{digit}+\.{digit}{1,6}  		{ strcpy(yylval.nd_obj.name,(yytext)); return FLOAT_NUM; }
{alphabet}({alphabet}|{digit})*  { strcpy(yylval.nd_obj.name,(yytext)); return ID; }



["].*["]                    { strcpy(yylval.nd_obj.name,(yytext)); return STR; }
['].[']                     { strcpy(yylval.nd_obj.name,(yytext)); return CHARACTER; }

";"|"="|","|"{"|"}"|"("|")"|"["|"]"|"*"|"+"|"-"|"/"|"?"|":"|"&"|"|"|"^"|"!"|"~"|"%"|"<"|">" { strcpy(yylval.nd_obj.name,(yytext));return yytext[0];}

%%

int yywrap() {
    return 1;
}
%{    
     #include "y.tab.h"
     int line_no=0;
%}

%option yylineno
%option noinput nounput
alphabet          [a-zA-Z]
digit          [0-9]

%%

"proclaim"		{ return PRINTFF; } -
"inquire"		{ return SCANFF; } -

"perhaps"      { return IF; } - 
"otherwise"		{ return ELSE; } - 
"yield" 		   { return RETURN; } -
"however"      { return ELIF; }
"anew"	      { return DECLARE; }
"+"		      { return ADD; }
"-"		      { return SUB; }
"*"		      { return MULT; }
"/"		      { return DIV; }
"log"		      { return LOG; }
"exp"		      { return POW; }
"whilst"       { return WHILE; } nope

">="		      { return GE; } -
"<="		      { return LE; } - 
">"		      { return GT; } -
"<"		      { return LT; } -
"=="		      { return EQ; } - 
"=!="		      { return NE; } -

"indeed"		   { return TRUE; } -
"nay"		      { return FALSE; } -
"&&"		      { return AND; } -
"||"		      { return OR; } -


"num"		      { return INT; }
"dec"		      { return FLOAT; }
"str"		      { return STRING; } nope
"bool"		   { return BOOL; }
"char"         { return CHAR; }

\#.*			   { ; }
[ \t]*			{ ; }
[\n]			   { line_no++; }


[-]?{digit}+                		{ return NUM; } -
[-]?{digit}+\.{digit}{1,6}  		{ return FLOAT_NUM; }-
{alphabet}({alphabet}|{digit})*  { return ID; }-



["].*["]                    { return STR; } -
['].[']                     { return CHARACTER; } -

";"|"="|","|"{"|"}"|"("|")"|"["|"]"|"*"|"+"|"-"|"/"|"?"|":"|"&"|"|"|"^"|"!"|"~"|"%"|"<"|">" {return yytext[0];}


%%

int yywrap(void) {
   return 1;
}


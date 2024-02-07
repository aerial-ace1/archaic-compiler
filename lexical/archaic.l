%{
#include <string>
#include <iostream>
#include <vector>
#include <utility>

#include "colors.h"

extern FILE* yyin;

int col =0;
int line=0;

#define OFFSET col+=yyleng
#define APPEND(x) tokens.push_back( { {x, yytext},{line,col}})  

std::vector<std::pair<std::vector<std::string>, std::vector<int> >> tokens;
extern "C" int yywrap() { return 1;}
bool hasError = false;
%}


%%

[ \t]                   { col++;}
[\n]                    { line++; col=0;}
"proclaim"					{ OFFSET; APPEND("proclaim"); }
"inquire"					{ OFFSET; APPEND("inquire"); }
"perhaps"					{ OFFSET; APPEND("perhaps");}
"however"					{ OFFSET; APPEND("however"); }
"otherwise"					{ OFFSET; APPEND("otherwise"); }
"yield"				{ OFFSET; APPEND("yield"); }
"anew"					{ OFFSET; APPEND("anew"); }
"+"					    { OFFSET; APPEND("+"); }
"-"					    { OFFSET; APPEND("-"); }
"*"					    { OFFSET; APPEND("*"); }
"/"					    { OFFSET; APPEND("/"); }
"method"				{ OFFSET; APPEND("method"); }
"indeed"					{ OFFSET; APPEND("indeed"); }
">="					{ OFFSET; APPEND(">="); }
"<="					{ OFFSET; APPEND("<="); }
">"					    { OFFSET; APPEND(">"); }
"<"					    { OFFSET; APPEND("<"); }
"=="					{ OFFSET; APPEND("=="); }
"=!"					{ OFFSET; APPEND("=!"); }
"("					    { OFFSET; APPEND("("); }
")"					    { OFFSET; APPEND(")"); }
"{"					    { OFFSET; APPEND("{"); }
"}"					    { OFFSET; APPEND("}"); }
"="					    { OFFSET; APPEND("="); }
";"					    { OFFSET; APPEND(";"); }
"nay"					{ OFFSET; APPEND("nay"); }
"&&"					{ OFFSET; APPEND("&&"); }
"||"					{ OFFSET; APPEND("||"); }
"num"					{ OFFSET; APPEND("num"); }
"dec"					{ OFFSET; APPEND("dec"); }
"str"					{ OFFSET; APPEND("str"); }
"bool"					{ OFFSET; APPEND("bool"); }

\#.*			        { ; }
[_a-zA-z][_a-zA-Z0-9]* { OFFSET; APPEND("ID"); }
[0-9]+\.[0-9]*	        { OFFSET; APPEND("DEC"); }
[0-9]+   	            { OFFSET; APPEND("INT"); }
["].*["]                { OFFSET; APPEND("STR"); }
['].*[']                { OFFSET; APPEND("STR"); }


.                       { std::cout << RED << "Unknown input " << BOLDRED << std::string(yytext,yyleng) << " at Line : " << line << " and Col : " << col << RESET << std::endl; 
							hasError = true; 
							yyterminate();
						}
%%

int main(){
	yyin = fopen("input.txt","r");
	yylex();
	if(hasError) {
		std::cout << RED << "Exited on Error" << RESET << std::endl;
		return 1;
	}
    
    std::cout<< BOLDWHITE << "Lexeme"<< BOLDBLUE << "\t" << WHITE <<"Token"  << "\t" << BOLDBLUE << "Line" "\t" << BOLDBLUE << "Col\n" << RESET;

	for(auto &x: tokens){
		std::cout<< BOLDWHITE <<x.first[0] << "\t" << BOLDRED << x.first[1] << "\t"<< CYAN << x.second[0] << "\t"<< BOLDYELLOW << x.second[1] << RESET << "\n";
	}
}
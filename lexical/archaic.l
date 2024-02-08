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

[ \t]                   		{ col++;}
[\n]                    		{ line++; col=0;}
"proclaim"						{ OFFSET; APPEND("proclaim"); }
"inquire"						{ OFFSET; APPEND("inquire"); }
"perhaps"						{ OFFSET; APPEND("perhaps");}
"however"						{ OFFSET; APPEND("however"); }
"otherwise"						{ OFFSET; APPEND("otherwise"); }
"yield"							{ OFFSET; APPEND("yield"); }
"anew"							{ OFFSET; APPEND("anew"); }
"+"					    		{ OFFSET; APPEND("+"); }
"-"					    		{ OFFSET; APPEND("-"); }
"*"					    		{ OFFSET; APPEND("*"); }
"/"					    		{ OFFSET; APPEND("/"); }
"method"						{ OFFSET; APPEND("method"); }
"indeed"						{ OFFSET; APPEND("indeed"); }
">="							{ OFFSET; APPEND(">="); }
"<="							{ OFFSET; APPEND("<="); }
">"					    		{ OFFSET; APPEND(">"); }
"<"					    		{ OFFSET; APPEND("<"); }
"=="							{ OFFSET; APPEND("=="); }
"=!"							{ OFFSET; APPEND("=!"); }
"("					    		{ OFFSET; APPEND("("); }
")"					    		{ OFFSET; APPEND(")"); }
"{"					    		{ OFFSET; APPEND("{"); }
"}"					    		{ OFFSET; APPEND("}"); }
"="					    		{ OFFSET; APPEND("="); }
";"					    		{ OFFSET; APPEND(";"); }
"nay"							{ OFFSET; APPEND("nay"); }
"&&"							{ OFFSET; APPEND("&&"); }
"||"							{ OFFSET; APPEND("||"); }
"num"							{ OFFSET; APPEND("num"); }
"dec"							{ OFFSET; APPEND("dec"); }
"str"							{ OFFSET; APPEND("str"); }
"bool"							{ OFFSET; APPEND("bool"); }
"char"							{ OFFSET; APPEND("char"); }

\#.*			        		{  }
[0-9]+[_a-zA-Z][_a-zA-Z0-9]* 	{ 
									std::cout << RED << "Identifiers can't start with a number " << BOLDRED << std::string(yytext,yyleng) << " at Line : " << line << " and Col : " << col << RESET << std::endl; 
									hasError = true; 
									yyterminate();
						    	}
[_a-zA-z][_a-zA-Z0-9]*  		{ OFFSET; APPEND("ID"); }
[+-]?[0-9]+\.[0-9]*	        	{ OFFSET; APPEND("DEC"); }
[0-9]+   	            		{ OFFSET; APPEND("NUM"); }
["].*["]                		{ OFFSET; APPEND("STR"); }
['].[']                			{ OFFSET; APPEND("CHAR"); }

.                       		{ 
									std::cout << RED << "Unknown input " << BOLDRED << std::string(yytext,yyleng) << " at Line : " << line << " and Col : " << col << RESET << std::endl; 
									hasError = true; 
									yyterminate();
								}
%%

int main(){
	yyin = fopen("input.txt","r");
	yylex();
	if(hasError) {
		std::cout << RED << "Exited on Error while Tokenizing" << RESET << std::endl;
		return 1;
	}
    
    std::cout<< GREEN << "Lexeme" << "\t\t" << "Token"  << "\t\t" << "Line" "\t\t" << "Col\n" << RESET;

	for(auto &x: tokens){
		std::string tabSpace1 = "\t\t";
		std::string tabSpace2 = "\t\t";
		if(x.first[0].size() >= 8)
			tabSpace1 = "\t";
		if(x.first[1].size() >= 8)
			tabSpace2 = "\t";
		std::cout<< BOLDWHITE <<x.first[0] << tabSpace1 << BOLDRED << x.first[1] << tabSpace2 << CYAN << x.second[0] << "\t\t" << BOLDYELLOW << x.second[1] << RESET << "\n";
	}
}
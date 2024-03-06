%{
    #include<stdio.h>
    #include<string.h>
    #include<stdlib.h>
    #include<ctype.h>
    #include"archaic_tree.yy.c"
    
    int yyerror(const char *s);
    int yylex(void);
    int yywrap();
    

    struct node* mknode(struct node *left, struct node *right, char *token);
    void printBT(struct node*);

    struct node *head;
    struct node { 
        struct node *left; 
        struct node *right; 
        char *token; 
    };
%}


%union { 
	struct var_name { 
		char name[100]; 
		struct node* nd;
	} nd_obj; 
}

%token <nd_obj> PRINT SCAN IF WHILE ELSE RETURN ELIF DECLARE ADD SUB MULT DIV LOG POW GE LE GT LT EQ NE TRUE FALSE AND OR INT FLOAT STRING BOOL CHAR NUM FLOAT_NUM ID STR CHARACTER

%type <nd_obj> program entry datatype body block else condition statement init expression term factor base exponent mulops addops relop value return and_or
 %define parse.error verbose 
%%

program: entry '(' ')' '{' body return '}' { struct node *main = mknode($5.nd, $6.nd, "Main"); $$.nd = mknode($1.nd, main, "Program"); head = $$.nd; } 
;

entry: datatype ID
;

datatype: INT 
| FLOAT 
| CHAR
| BOOL
;

body: block body {$$.nd = mknode($1.nd, $2.nd, "Scope");}
| { $$.nd = mknode(NULL, NULL, "EndOfScope"); }
;

block: WHILE '(' condition ')''{' body '}' { $$.nd = mknode($3.nd, $6.nd, $1.name); }
| IF '(' condition ')''{' body '}' else { struct node *iff = mknode($3.nd, $6.nd, $1.name); $$.nd = mknode(iff, $8.nd, "if-else"); }
| statement ';' { $$.nd = $1.nd; }
| PRINT '(' STR ')' ';' { struct node *data = mknode(NULL, NULL, $3.name); $$.nd = mknode(NULL, data, "print"); }
| PRINT '(' ID ')' ';' { struct node *data = mknode(NULL, NULL, $3.name); $$.nd = mknode(NULL, data, "print"); }
;

else: ELSE '{' body '}' {  struct node *cond = mknode(NULL, NULL, "EndOfConditional"); $$.nd = mknode($3.nd, cond, $1.name); }
| { $$.nd = NULL; }
;

condition: condition and_or condition { $$.nd = mknode($1.nd, $3.nd, $2.name); }
| value relop value { $$.nd = mknode($1.nd, $3.nd, $2.name);}
| TRUE {$$.nd = NULL; }
| FALSE {$$.nd = NULL; }
;

statement: DECLARE datatype ID init {$2.nd = mknode(NULL, NULL, $2.name); $3.nd = mknode(NULL, NULL, $3.name); $1.nd = mknode($2.nd, $3.nd, $1.name); $$.nd = mknode($1.nd, $4.nd, "var_init");} 
| ID '=' expression { $1.nd = mknode(NULL, NULL, $1.name); $$.nd = mknode($1.nd, $3.nd, "="); }
| ID relop expression { $1.nd = mknode(NULL, NULL, $1.name); $$.nd = mknode($1.nd, $3.nd, $2.name ); }
;

init: '=' value { $$.nd = $2.nd;}
| '=' expression { $$.nd = $2.nd;}
| { $$.nd = NULL; }
;


expression : expression addops term { $$.nd = mknode($1.nd, $3.nd, $2.name); }
| term { $$.nd = $1.nd;}
;

term : term mulops factor { $$.nd = mknode($1.nd, $3.nd, $2.name); }
| factor {$$.nd = $1.nd;}
; 

factor : base exponent base { $$.nd = mknode($1.nd, $3.nd, $2.name); }
| LOG '(' value ',' value ')' {$$.nd = mknode($3.nd, $5.nd, $1.name); }
| base {$$.nd = $1.nd;}
;

base : value {$$.nd = $1.nd;}
| '(' expression ')' {$$.nd = $2.nd;}
;

and_or : AND { $$.nd = mknode(NULL, NULL, $1.name); }
| OR { $$.nd = mknode(NULL, NULL, $1.name); }
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

value: NUM {$$.nd = mknode(NULL, NULL, $1.name);}
| FLOAT_NUM {$$.nd = mknode(NULL, NULL, $1.name);}
| ID {$$.nd = mknode(NULL, NULL, $1.name);}
| CHARACTER {$$.nd = mknode(NULL, NULL, $1.name);}
| TRUE {$$.nd = mknode(NULL, NULL, $1.name);}
| FALSE {$$.nd = mknode(NULL, NULL, $1.name);}
| SCAN '('')' { $$.nd = mknode(NULL, NULL, "scan"); }
;

return: RETURN value ';'  { $1.nd = mknode(NULL, NULL, "return"); $$.nd = mknode($1.nd, $2.nd, "Return"); }
| { $$.nd = NULL; } 
;

%%


int main() {
    extern FILE *yyin, *yyout;
   
    int p = -1;
    p = yyparse();
    if(p)
        printf("Parsing Successful\n");

    printf("\n\n");
    printf("parse tree :");
    printf("\n\n");
	printBT(head);
    printf("\n\n");

    
    return p;
}

int yyerror(const char *msg)
{
    extern int yylineno;
    printf("Parsing Failed\nLine Number: %d %s\n",yylineno,msg);
    return 0;
}

void printBTHelper(char* prefix, struct node* ptr, int isLeft) {
    if( ptr != NULL ) {
        printf("%s",prefix);
        if(isLeft) { printf("├──"); } 
		else { printf("└──"); }
        printf("%s",ptr->token);
		printf("\n");
		char* addon = isLeft ? "│   " : "    ";
    	int len2 = strlen(addon);
    	int len1 = strlen(prefix);
    	char* result = (char*)malloc(len1 + len2 + 1);
    	strcpy(result, prefix);
    	strcpy(result + len1, addon);
		printBTHelper(result, ptr->left, 1);
		printBTHelper(result, ptr->right, 0);
    	free(result);
    }
}

void printBT(struct node* ptr) {
	printf("\n");
    printBTHelper("", ptr, 0);    
}

struct node* mknode(struct node *left, struct node *right, char *token) {	
	struct node *newnode = (struct node *)malloc(sizeof(struct node));
	char *newstr = (char *)malloc(strlen(token)+1);
	strcpy(newstr, token);
	newnode->left = left;
	newnode->right = right;
	newnode->token = newstr;
	return(newnode);
}
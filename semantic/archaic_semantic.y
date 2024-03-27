%{
    #include<stdio.h>
    #include<string.h>
    #include<stdlib.h>
    #include<ctype.h>
	#include <stdbool.h>
    #include"lex.yy.c"
    void yyerror(const char *s);
    int yylex();
    int yywrap();
    void add(char);
    void insert_type();
    int search(char *);
	void insert_type();
	void print_tree(struct node*);
	void print_inorder(struct node *);
    void check_declaration(char *);
	void check_return_type(char *);
	int check_types(char *, char *);
	char *get_type(char *);
	void printBT(struct node*);
	struct node* mknode(struct node *left, struct node *right, char *token);

    struct dataType {
        char * id_name;
        char * data_type;
        char * type;
        int line_no;
	} symbol_table[40];
	int undeclared = 0;
    int count=0;
    int q;
	char type[10];
    extern int countn;
	struct node *head;
	int sem_errors=0;
	int label=0;
	char buff[100];
	char errors[10][100];
	char reserved[10][10] = {"int", "float", "char", "void", "if", "else", "for", "main", "return", "include"};

	struct node { 
		struct node *left; 
		struct node *right; 
		char *token; 
	};

%}

%union { struct var_name { 
			char name[100]; 
			struct node* nd;
			char type[5];
		} nd_obj;

		struct var_name2 { 
			char name[100]; 
			struct node* nd;
			char type[5];
		} nd_obj2; 
	} 
%token VOID 
%token <nd_obj> PRINT SCAN IF WHILE ELSE RETURN ELIF DECLARE ADD SUB MULT DIV LOG POW GE LE GT LT EQ NE TRUE FALSE AND OR INT FLOAT BOOL CHAR NUM FLOAT_NUM ID STR CHARACTER
%type <nd_obj> program entry datatype body block else condition statement term factor base exponent mulops addops relop return and_or arithmetic
%type <nd_obj2> init value expression 
%define parse.error verbose 
%%

program: entry '(' ')' '{' body return '}' { struct node *main = mknode($5.nd, $6.nd, "Main"); $$.nd = mknode($1.nd, main, "Program"); head = $$.nd; } 
;

entry: datatype ID { add('F'); }
;

datatype: INT { insert_type(); }
| FLOAT { insert_type(); }
| CHAR { insert_type(); }
| BOOL { insert_type(); }
| STR { insert_type(); }
| VOID { insert_type(); }
;

body: IF { add('K'); } '(' condition ')' '{' body '}' else { 
	struct node *iff = mknode($4.nd, $7.nd, $1.name); 
	$$.nd = mknode(iff, $9.nd, "if-else"); 
}
| statement ';' { $$.nd = $1.nd; }
| body body { $$.nd = mknode($1.nd, $2.nd, "statements"); }
| PRINT { add('K'); } '(' value ')' ';' { $$.nd = mknode($4.nd, NULL, "printf");  }
| WHILE '(' condition ')' '{' body '}'

;

else: ELSE { add('K'); } '{' body '}' { $$.nd = mknode(NULL, $4.nd, $1.name); }
| { $$.nd = NULL; }
;

condition: condition AND condition { $$.nd = mknode($1.nd, $3.nd, "AND"); }
| condition OR condition { $$.nd = mknode($1.nd, $3.nd, "OR"); }
| value relop value { $$.nd = mknode($1.nd, $3.nd, $2.name); }
| TRUE { add('K'); $$.nd = NULL; }
| FALSE { add('K'); $$.nd = NULL; }
| { $$.nd = NULL; }
;

statement: DECLARE datatype ID { add('V');} init { 
	$2.nd = mknode(NULL, NULL, $3.name); 
	int t = check_types($2.name, $5.type); 
	if(t>0) { 
		if(t == 1) {
			if(strcmp($2.name, "dec") != 0){
				sprintf(errors[sem_errors], "Line %d: Cannot cast %s to dec\n", countn+1, $2.name);
				sem_errors++;
			}
			struct node *temp = mknode(NULL, $5.nd, "toFloat"); 
			$$.nd = mknode($3.nd, temp, "declaration"); 
		} 
		else if(t == 2) { 
			if(strcmp($2.name, "num") != 0){
				sprintf(errors[sem_errors], "Line %d: Cannot cast %s to int\n", countn+1, $2.name);
				sem_errors++;
			}
			struct node *temp = mknode(NULL, $5.nd, "toInt"); 
			$$.nd = mknode($3.nd, temp, "declaration"); 
		} 
		else {
			if(strcmp($2.name, "str") != 0){
				sprintf(errors[sem_errors], "Line %d: Cannot cast %s to str\n", countn+1, $2.name);
				sem_errors++;
			} 
			struct node *temp = mknode(NULL, $5.nd, "toString"); 
			$$.nd = mknode($3.nd, temp, "declaration"); 
		}
	} 
	else { 
		$$.nd = mknode($3.nd, $5.nd, "declaration"); 
	} 
}
| ID { check_declaration($1.name); } '=' expression {
	
	if(undeclared){
		undeclared = 0;
		return;
	}
	$1.nd = mknode(NULL, NULL, $1.name); 
	char *id_type = get_type($1.name); 
	int t = check_types(id_type, $4.type); 
	if(t>0) { 
		if(t == 1) {
			if(strcmp(id_type, "dec") != 0){
				sprintf(errors[sem_errors], "Line %d: Cannot cast %s to dec\n", countn+1, id_type);
				sem_errors++;
			}
			struct node *temp = mknode(NULL, $4.nd, "toFloat");
			$$.nd = mknode($1.nd, temp, "=");  
		} 
		else if(t == 2) { 
			if(strcmp(id_type, "num") != 0){
				sprintf(errors[sem_errors], "Line %d: Cannot cast %s to num\n", countn+1, id_type);
				sem_errors++;
			}
			struct node *temp = mknode(NULL, $4.nd, "toInt");
			$$.nd = mknode($1.nd, temp, "=");  
		} 
		else {
			if(strcmp(id_type, "str") != 0){
				sprintf(errors[sem_errors], "Line %d: Cannot cast %s to num\n", countn+1, id_type);
				sem_errors++;
			}
			struct node *temp = mknode(NULL, $4.nd, "toString");
			$$.nd = mknode($1.nd, temp, "=");  
		}
	} 
	else { 
		$$.nd = mknode($1.nd, $4.nd, "="); 
	}
}
| ID { check_declaration($1.name); } relop expression { 
	if(undeclared){
		undeclared = 0;
		return;
	}
	$1.nd = mknode(NULL, NULL, $1.name); $$.nd = mknode($1.nd, $4.nd, $3.name); }
;

init: '=' expression { $$.nd = $2.nd; sprintf($$.type, $2.type); strcpy($$.name, $2.name); }
| { sprintf($$.type, "null"); $$.nd = mknode(NULL, NULL, "NULL"); strcpy($$.name, "NULL"); }
;

expression: expression arithmetic expression { 
	if(!strcmp($1.type, $3.type)) {
		if(!strcmp($1.type,"str") && strcmp($2.name, "+") != 0 ){
			sprintf(errors[sem_errors], "Line %d: Unpermitted operation on string \"%s \"!\n", countn+1, $2.name);
			sem_errors++;
		}
		else {
			sprintf($$.type, $1.type);
			$$.nd = mknode($1.nd, $3.nd, $2.name); 
		}
	}
	else {
		if(!strcmp($1.type, "float")){
			if(!strcmp($3.type, "int")) {
				struct node *temp = mknode(NULL, $3.nd, "inttofloat");
				sprintf($$.type, $1.type);
				$$.nd = mknode($1.nd, temp, $2.name);
			} else if (!strcmp($3.type, "char")) {
				struct node *temp = mknode(NULL, $3.nd, "chartofloat");
				sprintf($$.type, $1.type);
				$$.nd = mknode($1.nd, temp, $2.name);
			} else if(!strcmp($3.type, "bool")) {
				struct node *temp = mknode(NULL, $3.nd, "booltofloat");
				sprintf($$.type, $1.type);
			} 
			else {
				sprintf(errors[sem_errors], "Line %d: Mismatching Types in Expression on types \"%s && %s\"!\n", countn+1, $1.type, $3.type);
				sem_errors++;
			}
		} else if( !strcmp($1.type, "int")){
			if (!strcmp($3.type, "char")) {
				struct node *temp = mknode(NULL, $3.nd, "chartoint");
				sprintf($$.type, $1.type);
				$$.nd = mknode($1.nd, temp, $2.name);
			} else if(!strcmp($3.type, "bool")) {
				struct node *temp = mknode(NULL, $3.nd, "booltoint");
				sprintf($$.type, $1.type);
			} else if(!strcmp($3.type, "float")) {
				struct node *temp = mknode(NULL, $3.nd, "float");
				sprintf($$.type, $3.type);
			} 
			else {
				sprintf(errors[sem_errors], "Line %d: Mismatching Types in Expression on types \"%s && %s\"!\n", countn+1, $1.type, $3.type);
				sem_errors++;
			}
		} else if(!strcmp($1.type, "char")){
			if(!strcmp($3.type, "int")) {
				struct node *temp = mknode(NULL, $3.nd, "num");
				sprintf($$.type, $3.type);
				$$.nd = mknode($1.nd, temp, $2.name);
			} else if (!strcmp($3.type, "float")) {
				struct node *temp = mknode(NULL, $3.nd, "float");
				sprintf($$.type, $3.type);
				$$.nd = mknode($1.nd, temp, $2.name);
			} else if(!strcmp($3.type, "bool")) {
				struct node *temp = mknode(NULL, $3.nd, "booltochar");
				sprintf($$.type, $1.type);
			} else if(!strcmp($3.type, "str")) {
				struct node *temp = mknode(NULL, $3.nd, "strtochar");
				sprintf($$.type, $3.type);
			}
			else {
				sprintf(errors[sem_errors], "Line %d: Mismatching Types in Expression on types \"%s && %s\"!\n", countn+1, $1.type, $3.type);
				sem_errors++;
			}
		} else if (!strcmp($1.type, "bool")){
			if(!strcmp($3.type, "int")) {
				struct node *temp = mknode(NULL, $3.nd, "booltonum");
				sprintf($$.type, $3.type);
			} else if (!strcmp($3.type, "float")) {
				struct node *temp = mknode(NULL, $3.nd, "booltofloat");
				sprintf($$.type, $3.type);
			} else if(!strcmp($3.type, "char")) {
				struct node *temp = mknode(NULL, $3.nd, "booltochar");
				sprintf($$.type, $3.type);
			}
			else {
				sprintf(errors[sem_errors], "Line %d: Mismatching Types in Expression on types \"%s && %s\"!\n", countn+1, $1.type, $3.type);
				sem_errors++;
			}
		} else if (!strcmp($1.type, "str")){

			if( strcmp($2.name, "+") != 0 ){
				sprintf(errors[sem_errors], "Line %d: Unpermitted operation on string \"%s \"!\n", countn+1, $2.name);
				sem_errors++;
			}
			else if(!strcmp($3.type, "char")) {
				struct node *temp = mknode(NULL, $3.nd, "chartostr");
				sprintf($$.type, $1.type);
			} else if (!strcmp($3.type, "float")) {
				struct node *temp = mknode(NULL, $3.nd, "floattostr");
				sprintf($$.type, $1.type);
			} else if(!strcmp($3.type, "int")) {
				struct node *temp = mknode(NULL, $3.nd, "numtostr");
				sprintf($$.type, $1.type);
			} else if(!strcmp($3.type, "bool")) {
				struct node *temp = mknode(NULL, $3.nd, "booltostr");
				sprintf($$.type, $1.type);
			}
			else {
				sprintf(errors[sem_errors], "Line %d: Mismatching Types in Expression on types \"%s && %s\"!\n", countn+1, $1.type, $3.type);
				sem_errors++;
			}
		}
	}
}
| value { strcpy($$.name, $1.name); sprintf($$.type, $1.type);  $$.nd = $1.nd; }
;

arithmetic: ADD 
| SUB
| MULT
| DIV
;

relop: LT
| GT
| LE
| GE
| EQ
| NE
;

value: NUM { strcpy($$.name, $1.name); sprintf($$.type, "int"); add('C'); $$.nd = mknode(NULL, NULL, $1.name); }
| FLOAT_NUM { strcpy($$.name, $1.name); sprintf($$.type, "float"); add('C'); $$.nd = mknode(NULL, NULL, $1.name); }
| CHARACTER { strcpy($$.name, $1.name); sprintf($$.type, "char"); add('C'); $$.nd = mknode(NULL, NULL, $1.name); }
| STR { strcpy($$.name, $1.name); sprintf($$.type, "str"); add('C'); $$.nd = mknode(NULL, NULL, $1.name); }
| ID { strcpy($$.name, $1.name); char *id_type = get_type($1.name); sprintf($$.type, id_type); check_declaration($1.name); $$.nd = mknode(NULL, NULL, $1.name); }
| TRUE { strcpy($$.name, $1.name); sprintf($$.type, "bool"); add('C'); $$.nd = mknode(NULL, NULL, $1.name); }
| FALSE { strcpy($$.name, $1.name); sprintf($$.type, "bool"); add('C'); $$.nd = mknode(NULL, NULL, $1.name); }
| SCAN { add('K'); } '(' datatype ')' { 
	strcpy($$.name, $1.name); add('C'); sprintf($$.type, $4.name); $$.nd = mknode(NULL, NULL, "scanf");  
	}
;

return: RETURN { add('K'); } value ';' { check_return_type($3.name); $1.nd = mknode(NULL, NULL, "return"); $$.nd = mknode($1.nd, $3.nd, "RETURN"); }
| { $$.nd = NULL; }
;

%%

int main() {
    yyparse();
    printf("\n\n");
	printf("1: Symbol Table \n\n");
	printf("\nSYMBOL   DATATYPE   TYPE   LINE NUMBER \n");
	printf("_______________________________________\n\n");
	int i=0;
	for(i=0; i<count; i++) {
		printf("%s\t%s\t%s\t%d\t\n", symbol_table[i].id_name, symbol_table[i].data_type, symbol_table[i].type, symbol_table[i].line_no);
	}
	for(i=0;i<count;i++) {
		free(symbol_table[i].id_name);
		free(symbol_table[i].type);
	}
	printf("\n\n");
	printf("2: Syntax Tree \n\n");
	printBT(head); 
	printf("\n\n\n\n");
	printf("3: Semantic Analyser \n\n");
	if(sem_errors>0) {
		printf("Semantic analysis completed with %d errors\n", sem_errors);
		for(int i=0; i<sem_errors; i++){
			printf("\t - %s", errors[i]);
		}
	} else {
		printf("Semantic analysis completed with no errors");
	}
	printf("\n\n");
}

int search(char *type) {
	int i;
	for(i=count-1; i>=0; i--) {
		if(strcmp(symbol_table[i].id_name, type)==0) {
			return -1;
			break;
		}
	}
	return 0;
}

void check_declaration(char *c) {
    q = search(c);
    if(!q) {
		char buffer[500];
        sprintf(errors[sem_errors], "Line %d: Variable \"%s\" not declared before usage!\n", countn+1, c);
        int j = snprintf(buffer, sizeof buffer, errors[sem_errors], "Line %d: Variable \"%s\" not declared before usage!\n", countn+1, c);
		sem_errors++;
		yyerror(buffer);
		undeclared = 1;
    }
}

void check_return_type(char *value) {
	char *main_datatype = get_type("main");
	char *return_datatype = get_type(value);
	if((!strcmp(main_datatype, "int") && !strcmp(return_datatype, "CONST")) || !strcmp(main_datatype, return_datatype)){
		return ;
	}
	else {
		sprintf(errors[sem_errors], "Line %d: Return type mismatch\n", countn+1);
		sem_errors++;
	}
}

int check_types(char *type1, char *type2){

	if(!strcmp(type2, "null"))
		return -1;

	if(!strcmp(type1, type2))
		return 0;

	if((!strcmp(type1, "str") && !strcmp(type2, "char")) || (!strcmp(type2, "str") && !strcmp(type1, "char")) )
		return 3;
	
	if(!strcmp(type1, "str") || !strcmp(type2, "str")){
		sprintf(errors[sem_errors], "Line %d: Mismatching Types in String Arithmetic on types \"%s && %s\"!\n", countn+1, type1, type2);
		sem_errors++;
		return -1;
	}
	
	if(!strcmp(type1, "int") || !strcmp(type1, "float") || !strcmp(type2, "int") || !strcmp(type2, "float")){
		bool isFloat = !strcmp(type1, "float") || !strcmp(type2, "float");
		if(isFloat) return 1;
		bool isInt = !strcmp(type1, "int") || !strcmp(type2, "int");
		return 2;
	}
}

char *get_type(char *var){
	for(int i=0; i<count; i++) {
		// Handle case of use before declaration
		if(!strcmp(symbol_table[i].id_name, var)) {
			return symbol_table[i].data_type;
		}
	}
}

void add(char c) {
	if(c == 'V'){
		for(int i=0; i<10; i++){
			if(!strcmp(reserved[i], strdup(yytext))){
				char buffer[500];
        		sprintf(errors[sem_errors], "Line %d: Variable name \"%s\" is a reserved keyword!\n", countn+1, yytext);
				int j = snprintf(buffer, sizeof buffer , errors[sem_errors], "Line %d: Variable name \"%s\" is a reserved keyword!\n", countn+1, yytext);
				sem_errors++;
				yyerror(buffer);
				return;
			}
		}
	}
    q=search(yytext);
	if(!q) {
		if(c == 'H') {
			symbol_table[count].id_name=strdup(yytext);
			symbol_table[count].data_type=strdup(type);
			symbol_table[count].line_no=countn;
			symbol_table[count].type=strdup("Header");
			count++;
		}
		else if(c == 'K') {
			symbol_table[count].id_name=strdup(yytext);
			symbol_table[count].data_type=strdup("N/A");
			symbol_table[count].line_no=countn;
			symbol_table[count].type=strdup("Keyword\t");
			count++;
		}
		else if(c == 'V') {
			symbol_table[count].id_name=strdup(yytext);
			symbol_table[count].data_type=strdup(type);
			symbol_table[count].line_no=countn;
			symbol_table[count].type=strdup("Variable");
			count++;
		}
		else if(c == 'C') {
			symbol_table[count].id_name=strdup(yytext);
			symbol_table[count].data_type=strdup("CONST");
			symbol_table[count].line_no=countn;
			symbol_table[count].type=strdup("Constant");
			count++;
		}
		else if(c == 'F') {
			symbol_table[count].id_name=strdup(yytext);
			symbol_table[count].data_type=strdup(type);
			symbol_table[count].line_no=countn;
			symbol_table[count].type=strdup("Function");
			count++;
		}
    }
    else if(c == 'V' && q) {
        sprintf(errors[sem_errors], "Line %d: Multiple declarations of \"%s\" not allowed!\n", countn+1, yytext);
		sem_errors++;
    }
}

struct node* mknode(struct node *left, struct node *right, char *token) {	
	struct node *newnode = (struct node *) malloc(sizeof(struct node));
	char *newstr = (char *) malloc(strlen(token)+1);
	strcpy(newstr, token);
	newnode->left = left;
	newnode->right = right;
	newnode->token = newstr;
	return(newnode);
}

void print_tree(struct node* tree) {
	printf("\n\nInorder traversal of the Parse Tree is: \n\n");
	print_inorder(tree);
}

void print_inorder(struct node *tree) {
	int i;
	if (tree->left) {
		print_inorder(tree->left);
	}
	printf("%s, ", tree->token);
	if (tree->right) {
		print_inorder(tree->right);
	}
}

void insert_type() {
	strcpy(type, yytext);
}

void yyerror(const char* msg) {
    fprintf(stderr, "%s\n", msg);
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

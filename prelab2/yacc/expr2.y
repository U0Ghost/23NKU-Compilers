%{
/*********************************************
将所有的词法分析功能均放在 yylex 函数内实现，为 +、-、*、\、(、 ) 每个运算符及整数分别定义一个单词类别，在 yylex 内实现代码，能
识别这些单词，并将单词类别返回给词法分析程序。

中缀转后缀表达式

YACC file
edited by U0Ghost and Tangdary
**********************************************/
#include<stdio.h>
#include<stdlib.h>
#include<ctype.h>
#include<string.h>
#ifndef YYSTYPE
#define YYSTYPE char*
#endif

char numStr[50];
char idStr[50];
int yylex();
extern int yyparse();
FILE* yyin;
void yyerror(const char* s);
%}

//TODO:给每个符号定义一个单词类别
%token ADD
%token MINUS
%token MUL
%token DIV
%token LEFTPAR
%token RIGHTPAR
%token NUMBER
%token UMINUS
%token ID

%left ADD MINUS
%left MUL DIV
%right UMINUS

%%


lines   :       lines expr ';' { printf("%s\n", $2); }
        |       lines ';'
        |
        ;
//TODO:完善表达式的规则
expr    :       expr ADD expr   { 
                                $$ = (char*) malloc (50*sizeof(char));
                                strcpy($$, $1);
                                strcat($$, $3);
                                strcat($$, "+ ");
                                }
        |       expr MINUS expr {
                                $$ = (char*) malloc (50*sizeof(char));
                                strcpy($$, $1);
                                strcat($$, $3);
                                strcat($$, "- ");
                                }
        |       expr MUL expr   {
                                $$ = (char*) malloc (50*sizeof(char));
                                strcpy($$, $1);
                                strcat($$, $3);
                                strcat($$, "* ");
                                }
        |       expr DIV expr   {
                                $$ = (char*) malloc (50*sizeof(char));
                                strcpy($$, $1);
                                strcat($$, $3);
                                strcat($$, "/ ");
                                }
        |       LEFTPAR expr RIGHTPAR {
                                $$ = (char*) malloc (50*sizeof(char));
                                strcpy($$, $2);
                                strcat($$, " ");
                                }
        |       MINUS expr %prec UMINUS   {
                                $$ = (char*) malloc (50*sizeof(char));
                                strcpy($$, "0");
                                strcat($$, $2);
                                strcat($$, "- ");
                                }
        |       NUMBER          {
                                $$ = (char*) malloc (50*sizeof(char));
                                strcpy($$, $1);
                                strcat($$, " ");
                                }
        |       ID              {
                                $$ = (char*) malloc (50*sizeof(char));
                                strcpy($$, $1);
                                strcat($$, " ");
                                }
        ;

%%

// programs section


int yylex()
{
    int ch;
    while(1){
        ch=getchar();
        if(ch==' '||ch=='\t'||ch=='\n')
        {
            //do nothing
        }
        else if(isdigit(ch)){
            //TODO:解析多位数字返回number类型 
            int ti = 0;
            while(isdigit(ch))
            {
                numStr[ti] = ch;
                ch = getchar();
                ti++;
            }
            numStr[ti] = '\0';
            yylval = numStr;
            ungetc(ch, stdin);
            return NUMBER;
        }
        else if (isalpha(ch) || ch == '_'){
            //返回id类型
            int ti = 0;
            while(isalpha(ch) || isdigit(ch) || ch == '_')
            {
                idStr[ti] = ch;
                ch = getchar();
                ti++;
            }
            idStr[ti] = '\0';
            yylval = idStr;
            ungetc(ch, stdin);
            return ID;
        }
        
        else if(ch=='+')
        {
            return ADD;
        }
        else if(ch=='-')
        {
            return MINUS;
        }
        else if (ch == '*')
        {
            return MUL;
        }
        else if (ch == '/')
        {
            return DIV;
        }
        else if (ch == '(')
        {
            return LEFTPAR;
        }
        else if (ch == ')')
        {
            return RIGHTPAR;
        }
        else
        {
            return ch;
        }
    }
}

int main(void)
{
    yyin=stdin;
    do{
        yyparse();
    }while(!feof(yyin));
    return 0;
}
void yyerror(const char* s){
    fprintf(stderr,"Parse error: %s\n",s);
    exit(1);
}
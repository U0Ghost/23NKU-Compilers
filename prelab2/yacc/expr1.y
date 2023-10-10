%{
/*********************************************
将所有的词法分析功能均放在 yylex 函数内实现，为 +、-、*、\、(、 ) 每个运算符及整数分别定义一个单词类别，在 yylex 内实现代码，能
识别这些单词，并将单词类别返回给词法分析程序。
实现功能更强的词法分析程序，可识别并忽略空格、制表符、回车等
空白符，能识别多位十进制整数。
YACC file
edited by U0Ghost and Tangdary
**********************************************/
#include<stdio.h>
#include<stdlib.h>
#include<ctype.h>
#ifndef YYSTYPE
#define YYSTYPE double
#endif

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

%left ADD MINUS
%left MUL DIV
%right UMINUS

%%


lines   :       lines expr ';' { printf("%f\n", $2); }
        |       lines ';'
        |
        ;
//TODO:完善表达式的规则

expr    :   expr ADD expr           {$$ = $1 + $3;}
        |   expr MINUS expr         {$$ = $1 - $3;}
        |   expr MUL expr           {$$ = $1 * $3;}
        |   expr DIV expr           {$$ = $1 / $3;}
        |   LEFTPAR expr RIGHTPAR   {$$ = $2;}
        |   MINUS expr %prec UMINUS {$$ = -$2;}
        |   NUMBER                  {$$ = $1;}
        ;

%%

// programs section


int yylex()
{
    int ch;
    while(1) {
        ch=getchar();
        if(ch==' '||ch=='\t'||ch=='\n')
        {
            //do nothing
        }
        else if(isdigit(ch)){
            //TODO:解析多位数字返回number类型 
            yylval = 0;
            while(isdigit(ch))
            {
                yylval = yylval * 10 + ch - '0';
                ch = getchar();
            }
            ungetc(ch, stdin);
            return NUMBER;
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
    do {
        yyparse();
    } while(!feof(yyin));
    return 0;
}
void yyerror(const char* s){
    fprintf(stderr,"Parse error: %s\n",s);
    exit(1);
}
%{
/*********************************************
将所有的词法分析功能均放在 yylex 函数内实现，为 +、-、*、\、(、 ) 每个运算符及整数分别定义一个单词类别，在 yylex 内实现代码，能
识别这些单词，并将单词类别返回给词法分析程序。
实现功能更强的词法分析程序，可识别并忽略空格、制表符、回车等
空白符，能识别多位十进制整数。
试图识别变量构建符号表。
YACC file
edited by U0Ghost and Tangdary
**********************************************/
#include<stdio.h>
#include<stdlib.h>
#include<ctype.h>
#ifndef YYSTYPE
#define YYSTYPE double
#endif

struct SymbolEntry {
    char name[256];  // 假设变量名不超过 255 个字符
    double value;
    struct SymbolEntry* next;
};

typedef struct SymbolEntry SymbolEntry;

SymbolEntry* symbolTable = NULL;  // 符号表的头指针

// 添加变量到符号表
void addToSymbolTable(const char* name, double value) {
    SymbolEntry* entry = (SymbolEntry*)malloc(sizeof(SymbolEntry));
    strcpy(entry->name, name);
    entry->value = value;
    entry->next = symbolTable;
    symbolTable = entry;
}

// 在符号表中查找变量
double lookupSymbol(const char* name) {
    SymbolEntry* entry = symbolTable;
    while (entry != NULL) {
        if (strcmp(entry->name, name) == 0) {
            return entry->value;
        }
        entry = entry->next;
    }
    return 0.0;  // 如果变量未找到，默认返回0.0
}

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
%token ID // 添加标识符类型

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
        |   ID                      {$$ = lookupSymbol($1);}  // 使用变量的值
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
        else if (isalpha(ch)) {
            // 识别标识符并返回ID类型
            char buffer[256];
            int i = 0;
            buffer[i++] = ch;
            while ((ch = getchar()) && (isalnum(ch) || ch == '_')) {
                buffer[i++] = ch;
            }
            buffer[i] = '\0';
            ungetc(ch, stdin);
            yylval = strdup(buffer);  // 保存标识符名称
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
    do {
        yyparse();
    } while(!feof(yyin));
    return 0;
}
void yyerror(const char* s){
    fprintf(stderr,"Parse error: %s\n",s);
    exit(1);
}
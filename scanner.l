/* Definition section */
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define YY_NO_UNPUT
#define YY_NO_INPUT
#define print_token(token) \
    printf("%-8s \t %s\n", strcmp(token, "NEWLINE")? yytext: "", token)

int line_num = 1;
int comment_num = 0;
int comment_flag = 0;
int comment_has_newline = 0;
%}

/* Declare state for multi-line comments */
%x COMMENT

%%

\"[^\n\"]*\" {
    int len = yyleng;

    printf("%-8s \t %s\n", "\"", "QUOTA");

    if (len > 2) {
        char buffer[1024];
        strncpy(buffer, yytext + 1, len - 2);
        buffer[len - 2] = '\0';
        printf("%-8s \t STRING_LIT\n", buffer);
    }

    printf("%-8s \t %s\n", "\"", "QUOTA");
}

"//"[^\n]* {
    comment_flag = 1;
    printf("%-8s \t COMMENT\n", yytext);
}

"/*" {
    BEGIN(COMMENT);
    comment_flag = 1;
    comment_has_newline = 0;
    yymore();
}

<COMMENT>{
    \n { 
        line_num++; 
        comment_num++; 
        comment_has_newline = 1; /* 標記這個註解已有換行 */
        yymore(); 
    }
    "*/" {
        /*yymore();*/
        BEGIN(INITIAL);

        /* 如果從來沒碰到過換行，就把這整塊算作一行 */
        if (!comment_has_newline) {
            comment_num++;
        }

        char *p = yytext;
        if (*p == '\n') ++p;
        while (*p == ' ' || *p == '\t') ++p;

        printf("%s", p);
        printf("       \t MUTI_LINE_COMMENT\n");
    }
    .  { yymore(); }
    
}

"\n"            {
    line_num++;
    if (comment_flag) {
        comment_num++;
        comment_flag = 0;
    }
    print_token("NEWLINE");
}

"&&"            { print_token("LAND"); }
"||"            { print_token("LOR"); }
"=="            { print_token("EQL"); }
"!="            { print_token("NEQ"); }
">="            { print_token("GEQ"); }
"<="            { print_token("LEQ"); }
"+="            { print_token("ADD_ASSIGN"); }
"-="            { print_token("SUB_ASSIGN"); }
"*="            { print_token("MUL_ASSIGN"); }
"/="            { print_token("QUO_ASSIGN"); }
"%="            { print_token("REM_ASSIGN"); }
"->"            { print_token("ARROW"); }
"<<"            { print_token("LSHIFT"); }
">>"            { print_token("RSHIFT"); }
".."            { print_token("DOTDOT"); }

"+"             { print_token("ADD"); }
"-"             { print_token("SUB"); }
"*"             { print_token("MUL"); }
"/"             { print_token("QUO"); }
"%"             { print_token("REM"); }
">"             { print_token("GTR"); }
"<"             { print_token("LSS"); }
"="             { print_token("ASSIGN"); }
"&"             { print_token("BAND"); }
"|"             { print_token("BOR"); }
"~"             { print_token("BNOT"); }
"!"             { print_token("NOT"); }

"("             { print_token("LPAREN"); }
")"             { print_token("RPAREN"); }
"["             { print_token("LBRACK"); }
"]"             { print_token("RBRACK"); }
"{"             { print_token("LBRACE"); }
"}"             { print_token("RBRACE"); }
";"             { print_token("SEMICOLON"); }
","             { print_token("COMMA"); }
":"             { print_token("COLON"); }

"print"         { print_token("PRINT"); }
"println"       { print_token("PRINTLN"); }
"if"            { print_token("IF"); }
"else"          { print_token("ELSE"); }
"for"           { print_token("FOR"); }
"i32"           { print_token("INT"); }
"f32"           { print_token("FLOAT"); }
"bool"          { print_token("BOOL"); }
"true"          { print_token("TRUE"); }
"false"         { print_token("FALSE"); }
"let"           { print_token("LET"); }
"mut"           { print_token("MUT"); }
"fn"            { print_token("FUNC"); }
"return"        { print_token("RETURN"); }
"break"         { print_token("BREAK"); }
"as"            { print_token("AS"); }
"in"            { print_token("IN"); }
"while"         { print_token("WHILE"); }
"loop"          { print_token("LOOP"); }

[0-9]+\.[0-9]+    { print_token("FLOAT_LIT"); }
[0-9]+            { print_token("INT_LIT"); }

[a-zA-Z_][a-zA-Z0-9_]*   { print_token("IDENT"); }

[ \t]+                 { ; }
.                      { ; }
<<EOF>>                { yyterminate(); }

%%

int yywrap(void) {
   return 1;
}

int main(int argc, char *argv[]) {
   if (argc == 2) {
       yyin = fopen(argv[1], "r");
   } else {
       yyin = stdin;
   }
   yylex();
   printf("\nFinish scanning,\n");
   printf("total line: %d\n", line_num);
   printf("comment line: %d\n", comment_num);
   fclose(yyin);
   return 0;
}
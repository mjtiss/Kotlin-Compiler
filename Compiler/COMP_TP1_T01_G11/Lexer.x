{
    module Lexer where
}

%wrapper "basic"

$digit = [0-9]
$alpha = [a-zA-Z_]

-- A ordem é importante!!!!! (trial and error)
token :- 
    $white+                        ;    -- Espacos
    "//".*                         ;    -- Comentarios linha unica
    "/*" ( . )* "*/"               ;    -- Comentarios multi linha
    "var"             { \_ -> VAR }     -- Variavel
    "val"             { \_ -> VAL }     -- Variavel
    "if"              { \_ -> IF }      -- Keyword if
    "else"            { \_ -> ELSE }    -- Keyword else
    "print"           { \_ -> PRINT }   -- Keyword print
    "readln"          { \_ -> READLN }    -- Keyword readln
    "true"            { \_ -> TRUE }    -- Keyword true
    "false"           { \_ -> FALSE }   -- Keyword false
    "while"           { \_ -> WHILE }   -- Keyword while
    "fun"             { \_ -> FUN }     -- Keyword fun
    "main"            { \_ -> MAIN }    -- Keyword main
    "("               { \_ -> LPAREN } 
    ")"               { \_ -> RPAREN } 
    "+"               { \_ -> PLUS } 
    "-"               { \_ -> MINUS } 
    "*"               { \_ -> TIMES } 
    "/"               { \_ -> DIVIDE } 
    "=="              { \_ -> EQUAL }    -- Igualdade
    "<"               { \_ -> LESSER }    -- Menor que
    "<="              { \_ -> LESSEREQ}     -- Menor ou igual que     
    ">"               { \_ -> GREATER }    -- Maior que
    ">="              { \_ -> GREATEREQ}    -- Maior ou igual que 
    "&&"              { \_ -> AND } 
    "++"              { \_ -> INCR }
    "--"              { \_ -> DECR } 
    "||"              { \_ -> OR } 
    "!"               { \_ -> NOT } 
    "{"               { \_ -> LBRACE }   -- Abertura de bloco
    "}"               { \_ -> RBRACE }   -- Fechamento de bloco
    ";"               { \_ -> SEMICOLON } -- Fim de comando
    "="               { \_ -> ASSIGN }   -- Atribuicao de variavel
    --\"[^\"]*\"        { \s -> STRING  (init(tail s))} -- 
    $alpha+           { \s -> ID s }    -- Identificadores
    $digit+           { \s -> NUM (read s :: Int) } -- Numeros
    $digit+ "\." $digit* { \s -> FLOAT (read s :: Float) } -- Numeros Floating Point
    .                 { \s -> InvalidToken }  -- Caracteres invalidos

{
data Token
    = ID String
    | NUM Int
    | FLOAT Float
    | LPAREN
    | RPAREN
    | PLUS
    | MINUS
    | TIMES
    | DIVIDE
    | EQUAL        
    | LESSER
    | LESSEREQ       
    | GREATER 
    | GREATEREQ        
    | AND
    | OR
    | NOT
    | LBRACE     
    | RBRACE     
    | SEMICOLON  
    | PRINT
    | READLN
    | TRUE
    | FALSE
    | IF
    | ELSE
    | WHILE
    | FUN        -- fun keyword for functions
    | MAIN       -- main function
    | VAL        -- immutable val declaration
    | VAR        -- mutable var declaration
    | ASSIGN     -- =  
    | INCR         
    | DECR                 
    | InvalidToken
    deriving (Eq, Show)

}
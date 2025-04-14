{
-- Analisador sintático para Kotlin
module Parser where
import Lexer
import AST -- Estruturas de Dados
}



%name parse
%tokentype { Token }
%error { parseError }

%right ASSIGN                   -- Assignment has the lowest precedence
%nonassoc EQUAL LESSER GREATER  -- Non-associative for comparisons
%left OR                        -- Logical OR
%left AND                       -- Logical AND
%right NOT                      -- Logical NOT
%left PLUS MINUS                -- Addition and subtraction
%left TIMES DIVIDE              -- Multiplication and division

%token
  FUN       { FUN }
  MAIN      { MAIN }
  LPAREN    { LPAREN }
  RPAREN    { RPAREN }
  LBRACE    { LBRACE }
  RBRACE    { RBRACE }
  PLUS      { PLUS }
  MINUS     { MINUS }
  TIMES     { TIMES }
  DIVIDE    { DIVIDE }
  EQUAL     { EQUAL }
  LESSER    { LESSER }
  LESSEREQ  { LESSEREQ }
  GREATER   { GREATER }
  GREATEREQ { GREATEREQ }
  TRUE      { TRUE }
  FALSE     { FALSE }
  NOT       { NOT }
  AND       { AND }
  OR        { OR }
  VAL       { VAL }
  VAR       { VAR }
  ASSIGN    { ASSIGN }
  IF        { IF }
  ELSE      { ELSE }
  WHILE     { WHILE }
  PRINT     { PRINT }
  READLN    { READLN }
  INCR      { INCR }
  DECR      { DECR }
  ID        { ID $$ }
  NUM       { NUM $$ }

%%
-- ---------------------- Início da gramática ------------------------------

-- Regra inicial kotlin
Program : FUN MAIN LPAREN RPAREN Block                   { Program $5 }

-- Bloco de statements (conteúdo do programa)
Block : LBRACE StmtList RBRACE                           { $2 }

-- Lista de Statements (pode ter vários statements)
StmtList : Stmt StmtList                              { $1 : $2 }
         |                                            { [] }

-- ---------------------- Comandos ------------------------------

-- Separar comandos por produções distintas
Stmt : Declaration                                    { $1 }
     | Assignment                                     { $1 }
     | PrintStmt                                      { $1 }
     | IfStmt                                         { $1 }
     | WhileStmt                                      { $1 }
     | Exp                                            { ExprStmt $1 }  -- Allow expressions as standalone statements

-- Declarar Val e Var
Declaration : VAL ID ASSIGN Exp                          { ValDecl $2 $4 }
            | VAR ID ASSIGN Exp                          { VarDecl $2 $4 }

-- Atribuição
Assignment : ID ASSIGN Exp { Assign $1 $3 }
           | ID INCR { Incr $1 }
           | ID DECR { Decr $1 }


-- Print
PrintStmt : PRINT LPAREN Exp RPAREN                      { Print $3 }

-- Readln
--ReadStmt : READLN LPAREN RPAREN                         { ReadLn }

-- Estruturas de controle condicionais (if-then-else)
IfStmt : IF LPAREN Exp RPAREN Block              { If $3 $5 }
       | IF LPAREN Exp RPAREN Block ELSE Block   { IfElse $3 $5 $7 }

-- While (condition) { novo bloco de statements }
WhileStmt : WHILE LPAREN Exp RPAREN Block        { While $3 $5 }

-- ---------------------- Expressões ------------------------------

-- Separar entre operadores aritméticos e booleanos
Exp  : NUM                          { Num $1 }
     | ID                           { Var $1 }
     | Exp PLUS Exp               { Add $1 $3 }
     | Exp MINUS Exp              { Sub $1 $3 }
     | Exp TIMES Exp              { Mul $1 $3 }
     | Exp DIVIDE Exp             { Div $1 $3 }
     | Exp EQUAL Exp              { Equal $1 $3 }
     | Exp LESSER Exp             { Less $1 $3 }
     | Exp LESSEREQ Exp           { LessEq $1 $3 }
     | Exp GREATER Exp            { Greater $1 $3 }
     | Exp GREATEREQ Exp          { GreaterEq $1 $3 }
     | Exp OR Exp                 { Or $1 $3 }
     | Exp AND Exp                { And $1 $3 }
     | NOT Exp                     { Not $2 }
     | TRUE                         { BoolConst True }
     | FALSE                        { BoolConst False }
     | LPAREN Exp RPAREN           { Parens $2 }
     | READLN LPAREN RPAREN         { ReadLn }  -- Poder dar assign a um ReadLn
     | IF LPAREN Exp RPAREN Block ELSE Block { IfElseExpr $3 $5 $7 } -- Poder dar assign ao valor de uma condição if.
     | IF LPAREN Exp RPAREN Block           { IfExpr $3 $5 }


{

-- Função de erro para debug
parseError :: [Token] -> a
parseError toks = case toks of
    [] -> error "parseError: Unexpected end of input"
    (t:rest) -> error $ "parseError: Unexpected token " ++ show t ++ "\n" ++
                        "Remaining tokens: " ++ show (take 5 rest) ++ "\n" ++
                        "Context: Parsing failed around " ++ show t
}

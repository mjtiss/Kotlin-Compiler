-- Common.hs
module Common where

type Temp = String
type Label = String

-- Operações binárias
data BinOp = Plus | Minus | Mult | Divide | Lt | Lteq | Gt | Gteq | Eq | Not | And | Or
  deriving (Show, Eq)

--Estrutura de dados do Código intermédio
data Instr
  = MOVE Temp Temp                -- temp1 := temp2
  | MOVEI Temp Int                -- temp1 := num
  | OP BinOp Temp Temp Temp       -- temp1 := temp2 op temp3
  | OPI BinOp Temp Temp Int       -- temp1 := temp2 op num
  | LABEL Label                   -- Label para flow control
  | JUMP Label                    -- Jump Incondicional
  | COND Temp BinOp Temp Label Label -- Jump Condicional: if temp1 op temp2 then goto L1 else goto L2)
  | PRINT Temp -- Print temporários
  | READLN Temp -- Read Line
  | WHILE BinOp String Label Label 
  deriving (Show, Eq)
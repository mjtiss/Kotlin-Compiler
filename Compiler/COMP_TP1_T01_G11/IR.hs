module IR where


import Common
import AST
import SymbolTable

import Data.Map as Map
import Debug.Trace

-- Contador de temporários
type Supply = (Int, Int)

-- Gerar uma nova variável temporária
newTemp :: Supply -> (Temp, Supply)
newTemp (temps, labels) = ("$t" ++ show temps, (temps + 1, labels))

-- Gerar uma nova label
newLabel :: Supply -> (Label, Supply)
newLabel (temps, labels) = ("L" ++ show labels, (temps, labels + 1))





-- Traduzir Bloco
transBlock :: Block -> SymbolTable -> Supply -> ([Instr], Supply)
transBlock [] _ supply = ([], supply)
transBlock (cmd:cmds) table supply =
  let (code1, supply1) = transStmt cmd table supply
      (code2, supply2) = transBlock cmds table supply1
  in (code1 ++ code2, supply2)


-- Traduzir Statements
transStmt :: Command -> SymbolTable -> Supply -> ([Instr], Supply)
-- Assign
transStmt (Assign name expr) table supply =
  case Map.lookup name table of
    Just symbol ->
      let dest = symbolName symbol
          (codeExpr, supply1) = transExpr expr table dest supply
      in (codeExpr, supply1)
    Nothing -> error $ "Variable " ++ name ++ " not found in SymbolTable"


-- Var
transStmt (VarDecl name expr) table supply =
  case Map.lookup name table of
    Just symbol ->
      let temp = symbolName symbol
          (code, supply') = transExpr expr table temp supply
      in (code, supply')
    Nothing -> error $ "Variable " ++ name ++ " not found in SymbolTable"
-- Val
transStmt (ValDecl name expr) table supply =
  case Map.lookup name table of
    Just symbol ->
      let temp = symbolName symbol
          (code, supply') = transExpr expr table temp supply
      in (code, supply')
    Nothing -> error $ "Value " ++ name ++ " not found in SymbolTable"
-- Print
transStmt (Print expr) table supply =
  let (temp, supply1) = newTemp supply
      (code, supply2) = transExpr expr table temp supply1
  in (code ++ [PRINT temp], supply2)
-- If
transStmt (If cond block) table supply =
  let (labelTrue, supply1) = newLabel supply
      (labelEnd, supply2) = newLabel supply1
      (condCode, supply3) = transExpr cond table "$t0" supply2
      (blockCode, supply4) = transBlock block table supply3
      code = condCode ++
             [COND "t0" Eq "1" labelTrue labelEnd] 
             ++ [LABEL labelTrue]
             ++ blockCode
             ++ [LABEL labelEnd]
  in (code, supply4)

transStmt (ExprStmt expr) table supply =
  case expr of
    IfElseExpr cond trueBranch falseBranch ->
      -- Translate as IfElse
      transStmt (IfElse cond trueBranch falseBranch) table supply
    _ ->
      error $ "Unsupported expression statement: " ++ show expr


transStmt (IfElse cond blockTrue blockFalse) table supply =
  let (labelTrue, supply1) = newLabel supply
      (labelFalse, supply2) = newLabel supply1
      (labelEnd, supply3) = newLabel supply2
      (condCode, supply4) = transExpr cond table "$t0" supply3
      (trueCode, supply5) = transBlock blockTrue table supply4
      (falseCode, supply6) = transBlock blockFalse table supply5
      code = condCode ++ [COND "$t0" Eq "1" labelTrue labelFalse]
             ++ [LABEL labelTrue] ++ trueCode ++ [JUMP labelEnd]
             ++ [LABEL labelFalse] ++ falseCode ++ [LABEL labelEnd]
  in (code, supply6)

-- While
transStmt (While cond body) table supply =
  let (labelStart, supply1) = newLabel supply
      (labelEnd, supply2) = newLabel supply1
      (condCode, supply3) = transExpr cond table "$t0" supply2
      (bodyCode, supply4) = transBlock body table supply3
      code = [LABEL labelStart]
             ++ condCode
             ++ [COND "$t0" Eq "1" labelEnd labelStart]
             ++ bodyCode
             ++ [JUMP labelStart, LABEL labelEnd]
  in (code, supply4)

transStmt (Incr varName) table supply =
  let (temp, supply1) = newTemp supply
      (tempInc, supply2) = newTemp supply1
      loadCode = [MOVE temp varName]
      incCode = [MOVEI tempInc 1, OP Plus temp temp tempInc]
      storeCode = [MOVE varName temp]
  in (loadCode ++ incCode ++ storeCode, supply2)

transStmt (Decr varName) table supply =
  let (temp, supply1) = newTemp supply
      (tempInc, supply2) = newTemp supply1
      loadCode = [MOVE temp varName]
      incCode = [MOVEI tempInc 1, OP Minus temp temp tempInc]
      storeCode = [MOVE varName temp]
  in (loadCode ++ incCode ++ storeCode, supply2)

-- Statements fora de formato
transStmt cmd _ _ = error $ "Unsupported statement: " ++ show cmd




-- Traduzir Expressões
transExpr :: Expr -> SymbolTable -> Temp -> Supply -> ([Instr], Supply)
-- Numeros literais
transExpr (Num n) _ dest supply =
  ([MOVEI dest n], supply) -- dest := n
  
-- Var Lookup
transExpr (Var name) table dest supply =
  case Map.lookup name table of
    Just symbol ->
      let src = symbolName symbol
      in ([MOVE dest src], supply)
    Nothing -> error $ "Variable " ++ name ++ " not found in SymbolTable"

-- Adição
transExpr (Add e1 e2) table dest supply0 =
  let (temp1, supply1) = newTemp supply0
      (temp2, supply2) = newTemp supply1
      (code1, supply3) = transExpr e1 table temp1 supply2
      (code2, supply4) = transExpr e2 table temp2 supply3
      tempCode = [OP Plus dest temp1 temp2]
  in (code1 ++ code2 ++ tempCode, supply4)

-- Subtração
transExpr (Sub e1 e2) table dest supply0 =
  let (temp1, supply1) = newTemp supply0
      (temp2, supply2) = newTemp supply1
      (code1, supply3) = transExpr e1 table temp1 supply2
      (code2, supply4) = transExpr e2 table temp2 supply3
      tempCode = [OP Minus dest temp1 temp2]
  in (code1 ++ code2 ++ tempCode, supply4)

-- Multiplicação
transExpr (Mul e1 e2) table dest supply0 =
  let (temp1, supply1) = newTemp supply0
      (temp2, supply2) = newTemp supply1
      (code1, supply3) = transExpr e1 table temp1 supply2
      (code2, supply4) = transExpr e2 table temp2 supply3
      tempCode = [OP Mult dest temp1 temp2]
  in (code1 ++ code2 ++ tempCode, supply4)

-- Divisão
transExpr (Div e1 e2) table dest supply0 =
  let (temp1, supply1) = newTemp supply0
      (temp2, supply2) = newTemp supply1
      (code1, supply3) = transExpr e1 table temp1 supply2
      (code2, supply4) = transExpr e2 table temp2 supply3
  in (code1 ++ code2 ++ [OP Divide dest temp1 temp2], supply4)

-- Booleanos
-- < Menor
transExpr (Less lhs rhs) table dest supply =
  let (tempLhs, supply1) = newTemp supply
      (tempRhs, supply2) = newTemp supply1
      (tempResult, supply3) = newTemp supply2
      (codeLhs, supply4) = transExpr lhs table tempLhs supply3
      (codeRhs, supply5) = transExpr rhs table tempRhs supply4
      condCode = [COND tempLhs Lt tempRhs tempResult tempResult]
      moveCode = [MOVE dest tempResult]
  in (codeLhs ++ codeRhs ++ condCode ++ moveCode, supply5)

-- > Maior
transExpr (Greater lhs rhs) table dest supply =
  let (tempLhs, supply1) = newTemp supply
      (tempRhs, supply2) = newTemp supply1
      (tempResult, supply3) = newTemp supply2
      (codeLhs, supply4) = transExpr lhs table tempLhs supply3
      (codeRhs, supply5) = transExpr rhs table tempRhs supply4
      condCode = [COND tempLhs Gt tempRhs tempResult tempResult]
      moveCode = [MOVE dest tempResult]
  in (codeLhs ++ codeRhs ++ condCode ++ moveCode, supply5)

-- = Igual
transExpr (Equal lhs rhs) table dest supply =
  let (tempLhs, supply1) = newTemp supply
      (tempRhs, supply2) = newTemp supply1
      (tempResult, supply3) = newTemp supply2
      (codeLhs, supply4) = transExpr lhs table tempLhs supply3
      (codeRhs, supply5) = transExpr rhs table tempRhs supply4
      condCode = [COND tempLhs Eq tempRhs tempResult tempResult]
      moveCode = [MOVE dest tempResult]
  in (codeLhs ++ codeRhs ++ condCode ++ moveCode, supply5)

-- <= Menor igual
transExpr (LessEq lhs rhs) table dest supply =
  let (tempLhs, supply1) = newTemp supply
      (tempRhs, supply2) = newTemp supply1
      (tempResult, supply3) = newTemp supply2
      (codeLhs, supply4) = transExpr lhs table tempLhs supply3
      (codeRhs, supply5) = transExpr rhs table tempRhs supply4
      condCode = [COND tempLhs Lteq tempRhs tempResult tempResult]
      moveCode = [MOVE dest tempResult]
  in (codeLhs ++ codeRhs ++ condCode ++ moveCode, supply5)

-- >= Maior igual
transExpr (GreaterEq lhs rhs) table dest supply =
  let (tempLhs, supply1) = newTemp supply
      (tempRhs, supply2) = newTemp supply1
      (tempResult, supply3) = newTemp supply2
      (codeLhs, supply4) = transExpr lhs table tempLhs supply3
      (codeRhs, supply5) = transExpr rhs table tempRhs supply4
      condCode = [COND tempLhs Gteq tempRhs tempResult tempResult]
      moveCode = [MOVE dest tempResult]
  in (codeLhs ++ codeRhs ++ condCode ++ moveCode, supply5)

-- Constantes
transExpr (BoolConst True) _ dest supply =
  let (tempResult, supply1) = newTemp supply
  in ([MOVEI tempResult 1, MOVE dest tempResult], supply1)

transExpr (BoolConst False) _ dest supply =
  let (tempResult, supply1) = newTemp supply
  in ([MOVEI tempResult 0, MOVE dest tempResult], supply1)

-- && AND
transExpr (AST.And e1 e2) table dest supply =
  let (temp1, supply1) = newTemp supply
      (temp2, supply2) = newTemp supply1
      (tempResult, supply3) = newTemp supply2
      (code1, supply4) = transExpr e1 table temp1 supply3
      (code2, supply5) = transExpr e2 table temp2 supply4
      code = code1 ++ code2 ++
             [OP Common.And tempResult temp1 temp2, MOVE dest tempResult]
  in (code, supply5)
-- \\ OR
transExpr (AST.Or e1 e2) table dest supply =
  let (temp1, supply1) = newTemp supply
      (temp2, supply2) = newTemp supply1
      (tempResult, supply3) = newTemp supply2
      (code1, supply4) = transExpr e1 table temp1 supply3
      (code2, supply5) = transExpr e2 table temp2 supply4
      code = code1 ++ code2 ++
             [OP Common.Or tempResult temp1 temp2, MOVE dest tempResult]
  in (code, supply5)

-- ! NOT
transExpr (AST.Not e) table dest supply =
  let (temp, supply1) = newTemp supply
      (tempUnused, supply2) = newTemp supply1
      (tempResult, supply3) = newTemp supply2
      (code, supply4) = transExpr e table temp supply3
      notCode = [OP Common.Not tempResult temp tempUnused, MOVE dest tempResult]
  in (code ++ notCode, supply4)
transExpr (Parens expr) table dest supply = transExpr expr table dest supply

transExpr AST.ReadLn table dest supply =
  let readCode = [READLN dest]
  in (readCode, supply)

-- Fora de formato
transExpr expr _ _ _ = error $ "Unsupported expression: " ++ show expr


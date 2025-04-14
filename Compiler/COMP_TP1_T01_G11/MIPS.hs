module MIPS where

import IR
import Common
import Data.List (intercalate, isPrefixOf)



translateIRToMIPS :: [Instr] -> [String]
translateIRToMIPS irCode = 
    let variables = collectVariables irCode
        dataSection = generateDataSection variables
        textSection = [".text", "main:"] ++ concatMap translateLine irCode
    in dataSection ++ textSection

collectVariables :: [Instr] -> [String]
collectVariables [] = []
collectVariables (MOVE dest _ : rest)
  | not (isTemp dest) = dest : collectVariables rest
  | otherwise = collectVariables rest
collectVariables (MOVEI dest _ : rest)
  | not (isTemp dest) = dest : collectVariables rest
  | otherwise = collectVariables rest
collectVariables (OP _ dest _ _ : rest)
  | not (isTemp dest) = dest : collectVariables rest
  | otherwise = collectVariables rest
collectVariables (_ : rest) = collectVariables rest

isTemp :: String -> Bool
isTemp var = head var == '$'

generateDataSection :: [String] -> [String]
generateDataSection vars = [".data"] ++ map (\var -> var ++ ": .word 0") vars


translateLine :: Instr -> [String]
translateLine (MOVEI dest value) = ["li " ++ reg dest ++ ", " ++ show value]
translateLine (MOVE dest src) = ["move " ++ reg dest ++ ", " ++ reg src]
translateLine (OP op dest src1 src2) = 
    if op `elem` [And, Or, Not]
    then
        case op of
            Not  -> ["beq " ++ reg src1 ++ ", $zero, " ++ src1,
                        "j " ++ src2]
            And  -> ["beq " ++ reg src1 ++ ", $zero, " ++ src2,
                        "beq " ++ reg src2 ++ ", $zero, " ++ src2,
                        "j " ++ src1]
            Or   -> ["bne " ++ reg src1 ++ ", $zero, " ++ src1,
                        "bne " ++ reg src2 ++ ", $zero, " ++ src1,
                        "j " ++ src2]
    else
    let opcode = case op of
            Plus -> "add"
            Minus -> "sub"
            Mult -> "mul"
            Divide -> "div"
            _ -> error "Unsupported operation:"
    in ["lw $t0, " ++ reg src1,
        "lw $t1, " ++ reg src2,
        opcode ++ " " ++ reg dest ++ ", $t0, $t1"]
translateLine (COND src1 cond src2 labelTrue labelFalse) = case cond of
    Lt   -> ["slt $t8, " ++ reg src1 ++ ", " ++ reg src2,
                "bne $t8, $zero, " ++ labelTrue,
                "j " ++ labelFalse]
    Lteq-> ["slt $t8, " ++ reg src2 ++ ", " ++ reg src1,
                "beq $t8, $zero, " ++ labelTrue,
                "j " ++ labelFalse]
    Gt   -> ["slt $t8, " ++ reg src2 ++ ", " ++ reg src1,
                "bne $t8, $zero, " ++ labelTrue,
                "j " ++ labelFalse]
    Gteq -> ["slt $t8, " ++ reg src1 ++ ", " ++ reg src2,
                "beq $t8, $zero, " ++ labelTrue,
                "j " ++ labelFalse]
    Eq   -> ["beq " ++ reg src1 ++ ", " ++ reg src2 ++ ", " ++ labelTrue,
                "j " ++ labelFalse]
    _       -> error $ "Unsupported condition: "
translateLine (PRINT src) = ["move $a0, " ++ reg src,
                             "li $v0, 1",
                             "syscall"]
translateLine (READLN dest) = [
    "li $v0, 5",             
    "syscall",               
    "move " ++ reg dest ++ ", $v0"
  ]
translateLine (JUMP label) = ["j " ++ label]
translateLine (LABEL label) = [label ++ ":"]


reg :: String -> String
reg name
  | name == "$zero" = "$zero"
  | otherwise = name
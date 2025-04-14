module TAC where
import Common
import Data.Map as Map

printTAC :: [Instr] -> IO ()
printTAC = mapM_ printInstr

printInstr :: Instr -> IO ()
printInstr (MOVE dest src) = putStrLn $ dest ++ " := " ++ src
printInstr (MOVEI dest value) = putStrLn $ dest ++ " := " ++ show value
printInstr (OP op dest src1 src2) = putStrLn $ dest ++ " := " ++ src1 ++ " " ++ show op ++ " " ++ src2
printInstr (PRINT src) = putStrLn $ "print " ++ src
printInstr (LABEL lbl) = putStrLn $ lbl ++ ":"
printInstr (COND src1 cond src2 lbl1 lbl2) =
    putStrLn $ "if " ++ src1 ++ " " ++ show cond ++ " " ++ src2 ++
               " goto " ++ lbl1 ++ " else goto " ++ lbl2
printInstr (JUMP lbl) = putStrLn $ "goto " ++ lbl
printInstr (READLN dest) = putStrLn $ "read " ++ dest
printInstr _ = putStrLn "Incompatible IR code"
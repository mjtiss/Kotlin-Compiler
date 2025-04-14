module Main where

import Lexer
import Parser
import AST
import SymbolTable
import System.Environment (getArgs)
import System.IO (readFile)
import IR
import TAC
import MIPS

-- Lista de inputs sem strings
inputFiles :: [String]
inputFiles = ["arithmetic.txt", "assign.txt", "condition.txt", "boolean.txt", "readln.txt", "while.txt", "complex.txt"]

main :: IO ()
main = do
  -- Caminho para a pasta de inputs
  mapM_ (processFile . ("inputs/" ++)) inputFiles

-- Processar e dar parse ao conteudo dos inputs
processFile :: String -> IO ()
processFile fileName = do
  putStrLn $ "\nProcessing " ++ fileName ++ ":\n"
  
  -- Ler inputs
  content <- readFile fileName
  
  -- Lexer
  let tokens = alexScanTokens content
  putStrLn "Tokens:"
  print tokens  -- Imprimir tokens

  -- Parser
  let ast = parse tokens
  putStrLn "\nParsed Result:"
  putStrLn "\n--------------------------\n"
  print ast -- Imprimir programa Parsed
  putStrLn "\n--------------------------\n"
  
  -- Construção da tabela de símbolos
  let symbolTable = buildTable ast
  putStrLn "\nSymbol Table:"
  print symbolTable

  
  -- Geração de código intermédio
  let Program block = ast
  let initialSupply = (0, 1)
  let (irCode, _) = transBlock block symbolTable initialSupply
  putStrLn "\nIntermediate Representation (IR):"
  mapM_ print irCode

  -- Geração código TAC (Three-Address-Code)
  let Program block = ast
  let initialSupply = (0, 1)
  putStrLn "\nThree-Address Code (TAC):"
  let (tac, _) = transBlock block symbolTable initialSupply
  printTAC tac

  -- Tradução para MIPS
  let mipsCode = translateIRToMIPS irCode
  putStrLn "\nMIPS Assembly:"
  mapM_ putStrLn mipsCode

  writeMIPS "output.asm" mipsCode


-- Escrever o output num ficheiro
writeMIPS :: FilePath -> [String] -> IO ()
writeMIPS filePath mipsCode = do
  writeFile filePath (unlines mipsCode)
  putStrLn $ "MIPS code written to " ++ filePath





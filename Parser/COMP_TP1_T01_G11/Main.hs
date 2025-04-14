module Main where

import Lexer
import Parser
import AST
import System.Environment (getArgs)
import System.IO (readFile)

-- Lista de inputs sem strings
inputFiles :: [String]
inputFiles = ["arithmetic.txt", "assign.txt", "condition.txt", "boolean.txt", "readln.txt", "while.txt", "complex.txt"]

main :: IO ()
main = do
  -- Caminho para a pasta de inputs
  mapM_ (processFile . ("inputs/" ++)) inputFiles

-- Processar e dar parse ao conteudo dos inputs
processFile :: String -> IO ()
processFile filename = do
  putStrLn $ "\nProcessing " ++ filename ++ ":\n"
  
  -- Ler inputs
  content <- readFile filename
  
  -- Lexer
  let tokens = alexScanTokens content
  putStrLn "Tokens:"
  print tokens  -- Imprimir tokens


  -- Parser
  let parseResult = parse tokens
  putStrLn "\nParsed Result:"
  putStrLn "\n--------------------------\n"
  print parseResult -- Imprimir programa Parsed
  putStrLn "\n--------------------------\n"


module SymbolTable
  ( SymbolTable
  , Symbol(..)
  , symbolName
  , buildTable
  , printSymbolTable
  , removeScope
  , insertSymbol
  , lookupSymbol
  , updateSymbol
  ) where

import AST
import Common (Temp, Label)
import Data.Map as Map


data Symbol = Symbol
    { symbol :: String  -- Antes do ID (Int, Bool, ...)
    , name :: String -- Nome da variável
    , scope :: Int -- Nivel do código para saber a qual bloco pertence
    } deriving (Show, Eq)

symbolName :: Symbol -> Temp
symbolName (Symbol _ name _) = name


type SymbolTable = Map.Map String Symbol

buildTable :: Program -> SymbolTable -- AST -> SymbolTable
buildTable (Program block) = processBlock block Map.empty 0
    where
        -- Processar um bloco de comandos
        processBlock :: Block -> SymbolTable -> Int -> SymbolTable
        processBlock [] table _ = table
        processBlock (cmd:cmds) table level =
            let table' = processCommand cmd table level
            in processBlock cmds table' level

        -- Processar comandos individuais
        processCommand :: Command -> SymbolTable -> Int -> SymbolTable
        processCommand (VarDecl name expr) table level =
            Map.insert name (Symbol "Var" name level) table
        processCommand (ValDecl name expr) table level =
            Map.insert name (Symbol "Val" name level) table
        processCommand (Assign name expr) table level =
            case Map.lookup name table of
                Just symbol -> table  -- Verificar se já existe
                Nothing -> error $ "Variable " ++ name ++ " not declared"
        processCommand (If _ block) table level =
            processBlock block table (level + 1) -- Nested if {}
        processCommand (IfElse _ block1 block2) table level =
            let table1 = processBlock block1 table (level + 1)
            in processBlock block2 table1 (level + 1)
        processCommand (While _ block) table level =
            processBlock block table (level + 1) -- Nested while {}
        processCommand _ table _ = table -- Caso base não altera a tabela


-- Necessário remover scope?

removeScope :: SymbolTable -> Int -> SymbolTable
removeScope table level = Map.filter (\info  -> scope info < level) table


-- Inserir um símbolo na tabela
insertSymbol :: String -> Symbol -> SymbolTable -> SymbolTable
insertSymbol = Map.insert

-- Dar lookup a um símbolo na tabela
lookupSymbol :: String -> SymbolTable -> Maybe Symbol
lookupSymbol = Map.lookup

-- Dar update a um símbolo na tabela
updateSymbol :: String -> (Symbol -> Symbol) -> SymbolTable -> SymbolTable
updateSymbol name updateName = Map.update (Just . updateName) name



-- Print à tabela
printSymbolTable :: SymbolTable -> IO ()
printSymbolTable table = mapM_ print (Map.toList table)
module AST where


-- Program structure
newtype Program = Program Block deriving (Show)

-- Block of commands
type Block = [Command]

-- Commands (Statements)
data Command
  = ValDecl String Expr            -- val declaration
  | VarDecl String Expr            -- var declaration
  | Assign String Expr             -- assignment
  | Print Expr                     -- print statement
  | If Expr Block                  -- if statement
  | IfElse Expr Block Block        -- if-else statement
  | While Expr Block               -- while statement
  | Incr String                    -- increment
  | Decr String                    -- decrement
  | ExprStmt Expr                -- standalone expression as a statement
  deriving (Show)

-- Unified Expressions (covering both arithmetic and boolean)
data Expr
  = Num Int                      -- integer literal
  | Var String                   -- variable
  | Add Expr Expr                -- addition
  | Sub Expr Expr                -- subtraction
  | Mul Expr Expr                -- multiplication
  | Div Expr Expr                -- division
  | Equal Expr Expr              -- equality
  | Less Expr Expr               -- less than
  | LessEq Expr Expr             -- less than or equal
  | Greater Expr Expr            -- greater than
  | GreaterEq Expr Expr          -- greater than or equal
  | BoolConst Bool               -- boolean constants
  | Not Expr                     -- logical NOT
  | And Expr Expr                -- logical AND
  | Or Expr Expr                 -- logical OR
  | Parens Expr                  -- parentheses
  | ReadLn                       -- readln function as an expression
  | IfExpr Expr Block              -- Single-branch If expression
  | IfElseExpr Expr Block Block    -- Double-branch If-Else expression
  deriving (Show)

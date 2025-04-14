# Kotlin-Compiler

Project Overview:
This project implements a basic compiler for a subset of the Kotlin programming
language, handling key programming constructs like variable declarations, expressions,
conditional statements, loops, and input/output functions. Using a lexical analyzer
( Lexer.x ) and parser ( Parser.y ), the compiler interprets simple Kotlin programs and
builds an Abstract Syntax Tree (AST) to represent the program's structure and
operations.
Project Components
1. Lexer (Lexer.x)
Purpose: The lexer, generated with Alex, scans input Kotlin code to produce
tokens representing lexical elements.
Key Tokens: Keywords like val , var , if , else , while , print , readln ;
symbols like + , - , * , / , = , && , || , < , > , ( , ) , { , } , etc.
Token Output: The lexer outputs a sequence of tokens that are passed to the
parser for syntactical analysis.
2. Parser (Parser.y)
Purpose: The parser, created using Happy, analyzes the token stream, verifies
the syntactical correctness, and builds the AST.
Grammar:
Supports assignments, arithmetic and boolean expressions, conditionals
( if statements), and loops ( while ).
Each construct is associated with AST nodes that represent program
statements and expressions.
Error Handling: Custom error messages indicate unexpected tokens or invalid
syntax.
3. Abstract Syntax Tree (AST.hs)
Purpose: The AST represents the hierarchical structure of the parsed code,
allowing further manipulation or evaluation.
Main Nodes:
Program : Root node representing the main function.
Block : Represents a block of commands.
Command Types: Includes variable declarations, assignments, print
statements, and control structures like IfStmt , IfElseStmt ,
WhileStmt .
Expr : Represents arithmetic and boolean expressions, standalone
expressions, and operations within statements.
4. Error Handling
Lexical Errors: The lexer identifies invalid symbols or sequences and stops
token generation with an error message.


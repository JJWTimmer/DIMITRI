module lang::jedi::base::Implode

import ParseTree;

import lang::jedi::base::AST;

public lang::jedi::base::AST::Format implode(Tree x) = implode(#lang::jedi::base::AST::Format, x);
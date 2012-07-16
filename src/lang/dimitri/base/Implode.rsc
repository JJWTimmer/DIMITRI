module lang::dimitri::base::Implode

import ParseTree;

import lang::dimitri::base::AST;

public lang::dimitri::base::AST::Format implode(Tree x) = implode(#lang::dimitri::base::AST::Format, x);
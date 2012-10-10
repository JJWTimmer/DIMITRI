module lang::dimitri::levels::l7::Implode

import ParseTree;

import lang::dimitri::levels::l6::Desugar;

import lang::dimitri::levels::l7::AST;

public Format implode(Tree t) = implode(#Format, t);
module lang::dimitri::levels::l6::Implode

import ParseTree;

import lang::dimitri::levels::l6::Desugar;
import lang::dimitri::levels::l6::AST;

public Format implode(Tree t) = implode(#Format, t);
module lang::dimitri::levels::l6::prettyPrinting::ImplodeNoDesugar

import ParseTree;

import lang::dimitri::levels::l6::AST;

public Format implodeNoDesugar(Tree t) = implode(#Format, t);
module lang::dimitri::levels::l2::prettyPrinting::ImplodeNoDesugar

import ParseTree;

import lang::dimitri::levels::l2::AST;

public Format implodeNoDesugar(Tree t) = implode(#Format, t);
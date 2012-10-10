module lang::dimitri::levels::l7::prettyPrinting::ImplodeNoDesugar

import ParseTree;

import lang::dimitri::levels::l7::AST;

public Format implodeNoDesugar(Tree t) = implode(#Format, t);
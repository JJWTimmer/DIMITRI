module lang::dimitri::levels::l1::prettyPrinting::ImplodeNoDesugar

import ParseTree;

import lang::dimitri::levels::l1::AST;

public Format implodeNoDesugar(Tree t) = implode(#Format, t);
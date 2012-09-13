module lang::dimitri::levels::l4::prettyPrinting::ImplodeNoDesugar

import ParseTree;

import lang::dimitri::levels::l4::AST;

public Format implodeNoDesugar(Tree t) = implode(#Format, t);
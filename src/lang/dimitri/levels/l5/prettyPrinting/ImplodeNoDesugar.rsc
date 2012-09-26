module lang::dimitri::levels::l5::prettyPrinting::ImplodeNoDesugar

import ParseTree;

import lang::dimitri::levels::l5::AST;

public Format implodeNoDesugar(Tree t) = implode(#Format, t);
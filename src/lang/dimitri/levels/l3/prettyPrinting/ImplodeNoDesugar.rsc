module lang::dimitri::levels::l3::prettyPrinting::ImplodeNoDesugar

import ParseTree;

import lang::dimitri::levels::l3::AST;

public Format implodeNoDesugar(Tree t) = implode(#Format, t);
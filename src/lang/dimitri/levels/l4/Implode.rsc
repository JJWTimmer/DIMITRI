module lang::dimitri::levels::l4::Implode

import ParseTree;

import lang::dimitri::levels::l3::Desugar;
import lang::dimitri::levels::l4::AST;

public Format implode(Tree t) = implode(#Format, t);
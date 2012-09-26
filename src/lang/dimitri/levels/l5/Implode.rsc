module lang::dimitri::levels::l5::Implode

import ParseTree;

import lang::dimitri::levels::l3::Desugar;
import lang::dimitri::levels::l5::AST;

public Format implode(Tree t) = implode(#Format, t);
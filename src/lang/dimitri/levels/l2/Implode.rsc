module lang::dimitri::levels::l2::Implode

import ParseTree;

import lang::dimitri::levels::l2::AST;
import lang::dimitri::levels::l1::Desugar;

public Format implode(Tree t) = implode(#Format, t);
module lang::dimitri::levels::l2::Implode

import ParseTree;

import lang::dimitri::levels::l1::Desugar;
import lang::dimitri::levels::l2::AST;

public Format implode(Tree t) = implode(#Format, t);
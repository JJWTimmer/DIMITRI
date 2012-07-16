module lang::dimitri::levels::l1::Parse

import ParseTree;

import lang::dimitri::levels::l1::Syntax;

public Format parse(loc l) = parse(#Format, l);
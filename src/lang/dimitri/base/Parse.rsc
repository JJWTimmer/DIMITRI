module lang::dimitri::base::Parse

import ParseTree;

import lang::dimitri::base::Syntax;

public Format parse(loc l) = parse(#Format, l);
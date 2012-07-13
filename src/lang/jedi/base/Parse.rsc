module lang::jedi::base::Parse

import ParseTree;

import lang::jedi::base::Syntax;

public Format parse(loc l) = parse(#Format, l);
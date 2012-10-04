module lang::dimitri::levels::l6::Parse

import ParseTree;

import lang::dimitri::levels::l6::Syntax;

public start[Format] parse(loc l) = parse(#start[Format], l);
public start[Format] parse(str input, loc org) = parse(#start[Format], input, org);
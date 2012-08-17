module lang::dimitri::levels::l1::Parse

import ParseTree;
import lang::dimitri::levels::l1::Syntax;

public Format parse(loc l) = parse(#Format, l);
public Format parse(str input, loc org) = parse(#Format, input, org);
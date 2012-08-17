module lang::dimitri::Level2

import ParseTree;
import util::IDE;

import lang::dimitri::levels::l2::Parse;
import lang::dimitri::levels::l2::Implode;
import lang::dimitri::levels::l2::AST;

public str LANG = "Dimitri L2";
public str EXT  = "dim2";

public void registerL2() {
	registerLanguage(LANG, EXT, parseL2);
}

public Tree parseL2(str input, loc org) {
	return parse(input, org);
}

public Tree parseL2(loc org) {
	return parse(org);
}

public Format implodeL2(Tree f) {
	return implode(f);
}

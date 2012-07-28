module lang::dimitri::levels::Level2

import ParseTree;
import util::IDE;

import lang::dimitri::levels::l2::Parse;
import lang::dimitri::levels::l1::Implode;
import lang::dimitri::levels::l1::AST;

public str LANG = "Dimitri L2";

public Tree parseLevel(str input, loc org) {
	return parse(input, org);
}

public Tree parseLevel(loc org) {
	return parse(org);
}

public Format implodeLevel(Tree format) {
	return implode(format);
}

public void registerLevel(str ext) {
	registerLanguage(LANG, ext, parseLevel);
}
module lang::dimitri::Base

import ParseTree;
import util::IDE;

import lang::dimitri::base::Parse;
import lang::dimitri::base::Implode;
import lang::dimitri::base::AST;

loc TEST_FILE = |project://dimitri/formats/l1.jd|;
public str HOST_LANG = "Dimitri Base";
public str HOST_EXT  = "dim";

public Tree parseHost() {
	return parse(TEST_FILE);
}

public Format implodeHost() {
	return implode(parse(TEST_FILE));
}

public void registerHost() {
	registerLanguage(HOST_LANG, HOST_EXT, Tree (str input, loc org) {
		return parse(org); });
}
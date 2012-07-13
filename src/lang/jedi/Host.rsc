module lang::jedi::Host

import ParseTree;
import util::IDE;

import lang::jedi::base::Parse;
import lang::jedi::base::Implode;
import lang::jedi::base::AST;

loc TEST_FILE = |project://JEDI/formats/l1.jd|;
str HOST_LANG = "Jedi Host";
str HOST_EXT  = "jd";

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
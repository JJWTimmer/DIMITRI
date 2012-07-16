module lang::dimitri::levels::Level1

import ParseTree;
import util::IDE;

import lang::dimitri::levels::l1::Parse;
import lang::dimitri::levels::l1::Implode;
import lang::dimitri::levels::l1::AST;

loc TEST_FILE = |project://dimitri/formats/l1.dim|;

public Tree parseL1() {
	return parse(TEST_FILE);
}

public Format implodeL1() {
	return implodeL1(TEST_FILE);
}

public Format implodeL1(loc file) {
	return implode(parse(file));
}

public void registerL1(str langName, str ext) {
	registerLanguage(langName, ext, Tree (str input, loc org) {
		return parse(org); });
}
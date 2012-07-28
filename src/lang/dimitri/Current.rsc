module lang::dimitri::Current

import ParseTree;
import util::IDE;
import Node;

import lang::dimitri::levels::Level1; //change this to change level

public Tree parse(str input, loc org) {
	return parseLevel(input, org);
}

public Tree parse(loc org) {
	return parseLevel(org);
}

public node implode(Tree t) {
	return implodeLevel(t);
}

public Tree checkNames(Tree t) {
	return checkNamesLevel(t);
}

public Tree checkTypes(Tree t) {
	return checkTypesLevel(t);
}

public Tree check(Tree t) {
	return checkLevel(t);
}

public void registerLang(str ext) {
	registerLevel(ext);
}

public void compile(loc file) {
	compileLevel(file);
}
module lang::dimitri::levels::l1::ErrorChecking

import ParseTree;
import lang::dimitri::levels::l1::errorChecking::NameAnalysis;
import lang::dimitri::levels::l1::errorChecking::TypeAnalysis;

public Tree check(Tree t) {
	t = nameCheck(t);
	t = typeCheck(t);
	return t;
}

public Tree checkNames(Tree t) {
	t = nameCheck(t);
	return t;
}

public Tree checkTypes(Tree t) {
	t = typeCheck(t);
	return t;
}


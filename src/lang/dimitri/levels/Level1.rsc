module lang::dimitri::levels::Level1

import ParseTree;
import util::IDE;
import List;
import Set;
import IO;
import Message;

import lang::dimitri::levels::l1::AST;
import lang::dimitri::levels::l1::Parse;
import lang::dimitri::levels::l1::Implode;
import lang::dimitri::levels::l1::ErrorChecking;
import lang::dimitri::levels::l1::Compiler;

public str LANG = "Dimitri L1";
public list[FormatSpecifier] DEFAULTS =
	[
		formatSpecifier(unit(), byte()),
		formatSpecifier(sign(), \false()),
		formatSpecifier(endian(), big()),
		formatSpecifier(strings(), ascii()),
		formatSpecifier(\type(), integer()),
		variableSpecifier(size(), number("1"))
	];

public void registerLevel(str ext) {
	registerLanguage(LANG, ext, parseLevel);
	registerAnnotator(LANG, check);
}

public void buildFormat(loc file) {
	tree = parse(file);
	checked = check(tree);
	if (isEmpty(checked@messages)) {
		;
	}
}

public Tree parseLevel(str input, loc org) {
	return parse(input, org);
}

public Tree parseLevel(loc org) {
	return parse(org);
}

public node implodeLevel(Tree format) {
	return implode(format);
}

public Tree checkNamesLevel(Tree input) {
	return checkNames(input);
}


public Tree checkTypesLevel(Tree input) {
	return checkNames(input);
}

public Tree checkLevel(Tree input) {
	return check(input);
}

public void compileLevel(loc file) {
	tree = parse(file);
	tree = check(tree);
	if (!isEmpty(tree@messages)) {
		println("There are errors:");
		for (err <- tree@messages) {
			println("<err.msg> @ <err.at>");
		}
		return;
	}
	ast = implode(tree);
	
	compile(ast, DEFAULTS);
}

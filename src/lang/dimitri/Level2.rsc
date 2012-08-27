module lang::dimitri::Level2

import ParseTree;
import util::IDE;

import lang::dimitri::Level1;

import lang::dimitri::levels::l2::Parse;
import lang::dimitri::levels::l2::Implode;
import lang::dimitri::levels::l2::AST;
import lang::dimitri::levels::l2::Check;
import lang::dimitri::levels::l2::Compiler;

public str LANG = "Dimitri L2";
public str EXT  = "dim2";
public str PACKAGE = "org.dimitri_lang.generated";

public void registerL2() {
	registerLanguage(LANG, EXT, parseL2);
	registerAnnotator(LANG, checkL2);
}

public Tree parseL2(str input, loc org) = parse(input, org);

public Tree parseL2(loc org) = parse(org);

public Format implodeL2(Tree t) = implode(t);

public Tree checkL2(Tree t) = t[@messages=lang::dimitri::levels::l2::Check::check(ast)] when ast := implode(t);

public void compileL2(loc file) {
	tree = parse(file);
	ast = implode(tree);
	messages = check(ast);
	if (messages != {}) {
		println("There are errors:");
		for (err <- messages) {
			println("<err.msg> @ <err.at>");
		}
		return;
	}
	
	compile(ast, DEFAULTS, PACKAGE);
}
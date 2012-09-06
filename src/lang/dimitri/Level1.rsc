module lang::dimitri::Level1

import ParseTree;
import util::IDE;
import List;
import Set;
import IO;
import Message;

import lang::dimitri::levels::l1::AST;
import lang::dimitri::levels::l1::Parse;
import lang::dimitri::levels::l1::Implode;
import lang::dimitri::levels::l1::prettyPrinting::PrettyPrinting;
import lang::dimitri::levels::l1::Outliner;
import lang::dimitri::levels::l1::Check;
import lang::dimitri::levels::l1::Compiler;

public str LANG = "Dimitri L1";
public str EXT  = "dim1";
public str PACKAGE = "org.dimitri_lang.generated";

public void registerL1() {
	registerLanguage(LANG, EXT, parseL1);
	registerAnnotator(LANG, checkL1);
	registerOutliner(LANG, outline);
	
	contribution = {
		popup(
			menu("Dimitri",
				[
					action("Compile Format", void (Tree tree, loc selection) { compileL1(selection); }),
					action("Format && Remove Comments", void (Tree tree, loc selection) { prettyPrintFile(selection); })
				]
			)
		)
	};
	registerContributions(LANG, contribution);
}

public Tree parseL1(str input, loc org) = parse(input, org).top;

public Tree parseL1(loc org) = parse(org).top;

public node implodeL1(Tree format) = implode(format);

public node implodeNoDesugarL1(Tree format) = implodeNoDesugar(format);

public void prettyPrintL1(loc org) = prettyPrint(org);

public Tree checkL1(Tree input) = input[@messages=check(ast)] when ast := implode(input);

public void compileL1(loc file) {
	tree = parse(file).top;
	ast = implode(tree);
	messages = check(ast);
	if (messages != {}) {
		println("There are errors:");
		for (err <- messages) {
			println("<err.msg> @ <err.at>");
		}
		return;
	}

	
	compile(ast, PACKAGE);
}

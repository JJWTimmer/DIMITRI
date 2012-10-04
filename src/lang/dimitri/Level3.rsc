module lang::dimitri::Level3

import ParseTree;
import util::IDE;
import IO;

import lang::dimitri::levels::l3::Outliner;
import lang::dimitri::levels::l3::Check;
import lang::dimitri::levels::l3::Parse;
import lang::dimitri::levels::l3::Implode;
import lang::dimitri::levels::l3::AST;
import lang::dimitri::levels::l3::prettyPrinting::PrettyPrinting;
import lang::dimitri::levels::l3::Compiler;

str LANG = "Dimitri L3";
str EXT  = "dim3";
str PACKAGE = "org.dimitri_lang.generated";

public void registerL3() {
	registerLanguage(LANG, EXT, parseL3);
	registerAnnotator(LANG, checkL3);
	registerOutliner(LANG, outlineL3);
	
	contribution = {
		popup(
			menu("Dimitri",
				[
					action("Compile Format", void (Tree tree, loc selection) { compileL3(selection); }),
					action("Format && Remove Comments", void (Tree tree, loc selection) { prettyPrintFile(selection); })
				]
			)
		)
	};
	registerContributions(LANG, contribution);
}

public Tree parseL3(str input, loc org) = parse(input, org).top;

public Tree parseL3(loc org) = parse(org).top;

public Format implodeL3(Tree t) = implode(t);

public Tree checkL3(Tree t) = t[@messages=check(ast)] when ast := implode(t);

public void compileL3(loc file) {
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
module lang::dimitri::Level5

import ParseTree;
import util::IDE;
import IO;

import lang::dimitri::levels::l5::Outliner;
import lang::dimitri::levels::l5::Check;
import lang::dimitri::levels::l5::Parse;
import lang::dimitri::levels::l5::Implode;
import lang::dimitri::levels::l5::AST;
import lang::dimitri::levels::l5::prettyPrinting::PrettyPrinting;
import lang::dimitri::levels::l5::Compiler;

public str LANG = "Dimitri L5";
public str EXT  = "dim5";
public str PACKAGE = "org.dimitri_lang.generated";

public void registerL5() {
	registerLanguage(LANG, EXT, parseL5);
	registerAnnotator(LANG, checkL5);
	registerOutliner(LANG, outlineL5);
	contribution = {
		popup(
			menu("Dimitri",
				[
					action("Compile Format", void (Tree tree, loc selection) { compileL5(selection); }),
					action("Format && Remove Comments", void (Tree tree, loc selection) { prettyPrintFile(selection); })
				]
			)
		)
	};
	registerContributions(LANG, contribution);
}

public Tree parseL5(str input, loc org) = parse(input, org).top;

public Tree parseL5(loc org) = parse(org).top;

public Format implodeL5(Tree t) = implode(t);

public Tree checkL5(Tree t) = t[@messages=checkErrorsL5(ast)] when ast := implodeL5(t);

public void compileL5(loc file) {
	tree = parse(file);
	ast = implode(tree);
	messages = checkErrorsL5(ast);
	if (messages != {}) {
		println("There are errors:");
		for (err <- messages) {
			println("<err.msg> @ <err.at>");
		}
		return;
	}
	
	compile(ast, PACKAGE);
}
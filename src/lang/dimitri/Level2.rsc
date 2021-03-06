module lang::dimitri::Level2

import ParseTree;
import util::IDE;
import IO;

import lang::dimitri::levels::l2::ide::Outliner;
import lang::dimitri::levels::l2::Parse;
import lang::dimitri::levels::l2::Implode;
import lang::dimitri::levels::l2::AST;
import lang::dimitri::levels::l2::prettyPrinting::PrettyPrinting;
import lang::dimitri::levels::l2::Check;
import lang::dimitri::levels::l2::Compiler;

public loc T12 = |project://dimitri/formats/test1.dim2|;
public loc T22 = |project://dimitri/formats/test2.dim2|;

str LANG = "Dimitri L2";
str EXT  = "dim2";
str PACKAGE = "org.dimitri_lang.generated";

public void registerL2() {
	registerLanguage(LANG, EXT, parseL2);
	registerAnnotator(LANG, checkL2);
	registerOutliner(LANG, outlineL2);
	
	contribution = {
		popup(
			menu("Dimitri",
				[
					action("Compile Format", void (Tree tree, loc selection) { compileL2(selection); }),
					action("Format && Remove Comments", void (Tree tree, loc selection) { prettyPrintFile(selection); })
				]
			)
		)
	};
	registerContributions(LANG, contribution);
}

public Tree parseL2(str input, loc org) = parse(input, org).top;

public Tree parseL2(loc org) = parse(org).top;

public Format implodeL2(Tree t) = implode(t);

public Tree checkL2(Tree t) = t[@messages=checkErrorsL2(ast)] when ast := implode(t);

public void compileL2(loc file) {
	tree = parse(file).top;
	ast = implode(tree);
	messages = checkErrorsL2(ast);
	if (messages != {}) {
		println("There are errors:");
		for (err <- messages) {
			println("<err.msg> @ <err.at>");
		}
		return;
	}
	
	compile(ast, PACKAGE);
}
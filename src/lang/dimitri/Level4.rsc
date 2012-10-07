module lang::dimitri::Level4

import ParseTree;
import util::IDE;
import IO;

import lang::dimitri::levels::l4::ide::Outliner;
import lang::dimitri::levels::l4::Check;
import lang::dimitri::levels::l4::Parse;
import lang::dimitri::levels::l4::Implode;
import lang::dimitri::levels::l4::AST;
import lang::dimitri::levels::l4::prettyPrinting::PrettyPrinting;
import lang::dimitri::levels::l4::Compiler;

public loc T14 = |project://dimitri/formats/test1.dim4|;
public loc T24 = |project://dimitri/formats/test2.dim4|;

str LANG = "Dimitri L4";
str EXT  = "dim4";
str PACKAGE = "org.dimitri_lang.generated";

public void registerL4() {
	registerLanguage(LANG, EXT, parseL4);
	registerAnnotator(LANG, checkL4);
	registerOutliner(LANG, outlineL4);
	contribution = {
		popup(
			menu("Dimitri",
				[
					action("Compile Format", void (Tree tree, loc selection) { compileL4(selection); }),
					action("Format && Remove Comments", void (Tree tree, loc selection) { prettyPrintFile(selection); })
				]
			)
		)
	};
	registerContributions(LANG, contribution);
}

public Tree parseL4(str input, loc org) = parse(input, org).top;

public Tree parseL4(loc org) = parse(org).top;

public Format implodeL4(Tree t) = implode(t);

public Tree checkL4(Tree t) = t[@messages=checkErrorsL4(ast)] when ast := implodeL4(t);

public void compileL4(loc file) {
	tree = parse(file).top;
	ast = implode(tree);
	messages = checkErrorsL4(ast);
	if (messages != {}) {
		println("There are errors:");
		for (err <- messages) {
			println("<err.msg> @ <err.at>");
		}
		return;
	}
	
	compile(ast, PACKAGE);
}
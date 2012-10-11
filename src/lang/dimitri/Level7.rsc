module lang::dimitri::Level7

import util::IDE;
import ParseTree;
import IO;

import lang::dimitri::levels::l5::ide::Completion;

import lang::dimitri::levels::l7::Check;
import lang::dimitri::levels::l7::ide::Outliner;
import lang::dimitri::levels::l7::Parse;
import lang::dimitri::levels::l7::Implode;
import lang::dimitri::levels::l7::AST;
import lang::dimitri::levels::l7::prettyPrinting::PrettyPrinting;
import lang::dimitri::levels::l7::Compiler;

public loc T17 = |project://dimitri/formats/test1.dim7|;
public loc T27 = |project://dimitri/formats/test2.dim7|;
public loc PNG7 = |project://dimitri/formats/png.dim7|;

str LANG = "Dimitri L7";
str EXT  = "dim7";
str PACKAGE = "org.dimitri_lang.generated";

public void registerL7() {
	registerLanguage(LANG, EXT, parseL7);
	registerAnnotator(LANG, checkL7);
	registerOutliner(LANG, outlineL7);
	contribution = {
		popup(
			menu("Dimitri",
				[
					action("Compile Format", void (Tree tree, loc selection) { compileL6(selection); }),
					action("Format && Remove Comments", void (Tree tree, loc selection) { prettyPrintFile(selection); })
				]
			)
		)
		,proposerContrib
	};
	registerContributions(LANG, contribution);
}

public Tree parseL7(str input, loc org) = lang::dimitri::levels::l7::Parse::parse(input, org);

public Tree parseL7(loc org) = lang::dimitri::levels::l7::Parse::parse(org);

public Format implodeL7(Tree t) = implode(t.top);

public Tree checkL7(Tree t) = t[@messages=checkErrorsL7(ast)] when ast := implodeL7(t);

public void compileL7(loc file) {
	tree = parse(file);
	ast = implodeL7(tree);
	messages = checkErrorsL7(ast);
	if (messages != {}) {
		println("There are errors:");
		for (err <- messages) {
			println("<err.msg> @ <err.at>");
		}
		return;
	}
	
	compile(ast, PACKAGE);
}
module lang::dimitri::Level6

import util::IDE;
import ParseTree;
import IO;

//import lang::dimitri::levels::l5::ide::Outliner;
//import lang::dimitri::levels::l5::ide::Completion;
//import lang::dimitri::levels::l5::Check;
import lang::dimitri::levels::l6::Parse;
import lang::dimitri::levels::l6::Implode;
import lang::dimitri::levels::l6::AST;
//import lang::dimitri::levels::l5::ide::prettyPrinting::PrettyPrinting;
//import lang::dimitri::levels::l5::Compiler;


str LANG = "Dimitri L6";
str EXT  = "dim6";
str PACKAGE = "org.dimitri_lang.generated";

public void registerL6() {
	registerLanguage(LANG, EXT, parseL6);
	//registerAnnotator(LANG, checkL6);
	//registerOutliner(LANG, outlineL6);
	contribution = {
		popup(
			menu("Dimitri",
				[
					//action("Compile Format", void (Tree tree, loc selection) { compileL6(selection); }),
					//action("Format && Remove Comments", void (Tree tree, loc selection) { prettyPrintFile(selection); })
				]
			)
		)
		//,proposerContrib
	};
	registerContributions(LANG, contribution);
}

public Tree parseL6(str input, loc org) = lang::dimitri::levels::l6::Parse::parse(input, org);

public Tree parseL6(loc org) = lang::dimitri::levels::l6::Parse::parse(org);

public Format implodeL6(Tree t) = implode(t);

//public Tree checkL6(Tree t) = t[@messages=checkErrorsL6(ast)] when ast := implodeL6(t);

//public void compileL6(loc file) {
//	tree = parse(file);
//	ast = implode(tree);
//	messages = checkErrorsL6(ast);
//	if (messages != {}) {
//		println("There are errors:");
//		for (err <- messages) {
//			println("<err.msg> @ <err.at>");
//		}
//		return;
//	}
//	
//	compile(ast, PACKAGE);
//}
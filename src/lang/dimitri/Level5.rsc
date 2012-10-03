module lang::dimitri::Level5

import ParseTree;
import util::IDE;
import IO;
import util::ContentCompletion;
import List;

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
		,proposerContrib
	};
	registerContributions(LANG, contribution);
}

public Tree parseL5(str input, loc org) = parse(input, org);

public Tree parseL5(loc org) = parse(org);

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

str symbol_type_struct = "Structure";
str symbol_type_field = "Field";

public list[CompletionProposal] makeProposals(Tree input, str prefix, int requestOffset) {
	ast = implode(input);
	symbolTree = makeSymbolTree(ast);

	filterTypes = getFilterTypes(ast, requestOffset);
	symbols = flattenTree(symbolTree);
	symbols = filterSymbolsByType(symbols, filterTypes);

	proposals = createProposalsFromLabels(symbols);
	proposals = sort(proposals, lessThanOrEqual);
	proposals = filterPrefix(proposals, prefix);
	return proposals;
}

public list[str] getFilterTypes(Format ast, int offset) {	
	bottom-up-break visit(ast) {
		case Sequence seq : if (isWithin(seq@location, offset)) return [symbol_type_struct];
		case list[Structure] ls : {
			if (ls != []) {
				loca = |project://dimitri/|;
				l1 = head(ls)@location;
				loca = loca[offset = l1.offset];
				l2 = last(ls)@location;
				loca = loca[length=(l2.offset - l2.offset) + l2.length ];
				if (isWithin(loca, offset))
					return [symbol_type_struct, symbol_type_field];
			}
		}
	}

	return [];
}

SymbolTree makeSymbolTree(Format ast) {
	list[SymbolTree] symbols = [];	
	visit(ast) {
		case struct(id(sname), flds) : {
			symbols += symbol(sname, symbol_type_struct)[@label = "<sname> : <symbol_type_struct>"];
			symbols = makeSymbolTree(symbols,sname, flds); 
		}
	}
	return scope(symbols)[@label=""];
}

list[SymbolTree] makeSymbolTree(list[SymbolTree] symbols, str sname, list[Field] fields) {
	visit(fields) {
		case field(id(fname), _, _): symbols += symbol("<sname>.<fname>", symbol_type_field)[@label = "<sname>.<fname> : <symbol_type_field>"];
	}
	return symbols;
}
public Contribution proposerContrib = proposer(makeProposals, alphaNumeric + "_");
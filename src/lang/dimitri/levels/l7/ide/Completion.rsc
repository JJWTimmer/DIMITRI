module lang::dimitri::levels::l7::ide::Completion

import ParseTree;
import util::IDE;
import IO;
import util::ContentCompletion;
import List;

import lang::dimitri::levels::l7::AST;
import lang::dimitri::levels::l7::Implode;

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
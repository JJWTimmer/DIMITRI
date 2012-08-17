module lang::dimitri::levels::l1::compiler::SequenceSymbol2String

import lang::dimitri::levels::l1::AST;

public str writeSymbol(SequenceSymbol s) {
	switch(s) {
		case SequenceSymbol ss : return getSymbol(ss);
	}
	return "";
}

private str getSymbol( SequenceSymbol::struct(id(name))) = name;
private str getSymbol( optionalSeq(SequenceSymbol symbol)) = "<writeSymbol(symbol)>?";
private str getSymbol( zeroOrMoreSeq(SequenceSymbol symbol)) = "<writeSymbol(symbol)>*";
private str getSymbol( notSeq(SequenceSymbol symbol)) = "!<writeSymbol(symbol)>";
private str getSymbol( choiceSeq(set[SequenceSymbol] symbols)) = "(<("" | it + " " + symbol | sym <- symbols, symbol := writeSymbol(sym))> )";
private str getSymbol( fixedOrderSeq(list[SequenceSymbol] symbolSequence)) = "[<("" | it + " " + symbol | sym <- symbolSequence, symbol := writeSymbol(sym))> ]";

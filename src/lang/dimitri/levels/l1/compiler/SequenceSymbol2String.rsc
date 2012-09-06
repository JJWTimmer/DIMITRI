module lang::dimitri::levels::l1::compiler::SequenceSymbol2String

import List;
import Set;
import lang::dimitri::levels::l1::AST;

public str symbol2string(SequenceSymbol s) {
	switch(s) {
		case SequenceSymbol ss : return getSymbol(ss);
	}
	return "";
}

private str getSymbol( SequenceSymbol::struct(id(name))) = name;
private str getSymbol( optionalSeq(SequenceSymbol symbol)) = "<symbol2string(symbol)>?";
private str getSymbol( zeroOrMoreSeq(SequenceSymbol symbol)) = "<symbol2string(symbol)>*";
private str getSymbol( notSeq(SequenceSymbol symbol)) = "!<symbol2string(symbol)>";
private str getSymbol( choiceSeq(set[SequenceSymbol] symbols)) = "( <intercalate(" ", toList(mapper(symbols, symbol2string)))> )";
private str getSymbol( fixedOrderSeq(list[SequenceSymbol] symbols)) = "[ <intercalate(" ", mapper(symbols, symbol2string))> ]";
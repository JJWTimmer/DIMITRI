module lang::dimitri::levels::l1::compiler::Normalize

import Set;
import List;
import String;
import analysis::graphs::Graph;

import lang::dimitri::levels::l1::util::IdHelper;
import lang::dimitri::levels::l1::AST;

public Format normalize(Format format) = format4 when
	format1 := removeMultipleExpressions(format),
	format2 := removeStrings(format1),
	format3 := removeNotSequence(format2),
	format4 := sequence2dnf(format3);


private Format removeMultipleExpressions(Format format) {
	str getFName(int i, str fname) {
		if (i > 0) {
			fname += "*<i>";
		}
		return fname;
	}

	list[Field] expandMultipleExpressions(list[Field] fields) {
		return ret:for (f <- fields) {
			if (f has values, f.values != []) {
				int i = 0;
				for (c <- f.values) {
					append ret: field(id(getFName(i, f.name.val)), [c], f.format)[@parent=(i > 0 ? f.name.val : "" )];
					i += 1;
				}
			} else append f;
		};
	}

	return visit (format) {
		case struct(name, fields) => struct(name, expandMultipleExpressions(fields))
	}
}

private Format removeStrings(Format format) {
	return visit (format) {
		case struct(sname, list[Field] fields) => struct(sname, expandStrings(sname.val, fields))
	}
}

private list[Field] expandStrings(str sname, list[Field] fields) {
	str getFName(int i, str fname) {
		if (i > 0) {
			fname += "*s<i>";
		}
		return fname;
	}

	return ret: for (f <- fields) {
		if (f has values, f.values != [], string(sval) :=  f.values[0]) {
			localformat = visit (f.format) {
				case formatSpecifier("unit", _) => formatSpecifier("unit", "byte")
				case formatSpecifier("sign", _) => formatSpecifier("sign", "false")
				case formatSpecifier("type", _) => formatSpecifier("type", "integer")
				case variableSpecifier("size", _) => variableSpecifier("size", number(1))
			};
			
			fname = f.name.val;
			
			int i = 0;
			for (c <- chars(sval)) {
				append ret: field(id(getFName(i, fname)), [number(c)], localformat)[@parent=(i > 0 ? fname : "" )];
				i += 1;
			}
		}
		else {
			append ret: f;
		}
	};
}

private Format removeNotSequence(Format format) {
	return visit (format) {
		case SequenceSymbol s : insert removeNot(s);
	}
}

public SequenceSymbol removeNot(notSeq(s:struct(_))) = invert(format, {s});
public SequenceSymbol removeNot(notSeq(choiceSeq(symbols))) = invert(format, symbols);
public default SequenceSymbol removeNot(SequenceSymbol s) = s;

//helper for removeNot
public SequenceSymbol invert(Format format, set[SequenceSymbol] symbols) {
	exclude = for (struct(name) <- symbols) {
		append name;
	}

	include = for ( struct(name, _) <- format.structures) {
		if (name notin exclude) {
			append struct(name);
		}
	}
	
	//FIXME: check if all structs are excluded! Then emptylist generates error!
	return size(include) > 1 ? choiceSeq(toSet(include)) : include[0];
}

public Format sequence2dnf(Format format) {
	return top-down-break visit(format) {
		case SequenceSymbol s : insert dnf(s);
	}
}

public SequenceSymbol dnf( SequenceSymbol::struct(Id name) )= choiceSeq({fixedOrderSeq([struct(name)])});
public SequenceSymbol dnf( optionalSeq(SequenceSymbol::struct(Id name)) )=  choiceSeq({fixedOrderSeq([struct(name)]), fixedOrderSeq([])});
public SequenceSymbol dnf( zeroOrMoreSeq(SequenceSymbol::struct(Id name)) ) = zeroOrMoreSeq(choiceSeq({fixedOrderSeq([struct(name)])}));
public SequenceSymbol dnf( choiceSeq(set[SequenceSymbol] symbols) ) = choiceSeq({ fixedOrderSeq([s]) | s <- symbols, !(fixedOrderSeq(list[SequenceSymbol] syms) := s)} + { s | s <- symbols, fixedOrderSeq(list[SequenceSymbol] syms) := s});
public SequenceSymbol dnf( zeroOrMoreSeq(choiceSeq(set[SequenceSymbol] symbols)) ) = zeroOrMoreSeq(choiceSeq({ fixedOrderSeq([s]) | s <- symbols, !(fixedOrderSeq(list[SequenceSymbol] syms) := s)} + { s | s <- symbols, fixedOrderSeq(list[SequenceSymbol] syms) := s}));
public SequenceSymbol dnf( fixedOrderSeq(list[SequenceSymbol] symbols) ) = choiceSeq({fixedOrderSeq(symbols)} + { s | s <- symbols, fixedOrderSeq(list[SequenceSymbol] syms) := s});
public SequenceSymbol dnf( zeroOrMoreSeq(fixedOrderSeq(list[SequenceSymbol] symbols)) ) = zeroOrMoreSeq(choiceSeq({fixedOrderSeq(symbols)}));
public SequenceSymbol dnf( optionalSeq(fixedOrderSeq(list[SequenceSymbol] symbols)) ) = choiceSeq({fixedOrderSeq(symbols), fixedOrderSeq([])});
public SequenceSymbol dnf( optionalSeq(choiceSeq(set[SequenceSymbol] symbols)) ) = choiceSeq({ seq([s]) | s <- symbols, !(fixedOrderSeq(list[SequenceSymbol] syms) := s)} + { s | s <- symbols, fixedOrderSeq(list[SequenceSymbol] syms) := s} + {fixedOrderSeq([])});
public default SequenceSymbol dnf(SequenceSymbol s ) = s;
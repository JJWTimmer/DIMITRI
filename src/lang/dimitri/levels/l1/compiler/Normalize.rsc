module lang::dimitri::levels::l1::compiler::Normalize

/*
	I was desugar
*/

import Set;
import List;
import String;
import Graph;

import lang::dimitri::levels::l1::util::IdHelper;
import lang::dimitri::levels::l1::util::FormatHelper;
import lang::dimitri::levels::l1::AST;
import lang::dimitri::levels::l1::compiler::Strings;

public Format normalize(Format format) {
	format = removeMultipleExpressions(format);
	format = removeStrings(format);
	format = removeNotSequence(format);
	format = normalizeSequence(format);

	return format;
}

/////////////////////////////////////

private Format removeMultipleExpressions(Format format) {
	str getFName(int i, str fname) {
		if (i > 0) {
			fname += "*<i>";
		}
		return fname;
	}

	list[Field] expandMultipleExpressions(list[Field] fields) {
		return ret:for (f <- fields) {
			if (f.values != []) {
				int i = 0;
				for (c <- f.values) {
					append ret: field(id(getFName(i, f.name.val)), [c], f.format);
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
	// struct, field, num strings in field after expansion
	rel[str sname, str name, int count] expandedStrings = {};
	
	//what struct are we in?
	str sname;
	
	/*
		in: struct name, list of fields of that struct
		out: list of fields where strings are split into values of int
		side effect: update expandedStrings
		
		questionmark: sname hides sname above?
	*/
	list[Field] expandStrings(str sname, list[Field] fields) {
		str getFName(int i, str fname) {
			if (i > 0) {
				fname += "*s<i>";
			}
			return fname;
		}
	
		return ret: for (f <- fields) {
			if (f.values != [], string(sval) :=  f.values[0]) {
				f.format = setSFSValue(f.format, "unit", "byte");
				f.format = setSFSValue(f.format, "sign", "false");
				f.format = setSFSValue(f.format, "type", "integer");
				f.format = setSFSValue(f.format, "size", number(1));
				
				fname = f.name.val;
				
				int i = 0;

				for (c <- chars(sval)) {
					append ret: field(id(getFName(i, fname)), [number(c)], f.format);
					i += 1;
				}
			}
			else {
				append ret: f;
			}
		};
	}

	return visit (format) {
		case struct(sname, list[Field] fields) => struct(sname, expandStrings(sname.val, fields))
	}
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

public Format normalizeSequence(Format format) {
	return top-down-break visit(format) {
		case SequenceSymbol s : insert normalizeSeq(s);
	}
}

public SequenceSymbol normalizeSeq( SequenceSymbol::struct(Id name) )= choiceSeq({fixedOrderSeq([struct(name)])});
public SequenceSymbol normalizeSeq( optionalSeq(SequenceSymbol::struct(Id name)) )=  choiceSeq({fixedOrderSeq([struct(name)]), fixedOrderSeq([])});
public SequenceSymbol normalizeSeq( zeroOrMoreSeq(SequenceSymbol::struct(Id name)) ) = zeroOrMoreSeq(choiceSeq({fixedOrderSeq([struct(name)])}));
public SequenceSymbol normalizeSeq( choiceSeq(set[SequenceSymbol] symbols) ) = choiceSeq({ fixedOrderSeq([s]) | s <- symbols, !(fixedOrderSeq(list[SequenceSymbol] syms) := s)} + { s | s <- symbols, fixedOrderSeq(list[SequenceSymbol] syms) := s});
public SequenceSymbol normalizeSeq( zeroOrMoreSeq(choiceSeq(set[SequenceSymbol] symbols)) ) = zeroOrMoreSeq(choiceSeq({ fixedOrderSeq([s]) | s <- symbols, !(fixedOrderSeq(list[SequenceSymbol] syms) := s)} + { s | s <- symbols, fixedOrderSeq(list[SequenceSymbol] syms) := s}));
public SequenceSymbol normalizeSeq( fixedOrderSeq(list[SequenceSymbol] symbols) ) = choiceSeq({fixedOrderSeq(symbols)} + { s | s <- symbols, fixedOrderSeq(list[SequenceSymbol] syms) := s});
public SequenceSymbol normalizeSeq( zeroOrMoreSeq(fixedOrderSeq(list[SequenceSymbol] symbols)) ) = zeroOrMoreSeq(choiceSeq({fixedOrderSeq(symbols)}));
public SequenceSymbol normalizeSeq( optionalSeq(fixedOrderSeq(list[SequenceSymbol] symbols)) ) = choiceSeq({fixedOrderSeq(symbols), fixedOrderSeq([])});
public SequenceSymbol normalizeSeq( optionalSeq(choiceSeq(set[SequenceSymbol] symbols)) ) = choiceSeq({ seq([s]) | s <- symbols, !(fixedOrderSeq(list[SequenceSymbol] syms) := s)} + { s | s <- symbols, fixedOrderSeq(list[SequenceSymbol] syms) := s} + {fixedOrderSeq([])});
public default SequenceSymbol normalizeSeq(SequenceSymbol s ) = s;
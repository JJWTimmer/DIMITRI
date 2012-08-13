module lang::dimitri::levels::l1::compiler::Desugar

import Set;
import List;
import String;
import Graph;

import lang::dimitri::levels::l1::AST;
import lang::dimitri::levels::l1::compiler::Strings;

public Format desugar(Format format) {
	format = removeMultipleExpressions(format);
	format = removeStrings(format);
	format = removeNot(format);
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
			if (f has \value, f.\value has values) {
				int i = 0;
				for (c <- f.\value.values) {
					append ret: field(id(getFName(i, f.name.val)), fieldValue([c], f.\value.format));
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
			if (f has \value, f.\value has values, string(sval) :=  f.\value.values[0]) {
				f.\value.format[0].val = byte();
				f.\value.format[1].val = \false();
				f.\value.format[4].val = integer();
				f.\value.format[5].var = number(1);
				
				format = f.\value.format;
				fname = f.name.val;
				
				int i = 0;

				for (c <- chars(sval)) {
					append ret: field(id(getFName(i, fname)), fieldValue([number(c)], f.\value.format));
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

private Format removeNot(Format format) {
	return visit (format) {
		case notSeq(s:struct(_)) => invert(format, {s})
		case notSeq(choiceSeq(symbols)) => invert(format, symbols)
	}
}

//helper for removeNot
public SequenceSymbol invert(Format format, set[SequenceSymbol] symbols) {
	exclude = for (struct(name) <- symbols) {
		append name;
	}

	include = for ( struct(id(name), _) <- format.structures) {
		if (name notin exclude) {
			append struct(name);
		}
	}
	
	//FIXME: check if all structs are excluded! Then emptylist generates error!
	return size(include) > 1 ? choiceSeq(toSet(include)) : include[0];
}

//TODO: rewrite me to pattern based dispatch; not easy because of nonterminating rules
public Format normalizeSequence(Format format) {
	return top-down-break visit(format) {
		case struct(Id name) => choiceSeq({fixedOrderSeq([struct(name)])})
		case optionalSeq(SequenceSymbol::struct(Id name)) => choiceSeq({fixedOrderSeq([struct(name)]), fixedOrderSeq([])})
		case zeroOrMoreSeq(SequenceSymbol::struct(Id name)) => zeroOrMoreSeq(choiceSeq({fixedOrderSeq([struct(name)])}))
		case choiceSeq(set[SequenceSymbol] symbols) => choiceSeq({ fixedOrderSeq([s]) | s <- symbols, !(fixedOrderSeq(list[SequenceSymbol] syms) := s)} + { s | s <- symbols, fixedOrderSeq(list[SequenceSymbol] syms) := s})
		case zeroOrMoreSeq(choiceSeq(set[SequenceSymbol] symbols)) => zeroOrMoreSeq(choiceSeq({ fixedOrderSeq([s]) | s <- symbols, !(fixedOrderSeq(list[SequenceSymbol] syms) := s)} + { s | s <- symbols, fixedOrderSeq(list[SequenceSymbol] syms) := s}))
		case fixedOrderSeq(list[SequenceSymbol] symbols) => choiceSeq({fixedOrderSeq(symbols)} + { s | s <- symbols, fixedOrderSeq(list[SequenceSymbol] syms) := s})
		case zeroOrMoreSeq(fixedOrderSeq(list[SequenceSymbol] symbols)) => zeroOrMoreSeq(choiceSeq({fixedOrderSeq(symbols)}))
		case optionalSeq(fixedOrderSeq(list[SequenceSymbol] symbols)) => choiceSeq({fixedOrderSeq(symbols), []})
		case optionalSeq(choiceSeq(set[SequenceSymbol] symbols)) => choiceSeq({ seq([s]) | s <- symbols, !(fixedOrderSeq(list[SequenceSymbol] syms) := s)} + { s | s <- symbols, fixedOrderSeq(list[SequenceSymbol] syms) := s} + {fixedOrderSeq([])})
	}
}

//rewrite rules
public Scalar hex(str hex) = number(toInt(substring(hex, 2), 16));
public Scalar oct(str oct) = number(toInt(substring(oct, 2), 8));
public Scalar bin(str bin) = number(toInt(substring(bin, 2), 2));

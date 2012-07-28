module lang::dimitri::levels::l1::compiler::Desugar

import IO;
import Set;
import List;
import String;
import Graph;

import lang::dimitri::levels::l1::AST;
import lang::dimitri::levels::l1::compiler::Strings;

public Format desugar(Format format) {

	format = removeStrings(format);
	format = removeNot(format);
	format = normalizeSequence(format);

	return format;
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
		return for (f <- fields) {
			if (f has \value) {
				if (f.\value has values, string(_) in  f.\value.values) {
				
					f.\value.format[0].val = byte();
					f.\value.format[1].val = \false();
					f.\value.format[4].val = integer();
					f.\value.format[5].val = number(1);
					
					newVals = for (Scalar s <- f.\value.values) {
						int count = 0;
						if (string(sval) := string(_)) {
							
							for (i <- [0..size(sval)-1]) {
								str fname = f.name.val;
								if (i > 0) fname = f.name.val + "*s<i>";
								append number(ascii[sval[i]]);
								count += 1;
							}
							expandedStrings += <sname, f.name.val, count-1>;
						}
						else {
							append s;
						}
					};
					f.\value = fieldValue(newVals, f.\value.format);
				}

				append f;
			}
		};
	}

	return expanded = visit (format) {
		case struct(str name, list[Field] fields) => struct(name, expandStrings(name, fields))
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
	
	//TODO: check if all structs are excluded! Then emptylist generates error!
	return size(include) > 1 ? choiceSeq(toSet(include)) : include[0];
}

private Format normalizeSequence(Format format) {
	return top-down-break visit (format) {
			case struct(str name) => choiceSeq({fixedOrderSeq([struct(name)])})
			case optionalSeq(struct(str name)) => choiceSeq({fixedOrderSeq([struct(name)]), fixedOrderSeq([])})
			case zeroOrMoreSeq(struct(str name)) => zeroOrMoreSeq(choiceSeq({fixedOrderSeq([struct(name)])}))
			case choiceSeq(set[SequenceSymbol] symbols) => choiceSeq({ fixedOrderSeq([s]) | s <- symbols, !(fixedOrderSeq(list[SequenceSymbol] syms) := s)} + { s | s <- symbols, fixedOrderSeq(list[SequenceSymbol] syms) := s})
			case zeroOrMoreSeq(choiceSeq(set[SequenceSymbol] symbols)) => zeroOrMoreSeq(choiceSeq({ fixedOrderSeq([s]) | s <- symbols, !(fixedOrderSeq(list[SequenceSymbol] syms) := s)} + { s | s <- symbols, fixedOrderSeq(list[SequenceSymbol] syms) := s}))
			case fixedOrderSeq(list[SequenceSymbol] symbols) => choiceSeq({fixedOrderSeq(symbols)} + { s | s <- symbols, fixedOrderSeq(list[SequenceSymbol] syms) := s})
			case zeroOrMoreSeq(fixedOrderSeq(list[SequenceSymbol] symbols)) => zeroOrMoreSeq(choiceSeq({fixedOrderSeq(symbols)}))
			case optionalSeq(fixedOrderSeq(list[SequenceSymbol] symbols)) => choiceSeq({fixedOrderSeq(symbols), []})
	}
}
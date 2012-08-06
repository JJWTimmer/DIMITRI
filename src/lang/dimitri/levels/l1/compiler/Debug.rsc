module lang::dimitri::levels::l1::compiler::Debug

import IO;
import List;
import Set;
import String;

import lang::dimitri::levels::l1::AST;

map[str,str] mapping = ("*":"_");

public str generateFormat(Format format, list[FormatSpecifier] base) {
	str res = "";
	res += "format <format.name.val>\n";
	
	res += "extension";
	//for (str ext <- format.extensions) {
	for (id(ext) <- format.extensions) {
		res += " <ext>";
	}
	res += "\n\n";
	
	set[FormatSpecifier] defined = toSet(format.defaults) - toSet(base);
	bool fsWritten = false;
	res += writeFormatSpecs(toList(defined), "\n");
	if (fsWritten) {
		res += "\n";
	}
	
	res += "sequence\n";
	for (SequenceSymbol s <- format.sequence.symbols) {
		res += "  <writeSymbol(s)>\n";
	}

	res += "\n";
	res += "structures";
	for (Structure t <- format.structures) {
		res += "\n\n<t.name.val> {\n";
		for (Field f <- t.fields) {
			res += "  <writeField(f)>\n";
		}
		res += "}";
	}

	return res;
}

private str writeFormatSpecs(list[FormatSpecifier] specs, str sep) {
	res = "";
	for (fs <- specs) {
		fsWritten = true;
		if (formatSpecifier(key, val) := fs) {
			switch(key) {
				case unit() : {
					if (bit() := val) {
						res += "unit bit<sep>";
					} else if (byte() := val) {
						res += "unit byte<sep>";
					}
				}
				case sign() : {
					if (\true() := val) {
						res += "sign true<sep>";
					} else if (\false() := val) {
						res += "sign false<sep>";
					}
				}
				case endian() : {
					if (big() := val) {
						res += "endian big<sep>";
					} else if (little() := val) {
						res += "endian little<sep>";
					}
				}
				case strings() : {
					if (utf8() := val) {
						res += "strings utf8<sep>";
					} else if (ascii() := val) {
						res += "strings ascii<sep>";
					}
				}
				case \type() : {
					if (integer() := val) {
						res += "type integer<sep>";
					} else if (string() := val) {
						res += "type string<sep>";
					}
				}
			}
		} else if (variableSpecifier(key, val) := fs) {
			switch(key) {
				case size() : {
					if (number(n) := val) {
						res += "size <n><sep>";
					}
				}
			}
		}
	}
	return res;
}

private str writeField(Field f) {
	str res = escape(f.name.val, mapping);
	list[FormatSpecifier] overridden = getLocalQualifiers(f);
	if (isEmpty(overridden), fieldNoValue(_) := f) {
		res += ";";
	} else {
		res += ":";
		str exp = "";
		if (field(_, fieldValue(val, _)) := f) {
			exp = writeExpression(getOneFrom(val));
		}
		if (size(exp) > 0) {
			res += " " + exp;
		}
		overrideStr = writeFormatSpecs(overridden, " ");
		if (size(overrideStr) > 0) res += " <overrideStr>";
		res += ";";
	}
	return res;
}

private list[FormatSpecifier] getLocalQualifiers(fieldNoValue(_)) {
	return [];
}
private default list[FormatSpecifier] getLocalQualifiers(Field f) {	
	if (f has \value) {
		return for (FormatSpecifier fs <- f.\value.format) {
			if ((fs@local)?) append fs;
		}
	} else {
		return [];
	}
}

public str writeSymbol(SequenceSymbol s) {
	switch(s) {
		case struct(id(name)): return name;
		case optionalSeq(SequenceSymbol symbol): return "<writeSymbol(symbol)>?";
		case zeroOrMoreSeq(SequenceSymbol symbol): return "<writeSymbol(symbol)>*";
		case notSeq(SequenceSymbol symbol): return "!<writeSymbol(symbol)>";
		case choiceSeq(set[SequenceSymbol] symbols): return "(<("" | it + " " + symbol | sym <- symbols, symbol := writeSymbol(sym))> )";
		case fixedOrderSeq(list[SequenceSymbol] symbolSequence): return "[<("" | it + " " + symbol | sym <- symbolSequence, symbol := writeSymbol(sym))> ]";
	}
}

private str writeExpression(Scalar exp) {
	switch(exp) {
		case number(n): return "<n>";
		case string(s): return "\"<s>\"";
		case ref(id(name)): return escape(name, mapping);
		
	}
	return "";
}

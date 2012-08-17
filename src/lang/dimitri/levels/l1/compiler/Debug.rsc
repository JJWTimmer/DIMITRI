module lang::dimitri::levels::l1::compiler::Debug

import IO;
import List;
import Set;
import String;

import lang::dimitri::levels::l1::AST;
import lang::dimitri::levels::l1::compiler::SequenceSymbol2String;

map[str,str] mapping = ("*":"_");

public str debugFormat(Format format, set[FormatSpecifier] base) {
	str res = "";
	res += "format <format.name.val>\n";
	
	res += "extension";

	for (id(ext) <- format.extensions) {
		res += " <ext>";
	}
	res += "\n\n";
	
	defined = format.defaults - base;
	bool fsWritten = false;
	res += writeFormatSpecs(defined, "\n");
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

private str writeFormatSpecs(set[FormatSpecifier] specs, str sep) {
	res = "";
	for (fs <- specs) {
		fsWritten = true;
		if (formatSpecifier(key, val) := fs) {
			res += "<key> <val><sep>";
		} else if (variableSpecifier(key, val) := fs) {
			if (number(n) := val) {
				res += "<key> <n><sep>";
			} else if (ref(s) := val) {
				res += "<key> <s.val><sep>";
			}
		}
	}
	return res;
}

private str writeField(Field f) {
	res = escape(f.name.val, mapping);
	overridden = getLocalFormat(f);
	
	if (isEmpty(overridden), field(_, [], _) := f) {
		res += ";";
	} else {
		res += ":";
		str exp = "";
		
		exp = writeExpression(f.values);
		
		if (size(exp) > 0) {
			res += " " + exp;
		}
		overrideStr = writeFormatSpecs(overridden, " ");
		if (size(overrideStr) > 0) res += " <overrideStr>";
		res += ";";
	}
	return res;
}

private set[FormatSpecifier] getLocalFormat(Field f) 
  = {fs | fs <- f.format, (fs@local)?};

private str writeExpression([]) = "";
private str writeExpression([number(n)]) = "<n>";
private str writeExpression([string(s)]) = "\"<s>\"";
private str writeExpression([ref(id(name))]) = escape(name, mapping);

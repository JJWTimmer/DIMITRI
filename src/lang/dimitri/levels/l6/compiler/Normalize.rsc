module lang::dimitri::levels::l6::compiler::Normalize
extend lang::dimitri::levels::l5::compiler::Normalize;

import Node;
import util::ValueUI;

import lang::dimitri::levels::l6::AST;

public Format normalizeL6(Format format)
	= format4
	when format1 := removeMultipleExpressionsL6(format),
	format2 := removeStrings(format1),
	format2a1 := fixLengthOf(format2),
	format2a2 := removeOffset(format2a1),
	format2b := expandSpecificationL6(format2a2),
	format3 := removeNotSequence(format2b),
	format4 := sequence2dnf(format3);

private Format removeMultipleExpressionsL6(Format format) {
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
					append ret: f[name=id(getFName(i, f.name.val))][values=[c]][@parent=(i > 0 ? f.name.val : "" )];
					i += 1;
				}
			} else append f;
		};
	}

	return visit (format) {
		case s:struct(name, fields) => s[fields=expandMultipleExpressions(fields)]
	}
}

private Format expandSpecificationL6(Format format) {
	nw = visit (format) {
		case st:struct(sname, fields) => st[fields=expandSpecificationL6(sname, fields, format)]
	};
	return nw;
}

private list[Field] expandSpecificationL6(Id sname, list[Field] fields, Format format) {
	nw = [expandSpecificationL6(sname, fld, format) | fld <- fields];
	return nw;
}

private Field expandSpecificationL6(Id sname, fld:field(fname, Callback cb, _), Format format) {
	nw = fld[callback=expandSpecification(sname, fname, cb, format)];
	return nw;
}
private default Field expandSpecificationL6(Id _, Field f, Format _) = f;


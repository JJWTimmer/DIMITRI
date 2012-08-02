module lang::dimitri::levels::l1::compiler::PropagateConstants

import Set;
import List;
import Type;

import lang::dimitri::levels::l1::AST;

public Format propagateConstants(Format format) {

	rel[str s, str f, FieldSpecifier v] specMap = {<s, f, v> | struct(id(s),fs) <- format.structures, field(id(f), FieldSpecifier v) <- fs};
	
	FieldSpecifier getVal(str s, str f, FieldSpecifier fs) {
		sourceVal = specMap[s, f];
		if (size(sourceVal) == 1) {
			theValue = getOneFrom(sourceVal);
			if (theValue has values) {
				fs.values = theValue.values;
				return fs;
			}
		}
		return fieldValue(fs.format);
	}
	
	str sname = "";
	
	return outermost visit (format) {
		case struct(id(name), _) : sname = name;
		case F:field(id(fname), FV:fieldValue(values, _)) : {
			newValues = for (v <- values) {
				if (ref(source) := v) {
					F.\value = getVal(sname, source.field, FV);
					insert F;
				};
			}
		}
	}
}
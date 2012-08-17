module lang::dimitri::levels::l1::compiler::PropagateConstants

import Set;
import List;
import Type;

import lang::dimitri::levels::l1::AST;

/*
	propagate the first value of referenced fields
*/
public Format propagateConstants(Format format) {

	rel[str s, str f, Field v] specMap = {<s, f.name.val, f> | struct(id(s),fs) <- format.structures, Field f <- fs};
	
	Scalar getVal(str s, str f, Scalar originalValue) {
		sourceField = specMap[s, f];
		if ([theField] := sourceField, [val] := theField.values) {
			return val;
		}
		return originalValue;
	}
	
	list[Scalar] getVals(str s, str f, list[Scalar] originalValues) {
		return visit(originalValues) {
			case r:ref(id(source)) => getVal(s, source, r)
		}
	}
	
	str sname = "";
	
	return outermost visit (format) {
		case struct(id(name), _) : sname = name;
		case field(id(fname), values, format) : insert field(id(fname), getVals(sname, fname, values), format);
	}
}
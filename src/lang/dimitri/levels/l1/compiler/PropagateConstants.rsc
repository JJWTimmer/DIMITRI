module lang::dimitri::levels::l1::compiler::PropagateConstants

import Set;
import List;
import Type;

import lang::dimitri::levels::l1::AST;

public Format propagateConstants(Format format) {

	rel[str s, str f, Field v] specMap = {<s, f.name.val, f> | struct(id(s),fs) <- format.structures, Field f <- fs};
	
	FieldSpecifier getVal(str s, str f, FieldSpecifier fv) {
		sourceField = specMap[s, f];
		if (size(sourceField) == 1) {
			theField = getOneFrom(sourceField);
			if (theField has \value, theField.\value has values) {
				fv.values = theField.\value.values;
				return fv;
			}
			//source has no value or format, just return original value
			return fv;
		}
		//source has only a format
		return fieldValue(fv.format);
	}
	
	str sname = "";
	
	return outermost visit (format) {
		case struct(id(name), _) : sname = name;
		case F:field(id(fname), FV:fieldValue(values, _)) : {
			newValues =
				[getVal(sname, source, FV) | v <- values, ref(id(source)) := v ]
				+
				[fieldValue([v], FV.format) | v <- values, ref(_) !:= v ];

		}
	}
}
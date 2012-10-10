module lang::dimitri::levels::l1::compiler::PropagateConstants

import IO;
import Set;
import List;
import Type;

import lang::dimitri::levels::l1::AST;

anno bool Scalar@inFormat;

/*
	propagate the *first* value of referenced fields
*/
public Format propagateConstants(Format format) {
	return solve(format) {
		specMap = {<s, f.name, f> | struct(s,fs) <- format.structures, Field f <- fs};
		format = visit (format) {
			case struct(sname, fields) => propagateConstants(sname, fields, specMap)
		}
	}
}

public Structure propagateConstants(Id sname, list[Field] fields, rel[Id s, Id f, Field v] smap) =
	struct(sname, newFields)
	when newFields := visit (fields) {
		case field(fname, list[Scalar] values, format) => //typing of values because of callback
			field(fname, getVals(sname, values, smap), getVals(sname, format, smap))
	};

public list[Scalar] getVals(Id sname, list[Scalar] originalValues, rel[Id, Id, Field] specMap) =
	top-down-break visit(originalValues) {
		case [Scalar s] => getVals(sname, s, specMap)
	};
	
public set[FormatSpecifier] getVals(Id sname, set[FormatSpecifier] format, rel[Id, Id, Field] specMap) =
	top-down-break visit(format) {
		case Scalar s => getVals(sname, s[@inFormat=true], specMap)[0] 
	};

public list[Scalar] getVals(Id sname, r:ref(source), rel[Id, Id, Field] specMap)
	= theField.values
	when {theField} := specMap[sname, source],
	theField has values,
	size(theField.values) == 1,
	(!r@inFormat?) || (r@inFormat? && allowedInSize(theField.values[0]));
public default list[Scalar] getVals(Id _, Scalar original, rel[Id, Id, Field] _) = [original];

public bool allowedInSize(number(_)) = true;
public bool allowedInSize(ref(_)) = true;

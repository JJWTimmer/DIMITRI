module lang::dimitri::levels::l1::compiler::PropagateConstants

import IO;
import Set;
import List;
import Type;

import lang::dimitri::levels::l1::AST;

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
		case field(fname, list[Scalar] values, format) =>
			field(fname, getVals(sname, values, smap), getVals(sname, format, smap))
	};

public list[Scalar] getVals(Id sname, list[Scalar] originalValues, rel[Id, Id, Field] specMap) =
	visit(originalValues) {
		case [Scalar s] => getVals(sname, s, specMap)
	};
	
public set[FormatSpecifier] getVals(Id sname, set[FormatSpecifier] format, rel[Id, Id, Field] specMap) =
	visit(format) {
		case Scalar s => val when [val] := getVals(sname, s, specMap) 
	};

public list[Scalar] getVals(Id sname, ref(source), rel[Id, Id, Field] specMap) = theField.values when
	{theField} := specMap[sname, source],
	theField has values;
public default list[Scalar] getVals(Id _, Scalar original, rel[Id, Id, Field] _) = [original];
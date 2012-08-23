module lang::dimitri::levels::l1::compiler::PropagateConstants

import Set;
import List;
import Type;

import lang::dimitri::levels::l1::AST;

/*
	propagate the first value of referenced fields
*/
public Format propagateConstants(Format format) {

	rel[Id s, Id f, Field v] specMap = {<s, f.name, f> | struct(s,fs) <- format.structures, Field f <- fs};
	
	Id sname = id("");
	
	return outermost visit (format) {
		case struct(name, _) : sname = name;
		case field(fname, values, format) : insert field(fname, getVals(sname, values, specMap), format);
	}
}

public list[Scalar] getVals(Id sname, list[Scalar] originalValues, rel[Id, Id, Field] specMap) {
	return visit(originalValues) {
		case Scalar s => getVals(sname, s, specMap)
	}
}

public list[Scalar] getVals(Id sname, ref(source), rel[Id, Id, Field] specMap) = val when
	sourceField := specMap[sname, source],
	[theField] := sourceField,
	[val] := theField.values;
public default list[Scalar] getVals(Id _, Scalar original, rel[Id, Id, Field] _) = original;

module lang::dimitri::levels::l1::compiler::PropagateConstants

import Set;
import List;
import Type;

import lang::dimitri::levels::l1::AST;

/*
	propagate the *first* value of referenced fields
*/
public Format propagateConstants(Format format) =
	visit (format) {
		case struct(sname, fields) => propagateConstants(sname, fields, specMap)
	}
	when specMap := {<s, f.name, f> | struct(s,fs) <- format.structures, Field f <- fs};

public Structure propagateConstants(Id sname, list[Field] fields, rel[Id s, Id f, Field v] smap) =
	struct(sname, newFields)
	when newFields := visit (fields) {
		case field(fname, values, format) => field(fname, getVals(sname, values, smap), format)
	};

public list[Scalar] getVals(Id sname, list[Scalar] originalValues, rel[Id, Id, Field] specMap) =
	visit(originalValues) {
		case Scalar s => getVals(sname, s, specMap)
	};

public Scalar getVals(Id sname, ref(source), rel[Id, Id, Field] specMap) = val when
	sourceField := specMap[sname, source],
	{theField} := sourceField,
	[val] := theField.values;
public default Scalar getVals(Id _, Scalar original, rel[Id, Id, Field] _) = original;

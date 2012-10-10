module lang::dimitri::levels::l6::compiler::PropagateConstants
extend lang::dimitri::levels::l5::compiler::PropagateConstants;

import lang::dimitri::levels::l6::AST;
import Node;

anno Id Id@field;
anno bool Id@format;

public Format propagateConstantsL6(Format format) {
	return solve(format) {
		specMap = {<s, f.name, f> | struct(s,fs) <- format.structures, Field f <- fs};
		format = visit (format) {
			case struct(sname, fields) => propagateConstantsL6(sname, fields, specMap)
			case Scalar s => fold(s)
		}
	}
}

public Structure propagateConstantsL6(Id sname, list[Field] fields, rel[Id s, Id f, Field v] smap) =
	struct(sname, newFields)
	when newFields := visit (fields) {
		//typing of values to differentiate from Callback-fields
		case fld:field(fname, list[Scalar] values, format) => 
			fld[values=getValsL5(sname[@field=fname], values, smap)][format=getValsL6(sname[@field=fname][@format=true], format, smap)]
	};

public set[FormatSpecifier] getValsL6(Id sname, set[FormatSpecifier] format, rel[Id, Id, Field] specMap) =
	top-down-break visit(format) {
		case v:variableSpecifier(k, s) => v[var=getValsL5(sname, s[@inFormat=true], specMap)]
	};
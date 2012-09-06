module lang::dimitri::levels::l3::compiler::Normalize
extend lang::dimitri::levels::l1::compiler::Normalize;

import lang::dimitri::levels::l3::AST;

public Format normalizeL3(Format format) = format4 when
	format1 := removeMultipleExpressions(format),
	format2 := removeStrings(format1),
	format2b := expandSpecification(format2),
	format3 := removeNotSequence(format2b),
	format4 := sequence2dnf(format3);

private Format expandSpecification(Format format)
	= visit (format) {
		case struct(sname, fields) => expandSpecification(sname, fields, format)
	};

private Structure expandSpecification(Id sname, list[Field] fields, Format format) = struct(sname, [expandSpecification(sname, fld, format) | fld <- fields]);

private Field expandSpecification(Id sname, field(fname, cb, fmt), Format format) = field(fname, expandSpecification(sname, fname, cb, format), fmt); 
private default Field expandSpecification(Field f) = f; 

private Callback expandSpecification(Id sname, Id fname, Callback cb, Format format) = visit(cb) {
		case list[Scalar] ss => expandSpecification(sname, fname, ss, format)
	};

private list[Scalar] expandSpecification(Id sname, Id fname, list[Scalar] ss, Format format) = [*expandSpecification(sname, fname, scal, format) | scal <- ss];

private list[Scalar] expandSpecification(Id sname, Id fname, ref(sourceField), Format format) 
	= getFieldlist(sname, sourceField, format);
private list[Scalar] expandSpecification(Id sname, Id fname, crossRef(sourceStruct, sourceField), Format format)  
	= getFieldlist(sourceStruct, sourceField, format);
private default list[Scalar]  expandSpecification(Id sname, Id fname, Scalar s, Format format) = [s];

private list[Scalar] getFieldlist(Id sname, Id fname, Format format) {
	list[Field] res = [];
	visit (format) {
		case struct(sname, fields) : {
			res = getFields(fname.val, fields);
		} 
	}
	
	return [crossRef(sname, fld.name) | fld <- res];
	
	throw "no fields match";
}

private list[Field] getFields(str fname, list[Field] fields)
	= [f | f <- fields, ( (/<fname>/ := f.name.val) || (/<fname.val>\*.+/ := f.name.val) )];
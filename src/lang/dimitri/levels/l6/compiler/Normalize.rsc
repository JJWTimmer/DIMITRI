module lang::dimitri::levels::l6::compiler::Normalize
extend lang::dimitri::levels::l5::compiler::Normalize;

import Node;

import lang::dimitri::levels::l6::AST;

public Format normalizeL6(Format format) = format4 when
	format1 := removeMultipleExpressions(format),
	format2 := removeStrings(format1),
	format2b := expandSpecificationL6(format2),
	format3 := removeNotSequence(format2b),
	format4 := sequence2dnf(format3);

private Format expandSpecificationL6(Format format)
	= visit (format) {
		case struct(sname, fields) => expandSpecificationL6(sname, fields, format)
	};

private Structure expandSpecificationL6(Id sname, list[Field] fields, Format format)
	= struct(sname, [expandSpecificationL6(sname, fld, format) | fld <- fields]);

private Field expandSpecificationL6(Id sname, fld:field(fname, Callback cb, fmt), Format format)
	= setAnnotations(field(fname, expandSpecification(sname, fname, cb, format), fmt), annos)
	when annos := getAnnotations(fld); 
private default Field expandSpecificationL6(Id _, Field f, Format _) = f;


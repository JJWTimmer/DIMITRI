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

private Structure expandSpecification(Id sname, list[Field] fields, Format format)
	= struct(sname, [expandSpecification(sname, fld, format) | fld <- fields]);

private Field expandSpecification(Id sname, field(fname, Callback cb, fmt), Format format)
	= field(fname, expandSpecification(sname, fname, cb, format), fmt); 
private default Field expandSpecification(Id _, Field f, Format _) = f; 

private Callback expandSpecification(Id sname, Id fname, Callback cb, Format format)
	= visit (cb) {
		case list[Argument] as => expandSpecification(sname, fname, as, format) when [] !:= as
	};

private list[Argument] expandSpecification(Id sname, Id fname, list[Argument] as, Format format)
	= [*expandSpecification(sname, fname, arg, format) | arg <- as];

private list[Argument] expandSpecification(Id sname, Id fname, r:refArg(sourceField), Format format) 
	= selectVal(ls, r)
	when ls := getFieldlist(sname, sourceField, format);
private list[Argument] expandSpecification(Id sname, Id fname, cr:crossRefArg(sourceStruct, sourceField), Format format)  
	= selectVal(ls, cr)
	when ls := getFieldlist(sourceStruct, sourceField, format);
private default list[Argument]  expandSpecification(Id _, Id _, Argument s, Format _) = [s];

private list[Argument] selectVal(list[Argument] ls, Argument arg) = isEmpty(ls) ? [arg] : ls;

private list[Argument] getFieldlist(Id sname, Id fname, Format format) {
	list[Field] res = [];
	visit (format) {
		case struct(sname, fields) : {
			res = getFields(fname.val, res);
		} 
	}

	return [crossRefArg(sname, fld.name) | fld <- res];
}

private list[Field] getFields(str fname, list[Field] fields)
	= [f | f <- fields, fname == f.name.val] + [f | f <- fields, f@parent?, f@parent == fname];
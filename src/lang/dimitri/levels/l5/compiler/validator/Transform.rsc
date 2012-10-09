module lang::dimitri::levels::l5::compiler::validator::Transform
extend lang::dimitri::levels::l4::compiler::validator::Transform;

import lang::dimitri::levels::l5::compiler::Annotate;

import lang::dimitri::levels::l5::AST;

data EType = size();

public Validator getValidatorL5(Format format)
	= validator(
		toUpperCase(format.name.val) + "Validator",
		format.name.val,
		getGlobalsL5(format),
		getStructuresL5(format));

public list[Global] getGlobalsL5(Format format) {
	list[Global] globals = [];
	
	top-down visit(format) {
		case struct(id(sn), fields) : globals = getGlobalsL5(sn, fields, globals);
	}

	return globals;
}

public list[Global] getGlobalsL5(str sname, list[Field] fields, list[Global] globals) =  globals + [*getGlobalsL5(fld, sname) | fld <- fields];

public default list[Global] getGlobalsL5(Field fld, str sname) {
	list[Global] res = [];
	fname = fld.name.val;
	
	if ((fld@ref)?, global() := fld@ref) {
		if (isVariableSize(fld)) {
			bufName = "<sname>_<fname>";
			res += gdeclB(bufName);
		} else {
			valName = "<sname>_<fname>";
			t = makeType(fld);
			res += gdeclV(t, valName);
		}
	}
	
	if ((fld@size)?, global() := fld@size) {
		if (isVariableSize(fld)) {
			lenName = "<sname>_<fname>_len";
			lenType = integer(true, little(), 31);
			res += gdeclV(lenType, lenName);
		}
	}
	
	return res;
}

public list[Structure] getStructuresL5(Format format) {
	list[Structure] structures = [];
	str sname = "";
	FRefs frefs = getFRefs(format);

	for (struct <- format.structures) {
		sname = struct.name.val;
		list[Statement] statements = [];
		for (field <- struct.fields) {
			statements += field2statementsL5(sname, field, frefs, format);
		}
		structures += structure(sname, statements);
	}
	return structures;
}

public list[Statement] field2statementsL5 (str sname, Field field, FRefs frefs, Format format) = variableSizeFields2statementsL5(sname, field, frefs) when field has values, isVariableSize(field);
public list[Statement] field2statementsL5 (str sname, Field field, FRefs frefs, Format format) = fixedSizefields2statementsL5(sname, field, frefs) when field has values, !isVariableSize(field);
public list[Statement] field2statementsL5 (str sname, Field field, FRefs frefs, Format format) = callbackFields2statementsL5(sname, field, frefs, format) when field has callback;

public VValue generateScalar(str struct, lengthOf(ref(id(fname))))
	= var("<struct>_<fname>_len");
public VValue generateScalar(str struct, lengthOf(crossRef(id(sname), id(fname))))
	= var("<sname>_<fname>_len");
	
public list[Statement] variableSizeFields2statementsL5 (str sname, Field field, FRefs frefs) {
	list[Statement] statements = [];
	fname = escape(field.name.val, mapping);

	str lenName = "<sname>_<fname>_len";
	Type lenType = integer(true, littleE(), 31);
	if (!field@size? || (field@size? && global() !:= field@size) )
		statements += ldeclV(lenType, lenName);
	Scalar sourceSizeField;
	if (/variableSpecifier("size", val) := field.format) sourceSizeField = val;
	str relType;
	if (/formatSpecifier("type", val) := field.format) relType = val;
	relativeSize = (relType == "byte") ? bytes(generateScalar(sname, sourceSizeField)) : bits(generateScalar(sname, sourceSizeField));
	statements += calc(lenName, relativeSize);
	
	for (Statement s <- frefs[sname,fname,size()]) statements += s;
	
	if ((field@ref)?) {
		str bufName = "<struct>_<name>";
		if (global() := field@ref)
			globals += gdeclB(bufName);
		else
			statements += ldeclB(bufName);
		statements += readBuffer(lenName, bufName);
	} else {
		statements += skipBuffer(lenName);
	}
	return statements;
}

public list[Statement] fixedSizefields2statementsL5 (str sname, Field field, FRefs frefs) {
	list[Statement] statements = [];
	fname = escape(field.name.val, mapping);
	Type t = makeType(field);
	if (!field@ref? && !field@refdep? && !field@sizedep? && !hasValueSpecification(field)) {
		statements += skipValue(t);
	} else {
		str valName = "<sname>_<fname>";
		if (!(field@ref)? || local() := field@ref) statements += ldeclV(t, valName);
		statements += readValue(t, valName);
		if (hasValueSpecification(field)) {
			validateStatement = validate(valName, [*generateScalar(sname, field.values[0])]);
			if (field@refdep? && dependency(depName) := field@refdep)
				frefs += <sname, depName, \value(), validateStatement>;
			else if (field@sizedep? && dependency(depName) := field@sizedep)
				frefs += <sname, depName, size(), validateStatement>;
			else
				statements += validateStatement;
		}
		statements += toList(frefs[sname,fname,\value()]);
	}
	
	return statements;
}

public list[Statement] callbackFields2statementsL5 (str sname, f:field(id(fnameraw), Callback cb, set[FormatSpecifier] fieldFormat), FRefs frefs, Format format) {
	list[Statement] statements = [];
	fname = escape(fnameraw, mapping);
	
	map[str, str] custom = getCustomArguments(cb.parameters);
	map[str, list[VValue]] references = getReferences(cb.parameters, sname);

	str valName = "<sname>_<fname>";
	if ( !(f@ref)? || ((f@ref)? && global() !:= f@ref) ) statements += ldeclB(valName);
	// handles @size=none/local()/global()
	lenName = "<sname>_<fname>_len";
	lenType = integer(true, littleE(), 31);
	if (!f@size? || (f@size? && global() !:= f@size))
		statements += ldeclV(lenType, lenName);
	
	if (hasLocalSize(f)) {
		// handles size=\value(int) or Expression and @refdep=dependency(str)
		// @sizedep is not allowed since lengthOf() and offset() are not allowed in expressions in ContentSpecifier arguments
		//Expression sizeExp = (qualifiers[0].name == "byte") ? times(qualifiers[5].count, \value(8)) : qualifiers[5].count;
		Scalar fieldSize;
		if (/variableSpecifier("size", val) := f.format)
			fieldSize = val;
		statements += calc(lenName, generateScalar(sname, fieldSize));
		for (Statement s <- frefs[sname,fname,size()])
			statements += s;
		validateStatement = validateContent(valName, lenName, cb.fname.name.val, custom, references, false);
		if (!(f@refdep)? || ((f@refdep)? && dependency(_) !:= f@refdep))
			statements += validateStatement;
	} else {
		// handles size=undefined
		// no forward references are allowed since the content analysis must run order to reach following fields
		statements += calc(lenName, con(0));
		statements += validateContent(valName, lenName, cb.fname.name.val, custom, references, lastField(format, sname, fname));
	}
	return statements;
}
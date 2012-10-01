module lang::dimitri::levels::l1::compiler::validator::Transform

import IO;
import util::Maybe;
import List;
import Set;
import String;
//import util::ValueUI;

import lang::dimitri::levels::l1::AST;
import lang::dimitri::levels::l1::compiler::Annotate;
import lang::dimitri::levels::l1::compiler::validator::ADT;

data EType = \value();

map[str,str] mapping = ("*":"_");

alias FRefs = rel[str,str,EType,Statement];
alias FRef  = tuple[str,str,EType,Statement];

public list[Structure] getStructures(Format format) {
	list[Structure] structures = [];
	str sname = "";
	FRefs frefs = getFRefs(format);

	for (struct <- format.structures) {
		sname = struct.name.val;
		list[Statement] statements = [];
		for (field <- struct.fields) {
			statements += field2statements(sname, field, frefs, format);
		}
		structures += structure(sname, statements);
	}
	return structures;
}

public FRefs getFRefs(Format format) {
	str sname = "";
	FRefs frefs = {};
	
	top-down visit (format) {
		case Structure s : frefs = getFRefs(s, frefs);
	}
	
	return frefs;
}

public FRefs getFRefs( Structure::struct(id(sname), list[Field] fields),FRefs frefs) = frefs + {*getFRefs(fld, sname) | fld <- fields};

public FRefs getFRefs(fld:field(id(fname), list[Scalar] vals, set[FormatSpecifier] _), str sname) {
	FRefs res = {};
	if (!isVariableSize(fld), (fld@refdep)?, dependency(str depName) := fld@refdep ) {
		valName = "<sname>_<fname>";
		validateStatement = validate(valName, [*generateScalar(sname, vals[0])]);
		res += <sname, depName, \value(), validateStatement>;
	}
	
	return res;
}

public default FRefs getFRefs(Field fld, FRefs frefs, str sname) {
	throw "Unexpected field type: <fld>";
}

public bool hasValueSpecification(field(_, [],_)) {
	return false;
}
public default bool hasValueSpecification(Field _) {
	return true;
}

public bool hasLocalSize(Field field) {
	if (/s:variableSpecifier("size", _) := field.format) {
		return ((s@local)? && s@local);
	}
	return false;
}

public bool isVariableSize(Field f) {
	return !(/variableSpecifier("size", number(_)) := f.format);
}

public Type makeType(Field f) {
	
	Scalar size;
	if (/variableSpecifier("size", val) := f.format) size = val;
	str unit;
	if (/formatSpecifier("unit", val) := f.format) unit = val;
	int bitLength = size.number * ((unit == "byte") ? 8 : 1);
	
	str endn;
	if (/formatSpecifier("endian", val) := f.format) endn = val;
	Endianness endian = (endn == "little") ? littleE() : bigE();
	
	str sgn;
	if (/formatSpecifier("sign", val) := f.format) sgn = val;
	bool sign = ( sgn == "true" ) ? true : false;
	
	str vtype;
	if (/formatSpecifier("type", val) := f.format) vtype = val;
	if (vtype in {"integer", "string"}) return integer(sign, endian, bitLength);
	
	throw "Unsupported type";
}

public VValue generateScalar(str struct, ref(id(name))) = var("<struct>_<name>");
public VValue generateScalar(str struct, number(int i)) = con(i);

public list[Statement] field2statements (str sname, Field field, FRefs frefs, Format format) = variableSizeFields2statements(sname, field, frefs) when field has values, isVariableSize(field);
public list[Statement] field2statements (str sname, Field field, FRefs frefs, Format format) = fixedSizefields2statements(sname, field, frefs) when field has values, !isVariableSize(field);

public list[Statement] variableSizeFields2statements (str sname, Field field, FRefs frefs) {
	list[Statement] statements = [];
	fname = escape(field.name.val, mapping);

	str lenName = "<sname>_<fname>_len";
	Type lenType = integer(true, littleE(), 31);
	statements += ldeclV(lenType, lenName);
	Scalar sourceSizeField;
	if (/variableSpecifier("size", val) := field.format) sourceSizeField = val;
	str relType;
	if (/formatSpecifier("type", val) := field.format) relType = val;
	relativeSize = (relType == "byte") ? bytes(generateScalar(sname, sourceSizeField)) : bits(generateScalar(sname, sourceSizeField));
	statements += calc(lenName, relativeSize);
	
	if ((field@ref)?) {
		str bufName = "<sname>_<fname>";
		if (local() := field@ref) statements += ldeclB(bufName);
		statements += readBuffer(lenName, bufName);
	} else {
		statements += skipBuffer(lenName);
	}
	return statements;
}

public list[Statement] fixedSizefields2statements (str sname, Field field, FRefs frefs) {
	list[Statement] statements = [];
	fname = escape(field.name.val, mapping);
	Type t = makeType(field);
	if (!(field@ref)? && !hasValueSpecification(field)) {
		statements += skipValue(t);
	} else if (!(field@ref)?, !(field@refdep)?, !hasValueSpecification(field)) {
		statements += skipValue(t);
	} else {
		str valName = "<sname>_<fname>";
		if (!(field@ref)? || local() := field@ref) statements += ldeclV(t, valName);
		statements += readValue(t, valName);
		if (hasValueSpecification(field), ( !(field@refdep)? || ((field@refdep)? && dependency(str _) !:= field@refdep) ) ) {
			statements += validate(valName, [*generateScalar(sname, field.values[0])]);
		}
		statements += toList(frefs[sname,fname,\value()]);
	}
	
	return statements;
}

public Validator getValidator(Format format)
	= validator(toUpperCase(format.name.val) + "Validator", format.name.val, getStructures(format));

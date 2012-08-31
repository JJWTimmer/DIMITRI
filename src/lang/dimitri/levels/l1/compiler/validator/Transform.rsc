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

data EType = \value() | size();

map[str,str] mapping = ("*":"_");

alias FRefs = rel[str,str,EType,Statement];

public list[Structure] getStructures(Format format) {
	list[Structure] structures = [];
	str sname = "";
	FRefs frefs = getFRefs(format);

	for (struct <- format.structures) {
		sname = struct.name.val;
		list[Statement] statements = [];
		for (field <- struct.fields) {
			statements += field2statements(sname, field, frefs);
		}
		structures += structure(sname, statements);
	}
	return structures;
}

public FRefs getFRefs(Format format) {
	str sname = "";
	FRefs frefs = {};
	
	top-down visit (format) {
		case struct(id(sn)) : sname = sn; 
		case fld:field(id(fname), values, _) : {
			if (!isVariableSize(fld), (fld@refdep)?, dependency(str depName) := fld@refdep ) {
				valName = "<sname>_<fname>";
				validateStatement = validate(valName, [generateScalar(sname, values[0])]);
				frefs += <sname, depName, \value(), validateStatement>;
			}
		}
	}
	
	return frefs;
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
public default VValue generateScalar(str struct, x) { throw "generateScalar: unknown Scalar type: <x>"; }

public list[Statement] field2statements (str sname, Field field, FRefs frefs) = variableSizeFields2statements(sname, field, frefs) when isVariableSize(field);
public list[Statement] field2statements (str sname, Field field, FRefs frefs) = fixedSizefields2statements(sname, field, frefs) when !isVariableSize(field);

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
	relativeSize = (relType == "byte") ? bytes(generateScalar(sname, sourceSizeField).name) : bits(generateScalar(sname, sourceSizeField).name);
	statements += calc(lenName, relativeSize);
	
	for (Statement s <- frefs[sname,fname,size()]) statements += s;
	
	if ((field@ref)?) {
		str bufName = "<sname>_<fname>";
		if (local := field@ref) statements += ldeclB(bufName);
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
			statements += validate(valName, [generateScalar(sname, field.values[0])]);
		}
		statements += toList(frefs[sname,fname,\value()]);
	}
	
	return statements;
}




public Validator getValidator(Format format) = validator(toUpperCase(format.name.val) + "Validator", format.name.val, getStructures(format));

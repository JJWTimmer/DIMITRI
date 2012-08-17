module lang::dimitri::levels::l1::compiler::validator::Build


import IO;
import util::ValueUI;
import util::Maybe;
import List;
import Set;
import String;

import lang::dimitri::levels::l1::AST;
import lang::dimitri::levels::l1::compiler::Annotate;
import lang::dimitri::levels::l1::compiler::validator::ADT;
import lang::dimitri::levels::l1::util::FormatHelper;

data EType = \value() | size();

map[str,str] mapping = ("*":"_");

@doc{Produce an ADT (Validator) based on a provided AST (FileFormat).}
public Validator build(Format format) {
	list[Structure] structures = [];
	list[Statement] statements = [];
	str struct = "";
	rel[str,str,EType,Statement] frefs = {};
	
	void buildStatements(f: Field) {
		name = escape(f.name.val, mapping);
		if (isVariableSize(f)) {
			// handles value=noValue(), size=Expression, @ref=none/local()/global(), @size=none/local()/global()
			// when size=Expression, value *must* be noValue() and @refdep and @sizedep are forbidden
			str lenName = "<struct>_<name>_len";
			Type lenType = integer(true, littleE(), 31);
			statements += ldeclV(lenType, lenName);
			//Expression sizeExp = (qualifiers[0].name == "byte") ? times(qualifiers[5].count, \value(8)) : qualifiers[5].count;
			//statements += calc(lenName, generateExpression(struct, sizeExp));
			statements += calc(lenName, generateScalar(struct, getSFSScalar(f.format, "size").val.nmbr));
			for (Statement s <- frefs[struct,name,size()]) statements += s;
			if ((f@ref)?) {
				str bufName = "<struct>_<name>";
				statements += ldeclB(bufName);
				statements += readBuffer(lenName, bufName);
			} else {
				statements += skipBuffer(lenName);
			}
		} else {
			Type t = makeType(format.defaults, f);
			if (!(f@ref)? && !hasValueSpecification(f)) {
				statements += skipValue(t);
			} else if (!(f@ref)? && !(f@refdep)? && !hasValueSpecification(f)) {
				statements += skipValue(t);
			} else {
				str valName = "<struct>_<name>";
				statements += ldeclV(t, valName);
				statements += readValue(t, valName);
				if (hasValueSpecification(f)) {
					Statement validateStatement = validate(valName, [generateScalar(struct, f.values)]);
					if ((f@refdep)? && dependency(str depName) := f@refdep) frefs += <struct, depName, \value(), validateStatement>;
					else statements += validateStatement;		
				}
				for (Statement s <- frefs[struct,name,\value()]) statements += s;
			}
		}
	}	

	for (s <- format.structures) {
		struct = s.name.val;
		statements = [];
		for (f <- s.fields) {
			buildStatements(f);
		}
		structures += structure(s.name.val, statements);
	}

	return validator(toUpperCase(format.name.val) + "Validator", format.name.val, structures);
}

private bool hasValueSpecification(field(_, [],_)) {
	return false;
}
private default bool hasValueSpecification(Field _) {
	return true;
}
private default bool hasValueSpecification(Field f) {
	return true;
}

private bool hasLocalSize(Field field) {
	if (field has \value) {
		if (/s:variableSpecifier(size(), _) := field.\value.format) {
			return ((s@local)? && s@local);
		}
	}
	return false;
}

private bool isVariableSize(Field f) {
	if (f has \value) {
		return !(/variableSpecifier(size(), number(_)) := f.\value.format);
	}
	return false;
}

private Type makeType(SFS defaults, Field f) {
	sfs = (f.format != {}) ? f.format : getDefaultSFS(defaults);
	
	Maybe[Scalar] size = getSFSScalar(sfs, "size");
	unit = getSFSString(sfs, "unit");
	int bitLength = size.val.number * ((unit.val == "byte") ? 8 : 1);
	
	endn = getSFSString(sfs, "endian");
	Endianness endian = (endn.val == "little") ? littleE() : bigE();
	
	sgn = getSFSString(sfs, "sign");
	bool sign = ( sgn.val == "true" ) ? true : false;
	
	vtype = getSFSString(sfs, "type");
	if (vtype.val in {"integer", "string"}) return integer(sign, endian, bitLength);
	
	throw "Unsupported type";
}

private VValue generateScalar(str struct, [ref(id(name))]) = var("<struct>_<name>");
private VValue generateScalar(str struct, [number(int i)]) = con(i);
private default VValue generateScalar(str struct, [x]) { throw "generateScalar: unknown Scalar type"; }

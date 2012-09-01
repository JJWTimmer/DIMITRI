module lang::dimitri::levels::l3::compiler::validator::Transform
extend lang::dimitri::levels::l2::compiler::validator::Transform;

import lang::dimitri::levels::l3::compiler::validator::ADT;
import lang::dimitri::levels::l3::AST;

public list[Statement]  callbackFields2statements(str sname, f:field(id(fnameraw), Callback cb, set[FormatSpecifier] fieldFormat), FRefs frefs, Format format) {
	list[Statement] statements = [];
	fname = escape(fnameraw, mapping);
	
	map[str, str] custom = ();
	map[str, list[VValue]] references = ();
	for (parameter(id(key), set[Scalar] vals)  <- cb.parameters) {
		custom += (key : val | string(val) <- vals );
		specs = [generateSpecification(sname, val) | Scalar val <- vals, string(_) !:= val];
		references += (key : specs);
	}

	str valName = "<sname>_<fname>";
	if ( !(f@ref)? || ((f@ref)? && global() !:= f@ref) ) statements += ldeclB(valName);
	// handles @size=none/local()/global()
	lenName = "<sname>_<fname>_len";
	lenType = integer(true, littleE(), 31);
	statements += ldeclV(lenType, lenName);
	
	if (hasLocalSize(f)) {
		// handles size=\value(int) or Expression and @refdep=dependency(str)
		// @sizedep is not allowed since lengthOf() and offset() are not allowed in expressions in ContentSpecifier arguments
		//Expression sizeExp = (qualifiers[0].name == "byte") ? times(qualifiers[5].count, \value(8)) : qualifiers[5].count;
		Scalar fieldSize;
		if (/variableSpecifier("size", val) := f.format) fieldSize = val;
		statements += calc(lenName, generateScalar(sname, fieldSize));
		for (Statement s <- frefs[sname,fname,size()]) statements += s;
		validateStatement = validateContent(valName, lenName, cb.fname.name.val, custom, references, false);
		if (!(f@refdep)? || ((f@refdep)? && dependency(_) !:= f@refdep)) statements += validateStatement;
	} else {
		// handles size=undefined
		// no forward references are allowed since the content analysis must run order to reach following fields
		statements += calc(lenName, con(0));
		statements += validateContent(valName, lenName, cb.fname.name.val, custom, references, lastField(format, sname, fname));
	}
	return statements;
}

private VValue generateSpecification(str struct, number(int i)) = con(i);
private VValue generateSpecification(str struct, ref(id(fname))) = var("<struct>_<escape(fname, mapping)>");
private VValue generateSpecification(str struct, crossRef(id(sname), id(fname))) = var("<sname>_<escape(fname, mapping)>");
private default VValue generateSpecification(str _, Scalar s) {
	throw "generateSpecification: unknown Specification <s>";
}

private bool lastField(Format format, str sname, str fname) {
	for (s <- format.structures, s.name.val == sname) {
		for (i <- [0..size(s.fields)-1]) {
			if (s.fields[i].name.val == fname, i+1 == size(s.fields)) {
				return true;
			}
		}
	}
	return false;
}

public FRefs getFRefs(fld:field(id(fname), Callback cb, set[FormatSpecifier] _), str sname) {
	FRefs frefs = {};
	if (hasLocalSize(fld), (fld@refdep)?, dependency(str depName) := fld@refdep ) {
		valName = "<sname>_<fname>";
		lenName = "<sname>_<fname>_len";
		validateStatement = validateWithCallback(valName, lenName, cb.fname.name.val, custom, references, false);
		frefs += frefs += <sname, depName, \value(), validateStatement>;
	}
	
	return frefs;
}

public list[Global] getGlobals(fld:field(id(fname), Callback cb, set[FormatSpecifier] format), str sname) {
	list[Global] res = [];
	if ((fld@ref)?, global() := fld@ref) {
		bufName = "<sname>_<fname>";
		res += gdeclB(bufName);
	}
	return res;
}

public list[Statement] field2statements (str sname, Field field, FRefs frefs, Format format) = callbackFields2statements(sname, field, frefs, format) when field has callback;

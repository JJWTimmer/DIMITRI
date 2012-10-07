module lang::dimitri::levels::l6::prettyPrinting::Format2box
extend lang::dimitri::levels::l5::prettyPrinting::Format2box;

import Node;

import lang::dimitri::levels::l6::AST;

public Box field2box(fieldRaw(id(fname), fieldTerminatedBy(Callback cb, format)))
	= H([
		VAR(L(escape(fname, mapping))),
		L(": terminatedBy "),
		H([
			callback2box(cb),
			H([
				*hsepList(format, " ", format2box)
			])[@hs=0]
		])[@hs=1],
		L(";")
	])[@hs=0];
	

public Box field2box(fieldRaw(id(fname), fieldTerminatedBefore(Callback cb, format)))
	= H([
		VAR(L(escape(fname, mapping))),
		L(": terminatedBefore "),
		H([
			callback2box(cb),
			H([
				*hsepList(format, " ", format2box)
			])[@hs=0]
		])[@hs=1],
		L(";")
	])[@hs=0];
	
public Box field2box(fieldRaw(id(fname), fieldTerminatedBefore(list[Scalar] values, format)))
	= H([
		VAR(L(escape(fname, mapping))),
		L(": terminatedBefore "),
		H([
			H([
				*hsepList(values, ", ", scalar2box)
			])[@hs=0],
			H([
				*hsepList(format, " ", format2box)
			])[@hs=0]
		])[@hs=1],
		L(";")
	])[@hs=0];

public Box field2box(fieldRaw(id(fname), fieldTerminatedBy(list[Scalar] values, format)))
	= H([
		VAR(L(escape(fname, mapping))),
		L(": terminatedBy "),
		H([
			H([
				*hsepList(values, ", ", scalar2box)
			])[@hs=0],
			H([
				*hsepList(format, " ", format2box)
			])[@hs=0]
		])[@hs=1],
		L(";")
	])[@hs=0];


public Box field2box(Field fld) = terminatorfield2box(fld) when fld has values, fld@terminator?;
public Box field2box(Field fld) = terminatorcallbackfield2box(fld) when fld has callback, fld@terminator?;

public Box terminatorfield2box(Field fld) {	
	str comment = "/* ";
	
	bool annos = false;
	
	annomap = getAnnotations(fld);
	for (an <- annomap) {
		if (an != "location" && an != "terminator") {
			annos = true;
			comment += " <an>=<annomap[an]>";
		}
	}
	
	comment += " */";
	
	terminator = "terminatedBy";
	if (before() := fld@terminator)
		terminator = "terminatedBefore";
	
	return H([
		VAR(L(escape(fld.name.val, mapping))),
		L(": <terminator> "),
		H([
			H([
				*hsepList(fld.values, ", ", scalar2box)
			])[@hs=0],
			H([
				*hsepList(getLocalFormat(fld.format), " ", format2box)
			])[@hs=0]
		])[@hs=1],
		L(";")
	] + (annos ? [COMM(L(comment))] : [])
	)[@hs=0];
}


public Box terminatorcallbackfield2box(Field fld) {	
	str comment = "/* ";
	
	bool annos = false;
	
	annomap = getAnnotations(fld);
	for (an <- annomap) {
		if (an != "location" && an != "terminator") {
			annos = true;
			comment += " <an>=<annomap[an]>";
		}
	}
	
	comment += " */";
		
	terminator = "terminatedBy";
	if (before() := fld@terminator)
		terminator = "terminatedBefore";
		
	return H([
		VAR(L(escape(fname, mapping))),
		L(": <terminator> "),
		H([
			callback2box(cb),
			H([
				*hsepList(getLocalFormat(format), " ", format2box)
			])[@hs=0]
		])[@hs=1],
		L(";")
	] + (annos ? [COMM(L(comment))] : [])
	)[@hs=0];
}

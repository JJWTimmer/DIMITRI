module lang::dimitri::levels::l6::prettyPrinting::Format2box
extend lang::dimitri::levels::l5::prettyPrinting::Format2box;

import Node;

import lang::dimitri::levels::l6::AST;

public Box format2boxL6(Format f) =
  V([
    formatheader2box(f.name, f.extensions),
    defaults2box(f.defaults),
    sequence2box(f.sequence.symbols),
    structs2boxL6(f.structures)
  ])[@vs=1];

public Box structs2boxL6(list[Structure] structs)
	= V([KW(L("structures")), *list2boxlist(structs, struct2boxL6)])[@vs=1];
	
public Box struct2boxL6(Structure struct)
	= V([
		H([VAR(L(struct.name.val)), L("{")])[@hs=1],
		 I([V([fields2boxL6(struct.fields)])[@vs=0]])[@ts=1],
		 L("}")
	])[@vs=0];
	
public Box fields2boxL6(list[Field] fields)
	= V(list2boxlist(fields, field2boxL6))[@vs=0];

public Box field2boxL6(fieldRaw(id(fname), fieldTerminatedBy(Callback cb, format)))
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
	

public Box field2boxL6(fieldRaw(id(fname), fieldTerminatedBefore(Callback cb, format)))
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
	
public Box field2boxL6(fieldRaw(id(fname), fieldTerminatedBefore(list[Scalar] values, format)))
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

public Box field2boxL6(fieldRaw(id(fname), fieldTerminatedBy(list[Scalar] values, format)))
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


public Box field2boxL6(Field fld) = terminatorfield2box(fld) when fld has values, fld@terminator?;
public Box field2boxL6(Field fld) = terminatorcallbackfield2box(fld) when fld has callback, fld@terminator?;

public default Box field2boxL6(Field fld) = field2box(fld);

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
		VAR(L(escape(fld.name.val, mapping))),
		L(": <terminator> "),
		H([
			callback2box(fld.callback),
			H([
				*hsepList(getLocalFormat(fld.format), " ", format2box)
			])[@hs=0]
		])[@hs=1],
		L(";")
	] + (annos ? [COMM(L(comment))] : [])
	)[@hs=0];
}

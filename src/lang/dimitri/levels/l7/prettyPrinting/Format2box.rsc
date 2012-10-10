module lang::dimitri::levels::l7::prettyPrinting::Format2box
extend lang::dimitri::levels::l6::prettyPrinting::Format2box;

import Node;

import lang::dimitri::levels::l7::AST;

public Box format2boxL7(Format f) =
  V([
    formatheader2box(f.name, f.extensions),
    defaults2box(f.defaults),
    sequence2box(f.sequence.symbols),
    structs2boxL7(f.structures)
  ])[@vs=1];

public Box structs2boxL7(list[Structure] structs)
	= V([KW(L("structures")), *list2boxlist(structs, struct2boxL7)])[@vs=1];

public Box struct2boxL7(Structure::struct(sname, parent, fields))
	= V([
		H([VAR(L(sname.val)), L(" = "), VAR(L(parent.val)), L(" {")])[@hs=1],
		 I([V([fields2boxL6(fields)])[@vs=0]])[@ts=1],
		 L("}")
	])[@vs=0];
	
public Box struct2boxL7(s:Structure::struct(sname, fields))
	= struct2boxL6(s);

public Box field2boxL6(fld:fieldOverride(_,_)) = overridefield2box(fld);

public Box overridefield2box(Field fld) {	
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
	
	return H([
		VAR(L(escape(fld.name.val, mapping))),
		L(": { "),
		I([*fields2boxL6(fld.overrides)])[@ts=1],
		L("}")
	] + (annos ? [COMM(L(comment))] : [])
	)[@hs=0];
}
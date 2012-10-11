module lang::dimitri::levels::l3::prettyPrinting::Format2box
extend lang::dimitri::levels::l2::prettyPrinting::Format2box;

import lang::dimitri::levels::l3::AST;

public Box field2box(fieldRaw(id(fname), fieldValue(Callback cb)))
	= H([
		VAR(L(escape(fname, mapping))),
		L(": "),
		callback2box(cb),
		L(";")
	])[@hs=0];
	
public Box field2box(fieldRaw(id(fname), fieldValue(Callback cb, format)))
	= H([
		VAR(L(escape(fname, mapping))),
		L(": "),
		H([
			callback2box(cb),
			H([
				*hsepList(format, " ", format2box)
			])[@hs=0]
		])[@hs=1],
		L(";")
	])[@hs=0];

public Box field2box(Field fld) = callbackfield2box(fld) when fld has callback;

public Box callbackfield2box(fld:field(id(fname), Callback cb, set[FormatSpecifier] format)) {
	str comment = "/* ";
	
	bool annos = false;
	
	annomap = getAnnotations(fld);
	for (an <- annomap) {
		if (an != "location" && !(an == "parent" && annomap[an] == "")) {
			annos = true;
			comment += " <an>=<annomap[an]>";
		}
	}
	
	comment += " */";
		
	return H([
		VAR(L(escape(fname, mapping))),
		L(": "),
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

public Box callback2box(callback(func(id(funcname)), set[Parameter] params))
	= H([
		KW(L(funcname)),
		L("("),
		H(hsepList(params, ", ", parameter2box))[@hs=0],
		L(")")
	])[@hs=0];

public Box parameter2box(pm(id(paramname), values))
	= H([
		VAR(L(paramname)),
		L("="),
		*hsepList(values, "+", argument2box)
	])[@hs=0];
	
public Box argument2box(numberArg(val)) = NM(L("<val>"));
public Box argument2box(hexArg(val)) = NM(L(val));
public Box argument2box(octArg(val)) = NM(L(val));
public Box argument2box(binArg(val)) = NM(L(val));
public Box argument2box(stringArg(val)) = STRING(L("\"<val>\""));
public Box argument2box(refArg(val)) = id2box(val);
public Box argument2box(crossRefArg(sname, fname) ) = H([id2box(sname), L("."), id2box(fname)])[@hs=0];
public default Box argument2box(Argument a) { throw "Unknown argument: <a>"; }
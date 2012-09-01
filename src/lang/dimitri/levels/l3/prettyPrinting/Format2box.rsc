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

	
public Box field2box(field(id(fname), Callback cb, set[FormatSpecifier] format))
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

public Box field2box(field(id(fname), Callback cb, {}))
	= H([
		VAR(L(escape(fname, mapping))),
		L(": "),
		callback2box(cb),
		L(";")
	])[@hs=0];

public Box callback2box(callback(func(id(funcname)), set[Parameter] params))
	= H([
		KW(L(funcname)),
		L("("),
		H(hsepList(params, ", ", parameter2box))[@hs=0],
		L(")")
	])[@hs=0];

public Box parameter2box(parameter(id(paramname), values))
	= H([
		VAR(L(paramname)),
		L("="),
		*hsepList(values, "+", scalar2box)
	])[@hs=0];
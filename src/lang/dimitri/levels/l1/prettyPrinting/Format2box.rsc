module lang::dimitri::levels::l1::prettyPrinting::Format2box

import lang::box::util::Box;
import List;
import Set;
import String;
import Node;

import lang::dimitri::levels::l1::AST;
import lang::dimitri::levels::l1::prettyPrinting::BoxHelper;
import lang::dimitri::levels::l1::compiler::Annotate;

map[str,str] mapping = ("*":"_");

public Box format2box(Format f) =
  V([
    formatheader2box(f.name, f.extensions),
    defaults2box(f.defaults),
    sequence2box(f.sequence.symbols),
    structs2box(f.structures)
  ])[@vs=1];

public Box id2box(Id id) = VAR(L(escape(id.val, mapping)));

public Box formatheader2box(Id name, list[Id] extensions)
	= V([
		H([KW(L("format")), id2box(name)])[@hs=1],
		H([KW(L("extension")), L(" "), H(hsepList(extensions, " ", id2box))])[@hs=0]
	])[@vs=0];

public Box defaults2box(set[FormatSpecifier] defaults)
	= V(set2boxlist(defaults, format2box))[@vs=0];

public Box format2box(formatSpecifier(key, val))
	= H([KW(L(key)), L(val)])[@hs=1];

public Box format2box(variableSpecifier(key, val))
	= H([KW(L(key)), scalar2box(val)])[@hs=1];

public Box scalar2box(number(val)) = NM(L("<val>"));
public Box scalar2box(hex(val)) = NM(L(val));
public Box scalar2box(oct(val)) = NM(L(val));
public Box scalar2box(bin(val)) = NM(L(val));
public Box scalar2box(string(val)) = STRING(L("\"<val>\""));
public Box scalar2box(ref(val)) = id2box(val);
public default Box scalar2box(Scalar s) { throw "unknow scalar: <s>"; }


public Box sequence2box(list[SequenceSymbol] symbols)
	= V([
		KW(L("sequence")),
		I([V(list2boxlist(symbols, symbol2box))[@vs=0]])[@is=1]
	])[@vs=0];
	
public Box symbol2box( SequenceSymbol::struct(id(name))) = VAR(L(name));
public Box symbol2box( optionalSeq(SequenceSymbol symbol)) = H([symbol2box(symbol), L("?")])[@hs=0];
public Box symbol2box( zeroOrMoreSeq(SequenceSymbol symbol)) = H([symbol2box(symbol), L("*")])[@hs=0];
public Box symbol2box( notSeq(SequenceSymbol symbol)) = H([L("!"), *symbol2box(symbol)])[@hs=0];
public Box symbol2box( choiceSeq(set[SequenceSymbol] symbols)) = H([L("("), H(hsepList(symbols, " ", symbol2box)), L(")")]);
public Box symbol2box( fixedOrderSeq(list[SequenceSymbol] symbols)) = H([L("["), H(hsepList(symbols, " ", symbol2box)), L("]")]);

public Box structs2box(list[Structure] structs)
	= V([KW(L("structures")), *list2boxlist(structs, struct2box)])[@vs=1];
	
public Box struct2box(Structure struct)
	= V([
		H([VAR(L(struct.name.val)), L("{")])[@hs=1],
		 I([V([fields2box(struct.fields)])[@vs=0]])[@ts=1],
		 L("}")
	])[@vs=0];
	
public Box fields2box(list[Field] fields)
	= V(list2boxlist(fields, field2box))[@vs=0];

public Box field2box(fieldRaw(id(fname), fieldValue(format)))
	= H([
		VAR(L(escape(fname, mapping))),
		L(": "),
		*hsepList(format, " ", format2box),
		L(";")
	])[@hs=0];
	
public Box field2box(fieldRaw(id(fname), fieldValue(list[Scalar] values, format)))
	= H([
		VAR(L(escape(fname, mapping))),
		L(": "),
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

public Box field2box(fieldNoValue(id(fname)) )
	= H([VAR(L(escape(fname, mapping))), L(";")])[@hs=0];

//public Box field2box(fld:field(id(fname), [], {}) ) {
//	ref = "";
//	refdep = "";
//	if (fld@ref?) ref = "<fld@ref>";
//	if (fld@refdep?) refdep = "<fld@refdep>";
//	
//	str comment = "/* ";
//	
//	if (size(ref) > 0)
//		comment += "ref=<ref> ";
//	if (size(refdep) > 0)
//		comment += "refdep=<refdep>";
//		
//	comment += " */";
//	
//	return H([VAR(L(escape(fname, mapping))), L(";")]+ (annos ? [COMM(L(comment))] : []))[@hs=0];
//
//}

public default Box field2box(Field fld) {
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
		VAR(L(escape(fld.name.val, mapping))),
		L( (size(fld.values) > 0 || size(getLocalFormat(fld.format)) > 0) ? ": " : ""),
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

public set[FormatSpecifier] getLocalFormat(set[FormatSpecifier] fmt) = {fm | fm <- fmt, fm@local?, fm@local};
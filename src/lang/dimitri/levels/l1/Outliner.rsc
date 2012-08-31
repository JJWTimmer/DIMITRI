module lang::dimitri::levels::l1::Outliner

import util::IDE; // outline annos
import ParseTree;

import lang::dimitri::levels::l1::Implode;
import lang::dimitri::levels::l1::AST;
import lang::dimitri::levels::l1::compiler::Debug;

public node outline(Tree tree) = outline(implode(tree));

public node outline(t:format(id(name), _, _, seq, strcts)) = "format"(
  "seq"([ outlineSym(s) | s <- seq.symbols])[@label="Sequence"],
  "strcts"([ outline(s) | s <- strcts])[@label="Structures"]
)[@label="Format <name>"][@\loc=t@location];

public node outline(Structure s) = "struct"([outline(f) | f <- s.fields])[@label=s.name.val][@\loc=s@location];
public node outline(Field fld) = "fld"()[@label=fld.name.val][@\loc=fld@location];


public node outlineSym( t:SequenceSymbol::struct(id(n)) ) = "sym"()[@label=n][@\loc=t@location];
public node outlineSym( t:notSeq(SequenceSymbol s)) = "not"(outlineSym(s))[@label="Not"][@\loc=t@location];
public node outlineSym( t:optionalSeq(SequenceSymbol s)) = "opt"(outlineSym(s))[@label="Optional"][@\loc=t@location];
public node outlineSym( t:zeroOrMoreSeq(SequenceSymbol s)) = "iter"(outlineSym(s))[@label="Repeated"][@\loc=t@location];
public node outlineSym( t:choiceSeq(set[SequenceSymbol] ss)) = "any"([ outlineSym(s) | s <- ss ])[@label="Any of"][@\loc=t@location];
public node outlineSym( t:fixedOrderSeq(list[SequenceSymbol] ss)) = "seq"([ outlineSym(s) | s <- ss ])[@label="Sequence"][@\loc=t@location];
public default node outlineSym(SequenceSymbol t) { throw "Unsupported SequenceSymbol: <t>"; }
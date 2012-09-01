module lang::dimitri::levels::l3::Check
extend lang::dimitri::levels::l2::Check;

import lang::dimitri::levels::l3::AST;

public set[Message] checkRefs(fld:field(_, Callback cb, set[FormatSpecifier] format), rel[Id, Id] fields, Id sname) =
	{*checkRefs(val, fields, sname) | p <- cb.parameters, val <- p.values}
	+ {*checkRefs(val, fields, sname) | variableSpecifier(_, val) <- fld.format};
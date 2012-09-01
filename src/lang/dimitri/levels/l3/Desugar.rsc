module lang::dimitri::levels::l3::Desugar
extend lang::dimitri::levels::l1::Desugar;

import lang::dimitri::levels::l3::AST;

public Field fieldRaw(name, fieldValue(Callback cb, format)) =
	field(name, cb, format);

public Field fieldRaw(name, fieldValue(Callback cb)) =
	field(name, cb, {});
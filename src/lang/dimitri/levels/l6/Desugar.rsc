module lang::dimitri::levels::l6::Desugar
extend lang::dimitri::levels::l3::Desugar;

import lang::dimitri::levels::l6::AST;

public Field fieldRaw(name, fieldTerminatedBy(values, format))
	= field(name, values, format)[@terminator=by()];

public Field fieldRaw(name, fieldTerminatedBefore(values, format))
	= field(name, values, format)[@terminator=before()];
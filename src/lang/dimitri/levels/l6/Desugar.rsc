module lang::dimitri::levels::l6::Desugar
extend lang::dimitri::levels::l3::Desugar;

import lang::dimitri::levels::l6::AST;

public Field fieldRaw(name, fieldTerminatedBy(values, format))
	= field(name, fieldTerminatedBy(values), format);

public Field fieldRaw(name, fieldTerminatedBefore(values, format))
	= field(name, fieldTerminatedBefore(values), format);

public Field fieldRaw(name, fieldTerminatedBy(values))
	= field(name, fieldTerminatedBy(values), {});

public Field fieldRaw(name, fieldTerminatedBefore(values))
	= field(name, fieldTerminatedBefore(values), {});
module lang::dimitri::levels::l3::Desugar
extend lang::dimitri::levels::l1::Desugar;

import lang::dimitri::levels::l3::AST;

public Argument hexArg(str hex) = numberArg(toInt(substring(hex, 2), 16));
public Argument octArg(str oct) = numberArg(toInt(substring(oct, 2), 8));
public Argument binArg(str bin) = numberArg(toInt(substring(bin, 2), 2));

public Field fieldRaw(name, fieldValue(Callback cb, format)) =
	field(name, cb, format);

public Field fieldRaw(name, fieldValue(Callback cb)) =
	field(name, cb, {});
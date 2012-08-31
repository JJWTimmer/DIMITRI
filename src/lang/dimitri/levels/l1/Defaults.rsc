module lang::dimitri::levels::l1::Defaults

import lang::dimitri::levels::l1::AST;

alias SFS = set[FormatSpecifier];

public str getDefault("unit") = "byte";
public str getDefault("sign") = "false";
public str getDefault("endian") = "big";
public str getDefault("strings") = "ascii";
public str getDefault("type") = "integer";

public Scalar getDefaultVar("size") = number(1);

public SFS getDefaults() =
	{
		formatSpecifier("unit", getDefault("unit")),
		formatSpecifier("sign", getDefault("sign")),
		formatSpecifier("endian", getDefault("endian")),
		formatSpecifier("strings", getDefault("strings")),
		formatSpecifier("type", getDefault("type")),
		variableSpecifier("size", getDefaultVar("size"))
	};
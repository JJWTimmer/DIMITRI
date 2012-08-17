module lang::dimitri::levels::l1::Desugar

import String;
/*
	I am new
*/

import lang::dimitri::levels::l1::AST;

//rewrite rules
public Scalar hex(str hex) = number(toInt(substring(hex, 2), 16));
public Scalar oct(str oct) = number(toInt(substring(oct, 2), 8));
public Scalar bin(str bin) = number(toInt(substring(bin, 2), 2));

public Field fieldNoValue(name) {
	list[Scalar] noVal = [];
	set[FormatSpecifier] noFormat = {};
	return field(name, noVal, noFormat);
}
public Field fieldRaw(name, fieldValue(format)) {
	list[Scalar] noVal = [];
	return field(name, noVal, format);
}
public Field fieldRaw(name, fieldValue(values, format)) = field(name, values, format);
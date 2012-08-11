module lang::dimitri::levels::l1::util::FormatHelper

import IO;
import util::Maybe;
import lang::dimitri::levels::l1::AST;
import lang::dimitri::levels::Level1; //for the defaults

alias LFS = list[FormatSpecifier];

public map[FormatKeyword, FormatValue] generateFormatMap(LFS input) = (k:v | formatSpecifier(k, v) <- input );
public map[VariableKeyword, value] generateVariableMap(LFS input) = (k:v | variableSpecifier(k, v) <- input );

public Maybe[Scalar] getSize(LFS input) = getVariableSpec(size(), #Scalar, input);

public FormatValue getUnit(LFS input) = getFormatSpec(unit(), input);
public FormatValue getSign(LFS input) = getFormatSpec(sign(), input);
public FormatValue getEndian(LFS input) = getFormatSpec(endian(), input);
public FormatValue getStrings(LFS input) = getFormatSpec(strings(), input);
public FormatValue getType(LFS input) = getFormatSpec(\type(), input);

public FormatValue getFormatSpec(FormatKeyword keyw, LFS input) {
	locals = generateFormatMap(input);
	
	if (keyw in locals)
		return locals[keyw];
	else {
		defaults = getDefaultFormat();
		return defaults[keyw];
	}
	
	throw "FormatKeyword not found in (default) format";
}

public Maybe[&T] getVariableSpec(VariableKeyword keyw, type[&T] returnFormat, LFS input) {
	locals = generateVariableMap(input);

	if (keyw in locals) {
		if (/&T v := locals[keyw]) return just(v);
	} else {
		defaults = getDefaultVariables();

		if (/&T v := defaults[keyw]) return just(v);
	}
	
	return nothing();
}

public map[FormatKeyword, FormatValue] getDefaultFormat() = generateFormatMap(DEFAULTS);
public map[FormatKeyword, value] getDefaultVariables() = generateVariableMap(DEFAULTS);

public LFS getDefaultLFS() = DEFAULTS;
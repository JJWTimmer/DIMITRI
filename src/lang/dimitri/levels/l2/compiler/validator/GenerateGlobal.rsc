module lang::dimitri::levels::l2::compiler::validator::GenerateGlobal

import String;

import lang::dimitri::levels::l2::compiler::validator::ADT;

public str generateGlobal(gdeclV(integer(bool sign, _, int bits), str n)) = 
	"	private <generateIntegerDeclaration(sign, bits, n)>";
	
public str generateGlobal(gdeclB(str n)) =
	"	private org.derric_lang.validator.SubStream <n> = new org.derric_lang.validator.SubStream();";

public str generateIntegerDeclaration(bool sign, int bits, str name) {
	if (sign) bits += 1;
	if (bits <= 64) return "long <name>;";
	else return "org.derric_lang.validator.SubStream <name> = new org.derric_lang.validator.SubStream();";
}
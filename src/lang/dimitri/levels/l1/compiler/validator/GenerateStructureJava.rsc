module lang::dimitri::levels::l1::compiler::validator::GenerateStructureJava

import lang::dimitri::levels::l1::compiler::validator::ADT;

public str generateStructure(Structure struct) {
	str ret = "private boolean parse<struct.name>() throws java.io.IOException {\n		markStart();\n";
	int i = 0;
	for (s <- struct.statements) {
		ret += "		";
		switch (s) {
			case ldeclV(integer(bool sign, _, int bits), str n): ret += "<generateIntegerDeclaration(sign, bits, n)>";
			case ldeclB(str n): ret += "org.dimitri_lang.validator.SubStream <n> = new org.dimitri_lang.validator.SubStream();";
			case calc(str n, VValue e): ret += "<n> = <generateValueExpression(e)>;";
			case readValue(Type t, str n): ret += "<n> = <generateReadValueMethodCall(t)>;";
			case readBuffer(str s, str n): ret += "<n>.addFragment(_input, <s>);";
			case readUntil(Type t, list[VValue] l, bool includeTerminator): ret += "<generateValueSet(l, "vs<i>")>if (!_input.<t.sign ? "signed()" : "unsigned()">.<(littleE() := t.endian) ? "byteOrder(LITTLE_ENDIAN)" : "byteOrder(BIG_ENDIAN)">.includeMarker(<includeTerminator ? "true" : "false">).readUntil(<t.bits>, vs<i>).validated) return noMatch();";
			case skipValue(Type t): ret += "if (!_input.skipBits(<t.bits>)) return noMatch();";
			case skipBuffer(str s): ret += "if (_input.skip(<s>) != <s>) return noMatch();";
			case validate(str v, list[VValue] l): ret += "<generateValueSet(l, "vs<i>")>\n		if (!vs<i>.equals(<v>)) return noMatch();";
		}
		ret += "\n";
		i += 1;
	}
	ret += "		addSubSequence(\"<struct.name>\");\n		return true;\n	}\n";
	return ret;
}

public str generateIntegerDeclaration(bool sign, int bits, str name) {
	if (sign) bits += 1;
	if (bits <= 64) return "long <name>;";
	else return "org.dimitri_lang.validator.SubStream <name> = new org.dimitri_lang.validator.SubStream();";
}

private str generateValueSet(list[VValue] le, str vs) {
	str ret = "org.dimitri_lang.validator.ValueSet <vs> = new org.dimitri_lang.validator.ValueSet();";
	for (VValue exp <- le) {
		ret += "<vs>.addEquals(<generateValueExpression(exp)>);";
	}
	return ret;
}

private str generateValueExpression(VValue exp) {
	top-down visit (exp) {
		case var(str n): return n;
		case con(int i): {
			if (i <= 2147483647) {
				return "<i>";
			} else {
				return "<i>l";
			}
		}
	}
}

private str generateReadValueMethodCall(Type \type) {
	switch (\type) {
		case integer(bool sign, Endianness endian, int bits): return "_input.<sign ? "signed()" : "unsigned()">.<(littleE() := endian) ? "byteOrder(LITTLE_ENDIAN)" : "byteOrder(BIG_ENDIAN)">.readInteger(<bits>)";
	}
}

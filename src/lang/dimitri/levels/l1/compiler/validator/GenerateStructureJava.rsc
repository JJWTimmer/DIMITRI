module lang::dimitri::levels::l1::compiler::validator::GenerateStructureJava

import lang::dimitri::levels::l1::compiler::validator::ADT;

public str generateStructure(Structure struct) {
	str ret = "private boolean parse<struct.name>() throws java.io.IOException {\n		markStart();\n";
	int i = 0;
	for (s <- struct.statements) {
		ret += "		";
		switch (s) {
			case ldeclV(integer(bool sign, _, int bits), str n): ret += "<generateIntegerDeclaration(sign, bits, n)>";
			case ldeclB(str n): ret += "SubStream <n> = new SubStream();";
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
	else return "SubStream <name> = new SubStream();";
}

private str generateValueSet(list[VValue] le, str vs) {
	str ret = "ValueSet <vs> = new ValueSet();\n";
	for (VValue exp <- le) {
		ret += "		<vs>.addEquals(<generateValueExpression(exp)>);";
	}
	return ret;
}

private str generateValueExpression(bits(str var)) = var;
private str generateValueExpression(bytes(str var)) = "8 * <var>";
private str generateValueExpression(var(str n)) = n;
private str generateValueExpression(con(int i)) = (i <= 2147483647) ? "<i>" : "<i>l";

private str generateReadValueMethodCall(integer(bool sign, Endianness endian, int bits)) = "_input.<sign ? "signed()" : "unsigned()">.<(littleE() := endian) ? "byteOrder(LITTLE_ENDIAN)" : "byteOrder(BIG_ENDIAN)">.readInteger(<bits>)";
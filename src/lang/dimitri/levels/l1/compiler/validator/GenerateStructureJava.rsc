module lang::dimitri::levels::l1::compiler::validator::GenerateStructureJava

import lang::dimitri::levels::l1::compiler::validator::ADT;

public str generateStructure(Structure struct) {
	str ret = "private boolean parse<struct.name>() throws java.io.IOException {
			  '		markStart();\n";
	int i = 0;
	for (stmt <- struct.statements) {
		ret += "		<generateStructure(stmt, i)>\n";
		i += 1;
	}
	ret += "		addSubSequence(\"<struct.name>\");
		   '		return true;
		   '	}
		   '";
	return ret;
}


public str generateStructure(ldeclV(integer(bool sign, _, int bits), str n), int i) = "<generateIntegerDeclaration(sign, bits, n)>";
public str generateStructure(ldeclB(str n), int i) 	= "SubStream <n> = new SubStream();";
public str generateStructure(calc(str n, VValue e), int i) = "<n> = <generateValueExpression(e)>;";
public str generateStructure(readValue(Type t, str n), int i) = "<n> = <generateReadValueMethodCall(t)>;";
public str generateStructure(readBuffer(str s, str n), int i) {
	return "<n>.addFragment(_input, <s>);";
}
public str generateStructure(readUntil(Type t, list[VValue] l, bool includeTerminator), int i)
	= "<generateValueSet(l, "vs<i>")>if (!_input.<t.sign ? "signed()" : "unsigned()">.<(littleE() := t.endian) ? "byteOrder(LITTLE_ENDIAN)" : "byteOrder(BIG_ENDIAN)">.includeMarker(<includeTerminator ? "true" : "false">).readUntil(<t.bits>, vs<i>).validated) return noMatch();";
public str generateStructure(skipValue(Type t), int i) = "if (!_input.skipBits(<t.bits>)) return noMatch();";
public str generateStructure(skipBuffer(str s), int i) = "if (_input.skip(<s>) != <s>) return noMatch();";
public str generateStructure(validate(str v, list[VValue] l), int i)
	= "<generateValueSet(l, "vs<i>")>
	  '		if (!vs<i>.equals(<v>)) return noMatch();";

public default str generateStructure(Statement st, int _) {
	throw "Unknown Statement <st>";
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

private str generateValueExpression(bits(var(vname))) = vname;
private str generateValueExpression(bytes(var(vname))) = "8 * <vname>";
private str generateValueExpression(var(str n)) = n;
private str generateValueExpression(con(int i)) = (i <= 2147483647) ? "<i>" : "<i>l";

private str generateReadValueMethodCall(integer(bool sign, Endianness endian, int bits)) = "_input.<sign ? "signed()" : "unsigned()">.<(littleE() := endian) ? "byteOrder(LITTLE_ENDIAN)" : "byteOrder(BIG_ENDIAN)">.readInteger(<bits>)";
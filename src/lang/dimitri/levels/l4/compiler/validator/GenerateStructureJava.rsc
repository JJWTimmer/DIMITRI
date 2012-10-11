module lang::dimitri::levels::l4::compiler::validator::GenerateStructureJava
extend lang::dimitri::levels::l3::compiler::validator::GenerateStructureJava;

import lang::dimitri::levels::l4::compiler::validator::ADT;

public str generateValueExpression(bits(VValue exp)) = generateValueExpression(exp);
public str generateValueExpression(bytes(VValue exp)) = "(8 * (<generateValueExpression(exp)>))";
public str generateValueExpression(sub(VValue l, VValue r)) = "(<generateValueExpression(l)>-<generateValueExpression(r)>)";
public str generateValueExpression(sub(VValue l, VValue r)) = "(<generateValueExpression(l)>-<generateValueExpression(r)>)";
public str generateValueExpression(add(VValue l, VValue r)) = "(<generateValueExpression(l)>+<generateValueExpression(r)>)";
public str generateValueExpression(fac(VValue l, VValue r)) = "(<generateValueExpression(l)>*<generateValueExpression(r)>)";
public str generateValueExpression(div(VValue l, VValue r)) = "(<generateValueExpression(l)>/<generateValueExpression(r)>)";
public str generateValueExpression(pow(VValue b, VValue e)) = "(int)java.lang.Math.pow(<generateValueExpression(b)>, <generateValueExpression(e)>)";
public str generateValueExpression(neg(VValue e)) = "-<generateValueExpression(e)>";
public default str generateValueExpression(VValue v) {
	throw "Unknown VValue <v>";
}

public default str generateValueSetL4(list[VValue] le, str vs) {
	str ret = "ValueSet <vs> = new ValueSet();\n";
	for (VValue exp <- le) {
		switch (exp) {
			case not(range(VValue l, VValue u)): ret += "<vs>.addNot(<generateValueExpression(l)>, <generateValueExpression(u)>);";
			case not(VValue e): ret += "<vs>.addNot(<generateValueExpression(e)>);";
			case range(VValue l, VValue u): ret += "<vs>.addEquals(<generateValueExpression(l)>, <generateValueExpression(u)>);";
			default: ret += "<vs>.addEquals(<generateValueExpression(exp)>);";
		}
	}
	return ret;
}

public str generateStructureL4(Structure struct) {
	str ret = "private boolean parse<struct.name>() throws java.io.IOException {
			  '		markStart();\n";
	int i = 0;
	for (stmt <- struct.statements) {
		ret += "		<generateStructureL4(stmt, i)>\n";
		i += 1;
	}
	ret += "		addSubSequence(\"<struct.name>\");
		   '		return true;
		   '	}
		   '";
	return ret;
}

public str generateStructureL4(ldeclV(integer(bool sign, _, int bits), str n), int i) = "<generateIntegerDeclaration(sign, bits, n)>";
public str generateStructureL4(ldeclB(str n), int i) {
	return "SubStream <n> = new SubStream();";
}
public str generateStructureL4(calc(str n, VValue e), int i) = "<n> = <generateValueExpression(e)>;";
public str generateStructureL4(readValue(Type t, str n), int i) = "<n> = <generateReadValueMethodCall(t)>;";
public str generateStructureL4(readBuffer(str s, str n), int i) {
	return "<n>.addFragment(_input, <s>);";
}
public str generateStructureL4(readUntil(Type t, list[VValue] l, bool includeTerminator), int i)
	= "<generateValueSetL4(l, "vs<i>")>if (!_input.<t.sign ? "signed()" : "unsigned()">.<(littleE() := t.endian) ? "byteOrder(LITTLE_ENDIAN)" : "byteOrder(BIG_ENDIAN)">.includeMarker(<includeTerminator ? "true" : "false">).readUntil(<t.bits>, vs<i>).validated) return noMatch();";
public str generateStructureL4(skipValue(Type t), int i) = "if (!_input.skipBits(<t.bits>)) return noMatch();";
public str generateStructureL4(skipBuffer(str s), int i) = "if (_input.skip(<s>) != <s>) return noMatch();";
public str generateStructureL4(validate(str v, list[VValue] l), int i)
	= "<generateValueSetL4(l, "vs<i>")>
	  '		if (!vs<i>.equals(<v>)) return noMatch();";
public str generateStructureL4(validateContent(str v, str l, str n, map[str, str] configuration, map[str, list[VValue]] arguments, bool allowEOF), int i)
	= "<makeStringMap("content1_<i>", configuration)><makeExpressionMap("content2_<i>", arguments)>org.dimitri_lang.runtime.level1.Content content3_<i> = _input.validateContent(<l>, \"<n>\", content1_<i>, content2_<i>, allowEOF || <allowEOF>);
	  'if (!content3_<i>.validated) return noMatch();
	  '<v>.fragments.add(content3_<i>.data);
	  '<l> = <v>.getLast().length;
	  '";
public default str generateStructureL4(Statement s, int _) { throw "Unknown statement: <s>"; }
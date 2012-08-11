module lang::dimitri::levels::l1::compiler::validator::GenerateStructureJava

import lang::dimitri::levels::l1::compiler::validator::ADT;

public str generateStructure(Structure struct) {
	str ret = "private boolean parse<struct.name>() throws java.io.IOException {markStart();";
	int i = 0;
	for (s <- struct.statements) {
		switch (s) {
			case ldeclV(integer(bool sign, _, int bits), str n): ret += "<generateIntegerDeclaration(sign, bits, n)>";
			case ldeclB(str n): ret += "org.dimitri_lang.validator.SubStream <n> = new org.dimitri_lang.validator.SubStream();";
			case calc(str n, VValue e): ret += "<n> = <generateValueExpression(e)>;";
			case readValue(Type t, str n): ret += "<n> = <generateReadValueMethodCall(t)>;";
			case readBuffer(str s, str n): ret += "<n>.addFragment(_input, <s>);";
			case readUntil(Type t, list[VValue] l, bool includeTerminator): ret += "<generateValueSet(l, "vs<i>")>if (!_input.<t.sign ? "signed()" : "unsigned()">.<(littleE() := t.endian) ? "byteOrder(LITTLE_ENDIAN)" : "byteOrder(BIG_ENDIAN)">.includeMarker(<includeTerminator ? "true" : "false">).readUntil(<t.bits>, vs<i>).validated) return noMatch();";
			case skipValue(Type t): ret += "if (!_input.skipBits(<t.bits>)) return noMatch();";
			case skipBuffer(str s): ret += "if (_input.skip(<s>) != <s>) return noMatch();";
			case validate(str v, list[VValue] l): ret += "<generateValueSet(l, "vs<i>")>if (!vs<i>.equals(<v>)) return noMatch();";
			case validateContent(str v, str l, str n, map[str, str] configuration, map[str, list[VValue]] arguments): ret += "<makeStringMap("content1_<i>", configuration)><makeExpressionMap("content2_<i>", arguments)>org.dimitri_lang.validator.Content content3_<i> = _input.validateContent(<l>, \"<n>\", content1_<i>, content2_<i>); if (!content3_<i>.validated) return noMatch();<v>.fragments.add(content3_<i>.data);<l> = <v>.getLast().length;";
		}
		i += 1;
	}
	ret += "addSubSequence(\"<struct.name>\");return true; }";
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

private str makeList(str n, list[VValue] l) {
	str ret = "java.util.ArrayList\<Long\> <n> = new java.util.ArrayList\<Long\>();";
	for (e <- l) ret += "<n>.add((long)<generateValueExpression(e)>);";
	return ret;
}

private str makeStringMap(str n, map[str, str] m) {
	str ret = "java.util.HashMap\<String, String\> <n> = new java.util.HashMap\<String, String\>();";
	for (k <- m) ret += "<n>.put(\"<k>\", \"<m[k]>\");";
	return ret;
}

private str makeExpressionMap(str n, map[str, list[VValue]] m) {
	str ret = "java.util.HashMap\<String, java.util.List\<Object\>\> <n> = new java.util.HashMap\<String, java.util.List\<Object\>\>();";

	int i = 0;
	for (k <- m) {
		ret += "java.util.ArrayList\<Object\> <n>_<i> = new java.util.ArrayList\<Object\>();";
		for (VValue v <- m[k]) {
			switch (v) {
				case var(str v): ret += "<n>_<i>.add(<v>);";
				case con(int t): ret += "<n>_<i>.add(<t>);";
			}
		}
		ret += "<n>.put(\"<k>\", <n>_<i>);";
		i += 1;
	}
	return ret;
}

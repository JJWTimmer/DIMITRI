module lang::dimitri::levels::l3::compiler::validator::GenerateStructureJava
extend lang::dimitri::levels::l1::compiler::validator::GenerateStructureJava;

import lang::dimitri::levels::l3::compiler::validator::ADT;

public str generateStructure(validateContent(str v, str l, str n, map[str, str] configuration, map[str, list[VValue]] arguments, bool allowEOF), int i)
	= "<makeStringMap("content1_<i>", configuration)><makeExpressionMap("content2_<i>", arguments)>org.dimitri_lang.runtime.level1.Content content3_<i> = _input.validateContent(<l>, \"<n>\", content1_<i>, content2_<i>, allowEOF || <allowEOF>);
	  'if (!content3_<i>.validated) return noMatch();
	  '<v>.fragments.add(content3_<i>.data);
	  '<l> = <v>.getLast().length;
	  '";
	

private str makeExpressionMap(str n, map[str, list[VValue]] m) {
	str ret = "java.util.HashMap\<String, java.util.List\<Object\>\> <n> = new java.util.HashMap\<String, java.util.List\<Object\>\>();";

	int i = 0;
	for (k <- m) {
		ret += "java.util.ArrayList\<Object\> <n>_<i> = new java.util.ArrayList\<Object\>();";
		for (VValue v <- m[k]) {
			ret += getMapVal(v, n, i);
		}
		ret += "<n>.put(\"<k>\", <n>_<i>);";
		i += 1;
	}
	return ret;
}

public str getMapVal(var(str v), str n, int i) = "<n>_<i>.add(<v>);";
public str getMapVal(con(int t), str n, int i) = "<n>_<i>.add(<t>);";

public default str getMapVal(VValue s) {
	throw "Unknown VValue <s>";
}


private str makeStringMap(str n, map[str, str] m) {
	str ret = "java.util.HashMap\<String, String\> <n> = new java.util.HashMap\<String, String\>();\n";
	for (k <- m) ret += "<n>.put(\"<k>\", \"<m[k]>\");\n";
	return ret;
}
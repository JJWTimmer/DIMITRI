module lang::dimitri::levels::l4::compiler::validator::GenerateStructureJava
extend lang::dimitri::levels::l3::compiler::validator::GenerateStructureJava;

import lang::dimitri::levels::l4::compiler::validator::ADT;

public str generateValueExpression(sub(VValue l, VValue r)) = "(<generateValueExpression(l)>-<generateValueExpression(r)>)";
public str generateValueExpression(add(VValue l, VValue r)) = "(<generateValueExpression(l)>+<generateValueExpression(r)>)";
public str generateValueExpression(fac(VValue l, VValue r)) = "(<generateValueExpression(l)>*<generateValueExpression(r)>)";
public str generateValueExpression(div(VValue l, VValue r)) = "(<generateValueExpression(l)>/<generateValueExpression(r)>)";
public str generateValueExpression(pow(VValue b, VValue e)) = "(int)java.lang.Math.pow(<generateValueExpression(b)>, <generateValueExpression(e)>)";
public str generateValueExpression(neg(VValue e)) = "-<generateValueExpression(e)>";
public default str generateValueExpression(VValue v) {
	throw "Unknown VValue <v>";
}
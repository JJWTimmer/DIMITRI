module lang::dimitri::levels::l5::compiler::PropagateConstants
extend lang::dimitri::levels::l4::compiler::PropagateConstants;

import lang::dimitri::levels::l5::AST;

public list[Scalar] getVals(Id _, lengthOf(crossRef(struct, source)), rel[Id, Id, Field] specMap) {
	Field f;
	if( {theField} := specMap[struct, source] ) f = theField;
	
	Scalar size = number(0);
	if (/variableSpecifier("size", s) := f.format) size = s;
	
	if (number(0) := size) throw "Impossible size in lengthOf(<struct>.<source>)";
	
	return [size];
	
}

public list[Scalar] getVals(Id struct, lengthOf(ref(source)), rel[Id, Id, Field] specMap) {
	Field f;
	if( {theField} := specMap[struct, source] ) f = theField;
	
	Scalar size = number(0);
	if (/variableSpecifier("size", s) := f.format) size = s;
	
	if (number(0) := size) throw "Impossible size in lengthOf(<struct>.<source>)";
	
	return [size];
	
}
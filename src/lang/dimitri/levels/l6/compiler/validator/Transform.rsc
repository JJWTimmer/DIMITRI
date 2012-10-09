module lang::dimitri::levels::l6::compiler::validator::Transform
extend lang::dimitri::levels::l5::compiler::validator::Transform;

import lang::dimitri::levels::l6::AST;

public Validator getValidatorL6(Format format)
	= validator(
		toUpperCase(format.name.val) + "Validator",
		format.name.val,
		getGlobalsL5(format),
		getStructuresL6(format));
		
public list[Structure] getStructuresL6(Format format) {
	list[Structure] structures = [];
	str sname = "";
	FRefs frefs = getFRefs(format);

	for (struct <- format.structures) {
		sname = struct.name.val;
		list[Statement] statements = [];
		for (field <- struct.fields) {
			statements += field2statementsL6(sname, field, frefs, format);
		}
		structures += structure(sname, statements);
	}
	return structures;
}

public list[Statement] field2statementsL6 (str sname, Field field, FRefs frefs, Format format)
	= fixedSizefields2statementsL5(sname, field, frefs)
	when field has values,
	!isVariableSize(field),
	!hasTerminatorSpecification(field);
public list[Statement] field2statementsL6 (str sname, Field field, FRefs frefs, Format format)
	= variableSizeFields2statementsL5(sname, field, frefs)
	when field has values,
	isVariableSize(field),
	!hasTerminatorSpecification(field);
public list[Statement] field2statementsL6 (str sname, Field field, FRefs frefs, Format format)
	= terminatorfields2statements(sname, field, frefs)
	when field has values,
	hasTerminatorSpecification(field);
public list[Statement] field2statementsL6 (str sname, Field field, FRefs frefs, Format format)
	= callbackFields2statementsL5(sname, field, frefs, format)
	when field has callback;

private bool hasTerminatorSpecification(Field f) {
	return f@terminator?;
}

public list[Statement] terminatorfields2statements (str sname, Field field, FRefs frefs) {
	list[Statement] statements = [];
	// handles value=Expression, size=\value(int), modifier=terminatedBy/terminatedBefore
	// no references are allowed
	Type t = makeType(field);
	if (tt := field@terminator, before() := tt) {
		statements += readUntil(t, [*generateScalar(sname, field.values[0])], false);
	} else if (tt := field@terminator, by() := tt) {
		statements += readUntil(t, [*generateScalar(sname, field.values[0])], true);
	} else {
		throw "terminatorfields2statements: Unsupported terminator spec";
	}
	
	return statements;
}
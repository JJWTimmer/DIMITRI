module lang::dimitri::levels::l2::compiler::PropagateConstants
extend lang::dimitri::levels::l1::compiler::PropagateConstants;

import lang::dimitri::levels::l2::AST;

public list[Scalar] getVals(Id _, crossRef(struct, source), rel[Id, Id, Field] specMap) = theField.values when
	{theField} := specMap[struct, source],
	theField has values,
	[oldVal] := theField.values,
	ref(_) !:= oldVal;
	
public list[Scalar] getVals(Id sname, crossRef(struct, source), rel[Id, Id, Field] specMap) = [res] when
	{theField} := specMap[struct, source],
	theField has values,
	[oldVal] := theField.values,
	ref(nextRefField) := oldVal,
	res := crossRef(struct, nextRefField);
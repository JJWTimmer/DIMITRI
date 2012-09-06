module lang::dimitri::levels::l2::compiler::PropagateConstants
extend lang::dimitri::levels::l1::compiler::PropagateConstants;

import lang::dimitri::levels::l2::AST;

public list[Scalar] getVals(Id _, r:crossRef(struct, source), rel[Id, Id, Field] specMap) = theField.values when
	sourceField := specMap[struct, source],
	{theField} := sourceField,
	[oldVal] := theField.values,
	ref(_) !:= oldVal;
	
public list[Scalar] getVals(Id sname, r:crossRef(struct, source), rel[Id, Id, Field] specMap) = [res] when
	sourceField := specMap[struct, source],
	{theField} := sourceField,
	[oldVal] := theField.values,
	ref(srcField) := oldVal,
	res := crossRef(sname, srcField);
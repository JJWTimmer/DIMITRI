module lang::dimitri::levels::l2::compiler::PropagateConstants

extend lang::dimitri::levels::l1::compiler::PropagateConstants;

import Set;
import List;

import lang::dimitri::levels::l2::AST;

public list[Scalar] getVals(str _, r:crossRef(struct, source), rel[str, str, Field] specMap) = val when
	sourceField := specMap[struct, source],
	[theField] := sourceField,
	[val] := theField.values;
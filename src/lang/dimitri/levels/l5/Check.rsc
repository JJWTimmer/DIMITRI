module lang::dimitri::levels::l5::Check
extend lang::dimitri::levels::l4::Check;

import lang::dimitri::levels::l5::AST;

public set[Message] checkErrorsL5(start[Format] f) = checkErrorsL5(f.top, ctx(getFields(f), getCompleteFields(f)));

public set[Message] checkErrorsL5(f:format(name, extensions, defaults, sq, structures), Context cntxt)
	= checkDuplicateStructureNames(structures)
	+ checkUndefinedSequenceNames(sq.symbols, structures)
	+ checkDuplicateFieldNames(structures)
	+ checkRefs(f, cntxt.fields)
	+ typeCheckScalars(defaults, structures, cntxt)
	+ checkScalarSugar(f);

public bool allowString(offset(_), Id _, Context _) = false;
public bool allowString(lengthOf(_), Id _, Context _) = false;

public bool containsString(offset(_), Id _, Context _) = false;
public bool containsString(lengthOf(_), Id _, Context _) = false;

public set[Message] checkScalarSugar(Format fmt) =
	{error("offset can only contain a reference", s@location) | /offset(s) <- fmt, ref(_) !:= s && crossRef(_, _) !:= s}
	+ {error("lengthOf can only contain a reference", s@location) | /lengthOf(s) <- fmt, ref(_) !:= s && crossRef(_, _) !:= s};
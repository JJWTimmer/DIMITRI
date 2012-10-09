module lang::dimitri::levels::l6::Check
extend lang::dimitri::levels::l5::Check;

import Boolean;

import lang::dimitri::levels::l6::AST;

public set[Message] checkErrorsL6(Format f) = checkErrorsL6(f, ctx(getFields(f), getCompleteFields(f)));

public set[Message] checkErrorsL6(f:format(name, extensions, defaults, sq, structures), Context cntxt)
	= checkDuplicateStructureNames(structures)
	+ checkUndefinedSequenceNames(sq.symbols, structures)
	+ checkDuplicateFieldNames(structures)
	+ checkRefs(f, cntxt.fields)
	+ typeCheckScalars(defaults, structures, cntxt)
	+ checkScalarSugar(f)
	+ checkTerminators(structures, cntxt);
	
public set[Message] checkTerminators(list[Structure] structs, Context cntxt)
	= {*checkTerminators(fld, struct.name, cntxt) | struct <- structs, fld <- struct.fields};
public set[Message] checkTerminators(Field f, Id sname, Context cntxt)
	= {error("Cannot use a terminator modifier on strings, callbacks or multi valued fields", f@location)}
	when f@terminator?,
	f has values && (size(f.values) > 1 || any( v <- f.values, containsString(v, sname, cntxt)))
	|| f has callback;
public default set[Message] checkTerminators(Field f, Id _, Context _) = {};
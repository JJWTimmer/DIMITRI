module lang::dimitri::levels::l2::Check
extend lang::dimitri::levels::l1::Check;

import lang::dimitri::levels::l2::AST;

public set[Message] checkErrorsL2(Format f) = checkErrorsL2(f, ctx(getFields(f)));

public set[Message] checkErrorsL2(f:format(name, extensions, defaults, sequence, structures), Context ctx)
	= checkDuplicateStructureNames(structures)
	+ checkUndefinedSequenceNames(sequence.symbols, structures)
	+ checkDuplicateFieldNames(structures)
	+ checkRefsL2(f, ctx.fields);

public default set[Message] checkRefsL2(Field f, rel[Id, Id] fields, Id sname) =
	{*checkRefsL2(r, fields, sname) | /r:ref(_) <- f}
	+ {*checkRefsL2(r, fields, sname) | /r:crossRef(_, _) <- f};

public set[Message] checkRefsL2(cr:crossRef(structId, sourceId), rel[Id, Id] fields, Id _)
	= {error("Sourcefield does not exist: <structId.val>.<sourceId.val>", cr@location)}
	when sourceId notin fields[structId];

public set[Message] checkRefsL2(Format fmt, rel[Id, Id] fields)
	= {*checkRefsL2(struct, fields) | struct <- fmt.structures}
	+ {error("Refs not allowed in defaults", s@location) | /Scalar s <- fmt.defaults, ref(_) := s};
public set[Message] checkRefsL2(Structure struct, rel[Id, Id] fields)
	= {*checkRefsL2(field, fields, struct.name) | field <- struct.fields};
public set[Message] checkRefsL2(fld:field(_, list[Scalar] _, _), rel[Id, Id] fields, Id sname)
	= {*checkRefsL2(sc, fields, sname) | /Scalar sc <- fld};
public set[Message] checkRefsL2(r:ref(source), rel[Id, Id] fields, Id sname)
	= {error("Sourcefield does not exist: <sname.val>.<source.val>", r@location) }
	when source notin fields[sname];
public default set[Message] checkRefsL2(Scalar _, rel[Id, Id] _, Id _) = {};
module lang::dimitri::levels::l2::Check
extend lang::dimitri::levels::l1::Check;

import lang::dimitri::levels::l2::AST;

public default set[Message] checkRefs(Field f, rel[Id, Id] fields, Id sname) =
	{*checkRefs(r, fields, sname) | /r:ref(_) <- f}
	+ {*checkRefs(r, fields, sname) | /r:crossRef(_, _) <- f};

public set[Message] checkRefs(cr:crossRef(structId, sourceId), rel[Id, Id] fields, Id _) =
	{error("Sourcefield does not exist: <structId.val>.<sourceId.val>", cr@location)}
	when sourceId notin fields[structId];
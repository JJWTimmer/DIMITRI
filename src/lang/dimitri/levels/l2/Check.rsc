module lang::dimitri::levels::l2::Check
extend lang::dimitri::levels::l1::Check;

import ParseTree;
import List;
import Message;
import IO;

import lang::dimitri::levels::l2::AST;

public set[Message] checkRefs(cr:crossRef(structId, sourceId), rel[Id, Id] fields, Id _) =
	{error("Sourcefield does not exist: <structId.val>.<sourceId.val>", cr@location)}
	when sourceId notin fields[structId];
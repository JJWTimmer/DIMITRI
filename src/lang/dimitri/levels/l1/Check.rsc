module lang::dimitri::levels::l1::Check

import ParseTree;
import List;
import Message;

import lang::dimitri::levels::l1::AST;

data Context = ctx(rel[Id, Id] fields);

public set[Message] check(Format f) = check(f, ctx(getFields(f)));

public rel[Id, Id] getFields(format(_, _, _, _, structures)) = {*getFields(s) | s <- structures};
public rel[Id, Id] getFields(Structure::struct(sname, fields)) = {<sname, fname> | field(fname, _, _) <- fields};

public set[Message] check(f:format(name, extensions, defaults, sequence, structures), Context ctx)
	= checkDuplicateStructureNames(structures)
	+ checkUndefinedSequenceNames(sequence.symbols, structures)
	+ checkDuplicateFieldNames(structures)
	+ checkRefs(f, ctx.fields);

public set[Message] checkDuplicateStructureNames(list[Structure] ls) =
	{error("duplicate structure name: <sname.val>", sname@location) | struct(sname, _) <- ls, structs[sname] > 1}
	when structs := distribution([sname | struct(sname, _) <- ls]);

public set[Message] checkUndefinedSequenceNames(list[SequenceSymbol] ssl, list[Structure] structures) {
	set[Message] errors = {};
	structs = { s.name | s <- structures};
	visit(ssl) {
		case SequenceSymbol s : errors += checkUndefinedSequenceName(s, structs);
	};
	return errors;
}

public set[Message] checkUndefinedSequenceName(SequenceSymbol::struct(sname), set[Id] structs) =
	{error("Unknown structure: <sname.val>", sname@location)}
	when sname notin structs;
public default set[Message] checkUndefinedSequenceName(SequenceSymbol _, set[Id] structs) = {};

public set[Message] checkDuplicateFieldNames(list[Structure] ls) = {*checkDuplicateFieldNames(struct.fields) | struct <- ls};
public set[Message] checkDuplicateFieldNames(list[Field] fields) =
	{error("duplicate fieldname: <fname.val>", fname@location) | field(fname, _, _) <- fields, fieldnames[fname] > 1}
	when fieldnames := distribution([fname | field(fname, _, _) <- fields]);

public set[Message] checkRefs(Format fmt, rel[Id, Id] fields) =
	{*checkRefs(struct, fields) | struct <- fmt.structures}
	+ {error("Refs not allowed in defaults", s@location) | /Scalar s <- fmt.defaults, ref(_) := s};
public set[Message] checkRefs(Structure struct, rel[Id, Id] fields) = {*checkRefs(field, fields, struct.name) | field <- struct.fields};
public set[Message] checkRefs(Field f, rel[Id, Id] fields, Id sname) = {*checkRefs(r, fields, sname) | /r:ref(_) <- f};
public set[Message] checkRefs(r:ref(source), rel[Id, Id] fields, Id sname) =
	{error("Sourcefield does not exist: <sname.val>.<source.val>", r@location) }
	when source notin fields[sname];
public default set[Message] checkRefs(Scalar _, rel[Id, Id] _, Id _) = {};


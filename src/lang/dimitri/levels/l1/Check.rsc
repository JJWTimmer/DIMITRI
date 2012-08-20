module lang::dimitri::levels::l1::Check

import ParseTree;
import List;
import Message;

import lang::dimitri::levels::l1::AST;

public set[Message] check(Format f) = check(f, getFields(f), getRefs(f));

public rel[Id, Id] getFields(format(_, _, _, _, structures)) = {*getFields(s) | s <- structures};
public rel[Id, Id] getFields(Structure::struct(sname, fields)) = {<sname, fname> | field(fname, _, _) <- fields};

public rel[Id, Id] getRefs(format(_, _, _, _, structures)) = {*getRefs(struct) | struct <- structures};
public rel[Id, Id] getRefs(Structure::struct(sname, fields)) = {*getRefs(field, sname) | field <- fields};
public rel[Id, Id] getRefs(field(fname, values, _), Id sname) = {<sname, source> | ref(source) <- values};

public set[Message] check(f:format(name, extensions, defaults, sequence, structures), rel[Id, Id] fields, rel[Id, Id] refs) =
	checkDuplicateStructureNames(structures) + checkUndefinedSequenceNames(sequence.symbols, structures) + checkDuplicateFieldNames(structures)
		+ checkRefs(structures, fields);

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

public set[Message] checkRefs(list[Structure] structs, rel[Id, Id] fields) = {*checkRefs(struct, fields) | struct <- structs};
public set[Message] checkRefs(Structure struct, rel[Id, Id] fields) = {*checkRefs(field, fields, struct.name) | field <- struct.fields};
public set[Message] checkRefs(Field f, rel[Id, Id] fields, Id sname) =
	{*checkRefs(val, fields, sname) | val <- f.values}
	+ {*checkRefs(val, fields, sname) | variableSpecifier(_, val) <- f.format};
public set[Message] checkRefs(ref(source), rel[Id, Id] fields, Id sname) =
	{error("Sourcefield does not exist: <sname.val>.<source.val>", source@location) }
	when source notin fields[sname];
public default set[Message] checkRefs(Scalar _, rel[Id, Id] _, Id _) = {};

module lang::dimitri::levels::l7::Check
extend lang::dimitri::levels::l6::Check;

import Set;
import util::ValueUI;

import lang::dimitri::levels::l7::AST;
import lang::dimitri::levels::l7::compiler::Normalize;

alias Replacements = rel[Id struct, int order, Id field, Id repl];
data Context = ctx(rel[Id, Id] fields, rel[Id, Id, Field] completeFields, Replacements replacements);

public set[Message] checkErrorsL7(Format f) = checkErrorsL6(f, ctx(getFieldsL7(f), getCompleteFieldsL7(f), getReplacements(f)));

public set[Message] checkErrorsL6(f:format(name, extensions, defaults, sq, structures), Context cntxt)
	= checkDuplicateStructureNames(structures)
	+ checkUndefinedSequenceNames(sq.symbols, structures)
	+ checkDuplicateFieldNames(structures)
	+ checkRefs(f, cntxt.fields)
	+ typeCheckScalars(defaults, structures, cntxt)
	+ checkScalarSugar(f)
	+ checkTerminators(structures, cntxt)
	+ checkOverrides(structures, cntxt);

public rel[Id, Id] getFieldsL7(format(_, _, _, _, structures)) {
	parents = {*getFieldsL7(s) | s:Structure::struct(_, _) <- structures};
	
	unresolvable = { st |st:Structure::struct(_, pname, _) <- structures, pname notin parents<0> };
	resolvable = { st |st:Structure::struct(_, pname, _) <- structures, pname in parents<0> };
	
	solve(unresolvable, resolvable) {
		parents += {*getFieldsL7(parents, s) | s:Structure::struct(_, _, _) <- resolvable};
		unresolvable = { s |s <- unresolvable, s.name notin parents<0>};
		resolvable = { st |st:Structure::struct(_, pname, _) <- structures, pname in parents<0> };
	}
	
	if ({} !:= unresolvable)
		throw "Inheritance error, please check structure";
	
	return parents;
}
public rel[Id, Id] getFieldsL7(Structure::struct(sname, fields))
	= {<sname, fname> | field(fname, _, _) <- fields};
public rel[Id, Id] getFieldsL7(rel[Id, Id] pfields, Structure::struct(sname, pname, fields))
	= {<sname, fname> | field(fname, _, _) <- fields} //all normal fields
	+ {<sname, fld.name> | fieldOverride(_, flds) <- fields, fld <- flds} //all overriding fields
	+ {<sname, fld> | fld <- pfields[pname], !any(f <- fields, fieldOverride(fld, _) := f )} //all fields from parent without overridden field
	;

public rel[Id, Id, Field] getCompleteFieldsL7(format(_, _, _, _, structures))
	= parents + {*getCompleteFieldsL7(parents, s) | s:Structure::struct(_, _, _) <- structures}
	when parents := {*getCompleteFieldsL7(s) | s:Structure::struct(_, _) <- structures};
public rel[Id, Id, Field] getCompleteFieldsL7(Structure::struct(sname, fields))
	= {<sname, fname, f> | f:field(fname, _, _) <- fields};
public rel[Id, Id, Field] getCompleteFieldsL7(rel[Id, Id, Field] pfields, Structure::struct(sname, pname, fields))
	= {<sname, fname, f> | f:field(fname, _, _) <- fields}
	+ {<sname, fld.name, f> | fieldOverride(_, flds) <- fields, f:fld <- flds}
	+ {<sname, ps[0], ps[1]> | ps <- pfields[pname], !any(f <- fields, fieldOverride(fld, _) := ps[0] )};

public set[Message] checkRefs(field(_, list[Field] overrides), rel[Id, Id] fields, Id sname)
	= {*checkRefs(fld, fields, sname) | fld <- overrides};
	
public set[Message] checkOverrides(list[Structure] structs, Context cntxt) = {*checkOverrides(s, cntxt) | s <- structs};
public set[Message] checkOverrides(Structure::struct(sname, pname, fields), Context cntxt) = {*checkOverrides(fld, sname, pname, cntxt) | fld:fieldOverride(_,_) <- fields};
public set[Message] checkOverrides(Structure::struct(sname, fields), Context cntxt) = { error("Illegal override", fld@location) | fld:fieldOverride(_,_) <- fields};
public set[Message] checkOverrides(Field f, Id sname, Id pname, Context cntxt) {
	//check up the tree if this field can be overridden
	//todo elsewhere: check f: { g: { z; } }
}

private Replacements getReplacements(Format format) {
	//create env
	rel[Id, Id, list[Field]] env = { };
	for (s <- format.structures) {
		if (struct(sname, pname, fields) := s) {
			env += <sname, pname, fields>;
		}
		else {
			env += <s.name, id(""), s.fields>;
		}
	}
	
	Replacements replacements = {};

	//find all inheritance structs and expand
	format.structures = for (s <- format.structures) {
		if (chld:struct(Id sname, Id _, list[Field] _) := s) {
			<flds, replacements> = removeInheritance(sname, env, replacements);
			append struct(sname, flds);
		} else {
			append s;
		}
	}

	return replacements;
}
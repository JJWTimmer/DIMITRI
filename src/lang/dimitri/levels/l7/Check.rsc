module lang::dimitri::levels::l7::Check
extend lang::dimitri::levels::l6::Check;

import Relation;
import Set;
import util::ValueUI;
import analysis::graphs::Graph;

import lang::dimitri::levels::l7::AST;
import lang::dimitri::levels::l7::compiler::Normalize;

alias Replacements = rel[Id struct, int order, Id field, Id repl];
data Context = ctx(rel[Id, Id] fields, rel[Id, Id, Field] completeFields, rel[Id, Id] baseFields, Replacements replacements);

public set[Message] checkErrorsL7(Format f) = checkErrorsL7(f, ctx(getFieldsL7(f), getCompleteFieldsL7(f), getBaseFields(f), getReplacements(f)));

public set[Message] checkErrorsL7(f:format(name, extensions, defaults, sq, structures), Context cntxt)
	= checkDuplicateStructureNames(structures)
	+ checkUndefinedSequenceNames(sq.symbols, structures)
	+ checkDuplicateFieldNames(structures)
	+ checkRefsL2(f, cntxt.fields)
	+ typeCheckScalarsL7(defaults, structures, cntxt)
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

public rel[Id, Id] getBaseFields(format(_, _, _, _, structures)) {
	parents = {*getBaseFields(s) | s:Structure::struct(_, _) <- structures};
	
	unresolvable = { st |st:Structure::struct(_, pname, _) <- structures, pname notin parents<0> };
	resolvable = { st |st:Structure::struct(_, pname, _) <- structures, pname in parents<0> };
	
	solve(unresolvable, resolvable) {
		parents += {*getBaseFields(parents, s) | s:Structure::struct(_, _, _) <- resolvable};
		unresolvable = { s |s <- unresolvable, s.name notin parents<0>};
		resolvable = { st |st:Structure::struct(_, pname, _) <- structures, pname in parents<0> };
	}
	
	if ({} !:= unresolvable)
		throw "Inheritance error, please check structure";
	
	return parents;
}
public rel[Id, Id] getBaseFields(Structure::struct(sname, fields))
	= {<sname, fname> | field(fname, _, _) <- fields};
public rel[Id, Id] getBaseFields(rel[Id, Id] pfields, Structure::struct(sname, pname, fields))
	= {<sname, fname> | field(fname, _, _) <- fields} //all normal fields
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

public set[Message] checkRefsL2(field(_, list[Field] overrides), rel[Id, Id] fields, Id sname)
	= {*checkRefs(fld, fields, sname) | fld <- overrides};
	
public set[Message] checkOverrides(list[Structure] structs, Context cntxt)
	= {*checkOverrides(s, cntxt) | s <- structs};
public set[Message] checkOverrides(Structure::struct(sname, pname, fields), Context cntxt)
	= {*checkOverrides(fld, sname, pname, cntxt) | fld:fieldOverride(_,_) <- fields};
public set[Message] checkOverrides(Structure::struct(sname, fields), Context cntxt)
	= { error("Base field does not exist", fld.name@location) | fld:fieldOverride(_,_) <- fields};
public set[Message] checkOverrides(fieldOverride(fname, overrides), Id sname, Id pname, Context cntxt) {
	set[Message] res = {};
	flds = cntxt.fields[pname];
	
	if (fname notin flds)
		res += {error("Base fields does not exist", fname@location)};

	
	fieldset = { fn | fn <- cntxt.baseFields[sname]};
	
	res = res + { *checkOverride(o, fieldset, cntxt) | o <- overrides};
	
	return res;
	
}

public set[Message] checkOverride(f:fieldOverride(fname, overrides), set[Id] fieldset, Context cntxt)
	= {error("cannot nest overrides", f@location)};

public set[Message] checkOverride(field(fname, _, _), set[Id] fieldset, Context cntxt)
	= {error("duplicate fieldname", fname@location)}
	when fname in fieldset;

public default set[Message] checkOverride(Field f, set[Id] _, Context _) = {};

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

public set[Message] typeCheckScalarsL7(set[FormatSpecifier] defaults, list[Structure] structs, Context cntxt)
	= typeCheckScalars(defaults, cntxt)
	+ typeCheckScalarsL7(structs, cntxt);

public set[Message] typeCheckScalarsL7(list[Structure] structs, Context cntxt)
	= { *typeCheckScalars(e, st.name, cntxt) | st <- structs, f <- st.fields, f has values, e <- f.values}
	+ { *typeCheckScalars(se, st.name, cntxt) | st <- structs, f <- st.fields, f has overrides, sf <- f.overrides, sf has values, se <- sf.values}
	+ { *typeCheckScalars(e, st.name, cntxt) | st <- structs, f <- st.fields, f has format, variableSpecifier(_, e) <- f.format};
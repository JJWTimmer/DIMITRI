module lang::dimitri::levels::l1::compiler::Annotate

import IO;
import Set;
import List;

import lang::dimitri::levels::l1::AST;

data Reference = local();
data Dependency = dependency(str name);

anno Reference Field @ ref; //Referenced by a future field
anno Dependency Field @ refdep; //Referenced by a previous field

anno bool SequenceSymbol @ allowEOF;

alias RefEnv = rel[Id struct, Id field, Reference ref];
alias DepEnv = rel[Id struct, Id field, Dependency dep];

public Format annotate(Format format) = annotateAllowEOF(annotateFieldRefs(format));

public Format annotateFieldRefs(Format format) =
	visit (format) {
		case struct(sname, fields) => annotateFieldRefs(sname, fields, refenv, refdepenv)
	}
	when refenv := makeReferenceEnvironment(format),
	refdepenv := makeDependencyEnvironment(format);

public Structure annotateFieldRefs(Id sname, list[Field] fields, RefEnv refenv, DepEnv refdepenv) =
	struct(sname, annoFields) when
	annoFields := [getDepAnnotation(sname, getRefAnnotation(sname, f, refenv), refdepenv) | Field f <- fields];
	
public Field getRefAnnotation(Id sname, Field fld, RefEnv env) = fld[@ref=r] when annotation := env[sname, fld.name], {r} := annotation;
public default Field getRefAnnotation(Id sname, Field fld, RefEnv env) = fld;

public Field getDepAnnotation(Id sname, Field fld, DepEnv env) = fld[@refdep=r] when annotation := env[sname, fld.name], {r} := annotation;
public default Field getDepAnnotation(Id sname, Field fld, DepEnv env) = fld;

public Format annotateAllowEOF(Format format) {
	bool allowEOF = true;
	format.sequence.symbols = for (symbol <- format.sequence.symbols) {
		if (choiceSeq(set[SequenceSymbol] symbols) := symbol, fixedOrderSeq([]) notin symbols) {
			allowEOF = false;
		}
		append symbol[@allowEOF = allowEOF];
	}
	return format;
}

/////////////

public RefEnv makeReferenceEnvironment(Format format) {
	RefEnv env = {};
	rel[Id struct, Id field, bool seen] order = {};
	Id sname = id("");
	Id fname = id("");

	top-down visit (format) {
		case struct(name, _): sname = name;
		case Field f : {
			fname = f.name;
			order += <sname, fname, true>;
		}
		case Scalar s : env = makeReferenceEnvironment(s, sname, fname, env, order);
	}
	return env;
}


public RefEnv makeReferenceEnvironment(ref(sourceField), Id sname, Id fname, RefEnv env, rel[Id struct, Id field, bool seen] order)
	= makeReferenceRef(sname, sourceField, env, order);
public default RefEnv makeReferenceEnvironment(Scalar _, Id _, Id _, RefEnv env, rel[Id struct, Id field, bool seen] _)
	= env;

//target struct == source struct, check in call
public RefEnv makeReferenceRef(Id sname, Id fname, RefEnv env, rel[Id struct, Id field, bool seen] order)
	= env + res
	when !isEmpty(order[sname, fname]),
	res := {<sname, fname, local()>};
public default RefEnv makeReferenceRef(Id sname, Id fname, RefEnv env, rel[Id struct, Id field, bool seen] order) = env;

///////////////////////////////////////////////

public rel[Id, Id, Dependency] makeDependencyEnvironment(Format format) {
	rel[Id struct, Id field, Id dep] env = {};
	rel[Id struct, Id field, int count] order = {};
	DepEnv deps = {};
	Id sname = id("");
	Id fname = id("");
	int count = 0;

	top-down visit (format) {
		case struct(name, _): {
			sname = name;
			count = 0;
		}
		case Field f : {
			fname = f.name;
			order += <sname, fname, count>;
			count += 1;
		}
		case Scalar scal : env = makeDependencyEnvironment(scal, sname, fname, env, order);
	}
	
	for (<struct, field> <- env<0, 1>) {
		mx = max(order[struct, env[struct, field]]);
		Dependency dep = dependency([v.val | t <- order, <struct, Id v, mx> := t][0]);
		deps += <struct, field, dep>;
	}
	return deps;
}

public rel[Id, Id, Id] makeDependencyEnvironment(ref(Id source), Id sname, Id fname, rel[Id, Id, Id] env, rel[Id, Id, int] order) =
	makeDependencyRef(sname, fname, source, env, order);
	
public default rel[Id, Id, Id] makeDependencyEnvironment(Scalar _, Id _, Id _, rel[Id, Id, Id] env, rel[Id, Id , int] _) = env;

//target struct == source struct, check in call
public rel[Id, Id, Id] makeDependencyRef(Id sname, Id fname, Id source, rel[Id, Id, Id] env, rel[Id, Id, int] order)
	= env + res
	when isEmpty(order[sname, source]),
	res := {<sname, fname, source>};
public default rel[Id, Id, Id] makeDependencyRef(Id sname, Id fname, Id source, rel[Id, Id, Id] env, rel[Id, Id, int] order) = env;
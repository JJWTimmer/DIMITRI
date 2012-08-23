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

public Format annotate(Format format) {
	return annotateSymbols(annotateFieldRefs(format));
}

public Format annotateFieldRefs(Format format) {
	RefEnv refenv = makeReferenceEnvironment(format);
	DepEnv refdepenv = makeDependencyEnvironment(format);

	Id sname = id("");
	return top-down visit (format) {
		case struct(Id name, _): sname = name;
		case Field f : {
			Id fname = f.name;
			set[Reference] annotation = refenv[sname, fname];
			if ({r} := annotation) {
				f@ref = r;
			}
			
			set[Dependency] dependency = refdepenv[sname, fname];
			if ({d} := dependency) {
				f@refdep = d;
			}

			insert f;
		}
	}
}

public Format annotateSymbols(Format format) {
	bool allowEOF = true;
	for (i <- [size(format.sequence.symbols)-1..0]) {
		if (choiceSeq(set[SequenceSymbol] symbols) := format.sequence.symbols[i]) {
			if (fixedOrderSeq([]) notin symbols) {
				allowEOF = false;
			}
		}
		format.sequence.symbols[i]@allowEOF = allowEOF;
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


public RefEnv makeReferenceEnvironment(ref(sourceField), Id sname, Id fname, RefEnv env, rel[Id struct, Id field, bool seen] order) =
	makeReferenceRef(sname, sourceField, env, order);
public default RefEnv makeReferenceEnvironment(Scalar _, Id _, Id _, RefEnv env, rel[Id struct, Id field, bool seen] _) = env;

//target struct == source struct, check in call
public RefEnv makeReferenceRef(Id sname, Id fname, RefEnv env, rel[Id struct, Id field, bool seen] order) {
	if (!isEmpty(order[sname, fname])) {
		env += <sname, fname, local()>;
	}
	return env;
}

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
		case Scalar s: env = makeDependencyEnvironment(s, sname, fname, env, order);

	}
	
	for (<struct, field> <- env<0, 1>) {
		mx = max(order[struct, env[struct, field]]);
		Dependency dep = dependency([v.val | t <- order, <struct, Id v, mx> := t][0]);
		deps += <struct, field, dep>;
	}
	return deps;
}

public rel[Id struct, Id field, Id dep] makeDependencyEnvironment(ref(Id source), Id sname, Id fname, DepEnv env, rel[Id struct, Id field, int count] order) =
	makeDependencyRef(sname, fname, source, env, order);
	
public default rel[Id struct, Id field, Id dep] makeDependencyEnvironment(Scalar _, Id _, Id _, rel[Id struct, Id field, Id dep] env, rel[Id struct, Id field, int count] _) = env;

//target struct == source struct, check in call
public rel[Id struct, Id field, Id dep] makeDependencyRef(Id sname, Id fname, Id source, rel[Id struct, Id field, Id dep] env, rel[Id struct, Id field, int count] order) {
	if (isEmpty(order[sname, source])) {
		env += <sname, fname, source>;
	}
	return env;
}

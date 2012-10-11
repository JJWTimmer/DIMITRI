module lang::dimitri::levels::l3::compiler::Annotate
extend lang::dimitri::levels::l2::compiler::Annotate;

import lang::dimitri::levels::l3::AST;

public Format annotateL3(Format format) = annotateAllowEOF(annotateFieldRefsL3(format));

public Format annotateFieldRefsL3(Format format) =
	visit (format) {
		case struct(sname, fields) => annotateFieldRefsL2(sname, fields, refenv, refdepenv)
	}
	when refenv := makeReferenceEnvironmentL3(format),
	refdepenv := makeDependencyEnvironmentL3(format);
	
//----------------------------------------------------------------------------------
	
public RefEnv makeReferenceEnvironmentL3(Format format) {
	RefEnv env = {};
	rel[Id struct, Id field, bool seen] order = {};

	for (s <- format.structures, f <- s.fields) {
		order += <s.name, f.name, true>;
		top-down-break visit(f) {
			case Scalar sc : env = makeReferenceEnvironment(sc, s.name, f.name, env, order);
			case Argument arg : env = makeReferenceEnvironment(arg, s.name, f.name, env, order);
		}
	}
	return env;
}

public RefEnv makeReferenceEnvironment(refArg(sourceField), Id sname, Id fname, RefEnv env, rel[Id struct, Id field, bool seen] order)
	= makeReferenceRef(sname, sourceField, env, order);
public RefEnv makeReferenceEnvironment(crossRefArg(sourceStruct, sourceField), Id sname, Id fname, RefEnv env, rel[Id, Id, bool] order)
	= makeReferenceRef(sourceStruct, sourceField, env)
	when sourceStruct != sname;
public RefEnv makeReferenceEnvironment(crossRefArg(struct, source), struct, Id fname, RefEnv env, rel[Id, Id, bool] order)
	= makeReferenceRef(struct, source, env, order);
public default RefEnv makeReferenceEnvironment(Argument _, Id _, Id _, RefEnv env, rel[Id struct, Id field, bool seen] _)
	= env;
//----------------------------------------------------------------------------------
public rel[Id, Id, Dependency] makeDependencyEnvironmentL3(Format format) {
	rel[Id struct, Id field, Id dep] env = {};
	rel[Id struct, Id field, int count] order = {};
	DepEnv deps = {};
	int count = 0;

	for (s <- format.structures) {
		count = 0;
		for (f <- s.fields) {
			order += <s.name, f.name, count>;
			count += 1;
			top-down-break visit(f) {
				case Scalar sc : env = makeDependencyEnvironment(sc, s.name, f.name, env, order);
				case Argument arg : env = makeDependencyEnvironment(arg, s.name, f.name, env, order);
			}
		}
	}
	
	for (<struct, field> <- env<0, 1>) {
		mx = max(order[struct, env[struct, field]]);
		Dependency dep = dependency([v.val | t <- order, <struct, Id v, mx> := t][0]);
		deps += <struct, field, dep>;
	}
	
	return deps;
}

public rel[Id, Id, Id] makeDependencyEnvironment(refArg(source), Id sname, Id fname, rel[Id, Id, Id] env, rel[Id, Id, int] order)
	= makeDependencyRef(sname, fname, source, env, order);
public rel[Id, Id, Id] makeDependencyEnvironment(crossRefArg(sourceStruct, sourceField), sourceStruct, Id fname, rel[Id, Id, Id] env, rel[Id, Id, int] order)
	= env;
public default rel[Id, Id, Id] makeDependencyEnvironment(Argument _, Id _, Id _, rel[Id, Id, Id] env, rel[Id, Id, int] _)
	= env;
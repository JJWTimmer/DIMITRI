module lang::dimitri::levels::l5::compiler::Annotate
extend lang::dimitri::levels::l4::compiler::Annotate;

import lang::dimitri::levels::l5::AST;

anno Reference Field @ size;
anno Dependency Field @ sizedep;

public Format annotateL5(Format format) = annotateAllowEOF(annotateFieldRefsL5(format));

public Format annotateFieldRefsL5(Format format) =
	visit (format) {
		case struct(sname, fields) => annotateFieldRefsL5(sname, fields, refenv, refdepenv, sizeenv, refsizeenv)
	}
	when refenv := makeReferenceEnvironment(format),
	refdepenv := makeDependencyEnvironment(format),
	sizeenv := makeSizeReferenceEnvironment(format),
	refsizeenv := makeSizeDependencyEnvironment(format);

public Structure annotateFieldRefsL5(Id sname, list[Field] fields, RefEnv refenv, DepEnv refdepenv, RefEnv sizeenv, DepEnv refsizeenv){
	annoFields = for ( f <- fields) {
		nf = getRefAnnotationL2(sname, f, refenv);
		nf = getDepAnnotation(sname, nf, refdepenv);
		nf = getSizeRefAnnotation(sname, nf, sizeenv);
		nf = getSizeDepAnnotation(sname, nf, refsizeenv);
		append nf;
	}
	return struct(sname, annoFields);
}

public Field getSizeRefAnnotation(Id sname, Field fld, RefEnv env)
	= fld[@size=r]
	when {r} := env[sname, fld.name];
public default Field getSizeRefAnnotation(Id sname, Field fld, RefEnv env)
	= fld;

public Field getSizeDepAnnotation(Id sname, Field fld, DepEnv env)
	= fld[@sizedep=r]
	when rs := env[sname, fld.name],
	size(rs) > 0,
	r := getOneFrom(rs);
public default Field getSizeDepAnnotation(Id sname, Field fld, DepEnv env) = fld;

//------------------------------------------------------------------------

public RefEnv makeSizeReferenceEnvironment(Format format) {
	RefEnv env = {};
	rel[Id struct, Id field, bool seen] order = {};

	for (s <- format.structures, f <- s.fields) {
		order += <s.name, f.name, true>;
		top-down-break visit(f) {
			case Scalar sc : env = makeSizeReferenceEnvironment(sc, s.name, f.name, env, order);
		}
	}
	return env;
}
	
public RefEnv makeSizeReferenceEnvironment(lengthOf(ref(sourceField)), Id sname, Id fname, RefEnv env, rel[Id, Id, bool] order)
	= makeReferenceRef(sname, sourceField, env, order);
public RefEnv makeSizeReferenceEnvironment(lengthOf(crossRef(sourceStruct, sourceField)), Id sname, Id fname, RefEnv env, rel[Id, Id, bool] order)
	= makeReferenceRef(sourceStruct, sourceField, env);
public RefEnv makeSizeReferenceEnvironment(parentheses(sc), Id sname, Id fname, RefEnv env, rel[Id, Id, bool] order)
	= makeSizeReferenceEnvironment(sc, sname, fname, env, order);
public RefEnv makeSizeReferenceEnvironment(negate(sc), Id sname, Id fname, RefEnv env, rel[Id, Id, bool] order)
	= makeSizeReferenceEnvironment(sc, sname, fname, env, order);
public RefEnv makeSizeReferenceEnvironment(not(sc), Id sname, Id fname, RefEnv env, rel[Id, Id, bool] order)
	= makeSizeReferenceEnvironment(sc, sname, fname, env, order);
public RefEnv makeSizeReferenceEnvironment(Scalar::power(a, b), Id sname, Id fname, RefEnv env, rel[Id, Id, bool] order)
	= makeSizeReferenceEnvironment(a, sname, fname, env, order) + makeSizeReferenceEnvironment(b, sname, fname, env, order);
public RefEnv makeSizeReferenceEnvironment(times(a, b), Id sname, Id fname, RefEnv env, rel[Id, Id, bool] order)
	= makeSizeReferenceEnvironment(a, sname, fname, env, order) + makeSizeReferenceEnvironment(b, sname, fname, env, order);
public RefEnv makeSizeReferenceEnvironment(divide(a, b), Id sname, Id fname, RefEnv env, rel[Id, Id, bool] order)
	= makeSizeReferenceEnvironment(a, sname, fname, env, order) + makeSizeReferenceEnvironment(b, sname, fname, env, order);
public RefEnv makeSizeReferenceEnvironment(add(a, b), Id sname, Id fname, RefEnv env, rel[Id, Id, bool] order)
	= makeSizeReferenceEnvironment(a, sname, fname, env, order) + makeSizeReferenceEnvironment(b, sname, fname, env, order);
public RefEnv makeSizeReferenceEnvironment(minus(a, b), Id sname, Id fname, RefEnv env, rel[Id, Id, bool] order)
	= makeSizeReferenceEnvironment(a, sname, fname, env, order) + makeSizeReferenceEnvironment(b, sname, fname, env, order);
public RefEnv makeSizeReferenceEnvironment(range(a, b), Id sname, Id fname, RefEnv env, rel[Id, Id, bool] order)
	= makeSizeReferenceEnvironment(a, sname, fname, env, order) + makeSizeReferenceEnvironment(b, sname, fname, env, order);
public RefEnv makeSizeReferenceEnvironment(or(a, b), Id sname, Id fname, RefEnv env, rel[Id, Id, bool] order)
	= makeSizeReferenceEnvironment(a, sname, fname, env, order) + makeSizeReferenceEnvironment(b, sname, fname, env, order);
public default RefEnv makeSizeReferenceEnvironment(Scalar _, Id _, Id _, RefEnv env, rel[Id, Id, bool] _)
	= env;

//------------------------------------------------------------------------

public rel[Id, Id, Dependency] makeSizeDependencyEnvironment(Format format) {
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
				case Scalar sc : env = makeSizeDependencyEnvironment(sc, s.name, f.name, env, order);
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

public rel[Id, Id, Id] makeSizeDependencyEnvironment(lengthOf(ref(sourceField)), Id sname, Id fname, rel[Id, Id, Id] env, rel[Id, Id, int] order)
	= makeDependencyRef(sname, fname, sourceField, env, order);
public rel[Id, Id, Id] makeSizeDependencyEnvironment(lengthOf(crossRef(_, _)), Id sname, Id fname, rel[Id, Id, Id] env, rel[Id, Id, int] order)
	= env;
public rel[Id, Id, Id] makeSizeDependencyEnvironment(parentheses(sc), Id sname, Id fname, rel[Id, Id, Id] env, rel[Id, Id, int] order)
	= makeSizeDependencyEnvironment(sc, sname, fname, env, order);
public rel[Id, Id, Id] makeSizeDependencyEnvironment(negate(sc), Id sname, Id fname, rel[Id, Id, Id] env, rel[Id, Id, int] order)
	= makeSizeDependencyEnvironment(sc, sname, fname, env, order);
public rel[Id, Id, Id] makeSizeDependencyEnvironment(not(sc), Id sname, Id fname, rel[Id, Id, Id] env, rel[Id, Id, int] order)
	= makeSizeDependencyEnvironment(sc, sname, fname, env, order);
public rel[Id, Id, Id] makeSizeDependencyEnvironment(Scalar::power(a, b), Id sname, Id fname, rel[Id, Id, Id] env, rel[Id, Id, int] order)
	= makeSizeDependencyEnvironment(a, sname, fname, env, order) + makeSizeDependencyEnvironment(b, sname, fname, env, order);
public rel[Id, Id, Id] makeSizeDependencyEnvironment(times(a, b), Id sname, Id fname, rel[Id, Id, Id] env, rel[Id, Id, int] order)
	= makeSizeDependencyEnvironment(a, sname, fname, env, order) + makeSizeDependencyEnvironment(b, sname, fname, env, order);
public rel[Id, Id, Id] makeSizeDependencyEnvironment(divide(a, b), Id sname, Id fname, rel[Id, Id, Id] env, rel[Id, Id, int] order)
	= makeSizeDependencyEnvironment(a, sname, fname, env, order) + makeSizeDependencyEnvironment(b, sname, fname, env, order);
public rel[Id, Id, Id] makeSizeDependencyEnvironment(add(a, b), Id sname, Id fname, rel[Id, Id, Id] env, rel[Id, Id, int] order)
	= makeSizeDependencyEnvironment(a, sname, fname, env, order) + makeSizeDependencyEnvironment(b, sname, fname, env, order);
public rel[Id, Id, Id] makeSizeDependencyEnvironment(minus(a, b), Id sname, Id fname, rel[Id, Id, Id] env, rel[Id, Id, int] order)
	= makeSizeDependencyEnvironment(a, sname, fname, env, order) + makeSizeDependencyEnvironment(b, sname, fname, env, order);
public rel[Id, Id, Id] makeSizeDependencyEnvironment(range(a, b), Id sname, Id fname, rel[Id, Id, Id] env, rel[Id, Id, int] order)
	= makeSizeDependencyEnvironment(a, sname, fname, env, order) + makeSizeDependencyEnvironment(b, sname, fname, env, order);
public rel[Id, Id, Id] makeSizeDependencyEnvironment(or(a, b), Id sname, Id fname, rel[Id, Id, Id] env, rel[Id, Id, int] order)
	= makeSizeDependencyEnvironment(a, sname, fname, env, order) + makeSizeDependencyEnvironment(b, sname, fname, env, order);
public default rel[Id, Id, Id] makeSizeDependencyEnvironment(Scalar _, Id _, Id _, rel[Id, Id, Id] env, rel[Id, Id, int] _)
	= env;
	
//------------------------------------------------------------------------
public RefEnv makeReferenceEnvironment(lengthOf(ref(id(_))), Id _, Id _, RefEnv env, rel[Id, Id, bool] _)
	= env;
public RefEnv makeReferenceEnvironment(lengthOf(crossRef(id(_), id(_))), Id _, Id _, RefEnv env, rel[Id, Id, bool] _)
	= env;
public rel[Id, Id, Id] makeSizeDependencyEnvironment(lengthOf(ref(_)), Id _, Id _, rel[Id, Id, Id] env, rel[Id, Id, int] _)
	= env;
public rel[Id, Id, Id] makeSizeDependencyEnvironment(lengthOf(crossRef(_, _)), Id sname, Id fname, rel[Id, Id, Id] env, rel[Id, Id, int] order)
	= env;
module lang::dimitri::levels::l2::compiler::Annotate
extend lang::dimitri::levels::l1::compiler::Annotate;

import lang::dimitri::levels::l2::AST;

data Reference = global();

public Format annotateL2(Format format) = annotateAllowEOF(annotateFieldRefsL2(format));

public Format annotateFieldRefsL2(Format format) =
	visit (format) {
		case struct(sname, fields) => annotateFieldRefsL2(sname, fields, refenv, refdepenv)
	}
	when refenv := makeReferenceEnvironment(format),
	refdepenv := makeDependencyEnvironment(format);

public Structure annotateFieldRefsL2(Id sname, list[Field] fields, RefEnv refenv, DepEnv refdepenv) {
	annoFields = for ( f <- fields) {
		nf = getRefAnnotationL2(sname, f, refenv);
		nf = getDepAnnotation(sname, nf, refdepenv);
		append nf;
	}
	return struct(sname, annoFields);
}

public Field getRefAnnotationL2(Id sname, Field fld, RefEnv env)
	= fld[@ref=global()]
	when annotation := env[sname, fld.name],
	size(annotation) > 0,
	global() in annotation;
public Field getRefAnnotationL2(Id sname, Field fld, RefEnv env)
	= fld[@ref=local()]
	when annotation := env[sname, fld.name],
	size(annotation) > 0,
	global() notin annotation;
public default Field getRefAnnotationL2(Id sname, Field fld, RefEnv env)
	= fld;

//------------------------------------------------------------------------

public rel[Id, Id, Id] makeDependencyEnvironment(crossRef(sourceStruct, sourceField), sourceStruct, Id fname, rel[Id, Id, Id] env, rel[Id, Id, int] order)
	= env;

//------------------------------------------------------------------------

public RefEnv makeReferenceEnvironment(crossRef(sourceStruct, sourceField), Id sname, Id fname, RefEnv env, rel[Id, Id, bool] order)
	= makeReferenceRef(sourceStruct, sourceField, env)
	when sourceStruct != sname;

public RefEnv makeReferenceEnvironment(crossRef(struct, source), struct, Id fname, RefEnv env, rel[Id, Id, bool] order)
	= makeReferenceRef(struct, source, env, order);

public RefEnv makeReferenceRef(Id sname, Id fname, RefEnv env)
	= env + {<sname, fname, global()>};
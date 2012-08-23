module lang::dimitri::levels::l2::compiler::Annotate

extend lang::dimitri::levels::l1::compiler::Annotate;

import lang::dimitri::levels::l2::AST;

data Reference = global();

public DepEnv makeDependencyEnvironment(ref(struct, source), struct, Id fname, DepEnv env, rel[Id struct, Id field, int count] order) =
	makeDependencyRef(sname, fname, source, env, order);

///////////////////////////////////////

public RefEnv makeReferenceEnvironment(crossRef(sourceStruct, sourceField), Id sname, Id fname, RefEnv env, rel[Id struct, Id field, bool seen] order) =
	makeReferenceRef(sourceStruct, sourceField, env) when sourceStruct != sname;

public RefEnv makeReferenceEnvironment(crossRef(struct, source), struct, Id fname, RefEnv env, rel[Id struct, Id field, bool seen] order) =
	makeReferenceRef(struct, source, env, order);

public RefEnv makeReferenceRef(Id sname, Id fname, RefEnv env) {
	env += <sname, fname, global()>;
	return env;
}
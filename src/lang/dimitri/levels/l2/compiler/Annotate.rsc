module lang::dimitri::levels::l2::compiler::Annotate

extend lang::dimitri::levels::l1::compiler::Annotate;

import lang::dimitri::levels::l2::AST;

data Reference = global();

public rel[Id, Id, Id] makeDependencyEnvironment(crossRef(sourceStruct, sourceField), sourceStruct, Id fname, rel[Id, Id, Id] env, rel[Id, Id, int] order) = env;

///////////////////////////////////////

public RefEnv makeReferenceEnvironment(crossRef(sourceStruct, sourceField), Id sname, Id fname, RefEnv env, rel[Id, Id, bool] order) =
	makeReferenceRef(sourceStruct, sourceField, env) when sourceStruct != sname;

public RefEnv makeReferenceEnvironment(crossRef(struct, source), struct, Id fname, RefEnv env, rel[Id, Id, bool] order) =
	makeReferenceRef(struct, source, env, order);

public RefEnv makeReferenceRef(Id sname, Id fname, RefEnv env) = env + {<sname, fname, global()>};
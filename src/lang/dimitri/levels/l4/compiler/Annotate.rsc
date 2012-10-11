module lang::dimitri::levels::l4::compiler::Annotate
extend lang::dimitri::levels::l3::compiler::Annotate;

import lang::dimitri::levels::l4::AST;

public rel[Id, Id, Id] makeDependencyEnvironment(parentheses(sc), Id sname, Id fname, rel[Id, Id, Id] env, rel[Id, Id, int] order)
	= makeDependencyEnvironment(sc, sname, fname, env, order);
public rel[Id, Id, Id] makeDependencyEnvironment(negate(sc), Id sname, Id fname, rel[Id, Id, Id] env, rel[Id, Id, int] order)
	= makeDependencyEnvironment(sc, sname, fname, env, order);
public rel[Id, Id, Id] makeDependencyEnvironment(not(sc), Id sname, Id fname, rel[Id, Id, Id] env, rel[Id, Id, int] order)
	= makeDependencyEnvironment(sc, sname, fname, env, order);
public rel[Id, Id, Id] makeDependencyEnvironment(Scalar::power(a, b), Id sname, Id fname, rel[Id, Id, Id] env, rel[Id, Id, int] order)
	= makeDependencyEnvironment(a, sname, fname, env, order) + makeDependencyEnvironment(b, sname, fname, env, order);
public rel[Id, Id, Id] makeDependencyEnvironment(times(a, b), Id sname, Id fname, rel[Id, Id, Id] env, rel[Id, Id, int] order)
	= makeDependencyEnvironment(a, sname, fname, env, order) + makeDependencyEnvironment(b, sname, fname, env, order);
public rel[Id, Id, Id] makeDependencyEnvironment(divide(a, b), Id sname, Id fname, rel[Id, Id, Id] env, rel[Id, Id, int] order)
	= makeDependencyEnvironment(a, sname, fname, env, order) + makeDependencyEnvironment(b, sname, fname, env, order);
public rel[Id, Id, Id] makeDependencyEnvironment(add(a, b), Id sname, Id fname, rel[Id, Id, Id] env, rel[Id, Id, int] order)
	= makeDependencyEnvironment(a, sname, fname, env, order) + makeDependencyEnvironment(b, sname, fname, env, order);
public rel[Id, Id, Id] makeDependencyEnvironment(minus(a, b), Id sname, Id fname, rel[Id, Id, Id] env, rel[Id, Id, int] order)
	= makeDependencyEnvironment(a, sname, fname, env, order) + makeDependencyEnvironment(b, sname, fname, env, order);
public rel[Id, Id, Id] makeDependencyEnvironment(range(a, b), Id sname, Id fname, rel[Id, Id, Id] env, rel[Id, Id, int] order)
	= makeDependencyEnvironment(a, sname, fname, env, order) + makeDependencyEnvironment(b, sname, fname, env, order);
public rel[Id, Id, Id] makeDependencyEnvironment(or(a, b), Id sname, Id fname, rel[Id, Id, Id] env, rel[Id, Id, int] order)
	= makeDependencyEnvironment(a, sname, fname, env, order) + makeDependencyEnvironment(b, sname, fname, env, order);


public RefEnv makeReferenceEnvironment(parentheses(sc), Id sname, Id fname, RefEnv env, rel[Id, Id, bool] order)
	= makeReferenceEnvironment(sc, sname, fname, env, order);
public RefEnv makeReferenceEnvironment(negate(sc), Id sname, Id fname, RefEnv env, rel[Id, Id, bool] order)
	= makeReferenceEnvironment(sc, sname, fname, env, order);
public RefEnv makeReferenceEnvironment(not(sc), Id sname, Id fname, RefEnv env, rel[Id, Id, bool] order)
	= makeReferenceEnvironment(sc, sname, fname, env, order);
public RefEnv makeReferenceEnvironment(Scalar::power(a, b), Id sname, Id fname, RefEnv env, rel[Id, Id, bool] order)
	= makeReferenceEnvironment(a, sname, fname, env, order) + makeReferenceEnvironment(b, sname, fname, env, order);
public RefEnv makeReferenceEnvironment(times(a, b), Id sname, Id fname, RefEnv env, rel[Id, Id, bool] order)
	= makeReferenceEnvironment(a, sname, fname, env, order) + makeReferenceEnvironment(b, sname, fname, env, order);
public RefEnv makeReferenceEnvironment(divide(a, b), Id sname, Id fname, RefEnv env, rel[Id, Id, bool] order)
	= makeReferenceEnvironment(a, sname, fname, env, order) + makeReferenceEnvironment(b, sname, fname, env, order);
public RefEnv makeReferenceEnvironment(add(a, b), Id sname, Id fname, RefEnv env, rel[Id, Id, bool] order)
	= makeReferenceEnvironment(a, sname, fname, env, order) + makeReferenceEnvironment(b, sname, fname, env, order);
public RefEnv makeReferenceEnvironment(minus(a, b), Id sname, Id fname, RefEnv env, rel[Id, Id, bool] order)
	= makeReferenceEnvironment(a, sname, fname, env, order) + makeReferenceEnvironment(b, sname, fname, env, order);
public RefEnv makeReferenceEnvironment(range(a, b), Id sname, Id fname, RefEnv env, rel[Id, Id, bool] order)
	= makeReferenceEnvironment(a, sname, fname, env, order) + makeReferenceEnvironment(b, sname, fname, env, order);
public RefEnv makeReferenceEnvironment(or(a, b), Id sname, Id fname, RefEnv env, rel[Id, Id, bool] order)
	= makeReferenceEnvironment(a, sname, fname, env, order) + makeReferenceEnvironment(b, sname, fname, env, order);
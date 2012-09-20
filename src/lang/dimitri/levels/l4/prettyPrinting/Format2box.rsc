module lang::dimitri::levels::l4::prettyPrinting::Format2box
extend lang::dimitri::levels::l3::prettyPrinting::Format2box;

import lang::dimitri::levels::l4::AST;

public Box scalar2box(parentheses(Scalar exp))= H([L("("), scalar2box(exp), L(")")])[@hs=0];
public Box scalar2box(negate(Scalar exp)) = H([L("-("), scalar2box(exp), L(")")])[@hs=0];
public Box scalar2box(not(Scalar exp)) = H([L("!("), scalar2box(exp), L(")")])[@hs=0];
public Box scalar2box(power(Scalar base, Scalar exp)) = H([L("("), scalar2box(base), L("-"), scalar2box(exp), L(")")])[@hs=0];
public Box scalar2box(times(Scalar lhs, Scalar rhs)) = H([L("("), scalar2box(lhs), L("*"), scalar2box(rhs), L(")")])[@hs=0];
public Box scalar2box(divide(Scalar lhs, Scalar rhs)) = H([L("("), scalar2box(lhs), L("/"), scalar2box(rhs), L(")")])[@hs=0];
public Box scalar2box(add(Scalar lhs, Scalar rhs)) = H([L("("), scalar2box(lhs), L("+"), scalar2box(rhs), L(")")])[@hs=0];
public Box scalar2box(minus(Scalar lhs, Scalar rhs)) = H([L("("), scalar2box(lhs), L("-"), scalar2box(rhs), L(")")])[@hs=0];
public Box scalar2box(range(Scalar from, Scalar to)) = H([L("("), scalar2box(from), L(".."), scalar2box(to), L(")")])[@hs=0];
public Box scalar2box(or(Scalar lhs, Scalar rhs)) = H([scalar2box(lhs), L("|"), scalar2box(rhs)])[@hs=0];
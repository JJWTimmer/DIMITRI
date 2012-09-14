module lang::dimitri::levels::l4::Check
extend lang::dimitri::levels::l3::Check;

import lang::dimitri::levels::l4::AST;

public set[Message] check(f:format(name, extensions, defaults, sequence, structures), Context cntxt)
	= checkDuplicateStructureNames(structures)
	+ checkUndefinedSequenceNames(sequence.symbols, structures)
	+ checkDuplicateFieldNames(structures)
	+ checkRefs(structures, cntxt.fields)
	+ typeCheckExpressions(defaults, structures, cntxt);

public set[Message] typeCheckExpressions(set[FormatSpecifier] defaults, list[Structure] structs, Context cntxt)
	= typeCheckExpressions(defaults, cntxt) + typeCheckExpressions(structs, cntxt);
public set[Message] typeCheckExpressions(set[FormatSpecifier] defaults, Context cntxt)
	= { *typeCheckExpressions(exp, id("DEFAULTS"), cntxt) | variableSpecifier(_, Scalar exp) <- defaults};
public set[Message] typeCheckExpressions(list[Structure] structs, Context cntxt)
	= { *typeCheckExpressions(e, st.name, cntxt) | Structure st <- structs, Field f <- st.fields, f has expressions, Scalar e <- f.expressions}
	+ { *typeCheckExpressions(e, st.name, cntxt) | Structure st <- structs, Field f <- st.fields, variableSpecifier(_, Scalar e) <- f.format};
public set[Message] typeCheckExpressions(Scalar exp, Id sname, Context cntxt)
	= {error("String not allowed in this expression. Maybe a referenced field contains a string?", exp@location)}
	when !allowString(exp, sname, cntxt),
	containsString(exp, sname, cntxt);
public default set[Message] typeCheckExpressions(Scalar exp, Id sname, Context cntxt) = {};

public bool allowString(parentheses(Scalar exp), Id sname, Context cntxt) = allowString(exp, sname, cntxt);
public bool allowString(negate(Scalar _), Id _, Context _) = false;
public bool allowString(not(Scalar exp), Id sname, Context cntxt) = allowString(exp, sname, cntxt);
public bool allowString(power(Scalar _, Scalar _), Id _, Context _) = false;
public bool allowString(times(Scalar _, Scalar _), Id _, Context _) = false;
public bool allowString(divide(Scalar _, Scalar _), Id _, Context _) = false;
public bool allowString(add(Scalar _, Scalar _), Id _, Context _) = false;
public bool allowString(minus(Scalar _, Scalar _), Id _, Context _) = false;
public bool allowString(Scalar::range(Scalar _, Scalar _), Id _, Context _) = false;
public bool allowString(or(Scalar lhs, Scalar rhs), Id sname, Context cntxt) = allowString(lhs, sname, cntxt) && allowString(rhs, sname, cntxt);
public default bool allowString(Scalar e, Id _, Context cntxt) { throw "Unknown Scalar <e>"; }

public bool allowString(number(_), Id _, Context _) = true;
public bool allowString(string(_), Id _, Context _) = true;
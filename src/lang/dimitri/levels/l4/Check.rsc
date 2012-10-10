module lang::dimitri::levels::l4::Check
extend lang::dimitri::levels::l3::Check;

import util::ValueUI;

import lang::dimitri::levels::l4::AST;

data Context = ctx(rel[Id, Id] fields, rel[Id, Id, Field] completeFields);

public rel[Id, Id, Field] getCompleteFields(format(_, _, _, _, structures)) = {*getCompleteFields(s) | s <- structures};
public rel[Id, Id, Field] getCompleteFields(Structure::struct(sname, fields)) = {<sname, fname, fld> | fld:field(fname, _, _) <- fields};

public set[Message] checkErrorsL4(Format f) = checkErrorsL4(f, ctx(getFields(f), getCompleteFields(f)));

public set[Message] checkErrorsL4(f:format(name, extensions, defaults, sq, structures), Context cntxt)
	= checkDuplicateStructureNames(structures)
	+ checkUndefinedSequenceNames(sq.symbols, structures)
	+ checkDuplicateFieldNames(structures)
	+ checkRefs(f, cntxt.fields)
	+ typeCheckScalars(defaults, structures, cntxt);

public set[Message] typeCheckScalars(set[FormatSpecifier] defaults, list[Structure] structs, Context cntxt)
	= typeCheckScalars(defaults, cntxt) + typeCheckScalars(structs, cntxt);
	
public set[Message] typeCheckScalars(set[FormatSpecifier] defaults, Context cntxt)
	= { *typeCheckScalars(exp, id("DEFAULTS"), cntxt) | variableSpecifier(_, Scalar exp) <- defaults};
	
public set[Message] typeCheckScalars(list[Structure] structs, Context cntxt)
	= { *typeCheckScalars(e, st.name, cntxt) | st <- structs, f <- st.fields, f has values, e <- f.values}
	+ { *typeCheckScalars(e, st.name, cntxt) | st <- structs, f <- st.fields, f has format, variableSpecifier(_, e) <- f.format};

public set[Message] typeCheckScalars(Scalar exp, Id sname, Context cntxt)
	= {error("String not allowed in this expression. Maybe a referenced field contains a string?", exp@location)}
	when !allowString(exp, sname, cntxt),
	containsString(exp, sname, cntxt);
public default set[Message] typeCheckScalars(Scalar exp, Id sname, Context cntxt) = {};

public bool allowString(number(_), Id _, Context _) = true;
public bool allowString(string(_), Id _, Context _) = true;
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

public bool allowString(ref(fname), Id sname, Context cntxt)
	= allowString(exp, sname, cntxt)
	when fname in cntxt.completeFields[sname]<0>,
	{fld} := cntxt.completeFields[sname, fname],
	fld has values,
	[] !:= fld.values,
	exp := fld.values[0];
public bool allowString(ref(fname), Id sname, Context cntxt)
	= true
	when fname in cntxt.completeFields[sname]<0>,
	{fld} := cntxt.completeFields[sname, fname],
	fld has values,
	[] := fld.values;
public bool allowString(crossRef(sname, fname), Id _, Context cntxt)
	= allowString(exp, sname, cntxt)
	when fname in cntxt.completeFields[sname]<0>,
	{fld} := cntxt.completeFields[sname, fname],
	fld has values,
	[] !:= fld.values,
	exp := fld.values[0];
public bool allowString(crossRef(sname, fname), Id _, Context cntxt)
	= true
	when fname in cntxt.completeFields[sname]<0>,
	{fld} := cntxt.completeFields[sname, fname],
	fld has values,
	[] := fld.values;
public default bool allowString(Scalar s, Id _, Context _) = true;
//public default bool allowString(Scalar s, Id _, Context _) { throw "Unknown Scalar <s>"; }

public bool containsString(string(_), Id _, Context _) = true;
public bool containsString(number(_), Id _, Context _) = false;
public bool containsString(parentheses(Scalar exp), Id sname, Context cntxt) = containsString(exp, sname, cntxt);
public bool containsString(negate(Scalar exp), Id sname, Context cntxt) = containsString(exp, sname, cntxt);
public bool containsString(not(Scalar exp), Id sname, Context cntxt) = containsString(exp, sname, cntxt);
public bool containsString(power(Scalar lhs, Scalar rhs), Id sname, Context cntxt)
	= containsString(lhs, sname, cntxt) || containsString(rhs, sname, cntxt);
public bool containsString(times(Scalar lhs, Scalar rhs), Id sname, Context cntxt)
	= containsString(lhs, sname, cntxt) || containsString(rhs, sname, cntxt);
public bool containsString(divide(Scalar lhs, Scalar rhs), Id sname, Context cntxt)
	= containsString(lhs, sname, cntxt) || containsString(rhs, sname, cntxt);
public bool containsString(add(Scalar lhs, Scalar rhs), Id sname, Context cntxt)
	= containsString(lhs, sname, cntxt) || containsString(rhs, sname, cntxt);
public bool containsString(minus(Scalar lhs, Scalar rhs), Id sname, Context cntxt)
	= containsString(lhs, sname, cntxt) || containsString(rhs, sname, cntxt);
public bool containsString(Scalar::range(Scalar lhs, Scalar rhs), Id sname, Context cntxt)
	= containsString(lhs, sname, cntxt) || containsString(rhs, sname, cntxt);
public bool containsString(or(Scalar lhs, Scalar rhs), Id sname, Context cntxt)
	= containsString(lhs, sname, cntxt) || containsString(rhs, sname, cntxt);

public bool containsString(ref(fname), Id sname, Context cntxt)
	= containsString(exp, sname, cntxt)
	when fname in cntxt.completeFields[sname]<0>,
	{fld} := cntxt.completeFields[sname, fname],
	fld has values,
	[] !:= fld.values,
	exp := fld.values[0];
public bool containsString(ref(fname), Id sname, Context cntxt)
	= false
	when fname in cntxt.completeFields[sname]<0>,
	{fld} := cntxt.completeFields[sname, fname],
	fld has values,
	[] := fld.values;
public bool containsString(crossRef(sourceStruct, sourceField), Id sname, Context cntxt)
	= containsString(exp, sname, cntxt)
	when sourceField in cntxt.completeFields[sourceStruct]<0>,
	{fld} := cntxt.completeFields[sourceStruct, sourceField],
	fld has values,
	[] !:= fld.values,
	exp := fld.values[0];
public bool containsString(crossRef(sourceStruct, sourceField), Id sname, Context cntxt)
	= false
	when sourceField in cntxt.completeFields[sourceStruct]<0>,
	{fld} := cntxt.completeFields[sourceStruct, sourceField],
	fld has values,
	[] := fld.values;

public default bool containsString(Scalar e, Id i, Context c) {
	throw "Unknown Scalar <e>";
}
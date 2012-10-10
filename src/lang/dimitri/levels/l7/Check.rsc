module lang::dimitri::levels::l7::Check
extend lang::dimitri::levels::l6::Check;

import util::ValueUI;

import lang::dimitri::levels::l7::AST;

public set[Message] checkErrorsL7(Format f) = checkErrorsL6(f, ctx(getFieldsL7(f), getCompleteFieldsL7(f)));

public rel[Id, Id] getFieldsL7(format(_, _, _, _, structures))
	= parents + {*getFieldsL7(parents, s) | s:Structure::struct(_, _, _) <- structures}
	when parents := {*getFieldsL7(s) | s:Structure::struct(_, _) <- structures};
public rel[Id, Id] getFieldsL7(Structure::struct(sname, fields))
	= {<sname, fname> | field(fname, _, _) <- fields};
public rel[Id, Id] getFieldsL7(rel[Id, Id] pfields, Structure::struct(sname, pname, fields))
	= {<sname, fname> | field(fname, _, _) <- fields} //all normal fields
	+ {<sname, fld.name> | fieldOverride(_, flds) <- fields, fld <- flds} //all overriding fields
	+ {<sname, fld> | fld <- pfields[pname], !any(f <- fields, fieldOverride(fld, _) := f )} //all fields from parent without overridden field
	;

public rel[Id, Id, Field] getCompleteFieldsL7(format(_, _, _, _, structures))
	= parents + {*getCompleteFieldsL7(parents, s) | s:Structure::struct(_, _, _) <- structures}
	when parents := {*getCompleteFieldsL7(s) | s:Structure::struct(_, _) <- structures};
public rel[Id, Id, Field] getCompleteFieldsL7(Structure::struct(sname, fields))
	= {<sname, fname, f> | f:field(fname, _, _) <- fields};
public rel[Id, Id, Field] getCompleteFieldsL7(rel[Id, Id, Field] pfields, Structure::struct(sname, pname, fields))
	= {<sname, fname, f> | f:field(fname, _, _) <- fields}
	+ {<sname, fld.name, f> | fieldOverride(_, flds) <- fields, f:fld <- flds}
	+ {<sname, ps[0], ps[1]> | ps <- pfields[pname], !any(f <- fields, fieldOverride(fld, _) := ps[0] )};

public set[Message] checkRefs(field(_, list[Field] overrides), rel[Id, Id] fields, Id sname)
	= {*checkRefs(fld, fields, sname) | fld <- overrides};
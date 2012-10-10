module lang::dimitri::levels::l3::Check
extend lang::dimitri::levels::l2::Check;

import lang::dimitri::levels::l3::AST;

public set[Message] checkRefs(fld:field(_, Callback cb, set[FormatSpecifier] format), rel[Id, Id] fields, Id sname) =
	{*checkArgs(val, fields, sname) | p <- cb.parameters, val <- p.values}
	+ {*checkRefs(val, fields, sname) | variableSpecifier(_, val) <- fld.format};
	
public set[Message] checkArgs(Argument arg, rel[Id, Id] fields, Id sname) {
	switch(arg) {
		case numberArg(n) : return checkRefs(number(n), fields, sname);
		case stringArg(s) : return checkRefs(string(s), fields, sname);
		case refArg(f) : return checkRefs(ref(f), fields, sname);
		case crossRefArg(s, f) : return checkRefs(crossRef(s,f), fields, sname);
	}
	return {};
}
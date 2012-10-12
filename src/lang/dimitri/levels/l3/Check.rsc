module lang::dimitri::levels::l3::Check
extend lang::dimitri::levels::l2::Check;

import lang::dimitri::levels::l3::AST;

public set[Message] checkRefsL2(fld:field(_, Callback cb, format), rel[Id, Id] fields, Id sname)
	= {*checkArgs(arg, fields, sname) | p <- cb.parameters, arg <- p.values}
	+ {*checkRefsL2(val, fields, sname) | variableSpecifier(_, val) <- fld.format};
	
public set[Message] checkArgs(c:numberArg(n), rel[Id, Id] fields, Id sname)
	= checkRefsL2(number(n)[@location=c@location], fields, sname);
public set[Message] checkArgs(c:stringArg(s), rel[Id, Id] fields, Id sname)
	= checkRefsL2(string(s)[@location=c@location], fields, sname);
public set[Message] checkArgs(c:refArg(f), rel[Id, Id] fields, Id sname)
	= checkRefsL2(ref(f)[@location=c@location], fields, sname);
public set[Message] checkArgs(c:crossRefArg(s, f), rel[Id, Id] fields, Id sname)
	= checkRefsL2(crossRef(s,f)[@location=c@location], fields, sname);
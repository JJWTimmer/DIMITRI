module lang::dimitri::levels::l2::prettyPrinting::Format2box

extend lang::dimitri::levels::l1::prettyPrinting::Format2box;

import lang::dimitri::levels::l2::AST;

public Box scalar2box( crossRef(id(sname), id(fname)) ) = VAR(L("<sname>.<fname>"));
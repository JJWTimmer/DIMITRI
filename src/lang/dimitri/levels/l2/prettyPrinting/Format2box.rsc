module lang::dimitri::levels::l2::prettyPrinting::Format2box
extend lang::dimitri::levels::l1::prettyPrinting::Format2box;

import lang::dimitri::levels::l2::AST;

public Box scalar2box( crossRef(sname, fname) ) = H([id2box(sname), L("."), id2box(fname)])[@hs=0];
module lang::dimitri::levels::l5::prettyPrinting::Format2box
extend lang::dimitri::levels::l4::prettyPrinting::Format2box;

import lang::dimitri::levels::l5::AST;

public Box scalar2box(lengthOf(ref(field)))= H([L("lengthOf("), id2box(field), L(")")])[@hs=0];
public Box scalar2box(offset(ref(field)))= H([L("offset("), id2box(field), L(")")])[@hs=0];
public Box scalar2box(lengthOf(crossRef(Id struct, Id field)))= H([L("lengthOf("), id2box(struct), L("."), id2box(field), L(")")])[@hs=0];
public Box scalar2box(offset(crossRef(Id struct, Id field)))= H([L("offset("), id2box(struct), L("."), id2box(field), L(")")])[@hs=0];

module lang::dimitri::levels::l4::prettyPrinting::Format2box
extend lang::dimitri::levels::l3::prettyPrinting::Format2box;

import lang::dimitri::levels::l4::AST;

public Box scalar2box(number(val)) = NM(L("<val>"));
public Box scalar2box(hex(val)) = NM(L(val));
public Box scalar2box(oct(val)) = NM(L(val));
public Box scalar2box(bin(val)) = NM(L(val));
public Box scalar2box(string(val)) = STRING(L("\"<val>\""));
public Box scalar2box(ref(val)) = VAR(L(val.val));
module lang::dimitri::levels::l1::prettyPrinting::PrettyPrinting

import ParseTree;
import IO;
import lang::box::util::Box2Text;

import lang::dimitri::levels::l1::Parse;
import lang::dimitri::levels::l1::prettyPrinting::Format2box;
import lang::dimitri::levels::l1::prettyPrinting::ImplodeNoDesugar;

public str prettyPrint(loc source) = format(format2box(implodeNoDesugar(parse(source).top)));

public void prettyPrintFile(loc source) = writeFile(source, prettyPrint(source));
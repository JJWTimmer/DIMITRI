module lang::dimitri::levels::l3::prettyPrinting::PrettyPrinting

import ParseTree;
import IO;
import lang::box::util::Box2Text;

import lang::dimitri::levels::l3::AST;
import lang::dimitri::levels::l3::Parse;
import lang::dimitri::levels::l3::prettyPrinting::Format2box;
import lang::dimitri::levels::l3::prettyPrinting::ImplodeNoDesugar;

public str prettyPrint(Format f) = format(format2box(f));

public str prettyPrint(loc source) = format(format2box(implodeNoDesugar(parse(source).top)));

public void prettyPrintFile(loc source) = writeFile(source, prettyPrint(source));
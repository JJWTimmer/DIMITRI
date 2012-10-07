module lang::dimitri::levels::l6::prettyPrinting::PrettyPrinting

import ParseTree;
import IO;
import lang::box::util::Box2Text;

import lang::dimitri::levels::l6::AST;
import lang::dimitri::levels::l6::Parse;
import lang::dimitri::levels::l6::prettyPrinting::Format2box;
import lang::dimitri::levels::l6::prettyPrinting::ImplodeNoDesugar;

public str prettyPrint(Format f) = format(format2box(f));

public str prettyPrint(loc source) = prettyPrint(implodeNoDesugar(parse(source).top));
public void prettyPrintFile(loc source) = writeFile(source, prettyPrint(source));
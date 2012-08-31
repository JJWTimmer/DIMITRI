module lang::dimitri::levels::l2::compiler::Debug

extend lang::dimitri::levels::l1::compiler::Debug;

import IO;
import lang::dimitri::levels::l2::AST;

public str writeScalar([crossRef(id(sname), id(fname))]) = "<sname>.<escape(fname, mapping)>";
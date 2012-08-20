module lang::dimitri::levels::l2::AST

extend lang::dimitri::levels::l1::AST;

data Scalar = crossRef(Id struct, Id field);
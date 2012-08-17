module lang::dimitri::levels::l2::Syntax

extend lang::dimitri::levels::l1::Syntax;

syntax Expression = @category="Identifier" ref: Id struct "." Id field;
module lang::dimitri::levels::l2::Syntax
extend lang::dimitri::levels::l1::Syntax;

syntax Scalar = crossRef: ExpressionId struct "." ExpressionId field;
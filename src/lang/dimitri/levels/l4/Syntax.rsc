module lang::dimitri::levels::l4::Syntax
extend lang::dimitri::levels::l3::Syntax;

syntax Scalar = bracket parentheses: "(" Scalar ")"
		       | negate: "-" Scalar
		       | not: "!" Scalar 
		       > left power: Scalar "^" Scalar
		       > left ( times: Scalar "*" Scalar
		             | divide: Scalar "/" Scalar)
		       > left ( add: Scalar "+" Scalar
		             | minus: Scalar "-" Scalar)
		       > non-assoc range: Scalar ".." Scalar
		       > left or: Scalar "|" Scalar
		       ;
module lang::dimitri::levels::l4::Syntax
extend lang::dimitri::levels::l3::Syntax;

syntax Scalar = bracket parentheses: "(" Expression ")"
		       | negate: "-" Expression
		       | not: "!" Expression 
		       > left power: Expression "^" Expression
		       > left ( times: Expression "*" Expression
		             | divide: Expression "/" Expression)
		       > left ( add: Expression "+" Expression
		             | minus: Expression "-" Expression)
		       > non-assoc range: Expression ".." Expression
		       > left or: Expression "|" Expression
		       ;
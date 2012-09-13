module lang::dimitri::levels::l4::AST
extend lang::dimitri::levels::l3::AST;

data Scalar = 	  parentheses(Scalar exp)
				| negate(Scalar exp)
				| not(Scalar exp)
				| power(Scalar base, Scalar exp)
				| times(Scalar lhs, Scalar rhs)
				| divide(Scalar lhs, Scalar rhs)
				| add(Scalar lhs, Scalar rhs)
				| minus(Scalar lhs, Scalar rhs)
				| range(Scalar from, Scalar to)
				| or(Scalar lhs, Scalar rhs)
				;
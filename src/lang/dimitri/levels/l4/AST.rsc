module lang::dimitri::levels::l4::AST
extend lang::dimitri::levels::l3::AST;

data Expression = const(Scalar val)
				| parentheses(Expression exp)
				| negate(Expression exp)
				| not(Expression exp)
				| power(Expression base, Expression exp)
				| times(Expression lhs, Expression rhs)
				| divide(Expression lhs, Expression rhs)
				| add(Expression lhs, Expression rhs)
				| minus(Expression lhs, Expression rhs)
				| range(Expression from, Expression to)
				| or(Expression lhs, Expression rhs)
				;
				
anno loc Expression@location;
module lang::dimitri::levels::l4::compiler::validator::ADT
extend lang::dimitri::levels::l3::compiler::validator::ADT;

data VValue = sub(VValue lhs, VValue rhs)
			| add(VValue lhs, VValue rhs)
			| fac(VValue lhs, VValue rhs)
			| div(VValue lhs, VValue rhs)
			| pow(VValue base, VValue exp)
			| neg(VValue exp)
			| not(VValue exp)
			| range(VValue lower, VValue upper)
			;
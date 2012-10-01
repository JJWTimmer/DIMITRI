module lang::dimitri::levels::l4::compiler::validator::Transform
extend lang::dimitri::levels::l3::compiler::validator::Transform;

import lang::dimitri::levels::l4::compiler::validator::ADT;
import lang::dimitri::levels::l4::AST;

public VValue generateScalar(str struct, Scalar::power(Scalar base, Scalar exp))
	= pow(generateScalar(struct, base), generateScalar(struct, exp));
public VValue generateScalar(str struct, minus(Scalar lhs, Scalar rhs))
	= sub(generateScalar(struct, lhs), generateScalar(struct, rhs));
public VValue generateScalar(str struct, times(Scalar lhs, Scalar rhs))
	= fac(generateScalar(struct, lhs), generateScalar(struct, rhs));
public VValue generateScalar(str struct, Scalar::add(Scalar lhs, Scalar rhs))
	= add(generateScalar(struct, lhs), generateScalar(struct, rhs));
public VValue generateScalar(str struct, divide(Scalar lhs, Scalar rhs))
	= div(generateScalar(struct, lhs), generateScalar(struct, rhs));
public VValue generateScalar(str struct, negate(Scalar exp))
	= neg(generateScalar(struct, exp));
public VValue generateScalar(str struct, Scalar::not(Scalar exp))
	= not(generateScalar(struct, exp));
public VValue generateScalar(str struct, Scalar::range(Scalar lower, Scalar upper))
	= range(generateScalar(struct, lower), generateScalar(struct, upper));
	
public default list[VValue] generateScalar(str struct, Scalar e) {
	if (or(Scalar l, Scalar r) := e) {
		list[VValue] orList = [];
		orList += generateScalar(struct, l);
		orList += generateScalar(struct, r);
		return orList;
	} else {
		list[VValue] orList = [];
		orList += [generateScalar(struct, e)];
		return orList;
	}
}
module lang::dimitri::levels::l4::compiler::PropagateConstants
extend lang::dimitri::levels::l2::compiler::PropagateConstants;

import lang::dimitri::levels::l4::AST;

public Format propagateConstantsL4(Format format) {
	return solve(format) {
		specMap = {<s, f.name, f> | struct(s,fs) <- format.structures, Field f <- fs};
		format = top-down visit (format) {
			case struct(sname, fields) => propagateConstants(sname, fields, specMap)
			case Scalar s => fold(s)
		}
	}
}

public bool allowedInSize(parentheses(_)) = true;
public bool allowedInSize(negate(_)) = true;
public bool allowedInSize(not(_)) = false;
public bool allowedInSize(Scalar::power(_,_)) = true;
public bool allowedInSize(times(_,_)) = true;
public bool allowedInSize(divide(_,_)) = true;
public bool allowedInSize(add(_,_)) = true;
public bool allowedInSize(minus(_,_)) = true;
public bool allowedInSize(range(_,_)) = false;
public bool allowedInSize(or(_,_)) = false;
	
public list[Scalar] getVals(Id sname, parentheses(Scalar exp), rel[Id, Id, Field] specMap)
	= [parentheses(getVals(sname, exp, specMap)[0])];
public list[Scalar] getVals(Id sname, negate(Scalar exp), rel[Id, Id, Field] specMap)
	= [negate(getVals(sname, exp, specMap)[0])];
public list[Scalar] getVals(Id sname, not(Scalar exp), rel[Id, Id, Field] specMap)
	= [not(getVals(sname, exp, specMap)[0])];
public list[Scalar] getVals(Id sname, Scalar::power(Scalar lhs, Scalar rhs), rel[Id, Id, Field] specMap)
	= [Scalar::power(getVals(sname, lhs, specMap)[0], getVals(sname, rhs, specMap)[0])];
public list[Scalar] getVals(Id sname, times(Scalar lhs, Scalar rhs), rel[Id, Id, Field] specMap)
	= [times(getVals(sname, lhs, specMap)[0], getVals(sname, rhs, specMap)[0])];
public list[Scalar] getVals(Id sname, divide(Scalar lhs, Scalar rhs), rel[Id, Id, Field] specMap)
	= [divide(getVals(sname, lhs, specMap)[0], getVals(sname, rhs, specMap)[0])];
public list[Scalar] getVals(Id sname, add(Scalar lhs, Scalar rhs), rel[Id, Id, Field] specMap)
	= [add(getVals(sname, lhs, specMap)[0], getVals(sname, rhs, specMap)[0])];
public list[Scalar] getVals(Id sname, minus(Scalar lhs, Scalar rhs), rel[Id, Id, Field] specMap)
	= [minus(getVals(sname, lhs, specMap)[0], getVals(sname, rhs, specMap)[0])];
public list[Scalar] getVals(Id sname, Scalar::range(Scalar lhs, Scalar rhs), rel[Id, Id, Field] specMap)
	= [Scalar::range(getVals(sname, lhs, specMap)[0], getVals(sname, rhs, specMap)[0])];
public list[Scalar] getVals(Id sname, or(Scalar lhs, Scalar rhs), rel[Id, Id, Field] specMap)
	= [or(getVals(sname, lhs, specMap)[0], getVals(sname, rhs, specMap)[0])];

public Scalar  fold( Scalar::power(number(int b), number(int e))) = number(power(b, e));
public Scalar  fold( Scalar::power(Scalar::power(Scalar exp, number(int a)), number(int b))) = power(exp, number(a*b));
public Scalar  fold( minus(number(int l), number(int r))) = number(l-r);
public Scalar  fold( minus(minus(Scalar exp, number(int a)), number(int b))) = minus(exp, number(a+b));
public Scalar  fold( minus(minus(number(int a), Scalar exp), number(int b))) = minus(number(a-b), exp);
public Scalar  fold( minus(number(int a), minus(Scalar exp, number(int b)))) = minus(number(a+b), exp);
public Scalar  fold( minus(number(int a), minus(number(int b), Scalar exp))) = add(number(a-b), exp);
public Scalar  fold( times(number(int l), number(int r))) = number(l*r);
public Scalar  fold( times(times(Scalar exp, number(int a)), number(int b))) = times(exp, number(a*b));
public Scalar  fold( times(times(number(int a), Scalar exp), number(int b))) = times(exp, number(a*b));
public Scalar  fold( times(number(int a), times(Scalar exp, number(int b)))) = times(exp, number(a*b));
public Scalar  fold( times(number(int a), times(number(int b), Scalar exp))) = times(exp, number(a*b));
public Scalar  fold( add(number(int l), number(int r))) = number(l+r);
public Scalar  fold( add(add(Scalar exp, number(int a)), number(int b))) = add(exp, number(a+b));
public Scalar  fold( add(add(number(int a), Scalar exp), number(int b))) = add(exp, number(a+b));
public Scalar  fold( add(number(int a), add(Scalar exp, number(int b)))) = add(exp, number(a+b));
public Scalar  fold( add(number(int a), add(number(int b), Scalar exp))) = add(exp, number(a+b));
public Scalar  fold( divide(number(int l), number(int r))) = number(l/r);
public Scalar  fold( divide(divide(Scalar exp, number(int a)), number(int b))) = divide(exp, number(a*b));
public Scalar  fold( divide(divide(number(int a), Scalar exp), number(int b))) = divide(number(a/b), exp);
public Scalar  fold( divide(number(int a), divide(Scalar exp, number(int b)))) = divide(number(a*b), exp);
public Scalar  fold( divide(number(int a), divide(number(int b), Scalar exp))) = times(number(a/b), exp);
public Scalar  fold( negate(number(int v))) = number(-v);
public Scalar  fold( n:number(_)) = n;
public Scalar  fold( r:ref(_)) = r;
public Scalar  fold( r:crossRef(_, _)) = r;
public default Scalar fold(Scalar s) = s;

public int power(int base, int exponent) {
	if (exponent == 0) return 0;
	if (exponent == 1) return base;
	int result = base;
	while (exponent > 1) {
		result *= base;
		exponent -= 1;
	}
	return result;
}
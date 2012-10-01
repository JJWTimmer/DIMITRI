module lang::dimitri::levels::l2::compiler::validator::Transform

extend lang::dimitri::levels::l1::compiler::validator::Transform;

import IO;
import util::Maybe;
import List;
import Set;
import String;

import lang::dimitri::levels::l2::AST;
import lang::dimitri::levels::l2::compiler::Annotate;
import lang::dimitri::levels::l2::compiler::validator::ADT;

public Validator getValidatorL2(Format format) = validator(toUpperCase(format.name.val) + "Validator", format.name.val, getGlobals(format), getStructures(format));

public VValue generateScalar(str struct, crossRef(id(sname), id(fname))) = var("<sname>_<fname>");

public list[Global] getGlobals(Format format) {
	list[Global] globals = [];
	
	top-down visit(format) {
		case struct(id(sn), fields) : globals = getGlobals(sn, fields, globals);
	}

	return globals;
}

public list[Global] getGlobals(str sname, list[Field] fields, list[Global] globals) =  globals + [*getGlobals(fld, sname) | fld <- fields];

public default list[Global] getGlobals(Field fld, str sname) {
	list[Global] res = [];
	fname = fld.name.val;
	
	if ((fld@ref)?, global() := fld@ref) {
		if (isVariableSize(fld)) {
			bufName = "<sname>_<fname>";
			res += gdeclB(bufName);
		} else {
			valName = "<sname>_<fname>";
			Type t = makeType(fld);
			res += gdeclV(t, valName);
		}
	}
	return res;
}
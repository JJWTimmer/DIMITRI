module lang::dimitri::levels::l2::compiler::validator::Transform

extend lang::dimitri::levels::l1::compiler::validator::Transform;

import IO;
import util::Maybe;
import List;
import Set;
import String;
//import util::ValueUI;
import lang::dimitri::levels::l2::AST;
import lang::dimitri::levels::l2::compiler::Annotate;
import lang::dimitri::levels::l2::compiler::validator::ADT;

public Validator getValidatorL2(Format format) = validator(toUpperCase(format.name.val) + "Validator", format.name.val, getGlobals(format), getStructures(format));

public VValue generateScalar(str struct, crossRef(id(sname), id(fname))) = var("<sname>_<fname>");

public list[Global] getGlobals(Format format) {
	list[Global] globals = [];
	sname = "";
	
	top-down visit(format) {
		case struct(id(sn), _) : sname = sn;
		case fld:field(id(fname), _,_) : {
			if ((fld@ref)?, global() := fld@ref) {
				if (isVariableSize(fld)) {
					str bufName = "<sname>_<fname>";
					globals += gdeclB(bufName);
				} else {
					str valName = "<sname>_<fname>";
					Type t = makeType(fld);
					globals += gdeclV(t, valName);
				}
			}
		}
	}

	return globals;
}
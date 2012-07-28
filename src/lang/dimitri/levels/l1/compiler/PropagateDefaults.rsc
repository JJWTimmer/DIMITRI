module lang::dimitri::levels::l1::compiler::PropagateDefaults

import lang::dimitri::levels::l1::AST;

public Format propagateDefaults(Format format, list[FormatSpecifier] base) {
	format.defaults = resolveOverrides(base, format.defaults, false);
	return visit (format) {
		case f:field(_, FieldSpecifier _) => resolveFieldOverrides(format, f)
	}
}

private Field resolveFieldOverrides(Format format, Field field) {
	field.\value.format = resolveOverrides(format.defaults, field.\value.format, true);
	return field;
}

private list[FormatSpecifier] resolveOverrides(list[FormatSpecifier] base, list[FormatSpecifier] override, bool tagLocal) {
	for (q <- override) {
		int id = 6;
		switch(q) {
			case F:formatSpecifier(unit(), _): {
				id = 0;
				base[id] = F;
			}
			case F:formatSpecifier(sign(), spec): {
				id = 1;
				base[id] = F;
			}
			case F:formatSpecifier(endian(), _): {
				id = 2;
				base[id] = F;
			}	
			case F:formatSpecifier(strings(), _): {
				id = 3;
				base[id] = F;
			}	
			case F:formatSpecifier(\type(), _): {
				id = 4;
				base[id] = F;
			}	
			case V:variableSpecifier(size(), _): {
				id = 5;
				base[id] = V;
			}	
		}
		if (id < 6 && tagLocal) {
			base[id]@local = true;
		}
	}
	return base;
}

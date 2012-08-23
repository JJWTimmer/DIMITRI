module lang::dimitri::levels::l1::compiler::PropagateDefaults

import lang::dimitri::levels::l1::util::FormatHelper;
import lang::dimitri::levels::l1::AST;

public Format propagateDefaults(Format format, set[FormatSpecifier] base) {
	format.defaults = resolveFormat(base, format.defaults, false);

	return visit (format) {
		case Field f => resolveFieldOverrides(format, f)
	}
}

private Field resolveFieldOverrides(Format format, Field field) {
	field.format = resolveFormat(format.defaults, field.format, true);
	return field;
}

private set[FormatSpecifier] resolveFormat(set[FormatSpecifier] base, set[FormatSpecifier] locals, bool tagLocal) {
	map[str, str] localFormat = generateFormatMap(locals);
	map[str, Scalar] localVars = generateVariableMap(locals);
	
	return visit (base) {
		case fs:formatSpecifier(_, _) => resolve(fs, localFormat, tagLocal)
		case vs:variableSpecifier(_, _) => resolve(vs, localVars, tagLocal)
	};
}

private FormatSpecifier resolve(fs:formatSpecifier(k, _), map[str, str] locals, bool tagLocal) {
	if (locals[k]?) {
		fs.val = locals[k];
		if (tagLocal) fs@local=true;
	}
	
	return fs;
}

private FormatSpecifier resolve(vs:variableSpecifier(k, _), map[str, Scalar] locals, bool tagLocal) {
	if (locals[k]?) {
		vs.var = locals[k];
		if (tagLocal) vs@local=true;
	}
	
	return vs;
}
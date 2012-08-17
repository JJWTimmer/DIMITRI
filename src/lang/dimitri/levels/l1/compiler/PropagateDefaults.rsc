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

private set[FormatSpecifier] resolveFormat(set[FormatSpecifier] base, set[FormatSpecifier] defaults, bool tagLocal) {
	defaultFormat = generateFormatMap(defaults);
	defaultVars = generateVariableMap(defaults);
	
	//note: every format/variable specifier must have a base value declared
	visit (base) {
		case formatSpecifier(k, _) => formatSpecifier(k, defaultFormat[k])[@local=true] when defaultFormat[k]? && tagLocal
		case formatSpecifier(k, _) => formatSpecifier(k, defaultFormat[k]) when defaultFormat[k]? && !tagLocal
		case variableSpecifier(k, _) => variableSpecifier(k, defaultVars[k])[@local=true] when defaultVars[k]? && tagLocal
		case variableSpecifier(k, _) => variableSpecifier(k, defaultVars[k]) when defaultVars[k]? && !tagLocal
	}
	
	return base;
}

private FormatSpecifier resolve(fs: formatSpecifier(k, _), map[str, str] def, bool tagLocal) {
	if (ifs: formatSpecifier(k, _) := fs, def[k]?) {
		res = formatSpecifier(k, defaultFormat[k]);
		if (tagLocal) res[@local=true];
		return res;
	}
	
	return fs;
}

private FormatSpecifier resolve(vs: variableSpecifier(k, _), map[str, Scalar] def, bool tagLocal) {
	if (ivs: variableSpecifier(k, _) := fs, def[k]?) {
		res = variableSpecifier(k, defaultFormat[k]);
		if (tagLocal) res[@local=true];
		return res;
	}
	
	return vs;
}
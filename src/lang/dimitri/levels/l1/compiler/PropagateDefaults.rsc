module lang::dimitri::levels::l1::compiler::PropagateDefaults

import lang::dimitri::levels::l1::Defaults;
import lang::dimitri::levels::l1::AST;

public Format propagateDefaults(Format format) {
	format.defaults = resolveFormat(getDefaults(), format.defaults, false);

	return visit (format) {
		case Field fld => resolveFieldOverrides(format.defaults, fld)
	}
}

private Field resolveFieldOverrides(set[FormatSpecifier] defaults, fld:field(fname, _, format)) {
	fld.format = resolveFormat(defaults, format, true);
	return fld;
}
private default Field resolveFieldOverrides(set[FormatSpecifier] defaults, Field f) = f;

private set[FormatSpecifier] resolveFormat(set[FormatSpecifier] base, set[FormatSpecifier] locals, bool tagLocal) =
	visit (base) {
		case FormatSpecifier fs => resolve(fs, locals, tagLocal)
	};

private FormatSpecifier resolve(fs:formatSpecifier(k, _), set[FormatSpecifier] locals, bool tagLocal) {
	localMap = (k:v | formatSpecifier(k, v) <- locals );
	if (localMap[k]?) {
		fs.val = localMap[k];
		if (tagLocal)
			fs@local=true;
	}
	return fs;
}

private FormatSpecifier resolve(vs:variableSpecifier(k, _), set[FormatSpecifier] locals, bool tagLocal) {
	localMap = (k:v | variableSpecifier(k, v) <- locals );
	if (localMap[k]?) {
		vs.var = localMap[k];
		if (tagLocal)
			vs@local=true;
	}
	return vs;
}
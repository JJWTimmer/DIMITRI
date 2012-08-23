module lang::dimitri::levels::l1::util::FormatHelper

import IO;
import util::Maybe;
import lang::dimitri::levels::l1::AST;
import lang::dimitri::Level1; //for the defaults

public alias SFS = set[FormatSpecifier];

public map[str, str] generateFormatMap(SFS input) = (k:v | formatSpecifier(k, v) <- input );
public map[str, Scalar] generateVariableMap(SFS input) = (k:v | variableSpecifier(k, v) <- input );

public SFS setSFSValue(SFS format, str name, str val) {
	return visit (format) {
		case formatSpecifier(name, _) : insert formatSpecifier(name, val);
	}
}
public SFS setSFSValue(SFS format, str name, Scalar val) {
	return visit (format) {
		case variableSpecifier(name, _) : insert variableSpecifier(name, val);
	};
}

public Maybe[str] getSFSString(SFS format, str key) {
	if (/formatSpecifier(key, val) := format) return just(val);
	return nothing();
}

public Maybe[Scalar] getSFSScalar(SFS format, str key) {
	if (/variableSpecifier(key, val) := format) return just(val);
	return nothing();
}

public SFS getDefaultSFS(SFS defaults) {
	keys = {fs.key | FormatSpecifier fs <- defaults};
	for (FormatSpecifier def <- DEFAULTS, def.key notin keys) defaults += def;
	return defaults;
}
module lang::dimitri::levels::l1::util::FormatHelper

import lang::dimitri::levels::l1::AST;

alias LFS = list[FormatSpecifier];

public map[str, value] generateFormatMap(LFS input) {
	map[str, value] m = ();
	for (fs <- specs) {
		fsWritten = true;
		if (formatSpecifier(key, val) := fs) {
			switch(key) {
				case unit()		: m["unit"] = val;
				case sign()		: m["sign"] = val;
				case endian()	: m["endian"] = val;
				case strings()	: m["strings"] = val;
				case \type()	: m["type"] = val;
			}
		} else if (variableSpecifier(key, val) := fs) {
			switch(key) {
				case size() : {
					if (number(n) := val) {
						m["size"] = n;
					}
				}
			}
		}
	}
	return m;
}

public int getSize(LFS input) {
	if (/variableSpecifier(size(), number(n)) := input)
		return n;
	else
		return 0;
}

public FormatValue getUnits(LFS input) = getFormatSpec(unit(), byte(), input);
public FormatValue getSign(LFS input) = getFormatSpec(sign(), \true(), input);
public FormatValue getEndian(LFS input) = getFormatSpec(endian(), \big(), input);
public FormatValue getStrings(LFS input) = getFormatSpec(strings(), \ascii(), input);
public FormatValue getType(LFS input) = getFormatSpec(\type(), integer(), input);

public FormatValue getFormatSpec(FormatKeyword keyw, FormatValue deflt, LFS inp) {
	if (/formatSpecifier(keyw, val) := input)
		return val;
	else
		return deflt;
}
module lang::dimitri::levels::l7::compiler::Normalize
extend lang::dimitri::levels::l6::compiler::Normalize;

import Node;
import Set;
import util::ValueUI;

import lang::dimitri::levels::l1::util::IdHelper;
import lang::dimitri::levels::l7::AST;

alias Replacements = rel[Id struct, int order, Id field, Id repl];

public Format normalizeL7(Format format) = format4 when
	format0 := removeInheritance(format),
	format1 := removeMultipleExpressions(format0),
	format2 := removeStrings(format1),
	format2a1 := fixLengthOf(format2),
	format2a2 := removeOffset(format2a1),
	format2b := expandSpecificationL6(format2a2),
	format3 := removeNotSequence(format2b),
	format4 := sequence2dnf(format3);

private Format removeInheritance(Format format) {
	//create env
	rel[Id, Id, list[Field]] env = { };
	for (s <- format.structures) {
		if (struct(sname, pname, fields) := s) {
			env += <sname, pname, fields>;
		}
		else {
			env += <s.name, id(""), s.fields>;
		}
	}
	
	Replacements replacements = {};

	//find all inheritance structs and expand
	format.structures = for (s <- format.structures) {
		if (chld:struct(Id sname, Id _, list[Field] _) := s) {
			<flds, replacements> = removeInheritance(sname, env, replacements);
			append setAnnotations(struct(sname, flds), getAnnotations(chld));
		} else {
			append s;
		}
	}

	format = visit (format) {
		case s:struct(Id name, list[Field] fields): s[fields=normalizeInheritance(name, fields, replacements)];
	}
	
	return format;
}

private tuple[list[Field], Replacements] removeInheritance(Id sname, rel[Id, Id, list[Field]] env, Replacements replacements) {
	list[Field] currentFields = getOneFrom(env[sname,_]);
	rel[Id parent, list[Field] flds] base = env[sname]; 
	list[Field] baseFields = [];
	if ({parent} := base.parent, id("") !:= parent) {
		<baseFields, replacements> = removeInheritance(parent, env, replacements);
	}
	
	overriddenFields = top:for (baseField <- baseFields) {
		bool overridden = false;
		for (currentField <- currentFields) {
			if (baseField.name == currentField.name) {
				overridden = true;
				append top: currentField;
			}
		}
		if (!overridden) {
			append top: baseField;
		}
	}
	return removeInheritance(overriddenFields + (currentFields - overriddenFields), sname, replacements);
}




private tuple[list[Field], Replacements] removeInheritance(list[Field] fields, Id sname, Replacements replacements) {	
	flds = ret:for (f <- fields) {
		if (fieldOverride(Id fname, list[Field] fs) := f) {
			int i = 0;
			for (fi <- fs) {
				replacements += <sname, i, fname, fi.name>;
				i += 1;
			}
			removeInheritance(fs, sname, replacements);
		} else append ret: f;
	}
	return <flds, replacements>;

}

private list[Field] normalizeInheritance(Id sname, list[Field] fields, Replacements replacements) {
	return visit (fields) {
		case offset(ref(fname)) => offset(ref( resolveInheritanceOffset(sname, fname, replacements) ))
		case offset(crossRef(struct, fname)) => offset(crossRef(struct, resolveInheritanceOffset(struct, fname)))
		case lengthOf(ref(fname)) => resolveInheritanceLength(sname, fname, true, replacements)
		case lengthOf(crossRef(struct, fname)) => resolveInheritanceLength(struct, fname, false, replacements)
		case Parameter p => p[values=resolveInheritanceSpecification(sname, p, replacements)]
	}
}

private Id resolveInheritanceOffset(Id struct, Id name, Replacements replacements) {
	set[Id] override = (replacements[struct, 0]+)[name] & bottom(replacements[struct, 0]+);
	if (isEmpty(override)) {
		return name;
	} else {
		return getOneFrom(override);
	}
}

private Scalar resolveInheritanceLength(Id struct, Id name, bool local, Replacements replacements) {
	set[Id] override = (replacements[struct, _]+)[name] & bottom(replacements[struct, _]+);
	if (isEmpty(override)) {
		if (local)
			return lengthOf(ref(name));
		else
			return lengthOf(crossRef(struct, name));
	} else {
		list[Id] names = toList(override);
		tuple[Id head, list[Id] tail] result = pop(toList(override));
		return expandLengthOf(struct.val, result.head.val, unId(result.tail), local);
	}
}

private list[Argument] resolveInheritanceSpecification(Id sname, Parameter p, Replacements replacements) {
	return top:for (Argument arg <- p.values) {
		if (numberArg(_) := arg) {
			append arg;
		} else {
			if (cr:crossRefArg(struct, fname) := arg) {
				list[Id] overrides = [ n | <i, n> <- sort([*(replacements<0,2,1,3>[struct,fname])]), n in bottom(replacements[struct,_]+)];
				if (isEmpty(overrides)) {
					append top:cr;
				} else {
					for (n <- overrides) {
						append top:crossRef(struct, n);
					}
				}
			} else if (r:refArg(fname) := arg) {
				list[Id] overrides = [ n | <i, n> <- sort([*(replacements<0,2,1,3>[sname,fname])]), n in bottom(replacements[sname,_]+)];
				if (isEmpty(overrides)) {
					append top:r;
				} else {
					for (n <- overrides) {
						append top:ref(n);
					}
				}
			}
		}
	}
}
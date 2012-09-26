module lang::dimitri::levels::l5::compiler::Normalize
extend lang::dimitri::levels::l3::compiler::Normalize;

import lang::dimitri::levels::l5::AST;

public Format normalizeL5(Format format) = format4 when
	format1 := removeMultipleExpressions(format),
	format2 := removeStrings(format1),
	format2a1 := fixLengthOf(format2),
	format2a2 := removeOffset(format2a1),
	format2b := expandSpecification(format2a2),
	format3 := removeNotSequence(format2b),
	format4 := sequence2dnf(format3);

public Format fixLengthOf(Format format) {
	rel[str sname, str fname, str mname] env = { };
	for (s <- format.structures, f <- s.fields) {
		switch (f) {
			case field(id(mname), _, _):
				if (/<name:.*?>\*.*/ := mname) {
					env +=  < s.name.val, name, mname >;
				}
		}
	}

	return top-down-break visit (format) {
		case struct(id(sname), list[Field] fields): {
			fs = top-down-break visit (fields) {
				case lengthOf(ref(id(name))) => expandLengthOf(sname, name, toList(env[sname,name]), true)
				case lengthOf(crossRef(id(struct), id(name))) => expandLengthOf(struct, name, toList(env[struct,name]), false)
			}
			insert struct(id(sname), fs); 
		}
	}
}

private Scalar expandLengthOf(str struct, str head, list[str] tail, bool local) {
	if (isEmpty(tail)) {
		if (local) return lengthOf(ref(id(head)));
		else return lengthOf(crossRef(id(struct), id(head)));
	}
	tuple[str h,list[str] t] r = takeOneFrom(tail);
	if (local)
		return add(lengthOf(ref(id(head))),expandLengthOf(struct, r.h, r.t, local));
	else
		return add(lengthOf(crossRef(id(struct), id(head))), expandLengthOf(struct, r.h, r.t, local));
}

public Format removeOffset(Format format) {
	list[Field] fields = [];
	str sname;
	return top-down visit (format) {
		case struct(id(name), list[Field] fs) => removeOffset(name, fs, format)
	}
}

private Structure removeOffset(str strct, list[Field] fields, Format fmt) {
	newFields = visit (fields) {
		case offset(ref(id(name))): {
			list[str] preceders = getPrecedingFieldNames(name, fields);
			if (isEmpty(preceders)) insert number(0);
			else {
				tuple[str head, list[str] tail] result = pop(preceders);
				insert expandLengthOf(strct, result.head, result.tail, true);
			}
		}
		case offset(crossRef(id(sname), id(name))): {
			list[str] preceders = getPrecedingFieldNames(name, getFields(fmt, sname));
			if (isEmpty(preceders)) insert number(0);
			else {
				tuple[str head, list[str] tail] result = pop(preceders);
				insert expandLengthOf(sname, result.head, result.tail, false);
			}
		}
	}
	
	return struct(id(strct), newFields);
}

private list[Field] getFields(Format format, str struct) {
	for (s <- format.structures) {
		if (s.name.val == struct) return s.fields;
	}
}

private list[str] getPrecedingFieldNames(str name, list[Field] fields) {
	return for (field <- fields) {
		if (field.name.val == name)
			break;
		else
			append field.name.val;
	}
}
module lang::dimitri::levels::l1::compiler::Annotate

import IO;
import Set;
import List;

import lang::dimitri::levels::l1::AST;

data Reference = local();
data Dependency = dependency(str name);
anno Reference Field @ ref;
anno Reference Field @ size;
anno Dependency Field @ refdep;
anno Dependency Field @ sizedep;
anno bool SequenceSymbol @ allowEOF;

public Format annotate(Format format) {
	return annotateSymbols(annotateFieldRefs(format));
}

public Format annotateFieldRefs(Format format) {
	rel[str, str, Reference] refenv = makeReferenceEnvironment(format, true);
	rel[str, str, Reference] sizeenv = makeReferenceEnvironment(format, false);
	rel[str, str, Dependency] refdepenv = makeDependencyEnvironment(format, true);
	rel[str, str, Dependency] refsizeenv = makeDependencyEnvironment(format, false);
	str sname = "";
	return top-down visit (format) {
		case struct(id(name), _): sname = name;
		case Field f : {
			str name = f.name.val;
			set[Reference] annotation = refenv[sname, name];
			if ({r} := annotation) {
				f@ref = r;
			}
			annotation = sizeenv[sname, name];
			if({r} := annotation) {;
				f@size = r;
			}
			set[Dependency] dependency = refdepenv[sname, name];
			if ({d} := dependency) {
				f@refdep = d;
			}
			dependency = refsizeenv[sname, name];
			if ({d} := dependency) {
				f@sizedep = d;
			}
			insert f;
		}
	}
}

public Format annotateSymbols(Format format) {
	bool allowEOF = true;
	for (i <- [size(format.sequence.symbols)-1..0]) {
		if (choiceSeq(set[SequenceSymbol] symbols) := format.sequence.symbols[i]) {
			if (fixedOrderSeq([]) notin symbols) {
				allowEOF = false;
			}
		}
		format.sequence.symbols[i]@allowEOF = allowEOF;
	}
	return format;
}

private rel[str, str, Reference] makeReferenceEnvironment(Format format, bool values) {
	rel[str struct, str field, Reference ref] env = {};
	rel[str struct, str field, bool seen] order = {};
	str sname = "";
	str fname = "";
	
	void makeRef(str struct, str name) {
		if (struct != sname) {
			env += <struct, name, global()>;
		} else if (!isEmpty(order[sname, name])) {
			env += <sname, name, local()>;
		}
	}

	top-down visit (format) {
		case struct(id(name), _): sname = name;
		case Field f : {
			fname = f.name.val;
			order += <sname, fname, true>;
		}
		case ref(id(name)): if (values) makeRef(sname, name);
	}
	return env;
}

private rel[str, str, Dependency] makeDependencyEnvironment(Format format, bool values) {
	rel[str struct, str field, str dep] env = {};
	rel[str struct, str field, int count] order = {};
	rel[str struct, str field, Dependency dep] deps = {};
	str sname = "";
	str fname = "";
	int count = 0;
	
	void makeRef(str struct, str name) {
		if (struct == sname && isEmpty(order[sname, name])) {
			env += <sname, fname, name>;
		}
	}

	top-down visit (format) {
		case struct(id(name), _): {
			sname = name;
			count = 0;
		}
		case Field f : {
			fname = f.name.val;
			order += <sname, fname, count>;
			count += 1;
		}
		case ref(id(name)): if (values) makeRef(sname, name);

	}
	for (<str struct, str field> <- env<0, 1>) {
		int max = max(order[struct, env[struct, field]]);
		Dependency dep = dependency([v | t <- order, <struct, str v, max> := t][0]);
		deps += <struct, field, dep>;
	}
	return deps;
}

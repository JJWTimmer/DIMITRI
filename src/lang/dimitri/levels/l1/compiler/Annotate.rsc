module lang::dimitri::levels::l1::compiler::Annotate

import IO;
import Set;

import lang::dimitri::levels::l1::AST;

data Reference = local();
data Dependency = dependency(str name);
anno Reference Field @ ref;

public Format annotate(Format format) {
	rel[str, str, Reference] refenv = makeReferenceEnvironment(format);
	rel[str, str, Dependency] refdepenv = makeDependencyEnvironment(format);
	str sname = "";
	
	return top-down visit (format) {
		case struct(id(name), _): sname = name;
		case Field f: {
			set[Reference] annotation = refenv[sname, f.name.val];
			if (size(annotation) == 1) {
				f@ref = getOneFrom(annotation);
			}
			
			set[Dependency] dependency = refdepenv[sname, f.name.val];
			if (size(dependency) == 1) {
				f@refdep = getOneFrom(dependency);
			}
			
			insert f;
		}
	}
}

private rel[str, str, Reference] makeReferenceEnvironment(Format format) {
	rel[str struct, str field, Reference ref] env = {};
	rel[str struct, str field, bool seen] order = {};
	str sname = "";
	str fname = "";
	
	void makeRef(str struct, str name) {
		if (!isEmpty(order[sname, name])) {
			env += <sname, name, local()>;
		}
	}

	top-down visit (format) {
		case struct(id(name), _): sname = name;
		case Field f: {
			fname = f.name.val;
			order += <sname, fname, true>;
		}
		case ref(id(name)): makeRef(sname, name);
	}
	
	return env;
}

private rel[str, str, Dependency] makeDependencyEnvironment(Format format) {
	rel[str struct, str field, str dep] env = {};
	rel[str struct, str field, int count] order = {};
	rel[str struct, str field, Dependency dep] deps = {};
	str sname = "";
	str fname = "";
	int count = 0;
	
	//if same struct and field is unknown, add it to env
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
		case Field f: {
			fname = f.name.val;
			order += <sname, fname, count>;
			count += 1;
		}
		case ref(id(name)): makeRef(sname, name);
	}
	
	for (<str struct, str field> <- env<0, 1>) {
		int max = max(order[struct, env[struct, field]]);
		Dependency dep = dependency([v | t <- order, <struct, str v, max> := t][0]);
		deps += <struct, field, dep>;
	}
	return deps;
}
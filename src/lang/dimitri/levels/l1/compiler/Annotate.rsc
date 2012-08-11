module lang::dimitri::levels::l1::compiler::Annotate

import IO;
import Set;

import lang::dimitri::levels::l1::AST;

data Reference = local();
data Dependency = dependency(str name);
anno Reference Field @ ref;
anno Reference Field @ size;
anno Dependency Field @ refdep;
anno Dependency Field @ sizedep;

public Format annotate(Format format) {
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
			if (size(annotation) == 1) {
				//println("Adding value reference to <sname>.<name>");
				f@ref = getOneFrom(annotation);
			}
			annotation = sizeenv[sname, name];
			if(size(annotation) == 1) {
				//println("Adding size reference to <sname>.<name>");
				f@size = getOneFrom(annotation);
			}
			set[Dependency] dependency = refdepenv[sname, name];
			if (size(dependency) == 1) {
				//println("Adding local forward value reference to <sname>.<name>");
				f@refdep = getOneFrom(dependency);
			}
			dependency = refsizeenv[sname, name];
			if (size(dependency) == 1) {
				//println("Adding local forward size reference to <sname>.<name>");
				f@sizedep = getOneFrom(dependency);
			}
			insert f;
		}
	}
}

private rel[str, str, Reference] makeReferenceEnvironment(Format format, bool values) {
	rel[str struct, str field, Reference ref] env = {};
	rel[str struct, str field, bool seen] order = {};
	str sname = "";
	str fname = "";
	
	void makeRef(str struct, str name) {
		if (struct != sname) {
			//println("<struct>.<name> is referenced globally.");
			env += <struct, name, global()>;
		} else if (!isEmpty(order[sname, name])) {
			//println("<sname>.<name> is referenced locally.");
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
			//println("<sname>.<name> has a local forward reference.");
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
		//println("<struct>.<field>");
		//println("order: <order>");
		//println("env: <env>");
		int max = max(order[struct, env[struct, field]]);
		Dependency dep = dependency([v | t <- order, <struct, str v, max> := t][0]);
		deps += <struct, field, dep>;
	}
	return deps;
}

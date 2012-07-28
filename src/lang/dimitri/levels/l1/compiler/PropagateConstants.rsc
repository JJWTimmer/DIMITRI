module lang::dimitri::levels::l1::compiler::PropagateConstants

import IO;
import Set;
import List;
import Type;
import util::ValueUI;

import lang::dimitri::levels::l1::AST;

data EType = val(str field, Scalar scalar) | spec(str field, FormatSpecifier format);

data KeyType = fk(FormatKeyword fk) | vk(VariableKeyword vk);
data ValType = fv(FormatValue fv) | scal(Scalar s);
 

alias FieldTuple = tuple[str struct, str field];
alias FieldMap = map[FieldTuple referrer, FieldTuple source]; 

public bool isConst(number(_)) = true;
public bool isConst(Scalar::string(_)) = true; //rascal bug: have to use FQN when more constructors with same name
public default bool isConst(Scalar _) = false;

public Format propagateConstants(Format format) {
	rel[str sname, str fname, EType etype] env = makeEnvironment(format);
	FieldMap fmap = ();
	
	EType propagate(str sname, V:val(fieldName, fieldValue) ) {
		if (ref(str refName) := fieldValue) {
			vals = { si | val(_, si) <- env[sname,refName], isConst(si) };
			
			//more then one value = double names = error
			if (size(vals) == 1) {
				fmap[<sname, fieldName>] = <sname, refName>;
				return val(fieldName, getOneFrom(vals));
			}
		}
		return V;
	}
	
	default EType propagate(_, EType et) = et;

	solve(env) {
		env = { < sname, fname, propagate(sname, etype) > | < sname, fname, etype > <- env };
		
		for (referrer <- fmap) {
		
			referrerSpec = {sp | spec(_, sp) <- env[referrer.struct, referrer.field], sp@local?, sp@local};
			
			map[KeyType,ValType] sourceSpec =  (
				(const has key ? fk(const.key) : vk(const.varKey)) : (const has val ? fv(constval) : scal(const.var))
				| spec(_, const) <- env[fmap[referrer].struct,fmap[referrer].field],
				const@local?,
				const@local
			);
			
text(referrerSpec);
text(sourceSpec);
			
			newSpec = for (spec <- referrerSpec) {
				if ( F:formatSpecifier(k, v) := spec ) {
					if (sourceSpec[fk(k)]?) append formatSpecifier(k, sourceSpec[fk(k)].fv);
					else append F;
				}
				else if ( V:variableSpecifier(k, v) := spec) {
					if (sourceSpec[vk(k)]?) append variableSpecifier(k, sourceSpec[vk(k)].s);
					else append V;
				}
			}
text(newSpec);
			
			env -= { e | e <- env, referrer.struct == e.sname, referrer.field == e.fname};
			env += { < referrer.struct, referrer.field, spec(referrer.field, sp) > | sp <- newSpec };
		}
		
		fmap = ();
	}
	
	str sname = "";
	return top-down visit(format) {
		case struct(id(sn), _): sname = sn;
		case field(I:id(fieldName), fieldVal): {
			sizeExp = { si | spec(_, si) <- env[sname,fieldName] };
			if (size(sizeExp) == 1) fieldVal.format[5] = getOneFrom(sizeExp);
			specExp = [ sc | val(_, sc) <- env[sname,fieldName] ];
			if (size(specExp) == 1) {
				insert(field(I, fieldValue(specExp, fieldVal.format)));
			}
		}
	}
}

private rel[str sname, str fname, EType etype] makeEnvironment(Format format) {
	rel[str sname, str fname, EType etype] env = { };
	for (s <- format.structures, f <- s.fields) {
		switch(f) {
			case field(name, \value):
				if (\value has values ) {
					env += { < s.name.val, name.val, val(name.val, \value.values[0]) >, < s.name.val, name.val, spec(name.val, \value.format[5]) > };
				} 
		}
	}
	
	return env;
}
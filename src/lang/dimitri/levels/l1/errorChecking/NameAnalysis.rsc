module lang::dimitri::levels::l1::errorChecking::NameAnalysis

import IO;
import List;
import Map;
import Message;
import ParseTree;
import lang::dimitri::levels::l1::Implode;
import lang::dimitri::levels::l1::AST;

public Tree nameCheck(Tree t) {
	Format ast = dummy();
	if (Format F := implode(t)) {
		ast = F;
	}
	return t[@messages = checkUndefinedSequenceNames(ast) + checkDuplicateStructureNames(ast) + checkDuplicateFieldNames(ast)];
}

/*
	get all structure names from struct defs and check for duplicates
*/
private set[Message] checkDuplicateStructureNames(Format f) {
	list[Id] structureNames = [ name | struct(name, _) <- f.structures ];
	nameCounts = distribution(structureNames);
	return { error("Structure name not unique: <name.val>", name@location ) | name <- nameCounts , nameCounts[name] > 1};
}

/*
	find all struct names from struct defs
	get all the names used in sequence
	diff
*/
private set[Message] checkUndefinedSequenceNames(Format f) {
	set[Id] structureNames = { name | struct(name, _) <- f.structures };
	set[SequenceSymbol] sequenceNames = { S | /S:struct(_) <- f.sequence.symbols };
	set[Id] undefinedReferencedNames = {name | struct(name) <- sequenceNames} - structureNames;
	set[SequenceSymbol] unknowns = {symbol | symbol <- sequenceNames, symbol has name, symbol.name in undefinedReferencedNames };
	return {error("Sequence references undefined structure: <symbol.name>", symbol@location) | symbol <- unknowns};
}

/*
	get per struct the duplicate fieldnames
*/
private set[Message] checkDuplicateFieldNames(Format f) {
	set[Message] errors = {};
	
	for (struct <- f.structures, !isEmpty(struct.fields)) {
		nameCounts = distribution([field.name | field <- struct.fields, field has name]);
		set[Field] dups = {field | field <- struct.fields, field has name, nameCounts[field.name] > 1};
		errors += {error("Field name not unique: <struct.name.val>.<field.name.val>", field@location) | field <- dups};
	};
	
	return errors;
}
module lang::dimitri::levels::l2::compiler::validator::Generate
extend lang::dimitri::levels::l1::compiler::validator::Generate;
extend lang::dimitri::levels::l2::compiler::validator::GenerateGlobal;
extend lang::dimitri::levels::l1::compiler::validator::GenerateSymbolJava;
extend lang::dimitri::levels::l1::compiler::validator::GenerateStructureJava;

import lang::dimitri::levels::l2::AST;
import lang::dimitri::levels::l1::compiler::SequenceSymbol2String;
import lang::dimitri::levels::l2::compiler::validator::ADT;

public str getClassDeclaration(list[SequenceSymbol] sequence, str extension, validator(name, format, globals, structs)) = 
	"public class <name> extends Validator {
	'
	'private boolean allowEOF = false;
	'
	'<getGlobals(globals)>
	'
	'<getConstructor(name, format)>
	'<getExtension(extension)>
	'<getParseBody(sequence)>
	'<getFindFooter()>
	'<getStructures(structs)>
	'}";

public str getGlobals(list[Global] globals) = "<for (g <- globals) {><generateGlobal(g)>\n<}>";


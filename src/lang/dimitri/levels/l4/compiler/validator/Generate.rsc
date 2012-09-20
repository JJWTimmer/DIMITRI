module lang::dimitri::levels::l4::compiler::validator::Generate
extend lang::dimitri::levels::l3::compiler::validator::Generate;

import lang::dimitri::levels::l4::compiler::validator::GenerateStructureJava;

public str generateL4(list[SequenceSymbol] sequence, str extension, Validator vld, str packageName) =
	getPackageName(packageName) + getImportsL3() + getClassDeclarationL4(sequence, extension, vld);
	

public str getClassDeclarationL4(list[SequenceSymbol] sequence, str extension, validator(name, format, globals, structs)) = 
	"public class <name> extends Validator {
	'
	'private boolean allowEOF = false;
	'
	'<getGlobals(globals)>
	'<getConstructor(name, format)>
	'<getExtension(extension)>
	'<getParseBody(sequence)>
	'<getFindFooter()>
	'<getStructuresL4(structs)>
	'}";
	
public str getStructuresL4(list[Structure] structs) =
	"<for (struct <- structs) {>	<generateStructureL4(struct)>\n<}>";
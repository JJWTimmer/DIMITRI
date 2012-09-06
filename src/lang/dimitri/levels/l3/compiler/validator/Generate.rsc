module lang::dimitri::levels::l3::compiler::validator::Generate
extend lang::dimitri::levels::l2::compiler::validator::Generate;
extend lang::dimitri::levels::l3::compiler::validator::GenerateStructureJava;

import lang::dimitri::levels::l3::AST;
import lang::dimitri::levels::l3::compiler::validator::ADT;

public str generateL3(list[SequenceSymbol] sequence, str extension, Validator vld, str packageName) =
	getPackageName(packageName) + getImportsL3() + getClassDeclarationL3(sequence, extension, vld);
	
public str getImportsL3() =
	"import static org.dimitri_lang.runtime.level1.ByteOrder.*;
	'import org.dimitri_lang.runtime.level1.ParseResult;
	'import org.dimitri_lang.runtime.level1.SubStream;
	'import org.dimitri_lang.runtime.level1.ValueSet;
	'import org.dimitri_lang.runtime.level3.Validator;
	'";
	
public str getClassDeclarationL3(list[SequenceSymbol] sequence, str extension, validator(name, format, globals, structs)) = 
	"public class <name> extends Validator {
	'
	'private boolean allowEOF = false;
	'
	'<getGlobals(globals)>
	'<getConstructor(name, format)>
	'<getExtension(extension)>
	'<getParseBody(sequence)>
	'<getFindFooter()>
	'<getStructures(structs)>
	'}";
module lang::dimitri::levels::l1::compiler::validator::Generate

import String;

import lang::dimitri::levels::l1::AST;
import lang::dimitri::levels::l1::compiler::validator::ADT;
import lang::dimitri::levels::l1::compiler::validator::GenerateSymbolJava;
import lang::dimitri::levels::l1::compiler::validator::GenerateStructureJava;
import lang::dimitri::levels::l1::compiler::SequenceSymbol2String;

public str generate(list[SequenceSymbol] sequence, str extension, Validator vld, str packageName) =
	getPackageName(packageName) + getImports() + getClassDeclaration(sequence, extension, vld);

public str getPackageName(str packageName) = "package <packageName>;\n\n";
public str getImports() = "import static org.dimitri_lang.validator.ByteOrder.*;\n\n";
public str getClassDeclaration(list[SequenceSymbol] sequence, str extension, validator(name, format, structs)) = 
	"public class <name> extends org.dimitri_lang.validator.Validator {
	'<getConstructor(name, format)>
	'<getExtension(extension)>
	'<getParseBody(sequence)>
	'<getFindFooter()>
	'<getStructures(structs)>
	'}";

public str getConstructor(str name, str format) = "	public <name>() { super(\"<format>\"); }\n";
public str getExtension(str extension) = "	@Override
										 '	public String getExtension() { return \"<extension>\"; }
										 ";
public str getParseBody(list[SequenceSymbol] symbols) {
	int label = 0;
	return "	@Override
	'	public org.dimitri_lang.validator.ParseResult tryParseBody() throws java.io.IOException {
	'		<for (symbol <- symbols) {>_currentSymbol = \"<writeSymbol(symbol)>\";
	'		<generateSymbol(symbol, label)><label +=1; }>
	'		return yes();
	'	}
	";
}
public str getFindFooter() =
	"	@Override
	'	public org.dimitri_lang.validator.ParseResult findNextFooter() throws java.io.IOException {
	'		return yes();
	'	}
	";
	
public str getStructures(list[Structure] structs) =
	"<for (struct <- structs) {>	<generateStructure(struct)>\n<}>";

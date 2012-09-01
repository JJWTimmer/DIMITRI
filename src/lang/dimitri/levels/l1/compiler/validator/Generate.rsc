module lang::dimitri::levels::l1::compiler::validator::Generate
extend lang::dimitri::levels::l1::compiler::validator::GenerateSymbolJava;
extend lang::dimitri::levels::l1::compiler::validator::GenerateStructureJava;

import String;

import lang::dimitri::levels::l1::AST;
import lang::dimitri::levels::l1::compiler::validator::ADT;
import lang::dimitri::levels::l1::compiler::SequenceSymbol2String;


public str generate(list[SequenceSymbol] sequence, str extension, Validator vld, str packageName) =
	getPackageName(packageName) + getImports() + getClassDeclaration(sequence, extension, vld);

public str getPackageName(str packageName) ="package <packageName>;\n\n";
public str getImports() =
	"import static org.dimitri_lang.runtime.level1.ByteOrder.*;
	'import org.dimitri_lang.runtime.level1.*;
	'
	";
public str getClassDeclaration(list[SequenceSymbol] sequence, str extension, validator(name, format, structs)) = 
	"public class <name> extends Validator {
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
	'	public ParseResult tryParseBody() throws java.io.IOException {
	'		<for (symbol <- symbols) {>_currentSymbol = \"<writeSymbol(symbol)>\";
	'		<generateSymbol(symbol, label)><label +=1; }>
	'		return yes();
	'	}
	";
}
public str getFindFooter() =
	"	@Override
	'	public ParseResult findNextFooter() throws java.io.IOException {
	'		return yes();
	'	}
	";
	
public str getStructures(list[Structure] structs) =
	"<for (struct <- structs) {>	<generateStructure(struct)>\n<}>";

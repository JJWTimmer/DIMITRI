module lang::dimitri::levels::l1::compiler::validator::Generate


import String;

import lang::dimitri::levels::l1::AST;
import lang::dimitri::levels::l1::compiler::validator::ADT;
import lang::dimitri::levels::l1::compiler::validator::GenerateSymbolJava;
import lang::dimitri::levels::l1::compiler::validator::GenerateStructureJava;
import lang::dimitri::levels::l1::compiler::Debug;

public str generate(list[SequenceSymbol] sequence, str extension, Validator validator, str packageName) {
	initLabel();
	return
"package <packageName>;

import static org.dimitri_lang.validator.ByteOrder.*;

public class <validator.name> extends org.dimitri_lang.validator.Validator {

	public <validator.name>() { super(\"<validator.format>\"); }

	@Override
	public String getExtension() { return \"<extension>\"; }

	@Override
	public org.dimitri_lang.validator.ParseResult tryParseBody() throws java.io.IOException {
<for (symbol <- sequence) {>_currentSymbol = \"<writeSymbol(symbol)>\";<generateSymbol(symbol)><}>
		return yes();
	}

	@Override
	public org.dimitri_lang.validator.ParseResult findNextFooter() throws java.io.IOException {
		return yes();
	}

<for (struct <- validator.structs) {><generateStructure(struct)>\n<}>
}";
}

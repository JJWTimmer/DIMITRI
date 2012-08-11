module lang::dimitri::levels::l1::compiler::validator::GenerateSymbolJava

import IO;
import List;
import Set;

import lang::dimitri::levels::l1::AST;

int label;

public void initLabel() {
	label = 0;
}

private int getNextLabel() {
	label += 1;
	return label;
}

public str generateSymbol(zeroOrMoreSeq(choiceSeq(set[SequenceSymbol] symbols))) {
	return "top<getNextLabel()>: for (;;) {\n<generateChoiceSeqSymbols(symbols, true)>mergeSubSequence();break top<label>;\n}\n";
}

public str generateSymbol(choiceSeq(set[SequenceSymbol] symbols)) {
	return "top<getNextLabel()>: for (;;) {\n<generateChoiceSeqSymbols(symbols, false)><containsEmptyList(symbols) ? "mergeSubSequence();break top<label>" : "return no()">;\n}\n";
}

public default str generateSymbol(SequenceSymbol symbol) {
	return "// skipped: <symbol>\n";
}

private str generateChoiceSeqSymbols(set[SequenceSymbol] symbols, bool iterate) {
	str res = "";
	str fin = "";

	void generateChoiceSeqSymbol(SequenceSymbol s, bool final) {
		//println("generating: <s>");
		str breakTarget = final ? "mergeSubSequence();break top<label>" : "break";
		str continueStatement = final ? "mergeSubSequence();continue" : "continue";
		//println(breakTarget);
		if (res == "") {
			switch (s) {
				case struct(id(name)): res += "if (parse<name>()) { <iterate ? continueStatement : breakTarget>; }\n";
				case optionalSeq(struct(id(name))): res += "parse<name>();\n<iterate ? continueStatement : breakTarget>;\n";
				case zeroOrMoreSeq(struct(id(name))): res += "for (;;) {\nif (parse<name>()) { <continueStatement>; }\n<breakTarget>;\n}\n";
			}
		} else {
			switch (s) {
				case struct(id(name)): res = "if (parse<name>()) {\n<res>}\n";
				case optionalSeq(struct(id(name))): res = "parse<name>();\n<res>";
				case zeroOrMoreSeq(struct(id(name))): res = "for (;;) {\nif (parse<name>()) { <continueStatement>; }\n<breakTarget>;\n}\n<res>";
			}
		}
	}

	for (fixedOrderSeq(list[SequenceSymbol] sequence) <- symbols) {
		//println("generating: <sequence>");
		sequence = reverse(sequence);
		bool innerMost = true;
		while (!isEmpty(sequence)) {
			//println("Generating sequence: <sequence>, <size(tail(sequence))>"); 
			generateChoiceSeqSymbol(head(sequence), innerMost);
			innerMost = false;
			sequence = tail(sequence);
		}
		if (res != "") {
			fin += "_input.mark();\n" + res + "clearSubSequence();_input.reset();";
		}
		res = "";
	}
	return fin;
}


//TODO: ask about this function and line 42
private bool containsEmptyList(set[SequenceSymbol] symbols) {
	for (fixedOrderSeq(list[SequenceSymbol] sequence) <- symbols) {
		if (size(sequence) == 0) {
			return true;
		}
	}
	return false;
}

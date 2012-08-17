module lang::dimitri::levels::l1::compiler::validator::GenerateSymbolJava

import IO;
import List;
import Set;

import lang::dimitri::levels::l1::compiler::Annotate;
import lang::dimitri::levels::l1::AST;

int label;

public void initLabel() {
	label = 0;
}

private int getNextLabel() {
	label += 1;
	return label;
}

public str generateSymbol(s:zeroOrMoreSeq(choiceSeq(set[SequenceSymbol] symbols))) {
	return 	"top<getNextLabel()>:
			'	for (;;) {
			'		<generateEOFCheck(s@allowEOF)>
			'		<generateChoiceSeqSymbols(symbols, true)>
			'		mergeSubSequence();
			'		break top<label>;
			'	}
			'";
}

public str generateSymbol(s:choiceSeq(set[SequenceSymbol] symbols)) {
	return	"top<getNextLabel()>:
			'	for (;;) {
			'		<generateEOFCheck(s@allowEOF)>
			'		<generateChoiceSeqSymbols(symbols, false)>
			'		<containsEmptyList(symbols) ? "mergeSubSequence();
			'		break top<label>" : "return no()">;
			'	}
			'";
}

public default str generateSymbol(SequenceSymbol symbol) {
	return "	// skipped: <symbol>\n";
}

private str generateChoiceSeqSymbols(set[SequenceSymbol] symbols, bool iterate) {
	str res = "";
	str fin = "";

	void generateChoiceSeqSymbol(SequenceSymbol s, bool final) {
		str breakTarget = final ?	"mergeSubSequence();
									'break top<label>" 
								: 	"break";
		str continueStatement = final ? "mergeSubSequence();
										'continue"
									  : "continue";
		if (res == "") {
			switch (s) {
				case struct(id(name)): res += "if (parse<name>()) {
											  '	<iterate ? continueStatement : breakTarget>;
											  '}
											  ";
				case optionalSeq(struct(id(name))): res +=	"parse<name>();
															'<iterate ? continueStatement : breakTarget>;
															";
				case zeroOrMoreSeq(struct(id(name))): res +=	"for (;;) {
																'	if (parse<name>()) {
																'		<continueStatement>;
																'	}
																'	<breakTarget>;
																'}
																";
			}
		} else {
			switch (s) {
				case struct(id(name)): res =	"if (parse<name>()) {
												'	<res>
												'}
												";
				case optionalSeq(struct(id(name))): res =	"parse<name>();
														 	'<res>";
				case zeroOrMoreSeq(struct(id(name))): res =	"for (;;) {
															'	if (parse<name>()) {
															'		<continueStatement>;
															'	}
															'	<breakTarget>;
															'}
															'<res>";
			}
		}
	}

	for (fixedOrderSeq(list[SequenceSymbol] sequence) <- symbols) {
		sequence = reverse(sequence);
		bool innerMost = true;
		while (!isEmpty(sequence)) {
			generateChoiceSeqSymbol(head(sequence), innerMost);
			innerMost = false;
			sequence = tail(sequence);
		}
		if (res != "") {
			fin +=	"_input.mark();
					'<res>
					'clearSubSequence();
					'_input.reset();";
		}
		res = "";
	}
	return fin;
}

private bool containsEmptyList(set[SequenceSymbol] symbols) {
	for (fixedOrderSeq(list[SequenceSymbol] sequence) <- symbols) {
		if (size(sequence) == 0) {
			return true;
		}
	}
	return false;
}

private str generateEOFCheck(bool allowEOF) {
	return 	"if (_input.atEOF()) {
			'	return <allowEOF ? "yes" : "no">();
			'}";
}
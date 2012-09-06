module lang::dimitri::levels::l1::compiler::validator::GenerateSymbolJava

import IO;
import List;
import Set;

import lang::dimitri::levels::l1::compiler::Annotate;
import lang::dimitri::levels::l1::AST;

public str generateSymbol(s:zeroOrMoreSeq(choiceSeq(set[SequenceSymbol] symbols)), int label) {
	return 	"top<label>:
			'	for (;;) {
			'		<generateEOFCheck(s@allowEOF)>
			'		<generateChoiceSeqSymbols(symbols, true, label)>
			'		mergeSubSequence();
			'		break top<label>;
			'	}
			'";
}

public str generateSymbol(s:choiceSeq(set[SequenceSymbol] symbols), int label) {
	return	"top<label>:
			'	for (;;) {
			'		<generateEOFCheck(s@allowEOF)>
			'		<generateChoiceSeqSymbols(symbols, false, label)>
			'		<containsEmptyList(symbols) ? "mergeSubSequence();
			'		break top<label>" : "return no()">;
			'	}
			'";
}

public default str generateSymbol(SequenceSymbol symbol, int label) {
	return "	// skipped: <symbol>\n";
}

private str generateChoiceSeqSymbols(set[SequenceSymbol] symbols, bool iterate, int label) {
	str res = "";
	str fin = "";

	for (fixedOrderSeq(list[SequenceSymbol] sequence) <- symbols) {
		sequence = reverse(sequence);
		bool innerMost = true;
		while (!isEmpty(sequence)) {
			res = generateChoiceSeqSymbol(res, head(sequence), innerMost, iterate, label);
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

private str generateChoiceSeqSymbol(str res, SequenceSymbol s, bool final, bool iterate, int label) {
	str breakTarget = final ?	"mergeSubSequence();
								'break top<label>" 
							: 	"break";
	str continueStatement = final ? "mergeSubSequence();
									'continue"
								  : "continue";
	if (res == "") {
		switch (s) {
			case SequenceSymbol::struct(id(sname)): res = "if (parse<sname>()) {
										   				   '	<iterate ? continueStatement : breakTarget>;
										   				   '}
										  				   '";
			case optionalSeq(struct(id(sname))): res =	"parse<sname>();
														'<iterate ? continueStatement : breakTarget>;
														";
			case zeroOrMoreSeq(struct(id(sname))): res =	"for (;;) {
															'	if (parse<sname>()) {
															'		<continueStatement>;
															'	}
															'	<breakTarget>;
															'}
															";
		}
	} else {
		switch (s) {
			case struct(id(sname)): res =	"if (parse<sname>()) {
											'	<res>
											'}
											";
			case optionalSeq(struct(id(sname))): res =	"parse<sname>();
													 	'<res>";
			case zeroOrMoreSeq(struct(id(sname))): res ="for (;;) {
														'	if (parse<sname>()) {
														'		<continueStatement>;
														'	}
														'	<breakTarget>;
														'}
														'<res>";
		}
	}
	return res;
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
			'}
			'allowEOF = <allowEOF>;";
}
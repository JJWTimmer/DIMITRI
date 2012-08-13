package org.dimitri_lang.validator.generated;

import static org.dimitri_lang.validator.ByteOrder.*;

public class PNGValidator extends org.dimitri_lang.validator.Validator {

	public PNGValidator() { super("png"); }

	@Override
	public String getExtension() { return "png"; }

	@Override
	public org.dimitri_lang.validator.ParseResult tryParseBody() throws java.io.IOException {
_currentSymbol = "( [ Signature ] )";top1: for (;;) {
_input.mark();
if (parseSignature()) { mergeSubSequence();break top1; }
clearSubSequence();_input.reset();return no();
}
_currentSymbol = "( [ Chunk ] )*";top2: for (;;) {
_input.mark();
if (parseChunk()) { mergeSubSequence();continue; }
clearSubSequence();_input.reset();mergeSubSequence();break top2;
}
_currentSymbol = "( [ End ] )";top3: for (;;) {
_input.mark();
if (parseEnd()) { mergeSubSequence();break top3; }
clearSubSequence();_input.reset();return no();
}

		return yes();
	}

	@Override
	public org.dimitri_lang.validator.ParseResult findNextFooter() throws java.io.IOException {
		return yes();
	}

private boolean parseSignature() throws java.io.IOException {markStart();long Signature_marker;Signature_marker = _input.unsigned().byteOrder(BIG_ENDIAN).readInteger(8);org.dimitri_lang.validator.ValueSet vs2 = new org.dimitri_lang.validator.ValueSet();vs2.addEquals(137);if (!vs2.equals(Signature_marker)) return noMatch();long Signature_marker_1;Signature_marker_1 = _input.unsigned().byteOrder(BIG_ENDIAN).readInteger(8);org.dimitri_lang.validator.ValueSet vs5 = new org.dimitri_lang.validator.ValueSet();vs5.addEquals(80);if (!vs5.equals(Signature_marker_1)) return noMatch();long Signature_marker_2;Signature_marker_2 = _input.unsigned().byteOrder(BIG_ENDIAN).readInteger(8);org.dimitri_lang.validator.ValueSet vs8 = new org.dimitri_lang.validator.ValueSet();vs8.addEquals(78);if (!vs8.equals(Signature_marker_2)) return noMatch();long Signature_marker_3;Signature_marker_3 = _input.unsigned().byteOrder(BIG_ENDIAN).readInteger(8);org.dimitri_lang.validator.ValueSet vs11 = new org.dimitri_lang.validator.ValueSet();vs11.addEquals(71);if (!vs11.equals(Signature_marker_3)) return noMatch();long Signature_marker_4;Signature_marker_4 = _input.unsigned().byteOrder(BIG_ENDIAN).readInteger(8);org.dimitri_lang.validator.ValueSet vs14 = new org.dimitri_lang.validator.ValueSet();vs14.addEquals(13);if (!vs14.equals(Signature_marker_4)) return noMatch();long Signature_marker_5;Signature_marker_5 = _input.unsigned().byteOrder(BIG_ENDIAN).readInteger(8);org.dimitri_lang.validator.ValueSet vs17 = new org.dimitri_lang.validator.ValueSet();vs17.addEquals(10);if (!vs17.equals(Signature_marker_5)) return noMatch();long Signature_marker_6;Signature_marker_6 = _input.unsigned().byteOrder(BIG_ENDIAN).readInteger(8);org.dimitri_lang.validator.ValueSet vs20 = new org.dimitri_lang.validator.ValueSet();vs20.addEquals(26);if (!vs20.equals(Signature_marker_6)) return noMatch();long Signature_marker_7;Signature_marker_7 = _input.unsigned().byteOrder(BIG_ENDIAN).readInteger(8);org.dimitri_lang.validator.ValueSet vs23 = new org.dimitri_lang.validator.ValueSet();vs23.addEquals(10);if (!vs23.equals(Signature_marker_7)) return noMatch();addSubSequence("Signature");return true; }
private boolean parseChunk() throws java.io.IOException {markStart();long Chunk_length;Chunk_length = _input.unsigned().byteOrder(BIG_ENDIAN).readInteger(32);if (!_input.skipBits(32)) return noMatch();long Chunk_chunkdata_len;Chunk_chunkdata_len = Chunk_length;if (_input.skip(Chunk_chunkdata_len) != Chunk_chunkdata_len) return noMatch();if (!_input.skipBits(32)) return noMatch();addSubSequence("Chunk");return true; }
private boolean parseEnd() throws java.io.IOException {markStart();long End_length;End_length = _input.unsigned().byteOrder(BIG_ENDIAN).readInteger(32);org.dimitri_lang.validator.ValueSet vs2 = new org.dimitri_lang.validator.ValueSet();vs2.addEquals(0);if (!vs2.equals(End_length)) return noMatch();long End_chunktype;End_chunktype = _input.unsigned().byteOrder(BIG_ENDIAN).readInteger(8);org.dimitri_lang.validator.ValueSet vs5 = new org.dimitri_lang.validator.ValueSet();vs5.addEquals(73);if (!vs5.equals(End_chunktype)) return noMatch();long End_chunktype_s1;End_chunktype_s1 = _input.unsigned().byteOrder(BIG_ENDIAN).readInteger(8);org.dimitri_lang.validator.ValueSet vs8 = new org.dimitri_lang.validator.ValueSet();vs8.addEquals(69);if (!vs8.equals(End_chunktype_s1)) return noMatch();long End_chunktype_s2;End_chunktype_s2 = _input.unsigned().byteOrder(BIG_ENDIAN).readInteger(8);org.dimitri_lang.validator.ValueSet vs11 = new org.dimitri_lang.validator.ValueSet();vs11.addEquals(78);if (!vs11.equals(End_chunktype_s2)) return noMatch();long End_chunktype_s3;End_chunktype_s3 = _input.unsigned().byteOrder(BIG_ENDIAN).readInteger(8);org.dimitri_lang.validator.ValueSet vs14 = new org.dimitri_lang.validator.ValueSet();vs14.addEquals(68);if (!vs14.equals(End_chunktype_s3)) return noMatch();if (!_input.skipBits(32)) return noMatch();addSubSequence("End");return true; }

}
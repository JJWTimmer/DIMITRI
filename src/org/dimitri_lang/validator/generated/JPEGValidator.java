package org.dimitri_lang.validator.generated;

import static org.dimitri_lang.validator.ByteOrder.*;

public class JPEGValidator extends org.dimitri_lang.validator.Validator {

	public JPEGValidator() {
		super("jpeg");
	}

	@Override
	public String getExtension() {
		return "jpeg";
	}

	@Override
	public org.dimitri_lang.validator.ParseResult tryParseBody()
			throws java.io.IOException {
		_currentSymbol = "( [ SOI ] )";
		top1: for (;;) {
			_input.mark();
			if (parseSOI()) {
				mergeSubSequence();
				break top1;
			}
			clearSubSequence();
			_input.reset();
			return no();
		}

		return yes();
	}

	@Override
	public org.dimitri_lang.validator.ParseResult findNextFooter()
			throws java.io.IOException {
		return yes();
	}

	private boolean parseSOI() throws java.io.IOException {
		markStart();
		long SOI_marker;
		SOI_marker = _input.unsigned().byteOrder(LITTLE_ENDIAN).readInteger(8);
		org.dimitri_lang.validator.ValueSet vs2 = new org.dimitri_lang.validator.ValueSet();
		vs2.addEquals(255);
		if (!vs2.equals(SOI_marker))
			return noMatch();
		long SOI_marker_1;
		SOI_marker_1 = _input.unsigned().byteOrder(LITTLE_ENDIAN)
				.readInteger(8);
		org.dimitri_lang.validator.ValueSet vs5 = new org.dimitri_lang.validator.ValueSet();
		vs5.addEquals(216);
		if (!vs5.equals(SOI_marker_1))
			return noMatch();
		long SOI_strng;
		SOI_strng = _input.unsigned().byteOrder(LITTLE_ENDIAN).readInteger(8);
		org.dimitri_lang.validator.ValueSet vs8 = new org.dimitri_lang.validator.ValueSet();
		vs8.addEquals(102);
		if (!vs8.equals(SOI_strng))
			return noMatch();
		long SOI_strng_s1;
		SOI_strng_s1 = _input.unsigned().byteOrder(LITTLE_ENDIAN)
				.readInteger(8);
		org.dimitri_lang.validator.ValueSet vs11 = new org.dimitri_lang.validator.ValueSet();
		vs11.addEquals(111);
		if (!vs11.equals(SOI_strng_s1))
			return noMatch();
		long SOI_strng_s2;
		SOI_strng_s2 = _input.unsigned().byteOrder(LITTLE_ENDIAN)
				.readInteger(8);
		org.dimitri_lang.validator.ValueSet vs14 = new org.dimitri_lang.validator.ValueSet();
		vs14.addEquals(111);
		if (!vs14.equals(SOI_strng_s2))
			return noMatch();
		long SOI_strng_s3;
		SOI_strng_s3 = _input.unsigned().byteOrder(LITTLE_ENDIAN)
				.readInteger(8);
		org.dimitri_lang.validator.ValueSet vs17 = new org.dimitri_lang.validator.ValueSet();
		vs17.addEquals(98);
		if (!vs17.equals(SOI_strng_s3))
			return noMatch();
		long SOI_strng_s4;
		SOI_strng_s4 = _input.unsigned().byteOrder(LITTLE_ENDIAN)
				.readInteger(8);
		org.dimitri_lang.validator.ValueSet vs20 = new org.dimitri_lang.validator.ValueSet();
		vs20.addEquals(97);
		if (!vs20.equals(SOI_strng_s4))
			return noMatch();
		long SOI_strng_s5;
		SOI_strng_s5 = _input.unsigned().byteOrder(LITTLE_ENDIAN)
				.readInteger(8);
		org.dimitri_lang.validator.ValueSet vs23 = new org.dimitri_lang.validator.ValueSet();
		vs23.addEquals(114);
		if (!vs23.equals(SOI_strng_s5))
			return noMatch();
		long SOI_strng_1;
		SOI_strng_1 = _input.unsigned().byteOrder(LITTLE_ENDIAN).readInteger(8);
		org.dimitri_lang.validator.ValueSet vs26 = new org.dimitri_lang.validator.ValueSet();
		vs26.addEquals(1);
		if (!vs26.equals(SOI_strng_1))
			return noMatch();
		long SOI_strng_2;
		SOI_strng_2 = _input.unsigned().byteOrder(LITTLE_ENDIAN).readInteger(8);
		org.dimitri_lang.validator.ValueSet vs29 = new org.dimitri_lang.validator.ValueSet();
		vs29.addEquals(116);
		if (!vs29.equals(SOI_strng_2))
			return noMatch();
		long SOI_strng_2_s1;
		SOI_strng_2_s1 = _input.unsigned().byteOrder(LITTLE_ENDIAN)
				.readInteger(8);
		org.dimitri_lang.validator.ValueSet vs32 = new org.dimitri_lang.validator.ValueSet();
		vs32.addEquals(101);
		if (!vs32.equals(SOI_strng_2_s1))
			return noMatch();
		long SOI_strng_2_s2;
		SOI_strng_2_s2 = _input.unsigned().byteOrder(LITTLE_ENDIAN)
				.readInteger(8);
		org.dimitri_lang.validator.ValueSet vs35 = new org.dimitri_lang.validator.ValueSet();
		vs35.addEquals(115);
		if (!vs35.equals(SOI_strng_2_s2))
			return noMatch();
		long SOI_strng_2_s3;
		SOI_strng_2_s3 = _input.unsigned().byteOrder(LITTLE_ENDIAN)
				.readInteger(8);
		org.dimitri_lang.validator.ValueSet vs38 = new org.dimitri_lang.validator.ValueSet();
		vs38.addEquals(116);
		if (!vs38.equals(SOI_strng_2_s3))
			return noMatch();
		long SOI_fw;
		SOI_fw = _input.unsigned().byteOrder(LITTLE_ENDIAN).readInteger(8);
		long SOI_s;
		SOI_s = _input.unsigned().byteOrder(BIG_ENDIAN).readInteger(8);
		org.dimitri_lang.validator.ValueSet vs43 = new org.dimitri_lang.validator.ValueSet();
		vs43.addEquals(SOI_s);
		if (!vs43.equals(SOI_fw))
			return noMatch();
		long SOI_ref;
		SOI_ref = _input.unsigned().byteOrder(LITTLE_ENDIAN).readInteger(8);
		org.dimitri_lang.validator.ValueSet vs46 = new org.dimitri_lang.validator.ValueSet();
		vs46.addEquals(SOI_s);
		if (!vs46.equals(SOI_ref))
			return noMatch();
		long SOI_sz;
		SOI_sz = _input.unsigned().byteOrder(LITTLE_ENDIAN).readInteger(16);
		long SOI_szref_len;
		SOI_szref_len = SOI_sz;
		if (_input.skip(SOI_szref_len) != SOI_szref_len)
			return noMatch();
		addSubSequence("SOI");
		return true;
	}

}
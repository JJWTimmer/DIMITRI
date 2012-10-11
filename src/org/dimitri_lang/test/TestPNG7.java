package org.dimitri_lang.test;

import org.junit.Assert;
import org.junit.Test;
import org.dimitri_lang.runtime.level1.*;
import org.dimitri_lang.runtime.level3.Validator;
import org.dimitri_lang.runtime.level3.ValidatorInputStream;
import org.dimitri_lang.runtime.level3.ValidatorInputStreamFactory;
import org.dimitri_lang.generated.*;

public class TestPNG7 {

	public final static String TEST_DIRECTORY = "testdata";
	public final static String TEST_FILE = "280px-PNG_transparency_demonstration_1.png";
	private String _name;

	public TestPNG7() {
		_name = TEST_FILE;
	}

	@Test
	public void testGeneratedValidator() {
		Validator validator = new PNG7Validator();
		ValidatorInputStream stream = ValidatorInputStreamFactory
				.create(TEST_DIRECTORY + "/" + _name);
		validator.setStream(stream);
		ParseResult result = validator.tryParse();
		Assert.assertTrue("Parsing failed. " + validator.getClass() + " on "
				+ _name + ". Last read: " + result.getLastRead()
				+ "; Last location: " + result.getLastLocation()
				+ "; Last symbol: " + result.getSymbol() + "; Sequence: "
				+ result.getSequence(), result.isSuccess());
	}

}

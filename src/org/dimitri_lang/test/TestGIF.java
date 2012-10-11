package org.dimitri_lang.test;

import org.junit.Assert;
import org.junit.Test;
import org.dimitri_lang.runtime.level1.*;
import org.dimitri_lang.runtime.level3.Validator;
import org.dimitri_lang.runtime.level3.ValidatorInputStream;
import org.dimitri_lang.runtime.level3.ValidatorInputStreamFactory;
import org.dimitri_lang.generated.*;

public class TestGIF {

	public final static String TEST_DIRECTORY = "testdata";
	public final static String TEST_FILE = "200px-Rotating_earth_%28large%29.gif";
	private String _name;

	public TestGIF() {
		_name = TEST_FILE;
	}

	@Test
	public void testGeneratedValidator() {
		Validator validator = new GIFValidator();
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

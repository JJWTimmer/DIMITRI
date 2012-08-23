package org.dimitri_lang.validator.test;

import java.io.File;
import java.util.ArrayList;
import java.util.Collection;

import org.junit.Assert;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;
import org.junit.runners.Parameterized.Parameters;

import org.dimitri_lang.*;
import org.dimitri_lang.validator.*;
import org.dimitri_lang.validator.generated.*;

public class TestPNG1 {

	public final static String TEST_DIRECTORY = "testdata";
	public final static String TEST_FILE = "280px-PNG_transparency_demonstration_1.png";
	private String _name;
	
	public TestPNG1() {
		_name = TEST_FILE;
	}

	@Test
	public void testGeneratedValidator() {
		Validator validator = new PNG1Validator();
		ValidatorInputStream stream = ValidatorInputStreamFactory.create(TEST_DIRECTORY + "/" + _name);
		validator.setStream(stream);
		ParseResult result = validator.tryParse();
		Assert.assertTrue("Parsing failed. " + validator.getClass() + " on " + _name + ". Last read: " + result.getLastRead() + "; Last location: " + result.getLastLocation() + "; Last symbol: " + result.getSymbol() + "; Sequence: " + result.getSequence(), result.isSuccess());
	}

}

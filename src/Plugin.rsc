module Plugin

import IO;

import lang::dimitri::Level1;
import lang::dimitri::Level2;
import lang::dimitri::Level3;
//import lang::dimitri::Level4;
//import lang::dimitri::Level5;

public void main() {
	registerL1();
	registerL2();
	registerL3();
	registerL4();
	registerL5();
}

public void generateAll() {
	println("Generating all formats...");
	formatDir =|project://dimitri/formats|;
	for (file <- listEntries(formatDir), isFile(formatDir + file)) {
		format = formatDir + file;
		def = false;
		switch (format.extension) {
			case "dim1" : compileL1(format);
			case "dim2" : compileL2(format);
			//case "dim3" : compileL3(format);
			//case "dim4" : compileL4(format);
			//case "dim5" : compileL5(format);
			default 	: def = true;
		}
		if (!def)
			println("Generated: <file>");
		else
			println("Skipped: <file>");
	}
	println("Done.");
}
module Plugin

import IO;

import lang::dimitri::Level1;
import lang::dimitri::Level2;
import lang::dimitri::Level3;
import lang::dimitri::Level4;

public loc T11 = |project://dimitri/formats/test1.dim1|;
public loc T21 = |project://dimitri/formats/test2.dim1|;
public loc T12 = |project://dimitri/formats/test1.dim2|;
public loc T22 = |project://dimitri/formats/test2.dim2|;
public loc T13 = |project://dimitri/formats/test1.dim3|;
public loc T23 = |project://dimitri/formats/test2.dim3|;
public loc T14 = |project://dimitri/formats/test1.dim4|;
public loc PNG1 = |project://dimitri/formats/png.dim1|;

public void main() {
	registerL1();
	registerL2();
	registerL3();
	registerL4();
}

public void generateAll() {
	println("Generating all formats...");
	formatDir =|project://dimitri/formats|;
	for (file <- listEntries(formatDir), isFile(formatDir + file)) {
		format = formatDir + file;
		switch (format.extension) {
			case "dim1" : compileL1(format);
			case "dim2" : compileL2(format);
			case "dim3" : compileL3(format);
			//case "dim4" : compileL4(format);
			default 	: ;
		}
	}
	println("Done.");
}
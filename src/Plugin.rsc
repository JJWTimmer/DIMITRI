module Plugin

import IO;

extend lang::dimitri::Current;

public str EXT  = "dim";

public loc TST = |project://dimitri/formats/t1.dim|;
public loc PNG = |project://dimitri/formats/png_l1.dim|;

public void main() {
	println("Loaded Dimitri plugin");
	
	registerLang(EXT);
}
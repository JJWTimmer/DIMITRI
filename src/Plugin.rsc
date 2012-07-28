module Plugin

import IO;

extend lang::dimitri::Current;

public str EXT  = "dim";

public void main() {
	println("Loaded Dimitri plugin");
	
	registerLang(EXT);
}
module Plugin

import IO;

import lang::dimitri::levels::Level1;

public str LANG = "Dimitri L1";
public str EXT  = "dim";

public void main() {
	println("Loaded Dimitri plugin");
	
	registerL1(LANG, EXT);
}
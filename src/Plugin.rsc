module Plugin

import IO;

import lang::dimitri::bootstrap::Bootstrap;
import lang::dimitri::Base;

public void main() {
	println("Loaded Dimitri plugin");
	
	registerHost();
	
	loadDimitri();
}
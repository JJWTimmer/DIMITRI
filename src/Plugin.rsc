module Plugin

import lang::dimitri::Level1;
import lang::dimitri::Level2;

public loc TST = |project://dimitri/formats/test2.dim1|;
public loc PNG = |project://dimitri/formats/png.dim1|;

public void main() {
	registerL1();
	registerL2();
}
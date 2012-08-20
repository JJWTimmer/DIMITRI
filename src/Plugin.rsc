module Plugin

import lang::dimitri::Level1;
import lang::dimitri::Level2;

public loc T11 = |project://dimitri/formats/test1.dim1|;
public loc T21 = |project://dimitri/formats/test2.dim1|;
public loc T12 = |project://dimitri/formats/test1.dim2|;
public loc T22 = |project://dimitri/formats/test2.dim2|;
public loc PNG1 = |project://dimitri/formats/png.dim1|;
public loc PNG2 = |project://dimitri/formats/png.dim2|;

public void main() {
	registerL1();
	registerL2();
}
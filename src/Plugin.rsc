module Plugin

import lang::dimitri::Level1;
import lang::dimitri::Level2;
import lang::dimitri::Level3;

public loc T11 = |project://dimitri/formats/test1.dim1|;
public loc T21 = |project://dimitri/formats/test2.dim1|;
public loc T12 = |project://dimitri/formats/test1.dim2|;
public loc T22 = |project://dimitri/formats/test2.dim2|;
public loc T13 = |project://dimitri/formats/test1.dim3|;
public loc T23 = |project://dimitri/formats/test2.dim3|;
public loc PNG1 = |project://dimitri/formats/png.dim1|;
public loc PNG2 = |project://dimitri/formats/png.dim2|;

public void main() {
	registerL1();
	registerL2();
	registerL3();
}
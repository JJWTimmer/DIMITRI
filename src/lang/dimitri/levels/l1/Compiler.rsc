module lang::dimitri::levels::l1::Compiler

import IO;
import util::ValueUI;

import lang::dimitri::levels::l1::AST;
import lang::dimitri::levels::l1::compiler::PropagateDefaults;
import lang::dimitri::levels::l1::compiler::Desugar;
import lang::dimitri::levels::l1::compiler::PropagateConstants;

public void compile(Format ast, list[FormatSpecifier] langConsts) {
	ast = propagateDefaults(ast, langConsts);
	ast = desugar(ast);
	ast = propagateConstants(ast);
	
	text(ast);

	//TODO: annotate
	//TODO: build
	//TODO: generateJava && generateDebugDimitri
}
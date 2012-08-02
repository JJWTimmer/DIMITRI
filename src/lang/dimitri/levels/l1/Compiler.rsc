module lang::dimitri::levels::l1::Compiler

import IO;
import util::ValueUI;

import lang::dimitri::levels::l1::AST;
import lang::dimitri::levels::l1::compiler::PropagateDefaults;
import lang::dimitri::levels::l1::compiler::Desugar;
import lang::dimitri::levels::l1::compiler::PropagateConstants;
import lang::dimitri::levels::l1::compiler::Annotate;

public void compile(Format ast, list[FormatSpecifier] langConsts) {
	ast = propagateDefaults(ast, langConsts);
	ast = desugar(ast);
	ast = propagateConstants(ast);
	//ast = annotate(ast);
	
	text(ast);

	//TODO: build
	//TODO: generateJava && generateDebugDimitri
}
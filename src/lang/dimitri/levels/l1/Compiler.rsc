module lang::dimitri::levels::l1::Compiler

import IO;
import util::ValueUI;

import lang::dimitri::levels::l1::AST;
import lang::dimitri::levels::l1::compiler::PropagateDefaults;
import lang::dimitri::levels::l1::compiler::Desugar;
import lang::dimitri::levels::l1::compiler::PropagateConstants;
import lang::dimitri::levels::l1::compiler::Annotate;
import lang::dimitri::levels::l1::compiler::Debug;

public void compile(Format ast, list[FormatSpecifier] langConsts) {
	ast = propagateDefaults(ast, langConsts);
	ast = desugar(ast);
	ast = propagateConstants(ast);
	ast = annotate(ast);
	
text(ast);

	writeFile(|project://dimitri/formats/debug/<ast.name.val>.dim|, generateFormat(ast, langConsts));
	
	//TODO: build validator
	//TODO: generate Java
}
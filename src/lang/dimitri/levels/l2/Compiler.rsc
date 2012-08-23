module lang::dimitri::levels::l2::Compiler

import IO;
import String;
//import util::ValueUI;

import lang::dimitri::levels::l1::compiler::PropagateDefaults;
import lang::dimitri::levels::l1::compiler::Normalize;

import lang::dimitri::levels::l2::compiler::PropagateConstants;
import lang::dimitri::levels::l2::compiler::Annotate;
import lang::dimitri::levels::l2::compiler::Debug;
import lang::dimitri::levels::l2::AST;
import lang::dimitri::levels::l2::compiler::validator::Transform;
import lang::dimitri::levels::l2::compiler::validator::ADT;
import lang::dimitri::levels::l2::compiler::validator::Generate;

public void compile(Format ast, set[FormatSpecifier] langConsts, str packageName) {
	ast = propagateDefaults(ast, langConsts);
	ast = normalize(ast);
	ast = propagateConstants(ast);
	ast = annotate(ast);
	
//text(ast);

	writeFile(|project://dimitri/formats/debug/<ast.name.val>.dim2|, debugFormat(ast, langConsts));

	validatorADT = getValidatorL2(ast);

//text(validatorADT);

	writeFile(|project://dimitri/src/org/dimitri_lang/validator/generated/<toUpperCase(ast.name.val)>Validator.java|,
		generate(ast.sequence.symbols, ast.extensions[0].val, validatorADT, packageName));

}
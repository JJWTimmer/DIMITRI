module lang::dimitri::levels::l3::Compiler

import IO;
import String;
import util::ValueUI;

import lang::dimitri::levels::l1::compiler::PropagateDefaults;

import lang::dimitri::levels::l2::compiler::PropagateConstants;
import lang::dimitri::levels::l2::compiler::Annotate;

import lang::dimitri::levels::l3::AST;
import lang::dimitri::levels::l3::prettyPrinting::PrettyPrinting;
import lang::dimitri::levels::l3::compiler::validator::ADT;
import lang::dimitri::levels::l3::compiler::validator::Generate;
import lang::dimitri::levels::l3::compiler::validator::Transform;
import lang::dimitri::levels::l3::compiler::Normalize;

public void compile(Format ast, str packageName) {
	ast = propagateDefaults(ast);
	ast = normalizeL3(ast);
	ast = propagateConstants(ast);
	ast = annotate(ast);
	
//text(ast);

	writeFile(|project://dimitri/formats/debug/<ast.name.val>.dim3|, prettyPrint(ast));

	validatorADT = getValidatorL2(ast);

//text(validatorADT);
	javaPathPrefix = "dimitri/src/<replaceAll(packageName, ".", "/")>/";

	writeFile(|project://<javaPathPrefix>/<toUpperCase(ast.name.val)>Validator.java|,
		generateL3(ast.sequence.symbols, ast.extensions[0].val, validatorADT, packageName));

}
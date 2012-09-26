module lang::dimitri::levels::l5::Compiler

import IO;
import String;
import util::ValueUI;

import lang::dimitri::levels::l1::compiler::PropagateDefaults;

import lang::dimitri::levels::l4::compiler::validator::ADT;
import lang::dimitri::levels::l4::compiler::validator::Transform;
import lang::dimitri::levels::l4::compiler::validator::Generate;

import lang::dimitri::levels::l5::AST;
import lang::dimitri::levels::l5::compiler::Normalize;
import lang::dimitri::levels::l5::prettyPrinting::PrettyPrinting;
import lang::dimitri::levels::l5::compiler::PropagateConstants;
import lang::dimitri::levels::l5::compiler::Annotate;

public void compile(Format ast, str packageName) {
	ast = propagateDefaults(ast);
	ast = normalizeL5(ast);
	ast = propagateConstantsL4(ast);
	ast = annotate(ast);

	writeFile(|project://dimitri/formats/debug/<ast.name.val>.dim5|, prettyPrint(ast));
//
//	validatorADT = getValidatorL2(ast);
//
//	javaPathPrefix = "dimitri/src/<replaceAll(packageName, ".", "/")>/";
//
//	writeFile(|project://<javaPathPrefix>/<toUpperCase(ast.name.val)>Validator.java|,
//		generateL4(ast.sequence.symbols, ast.extensions[0].val, validatorADT, packageName));

}
module lang::dimitri::levels::l4::Compiler

import IO;
import String;
import util::ValueUI;

import lang::dimitri::levels::l1::compiler::PropagateDefaults;

import lang::dimitri::levels::l2::compiler::Annotate;

import lang::dimitri::levels::l3::compiler::Normalize;

import lang::dimitri::levels::l4::AST;
import lang::dimitri::levels::l4::prettyPrinting::PrettyPrinting;
import lang::dimitri::levels::l4::compiler::PropagateConstants;
import lang::dimitri::levels::l4::compiler::validator::ADT;
import lang::dimitri::levels::l4::compiler::validator::Transform;
import lang::dimitri::levels::l4::compiler::validator::Generate;

public void compile(Format ast, str packageName) {
	ast = propagateDefaults(ast);
	ast = normalizeL3(ast);
	ast = propagateConstantsL4(ast);
	ast = annotate(ast);

	writeFile(|project://dimitri/formats/debug/<ast.name.val>.dim4|, prettyPrint(ast));

	validatorADT = getValidatorL2(ast);

	javaPathPrefix = "dimitri/src/<replaceAll(packageName, ".", "/")>/";

	writeFile(|project://<javaPathPrefix>/<toUpperCase(ast.name.val)>Validator.java|,
		generateL3(ast.sequence.symbols, ast.extensions[0].val, validatorADT, packageName));

}
module lang::dimitri::levels::l6::Compiler

import IO;
import String;
import util::ValueUI;

import lang::dimitri::levels::l1::compiler::PropagateDefaults;

import lang::dimitri::levels::l5::compiler::Annotate;

import lang::dimitri::levels::l4::compiler::validator::ADT;
import lang::dimitri::levels::l4::compiler::validator::Generate;
import lang::dimitri::levels::l6::AST;
import lang::dimitri::levels::l6::compiler::Normalize;
import lang::dimitri::levels::l6::prettyPrinting::PrettyPrinting;
import lang::dimitri::levels::l6::compiler::validator::Transform;
import lang::dimitri::levels::l6::compiler::PropagateConstants;

public void compile(Format ast, str packageName) {
	ast = propagateDefaults(ast);
	ast = normalizeL6(ast);
	ast = propagateConstantsL6(ast);
	ast = annotateL5(ast);

	writeFile(|project://dimitri/formats/debug/<ast.name.val>.dim6|, prettyPrint(ast));

	validatorADT = getValidatorL6(ast);

	javaPathPrefix = "dimitri/src/<replaceAll(packageName, ".", "/")>/";

	writeFile(|project://<javaPathPrefix>/<toUpperCase(ast.name.val)>Validator.java|,
		generateL4(ast.sequence.symbols, ast.extensions[0].val, validatorADT, packageName));

}
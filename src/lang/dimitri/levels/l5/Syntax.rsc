module lang::dimitri::levels::l5::Syntax
extend lang::dimitri::levels::l4::Syntax;

keyword DimitriKeywords = "offset" | "lengthOf";

syntax Scalar = lengthOf: "lengthOf" "(" Scalar exp ")"
			  | offset:	  "offset" "(" Scalar exp ")"
			  ;
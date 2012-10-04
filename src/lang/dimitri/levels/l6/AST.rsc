module lang::dimitri::levels::l6::AST
extend lang::dimitri::levels::l5::AST;

data FieldSpecifier = fieldTerminatedBy(list[Scalar] values, set[FormatSpecifier] format)
					| fieldTerminatedBefore(list[Scalar] values, set[FormatSpecifier] format)
					| fieldTerminatedBy(list[Scalar] values)
					| fieldTerminatedBefore(list[Scalar] values)
					;
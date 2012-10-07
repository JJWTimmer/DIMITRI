module lang::dimitri::levels::l6::AST
extend lang::dimitri::levels::l5::AST;

data FieldSpecifier = fieldTerminatedBy(list[Scalar] values, set[FormatSpecifier] format)
					| fieldTerminatedBefore(list[Scalar] values, set[FormatSpecifier] format)
					| fieldTerminatedBefore(Callback call, set[FormatSpecifier] format)
					| fieldTerminatedBy(Callback call, set[FormatSpecifier] format)
					;

anno TerminatorSpec Field@terminator;

data TerminatorSpec = by()
					| before()
					;
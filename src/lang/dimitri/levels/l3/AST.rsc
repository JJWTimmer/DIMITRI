module lang::dimitri::levels::l3::AST

extend lang::dimitri::levels::l2::AST;

data Field = field(Id name, Callback callback, set[FormatSpecifier] format);

data FieldSpecifier = fieldValue(Callback call)
					| fieldValue(Callback call, set[FormatSpecifier] format)
					;

data Callback = callback(FunctionName fname, set[Parameter] parameters);
data Parameter = parameter(Id name, set[Scalar] values);

data FunctionName = func(Id name);

anno loc Callback@location;
anno loc Parameter@location;
anno loc FunctionName@location;

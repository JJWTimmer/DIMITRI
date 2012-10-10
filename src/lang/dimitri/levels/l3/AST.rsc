module lang::dimitri::levels::l3::AST
extend lang::dimitri::levels::l2::AST;

data Field = field(Id name, Callback callback, set[FormatSpecifier] format);

data FieldSpecifier = fieldValue(Callback call)
					| fieldValue(Callback call, set[FormatSpecifier] format)
					;

data Callback = callback(FunctionName fname, set[Parameter] parameters);
data Parameter = pm(Id name, list[Argument] values);

data FunctionName = func(Id name);

data Argument = numberArg(int number)
			  | hexArg(str hex)
			  | octArg(str oct)
			  | binArg(str bin)
			  | stringArg(str string)
			  | refArg(Id field)
			  | crossRefArg(Id struct, Id field)
			  ;

anno loc Callback@location;
anno loc Parameter@location;
anno loc FunctionName@location;
anno loc Argument@location;

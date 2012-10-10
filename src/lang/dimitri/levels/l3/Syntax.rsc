module lang::dimitri::levels::l3::Syntax
extend lang::dimitri::levels::l2::Syntax;

syntax FieldSpecifier = fieldValue: Callback call FormatSpecifier* format;
                  
syntax Callback = callback: FunctionName name "(" {Parameter ","}* parameters ")";
syntax Parameter = pm: Id name "=" {Argument "+"}+ values;

syntax FunctionName = @category="Todo" func: Id name;

syntax Argument = numberArg: Integer number
              | @category="Constant" stringArg: "\"" String string "\""
              | refArg: ExpressionId name
              | crossRefArg: ExpressionId struct "." ExpressionId field
              | hexArg: Hexadecimal
              | octArg: Octal
              | binArg: Binary
              ;
module lang::dimitri::levels::l3::Syntax

extend lang::dimitri::levels::l2::Syntax;

syntax FieldSpecifier = fieldValue: Callback call FormatSpecifier* format;
                  
syntax Callback = callback: FunctionName name "(" {Parameter ","}* parameters ")";
syntax Parameter = parameter: Id name "=" {Scalar "+"}+ values;

syntax FunctionName = @category="Todo" func: Id name;
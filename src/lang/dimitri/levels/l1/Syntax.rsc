module lang::dimitri::levels::l1::Syntax

import String;

lexical CommentChar = ![*] | [*] !>> [/];
lexical Comment = @category="Comment" "/*" CommentChar* "*/";

lexical LAYOUT = whitespace: [\t-\n \r \ ] | Comment;
layout LAYOUTLIST = LAYOUT* !>> [\t-\n \r \ ];

keyword DerricKeywords =
   "format"
 | "extension"
 | "sequence"
 | "structures"
 | "unit" | "sign" | "endian" | "strings" | "type"
 | "big" | "little" | "true" | "false" | "byte" | "bit" | "ascii" | "utf8" | "integer" | "string";

lexical Id = id: ([a-z A-Z _] !<< [a-z A-Z _][a-z A-Z 0-9 _]* !>> [a-z A-Z 0-9 _]) \ DerricKeywords;
syntax ExpressionId = @category="Identifier" Id;
 
lexical Integer =  [0-9]+ !>> [0-9];
lexical Octal =  [0][oO][0-7]+ !>> [0-7];
lexical Hexadecimal =  [0][xX][a-f A-F 0-9]+ !>> [a-f A-F 0-9];
lexical Binary =  [0][bB][0-1]+ !>> [0-1];
lexical String =  ![\"]* ;


start syntax Format = @Foldable format: "format" Id name "extension" Id+ extensions Defaults defaults Sequence sequence Structures structures;

syntax Defaults = @Foldable FormatSpecifier*;

syntax FormatSpecifier = formatSpecifier: FormatSpecifierKeyword key FormatSpecifierValue val
					   | variableSpecifier: VariableSpecifierKeyword key Scalar var
					   ;

lexical FormatSpecifierKeyword = "unit"
							  | "sign"
							  | "endian"
							  | "strings"
							  | "type"
							  ;

lexical FormatSpecifierValue = "big"
							| "little"
                            | "true"
                            | "false"
                            | "byte"
                            | "bit"
                            | "ascii"
                            | "utf8"
                            | "integer"
                            | "string"
                            ;

lexical VariableSpecifierKeyword = "size";

syntax Sequence = @Foldable sequence: "sequence" SequenceSymbol* symbols;

syntax SequenceSymbol = choiceSeq: "(" SequenceSymbol+ symbols ")"
                      | fixedOrderSeq: "[" SequenceSymbol* order "]"
                      | right notSeq: "!" SequenceSymbol symbol
                      > zeroOrMoreSeq: SequenceSymbol symbol "*"
                      | optionalSeq: SequenceSymbol symbol "?"
                      | struct: Id name;

syntax Structures = @Foldable "structures" Structure*;

syntax Structure = @Foldable struct: Id name "{" Field* fields "}";

syntax Field = fieldRaw: Id name ":" FieldSpecifier value ";"
             | fieldNoValue: Id name ";";
             
syntax FieldSpecifier = fieldValue: ValueListSpecifier values FormatSpecifier* format
                      | fieldValue: FormatSpecifier+ format
                      ;
                      
syntax ValueListSpecifier = { Scalar "," }+;

syntax Scalar = number: Integer number
              | @category="Constant" string: "\"" String string "\""
              | ref: ExpressionId name
              | hex: Hexadecimal
              | oct: Octal
              | bin: Binary
              ;
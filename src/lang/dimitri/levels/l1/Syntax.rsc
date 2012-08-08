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
syntax ContentSpecifierId = @category="Todo" Id;
syntax ExpressionId = @category="Identifier" Id;
lexical Integer =  [0-9]+ !>> [0-9];
lexical Octal =  [0][oO][0-7]+ !>> [0-7];
lexical Hexadecimal =  [0][xX][a-f A-F 0-9]+ !>> [a-f A-F 0-9];
lexical Binary =  [0][bB][0-1]+ !>> [0-1];
lexical String =  ![\"]* ;


start syntax Format = @Foldable format: "format" Id name "extension" Id+ extensions Defaults defaults Sequence sequence Structures structures;

syntax Defaults = @Foldable FormatSpecifier*;

syntax FormatSpecifier = formatSpecifier: FixedFormatSpecifierKeyword key FixedFormatSpecifierValue val
					   | variableSpecifier: VariableFormatSpecifierKeyword varKey Expression var;

syntax FixedFormatSpecifierKeyword = unit: "unit"
								   | sign: "sign"
								   | endian: "endian"
								   | strings: "strings"
								   | \type: "type";
								   
syntax FixedFormatSpecifierValue = big: "big"
								 | little: "little"
                                 | \true: "true"
                                 | \false: "false"
                                 | byte: "byte"
                                 | bit: "bit"
                                 | ascii: "ascii"
                                 | utf8: "utf8"
                                 | integer: "integer"
                                 | float: "float"
                                 | string: "string"
                                 ;
                                 
syntax VariableFormatSpecifierKeyword = size: "size";

syntax Sequence = @Foldable sequence: "sequence" SequenceSymbol* symbols;

syntax SequenceSymbol = choiceSeq: "(" SequenceSymbol+ symbols ")"
                      | fixedOrderSeq: "[" SequenceSymbol* order "]"
                      | right notSeq: "!" SequenceSymbol symbol
                      > zeroOrMoreSeq: SequenceSymbol symbol "*"
                      | optionalSeq: SequenceSymbol symbol "?"
                      | struct: Id;

syntax Structures = @Foldable "structures" Structure*;

syntax Structure = @Foldable struct: Id name "{" Field* fields "}";

syntax Field = field: Id name ":" FieldSpecifier value ";"
             | fieldNoValue: Id name ";";
             
syntax FieldSpecifier = fieldValue: ValueListSpecifier values FormatSpecifier* format
                      | fieldValue: FormatSpecifier+ format
                      ;
                      
syntax ValueListSpecifier = { Expression "," }+;

syntax Expression = number: Integer number
                  | @category="Constant" string: "\"" String string "\""
                  | ref: ExpressionId name
                  | hex: Hexadecimal
                  | oct: Octal
                  | bin: Binary
                  ;
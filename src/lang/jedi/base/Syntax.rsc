module lang::jedi::base::Syntax

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
 | "big" | "little" | "true" | "false" | "byte" | "bit" | "ascii" | "utf8" | "integer" | "float" | "string";

lexical Id = ([a-z A-Z _] !<< [a-z A-Z _][a-z A-Z 0-9 _]* !>> [a-z A-Z 0-9 _]) \ DerricKeywords;
lexical ContentSpecifierId = @category="Todo" Id;
lexical ExpressionId = @category="Identifier" Id;
lexical Number = @category="Constant" hex: [0][xX][a-f A-F 0-9]+ !>> [a-f A-F 0-9]
              |  @category="Constant" bin: [0][bB][0-1]+ !>> [0-1]
              |  @category="Constant" oct: [0][oO][0-7]+ !>> [0-7]
              |  @category="Constant" dec: [0-9]+ !>> [0-9];
lexical String = @category="Constant" "\"" ![\"]*  "\"";


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
                                 | \byte: "byte"
                                 | bit: "bit"
                                 | ascii: "ascii"
                                 | utf8: "utf8"
                                 | \integer: "integer"
                                 | \float: "float"
                                 | \string: "string"
                                 ;
                                 
syntax VariableFormatSpecifierKeyword = size: "size";

syntax Sequence = @Foldable sequence: "sequence" SequenceSymbol* symbols;

syntax SequenceSymbol = choiceSeq: "(" SequenceSymbol+ symbols ")"
                      | fixedOrderSeq: "[" SequenceSymbol* symbols "]"
                      | right notSeq: "!" SequenceSymbol symbol
                      > zeroOrMoreSeq: SequenceSymbol symbol "*"
                      | optionalSeq: SequenceSymbol symbol "?"
                      | struct: Id;

syntax Structures = @Foldable "structures" Structure*;

syntax Structure = @Foldable struct: Id name "{" Field* fields "}";

syntax Field = field: Id name ":" FieldSpecifier value ";"
             | fieldNoValue: Id name ";"
             | rootField: Id name ":" "{" Field* spec "}";
             
syntax FieldSpecifier = fieldValue: ValueListSpecifier values FormatSpecifier* format
                      | fieldValue: FormatSpecifier+ format
                      ;
                      
syntax ValueListSpecifier = { Expression "," }+;

syntax Expression = number: Number number
                  | string: String string
                  | ref: ExpressionId name
                  ;
                  
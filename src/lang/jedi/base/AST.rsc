module lang::jedi::base::AST

data Format = format(str name, list[str] extensions, list[FormatSpecifier] defaults, Sequence sequence, list[Structure] structures);

data FormatSpecifier = formatSpecifier(FormatKeyword key, FormatValue val)
					 | variableSpecifier(VariableKeyword varKey, Scalar var)
					 ;

data FormatKeyword = unit()
				   | sign()
				   | endian()
				   | strings()
				   | \type()
				   ;

data FormatValue = big()
				 | little()
				 | \true()
				 | \false()
				 | \byte()
				 | bit()
				 | ascii()
				 | utf8()
				 | \integer()
				 | \float()
				 | \string()
				 ;

data VariableKeyword = size();

data Sequence  = sequence(list[SequenceSymbol] symbols);

data SequenceSymbol = struct(str name)
					| optionalSeq(SequenceSymbol symbol)
					| zeroOrMoreSeq(SequenceSymbol symbol)
					| notSeq(SequenceSymbol symbol)
					| fixedOrderSeq(list[SequenceSymbol] symbols)
					| choiceSeq(list[SequenceSymbol] symbols)
					;

data Structure = struct(str name, list[Field] fields);

data Field = fieldNoValue(str name)
		   | field(str name, FieldSpecifier \value)
		   | rootField(str name, list[Field] spec)
		   ;

data FieldSpecifier = fieldValue(list[Scalar] values, list[FormatSpecifier] format)
					| fieldValue(list[FormatSpecifier] format)
					;

data Scalar = number(str number)
			| string(str string)
			| ref(str name)
			;
			
anno loc Format@location;	
anno loc FormatSpecifier@location;	
anno loc FormatKeyword@location;	
anno loc FormatValue@location;	
anno loc Sequence@location;	
anno loc SequenceSymbol@location;	
anno loc Structure@location;	
anno loc Field@location;	
anno loc FieldSpecifier@location;	
anno loc Scalar@location;	
anno loc VariableKeyword@location;	
module lang::dimitri::levels::l1::AST

data Format = format(Id name, list[Id] extensions, set[FormatSpecifier] defaults, Sequence sequence, list[Structure] structures);

data FormatSpecifier = formatSpecifier(str key, str val)
					 | variableSpecifier(str key, Scalar var)
					 ;

data Sequence  = sequence(list[SequenceSymbol] symbols);

data SequenceSymbol = struct(Id name)
					| optionalSeq(SequenceSymbol symbol)
					| zeroOrMoreSeq(SequenceSymbol symbol)
					| notSeq(SequenceSymbol symbol)
					| fixedOrderSeq(list[SequenceSymbol] order)
					| choiceSeq(set[SequenceSymbol] symbols)
					;

data Structure = struct(Id name, list[Field] fields);

data Field = fieldNoValue(Id name)
		   | fieldRaw(Id name, FieldSpecifier \value)
		   | field(Id name, list[Scalar] values, set[FormatSpecifier] format)
		   ;

data FieldSpecifier = fieldValue(list[Scalar] values, set[FormatSpecifier] format)
					| fieldValue(set[FormatSpecifier] format)
					;

data Scalar = number(int number)
			| hex(str hex)
			| oct(str oct)
			| bin(str bin)
			| string(str string)
			| ref(Id field)
			;

data Id = id(str val);

anno loc Id@location;			
anno loc Format@location;	
anno loc FormatSpecifier@location;	
anno loc Sequence@location;	
anno loc SequenceSymbol@location;	
anno loc Structure@location;	
anno loc Field@location;	
anno loc FieldSpecifier@location;	
anno loc Scalar@location;	

anno bool FormatSpecifier@local;

anno str Field@parent;
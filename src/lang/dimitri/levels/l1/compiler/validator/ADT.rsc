module lang::dimitri::levels::l1::compiler::validator::ADT

data Validator = validator(str name, str format, list[Structure] structs);

data Structure = structure(str name, list[Statement] statements);

data Statement = ldeclV(Type \type, str name)
			   | ldeclB(str name)
			   | calc(str varName, VValue exp)
			   | readValue(Type \type, str varName)
			   | readBuffer(str sizeVar, str varName)
			   | readUntil(Type \type, list[VValue] expOptions, bool includeMarker)
			   | skipValue(Type \type)
			   | skipBuffer(str sizeVar)
			   | validate(str varName, list[VValue] expOptions)
			   ;

data VValue = var(str name)
			| con(int intValue)
			| bits(VValue exp)
			| bytes(VValue exp)
			;

data Type = integer(bool sign, Endianness endian, int bits);

data Endianness = littleE()
				| bigE()
				;

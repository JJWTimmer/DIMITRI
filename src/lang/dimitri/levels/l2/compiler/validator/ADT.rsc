module lang::dimitri::levels::l2::compiler::validator::ADT

extend lang::dimitri::levels::l1::compiler::validator::ADT;

data Validator = validator(str name, str format, list[Global] globals, list[Structure] structs);

data Global = gdeclV(Type \type, str name)
			| gdeclB(str name);
  
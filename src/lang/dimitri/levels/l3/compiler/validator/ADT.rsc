module lang::dimitri::levels::l3::compiler::validator::ADT

extend lang::dimitri::levels::l2::compiler::validator::ADT;

data Statement = validateContent(str varName, str lenName, str method, map[str, str] custom, map[str, list[VValue]] references, bool allowEOF);
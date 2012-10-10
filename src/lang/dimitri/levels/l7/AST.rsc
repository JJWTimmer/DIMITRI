module lang::dimitri::levels::l7::AST
extend lang::dimitri::levels::l6::AST;

data Structure = struct(Id name, Id parent, list[Field] fields);

data Field = fieldOverride(Id name, list[Field] overrides);
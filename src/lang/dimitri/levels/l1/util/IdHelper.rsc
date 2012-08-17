module lang::dimitri::levels::l1::util::IdHelper

import lang::dimitri::levels::l1::AST;

public str unId(id(name)) = name;

public list[str] unId(list[Id] lst) = [name | id(name) <- lst];
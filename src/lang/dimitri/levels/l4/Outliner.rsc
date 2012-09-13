module lang::dimitri::levels::l4::Outliner

extend lang::dimitri::levels::l3::Outliner;

import lang::dimitri::levels::l4::Implode;
import lang::dimitri::levels::l4::AST;

public node outlineL4(Tree tree) = outline(lang::dimitri::levels::l4::Implode::implode(tree));
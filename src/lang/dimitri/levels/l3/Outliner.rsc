module lang::dimitri::levels::l3::Outliner

extend lang::dimitri::levels::l2::Outliner;

import lang::dimitri::levels::l3::Implode;
import lang::dimitri::levels::l3::AST;

public node outlineL3(Tree tree) = outline(lang::dimitri::levels::l3::Implode::implode(tree));
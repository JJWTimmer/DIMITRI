module lang::dimitri::levels::l2::Outliner
extend lang::dimitri::levels::l1::Outliner;

import lang::dimitri::levels::l2::Implode;
import lang::dimitri::levels::l2::AST;

public node outlineL2(Tree tree) = outline(lang::dimitri::levels::l2::Implode::implode(tree));
module lang::dimitri::levels::l3::ide::Outliner
extend lang::dimitri::levels::l2::ide::Outliner;

import lang::dimitri::levels::l3::Implode;
import lang::dimitri::levels::l3::AST;

public node outlineL3(Tree tree) = outline(lang::dimitri::levels::l3::Implode::implode(tree));
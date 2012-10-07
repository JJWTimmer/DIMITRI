module lang::dimitri::levels::l5::ide::Outliner
extend lang::dimitri::levels::l4::ide::Outliner;

import lang::dimitri::levels::l5::Implode;
import lang::dimitri::levels::l5::AST;

public node outlineL5(Tree tree) = outline(lang::dimitri::levels::l5::Implode::implode(tree));
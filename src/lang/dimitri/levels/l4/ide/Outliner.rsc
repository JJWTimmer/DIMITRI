module lang::dimitri::levels::l4::ide::Outliner
extend lang::dimitri::levels::l3::ide::Outliner;

import lang::dimitri::levels::l4::Implode;
import lang::dimitri::levels::l4::AST;

public node outlineL4(Tree tree) = outline(lang::dimitri::levels::l4::Implode::implode(tree));
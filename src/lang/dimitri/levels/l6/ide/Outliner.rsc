module lang::dimitri::levels::l6::ide::Outliner
extend lang::dimitri::levels::l5::ide::Outliner;

import lang::dimitri::levels::l6::Implode;
import lang::dimitri::levels::l6::AST;

public node outlineL6(Tree tree) = outline(lang::dimitri::levels::l6::Implode::implode(tree));
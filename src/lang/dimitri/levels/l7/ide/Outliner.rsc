module lang::dimitri::levels::l7::ide::Outliner
extend lang::dimitri::levels::l6::ide::Outliner;

import lang::dimitri::levels::l7::Implode;
import lang::dimitri::levels::l7::AST;

public node outlineL7(Tree tree) = outline(lang::dimitri::levels::l7::Implode::implode(tree));
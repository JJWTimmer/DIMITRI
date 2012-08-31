module lang::dimitri::levels::l2::Outliner

extend lang::dimitri::levels::l1::Outliner;

import lang::dimitri::levels::l2::Implode;
import lang::dimitri::levels::l2::AST;
import lang::dimitri::levels::l2::compiler::Debug;

public node outlineL2(Tree tree) = outline(lang::dimitri::levels::l2::Implode::implode(tree));
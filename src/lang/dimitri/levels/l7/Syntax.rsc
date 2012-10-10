module lang::dimitri::levels::l7::Syntax
extend lang::dimitri::levels::l6::Syntax;

syntax Structure = @Foldable struct: Id name "=" Id parent "{" Field* fields "}";

syntax Field = fieldOverride: Id name ":" "{" Field* overrides "}";
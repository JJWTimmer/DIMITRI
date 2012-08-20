module lang::dimitri::Level2

import ParseTree;
import util::IDE;

import lang::dimitri::levels::l2::Parse;
import lang::dimitri::levels::l2::Implode;
import lang::dimitri::levels::l2::AST;

import lang::dimitri::levels::l1::Check;
import lang::dimitri::levels::l2::Check;

public str LANG = "Dimitri L2";
public str EXT  = "dim2";

public void registerL2() {
	registerLanguage(LANG, EXT, parseL2);
	registerAnnotator(LANG, checkL2);
}

public Tree parseL2(str input, loc org) = parse(input, org);

public Tree parseL2(loc org) = parse(org);

public Format implodeL2(Tree t) = implode(t);

public Tree checkL2(Tree t) = t[@messages=lang::dimitri::levels::l2::Check::check(ast)] when ast := implode(t);
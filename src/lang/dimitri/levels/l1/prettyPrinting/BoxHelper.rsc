module lang::dimitri::levels::l1::prettyPrinting::BoxHelper

import lang::box::util::Box;
import List;
import Set;
import lang::dimitri::levels::l1::AST;


public list[Box] hsepList(list[&T] elts, str sep, Box(&T) tobox) {
	if (elts == [])  
		return [];
	result = [];
	Box lst = tobox(head(elts));
	for (e <- tail(elts)) {
		result += [H([lst, L(sep)])[@hs=0]];
		lst = tobox(e);
  	}
  	return result + [lst];
}

public list[Box] hsepList(set[&T] elts, str sep, Box(&T) tobox)
	 = hsepList(toList(elts), sep, tobox);
	 
public list[Box] list2boxlist(list[&T] elts, Box(&T) tobox) {
	return [tobox(x) | x <- elts];
}

public list[Box] set2boxlist(set[&T] elts, Box(&T) tobox)
	 = list2boxlist(toList(elts), tobox);
	 
public Box indentBox(Box b) = I(b)[@ts=1];
module lang::jedi::Bootstrap

import util::Resources;
import util::Reflective;
import util::IDE;
import IO;
import Set;
import List;
import String;
import Exception;
import ParseTree;

/*
	Should find highest extension level
	For every component, load highest available version
*/
public void loadJedi() {
	
	resJedi = getProject(|project://JEDI|);
	
	set[Resource] extensionSet = {};
	
	top-down-break visit (resJedi) {
		case folder(name, sub) : {
			if (name == |project://JEDI/src/lang/jedi/extensions|) {
				extensionSet = sub;
			} else fail;
		}
	}
	
	extensionList = toList(extensionSet);
	
	extensionList = sort(extensionList, sortExtensions);
	
	Resource lastLvl = last(extensionList);
	
	int maxLvl = loc2lvl(lastLvl.id);
	
	createMenu([maxLvl]);
}


/*
	Same as above, only load until level x
*/
public void loadJedi(str lvl) {

}

//translate a loc to a extension level

private int loc2lvl(loc level) {
	str extNameError = "Incorrect named extension directory. Should be ./e#/ where # is an int.";

	int lastSlash = findLast(level.path, "/");
	int lastE = findLast(level.path, "e");
	
	if (lastE < lastSlash) throw extNameError;
	int lvl = -1;
	
	try {
		lvl = toInt(substring(level.path, lastE+1));
	} catch IllegalArgument() : throw extNameError;
	
	
	return lvl;
}

public void createMenu(list[int] lvls) {
	set[Contribution] contributions = {}; 
	for (int lvl <- lvls) {
		contributions += popup(
			menu("JEDI Loader", [
				action("Load e<lvl>", 
					(Tree tree, loc selection) { lvlLoader(lvl); })
			])
		);
	}
	
	registerNonRascalContributions("org.eclipse.ui.DefaultTextEditor", contributions);
}

private void lvlLoader(int lvl) {
	println("Fake loading level <lvl>");
}

//sort function for extensions

private bool sortExtensions(folder(name1, _), folder(name2, _)) {
	return name1.path < name2.path;
}
private bool sortExtensions(file(_), folder(_, _)) {
	return false;
}
private bool sortExtensions(folder(_, _), file(_)) {
	return true;
}
private bool sortExtensions(file(name1), file(name2)) {
	return name1.path < name2.path;
}
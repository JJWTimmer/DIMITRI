module lang::dimitri::bootstrap::Bootstrap

import util::Resources;
import util::Reflective;
import util::IDE;
import IO;
import Set;
import List;
import String;
import Exception;
import ParseTree;

import lang::dimitri::bootstrap::Order;
import lang::dimitri::Host;

/*
	Should find highest extension level
	For every component, load highest available version
*/
public void loadDimitri() {
	
	resDimitri = getProject(|project://DIMITRI|);
	
	set[Resource] extensionSet = {};
	
	top-down-break visit (resDimitri) {
		case folder(name, sub) : {
			if (name == |project://DIMITRI/src/lang/dimitri/extensions|) {
				extensionSet = sub;
			} else fail;
		}
	}
	
	extensionList = toList(extensionSet);
	
	extensionList = sort(extensionList, sortExtensions);
	
	Resource lastLvl = last(extensionList);
	
	int maxLvl = loc2lvl(lastLvl.id);
	
	list[int] lvls = [loc2lvl(id) | extension <- extensionList, folder(id, _) := extension];
	
	createMenu(lvls);
}


/*
	Same as above, only load until level x
*/
public void loadDimitri(int lvl) {

}

/*
	translate a loc to an extension level
*/
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
	set[Contribution] rascalContributions = {};
	set[Contribution] nonRascalContributions = {};
	
	list[Menu] menuItems = [];
	
	for (int lvl <- lvls) {
		Menu menuItem = action(
						"Load e<lvl>", 
						(Tree tree, loc selection) { int myLvl = lvl; lvlLoader(myLvl); }
					);
		menuItems += menuItem;		
		nonRascalContributions += menu(menuItem);
	}
	
	
	rascalContributions += popup(menu("Dimitri Loader", menuItems));
	
	//registerNonRascalContributions("org.eclipse.ui.DefaultTextEditor", nonRascalContributions);
	//registerNonRascalContributions("org.rascalmpl.eclipse.editor.RascalEditor", nonRascalContributions);
	//registerNonRascalContributions("org.eclipse.imp.editor.UniversalEditor", nonRascalContributions);
	//registerNonRascalContributions("rascal.editor", nonRascalContributions);
	//registerNonRascalContributions("Rascal", nonRascalContributions);
	//registerNonRascalContributions("RascalRascal", nonRascalContributions);
	//registerNonRascalContributions("rascal", nonRascalContributions);
	//
	//registerContributions("org.eclipse.ui.DefaultTextEditor", rascalContributions);
	//registerContributions("org.rascalmpl.eclipse.editor.RascalEditor", rascalContributions);
	//registerContributions("org.eclipse.imp.editor.UniversalEditor", rascalContributions);
	//registerContributions("rascal.editor", rascalContributions);
	//registerContributions("Rascal", rascalContributions);
	//registerContributions("RascalRascal", rascalContributions);
	//registerContributions("rascal", rascalContributions);
	registerContributions(HOST_LANG, rascalContributions);
}

/*
	menu item load handler
*/
public void lvlLoader(int lvl) {
	println("Fake loading level <lvl>");
	loadDimitri(lvl);
}
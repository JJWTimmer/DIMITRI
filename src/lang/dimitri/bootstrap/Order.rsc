module lang::dimitri::bootstrap::Order

import util::Resources;
import String;

/*
	determine order of extensions
	currently: simple alphabetical sort, 
*/

public bool sortExtensions(folder(name1, _), folder(name2, _)) {
	return name1.path < name2.path;
}
public bool sortExtensions(file(_), folder(_, _)) {
	return false;
}
public bool sortExtensions(folder(_, _), file(_)) {
	return true;
}
public bool sortExtensions(file(name1), file(name2)) {
	return name1.path < name2.path;
}
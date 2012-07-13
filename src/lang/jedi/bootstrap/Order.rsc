module lang::jedi::bootstrap::Order

/*
	determine order of extensions
	currently: simple alphabetical sort, 
*/

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
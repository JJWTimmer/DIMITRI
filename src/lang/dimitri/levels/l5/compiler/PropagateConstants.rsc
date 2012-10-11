module lang::dimitri::levels::l5::compiler::PropagateConstants
extend lang::dimitri::levels::l4::compiler::PropagateConstants;

import lang::dimitri::levels::l5::AST;
import Node;

anno Id Id@field;
anno bool Id@format;

public Format propagateConstantsL5(Format format) {
	return solve(format) {
		specMap = {<s, f.name, f> | struct(s,fs) <- format.structures, Field f <- fs};
		format = visit (format) {
			case struct(sname, fields) => propagateConstantsL5(sname, fields, specMap)
			case Scalar s => fold(s)
		}
	}
}

public Structure propagateConstantsL5(Id sname, list[Field] fields, rel[Id s, Id f, Field v] smap) =
	struct(sname, newFields)
	when newFields := visit (fields) {
		//typing of values because of Callback-fields
		case field(fname, list[Scalar] values, format) => 
			field(fname, getValsL5(sname[@field=fname], values, smap), getValsL5(sname[@field=fname][@format=true], format, smap))
	};

public bool allowedInSize(offset(_)) = true;
public bool allowedInSize(lengthOf(_)) = true;

public list[Scalar] getValsL5(Id sname, list[Scalar] originalValues, rel[Id, Id, Field] specMap) =
	top-down-break visit(originalValues) {
		case [Scalar s] => [getValsL5(sname, s, specMap)]
	};

public set[FormatSpecifier] getValsL5(Id sname, set[FormatSpecifier] format, rel[Id, Id, Field] specMap) =
	top-down-break visit(format) {
		case v:variableSpecifier(k, s) => setAnnotations(variableSpecifier(k, getValsL5(sname, s[@inFormat=true], specMap)), getAnnotations(v))
	};

public Scalar getValsL5(Id sname, Scalar s, rel[Id, Id, Field] specMap) {
	bool interesting = false;
	visit(s) {
		case lengthOf(crossRef(_, _)) : interesting = true;
		case lengthOf(ref(_)) : interesting = true;
		case ref(_) : interesting = true;
		case crossRef(_, _) : interesting = true;
	}
	if (interesting)
		return getValsL5L5(sname, s, specMap);
	else
		return getVals(sname, s, specMap)[0];
}

public Scalar getValsL5L5(Id sname, Scalar s, rel[Id, Id, Field] specMap) {
	s = top-down-break visit (s) {
		case l:lengthOf(crossRef(struct, source)) : {
			Field f;
			bool breaking = false;
			if( {theField} := specMap[struct, source] )
				f = theField;
			else
				throw "lengthOf unknown field: <struct.val>.<source.val>";
			
			Scalar size = number(0);
			if (/variableSpecifier("size", sz) := f.format)
				size = sz;
			
			if (sname != struct, ref(_) := size)
				size = crossRef(struct, size.field);
			else if(crossRef(_,_) !:= size)
				size = getValsL5(sname, size, specMap);
			
			//if we are a lengthOf for a normal value, and the target size is a ref to us, return the original value
			if( (!sname@format? || (sname@format? && !sname@format)), sname@field?) {
				fld = sname@field;//bugfix, inserting with annotation below doesn't work
				if((sname == struct) && (ref(fld) := size) || (crossRef(sname, fld) := size))
					breaking = true;
			}
				
			if (!breaking) insert size;
			else insert l;
		}
		case l:lengthOf(ref(source)) : {
			Field f;
			breaking = false;
			if( {theField} := specMap[sname, source] )
				f = theField;
			else
				throw "lengthOf unknown field: <sname.val>.<source.val>";
			
			Scalar size = number(0);
			if (/variableSpecifier("size", sz) := f.format)
				size = sz;
			
			if(crossRef(_,_) !:= size, ref(_) !:= size)
				size = getVals(sname, size, specMap)[0];
			
			//if we are a lengthOf for a normal value, and the target size is a ref to us, return the original value
			if( (!sname@format? || (sname@format? && !sname@format)), sname@field?) {
				fld = sname@field;
				if(ref(fld) := size || crossRef(sname, fld) := size)
					breaking = true;
			}
			
			if (!breaking) insert size;
			else insert l;
		}
		case cr:crossRef(struct, source) : {
			list[Scalar] res;
			breaking = false;
			if ({f} := specMap[struct, source], f has values)
				res = f.values;
			else
				breaking = true;
			
			
			if ([ref(nextRef)] := res)
				res = [crossRef(struct, nextRef)];
			else if([crossRef(_,_)] !:= res, size(res) > 0)
				res = [getValsL5(sname, res[0], specMap)];
		
			//if we are a ref in a size value, and the target is a lengthOf us, return original value 
			if(sname@format?, sname@format, sname@field?) {
				fld = sname@field;
				if ((sname == struct && [lengthOf(ref(fld))] := res) || [lengthOf(crossRef(sname, fld))] := res) {
					breaking = true;
				}
			}
						
			if (size(res) > 0, !(!s@inFormat? || (s@inFormat? && allowedInSize(res[0]))))
				breaking = true;
			
			if (!breaking, size(res) > 0)
				insert res[0];
			else
				insert cr;
		}
		case r:ref(source) : {
			Field theField;
			breaking = false;
			if ({f} := specMap[sname, source], f has values)
				theField = f;
			else
				breaking = true;
		
			if(!breaking, [crossRef(_,_)] !:= theField.values, [ref(_)] !:= theField.values, [] != theField.values)
				theField.values = getVals(sname, theField.values[0], specMap);
		
			//if we are a ref in a size value, and the target is a lengthOf us, return original value 
			if(!breaking, sname@format?, sname@format, sname@field?) {
				fld = sname@field;
				if ([lengthOf(ref(fld))] := theField.values || [lengthOf(crossRef(sname, fld))] := theField.values) {
					breaking = true;
				}
			}			
						
			if (!breaking, size(theField.values) > 0, !(!s@inFormat? || (s@inFormat? && allowedInSize(theField.values[0]))))
				breaking = true;
			
			if (!breaking, size(theField.values) > 0 )
				insert theField.values[0];
			else
				insert r;
		} 
	}
	return s;
}

public Scalar  fold( l:lengthOf(ref(_))) = l;
public Scalar  fold( l:lengthOf(crossRef(_, _))) = l;
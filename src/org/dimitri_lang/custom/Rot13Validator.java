/* Copyright 2011-2012 Netherlands Forensic Institute and
                       Centrum Wiskunde & Informatica

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
 */

package org.dimitri_lang.custom;

import org.dimitri_lang.runtime.level1.*;
import org.dimitri_lang.runtime.level3.*;
import org.dimitri_lang.runtime.level3.ValidatorInputStream;
import org.rascalmpl.interpreter.staticErrors.RedeclaredTypeError;

import java.io.IOException;
import java.util.List;
import java.util.Map;

public class Rot13Validator {

	public static Content validateContent(ValidatorInputStream in, long size,
			String name, Map<String, String> configuration,
			Map<String, List<Object>> arguments, boolean allowEOF)
			throws IOException {
		if (arguments.containsKey("data")) {
			List<Object> data = arguments.get("data");
			Content content;
			switch (name) {
			case "rot13":
				content = analyzeRot13(in, data);
				break;
			default:
				throw new RuntimeException("unknown algorithm: " + name);
			}

			return new Content(content.validated, content.data);
		} else {
			throw new RuntimeException(
					"ROT13 did not get the data argument to compare to.");
		}
	}

	private static Content analyzeRot13(ValidatorInputStream in, List<Object> data) {
		byte[] bytes = new byte[data.size()];
		boolean valid = true;
		int counter = 0;
		for (Object c : data) {
			ValueSet rot13vs = new ValueSet();
			int rot13char = (int) rot13((char) ((Long) c).intValue());
			rot13vs.addEquals( rot13char);
			Content charContent;
			try {
				charContent = in.readUntil(8, rot13vs);
				if (!charContent.validated) {
					valid = false;
					bytes[counter] = charContent.data[0];
				} else {
					bytes[counter] = (byte) rot13char;
				}
			} catch (IOException e) {
				valid = false;
				break;
			}
			
			counter++;
		}
		
		return new Content(valid, bytes);
	}

	private static char rot13(char c) {
		if (c >= 'a' && c <= 'm')
			c += 13;
		else if (c >= 'A' && c <= 'M')
			c += 13;
		else if (c >= 'n' && c <= 'z')
			c -= 13;
		else if (c >= 'N' && c <= 'Z')
			c -= 13;
		return c;
	}
}

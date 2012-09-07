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

import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

import org.dimitri_lang.runtime.level1.Content;
import org.dimitri_lang.runtime.level1.ValueSet;
import org.dimitri_lang.runtime.level3.SubStream;
import org.dimitri_lang.runtime.level3.ValidatorInputStream;

public class Rot13Validator {

	public static Content validateContent(ValidatorInputStream in, long size,
			String name, Map<String, String> configuration,
			Map<String, List<Object>> arguments, boolean allowEOF)
			throws IOException {
		if (arguments.containsKey("data") && configuration.containsKey("alg")) {
			List<Object> data = arguments.get("data");
			Content content;
			switch (configuration.get("alg")) {
			case "known":
				content = analyzeRot13known(in, data);
				break;
			case "unknown":
				content = analyzeRot13unknown(in, data);
				break;
			default:
				throw new RuntimeException("unknown algorithm: " + name);
			}

			return new Content(content.validated, content.data);
		} else {
			throw new RuntimeException(
					"ROT13 did not get the data argument or the alg-string.");
		}
	}
	
	private static Content analyzeRot13known(ValidatorInputStream in, List<Object> data) {
		byte[] orig = new byte[data.size()];
		
		for (int i = 0; i < data.size(); i++) {
			orig[i] = ((Long)data.get(i)).byteValue();
		}
		
		byte[] bytes = new byte[data.size()];
		try {
			in.read(bytes);
		} catch (IOException e1) {
			return new Content(false, null);
		}
		
		byte[] encoded = new byte[bytes.length];
		for (int i = 0; i < bytes.length; i++) {
			char c = (char)bytes[i];
			encoded[i] = (byte)rot13(c);
		}
		
		if (Arrays.equals(encoded, orig))
			return new Content(true, bytes);
		
		
		return new Content(false, bytes);
	}
	
	private static Content analyzeRot13unknown(ValidatorInputStream in, List<Object> data) {	
		SubStream ss = (SubStream) data.get(data.size() - 1);

		byte[] orig = ss.getLast();
		int olen = orig.length;
		
		byte[] bytesIn = new byte[olen];
		try {
			in.read(bytesIn);
		} catch (IOException e) {
			return new Content(false, bytesIn);
		}
		
		byte[] decoded = new byte[olen];
		for (int i = 0; i < olen; i++) {
			char c = (char)orig[i];
			decoded[i] = (byte)rot13(c);
		}
		
		if (Arrays.equals(decoded, bytesIn))
			return new Content(true, bytesIn);
		
		
		return new Content(false, bytesIn);
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

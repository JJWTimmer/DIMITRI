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

package org.dimitri_lang.runtime.level1;

public enum ByteOrder {
	BIG_ENDIAN {
		public void apply(byte[] b) {
		}
	},
	LITTLE_ENDIAN {
		public void apply(byte[] b) {
			for (int i = 0; i < b.length / 2; i++) {
				byte tmp = b[i];
				b[i] = b[(b.length - 1) - i];
				b[(b.length - 1) - i] = tmp;
			}
		}
	};

	public abstract void apply(byte[] b);
}
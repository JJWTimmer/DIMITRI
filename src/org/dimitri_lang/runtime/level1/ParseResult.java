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

public class ParseResult {
	
	private boolean _result;
	private long _lastLocation;
	private long _lastRead;
	private String _symbol;
	private String _sequence;

	public boolean isSuccess() {
		return _result;
	}

	public long getLastLocation() {
		return _lastLocation;
	}
	
	public long getLastRead() {
		return _lastRead;
	}

	public String getSymbol() {
	  return _symbol;
	}
	
	public String getSequence() {
	  return _sequence;
	}

	public ParseResult(boolean result, long lastLocation, long lastRead, String symbol, String sequence) {
		_result = result;
		_lastLocation = lastLocation;
		_lastRead = lastRead;
		_symbol = symbol;
		_sequence = sequence;
	}
	
	@Override
	public String toString() {
		return "(result:" + _result + ", lastLocation:" + _lastLocation + ", lastRead:" + _lastRead + ", symbol: " + _symbol + ", sequence: " + _sequence + ")";
	}

}

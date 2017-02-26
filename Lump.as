// Lump.as:  A WAD lump directory entry.

package 
{
import flash.utils.ByteArray;

public class Lump {

	// Variables
	public var offset:int;
	public var len:int;
	public var name:String;

	public static var lastSearchIdx:int = -1;
	public static var tempOffsetFix:int = 0; // TEMP FIX

	// Constructor
	public function Lump(lOff:int, lLen:int, lName:String) {
		offset = lOff;
		len = lLen;
		name = lName;
	}

	// Fetch string representation of lump (no special characters)
	public function getLumpStr(file:ByteArray):String {
		file.position = offset + tempOffsetFix;
		return (file.readUTFBytes(len));
	}

	// Fetch string representation of lump (special characters)
	public function getLumpExtendedASCIIStr(file:ByteArray):String {
		file.position = offset + tempOffsetFix;
		var s:String = "";
		var i:int = len;
		while (i--)
			s += String.fromCharCode(file.readUnsignedByte());

		return s;
	}

	// Fetch binary representation of lump
	public function getLumpBytes(file:ByteArray):ByteArray {
		file.position = offset + tempOffsetFix;
		var ba:ByteArray = new ByteArray();
		file.readBytes(ba, 0, len);
		return ba;
	}

	// Search for specific lump
	public static function search(srcList:Vector.<Lump>, searchName:String, startIdx:int=-1):Lump {
		// If start index is -1, search beyond the last found lump.
		if (startIdx == -1)
			startIdx = lastSearchIdx + 1;

		for (var i:int = startIdx; i < srcList.length; i++)
		{
			if (srcList[i].name == searchName)
			{
				// Found.
				lastSearchIdx = i;
				return (srcList[i]);
			}
		}

		// Not found; reset last found lump.
		lastSearchIdx = -1;
		return null;
	}

	// Reset search
	public static function resetSearch():void {
		lastSearchIdx = -1;
	}

	// Search for embedded files; return list of names
	public static function getEmbeddedFileNames(srcList:Vector.<Lump>, file:ByteArray):Array {
		var fNameArray:Array = new Array(0);
		for (var i:int = 0; i < srcList.length; i++)
		{
			if (srcList[i].name == "FILE    ")
			{
				// File.  Get filename, which is an ASCIIZ string.
				var fileLen:int = 256;
				if (srcList[i].len < fileLen)
					fileLen = srcList[i].len;
				file.position = srcList[i].offset;
				var s:String = file.readUTFBytes(fileLen);

				// Establish filename as first part of lump data.
				var nullTerm:int = s.indexOf("\x00");
				if (nullTerm != -1)
					s = s.substr(0, nullTerm);

				fNameArray.push(s);
			}
		}

		// Return list of filenames.
		return fNameArray;
	}

	// Retrieve embedded file contents
	public static function getEmbeddedFile(srcList:Vector.<Lump>, file:ByteArray,
		fileName:String):ByteArray {

		for (var i:int = 0; i < srcList.length; i++)
		{
			if (srcList[i].name == "FILE    ")
			{
				// File.  Get filename, which is an ASCIIZ string.
				var fileLen:int = 256;
				if (srcList[i].len < fileLen)
					fileLen = srcList[i].len;
				file.position = srcList[i].offset;
				var s:String = file.readUTFBytes(fileLen);

				// Establish filename as first part of lump data.
				var nullTerm:int = s.indexOf("\x00");
				if (nullTerm != -1)
					s = s.substr(0, nullTerm);
				else
					nullTerm = 255;

				if (s.toUpperCase() == fileName.toUpperCase())
				{
					// Found.  Extract portion of binary contents after filename.
					file.position = srcList[i].offset + nullTerm + 1;
					var ba:ByteArray = new ByteArray();
					file.readBytes(ba, 0, srcList[i].len - (nullTerm + 1));
					return ba;
				}
			}
		}

		// Should not get here in theory; should only try to retrieve
		// a file that had been found using getEmbeddedFileNames.
		return null;
	}

};
};

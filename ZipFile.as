// ZipFile.as:  An object representing an unpacked ZIP file archive.

package {
public class ZipFile {

import flash.utils.ByteArray;
import flash.utils.Endian;

public var zipHeader:int; // 4 bytes
public var reqVersion:int // 2 bytes
public var bitFlag:int; // 2 bytes
public var compression:int; // 2 bytes; assumed == 8 (DEFLATE)
public var lastModTime:int; // 2 bytes
public var lastModDate:int; // 2 bytes
public var crc32:int; // 4 bytes
public var compSize:int; // 4 bytes
public var unCompSize:int; // 4 bytes
public var fileNameLength:int; // 2 bytes
public var extraFieldLength:int; // 2 bytes
public var fileName:String;
public var extraField:ByteArray;

public var b:ByteArray;
public var hasError:Boolean;
public var numFiles:int;
public var fileNames:Array;
public var fileOffsets:Array;
public var fileSizes:Array;
public var fileComps:Array;
public var fileContents:Array;

public function ZipFile(srcBytes:ByteArray) {
	b = srcBytes;
	b.endian = Endian.LITTLE_ENDIAN;
	b.position = 0;

	numFiles = 0;
	fileNames = [];
	fileOffsets = [];
	fileSizes = [];
	fileContents = [];
	fileComps = [];
	hasError = false;

	var offset:int = 0;
	while (b.position < b.length) {
		if (b.readInt() != 0x04034b50)
			break; // Not PK34 identifier

		// Get critical position and length info
		b.position = offset + 8;
		compression = b.readShort();
		b.position = offset + 26;
		fileNameLength = b.readShort();
		extraFieldLength = b.readShort();
		var fileOffset:int = offset + 30 + fileNameLength + extraFieldLength;

		// Store relevant info for file
		b.position = offset + 30;
		fileNames.push(b.readUTFBytes(fileNameLength));
		b.position = offset + 18;
		compSize = b.readInt();
		unCompSize = b.readInt();
		fileSizes.push(compSize);
		fileOffsets.push(fileOffset);
		fileComps.push(compression);

		// Go beyond file to start of next file
		offset = fileOffset + compSize;
		b.position = offset;
		numFiles++;
	}

	// Unpack and store all files
	for (var i:int = 0; i < numFiles; i++) {
		var newB:ByteArray = new ByteArray();
		b.position = fileOffsets[i];

		if (fileComps[i] == 0)
		{
			// STORED
			b.readBytes(newB, 0, fileSizes[i]);
		}
		else if (fileComps[i] == 8)
		{
			// DEFLATE
			b.readBytes(newB, 0, fileSizes[i]);
			newB.inflate();
		}
		else
		{
			// Unsupported compression algorithm; leave empty
			hasError = true;
		}

		fileContents.push(newB);
	}
}

// Return file matching name exactly.  Not case sensitive.
public function getFileByName(fName:String):ByteArray {
	var s:String = fName.toUpperCase();

	for (var i:int = 0; i < numFiles; i++) {
		if (fileNames[i].toUpperCase() == s)
			return fileContents[i]; // Match
	}

	// No match
	return null;
}

// Return filenames matching extension.  Not case sensitive.
public function getFileNamesMatchingExt(fExt:String):Array {
	var sLen:int = fExt.length;
	var nArray:Array = [];

	for (var i:int = 0; i < numFiles; i++) {
		if (fileNames[i].length >= sLen)
		{
			if (utils.endswith(fileNames[i], fExt))
				nArray.push(fileNames[i]);
		}
	}

	// Return matches
	return nArray;
}

};
};

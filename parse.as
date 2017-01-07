//parse.as:  The program's file read/write and JSON parsing/conversion functions.

package {
public class parse {

import flash.geom.*;
import flash.text.*;
import flash.net.*
import flash.events.IOErrorEvent;
import flash.events.Event;
import flash.utils.ByteArray;
import com.adobe.serialization.json.JSON;

// The domain prefix determines the load location for content.  If set
// to empty, all content is assumed to be local.
public static const domainPrefix = "";

// Use when ZAPTCHA is fundamental absolute domain.
//public static const domainPrefix = "http://www.chriskallen.com/zzt/blog/";

// Use when my website is fundamental absolute domain.
//public static const domainPrefix = "http://www.chriskallen.com/zzt/";

// Dataset vars
public static var dataset:String;
public static var jsonObj:Object;
public static var embedData:ByteArray;
public static var fileRef:FileReference;
public static var origFileData:ByteArray;
public static var fileData:ByteArray;
public static var zipData:ZipFile;
public static var lumpData:Vector.<Lump>;

// Loading status
public static var origLastFileName:String = "";
public static var lastFileName:String = "";
public static var pwadKey:String = "";
public static var originalAction:int = zzt.MODE_NORM;
public static var loadingAction:int = zzt.MODE_NORM;
public static var loadingName:String = "";
public static var loadingMessage:String = "";
public static var myLoader:URLLoader = null;
public static var loadingSuccess:Boolean = false;
public static var localFileSource:Boolean = false;
public static var cancellingAction:int = zzt.MODE_NORM;

// The following "embedding" section is designed to act as a special-build
// interface for an all-in-one SWF redistributable.  If used, embedded files
// will be substituted for the files loaded from the configuration.
// This can be useful if the hosting platform does not readily support
// external file loading.

// Uncomment to embed binary files
/*
[Embed(source="guis/zzt_ini.txt", mimeType="application/octet-stream")] static private var emb_zzt_ini : Class;
[Embed(source="guis/zzt_guis.txt", mimeType="application/octet-stream")] static private var emb_zzt_guis : Class;
[Embed(source="guis/zzt_objs.txt", mimeType="application/octet-stream")] static private var emb_zzt_objs : Class;
[Embed(source="www/content/3_wad/SMASHZZT.WAD", mimeType="application/octet-stream")] static private var emb_autoload_world : Class;
*/

// Uncomment to register embedded binary files to be visible to loadRemoteFile
public static var embeddedFiles:Array = [
/*
["guis/zzt_ini.txt", emb_zzt_ini],
["guis/zzt_guis.txt", emb_zzt_guis],
["guis/zzt_objs.txt", emb_zzt_objs],
["www/content/3_wad/SMASHZZT.WAD", emb_autoload_world]
*/
];

public static function getEmbeddedFile(fName:String):ByteArray {
	for (var i:int = 0; i < embeddedFiles.length; i++) {
		if (fName == embeddedFiles[i][0])
			return (new (embeddedFiles[i][1])() as ByteArray);
	}

	return null;
}

public static function loadTextFile(filename:String, action:int):void {
	localFileSource = false;
	loadingName = filename;
	loadingAction = action;
	myLoader = null;

	loadingMessage = "Loading " + filename + "...";
	loadingSuccess = false;

	embedData = getEmbeddedFile(filename);
	if (embedData != null)
	{
		// Special embedded file instant-load.
		loaderCompleteHandler(null);
		return;
	}

	try {
		myLoader = new URLLoader(new URLRequest(domainPrefix + filename));
	}
	catch (e:Error)
	{
		zzt.Toast("ERROR:  " + e);
		return;
	}

	myLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
	myLoader.addEventListener(Event.COMPLETE, loaderCompleteHandler);
}

public static function cancelHandler(e:Event):void {
	zzt.showLoadingAnim = false;
	zzt.mainMode = cancellingAction;
}

public static function errorHandler(e:IOErrorEvent):void {
	zzt.showLoadingAnim = false;
	zzt.Toast("IO ERROR:  " + e);
	zzt.mainMode = zzt.MODE_NORM;
}

public static function loaderCompleteHandler(event:Event):void {
	if (embedData != null)
		dataset = embedData.readUTFBytes(embedData.length);
		//dataset = ZZTLoader.readExtendedASCIIString(embedData, embedData.length);
	else
		dataset = myLoader.data;

	if (loadingAction == zzt.MODE_LOADMAIN || loadingAction == zzt.MODE_LOADDEFAULTOOP ||
		loadingAction == zzt.MODE_LOADINI)
	{
		try {
			jsonObj = JSON.decode(dataset, false);
		}
		catch (e:Error)
		{
			zzt.Toast("ERROR:  " + e);
			zzt.mainMode = zzt.MODE_NORM;
			return;
		}
	}

	zzt.mainMode = loadingAction;
	loadingSuccess = true;
}

public static function jsonDecode(str:String):Object {
	try {
		jsonObj = JSON.decode(str, false);
	}
	catch (e:Error)
	{
		zzt.Toast("ERROR:  " + e);
		jsonObj = null;
	}

	return jsonObj;
}

public static function jsonToText(jObj:Object, sorted:Boolean=false, purgePattern:String=""):String {
	try {
		if (sorted)
		{
			// Sort all keys alphabetically, with periodic line breaks
			var s:String = getSortedObject(jObj, purgePattern);
			return s;
		}
		/*else if (lineBreaks)
		{
			// Insert line breaks between , and "
			s = JSON.encode(jObj);
			while (s.search(",\"") != -1)
				s = s.replace(",\"", ",\n\"");

			return s;
		}*/
		else
		{
			// No special handling; has no whitespace worth a mention between items.
			return JSON.encode(jObj);
		}
	}
	catch (e:Error)
	{
		zzt.Toast("ERROR:  " + e);
	}

	return "";
}

public static function getSortedObject(jObj:Object, purgePattern:String=""):String {
	// Get sort order of main keys.
	var mainKeys:Array = [];
	var kObj:Object;
	for (kObj in jObj) {
		var k:String = kObj.toString();
		if (purgePattern == "")
			mainKeys.push(k);
		else
		{
			if (!utils.startswith(k, purgePattern))
				mainKeys.push(k);
		}
	}

	var sortOrder:Array = mainKeys.sort(Array.RETURNINDEXEDARRAY);

	// Piece together sorted version of object.
	var allStr:String = "{";
	for (var i:int = 0; i < sortOrder.length; i++) {
		var thisKey:String = mainKeys[sortOrder[i]];
		var thisVal:Object = jObj[thisKey];
		if (thisKey == "KeyInput" || thisKey == "MouseInput" || thisKey == "Label")
		{
			// Further sort the keys within the sub-object.
			allStr += "\"" + thisKey + "\":" + getSortedObject(thisVal) + ",\n";
		}
		else
		{
			allStr += "\"" + thisKey + "\":" + JSON.encode(thisVal) + ",\n";
		}
	}

	// Modify closing characters and return.
	if (sortOrder.length > 0)
	{
		allStr = allStr.substr(0, allStr.length - 2);
	}

	return (allStr + "}");
}

public static function loadLocalFile(extension:String, action:int, cancelAction:int=-1):void {
	localFileSource = true;
	loadingMessage = "Loading...";
	loadingAction = action;
	loadingSuccess = false;
	cancellingAction = cancelAction;

	fileRef = new FileReference();
	fileRef.addEventListener(Event.SELECT, selectHandler);
	fileRef.addEventListener(Event.COMPLETE, bCompleteHandler);
	fileRef.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
	if (cancelAction != -1)
		fileRef.addEventListener(Event.CANCEL, cancelHandler);

	if (extension == "ALL")
	{
		var ff:FileFilter = new FileFilter("All Files", "*.*");
		fileRef.browse([ff]);
	}
	else
	{
		ff = new FileFilter(extension + " Files", "*." + extension);
		fileRef.browse([ff]);
	}
}

public static function loadRemoteFile(filename:String, action:int, specStr=""):void {
	localFileSource = false;
	loadingName = filename;
	loadingAction = action;
	loadingMessage = "Loading " + filename + "...";
	loadingSuccess = false;

	lastFileName = filename;
	do {
		var i:int = lastFileName.indexOf("/");
		if (i != -1)
			lastFileName = lastFileName.substr(i + 1);
		else
		{
			i = lastFileName.indexOf("\\");
			if (i != -1)
				lastFileName = lastFileName.substr(i + 1);
		}
	} while (i != -1);

	embedData = getEmbeddedFile(filename);
	if (embedData != null)
	{
		// Special embedded file instant-load.
		bCompleteHandler(null);
		return;
	}

	zzt.showLoadingAnim = true;

	try {
		myLoader = new URLLoader();
		myLoader.dataFormat = URLLoaderDataFormat.BINARY;
		myLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
		myLoader.addEventListener(Event.COMPLETE, bCompleteHandler);
		var urlRequest:URLRequest = new URLRequest(domainPrefix + filename);
		if (specStr != "")
		{
			var urlVars:URLVariables = new URLVariables();
			urlVars.spec = specStr;
			urlRequest.data = urlVars;
		}
		myLoader.load(urlRequest);
	}
	catch (e:Error)
	{
		zzt.Toast("ERROR:  " + e);
		return;
	}
}

public static function selectHandler(event:Event):void {
	zzt.showLoadingAnim = true;
	fileRef.load();
}

public static function bCompleteHandler(event:Event):void {
	zzt.showLoadingAnim = false;
	if (localFileSource)
	{
		fileData = fileRef.data;
		lastFileName = fileRef.name;
	}
	else if (embedData != null)
		fileData = embedData;
	else
		fileData = myLoader.data;

	if (loadingAction == zzt.MODE_LOADZIP)
	{
		try {
			zipData = new ZipFile(fileData);
			if (zipData.hasError)
			{
				zzt.Toast("ERROR:  Unable to load ZIP file.");
				zzt.mainMode = zzt.MODE_NORM;
				return;
			}
		}
		catch (e:Error)
		{
			zzt.Toast("ERROR:  " + e);
			zzt.mainMode = zzt.MODE_NORM;
			return;
		}
	}

	originalAction = zzt.mainMode;
	zzt.mainMode = loadingAction;
	loadingSuccess = true;
}

public static function saveLocalFile(localFile:String, action:int, cancelAction:int, saveData:*):void {
	localFileSource = true;
	loadingMessage = "Saving...";
	loadingAction = action;
	loadingSuccess = false;
	cancellingAction = cancelAction;

	fileRef = new FileReference();
	fileRef.addEventListener(Event.COMPLETE, bSCompleteHandler);
	fileRef.addEventListener(Event.CANCEL, cancelHandler);
	fileRef.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
	if (localFile.charAt(0) == ".")
		fileRef.save(saveData, "untitled" + localFile);
	else
		fileRef.save(saveData, localFile);
}

public static function bSCompleteHandler(event:Event):void {
	lastFileName = fileRef.name;
	zzt.showLoadingAnim = false;
	zzt.mainMode = loadingAction;
	loadingSuccess = true;
}

public static function pwadLoad(pwadIndex:Object, action:int):Boolean {
	if (!utils.ciTest(pwadIndex, lastFileName))
		return false; // Not in PWAD index

	// Save just-loaded file name and data
	origFileData = fileData;
	origLastFileName = lastFileName;
	pwadKey = utils.ciLookup(pwadIndex, lastFileName) as String;

	// Load PWAD file
	loadRemoteFile(pwadKey, action);
	return true;
}

public static function replacePage(newUrl:String):void {
	var req:URLRequest = new URLRequest("http://www.chriskallen.com/zzt/" + newUrl);
	navigateToURL(req, "_self");
}

public static function blankPage(newUrl:String):void {
	var req:URLRequest = new URLRequest("http://www.chriskallen.com/zzt/" + newUrl);
	navigateToURL(req, "_blank");
}


};
};

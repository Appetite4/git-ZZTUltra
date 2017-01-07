// utils.as:  General utility functions.

package {
public class utils {

import flash.geom.*;

//Random number functions
public static function frange(lower:Number, upper:Number):Number
{
	return ((Math.random() * (upper - lower)) + lower);
}
public static function randrange(lower:int, upper:int):int
{
	return (int(Math.random() * (upper - lower + 1)) + lower);
}
public static function zerothru(qty:int):int
{
	return (int(Math.random() * (qty + 1)));
}
public static function onethru(qty:int):int
{
	return (int(Math.random() * qty) + 1);
}
public static function eitheror():Boolean
{
	return (Boolean(Math.random() <= 0.5));
}
public static function oneoutof(denom:Number):Boolean
{
	return (Boolean(Math.random() < 1.0 / denom));
}
public static function noutofn(num:Number, denom:Number):Boolean
{
	return (Boolean(Math.random() < num / denom));
}
public static function dir4norm():int
{
	// All directions equally likely
	return (int(Math.random() * 4));
}
public static function dir4skewed():int
{
	// Horizontal directions twice as likely as vertical
	var i:int = int(Math.random() * 6);
	if (i == 4)
		i = 0;
	else if (i == 5)
		i = 2;
	return i;
}

public static var curXSize:int;
public static var curYSize:int;
public static var curAllSize:int;
public static var curDissolveArr:Array = null;

public static function getDissolveArray(xSize:int, ySize:int):Array
{
	if (xSize != curXSize || ySize != curYSize)
		curDissolveArr = createRandomPosArray(xSize, ySize);

	return curDissolveArr;
}
public static function createRandomPosArray(xSize:int, ySize:int):Array
{
	// Save dimensions; create new dissolve array
	curXSize = xSize;
	curYSize = ySize;
	curAllSize = xSize * ySize;
	curDissolveArr = new Array(curAllSize);

	// Create temporary position array
	var i:int;
	var posArr:Array = new Array(curAllSize);
	for (i = 0; i < curAllSize; i++)
		posArr[i] = i;

	// Repeatedly take random list entries from position array until all taken
	for (i = curAllSize - 1; i >= 0; i--)
	{
		var val:int = zerothru(i);
		curDissolveArr[i] = posArr[val];
		posArr[val] = posArr[i];
	}

	return curDissolveArr;
}

//General functions
public static function int0(str:String):int
{
	var i:int;
	try {
		i = int(str);
	}
	catch (e:Error) {
		i = 0;
	}
	return i;
}
public static function float0(str:String):Number
{
	var f:Number;
	try {
		f = Number(str);
	}
	catch (e:Error) {
		f = 0.0;
	}
	return f;
}
public static function intMaybe(str:String, defInt:int):int
{
	var i:int;
	try {
		i = int(str);
	}
	catch (e:Error) {
		i = defInt;
	}
	return i;
}
public static function floatMaybe(str:String, defFloat:Number):Number
{
	var f:Number;
	try {
		f = Number(str);
	}
	catch (e:Error) {
		f = defFloat;
	}
	return f;
}
public static function avg(n1:Number, n2:Number):Number
{
	return ((n1 + n2) / 2);
}
public static function isgn(n:int):int
{
	if (n < 0) return -1;
	if (n > 0) return 1;
	return 0;
}
public static function sgn(n:Number):Number
{
	if (n < 0) return -1;
	if (n > 0) return 1;
	return 0;
}
public static function iabs(n:int):int
{
	if (n < 0) return -n;
	return n;
}
public static function inrange(n:int, lowest:int, highest:int):Boolean
{
	if (n < lowest || n > highest) return false;
	return true;
}
public static function clipval(n:Number, lowest:Number, highest:Number):Number
{
	if (n < lowest) n = lowest;
	if (n > highest) n = highest;
	return n;
}
public static function hexcode(n:int):String
{
	var i:int = n & 15;
	var s:String;
	if (i <= 9)
		s = String.fromCharCode(48 + i);
	else
		s = String.fromCharCode(65 - 0xA + i);

	i = (n >> 4) & 15;
	if (i <= 9)
		return (String.fromCharCode(48 + i) + s);
	else
		return (String.fromCharCode(65 - 0xA + i) + s);
}
public static function twogrouping(digits:int):String
{
	//A 2-digit grouping will always have 2 characters.
	var str:String = "";
	if (digits < 10)
		str += "0";

	str += String(digits);
	return str;
}
public static function threegrouping(digits:int):String
{
	//A 3-digit grouping will always have 3 characters.
	var str:String = "";
	if (digits < 10)
		str += "00";
	else if (digits < 100)
		str += "0";

	str += String(digits);
	return str;
}
public static function getcommaval(n:Number):String
{
	var str:String = "";
	var ival:int = int(n);

	//Early out if too small for grouping.
	if (ival < 1000)
		return (String(ival));

	//Millions grouping.
	if (ival >= 1000000)
	{
		str += int(ival / 1000000) + ",";
		ival %= 1000000;

		//Thousands grouping.
		str += threegrouping(ival / 1000) + ",";
		ival %= 1000;
	}
	else
	{
		//Thousands grouping.
		str += int(ival / 1000) + ",";
		ival %= 1000;
	}

	//Ones grouping.
	str += threegrouping(ival);

	return str;
}
public static function getsecondsbreakdown(n:Number):String
{
	var str:String = "";

	//Minutes
	str += int(n / 60.0) + ":";
	var secs:int = int(n % 60.0);

	//Seconds
	if (secs < 10) str += "0";
	str += secs;
	//str += secs + ".";

	//Hundredths of seconds
	var hundredths:int = int(((n % 60.0) - secs) * 100);
	if (hundredths < 10) str += "0";
	str += hundredths;

	return str;
}
public static function lstrip(s:String):String
{
	var l:int = s.length;
	var i:int = 0;
	while (i < l)
	{
		if (s.charCodeAt(i) != 32)
			break;
		i++;
	}

	return (s.substring(i));
}
public static function rstrip(s:String):String
{
	var i:int = s.length;
	while (--i >= 0)
	{
		if (s.charCodeAt(i) != 32)
			break;
	}

	return (s.substring(0, i + 1));
}
public static function allStrip(s:String):String
{
	// Right
	var i:int = s.length;
	while (--i >= 0)
	{
		if (s.charCodeAt(i) > 32)
			break;
	}

	s = s.substring(0, i + 1);

	// Left
	var l:int = s.length;
	i = 0;
	while (i < l)
	{
		if (s.charCodeAt(i) > 32)
			break;
		i++;
	}

	return (s.substring(i));
}

public static function scrubPath(s:String):String {
	// Scrub path for unsecure syntax (no .. or web root)
	while (s.indexOf("..") != -1)
		s = s.replace("..", "");

	while (s.charAt(0) == "/" || s.charAt(0) == "\\")
		s = s.substr(1);

	return s;
}

public static function namePartOfFile(s:String):String {
	// Get name part of file only (no directory portions)
	var idx:int;
	do {
		idx = s.search("/");
		if (idx != -1)
			s = s.substr(idx + 1);
	} while (idx != -1);

	do {
		idx = s.search("\\");
		if (idx != -1)
			s = s.substr(idx + 1);
	} while (idx != -1);

	return s;
}

public static function cr2lf(s:String):String {
	// Convert CR to LF
	return (s.split("\r").join("\n"));
}
public static function lf2cr(s:String):String {
	// Convert LF to CR
	return (s.split("\n").join("\r"));
}

public static function endswith(fName:String, fExt:String):Boolean {
	// Get case-insensitive "ends with"
	if (fExt.length > fName.length)
		return false;

	return Boolean(
		fName.substr(fName.length - fExt.length).toUpperCase() == fExt.toUpperCase());
}

public static function startswith(fName:String, fStart:String):Boolean {
	// Get case-insensitive "starts with"
	if (fStart.length > fName.length)
		return false;

	return Boolean(
		fName.substr(0, fStart.length).toUpperCase() == fStart.toUpperCase());
}

public static function getSortedKeys(o:Object):Array {
	// Get sort order of main keys.
	var mainKeys:Array = [];
	for (var kObj:Object in o)
		mainKeys.push(kObj.toString());

	mainKeys.sort();
	return mainKeys;
}

public static function ciTest(o:Object, key:String):Boolean {
	// Case-insensitive test for key.
	key = key.toUpperCase();
	for (var k:String in o) {
		if (k.toUpperCase() == key)
			return true;
	}

	return false;
}

public static function ciLookup(o:Object, key:String):Object {
	// Lookup of value from case-insensitive key.
	key = key.toUpperCase();
	for (var k:String in o) {
		if (k.toUpperCase() == key)
			return o[k];
	}

	return null;
}

};
};

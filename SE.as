// SE.as:  A ZZT status-element object.

package {

import flash.utils.Dictionary;
import flash.utils.ByteArray;

public class SE {
	// Static variables
	public static var tg:ByteArray;			// Type grid
	public static var cg:ByteArray;			// Color grid
	public static var lg:ByteArray;			// Lighting grid
	public static var sg:Vector.<SE>;		// Status element pointer grid
	public static var gridWidth:int;		// Width of current board
	public static var gridHeight:int;		// Height of current board
	public static var fullGridWidth:int;	// Width of current board, including borders
	public static var fullGridHeight:int;	// Height of current board, including borders
	public static var vpX0:int = 0;			// Viewport left
	public static var vpY0:int = 0;			// Viewport top
	public static var vpX1:int = 60;		// Viewport right
	public static var vpY1:int = 25;		// Viewport bottom
	public static var vpWidth:int;			// Viewport width
	public static var vpHeight:int;			// Viewport height
	public static var CameraX:int = 1;		// Camera UL corner (1-based)
	public static var CameraY:int = 1;		// Camera UL corner (1-based)
	public static var uCameraX:int = -1000; // Camera UL corner of last valid update (1-based)
	public static var uCameraY:int = -1000; // Camera UL corner of last valid update (1-based)

	public static var typeList:Array;		// List of type look-up info
	public static var mg:CellGrid;			// Main grid
	public static var statElem:Vector.<SE>;	// Vector of status element info
	public static var statLessCount:int;	// "Non-stat" status elements for board
	public static var statIter:int;			// SE search iterator

	public static var suspendDisp:int = 0;	// Flag used to temporarily suspend display
	public static var IsDark:int = 0;		// Flag set if board is dark
	public static var darkChar:int;			// "Darkness" character code
	public static var darkColor:int;		// "Darkness" color code

	// Variables
	public var TYPE:int;
	public var CYCLE:int;
	public var X:int; // 1-based!  0 is off the grid in the BOARDEDGE region.
	public var Y:int; // 1-based!  0 is off the grid in the BOARDEDGE region.
	public var STEPX:int;
	public var STEPY:int;
	public var UNDERID:int;
	public var UNDERCOLOR:int;
	public var IP:int;
	public var FLAGS:int;
	public var delay:int;
	public var myID:int;

	// Common extra variables include:
	// P1
	// P2
	// P3
	// FOLLOWER
	// LEADER
	// ONAME
	// CODEID
	// CHAR
	public var extra:Object;

	// Constructor
	public function SE(type:int, startX:int, startY:int, color:int=-1000, noPlace=false) {
		// Set basic attributes
		TYPE = type;
		X = startX;
		Y = startY;
		clipXY();

		// Set default attributes, if they exist
		var eInfo:ElementInfo = typeList[type];
		CYCLE = eInfo.CYCLE;
		STEPX = eInfo.STEPX;
		STEPY = eInfo.STEPY;
		UNDERID = tg[Y * fullGridWidth + X];
		UNDERCOLOR = cg[Y * fullGridWidth + X];
		IP = 0;
		FLAGS = 0;
		delay = 1;
		myID = 0;
		if (color == -1000)
			color = eInfo.COLOR;

		// Set additional default attributes, if they exist
		extra = new Object();
		for (var obj:Object in eInfo.extraVals)
		{
			extra[obj] = eInfo.extraVals[obj];
		}

		// Modify grid to reflect updated status element, unless inhibited
		if (!noPlace)
		{
			setType(X, Y, type);
			setColor(X, Y, color);
		}
	}

	public function toString():String {
		var str:String = "\nTYPE=" + TYPE.toString() + ">" + typeList[TYPE].NUMBER.toString() +
			"\nCYCLE=" + CYCLE.toString() +
			"\nCOORD=" + X.toString() + "," + Y.toString() +
			"\nSTEP=" + STEPX.toString() + "," + STEPY.toString() +
			"\nUNDERID=" + UNDERID.toString() + " UNDERCOLOR=" + UNDERCOLOR.toString() +
			"\nIP=" + IP.toString() + " FLAGS=" + FLAGS.toString() +
			"\ndelay=" + delay.toString() + " ID=" + myID.toString() + "\nextra=";

		for (var obj:Object in extra)
			str += obj.toString() + "->" + extra[obj].toString() + "\n";

		return str;
	}

	// Clip X and Y to remain on the grid
	public function clipXY():void {
		if (X < 1)
			X = 1;
		if (Y < 1)
			Y = 1;
		if (X > gridWidth)
			X = gridWidth;
		if (Y > gridHeight)
			Y = gridHeight;
	}

	// Display own square
	public function displaySelfSquare():void {
		// Draw nothing if out of viewport
		if (suspendDisp || X < CameraX || Y < CameraY ||
			X-CameraX >= vpWidth || Y-CameraY >= vpHeight)
			return;

		// Get standard info
		var eInfo:ElementInfo = typeList[TYPE];
		var color:int = cg[Y * fullGridWidth + X];
		var dispX:int = X - CameraX + vpX0 - 1;
		var dispY:int = Y - CameraY + vpY0 - 1;

		if (IsDark && !eInfo.AlwaysLit && !lg[Y * fullGridWidth + X])
		{
			// For dark boards, draw darkness.
			mg.setCell(dispX, dispY, darkChar, darkColor);
		}
		else if (eInfo.CustomDraw)
		{
			interp.customDrawColor = color;
			if (!eInfo.NoStat)
			{
				if (eInfo.HasOwnChar)
					interp.customDrawChar = extra["CHAR"];
				else
					interp.customDrawChar = eInfo.CHAR;

				interp.customDrawSE.extra["CHAR"] = interp.customDrawChar;
			}
			else
				interp.customDrawChar = 0;

			interp.dispatchCustomDraw(TYPE, X, Y);
			mg.setCell(dispX, dispY, interp.customDrawChar, interp.customDrawColor);
		}
		else if (eInfo.HasOwnChar)
		{
			// Use locally-defined character.
			mg.setCell(dispX, dispY, extra["CHAR"], color);
		}
		else
		{
			// Normal drawing simply sets the default character for the type.
			mg.setCell(dispX, dispY, eInfo.CHAR, color);
		}
	}

	// Erase own square
	public function eraseSelfSquare(doShow:Boolean=true):void {
		if ((FLAGS & interp.FL_GHOST) == 0)
		{
			tg[Y * fullGridWidth + X] = UNDERID;
			cg[Y * fullGridWidth + X] = UNDERCOLOR;
			sg[Y * fullGridWidth + X] = null;
			if (doShow)
				displaySquare(X, Y);
		}
	}

	// Move own square to new position
	public function moveSelfSquare(newX:int, newY:int, eraseLast:Boolean=true):void {
		var color:int = cg[Y * fullGridWidth + X];
		if (!typeList[TYPE].FullColor)
			color &= 0x8F;
		if (eraseLast)
			eraseSelfSquare();

		X = newX;
		Y = newY;
		clipXY();
		UNDERID = tg[Y * fullGridWidth + X];
		UNDERCOLOR = cg[Y * fullGridWidth + X];
		setType(X, Y, TYPE);
		setColor(X, Y, color, Boolean(UNDERID != 0));
		setStatElemAt(X, Y, this);

		displaySelfSquare();
	}

	// Display a specific square
	public static function displaySquare(x:int, y:int):void {
		// Draw nothing if out of viewport
		if (suspendDisp || x < CameraX || y < CameraY ||
			x-CameraX >= vpWidth || y-CameraY >= vpHeight)
			return;

		// Get standard info
		var type:int = tg[y * fullGridWidth + x];
		var eInfo:ElementInfo = typeList[type];
		var color:int = cg[y * fullGridWidth + x];
		var dispX:int = x - CameraX + vpX0 - 1;
		var dispY:int = y - CameraY + vpY0 - 1;
		var mySE:SE = getStatElemAt(x, y);

		// See if we have any special drawing requirements
		if (IsDark && !eInfo.AlwaysLit && !lg[y * fullGridWidth + x])
		{
			// For dark boards, draw darkness.
			mg.setCell(dispX, dispY, darkChar, darkColor);
		}
		else if (eInfo.NUMBER == 0)
		{
			// Empty is short-circuit forced to dark blank space.
			mg.setCell(dispX, dispY, 32, 15);
		}
		else if (eInfo.TextDraw)
		{
			// Text characters are a bit odd, with color associated with the type,
			// and character determined by the color attribute.  Although this
			// is counter-intuitive, it lets the designer use any character as text.
			mg.setCell(dispX, dispY, color, eInfo.COLOR);
		}
		else if (eInfo.CustomDraw)
		{
			// Custom drawing callback is present for some types (LINE, etc.)
			interp.customDrawColor = color;
			if (!eInfo.NoStat)
			{
				if (eInfo.HasOwnChar)
					interp.customDrawChar = mySE.extra["CHAR"];
				else
					interp.customDrawChar = eInfo.CHAR;

				interp.customDrawSE.extra["CHAR"] = interp.customDrawChar;
			}
			else
				interp.customDrawChar = 0;

			interp.dispatchCustomDraw(type, x, y);
			mg.setCell(dispX, dispY, interp.customDrawChar, interp.customDrawColor);
		}
		else if (eInfo.HasOwnChar)
		{
			// Some objects have a flexible character (spinning guns, objects, etc).
			if (mySE)
			{
				// Use locally-defined character
				mg.setCell(dispX, dispY, mySE.extra["CHAR"], color);
			}
			else
			{
				// This is somewhat anomalous, but still possible:  there is no
				// status element for a type that requires it.  Use type-based
				// character, which might be wrong but better than nothing.
				mg.setCell(dispX, dispY, eInfo.CHAR, color);
			}
		}
		else
		{
			// Normal drawing simply sets the default character for the type.
			mg.setCell(dispX, dispY, eInfo.CHAR, color);
		}
	}

	// Get status element object from vector, if myID is valid
	public static function getStatElem(oPtr:int):SE {
		if (oPtr <= 0)
			return null; // Invalid

		for (var i:int = 0; i < statElem.length; i++)
		{
			var mySE:SE = statElem[i];
			if (!(mySE.FLAGS & interp.FL_DEAD) && mySE.myID == oPtr)
			{
				return mySE; // Found
			}
		}

		return null; // Not found
	}

	// Get status element object with matching "extra" var, if any exist
	public static function getONAMEMatching(val:String, startIndex:int=0):SE {
		statIter = startIndex;
		var testLen:int = val.length;
		for (; statIter < statElem.length; statIter++)
		{
			var mySE:SE = statElem[statIter];
			if (mySE.extra.hasOwnProperty("ONAME"))
			{
				var testStr:String = mySE.extra["ONAME"].toString().toUpperCase();
				if (testLen < testStr.length)
				{
					// Starts-with string test
					if (testStr.substr(0, testLen) == val && !oop.isAlphaNum(testStr, testLen))
					{
						statIter++;
						return mySE; // Found
					}
				}
				else if (testStr == val)
				{
					// Exact-match string test
					statIter++;
					return mySE; // Found
				}
			}
		}

		statIter = 0;
		return null; // Not found
	}

	// Get status element object with own code
	public static function getStatElemOwnCode(startIndex:int=0):SE {
		statIter = startIndex;
		for (; statIter < statElem.length; statIter++)
		{
			var mySE:SE = statElem[statIter];
			var eInfo:ElementInfo = typeList[mySE.TYPE];
			if (eInfo.HasOwnCode)
			{
				statIter++;
				return mySE; // Found
			}
		}

		statIter = 0;
		return null; // Not found
	}

	// Get status element object from square, if one exists at a point
	public static function getStatElemAt(x:int, y:int):SE {
		return sg[y * fullGridWidth + x];
	}

	// Set grid square's status element pointer
	public static function setStatElemAt(x:int, y:int, sePtr:SE):void {
		sg[y * fullGridWidth + x] = sePtr;
	}

	// Set grid square's type
	public static function setType(x:int, y:int, type:int):void {
		tg[y * fullGridWidth + x] = type;
	}

	// Set grid square's color
	public static function setColor(x:int, y:int, color:int, useUnderColor:Boolean=true):void {
		if (color > 15 || !useUnderColor)
			cg[y * fullGridWidth + x] = color;
		else
			cg[y * fullGridWidth + x] = (cg[y * fullGridWidth + x] & 0x70) + color;
	}

	// Set grid square's lit flag
	public static function setLit(x:int, y:int, flag:int):void {
		lg[y * fullGridWidth + x] = flag;
	}

	// Get grid square's type
	public static function getType(x:int, y:int):int {
		return (tg[y * fullGridWidth + x]);
	}

	// Get grid square's color
	public static function getColor(x:int, y:int):int {
		return (cg[y * fullGridWidth + x]);
	}

	// Get grid square's color
	public static function getLit(x:int, y:int):int {
		return (lg[y * fullGridWidth + x]);
	}

}
}

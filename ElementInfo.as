// ElementInfo.as:  A ZZT element look-up object.

package 
{

import flash.utils.Dictionary;

public class ElementInfo {
	// Variables
	public var NUMBER:int;	// Required
	public var NAME:String; // Required
	public var CYCLE:int;	// Default; can change
	public var STEPX:int;	// Default; step not always used
	public var STEPY:int;	// Default; step not always used
	public var CHAR:int;	// Default; sometimes overridden
	public var COLOR:int;	// Default; often overridden

	public var NoStat:Boolean;			// No status element for type
	public var BlockObject:Boolean;		// Blocks most objects from moving immediately
	public var BlockPlayer:Boolean;		// Blocks player from moving immediately
	public var AlwaysLit:Boolean;		// Whether type is always visible even in dark rooms
	public var DominantColor:Boolean;	// Disallow color qualifiers in PUT, CHANGE, etc.
	public var FullColor:Boolean;		// Take all 8 bits of color when object moves
	public var TextDraw:Boolean;		// Text characters flip type/color meaning
	public var CustomDraw:Boolean;		// Drawing dispatches CUSTOMDRAW label
										// to identify character and color
	public var HasOwnChar:Boolean;		// Drawing should use CHAR extra value

	public var HasOwnCode:Boolean;		// Status element will specify own code block
	public var CustomStart:int;			// Starting index of custom code

	public var Pushable:int;			// Pushabilty code
	public var Squashable:Boolean;		// Squashability flag

	public var LocPUSHBEHAVIOR:int;		// Location in code of PUSHBEHAVIOR label
	public var LocWALKBEHAVIOR:int;		// Location in code of WALKBEHAVIOR label
	public var LocCUSTOMDRAW:int;		// Location in code of CUSTOMDRAW label

	// Extra values act as starting values for object-specific variables
	// if the type is designed to have a status element.  If no status
	// element is used for this type, the values act as globals.
	public var extraVals:Object;

	// Code is required for all element types.  The ID is an index into
	// interp.codeBlocks for the element type.  The actual status element
	// code might eventually resemble something other than this, which will
	// be indicated by extra.CODEID.
	public var CODEID:int;

	// Constructor
	public function ElementInfo(toName:String) {
		NUMBER = 0;
		NAME = toName;
		CYCLE = 3;
		STEPX = 0;
		STEPY = 0;
		CHAR = 0;
		COLOR = 15;
		NoStat = false;
		BlockObject = false;
		BlockPlayer = false;
		AlwaysLit = false;
		DominantColor = false;
		FullColor = false;
		TextDraw = false;
		CustomDraw = false;
		HasOwnChar = false;
		HasOwnCode = false;
		CustomStart = 0;
		Pushable = 0;
		Squashable = false;
		CODEID = 0;
		LocPUSHBEHAVIOR = -1;
		LocWALKBEHAVIOR = -1;
		LocCUSTOMDRAW = -1;
		extraVals = new Object();
	}

	// Fast-copy element info
	public function copyFrom(eInfo:ElementInfo):void {
		NUMBER = eInfo.NUMBER;
		NAME = eInfo.NAME;
		CYCLE = eInfo.CYCLE;
		STEPX = eInfo.STEPX;
		STEPY = eInfo.STEPY;
		CHAR = eInfo.CHAR;
		COLOR = eInfo.COLOR;
		NoStat = eInfo.NoStat;
		BlockObject = eInfo.BlockObject;
		BlockPlayer = eInfo.BlockPlayer;
		AlwaysLit = eInfo.AlwaysLit;
		DominantColor = eInfo.DominantColor;
		FullColor = eInfo.FullColor;
		TextDraw = eInfo.TextDraw;
		CustomDraw = eInfo.CustomDraw;
		HasOwnChar = eInfo.HasOwnChar;
		HasOwnCode = eInfo.HasOwnCode;
		CustomStart = eInfo.CustomStart;
		Pushable = eInfo.Pushable;
		Squashable = eInfo.Squashable;
		CODEID = eInfo.CODEID;
		LocPUSHBEHAVIOR = eInfo.LocPUSHBEHAVIOR;
		LocWALKBEHAVIOR = eInfo.LocWALKBEHAVIOR;
		LocCUSTOMDRAW = eInfo.LocCUSTOMDRAW;
		extraVals = new Object();
		for (var k:String in eInfo.extraVals) {
			extraVals[k] = eInfo.extraVals[k];
		}
	}

	// Stringify
	public function toString():String {
		var s:String = "\"" + NAME + "\":{\n";
		s += "\"NUMBER\": " + NUMBER.toString();
		s += ",\n\"CYCLE\": " + CYCLE.toString();
		if (STEPX != 0)
			s += ",\n\"STEPX\": " + STEPX.toString();
		if (STEPY != 0)
			s += ",\n\"STEPY\": " + STEPY.toString();
		s += ",\n\"CHAR\": " + CHAR.toString();
		s += ",\n\"COLOR\": " + COLOR.toString();
		if (NoStat)
			s += ",\n\"NOSTAT\": 1";
		if (BlockObject)
			s += ",\n\"BLOCKOBJECT\": 1";
		if (BlockPlayer)
			s += ",\n\"BLOCKPLAYER\": 1";
		if (AlwaysLit)
			s += ",\n\"ALWAYSLIT\": 1";
		if (DominantColor)
			s += ",\n\"DOMINANTCOLOR\": 1";
		if (FullColor)
			s += ",\n\"FULLCOLOR\": 1";
		if (TextDraw)
			s += ",\n\"TEXTDRAW\": 1";
		if (CustomDraw)
			s += ",\n\"CUSTOMDRAW\": 1";
		if (HasOwnChar)
			s += ",\n\"HASOWNCHAR\": 1";
		if (HasOwnCode)
			s += ",\n\"HASOWNCODE\": 1";
		if (CustomStart != 0)
			s += ",\n\"CUSTOMSTART\": " + CustomStart.toString();
		if (Pushable != 0)
			s += ",\n\"PUSHABLE\": " + Pushable.toString();
		if (Squashable)
			s += ",\n\"SQUASHABLE\": 1";

		for (var k:String in extraVals) {
			var val:String = extraVals[k].toString();
			var testInt:int = utils.int0(val);
			if (testInt.toString() != val)
				val = "\"" + val + "\"";

			s += ",\n\"" + k + "\": " + val;
		}

		// Code block will need to be closed separately.
		s += ",\n\"CODE\": ";
		return s;
	}

	// Run-time read a property
	public function readProperty(s:String):Object {
		switch (s.toUpperCase()) {
			case "NUMBER":
				return NUMBER;
			case "NAME":
				return NAME;
			case "CYCLE":
				return CYCLE;
			case "STEPX":
				return STEPX;
			case "STEPY":
				return STEPY;
			case "CHAR":
				return CHAR;
			case "COLOR":
				return COLOR;
			case "NOSTAT":
				return (NoStat ? 1 : 0);
			case "BLOCKOBJECT":
				return (BlockObject ? 1 : 0);
			case "BLOCKPLAYER":
				return (BlockPlayer ? 1 : 0);
			case "ALWAYSLIT":
				return (AlwaysLit ? 1 : 0);
			case "DOMINANTCOLOR":
				return (DominantColor ? 1 : 0);
			case "FULLCOLOR":
				return (FullColor ? 1 : 0);
			case "TEXTDRAW":
				return (TextDraw ? 1 : 0);
			case "CUSTOMDRAW":
				return (CustomDraw ? 1 : 0);
			case "HASOWNCHAR":
				return (HasOwnChar ? 1 : 0);
			case "HASOWNCODE":
				return (HasOwnCode ? 1 : 0);
			case "CUSTOMSTART":
				return ((CustomDraw > 0) ? 1 : 0);
			case "PUSHABLE":
				return Pushable;
			case "SQUASHABLE":
				return (Squashable ? 1 : 0);
			default:
				if (extraVals.hasOwnProperty(s))
					return extraVals[s];
		}

		return 0;
	}

	// Run-time write a property
	public function writeProperty(s:String, val:Object):Boolean
	{
		switch (s.toUpperCase()) {
			case "NUMBER":
				return false;
			case "NAME":
				return false;
			case "CYCLE":
				CYCLE = utils.int0(val.toString());
				break;
			case "STEPX":
				STEPX = utils.int0(val.toString());
				break;
			case "STEPY":
				STEPY = utils.int0(val.toString());
				break;
			case "CHAR":
				if (val is String)
					CHAR = (val as String).charCodeAt(0);
				else
					CHAR = utils.int0(val.toString());
				break;
			case "COLOR":
				COLOR = utils.int0(val.toString());
				break;
			case "NOSTAT":
				return false;
			case "BLOCKOBJECT":
				BlockObject = Boolean(val);
				break;
			case "BLOCKPLAYER":
				BlockPlayer = Boolean(val);
				break;
			case "ALWAYSLIT":
				AlwaysLit = Boolean(val);
				break;
			case "DOMINANTCOLOR":
				DominantColor = Boolean(val);
				break;
			case "FULLCOLOR":
				FullColor = Boolean(val);
				break;
			case "TEXTDRAW":
				TextDraw = Boolean(val);
				break;
			case "CUSTOMDRAW":
				return false;
			case "HASOWNCHAR":
				return false;
			case "HASOWNCODE":
				return false;
			case "CUSTOMSTART":
				return false;
			case "PUSHABLE":
				Pushable = utils.int0(val.toString());
				break;
			case "SQUASHABLE":
				Squashable = Boolean(val);
				break;
			default:
				extraVals[s] = val;
		}

		return true;
	}
}

}

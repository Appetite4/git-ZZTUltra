// interp.as:  The program's OOP interpretation functions.

package {
public class interp {

import flash.geom.*;
import flash.text.*;
import flash.utils.ByteArray;

// Constants

// SE flags
public static const FL_IDLE:int = 1;
public static const FL_LOCKED:int = 2;
public static const FL_PENDINGDEAD:int = 4;
public static const FL_DEAD:int = 8;
public static const FL_GHOST:int = 16;
public static const FL_NOSTAT:int = 32;
public static const FL_DISPATCH:int = 64;
public static const FL_UNDERLAYER:int = 128;

// Type placement modes
public static const CF_RETAINSE:int = 1;
public static const CF_RETAINCOLOR:int = 2;
public static const CF_REMOVEIFBLOCKING:int = 4;
public static const CF_GHOSTED:int = 8;
public static const CF_UNDERLAYER:int = 16;

// Text target locations
public static const TEXT_TARGET_NORM:int = 0;
public static const TEXT_TARGET_GUI:int = 1;
public static const TEXT_TARGET_GRID:int = 2;

public static const SCRIPT_DEADLOCK_THRESHOLD:int = 65536;

public static var step2Dir4:Array = [ 2, 3, 3, 2, -1, 0, 1, 1, 0 ];
public static var step2Dir8:Array = [ 5, 6, 7, 4, -1, 0, 3, 2, 1 ];
public static var dir2StepX:Array = [ 1, 1, 0, -1, -1, -1, 0, 1, 1 ];
public static var dir2StepY:Array = [ 0, 1, 1, 1, 0, -1, -1, -1, 0 ];

// Variables
public static var typeList:Array;
public static var typeTrans:Array;
public static var codeBlocks:Array;
public static var unCompCode:Array;
public static var unCompStart:Vector.<int>;
public static var zapRecord:Vector.<ZapRecord>;
public static var numBuiltInCodeBlocks:int = 0;
public static var numBuiltInCodeBlocksPlus:int = 0;
public static var numBuiltInTypes:int;
public static var numOverrideTypes:int;

// SE pointers
public static var blankSE:SE;
public static var thisSE:SE;
public static var playerSE:SE = null;
public static var cloneSE:SE;
public static var customDrawSE:SE;
public static var ptr2SetInExpr:SE;
public static var linkFollowSE:SE;
public static var fileLinkSE:SE;
public static var playSyncIdleSE:SE = null;

// Clone info
public static var cloneType:int = 0;
public static var cloneColor:int = 0;
public static var lastKindColor:int = 0;

// Interpreter state
public static var code:Array;
public static var turns:int;
public static var onPropPos:int = -1;
public static var onMousePos:int = -1;
public static var scriptDeadlockCount:int = 0;
public static var objComCount:int = 32;
public static var objComThreshold:int = 32;
public static var dispatchStack:Array = [];
public static var classicSet:int = 0;
public static var restoredFirst:Boolean = false;
public static var restoreEarlyOut:Boolean = false;
public static var playSyncIdleCode:Array = null;

// Direction, region info, misc. pointers
public static var majorDir:int = 0;
public static var minorDir:int = 0;
public static var coords1:Array = [ 1, 1 ];
public static var coords2:Array = [ 1, 1 ];
public static var noRegion:Array = [ [ 0, 0 ] , [ 0, 0 ] ];
public static var allRegion:Array = [ [ 1, 1 ] , [ 1, 1 ] ];
public static var litRegion:Array = [ [ 1000000, 1000000 ] , [ -1, -1 ] ];
public static var testRegion:Array;
public static var forceRegionLiteral:Boolean = false;
public static var noMask:Array = [ [ 0 ] ];
public static var modGuiLabel:Array = null;
public static var genericSeq:Array = null;
public static var lastExprType:int = 0;
public static var kwargPos:int = 0;
public static var memberIdx:int = 0;
public static var exprRefSrc1:Array = null;
public static var exprRefSrc2:Array = null;
public static var nextObjPtrNum:int = 65536;
public static var highScoreUID:int = 1;
public static var wouldSquashX:int = 0;
public static var wouldSquashY:int = 0;

// Custom draw info
public static var inCustomDraw:Boolean = false;
public static var customDrawChar:int = 0;
public static var customDrawColor:int = 0;

// "FOR" loop info
public static var forRetLoc:int = -1;
public static var forType:int = 0;
public static var forVarType1:int = 0;
public static var forVarType2:int = 0;
public static var forVarName1:String = "!";
public static var forVarName2:String = "!";
public static var forMask:Array = [ [ 0, 0 ] , [ 0, 0 ] ];
public static var forMaskXSize:int = 0;
public static var forMaskYSize:int = 0;
public static var forCornerX:int = 1;
public static var forCornerY:int = 1;
public static var forCursorX:int = 0;
public static var forCursorY:int = 0;
public static var forRegion:Array = [ [ 0, 0 ] , [ 0, 0 ] ];

// Group movement info
public static var doGroupMove:Boolean = false;
public static var checkAllGroup:Boolean = true;
public static var groupRimStepX:int = 0;
public static var groupRimStepY:int = 0;
public static var gArray:Array = [];
public static var groupRimX:Array = [];
public static var groupRimY:Array = [];

// Text display info
public static var doDispText:int = 0;
public static var textTarget:int = 0;
public static var textDestType:int = 73; // _TEXTBLUE
public static var textDestLabel:String = "NONE";
public static var marqueeSize:int = 60;
public static var marqueeDir:int = -1;
public static var marqueeText:String = "";

// Special
public static var captchaSrcArray:Array = [];
public static var captchaMainVal:int = 0;

// Translate number to type, but let stand special kinds.
public static function typeTrans2(k:int):int {
	if (k < 0)
		return k;
	else
		return typeTrans[k & 255];
}

// Like typeTrans2, but "moves" ZZT text types to SZT text types.
public static function typeTrans3(k:int):int {
	if (zzt.loadedOOPType == -1 && k >= 47 && k <= 53)
		k += 26; // Type unification:  Text -> SZT

	return typeTrans[k & 255];
}

// Fetch integer from code sequence; advance instruction pointer.
public static function getInt():int {
	return (code[thisSE.IP++]);
}

// Fetch integer without advancing instruction pointer.
public static function peekInt():int {
	return (code[thisSE.IP]);
}

// Fetch string from code sequence; advance instruction pointer.
public static function getString():String {
	return (oop.pStrings[code[thisSE.IP++]]);
}

// Fetch string from an arbitrary code block location.
public static function stringAt(codeBlock:Array, pos:int):String {
	if (pos < 0)
		pos = code[-pos + 1]; // Fast-found label

	return (oop.pStrings[codeBlock[pos]]);
}

// Fetch label location from code sequence; advance instruction pointer.
// Optimizes code at run-time by remembering absolute offset of label,
// which precludes having to parse a string and searching code a second time.
public static function getLabelLoc(myCode:Array):int {
	var i:int = code[thisSE.IP++];
	if (i < 0)
		return -i; // Fast-found label
	else
	{
		// Locate label using search.
		var pos:int = findLabel(myCode, oop.pStrings[i]);
		if (pos != -1 && !typeList[thisSE.TYPE].HasOwnCode)
			code[thisSE.IP-1] = -pos;

		// If custom code present or the label is not found, we don't optimize.
		return pos;
	}
}

// Step directions can be gotten from an 8-directional index.
// This is actually not useful in ZZT most of the time, because
// ZZT is mostly restricted to 4-direction cartesian directions.
public static function getStepXFromDir8(dir:int):int {
	return dir2StepX[dir & 7];
}
public static function getStepYFromDir8(dir:int):int {
	return dir2StepY[dir & 7];
}

// Step directions can be gotten from an 4-directional index.
// A 4-directional index is usually used in ZZT directions.
public static function getStepXFromDir4(dir:int):int {
	return dir2StepX[(dir << 1) & 7];
}
public static function getStepYFromDir4(dir:int):int {
	return dir2StepY[(dir << 1) & 7];
}

// Directional indexes can be gotten from steps (either 4- or 8-dir).
public static function getDir8FromSteps(stepX:int, stepY:int):int {
	var index:int = (stepY+1) * 3 + (stepX+1);
	if (index < 0 || index > 8)
		index = 0;
	return step2Dir8[index];
}
public static function getDir4FromSteps(stepX:int, stepY:int):int {
	var index:int = (stepY+1) * 3 + (stepX+1);
	if (index < 0 || index > 8)
		index = 0;
	return step2Dir4[index];
}

// The base directional index is 256-dir for this special arctangent function.
// The resolution will reduce the actual directions returned to that quantity.
public static function atan2FromSteps(stepX:int, stepY:int, resolution:int):int {
	var index:int = int(Math.atan2(Number(stepY), Number(stepX)) * 128 / Math.PI);
	var arc:int = int(256 / resolution);

	return int(((index + (arc >> 1)) & 255) / arc);
}

// Show error message
public static function errorMsg(str:String):void {
	thisSE.FLAGS |= FL_IDLE;
	oop.errorMsg(str);
	trace(str);
}

// Assign a new unique identifier if needed
public static function assignID(se:SE):void {
	if (se)
	{
		if (se.myID <= 0)
			se.myID = ++nextObjPtrNum;
	}
}

// This is called at various times to dispatch a message from anywhere,
// to any object.  The stack is augmented.
public static function briefDispatch(pos:int, fromSE:SE, toSE:SE):Boolean {
	if (pos == -1)
		return false;

	// Save state
	dispatchStack.push(fromSE.IP);
	dispatchStack.push(fromSE);
	dispatchStack.push(code);

	// Change instruction IP to start of message
	var oldComCount:int = objComCount;
	var oldFlags:int = toSE.FLAGS;
	var oldIP:int = toSE.IP;
	var oldTurns:int = turns;
	toSE.FLAGS = (toSE.FLAGS & ~FL_IDLE) | FL_DISPATCH;
	toSE.IP = pos;
	thisSE = toSE;
	var eInfo:ElementInfo = typeList[toSE.TYPE];
	if (eInfo.HasOwnCode && thisSE.extra.hasOwnProperty("CODEID"))
		code = codeBlocks[thisSE.extra["CODEID"]];
	else
		code = codeBlocks[eInfo.CODEID];

	// Run commands in modified loop
	turns = 0x7FFFFFFF;
	objComCount = 0x70000000;
	while ((thisSE.FLAGS & FL_IDLE) == 0 && turns > 0 && objComCount > 0) {
		if (thisSE.IP >= code.length)
		{
			// Automatic END; end of code.
			thisSE.FLAGS |= FL_IDLE;
			break;
		}

		var cByte:int = getInt();
		if (!processCommand(cByte))
			break;
	}
	Sounds.playVoice();

	if (doDispText == 2)
	{
		// Display text if any shown from dispatched message.
		// Do not try to display text if it originated from normal object execution.
		doDispText = 0;
		displayText(true);
	}

	// If DONEDISPATCH invoked, flags and new location are kept.
	if (!(thisSE.FLAGS & FL_DISPATCH))
	{
		oldFlags = thisSE.FLAGS;
		oldIP = thisSE.IP;
	}

	// Restore state
	code = dispatchStack[dispatchStack.length-1] as Array;
	dispatchStack.pop();
	fromSE = dispatchStack[dispatchStack.length-1] as SE;
	dispatchStack.pop();
	fromSE.IP = dispatchStack[dispatchStack.length-1] as int;
	dispatchStack.pop();
	thisSE = fromSE;

	toSE.FLAGS = oldFlags;
	toSE.IP = oldIP;
	turns = oldTurns;
	objComCount = oldComCount;

	return true;
}

// Dispatch message to main type code
public static function dispatchToMainLabel(labelStr:String):Boolean {
	var retVal:Boolean = briefDispatch(findLabel(codeBlocks[0], labelStr), blankSE, blankSE);
	return retVal;
}

// Dispatch CUSTOMDRAW message to obtain drawing character
public static function dispatchCustomDraw(type:int, x:int, y:int):int {
	customDrawSE.TYPE = type;
	customDrawSE.X = x;
	customDrawSE.Y = y;

	inCustomDraw = true;
	briefDispatch(typeList[type].LocCUSTOMDRAW, thisSE, customDrawSE);
	inCustomDraw = false;

	return customDrawChar;
}

// Either send message (status element) or dispatch message (no status element)
public static function linkFollow(labelStr:String):Boolean {
	if (linkFollowSE == blankSE)
	{
		// Generic link follow after message dispatch.
		return dispatchToMainLabel(labelStr);
	}
	else if (linkFollowSE.TYPE == zzt.fileLinkType)
	{
		// Link follow within HLP file (a file opened from a file link).
		return briefDispatch(findLabel(codeBlocks[codeBlocks.length - 1], labelStr),
			blankSE, linkFollowSE);
	}
	else
	{
		var myCode:int = codeBlocks[linkFollowSE.TYPE];
		if (linkFollowSE.extra.hasOwnProperty("CODEID"))
			myCode = linkFollowSE.extra["CODEID"];
		var pos:int = findLabel(codeBlocks[myCode], labelStr);
		if (pos != -1)
		{
			// Acts as a jump, or "GOTO"
			linkFollowSE.IP = pos;
			linkFollowSE.FLAGS &= ~(FL_IDLE | FL_PENDINGDEAD);
			linkFollowSE.delay = 1;
			return true;
		}
	}

	return false;
}

// This is called when executing code for a status element.
public static function execSECode(forSE:SE):Boolean {
	// Execute code for main iteration.
	var eInfo:ElementInfo = typeList[forSE.TYPE];
	var okResult:Boolean = execElementCode(eInfo, forSE);

	if (okResult && !(forSE.FLAGS & FL_DEAD))
	{
		// Dispatch WALKBEHAVIOR message, if implemented.
		// This occurs even if the status element is idle.
		// It will not occur if the status element is dead.
		okResult = briefDispatch(eInfo.LocWALKBEHAVIOR, blankSE, forSE);
	}

	return okResult;
}

// This is called when executing code in a general sense,
// with or without a status element.
public static function execElementCode(eInfo:ElementInfo, forSE:SE=null):Boolean {
	// There are two types of execution environments:  execution based on status
	// element, and execution based on element type alone.  Both of them are
	// very similar, but some functions are only accessible when run by status
	// elements.
	if (forSE == null)
	{
		// Element type.
		thisSE = blankSE;
		blankSE.CYCLE = 1;
		blankSE.FLAGS = 0;
		blankSE.delay = 0;
	}
	else
	{
		// Status element object.
		thisSE = forSE;
	}

	if (zzt.globalProps["LEGACYTICK"])
	{
		// Legacy tick behavior (ZZT and SZT) uses a master delay counter with
		// the delay implied from CYCLE modulos on the master delay and the
		// index within the SE vector.
		if (thisSE.CYCLE > 0)
		{
			if (zzt.legacyTick % thisSE.CYCLE == zzt.legacyIndex % thisSE.CYCLE)
				thisSE.delay = 1;
			else
				thisSE.delay = 10;
		}
		else
			thisSE.delay = 10;
	}

	// Check under-layer flag.
	if (thisSE.FLAGS & FL_UNDERLAYER)
	{
		// Special "under-layer" status forces a status element to remain
		// ghosted until the square at which it resides has no status element
		// present already.
		if (SE.getStatElemAt(thisSE.X, thisSE.Y) == null)
		{
			// Unghost.
			thisSE.FLAGS &= ~(FL_GHOST + FL_UNDERLAYER);

			// Update square.
			thisSE.moveSelfSquare(thisSE.X, thisSE.Y, false);
			SE.setColor(thisSE.X, thisSE.Y, thisSE.extra["!!ULCOLOR"], false);
			delete thisSE.extra["!!ULCOLOR"];
			thisSE.displaySelfSquare();
		}

		return true;
	}

	// Check delay.  Note that we update the delay counter even if the idle flag
	// is set, because WALKBEHAVIOR iterates only as frequently as the cycle would
	// also iterate for the main iteration.
	if (--thisSE.delay > 0)
	{
		// Nothing to do, since cycle delay will do nothing this time around.
		return false;
	}

	// Reset delay to equal cycle.
	thisSE.delay = thisSE.CYCLE;

	// Check idle flag.
	if (thisSE.FLAGS & FL_IDLE)
	{
		// Nothing to do.
		return true;
	}

	// Identify the code portion.  This will also depend on whether a status
	// element is present, because status elements can potentially point to a
	// different code block than the element type.
	if (eInfo.HasOwnCode && thisSE.extra.hasOwnProperty("CODEID"))
	{
		// Custom code (OBJECT, SCROLL).  Subject to limited number of #commands.
		code = codeBlocks[thisSE.extra["CODEID"]];
		objComThreshold = zzt.globalProps["OBJMAGICNUMBER"];
		objComCount = objComThreshold;
	}
	else
	{
		// Normal code.  Not subject to limited number of #commands.
		code = codeBlocks[eInfo.CODEID];
		objComCount = 0x70000000;
	}

	// Now we can repeatedly execute statements in the code portion until we
	// reach a stopping point.
	turns = 1;
	scriptDeadlockCount = 0;
	while ((thisSE.FLAGS & FL_IDLE) == 0 && turns > 0 && objComCount > 0) {
		if (thisSE.IP >= code.length)
		{
			// Automatic END; end of code.
			thisSE.IP = typeList[thisSE.TYPE].CustomStart;
			thisSE.FLAGS |= FL_IDLE;
			//thisSE.delay = thisSE.CYCLE;
			break;
		}

		var cByte:int = getInt();
		if (!processCommand(cByte))
			return false;
		else if (scriptDeadlockCount > SCRIPT_DEADLOCK_THRESHOLD)
		{
			if (zzt.globalProps["DETECTSCRIPTDEADLOCK"])
			{
				// Deadlock condition causes automatic end of turns.
				return true;
			}
		}
	}

	// Show text if text needs to be displayed.
	if (doDispText)
	{
		doDispText = 0;
		displayText(false);
	}

	return true;
}

// Process a compiled bytecode command.
public static function processCommand(cByte:int):Boolean {
	var tx:int;
	var ty:int;
	var pos:int;
	var pos2:int;
	var obj1:Object;
	var obj2:Object;
	var d:int;
	var kind1:int;
	var kind2:int;
	var dir:int;

	var relSE:SE;
	var relSE2:SE;

	var str:String;
	var str2:String;

	switch (cByte) {
		// Name, label, and comments
		case oop.CMD_NOP:
			// Nothing to do
		break;
		case oop.CMD_NAME:
			thisSE.extra["ONAME"] = getString();
		break;
		case oop.CMD_LABEL:
			thisSE.IP += 2; // Label is ignored
		break;
		case oop.CMD_COMMENT:
			thisSE.IP += 2; // Comment is ignored
		break;
		case oop.CMD_ERROR:
			errorMsg("COMMAND ERROR:  " + getString());
			opcodeTraceback(code, thisSE.IP);
		break;

		// Text display (possibly interactive)
		case oop.CMD_TEXT:
		case oop.CMD_TEXTCENTER:
		case oop.CMD_TEXTLINK:
		case oop.CMD_TEXTLINKFILE:
		case oop.CMD_DYNTEXT:
		case oop.CMD_DYNLINK:
		case oop.CMD_SCROLLSTR:
			if (!processText(cByte))
				return false;
		break;
		case oop.CMD_DYNTEXTVAR:
			str = getString();
			str2 = dynFormatString(getString());
			zzt.globals[str] = str2;
		break;
		case oop.CMD_DUMPSE:
			processText(cByte);
			pos = intGetExpr();
			relSE = SE.getStatElem(pos);
			if (relSE)
				dumpSE(relSE);
			else
				zzt.addMsgLine("", "Not a valid status element:  " + pos.toString());
		break;
		case oop.CMD_DUMPSEAT:
			processText(cByte);
			getCoords(coords1);
			tx = coords1[0];
			ty = coords1[1];
			relSE = SE.getStatElemAt(tx, ty);
			if (relSE)
				dumpSE(relSE);
			else
				zzt.addMsgLine("", "Not a valid status element at " + tx + "," + ty);
		break;
		case oop.CMD_TEXTTOGUI:
			str = getString();
			if (str == "NONE")
				textTarget = TEXT_TARGET_NORM;
			else
			{
				textTarget = TEXT_TARGET_GUI;
				textDestLabel = str;
			}
		break;
		case oop.CMD_TEXTTOGRID:
			str = regionGetExpr(); // Region name
			textDestType = intGetExpr();
			if (str == "NONE")
				textTarget = TEXT_TARGET_NORM;
			else
			{
				textTarget = TEXT_TARGET_GRID;
				textDestLabel = str;
			}
		break;
		case oop.CMD_SCROLLCOLOR:
			zzt.setScrollColors(intGetExpr(), intGetExpr(), intGetExpr(),
				intGetExpr(), intGetExpr(), intGetExpr(), intGetExpr());
		break;

		// Movement
		case oop.CMD_GO:
			turns--;
			objComCount -= objComThreshold;
			pos = thisSE.IP - 1;
			d = getDir();
			if (d != -1)
			{
				tx = thisSE.X + getStepXFromDir4(d);
				ty = thisSE.Y + getStepYFromDir4(d);
				if (thisSE.FLAGS & FL_GHOST)
				{
					// Ghost movement always succeeds
					thisSE.X = tx;
					thisSE.Y = ty;
				}
				else if (validXY(tx, ty))
				{
					if (!typeList[SE.getType(tx, ty)].BlockObject)
					{
						// Easy move; non-blocking square.
						thisSE.moveSelfSquare(tx, ty);
					}
					else if (thisSE.TYPE == zzt.objectType &&
						SE.getType(tx, ty) == zzt.transporterType &&
						zzt.globalProps["TELOBJECT"] == 0)
					{
						// By default, OBJECTs can't do anything special when
						// interacting with transporters.
						thisSE.IP = pos;
					}
					else if (assessPushability(tx, ty, d, false))
					{
						// Move without squashing.
						pushItems(tx, ty, d, false);
						thisSE.moveSelfSquare(tx, ty);
					}
					else if (assessPushability(tx, ty, d, true))
					{
						if (zzt.globals["$ALLPUSH"] != 1 &&
							wouldSquashX == tx && wouldSquashY == ty)
						{
							// Unable to squash this time because we don't
							// allow point-blank squashing.
							thisSE.IP = pos;
						}
						else
						{
							// Move with squashing.
							pushItems(tx, ty, d, true);
							thisSE.moveSelfSquare(tx, ty);
						}
					}
					else
					{
						// We can't move; wait at this instruction until
						// move is possible.
						thisSE.IP = pos;
					}
				}
				else
				{
					// Board edge; wait indefinitely.
					thisSE.IP = pos;
				}
			}
		break;
		case oop.CMD_FORCEGO:
			turns--;
			objComCount -= objComThreshold;
			d = getDir();
			if (d != -1)
			{
				tx = thisSE.X + getStepXFromDir4(d);
				ty = thisSE.Y + getStepYFromDir4(d);
				if (thisSE.FLAGS & FL_GHOST)
				{
					// Ghost movement always succeeds
					thisSE.X = tx;
					thisSE.Y = ty;
				}
				else if (validXY(tx, ty))
				{
					killSE(tx, ty);
					thisSE.moveSelfSquare(tx, ty);
				}
			}
		break;
		case oop.CMD_TRY:
			turns--;
			objComCount -= objComThreshold;
			d = getDir();
			thisSE.IP++;
			pos2 = getInt(); // Jump-over location
			if (d != -1)
			{
				tx = thisSE.X + getStepXFromDir4(d);
				ty = thisSE.Y + getStepYFromDir4(d);
				if (thisSE.FLAGS & FL_GHOST)
				{
					// Ghost movement always succeeds
					thisSE.X = tx;
					thisSE.Y = ty;
					thisSE.IP = pos2; // Jump over alternate command
				}
				else if (validXY(tx, ty))
				{
					if (!typeList[SE.getType(tx, ty)].BlockObject)
					{
						// Easy move; non-blocking square.
						thisSE.moveSelfSquare(tx, ty);
						thisSE.IP = pos2; // Jump over alternate command
					}
					else if (thisSE.TYPE == zzt.objectType &&
						SE.getType(tx, ty) == zzt.transporterType &&
						zzt.globalProps["TELOBJECT"] == 0)
					{
						// By default, OBJECTs can't do anything special when
						// interacting with transporters.
						turns++;
						objComCount += objComThreshold - 1;
					}
					else if (assessPushability(tx, ty, d, false))
					{
						// Move without squashing.
						pushItems(tx, ty, d, false);
						thisSE.moveSelfSquare(tx, ty);
						thisSE.IP = pos2; // Jump over alternate command
					}
					else if (assessPushability(tx, ty, d, true))
					{
						if (zzt.globals["$ALLPUSH"] != 1 &&
							wouldSquashX == tx && wouldSquashY == ty)
						{
							// Unable to squash this time because we don't
							// allow point-blank squashing.
							turns++;
							objComCount += objComThreshold - 1;
						}
						else
						{
							// Move with squashing.
							pushItems(tx, ty, d, true);
							thisSE.moveSelfSquare(tx, ty);
							thisSE.IP = pos2; // Jump over alternate command
						}
					}
					else
					{
						// We can't move; execute alternate command.
						objComCount += objComThreshold - 1;
						turns++;
					}
				}
				else
				{
					// We can't move; execute alternate command.
					objComCount += objComThreshold - 1;
					turns++;
				}
			}
		break;
		case oop.CMD_TRYSIMPLE:
			turns--;
			objComCount -= objComThreshold;
			d = getDir();
			if (d != -1)
			{
				tx = thisSE.X + getStepXFromDir4(d);
				ty = thisSE.Y + getStepYFromDir4(d);
				if (thisSE.FLAGS & FL_GHOST)
				{
					// Ghost movement always succeeds
					thisSE.X = tx;
					thisSE.Y = ty;
				}
				else if (validXY(tx, ty))
				{
					if (!typeList[SE.getType(tx, ty)].BlockObject)
					{
						// Easy move; non-blocking square.
						thisSE.moveSelfSquare(tx, ty);
					}
					else if (thisSE.TYPE == zzt.objectType &&
						SE.getType(tx, ty) == zzt.transporterType &&
						zzt.globalProps["TELOBJECT"] == 0)
					{
						// By default, OBJECTs can't do anything special when
						// interacting with transporters.
					}
					else if (assessPushability(tx, ty, d, false))
					{
						// Move without squashing.
						pushItems(tx, ty, d, false);
						thisSE.moveSelfSquare(tx, ty);
					}
					else if (assessPushability(tx, ty, d, true))
					{
						if (zzt.globals["$ALLPUSH"] != 1 &&
							wouldSquashX == tx && wouldSquashY == ty)
						{
							// Unable to squash this time because we don't
							// allow point-blank squashing.
						}
						else
						{
							// Move with squashing.
							pushItems(tx, ty, d, true);
							thisSE.moveSelfSquare(tx, ty);
						}
					}
				}
			}
		break;
		case oop.CMD_PUSHATPOS:
			getCoords(coords1);
			d = getDir();
			if (validCoords(coords1))
			{
				tx = coords1[0];
				ty = coords1[1];
				if (typeList[SE.getType(tx, ty)].BlockObject)
				{
					if (assessPushability(tx, ty, d, false))
					{
						// Push without squashing.
						pushItems(tx, ty, d, false);
					}
					else if (assessPushability(tx, ty, d, true))
					{
						// Push with squashing.
						pushItems(tx, ty, d, true);
					}
				}
			}
		break;
		case oop.CMD_WALK:
			d = getDir();
			objComCount--;
			if (d == -1)
			{
				thisSE.STEPX = 0;
				thisSE.STEPY = 0;
			}
			else
			{
				thisSE.STEPX = getStepXFromDir4(d);
				thisSE.STEPY = getStepYFromDir4(d);
			}
		break;

		// Status mods
		case oop.CMD_PAUSE:
			zzt.activeObjs = false;
		break;
		case oop.CMD_UNPAUSE:
			zzt.activeObjs = true;
		break;
		case oop.CMD_ENDGAME:
			objComCount--;
			pos = findLabel(codeBlocks[0], "$ENDGAME");
			briefDispatch(pos, thisSE, blankSE);
		break;
		case oop.CMD_END:
			objComCount--;
			thisSE.IP = typeList[thisSE.TYPE].CustomStart;
			thisSE.FLAGS |= FL_IDLE;
			//if ((thisSE.FLAGS & FL_DISPATCH) == 0)
			//	thisSE.delay = thisSE.CYCLE;
		break;
		case oop.CMD_RESTART:
			thisSE.IP = typeList[thisSE.TYPE].CustomStart;
			if (typeList[thisSE.TYPE].HasOwnCode && thisSE.extra.hasOwnProperty("CODEID"))
				code = codeBlocks[thisSE.extra["CODEID"]];
			else
				code = codeBlocks[typeList[thisSE.TYPE].CODEID];
			scriptDeadlockCount++;
			objComCount--;
		break;
		case oop.CMD_LOCK:
			objComCount--;
			thisSE.FLAGS |= FL_LOCKED;
		break;
		case oop.CMD_UNLOCK:
			objComCount--;
			thisSE.FLAGS &= ~FL_LOCKED;
		break;
		case oop.CMD_EXTRATURNS:
			pos = intGetExpr();
			turns += pos;
			objComCount += pos * objComThreshold;
		break;
		case oop.CMD_SUSPENDDISPLAY:
			SE.suspendDisp = intGetExpr();
		break;
		case oop.CMD_DIE:
			if (doDispText && zzt.numTextLines > zzt.toastMsgSize)
			{
				// Important:  if this happens immediately after display of
				// scroll-interface text, don't die "yet" because of importance
				// of state info.  Instead, just stop short of actual command,
				// which will be executed on the next iteration.
				thisSE.IP--;
				turns = 0;
				thisSE.FLAGS |= FL_PENDINGDEAD;
			}
			else
			{
				if (thisSE.TYPE == zzt.objectType && zzt.globalProps["OBJECTDIEEMPTY"])
				{
					// The OBJECT type leaves behind a white empty when #DIE called.
					thisSE.UNDERID = 0;
					thisSE.UNDERCOLOR = 15;
				}

				thisSE.FLAGS |= FL_IDLE + FL_DEAD;
				thisSE.eraseSelfSquare(true);
			}
		break;
		case oop.CMD_SAVEBOARD:
			// TBD:  -1=wipe all; 0=manual save; 1=board change save; 2=zap save; 3=auto save
			pos = intGetExpr();
			switch (pos) {
				case -1:
					ZZTLoader.wipeBoardStates();
					ZZTLoader.rewindZapRecord(-1);
					ZZTLoader.resetGlobalProps(ZZTLoader.saveStates[0]);
					zzt.globalProps["GAMESPEED"] = zzt.gameSpeed;
					zzt.pMoveDir = -1;
					zzt.pShootDir = -1;
				break;
				default:
					ZZTLoader.saveBoardState(pos);
				break;
			}
		break;
		case oop.CMD_SAVEWORLD:
			pos = intGetExpr();
			zzt.modeChanged = true;
			zzt.mainMode = zzt.MODE_LOADSAVEWAIT;

			// Pack world and board data into file
			if (pos == 0)
			{
				if (ZZTLoader.saveWAD(".WAD"))
				{
					// Open dialog to save as ordinary WAD
					parse.saveLocalFile(
						".WAD", zzt.MODE_NORM, zzt.MODE_NORM, ZZTLoader.file);
				}
				else
					zzt.mainMode = zzt.MODE_NORM;
			}
			else
			{
				if (ZZTLoader.saveWAD(".SAV"))
				{
					// Open dialog to save as savegame
					parse.saveLocalFile(
						"SAVED.SAV", zzt.MODE_NORM, zzt.MODE_NORM, ZZTLoader.file);
				}
				else
					zzt.mainMode = zzt.MODE_NORM;
			}
		break;
		case oop.CMD_LOADWORLD:
			obj1 = getExpr();
			zzt.modeChanged = true;
			zzt.mainMode = zzt.MODE_LOADSAVEWAIT;

			if (obj1 is int)
			{
				pos = int(obj1);
				if (pos == -1)
					parse.loadLocalFile("ZZT", zzt.MODE_NATIVELOADZZT, zzt.MODE_NORM);
				else if (pos == -2)
					parse.loadLocalFile("SZT", zzt.MODE_NATIVELOADSZT, zzt.MODE_NORM);
				else if (pos == -3)
					parse.loadLocalFile("WAD", zzt.MODE_LOADWAD, zzt.MODE_NORM);
				else if (pos == -4)
					parse.loadLocalFile("ZIP", zzt.MODE_LOADZIP, zzt.MODE_NORM);
				else if (pos == 1)
					zzt.launchDeployedFileIfPresent(zzt.featuredWorldFile);
				else
					zzt.loadDeployedFile(zzt.MODE_NORM);
			}
			else
			{
				zzt.launchDeployedFileIfPresent(obj1.toString());
			}
		break;
		case oop.CMD_RESTOREGAME:
			pos = intGetExpr();

			// Pack world and board data into file
			if (pos == 2)
			{
				// Open dialog to load SAV file
				zzt.modeChanged = true;
				zzt.mainMode = zzt.MODE_LOADSAVEWAIT;
				parse.loadLocalFile("SAV", zzt.MODE_RESTOREWADFILE, zzt.MODE_NORM);
			}
			else
			{
				// Alternate "scroll" interface for snapshot-based board restore
				zzt.snapshotRestoreScroll(pos == 0);
			}
		break;
		case oop.CMD_UPDATELIT:
			updateLit();
		break;
		case oop.CMD_SETPLAYER:
			pos = intGetExpr(); // Object pointer
			relSE = SE.getStatElem(pos);
			if (relSE)
			{
				playerSE = relSE;
				assignID(playerSE);
				zzt.globals["$PLAYER"] = playerSE.myID;
			}
			else
			{
				playerSE = null;
				zzt.globals["$PLAYER"] = -1;
			}
		break;
		case oop.CMD_BIND:
			str = getString();
			relSE = getSEFromOName(str);
			if (!relSE)
			{
				//errorMsg("Bad #BIND:  " + str);
				return false;
			}

			if (!relSE.extra.hasOwnProperty("CODEID"))
			{
				errorMsg("#BIND can't be used with non-unique code");
				return false;
			}

			// Object now resembles another type:  code is swapped out,
			// object name is removed (and eventually replaced), and
			// instruction pointer reset to start.
			thisSE.extra["CODEID"] = relSE.extra["CODEID"];
			delete thisSE.extra["ONAME"];
			code = codeBlocks[thisSE.extra["CODEID"]];
			thisSE.IP = typeList[thisSE.TYPE].CustomStart;
			//thisSE.delay = thisSE.CYCLE;
			objComCount--;
		break;
		case oop.CMD_BECOME:
			if (doDispText && zzt.numTextLines > zzt.toastMsgSize)
			{
				// Important:  if this happens immediately after display of
				// scroll-interface text, don't die "yet" because of importance
				// of state info.  Instead, just stop short of actual command,
				// which will be executed on the next iteration.
				thisSE.IP--;
				turns = 0;
			}
			else
			{
				kind1 = getKind();
				tx = thisSE.X;
				ty = thisSE.Y;

				// Auto-whiten if all black
				if (SE.getColor(tx, ty) == 0)
					SE.setColor(tx, ty, 15, false);

				relSE = createKind(tx, ty, kind1, CF_RETAINSE);
				if (relSE)
					relSE.displaySelfSquare();
			}
		break;

		// Messages
		case oop.CMD_SEND:
			pos = getLabelLoc(code);
			objComCount--;
			if (pos != -1)
			{
				// Acts as a jump, or "GOTO"
				thisSE.IP = pos;
				thisSE.FLAGS &= ~FL_IDLE;
				scriptDeadlockCount++;
			}
		break;
		case oop.CMD_SENDTONAME:
			objComCount--;
			str2 = getString();
			str = getString();
			relSE = getSEFromOName(str2);
			if (!relSE)
				break; // No destination

			do {
				if (relSE.extra.hasOwnProperty("CODEID"))
					pos = findLabel(codeBlocks[relSE.extra["CODEID"]], str);
				else
					pos = findLabel(codeBlocks[typeList[relSE.TYPE].CODEID], str);

				// Sent messages respect lock status, EXCEPT if the message
				// would reach self (an object never locks "itself" out of messages).
				if ((relSE.FLAGS & (FL_LOCKED | FL_PENDINGDEAD)) == 0 || relSE == thisSE)
				{
					if (pos != -1)
					{
						// Acts as a remote jump, or "GOTO"
						relSE.IP = pos;
						relSE.FLAGS &= ~FL_IDLE;
						//relSE.delay = 1;
						if (thisSE == relSE)
							scriptDeadlockCount++;
					}
					else if (str == "RESTART")
					{
						// Can trigger remote-restart
						relSE.IP = typeList[relSE.TYPE].CustomStart;
						relSE.FLAGS &= ~FL_IDLE;
						//relSE.delay = 1;
						if (thisSE == relSE)
							scriptDeadlockCount++;
					}
				}

				relSE = getSEFromOName(str2, false);
			} while (relSE);
		break;
		case oop.CMD_SENDTO:
			pos = intGetExpr(); // Object pointer
			relSE = SE.getStatElem(pos);
			str = getString();

			if (relSE)
			{
				if (relSE.extra.hasOwnProperty("CODEID"))
					pos = findLabel(codeBlocks[relSE.extra["CODEID"]], str);
				else
					pos = findLabel(codeBlocks[typeList[relSE.TYPE].CODEID], str);

				// Sent messages respect lock status.
				if (pos != -1 && (relSE.FLAGS & (FL_LOCKED | FL_PENDINGDEAD)) == 0)
				{
					// Acts as a remote jump, or "GOTO"
					relSE.IP = pos;
					relSE.FLAGS &= ~FL_IDLE;
					//relSE.delay = 1;
					scriptDeadlockCount++;
				}
			}
		break;
		case oop.CMD_DISPATCH:
			pos = getLabelLoc(codeBlocks[0]);
			briefDispatch(pos, thisSE, blankSE);
		break;
		case oop.CMD_DISPATCHTO:
			pos = intGetExpr(); // Object pointer
			relSE = SE.getStatElem(pos);
			if (relSE)
			{
				// Dispatched messages ignore lock status.
				if (relSE.extra.hasOwnProperty("CODEID"))
					pos = findLabel(codeBlocks[relSE.extra["CODEID"]], getString());
				else
					pos = findLabel(codeBlocks[typeList[relSE.TYPE].CODEID], getString());
				briefDispatch(pos, thisSE, relSE);
			}
			else
				getInt();
		break;

		// Type mods and placement
		case oop.CMD_SPAWN:
			d = getInt();
			getCoords(coords1);
			kind1 = getKind();
			if (!validCoords(coords1))
				errorMsg("#SPAWN:  Invalid coordinates");
			else if (d == oop.DIR_UNDER)
			{
				// Start element in under-layer at current position.
				relSE = createKind(coords1[0], coords1[1], kind1,
					CF_RETAINCOLOR | CF_GHOSTED | CF_UNDERLAYER);
				if (relSE)
				{
					relSE.FLAGS |= FL_UNDERLAYER;
					relSE.extra["!!ULCOLOR"] = lastKindColor;
					assignID(relSE);
				}
			}
			else
			{
				if (d == oop.DIR_OVER)
				{
					// Automatically move existing SE to under-layer.
					relSE = SE.getStatElemAt(coords1[0], coords1[1]);
					if (relSE)
					{
						relSE.extra["!!ULCOLOR"] = SE.getColor(coords1[0], coords1[1]);
						relSE.eraseSelfSquare();
						relSE.FLAGS |= FL_GHOST | FL_UNDERLAYER;
					}
				}

				relSE = createKind(coords1[0], coords1[1], kind1, CF_RETAINCOLOR);
				if (relSE)
					relSE.displaySelfSquare();
			}
		break;
		case oop.CMD_SPAWNGHOST:
			str = getExprRef();
			d = lastExprType;
			getCoords(coords1);
			kind1 = getKind();
			if (!validCoords(coords1))
				errorMsg("#SPAWNGHOST:  Invalid coordinates");
			else
			{
				relSE = createKind(coords1[0], coords1[1], kind1, CF_RETAINCOLOR | CF_GHOSTED);
				if (relSE)
				{
					assignID(relSE);
					setVariableFromRef(d, str, relSE.myID);
				}
			}
		break;
		case oop.CMD_PUT:
			objComCount--;
			d = getDir();
			kind1 = getKind();

			if (d == oop.DIR_UNDER)
			{
				// Start element in under-layer at current position.
				relSE = createKind(thisSE.X, thisSE.Y, kind1,
					CF_RETAINCOLOR | CF_GHOSTED | CF_UNDERLAYER);
				if (relSE)
				{
					relSE.FLAGS |= FL_UNDERLAYER;
					relSE.extra["!!ULCOLOR"] = lastKindColor;
					assignID(relSE);
				}
				break;
			}

			if (d == oop.DIR_OVER)
			{
				// Automatically move self to under-layer.
				if ((thisSE.FLAGS & FL_GHOST) == 0)
				{
					thisSE.extra["!!ULCOLOR"] = SE.getColor(thisSE.X, thisSE.Y);
					thisSE.eraseSelfSquare();
					thisSE.FLAGS |= FL_GHOST | FL_UNDERLAYER;
				}

				tx = thisSE.X;
				ty = thisSE.Y;
			}
			else
			{
				tx = thisSE.X + getStepXFromDir4(d);
				ty = thisSE.Y + getStepYFromDir4(d);
				if (zzt.globalProps["NOPUTBOTTOMROW"])
				{
					if (!validXYM1(tx, ty) || d == -1)
						break;
				}
				else if (!validXY(tx, ty) || d == -1)
				{
					break;
				}
	
				pos = SE.getType(tx, ty);
				if (typeList[pos].BlockObject && typeList[pos].Pushable != 0)
				{
					if (assessPushability(tx, ty, d, false))
					{
						// Push without squashing.
						pushItems(tx, ty, d, false);
					}
					else if (assessPushability(tx, ty, d, true))
					{
						// Push with squashing, unless point-blank would be squashed.
						if (wouldSquashX != tx || wouldSquashY != ty)
							pushItems(tx, ty, d, true);
					}
					else if (typeList[pos].NUMBER == 4)
					{
						// Can't overwrite player.
						break;
					}
				}
			}

			// Auto-whiten if all black
			if (SE.getColor(tx, ty) == 0)
				SE.setColor(tx, ty, 15, false);

			relSE = createKind(tx, ty, kind1,
				CF_RETAINSE | CF_RETAINCOLOR | CF_REMOVEIFBLOCKING);

			if (relSE)
			{
				relSE.displaySelfSquare();
				if (relSE.TYPE == zzt.playerType)
					zzt.boardProps["PLAYERCOUNT"]++;
			}
		break;
		case oop.CMD_SHOOT:
			objComCount--;
			turns--;
			pos = getInt(); // Silence flag
			d = getDir();
			tx = thisSE.X + getStepXFromDir4(d);
			ty = thisSE.Y + getStepYFromDir4(d);
			if (validXY(tx, ty))
			{
				kwargPos = -1;
				pos2 = SE.getType(tx, ty);

				if (!typeList[pos2].BlockObject || typeList[pos2].NUMBER == 19)
				{
					// Shoot if not blocked point-blank
					relSE = createKind(tx, ty, zzt.bulletType);
					if (relSE)
					{
						relSE.STEPX = getStepXFromDir4(d);
						relSE.STEPY = getStepYFromDir4(d);
						relSE.displaySelfSquare();
					}
					if (pos != 0)
						Sounds.soundDispatch("OBJECTSHOOT");
				}
				else
				{
					// Point-blank behavior
					if (pos2 == zzt.playerType)
					{
						// Hurt player
						relSE = SE.getStatElemAt(tx, ty);
						pos = findLabel(codeBlocks[typeList[pos2].CODEID], "RECVHURT");
						briefDispatch(pos, thisSE, relSE);
					}
					else if (pos2 == zzt.breakableType)
					{
						Sounds.soundDispatch("BREAKABLEHIT");
						SE.setType(tx, ty, 0);
						SE.displaySquare(tx, ty);
					}
					else if (pos2 == zzt.objectType && zzt.globalProps["POINTBLANKFIRING"])
					{
						// Object receives shot message if configured to do so.
						// Original ZZT behavior did not generate SHOT message.
						relSE = SE.getStatElemAt(tx, ty);
						if (relSE.extra.hasOwnProperty("CODEID"))
							pos = findLabel(codeBlocks[relSE.extra["CODEID"]], "SHOT");
						else
							pos = findLabel(codeBlocks[typeList[pos2].CODEID], "SHOT");

						if (pos != -1 && (relSE.FLAGS & (FL_LOCKED | FL_PENDINGDEAD)) == 0)
						{
							// Acts as a remote jump, or "GOTO"
							relSE.IP = pos;
							relSE.FLAGS &= ~FL_IDLE;
							//relSE.delay = 1;
						}
					}
				}
			}
		break;
		case oop.CMD_THROWSTAR:
			objComCount--;
			turns--;
			pos = getInt(); // Silence flag
			d = getDir();
			tx = thisSE.X + getStepXFromDir4(d);
			ty = thisSE.Y + getStepYFromDir4(d);
			if (validXY(tx, ty))
			{
				kwargPos = -1;
				pos2 = SE.getType(tx, ty);

				if (!typeList[pos2].BlockObject || typeList[pos2].NUMBER == 19)
				{
					// Shoot if not blocked point-blank
					relSE = createKind(tx, ty, zzt.starType);
					if (relSE)
					{
						relSE.STEPX = getStepXFromDir4(d);
						relSE.STEPY = getStepYFromDir4(d);
						relSE.extra['P2'] = 50;
						relSE.displaySelfSquare();
					}
				}
				else
				{
					// Point-blank behavior
					if (pos2 == zzt.playerType)
					{
						// Hurt player
						relSE = SE.getStatElemAt(tx, ty);
						pos = findLabel(codeBlocks[typeList[pos2].CODEID], "RECVHURT");
						briefDispatch(pos, thisSE, relSE);
					}
					else if (pos2 == zzt.breakableType)
					{
						Sounds.soundDispatch("ENEMYDIE");
						SE.setType(tx, ty, 0);
						SE.displaySquare(tx, ty);
					}
				}
			}
		break;
		case oop.CMD_CHANGE:
			objComCount--;
			processChange(noRegion);
		break;
		case oop.CMD_CHANGEREGION:
			str = regionGetExpr(); // Region name
			processChange(getRegion(str));
		break;
		case oop.CMD_KILLPOS:
			getCoords(coords1);
			relSE = SE.getStatElemAt(coords1[0], coords1[1]);
			if (relSE)
			{
				killSE(coords1[0], coords1[1]);
				SE.displaySquare(coords1[0], coords1[1]);
			}
		break;
		case oop.CMD_SETPOS:
			pos = intGetExpr(); // Object pointer
			pos2 = getInt(); // DIR_UNDER

			getCoords(coords1);
			relSE2 = SE.getStatElem(pos);

			if (!relSE2)
			{
				// No valid source; can still destroy destination.
				if (validCoords(coords1, true))
				{
					relSE = SE.getStatElemAt(coords1[0], coords1[1]);
					if (relSE)
					{
						killSE(coords1[0], coords1[1]);
						SE.displaySquare(coords1[0], coords1[1]);
					}
				}
			}
			else if (relSE2.FLAGS & FL_GHOST)
			{
				// Ghost movement always succeeds
				relSE2.X = coords1[0];
				relSE2.Y = coords1[1];
			}
			else if (validCoords(coords1, true))
			{
				// Valid source; not ghosted.
				relSE = SE.getStatElemAt(coords1[0], coords1[1]);
				if (relSE != relSE2)
				{
					if (pos2 == oop.DIR_UNDER)
					{
						// Go to under-layer.
						lastKindColor = SE.getColor(relSE2.X, relSE2.Y);
						relSE2.eraseSelfSquare();
						relSE2.FLAGS |= FL_GHOST | FL_UNDERLAYER;
						relSE2.X = coords1[0];
						relSE2.Y = coords1[1];
						relSE2.extra["!!ULCOLOR"] = lastKindColor;
					}
					else if (pos2 == oop.DIR_OVER)
					{
						// Move destination to under-layer, then move source.
						relSE.extra["!!ULCOLOR"] = SE.getColor(coords1[0], coords1[1]);
						relSE.eraseSelfSquare();
						relSE.FLAGS |= FL_GHOST | FL_UNDERLAYER;
						relSE2.moveSelfSquare(coords1[0], coords1[1]);
					}
					else
					{
						// Kill destination, then move source.
						killSE(coords1[0], coords1[1]);
						relSE2.moveSelfSquare(coords1[0], coords1[1]);
					}
				}
				else
				{
					// Move status element
					relSE2.moveSelfSquare(coords1[0], coords1[1]);
				}
			}
		break;

		// Variables
		case oop.CMD_CHAR:
			objComCount--;
			if (inCustomDraw)
				customDrawChar = intGetExpr();
			else
			{
				pos = intGetExpr();
				if (pos >= 0 && pos <= 255)
				{
					thisSE.extra["CHAR"] = pos;
					thisSE.displaySelfSquare();
				}
			}
		break;
		case oop.CMD_CYCLE:
			objComCount--;
			thisSE.CYCLE = int(utils.clipval(intGetExpr(), 1, 65535));
			thisSE.delay = ((thisSE.delay - 1) % thisSE.CYCLE) + 1;
		break;
		case oop.CMD_COLOR:
			if (inCustomDraw)
				customDrawColor = intGetExpr();
			else
			{
				SE.setColor(thisSE.X, thisSE.Y, intGetExpr());
				thisSE.displaySelfSquare();
			}
		break;
		case oop.CMD_COLORALL:
			if (inCustomDraw)
				customDrawColor = intGetExpr();
			else
			{
				SE.setColor(thisSE.X, thisSE.Y, intGetExpr(), false);
				thisSE.displaySelfSquare();
			}
		break;
		case oop.CMD_TYPEAT:
			str = getExprRef();
			d = lastExprType;
			getCoords(coords1);
			if (validCoords(coords1, true))
			{
				setVariableFromRef(d, str,
					typeList[SE.getType(coords1[0], coords1[1])].NUMBER);
			}
		break;
		case oop.CMD_COLORAT:
			str = getExprRef();
			d = lastExprType;
			getCoords(coords1);
			if (validCoords(coords1, true))
			{
				setVariableFromRef(d, str, SE.getColor(coords1[0], coords1[1]));
			}
		break;
		case oop.CMD_OBJAT:
			str = getExprRef();
			d = lastExprType;
			getCoords(coords1);
			relSE = SE.getStatElemAt(coords1[0], coords1[1]);
			if (relSE == null || !validCoords(coords1))
				setVariableFromRef(d, str, -1);
			else
			{
				assignID(relSE);
				setVariableFromRef(d, str, relSE.myID);
			}
		break;
		case oop.CMD_LITAT:
			str = getExprRef();
			d = lastExprType;
			getCoords(coords1);
			if (validCoords(coords1))
			{
				setVariableFromRef(d, str, SE.getLit(coords1[0], coords1[1]));
			}
		break;
		case oop.CMD_LIGHTEN:
			getCoords(coords1);
			if (validCoords(coords1))
				adjustLit(coords1, 1);
		break;
		case oop.CMD_DARKEN:
			getCoords(coords1);
			if (validCoords(coords1))
				adjustLit(coords1, 0);
		break;
		case oop.CMD_CHANGEBOARD:
			pos = intGetExpr();
			ZZTLoader.switchBoard(pos);
		break;
		case oop.CMD_CHAR4DIR:
			dir = getDir() & 3;
			pos = intGetExpr();
			pos2 = pos;
			//if (dir == 0)
				//pos2 = pos;
			pos = intGetExpr();
			if (dir == 1)
				pos2 = pos;
			pos = intGetExpr();
			if (dir == 2)
				pos2 = pos;
			pos = intGetExpr();
			if (dir == 3)
				pos2 = pos;

			if (inCustomDraw)
				customDrawChar = pos2;
			else
			{
				thisSE.extra["CHAR"] = pos2;
				thisSE.displaySelfSquare();
			}
		break;
		case oop.CMD_DIR2UVECT8:
			dir = intGetExpr();
			str = getExprRef();
			setVariableFromRef(lastExprType, str, getStepXFromDir8(dir));
			str = getExprRef();
			setVariableFromRef(lastExprType, str, getStepYFromDir8(dir));
		break;
		case oop.CMD_OFFSETBYDIR:
			getRelCoords(coords1);
			dir = thisSE.IP;
			pos = intGetExpr();
			pos2 = intGetExpr();
			thisSE.IP = dir;
			str = getExprRef();
			setVariableFromRef(lastExprType, str, pos + coords1[0]);
			str = getExprRef();
			setVariableFromRef(lastExprType, str, pos2 + coords1[1]);
		break;
		case oop.CMD_CLONE:
			getCoords(coords1);
			if (validCoords(coords1))
			{
				cloneType = SE.getType(coords1[0], coords1[1]);
				cloneColor = SE.getColor(coords1[0], coords1[1]);
				cloneSE = SE.getStatElemAt(coords1[0], coords1[1]);
			}
		break;
		case oop.CMD_SETREGION:
			str = regionGetExpr(); // Region name
			getCoords(coords1);
			getCoords(coords2);
			if (validCoords(coords1) && validCoords(coords2))
				zzt.regions[str] = [ [ coords1[0], coords1[1] ], [ coords2[0], coords2[1] ] ];
		break;
		case oop.CMD_CLEARREGION:
			str = regionGetExpr(); // Region name
			if (zzt.regions.hasOwnProperty(str))
				delete zzt.regions[str];
		break;
		case oop.CMD_SETPROPERTY:
			str = dynFormatString(getString()); // Property name
			if (zzt.boardProps.hasOwnProperty(str))
			{
				zzt.boardProps[str] = getExpr();
				if (str == "ISDARK")
					SE.IsDark = zzt.boardProps[str];
			}
			else
			{
				zzt.globalProps[str] = getExpr();
			}

			// Set property string and dispatch to ONPROPERTY handler.
			zzt.globals["$PROP"] = str;
			briefDispatch(onPropPos, thisSE, blankSE);
		break;
		case oop.CMD_GETPROPERTY:
			str = dynFormatString(getString()); // Property name
			str2 = getExprRef();
			d = lastExprType;
			if (zzt.boardProps.hasOwnProperty(str))
				setVariableFromRef(d, str2, zzt.boardProps[str]);
			else if (zzt.globalProps.hasOwnProperty(str))
				setVariableFromRef(d, str2, zzt.globalProps[str]);
			else
				errorMsg("No such property:  " + str);
		break;
		case oop.CMD_SETTYPEINFO:
			kind1 = getKind();
			str = strGetExpr();
			typeList[kind1].writeProperty(str, getExpr());
		break;
		case oop.CMD_GETTYPEINFO:
			kind1 = getKind();
			str = strGetExpr();
			obj1 = typeList[kind1].readProperty(str);
			str2 = getExprRef();
			d = lastExprType;
			setVariableFromRef(d, str2, obj1);
		break;
		case oop.CMD_SUBSTR:
			str = getExprRef();
			d = lastExprType;
			str2 = strGetExpr();
			pos = intGetExpr();
			pos2 = intGetExpr();

			if (pos < 0)
				pos = str2.length - pos;
			if (pos < 0 || pos >= str2.length)
				pos2 = 0;
			if (pos + pos2 > str2.length)
				pos2 = str2.length - pos;

			setVariableFromRef(d, str, str2.substr(pos, pos2));
		break;
		case oop.CMD_INT:
			str = getExprRef();
			d = lastExprType;
			str2 = strGetExpr();
			for (pos = 0; pos < str2.length; pos++)
			{
				if (pos == 0 && str2.charAt(0) == "-")
					continue;
				if (!oop.isNumeric(str2, pos))
					break;
			}

			pos2 = 0;
			if (pos > 0)
				pos2 = int(str2.substr(0, pos));
			setVariableFromRef(d, str, pos2);
		break;
		case oop.CMD_PLAYERINPUT:
			str = getExprRef();
			d = lastExprType;
			setVariableFromRef(d, str, zzt.pMoveDir);
			str = getExprRef();
			d = lastExprType;
			setVariableFromRef(d, str, zzt.pShootDir);
			zzt.pMoveDir = -1;
			zzt.pShootDir = -1;
		break;
		case oop.CMD_RANDOM:
			str = getExprRef();
			d = lastExprType;
			pos = intGetExpr();
			pos2 = intGetExpr();
			setVariableFromRef(d, str, utils.randrange(pos, pos2));
		break;
		case oop.CMD_GETSOUND:
			str = getExprRef();
			d = lastExprType;
			pos = intGetExpr();
			setVariableFromRef(d, str, Sounds.getChannelPlaying(pos));
		break;
		case oop.CMD_STOPSOUND:
			pos = intGetExpr();
			pos2 = intGetExpr();
			for (; pos <= pos2; pos++)
				Sounds.stopChannel(pos);
		break;
		case oop.CMD_MASTERVOLUME:
			pos = intGetExpr();
			pos2 = intGetExpr();
			Sounds.setMasterVolume(intGetExpr(), pos, pos2);
		break;

		case oop.CMD_SET:
			classicSet = 0;
			str = getExprRef();
			d = lastExprType;
			pos = zzt.globalProps.length;
			setVariableFromRef(d, str, getExpr());

			if (classicSet == 2)
			{
				// When using the classic #SET GlobalFlag, we must honor the
				// original ZZT or Super ZZT flag limits.
				objComCount--;
				if (zzt.globalProps["NUMCLASSICFLAGS"] >= zzt.globalProps["CLASSICFLAGLIMIT"])
				{
					// We are at the limit of the "classic" global flags.
					// We must replace the last-set classic flag with the new one.
					delete zzt.globals[zzt.globalProps["LASTCLASSICFLAG"]];
					zzt.globalProps["LASTCLASSICFLAG"] = str;
				}
				else
				{
					// Add a "classic" global flag.
					zzt.globalProps["NUMCLASSICFLAGS"] += 1;
					zzt.globalProps["LASTCLASSICFLAG"] = str;
				}

				// In SZT, Z label is set when a flag starts with Z
				if (zzt.globalProps["WORLDTYPE"] == -2 && str.charAt(0) == "Z")
					zzt.globalProps["ZSTONELABEL"] = str.substr(1);
			}
		break;
		case oop.CMD_CLEAR:
			objComCount--;
			classicSet = 0;
			str = getExprRef();
			if (lastExprType == oop.SPEC_LOCALVAR)
			{
				// Clear local variable.  Only works if part of extras.
				if (thisSE.extra.hasOwnProperty(str))
					delete thisSE.extra[str];
			}
			else
			{
				// Clear global variable.
				if (zzt.globals.hasOwnProperty(str))
				{
					delete zzt.globals[str];
					if (classicSet == 1)
					{
						// Clear "classic" global flag.
						zzt.globalProps["NUMCLASSICFLAGS"] -= 1;
					}
				}
			}
		break;

		// Inventory
		case oop.CMD_GIVE:
			objComCount--;
			pos = int(getInt());
			if (pos == oop.INV_KEY)
			{
				pos = getInt();
				str = "KEY" + pos;
			}
			else if (pos == oop.INV_EXTRA)
			{
				str = getString();
				zzt.globals["$EXTRAINVNAME"] = str;
			}
			else if (pos == oop.INV_NONE)
			{
				str = "###";
			}
			else
			{
				str = oop.inventory_x[pos - 1];
			}

			if (!zzt.globalProps.hasOwnProperty(str))
				zzt.globalProps[str] = 0;
			zzt.globalProps[str] += intGetExpr();

			// Set property string and dispatch to ONPROPERTY handler.
			zzt.globals["$PROP"] = str;
			briefDispatch(onPropPos, thisSE, blankSE);
		break;
		case oop.CMD_TAKE:
			objComCount--;
			pos = int(getInt());
			if (pos == oop.INV_KEY)
			{
				pos = getInt();
				str = "KEY" + pos;
			}
			else if (pos == oop.INV_EXTRA)
			{
				str = getString();
				zzt.globals["$EXTRAINVNAME"] = str;
			}
			else if (pos == oop.INV_NONE)
			{
				str = "###";
			}
			else
			{
				str = oop.inventory_x[pos - 1];
			}

			pos2 = intGetExpr();
			if (!zzt.globalProps.hasOwnProperty(str))
				zzt.globalProps[str] = 0;
			if (zzt.globalProps[str] >= pos2)
			{
				// Normal take
				zzt.globalProps[str] -= pos2;

				// Set property string and dispatch to ONPROPERTY handler.
				zzt.globals["$PROP"] = str;
				briefDispatch(onPropPos, thisSE, blankSE);

				thisSE.IP++;
				pos2 = getInt(); // Jump-over location
				thisSE.IP = pos2; // Jump over alternate command
			}
			else // Not enough to take; execute alternate command.
			{
				thisSE.IP++;
				pos2 = getInt(); // Jump-over location
				objComCount++;
				processCommand(getInt());
			}
		break;

		// Flow control
		case oop.CMD_ZAP:
			objComCount--;
			str = getString();
			zapTarget(thisSE, str);
		break;
		case oop.CMD_RESTORE:
			objComCount--;
			str = getString();
			restoreTarget(thisSE, str);
		break;
		case oop.CMD_ZAPTARGET:
			objComCount--;
			str = getString();
			str2 = getString();
			relSE = getSEFromOName(str);
			if (relSE)
			{
				if (!relSE.extra.hasOwnProperty("CODEID"))
				{
					errorMsg("#ZAP Target:Label can't be used with non-unique code");
					return false;
				}
				zapTarget(relSE, str2);
			}
		break;
		case oop.CMD_RESTORETARGET:
			objComCount--;
			str = getString();
			str2 = getString();
			relSE = getSEFromOName(str);
			if (relSE)
			{
				if (!relSE.extra.hasOwnProperty("CODEID"))
				{
					errorMsg("#RESTORE Target:Label can't be used with non-unique code");
					return false;
				}
				restoreTarget(relSE, str2, str);
			}
		break;
		case oop.CMD_IF:
			objComCount--;
			pos2 = getInt();
			pos = getInt();
			switch (pos) {
				case oop.FLAG_ALWAYSTRUE:
					pos = 1;
				break;
				case oop.FLAG_GENERIC:
					pos = int(getGlobalVarValue(getString()));
				break;
				case oop.FLAG_ANY:
					kind1 = getKind();
					pos = 0;
					if (checkTypeWithinRegion(allRegion, kind1, kwargPos))
						pos = 1;
				break;
				case oop.FLAG_ALLIGNED:
				case oop.FLAG_ALIGNED:
					if (peekInt() == oop.SPEC_ALL)
					{
						d = -1;
						thisSE.IP++
					}
					else
						d = getDir();

					pos = 0;
					switch (d) {
						case 0:
							if (thisSE.Y == playerSE.Y && thisSE.X <= playerSE.X)
								pos = 1;
						break;
						case 1:
							if (thisSE.X == playerSE.X && thisSE.Y <= playerSE.Y)
								pos = 1;
						break;
						case 2:
							if (thisSE.Y == playerSE.Y && thisSE.X >= playerSE.X)
								pos = 1;
						break;
						case 3:
							if (thisSE.X == playerSE.X && thisSE.Y >= playerSE.Y)
								pos = 1;
						break;
						default:
							if (thisSE.X == playerSE.X || thisSE.Y == playerSE.Y)
								pos = 1;
						break;
					}
				break;
				case oop.FLAG_CONTACT:
					if (peekInt() == oop.SPEC_ALL)
					{
						d = -1;
						thisSE.IP++
					}
					else
						d = getDir();

					pos = 0;
					switch (d) {
						case 0:
							if (thisSE.Y == playerSE.Y && thisSE.X == playerSE.X - 1)
								pos = 1;
						break;
						case 1:
							if (thisSE.X == playerSE.X && thisSE.Y == playerSE.Y - 1)
								pos = 1;
						break;
						case 2:
							if (thisSE.Y == playerSE.Y && thisSE.X == playerSE.X + 1)
								pos = 1;
						break;
						case 3:
							if (thisSE.X == playerSE.X && thisSE.Y == playerSE.Y + 1)
								pos = 1;
						break;
						default:
							if (utils.iabs(thisSE.X - playerSE.X) +
								utils.iabs(thisSE.Y - playerSE.Y) <= 1)
								pos = 1;
						break;
					}
				break;
				case oop.FLAG_BLOCKED:
					d = getDir();
					coords1[0] = thisSE.X + getStepXFromDir4(d);
					coords1[1] = thisSE.Y + getStepYFromDir4(d);
					pos = 0;
					if (typeList[SE.getType(coords1[0], coords1[1])].BlockObject)
						pos = 1;
				break;
				case oop.FLAG_CANPUSH:
					getCoords(coords1);
					d = getDir();
					pos = assessPushability(coords1[0], coords1[1], d);
				break;
				case oop.FLAG_SAFEPUSH:
					getCoords(coords1);
					d = getDir();
					pos = assessPushability(coords1[0], coords1[1], d, false);
				break;
				case oop.FLAG_SAFEPUSH1:
					getCoords(coords1);
					d = getDir();
					tx = coords1[0];
					ty = coords1[1];
					pos = assessPushability(coords1[0], coords1[1], d, false);
					if (pos == 0)
					{
						pos = assessPushability(tx, ty, d, true);
						if (pos != 0 && wouldSquashX == tx && wouldSquashY == ty)
							pos = 0; // Point-blank squashing not allowed
					}
				break;
				case oop.FLAG_ENERGIZED:
					pos = 0;
					if (zzt.globalProps["ENERGIZERCYCLES"] > 0)
						pos = 1;
				break;
				case oop.FLAG_ANYTO:
					d = getDir();
					kind1 = getKind();
					coords1[0] = thisSE.X + getStepXFromDir4(d);
					coords1[1] = thisSE.Y + getStepYFromDir4(d);
					pos = 0;
					if (validCoords(coords1, true))
					{
						if (checkType(coords1[0], coords1[1], kind1, kwargPos))
							pos = 1;
					}
				break;
				case oop.FLAG_ANYIN:
					str = regionGetExpr(); // Region name
					kind1 = getKind();
					pos = 0;
					if (checkTypeWithinRegion(getRegion(str), kind1, kwargPos))
						pos = 1;
				break;
				case oop.FLAG_SELFIN:
					str = regionGetExpr(); // Region name
					testRegion = getRegion(str);
					pos = 0;
					if (thisSE.X >= testRegion[0][0] && thisSE.Y >= testRegion[0][1] &&
						thisSE.X <= testRegion[1][0] && thisSE.Y <= testRegion[1][1])
						pos = 1;
				break;
				case oop.FLAG_TYPEIS:
					getCoords(coords1);
					kind1 = getKind();
					pos = 0;
					if (validCoords(coords1, true))
					{
						if (checkType(coords1[0], coords1[1], kind1, kwargPos))
							pos = 1;
					}
				break;
				case oop.FLAG_BLOCKEDAT:
					getCoords(coords1);
					pos = 0;
					if (validCoords(coords1, true))
					{
						if (typeList[SE.getType(coords1[0], coords1[1])].BlockObject)
							pos = 1;
					}
				break;
				case oop.FLAG_HASMESSAGE:
					pos = intGetExpr();
					str = getString();
					relSE = SE.getStatElem(pos);
					pos = 0;
					if (relSE)
					{
						if (relSE.extra.hasOwnProperty("CODEID"))
							pos = findLabel(codeBlocks[relSE.extra["CODEID"]], str);
						else
							pos = findLabel(codeBlocks[typeList[relSE.TYPE].CODEID], str);
						if (pos == -1)
							pos = 0;
						else
							pos = 1;
					}
				break;
				case oop.FLAG_TEST:
					pos = intGetExpr();
				break;
				case oop.FLAG_VALID:
					d = intGetExpr();
					if (SE.getStatElem(d) != null)
						pos = 1;
					else
						pos = 0;
				break;
			}

			if ((pos != 0) == (pos2 == oop.SPEC_NORM))
			{
				thisSE.IP += 2; // Skip CMD_FALSEJUMP
				objComCount++;
				processCommand(getInt());
			}
			else
			{
				thisSE.IP++;
				thisSE.IP = getInt(); // ignoreCommand(code, thisSE.IP);
			}
		break;
		case oop.CMD_DONEDISPATCH:
			// Done with dispatched message.  This means the main status
			// of the object will be affected, as if no longer in a
			// dispatched message.
			thisSE.FLAGS &= ~FL_DISPATCH;
			turns = 1;
			if (thisSE.extra.hasOwnProperty("CODEID"))
				objComCount = objComThreshold;
		break;
		case oop.CMD_FOREACH:
			str = getExprRef();
			d = lastExprType;
			if (cueForEach(str, d, regionGetExpr()) == -1)
			{
				// Short-circuit jump past FORNEXT if loop totally empty
				thisSE.IP = findLabel(code, ":#PASTFORNEXT", thisSE.IP, 3);
			}
		break;
		case oop.CMD_FORMASK:
			str = getExprRef();
			d = lastExprType;
			str2 = getExprRef();
			pos = lastExprType;
			getCoords(coords1);
			if (cueForMask(str, d, str2, pos, coords1, getString()) == -1)
			{
				// Short-circuit jump past FORNEXT if loop totally empty
				thisSE.IP = findLabel(code, ":#PASTFORNEXT", thisSE.IP, 3);
			}
		break;
		case oop.CMD_FORREGION:
			str = getExprRef();
			d = lastExprType;
			str2 = getExprRef();
			pos = lastExprType;
			if (cueForRegion(str, d, str2, pos, regionGetExpr()) == -1)
			{
				// Short-circuit jump past FORNEXT if loop totally empty
				thisSE.IP = findLabel(code, ":#PASTFORNEXT", thisSE.IP, 3);
			}
		break;
		case oop.CMD_FORNEXT:
			if (iterateFor() != -1)
				thisSE.IP = forRetLoc;
		break;

		// Sound and music
		case oop.CMD_PLAY:
			objComCount--;
			str = getString();

			// No 64th-note unless in Ultra mode
			if (zzt.globalProps["WORLDTYPE"] != -3)
			{
				while (str.indexOf("J") != -1)
					str = str.replace("J", " ");
			}

			// Play retention
			str = markupPlayString(str);

			// Only play if sound is registered as on
			if (zzt.globalProps["SOUNDOFF"] != 1)
			{
				// If play sync activated, remember code in case advancement needed
				if (zzt.globalProps["PLAYSYNC"] == 1)
				{
					Sounds.playSyncCallback = playSyncCallback;
					playSyncIdleSE = thisSE;
					playSyncIdleCode = code;
				}
				else
				{
					Sounds.playSyncCallback = null;
					playSyncIdleSE = null;
					playSyncIdleCode = null;
				}

				Sounds.distributePlayNotes(str);
			}
		break;
		case oop.CMD_PLAYSOUND:
			Sounds.soundDispatch(dynFormatString(getString()));
		break;

		// GUI and high-level control
		case oop.CMD_USEGUI:
			str = getString();
			if (zzt.establishGui(dynFormatString(str)));
				zzt.drawGui();
		break;
		case oop.CMD_MODGUILABEL:
			str = dynFormatString(getString());
			modGuiLabel = [ intGetExpr(), intGetExpr(), intGetExpr(), intGetExpr() ];
			pos = intGetExpr();
			if (pos == 1)
				modGuiLabel.push(pos);

			zzt.GuiLabels[str] = modGuiLabel;
		break;
		case oop.CMD_SETGUILABEL:
			str = dynFormatString(getString());
			str2 = strGetExpr();
			pos = intGetExpr();
			zzt.eraseGuiLabel(str, pos);
			zzt.drawGuiLabel(str, str2, pos);
		break;
		case oop.CMD_CONFMESSAGE:
			turns = 0;
			zzt.confMessage(getString(), strGetExpr(), getString(), getString());
		break;
		case oop.CMD_TEXTENTRY:
			turns = 0;
			str = getString();
			str2 = strGetExpr();
			pos = intGetExpr();
			pos2 = intGetExpr();
			zzt.textEntry(str, str2, pos, pos2, getString(), getString());
		break;
		case oop.CMD_DRAWPEN:
			zzt.drawPen(getString(), intGetExpr(), intGetExpr(),
				intGetExpr(), intGetExpr(), intGetExpr());
		break;
		case oop.CMD_SELECTPEN:
			zzt.selectPen(getString(), intGetExpr(), intGetExpr(),
				intGetExpr(), intGetExpr(), intGetExpr(), getString());
		break;
		case oop.CMD_DRAWBAR:
			zzt.drawBar(getString(),
				intGetExpr(), intGetExpr(), intGetExpr(), intGetExpr());
		break;
		case oop.CMD_UPDATEVIEWPORT:
			smartUpdateViewport();
		break;
		case oop.CMD_ERASEVIEWPORT:
			SE.mg.writeConst(SE.vpX0 - 1, SE.vpY0 - 1, SE.vpWidth, SE.vpHeight, " ", 0);
			SE.uCameraX = -1000;
			SE.uCameraY = -1000;
		break;
		case oop.CMD_DISSOLVEVIEWPORT:
			pos = intGetExpr(); // Color
			zzt.dissolveViewport(zzt.MODE_NORM, 0.5, pos);
		break;
		case oop.CMD_SCROLLTOVISUALS:
			pos = intGetExpr(); // Milliseconds
			dir = getDir();
			zzt.scrollTransitionViewport(zzt.MODE_NORM, Number(pos) / 1000.0, dir);
		break;
		case oop.CMD_CAMERAFOCUS:
			getCoords(coords1);
			cameraAdjust(coords1);
		break;

		case oop.CMD_PUSHARRAY:
			exprRefSrc1 = getExpr() as Array;
			exprRefSrc1.push(getExpr());
		break;
		case oop.CMD_POPARRAY:
			exprRefSrc1 = getExpr() as Array;
			str = getExprRef();
			d = lastExprType;
			if (exprRefSrc1.length > 0)
			{
				setVariableFromRef(d, str, exprRefSrc1[exprRefSrc1.length - 1]);
				exprRefSrc1.pop();
			}
		break;
		case oop.CMD_SETARRAY:
			str = getExprRef();
			d = lastExprType;
			pos = intGetExpr();
			if (pos >= 0)
				zzt.globals[str] = new Array(pos);
			else
				zzt.globals[str] = new Array(0);
		break;
		case oop.CMD_LEN:
			str = getExprRef();
			d = lastExprType;
			obj1 = getExpr();
			if (obj1 is Array)
				setVariableFromRef(d, str, (obj1 as Array).length);
			else
				setVariableFromRef(d, str, obj1.toString().length);
		break;

		case oop.CMD_SWITCHTYPE:
			getCoords(coords1);
			kind1 = typeList[SE.getType(coords1[0], coords1[1])].NUMBER;
			pos = getInt();
			while (pos--)
			{
				kind2 = typeList[getKind()].NUMBER;
				pos2 = getLabelLoc(code);
				if ((kind1 == kind2 || (kind1 == 253 && kind2 == 0)) && pos2 != -1)
				{
					// Go to label
					thisSE.IP = pos2;
					scriptDeadlockCount++;
					break;
				}
			}
		break;
		case oop.CMD_SWITCHVALUE:
			obj1 = getExpr();
			pos = getInt();
			while (pos--)
			{
				obj2 = getExprValue(oop.SPEC_NUMCONST);
				pos2 = getLabelLoc(code);
				if (obj1 == obj2 && pos2 != -1)
				{
					// Go to label
					thisSE.IP = pos2;
					scriptDeadlockCount++;
					break;
				}
			}
		break;
		case oop.CMD_EXECCOMMAND:
			zzt.oneLineExecCommand(String(getExpr()));
		break;

		case oop.CMD_DRAWCHAR:
			getCoords(coords1);
			obj1 = getExpr();
			pos2 = intGetExpr();

			if (!SE.suspendDisp)
			{
				tx = coords1[0] - SE.CameraX;
				ty = coords1[1] - SE.CameraY;
				if (tx >= 0 && ty >= 0 && tx < SE.vpWidth && ty < SE.vpHeight)
				{
					tx += SE.vpX0 - 1;
					ty += SE.vpY0 - 1;
					if (obj1 is int)
						SE.mg.setCell(tx, ty, int(obj1), pos2);
					else
						SE.mg.writeStr(tx, ty, obj1.toString(), pos2);
				}
			}
		break;
		case oop.CMD_ERASECHAR:
			getCoords(coords1);
			if (!SE.suspendDisp)
				SE.displaySquare(coords1[0], coords1[1]);
		break;
		case oop.CMD_DRAWGUICHAR:
			coords1[0] = intGetExpr() + zzt.GuiLocX - 2;
			coords1[1] = intGetExpr() + zzt.GuiLocY - 2;
			obj1 = getExpr();
			pos2 = intGetExpr();

			if (obj1 is int)
				SE.mg.setCell(coords1[0], coords1[1], int(obj1), pos2);
			else
				SE.mg.writeStr(coords1[0], coords1[1], obj1.toString(), pos2);
		break;
		case oop.CMD_ERASEGUICHAR:
			coords1[0] = intGetExpr() + zzt.GuiLocX - 1;
			coords1[1] = intGetExpr() + zzt.GuiLocY - 1;
			zzt.displayGuiSquare(coords1[0], coords1[1]);
		break;

		case oop.CMD_GHOST:
			pos = intGetExpr(); // Object pointer
			pos2 = intGetExpr();
			relSE = SE.getStatElem(pos);
			if (relSE)
			{
				if (validXY(relSE.X, relSE.Y))
				{
					if ((relSE.FLAGS & FL_GHOST) != 0 && pos2 == 0)
					{
						// Removing "ghost" status
						relSE.FLAGS &= ~FL_GHOST;
						killSE(relSE.X, relSE.Y);
						relSE.moveSelfSquare(relSE.X, relSE.Y, false);
					}
					else if ((relSE.FLAGS & FL_GHOST) == 0 && pos2 != 0)
					{
						// Setting "ghost" status
						relSE.eraseSelfSquare();
						relSE.FLAGS |= FL_GHOST;
					}
				}
			}
		break;

		case oop.CMD_GROUPSETPOS:
			// Update of position destroys anything in the group's path.
			getCoords(coords1);
			exprRefSrc1 = getExpr() as Array;
			calcGroupRimInfo(thisSE.X, thisSE.Y, coords1[0], coords1[1], exprRefSrc1);
			if (doGroupMove)
				tryEntireMove(0);
		break;
		case oop.CMD_GROUPGO:
			// Update of position will wait until path is free.
			turns--;
			objComCount -= objComThreshold;
			pos = thisSE.IP - 1;
			getCoords(coords1);
			exprRefSrc1 = getExpr() as Array;

			calcGroupRimInfo(thisSE.X, thisSE.Y, coords1[0], coords1[1], exprRefSrc1);
			if (doGroupMove)
			{
				if (!checkAllGroup)
				{
					// Push-movement
					if (tryRimPush(2) == -1)
						thisSE.IP = pos; // No
					else
						tryEntireMove(0); // Yes
				}
				else
				{
					// No-push movement
					if (!tryEntireMove(1))
						thisSE.IP = pos; // No
					else
						tryEntireMove(0); // Yes
				}
			}
		break;

		case oop.CMD_GROUPTRY:
		case oop.CMD_GROUPTRYNOPUSH:
			// Update of position will execute alternate command if blocked.
			getCoords(coords1);
			exprRefSrc1 = getExpr() as Array;
			thisSE.IP++;
			pos2 = getInt(); // Jump-over location

			calcGroupRimInfo(thisSE.X, thisSE.Y, coords1[0], coords1[1], exprRefSrc1);
			if (doGroupMove)
			{
				if (!checkAllGroup && cByte == oop.CMD_GROUPTRY)
				{
					// Push-movement
					if (tryRimPush(2) != -1)
					{
						// Yes
						tryEntireMove(0);
						turns--;
						objComCount -= objComThreshold;
						thisSE.IP = pos2; // Jump over
					}
				}
				else
				{
					// No-push movement
					if (tryEntireMove(1))
					{
						// Yes
						tryEntireMove(0);
						turns--;
						objComCount -= objComThreshold;
						thisSE.IP = pos2; // Jump over
					}
				}
			}
		break;

		case oop.CMD_ATAN2:
			getRelCoords(coords1);
			pos = atan2FromSteps(coords1[0], coords1[1], intGetExpr());

			str = getExprRef();
			d = lastExprType;
			setVariableFromRef(d, str, pos);
		break;
		case oop.CMD_SMOOTHTEST:
			pos = intGetExpr(); // Object pointer
			relSE = SE.getStatElem(pos);
			pos = intGetExpr(); // Mag * 256
			pos2 = intGetExpr(); // Dir256
			d = intGetExpr(); // Limit
			if (relSE)
			{
				// Ensure fractional component
				if (!relSE.extra.hasOwnProperty("FX"))
					relSE.extra["FX"] = 128;
				if (!relSE.extra.hasOwnProperty("FY"))
					relSE.extra["FY"] = 128;

				// Calculate vector
				tx = int(Number(pos) * Math.cos(Number(pos2) * Math.PI / 128));
				ty = int(Number(pos) * Math.sin(Number(pos2) * Math.PI / 128));

				if (utils.iabs(tx) > utils.iabs(ty))
				{
					if (utils.iabs(tx) > d)
					{
						ty = ty * d / utils.iabs(tx);
						tx = d * utils.isgn(tx);
					}
				}
				else if (utils.iabs(ty) > d)
				{
					tx = tx * d / utils.iabs(ty);
					ty = d * utils.isgn(ty);
				}

				// Get resulting coordinates * 256
				tx += (relSE.X << 8) + relSE.extra["FX"];
				ty += (relSE.Y << 8) + relSE.extra["FY"];

				zzt.globals["$DESTX"] = (tx >> 8);
				zzt.globals["$DESTY"] = (ty >> 8);
				zzt.globals["$FRACX"] = (tx & 255);
				zzt.globals["$FRACY"] = (ty & 255);
			}
		break;
		case oop.CMD_SMOOTHMOVE:
			pos = intGetExpr(); // Object pointer
			relSE2 = SE.getStatElem(pos);
			tx = zzt.globals["$DESTX"];
			ty = zzt.globals["$DESTY"];

			if (!relSE2)
			{
				if (validXY(tx, ty, true))
				{
					relSE = SE.getStatElemAt(tx, ty);
					if (relSE)
					{
						killSE(tx, ty);
						SE.displaySquare(tx, ty);
					}
				}
			}
			else if (relSE2.FLAGS & FL_GHOST)
			{
				// Ghost movement always succeeds
				relSE2.X = tx;
				relSE2.Y = ty;
				relSE2.extra["FX"] = zzt.globals["$FRACX"];
				relSE2.extra["FY"] = zzt.globals["$FRACY"];
			}
			else if (validXY(tx, ty, true))
			{
				relSE = SE.getStatElemAt(tx, ty);
				if (relSE != relSE2)
					killSE(tx, ty);

				// Move status element
				relSE2.moveSelfSquare(tx, ty);
				relSE2.extra["FX"] = zzt.globals["$FRACX"];
				relSE2.extra["FY"] = zzt.globals["$FRACY"];
			}
		break;

		case oop.CMD_READKEY:
			str = getExprRef();
			d = lastExprType;
			obj1 = getExpr();
			if (obj1 is int)
				setVariableFromRef(d, str, input.keyCodeDowns[int(obj1) & 255]);
			else
				setVariableFromRef(d, str,
					input.keyCharDowns[obj1.toString().charCodeAt(0) & 255]);
		break;
		case oop.CMD_READMOUSE:
			zzt.globals["$MOUSEX"] = input.mouseXGridPos - SE.vpX0 + 2;
			zzt.globals["$MOUSEY"] = input.mouseYGridPos - SE.vpY0 + 2;
			zzt.globals["$LMB"] = input.mDown ? 1 : 0;
		break;

		case oop.CMD_SETCONFIGVAR:
			str = strGetExpr();
			str2 = strGetExpr();
			if (!zzt.zztSO.data.hasOwnProperty(str))
				obj1 = new Object();
			else
				obj1 = zzt.zztSO.data[str];

			obj1[str2] = getExpr();
			zzt.saveSharedObj(str, obj1);
		break;
		case oop.CMD_GETCONFIGVAR:
			str = strGetExpr();
			str2 = strGetExpr();
			if (!zzt.zztSO.data.hasOwnProperty(str))
			{
				str = getExprRef();
				d = lastExprType;
				setVariableFromRef(d, str, 0);
			}
			else
			{
				obj1 = zzt.zztSO.data[str];
				str = getExprRef();
				d = lastExprType;
				if (!obj1.hasOwnProperty(str2))
					setVariableFromRef(d, str, 0);
				else
					setVariableFromRef(d, str, obj1[str2]);
			}
		break;
		case oop.CMD_DELCONFIGVAR:
			str = strGetExpr();
			str2 = strGetExpr();
			if (zzt.zztSO.data.hasOwnProperty(str))
			{
				obj1 = zzt.zztSO.data[str];
				delete obj1[str2];
				zzt.saveSharedObj(str, obj1);
			}
		break;
		case oop.CMD_DELCONFIGHIVE:
			str = strGetExpr();
			if (zzt.zztSO.data.hasOwnProperty(str))
				zzt.deleteSharedObj(str);
		break;
		case oop.CMD_SYSTEMACTION:
			pos = intGetExpr(); // Action code
			switch (pos) {
				case 56334:
					establishCaptchaNums();
				break;
				case 56335:
					captchaSubmit();
				break;
				case 56336:
					captchaSubmitAdmin();
				break;
				case 76591:
					setMedal();
				break;
				case 76592:
					clearMedal();
				break;
				case 76593:
					resetAllMedals();
				break;
			}
		break;

		case oop.CMD_SCANLINES:
			pos = intGetExpr(); // Scanline count mode
			switch (pos) {
				case 0: // CGA (200)
				case 1: // EGA (350)
				case 2: // VGA (400; default)
					zzt.globalProps["SCANLINES"] = pos;
					SE.mg.updateScanlineMode(pos);
					SE.mg.createSurfaces(
						zzt.OverallSizeX, zzt.OverallSizeY, zzt.Viewport, true);
					zzt.cellYDiv = 16;
				break;
			}
		break;
		case oop.CMD_BIT7ATTR:
			pos = intGetExpr(); // Bit 7 usage (0=high intensity color; 1=blink)
			zzt.globalProps["BIT7ATTR"] = pos;
			SE.mg.updateBit7Meaning(pos);
		break;
		case oop.CMD_PALETTECOLOR:
			pos = intGetExpr(); // Palette Index
			SE.mg.setPaletteColor(pos, intGetExpr(), intGetExpr(), intGetExpr());
		break;
		case oop.CMD_FADETOCOLOR:
			pos = intGetExpr(); // Milliseconds
			zzt.fadeToColorSingle(zzt.MODE_NORM, Number(pos) / 1000.0,
				intGetExpr(), intGetExpr(), intGetExpr());
		break;
		case oop.CMD_PALETTEBLOCK:
			pos = intGetExpr(); // Start index
			pos2 = intGetExpr(); // Number of indexes
			tx = intGetExpr(); // Extent
			obj1 = getExpr(); // Mask/Lump string or array name
			genericSeq = getFlatSequence(obj1);
			if (genericSeq == null)
				genericSeq = SE.mg.getDefaultPaletteColors();
			SE.mg.setPaletteColors(pos, pos2, tx, genericSeq);
		break;
		case oop.CMD_FADETOBLOCK:
			pos = intGetExpr(); // Milliseconds
			pos2 = intGetExpr(); // Start index
			tx = intGetExpr(); // Number of indexes
			ty = intGetExpr(); // Extent
			obj1 = getExpr(); // Mask/Lump string or array name
			genericSeq = getFlatSequence(obj1);
			if (genericSeq == null)
				genericSeq = SE.mg.getDefaultPaletteColors();
			zzt.fadeToColorBlock(zzt.MODE_NORM, Number(pos) / 1000.0, pos2, tx, ty, genericSeq);
		break;
		case oop.CMD_CHARSELECT:
			obj1 = getExpr(); // Mask/Lump string or array name
			genericSeq = getFlatSequence(obj1, true);
			pos = intGetExpr(); // Cell X Size
			pos2 = intGetExpr(); // Cell Y Size
			tx = intGetExpr(); // Cells Across
			ty = intGetExpr(); // Cells Down
			if (genericSeq == null)
			{
				pos = intGetExpr();
				SE.mg.setDefaultCharacters();
			}
			else
				SE.mg.updateCharacterSet(pos, pos2, tx, ty, intGetExpr(), genericSeq);

			SE.mg.createSurfaces(
				zzt.OverallSizeX, zzt.OverallSizeY, zzt.Viewport, true);
			zzt.cellYDiv = SE.mg.virtualCellYDiv;
		break;

		case oop.CMD_POSTHS:
			str = strGetExpr();
			str2 = strGetExpr();
			pos = intGetExpr();
			pos2 = intGetExpr();
			postHighScore(str, str2, pos, pos2);
		break;
		case oop.CMD_GETHS:
			str2 = strGetExpr();
			pos = intGetExpr();
			pos2 = intGetExpr();
			getHighScores(str2, pos, pos2);
		break;
		case oop.CMD_GETHSENTRY:
			str = getExprRef();
			d = lastExprType;
			pos = intGetExpr();
			pos2 = intGetExpr();
			setVariableFromRef(d, str, getHighScoreField(pos, pos2));
		break;

		default:
			errorMsg("Bad opcode:  " + cByte + " at pos " + thisSE.IP);
			opcodeTraceback(code, thisSE.IP);
		return false;
	}

	return true;
}

// Skip past a command.
public static function ignoreCommand(codeBlock:Array, pos:int):int {
	var i:int;
	var cByte:int = codeBlock[pos++];
	switch (cByte) {
		case oop.CMD_NAME:
		case oop.CMD_BIND:
		case oop.CMD_SEND:
		case oop.CMD_DISPATCH:
		case oop.CMD_ZAP:
		case oop.CMD_RESTORE:
		case oop.CMD_PLAY:
		case oop.CMD_PLAYSOUND:
		case oop.CMD_USEGUI:
		case oop.CMD_ERROR:
		case oop.CMD_FALSEJUMP:
			pos++;
		break;

		case oop.CMD_NOP:
		case oop.CMD_PAUSE:
		case oop.CMD_UNPAUSE:
		case oop.CMD_ENDGAME:
		case oop.CMD_END:
		case oop.CMD_RESTART:
		case oop.CMD_LOCK:
		case oop.CMD_UNLOCK:
		case oop.CMD_DIE:
		case oop.CMD_DONEDISPATCH:
		case oop.CMD_UPDATELIT:
		case oop.CMD_UPDATEVIEWPORT:
		case oop.CMD_ERASEVIEWPORT:
		break;

		case oop.CMD_CHAR:
		case oop.CMD_CYCLE:
		case oop.CMD_COLOR:
		case oop.CMD_COLORALL:
		case oop.CMD_EXTRATURNS:
		case oop.CMD_SUSPENDDISPLAY:
		case oop.CMD_CHANGEBOARD:
		case oop.CMD_DISSOLVEVIEWPORT:
		case oop.CMD_SAVEBOARD:
		case oop.CMD_SAVEWORLD:
		case oop.CMD_LOADWORLD:
		case oop.CMD_RESTOREGAME:
		case oop.CMD_DUMPSE:
		case oop.CMD_SETPLAYER:
		case oop.CMD_CLEARREGION:
			pos = ignoreExpr(codeBlock, pos);
		break;

		case oop.CMD_SCROLLTOVISUALS:
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreDir(codeBlock, pos);
		break;

		case oop.CMD_LABEL:
		case oop.CMD_COMMENT:
		case oop.CMD_SENDTONAME:
		case oop.CMD_ZAPTARGET:
		case oop.CMD_RESTORETARGET:
			pos += 2;
		break;
		case oop.CMD_SENDTO:
		case oop.CMD_DISPATCHTO:
			pos = ignoreExpr(codeBlock, pos);
			pos++;
		break;
		case oop.CMD_TEXT:
		case oop.CMD_TEXTCENTER:
		case oop.CMD_TEXTLINK:
		case oop.CMD_TEXTLINKFILE:
		case oop.CMD_DYNTEXT:
		case oop.CMD_DYNLINK:
		case oop.CMD_DYNTEXTVAR:
			pos = ignoreText(codeBlock, pos, cByte);
		break;
		case oop.CMD_SCROLLSTR:
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos++;
		break;
		case oop.CMD_SCROLLCOLOR:
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
		break;

		case oop.CMD_GO:
		case oop.CMD_FORCEGO:
		case oop.CMD_TRYSIMPLE:
		case oop.CMD_WALK:
			pos = ignoreDir(codeBlock, pos);
		break;
		case oop.CMD_TRY:
			pos = ignoreDir(codeBlock, pos);
			pos += 2;
			//pos = ignoreCommand(codeBlock, pos);
		break;
		case oop.CMD_PUSHATPOS:
			pos = ignoreCoords(codeBlock, pos);
			pos = ignoreDir(codeBlock, pos);
		break;

		case oop.CMD_BECOME:
			pos = ignoreKind(codeBlock, pos);
		break;

		case oop.CMD_SPAWN:
			pos++;
			pos = ignoreCoords(codeBlock, pos);
			pos = ignoreKind(codeBlock, pos);
		break;
		case oop.CMD_SPAWNGHOST:
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreCoords(codeBlock, pos);
			pos = ignoreKind(codeBlock, pos);
		break;
		case oop.CMD_PUT:
			pos = ignoreDir(codeBlock, pos);
			pos = ignoreKind(codeBlock, pos);
		break;
		case oop.CMD_SHOOT:
		case oop.CMD_THROWSTAR:
			pos++;
			pos = ignoreDir(codeBlock, pos);
		break;
		case oop.CMD_CHANGE:
			pos = ignoreKind(codeBlock, pos);
			pos = ignoreKind(codeBlock, pos);
		break;
		case oop.CMD_CHANGEREGION:
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreKind(codeBlock, pos);
			pos = ignoreKind(codeBlock, pos);
		break;
		case oop.CMD_SETPOS:
			pos = ignoreExpr(codeBlock, pos);
			pos++;
			pos = ignoreCoords(codeBlock, pos);
		break;
		case oop.CMD_TYPEAT:
		case oop.CMD_COLORAT:
		case oop.CMD_OBJAT:
		case oop.CMD_LITAT:
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreCoords(codeBlock, pos);
		break;

		case oop.CMD_CHAR4DIR:
			pos = ignoreDir(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
		break;
		case oop.CMD_DIR2UVECT8:
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
		break;
		case oop.CMD_OFFSETBYDIR:
			pos = ignoreCoords(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
		break;
		case oop.CMD_CLONE:
		case oop.CMD_LIGHTEN:
		case oop.CMD_DARKEN:
		case oop.CMD_DUMPSEAT:
		case oop.CMD_KILLPOS:
			pos = ignoreCoords(codeBlock, pos);
		break;
		case oop.CMD_TEXTTOGUI:
			pos++;
		break;
		case oop.CMD_TEXTTOGRID:
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
		break;

		case oop.CMD_SETREGION:
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreCoords(codeBlock, pos);
			pos = ignoreCoords(codeBlock, pos);
		break;
		case oop.CMD_SETPROPERTY:
		case oop.CMD_GETPROPERTY:
			pos++;
			pos = ignoreExpr(codeBlock, pos);
		break;
		case oop.CMD_CLEAR:
		case oop.CMD_EXECCOMMAND:
			pos = ignoreExpr(codeBlock, pos);
		break;
		case oop.CMD_SETTYPEINFO:
		case oop.CMD_GETTYPEINFO:
			pos = ignoreKind(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
		break;
		case oop.CMD_SUBSTR:
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
		break;
		case oop.CMD_INT:
		case oop.CMD_PLAYERINPUT:
		case oop.CMD_GETSOUND:
		case oop.CMD_STOPSOUND:
		case oop.CMD_SET:
		case oop.CMD_PUSHARRAY:
		case oop.CMD_POPARRAY:
		case oop.CMD_SETARRAY:
		case oop.CMD_LEN:
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
		break;
		case oop.CMD_RANDOM:
		case oop.CMD_MASTERVOLUME:
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
		break;

		case oop.CMD_SWITCHTYPE:
			pos = ignoreCoords(codeBlock, pos);
			i = codeBlock[pos++];
			while (i--)
			{
				pos = ignoreKind(codeBlock, pos);
				pos++;
			}
		break;
		case oop.CMD_SWITCHVALUE:
			pos = ignoreExpr(codeBlock, pos);
			i = codeBlock[pos++];
			while (i--)
			{
				pos = ignoreExprValue(codeBlock, pos, 0);
				pos++;
			}
		break;

		case oop.CMD_GIVE:
			if (codeBlock[pos] == oop.INV_KEY)
				pos += 2;
			else if (codeBlock[pos] == oop.INV_EXTRA)
				pos += 2;
			else
				pos++;

			pos = ignoreExpr(codeBlock, pos);
		break;
		case oop.CMD_TAKE:
			if (codeBlock[pos] == oop.INV_KEY)
				pos += 2;
			else if (codeBlock[pos] == oop.INV_EXTRA)
				pos += 2;
			else
				pos++;

			pos = ignoreExpr(codeBlock, pos);
			//pos = ignoreCommand(codeBlock, pos);
		break;

		case oop.CMD_IF:
			pos++;
			i = codeBlock[pos++];
			switch (i) {
				case oop.FLAG_ALWAYSTRUE:
				break;
				case oop.FLAG_GENERIC:
					pos++;
				break;
				case oop.FLAG_ANY:
					pos = ignoreKind(codeBlock, pos);
				break;
				case oop.FLAG_ALLIGNED:
				case oop.FLAG_ALIGNED:
				case oop.FLAG_CONTACT:
					if (codeBlock[pos] == oop.SPEC_ALL)
						pos++;
					else
						pos = ignoreDir(codeBlock, pos);
				break;
				case oop.FLAG_BLOCKED:
					pos = ignoreDir(codeBlock, pos);
				break;
				case oop.FLAG_CANPUSH:
				case oop.FLAG_SAFEPUSH:
				case oop.FLAG_SAFEPUSH1:
					pos = ignoreCoords(codeBlock, pos);
					pos = ignoreDir(codeBlock, pos);
				break;
				case oop.FLAG_ENERGIZED:
				break;
				case oop.FLAG_ANYTO:
					pos = ignoreDir(codeBlock, pos);
					pos = ignoreKind(codeBlock, pos);
				break;
				case oop.FLAG_ANYIN:
					pos = ignoreExpr(codeBlock, pos);
					pos = ignoreKind(codeBlock, pos);
				break;
				case oop.FLAG_SELFIN:
					pos = ignoreExpr(codeBlock, pos);
				break;
				case oop.FLAG_TYPEIS:
					pos = ignoreCoords(codeBlock, pos);
					pos = ignoreKind(codeBlock, pos);
				break;
				case oop.FLAG_BLOCKEDAT:
					pos = ignoreCoords(codeBlock, pos);
				break;
				case oop.FLAG_HASMESSAGE:
					pos = ignoreExpr(codeBlock, pos);
					pos++;
				break;
				case oop.FLAG_TEST:
				case oop.FLAG_VALID:
					pos = ignoreExpr(codeBlock, pos);
				break;
			}

			pos += 2;
			//pos = ignoreCommand(codeBlock, pos);
		break;

		case oop.CMD_FOREACH:
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
		break;
		case oop.CMD_FORMASK:
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreCoords(codeBlock, pos);
			pos++;
		break;
		case oop.CMD_FORREGION:
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
		break;
		case oop.CMD_FORNEXT:
		break;

		case oop.CMD_MODGUILABEL:
			pos++;
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
		break;
		case oop.CMD_SETGUILABEL:
			pos++;
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
		break;
		case oop.CMD_CONFMESSAGE:
			pos++;
			pos = ignoreExpr(codeBlock, pos);
			pos += 2;
		break;
		case oop.CMD_TEXTENTRY:
			pos++;
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos += 2;
		break;
		case oop.CMD_DRAWPEN:
			pos++;
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
		break;
		case oop.CMD_SELECTPEN:
			pos++;
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos++;
		break;
		case oop.CMD_DRAWBAR:
			pos++;
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
		break;

		case oop.CMD_CAMERAFOCUS:
			pos = ignoreCoords(codeBlock, pos);
		break;

		case oop.CMD_DRAWCHAR:
			pos = ignoreCoords(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
		break;
		case oop.CMD_ERASECHAR:
			pos = ignoreCoords(codeBlock, pos);
		break;
		case oop.CMD_DRAWGUICHAR:
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
		break;
		case oop.CMD_ERASEGUICHAR:
		case oop.CMD_GHOST:
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
		break;

		case oop.CMD_GROUPSETPOS:
		case oop.CMD_GROUPGO:
			pos = ignoreCoords(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
		break;

		case oop.CMD_GROUPTRY:
		case oop.CMD_GROUPTRYNOPUSH:
			pos = ignoreCoords(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos += 2;
		break;

		case oop.CMD_ATAN2:
			pos = ignoreCoords(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
		break;
		case oop.CMD_SMOOTHTEST:
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
		break;
		case oop.CMD_SMOOTHMOVE:
			pos = ignoreExpr(codeBlock, pos);
		break;

		case oop.CMD_READKEY:
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
		break;
		case oop.CMD_READMOUSE:
		break;

		case oop.CMD_SETCONFIGVAR:
		case oop.CMD_GETCONFIGVAR:
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
		break;
		case oop.CMD_DELCONFIGVAR:
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
		break;
		case oop.CMD_DELCONFIGHIVE:
		case oop.CMD_SYSTEMACTION:
			pos = ignoreExpr(codeBlock, pos);
		break;

		case oop.CMD_SCANLINES:
		case oop.CMD_BIT7ATTR:
			pos = ignoreExpr(codeBlock, pos);
		break;
		case oop.CMD_PALETTECOLOR:
		case oop.CMD_FADETOCOLOR:
		case oop.CMD_PALETTEBLOCK:
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
		break;
		case oop.CMD_FADETOBLOCK:
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
		break;
		case oop.CMD_CHARSELECT:
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
		break;
		case oop.CMD_POSTHS:
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
		break;
		case oop.CMD_GETHS:
		case oop.CMD_GETHSENTRY:
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
			pos = ignoreExpr(codeBlock, pos);
		break;

		default:
			opcodeTraceback(codeBlock, pos);
		break;
	}

	return pos;
}

// Find a label in a code block.
// If filtered, 0=Search unzapped, 1=Search zapped, 2=Search all, 3=Search FORNEXT,
// 4=Clear optimizations.
public static function findLabel(codeBlock:Array, mLabel:String, pos:int=0, filter:int=0):int {
	var done:Boolean = false;
	var i:int;
	var s:String;

	while (pos < codeBlock.length) {
		var cByte:int = codeBlock[pos++];
		switch (cByte) {
			case oop.CMD_LABEL:
				s = oop.pStrings[codeBlock[pos]];
				if (filter != 1)
				{
					if (s == mLabel)
						return (pos-1); // Found
					else if (s.length > mLabel.length)
					{
						// Original label-checking algorithm allowed for
						// "startswith" match, as long as the character
						// immediately following the length of the searched-for
						// label was not alpha or underscore.
						// It's really dumb but that's how it was supposed to work.
						if (s.substr(0, mLabel.length) == mLabel &&
							!oop.isAlpha(s, mLabel.length))
							return (pos-1); // Found
					}
				}

				pos += 2;
			break;
			case oop.CMD_COMMENT:
				s = oop.pStrings[codeBlock[pos]];
				restoreEarlyOut = false;
				if (filter == 1)
				{
					if (s == mLabel)
					{
						if (pos >= codeBlock.length)
							return (pos-1); // Found

						// Restore label-finding exits early if there is
						// alpha text immediately following the label.
						// Bizarre behavior in original ZZT engine.
						if (codeBlock[pos + 2] == oop.CMD_TEXT && restoredFirst)
						{
							s = oop.pStrings[codeBlock[pos + 3]];
							if (s.length > 0)
							{
								if (oop.isAlpha(s, 0))
								{
									// Very specific:  must be text, but not just
									// any text--it must be alpha or underscore.
									restoreEarlyOut = true;
									return -1;
								}
							}
						}

						return (pos-1); // Found
					}
					else if (s.length > mLabel.length)
					{
						// Original label-checking algorithm allowed for
						// "startswith" match, as long as the character
						// immediately following the length of the searched-for
						// label was not alpha or underscore.
						// It's really dumb but that's how it was supposed to work.
						if (s.substr(0, mLabel.length) == mLabel &&
							!oop.isAlpha(s, mLabel.length))
						{
							return (pos-1); // Found
						}
					}
				}
				else if (filter != 0)
				{
					if (s == mLabel)
						return (pos-1); // Found
				}

				pos += 2;
			break;

			case oop.CMD_SEND:
				if (filter == 4)
				{
					// Undo self-referential optimization
					if (codeBlock[pos] < 0)
					{
						i = -codeBlock[pos] + 1;
						codeBlock[pos] = codeBlock[i];
					}
				}
				pos++;
			break;
			case oop.CMD_DISPATCH:
				if (filter == 4)
				{
					// Undo zero-type-referential optimization
					if (codeBlock[pos] < 0)
					{
						i = -codeBlock[pos] + 1;
						codeBlock[pos] = codeBlocks[0][i];
					}
				}
				pos++;
			break;

			case oop.CMD_NAME:
			case oop.CMD_BIND:
			case oop.CMD_ZAP:
			case oop.CMD_RESTORE:
			case oop.CMD_PLAY:
			case oop.CMD_PLAYSOUND:
			case oop.CMD_USEGUI:
			case oop.CMD_ERROR:
			case oop.CMD_FALSEJUMP:
				pos++;
			break;

			case oop.CMD_NOP:
			case oop.CMD_PAUSE:
			case oop.CMD_UNPAUSE:
			case oop.CMD_ENDGAME:
			case oop.CMD_END:
			case oop.CMD_RESTART:
			case oop.CMD_LOCK:
			case oop.CMD_UNLOCK:
			case oop.CMD_DIE:
			case oop.CMD_DONEDISPATCH:
			case oop.CMD_UPDATELIT:
			case oop.CMD_UPDATEVIEWPORT:
			case oop.CMD_ERASEVIEWPORT:
			break;
			case oop.CMD_CHAR:
			case oop.CMD_CYCLE:
			case oop.CMD_COLOR:
			case oop.CMD_COLORALL:
			case oop.CMD_EXTRATURNS:
			case oop.CMD_SUSPENDDISPLAY:
			case oop.CMD_CHANGEBOARD:
			case oop.CMD_DISSOLVEVIEWPORT:
			case oop.CMD_SAVEBOARD:
			case oop.CMD_SAVEWORLD:
			case oop.CMD_LOADWORLD:
			case oop.CMD_RESTOREGAME:
			case oop.CMD_DUMPSE:
			case oop.CMD_SETPLAYER:
			case oop.CMD_CLEARREGION:
				pos = ignoreExpr(codeBlock, pos);
			break;
			case oop.CMD_SCROLLTOVISUALS:
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreDir(codeBlock, pos);
			break;
			case oop.CMD_SENDTONAME:
			case oop.CMD_ZAPTARGET:
			case oop.CMD_RESTORETARGET:
				pos += 2;
			break;
			case oop.CMD_SENDTO:
			case oop.CMD_DISPATCHTO:
				pos = ignoreExpr(codeBlock, pos);
				pos++;
			break;
			case oop.CMD_TEXT:
			case oop.CMD_TEXTCENTER:
			case oop.CMD_TEXTLINK:
			case oop.CMD_TEXTLINKFILE:
			case oop.CMD_DYNTEXT:
			case oop.CMD_DYNLINK:
			case oop.CMD_DYNTEXTVAR:
				pos = ignoreText(codeBlock, pos, cByte);
			break;
			case oop.CMD_SCROLLSTR:
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos++;
			break;
			case oop.CMD_SCROLLCOLOR:
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
			break;

			case oop.CMD_GO:
			case oop.CMD_FORCEGO:
			case oop.CMD_TRYSIMPLE:
			case oop.CMD_WALK:
				pos = ignoreDir(codeBlock, pos);
			break;
			case oop.CMD_TRY:
				pos = ignoreDir(codeBlock, pos);
				pos += 2;
				//pos = ignoreCommand(codeBlock, pos);
			break;
			case oop.CMD_PUSHATPOS:
				pos = ignoreCoords(codeBlock, pos);
				pos = ignoreDir(codeBlock, pos);
			break;

			case oop.CMD_BECOME:
				pos = ignoreKind(codeBlock, pos);
			break;

			case oop.CMD_SPAWN:
				pos++;
				pos = ignoreCoords(codeBlock, pos);
				pos = ignoreKind(codeBlock, pos);
			break;
			case oop.CMD_SPAWNGHOST:
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreCoords(codeBlock, pos);
				pos = ignoreKind(codeBlock, pos);
			break;
			case oop.CMD_PUT:
				pos = ignoreDir(codeBlock, pos);
				pos = ignoreKind(codeBlock, pos);
			break;
			case oop.CMD_SHOOT:
			case oop.CMD_THROWSTAR:
				pos++;
				pos = ignoreDir(codeBlock, pos);
			break;
			case oop.CMD_CHANGE:
				pos = ignoreKind(codeBlock, pos);
				pos = ignoreKind(codeBlock, pos);
			break;
			case oop.CMD_CHANGEREGION:
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreKind(codeBlock, pos);
				pos = ignoreKind(codeBlock, pos);
			break;
			case oop.CMD_SETPOS:
				pos = ignoreExpr(codeBlock, pos);
				pos++;
				pos = ignoreCoords(codeBlock, pos);
			break;
			case oop.CMD_TYPEAT:
			case oop.CMD_COLORAT:
			case oop.CMD_OBJAT:
			case oop.CMD_LITAT:
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreCoords(codeBlock, pos);
			break;

			case oop.CMD_CHAR4DIR:
				pos = ignoreDir(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
			break;
			case oop.CMD_DIR2UVECT8:
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
			break;
			case oop.CMD_OFFSETBYDIR:
				pos = ignoreCoords(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
			break;
			case oop.CMD_CLONE:
			case oop.CMD_LIGHTEN:
			case oop.CMD_DARKEN:
			case oop.CMD_DUMPSEAT:
			case oop.CMD_KILLPOS:
				pos = ignoreCoords(codeBlock, pos);
			break;
			case oop.CMD_TEXTTOGUI:
				pos++;
			break;
			case oop.CMD_TEXTTOGRID:
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
			break;
			case oop.CMD_SETREGION:
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreCoords(codeBlock, pos);
				pos = ignoreCoords(codeBlock, pos);
			break;
			case oop.CMD_SETPROPERTY:
			case oop.CMD_GETPROPERTY:
				pos++;
				pos = ignoreExpr(codeBlock, pos);
			break;
			case oop.CMD_CLEAR:
			case oop.CMD_EXECCOMMAND:
				pos = ignoreExpr(codeBlock, pos);
			break;
			case oop.CMD_SETTYPEINFO:
			case oop.CMD_GETTYPEINFO:
				pos = ignoreKind(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
			break;
			case oop.CMD_SUBSTR:
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
			break;
			case oop.CMD_INT:
			case oop.CMD_PLAYERINPUT:
			case oop.CMD_GETSOUND:
			case oop.CMD_STOPSOUND:
			case oop.CMD_SET:
			case oop.CMD_PUSHARRAY:
			case oop.CMD_POPARRAY:
			case oop.CMD_SETARRAY:
			case oop.CMD_LEN:
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
			break;
			case oop.CMD_RANDOM:
			case oop.CMD_MASTERVOLUME:
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
			break;

			case oop.CMD_SWITCHTYPE:
				pos = ignoreCoords(codeBlock, pos);
				i = codeBlock[pos++];
				while (i--)
				{
					pos = ignoreKind(codeBlock, pos);
					pos++;
				}
			break;
			case oop.CMD_SWITCHVALUE:
				pos = ignoreExpr(codeBlock, pos);
				i = codeBlock[pos++];
				while (i--)
				{
					pos = ignoreExprValue(codeBlock, pos, 0);
					pos++;
				}
			break;

			case oop.CMD_GIVE:
				if (codeBlock[pos] == oop.INV_KEY)
					pos += 2;
				else if (codeBlock[pos] == oop.INV_EXTRA)
					pos += 2;
				else
					pos++;

				pos = ignoreExpr(codeBlock, pos);
			break;
			case oop.CMD_TAKE:
				if (codeBlock[pos] == oop.INV_KEY)
					pos += 2;
				else if (codeBlock[pos] == oop.INV_EXTRA)
					pos += 2;
				else
					pos++;

				pos = ignoreExpr(codeBlock, pos);
				//pos = ignoreCommand(codeBlock, pos);
			break;

			case oop.CMD_IF:
				pos++;
				i = codeBlock[pos++];
				switch (i) {
					case oop.FLAG_ALWAYSTRUE:
					break;
					case oop.FLAG_GENERIC:
						pos++;
					break;
					case oop.FLAG_ANY:
						pos = ignoreKind(codeBlock, pos);
					break;
					case oop.FLAG_ALLIGNED:
					case oop.FLAG_ALIGNED:
					case oop.FLAG_CONTACT:
						if (codeBlock[pos] == oop.SPEC_ALL)
							pos++;
						else
							pos = ignoreDir(codeBlock, pos);
					break;
					case oop.FLAG_BLOCKED:
						pos = ignoreDir(codeBlock, pos);
					break;
					case oop.FLAG_CANPUSH:
					case oop.FLAG_SAFEPUSH:
					case oop.FLAG_SAFEPUSH1:
						pos = ignoreCoords(codeBlock, pos);
						pos = ignoreDir(codeBlock, pos);
					break;
					case oop.FLAG_ENERGIZED:
					break;
					case oop.FLAG_ANYTO:
						pos = ignoreDir(codeBlock, pos);
						pos = ignoreKind(codeBlock, pos);
					break;
					case oop.FLAG_ANYIN:
						pos = ignoreExpr(codeBlock, pos);
						pos = ignoreKind(codeBlock, pos);
					break;
					case oop.FLAG_SELFIN:
						pos = ignoreExpr(codeBlock, pos);
					break;
					case oop.FLAG_TYPEIS:
						pos = ignoreCoords(codeBlock, pos);
						pos = ignoreKind(codeBlock, pos);
					break;
					case oop.FLAG_BLOCKEDAT:
						pos = ignoreCoords(codeBlock, pos);
					break;
					case oop.FLAG_HASMESSAGE:
						pos = ignoreExpr(codeBlock, pos);
						pos++;
					break;
					case oop.FLAG_TEST:
					case oop.FLAG_VALID:
						pos = ignoreExpr(codeBlock, pos);
					break;
				}

				pos += 2;
				//pos = ignoreCommand(codeBlock, pos);
			break;

			case oop.CMD_FOREACH:
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
			break;
			case oop.CMD_FORMASK:
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreCoords(codeBlock, pos);
				pos++;
			break;
			case oop.CMD_FORREGION:
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
			break;
			case oop.CMD_FORNEXT:
				if (filter == 3)
					return pos; // Found
			break;

			case oop.CMD_MODGUILABEL:
				pos++;
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
			break;
			case oop.CMD_SETGUILABEL:
				pos++;
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
			break;
			case oop.CMD_CONFMESSAGE:
				pos++;
				pos = ignoreExpr(codeBlock, pos);
				pos += 2;
			break;
			case oop.CMD_TEXTENTRY:
				pos++;
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos += 2;
			break;
			case oop.CMD_DRAWPEN:
				pos++;
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
			break;
			case oop.CMD_SELECTPEN:
				pos++;
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos++;
			break;
			case oop.CMD_DRAWBAR:
				pos++;
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
			break;

			case oop.CMD_CAMERAFOCUS:
				pos = ignoreCoords(codeBlock, pos);
			break;

			case oop.CMD_DRAWCHAR:
				pos = ignoreCoords(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
			break;
			case oop.CMD_ERASECHAR:
				pos = ignoreCoords(codeBlock, pos);
			break;
			case oop.CMD_DRAWGUICHAR:
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
			break;
			case oop.CMD_ERASEGUICHAR:
			case oop.CMD_GHOST:
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
			break;
	
			case oop.CMD_GROUPSETPOS:
			case oop.CMD_GROUPGO:
				pos = ignoreCoords(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
			break;
	
			case oop.CMD_GROUPTRY:
			case oop.CMD_GROUPTRYNOPUSH:
				pos = ignoreCoords(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos += 2;
			break;
	
			case oop.CMD_ATAN2:
				pos = ignoreCoords(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
			break;
			case oop.CMD_SMOOTHTEST:
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
			break;
			case oop.CMD_SMOOTHMOVE:
				pos = ignoreExpr(codeBlock, pos);
			break;
	
			case oop.CMD_READKEY:
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
			break;
			case oop.CMD_READMOUSE:
			break;
	
			case oop.CMD_SETCONFIGVAR:
			case oop.CMD_GETCONFIGVAR:
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
			break;
			case oop.CMD_DELCONFIGVAR:
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
			break;
			case oop.CMD_DELCONFIGHIVE:
			case oop.CMD_SYSTEMACTION:
				pos = ignoreExpr(codeBlock, pos);
			break;

			case oop.CMD_SCANLINES:
			case oop.CMD_BIT7ATTR:
				pos = ignoreExpr(codeBlock, pos);
			break;
			case oop.CMD_PALETTECOLOR:
			case oop.CMD_FADETOCOLOR:
			case oop.CMD_PALETTEBLOCK:
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
			break;
			case oop.CMD_FADETOBLOCK:
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
			break;
			case oop.CMD_CHARSELECT:
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
			break;
			case oop.CMD_POSTHS:
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
			break;
			case oop.CMD_GETHS:
			case oop.CMD_GETHSENTRY:
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
				pos = ignoreExpr(codeBlock, pos);
			break;

			default:
				errorMsg("(Label scan) Bad opcode:  " + cByte + " for " + mLabel);
				opcodeTraceback(codeBlock, pos);
				return -1;
		}
	}

	return -1;
}

// Give estimated traceback of last-processed code.
public static function opcodeTraceback(codeBlock:Array, endPos:int):void {
	var startPos:int = endPos - 7;
	if (startPos < 0)
		startPos = 0;

	var overallStr:String = "";
	while (startPos < endPos)
	{
		var b:int = codeBlock[startPos++];
		if (b > 255 && b < oop.pStrings.length)
			overallStr += oop.pStrings[b];
		else if (b < 0 && -b <= oop.negTracebackLookup.length)
			overallStr += b.toString() + "-" + oop.negTracebackLookup[-b - 1];
		else if (b >= 0 && b < oop.posTracebackLookup.length)
			overallStr += b.toString() + "+" + oop.posTracebackLookup[b];
		else
			overallStr += b.toString();

		overallStr += " ";
	}

	trace(overallStr);
}

// Dump status element contents (and custom code, if present)
public static function dumpSE(relSE:SE):void {
	// Dump stringified copy of status element
	var str:String = relSE.toString();
	var dumpSplitter:Array = str.split("\n");
	for (var i:int = 0; i < dumpSplitter.length; i++)
		zzt.addMsgLine("", dumpSplitter[i]);

	// If custom code exists, dump that code
	if (relSE.extra.hasOwnProperty("CODEID"))
	{
		var codeID:int = relSE.extra["CODEID"] - numBuiltInCodeBlocksPlus;
		dumpSplitter = unCompCode[codeID].split(zzt.globalProps["CODEDELIMETER"]);

		zzt.addMsgLine("$", "CODE:");
		for (i = 0; i < dumpSplitter.length; i++)
			zzt.addMsgLine("", dumpSplitter[i]);
	}
}

// "Zap" a label in the target.
public static function zapTarget(relSE:SE, mLabel:String):void {
	var codeID:int = relSE.extra["CODEID"];
	var cBlock:Array = codeBlocks[codeID];
	var pos:int = findLabel(cBlock, mLabel);
	if (pos != -1)
	{
		// Change code to remark
		cBlock[pos] = oop.CMD_COMMENT;
		zapRecord.push(new ZapRecord(codeID, pos, 1, ZZTLoader.currentBoardSaveIndex));
	}
}

// "Restore" a label in the target.
public static function restoreTarget(relSE:SE, mLabel:String, overwriteLabel:String=""):void {
	var codeID:int = relSE.extra["CODEID"];
	var cBlock:Array = codeBlocks[codeID];
	var pos:int = 0;
	restoredFirst = false;
	do
	{
		pos = findLabel(cBlock, mLabel, pos, 1);
		if (pos != -1)
		{
			// Change code to label
			cBlock[pos] = oop.CMD_LABEL;
			zapRecord.push(new ZapRecord(codeID, pos, 2, ZZTLoader.currentBoardSaveIndex));

			pos += 3;
			restoredFirst = true;
		}
	} while (!restoreEarlyOut && pos != -1);
}

// Process a line of text.
public static function processText(cByte:int):Boolean {
	if (!doDispText)
	{
		// If no text had been queued on this iteration, initiate it.
		zzt.numTextLines = 0;
		zzt.msgNonBlank = false;
		zzt.msgScrollFormats = [];
		zzt.msgScrollText = [];
		zzt.msgScrollIsRestore = false;
		zzt.msgScrollFiles = false;
		if (thisSE.extra.hasOwnProperty("ONAME"))
			zzt.msgScrollObjName = thisSE.extra["ONAME"];
		else
			zzt.msgScrollObjName = "";

		if (thisSE.FLAGS & FL_DISPATCH)
			doDispText = 2; // Displayed from dispatched message specifically
		else
			doDispText = 1; // Displayed from normal object code execution
	}

	var lStr:String = "";
	var pos:int = 0;
	var pos2:int = 0;

	switch (cByte) {
		case oop.CMD_TEXT:
			zzt.addMsgLine("", getString());
		break;
		case oop.CMD_TEXTCENTER:
			lStr = getString();
			zzt.addMsgLine("$", lStr);
		break;
		case oop.CMD_TEXTLINK:
			lStr = getString();
			zzt.addMsgLine(lStr, getString());
		break;
		case oop.CMD_TEXTLINKFILE:
			lStr = "!" + getString();
			zzt.addMsgLine(lStr, getString());
		break;
		case oop.CMD_DYNTEXT:
			lStr = getString();
			lStr = dynFormatString(lStr);
			zzt.addMsgLine("", lStr);
		break;
		case oop.CMD_DYNLINK:
			lStr = getString();
			zzt.addMsgLine(lStr, dynFormatString(getString()));
		break;
		case oop.CMD_DUMPSE:
		break;
		case oop.CMD_SCROLLSTR:
			pos = intGetExpr();
			pos2 = intGetExpr();
			lStr = dynFormatString(getString());

			if (pos > 0)
				marqueeSize = pos;

			if (pos2 == 0)
			{
				// Queue text; don't scroll.
				if (lStr.length > 0)
					marqueeText = lStr;
				else
					marqueeText = utils.strReps(" ", marqueeSize);
			}
			else if (pos2 < 0)
			{
				// Scroll left.
				pos2 = -pos2;
				marqueeDir = -1;
				marqueeText += lStr + utils.strReps(" ", pos2 - lStr.length);
				marqueeText = marqueeText.substr(pos2);
			}
			else // pos2 > 0
			{
				// Scroll right.
				marqueeDir = 1;
				marqueeText =
					utils.strReps(" ", pos2 - lStr.length) + lStr + marqueeText;
				marqueeText = marqueeText.substr(0, marqueeText.length - pos2);
			}

			// Set output.
			if (marqueeDir == -1)
				zzt.addMsgLine("", marqueeText.substr(0, marqueeSize));
			else
				zzt.addMsgLine("",
					marqueeText.substr(marqueeText.length - marqueeSize, marqueeSize));
		break;
	}

	return true;
}

// For processed line(s) of text, decide how to display it.
// This can be either a toast message or a large scroll interface.
public static function displayText(allowSingularBlank:Boolean):Boolean {
	// Compress multiple blank lines into just one blank line.
	if (zzt.numTextLines > 1 && !zzt.msgNonBlank)
		zzt.numTextLines = 1;

	// Singular blank lines only toasted if originating from dispatched message.
	if (!allowSingularBlank && zzt.numTextLines == 1 && !zzt.msgNonBlank)
		return false;

	if (textTarget == TEXT_TARGET_GUI)
	{
		// Text is re-routed to a GUI label.
		zzt.textLinesToGui(textDestLabel);
	}
	else if (textTarget == TEXT_TARGET_GRID)
	{
		// Text is re-routed to a region.
		zzt.textLinesToRegion(textDestLabel, textDestType);
	}
	else if (zzt.numTextLines <= zzt.toastMsgSize)
	{
		// This will be a one- or two-line toast message.
		zzt.ToastMsg();
	}
	else
	{
		// This will be a larger message, shown in a "scroll" interface.
		if (thisSE.extra.hasOwnProperty("ONAME"))
			zzt.ScrollMsg(thisSE.extra["ONAME"]);
		else
			zzt.ScrollMsg(zzt.msgScrollObjName);

		// Remember the object responsible (for link-following purposes).
		linkFollowSE = thisSE;

		// When "scroll" interface must be displayed, turns are inherently over.
		turns = 0;
	}

	return true;
}

public static function ignoreText(codeBlock:Array, pos:int, cByte:int):int {
	switch (cByte) {
		case oop.CMD_TEXT:
		case oop.CMD_TEXTCENTER:
		case oop.CMD_DYNTEXT:
			pos++;
		break;
		case oop.CMD_TEXTLINK:
		case oop.CMD_TEXTLINKFILE:
		case oop.CMD_DYNLINK:
		case oop.CMD_DYNTEXTVAR:
			pos += 2;
		break;
	}

	return pos;
}

public static function dynFormatString(fmtStr:String):String {
	var idx:int = fmtStr.indexOf("$");
	if (idx == -1)
		return fmtStr;

	var doneStr:String = "";
	while (idx != -1) {
		doneStr += fmtStr.substring(0, idx);
		idx++;

		var isLocal:Boolean = false;
		var isProp:Boolean = false;
		if (idx < fmtStr.length)
		{
			if (fmtStr.charAt(idx) == ".")
			{
				isLocal = true;
				idx++;
			}
			else if (fmtStr.charAt(idx) == "~")
			{
				isProp = true;
				idx++;
			}
		}

		// Fetch variable value; replace in text.
		var nextIdx:int = oop.findNonKWDynamic(fmtStr, idx);
		var varName:String = fmtStr.substring(idx, nextIdx);
		var val:String = "";
		if (isLocal)
		{
			if (varName == "COLOR")
			{
				// Color is stored in grid.
				val = SE.getColor(thisSE.X, thisSE.Y).toString();
			}
			else if (thisSE.extra.hasOwnProperty(varName))
			{
				// Dereference operation retrieves extra value from dictionary
				val = thisSE.extra[varName].toString();
			}
			else if (thisSE.hasOwnProperty(varName))
			{
				// Dereference operation hits main member, not dictionary
				val = thisSE[varName].toString();
			}
		}
		else if (isProp)
		{
			if (zzt.boardProps.hasOwnProperty(varName))
				val = zzt.boardProps[varName].toString();
			else
				val = zzt.globalProps[varName].toString();
		}
		else
			val = getGlobalVarValue(varName).toString();

		// Remove part of string we just "digested."
		doneStr += val;
		fmtStr = fmtStr.substring(nextIdx);

		// Check for more variable names to replace.
		idx = fmtStr.indexOf("$");
	}

	doneStr += fmtStr;
	return doneStr;
}

public static function getGlobalVarValue(varName:String):Object {
	if (zzt.globals.hasOwnProperty(varName))
		return (zzt.globals[varName]);
	else
		return 0;
}

public static function setVariableFromRef(vType:int, varName:String, val:Object):void {
	if (vType == oop.SPEC_LOCALVAR)
	{
		// Set local variable.
		if (varName == "COLOR")
		{
			// Color is stored in grid.
			SE.setColor(thisSE.X, thisSE.Y, int(val));
		}
		else if (varName == "COLORALL")
		{
			// Color is stored in grid.
			SE.setColor(thisSE.X, thisSE.Y, int(val), false);
		}
		else if (thisSE.hasOwnProperty(varName))
			thisSE[varName] = val;
		else
			thisSE.extra[varName] = val;
	}
	else if (vType == oop.SPEC_PROPERTY)
	{
		// Set property.
		if (zzt.boardProps.hasOwnProperty(varName))
		{
			zzt.boardProps[varName] = val;
			if (varName == "ISDARK")
				SE.IsDark = zzt.boardProps[varName];
		}
		else
		{
			zzt.globalProps[varName] = val;
		}

		// Set property string and dispatch to ONPROPERTY handler.
		zzt.globals["$PROP"] = varName;
		briefDispatch(onPropPos, thisSE, blankSE);
	}
	else if (vType == oop.SPEC_GLOBALVAR)
	{
		// Set global variable.
		if (zzt.globals.hasOwnProperty(varName))
			classicSet = 0; // Replacement; no danger of hitting classic flag limit.
		zzt.globals[varName] = val;
	}
	else if (vType == oop.OP_ARR)
	{
		// Set array index.
		zzt.globals[varName][memberIdx] = val;
	}
	else
	{
		if (ptr2SetInExpr == null)
			errorMsg("Attempt to set member '" + varName + "' of null object");
		else if (varName == "COLOR")
		{
			// Color is stored in grid.
			SE.setColor(ptr2SetInExpr.X, ptr2SetInExpr.Y, int(val));
		}
		else if (varName == "COLORALL")
		{
			// Color is stored in grid.
			SE.setColor(ptr2SetInExpr.X, ptr2SetInExpr.Y, int(val), false);
		}
		else if (varName == "DIR")
		{
			// Direction is composite of steps.
			ptr2SetInExpr.STEPX = getStepXFromDir4(int(val));
			ptr2SetInExpr.STEPY = getStepYFromDir4(int(val));
		}
		else if (ptr2SetInExpr.extra.hasOwnProperty(varName))
		{
			// Dereference operation retrieves extra value from dictionary
			ptr2SetInExpr.extra[varName] = val;
		}
		else if (ptr2SetInExpr.hasOwnProperty(varName))
		{
			// Dereference operation hits main member, not dictionary
			ptr2SetInExpr[varName] = val;
		}
	}
}

public static function getRegion(regionName:String):Array {
	if (zzt.regions.hasOwnProperty(regionName))
		return (zzt.regions[regionName]);
	else
		return noRegion;
}

public static function getMask(maskName:String):Array {
	if (zzt.masks.hasOwnProperty(maskName))
		return (zzt.masks[maskName]);
	else
		return noMask;
}

public static function getDir():int {
	var dir:int = 0;
	var adder:int = 0;
	var qualifier:int = -1;
	var done:Boolean = false;
	var coords:Array = [1, 1];

	while (!done) {
		var cByte:int = getInt();
		switch (cByte) {
			case oop.SPEC_EXPRPRESENT:
				dir = intGetExpr();
				done = true;
			break;
			case oop.DIR_E:
				dir = 0;
				done = true;
			break;
			case oop.DIR_S:
				dir = 1;
				done = true;
			break;
			case oop.DIR_W:
				dir = 2;
				done = true;
			break;
			case oop.DIR_N:
				dir = 3;
				done = true;
			break;
			case oop.DIR_I:
				dir = -1;
				done = true;
			break;
			case oop.DIR_SEEK:
				dir = calcDirTowards(thisSE.X, thisSE.Y, playerSE.X, playerSE.Y,
					zzt.Use40Column);
				if (zzt.globalProps["ENERGIZERCYCLES"] > 0 && dir != -1)
					dir = (dir + 2 & 3); // Invert seek (Pac-Man logic)
				done = true;
			break;
			case oop.DIR_FLOW:
				dir = getDir4FromSteps(thisSE.STEPX, thisSE.STEPY);
				done = true;
			break;
			case oop.DIR_RNDNS:
				dir = utils.zerothru(1) * 2 + 1;
				done = true;
			break;
			case oop.DIR_RNDNE:
				dir = (utils.zerothru(1) - 1) & 3;
				done = true;
			break;
			case oop.DIR_RND:
				if (zzt.Use40Column)
					dir = utils.dir4norm();
				else
					dir = utils.dir4skewed();
				done = true;
			break;
			case oop.DIR_RNDSQ:
				dir = utils.dir4norm();
				done = true;
			break;
			case oop.DIR_CW:
				adder += 1;
			break;
			case oop.DIR_CCW:
				adder += 3;
			break;
			case oop.DIR_RNDP:
				if (utils.eitheror())
					adder += 1;
				else
					adder += 3;
			break;
			case oop.DIR_OPP:
				adder += 2;
			break;
			case oop.DIR_TOWARDS:
				getCoords(coords);
				dir = calcDirTowards(thisSE.X, thisSE.Y, coords[0], coords[1],
					zzt.Use40Column);
				done = true;
			break;
			case oop.DIR_MAJOR:
			case oop.DIR_MINOR:
				qualifier = cByte;
			break;
			case oop.DIR_UNDER:
			case oop.DIR_OVER:
				return cByte;
			break;
		}
	}

	// Apply major/minor qualifier
	if (qualifier == oop.DIR_MAJOR)
		dir = majorDir;
	else if (qualifier == oop.DIR_MINOR)
		dir = minorDir;

	// Clip direction.  Note that idle remains at -1.
	dir += adder;
	if (dir >= 4)
		dir &= 3;

	return dir;
}

public static function ignoreDir(codeBlock:Array, pos:int):int {
	var done:Boolean = false;
	while (!done) {
		var cByte:int = codeBlock[pos++];
		switch (cByte) {
			case oop.DIR_CW:
			case oop.DIR_CCW:
			case oop.DIR_RNDP:
			case oop.DIR_OPP:
			case oop.DIR_MAJOR:
			case oop.DIR_MINOR:
			break;
			case oop.DIR_TOWARDS:
				pos = ignoreCoords(codeBlock, pos);
				done = true;
			break;
			case oop.SPEC_EXPRPRESENT:
				pos = ignoreExpr(codeBlock, pos);
				done = true;
			break;
			default:
				done = true;
			break;
		}
	}

	return pos;
}

public static function calcDirTowards(origX:int, origY:int, destX:int, destY:int,
	perfectSquare:int):int {
	// Get differences
	destX -= origX;
	destY -= origY;
	var magX:int = utils.iabs(destX);
	var magY:int = utils.iabs(destY);

	// Figure out which is the dominant direction.
	if (magX == 0 && magY == 0)
	{
		// Origin:  idle.
		majorDir = -1;
		minorDir = -1;
		return -1;
	}

	if (magX >= magY)
	{
		majorDir = getDir4FromSteps(utils.isgn(destX), 0);
		minorDir = getDir4FromSteps(0, utils.isgn(destY));
	}
	else
	{
		majorDir = getDir4FromSteps(0, utils.isgn(destY));
		minorDir = getDir4FromSteps(utils.isgn(destX), 0);
	}

	if (magX == 0 || magY == 0)
		return majorDir;

	if (perfectSquare)
	{
		if (utils.eitheror())
			return getDir4FromSteps(utils.isgn(destX), 0);
		else
			return getDir4FromSteps(0, utils.isgn(destY));
	}
	else
	{
		if (utils.noutofn(2, 3))
			return getDir4FromSteps(utils.isgn(destX), 0);
		else
			return getDir4FromSteps(0, utils.isgn(destY));
	}
}

public static function getCoords(destCoords:Array):void {
	var cByte:int = getInt();
	if (cByte == oop.SPEC_ABS)
	{
		destCoords[0] = intGetExpr();
		destCoords[1] = intGetExpr();
	}
	else if (cByte == oop.SPEC_POLAR)
	{
		var mag:int = intGetExpr();
		var dir:int = intGetExpr() & 3;
		destCoords[0] = thisSE.X + (mag * getStepXFromDir4(dir));
		destCoords[1] = thisSE.Y + (mag * getStepYFromDir4(dir));
	}
	else
	{
		if (cByte == oop.SPEC_ADD)
			destCoords[0] = thisSE.X + intGetExpr();
		else
			destCoords[0] = thisSE.X - intGetExpr();

		cByte = getInt();
		if (cByte == oop.SPEC_ADD)
			destCoords[1] = thisSE.Y + intGetExpr();
		else
			destCoords[1] = thisSE.Y - intGetExpr();
	}
}

public static function getRelCoords(destCoords:Array):void {
	var cByte:int = getInt();
	if (cByte == oop.SPEC_ABS)
	{
		destCoords[0] = 0;
		destCoords[1] = 0;
	}
	else if (cByte == oop.SPEC_POLAR)
	{
		var mag:int = intGetExpr();
		var dir:int = intGetExpr() & 3;
		destCoords[0] = (mag * getStepXFromDir4(dir));
		destCoords[1] = (mag * getStepYFromDir4(dir));
	}
	else
	{
		if (cByte == oop.SPEC_ADD)
			destCoords[0] = intGetExpr();
		else
			destCoords[0] = -intGetExpr();

		cByte = getInt();
		if (cByte == oop.SPEC_ADD)
			destCoords[1] = intGetExpr();
		else
			destCoords[1] = -intGetExpr();
	}
}

public static function ignoreCoords(codeBlock:Array, pos:int):int {
	var cByte:int = codeBlock[pos++];
	if (cByte == oop.SPEC_ABS || cByte == oop.SPEC_POLAR)
	{
		pos = ignoreExpr(codeBlock, pos);
		pos = ignoreExpr(codeBlock, pos);
	}
	else
	{
		pos = ignoreExpr(codeBlock, pos);
		pos++;
		pos = ignoreExpr(codeBlock, pos);
	}

	return pos;
}

public static function getKind(allowAll:Boolean=false):int {
	var cByte:int = getInt();
	if (cByte == oop.SPEC_KINDMISC)
	{
		// Expression
		kwargPos = -1;
		var kByte:int = getInt();
		if (!allowAll && kByte == oop.MISC_ALL)
		{
			errorMsg("'ALL' type cannot be used here");
			return 0;
		}

		return -kByte;
	}
	else if (cByte == oop.SPEC_KINDEXPR)
	{
		// Expression determines kind.
		cByte = intGetExpr();
	}
	else
	{
		// Kind is a simple integer.
		cByte = typeTrans2(getInt());
	}

	// Save keyword arg position; we skip past args
	// and will evaluate them later.
	kwargPos = thisSE.IP;
	kByte = getInt();
	while (kByte != oop.SPEC_KWARGEND)
	{
		getExpr();
		kByte = getInt();
	}

	return cByte;
}

public static function ignoreKind(codeBlock:Array, pos:int):int {
	var cByte:int = codeBlock[pos++];
	if (cByte == oop.SPEC_KINDMISC)
	{
		return (pos+1);
	}
	if (cByte == oop.SPEC_KINDEXPR)
	{
		pos = ignoreExpr(codeBlock, pos);
	}
	else
	{
		pos++;
	}

	var kByte:int = codeBlock[pos++];
	while (kByte != oop.SPEC_KWARGEND)
	{
		pos = ignoreExpr(codeBlock, pos);
		kByte = codeBlock[pos++];
	}

	return pos;
}

// From a mask name, a WAD lump, or a global array, retrieve a "flat" sequence.
// The resulting array ignores rows or columns.
public static function getFlatSequence(o:Object, breakOutBits:Boolean=false):Array {
	var seq:Array = [];

	if (o is String)
	{
		// Mask name or WAD lump
		var s:String = o as String;
		var maskArray:Array = getMask(s);

		if (s == "NONE")
		{
			// Intentional NONE string usually has special handling.
			return null;
		}
		else if (maskArray == noMask)
		{
			// Take values out of WAD lump.
			for (var i:int = 0; i < ZZTLoader.extraLumps.length; i++) {
				if (utils.startswith(ZZTLoader.extraLumps[i].name, s))
				{
					var ba:ByteArray = ZZTLoader.extraLumpBinary[i];
					for (var j:int = 0; j < ba.length; j++)
						seq.push(ba[j]);

					break;
				}
			}

			if (seq.length == 0)
			{
				// Requested sequence can't be found.
				return null;
			}
		}
		else
		{
			// Take values out of mask.
			breakOutBits = false;
			var xSize:int = maskArray[0].length;
			var ySize:int = maskArray.length;
			for (var y:int = 0; y < ySize; y++) {
				for (var x:int = 0; x < xSize; x++) {
					seq.push(maskArray[y][x]);
				}
			}
		}
	}
	else if (o is ByteArray)
	{
		// ByteArray
		ba = o as ByteArray;
		for (j = 0; j < ba.length; j++)
			seq.push(ba[j]);
	}
	else
	{
		// Global variable (must be array)
		breakOutBits = false;
		var a:Array = o as Array;
		for (j = 0; j < a.length; j++)
		{
			if (a[j] is Array) {
				for (var p:int = 0; p < a[j].length; p++)
					seq.push(a[j][p]);
			}
			else
				seq.push(a[j]);
		}
	}

	// Take sequence verbatim.
	if (!breakOutBits)
		return seq;

	// Sequence is actually bit fields; break into separate bytes.
	var seq2:Array = [];
	for (var n:int = 0; n < seq.length; n++) {
		var val:int = seq[n];
		for (var bf:int = 0; bf < 8; bf++)
		{
			seq2.push(((val & 0x80) != 0) ? 1 : 0);
			val <<= 1;
		}
	}

	return seq2;
}

// Create bit fields from a number sequence.
public static function makeBitSequence(a:Array):ByteArray {
	var ba:ByteArray = new ByteArray();

	// Sequence is actually bit fields; break into separate bytes.
	for (var n:int = 0; n < a.length;) {
		var bMask:int = 0x80;
		var val:int = 0;

		for (var bf:int = 0; bf < 8 && n < a.length; n++, bf++) {
			if (a[n] != 0)
				val |= bMask;
			bMask >>= 1;
		}

		ba.writeByte(val);
	}

	return ba;
}

// Get full expression (value) and cast to integer.
public static function intGetExpr():int {
	var o:Object = getExpr();
	if (o is int || o is Boolean)
		return int(o);
	else
		return 0;
}

// Get full expression (value) and cast to string.
public static function strGetExpr():String {
	var o:Object = getExpr();
	if (o == null)
		return "";
	else
		return o.toString();
}

// Get full expression (value) and cast to string;
// compatible with older non-quoted strings
public static function regionGetExpr():String {
	if (peekInt() == oop.SPEC_GLOBALVAR)
	{
		thisSE.IP++;
		var member:String = getString();
		if (!zzt.globals.hasOwnProperty(member) || forceRegionLiteral)
		{
			// Old-style string represents non-quoted region.
			return member;
		}

		thisSE.IP -= 2;
	}

	// Evaluate expression normally.
	return (strGetExpr());
}

// Get full expression (value).
public static function getExpr():Object {
	// If expression is simple, we read only a single value.
	var cByte:int = peekInt();
	if (cByte != oop.SPEC_EXPRPRESENT)
		return getExprValue(cByte);

	// Expression is complex; we read many values.
	thisSE.IP++;
	var rObj:Object = null;
	var refSE:SE;
	while (cByte != oop.SPEC_EXPREND)
	{
		// Get expression and apply last operator.
		var eObj:Object = getExprValue(cByte);
		switch (cByte) {
			case oop.SPEC_EXPRPRESENT:
				// Simple value transfer
				rObj = eObj;
			break;
			case oop.OP_ADD:
				rObj += eObj;
			break;
			case oop.OP_SUB:
				rObj = Number(rObj) - Number(eObj);
			break;
			case oop.OP_MUL:
				rObj = Number(rObj) * Number(eObj);
			break;
			case oop.OP_DIV:
				rObj = int(Number(rObj) / Number(eObj));
			break;
			case oop.OP_EQU:
				rObj = Boolean(rObj == eObj);
			break;
			case oop.OP_NEQ:
				rObj = Boolean(rObj != eObj);
			break;
			case oop.OP_GRE:
				rObj = Boolean(rObj > eObj);
			break;
			case oop.OP_LES:
				rObj = Boolean(rObj < eObj);
			break;
			case oop.OP_GOE:
				rObj = Boolean(rObj >= eObj);
			break;
			case oop.OP_LOE:
				rObj = Boolean(rObj <= eObj);
			break;
			case oop.OP_AND:
				rObj = Number(rObj) & Number(eObj);
			break;
			case oop.OP_OR:
				rObj = Number(rObj) | Number(eObj);
			break;
			case oop.OP_XOR:
				rObj = Number(rObj) ^ Number(eObj);
			break;
			case oop.OP_ARR:
				exprRefSrc2 = rObj as Array;
				rObj = rObj[eObj as int];
			break;
			case oop.OP_DOT:
				// Indirection
				refSE = SE.getStatElem(rObj as int);
				if (refSE == null)
				{
					errorMsg("Null dereference for member:  " + eObj.toString());
					return 0;
				}
				else if (lastExprType != oop.SPEC_GLOBALVAR)
				{
					errorMsg("Bad indirection:  " + eObj.toString());
					return 0;
				}
				else if (eObj == "COLOR")
				{
					// Dereference operation retrieves color
					rObj = SE.getColor(refSE.X, refSE.Y);
				}
				else if (eObj == "DIR")
				{
					// Dereference operation retrieves direction (composite of steps)
					rObj = getDir4FromSteps(refSE.STEPX, refSE.STEPY);
				}
				else if (refSE.extra.hasOwnProperty(eObj))
				{
					// Dereference operation retrieves extra value from dictionary
					rObj = refSE.extra[eObj];
				}
				else if (refSE.hasOwnProperty(eObj))
				{
					// Dereference operation hits main member, not dictionary
					rObj = refSE[eObj];
				}
				else
				{
					errorMsg("Bad indirection:  " + eObj.toString());
					return 0;
				}
			break;
		}

		cByte = getInt();
	}

	return rObj;
}

// Get individual expression value.
public static function getExprValue(fromOp:int):Object {
	var member:String;
	var cByte:int = getInt();
	lastExprType = cByte;

	switch (cByte) {
		case oop.CMD_ERROR:
			errorMsg("EXPRESSION ERROR:  " + getString());
			opcodeTraceback(code, thisSE.IP);
			return -1;
		case oop.SPEC_BOOLEAN:
			classicSet += 1; // One half of classic flag limit requirement
			return getInt();
		case oop.SPEC_NUMCONST:
			return getInt();
		case oop.SPEC_KINDCONST:
			return typeTrans2(getInt());
		case oop.SPEC_STRCONST:
			return getString();
		case oop.SPEC_DIRCONST:
			return getDir();
		case oop.SPEC_LOCALVAR:
			member = getString();
			if (member == "COLOR")
			{
				// Color is stored in grid.
				return (SE.getColor(thisSE.X, thisSE.Y));
			}
			else if (member == "DIR")
			{
				// Direction is composite of steps.
				return (getDir4FromSteps(thisSE.STEPX, thisSE.STEPY));
			}
			else if (thisSE.extra.hasOwnProperty(member))
			{
				// Dereference operation retrieves extra value from dictionary
				return thisSE.extra[member];
			}
			else if (thisSE.hasOwnProperty(member))
			{
				// Dereference operation hits main member, not dictionary
				return thisSE[member];
			}

			errorMsg("Bad indirection:  " + member);
			return -1;

		case oop.SPEC_PROPERTY:
			member = getString();
			if (zzt.boardProps.hasOwnProperty(member))
			{
				// Board property
				return zzt.boardProps[member];
			}
			else if (zzt.globalProps.hasOwnProperty(member))
			{
				// World property
				return zzt.globalProps[member];
			}

			errorMsg("No such property:  " + member);
			return -1;

		case oop.SPEC_GLOBALVAR:
			member = getString();
			if (fromOp == oop.OP_DOT)
			{
				// Member; just return string.
				return member;
			}
			else if (zzt.globals.hasOwnProperty(member))
			{
				// Return global variable
				return zzt.globals[member];
			}

			// If global variable does not exist, can't dereference.
			errorMsg("Variable does not exist:  " + member);
			return -1;

		case oop.SPEC_SELF:
			getInt(); // Dummy argument
			assignID(thisSE);
			return thisSE.myID;
	}

	errorMsg("Bad expression value:  " + cByte);
	getInt();
	return -1;
}

// Get expression reference.
public static function getExprRef():String {
	// There are three types of expression references that can be returned:
	// 1) Local object member (string)
	// 2) Global variable (string)
	// 3) Global variable acting as indirected pointer to object member (string.string)
	var member:String;
	var cByte:int = getInt();
	var mByte:int;
	lastExprType = cByte;

	switch (cByte) {
		case oop.CMD_ERROR:
			errorMsg("EXPR REF ERROR:  " + getString());
			opcodeTraceback(code, thisSE.IP);
			return "";
		case oop.SPEC_LOCALVAR:
			member = getString();
			return member;
		case oop.SPEC_PROPERTY:
			member = getString();
			return member;
		case oop.SPEC_GLOBALVAR:
			classicSet += 1; // One half of classic flag limit requirement
			member = getString();
			return member;
		case oop.SPEC_EXPRPRESENT:
			if (getInt() == oop.SPEC_GLOBALVAR)
			{
				member = getString();
				ptr2SetInExpr = SE.getStatElem(zzt.globals[member]);
				mByte = getInt();
				if (mByte == oop.OP_DOT)
				{
					if (getInt() == oop.SPEC_GLOBALVAR)
					{
						member = getString();
						getInt(); // oop.SPEC_EXPREND
						return member;
					}
				}
				else if (mByte == oop.OP_ARR)
				{
					memberIdx = int(getExprValue(oop.OP_ARR));
					getInt(); // oop.SPEC_EXPREND
					lastExprType = oop.OP_ARR;
					return member;
				}
			}
			break;
	}

	errorMsg("L-Value required");
	return "";
}

public static function ignoreExpr(codeBlock:Array, pos:int):int {
	// If expression is simple, we read only a single value.
	var cByte:int = codeBlock[pos];
	if (cByte != oop.SPEC_EXPRPRESENT)
		return ignoreExprValue(codeBlock, pos, cByte);

	// Expression is complex; we read many values.
	pos++;
	while (cByte != oop.SPEC_EXPREND)
	{
		pos = ignoreExprValue(codeBlock, pos, cByte);
		cByte = codeBlock[pos++];
		if (pos >= codeBlock.length)
			break;
	}

	return pos;
}

public static function ignoreExprValue(codeBlock:Array, pos:int, cByte:int):int {
	if (codeBlock[pos] == oop.SPEC_DIRCONST)
		return ignoreDir(codeBlock, pos + 1);
	else
	{
		// Type + Integer or string
		return (pos + 2);
	}
}

public static function getSEFromOName(oName:String, restart:Boolean=true):SE {
	if (oName.toUpperCase() == "ALL")
	{
		if (restart)
			return SE.getStatElemOwnCode();
		else
			return SE.getStatElemOwnCode(SE.statIter);
	}
	else if (oName.toUpperCase() == "OTHERS")
	{
		var otherSE:SE;
		if (restart)
			otherSE = SE.getStatElemOwnCode();
		else
			otherSE = SE.getStatElemOwnCode(SE.statIter);

		// Skip over self
		if (otherSE == thisSE)
			otherSE = SE.getStatElemOwnCode(SE.statIter);

		return otherSE;
	}
	else
	{
		if (restart)
			return SE.getONAMEMatching(oName.toUpperCase());
		else
			return SE.getONAMEMatching(oName.toUpperCase(), SE.statIter);
	}
}

public static function killSE(x:int, y:int):void {
	var relSE:SE = SE.getStatElemAt(x, y);
	if (relSE)
	{
		if (relSE.TYPE == zzt.bulletType)
		{
			if (relSE.extra["P1"] == 0)
				zzt.boardProps["CURPLAYERSHOTS"] -= 1;
		}

		relSE.FLAGS |= FL_IDLE + FL_DEAD;
		relSE.eraseSelfSquare(false);
	}
	else
	{
		SE.setStatElemAt(x, y, null);
	}
}

public static function validCoords(coords:Array, allowBoardEdge=false):Boolean {
	return validXY(coords[0], coords[1], allowBoardEdge);
}

public static function validXY(x:int, y:int, allowBoardEdge=false):Boolean {
	if (allowBoardEdge)
		return Boolean(x >= 0 && y >= 0 && x <= SE.gridWidth + 1 && y <= SE.gridHeight + 1);
	else
		return Boolean(x > 0 && y > 0 && x <= SE.gridWidth && y <= SE.gridHeight);
}

public static function validXYM1(x:int, y:int):Boolean {
	return Boolean(x > 0 && y > 0 && x <= SE.gridWidth && y <= SE.gridHeight - 1);
}

public static function createKind(x:int, y:int, newKind:int, createFlags:int=0):SE {
	// Fetch current color info
	var useUnderColor:Boolean = true;
	var colorToSet:int = SE.getColor(x, y);
	lastKindColor = colorToSet;

	// If CLONE type used, make a copy of that.
	if (newKind == -oop.MISC_CLONE)
		return createClone(x, y, createFlags);

	// Get kind and status element at location.
	var oldSE:SE = SE.getStatElemAt(x, y);
	var oldKind:int = SE.getType(x, y);

	// Preserve IP; set to keyword arg position
	var oldIP:int = thisSE.IP;
	thisSE.IP = kwargPos;

	// If no status element, just show type at square.
	var eInfo:ElementInfo = typeList[newKind];
	if (eInfo.NoStat)
	{
		if (oldSE && (createFlags & CF_UNDERLAYER) != 0)
		{
			// Modify type and color under the status element.
			if (kwargPos == -1)
			{
				if (eInfo.DominantColor)
					colorToSet = eInfo.COLOR;
			}
			else
			{
				var kVal:int = getInt();
				if (eInfo.DominantColor)
					colorToSet = eInfo.COLOR;
				else if (kVal == oop.KWARG_COLOR)
					colorToSet = intGetExpr();
			}

			lastKindColor = colorToSet;
			oldSE.UNDERID = newKind;
			oldSE.UNDERCOLOR = lastKindColor;
			thisSE.IP = oldIP;
			return null;
		}

		// Erase status element.
		if (oldSE)
		{
			// "Natural" color reproduction from PASSAGE takes shown color
			// instead of stored color.
			if (typeList[oldKind].NUMBER == 11)
				colorToSet = oldSE.extra["P2"];

			if (oldSE.UNDERID == newKind)
			{
				if (zzt.globalProps["BECOMESAMECOLOR"])
					oldSE.UNDERCOLOR = colorToSet;
			}
			else if (createFlags & CF_RETAINCOLOR)
				oldSE.UNDERCOLOR = colorToSet;

			if (oldSE.TYPE == zzt.bulletType)
			{
				if (oldSE.extra["P1"] == 0)
					zzt.boardProps["CURPLAYERSHOTS"] -= 1;
			}

			oldSE.FLAGS |= FL_IDLE + FL_DEAD;
			oldSE.eraseSelfSquare(false);
		}

		if (typeList[oldKind].NUMBER == 9)
		{
			// "Natural" color reproduction from DOOR takes shown color
			// instead of stored color.
			colorToSet = (((colorToSet << 4) & 240) ^ 128) + ((colorToSet >> 4) & 15);
			SE.setColor(x, y, colorToSet, false);
		}
		if (typeList[newKind].NUMBER == 9)
		{
			// "Natural" color reproduction to DOOR forces FG to white.
			colorToSet = (colorToSet & 15) | 240;
			SE.setColor(x, y, colorToSet, false);
		}

		// We set type and color.
		SE.setStatElemAt(x, y, null);
		SE.setType(x, y, newKind);
		if (kwargPos == -1)
		{
			if (eInfo.DominantColor)
				colorToSet = eInfo.COLOR;

			// EMPTY target type forces a virtual default color of black-FG-on-light-grey BG.
			if (newKind == 0)
				colorToSet = 112;

			SE.setColor(x, y, colorToSet, false);
		}
		else
		{
			kVal = getInt();
			if (eInfo.DominantColor)
			{
				colorToSet = eInfo.COLOR;
				SE.setColor(x, y, colorToSet, false);
			}
			else if (kVal == oop.KWARG_COLOR)
			{
				// Can take one and only one possible kwarg:  color.
				colorToSet = intGetExpr();

				// "Natural" color reproduction to DOOR forces FG to white.
				if (typeList[newKind].NUMBER == 9)
					colorToSet = colorToSet | 240;

				SE.setColor(x, y, colorToSet, false);
			}
			else
			{
				// EMPTY target type forces a virtual default color of black-FG-on-light-grey BG.
				if (newKind == 0)
				{
					colorToSet = 112;
					SE.setColor(x, y, colorToSet, false);
				}
			}
		}

		// Display type immediately.
		thisSE.IP = oldIP;
		SE.displaySquare(x, y);
		return null;
	}

	// Clip against max stat element count.
	if (SE.statElem.length - SE.statLessCount >= zzt.globalProps["MAXSTATELEMENTCOUNT"])
	{
		//trace("limit");
		thisSE.IP = oldIP;
		return null;
	}

	var relSE:SE = null;
	if (oldSE != null && (createFlags & (CF_RETAINSE | CF_GHOSTED)) == CF_RETAINSE)
	{
		// "Natural" color reproduction from PASSAGE takes shown color
		// instead of stored color.
		if (typeList[oldKind].NUMBER == 11)
			colorToSet = oldSE.extra["P2"];

		if (newKind == oldSE.TYPE)
		{
			// Special:  if we are retaining SE content at current position,
			// we do not remove the status element if it is an identical type.
			relSE = oldSE;

			if (typeList[oldKind].NUMBER == 11)
				oldSE.extra["P2"] |= 512;
		}
	}

	lastKindColor = colorToSet;
	if (!relSE)
	{
		// Erase status element if one is already present.
		if (createFlags & CF_GHOSTED)
		{
			// No overwrites for pre-ghosted SE.
		}
		else if (oldSE)
		{
			if (oldSE.UNDERID == newKind)
			{
				if (zzt.globalProps["BECOMESAMECOLOR"])
					oldSE.UNDERCOLOR = colorToSet;
			}

			if (oldSE.TYPE == zzt.bulletType)
			{
				if (oldSE.extra["P1"] == 0)
					zzt.boardProps["CURPLAYERSHOTS"] -= 1;
			}

			oldSE.FLAGS |= FL_IDLE + FL_DEAD;
			oldSE.eraseSelfSquare(false);
		}
		else
		{
			if (typeList[oldKind].NUMBER == 9)
			{
				// "Natural" color reproduction from DOOR takes shown color
				// instead of stored color.
				colorToSet = (((colorToSet << 4) & 240) ^ 128) + ((colorToSet >> 4) & 15);
				SE.setColor(x, y, colorToSet, false);
			}

			if (typeList[oldKind].BlockObject && (createFlags & CF_REMOVEIFBLOCKING))
			{
				// Don't make previous tile into "floor."
				SE.setType(x, y, 0);
			}
		}

		// Create new SE.
		if (oldKind == 0)
			SE.setColor(x, y, colorToSet & 0x8F, false);

		if ((createFlags & CF_GHOSTED) == 0)
		{
			relSE = new SE(newKind, x, y);
			SE.setStatElemAt(x, y, relSE);
		}
		else
		{
			relSE = new SE(newKind, x, y, -1000, true);
			relSE.FLAGS = FL_GHOST;
		}

		SE.statElem.push(relSE);
		lastKindColor = eInfo.COLOR;
	}

	if (kwargPos == -1)
	{
		if (!eInfo.DominantColor && (createFlags & CF_GHOSTED) == 0)
		{
			SE.setColor(relSE.X, relSE.Y, colorToSet, useUnderColor);
		}

		thisSE.IP = oldIP;
		return relSE; // No kwargs
	}

	var kByte:int = getInt();
	while (kByte != oop.SPEC_KWARGEND)
	{
		// The expression is an integer for nearly all kwargs.
		var oVal:Object = getExpr();
		kVal = utils.int0(oVal.toString());

		// The kwarg index determines what we set.
		switch (kByte) {
			case oop.KWARG_TYPE:
				relSE.TYPE = kVal;
			break;
			case oop.KWARG_X:
				relSE.X = kVal;
			break;
			case oop.KWARG_Y:
				relSE.Y = kVal;
			break;
			case oop.KWARG_STEPX:
				relSE.STEPX = kVal;
			break;
			case oop.KWARG_STEPY:
				relSE.STEPY = kVal;
			break;
			case oop.KWARG_CYCLE:
				relSE.CYCLE = kVal;
			break;
			case oop.KWARG_P1:
				relSE.extra["P1"] = kVal;
			break;
			case oop.KWARG_P2:
				relSE.extra["P2"] = kVal;
			break;
			case oop.KWARG_P3:
				relSE.extra["P3"] = kVal;
			break;
			case oop.KWARG_FOLLOWER:
				relSE.extra["FOLLOWER"] = kVal;
			break;
			case oop.KWARG_LEADER:
				relSE.extra["LEADER"] = kVal;
			break;
			case oop.KWARG_UNDERID:
				relSE.UNDERID = kVal;
			break;
			case oop.KWARG_UNDERCOLOR:
				relSE.UNDERCOLOR = kVal;
			break;
			case oop.KWARG_CHAR:
				relSE.extra["CHAR"] = kVal;
			break;
			case oop.KWARG_COLOR:
				colorToSet = kVal;
				lastKindColor = colorToSet;
			break;
			case oop.KWARG_COLORALL:
				colorToSet = kVal;
				lastKindColor = colorToSet;
				useUnderColor = false;
			break;
			case oop.KWARG_DIR:
				relSE.STEPX = getStepXFromDir4(kVal);
				relSE.STEPY = getStepYFromDir4(kVal);
			break;
			case oop.KWARG_ONAME:
				oldSE = getSEFromOName(oVal.toString());
				if (oldSE && eInfo.HasOwnCode)
				{
					relSE.extra["CODEID"] = oldSE.extra["CODEID"];
					relSE.extra["ONAME"] = oVal.toString();
					relSE.IP = eInfo.CustomStart;
				}
			break;
		}

		// Read next keyword argument.
		kByte = getInt();
	}

	if (eInfo.FullColor)
		useUnderColor = false;
	if (!eInfo.DominantColor && (createFlags & CF_GHOSTED) == 0)
		SE.setColor(relSE.X, relSE.Y, colorToSet, useUnderColor);

	// Restore IP and return.
	thisSE.IP = oldIP;
	return relSE;
}

public static function createClone(x:int, y:int, createFlags:int=0):SE {
	// Erase status element.
	var oldSE:SE = SE.getStatElemAt(x, y);
	if (oldSE)
	{
		oldSE.FLAGS |= FL_IDLE + FL_DEAD;
		oldSE.eraseSelfSquare(false);
	}

	// If clone does not represent status element, just copy type.
	var eInfo:ElementInfo = typeList[cloneType];
	if (eInfo.NoStat)
	{
		// We set type and color from last poll.
		SE.setStatElemAt(x, y, null);
		SE.setType(x, y, cloneType);
		SE.setColor(x, y, cloneColor, false);

		// Display type immediately.
		SE.displaySquare(x, y);
		return null;
	}

	// Clip against max stat element count.
	if (SE.statElem.length - SE.statLessCount >= zzt.globalProps["MAXSTATELEMENTCOUNT"])
	{
		//trace("limit");
		return null;
	}

	// EMPTY does not transfer BG to clone
	if (SE.getType(x, y) == 0 && (createFlags & CF_GHOSTED) == 0)
		SE.setColor(x, y, cloneColor & 0x8F, false);

	// Create status element of same type as clone
	var relSE:SE;
	if ((createFlags & CF_GHOSTED) == 0)
	{
		relSE = new SE(cloneSE.TYPE, x, y);
		relSE.FLAGS = cloneSE.FLAGS;
		SE.setStatElemAt(x, y, relSE);
	}
	else
	{
		relSE = new SE(cloneSE.TYPE, x, y, -1000, true);
		relSE.FLAGS = cloneSE.FLAGS | FL_GHOST;
	}
	SE.statElem.push(relSE);

	// Update select attributes and color
	relSE.CYCLE = cloneSE.CYCLE;
	relSE.STEPX = cloneSE.STEPX;
	relSE.STEPY = cloneSE.STEPY;
	relSE.myID = ++nextObjPtrNum;
	if ((createFlags & CF_GHOSTED) == 0)
	{
		if (typeList[cloneType].FullColor)
			SE.setColor(x, y, cloneColor, false);
		else
			SE.setColor(x, y, cloneColor & 0x8F);
	}

	// Copy extras
	for (var s:Object in cloneSE.extra) {
		relSE.extra[s] = cloneSE.extra[s];
	}

	// If custom code exists, will need to make a duplicate code block
	// and duplicate zap history.
	if (relSE.extra.hasOwnProperty("CODEID"))
	{
		// Code ID must point to custom code, not built-in code.
		var unCompCodeID:int = relSE.extra["CODEID"] - numBuiltInCodeBlocksPlus;
		if (unCompCodeID >= 0)
		{
			// Add compiled copy to code blocks.
			var newCodeBlock:Array = codeBlocks[relSE.extra["CODEID"]].concat();
			var newCodeId:int = codeBlocks.length;
			codeBlocks.push(newCodeBlock);

			// Add uncompiled copy and zap history.
			unCompStart.push(unCompStart[unCompCodeID]);
			unCompCode.push(unCompCode[unCompCodeID]);
			ZZTLoader.cloneZapRecord(relSE.extra["CODEID"], newCodeId);
			relSE.extra["CODEID"] = newCodeId;
		}
	}

	return relSE;
}

public static function processChange(region:Array):void {
	// Get the two kinds
	var kind1:int = getKind(true);
	var kwargPos1:int = kwargPos;
	var kind2:int = getKind();
	var kwargPos2:int = kwargPos;

	if (kind1 == zzt.playerType)
		return; // Can't change PLAYER type.

	if (kind1 == -oop.MISC_CLONE)
		kind1 = cloneSE.TYPE;

	// Preserve IP
	var oldIP:int = thisSE.IP;

	// Establish region of change
	var x0:int = 1;
	var y0:int = 1;
	var xf:int = SE.gridWidth;
	var yf:int = SE.gridHeight;
	if (validCoords(region[0]) && validCoords(region[1]))
	{
		x0 = region[0][0];
		y0 = region[0][1];
		xf = region[1][0];
		yf = region[1][1];
	}

	// Set color filter policy
	var cChangeFilter:int = 0xF;
	if (zzt.globalProps["LIBERALCOLORCHANGE"])
		cChangeFilter = 0x7;

	// Conduct change
	for (var y:int = y0; y <= yf; y++) {
		for (var x:int = x0; x <= xf; x++) {
			// First, check for type match.
			if (!(kind1 == 0 && SE.getType(x, y) == zzt.windTunnelType))
			{
				if (SE.getType(x, y) != kind1 && kind1 != -oop.MISC_ALL)
					continue;
			}

			// Match:  must also examine kwargs.
			thisSE.IP = kwargPos1;
			var match:Boolean = true;
			var oldColor:int = SE.getColor(x, y);
			var relSE:SE = SE.getStatElemAt(x, y);

			var kByte:int = getInt();
			while (kByte != oop.SPEC_KWARGEND && match)
			{
				// The expression is an integer for nearly all kwargs.
				var oVal:Object = getExpr();
				var kVal:int = utils.int0(oVal.toString());

				if (kByte == oop.KWARG_COLOR)
				{
					// Color check is unique, because status element does
					// not need to exist in order to check it.
					// Specifying a colored EMPTY always fails (weird but needed).
					if ((oldColor & cChangeFilter) != (kVal & cChangeFilter) || kind1 == 0)
						match = false;
				}
				else if (kByte == oop.KWARG_COLORALL)
				{
					// Color check is unique, because status element does
					// not need to exist in order to check it.
					// Specifying a colored EMPTY always fails (weird but needed).
					if (oldColor != kVal || kind1 == 0)
						match = false;
				}
				else if (relSE)
				{
					switch (kByte) {
						case oop.KWARG_TYPE:
							match = Boolean(relSE.TYPE == typeTrans[kVal & 255]);
						break;
						case oop.KWARG_X:
							match = Boolean(relSE.X == kVal);
						break;
						case oop.KWARG_Y:
							match = Boolean(relSE.Y == kVal);
						break;
						case oop.KWARG_STEPX:
							match = Boolean(relSE.STEPX == kVal);
						break;
						case oop.KWARG_STEPY:
							match = Boolean(relSE.STEPY == kVal);
						break;
						case oop.KWARG_CYCLE:
							match = Boolean(relSE.CYCLE == kVal);
						break;
						case oop.KWARG_P1:
							if (!relSE.extra.hasOwnProperty("P1"))
								match = false;
							else
								match = Boolean(relSE.extra["P1"] == kVal);
						break;
						case oop.KWARG_P2:
							if (!relSE.extra.hasOwnProperty("P2"))
								match = false;
							else
								match = Boolean(relSE.extra["P2"] == kVal);
						break;
						case oop.KWARG_P3:
							if (!relSE.extra.hasOwnProperty("P3"))
								match = false;
							else
								match = Boolean(relSE.extra["P3"] == kVal);
						break;
						case oop.KWARG_FOLLOWER:
							if (!relSE.extra.hasOwnProperty("FOLLOWER"))
								match = false;
							else
								match = Boolean(relSE.extra["FOLLOWER"] == kVal);
						break;
						case oop.KWARG_LEADER:
							if (!relSE.extra.hasOwnProperty("LEADER"))
								match = false;
							else
								match = Boolean(relSE.extra["LEADER"] == kVal);
						break;
						case oop.KWARG_UNDERID:
							match = Boolean(relSE.UNDERID == kVal);
						break;
						case oop.KWARG_UNDERCOLOR:
							match = Boolean(relSE.UNDERCOLOR == kVal);
						break;
						case oop.KWARG_CHAR:
							if (!relSE.extra.hasOwnProperty("CHAR"))
								match = false;
							else
								match = Boolean(relSE.extra["CHAR"] == kVal);
						break;
						case oop.KWARG_DIR:
							match = Boolean(getDir4FromSteps(relSE.STEPX, relSE.STEPY) == kVal);
						break;
						case oop.KWARG_ONAME:
							if (!relSE.extra.hasOwnProperty("ONAME"))
								match = false;
							else
								match = Boolean(relSE.extra["ONAME"] == oVal.toString());
						break;
					}
				}

				// Read next keyword argument.
				kByte = getInt();
			}

			if (match)
			{
				// If conditions met, perform the change.
				if (!relSE && typeList[kind1].BlockObject)
					SE.setType(x, y, 0); // Don't make previous tile into "floor."

				kwargPos = kwargPos2;
				relSE = createKind(x, y, kind2,
					CF_RETAINSE | CF_RETAINCOLOR | CF_REMOVEIFBLOCKING);
				if (relSE)
					relSE.displaySelfSquare();
			}
		}
	}

	// Restore IP.
	thisSE.IP = oldIP;
}

public static function checkType(x:int, y:int, k:int, kp:int):Boolean {
	// First, check for type match.
	if (k == 0 && SE.getType(x, y) == zzt.windTunnelType)
		return true;
	else if (k != SE.getType(x, y) && k != -oop.MISC_ALL)
		return false;

	// Base type matches; must also examine kwargs.
	var oldIP:int = thisSE.IP;
	thisSE.IP = kp;
	var match:Boolean = true;
	var color:int = SE.getColor(x, y);
	var relSE:SE = SE.getStatElemAt(x, y);

	var kByte:int = getInt();
	while (kByte != oop.SPEC_KWARGEND && match)
	{
		// The expression is an integer for nearly all kwargs.
		var oVal:Object = getExpr();
		var kVal:int = utils.int0(oVal.toString());
		if (kByte == oop.KWARG_COLOR)
		{
			// Color check is unique, because status element does
			// not need to exist in order to check it.
			if ((color & 0xF) != kVal)
				match = false;
		}
		else if (kByte == oop.KWARG_COLORALL)
		{
			// Color check is unique, because status element does
			// not need to exist in order to check it.
			if (color != kVal)
				match = false;
		}
		else if (relSE)
		{
			switch (kByte) {
				case oop.KWARG_TYPE:
					match = Boolean(relSE.TYPE == typeTrans[kVal & 255]);
				break;
				case oop.KWARG_X:
					match = Boolean(relSE.X == kVal);
				break;
				case oop.KWARG_Y:
					match = Boolean(relSE.Y == kVal);
				break;
				case oop.KWARG_STEPX:
					match = Boolean(relSE.STEPX == kVal);
				break;
				case oop.KWARG_STEPY:
					match = Boolean(relSE.STEPY == kVal);
				break;
				case oop.KWARG_CYCLE:
					match = Boolean(relSE.CYCLE == kVal);
				break;
				case oop.KWARG_P1:
					if (!relSE.hasOwnProperty("P1"))
						match = false;
					else
						match = Boolean(relSE.extra["P1"] == kVal);
				break;
				case oop.KWARG_P2:
					if (!relSE.hasOwnProperty("P2"))
						match = false;
					else
						match = Boolean(relSE.extra["P2"] == kVal);
				break;
				case oop.KWARG_P3:
					if (!relSE.hasOwnProperty("P3"))
						match = false;
					else
						match = Boolean(relSE.extra["P3"] == kVal);
				break;
				case oop.KWARG_FOLLOWER:
					if (!relSE.hasOwnProperty("FOLLOWER"))
						match = false;
					else
						match = Boolean(relSE.extra["FOLLOWER"] == kVal);
				break;
				case oop.KWARG_LEADER:
					if (!relSE.hasOwnProperty("LEADER"))
						match = false;
					else
						match = Boolean(relSE.extra["LEADER"] == kVal);
				break;
				case oop.KWARG_UNDERID:
					match = Boolean(relSE.UNDERID == kVal);
				break;
				case oop.KWARG_UNDERCOLOR:
					match = Boolean(relSE.UNDERCOLOR == kVal);
				break;
				case oop.KWARG_CHAR:
					if (!relSE.hasOwnProperty("CHAR"))
						match = false;
					else
						match = Boolean(relSE.extra["CHAR"] == kVal);
				break;
				case oop.KWARG_DIR:
					match = Boolean(getDir4FromSteps(relSE.STEPX, relSE.STEPY) == kVal);
				break;
				case oop.KWARG_ONAME:
					if (!relSE.extra.hasOwnProperty("ONAME"))
						match = false;
					else
						match = Boolean(relSE.extra["ONAME"] == oVal.toString());
				break;
			}
		}

		// Read next keyword argument.
		kByte = getInt();
	}

	// Restore IP and return result.
	thisSE.IP = oldIP;
	return match;
}

public static function checkTypeWithinRegion(region:Array, k:int, kp:int):Boolean {
	if (k != -oop.MISC_ALL)
	{
		if (typeList[k].NUMBER == 4 &&
			(zzt.globals["$PLAYERMODE"] == 3 || zzt.globals["$PLAYERMODE"] == 4))
		{
			// Player isn't treated as physically within the board if one of the
			// "title screen" modes is activated.  Technically, the type is supposed
			// to be a MONITOR, but in ZZT Ultra, it is an unresponsive PLAYER.
			return false;
		}
	}

	for (var y:int = region[0][1]; y <= region[1][1]; y++) {
		for (var x:int = region[0][0]; x <= region[1][0]; x++) {
			if (checkType(x, y, k, kp))
				return true; // Found
		}
	}

	return false; // Not found
}

public static function assessPushability(x:int, y:int, d:int, allowSquash:Boolean=true):int {
	if (d == -1)
		return 0; // Push yourself around?

	wouldSquashX = 0;
	wouldSquashY = 0;
	var prevPushSE:Boolean = true;
	var iters:int = 1000;
	do {
		// To assess pushability, we examine the square to see if pushing is possible.
		var t:int = SE.getType(x, y);
		var eInfo:ElementInfo = typeList[t];

		// Squashable types will work unequivocally; square is replaced if push
		// operation would be otherwise braced.  It is possible to do a "preliminary"
		// assessment of whether squashing would occur for a push operation by setting
		// allowSquash to false.  However, the -actual- push operation would not fail.
		if (eInfo.Squashable && allowSquash)
		{
			wouldSquashX = x;
			wouldSquashY = y;
		}

		// If the previous type in the push queue was a status element, we can push
		// to a pushable but non-blocking square.
		if (prevPushSE && eInfo.Pushable == 0 && !eInfo.BlockObject)
			return 1;

		// Non-pushable objects won't work (braced).
		if (eInfo.Pushable == 0)
		{
			if (wouldSquashX == 0)
				return 0;
			else
				return 1; // We can push, because we would squash something.
		}

		// Non-blocking types will work unequivocally; simply replace this square.
		if (!eInfo.BlockObject)
			return 1;

		prevPushSE = Boolean(SE.getStatElemAt(x, y) != null);

		if (eInfo.Pushable == 1)
		{
			// If always pushable, test next square.
			x += getStepXFromDir4(d);
			y += getStepYFromDir4(d);
		}
		else if (eInfo.LocPUSHBEHAVIOR != -1)
		{
			// Custom-behavior pushable objects will use the dispatched
			// message PUSHBEHAVIOR, if it exists.
			var oldType:int = customDrawSE.TYPE;
			var oldPush:int = int(getGlobalVarValue("$PUSH"));
			var oldPushDestX:int = int(getGlobalVarValue("$PUSHDESTX"));
			var oldPushDestY:int = int(getGlobalVarValue("$PUSHDESTY"));
			var oldPushDir:int = int(getGlobalVarValue("$PUSHDIR"));

			customDrawSE.TYPE = t;
			customDrawSE.X = x;
			customDrawSE.Y = y;

			// Seed the global "out" values.
			zzt.globals["$PUSH"] = 0;		// Default:  FAIL
			zzt.globals["$PUSHDESTX"] = x;
			zzt.globals["$PUSHDESTY"] = y;
			zzt.globals["$PUSHDIR"] = d;
			briefDispatch(eInfo.LocPUSHBEHAVIOR, thisSE, customDrawSE);

			// Process result.
			var doRet:Boolean = false;
			var r:int = int(getGlobalVarValue("$PUSH"));
			if (r == 0)
				doRet = true; // Not pushable
			else if (r == 1)
			{
				// Pushable; test next square.
				x += getStepXFromDir4(d);
				y += getStepYFromDir4(d);
			}
			else if (r == 2)
			{
				// Squashable.
				if (allowSquash)
				{
					wouldSquashX = x;
					wouldSquashY = y;
				}

				x += getStepXFromDir4(d);
				y += getStepYFromDir4(d);
			}
			else
			{
				// Special:  check further at a specific location.  This usually
				// happens when pushing an object through a transporter.
				x = zzt.globals["$PUSHDESTX"];
				y = zzt.globals["$PUSHDESTY"];
				d = zzt.globals["$PUSHDIR"];
			}

			customDrawSE.TYPE = oldType;
			zzt.globals["$PUSH"] = oldPush;
			zzt.globals["$PUSHDESTX"] = oldPushDestX;
			zzt.globals["$PUSHDESTY"] = oldPushDestY;
			zzt.globals["$PUSHDIR"] = oldPushDir;

			if (doRet)
			{
				if (wouldSquashX == 0)
					return r;
				else
					return 1; // We can push, because we would squash something.
			}
		}
		else if (wouldSquashX != 0)
		{
			// With squash assumption, treat as implicitly pushable for now.
			x += getStepXFromDir4(d);
			y += getStepYFromDir4(d);
		}
		else
			return 0; // Assume not pushable
	} while (--iters);

	// Assume not pushable
	return 0;
}

public static function pushItems(x:int, y:int, d:int, allowSquash:Boolean=true):int {
	// This function chains together movement of pushed objects.
	var posStackX:Vector.<int> = new Vector.<int>();
	var posStackY:Vector.<int> = new Vector.<int>();
	var iters:int = 1000;

	// We already know that a push would succeed, so it is a simple matter to trace
	// the path that we had already assessed successfully.
	do {
		var t:int = SE.getType(x, y);
		var eInfo:ElementInfo = typeList[t];

		if (eInfo.Squashable && allowSquash)
		{
			// Squash this square.
			var relSE:SE = SE.getStatElemAt(x, y);
			if (relSE)
			{
				// Kill status element
				relSE.FLAGS |= FL_IDLE + FL_DEAD;
				relSE.eraseSelfSquare(false);
			}
			else
			{
				// Set type to empty
				SE.setType(x, y, 0);
				SE.setStatElemAt(x, y, null);
			}

			posStackX.push(x);
			posStackY.push(y);
			break; // Done.
		}
		else if (!eInfo.BlockObject)
		{
			// A non-blocking square will be replaced.
			posStackX.push(x);
			posStackY.push(y);
			break; // Done.
		}
		else if (eInfo.Pushable == 1)
		{
			// If always pushable, add to position stack and continue.
			posStackX.push(x);
			posStackY.push(y);
			x += getStepXFromDir4(d);
			y += getStepYFromDir4(d);
		}
		else if (eInfo.LocPUSHBEHAVIOR != -1)
		{
			// Custom-behavior pushable objects will use the dispatched
			// message PUSHBEHAVIOR, if it exists.
			customDrawSE.TYPE = t;
			customDrawSE.X = x;
			customDrawSE.Y = y;

			// Seed the global "out" values.
			zzt.globals["$PUSH"] = 0;		// Default:  FAIL
			zzt.globals["$PUSHDESTX"] = x;
			zzt.globals["$PUSHDESTY"] = y;
			zzt.globals["$PUSHDIR"] = d;
			briefDispatch(eInfo.LocPUSHBEHAVIOR, thisSE, customDrawSE);

			// Process result.
			var r:int = int(getGlobalVarValue("$PUSH"));
			if (r == 1 || (r == 2 && !allowSquash))
			{
				// Pushable; add to position stack and continue.
				posStackX.push(x);
				posStackY.push(y);
				x += getStepXFromDir4(d);
				y += getStepYFromDir4(d);
			}
			else if (r == 2)
			{
				// Squash this square.
				relSE = SE.getStatElemAt(x, y);
				if (relSE)
				{
					// Kill status element
					relSE.FLAGS |= FL_IDLE + FL_DEAD;
					relSE.eraseSelfSquare(false);
				}
				else
				{
					// Set type to empty
					SE.setType(x, y, 0);
					SE.setStatElemAt(x, y, null);
				}
	
				posStackX.push(x);
				posStackY.push(y);
				break; // Done.
			}
			else
			{
				// Special:  update location (no position stack update).
				x = zzt.globals["$PUSHDESTX"];
				y = zzt.globals["$PUSHDESTY"];
				d = zzt.globals["$PUSHDIR"];
			}
		}
	} while (--iters);

	if (iters <= 0)
		return 0; // Error (too many iterations; deadlocked?)

	// Now we move everything according to the position stack.
	// We must move everything starting from the last position and
	// ending with the first position.  Also note that the very
	// last position is not actually moved; it only serves as a final
	// destination.  This means that a stack with a size of 1 will
	// not result in any pushing (although it might have caused squashing).
	for (var i:int = posStackX.length - 2; i >= 0; i--)
	{
		x = posStackX[i];
		y = posStackY[i];
		var newX:int = posStackX[i+1];
		var newY:int = posStackY[i+1];

		// Move previous square forward.
		relSE = SE.getStatElemAt(x, y);
		if (relSE)
		{
			// Move status element
			relSE.moveSelfSquare(newX, newY);
		}
		else
		{
			// Move ordinary grid square
			SE.setType(newX, newY, SE.getType(x, y));
			SE.setColor(newX, newY, SE.getColor(x, y), false);
			SE.setStatElemAt(newX, newY, null);
			SE.displaySquare(newX, newY);
			SE.setType(x, y, 0);
			SE.setStatElemAt(x, y, null);
		}
	}

	// Update first square in the event that the pushing object doesn't
	// actually move to this square for some reason.
	if (posStackX.length >= 1)
		SE.displaySquare(posStackX[0], posStackY[0]);

	return 1; // Assumed success
}

public static function adjustLit(coords:Array, flag:int):void {
	// Update flag
	SE.setLit(coords[0], coords[1], flag);

	// Expand update region for lighting if needed
	if (litRegion[0][0] > coords[0])
		litRegion[0][0] = coords[0];
	if (litRegion[0][1] > coords[1])
		litRegion[0][1] = coords[1];
	if (litRegion[1][0] < coords[0])
		litRegion[1][0] = coords[0];
	if (litRegion[1][1] < coords[1])
		litRegion[1][1] = coords[1];
}

public static function updateLit():void {
	// Redraw update region
	var x0:int = litRegion[0][0];
	var y0:int = litRegion[0][1];
	var xf:int = litRegion[1][0];
	var yf:int = litRegion[1][1];

	for (var y:int = y0; y <= yf; y++) {
		for (var x:int = x0; x <= xf; x++) {
			SE.displaySquare(x, y);
		}
	}

	// Reset update region to empty
	litRegion[0][0] = 1000000;
	litRegion[0][1] = 1000000;
	litRegion[1][0] = -1;
	litRegion[1][1] = -1;
}

public static function smartUpdateViewport():void {
	var copyX1:int = 0;
	var copyY1:int = 0;
	var copyX2:int = SE.vpWidth - 1;
	var copyY2:int = SE.vpHeight - 1;

	// When updating the viewport, check if there is overlap from last camera location.
	// Only economizes scrolling if a single axis was changed.
	// If multiple axes changed, we will need to update the entire viewport.
	if (SE.uCameraX == SE.CameraX && SE.uCameraY == SE.CameraY)
	{
		// No update necessary--camera unchanged.
		copyX2 = copyX1 - 1;
		copyY2 = copyY1 - 1;
	}
	else if ((utils.iabs(SE.uCameraX - SE.CameraX) <= 2 && SE.uCameraY == SE.CameraY) ||
		(utils.iabs(SE.uCameraY - SE.CameraY) <= 2 && SE.uCameraX == SE.CameraX))
	{
		// Economize by shifting the contents of the viewport.
		var xInc:int = SE.uCameraX - SE.CameraX;
		var yInc:int = SE.uCameraY - SE.CameraY;
		if (xInc < 0)
			copyX1 -= xInc;
		else if (xInc > 0)
			copyX2 -= xInc;
		if (yInc < 0)
			copyY1 -= yInc;
		else if (yInc > 0)
			copyY2 -= yInc;

		// Copy pre-existing content.
		SE.mg.moveBlock(copyX1+SE.vpX0-1, copyY1+SE.vpY0-1, copyX2+SE.vpX0-1, copyY2+SE.vpY0-1,
			xInc, yInc);

		// The update region is now limited to only the area vacated by the move.
		if (xInc < 0)
			copyX1 = copyX2 + xInc + 1;
		else if (xInc > 0)
			copyX2 = copyX1 + xInc - 1;
		if (yInc < 0)
			copyY1 = copyY2 + yInc + 1;
		else if (yInc > 0)
			copyY2 = copyY1 + yInc - 1;
	}

	// Update remaining (or only) portion.
	for (var y:int = copyY1; y <= copyY2; y++)
	{
		for (var x:int = copyX1; x <= copyX2; x++)
		{
			SE.displaySquare(SE.CameraX + x, SE.CameraY + y);
		}
	}

	// Viewport is now completely up-to-date.
	SE.uCameraX = SE.CameraX;
	SE.uCameraY = SE.CameraY;
}

// Adjust camera
public static function cameraAdjust(coords:Array):void {
	var cx:int = int(coords[0]);
	var cy:int = int(coords[1]);
	if (zzt.globalProps["LEGACYCAMERA"])
	{
		// Legacy edge bumping, as with Super ZZT
		if (cx - SE.CameraX < 9)
			SE.CameraX = cx - 9;
		if (cy - SE.CameraY < 8)
			SE.CameraY = cy - 8;
		if (SE.CameraX + SE.vpWidth - cx < 11)
			SE.CameraX = 11 + cx - SE.vpWidth;
		if (SE.CameraY + SE.vpHeight - cy < 7)
			SE.CameraY = 7 + cy - SE.vpHeight;

		SE.CameraX = utils.clipintval(SE.CameraX, 1, SE.gridWidth - SE.vpWidth + 1);
		SE.CameraY = utils.clipintval(SE.CameraY, 1, SE.gridHeight - SE.vpHeight + 1);
	}
	else
	{
		// Exact center alignment
		cx = cx - int(SE.vpWidth >> 1);
		cy = cy - int(SE.vpHeight >> 1);
		cx = utils.clipintval(cx, 1, SE.gridWidth - SE.vpWidth + 1);
		cy = utils.clipintval(cy, 1, SE.gridHeight - SE.vpHeight + 1);
		SE.CameraX = cx;
		SE.CameraY = cy;
	}

	zzt.boardProps["CAMERAX"] = SE.CameraX;
	zzt.boardProps["CAMERAY"] = SE.CameraY;
}

public static function cueForEach(varName:String, vType:int, region:String):int {
	// Cue a "FOR" loop that will iterate through each status element of a region
	forType = 0;
	forVarName1 = varName;
	forVarType1 = vType;
	if (region == "" || region == "ALL")
		forRegion = allRegion;
	else
		forRegion = getRegion(region);
	forCursorX = forRegion[0][0];
	forCursorY = forRegion[0][1];
	forRetLoc = thisSE.IP;

	return iterateFor();
}

public static function cueForMask(varName1:String, vType1:int, varName2:String, vType2:int,
	coords:Array, mask:String):int {
	// Cue a "FOR" loop that will iterate through each coordinate in a mask
	forType = 1;
	forVarName1 = varName1;
	forVarType1 = vType1;
	forVarName2 = varName2;
	forVarType2 = vType2;
	forMask = getMask(mask);
	forMaskXSize = forMask[0].length;
	forMaskYSize = forMask.length;
	forCornerX = coords[0] - (forMaskXSize >> 1); // Top left corner
	forCornerY = coords[1] - (forMaskYSize >> 1); // Top left corner
	forCursorX = 0;
	forCursorY = 0;
	forRetLoc = thisSE.IP;

	return iterateFor();
}

public static function cueForRegion(varName1:String, vType1:int, varName2:String, vType2:int,
	region:String):int {
	// Cue a "FOR" loop that will iterate through each coordinate in a region
	forType = 2;
	forVarName1 = varName1;
	forVarType1 = vType1;
	forVarName2 = varName2;
	forVarType2 = vType2;
	if (region == "" || region == "ALL")
		forRegion = allRegion;
	else
		forRegion = getRegion(region);
	forCursorX = forRegion[0][0];
	forCursorY = forRegion[0][1];
	forRetLoc = thisSE.IP;

	return iterateFor();
}

public static function iterateFor():int {
	var relSE:SE;

	if (forType == 0)
	{
		// Step through region, finding status elements
		while (forType != -1) {
			// Ensure cursor is within region
			if (forCursorX > forRegion[1][0])
			{
				forCursorX = forRegion[0][0];
				forCursorY++;
			}

			// If no longer in region, done with FOREACH.
			if (forCursorY > forRegion[1][1])
			{
				forType = -1;
				break;
			}

			relSE = SE.getStatElemAt(forCursorX++, forCursorY);
			if (relSE)
			{
				// Found a status element; set iterator variable to ID.
				assignID(relSE);
				setVariableFromRef(forVarType1, forVarName1, relSE.myID);
				break;
			}
		}
	}
	else if (forType == 1)
	{
		// Step through coordinates, finding status elements
		while (forType != -1) {
			// Ensure cursor is within mask area
			if (forCursorX >= forMaskXSize)
			{
				forCursorX = 0;
				forCursorY++;
			}

			// If no longer in mask area, done with FORMASK.
			if (forCursorY >= forMaskYSize)
			{
				forType = -1;
				break;
			}

			if (forMask[forCursorY][forCursorX++] != 0)
			{
				// Found valid mask location.  Find actual coordinates.
				coords2[0] = forCornerX + forCursorX - 1;
				coords2[1] = forCornerY + forCursorY;

				// The actual coordinates are only reported if they are valid.
				if (validCoords(coords2))
				{
					setVariableFromRef(forVarType1, forVarName1, coords2[0]);
					setVariableFromRef(forVarType2, forVarName2, coords2[1]);
					break;
				}
			}
		}
	}
	else if (forType == 2)
	{
		// Step through region, finding coordinates

		// Ensure cursor is within region
		if (forCursorX > forRegion[1][0])
		{
			forCursorX = forRegion[0][0];
			forCursorY++;
		}

		// If no longer in region, done with FORREGION.
		if (forCursorY > forRegion[1][1])
			forType = -1;
		else
		{
			setVariableFromRef(forVarType1, forVarName1, forCursorX);
			setVariableFromRef(forVarType2, forVarName2, forCursorY);
			forCursorX++;
		}
	}

	return forType;
}

// Calculate the group-move rim info, which is used to qualify how movement occurs.
public static function calcGroupRimInfo(
	srcX:int, srcY:int, destX:int, destY:int, groupArray:Array):void {

	doGroupMove = true;
	checkAllGroup = false;
	groupRimStepX = destX - srcX;
	groupRimStepY = destY - srcY;
	gArray = groupArray;

	if (utils.iabs(groupRimStepX) >= 2 || utils.iabs(groupRimStepY) >= 2)
		checkAllGroup = true;
	else if (groupRimStepX != 0 && groupRimStepY != 0)
		checkAllGroup = true;
	else if (groupRimStepX == 0 && groupRimStepY == 0)
		doGroupMove = false;
	else if (groupRimStepX == 0)
	{
		// Calculate vertical-movement rim.
		groupRimX = [];
		groupRimY = [];
		for (var i:int = 0; i < gArray.length; i++)
		{
			var relSE:SE = SE.getStatElem(gArray[i]);
			if (relSE)
			{
				var idx:int = groupRimX.indexOf(relSE.X);
				if (relSE.FLAGS & FL_GHOST)
				{
					// Ghosted object does not count as rim
				}
				else if (idx == -1)
				{
					idx = groupRimX.length;
					groupRimX.push(relSE.X);
					groupRimY.push(relSE.Y);
				}
				else
				{
					if (groupRimStepY > 0)
					{
						if (groupRimY[idx] < relSE.Y)
							groupRimY[idx] = relSE.Y;
					}
					else
					{
						if (groupRimY[idx] > relSE.Y)
							groupRimY[idx] = relSE.Y;
					}
				}
			}
		}
	}
	else
	{
		// Calculate horizontal-movement rim.
		groupRimX = [];
		groupRimY = [];
		for (i = 0; i < gArray.length; i++)
		{
			relSE = SE.getStatElem(gArray[i]);
			if (relSE)
			{
				idx = groupRimY.indexOf(relSE.Y);
				if (relSE.FLAGS & FL_GHOST)
				{
					// Ghosted object does not count as rim
				}
				else if (idx == -1)
				{
					idx = groupRimY.length;
					groupRimX.push(relSE.X);
					groupRimY.push(relSE.Y);
				}
				else
				{
					if (groupRimStepX > 0)
					{
						if (groupRimX[idx] < relSE.X)
							groupRimX[idx] = relSE.X;
					}
					else
					{
						if (groupRimX[idx] > relSE.X)
							groupRimX[idx] = relSE.X;
					}
				}
			}
		}
	}
}

// Assess group rim movement profile at destination; apply pushing if needed
public static function tryRimPush(action:int):int {
	if (!doGroupMove || checkAllGroup)
		return -1; // No pushing allowed

	// Get direction
	var d:int = getDir4FromSteps(utils.isgn(groupRimStepX), utils.isgn(groupRimStepY));
	var actionProfile:int = 0;

	// Assess push result and allowable push profile.  Allowable actions include...
	// 0:  Movement only; no pushing allowed.
	// 1:  Movement with non-squashing pushing allowed.
	// 2:  Movement with squashing pushing allowed.
	for (var j:int = 0; j < groupRimX.length; j++)
	{
		var tx:int = groupRimX[j] + groupRimStepX;
		var ty:int = groupRimY[j] + groupRimStepY;

		if (!typeList[SE.getType(tx, ty)].BlockObject)
		{
			// Easy move; non-blocking square.
			continue;
		}
		else if (SE.getType(tx, ty) == zzt.transporterType)
		{
			// By default, TRANSPORTER counts as non-movable.
			return -1;
		}
		else if (action < 1)
		{
			// Action does not call for push possibility.  Non-movable.
			return -1;
		}
		else if (assessPushability(tx, ty, d, false))
		{
			// Can move without squashing.
			actionProfile = 1;
		}
		else if (action < 2)
		{
			// Action does not call for squash possibility.  Non-movable.
			return -1;
		}
		else if (assessPushability(tx, ty, d, true))
		{
			// Can move without squashing.
			actionProfile = 2;
		}
		else
		{
			// We can't move.
			return -1;
		}
	}

	// If move is "clean" (no pushing), just return.
	if (actionProfile == 0)
		return 0;

	// Perform pushing and/or squashing as needed.
	for (j = 0; j < groupRimX.length; j++)
	{
		tx = groupRimX[j] + groupRimStepX;
		ty = groupRimY[j] + groupRimStepY;

		if (!typeList[SE.getType(tx, ty)].BlockObject)
			continue;
		else if (assessPushability(tx, ty, d, false))
			pushItems(tx, ty, d, false);
		else if (assessPushability(tx, ty, d, true))
			pushItems(tx, ty, d, true);
	}

	// Move involved pushing and/or squashing.
	return actionProfile;
}

// Assess entire-group movement profile at destination
public static function tryEntireMove(action:int):Boolean {
	// Get direction
	var d:int = getDir4FromSteps(utils.isgn(groupRimStepX), utils.isgn(groupRimStepY));

	// Re-sort the group array by leaders-first-in-move-direction.
	var ptArrayX:Array = [];
	var ptArrayY:Array = [];
	for (var i:int = 0; i < gArray.length; i++) {
		var relSE:SE = SE.getStatElem(gArray[i]);
		if (relSE)
		{
			ptArrayX.push(relSE.X);
			ptArrayY.push(relSE.Y);
		}
		else
		{
			ptArrayX.push(0);
			ptArrayY.push(0);
		}
	}

	var sortOrderX:Array = ptArrayX.sort(Array.RETURNINDEXEDARRAY | Array.NUMERIC);
	var sortOrderY:Array = ptArrayY.sort(Array.RETURNINDEXEDARRAY | Array.NUMERIC);

	// Move or test the individual units of the group.  We need the objects
	// to be sorted in such a way that we iterate with a "leaders first"
	// algorithm.  This way, the objects in front will be moved or tested
	// first.  We don't want the objects in the rear to be "tripped up" by
	// the objects in the front if the ones in front haven't moved yet.
	switch (d) {
		case 0: // Right movement; iterate by descending X.
			for (i = sortOrderX.length - 1; i >= 0; i--) {
				relSE = SE.getStatElem(gArray[sortOrderX[i]]);
				if (relSE)
				{
					if (!unitMoveAction(relSE, action))
						return false;
				}
			}
		break;
		case 2: // Left movement; iterate by ascending X.
			for (i = 0; i < sortOrderX.length; i++) {
				relSE = SE.getStatElem(gArray[sortOrderX[i]]);
				if (relSE)
				{
					if (!unitMoveAction(relSE, action))
						return false;
				}
			}
		break;
		case 1: // Down movement; iterate by descending Y.
			for (i = sortOrderY.length - 1; i >= 0; i--) {
				relSE = SE.getStatElem(gArray[sortOrderY[i]]);
				if (relSE)
				{
					if (!unitMoveAction(relSE, action))
						return false;
				}
			}
		break;
		case 3: // Up movement; iterate by ascending Y.
			for (i = 0; i < sortOrderY.length; i++) {
				relSE = SE.getStatElem(gArray[sortOrderY[i]]);
				if (relSE)
				{
					if (!unitMoveAction(relSE, action))
						return false;
				}
			}
		break;
	}

	// The movement or test was successful.
	return true;
}

// Try to move or test an individual unit of a group.
public static function unitMoveAction(se:SE, action:int):Boolean {
	// Allowable actions include...
	// 0:  Movement is definitely taken, crushing anything in the path.
	// 1:  Movement is tested, but not taken.  If something is in the path,
	//     the movement attempt fails.
	var tx:int = se.X + groupRimStepX;
	var ty:int = se.Y + groupRimStepY;

	if (se.FLAGS & FL_GHOST)
	{
		// Ghost movement or test always succeeds.
		if (action == 0)
		{
			// MOVE
			se.X = tx;
			se.Y = ty;
		}

		return true; // OK
	}
	else
	{
		var relSE:SE = SE.getStatElemAt(tx, ty);
		if (relSE)
		{
			// Blocked.
			if (action == 0)
				killSE(tx, ty); // KILL
			else
			{
				// We don't count the destination as blocked if the object
				// belongs to the same group.
				for (var i:int = 0; i < gArray.length; i++) {
					if (relSE.myID == gArray[i])
						return true; // OK
				}

				return false; // FAIL
			}
		}
		else if (typeList[SE.getType(tx, ty)].BlockObject && action == 1)
		{
			return false; // FAIL
		}

		if (action == 0)
			se.moveSelfSquare(tx, ty); // MOVE

		return true; // OK
	}
}

// Marked-up #PLAY string format.
public static function markupPlayString(str:String):String {
	if (zzt.globalProps["PLAYREVERB"])
		str = "K40:0.3:" + str;
	else
		str = "K40:0:" + str;

	if (zzt.globalProps["PLAYRETENTION"])
		str = "Z01@" + str;
	else
		str = "Z00P99@" + str;

	return str;
}

// Callback function for PLAYSYNC if implemented.
public static function playSyncCallback():Boolean {
	// Non-active SE can't be synched.
	if (playSyncIdleSE.FLAGS & (FL_IDLE | FL_PENDINGDEAD | FL_DEAD))
		return false;

	// If there is an idle sync location identified, skip past idle
	// move commands and locate another #PLAY command.
	var pos:int = playSyncIdleSE.IP;
	var destCycle:int = playSyncIdleSE.CYCLE;
	var i:int = 0;
	var loopLimit:int = 256;
	var str:String;

	while (pos < playSyncIdleCode.length && loopLimit > 0) {

		var cByte:int = playSyncIdleCode[pos++];
		switch (cByte) {
			case oop.CMD_NOP:
				// Nothing to do
			break;
			case oop.CMD_NAME:
				// Skip name
				pos++;
			break;
			case oop.CMD_LABEL:
			case oop.CMD_COMMENT:
				// Skip comment or label
				pos += 2;
			break;
			case oop.CMD_SEND:
				// Jump to label location
				i = playSyncIdleCode[pos++];
				if (i < 0)
					pos = -i;
				else
				{
					i = findLabel(playSyncIdleCode, oop.pStrings[i]);
					if (i != -1)
						pos = i;
				}
			break;
			case oop.CMD_CYCLE:
				// Capture new cycle, but don't set unless skipped code is definite
				if (playSyncIdleCode[pos] == oop.SPEC_NUMCONST)
				{
					destCycle = playSyncIdleCode[pos + 1];
					pos += 2;
				}
				else
					return false; // Nonconstant cycle; don't try to sync
			break;
			case oop.CMD_ZAP:
				// The presence of #ZAP allows us to continue, but we can't
				// reasonably expect to undo this step.  Commit to this point.
				str = oop.pStrings[playSyncIdleCode[pos++]];
				zapTarget(playSyncIdleSE, str);
				playSyncIdleSE.CYCLE = destCycle;
				playSyncIdleSE.IP = pos;
			break;
			case oop.CMD_RESTORE:
				// The presence of #RESTORE allows us to continue, but we can't
				// reasonably expect to undo this step.  Commit to this point.
				str = oop.pStrings[playSyncIdleCode[pos++]];
				restoreTarget(playSyncIdleSE, str);
				playSyncIdleSE.CYCLE = destCycle;
				playSyncIdleSE.IP = pos;
			break;
			case oop.CMD_GO:
				// Movement.
				if (playSyncIdleCode[pos] == oop.DIR_I)
				{
					// Found idle movement; skip forward.
					pos++;
				}
				else
				{
					// Not an idle movement; no sync will occur.
					return false;
				}
			break;
			case oop.CMD_PLAY:
				// Another #PLAY command.  Bump the IP up to this new location;
				// add to the queue immediately.
				str = oop.pStrings[playSyncIdleCode[pos++]];
				str = markupPlayString(str);

				Sounds.distributePlayNotes(str);
				playSyncIdleSE.CYCLE = destCycle;
				playSyncIdleSE.IP = pos;
				return true;
			break;
			default:
				// Not idle movement or #PLAY command; no sync will occur.
				return false;
			break;
		}

		loopLimit--;
	}

	// If we got here, we're at the end of the code.  No sync.
	return false;
}

public static function establishCaptchaNums():void {
	/*captchaSrcArray = [];
	var tempVal:int = 0;

	// The following is used to serve as a timestamp for the start of the check routine.
	var srcTime:Date = new Date();
	var startTime:Number = Math.floor(srcTime.time / 1000);
	var interval:int = int(Math.floor((startTime + 300) / 600));

	// Calculate numbers.
	for (var i:int = 0; i < 4; i++) {
		tempVal &= 32767;
		var s1:int = utils.randrange(257, 32767);
		var s2:int = utils.randrange(257, 32767);
		var s3:int = utils.randrange(257, 32767);
		var s4:int = utils.randrange(257, 32767);
		captchaSrcArray.push(s1);
		captchaSrcArray.push(s2);
		captchaSrcArray.push(s3);
		captchaSrcArray.push(s4);
		tempVal += (((((s1 * s2) + s3 + interval) & 32767) * s4 + s1 - s2) & 32767) * s3 + s4;
	}

	tempVal = tempVal & 65535;
	captchaMainVal = tempVal;
	var num1:int = (tempVal % 9) + 1;
	tempVal = int(tempVal / 9);
	var num2:int = (tempVal % 9) + 1;
	tempVal = int(tempVal / 9);
	var num3:int = (tempVal % 9) + 1;
	tempVal = int(tempVal / 9);
	var num4:int = (tempVal % 9) + 1;
	tempVal = int(tempVal / 9);
	var num5:int = (tempVal % 9) + 1;
	zzt.globals["NUM1"] = num1;
	zzt.globals["NUM2"] = num2;
	zzt.globals["NUM3"] = num3;
	zzt.globals["NUM4"] = num4;
	zzt.globals["NUM5"] = num5;
	trace(captchaMainVal, interval, captchaSrcArray);*/
}

public static function captchaSubmit():void {
	/*trace("submit norm");
	var captchaUrl:String = "discussion.php?task=1&login=";
	for (var i:int = 0; i < 16; i++)
		captchaUrl += captchaSrcArray[i].toString() + "%20";

	captchaUrl += zzt.globals["NUM1"].toString() + "%20";
	captchaUrl += zzt.globals["NUM2"].toString() + "%20";
	captchaUrl += zzt.globals["NUM3"].toString() + "%20";
	captchaUrl += zzt.globals["NUM4"].toString() + "%20";
	captchaUrl += zzt.globals["NUM5"].toString();

	parse.replacePage(captchaUrl);*/
}

public static function captchaSubmitAdmin():void {
	/*trace("submit admin");
	var captchaUrl:String = "discussion.php?task=1&login=";
	for (var i:int = 0; i < 16; i++)
		captchaUrl += (captchaSrcArray[i] ^ 65535).toString() + "%20";

	captchaUrl += zzt.globals["NUM1"].toString() + "%20";
	captchaUrl += zzt.globals["NUM2"].toString() + "%20";
	captchaUrl += zzt.globals["NUM3"].toString() + "%20";
	captchaUrl += zzt.globals["NUM4"].toString() + "%20";
	captchaUrl += zzt.globals["NUM5"].toString();

	parse.replacePage(captchaUrl);*/
}

public static function setMedal():void {
}

public static function clearMedal():void {
}

public static function resetAllMedals():void {
}

// Post a high score and fetch high scores from a specific filename
public static function postHighScore(
	hsLine:String, filename:String, sortKey:int, sortOrder:int):void {
	if (zzt.DISABLE_HISCORE || zzt.globalProps["HIGHSCOREACTIVE"] == 0)
	{
		briefDispatch(findLabel(codeBlocks[0], "$ONFAILPOSTHS"), thisSE, blankSE);
		return;
	}

	// Clean line of offending characters.
	hsLine = (hsLine.split(";").join(" "));
	hsLine = (hsLine.split("&").join(" "));

	// Establish action code and timestamp.
	var hsCode:int = 1;
	var srcTime:Date = new Date();
	var startTime:int = int(srcTime.time / 1000.0);

	// Create full line in script.
	var fullLine:String = hsCode.toString() + "," + startTime.toString() + "," +
		filename + "," + sortKey + "," + sortOrder + "," + hsLine;

	// Calculate checksum on line.
	var checkSum:int = 0;
	for (var i:int = 0; i < fullLine.length; i++)
		checkSum += fullLine.charCodeAt(i) & 255;
	checkSum ^= 0x5555;

	// Post line and checksum.
	fullLine += "," + checkSum.toString();
	if (zzt.highScoreServer)
	{
		parse.loadRemoteFile("eval_hs.php", zzt.MODE_POSTHIGHSCORE, fullLine);
		zzt.showLoadingAnim = false;
	}
	else
	{
		evalHsLocal(fullLine);
		var pos:int = findLabel(
			codeBlocks[0], zzt.highScoresLoaded ? "$ONPOSTHS" : "$ONFAILPOSTHS")
		briefDispatch(pos, thisSE, blankSE);
	}
}

// Fetch high scores from a specific filename
public static function getHighScores(filename:String, sortKey:int, sortOrder:int):void {
	if (zzt.DISABLE_HISCORE || zzt.globalProps["HIGHSCOREACTIVE"] == 0)
	{
		briefDispatch(findLabel(codeBlocks[0], "$ONFAILGETHS"), thisSE, blankSE);
		return;
	}

	// Establish action code and timestamp.
	var hsCode:int = 2;
	var srcTime:Date = new Date();
	var startTime:int = int(srcTime.time / 1000.0);

	// Send request line to script.
	var fullLine:String = hsCode.toString() + "," + startTime.toString() + "," +
		filename + "," + sortKey + "," + sortOrder + ",0,0,0";

	if (zzt.highScoreServer)
		parse.loadRemoteFile("eval_hs.php", zzt.MODE_GETHIGHSCORES, fullLine);
	else
	{
		evalHsLocal(fullLine);
		var pos:int = findLabel(
			codeBlocks[0], zzt.highScoresLoaded ? "$ONGETHS" : "$ONFAILGETHS")
		briefDispatch(pos, thisSE, blankSE);
	}
}

// Get a specific high score field (-1 returned if not possible)
public static function getHighScoreField(linePos:int, indexPos:int):Object {
	if (zzt.DISABLE_HISCORE || zzt.globalProps["HIGHSCOREACTIVE"] == 0)
		return -1;
	if (!zzt.highScoresLoaded)
		return -1;

	if (linePos < 0 || linePos >= zzt.highScores.length)
		return -1;
	if (indexPos < 0 || indexPos >= zzt.highScores[linePos].length)
		return -1;

	return zzt.highScores[linePos][indexPos];
}

// High scores list sorting function
public static function hsListSorter(lines:Array, sortKey:int, sortOrder:int):Array {
	// Get sort keys for existing list
	var keys:Array = [];
	var sType:int = Array.NUMERIC;
	for (var i:int = 0; i < lines.length; i++) {
		var l:String = lines[i];
		if (l.length <= 3)
			continue;

		var fields:Array = l.split(",");
		if (highScoreUID < int(fields[0]))
			highScoreUID = int(fields[0]) + 1;

		var val:String = fields[sortKey];
		if (utils.int0(val) == 0 && val != "0")
		{
			sType = 0;
		}

		keys.push(val);
	}

	// Sort keys
	if (sortOrder < 0)
		sType |= Array.DESCENDING;

	var sortedArray:Array = keys.sort(sType | Array.RETURNINDEXEDARRAY);

	// Rearrange lines in proper sort order
	var sLines:Array = [];
	for (i = 0; i < sortedArray.length; i++) {
		l = lines[sortedArray[i]];
		if (l.length > 3)
			sLines.push(l);
	}

	return sLines;
}

// This high-score evaluation function is a stripped-down version of the server-side script.
// It is designed to serve the same functionality with locally stored files.
public static function evalHsLocal(specStr:String):Boolean {
	// Maximum number of lines storable per file
	var hsMaxLinesPerFile:int = 100;
	var hsDefaultSortKey:int = 0;
	var hsDefaultSortOrder:int = -1;

	// UID used for next post
	highScoreUID = 1;

	// Main script processing
	var specFields:Array = specStr.split(",");
	if (specFields.length <= 6)
		return false;

	// Get request fundamentals
	var actionCode:int = int(specFields[0]);
	var timeStamp:int = int(specFields[1]);
	var filename:String = specFields[2];
	var sortKey:int = int(specFields[3]);
	var sortOrder:int = int(specFields[4]);
	if (sortKey == 0)
		sortKey = hsDefaultSortKey;
	if (sortOrder == 0)
		sortOrder = hsDefaultSortOrder;

	// Find converted name (no extension and case-insensitive)
	var convertedName:String = filename.toUpperCase();
	var periodPos:int = filename.indexOf(".");
	if (periodPos != -1)
		convertedName = convertedName.substr(0, periodPos);

	// Establish actual storage location; fetch file
	var actualFile:String = convertedName;

	// TBD:  Adobe AIR file load?
	zzt.guaranteeSharedObj("HIGHSCORE");
	var obj:Object = zzt.zztSO.data["HIGHSCORE"];
	var allLines:String = "";
	if (obj.hasOwnProperty(actualFile))
		allLines = obj[actualFile];

	var lines:Array = allLines.split("\n");

	// Sort the list
	if (lines.length > 0 && sortOrder != 0 && sortKey >= 0)
		lines = hsListSorter(lines, sortKey, sortOrder);

	// Establish action-specific information
	if (actionCode == 1)
	{
		// Post-to-scores action

		// Synth posted line.  This excludes the action code, filename, and checksum,
		// but includes a primary key, the timestamp, and all other fields.
		var postedLine:String = highScoreUID.toString() + "," + timeStamp;
		for (var i:int = 5; i < specFields.length - 1; i += 1) {
			postedLine += "," + specFields[i];
		}

		// Add posted line

		// If maximum number of lines exceeded, remove the last sorted line
		if (lines.length > hsMaxLinesPerFile - 1)
		{
			// We remove the last line because we assume anything at the tail of the sort
			// order is least significant.
			lines[lines.length - 1] = postedLine;
		}
		else
		{
			// Just add the line to the end.
			lines.push(postedLine);
		}

		// Re-sort the list if needed
		if (sortOrder != 0)
			lines = hsListSorter(lines, sortKey, sortOrder);

		// Write list back to file
		allLines = "";
		for (i = 0; i < lines.length; i++)
			allLines += lines[i] + "\n";

		obj[actualFile] = allLines;
		zzt.saveSharedObj("HIGHSCORE", obj);
	}
	else if (actionCode == 2)
	{
		// Fetch-score action
	}
	else
	{
		return false;
	}

	// Register lines
	zzt.highScores = lines;
	for (i = 0; i < lines.length; i++) {
		var l:Array = lines[i].split(",");
		if (l.length >= 3)
			lines[i] = l;
		else
		{
			delete lines[i];
			i--;
		}
	}

	// Flag high score presence
	if (lines.length > 0)
	{
		zzt.highScores = lines;
		zzt.highScoresLoaded = true;
	}
	else
		zzt.highScoresLoaded = false;

	return zzt.highScoresLoaded;
}

};
};

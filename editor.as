// editor.as:  The program's editor functions.

package {

// Imports
import flash.utils.ByteArray;
import flash.utils.Endian;

public class editor {

// Constants
public static const EDSTYLE_ULTRA:int = 0;
public static const EDSTYLE_KEVEDIT:int = 1;
public static const EDSTYLE_CLASSIC:int = 2;
public static const EDSTYLE_SUPERZZT:int = 3;

public static const DRAW_OFF:int = 0;
public static const DRAW_ON:int = 1;
public static const DRAW_ACQFORWARD:int = 2;
public static const DRAW_ACQBACK:int = 3;
public static const DRAW_TEXT:int = 4;

public static const TYPEFILTER_FLOOR:int = 0;
public static const TYPEFILTER_BLOCKING:int = 1;
public static const TYPEFILTER_STATTYPES:int = 2;
public static const TYPEALL_ROWLIMIT:int = 21;
public static const TYPEALL_PAGELIMIT:int = 42;

public static const SM_STATELEM:int = 0;
public static const SM_UNDERCOLOR:int = 1;
public static const SM_WORLDTYPECHOICELOAD:int = 2;
public static const SM_WORLDTYPECHOICESAVE:int = 3;
public static const SM_WORLDINFO:int = 4;
public static const SM_BOARDINFO:int = 5;
public static const SM_BOARDSWITCH:int = 6;
public static const SM_TRANSFER:int = 7;
public static const SM_STATINFO:int = 8;
public static const SM_STATLIST:int = 9;
public static const SM_INVENTORYINFO:int = 10;
public static const SM_GLOBALS:int = 11;
public static const SM_OBJLIB:int = 12;
public static const SM_EXTRAGUI:int = 13;
public static const SM_EXTRAWAD:int = 14;
public static const SM_CHAREDITLOAD:int = 15;
public static const SM_CHAREDITSAVE:int = 16;
public static const SM_GUITEXT:int = 17;

public static const BSA_SWITCHBOARD:int = 0;
public static const BSA_SETBOARDPROP:int = 1;
public static const BSA_SETWORLDPROP:int = 2;
public static const BSA_SETPASSAGEDEST:int = 3;

public static const FILL_PAINT:int = 0;
public static const FILL_RANDOMPAINT:int = 1;
public static const FILL_SELECTION:int = 2;

public static const GRAD_LINEAR:int = 0;
public static const GRAD_BILINEAR:int = 1;
public static const GRAD_RADIAL:int = 2;

public static const MAX_BBUFFER:int = 64;

// GUI/Combined editor vars
public static var modFlag:Boolean = false;
public static var fgColorCursor:int = 15;
public static var bgColorCursor:int = 1;
public static var oldFgColorCursor:int = 15;
public static var oldBgColorCursor:int = 1;
public static var blinkFlag:Boolean = false;
public static var typingTextInGuiEditor:Boolean = false;
public static var guiTextEditCursor:int = 0;
public static var altCharCursor:int = 0;
public static var lastChar:int = 0;
public static var editWidth:int = 20;
public static var editHeight:int = 25;

public static var editorChars:ByteArray;
public static var editorAttrs:ByteArray;
public static var cursorActive:Boolean = true;

// World editor vars
public static var patternBuiltIn:int = 6;
public static var patternCursor:int = 0;
public static var patternBBCursor:int = 0;

public static var oldHlpStr:String = "";
public static var hasExistingTypeSpec:Boolean = false;
public static var newTypeNameFocus:String = "";
public static var newTypeString:String = "";
public static var newTypeNum:int = 0;
public static var editedPropName:String = "";
public static var errorMsgs:String = "";
public static var hexTextEntry:int = 0;
public static var hexCodeValue:int = 0;
public static var text128:Boolean = false;
public static var drawFlag:int = 0;
public static var defColorMode:Boolean = true;
public static var acquireMode:Boolean = false;
public static var bufLockMode:Boolean = false;
public static var editorStyle:int = 0;
public static var scrollMode:int = 0;
public static var boardSelectAction:int = 0;
public static var worldSaveType:int = -3;
public static var quitAfterSave:Boolean = false;

public static var typeAllFilter:int = 0;
public static var typeAllPage:int = 0;
public static var typeAllCursor:int = 0;
public static var typeAllPageCount:int = 0;
public static var typeAllTypes:Array = [];

public static var numStats:int = 0;
public static var maxStats:int = 151;
public static var editorCursorX:int = 1;
public static var editorCursorY:int = 1;
public static var boardWidth:int = 60;
public static var boardHeight:int = 25;
public static var origCameraX:int = 1;
public static var origCameraY:int = 1;

public static var anchorX:int = -1;
public static var anchorY:int = -1;
public static var clipX1:int = 0;
public static var clipY1:int = 0;
public static var guiClipWidth:int = 0;
public static var guiClipHeight:int = 0;
public static var invertGPts:Boolean = false;
public static var gradientShape:int = 0;
public static var gradientDither:Number = 0.0;

public static var immType:Array = [32, 15, 0, null];
public static var actualBBLen:int = 10;
public static var bBuffer:Array = null;
public static var selBuffer:Array = [];
public static var gradBuffer:Array = [];
public static var fillBuffer:Array = [];
public static var clipBuffer:Array = [];
public static var guiClipBuffer:Array = [];
public static var objLibraryBuffer:Array = [];
public static var tempStatProps:Object = null;

public static var prevStepX:int = 1;
public static var prevStepY:int = 0;
public static var prevP1:int = 0;
public static var prevP2:int = 0;
public static var prevP3:int = 0;

public static var sBuffer:ByteArray;

public static var charEditorInit:Boolean = false;
public static var cePreviewIdent:Boolean = false;
public static var ceCharWidth:int = 8;
public static var ceCharHeight:int = 16;
public static var ceCharHeightMode:int = 2;
public static var ceCharCount:int = 256;
public static var ceCharNum:int = 0;
public static var ceCharX:int = 0;
public static var ceCharY:int = 0;
public static var ceCharDrawMode:int = 0;
public static var ceCharMouseMode:int = 0;
public static var ceMaskArray:Array;
public static var ceMaskCBArray:Array;
public static var cePreviewChars:Array;
public static var ceStorage:Array;
public static var savedCEStorage:Array = [ null, null, null ];

public static var playerExtras:Object = {
	"CHAR" : 2
};
public static var playerDeadExtras:Object = {
	"CHAR" : 2,
	"$DEADSMILEY" : 1
};
public static var passageExtras:Object = {
	"P2" : 15
};
public static var scrollExtras:Object = {
	"$CODE" : ""
};
public static var duplicatorExtras:Object = {
	"CHAR" : 250
};
public static var starExtras:Object = {
	"CHAR" : 47
};
public static var spinningGunExtras:Object = {
	"CHAR" : 24
};
public static var objectExtras:Object = {
	"CHAR" : 1,
	"$CODE" : ""
};
public static var transporterExtras:Object = {
	"CHAR" : 62
};
public static var dragonPupExtras:Object = {
	"CHAR" : 148
};
public static var stoneExtras:Object = {
	"CHAR" : 90
};

public static var longBuiltInTypes:Array =
	[[219, 21], [178, 22], [177, 23], [176, 19], [32, 0], [206, 31]];
public static var shortBuiltInTypes:Array =
	[[219, 21], [178, 22], [177, 23], [32, 0], [206, 31]];

public static var editorDefaultGuis:Array = [
	"ED_ULTRA1", "ED_KEVEDIT", "ED_CLASSIC", "ED_SUPERZZT"
];

public static var prettyColorNames:Array = [
	"Black   ", "D. Blue ", "D. Green", "D. Cyan ",
	"D. Red  ", "D.Purple", "Brown   ", "Grey    ",
	"D. Grey ", "Blue    ", "Green   ", "Cyan    ",
	"Red     ", "Purple  ", "Yellow  ", "White   "
];

public static var requiredWorldKeys:Array = [
	"WORLDNAME", "WORLDTYPE", "STARTBOARD", "AMMO", "GEMS", "HEALTH",
	"TORCHES", "SCORE", "TIME", "Z", "TORCHCYCLES", "ENERGIZERCYCLES",
	"KEY0", "KEY1", "KEY2", "KEY3", "KEY4", "KEY5", "KEY6", "KEY7",
	"KEY8", "KEY9", "KEY10", "KEY11", "KEY12", "KEY13", "KEY14", "KEY15"
];

public static var inventoryWorldKeys:Array = [
	"AMMO", "GEMS", "HEALTH", "TORCHES", "SCORE", "TIME", "Z", "TORCHCYCLES",
	"ENERGIZERCYCLES", "KEY8", "KEY9", "KEY10", "KEY11", "KEY12", "KEY13", "KEY14", "KEY15"
];

public static var notIncludedBoardKeys:Array = [
	"BOARDNAME", "SIZEX", "SIZEY", "ISDARK", "RESTARTONZAP",
	"TIMELIMIT", "MAXPLAYERSHOTS", "EXITNORTH", "EXITSOUTH", "EXITEAST", "EXITWEST"
];

public static var nonExtraStatusKeys:Array = [
	"CYCLE", "X", "Y", "STEPX", "STEPY", "FLAGS", "delay",
	"IP", "UNDERID", "UNDERCOLOR", "CODEID", "$CODE"
];

public static var propText:String;
public static var emptyGuiProperties:String = "{\n"+
"\"Use40Column\":0,\n\"OverallSizeX\":80,\n\"OverallSizeY\":25,\n"+
"\"GuiLocX\":61,\n\"GuiLocY\":1,\n\"GuiWidth\":20,\n\"GuiHeight\":25,\n"+
"\"Viewport\":[1,1,60,25],\n\"KeyInput\":{ },\n\"Label\":{ }\n}";

// Draw the GUI editor color band
public static function drawColorBand(labelStr:String):void
{
	// Assumed that color band is just below label
	var guiLabelInfo:Array = zzt.GuiLabels[labelStr];
	var gx:int = (zzt.GuiLocX-1) + int(guiLabelInfo[0]) - 1 + 2;
	var gy:int = (zzt.GuiLocY-1) + int(guiLabelInfo[1]) + 1 - 1;

	// Write color band
	zzt.mg.setCell(gx++, gy, 223, 8);
	zzt.mg.setCell(gx++, gy, 223, 25);
	zzt.mg.setCell(gx++, gy, 223, 42);
	zzt.mg.setCell(gx++, gy, 223, 59);
	zzt.mg.setCell(gx++, gy, 223, 76);
	zzt.mg.setCell(gx++, gy, 223, 93);
	zzt.mg.setCell(gx++, gy, 223, 110);
	zzt.mg.setCell(gx++, gy, 223, 127);
}

// Dispatch a GUI-editor menu message
public static function dispatchEditGuiMenu(msg:String):void
{
	var jObj:Object;
	switch (msg) {
		case "EVENT_REDRAW":
			zzt.mainMode = zzt.MODE_NORM;
			writeColorCursors();
			break;
		case "EVENT_TESTDRAWGUI":
			writeGuiTextEdit();
			break;
		case "EVENT_LOADGUI":
			parse.loadLocalFile("ZZTGUI", zzt.MODE_LOADGUI);
			break;
		case "EVENT_SAVEGUI":
			saveGuiFile();
			break;
		case "EVENT_SAVEANDQUIT":
			saveGuiFile();
			zzt.mainMode = zzt.MODE_NORM;
			zzt.popGui();
			break;
		case "EVENT_GUIPROPERTIES":
			// Show properties editor.
			zzt.showPropTextView(zzt.MODE_ENTERGUIPROP, "GUI Properties", propText);
			break;
		case "EVENT_ACCEPTPROP":
			// Parse properties text.
			jObj = parse.jsonDecode(zzt.guiPropText.text);
			if (jObj != null)
			{
				// Get properties text; hide properties editor.
				propText = zzt.guiPropText.text;
				zzt.hidePropTextView(zzt.MODE_NORM);

				// From the parsed properties, resize the GUI editing portion, if needed.
				editWidth = int(jObj.GuiWidth);
				editHeight = int(jObj.GuiHeight);
				if (editWidth <= 0 || editWidth > zzt.CHARS_WIDTH)
					editWidth = 20;
				if (editHeight <= 0 || editHeight > zzt.CHARS_HEIGHT)
					editHeight = 25;
				modFlag = true;
				zzt.drawGuiLabel("MODFLAG", "*");
			}
			break;
		case "EVENT_QUITGUIEDITOR":
			if (modFlag)
				zzt.confMessage("CONFMESSAGE", "Save First?",
					"EVENT_SAVEANDQUIT", "EVENT_REALLYQUIT", "EVENT_CANCEL");
			else
				dispatchEditGuiMenu("EVENT_REALLYQUIT");
			break;
		case "EVENT_REALLYQUIT":
			zzt.mainMode = zzt.MODE_NORM;
			zzt.popGui();
			break;
		case "EVENT_CANCEL":
			break;
		case "EVENT_FGCOLOR":
			fgColorCursor += 1;
			fgColorCursor &= 15;
			writeColorCursors();
			break;
		case "EVENT_BGCOLOR":
			bgColorCursor += 1;
			bgColorCursor &= 7;
			writeColorCursors();
			break;
		case "EVENT_TOGGLEBLINK":
			blinkFlag = !blinkFlag;
			writeColorCursors();
			break;
		case "EVENT_EDITTEXT":
			if (zzt.establishGui("EDITGUITEXT"))
			{
				zzt.mainMode = zzt.MODE_NORM;
				zzt.mg.writeConst(0, 0, zzt.CHARS_WIDTH, zzt.CHARS_HEIGHT, " ", 31);
				zzt.drawGui();
				drawFlag = 0;
				typingTextInGuiEditor = true;
				writeGuiTextEdit();
				writeGuiTextEditLabels();
				zzt.guiStack.push("EDITGUITEXT");
			}
			break;
	}
}

public static function dispatchEditGuiTextMenu(msg:String):void
{
	var i:int;
	var j:int;
	switch (msg) {
		case "EVENT_RETURNTOEDITGUI":
			typingTextInGuiEditor = false;
			zzt.popGui();
			zzt.drawGuiLabel("MODFLAG", modFlag ? "*" : " ");
			break;
		case "EVENT_BACKSPACE":
		case "EVENT_LEFT":
			guiTextEditCursor -= 1;
			if (guiTextEditCursor < 0)
				guiTextEditCursor = editWidth * editHeight - 1;
			anchorX = guiTextEditCursor;

			if (drawFlag)
				writeKeyToGuiEditor(lastChar, false);
			else
				writeGuiTextEdit();
			break;
		case "EVENT_RIGHT":
			guiTextEditCursor += 1;
			if (guiTextEditCursor >= editWidth * editHeight)
				guiTextEditCursor = 0;
			anchorX = guiTextEditCursor;

			if (drawFlag)
				writeKeyToGuiEditor(lastChar, false);
			else
				writeGuiTextEdit();
			break;
		case "EVENT_UP":
			guiTextEditCursor -= editWidth;
			if (guiTextEditCursor < 0)
				guiTextEditCursor = 0;
			anchorX = guiTextEditCursor;

			if (drawFlag)
				writeKeyToGuiEditor(lastChar, false);
			else
				writeGuiTextEdit();
			break;
		case "EVENT_DOWN":
			guiTextEditCursor += editWidth;
			if (guiTextEditCursor >= editWidth * editHeight)
				guiTextEditCursor = editWidth * editHeight - 1;
			anchorX = guiTextEditCursor;

			if (drawFlag)
				writeKeyToGuiEditor(lastChar, false);
			else
				writeGuiTextEdit();
			break;
		case "EVENT_SELLEFT":
			guiTextEditCursor -= 1;
			if (guiTextEditCursor < 0)
				guiTextEditCursor = editWidth * editHeight - 1;
			writeGuiTextEdit(true);
			break;
		case "EVENT_SELRIGHT":
			guiTextEditCursor += 1;
			if (guiTextEditCursor >= editWidth * editHeight)
				guiTextEditCursor = 0;
			writeGuiTextEdit(true);
			break;
		case "EVENT_SELUP":
			guiTextEditCursor -= editWidth;
			if (guiTextEditCursor < 0)
				guiTextEditCursor = 0;
			writeGuiTextEdit(true);
			break;
		case "EVENT_SELDOWN":
			guiTextEditCursor += editWidth;
			if (guiTextEditCursor >= editWidth * editHeight)
				guiTextEditCursor = editWidth * editHeight - 1;
			writeGuiTextEdit(true);
			break;

		case "EVENT_COLORDIALOG":
			oldFgColorCursor = fgColorCursor;
			oldBgColorCursor = bgColorCursor;
			scrollMode = SM_GUITEXT;
			zzt.inEditor = true;
			zzt.mainMode = zzt.MODE_COLORSEL;
			zzt.establishGui("ED_COLORS");
			for (j = 1; j <= 8; j++) {
				zzt.GuiTextLines[j] = String.fromCharCode(179);
				for (i = 1; i <= 32; i++) {
					zzt.GuiTextLines[j] += String.fromCharCode(254);
				}
				zzt.GuiTextLines[j] += String.fromCharCode(179);
			}
			zzt.drawGui();
			drawKolorCursor(true);
			break;

		case "EVENT_COPY":
			copyGuiTextRange();
			anchorX = guiTextEditCursor;
			writeGuiTextEdit();
			break;
		case "EVENT_PASTE":
			pasteGuiText();
			writeGuiTextEdit();
			break;

		case "EVENT_ALTCHAR":
			altCharCursor += 1;
			if (altCharCursor > 32 && altCharCursor < 127)
				altCharCursor = 127;
			else if (altCharCursor >= 256)
				altCharCursor = 0;

			lastChar = altCharCursor;
			writeGuiTextEditLabels();
			break;
		case "EVENT_ALTCHAR2":
			altCharCursor -= 1;
			if (altCharCursor > 32 && altCharCursor < 127)
				altCharCursor = 32;
			else if (altCharCursor < 0)
				altCharCursor = 255;

			lastChar = altCharCursor;
			writeGuiTextEditLabels();
			break;
		case "EVENT_TOGGLEDRAW":
			drawFlag = drawFlag ^ 1;
			if (drawFlag)
				writeKeyToGuiEditor(lastChar, false);

			writeGuiTextEditLabels();
			break;
		case "EVENT_PLOTLAST":
			writeKeyToGuiEditor(lastChar);
			break;
		case "EVENT_PICKUPCHAR":
			i = int(guiTextEditCursor % editWidth);
			j = int(guiTextEditCursor / editWidth);
			lastChar = editorChars[j * zzt.MAX_WIDTH + i];
			altCharCursor = lastChar;
			writeGuiTextEditLabels();
			break;
		case "EVENT_PICKUPALL":
			i = int(guiTextEditCursor % editWidth);
			j = int(guiTextEditCursor / editWidth);
			lastChar = editorChars[j * zzt.MAX_WIDTH + i];
			altCharCursor = lastChar;
			fgColorCursor = editorAttrs[j * zzt.MAX_WIDTH + i];
			bgColorCursor = (fgColorCursor >> 4) & 7;
			blinkFlag = Boolean((fgColorCursor & 128) != 0);
			fgColorCursor &= 15;
			writeGuiTextEditLabels();
			break;

		case "EVENT_FGCOLOR":
			fgColorCursor += 1;
			fgColorCursor &= 15;
			writeGuiTextEditLabels();
			break;
		case "EVENT_BGCOLOR":
			bgColorCursor += 1;
			bgColorCursor &= 7;
			writeGuiTextEditLabels();
			break;
		case "EVENT_TOGGLEBLINK":
			blinkFlag = !blinkFlag;
			writeGuiTextEditLabels();
			break;

		case "EVENT_SETLABEL":
			i = int(guiTextEditCursor % editWidth);
			j = int(guiTextEditCursor / editWidth);
			typingTextInGuiEditor = false;
			zzt.popGui();
			insertNewGuiLabelAt("Label", "NEWLABEL",
				i + 1, j + 1, 5, editorAttrs[j * zzt.MAX_WIDTH + i]);
			zzt.showPropTextView(zzt.MODE_ENTERGUIPROP, "GUI Properties", propText);
			break;
		case "EVENT_SETMOUSEINPUT":
			i = int(guiTextEditCursor % editWidth);
			j = int(guiTextEditCursor / editWidth);
			typingTextInGuiEditor = false;
			zzt.popGui();
			insertNewGuiLabelAt("MouseInput", "NEWEVENT", i + 1, j + 1, 5, 1);
			zzt.showPropTextView(zzt.MODE_ENTERGUIPROP, "GUI Properties", propText);
			break;
	}
}

// Insert a new GUI label within properties text.
public static function insertNewGuiLabelAt(propContainer:String, labelStr:String,
	x:int, y:int, xLen:int, yLen:int):void {
	var newLabel:String =
		"\n\"" + labelStr + "\":[" + x + "," + y + "," + xLen + "," + yLen + "],\n";

	var contStr:String = "\"" + propContainer + "\":";
	var idx:int = propText.indexOf(contStr);
	if (idx == -1)
	{
		propText = propText.substr(0, 1) + contStr + "{\n}," + propText.substr(1);
		idx = 1;
	}

	idx = propText.indexOf("{", idx) + 1;
	propText = propText.substr(0, idx) + newLabel + propText.substr(idx);
}

public static function writeColorCursors():void
{
	var fgColorStr:String = "  ";
	var bgColorStr:String = "  ";
	var blinkStr:String = "  No ";

	for (var i:int = 0; i < 8; i++)
	{
		if (i == fgColorCursor - 8)
			fgColorStr += String.fromCharCode(31);
		else
			fgColorStr += " ";
	}
	for (var j:int = 0; j < 8; j++)
	{
		if (j == fgColorCursor)
			bgColorStr += String.fromCharCode(30);
		else if (j == bgColorCursor)
			bgColorStr += String.fromCharCode(24);
		else
			bgColorStr += " ";
	}
	if (blinkFlag)
		blinkStr = "  Yes";

	var doOffset:Boolean = Boolean(zzt.thisGuiName == "EDITGUITEXT");
	drawGuiLabelSmart("COLORCURSOR1", fgColorStr, doOffset);
	drawGuiLabelSmart("COLORCURSOR2", bgColorStr, doOffset);
	drawGuiLabelSmart("BLINKLABEL", blinkStr, doOffset);
	drawColorBand("COLORCURSOR1");
}

public static function writeGuiTextEditLabels():void
{
	drawGuiLabelSmart("TOGGLEDRAW", "Tab:  Draw mode " + (drawFlag ? "ON " : "OFF"));
	drawGuiLabelSmart("PLOTLAST", "Space:  Plot last");
	drawGuiLabelSmart("ALTCHAR", "Numpad +/-:  Char " + String.fromCharCode(altCharCursor));
	drawGuiLabelSmart("PICKUPCHAR", "Enter:  Get char");
	drawGuiLabelSmart("PICKUPALL", "Shift+Enter: Get all");
	drawGuiLabelSmart("SETLABEL", "F3:  Set GUI label");
	drawGuiLabelSmart("SETMOUSEINPUT", "F4:  Set mouse label");
	drawGuiLabelSmart("RETURNTOEDITGUI", "Esc:  Back to menu");
	drawGuiLabelSmart("COLORDIALOG", "Ctrl+K:  Color dlg.");
	drawGuiLabelSmart("RANGE", "Shift+Arrow:  Select");
	drawGuiLabelSmart("COPY", "Ctrl+C:  Copy");
	drawGuiLabelSmart("PASTE", "Ctrl+V:  Paste");
	writeColorCursors();
}

public static function drawGuiLabelSmart(lbl:String, val:String, doOffset:Boolean=true):void
{
	// Kick label to left side of display if cursor would intrude on label area.
	if (doOffset)
	{
		var gx:int = guiTextEditCursor % editWidth;
		gx = (gx >= 60) ? -79 : -19;
		zzt.GuiLabels[lbl][0] = gx;
	}

	zzt.drawGuiLabel(lbl, val);
}

public static function writeGuiTextEdit(showSel:Boolean=false):void
{
	var gx:Array = utils.orderInts(
		guiTextEditCursor % editWidth, anchorX % editWidth);
	var gy:Array = utils.orderInts(
		int(guiTextEditCursor / editWidth), int(anchorX / editWidth));

	var gtc:int = 0;
	for (var j:int = 0; j < editHeight; j++)
	{
		for (var i:int = 0; i < editWidth; i++)
		{
			var color:int = editorAttrs[j * zzt.MAX_WIDTH + i];
			if (guiTextEditCursor == gtc)
				color = color ^ 127;
			else if (showSel)
			{
				if (i >= gx[0] && i <= gx[1] && j >= gy[0] && j <= gy[1])
					color = color ^ 127;
			}

			gtc++;
			zzt.mg.setCell(i, j, editorChars[j * zzt.MAX_WIDTH + i], color);
		}
	}
}

public static function writeKeyToGuiEditor(c:uint, doAdvance:Boolean=true):void
{
	lastChar = int(c);
	var gx:int = guiTextEditCursor % editWidth;
	var gy:int = int(guiTextEditCursor / editWidth);
	var color:int = fgColorCursor + (bgColorCursor * 16) + (blinkFlag ? 128 : 0);
	editorChars[gy * zzt.MAX_WIDTH + gx] = lastChar;
	editorAttrs[gy * zzt.MAX_WIDTH + gx] = color;

	if (doAdvance)
	{
		guiTextEditCursor += 1;
		if (guiTextEditCursor >= editWidth * editHeight)
			guiTextEditCursor = 0;
	}

	writeGuiTextEdit();
	modFlag = true;
}

public static function copyGuiTextRange():void {
	var gx:Array = utils.orderInts(
		guiTextEditCursor % editWidth, anchorX % editWidth);
	var gy:Array = utils.orderInts(
		int(guiTextEditCursor / editWidth), int(anchorX / editWidth));

	guiClipWidth = gx[1] - gx[0] + 1;
	guiClipHeight = gy[1] - gy[0] + 1;
	guiClipBuffer = new Array(guiClipHeight * guiClipWidth * 2);

	var gtc:int = 0;
	for (var y:int = gy[0]; y <= gy[1]; y++) {
		for (var x:int = gx[0]; x <= gx[1]; x++) {
			guiClipBuffer[gtc++] = editorChars[y * zzt.MAX_WIDTH + x];
			guiClipBuffer[gtc++] = editorAttrs[y * zzt.MAX_WIDTH + x];
		}
	}
}

public static function pasteGuiText():void {
	var gx:int = guiTextEditCursor % editWidth;
	var gy:int = int(guiTextEditCursor / editWidth);

	var gtc:int = 0;
	for (var y:int = 0; y < guiClipHeight; y++) {
		for (var x:int = 0; x < guiClipWidth; x++) {
			editorChars[(y + gy) * zzt.MAX_WIDTH + (x + gx)] = guiClipBuffer[gtc++];
			editorAttrs[(y + gy) * zzt.MAX_WIDTH + (x + gx)] = guiClipBuffer[gtc++];
		}
	}

	modFlag = true;
}

public static function loadGuiFile():void
{
	var jObj:Object = parse.jsonDecode(parse.fileData.toString());
	if (jObj != null)
	{
		// Get interface size
		editWidth = int(jObj.GuiWidth);
		editHeight = int(jObj.GuiHeight);

		// Get text and color info
		var txt:String = jObj.Text;
		var cols:Array = jObj.Color;

		// Copy text characters
		var sCursor:int = 0;
		for (var j:int = 0; j < editHeight; )
		{
			var eCursor:int = txt.indexOf("\n", sCursor);
			if (eCursor == -1)
				break;

			if (eCursor - sCursor >= editWidth)
			{
				for (var i:int = 0; i < editWidth; i++)
					editorChars[j * zzt.MAX_WIDTH + i] = txt.charCodeAt(sCursor + i);
				j++;
			}

			sCursor = ++eCursor;
		}

		// Copy colors
		sCursor = 0;
		var cColor:int = cols[sCursor++];
		var cLen:int = cols[sCursor++];
		for (j = 0; j < editHeight; j++)
		{
			for (i = 0; i < editWidth; i++)
			{
				if (cLen == 0)
				{
					cColor = cols[sCursor++];
					cLen = cols[sCursor++];
				}

				editorAttrs[j * zzt.MAX_WIDTH + i] = cColor;
				cLen--;
			}
		}

		// Remove text and colors from properties dictionary
		delete jObj.Text;
		delete jObj.Color;

		// Maintain remaining dataset as text
		propText = parse.jsonToText(jObj, true);

		// Redraw
		zzt.drawGuiLabel("MODFLAG", " ");
		writeGuiTextEdit();
		writeColorCursors();
		modFlag = false;
	}
}

public static function saveGuiFile():void
{
	// First, build text record.
	var txt:String = "\n";
	for (var j:int = 0; j < editHeight; j++)
	{
		for (var i:int = 0; i < editWidth; i++)
		{
			var ec:int = editorChars[j * zzt.MAX_WIDTH + i];
			txt += String.fromCharCode(ec);
		}

		txt += "\n";
	}

	// Next, build color record.
	var cols:Array = [];
	var lastCol:int = 10000;
	var colCount:int = 0;
	for (j = 0; j < editHeight; j++)
	{
		for (i = 0; i < editWidth; i++)
		{
			var thisCol:int = editorAttrs[j * zzt.MAX_WIDTH + i];
			if (thisCol != lastCol)
			{
				if (colCount > 0)
				{
					cols.push(lastCol);
					cols.push(colCount);
				}

				lastCol = thisCol;
				colCount = 1;
			}
			else
				colCount++;
		}

		if (colCount > 0)
		{
			cols.push(lastCol);
			cols.push(colCount);
			colCount = 0;
		}
	}

	// Create dictionary from properties, text, and colors
	var jObj:Object = parse.jsonDecode(propText);
	jObj["Text"] = txt;
	jObj["Color"] = cols;

	// Data is ready; show save dialog.
	var fileName:String = parse.lastFileName;
	if (!utils.endswith(fileName, ".ZZTGUI"))
		fileName = ".ZZTGUI";

	parse.saveLocalFile(fileName, zzt.MODE_SAVEGUI, zzt.MODE_NORM, parse.jsonToText(jObj));
	modFlag = false;
	zzt.drawGuiLabel("MODFLAG", " ");
}

// Set up editor flags, info, etc.
public static function initEditor():void
{
	if (bBuffer == null)
	{
		// First time creation of back buffer creates empties
		bBuffer = new Array(MAX_BBUFFER);
		for (var i:int = 0; i < MAX_BBUFFER; i++)
			bBuffer[i] = [0, 15, 0, null];
	}

	// Initialize editor per chosen style
	cursorActive = true;
	quitAfterSave = false;
	blinkFlag = false;
	drawFlag = DRAW_OFF;
	acquireMode = false;
	bufLockMode = false;
	selBuffer = [];
	anchorX = -1;
	zzt.typeList[zzt.invisibleType].CHAR = 176;
	zzt.typeList[zzt.bEdgeType].CHAR = 69;
	switch (editorStyle) {
		case EDSTYLE_ULTRA:
			interp.typeTrans[19] = zzt.waterType;
			zzt.typeList[zzt.bearType].CHAR = 153;
			zzt.typeList[zzt.bearType].COLOR = 6;
			maxStats = 9999;
			patternBuiltIn = 6;
			if (actualBBLen == 1)
				actualBBLen = 10;
		break;
		case EDSTYLE_KEVEDIT:
			interp.typeTrans[19] = zzt.waterType;
			zzt.typeList[zzt.bearType].CHAR = 153;
			zzt.typeList[zzt.bearType].COLOR = 6;
			maxStats = 151;
			patternBuiltIn = 6;
			if (actualBBLen == 1)
				actualBBLen = 10;
		break;
		case EDSTYLE_CLASSIC:
			interp.typeTrans[19] = zzt.waterType;
			zzt.typeList[zzt.bearType].CHAR = 153;
			zzt.typeList[zzt.bearType].COLOR = 6;
			defColorMode = true;
			maxStats = 151;
			patternBuiltIn = 5;
			actualBBLen = 1;
			bgColorCursor = 0;
			patternCursor = 0;
			patternBBCursor = 0;
		break;
		case EDSTYLE_SUPERZZT:
			interp.typeTrans[19] = zzt.lavaType;
			zzt.typeList[zzt.bearType].CHAR = 235;
			zzt.typeList[zzt.bearType].COLOR = 2;
			defColorMode = true;
			maxStats = 129;
			patternBuiltIn = 5;
			actualBBLen = 1;
			patternCursor = 0;
			patternBBCursor = 0;
		break;
	}
}

public static function getPrettyColorName(color:int):String {
	if (color < 0 && color >= 16)
		return "        ";
	return prettyColorNames[color];
}

public static function getNamedStep(dx:int, dy:int):String {
	if (dx == 0)
	{
		if (dy == -1)
			return (String.fromCharCode(24) + " NORTH");
		else if (dy == 1)
			return (String.fromCharCode(25) + " SOUTH");
		else if (dy == 0)
			return (String.fromCharCode(249) + " IDLE");
	}
	else if (dy == 0)
	{
		if (dx == -1)
			return (String.fromCharCode(27) + " WEST");
		else if (dx == 1)
			return (String.fromCharCode(26) + " EAST");
	}

	return "(Nonstandard)";
}

// Make sure camera stays valid when moving across boards
public static function clipCamera():void {
	SE.CameraX = origCameraX;
	SE.CameraY = origCameraY;

	if (SE.CameraX + SE.vpWidth - 1 > boardWidth)
		SE.CameraX = boardWidth - SE.vpWidth + 1;
	if (SE.CameraX < 1)
		SE.CameraX = 1;

	if (SE.CameraY + SE.vpHeight - 1 > boardHeight)
		SE.CameraY = boardHeight - SE.vpHeight + 1;
	if (SE.CameraY < 1)
		SE.CameraY = 1;
}

// Set up empty world properties with a single empty board
public static function newWorldSetup():void {
	// World properties
	zzt.globalProps["EVERPLAYED"] = 0;
	zzt.globalProps["WORLDTYPE"] = -3;
	zzt.globalProps["WORLDNAME"] = "Untitled";
	zzt.globalProps["LOCKED"] = 0;
	zzt.globalProps["NUMBOARDS"] = 1;
	zzt.globalProps["NUMBASECODEBLOCKS"] = interp.numBuiltInCodeBlocks;
	zzt.globalProps["NUMCLASSICFLAGS"] = 0;
	zzt.globalProps["CODEDELIMETER"] = "\n";
	zzt.globalProps["STARTBOARD"] = 0;
	zzt.globalProps["BOARD"] = -1;
	zzt.globalProps["AMMO"] = 0;
	zzt.globalProps["GEMS"] = 0;
	zzt.globalProps["HEALTH"] = 100;
	zzt.globalProps["TORCHES"] = 0;
	zzt.globalProps["SCORE"] = 0;
	zzt.globalProps["TIME"] = 0;
	zzt.globalProps["Z"] = 0;
	zzt.globalProps["TORCHCYCLES"] = 0;
	zzt.globalProps["ENERGIZERCYCLES"] = 0;
	zzt.globalProps["KEY8"] = 0;
	zzt.globalProps["KEY9"] = 0;
	zzt.globalProps["KEY10"] = 0;
	zzt.globalProps["KEY11"] = 0;
	zzt.globalProps["KEY12"] = 0;
	zzt.globalProps["KEY13"] = 0;
	zzt.globalProps["KEY14"] = 0;
	zzt.globalProps["KEY15"] = 0;

	// Sounds
	for (var k:String in ZZTProp.defaultSoundFx)
		zzt.soundFx[k] = ZZTProp.defaultSoundFx[k];

	// Board properties
	boardWidth = 60;
	boardHeight = 25;
	newBoardSetup();

	// Storage
	var thisBoard:ZZTBoard = new ZZTBoard();
	ZZTLoader.extraMasks = new Object();
	ZZTLoader.extraSoundFX = new Object();
	ZZTLoader.boardData = new Array(1);
	ZZTLoader.boardData[0] = thisBoard;
	thisBoard.props = zzt.boardProps;
	thisBoard.statElementCount = 0;
	thisBoard.statLessCount = 0;
	thisBoard.statElem = zzt.statElem;
	thisBoard.playerSE = null;
	thisBoard.typeBuffer = new ByteArray();
	thisBoard.typeBuffer.length = boardWidth * boardHeight;
	thisBoard.colorBuffer = new ByteArray();
	thisBoard.colorBuffer.length = boardWidth * boardHeight;
	thisBoard.lightBuffer = new ByteArray();
	thisBoard.lightBuffer.length = boardWidth * boardHeight;
	thisBoard.regions = new Object();
	zzt.regions = thisBoard.regions;
	thisBoard.saveStamp = "init";
	thisBoard.boardIndex = 0;
	thisBoard.saveIndex = 0;
	thisBoard.saveType = -1;
}

// Set up empty board properties; clear grid if not created from editor
public static function newBoardSetup(srcboardProps:Object=null):void {
	var boardProps:Object = srcboardProps;
	if (boardProps == null)
		boardProps = zzt.boardProps;

	// Board properties
	boardProps["EXITNORTH"] = 0;
	boardProps["EXITSOUTH"] = 0;
	boardProps["EXITWEST"] = 0;
	boardProps["EXITEAST"] = 0;
	boardProps["SIZEX"] = boardWidth;
	boardProps["SIZEY"] = boardHeight;
	boardProps["MESSAGE"] = "";
	boardProps["MAXPLAYERSHOTS"] = 255;
	boardProps["CURPLAYERSHOTS"] = 0;
	boardProps["ISDARK"] = 0;
	boardProps["RESTARTONZAP"] = 0;
	boardProps["BOARDNAME"] = "Title Screen";
	boardProps["FROMPASSAGEHACK"] = 0;
	boardProps["PLAYERCOUNT"] = 0;
	boardProps["PLAYERENTERX"] = 1;
	boardProps["PLAYERENTERY"] = 1;
	boardProps["CAMERAX"] = 1;
	boardProps["CAMERAY"] = 1;
	boardProps["TIMELIMIT"] = 0;

	// Grid
	if (srcboardProps == null)
	{
		ZZTLoader.setUpGrid(boardWidth, boardHeight);
		for (var y:int = 1; y <= boardHeight; y++) {
			for (var x:int = 1; x <= boardWidth; x++) {
				SE.setType(x, y, 0);
				SE.setColor(x, y, 15, false);
				SE.setStatElemAt(x, y, null);
			}
		}

		zzt.statElem.splice(0, zzt.statElem.length);
	}
}

// Add a new board
public static function addNewBoard():void {
	modFlag = true;
	var thisBoard:ZZTBoard = new ZZTBoard();
	ZZTLoader.boardData.push(thisBoard);

	thisBoard.props = new Object();
	newBoardSetup(thisBoard.props);
	thisBoard.props["BOARDNAME"] = "Untitled";

	thisBoard.statElem = new Vector.<SE>();
	thisBoard.statElementCount = 0;
	thisBoard.statLessCount = 0;
	thisBoard.playerSE = null;
	thisBoard.typeBuffer = new ByteArray();
	thisBoard.typeBuffer.length = boardWidth * boardHeight;
	thisBoard.colorBuffer = new ByteArray();
	thisBoard.colorBuffer.length = boardWidth * boardHeight;
	thisBoard.lightBuffer = new ByteArray();
	thisBoard.lightBuffer.length = boardWidth * boardHeight;
	thisBoard.regions = new Object();
	thisBoard.saveStamp = "init";
	thisBoard.boardIndex = 0;
	thisBoard.saveIndex = 0;
	thisBoard.saveType = -1;

	var totalSquares:int = boardWidth * boardHeight;
	for (var i:int = 0; i < totalSquares; i++) {
		thisBoard.typeBuffer[i] = 0;
		thisBoard.colorBuffer[i] = 15;
		thisBoard.lightBuffer[i] = 0;
	}

	zzt.globalProps["NUMBOARDS"] += 1;
}

public static function adjustBoardNum(cont:Object, key:String, delBoardNum:int):void {
	if (cont[key] >= delBoardNum)
		cont[key] -= 1;
}

public static function deleteBoard(delBoardNum:int):Boolean {
	if (delBoardNum == 0)
		return false; // Can't remove title screen--need at least one board!

	// Save current board info; move current board to before the shift position.
	modFlag = true;
	ZZTLoader.registerBoardState(true);
	if (zzt.globalProps["BOARD"] >= delBoardNum)
		zzt.globalProps["BOARD"] = 0;

	// Get rid of old board.
	ZZTLoader.boardData.splice(delBoardNum, 1);
	zzt.globalProps["NUMBOARDS"] -= 1;

	// Reconcile board links.  This includes start board, edge links, and passage links.
	adjustBoardNum(zzt.globalProps, "STARTBOARD", delBoardNum);

	for (var i:int = 0; i < zzt.globalProps["NUMBOARDS"]; i++) {
		var bd:ZZTBoard = ZZTLoader.boardData[i];
		var bp:Object = bd.props;
		
		adjustBoardNum(bp, "EXITNORTH", delBoardNum);
		adjustBoardNum(bp, "EXITSOUTH", delBoardNum);
		adjustBoardNum(bp, "EXITEAST", delBoardNum);
		adjustBoardNum(bp, "EXITWEST", delBoardNum);

		for (var j:int = 0; j < bd.statElem.length; j++) {
			var se:SE = bd.statElem[j];
			if (zzt.typeList[se.TYPE].NUMBER == 11)
				adjustBoardNum(se.extra, "P3", delBoardNum);
		}
	}

	// Show current board.
	i = zzt.globalProps["BOARD"];
	ZZTLoader.updateContFromBoard(i, ZZTLoader.boardData[i]);
	SE.IsDark = 0;
	boardWidth = zzt.boardProps["SIZEX"];
	boardHeight = zzt.boardProps["SIZEY"];
	editorCursorX = 1;
	editorCursorY = 1;
	SE.CameraX = 1;
	SE.CameraY = 1;
	zzt.mainMode = zzt.MODE_SCROLLCLOSE;
	zzt.establishGui(zzt.prefEditorGui);
	updateEditorView(false);
	cursorActive = true;

	return true;
}

// Dispatch a world-editor menu message
public static function dispatchEditorMenu(msg:String, handleSpecGui:Boolean=true):void {
	if (handleSpecGui)
	{
		switch (zzt.thisGuiName) {
			case "ED_CHAREDIT":
				dispatchCharEditMenu(msg);
				return;
			case "ED_GRADIENT2":
				dispatchGradientMenu(msg);
				return;
			case "ED_TYPEALL":
				dispatchTypeAllMenu(msg);
				return;
			case "ED_F1":
				dispatchF1Menu(msg);
				return;
			case "ED_F2":
				dispatchF2Menu(msg);
				return;
			case "ED_F3":
				dispatchF3Menu(msg);
				return;
			case "ED_F4":
				dispatchF4Menu(msg);
				return;
			case "ED_F5":
				dispatchF5Menu(msg);
				return;
		}
	}

	var x:int;
	var y:int;
	var i:int;
	var relSE:SE;
	var rKey:String;
	var rObj:Array;
	switch (msg) {
		// High-level
		case "ED_SHOWULTRA1":
			zzt.establishGui("ED_ULTRA1");
			updateEditorView(true);
		break;
		case "ED_SHOWULTRA2":
			zzt.establishGui("ED_ULTRA2");
			updateEditorView(true);
		break;
		case "ED_SHOWULTRA3":
			zzt.establishGui("ED_ULTRA3");
			updateEditorView(true);
		break;
		case "ED_SHOWULTRA4":
			zzt.establishGui("ED_ULTRA4");
			updateEditorView(true);
		break;
		case "ED_SWAPED":
			if (++editorStyle > 3)
				editorStyle = 0;
			zzt.prefEditorGui = editorDefaultGuis[editorStyle];
			initEditor();
			zzt.establishGui(zzt.prefEditorGui);
			updateEditorView(true);
		break;
		case "ED_NEW":
			zzt.confMessage("CONFMESSAGE", " Make new world?    ",
				"ED_REALLYNEW", "ED_CANCEL", "ED_CANCEL");
		break;
		case "ED_REALLYNEW":
			newWorldSetup();
			updateEditorView(false);
			zzt.globalProps["BOARD"] = 0;
			modFlag = false;
		break;
		case "ED_CLEAR":
			zzt.confMessage("CONFMESSAGE", " Clear board?       ",
				"ED_REALLYCLEAR", "ED_CANCEL", "ED_CANCEL");
		break;
		case "ED_REALLYCLEAR":
			newBoardSetup();
			updateEditorView(false);
			modFlag = true;
		break;
		case "ED_LOAD":
			loadWorldScroll();
		break;
		case "ED_SAVE":
			quitAfterSave = false;
			saveWorldScroll();
		break;
		case "ED_HELP":
			showHelp();
		break;
		case "ED_HELPEDITOR":
			editedPropName = "";
			showCodeInterface(oldHlpStr);
		break;
		case "ED_QUIT":
			if (selBuffer.length > 0)
			{
				anchorX = -1;
				selBuffer = [];
				updateEditorView(false);
			}
			else if (drawFlag == DRAW_TEXT)
			{
				drawFlag = DRAW_OFF;
				drawEditorPatternCursor();
			}
			else if (modFlag)
				zzt.confMessage("CONFMESSAGE", " Save First?        ",
					"ED_SAVEANDQUIT", "ED_REALLYQUIT", "ED_CANCELQUIT");
			else
				dispatchEditorMenu("ED_REALLYQUIT");
		break;
		case "ED_REALLYQUIT":
			SE.vpWidth = 60;
			SE.vpX1 = 60;
			SE.vpHeight = 25;
			SE.vpY1 = 25;
			zzt.typeList[zzt.bEdgeType].CHAR = 32;
			zzt.typeList[zzt.invisibleType].CHAR = 0;
			zzt.mainMode = zzt.MODE_NORM;
			zzt.inEditor = false;
			hexTextEntry = 0;
			zzt.establishGui("DEBUGMENU");
			zzt.drawGui();
		break;
		case "ED_SAVEANDQUIT":
			quitAfterSave = true;
			saveWorldScroll();
		break;
		case "ED_TRANSFER":
			quitAfterSave = false;
			showTransferScroll();
			cursorActive = false;
		break;
		case "ED_RUN":
			/*if (modFlag)
			{
				showEditorScroll(
					["$You must save", "$before performing a quick run."],
					"Save needed", 0);
			}
			else
			{
				// TBD
				parse.loadingSuccess = true;
				set parse.fileData
			}*/
		break;
		case "ED_CHAREDIT":
			cursorActive = false;
			zzt.establishGui("ED_CHAREDIT");
			updateEditorView(true);
			showCharEditor(true);
		break;

		// Cancellation
		case "ED_CANCELQUIT":
			cursorActive = true;
			updateEditorView(true);
		break;
		case "ED_CANCELTYPE":
		case "ED_CANCELALLTYPE":
			cursorActive = true;
			zzt.establishGui(zzt.prefEditorGui);
			updateEditorView(true);
		break;
		case "ED_CANCELGRADIENT":
			selBuffer = [];
			anchorX = -1;
			cursorActive = true;
			zzt.establishGui(zzt.prefEditorGui);
			updateEditorView(false);
		break;

		// Info menus
		case "ED_WORLD":
			cursorActive = false;
			zzt.establishGui("ED_SCROLLEDIT");
			zzt.drawGui();
			showWorldInfo();
		break;
		case "ED_INFO":
			cursorActive = false;
			zzt.establishGui("ED_SCROLLEDIT");
			zzt.drawGui();
			showBoardInfo();
		break;
		case "ED_OBJEDIT":
			parse.loadLocalFile("ZZL", zzt.MODE_LOADZZL);
		break;
		case "ED_STATELEM":
			modFlag = true;
			cursorActive = false;
			zzt.establishGui("ED_STATEDIT");
			zzt.drawGui();
			showStatScroll();
		break;
		case "ED_TILEINFO":
			modFlag = true;
			cursorActive = false;
			SE.displaySquare(editorCursorX, editorCursorY);
			showTileScroll();
		break;
		case "ED_HIDDENOBJ":
			showHiddenObj();
		break;

		// Regions
		case "ED_REGION":
			if (anchorX != -1)
			{
				// Create new region at selection
				modFlag = true;
				editedPropName = "";
				zzt.drawGuiLabel("FILEMESSAGE", " New Region:        ");
				zzt.textEntry("FILEENTRY", "", 20, 15, "ED_NEWREGIONUPDATE", "ED_REGIONCANCEL");
			}
			else
			{
				editedPropName = "";
				for (rKey in zzt.regions) {
					rObj = zzt.regions[rKey];
					if (editorCursorX >= rObj[0][0] && editorCursorX <= rObj[1][0] &&
						editorCursorY >= rObj[0][1] && editorCursorY <= rObj[1][1])
					{
						// Edit existing region
						modFlag = true;
						editedPropName = rKey;
						zzt.drawGuiLabel("FILEMESSAGE", " Region Name:       ");
						zzt.textEntry("FILEENTRY", rKey, 20, 15, "ED_REGIONUPDATE", "ED_REGIONCANCEL");
						break;
					}
				}

				if (editedPropName == "")
				{
					// Show all region selections
					zzt.drawGuiLabel("FILEMESSAGE", " No Regions Defined ", 27);
					for (rKey in zzt.regions) {
						rObj = zzt.regions[rKey];
						zzt.mg.writeXorAttr(rObj[0][0] - SE.CameraX + SE.vpX0 - 1,
							rObj[0][1] - SE.CameraY + SE.vpY0 - 1,
							rObj[1][0] - rObj[0][0] + 1, rObj[1][1] - rObj[0][1] + 1, 127);
						zzt.drawGuiLabel("FILEMESSAGE", " Regions Shown      ", 27);
					}
				}
			}
		break;
		case "ED_NEWREGIONUPDATE":
			modFlag = true;
			if (zzt.textChars != "")
			{
				rObj = [
					[(anchorX < editorCursorX) ? anchorX : editorCursorX,
					(anchorY < editorCursorY) ? anchorY : editorCursorY],
					[(anchorX >= editorCursorX) ? anchorX : editorCursorX,
					(anchorY >= editorCursorY) ? anchorY : editorCursorY],
				];
				zzt.regions[zzt.textChars] = rObj;
			}

			selBuffer = [];
			anchorX = -1;
			updateEditorView(false);
		break;
		case "ED_REGIONUPDATE":
			modFlag = true;
			if (zzt.textChars == "")
				delete zzt.regions[editedPropName];
			else if (zzt.textChars != editedPropName)
			{
				zzt.regions[zzt.textChars] = zzt.regions[editedPropName];
				delete zzt.regions[editedPropName];
			}

			selBuffer = [];
			anchorX = -1;
			updateEditorView(false);
		break;
		case "ED_REGIONCANCEL":
			selBuffer = [];
			anchorX = -1;
			updateEditorView(false);
		break;

		// Board change
		case "ED_BOARD":
			cursorActive = false;
			zzt.establishGui("ED_DELEDIT");
			zzt.drawGui();
			boardSelectAction = BSA_SWITCHBOARD;
			showBoardScroll(zzt.globalProps["BOARD"]);
		break;
		case "ED_BOARDPREV":
			ZZTLoader.registerBoardState(true);
			i = zzt.globalProps["BOARD"] - 1;
			if (i < 0)
				i = zzt.globalProps["NUMBOARDS"] - 1;
			zzt.globalProps["BOARD"] = i;

			x = zzt.boardProps["SIZEX"];
			y = zzt.boardProps["SIZEY"];
			origCameraX = SE.CameraX;
			origCameraY = SE.CameraY;

			ZZTLoader.updateContFromBoard(i, ZZTLoader.boardData[i]);
			SE.IsDark = 0;
			boardWidth = zzt.boardProps["SIZEX"];
			boardHeight = zzt.boardProps["SIZEY"];
			if (boardWidth != x || boardHeight != y)
			{
				editorCursorX = 1;
				editorCursorY = 1;
				SE.CameraX = 1;
				SE.CameraY = 1;
			}

			clipCamera();
			updateEditorView(false);
		break;
		case "ED_BOARDNEXT":
			ZZTLoader.registerBoardState(true);
			i = zzt.globalProps["BOARD"] + 1;
			if (i >= zzt.globalProps["NUMBOARDS"])
				i = 0;
			zzt.globalProps["BOARD"] = i;

			x = zzt.boardProps["SIZEX"];
			y = zzt.boardProps["SIZEY"];
			origCameraX = SE.CameraX;
			origCameraY = SE.CameraY;
			ZZTLoader.updateContFromBoard(i, ZZTLoader.boardData[i]);
			SE.IsDark = 0;
			boardWidth = zzt.boardProps["SIZEX"];
			boardHeight = zzt.boardProps["SIZEY"];
			if (boardWidth != x || boardHeight != y)
			{
				editorCursorX = 1;
				editorCursorY = 1;
				SE.CameraX = 1;
				SE.CameraY = 1;
			}

			clipCamera();
			updateEditorView(false);
		break;

		// Movement and selection
		case "ED_LEFT":
			anchorX = -1;
			eraseEditorCursor();
			if (--editorCursorX <= 0)
				editorCursorX = boardWidth;
			spotPlace(true);
			drawEditorCursor();
		break;
		case "ED_RIGHT":
			anchorX = -1;
			eraseEditorCursor();
			if (++editorCursorX > boardWidth)
				editorCursorX = 1;
			spotPlace(true);
			drawEditorCursor();
		break;
		case "ED_UP":
			anchorX = -1;
			eraseEditorCursor();
			if (--editorCursorY <= 0)
				editorCursorY = boardHeight;
			spotPlace(true);
			drawEditorCursor();
		break;
		case "ED_DOWN":
			anchorX = -1;
			eraseEditorCursor();
			if (++editorCursorY > boardHeight)
				editorCursorY = 1;
			spotPlace(true);
			drawEditorCursor();
		break;
		case "ED_LEFTSUPER":
			anchorX = -1;
			eraseEditorCursor();
			editorCursorX -= 10;
			if (editorCursorX <= 0)
				editorCursorX = 1;
			spotPlace(true);
			drawEditorCursor();
		break;
		case "ED_RIGHTSUPER":
			anchorX = -1;
			eraseEditorCursor();
			editorCursorX += 10;
			if (editorCursorX > boardWidth)
				editorCursorX = boardWidth;
			spotPlace(true);
			drawEditorCursor();
		break;
		case "ED_UPSUPER":
			anchorX = -1;
			eraseEditorCursor();
			editorCursorY -= 10;
			if (editorCursorY <= 0)
				editorCursorY = 1;
			spotPlace(true);
			drawEditorCursor();
		break;
		case "ED_DOWNSUPER":
			anchorX = -1;
			eraseEditorCursor();
			editorCursorY += 10;
			if (editorCursorY > boardHeight)
				editorCursorY = boardHeight;
			spotPlace(true);
			drawEditorCursor();
		break;
		case "ED_SELLEFT":
			if (anchorX == -1)
			{
				anchorX = editorCursorX;
				anchorY = editorCursorY;
			}
			else
				removeRectSel();

			eraseEditorCursor();
			if (--editorCursorX <= 0)
				editorCursorX = boardWidth;
			addToRectSel();
		break;
		case "ED_SELRIGHT":
			if (anchorX == -1)
			{
				anchorX = editorCursorX;
				anchorY = editorCursorY;
			}
			else
				removeRectSel();

			eraseEditorCursor();
			if (++editorCursorX > boardWidth)
				editorCursorX = 1;
			addToRectSel();
		break;
		case "ED_SELUP":
			if (anchorX == -1)
			{
				anchorX = editorCursorX;
				anchorY = editorCursorY;
			}
			else
				removeRectSel();

			eraseEditorCursor();
			if (--editorCursorY <= 0)
				editorCursorY = boardHeight;
			addToRectSel();
		break;
		case "ED_SELDOWN":
			if (anchorX == -1)
			{
				anchorX = editorCursorX;
				anchorY = editorCursorY;
			}
			else
				removeRectSel();

			eraseEditorCursor();
			if (++editorCursorY > boardHeight)
				editorCursorY = 1;
			addToRectSel();
		break;

		// Mode change
		case "ED_DRAWING":
			hexTextEntry = 0;
			if (drawFlag == DRAW_OFF)
			{
				drawFlag = DRAW_ON;
				spotPlace(true);
			}
			else
				drawFlag = DRAW_OFF;

			drawEditorPatternCursor();
		break;
		case "ED_DRAWINGCYCLE":
			hexTextEntry = 0;
			if (drawFlag == DRAW_ACQBACK)
				drawFlag = DRAW_ACQFORWARD;
			else
				drawFlag = DRAW_ACQBACK;

			spotPlace(true);
			drawEditorPatternCursor();
		break;
		case "ED_TEXT":
			hexTextEntry = 0;
			if (drawFlag == DRAW_TEXT)
				drawFlag = DRAW_OFF;
			else
				drawFlag = DRAW_TEXT;

			drawEditorPatternCursor();
		break;
		case "ED_ACQUIRE":
			acquireMode = !acquireMode;
			drawEditorPatternCursor();
		break;
		case "ED_BLINK":
			blinkFlag = !blinkFlag;
			drawEditorPatternCursor();
		break;
		case "ED_DEFAULTCOLOR":
			defColorMode = !defColorMode;
			drawEditorPatternCursor();
		break;
		case "ED_AESTHETIC":
			// TBD
		break;

		// Spot editing
		case "ED_PLACE":
			spotPlace(false);
		break;
		case "ED_DELETE":
			modFlag = true;
			killSE(editorCursorX, editorCursorY);
			SE.setType(editorCursorX, editorCursorY, 0);
			SE.setColor(editorCursorX, editorCursorY, 15, false);
			SE.displaySquare(editorCursorX, editorCursorY);
		break;
		case "ED_PICKUP":
			pickupCursor();
			updateEditorView(true);
			if (immType[3] != null)
			{
				modFlag = true;
				zzt.establishGui("ED_STATEDIT");
				zzt.drawGui();
				editStatElem();
				drawEditorPatternCursor();
				drawEditorColorCursors();
			}
		break;
		case "ED_PICKUPNOEDIT":
			pickupCursor();
			updateEditorView(true);
		break;

		// Color/pattern selection
		case "ED_PATTERN":
			if (patternCursor == -1)
			{
				if (++patternBBCursor >= actualBBLen)
				{
					patternBBCursor = 0;
					patternCursor = 0;
				}
			}
			else
			{
				if (++patternCursor >= patternBuiltIn)
				{
					patternCursor = -1;
					patternBBCursor = 0;
				}
			}

			drawEditorPatternCursor();
		break;
		case "ED_REVPATTERN":
			if (patternCursor == -1)
			{
				if (--patternBBCursor < 0)
				{
					patternBBCursor = 0;
					patternCursor = patternBuiltIn - 1;
				}
			}
			else
			{
				if (--patternCursor < 0)
				{
					patternCursor = -1;
					patternBBCursor = actualBBLen - 1;
				}
			}

			drawEditorPatternCursor();
		break;
		case "ED_COLOR":
			switch (editorStyle) {
				case EDSTYLE_ULTRA:
				case EDSTYLE_KEVEDIT:
				case EDSTYLE_SUPERZZT:
					if (++fgColorCursor >= 16)
						fgColorCursor = 0;
				break;
				case EDSTYLE_CLASSIC:
					if (++fgColorCursor >= 16)
						fgColorCursor = 9;
				break;
			}

			drawEditorColorCursors();
		break;
		case "ED_COLOR2":
			switch (editorStyle) {
				case EDSTYLE_ULTRA:
				case EDSTYLE_KEVEDIT:
				case EDSTYLE_SUPERZZT:
					if (++bgColorCursor >= 8)
						bgColorCursor = 0;
				break;
				case EDSTYLE_CLASSIC:
					if (--fgColorCursor < 9)
						fgColorCursor = 15;
				break;
			}

			drawEditorColorCursors();
		break;
		case "ED_SWITCHCOLOR":
			fgColorCursor = fgColorCursor ^ 8;
			drawEditorColorCursors();
		break;
		case "ED_KOLOR":
			oldFgColorCursor = fgColorCursor;
			oldBgColorCursor = bgColorCursor;
			cursorActive = false;
			zzt.mainMode = zzt.MODE_COLORSEL;
			zzt.establishGui("ED_COLORS");
			for (y = 1; y <= 8; y++) {
				zzt.GuiTextLines[y] = String.fromCharCode(179);
				for (x = 1; x <= 32; x++) {
					zzt.GuiTextLines[y] += String.fromCharCode(254);
				}
				zzt.GuiTextLines[y] += String.fromCharCode(179);
			}
			zzt.drawGui();
			drawKolorCursor(true);
		break;
		case "ED_BIT7TOGGLE":
			zzt.globalProps["BIT7ATTR"] = CellGrid.blinkBitUsed ? 0 : 1;
			zzt.mg.updateBit7Meaning(zzt.globalProps["BIT7ATTR"]);
		break;
		case "ED_TEXTSPECCHAR":
			selectCharDialog();
		break;

		case "ED_HEXTEXT":
			hexTextEntry = 1;
			drawEditorPatternCursor();
		break;
		case "ED_COLORCANCEL":
			fgColorCursor = oldFgColorCursor;
			bgColorCursor = oldBgColorCursor;
		case "ED_COLORSEL":
			if (scrollMode == SM_STATINFO)
			{
				SE.setColor(editorCursorX, editorCursorY,
					fgColorCursor + (bgColorCursor * 16) + (blinkFlag ? 128 : 0), false);
				showTileScroll();
			}
			else if (scrollMode == SM_UNDERCOLOR)
			{
				relSE = SE.getStatElemAt(editorCursorX, editorCursorY);
				relSE.UNDERCOLOR = fgColorCursor + (bgColorCursor * 16) + (blinkFlag ? 128 : 0);
				showTileScroll();
			}
			else if (scrollMode == SM_GUITEXT)
			{
				zzt.inEditor = false;
				zzt.establishGui("EDITGUITEXT");
				zzt.mg.writeConst(0, 0, zzt.CHARS_WIDTH, zzt.CHARS_HEIGHT, " ", 31);
				zzt.drawGui();
				writeColorCursors();
				writeGuiTextEdit();
				writeGuiTextEditLabels();
				zzt.mainMode = zzt.MODE_NORM;
				scrollMode = 0;
			}
			else
			{
				cursorActive = true;
				zzt.establishGui(zzt.prefEditorGui);
				updateEditorView(false);
				zzt.mainMode = zzt.MODE_NORM;
			}
		break;
		case "ED_CHARSEL":
			if (editedPropName == "CHAR")
			{
				relSE = immType[3];
				relSE.extra["CHAR"] = hexCodeValue;
				immType[0] = hexCodeValue;
				spotPlace(false, true);
				add2BBuffer(false);

				zzt.establishGui("ED_STATEDIT");
				updateEditorView(false);
				zzt.drawGui();
				editStatElem();
				drawEditorPatternCursor();
				drawEditorColorCursors();
				break;
			}

			writeTextDrawChar(hexCodeValue);
		case "ED_CHARCANCEL":
			cursorActive = true;
			zzt.establishGui(zzt.prefEditorGui);
			updateEditorView(false);
			zzt.mainMode = zzt.MODE_NORM;
		break;

		// Back buffer
		case "ED_BUF1":
			setCustomPatternCursorPos(0);
		break;
		case "ED_BUF2":
			setCustomPatternCursorPos(1);
		break;
		case "ED_BUF3":
			setCustomPatternCursorPos(2);
		break;
		case "ED_BUF4":
			setCustomPatternCursorPos(3);
		break;
		case "ED_BUF5":
			setCustomPatternCursorPos(4);
		break;
		case "ED_BUF6":
			setCustomPatternCursorPos(5);
		break;
		case "ED_BUF7":
			setCustomPatternCursorPos(6);
		break;
		case "ED_BUF8":
			setCustomPatternCursorPos(7);
		break;
		case "ED_BUF9":
			setCustomPatternCursorPos(8);
		break;
		case "ED_BUFINC":
			if (++actualBBLen > MAX_BBUFFER)
				actualBBLen = MAX_BBUFFER;

			drawEditorPatternCursor();
		break;
		case "ED_BUFDEC":
			if (--actualBBLen < 1)
				actualBBLen = 1;

			drawEditorPatternCursor();
		break;
		case "ED_BUFLOCK":
			bufLockMode = !bufLockMode;
			drawEditorPatternCursor();
		break;
		case "ED_BUFEMPTY":
			switch (editorStyle) {
				case EDSTYLE_ULTRA:
				case EDSTYLE_KEVEDIT:
					patternCursor = 4;
				break;
				case EDSTYLE_CLASSIC:
				case EDSTYLE_SUPERZZT:
					patternCursor = 3;
				break;
			}

			drawEditorPatternCursor();
		break;

		// Type menus
		case "ED_ITEM":
			cursorActive = false;
			zzt.establishGui("ED_F1");
			updateEditorView(true);
		break;
		case "ED_CREATURE":
			cursorActive = false;
			zzt.establishGui("ED_F2");
			updateEditorView(true);
			zzt.drawGuiLabel("BEARCHAR",
				String.fromCharCode(zzt.typeList[zzt.bearType].CHAR),
				zzt.typeList[zzt.bearType].COLOR);
		break;
		case "ED_TERRAIN":
			cursorActive = false;
			zzt.establishGui("ED_F3");
			updateEditorView(true);
			zzt.drawGuiLabel("WATERLAVA",
				(editorStyle == EDSTYLE_SUPERZZT) ? "Lava " : "Water", 31);
			zzt.drawGuiLabel("WATERLAVACHAR",
				String.fromCharCode(zzt.typeList[interp.typeTrans[19]].CHAR),
				zzt.typeList[interp.typeTrans[19]].COLOR);
		break;
		case "ED_UGLIES":
			cursorActive = false;
			zzt.establishGui("ED_F4");
			updateEditorView(true);
		break;
		case "ED_TERRAIN2":
			cursorActive = false;
			zzt.establishGui("ED_F5");
			updateEditorView(true);
		break;
		case "ED_FLOOR":
			cursorActive = false;
			typeAllFilter = TYPEFILTER_FLOOR;
			zzt.establishGui("ED_TYPEALL");
			updateEditorView(true);
			updateTypeAllView(true);
		break;
		case "ED_BLOCKING":
			cursorActive = false;
			typeAllFilter = TYPEFILTER_BLOCKING;
			zzt.establishGui("ED_TYPEALL");
			updateEditorView(true);
			updateTypeAllView(true);
		break;
		case "ED_STATTYPES":
			cursorActive = false;
			typeAllFilter = TYPEFILTER_STATTYPES;
			zzt.establishGui("ED_TYPEALL");
			updateEditorView(true);
			updateTypeAllView(true);
		break;

		// Copy and paste
		case "ED_CUT":
			captureSel(true);
		break;
		case "ED_COPY":
			captureSel(false);
		break;
		case "ED_PASTE":
			if (clipBuffer.length > 0)
			{
				editorCursorX = clipX1;
				editorCursorY = clipY1;
				zzt.establishGui("ED_PASTE");
				updatePasteView();
			}
		break;
		case "ED_REALLYPASTE":
			pasteSel();
			zzt.establishGui(zzt.prefEditorGui);
			updateEditorView(false);
		break;
		case "ED_CANCELPASTE":
			selBuffer = [];
			zzt.establishGui(zzt.prefEditorGui);
			updateEditorView(false);
		break;
		case "ED_PASTESELLEFT":
			if (--editorCursorX <= 0)
				editorCursorX = boardWidth;
			updatePasteView();
		break;
		case "ED_PASTESELRIGHT":
			if (++editorCursorX > boardWidth)
				editorCursorX = 1;
			updatePasteView();
		break;
		case "ED_PASTESELUP":
			if (--editorCursorY <= 0)
				editorCursorY = boardHeight;
			updatePasteView();
		break;
		case "ED_PASTESELDOWN":
			if (++editorCursorY > boardHeight)
				editorCursorY = 1;
			updatePasteView();
		break;

		// Fill operations
		case "ED_RANDOMFILL":
			if (selBuffer.length > 0)
				fillAction(FILL_RANDOMPAINT);
			else
				floodFill(editorCursorX, editorCursorY, FILL_RANDOMPAINT);
		break;
		case "ED_FILL":
			if (selBuffer.length > 0)
				fillAction(FILL_PAINT);
			else
				floodFill(editorCursorX, editorCursorY, FILL_PAINT);
		break;
		case "ED_FLOODSEL":
			if (selBuffer.length > 0 && zzt.thisGuiName != "ED_GRADIENT")
				fillAction(FILL_SELECTION);
			else
				floodFill(editorCursorX, editorCursorY, FILL_SELECTION);
		break;
		case "ED_SELSIMILAR":
			pickerSel(editorCursorX, editorCursorY);
		break;
		case "ED_GRADIENT":
			if (selBuffer.length > 0)
				dispatchGradientMenu("ED_GRADIENT2");
			else
			{
				zzt.establishGui("ED_GRADIENT");
				updateEditorView(true);
			}
		break;
		case "ED_GRADIENT2":
			dispatchGradientMenu("ED_GRADIENT2");
		break;

		// Miscellaneous
		case "ED_STATVALUPDATE":
			modFlag = true;
			zzt.drawGuiLabel("FILEMESSAGE", "                    ", 31);
			zzt.drawGuiLabel("FILEENTRY", "                    ", 31);
			updateStatVal();
		break;
		case "ED_STATVALCANCEL":
			zzt.drawGuiLabel("FILEMESSAGE", "                    ", 31);
			zzt.drawGuiLabel("FILEENTRY", "                    ", 31);
			updateStatTypeInScroll();
		break;
		case "ED_BOARDPROPUPDATE":
			modFlag = true;
			zzt.drawGuiLabel("FILEMESSAGE", "                    ", 31);
			zzt.drawGuiLabel("FILEENTRY", "                    ", 31);
			updateBoardProp();
		break;
		case "ED_BOARDPROPCANCEL":
			zzt.drawGuiLabel("FILEMESSAGE", "                    ", 31);
			zzt.drawGuiLabel("FILEENTRY", "                    ", 31);
			updateBoardProp();
		break;
		case "ED_WORLDPROPUPDATE":
			modFlag = true;
			zzt.drawGuiLabel("FILEMESSAGE", "                    ", 31);
			zzt.drawGuiLabel("FILEENTRY", "                    ", 31);
			updateWorldProp();
		break;
		case "ED_WORLDPROPCANCEL":
			zzt.drawGuiLabel("FILEMESSAGE", "                    ", 31);
			zzt.drawGuiLabel("FILEENTRY", "                    ", 31);
			updateWorldProp();
		break;
		case "ED_GLOBALSUPDATE":
			modFlag = true;
			zzt.drawGuiLabel("FILEMESSAGE", "                    ", 31);
			zzt.drawGuiLabel("FILEENTRY", "                    ", 31);
			updateGlobals();
		break;
		case "ED_GLOBALSCANCEL":
			zzt.drawGuiLabel("FILEMESSAGE", "                    ", 31);
			zzt.drawGuiLabel("FILEENTRY", "                    ", 31);
			updateGlobals();
		break;
		case "ED_ACCEPTEDITORPROP":
			parseJSONProps();
		break;
	}
}

// Upload character-edit binary file
public static function uploadCharEditFile():void {
	var ba:ByteArray = parse.fileData;
	if (ba != null)
	{
		var arr:Array = interp.getFlatSequence(ba, true);
		ceCharCount = int(arr.length / (ceCharHeight * 8));
		ceCharNum = 0;
		if (ceCharCount > 256)
			ceCharCount = 256;

		zzt.csg.updateCharacterSet(ceCharWidth, ceCharHeight, 1, ceCharCount, 0, arr);
		zzt.cpg.updateCharacterSet(ceCharWidth, ceCharHeight, 1, ceCharCount, 0, arr);
		showCharEditor(true);
	}
}

// Dispatch character-editor menu message
public static function dispatchCharEditMenu(msg:String):void {
	var x:int;
	var y:int;
	var c:int = ceMaskArray[ceCharY * ceCharWidth + ceCharX];
	var a:Array;

	switch (msg) {
		case "CE_EXIT":
			zzt.cpg.visible = false;
			zzt.csg.visible = false;
			cursorActive = true;
			anchorX = -1;
			zzt.establishGui(zzt.prefEditorGui);
			updateEditorView(false);
		break;
		case "CE_LOAD":
			showEditorScroll(
				["!CE_LOADMASK;Mask or Lump", "!CE_LOADFILE;Binary File"],
				"Choose Character Set Source", SM_CHAREDITLOAD);
		break;
		case "CE_LOADMASKYES":
			handleClosedEditorScroll();
			a = interp.getFlatSequence(zzt.textChars, true);
			if (a != null)
			{
				ceCharNum = 0;
				ceCharCount = int(a.length / (8 * ceCharHeight));
				if (ceCharCount > 256)
					ceCharCount = 256;

				zzt.csg.updateCharacterSet(ceCharWidth, ceCharHeight, 1, ceCharCount, 0, a);
				zzt.cpg.updateCharacterSet(ceCharWidth, ceCharHeight, 1, ceCharCount, 0, a);
				showCharEditor(true);
			}
		break;
		case "CE_SAVE":
			ceStorage = [];
			for (c = 0; c < ceCharCount; c++) {
				a = zzt.csg.getCurrentCharacterMask(c, 8);
				for (y = 0; y < a.length; y++)
					ceStorage.push(a[y]);
			}

			showEditorScroll(
				["!CE_SAVEMASK;To Mask", "!CE_SAVELUMP;To Lump", "!CE_SAVEFILE;To Binary File"],
				"Choose Save Destination", SM_CHAREDITSAVE);
		break;
		case "CE_SAVELUMPYES":
			handleClosedEditorScroll();
			parse.lastFileName = zzt.textChars;
			parse.fileData = interp.makeBitSequence(interp.getFlatSequence(ceStorage));
			uploadExtraLump(false);
		break;
		case "CE_SAVEMASKYES":
			handleClosedEditorScroll();
			ZZTLoader.extraMasks[zzt.textChars] = ceStorage;
		break;
		case "CE_LOADSAVECANCEL":
			handleClosedEditorScroll();
		break;
		case "CE_APPLY":
			a = [];
			for (y = 0; y < ceCharCount; y++) {
				a.push(zzt.csg.getCurrentCharacterMask(y));
			}

			zzt.mg.updateScanlineMode(ceCharHeightMode);
			zzt.mg.updateCharacterSet(ceCharWidth, ceCharHeight, 1, ceCharCount, 0,
				interp.getFlatSequence(a));
			zzt.mg.createSurfaces(
				zzt.OverallSizeX, zzt.OverallSizeY, zzt.Viewport, true);
			zzt.cellYDiv = zzt.mg.virtualCellYDiv;
		break;
		case "CE_RESET":
			zzt.confMessage("CONFMESSAGE", "Reset to default?",
				"CE_REALLYRESET", "CE_CANCEL", "CE_CANCEL");
		break;
		case "CE_REALLYRESET":
			zzt.cpg.updateScanlineMode(ceCharHeightMode);
			zzt.csg.updateScanlineMode(ceCharHeightMode);
			ceCharCount = 256;
			ceCharNum = 0;
			ceCharX = 0;
			ceCharY = 0;
			showCharEditor(true);
			dispatchCharEditMenu("CE_CLEAR");
		break;
		case "CE_CANCEL":
		break;
		case "CE_STARTMOUSEDRAW":
			ceCharMouseMode = (c != 0) ? 0 : 1;
			// Intentional fallthrough
		case "CE_CONTINUEMOUSEDRAW":
			ceMaskArray[ceCharY * ceCharWidth + ceCharX] = ceCharMouseMode;
			updateCharFromMaskArray();
		break;
		case "CE_TOGGLEBIT":
			ceMaskArray[ceCharY * ceCharWidth + ceCharX] = (c != 0) ? 0 : 1;
			updateCharFromMaskArray();
		break;
		case "CE_DRAWMODEBIT":
			if (ceCharDrawMode != 0)
			{
				ceMaskArray[ceCharY * ceCharWidth + ceCharX] = ceCharDrawMode - 1;
				updateCharFromMaskArray();
			}
		break;
		case "CE_DRAWINGMODE":
			if (ceCharDrawMode == 0)
			{
				ceCharDrawMode = (c != 0) ? 1 : 2;
				zzt.drawGuiLabel("CONFMESSAGE",
					"Draw Mode:  " + ((ceCharDrawMode == 1) ? "CLEAR" : "SET  ").toString());
				dispatchCharEditMenu("CE_TOGGLEBIT");
			}
			else
			{
				ceCharDrawMode = 0;
				zzt.drawGuiLabel("CONFMESSAGE", "Draw Mode:  " + "Off  ");
			}
		break;
		case "CE_COUNT":
			modFlag = true;
			editedPropName = "";
			zzt.textEntry("COUNTENTRY", ceCharCount.toString(), 3, 15,
				"CE_COUNTSET", "CE_CANCEL");
		break;
		case "CE_COUNTSET":
			if (zzt.textChars != "")
			{
				ceCharCount = utils.int0(zzt.textChars);
				if (ceCharCount <= 0 || ceCharCount > 256)
					ceCharCount = 256;
			}
			showCharEditor();
		break;
		case "CE_HEIGHT":
			ceStorage = [];
			for (c = 0; c < 256; c++) {
				a = zzt.csg.getCurrentCharacterMask(c);
				for (y = 0; y < a.length; y++)
					ceStorage.push(a[y]);
			}
			savedCEStorage[ceCharHeightMode] = ceStorage;

			if (++ceCharHeightMode > 2)
				ceCharHeightMode = 0;
			switch (ceCharHeightMode) {
				case 0:
					ceCharHeight = 8;
				break;
				case 1:
					ceCharHeight = 14;
				break;
				case 2:
					ceCharHeight = 16;
				break;
			}

			zzt.cpg.updateScanlineMode(ceCharHeightMode);
			zzt.csg.updateScanlineMode(ceCharHeightMode);
			if (savedCEStorage[ceCharHeightMode] != null)
			{
				zzt.cpg.updateCharacterSet(ceCharWidth, ceCharHeight, 1, 256, 0,
					savedCEStorage[ceCharHeightMode]);
				zzt.csg.updateCharacterSet(ceCharWidth, ceCharHeight, 1, 256, 0,
					savedCEStorage[ceCharHeightMode]);
			}

			ceCharNum = 0;
			ceCharX = 0;
			ceCharY = 0;
			showCharEditor(true);
			dispatchCharEditMenu("CE_CLEAR");
		break;
		case "CE_ROTATELEFT":
			for (y = 0; y < ceCharHeight; y++) {
				c = ceMaskArray[y * ceCharWidth + 0];
				for (x = 1; x < ceCharWidth; x++) {
					ceMaskArray[y * ceCharWidth + x - 1] = ceMaskArray[y * ceCharWidth + x];
				}
				ceMaskArray[y * ceCharWidth + (ceCharWidth - 1)] = c;
			}
			updateCharFromMaskArray();
		break;
		case "CE_ROTATERIGHT":
			for (y = 0; y < ceCharHeight; y++) {
				c = ceMaskArray[y * ceCharWidth + (ceCharWidth - 1)];
				for (x = ceCharWidth - 2; x >= 0; x--) {
					ceMaskArray[y * ceCharWidth + x + 1] = ceMaskArray[y * ceCharWidth + x];
				}
				ceMaskArray[y * ceCharWidth + 0] = c;
			}
			updateCharFromMaskArray();
		break;
		case "CE_ROTATEUP":
			for (x = 0; x < ceCharWidth; x++) {
				c = ceMaskArray[(0) * ceCharWidth + x];
				for (y = 1; y < ceCharHeight; y++) {
					ceMaskArray[(y - 1) * ceCharWidth + x] = ceMaskArray[y * ceCharWidth + x];
				}
				ceMaskArray[(ceCharHeight - 1) * ceCharWidth + x] = c;
			}
			updateCharFromMaskArray();
		break;
		case "CE_ROTATEDOWN":
			for (x = 0; x < ceCharWidth; x++) {
				c = ceMaskArray[(ceCharHeight - 1) * ceCharWidth + x];
				for (y = ceCharHeight - 2; y >= 0; y--) {
					ceMaskArray[(y + 1) * ceCharWidth + x] = ceMaskArray[y * ceCharWidth + x];
				}
				ceMaskArray[(0) * ceCharWidth + x] = c;
			}
			updateCharFromMaskArray();
		break;
		case "CE_LEFT":
			if (--ceCharX < 0)
				ceCharX = ceCharWidth - 1;
			dispatchCharEditMenu("CE_DRAWMODEBIT");
			showCharEditor();
		break;
		case "CE_RIGHT":
			if (++ceCharX >= ceCharWidth)
				ceCharX = 0;
			dispatchCharEditMenu("CE_DRAWMODEBIT");
			showCharEditor();
		break;
		case "CE_UP":
			if (--ceCharY < 0)
				ceCharY = ceCharHeight - 1;
			dispatchCharEditMenu("CE_DRAWMODEBIT");
			showCharEditor();
		break;
		case "CE_DOWN":
			if (++ceCharY >= ceCharHeight)
				ceCharY = 0;
			dispatchCharEditMenu("CE_DRAWMODEBIT");
			showCharEditor();
		break;
		case "CE_CLEAR":
			for (y = 0; y < ceCharHeight; y++) {
				for (x = 0; x < ceCharWidth; x++) {
					ceMaskArray[y * ceCharWidth + x] = 0;
				}
			}
			updateCharFromMaskArray();
		break;
		case "CE_NEXTCHAR":
			selectCharFromSet((ceCharNum + 1) & 255);
		break;
		case "CE_PREVCHAR":
			selectCharFromSet((ceCharNum - 1) & 255);
		break;
		case "CE_COPY":
			for (y = 0; y < ceCharHeight; y++) {
				for (x = 0; x < ceCharWidth; x++) {
					ceMaskCBArray[y * ceCharWidth + x] = ceMaskArray[y * ceCharWidth + x];
				}
			}
			updateCharFromMaskArray();
		break;
		case "CE_PASTE":
			for (y = 0; y < ceCharHeight; y++) {
				for (x = 0; x < ceCharWidth; x++) {
					ceMaskArray[y * ceCharWidth + x] = ceMaskCBArray[y * ceCharWidth + x];
				}
			}
			updateCharFromMaskArray();
		break;
		case "CE_MIRRORHORIZ":
			for (y = 0; y < ceCharHeight; y++) {
				for (x = 0; x < ceCharWidth / 2; x++) {
					c = ceMaskArray[y * ceCharWidth + x];
					ceMaskArray[y * ceCharWidth + x] =
						ceMaskArray[y * ceCharWidth + (ceCharWidth - 1 - x)];
					ceMaskArray[y * ceCharWidth + (ceCharWidth - 1 - x)] = c;
				}
			}
			updateCharFromMaskArray();
		break;
		case "CE_MIRRORVERT":
			for (y = 0; y < ceCharHeight / 2; y++) {
				for (x = 0; x < ceCharWidth; x++) {
					c = ceMaskArray[y * ceCharWidth + x];
					ceMaskArray[y * ceCharWidth + x] =
						ceMaskArray[(ceCharHeight - 1 - y) * ceCharWidth + x];
					ceMaskArray[(ceCharHeight - 1 - y) * ceCharWidth + x] = c;
				}
			}
			updateCharFromMaskArray();
		break;
		case "CE_NEGATE":
			for (y = 0; y < ceCharHeight; y++) {
				for (x = 0; x < ceCharWidth; x++) {
					c = ceMaskArray[y * ceCharWidth + x];
					ceMaskArray[y * ceCharWidth + x] = (c != 0) ? 0 : 1;
				}
			}
			updateCharFromMaskArray();
		break;
	}
}

// Copy selected character to preview slot.
public static function selectCharFromSet(cNum:int):void {
	ceCharNum = cNum;
	if (cePreviewIdent)
	{
		// Update all characters.
		for (var cy:int = 0; cy < 3; cy++) {
			for (var cx:int = 0; cx < 3; cx++) {
				cePreviewChars[cy * 3 + cx] = ceCharNum;
			}
		}

		cePreviewIdent = false;
	}
	else
	{
		// Update only center character.
		cePreviewChars[1 * 3 + 1] = ceCharNum;
	}

	// After new character is picked, update mask with new character.
	ceMaskArray = zzt.csg.getCurrentCharacterMask(ceCharNum);
	showCharEditor();
}

// Copy selected character to preview slot.
public static function setCharEditPreview(x:int, y:int):void {
	if (x == 1 && y == 1)
	{
		// Not much to do here; equivalent to selecting identical bounds in preview.
		cePreviewIdent = true;
		selectCharFromSet(ceCharNum);
	}
	else
	{
		// Identical bounds in preview are turned off.
		cePreviewIdent = false;
		cePreviewChars[y * 3 + x] = ceCharNum;
		showCharEditor();
	}
}

// After character mask was changed, update character
public static function updateCharFromMaskArray():void {
	zzt.csg.updateCharacterSet(ceCharWidth, ceCharHeight, 1, 1, ceCharNum, ceMaskArray);
	zzt.cpg.updateCharacterSet(ceCharWidth, ceCharHeight, 1, 1, ceCharNum, ceMaskArray);
	showCharEditor();
}

// Display character editor interface.
public static function showCharEditor(fullUpdate:Boolean=false):void {
	// Show preview and character cell grids
	if (fullUpdate)
	{
		zzt.cpg.visible = true;
		zzt.csg.visible = true;

		if (!charEditorInit)
		{
			// First-time initialization:  create arrays.
			ceMaskArray = new Array(16 * 8);
			ceMaskCBArray = new Array(16 * 8);
			for (var n:int = 0; n < 16 * 8; n++) {
				ceMaskArray[n] = 0;
				ceMaskCBArray[n] = 0;
			}

			cePreviewChars = new Array(9);
			for (n = 0; n < 9; n++)
				cePreviewChars[n] = 0;

			for (n = 0; n < 256; n++)
				zzt.csg.setCell(n % 32, int(n / 32), n, 15);

			ceCharWidth = zzt.mg.charWidth;
			ceCharHeight = zzt.mg.charHeight;
			ceCharHeightMode = zzt.mg.charHeightMode;
			ceCharCount = 256;
			ceCharNum = 0;
			ceCharX = 0;
			ceCharY = 0;
			cePreviewIdent = false;
			charEditorInit = true;
		}

		// Set up preview grid info
		if (zzt.cpg.charHeightMode != ceCharHeightMode)
			zzt.cpg.updateScanlineMode(ceCharHeightMode);
		zzt.cpg.adjustVisiblePortion(3, 3);

		// Set up character selection grid update
		if (zzt.csg.charHeightMode != ceCharHeightMode)
			zzt.csg.updateScanlineMode(ceCharHeightMode);
		zzt.csg.adjustVisiblePortion(32, 8);
	}

	// Number labels
	zzt.eraseGuiLabel("HEIGHTLABEL");
	zzt.drawGuiLabel("HEIGHTLABEL", ceCharHeight.toString());
	zzt.eraseGuiLabel("COUNTLABEL");
	zzt.drawGuiLabel("COUNTLABEL", ceCharCount.toString());
	zzt.eraseGuiLabel("CHARCODELABEL");
	zzt.drawGuiLabel("CHARCODELABEL", ceCharNum.toString());

	// Preview grid update
	for (n = 0; n < 9; n++)
		zzt.cpg.setCell(n % 3, int(n / 3), cePreviewChars[n], 15);
	zzt.cpg.drawSurfaces();

	// Character selection grid update
	zzt.csg.setCell(ceCharNum % 32, int(ceCharNum / 32), ceCharNum, 15);
	zzt.csg.drawSurfaces();

	// Bit grid update
	var bgX:int = zzt.GuiLabels["BITGRID"][0] - 1;
	var bgY:int = zzt.GuiLabels["BITGRID"][1] - 1;
	for (var y:int = 0; y < 16; y++) {
		for (var x:int = 0; x < ceCharWidth; x++) {

			var colorXor:int = (x == ceCharX && y == ceCharY) ? 4 : 0;
			var c:int = ceMaskArray[y * ceCharWidth + x];
			if (y >= ceCharHeight)
			{
				zzt.mg.setCell(bgX + (x * 2), bgY + y, 32, 31);
				zzt.mg.setCell(bgX + (x * 2) + 1, bgY + y, 32, 31);
			}
			else if (c != 0)
			{
				zzt.mg.setCell(bgX + (x * 2), bgY + y, 219, 15 ^ colorXor);
				zzt.mg.setCell(bgX + (x * 2) + 1, bgY + y, 219, 15 ^ colorXor);
			}
			else
			{
				zzt.mg.setCell(bgX + (x * 2), bgY + y, 46, 8 ^ colorXor);
				zzt.mg.setCell(bgX + (x * 2) + 1, bgY + y, 46, 8 ^ colorXor);
			}
		}
	}
}

// Dispatch gradient-menu message
public static function dispatchGradientMenu(msg:String):void {
	var i:int;
	var x:int;
	var y:int;
	switch (msg) {
		case "ED_GRADIENT2":
			if (selBuffer.length != 0)
			{
				gradBuffer = [];
				for (i = 0; i < selBuffer.length; i++)
					gradBuffer.push(new IPoint(selBuffer[i].x, selBuffer[i].y));
				selBuffer = [];

				invertGPts = false;
				gradientShape = GRAD_LINEAR;
				gradientDither = 0.0;
				anchorX = editorCursorX;
				anchorY = editorCursorY;
				zzt.establishGui("ED_GRADIENT2");
				updateGradientView();
			}
		break;
		case "ED_GRADPTLEFT":
			eraseEditorCursor();
			if (--editorCursorX <= 0)
				editorCursorX = boardWidth;
			updateGradientView();
		break;
		case "ED_GRADPTRIGHT":
			eraseEditorCursor();
			if (++editorCursorX > boardWidth)
				editorCursorX = 1;
			updateGradientView();
		break;
		case "ED_GRADPTUP":
			eraseEditorCursor();
			if (--editorCursorY <= 0)
				editorCursorY = boardHeight;
			updateGradientView();
		break;
		case "ED_GRADPTDOWN":
			eraseEditorCursor();
			if (++editorCursorY > boardHeight)
				editorCursorY = 1;
			updateGradientView();
		break;
		case "ED_GRADCHANGEPT":
			invertGPts = !invertGPts;
			x = anchorX;
			y = anchorY;
			anchorX = editorCursorX;
			anchorY = editorCursorY;
			editorCursorX = x;
			editorCursorY = y;
			updateGradientView();
		break;
		case "ED_GRADDITHERMORE":
			gradientDither += 0.025;
			if (gradientDither > 0.75)
				gradientDither = 0.75;
			updateGradientView();
		break;
		case "ED_GRADDITHERLESS":
			gradientDither -= 0.025;
			if (gradientDither < 0.0)
				gradientDither = 0.0;
			updateGradientView();
		break;
		case "ED_GRADLINEAR":
			gradientShape = GRAD_LINEAR;
			updateGradientView();
		break;
		case "ED_GRADBILINEAR":
			gradientShape = GRAD_BILINEAR;
			updateGradientView();
		break;
		case "ED_GRADRADIAL":
			gradientShape = GRAD_RADIAL;
			updateGradientView();
		break;
		case "ED_GRADIENTDONE":
			updateGradientView(true);
			cursorActive = true;
			anchorX = -1;
			zzt.establishGui(zzt.prefEditorGui);
			updateEditorView(false);
			modFlag = true;
		break;
		case "ED_CANCELGRADIENT":
			cursorActive = true;
			anchorX = -1;
			zzt.establishGui(zzt.prefEditorGui);
			updateEditorView(false);
		break;
	}
}

// Show gradient preview within board
public static function updateGradientView(writeToGrid:Boolean=false):void {
	if (!writeToGrid)
		updateEditorView(false);

	// Get type extent info
	var numTypes:int = (patternCursor == -1) ? actualBBLen : 5;
	var typeExtent:Number =
		Number((gradientShape == GRAD_BILINEAR) ? (numTypes * 2 - 1) : numTypes);
	var halfInterval:Number = 0.5 / Number(typeExtent);
	var adjustedExtent:Number = 1.0 + (halfInterval * 2);
	var radialRatioAdjust:Number = (zzt.Use40Column == 1) ? 1.0 : 4.0; // Need other factor?

	var dx:int = -SE.CameraX + SE.vpX0 - 1;
	var dy:int = -SE.CameraY + SE.vpY0 - 1;

	// Calculate foci
	var fociX1:Number = Number(invertGPts ? editorCursorX : anchorX);
	var fociY1:Number = Number(invertGPts ? editorCursorY : anchorY);
	var fociX2:Number = Number(invertGPts ? anchorX : editorCursorX);
	var fociY2:Number = Number(invertGPts ? anchorY : editorCursorY);
	var fociDist:Number =
		Math.sqrt((fociX1 - fociX2) * (fociX1 - fociX2) + (fociY1 - fociY2) * (fociY1 - fociY2));
	var fociAngle:Number = Math.atan2(fociY2 - fociY1, fociX2 - fociX1);

	if (fociDist <= 0.0)
		return; // NO!!  Foci must be unique.

	for (var i:int = 0; i < gradBuffer.length; i++) {
		var x:Number = Number(gradBuffer[i].x);
		var y:Number = Number(gradBuffer[i].y);

		// Translate point to gradient space position.
		var gradPos:Number = 0.0;
		if (gradientShape == GRAD_RADIAL)
		{
			var fDist:Number = Math.sqrt((x - fociX1) * (x - fociX1) +
				(y - fociY1) * (y - fociY1) * radialRatioAdjust);
			gradPos = fDist / fociDist;
		}
		else
		{
			var xPrime:Number = (x - fociX1) * Math.cos(-fociAngle)
				- (y - fociY1) * Math.sin(-fociAngle);
			gradPos = xPrime / fociDist;
		}

		// Apply dither.
		gradPos += utils.frange(-gradientDither, gradientDither);

		// Select type index; have index run through "centers" of edges.
		var typeIndex:int = int(Math.floor((gradPos + halfInterval) / adjustedExtent
			* Number(typeExtent)));
		//var typeIndex:int = int(Math.floor(gradPos * Number(typeExtent))); // Alt:  outer edges are borders
		if (typeIndex >= typeExtent)
			typeIndex = typeExtent - 1;
		if (typeIndex < 0)
			typeIndex = 0;

		// Pick type info.
		var idx:int;
		if (gradientShape == GRAD_BILINEAR)
		{
			if (typeIndex >= numTypes)
				idx = typeIndex - numTypes + 1;
			else
				idx = (numTypes - 1) - typeIndex;
		}
		else
			idx = typeIndex;

		var pType:Array;
		if (patternCursor == -1)
		{
			// Back buffer assumes ascending from first position.
			pType = bBuffer[idx];
		}
		else
		{
			// Built-in patterns assume ascending from solid to empty.
			immType[0] = longBuiltInTypes[idx][0];
			immType[1] = (blinkFlag ? 128 : 0) + (bgColorCursor * 16) + fgColorCursor;
			immType[2] = longBuiltInTypes[idx][1];
			immType[3] = null;
			pType = immType;
		}

		// Choose what to do:  just draw, or set.
		var destType:int = interp.typeTrans[pType[2]];
		var destColor:int = pType[1];
		if (!defColorMode)
			destColor = (blinkFlag ? 128 : 0) + (bgColorCursor * 16) + fgColorCursor;
		destColor = colorVis2Stored(destType, destColor, pType[0]);

		if (writeToGrid)
		{
			// Set.
			if (pType[3] == null)
			{
				SE.setType(int(x), int(y), destType);
				SE.setColor(int(x), int(y), destColor, false);
			}
			else
				createSECopy(int(x), int(y), destType, destColor, pType[3]);
		}
		else
		{
			// Draw.
			zzt.mg.setCell(int(x) + dx, int(y) + dy, pType[0], destColor);
		}
	}
}

// Get a spot-placement type array based on current pattern selection.
public static function getPType():Array {
	if (patternCursor == -1)
	{
		// Back buffer
		var srcPType:Array = bBuffer[patternBBCursor];
		immType[0] = srcPType[0];
		immType[1] = srcPType[1];
		immType[2] = srcPType[2];
		immType[3] = srcPType[3];
		if (!defColorMode)
			immType[1] = (blinkFlag ? 128 : 0) + (bgColorCursor * 16) + fgColorCursor;
	}
	else if (editorStyle == EDSTYLE_ULTRA || editorStyle == EDSTYLE_KEVEDIT)
	{
		// Get type from pattern table and color from color cursors.
		immType[0] = longBuiltInTypes[patternCursor][0];
		immType[1] = (blinkFlag ? 128 : 0) + (bgColorCursor * 16) + fgColorCursor;
		immType[2] = longBuiltInTypes[patternCursor][1];
		immType[3] = null;
	}
	else
	{
		// Earlier editors have simpler pattern table.
		immType[0] = shortBuiltInTypes[patternCursor][0];
		immType[1] = (blinkFlag ? 128 : 0) + (bgColorCursor * 16) + fgColorCursor;
		immType[2] = shortBuiltInTypes[patternCursor][1];
		immType[3] = null;
	}

	return immType;
}

// Conduct a "fill" operation.
public static function floodFill(x:int, y:int, action:int):Boolean {
	var srcType:int = SE.getType(x, y);
	var srcColor:int = SE.getColor(x, y);

	var pType:Array = getPType();
	var destType:int = interp.typeTrans[pType[2]];
	var destColor:int = pType[1];

	if (srcType == zzt.bEdgeType)
		return false; // Can't fill this type
	if (destType == SE.getType(x, y) && destColor == SE.getColor(x, y) && action == FILL_PAINT)
		return false; // No need for fill operation

	// Initiate fill objects
	var se:SE = pType[3];
	anchorX = -1;
	selBuffer = [];
	fillBuffer = [];
	fillBuffer.push(new IPoint(x, y));

	// Handle all fill object iterations
	while (fillBuffer.length > 0) {
		for (var i:int = 0; i < fillBuffer.length; i++) {
			x = fillBuffer[i].x;
			y = fillBuffer[i].y;

			if (SE.getType(x, y) != srcType || SE.getColor(x, y) != srcColor)
			{
				// Doubled-up object; discard.
				fillBuffer.splice(i, 1);
				i--;
				continue;
			}

			// Spread objects to nearest four neighbors
			var dx:int = x - 1;
			var dy:int = y;
			if (SE.getType(dx, dy) == srcType && SE.getColor(dx, dy) == srcColor)
				fillBuffer.push(new IPoint(dx, dy));

			dx += 2;
			if (SE.getType(dx, dy) == srcType && SE.getColor(dx, dy) == srcColor)
				fillBuffer.push(new IPoint(dx, dy));

			dx -= 1;
			dy -= 1;
			if (SE.getType(dx, dy) == srcType && SE.getColor(dx, dy) == srcColor)
				fillBuffer.push(new IPoint(dx, dy));

			dy += 2;
			if (SE.getType(dx, dy) == srcType && SE.getColor(dx, dy) == srcColor)
				fillBuffer.push(new IPoint(dx, dy));

			// Remove square from future consideration
			SE.setType(x, y, srcType ^ 128);
			selBuffer.push(fillBuffer[i]);
			fillBuffer.splice(i, 1);
			i--;
		}
	}

	// Revert types back to normal
	for (i = 0; i < selBuffer.length; i++) {
		x = selBuffer[i].x;
		y = selBuffer[i].y;
		SE.setType(x, y, srcType);
	}

	return (fillAction(action));
}

// Perform fill action on current selection
public static function fillAction(action:int):Boolean {
	if (action == FILL_SELECTION)
	{
		updateEditorView(false);
		return true; // No action; just retain selections
	}

	// From selections, decide what to do from action
	var pType:Array = getPType();
	var destType:int = interp.typeTrans[pType[2]];
	var destColor:int = pType[1];
	var se:SE = pType[3];
	destColor = colorVis2Stored(destType, destColor, pType[0]);

	for (var i:int = 0; i < selBuffer.length; i++) {
		var x:int = selBuffer[i].x;
		var y:int = selBuffer[i].y;

		killSE(x, y);
		SE.setType(x, y, 0);
		if (action == FILL_PAINT)
		{
			if (se == null)
			{
				SE.setType(x, y, destType);
				SE.setColor(x, y, destColor, false);
			}
			else
				createSECopy(x, y, destType, destColor, se);
		}
		else if (action == FILL_RANDOMPAINT)
		{
			placeRandomType(x, y);
		}
	}

	modFlag = true;
	selBuffer = [];
	anchorX = -1;
	updateEditorView(false);
	return true;
}

// Select all similar tiles (like a "color picker" eyedrop tool)
public static function pickerSel(x:int, y:int):void {
	var srcType:int = SE.getType(x, y);
	var srcColor:int = SE.getColor(x, y);

	selBuffer = [];
	anchorX = -1;
	for (var dy:int = 1; dy <= boardHeight; dy++) {
		for (var dx:int = 1; dx <= boardWidth; dx++) {
			if (srcType == SE.getType(dx, dy) && srcColor == SE.getColor(dx, dy))
				selBuffer.push(new IPoint(dx, dy));
		}
	}

	updateEditorView(false);
}

// Capture selected tiles to clipboard
public static function captureSel(doCut:Boolean):void {
	if (selBuffer.length == 0)
	{
		// Nothing to capture
		clipX1 = 0;
		clipY1 = 0;
		clipBuffer = [];
		return;
	}

	clipBuffer = new Array(selBuffer.length);
	clipX1 = 10000000;
	clipY1 = 10000000;
	for (var i:int = 0; i < selBuffer.length; i++) {
		// Get captured tile; like back buffer except coordinates also stored
		var pt:IPoint = selBuffer[i];
		var type:int = SE.getType(pt.x, pt.y);
		var capTile:Array = [ zzt.mg.getChar(pt.x - SE.CameraX + SE.vpX0 - 1,
			pt.y - SE.CameraY + SE.vpY0 - 1), SE.getColor(pt.x, pt.y),
			zzt.typeList[type].NUMBER, null, pt.x, pt.y];

		var oldSE:SE = SE.getStatElemAt(pt.x, pt.y);	
		if (oldSE)
		{
			// Configure stat type as needed.
			var se:SE = new SE(oldSE.TYPE, pt.x, pt.y, capTile[1], true);
			se.CYCLE = oldSE.CYCLE;
			se.STEPX = oldSE.STEPX;
			se.STEPY = oldSE.STEPY;
			se.IP = oldSE.IP;
			se.FLAGS = oldSE.FLAGS;
			se.delay = oldSE.delay;
			for (var s:String in oldSE.extra)
				se.extra[s] = oldSE.extra[s];

			capTile[3] = se;
		}

		// Store captured tile in clipboard; save upper-left reference point.
		clipBuffer[i] = capTile;
		if (clipX1 > pt.x)
			clipX1 = pt.x;
		if (clipY1 > pt.y)
			clipY1 = pt.y;
	}

	// If we are cutting, we must spot-place the selected pattern in the
	// area we just captured.
	if (doCut)
	{
		modFlag = true;
		for (i = 0; i < selBuffer.length; i++) {
			var pType:Array = getPType();
			var destType:int = interp.typeTrans[pType[2]];
			var destColor:int = pType[1];
			destColor = colorVis2Stored(destType, destColor, pType[0]);

			se = pType[3];
			var x:int = selBuffer[i].x;
			var y:int = selBuffer[i].y;

			killSE(x, y);
			SE.setType(x, y, 0);
			if (se == null)
			{
				SE.setType(x, y, destType);
				SE.setColor(x, y, destColor, false);
			}
			else
				createSECopy(x, y, destType, destColor, se);
		}
	}

	selBuffer = [];
	anchorX = -1;
	updateEditorView(false);
}

public static function updatePasteView():void {
	// Set selection to match clipboard shape
	selBuffer = [];
	anchorX = -1;
	for (var i:int = 0; i < clipBuffer.length; i++) {
		var x:int = clipBuffer[i][4] + (editorCursorX - clipX1);
		var y:int = clipBuffer[i][5] + (editorCursorY - clipY1);
		selBuffer.push(new IPoint(x, y));
	}

	updateEditorView(false);
}

public static function pasteSel():void {
	for (var i:int = 0; i < clipBuffer.length; i++) {
		// Paste clipboard tile
		var pType:Array = clipBuffer[i];
		var x:int = pType[4] + (editorCursorX - clipX1);
		var y:int = pType[5] + (editorCursorY - clipY1);
		if (x >= 1 && y >= 1 && x <= boardWidth && y <= boardHeight)
		{
			var destType:int = interp.typeTrans[pType[2]];
			var destColor:int = pType[1];
			var se:SE = pType[3];

			killSE(x, y);
			SE.setType(x, y, 0);
			if (se == null)
			{
				SE.setType(x, y, destType);
				SE.setColor(x, y, destColor, false);
			}
			else
				createSECopy(x, y, destType, destColor, se);
		}
	}

	modFlag = true;
	selBuffer = [];
	updateEditorView(false);
}

// Create copy of status element at location
public static function createSECopy(x:int, y:int, destType:int, destColor:int, oldSE:SE):void {
	var se:SE = new SE(destType, x, y, destColor);
	SE.setStatElemAt(x, y, se);
	SE.statElem.push(se);
	modFlag = true;

	se.STEPX = oldSE.STEPX;
	se.STEPY = oldSE.STEPY;
	se.CYCLE = oldSE.CYCLE;
	se.IP = oldSE.IP;
	se.FLAGS = oldSE.FLAGS;
	se.delay = oldSE.delay;
	for (var s:String in oldSE.extra)
		se.extra[s] = oldSE.extra[s];
}

public static function placeRandomType(x:int, y:int):void {
	var pType:Array = null;
	if (patternCursor == -1)
	{
		// Pick from back buffer
		var idx:int = utils.onethru(actualBBLen) - 1;
		pType = bBuffer[idx];
	}
	else
	{
		// Get type from pattern table and color from color cursors.
		idx = utils.onethru(patternBuiltIn - 1) - 1;
		immType[0] = longBuiltInTypes[idx][0];
		immType[1] = (blinkFlag ? 128 : 0) + (bgColorCursor * 16) + fgColorCursor;
		immType[2] = longBuiltInTypes[idx][1];
		immType[3] = null;
		pType = immType;
	}

	// Place chosen type
	modFlag = true;
	var destType:int = interp.typeTrans[pType[2]];
	var destColor:int = pType[1];
	if (!defColorMode)
		destColor = (blinkFlag ? 128 : 0) + (bgColorCursor * 16) + fgColorCursor;
	destColor = colorVis2Stored(destType, destColor, pType[0]);

	if (pType[3] == null)
	{
		SE.setType(x, y, destType);
		SE.setColor(x, y, destColor, false);
	}
	else
		createSECopy(x, y, destType, destColor, pType[3]);
}

// Select color or pattern based on mouse position within GUI.
public static function colorPatternMousePick(
	guiX:int, guiY:int, rightSide:int, downSide:int):void {

	if (zzt.thisGuiName == "ED_CLASSIC" || zzt.thisGuiName == "ED_SUPERZZT")
	{
		if (guiX < 9)
		{
			// Pattern selection
			if (guiX >= 3 && guiX <= 7)
			{
				patternCursor = guiX - 3;
				patternBBCursor = 0;
			}
			else if (guiX == 8)
			{
				patternBBCursor = 0;
				patternCursor = -1;
			}

			drawEditorPatternCursor();
		}
		else if (guiX >= 10 && guiX <= 17)
		{
			// Color selection
			if (guiY == 22 ||
				(guiY == 23 && (downSide == 0 || zzt.thisGuiName == "ED_CLASSIC")))
			{
				// FG selection (top)
				fgColorCursor = guiX - 10 + 8;
			}
			else if (zzt.thisGuiName == "ED_SUPERZZT" && guiY == 23 && downSide == 1)
			{
				// FG selection (bottom)
				fgColorCursor = guiX - 10;
			}
			else if (zzt.thisGuiName == "ED_SUPERZZT" && guiY == 24)
			{
				// BG selection
				bgColorCursor = guiX - 10;
			}

			drawEditorPatternCursor();
			drawEditorColorCursors();
		}
	}
	else
	{
		if (guiY >= 21 && guiY <= 22)
		{
			// Pattern selection
			if (guiX >= 2 && guiX <= 7)
			{
				patternCursor = guiX - 2;
				patternBBCursor = 0;
			}
			else if (guiX == 8)
				bufLockMode = !bufLockMode;
			else if (guiX >= 9 && guiX <= 18)
			{
				patternBBCursor = guiX - 9;
				patternCursor = -1;
			}
			else if (guiX >= 19)
				acquireMode = !acquireMode;

			drawEditorPatternCursor();
		}
		else if (guiY == 23 || (guiY == 24 && downSide == 0))
		{
			// FG selection
			if (guiX >= 2 && guiX <= 17)
				fgColorCursor = guiX - 2;
			else if (guiX >= 19)
				defColorMode = !defColorMode;

			drawEditorPatternCursor();
			drawEditorColorCursors();
		}
		else if (guiY == 25 || (guiY == 24 && downSide == 1))
		{
			// BG selection
			if (guiX >= 2 && guiX <= 9)
				bgColorCursor = 0;
			else if (guiX >= 10 && guiX <= 17)
				bgColorCursor = guiX - 10;
			else if (guiX >= 19)
				defColorMode = !defColorMode;

			drawEditorPatternCursor();
			drawEditorColorCursors();
		}
	}
}

// Dispatch legacy F1-menu message
public static function dispatchF1Menu(msg:String):void {
	var oldDefColorMode:Boolean = defColorMode;
	var oldFG:int = fgColorCursor;
	var oldBG:int = bgColorCursor;
	switch (msg) {
		case "ED_CANCELTYPE":
			cursorActive = true;
			zzt.establishGui(zzt.prefEditorGui);
			updateEditorView(true);
		break;
		case "ED_TYPEPLAYER":
			defColorMode = false;
			fgColorCursor = 15;
			bgColorCursor = 1;
			selectStatType("PLAYER", false, false, false, false, playerExtras);
			fgColorCursor = oldFG;
			bgColorCursor = oldBG;
			defColorMode = oldDefColorMode;
			updateEditorView(true);
		break;
		case "ED_TYPEGEM":
		case "ED_TYPEAMMO":
		case "ED_TYPETORCH":
		case "ED_TYPEENERGIZER":
		case "ED_TYPEKEY":
		case "ED_TYPEDOOR":
			selectNoStatType(msg.substr(7));
		break;
		case "ED_TYPEPASSAGE":
			selectStatType("PASSAGE", false, false, false, true, passageExtras);
		break;
		case "ED_TYPECLOCKWISE":
			selectStatType("CLOCKWISE", false);
		break;
		case "ED_TYPECOUNTER":
			selectStatType("COUNTER", false);
		break;
		case "ED_TYPESCROLL":
			selectStatType("SCROLL", false, false, false, false, scrollExtras);
		break;
		case "ED_TYPEDUPLICATOR":
			selectStatType("DUPLICATOR", true, false, true, false, duplicatorExtras);
		break;
		case "ED_TYPEBOMB":
			selectStatType("BOMB", false, true);
		break;
	}
}

// Dispatch legacy F2-menu message
public static function dispatchF2Menu(msg:String):void {
	switch (msg) {
		case "ED_CANCELTYPE":
			cursorActive = true;
			zzt.establishGui(zzt.prefEditorGui);
			updateEditorView(true);
		break;
		case "ED_TYPESTAR":
			selectStatType("STAR", true, false, false, false, starExtras);
		break;
		case "ED_TYPEBULLET":
			selectStatType("BULLET", true);
		break;
		case "ED_TYPEHEAD":
			selectStatType("HEAD", false, true, true);
		break;
		case "ED_TYPESEGMENT":
			selectStatType("SEGMENT", false);
		break;
		case "ED_TYPERUFFIAN":
			selectStatType("RUFFIAN", false, true, true);
		break;
		case "ED_TYPEBEAR":
			selectStatType("BEAR", false, true);
		break;
		case "ED_TYPESHARK":
			selectStatType("SHARK", false, true);
		break;
		case "ED_TYPELION":
			selectStatType("LION", false, true);
		break;
		case "ED_TYPETIGER":
			selectStatType("TIGER", false, true, true);
		break;
		case "ED_TYPEPUSHER":
			selectStatType("PUSHER", true);
		break;
		case "ED_TYPESLIME":
			selectStatType("SLIME", false, false, true);
		break;
		case "ED_TYPESPINNINGGUN":
			selectStatType("SPINNINGGUN", false, true, true, false, spinningGunExtras);
		break;
		case "ED_TYPEOBJECT":
			selectStatType("OBJECT", false, false, false, false, objectExtras);
		break;
	}
}

// Dispatch legacy F3-menu message
public static function dispatchF3Menu(msg:String):void {
	var oldDefColorMode:Boolean = defColorMode;
	switch (msg) {
		case "ED_CANCELTYPE":
			cursorActive = true;
			zzt.establishGui(zzt.prefEditorGui);
			updateEditorView(true);
		break;
		case "ED_TYPESOLID":
		case "ED_TYPENORMAL":
		case "ED_TYPEFAKE":
		case "ED_TYPEBREAKABLE":
		case "ED_TYPEINVISIBLE":
		case "ED_TYPEFOREST":
		case "ED_TYPEWATER":
		case "ED_TYPEBOARDEDGE":
		case "ED_TYPERICOCHET":
		case "ED_TYPEBOULDER":
		case "ED_TYPESLIDERNS":
		case "ED_TYPESLIDEREW":
		case "ED_TYPE_BEAMHORIZ":
		case "ED_TYPE_BEAMVERT":
		case "ED_TYPEMONITOR":
			selectNoStatType(msg.substr(7));
		break;
		case "ED_TYPEDEADSMILEY":
			defColorMode = false;
			selectStatType("PLAYER", false, false, false, false, playerDeadExtras);
			defColorMode = oldDefColorMode;
			updateEditorView(true);
		break;
		case "ED_TYPEBLINKWALL":
			selectStatType("BLINKWALL", true, true, true);
		break;
		case "ED_TYPETRANSPORTER":
			if (prevStepX == 1)
				transporterExtras["CHAR"] = 62;
			else if (prevStepX == -1)
				transporterExtras["CHAR"] = 60;
			else if (prevStepY == 1)
				transporterExtras["CHAR"] = 40;
			else if (prevStepY == -1)
				transporterExtras["CHAR"] = 94;
			selectStatType("TRANSPORTER", true, false, false, false, transporterExtras);
		break;
	}
}

// Dispatch legacy F4-menu message
public static function dispatchF4Menu(msg:String):void {
	switch (msg) {
		case "ED_CANCELTYPE":
			cursorActive = true;
			zzt.establishGui(zzt.prefEditorGui);
			updateEditorView(true);
		break;
		case "ED_TYPESPIDER":
			selectStatType("SPIDER", false, true);
		break;
		case "ED_TYPEBDRAGONPUP":
			selectStatType("DRAGONPUP", false, true, true, false, dragonPupExtras);
		break;
		case "ED_TYPEROTON":
		case "ED_TYPEPAIRER":
			selectStatType(msg.substr(7), false, true, true);
		break;
	}
}

// Dispatch legacy F5-menu message
public static function dispatchF5Menu(msg:String):void {
	switch (msg) {
		case "ED_CANCELTYPE":
			cursorActive = true;
			zzt.establishGui(zzt.prefEditorGui);
			updateEditorView(true);
		break;
		case "ED_TYPEFLOOR":
		case "ED_TYPEWATERS":
		case "ED_TYPEWATERN":
		case "ED_TYPEWATERE":
		case "ED_TYPEWATERW":
		case "ED_TYPEWEB":
			selectNoStatType(msg.substr(7));
		break;
		case "ED_TYPESTONE":
			selectStatType("STONE", false, false, false, false, stoneExtras);
		break;
	}
}

// Establish a non-stat type from menu for placement.
public static function selectNoStatType(tName:String):void {
	// Set immediate type to non-stat type.
	var eInfo:ElementInfo = zzt.getTypeFromName(tName);
	immType[0] = eInfo.CHAR;
	immType[1] = eInfo.COLOR;
	immType[2] = eInfo.NUMBER;
	immType[3] = null;
	if (!defColorMode || !eInfo.DominantColor)
		immType[1] = (blinkFlag ? 128 : 0) + (bgColorCursor * 16) + fgColorCursor;

	// Place and modify
	add2BBuffer();
	spotPlace(false, true);

	// Return to editor
	modFlag = true;
	cursorActive = true;
	zzt.establishGui(zzt.prefEditorGui);
	updateEditorView(true);
}

// Establish a stat type from menu for placement.
public static function selectStatType(tName:String, usePrevDir:Boolean=false,
	usePrevP1:Boolean=false, usePrevP2:Boolean=false, usePrevP3:Boolean=false, extras=null):void {
	// Set immediate type to stat type.
	var eInfo:ElementInfo = zzt.getTypeFromName(tName);
	immType[0] = eInfo.CHAR;
	immType[1] = eInfo.COLOR;
	immType[2] = eInfo.NUMBER;
	if (!defColorMode || !eInfo.DominantColor)
		immType[1] = (blinkFlag ? 128 : 0) + (bgColorCursor * 16) + fgColorCursor;

	// Configure stat type as needed.
	var se:SE = new SE(interp.typeTrans[eInfo.NUMBER],
		editorCursorX, editorCursorY, immType[1], true);
	immType[3] = se;

	if (usePrevDir)
	{
		se.STEPX = prevStepX;
		se.STEPY = prevStepY;
	}
	if (usePrevP1)
		se.extra["P1"] = prevP1;
	if (usePrevP2)
		se.extra["P2"] = prevP2;
	if (usePrevP3)
		se.extra["P3"] = prevP3;

	if (extras != null)
	{
		for (var s:String in extras)
			se.extra[s] = extras[s];
	}

	// Place and modify
	add2BBuffer();
	spotPlace(false, true);

	// Return to editor
	modFlag = true;
	cursorActive = true;
	zzt.establishGui(zzt.prefEditorGui);
	updateEditorView(true);
}

// Pick up type at cursor location; add to back buffer.
public static function pickupCursor():void {
	SE.displaySquare(editorCursorX, editorCursorY);
	var type:int = SE.getType(editorCursorX, editorCursorY);

	immType[0] = zzt.mg.getChar(editorCursorX - SE.CameraX + SE.vpX0 - 1,
		editorCursorY - SE.CameraY + SE.vpY0 - 1);
	immType[1] = zzt.mg.getAttr(editorCursorX - SE.CameraX + SE.vpX0 - 1,
		editorCursorY - SE.CameraY + SE.vpY0 - 1);
	immType[2] = zzt.typeList[type].NUMBER;
	immType[3] = null;
	var oldSE:SE = SE.getStatElemAt(editorCursorX, editorCursorY);

	// Copy SE if needed.
	if (oldSE)
	{
		// Configure stat type as needed.
		var se:SE = new SE(oldSE.TYPE, editorCursorX, editorCursorY, immType[1], true);
		se.CYCLE = oldSE.CYCLE;
		se.STEPX = oldSE.STEPX;
		se.STEPY = oldSE.STEPY;
		se.IP = oldSE.IP;
		se.FLAGS = oldSE.FLAGS;
		se.delay = oldSE.delay;
		se.UNDERID = oldSE.UNDERID;
		se.UNDERCOLOR = oldSE.UNDERCOLOR;
		for (var s:String in oldSE.extra)
			se.extra[s] = oldSE.extra[s];

		immType[3] = se;
	}

	add2BBuffer();
}

// Add to the back buffer, forward-feeding it.
public static function add2BBuffer(doFeed:Boolean=true):void {
	if (bufLockMode)
		return;

	if (doFeed)
	{
		for (var i:int = MAX_BBUFFER - 1; i > 0; i--)
		{
			bBuffer[i][0] = bBuffer[i-1][0];
			bBuffer[i][1] = bBuffer[i-1][1];
			bBuffer[i][2] = bBuffer[i-1][2];
			bBuffer[i][3] = bBuffer[i-1][3];
		}
	}

	bBuffer[0][0] = immType[0];
	bBuffer[0][1] = immType[1];
	bBuffer[0][2] = immType[2];
	bBuffer[0][3] = immType[3];

	drawEditorPatternCursor();
}

// Handle text drawing character
public static function writeTextDrawChar(charCode:int):void {
	// If backspace, take back a character
	modFlag = true;
	if (charCode == 8 && zzt.mainMode != zzt.MODE_CHARSEL)
	{
		eraseEditorCursor();
		if (--editorCursorX <= 0)
			editorCursorX = boardWidth;
		dispatchEditorMenu("ED_DELETE");
		drawEditorCursor();
		return;
	}

	var baseColorIdx:int;
	if (text128)
	{
		// 128-color, full-text mode
		baseColorIdx = 100 + (bgColorCursor * 16 + fgColorCursor);
	}
	else
	{
		// 7-color, limited-text mode
		baseColorIdx = (fgColorCursor & 7) - 1;
		if (baseColorIdx == -1)
			baseColorIdx = 0;
		baseColorIdx += 73; // _TEXTBLUE
	}

	// If entering a hex code character, need two characters.
	if (hexTextEntry > 0)
	{
		var dCode:int = 0;
		if (charCode >= 48 && charCode <= 57)
			dCode = charCode - 48;
		else if (charCode >= 65 && charCode <= 90)
			dCode = (charCode - 65) + 10;
		else if (charCode >= 97 && charCode <= 122)
			dCode = (charCode - 97) + 10;

		if (hexTextEntry == 1)
		{
			// First digit
			hexCodeValue = dCode;
			hexTextEntry++;
			return;
		}
		else
		{
			// Second digit--use code
			hexCodeValue = hexCodeValue * 16 + dCode;
			charCode = hexCodeValue;
			hexTextEntry = 0;
			drawEditorPatternCursor();
		}
	}

	// Write text character
	immType[0] = charCode;
	immType[1] = charCode;
	immType[2] = baseColorIdx;
	immType[3] = null;
	spotPlace(false, true);

	// Advance cursor
	if (++editorCursorX > boardWidth)
		editorCursorX = 1;
	drawEditorCursor();
}

// Get a type number that is not currently being used.
public static function getFreeTypeNumber():int {
	for (var i:int = 0; i < 254; i++) {
		var found:Boolean = true;
		for (var j:int = 0; j < zzt.typeList.length; j++) {
			var eInfo:ElementInfo = zzt.typeList[j];
			if (eInfo.NUMBER == i)
			{
				found = false;
				break;
			}
		}

		if (found)
			return i;
	}

	// This should not happen in theory...every single type is exhausted?
	return 252;
}

// Dispatch modern "all type" menu message
public static function dispatchTypeAllMenu(msg:String):void {
	var eInfo:ElementInfo;
	switch (msg) {
		case "ED_CANCELALLTYPE":
			cursorActive = true;
			zzt.establishGui(zzt.prefEditorGui);
			updateEditorView(false);
		break;
		case "ED_TYPEALLSEL":
			eInfo = zzt.typeList[typeAllTypes[typeAllCursor]];
			if (eInfo.NoStat)
				selectNoStatType(eInfo.NAME);
			else if (eInfo.HasOwnCode)
				selectStatType(eInfo.NAME, false, false, false, false, scrollExtras);
			else
			{
				switch (eInfo.NAME) {
					case "PASSAGE":
						selectStatType(eInfo.NAME, false, false, false, false, passageExtras);
					break;
					case "BLINKWALL":
						selectStatType(eInfo.NAME, true, true, true);
					break;
					case "DUPLICATOR":
						selectStatType(eInfo.NAME, true, false, true, false, duplicatorExtras);
					break;
					case "STAR":
						selectStatType(eInfo.NAME, true, false, false, false, starExtras);
					break;
					case "BULLET":
					case "PUSHER":
						selectStatType(eInfo.NAME, true);
					break;
					case "TRANSPORTER":
						if (prevStepX == 1)
							transporterExtras["CHAR"] = 62;
						else if (prevStepX == -1)
							transporterExtras["CHAR"] = 60;
						else if (prevStepY == 1)
							transporterExtras["CHAR"] = 40;
						else if (prevStepY == -1)
							transporterExtras["CHAR"] = 94;
						selectStatType(eInfo.NAME, true, false, false, false, transporterExtras);
					break;
					default:
						selectStatType(eInfo.NAME, false);
					break;
				}
			}

			cursorActive = true;
			zzt.establishGui(zzt.prefEditorGui);
			updateEditorView(false);
		break;
		case "ED_TYPEALLPREV":
			if (typeAllPage > 0)
			{
				typeAllPage--;
				typeAllCursor -= TYPEALL_PAGELIMIT;
				if (typeAllCursor < 0)
					typeAllCursor = 0;
				updateTypeAllView(true);
			}
		break;
		case "ED_TYPEALLNEXT":
			if (typeAllPage < typeAllPageCount - 1)
			{
				typeAllPage++;
				typeAllCursor += TYPEALL_PAGELIMIT;
				if (typeAllCursor >= typeAllTypes.length)
					typeAllCursor = typeAllTypes.length - 1;
				updateTypeAllView(true);
			}
		break;
		case "ED_TYPEEDITOR":
			eInfo = zzt.typeList[typeAllTypes[typeAllCursor]];
			newTypeNameFocus = eInfo.NAME;
			newTypeString = eInfo.toString();
			if (zzt.extraTypeCode.hasOwnProperty(eInfo.NAME))
			{
				hasExistingTypeSpec = true;
				newTypeString += "\"" + zzt.markUpCodeQuotes(zzt.extraTypeCode[eInfo.NAME]) + "\"\n}";
			}
			else
			{
				hasExistingTypeSpec = false;
				newTypeString += "\"\n#END\n\"\n}";
			}

			zzt.establishGui(zzt.prefEditorGui);
			launchTypeEditor(true);
		break;
		case "ED_TYPENEW":
			newTypeNum++;
			eInfo = new ElementInfo("NEWTYPE" + newTypeNum.toString());
			eInfo.NUMBER = getFreeTypeNumber();
			eInfo.CHAR = 1;
			eInfo.NoStat = Boolean(typeAllFilter != TYPEFILTER_STATTYPES);
			eInfo.BlockObject = Boolean(typeAllFilter != TYPEFILTER_FLOOR);
			eInfo.BlockPlayer = Boolean(typeAllFilter != TYPEFILTER_FLOOR);
			newTypeNameFocus = eInfo.NAME;
			newTypeString = eInfo.toString();
			newTypeString += "\"\n#END\n\"\n}";
			hasExistingTypeSpec = false;

			zzt.establishGui(zzt.prefEditorGui);
			launchTypeEditor(true);
		break;
		case "ED_TYPELEFT":
		case "ED_TYPERIGHT":
			highlightTypeAllCursor();
			if (typeAllCursor - typeAllPage * TYPEALL_PAGELIMIT < TYPEALL_ROWLIMIT)
				typeAllCursor += TYPEALL_ROWLIMIT;
			else
				typeAllCursor -= TYPEALL_ROWLIMIT;
			if (typeAllCursor >= typeAllTypes.length)
				typeAllCursor = typeAllTypes.length - 1;
			updateTypeAllView(false);
		break;
		case "ED_TYPEUP":
			highlightTypeAllCursor();
			typeAllCursor--;
			if (typeAllCursor < 0 || typeAllCursor < typeAllPage * TYPEALL_PAGELIMIT)
				typeAllCursor = (typeAllPage + 1) * TYPEALL_PAGELIMIT - 1;
			if (typeAllCursor >= typeAllTypes.length)
				typeAllCursor = typeAllTypes.length - 1;
			updateTypeAllView(false);
		break;
		case "ED_TYPEDOWN":
			highlightTypeAllCursor();
			typeAllCursor++;
			if (typeAllCursor >= typeAllTypes.length ||
				typeAllCursor - (typeAllPage * TYPEALL_PAGELIMIT) >= TYPEALL_PAGELIMIT)
				typeAllCursor = typeAllPage * TYPEALL_PAGELIMIT;
			updateTypeAllView(false);
		break;
	}
}

// Update general type menu display
public static function updateTypeAllView(updateTypes:Boolean=false):void {
	// Get dynamic label positions
	var guiLabelInfo:Array = zzt.GuiLabels["TYPE1"];
	var gx1:int = int(guiLabelInfo[0]) - 1;
	var gy:int = int(guiLabelInfo[1]) - 1;
	var guiLabelInfo2:Array = zzt.GuiLabels["TYPE2"];
	var gx2:int = int(guiLabelInfo2[0]) - 1;

	if (updateTypes)
	{
		// Set up type list
		typeAllPageCount = 1;
		typeAllTypes = [];
		var typeAllNameSet:Object = new Object();
		var typeAllTypeNums:Array = [];
		var typeAllNames:Array = [];
		for (var i:int = zzt.typeList.length - 1; i >= 0; i--) {
			var eInfo:ElementInfo = zzt.typeList[i];
			if (!typeAllNameSet.hasOwnProperty(eInfo.NAME))
			{
				typeAllNameSet[eInfo.NAME] = 1;
				if (typeAllFilter == TYPEFILTER_STATTYPES)
				{
					if (!eInfo.NoStat && eInfo.NUMBER < 254)
					{
						typeAllTypeNums.push(i);
						typeAllNames.push(eInfo.NAME);
					}
				}
				else if (typeAllFilter == TYPEFILTER_FLOOR && eInfo.NoStat)
				{
					if (!eInfo.BlockObject && eInfo.NUMBER < 254)
					{
						typeAllTypeNums.push(i);
						typeAllNames.push(eInfo.NAME);
					}
				}
				else if (typeAllFilter == TYPEFILTER_BLOCKING && eInfo.NoStat)
				{
					if (eInfo.BlockObject && eInfo.NUMBER < 254)
					{
						typeAllTypeNums.push(i);
						typeAllNames.push(eInfo.NAME);
					}
				}
			}
		}

		// Sort types by name
		var sortOrder:Array = typeAllNames.sort(Array.RETURNINDEXEDARRAY);
		for (i = 0; i < sortOrder.length; i++) {
			typeAllTypes.push(typeAllTypeNums[sortOrder[i]]);
		}

		// Set cursor and page
		typeAllPageCount = int((typeAllTypes.length - 1) / TYPEALL_PAGELIMIT) + 1;
		if (typeAllCursor >= typeAllTypes.length || typeAllPage >= typeAllPageCount)
		{
			typeAllCursor = 0;
			typeAllPage = 0;
		}
		else
			typeAllPage = int(typeAllCursor / TYPEALL_PAGELIMIT);

		// Write current page of types
		for (i = 0; i < TYPEALL_PAGELIMIT; i++) {
			var csr:int = typeAllPage * TYPEALL_PAGELIMIT + i;
			var x:int = gx1;
			var y:int = gy + i;
			if (csr >= TYPEALL_ROWLIMIT)
			{
				x = gx2;
				y -= TYPEALL_ROWLIMIT;
			}

			var ch:int = 32;
			var col:int = 30;
			var fullStr:String = "";
			if (csr < typeAllTypes.length)
			{
				eInfo = zzt.typeList[typeAllTypes[csr]];
				fullStr = eInfo.NAME;
				ch = eInfo.CHAR;
				col = eInfo.COLOR;
				if (!eInfo.DominantColor)
					col = fgColorCursor + (bgColorCursor * 16) + (blinkFlag ? 128 : 0);
			}

			zzt.mg.writeStr(x, y, "                ", 30);
			zzt.mg.writeStr(x, y, fullStr, 30);
			zzt.mg.setCell(x - 2, y, ch, col);
		}
	}

	// Highlight cursor
	highlightTypeAllCursor();
}

public static function highlightTypeAllCursor():void {
	// Get dynamic label positions
	var guiLabelInfo:Array = zzt.GuiLabels["TYPE1"];
	var gx1:int = int(guiLabelInfo[0]) - 1;
	var gy:int = int(guiLabelInfo[1]) - 1;
	var guiLabelInfo2:Array = zzt.GuiLabels["TYPE2"];
	var gx2:int = int(guiLabelInfo2[0]) - 1;

	// Highlight
	var csr:int = typeAllCursor - typeAllPage * TYPEALL_PAGELIMIT;
	var x:int = gx1;
	var y:int = gy + csr;
	if (csr >= TYPEALL_ROWLIMIT)
	{
		x = gx2;
		csr -= TYPEALL_ROWLIMIT;
		y -= TYPEALL_ROWLIMIT;
	}

	zzt.mg.writeXorAttr(x, y, 16, 1, 127);
	zzt.typeAllInfoDelay = 8;
}

public static function showTypeAllInfo():void {
	if (zzt.thisGuiName != "ED_TYPEALL")
		return;

	var guiLabelInfo3:Array = zzt.GuiLabels["TYPEINFO"];
	var gx3:int = int(guiLabelInfo3[0]) - 1;
	var gy:int = int(guiLabelInfo3[1]) - 1;

	var x:int = gx3;
	var y:int = gy;
	var fullStr:String = "       ";
	var eInfo:ElementInfo = zzt.typeList[typeAllTypes[typeAllCursor]];

	zzt.mg.writeStr(x, y++, eInfo.NUMBER.toString() + fullStr);
	zzt.mg.writeStr(x, y++, eInfo.CYCLE.toString() + fullStr);
	zzt.mg.writeStr(x, y++, eInfo.STEPX.toString() + fullStr);
	zzt.mg.writeStr(x, y++, eInfo.STEPY.toString() + fullStr);
	zzt.mg.writeStr(x, y++, eInfo.CHAR.toString() + fullStr);
	zzt.mg.writeStr(x, y++, eInfo.COLOR.toString() + fullStr);
	zzt.mg.writeStr(x, y++, (eInfo.NoStat ? "1" : "0") + fullStr);
	zzt.mg.writeStr(x, y++, (eInfo.BlockObject ? "1" : "0") + fullStr);
	zzt.mg.writeStr(x, y++, (eInfo.BlockPlayer ? "1" : "0") + fullStr);
	zzt.mg.writeStr(x, y++, (eInfo.AlwaysLit ? "1" : "0") + fullStr);
	zzt.mg.writeStr(x, y++, (eInfo.DominantColor ? "1" : "0") + fullStr);
	zzt.mg.writeStr(x, y++, (eInfo.FullColor ? "1" : "0") + fullStr);
	zzt.mg.writeStr(x, y++, (eInfo.TextDraw ? "1" : "0") + fullStr);
	zzt.mg.writeStr(x, y++, (eInfo.CustomDraw ? "1" : "0") + fullStr);
	zzt.mg.writeStr(x, y++, (eInfo.HasOwnChar ? "1" : "0") + fullStr);
	zzt.mg.writeStr(x, y++, (eInfo.HasOwnCode ? "1" : "0") + fullStr);
	zzt.mg.writeStr(x, y++, ((eInfo.CustomStart > 0) ? "1" : "0") + fullStr);
	zzt.mg.writeStr(x, y++, eInfo.Pushable.toString() + fullStr);
	zzt.mg.writeStr(x, y++, (eInfo.Squashable ? "1" : "0") + fullStr);

	var extraStr:String = "";
	for (var k:String in eInfo.extraVals)
		extraStr += k + "=" + eInfo.extraVals[k].toString() + " ";
	zzt.mg.writeStr(x, y, "                              ");
	zzt.mg.writeStr(x, y, extraStr);
}

// Launch the type editor with a possible new/edited type focus.
public static function launchTypeEditor(singleFocus:Boolean):void {
	// Reset types; strip out extras from main record
	modFlag = true;
	ZZTLoader.registerBoardState(true);
	ZZTLoader.swapTypeNumbers(true);
	zzt.resetTypes();

	// Ensure extra types are sorted by name.
	var mainKeys:Array = [];
	var newTypeAccountedFor:Boolean = false;
	var anyExistingTypes:Boolean = false;
	for (var j:int = 0; j < zzt.extraTypeList.length; j++) {
		// We will pull out the single-focus type name and put it
		// at the beginning of the order if it was edited explicitly.
		if (newTypeNameFocus == zzt.extraTypeList[j].NAME)
		{
			newTypeAccountedFor = true;
			anyExistingTypes = true;
			mainKeys.push("!!!" + zzt.extraTypeList[j].NAME);
		}
		else
		{
			anyExistingTypes = true;
			mainKeys.push(zzt.extraTypeList[j].NAME);
		}
	}

	var sortOrder:Array = mainKeys.sort(Array.RETURNINDEXEDARRAY);

	// Capture all extra types as JSON
	var overallStr:String = "{\n";
	if (singleFocus && !hasExistingTypeSpec && !newTypeAccountedFor)
	{
		overallStr += newTypeString;
		if (anyExistingTypes)
			overallStr += ",\n\n";
	}

	for (j = 0; j < sortOrder.length; j++) {
		var i:int = sortOrder[j];
		if (newTypeNameFocus == zzt.extraTypeList[i].NAME)
		{
			overallStr += newTypeString;
		}
		else
		{
			var eInfo:ElementInfo = zzt.extraTypeList[i];
			var eStr:String = eInfo.toString();
			if (zzt.extraTypeCode.hasOwnProperty(eInfo.NAME))
				eStr += "\"" + zzt.markUpCodeQuotes(zzt.extraTypeCode[eInfo.NAME]) + "\"\n}";
			else
				eStr += "\"\n#END\n\"\n}";

			overallStr += eStr;
		}

		if (j < sortOrder.length - 1)
			overallStr += ",\n\n";
	}

	overallStr += "\n}";

	// Show dictionary
	editedPropName = "$JSONTYPES";
	zzt.propDictToUpdate = new Object();
	zzt.showPropTextView(zzt.MODE_ENTEREDITORPROP, "Customized Types", overallStr);
}

// Open a scroll interface for board info.
public static function showWorldInfo():void {
	// Write standard stuff
	var wp:Object = zzt.globalProps;
	var title:String = "Edit World Properties";
	var lines:Array = [];
	lines.push("!WORLDNAME;WORLDNAME:  " + wp["WORLDNAME"]);
	lines.push("!WORLDTYPE;WORLDTYPE:  " + wp["WORLDTYPE"] + " (-3=ZZT Ultra)");
	lines.push("!STARTBOARD;STARTBOARD:  " +
		wp["STARTBOARD"] + " " + ZZTLoader.getBoardName(wp["STARTBOARD"], true));
	lines.push("------------------------------");
	lines.push("!$INVPROP;Inventory properties");
	lines.push("!$JSONWORLDPROP;All properties (JSON)");
	lines.push("------------------------------");
	lines.push("!$GLOBALS;Global variables (common)");
	lines.push("!$JSONGLOBALS;Global variables (all, using JSON)");
	lines.push("------------------------------");
	lines.push("!$JSONTYPES;Edit Types using JSON");
	lines.push("!$JSONMASKS;Edit Masks using JSON");
	lines.push("!$JSONSOUNDFX;Edit Sounds using JSON");
	lines.push("------------------------------");
	lines.push("!$GUIMANAGER;GUI Manager");
	lines.push("!$WADMANAGER;WAD Manager");

	showEditorScroll(lines, title, SM_WORLDINFO);
}

// Open a scroll interface for board info.
public static function showInventoryScroll():void {
	modFlag = true;
	var lines:Array = [];
	for (var i:int = 0; i < inventoryWorldKeys.length; i++)
	{
		var s:String = inventoryWorldKeys[i];
		if (utils.startswith(s, "KEY"))
		{
			var kVal:int = int(s.substr(3)) & 15;
			lines.push("!" + s + ";" + s + " (" + prettyColorNames[kVal] + "):  " +
				zzt.globalProps[s].toString());
		}
		else
			lines.push("!" + s + ";" + s + ":  " + zzt.globalProps[s].toString());
	}
	showEditorScroll(lines, "Inventory Properties", SM_INVENTORYINFO);
}

// Open a scroll interface for basic (non-incidental) global variables.
public static function showGlobalsScroll():void {
	modFlag = true;
	zzt.establishGui("ED_DELEDIT");
	zzt.drawGui();

	var sortedKeys:Array = [];
	for (var s:String in zzt.globals)
	{
		if (s.charAt(0) != "$" && !(zzt.globals[s] is Array))
			sortedKeys.push(s);
	}
	sortedKeys = sortedKeys.sort(Array.CASEINSENSITIVE);

	var lines:Array = [];
	for (var i:int = 0; i < sortedKeys.length; i++)
	{
		s = sortedKeys[i];
		lines.push("!" + s + ";" + s + ":  " + zzt.globals[s].toString());
	}

	if (sortedKeys.length == 0)
		handleClosedEditorScroll();
	else
		showEditorScroll(lines, "Common Global Variables", SM_GLOBALS);
}

// Open a scroll interface for board info.
public static function showBoardInfo():void {
	// Write standard stuff
	var bp:Object = zzt.boardProps;
	var title:String = "Edit Board Properties";
	var lines:Array = [];
	lines.push("!BOARDNAME;BOARDNAME:  " + bp["BOARDNAME"]);
	lines.push("------------------------------");
	lines.push("!SIZEX;SIZEX:  " + bp["SIZEX"]);
	lines.push("!SIZEY;SIZEY:  " + bp["SIZEY"]);
	lines.push("------------------------------");
	lines.push("!ISDARK;ISDARK:  " + bp["ISDARK"]);
	lines.push("!RESTARTONZAP;RESTARTONZAP:  " + bp["RESTARTONZAP"]);
	lines.push("!TIMELIMIT;TIMELIMIT:  " + bp["TIMELIMIT"] + " (0=No limit)");
	lines.push("!MAXPLAYERSHOTS;MAXPLAYERSHOTS:  " + bp["MAXPLAYERSHOTS"]);
	lines.push("------------------------------");
	lines.push("!EXITNORTH;EXITNORTH:  " +
		bp["EXITNORTH"] + " " + ZZTLoader.getBoardName(bp["EXITNORTH"]));
	lines.push("!EXITSOUTH;EXITSOUTH:  " +
		bp["EXITSOUTH"] + " " + ZZTLoader.getBoardName(bp["EXITSOUTH"]));
	lines.push("!EXITEAST;EXITEAST:  " +
		bp["EXITEAST"] + " " + ZZTLoader.getBoardName(bp["EXITEAST"]));
	lines.push("!EXITWEST;EXITWEST:  " +
		bp["EXITWEST"] + " " + ZZTLoader.getBoardName(bp["EXITWEST"]));
	lines.push("------------------------------");

	// Write custom stuff
	var notIncludedKeys:Array = ["BOARDNAME", "SIZEX", "SIZEY", "ISDARK", "RESTARTONZAP",
		"TIMELIMIT", "MAXPLAYERSHOTS", "EXITNORTH", "EXITSOUTH", "EXITEAST", "EXITWEST"];
	var sortedKeys:Array = [];
	for (var s:String in bp)
	{
		if (notIncludedKeys.indexOf(s) == -1)
			sortedKeys.push(s);
	}
	sortedKeys = sortedKeys.sort(Array.CASEINSENSITIVE);

	for (var i:int = 0; i < sortedKeys.length; i++)
	{
		s = sortedKeys[i];
		lines.push("!" + s + ";" + s + ":  " + bp[s].toString());
	}

	lines.push("------------------------------");
	lines.push("!$JSONBOARDREGIONS;Edit regions using JSON");
	lines.push("!$JSONBOARDINFO;Edit board properties using JSON");

	showEditorScroll(lines, title, SM_BOARDINFO);
}

public static function showBoardScroll(point2Board:int=0):void {
	// Write standard stuff
	var title:String = "Choose Board";
	var lines:Array = [];

	var num:int = zzt.globalProps["NUMBOARDS"];
	for (var i:int = 0; i < num; i++) {
		var name:String =
			ZZTLoader.getBoardName(i, Boolean(boardSelectAction != BSA_SETBOARDPROP));
		lines.push("!" + i.toString() + ";" + i.toString() + ":  " + name);
	}

	lines.push("------------------------------");
	lines.push("!$ADDNEWBOARD;Add new board");

	showEditorScroll(lines, title, SM_BOARDSWITCH);
	zzt.msgScrollIndex = point2Board;
}

public static function showGuiManagerScroll():void {
	// Write standard stuff
	modFlag = true;
	var title:String = "Extra GUIs specific to world";
	var lines:Array = [];

	for (var k:String in ZZTLoader.extraGuis) {
		lines.push("!" + k + ";" + k);
	}

	lines.push("------------------------------");
	lines.push("!$ADDNEWGUI;Upload new GUI");

	showEditorScroll(lines, title, SM_EXTRAGUI);
}

public static function showWADManagerScroll():void {
	// Write standard stuff
	modFlag = true;
	var title:String = "Additional WAD lumps";
	var lines:Array = [];

	for (var i:int = 0; i < ZZTLoader.extraLumps.length; i++) {
		lines.push("!" + i.toString() + ";" + ZZTLoader.extraLumps[i].name +
			": size=" + ZZTLoader.extraLumps[i].len);
	}

	lines.push("------------------------------");
	lines.push("!$ADDNEWLUMP;Upload new WAD lump");

	showEditorScroll(lines, title, SM_EXTRAWAD);
}

// Show code editor interface.
public static function showCodeInterface(codeStr:String):void {
	modFlag = true;
	zzt.showPropTextView(zzt.MODE_ENTEREDITORPROP,
		(editedPropName == "$CODE") ? "SE Object Code" : ".HLP File Code", codeStr);
}

// Show tile info scroll.
public static function showTileScroll():void {
	// Write standard stuff
	var title:String = "Tile at (" + editorCursorX.toString() +
		"," + editorCursorY.toString() + ")";
	var lines:Array = [];

	var t:int = SE.getType(editorCursorX, editorCursorY);
	var c:int = SE.getColor(editorCursorX, editorCursorY);
	var se:SE = SE.getStatElemAt(editorCursorX, editorCursorY);
	var eInfo:ElementInfo = zzt.typeList[t];
	var fgName:String = utils.rstrip(getPrettyColorName(c & 15));
	var bgName:String = utils.rstrip(getPrettyColorName((c >> 4) & 7));
	var blink:String = Boolean((c & 128) != 0) ? ", Blinking" : "";

	lines.push("     Number: " + eInfo.NUMBER.toString() + "  Name:  " + eInfo.NAME);
	lines.push("!$TC" + c.toString() + ";Color: " + c.toString() +
		" " + fgName + " on " + bgName + blink);
	lines.push("------------------------------");

	if (se == null)
	{
		lines.push("     No status element");
		lines.push("------------------------------");
	}
	else
	{
		lines.push("     Status Element Info");
		lines.push("------------------------------");
		t = se.UNDERID;
		c = se.UNDERCOLOR;
		eInfo = zzt.typeList[t];
		fgName = utils.rstrip(getPrettyColorName(c & 15));
		bgName = utils.rstrip(getPrettyColorName((c >> 4) & 7));
		blink = Boolean((c & 128) != 0) ? ", Blinking" : "";

		lines.push("     UNDERID: " + eInfo.NUMBER.toString() + "  Name:  " + eInfo.NAME);
		lines.push("!$TU" + c.toString() + ";UNDERCOLOR: " + c.toString() +
			" " + fgName + " on " + bgName + blink);
		lines.push("!$EDITSTATELEM;Edit Status Element");
	}

	showEditorScroll(lines, title, SM_STATINFO);
}

// Show stat list scroll.
public static function showStatScroll():void {
	// Write standard stuff
	var title:String = "Status Element Ordering";
	var lines:Array = [];

	lines.push("------------------------------");
	for (var i:int = 0; i < SE.statElem.length; i++) {
		var se:SE = SE.statElem[i];
		var eInfo:ElementInfo = zzt.typeList[se.TYPE];
		lines.push("!" + i.toString() +
			";(" + se.X.toString() + "," + se.Y.toString() + ") " + eInfo.NAME);
	}

	lines.push("------------------------------");
	showEditorScroll(lines, title, SM_STATLIST);
}

// Extract uncompiled code from status element, if any.
public static function forceCodeStr(se:SE):void {
	if (!se.extra.hasOwnProperty("$CODE"))
	{
		se.extra["$CODE"] = "";
		if (se.extra.hasOwnProperty("CODEID"))
		{
			var unCompID:int = se.extra["CODEID"] - interp.numBuiltInCodeBlocksPlus;
			if (unCompID >= 0 && unCompID < interp.unCompCode.length)
			{
				// Inherit code from original source, if present
				se.extra["$CODE"] = utils.cr2lf(
					interp.unCompCode[unCompID].substr(interp.unCompStart[unCompID]));
			}
		}
	}
}

// Extract all uncompiled code from all status element in all boards.
public static function forceCodeStrAll():void {
	var numBoards:int = zzt.globalProps["NUMBOARDS"];
	for (var i:int = 0; i < numBoards; i++) {
		var bd:ZZTBoard = ZZTLoader.boardData[i];
		var bp:Object = bd.props;

		for (var j:int = 0; j < bd.statElem.length; j++)
		{
			// Ensure $CODE exists.
			var se:SE = bd.statElem[j];
			var eInfo:ElementInfo = zzt.typeList[se.TYPE];
			if (eInfo.HasOwnCode)
				forceCodeStr(se);
		}
	}
}

public static function redoUnCompCode():void {
	// Strip out non-built-in code blocks.
	var numBoards:int = zzt.globalProps["NUMBOARDS"];
	interp.zapRecord = new Vector.<ZapRecord>();
	interp.unCompCode = [];
	interp.unCompStart = new Vector.<int>();

	// Rebuild the code blocks.
	var unCompId:int = interp.numBuiltInCodeBlocksPlus;
	for (var i:int = 0; i < numBoards; i++) {
		var bd:ZZTBoard = ZZTLoader.boardData[i];
		var bp:Object = bd.props;
		var foundPlayer:Boolean = false;

		// Write status elements.
		for (var j:int = 0; j < bd.statElem.length; j++)
		{
			// Status element representing player is always first.
			var se:SE = bd.statElem[j];
			var eInfo:ElementInfo = zzt.typeList[se.TYPE];

			if (se.extra.hasOwnProperty("$CODE"))
			{
				se.extra["CODEID"] = unCompId++;
				var numPrefix:String = eInfo.NUMBER.toString() + "\n";
				interp.unCompCode.push(numPrefix + se.extra["$CODE"]);
				interp.unCompStart.push(numPrefix.length);
			}

			// Status element representing player is always first.
			if (eInfo.NUMBER == 4)
			{
				// The idea is that any PLAYER with CPY=0 is moved to
				// the first position.  Otherwise, the first player
				// found in the status element vector is moved to the
				// first position, even if CPY=1.  Note that no move
				// of CPY=1 PLAYERs will happen if a player had already
				// been moved there.
				if (se.extra["CPY"] == 0 || !foundPlayer)
				{
					foundPlayer = true;
					bd.statElem[j] = bd.statElem[0];
					bd.statElem[0] = se;
					bd.playerSE = se;
				}
			}
		}

		// The player in the first position (if it exists)
		// is automatically assumed to be CPY=0.
		if (foundPlayer)
			bd.statElem[0].extra["CPY"] = 0;
	}
}

// Open a scroll interface for status element editing.
public static function editStatElem():void {
	modFlag = true;
	var se:SE = immType[3];
	var eInfo:ElementInfo = zzt.typeList[se.TYPE];

	// Write standard stuff
	var title:String = "Edit " + eInfo.NAME;
	var lines:Array = [];
	lines.push("!CYCLE;CYCLE:  " + se.CYCLE.toString());

	if (se.extra.hasOwnProperty("$CODE"))
		lines.push("!$CODE;(Edit custom code)");

	lines.push("------------------------------");
	lines.push("!DIR;DIR:    " + getNamedStep(se.STEPX, se.STEPY));
	lines.push("!STEPX;STEPX:  " + se.STEPX.toString());
	lines.push("!STEPY;STEPY:  " + se.STEPY.toString());
	lines.push("------------------------------");

	// Write custom stuff
	var sortedKeys:Array = [];
	for (var s:String in se.extra)
	{
		if (s != "CODEID" && s != "$CODE")
			sortedKeys.push(s);
	}
	sortedKeys = sortedKeys.sort(Array.CASEINSENSITIVE);

	for (var i:int = 0; i < sortedKeys.length; i++)
	{
		s = sortedKeys[i];
		var extraDesc:String = "";
		switch (eInfo.NUMBER) {
			case 4:
				if (s == "CPY")
					extraDesc = " (=1 if player clone)";
				else if (s == "$DEADSMILEY")
					extraDesc = " (Dead if present)";
			break;
			case 11:
				if (s == "P3")
					extraDesc = " (Dest=" + ZZTLoader.getBoardName(se.extra[s], true) + ")";
			break;
			case 12:
				if (s == "P2")
					extraDesc = " (Dup. rate, 0-8)";
			break;
			case 13:
				if (s == "P1")
					extraDesc = " (Countdown; 0=inactive)";
			break;
			case 15:
				if (s == "P1")
					extraDesc = " (From:  0=player; 1=enemy)";
				else if (s == "P2")
					extraDesc = " (Lifetime; 0=max)";
			break;
			case 18:
				if (s == "P1")
					extraDesc = " (From:  0=player; 1=enemy)";
			break;
			case 29:
				if (s == "P1")
					extraDesc = " (Start interval, 0-8)";
				if (s == "P2")
					extraDesc = " (Period, 0-8)";
			break;
			case 34:
				if (s == "P1")
					extraDesc = " (Sensitivity, 0-8)";
			break;
			case 35:
				if (s == "P1")
					extraDesc = " (Intelligence, 0-8)";
				if (s == "P2")
					extraDesc = " (Rest time, 0-8)";
			break;
			case 37:
				if (s == "P2")
					extraDesc = " (Rate, 0-8)";
			break;
			case 38:
			case 41:
			case 62:
				if (s == "P1")
					extraDesc = " (Intelligence, 0-8)";
			break;
			case 39:
			case 42:
				if (s == "P1")
					extraDesc = " (Intelligence, 0-8)";
				if (s == "P2")
					extraDesc = " (Firing rate, 0-8; +128=stars)";
			break;
			case 44:
				if (s == "P1")
					extraDesc = " (Intelligence, 0-8)";
				if (s == "P2")
					extraDesc = " (Deviance, 0-8)";
			break;
			case 59:
			case 60:
			case 61:
				if (s == "P1")
					extraDesc = " (Intelligence, 0-8)";
				if (s == "P2")
					extraDesc = " (Switch Rate, 0-8)";
			break;
			default:
				if (s == "CHAR")
					extraDesc = " (" + String.fromCharCode(se.extra[s]) + ")";
			break;
		}

		lines.push("!" + s + ";" + s + ":  " + se.extra[s].toString() + extraDesc);
	}

	lines.push("------------------------------");
	lines.push("!$JSONSTATELEM;Edit using JSON");

	showEditorScroll(lines, title, SM_STATELEM);
}

// If special scroll keys are defined, handle them now.
public static function specialScrollKeys(theCode:int):void {
	if (scrollMode == SM_STATELEM)
	{
		if (theCode == 37)
			handleSideScroll(-1);
		else if (theCode == 39)
			handleSideScroll(1);
		else if (theCode == 46)
			handlePropDelete();
	}
	else if (scrollMode == SM_STATLIST)
	{
		if (theCode == 37)
			handleStatShift(-1);
		else if (theCode == 39)
			handleStatShift(1);
		else if (theCode == 46)
			handleStatDelete();
	}
	else if (scrollMode == SM_GLOBALS)
	{
		if (theCode == 46)
		{
			var fmt:String = zzt.msgScrollFormats[zzt.msgScrollIndex + zzt.mouseScrollOffset];
			if (zzt.globals.hasOwnProperty(fmt))
			{
				delete zzt.globals[fmt];
				showGlobalsScroll();
			}
		}
	}
	else if (scrollMode == SM_BOARDSWITCH)
	{
		if (theCode == 46)
		{
			fmt = zzt.msgScrollFormats[zzt.msgScrollIndex + zzt.mouseScrollOffset];
			deleteBoard(int(fmt));
		}
	}
	else if (scrollMode == SM_EXTRAGUI)
	{
		if (theCode == 46)
		{
			fmt = zzt.msgScrollFormats[zzt.msgScrollIndex + zzt.mouseScrollOffset];
			delete ZZTLoader.extraGuis[fmt];
			showGuiManagerScroll();
		}
	}
	else if (scrollMode == SM_EXTRAWAD)
	{
		if (theCode == 46)
		{
			fmt = zzt.msgScrollFormats[zzt.msgScrollIndex + zzt.mouseScrollOffset];
			ZZTLoader.extraLumps.splice(int(fmt), 1);
			ZZTLoader.extraLumpBinary.splice(int(fmt), 1);
			showWADManagerScroll();
		}
	}

	if (theCode == 27)
		handleClosedEditorScroll();
}

// Handle left/right incremental action during scroll interface
public static function handleSideScroll(dir:int):void {
	var fmt:String = zzt.msgScrollFormats[zzt.msgScrollIndex + zzt.mouseScrollOffset];
	if (fmt == "$" || fmt == "")
		return;

	var se:SE = immType[3];
	var d:int = 0;
	switch (fmt) {
		case "CYCLE":
			se.CYCLE = se.CYCLE + dir;
			if (se.CYCLE < 1)
				se.CYCLE = 1;
		break;
		case "DIR":
			d = interp.getDir4FromSteps(se.STEPX, se.STEPY) + dir;
			if (d < -1)
				d = 3;
			else if (d > 3)
				d = -1;
			if (d == -1)
			{
				se.STEPX = 0;
				se.STEPY = 0;
			}
			else
			{
				se.STEPX = interp.getStepXFromDir4(d);
				se.STEPY = interp.getStepYFromDir4(d);
			}
		break;
		case "STEPX":
			se.STEPX += dir;
		break;
		case "STEPY":
			se.STEPY += dir;
		break;
		case "P1":
		case "P2":
		case "P3":
		case "CHAR":
			se.extra[fmt] = (se.extra[fmt] + dir) & 255;
		break;
	}

	// Update type
	spotPlace(false, true);
	immType[0] = zzt.mg.getChar(editorCursorX - SE.CameraX + SE.vpX0 - 1,
		editorCursorY - SE.CameraY + SE.vpY0 - 1);
	immType[1] = zzt.mg.getAttr(editorCursorX - SE.CameraX + SE.vpX0 - 1,
		editorCursorY - SE.CameraY + SE.vpY0 - 1);
	add2BBuffer(false);
	drawEditorColorCursors();

	// Update scroll
	var oldScrollIdx:int = zzt.msgScrollIndex;
	editStatElem();
	zzt.msgScrollIndex = oldScrollIdx;
}

// Handle left/right SE shift action during scroll interface
public static function handleStatShift(dir:int):void {
	var fmt:String = zzt.msgScrollFormats[zzt.msgScrollIndex + zzt.mouseScrollOffset];
	if (fmt == "$" || fmt == "")
		return;

	// Get shift position; exit if unshiftable direction
	var i:int = int(fmt);
	var se:SE = SE.statElem[i];
	if (i == 0 && dir == -1)
		return;
	if (i == SE.statElem.length - 1 && dir == 1)
		return;

	// Swap the status element ordering
	var otherSE:SE = SE.statElem[i + dir];
	SE.statElem[i] = otherSE;
	SE.statElem[i + dir] = se;

	// Update scroll
	var oldScrollIdx:int = zzt.msgScrollIndex;
	showStatScroll();
	zzt.msgScrollIndex = oldScrollIdx;
}

// Handle property deletion action during scroll interface
public static function handlePropDelete():void {
	var fmt:String = zzt.msgScrollFormats[zzt.msgScrollIndex + zzt.mouseScrollOffset];
	if (fmt == "$" || fmt == "")
		return;

	var se:SE = immType[3];
	if (fmt == "$CODE" || fmt == "$JSONSTATELEM")
		; // Can't remove interfacial button
	else if (se.extra.hasOwnProperty(fmt))
	{
		var eInfo:ElementInfo = zzt.typeList[se.TYPE];
		if (eInfo.extraVals.hasOwnProperty(fmt))
		{
			// Can't remove--just set to zero
			se.extra[fmt] = 0;
		}
		else
		{
			// Remove item
			delete se.extra[fmt];
		}
	}

	updateStatTypeInScroll();
}

// Handle SE deletion action during scroll interface
public static function handleStatDelete():void {
	var fmt:String = zzt.msgScrollFormats[zzt.msgScrollIndex + zzt.mouseScrollOffset];
	if (fmt == "$" || fmt == "")
		return;

	// Delete
	var i:int = int(fmt);
	var se:SE = SE.statElem[i];
	se.FLAGS |= interp.FL_DEAD;
	killSE(se.X, se.Y);

	// Update scroll
	var oldScrollIdx:int = zzt.msgScrollIndex;
	showStatScroll();
	zzt.msgScrollIndex = oldScrollIdx;
}

public static function handleClosedEditorScroll():void {
	switch (scrollMode) {
		case SM_WORLDINFO:
		case SM_BOARDINFO:
		case SM_STATELEM:
		case SM_INVENTORYINFO:
		case SM_GLOBALS:
		case SM_WORLDTYPECHOICELOAD:
		case SM_EXTRAGUI:
		case SM_EXTRAWAD:
			zzt.mainMode = zzt.MODE_SCROLLCLOSE;
			zzt.establishGui(zzt.prefEditorGui);
			updateEditorView(true);
			cursorActive = true;
		break;
		case SM_CHAREDITLOAD:
		case SM_CHAREDITSAVE:
			zzt.mainMode = zzt.MODE_SCROLLCLOSE;
		break;
		case SM_WORLDTYPECHOICESAVE:
		case SM_TRANSFER:
			zzt.mainMode = zzt.MODE_NORM;
			zzt.titleGrid.visible = false;
			zzt.scrollGrid.visible = false;
			zzt.scrollArea.visible = false;
			cursorActive = true;
		break;
		case SM_BOARDSWITCH:
		case SM_STATINFO:
		case SM_UNDERCOLOR:
		case SM_STATLIST:
		case SM_OBJLIB:
			zzt.mainMode = zzt.MODE_SCROLLCLOSE;
			zzt.establishGui(zzt.prefEditorGui);
			updateEditorView(false);
			cursorActive = true;
		break;
	}

	scrollMode = 0;
}

// Create generalized editor scroll interface to display
public static function showEditorScroll(lines:Array, title:String, sMode:int):void {
	zzt.numTextLines = 0;
	zzt.msgScrollFormats = [];
	zzt.msgScrollText = [];
	zzt.msgScrollFiles = true;

	for (var i:int = 0; i < lines.length; i++) {
		var line:String = lines[i];
		if (line.charAt(0) == "!")
		{
			// Button link
			var txtStart:int = line.indexOf(";");
			var btnText:String = line.substring(1, txtStart);
			zzt.addMsgLine(btnText, line.substr(txtStart+1));
		}
		else
		{
			// Ordinary text
			zzt.addMsgLine("", line);
		}
	}

	// Initiate scroll
	scrollMode = sMode;
	zzt.ScrollMsg(title);
}

public static function scrollInterfaceButton(fmt:String):void {
	if (fmt == "$" || fmt == "")
	{
		handleClosedEditorScroll();
		return;
	}

	var se:SE = immType[3];
	var s:String = "";
	var i:int = 0;
	var sizeX:int = zzt.boardProps["SIZEX"];
	var sizeY:int = zzt.boardProps["SIZEY"];
	switch (scrollMode) {
		case SM_STATELEM:
			if (fmt == "$JSONSTATELEM")
				displayJSONProps(fmt);
			else if (fmt == "$CODE")
			{
				editedPropName = fmt;
				showCodeInterface(se.extra["$CODE"]);
			}
			else if (fmt == "CHAR")
			{
				// Character selection
				zzt.titleGrid.visible = false;
				zzt.scrollGrid.visible = false;
				zzt.scrollArea.visible = false;
				hexCodeValue = utils.int0(se.extra[fmt]);
				selectCharDialog(fmt);
			}
			else if (fmt == "P3" && zzt.typeList[se.TYPE].NUMBER == 11)
			{
				// Passage destination
				boardSelectAction = BSA_SETPASSAGEDEST;
				editedPropName = fmt;
				zzt.establishGui("ED_DELEDIT");
				zzt.drawGui();
				showBoardScroll(se.extra[fmt]);
			}
			else
			{
				switch (fmt) {
					case "DIR":
						s = interp.getDir4FromSteps(se.STEPX, se.STEPY).toString();
					break;
					case "CYCLE":
						s = se.CYCLE.toString();
					break;
					case "STEPX":
						s = se.STEPX.toString();
					break;
					case "STEPY":
						s = se.STEPY.toString();
					break;
					default:
						if (se.extra.hasOwnProperty(fmt))
							s = se.extra[fmt].toString();
					break;
				}

				editedPropName = fmt;
				zzt.drawGuiLabel("FILEMESSAGE", " " + fmt + ":");
				zzt.textEntry("FILEENTRY", s, 20, 15, "ED_STATVALUPDATE", "ED_STATVALCANCEL");
			}
		break;

		case SM_BOARDINFO:
			modFlag = true;
			if (fmt == "$JSONBOARDINFO" || fmt == "$JSONBOARDREGIONS")
				displayJSONProps(fmt);
			else if (fmt == "EXITNORTH" || fmt == "EXITSOUTH" ||
				fmt == "EXITEAST" || fmt == "EXITWEST")
			{
				boardSelectAction = BSA_SETBOARDPROP;
				editedPropName = fmt;
				zzt.establishGui("ED_DELEDIT");
				zzt.drawGui();
				showBoardScroll(zzt.boardProps[fmt]);
			}
			else
			{
				s = zzt.boardProps[fmt].toString();
				editedPropName = fmt;
				zzt.drawGuiLabel("FILEMESSAGE", " " + fmt + ":");
				zzt.textEntry("FILEENTRY", s, 20, 15, "ED_BOARDPROPUPDATE", "ED_BOARDPROPCANCEL");
			}
		break;

		case SM_WORLDINFO:
		case SM_INVENTORYINFO:
			modFlag = true;
			switch (fmt) {
				case "STARTBOARD":
					boardSelectAction = BSA_SETWORLDPROP;
					editedPropName = fmt;
					zzt.establishGui("ED_DELEDIT");
					zzt.drawGui();
					showBoardScroll(zzt.globalProps[fmt]);
				break;
				case "$INVPROP":
					showInventoryScroll();
				break;
				case "$GLOBALS":
					showGlobalsScroll();
				break;
				case "$JSONWORLDPROP":
				case "$JSONGLOBALS":
				case "$JSONTYPES":
				case "$JSONMASKS":
				case "$JSONSOUNDFX":
					displayJSONProps(fmt);
				break;
				case "$GUIMANAGER":
					zzt.establishGui("ED_DELEDIT");
					zzt.drawGui();
					showGuiManagerScroll();
				break;
				case "$WADMANAGER":
					zzt.establishGui("ED_DELEDIT");
					zzt.drawGui();
					showWADManagerScroll();
				break;
				default:
					s = zzt.globalProps[fmt].toString();
					editedPropName = fmt;
					zzt.drawGuiLabel("FILEMESSAGE", " " + fmt + ":");
					zzt.textEntry("FILEENTRY", s, 20, 15, "ED_WORLDPROPUPDATE", "ED_WORLDPROPCANCEL");
				break;
			}
		break;

		case SM_GLOBALS:
			modFlag = true;
			s = zzt.globals[fmt].toString();
			editedPropName = fmt;
			zzt.drawGuiLabel("FILEMESSAGE", " " + fmt + ":");
			zzt.textEntry("FILEENTRY", s, 20, 15, "ED_GLOBALSUPDATE", "ED_GLOBALSCANCEL");
		break;

		case SM_TRANSFER:
			modFlag = true;
			i = int(fmt);
			handleClosedEditorScroll();

			if (i == 0)
				parse.loadLocalFile("WAD", zzt.MODE_LOADTRANSFERWAD);
			else if (i == 1)
			{
				worldSaveType = -3;
				zzt.globalProps["WORLDTYPE"] = -3;
				zzt.globalProps["CODEDELIMETER"] = "\n";
				ZZTLoader.resetSEIDs();
				redoUnCompCode();
				if (ZZTLoader.saveWAD(".WAD", zzt.globalProps["BOARD"]))
					saveWorld("TEMP.WAD");
			}
		break;
		case SM_WORLDTYPECHOICELOAD:
			i = int(fmt);
			if (i == 0)
				parse.loadLocalFile("WAD", zzt.MODE_LOADWAD);
			else if (i == 1)
				parse.loadLocalFile("ZZT", zzt.MODE_NATIVELOADZZT);
			else if (i == 2)
				parse.loadLocalFile("SZT", zzt.MODE_NATIVELOADSZT);

			handleClosedEditorScroll();
		break;
		case SM_WORLDTYPECHOICESAVE:
			i = int(fmt);
			handleClosedEditorScroll();

			if (saveTest(i))
			{
				if (i == 0)
				{
					worldSaveType = -3;
					zzt.globalProps["WORLDTYPE"] = -3;
					zzt.globalProps["CODEDELIMETER"] = "\n";
					ZZTLoader.resetSEIDs();
					redoUnCompCode();
					if (ZZTLoader.saveWAD(".WAD"))
						saveWorld();
				}
				else if (!doSave(i))
					zzt.displayTextBrowser("Save Errors", errorMsgs + "\nUnable to save.",
						zzt.MTRANS_NORM);
				else if (errorMsgs != "")
					zzt.displayTextBrowser("Save Messages", errorMsgs + "\nEnd of Messages.",
						zzt.MTRANS_SAVEWORLD);
				else
					saveWorld();
			}
			else
				zzt.displayTextBrowser("Save Errors", errorMsgs + "\nUnable to save.",
					zzt.MTRANS_NORM);
		break;

		case SM_BOARDSWITCH:
			if (fmt == "$ADDNEWBOARD")
			{
				i = zzt.globalProps["NUMBOARDS"];
				addNewBoard();
			}
			else
				i = int(fmt);

			switch (boardSelectAction) {
				case BSA_SETBOARDPROP:
					zzt.boardProps[editedPropName] = i;
					zzt.establishGui("ED_SCROLLEDIT");
					zzt.drawGui();
					showBoardInfo();
				break;
				case BSA_SETWORLDPROP:
					zzt.globalProps[editedPropName] = i;
					zzt.establishGui("ED_SCROLLEDIT");
					zzt.drawGui();
					showWorldInfo();
				break;
				case BSA_SETPASSAGEDEST:
					se.extra[editedPropName] = i;
					zzt.establishGui("ED_STATEDIT");
					zzt.drawGui();
					updateStatTypeInScroll();
					drawEditorPatternCursor();
					drawEditorColorCursors();
				break;
				case BSA_SWITCHBOARD:
					// Switch board
					ZZTLoader.registerBoardState(true);
					ZZTLoader.updateContFromBoard(i, ZZTLoader.boardData[i]);
					SE.IsDark = 0;
					boardWidth = zzt.boardProps["SIZEX"];
					boardHeight = zzt.boardProps["SIZEY"];
					if (boardWidth != sizeX || boardHeight != sizeY)
					{
						editorCursorX = 1;
						editorCursorY = 1;
						SE.CameraX = 1;
						SE.CameraY = 1;
					}

					handleClosedEditorScroll();
				break;
			};
		break;

		case SM_STATINFO:
		case SM_UNDERCOLOR:
			if (utils.startswith(fmt, "$TC"))
			{
				i = int(fmt.substr(3));
				fgColorCursor = i & 15;
				bgColorCursor = (i >> 4) & 7;
				blinkFlag = Boolean((i & 128) != 0);
				zzt.titleGrid.visible = false;
				zzt.scrollGrid.visible = false;
				zzt.scrollArea.visible = false;
				dispatchEditorMenu("ED_KOLOR");
			}
			else if (utils.startswith(fmt, "$TU"))
			{
				scrollMode = SM_UNDERCOLOR;
				i = int(fmt.substr(3));
				fgColorCursor = i & 15;
				bgColorCursor = (i >> 4) & 7;
				blinkFlag = Boolean((i & 128) != 0);
				zzt.titleGrid.visible = false;
				zzt.scrollGrid.visible = false;
				zzt.scrollArea.visible = false;
				dispatchEditorMenu("ED_KOLOR");
			}
			else if (fmt == "$EDITSTATELEM")
			{
				dispatchEditorMenu("ED_PICKUP");
			}
		break;
		case SM_STATLIST:
			i = int(fmt);
			se = SE.statElem[i];
			editorCursorX = se.X;
			editorCursorY = se.Y;
			dispatchEditorMenu("ED_PICKUP");
		break;

		case SM_OBJLIB:
			modFlag = true;
			if (fmt == "$PLACEALL")
			{
				for (i = 0; i < objLibraryBuffer.length; i++)
					placeObjLibraryAt(1 + i, 1, i);
			}
			else
				placeObjLibraryAt(editorCursorX, editorCursorY, int(fmt));

			handleClosedEditorScroll();
		break;

		case SM_EXTRAGUI:
			modFlag = true;
			if (fmt == "$ADDNEWGUI")
			{
				parse.loadLocalFile("ZZTGUI", zzt.MODE_LOADEXTRAGUI);
				handleClosedEditorScroll();
			}
			else if (ZZTLoader.extraGuis.hasOwnProperty(fmt))
			{
				parse.saveLocalFile(".ZZTGUI", zzt.MODE_NORM, zzt.MODE_NORM,
					parse.jsonToText(ZZTLoader.extraGuis[fmt]));
				handleClosedEditorScroll();
			}
			else
				handleClosedEditorScroll();
		break;

		case SM_EXTRAWAD:
			modFlag = true;
			if (fmt == "$ADDNEWLUMP")
			{
				parse.loadLocalFile("ALL", zzt.MODE_LOADEXTRALUMP);
				handleClosedEditorScroll();
			}
			else if (int(fmt) < ZZTLoader.extraLumps.length)
			{
				parse.saveLocalFile("untitled", zzt.MODE_NORM, zzt.MODE_NORM,
					ZZTLoader.extraLumpBinary[int(fmt)]);
				handleClosedEditorScroll();
			}
			else
				handleClosedEditorScroll();
		break;

		case SM_CHAREDITLOAD:
			if (fmt == "CE_LOADMASK")
			{
				zzt.textEntry("CONFMESSAGE", "", 8, 15, "CE_LOADMASKYES", "CE_LOADSAVECANCEL");
			}
			else if (fmt == "CE_LOADFILE")
			{
				parse.loadLocalFile("ALL", zzt.MODE_LOADCHAREDITFILE);
				handleClosedEditorScroll();
			}
		break;
		case SM_CHAREDITSAVE:
			if (fmt == "CE_SAVEMASK")
			{
				zzt.textEntry("CONFMESSAGE", "", 8, 15, "CE_SAVEMASKYES", "CE_LOADSAVECANCEL");
			}
			else if (fmt == "CE_SAVELUMP")
			{
				zzt.textEntry("CONFMESSAGE", "", 8, 15, "CE_SAVELUMPYES", "CE_LOADSAVECANCEL");
			}
			else if (fmt == "CE_SAVEFILE")
			{
				parse.saveLocalFile("ALL", zzt.MODE_NORM, zzt.MODE_NORM,
					interp.makeBitSequence(interp.getFlatSequence(ceStorage)));
				handleClosedEditorScroll();
			}
		break;
	}
}

public static function placeObjLibraryAt(x:int, y:int, i:int):void {
	// Erase previous
	killSE(x, y);
	SE.setType(x, y, 0);

	// Place new type
	var obj:Object = objLibraryBuffer[i];
	var se:SE = new SE(zzt.objectType, x, y, obj["COLOR"]);

	se.CYCLE = obj["CYCLE"];
	se.STEPX = obj["STEPX"];
	se.STEPY = obj["STEPY"];
	se.extra["CHAR"] = obj["CHAR"];
	se.extra["$CODE"] = obj["$CODE"];

	SE.setStatElemAt(x, y, se);
	SE.statElem.push(se);
}

public static function selectCharDialog(fmt:String=""):void {
	editedPropName = fmt;
	cursorActive = false;
	zzt.mainMode = zzt.MODE_CHARSEL;
	zzt.establishGui("ED_CHARS");

	for (var y:int = 1; y <= 8; y++) {
		zzt.GuiTextLines[y] = String.fromCharCode(179);
		for (var x:int = 1; x <= 32; x++) {
			zzt.GuiTextLines[y] += String.fromCharCode((y-1) * 32 + (x-1));
		}
		zzt.GuiTextLines[y] += String.fromCharCode(179);
	}

	zzt.drawGui();
	drawCharCursor(true);
}

// Update status element with typed value
public static function updateStatVal():void {
	modFlag = true;
	var fmt:String = editedPropName;
	var val:String = zzt.textChars;
	var se:SE = immType[3];

	var testInt:int;
	switch (fmt) {
		case "DIR":
			se.STEPX = interp.getStepXFromDir4(utils.int0(val));
			se.STEPY = interp.getStepYFromDir4(utils.int0(val));
		break;
		case "CYCLE":
			se.CYCLE = utils.int0(val);
			if (se.CYCLE < 1)
				se.CYCLE = 1;
		break;
		case "STEPX":
			se.STEPX = utils.int0(val);
		break;
		case "STEPY":
			se.STEPY = utils.int0(val);
		break;
		default:
			// Store as integer only if resembles an integer
			testInt = utils.int0(val);
			if (testInt.toString() != val)
				se.extra[fmt] = val;
			else
				se.extra[fmt] = testInt;
		break;
	}

	updateStatTypeInScroll();
}

// Update board property with typed value
public static function updateBoardProp():void {
	var fmt:String = editedPropName;
	var val:String = zzt.textChars;

	var bd:ZZTBoard = ZZTLoader.boardData[zzt.globalProps["BOARD"]];
	var oldSizeX:int = zzt.boardProps["SIZEX"];
	var oldSizeY:int = zzt.boardProps["SIZEY"];
	var testInt:int = utils.int0(val);
	switch (fmt) {
		case "SIZEX":
		case "SIZEY":
			// Board size change needs to be realistic; keep cursor valid
			if (testInt < 1)
				testInt = 1;
			editorCursorX = 1;
			editorCursorY = 1;
			zzt.boardProps[fmt] = testInt;
			if (zzt.boardProps["SIZEX"] * zzt.boardProps["SIZEY"] > 65536)
			{
				// Max tile limit reached; clip sizes
				zzt.boardProps["SIZEX"] = 60;
				zzt.boardProps["SIZEY"] = 25;
			}
			boardWidth = zzt.boardProps["SIZEX"];
			boardHeight = zzt.boardProps["SIZEY"];

			// We need to do some buffer size juggling; revert size back to old
			// so that we can write back the current grid to a buffer with a
			// different stride than before.
			bd.typeBuffer.length = boardWidth * boardHeight;
			bd.colorBuffer.length = boardWidth * boardHeight;
			bd.lightBuffer.length = boardWidth * boardHeight;
			zzt.boardProps["SIZEX"] = oldSizeX;
			zzt.boardProps["SIZEY"] = oldSizeY;
			ZZTLoader.ensureGridSpace(boardWidth, boardHeight);
			ZZTLoader.registerBoardState(true, boardWidth, boardHeight);

			// Set new size and reconstitute border
			zzt.boardProps["SIZEX"] = boardWidth;
			zzt.boardProps["SIZEY"] = boardHeight;
			ZZTLoader.updateContFromBoard(zzt.globalProps["BOARD"], bd);
			updateEditorView(false);
		break;
		default:
			// Store as integer only if resembles an integer
			if (testInt.toString() != val)
				zzt.boardProps[fmt] = val;
			else
				zzt.boardProps[fmt] = testInt;
		break;
	}

	// Update scroll
	SE.IsDark = 0;
	var oldScrollIdx:int = zzt.msgScrollIndex;
	showBoardInfo();
	zzt.msgScrollIndex = oldScrollIdx;
}

// Update world property with typed value
public static function updateWorldProp():void {
	var fmt:String = editedPropName;
	var val:String = zzt.textChars;

	// Store as integer only if resembles an integer
	var testInt:int = utils.int0(val);
	if (testInt.toString() != val)
		zzt.globalProps[fmt] = val;
	else
		zzt.globalProps[fmt] = testInt;

	// Update scroll
	var oldScrollIdx:int = zzt.msgScrollIndex;
	if (scrollMode == SM_INVENTORYINFO)
		showInventoryScroll();
	else
		showWorldInfo();

	zzt.msgScrollIndex = oldScrollIdx;
}

public static function updateGlobals():void {
	var fmt:String = editedPropName;
	var val:String = zzt.textChars;

	// Store as integer only if resembles an integer
	var testInt:int = utils.int0(val);
	if (testInt.toString() != val)
		zzt.globals[fmt] = val;
	else
		zzt.globals[fmt] = testInt;

	// Update scroll
	var oldScrollIdx:int = zzt.msgScrollIndex;
	showGlobalsScroll();
	zzt.msgScrollIndex = oldScrollIdx;
}

public static function updateStatTypeInScroll():void {
	// Update type
	spotPlace(false, true);
	var se:SE = SE.getStatElemAt(editorCursorX, editorCursorY);
	se.UNDERID = immType[3].UNDERID;
	se.UNDERCOLOR = immType[3].UNDERCOLOR;

	immType[0] = zzt.mg.getChar(editorCursorX - SE.CameraX + SE.vpX0 - 1,
		editorCursorY - SE.CameraY + SE.vpY0 - 1);
	immType[1] = zzt.mg.getAttr(editorCursorX - SE.CameraX + SE.vpX0 - 1,
		editorCursorY - SE.CameraY + SE.vpY0 - 1);
	add2BBuffer(false);
	drawEditorColorCursors();

	// Update scroll
	var oldScrollIdx:int = zzt.msgScrollIndex;
	editStatElem();
	zzt.msgScrollIndex = oldScrollIdx;
}

// Load contents of object library into board
public static function loadZZL():void {
	// Get text of file
	var s:String = parse.fileData.readUTFBytes(parse.fileData.length);
	var lines:Array = s.split("\n");

	// Initialize
	var inDef:Boolean = false;
	var libName:String = "";
	var descLines:Array = [];
	var numLines:int = 0;
	var linesRead:int = 0;
	var objs:Array = [];
	var curObj:Object = new Object();

	// Parse lines
	for (var i:int = 0; i < lines.length; i++) {
		// Trim CR if present
		var line:String = lines[i];
		if (line.charCodeAt(line.length - 1) == 13)
			line = line.substr(0, line.length - 1);

		if (i == 0)
			libName = line; // Library name
		else if (inDef)
		{
			// Code line of definition
			curObj["$CODE"] += line + "\n";
			if (++linesRead >= numLines)
			{
				// Done with definition
				inDef = false;
				objs.push(curObj);
				curObj = new Object();
			}
		}
		else if (line.length == 0)
			; // Do nothing
		else if (!inDef && line.charAt(0) == "*")
			descLines.push(line.substr(1)); // Descriptive text
		else
		{
			// Start definition
			inDef = true;
			curObj["OfficialName"] = line;

			var attrs:Array = lines[++i].split(",");
			numLines = int(utils.rstrip(attrs[0]));
			linesRead = 0;

			curObj["CHAR"] = int(attrs[1]);
			var fg:int = int(attrs[2]) & 15;
			var bg:int = int(attrs[3]);
			curObj["COLOR"] = fg + bg * 16 + (fg > 15 ? 128 : 0);
			curObj["STEPX"] = int(attrs[4]);
			curObj["STEPY"] = int(attrs[5]);
			curObj["CYCLE"] = int(attrs[6]);
			curObj["$CODE"] = "";
		}
	}

	// Show scroll of all objects.
	var title:String = "Object Library";
	lines = [];
	lines.push(libName);
	lines.push("------------------------------");
	lines.push("!$PLACEALL;Place all in 1st row");
	lines.push("------------------------------");
	for (i = 0; i < objs.length; i++) {
		lines.push("!" + i.toString() + ";" + objs[i]["OfficialName"]);
	}

	objLibraryBuffer = objs;
	showEditorScroll(lines, title, SM_OBJLIB);
}

public static function uploadExtraGui():void {
	// Upload GUI file into extras.
	var jObj:Object = parse.jsonDecode(parse.fileData.toString());
	if (jObj != null)
	{
		var k:String = parse.lastFileName;
		if (utils.endswith(k, ".ZZTGUI"))
			k = k.substr(0, k.length - 7);

		ZZTLoader.extraGuis[k] = jObj;
	}

	showGuiManagerScroll();
}

public static function uploadExtraLump(backToWADManager:Boolean=true):void {
	// Upload file into extra WAD lumps.
	var ba:ByteArray = parse.fileData;
	if (ba != null)
	{
		// Extra lump name from filename; mold into 8-byte uppercase.
		var lName:String = parse.lastFileName.toUpperCase();

		// No extension
		var idx:int = lName.indexOf(".");
		if (idx != -1)
			lName = lName.substr(0, idx);

		// Space-padded at right; 8-byte limit
		lName += "        ";
		if (lName.length > 8)
			lName = lName.substr(0, 8);

		// Cannot match any native lump name
		if (ZZTLoader.isNativeLump(lName))
			lName = lName.substr(0, 7) + "_";

		// Add to extras (offset is meaningless until file write occurs)
		ZZTLoader.extraLumps.push(new Lump(0, ba.length, lName));
		ZZTLoader.extraLumpBinary.push(ba);
	}

	if (backToWADManager)
		showWADManagerScroll();
}

public static function showTransferScroll():void {
	// Show scroll of transfer choices.
	var title:String = "Transfer board";
	var lines:Array = [];
	lines.push("!0;Import Board from WAD");
	lines.push("!1;Export Board to WAD");

	showEditorScroll(lines, title, SM_TRANSFER);
}

public static function loadWorldScroll():void {
	// Show scroll of world choices.
	var title:String = "Load World File";
	var lines:Array = [];
	lines.push("!0;WAD (ZZT Ultra)");
	lines.push("!1;ZZT (Original ZZT)");
	lines.push("!2;SZT (Super ZZT)");

	showEditorScroll(lines, title, SM_WORLDTYPECHOICELOAD);
}

public static function saveWorldScroll():void {
	// Show scroll of world choices.
	var title:String = "Save World File As...";
	var lines:Array = [];
	lines.push("!0;WAD (ZZT Ultra)");
	lines.push("!1;ZZT (Original ZZT)");
	lines.push("!2;SZT (Super ZZT)");

	showEditorScroll(lines, title, SM_WORLDTYPECHOICESAVE);
	if (zzt.globalProps["WORLDTYPE"] == -1)
		zzt.msgScrollIndex = 1;
	else if (zzt.globalProps["WORLDTYPE"] == -2)
		zzt.msgScrollIndex = 2;
}

// Register error message during save
public static function regErrorMsg(errStr:String):void {
	errorMsgs += "ERROR:  " + errStr + "\n";
}

// Register warning message during save
public static function regWarningMsg(errStr:String):void {
	errorMsgs += "Warning:  " + errStr + "\n";
}

// Register info message during save
public static function regInfoMsg(errStr:String):void {
	errorMsgs += errStr + "\n";
}

// Register error if value is out of range
public static function errorIfOutOfRange(name:String, val:int, lower:int, upper:int):void {
	if (val < lower || val > upper)
		regErrorMsg(name + " is out of the range [" + lower + ", " + upper + "].");
}

// Register warning if value is out of range
public static function warningIfOutOfRange(name:String, val:int, lower:int, upper:int):void {
	if (val < lower || val > upper)
		regWarningMsg(name + " should be in range [" + lower + ", " + upper + "].");
}

// Write a Pascal-style string with appropriate blank-filled size.
public static function writePascalString(wBuf:ByteArray, name:String, val:String, maxLen:int):void {
	var actualLen:int = val.length;
	if (actualLen > maxLen)
	{
		actualLen = maxLen;
		regWarningMsg(name + " length is > " + maxLen + " chars; will be clipped.");
	}

	// Write length and string.
	wBuf.writeByte(actualLen);
	wBuf.writeUTFBytes(val.substr(0, actualLen));

	// Blank-fill the padding at the end.
	for (; actualLen < maxLen; actualLen++)
		wBuf.writeByte(32);
}

// Write a constant-byte run of bytes.
public static function writeConstantByte(wBuf:ByteArray, val:int, len:int):void {
	while (len-- > 0)
		wBuf.writeByte(val);
}

// Conduct a series of tests for the file to ensure that saving would
// work with the target format.
public static function saveTest(sType:int):Boolean {
	// Register current board state; capture edits.
	errorMsgs = "";
	ZZTLoader.registerBoardState(true);
	if (sType == 0)
		return true; // Native WAD format; always succeeds

	// Get format code and bounding parameters
	var wType:int = -1;
	var baseSizeX:int = 60;
	var baseSizeY:int = 25;
	var baseOffset:int = 512;
	var flagLimit:int = 10;
	var statLimit:int = 151;
	if (sType == 2) {
		wType = -2;
		baseSizeX = 96;
		baseSizeY = 80;
		baseOffset = 1024;
		flagLimit = 16;
		statLimit = 129;
	}

	// Test if global variables will work.
	var varCount:int = 0;
	for (var k:String in zzt.globals) {
		if (k.charAt(0) != "$")
			varCount++;
	}

	if (varCount > flagLimit)
		regErrorMsg("Number of flags would be " + varCount + "; max is " + flagLimit);

	// Test if world properties will work.
	var numBoards:int = zzt.globalProps["NUMBOARDS"];
	errorIfOutOfRange("NUMBOARDS", numBoards, 1, 255);
	errorIfOutOfRange("STARTBOARD", zzt.globalProps["STARTBOARD"], 0, numBoards - 1);
	errorIfOutOfRange("AMMO", zzt.globalProps["AMMO"], 0, 32767);
	errorIfOutOfRange("GEMS", zzt.globalProps["GEMS"], 0, 32767);
	errorIfOutOfRange("TORCHES", zzt.globalProps["TORCHES"], 0, 32767);
	errorIfOutOfRange("HEALTH", zzt.globalProps["HEALTH"], 0, 32767);
	errorIfOutOfRange("SCORE", zzt.globalProps["SCORE"], -32768, 32767);
	errorIfOutOfRange("TIME", zzt.globalProps["TIME"], 0, 32767);
	errorIfOutOfRange("Z", zzt.globalProps["Z"], -32768, 32767);
	errorIfOutOfRange("TORCHCYCLES", zzt.globalProps["TORCHCYCLES"], 0, 32767);
	errorIfOutOfRange("ENERGIZERCYCLES", zzt.globalProps["ENERGIZERCYCLES"], 0, 32767);

	// Test if all board sizes and properties will work.
	for (var i:int = 0; i < numBoards; i++) {
		var bd:ZZTBoard = ZZTLoader.boardData[i];
		var bp:Object = bd.props;

		if (bp["SIZEX"] != baseSizeX || bp["SIZEY"] != baseSizeY)
			regErrorMsg("Board " + bp["BOARDNAME"] + " has invalid dimensions.");

		errorIfOutOfRange("MAXPLAYERSHOTS", bp["MAXPLAYERSHOTS"], 0, 255);
		errorIfOutOfRange("CURPLAYERSHOTS", bp["CURPLAYERSHOTS"], 0, 255);
		errorIfOutOfRange("ISDARK", bp["ISDARK"], 0, 1);
		errorIfOutOfRange("EXITNORTH", bp["EXITNORTH"], 0, numBoards - 1);
		errorIfOutOfRange("EXITSOUTH", bp["EXITSOUTH"], 0, numBoards - 1);
		errorIfOutOfRange("EXITWEST", bp["EXITWEST"], 0, numBoards - 1);
		errorIfOutOfRange("EXITEAST", bp["EXITEAST"], 0, numBoards - 1);
		errorIfOutOfRange("RESTARTONZAP", bp["RESTARTONZAP"], 0, 1);
		errorIfOutOfRange("TIMELIMIT", bp["TIMELIMIT"], 0, 65535);

		if (bd.statElem.length > statLimit)
			regErrorMsg("Status element count is " + bd.statElem.length +
				"; max is " + statLimit);

		// Search status elements
		var hasPlayer:Boolean = false;
		for (var j:int = 0; j < bd.statElem.length; j++) {
			var se:SE = bd.statElem[j];

			if (se.X <= 0 || se.Y <= 0 || se.X > baseSizeX || se.Y > baseSizeY)
				regErrorMsg("Off-grid status element:  " + se.X + "," + se.Y);

			if (zzt.typeList[se.TYPE].NUMBER == 4)
				hasPlayer = true;
		}

		if (!hasPlayer)
			regErrorMsg("Board " + bp["BOARDNAME"] + " has no PLAYER.");
	}

	return Boolean(errorMsgs == "");
}

// Find status element matching X and Y from cursor.
public static function getStatElemAtCursor(statElem:Vector.<SE>, csr:int, baseSizeX:int):SE {
	var x:int = csr % baseSizeX;
	var y:int = int((csr - x) / baseSizeX);

	for (var i:int = 0; i < statElem.length; i++) {
		if (statElem[i].X == x + 1 && statElem[i].Y == y + 1)
			return statElem[i];
	}

	// Should not happen in theory...unless passage SE is missing.
	return null;
}

// Perform actual save in target format.
public static function doSave(sType:int):Boolean {
	errorMsgs = "";
	sBuffer = new ByteArray();
	sBuffer.endian = Endian.LITTLE_ENDIAN;

	// Get format code and bounding parameters
	var wType:int = -3;
	var baseSizeX:int = 60;
	var baseSizeY:int = 25;
	var baseOffset:int = 512;
	var flagLimit:int = 10;
	if (sType == 1)
		wType = -1;
	else if (sType == 2)
	{
		wType = -2;
		baseSizeX = 96;
		baseSizeY = 80;
		baseOffset = 1024;
		flagLimit = 16;
	}

	// World header and properties
	sBuffer.writeShort(wType);
	var numBoards:int = zzt.globalProps["NUMBOARDS"];
	sBuffer.writeShort(numBoards - 1);
	sBuffer.writeShort(zzt.globalProps["AMMO"]);
	sBuffer.writeShort(zzt.globalProps["GEMS"]);

	for (var i:int = 0; i < 7; i++) {
		var keyStr:String = "KEY" + (i + 9).toString();
		sBuffer.writeByte(zzt.globalProps[keyStr]);
		warningIfOutOfRange(keyStr, zzt.globalProps[keyStr], 0, 1);
	}

	sBuffer.writeShort(zzt.globalProps["HEALTH"]);
	if (zzt.globalProps["HEALTH"] <= 0)
		regWarningMsg("HEALTH is <= 0; player will start 'dead.'");
	sBuffer.writeShort(zzt.globalProps["STARTBOARD"]);

	if (wType == -1)
	{
		sBuffer.writeShort(zzt.globalProps["TORCHES"]);
		sBuffer.writeShort(zzt.globalProps["TORCHCYCLES"]);
		sBuffer.writeShort(zzt.globalProps["ENERGIZERCYCLES"]);
		sBuffer.writeShort(0); // Unused
		sBuffer.writeShort(zzt.globalProps["SCORE"]);
	}
	else
	{
		sBuffer.writeShort(0); // Unused
		sBuffer.writeShort(zzt.globalProps["SCORE"]);
		sBuffer.writeShort(0); // Unused
		sBuffer.writeShort(zzt.globalProps["ENERGIZERCYCLES"]);
	}

	writePascalString(sBuffer, "WORLDNAME", zzt.globalProps["WORLDNAME"], 20);

	// Global variables (flags)
	var secretLoc:int = -1;
	var flagsWritten:int = 0;
	i = 0;
	for (var k:String in zzt.globals) {
		if (k.charAt(0) != "$")
		{
			if (k == "SECRET" && zzt.globals[k] != 0)
			{
				regInfoMsg("SECRET flag detected; will be moved to position 0.");
				secretLoc = i;
			}
			i++;
		}
	}

	if (secretLoc != -1)
	{
		writePascalString(sBuffer, "SECRET", "SECRET", 20);
		flagsWritten++;
	}

	for (k in zzt.globals) {
		if (k.charAt(0) != "$" && k != "SECRET" && zzt.globals[k] != 0)
		{
			if (zzt.globals[k] != 1)
				regWarningMsg(k + " flag is not 1; results may be undefined.");
			writePascalString(sBuffer, k, k, 20);
			flagsWritten++;
		}
	}

	while (flagsWritten < flagLimit)
	{
		writePascalString(sBuffer, "", "", 20);
		flagsWritten++;
	}

	// Remaining world properties
	if (wType == -1)
	{
		sBuffer.writeShort(zzt.globalProps["TIME"]);
		sBuffer.writeShort(0); // "Player data"
		sBuffer.writeByte(zzt.globalProps["LOCKED"]);
	}
	else
	{
		sBuffer.writeShort(zzt.globalProps["TIME"]);
		sBuffer.writeShort(0); // "Player data"
		sBuffer.writeByte(zzt.globalProps["LOCKED"]);
		sBuffer.writeShort(zzt.globalProps["Z"]);
	}

	// Pad to base offset
	writeConstantByte(sBuffer, 0, baseOffset - sBuffer.length);

	// Handle individual boards.
	var se:SE;
	for (i = 0; i < numBoards; i++) {
		var bd:ZZTBoard = ZZTLoader.boardData[i];
		var bp:Object = bd.props;

		var bBuffer:ByteArray = new ByteArray();
		bBuffer.endian = Endian.LITTLE_ENDIAN;
		bBuffer.writeShort(0); // Size will need to be updated later.

		writePascalString(bBuffer, "BOARDNAME", bp["BOARDNAME"], (wType == -1) ? 50 : 60);

		// Pack RLE data.
		var totalSquares:int = baseSizeX * baseSizeY;
		for (var c:int = 0; c < totalSquares;)
		{
			var count:int = 1;
			var typ:int = bd.typeBuffer[c];
			var col:int = bd.colorBuffer[c];
			while (++c < totalSquares) {
				if (typ == bd.typeBuffer[c] && col == bd.colorBuffer[c])
				{
					if (++count >= 255)
					{
						c++;
						break;
					}
				}
				else
					break;
			}

			var num:int = zzt.typeList[typ].NUMBER;
			switch (num) {
				// Special messages
				case 2:
				case 3:
					regWarningMsg("Type " + zzt.typeList[typ].NAME +
						" is uncommon; risky to use.");
				break;
				case 6:
				case 38:
					if (wType == -2)
						regWarningMsg("Type " + zzt.typeList[typ].NAME +
							" is undefined in SZT format.");
				break;
				case 47:
				case 48:
				case 49:
				case 50:
				case 51:
				case 59:
				case 60:
				case 61:
				case 62:
				case 63:
				case 64:
					if (wType == -1)
						regWarningMsg("Type " + zzt.typeList[typ].NAME +
							" is undefined in ZZT format.");
				break;

				// Type translation
				case 15:
					if (wType == -2)
						num = 72;
				break;
				case 18:
					if (wType == -2)
						num = 69;
				break;
				case 33:
					if (wType == -2)
						num = 70;
				break;
				case 43:
					if (wType == -2)
						num = 71;
				break;
				case 73:
				case 74:
				case 75:
				case 76:
				case 77:
				case 78:
				case 79:
					if (wType == -1)
						num = num + (47 - 73);
				break;

				// Color translation
				case 9:
					// Invert door FG and BG
					col = ((col >> 4) & 15) + (((col ^ 8) << 4) & 240);
				break;
				case 11:
					// Process passage colors
					se = getStatElemAtCursor(bd.statElem, c - 1, baseSizeX);
					if (se.extra["P2"] & 15 == 15)
						col = (col & 7) * 16 + 15;
					else
						col = se.extra["P2"];
				break;

				// Unmappable types
				default:
					if (typ >= interp.numBuiltInTypes)
						regWarningMsg("Type " + zzt.typeList[typ].NAME +
							" is undefined outside of ZZT Ultra.");
				break;
			}

			bBuffer.writeByte(count & 255);
			bBuffer.writeByte(num);
			bBuffer.writeByte(col);
		}

		// Status element accounting.
		var playerPos:int = -1;
		var sCoords:Vector.<IPoint> = new Vector.<IPoint>();

		for (var j:int = 0; j < bd.statElem.length; j++)
		{
			se = bd.statElem[j];
			var eInfo:ElementInfo = zzt.typeList[se.TYPE];

			for (var ci:int = 0; ci < sCoords.length; ci++)
			{
				if (sCoords[ci].x == se.X && sCoords[ci].y == se.Y)
					regWarningMsg("Double status element at (" + se.X + ", " + se.Y + ").");
			}
			sCoords.push(new IPoint(se.X, se.Y));

			if (eInfo.NUMBER == 4)
			{
				// Establish which player is the "real" player.
				if (playerPos != -1 || se.extra["CPY"] == 0)
				{
					bp["PLAYERENTERX"] = se.X;
					bp["PLAYERENTERY"] = se.Y;
					playerPos = j;
				}
			}
		}

		// Board properties.
		bBuffer.writeByte(bp["MAXPLAYERSHOTS"]);
		if (wType == -1)
			bBuffer.writeByte(bp["ISDARK"]);
		bBuffer.writeByte(bp["EXITNORTH"]);
		bBuffer.writeByte(bp["EXITSOUTH"]);
		bBuffer.writeByte(bp["EXITWEST"]);
		bBuffer.writeByte(bp["EXITEAST"]);
		bBuffer.writeByte(bp["RESTARTONZAP"]);

		if (wType == -1)
			writePascalString(bBuffer, "MESSAGE", bp["MESSAGE"], 58);

		bBuffer.writeByte(bp["PLAYERENTERX"]);
		bBuffer.writeByte(bp["PLAYERENTERY"]);

		if (wType == -2)
		{
			bBuffer.writeShort(bp["CAMERAX"]);
			bBuffer.writeShort(bp["CAMERAY"]);
		}

		bBuffer.writeShort(bp["TIMELIMIT"]);

		if (wType == -1)
			writeConstantByte(bBuffer, 0, 16);
		else
			writeConstantByte(bBuffer, 0, 14);

		var seLenPos:int = bBuffer.length;
		var seLen:int = bd.statElem.length - 1;
		bBuffer.writeShort(seLen);

		// Write status elements.
		for (j = 0; j < bd.statElem.length; j++)
		{
			// Status element representing player is always first.
			se = bd.statElem[j];
			if (j == 0 && playerPos != -1)
				se = bd.statElem[playerPos];
			else if (j == playerPos)
				se = bd.statElem[0];

			eInfo = zzt.typeList[se.TYPE];

			// Skip "dead" smileys; these do not have status elements.
			if (eInfo.NUMBER == 4 && se.extra.hasOwnProperty("$DEADSMILEY"))
			{
				regInfoMsg("A 'dead smiley' was saved in " + bp["BOARDNAME"]);
				seLen--;
				continue;
			}

			// Write coordinates and SE fields
			bBuffer.writeByte(se.X);
			bBuffer.writeByte(se.Y);
			bBuffer.writeShort(se.STEPX);
			bBuffer.writeShort(se.STEPY);
			bBuffer.writeShort(se.CYCLE);

			var P1:int = se.extra.hasOwnProperty("P1") ? se.extra["P1"] : 0;
			var P2:int = se.extra.hasOwnProperty("P2") ? se.extra["P2"] : 0;
			var P3:int = se.extra.hasOwnProperty("P3") ? se.extra["P3"] : 0;

			var FOLLOWER:int = se.extra.hasOwnProperty("FOLLOWER") ? se.extra["FOLLOWER"] : 0;
			var LEADER:int = se.extra.hasOwnProperty("LEADER") ? se.extra["LEADER"] : 0;
			if (FOLLOWER >= 65536 || FOLLOWER < 0)
				FOLLOWER = 65535;
			if (LEADER >= 65536 || LEADER < 0)
				LEADER = 65535;

			if (eInfo.NUMBER == 36)
			{
				P1 = se.extra["CHAR"];
				P2 = (se.FLAGS & interp.FL_LOCKED) ? 1 : 0;
			}

			bBuffer.writeByte(P1);
			bBuffer.writeByte(P2);
			bBuffer.writeByte(P3);
			bBuffer.writeShort(FOLLOWER);
			bBuffer.writeShort(LEADER);
			bBuffer.writeByte(zzt.typeList[se.UNDERID].NUMBER);
			bBuffer.writeByte(se.UNDERCOLOR);
			bBuffer.writeInt(0); // Ptr
			bBuffer.writeShort(0); // IP

			var codeStr:String = "";
			if (eInfo.NUMBER == 10 || eInfo.NUMBER == 36)
			{
				//forceCodeStr(se);
				codeStr = se.extra["$CODE"];
			}

			bBuffer.writeShort(codeStr.length);
			if (wType == -1)
				writeConstantByte(bBuffer, 0, 8);

			if (codeStr.length > 0)
			{
				for (var si:int = 0; si < codeStr.length; si++)
				{
					var b:int = codeStr.charCodeAt(si);
					bBuffer.writeByte((b == 10) ? 13 : b);
				}
			}
		}

		// Size and concatenate the board buffer to the whole buffer.
		var bSize:int = bBuffer.length;
		if (bSize >= 32768)
		{
			regErrorMsg("Board " + bp["BOARDNAME"] + " is >= 32 KB; too large.");
			return false;
		}
		else if (bSize > 20480)
			regWarningMsg("Board " + bp["BOARDNAME"] + " is > 20 KB; carries risks.");

		bBuffer.position = 0;
		bBuffer.writeShort(bBuffer.length - 2);
		bBuffer.position = seLenPos;
		bBuffer.writeShort(seLen);
		bBuffer.position = bBuffer.length;
		sBuffer.writeBytes(bBuffer, 0, bBuffer.length);
	}

	worldSaveType = wType;
	return true;
}

public static function saveWorld(useFileName:String=""):void {
	var fileName:String = parse.lastFileName;
	if (useFileName != "")
		fileName = useFileName;

	if (utils.endswith(fileName, ".WAD") || utils.endswith(fileName, ".ZZT") ||
		utils.endswith(fileName, ".SZT"))
		fileName = fileName.substr(0, fileName.length - 4);
	else
		fileName = "";

	switch (worldSaveType) {
		case -1:
			modFlag = false;
			fileName = fileName + ".ZZT";
			parse.saveLocalFile(fileName, zzt.MODE_SAVELEGACY, zzt.MODE_NORM, sBuffer);
		break;
		case -2:
			modFlag = false;
			fileName = fileName + ".SZT";
			parse.saveLocalFile(fileName, zzt.MODE_SAVELEGACY, zzt.MODE_NORM, sBuffer);
		break;
		case -3:
			if (useFileName == "")
				modFlag = false;
			fileName = fileName + ".WAD";
			parse.saveLocalFile(fileName, zzt.MODE_SAVEWAD, zzt.MODE_NORM, ZZTLoader.file);
		break;
	}
}

// Show the JSON editor box with specific content.
public static function displayJSONProps(msg:String):void
{
	var se:SE;
	var i:int;
	var k:String;
	var s:String;
	var textStr:String;
	var titleStr:String;

	switch (msg) {
		case "$JSONBOARDINFO":
			zzt.propDictToUpdate = zzt.boardProps;
			titleStr = "Board Properties";
			textStr = parse.jsonToText(zzt.propDictToUpdate, true);
			break;
		case "$JSONBOARDREGIONS":
			zzt.propDictToUpdate = zzt.regions;
			titleStr = "Board Regions";
			textStr = parse.jsonToText(zzt.propDictToUpdate, true);
			break;
		case "$JSONWORLDPROP":
			zzt.propDictToUpdate = zzt.globalProps;
			titleStr = "World Properties";
			textStr = parse.jsonToText(zzt.propDictToUpdate, true, "DEP_");
			break;
		case "$JSONGLOBALS":
			zzt.propDictToUpdate = zzt.globals;
			titleStr = "Global Variables";
			textStr = parse.jsonToText(zzt.propDictToUpdate, true);
			break;
		case "$JSONMASKS":
			zzt.propDictToUpdate = ZZTLoader.extraMasks;
			titleStr = "Masks";
			s = parse.jsonToText(zzt.propDictToUpdate, true);
			textStr = formatMaskStr(s);
			break;
		case "$JSONSOUNDFX":
			zzt.propDictToUpdate = ZZTLoader.extraSoundFX;
			titleStr = "Sound FX";
			textStr = parse.jsonToText(zzt.propDictToUpdate, true);
			break;
		case "$JSONSTATELEM":
			tempStatProps = new Object();
			se = immType[3];
			tempStatProps["CYCLE"] = se.CYCLE;
			tempStatProps["X"] = se.X;
			tempStatProps["Y"] = se.Y;
			tempStatProps["STEPX"] = se.STEPX;
			tempStatProps["STEPY"] = se.STEPY;
			tempStatProps["FLAGS"] = se.FLAGS;
			tempStatProps["delay"] = se.delay;
			tempStatProps["IP"] = se.IP;
			tempStatProps["UNDERID"] = se.UNDERID;
			tempStatProps["UNDERCOLOR"] = se.UNDERCOLOR;
			for (k in se.extra)
				tempStatProps[k] = se.extra[k];

			zzt.propDictToUpdate = tempStatProps;
			titleStr = "Status Element";
			textStr = parse.jsonToText(zzt.propDictToUpdate, true);
			break;

		case "$JSONTYPES":
			hasExistingTypeSpec = true;
			newTypeString = "";
			newTypeNameFocus = "";
			launchTypeEditor(false);
			return;
	}

	editedPropName = msg;
	zzt.showPropTextView(zzt.MODE_ENTEREDITORPROP, titleStr, textStr);
}

// Parse properties from JSON editor box; destination will depend on
// the action that showed the box to begin with.
public static function parseJSONProps():void {
	var msg:String = editedPropName;
	var srcStr:String = utils.cr2lf(zzt.guiPropText.text);
	var i:int;
	var k:String;
	var se:SE;

	modFlag = true;
	if (msg == "$CODE" || msg == "")
	{
		// Object code is not stored in JSON format; just take it as-is.
		zzt.hidePropTextView(zzt.MODE_NORM);
		if (msg == "$CODE")
		{
			se = immType[3];
			se.extra["$CODE"] = srcStr;
			updateStatTypeInScroll();
		}
		else
		{
			// Open dialog to save as savegame
			oldHlpStr = srcStr;
			parse.saveLocalFile("UNTITLED.HLP", zzt.MODE_SAVEHLP, zzt.MODE_NORM, srcStr);
		}
		return;
	}

	var jObj:Object = parse.jsonDecode(srcStr);
	if (jObj == null)
		return;

	zzt.hidePropTextView(zzt.MODE_NORM);
	switch (msg) {
		case "$JSONBOARDINFO":
			for (k in zzt.propDictToUpdate)
				delete zzt.propDictToUpdate[k];
			for (k in jObj)
				zzt.propDictToUpdate[k] = jObj[k];

			showBoardInfo();
			break;
		case "$JSONBOARDREGIONS":
			for (k in zzt.propDictToUpdate)
				delete zzt.propDictToUpdate[k];
			for (k in jObj)
				zzt.propDictToUpdate[k] = jObj[k];

			showBoardInfo();
			break;

		case "$JSONWORLDPROP":
			for (k in zzt.propDictToUpdate)
			{
				if (!utils.startswith(k, "DEP_"))
					delete zzt.propDictToUpdate[k];
			}
			for (k in jObj)
				zzt.propDictToUpdate[k] = jObj[k];

			showWorldInfo();
			break;
		case "$JSONGLOBALS":
		case "$JSONSOUNDFX":
			for (k in zzt.propDictToUpdate)
				delete zzt.propDictToUpdate[k];
			for (k in jObj)
				zzt.propDictToUpdate[k] = jObj[k];

			showWorldInfo();
			break;
		case "$JSONMASKS":
			for (k in zzt.propDictToUpdate)
				delete zzt.propDictToUpdate[k];
			for (k in jObj)
			{
				zzt.propDictToUpdate[k] = jObj[k];
				zzt.addMask(k, jObj[k]);
			}

			showWorldInfo();
			break;

		case "$JSONSTATELEM":
			se = immType[3];
			se.CYCLE = jObj["CYCLE"];
			se.X = jObj["X"];
			se.Y = jObj["Y"];
			se.STEPX = jObj["STEPX"];
			se.STEPY = jObj["STEPY"];
			se.FLAGS = jObj["FLAGS"];
			se.delay = jObj["delay"];
			se.IP = jObj["IP"];
			se.UNDERID = jObj["UNDERID"];
			se.UNDERCOLOR = jObj["UNDERCOLOR"];

			for (k in se.extra)
			{
				if (nonExtraStatusKeys.indexOf(k) == -1)
					delete se.extra[k];
			}
			for (k in jObj)
			{
				if (nonExtraStatusKeys.indexOf(k) == -1)
					se.extra[k] = jObj[k];
			}

			updateStatTypeInScroll();
			break;

		case "$JSONTYPES":
			// When we establish the extra types, we must temporarily swap the
			// types within the gridded data with numbers, so that we don't end
			// up with type indexes pointing nowhere.
			zzt.establishExtraTypes(jObj);
			ZZTLoader.swapTypeNumbers(false);
			i = zzt.globalProps["BOARD"];
			ZZTLoader.updateContFromBoard(i, ZZTLoader.boardData[i]);
			SE.IsDark = 0;

			if (newTypeNameFocus == "")
				showWorldInfo();
			else
			{
				cursorActive = true;
				updateEditorView(false);
			}
			break;
	}
}

// Format the string version of a mask to look cleaner
public static function formatMaskStr(s:String):String {
	s = (s.split("[\"").join("[\n\""));
	s = (s.split("],").join("]\n,"));
	s = (s.split(",\"").join(",\n\""));

	return s;
}

// Set pattern cursor to specific custom slot
public static function setCustomPatternCursorPos(newPos:int):void {
	if (newPos >= actualBBLen)
		newPos = actualBBLen - 1;
	if (newPos < 0)
		newPos = 0;

	patternCursor = -1;
	patternBBCursor = newPos;
	drawEditorPatternCursor();
}

public static function colorVis2Stored(type:int, color:int, actualChar:int):int {
	var num:int = zzt.typeList[type].NUMBER;
	if (num == 11 || num == 9)
	{
		// Passages and doors should have FG and BG swapped.
		return (((color >> 4) & 15) ^ 8) + ((color << 4) & 240);
	}
	else if (zzt.typeList[type].TextDraw)
	{
		// Text drawing uses character as color.
		return actualChar;
	}

	return color;
}

// Perform spot-placement at editor cursor
public static function spotPlace(fromDrawingMode:Boolean, useImmType:Boolean=false):void {
	var pType:Array = immType;
	if (fromDrawingMode)
	{
		if (acquireMode)
		{
			// Instead of placing content, acquire the tile.
			pickupCursor();
			updateEditorView(true);
			return;
		}

		// Don't place if simple movement would not draw anything.
		if (drawFlag == DRAW_OFF || drawFlag == DRAW_TEXT)
			return;
	}

	modFlag = true;
	if (!useImmType)
	{
		pType = getPType();

		// If pulling from back buffer or pattern table...
		if (patternCursor == -1)
		{
			// Back buffer iteration
			if (drawFlag == DRAW_ACQFORWARD)
			{
				if (++patternBBCursor >= actualBBLen)
					patternBBCursor = 0;
				drawEditorPatternCursor();
			}
			else if (drawFlag == DRAW_ACQBACK)
			{
				if (--patternBBCursor < 0)
					patternBBCursor = actualBBLen - 1;
				drawEditorPatternCursor();
			}
		}
		else if (editorStyle == EDSTYLE_ULTRA || editorStyle == EDSTYLE_KEVEDIT)
		{
			// Built-in table iteration
			if (drawFlag == DRAW_ACQFORWARD)
			{
				if (++patternCursor >= patternBuiltIn - 1)
					patternCursor = 0;
				drawEditorPatternCursor();
			}
			else if (drawFlag == DRAW_ACQBACK)
			{
				if (--patternCursor < 0)
					patternCursor = patternBuiltIn - 2;
				drawEditorPatternCursor();
			}
		}
	}

	// Determine shown color.
	var useColor:int = pType[1];
	if (!defColorMode)
		useColor = (blinkFlag ? 128 : 0) + (bgColorCursor * 16) + fgColorCursor;

	// Get type; tweak color if type has special rendering.
	var eType:int = interp.typeTrans[pType[2]];
	var eInfo:ElementInfo = zzt.typeList[eType];
	var visColor:int = useColor;
	useColor = colorVis2Stored(eType, useColor, pType[0]);

	killSE(editorCursorX, editorCursorY);
	if (pType[3] == null)
	{
		// No-stat
		SE.setType(editorCursorX, editorCursorY, eType);
		SE.setColor(editorCursorX, editorCursorY, useColor, false);
	}
	else
	{
		// Stat
		var se:SE = new SE(eType, editorCursorX, editorCursorY, useColor);
		SE.setStatElemAt(editorCursorX, editorCursorY, se);
		SE.statElem.push(se);

		var oldSE:SE = pType[3];
		se.STEPX = oldSE.STEPX;
		se.STEPY = oldSE.STEPY;
		se.CYCLE = oldSE.CYCLE;
		se.IP = oldSE.IP;
		se.FLAGS = oldSE.FLAGS;
		se.delay = oldSE.delay;

		for (var s:String in oldSE.extra)
			se.extra[s] = oldSE.extra[s];

		// Passages have P2 set to visual color.
		if (eInfo.NUMBER == 11)
			se.extra["P2"] = visColor;
	}

	// Show updated square at cursor
	eraseEditorCursor();
}

public static function killSE(x:int, y:int):void {
	modFlag = true;
	var relSE:SE = SE.getStatElemAt(x, y);
	if (relSE != null)
	{
		// Kill status element at destination
		relSE.FLAGS |= interp.FL_DEAD;
		relSE.eraseSelfSquare(false);
		removeDead();
	}
}

// Remove all status elements with "FL_DEAD" flag set
public static function removeDead():void {
	for (var i:int = 0; i < zzt.statElem.length; i++)
	{
		if ((zzt.statElem[i].FLAGS & interp.FL_DEAD) != 0)
		{
			zzt.statElem.splice(i, 1);
			i--;
		}
	}
}

// Move the editor cursor to a specific spot
public static function warpEditorCursor(spotX:int, spotY:int, shiftStatus:Boolean=false):void {
	if (spotX < 1 || spotY < 1 || spotX > boardWidth || spotY > boardHeight)
		return;

	if (shiftStatus)
	{
		if (anchorX == -1)
		{
			anchorX = editorCursorX;
			anchorY = editorCursorY;
		}
		else
			removeRectSel();

		eraseEditorCursor();
		editorCursorX = spotX;
		editorCursorY = spotY;
		addToRectSel();
	}
	else
	{
		anchorX = -1;
		eraseEditorCursor();
		editorCursorX = spotX;
		editorCursorY = spotY;
		spotPlace(true);
		drawEditorCursor();
	}
}

// Update editor GUI fields and possibly board
public static function updateEditorView(guiOnly:Boolean=false):void {
	// Draw GUI-oriented fields
	zzt.drawGui();
	drawEditorColorCursors();
	drawEditorPatternCursor();
	if (guiOnly)
		return;

	// If updating board, draw it in its entirety
	reCenterEditorCursor();
	SE.uCameraX = -1000;
	SE.uCameraY = -1000;

	// Tweak the viewport if the board size would constrain what can be edited
	var sizeX:int = zzt.boardProps["SIZEX"];
	var sizeY:int = zzt.boardProps["SIZEY"];
	if (sizeX < 60)
	{
		SE.vpWidth = sizeX;
		SE.vpX1 = sizeX;
	}
	else
	{
		SE.vpWidth = 60;
		SE.vpX1 = 60;
	}
	if (sizeY < 25)
	{
		SE.vpHeight = sizeY;
		SE.vpY1 = sizeY;
	}
	else
	{
		SE.vpHeight = 25;
		SE.vpY1 = 25;
	}

	interp.smartUpdateViewport();

	// We will need to trim around the "outer rim" if not using the entire area
	for (var y:int = 1; y <= 25; y++)
	{
		for (var x:int = sizeX + 1; x <= 60; x++)
			zzt.mg.setCell(x-1, y-1, 69, 14);
	}
	for (y = sizeY + 1; y <= 25; y++)
	{
		for (x = 1; x <= 60; x++)
			zzt.mg.setCell(x-1, y-1, 69, 14);
	}

	// Draw editor cursor and selection info
	drawSelBuffer();
	drawEditorCursor();
}

// Draw selection buffer ranges as "XOR'ed" colors
public static function drawSelBuffer():void {
	var dx:int = -SE.CameraX + SE.vpX0 - 1;
	var dy:int = -SE.CameraY + SE.vpY0 - 1;

	for (var i:int = 0; i < selBuffer.length; i++) {
		var selRange:IPoint = selBuffer[i];
		zzt.mg.writeXorAttr(selRange.x + dx, selRange.y + dy, 1, 1, 127);
	}
}

// Tweak selection buffer ranges to include box between anchor and current cursor
public static function addToRectSel():void {
	var y1:int = (anchorY < editorCursorY) ? anchorY : editorCursorY;
	var y2:int = (anchorY >= editorCursorY) ? anchorY : editorCursorY;
	var x1:int = (anchorX < editorCursorX) ? anchorX : editorCursorX;
	var x2:int = (anchorX >= editorCursorX) ? anchorX : editorCursorX;

	for (var y:int = y1; y <= y2; y++) {
		for (var x:int = x1; x <= x2; x++) {
			var already:Boolean = false;
			for (var i:int = 0; i < selBuffer.length; i++) {
				var selRange:IPoint = selBuffer[i];
				if (x == selRange.x && y == selRange.y)
				{
					already = true;
					break;
				}
			}

			if (!already)
				selBuffer.push(new IPoint(x, y));
		}
	}

	updateEditorView(false);
}

// Tweak selection buffer ranges to exclude box between anchor and current cursor
public static function removeRectSel():void {
	if (anchorX == -1)
		return;

	var y1:int = (anchorY < editorCursorY) ? anchorY : editorCursorY;
	var y2:int = (anchorY >= editorCursorY) ? anchorY : editorCursorY;
	var x1:int = (anchorX < editorCursorX) ? anchorX : editorCursorX;
	var x2:int = (anchorX >= editorCursorX) ? anchorX : editorCursorX;

	for (var i:int = 0; i < selBuffer.length; i++) {
		var selRange:IPoint = selBuffer[i];
		if (selRange.x >= x1 && selRange.x <= x2 && selRange.y >= y1 && selRange.y <= y2)
		{
			selBuffer.splice(i, 1);
			i--;
		}
	}
}

// Draw the large color selection box cursor
public static function drawKolorCursor(isOn:Boolean):void {
	var boxCol:int = fgColorCursor + (blinkFlag ? 16 : 0);
	var boxRow:int = bgColorCursor;

	if (isOn)
		zzt.mg.setCell(boxCol + zzt.GuiLocX, boxRow + zzt.GuiLocY,
			254, 127 + (blinkFlag ? 0 : 128));
	else
		zzt.displayGuiSquare(boxCol + zzt.GuiLocX + 1, boxRow + zzt.GuiLocY + 1);
}

// Draw the large character selection box cursor
public static function drawCharCursor(isOn:Boolean):void {
	var boxCol:int = hexCodeValue & 31;
	var boxRow:int = (hexCodeValue >> 5) & 7;

	zzt.mg.setCell(boxCol + zzt.GuiLocX, boxRow + zzt.GuiLocY,
		hexCodeValue, isOn ? 112 : 15);
}

// If the cursor would be placed outside of the viewport, re-center it.
public static function reCenterEditorCursor():Boolean {
	var oldX:int = SE.CameraX;
	var oldY:int = SE.CameraY;
	var relX:int = editorCursorX - SE.CameraX + 1;
	var relY:int = editorCursorY - SE.CameraY + 1;
	var sizeX:int = zzt.boardProps["SIZEX"];
	var sizeY:int = zzt.boardProps["SIZEY"];

	if (relX < SE.vpX0 || relX > SE.vpX1)
	{
		SE.CameraX = editorCursorX - int(SE.vpWidth / 2);
		if (SE.CameraX + SE.vpWidth - 1 > sizeX)
			SE.CameraX = sizeX - SE.vpWidth + 1;
		if (SE.CameraX < 1)
			SE.CameraX = 1;
	}
	if (relY < SE.vpY0 || relY > SE.vpY1)
	{
		SE.CameraY = editorCursorY - int(SE.vpHeight / 2);
		if (SE.CameraY + SE.vpHeight - 1 > sizeY)
			SE.CameraY = sizeY - SE.vpHeight + 1;
		if (SE.CameraY < 1)
			SE.CameraY = 1;
	}

	return Boolean(SE.CameraX != oldX || SE.CameraY != oldY);
}

// Erase the editor cursor, drawing tile underneath
public static function eraseEditorCursor():void {
	SE.displaySquare(editorCursorX, editorCursorY);
}

// Draw the editor cursor based on the timer
public static function drawEditorCursor():void {
	if (reCenterEditorCursor())
		updateEditorView(false);

	if ((zzt.mcount & 31) >= 6)
	{
		zzt.mg.setCell(editorCursorX - SE.CameraX + SE.vpX0 - 1,
			editorCursorY - SE.CameraY + SE.vpY0 - 1, 197, 15);
	}
	else
		eraseEditorCursor();

	drawEditorStatsCoords();
}

// Draw editor color cursor(s)
public static function drawEditorColorCursors():void
{
	var fgMin:int = 0;
	var fgMax:int = 15;
	var bgMin:int = 0;
	var bgMax:int = 7;
	var fgSplit:Boolean = false;
	var hasBg:Boolean = true;

	switch (zzt.thisGuiName) {
		case "ED_CLASSIC":
			fgMin = 9;
			fgMax = 15;
			hasBg = false;
			zzt.drawGuiLabel("COLORNAME", getPrettyColorName(fgColorCursor));
		break;
		case "ED_SUPERZZT":
			fgSplit = true;
			zzt.drawGuiLabel("COLORNAME", getPrettyColorName(fgColorCursor));
		break;
	}

	var fgColorStr:String = "";
	var bgColorStr:String = "";
	var fgCols:int = fgSplit ? 8 : (fgMax - fgMin + 1);
	var bgCols:int = hasBg ? (bgMax - bgMin + 1) : 0;
	for (var i:int = 0; i < fgCols; i++)
	{
		if (fgSplit)
		{
			if (i + 8 == fgColorCursor)
				fgColorStr += String.fromCharCode(31);
			else
				fgColorStr += " ";
		}
		else if (i + fgMin == fgColorCursor)
			fgColorStr += String.fromCharCode(31);
		else
			fgColorStr += " ";
	}
	for (var j:int = 0; j < bgCols; j++)
	{
		if (fgSplit && j + fgMin == fgColorCursor)
			bgColorStr += String.fromCharCode(30);
		else if (j + bgMin == bgColorCursor)
			bgColorStr += String.fromCharCode(24);
		else
			bgColorStr += " ";
	}

	zzt.drawGuiLabel("COLORCURSOR1", fgColorStr);
	if (hasBg)
		zzt.drawGuiLabel("COLORCURSOR2", bgColorStr);
}

// Draw editor pattern cursor and back buffer
public static function drawEditorPatternCursor():void
{
	if (!zzt.GuiLabels.hasOwnProperty("PATTERNCURSOR"))
		return;

	var pCursor:int = 0;
	if (zzt.thisGuiName == "ED_CLASSIC" || zzt.thisGuiName == "ED_SUPERZZT")
	{
		// Back buffer of only one
		actualBBLen = 1;
		if (patternCursor == -1)
			pCursor = 5;
		else
			pCursor = patternCursor;
	}
	else
	{
		// Full back buffer
		if (patternCursor == -1)
			pCursor = 7 + patternBBCursor;
		else
			pCursor = patternCursor;
	}

	// Create pattern cursor string; write to label
	var pLen:int = zzt.GuiLabels["PATTERNCURSOR"][2];
	var pCursorStr:String = "";
	for (var j:int = 0; j < pLen; j++)
	{
		if (j == pCursor)
			pCursorStr += String.fromCharCode(31);
		else
			pCursorStr += " ";
	}

	zzt.drawGuiLabel("PATTERNCURSOR", pCursorStr);

	// Fill drawing-associated flags
	if (zzt.thisGuiName == "ED_CLASSIC" || zzt.thisGuiName == "ED_SUPERZZT")
	{
		if (hexTextEntry > 0)
			zzt.drawGuiLabel("DRAWING", "ASCII Char ", 26);
		else if (drawFlag == DRAW_ON)
			zzt.drawGuiLabel("DRAWING", "Drawing On ", 30);
		else if (drawFlag == DRAW_TEXT)
			zzt.drawGuiLabel("DRAWING", "Text Entry ", 78);
		else
			zzt.drawGuiLabel("DRAWING", "Drawing Off", 31);
	}
	else
	{
		zzt.drawGuiLabel("ENTERTEXT", "Enter Text", (drawFlag == DRAW_TEXT) ? 78 : 31);
		zzt.drawGuiLabel("BLINK", (blinkFlag ? "Blink On " : "Blink Off"),
			(blinkFlag ? 30 : 31));

		if (hexTextEntry > 0)
			zzt.drawGuiLabel("DRAW", "ASCII Char", 26);
		else if (drawFlag == DRAW_ON)
			zzt.drawGuiLabel("DRAW", "Draw On   ", 30);
		else if (drawFlag == DRAW_ACQFORWARD)
			zzt.drawGuiLabel("DRAW", "Draw Rot +", 28);
		else if (drawFlag == DRAW_ACQBACK)
			zzt.drawGuiLabel("DRAW", "Draw Rot -", 29);
		else
			zzt.drawGuiLabel("DRAW", "Draw Off  ", 31);

		zzt.drawGuiLabel("DEFCOLORMODE", (defColorMode ? "D" : "d"), (defColorMode ? 30 : 24));
		zzt.drawGuiLabel("ACQUIREMODE", (acquireMode ? "A" : "a"), (acquireMode ? 30 : 24));
		zzt.drawGuiLabel("BUFLOCK", (bufLockMode ? "/" : String.fromCharCode(179)),
			(bufLockMode ? 12 : 1));
	}

	// Show back buffer contents
	var guiLabelInfo:Array = zzt.GuiLabels["BBUFFER"];
	var gx:int = int(guiLabelInfo[0]);
	var gy:int = int(guiLabelInfo[1]);
	var bLen:int = int(guiLabelInfo[2]);
	gx += zzt.GuiLocX - 2;
	gy += zzt.GuiLocY - 2;

	for (var i:int = 0; i < bLen; i++)
	{
		if (i >= actualBBLen)
			zzt.mg.setCell(gx + i, gy, 32, 31);
		else
			zzt.mg.setCell(gx + i, gy, bBuffer[i][0], bBuffer[i][1]);
	}
}

// Draw stats and coords
public static function drawEditorStatsCoords():void
{
	var statStr:String = zzt.statElem.length.toString() + "/" + maxStats.toString();
	var coordStr:String = "(" + editorCursorX.toString() + "," + editorCursorY.toString() + ") ";
	zzt.drawGuiLabel("STATS", statStr);
	zzt.drawGuiLabel("COORDS", coordStr);
	zzt.drawGuiLabel("MODFLAG", modFlag ? "*" : " ");
}

// Reveal all "hidden" objects.  This routine examines the viewport
// for any status element that satisfies one of two conditions:
// 1) Character is 0, 32, 255, 219, 176, 177, or 178
// 2) FG and BG are the same
public static function showHiddenObj():void
{
	for (var y:int = SE.vpY0; y <= SE.vpY1; y++) {
		for (var x:int = SE.vpX0; x <= SE.vpX1; x++) {
			var dx:int = x - SE.vpX0 + SE.CameraX;
			var dy:int = y - SE.vpY0 + SE.CameraY;

			var se:SE = SE.getStatElemAt(dx, dy);
			if (se)
			{
				var color:int = SE.getColor(dx, dy);
				if ((color & 15) == ((color >> 4) & 7))
					zzt.mg.setCell(x-1, y-1, 1, 15);
				else
				{
					var char:int = zzt.mg.getChar(x-1, y-1);
					switch (char) {
						case 0:
						case 32:
						case 255:
						case 219:
						case 176:
						case 177:
						case 178:
							zzt.mg.setCell(x-1, y-1, 1, color);
						break;
					}
				}
			}
		}
	}
}

public static function showHelp():void {
	parse.blankPage("editors.html#worldeditor");
}

};
};

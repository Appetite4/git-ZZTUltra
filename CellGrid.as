//CellGrid.as:  A grid filled with Cells.

package
{

import flash.display.*;
import flash.geom.*;
import flash.utils.ByteArray;
import flash.utils.Endian;

//public class CellGrid extends MovieClip {
public class CellGrid extends Bitmap {
	// Constants
	public static const COLOR_BLACK:int = 0x000000;
	public static const COLOR_DARKBLUE:int = 0x0000AA;
	public static const COLOR_DARKGREEN:int = 0x00AA00;
	public static const COLOR_DARKCYAN:int = 0x00AAAA;
	public static const COLOR_DARKRED:int = 0xAA0000;
	public static const COLOR_DARKPURPLE:int = 0xAA00AA;
	public static const COLOR_BROWN:int = 0xAA5500;
	public static const COLOR_GREY:int = 0xAAAAAA;
	public static const COLOR_DARKGREY:int = 0x555555;
	public static const COLOR_BLUE:int = 0x5555FF;
	public static const COLOR_GREEN:int = 0x55FF55;
	public static const COLOR_CYAN:int = 0x55FFFF;
	public static const COLOR_RED:int = 0xFF5555;
	public static const COLOR_PURPLE:int = 0xFF55FF;
	public static const COLOR_YELLOW:int = 0xFFFF55;
	public static const COLOR_WHITE:int = 0xFFFFFF;

	// Default color lookup table
	public static var colorLookup:Array = [
		COLOR_BLACK, COLOR_DARKBLUE, COLOR_DARKGREEN, COLOR_DARKCYAN,
		COLOR_DARKRED, COLOR_DARKPURPLE, COLOR_BROWN, COLOR_GREY,
		COLOR_DARKGREY, COLOR_BLUE, COLOR_GREEN, COLOR_CYAN,
		COLOR_RED, COLOR_PURPLE, COLOR_YELLOW, COLOR_WHITE
	];

	// Mode info
	public static var modeInfo:Array = [
		// Height mode,    scanlines,   dest char height, num rows, pre-stretch, fit-stretch

		// CGA scanlines (200)
		[ 0,				200,			8,				25,			1.0,		2.0],
		[ 0,				200,			8,				25,			7.0/4.0,	2.0],
		[ 0,				200,			8,				25,			2.0,		2.0],

		// EGA scanlines (350)
		[ 0,				350,			8,				43,			1.0,		8.0/7.0],
		[ 1,				350,			14,				25,			1.0,		8.0/7.0],
		[ 1,				350,			14,				25,			8.0/7.0,	8.0/7.0],

		// VGA scanlines (400)
		[ 0,				400,			8,				50,			1.0,		1.0],
		[ 1,				400,			14,				28,			1.0,		1.0],
		[ 2,				400,			16,				25,			1.0,		1.0]
	];

	// Variables
	public static var blinkChanged:Boolean = false;
	public static var blinkOnVis:Boolean = false;
	public static var blinkBitUsed:Boolean = true;
	public static var bgMask:int = 7;

	public var redArray:Array;
	public var greenArray:Array;
	public var blueArray:Array;
	public var colors16:Vector.<int>;

	public var charWidth:int;
	public var charHeight:int;
	public var charHeightMode:int;
	public var scanlineMode:int;
	public var overallMode:int;
	public var numRows:int;
	public var fitStretch:Number;
	public var virtualCellYDiv:Number;

	public var numSurfaces:int;
	public var surfaces:Array;

	public var xSize:int;
	public var ySize:int;
	public var ixSize:int;
	public var iySize:int;
	public var totalCount:int;
	public var doubleWidth:Boolean;

	//public var cellArray:Vector.<Cell>;
	public var blinkList:Vector.<int>;
	public var chars:ByteArray;
	public var attrs:ByteArray;

	public var myBitmapBank:Vector.<BitmapData>;
	public var defaultBmBanks:Array;

	// Constructor
	public function CellGrid(gridWidth:int, gridHeight:int) {
		// Set basic attributes
		xSize = gridWidth;
		ySize = gridHeight;
		ixSize = xSize;
		iySize = 50; // ySize
		charWidth = ASCII_Characters.CHAR_WIDTH;
		charHeight = ASCII_Characters.CHAR_HEIGHT;
		totalCount = xSize * ySize;
		doubleWidth = false;
		charHeightMode = 2; // 16 height
		scanlineMode = 2; // VGA
		overallMode = 8; // VGA, 16 height
		numRows = 25;
		fitStretch = 1.0;
		virtualCellYDiv = 16;

		// Create palette info
		createPaletteArrays(colorLookup);
		myBitmapBank = ASCII_Characters.bmBank16;
		defaultBmBanks = [
			ASCII_Characters.bmBank8,		// CGA
			ASCII_Characters.bmBank14,		// EGA
			ASCII_Characters.bmBank16		// VGA
		];

		// Set default surface info
		numSurfaces = 1;
		surfaces = [
			[ 0, 0, xSize, ySize, null, false ],
			[ 0, 0, xSize, ySize, null, false ],
			[ 0, 0, xSize, ySize, null, false ],
			[ 0, 0, xSize, ySize, null, false ],
			[ 0, 0, xSize, ySize, null, false ]
		];
		createSurfaces(xSize, ySize, [1, 1, xSize, ySize]);

		// Create individuals cells; arrange into grid
		chars = new ByteArray();
		attrs = new ByteArray();
		blinkList = new Vector.<int>();
		this.bitmapData = new BitmapData(xSize * charWidth, ySize * charHeight, false, 0);
		//cellArray = new Vector.<Cell>(totalCount);
		for (var cy:int = 0; cy < iySize; cy++)
		{
			for (var cx:int = 0; cx < xSize; cx++)
			{
				//var mc:Cell = new Cell(0, 0);
				//cellArray[cy * xSize + cx] = mc;
				//mc.x = cx * ASCII_Characters.CHAR_WIDTH;
				//mc.y = cy * ASCII_Characters.CHAR_HEIGHT;
				//this.addChild(mc);
				chars.writeByte(0);
				attrs.writeByte(0);
			}
		}

		// If "40-column" display, double the x-scale factor
		if (doubleWidth)
			this.scaleX = 2.0;
	}

	public function setDoubled(isDoubled:Boolean):void {
		doubleWidth = isDoubled;
		if (isDoubled)
			this.scaleX = 2.0;
		else
			this.scaleX = 1.0;
	}

	public function adjustVisiblePortion(visibleWidth:int, visibleHeight:int):void {
		xSize = visibleWidth;
		ySize = visibleHeight;
		totalCount = xSize * ySize;

		// Create and initialize new bitmap
		this.bitmapData = new BitmapData(xSize * charWidth, ySize * charHeight, false, 0);
		createSurfaces(xSize, ySize, [1, 1, xSize, ySize], true);
	}
	/*public function adjustVisiblePortionOld(visibleWidth:int, visibleHeight:int):void {
		for (var cy:int = 0; cy < ySize; cy++)
		{
			for (var cx:int = 0; cx < xSize; cx++)
			{
				if (cx < visibleWidth && cy < visibleHeight)
					cellArray[cy * xSize + cx].visible = true;
				else
					cellArray[cy * xSize + cx].visible = false;
			}
		}
	}*/

	// Creation of palette mapping colors
	public function createPaletteArrays(cLookup:Array):void {
		// Set look-up arrays to defaults
		redArray = new Array(256);
		greenArray = new Array(256);
		blueArray = new Array(256);
		for (var j:int = 0; j < 256; j++) {
			redArray[j] = 0;
			greenArray[j] = 0;
			blueArray[j] = 0;
		}

		// Extract RGB basis for default 16 colors
		colors16 = new Vector.<int>();
		for (var i:int = 0; i < 16; i++) {
			var c:int = cLookup[i];
			var r:int = c & 16711680;
			var g:int = c & 65280;
			var b:int = c & 255;
			colors16.push(r);
			colors16.push(g);
			colors16.push(b);
		}
	}

	// Setting palette look-up arrays to specific color
	public function setPalLookup(fgColor:int, bgColor:int):void {
		var idxFG:int = fgColor * 3;
		var idxBG:int = bgColor * 3;
		redArray[0]		= colors16[idxBG + 0];
		greenArray[0]	= colors16[idxBG + 1];
		blueArray[0]	= colors16[idxBG + 2];
		redArray[255]	= colors16[idxFG + 0];
		greenArray[255]	= colors16[idxFG + 1];
		blueArray[255]	= colors16[idxFG + 2];
	}

	// Create a surface bitmap from bounds.
	public function createSurface(surface:Array, x0:int, y0:int, xLen:int, yLen:int):void {
		surface[0] = x0;
		surface[1] = y0;
		surface[2] = xLen;
		surface[3] = yLen;
		surface[4] = new BitmapData(charWidth * xLen, charHeight * yLen, false, 0x00000000);
	}

	// Create surface bitmaps from GUI/viewport spec
	public function createSurfaces(overallSizeX:int, overallSizeY:int, viewport:Array,
		copyFromOld:Boolean=false):void {
		// Establish viewport dimensions
		var vpX0:int = viewport[0] - 1;
		var vpY0:int = viewport[1] - 1;
		var vpXLen:int = viewport[2];
		var vpYLen:int = viewport[3];
		var vpX1:int = vpX0 + vpXLen;
		var vpY1:int = vpY0 + vpYLen;

		// Reset existing surfaces.
		surfaces[0][4] = null;
		surfaces[1][4] = null;
		surfaces[2][4] = null;
		surfaces[3][4] = null;
		surfaces[4][4] = null;

		// Depending on how the viewport is aligned within or next to the GUI, there can be
		// between one and five surfaces created.
		if (vpX1 <= 0 || vpY1 <= 0 || vpX0 >= overallSizeX || vpY0 >= overallSizeY)
		{
			// No visible viewport--only a single GUI portion is present.
			createSurface(surfaces[0], 0, 0, overallSizeX, overallSizeY);
			numSurfaces = 1;
		}
		else
		{
			// Viewport
			createSurface(surfaces[0], vpX0, vpY0, vpXLen, vpYLen);
			numSurfaces = 1;

			if (vpY0 > 0)
			{
				// Top portion of GUI (above viewport)
				createSurface(surfaces[numSurfaces], 0, 0, overallSizeX, vpY0);
				numSurfaces++;
			}
			if (vpX0 > 0)
			{
				// Left portion of GUI (left of viewport)
				createSurface(surfaces[numSurfaces], 0, vpY0, vpX0, vpYLen);
				numSurfaces++;
			}
			if (vpX1 < overallSizeX)
			{
				// Right portion of GUI (right of viewport)
				createSurface(surfaces[numSurfaces], vpX1, vpY0, overallSizeX - vpX1, vpYLen);
				numSurfaces++;
			}
			if (vpY1 < overallSizeY)
			{
				// Bottom portion of GUI (below viewport)
				createSurface(surfaces[numSurfaces], 0, vpY1, overallSizeX, overallSizeY - vpY1);
				numSurfaces++;
			}
		}

		if (copyFromOld)
		{
			for (var cy:int = 0; cy < ySize; cy++)
			{
				for (var cx:int = 0; cx < xSize; cx++)
				{
					var locIdx:int = cy * ixSize + cx;
					setCell(cx, cy, chars[locIdx], attrs[locIdx]);
				}
			}
		}
	}

	// Perform uniform copy to back buffer to be shown upon the next redraw
	public function silentErase(char:int, attr:int):void {
		for (var cy:int = 0; cy < iySize; cy++)
		{
			for (var cx:int = 0; cx < ixSize; cx++)
			{
				var locIdx:int = cy * ixSize + cx;
				chars[locIdx] = char;
				attrs[locIdx] = attr;
			}
		}

		for (var n:int = 0; n < numSurfaces; n++)
			surfaces[n][5] = true;
	}

	// Perform redraw over entirety of grid, to be shown upon the next redraw
	public function redrawGrid():void {
		for (var cy:int = 0; cy < ySize; cy++)
		{
			for (var cx:int = 0; cx < xSize; cx++)
			{
				var locIdx:int = cy * ixSize + cx;
				setCell(cx, cy, chars[locIdx], attrs[locIdx]);
			}
		}
	}

	// Select target surface.
	public function getTargetSurface(x:int, y:int):Array {
		for (var i:int = 0; i < numSurfaces; i++) {
			var s:Array = surfaces[i];
			if (x >= s[0] && y >= s[1] && x < s[0] + s[2] && y < s[1] + s[3])
				return s;
		}

		// Early-out if coordinates are outside all surfaces
		return null;
	}

	// Draw surfaces if they were updated.
	public function drawSurfaces(redrawAll:Boolean=false):void {
		for (var i:int = 0; i < numSurfaces; i++) {
			var s:Array = surfaces[i];
			if (s[5] || redrawAll)
			{
				s[5] = false;
				var destPt:Point = new Point(s[0] * charWidth, s[1] * charHeight);
				var srcRect:Rectangle = new Rectangle(0, 0, s[2] * charWidth, s[3] * charHeight);
				this.bitmapData.copyPixels(s[4], srcRect, destPt);
			}
		}
	}

	// Write character and attribute
	public function setCell(x:int, y:int, char:int, attr:int=-1):void {
		// Select target surface.  Early-out if coordinates are outside all surfaces.
		var s:Array = getTargetSurface(x, y);
		if (!s)
			return;

		// Reconcile attribute, shown character, and blink
		var locIdx:int = y * ixSize + x;
		chars[locIdx] = char;
		if (attr == -1)
			attr = attrs[locIdx];
		if ((attr & 128) != 0 && blinkBitUsed)
			char = blinkOnVis ? char : 0;

		// Get bitmap and positions
		var tPoint:Point = new Point((x - s[0]) * charWidth, (y - s[1]) * charHeight);
		var sourceRect:Rectangle = new Rectangle(0, 0, charWidth, charHeight);
		var srcBitmap:BitmapData = myBitmapBank[char];

		// Establish color change
		var fgColor:int = attr & 15;
		var bgColor:int = (attr >> 4) & bgMask;
		setPalLookup(fgColor, bgColor);

		// Write bitmap to surface using palette lookup; flag surface as needing an update
		//s[4].copyPixels(srcBitmap, sourceRect, tPoint, null, null, false);
		s[4].paletteMap(srcBitmap, sourceRect, tPoint, redArray, greenArray, blueArray);
		s[5] = true;

		if (((attr ^ attrs[locIdx]) & 128) != 0 && blinkBitUsed)
			blinkChanged = true;
		attrs[locIdx] = attr;
	}
	/*public function setCellOld(cx:int, cy:int, char:int, attr:int=-1):void
	{
		// Clipped out of grid
		if (cx < 0 || cx >= xSize || cy < 0 || cy >= ySize)
			return;

		// Set cell and possible color at specific location
		var cell:Cell = cellArray[cy * xSize + cx];
		if (attr == -1)
			cell.setChar(char);
		else
			cell.setAll(char, attr);
	}*/

	public function changeBlinkForCell(x:int, y:int, setOn:Boolean):void {
		// Select target surface.  Early-out if coordinates are outside all surfaces.
		var s:Array = getTargetSurface(x, y);
		if (!s)
			return;

		// Reconcile attribute, shown character, and blink
		var locIdx:int = y * ixSize + x;
		var char:int = chars[locIdx];
		var attr:int = attrs[locIdx];
		if (attr & 128)
			char = setOn ? char : 0;

		// Get bitmap and positions
		var tPoint:Point = new Point((x - s[0]) * charWidth, (y - s[1]) * charHeight);
		var sourceRect:Rectangle = new Rectangle(0, 0, charWidth, charHeight);
		var srcBitmap:BitmapData = myBitmapBank[char];

		// Establish color change
		var fgColor:int = attr & 15;
		var bgColor:int = (attr >> 4) & 7;
		setPalLookup(fgColor, bgColor);

		// Write bitmap to surface using palette lookup; flag surface as needing an update
		s[4].paletteMap(srcBitmap, sourceRect, tPoint, redArray, greenArray, blueArray);
		s[5] = true;
	}

	public function getChar(cx:int, cy:int):int
	{
		// Clipped out of grid
		if (cx < 0 || cx >= xSize || cy < 0 || cy >= ySize)
			return 0;

		return chars[cy * ixSize + cx];
	}
	/*public function getCharOld(cx:int, cy:int):int
	{
		// Clipped out of grid
		if (cx < 0 || cx >= xSize || cy < 0 || cy >= ySize)
			return 0;

		// Get cell
		var cell:Cell = cellArray[cy * xSize + cx];
		return (cell.myChar);
	}*/

	public function getAttr(cx:int, cy:int):int
	{
		// Clipped out of grid
		if (cx < 0 || cx >= xSize || cy < 0 || cy >= ySize)
			return 0;

		// Get color
		return attrs[cy * ixSize + cx];
	}
	/*public function getAttrOld(cx:int, cy:int):int
	{
		// Clipped out of grid
		if (cx < 0 || cx >= xSize || cy < 0 || cy >= ySize)
			return 0;

		// Get color
		var cell:Cell = cellArray[cy * xSize + cx];
		return (cell.myAttr);
	}*/

	public function getFG(cx:int, cy:int):int
	{
		return (getAttr(cx, cy) & 15);
	}
	public function getBG(cx:int, cy:int):int
	{
		return ((getAttr(cx, cy) >> 4) & bgMask);
	}

	public function writeStr(cx:int, cy:int, str:String, attr:int=-1):void
	{
		// Write multiple cells and possible color
		for (var i:int = 0; i < str.length; i++)
		{
			setCell(cx, cy, int(str.charCodeAt(i)), attr);
			cx++;
		}
	}

	public function writeUntilWordEdge(cx:int, cy:int, cWidth:int,
		str:String, attr:int=-1, centered=false):int
	{
		var hasSpaces:Boolean = false;
		var lastWasSpace:Boolean = false;
		var safeExtent:int = 0;
		var nextWord:int = 0;
		var i:int;

		// Find how many characters will fit on line.
		for (i = 0; i < str.length && i < cWidth; i++) {
			var c:int = int(str.charCodeAt(i));
			if (c == 32)
			{
				// Space; will be possible implied break of line.
				if (!lastWasSpace)
				{
					safeExtent = i;
					lastWasSpace = true;
					hasSpaces = true;
				}

				nextWord = i + 1;
			}
			/*else if (c == 0)
			{
				// End of string; done with line.
				nextWord = i;
				if (!lastWasSpace)
					safeExtent = i;
				break;
			}*/
			else if (c == 10)
			{
				// Line break; done with line.
				nextWord = i + 1;
				if (!lastWasSpace)
					safeExtent = i;
				break;
			}
			else
			{
				// Non-space.
				lastWasSpace = false;
			}
		}

		if (!hasSpaces && safeExtent == 0)
		{
			// The "safe extent" distance becomes the entire width if
			// there are no spaces on the entire line.
			safeExtent = cWidth;
		}

		// Display the clipped line.
		if (centered)
			writeStr(int(cx + cWidth/2 - safeExtent/2), cy,
				str.substr(0, safeExtent), attr);
		else
			writeStr(cx, cy, str.substr(0, safeExtent), attr);

		// Return the next point where the line should continue.
		return nextWord;
	}

	public function writeMultipleWrapLines(cx:int, cy:int, cWidth:int, cHeight:int,
		str:String, attr:int=-1, centered=false):int
	{
		// Write partial lines until done with string or cHeight reached.
		do {
			var nextPos:int =
				writeUntilWordEdge(cx, cy, cWidth, str, attr, centered);
			str = str.substr(nextPos);

			cy++;
		} while (str != "" && cy < cHeight);

		// Return number of lines written.
		return cy;
	}

	public function writeBlock(cx:int, cy:int, strList:Array, attrList:Array=null):void
	{
		// Write block of rows from an array, optionally coloring them as well
		if (attrList == null)
		{
			// No color info; keep color
			for (var dy:int = 0; dy < strList.length; dy++)
			{
				writeStr(cx, cy + dy, strList[dy]);
			}
		}
		else
		{
			// Color info; write characters and colors
			for (dy = 0; dy < strList.length; dy++)
			{
				for (var dx:int = 0; dx < strList[0].length; dx++)
				{
					setCell(cx + dx, cy + dy,
						int(strList[dy].charCodeAt(dx)), int(attrList[dy][dx]));
				}
			}
		}
	}

	public function writeConst(cx:int, cy:int, xlen:int, ylen:int, cChar:String, attr:int):void
	{
		// Paint block of rows with constant character and color
		var c:int = int(cChar.charCodeAt(0));
		for (var dy:int = 0; dy < ylen; dy++)
		{
			for (var dx:int = 0; dx < xlen; dx++)
			{
				setCell(cx + dx, cy + dy, c, attr);
			}
		}
	}

	public function writeXorAttr(cx:int, cy:int, xlen:int, ylen:int, attr:int):void
	{
		// XOR the color at the block with the specified color attribute mask
		for (var dy:int = 0; dy < ylen; dy++)
		{
			for (var dx:int = 0; dx < xlen; dx++)
			{
				var newAttr:int = getAttr(cx + dx, cy + dy) ^ attr;
				setCell(cx + dx, cy + dy, getChar(cx + dx, cy + dy), newAttr);
			}
		}
	}

	public function moveBlock(cx1:int, cy1:int, cx2:int, cy2:int, xDiff:int, yDiff:int):void
	{
		// Copy a block of existing cells by (xDiff, yDiff).
		var xInc:int = utils.isgn(xDiff);
		var yInc:int = utils.isgn(yDiff);
		var xLen:int = utils.iabs(cx2 - cx1);
		var yLen:int = utils.iabs(cy2 - cy1);
		var tempVal:int;
		if (xInc > 0)
		{
			tempVal = cx1;
			cx1 = cx2;
			cx2 = tempVal;
		}
		if (yInc > 0)
		{
			tempVal = cy1;
			cy1 = cy2;
			cy2 = tempVal;
		}
		if (xInc == 0)
			xInc = -1;
		if (yInc == 0)
			yInc = -1;

		for (var dy:int = cy1; yLen >= 0; dy -= yInc, yLen--)
		{
			var xLen2:int = xLen;
			for (var dx:int = cx1; xLen2 >= 0; dx -= xInc, xLen2--)
			{
				var locIdx:int = dy * ixSize + dx;
				setCell(dx + xDiff, dy + yDiff, chars[locIdx], attrs[locIdx]);
			}
		}
	}
	/*public function moveBlockOld(cx1:int, cy1:int, cx2:int, cy2:int, xDiff:int, yDiff:int):void
	{
		// Copy a block of existing cells by (xDiff, yDiff).
		var xInc:int = utils.isgn(xDiff);
		var yInc:int = utils.isgn(yDiff);
		var xLen:int = utils.iabs(cx2 - cx1);
		var yLen:int = utils.iabs(cy2 - cy1);
		var tempVal:int;
		if (xInc > 0)
		{
			tempVal = cx1;
			cx1 = cx2;
			cx2 = tempVal;
		}
		if (yInc > 0)
		{
			tempVal = cy1;
			cy1 = cy2;
			cy2 = tempVal;
		}
		if (xInc == 0)
			xInc = -1;
		if (yInc == 0)
			yInc = -1;

		for (var dy:int = cy1; yLen >= 0; dy -= yInc, yLen--)
		{
			var xLen2:int = xLen;
			for (var dx:int = cx1; xLen2 >= 0; dx -= xInc, xLen2--)
			{
				var srcCell:Cell = cellArray[dy * xSize + dx];
				setCell(dx + xDiff, dy + yDiff, srcCell.myChar, srcCell.myAttr);
			}
		}
	}*/

	public function updateScanlineMode(mode:int):void {
		// Establish overall mode from updated scanline mode
		scanlineMode = mode;
		overallMode = scanlineMode * 3;

		// Character set is reverted to default set for the scanline size.
		// This can be configured later by selecting a different character
		// set.  If the character set is not the same size as the
		// preferred number of lines per character, can have > 25 rows.
		myBitmapBank = defaultBmBanks[scanlineMode];
		charHeightMode = scanlineMode;
		overallMode += charHeightMode;

		// Establish mode parameters
		var mi:Array = modeInfo[overallMode];
		var oldNumRows:int = numRows;
		numRows = 25;
		var oldCharHeight:int = charHeight;
		charHeight = mi[2];
		fitStretch = mi[5];
		virtualCellYDiv = 16;

		// If the number of rows/char height had changed, adjust the visible height.
		if (numRows != oldNumRows || charHeight != oldCharHeight)
		{
			ySize = numRows;
			totalCount = xSize * ySize;
			this.bitmapData = new BitmapData(xSize * charWidth, ySize * charHeight, false, 0);
		}

		// Adjust window stretch
		this.scaleY = fitStretch;

		// Will need to re-create surfaces after this call.
	}

	// Reset character set to default
	public function setDefaultCharacters():void {
		var mi:Array = modeInfo[overallMode];
		myBitmapBank = defaultBmBanks[mi[0]];

		// Will need to re-create surfaces after this call.
	}

	// Get current character mask from existing bitmap
	public function getCurrentCharacterMask(charNum:int, xLength:int=-1):Array {
		var bmd:BitmapData = myBitmapBank[charNum];
		var cell:Array = [];
		var subCell:Array = [];
		var xCounter:int = 0;

		for (var y:int = 0; y < charHeight; y++) {
			if (xLength == -1)
			{
				// No sub-length
				for (var x:int = 0; x < charWidth; x++) {
					var val:uint = bmd.getPixel(x, y) & 0x00FFFFFF;
					cell.push((val != 0) ? 1 : 0);
				}
			}
			else
			{
				// Sub-length of xLength
				for (x = 0; x < charWidth; x++) {
					val = bmd.getPixel(x, y) & 0x00FFFFFF;
					subCell.push((val != 0) ? 1 : 0);
					if (subCell.length >= xLength)
					{
						cell.push(subCell);
						subCell = [];
					}
				}
			}
		}

		return cell;
	}

	// Modify some or all of character set.
	public function updateCharacterSet(cellXSize:int, cellYSize:int,
		cellsAcross:int, cellsDown:int, startChar:int, sequence:Array):void {
		// Find out what to do based on character cell size.
		var srcHeightOffset:int = 2;
		var customStretch:Boolean = false;
		switch (cellYSize) {
			case 8:
				srcHeightOffset = 0;
			break;
			case 14:
				srcHeightOffset = 1;
			break;
			case 16:
				srcHeightOffset = 2;
			break;
			default:
				customStretch = true;
			break;
		}

		// Establish mode parameters
		var oldCharHeight:int = charHeight;
		var oldDefaultBms:Vector.<BitmapData> = defaultBmBanks[srcHeightOffset];

		overallMode = scanlineMode * 3 + srcHeightOffset;
		charHeightMode = srcHeightOffset;
		var mi:Array = modeInfo[overallMode];
		charHeight = mi[2];
		var oldNumRows:int = numRows;
		numRows = mi[3];
		var preStretch:Number = mi[4];
		virtualCellYDiv = 400.0 / (Number(mi[1]) / Number(charHeight));
		fitStretch = mi[5];
		if (customStretch)
			preStretch = Number(charHeight) / Number(cellYSize);

		// Figure out sequence iteration parameters
		var endChar:int = startChar + (cellsAcross * cellsDown);
		var pitch:int = cellsAcross * cellXSize;
		var bRect:Rectangle = new Rectangle(0, 0, charWidth, charHeight);
		var pt:Point = new Point(0, 0);
		var newBitmapBank:Vector.<BitmapData> = new Vector.<BitmapData>(256, true);

		// Establish the new character cell bitmaps.
		for (var n:int = 0; n < 256; n++) {
			var bmd:BitmapData = new BitmapData(charWidth, charHeight, false, 0);

			if (n < startChar || n >= endChar)
			{
				// Use original character set--our list did not include this character.
				if (charHeight == oldCharHeight)
					bmd.copyPixels(myBitmapBank[n], bRect, pt);
				else
					bmd.copyPixels(oldDefaultBms[n], bRect, pt);
			}
			else
			{
				// Create new bitmap from provided cell data.
				bmd.lock();

				var rowIdx:int = int((n - startChar) / cellsAcross);
				var colIdx:int = int((n - startChar) % cellsAcross);
				var seqBase:int = (rowIdx * pitch * cellYSize) + (colIdx * cellXSize);

				for (var y:int = 0; y < charHeight; y++) {
					// The pre-stretch factor is used when we must scale the
					// source data to a target height.
					var seqIdx:int = int(preStretch * y) * pitch + seqBase;

					for (var x:int = 0; x < charWidth; x++) {
						var pix:int = sequence[seqIdx++];
						bmd.setPixel(x, y, (pix != 0) ? 0x00FFFFFF : 0);
					}
				}

				bmd.unlock();
			}

			// Store new character cell
			newBitmapBank[n] = bmd;
		}

		myBitmapBank = newBitmapBank;

		// If the number of rows/char height had changed, adjust the visible height.
		if (numRows != oldNumRows || charHeight != oldCharHeight)
		{
			ySize = numRows;
			totalCount = xSize * ySize;
			this.bitmapData = new BitmapData(xSize * charWidth, ySize * charHeight, false, 0);
		}

		// Adjust window stretch
		this.scaleY = fitStretch;

		// Will need to re-create surfaces after this call.
	}

	public function updateBit7Meaning(useBlink:int):void {
		if (blinkBitUsed == Boolean(useBlink == 1))
			return;

		blinkBitUsed = Boolean(useBlink == 1);
		bgMask = (useBlink == 1) ? 7 : 15;
		redrawGrid();
		blinkChanged = true;
	}

	public function setPaletteColor(palIdx:int, red:int, green:int, blue:int):void {
		setPaletteColors(palIdx, 1, 255, [ red, green, blue ]);
	}

	public function setPaletteColors(
		palIdxStart:int, palIdxNum:int, extent:int, sequence:Array):void {

		// Extract RGB basis for default 16 colors
		var seqIdx:int = 0;
		if (sequence.length < palIdxNum * 3)
			palIdxNum = int(sequence.length / 3);

		var palIdxEnd:int = palIdxStart + palIdxNum - 1;
		for (var i:int = palIdxStart; i <= palIdxEnd; i++) {
			colors16[i * 3 + 0] = (sequence[seqIdx++] * 255 / extent) << 16;
			colors16[i * 3 + 1] = (sequence[seqIdx++] * 255 / extent) << 8;
			colors16[i * 3 + 2] = (sequence[seqIdx++] * 255 / extent);
		}

		redrawGrid();
	}

	// Get current palette color sequence
	public function getPaletteColors():Array {
		// Extract RGB basis for default 16 colors
		var sequence:Array = [];
		for (var i:int = 0; i < colors16.length; i += 3) {
			sequence.push((colors16[i+0] >> 16) & 255);
			sequence.push((colors16[i+1] >> 8) & 255);
			sequence.push(colors16[i+2] & 255);
		}

		return sequence;
	}

	// Get default palette color sequence
	public function getDefaultPaletteColors():Array {
		var sequence:Array = [];
		for (var i:int = 0; i < 16; i++) {
			var c:int = colorLookup[i];
			sequence.push((c >> 16) & 255);
			sequence.push((c >> 8) & 255);
			sequence.push(c & 255);
		}

		return sequence;
	}

	public function captureBlinkList(vis:Boolean):void
	{
		if (!blinkBitUsed)
			return;

		// Go through all cells identified as blinking and set visibility.
		blinkOnVis = vis;
		blinkList.length = 0;
		for (var cy:int = 0; cy < ySize; cy++)
		{
			for (var cx:int = 0; cx < xSize; cx++)
			{
				var locIdx:int = cy * ixSize + cx;
				if (attrs[locIdx] & 128)
				{
					changeBlinkForCell(cx, cy, vis);
					blinkList.push(cx);
					blinkList.push(cy);
				}
			}
		}
	}
	/*public function captureBlinkListOld(vis:Boolean):void
	{
		// Go through record of cells identified as blinking and restore FG visibility.
		var numBlink:int = blinkList.length;
		for (var i:int = 0; i < numBlink; i++)
		{
			var cell:Cell = cellArray[blinkList[i]];
			cell.bm.visible = true;
		}

		// Purge blink record and regenerate it.
		blinkList.length = 0;
		for (i = 0; i < totalCount; i++)
		{
			cell = cellArray[i];
			if (cell.myAttr & 128)
				blinkList.push(i);
		}

		// Update status.
		blinkToggleOld(vis);
	}*/

	public function blinkToggle(vis:Boolean):void
	{
		if (!blinkBitUsed)
			return;

		// Go through record of cells, altering FG visibility state.
		blinkOnVis = vis;
		var numBlink:int = blinkList.length;
		for (var i:int = 0; i < numBlink; i += 2)
		{
			var cx:int = blinkList[i];
			var cy:int = blinkList[i+1];
			changeBlinkForCell(cx, cy, vis);
		}
	}
	/*public function blinkToggleOld(vis:Boolean):void
	{
		// Go through record of cells, altering FG visibility state.
		blinkOnVis = vis;
		var numBlink:int = blinkList.length;
		for (var i:int = 0; i < numBlink; i++)
		{
			var cell:Cell = cellArray[blinkList[i]];
			cell.bm.visible = vis;
		}
	}*/
}

}

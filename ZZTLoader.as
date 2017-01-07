// ZZTLoader.as:  ZZT/SZT file loading functions.

package {
public class ZZTLoader {

import flash.utils.ByteArray;
import flash.utils.Endian;

public static var file:ByteArray;

// World properties
public static var worldType:int;
public static var baseSizeX:int;
public static var baseSizeY:int;
public static var baseOffset:int;
public static var numBoards:int;
public static var playerAmmo:int;
public static var playerGems:int;
public static var playerKeys:ByteArray;
public static var playerHealth:int;
public static var playerBoard:int;
public static var playerTorches:int;
public static var torchCycles:int;
public static var energizerCycles:int;
public static var playerScore:int;
public static var worldName:String;
public static var flagNames:Array;
public static var timePassed:int;
public static var locked:int;
public static var playerData:int;
public static var playerStones:int;

// Board storage
public static var boardData:Array;
public static var board:ZZTBoard;
public static var saveStates:Vector.<ZZTBoard> = new Vector.<ZZTBoard>();
public static var currentBoardSaveIndex:int;
public static var extraGuis:Object = new Object();
public static var extraMasks:Object = new Object();
public static var extraSoundFX:Object = new Object();
public static var customONAME:Object;
public static var extraLumps:Vector.<Lump> = new Vector.<Lump>();
public static var extraLumpBinary:Vector.<ByteArray> = new Vector.<ByteArray>();

// PWAD containers
public static var pwads:Object = new Object();
public static var pwadTypeMap:ByteArray;
public static var pwadDicts:Object = new Object();
public static var pwadDelDicts:Object = new Object();
public static var pwadCustCode:Array = [];
public static var pwadBoards:Array = [];
public static var pwadExtraLumps:Vector.<Lump> = new Vector.<Lump>();
public static var pwadExtraLumpBinary:Vector.<ByteArray> = new Vector.<ByteArray>();
public static var pwadBQUESTHACK:int = 0;

// Property overrides
public static var overridePropsZZT:Object = null;
public static var overridePropsSZT:Object = null;
public static var overridePropsGeneral:Object = null;
public static var overridePropsGenModern:Object = null;
public static var overridePropsGenClassic:Object = null;

// Default properties if not set:  ZZT-specific
public static var defaultPropsZZT:Object = {
	"GEMHEALTH" : 1,
	"MAXSTATELEMENTCOUNT" : 151,
	"CLASSICFLAGLIMIT" : 10,
	"NOPUTBOTTOMROW" : 1,
	"BECOMESAMECOLOR" : 0,
	"LIBERALCOLORCHANGE" : 0,
	"LEGACYTICK" : 1,
	"FREESCOLLING" : 0,
	"SENDALLENTER" : 0
};

// Default properties if not set:  SZT-specific
public static var defaultPropsSZT:Object = {
	"GEMHEALTH" : 10,
	"MAXSTATELEMENTCOUNT" : 129,
	"CLASSICFLAGLIMIT" : 16,
	"NOPUTBOTTOMROW" : 0,
	"BECOMESAMECOLOR" : 1,
	"LIBERALCOLORCHANGE" : 1,
	"LEGACYTICK" : 1,
	"FREESCOLLING" : 1,
	"SENDALLENTER" : 1
};

// Default properties if not set:  WAD-specific
public static var defaultPropsWAD:Object = {
	"GEMHEALTH" : 10,
	"MAXSTATELEMENTCOUNT" : 9999,
	"CLASSICFLAGLIMIT" : 100000,
	"NOPUTBOTTOMROW" : 0,
	"BECOMESAMECOLOR" : 0,
	"LIBERALCOLORCHANGE" : 0,
	"LEGACYTICK" : 0,
	"FREESCOLLING" : 0,
	"SENDALLENTER" : 0,
	"KEY0" : 0, "KEY1" : 0, "KEY2" : 0, "KEY3" : 0,
	"KEY4" : 0, "KEY5" : 0, "KEY6" : 0, "KEY7" : 0,
	"KEY8" : 0, "KEY9" : 0, "KEY10" : 0, "KEY11" : 0,
	"KEY12" : 0, "KEY13" : 0, "KEY14" : 0, "KEY15" : 0
};

// Default properties if not set:  General
public static var defaultPropsGeneral:Object = {
	// Gameplay
	"CONFIGTYPE" : 0,
	"GAMESPEED" : 4,
	"FASTESTFPS" : 30,
	"PLAYERDAMAGE" : 10,
	"SOUNDOFF" : 0,
	"IMMEDIATESCROLL" : 0,
	"ORIGINALSCROLL" : 0,
	"OVERLAYSCROLL" : 1,
	"KEYLIMIT" : 1,
	"KEYSBLOCKPLAYER" : 1,
	"POINTBLANKFIRING" : 1,
	"BLINKWALLBUMP" : 0,
	"TELOBJECT" : 0,
	"DETECTSCRIPTDEADLOCK" : 1,
	"PLAYRETENTION" : 1,
	"PLAYSYNC" : 1,
	"PLAYERRUNDELAY" : 8,
	"PLAYERFIREDELAY" : 8,
	"BLACKKEYGEMS" : 0,
	"BLACKDOORGEMS" : 0,
	"ALLCOLORKEYS" : 0,
	"MOUSEBEHAVIOR" : 3,
	"OBJECTDIEEMPTY" : 1,
	"REENTRYMOVESTYPE" : 0,
	"SCORELIMIT" : 2000000000,
	"BIT7ATTR" : 1,
	"SCANLINES" : 2,
	"BQUESTHACK" : 0,
	"ZSTONELABEL" : "Stone",
	"OLDTORCHBAR" : 0,
	"HIGHSCOREACTIVE" : 1,
	"HIGHSCOREMIN" : 100,
	"HIGHSCOREPROMPT" : 1,
	"MASTERVOLUME" : 50,
	"PLAYERCHARNORM" : 2,
	"PLAYERCOLORNORM" : 31,
	"PLAYERCHARHURT" : 1,
	"PLAYERCOLORHURT" : 127,
	"PAUSEANIMATED" : 1,
	"SITELOADCHOICE" : 3,
	"WATERSOUND" : 1,
	"WATERMSG" : 1,
	"INVISIBLESOUND" : 1,
	"INVISIBLEMSG" : 1,
	"FORESTSOUND" : 1,
	"FORESTMSG" : 1,
	"DUPSOUNDDIST" : 1000,
	"FAKEMSG" : 1,
	"MOUSEEDGENAV" : 1,
	"MOUSEEDGEPOINTER" : 1,
	"BOARDEDGETRANS" : 1,
	"ALLOWINGAMERESTORE" : 1,
	"ALLOWINGAMECONSOLE" : 1,
	"ALLOWINGAMECHEAT" : 1,
	"FASTCHEATFLAG" : 0,
	"ZZTGAMEGUI" : "ZZTGAME",
	"SZTGAMEGUI" : "SZTGAME",

	// Version
	"VERSION" : "1.1",

	// Autosave
	"AUTOSAVESECS" : 60,
	"BOARDCHANGESAVESECS" : 20,
	"REENTRYZAPSAVESECS" : 10,
	"MAXSAVESTATES" : 30,

	// Deployment
	"DEP_INDEXPATH" : "",
	"DEP_RECURSIVELEVEL" : 0,
	"DEP_INDEXRESOURCE" : "",
	"DEP_AUTORUNZIP" : 0,
	"DEP_STARTUPFILE" : "",
	"DEP_STARTUPGUI" : "DEBUGMENU",
	"DEP_EXTRAFILTER" : "",

	// -extras?-
	"PUTREMOVESTILE" : 1
};

// Altered general properties when option mode switched to "CLASSIC"
public static var classicPropChanges:Object = {
	"ORIGINALSCROLL" : 1,
	"OVERLAYSCROLL" : 0,
	"PLAYRETENTION" : 0,
	"BLACKKEYGEMS" : 1,
	"BLACKDOORGEMS" : 1,
	"REENTRYMOVESTYPE" : 1,
	"SCORELIMIT" : 32767,
	"OLDTORCHBAR" : 1,
	"BOARDEDGETRANS" : 2,
	"ALLOWINGAMERESTORE" : 0,
	"ALLOWINGAMECONSOLE" : 1,
	"ZZTGAMEGUI" : "CLASSICZZTGAME",
	"SZTGAMEGUI" : "CLASSICSZTGAME"
};

// General property subsets
public static var propSubsets:Object = {
	"DISPLAY" : ["BIT7ATTR", "SCANLINES", "SZTGAMEGUI", "ZZTGAMEGUI", "OLDTORCHBAR",
		"PLAYERCHARNORM", "PLAYERCOLORNORM", "PLAYERCHARHURT", "PLAYERCOLORHURT",
		"PAUSEANIMATED"],
	"GAMEPLAY" : ["ALLOWINGAMECHEAT", "ALLOWINGAMECONSOLE", "ALLOWINGAMERESTORE",
		"BLINKWALLBUMP", "FASTCHEATFLAG", "PLAYERDAMAGE", "POINTBLANKFIRING", "SCORELIMIT",
		"HIGHSCOREACTIVE", "HIGHSCOREMIN", "HIGHSCOREPROMPT"],
	"KEY" : ["ALLCOLORKEYS", "BLACKDOORGEMS", "BLACKKEYGEMS", "KEYLIMIT", "KEYSBLOCKPLAYER"],
	"MOVE" : ["BOARDEDGETRANS", "MOUSEBEHAVIOR", "MOUSEEDGENAV", "MOUSEEDGEPOINTER",
		"PLAYERFIREDELAY", "PLAYERRUNDELAY"],
	"TIMING" : ["FASTESTFPS", "GAMESPEED"],
	"SOUND" : ["FAKEMSG", "DUPSOUNDDIST", "INVISIBLEMSG", "INVISIBLESOUND", "PLAYRETENTION",
		"PLAYSYNC", "SOUNDOFF", "WATERMSG", "WATERSOUND", "FORESTMSG", "FORESTSOUND",
		"MASTERVOLUME" ],
	"SCROLL" : ["IMMEDIATESCROLL", "ORIGINALSCROLL", "OVERLAYSCROLL"]
};

// General property subset title names
public static var propSubsetNames:Object = {
	"DISPLAY" : "Display",
	"GAMEPLAY" : "Gameplay",
	"KEY" : "Key Usage",
	"MOVE" : "Movement",
	"TIMING" : "Timing",
	"SOUND" : "Sound/Msg",
	"SCROLL" : "Scrolls"
};

// Default sound effects
public static var defaultSoundFx:Object = {
	"PLAYERMOVE":		"Z00P01:@V40K0:0: T0",
	"FOREST":			"Z00P02:@V40K0:0: TA",
	"FORESTSZT0":		"Z00P03:@V40K0:0: T+F",
	"FORESTSZT1":		"Z00P03:@V40K0:0: T+C",
	"FORESTSZT2":		"Z00P03:@V40K0:0: T+G",
	"FORESTSZT3":		"Z00P03:@V40K0:0: T++C",
	"FORESTSZT4":		"Z00P03:@V40K0:0: T+F#",
	"FORESTSZT5":		"Z00P03:@V40K0:0: T+C#",
	"FORESTSZT6":		"Z00P03:@V40K0:0: T+G#",
	"FORESTSZT7":		"Z00P03:@V40K0:0: T++C#",
	"COLLECTGEM":		"Z00P04:@V40K0:0: T+C-GEC",
	"COLLECTAMMO":		"Z00P05:@V40K0:0: TCC#D",
	"COLLECTTORCH":		"Z00P06:@V40K0:0: TCASE",
	"PUSHER":			"Z00P08:@V40K0:0: T--F",
	"BREAKABLEHIT":		"Z00P09:@V40K0:0: -TC",
	"ALREADYHAVEKEY":	"Z00P10:@V40K0:0: SC-C",
	"READSCROLL":		"Z00P11:@V40K0:0: TC-C+D-D+E-E+F-F+G-G",
	"COLLECTKEY":		"Z00P12:@V40K0:0: +TCEGCEGCEGS+C",
	"OPENDOOR":			"Z00P13:@V40K0:0: TCGBCGBI+C",
	"DOORLOCKED":		"Z00P14:@V40K0:0: --TGC",
	"INVISIBLEWALL":	"Z00P15:@V40K0:0: T--DC",
	"WATERBLOCK":		"Z00P16:@V40K0:0: T+C+C",
	"DUPLICATE":		"Z00P20:@V40K0:0: SCDEFG",
	"DUPFAIL":			"Z00P21:@V40K0:0: --TG#F#",
	"BOMBTICK1":		"Z00P22:@V40K0:0: T8", // low
	"BOMBTICK2":		"Z00P23:@V40K0:0: T5", // high
	"BOMBACTIVATE":		"Z00P24:@V40K0:0: TCF+CF+C",
	"BOMBEXPLODE":		"Z00P25:@V40K0:0: T+++C-C-C-C-C-C",
	"TORCHOUT":			"Z00P26:@V40K0:0: TC-C-C",
	"PLAYERSHOOT":		"Z00P31:@V40K0:0: T+C-C-C",
	"OBJECTSHOOT":		"Z00P32:@V40K0:0: TC-F#",
	"RICOCHET":			"Z00P33:@V40K0:0: T9",
	"ENEMYDIE":			"Z00P34:@V40K0:0: TC--C++++C--C",
	"PLAYERHURT":		"Z00P35:@V40K0:0: T--C+C-C+D#",
	"TIMELOW":			"Z00P42:@V40K0:0: I.+CFC-F+CFQ.C",
	"ENERGIZER":		"Z00P43:@V40K0:0: S.-CD#EF+F-FD#C+C-CD#E+F-FD#C+C-CD#E+F-FD#C+C-CD#E+F-FD#C\
+C-CD#E+F-FD#C+C-CD#E+F-FD#C+C-CD#E+F-FD#C+C-CD#E+F-FD#C",
	"ENERGIZEREND":		"Z00P44:@V40K0:0: S.-C-A#GF#FD#C", // interrupts ENERGIZER
	"TRANSPORTER":		"Z00P46:@V40K0:0: TC+D-E+F#-G#+A#C+D",
	"PASSAGEMOVE":		"Z00P47:@V40K0:0: TCEGC#FG#DF#AD#GA#EG#+C",
	"OOPERROR":			"Z00P48:@V40K0:0: Q.++C",
	"DOSERROR":			"Z00P49:@V40K0:0: --S22I1S44I1S00", // guess; not easy to reproduce
	"GAMEOVER":			"Z00P50:@V40K0:0: S.-CD#G+C-GA#+DGFG#+CF---HC"
};

public static var sStateDesc:Array = [ "Quick", "Entry", "Zap", "Auto" ];

public static function establishZZTFile(b:ByteArray):Boolean {
	// Reset types back to defaults
	zzt.resetTypes();
	zzt.establishExtraTypes(new Object());
	extraGuis = new Object();
	extraLumps = new Vector.<Lump>();
	extraLumpBinary = new Vector.<ByteArray>();

	// Ensure type unification between ZZT and SZT.
	interp.typeTrans[69] = interp.typeTrans[18]; // Bullets -> ZZT
	interp.typeTrans[72] = interp.typeTrans[15]; // Stars -> ZZT
	interp.typeTrans[70] = interp.typeTrans[33]; // Horiz blink wall beam -> ZZT
	interp.typeTrans[71] = interp.typeTrans[43]; // Vert blink wall beam -> ZZT

	// Strip out non-built-in code blocks
	interp.zapRecord = new Vector.<ZapRecord>();
	interp.unCompCode = [];
	interp.unCompStart = new Vector.<int>();
	interp.numBuiltInCodeBlocksPlus = interp.numBuiltInCodeBlocks;
	if (interp.codeBlocks.length > interp.numBuiltInCodeBlocks)
		interp.codeBlocks.length = interp.numBuiltInCodeBlocks;

	// If Banana Quest hack is implemented, code compilation is affected.
	zzt.globalProps["BQUESTHACK"] = pwadBQUESTHACK;

	// Interpret file contents.
	file = b;
	file.endian = Endian.LITTLE_ENDIAN;

	// First few fields are common to both ZZT and SZT.
	worldType = file.readShort();
	zzt.loadedOOPType = worldType;
	numBoards = file.readShort() + 1;
	playerAmmo = file.readShort();
	playerGems = file.readShort();
	playerKeys = new ByteArray();
	file.readBytes(playerKeys, 0, 7);
	playerHealth = file.readShort();
	playerBoard = file.readShort();

	// Next few fields will depend on format.
	var i:int;
	if (worldType == -1)
	{
		// ZZT
		baseSizeX = 60;
		baseSizeY = 25;
		baseOffset = 512;
		playerTorches = file.readShort();
		torchCycles = file.readShort();
		energizerCycles = file.readShort();
		file.readShort(); // Unused
		playerScore = file.readShort();
		var worldNameLength:int = file.readByte();
		worldName = readExtendedASCIIString(file, worldNameLength);
		file.position = file.position + (20 - worldNameLength);

		flagNames = new Array(10);
		for (i = 0; i < 10; i++)
		{
			var flagNameLength:int = file.readByte();
			flagNames[i] = readExtendedASCIIString(file, flagNameLength);
			file.position = file.position + (20 - flagNameLength);
		}

		timePassed = file.readShort();
		playerData = file.readShort();
		locked = file.readByte();
		playerStones = 0;
		interp.typeTrans[19] = zzt.waterType;
	}
	else
	{
		// SZT
		baseSizeX = 96;
		baseSizeY = 80;
		baseOffset = 1024;
		file.readShort(); // Unused
		playerTorches = 0;
		playerScore = file.readShort();
		torchCycles = 0;
		file.readShort(); // Unused
		energizerCycles = file.readShort();
		worldNameLength = file.readByte();
		worldName = readExtendedASCIIString(file, worldNameLength);
		file.position = file.position + (20 - worldNameLength);

		flagNames = new Array(16);
		for (i = 0; i < 16; i++)
		{
			flagNameLength = file.readByte();
			flagNames[i] = readExtendedASCIIString(file, flagNameLength);
			file.position = file.position + (20 - flagNameLength);
		}

		timePassed = file.readShort();
		playerData = file.readShort();
		locked = file.readByte();
		playerStones = file.readShort();
		interp.typeTrans[19] = zzt.lavaType;
	}

	// Set up grid for size
	setUpGrid(baseSizeX, baseSizeY);

	// Remaining data is interpreted board-by-board.
	file.position = baseOffset;
	boardData = new Array(numBoards);
	for (i = 0; i < numBoards; i++)
	{
		boardData[i] = establishZZTBoard(i);
		if (boardData[i] == null)
			return false;
	}

	// Successfully loaded file.  Set global properties.
	setGlobalProperties();

	return true;
}

public static function getBoardName(boardNum:int, incTitle:Boolean=false):String {
	if (!incTitle && boardNum == 0)
		return "(None)";
	else if (boardNum < 0 || boardNum >= boardData.length)
		return "(None)";

	return (boardData[boardNum].props["BOARDNAME"]);
}

public static function establishZZTBoard(boardNum:int):ZZTBoard
{
	// Create new board storage object.
	board = new ZZTBoard();
	board.props = new Object();
	board.regions = new Object();
	board.saveStamp = "init";
	board.boardIndex = boardNum;
	board.saveIndex = 0;
	board.saveType = -1;

	// Get board size.
	if (file.position + 1 >= file.length)
	{
		trace("BOARD FORMAT ERROR:  Bad size in " + boardNum);
		file.position = file.length;
		return setBlankBoard(board);
	}

	var boardSize:int = file.readShort();
	var idealNextPos:int = file.position + (boardSize & 65535);

	// Detect possible sizing issues.
	var boardError:Boolean = false;
	if (boardSize >= -255 && boardSize <= 178)
		boardError = true;
	else if (worldType == -2 && boardSize >= 0 && boardSize < 206)
		boardError = true;
	if (idealNextPos > file.length)
	{
		idealNextPos = file.length;
		boardError = true;
	}

	if (boardError)
	{
		trace("BOARD FORMAT ERROR:  Bad size in " + boardNum);
		file.position = idealNextPos;
		return setBlankBoard(board);
	}

	var boardNameLength:int = file.readByte();
	board.props["BOARDNAME"] = readExtendedASCIIString(file, boardNameLength);
	if (worldType == -1)
		file.position = file.position + (50 - boardNameLength);
	else
		file.position = file.position + (60 - boardNameLength);

	// Create kind and color buffers.
	board.typeBuffer = new ByteArray();
	board.colorBuffer = new ByteArray();
	board.lightBuffer = new ByteArray();
	var totalSquares:int = baseSizeX * baseSizeY;
	board.props["SIZEX"] = baseSizeX;
	board.props["SIZEY"] = baseSizeY;

	// Unpack RLE data.
	for (var c:int = 0; c < totalSquares && file.position + 3 <= idealNextPos;)
	{
		var count:int = (file.readByte() - 1) & 255; // 256-count rollover possible
		var num:int = file.readUnsignedByte();
		var type:int = interp.typeTrans3(num);
		var color:int = file.readUnsignedByte();
		/*if (type == 0)
			color &= 15; // Force EMPTY to have black BG*/
		if (num == 9)
		{
			// Switch locations of FG and BG bits for DOOR
			color = (((color >> 4) & 15) ^ 8) + ((color << 4) & 240);
		}

		while (count >= 0)
		{
			board.lightBuffer[c] = 0;
			board.typeBuffer[c] = type;
			board.colorBuffer[c++] = color;
			count--;
		}
	}

	// Detect more sizing issues.
	if (file.position + 3 >= idealNextPos)
	{
		trace("BOARD FORMAT ERROR:  RLE overrun in " + boardNum);
		file.position = idealNextPos;
		return setBlankBoard(board);
	}

	if ((file.position + 88 > idealNextPos && worldType == -1) ||
		(file.position + 30 > idealNextPos && worldType == -2))
	{
		trace("BOARD FORMAT ERROR:  properties overrun in " + boardNum);
		file.position = idealNextPos;
		return setBlankBoard(board);
	}

	// Get board properties.
	board.props["MAXPLAYERSHOTS"] = file.readUnsignedByte();
	board.props["CURPLAYERSHOTS"] = 0;
	if (worldType == -1)
		board.props["ISDARK"] = file.readByte();
	else
		board.props["ISDARK"] = 0;
	board.props["EXITNORTH"] = file.readUnsignedByte();
	board.props["EXITSOUTH"] = file.readUnsignedByte();
	board.props["EXITWEST"] = file.readUnsignedByte();
	board.props["EXITEAST"] = file.readUnsignedByte();
	board.props["RESTARTONZAP"] = file.readByte();

	if (worldType == -1)
	{
		var messageLength:int = file.readByte();
		board.props["MESSAGE"] = readExtendedASCIIString(file, messageLength);
		file.position = file.position + (58 - messageLength);
	}
	else
		board.props["MESSAGE"] = "";

	board.props["FROMPASSAGEHACK"] = 0;
	board.props["PLAYERCOUNT"] = 0;
	board.props["PLAYERENTERX"] = file.readByte(); // Unused in SZT?
	board.props["PLAYERENTERY"] = file.readByte(); // Unused in SZT?
	if (worldType == -2)
	{
		board.props["CAMERAX"] = file.readShort();
		board.props["CAMERAY"] = file.readShort();
	}
	else
	{
		board.props["CAMERAX"] = 1;
		board.props["CAMERAY"] = 1;
	}

	board.props["TIMELIMIT"] = file.readShort();
	if (worldType == -1)
		file.position = file.position + 16;
	else
		file.position = file.position + 14;

	board.statElementCount = file.readShort() + 1;
	board.statLessCount = 0;

	// Load status elements
	var boardStartCodeID:int = interp.codeBlocks.length;
	board.playerSE = null;
	board.statElem = new Vector.<SE>();
	for (var i:int = 0; i < board.statElementCount; i++)
	{
		if ((file.position + 33 > idealNextPos && worldType == -1) ||
			(file.position + 25 > idealNextPos && worldType == -2))
		{
			trace("BOARD FORMAT ERROR:  SE overrun in " + boardNum);
			file.position = idealNextPos;
			return setBlankBoard(board);
		}

		// Get coordinates
		var statElemX:int = file.readByte();
		var statElemY:int = file.readByte();
		if (statElemX <= 0 || statElemY <= 0)
		{
			// Non-used status element?
			trace("Off-grid statElem: ", board.props["BOARDNAME"], statElemX, statElemY);
			file.position = file.position + 21;

			var statElemCodeLength:int = file.readShort();
			if (statElemCodeLength > 0)
				file.position += statElemCodeLength;

			if (worldType == -1)
				file.position = file.position + 8;

			continue;
		}

		// Establish type/color info at coordinates
		var st:int = board.typeBuffer[(statElemY-1) * baseSizeX + (statElemX-1)];
		var sc:int = board.colorBuffer[(statElemY-1) * baseSizeX + (statElemX-1)];

		if (st == 0 && worldType == -1)
		{
			// Create an alternate "wind tunnel" type (an odd exploit of ZZT engine)
			board.typeBuffer[(statElemY-1) * baseSizeX + (statElemX-1)] = zzt.windTunnelType;
			file.position = file.position + 21;

			statElemCodeLength = file.readShort();
			if (statElemCodeLength > 0)
				file.position += statElemCodeLength;

			if (worldType == -1)
				file.position = file.position + 8;

			continue;
		}

		// Create SE.
		var se:SE = new SE(st, statElemX, statElemY, sc, true);
		var eInfo:ElementInfo = SE.typeList[st];
		if (eInfo.NUMBER == 4 && !board.playerSE)
		{
			// This is the main player type.
			board.playerSE = se;
			board.playerSE.extra["CPY"] = 0;
		}

		// Read rest of SE fields
		var statElemStepX:int = file.readShort();
		var statElemStepY:int = file.readShort();
		var statElemCycle:int = file.readShort();
		var statElemP1:int = file.readUnsignedByte();
		var statElemP2:int = file.readUnsignedByte();
		var statElemP3:int = file.readUnsignedByte();
		var statElemFollower:int = file.readShort();
		var statElemLeader:int = file.readShort();
		var statElemUnderKind:int = interp.typeTrans2(file.readUnsignedByte());
		var statElemUnderColor:int = file.readUnsignedByte();
		var ptr:int = file.readInt();
		var statElemIP:int = file.readUnsignedShort();

		statElemCodeLength = file.readShort();
		if (worldType == -1)
			file.position = file.position + 8;

		if (!SE.typeList[statElemUnderKind].NoStat)
			statElemUnderKind = 0; // Fix common "same type under itself" error

		var newCodeId:int = -1;
		if (statElemCodeLength != 0 || eInfo.HasOwnCode)
		{
			if (statElemCodeLength > 0 && file.position + statElemCodeLength > idealNextPos)
			{
				trace("BOARD FORMAT ERROR:  code overrun in " + boardNum);
				file.position = idealNextPos;
				return setBlankBoard(board);
			}

			// ZZT-OOP code uses CR as line break.
			var statElemCode:String = readExtendedASCIIString(file, statElemCodeLength);
			if (statElemCode == "")
				statElemCode = pwadBQUESTHACK ? "#STP" : "#END";
			if (statElemCode.charAt(statElemCode.length - 1) == "\r")
				statElemCode = statElemCode.substring(0, statElemCode.length - 1);

			if (statElemCodeLength < 0)
			{
				// This is a #BIND'ed OBJECT.  We will need to reference the SE that
				// sponsors the real code.
				newCodeId = locateSponsorCodeId(-statElemCodeLength, i);
			}
			else
			{
				// Compile custom code.
				newCodeId = zzt.compileCustomCode(eInfo, statElemCode, "\r", statElemIP);
				if (newCodeId == -1)
					return null;
				var numPrefix:String = eInfo.NUMBER.toString() + "\r";
				interp.unCompStart.push(numPrefix.length);
				interp.unCompCode.push(numPrefix + statElemCode);
			}

			if (eInfo.NUMBER == 36)
			{
				// Objects change character to P1 and take locked status from P2.
				// We might also need to set the name immediately if defined on line 1.
				se.delay = 2;
				se.extra["CHAR"] = statElemP1;
				if (statElemP2 & 1)
					se.FLAGS |= interp.FL_LOCKED;
				if (statElemIP == 65535)
					se.FLAGS |= interp.FL_IDLE;
				if (oop.lastAssignedName != "")
					se.extra["ONAME"] = oop.lastAssignedName;
				if (statElemIP > 0)
					se.IP = oop.virtualIP;
			}
		}

		// Set SE fields in instance.
		se.myID = ++interp.nextObjPtrNum;
		se.STEPX = statElemStepX;
		se.STEPY = statElemStepY;
		se.CYCLE = statElemCycle;
		se.UNDERID = statElemUnderKind;
		se.UNDERCOLOR = statElemUnderColor;

		// Introduce quasi-random delays to SE to simulate disjointed
		// cycles in original engine, if cycle is not 1.
		if (se.CYCLE > 1)
		{
			se.delay += se.myID % se.CYCLE;
		}

		// The "extra" fields in the SE are included only if they are
		// requisitioned by the type.  No need to include "garbage."
		if (eInfo.extraVals.hasOwnProperty("P1"))
			se.extra["P1"] = statElemP1;
		if (eInfo.extraVals.hasOwnProperty("P2"))
			se.extra["P2"] = statElemP2;
		if (eInfo.extraVals.hasOwnProperty("P3"))
			se.extra["P3"] = statElemP3;
		if (eInfo.extraVals.hasOwnProperty("FOLLOWER"))
			se.extra["FOLLOWER"] = statElemFollower;
		if (eInfo.extraVals.hasOwnProperty("LEADER"))
			se.extra["LEADER"] = statElemLeader;
		if (newCodeId != -1)
			se.extra["CODEID"] = newCodeId;

		if (eInfo.NUMBER == 11)
		{
			// Passages should have color tweaked:  BG->FG slot.
			se.extra["P2"] = sc; // Original color spec
			sc = ((sc >> 4) & 15) ^ 8;
			board.colorBuffer[(statElemY-1) * baseSizeX + (statElemX-1)] = sc;
		}
		else if (eInfo.NUMBER == 4)
		{
			trace("Board=", board.props["BOARDNAME"]);
			board.props["PLAYERCOUNT"]++;
		}

		// Add SE to container.
		board.statElem.push(se);
	}

	// Here we need to address status element errors.  Sometimes a type requiring
	// SE does not have one defined.  If we don't have one defined, we must create
	// a simple one with default attributes.
	var csr:int = 0;
	for (var y:int = 0; y < baseSizeY; y++)
	{
		for (var x:int = 0; x < baseSizeX; x++)
		{
			st = board.typeBuffer[csr++]
			eInfo = SE.typeList[st];
			if (!eInfo.NoStat)
			{
				for (i = 0; i < board.statElem.length; i++)
				{
					if (board.statElem[i].X == x+1 && board.statElem[i].Y == y+1)
					{
						// Found; no problem.
						st = 0;
						break;
					}
				}

				if (st != 0)
				{
					// A "statless" type that needs to be a status element
					// is still given stats in ZZT Ultra.  However, it is put
					// into a special state that does not iterate and does not
					// respond to sent messages.
					sc = board.colorBuffer[y * baseSizeX + x];
					se = new SE(st, x+1, y+1, sc, true);
					board.statElem.push(se);
					//trace ("Repaired statElem error at ", (x+1), ",", (y+1));

					if (eInfo.NUMBER == 4)
					{
						if (board.playerSE)
						{
							se.FLAGS |= interp.FL_IDLE | interp.FL_LOCKED | interp.FL_NOSTAT;
							board.statLessCount++;
						}
						else
						{
							// Main player type; this saves a last-chance legit player.
							board.playerSE = se;
							board.playerSE.extra["CPY"] = 0;
						}
					}
					else
					{
						se.FLAGS |= interp.FL_IDLE | interp.FL_LOCKED | interp.FL_NOSTAT;
						board.statLessCount++;
					}
				}
			}
		}
	}

	board.statElementCount = board.statElem.length;
	if (board.statLessCount > 0)
		trace("Non-stat count:  ", board.statLessCount);

	return board;
}

// This is invoked when the format of a loaded board is broken
// and needs to be replaced with a mostly-empty shell.
public static function setBlankBoard(zb:ZZTBoard):ZZTBoard {
	// Default grid is all-empty with player in upper-left.
	zb.typeBuffer = new ByteArray();
	zb.colorBuffer = new ByteArray();
	zb.lightBuffer = new ByteArray();
	var totalSquares:int = baseSizeX * baseSizeY;

	zb.typeBuffer[0] = zzt.playerType;
	zb.colorBuffer[0] = 31;
	zb.lightBuffer[0] = 0;
	for (var i:int = 1; i < totalSquares; i++) {
		zb.typeBuffer[i] = 0;
		zb.colorBuffer[i] = 15;
		zb.lightBuffer[i] = 0;
	}

	// Board properties are sensible defaults.
	zb.props["BOARDNAME"] = "ERROR!";
	zb.props["SIZEX"] = baseSizeX;
	zb.props["SIZEY"] = baseSizeY;
	zb.props["MAXPLAYERSHOTS"] = 255
	zb.props["CURPLAYERSHOTS"] = 0;
	zb.props["ISDARK"] = 0;
	zb.props["EXITNORTH"] = 0;
	zb.props["EXITSOUTH"] = 0;
	zb.props["EXITWEST"] = 0;
	zb.props["EXITEAST"] = 0;
	zb.props["RESTARTONZAP"] = 0;
	zb.props["MESSAGE"] = "";
	zb.props["FROMPASSAGEHACK"] = 0;
	zb.props["PLAYERCOUNT"] = 1;
	zb.props["PLAYERENTERX"] = 1;
	zb.props["PLAYERENTERY"] = 1;
	zb.props["CAMERAX"] = 1;
	zb.props["CAMERAY"] = 1;
	zb.props["TIMELIMIT"] = 0
	zb.statElementCount = 1;
	zb.statLessCount = 0;

	// Status elements include only player.
	zb.statElem = new Vector.<SE>();
	var se:SE = new SE(zzt.playerType, 1, 1, 31, true);
	se.myID = ++interp.nextObjPtrNum;
	se.UNDERID = 0;
	se.extra["CPY"] = 0;
	zb.playerSE = se;
	zb.statElem.push(se);

	return zb;
}

public static function locateSponsorCodeId(findIdx:int, curIdx:int):int {
	if (findIdx < curIdx)
	{
		// This is easy to find:  we already processed the status element
		// and its code.
		var testSE:SE = board.statElem[findIdx];
		return (testSE.extra["CODEID"]);
	}

	// Otherwise, the status element is downstream in the parse order.  We will
	// need to locate an object with its own code at the index, and then infer
	// what its code ID will be.
	var nextCodeId:int = interp.codeBlocks.length;
	var origPos:int = file.position;
	while (++curIdx < board.statElementCount)
	{
		// Get location.
		var testX:int = file.readByte();
		var testY:int = file.readByte();

		// Advance to code length.
		file.position = file.position + 21;
		var testCodeLength:int = file.readShort();
		if (findIdx == curIdx)
		{
			if (testCodeLength >= 0)
			{
				// Found it.
				file.position = origPos;
				return nextCodeId;
			}
		}

		// Skip ZZT 8 bytes if needed.
		if (worldType == -1)
			file.position = file.position + 8;

		// Skip code.
		if (testCodeLength >= 0)
		{
			file.position = file.position + testCodeLength;

			// If this was an OBJECT or SCROLL, we need to
			// advance expected code ID.
			if (testX > 0 && testY > 0)
			{
				var st:int = board.typeBuffer[(testY-1) * baseSizeX + (testX-1)];
				var eInfo:ElementInfo = SE.typeList[st];
				if (eInfo.NUMBER == 10 || eInfo.NUMBER == 36)
				{
					nextCodeId++;
				}
			}
		}
	}

	// It is possible that the #BIND destination got logically corrupted
	// somehow, and does not actually point to valid code.  If this happens,
	// assume the code block is empty and unbound.
	file.position = origPos;
	return -1;
}

public static function setOverridePropDefaults():void {
	// Extract overrides from defaults
	var k:String;
	overridePropsZZT = new Object();
	for (k in defaultPropsZZT)
		overridePropsZZT[k] = defaultPropsZZT[k];

	overridePropsSZT = new Object();
	for (k in defaultPropsSZT)
		overridePropsSZT[k] = defaultPropsSZT[k];

	overridePropsGenModern = new Object();
	overridePropsGenClassic = new Object();
	for (k in defaultPropsGeneral) {
		overridePropsGenModern[k] = defaultPropsGeneral[k];
		overridePropsGenClassic[k] = defaultPropsGeneral[k];
	}

	for (k in classicPropChanges) {
		overridePropsGenClassic[k] = classicPropChanges[k];
	}
}

public static function setGlobalProperties():void {
	// -WORLD PROPERTIES-
	zzt.globalProps["WORLDTYPE"] = worldType;
	zzt.globalProps["WORLDNAME"] = worldName;
	zzt.globalProps["LOCKED"] = locked;
	zzt.globalProps["NUMBOARDS"] = numBoards;
	zzt.globalProps["NUMBASECODEBLOCKS"] = interp.numBuiltInCodeBlocks;
	zzt.globalProps["NUMCLASSICFLAGS"] = 0;
	zzt.globalProps["CODEDELIMETER"] = "\r";

	// -INVENTORY PROPERTIES-
	zzt.globalProps["STARTBOARD"] = playerBoard;
	zzt.globalProps["BOARD"] = -1;
	zzt.globalProps["AMMO"] = playerAmmo;
	zzt.globalProps["GEMS"] = playerGems;
	zzt.globalProps["HEALTH"] = playerHealth;
	zzt.globalProps["TORCHES"] = playerTorches;
	zzt.globalProps["SCORE"] = playerScore;
	zzt.globalProps["TIME"] = timePassed;
	zzt.globalProps["Z"] = playerStones;
	zzt.globalProps["TORCHCYCLES"] = torchCycles;
	zzt.globalProps["ENERGIZERCYCLES"] = energizerCycles;
	for (var i:int = 0; i < 7; i++)
	{
		var kCount:int = i + 9; // Starts at BLUE
		zzt.globalProps["KEY" + kCount.toString()] = playerKeys[i];
	}

	zzt.globalProps["KEY0"] = 0;
	zzt.globalProps["KEY1"] = 0;
	zzt.globalProps["KEY2"] = 0;
	zzt.globalProps["KEY3"] = 0;
	zzt.globalProps["KEY4"] = 0;
	zzt.globalProps["KEY5"] = 0;
	zzt.globalProps["KEY6"] = 0;
	zzt.globalProps["KEY7"] = 0;
	zzt.globalProps["KEY8"] = 0;

	// Property overrides
	var k:String;
	if (worldType == -1)
	{
		for (k in overridePropsZZT)
			zzt.globalProps[k] = overridePropsZZT[k];

		// Setting SCORE as a config property is considered cheating.
		if (zzt.CHEATING_DISABLES_PROGRESS && overridePropsZZT.hasOwnProperty("SCORE"))
			zzt.DISABLE_HISCORE = 1;
	}
	else if (worldType == -2)
	{
		for (k in overridePropsSZT)
			zzt.globalProps[k] = overridePropsSZT[k];

		// Setting SCORE as a config property is considered cheating.
		if (zzt.CHEATING_DISABLES_PROGRESS && overridePropsSZT.hasOwnProperty("SCORE"))
			zzt.DISABLE_HISCORE = 1;
	}

	for (k in overridePropsGeneral)
		zzt.globalProps[k] = overridePropsGeneral[k];

	// Setting SCORE as a config property is considered cheating.
	if (zzt.CHEATING_DISABLES_PROGRESS && overridePropsGeneral.hasOwnProperty("SCORE"))
		zzt.DISABLE_HISCORE = 1;

	// Global variables (from flags)
	zzt.globals = new Object();
	for (i = 0; i < flagNames.length; i++)
	{
		if (flagNames[i].length > 0)
		{
			// Flags are Boolean; always set to 1
			zzt.globals[flagNames[i]] = 1;
			zzt.globalProps["NUMCLASSICFLAGS"] += 1;
			zzt.globalProps["LASTCLASSICFLAG"] = flagNames[i];

			// In SZT, Z label is set when a flag starts with Z
			if (worldType == -2 && flagNames[i].charAt(0) == "Z")
				zzt.globalProps["ZSTONELABEL"] = flagNames[i].substr(1);
		}
	}

	// Masks set to standard sizes for ZZT or SZT
	if (worldType == -1)
	{
		zzt.addMask("TORCH", zzt.stdTorchMask);
		zzt.addMask("BOMB", zzt.stdBombMask);
	}
	else if (worldType == -2)
	{
		zzt.addMask("TORCH", zzt.stdTorchMask);
		zzt.addMask("SZTBOMB", zzt.sztBombMask);
	}

	// Sound effects set to default for ZZT or SZT
	if (worldType == -1 || worldType == -2)
	{
		for (k in defaultSoundFx)
			zzt.soundFx[k] = defaultSoundFx[k];
	}

	// Patch using active PWAD (establishPWAD should have been called already)
	pwadPatch();

	// Update master volume.
	Sounds.setMasterVolume(zzt.globalProps["MASTERVOLUME"]);

	// Reset save state container
	saveStates = new Vector.<ZZTBoard>();
	currentBoardSaveIndex = 0;
}

// Update world from active PWAD info
public static function pwadPatch():void {
	// Patch dictionaries
	if (pwadDicts.hasOwnProperty("WORLDHDR"))
		replaceDict(zzt.globalProps, pwadDicts["WORLDHDR"], pwadDelDicts["WORLDHDR"]);
	zzt.globalProps["NUMBOARDS"] = numBoards;

	if (pwadDicts.hasOwnProperty("GLOBALS "))
		replaceDict(zzt.globals, pwadDicts["GLOBALS "], pwadDelDicts["GLOBALS "]);

	if (pwadDicts.hasOwnProperty("SOUNDFX "))
		replaceDict(zzt.soundFx, pwadDicts["SOUNDFX "], pwadDelDicts["SOUNDFX "]);

	if (pwadDicts.hasOwnProperty("MASKS   "))
	{
		for (var k:String in pwadDicts["MASKS   "])
			zzt.addMask(k, pwadDicts["MASKS   "][k]);
	}

	// TBD
	//if (pwadDicts.hasOwnProperty("EXTRATYP"))
	//	replaceDict(zzt.globals, pwadDicts["GLOBALS "], pwadDelDicts["GLOBALS "]);

	// TBD
	//if (pwadDicts.hasOwnProperty("EXTRAGUI"))
	//	replaceDict(zzt.globals, pwadDicts["EXTRAGUI"], pwadDelDicts["EXTRAGUI"]);

	// Append extra PWADs.
	extraLumps = extraLumps.concat(pwadExtraLumps);
	extraLumpBinary = extraLumpBinary.concat(pwadExtraLumpBinary);

	// Compile custom code.
	var iwadHighestCustomCodeID:int = interp.codeBlocks.length;
	var pwadLowestCustomCodeID:int = zzt.globalProps["PWADLOWESTCUSTOMCODEID"];
	customONAME = new Object();

	zzt.loadedOOPType = -3;
	for (var i:int = 0; i < pwadCustCode.length; i++) {
		var codeStr:String = pwadCustCode[i];
		if (codeStr == "")
			codeStr = pwadBQUESTHACK ? "#STP" : "#END";

		// Add code block.
		interp.unCompCode.push(codeStr);

		var eLoc:int = codeStr.indexOf("\n");
		var codeSrcType:String = codeStr.substr(0, eLoc);
		var unCompCodeId:int = interp.typeTrans2(int(codeSrcType));
		var eInfo:ElementInfo = SE.typeList[unCompCodeId];
		codeStr = codeStr.substr(eLoc+1);
		interp.unCompStart.push(eLoc+1);

		// Add to code blocks
		var newCodeId:int = zzt.compileCustomCode(eInfo, codeStr);
		if (oop.lastAssignedName != "")
			customONAME[newCodeId.toString()] = oop.lastAssignedName;
	}
	zzt.loadedOOPType = worldType;

	// Patch individual boards
	for (i = 0; i < pwadBoards.length; i++) {
		var pwb:Array = pwadBoards[i];
		var hdrDict:Object = pwb[0];
		var hdrDelDict:Object = pwb[1];
		var rgnDict:Object = pwb[2];
		var rgnDelDict:Object = pwb[3];
		var seArray:Array = pwb[4];
		var typeBuffer:ByteArray = pwb[5];
		var colorBuffer:ByteArray = pwb[6];
		var lightBuffer:ByteArray = pwb[7];
		var zb:ZZTBoard = boardData[i];

		// Replace dictionaries
		replaceDict(zb.props, hdrDict, hdrDelDict);
		replaceDict(zb.regions, rgnDict, rgnDelDict);

		// Patch grid data
		var sizeX:int = zb.props["SIZEX"];
		var sizeY:int = zb.props["SIZEY"];
		for (var y:int = 0; y < sizeY; y++) {
			for (var x:int = 0; x < sizeX; x++) {
				// Check updated type
				var newType:int = typeBuffer[sizeX * y + x];
				if (newType == zzt.patchType)
					continue; // Nothing to patch at this square

				// Patch grid
				var newColor:int = colorBuffer[sizeX * y + x];
				var newLit:int = lightBuffer[sizeX * y + x];
				zb.typeBuffer[sizeX * y + x] = newType;
				zb.colorBuffer[sizeX * y + x] = newColor;
				zb.lightBuffer[sizeX * y + x] = newLit;
			}
		}

		// Added/Modded status elements
		for (var j:int = 0; j < seArray.length; j++) {
			var o:Object = seArray[j];
			x = o["X"];
			y = o["Y"];

			// Remove old status element copies at identified location
			var insertionLoc:int = -1;
			for (var s:int = 0; s < zb.statElem.length; s++) {
				var se:SE = zb.statElem[s];
				if (se.X == x && se.Y == y)
				{
					insertionLoc = s;
					zb.statElem.splice(s, 1);
					s--;
				}
			}

			// The "zero" type cannot be a status element; it indicates removal only.
			if (o["TYPE"] != 0)
			{
				// Nonzero types indicate an added or replaced status element.
				var st:int = zb.typeBuffer[sizeX * (y - 1) + (x - 1)];
				var sc:int = zb.colorBuffer[sizeX * (y - 1) + (x - 1)];
				eInfo = SE.typeList[st];
				se = new SE(st, x, y, sc, true);

				if (o.hasOwnProperty("IP"))
					se.IP = o["IP"];
				if (o.hasOwnProperty("FLAGS"))
					se.FLAGS = o["FLAGS"];
				if (o.hasOwnProperty("delay"))
					se.delay = o["delay"];
				se.myID = ++interp.nextObjPtrNum;

				if (o.hasOwnProperty("UNDERID"))
					se.UNDERID = interp.typeTrans2(o["UNDERID"]);
				else
					se.UNDERID = 0;
				if (o.hasOwnProperty("UNDERCOLOR"))
					se.UNDERCOLOR = o["UNDERCOLOR"];
				else
					se.UNDERCOLOR = 0;
				if (o.hasOwnProperty("CYCLE"))
					se.CYCLE = o["CYCLE"];
				else
					se.CYCLE = eInfo.CYCLE;
				if (o.hasOwnProperty("STEPX"))
					se.STEPX = o["STEPX"];
				else
					se.STEPY = eInfo.STEPY;
				if (o.hasOwnProperty("STEPY"))
					se.STEPY = o["STEPY"];
				else
					se.STEPY = eInfo.STEPY;

				var e:String;
				for (e in o)
				{
					if (!se.hasOwnProperty(e))
						se.extra[e] = o[e];
				}

				// Adjust CODEID if it is present to point to added custom IDs.
				if (se.extra.hasOwnProperty("CODEID"))
					se.extra["CODEID"] += iwadHighestCustomCodeID - pwadLowestCustomCodeID;

				// If next command is a @name, assign ONAME member.
				if ((se.FLAGS & interp.FL_IDLE) == 0 && eInfo.HasOwnCode)
				{
					if (se.extra.hasOwnProperty("CODEID"))
					{
						var codeIdStr:String = se.extra["CODEID"].toString();
						if (customONAME.hasOwnProperty(codeIdStr))
							se.extra["ONAME"] = customONAME[codeIdStr];
					}
				}

				if (insertionLoc == -1)
					zb.statElem.push(se);
				else
					zb.statElem.splice(insertionLoc, 0, se);
			}
		}

		// Player SE might have been moved; reset if needed.
		if (zb.statElem.length > 0)
			zb.playerSE = zb.statElem[0];
		else
			zb.playerSE = null;

		for (j = 0; j < zb.statElem.length; j++)
		{
			if (zb.statElem[j].myID == zb.props["$PLAYER"] && zb.props["$PLAYER"] > 0)
			{
				zb.playerSE = zb.statElem[j];
				break;
			}
		}

		if (zb.playerSE != null)
			zb.props["$PLAYER"] = zb.playerSE.myID;
	}
}

// In case the real-time grid containers are undersized for this board,
// expand them so that they encompass the board grid dimensions plus a border.
public static function ensureGridSpace(gridBoundX:int, gridBoundY:int):void {
	var squares:int = (gridBoundX + 2) * (gridBoundY + 2);

	if (zzt.tg.length < squares)
		zzt.tg.length = squares;
	if (zzt.cg.length < squares)
		zzt.cg.length = squares;
	if (zzt.lg.length < squares)
		zzt.lg.length = squares;
	if (zzt.sg.length < squares)
		zzt.sg.length = squares;
}

// Establish the grid for the board; ring it with board edge tiles
public static function setUpGrid(gridBoundX:int, gridBoundY:int, dimsOnly:Boolean=false):void {
	// Set grid boundaries
	SE.gridWidth = gridBoundX;
	SE.gridHeight = gridBoundY;
	SE.fullGridWidth = gridBoundX + 2;
	SE.fullGridHeight = gridBoundY + 2;
	interp.allRegion[1][0] = gridBoundX;
	interp.allRegion[1][1] = gridBoundY;

	if (dimsOnly)
		return;

	// Place board edge type around grid
	for (var i:int = 0; i < SE.fullGridWidth; i++)
	{
		SE.setType(i, 0, zzt.bEdgeType);
		SE.setColor(i, 0, 14);
		SE.setType(i, SE.gridHeight + 1, zzt.bEdgeType);
		SE.setColor(i, SE.gridHeight + 1, 14);
	}
	for (i = 0; i < SE.fullGridHeight; i++)
	{
		SE.setType(0, i, zzt.bEdgeType);
		SE.setColor(0, i, 14);
		SE.setType(SE.gridWidth + 1, i, zzt.bEdgeType);
		SE.setColor(SE.gridWidth + 1, i, 14);
	}
}

// Destroy all board states beyond the specified save index.
// Use default to wipe all board states.
public static function wipeBoardStates(lowerIndex:int=-1):void {
	// Note that this function will intentionally "miss"
	// the initial state used to characterize the title screen when
	// it is first loaded.  This is because we need to have a workable
	// "reset" state when the user quits a game and wants to start over.
	for (var j:int = 1; j < saveStates.length; j++)
	{
		if (saveStates[j].saveIndex > lowerIndex)
		{
			saveStates.splice(j, 1);
			j--;
		}
	}

	// Bump save index back to relevant point.
	currentBoardSaveIndex = lowerIndex;
	if (currentBoardSaveIndex < 0)
		currentBoardSaveIndex = 0;
}

// Revert all boards back to original state, including title screen.
// This is used when a world is edited.
public static function wipeBoardZero():void {
	while (saveStates.length > 0)
		saveStates.pop();

	currentBoardSaveIndex = 0;
}

// Reverse the timeline of the zap/restore record until save index reached.
public static function rewindZapRecord(lowerIndex:int):void {
	for (var i:int = interp.zapRecord.length - 1; i >= 0; i--)
	{
		// Get info.
		var zr:ZapRecord = interp.zapRecord[i];
		if (zr.saveIndex <= lowerIndex)
			break; // Done.

		var labelLoc:int = zr.labelLoc;
		var cBlock:Array = interp.codeBlocks[zr.codeID];
		if (labelLoc >= 0)
		{
			// Undo zap
			cBlock[labelLoc] = oop.CMD_LABEL;
		}
		else
		{
			// Undo restore
			cBlock[-labelLoc] = oop.CMD_COMMENT;
		}

		// Remove record instance.
		interp.zapRecord.pop();
	}
}

// Apply the timeline of the zap/restore record to uncompiled code.
// This is done in preparation for writing the modified code to a file.
public static function applyZapRecord():void {
	for (var i:int = 0; i < interp.zapRecord.length; i++)
	{
		// Get info.
		var zr:ZapRecord = interp.zapRecord[i];
		var labelLoc:int = zr.labelLoc;
		var cBlock:Array = interp.codeBlocks[zr.codeID];
		var unCompID:int = zr.codeID - interp.numBuiltInCodeBlocksPlus;

		if (labelLoc >= 0)
		{
			// Register zap
			var unCompLoc:int = cBlock[labelLoc + 2] + interp.unCompStart[unCompID];
			interp.unCompCode[unCompID] = interp.unCompCode[unCompID].substring(0, unCompLoc) +
				"'" + interp.unCompCode[unCompID].substring(unCompLoc + 1);
		}
		else
		{
			// Register restore
			unCompLoc = cBlock[-labelLoc + 2] + interp.unCompStart[unCompID];
			interp.unCompCode[unCompID] = interp.unCompCode[unCompID].substring(0, unCompLoc) +
				":" + interp.unCompCode[unCompID].substring(unCompLoc + 1);
		}
	}
}

// Clone the zap record for a specific code block.
public static function cloneZapRecord(forCodeID:int, newCodeID:int):void {
	var origLen:int = interp.zapRecord.length;
	for (var i:int = 0; i < origLen; i++)
	{
		var zr:ZapRecord = interp.zapRecord[i];
		if (zr.codeID == forCodeID)
			interp.zapRecord.push(
				new ZapRecord(newCodeID, zr.labelLoc, 1, currentBoardSaveIndex));
	}
}

// Reset state of global variables and world properties to a specific state.
public static function resetGlobalProps(bState:ZZTBoard):void {
	zzt.globalProps = new Object();
	zzt.globals = new Object();
	Sounds.globalProps = zzt.globalProps;

	for (var k:Object in bState.worldProps)
		zzt.globalProps[k] = bState.worldProps[k];
	for (k in bState.worldVars)
		zzt.globals[k] = bState.worldVars[k];
}

// Locate a save state that matches the board index and save index.
public static function getBoardState(boardNum:int, saveIndex:int):ZZTBoard {
	for (var j:int = 0; j < saveStates.length; j++)
	{
		if (saveStates[j].boardIndex == boardNum && saveStates[j].saveIndex == saveIndex)
			return (saveStates[j]);
	}

	return null;
}

// Like getBoardState, except that latest instance is always returned,
// include non-accessed original if necessary.  The current board can
// be registered as a state if it is the one requested.
public static function latestBoardState(boardNum:int, autoReg:Boolean=false):ZZTBoard {
	if (boardNum < 0)
		return null;

	var bState:ZZTBoard = null;
	for (var j:int = 0; j < saveStates.length; j++)
	{
		if (saveStates[j].boardIndex == boardNum)
		{
			// Take latest (or only) state for board.
			if (bState == null)
				bState = saveStates[j];
			else if (saveStates[j].saveIndex > bState.saveIndex)
				bState = saveStates[j];
		}
	}

	// If board matches current, register current board state at same level.
	if (autoReg && boardNum == zzt.globalProps["BOARD"])
	{
		// If the current board had never been registered, choose save index of zero.
		if (bState == null)
		{
			registerBoardState();
			bState = getBoardState(boardNum, 0);
		}
		else
			registerBoardState();
	}

	// If board does not match current, just pull from stored board data if
	// auto-registering unloaded data.
	if (autoReg && bState == null)
		bState = boardData[boardNum];

	return bState;
}

public static function registerBoardState(
	targetOriginal:Boolean=false, newX:int=-1, newY:int=-1):Boolean {
	// Write back current board's type info to the last save state slot.
	// There won't be anything to write back if the world had just been loaded,
	// and no board had been selected.
	var oldBoardNum:int = zzt.globalProps["BOARD"];
	var oldBoard:ZZTBoard = null;
	if (targetOriginal)
		oldBoard = boardData[oldBoardNum];
	else
		oldBoard = latestBoardState(oldBoardNum);

	if (oldBoard != null)
	{
		// Write back data.
		var sizeX:int = oldBoard.props["SIZEX"];
		var sizeY:int = oldBoard.props["SIZEY"];

		var padX:int = 0;
		if (newX != -1)
		{
			if (newX < sizeX)
				sizeX = newX;
			else
				padX = newX - sizeX;
		}
		if (newY != -1)
		{
			if (newY <= sizeY)
				newY = -1;
		}

		// Copy working grid to board grids.
		var csr:int = 0;
		for (var y:int = 0; y < sizeY; y++)
		{
			for (var x:int = 0; x < sizeX; x++)
			{
				oldBoard.typeBuffer[csr] = SE.getType(x + 1, y + 1);
				oldBoard.colorBuffer[csr] = SE.getColor(x + 1, y + 1);
				oldBoard.lightBuffer[csr] = SE.getLit(x + 1, y + 1);
				csr++;
			}

			for (x = 0; x < padX; x++)
			{
				// Empty-fill the right-expanded portion
				oldBoard.typeBuffer[csr] = 0;
				oldBoard.colorBuffer[csr] = 15;
				oldBoard.lightBuffer[csr] = 0;
				csr++;
			}
		}

		csr = sizeY * newX;
		for (y = sizeY; y < newY; y++)
		{
			for (x = 0; x < newX; x++)
			{
				// Empty-fill the down-expanded portion
				oldBoard.typeBuffer[csr] = 0;
				oldBoard.colorBuffer[csr] = 15;
				oldBoard.lightBuffer[csr] = 0;
				csr++;
			}
		}

		// Set timestamp.
		var d:Date = new Date();
		oldBoard.saveStamp = oldBoard.props["BOARDNAME"] + " : " + d.toTimeString();

		// Save snapshot of world properties and global variables.
		// Although not strictly related to the board itself, the
		// snapshot is necessary for restoration purposes.
		oldBoard.worldProps = new Object();
		oldBoard.worldVars = new Object();
		for (var k:Object in zzt.globalProps)
			oldBoard.worldProps[k] = zzt.globalProps[k];
		for (k in zzt.globals)
			oldBoard.worldVars[k] = zzt.globals[k];

		return true;
	}

	return false;
}

// This function does not update any visuals.  Updates must be
// performed using a special command, like DISSOLVEVIEWPORT.
// Set saveIndex to -1 to switch to the latest board state.
public static function switchBoard(boardNum:int, saveIndex:int = -1):Boolean {
	if (boardNum < 0 && boardNum >= boardData.length)
		return false;

	// Ensure movement destination is cancelled.
	input.c2MDestX = -1;
	input.c2MDestY = -1;

	// Register existing board state.
	registerBoardState();

	// Locate board in the saved states.
	var newBoard:ZZTBoard = null;
	if (saveIndex == -1)
	{
		// Fetch latest board.
		newBoard = latestBoardState(boardNum);
	}
	else
	{
		// Fetch from specific save index.
		newBoard = getBoardState(boardNum, saveIndex);
	}

	if (newBoard == null)
	{
		// If no board present, we hadn't yet tried to switch to that board,
		// and we must make a copy.
		newBoard = copyBaseBoard(boardNum);
	}
	else if (newBoard.saveIndex < currentBoardSaveIndex && boardNum != 0)
	{
		// If the present board is of a save index further back,
		// we must make a copy to prevent confusion with earlier ones.
		newBoard = copyBoardState(newBoard);
		newBoard.saveIndex = currentBoardSaveIndex;
		newBoard.saveType = -1;
		saveStates.push(newBoard);
	}

	// Update global containers to reflect new board.
	updateContFromBoard(boardNum, newBoard);
	return true;
}

public static function updateContFromBoard(boardNum:int, newBoard:ZZTBoard):void {
	// Set the global containers to reflect new board.
	zzt.boardProps = newBoard.props;
	zzt.regions = newBoard.regions;
	zzt.statElem = newBoard.statElem;
	SE.statElem = newBoard.statElem;
	SE.statLessCount = newBoard.statLessCount;
	SE.IsDark = newBoard.props["ISDARK"];
	SE.CameraX = newBoard.props["CAMERAX"];
	SE.CameraY = newBoard.props["CAMERAY"];

	zzt.globalProps["BOARD"] = boardNum;
	interp.playerSE = newBoard.playerSE;

	if (newBoard.playerSE)
	{
		if (newBoard.playerSE.myID <= 0)
			newBoard.playerSE.myID = ++interp.nextObjPtrNum;
		zzt.globals["$PLAYER"] = newBoard.playerSE.myID;
	}

	// "Fence in" the content.
	var sizeX:int = newBoard.props["SIZEX"];
	var sizeY:int = newBoard.props["SIZEY"];
	setUpGrid(sizeX, sizeY);

	// Copy board grids to working grid.
	var csr:int = 0;
	for (var y:int = 0; y < sizeY; y++)
	{
		for (var x:int = 0; x < sizeX; x++)
		{
			SE.setType(x + 1, y + 1, newBoard.typeBuffer[csr]);
			SE.setColor(x + 1, y + 1, newBoard.colorBuffer[csr], false);
			SE.setLit(x + 1, y + 1, newBoard.lightBuffer[csr]);
			SE.setStatElemAt(x + 1, y + 1, null);
			csr++;
		}
	}

	// Update status element linkages.
	for (var i:int = 0; i < newBoard.statElem.length; i++)
	{
		var se:SE = newBoard.statElem[i];
		if (se.FLAGS & interp.FL_GHOST)
			continue;

		if (SE.getStatElemAt(se.X, se.Y) != null)
		{
			// This is usually from a bug in the editor.  "Kill" the secondary
			// status element to prevent it from resulting in odd "duplication."
			trace("WARNING:  Multiple statElem at: ", se.X, se.Y);
			se.FLAGS = interp.FL_IDLE | interp.FL_LOCKED | interp.FL_DEAD;
		}
		else
		{
			SE.setStatElemAt(se.X, se.Y, se);
		}
	}
}

// Save a snapshot of the current board state using the save type (0-3).
public static function saveBoardState(saveType:int):void {
	// Get board number.  We can't save the title screen because of
	// continuity constraints; it is forward-only while the world is open.
	// All other boards can be saved.
	var boardNum:int = zzt.globalProps["BOARD"];
	if (boardNum == 0)
		return;

	// Register existing board state.
	registerBoardState();

	// Get latest board; archive this as the "official" save state
	// that shows up in the restore interface.
	var oldBoard:ZZTBoard = latestBoardState(boardNum);
	oldBoard.saveIndex = currentBoardSaveIndex;
	oldBoard.saveType = saveType;

	// Make copy and advance save index.
	var newBoard:ZZTBoard = copyBoardState(oldBoard, true);
	newBoard.saveIndex = ++currentBoardSaveIndex;
	newBoard.saveType = -1;
	saveStates.push(newBoard);

	// Set the global containers to reflect newly copied board state.
	zzt.boardProps = newBoard.props;
	zzt.regions = newBoard.regions;
	zzt.statElem = newBoard.statElem;
	SE.statElem = newBoard.statElem;
	SE.statLessCount = newBoard.statLessCount;
	interp.playerSE = newBoard.playerSE;
	if (newBoard.playerSE)
		zzt.globals["$PLAYER"] = newBoard.playerSE.myID;

	// Purge status element linkages.
	var sizeX:int = newBoard.props["SIZEX"];
	var sizeY:int = newBoard.props["SIZEY"];
	for (var y:int = 0; y < sizeY; y++)
	{
		for (var x:int = 0; x < sizeX; x++)
			SE.setStatElemAt(x + 1, y + 1, null);
	}

	// Freshen status element linkages for newly copied board state.
	for (var i:int = 0; i < newBoard.statElem.length; i++)
	{
		var se:SE = newBoard.statElem[i];
		if ((se.FLAGS & (interp.FL_DEAD | interp.FL_GHOST)) == 0)
			SE.setStatElemAt(se.X, se.Y, se);
	}

	//trace("Saved board:  ", boardNum, saveType, currentBoardSaveIndex);
}

// Restore existing world to the point of index of specified save state.
public static function restoreToState(sIndex:int):void {
	var bState:ZZTBoard = saveStates[sIndex];
	trace("restore to state:  ", sIndex, bState.saveIndex, bState.boardIndex);

	// Register current state before snapshot restore
	if (zzt.globalProps["BOARD"] == 0)
		registerBoardState();
	else
		registerBoardState();

	// Wipe the board state information beyond this state.
	wipeBoardStates(bState.saveIndex);

	// Rewind zap record to appropriate level.
	rewindZapRecord(bState.saveIndex);

	// Set the global variables and world properties to specific state.
	resetGlobalProps(bState);

	// Switch to the board represented by the state.
	zzt.globalProps["BOARD"] = -1;
	switchBoard(bState.boardIndex);
	currentBoardSaveIndex++;
	switchBoard(bState.boardIndex);

	for (var i:int = 0; i < saveStates.length; i++) {
		bState = saveStates[i];
		trace("State remaining:  ", bState.saveType, bState.saveIndex, bState.boardIndex);
	}
}

// Make copy from "base" version of board, from original world file.
// Push to save states.
public static function copyBaseBoard(boardNum:int):ZZTBoard {
	//trace("base board copy:  " + boardNum);
	var bBoard:ZZTBoard = copyBoardState(boardData[boardNum]);
	bBoard.saveIndex = currentBoardSaveIndex;
	saveStates.push(bBoard);

	return bBoard;
}

// Copy board state and log it in saveStates.
public static function copyBoardState(srcBoard:ZZTBoard, fromCurrent=false):ZZTBoard {
	// Create new board object, which clones the source.
	var b:ZZTBoard = new ZZTBoard();
	var sizeX:int = srcBoard.props["SIZEX"];
	var sizeY:int = srcBoard.props["SIZEY"];

	// Copy working grid to board grids.
	b.typeBuffer = new ByteArray();
	b.colorBuffer = new ByteArray();
	b.lightBuffer = new ByteArray();
	b.typeBuffer.writeBytes(srcBoard.typeBuffer, 0, sizeX * sizeY);
	b.colorBuffer.writeBytes(srcBoard.colorBuffer, 0, sizeX * sizeY);
	b.lightBuffer.writeBytes(srcBoard.lightBuffer, 0, sizeX * sizeY);

	if (fromCurrent)
	{
		// If copying from real-time snapshot, copy working grid to board grids.
		var csr:int = 0;
		for (var y:int = 0; y < sizeY; y++)
		{
			for (var x:int = 0; x < sizeX; x++)
			{
				b.typeBuffer[csr] = SE.getType(x + 1, y + 1);
				b.colorBuffer[csr] = SE.getColor(x + 1, y + 1);
				b.lightBuffer[csr] = SE.getLit(x + 1, y + 1);
				csr++;
			}
		}
	}

	// Create copies of board properties and regions.
	b.props = new Object();
	b.regions = new Object();
	for (var k:Object in srcBoard.props)
		b.props[k] = srcBoard.props[k];
	for (k in srcBoard.regions)
		b.regions[k] = srcBoard.regions[k];

	var oldGridWidth:int = SE.gridWidth;
	var oldGridHeight:int = SE.gridHeight;
	setUpGrid(srcBoard.props["SIZEX"], srcBoard.props["SIZEY"], true);

	// Remember old player's location
	var oldPlayerSE:SE = fromCurrent ? interp.playerSE : srcBoard.playerSE;

	// Status elements require deep copies.
	srcBoard.statElementCount = srcBoard.statElem.length;
	b.statElem = new Vector.<SE>();
	var pIdx:int = -1;
	for (var i:int = 0; i < srcBoard.statElementCount; i++)
	{
		var oldSE:SE = srcBoard.statElem[i];
		if (oldSE.FLAGS & interp.FL_DEAD)
			continue;

		// Remember new player's index
		if (oldSE == oldPlayerSE)
			pIdx = b.statElem.length;

		var se:SE = new SE(oldSE.TYPE, oldSE.X, oldSE.Y,
			SE.getColor(oldSE.X, oldSE.Y), true);
		se.CYCLE = oldSE.CYCLE;
		se.STEPX = oldSE.STEPX;
		se.STEPY = oldSE.STEPY;
		se.UNDERID = oldSE.UNDERID;
		se.UNDERCOLOR = oldSE.UNDERCOLOR;
		se.IP = oldSE.IP;
		se.FLAGS = oldSE.FLAGS;
		se.delay = oldSE.delay;
		se.myID = oldSE.myID;
		for (k in oldSE.extra)
			se.extra[k] = oldSE.extra[k];

		// Add SE to container.
		b.statElem.push(se);
	}

	setUpGrid(oldGridWidth, oldGridHeight, true);
	b.statElementCount = b.statElem.length;
	b.statLessCount = srcBoard.statLessCount;
	b.playerSE = (pIdx == -1) ? null : b.statElem[pIdx];

	// Set timestamp.
	var d:Date = new Date();
	b.saveStamp = srcBoard.props["BOARDNAME"] + " : " + d.toTimeString();
	b.saveIndex = srcBoard.saveIndex;
	b.saveType = -1;
	b.boardIndex = srcBoard.boardIndex;

	// Save snapshot of world properties and global variables.
	// Although not strictly related to the board itself, the
	// snapshot is necessary for restoration purposes.
	b.worldProps = new Object();
	b.worldVars = new Object();
	for (k in zzt.globalProps)
		b.worldProps[k] = zzt.globalProps[k];
	for (k in zzt.globals)
		b.worldVars[k] = zzt.globals[k];

	// Return cloned board.
	return b;
}

// Translate Code Page 437 byte array to string.
public static function readExtendedASCIIString(b:ByteArray, len:int):String {
	if (len <= 0)
		return "";

	var tempB:ByteArray = new ByteArray();
	b.readBytes(tempB, 0, len);
	var s:String = "";
	for (var i:int = 0; i < len; i++)
		s += String.fromCharCode(tempB[i] & 255);

	return s;
}

// Translate Code Page 437-compatible string into byte array.
// It is not necessarily safe to use writeUTFBytes and have the
// number of bytes written come out the length of the string,
// so this function is needed to ensure one character -> one byte.
public static function writeExtendedASCIIString(s:String):ByteArray {
	var ba:ByteArray = new ByteArray();
	var len:int = s.length;
	for (var i:int = 0; i < len; i++)
		ba.writeByte(int(s.charCodeAt(i)));

	return ba;
}

// Translate board type info to or from numbers.
// This is used when extra types are being swapped in or out.
public static function swapTypeNumbers(toNumbers:Boolean):void {
	for (var i:int = 0; i < boardData.length; i++) {
		var bd:ZZTBoard = boardData[i];

		// Update main grid type IDs.
		for (var j:int = 0; j < bd.typeBuffer.length; j++) {
			if (toNumbers)
				bd.typeBuffer[j] = zzt.typeList[bd.typeBuffer[j]].NUMBER;
			else
				bd.typeBuffer[j] = interp.typeTrans[bd.typeBuffer[j]];
		}

		// Update status element TYPEs and UNDERIDs.
		for (j = 0; j < bd.statElem.length; j++)
		{
			var se:SE = bd.statElem[j];
			if (toNumbers)
			{
				se.TYPE = zzt.typeList[se.TYPE].NUMBER;
				se.UNDERID = zzt.typeList[se.UNDERID].NUMBER;
			}
			else
			{
				se.TYPE = interp.typeTrans[se.TYPE];
				se.UNDERID = interp.typeTrans[se.UNDERID];
			}
		}
	}
}

// Reset all status element IDs.
// Before saving a WAD file in the editor, we want compact IDs.
// Although the editor could maintain links set from the editor in theory,
// this is not considered a best practice.
public static function resetSEIDs():void {
	interp.nextObjPtrNum = 65536;

	for (var i:int = 0; i < boardData.length; i++) {
		var bd:ZZTBoard = boardData[i];

		// Update status element TYPEs and UNDERIDs.
		bd.props["$PLAYER"] = 0;
		for (var j:int = 0; j < bd.statElem.length; j++)
			bd.statElem[j].myID = 0;
	}
}

// Save the overall world state as a WAD file.
// If oneLevel is set to a specific board number, only that one board will be saved
// in the WAD file (all other non-board information will still be saved).
public static function saveWAD(
	destFile:String = ".WAD", oneLevel:int = -1, isPwad:Boolean=false):Boolean {
	// See if any extra GUIs, masks, and sound FX present.
	var numExtraGuis:int = 0;
	for (var key:String in extraGuis)
		numExtraGuis++;

	var numExtraSoundFX:int = 0;
	for (key in extraSoundFX)
		numExtraSoundFX++;

	var numExtraMasks:int = 0;
	for (key in extraMasks)
		numExtraMasks++;

	// Calculate fundamental lengths.
	var totalBoards:int = (oneLevel == -1) ? zzt.globalProps["NUMBOARDS"] : 1;
	var totalLumps:int = 4 + interp.unCompCode.length + (totalBoards * 4) +
		(numExtraGuis > 0 ? 1 : 0) + (zzt.extraTypeList.length > 0 ? 1 : 0) +
		(numExtraSoundFX > 0 ? 1 : 0) + (numExtraMasks > 0 ? 1 : 0) + extraLumps.length;
	var nextLumpOffset:int = 12 + (totalLumps * 16);

	// Create file header.
	file = new ByteArray();
	file.endian = Endian.LITTLE_ENDIAN;
	file.writeUTFBytes(isPwad ? "PWAD" : "IWAD");
	file.writeInt(totalLumps);
	file.writeInt(12);

	// We keep things simple by always placing the directory at the start of
	// the file (although it could be anywhere).

	// Pre-populate important world properties.
	var isSave:Boolean = Boolean(
		destFile.substr(destFile.length - 4).toUpperCase() == ".SAV");
	if (!isPwad)
	{
		zzt.globalProps["HIGHESTOBJPTR"] = isSave ? interp.nextObjPtrNum : 65536;
		zzt.globalProps["ISSAVEGAME"] = isSave ? 1 : 0;
	}

	// Get string equivalents of world properties, global vars.
	var worldStr:String;
	if (isSave)
		worldStr = parse.jsonToText(zzt.globalProps);
	else
		worldStr = parse.jsonToText(zzt.globalProps, true, "DEP_");

	var worldStrBytes:ByteArray = writeExtendedASCIIString(worldStr);
	file.writeInt(nextLumpOffset);
	file.writeInt(worldStrBytes.length);
	file.writeUTFBytes("WORLDHDR");
	nextLumpOffset += worldStrBytes.length;

	var globalStr:String;
	if (isSave)
		globalStr = parse.jsonToText(zzt.globals);
	else
		globalStr = parse.jsonToText(zzt.globals, true, "$");

	var globalStrBytes:ByteArray = writeExtendedASCIIString(globalStr);
	file.writeInt(nextLumpOffset);
	file.writeInt(globalStrBytes.length);
	file.writeUTFBytes("GLOBALS ");
	nextLumpOffset += globalStrBytes.length;

	// Make a copy of the type map array.
	var typeMapArr:ByteArray = new ByteArray();
	for (var ba:int = 0; ba < 256; ba++)
		typeMapArr.writeByte(interp.typeTrans[ba]);
	file.writeInt(nextLumpOffset);
	file.writeInt(256);
	file.writeUTFBytes("TYPEMAP ");
	nextLumpOffset += 256;

	// Playback string composite is fetched from existing queues.
	var playbackStr:String = Sounds.getQueueComposite();
	file.writeInt(nextLumpOffset);
	file.writeInt(playbackStr.length);
	file.writeUTFBytes("PLAYBACK");
	nextLumpOffset += playbackStr.length;

	// Account for extra sound FX, if any.
	var extraSoundFXStr:String = "";
	if (numExtraSoundFX > 0)
	{
		extraSoundFXStr = parse.jsonToText(extraSoundFX);
		file.writeInt(nextLumpOffset);
		file.writeInt(extraSoundFXStr.length);
		file.writeUTFBytes("SOUNDFX ");
		nextLumpOffset += extraSoundFXStr.length;
	}

	// Account for extra masks, if any.
	var extraMasksStr:String = "";
	if (numExtraMasks > 0)
	{
		extraMasksStr = parse.jsonToText(extraMasks);
		file.writeInt(nextLumpOffset);
		file.writeInt(extraMasksStr.length);
		file.writeUTFBytes("MASKS   ");
		nextLumpOffset += extraMasksStr.length;
	}

	// Account for extra GUIs, if any.
	var extraGuiBytes:ByteArray = new ByteArray();
	var extraGuiStr:String = "";
	if (numExtraGuis > 0)
	{
		extraGuiStr = parse.jsonToText(extraGuis);
		extraGuiBytes.writeUTFBytes(extraGuiStr);
		file.writeInt(nextLumpOffset);
		file.writeInt(extraGuiBytes.length);
		file.writeUTFBytes("EXTRAGUI");
		nextLumpOffset += extraGuiBytes.length;
	}

	// Account for extra types, if any.
	var extraTypeListStr:String = "";
	if (zzt.extraTypeList.length > 0)
	{
		extraTypeListStr = "{\n";
		for (var et:int = 0; et < zzt.extraTypeList.length; et++) {
			var eInfo:ElementInfo = zzt.extraTypeList[et];

			var eStr:String = eInfo.toString();
			if (zzt.extraTypeCode.hasOwnProperty(eInfo.NAME))
				eStr += "\"" + zzt.markUpCodeQuotes(zzt.extraTypeCode[eInfo.NAME]) + "\"\n}";
			else
				eStr += "\"\n#END\n\"\n}";

			extraTypeListStr += eStr;

			if (et < zzt.extraTypeList.length - 1)
				extraTypeListStr += ",\n";
			else
				extraTypeListStr += "\n}";
		}

		file.writeInt(nextLumpOffset);
		file.writeInt(extraTypeListStr.length);
		file.writeUTFBytes("EXTRATYP");
		nextLumpOffset += extraTypeListStr.length;
	}

	// Before handling uncompiled custom object code,
	// ensure that zap record modifications are logged.
	applyZapRecord();

	// Get total size of uncompiled custom object code.
	for (var c:int = 0; c < interp.unCompCode.length; c++)
	{
		file.writeInt(nextLumpOffset);
		file.writeInt(interp.unCompCode[c].length);
		file.writeUTFBytes("CUSTCODE");
		nextLumpOffset += interp.unCompCode[c].length;
	}

	// For each board, collect board properties, board regions,
	// board status elements, and board RLE streams.
	var boardStorage:Array = [];
	for (var i:int = 0; i < totalBoards; i++)
	{
		var bNum:int = (oneLevel == -1) ? i : oneLevel;
		var b:ZZTBoard = latestBoardState(bNum, true);

		var sizeX:int = b.props["SIZEX"];
		var sizeY:int = b.props["SIZEY"];
		b.props["$PLAYER"] = (b.playerSE == null) ? 0 : b.playerSE.myID;

		// Board properties
		var boardPropStr:String = parse.jsonToText(b.props);
		var boardPropStrBytes:ByteArray = writeExtendedASCIIString(boardPropStr);
		boardStorage.push(boardPropStrBytes);
		file.writeInt(nextLumpOffset);
		file.writeInt(boardPropStrBytes.length);
		file.writeUTFBytes("BOARDHDR");
		nextLumpOffset += boardPropStrBytes.length;

		// Board regions
		var boardRegionStr:String = parse.jsonToText(b.regions);
		boardStorage.push(boardRegionStr);
		file.writeInt(nextLumpOffset);
		file.writeInt(boardRegionStr.length);
		file.writeUTFBytes("BOARDRGN");
		nextLumpOffset += boardRegionStr.length;

		// Board status elements
		var boardStatElem:Array = new Array(b.statElem.length);
		for (var j:int = 0; j < b.statElem.length; j++)
		{
			// SE members are only stored if they are needed, and
			// if they differ from their defaults.
			var s:Object = new Object();
			var oldS:SE = b.statElem[j];
			eInfo = SE.typeList[oldS.TYPE];

			s["X"] = oldS.X;
			s["Y"] = oldS.Y;
			if (oldS.TYPE == 0)
			{
				// Deleted SE (used with PWADs)
				s["TYPE"] = 0;
			}
			else
			{
				// Normal SE
				s["IP"] = oldS.IP;
				s["FLAGS"] = oldS.FLAGS;
				s["delay"] = oldS.delay;
				if (isSave)
					s["myID"] = oldS.myID;
				if (oldS.UNDERID != 0)
					s["UNDERID"] = SE.typeList[oldS.UNDERID].NUMBER;
				if (oldS.UNDERCOLOR != 0)
					s["UNDERCOLOR"] = oldS.UNDERCOLOR;
				if (eInfo.CYCLE != oldS.CYCLE)
					s["CYCLE"] = oldS.CYCLE;
				if (eInfo.STEPX != oldS.STEPX)
					s["STEPX"] = oldS.STEPX;
				if (eInfo.STEPY != oldS.STEPY)
					s["STEPY"] = oldS.STEPY;

				for (var e:String in oldS.extra)
					if (e != "$CODE" || oneLevel != -1)
						s[e] = oldS.extra[e];
			}

			boardStatElem[j] = s;
		}

		var boardStatElemStr:String = parse.jsonToText(boardStatElem);
		var boardStatElemStrBytes:ByteArray = writeExtendedASCIIString(boardStatElemStr);
		boardStorage.push(boardStatElemStrBytes);
		file.writeInt(nextLumpOffset);
		file.writeInt(boardStatElemStrBytes.length);
		file.writeUTFBytes("STATELEM");
		nextLumpOffset += boardStatElemStrBytes.length;

		// Board RLE data
		var totalSquares:int = sizeX * sizeY;

		// First RLE is type info
		var lastVal:int = -1;
		var baseLoc:int = 0;
		var rleData:ByteArray = new ByteArray();
		var count:int = 0;
		var k:int = 0;
		while (k < totalSquares)
		{
			var typ:int = b.typeBuffer[k];
			if (k + 4 <= totalSquares)
			{
				// We only use RLE if there is at least a sequence of 4.
				// If 2 or 3, no compression is realized, so it is best ignored.
				if (typ == b.typeBuffer[k+1] && typ == b.typeBuffer[k+2] &&
					typ == b.typeBuffer[k+3])
				{
					// Write previous run
					if (count < 0)
					{
						rleData.writeByte(count);
						rleData.writeBytes(b.typeBuffer, baseLoc, -count);
					}

					// Capture repeated sequence
					count = 4;
					lastVal = typ;
					k += 4;
					while (k < totalSquares && count < 127)
					{
						typ = b.typeBuffer[k];
						if (typ != lastVal)
							break;
						k++;
						count++;
					}

					// Set next base location and write repeated sequence
					rleData.writeByte(count);
					rleData.writeByte(lastVal);
					baseLoc = k;
					count = 0;
					continue;
				}
			}

			// Advance beyond run
			k++;
			count--;

			// Write run if at end, or if size is large enough
			if (k >= totalSquares || count <= -128)
			{
				rleData.writeByte(count);
				rleData.writeBytes(b.typeBuffer, baseLoc, -count);
				baseLoc = k;
				count = 0;
			}
		}

		// Next RLE is foreground color
		lastVal = -1;
		k = 0;
		while (k < totalSquares)
		{
			count = 1;
			lastVal = b.colorBuffer[k++] & 15;
			while (count < 16 && k < totalSquares)
			{
				var col:int = b.colorBuffer[k] & 15;
				if (col != lastVal)
					break;
				count++;
				k++;
			}

			// Write mixture of color and count
			rleData.writeByte(lastVal | (((count-1) & 15) << 4));
		}

		// Next RLE is background color
		lastVal = -1;
		k = 0;
		while (k < totalSquares)
		{
			count = 1;
			lastVal = b.colorBuffer[k++] & 240;
			while (count < 16 && k < totalSquares)
			{
				col = b.colorBuffer[k] & 240;
				if (col != lastVal)
					break;
				count++;
				k++;
			}

			// Write mixture of color and count
			rleData.writeByte(((lastVal >> 4) & 15) | (((count-1) & 15) << 4));
		}

		// Next RLE is lighting
		if (!b.props["ISDARK"])
		{
			rleData.writeByte(0);
		}
		else
		{
			rleData.writeByte(1);
			lastVal = -1;
			k = 0;
			while (k < totalSquares)
			{
				count = 0;
				while (count < 255)
				{
					if (b.lightBuffer[k])
						break;
					count++;
					k++;
				}
				rleData.writeByte(count);

				count = 0;
				while (count < 255)
				{
					if (!b.lightBuffer[k])
						break;
					count++;
					k++;
				}
				rleData.writeByte(count);
			}
		}

		boardStorage.push(rleData);
		file.writeInt(nextLumpOffset);
		file.writeInt(rleData.length);
		file.writeUTFBytes("BOARDRLE");
		nextLumpOffset += rleData.length;
	}

	// Write extra lump directory entries.
	for (i = 0; i < extraLumps.length; i++) {
		file.writeInt(nextLumpOffset);
		file.writeInt(extraLumps[i].len);
		file.writeUTFBytes(extraLumps[i].name);
		nextLumpOffset += extraLumps[i].len;
	}

	// With all lump directory entries written, proceed to write actual lumps.
	file.writeBytes(worldStrBytes);
	file.writeBytes(globalStrBytes);
	file.writeBytes(typeMapArr, 0, 256);
	file.writeUTFBytes(playbackStr);

	if (numExtraSoundFX > 0)
		file.writeUTFBytes(extraSoundFXStr);

	if (numExtraMasks > 0)
		file.writeUTFBytes(extraMasksStr);

	if (numExtraGuis > 0)
		file.writeBytes(extraGuiBytes);

	if (zzt.extraTypeList.length > 0)
		file.writeUTFBytes(extraTypeListStr);

	for (c = 0; c < interp.unCompCode.length; c++)
	{
		//file.writeUTFBytes(interp.unCompCode[c]);
		for (j = 0; j < interp.unCompCode[c].length; j++) {
			var uccb:int = int(interp.unCompCode[c].charCodeAt(j));
			file.writeByte(uccb);
		}
	}

	j = 0;
	for (i = 0; i < totalBoards; i++)
	{
		file.writeBytes(boardStorage[j++]); // BOARDHDR
		file.writeUTFBytes(boardStorage[j++]); // BOARDRGN
		file.writeBytes(boardStorage[j++]); // STATELEM
		file.writeBytes(boardStorage[j++]); // BOARDRLE
	}

	for (i = 0; i < extraLumps.length; i++) {
		file.writeBytes(extraLumpBinary[i]);
	}

	// Data is ready in "file" static member.
	return true;
}

// Test if a lump name is native to enhanced format or not.
public static function isNativeLump(str:String):Boolean {
	if (str == "WORLDHDR" || str == "GLOBALS " || str == "TYPEMAP " || str == "PLAYBACK" ||
		str == "EXTRATYP" || str == "EXTRAGUI" || str == "SOUNDFX " || str == "MASKS   " ||
		str == "CUSTCODE" || str == "BOARDHDR" || str == "BOARDRGN" || str == "BOARDRLE" ||
		str == "STATELEM")
		return true;

	return false;
}

// Unpack a WAD file and load world state from it
public static function establishWADFile(b:ByteArray, isImport:Boolean=false):Boolean {
	// If importing a board, loaded code blocks will be stacked on top of current blocks
	var codeIDBase:int = interp.codeBlocks.length;
	var unCompCodeIDBase:int = interp.unCompCode.length;

	if (!isImport)
	{
		// Strip out non-built-in code blocks
		interp.unCompCode = [];
		interp.unCompStart = new Vector.<int>();
		interp.numBuiltInCodeBlocksPlus = interp.numBuiltInCodeBlocks;
		if (interp.codeBlocks.length > interp.numBuiltInCodeBlocks)
			interp.codeBlocks.length = interp.numBuiltInCodeBlocks;

		// Reset types back to defaults
		zzt.resetTypes();
	}

	// Read file header.
	file = b;
	file.endian = Endian.LITTLE_ENDIAN;
	if (file.readUTFBytes(4) != "IWAD")
	{
		// This is an error--we can only take an IWAD.
		// PWADs, if used, are handled differently.
		zzt.Toast("File is not an IWAD.");
		return false;
	}
	var totalLumps:int = file.readInt();
	file.position = file.readInt();

	// Read directory entries.  ZZT Ultra always writes a WAD with the
	// directory at the start, but we must allow for the possibility of
	// the directory being located anywhere.
	var lumps:Vector.<Lump> = new Vector.<Lump>();
	extraLumps = new Vector.<Lump>();
	for (var i:int = 0; i < totalLumps; i++)
	{
		var pos:int = file.readInt();
		var len:int = file.readInt();
		var str:String = file.readUTFBytes(8);
		var nLump:Lump = new Lump(pos, len, str);
		lumps.push(nLump);

		if (!isNativeLump(str))
			extraLumps.push(nLump);
	}

	// Read all extra lump binaries.
	for (i = 0; i < extraLumps.length; i++) {
		extraLumpBinary.push(extraLumps[i].getLumpBytes(file));
	}

	// Read type map array.
	var lump:Lump;
	lump = Lump.search(lumps, "TYPEMAP ", 0);
	if (!lump)
	{
		zzt.Toast("Bad/missing TYPEMAP.");
		return false;
	}
	var typeMapArr:ByteArray = lump.getLumpBytes(file);

	if (!isImport)
	{
		// Read world header.
		lump = Lump.search(lumps, "WORLDHDR", 0);
		if (!lump)
		{
			zzt.Toast("Bad/missing WORLDHDR.");
			return false;
		}
		zzt.globalProps = parse.jsonDecode(lump.getLumpStr(file));
		Sounds.globalProps = zzt.globalProps;
	
		if (zzt.globalProps.hasOwnProperty("HIGHESTOBJPTR"))
			interp.nextObjPtrNum = zzt.globalProps["HIGHESTOBJPTR"];
	
		// Read global variables.
		lump = Lump.search(lumps, "GLOBALS ", 0);
		if (!lump)
		{
			zzt.Toast("Bad/missing GLOBALS.");
			return false;
		}
		zzt.globals = parse.jsonDecode(lump.getLumpStr(file));

		// Ensure default properties are present if not defined within WAD.
		for (var k:String in defaultPropsWAD) {
			if (!zzt.globalProps.hasOwnProperty(k))
				zzt.globalProps[k] = defaultPropsWAD[k];
		}

		for (k in overridePropsGeneral) {
			if (!zzt.globalProps.hasOwnProperty(k))
				zzt.globalProps[k] = overridePropsGeneral[k];
		}

		// The version number is a forced override.
		zzt.globalProps["VERSION"] = defaultPropsGeneral["VERSION"];

		// Update master volume.
		Sounds.setMasterVolume(zzt.globalProps["MASTERVOLUME"]);

		// Setting SCORE as a property is a sneaky way to cheat (it doesn't work).
		if (zzt.CHEATING_DISABLES_PROGRESS && overridePropsGeneral.hasOwnProperty("SCORE"))
			zzt.DISABLE_HISCORE = 1;
	}

	if (!isImport)
	{
		// Read and set up extra types, if present.
		lump = Lump.search(lumps, "EXTRATYP", 0);
		if (lump)
		{
			var extraTypeStr:String = lump.getLumpStr(file);
			var jObj:Object = parse.jsonDecode(extraTypeStr);
			zzt.establishExtraTypes(jObj);
		}
		else
			zzt.establishExtraTypes(new Object());
	}

	// Fashion type-to-type translation table.
	var type2TypeMap:Array = new Array(256);
	for (i = 0; i < typeMapArr.length; i++)
	{
		var typeOld:int = typeMapArr[i];
		var typeNew:int = interp.typeTrans[i];
		if (typeOld == 0)
			typeNew = 0;
		type2TypeMap[typeOld] = typeNew;
	}

	if (!isImport)
	{
		// Read playback string composite, if present.
		lump = Lump.search(lumps, "PLAYBACK", 0);
		if (lump)
		{
			var playbackStr:String = lump.getLumpStr(file);
			// TBD:  restart BGM
		}

		// Read sound effects bank, if present.
		lump = Lump.search(lumps, "SOUNDFX ", 0);
		if (lump)
		{
			var soundFxStr:String = lump.getLumpStr(file);
			extraSoundFX = parse.jsonDecode(soundFxStr);
			for (k in extraSoundFX)
				zzt.soundFx[k] = extraSoundFX[k];
		}

		// Read extra masks bank, if present.
		lump = Lump.search(lumps, "MASKS   ", 0);
		if (lump)
		{
			var maskStr:String = lump.getLumpStr(file);
			extraMasks = parse.jsonDecode(maskStr);
			for (k in extraMasks)
				zzt.addMask(k, extraMasks[k]);
		}

		// Read and set up extra GUIs, if present.
		lump = Lump.search(lumps, "EXTRAGUI", 0);
		if (lump)
		{
			var extraGuiStr:String = lump.getLumpStr(file);
			extraGuis = parse.jsonDecode(extraGuiStr);
			for (k in extraGuis)
				zzt.guiStorage[k] = extraGuis[k];
		}
	}

	// Get uncompiled custom object code; compile it.
	customONAME = new Object();
	Lump.resetSearch();
	lump = Lump.search(lumps, "CUSTCODE");
	while (lump) {
		var codeStr:String = lump.getLumpExtendedASCIIStr(file);
		interp.unCompCode.push(codeStr);

		var eLoc:int = codeStr.indexOf(zzt.globalProps["CODEDELIMETER"]);
		var codeSrcType:String = codeStr.substr(0, eLoc);
		var unCompCodeId:int = interp.typeTrans2(int(codeSrcType));
		codeStr = codeStr.substr(eLoc+1);
		interp.unCompStart.push(eLoc+1);

		// Compile custom code.
		var newCodeId:int = zzt.compileCustomCode(
			SE.typeList[unCompCodeId], codeStr, zzt.globalProps["CODEDELIMETER"]);

		if (oop.lastAssignedName != "")
			customONAME[newCodeId.toString()] = oop.lastAssignedName;

		// Next code block
		lump = Lump.search(lumps, "CUSTCODE");
	}

	// Establish board lumps.
	var totalBoards:int = isImport ? 1 : zzt.globalProps["NUMBOARDS"];
	var bHdrLumps:Vector.<Lump> = new Vector.<Lump>();
	var bRgnLumps:Vector.<Lump> = new Vector.<Lump>();
	var bSELumps:Vector.<Lump> = new Vector.<Lump>();
	var bRLELumps:Vector.<Lump> = new Vector.<Lump>();

	Lump.resetSearch();
	for (i = 0; i < totalBoards; i++)
	{
		lump = Lump.search(lumps, "BOARDHDR");
		if (!lump)
		{
			zzt.Toast("Bad/missing BOARDHDR at postion " + i.toString());
			return false;
		}
		bHdrLumps.push(lump);
	}
	Lump.resetSearch();
	for (i = 0; i < totalBoards; i++)
	{
		lump = Lump.search(lumps, "BOARDRGN");
		if (!lump)
		{
			zzt.Toast("Bad/missing BOARDRGN at postion " + i.toString());
			return false;
		}
		bRgnLumps.push(lump);
	}
	Lump.resetSearch();
	for (i = 0; i < totalBoards; i++)
	{
		lump = Lump.search(lumps, "STATELEM");
		if (!lump)
		{
			zzt.Toast("Bad/missing STATELEM at postion " + i.toString());
			return false;
		}
		bSELumps.push(lump);
	}
	Lump.resetSearch();
	for (i = 0; i < totalBoards; i++)
	{
		lump = Lump.search(lumps, "BOARDRLE");
		if (!lump)
		{
			zzt.Toast("Bad/missing BOARDRLE at postion " + i.toString());
			return false;
		}
		bRLELumps.push(lump);
	}

	// For each board, reconstitute ZZTBoard instances.
	if (isImport)
		boardData.push(null);
	else
		boardData = new Array(totalBoards);

	for (i = 0; i < totalBoards; i++)
	{
		// Create new board storage object.
		board = new ZZTBoard();
		board.saveStamp = "init";
		board.saveIndex = 0;
		board.saveType = -1;
		board.boardIndex = i;

		// Reinstate board properties and regions.
		board.props = parse.jsonDecode(bHdrLumps[i].getLumpStr(file));
		board.regions = parse.jsonDecode(bRgnLumps[i].getLumpStr(file));

		// Load RLE data.
		var rleData:ByteArray = bRLELumps[i].getLumpBytes(file);
		var sizeX:int = board.props["SIZEX"];
		var sizeY:int = board.props["SIZEY"];
		var totalSquares:int = sizeX * sizeY;
		ensureGridSpace(sizeX, sizeY);
		board.typeBuffer = new ByteArray();
		board.colorBuffer = new ByteArray();
		board.lightBuffer = new ByteArray();

		// First RLE is type info
		for (var c:int = 0; c < totalSquares;)
		{
			len = rleData.readByte();
			if (len < 0)
			{
				// Run
				while (len++ < 0)
					board.typeBuffer[c++] = type2TypeMap[rleData.readUnsignedByte()];
			}
			else if (len > 0)
			{
				// Rep
				var repByte:int = type2TypeMap[rleData.readUnsignedByte()];
				while (len-- > 0)
					board.typeBuffer[c++] = repByte;
			}
			else
			{
				// End
				while (c < totalSquares)
					board.typeBuffer[c++] = 0;
				break;
			}
		}

		// Next RLE is foreground color
		for (c = 0; c < totalSquares;)
		{
			repByte = rleData.readUnsignedByte();
			len = (repByte >> 4) & 15;
			while (len-- >= 0)
				board.colorBuffer[c++] = repByte & 15;
		}

		// Next RLE is background color
		for (c = 0; c < totalSquares;)
		{
			repByte = rleData.readUnsignedByte();
			len = (repByte >> 4) & 15;
			while (len-- >= 0)
				board.colorBuffer[c++] |= (repByte & 15) << 4;
		}

		// Next RLE is lighting
		c = 0;
		repByte = rleData.readUnsignedByte();
		if (repByte != 0)
		{
			// Light buffer is present
			for (; c < totalSquares;)
			{
				// Unlit region
				len = rleData.readUnsignedByte();
				while (len-- > 0)
					board.lightBuffer[c++] = 0;

				// Lit region
				len = rleData.readUnsignedByte();
				if (len == 0)
					break; // Early-out
				while (len-- > 0)
					board.lightBuffer[c++] = 1;
			}
		}

		// Remainder of light buffer
		while (c < totalSquares)
			board.lightBuffer[c++] = 0;

		// Board status elements
		var boardStatElem:Array = parse.jsonDecode(bSELumps[i].getLumpStr(file)) as Array;
		board.statElem = new Vector.<SE>();
		board.statElementCount = boardStatElem.length;
		board.statLessCount = 0;
		setUpGrid(sizeX, sizeY, true);

		for (var j:int = 0; j < board.statElementCount; j++)
		{
			// Get stored JSON object; locate grid position
			var s:Object = boardStatElem[j];
			var statElemX:int = s["X"];
			var statElemY:int = s["Y"];
			var st:int = board.typeBuffer[(statElemY-1) * sizeX + (statElemX-1)];
			var sc:int = board.colorBuffer[(statElemY-1) * sizeX + (statElemX-1)];
			var eInfo:ElementInfo = SE.typeList[st];

			// Create and populate SE
			var se:SE = new SE(st, statElemX, statElemY, sc, true);
			se.IP = s["IP"];
			se.FLAGS = s["FLAGS"];
			se.delay = s["delay"];
			if (s.hasOwnProperty("myID"))
				se.myID = s["myID"];
			else
				se.myID = ++interp.nextObjPtrNum;
			if (s.hasOwnProperty("UNDERID"))
				se.UNDERID = interp.typeTrans2(s["UNDERID"]);
			else
				se.UNDERID = 0;
			if (s.hasOwnProperty("UNDERCOLOR"))
				se.UNDERCOLOR = s["UNDERCOLOR"];
			else
				se.UNDERCOLOR = 0;
			if (s.hasOwnProperty("CYCLE"))
				se.CYCLE = s["CYCLE"];
			else
				se.CYCLE = eInfo.CYCLE;
			if (s.hasOwnProperty("STEPX"))
				se.STEPX = s["STEPX"];
			else
				se.STEPX = eInfo.STEPX;
			if (s.hasOwnProperty("STEPY"))
				se.STEPY = s["STEPY"];
			else
				se.STEPY = eInfo.STEPY;

			var e:String;
			for (e in s)
			{
				if (!se.hasOwnProperty(e))
					se.extra[e] = s[e];
			}

			// If next command is a @name, assign ONAME member.
			if ((se.FLAGS & interp.FL_IDLE) == 0 && eInfo.HasOwnCode)
			{
				if (se.extra.hasOwnProperty("CODEID"))
				{
					var codeIdStr:String = se.extra["CODEID"].toString();
					if (customONAME.hasOwnProperty(codeIdStr))
						se.extra["ONAME"] = customONAME[codeIdStr];
				}
			}

			board.statElem.push(se);
		}

		// Set player SE.  Defaults to first element if can't distinguish ID
		// for some reason (original ZZT and Super ZZT always set player to
		// position zero, so this is reasonably safe).
		if (board.statElem.length > 0)
			board.playerSE = board.statElem[0];
		else
			board.playerSE = null;

		for (j = 0; j < board.statElem.length; j++)
		{
			if (board.statElem[j].myID == board.props["$PLAYER"] && board.props["$PLAYER"] > 0)
			{
				board.playerSE = board.statElem[j];
				break;
			}
		}

		if (board.playerSE != null)
			board.props["$PLAYER"] = board.playerSE.myID;

		if (isImport)
			boardData[boardData.length - 1] = board;
		else
			boardData[i] = board;
	}

	// Reset save state container
	saveStates = new Vector.<ZZTBoard>();
	interp.zapRecord = new Vector.<ZapRecord>();
	currentBoardSaveIndex = 0;

	// Retain record of lumps for future indexing purposes
	parse.lumpData = lumps;

	return true;
}

// Dictionaries that call for component deletion need to have these
// deletion directives separated out.
public static function createDelDicts(pwadDicts:Object, pwadDelDicts:Object):void {
	for (var s:String in pwadDicts) {
		var d:Object = pwadDicts[s];
		var delDict:Object = new Object();

		// Find keys to delete
		var numDels:int = 0;
		for (var k:String in d) {
			if (d[k] == "delete")
			{
				delDict[k] = 1;
				numDels++;
			}
		}

		// If any deletion keys found, add to deletion list
		if (numDels > 0)
		{
			pwadDelDicts[s] = delDict;
			for (k in delDict)
				delete d[k];
		}
	}
}

// Update dictionaries with added and deleted keys.
public static function replaceDict(d:Object, dSet:Object, dClear:Object):void {
	for (var k:String in dSet)
		d[k] = dSet[k];

	for (k in dClear)
		delete d[k];
}

// Create a "delta" dictionary from source and destination dictionaries.
public static function createDeltaDict(dSrc:Object, dDest:Object,
	textReduction:Boolean=false):Object {

	// Compare source and dest.
	var dDelta:Object = new Object();
	for (var k:String in dSrc) {
		if (dDest.hasOwnProperty(k)) {
			if (textReduction)
			{
				var sSrc:String = parse.jsonToText(dSrc[k]);
				var sDest:String = parse.jsonToText(dDest[k]);
				if (sSrc != sDest)
				{
					// Not equal--include replacement in delta.
					dDelta[k] = dDest[k];
				}
			}
			else if (dSrc[k] != dDest[k])
			{
				// Not equal--include replacement in delta.
				dDelta[k] = dDest[k];
			}
		}
		else
		{
			// Deleted
			dDelta[k] = "delete";
		}
	}

	// Retain keys exclusive to destination.
	for (k in dDest) {
		if (!dSrc.hasOwnProperty(k))
			dDelta[k] = dDest[k];
	}

	return dDelta;
}

// Unpack a PWAD file; temporarily store PWAD info
public static function registerPWADFile(b:ByteArray, pwadName:String):Boolean {
	pwadDicts = new Object();
	pwadDelDicts = new Object();
	pwadBoards = [];
	pwadCustCode = [];

	// Read file header.
	var pFile:ByteArray = b;
	pFile.endian = Endian.LITTLE_ENDIAN;
	if (pFile.readUTFBytes(4) != "PWAD")
	{
		// This is an error--we can only take a PWAD.
		zzt.Toast("File is not a PWAD.");
		return false;
	}
	var totalLumps:int = pFile.readInt();
	pFile.position = pFile.readInt();

	// Read directory entries.
	var lumps:Vector.<Lump> = new Vector.<Lump>();
	var pExtraLumps:Vector.<Lump> = new Vector.<Lump>();
	for (var i:int = 0; i < totalLumps; i++)
	{
		var pos:int = pFile.readInt();
		var len:int = pFile.readInt();
		var str:String = pFile.readUTFBytes(8);
		var nLump:Lump = new Lump(pos, len, str);
		lumps.push(nLump);

		if (!isNativeLump(str))
			pExtraLumps.push(nLump);
	}

	// Read all extra lump binaries.
	var pExtraLumpBinary:Vector.<ByteArray> = new Vector.<ByteArray>();
	for (i = 0; i < pExtraLumps.length; i++) {
		pExtraLumpBinary.push(pExtraLumps[i].getLumpBytes(pFile));
	}

	// Read type map array.
	var lump:Lump;
	lump = Lump.search(lumps, "TYPEMAP ", 0);
	if (!lump)
	{
		zzt.Toast("Bad/missing TYPEMAP.");
		return false;
	}
	pwadTypeMap = lump.getLumpBytes(pFile);

	// Fashion type-to-type translation table.
	var type2TypeMap:Array = new Array(256);
	for (i = 0; i < pwadTypeMap.length; i++)
	{
		var typeOld:int = pwadTypeMap[i];
		var typeNew:int = interp.typeTrans[i];
		if (typeOld == 0)
			typeNew = 0;
		type2TypeMap[typeOld] = typeNew;
	}

	// Read world header.
	lump = Lump.search(lumps, "WORLDHDR", 0);
	if (lump)
		pwadDicts["WORLDHDR"] = parse.jsonDecode(lump.getLumpStr(pFile));

	// Read global variables.
	lump = Lump.search(lumps, "GLOBALS ", 0);
	if (lump)
		pwadDicts["GLOBALS "] = parse.jsonDecode(lump.getLumpStr(pFile));

	// Read extra types, if present.
	lump = Lump.search(lumps, "EXTRATYP", 0);
	if (lump)
		pwadDicts["EXTRATYP"] = parse.jsonDecode(lump.getLumpStr(pFile));

	// Read sound effects bank, if present.
	lump = Lump.search(lumps, "SOUNDFX ", 0);
	if (lump)
		pwadDicts["SOUNDFX "] = parse.jsonDecode(lump.getLumpStr(pFile));

	// Read extra masks bank, if present.
	lump = Lump.search(lumps, "MASKS   ", 0);
	if (lump)
		pwadDicts["MASKS   "] = parse.jsonDecode(lump.getLumpStr(pFile));

	// Read and set up extra GUIs, if present.
	lump = Lump.search(lumps, "EXTRAGUI", 0);
	if (lump)
		pwadDicts["EXTRAGUI"] = parse.jsonDecode(lump.getLumpStr(pFile));

	createDelDicts(pwadDicts, pwadDelDicts);

	// Get uncompiled custom object code.
	Lump.resetSearch();
	lump = Lump.search(lumps, "CUSTCODE");
	while (lump) {
		var codeStr:String = lump.getLumpExtendedASCIIStr(pFile);
		pwadCustCode.push(codeStr);

		// Next code block
		lump = Lump.search(lumps, "CUSTCODE");
	}

	// Establish board lumps.
	var bHdrLumps:Vector.<Lump> = new Vector.<Lump>();
	var bRgnLumps:Vector.<Lump> = new Vector.<Lump>();
	var bSELumps:Vector.<Lump> = new Vector.<Lump>();
	var bRLELumps:Vector.<Lump> = new Vector.<Lump>();

	Lump.resetSearch();
	do {
		lump = Lump.search(lumps, "BOARDHDR");
		if (lump)
			bHdrLumps.push(lump);
	} while (lump);

	Lump.resetSearch();
	do {
		lump = Lump.search(lumps, "BOARDRGN");
		if (lump)
			bRgnLumps.push(lump);
	} while (lump);

	Lump.resetSearch();
	do {
		lump = Lump.search(lumps, "STATELEM");
		if (lump)
			bSELumps.push(lump);
	} while (lump);

	Lump.resetSearch();
	do {
		lump = Lump.search(lumps, "BOARDRLE");
		if (lump)
			bRLELumps.push(lump);
	} while (lump);

	// Patched board total only extends as far as lowest count.
	var totalBoards:int = bHdrLumps.length;
	if (totalBoards > bRgnLumps.length)
		totalBoards = bRgnLumps.length;
	if (totalBoards > bSELumps.length)
		totalBoards = bSELumps.length;
	if (totalBoards > bRLELumps.length)
		totalBoards = bRLELumps.length;
	if (pwadDicts.hasOwnProperty("NUMBOARDS"))
	{
		if (totalBoards < pwadDicts["NUMBOARDS"])
			totalBoards = pwadDicts["NUMBOARDS"];
		delete pwadDicts["NUMBOARDS"];
	}

	// Store board patch info.
	for (i = 0; i < totalBoards; i++)
	{
		// Queue storage
		var hdrDict:Object = new Object();
		var hdrDelDict:Object = new Object();
		var rgnDict:Object = new Object();
		var rgnDelDict:Object = new Object();
		var seArray:Array = [];
		var typeBuffer:ByteArray = new ByteArray();
		var colorBuffer:ByteArray = new ByteArray();
		var lightBuffer:ByteArray = new ByteArray();

		// Get changed board properties and regions
		if (bHdrLumps[i].len > 0)
		{
			hdrDict = parse.jsonDecode(bHdrLumps[i].getLumpStr(pFile));
			createDelDicts(hdrDict, hdrDelDict);
		}
		if (bRgnLumps[i].len > 0)
		{
			rgnDict = parse.jsonDecode(bRgnLumps[i].getLumpStr(pFile));
			createDelDicts(rgnDict, rgnDelDict);
		}

		// Get changed status elements
		seArray = parse.jsonDecode(bSELumps[i].getLumpStr(pFile)) as Array;

		// Get RLE sequences
		var sizeX:int = hdrDict["SIZEX"];
		var sizeY:int = hdrDict["SIZEY"];
		var totalSquares:int = sizeX * sizeY;
		var rleData:ByteArray = bRLELumps[i].getLumpBytes(pFile);

		// First RLE is type info
		var v:int = 0;
		for (var c:int = 0; c < totalSquares;)
		{
			len = rleData.readByte();
			if (len < 0)
			{
				// Run
				while (len++ < 0) {
					typeBuffer[c++] = type2TypeMap[rleData.readUnsignedByte()];
				}
			}
			else if (len > 0)
			{
				// Rep
				var repByte:int = type2TypeMap[rleData.readUnsignedByte()];
				while (len-- > 0)
					typeBuffer[c++] = repByte;
			}
			else
			{
				// End
				break;
			}
		}

		// Next RLE is foreground color
		for (c = 0; c < totalSquares;)
		{
			repByte = rleData.readUnsignedByte();
			len = (repByte >> 4) & 15;
			while (len-- >= 0)
				colorBuffer[c++] = repByte & 15;
		}

		// Next RLE is background color
		for (c = 0; c < totalSquares;)
		{
			repByte = rleData.readUnsignedByte();
			len = (repByte >> 4) & 15;
			while (len-- >= 0)
				colorBuffer[c++] |= (repByte & 15) << 4;
		}

		// Next RLE is lighting
		c = 0;
		repByte = rleData.readUnsignedByte();
		if (repByte != 0)
		{
			// Light buffer is present
			for (; c < totalSquares;)
			{
				// Unlit region
				len = rleData.readUnsignedByte();
				while (len-- > 0)
					lightBuffer[c++] = 0;

				// Lit region
				len = rleData.readUnsignedByte();
				if (len == 0)
					break; // Early-out
				while (len-- > 0)
					lightBuffer[c++] = 1;
			}
		}

		// Remainder of light buffer
		while (c < totalSquares)
			lightBuffer[c++] = 0;

		// Store board-patch info
		var pbInfo:Array = [ hdrDict, hdrDelDict, rgnDict, rgnDelDict,
			seArray, typeBuffer, colorBuffer, lightBuffer ];
		pwadBoards.push(pbInfo);
	}

	pwads[pwadName] = [pwadTypeMap, pwadDicts, pwadDelDicts, pwadCustCode,
		pwadBoards, pExtraLumps, pExtraLumpBinary];
	return true;
}

// Initialize PWAD patch containers based on key.
public static function establishPWAD(pwadName:String):Boolean {
	var loadBlank:Boolean = false;
	if (!pwads.hasOwnProperty(pwadName))
		loadBlank = true;
	else if (pwads[pwadName] == "")
		loadBlank = true;

	pwadBQUESTHACK = 0;
	if (loadBlank)
	{
		// Empty containers; no PWAD info.
		pwadTypeMap = new ByteArray();
		for (var i:int = 0; i < 256; i++)
			pwadTypeMap[i] = interp.typeTrans[i];
		pwadDicts = new Object();
		pwadDelDicts = new Object();
		pwadCustCode = [];
		pwadBoards = [];
		pwadExtraLumps = new Vector.<Lump>();
		pwadExtraLumpBinary = new Vector.<ByteArray>();
		return false;
	}
	else
	{
		// Take PWAD info from dictionary.
		var pwa:Array = pwads[pwadName];
		pwadTypeMap = pwa[0];
		pwadDicts = pwa[1];
		pwadDelDicts = pwa[2];
		pwadCustCode = pwa[3];
		pwadBoards = pwa[4];
		pwadExtraLumps = pwa[5];
		pwadExtraLumpBinary = pwa[6];
		if (pwadDicts["WORLDHDR"].hasOwnProperty("BQUESTHACK"))
			pwadBQUESTHACK = pwadDicts["WORLDHDR"]["BQUESTHACK"];
		return true;
	}
}

// Check if PWAD is loaded already.  If loaded, establish containers.
public static function pwadIsLoaded(pwadIndex:Object, origName:String):Boolean {
	if (!utils.ciTest(pwadIndex, origName))
	{
		establishPWAD("");
		return true; // No such name in index; no load necessary.
	}

	var pwadKey:String = utils.ciLookup(pwadIndex, origName) as String;
	if (pwads.hasOwnProperty(pwadKey))
	{
		establishPWAD(pwadKey);
		return true; // Already registered; no load necessary.
	}

	// Not registered; load necessary.
	return false;
}

};
};

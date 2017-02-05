//zzt.as:  The main engine.

package
{
// Imports
import flash.display.*;
import flash.geom.*;
import flash.text.*;
import flash.net.*;
import flash.utils.ByteArray;
import flash.utils.Endian;
import flash.utils.Timer;
import flash.utils.getTimer;
import flash.system.Security;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import flash.events.TimerEvent;
import flash.ui.Keyboard;
import fl.controls.TextArea;

public class zzt {

// Directive constants
public static const GUIS_PREFIX:String = "guis/";
public static const USE_SHAREDOBJECTS:int = 1;
public static const CHEATING_DISABLES_PROGRESS:int = 1;
public static const DISABLE_CHEATS:int = 0;
public static var DISABLE_MEDALS:int = 1;
public static var DISABLE_HISCORE:int = 0;

// Constants
public static const MODE_INIT:int = 0;
public static const MODE_LOADMAIN:int = 1;
public static const MODE_LOADZZT:int = 2;
public static const MODE_LOADSZT:int = 3;
public static const MODE_LOADWAD:int = 4;
public static const MODE_SAVEWAD:int = 5;
public static const MODE_NORM:int = 6;
public static const MODE_SETUPMAIN:int = 7;
public static const MODE_SETUPZZT:int = 8;
public static const MODE_SETUPSZT:int = 9;
public static const MODE_SETUPWAD:int = 10;
public static const MODE_ENTERGUIPROP:int = 11;
public static const MODE_LOADGUI:int = 12;
public static const MODE_SAVEGUI:int = 13;
public static const MODE_CONFMESSAGE:int = 14;
public static const MODE_TEXTENTRY:int = 15;
public static const MODE_LOADDEFAULTOOP:int = 16;
public static const MODE_SETUPOOP:int = 17;
public static const MODE_SCROLLOPEN:int = 18;
public static const MODE_SCROLLINTERACT:int = 19;
public static const MODE_SCROLLCLOSE:int = 20;
public static const MODE_SCROLLCHAIN:int = 21;
public static const MODE_LOADFILELINK:int = 22;
public static const MODE_SELECTPEN:int = 23;
public static const MODE_LOADSAVEWAIT:int = 24;
public static const MODE_RESTOREWADFILE:int = 25;
public static const MODE_ENTEROPTIONS:int = 26;
public static const MODE_ENTEROPTIONSPROP:int = 27;
public static const MODE_ENTERCONSOLE:int = 28;
public static const MODE_ENTERCONSOLEPROP:int = 29;
public static const MODE_LOADZIP:int = 30;
public static const MODE_NATIVELOADZZT:int = 31;
public static const MODE_NATIVELOADSZT:int = 32;
public static const MODE_LOADINDEXPATHS:int = 33;
public static const MODE_LOADINI:int = 34;
public static const MODE_AUTOSTART:int = 35;
public static const MODE_LOADFILEBROWSER:int = 36;
public static const MODE_FILEBROWSER:int = 37;
public static const MODE_DISSOLVE:int = 38;
public static const MODE_SCROLLMOVE:int = 39;
public static const MODE_COLORSEL:int = 40;
public static const MODE_CHARSEL:int = 41;
public static const MODE_ENTEREDITORPROP:int = 42;
public static const MODE_SAVEHLP:int = 43;
public static const MODE_LOADZZL:int = 44;
public static const MODE_SAVELEGACY:int = 45;
public static const MODE_LOADEXTRAGUI:int = 46;
public static const MODE_LOADTRANSFERWAD:int = 47;
public static const MODE_WAITUNTILPROP:int = 48;
public static const MODE_LOADEXTRALUMP:int = 49;
public static const MODE_FADETOBLOCK:int = 50;
public static const MODE_LOADCHAREDITFILE:int = 51;
public static const MODE_PATCHLOADZZT:int = 52;
public static const MODE_PATCHLOADSZT:int = 53;
public static const MODE_PATCHLOADWAD:int = 54;
public static const MODE_GETHIGHSCORES:int = 55;
public static const MODE_POSTHIGHSCORE:int = 56;

public static const MTRANS_NORM:int = 0;
public static const MTRANS_ZIPSCROLL:int = 1;
public static const MTRANS_SAVEWORLD:int = 2;

public static const FST_NONE:int = 0;
public static const FST_DIR:int = 1;
public static const FST_ZIP:int = 2;
public static const FST_WAD:int = 3;

public static const STAGE_WIDTH:int = 640;
public static const STAGE_HEIGHT:int = 400;

public static const MAX_WIDTH:int = 96;
public static const MAX_HEIGHT:int = 80;

public static const CHARS_WIDTH:int = 80;
public static const CHARS_HEIGHT:int = 25;

public static const LEGACY_TICK_SIZE:int = 420;

public static const TRANSITION_BASE_RATE:Number = 33.33333333;

// Variables
public static var stage:Stage; // Stage
public static var mg:CellGrid; // Main grid
public static var fbg:CellGrid; // File browser grid
public static var cpg:CellGrid; // Character preview grid
public static var csg:CellGrid; // Character set grid
public static var activeObjs:Boolean = false; // Whether SE instances handled
public static var oopReady:Boolean = false; // Whether OOP environment ready
public static var arcFileNames:Array = []; // Archive filenames
public static var textBrowserLines:Array = []; // Text file browser lines
public static var textBrowserName:String = ""; // Text file browser filename
public static var textBrowserSize:int; // Text browser file size
public static var textBrowserCursor:int; // Text browser view cursor
public static var fileLinkName:String = ""; // "File link" filename

public static var opts:Object = new Object(); // Current options
public static var medals:Object = new Object(); // Current medals (achievements)
public static var zztSO:SharedObject = null; // Locally persistent shared object

// Timing
public static var fpsRate:Number; // Update rate
public static var tickTimer:Timer; // Timer event
public static var mcount:int = 0; // Master count from timer
public static var scount:int = 0; // Seconds count from timer
public static var bcount:int = 0; // Blink count from timer
public static var typeAllInfoDelay:int = 0; // Delay before showing type info in editor
public static var gTickInit:Number = 3.2967032967; // Game tick count start
public static var gTickCurrent:Number = 0.0; // Game tick current remaining
public static var gameSpeed:int = 0; // Game speed slot
public static var legacyTick:int = 1; // ZZT legacy tick counter (1...420)
public static var legacyIndex:int = 1; // ZZT legacy SE index within vector
public static var propTextDelay:int = 0; // Delay before property text shown
public static var loadAnimColor:int = 14;
public static var loadAnimPos:int = 0;
public static var showLoadingAnim:Boolean = false;
public static var toastObj:MovieClip; // Toast message box
public static var toastTime:int = 0; // Time left on Toast message box
public static var speedInits:Array = [ 1.0, 1.25, 1.648351648,
	2.197802198, 3.2967032967, 3.5964, 3.95603526, 4.39558829, 4.945054945 ];

// Transitions
public static var transModeWhenDone:int;		// Transition mode set when done
public static var transColor:int;				// Transition target color
public static var transDX:int;					// Transition X-delta
public static var transDY:int;					// Transition Y-delta
public static var transProgress:int;			// On nth square in transition sequence
public static var transProgress2:Number;		// On nth square in transition sequence, float
public static var transExtent:int;				// Max value of transition sequence
public static var transSquaresPerFrame:int;		// How many squares to iterate per frame
public static var transSquaresPerFrame2:Number;	// How many squares to iterate per frame, float

public static var transFrameCount:int = 0;		// Number of frames to wait before next transition
public static var transCurFrame:int = 0;		// Frame counter before next transition
public static var transLogTime:Number = 0.0;	// Time start of last transition was logged
public static var transBaseRate:Number = 33.0;	// Optimal expected milliseconds between transitions

public static var transPaletteCur:Array;		// Palette entries current in transition
public static var transPaletteDelta:Array;		// Palette entry deltas to transition
public static var transPaletteFinal:Array;		// Palette entries upon completion of transition
public static var transPaletteStartIdx:int;		// Start of palette entries in transition
public static var transPaletteNumIdx:int;		// Number of palette entries in transition

// Special interfaces
public static var confLabelStr:String;
public static var confYesMsg:String;
public static var confNoMsg:String;
public static var confCancelMsg:String;
public static var penStartVal:int;
public static var penEndVal:int;
public static var penActVal:int;
public static var penChrCode:int;
public static var penAttr:int;
public static var textChars:String;
public static var textCharsColor:int;
public static var textMaxCharCount:int;

// Mode
public static var mainMode:int = 0;
public static var modeChanged:Boolean = false;
public static var modeWhenBrowserClosed:int = 0;
public static var modeForPropText:int = 0;
public static var inEditor:Boolean = false;
public static var configType:int = 0;

// Deployment
public static var fileSystemType:int = 0;
public static var deployedFile:String = "";
public static var deployedDir:String = "";
public static var allDeployedPaths:Array = [];
public static var indexLoadPaths:Array = [];
public static var indexLoadPathLevels:Array = [];
public static var indexLoadPos:int = 0;
public static var indexLoadFormat:int = 0;
public static var featuredWorldName:String = "";
public static var featuredWorldFile:String = "";
public static var depIndexPath:String = "";
public static var depIndexFile:String = "";
public static var depIndex:Array = [];
public static var depRecursiveLevel:int = 0;
public static var depGETVars:Object = new Object();
public static var pwadIndex:Object = new Object();

// GUI state
public static var thisGuiName:String = "DEBUGMENU";
public static var thisGui:Object;
public static var prefEditorGui:String = "ED_ULTRA1";
public static var propDictToUpdate:Object;
public static var propSubset:Object;
public static var generalSubset:Boolean = false;
public static var aSubsetName:String = "";
public static var optCursor:int = 0;
public static var Use40Column:int;
public static var OverallSizeX:int;
public static var OverallSizeY:int;
public static var GuiLocX:int = 1;
public static var GuiLocY:int = 1;
public static var GuiWidth:int = 20;
public static var GuiHeight:int = 25;
public static var cellXDiv:int = 8;
public static var cellYDiv:Number = 16;
public static var aspectMultiplier:int = 2;
public static var curHighlightButton:String = "";
public static var Viewport:Array;
public static var GuiText:String;
public static var GuiColor:Array;
public static var GuiKeys:Object;
public static var GuiLabels:Object;
public static var GuiMouseEvents:Object = new Object();
public static var GuiTextLines:Array = [];
public static var GuiColorLines:Array = [];
public static var GuiKeyMapping:Array = new Array(256);
public static var GuiKeyMappingShift:Array = new Array(256);
public static var GuiKeyMappingCtrl:Array = new Array(256);
public static var GuiKeyMappingShiftCtrl:Array = new Array(256);
public static var GuiKeyMappingAll:Array = [
	GuiKeyMapping, GuiKeyMappingShift, GuiKeyMappingCtrl, GuiKeyMappingShiftCtrl ];

public static var defsObj:Object = null;
public static var origGuiStorage:Object = new Object();
public static var guiStorage:Object = new Object();
public static var guiStack:Array = ["DEBUGMENU"];

// Game-oriented toast message and scroll message
public static var toastMsgSize:int = 1;
public static var toastMsgCont:Array = [ null, null ];
public static var toastMsgTimeLeft:int = 0;
public static var toastMsgText:Array = [ "", "" ];
public static var toastMsgColor:int = 9;

public static var scrollCenterX:Number = 240;
public static var scrollCenterY:Number = 200;
public static var numTextLines:int = 0;
public static var msgNonBlank:Boolean = false;
public static var msgScrollFormats:Array = [];
public static var msgScrollText:Array = [];
public static var msgScrollObjName:String = "";
public static var msgScrollWidth:int = 42;
public static var msgScrollHeight:int = 15;
public static var msgScrollIsRestore:Boolean = false;
public static var msgScrollFiles:Boolean = false;
public static var scroll40Column:int = 0;
public static var msgScrollIndex:int = 0;
public static var mouseScrollOffset:int = 0;
public static var curScrollCols:int = 1;
public static var curScrollRows:int = 1;

// Layers and controls
public static var guiProperties:MovieClip;
public static var guiPropText:TextArea;
public static var guiPropLabel:TextField;

public static var scrollArea:DisplayObjectContainer;
public static var main_scrollArea:ScrollFrame;
//public static var solid_scrollArea:S_ScrollFrame;
public static var scrollUL:DisplayObject;
public static var scrollUR:DisplayObject;
public static var scrollDL:DisplayObject;
public static var scrollDR:DisplayObject;
public static var scrollU1:DisplayObject;
public static var scrollU2:DisplayObject;
public static var scrollD1:DisplayObject;
public static var scrollL1:DisplayObject;
public static var scrollR1:DisplayObject;
public static var scrollGeom:Array = [];
public static var scrollBitmaps:Array = [ [], [] ];
public static var sbmRed:Array = [];
public static var sbmGreen:Array = [];
public static var sbmBlue:Array = [];
public static var sbmAlpha:Array = [];
public static var sBorderColor:uint = 0xFFFFFFFF;
public static var sShadowColor:uint = 0xFF000000;
public static var sBGColor:uint = 0xFF0000AA;
public static var sTextColor:int = 30;
public static var sCenterTextColor:int = 31;
public static var sButtonColor:int = 29;
public static var sArrowColor:int = 28;
public static var titleGrid:CellGrid; // Scroll-area-specific grid
public static var scrollGrid:CellGrid; // Scroll-area-specific grid

// Game
public static var tg:ByteArray;				// Type grid
public static var cg:ByteArray;				// Color grid
public static var lg:ByteArray;				// Lighting grid
public static var sg:Vector.<SE>;			// Status element pointer grid
public static var gridWidth:int;			// Width of type and color grid
public static var gridHeight:int;			// Height of type and color grid
public static var bEdgeType:int = 1;		// Type used as invisible border
public static var bulletType:int = 0;		// Type used as BULLET
public static var starType:int = 0;			// Type used as STAR
public static var playerType:int = 0;		// Type used as PLAYER
public static var objectType:int = 0;		// Type used as OBJECT
public static var transporterType:int = 0;	// Type used as TRANSPORTER
public static var bearType:int = 0;			// Type used as BEAR
public static var breakableType:int = 0;	// Type used as BREAKABLE
public static var waterType:int = 0;		// Type used as WATER
public static var lavaType:int = 0;			// Type used as LAVA
public static var invisibleType:int = 0;	// Type used as INVISIBLE
public static var windTunnelType:int = 253;	// Type used as _WINDTUNNEL
public static var fileLinkType:int = 0;		// Type used as FILELINK
public static var patchType:int = 0;		// Type used as PATCH
public static var loadedOOPType:int = -3;	// Basic type used in custom code
public static var overrideDefaults = false;	// True if default properties override ZZT/SuperZZT levels
public static var extraEmptyType:int = -1;	// Overridden main type code type index within extras
public static var extraEmptyCode:int = -1;	// Overridden main type code ID

public static var typeList:Array;					// List of type look-up info (ElementInfo)
public static var extraTypeList:Array;				// Extra types, as loaded from WAD file
public static var extraTypeCode:Object;				// Extra type code blocks
public static var extraKindNames:Array;				// Extra type names; used in ZZT-OOP
public static var extraKindNumbers:Array;			// Extra type numbers; used in ZZT-OOP
public static var emptyTypeTemplate:ElementInfo;	// Empty main type ElementInfo base template
public static var emptyCodeTemplate:Array;			// Empty main type code base template
public static var typeTrans:Array = new Array(256);	// List of number-to-type look-ups
public static var statElem:Vector.<SE>;				// Vector of status element info
public static var globals:Object;					// Global variables dictionary
public static var regions:Object;					// Regions dictionary
public static var globalProps:Object;				// Global properties dictionary
public static var boardProps:Object;				// Board properties dictionary
public static var masks:Object;						// Masks dictionary
public static var soundFx:Object;					// Sound FX dictionary

public static var pMoveDir:int = -1;				// Logged movement direction
public static var pShootDir:int = -1;				// Logged shoot direction

public static var highScores:Array = [];			// High score table
public static var highScoresLoaded:Boolean = false;	// Whether high scores are loaded
public static var highScoreServer:Boolean = false;	// Whether high scores target server

// Confirmation yes/no buttons
public static var confButtonX:int = 1;
public static var confButtonY:int = 1;
public static var confButtonSel:int = -1;
public static var confButtonTextYes:String = " Yes ";
public static var confButtonTextNo:String = " No ";
public static var confButtonColorSelYes:int = 32 + 15;
public static var confButtonColorSelNo:int = 64 + 15;
public static var confButtonColorYes:int = 10;
public static var confButtonColorNo:int = 12;
public static var confButtonUnderBG:int = 0;
public static var confButtonUnderText:Array = [];
public static var confButtonUnderColors:Array = [];

// Edge-nav arrows
public static var lastEdgeNavArrowX:int = -1;
public static var lastEdgeNavArrowY:int = -1;
public static var edgeNavArrowChars:Array = [ 16, 31, 17, 30 ];

public static var stdTorchMask:Array = [
 "000111111111000",
 "001111111111100",
 "011111111111110",
 "011111111111110",
 "111111111111111",
 "011111111111110",
 "011111111111110",
 "001111111111100",
 "000111111111000" ];
public static var stdBombMask:Array = [
 "000111111111000",
 "001111111111100",
 "011111111111110",
 "011111111111110",
 "111111111111111",
 "011111111111110",
 "011111111111110",
 "001111111111100",
 "000111111111000" ];
public static var sztBombMask:Array = [
 "000011111110000",
 "001111111111100",
 "011111111111110",
 "011111111111110",
 "111111111111111",
 "111111111111111",
 "111111111111111",
 "111111111111111",
 "111111111111111",
 "111111111111111",
 "111111111111111",
 "011111111111110",
 "011111111111110",
 "001111111111100",
 "000011111110000" ];

public static var configTypeNames:Array = ["Modern ", "Classic"];

// This function drills down through the object hierarchy until
// a named child is found.
public static function getSuperChildByName(cont:DisplayObjectContainer, str:String):DisplayObject {
	//First, see if direct named child exists.
	var directchild:DisplayObject = cont.getChildByName(str);
	if (directchild) return directchild;

	//Check each container for additional children.
	for (var n:int = 0; n < cont.numChildren; n++) {
		var obj:DisplayObject = cont.getChildAt(n);
		if (obj is DisplayObjectContainer)
		{
			var tchild:DisplayObject =
				getSuperChildByName(DisplayObjectContainer(obj), str);
			if (tchild) return tchild;
		}
	}

	//No display object children match named child.
	return null;
}

// Constructor
public static function init(myStage:Stage, setEventHandlers:Boolean=true) {
	// Set stage
	stage = myStage;

	// Initialize bitmaps
	ASCII_Characters.Separate_ASCII_Characters();

	// Add standard grid to the stage
	mg = new CellGrid(CHARS_WIDTH, CHARS_HEIGHT);
	stage.addChild(mg);
	SE.mg = mg;

	// Add file browser grid to the stage
	fbg = new CellGrid(CHARS_WIDTH, CHARS_HEIGHT);
	fbg.visible = false;
	stage.addChild(fbg);

	// Add character preview and character set grids to the stage
	cpg = new CellGrid(3, 3);
	cpg.visible = false;
	cpg.x = 15 * ASCII_Characters.CHAR_WIDTH;
	cpg.y = 21 * ASCII_Characters.CHAR_HEIGHT;
	stage.addChild(cpg);
	csg = new CellGrid(32, 8);
	csg.visible = false;
	csg.x = 24 * ASCII_Characters.CHAR_WIDTH;
	csg.y = 16 * ASCII_Characters.CHAR_HEIGHT;
	stage.addChild(csg);

	// Add text portions of ScrollArea to the stage
	titleGrid = new CellGrid(CHARS_WIDTH, 1);
	titleGrid.visible = false;
	titleGrid.writeConst(0, 0, CHARS_WIDTH, 1, " ", sTextColor);
	stage.addChild(titleGrid);
	scrollGrid = new CellGrid(CHARS_WIDTH, CHARS_HEIGHT);
	scrollGrid.visible = false;
	scrollGrid.writeConst(0, 0, CHARS_WIDTH, CHARS_HEIGHT, " ", sTextColor);
	stage.addChild(scrollGrid);

	// Add ScrollFrame to the stage
	main_scrollArea = new ScrollFrame();
	main_scrollArea.visible = false;
	setScrollCornerMapping(main_scrollArea);
	scrollArea.visible = false;
	stage.addChild(scrollArea);

	// Add GUI properties to the stage
	guiProperties = new GUIProperties();
	guiPropText = getSuperChildByName(guiProperties, "TA_GUIProp") as TextArea;
	guiPropLabel = getSuperChildByName(guiProperties, "TA_Label") as TextField;
	guiProperties.visible = false;
	var tf:TextFormat = new TextFormat("Courier New", 11, 0xFFFFFF, true, false, false,
		'', '', TextFormatAlign.LEFT, 0, 0, 0, 0);
	guiPropText.setStyle("textFormat", tf);
	guiPropText.enabled = false;
	stage.addChild(guiProperties);

	// Create toast object
	toastObj = new ToastObj();
	toastObj.x = STAGE_WIDTH / 2 - (toastObj.width / 2);
	toastObj.y = STAGE_HEIGHT - toastObj.height;
	toastObj.visible = false;
	stage.addChild(toastObj);

	// Create editor and game char/color storage space
	editor.editorChars = new ByteArray();
	editor.editorAttrs = new ByteArray();
	tg = new ByteArray();
	SE.tg = tg;
	cg = new ByteArray();
	SE.cg = cg;
	lg = new ByteArray();
	SE.lg = lg;
	sg = new Vector.<SE>();
	SE.sg = sg;
	for (var i:int = 0; i < (MAX_WIDTH+2)*(MAX_HEIGHT*2); i++)
	{
		editor.editorChars[i] = 32;
		editor.editorAttrs[i] = 31;
		tg[i] = 0;
		cg[i] = 0;
		lg[i] = 0;
		sg.push(null);
	}

	globals = new Object();
	regions = new Object();
	globalProps = new Object();
	boardProps = new Object();
	masks = new Object();
	soundFx = new Object();

	globalProps["MAXSTATELEMENTCOUNT"] = 9999;
	globalProps["SOUNDOFF"] = 0;
	globalProps["BECOMESAMECOLOR"] = 0;
	globalProps["LIBERALCOLORCHANGE"] = 0;
	globalProps["VERSION"] = ZZTProp.defaultPropsGeneral["VERSION"];
	globalProps["MOUSEBEHAVIOR"] = 3;
	globalProps["IMMEDIATESCROLL"] = 0;
	globalProps["ORIGINALSCROLL"] = 0;
	globalProps["OVERLAYSCROLL"] = 1;
	globalProps["OLDTORCHBAR"] = 0;
	globalProps["BIT7ATTR"] = 1;
	globalProps["FASTESTFPS"] = 30;
	globalProps["LEGACYTICK"] = 0;
	globalProps["BQUESTHACK"] = 0;
	globalProps["ZSTONELABEL"] = "Stone";
	globalProps["SITELOADCHOICE"] = 3;
	globalProps["HIGHSCOREACTIVE"] = 1;
	globalProps["MASTERVOLUME"] = 50;
	globalProps["FREESCOLLING"] = 0;
	globalProps["SENDALLENTER"] = 0;
	globalProps["PLAYERCHARNORM"] = 2;
	globalProps["PLAYERCOLORNORM"] = 31;
	globalProps["PLAYERCHARHURT"] = 1;
	globalProps["PLAYERCOLORHURT"] = 31;
	globalProps["PAUSEANIMATED"] = 1;
	globalProps["DEP_RECURSIVELEVEL"] = 0;
	globalProps["DEP_AUTORUNZIP"] = 0;
	globalProps["DEP_STARTUPFILE"] = "";
	globalProps["DEP_STARTUPGUI"] = "DEBUGMENU";
	globalProps["DEP_EXTRAFILTER"] = "";
	globals["$PLAYER"] = -1;
	globals["$PLAYERMODE"] = 3; // "ZZT title screen" mode
	globals["$PLAYERPAUSED"] = 0;
	globals["$PAUSECYCLE"] = 0;
	globals["$PASSAGEEMERGE"] = 0;
	globals["$LASTSAVESECS"] = 0;
	addMask("TORCH", stdTorchMask);
	addMask("BOMB", stdBombMask);
	addMask("SZTBOMB", sztBombMask);

	statElem = new Vector.<SE>();
	editor.newWorldSetup();
	ZZTProp.setOverridePropDefaults();
	ZZTProp.overridePropsGeneral = ZZTProp.overridePropsGenModern;

	// Initialize sounds
	Sounds.initAllSounds(soundFx, globalProps);

	// Keypress timing vector
	input.keyCodeDowns = new Vector.<int>(256, true);
	input.keyCharDowns = new Vector.<int>(256, true);
	for (i = 0; i < 256; i++)
	{
		input.keyCodeDowns[i] = 0;
		input.keyCharDowns[i] = 0;
	}

	// Read deployment GET variables from URL, if any
	var flashVars:Object = stage.loaderInfo.parameters;
	//var getVars:String = "";
	//var uVars:URLVariables = new URLVariables(getVars);
	for (var kObj:Object in flashVars)
	{
		var k:String = kObj.toString().toUpperCase();
		if (k.substr(0, 4) == "DEP_")
		{
			// Can't change all deployment with GET variables; only some work
			if (k != "DEP_STARTUPFILE" && k != "DEP_AUTORUNZIP" && k != "DEP_EXTRAFILTER")
				k = "";
		}

		if (k.length > 0)
		{
			var v:String = flashVars[kObj].toString();
			depGETVars[k] = v;
		}

		//getVars += "\n" + kObj.toString() + ":" + flashVars[kObj].toString();
	}
	//Toast(getVars);

	// Add event handlers
	if (setEventHandlers)
	{
		stage.addEventListener(KeyboardEvent.KEY_DOWN,input.keyPressed,false,3);
		stage.addEventListener(KeyboardEvent.KEY_UP,input.keyReleased,false,3);
		stage.addEventListener(MouseEvent.MOUSE_DOWN,input.mousePressed,false,2);
		stage.addEventListener(MouseEvent.MOUSE_UP,input.mouseReleased,false,2);
		stage.addEventListener(MouseEvent.MOUSE_WHEEL,input.mouseWheel,false,2);
		stage.addEventListener(MouseEvent.MOUSE_MOVE,input.mouseDrag,false,1);
	}

	fpsRate = 30;
	mcount = 0;
	setGameSpeed(4);
	if (setEventHandlers)
	{
		tickTimer = new Timer(int(1000/fpsRate), 0); // FPS -> Milliseconds
		tickTimer.addEventListener(TimerEvent.TIMER, mTick, false, 0);
		tickTimer.start();
	}
	else
		mg.visible = false;

	initSharedObj();

	// Load main GUI component file
	if (setEventHandlers)
		parse.loadTextFile(GUIS_PREFIX + "zzt_guis.txt", MODE_LOADMAIN);
}

// Initialize shared object storage.
public static function initSharedObj():void {
	// ZZTMedal.resetMedals();
	if (!USE_SHAREDOBJECTS)
		return;

	try {
		// Get or create shared object
		zztSO = SharedObject.getLocal("ZZTSOState");

		// Saved configuration settings
		var cfgHives:Array = ["CFGMODERN", "CFGCLASSIC", "CFGZZTSPEC", "CFGSZTSPEC"];
		for (var i:int = 0; i < cfgHives.length; i++) {
			var soName:String = cfgHives[i];
			guaranteeSharedObj(soName);

			var o:Object = zztSO.data[soName];
			for (var s:String in o) {
				if (soName == "CFGMODERN")
					ZZTProp.overridePropsGenModern[s] = o[s];
				else if (soName == "CFGCLASSIC")
					ZZTProp.overridePropsGenClassic[s] = o[s];
				else if (soName == "CFGZZTSPEC")
					ZZTProp.overridePropsZZT[s] = o[s];
				else if (soName == "CFGSZTSPEC")
					ZZTProp.overridePropsSZT[s] = o[s];
			}
		}

		if (depGETVars.hasOwnProperty("CONFIGTYPE"))
		{
			var cTypeVal:int = utils.int0(depGETVars["CONFIGTYPE"]);
			ZZTProp.overridePropsGenModern["CONFIGTYPE"] = cTypeVal;
		}

		setConfigType(ZZTProp.overridePropsGenModern["CONFIGTYPE"] & 1);

		// Saved medal list
		if (zztSO.data.hasOwnProperty("MEDALLIST"))
			medals = zztSO.data.MEDALLIST;
		else
			zztSO.data.MEDALLIST = medals;
	}
	catch (e:Error)
	{
		Toast("SHAREDOBJECT LOAD ERROR:  " + e);
	}
}

// Set empty shared object if it doesn't already exist
public static function guaranteeSharedObj(soName:String):void {
	if (!zztSO.data.hasOwnProperty(soName))
		zztSO.data[soName] = new Object();
}

// Save a shared object member.
public static function saveSharedObj(soName:String, soObject:Object):void {
	if (!USE_SHAREDOBJECTS)
		return;

	try {
		zztSO.data[soName] = soObject;
		zztSO.flush();
	}
	catch (e:Error)
	{
		Toast("SHAREDOBJECT SAVE ERROR:  " + e);
	}
}

// Delete a shared object member.
public static function deleteSharedObj(soName:String):void {
	if (!USE_SHAREDOBJECTS)
		return;

	try {
		delete zztSO.data[soName];
		zztSO.flush();
	}
	catch (e:Error)
	{
		Toast("SHAREDOBJECT DELETION ERROR:  " + e);
	}
}

// Establish configuration read from INI file
public static function establishINI():Boolean {
	// Read deployment variables from INI
	var iniVars:Object = parse.jsonObj;
	for (var gvObj:Object in iniVars) {
		// World property is taken from INI, unless overridden by HTTP GET variable
		var gvStr:String = gvObj.toString().toUpperCase();
		if (!depGETVars.hasOwnProperty(gvStr))
			depGETVars[gvObj] = iniVars[gvObj];
	}

	for (var kObj:Object in depGETVars) {
		var k:String = kObj.toString().toUpperCase();
		if (k.charAt(0) == "'" || k.charAt(0) == "#")
			continue;

		if (k == "DEP_INDEX")
		{
			// Index is defined in INI file
			var indexArray:Array = depGETVars[kObj];
			for (var i:int = 0; i < indexArray.length; i++) {
				var s:String = utils.scrubPath(indexArray[i]);
				if (s != "")
					allDeployedPaths.push(s);
			}

			if (allDeployedPaths.length > 0)
			{
				featuredWorldFile = allDeployedPaths[0];
				featuredWorldName = utils.namePartOfFile(featuredWorldFile);
			}
		}
		else if (k == "PWADS")
		{
			// PWAD index
			pwadIndex = depGETVars[kObj];
		}
		else
		{
			var v:String = depGETVars[kObj].toString();
			if (k == "DEP_INDEXRESOURCE")
			{
				// Index is fetched from HTTP resource
				indexLoadFormat = 0;
				depIndexFile = utils.scrubPath(v);
				indexLoadPaths.push(depIndexFile);
				indexLoadPathLevels.push(0);
			}
			else if (k == "DEP_INDEXPATH")
			{
				// Index is fetched by evaluating directory over HTTP
				indexLoadFormat = 1;
				depIndexFile = utils.scrubPath(v);
				indexLoadPaths.push(depIndexFile);
				indexLoadPathLevels.push(0);
				if (depGETVars.hasOwnProperty("DEP_RECURSIVELEVEL"))
					depRecursiveLevel = int(depGETVars["DEP_RECURSIVELEVEL"]);
			}

			if ((v.charCodeAt(0) >= 48 && v.charCodeAt(0) <= 57) || v.charAt(0) == "-")
			{
				// Integer property
				ZZTProp.defaultPropsGeneral[k] = int(v);
				ZZTProp.overridePropsGeneral[k] = int(v);
				globalProps[k] = int(v);
			}
			else
			{
				// String property
				ZZTProp.defaultPropsGeneral[k] = v;
				ZZTProp.overridePropsGeneral[k] = v;
				globalProps[k] = v;
			}
		}
	}

	if (indexLoadPaths.length > 0)
	{
		// If we need to load paths to determine configuration, start now.
		parse.loadTextFile(depIndexFile, MODE_LOADINDEXPATHS);
		return true;
	}

	return false;
}

// Parse the returned file for index paths.
public static function addIndexPaths():Boolean {
	if (indexLoadFormat == 0)
	{
		// Index resource has paths separated by line breaks.
		var realStr:String = parse.dataset.toUpperCase();
		var bound1:int = realStr.indexOf("<PRE>");
		var bound2:int = realStr.indexOf("</PRE>");
		if (bound1 != -1 && bound2 != -1)
			realStr = parse.dataset.substring(bound1 + 5, bound2); // Inside PRE tag
		else
			realStr = parse.dataset; // Entire

		var lines:Array = realStr.split("\n");
		for (var i:int = 0; i < lines.length; i++) {
			// Scrub and strip whitespace
			var s:String = utils.allStrip(utils.scrubPath(lines[i]));

			// If path starts with "./" change to ordinary file portion
			if (s.substr(0, 2) == "./")
				s = s.substr(2);

			// Add to deployed paths
			if (s != "")
				allDeployedPaths.push(s);
		}

		if (allDeployedPaths.length > 0)
		{
			featuredWorldFile = allDeployedPaths[0];
			featuredWorldName = utils.namePartOfFile(featuredWorldFile);
		}

		// Done!
		return false;
	}
	else
	{
		// Need to use heuristics to deduce paths.
		var aHrefPattern:RegExp = /((href)|(HREF))=["'][\-_A-Za-z0-9]+/;
		var quotePattern:RegExp = /["']/;
		/*var alphaNumPattern:RegExp = /[\-_A-Za-z0-9]+/;
		/var filePattern:RegExp = /[\-_A-Za-z0-9]+[.][\-_A-Za-z0-9]+/;
		var afterFilePattern:RegExp = /[^\-_A-Za-z0-9]+/;
		var dirPattern:RegExp = /[\-_A-Za-z0-9]+[\/]/;*/

		// Find files and directories.
		var fileArray:Array = [];
		var dirArray:Array = [];
		var fileStr:String = parse.dataset;
		while (fileStr != "") {
			var idx:int = fileStr.search(aHrefPattern);
			if (idx == -1)
				fileStr = ""; // Done
			else
			{
				// Get text within hyperlink location
				var nextIdx:int = fileStr.substr(idx).search(quotePattern) + idx;
				var finalIdx:int = fileStr.substr(nextIdx + 1).search(quotePattern);
				if (finalIdx == -1)
					continue;
				finalIdx += nextIdx + 1;

				s = fileStr.substring(nextIdx + 1, finalIdx);
				if (s.charAt(0) != ".")
				{
					if (s.charAt(s.length - 1) == "/")
						dirArray.push(s);
					else
						fileArray.push(s);
				}

				fileStr = fileStr.substr(finalIdx + 1);
			}
		}

		// Set deployed paths, joining root to found file
		if (depIndexFile == ".")
			depIndexFile = "";
		else if (depIndexFile.charAt(depIndexFile.length - 1) != "/")
			depIndexFile += "/";

		for (i = 0; i < fileArray.length; i++)
			allDeployedPaths.push(depIndexFile + fileArray[i]);

		// If we found subfolders, only continue to enumerate contents
		// of these folders if the recursion level would allow it.
		if (indexLoadPathLevels[indexLoadPos] < depRecursiveLevel)
		{
			for (i = 0; i < dirArray.length; i++)
			{
				indexLoadPaths.push(depIndexFile + dirArray[i])
				indexLoadPathLevels.push(indexLoadPathLevels[indexLoadPos] + 1);
			}
		}

		if (++indexLoadPos >= indexLoadPaths.length)
		{
			if (allDeployedPaths.length > 0)
			{
				featuredWorldFile = allDeployedPaths[0];
				featuredWorldName = utils.namePartOfFile(featuredWorldFile);
			}

			return false; // Done!
		}

		// Not done yet; need to load more subfolder contents.
		depIndexFile = indexLoadPaths[indexLoadPos];
		parse.loadTextFile(depIndexFile, MODE_LOADINDEXPATHS);
		return true;
	}
}

// This function brings up an interface for loading one of files captured
// by the deployed configuration.
public static function loadDeployedFile(action:int):void {
	numTextLines = 0;
	msgScrollFormats = [];
	msgScrollText = [];
	msgScrollFiles = true;

	// Convert file filter to regular expression
	var filter:String = globalProps["DEP_EXTRAFILTER"].toUpperCase();
	var filterExpr:RegExp;
	if (filter != "")
	{
		filter = filter.replace(".", "[.]");
		filter = filter.replace("*", ".*");
		filterExpr = new RegExp(filter);
	}

	// Deployed filenames
	var slChoice:int = globalProps["SITELOADCHOICE"];
	var subDirFiles:Array = allDeployedPaths;
	for (var i:int = 0; i < subDirFiles.length && (slChoice == 2 || slChoice == 3); i++) {
		// Display file link, unless filtered out
		var btnText:String = subDirFiles[i];

		var testText:String = btnText.toUpperCase();
		if (filter == "")
			addMsgLine(i.toString(), btnText); // No filter
		else if (filter != "" && testText.search(filterExpr) != -1)
			addMsgLine(i.toString(), btnText); // Matches regular expression
	}

	if (allDeployedPaths.length == 0 && slChoice == 2)
	{
		// No deployed files
		msgScrollFiles = false;
		mainMode = MODE_NORM;
		addMsgLine("$", "No deployed files for site.");
		addMsgLine("$", "Check " + GUIS_PREFIX + "zzt_ini.txt");
	}

	// Local file options
	if (slChoice == 0)
	{
		// Last-loaded type ONLY--show local file interface immediately.
		highScoreServer = false;
		if (globalProps["WORLDTYPE"] == -1)
			parse.loadLocalFile("ZZT", MODE_NATIVELOADZZT, MODE_NORM);
		else if (globalProps["WORLDTYPE"] == -2)
			parse.loadLocalFile("SZT", MODE_NATIVELOADSZT, MODE_NORM);
		else
			parse.loadLocalFile("WAD", MODE_LOADWAD, MODE_NORM);

		return;
	}
	else if (slChoice == 1 || slChoice == 3)
	{
		// Local file options exist.
		if (allDeployedPaths.length > 0)
			addMsgLine("$", "-------------------------");

		addMsgLine("-1", "(Local File:  ZZT)");
		addMsgLine("-2", "(Local File:  Super ZZT)");
		addMsgLine("-3", "(Local File:  WAD)");
		addMsgLine("-4", "(Local File:  ZIP)");
	}

	// Initiate scroll
	fileSystemType = FST_NONE;
	ScrollMsg("Game Files");
}

// Generic launch of deployed file, provided it is present in deployed configuration.
public static function launchDeployedFileIfPresent(fileName:String):void {
	// Search deployed paths for an exact match.
	for (var i:int = 0; i < allDeployedPaths.length; i++) {
		if (fileName.toUpperCase() == allDeployedPaths[i].toUpperCase())
		{
			// Exact match.
			launchDeployedFile(fileName);
			return;
		}
	}

	// If no exact match exists, see if the name portion only matches.
	fileName = utils.namePartOfFile(fileName);
	for (i = 0; i < allDeployedPaths.length; i++) {
		if (fileName.toUpperCase() ==
			utils.namePartOfFile(allDeployedPaths[i]).toUpperCase())
		{
			// Name-only match.
			launchDeployedFile(allDeployedPaths[i]);
			return;
		}
	}

	// Ignore the launch attempt if no match exists.
}

// This function performs a generic "launch" of a deployed file.
// Can load a game world or display file as text.
public static function launchDeployedFile(fileName:String):void {
	mainMode = MODE_NORM;
	if (utils.endswith(fileName, ".ZZT"))
	{
		highScoreServer = true;
		featuredWorldFile = fileName;
		parse.loadRemoteFile(fileName, MODE_LOADZZT);
	}
	else if (utils.endswith(fileName, ".SZT"))
	{
		highScoreServer = true;
		featuredWorldFile = fileName;
		parse.loadRemoteFile(fileName, MODE_LOADSZT);
	}
	else if (utils.endswith(fileName, ".WAD"))
	{
		highScoreServer = true;
		featuredWorldFile = fileName;
		parse.loadRemoteFile(fileName, MODE_LOADWAD);
	}
	else if (utils.endswith(fileName, ".ZIP"))
	{
		highScoreServer = true;
		featuredWorldFile = fileName;
		parse.loadRemoteFile(fileName, MODE_LOADZIP);
	}
	else if (utils.endswith(fileName, ".HLP"))
		displayFileLink(fileName);
	else
		parse.loadRemoteFile(fileName, MODE_LOADFILEBROWSER);

	featuredWorldName = utils.namePartOfFile(featuredWorldFile);
}

// Find a type based on the name
public static function getTypeFromName(tName:String):ElementInfo {
	// We iterate in reverse order as a way to capture overridden types first.
	for (var i:int = typeList.length - 1; i >= 0; i--) {
		var eInfo:ElementInfo = typeList[i];
		if (eInfo.NAME == tName)
			return eInfo; // Match
	}

	// No match
	return null;
}

// Compile zzt_objs.txt file with default object definitions
public static function establishOOP():Boolean
{
	// For each child of the definitions, we have an object definition.
	// The first definition should always be the main dispatch receiver.
	typeList = [];
	extraTypeList = [];
	extraTypeCode = new Object();
	extraKindNames = [];
	extraKindNumbers = [];
	SE.typeList = typeList;
	SE.statElem = statElem;
	SE.statLessCount = 0;
	SE.IsDark = 0;
	SE.darkChar = 176;
	SE.darkColor = 8;
	SE.CameraX = 1;
	SE.CameraY = 1;
	interp.typeList = typeList;
	interp.typeTrans = typeTrans;
	interp.codeBlocks = new Array(0);
	oop.zeroTypeLabelAction = 0;
	oop.setOOPType();
	loadedOOPType = -3;

	for (var s:String in defsObj)
	{
		if (!establishType(s, defsObj[s], true))
			return false;
	}
	oop.zeroTypeLabelAction = 0;

	// Create several "stock" status elements.
	interp.customDrawSE = new SE(0, 0, 0, 0, true);
	interp.blankSE = new SE(0, 0, 0, 0, true);
	interp.thisSE = interp.blankSE;
	interp.numBuiltInTypes = typeList.length;
	interp.numOverrideTypes = 0;

	// Set up type translation
	setupTypeTranslation();
	emptyTypeTemplate = typeList[0];
	emptyCodeTemplate = interp.codeBlocks[0];

	// Property dispatch function
	interp.onPropPos = interp.findLabel(interp.codeBlocks[0], "$ONPROPERTY");
	interp.onMousePos = interp.findLabel(interp.codeBlocks[0], "$ONMOUSE");

	// Remember how many built-in object code blocks there are
	interp.numBuiltInCodeBlocks = interp.codeBlocks.length;
	interp.numBuiltInCodeBlocksPlus = interp.numBuiltInCodeBlocks;
	globalProps["NUMBASECODEBLOCKS"] = interp.numBuiltInCodeBlocksPlus;
	interp.unCompCode = [];

	oopReady = true;
	return true;
}

public static function establishExtraTypes(typeObjs:Object):Boolean {
	extraTypeList = [];
	extraEmptyType = -1;
	extraEmptyCode = -1;
	extraKindNames = [];
	extraKindNumbers = [];
	oop.zeroTypeLabelAction = 0;
	oop.setOOPType();
	loadedOOPType = -3;

	for (var k:String in typeObjs) {
		extraKindNames.push(k.toUpperCase());
		extraKindNumbers.push(int(typeObjs[k]["NUMBER"]));
	}

	for (k in typeObjs) {
		if (!establishType(k, typeObjs[k], false))
			return false;
	}

	for (var i:int = 0; i < extraTypeList.length; i++)
	{
		if (extraTypeList[i].NUMBER != 0)
			typeList.push(extraTypeList[i]);
	}

	ZZTLoader.worldType = globalProps["WORLDTYPE"];
	loadedOOPType = globalProps["WORLDTYPE"];
	oop.setOOPType();

	setupTypeTranslation();
	interp.onPropPos = interp.findLabel(interp.codeBlocks[0], "$ONPROPERTY");
	interp.onMousePos = interp.findLabel(interp.codeBlocks[0], "$ONMOUSE");
	interp.numOverrideTypes = extraTypeList.length;
	interp.numBuiltInCodeBlocksPlus = interp.codeBlocks.length;

	return true;
}

// Reset type information to original state loaded from zzt_oop.txt.
public static function resetTypes():void {
	if (extraEmptyType != -1)
	{
		// Restore main type code, if replaced
		typeList[0] = emptyTypeTemplate;
		interp.codeBlocks[0] = emptyCodeTemplate;
		extraEmptyType = -1;
		extraEmptyCode = -1;

		// Restore "zapped" main type code labels
		oop.restoreOldZeroTypeLabels();
	}

	// Clear jump optimizations
	for (var i:int = 0; i < interp.numBuiltInCodeBlocks; i++)
		interp.findLabel(interp.codeBlocks[i], "#!NOLABELMATCH", 0, 4);

	// Restore number of types to original count
	typeList.length = interp.numBuiltInTypes;

	// Restore number of code blocks to original count
	interp.numBuiltInCodeBlocksPlus = interp.numBuiltInCodeBlocks;
	interp.codeBlocks.length = interp.numBuiltInCodeBlocks;
}

public static function establishType(name:String, defProps:Object, builtIn:Boolean):Boolean {
	// Create ElementInfo instance; handle members.
	var myDef:ElementInfo = new ElementInfo(name.toUpperCase());
	var codeProp:String = "#required!";
	var hasCustomStart:Boolean = false;
	oop.lineStartIP = 0;
	oop.zeroTypeLabelAction = 0;

	for (var prop:String in defProps)
	{
		var uProp:String = prop.toUpperCase();
		switch (uProp) {
			case "NUMBER":
				myDef.NUMBER = int(defProps[prop]);
			break;
			case "CYCLE":
				myDef.CYCLE = int(defProps[prop]);
			break;
			case "STEPX":
				myDef.STEPX = int(defProps[prop]);
			break;
			case "STEPY":
				myDef.STEPY = int(defProps[prop]);
			break;
			case "CHAR":
				myDef.CHAR = int(defProps[prop]);
			break;
			case "COLOR":
				myDef.COLOR = int(defProps[prop]);
			break;
			case "NOSTAT":
				myDef.NoStat = Boolean(defProps[prop]);
			break;
			case "BLOCKOBJECT":
				myDef.BlockObject = Boolean(defProps[prop]);
			break;
			case "BLOCKPLAYER":
				myDef.BlockPlayer = Boolean(defProps[prop]);
			break;
			case "ALWAYSLIT":
				myDef.AlwaysLit = Boolean(defProps[prop]);
			break;
			case "DOMINANTCOLOR":
				myDef.DominantColor = Boolean(defProps[prop]);
			break;
			case "FULLCOLOR":
				myDef.FullColor = Boolean(defProps[prop]);
			break;
			case "TEXTDRAW":
				myDef.TextDraw = Boolean(defProps[prop]);
			break;
			case "CUSTOMDRAW":
				myDef.CustomDraw = Boolean(defProps[prop]);
			break;
			case "HASOWNCHAR":
				myDef.HasOwnChar = Boolean(defProps[prop]);
			break;
			case "HASOWNCODE":
				myDef.HasOwnCode = Boolean(defProps[prop]);
			break;
			case "CUSTOMSTART":
				hasCustomStart = Boolean(defProps[prop]);
			break;
			case "PUSHABLE":
				myDef.Pushable = int(defProps[prop]);
			break;
			case "SQUASHABLE":
				myDef.Squashable = Boolean(defProps[prop]);
			break;
			case "CODE":
				codeProp = prop;
			break;
			default:
				// This member is assumed to be a default for a status
				// element or initial value.
				myDef.extraVals[uProp] = defProps[prop];
			break;
		}
	}

	// Ensure default "CHAR" extension exists if has own character.
	if (myDef.HasOwnChar)
		myDef.extraVals["CHAR"] = myDef.CHAR;

	// The one final property to handle is the code, which must be compiled.
	// This property is sent to the oop object, and a valid code ID is returned.
	if (!builtIn)
		extraTypeCode[name] = defProps[codeProp];

	var codeLines:Array = defProps[codeProp].split("\n");
	var myCodeBlock:Array = [];

	// First line cannot be empty text
	if (codeLines[0] == "\r" || codeLines[0] == "")
		codeLines[0] = "' ";

	// Collect all labels used in main type code initially.
	// If overridden main type code, "zap" these old labels in the process.
	if (myDef.NUMBER == 0)
	{
		oop.zeroTypeLabelAction = builtIn ? 1 : 2;
		if (!builtIn)
		{
			myCodeBlock = emptyCodeTemplate.concat();
			interp.codeBlocks[0] = myCodeBlock;
		}
	}

	// Compile code for type
	for (var i:int = 0; i < codeLines.length; i++) {
		// Strip trailing CR, if present
		var line:String = codeLines[i];
		if (line.charCodeAt(line.length-1) == 13)
		{
			line = line.substr(0, line.length-1);
			codeLines[i] = line;
		}

		// If line continuation code present, concatenate the next line.
		if (line.length > 0)
		{
			if (line.charAt(line.length-1) == '\\')
			{
				codeLines[i+1] = line.substr(0, line.length-1) + codeLines[i+1];
				codeLines[i] = "'";
				continue;
			}
		}

		oop.checkMiddleOffset = -1;
		var resultArr:Array = oop.parseLine(myCodeBlock, codeLines[i]);
		if (resultArr == null)
		{
			Toast(oop.errorText);
			return false;
		}
	}

	// If custom code allowed, identify "real" start if needed
	if (hasCustomStart)
		myDef.CustomStart = myCodeBlock.length;

	// Add object definition to list.  Compiled code block is permanently
	// added to the code block record.
	if (builtIn)
	{
		if (myDef.NUMBER == 0)
		{
			// The zero-type is always added at the start.
			interp.codeBlocks.splice(0, 0, myCodeBlock);
			typeList.splice(0, 0, myDef);
		}
		else
		{
			// All other types are added sequentially.
			interp.codeBlocks.push(myCodeBlock);
			typeList.push(myDef);
		}
	}
	else
	{
		if (myDef.NUMBER == 0)
		{
			// An overridden zero-type must be accounted for.
			// This REPLACES the original zero-type template with
			// a composite of the original and the appended custom section.
			myDef.CODEID = 0;
			extraEmptyType = extraTypeList.length;
			extraEmptyCode = 0;

			interp.codeBlocks.push(myCodeBlock);
			extraTypeList.push(myDef);
			typeList[0] = myDef;
		}
		else
		{
			// Type is added to extra type list.
			myDef.CODEID = interp.codeBlocks.length;
			interp.codeBlocks.push(myCodeBlock);
			extraTypeList.push(myDef);
		}
	}

	return true;
}

public static function setupTypeTranslation():void {
	// Create the number-to-type translation table.
	for (var i:int = 0; i < 256; i++)
		typeTrans[i] = 0;
	for (i = 0; i < typeList.length; i++)
		typeTrans[typeList[i].NUMBER] = i;

	typeTrans[0] = 0;

	// Find special dispatch label locations in the code
	for (i = 0; i < typeList.length; i++)
	{
		if (typeList[i].NAME == "BOARDEDGE")
			bEdgeType = i;
		else if (typeList[i].NAME == "BULLET")
			bulletType = i;
		else if (typeList[i].NAME == "STAR")
			starType = i;
		else if (typeList[i].NAME == "PLAYER")
			playerType = i;
		else if (typeList[i].NAME == "OBJECT")
			objectType = i;
		else if (typeList[i].NAME == "TRANSPORTER")
			transporterType = i;
		else if (typeList[i].NAME == "BEAR")
			bearType = i;
		else if (typeList[i].NAME == "BREAKABLE")
			breakableType = i;
		else if (typeList[i].NAME == "LAVA")
			lavaType = i;
		else if (typeList[i].NAME == "WATER")
			waterType = i;
		else if (typeList[i].NAME == "INVISIBLE")
			invisibleType = i;
		else if (typeList[i].NAME == "_WINDTUNNEL")
			windTunnelType = i;
		else if (typeList[i].NAME == "FILELINK")
			fileLinkType = i;
		else if (typeList[i].NAME == "PATCH")
			patchType = i;

		if (i < interp.numBuiltInTypes)
			typeList[i].CODEID = i;
		typeList[i].LocPUSHBEHAVIOR =
			interp.findLabel(interp.codeBlocks[typeList[i].CODEID], "$PUSHBEHAVIOR");
		typeList[i].LocWALKBEHAVIOR =
			interp.findLabel(interp.codeBlocks[typeList[i].CODEID], "$WALKBEHAVIOR");
		typeList[i].LocCUSTOMDRAW =
			interp.findLabel(interp.codeBlocks[typeList[i].CODEID], "$CUSTOMDRAW");
	}
}

// Escape quotation marks in code
public static function markUpCodeQuotes(codeStr:String):String {
	var resultStr:String = "";
	var i:int = 0;
	do {
		var loc:int = codeStr.indexOf("\"", i);
		if (loc == -1)
		{
			resultStr += codeStr.substring(i);
			i = codeStr.length;
		}
		else
		{
			resultStr += codeStr.substring(i, loc) + "\\\"";
			i = loc + 1;
		}
	} while (i < codeStr.length);

	return resultStr;
}

// Compile custom ZZT-OOP code
public static function compileCustomCode(eInfo:ElementInfo, customCode:String,
	delim:String="\n", matchIP=0):int
{
	// Queue up the custom code block
	oop.setOOPType(loadedOOPType);
	var codeLines:Array = customCode.split(delim);

	// Create new code block, copying type's code as a basis
	var myCodeBlock:Array = interp.codeBlocks[eInfo.CODEID].concat();

	// Compile code lines
	oop.lastAssignedName = "";
	oop.virtualIP = 0;
	oop.zeroTypeLabelAction = 0;
	var runningIP:int = 0;
	for (var i:int = 0; i < codeLines.length; i++) {
		var line:String = codeLines[i];

		// Capture offset into original text for comment and label.
		oop.lineStartIP = runningIP;

		// See if original text-based IP matches start of line.
		oop.checkMiddleOffset = -1;
		if (matchIP > 0 && oop.virtualIP == 0)
		{
			if (matchIP == runningIP || matchIP == runningIP - 1)
			{
				// Exact match to start of line.
				oop.virtualIP = myCodeBlock.length;
				matchIP = -1;
			}
			else if (matchIP - runningIP < line.length + 1)
			{
				// Match in middle of line, probably for a direction.
				oop.checkMiddleOffset = matchIP - runningIP;
			}
		}
		runningIP += line.length + 1;

		// Strip trailing CR, if present
		if (line.charCodeAt(line.length-1) == 13)
		{
			line = line.substr(0, line.length-1);
			codeLines[i] = line;
		}

		// If line continuation code present, concatenate the next line.
		if (line.length > 0 && loadedOOPType == -3)
		{
			if (line.charAt(line.length-1) == '\\')
			{
				codeLines[i+1] = line.substr(0, line.length-1) + codeLines[i+1];
				codeLines[i] = "'";
				continue;
			}
		}

		var resultArr:Array = oop.parseLine(myCodeBlock, codeLines[i]);
		if (resultArr == null)
		{
			Toast(oop.errorText);
			return -1;
		}
	}

	// Add to code blocks
	var myCodeId:int = interp.codeBlocks.length;
	interp.codeBlocks.push(myCodeBlock);

	// Return new code ID, which will be used in status element
	return myCodeId;
}

// Execute a one-line command within a unique type and code base
public static function oneLineExecCommand(line:String):void {
	// Create a quasi-unique temporary type
	var eInfo:ElementInfo = new ElementInfo("###TEMP###");
	eInfo.CYCLE = 1;
	typeList.push(eInfo);
	oop.setOOPType();

	var resultArr:Array = null;
	var myCodeBlock:Array = new Array(0);
	try {
		// Compile a one-line program statement
		resultArr = oop.parseLine(myCodeBlock, line);
		if (resultArr == null)
			Toast(oop.errorText);
	}
	catch (e:Error) {
		Toast("ERROR:  " + e);
	}

	if (resultArr != null)
	{
		// Add temporary code block
		oop.parseLine(myCodeBlock, "#END");
		eInfo.CODEID = interp.codeBlocks.length;
		interp.codeBlocks.push(myCodeBlock);

		// Dispatch message
		var tempSE:SE = new SE(typeList.length - 1, 0, 0, 0, true);
		try {
			interp.briefDispatch(0, interp.thisSE, tempSE);
		}
		catch (e:Error) {
			Toast("ERROR:  " + e);
		}

		// Remove temporary code block
		interp.codeBlocks.pop();
	}

	// Remove temporary type
	typeList.pop();
	oop.setOOPType(loadedOOPType);
}

// Reset GUIs back to original states.
public static function resetGuis():void {
	for (var k:String in origGuiStorage) {
		guiStorage[k] = origGuiStorage[k];
	}
}

// Establish a GUI by name as the current GUI.
public static function establishGui(guiName:String):Boolean
{
	// Fetch GUI by specific name
	if (!guiStorage.hasOwnProperty(guiName))
		return false;
	thisGui = guiStorage[guiName];

	// Cancel click-to-move
	input.c2MDestX = -1;
	input.c2MDestY = -1;

	// Get top-level GUI variables
	Use40Column = int(utils.ciLookup(thisGui, "Use40Column"));
	OverallSizeX = int(utils.ciLookup(thisGui, "OverallSizeX"));
	OverallSizeY = int(utils.ciLookup(thisGui, "OverallSizeY"));
	GuiLocX = int(utils.ciLookup(thisGui, "GuiLocX"));
	GuiLocY = int(utils.ciLookup(thisGui, "GuiLocY"));
	GuiWidth = int(utils.ciLookup(thisGui, "GuiWidth"));
	GuiHeight = int(utils.ciLookup(thisGui, "GuiHeight"));
	Viewport = utils.ciLookup(thisGui, "Viewport") as Array;
	SE.vpX0 = Viewport[0];
	SE.vpY0 = Viewport[1];
	SE.vpWidth = Viewport[2];
	SE.vpHeight = Viewport[3];
	SE.vpX1 = Viewport[0] + Viewport[2] - 1;
	SE.vpY1 = Viewport[1] + Viewport[3] - 1;
	if (Use40Column)
	{
		cellXDiv = 16;
		aspectMultiplier = 1;
	}
	else
	{
		cellXDiv = 8;
		aspectMultiplier = 2;
	}

	// Get text, color, key inputs, and label info
	GuiText = utils.ciLookup(thisGui, "Text") as String;
	GuiColor = utils.ciLookup(thisGui, "Color") as Array;
	GuiKeys = utils.ciLookup(thisGui, "KeyInput");
	GuiLabels = utils.ciLookup(thisGui, "Label");

	// If toast labels customized, read them here
	if (GuiLabels.hasOwnProperty("TOAST1"))
	{
		toastMsgSize = 1;
		toastMsgCont[0] = [GuiLabels["TOAST1"][0], GuiLabels["TOAST1"][1],
			GuiLabels["TOAST1"][2], GuiLabels["TOAST1"][3]];
		toastMsgCont[0][0] += GuiLocX - 1;
		toastMsgCont[0][1] += GuiLocY - 1;
		if (GuiLabels.hasOwnProperty("TOAST2"))
		{
			toastMsgSize = 2;
			toastMsgCont[1] = [GuiLabels["TOAST2"][0], GuiLabels["TOAST2"][1],
				GuiLabels["TOAST2"][2], GuiLabels["TOAST2"][3]];
			toastMsgCont[1][0] += GuiLocX - 1;
			toastMsgCont[1][1] += GuiLocY - 1;
		}
	}

	// If a palette is provided for the GUI, activate it here
	if (utils.ciTest(thisGui, "PALETTE"))
	{
		var palSeq:Array = utils.ciLookup(thisGui, "PALETTE") as Array;
		palSeq = interp.getFlatSequence(palSeq);
		mg.setPaletteColors(0, 16, 255, palSeq);
	}

	// If scroll interface box customized, read settings here
	if (utils.ciTest(thisGui, "SCROLL"))
	{
		var scr:Object = utils.ciLookup(thisGui, "SCROLL");
		scrollCenterX = int((scr[0] + GuiLocX) * ASCII_Characters.CHAR_WIDTH);
		scrollCenterY = int((scr[1] + GuiLocY) * ASCII_Characters.CHAR_HEIGHT);
		msgScrollWidth = int(scr[2]);
		msgScrollHeight = int(scr[3]);
		scroll40Column = int(scr[4]);
		if (scroll40Column == 1)
			scrollCenterX *= 2;
	}
	else
	{
		scrollCenterX = 240;
		scrollCenterY = 200;
		msgScrollWidth = 42;
		msgScrollHeight = 15;
		scroll40Column = 0;
	}

	// Text and colors must be reformatted to allow for easy
	// transfers to destination
	GuiTextLines = [];
	var iCursor:int = 0;
	var jCursor:int = 0;
	do {
		// Line must be bounded by a line break, and it must
		// equal or exceed the GUI width spec.
		jCursor = GuiText.indexOf("\n", iCursor);
		if (jCursor != -1)
		{
			if (jCursor - iCursor >= GuiWidth)
				GuiTextLines.push(GuiText.substring(iCursor, iCursor + GuiWidth));

			iCursor = ++jCursor;
		}
	} while (jCursor != -1);

	GuiColorLines = [];
	var thisList:Array = new Array();
	for (var i:int = 0; i < GuiColor.length; i += 2)
	{
		var attr:int = GuiColor[i];
		var runLen:int = GuiColor[i+1];
		while (runLen--)
			thisList.push(attr);

		if (thisList.length >= GuiWidth)
		{
			GuiColorLines.push(thisList);
			thisList = new Array();
		}
	}

	// Key mapping is stored as a look-up table, not a dictionary
	for (var n:int = 0; n < 256; n++)
	{
		GuiKeyMapping[n] = "";
		GuiKeyMappingShift[n] = "";
		GuiKeyMappingCtrl[n] = "";
		GuiKeyMappingShiftCtrl[n] = "";
	}
	for (var s:String in GuiKeys)
	{
		var origKey:String = s;
		var sReq:Boolean = false;
		var cReq:Boolean = false;
		if (utils.startswith(s, "SHIFT+"))
		{
			sReq = true;
			s = s.substr(6);
		}
		if (utils.startswith(s, "CTRL+"))
		{
			cReq = true;
			s = s.substr(5);
		}

		var val:int;
		if (s.charCodeAt(0) >= 48 && s.charCodeAt(0) <= 57)
			val = int(s); // Code-based input
		else
			val = s.charCodeAt(0); // Character-based input
		//trace (s, val);

		if (sReq && cReq)
			GuiKeyMappingShiftCtrl[val] = GuiKeys[origKey];
		else if (sReq)
			GuiKeyMappingShift[val] = GuiKeys[origKey];
		else if (cReq)
			GuiKeyMappingCtrl[val] = GuiKeys[origKey];
		else
			GuiKeyMapping[val] = GuiKeys[origKey];
	}

	// Mouse button mapping is stored as a dictionary
	curHighlightButton = "";
	GuiMouseEvents = new Object();
	if (utils.ciTest(thisGui, "MouseInput"))
	{
		var mInput:Object = utils.ciLookup(thisGui, "MouseInput");
		for (s in mInput)
		{
			GuiMouseEvents[s] = mInput[s];
		}
	}

	// Change double-width spec if needed
	if (mg.doubleWidth && Use40Column == 0)
		mg.setDoubled(false);
	else if (!mg.doubleWidth && Use40Column == 1)
		mg.setDoubled(true);

	// Account for scanline mode
	if (utils.ciTest(thisGui, "SCANLINES"))
	{
		globalProps["SCANLINES"] = int(utils.ciLookup(thisGui, "SCANLINES"));
		mg.updateScanlineMode(globalProps["SCANLINES"]);
		cellYDiv = 16;
	}

	/* (Character-set definitions within GUI are rather unwieldy; re-think this later)
	
	// Account for character set selection height (used with CHARSELECT)
	// Default is the same height assumed for the scanline mode
	var charSelHeight:int = mg.charHeight;
	if (thisGui.hasOwnProperty("CHARSELECTHEIGHT"))
		charSelHeight = int(thisGui["CHARSELECTHEIGHT"]);

	// Account for character set selection
	if (thisGui.hasOwnProperty("CHARSELECT"))
	{
		var csa:Array = interp.getFlatSequence(thisGui["CHARSELECT"], false);
		var deducedCharCount:int = int(csa.length / (mg.charWidth * charSelHeight));
		mg.updateCharacterSet(mg.charWidth, charSelHeight, 1, deducedCharCount, 0, csa);
		cellYDiv = mg.virtualCellYDiv;
	}*/

	// Account for bit-7 meaning
	if (utils.ciTest(thisGui, "BIT7ATTR"))
		globalProps["BIT7ATTR"] = int(utils.ciLookup(thisGui, "BIT7ATTR"));
	mg.updateBit7Meaning(globalProps["BIT7ATTR"]);

	// Set up grid surface abstractions
	mg.createSurfaces(OverallSizeX, OverallSizeY, Viewport, true);

	SE.uCameraX = -1000;
	SE.uCameraY = -1000;

	thisGuiName = guiName;
	globalProps["THISGUI"] = guiName;
	return true;
}

// Pop the current GUI off the stack; restore previous GUI
public static function popGui():void
{
	// Only works if stack is not at bottom
	if (guiStack.length > 1)
	{
		thisGuiName = guiStack[guiStack.length - 2];
		if (establishGui(thisGuiName))
		{
			guiStack.pop();
			mainMode = MODE_NORM;
			drawGui();
			dispatchInputMessage("EVENT_REDRAW");
		}
	}
}

// Draw the GUI background
public static function drawGui():Boolean
{
	mg.writeBlock(GuiLocX-1, GuiLocY-1, GuiTextLines, GuiColorLines);
	curHighlightButton = "";

	if (thisGuiName == "DEBUGMENU")
	{
		drawGuiLabel("CUSTOMTEXT", featuredWorldName);
		drawGuiLabel("VERSIONTEXT", globalProps["VERSION"].toString());
		drawGuiLabel("BUILDTEXT", "AS3 Build");
		drawGuiLabel("SPECIALTEXT", "Prototype");
		//drawGuiLabel("SPECIALTEXT", "NG Special");
		Sounds.distributePlayNotes("U137");
	}

	return true;
}

// Draw a GUI label
public static function drawGuiLabel(labelStr:String, str:String, attr:int=-1):Boolean
{
	if (GuiLabels.hasOwnProperty(labelStr))
	{
		// Extract label info
		var guiLabelInfo:Array = GuiLabels[labelStr];
		var gx:int = int(guiLabelInfo[0]);
		var gy:int = int(guiLabelInfo[1]);
		var maxLen:int = int(guiLabelInfo[2]);
		var defAttr:int = int(guiLabelInfo[3]);

		// Write text to label location
		gx += GuiLocX-1;
		gy += GuiLocY-1;
		if (str.length > maxLen)
			str = str.substr(0, maxLen); // Clip
		if (guiLabelInfo.length >= 5)
		{
			if (int(guiLabelInfo[4]) != 0)
				gx += maxLen - str.length; // Right-justify
		}
		if (attr == -1)
			attr = defAttr; // Default color

		// Draw
		mg.writeStr(gx-1, gy-1, str, attr);
		return true;
	}

	return false;
}

// Erase a GUI label, showing the background where the label was
public static function eraseGuiLabel(labelStr:String, attr:int=-1):Boolean
{
	if (GuiLabels.hasOwnProperty(labelStr))
	{
		// Extract label info
		var guiLabelInfo:Array = GuiLabels[labelStr];
		var gx:int = int(guiLabelInfo[0]);
		var gy:int = int(guiLabelInfo[1]);
		var maxLen:int = int(guiLabelInfo[2]);
		var defAttr:int = int(guiLabelInfo[3]);

		// Erase at label location
		gx += GuiLocX-1;
		gy += GuiLocY-1;
		while (maxLen-- > 0)
			displayGuiSquare(gx++, gy);
		return true;
	}

	return false;
}

// Display the appropriate GUI square at the absolute location.
public static function displayGuiSquare(x:int, y:int):void {
	if (x >= SE.vpX0 && y >= SE.vpY0 && x <= SE.vpX1 && y <= SE.vpY1)
	{
		// Falls within viewport; write square using SE.
		x -= SE.vpX0 - SE.CameraX;
		y -= SE.vpY0 - SE.CameraY;
		SE.displaySquare(x, y);
	}
	else if (x >= GuiLocX && y >= GuiLocY &&
		x < GuiLocX + GuiWidth && y < GuiLocY + GuiHeight)
	{
		// Ordinary GUI square.  Write GUI character.
		x -= GuiLocX;
		y -= GuiLocY;
		mg.setCell(x+GuiLocX-1, y+GuiLocY-1,
			int(GuiTextLines[y].charCodeAt(x)), int(GuiColorLines[y][x]));
	}

	// If coordinates fall outside of viewport, we can't display anything.
}

// When user moves mouse near viewport edge, indicate that click would change board
public static function showEdgeNavArrow(x:int, y:int, dir:int):void {
	lastEdgeNavArrowX = x;
	lastEdgeNavArrowY = y;
	x += -SE.CameraX + SE.vpX0 - 1;
	y += -SE.CameraY + SE.vpY0 - 1;
	mg.setCell(x, y, edgeNavArrowChars[dir], 128 + 31);
}

// Draw a pen pointer
public static function drawPen(labelStr:String,
	startVal:int, endVal:int, actVal:int, chrCode:int, attr:int):Boolean
{
	if (GuiLabels.hasOwnProperty(labelStr) && startVal != endVal)
	{
		// Extract label info
		var guiLabelInfo:Array = GuiLabels[labelStr];
		var gx:int = int(guiLabelInfo[0]);
		var gy:int = int(guiLabelInfo[1]);
		var maxLen:int = int(guiLabelInfo[2]);
		var defAttr:int = int(guiLabelInfo[3]);

		// Erase at label location
		gx += GuiLocX-1;
		gy += GuiLocY-1;
		if (attr == -1)
			attr = defAttr; // Default color
		mg.writeConst(gx-1, gy-1, maxLen, 1, " ", defAttr);

		// Find pen render disposition
		var frac:int;
		if (startVal < endVal)
			frac = int((actVal - startVal) * maxLen / (endVal - startVal + 1));
		else
			frac = int((actVal - endVal) * maxLen / (startVal - endVal+ 1));
		if (frac < 0)
			frac = 0;
		else if (frac >= maxLen)
			frac = maxLen - 1;

		// Draw pen
		if (startVal < endVal)
			gx += frac; // Increases left to right
		else
			gx += maxLen - 1 - frac; // Increases right to left
		mg.setCell(gx-1, gy-1, chrCode, attr);
		return true;
	}

	return false;
}

// Initialize pen-selection interface
public static function selectPen(labelStr:String,
	startVal:int, endVal:int, actVal:int, chrCode:int, attr:int, doneMsg:String):Boolean
{
	// Draw initial pen
	if (drawPen(labelStr, startVal, endVal, actVal, chrCode, attr))
	{
		// Go into pen selection mode
		confLabelStr = labelStr;
		confYesMsg = doneMsg;
		penStartVal = startVal;
		penEndVal = endVal;
		penActVal = actVal;
		penChrCode = chrCode;
		penAttr = attr;
		mainMode = MODE_SELECTPEN;
		return true;
	}

	return false;
}

// Draw a bar (a meter)
public static function drawBar(labelStr:String,
	startVal:int, endVal:int, actVal:int, attr:int):Boolean
{
	if (GuiLabels.hasOwnProperty(labelStr) && startVal != endVal)
	{
		// Extract label info
		var guiLabelInfo:Array = GuiLabels[labelStr];
		var gx:int = int(guiLabelInfo[0]);
		var gy:int = int(guiLabelInfo[1]);
		var maxLen:int = int(guiLabelInfo[2]);
		var defAttr:int = int(guiLabelInfo[3]);

		// Erase at label location
		gx += GuiLocX-1;
		gy += GuiLocY-1;
		if (attr == -1)
			attr = defAttr; // Default color
		mg.writeConst(gx-1, gy-1, maxLen, 1, " ", defAttr);

		// Find bar render disposition
		var fracFloat:Number;
		if (startVal < endVal)
			fracFloat = Number((actVal - startVal) * maxLen * 2) / Number(endVal - startVal);
		else
			fracFloat = Number((actVal - endVal) * maxLen * 2) / Number(startVal - endVal);

		var frac:int = int(fracFloat + 0.5);
		if (frac < 0)
			frac = 0;
		else if (frac > maxLen * 2)
			frac = maxLen * 2;

		// Draw bar
		if (startVal < endVal)
		{
			// Grows rightwards
			while (frac >= 2)
			{
				// Set "full" cell
				mg.setCell(gx-1, gy-1, 219, attr);
				gx++;
				frac -= 2;
			}

			// Set "half" cell if applicable
			if (frac == 1)
				mg.setCell(gx-1, gy-1, 221, attr);
		}
		else
		{
			// Grows leftwards
			gx += maxLen - 1;
			while (frac >= 2)
			{
				// Set "full" cell
				mg.setCell(gx-1, gy-1, 219, attr);
				gx--;
				frac -= 2;
			}

			// Set "half" cell if applicable
			if (frac == 1)
				mg.setCell(gx-1, gy-1, 222, attr);
		}

		return true;
	}

	return false;
}

// Place confirmation Yes/No message and go to confirmation message mode
public static function confMessage(labelStr:String, str:String, yesMsg:String, noMsg:String,
	cancelMsg:String=""):Boolean
{
	confLabelStr = labelStr;
	confYesMsg = yesMsg;
	confNoMsg = noMsg;
	confCancelMsg = cancelMsg;
	drawGuiLabel(labelStr, str);
	mainMode = MODE_CONFMESSAGE;

	var guiLabelInfo:Array = GuiLabels[labelStr];
	var gx:int = int(guiLabelInfo[0]);
	var gy:int = int(guiLabelInfo[1]);
	var maxLen:int = int(guiLabelInfo[2]);
	if (gy + GuiLocY - 2 >= 24)
	{
		// Align buttons to right
		confButtonX = gx + str.length + 1;
		confButtonY = gy;
	}
	else
	{
		// Align buttons below
		confButtonX = gx + 3;
		confButtonY = gy + 1;
	}

	confButtonSel = 0;
	confButtonUnderText.length = 0;
	confButtonUnderColors.length = 0;
	drawConfButtons();

	return true;
}

// Draw confirmation Yes/No buttons
public static function drawConfButtons():void {
	// If no under-text established, remember it now.
	if (confButtonUnderText.length == 0)
	{
		confButtonUnderBG = mg.getAttr(GuiLocX + confButtonX - 2, GuiLocY + confButtonY - 2);
		confButtonUnderBG = confButtonUnderBG & (7 << 3);

		for (var i:int = 0; i < 10; i++)
		{
			confButtonUnderText.push(
				mg.getChar(GuiLocX + confButtonX + i - 2, GuiLocY + confButtonY - 2));
			confButtonUnderColors.push(
				mg.getAttr(GuiLocX + confButtonX + i - 2, GuiLocY + confButtonY - 2));
		}
	}

	// Draw "Yes" button
	var color:int = (confButtonSel == 0) ?
		confButtonColorSelYes : (confButtonUnderBG | confButtonColorYes);
	mg.writeStr(GuiLocX + confButtonX - 2, GuiLocY + confButtonY - 2, confButtonTextYes, color);

	// Draw "No" button
	color = (confButtonSel == 1) ?
		confButtonColorSelNo : (confButtonUnderBG | confButtonColorNo);
	mg.writeStr(GuiLocX + confButtonX + 6 - 2, GuiLocY + confButtonY - 2, confButtonTextNo, color);
}

// Restore GUI under Yes/No buttons
public static function unDrawConfButtons():void {
	// Replace original text under confirmation buttons.
	for (var i:int = 0; i < confButtonUnderText.length; i++)
	{
		mg.setCell(GuiLocX + confButtonX + i - 2, GuiLocY + confButtonY - 2,
			confButtonUnderText[i], confButtonUnderColors[i]);
	}
}

// Initialize text-entry box
public static function textEntry(labelStr:String,
	str:String, maxCharCount:int, color:int, yesMsg:String, noMsg:String):Boolean {
	confLabelStr = labelStr;
	confYesMsg = yesMsg;
	confNoMsg = noMsg;
	textMaxCharCount = maxCharCount;
	textChars = str;
	textCharsColor = color;
	for (var i:int = textChars.length; i < textMaxCharCount; i++)
		str += " ";
	drawGuiLabel(labelStr, str, color);
	mainMode = MODE_TEXTENTRY;
	return true;
}

// Game speed control.
public static function setGameSpeed(newSpeed:int):void {
	if (gameSpeed != newSpeed)
	{
		gameSpeed = int(utils.clipval(newSpeed, 0, 8));
		if (gameSpeed == 0)
		{
			var newTick:Number = utils.clipval(globalProps["FASTESTFPS"], 1.0, 10000.0);
			speedInits[0] = 30.0 / newTick;
		}

		gTickInit = speedInits[gameSpeed];
		gTickCurrent = gTickInit;
	}
}

// Mask setting.
public static function addMask(str:String, maskArray:Array):void {
	// Get size.
	var ySize:int = maskArray.length;
	var xSize:int = maskArray[0].length;

	// Replace each string with an array.  This is more easily looked up.
	var newCont:Array = new Array(ySize);
	for (var y:int = 0; y < ySize; y++)
	{
		var newArr:Array = new Array(xSize);
		for (var x:int = 0; x < xSize; x++)
		{
			// Number characters are converted to actual numbers.
			if (maskArray[y] is String)
				newArr[x] = int(maskArray[y].charCodeAt(x)) - 48;
			else
				newArr[x] = int(maskArray[y][x]);
		}

		newCont[y] = newArr;
	}

	// Set mask dictionary.
	masks[str] = newCont;
}

// Multi-line text is displayed at a GUI label.
public static function textLinesToGui(labelStr:String):void {
	if (GuiLabels.hasOwnProperty(labelStr))
	{
		// Extract label info
		var guiLabelInfo:Array = GuiLabels[labelStr];
		var gx:int = int(guiLabelInfo[0]);
		var gy:int = int(guiLabelInfo[1]);
		var maxLen:int = int(guiLabelInfo[2]);
		var defAttr:int = int(guiLabelInfo[3]);

		// Write lines to label location
		gx += GuiLocX - 2;
		gy += GuiLocY - 2;

		for (var i:int = 0; i < numTextLines; i++) {
			var str:String = msgScrollText[i];
			if (str.length > maxLen)
				str = str.substr(0, maxLen); // Clip

			mg.writeStr(gx, gy, str, defAttr);
			gy++;
		}
	}
}

// Multi-line text is written to a region on the grid as a text type.
public static function textLinesToRegion(regionName:String, textType:int):void {
	var region:Array = interp.getRegion(regionName);

	// Establish region bounds
	var x0:int = 0;
	var y0:int = 0;
	var xf:int = -1;
	var yf:int = -1;
	if (interp.validCoords(region[0]) && interp.validCoords(region[1]))
	{
		x0 = region[0][0];
		y0 = region[0][1];
		xf = region[1][0];
		yf = region[1][1];
	}

	var i:int = 0;
	for (var y:int = y0; y <= yf; y++, i++) {
		if (i >= numTextLines)
			break; // Done with lines

		var str:String = msgScrollText[i];

		var j:int = 0;
		for (var x:int = x0; x <= xf; x++, j++) {
			if (j >= str.length)
				break; // End of line

			// Get character
			var c:int = str.charCodeAt(j);

			// Kill destination
			var relSE:SE = SE.getStatElemAt(x, y);
			if (relSE)
				interp.killSE(x, y);

			// Update grid cell
			SE.setType(x, y, textType);
			SE.setColor(x, y, c, false);
			SE.displaySquare(x, y);
		}
	}
}

// "Internal" toast message box.
public static function Toast(textmsg:String, timeOpen:Number = 2.5):void
{
	var mytext:TextField =
		getSuperChildByName(toastObj, "toasttext") as TextField;
	mytext.text = textmsg;
	toastObj.alpha = 1.0;
	toastObj.visible = true;
	toastTime = int(30 * timeOpen);
}

// "Game" flashing toast message box.
public static function ToastMsg(timeOpen:Number = 0.0):void
{
	if (numTextLines <= 0)
		return; // Nothing to display

	toastMsgText[0] = "";
	toastMsgText[1] = "";

	// Line 1
	if (msgScrollFormats[0] == "$")
		toastMsgText[0] = " $" + msgScrollText[0] + " ";
	else if (msgScrollText[0].length == 0)
		toastMsgText[0] = "";
	else
		toastMsgText[0] = " " + msgScrollText[0] + " ";

	// Line 2
	if (numTextLines > 1)
	{
		if (msgScrollFormats[1] == "$")
			toastMsgText[1] = " $" + msgScrollText[1] + " ";
		else if (msgScrollText[1].length == 0)
			toastMsgText[1] = "";
		else
			toastMsgText[1] = " " + msgScrollText[1] + " ";
	}

	// If no time open is set, use a sliding scale from 1.25 to 4.0
	// seconds with overall length serving as the basis for time.
	if (timeOpen == 0.0)
	{
		// Zero char min:  1.25 seconds.  60-char max:  4.0 seconds.
		timeOpen = Number(toastMsgText[0].length) / 60.0 * 2.75 + 1.25;
	}

	toastMsgTimeLeft = int(30 * timeOpen);
	toastMsgColor = 9;
	undisplayToastMsg();
	displayToastMsg();
}

// "Erase" flashing toast message box.
public static function undisplayToastMsg():void {
	for (var i:int = 0; i < toastMsgSize; i++)
	{
		var x:int = toastMsgCont[i][0];
		var y:int = toastMsgCont[i][1];
		var l:int = toastMsgCont[i][2];
		for (var j:int = 0; j < l; j++)
			displayGuiSquare(x + j, y);
	}
}

// Show flashing toast message box.
public static function displayToastMsg():void {
	for (var i:int = 0; i < toastMsgSize; i++)
	{
		var x:int = toastMsgCont[i][0];
		var y:int = toastMsgCont[i][1];
		var l:int = toastMsgCont[i][2];
		var bgColor:int = toastMsgCont[i][3] & 0xF0;

		// If line of text will not fit into length, clip it.
		if (toastMsgText[i].length > l)
			toastMsgText[i] = toastMsgText[i].substr(0, l);

		// Center message and display.
		x += int(l / 2);
		if (toastMsgText[i].length & 1)
			x -= int(toastMsgText[i].length / 2);
		else
			x -= int((toastMsgText[i].length - 1) / 2);
		mg.writeStr(x-1, y-1, toastMsgText[i], toastMsgColor | bgColor);
	}
}

// Add to message formatting list.
public static function addMsgLine(fmt:String, txt:String):void {
	if (txt.length > 0)
		msgNonBlank = true;
	msgScrollFormats.push(fmt);
	msgScrollText.push(txt);
	numTextLines++;

	if (numTextLines > toastMsgSize && interp.textTarget == interp.TEXT_TARGET_NORM)
		globals["$SCROLLMSG"] = 1;
}

// Scroll interface button selection handler
public static function scrollInterfaceButton():void {
	// Done or link follow
	var fmt:String = msgScrollFormats[msgScrollIndex + mouseScrollOffset];
	if (inEditor)
	{
		// Editor has many different types of scroll interfaces;
		// delegate the responsibility to editor section.
		editor.scrollInterfaceButton(fmt);
	}
	else if (fmt == "$" || fmt == "")
	{
		// Not scroll button; just close scroll
		mainMode = MODE_SCROLLCLOSE; // Done
	}
	else if (msgScrollFiles)
	{
		// File browser selection
		globals["$SCROLLMSG"] = 0;
		titleGrid.visible = false;
		scrollGrid.visible = false;
		scrollArea.visible = false;

		// Extension determines what we will try to display
		var n:int = int(fmt);
		var fStr:String = "";
		if (fileSystemType == FST_ZIP)
		{
			// ZIP archive file
			fStr = parse.zipData.fileNames[n];
			parse.fileData = parse.zipData.getFileByName(fStr);
			if (utils.endswith(fStr, ".ZZT"))
			{
				parse.loadingSuccess = true;
				mainMode = MODE_LOADZZT;
			}
			else if (utils.endswith(fStr, ".SZT"))
			{
				parse.loadingSuccess = true;
				mainMode = MODE_LOADSZT;
			}
			else if (utils.endswith(fStr, ".WAD"))
			{
				parse.loadingSuccess = true;
				mainMode = MODE_LOADWAD;
			}
			else if (utils.endswith(fStr, ".HLP"))
			{
				// File link display
				modeWhenBrowserClosed = MTRANS_ZIPSCROLL;
				displayFileLink(fStr);
			}
			else
			{
				// Full-page file browser
				modeWhenBrowserClosed = MTRANS_ZIPSCROLL;
				displayFileBrowser(fStr);
			}
		}
		else if (n < 0)
		{
			modeChanged = true;
			mainMode = MODE_LOADSAVEWAIT;
			modeWhenBrowserClosed = MTRANS_NORM;
			highScoreServer = false;
			switch (n) {
				case -1:
					parse.loadLocalFile("ZZT", MODE_NATIVELOADZZT, MODE_NORM);
				break;
				case -2:
					parse.loadLocalFile("SZT", MODE_NATIVELOADSZT, MODE_NORM);
				break;
				case -3:
					parse.loadLocalFile("WAD", MODE_LOADWAD, MODE_NORM);
				break;
				case -4:
					parse.loadLocalFile("ZIP", MODE_LOADZIP, MODE_NORM);
				break;
			}
		}
		else
		{
			// Deployed file in configuration
			modeWhenBrowserClosed = MTRANS_NORM;
			launchDeployedFile(allDeployedPaths[n]);
		}
	}
	else if (msgScrollIsRestore)
	{
		// Restoration
		globals["$SCROLLMSG"] = 0;
		titleGrid.visible = false;
		scrollGrid.visible = false;
		scrollArea.visible = false;

		if (fmt == "0")
		{
			// World restore
			modeChanged = true;
			mainMode = MODE_LOADSAVEWAIT;
			highScoreServer = false;
			parse.loadLocalFile("SAV", MODE_RESTOREWADFILE, MODE_NORM);
		}
		else
		{
			// Snapshot restore
			n = int(fmt);
			for (var i:int = ZZTLoader.saveStates.length - 1; i >= 0; i--) {
				// Get genuine, deliberate save states (not bases or incidentals).
				var sState:ZZTBoard = ZZTLoader.saveStates[i];
				if (sState.saveType >= 0)
				{
					if (n <= 1)
					{
						ZZTLoader.restoreToState(i);
						interp.dispatchToMainLabel("$ONRESTORESTATE");
						dissolveViewport(MODE_NORM, 0.5, -1);
						trace(globalProps["BOARD"], globals["$PLAYERPAUSED"], globals["$PLAYERMODE"],
							globalProps["THISGUI"]);
						return;
					}
					n--;
				}
			}

			mainMode = MODE_NORM;
		}
	}
	else if (fmt.substr(0, 1) == "!")
	{
		// File link display
		globals["$SCROLLMSG"] = 0;
		titleGrid.visible = false;
		scrollGrid.visible = false;
		scrollArea.visible = false;
		fmt = fmt.substr(1);
		if (fmt.indexOf(".") == -1)
			fmt = fmt + ".HLP";
		displayFileLink(fmt);
	}
	else
	{
		// Link follow
		interp.linkFollow(fmt);
		if (mainMode == MODE_SCROLLOPEN)
			mainMode = MODE_SCROLLCHAIN;
		else
			mainMode = MODE_SCROLLCLOSE;
	}
}

// "Scroll" large text box.
public static function ScrollMsg(objName:String=""):void {
	msgScrollObjName = objName;
	msgScrollIndex = 0;
	mouseScrollOffset = 0;

	// Erase previous scroll interface text.
	titleGrid.silentErase(32, sTextColor);
	scrollGrid.silentErase(32, sArrowColor);

	// Set up scroll frame type per configuration.
	if (globalProps["OVERLAYSCROLL"])
		setScrollBitmapColors(0);
	else
		setScrollBitmapColors(1);

	// Set new "final" dimensions and initial scroll message text.
	curScrollCols = msgScrollWidth;
	curScrollRows = msgScrollHeight;
	setScrollMsgDims(curScrollCols, curScrollRows);
	drawScrollMsgText();

	// If we will "scroll" open, start the dimensions small.
	if (globalProps["IMMEDIATESCROLL"] == 0 && !inEditor)
	{
		if (globalProps["ORIGINALSCROLL"] != 0)
		{
			curScrollRows = 1;
		}
		else
		{
			curScrollCols = 1;
			curScrollRows = 1;
		}
		setScrollMsgDims(curScrollCols, curScrollRows);
	}

	// Set "open" mode.
	mainMode = MODE_SCROLLOPEN;
	modeChanged = true;
}

// Get scroll component geometry (position and size).
public static function getScrollGeom(sa:DisplayObjectContainer, name:String, idx:int):void {
	var d:DisplayObject = getSuperChildByName(sa, name);
	scrollGeom.push([idx, d.x, d.y, d.width, d.height]);
}

// Set scroll object corner mapping geometry.
public static function setScrollCornerMapping(sa:DisplayObjectContainer):void {
	// Get geometry of each piece in frame.
	getScrollGeom(sa, "ul", 0);
	getScrollGeom(sa, "ur", 1);
	getScrollGeom(sa, "dl", 2);
	getScrollGeom(sa, "dr", 3);
	getScrollGeom(sa, "u1", 4);
	getScrollGeom(sa, "u2", 5);
	getScrollGeom(sa, "d1", 6);
	getScrollGeom(sa, "l1", 7);
	getScrollGeom(sa, "r1", 8);

	// Create bitmap substitutions.
	createScrollSubs(0, [ BMScrollUL, BMScrollUR, BMScrollDL, BMScrollDR,
		BMScrollU1, BMScrollU2, BMScrollD1, BMScrollL1, BMScrollR1 ]);
	createScrollSubs(1, [ BMScrollUL_S, BMScrollUR_S, BMScrollDL_S, BMScrollDR_S,
		BMScrollU1_S, BMScrollU2_S, BMScrollD1_S, BMScrollL1_S, BMScrollR1_S ]);
}

// Create bitmap substitutions for a specific set of scroll bitmap classes.
public static function createScrollSubs(idx:int, classArray:Array):void {
	var bmpArray:Array = scrollBitmaps[idx];

	for (var n:int = 0; n < classArray.length; n++) {

		// Establish source and destination bitmaps.
		var srcBmd:BitmapData = new (classArray[n])(scrollGeom[n][3], scrollGeom[n][4]);
		var bmd:BitmapData = new BitmapData(scrollGeom[n][3], scrollGeom[n][4]);

		// Create palette-mapped bitmap data from source bitmap.
		for (var y:int = 0; y < srcBmd.height; y++) {
			for (var x:int = 0; x < srcBmd.width; x++) {
				var pVal:uint = srcBmd.getPixel32(x, y);
				switch (pVal) {
					case 0xFFFFFFFF: // Border
						bmd.setPixel32(x, y, 0xFFFFFFFF);
					break;
					case 0xFF000000: // Shadow
						bmd.setPixel32(x, y, 0xFF808080);
					break;
					case 0xFF0000AA: // BG
						bmd.setPixel32(x, y, 0xFFC0C0C0);
					break;
					default: // Transparent
						bmd.setPixel32(x, y, 0x00000000);
					break;
				}
			}
		}

		bmpArray.push(bmd);
	}

	// Only create target scroll area if not already created.
	if (idx != 0)
		return;

	// Create new scroll area.
	scrollArea = new MovieClip();
	for (n = 0; n < bmpArray.length; n++) {
		var bm:Bitmap = new Bitmap(new BitmapData(scrollGeom[n][3], scrollGeom[n][4]));
		scrollArea.addChild(bm);
		bm.x = scrollGeom[n][1];
		bm.y = scrollGeom[n][2];
	}

	scrollUL = scrollArea.getChildAt(0);
	scrollUR = scrollArea.getChildAt(1);
	scrollDL = scrollArea.getChildAt(2);
	scrollDR = scrollArea.getChildAt(3);
	scrollU1 = scrollArea.getChildAt(4);
	scrollU2 = scrollArea.getChildAt(5);
	scrollD1 = scrollArea.getChildAt(6);
	scrollL1 = scrollArea.getChildAt(7);
	scrollR1 = scrollArea.getChildAt(8);
}

// Set bitmaps for a specific scroll container.
public static function setScrollBitmapColors(idx:int):void {
	// Update palette lookup tables.
	sbmRed.length = 256;
	sbmGreen.length = 256;
	sbmBlue.length = 256;
	sbmAlpha.length = 256;
	for (var j:int = 0; j < 256; j++) {
		sbmRed[j] = 0;
		sbmGreen[j] = 0;
		sbmBlue[j] = 0;
		sbmAlpha[j] = 0xFF000000;
	}

	sbmAlpha[0] = 0;
	sbmRed[0xFF] = sBorderColor & 16711680;
	sbmGreen[0xFF] = sBorderColor & 65280;
	sbmBlue[0xFF] = sBorderColor & 255;
	sbmRed[0x80] = sShadowColor & 16711680;
	sbmGreen[0x80] = sShadowColor & 65280;
	sbmBlue[0x80] = sShadowColor & 255;
	sbmRed[0xC0] = sBGColor & 16711680;
	sbmGreen[0xC0] = sBGColor & 65280;
	sbmBlue[0xC0] = sBGColor & 255;

	// Update bitmaps with palette-mapped colors.
	var tPoint:Point = new Point(0, 0);
	for (var i:int = 0; i < 9; i++)
	{
		var bmd:BitmapData = scrollBitmaps[idx][i];
		var destBmd:BitmapData = (scrollArea.getChildAt(i) as Bitmap).bitmapData;
		var sourceRect:Rectangle = new Rectangle(0, 0, bmd.width, bmd.height);

		destBmd.paletteMap(bmd, sourceRect, tPoint,
			sbmRed, sbmGreen, sbmBlue, sbmAlpha);
	}
}

// Set color indexes for scroll interface.
public static function setScrollColors(colBorder:int, colShadow:int, colBG:int,
	colText:int, colCenterText:int, colButton:int, colArrow:int):void {

	// Frame colors
	var idx:int = colBorder * 3;
	sBorderColor = mg.colors16[idx + 0] | mg.colors16[idx + 1] | mg.colors16[idx + 2];
	idx = colShadow * 3;
	sShadowColor = mg.colors16[idx + 0] | mg.colors16[idx + 1] | mg.colors16[idx + 2];
	idx = colBG * 3;
	sBGColor = mg.colors16[idx + 0] | mg.colors16[idx + 1] | mg.colors16[idx + 2];

	// Cell colors
	sTextColor = (colText & 15) + (colBG << 4);
	sCenterTextColor = (colCenterText & 15) + (colBG << 4);
	sButtonColor = (colButton & 15) + (colBG << 4);
	sArrowColor = (colArrow & 15) + (colBG << 4);

	// Update properties
	globalProps["SCRCOLBORDER"] = colBorder;
	globalProps["SCRCOLSHADOW"] = colShadow;
	globalProps["SCRCOLBG"] = colBG;
	globalProps["SCRCOLTEXT"] = colText;
	globalProps["SCRCOLCENTERTEXT"] = colCenterText;
	globalProps["SCRCOLBUTTON"] = colButton;
	globalProps["SCRCOLARROW"] = colArrow;
}

// Set dimensions of "Scroll" large text box.
public static function setScrollMsgDims(cols:int, rows:int):void {
	// Actual number of columns needed includes 2 on each side (for frame),
	// plus 2 leading spaces (arrow and margin), plus 1 trailing space (arrow).
	var actualColsNeeded:int = 2 + 2 + cols + 1 + 2;

	// Actual number of rows needed includes 3-line title+frame, and bottom frame.
	var actualRowsNeeded:int = 3 + rows + 1;

	// Position the corners as needed.
	scrollUR.x = ASCII_Characters.CHAR_WIDTH * (actualColsNeeded - 2);
	scrollDL.y = ASCII_Characters.CHAR_HEIGHT * (actualRowsNeeded - 2);
	scrollDR.x = ASCII_Characters.CHAR_WIDTH * (actualColsNeeded - 2);
	scrollDR.y = ASCII_Characters.CHAR_HEIGHT * (actualRowsNeeded - 2);
	scrollD1.y = ASCII_Characters.CHAR_HEIGHT * (actualRowsNeeded - 1);
	scrollR1.x = ASCII_Characters.CHAR_WIDTH * (actualColsNeeded - 2);

	// Extend the sides as needed.
	scrollU1.scaleX = actualColsNeeded - 4;
	scrollU2.scaleX = actualColsNeeded - 4;
	scrollD1.scaleX = actualColsNeeded - 4;
	scrollL1.scaleY = rows;
	scrollR1.scaleY = rows;

	// From new dimensions of scroll area, center at chosen spot.
	scrollArea.x = scrollCenterX - (scrollArea.width/2);
	scrollArea.y = scrollCenterY - (scrollArea.height/2);

	if (globalProps["OVERLAYSCROLL"] == 0)
	{
		// Overlay scrolls are locked to actual grid cells;
		// they are not perfectly centered.
		scrollArea.x = int(scrollArea.x / 8) * 8;
		scrollArea.y = int(scrollArea.y / 16) * 16;
	}

	// Now set the title grid and scroll grid to the
	// correct locations and dimensions.
	titleGrid.x = scrollArea.x + (ASCII_Characters.CHAR_WIDTH * 2);
	titleGrid.y = scrollArea.y + (ASCII_Characters.CHAR_HEIGHT * 1);
	titleGrid.adjustVisiblePortion(actualColsNeeded - 4, 1);
	scrollGrid.x = scrollArea.x + (ASCII_Characters.CHAR_WIDTH * 2);
	scrollGrid.y = scrollArea.y + (ASCII_Characters.CHAR_HEIGHT * 3);
	scrollGrid.adjustVisiblePortion(actualColsNeeded - 4, rows);

	// Tweak frame for 40-column display
	if (scroll40Column == 1)
		scrollArea.x -= ASCII_Characters.CHAR_WIDTH * 2;
}

// Draw text of "Scroll" large text box with specific cursor position.
public static function drawScrollMsgText():void {
	// Back up "current" index by half the size of the window.
	var backupLen:int = int(msgScrollHeight/2);
	var curIndex:int = msgScrollIndex - backupLen;
	var changeTitle:Boolean = false;

	// Draw each line.
	for (var cy:int = 0; cy < msgScrollHeight; cy++)
	{
		if (curIndex < -1 || curIndex > msgScrollText.length)
		{
			// Out of message boundaries; display blank line.
			scrollGrid.writeConst(2, cy, msgScrollWidth, 1, " ", sTextColor);
		}
		else if (curIndex == -1 || curIndex == msgScrollText.length)
		{
			// On message boundaries; display dotted line.
			for (var cx:int = 0; cx < msgScrollWidth; cx += 5)
			{
				scrollGrid.writeConst(1+cx, cy, msgScrollWidth, 1, " ", sTextColor);
				scrollGrid.setCell(1+cx+4, cy, 7, sTextColor);
			}
		}
		else
		{
			// Within message.  Check if special formatting is present.
			var fmt:String = msgScrollFormats[curIndex];
			var txt:String = msgScrollText[curIndex];
			var lineLen:int = txt.length;
			if (fmt == "")
			{
				// No formatting; display ordinary line.
				scrollGrid.writeStr(2, cy, txt, sTextColor);

				// Erase rest of line
				scrollGrid.writeConst(2+lineLen, cy,
					msgScrollWidth-lineLen+1, 1, " ", sTextColor);
			}
			else if (fmt == "$")
			{
				// Centered text; display white line with leading spaces.
				var leadingSpaces:int = int((msgScrollWidth/2) - (lineLen/2));
				while (leadingSpaces-- > 0)
					txt = " " + txt;
				lineLen = txt.length;

				scrollGrid.writeStr(2, cy, txt, sCenterTextColor);

				// Erase rest of line
				scrollGrid.writeConst(2+lineLen, cy,
					msgScrollWidth-lineLen+1, 1, " ", sCenterTextColor);
			}
			else
			{
				// Link; display link button and line.
				scrollGrid.writeConst(2, cy, 6, 1, " ", sCenterTextColor);
				scrollGrid.setCell(2+2, cy, 16, sButtonColor);
				scrollGrid.writeStr(2+5, cy, txt, sCenterTextColor);

				// Erase rest of line
				scrollGrid.writeConst(2+5+lineLen, cy,
					msgScrollWidth-lineLen-5+1, 1, " ", sCenterTextColor);

				// Signal to change title bar if link at cursor
				if (msgScrollIndex + mouseScrollOffset == curIndex)
					changeTitle = true;
			}
		}

		curIndex++;
	}

	// Draw cursor arrows (always visible).
	scrollGrid.writeConst(0, 0, 1, msgScrollHeight, " ", sArrowColor);
	scrollGrid.setCell(0, backupLen + mouseScrollOffset, 175, sArrowColor);
	scrollGrid.setCell(2+msgScrollWidth, backupLen + mouseScrollOffset, 174, sArrowColor);

	// Set title based on context.
	var titleText:String = "Interaction";
	if (changeTitle) // Link at cursor
		titleText = "<< Press ENTER to select this >>";
	else if (msgScrollObjName != "") // Object name specified
		titleText = msgScrollObjName;

	// Erase title line and redraw.
	titleGrid.writeConst(0, 0, msgScrollWidth + 3, 1, " ", sTextColor);
	cx = int(msgScrollWidth/2 - titleText.length/2);
	titleGrid.writeStr(2+cx, 0, titleText, sTextColor);

	// Draw grid surfaces.
	titleGrid.drawSurfaces();
	scrollGrid.drawSurfaces();
}

// Create scroll interface for world restoration
public static function snapshotRestoreScroll(allowWorldRestore:Boolean):void {
	numTextLines = 0;
	msgScrollFormats = [];
	msgScrollText = [];
	msgScrollIsRestore = true;

	// World restore link
	if (allowWorldRestore)
	{
		addMsgLine("0", "Restore from SAV file");
		addMsgLine("$", "---------------------");
	}

	// Snapshot restore links
	var n:int = 1;
	for (var i:int = ZZTLoader.saveStates.length - 1; i >= 0; i--) {
		// Get genuine, deliberate save states (not bases or incidentals).
		var sState:ZZTBoard = ZZTLoader.saveStates[i];
		if (sState.saveType >= 0)
		{
			var btnText:String = ZZTLoader.sStateDesc[sState.saveType] + " : " + sState.saveStamp;
			addMsgLine(n.toString(), btnText);
			n++;
		}
	}

	// Initiate scroll
	ScrollMsg("Restore Game");
}

// Create scroll interface for ZIP file contents display
public static function zipContentsScroll():void {
	numTextLines = 0;
	msgScrollFormats = [];
	msgScrollText = [];
	msgScrollFiles = true;
	modeWhenBrowserClosed = MTRANS_NORM;

	// ZIP file links
	var subDirFiles:Array = parse.zipData.fileNames;
	for (var i:int = 0; i < subDirFiles.length; i++) {
		// Display file link
		var btnText:String = subDirFiles[i];
		addMsgLine(i.toString(), btnText);
	}

	// Initiate scroll
	ScrollMsg("Contents of ZIP file");
}

// Create scroll interface for WAD file contents display
public static function wadContentsScroll():void {
	numTextLines = 0;
	msgScrollFormats = [];
	msgScrollText = [];
	msgScrollFiles = true;

	// WAD embedded file links
	var subDirFiles:Array = Lump.getEmbeddedFileNames(parse.lumpData, parse.fileData);
	for (var i:int = 0; i < subDirFiles.length; i++) {
		// Display file link
		var btnText:String = subDirFiles[i];
		addMsgLine(i.toString(), btnText);
	}

	// Initiate scroll
	ScrollMsg("Contents of WAD");
}

// Load a file and display its contents as if the entirety were
// a scroll interface that had been opened.
public static function displayFileLink(fileName:String):void {
	if (!utils.endswith(fileName, ".HLP"))
	{
		// In case file link identified in scroll is not HLP,
		// show the text browser instead.
		if (fileSystemType == FST_ZIP)
		{
			parse.fileData = parse.zipData.getFileByName(fileName);
			displayFileBrowser(fileName);
		}
		else
		{
			mainMode = MODE_NORM;
			parse.loadRemoteFile(fileName, MODE_LOADFILEBROWSER);
		}
	}
	else
	{
		// Compile the file link code, UNLESS it is already being browsed.
		if (fileLinkName != fileName)
		{
			if (fileSystemType == FST_ZIP)
			{
				parse.fileData = parse.zipData.getFileByName(fileName);
				launchFileLinkScroll(fileName);
			}
			else
				parse.loadRemoteFile(fileName, MODE_LOADFILELINK);
		}
		else
			launchFileLinkScroll(fileName);
	}
}

// Load a file link ("HLP" file).
public static function launchFileLinkScroll(fileName:String):void {
	if (fileLinkName != fileName)
	{
		// If file link chained from one file to another (an unusual case),
		// remove the old file code.
		if (fileLinkName != "")
		{
			fileLinkName = "";
			interp.codeBlocks.pop();
		}

		// File has not been loaded yet; compile custom code.
		var eInfo:ElementInfo = typeList[fileLinkType];
		var codeStr:String =
			ZZTLoader.readExtendedASCIIString(parse.fileData, parse.fileData.length);

		var newCodeId:int = compileCustomCode(eInfo, codeStr, "\n");
		var numPrefix:String = eInfo.NUMBER.toString() + "\n";

		interp.fileLinkSE = new SE(fileLinkType, 0, 0, 0, true);
		interp.fileLinkSE.extra["CODEID"] = newCodeId;
		fileLinkName = fileName;
	}

	// Scroll is generated by simply dispatching a message to the type.
	mainMode = MODE_NORM;
	interp.briefDispatch(0, interp.thisSE, interp.fileLinkSE);
}

// Load a file and display its contents in a full-page browser,
// in the style of DOS file browsers (only lines 0 and 24 non-scrolling).
public static function displayFileBrowser(fileName:String):void {
	// Separate file data into text lines
	mainMode = MODE_FILEBROWSER;
	var b:ByteArray = parse.fileData;
	var bLimit:int = b.length;

	var lineLen:int = 0;
	textBrowserName = fileName;
	textBrowserSize = bLimit;
	textBrowserLines = [];
	for (var i:int = 0; i < bLimit; i++) {
		lineLen++;
		var val:int = b[i];
		if (val == 10 || lineLen >= 80 || i == bLimit - 1)
		{
			// Break the line; convert to text.
			b.position = i - lineLen + 1;
			var sLine:String = ZZTLoader.readExtendedASCIIString(b, lineLen);
			lineLen = 0;

			// Remove breaking characters.
			if (sLine.charCodeAt(sLine.length - 1) == 10)
				sLine = sLine.substr(0, sLine.length - 1);
			if (sLine.charCodeAt(sLine.length - 1) == 13)
				sLine = sLine.substr(0, sLine.length - 1);

			// Replace tab characters.
			sLine = sLine.replace("\t", "    ");

			textBrowserLines.push(sLine);
		}
	}

	// Show the interface
	drawFileBrowser();
}

// Show file browser with text generated within the program itself.
public static function displayTextBrowser(
	titleMsg:String, displayedLines:String, modeWhenDone:int):void {
	// Separate file data into text lines
	textBrowserName = titleMsg;
	textBrowserSize = displayedLines.length;
	textBrowserLines = displayedLines.split("\n");

	// Show the interface
	mainMode = MODE_FILEBROWSER;
	modeWhenBrowserClosed = modeWhenDone;
	drawFileBrowser();
}

// Draw the file browser interface
public static function drawFileBrowser():void {
	var fileLineColor:int = (4 * 16) + 15;
	var navLineColor:int = (4 * 16) + 15;
	var bodyLineColor:int = (1 * 16) + 15;

	// First line is taken up by filename and other information.
	fbg.writeConst(0, 0, 80, 1, " ", fileLineColor);
	fbg.writeStr(2, 0, textBrowserName, fileLineColor);
	fbg.writeStr(60, 0, "Size:  " + textBrowserSize.toString(), fileLineColor);

	// Last line is taken up by commands.
	fbg.writeConst(0, 24, 80, 1, " ", navLineColor);
	fbg.writeStr(2, 24,
		"Up/Down: Scroll    PgUp/PgDn: Page Scroll    Esc: Exit Browser", navLineColor);

	// Body occupies all other lines.
	fbg.writeConst(0, 1, 80, 23, " ", bodyLineColor);
	textBrowserCursor = -100000000;
	moveFileBrowser(0);
	fbg.visible = true;
}

// Show the scrolling part of the file browser, scrolling if necessary.
public static function moveFileBrowser(newPos:int):void {
	// Clip new cursor.
	var newBrowserCursor:int = newPos;
	if (newBrowserCursor >= textBrowserLines.length)
		newBrowserCursor = textBrowserLines.length - 1;
	if (newBrowserCursor < 0)
		newBrowserCursor = 0;

	// Shift browser by move delta.
	var y1:int = 1;
	var y2:int = 23;
	var moveDelta:int = utils.iabs(newBrowserCursor - textBrowserCursor);
	if (moveDelta <= 22)
	{
		if (newBrowserCursor > textBrowserCursor)
		{
			fbg.moveBlock(0, moveDelta+1, 79, 23, 0, -moveDelta);
			y1 = 24 - moveDelta;
			y2 = 23;
		}
		else if (newBrowserCursor < textBrowserCursor)
		{
			fbg.moveBlock(0, 1, 79, 23 - moveDelta, 0, moveDelta);
			y1 = 1;
			y2 = moveDelta;
		}
		else
		{
			y1 = 0;
			y2 = -1;
		}
	}

	// Fill in emptied lines.
	var bodyLineColor:int = (1 * 16) + 15;
	textBrowserCursor = newBrowserCursor;
	for (var y:int = y1; y <= y2; y++) {
		fbg.writeConst(0, y, 80, 1, " ", bodyLineColor);
		var lCursor:int = (y - 1) + textBrowserCursor;
		if (lCursor < textBrowserLines.length)
			fbg.writeStr(0, y, textBrowserLines[lCursor], bodyLineColor);
	}

	fbg.drawSurfaces();
}

// Perform dissolve effect on viewport
public static function dissolveViewport(modeWhenDone:int, time:Number, toColor:int = -1):void {
	transModeWhenDone = modeWhenDone;
	transColor = toColor;
	transProgress = SE.vpWidth * SE.vpHeight;
	transSquaresPerFrame = int(Number(transProgress) / (time * 30));
	SE.uCameraX = -1000;
	SE.uCameraY = -1000;

	transCurFrame = 0;
	transFrameCount = 1;
	transBaseRate = TRANSITION_BASE_RATE;
	transLogTime = getTimer();
	mainMode = MODE_DISSOLVE;
	modeChanged = true;
}

// Single dissolve effect iteration
public static function dissolveIter():Boolean {
	// Fetch dissolve "random list" array
	var dArray:Array = utils.getDissolveArray(SE.vpWidth, SE.vpHeight);

	// For n squares for this iteration, select and replace.
	for (var i:int = 0; i < transSquaresPerFrame && transProgress > 0; i++)
	{
		var pos:int = dArray[--transProgress];
		var x:int = int(pos % SE.vpWidth);
		var y:int = int(pos / SE.vpWidth);

		if (transColor == -1)
			SE.displaySquare(SE.CameraX + x, SE.CameraY + y);
		else
			mg.setCell(SE.vpX0 + x - 1, SE.vpY0 + y - 1, 219, transColor);
	}

	if (transProgress <= 0)
	{
		mainMode = transModeWhenDone;
		if (transColor == -1)
		{
			// Viewport is now completely up-to-date.
			SE.uCameraX = SE.CameraX;
			SE.uCameraY = SE.CameraY;
		}
		return true;
	}

	mg.drawSurfaces();
	return false;
}

// Perform "scroll transition" effect on viewport
public static function scrollTransitionViewport(modeWhenDone:int, time:Number, toDir:int):void {
	transModeWhenDone = modeWhenDone;
	transDX = -interp.getStepXFromDir4(toDir);
	transDY = -interp.getStepYFromDir4(toDir);
	if (transDX == 0)
		transExtent = SE.vpHeight;
	else
		transExtent = SE.vpWidth;
	transProgress2 = 0;
	transSquaresPerFrame2 = Number(transExtent) / (time * 30);
	SE.uCameraX = -1000;
	SE.uCameraY = -1000;

	transCurFrame = 0;
	transFrameCount = 1;
	transBaseRate = TRANSITION_BASE_RATE;
	transLogTime = getTimer();
	mainMode = MODE_SCROLLMOVE;
	modeChanged = true;
}

// Single "scroll transition" effect iteration
public static function scrollTransitionIter():Boolean {
	// For n squares for this iteration, copy lines and insert new ones.
	var intTransSquares:int = int(transProgress2 + transSquaresPerFrame2) - int(transProgress2);
	transProgress2 += transSquaresPerFrame2;
	transProgress = int(transProgress2);
	var writeX1:int = 0;
	var writeY1:int = 0;
	var writeX2:int = SE.vpWidth - 1;
	var writeY2:int = SE.vpHeight - 1;
	var copyX1:int = writeX1;
	var copyY1:int = writeY1;
	var copyX2:int = writeX2;
	var copyY2:int = writeY2;
	var copyDX:int = transDX * intTransSquares;
	var copyDY:int = transDY * intTransSquares;
	var scrollOffsetX:int = 0;
	var scrollOffsetY:int = 0;
	var result:Boolean = false;

	if (transProgress >= transExtent)
	{
		// Done.  Update entire viewport; don't move anything.
		copyDX = 0;
		copyDY = 0;
		copyY2 = copyY1 - 1;
		transProgress = transExtent;
		mainMode = transModeWhenDone;

		// Viewport is now completely up-to-date.
		SE.uCameraX = SE.CameraX;
		SE.uCameraY = SE.CameraY;
		result = true;
	}
	else if (transDX == 0)
	{
		if (transDY < 0)
		{
			copyY1 -= copyDY;
			writeY1 = writeY2 + copyDY + 1;
			scrollOffsetY = -(transExtent - transProgress);
		}
		else
		{
			copyY2 -= copyDY;
			writeY2 = writeY1 + copyDY - 1;
			scrollOffsetY = (transExtent - transProgress);
		}
	}
	else
	{
		if (transDX < 0)
		{
			copyX1 -= copyDX;
			writeX1 = writeX2 + copyDX + 1;
			scrollOffsetX = -(transExtent - transProgress);
		}
		else
		{
			copyX2 -= copyDX;
			writeX2 = writeX1 + copyDX - 1;
			scrollOffsetX = (transExtent - transProgress);
		}
	}

	// Conduct move.
	if (transProgress < transExtent)
		mg.moveBlock(copyX1+SE.vpX0-1, copyY1+SE.vpY0-1, copyX2+SE.vpX0-1, copyY2+SE.vpY0-1,
			copyDX, copyDY);

	// Conduct redraw.
	var oldCameraX:int = SE.CameraX;
	var oldCameraY:int = SE.CameraY;
	SE.CameraX += scrollOffsetX;
	SE.CameraY += scrollOffsetY;
	for (var y:int = writeY1; y <= writeY2; y++)
	{
		for (var x:int = writeX1; x <= writeX2; x++)
		{
			SE.displaySquare(SE.CameraX + x, SE.CameraY + y);
		}
	}
	SE.CameraX = oldCameraX;
	SE.CameraY = oldCameraY;

	mg.drawSurfaces();
	return result;
}

// Fade all palette indexes to a solid color (usually a fade out to black).
public static function fadeToColorSingle(
	modeWhenDone:int, time:Number, red:int, green:int, blue:int):void {
	var seq:Array = [];
	for (var n:int = 0; n < 16; n++) {
		seq.push(red);
		seq.push(green);
		seq.push(blue);
	}

	fadeToColorBlock(modeWhenDone, time, 0, 16, 255, seq);
}

// Fade select palette indexes to specific colors (usually a fade in to normal colors).
public static function fadeToColorBlock(
	modeWhenDone:int, time:Number, startIdx:int, numIdx:int, extent:int, fadeSeq:Array):void {

	// Ensure that extent is out of 255
	transPaletteFinal = fadeSeq;
	for (var n:int = 0; n < fadeSeq.length; n++) {
		fadeSeq[n] = int(fadeSeq[n] * 255 / extent);
	}

	// Transition variables
	transPaletteCur = mg.getPaletteColors();
	transPaletteDelta = [];
	for (n = 0; n < fadeSeq.length; n++) {
		transPaletteCur[n] = Number(transPaletteCur[n + (startIdx * 3)]);
		transPaletteDelta.push(
			Number(fadeSeq[n] - transPaletteCur[n]) / 255.0);
	}

	transPaletteStartIdx = startIdx;
	transPaletteNumIdx = numIdx;
	transModeWhenDone = modeWhenDone;
	transExtent = 256;
	transProgress = 0;
	transSquaresPerFrame = Number(transExtent) / (time * 30);

	transCurFrame = 0;
	transFrameCount = 1;
	transBaseRate = TRANSITION_BASE_RATE;
	transLogTime = getTimer();
	mainMode = MODE_FADETOBLOCK;
	modeChanged = true;
}

// Fade effect iteration
public static function fadeTransitionIter():Boolean {
	transProgress += transSquaresPerFrame;
	if (transProgress >= transExtent)
	{
		// Palette is now 100% at target.
		mg.setPaletteColors(transPaletteStartIdx, transPaletteNumIdx, 255, transPaletteFinal);
		mainMode = transModeWhenDone;
		return true;
	}

	// Iterate palette entries
	var newSeq:Array = [];
	for (var n:int = 0; n < transPaletteCur.length; n++) {
		transPaletteCur[n] += transPaletteDelta[n] * Number(transSquaresPerFrame);
		newSeq.push(int(transPaletteCur[n]));
	}

	// Update palette
	mg.setPaletteColors(transPaletteStartIdx, transPaletteNumIdx, 255, newSeq);
	mg.drawSurfaces();
	return false;
}

// Display the properties text entry view
public static function showPropTextView(propMode:int, title:String, text:String):void {
	// Set text in properties entry view
	guiPropLabel.text = title;
	guiPropText.enabled = false;
	guiPropText.text = text;
	mg.visible = false;

	// Prepare for property text showing
	modeForPropText = propMode;
	mainMode = MODE_WAITUNTILPROP;
	propTextDelay = 3;
}

// Hide the properties entry view; show main grid again
public static function hidePropTextView(newMode:int):void {
	guiProperties.visible = false;
	guiPropText.enabled = false;
	mg.visible = true;
	mainMode = newMode;
}

// Dispatch an input-originated message to the appropriate context
public static function dispatchInputMessage(msg:String):void
{
	// Certain GUIs are handled internally.
	if (inEditor)
	{
		editor.dispatchEditorMenu(msg);
		return;
	}
	else if (msg == "EVENT_EDITOR")
	{
		for (var i:int = 0; i <= 16; i++)
			Sounds.stopChannel(i);

		inEditor = true;
		highScoresLoaded = false;
		establishGui(prefEditorGui);
		activeObjs = false;
		mainMode = MODE_NORM;
		ZZTLoader.wipeBoardZero();
		ZZTLoader.updateContFromBoard(0, ZZTLoader.boardData[0]);
		interp.dispatchToMainLabel("SETLINECHARS");
		globalProps["OVERLAYSCROLL"] = 1;
		if (globalProps["BOARD"] == -1)
			globalProps["BOARD"] = 0;
		globals["$PLAYERMODE"] = 5; // "ZZT editor screen" mode
		SE.CameraX = 1;
		SE.CameraY = 1;
		editor.bgColorCursor = 0;
		editor.hexTextEntry = 0;
		editor.boardWidth = boardProps["SIZEX"];
		editor.boardHeight = boardProps["SIZEY"];
		editor.forceCodeStrAll();
		editor.modFlag = false;
		editor.initEditor();
		editor.updateEditorView();
	}

	switch (thisGuiName) {
		case "DEBUGMENU":
			dispatchDebugMenu(msg);
			break;
		case "OPTIONSGUI":
			dispatchOptionsGuiMenu(msg);
			break;
		case "OPTIONSEDITGUI":
			dispatchOptionsEditGuiMenu(msg);
			break;
		case "CONSOLEGUI":
			dispatchConsoleGuiMenu(msg);
			break;
		case "EDITGUI":
			editor.dispatchEditGuiMenu(msg);
			break;
		case "EDITGUITEXT":
			editor.dispatchEditGuiTextMenu(msg);
			break;
		default:
			// The main type code receives the message.
			interp.dispatchToMainLabel(msg);
			break;
	}
}

// Dispatch an debug-menu message; this is the main top-level menu for ZZT Ultra
public static function dispatchDebugMenu(msg:String):void
{
	var req:URLRequest;
	switch (msg) {
		case "EVENT_LOADDEP":
			loadDeployedFile(MODE_NORM);
			break;
		case "EVENT_LOADZZT":
			highScoreServer = false;
			parse.loadLocalFile("ZZT", MODE_NATIVELOADZZT);
			break;
		case "EVENT_LOADSZT":
			highScoreServer = false;
			parse.loadLocalFile("SZT", MODE_NATIVELOADSZT);
			break;
		case "EVENT_LOADWAD":
			highScoreServer = false;
			parse.loadLocalFile("WAD", MODE_LOADWAD);
			break;
		case "EVENT_LOADZIP":
			highScoreServer = false;
			parse.loadLocalFile("ZIP", MODE_LOADZIP);
			break;
		case "EVENT_OPTIONS":
			establishGui("OPTIONSGUI");
			editor.propText = "{\n}";
			mainMode = MODE_NORM;
			drawGui();
			drawGuiLabel("CONFIGTYPE", configTypeNames[configType]);
			guiStack.push("OPTIONSGUI");
			break;
		case "EVENT_EDITGUI":
			if (establishGui("EDITGUI"))
			{
				editor.modFlag = false;
				editor.propText = editor.emptyGuiProperties;
				mainMode = MODE_NORM;
				mg.writeConst(0, 0, OverallSizeX, OverallSizeY, " ", 31);
				drawGui();
				editor.writeColorCursors();
				guiStack.push("EDITGUI");
			}
			break;
		case "EVENT_LOADFEATURED":
			launchDeployedFileIfPresent(featuredWorldFile);
			break;
		case "EVENT_VISITWEBSITE":
			parse.blankPage("");
			break;
		case "EVENT_DOCUMENTATION":
			parse.blankPage("editors.html#editors");
			break;
		/*case "EVENT_ACHIEVEMENTS":
			// TBD
			break;
		case "EVENT_PWADS":
			// TBD
			break;*/
	}

	interp.dispatchToMainLabel(msg);
}

// Select config type
public static function setConfigType(cType:int):void {
	configType = cType;

	ZZTProp.overridePropsGenModern["CONFIGTYPE"] = cType;
	ZZTProp.overridePropsGenClassic["CONFIGTYPE"] = cType;

	if (cType == 0)
		ZZTProp.overridePropsGeneral = ZZTProp.overridePropsGenModern;
	else
		ZZTProp.overridePropsGeneral = ZZTProp.overridePropsGenClassic;
}

// Dispatch an options-menu message
public static function dispatchOptionsGuiMenu(msg:String):void
{
	var jObj:Object;
	var k:String;
	switch (msg) {
		case "OPT_QUIT":
			// Update shared objects
			saveSharedObj("CFGMODERN", ZZTProp.overridePropsGenModern);
			saveSharedObj("CFGCLASSIC", ZZTProp.overridePropsGenClassic);
			saveSharedObj("CFGZZTSPEC", ZZTProp.overridePropsZZT);
			saveSharedObj("CFGSZTSPEC", ZZTProp.overridePropsSZT);

			// Return to main menu
			mainMode = MODE_NORM;
			popGui();
			break;
		case "OPT_RESET":
			ZZTProp.setOverridePropDefaults();
			setConfigType(configType);
			drawGuiLabel("CONFIGTYPE", configTypeNames[configType]);
			Toast("All properties reset to defaults.", 1.0);
			break;
		case "OPT_CONFIG":
			configType = (configType + 1) & 1;
			setConfigType(configType);
			drawGuiLabel("CONFIGTYPE", configTypeNames[configType]);
			break;
		case "EVENT_ACCEPTPROP":
			// Parse properties text.
			jObj = parse.jsonDecode(guiPropText.text);
			if (jObj != null)
			{
				if (generalSubset)
				{
					// Edit subset of general properties
					for (k in jObj)
						ZZTProp.overridePropsGeneral[k] = jObj[k];
				}
				else
				{
					// Get properties text; replace entire dictionary with updates
					for (k in propDictToUpdate)
						delete propDictToUpdate[k];
					for (k in jObj)
						propDictToUpdate[k] = jObj[k];
				}

				// Hide properties editor.
				hidePropTextView(MODE_NORM);
				drawGuiLabel("CONFIGTYPE", configTypeNames[configType]);
			}
			break;
		default:
			if (utils.startswith(msg, "OPT_"))
				showOptionsForDict(msg);
			break;
	}

	interp.dispatchToMainLabel(msg);
}

public static function showOptionsForDict(msg:String):void {
	var oTitle:String = "Options";
	var subsetStr:String;

	generalSubset = false;
	propSubset = new Object();
	propDictToUpdate = propSubset;

	switch (msg) {
		case "OPT_GENERAL":
			propDictToUpdate = ZZTProp.overridePropsGeneral;
			oTitle = "General Options";
			showPropTextView(MODE_ENTEROPTIONSPROP, oTitle, 
				parse.jsonToText(propDictToUpdate, true));
			break;
		case "OPT_ZZT":
			propDictToUpdate = ZZTProp.overridePropsZZT;
			oTitle = "ZZT-specific Options";
			showOptionsEditView(oTitle, msg.substr(4));
			break;
		case "OPT_SZT":
			propDictToUpdate = ZZTProp.overridePropsSZT;
			oTitle = "SZT-specific Options";
			showOptionsEditView(oTitle, msg.substr(4));
			break;
		default:
			subsetStr = msg.substr(4);
			if (ZZTProp.propSubsets.hasOwnProperty(subsetStr))
			{
				generalSubset = true;
				for (var i:int = 0; i < ZZTProp.propSubsets[subsetStr].length; i++) {
					var s:String = ZZTProp.propSubsets[subsetStr][i];
					propDictToUpdate[s] = ZZTProp.overridePropsGeneral[s];
				}

				oTitle = ZZTProp.propSubsetNames[subsetStr] + " Options";
				showOptionsEditView(oTitle, subsetStr);
			}
			break;
	}
}

// Show the descriptive options edit view.
public static function showOptionsEditView(title:String, subsetName:String):void {
	// Set up options edit GUI view
	establishGui("OPTIONSEDITGUI");
	mainMode = MODE_NORM;
	drawGui();

	// Draw labels
	drawGuiLabel("CONFIGTYPE", configTypeNames[configType]);
	drawGuiLabel("PROPTITLE", title);

	// Draw property names
	aSubsetName = subsetName;
	var myPropNames:Array = ZZTProp.propSubsets[aSubsetName];
	for (var i:int = 0; i < myPropNames.length; i++)
		mg.writeStr(36-1, i + 5-1, myPropNames[i], 31);

	// Draw cursor, values, and description
	optCursor = 1;
	dispatchOptionsEditGuiMenu("OPT_UP");
}

// Dispatch an options-menu message
public static function dispatchOptionsEditGuiMenu(msg:String):void {
	// Erase cursor
	mg.writeStr(34-1, optCursor + 5-1, " ", 31);
	var myPropNames:Array = ZZTProp.propSubsets[aSubsetName];
	var curPropName:String = myPropNames[optCursor];

	switch (msg) {
		case "OPT_QUIT":
			// Go back to OPTIONSGUI
			establishGui("OPTIONSGUI");
			mainMode = MODE_NORM;
			drawGui();
			drawGuiLabel("CONFIGTYPE", configTypeNames[configType]);
			return;
		case "OPT_UP":
			if (--optCursor < 0)
				optCursor = myPropNames.length - 1;
			break;
		case "OPT_DOWN":
			if (++optCursor >= myPropNames.length)
				optCursor = 0;
			break;
		case "OPT_EDIT":
			// Bring up single-line property text box.
			GuiLabels["PROPVALUE1"][0] = 61;
			GuiLabels["PROPVALUE1"][1] = optCursor + 5;
			textEntry("PROPVALUE1", propDictToUpdate[curPropName].toString(), 20, 14,
				"OPT_TE_ACCEPT", "OPT_TE_REJECT");
			return;
		case "OPT_TE_REJECT":
			// No update; just redraw.
			break;
		case "OPT_TE_ACCEPT":
			// Update property.
			if (propDictToUpdate[curPropName] is int)
				propDictToUpdate[curPropName] = utils.int0(globals["$TEXTRESULT"]);
			else
				propDictToUpdate[curPropName] = globals["$TEXTRESULT"].toString();

			if (generalSubset)
				ZZTProp.overridePropsGeneral[curPropName] = propDictToUpdate[curPropName];
			break;
	}

	// Write cursor
	mg.setCell(34-1, optCursor + 5-1, 16, 29);

	// Draw property values
	for (var i:int = 0; i < myPropNames.length; i++)
		mg.writeStr(61-1, i + 5-1,
			propDictToUpdate[myPropNames[i]].toString(), 30);

	// Draw description of current property
	curPropName = myPropNames[optCursor];
	var propStr:String = "";
	if (ZZTProp.propDesc.hasOwnProperty(curPropName))
		propStr = ZZTProp.propDesc[curPropName];

	eraseGuiLabel("PROPDESC");
	drawGuiLabel("PROPDESC", propStr);

	interp.dispatchToMainLabel(msg);
}

// Dispatch an in-game console-menu message
public static function dispatchConsoleGuiMenu(msg:String):void
{
	var jObj:Object;
	var k:String;
	switch (msg) {
		case "CON_BOARDPROP":
			// Show properties editor.
			if (CHEATING_DISABLES_PROGRESS)
				DISABLE_HISCORE = 1;
			propDictToUpdate = boardProps;
			showPropTextView(MODE_ENTERCONSOLEPROP, "Board Properties",
				parse.jsonToText(propDictToUpdate, true));
			break;
		case "CON_WORLDPROP":
			// Show properties editor.
			if (CHEATING_DISABLES_PROGRESS)
				DISABLE_HISCORE = 1;
			propDictToUpdate = globalProps;
			showPropTextView(MODE_ENTERCONSOLEPROP, "World Properties",
				parse.jsonToText(propDictToUpdate, true));
			break;
		case "CON_GLOBALVAR":
			// Show properties editor.
			if (CHEATING_DISABLES_PROGRESS)
				DISABLE_HISCORE = 1;
			propDictToUpdate = globals;
			showPropTextView(MODE_ENTERCONSOLEPROP, "Global Variables",
				parse.jsonToText(propDictToUpdate, true));
			break;
		case "CON_CHEAT":
			if (CHEATING_DISABLES_PROGRESS)
				DISABLE_HISCORE = 1;
			textEntry("CONFMESSAGE", "", 60, 15, "CHEATACTION", "NOACTION");
			break;
		case "EVENT_ACCEPTPROP":
			// Parse properties text.
			jObj = parse.jsonDecode(guiPropText.text);
			if (jObj != null)
			{
				// Get properties text; hide properties editor.
				for (k in propDictToUpdate)
					delete propDictToUpdate[k];
				for (k in jObj)
					propDictToUpdate[k] = jObj[k];

				hidePropTextView(MODE_NORM);
			}
			break;
	}

	interp.dispatchToMainLabel(msg);
}

// Show "Loading..." tick animation
public static function drawLoadingAnimation():void {
	if (++loadAnimColor > 15)
		loadAnimColor = 9;

	loadAnimPos = (loadAnimPos - 1) & 3;
	var loadAnimStr:String = "";
	switch (loadAnimPos) {
		case 0:
			loadAnimStr = "*...|";
		break;
		case 1:
			loadAnimStr = ".*..\\";
		break;
		case 2:
			loadAnimStr = "..*.-";
		break;
		case 3:
			loadAnimStr = "...*/";
		break;
	}

	drawGuiLabel("LOADINGLOC", "Loading");
	drawGuiLabel("LOADINGANIM", loadAnimStr, loadAnimColor + 16);
}

public static function parseHighScores():void {
	var b:ByteArray = parse.fileData;
	var s:String = b.readUTFBytes(b.length);
	var us:String = s.toUpperCase();

	var bound1:int = us.indexOf("<PRE>");
	var bound2:int = us.indexOf("</PRE>");
	if (bound1 != -1 && bound2 != -1)
		s = s.substring(bound1 + 5, bound2); // Inside PRE tag

	var resultLines:Array = [];
	var lines:Array = s.split("\n");
	for (var i:int = 0; i < lines.length; i++) {
		var ls:String = lines[i];
		if (utils.endswith(ls, "\r"))
			ls = ls.substr(0, ls.length - 1);

		var l:Array = ls.split(",");
		if (l.length >= 3)
			resultLines.push(l);
	}

	if (resultLines.length > 0)
	{
		highScores = resultLines;
		highScoresLoaded = true;
	}
	else
		highScoresLoaded = false;
}

// Process action that comes from waiting on a load-complete event.
public static function processLoadingSuccessModes():void {
	var i:int;

	switch (mainMode) {
		case MODE_LOADMAIN:
			// This is executed on successful load of main GUI file.
			mainMode = MODE_SETUPMAIN;
			origGuiStorage = parse.jsonObj;
			resetGuis();
			if (establishGui("DEBUGMENU"))
			{
				// GUI successfully established for main menu; set up and draw.
				mainMode = MODE_NORM;
				drawGui();

				// Load main OOP definition file
				parse.loadTextFile(GUIS_PREFIX + "zzt_objs.txt", MODE_LOADDEFAULTOOP);
			}
		break;
		case MODE_LOADDEFAULTOOP:
			// This is executed on successful load of default OOP definition file.
			mainMode = MODE_SETUPOOP;
			defsObj = parse.jsonObj;
			if (establishOOP())
			{
				// OOP successfully compiled and definitions established.
				mainMode = MODE_NORM;

				// Establish that there are no "valid" PWADs at the start.
				ZZTLoader.establishPWAD("n/a");

				// Set up deployment from INI file
				parse.loadTextFile(GUIS_PREFIX + "zzt_ini.txt", MODE_LOADINI);
			}
			else
			{
				// OOP compilation unsuccessful.
				mainMode = MODE_NORM;
			}
		break;
		case MODE_LOADINI:
			// This is executed on successful load of INI file.
			if (!establishINI())
			{
				mainMode = MODE_AUTOSTART;
				parse.loadingSuccess = true;
			}
		break;
		case MODE_LOADINDEXPATHS:
			// Index path was loaded; add resulting paths to deployment.
			if (!addIndexPaths())
			{
				mainMode = MODE_AUTOSTART;
				parse.loadingSuccess = true;
			}
		break;
		case MODE_AUTOSTART:
			// Auto-start behavior obeys configuration params.
			if (globalProps["DEP_STARTUPGUI"] != "DEBUGMENU")
			{
				// Replace startup GUI (experts only!)
				establishGui(globalProps["DEP_STARTUPGUI"])
				drawGui();
				guiStack.pop();
				guiStack.push(globalProps["DEP_STARTUPGUI"]);
			}

			// Initiate startup file, if there is one
			if (globalProps["DEP_STARTUPFILE"] == "")
			{
				drawGuiLabel("CUSTOMTEXT", featuredWorldName);
				mainMode = MODE_NORM;
			}
			else
			{
				featuredWorldFile = globalProps["DEP_STARTUPFILE"];
				featuredWorldName = utils.namePartOfFile(featuredWorldFile);
				drawGuiLabel("CUSTOMTEXT", featuredWorldName);
				launchDeployedFile(featuredWorldFile);
			}
		break;

		case MODE_PATCHLOADZZT:
		case MODE_PATCHLOADSZT:
		case MODE_PATCHLOADWAD:
			if (!ZZTLoader.registerPWADFile(parse.fileData, parse.pwadKey))
			{
				// Failed to load--assume blank.
				ZZTLoader.pwads[parse.pwadKey] = "";
			}

			mainMode = MODE_LOADZZT + (mainMode - MODE_PATCHLOADZZT);
			parse.fileData = parse.origFileData;
			parse.lastFileName = parse.origLastFileName;
			parse.loadingSuccess = true;
		break;

		case MODE_NATIVELOADZZT:
			// No file system; just ZZT file.
			fileSystemType = FST_NONE;
			mainMode = MODE_LOADZZT;
		case MODE_LOADZZT:
			mainMode = MODE_SETUPZZT;
			if (!ZZTLoader.pwadIsLoaded(pwadIndex, parse.lastFileName) && !inEditor)
			{
				if (parse.pwadLoad(pwadIndex, MODE_PATCHLOADZZT))
					break;
			}

			highScoresLoaded = false;
			resetGuis();
			modeWhenBrowserClosed = MTRANS_NORM;
			if (ZZTLoader.establishZZTFile(parse.fileData))
			{
				// Successful establishment; load title screen.
				if (!inEditor)
				{
					// Apply scanline mod if set
					if (mg.scanlineMode != globalProps["SCANLINES"])
					{
						mg.updateScanlineMode(globalProps["SCANLINES"]);
						cellYDiv = 16;
					}

					establishGui("ZZTTITLE");
					drawGui();
					drawGuiLabel("WORLDNAME", globalProps["WORLDNAME"]);
					drawPen("SPEEDCURSOR", 0, 8, globalProps["GAMESPEED"], 31, 31);
				}

				if (inEditor)
				{
					ZZTLoader.updateContFromBoard(0, ZZTLoader.boardData[0]);
					globals["$PLAYERMODE"] = 5; // "Editor" mode
					globalProps["OVERLAYSCROLL"] = 1;
				}
				else
				{
					ZZTLoader.switchBoard(0);
					globals["$PLAYERMODE"] = 3; // "ZZT title screen" mode
				}

				globalProps["EVERPLAYED"] = 0;
				globals["$ALLPUSH"] = 0;
				globals["$PLAYERPAUSED"] = 0;
				globals["$PAUSECYCLE"] = 0;
				globals["$PASSAGEEMERGE"] = 0;
				globals["$LASTSAVESECS"] = 0;
				typeList[bearType].CHAR = 153;
				typeList[bearType].COLOR = 6;
				pMoveDir = -1;
				pShootDir = -1;

				if (inEditor)
				{
					mainMode = MODE_NORM;
					editor.modFlag = false;
					editor.boardWidth = boardProps["SIZEX"];
					editor.boardHeight = boardProps["SIZEY"];
					editor.editorCursorX = 1;
					editor.editorCursorY = 1;
					editor.forceCodeStrAll();
					interp.dispatchToMainLabel("SETLINECHARS");
					editor.updateEditorView(false);
					activeObjs = false;
				}
				else
				{
					interp.dispatchToMainLabel("$ONWORLDLOAD");
					dissolveViewport(MODE_NORM, 0.5, -1);
					activeObjs = true;
				}
			}
			else
				mainMode = MODE_NORM;
		break;
		case MODE_NATIVELOADSZT:
			// No file system; just SZT file.
			fileSystemType = FST_NONE;
			mainMode = MODE_LOADSZT;
		case MODE_LOADSZT:
			mainMode = MODE_SETUPSZT;
			if (!ZZTLoader.pwadIsLoaded(pwadIndex, parse.lastFileName) && !inEditor)
			{
				if (parse.pwadLoad(pwadIndex, MODE_PATCHLOADSZT))
					break;
			}

			highScoresLoaded = false;
			resetGuis();
			modeWhenBrowserClosed = MTRANS_NORM;
			if (ZZTLoader.establishZZTFile(parse.fileData))
			{
				// Successful establishment; load intro screen.
				if (!inEditor)
				{
					// Apply scanline mod if set
					if (mg.scanlineMode != globalProps["SCANLINES"])
					{
						mg.updateScanlineMode(globalProps["SCANLINES"]);
						cellYDiv = 16;
					}

					if (globalProps["WORLDNAME"] == "FOREST")
						establishGui("FOREST");
					else if (globalProps["WORLDNAME"] == "PROVING")
						establishGui("PROVING");
					else if (globalProps["WORLDNAME"] == "MONSTER")
						establishGui("MONSTER");
					else
						establishGui("CUSTOMSZT");

					drawGui();
					if (thisGuiName == "CUSTOMSZT")
						drawGuiLabel("CUSTOMTEXT", globalProps["WORLDNAME"]);
				}

				if (inEditor)
				{
					ZZTLoader.updateContFromBoard(0, ZZTLoader.boardData[0]);
					globals["$PLAYERMODE"] = 1; // Normal mode
					globalProps["OVERLAYSCROLL"] = 1;
				}
				else
				{
					ZZTLoader.switchBoard(0);
					globals["$PLAYERMODE"] = 4; // "SZT title screen" mode
				}

				activeObjs = false;

				globalProps["EVERPLAYED"] = 0;
				globals["$_SZTTITLEGUI"] = thisGuiName;
				globals["$ALLPUSH"] = 0;
				globals["$PLAYERPAUSED"] = 0;
				globals["$PAUSECYCLE"] = 0;
				globals["$PASSAGEEMERGE"] = 0;
				globals["$LASTSAVESECS"] = 0;
				typeList[bearType].CHAR = 235;
				typeList[bearType].COLOR = 2;
				pMoveDir = -1;
				pShootDir = -1;

				if (inEditor)
				{
					mainMode = MODE_NORM;
					editor.modFlag = false;
					editor.boardWidth = boardProps["SIZEX"];
					editor.boardHeight = boardProps["SIZEY"];
					editor.editorCursorX = 1;
					editor.editorCursorY = 1;
					editor.forceCodeStrAll();
					interp.dispatchToMainLabel("SETLINECHARS");
					SE.CameraX = 1;
					SE.CameraY = 1;
					editor.updateEditorView(false);
				}
				else
					interp.dispatchToMainLabel("$ONWORLDLOAD");
			}

			mainMode = MODE_NORM;
		break;
		case MODE_LOADWAD:
			mainMode = MODE_SETUPWAD;
			if (!ZZTLoader.pwadIsLoaded(pwadIndex, parse.lastFileName) && !inEditor)
			{
				if (parse.pwadLoad(pwadIndex, MODE_PATCHLOADWAD))
					break;
			}

			highScoresLoaded = false;
			resetGuis();
			fileSystemType = FST_WAD;
			modeWhenBrowserClosed = MTRANS_NORM;
			oop.setOOPType();
			loadedOOPType = -3;

			if (ZZTLoader.establishWADFile(parse.fileData))
			{
				// Successful establishment; load current GUI and title screen.
				if (!inEditor)
				{
					if (globalProps.hasOwnProperty("WADSTARTUPGUI"))
						establishGui(globalProps["WADSTARTUPGUI"]);
					else
						establishGui("ZZTTITLE");

					drawGui();
					//drawGuiLabel("WORLDNAME", globalProps["WORLDNAME"]);
					//drawPen("SPEEDCURSOR", 0, 8, globalProps["GAMESPEED"], 31, 31);
				}

				if (inEditor)
					globals["$PLAYERMODE"] = 1; // Normal mode
				else
					globals["$PLAYERMODE"] = 3; // "ZZT title screen" mode

				i = globalProps["BOARD"];
				globalProps["BOARD"] = -1;
				globalProps["EVERPLAYED"] = 0;
				globals["$ALLPUSH"] = 0;
				globals["$PLAYERPAUSED"] = 0;
				globals["$PAUSECYCLE"] = 0;
				globals["$PASSAGEEMERGE"] = 0;
				globals["$LASTSAVESECS"] = 0;
				pMoveDir = -1;
				pShootDir = -1;

				if (inEditor)
					ZZTLoader.updateContFromBoard(0, ZZTLoader.boardData[0]);
				else
					ZZTLoader.switchBoard(0);

				activeObjs = false;

				// Even though we dispatch the world-load handler with the title
				// screen loaded and many important properties and global variables
				// initialized, nothing is actually displayed, and no paused/unpaused
				// state decision is made.  This is because the WAD should define
				// its own behavior for what it should do upon load (usually, a
				// dissolve effect on the board).  The routine should also unpause
				// the action if the title screen is meant to have action.

				if (inEditor)
				{
					mainMode = MODE_NORM;
					editor.modFlag = false;
					editor.boardWidth = boardProps["SIZEX"];
					editor.boardHeight = boardProps["SIZEY"];
					editor.editorCursorX = 1;
					editor.editorCursorY = 1;
					editor.forceCodeStrAll();
					interp.dispatchToMainLabel("SETLINECHARS");
					globalProps["OVERLAYSCROLL"] = 1;
					SE.CameraX = 1;
					SE.CameraY = 1;
					editor.updateEditorView(false);
				}
				else
				{
					interp.dispatchToMainLabel("$ONWORLDLOAD");
					//dissolveViewport(MODE_NORM, 0.5, -1);
				}
			}
			else
				mainMode = MODE_NORM;
		break;
		case MODE_LOADTRANSFERWAD:
			// Result of WAD transfer load has little effect on editor.
			mainMode = MODE_SETUPWAD;
			modeWhenBrowserClosed = MTRANS_NORM;
			if (ZZTLoader.establishWADFile(parse.fileData, true))
			{
				globalProps["NUMBOARDS"] += 1;
				editor.updateEditorView(false);
				mainMode = MODE_NORM;
				Toast("Transferred.", 0.25);
			}
			else
				mainMode = MODE_NORM;
		break;
		case MODE_LOADZIP:
			// Collect relevant game files from ZIP archive
			fileSystemType = FST_ZIP;
			modeWhenBrowserClosed = MTRANS_NORM;
			arcFileNames = parse.zipData.getFileNamesMatchingExt(".ZZT");
			arcFileNames = arcFileNames.concat(parse.zipData.getFileNamesMatchingExt(".SZT"));
			arcFileNames = arcFileNames.concat(parse.zipData.getFileNamesMatchingExt(".WAD"));

			if ((parse.zipData.numFiles == 1 && arcFileNames.length == 1) ||
				(globalProps["DEP_AUTORUNZIP"] != 0 && arcFileNames.length == 1))
			{
				// Auto-load first game file in ZIP file.
				parse.loadingSuccess = true;
				parse.fileData = parse.zipData.getFileByName(arcFileNames[0]);
				if (utils.endswith(arcFileNames[0], ".ZZT"))
					mainMode = MODE_LOADZZT;
				else if (utils.endswith(arcFileNames[0], ".SZT"))
					mainMode = MODE_LOADSZT;
				else
					mainMode = MODE_LOADWAD;
			}
			else
			{
				// Show scroll containing ZIP file contents.
				zipContentsScroll();
			}
		break;
		case MODE_LOADFILEBROWSER:
			displayFileBrowser(parse.loadingName);
		break;
		case MODE_LOADFILELINK:
			launchFileLinkScroll(parse.loadingName);
		break;
		case MODE_LOADGUI:
			editor.loadGuiFile();
			mainMode = MODE_NORM;
		break;
		case MODE_LOADEXTRAGUI:
			mainMode = MODE_NORM;
			editor.uploadExtraGui();
		break;
		case MODE_LOADEXTRALUMP:
			mainMode = MODE_NORM;
			editor.uploadExtraLump();
		break;
		case MODE_LOADCHAREDITFILE:
			mainMode = MODE_NORM;
			editor.uploadCharEditFile();
		break;
		case MODE_LOADZZL:
			mainMode = MODE_NORM;
			editor.loadZZL();
		break;
		case MODE_SAVEGUI:
			Toast("Saved.", 1.0);
			mainMode = MODE_NORM;
		break;
		case MODE_SAVEWAD:
			Toast("Saved.", 0.25);
			mainMode = MODE_NORM;
			if (editor.quitAfterSave)
				editor.dispatchEditorMenu("ED_REALLYQUIT");
		break;
		case MODE_SAVELEGACY:
			Toast("Saved.", 0.25);
			mainMode = MODE_NORM;
			if (editor.quitAfterSave)
				editor.dispatchEditorMenu("ED_REALLYQUIT");
		break;
		case MODE_SAVEHLP:
			Toast("Saved.", 1.0);
			mainMode = MODE_NORM;
		break;

		case MODE_RESTOREWADFILE:
			if (ZZTLoader.establishWADFile(parse.fileData))
			{
				// Successful establishment; load current GUI and board.
				establishGui(globalProps["THISGUI"]);
				drawGui();
				i = globalProps["BOARD"];
				globalProps["BOARD"] = -1;
				ZZTLoader.switchBoard(i);
				dissolveViewport(MODE_NORM, 0.5, -1);
				interp.dispatchToMainLabel("$ONRESTOREGAME");
			}
			else
				mainMode = MODE_NORM;
		break;

		case MODE_GETHIGHSCORES:
			mainMode = parse.originalAction;
			parseHighScores();
			interp.dispatchToMainLabel(highScoresLoaded ? "$ONGETHS" : "$ONFAILGETHS");
		break;
		case MODE_POSTHIGHSCORE:
			mainMode = parse.originalAction;
			parseHighScores();
			interp.dispatchToMainLabel(highScoresLoaded ? "$ONPOSTHS" : "$ONFAILPOSTHS");
		break;
	}
}

// Main timer tick iteration; called at 30 Hz
public static function mTick(event:TimerEvent):void
{
	// Master counter
	mcount++;

	// Hide toast text if time expired.
	if (toastTime > 0)
	{
		if (--toastTime <= 3)
		{
			toastObj.alpha = toastObj.alpha - 0.25;
			if (toastObj.alpha <= 0.0)
				toastObj.visible = false;
		}
	}

	// "Scroll" interfaces take priority over all other types
	// of action, whether opening, closing, or interacting.
	if (mainMode >= MODE_SCROLLOPEN && mainMode <= MODE_SCROLLCHAIN)
	{
		if (mainMode == MODE_SCROLLOPEN || mainMode == MODE_SCROLLCHAIN)
		{
			// Open the scroll interface.
			curScrollCols += 8;
			curScrollRows += 2;
			if (curScrollCols > msgScrollWidth || globalProps["IMMEDIATESCROLL"] != 0 || inEditor)
				curScrollCols = msgScrollWidth;
			if (curScrollRows > msgScrollHeight || globalProps["IMMEDIATESCROLL"] != 0 || inEditor)
				curScrollRows = msgScrollHeight;
			setScrollMsgDims(curScrollCols, curScrollRows);
			titleGrid.visible = true;
			scrollGrid.visible = true;
			scrollArea.visible = true;
			scrollArea.scaleX = (scroll40Column + 1);
			titleGrid.setDoubled(Boolean(scroll40Column == 1));
			scrollGrid.setDoubled(Boolean(scroll40Column == 1));

			if (curScrollCols >= msgScrollWidth && curScrollRows >= msgScrollHeight)
			{
				// Go to interaction mode.
				drawScrollMsgText();
				mainMode = MODE_SCROLLINTERACT;
			}
			else
			{
				titleGrid.drawSurfaces();
				scrollGrid.drawSurfaces();
			}
		}
		else if (mainMode == MODE_SCROLLCLOSE)
		{
			// Close the scroll interface.
			curScrollRows -= 3;
			if (curScrollRows < 1 || globalProps["IMMEDIATESCROLL"] != 0 || inEditor)
			{
				// Hide scroll interface.
				globals["$SCROLLMSG"] = 0;
				titleGrid.visible = false;
				scrollGrid.visible = false;
				scrollArea.visible = false;

				// If file link is source of scroll text, remove code.
				if (fileLinkName != "")
				{
					fileLinkName = "";
					interp.codeBlocks.pop();
				}

				// Go back to normal operations.
				mainMode = MODE_NORM;
				if (modeWhenBrowserClosed == MTRANS_ZIPSCROLL)
					zipContentsScroll();
			}
			else
			{
				setScrollMsgDims(curScrollCols, curScrollRows);
				titleGrid.drawSurfaces();
				scrollGrid.drawSurfaces();
			}
		}
		else if (inEditor)
		{
			// Update surfaces if scroll is open (special circumstances apply)
			mg.drawSurfaces();
		}

		return;
	}

	// Transition effects are usually over very quickly
	if (++transCurFrame >= transFrameCount)
	{
		// Transition effects catch whether the CPU might be too slow to render
		// a complex update that hits multiple parts of the screen.  If the
		// actual logged time between transition iterations is more than double
		// the requested rate, shift the strategy in such a way that the
		// transition rate is doubled, but with an actual screen update
		// occurring only half as often.  Flash usually responds well to
		// updates that don't require the screen to be hit every single frame.
		transCurFrame = 0;

		// Test if transition effect lags too much for CPU.
		var transDeltaTime:Number = getTimer() - transLogTime;
		if (Math.floor(transDeltaTime / transBaseRate) >= 2.0)
		{
			// Unacceptable--increase the base rate and multiplier.
			//trace(transDeltaTime, transBaseRate, transSquaresPerFrame);
			transBaseRate *= 2.0;
			transFrameCount *= 2;
			transSquaresPerFrame *= 2;
		}

		transLogTime = getTimer();

		if (mainMode == MODE_DISSOLVE)
		{
			if (!dissolveIter())
				return;
		}
		else if (mainMode == MODE_SCROLLMOVE)
		{
			if (!scrollTransitionIter())
				return;
		}
		else if (mainMode == MODE_FADETOBLOCK)
		{
			if (!fadeTransitionIter())
				return;
		}
	}

	// Iterate game-oriented flashing toast text if needed.
	if ((mcount & 3) == 0 && toastMsgTimeLeft > 0)
	{
		// The toast text iterates only while the action is progressing (if a "game" GUI)
		// or if GUI does not resemble ZZTGAME, SZTGAME, etc.
		if ((activeObjs && mainMode == MODE_NORM) || thisGuiName.indexOf("ZTGAME") == -1)
		{
			toastMsgTimeLeft -= 4;
			if (toastMsgTimeLeft <= 0)
			{
				// Remove line(s).
				undisplayToastMsg();
				interp.marqueeText = "";
			}
			else
			{
				// Flash lines.
				if (++toastMsgColor > 15)
					toastMsgColor = 9;
	
				displayToastMsg();
			}
		}
	}

	// Show loading animation if needed.
	if (showLoadingAnim)
		drawLoadingAnimation();

	// Show delayed property text if necessary.
	if (propTextDelay > 0)
	{
		if (--propTextDelay <= 0)
		{
			mainMode = modeForPropText;
			guiProperties.visible = true;
			guiPropText.enabled = true;
		}
	}

	// Handle result of loading action.
	if (parse.loadingSuccess)
	{
		parse.loadingSuccess = false;
		processLoadingSuccessModes();
	}

	// This is the main I/O handling mode.
	if (mainMode == MODE_NORM && activeObjs)
	{
		// Game speed is manifested in terms of the ZZT speed control
		// setting, in which each cycle-1 interval takes up gTickInit
		// frames (usually a fractional value).  The remainder is not
		// discarded after a cycle completes; the result must be
		// time-averaged to give the appearance of resembling the
		// factor-of-18.2 Hz rate used in the original code.
		gTickCurrent -= 1.0;
		while (gTickCurrent <= 0.0)
		{
			gTickCurrent += gTickInit;

			// If click-to-move active, feed into movement directions.
			if (input.c2MDestX != -1)
			{
				input.lastPlayerX = interp.playerSE.X;
				input.lastPlayerY = interp.playerSE.Y;
				input.moveC2MSquare();
			}

			// Process all status elements.
			modeChanged = false;
			for (var i:int = 0; i < statElem.length; i++)
			{
				legacyIndex = i;
				interp.execSECode(statElem[i]);
				if (modeChanged)
					break; // If scroll or board transition, all remaining SEs wait.
			}

			// Process the "FL_DEAD" flags for status elements, which
			// identifies status elements to remove.
			for (i = 0; i < statElem.length; i++)
			{
				if ((statElem[i].FLAGS & interp.FL_DEAD) != 0)
				{
					// Block-closure mechanism maintains original iteration order.
					statElem.splice(i, 1);
					i--;

					/*
					// End-move mechanism maintains has least overhead of list,
					// maintaining most of original iteration order except for last SE.
					statElem[i] = statElem[statElem.length - 1];
					statElem.pop();
					i--;
					*/

					// Neither of the above mechanisms seems to be notably
					// superior than the other, in either performance or
					// iteration accuracy.
				}
			}

			// Update legacy tick counter
			if (++legacyTick > LEGACY_TICK_SIZE)
				legacyTick = 1;

			if (oop.hasError)
			{
				oop.hasError = false;
				Toast(oop.errorText);
			}

			// If click-to-move active, select next direction to move.
			if (input.c2MDestX != -1)
				input.chooseNextC2MDir();
		}

		// If necessary, update game speed and dispatch every-second message.
		setGameSpeed(int(globalProps["GAMESPEED"]));
		if (++scount == 30)
		{
			scount = 0;
			interp.dispatchToMainLabel("$SECONDINTERVAL");
		}

		// If a run/fire key is being held down,
		// push additional keydowns based on rate, etc.
		var runDelay:int = int(globalProps["PLAYERRUNDELAY"]);
		var fireDelay:int = int(globalProps["PLAYERFIREDELAY"]);
		if ((mcount & 1) == 0)
		{
			if (input.keyCodeDowns[16] == 0) // Shift
			{
				// Run
				input.extraKeyDownHandler(37, 0, false, false, runDelay); // Left
				input.extraKeyDownHandler(38, 0, false, false, runDelay); // Up
				input.extraKeyDownHandler(39, 0, false, false, runDelay); // Right
				input.extraKeyDownHandler(40, 0, false, false, runDelay); // Down
				input.extraKeyDownHandler(32, 32, false, false, runDelay); // Space
			}
			else if (input.mDown)
			{
				input.mouseFireHandler(fireDelay); // Mouse fire (button held down)
			}
			else
			{
				// Fire
				input.extraKeyDownHandler(37, 0, true, false, fireDelay); // Left
				input.extraKeyDownHandler(38, 0, true, false, fireDelay); // Up
				input.extraKeyDownHandler(39, 0, true, false, fireDelay); // Right
				input.extraKeyDownHandler(40, 0, true, false, fireDelay); // Down
			}
		}
	}
	else if (mainMode == MODE_NORM && !activeObjs)
	{
		// This is the "paused" or "menu" I/O handling mode.
		if (inEditor)
		{
			// Editor time-based action has special handling.
			if (editor.cursorActive)
			{
				// Blinking cursor
				if ((mcount & 3) == 0)
					editor.drawEditorCursor();
			}

			if (typeAllInfoDelay > 0)
			{
				if (--typeAllInfoDelay == 0)
					editor.showTypeAllInfo();
			}
		}
		else
		{
			// The PAUSED message is sent to the main object every frame.
			// Additionally, GUI-oriented keyboard commands will still work.
			if (oopReady)
				interp.dispatchToMainLabel("$PAUSED");
		}
	}

	// Incidental sound update.
	Sounds.playVoice();

	// Handle blink mode updates.
	if (++bcount == 8)
	{
		// Turn blinking cells OFF.
		if (CellGrid.blinkChanged)
		{
			CellGrid.blinkChanged = false;
			mg.captureBlinkList(false);
		}
		else
			mg.blinkToggle(false);
	}
	if (bcount == 16)
	{
		// Turn blinking cells ON.
		bcount = 0;
		if (CellGrid.blinkChanged)
		{
			CellGrid.blinkChanged = false;
			mg.captureBlinkList(true);
		}
		else
			mg.blinkToggle(true);
	}

	// Update surfaces if needed.
	mg.drawSurfaces();
}

}

}

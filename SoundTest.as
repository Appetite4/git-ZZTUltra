// SoundTest.as:  Sound test interface business logic.

package 
{
// Imports
import flash.display.*;
import flash.geom.*;
import flash.text.*;
import flash.net.*
import flash.utils.ByteArray;
import fl.core.UIComponent;
import fl.controls.TextInput;
import fl.controls.TextArea;
import fl.controls.ComboBox;
import fl.controls.List;
import fl.controls.NumericStepper;
import fl.controls.Button;
import fl.controls.ScrollBar;
import fl.controls.ScrollBarDirection;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.IOErrorEvent;
import flash.events.TimerEvent;
import fl.events.ScrollEvent;
import flash.utils.Timer;
import flash.utils.getTimer;
import com.adobe.serialization.json.JSON;

public class SoundTest {

// Constants
public static const PAGE_MAIN:int = 0;
public static const PAGE_UPLOAD:int = 1;
public static const PAGE_LOGIN:int = 2;
public static const PAGE_MESSAGE:int = 3;

public static const MAX_MISTAKE_ALLOWED:int = 4;
public static const LOGIN_DURATION:int = 30 * 60 * 30; // 30 minutes

// Login tunes
public static var loginTunes:Array = [
	"ICXFXGXCXFXGXCXFX",
	"IDGFGCGEG",
	"IFGAGFEDC",
	"IDGECQDG",
	"IEEEESD#EIF#E",
	"ICD#FGFD#QCX",
	"IFA#FAFAFA",
	"ICEGAA#AGE",
	"IF#G#IAG#F#E",
	"IAG#XF#XEXF#XG#XHAIX",
];
public static var masterTune:String = "SC#CC#CC#XXXSC#CC#D#FD#FF#G#GG#GG#XXX";
public static var masterMatch:String = "C#CC#CC#C#CC#D#FD#FF#G#GG#GG#";

// Stage
public static var stage:Stage;

// Layers
public static var lMainPage:DisplayObject;
public static var lUploadPage:DisplayObject;
public static var lLoginPage:DisplayObject;
public static var lMessagePage:DisplayObject;

// Controls
public static var cbFilter:ComboBox;
public static var lbLibrary:List;
public static var txtSongInfo:TextField;
public static var txtCurTime:TextField;
public static var txtMaxTime:TextField;
public static var tbPrefix:TextInput;
public static var taSong:TextArea;
public static var scrTimeline:ScrollBar;
public static var sbMainVolume:NumericStepper;
public static var bUpload:Button;
public static var bPlay:Button;
public static var bStop:Button;
public static var bLoopPlay:Button;
public static var bPause:Button;
public static var tbLoginEmail:TextInput;
public static var txtTuneCopy:TextField;
public static var bC:WhiteKey;
public static var bCS:BlackKey;
public static var bD:WhiteKey;
public static var bDS:BlackKey;
public static var bE:WhiteKey;
public static var bF:WhiteKey;
public static var bFS:BlackKey;
public static var bG:WhiteKey;
public static var bGS:BlackKey;
public static var bA:WhiteKey;
public static var bAS:BlackKey;
public static var bB:WhiteKey;
public static var bLoginSubmit:Button;
public static var bLoginCancel:Button;
public static var bPlayTune:Button;
public static var bBackSpace:Button;

public static var lbULibrary:List;
public static var txtContrib:TextField;
public static var tbTitle:TextInput;
public static var tbCover:TextInput;
public static var tbAuthor:TextInput;
public static var tbGame:TextInput;
public static var tbYear:TextInput;
public static var tbTags:TextInput;
public static var tbDesc:TextInput;
public static var taUSong:TextArea;
public static var bCreateNew:Button;
public static var bUPlay:Button;
public static var bUStop:Button;
public static var bUPause:Button;
public static var bULoopPlay:Button;
public static var bUpdate:Button;
public static var bUCancel:Button;
public static var scrUTimeline:ScrollBar;

public static var txtMessage:TextField;
public static var bMsgOK:Button;

// Dataset vars
public static var dataset:String;
public static var jsonObj:Object;
public static var lObj:Object;

public static var maxUID:int = 1;
public static var libraryUIDs:Array = [];
public static var libraryNames:Array = [];
public static var libraryDisp:Array = [];
public static var libraryChanging:Boolean = false;
public static var extraSongObj:Object = null;
public static var usingExtraSong:Boolean = false;

// Loading status
public static var loadingName:String = "";
public static var myLoader:URLLoader = null;
public static var loadingSuccess:Boolean = false;
public static var tickTimer:Timer;
public static var mcount:int = 0;
public static var loginRefreshTime:int = 0;
public static var partialUpdate:Boolean = false;
public static var canLogin:Boolean = false;

// Timeline management
public static var chanDurations:Vector.<Number> = new Vector.<Number>(Sounds.NUM_CHANNELS);
public static var chanTempoMultiplier:Vector.<Number> = new Vector.<Number>(Sounds.NUM_CHANNELS);
public static var chanPos:Vector.<Number> = new Vector.<Number>(Sounds.NUM_CHANNELS);
public static var chanStrings:Vector.<String> = new Vector.<String>(Sounds.NUM_CHANNELS);
public static var chanDone:Vector.<Boolean> = new Vector.<Boolean>(Sounds.NUM_CHANNELS);
public static var lastChannel:Number = 0;
public static var lastTempoMultiplier:Number = 1.0;
public static var lastDuration:Number = FxEnvelope.T1_DURATION;
public static var songDuration:Number = 44100.0;
public static var middleMSTime:Number = 0.0;
public static var runningTicks:int = 0;

// Action-on-start
public static var initPlaySongName:String = "";
public static var initFilterName:String = "";
public static var initLoopPlay:int = 0;
public static var initStartTime:Number = 0.0;

// Other
public static var activePage:int = 0;
public static var uploadMod:Boolean = false;
public static var loggedIn:Boolean = false;
public static var masterKey:Boolean = false;
public static var badStanding:Boolean = false;
public static var userStartedPlay:Boolean = false;
public static var userPausedPlay:Boolean = false;
public static var userSetMiddlePlay:Boolean = false;
public static var loopingActive:Boolean = false;
public static var loopingPosted:Boolean = false;
public static var shownUpload:Boolean = false;
public static var defaultPrefix:String = "Z01@U137V40K40:0.3:";
public static var userName:String = "";
public static var playedNoteSequence:String = "";
public static var reqNoteSequence:String = "";
public static var myNoteSequence:String = "";
public static var mistakeDelay:int = int(250 * 30 / 1000);
public static var mistakeTimeOut:int = 0;
public static var mistakeCount:int = 0;

// Constructor
public static function init(myStage:Stage) {
	// Set stage
	stage = myStage;

	// Set up song filters
	SongFilters.init();

	// Establish UI components
	lMainPage = getSuperChildByName(stage, "l_mainpage");
	lUploadPage = getSuperChildByName(stage, "l_uploadpage");
	lLoginPage = getSuperChildByName(stage, "l_loginpage");
	lMessagePage = getSuperChildByName(stage, "l_messagepage");

	// Main
	cbFilter = getUIComponentByName(stage, "cb_filter") as ComboBox;
	lbLibrary = getSuperChildByName(stage, "lb_library") as List;
	txtSongInfo = getSuperChildByName(stage, "txt_songinfo") as TextField;
	txtCurTime = getSuperChildByName(stage, "txt_curtime") as TextField;
	txtMaxTime = getSuperChildByName(stage, "txt_maxtime") as TextField;
	tbPrefix = getSuperChildByName(stage, "tb_prefix") as TextInput;
	taSong = getSuperChildByName(stage, "ta_song") as TextArea;
	sbMainVolume = getSuperChildByName(stage, "sb_mainvolume") as NumericStepper;
	bUpload = getUIComponentByName(stage, "b_upload") as Button;
	bPlay = getUIComponentByName(stage, "b_play") as Button;
	bLoopPlay = getUIComponentByName(stage, "b_loopplay") as Button;
	bStop = getUIComponentByName(stage, "b_stop") as Button;
	bPause = getUIComponentByName(stage, "b_pause") as Button;
	scrTimeline = getSuperChildByName(stage, "scr_timeline") as ScrollBar;

	// Login
	tbLoginEmail = getSuperChildByName(stage, "tb_loginemail") as TextInput;
	txtTuneCopy = getSuperChildByName(stage, "txt_tunecopy") as TextField;
	bC = getSuperChildByName(stage, "b_C") as WhiteKey;
	bCS = getSuperChildByName(stage, "b_CS") as BlackKey;
	bD = getSuperChildByName(stage, "b_D") as WhiteKey;
	bDS = getSuperChildByName(stage, "b_DS") as BlackKey;
	bE = getSuperChildByName(stage, "b_E") as WhiteKey;
	bF = getSuperChildByName(stage, "b_F") as WhiteKey;
	bFS = getSuperChildByName(stage, "b_FS") as BlackKey;
	bG = getSuperChildByName(stage, "b_G") as WhiteKey;
	bGS = getSuperChildByName(stage, "b_GS") as BlackKey;
	bA = getSuperChildByName(stage, "b_A") as WhiteKey;
	bAS = getSuperChildByName(stage, "b_AS") as BlackKey;
	bB = getSuperChildByName(stage, "b_B") as WhiteKey;
	bLoginSubmit = getUIComponentByName(stage, "b_loginsubmit") as Button;
	bLoginCancel = getUIComponentByName(stage, "b_logincancel") as Button;
	bPlayTune = getUIComponentByName(stage, "b_playtune") as Button;
	bBackSpace = getUIComponentByName(stage, "b_backspace") as Button;

	// Upload
	lbULibrary = getSuperChildByName(stage, "lb_ulibrary") as List;
	txtContrib = getSuperChildByName(stage, "txt_contrib") as TextField;
	tbTitle = getSuperChildByName(stage, "tb_title") as TextInput;
	tbCover = getSuperChildByName(stage, "tb_cover") as TextInput;
	tbAuthor = getSuperChildByName(stage, "tb_author") as TextInput;
	tbGame = getSuperChildByName(stage, "tb_game") as TextInput;
	tbYear = getSuperChildByName(stage, "tb_year") as TextInput;
	tbTags = getSuperChildByName(stage, "tb_tags") as TextInput;
	tbDesc = getSuperChildByName(stage, "tb_desc") as TextInput;
	taUSong = getSuperChildByName(stage, "ta_usong") as TextArea;
	bCreateNew = getUIComponentByName(stage, "b_createnew") as Button;
	bUPlay = getUIComponentByName(stage, "b_uplay") as Button;
	bUStop = getUIComponentByName(stage, "b_ustop") as Button;
	bULoopPlay = getUIComponentByName(stage, "b_uloopplay") as Button;
	bUPause = getUIComponentByName(stage, "b_upause") as Button;
	bUpdate = getUIComponentByName(stage, "b_update") as Button;
	bUCancel = getUIComponentByName(stage, "b_ucancel") as Button;
	scrUTimeline = getSuperChildByName(stage, "scr_utimeline") as ScrollBar;

	// Message
	txtMessage = getSuperChildByName(stage, "txt_message") as TextField;
	bMsgOK = getUIComponentByName(stage, "b_msgok") as Button;

	// Configure components
	lLoginPage.visible = false;
	lUploadPage.visible = false;
	lMessagePage.visible = false;
	bUpload.label = "Upload Song";
	bPlay.label = "Play";
	bLoopPlay.label = "Looped Play";
	bPause.label = "Pause";
	bStop.label = "Stop";
	bLoginSubmit.label = "Log In";
	bLoginCancel.label = "Cancel";
	bPlayTune.label = "Play Tune";
	bBackSpace.label = "Back 1 Note";
	bCreateNew.label = "Create New Song";
	bUPlay.label = "Play";
	bULoopPlay.label = "Looped Play";
	bUPause.label = "Pause";
	bUStop.label = "Stop";
	bUpdate.label = "Upload";
	bUCancel.label = "Exit";
	bMsgOK.label = "OK";

	cbFilter.editable = false;
	cbFilter.rowCount = 26;
	for (var j:int = 0; j < SongFilters.allFilters.length; j++) {
		var o:Object = new Object();
		o["label"] = SongFilters.allFilters[j];
		o["data"] = null;
		cbFilter.addItem(o);
	}

	scrTimeline.direction = ScrollBarDirection.HORIZONTAL;
	scrTimeline.minScrollPosition = 0.0;
	scrTimeline.maxScrollPosition = 100.0;
	scrTimeline.scrollPosition = 0.0;
	scrTimeline.width = taSong.width;
	scrUTimeline.direction = ScrollBarDirection.HORIZONTAL;
	scrUTimeline.minScrollPosition = 0.0;
	scrUTimeline.maxScrollPosition = 100.0;
	scrUTimeline.scrollPosition = 0.0;
	scrUTimeline.width = taUSong.width;

	sbMainVolume.minimum = 0;
	sbMainVolume.maximum = 50;
	sbMainVolume.value = 50;

	tbPrefix.text = defaultPrefix;

	// Timer
	mcount = 0;
	tickTimer = new Timer(int(1000/30), 0); // FPS -> Milliseconds
	tickTimer.addEventListener(TimerEvent.TIMER, mTick, false, 0);
	tickTimer.start();

	// Load library
	loadSongLibrary();

	// Add event handlers
	stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed, false, 3);
	bUpload.addEventListener(MouseEvent.CLICK, showUploadScreen, false, 3);
	bPlay.addEventListener(MouseEvent.CLICK, playSong, false, 3);
	bUPlay.addEventListener(MouseEvent.CLICK, playSong, false, 3);
	bLoopPlay.addEventListener(MouseEvent.CLICK, loopPlaySong, false, 3);
	bULoopPlay.addEventListener(MouseEvent.CLICK, loopPlaySong, false, 3);
	bStop.addEventListener(MouseEvent.CLICK, stopSong, false, 3);
	bUStop.addEventListener(MouseEvent.CLICK, stopSong, false, 3);
	bPause.addEventListener(MouseEvent.CLICK, pauseSong, false, 3);
	bUPause.addEventListener(MouseEvent.CLICK, pauseSong, false, 3);
	bLoginSubmit.addEventListener(MouseEvent.CLICK, loginAction, false, 3);
	bLoginCancel.addEventListener(MouseEvent.CLICK, showMainScreen, false, 3);
	bPlayTune.addEventListener(MouseEvent.CLICK, playLoginTune, false, 3);
	bBackSpace.addEventListener(MouseEvent.CLICK, backOneNote, false, 3);
	bC.addEventListener(MouseEvent.CLICK, enterNoteC, false, 3);
	bCS.addEventListener(MouseEvent.CLICK, enterNoteCS, false, 3);
	bD.addEventListener(MouseEvent.CLICK, enterNoteD, false, 3);
	bDS.addEventListener(MouseEvent.CLICK, enterNoteDS, false, 3);
	bE.addEventListener(MouseEvent.CLICK, enterNoteE, false, 3);
	bF.addEventListener(MouseEvent.CLICK, enterNoteF, false, 3);
	bFS.addEventListener(MouseEvent.CLICK, enterNoteFS, false, 3);
	bG.addEventListener(MouseEvent.CLICK, enterNoteG, false, 3);
	bGS.addEventListener(MouseEvent.CLICK, enterNoteGS, false, 3);
	bA.addEventListener(MouseEvent.CLICK, enterNoteA, false, 3);
	bAS.addEventListener(MouseEvent.CLICK, enterNoteAS, false, 3);
	bB.addEventListener(MouseEvent.CLICK, enterNoteB, false, 3);
	bCreateNew.addEventListener(MouseEvent.CLICK, createNewSong, false, 3);
	bUpdate.addEventListener(MouseEvent.CLICK, updateSong, false, 3);
	bUCancel.addEventListener(MouseEvent.CLICK, showMainScreen2, false, 3);
	bMsgOK.addEventListener(MouseEvent.CLICK, closeMessage, false, 3);
	sbMainVolume.addEventListener(Event.CHANGE, setMasterVolume, false, 3);
	lbLibrary.addEventListener(Event.CHANGE, loadFromLibrary, false, 3);
	lbULibrary.addEventListener(Event.CHANGE, loadFromLibrary, false, 3);
	cbFilter.addEventListener(Event.CHANGE, changeFilter, false, 3);
	scrTimeline.addEventListener(ScrollEvent.SCROLL, modScrollTimeline, false, 3);
	scrUTimeline.addEventListener(ScrollEvent.SCROLL, modScrollTimeline, false, 3);

	// Read deployment GET variables from URL, if any
	var flashVars:Object = stage.loaderInfo.parameters;
	for (var kObj:Object in flashVars)
	{
		var k:String = kObj.toString().toUpperCase();
		if (k == "SONG")
			initPlaySongName = flashVars[kObj].toString();
		else if (k == "FILTER")
			initFilterName = flashVars[kObj].toString();
		else if (k == "LOOP")
			initLoopPlay = utils.int0(flashVars[kObj].toString());
		else if (k == "TIME")
			initStartTime = utils.float0(flashVars[kObj].toString());
	}
}

// This function drills down through the object hierarchy until
// a named child is found.
public static function getSuperChildByName(cont:DisplayObjectContainer, str:String):DisplayObject {
	// First, see if direct named child exists.
	var directchild:DisplayObject = cont.getChildByName(str);
	if (directchild) return directchild;

	// Check each container for additional children.
	for (var n:int = 0; n < cont.numChildren; n++) {
		var obj:DisplayObject = cont.getChildAt(n);
		if (obj is DisplayObjectContainer)
		{
			var tchild:DisplayObject =
				getSuperChildByName(DisplayObjectContainer(obj), str);
			if (tchild) return tchild;
		}
	}

	// No display object children match named child.
	return null;
}

// This function fetches a UIComponent using getSuperChildByName,
// applying a font style before return.
public static function getUIComponentByName(cont:DisplayObjectContainer, str:String):DisplayObject {
	var uiComp:UIComponent = getSuperChildByName(cont, str) as UIComponent;
	if (uiComp)
	{
		var tf:TextFormat = new TextFormat("_sans", 11, 0xFFFFFF, true, false, false,
			'', '', TextFormatAlign.LEFT, 0, 0, 0, 0);
		uiComp.setStyle("textFormat", tf);
	}

	return uiComp;
}

public static function keyPressed(event:KeyboardEvent):void {
	var charCode:uint = event.charCode;
	var theCode:uint = event.keyCode;
	var ctrlStatus:Boolean = event.ctrlKey;

	// Process shortcuts for key combinations
	switch (theCode) {
		case 116: // F5
			if (!ctrlStatus)
				basicPlaySong();
		break;
		case 117: // F6
			if (!ctrlStatus)
				loopPlaySong(null);
		break;
		case 118: // F7
		case 19: // Pause/Break
			if (!ctrlStatus)
				pauseSong(null);
		break;
		case 119: // F8
			if (!ctrlStatus)
				stopSong(null);
		break;
	}
}

public static function showMainScreen(event:MouseEvent):void
{
	activePage = PAGE_MAIN;
	lMainPage.visible = true;
	lUploadPage.visible = false;
	lLoginPage.visible = false;
	lMessagePage.visible = false;
}

public static function showMainScreen2(event:MouseEvent):void
{
	if (lbULibrary.selectedIndex == lbULibrary.length - 1)
		updateExtraSongObj();

	showMainScreen(event);
}

public static function showUploadScreen(event:MouseEvent):void
{
	if (mcount > loginRefreshTime)
		loggedIn = false;

	if (!loggedIn)
	{
		showLoginScreen(event);
		return;
	}

	txtContrib.text = "Contributor:  " + userName;
	taUSong.text = taSong.text;

	activePage = PAGE_UPLOAD;
	lMainPage.visible = false;
	lUploadPage.visible = true;
	lLoginPage.visible = false;
	lMessagePage.visible = false;
	uploadMod = false;

	// Ensure entire library is shown
	cbFilter.selectedIndex = 0;
	populateLibraryList("");

	// An extra entry always exists in this list, representing a "new" song slot.
	var o:Object = new Object();
	o["label"] = "[Enter New Song Title]";
	o["data"] = null;
	lbULibrary.addItem(o);

	if (!shownUpload)
	{
		extraSongObj = new Object();
		libraryDisp.push(extraSongObj);
		createNewSong(null);
		shownUpload = true;
	}
	else
	{
		libraryDisp.push(extraSongObj);
		usingExtraSong = false;
		lbULibrary.selectedIndex = lbULibrary.length - 1;
		loadFromLibrary(null);
		taUSong.text = extraSongObj["song"];
	}
}

public static function pickRandomLoginTune():void
{
	var noteProfile:String = "ABCDEFG";

	// Get random note sequence; strip out non-note information
	reqNoteSequence = "";
	playedNoteSequence = loginTunes[utils.randrange(0, loginTunes.length - 1)];
	for (var i:int = 0; i < playedNoteSequence.length; i++) {
		var s:String = playedNoteSequence.charAt(i);
		if (noteProfile.indexOf(s) != -1)
		{
			reqNoteSequence += s;
			if (i + 1 < playedNoteSequence.length)
			{
				s = playedNoteSequence.charAt(i + 1);
				if (s == "#")
					reqNoteSequence += s;
			}
		}
	}
}

public static function showLoginScreen(event:MouseEvent):void
{
	bLoginSubmit.enabled = false;
	pickRandomLoginTune();
	if (badStanding)
		txtTuneCopy.text = "<- Listen Again and Enter";
	else
		txtTuneCopy.text = "<- Listen and Enter";
	myNoteSequence = "";
	mistakeCount = 0;

	activePage = PAGE_LOGIN;
	lMainPage.visible = false;
	lUploadPage.visible = false;
	lLoginPage.visible = true;
	lMessagePage.visible = false;
}

public static function playLoginTune(event:MouseEvent):void
{
	// Stop all sounds.
	Sounds.stopAllChannels();

	// Join prefix and login song; play.
	userStartedPlay = false;
	var s:String = defaultPrefix + playedNoteSequence;
	Sounds.distributePlayNotes(s);
	Sounds.playVoice();
}

public static function backOneNote(event:MouseEvent):void {
	if (myNoteSequence == "")
		return;

	var count:int = 1;
	if (myNoteSequence.substr(myNoteSequence.length - 1, 1) == "#")
		count = 2;

	myNoteSequence = myNoteSequence.substr(0, myNoteSequence.length - count);
	txtTuneCopy.text = txtTuneCopy.text.substr(0, txtTuneCopy.text.length - (count + 1));
}

public static function enterNoteGeneric(note:String):void {
	if (utils.startswith(txtTuneCopy.text, "<- Listen"))
		txtTuneCopy.text = "";

	userStartedPlay = false;
	myNoteSequence += note;
	txtTuneCopy.text = txtTuneCopy.text + note + " ";
	Sounds.distributePlayNotes(defaultPrefix + "S" + note);
	Sounds.playVoice();
}

public static function enterNoteC(event:MouseEvent):void {
	enterNoteGeneric("C");
}
public static function enterNoteCS(event:MouseEvent):void {
	enterNoteGeneric("C#");
}
public static function enterNoteD(event:MouseEvent):void {
	enterNoteGeneric("D");
}
public static function enterNoteDS(event:MouseEvent):void {
	enterNoteGeneric("D#");
}
public static function enterNoteE(event:MouseEvent):void {
	enterNoteGeneric("E");
}
public static function enterNoteF(event:MouseEvent):void {
	enterNoteGeneric("F");
}
public static function enterNoteFS(event:MouseEvent):void {
	enterNoteGeneric("F#");
}
public static function enterNoteG(event:MouseEvent):void {
	enterNoteGeneric("G");
}
public static function enterNoteGS(event:MouseEvent):void {
	enterNoteGeneric("G#");
}
public static function enterNoteA(event:MouseEvent):void {
	enterNoteGeneric("A");
}
public static function enterNoteAS(event:MouseEvent):void {
	enterNoteGeneric("A#");
}
public static function enterNoteB(event:MouseEvent):void {
	enterNoteGeneric("B");
}

public static function loginAction(event:MouseEvent):void {
	//trace(myNoteSequence);
	//trace(reqNoteSequence);

	userStartedPlay = false;
	if (!canLogin)
	{
		showMessage("You must enter a valid\ne-mail address to log in.");
	}
	else if (myNoteSequence == reqNoteSequence && tbLoginEmail.text != "chris@chriskallen.com")
	{
		// Match
		Sounds.distributePlayNotes("Z00P47:@V40K0:0: TCEGC#FG#DF#AD#GA#EG#+C");
		Sounds.playVoice();
		userName = tbLoginEmail.text;
		loggedIn = true;
		loginRefreshTime = mcount + LOGIN_DURATION;
		showUploadScreen(null);
	}
	else if (myNoteSequence == masterMatch)
	{
		// Master key match
		Sounds.distributePlayNotes("Z00P25:@V40K0:0: T+++C-C-C-C-C-C");
		Sounds.playVoice();
		userName = "chris@chriskallen.com";
		loggedIn = true;
		masterKey = true;
		loginRefreshTime = mcount + LOGIN_DURATION;
		showUploadScreen(null);
	}
	else
	{
		// Mistake
		bLoginSubmit.enabled = false;
		bLoginCancel.enabled = false;
		txtTuneCopy.text = "WRONG!";
		mistakeTimeOut = mistakeDelay;
		Sounds.distributePlayNotes(defaultPrefix + "--QC");
		Sounds.playVoice();
	}
}

public static function mistakeReset():void
{
	myNoteSequence = "";
	txtTuneCopy.text = "";
	if (++mistakeCount > MAX_MISTAKE_ALLOWED)
	{
		badStanding = true;
		mistakeDelay *= 2;
		showLoginScreen(null);
	}
}

public static function createNewSong(event:MouseEvent):void
{
	// Update song info with blank fields
	usingExtraSong = true;
	tbTitle.text = "[Enter New Song Title]";
	tbCover.text = "";
	tbAuthor.text = "";
	tbGame.text = "";
	tbYear.text = "";
	tbTags.text = "";
	tbDesc.text = "";
	extraSongObj["contrib"] = "";
	if (shownUpload)
		taUSong.text = "";

	// Select the "new" slot in library
	lbULibrary.selectedIndex = lbULibrary.length - 1;
	loadFromLibrary(null);
	usingExtraSong = true;
}

// Find keyword match.
public static function kwFilterMatch(s:String, fText:String):Boolean {
	var idx:int = s.indexOf(fText);
	if (idx == -1)
		return false;

	// Keyword match favors whole words only.
	var tChars:Array = [0, 0];
	if (idx > 0)
		tChars[0] = s.charCodeAt(idx - 1);
	if (idx + fText.length < s.length)
		tChars[1] = s.charCodeAt(idx + fText.length);

	for (var i:int = 0; i < 2; i++)
	{
		var c:int = tChars[i];
		if (c >= 48 && c <= 57 || c >= 65 && c <= 90 || c >= 97 && c <= 122)
			return false;
	}

	return true;
}

public static function safeText(s:String):String {
	var markupPattern:RegExp = /"/g;
	s = s.replace(markupPattern, "'");
	markupPattern = /\\/g;
	s = s.replace(markupPattern, "");

	return s;
}

public static function cleanZZTOOP(s:String):String {
	// Transform #PLAY into ordinary state reset
	s = (s.split("#PLAY").join("@"));

	// Purge a variety of ZZT-OOP commands that would cause problems
	s = (s.split("\r").join("\n"));

	var idx:int = s.indexOf("\n#");
	while (idx != -1) {
		var idx2:int = s.indexOf("\n", idx + 1);
		if (idx2 == -1)
		{
			// Clip last statement
			s = s.substring(0, idx);
			break;
		}
		else
		{
			// Remove command
			s = s.substring(0, idx) + s.substring(idx2);
			idx = s.indexOf("\n#", idx);
		}
	}

	return s;
}

public static function showMessage(msg:String):void {
	txtMessage.text = msg;
	lMainPage.visible = false;
	lUploadPage.visible = false;
	lLoginPage.visible = false;
	lMessagePage.visible = true;
}

public static function updateSong(event:MouseEvent):void
{
	// Check if required fields present
	uploadMod = true;
	if (tbTitle.text == "" || tbCover.text == "" || tbGame.text == "" ||
		tbYear.text == "" || taUSong.text == "")
	{
		showMessage("These fields are required:\n\n\
  Title\n  Covered By\n  Game\n  Year\n  Song");
		return;
	}

	// Base fields
	var uid:String = (maxUID + 1).toString();
	var title:String = tbTitle.text;
	var cover:String = tbCover.text;
	var author:String = tbAuthor.text;
	var game:String = tbGame.text;
	var year:String = tbYear.text;
	var tags:String = tbTags.text;
	var desc:String = tbDesc.text;
	var song:String =  taUSong.text;
	var contrib:String = userName;

	// Check fields against what is already entered
	partialUpdate = false;
	var unique:Boolean = true;
	var foundIdx:int = lbULibrary.selectedIndex;
	if (lbULibrary.selectedIndex == lbULibrary.length - 1)
	{
		// Use extra song object.
	}
	else if (foundIdx != -1)
	{
		// Select object from library
		unique = false;
		uid = libraryUIDs[foundIdx];
		var lObj:Object = jsonObj[uid];
		if (masterKey || lObj.contrib == userName)
		{
			// Can edit all if original contributor, or master key
		}
		else
		{
			// Find out what can be modified
			title = lObj.title;
			cover = lObj.cover;
			author = lObj.author;
			game = lObj.game;
			year = lObj.year;
			tags = lObj.tags;
			desc = lObj.desc;
			contrib = lObj.contrib;

			song = lObj.song;
			var breakPattern:RegExp = /\r\n/g;
			song = song.replace(breakPattern, "\n");
			breakPattern = /\r/g;
			song = song.replace(breakPattern, "\n");

			// Only some of original can be modified, if blank
			if (author == "" || author == "?")
			{
				partialUpdate = true;
				author = tbAuthor.text;
			}
			if (tags == "" || tags == "?")
			{
				partialUpdate = true;
				tags = tbTags.text;
			}
			if (desc == "" || desc == "?")
			{
				partialUpdate = true;
				desc = tbDesc.text;
			}

			if (!partialUpdate)
			{
				showMessage("Unable to modify this entry.\n\n\
You are not the original contributor.");
				return;
			}
		}
	}

	// Create package for submittal
	var newSubmission:String = "\"" + uid +
		"\":{\n\"title\":\"" + safeText(title) + "\",\n\"cover\":\"" + safeText(cover) +
		"\",\n\"author\":\"" + safeText(author) + "\",\n\"game\":\"" + safeText(game) +
		"\",\n\"year\":\"" + safeText(year) + "\",\n\"tags\":\"" + safeText(tags) +
		"\",\n\"desc\":\"" + safeText(desc) + "\",\n\"contrib\":\"" + safeText(contrib) +
		"\",\n\"song\":\"" + safeText(song) + "\"\n},\n\n";
	//trace(newSubmission);
	submitSong("guis/submit_song.php", newSubmission, unique);
	//submitSong("http://www.chriskallen.com/zzt/guis/submit_song.php", newSubmission, unique);
}

public static function closeMessage(event:MouseEvent):void {
	if (activePage == PAGE_UPLOAD)
	{
		lMainPage.visible = false;
		lUploadPage.visible = true;
		lLoginPage.visible = false;
		lMessagePage.visible = false;
	}
	else if (activePage == PAGE_LOGIN)
	{
		lMainPage.visible = false;
		lUploadPage.visible = false;
		lLoginPage.visible = true;
		lMessagePage.visible = false;
	}
}

public static function playSong(event:MouseEvent):void {
	basicPlaySong();
}

public static function basicPlaySong(useLooping:Boolean=false):void {

	// Signal restart if any sounds are still playing.
	Sounds.stopAllChannels();

	// Join prefix and main song text; play.
	var prefix:String = tbPrefix.text;
	var s:String;
	var scr:ScrollBar;
	if (activePage == PAGE_MAIN)
	{
		s = taSong.text;
		scr = scrTimeline;
	}
	else
	{
		s = taUSong.text;
		scr = scrUTimeline;
	}

	// If the user posted a #PLAY statement, change to @.
	s = cleanZZTOOP(s.toUpperCase());

	// TBD:  Purge other ZZT-OOP commands that would disrupt operations.

	// Set scrollbar info and max time from samples time.
	s = prefix + s;
	songDuration = calcSamplesTime(s);
	var oldPos:Number = scr.scrollPosition;
	scr.maxScrollPosition = songDuration;
	scr.pageSize = songDuration / 25.0;
	setTimeValue(txtMaxTime, songDuration);

	if (userSetMiddlePlay)
	{
		// User had set a middle position (from a pause or manual
		// scrollbar adjustment).  Modify string accordingly.
		runningTicks = msTime2Ticks(middleMSTime);
		s = createMiddlePlayString(prefix, s, middleMSTime);
		userSetMiddlePlay = false;
	}
	else
	{
		// Start song from the beginning.
		runningTicks = 0;
		scr.scrollPosition = oldPos;
	}

	// Start playing notes.
	loopingActive = useLooping;
	loopingPosted = false;
	userStartedPlay = true;
	userPausedPlay = false;
	Sounds.distributePlayNotes(s);
	Sounds.playVoice();
}

public static function loopPlaySong(event:MouseEvent):void
{
	if (userStartedPlay && !userPausedPlay && Sounds.isAnyChannelPlaying())
		loopingActive = true;
	else
		basicPlaySong(true);
}

public static function pauseSong(event:MouseEvent):void
{
	if (userStartedPlay && userPausedPlay)
	{
		// Treat as unpause if already playing.
		basicPlaySong();
		return;
	}

	// Log middle position of song.
	userPausedPlay = true;
	userSetMiddlePlay = true;
	loopingActive = false;
	loopingPosted = false;
	middleMSTime = ticks2MSTime(runningTicks);

	// Stop all channels.
	Sounds.stopAllChannels();
}

public static function modScrollTimeline(event:ScrollEvent):void
{
	// Any scroll event that happens during playback is assumed to be as a result
	// of the timer routine.  Do not log a user-set middle position.
	if (userStartedPlay && !userPausedPlay && Sounds.isAnyChannelPlaying())
	{
		userSetMiddlePlay = false;
		return;
	}

	// Assume user modified scroll position to set the timeline manually.
	if (songDuration > 0.0)
	{
		var scr:ScrollBar = (activePage == PAGE_MAIN) ? scrTimeline : scrUTimeline;
		middleMSTime = samples2MSTime(scr.scrollPosition);
		setTimeValue(txtCurTime, scr.scrollPosition);
		userSetMiddlePlay = true;
	}
	else
	{
		userSetMiddlePlay = false;
	}
}

public static function stopSong(event:MouseEvent):void
{
	// Clear playing status.
	userStartedPlay = false;
	userPausedPlay = false;
	userSetMiddlePlay = false;
	loopingActive = false;
	loopingPosted = false;
	middleMSTime = 0.0;

	var scr:ScrollBar = (activePage == PAGE_MAIN) ? scrTimeline : scrUTimeline;
	scr.scrollPosition = 0.0;
	setTimeValue(txtCurTime, 0.0);

	// Stop all channels.
	Sounds.stopAllChannels();
}

public static function setMasterVolume(event:Event):void
{
	// Set master volume.
	Sounds.setMasterVolume(int(sbMainVolume.value));
}

public static function loadSongLibrary():void {
	var randNum:int = utils.randrange(0, 65536);
	loadTextFile("guis/song_library.txt");
	//loadTextFile("guis/song_library.php?rand=" + randNum.toString());
}

public static function setupLibrary():Boolean {
	if (!loadingSuccess)
		return false;

	// Load object with sorted key order
	var altLibraryUIDs:Array = []
	var altLibraryNames:Array = [];
	var kObj:Object;
	for (kObj in jsonObj)
	{
		var uid:String = kObj.toString();
		var uidNum:int = int(uid);
		var lName:String = jsonObj[uid]["title"].toString();
		if (lName != "dummy")
		{
			altLibraryUIDs.push(uid);
			altLibraryNames.push(lName);
			if (maxUID < uidNum)
				maxUID = uidNum;
		}
	}

	// Ensure library UIDs and names are properly sorted
	var sortOrder:Array = altLibraryNames.sort(Array.RETURNINDEXEDARRAY);
	libraryUIDs = [];
	libraryNames = [];
	for (var j:int = 0; j < sortOrder.length; j++) {
		libraryUIDs.push(altLibraryUIDs[sortOrder[j]]);
		libraryNames.push(altLibraryNames[sortOrder[j]]);
	}

	// Populate list with appropriate filter
	return (populateLibraryList());
}

public static function populateLibraryList(fText:String=""):Boolean {
	// Populate library list box with filtered entries
	libraryChanging = true;
	libraryDisp = [];
	lbLibrary.removeAll();
	lbULibrary.removeAll();

	for (var i:int = 0; i < libraryNames.length; i++) {
		var name:String = libraryNames[i];
		var uid:String = libraryUIDs[i];
		var entry:Object = jsonObj[uid];
		var useEntry:Boolean = false;

		// If filter text is empty, show all entries.
		if (fText == "")
			useEntry = true;
		else
		{
			// Entry is used only if keyword match(es) are present.
			useEntry =
				kwFilterMatch(name, fText) ||
				kwFilterMatch(entry.cover, fText) ||
				kwFilterMatch(entry.author, fText) ||
				kwFilterMatch(entry.game, fText) ||
				kwFilterMatch(entry.tags, fText) ||
				kwFilterMatch(entry.desc, fText);
		}

		if (useEntry)
		{
			var o:Object = new Object();
			o["label"] = name;
			o["data"] = null;
			lbLibrary.addItem(o);
			lbULibrary.addItem(o);
			libraryDisp.push(entry);
		}
	}

	libraryChanging = false;
	return true;
}

// Find index of title within either the entire list or the filtered list.
public static function findInLibrary(title:String, fromFilteredList:Boolean):int {
	if (fromFilteredList)
	{
		for (var i:int = 0; i < libraryDisp.length; i++) {
			if (libraryDisp[i].title == title)
				return i;
		}
	}
	else
	{
		return (libraryNames.indexOf(title));
	}

	return -1;
}

public static function loadFromLibrary(event:Event):void {
	var i:int = -1;
	if (activePage == PAGE_MAIN)
		i = lbLibrary.selectedIndex;
	else
	{
		uploadMod = true;
		i = lbULibrary.selectedIndex;

		// Update the "new" song fields if necessary
		if (usingExtraSong)
			updateExtraSongObj();

		usingExtraSong = Boolean(i == lbULibrary.length - 1);
	}

	if (libraryChanging || (i < 0 || i >= libraryDisp.length))
		return;

	// Select object from library
	lObj = libraryDisp[i];

	// Populate information from library entry
	var title:String = lObj.title;
	var cover:String = lObj.cover;
	var author:String = lObj.author;
	var game:String = lObj.game;
	var year:String = lObj.year;
	var tags:String = lObj.tags;
	var desc:String = lObj.desc;
	var contrib:String = lObj.contrib;
	var song:String = lObj.song as String;

	// Ensure song has only one type of line break
	var breakPattern:RegExp = /\r\n/g;
	song = song.replace(breakPattern, "\n");
	breakPattern = /\r/g;
	song = song.replace(breakPattern, "\n");

	if (activePage == PAGE_MAIN)
	{
		var infoStr:String = title + "\n" + cover + "\n" + author + "\n" + game +
			"\n" + year + "\n" + tags + "\n" + desc;
		txtSongInfo.text = infoStr;
		taSong.text = song;
	}
	else
	{
		tbTitle.text = title;
		tbCover.text = cover;
		tbAuthor.text = author;
		tbGame.text = game;
		tbYear.text = year;
		tbTags.text = tags;
		tbDesc.text = desc;
		txtContrib.text = "Contributor:  " + contrib;
		taUSong.text = song;
	}

	// Capture song length and other info
	if (!userStartedPlay || userPausedPlay || !Sounds.isAnyChannelPlaying())
	{
		userStartedPlay = false;
		userPausedPlay = false;
		userSetMiddlePlay = false;

		var scr:ScrollBar = (activePage == PAGE_MAIN) ? scrTimeline : scrUTimeline;
		songDuration = calcSamplesTime((tbPrefix.text + song).toUpperCase());
		scr.maxScrollPosition = songDuration;
		scr.pageSize = songDuration / 25.0;
		scr.scrollPosition = 0.0;
		setTimeValue(txtMaxTime, songDuration);
		setTimeValue(txtCurTime, 0.0);
	}
}

public static function updateExtraSongObj():void {
	extraSongObj["title"] = tbTitle.text;
	extraSongObj["cover"] = tbCover.text;
	extraSongObj["author"] = tbAuthor.text;
	extraSongObj["game"] = tbGame.text;
	extraSongObj["year"] = tbYear.text;
	extraSongObj["tags"] = tbTags.text;
	extraSongObj["desc"] = tbDesc.text;
	extraSongObj["song"] = taUSong.text;
}

public static function changeFilter(event:Event):void {
	if (activePage != PAGE_MAIN)
		return;

	// Get filter selection
	var i:int = cbFilter.selectedIndex;
	var fText:String = SongFilters.allFilters[i];
	if (fText == "[No Filter]" || utils.startswith(fText, "--"))
		fText = "";

	populateLibraryList(fText);
}

public static function loadTextFile(filename:String):void {
	loadingName = filename;
	myLoader = null;
	loadingSuccess = false;

	try {
		myLoader = new URLLoader(new URLRequest(filename));
	}
	catch (e:Error)
	{
		trace("ERROR:  " + e);
		return;
	}

	myLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
	myLoader.addEventListener(Event.COMPLETE, loaderCompleteHandler);
}

public static function submitSong(filename:String, info:String, isNew:Boolean):void {
	loadingName = filename;
	myLoader = null;
	loadingSuccess = false;

	var urlVars:URLVariables = new URLVariables();
	urlVars.submission = info;
	urlVars.isnew = (isNew ? "1" : "0");
	var hashInt:int = 13291797;
	//trace(info.length);
	for (var i:int = 0; i < info.length; i++) {
		var c:int = info.charCodeAt(i);
		hashInt = ((c * 71) + hashInt) & 1073741823;
		//trace(hashInt);
	}
	hashInt ^= info.length;
	//trace(hashInt);
	urlVars.hash = hashInt.toString();
	//trace(urlVars);

	var req:URLRequest = new URLRequest(filename);
	req.method = URLRequestMethod.POST;
	req.contentType = "application/x-www-form-urlencoded";
	req.data = urlVars;
	//trace(req);

	try {
		myLoader = new URLLoader(req);
	}
	catch (e:Error)
	{
		trace("ERROR:  " + e);
		return;
	}

	myLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
	myLoader.addEventListener(Event.COMPLETE, submitCompleteHandler);
}

public static function errorHandler(e:IOErrorEvent):void {
	trace("IO ERROR:  " + e);
	showMessage("IO ERROR:  " + e);
}

public static function loaderCompleteHandler(event:Event):void {
	// Load song dataset
	dataset = myLoader.data;
	try {
		jsonObj = JSON.decode(dataset, false);
	}
	catch (e:Error)
	{
		trace("ERROR:  " + e);
		return;
	}

	// Update library
	loadingSuccess = true;
	setupLibrary();

	// Set initial list filter, if one provided.
	if (initFilterName != "")
	{
		populateLibraryList(initFilterName);
		initFilterName = "";
	}

	if (initPlaySongName != "")
	{
		// Play initial song if name indicated in URL
		var i:int = findInLibrary(initPlaySongName, false);
		var li:int = findInLibrary(initPlaySongName, true);
		if (i != -1)
		{
			lbLibrary.selectedIndex = li;
			loadFromLibrary(null);

			if (initStartTime > 0.0)
			{
				userSetMiddlePlay = true;
				middleMSTime = initStartTime * 1000.0;
			}

			basicPlaySong(Boolean(initLoopPlay != 0));
		}

		initPlaySongName = "";
	}
}

public static function submitCompleteHandler(event:Event):void {
	dataset = myLoader.data;
	try {
		jsonObj = JSON.decode(dataset, false);
	}
	catch (e:Error)
	{
		trace("ERROR:  " + e);
		return;
	}

	loadingSuccess = true;
	setupLibrary();

	if (partialUpdate)
		showMessage("Entry partially updated (filled in missing fields).");
	else
		showMessage("Submitted entry to library.");
}

public static function jsonToText(jObj:Object, lineBreaks:Boolean=false, sorted:Boolean=false):String {
	try {
		if (sorted)
		{
			// Sort all keys alphabetically, with periodic line breaks
			var s:String = getSortedObject(jObj);
			return s;
		}
		else if (lineBreaks)
		{
			// Insert line breaks between , and "
			s = JSON.encode(jObj);
			while (s.search(",\"") != -1)
				s = s.replace(",\"", ",\n\"");

			return s;
		}
		else
		{
			// No line breaks; has no whitespace worth a mention between items.
			return JSON.encode(jObj);
		}
	}
	catch (e:Error)
	{
		trace("ERROR:  " + e);
	}

	return "";
}

public static function getSortedObject(jObj:Object):String {
	// Get sort order of main keys.
	var mainKeys:Array = [];
	var kObj:Object;
	for (kObj in jObj)
		mainKeys.push(kObj.toString());

	var sortOrder:Array = mainKeys.sort(Array.RETURNINDEXEDARRAY);

	// Piece together sorted version of object.
	var allStr:String = "{";
	for (var i:int = 0; i < sortOrder.length; i++) {
		var thisKey:String = mainKeys[sortOrder[i]];
		var thisVal:Object = jObj[thisKey];
		if (thisKey == "KeyInput" || thisKey == "Label")
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

public static function mTick(event:TimerEvent):void
{
	// Master counter
	mcount++;

	// Reset action suspension after delay.
	if (mistakeTimeOut > 0)
	{
		mistakeTimeOut--;
		if (mistakeTimeOut == 0)
		{
			mistakeReset();
		}

		return;
	}

	if ((activePage == PAGE_MAIN || activePage == PAGE_UPLOAD) &&
		Sounds.isAnyChannelPlaying() && userStartedPlay && !userPausedPlay)
	{
		// Update scrollbar and current time while playing.
		var scr:ScrollBar = (activePage == PAGE_MAIN) ? scrTimeline : scrUTimeline;
		var curPos:Number = msTime2Samples(ticks2MSTime(++runningTicks));
		scr.scrollPosition = curPos;
		setTimeValue(txtCurTime, curPos);

		// If looping is active, post the notes again when conditions are satisfied.
		if (loopingActive)
		{
			if (curPos >= songDuration)
			{
				// Wrap scrollbar and ticks accordingly after limit reached.
				curPos -= songDuration;
				runningTicks = msTime2Ticks(samples2MSTime(curPos));
				loopingPosted = false;
			}
			else if (!loopingPosted && samples2MSTime(songDuration - curPos) <= 2000.0)
			{
				// Post notes.
				loopingPosted = true;

				var s:String = (activePage == PAGE_MAIN) ? taSong.text : taUSong.text;
				s = cleanZZTOOP(s.toUpperCase());
				Sounds.distributePlayNotes(tbPrefix.text + s);
				Sounds.playVoice();
			}
		}
	}

	if (activePage == PAGE_LOGIN && (mcount & 7) == 0)
	{
		// Login button is activated only when valid e-mail address is recognized.
		canLogin = false;
		var atAt:int = tbLoginEmail.text.indexOf("@");
		if (atAt > 0 && atAt < tbLoginEmail.text.length - 1)
			canLogin = true;

		bLoginCancel.enabled = true;
		bLoginSubmit.enabled = true;
	}
}

// This sets the tempo for all channels.
public static function updateAllTempo(tempoMultiplier:Number):void {
	for (var i:int = 0; i < Sounds.NUM_CHANNELS; i++)
		chanTempoMultiplier[i] = tempoMultiplier;
}

// Samples and millisecond conversion functions
public static function samples2MSTime(sTime:Number):Number {
	return (sTime * 1000.0 / FxEnvelope.SR);
}
public static function msTime2Samples(msTime:Number):Number {
	return (msTime * FxEnvelope.SR / 1000.0);
}
public static function ticks2MSTime(tTime:Number):Number {
	return (tTime * 1000.0 / 30.0);
}
public static function msTime2Ticks(msTime:Number):Number {
	return (msTime * 30.0 / 1000.0);
}

// Set a text field with time value information.
public static function setTimeValue(destField:TextField, sTime:Number):void {
	// Get breakdown
	var secTime:Number = samples2MSTime(sTime) / 1000.0;
	var minutes:int = int(secTime / 60.0);
	var seconds:int = int(secTime - minutes * 60);
	var fracs:Number = secTime - (minutes * 60) - seconds;

	// Piece together string
	var s:String = "" + minutes + ":";
	if (seconds >= 10)
		s += seconds;
	else
		s += "0" + seconds;

	var sf:String = String(fracs);
	var dpIdx:int = sf.indexOf(".");
	if (dpIdx != -1)
	{
		sf += "000";
		sf = sf.substr(dpIdx, 4);
	}
	else
		sf = ".000";

	s += sf;
	destField.text = s;
}

// Calculate the total time, in samples, allocated to a specific string.
public static function calcSamplesTime(pString:String):Number {

	// Current channel being parsed
	var curChannel:int = lastChannel;

	// Tempo multiplier for current channel
	var tempoMultiplier:Number = lastTempoMultiplier;
	updateAllTempo(tempoMultiplier);

	// Note duration for current channel in samples
	var curDuration:Number = lastDuration;

	// Total duration of channel in samples
	var chanDuration:Number = 0.0;
	for (var i:int = 0; i < Sounds.NUM_CHANNELS; i++) {
		chanDurations[i] = 0.0;
	}

	var idx:int = 0;
	var pos:int = 0;
	var tempoPos:int = 0;

	while (pos < pString.length) {
		var c:String = pString.charAt(pos);
		switch (c) {
			// Log note duration
			case "C":
			case "D":
			case "E":
			case "F":
			case "G":
			case "A":
			case "B":
			case "0":
			case "1":
			case "2":
			case "4":
			case "5":
			case "6":
			case "7":
			case "8":
			case "9":
			case "X":
				chanDuration += curDuration;
				pos++;
			break;

			// Change duration for subsequent notes
			case "W":
				pos++;
				curDuration = FxEnvelope.W1_DURATION * tempoMultiplier;
			break;
			case "H":
				pos++;
				curDuration = FxEnvelope.H1_DURATION * tempoMultiplier;
			break;
			case "Q":
				pos++;
				curDuration = FxEnvelope.Q1_DURATION * tempoMultiplier;
			break;
			case "I":
				pos++;
				curDuration = FxEnvelope.I1_DURATION * tempoMultiplier;
			break;
			case "S":
				pos++;
				curDuration = FxEnvelope.S1_DURATION * tempoMultiplier;
			break;
			case "T":
				pos++;
				curDuration = FxEnvelope.T1_DURATION * tempoMultiplier;
			break;
			case "J":
				pos++;
				curDuration = FxEnvelope.T64_DURATION * tempoMultiplier;
			break;
			case "@":
				pos++;
				curDuration = FxEnvelope.T1_DURATION;
			break;
			case ".":
				pos++;
				curDuration *= 1.5;
			break;
			case "3":
				pos++;
				curDuration *= 0.3333333333;
			break;

			// Control codes must be skipped; timing not affected
			case "P":
			case "V":
				pos += 3;
			break;
			case "R":
				idx = pString.indexOf(":", pos);
				if (idx != -1)
					pos = idx + 1;
				else
					pos++;
			break;
			case "K":
				pos++;
				if (pos + 5 <= pString.length)
				{
					idx = pString.indexOf(":", pos + 3);
					if (idx != -1)
						pos = idx + 1;
				}
			break;

			// Channel change and tempo change will affect timing
			case "Z":
				chanDurations[curChannel] = chanDuration;
				chanTempoMultiplier[curChannel] = tempoMultiplier;
				pos++;
				if (pos + 2 <= pString.length)
				{
					// Change target channel
					curChannel = intFrom2D(pString, pos, 0);
					chanDuration = chanDurations[curChannel];
					tempoMultiplier = chanTempoMultiplier[curChannel];
					pos += 2;
				}
			break;
			case "U":
				pos++;
				if (pos + 3 <= pString.length)
				{
					tempoPos = intFrom3D(pString, pos, -1);
					if (tempoPos > 0)
					{
						// Adjust tempo multiplier
						pos += 3;
						tempoMultiplier = FxEnvelope.ASSUMED_TEMPO / tempoPos;
	
						// If colon present at end, only current channel tempo is affected.
						if (pos >= pString.length)
							updateAllTempo(tempoMultiplier);
						else if (pString.charAt(pos) != ":")
							updateAllTempo(tempoMultiplier);
						else
							pos++;
					}
				}
			break;

			default:
				pos++;
			break;
		}
	}

	// Finalize channel durations, times, etc.
	chanDurations[curChannel] = chanDuration;
	chanTempoMultiplier[curChannel] = tempoMultiplier;
	lastChannel = curChannel;
	lastTempoMultiplier = tempoMultiplier;
	lastDuration = curDuration;

	// Find the "overall" duration based on the maximum of all channels.
	var overallTime:Number = 0.0;
	for (i = 0; i < Sounds.NUM_CHANNELS; i++) {
		if (overallTime < chanDurations[i])
			overallTime = chanDurations[i];
	}

	// In addition to the overall time, chanDurations reports the time
	// allocated to each channel individually.
	return overallTime;
}

// Create an alternate play string based upon a partial milliseconds advancement.
public static function createMiddlePlayString(prefix:String, pString:String, msTime:Number):String {

	// Convert starting milliseconds to sample time; early-out if at beginning or end.
	var sLimit:Number = msTime2Samples(msTime);
	if (sLimit <= 0.0)
		return pString;
	else if (sLimit >= songDuration)
		return "";

	// Current channel being parsed
	var curChannel:int = lastChannel;

	// Tempo multiplier for current channel
	var tempoMultiplier:Number = lastTempoMultiplier;
	updateAllTempo(tempoMultiplier);

	// Note duration for current channel in samples
	var curDuration:Number = lastDuration;

	// Total duration of channel in samples
	var chanDuration:Number = 0.0;
	for (var i:int = 0; i < Sounds.NUM_CHANNELS; i++) {
		chanDurations[i] = 0.0;
		chanStrings[i] = "";
		chanDone[i] = false;
	}

	// We will add prefix back to composite string later.
	pString = pString.substr(prefix.length);

	// The loop iteration stops when a single channel's duration
	// steps beyond the sample limit or falls within a tolerance of exact.
	var idx:int = 0;
	var pos:int = 0;
	var tempoPos:int = 0;
	var restAdder:String = "";

	while (pos < pString.length) {
		var c:String = pString.charAt(pos);
		switch (c) {
			// Log note duration
			case "C":
			case "D":
			case "E":
			case "F":
			case "G":
			case "A":
			case "B":
			case "0":
			case "1":
			case "2":
			case "4":
			case "5":
			case "6":
			case "7":
			case "8":
			case "9":
			case "X":
				// If channel starting position already found, add note.
				pos++;
				if (chanDone[curChannel])
				{
					chanStrings[curChannel] += c;
					break;
				}

				// Otherwise, add to overall duration count.
				chanDuration += curDuration;

				// If the target duration falls within tolerance,
				// we have found the starting point.
				if (Math.abs(chanDuration - sLimit) <=
					FxEnvelope.T64_DURATION * tempoMultiplier * 0.25)
				{
					// Downstream notes will be logged.
					chanDone[curChannel] = true;
				}
				else if (chanDuration >= sLimit)
				{
					// This happens when the note overshoots the starting point.
					// We can't play a fraction of a note, so we insert rests
					// to make up the difference.
					restAdder = ":J";
					while (chanDuration > sLimit &&
						Math.abs(chanDuration - sLimit) >
						FxEnvelope.T64_DURATION * tempoMultiplier * 0.25)
					{
						restAdder += "X";
						chanDuration -= FxEnvelope.T64_DURATION * tempoMultiplier;
					}

					// We prefix the entire channel's note sequence with the rests
					// so that the starting point is aligned properly.
					var chanPrefix:String = "Z" + utils.twogrouping(curChannel) + "U" +
						utils.threegrouping(int(FxEnvelope.ASSUMED_TEMPO / tempoMultiplier)) +
						restAdder;
					chanStrings[curChannel] = chanPrefix + chanStrings[curChannel];
					chanDone[curChannel] = true;
				}
			break;

			// Change duration for subsequent notes
			case "W":
				pos++;
				curDuration = FxEnvelope.W1_DURATION * tempoMultiplier;
				chanStrings[curChannel] += c;
			break;
			case "H":
				pos++;
				curDuration = FxEnvelope.H1_DURATION * tempoMultiplier;
				chanStrings[curChannel] += c;
			break;
			case "Q":
				pos++;
				curDuration = FxEnvelope.Q1_DURATION * tempoMultiplier;
				chanStrings[curChannel] += c;
			break;
			case "I":
				pos++;
				curDuration = FxEnvelope.I1_DURATION * tempoMultiplier;
				chanStrings[curChannel] += c;
			break;
			case "S":
				pos++;
				curDuration = FxEnvelope.S1_DURATION * tempoMultiplier;
				chanStrings[curChannel] += c;
			break;
			case "T":
				pos++;
				curDuration = FxEnvelope.T1_DURATION * tempoMultiplier;
				chanStrings[curChannel] += c;
			break;
			case "J":
				pos++;
				curDuration = FxEnvelope.T64_DURATION * tempoMultiplier;
				chanStrings[curChannel] += c;
			break;
			case "@":
				pos++;
				curDuration = FxEnvelope.T1_DURATION;
				chanStrings[curChannel] += c;
			break;
			case ".":
				pos++;
				curDuration *= 1.5;
				chanStrings[curChannel] += c;
			break;
			case "3":
				pos++;
				curDuration *= 0.3333333333;
				chanStrings[curChannel] += c;
			break;

			// Control codes must be skipped; timing not affected
			case "P":
			case "V":
				chanStrings[curChannel] += pString.substr(pos, 3);
				pos += 3;
			break;
			case "R":
				idx = pString.indexOf(":", pos);
				if (idx != -1)
				{
					chanStrings[curChannel] += pString.substring(pos, idx + 1);
					pos = idx + 1;
				}
				else
					pos++;
			break;
			case "K":
				pos++;
				if (pos + 5 <= pString.length)
				{
					idx = pString.indexOf(":", pos + 3);
					if (idx != -1)
					{
						chanStrings[curChannel] += pString.substring(pos - 1, idx + 1);
						pos = idx + 1;
					}
				}
			break;

			// Channel change and tempo change will affect timing
			case "Z":
				chanDurations[curChannel] = chanDuration;
				chanTempoMultiplier[curChannel] = tempoMultiplier;
				pos++;
				if (pos + 2 <= pString.length)
				{
					// Change target channel
					curChannel = intFrom2D(pString, pos, 0);
					chanDuration = chanDurations[curChannel];
					chanStrings[curChannel] += pString.substr(pos - 1, 3);
					tempoMultiplier = chanTempoMultiplier[curChannel];
					pos += 2;
				}
			break;
			case "U":
				pos++;
				if (pos + 3 <= pString.length)
				{
					tempoPos = intFrom3D(pString, pos, -1);
					if (tempoPos > 0)
					{
						// Adjust tempo multiplier
						chanStrings[curChannel] += pString.substr(pos - 1, 4);
						pos += 3;
						tempoMultiplier = FxEnvelope.ASSUMED_TEMPO / tempoPos;

						// If colon present at end, only current channel tempo is affected.
						if (pos >= pString.length)
							updateAllTempo(tempoMultiplier);
						else if (pString.charAt(pos) != ":")
							updateAllTempo(tempoMultiplier);
						else
						{
							chanStrings[curChannel] += ":";
							pos++;
						}
					}
				}
			break;

			default:
				chanStrings[curChannel] += c;
				pos++;
			break;
		}
	}

	// Synth a new string from the modified individual channel strings.
	var newString:String = prefix;
	for (i = 0; i < Sounds.NUM_CHANNELS; i++) {
		newString += chanStrings[i];
	}

	return newString;
}

public static function intFrom2D(s:String, start:int, defInt:int=0):int {
	return utils.intMaybe(s.substr(start, 2), defInt);
}

public static function intFrom3D(s:String, start:int, defInt:int=0):int {
	return utils.intMaybe(s.substr(start, 3), defInt);
}

};
};

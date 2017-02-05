// oop.as:  The program's OOP compiling functions.

package {
public class oop {

import flash.geom.*;
import flash.text.*;

// Command constants (non-#)
public static const CMD_ERROR:int = 0;
public static const CMD_NAME:int = 255;
public static const CMD_LABEL:int = 254;
public static const CMD_COMMENT:int = 253;
public static const CMD_TEXT:int = 252;
public static const CMD_TEXTCENTER:int = 251;
public static const CMD_TEXTLINK:int = 250;
public static const CMD_TEXTLINKFILE:int = 249;
public static const CMD_TRYSIMPLE:int = 248;
public static const CMD_SENDTONAME:int = 247;
public static const CMD_FORITER:int = 246;
public static const CMD_NOP:int = 245;
public static const CMD_ZAPTARGET:int = 244;
public static const CMD_RESTORETARGET:int = 243;
public static const CMD_FALSEJUMP:int = 242;

// Original ZZT-OOP command constants (#)
public static const CMD_GO:int = 1;
public static const CMD_TRY:int = 2;
public static const CMD_WALK:int = 3;
public static const CMD_DIE:int = 4;
public static const CMD_ENDGAME:int = 5;
public static const CMD_SEND:int = 6;
public static const CMD_RESTART:int = 7;
public static const CMD_END:int = 8;
public static const CMD_BIND:int = 9;
public static const CMD_BECOME:int = 10;
public static const CMD_CHANGE:int = 11;
public static const CMD_PUT:int = 12;
public static const CMD_CHAR:int = 13;
public static const CMD_CYCLE:int = 14;
public static const CMD_CLEAR:int = 15;
public static const CMD_SET:int = 16;
public static const CMD_GIVE:int = 17;
public static const CMD_TAKE:int = 18;
public static const CMD_IF:int = 19;
public static const CMD_LOCK:int = 20;
public static const CMD_UNLOCK:int = 21;
public static const CMD_ZAP:int = 22;
public static const CMD_RESTORE:int = 23;
public static const CMD_SHOOT:int = 24;
public static const CMD_THROWSTAR:int = 25;
public static const CMD_PLAY:int = 26;
public static const CMD_IDLE:int = 27;

// "New" ZZT-OOP command constants as follows

// Flow control and messaging command constants
public static const CMD_PAUSE:int = 30;
public static const CMD_UNPAUSE:int = 31;
public static const CMD_EXTRATURNS:int = 32;
public static const CMD_DONEDISPATCH:int = 33;
public static const CMD_DISPATCH:int = 34;
public static const CMD_SENDTO:int = 35;
public static const CMD_DISPATCHTO:int = 36;
public static const CMD_SWITCHTYPE:int = 37;
public static const CMD_SWITCHVALUE:int = 38;
public static const CMD_EXECCOMMAND:int = 39;

// Region manipulation command constants
public static const CMD_SETREGION:int = 40;
public static const CMD_CLEARREGION:int = 41;

// Character/Color update command constants
public static const CMD_CHAR4DIR:int = 50;
public static const CMD_COLOR:int = 51;
public static const CMD_COLORALL:int = 52;
public static const CMD_DRAWCHAR:int = 53;
public static const CMD_ERASECHAR:int = 54;
public static const CMD_GHOST:int = 55;
public static const CMD_KILLPOS:int = 56;

// Movement/Pushing command constants
public static const CMD_SETPOS:int = 60;
public static const CMD_FORCEGO:int = 61;
public static const CMD_PUSHATPOS:int = 62;

public static const CMD_GROUPSETPOS:int = 63;
public static const CMD_GROUPGO:int = 64;
public static const CMD_GROUPTRY:int = 65;
public static const CMD_GROUPTRYNOPUSH:int = 66;

// Dynamic text and link command constants
public static const CMD_DYNTEXT:int = 70;
public static const CMD_DYNLINK:int = 71;
public static const CMD_DYNTEXTVAR:int = 72;
public static const CMD_DUMPSE:int = 73;
public static const CMD_DUMPSEAT:int = 74;
public static const CMD_TEXTTOGUI:int = 75;
public static const CMD_TEXTTOGRID:int = 76;
public static const CMD_SCROLLSTR:int = 77;
public static const CMD_SCROLLCOLOR:int = 78;

// Set/Get special command constants
public static const CMD_SETPLAYER:int = 80;
public static const CMD_SETPROPERTY:int = 81;
public static const CMD_GETPROPERTY:int = 82;
public static const CMD_PLAYERINPUT:int = 83;
public static const CMD_TYPEAT:int = 84;
public static const CMD_COLORAT:int = 85;
public static const CMD_OBJAT:int = 86;
public static const CMD_LITAT:int = 87;
public static const CMD_RANDOM:int = 88;
public static const CMD_DIR2UVECT8:int = 89;
public static const CMD_OFFSETBYDIR:int = 90;
public static const CMD_SUBSTR:int = 91;
public static const CMD_INT:int = 92;
public static const CMD_ATAN2:int = 93;
public static const CMD_SMOOTHTEST:int = 94;
public static const CMD_SMOOTHMOVE:int = 95;
public static const CMD_READKEY:int = 96;
public static const CMD_READMOUSE:int = 97;
public static const CMD_SETTYPEINFO:int = 98;
public static const CMD_GETTYPEINFO:int = 99;

// Placement command constants
public static const CMD_SPAWN:int = 100;
public static const CMD_SPAWNGHOST:int = 101;
public static const CMD_CHANGEREGION:int = 102;
public static const CMD_CLONE:int = 103;

// Loop iteration command constants
public static const CMD_FOREACH:int = 110;
public static const CMD_FORMASK:int = 111;
public static const CMD_FORNEXT:int = 112;
public static const CMD_FORREGION:int = 113;

// Viewport update command constants
public static const CMD_UPDATEVIEWPORT:int = 120;
public static const CMD_ERASEVIEWPORT:int = 121;
public static const CMD_DISSOLVEVIEWPORT:int = 122;
public static const CMD_SCROLLTOVISUALS:int = 123;
public static const CMD_CAMERAFOCUS:int = 124;
public static const CMD_LIGHTEN:int = 125;
public static const CMD_DARKEN:int = 126;
public static const CMD_UPDATELIT:int = 127;
public static const CMD_SUSPENDDISPLAY:int = 128;

// GUI update command constants
public static const CMD_USEGUI:int = 130;
public static const CMD_SETGUILABEL:int = 131;
public static const CMD_SELECTPEN:int = 132;
public static const CMD_DRAWPEN:int = 133;
public static const CMD_DRAWBAR:int = 134;
public static const CMD_CONFMESSAGE:int = 135;
public static const CMD_TEXTENTRY:int = 136;
public static const CMD_DRAWGUICHAR:int = 137;
public static const CMD_ERASEGUICHAR:int = 138;
public static const CMD_MODGUILABEL:int = 139;

// Game world/board management command constants
public static const CMD_SAVEBOARD:int = 140;
public static const CMD_CHANGEBOARD:int = 141;
public static const CMD_SAVEWORLD:int = 142;
public static const CMD_LOADWORLD:int = 143;
public static const CMD_RESTOREGAME:int = 144;

// Sound command constants
public static const CMD_PLAYSOUND:int = 150;
public static const CMD_GETSOUND:int = 151;
public static const CMD_STOPSOUND:int = 152;
public static const CMD_MASTERVOLUME:int = 153;

// Array command constants
public static const CMD_PUSHARRAY:int = 160;
public static const CMD_POPARRAY:int = 161;
public static const CMD_SETARRAY:int = 162;
public static const CMD_LEN:int = 163;

// Config vars command constants
public static const CMD_SETCONFIGVAR:int = 170;
public static const CMD_GETCONFIGVAR:int = 171;
public static const CMD_DELCONFIGVAR:int = 172;
public static const CMD_DELCONFIGHIVE:int = 173;
public static const CMD_SYSTEMACTION:int = 174;

// Palette and character editing command constants
public static const CMD_SCANLINES:int = 180;
public static const CMD_BIT7ATTR:int = 181;
public static const CMD_PALETTECOLOR:int = 182;
public static const CMD_PALETTEBLOCK:int = 183;
public static const CMD_FADETOCOLOR:int = 184;
public static const CMD_FADETOBLOCK:int = 185;
public static const CMD_CHARSELECT:int = 186;

// High score and other server-side storage command constants
public static const CMD_POSTHS:int = 190;
public static const CMD_GETHS:int = 191;
public static const CMD_GETHSENTRY:int = 192;

// Flag evaluation constants
public static const FLAG_ANY:int = 1;
public static const FLAG_ALLIGNED:int = 2;
public static const FLAG_CONTACT:int = 3;
public static const FLAG_BLOCKED:int = 4;
public static const FLAG_ENERGIZED:int = 5;

// "New" flag evaluation constants
public static const FLAG_ALIGNED:int = 6;
public static const FLAG_ANYTO:int = 7;
public static const FLAG_ANYIN:int = 8;
public static const FLAG_SELFIN:int = 9;
public static const FLAG_TYPEIS:int = 10;
public static const FLAG_BLOCKEDAT:int = 11;
public static const FLAG_CANPUSH:int = 12;
public static const FLAG_SAFEPUSH:int = 13;
public static const FLAG_SAFEPUSH1:int = 14;
public static const FLAG_HASMESSAGE:int = 15;
public static const FLAG_TEST:int = 16;
public static const FLAG_VALID:int = 17;

// Generic "flag" evaluation constant
public static const FLAG_GENERIC:int = 100;
public static const FLAG_ALWAYSTRUE:int = 101;

// Base direction constants
public static const DIR_E:int = 1;
public static const DIR_S:int = 3;
public static const DIR_W:int = 5;
public static const DIR_N:int = 7;
public static const DIR_I:int = 9;

// direction constants
public static const DIR_SEEK:int = 11;
public static const DIR_FLOW:int = 12;
public static const DIR_RNDNS:int = 13;
public static const DIR_RNDNE:int = 14;
public static const DIR_RND:int = 15;

// Prefixes
public static const DIR_CW:int = 16;
public static const DIR_CCW:int = 17;
public static const DIR_RNDP:int = 18;
public static const DIR_OPP:int = 19;
public static const DIR_RNDSQ:int = 20;

public static const DIR_TOWARDS:int = 21;
public static const DIR_MAJOR:int = 22;
public static const DIR_MINOR:int = 23;
public static const DIR_UNDER:int = 24;
public static const DIR_OVER:int = 25;

// Inventory constants
public static const INV_NONE:int = 0;
public static const INV_AMMO:int = 1;
public static const INV_TORCHES:int = 2;
public static const INV_GEMS:int = 3;
public static const INV_HEALTH:int = 4;
public static const INV_SCORE:int = 5;
public static const INV_TIME:int = 6;
public static const INV_Z:int = 7;
public static const INV_KEY:int = 8;
public static const INV_EXTRA:int = 9;

// Color constants
public static const COLOR_BLACK:int = 0;
public static const COLOR_DARKBLUE:int = 1;
public static const COLOR_DARKGREEN:int = 2;
public static const COLOR_DARKCYAN:int = 3;
public static const COLOR_DARKRED:int = 4;
public static const COLOR_DARKPURPLE:int = 5;
public static const COLOR_DARKYELLOW:int = 6;
public static const COLOR_BROWN:int = 6;
public static const COLOR_GREY:int = 7;
public static const COLOR_DARKGREY:int = 8;
public static const COLOR_BLUE:int = 9;
public static const COLOR_GREEN:int = 10;
public static const COLOR_CYAN:int = 11;
public static const COLOR_RED:int = 12;
public static const COLOR_PURPLE:int = 13;
public static const COLOR_YELLOW:int = 14;
public static const COLOR_WHITE:int = 15;

// Misc. keyword constants
public static const MISC_NOT:int = 1;
public static const MISC_SELF:int = 2;
public static const MISC_ALL:int = 3;
public static const MISC_OTHERS:int = 4;
public static const MISC_THEN:int = 5;
public static const MISC_CLONE:int = 6;
public static const MISC_SILENT:int = 7;
public static const MISC_UNDER:int = 8;
public static const MISC_OVER:int = 9;

// "Keyword arg" constants
public static const KWARG_TYPE:int = 1;
public static const KWARG_X:int = 2;
public static const KWARG_Y:int = 3;
public static const KWARG_STEPX:int = 4;
public static const KWARG_STEPY:int = 5;
public static const KWARG_CYCLE:int = 6;
public static const KWARG_P1:int = 7;
public static const KWARG_P2:int = 8;
public static const KWARG_P3:int = 9;
public static const KWARG_FOLLOWER:int = 10;
public static const KWARG_LEADER:int = 11;
public static const KWARG_UNDERID:int = 12;
public static const KWARG_UNDERCOLOR:int = 13;

public static const KWARG_CHAR:int = 14;
public static const KWARG_COLOR:int = 15;
public static const KWARG_COLORALL:int = 16;
public static const KWARG_DIR:int = 17;
public static const KWARG_ONAME:int = 18;
public static const KWARG_BIND:int = 19;

public static const KWARG_INTELLIGENCE:int = 20;
public static const KWARG_SENSITIVITY:int = 21;
public static const KWARG_PHASE:int = 22;
public static const KWARG_PERIOD:int = 23;
public static const KWARG_RESTINGTIME:int = 24;
public static const KWARG_DEVIANCE:int = 25;
public static const KWARG_RATE:int = 26;
public static const KWARG_DESTINATION:int = 27;

// Expression operator constants
public static const OP_ADD:int = 1;
public static const OP_SUB:int = 2;
public static const OP_MUL:int = 3;
public static const OP_DIV:int = 4;
public static const OP_EQU:int = 5;
public static const OP_NEQ:int = 6;
public static const OP_GRE:int = 7;
public static const OP_LES:int = 8;
public static const OP_AND:int = 9;
public static const OP_OR:int = 10;
public static const OP_XOR:int = 11;
public static const OP_DOT:int = 12;
public static const OP_ARR:int = 13;
public static const OP_GOE:int = 14;
public static const OP_LOE:int = 15;

// Special internal constants
public static const SPEC_SILENT:int = 0;
public static const SPEC_NOTSILENT:int = 1;
public static const SPEC_BOOLEAN:int = -2;
public static const SPEC_NOT:int = -3;
public static const SPEC_NORM:int = -4;
public static const SPEC_ALL:int = -5;
public static const SPEC_NOCOLOR:int = -6;
public static const SPEC_POLAR:int = -7;
public static const SPEC_ADD:int = -8;
public static const SPEC_SUB:int = -9;
public static const SPEC_ABS:int = -10;
public static const SPEC_KINDNORM:int = -2;
public static const SPEC_KINDEXPR:int = -3;
public static const SPEC_KINDMISC:int = -4;
public static const SPEC_KWARGEND:int = -5;
public static const SPEC_EXPRPRESENT:int = -1;
public static const SPEC_EXPREND:int = -11;
public static const SPEC_NUMCONST:int = 1;
public static const SPEC_STRCONST:int = 2;
public static const SPEC_LOCALVAR:int = 3;
public static const SPEC_PROPERTY:int = 4;
public static const SPEC_GLOBALVAR:int = 5;
public static const SPEC_DIRCONST:int = 6;
public static const SPEC_KINDCONST:int = 7;
public static const SPEC_SELF:int = 8;

// Prefix characters, identifying type of ZZT-OOP action
public static var prefixChars:String = "@/?:'$!#";

// Characters used in expression operators
public static var opChars:String = "+-*/=!><&|^.[";
public static var opLookupStr:Array = [
	"+", "-", "*", "/", "==", "!=", "<", ">", "&", "|", "^", ".", "[", ">=", "<="
];

// Characters used in coordinate and expression ellipsis
public static var ellipsisChars:String = "()[]+-,";

// Characters used in PLAY statements
public static var musicChars_1:String;
public static var musicChars:String = "TSIQHW3.+-XABCDEFG012456789[]";
public static var musicChars_x:String = "TSIQHW3.+-XABCDEFG012456789[]ZVYPR";

// ZZT-OOP commands
public static var nonSpelledCommandStr:Array = [
	"",
	"RESTORE",
	"ZAP",
	"",
	"FORITER",
	"SEND",
	"?",
	"!-",
	"!",
	"$",
	"",
	"'",
	":",
	"@"
];

public static var commands_1:Array;
public static var commands:Array = [
	"GO", "TRY", "WALK",        // Movement
	"DIE", "ENDGAME",           // Object or game destruction
	"SEND", "RESTART", "END",   // Program flow
	"BIND",                     // Behavior reassign
	"BECOME", "CHANGE", "PUT",  // Kind modification
	"CHAR", "CYCLE",            // Self-status modification
	"CLEAR", "SET",             // Flag handling
	"GIVE", "TAKE",             // Inventory modification
	"IF",                       // Conditional execution
	"LOCK", "UNLOCK",           // Message blocking
	"ZAP", "RESTORE",           // Message label modification
	"SHOOT", "THROWSTAR",       // Projectile firing
	"PLAY",                     // Play music/SFX
	"IDLE"						// Equivalent to /i
];
public static var commands_x:Array = [
	"GO", "TRY", "WALK",
	"DIE", "ENDGAME",
	"SEND", "RESTART", "END",
	"BIND",
	"BECOME", "CHANGE", "PUT",
	"CHAR", "CYCLE",
	"CLEAR", "SET",
	"GIVE", "TAKE",
	"IF",
	"LOCK", "UNLOCK",
	"ZAP", "RESTORE",
	"SHOOT", "THROWSTAR",
	"PLAY",
	"IDLE",
	"\x1F","\x1F",

	"PAUSE",					// Suspend object execution; send main a PAUSED message each frame
	"UNPAUSE",					// Resume object execution.
	"EXTRATURNS",               // Allow object to take multiple turns per iteration
	"DONEDISPATCH",             // Clears dispatch flag; object affected as if
								// no longer dispatched message
	"DISPATCH",					// Dispatch message to main (immediate).
	"SENDTO",					// Send message to specific target.
	"DISPATCHTO",				// Dispatch message to specific target (immediate).
	"SWITCHTYPE",				// Go to message based on type at coordinates.
	"SWITCHVALUE",				// Go to message based on expression value.
	"EXECCOMMAND",				// Execute command in variable string.

	"SETREGION",                // Set named region
	"CLEARREGION",              // Clear named region
	"\x1F","\x1F","\x1F","\x1F","\x1F","\x1F","\x1F","\x1F",

	"CHAR4DIR",                 // Set object's character based on direction
	"COLOR",                    // Set object's color (usually FG only)
	"COLORALL",                 // Set object's FG and BG color
	"DRAWCHAR",					// Draw a character to the grid (nonpermanent)
	"ERASECHAR",				// Erase a (nonpermanent) character from the grid
	"GHOST",					// Change object's ghost flag status and appearance
	"KILLPOS",					// Kill an object at the specified coordinates.
	"\x1F","\x1F","\x1F",

	"SETPOS",                   // Sets X and Y of status element; no movement messages
	"FORCEGO",                  // "Nuclear" version of GO; does not push and will overwrite
	"PUSHATPOS",				// Push objects at a specific position.
	"GROUPSETPOS",				// "Grouped" version of SETPOS
	"GROUPGO",					// "Grouped" version of GO
	"GROUPTRY",					// "Grouped" version of TRY
	"GROUPTRYNOPUSH",			// "Grouped" version of non-pushing TRY (e.g. ZZT WALK)
	"\x1F","\x1F","\x1F",

	"DYNTEXT",                  // Display dynamic text
	"DYNLINK",                  // Display a scroll label with dynamic text
	"DYNTEXTVAR",				// Set global variable to dynamic string.
	"DUMPSE",					// Dump a status element as scroll text
	"DUMPSEAT",					// Dump a status element as scroll text at coordinates
	"TEXTTOGUI",				// Re-route text to a GUI label
	"TEXTTOGRID",				// Re-route text to a region in the grid
	"SCROLLSTR",				// "Scroll" a string into a toast message label
	"SCROLLCOLOR",				// Modify scroll interface color scheme
	"\x1F",

	"SETPLAYER",				// Set the player's object.
	"SETPROPERTY",              // Set world or board property
	"GETPROPERTY",              // Retrieve world or board property
	"PLAYERINPUT",              // Get player's input
	"TYPEAT",                   // Extract kind code
	"COLORAT",                  // Extract color
	"OBJAT",                    // Extract object pointer
	"LITAT",					// Extract lit cell flag
	"RANDOM",                   // Get random number between n and p
	"DIR2UVECT8",               // Get x and y offsets from 8-directional constant
	"OFFSETBYDIR",				// Offset coordinates by a magnitude and direction.
	"SUBSTR",               	// Get substring equivalent of expression.
	"INT",						// Get integer equivalent of expression.
	"ATAN2",					// Get specific-resolution arctangent of step values.
	"SMOOTHTEST",				// Prepare an object pointer for a directional "smooth move"
	"SMOOTHMOVE",				// Take the move identified from SMOOTHTEST
	"READKEY",					// Read keydown status for a keyboard key
	"READMOUSE",				// Read mouse button and cursor status
	"SETTYPEINFO",				// Set type property information
	"GETTYPEINFO",				// Get type property information

	"SPAWN",                    // Put new object at specific coordinates
	"SPAWNGHOST",               // Put new object at specific coordinates, with ghosted status
	"CHANGEREGION",             // "Region" version of CHANGE
	"CLONE",                    // Set CLONE object type
	"\x1F","\x1F","\x1F","\x1F","\x1F","\x1F",

	"FOREACH",                  // Enumerate status elements in a region
	"FORMASK",                  // Enumerate coordinates associated with a mask
	"FORNEXT",					// Iterate to last FOREACH or FORMASK or FORREGION
	"FORREGION",				// Enumerate coordinates at region
	"\x1F","\x1F","\x1F","\x1F","\x1F","\x1F",

	"UPDATEVIEWPORT",           // Update viewport with game contents
	"ERASEVIEWPORT",            // Erase viewport
	"DISSOLVEVIEWPORT",         // Dissolve viewport (in or out)
	"SCROLLTOVISUALS",          // Scroll between boards
	"CAMERAFOCUS",				// Change CAMERAX and CAMERAY to focus on coordinates
	"LIGHTEN",					// Set lit cell flag
	"DARKEN",					// Clear lit cell flag
	"UPDATELIT",				// Draw the area updated most recently by LIGHTEN and DARKEN
	"SUSPENDDISPLAY",			// Impose or lift a temporary suspension of grid display
	"\x1F",

	"USEGUI",                   // Use a named GUI
	"SETGUILABEL",              // Write text to a GUI label
	"SELECTPEN",				// Go into pen-selection mode, letting user pick setting.
	"DRAWPEN",					// Draw a pen at a GUI label.
	"DRAWBAR",					// Draw a bar at a GUI label.
	"CONFMESSAGE",				// Display a confirmation message at the CONFMESSAGE label.
	"TEXTENTRY",				// Display a text entry message at the FILEMESSAGE label, with
								// entry at the FILEENTRY label.
	"DRAWGUICHAR",				// Draw a character to the GUI (nonpermanent)
	"ERASEGUICHAR",				// Erase a (nonpermanent) character from the GUI
	"MODGUILABEL",				// Modify a GUI label to active GUI (or add a new label)

	"SAVEBOARD",				// Save board information for later archive
	"CHANGEBOARD",				// Change board to another in archive
	"SAVEWORLD",				// Bring up interface to save world
	"LOADWORLD",				// Load world archive.
	"RESTOREGAME",				// Bring up interface for restoring game.
	"\x1F","\x1F","\x1F","\x1F","\x1F",

	"PLAYSOUND",                // Play content from a SOUND_FX lump, which contains PLAY
								// statements.  If RS and RE exist within these play
								// statements, looping is automatic for these effects until
								// STOPSOUND is used.
	"GETSOUND",                 // Get sound effect playing.
	"STOPSOUND",                // Stop one or more voices.
	"MASTERVOLUME",             // Change master volume for one or more channels.
	"\x1F","\x1F","\x1F","\x1F","\x1F","\x1F",

	"PUSHARRAY",				// Push expression to end of array.
	"POPARRAY",					// Get expression from top of array; pop from top.
	"SETARRAY",					// Set array to specific size.
	"LEN",						// Get length of an array or string.
	"\x1F","\x1F","\x1F","\x1F","\x1F","\x1F",

	"SETCONFIGVAR",				// Set persistent configuration variable.
	"GETCONFIGVAR",				// Get persistent configuration variable.
	"DELCONFIGVAR",				// Delete persistent configuration variable.
	"DELCONFIGHIVE",			// Delete persistent configuration variable hive.
	"SYSTEMACTION",				// Perform special system-exclusive action.
	"\x1F","\x1F","\x1F","\x1F","\x1F",

	"SCANLINES",				// Set number of scanlines per character.
	"BIT7ATTR",					// Set meaning of bit 7 of color attribute.
	"PALETTECOLOR",				// Change a single color palette DAC entry.
	"PALETTEBLOCK",				// Change a block of color palette DAC entries.
	"FADETOCOLOR",				// Fade all colors to a single color palette DAC entry.
	"FADETOBLOCK",				// Fade a block of colors palette DAC entries to specific targets.
	"CHARSELECT",				// Character selection interface (modify ASCII character set).
	"\x1F","\x1F","\x1F",

	"POSTHS",					// Post a high score line.
	"GETHS",					// Get high scores.
	"GETHSENTRY"				// Get a high score field entry.
];

// Flags used in IF statements
public static var flagEvals_1:Array;
public static var flagEvals:Array = [
	"ANY", "ALLIGNED", "CONTACT", "BLOCKED", "ENERGIZED"
];
public static var flagEvals_x:Array = [
	"ANY", "ALLIGNED", "CONTACT", "BLOCKED", "ENERGIZED",

	"ALIGNED",                  // Alternate (correct) spelling of ALLIGNED.
	"ANYTO",                    // If a kind is immediately to a specific direction.
	"ANYIN",                    // If a kind is within a specific named region.
	"SELFIN",                   // If self is within a specific named region.
	"TYPEIS",                   // If a kind is at a specific coordinate.
	"BLOCKEDAT",				// If blocking flag set for type at a specific coordinate.
	"CANPUSH",                  // If can push towards a specific direction.
								// This is not the same as BLOCKED, which detects if
								// anything other than EMPTY, FLOOR, or FAKE is present.
	"SAFEPUSH",                 // Variation on CANPUSH; will fail if squash would occur.
	"SAFEPUSH1",                // Variation on CANPUSH; will fail if 100% squash would occur.
	"HASMESSAGE",				// Checks if object at pointer has a valid message label.
	"TEST",                     // Checks if an expression is zero or nonzero;
								// expression must be a number.
	"VALID"                     // Checks if an object pointer is valid.
];

// Game-generated messages
public static var specialMessages_1:Array;
public static var specialMessages:Array = [
	"TOUCH", "SHOT", "BOMBED", "THUD", "ENERGIZE", "HINT"
];
public static var specialMessages_x:Array = [
	"TOUCH", "SHOT", "BOMBED", "THUD", "ENERGIZE", "HINT",

	"BLOCKBEHAVIOR",            // Sent when something crashes into it (GO, TRY).
	"CRASHBEHAVIOR",            // Sent when object crashes into something (GO, TRY).
	"DIEBEHAVIOR",              // Sent when object is about to die (no matter how).
	"PUSHBEHAVIOR",             // Sent when a push attempt is coming from a direction.
	"WALKBEHAVIOR",             // Sent when making an object walk.
	"ONENTERBOARD",             // Sent when player enters the board.
	"ONLEAVEBOARD"              // Sent when player leaves the board.
];

// Directions and directional mod prefixes
public static var directions_1:Array;
public static var directions:Array = [
	"E", "EAST",
	"S", "SOUTH",
	"W", "WEST",
	"N", "NORTH",
	"I", "IDLE",
	"SEEK", "FLOW",             // Looked-up direction
	"RNDNS", "RNDNE", "RND",    // Random direction
	"CW", "CCW", "RNDP", "OPP"  // Directional mod prefix
];
public static var directions_x:Array = [
	"E", "EAST",
	"S", "SOUTH",
	"W", "WEST",
	"N", "NORTH",
	"I", "IDLE",
	"SEEK", "FLOW",
	"RNDNS", "RNDNE", "RND",
	"CW", "CCW", "RNDP", "OPP",

	"RNDSQ",                    // Genuinely random direction, with all 4 directions
								// picked with equal probability.
	"TOWARDS",                  // Equivalent of SEEK but with any coordinate pair dest.
	"MAJOR",                    // Picks dominant direction if destination is diagonal.
	"MINOR",                    // Picks non-dominant direction if destination is diagonal.
];

// Inventory names used in GIVE and TAKE statements
public static var inventory_1:Array;
public static var inventory:Array = [
	"AMMO", "TORCHES", "GEMS", "HEALTH", "SCORE", "TIME", "Z"
];
public static var inventory_x:Array = [
	"AMMO", "TORCHES", "GEMS", "HEALTH", "SCORE", "TIME", "Z",

	"KEY"                       // Can adjust keys in inventory (color required).
];

// Colors used when qualifying kinds
public static var colors_1:Array;
public static var colors:Array = [
	"BLUE", "GREEN", "CYAN", "RED", "PURPLE", "YELLOW", "WHITE"
];
public static var colors_x:Array = [
	// New
	"BLACK", "DARKBLUE", "DARKGREEN", "DARKCYAN", "DARKRED",
	"DARKPURPLE", "BROWN", "GREY", "DARKGREY",

	// Old
	"BLUE", "GREEN", "CYAN", "RED", "PURPLE", "YELLOW", "WHITE"
];

// Kinds used when referring to terrain and object types in the game
public static var kinds:Array = [
	"EMPTY",
	"BOARDEDGE",
	"MESSENGER",
	"MONITOR",
	"PLAYER",
	"AMMO",
	"TORCH",
	"GEM",
	"KEY",
	"DOOR",
	"SCROLL",
	"PASSAGE",
	"DUPLICATOR",
	"BOMB",
	"ENERGIZER",
	"STAR",
	"CLOCKWISE",
	"COUNTER",
	"BULLET",
	"WATER",
	"LAVA",
	"FOREST",
	"SOLID",
	"NORMAL",
	"BREAKABLE",
	"BOULDER",
	"SLIDERNS",
	"SLIDEREW",
	"FAKE",
	"INVISIBLE",
	"BLINKWALL",
	"TRANSPORTER",
	"LINE",
	"RICOCHET",
	"_BEAMHORIZ",
	"BEAR",
	"RUFFIAN",
	"OBJECT",
	"SLIME",
	"SHARK",
	"SPINNINGGUN",
	"PUSHER",
	"LION",
	"TIGER",
	"_BEAMVERT",
	"HEAD",
	"SEGMENT",
	"FLOOR",
	"WATERN",
	"WATERS",
	"WATERW",
	"WATERE",
	"ROTON",
	"DRAGONPUP",
	"PAIRER",
	"SPIDER",
	"WEB",
	"STONE",
	"_TEXTBLUE",
	"_TEXTGREEN",
	"_TEXTCYAN",
	"_TEXTRED",
	"_TEXTPURPLE",
	"_TEXTBROWN",
	"_TEXTWHITE",
	"_WINDTUNNEL"
];

// Miscellaneous keywords
public static var miscKeywords_1:Array;
public static var miscKeywords:Array = [
	"NOT",
	"SELF",
	"ALL",
	"OTHERS",
	"THEN"
];
public static var miscKeywords_x:Array = [
	"NOT",
	"SELF",
	"ALL",
	"OTHERS",
	"THEN",

	"CLONE",                    // Kind established from last CLONE command
	"SILENT",                   // Inhibits sound for some actions
	"UNDER",					// Modifies placement of new objects
	"OVER",						// Modifies placement of new objects
];

// Keywords used with KIND or dot operator
public static var keywordArgs:Array = [
	"TYPE",                     // Type code
	"X",                        // X-coordinate; 1-based
	"Y",                        // Y-coordinate; 1-based
	"STEPX",                    // X-step
	"STEPY",                    // Y-step
	"CYCLE",                    // Number
	"P1",                       // Number
	"P2",                       // Number
	"P3",                       // Number
	"FOLLOWER",                 // Object pointer
	"LEADER",                   // Object pointer
	"UNDERID",                  // Kind code "under" object
	"UNDERCOLOR",               // Color code "under" object

	"CHAR",                     // Character code of the object; alias of P1 for OBJECT type
	"COLOR",                    // Color code of the object
	"COLORALL",                 // Color code of the object, FG and BG together
	"DIR",                      // Flow direction (calculated from STEPX and STEPY)
	"ONAME",                    // ONAME to which to bind on the board
	"BIND",                     // Kind-specific; alias of ONAME
	"INTELLIGENCE",             // Kind-specific; alias of P1
	"SENSITIVITY",              // Kind-specific; alias of P1
	"PHASE",             		// Kind-specific; alias of P1
	"PERIOD",                   // Kind-specific; alias of P2
	"RESTINGTIME",              // Kind-specific; alias of P2
	"DEVIANCE",                 // Kind-specific; alias of P2
	"RATE",                     // Kind-specific; alias of P2
	"DESTINATION",              // Kind-specific; alias of P3
];

// "Traceback" dictionary look-up
public static var negTracebackLookup:Array = [
	"EXPRPRESENT", "KINDNORM/BOOLEAN", "KINDEXPR/NOT", "KINDMISC/NORM",
	"ALL/KWARGEND", "NOCOLOR", "COORD_POLAR", "COORD_ADD", "COORD_SUB", "COORD_ABS",
	"EXPREND"
];

// "Traceback" dictionary look-up
public static var posTracebackLookup:Array = [
	"ERROR/INVNONE/SILENT",
	"GO/ANY/E/INVAMMO/NOT/+/NOTSILENT/NUMCONST",
	"TRY/ALLIGNED/INVTORCHES/SELF/-/STRCONST",
	"CONTACT/WALK/S/INVGEMS/ALL/*/LOCALVAR",
	"DIE/BLOCKED/INVHEALTH/OTHERS///PROPERTY",
	"ENERGIZED/W/INVSCORE/THEN/=/GLOBALVAR",
	"SEND/ALIGNED/INVTIME/CLONE/!/DIRCONST",
	"ANYTO/N/INVZ/SILENT/>=/KINDCONST",
	"END/ANYIN/INVKEY/</SELF",
	"SELFIN/I/&",
	"TYPEIS/|",
	"BLOCKEDAT/SEEK/^",
	"FLOW/CANPUSH/.",
	"SAFEPUSH/RNDNS/[]",
	"SAFEPUSH1/RNDNE/>=",
	"TEST/RND/<=",
	"VALID/CW",
	"CCW",
	"RNDP",
	"OPP",
	"RNDSQ",
	"TOWARDS",
	"MAJOR",
	"MINOR"
];

// Strings parsed in the past
public static var pStrings:Vector.<String> = new Vector.<String>();

// Error condition
public static var errorText:String = "";
public static var hasError:Boolean = false;

public static var oopType:int = -3;
public static var lastAssignedName:String = "";
public static var lastDirType:int = 0;
public static var virtualIP:int = 0;
public static var lineStartIP:int = 0;
public static var checkMiddleOffset:int = 0;

public static var zeroTypeLabelAction:int = 0;
public static var zeroTypeLabelLocs:Array = [];

// Set the namespace used when handling the OOP commands.
public static function setOOPType(type:int=-3):void {
	if (type != -3)
	{
		// Use classic ZZT-OOP namespace
		musicChars_1 = musicChars;
		commands_1 = commands;
		flagEvals_1 = flagEvals;
		specialMessages_1 = specialMessages;
		directions_1 = directions;
		inventory_1 = inventory;
		colors_1 = colors;
		miscKeywords_1 = miscKeywords;
	}
	else
	{
		// Use extended ZZTUltra-OOP namespace
		musicChars_1 = musicChars_x;
		commands_1 = commands_x;
		flagEvals_1 = flagEvals_x;
		specialMessages_1 = specialMessages_x;
		directions_1 = directions_x;
		inventory_1 = inventory_x;
		colors_1 = colors_x;
		miscKeywords_1 = miscKeywords_x;
	}

	// Banana Quest hacked executable keywords
	if (zzt.globalProps["BQUESTHACK"])
	{
		commands_1[CMD_END - 1] = "STP";
		commands_1[CMD_CYCLE - 1] = "SPEED";
		commands_1[CMD_PLAY - 1] = "MUZK";
		commands_1[CMD_ENDGAME - 1] = "OHHDREA";
	}
	else
	{
		commands_1[CMD_END - 1] = "END";
		commands_1[CMD_CYCLE - 1] = "CYCLE";
		commands_1[CMD_PLAY - 1] = "PLAY";
		commands_1[CMD_ENDGAME - 1] = "ENDGAME";
	}

	oopType = type;
	errorText = "";
	hasError = false;
}

// Signal error message during parse.
public static function errorMsg(str:String):void {
	hasError = true;
	errorText = str;
}

// Signal warning message during parse.
public static function warningMsg(str:String):void {
	zzt.Toast(str);
}

// Post error message to be shown during script interpretation.
public static function postErrorMsg(b:Array, str:String, popCount:int=0):void {
	while (popCount--)
		b.pop();
	b.push(CMD_ERROR);
	b.push(addCString(str));
}

// Find a constant matching keyword (case-insensitive search).
public static function findMatching(str:String, cont:Array):int {
	var strLen:int = findNonKW(str, 0);
	str = str.substr(0, strLen).toUpperCase();

	return cont.indexOf(str);
}

// Find next non-whitespace character.
public static function findNonWS(str:String, idx:int):int {
	for (var i:int = idx; i < str.length; i++) {
		if (str.charCodeAt(i) != 32)
			return i; // Found
	}

	return str.length; // EOL
}

// Find next non-whitespace character and skip stray commas if present.
public static function findNonWSComma(str:String, idx:int):int {
	for (var i:int = idx; i < str.length; i++) {
		var c:int = str.charCodeAt(i);
		if (c != 32 && c != 44)
			return i; // Found
	}

	return str.length; // EOL
}

// Find next non-keyword character.
public static function findNonKW(str:String, idx:int):int {
	for (var i:int = idx; i < str.length; i++) {
		var c:int = str.charCodeAt(i);
		if ((c >= 65 && c <= 90) || (c >= 48 && c <= 57) ||
			(c >= 97 && c <= 122) || c == 95)
		{
			// Continue
		}
		else
		{
			return i; // Found
		}
	}

	return str.length; // EOL
}

// Variation on findNonKW, which allows dollar symbols.
public static function findNonKWDynamic(str:String, idx:int):int {
	for (var i:int = idx; i < str.length; i++) {
		var c:int = str.charCodeAt(i);
		if ((c >= 65 && c <= 90) || (c >= 48 && c <= 57) ||
			(c >= 97 && c <= 122) || c == 95 || c == 36)
		{
			// Continue
		}
		else
		{
			return i; // Found
		}
	}

	return str.length; // EOL
}

// Check if next keyword can be interpreted as a numeric constant.
public static function isNumeric(str:String, idx:int):Boolean {
	var c:int = str.charCodeAt(idx);
	if (c >= 48 && c <= 57)
		return true;
	else
		return false;
}

// Check if next keyword starts with alpha or underscore
public static function isAlpha(str:String, idx:int):Boolean {
	var c:int = str.charCodeAt(idx);
	if ((c >= 65 && c <= 90) || (c >= 97 && c <= 122) || c == 95)
		return true;
	else
		return false;
}

// Check if next keyword starts with alphanumeric or underscore
public static function isAlphaNum(str:String, idx:int):Boolean {
	var c:int = str.charCodeAt(idx);
	if ((c >= 65 && c <= 90) || (c >= 97 && c <= 122) ||
		(c >= 48 && c <= 57) || c == 95)
		return true;
	else
		return false;
}

// Add a string to pStrings (uppercase only); return look-up index.
public static function addString(str:String):int {
	var l:int = pStrings.length;
	pStrings.push(str.toUpperCase());
	return l;
}

// Add a string to pStrings (any case); return look-up index.
public static function addCString(str:String):int {
	var l:int = pStrings.length;
	pStrings.push(str);
	return l;
}

// Special type of "zap" that applies only to overridden labels in main type code.
public static function pushOldZeroTypeLabel(labelStr:String):void {
	var code:Array = interp.codeBlocks[0];
	for (var i:int = 0; i < zeroTypeLabelLocs.length; i++) {
		var pos:int = zeroTypeLabelLocs[i];
		if (pStrings[code[pos + 1]] == labelStr)
		{
			code[pos] = CMD_COMMENT;
			break;
		}
	}
}

// Special type of "restore" that applies only to overridden labels in main type code.
public static function restoreOldZeroTypeLabels():void {
	var code:Array = interp.codeBlocks[0];
	for (var i:int = 0; i < zeroTypeLabelLocs.length; i++) {
		var pos:int = zeroTypeLabelLocs[i];
		code[pos] = CMD_LABEL;
	}
}

// Parse a line of the OOP.
public static function parseLine(b:Array, line:String):Array {
	// Empty line counts as text
	if (line.length == 0)
	{
		b.push(CMD_TEXT);
		b.push(addString(""));
		return b;
	}

	// Text counts as any line not adorned by a prefix character.
	var op:int = prefixChars.indexOf(line.charAt(0));
	if (op == -1)
	{
		b.push(CMD_TEXT);
		b.push(addCString(line));
	}
	else
	{
		parseCommand(b, line, 0);
	}

	if (hasError)
		return null;
	else
		return b;
}

// Parse a line of one or more "go"- or "try"-type operations.
public static function parseGo(b:Array, line:String, idx:int=0):void {
	while (idx < line.length) {
		// Detect middle-of-line virtual IP position.
		if (checkMiddleOffset == idx)
			virtualIP = b.length;

		var s:String = line.charAt(idx);
		if (++idx > line.length)
		{
			postErrorMsg(b, "Bad " + s);
			return;
		}

		var goStart:int = b.length;
		if (s == "/")
			b.push(CMD_GO);
		else
			b.push(CMD_TRYSIMPLE);

		idx = parseDirection(b, line, idx);
		if (idx == -1)
		{
			postErrorMsg(b, "Bad direction", 1);
			return;
		}
		var goEnd:int = b.length;

		var testIdx = findNonWS(line, idx);
		if (testIdx < line.length)
		{
			if (isNumeric(line, testIdx) && oopType != -1)
			{
				idx = testIdx;
				testIdx = -1;
				var eLoc:int = findNonKW(line, idx);
				var repCount:int = int(line.substring(idx, eLoc));
				idx = findNonWS(line, eLoc);

				// Repeat last operation.
				while (--repCount > 0)
				{
					var unitSlice:Array = b.slice(goStart, goEnd);
					for (var i:int = 0; i < unitSlice.length; i++)
						b.push(unitSlice[i]);
				}

				return;
			}
		}

		// Unusual syntax to see command here, but still valid
		if (idx < line.length)
		{
			var op:int = prefixChars.indexOf(line.charAt(idx));
			if (op == -1)
			{
				b.push(CMD_TEXT);
				b.push(addCString(line.substring(idx)));
				idx = line.length;
			}
			else if (line.charAt(idx) != "/" && line.charAt(idx) != "?")
			{
				parseCommand(b, line, idx);
				idx = line.length;
			}
		}
	}
}

// Parse a ZZT-OOP command, usually encountered by preceding with a '#'.
public static function parseCommand(b:Array, line:String, idx:int):int {
	while (idx < line.length)
	{
		// Multiple '#' characters permitted
		// Dumb parsing rule but still valid
		if (line.charAt(idx) == "#")
			idx++;
		else
			break;
	}
	if (idx >= line.length)
	{
		// Empty text
		b.push(CMD_TEXT);
		b.push(addCString(""));
		return line.length;
	}

	// Ignore leading spaces.
	var c1:String = line.charAt(idx);
	while (idx < line.length)
	{
		if (c1 == " ")
			c1 = line.charAt(++idx);
		else
			break;
	}

	if (c1 == "@")
	{
		// Name assignment
		lastAssignedName = line.substr(idx+1);
		b.push(CMD_NAME);
		b.push(addCString(lastAssignedName));

		return line.length;
	}
	else if (c1 == ":")
	{
		// Message Label
		c1 = utils.rstrip(line.substr(idx+1));
		b.push(CMD_LABEL);
		b.push(addString(c1));
		b.push(lineStartIP);

		if (zeroTypeLabelAction == 1)
			zeroTypeLabelLocs.push(b.length - 3);
		else if (zeroTypeLabelAction == 2)
			pushOldZeroTypeLabel(c1);

		return line.length;
	}
	else if (c1 == "'")
	{
		// Comment
		b.push(CMD_COMMENT);
		b.push(addString(utils.rstrip(line.substr(idx+1))));
		b.push(lineStartIP);

		return line.length;
	}
	else if (c1 == "/" || c1 == "?")
	{
		// Movement
		parseGo(b, line, idx);
		return line.length;
	}
	else if (c1 == "$")
	{
		// Centered text
		b.push(CMD_TEXTCENTER);
		b.push(addCString(line.substr(idx+1)));
		return line.length;
	}
	else if (c1 == "!")
	{
		// Button link
		var sepLoc:int = line.indexOf(";", idx+1);
		if (sepLoc == -1)
		{
			postErrorMsg(b, "Bad link");
		}
		else if (line.charAt(idx+1) == "-")
		{
			b.push(CMD_TEXTLINKFILE);
			b.push(addString(line.substring(idx+2, sepLoc)));
			b.push(addCString(line.substring(sepLoc+1)));
		}
		else
		{
			b.push(CMD_TEXTLINK);
			b.push(addString(line.substring(idx+1, sepLoc)));
			b.push(addCString(line.substring(sepLoc+1)));
		}

		return line.length;
	}
	else if (!isAlpha(line, idx))
	{
		// This counts as text; strange parsing rule
		b.push(CMD_TEXT);
		b.push(addCString(line.substr(idx)));
		return line.length;
	}

	// Parse # command
	line = line.substr(idx);
	idx = 0;
	var str:String = line;
	var cmdType:int = findMatching(str, commands_1);
	var otherType:int;
	var nextIdx:int;
	var falseJumpLoc:int;

	// Will count as #SEND command if...
	// 1) #SEND Target
	// 2) #SEND Target:Label
	// 3) #Target (Target cannot be command)
	// 4) #Target:Label (Target CAN be command, but without spaces between Target and colon)
	var colonLoc:int = line.indexOf(":", idx);
	var spaceLoc:int = line.indexOf(" ", idx);
	if (cmdType == -1 || (colonLoc != -1 && (spaceLoc == -1 || spaceLoc > colonLoc)))
	{
		// SEND equivalent
		if (colonLoc == -1)
		{
			// Self-SEND
			b.push(CMD_SEND);
			nextIdx = findNonKWDynamic(line, idx);
			b.push(addString(utils.rstrip(line.substring(idx, nextIdx))));
		}
		else
		{
			str = line.substring(idx, colonLoc).toUpperCase();
			if (str == "SELF")
			{
				// Self-SEND
				b.push(CMD_SEND);
				nextIdx = findNonKWDynamic(line, colonLoc+1);
				b.push(addString(utils.rstrip(line.substring(colonLoc+1, nextIdx))));
			}
			else
			{
				// SENDTONAME
				b.push(CMD_SENDTONAME);
				nextIdx = findNonKWDynamic(line, colonLoc+1);
				b.push(addString(str));
				b.push(addString(utils.rstrip(line.substring(colonLoc+1, nextIdx))));
			}
		}

		idx = findNonWS(line, idx);
	}
	else
	{
		// Ordinary command.
		idx = findNonKW(line, idx);
		idx = findNonWS(line, idx);
		b.push(cmdType + 1);
		switch (cmdType + 1) {
			case CMD_GO:
				idx = parseDirAndLength(b, line, idx);
				if (lastDirType == DIR_I)
				{
					// Special:  #GO IDLE should block indefinitely.
					b.push(CMD_END);
				}
			break;
			case CMD_FORCEGO:
				idx = parseDirAndLength(b, line, idx);
			break;
			case CMD_TRY:
				idx = parseDirAndAction(b, line, idx);
			break;
			case CMD_WALK:
				idx = parseDirection(b, line, idx);
			break;
			case CMD_IDLE:
				b[b.length - 1] = CMD_GO;
				b.push(DIR_I);
			break;
			case CMD_SHOOT:
			case CMD_THROWSTAR:
				if (findMatching(line.substr(idx), miscKeywords_1) == MISC_SILENT-1)
				{
					idx = findNonKW(line, idx);
					idx = findNonWS(line, idx);
					b.push(SPEC_SILENT); // SILENT
				}
				else
					b.push(SPEC_NOTSILENT); // NOT SILENT

				idx = parseDirection(b, line, idx);
				if (idx == -1)
				{
					postErrorMsg(b, "Bad direction", 2);
				}
			break;
			case CMD_DIE:
			case CMD_ENDGAME:
			case CMD_END:
			case CMD_RESTART:
			case CMD_LOCK:
			case CMD_UNLOCK:
			case CMD_DONEDISPATCH:
			case CMD_UPDATEVIEWPORT:
			case CMD_ERASEVIEWPORT:
			case CMD_UPDATELIT:
			case CMD_PAUSE:
			case CMD_UNPAUSE:
			break;
			case CMD_FORNEXT:
				b.push(CMD_LABEL);
				b.push(addString(":#PASTFORNEXT"));
				b.push(lineStartIP);
			break;

			case CMD_SEND:
				colonLoc = line.indexOf(":", idx);
				if (colonLoc == -1)
				{
					// Self-SEND
					nextIdx = findNonKWDynamic(line, idx);
					b.push(addString(line.substring(idx, nextIdx)));
				}
				else
				{
					str = line.substring(idx, colonLoc).toUpperCase();
					if (str == "SELF")
					{
						// Self-SEND
						b[b.length-1] = CMD_SEND;
						nextIdx = findNonKWDynamic(line, colonLoc+1);
						b.push(addString(line.substring(colonLoc+1, nextIdx)));
					}
					else
					{
						// SENDTONAME
						b[b.length-1] = CMD_SENDTONAME;
						nextIdx = findNonKWDynamic(line, colonLoc+1);
						b.push(addString(str));
						b.push(addString(line.substring(colonLoc+1, nextIdx)));
					}
				}
			break;
			case CMD_DISPATCH:
				nextIdx = findNonKWDynamic(line, idx);
				b.push(addString(line.substring(idx, nextIdx)));
			break;
			case CMD_SENDTO:
			case CMD_DISPATCHTO:
				colonLoc = line.indexOf(":", idx);
				if (colonLoc != -1)
				{
					nextIdx = findNonKWDynamic(line, colonLoc+1);
					idx = parseExpr(b, line, idx);
					b.push(addString(line.substring(colonLoc+1, nextIdx)));
				}
				else
					postErrorMsg(b, "Expected:  colon", 1);
			break;
			case CMD_BIND:
				nextIdx = findNonKW(line, idx);
				b.push(addString(line.substring(idx, nextIdx)));
				nextIdx = line.length;
			break;
			case CMD_ZAP:
				colonLoc = line.indexOf(":", idx);
				if (colonLoc != -1)
				{
					b[b.length-1] = CMD_ZAPTARGET;
					b.push(addString(line.substring(idx, colonLoc)));
					nextIdx = findNonKWDynamic(line, colonLoc+1);
					b.push(addString(line.substring(colonLoc+1, nextIdx)));
					idx = nextIdx;
				}
				else
				{
					nextIdx = findNonKWDynamic(line, idx);
					b.push(addString(line.substring(idx, nextIdx)));
					idx = nextIdx;
				}
			break;
			case CMD_RESTORE:
				colonLoc = line.indexOf(":", idx);
				if (colonLoc != -1)
				{
					b[b.length-1] = CMD_RESTORETARGET;
					b.push(addString(line.substring(idx, colonLoc)));
					nextIdx = findNonKWDynamic(line, colonLoc+1);
					b.push(addString(line.substring(colonLoc+1, nextIdx)));
					idx = nextIdx;
				}
				else
				{
					nextIdx = findNonKWDynamic(line, idx);
					b.push(addString(line.substring(idx, nextIdx)));
					idx = nextIdx;
				}
			break;
			case CMD_CHAR:
			case CMD_CYCLE:
				if (idx >= line.length)
				{
					// Kludge:  enter a NOP if expression missing
					b[b.length-1] = CMD_NOP;
				}
				else
					idx = parseExpr(b, line, idx);
			break;
			case CMD_COLOR:
			case CMD_COLORALL:
			case CMD_EXTRATURNS:
			case CMD_SUSPENDDISPLAY:
				idx = parseExpr(b, line, idx);
			break;
			case CMD_PLAY:
			case CMD_PLAYSOUND:
			case CMD_USEGUI:
				b.push(addString(line.substr(idx)));
			break;
			case CMD_BECOME:
				idx = parseKind(b, line, idx);
			break;
			case CMD_CHANGE:
				idx = parseKind(b, line, idx);
				idx = findNonWSComma(line, idx);
				idx = parseKind(b, line, idx);
			break;
			case CMD_PUT:
				otherType = findMatching(line.substr(idx), miscKeywords_1);
				if (otherType == MISC_UNDER-1 || otherType == MISC_OVER-1)
				{
					idx = findNonKW(line, idx);
					idx = findNonWS(line, idx);
					b.push(DIR_UNDER + otherType - (MISC_UNDER-1));
				}
				else
				{
					idx = parseDirection(b, line, idx);
					if (idx == -1)
					{
						postErrorMsg(b, "Bad direction", 1);
						return idx;
					}
				}

				idx = findNonWSComma(line, idx);
				idx = parseKind(b, line, idx);
			break;
			case CMD_CLEAR:
				idx = parseExpr(b, line, idx, true);
			break;
			case CMD_DISSOLVEVIEWPORT:
				idx = parseExpr(b, line, idx);
			break;
			case CMD_RANDOM:
				idx = parseExpr(b, line, idx, true);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx);
			break;
			case CMD_SET:
				idx = parseExpr(b, line, idx, true);
				idx = findNonWS(line, idx);
				if (idx == line.length || oopType != -3)
				{
					b.push(SPEC_BOOLEAN); // Boolean value:  1
					b.push(1);
				}
				else
				{
					if (line.charAt(idx) == '=')
						idx = findNonWS(line, ++idx);

					idx = parseExpr(b, line, idx);
				}
			break;
			case CMD_GIVE:
			case CMD_TAKE:
				otherType = findMatching(line.substr(idx), colors_1);
				if (otherType != -1 && oopType == -3)
				{
					// Colored key inventory
					b.push(INV_KEY);
					b.push(otherType);

					idx = findNonKW(line, idx);
					idx = findNonWS(line, idx);
					if (findMatching(line.substr(idx), inventory_1) != INV_KEY-1)
						warningMsg("Inventory syntax:  [COLOR] KEY");
				}
				else
				{
					// Conventional inventory
					otherType = findMatching(line.substr(idx), inventory_1);
					if (otherType >= INV_KEY-1 || otherType < 0)
					{
						if (oopType == -3)
						{
							// ZZT Ultra mode lets any property work as inventory
							b.push(INV_EXTRA);
							otherType = INV_EXTRA + 1;
							nextIdx = findNonKW(line, idx);
							b.push(addString(line.substring(idx, nextIdx)));
						}
						else
						{
							// Inventory needs to work even if wrong
							b.push(INV_NONE);
							otherType = -1;
						}
					}
					else
						b.push(otherType+1);
				}

				// Amount to give/take
				if (otherType == -1)
				{
					// Erroneous inventory; set amount to zero
					b.push(SPEC_NUMCONST);
					b.push(0);
				}
				else
				{
					idx = findNonKW(line, idx);
					idx = findNonWSComma(line, idx);
					if (idx >= line.length)
					{
						// No inventory count; set amount to zero
						b.push(SPEC_NUMCONST);
						b.push(0);
					}
					else
						idx = parseExpr(b, line, idx);
				}

				// TAKE can execute command if out of inventory
				if (cmdType + 1 == CMD_TAKE)
				{
					// False condition jump-over
					b.push(CMD_FALSEJUMP);
					falseJumpLoc = b.length;
					b.push(0);

					idx = findNonWSComma(line, idx);
					if (idx < line.length)
						idx = parseCommand(b, line, idx);
					else
						b.push(CMD_NOP);

					// Set the false jump-over location.
					b[falseJumpLoc] = b.length;
				}
			break;
			case CMD_IF:
				if (findMatching(line.substr(idx), miscKeywords_1) == MISC_NOT-1)
				{
					idx = findNonKW(line, idx);
					idx = findNonWS(line, idx);
					b.push(SPEC_NOT);
				}
				else
					b.push(SPEC_NORM);

				otherType = findMatching(line.substr(idx), flagEvals_1);
				if (otherType == -1)
				{
					// Miscellaneous flag test
					nextIdx = findNonKW(line, idx);
					str = line.substring(idx, nextIdx);
					otherType = FLAG_GENERIC - 1;

					if (str == "")
					{
						// Special:  if no clause at all, set "always true" flag.
						otherType = FLAG_ALWAYSTRUE - 1;
					}
					else if (isNumeric(str, 0))
					{
						// Special:  if numeric field, set "always true" flag,
						// and DO NOT ADVANCE beyond the number.
						otherType = FLAG_ALWAYSTRUE - 1;
						nextIdx = idx;
					}
				}

				otherType++;
				b.push(otherType);
				idx = findNonKW(line, idx);
				idx = findNonWS(line, idx);

				switch (otherType) {
					case FLAG_ALWAYSTRUE:
						idx = nextIdx;
					break;
					case FLAG_GENERIC:
						b.push(addString(str));
					break;
					case FLAG_ANY:
						idx = parseKind(b, line, idx);
					break;
					case FLAG_ALLIGNED:
					case FLAG_ALIGNED:
					case FLAG_CONTACT:
						idx = findNonWS(line, idx);
						if (oopType != -3)
							b.push(SPEC_ALL); // ALL
						else
						{
							nextIdx = parseDirection(b, line, idx);
							if (nextIdx == -1)
								b.push(SPEC_ALL); // ALL
							else
								idx = nextIdx;
						}
					break;
					case FLAG_BLOCKED:
						idx = findNonWS(line, idx);
						nextIdx = parseDirection(b, line, idx);
						if (nextIdx == -1)
						{
							postErrorMsg(b, "Bad direction", 3);
							return idx;
						}
						else
							idx = nextIdx;
					break;
					case FLAG_CANPUSH:
					case FLAG_SAFEPUSH:
					case FLAG_SAFEPUSH1:
						idx = findNonWS(line, idx);
						idx = parseCoords(b, line, idx);
						idx = findNonWSComma(line, idx);
						nextIdx = parseDirection(b, line, idx);
						if (nextIdx == -1)
						{
							b.push(DIR_I);
							postErrorMsg(b, "Bad direction");
							return idx;
						}
						else
							idx = nextIdx;
					break;
					case FLAG_ENERGIZED:
					break;
					case FLAG_ANYTO:
						nextIdx = parseDirection(b, line, idx);
						if (nextIdx == -1)
						{
							postErrorMsg(b, "Bad direction", 3);
							return idx;
						}
						idx = findNonWSComma(line, idx);
						idx = parseKind(b, line, idx);
					break;
					case FLAG_ANYIN:
						idx = parseExpr(b, line, idx);
						idx = findNonWSComma(line, idx);
						idx = parseKind(b, line, idx);
					break;
					case FLAG_SELFIN:
						idx = parseExpr(b, line, idx);
					break;
					case FLAG_TYPEIS:
						idx = parseCoords(b, line, idx);
						idx = findNonWSComma(line, idx);
						idx = parseKind(b, line, idx);
					break;
					case FLAG_BLOCKEDAT:
						idx = parseCoords(b, line, idx);
						idx = findNonWS(line, idx);
					break;
					case FLAG_HASMESSAGE:
						idx = parseExpr(b, line, idx);
						idx = findNonWSComma(line, idx);
						nextIdx = findNonKW(line, idx);
						b.push(addString(line.substring(idx, nextIdx)));
						idx = nextIdx;
					break;
					case FLAG_TEST:
					case FLAG_VALID:
						idx = parseExpr(b, line, idx);
					break;
				}

				idx = findNonWS(line, idx);
				if (findMatching(line.substr(idx), miscKeywords_1) == MISC_THEN-1)
				{
					idx = findNonKW(line, idx);
					idx = findNonWS(line, idx);
				}

				// False condition jump-over
				b.push(CMD_FALSEJUMP);
				falseJumpLoc = b.length;
				b.push(0);

				// A wide variety of possible statements can come after #IF.
				// Based on the next character, decide.
				if (idx >= line.length)
					postErrorMsg(b, "No statement at end of #IF");
				else
					idx = parseCommand(b, line, idx);

				// Set the false jump-over location.
				b[falseJumpLoc] = b.length;

				return line.length;
			break;
			case CMD_CHAR4DIR:
				nextIdx = parseDirection(b, line, idx);
				if (nextIdx == -1)
				{
					postErrorMsg(b, "Bad direction", 1);
					return idx;
				}
				else
					idx = nextIdx;

				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx);
				idx = findNonWS(line, idx);
			break;
			case CMD_DIR2UVECT8:
				idx = parseExpr(b, line, idx);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx, true);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx, true);
				idx = findNonWS(line, idx);
			break;
			case CMD_OFFSETBYDIR:
				idx = parseCoords(b, line, idx);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx, true);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx, true);
				idx = findNonWS(line, idx);
			break;
			case CMD_SPAWN:
				otherType = findMatching(line.substr(idx), miscKeywords_1);
				if (otherType == MISC_UNDER-1 || otherType == MISC_OVER-1)
				{
					idx = findNonKW(line, idx);
					idx = findNonWS(line, idx);
					b.push(DIR_UNDER + otherType - (MISC_UNDER-1));
				}
				else
					b.push(0);

				idx = parseCoords(b, line, idx);
				idx = findNonWSComma(line, idx);
				idx = parseKind(b, line, idx);
			break;
			case CMD_SPAWNGHOST:
				idx = parseExpr(b, line, idx, true);
				idx = findNonWSComma(line, idx);
				idx = parseCoords(b, line, idx);
				idx = findNonWSComma(line, idx);
				idx = parseKind(b, line, idx);
			break;
			case CMD_CAMERAFOCUS:
				idx = parseCoords(b, line, idx);
				idx = findNonWS(line, idx);
			break;
			case CMD_SETPOS:
				idx = parseExpr(b, line, idx);
				idx = findNonWSComma(line, idx);

				otherType = findMatching(line.substr(idx), miscKeywords_1);
				if (otherType == MISC_UNDER-1 || otherType == MISC_OVER-1)
				{
					idx = findNonKW(line, idx);
					idx = findNonWS(line, idx);
					b.push(DIR_UNDER + otherType - (MISC_UNDER-1));
				}
				else
					b.push(0);

				idx = parseCoords(b, line, idx);
			break;
			case CMD_TYPEAT:
			case CMD_COLORAT:
			case CMD_OBJAT:
			case CMD_LITAT:
				idx = parseExpr(b, line, idx, true);
				idx = findNonWSComma(line, idx);
				idx = parseCoords(b, line, idx);
			break;
			case CMD_PUSHATPOS:
				idx = parseCoords(b, line, idx);
				idx = findNonWSComma(line, idx);
				nextIdx = parseDirection(b, line, idx);
				if (nextIdx == -1)
				{
					b.push(DIR_I);
					postErrorMsg(b, "Bad direction");
					return idx;
				}
			break;
			case CMD_CHANGEBOARD:
			case CMD_SAVEBOARD:
			case CMD_LOADWORLD:
			case CMD_SAVEWORLD:
			case CMD_RESTOREGAME:
				idx = parseExpr(b, line, idx);
			break;
			case CMD_LIGHTEN:
			case CMD_DARKEN:
			case CMD_KILLPOS:
				idx = parseCoords(b, line, idx);
			break;
			case CMD_CHANGEREGION:
				idx = parseExpr(b, line, idx);
				idx = findNonWSComma(line, idx);
				idx = parseKind(b, line, idx);
				idx = findNonWSComma(line, idx);
				idx = parseKind(b, line, idx);
			break;
			case CMD_CLONE:
				idx = parseCoords(b, line, idx);
			break;
			case CMD_SETREGION:
				idx = parseExpr(b, line, idx);
				idx = findNonWSComma(line, idx);
				idx = parseCoords(b, line, idx);
				idx = findNonWSComma(line, idx);
				idx = parseCoords(b, line, idx);
			break;
			case CMD_CLEARREGION:
				idx = parseExpr(b, line, idx);
			break;
			case CMD_SETPROPERTY:
				nextIdx = findNonKWDynamic(line, idx);
				b.push(addString(line.substring(idx, nextIdx)));

				idx = findNonWSComma(line, nextIdx);
				idx = parseExpr(b, line, idx);
			break;
			case CMD_GETPROPERTY:
				nextIdx = findNonKWDynamic(line, idx);
				b.push(addString(line.substring(idx, nextIdx)));

				idx = findNonWSComma(line, nextIdx);
				idx = parseExpr(b, line, idx, true);
			break;
			case CMD_SETTYPEINFO:
				idx = parseKind(b, line, idx);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx);
			break;
			case CMD_GETTYPEINFO:
				idx = parseKind(b, line, idx);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx, true);
			break;
			case CMD_SUBSTR:
				idx = parseExpr(b, line, idx, true);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx);
			break;
			case CMD_PLAYERINPUT:
				idx = parseExpr(b, line, idx, true);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx, true);
			break;
			case CMD_GETSOUND:
			case CMD_READKEY:
			case CMD_INT:
				idx = parseExpr(b, line, idx, true);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx);
			break;
			case CMD_STOPSOUND:
				idx = parseExpr(b, line, idx);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx);
			break;
			case CMD_MASTERVOLUME:
				idx = parseExpr(b, line, idx);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx);
			break;

			case CMD_DYNTEXT:
				b.push(addCString(line.substring(idx)));
			break;
			case CMD_DYNLINK:
				sepLoc = line.indexOf(";", idx);
				if (sepLoc == -1)
				{
					postErrorMsg(b, "Bad link", 1);
					return idx;
				}

				b.push(addString(line.substring(idx, sepLoc)));
				b.push(addCString(line.substring(sepLoc+1)));
			break;
			case CMD_DYNTEXTVAR:
				sepLoc = line.indexOf(";", idx);
				if (sepLoc == -1)
				{
					postErrorMsg(b, "Bad variable name", 1);
					return idx;
				}

				b.push(addString(line.substring(idx, sepLoc)));
				b.push(addCString(line.substring(sepLoc+1)));
			break;
			case CMD_SCROLLSTR:
				idx = parseExpr(b, line, idx);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx);
				idx = findNonWS(line, idx);
				b.push(addCString(line.substring(idx)));
			break;
			case CMD_SCROLLCOLOR:
				idx = parseExpr(b, line, idx); // Border
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx); // Shadow
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx); // Background
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx); // Text
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx); // Center Text
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx); // Button
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx); // Arrow
			break;
			case CMD_DUMPSE:
			case CMD_SETPLAYER:
				idx = parseExpr(b, line, idx);
			break;
			case CMD_DUMPSEAT:
				idx = parseCoords(b, line, idx);
			break;
			case CMD_TEXTTOGUI:
				nextIdx = findNonKWDynamic(line, idx);
				b.push(addString(line.substring(idx, nextIdx)));
			break;
			case CMD_TEXTTOGRID:
				idx = parseExpr(b, line, idx);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx);
			break;

			case CMD_MODGUILABEL:
				nextIdx = findNonKWDynamic(line, idx);
				b.push(addString(line.substring(idx, nextIdx))); // GUI label

				idx = findNonWSComma(line, nextIdx);
				idx = parseExpr(b, line, idx); // Column
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx); // Row
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx); // Max length
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx); // Color
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx); // Right-justify flag
			break;
			case CMD_SETGUILABEL:
				nextIdx = findNonKWDynamic(line, idx);
				b.push(addString(line.substring(idx, nextIdx))); // GUI label

				idx = findNonWSComma(line, nextIdx);
				idx = parseExpr(b, line, idx); // Expression to display
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx); // Color
			break;
			case CMD_CONFMESSAGE:
				nextIdx = findNonKWDynamic(line, idx);
				b.push(addString(line.substring(idx, nextIdx))); // GUI label

				idx = findNonWSComma(line, nextIdx);
				idx = parseExpr(b, line, idx); // Expression to display

				idx = findNonWSComma(line, idx);
				nextIdx = findNonKWDynamic(line, idx);
				b.push(addString(line.substring(idx, nextIdx))); // "Yes" dispatch message
				idx = findNonWSComma(line, nextIdx);
				nextIdx = findNonKWDynamic(line, idx);
				b.push(addString(line.substring(idx, nextIdx))); // "No" dispatch message
			break;
			case CMD_TEXTENTRY:
				nextIdx = findNonKWDynamic(line, idx);
				b.push(addString(line.substring(idx, nextIdx))); // GUI label

				idx = findNonWSComma(line, nextIdx);
				idx = parseExpr(b, line, idx); // Label init value
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx); // Max char count
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx); // Color

				idx = findNonWSComma(line, idx);
				nextIdx = findNonKWDynamic(line, idx);
				b.push(addString(line.substring(idx, nextIdx))); // "Enter" dispatch message
				idx = findNonWSComma(line, nextIdx);
				nextIdx = findNonKWDynamic(line, idx);
				b.push(addString(line.substring(idx, nextIdx))); // "Cancel" dispatch message
			break;
			case CMD_DRAWPEN:
				nextIdx = findNonKWDynamic(line, idx);
				b.push(addString(line.substring(idx, nextIdx))); // GUI label

				idx = findNonWSComma(line, nextIdx);
				idx = parseExpr(b, line, idx); // Low value extent
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx); // High value extent
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx); // Actual value
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx); // Character to show as pen
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx); // Color of pen (-1==label color)
			break;
			case CMD_SELECTPEN:
				nextIdx = findNonKWDynamic(line, idx);
				b.push(addString(line.substring(idx, nextIdx))); // GUI label

				idx = findNonWSComma(line, nextIdx);
				idx = parseExpr(b, line, idx); // Low value extent
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx); // High value extent
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx); // Actual value
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx); // Character to show as pen
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx); // Color of pen (-1==label color)
				idx = findNonWSComma(line, idx);

				nextIdx = findNonKWDynamic(line, idx);
				b.push(addString(line.substring(idx, nextIdx))); // "done" Dispatch message
			break;
			case CMD_DRAWBAR:
				nextIdx = findNonKWDynamic(line, idx);
				b.push(addString(line.substring(idx, nextIdx))); // GUI label

				idx = findNonWSComma(line, nextIdx);
				idx = parseExpr(b, line, idx); // Low value extent
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx); // High value extent
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx); // Actual value
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx); // Color of bar (-1==label color)
			break;

			case CMD_SCROLLTOVISUALS:
				idx = parseExpr(b, line, idx); // Milliseconds
				idx = findNonWSComma(line, idx);
				nextIdx = parseDirection(b, line, idx);
				if (nextIdx == -1)
				{
					postErrorMsg(b, "Bad direction", 1);
					return idx;
				}
				else
					idx = nextIdx;
			break;
			case CMD_FOREACH:
				idx = parseExpr(b, line, idx, true);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx);
			break;
			case CMD_FORMASK:
				idx = parseExpr(b, line, idx, true);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx, true);
				idx = findNonWSComma(line, idx);

				idx = parseCoords(b, line, idx);
				idx = findNonWSComma(line, idx);
				nextIdx = findNonKW(line, idx);
				b.push(addString(line.substring(idx, nextIdx)));
				idx = nextIdx;
			break;
			case CMD_FORREGION:
				idx = parseExpr(b, line, idx, true);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx, true);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx);
			break;

			case CMD_PUSHARRAY:
				idx = parseExpr(b, line, idx, true);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx);
				idx = findNonWS(line, idx);
			break;
			case CMD_POPARRAY:
				idx = parseExpr(b, line, idx, true);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx);
				idx = findNonWS(line, idx);
			break;
			case CMD_SETARRAY:
				idx = parseExpr(b, line, idx, true);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx);
				idx = findNonWS(line, idx);
			break;
			case CMD_LEN:
				idx = parseExpr(b, line, idx, true);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx);
				idx = findNonWS(line, idx);
			break;

			case CMD_SWITCHTYPE:
				idx = parseCoords(b, line, idx);
				idx = findNonWSComma(line, idx);

				sepLoc = b.length;
				b.push(0); // Label count
				while (idx < line.length)
				{
					idx = parseKind(b, line, idx); // Kind
					idx = findNonWSComma(line, idx);
					nextIdx = findNonKW(line, idx);
					b.push(addString(line.substring(idx, nextIdx))); // Label
					idx = findNonWSComma(line, nextIdx);
					b[sepLoc] = b[sepLoc] + 1;
				}
			break;
			case CMD_SWITCHVALUE:
				idx = parseExpr(b, line, idx);
				idx = findNonWSComma(line, idx);

				sepLoc = b.length;
				b.push(0); // Label count
				while (idx < line.length)
				{
					idx = parseExprValue(b, line, idx); // Expression value
					idx = findNonWSComma(line, idx);
					nextIdx = findNonKW(line, idx);
					b.push(addString(line.substring(idx, nextIdx))); // Label
					idx = findNonWSComma(line, nextIdx);
					b[sepLoc] = b[sepLoc] + 1;
				}
			break;
			case CMD_EXECCOMMAND:
				idx = parseExpr(b, line, idx);
				idx = findNonWS(line, idx);
			break;

			case CMD_DRAWCHAR:
				idx = parseCoords(b, line, idx);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx);
				idx = findNonWS(line, idx);
			break;
			case CMD_ERASECHAR:
				idx = parseCoords(b, line, idx);
				idx = findNonWS(line, idx);
			break;
			case CMD_DRAWGUICHAR:
				idx = parseExpr(b, line, idx);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx);
				idx = findNonWS(line, idx);
			break;
			case CMD_ERASEGUICHAR:
				idx = parseExpr(b, line, idx);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx);
				idx = findNonWS(line, idx);
			break;
			case CMD_GHOST:
				idx = parseExpr(b, line, idx);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx);
				idx = findNonWS(line, idx);
			break;

			case CMD_GROUPSETPOS:
			case CMD_GROUPGO:
				idx = parseCoords(b, line, idx);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx, true);
				idx = findNonWS(line, idx);
			break;
			case CMD_GROUPTRY:
			case CMD_GROUPTRYNOPUSH:
				idx = parseCoords(b, line, idx);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx, true);

				// False condition jump-over
				b.push(CMD_FALSEJUMP);
				falseJumpLoc = b.length;
				b.push(0);

				idx = findNonWSComma(line, idx);
				if (idx < line.length)
					idx = parseCommand(b, line, idx);
				else
					b.push(CMD_NOP);

				// Set the successful move jump-over location.
				b[falseJumpLoc] = b.length;
			break;

			case CMD_ATAN2:
				idx = parseCoords(b, line, idx);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx, true);
			break;
			case CMD_SMOOTHTEST:
				idx = parseExpr(b, line, idx);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx);
			break;
			case CMD_SMOOTHMOVE:
				idx = parseExpr(b, line, idx);
			break;

			case CMD_READMOUSE:
			break;

			case CMD_SETCONFIGVAR:
				idx = parseExpr(b, line, idx);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx);
				idx = findNonWS(line, idx);
			break;
			case CMD_GETCONFIGVAR:
				idx = parseExpr(b, line, idx);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx, true);
				idx = findNonWS(line, idx);
			break;
			case CMD_DELCONFIGVAR:
				idx = parseExpr(b, line, idx);
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx);
				idx = findNonWS(line, idx);
			break;
			case CMD_DELCONFIGHIVE:
				idx = parseExpr(b, line, idx);
				idx = findNonWS(line, idx);
			break;
			case CMD_SYSTEMACTION:
				if (idx == line.length)
				{
					b[b.length - 1] = CMD_SEND;
					b.push(addString("SYSTEMACTION"));
				}
				else
					idx = parseExpr(b, line, idx);
			break;

			case CMD_SCANLINES:
			case CMD_BIT7ATTR:
				idx = parseExpr(b, line, idx);
			break;
			case CMD_FADETOCOLOR:
			case CMD_PALETTECOLOR:
				idx = parseExpr(b, line, idx); // Palette Index / Milliseconds
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx); // Red
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx); // Green
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx); // Blue
			break;
			case CMD_PALETTEBLOCK:
				idx = parseExpr(b, line, idx); // Start index
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx); // Number of indexes
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx); // Extent
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx); // Mask/Lump string or array name
			break;
			case CMD_FADETOBLOCK:
				idx = parseExpr(b, line, idx); // Milliseconds
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx); // Start index
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx); // Number of indexes
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx); // Extent
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx); // Mask/Lump string or array name
			break;
			case CMD_CHARSELECT:
				idx = parseExpr(b, line, idx); // Mask/Lump string or array name
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx); // Cell X Size
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx); // Cell Y Size
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx); // Cells Across
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx); // Cells Down
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx); // Starting character index
			break;

			case CMD_POSTHS:
				idx = parseExpr(b, line, idx); // Text line expression
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx); // Filename expression
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx); // Sort key expression
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx); // Sort order expression
			break;
			case CMD_GETHS:
				idx = parseExpr(b, line, idx); // Filename expression
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx); // Sort key expression
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx); // Sort order expression
			break;
			case CMD_GETHSENTRY:
				idx = parseExpr(b, line, idx, true); // LValue that receives entry
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx); // Line number expression
				idx = findNonWSComma(line, idx);
				idx = parseExpr(b, line, idx); // Index number expression
			break;
		}
	}

	return idx;
}

// Parse coordinates.
public static function parseCoords(b:Array, line:String, idx:int):int {
	var c1:String = line.charAt(idx);
	if (c1 == "[")
	{
		// "Polar" relative coordinates
		b.push(SPEC_POLAR);
		idx = parseExpr(b, line, ++idx);

		idx = findNonWS(line, idx);
		if (line.charAt(idx) == ",")
		{
			idx = findNonWS(line, ++idx);
			//postErrorMsg(b, "Expected:  comma (for polar coordinates)");
			//return idx;
		}

		idx = parseExpr(b, line, idx);
		idx = findNonWS(line, idx);
		if (line.charAt(idx) == "]")
		{
			idx++;
			//postErrorMsg(b, "Expected:  ]");
			//return idx;
		}

		return idx;
	}
	else if (c1 == "+" || c1 == "-")
	{
		// Relative coordinates
		if (c1 == "+")
			b.push(SPEC_ADD);
		else
			b.push(SPEC_SUB);

		idx = parseExpr(b, line, ++idx);
		idx = findNonWS(line, idx);
		if (line.charAt(idx) == ",")
		{
			idx = findNonWS(line, ++idx);
			//postErrorMsg(b, "Expected:  comma (for relative coordinates)");
			//return idx;
		}

		c1 = line.charAt(idx++);
		if (c1 == "+")
			b.push(SPEC_ADD);
		else if (c1 == "-")
			b.push(SPEC_SUB);
		else
		{
			b.push(SPEC_ADD);
			idx--;
			//postErrorMsg(b, "Expected:  +/-");
			//return idx;
		}

		idx = findNonWS(line, idx);
		idx = parseExpr(b, line, idx);

		return idx;
	}
	else
	{
		// Absolute coordinates
		b.push(SPEC_ABS);
		idx = parseExpr(b, line, idx);
		idx = findNonWS(line, idx);
		if (line.charAt(idx) == ",")
		{
			idx = findNonWS(line, ++idx);
			//postErrorMsg(b, "Expected:  comma (for absolute coordinates)");
			//return idx;
		}

		idx = parseExpr(b, line, idx);
		return idx;
	}
}

// Parse kind (a valid ZZT-OOP type representing something in the grid).
public static function parseKind(b:Array, line:String, idx:int):int {
	if (idx >= line.length)
	{
		// Strange parsing case causes lack of kind to translate into BOARDEDGE.
		b.push(SPEC_KINDNORM);
		b.push(1);
		b.push(SPEC_KWARGEND);
		return idx;
	}

	// Skip '#' if present
	if (line.charAt(idx) == '#')
		idx++;

	// Check if kind is a special representation
	var sType:int = findMatching(line.substr(idx), miscKeywords_1);
	if (sType+1 == MISC_ALL || sType+1 == MISC_CLONE)
	{
		// Enter:  special representation
		b.push(SPEC_KINDMISC);
		b.push(sType+1);

		idx = findNonKW(line, idx);
		return idx;
	}

	// Find color qualifier, if one exists
	var cType:int = findMatching(line.substr(idx), colors_1);
	if (cType != -1)
	{
		if (oopType != -3)
			cType += 9;
		idx = findNonKW(line, idx);
		idx = findNonWS(line, idx);
	}

	// Check if kind is present
	var kType:int = findMatching(line.substr(idx), kinds);
	if (kType != -1)
	{
		// Kind is a well-known type.
		if (kType > 19)
			kType--; // LAVA type is same as WATER type
		if (kType >= 46)
			kType++; // Skip over missing type before FLOOR
		if (kType >= 52)
			kType += 7; // Skip over missing types before ROTON
		if (kType >= 65)
			kType += 8; // Skip over missing types before _TEXTBLUE
		if (kType == 80)
			kType = 253; // This is the _WINDTUNNEL type

		// Enter:  normal kind
		b.push(SPEC_KINDNORM);
		b.push(kType);
		idx = findNonKW(line, idx);
	}
	else
	{
		kType = findMatching(line.substr(idx), zzt.extraKindNames);
		if (kType != -1)
		{
			// Enter:  normal kind
			b.push(SPEC_KINDNORM);
			b.push(zzt.extraKindNumbers[kType]);
			idx = findNonKW(line, idx);
		}
		else if (idx >= line.length)
		{
			// Strange "color only" parsing case causes lack of kind to translate
			// into colored BOARDEDGE.
			b.push(SPEC_KINDNORM);
			b.push(1);
		}
		else
		{
			// Enter:  expression-based type
			b.push(SPEC_KINDEXPR);
			idx = parseExpr(b, line, idx);
		}
	}

	// If color qualifier present, immediately enter as a kwarg
	if (cType != -1 && !(oopType != -3 && kType == 0))
	{
		b.push(KWARG_COLOR);
		b.push(SPEC_NUMCONST); // Numeric constant
		b.push(cType);
	}

	// Handle remaining kwargs, if any
	idx = findNonWS(line, idx);
	do {
		// No (more) kwargs; done
		if (idx == line.length)
			break;
		if (line.charAt(idx) != ";")
			break;

		// Identify kwarg
		var kwType:int = findMatching(line.substr(++idx), keywordArgs);
		if (kwType == -1)
		{
			b.push(KWARG_X);
			postErrorMsg(b, "Bad KIND keyword argument:  " + line.substr(idx-1));
			return idx;
		}

		// Handle aliases for P1, P2, and P3
		kwType++;
		if (kwType == KWARG_INTELLIGENCE || kwType == KWARG_SENSITIVITY ||
			kwType == KWARG_PHASE)
			kwType = KWARG_P1;
		else if (kwType == KWARG_PERIOD || kwType == KWARG_RESTINGTIME ||
			kwType == KWARG_DEVIANCE || kwType == KWARG_RATE)
			kwType = KWARG_P2;
		else if (kwType == KWARG_DESTINATION)
			kwType = KWARG_P3;
		else if (kwType == KWARG_BIND)
			kwType = KWARG_ONAME;

		b.push(kwType);

		idx = findNonKW(line, idx);
		idx = findNonWS(line, idx);
		if (line.charAt(idx) != "=")
		{
			postErrorMsg(b, "Expected:  =", 1);
			return idx;
		}

		// Identify kwarg value
		idx = parseExpr(b, line, ++idx);
	} while (idx < line.length);

	// End of kwargs
	b.push(SPEC_KWARGEND);
	return idx;
}

// Parse direction.
public static function parseDirection(b:Array, line:String, idx:int, allowExpr:Boolean=true):int {
	// Find direction keyword
	var dType:int;
	var expectCoords:Boolean = false;
	lastDirType = -1;

	do {
		dType = findMatching(line.substr(idx), directions_1);
		if (dType != -1)
		{
			// Direction keyword found
			dType++;
			if (dType <= 10 && (dType & 1) == 0)
				dType--; // NORTH -> N, SOUTH -> S, etc.
			b.push(dType);
			lastDirType = dType;

			idx = findNonKW(line, idx);
			if (dType > DIR_RND)
				idx = findNonWS(line, idx);

			if (dType == DIR_TOWARDS)
				expectCoords = true;
		}
		else if (!allowExpr)
		{
			// Already checked expression types; take ONLY direction keywords.
			return -1;
		}
		else if (line.charAt(idx) == "." || line.charAt(idx) == '(')
		{
			// See if this is a local var or expression
			b.push(SPEC_EXPRPRESENT);
			idx = parseExpr(b, line, idx);
		}
		else
		{
			// Did not find anything conforming to a direction.
			// This is not actually considered an error, because
			// where a direction might exist, it could be optional.
			return -1;
		}

		// If direction was a prefix, we need to read another.
	} while ((dType >= DIR_CW && dType <= DIR_OPP) || dType >= DIR_MAJOR)

	if (expectCoords)
		return (parseCoords(b, line, idx));

	return idx;
}

// Parse direction and optional length (number of times to repeat movement).
public static function parseDirAndLength(b:Array, line:String, idx:int):int {
	// Direction must be present.
	var goStart:int = b.length - 1;
	idx = parseDirection(b, line, idx);
	if (idx == -1)
	{
		postErrorMsg(b, "Bad direction", 1);
		return idx;
	}
	var goEnd:int = b.length;

	idx = findNonWS(line, idx);
	if (idx < line.length)
	{
		if (isNumeric(line, idx) && oopType != -1)
		{
			var eLoc:int = findNonKW(line, idx);
			var repCount:int = int(line.substring(idx, eLoc));
			idx = findNonWS(line, eLoc);

			// Repeat last operation.
			while (--repCount > 0)
			{
				var unitSlice:Array = b.slice(goStart, goEnd);
				for (var i:int = 0; i < unitSlice.length; i++)
					b.push(unitSlice[i]);
			}
		}
	}

	return idx;
}

// Parse direction and optional sub-command (operation to perform if unable to move).
public static function parseDirAndAction(b:Array, line:String, idx:int):int {
	// Direction must be present.
	idx = parseDirection(b, line, idx);
	if (idx == -1)
	{
		postErrorMsg(b, "Bad direction", 1);
		return idx;
	}

	// Successful move condition jump-over
	b.push(CMD_FALSEJUMP);
	var falseJumpLoc:int = b.length;
	b.push(0);

	idx = findNonWS(line, idx);
	if (idx < line.length)
	{
		idx = parseCommand(b, line, idx);
	}
	else
	{
		b.push(CMD_NOP);
	}

	// Set the successful move jump-over location.
	b[falseJumpLoc] = b.length;

	return idx;
}

// Parse expression.
public static function parseExpr(b:Array, line:String, idx:int, lValue:Boolean=false):int {
	// Error if rest of line is empty
	if (idx >= line.length)
	{
		postErrorMsg(b, "Expected:  Expression");
		return idx;
	}

	// See if expression operator present
	if (line.charAt(idx) != "(")
		return (parseExprValue(b, line, idx, lValue)); // No expression; just one value

	// Parse expression values
	idx++;
	var moreVals:Boolean = true;
	b.push(SPEC_EXPRPRESENT); // Expression present
	while (moreVals) {
		// Value
		idx = findNonWS(line, idx);
		idx = parseExprValue(b, line, idx);
		if (idx == -1)
			return -1; // Error

		// Operator
		idx = findNonWS(line, idx);
		var c:String = line.charAt(idx);
		if (c == ']')
		{
			idx = findNonWS(line, idx+1);
			c = line.charAt(idx);
		}
		if (c == ')')
		{
			b.push(SPEC_EXPREND);
			moreVals = false;
		}
		else
		{
			var op:int = opChars.indexOf(c);
			if (op == -1)
			{
				b.push(OP_ADD);
				postErrorMsg(b, "Expected:  operator or ')'");
				return idx;
			}
			else
			{
				op++;
				if ((op == OP_GRE || op == OP_LES) && idx + 1 < line.length)
				{
					if (line.charAt(idx+1) == '=')
					{
						op += (OP_GOE - OP_GRE);
						idx++;
					}
				}
				else if ((op == OP_NEQ || op == OP_EQU) && idx + 1 < line.length)
				{
					if (line.charAt(idx+1) == '=')
						idx++;
				}

				b.push(op);
			}
		}

		idx = findNonWS(line, ++idx);
	}

	return idx;
}

// Parse a single value in an expression.
public static function parseExprValue(b:Array, line:String, idx:int, lValue:Boolean=false):int {
	// An expression value can be one of the following:
	// 1) Numeric constant
	// 2) String constant
	// 3) Local variable name
	// 4) Global variable name
	// 5) Kind (numeric constant)
	// 6) Color (numeric constant)
	// 7) Direction

	var eLoc:int;
	if (line.length == idx)
	{
		postErrorMsg(b, "Expected:  value");
		return idx;
	}
	else if (isNumeric(line, idx) || line.charAt(idx) == '-')
	{
		if (lValue)
		{
			postErrorMsg(b, "LValue required");
			return line.length;
		}

		// Numeric constant
		if (line.charAt(idx) == '-')
			eLoc = findNonKW(line, idx+1);
		else
			eLoc = findNonKW(line, idx);
		b.push(SPEC_NUMCONST);
		b.push(int(line.substring(idx, eLoc)));
		idx = findNonWS(line, eLoc);
	}
	else if (oopType != -3)
	{
		// ZZT or Super ZZT expression henceforth can only be global variable name
		eLoc = findNonKWDynamic(line, idx);
		b.push(SPEC_GLOBALVAR);
		b.push(addString(line.substring(idx, eLoc)));
		idx = findNonWS(line, eLoc);
	}
	else if (line.charAt(idx) == "\"")
	{
		if (lValue)
		{
			postErrorMsg(b, "LValue required");
			return line.length;
		}

		// String constant
		eLoc = line.indexOf("\"", idx+1)
		if (!eLoc)
			postErrorMsg(b, "Bad string constant");
		else
		{
			b.push(SPEC_STRCONST);
			b.push(addCString(line.substring(idx+1, eLoc)));
			idx = findNonWS(line, eLoc+1);
		}
	}
	else if (line.charAt(idx) == ".")
	{
		// Local variable
		eLoc = findNonKW(line, idx+1);
		b.push(SPEC_LOCALVAR);
		b.push(addString(line.substring(idx+1, eLoc)));
		idx = findNonWS(line, eLoc);
	}
	else if (line.charAt(idx) == "~")
	{
		// Property
		eLoc = findNonKW(line, idx+1);
		b.push(SPEC_PROPERTY);
		b.push(addString(line.substring(idx+1, eLoc)));
		idx = findNonWS(line, eLoc);
	}
	else if (lValue)
	{
		// Word can only be L-Value by this point (global variable name)
		eLoc = findNonKWDynamic(line, idx);
		b.push(SPEC_GLOBALVAR);
		b.push(addString(line.substring(idx, eLoc)));
		idx = findNonWS(line, eLoc);
	}
	else if (findMatching(line.substr(idx), ["SELF"]) != -1 && oopType == -3)
	{
		if (lValue)
		{
			postErrorMsg(b, "Expected:  LValue");
			return line.length;
		}

		// "Self" object pointer
		b.push(SPEC_SELF);
		b.push(0);
		idx = findNonWS(line, idx + 4);
	}
	else
	{
		// Check if kind is present
		var kType:int = findMatching(line.substr(idx), kinds);
		var cType:int = findMatching(line.substr(idx), colors_1);
		var kType2:int = findMatching(line.substr(idx), zzt.extraKindNames);
		if (kType != -1)
		{
			// Kind is a well-known type.
			if (kType > 19)
				kType--; // LAVA type is same as WATER type
			if (kType >= 46)
				kType++; // Skip over missing type before FLOOR
			if (kType >= 52)
				kType += 7; // Skip over missing types before ROTON
			if (kType >= 65)
				kType += 8; // Skip over missing types before _TEXTBLUE
			if (kType == 80)
				kType = 253; // This is the _WINDTUNNEL type

			// Acts as a numeric constant; translation needed later
			b.push(SPEC_KINDCONST);
			b.push(kType);
			idx = findNonKW(line, idx);
			idx = findNonWS(line, idx);
		}
		else if (kType2 != -1)
		{
			// Enter:  extra kind
			b.push(SPEC_KINDCONST);
			b.push(zzt.extraKindNumbers[kType2]);
			idx = findNonKW(line, idx);
			idx = findNonWS(line, idx);
		}
		else if (cType != -1)
		{
			// Acts as a numeric constant
			b.push(SPEC_NUMCONST);
			b.push(cType);
			idx = findNonKW(line, idx);
			idx = findNonWS(line, idx);
		}
		else
		{
			// Direction?
			b.push(SPEC_DIRCONST);
			var dIdx:int = parseDirection(b, line, idx, false);
			if (dIdx == -1)
			{
				// Global variable name or miscellaneous member
				b[b.length-1] = SPEC_GLOBALVAR;
				eLoc = findNonKWDynamic(line, idx);
				b.push(addString(line.substring(idx, eLoc)));
				idx = findNonWS(line, eLoc);
			}
			else
			{
				// Direction:  Yes
				idx = findNonWS(line, dIdx);
			}
		}
	}

	return idx;
}

public static function getCommandStr(cByte:int):String {
	// Reverse-engineer the compiled command opcode.
	if (cByte == 0)
		return "ERROR: ";

	if (cByte >= CMD_FALSEJUMP && cByte <= CMD_NAME)
		return (nonSpelledCommandStr[cByte - CMD_FALSEJUMP]);

	if (cByte > 0 && cByte <= commands_x.length)
		return (commands_x[cByte]);

	return "Unknown: " + cByte.toString();
}

public static function getColorStr(cByte:int):String {
	// Reverse-engineer color constants.
	if (cByte < 0 || cByte >= 16)
		return cByte.toString();

	return colors_x[cByte];
}

public static function getInventoryStr(cByte:int):String {
	// Reverse-engineer inventory constants.
	if (cByte <= 0 || cByte > inventory_x.length)
		return "NONE";

	return inventory_x[cByte-1];
}

public static function getConditionStr(cByte:int):String {
	// Reverse-engineer condition constants.
	if (cByte > 0 && cByte <= flagEvals_x.length)
		return flagEvals_x[cByte-1];

	return "";
}

public static function getDirStr(cByte:int):String {
	// Reverse-engineer direction constants.
	if (cByte > 0 && cByte <= directions_x.length)
		return directions_x[cByte-1];

	return "";
}

public static function getKwargTypeStr(cByte:int):String {
	// Reverse-engineer keyword argument constants.
	if (cByte > 0 && cByte <= keywordArgs.length)
		return keywordArgs[cByte-1];

	return "";
}

public static function getOpStr(cByte:int):String {
	// Reverse-engineer keyword argument constants.
	if (cByte > 0 && cByte <= opLookupStr.length)
		return opLookupStr[cByte-1];

	if (cByte == SPEC_EXPREND)
		return ")";

	return "";
}

};
};

-------------------------------------
Source code for ZZT Ultra version 1.0
-------------------------------------

The source code was developed by Christopher Allen.  It is FreeWare.

The code is subject to the Creative Commons license BY-NC license (see license
link below).

http://creativecommons.org/licenses/by-nc/4.0/legalcode

Basically, you can use the code as you please, but you must attribute credit
to the original author wherever the code is used or published.  Furthermore,
all code usage is subject to a non-commercial restriction.


---------------------
Source code file list
---------------------

. ZZTUltra.fla

The Adobe Flash project is rather resource-light.  The "Release" configuration
depends on ActionScript 3 deployment to SWF (with at least Flash version 10).
The publish settings also incorporate the use of as3corlib, which is used when
invoking JSON services.

It is expected that future releases of the project source code will require a
more advanced CC version.  If this happens, the need for as3corlib will likely
also disappear (JSON is built directly into the API in later Flash versions).

. .flashProjectProperties

Supports ZZTUltra.fla.

. zzt.as

The main "top-level" class.

. interp.as

The compiled opcode interpreter for ZZT-OOP code.

. oop.as

ZZT-OOP code compiler.

. input.as

Input-handling code for mouse and keyboard.  The program state heavily impacts
how user input is interpreted.

. editor.as

This class contains the functionality for both the GUI editor and the world
editor.

. ZZTLoader.as

This class handles loading and saving of world files, patching of world files,
and various board state transitioning, saving, and restoring operations.

. parse.as

This class supports file system and web resource loading/saving operations.

. ZipFile.as

Zip file processing class.

. Sounds.as

The sound system class.

. CellGrid.as

This class comprises the text-mode video emulation layer.

. ASCII_Characters.as

This class controls the stock character sets used to represent individual
ASCII characters for the 8x8, 8x14, and 8x16 default character sets.

. ZZTBoard.as

A record of a single board within a world.

. ElementInfo.as

This class represents a type definition.

. SE.as

Status element class.  This is a staple for any "object" found in a board.
Each board controls a vector of all status elements for that board.

. ZapRecord.as

This class stores a record of a zapped message label in program code.  Vectors
of this class compose a full zap history.

. FxEnvelope.as

A single sound "channel" class.  The way the ZZT Ultra sound system works, the
class does not represent an actual unique playback device because of position
accuracy issues caused by having multiple devices.  Instead, data from all
sound effect channels are mixed by Sounds.as, which supports only one
"genuine" sound playback device.

. IPoint.as

Integer coordinate pair class; used by editor fill operations.

utils.as

Various low-level utility functions.


-------------
GUI file list
-------------

There are a lot of ZZTGUI files in the "guis" folder, whose purposes speak
for themselves.  Load these in the GUI editor to see how they work.

Also, the "comma_xxxxxx.txt" files are used by the zzt_guis.txt rebuild line
(see guis/README.TXT) as a way to automatically stack the GUI components
within the resulting composite file.  There is no need to cover these files
in detail.

. README.txt

This describes how to build zzt_guis.txt.  This file begins with the contents
of zzt_guis_Orig.txt and has numerous other ZZTGUI files appended.

. zzt-oop.xml
. zzt-oop2.xml

Notepad++ syntax highlighting formats for ZZT-OOP.  If you want to use syntax
highlighting when editing code outside of the ZZT Ultra editor, try these.

. zzt_guis.txt

All built-in GUIs for ZZT Ultra.  Note that this includes not only the debug
menu and in-game GUIs, but also the editor-oriented GUIs, high score entry
GUIs, option selection GUIs, and the title GUIs for Super ZZT games.

. zzt_guis_orig.txt

Most of the built-in GUIs for ZZT Ultra; most of these are used by the editor.

. zzt_ini.txt

Configuration file loaded when ZZT Ultra starts up.  The official download
package for ZZT Ultra describes how this file works.

. zzt_objs.txt

All built-in type definitions for ZZT Ultra, including the default code for
player, item, and monster behaviors.  The official documentation on the web
page describes how type definitions work.

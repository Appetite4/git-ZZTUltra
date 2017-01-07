// input.as:  The program's input-handling functions.

package {

// Imports
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;

public class input {

// Constants
public static const MOUSE_WHEEL_COUNT_THRESHOLD:int = 4;
public static const MOUSE_WHEEL_TIME_THRESHOLD:int = 3;
public static const MOUSE_WHEEL_MULTIPLIER:int = 3;

public static const C2M_MODE_TOWARDS:int = 1;
public static const C2M_MODE_CCW:int = 2;
public static const C2M_MODE_CW:int = 3;
public static const C2M_MODE_EXTEND:int = 4;

public static const C2M_GIVEUP_THRESHOLD:int = 1500;

// Keyboard and mouse info
public static var keyCodeDowns:Vector.<int>; // Vector of keypress timing
public static var keyCharDowns:Vector.<int>; // Vector of keypress timing
public static var lastWheelMCount:int = 0; // Last mouse wheel event count
public static var progWheelCount:int = 0; // Progressive mouse wheel move count
public static var mDownCount:int = 0; // Start time of last mouse-down
public static var mDown:Boolean = false; // Mouse-down status (LMB)
public static var mouseXGridPos:int = 0; // Last mouse X screen position (0-based)
public static var mouseYGridPos:int = 0; // Last mouse Y screen position (0-based)

// Mouse click-to-move location info
public static var c2MMode:int = C2M_MODE_TOWARDS;
public static var c2MCount:int = 0;
public static var c2MDestX:int = -1;
public static var c2MDestY:int = -1;
public static var c2MDir:int = 0;
public static var c2MBeatDist:int = 0;
public static var lastPlayerX:int = -1;
public static var lastPlayerY:int = -1;
public static var c2MCircleDestX:int = -1;
public static var c2MCircleDestY:int = -1;
public static var c2MExtendDestX:int = -1;
public static var c2MExtendDestY:int = -1;
public static var c2MExtendDir:int = 0;
public static var c2MMoveCountLowest:int = 0;

// Genuine key-down handler
public static function keyPressed(event:KeyboardEvent):void
{
	var theCode:uint = event.keyCode;
	var charCode:uint = event.charCode;
	var shiftStatus:Boolean = event.shiftKey;
	var ctrlStatus:Boolean = event.ctrlKey;
	if (keyCodeDowns[theCode & 255] == 0)
	{
		keyCodeDowns[theCode & 255] = zzt.mcount;
		keyCharDowns[charCode & 255] = zzt.mcount;
	}

	// Physically pressing a key instantly cancels click-to-move.
	c2MDestX = -1;
	c2MDestY = -1;
	keyDownHandler(theCode, charCode & 255, shiftStatus, ctrlStatus);
}

// This is an "externally written" key-down handler, posted from other input contexts
public static function extraKeyDownHandler(
	keyCode:uint, keyChar:uint, shiftStatus:Boolean, ctrlStatus:Boolean, minDelay:int):void {
	if (keyCodeDowns[keyCode] != 0)
	{
		if (zzt.mcount - keyCodeDowns[keyCode] >= minDelay)
			keyDownHandler(keyCode, keyChar, shiftStatus, ctrlStatus);
	}
}

// Common key-down handler, regardless of input origin
public static function keyDownHandler(theCode:uint, charCode:uint,
	shiftStatus:Boolean, ctrlStatus:Boolean):void {
	//trace(theCode);
	var mappingIdx:int = (shiftStatus ? 1 : 0) + (ctrlStatus ? 2 : 0);
	var guiKeyMappingArray:Array = zzt.GuiKeyMappingAll[mappingIdx];

	switch (zzt.mainMode) {
		case zzt.MODE_NORM:
			if (theCode < 0 || theCode >= 256)
				break;
			if (zzt.activeObjs)
			{
				// Handle gameplay-oriented move and shoot code setting
				switch (theCode) {
					case 37: // Left
						if (shiftStatus)
							zzt.pShootDir = 2;
						else
							zzt.pMoveDir = 2;
					break;
					case 38: // Up
						if (shiftStatus)
							zzt.pShootDir = 3;
						else
							zzt.pMoveDir = 3;
					break;
					case 39: // Right
						if (shiftStatus)
							zzt.pShootDir = 0;
						else
							zzt.pMoveDir = 0;
					break;
					case 40: // Down
						if (shiftStatus)
							zzt.pShootDir = 1;
						else
							zzt.pMoveDir = 1;
					break;
				}
			}

			// Handle key code based on GUI's defined handling.
			if (zzt.inEditor && (editor.drawFlag == editor.DRAW_TEXT || editor.hexTextEntry > 0))
			{
				// Type key to text-drawing feature of world editor.
				if (theCode >= 37 && theCode <= 40 || theCode == 27)
				{
					// Cursor direction keys and ESC are dispatched.
					if (guiKeyMappingArray[theCode] != "")
						zzt.dispatchInputMessage(guiKeyMappingArray[theCode]);
				}
				else if ((charCode >= 32 && charCode < 127 || charCode == 8) && !ctrlStatus)
					editor.writeTextDrawChar(charCode);
				else if (guiKeyMappingArray[theCode] != "")
					zzt.dispatchInputMessage(guiKeyMappingArray[theCode]);
			}
			else if (guiKeyMappingArray[theCode] != "")
			{
				// Normal dispatch
				zzt.dispatchInputMessage(guiKeyMappingArray[theCode]);
			}
			else if (editor.typingTextInGuiEditor && theCode != 16)
			{
				// Type key to GUI editor.
				editor.writeKeyToGuiEditor(charCode & 255);
			}
			break;

		case zzt.MODE_CONFMESSAGE:
			if (theCode == 37 || theCode == 39 || theCode == 9) // Left or right or tab
			{
				// Change selected confirmation button
				zzt.confButtonSel = zzt.confButtonSel + 1 & 1;
				zzt.drawConfButtons();
			}
			else if (theCode == 27 && zzt.confCancelMsg != "")
			{
				// Cancel, if allowed
				zzt.unDrawConfButtons();
				zzt.eraseGuiLabel(zzt.confLabelStr);
				zzt.mainMode = zzt.MODE_NORM;
				zzt.dispatchInputMessage(zzt.confCancelMsg);
			}
			else if (theCode == 78)
			{
				// No
				zzt.unDrawConfButtons();
				zzt.eraseGuiLabel(zzt.confLabelStr);
				zzt.mainMode = zzt.MODE_NORM;
				zzt.dispatchInputMessage(zzt.confNoMsg);
			}
			else if (theCode == 89)
			{
				// Yes
				zzt.unDrawConfButtons();
				zzt.eraseGuiLabel(zzt.confLabelStr);
				zzt.mainMode = zzt.MODE_NORM;
				zzt.dispatchInputMessage(zzt.confYesMsg);
			}
			else if (theCode == 13)
			{
				// Choose selected confirmation button
				zzt.unDrawConfButtons();
				zzt.eraseGuiLabel(zzt.confLabelStr);
				zzt.mainMode = zzt.MODE_NORM;
				zzt.dispatchInputMessage(
					(zzt.confButtonSel == 0) ? zzt.confYesMsg : zzt.confNoMsg);
			}
			break;

		case zzt.MODE_TEXTENTRY:
			if (theCode == 13)
			{
				// Yes
				zzt.eraseGuiLabel(zzt.confLabelStr);
				zzt.mainMode = zzt.MODE_NORM;
				zzt.globals["$TEXTRESULT"] = zzt.textChars;
				zzt.dispatchInputMessage(zzt.confYesMsg);
			}
			else if (theCode == 27)
			{
				// No
				zzt.eraseGuiLabel(zzt.confLabelStr);
				zzt.mainMode = zzt.MODE_NORM;
				zzt.dispatchInputMessage(zzt.confNoMsg);
			}
			else if (theCode == 8 || theCode == 37)
			{
				if (zzt.textChars.length > 0)
					zzt.textChars = zzt.textChars.substring(0, zzt.textChars.length - 1);
				zzt.drawGuiLabel(zzt.confLabelStr, zzt.textChars + " ", zzt.textCharsColor);
			}
			else if (zzt.textChars.length < zzt.textMaxCharCount &&
				charCode >= 32 && charCode < 127)
			{
				zzt.textChars += String.fromCharCode(charCode);
				zzt.drawGuiLabel(zzt.confLabelStr, zzt.textChars, zzt.textCharsColor);
			}
			break;

		case zzt.MODE_SELECTPEN:
			if (theCode == 37) // Left
			{
				if (zzt.penStartVal < zzt.penEndVal)
				{
					if (--zzt.penActVal < zzt.penStartVal)
						zzt.penActVal = zzt.penStartVal;
				}
				else
				{
					if (++zzt.penActVal > zzt.penStartVal)
						zzt.penActVal = zzt.penStartVal;
				}
				zzt.drawPen(zzt.confLabelStr, zzt.penStartVal, zzt.penEndVal, zzt.penActVal,
					zzt.penChrCode, zzt.penAttr);
			}
			else if (theCode == 39) // Right
			{
				if (zzt.penStartVal < zzt.penEndVal)
				{
					if (++zzt.penActVal > zzt.penEndVal)
						zzt.penActVal = zzt.penEndVal;
				}
				else
				{
					if (--zzt.penActVal < zzt.penEndVal)
						zzt.penActVal = zzt.penEndVal;
				}
				zzt.drawPen(zzt.confLabelStr, zzt.penStartVal, zzt.penEndVal, zzt.penActVal,
					zzt.penChrCode, zzt.penAttr);
			}
			else if (theCode == 13 || theCode == 27) // Done
			{
				zzt.drawPen(zzt.confLabelStr, zzt.penStartVal, zzt.penEndVal, zzt.penActVal,
					zzt.penChrCode, -1);
				zzt.mainMode = zzt.MODE_NORM;
				zzt.globals["$PENRESULT"] = zzt.penActVal;
				zzt.dispatchInputMessage(zzt.confYesMsg);
			}
			break;

		case zzt.MODE_SCROLLINTERACT:
			if (theCode == 38)
			{
				zzt.mouseScrollOffset = 0;
				zzt.msgScrollIndex--; // Up
			}
			else if (theCode == 40)
			{
				zzt.mouseScrollOffset = 0;
				zzt.msgScrollIndex++; // Down
			}
			else if (theCode == 33)
			{
				zzt.mouseScrollOffset = 0;
				zzt.msgScrollIndex -= zzt.msgScrollHeight; // Page Up
			}
			else if (theCode == 34)
			{
				zzt.mouseScrollOffset = 0;
				zzt.msgScrollIndex += zzt.msgScrollHeight; // Page Down
			}
			else if (theCode == 36)
			{
				zzt.mouseScrollOffset = 0;
				zzt.msgScrollIndex = 0; // Home
			}
			else if (theCode == 35)
			{
				zzt.mouseScrollOffset = 0;
				zzt.msgScrollIndex = zzt.msgScrollText.length - 1; // End
			}
			else if (theCode == 13)
				zzt.scrollInterfaceButton();
			else if (zzt.inEditor)
				editor.specialScrollKeys(theCode);
			else if (theCode == 27)
				zzt.mainMode = zzt.MODE_SCROLLCLOSE; // Done

			if (zzt.msgScrollIndex < 0)
				zzt.msgScrollIndex = 0;
			if (zzt.msgScrollIndex >= zzt.msgScrollText.length)
				zzt.msgScrollIndex = zzt.msgScrollText.length - 1;

			zzt.drawScrollMsgText();
			break;

		case zzt.MODE_FILEBROWSER:
			if (theCode == 27)
			{
				// Done; return to archive or normal mode
				zzt.fbg.visible = false;
				if (zzt.modeWhenBrowserClosed == zzt.MTRANS_ZIPSCROLL)
					zzt.zipContentsScroll();
				else if (zzt.modeWhenBrowserClosed == zzt.MTRANS_SAVEWORLD)
				{
					zzt.mainMode = zzt.MODE_NORM;
					editor.saveWorld();
				}
				else
					zzt.mainMode = zzt.MODE_NORM;
			}
			else if (theCode == 38)
				zzt.moveFileBrowser(zzt.textBrowserCursor - 1); // Up
			else if (theCode == 40)
				zzt.moveFileBrowser(zzt.textBrowserCursor + 1); // Down
			else if (theCode == 33)
				zzt.moveFileBrowser(zzt.textBrowserCursor - 22); // Page Up
			else if (theCode == 34)
				zzt.moveFileBrowser(zzt.textBrowserCursor + 22); // Page Down
			else if (theCode == 36)
				zzt.moveFileBrowser(0); // Home
			else if (theCode == 35)
				zzt.moveFileBrowser(zzt.textBrowserLines.length - 22); // End
			break;

		case zzt.MODE_COLORSEL:
			editor.drawKolorCursor(false);
			switch (theCode) {
				case 37: // Left
					editor.fgColorCursor = (editor.fgColorCursor - 1) & 15;
					if (editor.fgColorCursor == 15)
						editor.blinkFlag = !editor.blinkFlag;
					editor.drawKolorCursor(true);
				break;
				case 39: // Right
					editor.fgColorCursor = (editor.fgColorCursor + 1) & 15;
					if (editor.fgColorCursor == 0)
						editor.blinkFlag = !editor.blinkFlag;
					editor.drawKolorCursor(true);
				break;
				case 38: // Up
					editor.bgColorCursor = (editor.bgColorCursor - 1) & 7;
					editor.drawKolorCursor(true);
				break;
				case 40: // Down
					editor.bgColorCursor = (editor.bgColorCursor + 1) & 7;
					editor.drawKolorCursor(true);
				break;
				default:
					zzt.dispatchInputMessage(guiKeyMappingArray[theCode]);
				break;
			}
		break;
		case zzt.MODE_CHARSEL:
			editor.drawCharCursor(false);
			switch (theCode) {
				case 37: // Left
					editor.hexCodeValue = (editor.hexCodeValue - 1) & 255;
					editor.drawCharCursor(true);
				break;
				case 39: // Right
					editor.hexCodeValue = (editor.hexCodeValue + 1) & 255;
					editor.drawCharCursor(true);
				break;
				case 38: // Up
					editor.hexCodeValue = (editor.hexCodeValue - 32) & 255;
					editor.drawCharCursor(true);
				break;
				case 40: // Down
					editor.hexCodeValue = (editor.hexCodeValue + 32) & 255;
					editor.drawCharCursor(true);
				break;
				default:
					zzt.dispatchInputMessage(guiKeyMappingArray[theCode]);
				break;
			}
		break;

		case zzt.MODE_ENTERGUIPROP:
			if (theCode == 27)
				zzt.dispatchInputMessage("EVENT_ACCEPTPROP");
			break;
		case zzt.MODE_ENTEROPTIONSPROP:
			if (theCode == 27)
				zzt.dispatchInputMessage("EVENT_ACCEPTPROP");
			break;
		case zzt.MODE_ENTERCONSOLEPROP:
			if (theCode == 27)
				zzt.dispatchInputMessage("EVENT_ACCEPTPROP");
			break;
		case zzt.MODE_ENTEREDITORPROP:
			if (theCode == 27)
				zzt.dispatchInputMessage("ED_ACCEPTEDITORPROP");
			break;
	}
}

// Key-up handler
public static function keyReleased(event:KeyboardEvent):void 
{
	var theCode:uint = event.keyCode;
	var charCode:uint = event.charCode;
	keyCodeDowns[theCode & 255] = 0;
	keyCharDowns[charCode & 255] = 0;
}

// Mouse-down handler
public static function mousePressed(event:MouseEvent):void
{
	// Mouse tracking info
	mouseXGridPos = int(event.stageX / zzt.cellXDiv);
	mouseYGridPos = int(event.stageY / zzt.cellYDiv);
	mDown = true;
	mDownCount = zzt.mcount;

	// Register click location relative to GUI.
	var guiX:int = mouseXGridPos - zzt.GuiLocX + 2;
	var guiY:int = mouseYGridPos - zzt.GuiLocY + 2;
	var rightSide:int = (event.stageX % zzt.cellXDiv >= zzt.cellXDiv / 2) ? 1 : 0;
	var downSide:int = (event.stageY % zzt.cellYDiv >= zzt.cellYDiv / 2) ? 1 : 0;

	if (zzt.mainMode == zzt.MODE_SCROLLINTERACT)
	{
		zzt.scrollInterfaceButton();
	}
	else if (zzt.mainMode == zzt.MODE_SELECTPEN)
	{
		zzt.drawPen(zzt.confLabelStr, zzt.penStartVal, zzt.penEndVal, zzt.penActVal,
			zzt.penChrCode, -1);
		zzt.mainMode = zzt.MODE_NORM;
		zzt.globals["$PENRESULT"] = zzt.penActVal;
		zzt.dispatchInputMessage(zzt.confYesMsg);
	}
	else if (zzt.mainMode == zzt.MODE_CONFMESSAGE)
	{
		if (guiY == zzt.confButtonY && guiX >= zzt.confButtonX && guiX < zzt.confButtonX + 10)
		{
			zzt.confButtonSel = (guiX - zzt.confButtonX < 5) ? 0 : 1;

			// Choose selected confirmation button
			zzt.unDrawConfButtons();
			zzt.eraseGuiLabel(zzt.confLabelStr);
			zzt.mainMode = zzt.MODE_NORM;
			zzt.dispatchInputMessage((zzt.confButtonSel == 0) ? zzt.confYesMsg : zzt.confNoMsg);
		}
	}
	else if (zzt.mainMode == zzt.MODE_NORM)
	{
		// GUI event handling.
		for (var s:String in zzt.GuiMouseEvents) {
			var o:Object = zzt.GuiMouseEvents[s];
			if (guiX >= o[0] && guiY >= o[1] && guiX < o[0] + o[2] && guiY < o[1] + o[3])
			{
				zzt.dispatchInputMessage(s);
				return;
			}
		}

		if (zzt.inEditor)
		{
			// If within the editor, special GUIs will cause mouse-down events.
			var shiftStatus:Boolean = event.shiftKey;
			switch (zzt.thisGuiName) {
				case "ED_TYPEALL":
					guiY -= 3;
					if (guiX < 42 && guiY >= 0 && guiY < 21)
						editor.dispatchEditorMenu("ED_TYPEALLSEL");
				break;
				case "ED_ULTRA1":
				case "ED_ULTRA2":
				case "ED_ULTRA3":
				case "ED_ULTRA4":
				case "ED_CLASSIC":
				case "ED_SUPERZZT":
				case "ED_KEVEDIT":
					guiX += zzt.GuiLocX - 1;
					guiY += zzt.GuiLocY - 1;
					if (guiX >= SE.vpX0 && guiY >= SE.vpY0 && guiX <= SE.vpX1 && guiY <= SE.vpY1)
					{
						// If cursor within viewport, place type at hotspot.
						if (shiftStatus)
						{
							editor.dispatchEditorMenu("ED_SELLEFT");
							editor.dispatchEditorMenu("ED_SELRIGHT");
						}
						else
						{
							editor.dispatchEditorMenu("ED_PLACE");
							editor.drawFlag = editor.DRAW_ON;
						}
					}
					else if (guiX >= 61 && guiY >= 21)
					{
						// If cursor in color/pattern selection area, select position.
						guiX -= zzt.GuiLocX - 1;
						guiY -= zzt.GuiLocY - 1;
						editor.colorPatternMousePick(guiX, guiY, rightSide, downSide);
					}
				break;
				case "ED_CHAREDIT":
					guiX += zzt.GuiLocX - 1;
					guiY += zzt.GuiLocY - 1;
					if (guiX >= 4 && guiY >= 3 && guiX < 4 + 16 && guiY < 3 + 16)
					{
						editor.ceCharX = (guiX - 4) >> 1;
						editor.ceCharY = guiY - 3;
						editor.dispatchEditorMenu("CE_STARTMOUSEDRAW");
					}
					else if (guiX >= 16 && guiY >= 22 && guiX < 16 + 3 && guiY < 22 + 3)
						editor.setCharEditPreview(guiX - 16, guiY - 22);
					else if (guiX >= 25 && guiY >= 17 && guiX < 25 + 32 && guiY < 17 + 8)
						editor.selectCharFromSet((guiY - 17) * 32 + guiX - 25);
				break;
			}
		}
		else if (editor.typingTextInGuiEditor)
		{
			editor.guiTextEditCursor = (mouseYGridPos * editor.editWidth) + mouseXGridPos;
			if (editor.guiTextEditCursor >= editor.editWidth * editor.editHeight)
				editor.guiTextEditCursor = 0;

			editor.writeGuiTextEdit();
		}
		else if (zzt.globalProps["MOUSEBEHAVIOR"] != 0)
		{
			// If click location within viewport, trigger click-to-move
			// if mouse behavior would allow that kind of movement.
			guiX += zzt.GuiLocX - 1;
			guiY += zzt.GuiLocY - 1;
			if (guiX >= SE.vpX0 && guiY >= SE.vpY0 &&
				guiX <= SE.vpX1 && guiY <= SE.vpY1)
			{
				guiX -= SE.vpX0 - SE.CameraX;
				guiY -= SE.vpY0 - SE.CameraY;
				clickToMoveSquare(guiX, guiY, rightSide, downSide);
			}
		}
		else
		{
			// Dispatch to custom mouse routine.
			interp.briefDispatch(interp.onMousePos, interp.blankSE, interp.blankSE);
		}
	}
	else if (zzt.mainMode == zzt.MODE_COLORSEL)
		editor.dispatchEditorMenu("ED_COLORSEL");
	else if (zzt.mainMode == zzt.MODE_CHARSEL)
		editor.dispatchEditorMenu("ED_CHARSEL");
}

// Mouse-up handler
public static function mouseReleased(event:MouseEvent):void
{
	// Mouse tracking info
	mouseXGridPos = int(event.stageX / zzt.cellXDiv);
	mouseYGridPos = int(event.stageY / zzt.cellYDiv);
	mDown = false;

	if (zzt.inEditor)
	{
		var guiX:int = mouseXGridPos - zzt.GuiLocX + 2;
		var guiY:int = mouseYGridPos - zzt.GuiLocY + 2;

		// If within the editor, special GUIs will cause mouse-down events.
		switch (zzt.thisGuiName) {
			case "ED_ULTRA1":
			case "ED_ULTRA2":
			case "ED_ULTRA3":
			case "ED_ULTRA4":
			case "ED_CLASSIC":
			case "ED_SUPERZZT":
			case "ED_KEVEDIT":
				// If cursor within viewport, turn drawing off.
				guiX += zzt.GuiLocX - 1;
				guiY += zzt.GuiLocY - 1;
				if (guiX >= SE.vpX0 && guiY >= SE.vpY0 && guiX <= SE.vpX1 && guiY <= SE.vpY1)
					editor.drawFlag = editor.DRAW_OFF;
			break;
		}
	}
	else if (zzt.globalProps["MOUSEBEHAVIOR"] == 0)
	{
		// Dispatch to custom mouse routine.
		interp.briefDispatch(interp.onMousePos, interp.blankSE, interp.blankSE);
	}
}

// Mouse-drag handler
public static function mouseDrag(event:MouseEvent):void
{
	// Mouse tracking info
	mouseXGridPos = int(event.stageX / zzt.cellXDiv);
	mouseYGridPos = int(event.stageY / zzt.cellYDiv);

	// Highlight GUI as needed.
	var guiX:int = mouseXGridPos - zzt.GuiLocX + 2;
	var guiY:int = mouseYGridPos - zzt.GuiLocY + 2;
	var rightSide:int = (event.stageX % zzt.cellXDiv >= zzt.cellXDiv / 2) ? 1 : 0;
	var downSide:int = (event.stageY % zzt.cellYDiv >= zzt.cellYDiv / 2) ? 1 : 0;
	var shiftStatus:Boolean = event.shiftKey;

	if (zzt.mainMode == zzt.MODE_CONFMESSAGE)
	{
		if (guiY == zzt.confButtonY && guiX >= zzt.confButtonX && guiX < zzt.confButtonX + 10)
		{
			zzt.confButtonSel = (guiX - zzt.confButtonX < 5) ? 0 : 1;
			zzt.drawConfButtons();
		}
	}
	else if (zzt.mainMode == zzt.MODE_SCROLLINTERACT)
	{
		guiX = int((event.stageX - zzt.scrollGrid.x) / zzt.cellXDiv);
		guiY = int((event.stageY - zzt.scrollGrid.y) / zzt.scrollGrid.charHeight);
		var backupLen:int = int(zzt.msgScrollHeight/2);
		var oldScroll:int = zzt.mouseScrollOffset;
		zzt.mouseScrollOffset = 0;

		if (guiX >= 0 && guiY >= 0 &&
			guiX < zzt.msgScrollWidth && guiY < zzt.msgScrollHeight)
		{
			// Within boundaries of scroll.  Evaluate cursor offset.
			zzt.mouseScrollOffset = guiY - backupLen;

			var curIndex:int = zzt.msgScrollIndex + zzt.mouseScrollOffset;
			if (curIndex <= -1)
				zzt.mouseScrollOffset = 0;
			else if (curIndex >= zzt.msgScrollText.length)
				zzt.mouseScrollOffset = 0;
		}

		// Update arrows only if different.
		if (oldScroll != zzt.mouseScrollOffset)
			zzt.drawScrollMsgText();
	}
	else if (zzt.mainMode == zzt.MODE_NORM)
	{
		var newS:String = "";
		for (var s:String in zzt.GuiMouseEvents) {
			var o:Object = zzt.GuiMouseEvents[s];
			if (guiX >= o[0] && guiY >= o[1] && guiX < o[0] + o[2] && guiY < o[1] + o[3])
			{
				newS = s;
				break;
			}
		}

		if (newS != zzt.curHighlightButton)
		{
			if (zzt.curHighlightButton != "")
			{
				o = zzt.GuiMouseEvents[zzt.curHighlightButton];
				zzt.mg.writeXorAttr(zzt.GuiLocX + o[0] - 2, zzt.GuiLocY + o[1] - 2, o[2], o[3], 127);
			}
	
			zzt.curHighlightButton = newS;
			if (zzt.curHighlightButton != "")
			{
				o = zzt.GuiMouseEvents[zzt.curHighlightButton];
				zzt.mg.writeXorAttr(zzt.GuiLocX + o[0] - 2, zzt.GuiLocY + o[1] - 2, o[2], o[3], 127);
			}
		}

		if (zzt.inEditor)
		{
			// If within the editor, special GUIs will cause mouse-over events
			// to move the cursor.
			switch (zzt.thisGuiName) {
				case "ED_TYPEALL":
					guiY -= 3;
					if (guiX < 42 && guiY >= 0 && guiY < 21)
					{
						editor.highlightTypeAllCursor();
						editor.typeAllCursor = editor.typeAllPage + guiY;
						if (guiX >= 21)
							editor.typeAllCursor += editor.TYPEALL_ROWLIMIT;
						if (editor.typeAllCursor >= editor.typeAllTypes.length)
							editor.typeAllCursor = editor.typeAllTypes.length - 1;

						editor.updateTypeAllView(false);
					}
				break;
				case "ED_ULTRA1":
				case "ED_ULTRA2":
				case "ED_ULTRA3":
				case "ED_ULTRA4":
				case "ED_CLASSIC":
				case "ED_SUPERZZT":
				case "ED_KEVEDIT":
					// If cursor within viewport, move cursor to hotspot.
					guiX += zzt.GuiLocX - 1;
					guiY += zzt.GuiLocY - 1;
					if (guiX >= SE.vpX0 && guiY >= SE.vpY0 && guiX <= SE.vpX1 && guiY <= SE.vpY1)
					{
						guiX -= SE.vpX0 - SE.CameraX;
						guiY -= SE.vpY0 - SE.CameraY;
						editor.warpEditorCursor(guiX, guiY, shiftStatus);
					}
				break;
				case "ED_CHAREDIT":
					guiX += zzt.GuiLocX - 1;
					guiY += zzt.GuiLocY - 1;
					if (guiX >= 4 && guiY >= 3 && guiX < 4 + 16 && guiY < 3 + 16 && mDown)
					{
						editor.ceCharX = (guiX - 4) >> 1;
						editor.ceCharY = guiY - 3;
						editor.dispatchEditorMenu("CE_CONTINUEMOUSEDRAW");
					}
				break;
			}
		}
		else if (zzt.globalProps["MOUSEBEHAVIOR"] != 0 &&
			zzt.globalProps["MOUSEEDGEPOINTER"] != 0 &&
			zzt.globalProps["MOUSEEDGENAV"] != 0)
		{
			// If cursor within viewport, trigger edge-nav arrows if
			// mouse behavior would allow that kind of movement.
			guiX += zzt.GuiLocX - 1;
			guiY += zzt.GuiLocY - 1;
			if (guiX >= SE.vpX0 && guiY >= SE.vpY0 && guiX <= SE.vpX1 && guiY <= SE.vpY1)
			{
				guiX -= SE.vpX0 - SE.CameraX;
				guiY -= SE.vpY0 - SE.CameraY;

				// Restore tile under last edge-nav arrow.
				if (zzt.lastEdgeNavArrowX != -1)
					SE.displaySquare(zzt.lastEdgeNavArrowX, zzt.lastEdgeNavArrowY);
				zzt.lastEdgeNavArrowX = -1;
				zzt.lastEdgeNavArrowY = -1;
				var meNav:int = zzt.globalProps["MOUSEEDGENAV"];

				// Draw new edge-nav arrow if mouse cursor flush with board edge.
				if (guiX == 1 && (rightSide == 0 || meNav == 2) &&
					zzt.boardProps["EXITWEST"] != 0)
					zzt.showEdgeNavArrow(guiX, guiY, 2);
				else if (guiY == 1 && (downSide == 0 || meNav == 2) &&
					zzt.boardProps["EXITNORTH"] != 0)
					zzt.showEdgeNavArrow(guiX, guiY, 3);
				else if (guiX == zzt.boardProps["SIZEX"] && (rightSide == 1 || meNav == 2) &&
					zzt.boardProps["EXITEAST"] != 0)
					zzt.showEdgeNavArrow(guiX, guiY, 0);
				else if (guiY == zzt.boardProps["SIZEY"] && (downSide == 1 || meNav == 2) &&
					zzt.boardProps["EXITSOUTH"] != 0)
					zzt.showEdgeNavArrow(guiX, guiY, 1);
			}
		}
	}
	else if (zzt.mainMode == zzt.MODE_COLORSEL)
	{
		guiX -= 2;
		guiY -= 2;
		if (guiX >= 0 && guiY >= 0 && guiX < 32 && guiY < 8)
		{
			editor.drawKolorCursor(false);
			editor.fgColorCursor = guiX & 15;
			editor.bgColorCursor = guiY;
			editor.blinkFlag = Boolean(guiX >= 16);
			editor.drawKolorCursor(true);
		}
	}
	else if (zzt.mainMode == zzt.MODE_CHARSEL)
	{
		guiX -= 2;
		guiY -= 2;
		if (guiX >= 0 && guiY >= 0 && guiX < 32 && guiY < 8)
		{
			editor.drawCharCursor(false);
			editor.hexCodeValue = guiY * 32 + guiX;
			editor.drawCharCursor(true);
		}
	}
}

// Mouse wheel handler
public static function mouseWheel(event:MouseEvent):void
{
	var lineDelta:int = utils.isgn(-event.delta);
	if (zzt.mainMode == zzt.MODE_SCROLLINTERACT)
	{
		if (utils.isgn(progWheelCount) == lineDelta)
			progWheelCount += lineDelta;
		else
			progWheelCount = lineDelta;

		// Boost scroll rate for faster wheel rotation.
		if (zzt.mcount - lastWheelMCount < MOUSE_WHEEL_TIME_THRESHOLD &&
			utils.iabs(progWheelCount) >= MOUSE_WHEEL_COUNT_THRESHOLD)
			lineDelta *= MOUSE_WHEEL_MULTIPLIER;

		lastWheelMCount = zzt.mcount;
		zzt.msgScrollIndex += lineDelta;

		if (zzt.msgScrollIndex < 0)
			zzt.msgScrollIndex = 0;
		if (zzt.msgScrollIndex >= zzt.msgScrollText.length)
			zzt.msgScrollIndex = zzt.msgScrollText.length - 1;
		zzt.drawScrollMsgText();
	}
	else if (zzt.mainMode == zzt.MODE_FILEBROWSER)
	{
		zzt.moveFileBrowser(zzt.textBrowserCursor + lineDelta * 5);
	}
	else if (zzt.mainMode == zzt.MODE_SELECTPEN)
	{
		if (lineDelta < 0) // Left
		{
			if (zzt.penStartVal < zzt.penEndVal)
			{
				if (--zzt.penActVal < zzt.penStartVal)
					zzt.penActVal = zzt.penStartVal;
			}
			else
			{
				if (++zzt.penActVal > zzt.penStartVal)
					zzt.penActVal = zzt.penStartVal;
			}
			zzt.drawPen(zzt.confLabelStr, zzt.penStartVal, zzt.penEndVal, zzt.penActVal,
				zzt.penChrCode, zzt.penAttr);
		}
		else if (lineDelta > 0) // Right
		{
			if (zzt.penStartVal < zzt.penEndVal)
			{
				if (++zzt.penActVal > zzt.penEndVal)
					zzt.penActVal = zzt.penEndVal;
			}
			else
			{
				if (--zzt.penActVal < zzt.penEndVal)
					zzt.penActVal = zzt.penEndVal;
			}
			zzt.drawPen(zzt.confLabelStr, zzt.penStartVal, zzt.penEndVal, zzt.penActVal,
				zzt.penChrCode, zzt.penAttr);
		}
	}
}

// Mouse-based firing handler
public static function mouseFireHandler(minDelay:int):void {
	if (zzt.mcount - mDownCount >= minDelay)
	{
		switch (c2MDir) {
			case 0:
				keyDownHandler(39, 0, true, false); // Right
			break;
			case 1:
				keyDownHandler(40, 0, true, false); // Down
			break;
			case 2:
				keyDownHandler(37, 0, true, false); // Left
			break;
			case 3:
				keyDownHandler(38, 0, true, false); // Up
			break;
		}
	}
}

// Mouse click-to-move handler
public static function clickToMoveSquare(x:int, y:int, rightSide:int, downSide:int):void {
	// Reset timer and pick next direction.
	c2MDestX = x;
	c2MDestY = y;
	c2MMode = C2M_MODE_TOWARDS;

	// If edge-nav is possible, bump destination further by one.
	var meNav:int = zzt.globalProps["MOUSEEDGENAV"];
	if (meNav != 0)
	{
		if (x == 1 && (rightSide == 0 || meNav == 2) &&
			zzt.boardProps["EXITWEST"] != 0)
			c2MDestX--;
		else if (y == 1 && (downSide == 0 || meNav == 2) &&
			zzt.boardProps["EXITNORTH"] != 0)
			c2MDestY--;
		else if (x == zzt.boardProps["SIZEX"] && (rightSide == 1 || meNav == 2) &&
			zzt.boardProps["EXITEAST"] != 0)
			c2MDestX++;
		else if (y == zzt.boardProps["SIZEY"] && (downSide == 1 || meNav == 2) &&
			zzt.boardProps["EXITSOUTH"] != 0)
			c2MDestY++;
	}

	if (pickC2MSquare())
	{
		if (keyCodeDowns[16] != 0) // Shift
		{
			// Firing handler
			mouseFireHandler(0);
			c2MDestX = -1;
			c2MDestY = -1;
			return;
		}
		else if (zzt.globals["$PLAYERMODE"] == 1 && zzt.globals["$PLAYERPAUSED"] == 1)
		{
			// Initial movement handler (when game paused)
			moveC2MSquare();
		}
	}
}

// Click-to-move pathfinding algorithm when moving straight towards destination
public static function pickC2MSquare():Boolean {
	// If player not present, can't evaluate.
	if (!interp.playerSE)
	{
		c2MDestX = -1;
		c2MDestY = -1;
		return false;
	}

	// Check if player is at current square.  If so, veto movement.
	var px:int = interp.playerSE.X;
	var py:int = interp.playerSE.Y;
	if (c2MDestX == px && c2MDestY == py)
	{
		c2MDestX = -1;
		c2MDestY = -1;
		return false;
	}

	// Set initial direction.
	var xDiff:int = c2MDestX - px;
	var yDiff:int = c2MDestY - py;
	c2MDir = interp.getDir4FromSteps(utils.isgn(xDiff), utils.isgn(yDiff));
	if (px != c2MDestX && py != c2MDestY)
	{
		// There is no straight vector to destination.  From ratios of
		// distances, pick ideal choice (vertical or horizontal).

		// Y difference counts for twice as much as X difference in 80-column mode.
		//yDiff *= aspectMultiplier;

		// For MOUSEBEHAVIOR of 1, the vector chosen will pick the minor nav first.
		// For MOUSEBEHAVIOR of 2, the vector chosen will pick the major nav first.
		var xDom:Boolean = Boolean(utils.iabs(xDiff) >= utils.iabs(yDiff));
		if (zzt.globalProps["MOUSEBEHAVIOR"] == 1)
			xDom = !xDom;

		// Try preferred nav direction.  Preference is ignored if the preferred
		// nav direction is blocked.
		if (xDom)
		{
			c2MDir = interp.getDir4FromSteps(utils.isgn(xDiff), 0);
			if (!canMoveTowards(px, py, c2MDir))
				c2MDir = interp.getDir4FromSteps(0, utils.isgn(yDiff));
		}
		else
		{
			c2MDir = interp.getDir4FromSteps(0, utils.isgn(yDiff));
			if (!canMoveTowards(px, py, c2MDir))
				c2MDir = interp.getDir4FromSteps(utils.isgn(xDiff), 0);
		}
	}

	// Direction chosen.
	return true;
}

// Click-to-move pathfinding algorithm when circling around obstacles
public static function chooseNextC2MDir():void {
	// Decide strategy for selecting next movement location.
	var x:int = interp.playerSE.X;
	var y:int = interp.playerSE.Y;

	if (c2MMode == C2M_MODE_EXTEND)
	{
		if ((lastPlayerX == x && lastPlayerY == y) ||
			(x == c2MExtendDestX && y == c2MExtendDestY))
		{
			// If we arrive at destination, or we didn't move, reorient towards the player.
			c2MMode = C2M_MODE_TOWARDS;
			pickC2MSquare();
		}
		else
		{
			// Go towards extended location.
			c2MCount = zzt.mcount;
			c2MDir = c2MExtendDir;
		}
	}
	else if (c2MMode == C2M_MODE_TOWARDS)
	{
		// Change in player position indicates that move towards destination is working.
		if (lastPlayerX != x || lastPlayerY != y)
		{
			if (zzt.globalProps["MOUSEBEHAVIOR"] == 3)
			{
				// This behavior will constantly re-evaluate the distance to
				// the destination and pick an "as the crow flies" vector.
				// This is very similar to the TOWARDS direction.
				if (utils.iabs(c2MDestX - x) >= utils.iabs(c2MDestY - y))
					c2MDir = interp.getDir4FromSteps(utils.isgn(c2MDestX - x), 0);
				else
					c2MDir = interp.getDir4FromSteps(0, utils.isgn(c2MDestY - y));
			}

			// If not using MOUSEBEHAVIOR==3, pick the same movement direction
			// as before if that direction would get us closer to the target.
			c2MCount = zzt.mcount;
			var nextX:int = x + interp.getStepXFromDir4(c2MDir);
			var nextY:int = y + interp.getStepYFromDir4(c2MDir);

			if (utils.iabs(nextX - c2MDestX) + utils.iabs(nextY - c2MDestY) >=
				utils.iabs(x - c2MDestX) + utils.iabs(y - c2MDestY))
			{
				// Same movement direction wouldn't get us closer.
				// Reorient towards the player.
				pickC2MSquare();
			}
		}
		else
		{
			// We didn't or couldn't move towards destination.
			// Plan paths around obstacles to see if circling would
			// get us closer.
			getIdealCircularPath();
		}
	}
	else if (zzt.mcount - c2MCount >= C2M_GIVEUP_THRESHOLD)
	{
		// Too many iterations have passed without getting
		// close to destination.  Give up.
		c2MDestX = -1;
		c2MDestY = -1;
	}
	else if (c2MMode == C2M_MODE_CW)
	{
		// Clockwise circling attempts to get closer by turning in a
		// positive direction when blocked.
		c2MDir = (c2MDir - 1) & 3;
		if (!canMoveTowards(x, y, c2MDir))
		{
			c2MDir = (c2MDir + 1) & 3;
			if (!canMoveTowards(x, y, c2MDir))
			{
				c2MDir = (c2MDir + 1) & 3;
				if (!canMoveTowards(x, y, c2MDir))
				{
					c2MDir = (c2MDir + 1) & 3;
					if (!canMoveTowards(x, y, c2MDir))
					{
						c2MDir = (c2MDir + 1) & 3;
						if (!canMoveTowards(x, y, c2MDir))
						{
							// Trapped!  Give up.
							c2MDestX = -1;
							c2MDestY = -1;
						}
					}
				}
			}
		}

		// Switch mode if we had arrived at "closest" destination.
		if (x == c2MCircleDestX && y == c2MCircleDestY)
		{
			c2MCount = zzt.mcount;
			c2MMode = C2M_MODE_EXTEND;
		}
	}
	else
	{
		// Counter-clockwise circling attempts to get closer by
		// turning in a negative direction when blocked.
		c2MDir = (c2MDir + 1) & 3;
		if (!canMoveTowards(x, y, c2MDir))
		{
			c2MDir = (c2MDir - 1) & 3;
			if (!canMoveTowards(x, y, c2MDir))
			{
				c2MDir = (c2MDir - 1) & 3;
				if (!canMoveTowards(x, y, c2MDir))
				{
					c2MDir = (c2MDir - 1) & 3;
					if (!canMoveTowards(x, y, c2MDir))
					{
						c2MDir = (c2MDir - 1) & 3;
						if (!canMoveTowards(x, y, c2MDir))
						{
							// Trapped!  Give up.
							c2MDestX = -1;
							c2MDestY = -1;
						}
					}
				}
			}
		}

		// Switch mode if we had arrived at "closest" destination.
		if (x == c2MCircleDestX && y == c2MCircleDestY)
		{
			c2MCount = zzt.mcount;
			c2MMode = C2M_MODE_EXTEND;
		}
	}
}

// BLOCKPLAYER type evaluation for square
public static function canMoveTowards(x:int, y:int, toDir:int):Boolean {
	// Test if destination square is nonblocking.
	x += interp.getStepXFromDir4(toDir);
	y += interp.getStepYFromDir4(toDir);
	return Boolean(!zzt.typeList[SE.getType(x, y)].BlockPlayer ||
		(x == interp.playerSE.X && y == interp.playerSE.Y));
}

// Test how many moves we could take in a straight direction for click-to-move
public static function testExtendedMoveTowards(x:int, y:int, toDir:int):int {
	var moveCount:int = 0;
	var distLowest:int = utils.iabs(x - c2MDestX) + utils.iabs(y - c2MDestY);
	c2MExtendDestX = x;
	c2MExtendDestY = y;
	c2MMoveCountLowest = 0;

	while (moveCount < 200) {
		if (!canMoveTowards(x, y, toDir))
			break; // Done moving.

		// Advance to next square.
		x += interp.getStepXFromDir4(toDir);
		y += interp.getStepYFromDir4(toDir);
		moveCount++;

		// Calculate distance from target.
		var distCurrent:int = utils.iabs(x - c2MDestX) + utils.iabs(y - c2MDestY);
		if (distCurrent < distLowest)
		{
			// This beats previous distance.  Choose this distance and count.
			c2MExtendDestX = x;
			c2MExtendDestY = y;
			c2MMoveCountLowest = moveCount;
			distLowest = distCurrent;
		}
	}

	// Report how far away from target we would get.
	return distLowest;
}

// Test extended movement in all directions; report most optimal distance away
public static function testExtendedMoveAll(x:int, y:int):int {
	var distCurrent:int = testExtendedMoveTowards(x, y, 0);
	var distLowest:int = distCurrent;
	var moveCountLowest:int = c2MMoveCountLowest;
	c2MExtendDir = 0;

	distCurrent = testExtendedMoveTowards(x, y, 1);
	if (distLowest > distCurrent)
	{
		distLowest = distCurrent;
		moveCountLowest = c2MMoveCountLowest;
		c2MExtendDir = 1;
	}
	distCurrent = testExtendedMoveTowards(x, y, 2);
	if (distLowest > distCurrent)
	{
		distLowest = distCurrent;
		moveCountLowest = c2MMoveCountLowest;
		c2MExtendDir = 2;
	}
	distCurrent = testExtendedMoveTowards(x, y, 3);
	if (distLowest > distCurrent)
	{
		distLowest = distCurrent;
		moveCountLowest = c2MMoveCountLowest;
		c2MExtendDir = 3;
	}

	// Return objective lowest distance count, and remember lowest move count.
	c2MMoveCountLowest = moveCountLowest;
	return distLowest;
}

// Trace a circling path around the immediate obstacle to see which
// direction, clockwise or counter-clockwise, would be more optimal
public static function getIdealCircularPath():void {
	var x:int = interp.playerSE.X;
	var y:int = interp.playerSE.Y;
	var baseDir:int = c2MDir;
	c2MBeatDist = utils.iabs(x - c2MDestX) + utils.iabs(y - c2MDestY);

	// First, clockwise.
	c2MDir = (baseDir + 1) & 3;
	var cwMinDist:int = 100000000;
	var cwIdealX:int = -1;
	var cwIdealY:int = -1;
	var cwMoves:int = 0;
	var cwMinMoves:int = 100000000;
	while (cwMoves++ < 60) {
		c2MDir = (c2MDir - 1) & 3;
		if (!canMoveTowards(x, y, c2MDir))
		{
			c2MDir = (c2MDir + 1) & 3;
			if (!canMoveTowards(x, y, c2MDir))
			{
				c2MDir = (c2MDir + 1) & 3;
				if (!canMoveTowards(x, y, c2MDir))
				{
					c2MDir = (c2MDir + 1) & 3;
					if (!canMoveTowards(x, y, c2MDir))
					{
						c2MDir = (c2MDir + 1) & 3;
						if (!canMoveTowards(x, y, c2MDir))
						{
							// Trapped!
							break;
						}
					}
				}
			}
		}

		// Advance to next square.
		x += interp.getStepXFromDir4(c2MDir);
		y += interp.getStepYFromDir4(c2MDir);

		// Record distance.
		var thisDist:int = testExtendedMoveAll(x, y);
		if (cwMinDist > thisDist)
		{
			// This square would improve proximity.
			cwMinMoves = cwMoves + c2MMoveCountLowest;
			cwMinDist = thisDist;
			cwIdealX = x;
			cwIdealY = y;
		}
		else if (cwMinDist == thisDist)
		{
			// This square would not improve proximity, but we might prefer to
			// pick it anyway as an extension point if it would result in fewer
			// moves than our last favorite.
			if (cwMinMoves > cwMoves + c2MMoveCountLowest)
			{
				cwMinMoves = cwMoves + c2MMoveCountLowest;
				cwMinDist = thisDist;
				cwIdealX = x;
				cwIdealY = y;
			}
		}
	}

	// Next, counter-clockwise.
	x = interp.playerSE.X;
	y = interp.playerSE.Y;
	c2MDir = (baseDir - 1) & 3;
	var ccwMinDist:int = 100000000;
	var ccwIdealX:int = -1;
	var ccwIdealY:int = -1;
	var ccwMoves:int = 0;
	var ccwMinMoves:int = 100000000;
	while (ccwMoves++ < 60) {
		c2MDir = (c2MDir + 1) & 3;
		if (!canMoveTowards(x, y, c2MDir))
		{
			c2MDir = (c2MDir - 1) & 3;
			if (!canMoveTowards(x, y, c2MDir))
			{
				c2MDir = (c2MDir - 1) & 3;
				if (!canMoveTowards(x, y, c2MDir))
				{
					c2MDir = (c2MDir - 1) & 3;
					if (!canMoveTowards(x, y, c2MDir))
					{
						c2MDir = (c2MDir - 1) & 3;
						if (!canMoveTowards(x, y, c2MDir))
						{
							// Trapped!
							break;
						}
					}
				}
			}
		}

		// Advance to next square.
		x += interp.getStepXFromDir4(c2MDir);
		y += interp.getStepYFromDir4(c2MDir);

		// Record distance.
		//thisDist = utils.iabs(x - c2MDestX) + utils.iabs(y - c2MDestY);
		thisDist = testExtendedMoveAll(x, y);
		if (ccwMinDist > thisDist)
		{
			// This square would improve proximity.
			ccwMinMoves = ccwMoves + c2MMoveCountLowest;
			ccwMinDist = thisDist;
			ccwIdealX = x;
			ccwIdealY = y;
		}
		else if (ccwMinDist == thisDist)
		{
			// This square would not improve proximity, but we might prefer to
			// pick it anyway as an extension point if it would result in fewer
			// moves than our last favorite.
			if (ccwMinMoves > ccwMoves + c2MMoveCountLowest)
			{
				ccwMinMoves = ccwMoves + c2MMoveCountLowest;
				ccwMinDist = thisDist;
				ccwIdealX = x;
				ccwIdealY = y;
			}
		}
	}

	// Pick circling mode based on proximity performance.
	if (cwMinDist == ccwMinDist && cwMinDist < c2MBeatDist && ccwMinDist < c2MBeatDist)
	{
		// Both clockwise and counter-clockwise would reach equally well.
		// Judge using different criteria:  least number of moves.
		if (cwMinMoves <= ccwMinMoves)
		{
			// Clockwise performance is better.
			c2MMode = C2M_MODE_CW;
			c2MDir = (baseDir + 1) & 3;
			c2MCircleDestX = cwIdealX;
			c2MCircleDestY = cwIdealY;
			testExtendedMoveAll(c2MCircleDestX, c2MCircleDestY);
			testExtendedMoveTowards(c2MCircleDestX, c2MCircleDestY, c2MExtendDir);
		}
		else
		{
			// Counter-clockwise performance is better.
			c2MMode = C2M_MODE_CCW;
			c2MDir = (baseDir - 1) & 3;
			c2MCircleDestX = ccwIdealX;
			c2MCircleDestY = ccwIdealY;
			testExtendedMoveAll(c2MCircleDestX, c2MCircleDestY);
			testExtendedMoveTowards(c2MCircleDestX, c2MCircleDestY, c2MExtendDir);
		}
	}
	else if (cwMinDist < ccwMinDist && cwMinDist < c2MBeatDist)
	{
		// Clockwise performance is better.
		c2MMode = C2M_MODE_CW;
		c2MDir = (baseDir + 1) & 3;
		c2MCircleDestX = cwIdealX;
		c2MCircleDestY = cwIdealY;
		testExtendedMoveAll(c2MCircleDestX, c2MCircleDestY);
		testExtendedMoveTowards(c2MCircleDestX, c2MCircleDestY, c2MExtendDir);
	}
	else if (ccwMinDist < cwMinDist && ccwMinDist < c2MBeatDist)
	{
		// Counter-clockwise performance is better.
		c2MMode = C2M_MODE_CCW;
		c2MDir = (baseDir - 1) & 3;
		c2MCircleDestX = ccwIdealX;
		c2MCircleDestY = ccwIdealY;
		testExtendedMoveAll(c2MCircleDestX, c2MCircleDestY);
		testExtendedMoveTowards(c2MCircleDestX, c2MCircleDestY, c2MExtendDir);
	}
	else
	{
		// If neither circling modes would get us closer, give up.
		c2MDestX = -1;
		c2MDestY = -1;
	}
}

// Move the player based on click-to-move decision
public static function moveC2MSquare():void {
	// If within touching distance of destination, this is the last time
	// we will try to move towards destination.
	if (utils.iabs(interp.playerSE.X - c2MDestX) +
		utils.iabs(interp.playerSE.Y - c2MDestY) <= 1)
	{
		c2MDestX = -1;
		c2MDestY = -1;
	}

	// Feed player input from direction
	switch (c2MDir) {
		case 0:
			keyDownHandler(39, 0, false, false); // Right
		break;
		case 1:
			keyDownHandler(40, 0, false, false); // Down
		break;
		case 2:
			keyDownHandler(37, 0, false, false); // Left
		break;
		case 3:
			keyDownHandler(38, 0, false, false); // Up
		break;
	}
}


};
};

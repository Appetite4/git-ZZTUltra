//ASCII_Characters.as:  The source for the ASCII character pixel
//data.  This is a 32x8 grid of 8x16 ASCII characters, from 0
//to 255.  The class contains routines for breaking up the
//bitmap data into individual portions.

package {

import flash.utils.ByteArray;
import flash.display.BitmapData;
import flash.geom.*;
import Chars_Trans;

public class ASCII_Characters {
	//Constants
	public static const CHAR_WIDTH:int = 8;
	public static const CHAR_HEIGHT:int = 16;
	public static const CHAR_HEIGHT16:int = 16;
	public static const CHAR_HEIGHT14:int = 14;
	public static const CHAR_HEIGHT8:int = 8;

	//Variables
	public static var srcdatachar:Chars_Trans;
	public static var srcdatachar14:Chars_Trans_14;
	public static var srcdatachar8:Chars_Trans_8;
	public static var bmBank16:Vector.<BitmapData>;
	public static var bmBank14:Vector.<BitmapData>;
	public static var bmBank8:Vector.<BitmapData>;
	public static var bg:BitmapData;

	public static function Separate_ASCII_Characters() {
		//var oneRect:Rectangle = new Rectangle(0, 0, CHAR_WIDTH, CHAR_HEIGHT);
		var myrect:Rectangle = new Rectangle();
		var mypoint:Point = new Point(0, 0);
		srcdatachar = new Chars_Trans(512, 128);
		srcdatachar14 = new Chars_Trans_14(512, 112);
		srcdatachar8 = new Chars_Trans_8(512, 64);

		bmBank16 = new Vector.<BitmapData>(256, true);
		bmBank14 = new Vector.<BitmapData>(256, true);
		bmBank8 = new Vector.<BitmapData>(256, true);
		for (var n:int = 0; n < 256; n++)
		{
			// Create source bounds for 16-scanline height.
			myrect.x = int(n % 32) * CHAR_WIDTH;
			myrect.y = int(n / 32) * CHAR_HEIGHT;
			myrect.width = CHAR_WIDTH;
			myrect.height = CHAR_HEIGHT;

			// Create bitmap for 16-scanline height.
			var bmd:BitmapData = new BitmapData(CHAR_WIDTH, CHAR_HEIGHT, false, 0x00000000);
			bmd.copyPixels(srcdatachar, myrect, mypoint, null, null, false);
			bmBank16[n] = bmd;

			// 14-scanline height.
			myrect.x = int(n % 32) * CHAR_WIDTH;
			myrect.y = int(n / 32) * CHAR_HEIGHT14;
			myrect.width = CHAR_WIDTH;
			myrect.height = CHAR_HEIGHT14;

			// Create bitmap for 14-scanline height.
			bmd = new BitmapData(CHAR_WIDTH, CHAR_HEIGHT14, false, 0x00000000);
			bmd.copyPixels(srcdatachar14, myrect, mypoint, null, null, false);
			bmBank14[n] = bmd;

			// 8-scanline height.
			myrect.x = int(n % 32) * CHAR_WIDTH;
			myrect.y = int(n / 32) * CHAR_HEIGHT8;
			myrect.width = CHAR_WIDTH;
			myrect.height = CHAR_HEIGHT8;

			// Create bitmap for 8-scanline height.
			bmd = new BitmapData(CHAR_WIDTH, CHAR_HEIGHT8, false, 0x00000000);
			bmd.copyPixels(srcdatachar8, myrect, mypoint, null, null, false);
			bmBank8[n] = bmd;
		}

		// Character 219 is a solid color block.
		bg = bmBank16[219];

		/*charbitmapbank = new Vector.<BitmapData>(16 * 256, true);
		for (var c:int = 0; c < 16; c++)
		{
			// Set color transform.
			var ct:ColorTransform = new ColorTransform();
			ct.color = CellGrid.colorLookup[c];
			for (var n:int = 0; n < 256; n++)
			{
				//Create source bounds.
				myrect.x = int(n % 32) * CHAR_WIDTH;
				myrect.y = int(n / 32) * CHAR_HEIGHT;
				myrect.width = CHAR_WIDTH;
				myrect.height = CHAR_HEIGHT;
	
				//Create bitmaps for characters.
				var bmd:BitmapData = new BitmapData(CHAR_WIDTH, CHAR_HEIGHT, true, 0x00000000);
				bmd.copyPixels(srcdatachar, myrect, mypoint, null, null, false);
				bmd.colorTransform(oneRect, ct);
				charbitmapbank[c * 256 + n] = bmd;
			}
		}

		// Character 219 is a solid color block.
		bg = charbitmapbank[(15 * 256) + 219];*/
	}

	// Retrieve a bitmap data section for any single character
	// with this function.
	/*public static function GetBitmapDataForChar(charPos:int):BitmapData {
		return (charBitmapBank[charPos]);
	}*/
	/*public static function GetBitmapDataForCharOld(charpos:int, colorpos:int):BitmapData {
		return (charbitmapbank[(colorpos << 8) + charpos]);
	}*/
};
};

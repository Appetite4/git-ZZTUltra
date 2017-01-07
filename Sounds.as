// Sound effects processing.

package {
public class Sounds {

import flash.utils.ByteArray;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.net.URLRequest;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SampleDataEvent;

// General constants
public static const NUM_CHANNELS:int = 16;
public static const EXTENDED_SILENCE_SIZE:int = 131072; // About 3 seconds worth
public static const SAMPLE_WRITE_SIZE:int = 4096; // 8192=max; 2048=min
public static const RELOAD_CHECK_FREQUENCY:int = 20;

public static const CC_STOP_PREVIOUS:int = 0;
public static const CC_WAIT_FOR_PREVIOUS:int = 1;
public static const CC_MULTIPLE:int = 2;

public static const CC_ONCE_ONLY:int = 1;
public static const CC_INFINITE_LOOP:int = 100000;

// Sound constants
public static const NONE:int = 0;
public static const B7_X8:int = 1;
public static const G7_X13:int = 2;
public static const C7_X2:int = 3;
public static const G6_X3:int = 4;
public static const C6_X1:int = 5;
public static const G5_X3:int = 6;
public static const C5_X1:int = 7;
public static const G4_X1:int = 8;
public static const C4_X1:int = 9;
public static const G3_X1:int = 10;
public static const C3_X1:int = 11;
public static const G2_X1:int = 12;
public static const E2_X1:int = 13;
public static const C2_X1:int = 14;
public static const PERC_0:int = 15;
public static const PERC_1:int = 16;
public static const PERC_2:int = 17;
public static const PERC_3:int = 0;
public static const PERC_4:int = 19;
public static const PERC_5:int = 20;
public static const PERC_6:int = 21;
public static const PERC_7:int = 22;
public static const PERC_8:int = 23;
public static const PERC_9:int = 24;

// Music constants
public static const BGM_SILENCE:int = 0;

// Sound storage array.  Format is:
// 0:  initialized, 1:  index, 2:  equivalent frequency, 3:  stored cycles,
// 4:  mono sample Number vector, 5:  number of samples in ByteArray.
public static var sound_info:Array = [
	[ true,  NONE, 0.0, 1, null, null ],
	[ false, B7_X8, 3876.92307692308, 8, null, null ],
	[ false, G7_X13, 3132.7868852459, 13, null, null ],
	[ false, C7_X2, 2100.00, 2, null, null ],
	[ false, G6_X3, 1575.00, 3, null, null ],
	[ false, C6_X1, 1050.00, 2, null, null ],
	[ false, G5_X3, 782.84023668639, 3, null, null ],
	[ false, C5_X1, 525.00, 1, null, null ],
	[ false, G4_X1, 390.26548672566, 1, null, null ],
	[ false, C4_X1, 260.94674556213, 1, null, null ],
	[ false, G3_X1, 196.00, 1, null, null ],
	[ false, C3_X1, 130.860534124629, 1, null, null ],
	[ false, G2_X1, 98.00, 1, null, null ],
	[ false, E2_X1, 82.276119402985, 1, null, null ],
	[ false, C2_X1, 65.43026706231454, 1, null, null ],
	[ false, PERC_0, 0.0, 1, null, null ],
	[ false, PERC_1, 0.0, 1, null, null ],
	[ false, PERC_2, 0.0, 1, null, null ],
	[ true,  PERC_3, 0.0, 1, null, null ],
	[ false, PERC_4, 0.0, 1, null, null ],
	[ false, PERC_5, 0.0, 1, null, null ],
	[ false, PERC_6, 0.0, 1, null, null ],
	[ false, PERC_7, 0.0, 1, null, null ],
	[ false, PERC_8, 0.0, 1, null, null ],
	[ false, PERC_9, 0.0, 1, null, null ],
];

// Music storage array
public static var music_info:Array = [
	[ false, BGM_SILENCE, "cruz_silence.mp3", null, null ],
];

// Output sound channel arrays
public static var sounds:Array;
public static var channels:Array;

// Play queue and envelope management
public static var fxEnvelopes:Array;
public static var mixBuffer:Vector.<Number>;
public static var mixLimit:int;
public static var silenceRemaining:int = 0;

// Other vars
public static var reloadQueueCount:int = 0;
public static var lastSelVoice:int = 0;
public static var playPending:Boolean = false;
public static var soundFx:Object;
public static var globalProps:Object;
public static var playSyncCallback:Function = null;

public static function initAllSounds(builtInSoundFx=null, builtInGlobalProps=null):Boolean {
	// Establish effects containers and global properties, if provided
	if (builtInSoundFx == null)
		soundFx = new Object();
	else
		soundFx = builtInSoundFx;

	if (builtInGlobalProps == null)
	{
		globalProps = new Object();
		globalProps["PLAYRETENTION"] = 0;
		globalProps["PLAYSYNC"] = 0;
		globalProps["SOUNDOFF"] = 0;
	}
	else
		globalProps = builtInGlobalProps;

	// Set up sound sample data
	initSound(B7_X8, new b7_3951_07_x8());
	initSound(G7_X13, new g7_3132_79_x13());
	initSound(C7_X2, new c7_2093_00_x2());
	initSound(G6_X3, new g6_1575_00_x3());
	initSound(C6_X1, new c6_1046_50_x2());
	initSound(G5_X3, new g5_782_84_x3());
	initSound(C5_X1, new c5_523_25());
	initSound(G4_X1, new g4_390_27());
	initSound(C4_X1, new c4_261_63());
	initSound(G3_X1, new g3_196_00());
	initSound(C3_X1, new c3_130_81());
	initSound(G2_X1, new g2_98_00());
	initSound(E2_X1, new e2_82_41());
	initSound(C2_X1, new c2_65_41());
	initSound(PERC_0, new perc_0());
	initSound(PERC_1, new perc_1());
	initSound(PERC_2, new perc_2());
	initSound(PERC_4, new perc_4());
	initSound(PERC_5, new perc_5());
	initSound(PERC_6, new perc_6());
	initSound(PERC_7, new perc_7());
	initSound(PERC_8, new perc_8());
	initSound(PERC_9, new perc_9());

	// Set up output sound channels
	sounds = new Array(1);
	channels = new Array(1);
	fxEnvelopes = new Array(NUM_CHANNELS);
	FxEnvelope.allSoundInfo = sound_info;
	for (var i:int = 0; i < NUM_CHANNELS; i++)
	{
		//sounds[i] = new Sound();
		//sounds[i].addEventListener(SampleDataEvent.SAMPLE_DATA, processSound);
		//channels[i] = null;
		fxEnvelopes[i] = new FxEnvelope(i);
	}

	sounds[0] = new Sound();
	sounds[0].addEventListener(SampleDataEvent.SAMPLE_DATA, processSound);
	channels[0] = null;

	mixBuffer = new Vector.<Number>();
	for (i = 0; i < SAMPLE_WRITE_SIZE; i++)
	{
		mixBuffer.push(0.0);
	}

	return true;
}

public static function initSound(num:int, fxInst:Sound):Boolean {
	sound_info[num][0] = true;
	var sData:ByteArray = new ByteArray();
	var sDataLen:int = int(fxInst.extract(sData, 22050));
	sound_info[num][4] = new Vector.<Number>();
	sound_info[num][5] = int(sDataLen);
	for (var i:int = 0; i < sound_info[num][5]; i++)
	{
		sData.position = i * 8;
		sound_info[num][4].push(sData.readFloat());
	}

	return true;
}

public static function processSound(event:SampleDataEvent):void {
	var outBuf:ByteArray = new ByteArray();
	var sObj:Object = event.currentTarget as Sound;
	var c:int = sounds.indexOf(sObj);
	if (c != -1)
	{
		// Main mixing section
		mixLimit = 0;
		for (var i:int = 0; i < NUM_CHANNELS; i++)
		{
			mixLimit = fxEnvelopes[i].writeFromQueue(mixBuffer, mixLimit, SAMPLE_WRITE_SIZE);
			//trace(i, mixLimit);
		}

		// Extend a silence block later if anything mixed
		if (mixLimit != 0)
			silenceRemaining = EXTENDED_SILENCE_SIZE;

		// Economize the queue periodically to prevent infinitely large strings
		if (++reloadQueueCount >= RELOAD_CHECK_FREQUENCY)
		{
			reloadQueueCount = 0;
			for (i = 0; i < NUM_CHANNELS; i++)
				fxEnvelopes[i].economizeQueue();
		}

		// Check for repeat; dispatch updated queue.
		var repeatCursorLoc:int = 0;
		for (i = 0; i < NUM_CHANNELS; i++) {
			if (fxEnvelopes[i].repeatActive)
			{
				repeatCursorLoc = fxEnvelopes[i].repeatCursorLoc;
				fxEnvelopes[i].repeatActive = false;
				soundDispatch(fxEnvelopes[i].repeatName, true);
			}
		}

		// If updated queue from repeated section, mix the new queue content
		// a second time from within the MIDDLE of the section.
		for (i = 0; i < NUM_CHANNELS; i++) {
			if (fxEnvelopes[i].midRepeat)
			{
				fxEnvelopes[i].midRepeat = false;
				mixLimit = fxEnvelopes[i].writeFromQueue(
					mixBuffer, mixLimit, SAMPLE_WRITE_SIZE, repeatCursorLoc);
			}
		}

		// Transfer mix buffer contents to output buffer.
		for (i = 0; i < mixLimit; i++)
		{
			outBuf.writeFloat(mixBuffer[i]);
			outBuf.writeFloat(mixBuffer[i]);
		}

		if (mixLimit == 0 && silenceRemaining > 0)
		{
			// Extended silence is used to prevent interstitial skipping.
			silenceRemaining -= SAMPLE_WRITE_SIZE;
			for (i = 0; i < SAMPLE_WRITE_SIZE; i++)
			{
				outBuf.writeFloat(0);
				outBuf.writeFloat(0);
			}
		}
		else if (mixLimit > 0 && mixLimit <= SAMPLE_WRITE_SIZE)
		{
			// Just in case the mix buffer would be greater than zero,
			// but less than the minimum threshold for sound cutoff,
			// pad the buffer out to extend play a bit further.
			// This prevents unexpected "jumps" from the AS3 sound system
			// "stopping" and "restarting."
			for (i = mixLimit; i < SAMPLE_WRITE_SIZE; i++)
			{
				outBuf.writeFloat(0);
				outBuf.writeFloat(0);
			}
		}
	}

	event.data.writeBytes(outBuf);
}

public static function startEchoTrace(srcVoice:int):void {
	for (var i:int = NUM_CHANNELS - 1; i >= 0; i--)
	{
		if (fxEnvelopes[i].eState == FxEnvelope.FX_DORMANT)
		{
			fxEnvelopes[i].echoExisting(fxEnvelopes[srcVoice]);
			break;
		}
	}
}

public static function distributePlayNotes(playStr:String, syncFromRepeat:Boolean=false):void {
	var curVoice:int = lastSelVoice;
	var curStr:String = playStr.toUpperCase();

	while (curStr.length > 0) {
		var nextVoiceLoc:int = curStr.indexOf("Z");
		if (nextVoiceLoc == -1 || nextVoiceLoc + 3 > curStr.length)
		{
			// If we are repeating a sequence, ensure queue empty.
			if (syncFromRepeat)
				fxEnvelopes[curVoice].eraseQueueForRepeat();

			// No more voice specs; send remainder of string to current voice.
			add2Queue(curVoice, curStr);
			break;
		}
		else
		{
			// If we are repeating a sequence, ensure queue empty.
			if (syncFromRepeat)
				fxEnvelopes[curVoice].eraseQueueForRepeat();

			// Send queue up until voice change to current voice.
			add2Queue(curVoice, curStr.substr(0, nextVoiceLoc));

			// Select new voice and resume string later.
			curVoice = int(curStr.substr(nextVoiceLoc + 1, 2));
			curStr = curStr.substr(nextVoiceLoc + 3);
		}
	}

	lastSelVoice = curVoice;
}

public static function add2Queue(curVoice:int, curStr:String):void {
	if (fxEnvelopes[curVoice].add2Queue(curStr))
	{
		// If sound is not playing, it must be "woken" up.
		if (channels[0] == null)
			playPending = true;
	}
}

public static function soundPlayComplete(event:Event):void {
	//var sObj:Object = event.currentTarget as SoundChannel;
	//var curVoice:int = channels.indexOf(sObj);
	var sObj:Object = event.currentTarget as SoundChannel;

	// Erase record of active channel
	channels[0] = null;
	var doPlayVoice:Boolean = false;
	for (var i:int = 0; i < NUM_CHANNELS; i++)
	{
		// If queue managed to fill up during this time, play again.
		if (fxEnvelopes[i].queue.length > 0)
			doPlayVoice = true;
	}

	if (doPlayVoice)
	{
		playPending = true;
		playVoice();
	}
}

public static function getChannelPlaying(curVoice:int):int {
	if (channels[0] != null && curVoice >= 0 && curVoice < NUM_CHANNELS)
	{
		if (fxEnvelopes[curVoice].eState != FxEnvelope.FX_DORMANT)
			return 1;
	}

	return 0;
}

public static function isAnyChannelPlaying():Boolean {
	for (var i:int = 0; i < NUM_CHANNELS; i++)
	{
		if (getChannelPlaying(i) != 0)
			return true;
	}

	return false;
}

public static function stopChannel(curVoice:int):Boolean {
	if (channels[0] != null && curVoice >= 0 && curVoice < NUM_CHANNELS)
	{
		fxEnvelopes[curVoice].eState = FxEnvelope.FX_DORMANT;
		fxEnvelopes[curVoice].queue = "";
		fxEnvelopes[curVoice].priority = -1;
		return true;
	}

	return false;
}

public static function stopAllChannels():Boolean {
	for (var i:int = 0; i <= Sounds.NUM_CHANNELS; i++)
		Sounds.stopChannel(i);

	return true;
}

public static function playVoice():void {
	if (playPending)
	{
		playPending = false;
		channels[0] = sounds[0].play();
		if (channels[0] != null)
		{
			channels[0].addEventListener(Event.SOUND_COMPLETE, soundPlayComplete);
		}
		else
		{
			trace("ERROR!  Unable to create sound channel.");
		}
	}
}

public static function getQueueComposite():String {
	// Save tempo
	var allStr:String = "U" + utils.threegrouping(FxEnvelope.tempoPos);

	for (var i:int = 0; i < NUM_CHANNELS; i++)
	{
		// Each channel is examined for potentially looping tracks.
		var fx:FxEnvelope = fxEnvelopes[i];
		if (fx.queuePos <= fx.queue.length && fx.echoTrigger == -1 && fx.repeatName != "")
		{
			// If a looping track is found, save the channel number, priority,
			// volume, and repeat name.  When the world is reloaded, we can start
			// the repeated portion of these channels from the beginning.
			var qStr:String = "Z" + utils.twogrouping(i);
			if (fx.priority > 0)
				qStr += "P" + utils.twogrouping(fx.priority);
			qStr += "V" + utils.twogrouping(fx.baseVolPos);
			qStr += "R" + fx.repeatName + ":";

			// Add to overall composite string
			allStr += qStr;
		}
	}

	return allStr;
}

// This is called to dispatch a "sound effect" consisting of a PLAY string.
public static function soundDispatch(sName:String, syncFromRepeat:Boolean=false):Boolean {
	if (soundFx.hasOwnProperty(sName))
	{
		if (globalProps["SOUNDOFF"] != 1)
			distributePlayNotes(soundFx[sName], syncFromRepeat);
		return true;
	}

	// Not found
	return false;
}

// This sets the tempo for all channels.
public static function updateAllTempo(tempoMultiplier:Number):void {
	FxEnvelope.tempoBaseMultiplier = tempoMultiplier;

	for (var i:int = 0; i < NUM_CHANNELS; i++)
	{
		var fx:FxEnvelope = fxEnvelopes[i];
		fx.tempoMultiplier = tempoMultiplier;
	}
}

// This sets the master volume level for one or more channels.
public static function setMasterVolume(idx:int, channelStart:int=0, channelEnd:int=256):void {

	if (idx < 0 || idx > 50)
		return;

	for (var i:int = channelStart; i <= channelEnd && i >= 0 && i < NUM_CHANNELS; i++)
	{
		var fx:FxEnvelope = fxEnvelopes[i];
		var prevMultiplier:Number = fx.masterVolMultiplier;
		fx.masterVolPos = idx;
		fx.masterVolMultiplier = FxEnvelope.volume_table[idx];

		// Modify the base volume level of currently playing sound.
		if (prevMultiplier > 0.0)
			fx.baseVolMultiplier *= (fx.masterVolMultiplier / prevMultiplier);
		else
			fx.baseVolMultiplier = fx.masterVolMultiplier;
	}
}

public static function testPlay():void {
	// "Standard" echo effect
	//distributePlayNotes("K40:0.3:");

	playVoice();
}

}
}

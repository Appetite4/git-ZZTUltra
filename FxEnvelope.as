// Sound effects envelope information.

package {
public class FxEnvelope {

import flash.utils.ByteArray;

public static const FX_DORMANT:int = 0;
public static const FX_NEXTNOTE:int = 1;
public static const FX_ENVELOPE:int = 2;
public static const FX_PERCUSSION:int = 3;
public static const FX_SWEEP:int = 4;
public static const FX_REST:int = 5;
public static const FX_ECHO_ENVELOPE:int = 6;
public static const FX_ECHO_PERCUSSION:int = 7;
public static const FX_ECHO_SWEEP:int = 8;

public static const SR:Number = 44100.0;
public static const ASSUMED_TEMPO:Number = 137.142857143;
public static const ATTACK_RATE:Number = 0.025;
public static const ATTACK_DUR:Number = 1 / ATTACK_RATE;
public static const RELEASE_RATE:Number = 0.005;
public static const RELEASE_DUR:Number = 1 / RELEASE_RATE;
public static const SWEEP_RELEASE_RATE:Number = 0.025;
public static const SWEEP_RELEASE_DUR:Number = 1 / SWEEP_RELEASE_RATE;

public static var realIters:int = 0;

//  Calculation of Q1-duration based on tempo:
//  1 min              60 sec   samples per second
//  ---------------- * ------ * ------------------
//  1 tempo constant   1 min    1 sec
public static const Q1_DURATION:Number = 1.0 / ASSUMED_TEMPO * 60.0 * SR;
public static const H1_DURATION:Number = Q1_DURATION * 2.0;
public static const W1_DURATION:Number = Q1_DURATION * 4.0;
public static const I1_DURATION:Number = Q1_DURATION / 2.0;
public static const S1_DURATION:Number = Q1_DURATION / 4.0;
public static const T1_DURATION:Number = Q1_DURATION / 8.0;
public static const T64_DURATION:Number = Q1_DURATION / 16.0;

public static var octave_table:Array = [
//  0          1      2     3     4     5     6     7
	0.25,   0.25,  0.25,  0.5,  1.0,  2.0,  4.0,  8.0
];
public static var frequency_table:Array = [
//  B           C           C#          D           D#          E           F
	246.941651, 261.625565, 277.182631, 293.664768, 311.126984, 329.627557, 349.228231,
//  F#          G           G#          A           A#          B           C
	369.994423, 391.995436, 415.304698, 440.000000, 466.163762, 493.883301, 523.251131
];

// Volume multiplier is calculated as 2^(-(50 - idx) / 5)
// At 50, volume is at max (not attenuated).
// At 0, everything is muted.
public static var volume_table:Array = [
0.0,
0.0011217757,
0.0012885819,
0.001480192,
0.0017002941,
0.001953125,
0.0022435515,
0.0025771639,
0.0029603839,
0.0034005881,
0.00390625,
0.0044871029,
0.0051543278,
0.0059207678,
0.0068011763,
0.0078125,
0.0089742059,
0.0103086556,
0.0118415357,
0.0136023526,
0.015625,
0.0179484118,
0.0206173111,
0.0236830714,
0.0272047051,
0.03125,
0.0358968236,
0.0412346222,
0.0473661427,
0.0544094102,
0.0625,
0.0717936472,
0.0824692444,
0.0947322854,
0.1088188204,
0.125,
0.1435872944,
0.1649384888,
0.1894645708,
0.2176376408,
0.25,
0.2871745887,
0.3298769777,
0.3789291416,
0.4352752816,
0.5,
0.5743491775,
0.6597539554,
0.7578582833,
0.8705505633,
1.0
];

// Format is:
// 0:  initialized, 1:  index, 2:  equivalent frequency, 3:  stored cycles,
// 4:  mono sample Number vector, 5:  number of samples in ByteArray.
public static var allSoundInfo:Array;
public static var tempoPos:int = 137;
public static var tempoBaseMultiplier:Number = 1.0;

public var channel:int;
public var priority:int;
public var eState:int;
public var baseVolPos:int;
public var queuePos:int;
public var queue:String;
public var freq:Number;
public var freqLeft:Number;
public var freqInc:Number;
public var curSoundInfo:Array;
public var lastSample:Number;
public var lastSample2:Number;
public var samplePos:Number;
public var curDuration:Number;
public var advMultiplier:Number;
public var baseVolMultiplier:Number;
public var envelopeMultiplier:Number;
public var echoMultiplier:Number;
public var echoDelay:Number;
public var tempoMultiplier:Number;
public var masterVolPos:int;
public var masterVolMultiplier:Number;
public var curOctave:int;
public var samplesLeft:int;
public var attackTrigger:int;
public var releaseTrigger:int;
public var echoTrigger:int;
public var writeSizeLeft:int;
public var writeCursor:int;
public var writeLimit:int;
public var repeatName:String;
public var repeatActive:Boolean;
public var midRepeat:Boolean;
public var repeatCursorLoc:int;
public var tick64Count:int;
public var tick64CountSize:int;

public function FxEnvelope(myChannel:int) {
	channel = myChannel;
	priority = -1;
	eState = FX_DORMANT;
	queuePos = 0;
	queue = "";
	freq = 1.0;
	curSoundInfo = null;
	lastSample = 0.0;
	lastSample2 = 0.0;
	samplePos = 0.0;
	curDuration = T1_DURATION;
	advMultiplier = 1.0;
	baseVolPos = 40;
	baseVolMultiplier = 0.25;
	envelopeMultiplier = 0.0;
	echoMultiplier = 0.0;
	echoDelay = 0.0;
	tempoMultiplier = tempoBaseMultiplier;
	masterVolPos = 50;
	masterVolMultiplier = 1.0;
	curOctave = 4;
	samplesLeft = 0;
	echoTrigger = -1;
	repeatName = "";
	repeatActive = false;
	midRepeat = false;
	repeatCursorLoc = 0;
	tick64Count = 0;
	tick64CountSize = 2;
}

public function echoExisting(srcEnvelope:FxEnvelope) {
	eState = srcEnvelope.eState + (FX_ECHO_ENVELOPE - FX_ENVELOPE);
	queuePos = 0;
	queue = "";
	freq = srcEnvelope.freq;
	curSoundInfo = srcEnvelope.curSoundInfo;
	samplePos = 0;
	curDuration = srcEnvelope.curDuration;
	advMultiplier = srcEnvelope.advMultiplier;
	baseVolMultiplier = srcEnvelope.baseVolMultiplier * srcEnvelope.echoMultiplier;
	echoMultiplier = srcEnvelope.echoMultiplier;
	envelopeMultiplier = 0.0;
	curOctave = srcEnvelope.curOctave;
	samplesLeft = int(curDuration);
	attackTrigger = samplesLeft - int(ATTACK_DUR);
	releaseTrigger = int(RELEASE_DUR);
	echoTrigger = int(SR * srcEnvelope.echoDelay);
}

public function intFrom2D(s:String, start:int, defInt:int=0):int {
	return utils.intMaybe(s.substr(start, 2), defInt);
}

public function intFrom3D(s:String, start:int, defInt:int=0):int {
	return utils.intMaybe(s.substr(start, 3), defInt);
}

public function add2Queue(newAddition:String):Boolean {
	if (newAddition == "")
	{
		// Nothing to play...
		return false;
	}
	else if (newAddition.charAt(0) == "P")
	{
		// Priority-based playback.
		var newPriority:int = 0;
		if (newAddition.length >= 3)
			newPriority = intFrom2D(newAddition, 1);

		if (newPriority > priority || eState == FX_DORMANT)
		{
			// Overridden priority; cancel previous queue.
			priority = newPriority;
			queue = newAddition;
			queuePos = 0;
			tick64Count = 0;
			eState = FX_NEXTNOTE;
			return true;
		}
		else if (newPriority < priority)
		{
			// Lesser priority; discard addition to queue.
			return false;
		}
		else
		{
			if (newAddition.length >= 4)
			{
				if (newAddition.charAt(3) == ":")
				{
					// Same priority but "self-overridden."
					queue = newAddition;
					queuePos = 0;
					tick64Count = 0;
					eState = FX_NEXTNOTE;
					return true;
				}
			}

			// Same priority; append to queue.
			queue = queue + newAddition;
			return true;
		}
	}
	else if (eState == FX_DORMANT)
	{
		// Voice needs to be woken up to play a brand-new queue.
		priority = 0;
		queue = newAddition;
		queuePos = 0;
		tick64Count = 0;
		eState = FX_NEXTNOTE;
		return true;
	}
	else
	{
		// Assume same priority; append to queue.
		queue = queue + newAddition;
		return true;
	}

	return false;
}

public function economizeQueue():void {
	if (queuePos > 0 && queuePos <= queue.length)
	{
		// Economize string, to prevent strings from growing
		// too large as queue is digested.
		queue = queue.substr(queuePos);
		queuePos = 0;
	}
}

public function eraseQueueForRepeat():void {
	// Effectively, start the queue over at nothing.  Flag for mid-buffer repeat.
	queue = "";
	queuePos = 0;
	eState = FX_DORMANT;
	midRepeat = true;
}

// writeSizeLeft:  How many samples remain until end of written sample window
// writeCursor:    Zero-based position of sample window being written
// writeLimit:     Current length of sample buffer as sample window is being established;
//                 maximum is sampleWriteSize.  Starts at zero.  If a previous sample
//                 "grew" the buffer to a certain size, mixing commands will add the
//                 samples to the existing buffer up to the point where it gets filled,
//                 and adding to the buffer beyond this point.

public function writeFromQueue(mixBuf:Vector.<Number>, mixLimit:int, sampleWriteSize:int,
	startCursor:int=0):int {
	writeCursor = startCursor;
	writeSizeLeft = sampleWriteSize - writeCursor;
	writeLimit = mixLimit;

	while (writeSizeLeft > 0) {
		switch (eState) {
			case FX_DORMANT:
				return writeLimit;
			case FX_NEXTNOTE:
				if (queuePos >= queue.length)
				{
					if (!playSyncExtended())
					{
						queue = "";
						eState = FX_DORMANT;
						priority = -1;
						return writeLimit;
					}
				}
				else if (!prepNextNote(mixBuf))
				{
					queue = "";
					eState = FX_DORMANT;
					priority = -1;
					return writeLimit;
				}
			break;
			case FX_ECHO_ENVELOPE:
				while (writeSizeLeft > 0 && echoTrigger > 0) {
					writeSizeLeft--;
					echoTrigger--;
					mixFloat(mixBuf, 0.0);
				}

				if (echoTrigger <= 0)
					eState = FX_ENVELOPE;
			break;
			case FX_ENVELOPE:
				writeEnvelopeRegion(mixBuf);
			break;
			case FX_REST:
				writeRestRegion(mixBuf);
			break;
			case FX_ECHO_PERCUSSION:
				while (writeSizeLeft > 0 && echoTrigger > 0) {
					writeSizeLeft--;
					echoTrigger--;
					mixFloat(mixBuf, 0.0);
				}

				if (echoTrigger <= 0)
					eState = FX_PERCUSSION;
			break;
			case FX_PERCUSSION:
				writePercussionRegion(mixBuf);
			break;
			case FX_ECHO_SWEEP:
				while (writeSizeLeft > 0 && echoTrigger > 0) {
					writeSizeLeft--;
					echoTrigger--;
					mixFloat(mixBuf, 0.0);
				}

				if (echoTrigger <= 0)
					eState = FX_SWEEP;
			break;
			case FX_SWEEP:
				writeSweepRegion(mixBuf);
			break;
		}
	}

	return writeLimit;
}

public function writeEnvelopeRegion(mixBuf:Vector.<Number>):Boolean {
	while (writeSizeLeft > 0) {
		var sInt:int = int(samplePos);
		var s1:Number;
		var s2:Number;
		if (sInt < curSoundInfo[5] - 1)
		{
			s1 = curSoundInfo[4][sInt];
			s2 = curSoundInfo[4][sInt + 1];
		}
		else if (sInt == curSoundInfo[5] - 1)
		{
			s1 = curSoundInfo[4][sInt];
			s2 = curSoundInfo[4][0];
		}
		else
		{
			samplePos -= curSoundInfo[5];
			sInt = int(samplePos);
			s1 = curSoundInfo[4][sInt];
			s2 = curSoundInfo[4][sInt + 1];
		}

		// Linear interpolation
		s1 = (s2 - s1) * (samplePos - sInt) + s1;
		samplePos += advMultiplier;
		samplesLeft--;
		writeSizeLeft--;

		if (samplesLeft <= 0)
		{
			lastSample = 0.0;
			lastSample2 = 0.0;
			mixFloat(mixBuf, 0.0);
			if (echoTrigger == -1)
				eState = FX_NEXTNOTE;
			else
			{
				eState = FX_DORMANT;
				priority = -1;
			}
			return true;
		}
		else if (samplesLeft > attackTrigger && envelopeMultiplier < 1.0)
			envelopeMultiplier += ATTACK_RATE;
		else if (samplesLeft > releaseTrigger)
			envelopeMultiplier = 1.0;
		else if (envelopeMultiplier > 0.0)
			envelopeMultiplier -= RELEASE_RATE;
		else
		{
			mixFloat(mixBuf, 0.0);
			if (echoTrigger == -1)
				eState = FX_NEXTNOTE;
			else
			{
				eState = FX_DORMANT;
				priority = -1;
			}
			return true;
		}

		// Filtered:  output time-averages over 3 samples, filtering to about
		// 1/3 of Nyquist frequency in theory.  In actuality, there will still
		// be frequencies in the spectrum up to about 13000 Hz, but this is
		// reasonable in terms of preventing annoying high harmonics.
		mixFloat(mixBuf, (s1 + lastSample + lastSample2) * 0.3333333333 *
			envelopeMultiplier * baseVolMultiplier);
		lastSample2 = lastSample;
		lastSample = s1;

		// Original:  unfiltered output resulted in high harmonics.
		//mixFloat(mixBuf, s1 * envelopeMultiplier * baseVolMultiplier);
	}

	return false;
}

public function writeRestRegion(mixBuf:Vector.<Number>):Boolean {
	while (writeSizeLeft > 0) {
		samplesLeft--;
		writeSizeLeft--;

		if (samplesLeft <= 0)
		{
			// Change state to next note
			eState = FX_NEXTNOTE;
			mixFloat(mixBuf, 0.0);
			return true;
		}

		mixFloat(mixBuf, 0.0);
	}

	return false;
}

public function writePercussionRegion(mixBuf:Vector.<Number>):Boolean {
	while (writeSizeLeft > 0) {
		var sample:Number;
		if (int(samplePos) < curSoundInfo[5])
			sample = curSoundInfo[4][int(samplePos)] * baseVolMultiplier;
		else
			sample = 0.0;
		samplePos += advMultiplier;
		samplesLeft--;
		writeSizeLeft--;
		//realIters++;

		if (samplesLeft <= 0)
		{
			// Change state to next note
			mixFloat(mixBuf, 0.0);
			if (echoTrigger == -1)
				eState = FX_NEXTNOTE;
			else
			{
				eState = FX_DORMANT;
				priority = -1;
			}

			return true;
		}

		mixFloat(mixBuf, sample);
	}

	return false;
}

public function writeSweepRegion(mixBuf:Vector.<Number>):Boolean {
	while (writeSizeLeft > 0 && freqLeft >= 0.0)
	{
		if (samplesLeft <= 0)
		{
			// Initiate a new frequency stub
			samplesLeft = int(curDuration);
			attackTrigger = samplesLeft - int(ATTACK_DUR);
			releaseTrigger = int(SWEEP_RELEASE_DUR);
			samplePos = 0;
			envelopeMultiplier = 0.0;

			// Select base sample from iterated frequency
			curSoundInfo = allSoundInfo[Sounds.B7_X8];
			for (var f:int = Sounds.E2_X1; f >= Sounds.B7_X8; f--)
			{
				if (freq < allSoundInfo[f][2])
				{
					curSoundInfo = allSoundInfo[f + 1];
					break;
				}
			}

			// Determine advancement multiplier (usually between 1 and 2)
			advMultiplier = freq / curSoundInfo[2];
			echoTrigger = -1;
		}

		while (writeSizeLeft > 0) {
			var sInt:int = int(samplePos);
			var s1:Number;
			var s2:Number;
			if (sInt < curSoundInfo[5] - 1)
			{
				s1 = curSoundInfo[4][sInt];
				s2 = curSoundInfo[4][sInt + 1];
			}
			else if (sInt == curSoundInfo[5] - 1)
			{
				s1 = curSoundInfo[4][sInt];
				s2 = curSoundInfo[4][0];
			}
			else
			{
				samplePos -= curSoundInfo[5];
				sInt = int(samplePos);
				s1 = curSoundInfo[4][sInt];
				s2 = curSoundInfo[4][sInt + 1];
			}

			// Linear interpolation
			s1 = (s2 - s1) * (samplePos - sInt) + s1;
			samplePos += advMultiplier;
			samplesLeft--;
			writeSizeLeft--;

			if (samplesLeft <= 0)
			{
				// Iterate frequency forward
				mixFloat(mixBuf, 0.0);
				freq += freqInc;
				freqLeft -= Math.abs(freqInc);
				if (freqLeft < 0.0)
				{
					eState = FX_NEXTNOTE;
					return true;
				}
				break;
			}
			else if (samplesLeft > attackTrigger && envelopeMultiplier < 1.0)
				envelopeMultiplier += ATTACK_RATE;
			else if (samplesLeft > releaseTrigger)
				envelopeMultiplier = 1.0;
			else if (envelopeMultiplier > 0.0)
				envelopeMultiplier -= RELEASE_RATE;
			else
			{
				// Iterate frequency forward
				mixFloat(mixBuf, 0.0);
				freq += freqInc;
				freqLeft -= Math.abs(freqInc);
				if (freqLeft < 0.0)
				{
					eState = FX_NEXTNOTE;
					return true;
				}
				break;
			}

			mixFloat(mixBuf, s1 * envelopeMultiplier * baseVolMultiplier);
		}
	}

	return false;
}

public function mixFloat(mixBuf:Vector.<Number>, sample:Number):void {
	if (writeCursor < writeLimit)
	{
		// Write mixed output
		mixBuf[writeCursor] += sample;
		writeCursor++;
	}
	else
	{
		// Set output
		mixBuf[writeCursor++] = sample;
		writeLimit++;
	}
}

public function prepNextNote(outBuf:Vector.<Number>):Boolean {
	var b:String = queue.charAt(queuePos++);
	//trace(b, queuePos);
	switch (b) {
		case "W":
			tick64CountSize = 64;
			curDuration = W1_DURATION * tempoMultiplier;
		break;
		case "H":
			tick64CountSize = 32;
			curDuration = H1_DURATION * tempoMultiplier;
		break;
		case "Q":
			tick64CountSize = 16;
			curDuration = Q1_DURATION * tempoMultiplier;
		break;
		case "I":
			tick64CountSize = 8;
			curDuration = I1_DURATION * tempoMultiplier;
		break;
		case "S":
			tick64CountSize = 4;
			curDuration = S1_DURATION * tempoMultiplier;
		break;
		case "T":
			tick64CountSize = 2;
			curDuration = T1_DURATION * tempoMultiplier;
		break;
		case ".":
			curDuration *= 1.5;
		break;
		case "3":
			curDuration *= 0.3333333333;
		break;
		case "+":
			if (++curOctave > 7)
				curOctave = 7;
		break;
		case "-":
			if (--curOctave < 2)
				curOctave = 2;
		break;
		case "X":
			eState = FX_REST;
			tick64Count += tick64CountSize;
			samplesLeft = int(curDuration);
			//trace(samplesLeft, writeSizeLeft);
		break;
		case "C":
			letteredNote(1);
		break;
		case "D":
			letteredNote(3);
		break;
		case "E":
			letteredNote(5);
		break;
		case "F":
			letteredNote(6);
		break;
		case "G":
			letteredNote(8);
		break;
		case "A":
			letteredNote(10);
		break;
		case "B":
			letteredNote(12);
		break;
		case "0":
			percussionNote(Sounds.PERC_0);
		break;
		case "1":
			percussionNote(Sounds.PERC_1);
		break;
		case "2":
			percussionNote(Sounds.PERC_2);
		break;
		case "4":
			percussionNote(Sounds.PERC_4);
		break;
		case "5":
			percussionNote(Sounds.PERC_5);
		break;
		case "6":
			percussionNote(Sounds.PERC_6);
		break;
		case "7":
			percussionNote(Sounds.PERC_7);
		break;
		case "8":
			percussionNote(Sounds.PERC_8);
		break;
		case "9":
			percussionNote(Sounds.PERC_9);
		break;

		// EXPANDED PLAY SYNTAX
		case "V":
			if (queuePos + 2 <= queue.length)
			{
				var idx:int = intFrom2D(queue, queuePos, -1);
				if (idx == 0 && queue.charAt(queuePos) != "0")
					idx = -1;
				if (idx >= 0 && idx <= 50)
				{
					queuePos += 2;
					baseVolPos = idx;
					baseVolMultiplier = volume_table[idx] * masterVolMultiplier;
				}
			}
		break;
		case "J":
			tick64CountSize = 1;
			curDuration = T64_DURATION * tempoMultiplier;
		break;
		case "K":
			if (queuePos + 5 <= queue.length)
			{
				idx = intFrom2D(queue, queuePos, -1);
				if (idx == 0 && queue.charAt(queuePos) != "0")
					idx = -1;
				if (idx >= 0 && idx <= 50)
				{
					echoMultiplier = volume_table[idx];
					queuePos += 3;

					idx = queue.indexOf(":", queuePos);
					if (idx != -1)
					{
						echoDelay = utils.float0(queue.substr(queuePos, idx - queuePos));
						queuePos = idx + 1;
					}
				}
			}
		break;
		case "U":
			if (queuePos + 3 <= queue.length)
			{
				tempoPos = intFrom3D(queue, queuePos, -1);
				if (tempoPos > 0)
				{
					queuePos += 3;
					tempoMultiplier = ASSUMED_TEMPO / tempoPos;

					// If colon present at end, only current channel tempo is affected.
					if (queuePos >= queue.length)
						Sounds.updateAllTempo(tempoMultiplier);
					else if (queue.charAt(queuePos) != ":")
						Sounds.updateAllTempo(tempoMultiplier);
					else
						queuePos++;
				}
			}
		break;
		case "P":
			if (queuePos + 2 <= queue.length)
			{
				// We already processed priority; skip over.
				idx = intFrom2D(queue, queuePos, -1);
				if (idx >= 0 && idx <= 99)
					queuePos += 2;
			}
		break;
		case "R":
			idx = queue.indexOf(":", queuePos);
			if (idx != -1)
			{
				repeatName = queue.substr(queuePos, idx - queuePos);
				queuePos = idx + 1;
				if (repeatName != "")
				{
					repeatActive = true;
					repeatCursorLoc = writeCursor;
				}
			}
		break;
		case "@":
			curOctave = 4;
			curDuration = T1_DURATION * tempoMultiplier;
			tick64CountSize = 2;
		break;
		case "%":
			if (queuePos + 5 <= queue.length)
			{
				// Get 4 values:  startFreq, endFreq, freqInc, singleDuration
				idx = queue.indexOf(":", queuePos);
				if (idx == -1)
					idx = queue.length - 1;
				freq = utils.float0(queue.substr(queuePos, idx - queuePos));
				queuePos = idx + 1;
				idx = queue.indexOf(":", queuePos);
				if (idx == -1)
					idx = queue.length - 1;
				freqLeft = utils.float0(queue.substr(queuePos, idx - queuePos));
				queuePos = idx + 1;
				idx = queue.indexOf(":", queuePos);
				if (idx == -1)
					idx = queue.length - 1;
				freqInc = utils.float0(queue.substr(queuePos, idx - queuePos));
				queuePos = idx + 1;
				idx = queue.indexOf(":", queuePos);
				if (idx == -1)
					idx = queue.length - 1;
				curDuration = utils.float0(queue.substr(queuePos, idx - queuePos)) * SR;
				queuePos = idx + 1;

				eState = FX_SWEEP;
				envelopeMultiplier = 0.0;
				samplesLeft = 0;
				freqInc = utils.sgn(freqLeft - freq) * Math.abs(freqInc);
				freqLeft = Math.abs(freqLeft - freq);
			}
		break;
	}

	return true;
}

public function letteredNote(idx:int):void {
	// Add to logged ticks
	tick64Count += tick64CountSize;

	// Check if sharp or flat follows
	if (queuePos < queue.length)
	{
		if (queue.charAt(queuePos) == "#")
		{
			idx++;
			queuePos++;
		}
		else if (queue.charAt(queuePos) == "!")
		{
			idx--;
			queuePos++;
		}
	}

	// Change to attack state
	eState = FX_ENVELOPE;
	samplesLeft = int(curDuration);
	attackTrigger = samplesLeft - int(ATTACK_DUR);
	releaseTrigger = int(RELEASE_DUR);
	samplePos = 0;
	envelopeMultiplier = 0.0;
	lastSample = 0.0;
	lastSample2 = 0.0;

	// Select base sample from frequency
	freq = frequency_table[idx] * octave_table[curOctave];
	curSoundInfo = allSoundInfo[Sounds.B7_X8];
	for (var f:int = Sounds.E2_X1; f >= Sounds.B7_X8; f--)
	{
		if (freq < allSoundInfo[f][2])
		{
			//trace(f+1);
			curSoundInfo = allSoundInfo[f + 1];
			break;
		}
	}

	// Determine advancement multiplier (usually between 1 and 2)
	advMultiplier = freq / curSoundInfo[2];
	echoTrigger = -1;
	//trace(advMultiplier, freq, curSoundInfo[2], curSoundInfo[5]);

	// If echo present, set echo trace
	if (echoDelay > 0.0 && echoMultiplier > 0.0)
		Sounds.startEchoTrace(channel);
}

public function percussionNote(idx:int):void {
	// Add to logged ticks
	tick64Count += tick64CountSize;

	// Change to percussion state
	curSoundInfo = allSoundInfo[idx];
	eState = FX_PERCUSSION;
	samplesLeft = int(curDuration);
	samplePos = 0;
	advMultiplier = 1.0;
	echoTrigger = -1;

	// If echo present, set echo trace
	if (echoDelay > 0.0 && echoMultiplier > 0.0)
		Sounds.startEchoTrace(channel);
}

public function playSyncExtended():Boolean {
	// Only extend channel 1, and only if sync location identified.
	if (Sounds.playSyncCallback == null || channel != 1 || tick64Count < 64)
		return false;

	if (Sounds.playSyncCallback())
		return true;
	else
	{
		Sounds.playSyncCallback = null;
		return false;
	}
}

/*
Some additional codes are possible:

Ynn:adsr    - Indicates envelope for voice nn, in the form of
              attack rate/decay rate/sustain level/release rate.
*/

}
}

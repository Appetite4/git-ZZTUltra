// ZZTBoard.as:  ZZT/SZT individual board instance.

package {
public class ZZTBoard {

import flash.utils.ByteArray;
import flash.utils.Dictionary;

// Buffers used for storing grid data
public var typeBuffer:ByteArray;
public var colorBuffer:ByteArray;
public var lightBuffer:ByteArray;

// Board properties
public var props:Object;

// Board regions
public var regions:Object;

// Status elements for board
public var statElementCount:int;
public var statLessCount:int;
public var statElem:Vector.<SE>;
public var playerSE:SE;

// Timestamp and state save info
public var saveStamp:String;
public var boardIndex:int;
public var saveIndex:int;
public var saveType:int;

public var worldProps:Object;
public var worldVars:Object;

};
};

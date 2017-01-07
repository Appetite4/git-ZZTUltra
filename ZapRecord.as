// ZapRecord.as:  A label zap/restore record instance.

package {
public class ZapRecord {

public var codeID:int;
public var labelLoc:int;
public var saveIndex:int;

public function ZapRecord(id:int, loc:int, zType:int, sIndex:int) {
	codeID = id;
	labelLoc = loc;
	saveIndex = sIndex;
	if (zType == 2)
		labelLoc = -labelLoc;
}

};
};

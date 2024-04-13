package ;

import hxbit.Serializable;
import haxe.ds.Vector;

class LevelState implements Serializable {
    @:s public var hasSlime : Vector<Vector<Vector<Bool> > >;
    @:s public var floorId : Int = 1;

    public function new(floorCount:Int) {
        hasSlime = new Vector(floorCount);
        for(fid in 0...floorCount) {
            hasSlime[fid] = new Vector(Level.HEIGHT_TILES);
            for(i in 0...Level.HEIGHT_TILES) {
                hasSlime[fid][i] = new Vector(Level.WIDTH_TILES, false);
            }
        }
    }
}
package fx;

import h2d.Tile;
import Assets;

class AnimParticle extends Particle {
	var tiles : Array<Tile>;
	var curFrame : Float;
	var animSpeed : Float;

    public function new(animData:AnimData, ?time:Float=-1.) {
        tiles = animData.tiles;
        curFrame = 0.;
        animSpeed = animData.fps;
        if(time == -1) {
            time = tiles.length / animSpeed;
        } else {
            animSpeed = tiles.length / time;
        }
        super(tiles[0], time);
    }

    override public function update(dt:Float) {
        if(!super.update(dt)) return false;
        curFrame += animSpeed * dt;
        if(curFrame >= tiles.length) {
            return true;
        }
        t = tiles[Util.floor(curFrame)];
        return true;
    }
}
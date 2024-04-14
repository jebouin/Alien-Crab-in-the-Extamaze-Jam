package ui;

import h2d.Tile;
import h2d.TileGroup;

class Path {
    var atlas : Tile;
    var tg : TileGroup;
    public var path : Array<{x:Int, y:Int}> = null;
    public var visible(default, set) : Bool = false;

    public function new() {
        atlas = Assets.getTile("tileset", "path");
        tg = new TileGroup(atlas);
        Game.inst.world.add(tg, Game.LAYER_PATH);
    }

    public function compute(fx:Int, fy:Int, tx:Int, ty:Int, ignoreSlippery:Bool) {
        tg.clear();
        path = Game.inst.level.computePath(fx, fy, tx, ty, ignoreSlippery);
        if(path == null) {
            return;
        }
        function getId(pp, p, np, reverse:Bool) {
            var id = 8;
            if(np.x == p.x + 1 && np.y == p.y && pp.x == p.x && pp.y == p.y + 1) id = 0;
            else if(np.x == p.x - 1 && np.y == p.y && pp.x == p.x && pp.y == p.y + 1) id = 1;
            else if(np.x == p.x + 1 && np.y == p.y && pp.x == p.x && pp.y == p.y - 1) id = 5;
            else if(np.x == p.x - 1 && np.y == p.y && pp.x == p.x && pp.y == p.y - 1) id = 6;
            else if(np.y == p.y && pp.y == p.y && np.x == p.x + 1 && pp.x == p.x - 1) id = 3;
            else if(np.x == p.x && pp.x == p.x && np.y == p.y + 1 && pp.y == p.y - 1) id = 12;
            else if(!reverse && np.x < 0 && np.y < 0 && pp.x == p.x - 1) id = 4;
            else if(!reverse && np.x < 0 && np.y < 0 && pp.x == p.x + 1) id = 2;
            else if(!reverse && np.x < 0 && np.y < 0 && pp.y == p.y - 1) id = 17;
            else if(!reverse && np.x < 0 && np.y < 0 && pp.y == p.y + 1) id = 7;
            else if(!reverse && pp.x < 0 && pp.y < 0 && np.x == p.x - 1) id = 16;
            else if(!reverse && pp.x < 0 && pp.y < 0 && np.x == p.x + 1) id = 15;
            else if(!reverse && pp.x < 0 && pp.y < 0 && np.y == p.y - 1) id = 11;
            else if(!reverse && pp.x < 0 && pp.y < 0 && np.y == p.y + 1) id = 10;
            return id;
        }
        for(i in 0...path.length) {
            var p = path[i];
            var pp = i == 0 ? {x: -10, y: -10} : path[i - 1];
            var np = i == path.length - 1 ? {x: -10, y: -10} : path[i + 1];
            var id = getId(pp, p, np, false);
            if(id == 8) {
                id = getId(np, p, pp, true);
            }
            var ty = Std.int(id / 5), tx = id % 5;
            var sub = atlas.sub(tx * Level.TS, ty * Level.TS, Level.TS, Level.TS);
            tg.add(p.x * Level.TS, p.y * Level.TS, sub);
        }
    }

    public function canRun() {
        return path != null && path.length > 1;
    }

    public function run() {
        if(!canRun()) return;
        for(i in 1...path.length - 1) {
            var dx = path[i].x - path[i - 1].x;
            var dy = path[i].y - path[i - 1].y;
            Game.inst.hero.pushStep(Move(dx, dy));
        }
        var dx = path[path.length - 1].x - path[path.length - 2].x;
        var dy = path[path.length - 1].y - path[path.length - 2].y;
        Game.inst.hero.pushStep(TryMove(dx, dy));
    }

    public function set_visible(v:Bool) {
        tg.visible = v;
        return v;
    }
}
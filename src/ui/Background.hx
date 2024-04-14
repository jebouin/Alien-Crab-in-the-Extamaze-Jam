package ui;

import h2d.Object;
import h2d.Tile;
import CustomSpriteBatch;

class Star extends CustomSpriteBatch.BatchElement {
    var speed : Float;

    public function new(rand:Rand) {
        var t = rand.rangeFloat(0, 1);
        speed = (30 + t * 30) * .5;
        super(Background.tile);
        x = rand.rangeFloat(0, Main.WIDTH);
        y = rand.rangeFloat(0, Main.HEIGHT);
        a = t * .5 + .2;
        r = rand.rangeFloat(.7, 1.);
        g = rand.rangeFloat(.7, 1.);
        b = rand.rangeFloat(.7, 1.);
    }

    override public function update(dt:Float) {
        y += speed * dt;
        if(x > Main.WIDTH) {
            x -= Main.WIDTH;
        }
        if(x < 0) {
            x += Main.WIDTH;
        }
        if(y > Main.HEIGHT) {
            y -= Main.HEIGHT;
        }
        if(x < 0) {
            y += Main.HEIGHT;
        }
        return true;
    }
}

class Background {
    public inline static var COUNT = 100;
    public static var tile : Tile;
    var sb : CustomSpriteBatch;
    var rand : Rand;

    public function new(parent:Object) {
        tile = Tile.fromColor(0xFFFFFF, 1, 1);
        sb = new CustomSpriteBatch(tile, parent);
        rand = new Rand(456);
        for(i in 0...COUNT) {
            sb.add(new Star(rand));
        }
        sb.hasUpdate = true;
    }

    public function update(dt:Float) {
        sb.update(dt);
    }
}
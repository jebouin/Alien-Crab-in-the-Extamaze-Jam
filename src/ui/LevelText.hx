package ui;

import h2d.TileGroup;
import h2d.Bitmap;
import h2d.Flow;
import h2d.Object;

class LevelText extends Flow {
    var tg : TileGroup;
    var val : Int;

    public function new(parent:Object, val:Int) {
        super(parent);
        var baseTile = Assets.getTile("ui", "textLV");
        tg = new TileGroup(baseTile, this);
        tg.add(0, 0, baseTile);
        this.val = val;
        var digits = [];
        while(val > 0) {
            var digit = val % 10;
            digits.push(digit);
            val = Std.int(val / 10);
        }
        digits.reverse();
        var x = baseTile.width;
        for(d in digits) {
            var t = Assets.getTile("ui", "textLV" + d);
            tg.add(x, 0, t);
            x += t.width;
        }
    }
}
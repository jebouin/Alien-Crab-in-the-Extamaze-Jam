package entities;

import h2d.Bitmap;

class Door extends Entity {
    @:s public var type : Int;
    var pupil : Bitmap;

    public function new(floorId:Int, tx:Int, ty:Int, type:Int) {
        this.type = type;
        super("", floorId, tx, ty);
    }

    override public function init(?animName:String=null) {
        super.init("door" + type);
        if(type == 4) {
            pupil = new Bitmap(Assets.getTile("entities", "doorPupil"), anim);
        }
    }

    public function open() {
        Game.inst.onChange();
        Game.inst.fx.doorOpen(anim.x, anim.y, type);
        delete();
    }

    override public function update(dt:Float) {
        if(type == 4) {
            var dx = Game.inst.hero.anim.x - anim.x;
            var dy = Game.inst.hero.anim.y - anim.y;
            var d = Math.sqrt(dx*dx + dy*dy);
            dx /= d;
            dy /= d;
            var dist = 1.5;
            pupil.x = Math.round(dx * dist);
            pupil.y = Math.round(dy * dist) - 2;
        }
    }
}